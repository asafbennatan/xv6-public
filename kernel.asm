
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
8010002d:	b8 cb 43 10 80       	mov    $0x801043cb,%eax
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
8010003d:	68 94 93 10 80       	push   $0x80109394
80100042:	68 e0 d6 10 80       	push   $0x8010d6e0
80100047:	e8 16 5b 00 00       	call   80105b62 <initlock>
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
801000c1:	e8 be 5a 00 00       	call   80105b84 <acquire>
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
8010010c:	e8 da 5a 00 00       	call   80105beb <release>
80100111:	83 c4 10             	add    $0x10,%esp
        return b;
80100114:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100117:	e9 98 00 00 00       	jmp    801001b4 <bget+0x101>
      }
      sleep(b, &bcache.lock);
8010011c:	83 ec 08             	sub    $0x8,%esp
8010011f:	68 e0 d6 10 80       	push   $0x8010d6e0
80100124:	ff 75 f4             	pushl  -0xc(%ebp)
80100127:	e8 5f 57 00 00       	call   8010588b <sleep>
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
80100188:	e8 5e 5a 00 00       	call   80105beb <release>
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
801001aa:	68 9b 93 10 80       	push   $0x8010939b
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
80100204:	68 ac 93 10 80       	push   $0x801093ac
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
80100243:	68 b3 93 10 80       	push   $0x801093b3
80100248:	e8 19 03 00 00       	call   80100566 <panic>

  acquire(&bcache.lock);
8010024d:	83 ec 0c             	sub    $0xc,%esp
80100250:	68 e0 d6 10 80       	push   $0x8010d6e0
80100255:	e8 2a 59 00 00       	call   80105b84 <acquire>
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
801002b9:	e8 b8 56 00 00       	call   80105976 <wakeup>
801002be:	83 c4 10             	add    $0x10,%esp

  release(&bcache.lock);
801002c1:	83 ec 0c             	sub    $0xc,%esp
801002c4:	68 e0 d6 10 80       	push   $0x8010d6e0
801002c9:	e8 1d 59 00 00       	call   80105beb <release>
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
801003e2:	e8 9d 57 00 00       	call   80105b84 <acquire>
801003e7:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
801003ea:	8b 45 08             	mov    0x8(%ebp),%eax
801003ed:	85 c0                	test   %eax,%eax
801003ef:	75 0d                	jne    801003fe <cprintf+0x38>
    panic("null fmt");
801003f1:	83 ec 0c             	sub    $0xc,%esp
801003f4:	68 ba 93 10 80       	push   $0x801093ba
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
801004cd:	c7 45 ec c3 93 10 80 	movl   $0x801093c3,-0x14(%ebp)
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
8010055b:	e8 8b 56 00 00       	call   80105beb <release>
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
8010058b:	68 ca 93 10 80       	push   $0x801093ca
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
801005aa:	68 d9 93 10 80       	push   $0x801093d9
801005af:	e8 12 fe ff ff       	call   801003c6 <cprintf>
801005b4:	83 c4 10             	add    $0x10,%esp
  getcallerpcs(&s, pcs);
801005b7:	83 ec 08             	sub    $0x8,%esp
801005ba:	8d 45 cc             	lea    -0x34(%ebp),%eax
801005bd:	50                   	push   %eax
801005be:	8d 45 08             	lea    0x8(%ebp),%eax
801005c1:	50                   	push   %eax
801005c2:	e8 76 56 00 00       	call   80105c3d <getcallerpcs>
801005c7:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
801005ca:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801005d1:	eb 1c                	jmp    801005ef <panic+0x89>
    cprintf(" %p", pcs[i]);
801005d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801005d6:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
801005da:	83 ec 08             	sub    $0x8,%esp
801005dd:	50                   	push   %eax
801005de:	68 db 93 10 80       	push   $0x801093db
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
801006ca:	68 df 93 10 80       	push   $0x801093df
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
801006f7:	e8 aa 57 00 00       	call   80105ea6 <memmove>
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
80100721:	e8 c1 56 00 00       	call   80105de7 <memset>
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
801007b6:	e8 61 72 00 00       	call   80107a1c <uartputc>
801007bb:	83 c4 10             	add    $0x10,%esp
801007be:	83 ec 0c             	sub    $0xc,%esp
801007c1:	6a 20                	push   $0x20
801007c3:	e8 54 72 00 00       	call   80107a1c <uartputc>
801007c8:	83 c4 10             	add    $0x10,%esp
801007cb:	83 ec 0c             	sub    $0xc,%esp
801007ce:	6a 08                	push   $0x8
801007d0:	e8 47 72 00 00       	call   80107a1c <uartputc>
801007d5:	83 c4 10             	add    $0x10,%esp
801007d8:	eb 0e                	jmp    801007e8 <consputc+0x56>
  } else
    uartputc(c);
801007da:	83 ec 0c             	sub    $0xc,%esp
801007dd:	ff 75 08             	pushl  0x8(%ebp)
801007e0:	e8 37 72 00 00       	call   80107a1c <uartputc>
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
8010080e:	e8 71 53 00 00       	call   80105b84 <acquire>
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
80100956:	e8 1b 50 00 00       	call   80105976 <wakeup>
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
80100979:	e8 6d 52 00 00       	call   80105beb <release>
8010097e:	83 c4 10             	add    $0x10,%esp
  if(doprocdump) {
80100981:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100985:	74 05                	je     8010098c <consoleintr+0x193>
    procdump();  // now call procdump() wo. cons.lock held
80100987:	e8 a5 50 00 00       	call   80105a31 <procdump>
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
8010099b:	e8 eb 16 00 00       	call   8010208b <iunlock>
801009a0:	83 c4 10             	add    $0x10,%esp
  target = n;
801009a3:	8b 45 10             	mov    0x10(%ebp),%eax
801009a6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&cons.lock);
801009a9:	83 ec 0c             	sub    $0xc,%esp
801009ac:	68 c0 c5 10 80       	push   $0x8010c5c0
801009b1:	e8 ce 51 00 00       	call   80105b84 <acquire>
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
801009d3:	e8 13 52 00 00       	call   80105beb <release>
801009d8:	83 c4 10             	add    $0x10,%esp
        //cprintf("cRead \n");
        ilock(ip);
801009db:	83 ec 0c             	sub    $0xc,%esp
801009de:	ff 75 08             	pushl  0x8(%ebp)
801009e1:	e8 04 15 00 00       	call   80101eea <ilock>
801009e6:	83 c4 10             	add    $0x10,%esp
        return -1;
801009e9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801009ee:	e9 ab 00 00 00       	jmp    80100a9e <consoleread+0x10f>
      }
      sleep(&input.r, &cons.lock);
801009f3:	83 ec 08             	sub    $0x8,%esp
801009f6:	68 c0 c5 10 80       	push   $0x8010c5c0
801009fb:	68 e0 18 11 80       	push   $0x801118e0
80100a00:	e8 86 4e 00 00       	call   8010588b <sleep>
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
80100a7e:	e8 68 51 00 00       	call   80105beb <release>
80100a83:	83 c4 10             	add    $0x10,%esp
          //    cprintf("cRead2 \n");

  ilock(ip);
80100a86:	83 ec 0c             	sub    $0xc,%esp
80100a89:	ff 75 08             	pushl  0x8(%ebp)
80100a8c:	e8 59 14 00 00       	call   80101eea <ilock>
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
80100aac:	e8 da 15 00 00       	call   8010208b <iunlock>
80100ab1:	83 c4 10             	add    $0x10,%esp
  acquire(&cons.lock);
80100ab4:	83 ec 0c             	sub    $0xc,%esp
80100ab7:	68 c0 c5 10 80       	push   $0x8010c5c0
80100abc:	e8 c3 50 00 00       	call   80105b84 <acquire>
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
80100afe:	e8 e8 50 00 00       	call   80105beb <release>
80100b03:	83 c4 10             	add    $0x10,%esp
        //  cprintf("cWrite \n");

  ilock(ip);
80100b06:	83 ec 0c             	sub    $0xc,%esp
80100b09:	ff 75 08             	pushl  0x8(%ebp)
80100b0c:	e8 d9 13 00 00       	call   80101eea <ilock>
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
80100b22:	68 f2 93 10 80       	push   $0x801093f2
80100b27:	68 c0 c5 10 80       	push   $0x8010c5c0
80100b2c:	e8 31 50 00 00       	call   80105b62 <initlock>
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
80100b57:	e8 ee 3e 00 00       	call   80104a4a <picenable>
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
80100b8d:	e8 fe 32 00 00       	call   80103e90 <begin_op>
80100b92:	83 c4 10             	add    $0x10,%esp
  if((ip = namei(path)) == 0){
80100b95:	83 ec 0c             	sub    $0xc,%esp
80100b98:	ff 75 08             	pushl  0x8(%ebp)
80100b9b:	e8 5b 21 00 00       	call   80102cfb <namei>
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
80100bbf:	e8 d3 33 00 00       	call   80103f97 <end_op>
80100bc4:	83 c4 10             	add    $0x10,%esp
    return -1;
80100bc7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100bcc:	e9 fa 03 00 00       	jmp    80100fcb <exec+0x45a>
  }
           // cprintf("exec \n");

  ilock(ip);
80100bd1:	83 ec 0c             	sub    $0xc,%esp
80100bd4:	ff 75 d8             	pushl  -0x28(%ebp)
80100bd7:	e8 0e 13 00 00       	call   80101eea <ilock>
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
80100bf4:	e8 7f 19 00 00       	call   80102578 <readi>
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
80100c16:	e8 56 7f 00 00       	call   80108b71 <setupkvm>
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
80100c54:	e8 1f 19 00 00       	call   80102578 <readi>
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
80100c9c:	e8 77 82 00 00       	call   80108f18 <allocuvm>
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
80100ccf:	e8 6d 81 00 00       	call   80108e41 <loaduvm>
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
80100d08:	e8 e0 14 00 00       	call   801021ed <iunlockput>
80100d0d:	83 c4 10             	add    $0x10,%esp
  end_op(proc->cwd->part->number);
80100d10:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100d16:	8b 40 68             	mov    0x68(%eax),%eax
80100d19:	8b 40 50             	mov    0x50(%eax),%eax
80100d1c:	8b 40 14             	mov    0x14(%eax),%eax
80100d1f:	83 ec 0c             	sub    $0xc,%esp
80100d22:	50                   	push   %eax
80100d23:	e8 6f 32 00 00       	call   80103f97 <end_op>
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
80100d54:	e8 bf 81 00 00       	call   80108f18 <allocuvm>
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
80100d78:	e8 c1 83 00 00       	call   8010913e <clearpteu>
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
80100db1:	e8 7e 52 00 00       	call   80106034 <strlen>
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
80100dde:	e8 51 52 00 00       	call   80106034 <strlen>
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
80100e04:	e8 ec 84 00 00       	call   801092f5 <copyout>
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
80100ea0:	e8 50 84 00 00       	call   801092f5 <copyout>
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
80100ef1:	e8 f4 50 00 00       	call   80105fea <safestrcpy>
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
80100f47:	e8 0c 7d 00 00       	call   80108c58 <switchuvm>
80100f4c:	83 c4 10             	add    $0x10,%esp
  freevm(oldpgdir);
80100f4f:	83 ec 0c             	sub    $0xc,%esp
80100f52:	ff 75 d0             	pushl  -0x30(%ebp)
80100f55:	e8 44 81 00 00       	call   8010909e <freevm>
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
80100f8f:	e8 0a 81 00 00       	call   8010909e <freevm>
80100f94:	83 c4 10             	add    $0x10,%esp
  if(ip){
80100f97:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100f9b:	74 29                	je     80100fc6 <exec+0x455>
    iunlockput(ip);
80100f9d:	83 ec 0c             	sub    $0xc,%esp
80100fa0:	ff 75 d8             	pushl  -0x28(%ebp)
80100fa3:	e8 45 12 00 00       	call   801021ed <iunlockput>
80100fa8:	83 c4 10             	add    $0x10,%esp
    end_op(proc->cwd->part->number);
80100fab:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100fb1:	8b 40 68             	mov    0x68(%eax),%eax
80100fb4:	8b 40 50             	mov    0x50(%eax),%eax
80100fb7:	8b 40 14             	mov    0x14(%eax),%eax
80100fba:	83 ec 0c             	sub    $0xc,%esp
80100fbd:	50                   	push   %eax
80100fbe:	e8 d4 2f 00 00       	call   80103f97 <end_op>
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
80100fd6:	68 fa 93 10 80       	push   $0x801093fa
80100fdb:	68 00 19 11 80       	push   $0x80111900
80100fe0:	e8 7d 4b 00 00       	call   80105b62 <initlock>
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
80100ff9:	e8 86 4b 00 00       	call   80105b84 <acquire>
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
80101026:	e8 c0 4b 00 00       	call   80105beb <release>
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
80101049:	e8 9d 4b 00 00       	call   80105beb <release>
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
80101066:	e8 19 4b 00 00       	call   80105b84 <acquire>
8010106b:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
8010106e:	8b 45 08             	mov    0x8(%ebp),%eax
80101071:	8b 40 04             	mov    0x4(%eax),%eax
80101074:	85 c0                	test   %eax,%eax
80101076:	7f 0d                	jg     80101085 <filedup+0x2d>
    panic("filedup");
80101078:	83 ec 0c             	sub    $0xc,%esp
8010107b:	68 01 94 10 80       	push   $0x80109401
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
8010109c:	e8 4a 4b 00 00       	call   80105beb <release>
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
801010b7:	e8 c8 4a 00 00       	call   80105b84 <acquire>
801010bc:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
801010bf:	8b 45 08             	mov    0x8(%ebp),%eax
801010c2:	8b 40 04             	mov    0x4(%eax),%eax
801010c5:	85 c0                	test   %eax,%eax
801010c7:	7f 0d                	jg     801010d6 <fileclose+0x2d>
    panic("fileclose");
801010c9:	83 ec 0c             	sub    $0xc,%esp
801010cc:	68 09 94 10 80       	push   $0x80109409
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
801010f7:	e8 ef 4a 00 00       	call   80105beb <release>
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
80101147:	e8 9f 4a 00 00       	call   80105beb <release>
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
80101166:	e8 48 3b 00 00       	call   80104cb3 <pipeclose>
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
80101188:	e8 03 2d 00 00       	call   80103e90 <begin_op>
8010118d:	83 c4 10             	add    $0x10,%esp
    iput(ff.ip);
80101190:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101193:	83 ec 0c             	sub    $0xc,%esp
80101196:	50                   	push   %eax
80101197:	e8 61 0f 00 00       	call   801020fd <iput>
8010119c:	83 c4 10             	add    $0x10,%esp
    end_op(f->ip->part->number);
8010119f:	8b 45 08             	mov    0x8(%ebp),%eax
801011a2:	8b 40 0e             	mov    0xe(%eax),%eax
801011a5:	8b 40 50             	mov    0x50(%eax),%eax
801011a8:	8b 40 14             	mov    0x14(%eax),%eax
801011ab:	83 ec 0c             	sub    $0xc,%esp
801011ae:	50                   	push   %eax
801011af:	e8 e3 2d 00 00       	call   80103f97 <end_op>
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
801011d3:	e8 12 0d 00 00       	call   80101eea <ilock>
801011d8:	83 c4 10             	add    $0x10,%esp
    stati(f->ip, st);
801011db:	8b 45 08             	mov    0x8(%ebp),%eax
801011de:	8b 40 0e             	mov    0xe(%eax),%eax
801011e1:	83 ec 08             	sub    $0x8,%esp
801011e4:	ff 75 0c             	pushl  0xc(%ebp)
801011e7:	50                   	push   %eax
801011e8:	e8 45 13 00 00       	call   80102532 <stati>
801011ed:	83 c4 10             	add    $0x10,%esp
   // cprintf("filestat \n");

    iunlock(f->ip);
801011f0:	8b 45 08             	mov    0x8(%ebp),%eax
801011f3:	8b 40 0e             	mov    0xe(%eax),%eax
801011f6:	83 ec 0c             	sub    $0xc,%esp
801011f9:	50                   	push   %eax
801011fa:	e8 8c 0e 00 00       	call   8010208b <iunlock>
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
80101245:	e8 11 3c 00 00       	call   80104e5b <piperead>
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
80101263:	e8 82 0c 00 00       	call   80101eea <ilock>
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
80101280:	e8 f3 12 00 00       	call   80102578 <readi>
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
801012ac:	e8 da 0d 00 00       	call   8010208b <iunlock>
801012b1:	83 c4 10             	add    $0x10,%esp
    return r;
801012b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801012b7:	eb 0d                	jmp    801012c6 <fileread+0xb6>
  }
  panic("fileread");
801012b9:	83 ec 0c             	sub    $0xc,%esp
801012bc:	68 13 94 10 80       	push   $0x80109413
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
801012fe:	e8 5a 3a 00 00       	call   80104d5d <pipewrite>
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
80101353:	e8 38 2b 00 00       	call   80103e90 <begin_op>
80101358:	83 c4 10             	add    $0x10,%esp
      ilock(f->ip);
8010135b:	8b 45 08             	mov    0x8(%ebp),%eax
8010135e:	8b 40 0e             	mov    0xe(%eax),%eax
80101361:	83 ec 0c             	sub    $0xc,%esp
80101364:	50                   	push   %eax
80101365:	e8 80 0b 00 00       	call   80101eea <ilock>
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
80101388:	e8 8b 13 00 00       	call   80102718 <writei>
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
801013b4:	e8 d2 0c 00 00       	call   8010208b <iunlock>
801013b9:	83 c4 10             	add    $0x10,%esp
      end_op(f->ip->part->number);
801013bc:	8b 45 08             	mov    0x8(%ebp),%eax
801013bf:	8b 40 0e             	mov    0xe(%eax),%eax
801013c2:	8b 40 50             	mov    0x50(%eax),%eax
801013c5:	8b 40 14             	mov    0x14(%eax),%eax
801013c8:	83 ec 0c             	sub    $0xc,%esp
801013cb:	50                   	push   %eax
801013cc:	e8 c6 2b 00 00       	call   80103f97 <end_op>
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
801013e5:	68 1c 94 10 80       	push   $0x8010941c
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
8010141b:	68 2c 94 10 80       	push   $0x8010942c
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
8010146c:	e8 35 4a 00 00       	call   80105ea6 <memmove>
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
801014d3:	e8 ce 49 00 00       	call   80105ea6 <memmove>
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
80101519:	e8 c9 48 00 00       	call   80105de7 <memset>
8010151e:	83 c4 10             	add    $0x10,%esp
    log_write(bp,partitionNumber);
80101521:	83 ec 08             	sub    $0x8,%esp
80101524:	ff 75 10             	pushl  0x10(%ebp)
80101527:	ff 75 f4             	pushl  -0xc(%ebp)
8010152a:	e8 0e 2d 00 00       	call   8010423d <log_write>
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
8010163f:	e8 f9 2b 00 00       	call   8010423d <log_write>
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
801016ca:	68 38 94 10 80       	push   $0x80109438
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
80101787:	68 4e 94 10 80       	push   $0x8010944e
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
801017c3:	e8 75 2a 00 00       	call   8010423d <log_write>
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
801017e5:	68 61 94 10 80       	push   $0x80109461
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
8010182a:	c7 45 f0 6c 94 10 80 	movl   $0x8010946c,-0x10(%ebp)
80101831:	eb 07                	jmp    8010183a <printMBR+0x5e>

        } else {
            bootable = "NO";
80101833:	c7 45 f0 70 94 10 80 	movl   $0x80109470,-0x10(%ebp)
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
80101889:	c7 45 ec 73 94 10 80 	movl   $0x80109473,-0x14(%ebp)
            cprintf("unknown type %d \n", m->partitions[i].type);
80101890:	8b 45 08             	mov    0x8(%ebp),%eax
80101893:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101896:	83 c2 1b             	add    $0x1b,%edx
80101899:	c1 e2 04             	shl    $0x4,%edx
8010189c:	01 d0                	add    %edx,%eax
8010189e:	8b 40 12             	mov    0x12(%eax),%eax
801018a1:	83 ec 08             	sub    $0x8,%esp
801018a4:	50                   	push   %eax
801018a5:	68 77 94 10 80       	push   $0x80109477
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
801018e2:	68 8c 94 10 80       	push   $0x8010948c
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
80101909:	68 c2 94 10 80       	push   $0x801094c2
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
80101a46:	68 cd 94 10 80       	push   $0x801094cd
80101a4b:	68 60 24 11 80       	push   $0x80112460
80101a50:	e8 0d 41 00 00       	call   80105b62 <initlock>
80101a55:	83 c4 10             	add    $0x10,%esp

    rootNode = p->cwd;
80101a58:	8b 45 08             	mov    0x8(%ebp),%eax
80101a5b:	8b 40 68             	mov    0x68(%eax),%eax
80101a5e:	89 45 e0             	mov    %eax,-0x20(%ebp)
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
80101a88:	68 d4 94 10 80       	push   $0x801094d4
80101a8d:	e8 34 e9 ff ff       	call   801003c6 <cprintf>
80101a92:	83 c4 10             	add    $0x10,%esp
    if (bootfrom == -1) {
80101a95:	a1 18 a0 10 80       	mov    0x8010a018,%eax
80101a9a:	83 f8 ff             	cmp    $0xffffffff,%eax
80101a9d:	75 0d                	jne    80101aac <iinit+0x72>
        panic("no bootable partition");
80101a9f:	83 ec 0c             	sub    $0xc,%esp
80101aa2:	68 e6 94 10 80       	push   $0x801094e6
80101aa7:	e8 ba ea ff ff       	call   80100566 <panic>
    }
    rootNode->part = &(partitions[bootfrom]);
80101aac:	8b 15 18 a0 10 80    	mov    0x8010a018,%edx
80101ab2:	89 d0                	mov    %edx,%eax
80101ab4:	01 c0                	add    %eax,%eax
80101ab6:	01 d0                	add    %edx,%eax
80101ab8:	c1 e0 03             	shl    $0x3,%eax
80101abb:	8d 90 00 18 11 80    	lea    -0x7feee800(%eax),%edx
80101ac1:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101ac4:	89 50 50             	mov    %edx,0x50(%eax)
    int i;
    for(i=0;i<NPARTITIONS;i++){
80101ac7:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80101ace:	e9 89 00 00 00       	jmp    80101b5c <iinit+0x122>
    readsb(dev, i);
80101ad3:	83 ec 08             	sub    $0x8,%esp
80101ad6:	ff 75 e4             	pushl  -0x1c(%ebp)
80101ad9:	ff 75 0c             	pushl  0xc(%ebp)
80101adc:	e8 49 f9 ff ff       	call   8010142a <readsb>
80101ae1:	83 c4 10             	add    $0x10,%esp
    sb = sbs[i];
80101ae4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101ae7:	c1 e0 05             	shl    $0x5,%eax
80101aea:	05 60 d6 10 80       	add    $0x8010d660,%eax
80101aef:	8b 10                	mov    (%eax),%edx
80101af1:	89 55 c0             	mov    %edx,-0x40(%ebp)
80101af4:	8b 50 04             	mov    0x4(%eax),%edx
80101af7:	89 55 c4             	mov    %edx,-0x3c(%ebp)
80101afa:	8b 50 08             	mov    0x8(%eax),%edx
80101afd:	89 55 c8             	mov    %edx,-0x38(%ebp)
80101b00:	8b 50 0c             	mov    0xc(%eax),%edx
80101b03:	89 55 cc             	mov    %edx,-0x34(%ebp)
80101b06:	8b 50 10             	mov    0x10(%eax),%edx
80101b09:	89 55 d0             	mov    %edx,-0x30(%ebp)
80101b0c:	8b 50 14             	mov    0x14(%eax),%edx
80101b0f:	89 55 d4             	mov    %edx,-0x2c(%ebp)
80101b12:	8b 50 18             	mov    0x18(%eax),%edx
80101b15:	89 55 d8             	mov    %edx,-0x28(%ebp)
80101b18:	8b 40 1c             	mov    0x1c(%eax),%eax
80101b1b:	89 45 dc             	mov    %eax,-0x24(%ebp)
     cprintf("sb: offset %d size %d nblocks %d ninodes %d nlog %d logstart %d inodestart %d bmap start %d\n",
80101b1e:	8b 55 d8             	mov    -0x28(%ebp),%edx
80101b21:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80101b24:	89 45 b4             	mov    %eax,-0x4c(%ebp)
80101b27:	8b 4d d0             	mov    -0x30(%ebp),%ecx
80101b2a:	89 4d b0             	mov    %ecx,-0x50(%ebp)
80101b2d:	8b 7d cc             	mov    -0x34(%ebp),%edi
80101b30:	8b 75 c8             	mov    -0x38(%ebp),%esi
80101b33:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
80101b36:	8b 4d c0             	mov    -0x40(%ebp),%ecx
80101b39:	8b 45 dc             	mov    -0x24(%ebp),%eax
80101b3c:	83 ec 0c             	sub    $0xc,%esp
80101b3f:	52                   	push   %edx
80101b40:	ff 75 b4             	pushl  -0x4c(%ebp)
80101b43:	ff 75 b0             	pushl  -0x50(%ebp)
80101b46:	57                   	push   %edi
80101b47:	56                   	push   %esi
80101b48:	53                   	push   %ebx
80101b49:	51                   	push   %ecx
80101b4a:	50                   	push   %eax
80101b4b:	68 fc 94 10 80       	push   $0x801094fc
80101b50:	e8 71 e8 ff ff       	call   801003c6 <cprintf>
80101b55:	83 c4 30             	add    $0x30,%esp
    if (bootfrom == -1) {
        panic("no bootable partition");
    }
    rootNode->part = &(partitions[bootfrom]);
    int i;
    for(i=0;i<NPARTITIONS;i++){
80101b58:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80101b5c:	83 7d e4 03          	cmpl   $0x3,-0x1c(%ebp)
80101b60:	0f 8e 6d ff ff ff    	jle    80101ad3 <iinit+0x99>

    // cprintf("root node init %d \n",rootNode->part->offset);
   
            
    
            return bootfrom;
80101b66:	a1 18 a0 10 80       	mov    0x8010a018,%eax
}
80101b6b:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101b6e:	5b                   	pop    %ebx
80101b6f:	5e                   	pop    %esi
80101b70:	5f                   	pop    %edi
80101b71:	5d                   	pop    %ebp
80101b72:	c3                   	ret    

80101b73 <ialloc>:

// PAGEBREAK!
// Allocate a new inode with the given type on device dev.
// A free inode has a type of zero.
struct inode* ialloc(uint dev, short type, int partitionNumber)
{
80101b73:	55                   	push   %ebp
80101b74:	89 e5                	mov    %esp,%ebp
80101b76:	83 ec 48             	sub    $0x48,%esp
80101b79:	8b 45 0c             	mov    0xc(%ebp),%eax
80101b7c:	66 89 45 c4          	mov    %ax,-0x3c(%ebp)
     //cprintf("ialloc \n");
    int inum;
    struct buf* bp;
    struct dinode* dip;
    struct superblock sb;
    sb = sbs[partitionNumber];
80101b80:	8b 45 10             	mov    0x10(%ebp),%eax
80101b83:	c1 e0 05             	shl    $0x5,%eax
80101b86:	05 60 d6 10 80       	add    $0x8010d660,%eax
80101b8b:	8b 10                	mov    (%eax),%edx
80101b8d:	89 55 cc             	mov    %edx,-0x34(%ebp)
80101b90:	8b 50 04             	mov    0x4(%eax),%edx
80101b93:	89 55 d0             	mov    %edx,-0x30(%ebp)
80101b96:	8b 50 08             	mov    0x8(%eax),%edx
80101b99:	89 55 d4             	mov    %edx,-0x2c(%ebp)
80101b9c:	8b 50 0c             	mov    0xc(%eax),%edx
80101b9f:	89 55 d8             	mov    %edx,-0x28(%ebp)
80101ba2:	8b 50 10             	mov    0x10(%eax),%edx
80101ba5:	89 55 dc             	mov    %edx,-0x24(%ebp)
80101ba8:	8b 50 14             	mov    0x14(%eax),%edx
80101bab:	89 55 e0             	mov    %edx,-0x20(%ebp)
80101bae:	8b 50 18             	mov    0x18(%eax),%edx
80101bb1:	89 55 e4             	mov    %edx,-0x1c(%ebp)
80101bb4:	8b 40 1c             	mov    0x1c(%eax),%eax
80101bb7:	89 45 e8             	mov    %eax,-0x18(%ebp)
    //  cprintf("ialloc pnumber %d , numberofnods %d \n", partitionNumber, sb.ninodes);
    for (inum = 1; inum < sb.ninodes; inum++) {
80101bba:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
80101bc1:	e9 a9 00 00 00       	jmp    80101c6f <ialloc+0xfc>
        // cprintf("checking inode %d \n", inum);
        bp = bread(dev, IBLOCK(inum, sb));
80101bc6:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101bc9:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101bcc:	89 d1                	mov    %edx,%ecx
80101bce:	c1 e9 03             	shr    $0x3,%ecx
80101bd1:	8b 55 e0             	mov    -0x20(%ebp),%edx
80101bd4:	01 ca                	add    %ecx,%edx
80101bd6:	01 d0                	add    %edx,%eax
80101bd8:	83 ec 08             	sub    $0x8,%esp
80101bdb:	50                   	push   %eax
80101bdc:	ff 75 08             	pushl  0x8(%ebp)
80101bdf:	e8 d2 e5 ff ff       	call   801001b6 <bread>
80101be4:	83 c4 10             	add    $0x10,%esp
80101be7:	89 45 f0             	mov    %eax,-0x10(%ebp)
        dip = (struct dinode*)bp->data + inum % IPB;
80101bea:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101bed:	8d 50 18             	lea    0x18(%eax),%edx
80101bf0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101bf3:	83 e0 07             	and    $0x7,%eax
80101bf6:	c1 e0 06             	shl    $0x6,%eax
80101bf9:	01 d0                	add    %edx,%eax
80101bfb:	89 45 ec             	mov    %eax,-0x14(%ebp)
        if (dip->type == 0) { // a free inode
80101bfe:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101c01:	0f b7 00             	movzwl (%eax),%eax
80101c04:	66 85 c0             	test   %ax,%ax
80101c07:	75 54                	jne    80101c5d <ialloc+0xea>
            memset(dip, 0, sizeof(*dip));
80101c09:	83 ec 04             	sub    $0x4,%esp
80101c0c:	6a 40                	push   $0x40
80101c0e:	6a 00                	push   $0x0
80101c10:	ff 75 ec             	pushl  -0x14(%ebp)
80101c13:	e8 cf 41 00 00       	call   80105de7 <memset>
80101c18:	83 c4 10             	add    $0x10,%esp
            dip->type = type;
80101c1b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101c1e:	0f b7 55 c4          	movzwl -0x3c(%ebp),%edx
80101c22:	66 89 10             	mov    %dx,(%eax)
            log_write(bp,partitionNumber); // mark it allocated on the disk
80101c25:	8b 45 10             	mov    0x10(%ebp),%eax
80101c28:	83 ec 08             	sub    $0x8,%esp
80101c2b:	50                   	push   %eax
80101c2c:	ff 75 f0             	pushl  -0x10(%ebp)
80101c2f:	e8 09 26 00 00       	call   8010423d <log_write>
80101c34:	83 c4 10             	add    $0x10,%esp
            brelse(bp);
80101c37:	83 ec 0c             	sub    $0xc,%esp
80101c3a:	ff 75 f0             	pushl  -0x10(%ebp)
80101c3d:	e8 ec e5 ff ff       	call   8010022e <brelse>
80101c42:	83 c4 10             	add    $0x10,%esp
            return iget(dev, inum, partitionNumber);
80101c45:	8b 55 10             	mov    0x10(%ebp),%edx
80101c48:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101c4b:	83 ec 04             	sub    $0x4,%esp
80101c4e:	52                   	push   %edx
80101c4f:	50                   	push   %eax
80101c50:	ff 75 08             	pushl  0x8(%ebp)
80101c53:	e8 42 01 00 00       	call   80101d9a <iget>
80101c58:	83 c4 10             	add    $0x10,%esp
80101c5b:	eb 2d                	jmp    80101c8a <ialloc+0x117>
        }
        brelse(bp);
80101c5d:	83 ec 0c             	sub    $0xc,%esp
80101c60:	ff 75 f0             	pushl  -0x10(%ebp)
80101c63:	e8 c6 e5 ff ff       	call   8010022e <brelse>
80101c68:	83 c4 10             	add    $0x10,%esp
    struct buf* bp;
    struct dinode* dip;
    struct superblock sb;
    sb = sbs[partitionNumber];
    //  cprintf("ialloc pnumber %d , numberofnods %d \n", partitionNumber, sb.ninodes);
    for (inum = 1; inum < sb.ninodes; inum++) {
80101c6b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101c6f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80101c72:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101c75:	39 c2                	cmp    %eax,%edx
80101c77:	0f 87 49 ff ff ff    	ja     80101bc6 <ialloc+0x53>
            brelse(bp);
            return iget(dev, inum, partitionNumber);
        }
        brelse(bp);
    }
    panic("ialloc: no inodes");
80101c7d:	83 ec 0c             	sub    $0xc,%esp
80101c80:	68 59 95 10 80       	push   $0x80109559
80101c85:	e8 dc e8 ff ff       	call   80100566 <panic>
}
80101c8a:	c9                   	leave  
80101c8b:	c3                   	ret    

80101c8c <iupdate>:

// Copy a modified in-memory inode to disk.
void iupdate(struct inode* ip)
{
80101c8c:	55                   	push   %ebp
80101c8d:	89 e5                	mov    %esp,%ebp
80101c8f:	83 ec 38             	sub    $0x38,%esp

    struct buf* bp;
    struct dinode* dip;
    struct superblock sb;

    sb = sbs[ip->part->number];
80101c92:	8b 45 08             	mov    0x8(%ebp),%eax
80101c95:	8b 40 50             	mov    0x50(%eax),%eax
80101c98:	8b 40 14             	mov    0x14(%eax),%eax
80101c9b:	c1 e0 05             	shl    $0x5,%eax
80101c9e:	05 60 d6 10 80       	add    $0x8010d660,%eax
80101ca3:	8b 10                	mov    (%eax),%edx
80101ca5:	89 55 d0             	mov    %edx,-0x30(%ebp)
80101ca8:	8b 50 04             	mov    0x4(%eax),%edx
80101cab:	89 55 d4             	mov    %edx,-0x2c(%ebp)
80101cae:	8b 50 08             	mov    0x8(%eax),%edx
80101cb1:	89 55 d8             	mov    %edx,-0x28(%ebp)
80101cb4:	8b 50 0c             	mov    0xc(%eax),%edx
80101cb7:	89 55 dc             	mov    %edx,-0x24(%ebp)
80101cba:	8b 50 10             	mov    0x10(%eax),%edx
80101cbd:	89 55 e0             	mov    %edx,-0x20(%ebp)
80101cc0:	8b 50 14             	mov    0x14(%eax),%edx
80101cc3:	89 55 e4             	mov    %edx,-0x1c(%ebp)
80101cc6:	8b 50 18             	mov    0x18(%eax),%edx
80101cc9:	89 55 e8             	mov    %edx,-0x18(%ebp)
80101ccc:	8b 40 1c             	mov    0x1c(%eax),%eax
80101ccf:	89 45 ec             	mov    %eax,-0x14(%ebp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101cd2:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101cd5:	8b 45 08             	mov    0x8(%ebp),%eax
80101cd8:	8b 40 04             	mov    0x4(%eax),%eax
80101cdb:	c1 e8 03             	shr    $0x3,%eax
80101cde:	89 c1                	mov    %eax,%ecx
80101ce0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101ce3:	01 c8                	add    %ecx,%eax
80101ce5:	01 c2                	add    %eax,%edx
80101ce7:	8b 45 08             	mov    0x8(%ebp),%eax
80101cea:	8b 00                	mov    (%eax),%eax
80101cec:	83 ec 08             	sub    $0x8,%esp
80101cef:	52                   	push   %edx
80101cf0:	50                   	push   %eax
80101cf1:	e8 c0 e4 ff ff       	call   801001b6 <bread>
80101cf6:	83 c4 10             	add    $0x10,%esp
80101cf9:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum % IPB;
80101cfc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101cff:	8d 50 18             	lea    0x18(%eax),%edx
80101d02:	8b 45 08             	mov    0x8(%ebp),%eax
80101d05:	8b 40 04             	mov    0x4(%eax),%eax
80101d08:	83 e0 07             	and    $0x7,%eax
80101d0b:	c1 e0 06             	shl    $0x6,%eax
80101d0e:	01 d0                	add    %edx,%eax
80101d10:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip->type = ip->type;
80101d13:	8b 45 08             	mov    0x8(%ebp),%eax
80101d16:	0f b7 50 10          	movzwl 0x10(%eax),%edx
80101d1a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101d1d:	66 89 10             	mov    %dx,(%eax)
    dip->major = ip->major;
80101d20:	8b 45 08             	mov    0x8(%ebp),%eax
80101d23:	0f b7 50 12          	movzwl 0x12(%eax),%edx
80101d27:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101d2a:	66 89 50 02          	mov    %dx,0x2(%eax)
    dip->minor = ip->minor;
80101d2e:	8b 45 08             	mov    0x8(%ebp),%eax
80101d31:	0f b7 50 14          	movzwl 0x14(%eax),%edx
80101d35:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101d38:	66 89 50 04          	mov    %dx,0x4(%eax)
    dip->nlink = ip->nlink;
80101d3c:	8b 45 08             	mov    0x8(%ebp),%eax
80101d3f:	0f b7 50 16          	movzwl 0x16(%eax),%edx
80101d43:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101d46:	66 89 50 06          	mov    %dx,0x6(%eax)
    dip->size = ip->size;
80101d4a:	8b 45 08             	mov    0x8(%ebp),%eax
80101d4d:	8b 50 18             	mov    0x18(%eax),%edx
80101d50:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101d53:	89 50 08             	mov    %edx,0x8(%eax)
    memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
80101d56:	8b 45 08             	mov    0x8(%ebp),%eax
80101d59:	8d 50 1c             	lea    0x1c(%eax),%edx
80101d5c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101d5f:	83 c0 0c             	add    $0xc,%eax
80101d62:	83 ec 04             	sub    $0x4,%esp
80101d65:	6a 34                	push   $0x34
80101d67:	52                   	push   %edx
80101d68:	50                   	push   %eax
80101d69:	e8 38 41 00 00       	call   80105ea6 <memmove>
80101d6e:	83 c4 10             	add    $0x10,%esp
    log_write(bp,ip->part->number);
80101d71:	8b 45 08             	mov    0x8(%ebp),%eax
80101d74:	8b 40 50             	mov    0x50(%eax),%eax
80101d77:	8b 40 14             	mov    0x14(%eax),%eax
80101d7a:	83 ec 08             	sub    $0x8,%esp
80101d7d:	50                   	push   %eax
80101d7e:	ff 75 f4             	pushl  -0xc(%ebp)
80101d81:	e8 b7 24 00 00       	call   8010423d <log_write>
80101d86:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80101d89:	83 ec 0c             	sub    $0xc,%esp
80101d8c:	ff 75 f4             	pushl  -0xc(%ebp)
80101d8f:	e8 9a e4 ff ff       	call   8010022e <brelse>
80101d94:	83 c4 10             	add    $0x10,%esp
}
80101d97:	90                   	nop
80101d98:	c9                   	leave  
80101d99:	c3                   	ret    

80101d9a <iget>:

// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode* iget(uint dev, uint inum, uint partitionNumber)
{
80101d9a:	55                   	push   %ebp
80101d9b:	89 e5                	mov    %esp,%ebp
80101d9d:	83 ec 18             	sub    $0x18,%esp
    struct inode* ip, *empty;

    acquire(&icache.lock);
80101da0:	83 ec 0c             	sub    $0xc,%esp
80101da3:	68 60 24 11 80       	push   $0x80112460
80101da8:	e8 d7 3d 00 00       	call   80105b84 <acquire>
80101dad:	83 c4 10             	add    $0x10,%esp
    //cprintf("partnumber %d \n", partitionNumber);

    // Is the inode already cached?
    empty = 0;
80101db0:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for (ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++) {
80101db7:	c7 45 f4 94 24 11 80 	movl   $0x80112494,-0xc(%ebp)
80101dbe:	eb 78                	jmp    80101e38 <iget+0x9e>
        if (ip->ref > 0 && ip->dev == dev && ip->inum == inum && ip->part && ip->part->number == partitionNumber) {
80101dc0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101dc3:	8b 40 08             	mov    0x8(%eax),%eax
80101dc6:	85 c0                	test   %eax,%eax
80101dc8:	7e 54                	jle    80101e1e <iget+0x84>
80101dca:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101dcd:	8b 00                	mov    (%eax),%eax
80101dcf:	3b 45 08             	cmp    0x8(%ebp),%eax
80101dd2:	75 4a                	jne    80101e1e <iget+0x84>
80101dd4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101dd7:	8b 40 04             	mov    0x4(%eax),%eax
80101dda:	3b 45 0c             	cmp    0xc(%ebp),%eax
80101ddd:	75 3f                	jne    80101e1e <iget+0x84>
80101ddf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101de2:	8b 40 50             	mov    0x50(%eax),%eax
80101de5:	85 c0                	test   %eax,%eax
80101de7:	74 35                	je     80101e1e <iget+0x84>
80101de9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101dec:	8b 40 50             	mov    0x50(%eax),%eax
80101def:	8b 40 14             	mov    0x14(%eax),%eax
80101df2:	3b 45 10             	cmp    0x10(%ebp),%eax
80101df5:	75 27                	jne    80101e1e <iget+0x84>
            ip->ref++;
80101df7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101dfa:	8b 40 08             	mov    0x8(%eax),%eax
80101dfd:	8d 50 01             	lea    0x1(%eax),%edx
80101e00:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101e03:	89 50 08             	mov    %edx,0x8(%eax)
            release(&icache.lock);
80101e06:	83 ec 0c             	sub    $0xc,%esp
80101e09:	68 60 24 11 80       	push   $0x80112460
80101e0e:	e8 d8 3d 00 00       	call   80105beb <release>
80101e13:	83 c4 10             	add    $0x10,%esp
            return ip;
80101e16:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101e19:	e9 90 00 00 00       	jmp    80101eae <iget+0x114>
        }
        if (empty == 0 && ip->ref == 0) // Remember empty slot.
80101e1e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101e22:	75 10                	jne    80101e34 <iget+0x9a>
80101e24:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101e27:	8b 40 08             	mov    0x8(%eax),%eax
80101e2a:	85 c0                	test   %eax,%eax
80101e2c:	75 06                	jne    80101e34 <iget+0x9a>
            empty = ip;
80101e2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101e31:	89 45 f0             	mov    %eax,-0x10(%ebp)
    acquire(&icache.lock);
    //cprintf("partnumber %d \n", partitionNumber);

    // Is the inode already cached?
    empty = 0;
    for (ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++) {
80101e34:	83 45 f4 54          	addl   $0x54,-0xc(%ebp)
80101e38:	81 7d f4 fc 34 11 80 	cmpl   $0x801134fc,-0xc(%ebp)
80101e3f:	0f 82 7b ff ff ff    	jb     80101dc0 <iget+0x26>
        if (empty == 0 && ip->ref == 0) // Remember empty slot.
            empty = ip;
    }

    // Recycle an inode cache entry.
    if (empty == 0)
80101e45:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101e49:	75 0d                	jne    80101e58 <iget+0xbe>
        panic("iget: no inodes");
80101e4b:	83 ec 0c             	sub    $0xc,%esp
80101e4e:	68 6b 95 10 80       	push   $0x8010956b
80101e53:	e8 0e e7 ff ff       	call   80100566 <panic>

    ip = empty;
80101e58:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e5b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    ip->dev = dev;
80101e5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101e61:	8b 55 08             	mov    0x8(%ebp),%edx
80101e64:	89 10                	mov    %edx,(%eax)
    ip->inum = inum;
80101e66:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101e69:	8b 55 0c             	mov    0xc(%ebp),%edx
80101e6c:	89 50 04             	mov    %edx,0x4(%eax)
    ip->part = &(partitions[partitionNumber]);
80101e6f:	8b 55 10             	mov    0x10(%ebp),%edx
80101e72:	89 d0                	mov    %edx,%eax
80101e74:	01 c0                	add    %eax,%eax
80101e76:	01 d0                	add    %edx,%eax
80101e78:	c1 e0 03             	shl    $0x3,%eax
80101e7b:	8d 90 00 18 11 80    	lea    -0x7feee800(%eax),%edx
80101e81:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101e84:	89 50 50             	mov    %edx,0x50(%eax)
    ip->ref = 1;
80101e87:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101e8a:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
    ip->flags = 0;
80101e91:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101e94:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    release(&icache.lock);
80101e9b:	83 ec 0c             	sub    $0xc,%esp
80101e9e:	68 60 24 11 80       	push   $0x80112460
80101ea3:	e8 43 3d 00 00       	call   80105beb <release>
80101ea8:	83 c4 10             	add    $0x10,%esp

    return ip;
80101eab:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80101eae:	c9                   	leave  
80101eaf:	c3                   	ret    

80101eb0 <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode* idup(struct inode* ip)
{
80101eb0:	55                   	push   %ebp
80101eb1:	89 e5                	mov    %esp,%ebp
80101eb3:	83 ec 08             	sub    $0x8,%esp
             //   cprintf("idup \n");

    acquire(&icache.lock);
80101eb6:	83 ec 0c             	sub    $0xc,%esp
80101eb9:	68 60 24 11 80       	push   $0x80112460
80101ebe:	e8 c1 3c 00 00       	call   80105b84 <acquire>
80101ec3:	83 c4 10             	add    $0x10,%esp
    ip->ref++;
80101ec6:	8b 45 08             	mov    0x8(%ebp),%eax
80101ec9:	8b 40 08             	mov    0x8(%eax),%eax
80101ecc:	8d 50 01             	lea    0x1(%eax),%edx
80101ecf:	8b 45 08             	mov    0x8(%ebp),%eax
80101ed2:	89 50 08             	mov    %edx,0x8(%eax)
    release(&icache.lock);
80101ed5:	83 ec 0c             	sub    $0xc,%esp
80101ed8:	68 60 24 11 80       	push   $0x80112460
80101edd:	e8 09 3d 00 00       	call   80105beb <release>
80101ee2:	83 c4 10             	add    $0x10,%esp
    return ip;
80101ee5:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101ee8:	c9                   	leave  
80101ee9:	c3                   	ret    

80101eea <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void ilock(struct inode* ip)
{
80101eea:	55                   	push   %ebp
80101eeb:	89 e5                	mov    %esp,%ebp
80101eed:	83 ec 38             	sub    $0x38,%esp
    struct buf* bp;
    struct dinode* dip;
                 //   cprintf("ilock \n");

    if (ip == 0 || ip->ref < 1)
80101ef0:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101ef4:	74 0a                	je     80101f00 <ilock+0x16>
80101ef6:	8b 45 08             	mov    0x8(%ebp),%eax
80101ef9:	8b 40 08             	mov    0x8(%eax),%eax
80101efc:	85 c0                	test   %eax,%eax
80101efe:	7f 0d                	jg     80101f0d <ilock+0x23>
        panic("ilock");
80101f00:	83 ec 0c             	sub    $0xc,%esp
80101f03:	68 7b 95 10 80       	push   $0x8010957b
80101f08:	e8 59 e6 ff ff       	call   80100566 <panic>

    acquire(&icache.lock);
80101f0d:	83 ec 0c             	sub    $0xc,%esp
80101f10:	68 60 24 11 80       	push   $0x80112460
80101f15:	e8 6a 3c 00 00       	call   80105b84 <acquire>
80101f1a:	83 c4 10             	add    $0x10,%esp
    while (ip->flags & I_BUSY)
80101f1d:	eb 13                	jmp    80101f32 <ilock+0x48>
        sleep(ip, &icache.lock);
80101f1f:	83 ec 08             	sub    $0x8,%esp
80101f22:	68 60 24 11 80       	push   $0x80112460
80101f27:	ff 75 08             	pushl  0x8(%ebp)
80101f2a:	e8 5c 39 00 00       	call   8010588b <sleep>
80101f2f:	83 c4 10             	add    $0x10,%esp

    if (ip == 0 || ip->ref < 1)
        panic("ilock");

    acquire(&icache.lock);
    while (ip->flags & I_BUSY)
80101f32:	8b 45 08             	mov    0x8(%ebp),%eax
80101f35:	8b 40 0c             	mov    0xc(%eax),%eax
80101f38:	83 e0 01             	and    $0x1,%eax
80101f3b:	85 c0                	test   %eax,%eax
80101f3d:	75 e0                	jne    80101f1f <ilock+0x35>
        sleep(ip, &icache.lock);
    ip->flags |= I_BUSY;
80101f3f:	8b 45 08             	mov    0x8(%ebp),%eax
80101f42:	8b 40 0c             	mov    0xc(%eax),%eax
80101f45:	83 c8 01             	or     $0x1,%eax
80101f48:	89 c2                	mov    %eax,%edx
80101f4a:	8b 45 08             	mov    0x8(%ebp),%eax
80101f4d:	89 50 0c             	mov    %edx,0xc(%eax)
    release(&icache.lock);
80101f50:	83 ec 0c             	sub    $0xc,%esp
80101f53:	68 60 24 11 80       	push   $0x80112460
80101f58:	e8 8e 3c 00 00       	call   80105beb <release>
80101f5d:	83 c4 10             	add    $0x10,%esp

    if (!(ip->flags & I_VALID)) {
80101f60:	8b 45 08             	mov    0x8(%ebp),%eax
80101f63:	8b 40 0c             	mov    0xc(%eax),%eax
80101f66:	83 e0 02             	and    $0x2,%eax
80101f69:	85 c0                	test   %eax,%eax
80101f6b:	0f 85 17 01 00 00    	jne    80102088 <ilock+0x19e>
        struct superblock sb;
        sb = sbs[ip->part->number];
80101f71:	8b 45 08             	mov    0x8(%ebp),%eax
80101f74:	8b 40 50             	mov    0x50(%eax),%eax
80101f77:	8b 40 14             	mov    0x14(%eax),%eax
80101f7a:	c1 e0 05             	shl    $0x5,%eax
80101f7d:	05 60 d6 10 80       	add    $0x8010d660,%eax
80101f82:	8b 10                	mov    (%eax),%edx
80101f84:	89 55 d0             	mov    %edx,-0x30(%ebp)
80101f87:	8b 50 04             	mov    0x4(%eax),%edx
80101f8a:	89 55 d4             	mov    %edx,-0x2c(%ebp)
80101f8d:	8b 50 08             	mov    0x8(%eax),%edx
80101f90:	89 55 d8             	mov    %edx,-0x28(%ebp)
80101f93:	8b 50 0c             	mov    0xc(%eax),%edx
80101f96:	89 55 dc             	mov    %edx,-0x24(%ebp)
80101f99:	8b 50 10             	mov    0x10(%eax),%edx
80101f9c:	89 55 e0             	mov    %edx,-0x20(%ebp)
80101f9f:	8b 50 14             	mov    0x14(%eax),%edx
80101fa2:	89 55 e4             	mov    %edx,-0x1c(%ebp)
80101fa5:	8b 50 18             	mov    0x18(%eax),%edx
80101fa8:	89 55 e8             	mov    %edx,-0x18(%ebp)
80101fab:	8b 40 1c             	mov    0x1c(%eax),%eax
80101fae:	89 45 ec             	mov    %eax,-0x14(%ebp)
       // cprintf("inode inum %d , part Number %d \n",ip->inum,ip->part->number);
        bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101fb1:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101fb4:	8b 45 08             	mov    0x8(%ebp),%eax
80101fb7:	8b 40 04             	mov    0x4(%eax),%eax
80101fba:	c1 e8 03             	shr    $0x3,%eax
80101fbd:	89 c1                	mov    %eax,%ecx
80101fbf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101fc2:	01 c8                	add    %ecx,%eax
80101fc4:	01 c2                	add    %eax,%edx
80101fc6:	8b 45 08             	mov    0x8(%ebp),%eax
80101fc9:	8b 00                	mov    (%eax),%eax
80101fcb:	83 ec 08             	sub    $0x8,%esp
80101fce:	52                   	push   %edx
80101fcf:	50                   	push   %eax
80101fd0:	e8 e1 e1 ff ff       	call   801001b6 <bread>
80101fd5:	83 c4 10             	add    $0x10,%esp
80101fd8:	89 45 f4             	mov    %eax,-0xc(%ebp)
        dip = (struct dinode*)bp->data + ip->inum % IPB;
80101fdb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101fde:	8d 50 18             	lea    0x18(%eax),%edx
80101fe1:	8b 45 08             	mov    0x8(%ebp),%eax
80101fe4:	8b 40 04             	mov    0x4(%eax),%eax
80101fe7:	83 e0 07             	and    $0x7,%eax
80101fea:	c1 e0 06             	shl    $0x6,%eax
80101fed:	01 d0                	add    %edx,%eax
80101fef:	89 45 f0             	mov    %eax,-0x10(%ebp)
        ip->type = dip->type;
80101ff2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ff5:	0f b7 10             	movzwl (%eax),%edx
80101ff8:	8b 45 08             	mov    0x8(%ebp),%eax
80101ffb:	66 89 50 10          	mov    %dx,0x10(%eax)
        ip->major = dip->major;
80101fff:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102002:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80102006:	8b 45 08             	mov    0x8(%ebp),%eax
80102009:	66 89 50 12          	mov    %dx,0x12(%eax)
        ip->minor = dip->minor;
8010200d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102010:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80102014:	8b 45 08             	mov    0x8(%ebp),%eax
80102017:	66 89 50 14          	mov    %dx,0x14(%eax)
        ip->nlink = dip->nlink;
8010201b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010201e:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80102022:	8b 45 08             	mov    0x8(%ebp),%eax
80102025:	66 89 50 16          	mov    %dx,0x16(%eax)
        ip->size = dip->size;
80102029:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010202c:	8b 50 08             	mov    0x8(%eax),%edx
8010202f:	8b 45 08             	mov    0x8(%ebp),%eax
80102032:	89 50 18             	mov    %edx,0x18(%eax)
        memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80102035:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102038:	8d 50 0c             	lea    0xc(%eax),%edx
8010203b:	8b 45 08             	mov    0x8(%ebp),%eax
8010203e:	83 c0 1c             	add    $0x1c,%eax
80102041:	83 ec 04             	sub    $0x4,%esp
80102044:	6a 34                	push   $0x34
80102046:	52                   	push   %edx
80102047:	50                   	push   %eax
80102048:	e8 59 3e 00 00       	call   80105ea6 <memmove>
8010204d:	83 c4 10             	add    $0x10,%esp
        brelse(bp);
80102050:	83 ec 0c             	sub    $0xc,%esp
80102053:	ff 75 f4             	pushl  -0xc(%ebp)
80102056:	e8 d3 e1 ff ff       	call   8010022e <brelse>
8010205b:	83 c4 10             	add    $0x10,%esp
        ip->flags |= I_VALID;
8010205e:	8b 45 08             	mov    0x8(%ebp),%eax
80102061:	8b 40 0c             	mov    0xc(%eax),%eax
80102064:	83 c8 02             	or     $0x2,%eax
80102067:	89 c2                	mov    %eax,%edx
80102069:	8b 45 08             	mov    0x8(%ebp),%eax
8010206c:	89 50 0c             	mov    %edx,0xc(%eax)
        if (ip->type == 0)
8010206f:	8b 45 08             	mov    0x8(%ebp),%eax
80102072:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80102076:	66 85 c0             	test   %ax,%ax
80102079:	75 0d                	jne    80102088 <ilock+0x19e>
            panic("ilock: no type");
8010207b:	83 ec 0c             	sub    $0xc,%esp
8010207e:	68 81 95 10 80       	push   $0x80109581
80102083:	e8 de e4 ff ff       	call   80100566 <panic>
    }
}
80102088:	90                   	nop
80102089:	c9                   	leave  
8010208a:	c3                   	ret    

8010208b <iunlock>:

// Unlock the given inode.
void iunlock(struct inode* ip)
{
8010208b:	55                   	push   %ebp
8010208c:	89 e5                	mov    %esp,%ebp
8010208e:	83 ec 08             	sub    $0x8,%esp
                  //  cprintf("iunlock \n");

    if (ip == 0 || !(ip->flags & I_BUSY) || ip->ref < 1) {
80102091:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102095:	74 17                	je     801020ae <iunlock+0x23>
80102097:	8b 45 08             	mov    0x8(%ebp),%eax
8010209a:	8b 40 0c             	mov    0xc(%eax),%eax
8010209d:	83 e0 01             	and    $0x1,%eax
801020a0:	85 c0                	test   %eax,%eax
801020a2:	74 0a                	je     801020ae <iunlock+0x23>
801020a4:	8b 45 08             	mov    0x8(%ebp),%eax
801020a7:	8b 40 08             	mov    0x8(%eax),%eax
801020aa:	85 c0                	test   %eax,%eax
801020ac:	7f 0d                	jg     801020bb <iunlock+0x30>
        // cprintf("iunlock ilock%d ",ip);
        panic("iunlock");
801020ae:	83 ec 0c             	sub    $0xc,%esp
801020b1:	68 90 95 10 80       	push   $0x80109590
801020b6:	e8 ab e4 ff ff       	call   80100566 <panic>
    }

    acquire(&icache.lock);
801020bb:	83 ec 0c             	sub    $0xc,%esp
801020be:	68 60 24 11 80       	push   $0x80112460
801020c3:	e8 bc 3a 00 00       	call   80105b84 <acquire>
801020c8:	83 c4 10             	add    $0x10,%esp
    ip->flags &= ~I_BUSY;
801020cb:	8b 45 08             	mov    0x8(%ebp),%eax
801020ce:	8b 40 0c             	mov    0xc(%eax),%eax
801020d1:	83 e0 fe             	and    $0xfffffffe,%eax
801020d4:	89 c2                	mov    %eax,%edx
801020d6:	8b 45 08             	mov    0x8(%ebp),%eax
801020d9:	89 50 0c             	mov    %edx,0xc(%eax)
    wakeup(ip);
801020dc:	83 ec 0c             	sub    $0xc,%esp
801020df:	ff 75 08             	pushl  0x8(%ebp)
801020e2:	e8 8f 38 00 00       	call   80105976 <wakeup>
801020e7:	83 c4 10             	add    $0x10,%esp
    release(&icache.lock);
801020ea:	83 ec 0c             	sub    $0xc,%esp
801020ed:	68 60 24 11 80       	push   $0x80112460
801020f2:	e8 f4 3a 00 00       	call   80105beb <release>
801020f7:	83 c4 10             	add    $0x10,%esp
}
801020fa:	90                   	nop
801020fb:	c9                   	leave  
801020fc:	c3                   	ret    

801020fd <iput>:
// If that was the last reference and the inode has no links
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void iput(struct inode* ip)
{
801020fd:	55                   	push   %ebp
801020fe:	89 e5                	mov    %esp,%ebp
80102100:	83 ec 08             	sub    $0x8,%esp
                       // cprintf("iput  %d \n",ip->inum);

    acquire(&icache.lock);
80102103:	83 ec 0c             	sub    $0xc,%esp
80102106:	68 60 24 11 80       	push   $0x80112460
8010210b:	e8 74 3a 00 00       	call   80105b84 <acquire>
80102110:	83 c4 10             	add    $0x10,%esp
    if (ip->ref == 1 && (ip->flags & I_VALID) && ip->nlink == 0) {
80102113:	8b 45 08             	mov    0x8(%ebp),%eax
80102116:	8b 40 08             	mov    0x8(%eax),%eax
80102119:	83 f8 01             	cmp    $0x1,%eax
8010211c:	0f 85 a9 00 00 00    	jne    801021cb <iput+0xce>
80102122:	8b 45 08             	mov    0x8(%ebp),%eax
80102125:	8b 40 0c             	mov    0xc(%eax),%eax
80102128:	83 e0 02             	and    $0x2,%eax
8010212b:	85 c0                	test   %eax,%eax
8010212d:	0f 84 98 00 00 00    	je     801021cb <iput+0xce>
80102133:	8b 45 08             	mov    0x8(%ebp),%eax
80102136:	0f b7 40 16          	movzwl 0x16(%eax),%eax
8010213a:	66 85 c0             	test   %ax,%ax
8010213d:	0f 85 88 00 00 00    	jne    801021cb <iput+0xce>
        // inode has no links and no other references: truncate and free.
        if (ip->flags & I_BUSY)
80102143:	8b 45 08             	mov    0x8(%ebp),%eax
80102146:	8b 40 0c             	mov    0xc(%eax),%eax
80102149:	83 e0 01             	and    $0x1,%eax
8010214c:	85 c0                	test   %eax,%eax
8010214e:	74 0d                	je     8010215d <iput+0x60>
            panic("iput busy");
80102150:	83 ec 0c             	sub    $0xc,%esp
80102153:	68 98 95 10 80       	push   $0x80109598
80102158:	e8 09 e4 ff ff       	call   80100566 <panic>
        ip->flags |= I_BUSY;
8010215d:	8b 45 08             	mov    0x8(%ebp),%eax
80102160:	8b 40 0c             	mov    0xc(%eax),%eax
80102163:	83 c8 01             	or     $0x1,%eax
80102166:	89 c2                	mov    %eax,%edx
80102168:	8b 45 08             	mov    0x8(%ebp),%eax
8010216b:	89 50 0c             	mov    %edx,0xc(%eax)
        release(&icache.lock);
8010216e:	83 ec 0c             	sub    $0xc,%esp
80102171:	68 60 24 11 80       	push   $0x80112460
80102176:	e8 70 3a 00 00       	call   80105beb <release>
8010217b:	83 c4 10             	add    $0x10,%esp
        itrunc(ip);
8010217e:	83 ec 0c             	sub    $0xc,%esp
80102181:	ff 75 08             	pushl  0x8(%ebp)
80102184:	e8 1c 02 00 00       	call   801023a5 <itrunc>
80102189:	83 c4 10             	add    $0x10,%esp
        ip->type = 0;
8010218c:	8b 45 08             	mov    0x8(%ebp),%eax
8010218f:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)
        iupdate(ip);
80102195:	83 ec 0c             	sub    $0xc,%esp
80102198:	ff 75 08             	pushl  0x8(%ebp)
8010219b:	e8 ec fa ff ff       	call   80101c8c <iupdate>
801021a0:	83 c4 10             	add    $0x10,%esp
        acquire(&icache.lock);
801021a3:	83 ec 0c             	sub    $0xc,%esp
801021a6:	68 60 24 11 80       	push   $0x80112460
801021ab:	e8 d4 39 00 00       	call   80105b84 <acquire>
801021b0:	83 c4 10             	add    $0x10,%esp
        ip->flags = 0;
801021b3:	8b 45 08             	mov    0x8(%ebp),%eax
801021b6:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        wakeup(ip);
801021bd:	83 ec 0c             	sub    $0xc,%esp
801021c0:	ff 75 08             	pushl  0x8(%ebp)
801021c3:	e8 ae 37 00 00       	call   80105976 <wakeup>
801021c8:	83 c4 10             	add    $0x10,%esp
    }
    ip->ref--;
801021cb:	8b 45 08             	mov    0x8(%ebp),%eax
801021ce:	8b 40 08             	mov    0x8(%eax),%eax
801021d1:	8d 50 ff             	lea    -0x1(%eax),%edx
801021d4:	8b 45 08             	mov    0x8(%ebp),%eax
801021d7:	89 50 08             	mov    %edx,0x8(%eax)
    release(&icache.lock);
801021da:	83 ec 0c             	sub    $0xc,%esp
801021dd:	68 60 24 11 80       	push   $0x80112460
801021e2:	e8 04 3a 00 00       	call   80105beb <release>
801021e7:	83 c4 10             	add    $0x10,%esp
}
801021ea:	90                   	nop
801021eb:	c9                   	leave  
801021ec:	c3                   	ret    

801021ed <iunlockput>:

// Common idiom: unlock, then put.
void iunlockput(struct inode* ip)
{
801021ed:	55                   	push   %ebp
801021ee:	89 e5                	mov    %esp,%ebp
801021f0:	83 ec 08             	sub    $0x8,%esp
    iunlock(ip);
801021f3:	83 ec 0c             	sub    $0xc,%esp
801021f6:	ff 75 08             	pushl  0x8(%ebp)
801021f9:	e8 8d fe ff ff       	call   8010208b <iunlock>
801021fe:	83 c4 10             	add    $0x10,%esp
    iput(ip);
80102201:	83 ec 0c             	sub    $0xc,%esp
80102204:	ff 75 08             	pushl  0x8(%ebp)
80102207:	e8 f1 fe ff ff       	call   801020fd <iput>
8010220c:	83 c4 10             	add    $0x10,%esp
}
8010220f:	90                   	nop
80102210:	c9                   	leave  
80102211:	c3                   	ret    

80102212 <bmap>:
// listed in block ip->addrs[NDIRECT].

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint bmap(struct inode* ip, uint bn)
{
80102212:	55                   	push   %ebp
80102213:	89 e5                	mov    %esp,%ebp
80102215:	53                   	push   %ebx
80102216:	83 ec 34             	sub    $0x34,%esp
                       //     cprintf("ip %d , part number %d ,bmap %d \n",ip->inum,ip->part->number,bn);

    uint addr, *a;
    struct buf* bp;
struct superblock sb;
sb=sbs[ip->part->number];
80102219:	8b 45 08             	mov    0x8(%ebp),%eax
8010221c:	8b 40 50             	mov    0x50(%eax),%eax
8010221f:	8b 40 14             	mov    0x14(%eax),%eax
80102222:	c1 e0 05             	shl    $0x5,%eax
80102225:	05 60 d6 10 80       	add    $0x8010d660,%eax
8010222a:	8b 10                	mov    (%eax),%edx
8010222c:	89 55 cc             	mov    %edx,-0x34(%ebp)
8010222f:	8b 50 04             	mov    0x4(%eax),%edx
80102232:	89 55 d0             	mov    %edx,-0x30(%ebp)
80102235:	8b 50 08             	mov    0x8(%eax),%edx
80102238:	89 55 d4             	mov    %edx,-0x2c(%ebp)
8010223b:	8b 50 0c             	mov    0xc(%eax),%edx
8010223e:	89 55 d8             	mov    %edx,-0x28(%ebp)
80102241:	8b 50 10             	mov    0x10(%eax),%edx
80102244:	89 55 dc             	mov    %edx,-0x24(%ebp)
80102247:	8b 50 14             	mov    0x14(%eax),%edx
8010224a:	89 55 e0             	mov    %edx,-0x20(%ebp)
8010224d:	8b 50 18             	mov    0x18(%eax),%edx
80102250:	89 55 e4             	mov    %edx,-0x1c(%ebp)
80102253:	8b 40 1c             	mov    0x1c(%eax),%eax
80102256:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if (bn < NDIRECT) {
80102259:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
8010225d:	77 4e                	ja     801022ad <bmap+0x9b>
        if ((addr = ip->addrs[bn]) == 0)
8010225f:	8b 45 08             	mov    0x8(%ebp),%eax
80102262:	8b 55 0c             	mov    0xc(%ebp),%edx
80102265:	83 c2 04             	add    $0x4,%edx
80102268:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
8010226c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010226f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102273:	75 30                	jne    801022a5 <bmap+0x93>
            ip->addrs[bn] = addr = balloc(ip->dev, ip->part->number);
80102275:	8b 45 08             	mov    0x8(%ebp),%eax
80102278:	8b 40 50             	mov    0x50(%eax),%eax
8010227b:	8b 40 14             	mov    0x14(%eax),%eax
8010227e:	89 c2                	mov    %eax,%edx
80102280:	8b 45 08             	mov    0x8(%ebp),%eax
80102283:	8b 00                	mov    (%eax),%eax
80102285:	83 ec 08             	sub    $0x8,%esp
80102288:	52                   	push   %edx
80102289:	50                   	push   %eax
8010228a:	e8 b4 f2 ff ff       	call   80101543 <balloc>
8010228f:	83 c4 10             	add    $0x10,%esp
80102292:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102295:	8b 45 08             	mov    0x8(%ebp),%eax
80102298:	8b 55 0c             	mov    0xc(%ebp),%edx
8010229b:	8d 4a 04             	lea    0x4(%edx),%ecx
8010229e:	8b 55 f4             	mov    -0xc(%ebp),%edx
801022a1:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
       // cprintf("addr %d \n ",addr);
        return addr;
801022a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022a8:	e9 f3 00 00 00       	jmp    801023a0 <bmap+0x18e>
    }
    bn -= NDIRECT;
801022ad:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

    if (bn < NINDIRECT) {
801022b1:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
801022b5:	0f 87 d8 00 00 00    	ja     80102393 <bmap+0x181>
        // Load indirect block, allocating if necessary.
        if ((addr = ip->addrs[NDIRECT]) == 0)
801022bb:	8b 45 08             	mov    0x8(%ebp),%eax
801022be:	8b 40 4c             	mov    0x4c(%eax),%eax
801022c1:	89 45 f4             	mov    %eax,-0xc(%ebp)
801022c4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801022c8:	75 29                	jne    801022f3 <bmap+0xe1>
            ip->addrs[NDIRECT] = addr = balloc(ip->dev, ip->part->number);
801022ca:	8b 45 08             	mov    0x8(%ebp),%eax
801022cd:	8b 40 50             	mov    0x50(%eax),%eax
801022d0:	8b 40 14             	mov    0x14(%eax),%eax
801022d3:	89 c2                	mov    %eax,%edx
801022d5:	8b 45 08             	mov    0x8(%ebp),%eax
801022d8:	8b 00                	mov    (%eax),%eax
801022da:	83 ec 08             	sub    $0x8,%esp
801022dd:	52                   	push   %edx
801022de:	50                   	push   %eax
801022df:	e8 5f f2 ff ff       	call   80101543 <balloc>
801022e4:	83 c4 10             	add    $0x10,%esp
801022e7:	89 45 f4             	mov    %eax,-0xc(%ebp)
801022ea:	8b 45 08             	mov    0x8(%ebp),%eax
801022ed:	8b 55 f4             	mov    -0xc(%ebp),%edx
801022f0:	89 50 4c             	mov    %edx,0x4c(%eax)
        bp = bread(ip->dev, sb.offset+addr);
801022f3:	8b 55 e8             	mov    -0x18(%ebp),%edx
801022f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022f9:	01 c2                	add    %eax,%edx
801022fb:	8b 45 08             	mov    0x8(%ebp),%eax
801022fe:	8b 00                	mov    (%eax),%eax
80102300:	83 ec 08             	sub    $0x8,%esp
80102303:	52                   	push   %edx
80102304:	50                   	push   %eax
80102305:	e8 ac de ff ff       	call   801001b6 <bread>
8010230a:	83 c4 10             	add    $0x10,%esp
8010230d:	89 45 f0             	mov    %eax,-0x10(%ebp)
        a = (uint*)bp->data;
80102310:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102313:	83 c0 18             	add    $0x18,%eax
80102316:	89 45 ec             	mov    %eax,-0x14(%ebp)
        if ((addr = a[bn]) == 0) {
80102319:	8b 45 0c             	mov    0xc(%ebp),%eax
8010231c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80102323:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102326:	01 d0                	add    %edx,%eax
80102328:	8b 00                	mov    (%eax),%eax
8010232a:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010232d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102331:	75 4d                	jne    80102380 <bmap+0x16e>
            a[bn] = addr = balloc(ip->dev, ip->part->number);
80102333:	8b 45 0c             	mov    0xc(%ebp),%eax
80102336:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010233d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102340:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80102343:	8b 45 08             	mov    0x8(%ebp),%eax
80102346:	8b 40 50             	mov    0x50(%eax),%eax
80102349:	8b 40 14             	mov    0x14(%eax),%eax
8010234c:	89 c2                	mov    %eax,%edx
8010234e:	8b 45 08             	mov    0x8(%ebp),%eax
80102351:	8b 00                	mov    (%eax),%eax
80102353:	83 ec 08             	sub    $0x8,%esp
80102356:	52                   	push   %edx
80102357:	50                   	push   %eax
80102358:	e8 e6 f1 ff ff       	call   80101543 <balloc>
8010235d:	83 c4 10             	add    $0x10,%esp
80102360:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102363:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102366:	89 03                	mov    %eax,(%ebx)
            log_write(bp,ip->part->number);
80102368:	8b 45 08             	mov    0x8(%ebp),%eax
8010236b:	8b 40 50             	mov    0x50(%eax),%eax
8010236e:	8b 40 14             	mov    0x14(%eax),%eax
80102371:	83 ec 08             	sub    $0x8,%esp
80102374:	50                   	push   %eax
80102375:	ff 75 f0             	pushl  -0x10(%ebp)
80102378:	e8 c0 1e 00 00       	call   8010423d <log_write>
8010237d:	83 c4 10             	add    $0x10,%esp
        }
        brelse(bp);
80102380:	83 ec 0c             	sub    $0xc,%esp
80102383:	ff 75 f0             	pushl  -0x10(%ebp)
80102386:	e8 a3 de ff ff       	call   8010022e <brelse>
8010238b:	83 c4 10             	add    $0x10,%esp
        return addr;
8010238e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102391:	eb 0d                	jmp    801023a0 <bmap+0x18e>
    }

    panic("bmap: out of range");
80102393:	83 ec 0c             	sub    $0xc,%esp
80102396:	68 a2 95 10 80       	push   $0x801095a2
8010239b:	e8 c6 e1 ff ff       	call   80100566 <panic>
}
801023a0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801023a3:	c9                   	leave  
801023a4:	c3                   	ret    

801023a5 <itrunc>:
// Only called when the inode has no links
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void itrunc(struct inode* ip)
{
801023a5:	55                   	push   %ebp
801023a6:	89 e5                	mov    %esp,%ebp
801023a8:	83 ec 38             	sub    $0x38,%esp

    int i, j;
    struct buf* bp;
    uint* a;
    struct superblock sb;
    sb=sbs[ip->part->number];
801023ab:	8b 45 08             	mov    0x8(%ebp),%eax
801023ae:	8b 40 50             	mov    0x50(%eax),%eax
801023b1:	8b 40 14             	mov    0x14(%eax),%eax
801023b4:	c1 e0 05             	shl    $0x5,%eax
801023b7:	05 60 d6 10 80       	add    $0x8010d660,%eax
801023bc:	8b 10                	mov    (%eax),%edx
801023be:	89 55 c8             	mov    %edx,-0x38(%ebp)
801023c1:	8b 50 04             	mov    0x4(%eax),%edx
801023c4:	89 55 cc             	mov    %edx,-0x34(%ebp)
801023c7:	8b 50 08             	mov    0x8(%eax),%edx
801023ca:	89 55 d0             	mov    %edx,-0x30(%ebp)
801023cd:	8b 50 0c             	mov    0xc(%eax),%edx
801023d0:	89 55 d4             	mov    %edx,-0x2c(%ebp)
801023d3:	8b 50 10             	mov    0x10(%eax),%edx
801023d6:	89 55 d8             	mov    %edx,-0x28(%ebp)
801023d9:	8b 50 14             	mov    0x14(%eax),%edx
801023dc:	89 55 dc             	mov    %edx,-0x24(%ebp)
801023df:	8b 50 18             	mov    0x18(%eax),%edx
801023e2:	89 55 e0             	mov    %edx,-0x20(%ebp)
801023e5:	8b 40 1c             	mov    0x1c(%eax),%eax
801023e8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    for (i = 0; i < NDIRECT; i++) {
801023eb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801023f2:	eb 51                	jmp    80102445 <itrunc+0xa0>
        if (ip->addrs[i]) {
801023f4:	8b 45 08             	mov    0x8(%ebp),%eax
801023f7:	8b 55 f4             	mov    -0xc(%ebp),%edx
801023fa:	83 c2 04             	add    $0x4,%edx
801023fd:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80102401:	85 c0                	test   %eax,%eax
80102403:	74 3c                	je     80102441 <itrunc+0x9c>
            bfree(ip->dev, ip->addrs[i], ip->part->number);
80102405:	8b 45 08             	mov    0x8(%ebp),%eax
80102408:	8b 40 50             	mov    0x50(%eax),%eax
8010240b:	8b 40 14             	mov    0x14(%eax),%eax
8010240e:	89 c1                	mov    %eax,%ecx
80102410:	8b 45 08             	mov    0x8(%ebp),%eax
80102413:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102416:	83 c2 04             	add    $0x4,%edx
80102419:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
8010241d:	8b 55 08             	mov    0x8(%ebp),%edx
80102420:	8b 12                	mov    (%edx),%edx
80102422:	83 ec 04             	sub    $0x4,%esp
80102425:	51                   	push   %ecx
80102426:	50                   	push   %eax
80102427:	52                   	push   %edx
80102428:	e8 a9 f2 ff ff       	call   801016d6 <bfree>
8010242d:	83 c4 10             	add    $0x10,%esp
            ip->addrs[i] = 0;
80102430:	8b 45 08             	mov    0x8(%ebp),%eax
80102433:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102436:	83 c2 04             	add    $0x4,%edx
80102439:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80102440:	00 
    int i, j;
    struct buf* bp;
    uint* a;
    struct superblock sb;
    sb=sbs[ip->part->number];
    for (i = 0; i < NDIRECT; i++) {
80102441:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102445:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80102449:	7e a9                	jle    801023f4 <itrunc+0x4f>
            bfree(ip->dev, ip->addrs[i], ip->part->number);
            ip->addrs[i] = 0;
        }
    }

    if (ip->addrs[NDIRECT]) {
8010244b:	8b 45 08             	mov    0x8(%ebp),%eax
8010244e:	8b 40 4c             	mov    0x4c(%eax),%eax
80102451:	85 c0                	test   %eax,%eax
80102453:	0f 84 be 00 00 00    	je     80102517 <itrunc+0x172>
        bp = bread(ip->dev, sb.offset+ip->addrs[NDIRECT]);
80102459:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010245c:	8b 45 08             	mov    0x8(%ebp),%eax
8010245f:	8b 40 4c             	mov    0x4c(%eax),%eax
80102462:	01 c2                	add    %eax,%edx
80102464:	8b 45 08             	mov    0x8(%ebp),%eax
80102467:	8b 00                	mov    (%eax),%eax
80102469:	83 ec 08             	sub    $0x8,%esp
8010246c:	52                   	push   %edx
8010246d:	50                   	push   %eax
8010246e:	e8 43 dd ff ff       	call   801001b6 <bread>
80102473:	83 c4 10             	add    $0x10,%esp
80102476:	89 45 ec             	mov    %eax,-0x14(%ebp)
        a = (uint*)bp->data;
80102479:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010247c:	83 c0 18             	add    $0x18,%eax
8010247f:	89 45 e8             	mov    %eax,-0x18(%ebp)
        for (j = 0; j < NINDIRECT; j++) {
80102482:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80102489:	eb 48                	jmp    801024d3 <itrunc+0x12e>
            if (a[j])
8010248b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010248e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80102495:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102498:	01 d0                	add    %edx,%eax
8010249a:	8b 00                	mov    (%eax),%eax
8010249c:	85 c0                	test   %eax,%eax
8010249e:	74 2f                	je     801024cf <itrunc+0x12a>
                bfree(ip->dev, a[j], ip->part->number);
801024a0:	8b 45 08             	mov    0x8(%ebp),%eax
801024a3:	8b 40 50             	mov    0x50(%eax),%eax
801024a6:	8b 40 14             	mov    0x14(%eax),%eax
801024a9:	89 c1                	mov    %eax,%ecx
801024ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
801024ae:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801024b5:	8b 45 e8             	mov    -0x18(%ebp),%eax
801024b8:	01 d0                	add    %edx,%eax
801024ba:	8b 00                	mov    (%eax),%eax
801024bc:	8b 55 08             	mov    0x8(%ebp),%edx
801024bf:	8b 12                	mov    (%edx),%edx
801024c1:	83 ec 04             	sub    $0x4,%esp
801024c4:	51                   	push   %ecx
801024c5:	50                   	push   %eax
801024c6:	52                   	push   %edx
801024c7:	e8 0a f2 ff ff       	call   801016d6 <bfree>
801024cc:	83 c4 10             	add    $0x10,%esp
    }

    if (ip->addrs[NDIRECT]) {
        bp = bread(ip->dev, sb.offset+ip->addrs[NDIRECT]);
        a = (uint*)bp->data;
        for (j = 0; j < NINDIRECT; j++) {
801024cf:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801024d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801024d6:	83 f8 7f             	cmp    $0x7f,%eax
801024d9:	76 b0                	jbe    8010248b <itrunc+0xe6>
            if (a[j])
                bfree(ip->dev, a[j], ip->part->number);
        }
        brelse(bp);
801024db:	83 ec 0c             	sub    $0xc,%esp
801024de:	ff 75 ec             	pushl  -0x14(%ebp)
801024e1:	e8 48 dd ff ff       	call   8010022e <brelse>
801024e6:	83 c4 10             	add    $0x10,%esp
        bfree(ip->dev, ip->addrs[NDIRECT], ip->part->number);
801024e9:	8b 45 08             	mov    0x8(%ebp),%eax
801024ec:	8b 40 50             	mov    0x50(%eax),%eax
801024ef:	8b 40 14             	mov    0x14(%eax),%eax
801024f2:	89 c1                	mov    %eax,%ecx
801024f4:	8b 45 08             	mov    0x8(%ebp),%eax
801024f7:	8b 40 4c             	mov    0x4c(%eax),%eax
801024fa:	8b 55 08             	mov    0x8(%ebp),%edx
801024fd:	8b 12                	mov    (%edx),%edx
801024ff:	83 ec 04             	sub    $0x4,%esp
80102502:	51                   	push   %ecx
80102503:	50                   	push   %eax
80102504:	52                   	push   %edx
80102505:	e8 cc f1 ff ff       	call   801016d6 <bfree>
8010250a:	83 c4 10             	add    $0x10,%esp
        ip->addrs[NDIRECT] = 0;
8010250d:	8b 45 08             	mov    0x8(%ebp),%eax
80102510:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
    }

    ip->size = 0;
80102517:	8b 45 08             	mov    0x8(%ebp),%eax
8010251a:	c7 40 18 00 00 00 00 	movl   $0x0,0x18(%eax)
    iupdate(ip);
80102521:	83 ec 0c             	sub    $0xc,%esp
80102524:	ff 75 08             	pushl  0x8(%ebp)
80102527:	e8 60 f7 ff ff       	call   80101c8c <iupdate>
8010252c:	83 c4 10             	add    $0x10,%esp
}
8010252f:	90                   	nop
80102530:	c9                   	leave  
80102531:	c3                   	ret    

80102532 <stati>:

// Copy stat information from inode.
void stati(struct inode* ip, struct stat* st)
{
80102532:	55                   	push   %ebp
80102533:	89 e5                	mov    %esp,%ebp
    st->dev = ip->dev;
80102535:	8b 45 08             	mov    0x8(%ebp),%eax
80102538:	8b 00                	mov    (%eax),%eax
8010253a:	89 c2                	mov    %eax,%edx
8010253c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010253f:	89 50 04             	mov    %edx,0x4(%eax)
    st->ino = ip->inum;
80102542:	8b 45 08             	mov    0x8(%ebp),%eax
80102545:	8b 50 04             	mov    0x4(%eax),%edx
80102548:	8b 45 0c             	mov    0xc(%ebp),%eax
8010254b:	89 50 08             	mov    %edx,0x8(%eax)
    st->type = ip->type;
8010254e:	8b 45 08             	mov    0x8(%ebp),%eax
80102551:	0f b7 50 10          	movzwl 0x10(%eax),%edx
80102555:	8b 45 0c             	mov    0xc(%ebp),%eax
80102558:	66 89 10             	mov    %dx,(%eax)
    st->nlink = ip->nlink;
8010255b:	8b 45 08             	mov    0x8(%ebp),%eax
8010255e:	0f b7 50 16          	movzwl 0x16(%eax),%edx
80102562:	8b 45 0c             	mov    0xc(%ebp),%eax
80102565:	66 89 50 0c          	mov    %dx,0xc(%eax)
    st->size = ip->size;
80102569:	8b 45 08             	mov    0x8(%ebp),%eax
8010256c:	8b 50 18             	mov    0x18(%eax),%edx
8010256f:	8b 45 0c             	mov    0xc(%ebp),%eax
80102572:	89 50 10             	mov    %edx,0x10(%eax)
}
80102575:	90                   	nop
80102576:	5d                   	pop    %ebp
80102577:	c3                   	ret    

80102578 <readi>:

// PAGEBREAK!
// Read data from inode.
int readi(struct inode* ip, char* dst, uint off, uint n)
{
80102578:	55                   	push   %ebp
80102579:	89 e5                	mov    %esp,%ebp
8010257b:	83 ec 38             	sub    $0x38,%esp
    uint tot, m;
    struct buf* bp;
    struct superblock sb;
                      //      cprintf("readi \n");
    sb=sbs[ip->part->number];
8010257e:	8b 45 08             	mov    0x8(%ebp),%eax
80102581:	8b 40 50             	mov    0x50(%eax),%eax
80102584:	8b 40 14             	mov    0x14(%eax),%eax
80102587:	c1 e0 05             	shl    $0x5,%eax
8010258a:	05 60 d6 10 80       	add    $0x8010d660,%eax
8010258f:	8b 10                	mov    (%eax),%edx
80102591:	89 55 c8             	mov    %edx,-0x38(%ebp)
80102594:	8b 50 04             	mov    0x4(%eax),%edx
80102597:	89 55 cc             	mov    %edx,-0x34(%ebp)
8010259a:	8b 50 08             	mov    0x8(%eax),%edx
8010259d:	89 55 d0             	mov    %edx,-0x30(%ebp)
801025a0:	8b 50 0c             	mov    0xc(%eax),%edx
801025a3:	89 55 d4             	mov    %edx,-0x2c(%ebp)
801025a6:	8b 50 10             	mov    0x10(%eax),%edx
801025a9:	89 55 d8             	mov    %edx,-0x28(%ebp)
801025ac:	8b 50 14             	mov    0x14(%eax),%edx
801025af:	89 55 dc             	mov    %edx,-0x24(%ebp)
801025b2:	8b 50 18             	mov    0x18(%eax),%edx
801025b5:	89 55 e0             	mov    %edx,-0x20(%ebp)
801025b8:	8b 40 1c             	mov    0x1c(%eax),%eax
801025bb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if (ip->type == T_DEV) {
801025be:	8b 45 08             	mov    0x8(%ebp),%eax
801025c1:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801025c5:	66 83 f8 03          	cmp    $0x3,%ax
801025c9:	75 5c                	jne    80102627 <readi+0xaf>
        if (ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
801025cb:	8b 45 08             	mov    0x8(%ebp),%eax
801025ce:	0f b7 40 12          	movzwl 0x12(%eax),%eax
801025d2:	66 85 c0             	test   %ax,%ax
801025d5:	78 20                	js     801025f7 <readi+0x7f>
801025d7:	8b 45 08             	mov    0x8(%ebp),%eax
801025da:	0f b7 40 12          	movzwl 0x12(%eax),%eax
801025de:	66 83 f8 09          	cmp    $0x9,%ax
801025e2:	7f 13                	jg     801025f7 <readi+0x7f>
801025e4:	8b 45 08             	mov    0x8(%ebp),%eax
801025e7:	0f b7 40 12          	movzwl 0x12(%eax),%eax
801025eb:	98                   	cwtl   
801025ec:	8b 04 c5 e0 21 11 80 	mov    -0x7feede20(,%eax,8),%eax
801025f3:	85 c0                	test   %eax,%eax
801025f5:	75 0a                	jne    80102601 <readi+0x89>
            return -1;
801025f7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801025fc:	e9 15 01 00 00       	jmp    80102716 <readi+0x19e>
        return devsw[ip->major].read(ip, dst, n);
80102601:	8b 45 08             	mov    0x8(%ebp),%eax
80102604:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102608:	98                   	cwtl   
80102609:	8b 04 c5 e0 21 11 80 	mov    -0x7feede20(,%eax,8),%eax
80102610:	8b 55 14             	mov    0x14(%ebp),%edx
80102613:	83 ec 04             	sub    $0x4,%esp
80102616:	52                   	push   %edx
80102617:	ff 75 0c             	pushl  0xc(%ebp)
8010261a:	ff 75 08             	pushl  0x8(%ebp)
8010261d:	ff d0                	call   *%eax
8010261f:	83 c4 10             	add    $0x10,%esp
80102622:	e9 ef 00 00 00       	jmp    80102716 <readi+0x19e>
    }

    if (off > ip->size || off + n < off)
80102627:	8b 45 08             	mov    0x8(%ebp),%eax
8010262a:	8b 40 18             	mov    0x18(%eax),%eax
8010262d:	3b 45 10             	cmp    0x10(%ebp),%eax
80102630:	72 0d                	jb     8010263f <readi+0xc7>
80102632:	8b 55 10             	mov    0x10(%ebp),%edx
80102635:	8b 45 14             	mov    0x14(%ebp),%eax
80102638:	01 d0                	add    %edx,%eax
8010263a:	3b 45 10             	cmp    0x10(%ebp),%eax
8010263d:	73 0a                	jae    80102649 <readi+0xd1>
        return -1;
8010263f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102644:	e9 cd 00 00 00       	jmp    80102716 <readi+0x19e>
    if (off + n > ip->size)
80102649:	8b 55 10             	mov    0x10(%ebp),%edx
8010264c:	8b 45 14             	mov    0x14(%ebp),%eax
8010264f:	01 c2                	add    %eax,%edx
80102651:	8b 45 08             	mov    0x8(%ebp),%eax
80102654:	8b 40 18             	mov    0x18(%eax),%eax
80102657:	39 c2                	cmp    %eax,%edx
80102659:	76 0c                	jbe    80102667 <readi+0xef>
        n = ip->size - off;
8010265b:	8b 45 08             	mov    0x8(%ebp),%eax
8010265e:	8b 40 18             	mov    0x18(%eax),%eax
80102661:	2b 45 10             	sub    0x10(%ebp),%eax
80102664:	89 45 14             	mov    %eax,0x14(%ebp)

    for (tot = 0; tot < n; tot += m, off += m, dst += m) {
80102667:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010266e:	e9 94 00 00 00       	jmp    80102707 <readi+0x18f>
        uint bmapOut=bmap(ip, off / BSIZE);
80102673:	8b 45 10             	mov    0x10(%ebp),%eax
80102676:	c1 e8 09             	shr    $0x9,%eax
80102679:	83 ec 08             	sub    $0x8,%esp
8010267c:	50                   	push   %eax
8010267d:	ff 75 08             	pushl  0x8(%ebp)
80102680:	e8 8d fb ff ff       	call   80102212 <bmap>
80102685:	83 c4 10             	add    $0x10,%esp
80102688:	89 45 f0             	mov    %eax,-0x10(%ebp)
       // cprintf("bout %d \n",bmapOut);
        bp = bread(ip->dev, sb.offset+bmapOut);
8010268b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010268e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102691:	01 c2                	add    %eax,%edx
80102693:	8b 45 08             	mov    0x8(%ebp),%eax
80102696:	8b 00                	mov    (%eax),%eax
80102698:	83 ec 08             	sub    $0x8,%esp
8010269b:	52                   	push   %edx
8010269c:	50                   	push   %eax
8010269d:	e8 14 db ff ff       	call   801001b6 <bread>
801026a2:	83 c4 10             	add    $0x10,%esp
801026a5:	89 45 ec             	mov    %eax,-0x14(%ebp)
        m = min(n - tot, BSIZE - off % BSIZE);
801026a8:	8b 45 10             	mov    0x10(%ebp),%eax
801026ab:	25 ff 01 00 00       	and    $0x1ff,%eax
801026b0:	ba 00 02 00 00       	mov    $0x200,%edx
801026b5:	29 c2                	sub    %eax,%edx
801026b7:	8b 45 14             	mov    0x14(%ebp),%eax
801026ba:	2b 45 f4             	sub    -0xc(%ebp),%eax
801026bd:	39 c2                	cmp    %eax,%edx
801026bf:	0f 46 c2             	cmovbe %edx,%eax
801026c2:	89 45 e8             	mov    %eax,-0x18(%ebp)
        memmove(dst, bp->data + off % BSIZE, m);
801026c5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801026c8:	8d 50 18             	lea    0x18(%eax),%edx
801026cb:	8b 45 10             	mov    0x10(%ebp),%eax
801026ce:	25 ff 01 00 00       	and    $0x1ff,%eax
801026d3:	01 d0                	add    %edx,%eax
801026d5:	83 ec 04             	sub    $0x4,%esp
801026d8:	ff 75 e8             	pushl  -0x18(%ebp)
801026db:	50                   	push   %eax
801026dc:	ff 75 0c             	pushl  0xc(%ebp)
801026df:	e8 c2 37 00 00       	call   80105ea6 <memmove>
801026e4:	83 c4 10             	add    $0x10,%esp
        brelse(bp);
801026e7:	83 ec 0c             	sub    $0xc,%esp
801026ea:	ff 75 ec             	pushl  -0x14(%ebp)
801026ed:	e8 3c db ff ff       	call   8010022e <brelse>
801026f2:	83 c4 10             	add    $0x10,%esp
    if (off > ip->size || off + n < off)
        return -1;
    if (off + n > ip->size)
        n = ip->size - off;

    for (tot = 0; tot < n; tot += m, off += m, dst += m) {
801026f5:	8b 45 e8             	mov    -0x18(%ebp),%eax
801026f8:	01 45 f4             	add    %eax,-0xc(%ebp)
801026fb:	8b 45 e8             	mov    -0x18(%ebp),%eax
801026fe:	01 45 10             	add    %eax,0x10(%ebp)
80102701:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102704:	01 45 0c             	add    %eax,0xc(%ebp)
80102707:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010270a:	3b 45 14             	cmp    0x14(%ebp),%eax
8010270d:	0f 82 60 ff ff ff    	jb     80102673 <readi+0xfb>
        bp = bread(ip->dev, sb.offset+bmapOut);
        m = min(n - tot, BSIZE - off % BSIZE);
        memmove(dst, bp->data + off % BSIZE, m);
        brelse(bp);
    }
    return n;
80102713:	8b 45 14             	mov    0x14(%ebp),%eax
}
80102716:	c9                   	leave  
80102717:	c3                   	ret    

80102718 <writei>:

// PAGEBREAK!
// Write data to inode.
int writei(struct inode* ip, char* src, uint off, uint n)
{
80102718:	55                   	push   %ebp
80102719:	89 e5                	mov    %esp,%ebp
8010271b:	83 ec 38             	sub    $0x38,%esp
                               // cprintf("writei \n");

    uint tot, m;
    struct buf* bp;
    struct superblock sb;
        sb=sbs[ip->part->number];
8010271e:	8b 45 08             	mov    0x8(%ebp),%eax
80102721:	8b 40 50             	mov    0x50(%eax),%eax
80102724:	8b 40 14             	mov    0x14(%eax),%eax
80102727:	c1 e0 05             	shl    $0x5,%eax
8010272a:	05 60 d6 10 80       	add    $0x8010d660,%eax
8010272f:	8b 10                	mov    (%eax),%edx
80102731:	89 55 c8             	mov    %edx,-0x38(%ebp)
80102734:	8b 50 04             	mov    0x4(%eax),%edx
80102737:	89 55 cc             	mov    %edx,-0x34(%ebp)
8010273a:	8b 50 08             	mov    0x8(%eax),%edx
8010273d:	89 55 d0             	mov    %edx,-0x30(%ebp)
80102740:	8b 50 0c             	mov    0xc(%eax),%edx
80102743:	89 55 d4             	mov    %edx,-0x2c(%ebp)
80102746:	8b 50 10             	mov    0x10(%eax),%edx
80102749:	89 55 d8             	mov    %edx,-0x28(%ebp)
8010274c:	8b 50 14             	mov    0x14(%eax),%edx
8010274f:	89 55 dc             	mov    %edx,-0x24(%ebp)
80102752:	8b 50 18             	mov    0x18(%eax),%edx
80102755:	89 55 e0             	mov    %edx,-0x20(%ebp)
80102758:	8b 40 1c             	mov    0x1c(%eax),%eax
8010275b:	89 45 e4             	mov    %eax,-0x1c(%ebp)


    if (ip->type == T_DEV) {
8010275e:	8b 45 08             	mov    0x8(%ebp),%eax
80102761:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80102765:	66 83 f8 03          	cmp    $0x3,%ax
80102769:	75 5c                	jne    801027c7 <writei+0xaf>
        if (ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
8010276b:	8b 45 08             	mov    0x8(%ebp),%eax
8010276e:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102772:	66 85 c0             	test   %ax,%ax
80102775:	78 20                	js     80102797 <writei+0x7f>
80102777:	8b 45 08             	mov    0x8(%ebp),%eax
8010277a:	0f b7 40 12          	movzwl 0x12(%eax),%eax
8010277e:	66 83 f8 09          	cmp    $0x9,%ax
80102782:	7f 13                	jg     80102797 <writei+0x7f>
80102784:	8b 45 08             	mov    0x8(%ebp),%eax
80102787:	0f b7 40 12          	movzwl 0x12(%eax),%eax
8010278b:	98                   	cwtl   
8010278c:	8b 04 c5 e4 21 11 80 	mov    -0x7feede1c(,%eax,8),%eax
80102793:	85 c0                	test   %eax,%eax
80102795:	75 0a                	jne    801027a1 <writei+0x89>
            return -1;
80102797:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010279c:	e9 50 01 00 00       	jmp    801028f1 <writei+0x1d9>
        return devsw[ip->major].write(ip, src, n);
801027a1:	8b 45 08             	mov    0x8(%ebp),%eax
801027a4:	0f b7 40 12          	movzwl 0x12(%eax),%eax
801027a8:	98                   	cwtl   
801027a9:	8b 04 c5 e4 21 11 80 	mov    -0x7feede1c(,%eax,8),%eax
801027b0:	8b 55 14             	mov    0x14(%ebp),%edx
801027b3:	83 ec 04             	sub    $0x4,%esp
801027b6:	52                   	push   %edx
801027b7:	ff 75 0c             	pushl  0xc(%ebp)
801027ba:	ff 75 08             	pushl  0x8(%ebp)
801027bd:	ff d0                	call   *%eax
801027bf:	83 c4 10             	add    $0x10,%esp
801027c2:	e9 2a 01 00 00       	jmp    801028f1 <writei+0x1d9>
    }

    if (off > ip->size || off + n < off)
801027c7:	8b 45 08             	mov    0x8(%ebp),%eax
801027ca:	8b 40 18             	mov    0x18(%eax),%eax
801027cd:	3b 45 10             	cmp    0x10(%ebp),%eax
801027d0:	72 0d                	jb     801027df <writei+0xc7>
801027d2:	8b 55 10             	mov    0x10(%ebp),%edx
801027d5:	8b 45 14             	mov    0x14(%ebp),%eax
801027d8:	01 d0                	add    %edx,%eax
801027da:	3b 45 10             	cmp    0x10(%ebp),%eax
801027dd:	73 0a                	jae    801027e9 <writei+0xd1>
        return -1;
801027df:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801027e4:	e9 08 01 00 00       	jmp    801028f1 <writei+0x1d9>
    if (off + n > MAXFILE * BSIZE)
801027e9:	8b 55 10             	mov    0x10(%ebp),%edx
801027ec:	8b 45 14             	mov    0x14(%ebp),%eax
801027ef:	01 d0                	add    %edx,%eax
801027f1:	3d 00 18 01 00       	cmp    $0x11800,%eax
801027f6:	76 0a                	jbe    80102802 <writei+0xea>
        return -1;
801027f8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801027fd:	e9 ef 00 00 00       	jmp    801028f1 <writei+0x1d9>

    for (tot = 0; tot < n; tot += m, off += m, src += m) {
80102802:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102809:	e9 ac 00 00 00       	jmp    801028ba <writei+0x1a2>
        uint bmapOut=bmap(ip, off / BSIZE);
8010280e:	8b 45 10             	mov    0x10(%ebp),%eax
80102811:	c1 e8 09             	shr    $0x9,%eax
80102814:	83 ec 08             	sub    $0x8,%esp
80102817:	50                   	push   %eax
80102818:	ff 75 08             	pushl  0x8(%ebp)
8010281b:	e8 f2 f9 ff ff       	call   80102212 <bmap>
80102820:	83 c4 10             	add    $0x10,%esp
80102823:	89 45 f0             	mov    %eax,-0x10(%ebp)
        bp = bread(ip->dev, sb.offset+bmapOut);
80102826:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80102829:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010282c:	01 c2                	add    %eax,%edx
8010282e:	8b 45 08             	mov    0x8(%ebp),%eax
80102831:	8b 00                	mov    (%eax),%eax
80102833:	83 ec 08             	sub    $0x8,%esp
80102836:	52                   	push   %edx
80102837:	50                   	push   %eax
80102838:	e8 79 d9 ff ff       	call   801001b6 <bread>
8010283d:	83 c4 10             	add    $0x10,%esp
80102840:	89 45 ec             	mov    %eax,-0x14(%ebp)
        m = min(n - tot, BSIZE - off % BSIZE);
80102843:	8b 45 10             	mov    0x10(%ebp),%eax
80102846:	25 ff 01 00 00       	and    $0x1ff,%eax
8010284b:	ba 00 02 00 00       	mov    $0x200,%edx
80102850:	29 c2                	sub    %eax,%edx
80102852:	8b 45 14             	mov    0x14(%ebp),%eax
80102855:	2b 45 f4             	sub    -0xc(%ebp),%eax
80102858:	39 c2                	cmp    %eax,%edx
8010285a:	0f 46 c2             	cmovbe %edx,%eax
8010285d:	89 45 e8             	mov    %eax,-0x18(%ebp)
        memmove(bp->data + off % BSIZE, src, m);
80102860:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102863:	8d 50 18             	lea    0x18(%eax),%edx
80102866:	8b 45 10             	mov    0x10(%ebp),%eax
80102869:	25 ff 01 00 00       	and    $0x1ff,%eax
8010286e:	01 d0                	add    %edx,%eax
80102870:	83 ec 04             	sub    $0x4,%esp
80102873:	ff 75 e8             	pushl  -0x18(%ebp)
80102876:	ff 75 0c             	pushl  0xc(%ebp)
80102879:	50                   	push   %eax
8010287a:	e8 27 36 00 00       	call   80105ea6 <memmove>
8010287f:	83 c4 10             	add    $0x10,%esp
        log_write(bp,ip->part->number);
80102882:	8b 45 08             	mov    0x8(%ebp),%eax
80102885:	8b 40 50             	mov    0x50(%eax),%eax
80102888:	8b 40 14             	mov    0x14(%eax),%eax
8010288b:	83 ec 08             	sub    $0x8,%esp
8010288e:	50                   	push   %eax
8010288f:	ff 75 ec             	pushl  -0x14(%ebp)
80102892:	e8 a6 19 00 00       	call   8010423d <log_write>
80102897:	83 c4 10             	add    $0x10,%esp
        brelse(bp);
8010289a:	83 ec 0c             	sub    $0xc,%esp
8010289d:	ff 75 ec             	pushl  -0x14(%ebp)
801028a0:	e8 89 d9 ff ff       	call   8010022e <brelse>
801028a5:	83 c4 10             	add    $0x10,%esp
    if (off > ip->size || off + n < off)
        return -1;
    if (off + n > MAXFILE * BSIZE)
        return -1;

    for (tot = 0; tot < n; tot += m, off += m, src += m) {
801028a8:	8b 45 e8             	mov    -0x18(%ebp),%eax
801028ab:	01 45 f4             	add    %eax,-0xc(%ebp)
801028ae:	8b 45 e8             	mov    -0x18(%ebp),%eax
801028b1:	01 45 10             	add    %eax,0x10(%ebp)
801028b4:	8b 45 e8             	mov    -0x18(%ebp),%eax
801028b7:	01 45 0c             	add    %eax,0xc(%ebp)
801028ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028bd:	3b 45 14             	cmp    0x14(%ebp),%eax
801028c0:	0f 82 48 ff ff ff    	jb     8010280e <writei+0xf6>
        memmove(bp->data + off % BSIZE, src, m);
        log_write(bp,ip->part->number);
        brelse(bp);
    }

    if (n > 0 && off > ip->size) {
801028c6:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
801028ca:	74 22                	je     801028ee <writei+0x1d6>
801028cc:	8b 45 08             	mov    0x8(%ebp),%eax
801028cf:	8b 40 18             	mov    0x18(%eax),%eax
801028d2:	3b 45 10             	cmp    0x10(%ebp),%eax
801028d5:	73 17                	jae    801028ee <writei+0x1d6>
        ip->size = off;
801028d7:	8b 45 08             	mov    0x8(%ebp),%eax
801028da:	8b 55 10             	mov    0x10(%ebp),%edx
801028dd:	89 50 18             	mov    %edx,0x18(%eax)
        iupdate(ip);
801028e0:	83 ec 0c             	sub    $0xc,%esp
801028e3:	ff 75 08             	pushl  0x8(%ebp)
801028e6:	e8 a1 f3 ff ff       	call   80101c8c <iupdate>
801028eb:	83 c4 10             	add    $0x10,%esp
    }
    return n;
801028ee:	8b 45 14             	mov    0x14(%ebp),%eax
}
801028f1:	c9                   	leave  
801028f2:	c3                   	ret    

801028f3 <namecmp>:

// PAGEBREAK!
// Directories

int namecmp(const char* s, const char* t)
{
801028f3:	55                   	push   %ebp
801028f4:	89 e5                	mov    %esp,%ebp
801028f6:	83 ec 08             	sub    $0x8,%esp
    return strncmp(s, t, DIRSIZ);
801028f9:	83 ec 04             	sub    $0x4,%esp
801028fc:	6a 0e                	push   $0xe
801028fe:	ff 75 0c             	pushl  0xc(%ebp)
80102901:	ff 75 08             	pushl  0x8(%ebp)
80102904:	e8 33 36 00 00       	call   80105f3c <strncmp>
80102909:	83 c4 10             	add    $0x10,%esp
}
8010290c:	c9                   	leave  
8010290d:	c3                   	ret    

8010290e <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode* dirlookup(struct inode* dp, char* name, uint* poff)
{
8010290e:	55                   	push   %ebp
8010290f:	89 e5                	mov    %esp,%ebp
80102911:	83 ec 28             	sub    $0x28,%esp
                             //       cprintf("dirlookup \n");

    uint off, inum;
    struct dirent de;

    if (dp->type != T_DIR)
80102914:	8b 45 08             	mov    0x8(%ebp),%eax
80102917:	0f b7 40 10          	movzwl 0x10(%eax),%eax
8010291b:	66 83 f8 01          	cmp    $0x1,%ax
8010291f:	74 0d                	je     8010292e <dirlookup+0x20>
        panic("dirlookup not DIR");
80102921:	83 ec 0c             	sub    $0xc,%esp
80102924:	68 b5 95 10 80       	push   $0x801095b5
80102929:	e8 38 dc ff ff       	call   80100566 <panic>

    for (off = 0; off < dp->size; off += sizeof(de)) {
8010292e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102935:	e9 85 00 00 00       	jmp    801029bf <dirlookup+0xb1>
        if (readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010293a:	6a 10                	push   $0x10
8010293c:	ff 75 f4             	pushl  -0xc(%ebp)
8010293f:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102942:	50                   	push   %eax
80102943:	ff 75 08             	pushl  0x8(%ebp)
80102946:	e8 2d fc ff ff       	call   80102578 <readi>
8010294b:	83 c4 10             	add    $0x10,%esp
8010294e:	83 f8 10             	cmp    $0x10,%eax
80102951:	74 0d                	je     80102960 <dirlookup+0x52>
            panic("dirlink read");
80102953:	83 ec 0c             	sub    $0xc,%esp
80102956:	68 c7 95 10 80       	push   $0x801095c7
8010295b:	e8 06 dc ff ff       	call   80100566 <panic>
        if (de.inum == 0)
80102960:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102964:	66 85 c0             	test   %ax,%ax
80102967:	74 51                	je     801029ba <dirlookup+0xac>
            continue;
        if (namecmp(name, de.name) == 0) {
80102969:	83 ec 08             	sub    $0x8,%esp
8010296c:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010296f:	83 c0 02             	add    $0x2,%eax
80102972:	50                   	push   %eax
80102973:	ff 75 0c             	pushl  0xc(%ebp)
80102976:	e8 78 ff ff ff       	call   801028f3 <namecmp>
8010297b:	83 c4 10             	add    $0x10,%esp
8010297e:	85 c0                	test   %eax,%eax
80102980:	75 39                	jne    801029bb <dirlookup+0xad>
            // entry matches path element
            if (poff)
80102982:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80102986:	74 08                	je     80102990 <dirlookup+0x82>
                *poff = off;
80102988:	8b 45 10             	mov    0x10(%ebp),%eax
8010298b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010298e:	89 10                	mov    %edx,(%eax)
            inum = de.inum;
80102990:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102994:	0f b7 c0             	movzwl %ax,%eax
80102997:	89 45 f0             	mov    %eax,-0x10(%ebp)
            return iget(dp->dev, inum, dp->part->number);
8010299a:	8b 45 08             	mov    0x8(%ebp),%eax
8010299d:	8b 40 50             	mov    0x50(%eax),%eax
801029a0:	8b 50 14             	mov    0x14(%eax),%edx
801029a3:	8b 45 08             	mov    0x8(%ebp),%eax
801029a6:	8b 00                	mov    (%eax),%eax
801029a8:	83 ec 04             	sub    $0x4,%esp
801029ab:	52                   	push   %edx
801029ac:	ff 75 f0             	pushl  -0x10(%ebp)
801029af:	50                   	push   %eax
801029b0:	e8 e5 f3 ff ff       	call   80101d9a <iget>
801029b5:	83 c4 10             	add    $0x10,%esp
801029b8:	eb 19                	jmp    801029d3 <dirlookup+0xc5>

    for (off = 0; off < dp->size; off += sizeof(de)) {
        if (readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
            panic("dirlink read");
        if (de.inum == 0)
            continue;
801029ba:	90                   	nop
    struct dirent de;

    if (dp->type != T_DIR)
        panic("dirlookup not DIR");

    for (off = 0; off < dp->size; off += sizeof(de)) {
801029bb:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
801029bf:	8b 45 08             	mov    0x8(%ebp),%eax
801029c2:	8b 40 18             	mov    0x18(%eax),%eax
801029c5:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801029c8:	0f 87 6c ff ff ff    	ja     8010293a <dirlookup+0x2c>
            inum = de.inum;
            return iget(dp->dev, inum, dp->part->number);
        }
    }

    return 0;
801029ce:	b8 00 00 00 00       	mov    $0x0,%eax
}
801029d3:	c9                   	leave  
801029d4:	c3                   	ret    

801029d5 <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int dirlink(struct inode* dp, char* name, uint inum)
{
801029d5:	55                   	push   %ebp
801029d6:	89 e5                	mov    %esp,%ebp
801029d8:	83 ec 28             	sub    $0x28,%esp
    int off;
    struct dirent de;
    struct inode* ip;

    // Check that name is not present.
    if ((ip = dirlookup(dp, name, 0)) != 0) {
801029db:	83 ec 04             	sub    $0x4,%esp
801029de:	6a 00                	push   $0x0
801029e0:	ff 75 0c             	pushl  0xc(%ebp)
801029e3:	ff 75 08             	pushl  0x8(%ebp)
801029e6:	e8 23 ff ff ff       	call   8010290e <dirlookup>
801029eb:	83 c4 10             	add    $0x10,%esp
801029ee:	89 45 f0             	mov    %eax,-0x10(%ebp)
801029f1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801029f5:	74 18                	je     80102a0f <dirlink+0x3a>
        iput(ip);
801029f7:	83 ec 0c             	sub    $0xc,%esp
801029fa:	ff 75 f0             	pushl  -0x10(%ebp)
801029fd:	e8 fb f6 ff ff       	call   801020fd <iput>
80102a02:	83 c4 10             	add    $0x10,%esp
        return -1;
80102a05:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102a0a:	e9 9c 00 00 00       	jmp    80102aab <dirlink+0xd6>
    }

    // Look for an empty dirent.
    for (off = 0; off < dp->size; off += sizeof(de)) {
80102a0f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102a16:	eb 39                	jmp    80102a51 <dirlink+0x7c>
        if (readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102a18:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a1b:	6a 10                	push   $0x10
80102a1d:	50                   	push   %eax
80102a1e:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102a21:	50                   	push   %eax
80102a22:	ff 75 08             	pushl  0x8(%ebp)
80102a25:	e8 4e fb ff ff       	call   80102578 <readi>
80102a2a:	83 c4 10             	add    $0x10,%esp
80102a2d:	83 f8 10             	cmp    $0x10,%eax
80102a30:	74 0d                	je     80102a3f <dirlink+0x6a>
            panic("dirlink read");
80102a32:	83 ec 0c             	sub    $0xc,%esp
80102a35:	68 c7 95 10 80       	push   $0x801095c7
80102a3a:	e8 27 db ff ff       	call   80100566 <panic>
        if (de.inum == 0)
80102a3f:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102a43:	66 85 c0             	test   %ax,%ax
80102a46:	74 18                	je     80102a60 <dirlink+0x8b>
        iput(ip);
        return -1;
    }

    // Look for an empty dirent.
    for (off = 0; off < dp->size; off += sizeof(de)) {
80102a48:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a4b:	83 c0 10             	add    $0x10,%eax
80102a4e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102a51:	8b 45 08             	mov    0x8(%ebp),%eax
80102a54:	8b 50 18             	mov    0x18(%eax),%edx
80102a57:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a5a:	39 c2                	cmp    %eax,%edx
80102a5c:	77 ba                	ja     80102a18 <dirlink+0x43>
80102a5e:	eb 01                	jmp    80102a61 <dirlink+0x8c>
        if (readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
            panic("dirlink read");
        if (de.inum == 0)
            break;
80102a60:	90                   	nop
    }

    strncpy(de.name, name, DIRSIZ);
80102a61:	83 ec 04             	sub    $0x4,%esp
80102a64:	6a 0e                	push   $0xe
80102a66:	ff 75 0c             	pushl  0xc(%ebp)
80102a69:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102a6c:	83 c0 02             	add    $0x2,%eax
80102a6f:	50                   	push   %eax
80102a70:	e8 1d 35 00 00       	call   80105f92 <strncpy>
80102a75:	83 c4 10             	add    $0x10,%esp
    de.inum = inum;
80102a78:	8b 45 10             	mov    0x10(%ebp),%eax
80102a7b:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
    if (writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102a7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a82:	6a 10                	push   $0x10
80102a84:	50                   	push   %eax
80102a85:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102a88:	50                   	push   %eax
80102a89:	ff 75 08             	pushl  0x8(%ebp)
80102a8c:	e8 87 fc ff ff       	call   80102718 <writei>
80102a91:	83 c4 10             	add    $0x10,%esp
80102a94:	83 f8 10             	cmp    $0x10,%eax
80102a97:	74 0d                	je     80102aa6 <dirlink+0xd1>
        panic("dirlink");
80102a99:	83 ec 0c             	sub    $0xc,%esp
80102a9c:	68 d4 95 10 80       	push   $0x801095d4
80102aa1:	e8 c0 da ff ff       	call   80100566 <panic>

    return 0;
80102aa6:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102aab:	c9                   	leave  
80102aac:	c3                   	ret    

80102aad <skipelem>:
//   skipelem("///a//bb", name) = "bb", setting name = "a"
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char* skipelem(char* path, char* name)
{
80102aad:	55                   	push   %ebp
80102aae:	89 e5                	mov    %esp,%ebp
80102ab0:	83 ec 18             	sub    $0x18,%esp
    
    char* s;
    int len;

    while (*path == '/')
80102ab3:	eb 04                	jmp    80102ab9 <skipelem+0xc>
        path++;
80102ab5:	83 45 08 01          	addl   $0x1,0x8(%ebp)
{
    
    char* s;
    int len;

    while (*path == '/')
80102ab9:	8b 45 08             	mov    0x8(%ebp),%eax
80102abc:	0f b6 00             	movzbl (%eax),%eax
80102abf:	3c 2f                	cmp    $0x2f,%al
80102ac1:	74 f2                	je     80102ab5 <skipelem+0x8>
        path++;
    if (*path == 0)
80102ac3:	8b 45 08             	mov    0x8(%ebp),%eax
80102ac6:	0f b6 00             	movzbl (%eax),%eax
80102ac9:	84 c0                	test   %al,%al
80102acb:	75 07                	jne    80102ad4 <skipelem+0x27>
        return 0;
80102acd:	b8 00 00 00 00       	mov    $0x0,%eax
80102ad2:	eb 7b                	jmp    80102b4f <skipelem+0xa2>
    s = path;
80102ad4:	8b 45 08             	mov    0x8(%ebp),%eax
80102ad7:	89 45 f4             	mov    %eax,-0xc(%ebp)
    while (*path != '/' && *path != 0)
80102ada:	eb 04                	jmp    80102ae0 <skipelem+0x33>
        path++;
80102adc:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    while (*path == '/')
        path++;
    if (*path == 0)
        return 0;
    s = path;
    while (*path != '/' && *path != 0)
80102ae0:	8b 45 08             	mov    0x8(%ebp),%eax
80102ae3:	0f b6 00             	movzbl (%eax),%eax
80102ae6:	3c 2f                	cmp    $0x2f,%al
80102ae8:	74 0a                	je     80102af4 <skipelem+0x47>
80102aea:	8b 45 08             	mov    0x8(%ebp),%eax
80102aed:	0f b6 00             	movzbl (%eax),%eax
80102af0:	84 c0                	test   %al,%al
80102af2:	75 e8                	jne    80102adc <skipelem+0x2f>
        path++;
    len = path - s;
80102af4:	8b 55 08             	mov    0x8(%ebp),%edx
80102af7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102afa:	29 c2                	sub    %eax,%edx
80102afc:	89 d0                	mov    %edx,%eax
80102afe:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (len >= DIRSIZ)
80102b01:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
80102b05:	7e 15                	jle    80102b1c <skipelem+0x6f>
        memmove(name, s, DIRSIZ);
80102b07:	83 ec 04             	sub    $0x4,%esp
80102b0a:	6a 0e                	push   $0xe
80102b0c:	ff 75 f4             	pushl  -0xc(%ebp)
80102b0f:	ff 75 0c             	pushl  0xc(%ebp)
80102b12:	e8 8f 33 00 00       	call   80105ea6 <memmove>
80102b17:	83 c4 10             	add    $0x10,%esp
80102b1a:	eb 26                	jmp    80102b42 <skipelem+0x95>
    else {
        memmove(name, s, len);
80102b1c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102b1f:	83 ec 04             	sub    $0x4,%esp
80102b22:	50                   	push   %eax
80102b23:	ff 75 f4             	pushl  -0xc(%ebp)
80102b26:	ff 75 0c             	pushl  0xc(%ebp)
80102b29:	e8 78 33 00 00       	call   80105ea6 <memmove>
80102b2e:	83 c4 10             	add    $0x10,%esp
        name[len] = 0;
80102b31:	8b 55 f0             	mov    -0x10(%ebp),%edx
80102b34:	8b 45 0c             	mov    0xc(%ebp),%eax
80102b37:	01 d0                	add    %edx,%eax
80102b39:	c6 00 00             	movb   $0x0,(%eax)
    }
    while (*path == '/')
80102b3c:	eb 04                	jmp    80102b42 <skipelem+0x95>
        path++;
80102b3e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
        memmove(name, s, DIRSIZ);
    else {
        memmove(name, s, len);
        name[len] = 0;
    }
    while (*path == '/')
80102b42:	8b 45 08             	mov    0x8(%ebp),%eax
80102b45:	0f b6 00             	movzbl (%eax),%eax
80102b48:	3c 2f                	cmp    $0x2f,%al
80102b4a:	74 f2                	je     80102b3e <skipelem+0x91>
        path++;
    return path;
80102b4c:	8b 45 08             	mov    0x8(%ebp),%eax
}
80102b4f:	c9                   	leave  
80102b50:	c3                   	ret    

80102b51 <namex>:
// Look up and return the inode for a path name.
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode* namex(char* path, int nameiparent, int ignoreMounts,char* name)
{
80102b51:	55                   	push   %ebp
80102b52:	89 e5                	mov    %esp,%ebp
80102b54:	83 ec 18             	sub    $0x18,%esp
                                           // cprintf("namex \n");

    struct inode* ip, *next;
     // cprintf("path %s nameparent %d , name %s bootfrom %d\n", path, nameiparent, name, bootfrom);
    if (*path == '/')
80102b57:	8b 45 08             	mov    0x8(%ebp),%eax
80102b5a:	0f b6 00             	movzbl (%eax),%eax
80102b5d:	3c 2f                	cmp    $0x2f,%al
80102b5f:	75 1d                	jne    80102b7e <namex+0x2d>
        ip = iget(ROOTDEV, ROOTINO, bootfrom);
80102b61:	a1 18 a0 10 80       	mov    0x8010a018,%eax
80102b66:	83 ec 04             	sub    $0x4,%esp
80102b69:	50                   	push   %eax
80102b6a:	6a 01                	push   $0x1
80102b6c:	6a 00                	push   $0x0
80102b6e:	e8 27 f2 ff ff       	call   80101d9a <iget>
80102b73:	83 c4 10             	add    $0x10,%esp
80102b76:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102b79:	e9 3f 01 00 00       	jmp    80102cbd <namex+0x16c>
    else
        ip = idup(proc->cwd);
80102b7e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80102b84:	8b 40 68             	mov    0x68(%eax),%eax
80102b87:	83 ec 0c             	sub    $0xc,%esp
80102b8a:	50                   	push   %eax
80102b8b:	e8 20 f3 ff ff       	call   80101eb0 <idup>
80102b90:	83 c4 10             	add    $0x10,%esp
80102b93:	89 45 f4             	mov    %eax,-0xc(%ebp)

    while ((path = skipelem(path, name)) != 0) {
80102b96:	e9 22 01 00 00       	jmp    80102cbd <namex+0x16c>
      //  cprintf("namex inode %d,part number %d \n",ip->inum,ip->part->number);
        ilock(ip);
80102b9b:	83 ec 0c             	sub    $0xc,%esp
80102b9e:	ff 75 f4             	pushl  -0xc(%ebp)
80102ba1:	e8 44 f3 ff ff       	call   80101eea <ilock>
80102ba6:	83 c4 10             	add    $0x10,%esp
        if (ip->type != T_DIR) {
80102ba9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102bac:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80102bb0:	66 83 f8 01          	cmp    $0x1,%ax
80102bb4:	74 18                	je     80102bce <namex+0x7d>
            iunlockput(ip);
80102bb6:	83 ec 0c             	sub    $0xc,%esp
80102bb9:	ff 75 f4             	pushl  -0xc(%ebp)
80102bbc:	e8 2c f6 ff ff       	call   801021ed <iunlockput>
80102bc1:	83 c4 10             	add    $0x10,%esp
            return 0;
80102bc4:	b8 00 00 00 00       	mov    $0x0,%eax
80102bc9:	e9 2b 01 00 00       	jmp    80102cf9 <namex+0x1a8>
        }
        if (nameiparent && *path == '\0') {
80102bce:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102bd2:	74 20                	je     80102bf4 <namex+0xa3>
80102bd4:	8b 45 08             	mov    0x8(%ebp),%eax
80102bd7:	0f b6 00             	movzbl (%eax),%eax
80102bda:	84 c0                	test   %al,%al
80102bdc:	75 16                	jne    80102bf4 <namex+0xa3>
            // Stop one level early.
            //  cprintf("fileread \n");

            iunlock(ip);
80102bde:	83 ec 0c             	sub    $0xc,%esp
80102be1:	ff 75 f4             	pushl  -0xc(%ebp)
80102be4:	e8 a2 f4 ff ff       	call   8010208b <iunlock>
80102be9:	83 c4 10             	add    $0x10,%esp
            return ip;
80102bec:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102bef:	e9 05 01 00 00       	jmp    80102cf9 <namex+0x1a8>
        }
        if ((next = dirlookup(ip, name, 0)) == 0) {
80102bf4:	83 ec 04             	sub    $0x4,%esp
80102bf7:	6a 00                	push   $0x0
80102bf9:	ff 75 14             	pushl  0x14(%ebp)
80102bfc:	ff 75 f4             	pushl  -0xc(%ebp)
80102bff:	e8 0a fd ff ff       	call   8010290e <dirlookup>
80102c04:	83 c4 10             	add    $0x10,%esp
80102c07:	89 45 f0             	mov    %eax,-0x10(%ebp)
80102c0a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102c0e:	75 18                	jne    80102c28 <namex+0xd7>
            iunlockput(ip);
80102c10:	83 ec 0c             	sub    $0xc,%esp
80102c13:	ff 75 f4             	pushl  -0xc(%ebp)
80102c16:	e8 d2 f5 ff ff       	call   801021ed <iunlockput>
80102c1b:	83 c4 10             	add    $0x10,%esp
            return 0;
80102c1e:	b8 00 00 00 00       	mov    $0x0,%eax
80102c23:	e9 d1 00 00 00       	jmp    80102cf9 <namex+0x1a8>
        }
        iunlockput(ip);
80102c28:	83 ec 0c             	sub    $0xc,%esp
80102c2b:	ff 75 f4             	pushl  -0xc(%ebp)
80102c2e:	e8 ba f5 ff ff       	call   801021ed <iunlockput>
80102c33:	83 c4 10             	add    $0x10,%esp
        //testing 
        if(!ignoreMounts&&next->type==T_DIR&&next->major!=0 && next->major!=MOUNTING_POINT){
80102c36:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80102c3a:	75 36                	jne    80102c72 <namex+0x121>
80102c3c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102c3f:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80102c43:	66 83 f8 01          	cmp    $0x1,%ax
80102c47:	75 29                	jne    80102c72 <namex+0x121>
80102c49:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102c4c:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102c50:	66 85 c0             	test   %ax,%ax
80102c53:	74 1d                	je     80102c72 <namex+0x121>
80102c55:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102c58:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102c5c:	66 83 f8 01          	cmp    $0x1,%ax
80102c60:	74 10                	je     80102c72 <namex+0x121>
            cprintf("major used ,we are fucked \n");
80102c62:	83 ec 0c             	sub    $0xc,%esp
80102c65:	68 dc 95 10 80       	push   $0x801095dc
80102c6a:	e8 57 d7 ff ff       	call   801003c6 <cprintf>
80102c6f:	83 c4 10             	add    $0x10,%esp
        }
        //handle mounting points
        if(!ignoreMounts&&!nameiparent&&next->type==T_DIR&&next->major==MOUNTING_POINT){
80102c72:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80102c76:	75 3f                	jne    80102cb7 <namex+0x166>
80102c78:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102c7c:	75 39                	jne    80102cb7 <namex+0x166>
80102c7e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102c81:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80102c85:	66 83 f8 01          	cmp    $0x1,%ax
80102c89:	75 2c                	jne    80102cb7 <namex+0x166>
80102c8b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102c8e:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102c92:	66 83 f8 01          	cmp    $0x1,%ax
80102c96:	75 1f                	jne    80102cb7 <namex+0x166>
            
            
            uint partitionNumnber=next->minor;
80102c98:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102c9b:	0f b7 40 14          	movzwl 0x14(%eax),%eax
80102c9f:	98                   	cwtl   
80102ca0:	89 45 ec             	mov    %eax,-0x14(%ebp)
            return iget(ROOTDEV,1,partitionNumnber);
80102ca3:	83 ec 04             	sub    $0x4,%esp
80102ca6:	ff 75 ec             	pushl  -0x14(%ebp)
80102ca9:	6a 01                	push   $0x1
80102cab:	6a 00                	push   $0x0
80102cad:	e8 e8 f0 ff ff       	call   80101d9a <iget>
80102cb2:	83 c4 10             	add    $0x10,%esp
80102cb5:	eb 42                	jmp    80102cf9 <namex+0x1a8>
        }
        ip = next;
80102cb7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102cba:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (*path == '/')
        ip = iget(ROOTDEV, ROOTINO, bootfrom);
    else
        ip = idup(proc->cwd);

    while ((path = skipelem(path, name)) != 0) {
80102cbd:	83 ec 08             	sub    $0x8,%esp
80102cc0:	ff 75 14             	pushl  0x14(%ebp)
80102cc3:	ff 75 08             	pushl  0x8(%ebp)
80102cc6:	e8 e2 fd ff ff       	call   80102aad <skipelem>
80102ccb:	83 c4 10             	add    $0x10,%esp
80102cce:	89 45 08             	mov    %eax,0x8(%ebp)
80102cd1:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102cd5:	0f 85 c0 fe ff ff    	jne    80102b9b <namex+0x4a>
            uint partitionNumnber=next->minor;
            return iget(ROOTDEV,1,partitionNumnber);
        }
        ip = next;
    }
    if (nameiparent) {
80102cdb:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102cdf:	74 15                	je     80102cf6 <namex+0x1a5>
        iput(ip);
80102ce1:	83 ec 0c             	sub    $0xc,%esp
80102ce4:	ff 75 f4             	pushl  -0xc(%ebp)
80102ce7:	e8 11 f4 ff ff       	call   801020fd <iput>
80102cec:	83 c4 10             	add    $0x10,%esp
        return 0;
80102cef:	b8 00 00 00 00       	mov    $0x0,%eax
80102cf4:	eb 03                	jmp    80102cf9 <namex+0x1a8>
    }
    // cprintf("ip returned is %d \n", ip->inum);
    return ip;
80102cf6:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102cf9:	c9                   	leave  
80102cfa:	c3                   	ret    

80102cfb <namei>:



struct inode* namei(char* path)
{
80102cfb:	55                   	push   %ebp
80102cfc:	89 e5                	mov    %esp,%ebp
80102cfe:	83 ec 18             	sub    $0x18,%esp
    char name[DIRSIZ];
    return namex(path, 0, 0,name);
80102d01:	8d 45 ea             	lea    -0x16(%ebp),%eax
80102d04:	50                   	push   %eax
80102d05:	6a 00                	push   $0x0
80102d07:	6a 00                	push   $0x0
80102d09:	ff 75 08             	pushl  0x8(%ebp)
80102d0c:	e8 40 fe ff ff       	call   80102b51 <namex>
80102d11:	83 c4 10             	add    $0x10,%esp
}
80102d14:	c9                   	leave  
80102d15:	c3                   	ret    

80102d16 <nameiIgnoreMounts>:

struct inode* nameiIgnoreMounts(char* path)
{
80102d16:	55                   	push   %ebp
80102d17:	89 e5                	mov    %esp,%ebp
80102d19:	83 ec 18             	sub    $0x18,%esp
    char name[DIRSIZ];
    return namex(path, 0, 1,name);
80102d1c:	8d 45 ea             	lea    -0x16(%ebp),%eax
80102d1f:	50                   	push   %eax
80102d20:	6a 01                	push   $0x1
80102d22:	6a 00                	push   $0x0
80102d24:	ff 75 08             	pushl  0x8(%ebp)
80102d27:	e8 25 fe ff ff       	call   80102b51 <namex>
80102d2c:	83 c4 10             	add    $0x10,%esp
}
80102d2f:	c9                   	leave  
80102d30:	c3                   	ret    

80102d31 <nameiparent>:

struct inode* nameiparent(char* path, char* name)
{
80102d31:	55                   	push   %ebp
80102d32:	89 e5                	mov    %esp,%ebp
80102d34:	83 ec 08             	sub    $0x8,%esp
    return namex(path, 1, 0,name);
80102d37:	ff 75 0c             	pushl  0xc(%ebp)
80102d3a:	6a 00                	push   $0x0
80102d3c:	6a 01                	push   $0x1
80102d3e:	ff 75 08             	pushl  0x8(%ebp)
80102d41:	e8 0b fe ff ff       	call   80102b51 <namex>
80102d46:	83 c4 10             	add    $0x10,%esp
}
80102d49:	c9                   	leave  
80102d4a:	c3                   	ret    

80102d4b <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102d4b:	55                   	push   %ebp
80102d4c:	89 e5                	mov    %esp,%ebp
80102d4e:	83 ec 14             	sub    $0x14,%esp
80102d51:	8b 45 08             	mov    0x8(%ebp),%eax
80102d54:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102d58:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102d5c:	89 c2                	mov    %eax,%edx
80102d5e:	ec                   	in     (%dx),%al
80102d5f:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102d62:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102d66:	c9                   	leave  
80102d67:	c3                   	ret    

80102d68 <insl>:

static inline void
insl(int port, void *addr, int cnt)
{
80102d68:	55                   	push   %ebp
80102d69:	89 e5                	mov    %esp,%ebp
80102d6b:	57                   	push   %edi
80102d6c:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
80102d6d:	8b 55 08             	mov    0x8(%ebp),%edx
80102d70:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102d73:	8b 45 10             	mov    0x10(%ebp),%eax
80102d76:	89 cb                	mov    %ecx,%ebx
80102d78:	89 df                	mov    %ebx,%edi
80102d7a:	89 c1                	mov    %eax,%ecx
80102d7c:	fc                   	cld    
80102d7d:	f3 6d                	rep insl (%dx),%es:(%edi)
80102d7f:	89 c8                	mov    %ecx,%eax
80102d81:	89 fb                	mov    %edi,%ebx
80102d83:	89 5d 0c             	mov    %ebx,0xc(%ebp)
80102d86:	89 45 10             	mov    %eax,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "memory", "cc");
}
80102d89:	90                   	nop
80102d8a:	5b                   	pop    %ebx
80102d8b:	5f                   	pop    %edi
80102d8c:	5d                   	pop    %ebp
80102d8d:	c3                   	ret    

80102d8e <outb>:

static inline void
outb(ushort port, uchar data)
{
80102d8e:	55                   	push   %ebp
80102d8f:	89 e5                	mov    %esp,%ebp
80102d91:	83 ec 08             	sub    $0x8,%esp
80102d94:	8b 55 08             	mov    0x8(%ebp),%edx
80102d97:	8b 45 0c             	mov    0xc(%ebp),%eax
80102d9a:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80102d9e:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102da1:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102da5:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102da9:	ee                   	out    %al,(%dx)
}
80102daa:	90                   	nop
80102dab:	c9                   	leave  
80102dac:	c3                   	ret    

80102dad <outsl>:
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
}

static inline void
outsl(int port, const void *addr, int cnt)
{
80102dad:	55                   	push   %ebp
80102dae:	89 e5                	mov    %esp,%ebp
80102db0:	56                   	push   %esi
80102db1:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
80102db2:	8b 55 08             	mov    0x8(%ebp),%edx
80102db5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102db8:	8b 45 10             	mov    0x10(%ebp),%eax
80102dbb:	89 cb                	mov    %ecx,%ebx
80102dbd:	89 de                	mov    %ebx,%esi
80102dbf:	89 c1                	mov    %eax,%ecx
80102dc1:	fc                   	cld    
80102dc2:	f3 6f                	rep outsl %ds:(%esi),(%dx)
80102dc4:	89 c8                	mov    %ecx,%eax
80102dc6:	89 f3                	mov    %esi,%ebx
80102dc8:	89 5d 0c             	mov    %ebx,0xc(%ebp)
80102dcb:	89 45 10             	mov    %eax,0x10(%ebp)
               "=S" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "cc");
}
80102dce:	90                   	nop
80102dcf:	5b                   	pop    %ebx
80102dd0:	5e                   	pop    %esi
80102dd1:	5d                   	pop    %ebp
80102dd2:	c3                   	ret    

80102dd3 <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
80102dd3:	55                   	push   %ebp
80102dd4:	89 e5                	mov    %esp,%ebp
80102dd6:	83 ec 10             	sub    $0x10,%esp
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY) 
80102dd9:	90                   	nop
80102dda:	68 f7 01 00 00       	push   $0x1f7
80102ddf:	e8 67 ff ff ff       	call   80102d4b <inb>
80102de4:	83 c4 04             	add    $0x4,%esp
80102de7:	0f b6 c0             	movzbl %al,%eax
80102dea:	89 45 fc             	mov    %eax,-0x4(%ebp)
80102ded:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102df0:	25 c0 00 00 00       	and    $0xc0,%eax
80102df5:	83 f8 40             	cmp    $0x40,%eax
80102df8:	75 e0                	jne    80102dda <idewait+0x7>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
80102dfa:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102dfe:	74 11                	je     80102e11 <idewait+0x3e>
80102e00:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102e03:	83 e0 21             	and    $0x21,%eax
80102e06:	85 c0                	test   %eax,%eax
80102e08:	74 07                	je     80102e11 <idewait+0x3e>
    return -1;
80102e0a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102e0f:	eb 05                	jmp    80102e16 <idewait+0x43>
  return 0;
80102e11:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102e16:	c9                   	leave  
80102e17:	c3                   	ret    

80102e18 <ideinit>:

void
ideinit(void)
{
80102e18:	55                   	push   %ebp
80102e19:	89 e5                	mov    %esp,%ebp
80102e1b:	83 ec 18             	sub    $0x18,%esp
  int i;
  
  initlock(&idelock, "ide");
80102e1e:	83 ec 08             	sub    $0x8,%esp
80102e21:	68 02 96 10 80       	push   $0x80109602
80102e26:	68 00 c6 10 80       	push   $0x8010c600
80102e2b:	e8 32 2d 00 00       	call   80105b62 <initlock>
80102e30:	83 c4 10             	add    $0x10,%esp
  picenable(IRQ_IDE);
80102e33:	83 ec 0c             	sub    $0xc,%esp
80102e36:	6a 0e                	push   $0xe
80102e38:	e8 0d 1c 00 00       	call   80104a4a <picenable>
80102e3d:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_IDE, ncpu - 1);
80102e40:	a1 60 3e 11 80       	mov    0x80113e60,%eax
80102e45:	83 e8 01             	sub    $0x1,%eax
80102e48:	83 ec 08             	sub    $0x8,%esp
80102e4b:	50                   	push   %eax
80102e4c:	6a 0e                	push   $0xe
80102e4e:	e8 93 04 00 00       	call   801032e6 <ioapicenable>
80102e53:	83 c4 10             	add    $0x10,%esp
  idewait(0);
80102e56:	83 ec 0c             	sub    $0xc,%esp
80102e59:	6a 00                	push   $0x0
80102e5b:	e8 73 ff ff ff       	call   80102dd3 <idewait>
80102e60:	83 c4 10             	add    $0x10,%esp
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
80102e63:	83 ec 08             	sub    $0x8,%esp
80102e66:	68 f0 00 00 00       	push   $0xf0
80102e6b:	68 f6 01 00 00       	push   $0x1f6
80102e70:	e8 19 ff ff ff       	call   80102d8e <outb>
80102e75:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<1000; i++){
80102e78:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102e7f:	eb 24                	jmp    80102ea5 <ideinit+0x8d>
    if(inb(0x1f7) != 0){
80102e81:	83 ec 0c             	sub    $0xc,%esp
80102e84:	68 f7 01 00 00       	push   $0x1f7
80102e89:	e8 bd fe ff ff       	call   80102d4b <inb>
80102e8e:	83 c4 10             	add    $0x10,%esp
80102e91:	84 c0                	test   %al,%al
80102e93:	74 0c                	je     80102ea1 <ideinit+0x89>
      havedisk1 = 1;
80102e95:	c7 05 38 c6 10 80 01 	movl   $0x1,0x8010c638
80102e9c:	00 00 00 
      break;
80102e9f:	eb 0d                	jmp    80102eae <ideinit+0x96>
  ioapicenable(IRQ_IDE, ncpu - 1);
  idewait(0);
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
  for(i=0; i<1000; i++){
80102ea1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102ea5:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
80102eac:	7e d3                	jle    80102e81 <ideinit+0x69>
      break;
    }
  }
  
  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
80102eae:	83 ec 08             	sub    $0x8,%esp
80102eb1:	68 e0 00 00 00       	push   $0xe0
80102eb6:	68 f6 01 00 00       	push   $0x1f6
80102ebb:	e8 ce fe ff ff       	call   80102d8e <outb>
80102ec0:	83 c4 10             	add    $0x10,%esp
}
80102ec3:	90                   	nop
80102ec4:	c9                   	leave  
80102ec5:	c3                   	ret    

80102ec6 <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
80102ec6:	55                   	push   %ebp
80102ec7:	89 e5                	mov    %esp,%ebp
80102ec9:	83 ec 18             	sub    $0x18,%esp
  if(b == 0)
80102ecc:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102ed0:	75 0d                	jne    80102edf <idestart+0x19>
    panic("idestart");
80102ed2:	83 ec 0c             	sub    $0xc,%esp
80102ed5:	68 06 96 10 80       	push   $0x80109606
80102eda:	e8 87 d6 ff ff       	call   80100566 <panic>
  if(b->blockno >= FSSIZE){
80102edf:	8b 45 08             	mov    0x8(%ebp),%eax
80102ee2:	8b 40 08             	mov    0x8(%eax),%eax
80102ee5:	3d 9f 0f 00 00       	cmp    $0xf9f,%eax
80102eea:	76 1d                	jbe    80102f09 <idestart+0x43>
      cprintf("block %d \n");
80102eec:	83 ec 0c             	sub    $0xc,%esp
80102eef:	68 0f 96 10 80       	push   $0x8010960f
80102ef4:	e8 cd d4 ff ff       	call   801003c6 <cprintf>
80102ef9:	83 c4 10             	add    $0x10,%esp
          panic("incorrect blockno");
80102efc:	83 ec 0c             	sub    $0xc,%esp
80102eff:	68 1a 96 10 80       	push   $0x8010961a
80102f04:	e8 5d d6 ff ff       	call   80100566 <panic>

  }
  int sector_per_block =  BSIZE/SECTOR_SIZE;
80102f09:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  int sector = b->blockno * sector_per_block;
80102f10:	8b 45 08             	mov    0x8(%ebp),%eax
80102f13:	8b 50 08             	mov    0x8(%eax),%edx
80102f16:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102f19:	0f af c2             	imul   %edx,%eax
80102f1c:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if (sector_per_block > 7) panic("idestart");
80102f1f:	83 7d f4 07          	cmpl   $0x7,-0xc(%ebp)
80102f23:	7e 0d                	jle    80102f32 <idestart+0x6c>
80102f25:	83 ec 0c             	sub    $0xc,%esp
80102f28:	68 06 96 10 80       	push   $0x80109606
80102f2d:	e8 34 d6 ff ff       	call   80100566 <panic>
  
  idewait(0);
80102f32:	83 ec 0c             	sub    $0xc,%esp
80102f35:	6a 00                	push   $0x0
80102f37:	e8 97 fe ff ff       	call   80102dd3 <idewait>
80102f3c:	83 c4 10             	add    $0x10,%esp
  outb(0x3f6, 0);  // generate interrupt
80102f3f:	83 ec 08             	sub    $0x8,%esp
80102f42:	6a 00                	push   $0x0
80102f44:	68 f6 03 00 00       	push   $0x3f6
80102f49:	e8 40 fe ff ff       	call   80102d8e <outb>
80102f4e:	83 c4 10             	add    $0x10,%esp
  outb(0x1f2, sector_per_block);  // number of sectors
80102f51:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102f54:	0f b6 c0             	movzbl %al,%eax
80102f57:	83 ec 08             	sub    $0x8,%esp
80102f5a:	50                   	push   %eax
80102f5b:	68 f2 01 00 00       	push   $0x1f2
80102f60:	e8 29 fe ff ff       	call   80102d8e <outb>
80102f65:	83 c4 10             	add    $0x10,%esp
  outb(0x1f3, sector & 0xff);
80102f68:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102f6b:	0f b6 c0             	movzbl %al,%eax
80102f6e:	83 ec 08             	sub    $0x8,%esp
80102f71:	50                   	push   %eax
80102f72:	68 f3 01 00 00       	push   $0x1f3
80102f77:	e8 12 fe ff ff       	call   80102d8e <outb>
80102f7c:	83 c4 10             	add    $0x10,%esp
  outb(0x1f4, (sector >> 8) & 0xff);
80102f7f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102f82:	c1 f8 08             	sar    $0x8,%eax
80102f85:	0f b6 c0             	movzbl %al,%eax
80102f88:	83 ec 08             	sub    $0x8,%esp
80102f8b:	50                   	push   %eax
80102f8c:	68 f4 01 00 00       	push   $0x1f4
80102f91:	e8 f8 fd ff ff       	call   80102d8e <outb>
80102f96:	83 c4 10             	add    $0x10,%esp
  outb(0x1f5, (sector >> 16) & 0xff);
80102f99:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102f9c:	c1 f8 10             	sar    $0x10,%eax
80102f9f:	0f b6 c0             	movzbl %al,%eax
80102fa2:	83 ec 08             	sub    $0x8,%esp
80102fa5:	50                   	push   %eax
80102fa6:	68 f5 01 00 00       	push   $0x1f5
80102fab:	e8 de fd ff ff       	call   80102d8e <outb>
80102fb0:	83 c4 10             	add    $0x10,%esp
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
80102fb3:	8b 45 08             	mov    0x8(%ebp),%eax
80102fb6:	8b 40 04             	mov    0x4(%eax),%eax
80102fb9:	83 e0 01             	and    $0x1,%eax
80102fbc:	c1 e0 04             	shl    $0x4,%eax
80102fbf:	89 c2                	mov    %eax,%edx
80102fc1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102fc4:	c1 f8 18             	sar    $0x18,%eax
80102fc7:	83 e0 0f             	and    $0xf,%eax
80102fca:	09 d0                	or     %edx,%eax
80102fcc:	83 c8 e0             	or     $0xffffffe0,%eax
80102fcf:	0f b6 c0             	movzbl %al,%eax
80102fd2:	83 ec 08             	sub    $0x8,%esp
80102fd5:	50                   	push   %eax
80102fd6:	68 f6 01 00 00       	push   $0x1f6
80102fdb:	e8 ae fd ff ff       	call   80102d8e <outb>
80102fe0:	83 c4 10             	add    $0x10,%esp
  if(b->flags & B_DIRTY){
80102fe3:	8b 45 08             	mov    0x8(%ebp),%eax
80102fe6:	8b 00                	mov    (%eax),%eax
80102fe8:	83 e0 04             	and    $0x4,%eax
80102feb:	85 c0                	test   %eax,%eax
80102fed:	74 30                	je     8010301f <idestart+0x159>
    outb(0x1f7, IDE_CMD_WRITE);
80102fef:	83 ec 08             	sub    $0x8,%esp
80102ff2:	6a 30                	push   $0x30
80102ff4:	68 f7 01 00 00       	push   $0x1f7
80102ff9:	e8 90 fd ff ff       	call   80102d8e <outb>
80102ffe:	83 c4 10             	add    $0x10,%esp
    outsl(0x1f0, b->data, BSIZE/4);
80103001:	8b 45 08             	mov    0x8(%ebp),%eax
80103004:	83 c0 18             	add    $0x18,%eax
80103007:	83 ec 04             	sub    $0x4,%esp
8010300a:	68 80 00 00 00       	push   $0x80
8010300f:	50                   	push   %eax
80103010:	68 f0 01 00 00       	push   $0x1f0
80103015:	e8 93 fd ff ff       	call   80102dad <outsl>
8010301a:	83 c4 10             	add    $0x10,%esp
  } else {
    outb(0x1f7, IDE_CMD_READ);
  }
}
8010301d:	eb 12                	jmp    80103031 <idestart+0x16b>
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
  if(b->flags & B_DIRTY){
    outb(0x1f7, IDE_CMD_WRITE);
    outsl(0x1f0, b->data, BSIZE/4);
  } else {
    outb(0x1f7, IDE_CMD_READ);
8010301f:	83 ec 08             	sub    $0x8,%esp
80103022:	6a 20                	push   $0x20
80103024:	68 f7 01 00 00       	push   $0x1f7
80103029:	e8 60 fd ff ff       	call   80102d8e <outb>
8010302e:	83 c4 10             	add    $0x10,%esp
  }
}
80103031:	90                   	nop
80103032:	c9                   	leave  
80103033:	c3                   	ret    

80103034 <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
80103034:	55                   	push   %ebp
80103035:	89 e5                	mov    %esp,%ebp
80103037:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
8010303a:	83 ec 0c             	sub    $0xc,%esp
8010303d:	68 00 c6 10 80       	push   $0x8010c600
80103042:	e8 3d 2b 00 00       	call   80105b84 <acquire>
80103047:	83 c4 10             	add    $0x10,%esp
  if((b = idequeue) == 0){
8010304a:	a1 34 c6 10 80       	mov    0x8010c634,%eax
8010304f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103052:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103056:	75 15                	jne    8010306d <ideintr+0x39>
    release(&idelock);
80103058:	83 ec 0c             	sub    $0xc,%esp
8010305b:	68 00 c6 10 80       	push   $0x8010c600
80103060:	e8 86 2b 00 00       	call   80105beb <release>
80103065:	83 c4 10             	add    $0x10,%esp
    // cprintf("spurious IDE interrupt\n");
    return;
80103068:	e9 aa 00 00 00       	jmp    80103117 <ideintr+0xe3>
  }
  idequeue = b->qnext;
8010306d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103070:	8b 40 14             	mov    0x14(%eax),%eax
80103073:	a3 34 c6 10 80       	mov    %eax,0x8010c634

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
80103078:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010307b:	8b 00                	mov    (%eax),%eax
8010307d:	83 e0 04             	and    $0x4,%eax
80103080:	85 c0                	test   %eax,%eax
80103082:	75 2d                	jne    801030b1 <ideintr+0x7d>
80103084:	83 ec 0c             	sub    $0xc,%esp
80103087:	6a 01                	push   $0x1
80103089:	e8 45 fd ff ff       	call   80102dd3 <idewait>
8010308e:	83 c4 10             	add    $0x10,%esp
80103091:	85 c0                	test   %eax,%eax
80103093:	78 1c                	js     801030b1 <ideintr+0x7d>
    insl(0x1f0, b->data, BSIZE/4);
80103095:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103098:	83 c0 18             	add    $0x18,%eax
8010309b:	83 ec 04             	sub    $0x4,%esp
8010309e:	68 80 00 00 00       	push   $0x80
801030a3:	50                   	push   %eax
801030a4:	68 f0 01 00 00       	push   $0x1f0
801030a9:	e8 ba fc ff ff       	call   80102d68 <insl>
801030ae:	83 c4 10             	add    $0x10,%esp
  
  // Wake process waiting for this buf.
  b->flags |= B_VALID;
801030b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801030b4:	8b 00                	mov    (%eax),%eax
801030b6:	83 c8 02             	or     $0x2,%eax
801030b9:	89 c2                	mov    %eax,%edx
801030bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801030be:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
801030c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801030c3:	8b 00                	mov    (%eax),%eax
801030c5:	83 e0 fb             	and    $0xfffffffb,%eax
801030c8:	89 c2                	mov    %eax,%edx
801030ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801030cd:	89 10                	mov    %edx,(%eax)
  wakeup(b);
801030cf:	83 ec 0c             	sub    $0xc,%esp
801030d2:	ff 75 f4             	pushl  -0xc(%ebp)
801030d5:	e8 9c 28 00 00       	call   80105976 <wakeup>
801030da:	83 c4 10             	add    $0x10,%esp
  
  // Start disk on next buf in queue.
  if(idequeue != 0){
801030dd:	a1 34 c6 10 80       	mov    0x8010c634,%eax
801030e2:	85 c0                	test   %eax,%eax
801030e4:	74 21                	je     80103107 <ideintr+0xd3>
            cprintf("ideintr \n");
801030e6:	83 ec 0c             	sub    $0xc,%esp
801030e9:	68 2c 96 10 80       	push   $0x8010962c
801030ee:	e8 d3 d2 ff ff       	call   801003c6 <cprintf>
801030f3:	83 c4 10             	add    $0x10,%esp
                idestart(idequeue);
801030f6:	a1 34 c6 10 80       	mov    0x8010c634,%eax
801030fb:	83 ec 0c             	sub    $0xc,%esp
801030fe:	50                   	push   %eax
801030ff:	e8 c2 fd ff ff       	call   80102ec6 <idestart>
80103104:	83 c4 10             	add    $0x10,%esp


  }

  release(&idelock);
80103107:	83 ec 0c             	sub    $0xc,%esp
8010310a:	68 00 c6 10 80       	push   $0x8010c600
8010310f:	e8 d7 2a 00 00       	call   80105beb <release>
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
8010312e:	68 36 96 10 80       	push   $0x80109636
80103133:	e8 2e d4 ff ff       	call   80100566 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
80103138:	8b 45 08             	mov    0x8(%ebp),%eax
8010313b:	8b 00                	mov    (%eax),%eax
8010313d:	83 e0 06             	and    $0x6,%eax
80103140:	83 f8 02             	cmp    $0x2,%eax
80103143:	75 0d                	jne    80103152 <iderw+0x39>
    panic("iderw: nothing to do");
80103145:	83 ec 0c             	sub    $0xc,%esp
80103148:	68 4a 96 10 80       	push   $0x8010964a
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
80103168:	68 5f 96 10 80       	push   $0x8010965f
8010316d:	e8 f4 d3 ff ff       	call   80100566 <panic>

  acquire(&idelock);  //DOC:acquire-lock
80103172:	83 ec 0c             	sub    $0xc,%esp
80103175:	68 00 c6 10 80       	push   $0x8010c600
8010317a:	e8 05 2a 00 00       	call   80105b84 <acquire>
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
801031c1:	e8 00 fd ff ff       	call   80102ec6 <idestart>
801031c6:	83 c4 10             	add    $0x10,%esp

  }
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
801031c9:	eb 13                	jmp    801031de <iderw+0xc5>
    sleep(b, &idelock);
801031cb:	83 ec 08             	sub    $0x8,%esp
801031ce:	68 00 c6 10 80       	push   $0x8010c600
801031d3:	ff 75 08             	pushl  0x8(%ebp)
801031d6:	e8 b0 26 00 00       	call   8010588b <sleep>
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
801031f3:	e8 f3 29 00 00       	call   80105beb <release>
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
80103284:	68 80 96 10 80       	push   $0x80109680
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
80103344:	68 b2 96 10 80       	push   $0x801096b2
80103349:	68 00 35 11 80       	push   $0x80113500
8010334e:	e8 0f 28 00 00       	call   80105b62 <initlock>
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
80103405:	68 b7 96 10 80       	push   $0x801096b7
8010340a:	e8 57 d1 ff ff       	call   80100566 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
8010340f:	83 ec 04             	sub    $0x4,%esp
80103412:	68 00 10 00 00       	push   $0x1000
80103417:	6a 01                	push   $0x1
80103419:	ff 75 08             	pushl  0x8(%ebp)
8010341c:	e8 c6 29 00 00       	call   80105de7 <memset>
80103421:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
80103424:	a1 34 35 11 80       	mov    0x80113534,%eax
80103429:	85 c0                	test   %eax,%eax
8010342b:	74 10                	je     8010343d <kfree+0x68>
    acquire(&kmem.lock);
8010342d:	83 ec 0c             	sub    $0xc,%esp
80103430:	68 00 35 11 80       	push   $0x80113500
80103435:	e8 4a 27 00 00       	call   80105b84 <acquire>
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
80103467:	e8 7f 27 00 00       	call   80105beb <release>
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
80103489:	e8 f6 26 00 00       	call   80105b84 <acquire>
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
801034ba:	e8 2c 27 00 00       	call   80105beb <release>
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
80103805:	68 c0 96 10 80       	push   $0x801096c0
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
80103a30:	e8 19 24 00 00       	call   80105e4e <memcmp>
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
for(int i=0;i<NPARTITIONS;i++){
80103b41:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103b48:	e9 98 00 00 00       	jmp    80103be5 <initlog+0xaa>
     initlock(&logs[i].lock, "log");
80103b4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b50:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103b56:	05 40 35 11 80       	add    $0x80113540,%eax
80103b5b:	83 ec 08             	sub    $0x8,%esp
80103b5e:	68 ec 96 10 80       	push   $0x801096ec
80103b63:	50                   	push   %eax
80103b64:	e8 f9 1f 00 00       	call   80105b62 <initlock>
80103b69:	83 c4 10             	add    $0x10,%esp
 // readsb(dev, partitionNumber);
  logs[i].start = sbs[i].offset+sbs[i].logstart;
80103b6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b6f:	c1 e0 05             	shl    $0x5,%eax
80103b72:	05 70 d6 10 80       	add    $0x8010d670,%eax
80103b77:	8b 50 0c             	mov    0xc(%eax),%edx
80103b7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b7d:	c1 e0 05             	shl    $0x5,%eax
80103b80:	05 70 d6 10 80       	add    $0x8010d670,%eax
80103b85:	8b 00                	mov    (%eax),%eax
80103b87:	01 d0                	add    %edx,%eax
80103b89:	89 c2                	mov    %eax,%edx
80103b8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b8e:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103b94:	05 70 35 11 80       	add    $0x80113570,%eax
80103b99:	89 50 04             	mov    %edx,0x4(%eax)
  logs[i].size =  sbs[i].nlog;
80103b9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b9f:	c1 e0 05             	shl    $0x5,%eax
80103ba2:	05 60 d6 10 80       	add    $0x8010d660,%eax
80103ba7:	8b 40 0c             	mov    0xc(%eax),%eax
80103baa:	89 c2                	mov    %eax,%edx
80103bac:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103baf:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103bb5:	05 70 35 11 80       	add    $0x80113570,%eax
80103bba:	89 50 08             	mov    %edx,0x8(%eax)
  logs[i].dev = dev;
80103bbd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bc0:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103bc6:	8d 90 80 35 11 80    	lea    -0x7feeca80(%eax),%edx
80103bcc:	8b 45 08             	mov    0x8(%ebp),%eax
80103bcf:	89 42 04             	mov    %eax,0x4(%edx)
  recover_from_log(i);
80103bd2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bd5:	83 ec 0c             	sub    $0xc,%esp
80103bd8:	50                   	push   %eax
80103bd9:	e8 6a 02 00 00       	call   80103e48 <recover_from_log>
80103bde:	83 c4 10             	add    $0x10,%esp
void
initlog(int dev)
{
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");
for(int i=0;i<NPARTITIONS;i++){
80103be1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103be5:	83 7d f4 03          	cmpl   $0x3,-0xc(%ebp)
80103be9:	0f 8e 5e ff ff ff    	jle    80103b4d <initlog+0x12>
  logs[i].size =  sbs[i].nlog;
  logs[i].dev = dev;
  recover_from_log(i);
}
 
}
80103bef:	90                   	nop
80103bf0:	c9                   	leave  
80103bf1:	c3                   	ret    

80103bf2 <install_trans>:

// Copy committed blocks from log to their home location
static void 
install_trans(uint partitionNumber)
{
80103bf2:	55                   	push   %ebp
80103bf3:	89 e5                	mov    %esp,%ebp
80103bf5:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < logs[partitionNumber].lh.n; tail++) {
80103bf8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103bff:	e9 c0 00 00 00       	jmp    80103cc4 <install_trans+0xd2>
    struct buf *lbuf = bread(logs[partitionNumber].dev, logs[partitionNumber].start+tail+1); // read log block
80103c04:	8b 45 08             	mov    0x8(%ebp),%eax
80103c07:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103c0d:	05 70 35 11 80       	add    $0x80113570,%eax
80103c12:	8b 50 04             	mov    0x4(%eax),%edx
80103c15:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c18:	01 d0                	add    %edx,%eax
80103c1a:	83 c0 01             	add    $0x1,%eax
80103c1d:	89 c2                	mov    %eax,%edx
80103c1f:	8b 45 08             	mov    0x8(%ebp),%eax
80103c22:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103c28:	05 80 35 11 80       	add    $0x80113580,%eax
80103c2d:	8b 40 04             	mov    0x4(%eax),%eax
80103c30:	83 ec 08             	sub    $0x8,%esp
80103c33:	52                   	push   %edx
80103c34:	50                   	push   %eax
80103c35:	e8 7c c5 ff ff       	call   801001b6 <bread>
80103c3a:	83 c4 10             	add    $0x10,%esp
80103c3d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(logs[partitionNumber].dev, logs[partitionNumber].lh.block[tail]); // read dst
80103c40:	8b 45 08             	mov    0x8(%ebp),%eax
80103c43:	6b d0 31             	imul   $0x31,%eax,%edx
80103c46:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c49:	01 d0                	add    %edx,%eax
80103c4b:	83 c0 10             	add    $0x10,%eax
80103c4e:	8b 04 85 4c 35 11 80 	mov    -0x7feecab4(,%eax,4),%eax
80103c55:	89 c2                	mov    %eax,%edx
80103c57:	8b 45 08             	mov    0x8(%ebp),%eax
80103c5a:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103c60:	05 80 35 11 80       	add    $0x80113580,%eax
80103c65:	8b 40 04             	mov    0x4(%eax),%eax
80103c68:	83 ec 08             	sub    $0x8,%esp
80103c6b:	52                   	push   %edx
80103c6c:	50                   	push   %eax
80103c6d:	e8 44 c5 ff ff       	call   801001b6 <bread>
80103c72:	83 c4 10             	add    $0x10,%esp
80103c75:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
80103c78:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c7b:	8d 50 18             	lea    0x18(%eax),%edx
80103c7e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103c81:	83 c0 18             	add    $0x18,%eax
80103c84:	83 ec 04             	sub    $0x4,%esp
80103c87:	68 00 02 00 00       	push   $0x200
80103c8c:	52                   	push   %edx
80103c8d:	50                   	push   %eax
80103c8e:	e8 13 22 00 00       	call   80105ea6 <memmove>
80103c93:	83 c4 10             	add    $0x10,%esp
    bwrite(dbuf);  // write dst to disk
80103c96:	83 ec 0c             	sub    $0xc,%esp
80103c99:	ff 75 ec             	pushl  -0x14(%ebp)
80103c9c:	e8 4e c5 ff ff       	call   801001ef <bwrite>
80103ca1:	83 c4 10             	add    $0x10,%esp
    brelse(lbuf); 
80103ca4:	83 ec 0c             	sub    $0xc,%esp
80103ca7:	ff 75 f0             	pushl  -0x10(%ebp)
80103caa:	e8 7f c5 ff ff       	call   8010022e <brelse>
80103caf:	83 c4 10             	add    $0x10,%esp
    brelse(dbuf);
80103cb2:	83 ec 0c             	sub    $0xc,%esp
80103cb5:	ff 75 ec             	pushl  -0x14(%ebp)
80103cb8:	e8 71 c5 ff ff       	call   8010022e <brelse>
80103cbd:	83 c4 10             	add    $0x10,%esp
static void 
install_trans(uint partitionNumber)
{
  int tail;

  for (tail = 0; tail < logs[partitionNumber].lh.n; tail++) {
80103cc0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103cc4:	8b 45 08             	mov    0x8(%ebp),%eax
80103cc7:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103ccd:	05 80 35 11 80       	add    $0x80113580,%eax
80103cd2:	8b 40 08             	mov    0x8(%eax),%eax
80103cd5:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103cd8:	0f 8f 26 ff ff ff    	jg     80103c04 <install_trans+0x12>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    bwrite(dbuf);  // write dst to disk
    brelse(lbuf); 
    brelse(dbuf);
  }
}
80103cde:	90                   	nop
80103cdf:	c9                   	leave  
80103ce0:	c3                   	ret    

80103ce1 <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(uint partitionNumber)
{
80103ce1:	55                   	push   %ebp
80103ce2:	89 e5                	mov    %esp,%ebp
80103ce4:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(logs[partitionNumber].dev, logs[partitionNumber].start);
80103ce7:	8b 45 08             	mov    0x8(%ebp),%eax
80103cea:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103cf0:	05 70 35 11 80       	add    $0x80113570,%eax
80103cf5:	8b 40 04             	mov    0x4(%eax),%eax
80103cf8:	89 c2                	mov    %eax,%edx
80103cfa:	8b 45 08             	mov    0x8(%ebp),%eax
80103cfd:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103d03:	05 80 35 11 80       	add    $0x80113580,%eax
80103d08:	8b 40 04             	mov    0x4(%eax),%eax
80103d0b:	83 ec 08             	sub    $0x8,%esp
80103d0e:	52                   	push   %edx
80103d0f:	50                   	push   %eax
80103d10:	e8 a1 c4 ff ff       	call   801001b6 <bread>
80103d15:	83 c4 10             	add    $0x10,%esp
80103d18:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
80103d1b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d1e:	83 c0 18             	add    $0x18,%eax
80103d21:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  logs[partitionNumber].lh.n = lh->n;
80103d24:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103d27:	8b 00                	mov    (%eax),%eax
80103d29:	8b 55 08             	mov    0x8(%ebp),%edx
80103d2c:	69 d2 c4 00 00 00    	imul   $0xc4,%edx,%edx
80103d32:	81 c2 80 35 11 80    	add    $0x80113580,%edx
80103d38:	89 42 08             	mov    %eax,0x8(%edx)
  for (i = 0; i < logs[partitionNumber].lh.n; i++) {
80103d3b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103d42:	eb 23                	jmp    80103d67 <read_head+0x86>
    logs[partitionNumber].lh.block[i] = lh->block[i];
80103d44:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103d47:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103d4a:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
80103d4e:	8b 55 08             	mov    0x8(%ebp),%edx
80103d51:	6b ca 31             	imul   $0x31,%edx,%ecx
80103d54:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103d57:	01 ca                	add    %ecx,%edx
80103d59:	83 c2 10             	add    $0x10,%edx
80103d5c:	89 04 95 4c 35 11 80 	mov    %eax,-0x7feecab4(,%edx,4)
{
  struct buf *buf = bread(logs[partitionNumber].dev, logs[partitionNumber].start);
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  logs[partitionNumber].lh.n = lh->n;
  for (i = 0; i < logs[partitionNumber].lh.n; i++) {
80103d63:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103d67:	8b 45 08             	mov    0x8(%ebp),%eax
80103d6a:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103d70:	05 80 35 11 80       	add    $0x80113580,%eax
80103d75:	8b 40 08             	mov    0x8(%eax),%eax
80103d78:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103d7b:	7f c7                	jg     80103d44 <read_head+0x63>
    logs[partitionNumber].lh.block[i] = lh->block[i];
  }
  brelse(buf);
80103d7d:	83 ec 0c             	sub    $0xc,%esp
80103d80:	ff 75 f0             	pushl  -0x10(%ebp)
80103d83:	e8 a6 c4 ff ff       	call   8010022e <brelse>
80103d88:	83 c4 10             	add    $0x10,%esp
}
80103d8b:	90                   	nop
80103d8c:	c9                   	leave  
80103d8d:	c3                   	ret    

80103d8e <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(uint partitionNumber)
{
80103d8e:	55                   	push   %ebp
80103d8f:	89 e5                	mov    %esp,%ebp
80103d91:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(logs[partitionNumber].dev, logs[partitionNumber].start);
80103d94:	8b 45 08             	mov    0x8(%ebp),%eax
80103d97:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103d9d:	05 70 35 11 80       	add    $0x80113570,%eax
80103da2:	8b 40 04             	mov    0x4(%eax),%eax
80103da5:	89 c2                	mov    %eax,%edx
80103da7:	8b 45 08             	mov    0x8(%ebp),%eax
80103daa:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103db0:	05 80 35 11 80       	add    $0x80113580,%eax
80103db5:	8b 40 04             	mov    0x4(%eax),%eax
80103db8:	83 ec 08             	sub    $0x8,%esp
80103dbb:	52                   	push   %edx
80103dbc:	50                   	push   %eax
80103dbd:	e8 f4 c3 ff ff       	call   801001b6 <bread>
80103dc2:	83 c4 10             	add    $0x10,%esp
80103dc5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
80103dc8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103dcb:	83 c0 18             	add    $0x18,%eax
80103dce:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = logs[partitionNumber].lh.n;
80103dd1:	8b 45 08             	mov    0x8(%ebp),%eax
80103dd4:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103dda:	05 80 35 11 80       	add    $0x80113580,%eax
80103ddf:	8b 50 08             	mov    0x8(%eax),%edx
80103de2:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103de5:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < logs[partitionNumber].lh.n; i++) {
80103de7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103dee:	eb 23                	jmp    80103e13 <write_head+0x85>
    hb->block[i] = logs[partitionNumber].lh.block[i];
80103df0:	8b 45 08             	mov    0x8(%ebp),%eax
80103df3:	6b d0 31             	imul   $0x31,%eax,%edx
80103df6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103df9:	01 d0                	add    %edx,%eax
80103dfb:	83 c0 10             	add    $0x10,%eax
80103dfe:	8b 0c 85 4c 35 11 80 	mov    -0x7feecab4(,%eax,4),%ecx
80103e05:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103e08:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103e0b:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
{
  struct buf *buf = bread(logs[partitionNumber].dev, logs[partitionNumber].start);
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = logs[partitionNumber].lh.n;
  for (i = 0; i < logs[partitionNumber].lh.n; i++) {
80103e0f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103e13:	8b 45 08             	mov    0x8(%ebp),%eax
80103e16:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103e1c:	05 80 35 11 80       	add    $0x80113580,%eax
80103e21:	8b 40 08             	mov    0x8(%eax),%eax
80103e24:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103e27:	7f c7                	jg     80103df0 <write_head+0x62>
    hb->block[i] = logs[partitionNumber].lh.block[i];
  }
  bwrite(buf);
80103e29:	83 ec 0c             	sub    $0xc,%esp
80103e2c:	ff 75 f0             	pushl  -0x10(%ebp)
80103e2f:	e8 bb c3 ff ff       	call   801001ef <bwrite>
80103e34:	83 c4 10             	add    $0x10,%esp
  brelse(buf);
80103e37:	83 ec 0c             	sub    $0xc,%esp
80103e3a:	ff 75 f0             	pushl  -0x10(%ebp)
80103e3d:	e8 ec c3 ff ff       	call   8010022e <brelse>
80103e42:	83 c4 10             	add    $0x10,%esp
}
80103e45:	90                   	nop
80103e46:	c9                   	leave  
80103e47:	c3                   	ret    

80103e48 <recover_from_log>:

static void
recover_from_log(uint partitionNumber)
{
80103e48:	55                   	push   %ebp
80103e49:	89 e5                	mov    %esp,%ebp
80103e4b:	83 ec 08             	sub    $0x8,%esp
  read_head(partitionNumber);      
80103e4e:	83 ec 0c             	sub    $0xc,%esp
80103e51:	ff 75 08             	pushl  0x8(%ebp)
80103e54:	e8 88 fe ff ff       	call   80103ce1 <read_head>
80103e59:	83 c4 10             	add    $0x10,%esp
  install_trans(partitionNumber); // if committed, copy from log to disk
80103e5c:	83 ec 0c             	sub    $0xc,%esp
80103e5f:	ff 75 08             	pushl  0x8(%ebp)
80103e62:	e8 8b fd ff ff       	call   80103bf2 <install_trans>
80103e67:	83 c4 10             	add    $0x10,%esp
  logs[partitionNumber].lh.n = 0;
80103e6a:	8b 45 08             	mov    0x8(%ebp),%eax
80103e6d:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103e73:	05 80 35 11 80       	add    $0x80113580,%eax
80103e78:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  write_head(partitionNumber); // clear the log
80103e7f:	83 ec 0c             	sub    $0xc,%esp
80103e82:	ff 75 08             	pushl  0x8(%ebp)
80103e85:	e8 04 ff ff ff       	call   80103d8e <write_head>
80103e8a:	83 c4 10             	add    $0x10,%esp
}
80103e8d:	90                   	nop
80103e8e:	c9                   	leave  
80103e8f:	c3                   	ret    

80103e90 <begin_op>:

// called at the start of each FS system call.
void
begin_op(uint partitionNumber)
{
80103e90:	55                   	push   %ebp
80103e91:	89 e5                	mov    %esp,%ebp
80103e93:	83 ec 08             	sub    $0x8,%esp
  acquire(&logs[partitionNumber].lock);
80103e96:	8b 45 08             	mov    0x8(%ebp),%eax
80103e99:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103e9f:	05 40 35 11 80       	add    $0x80113540,%eax
80103ea4:	83 ec 0c             	sub    $0xc,%esp
80103ea7:	50                   	push   %eax
80103ea8:	e8 d7 1c 00 00       	call   80105b84 <acquire>
80103ead:	83 c4 10             	add    $0x10,%esp
  while(1){
    if(logs[partitionNumber].committing){
80103eb0:	8b 45 08             	mov    0x8(%ebp),%eax
80103eb3:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103eb9:	05 80 35 11 80       	add    $0x80113580,%eax
80103ebe:	8b 00                	mov    (%eax),%eax
80103ec0:	85 c0                	test   %eax,%eax
80103ec2:	74 2c                	je     80103ef0 <begin_op+0x60>
      sleep(&logs[partitionNumber], &logs[partitionNumber].lock);
80103ec4:	8b 45 08             	mov    0x8(%ebp),%eax
80103ec7:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103ecd:	8d 90 40 35 11 80    	lea    -0x7feecac0(%eax),%edx
80103ed3:	8b 45 08             	mov    0x8(%ebp),%eax
80103ed6:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103edc:	05 40 35 11 80       	add    $0x80113540,%eax
80103ee1:	83 ec 08             	sub    $0x8,%esp
80103ee4:	52                   	push   %edx
80103ee5:	50                   	push   %eax
80103ee6:	e8 a0 19 00 00       	call   8010588b <sleep>
80103eeb:	83 c4 10             	add    $0x10,%esp
80103eee:	eb c0                	jmp    80103eb0 <begin_op+0x20>
    } else if(logs[partitionNumber].lh.n + (logs[partitionNumber].outstanding+1)*MAXOPBLOCKS > LOGSIZE){
80103ef0:	8b 45 08             	mov    0x8(%ebp),%eax
80103ef3:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103ef9:	05 80 35 11 80       	add    $0x80113580,%eax
80103efe:	8b 48 08             	mov    0x8(%eax),%ecx
80103f01:	8b 45 08             	mov    0x8(%ebp),%eax
80103f04:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103f0a:	05 70 35 11 80       	add    $0x80113570,%eax
80103f0f:	8b 40 0c             	mov    0xc(%eax),%eax
80103f12:	8d 50 01             	lea    0x1(%eax),%edx
80103f15:	89 d0                	mov    %edx,%eax
80103f17:	c1 e0 02             	shl    $0x2,%eax
80103f1a:	01 d0                	add    %edx,%eax
80103f1c:	01 c0                	add    %eax,%eax
80103f1e:	01 c8                	add    %ecx,%eax
80103f20:	83 f8 1e             	cmp    $0x1e,%eax
80103f23:	7e 2f                	jle    80103f54 <begin_op+0xc4>
      // this op might exhaust log space; wait for commit.
      sleep(&logs[partitionNumber], &logs[partitionNumber].lock);
80103f25:	8b 45 08             	mov    0x8(%ebp),%eax
80103f28:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103f2e:	8d 90 40 35 11 80    	lea    -0x7feecac0(%eax),%edx
80103f34:	8b 45 08             	mov    0x8(%ebp),%eax
80103f37:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103f3d:	05 40 35 11 80       	add    $0x80113540,%eax
80103f42:	83 ec 08             	sub    $0x8,%esp
80103f45:	52                   	push   %edx
80103f46:	50                   	push   %eax
80103f47:	e8 3f 19 00 00       	call   8010588b <sleep>
80103f4c:	83 c4 10             	add    $0x10,%esp
80103f4f:	e9 5c ff ff ff       	jmp    80103eb0 <begin_op+0x20>
    } else {
      logs[partitionNumber].outstanding += 1;
80103f54:	8b 45 08             	mov    0x8(%ebp),%eax
80103f57:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103f5d:	05 70 35 11 80       	add    $0x80113570,%eax
80103f62:	8b 40 0c             	mov    0xc(%eax),%eax
80103f65:	8d 50 01             	lea    0x1(%eax),%edx
80103f68:	8b 45 08             	mov    0x8(%ebp),%eax
80103f6b:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103f71:	05 70 35 11 80       	add    $0x80113570,%eax
80103f76:	89 50 0c             	mov    %edx,0xc(%eax)
      release(&logs[partitionNumber].lock);
80103f79:	8b 45 08             	mov    0x8(%ebp),%eax
80103f7c:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103f82:	05 40 35 11 80       	add    $0x80113540,%eax
80103f87:	83 ec 0c             	sub    $0xc,%esp
80103f8a:	50                   	push   %eax
80103f8b:	e8 5b 1c 00 00       	call   80105beb <release>
80103f90:	83 c4 10             	add    $0x10,%esp
      break;
80103f93:	90                   	nop
    }
  }
}
80103f94:	90                   	nop
80103f95:	c9                   	leave  
80103f96:	c3                   	ret    

80103f97 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(uint partitionNumber)
{
80103f97:	55                   	push   %ebp
80103f98:	89 e5                	mov    %esp,%ebp
80103f9a:	83 ec 18             	sub    $0x18,%esp
  int do_commit = 0;
80103f9d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&logs[partitionNumber].lock);
80103fa4:	8b 45 08             	mov    0x8(%ebp),%eax
80103fa7:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103fad:	05 40 35 11 80       	add    $0x80113540,%eax
80103fb2:	83 ec 0c             	sub    $0xc,%esp
80103fb5:	50                   	push   %eax
80103fb6:	e8 c9 1b 00 00       	call   80105b84 <acquire>
80103fbb:	83 c4 10             	add    $0x10,%esp
  logs[partitionNumber].outstanding -= 1;
80103fbe:	8b 45 08             	mov    0x8(%ebp),%eax
80103fc1:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103fc7:	05 70 35 11 80       	add    $0x80113570,%eax
80103fcc:	8b 40 0c             	mov    0xc(%eax),%eax
80103fcf:	8d 50 ff             	lea    -0x1(%eax),%edx
80103fd2:	8b 45 08             	mov    0x8(%ebp),%eax
80103fd5:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103fdb:	05 70 35 11 80       	add    $0x80113570,%eax
80103fe0:	89 50 0c             	mov    %edx,0xc(%eax)
  if(logs[partitionNumber].committing)
80103fe3:	8b 45 08             	mov    0x8(%ebp),%eax
80103fe6:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103fec:	05 80 35 11 80       	add    $0x80113580,%eax
80103ff1:	8b 00                	mov    (%eax),%eax
80103ff3:	85 c0                	test   %eax,%eax
80103ff5:	74 0d                	je     80104004 <end_op+0x6d>
    panic("log.committing");
80103ff7:	83 ec 0c             	sub    $0xc,%esp
80103ffa:	68 f0 96 10 80       	push   $0x801096f0
80103fff:	e8 62 c5 ff ff       	call   80100566 <panic>
  if(logs[partitionNumber].outstanding == 0){
80104004:	8b 45 08             	mov    0x8(%ebp),%eax
80104007:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
8010400d:	05 70 35 11 80       	add    $0x80113570,%eax
80104012:	8b 40 0c             	mov    0xc(%eax),%eax
80104015:	85 c0                	test   %eax,%eax
80104017:	75 1d                	jne    80104036 <end_op+0x9f>
    do_commit = 1;
80104019:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    logs[partitionNumber].committing = 1;
80104020:	8b 45 08             	mov    0x8(%ebp),%eax
80104023:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80104029:	05 80 35 11 80       	add    $0x80113580,%eax
8010402e:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
80104034:	eb 1a                	jmp    80104050 <end_op+0xb9>
  } else {
    // begin_op() may be waiting for log space.
    wakeup(&logs[partitionNumber]);
80104036:	8b 45 08             	mov    0x8(%ebp),%eax
80104039:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
8010403f:	05 40 35 11 80       	add    $0x80113540,%eax
80104044:	83 ec 0c             	sub    $0xc,%esp
80104047:	50                   	push   %eax
80104048:	e8 29 19 00 00       	call   80105976 <wakeup>
8010404d:	83 c4 10             	add    $0x10,%esp
  }
  release(&logs[partitionNumber].lock);
80104050:	8b 45 08             	mov    0x8(%ebp),%eax
80104053:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80104059:	05 40 35 11 80       	add    $0x80113540,%eax
8010405e:	83 ec 0c             	sub    $0xc,%esp
80104061:	50                   	push   %eax
80104062:	e8 84 1b 00 00       	call   80105beb <release>
80104067:	83 c4 10             	add    $0x10,%esp

  if(do_commit){
8010406a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010406e:	74 70                	je     801040e0 <end_op+0x149>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit(partitionNumber);
80104070:	83 ec 0c             	sub    $0xc,%esp
80104073:	ff 75 08             	pushl  0x8(%ebp)
80104076:	e8 57 01 00 00       	call   801041d2 <commit>
8010407b:	83 c4 10             	add    $0x10,%esp
    acquire(&logs[partitionNumber].lock);
8010407e:	8b 45 08             	mov    0x8(%ebp),%eax
80104081:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80104087:	05 40 35 11 80       	add    $0x80113540,%eax
8010408c:	83 ec 0c             	sub    $0xc,%esp
8010408f:	50                   	push   %eax
80104090:	e8 ef 1a 00 00       	call   80105b84 <acquire>
80104095:	83 c4 10             	add    $0x10,%esp
    logs[partitionNumber].committing = 0;
80104098:	8b 45 08             	mov    0x8(%ebp),%eax
8010409b:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
801040a1:	05 80 35 11 80       	add    $0x80113580,%eax
801040a6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    wakeup(&logs[partitionNumber]);
801040ac:	8b 45 08             	mov    0x8(%ebp),%eax
801040af:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
801040b5:	05 40 35 11 80       	add    $0x80113540,%eax
801040ba:	83 ec 0c             	sub    $0xc,%esp
801040bd:	50                   	push   %eax
801040be:	e8 b3 18 00 00       	call   80105976 <wakeup>
801040c3:	83 c4 10             	add    $0x10,%esp
    release(&logs[partitionNumber].lock);
801040c6:	8b 45 08             	mov    0x8(%ebp),%eax
801040c9:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
801040cf:	05 40 35 11 80       	add    $0x80113540,%eax
801040d4:	83 ec 0c             	sub    $0xc,%esp
801040d7:	50                   	push   %eax
801040d8:	e8 0e 1b 00 00       	call   80105beb <release>
801040dd:	83 c4 10             	add    $0x10,%esp
  }
}
801040e0:	90                   	nop
801040e1:	c9                   	leave  
801040e2:	c3                   	ret    

801040e3 <write_log>:

// Copy modified blocks from cache to log.
static void 
write_log(uint partitionNumber)
{
801040e3:	55                   	push   %ebp
801040e4:	89 e5                	mov    %esp,%ebp
801040e6:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < logs[partitionNumber].lh.n; tail++) {
801040e9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801040f0:	e9 c0 00 00 00       	jmp    801041b5 <write_log+0xd2>
    struct buf *to = bread(logs[partitionNumber].dev, logs[partitionNumber].start+tail+1); // log block
801040f5:	8b 45 08             	mov    0x8(%ebp),%eax
801040f8:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
801040fe:	05 70 35 11 80       	add    $0x80113570,%eax
80104103:	8b 50 04             	mov    0x4(%eax),%edx
80104106:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104109:	01 d0                	add    %edx,%eax
8010410b:	83 c0 01             	add    $0x1,%eax
8010410e:	89 c2                	mov    %eax,%edx
80104110:	8b 45 08             	mov    0x8(%ebp),%eax
80104113:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80104119:	05 80 35 11 80       	add    $0x80113580,%eax
8010411e:	8b 40 04             	mov    0x4(%eax),%eax
80104121:	83 ec 08             	sub    $0x8,%esp
80104124:	52                   	push   %edx
80104125:	50                   	push   %eax
80104126:	e8 8b c0 ff ff       	call   801001b6 <bread>
8010412b:	83 c4 10             	add    $0x10,%esp
8010412e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(logs[partitionNumber].dev, logs[partitionNumber].lh.block[tail]); // cache block
80104131:	8b 45 08             	mov    0x8(%ebp),%eax
80104134:	6b d0 31             	imul   $0x31,%eax,%edx
80104137:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010413a:	01 d0                	add    %edx,%eax
8010413c:	83 c0 10             	add    $0x10,%eax
8010413f:	8b 04 85 4c 35 11 80 	mov    -0x7feecab4(,%eax,4),%eax
80104146:	89 c2                	mov    %eax,%edx
80104148:	8b 45 08             	mov    0x8(%ebp),%eax
8010414b:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80104151:	05 80 35 11 80       	add    $0x80113580,%eax
80104156:	8b 40 04             	mov    0x4(%eax),%eax
80104159:	83 ec 08             	sub    $0x8,%esp
8010415c:	52                   	push   %edx
8010415d:	50                   	push   %eax
8010415e:	e8 53 c0 ff ff       	call   801001b6 <bread>
80104163:	83 c4 10             	add    $0x10,%esp
80104166:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
80104169:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010416c:	8d 50 18             	lea    0x18(%eax),%edx
8010416f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104172:	83 c0 18             	add    $0x18,%eax
80104175:	83 ec 04             	sub    $0x4,%esp
80104178:	68 00 02 00 00       	push   $0x200
8010417d:	52                   	push   %edx
8010417e:	50                   	push   %eax
8010417f:	e8 22 1d 00 00       	call   80105ea6 <memmove>
80104184:	83 c4 10             	add    $0x10,%esp
    bwrite(to);  // write the log
80104187:	83 ec 0c             	sub    $0xc,%esp
8010418a:	ff 75 f0             	pushl  -0x10(%ebp)
8010418d:	e8 5d c0 ff ff       	call   801001ef <bwrite>
80104192:	83 c4 10             	add    $0x10,%esp
    brelse(from); 
80104195:	83 ec 0c             	sub    $0xc,%esp
80104198:	ff 75 ec             	pushl  -0x14(%ebp)
8010419b:	e8 8e c0 ff ff       	call   8010022e <brelse>
801041a0:	83 c4 10             	add    $0x10,%esp
    brelse(to);
801041a3:	83 ec 0c             	sub    $0xc,%esp
801041a6:	ff 75 f0             	pushl  -0x10(%ebp)
801041a9:	e8 80 c0 ff ff       	call   8010022e <brelse>
801041ae:	83 c4 10             	add    $0x10,%esp
static void 
write_log(uint partitionNumber)
{
  int tail;

  for (tail = 0; tail < logs[partitionNumber].lh.n; tail++) {
801041b1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801041b5:	8b 45 08             	mov    0x8(%ebp),%eax
801041b8:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
801041be:	05 80 35 11 80       	add    $0x80113580,%eax
801041c3:	8b 40 08             	mov    0x8(%eax),%eax
801041c6:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801041c9:	0f 8f 26 ff ff ff    	jg     801040f5 <write_log+0x12>
    memmove(to->data, from->data, BSIZE);
    bwrite(to);  // write the log
    brelse(from); 
    brelse(to);
  }
}
801041cf:	90                   	nop
801041d0:	c9                   	leave  
801041d1:	c3                   	ret    

801041d2 <commit>:

static void
commit(uint partitionNumber)
{
801041d2:	55                   	push   %ebp
801041d3:	89 e5                	mov    %esp,%ebp
801041d5:	83 ec 08             	sub    $0x8,%esp
  if (logs[partitionNumber].lh.n > 0) {
801041d8:	8b 45 08             	mov    0x8(%ebp),%eax
801041db:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
801041e1:	05 80 35 11 80       	add    $0x80113580,%eax
801041e6:	8b 40 08             	mov    0x8(%eax),%eax
801041e9:	85 c0                	test   %eax,%eax
801041eb:	7e 4d                	jle    8010423a <commit+0x68>
    write_log(partitionNumber);     // Write modified blocks from cache to log
801041ed:	83 ec 0c             	sub    $0xc,%esp
801041f0:	ff 75 08             	pushl  0x8(%ebp)
801041f3:	e8 eb fe ff ff       	call   801040e3 <write_log>
801041f8:	83 c4 10             	add    $0x10,%esp
    write_head(partitionNumber);    // Write header to disk -- the real commit
801041fb:	83 ec 0c             	sub    $0xc,%esp
801041fe:	ff 75 08             	pushl  0x8(%ebp)
80104201:	e8 88 fb ff ff       	call   80103d8e <write_head>
80104206:	83 c4 10             	add    $0x10,%esp
    install_trans(partitionNumber); // Now install writes to home locations
80104209:	83 ec 0c             	sub    $0xc,%esp
8010420c:	ff 75 08             	pushl  0x8(%ebp)
8010420f:	e8 de f9 ff ff       	call   80103bf2 <install_trans>
80104214:	83 c4 10             	add    $0x10,%esp
    logs[partitionNumber].lh.n = 0; 
80104217:	8b 45 08             	mov    0x8(%ebp),%eax
8010421a:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80104220:	05 80 35 11 80       	add    $0x80113580,%eax
80104225:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    write_head(partitionNumber);    // Erase the transaction from the log
8010422c:	83 ec 0c             	sub    $0xc,%esp
8010422f:	ff 75 08             	pushl  0x8(%ebp)
80104232:	e8 57 fb ff ff       	call   80103d8e <write_head>
80104237:	83 c4 10             	add    $0x10,%esp
  }
}
8010423a:	90                   	nop
8010423b:	c9                   	leave  
8010423c:	c3                   	ret    

8010423d <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b,uint partitionNumber)
{
8010423d:	55                   	push   %ebp
8010423e:	89 e5                	mov    %esp,%ebp
80104240:	83 ec 18             	sub    $0x18,%esp
  int i;

  if (logs[partitionNumber].lh.n >= LOGSIZE || logs[partitionNumber].lh.n >= logs[partitionNumber].size - 1)
80104243:	8b 45 0c             	mov    0xc(%ebp),%eax
80104246:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
8010424c:	05 80 35 11 80       	add    $0x80113580,%eax
80104251:	8b 40 08             	mov    0x8(%eax),%eax
80104254:	83 f8 1d             	cmp    $0x1d,%eax
80104257:	7f 2a                	jg     80104283 <log_write+0x46>
80104259:	8b 45 0c             	mov    0xc(%ebp),%eax
8010425c:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80104262:	05 80 35 11 80       	add    $0x80113580,%eax
80104267:	8b 40 08             	mov    0x8(%eax),%eax
8010426a:	8b 55 0c             	mov    0xc(%ebp),%edx
8010426d:	69 d2 c4 00 00 00    	imul   $0xc4,%edx,%edx
80104273:	81 c2 70 35 11 80    	add    $0x80113570,%edx
80104279:	8b 52 08             	mov    0x8(%edx),%edx
8010427c:	83 ea 01             	sub    $0x1,%edx
8010427f:	39 d0                	cmp    %edx,%eax
80104281:	7c 0d                	jl     80104290 <log_write+0x53>
    panic("too big a transaction");
80104283:	83 ec 0c             	sub    $0xc,%esp
80104286:	68 ff 96 10 80       	push   $0x801096ff
8010428b:	e8 d6 c2 ff ff       	call   80100566 <panic>
  if (logs[partitionNumber].outstanding < 1)
80104290:	8b 45 0c             	mov    0xc(%ebp),%eax
80104293:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80104299:	05 70 35 11 80       	add    $0x80113570,%eax
8010429e:	8b 40 0c             	mov    0xc(%eax),%eax
801042a1:	85 c0                	test   %eax,%eax
801042a3:	7f 0d                	jg     801042b2 <log_write+0x75>
    panic("log_write outside of trans");
801042a5:	83 ec 0c             	sub    $0xc,%esp
801042a8:	68 15 97 10 80       	push   $0x80109715
801042ad:	e8 b4 c2 ff ff       	call   80100566 <panic>

  acquire(&logs[partitionNumber].lock);
801042b2:	8b 45 0c             	mov    0xc(%ebp),%eax
801042b5:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
801042bb:	05 40 35 11 80       	add    $0x80113540,%eax
801042c0:	83 ec 0c             	sub    $0xc,%esp
801042c3:	50                   	push   %eax
801042c4:	e8 bb 18 00 00       	call   80105b84 <acquire>
801042c9:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < logs[partitionNumber].lh.n; i++) {
801042cc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801042d3:	eb 25                	jmp    801042fa <log_write+0xbd>
    if (logs[partitionNumber].lh.block[i] == b->blockno)   // log absorbtion
801042d5:	8b 45 0c             	mov    0xc(%ebp),%eax
801042d8:	6b d0 31             	imul   $0x31,%eax,%edx
801042db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042de:	01 d0                	add    %edx,%eax
801042e0:	83 c0 10             	add    $0x10,%eax
801042e3:	8b 04 85 4c 35 11 80 	mov    -0x7feecab4(,%eax,4),%eax
801042ea:	89 c2                	mov    %eax,%edx
801042ec:	8b 45 08             	mov    0x8(%ebp),%eax
801042ef:	8b 40 08             	mov    0x8(%eax),%eax
801042f2:	39 c2                	cmp    %eax,%edx
801042f4:	74 1c                	je     80104312 <log_write+0xd5>
    panic("too big a transaction");
  if (logs[partitionNumber].outstanding < 1)
    panic("log_write outside of trans");

  acquire(&logs[partitionNumber].lock);
  for (i = 0; i < logs[partitionNumber].lh.n; i++) {
801042f6:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801042fa:	8b 45 0c             	mov    0xc(%ebp),%eax
801042fd:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80104303:	05 80 35 11 80       	add    $0x80113580,%eax
80104308:	8b 40 08             	mov    0x8(%eax),%eax
8010430b:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010430e:	7f c5                	jg     801042d5 <log_write+0x98>
80104310:	eb 01                	jmp    80104313 <log_write+0xd6>
    if (logs[partitionNumber].lh.block[i] == b->blockno)   // log absorbtion
      break;
80104312:	90                   	nop
  }
  logs[partitionNumber].lh.block[i] = b->blockno;
80104313:	8b 45 08             	mov    0x8(%ebp),%eax
80104316:	8b 40 08             	mov    0x8(%eax),%eax
80104319:	89 c1                	mov    %eax,%ecx
8010431b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010431e:	6b d0 31             	imul   $0x31,%eax,%edx
80104321:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104324:	01 d0                	add    %edx,%eax
80104326:	83 c0 10             	add    $0x10,%eax
80104329:	89 0c 85 4c 35 11 80 	mov    %ecx,-0x7feecab4(,%eax,4)
  if (i == logs[partitionNumber].lh.n)
80104330:	8b 45 0c             	mov    0xc(%ebp),%eax
80104333:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80104339:	05 80 35 11 80       	add    $0x80113580,%eax
8010433e:	8b 40 08             	mov    0x8(%eax),%eax
80104341:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80104344:	75 25                	jne    8010436b <log_write+0x12e>
    logs[partitionNumber].lh.n++;
80104346:	8b 45 0c             	mov    0xc(%ebp),%eax
80104349:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
8010434f:	05 80 35 11 80       	add    $0x80113580,%eax
80104354:	8b 40 08             	mov    0x8(%eax),%eax
80104357:	8d 50 01             	lea    0x1(%eax),%edx
8010435a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010435d:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80104363:	05 80 35 11 80       	add    $0x80113580,%eax
80104368:	89 50 08             	mov    %edx,0x8(%eax)
  b->flags |= B_DIRTY; // prevent eviction
8010436b:	8b 45 08             	mov    0x8(%ebp),%eax
8010436e:	8b 00                	mov    (%eax),%eax
80104370:	83 c8 04             	or     $0x4,%eax
80104373:	89 c2                	mov    %eax,%edx
80104375:	8b 45 08             	mov    0x8(%ebp),%eax
80104378:	89 10                	mov    %edx,(%eax)
  release(&logs[partitionNumber].lock);
8010437a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010437d:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80104383:	05 40 35 11 80       	add    $0x80113540,%eax
80104388:	83 ec 0c             	sub    $0xc,%esp
8010438b:	50                   	push   %eax
8010438c:	e8 5a 18 00 00       	call   80105beb <release>
80104391:	83 c4 10             	add    $0x10,%esp
}
80104394:	90                   	nop
80104395:	c9                   	leave  
80104396:	c3                   	ret    

80104397 <v2p>:
80104397:	55                   	push   %ebp
80104398:	89 e5                	mov    %esp,%ebp
8010439a:	8b 45 08             	mov    0x8(%ebp),%eax
8010439d:	05 00 00 00 80       	add    $0x80000000,%eax
801043a2:	5d                   	pop    %ebp
801043a3:	c3                   	ret    

801043a4 <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
801043a4:	55                   	push   %ebp
801043a5:	89 e5                	mov    %esp,%ebp
801043a7:	8b 45 08             	mov    0x8(%ebp),%eax
801043aa:	05 00 00 00 80       	add    $0x80000000,%eax
801043af:	5d                   	pop    %ebp
801043b0:	c3                   	ret    

801043b1 <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
801043b1:	55                   	push   %ebp
801043b2:	89 e5                	mov    %esp,%ebp
801043b4:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
801043b7:	8b 55 08             	mov    0x8(%ebp),%edx
801043ba:	8b 45 0c             	mov    0xc(%ebp),%eax
801043bd:	8b 4d 08             	mov    0x8(%ebp),%ecx
801043c0:	f0 87 02             	lock xchg %eax,(%edx)
801043c3:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
801043c6:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801043c9:	c9                   	leave  
801043ca:	c3                   	ret    

801043cb <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
801043cb:	8d 4c 24 04          	lea    0x4(%esp),%ecx
801043cf:	83 e4 f0             	and    $0xfffffff0,%esp
801043d2:	ff 71 fc             	pushl  -0x4(%ecx)
801043d5:	55                   	push   %ebp
801043d6:	89 e5                	mov    %esp,%ebp
801043d8:	51                   	push   %ecx
801043d9:	83 ec 04             	sub    $0x4,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
801043dc:	83 ec 08             	sub    $0x8,%esp
801043df:	68 00 00 40 80       	push   $0x80400000
801043e4:	68 5c 66 11 80       	push   $0x8011665c
801043e9:	e8 4d ef ff ff       	call   8010333b <kinit1>
801043ee:	83 c4 10             	add    $0x10,%esp
  kvmalloc();      // kernel page table
801043f1:	e8 2d 48 00 00       	call   80108c23 <kvmalloc>
  mpinit();        // collect info about this machine
801043f6:	e8 26 04 00 00       	call   80104821 <mpinit>
  lapicinit();
801043fb:	e8 ba f2 ff ff       	call   801036ba <lapicinit>
  seginit();       // set up segments
80104400:	e8 c7 41 00 00       	call   801085cc <seginit>
 // cprintf("\ncpu%d: starting xv6\n\n", cpu->id);
  picinit();       // interrupt controller
80104405:	e8 6d 06 00 00       	call   80104a77 <picinit>
  ioapicinit();    // another interrupt controller
8010440a:	e8 21 ee ff ff       	call   80103230 <ioapicinit>
  consoleinit();   // I/O devices & their interrupts
8010440f:	e8 05 c7 ff ff       	call   80100b19 <consoleinit>
  uartinit();      // serial port
80104414:	e8 0f 35 00 00       	call   80107928 <uartinit>
  pinit();         // process table
80104419:	e8 56 0b 00 00       	call   80104f74 <pinit>
  tvinit();        // trap vectors
8010441e:	e8 cf 30 00 00       	call   801074f2 <tvinit>
  binit();         // buffer cache
80104423:	e8 0c bc ff ff       	call   80100034 <binit>
 // cprintf("after b cache");
  fileinit();      // file table
80104428:	e8 a0 cb ff ff       	call   80100fcd <fileinit>
  //  cprintf("after f init");

  ideinit();       // disk
8010442d:	e8 e6 e9 ff ff       	call   80102e18 <ideinit>
   //   cprintf("after ide init");

  if(!ismp)
80104432:	a1 64 38 11 80       	mov    0x80113864,%eax
80104437:	85 c0                	test   %eax,%eax
80104439:	75 05                	jne    80104440 <main+0x75>
    timerinit();   // uniprocessor timer
8010443b:	e8 0f 30 00 00       	call   8010744f <timerinit>
  //  int a=3;
 //   if(a==4)
 startothers();   // start other processors
80104440:	e8 7f 00 00 00       	call   801044c4 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80104445:	83 ec 08             	sub    $0x8,%esp
80104448:	68 00 00 00 8e       	push   $0x8e000000
8010444d:	68 00 00 40 80       	push   $0x80400000
80104452:	e8 1d ef ff ff       	call   80103374 <kinit2>
80104457:	83 c4 10             	add    $0x10,%esp

  userinit();      // first user process
8010445a:	e8 39 0c 00 00       	call   80105098 <userinit>
  // Finish setting up this processor in mpmain.

  mpmain();
8010445f:	e8 1a 00 00 00       	call   8010447e <mpmain>

80104464 <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
80104464:	55                   	push   %ebp
80104465:	89 e5                	mov    %esp,%ebp
80104467:	83 ec 08             	sub    $0x8,%esp
  switchkvm(); 
8010446a:	e8 cc 47 00 00       	call   80108c3b <switchkvm>
  seginit();
8010446f:	e8 58 41 00 00       	call   801085cc <seginit>
  lapicinit();
80104474:	e8 41 f2 ff ff       	call   801036ba <lapicinit>
  mpmain();
80104479:	e8 00 00 00 00       	call   8010447e <mpmain>

8010447e <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
8010447e:	55                   	push   %ebp
8010447f:	89 e5                	mov    %esp,%ebp
80104481:	83 ec 08             	sub    $0x8,%esp
  cprintf("cpu%d: starting\n", cpu->id);
80104484:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010448a:	0f b6 00             	movzbl (%eax),%eax
8010448d:	0f b6 c0             	movzbl %al,%eax
80104490:	83 ec 08             	sub    $0x8,%esp
80104493:	50                   	push   %eax
80104494:	68 30 97 10 80       	push   $0x80109730
80104499:	e8 28 bf ff ff       	call   801003c6 <cprintf>
8010449e:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
801044a1:	e8 c2 31 00 00       	call   80107668 <idtinit>
  xchg(&cpu->started, 1); // tell startothers() we're up
801044a6:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801044ac:	05 a8 00 00 00       	add    $0xa8,%eax
801044b1:	83 ec 08             	sub    $0x8,%esp
801044b4:	6a 01                	push   $0x1
801044b6:	50                   	push   %eax
801044b7:	e8 f5 fe ff ff       	call   801043b1 <xchg>
801044bc:	83 c4 10             	add    $0x10,%esp
  scheduler();     // start running processes
801044bf:	e8 ab 11 00 00       	call   8010566f <scheduler>

801044c4 <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
801044c4:	55                   	push   %ebp
801044c5:	89 e5                	mov    %esp,%ebp
801044c7:	53                   	push   %ebx
801044c8:	83 ec 14             	sub    $0x14,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
801044cb:	68 00 70 00 00       	push   $0x7000
801044d0:	e8 cf fe ff ff       	call   801043a4 <p2v>
801044d5:	83 c4 04             	add    $0x4,%esp
801044d8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
801044db:	b8 8a 00 00 00       	mov    $0x8a,%eax
801044e0:	83 ec 04             	sub    $0x4,%esp
801044e3:	50                   	push   %eax
801044e4:	68 0c c5 10 80       	push   $0x8010c50c
801044e9:	ff 75 f0             	pushl  -0x10(%ebp)
801044ec:	e8 b5 19 00 00       	call   80105ea6 <memmove>
801044f1:	83 c4 10             	add    $0x10,%esp

  for(c = cpus; c < cpus+ncpu; c++){
801044f4:	c7 45 f4 80 38 11 80 	movl   $0x80113880,-0xc(%ebp)
801044fb:	e9 90 00 00 00       	jmp    80104590 <startothers+0xcc>
    if(c == cpus+cpunum())  // We've started already.
80104500:	e8 d3 f2 ff ff       	call   801037d8 <cpunum>
80104505:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
8010450b:	05 80 38 11 80       	add    $0x80113880,%eax
80104510:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80104513:	74 73                	je     80104588 <startothers+0xc4>
      continue;

    // Tell entryother.S what stack to use, where to enter, and what 
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
80104515:	e8 58 ef ff ff       	call   80103472 <kalloc>
8010451a:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
8010451d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104520:	83 e8 04             	sub    $0x4,%eax
80104523:	8b 55 ec             	mov    -0x14(%ebp),%edx
80104526:	81 c2 00 10 00 00    	add    $0x1000,%edx
8010452c:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
8010452e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104531:	83 e8 08             	sub    $0x8,%eax
80104534:	c7 00 64 44 10 80    	movl   $0x80104464,(%eax)
    *(int**)(code-12) = (void *) v2p(entrypgdir);
8010453a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010453d:	8d 58 f4             	lea    -0xc(%eax),%ebx
80104540:	83 ec 0c             	sub    $0xc,%esp
80104543:	68 00 b0 10 80       	push   $0x8010b000
80104548:	e8 4a fe ff ff       	call   80104397 <v2p>
8010454d:	83 c4 10             	add    $0x10,%esp
80104550:	89 03                	mov    %eax,(%ebx)

    lapicstartap(c->id, v2p(code));
80104552:	83 ec 0c             	sub    $0xc,%esp
80104555:	ff 75 f0             	pushl  -0x10(%ebp)
80104558:	e8 3a fe ff ff       	call   80104397 <v2p>
8010455d:	83 c4 10             	add    $0x10,%esp
80104560:	89 c2                	mov    %eax,%edx
80104562:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104565:	0f b6 00             	movzbl (%eax),%eax
80104568:	0f b6 c0             	movzbl %al,%eax
8010456b:	83 ec 08             	sub    $0x8,%esp
8010456e:	52                   	push   %edx
8010456f:	50                   	push   %eax
80104570:	e8 dd f2 ff ff       	call   80103852 <lapicstartap>
80104575:	83 c4 10             	add    $0x10,%esp

    // wait for cpu to finish mpmain()
    while(c->started == 0)
80104578:	90                   	nop
80104579:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010457c:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80104582:	85 c0                	test   %eax,%eax
80104584:	74 f3                	je     80104579 <startothers+0xb5>
80104586:	eb 01                	jmp    80104589 <startothers+0xc5>
  code = p2v(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
    if(c == cpus+cpunum())  // We've started already.
      continue;
80104588:	90                   	nop
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
80104589:	81 45 f4 bc 00 00 00 	addl   $0xbc,-0xc(%ebp)
80104590:	a1 60 3e 11 80       	mov    0x80113e60,%eax
80104595:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
8010459b:	05 80 38 11 80       	add    $0x80113880,%eax
801045a0:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801045a3:	0f 87 57 ff ff ff    	ja     80104500 <startothers+0x3c>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
      ;
  }
}
801045a9:	90                   	nop
801045aa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801045ad:	c9                   	leave  
801045ae:	c3                   	ret    

801045af <p2v>:
801045af:	55                   	push   %ebp
801045b0:	89 e5                	mov    %esp,%ebp
801045b2:	8b 45 08             	mov    0x8(%ebp),%eax
801045b5:	05 00 00 00 80       	add    $0x80000000,%eax
801045ba:	5d                   	pop    %ebp
801045bb:	c3                   	ret    

801045bc <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801045bc:	55                   	push   %ebp
801045bd:	89 e5                	mov    %esp,%ebp
801045bf:	83 ec 14             	sub    $0x14,%esp
801045c2:	8b 45 08             	mov    0x8(%ebp),%eax
801045c5:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801045c9:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801045cd:	89 c2                	mov    %eax,%edx
801045cf:	ec                   	in     (%dx),%al
801045d0:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801045d3:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801045d7:	c9                   	leave  
801045d8:	c3                   	ret    

801045d9 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801045d9:	55                   	push   %ebp
801045da:	89 e5                	mov    %esp,%ebp
801045dc:	83 ec 08             	sub    $0x8,%esp
801045df:	8b 55 08             	mov    0x8(%ebp),%edx
801045e2:	8b 45 0c             	mov    0xc(%ebp),%eax
801045e5:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801045e9:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801045ec:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801045f0:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801045f4:	ee                   	out    %al,(%dx)
}
801045f5:	90                   	nop
801045f6:	c9                   	leave  
801045f7:	c3                   	ret    

801045f8 <mpbcpu>:
int ncpu;
uchar ioapicid;

int
mpbcpu(void)
{
801045f8:	55                   	push   %ebp
801045f9:	89 e5                	mov    %esp,%ebp
  return bcpu-cpus;
801045fb:	a1 44 c6 10 80       	mov    0x8010c644,%eax
80104600:	89 c2                	mov    %eax,%edx
80104602:	b8 80 38 11 80       	mov    $0x80113880,%eax
80104607:	29 c2                	sub    %eax,%edx
80104609:	89 d0                	mov    %edx,%eax
8010460b:	c1 f8 02             	sar    $0x2,%eax
8010460e:	69 c0 cf 46 7d 67    	imul   $0x677d46cf,%eax,%eax
}
80104614:	5d                   	pop    %ebp
80104615:	c3                   	ret    

80104616 <sum>:

static uchar
sum(uchar *addr, int len)
{
80104616:	55                   	push   %ebp
80104617:	89 e5                	mov    %esp,%ebp
80104619:	83 ec 10             	sub    $0x10,%esp
  int i, sum;
  
  sum = 0;
8010461c:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(i=0; i<len; i++)
80104623:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
8010462a:	eb 15                	jmp    80104641 <sum+0x2b>
    sum += addr[i];
8010462c:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010462f:	8b 45 08             	mov    0x8(%ebp),%eax
80104632:	01 d0                	add    %edx,%eax
80104634:	0f b6 00             	movzbl (%eax),%eax
80104637:	0f b6 c0             	movzbl %al,%eax
8010463a:	01 45 f8             	add    %eax,-0x8(%ebp)
sum(uchar *addr, int len)
{
  int i, sum;
  
  sum = 0;
  for(i=0; i<len; i++)
8010463d:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80104641:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104644:	3b 45 0c             	cmp    0xc(%ebp),%eax
80104647:	7c e3                	jl     8010462c <sum+0x16>
    sum += addr[i];
  return sum;
80104649:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
8010464c:	c9                   	leave  
8010464d:	c3                   	ret    

8010464e <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
8010464e:	55                   	push   %ebp
8010464f:	89 e5                	mov    %esp,%ebp
80104651:	83 ec 18             	sub    $0x18,%esp
  uchar *e, *p, *addr;

  addr = p2v(a);
80104654:	ff 75 08             	pushl  0x8(%ebp)
80104657:	e8 53 ff ff ff       	call   801045af <p2v>
8010465c:	83 c4 04             	add    $0x4,%esp
8010465f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  e = addr+len;
80104662:	8b 55 0c             	mov    0xc(%ebp),%edx
80104665:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104668:	01 d0                	add    %edx,%eax
8010466a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(p = addr; p < e; p += sizeof(struct mp))
8010466d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104670:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104673:	eb 36                	jmp    801046ab <mpsearch1+0x5d>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80104675:	83 ec 04             	sub    $0x4,%esp
80104678:	6a 04                	push   $0x4
8010467a:	68 44 97 10 80       	push   $0x80109744
8010467f:	ff 75 f4             	pushl  -0xc(%ebp)
80104682:	e8 c7 17 00 00       	call   80105e4e <memcmp>
80104687:	83 c4 10             	add    $0x10,%esp
8010468a:	85 c0                	test   %eax,%eax
8010468c:	75 19                	jne    801046a7 <mpsearch1+0x59>
8010468e:	83 ec 08             	sub    $0x8,%esp
80104691:	6a 10                	push   $0x10
80104693:	ff 75 f4             	pushl  -0xc(%ebp)
80104696:	e8 7b ff ff ff       	call   80104616 <sum>
8010469b:	83 c4 10             	add    $0x10,%esp
8010469e:	84 c0                	test   %al,%al
801046a0:	75 05                	jne    801046a7 <mpsearch1+0x59>
      return (struct mp*)p;
801046a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046a5:	eb 11                	jmp    801046b8 <mpsearch1+0x6a>
{
  uchar *e, *p, *addr;

  addr = p2v(a);
  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
801046a7:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
801046ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046ae:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801046b1:	72 c2                	jb     80104675 <mpsearch1+0x27>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
      return (struct mp*)p;
  return 0;
801046b3:	b8 00 00 00 00       	mov    $0x0,%eax
}
801046b8:	c9                   	leave  
801046b9:	c3                   	ret    

801046ba <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
801046ba:	55                   	push   %ebp
801046bb:	89 e5                	mov    %esp,%ebp
801046bd:	83 ec 18             	sub    $0x18,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
801046c0:	c7 45 f4 00 04 00 80 	movl   $0x80000400,-0xc(%ebp)
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
801046c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046ca:	83 c0 0f             	add    $0xf,%eax
801046cd:	0f b6 00             	movzbl (%eax),%eax
801046d0:	0f b6 c0             	movzbl %al,%eax
801046d3:	c1 e0 08             	shl    $0x8,%eax
801046d6:	89 c2                	mov    %eax,%edx
801046d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046db:	83 c0 0e             	add    $0xe,%eax
801046de:	0f b6 00             	movzbl (%eax),%eax
801046e1:	0f b6 c0             	movzbl %al,%eax
801046e4:	09 d0                	or     %edx,%eax
801046e6:	c1 e0 04             	shl    $0x4,%eax
801046e9:	89 45 f0             	mov    %eax,-0x10(%ebp)
801046ec:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801046f0:	74 21                	je     80104713 <mpsearch+0x59>
    if((mp = mpsearch1(p, 1024)))
801046f2:	83 ec 08             	sub    $0x8,%esp
801046f5:	68 00 04 00 00       	push   $0x400
801046fa:	ff 75 f0             	pushl  -0x10(%ebp)
801046fd:	e8 4c ff ff ff       	call   8010464e <mpsearch1>
80104702:	83 c4 10             	add    $0x10,%esp
80104705:	89 45 ec             	mov    %eax,-0x14(%ebp)
80104708:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010470c:	74 51                	je     8010475f <mpsearch+0xa5>
      return mp;
8010470e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104711:	eb 61                	jmp    80104774 <mpsearch+0xba>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80104713:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104716:	83 c0 14             	add    $0x14,%eax
80104719:	0f b6 00             	movzbl (%eax),%eax
8010471c:	0f b6 c0             	movzbl %al,%eax
8010471f:	c1 e0 08             	shl    $0x8,%eax
80104722:	89 c2                	mov    %eax,%edx
80104724:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104727:	83 c0 13             	add    $0x13,%eax
8010472a:	0f b6 00             	movzbl (%eax),%eax
8010472d:	0f b6 c0             	movzbl %al,%eax
80104730:	09 d0                	or     %edx,%eax
80104732:	c1 e0 0a             	shl    $0xa,%eax
80104735:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((mp = mpsearch1(p-1024, 1024)))
80104738:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010473b:	2d 00 04 00 00       	sub    $0x400,%eax
80104740:	83 ec 08             	sub    $0x8,%esp
80104743:	68 00 04 00 00       	push   $0x400
80104748:	50                   	push   %eax
80104749:	e8 00 ff ff ff       	call   8010464e <mpsearch1>
8010474e:	83 c4 10             	add    $0x10,%esp
80104751:	89 45 ec             	mov    %eax,-0x14(%ebp)
80104754:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80104758:	74 05                	je     8010475f <mpsearch+0xa5>
      return mp;
8010475a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010475d:	eb 15                	jmp    80104774 <mpsearch+0xba>
  }
  return mpsearch1(0xF0000, 0x10000);
8010475f:	83 ec 08             	sub    $0x8,%esp
80104762:	68 00 00 01 00       	push   $0x10000
80104767:	68 00 00 0f 00       	push   $0xf0000
8010476c:	e8 dd fe ff ff       	call   8010464e <mpsearch1>
80104771:	83 c4 10             	add    $0x10,%esp
}
80104774:	c9                   	leave  
80104775:	c3                   	ret    

80104776 <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80104776:	55                   	push   %ebp
80104777:	89 e5                	mov    %esp,%ebp
80104779:	83 ec 18             	sub    $0x18,%esp
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
8010477c:	e8 39 ff ff ff       	call   801046ba <mpsearch>
80104781:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104784:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104788:	74 0a                	je     80104794 <mpconfig+0x1e>
8010478a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010478d:	8b 40 04             	mov    0x4(%eax),%eax
80104790:	85 c0                	test   %eax,%eax
80104792:	75 0a                	jne    8010479e <mpconfig+0x28>
    return 0;
80104794:	b8 00 00 00 00       	mov    $0x0,%eax
80104799:	e9 81 00 00 00       	jmp    8010481f <mpconfig+0xa9>
  conf = (struct mpconf*) p2v((uint) mp->physaddr);
8010479e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047a1:	8b 40 04             	mov    0x4(%eax),%eax
801047a4:	83 ec 0c             	sub    $0xc,%esp
801047a7:	50                   	push   %eax
801047a8:	e8 02 fe ff ff       	call   801045af <p2v>
801047ad:	83 c4 10             	add    $0x10,%esp
801047b0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
801047b3:	83 ec 04             	sub    $0x4,%esp
801047b6:	6a 04                	push   $0x4
801047b8:	68 49 97 10 80       	push   $0x80109749
801047bd:	ff 75 f0             	pushl  -0x10(%ebp)
801047c0:	e8 89 16 00 00       	call   80105e4e <memcmp>
801047c5:	83 c4 10             	add    $0x10,%esp
801047c8:	85 c0                	test   %eax,%eax
801047ca:	74 07                	je     801047d3 <mpconfig+0x5d>
    return 0;
801047cc:	b8 00 00 00 00       	mov    $0x0,%eax
801047d1:	eb 4c                	jmp    8010481f <mpconfig+0xa9>
  if(conf->version != 1 && conf->version != 4)
801047d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801047d6:	0f b6 40 06          	movzbl 0x6(%eax),%eax
801047da:	3c 01                	cmp    $0x1,%al
801047dc:	74 12                	je     801047f0 <mpconfig+0x7a>
801047de:	8b 45 f0             	mov    -0x10(%ebp),%eax
801047e1:	0f b6 40 06          	movzbl 0x6(%eax),%eax
801047e5:	3c 04                	cmp    $0x4,%al
801047e7:	74 07                	je     801047f0 <mpconfig+0x7a>
    return 0;
801047e9:	b8 00 00 00 00       	mov    $0x0,%eax
801047ee:	eb 2f                	jmp    8010481f <mpconfig+0xa9>
  if(sum((uchar*)conf, conf->length) != 0)
801047f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801047f3:	0f b7 40 04          	movzwl 0x4(%eax),%eax
801047f7:	0f b7 c0             	movzwl %ax,%eax
801047fa:	83 ec 08             	sub    $0x8,%esp
801047fd:	50                   	push   %eax
801047fe:	ff 75 f0             	pushl  -0x10(%ebp)
80104801:	e8 10 fe ff ff       	call   80104616 <sum>
80104806:	83 c4 10             	add    $0x10,%esp
80104809:	84 c0                	test   %al,%al
8010480b:	74 07                	je     80104814 <mpconfig+0x9e>
    return 0;
8010480d:	b8 00 00 00 00       	mov    $0x0,%eax
80104812:	eb 0b                	jmp    8010481f <mpconfig+0xa9>
  *pmp = mp;
80104814:	8b 45 08             	mov    0x8(%ebp),%eax
80104817:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010481a:	89 10                	mov    %edx,(%eax)
  return conf;
8010481c:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
8010481f:	c9                   	leave  
80104820:	c3                   	ret    

80104821 <mpinit>:

void
mpinit(void)
{
80104821:	55                   	push   %ebp
80104822:	89 e5                	mov    %esp,%ebp
80104824:	83 ec 28             	sub    $0x28,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
80104827:	c7 05 44 c6 10 80 80 	movl   $0x80113880,0x8010c644
8010482e:	38 11 80 
  if((conf = mpconfig(&mp)) == 0)
80104831:	83 ec 0c             	sub    $0xc,%esp
80104834:	8d 45 e0             	lea    -0x20(%ebp),%eax
80104837:	50                   	push   %eax
80104838:	e8 39 ff ff ff       	call   80104776 <mpconfig>
8010483d:	83 c4 10             	add    $0x10,%esp
80104840:	89 45 f0             	mov    %eax,-0x10(%ebp)
80104843:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104847:	0f 84 96 01 00 00    	je     801049e3 <mpinit+0x1c2>
    return;
  ismp = 1;
8010484d:	c7 05 64 38 11 80 01 	movl   $0x1,0x80113864
80104854:	00 00 00 
  lapic = (uint*)conf->lapicaddr;
80104857:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010485a:	8b 40 24             	mov    0x24(%eax),%eax
8010485d:	a3 3c 35 11 80       	mov    %eax,0x8011353c
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80104862:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104865:	83 c0 2c             	add    $0x2c,%eax
80104868:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010486b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010486e:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80104872:	0f b7 d0             	movzwl %ax,%edx
80104875:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104878:	01 d0                	add    %edx,%eax
8010487a:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010487d:	e9 f2 00 00 00       	jmp    80104974 <mpinit+0x153>
    switch(*p){
80104882:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104885:	0f b6 00             	movzbl (%eax),%eax
80104888:	0f b6 c0             	movzbl %al,%eax
8010488b:	83 f8 04             	cmp    $0x4,%eax
8010488e:	0f 87 bc 00 00 00    	ja     80104950 <mpinit+0x12f>
80104894:	8b 04 85 8c 97 10 80 	mov    -0x7fef6874(,%eax,4),%eax
8010489b:	ff e0                	jmp    *%eax
    case MPPROC:
      proc = (struct mpproc*)p;
8010489d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048a0:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if(ncpu != proc->apicid){
801048a3:	8b 45 e8             	mov    -0x18(%ebp),%eax
801048a6:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801048aa:	0f b6 d0             	movzbl %al,%edx
801048ad:	a1 60 3e 11 80       	mov    0x80113e60,%eax
801048b2:	39 c2                	cmp    %eax,%edx
801048b4:	74 2b                	je     801048e1 <mpinit+0xc0>
        cprintf("mpinit: ncpu=%d apicid=%d\n", ncpu, proc->apicid);
801048b6:	8b 45 e8             	mov    -0x18(%ebp),%eax
801048b9:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801048bd:	0f b6 d0             	movzbl %al,%edx
801048c0:	a1 60 3e 11 80       	mov    0x80113e60,%eax
801048c5:	83 ec 04             	sub    $0x4,%esp
801048c8:	52                   	push   %edx
801048c9:	50                   	push   %eax
801048ca:	68 4e 97 10 80       	push   $0x8010974e
801048cf:	e8 f2 ba ff ff       	call   801003c6 <cprintf>
801048d4:	83 c4 10             	add    $0x10,%esp
        ismp = 0;
801048d7:	c7 05 64 38 11 80 00 	movl   $0x0,0x80113864
801048de:	00 00 00 
      }
      if(proc->flags & MPBOOT)
801048e1:	8b 45 e8             	mov    -0x18(%ebp),%eax
801048e4:	0f b6 40 03          	movzbl 0x3(%eax),%eax
801048e8:	0f b6 c0             	movzbl %al,%eax
801048eb:	83 e0 02             	and    $0x2,%eax
801048ee:	85 c0                	test   %eax,%eax
801048f0:	74 15                	je     80104907 <mpinit+0xe6>
        bcpu = &cpus[ncpu];
801048f2:	a1 60 3e 11 80       	mov    0x80113e60,%eax
801048f7:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
801048fd:	05 80 38 11 80       	add    $0x80113880,%eax
80104902:	a3 44 c6 10 80       	mov    %eax,0x8010c644
      cpus[ncpu].id = ncpu;
80104907:	a1 60 3e 11 80       	mov    0x80113e60,%eax
8010490c:	8b 15 60 3e 11 80    	mov    0x80113e60,%edx
80104912:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80104918:	05 80 38 11 80       	add    $0x80113880,%eax
8010491d:	88 10                	mov    %dl,(%eax)
      ncpu++;
8010491f:	a1 60 3e 11 80       	mov    0x80113e60,%eax
80104924:	83 c0 01             	add    $0x1,%eax
80104927:	a3 60 3e 11 80       	mov    %eax,0x80113e60
      p += sizeof(struct mpproc);
8010492c:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
      continue;
80104930:	eb 42                	jmp    80104974 <mpinit+0x153>
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
80104932:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104935:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      ioapicid = ioapic->apicno;
80104938:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010493b:	0f b6 40 01          	movzbl 0x1(%eax),%eax
8010493f:	a2 60 38 11 80       	mov    %al,0x80113860
      p += sizeof(struct mpioapic);
80104944:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80104948:	eb 2a                	jmp    80104974 <mpinit+0x153>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
8010494a:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
8010494e:	eb 24                	jmp    80104974 <mpinit+0x153>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
80104950:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104953:	0f b6 00             	movzbl (%eax),%eax
80104956:	0f b6 c0             	movzbl %al,%eax
80104959:	83 ec 08             	sub    $0x8,%esp
8010495c:	50                   	push   %eax
8010495d:	68 6c 97 10 80       	push   $0x8010976c
80104962:	e8 5f ba ff ff       	call   801003c6 <cprintf>
80104967:	83 c4 10             	add    $0x10,%esp
      ismp = 0;
8010496a:	c7 05 64 38 11 80 00 	movl   $0x0,0x80113864
80104971:	00 00 00 
  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80104974:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104977:	3b 45 ec             	cmp    -0x14(%ebp),%eax
8010497a:	0f 82 02 ff ff ff    	jb     80104882 <mpinit+0x61>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
      ismp = 0;
    }
  }
  if(!ismp){
80104980:	a1 64 38 11 80       	mov    0x80113864,%eax
80104985:	85 c0                	test   %eax,%eax
80104987:	75 1d                	jne    801049a6 <mpinit+0x185>
    // Didn't like what we found; fall back to no MP.
    ncpu = 1;
80104989:	c7 05 60 3e 11 80 01 	movl   $0x1,0x80113e60
80104990:	00 00 00 
    lapic = 0;
80104993:	c7 05 3c 35 11 80 00 	movl   $0x0,0x8011353c
8010499a:	00 00 00 
    ioapicid = 0;
8010499d:	c6 05 60 38 11 80 00 	movb   $0x0,0x80113860
    return;
801049a4:	eb 3e                	jmp    801049e4 <mpinit+0x1c3>
  }

  if(mp->imcrp){
801049a6:	8b 45 e0             	mov    -0x20(%ebp),%eax
801049a9:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
801049ad:	84 c0                	test   %al,%al
801049af:	74 33                	je     801049e4 <mpinit+0x1c3>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
801049b1:	83 ec 08             	sub    $0x8,%esp
801049b4:	6a 70                	push   $0x70
801049b6:	6a 22                	push   $0x22
801049b8:	e8 1c fc ff ff       	call   801045d9 <outb>
801049bd:	83 c4 10             	add    $0x10,%esp
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
801049c0:	83 ec 0c             	sub    $0xc,%esp
801049c3:	6a 23                	push   $0x23
801049c5:	e8 f2 fb ff ff       	call   801045bc <inb>
801049ca:	83 c4 10             	add    $0x10,%esp
801049cd:	83 c8 01             	or     $0x1,%eax
801049d0:	0f b6 c0             	movzbl %al,%eax
801049d3:	83 ec 08             	sub    $0x8,%esp
801049d6:	50                   	push   %eax
801049d7:	6a 23                	push   $0x23
801049d9:	e8 fb fb ff ff       	call   801045d9 <outb>
801049de:	83 c4 10             	add    $0x10,%esp
801049e1:	eb 01                	jmp    801049e4 <mpinit+0x1c3>
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
801049e3:	90                   	nop
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
  }
}
801049e4:	c9                   	leave  
801049e5:	c3                   	ret    

801049e6 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801049e6:	55                   	push   %ebp
801049e7:	89 e5                	mov    %esp,%ebp
801049e9:	83 ec 08             	sub    $0x8,%esp
801049ec:	8b 55 08             	mov    0x8(%ebp),%edx
801049ef:	8b 45 0c             	mov    0xc(%ebp),%eax
801049f2:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801049f6:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801049f9:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801049fd:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80104a01:	ee                   	out    %al,(%dx)
}
80104a02:	90                   	nop
80104a03:	c9                   	leave  
80104a04:	c3                   	ret    

80104a05 <picsetmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static ushort irqmask = 0xFFFF & ~(1<<IRQ_SLAVE);

static void
picsetmask(ushort mask)
{
80104a05:	55                   	push   %ebp
80104a06:	89 e5                	mov    %esp,%ebp
80104a08:	83 ec 04             	sub    $0x4,%esp
80104a0b:	8b 45 08             	mov    0x8(%ebp),%eax
80104a0e:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  irqmask = mask;
80104a12:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80104a16:	66 a3 00 c0 10 80    	mov    %ax,0x8010c000
  outb(IO_PIC1+1, mask);
80104a1c:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80104a20:	0f b6 c0             	movzbl %al,%eax
80104a23:	50                   	push   %eax
80104a24:	6a 21                	push   $0x21
80104a26:	e8 bb ff ff ff       	call   801049e6 <outb>
80104a2b:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, mask >> 8);
80104a2e:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80104a32:	66 c1 e8 08          	shr    $0x8,%ax
80104a36:	0f b6 c0             	movzbl %al,%eax
80104a39:	50                   	push   %eax
80104a3a:	68 a1 00 00 00       	push   $0xa1
80104a3f:	e8 a2 ff ff ff       	call   801049e6 <outb>
80104a44:	83 c4 08             	add    $0x8,%esp
}
80104a47:	90                   	nop
80104a48:	c9                   	leave  
80104a49:	c3                   	ret    

80104a4a <picenable>:

void
picenable(int irq)
{
80104a4a:	55                   	push   %ebp
80104a4b:	89 e5                	mov    %esp,%ebp
  picsetmask(irqmask & ~(1<<irq));
80104a4d:	8b 45 08             	mov    0x8(%ebp),%eax
80104a50:	ba 01 00 00 00       	mov    $0x1,%edx
80104a55:	89 c1                	mov    %eax,%ecx
80104a57:	d3 e2                	shl    %cl,%edx
80104a59:	89 d0                	mov    %edx,%eax
80104a5b:	f7 d0                	not    %eax
80104a5d:	89 c2                	mov    %eax,%edx
80104a5f:	0f b7 05 00 c0 10 80 	movzwl 0x8010c000,%eax
80104a66:	21 d0                	and    %edx,%eax
80104a68:	0f b7 c0             	movzwl %ax,%eax
80104a6b:	50                   	push   %eax
80104a6c:	e8 94 ff ff ff       	call   80104a05 <picsetmask>
80104a71:	83 c4 04             	add    $0x4,%esp
}
80104a74:	90                   	nop
80104a75:	c9                   	leave  
80104a76:	c3                   	ret    

80104a77 <picinit>:

// Initialize the 8259A interrupt controllers.
void
picinit(void)
{
80104a77:	55                   	push   %ebp
80104a78:	89 e5                	mov    %esp,%ebp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80104a7a:	68 ff 00 00 00       	push   $0xff
80104a7f:	6a 21                	push   $0x21
80104a81:	e8 60 ff ff ff       	call   801049e6 <outb>
80104a86:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, 0xFF);
80104a89:	68 ff 00 00 00       	push   $0xff
80104a8e:	68 a1 00 00 00       	push   $0xa1
80104a93:	e8 4e ff ff ff       	call   801049e6 <outb>
80104a98:	83 c4 08             	add    $0x8,%esp

  // ICW1:  0001g0hi
  //    g:  0 = edge triggering, 1 = level triggering
  //    h:  0 = cascaded PICs, 1 = master only
  //    i:  0 = no ICW4, 1 = ICW4 required
  outb(IO_PIC1, 0x11);
80104a9b:	6a 11                	push   $0x11
80104a9d:	6a 20                	push   $0x20
80104a9f:	e8 42 ff ff ff       	call   801049e6 <outb>
80104aa4:	83 c4 08             	add    $0x8,%esp

  // ICW2:  Vector offset
  outb(IO_PIC1+1, T_IRQ0);
80104aa7:	6a 20                	push   $0x20
80104aa9:	6a 21                	push   $0x21
80104aab:	e8 36 ff ff ff       	call   801049e6 <outb>
80104ab0:	83 c4 08             	add    $0x8,%esp

  // ICW3:  (master PIC) bit mask of IR lines connected to slaves
  //        (slave PIC) 3-bit # of slave's connection to master
  outb(IO_PIC1+1, 1<<IRQ_SLAVE);
80104ab3:	6a 04                	push   $0x4
80104ab5:	6a 21                	push   $0x21
80104ab7:	e8 2a ff ff ff       	call   801049e6 <outb>
80104abc:	83 c4 08             	add    $0x8,%esp
  //    m:  0 = slave PIC, 1 = master PIC
  //      (ignored when b is 0, as the master/slave role
  //      can be hardwired).
  //    a:  1 = Automatic EOI mode
  //    p:  0 = MCS-80/85 mode, 1 = intel x86 mode
  outb(IO_PIC1+1, 0x3);
80104abf:	6a 03                	push   $0x3
80104ac1:	6a 21                	push   $0x21
80104ac3:	e8 1e ff ff ff       	call   801049e6 <outb>
80104ac8:	83 c4 08             	add    $0x8,%esp

  // Set up slave (8259A-2)
  outb(IO_PIC2, 0x11);                  // ICW1
80104acb:	6a 11                	push   $0x11
80104acd:	68 a0 00 00 00       	push   $0xa0
80104ad2:	e8 0f ff ff ff       	call   801049e6 <outb>
80104ad7:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, T_IRQ0 + 8);      // ICW2
80104ada:	6a 28                	push   $0x28
80104adc:	68 a1 00 00 00       	push   $0xa1
80104ae1:	e8 00 ff ff ff       	call   801049e6 <outb>
80104ae6:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, IRQ_SLAVE);           // ICW3
80104ae9:	6a 02                	push   $0x2
80104aeb:	68 a1 00 00 00       	push   $0xa1
80104af0:	e8 f1 fe ff ff       	call   801049e6 <outb>
80104af5:	83 c4 08             	add    $0x8,%esp
  // NB Automatic EOI mode doesn't tend to work on the slave.
  // Linux source code says it's "to be investigated".
  outb(IO_PIC2+1, 0x3);                 // ICW4
80104af8:	6a 03                	push   $0x3
80104afa:	68 a1 00 00 00       	push   $0xa1
80104aff:	e8 e2 fe ff ff       	call   801049e6 <outb>
80104b04:	83 c4 08             	add    $0x8,%esp

  // OCW3:  0ef01prs
  //   ef:  0x = NOP, 10 = clear specific mask, 11 = set specific mask
  //    p:  0 = no polling, 1 = polling mode
  //   rs:  0x = NOP, 10 = read IRR, 11 = read ISR
  outb(IO_PIC1, 0x68);             // clear specific mask
80104b07:	6a 68                	push   $0x68
80104b09:	6a 20                	push   $0x20
80104b0b:	e8 d6 fe ff ff       	call   801049e6 <outb>
80104b10:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC1, 0x0a);             // read IRR by default
80104b13:	6a 0a                	push   $0xa
80104b15:	6a 20                	push   $0x20
80104b17:	e8 ca fe ff ff       	call   801049e6 <outb>
80104b1c:	83 c4 08             	add    $0x8,%esp

  outb(IO_PIC2, 0x68);             // OCW3
80104b1f:	6a 68                	push   $0x68
80104b21:	68 a0 00 00 00       	push   $0xa0
80104b26:	e8 bb fe ff ff       	call   801049e6 <outb>
80104b2b:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2, 0x0a);             // OCW3
80104b2e:	6a 0a                	push   $0xa
80104b30:	68 a0 00 00 00       	push   $0xa0
80104b35:	e8 ac fe ff ff       	call   801049e6 <outb>
80104b3a:	83 c4 08             	add    $0x8,%esp

  if(irqmask != 0xFFFF)
80104b3d:	0f b7 05 00 c0 10 80 	movzwl 0x8010c000,%eax
80104b44:	66 83 f8 ff          	cmp    $0xffff,%ax
80104b48:	74 13                	je     80104b5d <picinit+0xe6>
    picsetmask(irqmask);
80104b4a:	0f b7 05 00 c0 10 80 	movzwl 0x8010c000,%eax
80104b51:	0f b7 c0             	movzwl %ax,%eax
80104b54:	50                   	push   %eax
80104b55:	e8 ab fe ff ff       	call   80104a05 <picsetmask>
80104b5a:	83 c4 04             	add    $0x4,%esp
}
80104b5d:	90                   	nop
80104b5e:	c9                   	leave  
80104b5f:	c3                   	ret    

80104b60 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80104b60:	55                   	push   %ebp
80104b61:	89 e5                	mov    %esp,%ebp
80104b63:	83 ec 18             	sub    $0x18,%esp
  struct pipe *p;

  p = 0;
80104b66:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
80104b6d:	8b 45 0c             	mov    0xc(%ebp),%eax
80104b70:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80104b76:	8b 45 0c             	mov    0xc(%ebp),%eax
80104b79:	8b 10                	mov    (%eax),%edx
80104b7b:	8b 45 08             	mov    0x8(%ebp),%eax
80104b7e:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80104b80:	e8 66 c4 ff ff       	call   80100feb <filealloc>
80104b85:	89 c2                	mov    %eax,%edx
80104b87:	8b 45 08             	mov    0x8(%ebp),%eax
80104b8a:	89 10                	mov    %edx,(%eax)
80104b8c:	8b 45 08             	mov    0x8(%ebp),%eax
80104b8f:	8b 00                	mov    (%eax),%eax
80104b91:	85 c0                	test   %eax,%eax
80104b93:	0f 84 cb 00 00 00    	je     80104c64 <pipealloc+0x104>
80104b99:	e8 4d c4 ff ff       	call   80100feb <filealloc>
80104b9e:	89 c2                	mov    %eax,%edx
80104ba0:	8b 45 0c             	mov    0xc(%ebp),%eax
80104ba3:	89 10                	mov    %edx,(%eax)
80104ba5:	8b 45 0c             	mov    0xc(%ebp),%eax
80104ba8:	8b 00                	mov    (%eax),%eax
80104baa:	85 c0                	test   %eax,%eax
80104bac:	0f 84 b2 00 00 00    	je     80104c64 <pipealloc+0x104>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80104bb2:	e8 bb e8 ff ff       	call   80103472 <kalloc>
80104bb7:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104bba:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104bbe:	0f 84 9f 00 00 00    	je     80104c63 <pipealloc+0x103>
    goto bad;
  p->readopen = 1;
80104bc4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bc7:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80104bce:	00 00 00 
  p->writeopen = 1;
80104bd1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bd4:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80104bdb:	00 00 00 
  p->nwrite = 0;
80104bde:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104be1:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80104be8:	00 00 00 
  p->nread = 0;
80104beb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bee:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80104bf5:	00 00 00 
  initlock(&p->lock, "pipe");
80104bf8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bfb:	83 ec 08             	sub    $0x8,%esp
80104bfe:	68 a0 97 10 80       	push   $0x801097a0
80104c03:	50                   	push   %eax
80104c04:	e8 59 0f 00 00       	call   80105b62 <initlock>
80104c09:	83 c4 10             	add    $0x10,%esp
  (*f0)->type = FD_PIPE;
80104c0c:	8b 45 08             	mov    0x8(%ebp),%eax
80104c0f:	8b 00                	mov    (%eax),%eax
80104c11:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80104c17:	8b 45 08             	mov    0x8(%ebp),%eax
80104c1a:	8b 00                	mov    (%eax),%eax
80104c1c:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80104c20:	8b 45 08             	mov    0x8(%ebp),%eax
80104c23:	8b 00                	mov    (%eax),%eax
80104c25:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80104c29:	8b 45 08             	mov    0x8(%ebp),%eax
80104c2c:	8b 00                	mov    (%eax),%eax
80104c2e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104c31:	89 50 0a             	mov    %edx,0xa(%eax)
  (*f1)->type = FD_PIPE;
80104c34:	8b 45 0c             	mov    0xc(%ebp),%eax
80104c37:	8b 00                	mov    (%eax),%eax
80104c39:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80104c3f:	8b 45 0c             	mov    0xc(%ebp),%eax
80104c42:	8b 00                	mov    (%eax),%eax
80104c44:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80104c48:	8b 45 0c             	mov    0xc(%ebp),%eax
80104c4b:	8b 00                	mov    (%eax),%eax
80104c4d:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
80104c51:	8b 45 0c             	mov    0xc(%ebp),%eax
80104c54:	8b 00                	mov    (%eax),%eax
80104c56:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104c59:	89 50 0a             	mov    %edx,0xa(%eax)
  return 0;
80104c5c:	b8 00 00 00 00       	mov    $0x0,%eax
80104c61:	eb 4e                	jmp    80104cb1 <pipealloc+0x151>
  p = 0;
  *f0 = *f1 = 0;
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
    goto bad;
80104c63:	90                   	nop
  (*f1)->pipe = p;
  return 0;

//PAGEBREAK: 20
 bad:
  if(p)
80104c64:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104c68:	74 0e                	je     80104c78 <pipealloc+0x118>
    kfree((char*)p);
80104c6a:	83 ec 0c             	sub    $0xc,%esp
80104c6d:	ff 75 f4             	pushl  -0xc(%ebp)
80104c70:	e8 60 e7 ff ff       	call   801033d5 <kfree>
80104c75:	83 c4 10             	add    $0x10,%esp
  if(*f0)
80104c78:	8b 45 08             	mov    0x8(%ebp),%eax
80104c7b:	8b 00                	mov    (%eax),%eax
80104c7d:	85 c0                	test   %eax,%eax
80104c7f:	74 11                	je     80104c92 <pipealloc+0x132>
    fileclose(*f0);
80104c81:	8b 45 08             	mov    0x8(%ebp),%eax
80104c84:	8b 00                	mov    (%eax),%eax
80104c86:	83 ec 0c             	sub    $0xc,%esp
80104c89:	50                   	push   %eax
80104c8a:	e8 1a c4 ff ff       	call   801010a9 <fileclose>
80104c8f:	83 c4 10             	add    $0x10,%esp
  if(*f1)
80104c92:	8b 45 0c             	mov    0xc(%ebp),%eax
80104c95:	8b 00                	mov    (%eax),%eax
80104c97:	85 c0                	test   %eax,%eax
80104c99:	74 11                	je     80104cac <pipealloc+0x14c>
    fileclose(*f1);
80104c9b:	8b 45 0c             	mov    0xc(%ebp),%eax
80104c9e:	8b 00                	mov    (%eax),%eax
80104ca0:	83 ec 0c             	sub    $0xc,%esp
80104ca3:	50                   	push   %eax
80104ca4:	e8 00 c4 ff ff       	call   801010a9 <fileclose>
80104ca9:	83 c4 10             	add    $0x10,%esp
  return -1;
80104cac:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104cb1:	c9                   	leave  
80104cb2:	c3                   	ret    

80104cb3 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
80104cb3:	55                   	push   %ebp
80104cb4:	89 e5                	mov    %esp,%ebp
80104cb6:	83 ec 08             	sub    $0x8,%esp
  acquire(&p->lock);
80104cb9:	8b 45 08             	mov    0x8(%ebp),%eax
80104cbc:	83 ec 0c             	sub    $0xc,%esp
80104cbf:	50                   	push   %eax
80104cc0:	e8 bf 0e 00 00       	call   80105b84 <acquire>
80104cc5:	83 c4 10             	add    $0x10,%esp
  if(writable){
80104cc8:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104ccc:	74 23                	je     80104cf1 <pipeclose+0x3e>
    p->writeopen = 0;
80104cce:	8b 45 08             	mov    0x8(%ebp),%eax
80104cd1:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
80104cd8:	00 00 00 
    wakeup(&p->nread);
80104cdb:	8b 45 08             	mov    0x8(%ebp),%eax
80104cde:	05 34 02 00 00       	add    $0x234,%eax
80104ce3:	83 ec 0c             	sub    $0xc,%esp
80104ce6:	50                   	push   %eax
80104ce7:	e8 8a 0c 00 00       	call   80105976 <wakeup>
80104cec:	83 c4 10             	add    $0x10,%esp
80104cef:	eb 21                	jmp    80104d12 <pipeclose+0x5f>
  } else {
    p->readopen = 0;
80104cf1:	8b 45 08             	mov    0x8(%ebp),%eax
80104cf4:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
80104cfb:	00 00 00 
    wakeup(&p->nwrite);
80104cfe:	8b 45 08             	mov    0x8(%ebp),%eax
80104d01:	05 38 02 00 00       	add    $0x238,%eax
80104d06:	83 ec 0c             	sub    $0xc,%esp
80104d09:	50                   	push   %eax
80104d0a:	e8 67 0c 00 00       	call   80105976 <wakeup>
80104d0f:	83 c4 10             	add    $0x10,%esp
  }
  if(p->readopen == 0 && p->writeopen == 0){
80104d12:	8b 45 08             	mov    0x8(%ebp),%eax
80104d15:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80104d1b:	85 c0                	test   %eax,%eax
80104d1d:	75 2c                	jne    80104d4b <pipeclose+0x98>
80104d1f:	8b 45 08             	mov    0x8(%ebp),%eax
80104d22:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80104d28:	85 c0                	test   %eax,%eax
80104d2a:	75 1f                	jne    80104d4b <pipeclose+0x98>
    release(&p->lock);
80104d2c:	8b 45 08             	mov    0x8(%ebp),%eax
80104d2f:	83 ec 0c             	sub    $0xc,%esp
80104d32:	50                   	push   %eax
80104d33:	e8 b3 0e 00 00       	call   80105beb <release>
80104d38:	83 c4 10             	add    $0x10,%esp
    kfree((char*)p);
80104d3b:	83 ec 0c             	sub    $0xc,%esp
80104d3e:	ff 75 08             	pushl  0x8(%ebp)
80104d41:	e8 8f e6 ff ff       	call   801033d5 <kfree>
80104d46:	83 c4 10             	add    $0x10,%esp
80104d49:	eb 0f                	jmp    80104d5a <pipeclose+0xa7>
  } else
    release(&p->lock);
80104d4b:	8b 45 08             	mov    0x8(%ebp),%eax
80104d4e:	83 ec 0c             	sub    $0xc,%esp
80104d51:	50                   	push   %eax
80104d52:	e8 94 0e 00 00       	call   80105beb <release>
80104d57:	83 c4 10             	add    $0x10,%esp
}
80104d5a:	90                   	nop
80104d5b:	c9                   	leave  
80104d5c:	c3                   	ret    

80104d5d <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
80104d5d:	55                   	push   %ebp
80104d5e:	89 e5                	mov    %esp,%ebp
80104d60:	83 ec 18             	sub    $0x18,%esp
  int i;

  acquire(&p->lock);
80104d63:	8b 45 08             	mov    0x8(%ebp),%eax
80104d66:	83 ec 0c             	sub    $0xc,%esp
80104d69:	50                   	push   %eax
80104d6a:	e8 15 0e 00 00       	call   80105b84 <acquire>
80104d6f:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++){
80104d72:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104d79:	e9 ad 00 00 00       	jmp    80104e2b <pipewrite+0xce>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || proc->killed){
80104d7e:	8b 45 08             	mov    0x8(%ebp),%eax
80104d81:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80104d87:	85 c0                	test   %eax,%eax
80104d89:	74 0d                	je     80104d98 <pipewrite+0x3b>
80104d8b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d91:	8b 40 24             	mov    0x24(%eax),%eax
80104d94:	85 c0                	test   %eax,%eax
80104d96:	74 19                	je     80104db1 <pipewrite+0x54>
        release(&p->lock);
80104d98:	8b 45 08             	mov    0x8(%ebp),%eax
80104d9b:	83 ec 0c             	sub    $0xc,%esp
80104d9e:	50                   	push   %eax
80104d9f:	e8 47 0e 00 00       	call   80105beb <release>
80104da4:	83 c4 10             	add    $0x10,%esp
        return -1;
80104da7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104dac:	e9 a8 00 00 00       	jmp    80104e59 <pipewrite+0xfc>
      }
      wakeup(&p->nread);
80104db1:	8b 45 08             	mov    0x8(%ebp),%eax
80104db4:	05 34 02 00 00       	add    $0x234,%eax
80104db9:	83 ec 0c             	sub    $0xc,%esp
80104dbc:	50                   	push   %eax
80104dbd:	e8 b4 0b 00 00       	call   80105976 <wakeup>
80104dc2:	83 c4 10             	add    $0x10,%esp
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
80104dc5:	8b 45 08             	mov    0x8(%ebp),%eax
80104dc8:	8b 55 08             	mov    0x8(%ebp),%edx
80104dcb:	81 c2 38 02 00 00    	add    $0x238,%edx
80104dd1:	83 ec 08             	sub    $0x8,%esp
80104dd4:	50                   	push   %eax
80104dd5:	52                   	push   %edx
80104dd6:	e8 b0 0a 00 00       	call   8010588b <sleep>
80104ddb:	83 c4 10             	add    $0x10,%esp
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80104dde:	8b 45 08             	mov    0x8(%ebp),%eax
80104de1:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
80104de7:	8b 45 08             	mov    0x8(%ebp),%eax
80104dea:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80104df0:	05 00 02 00 00       	add    $0x200,%eax
80104df5:	39 c2                	cmp    %eax,%edx
80104df7:	74 85                	je     80104d7e <pipewrite+0x21>
        return -1;
      }
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
80104df9:	8b 45 08             	mov    0x8(%ebp),%eax
80104dfc:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104e02:	8d 48 01             	lea    0x1(%eax),%ecx
80104e05:	8b 55 08             	mov    0x8(%ebp),%edx
80104e08:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
80104e0e:	25 ff 01 00 00       	and    $0x1ff,%eax
80104e13:	89 c1                	mov    %eax,%ecx
80104e15:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104e18:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e1b:	01 d0                	add    %edx,%eax
80104e1d:	0f b6 10             	movzbl (%eax),%edx
80104e20:	8b 45 08             	mov    0x8(%ebp),%eax
80104e23:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
pipewrite(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
80104e27:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104e2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e2e:	3b 45 10             	cmp    0x10(%ebp),%eax
80104e31:	7c ab                	jl     80104dde <pipewrite+0x81>
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80104e33:	8b 45 08             	mov    0x8(%ebp),%eax
80104e36:	05 34 02 00 00       	add    $0x234,%eax
80104e3b:	83 ec 0c             	sub    $0xc,%esp
80104e3e:	50                   	push   %eax
80104e3f:	e8 32 0b 00 00       	call   80105976 <wakeup>
80104e44:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80104e47:	8b 45 08             	mov    0x8(%ebp),%eax
80104e4a:	83 ec 0c             	sub    $0xc,%esp
80104e4d:	50                   	push   %eax
80104e4e:	e8 98 0d 00 00       	call   80105beb <release>
80104e53:	83 c4 10             	add    $0x10,%esp
  return n;
80104e56:	8b 45 10             	mov    0x10(%ebp),%eax
}
80104e59:	c9                   	leave  
80104e5a:	c3                   	ret    

80104e5b <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
80104e5b:	55                   	push   %ebp
80104e5c:	89 e5                	mov    %esp,%ebp
80104e5e:	53                   	push   %ebx
80104e5f:	83 ec 14             	sub    $0x14,%esp
  int i;

  acquire(&p->lock);
80104e62:	8b 45 08             	mov    0x8(%ebp),%eax
80104e65:	83 ec 0c             	sub    $0xc,%esp
80104e68:	50                   	push   %eax
80104e69:	e8 16 0d 00 00       	call   80105b84 <acquire>
80104e6e:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80104e71:	eb 3f                	jmp    80104eb2 <piperead+0x57>
    if(proc->killed){
80104e73:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104e79:	8b 40 24             	mov    0x24(%eax),%eax
80104e7c:	85 c0                	test   %eax,%eax
80104e7e:	74 19                	je     80104e99 <piperead+0x3e>
      release(&p->lock);
80104e80:	8b 45 08             	mov    0x8(%ebp),%eax
80104e83:	83 ec 0c             	sub    $0xc,%esp
80104e86:	50                   	push   %eax
80104e87:	e8 5f 0d 00 00       	call   80105beb <release>
80104e8c:	83 c4 10             	add    $0x10,%esp
      return -1;
80104e8f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104e94:	e9 bf 00 00 00       	jmp    80104f58 <piperead+0xfd>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
80104e99:	8b 45 08             	mov    0x8(%ebp),%eax
80104e9c:	8b 55 08             	mov    0x8(%ebp),%edx
80104e9f:	81 c2 34 02 00 00    	add    $0x234,%edx
80104ea5:	83 ec 08             	sub    $0x8,%esp
80104ea8:	50                   	push   %eax
80104ea9:	52                   	push   %edx
80104eaa:	e8 dc 09 00 00       	call   8010588b <sleep>
80104eaf:	83 c4 10             	add    $0x10,%esp
piperead(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80104eb2:	8b 45 08             	mov    0x8(%ebp),%eax
80104eb5:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80104ebb:	8b 45 08             	mov    0x8(%ebp),%eax
80104ebe:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104ec4:	39 c2                	cmp    %eax,%edx
80104ec6:	75 0d                	jne    80104ed5 <piperead+0x7a>
80104ec8:	8b 45 08             	mov    0x8(%ebp),%eax
80104ecb:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80104ed1:	85 c0                	test   %eax,%eax
80104ed3:	75 9e                	jne    80104e73 <piperead+0x18>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80104ed5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104edc:	eb 49                	jmp    80104f27 <piperead+0xcc>
    if(p->nread == p->nwrite)
80104ede:	8b 45 08             	mov    0x8(%ebp),%eax
80104ee1:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80104ee7:	8b 45 08             	mov    0x8(%ebp),%eax
80104eea:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104ef0:	39 c2                	cmp    %eax,%edx
80104ef2:	74 3d                	je     80104f31 <piperead+0xd6>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
80104ef4:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104ef7:	8b 45 0c             	mov    0xc(%ebp),%eax
80104efa:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80104efd:	8b 45 08             	mov    0x8(%ebp),%eax
80104f00:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80104f06:	8d 48 01             	lea    0x1(%eax),%ecx
80104f09:	8b 55 08             	mov    0x8(%ebp),%edx
80104f0c:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
80104f12:	25 ff 01 00 00       	and    $0x1ff,%eax
80104f17:	89 c2                	mov    %eax,%edx
80104f19:	8b 45 08             	mov    0x8(%ebp),%eax
80104f1c:	0f b6 44 10 34       	movzbl 0x34(%eax,%edx,1),%eax
80104f21:	88 03                	mov    %al,(%ebx)
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80104f23:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104f27:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f2a:	3b 45 10             	cmp    0x10(%ebp),%eax
80104f2d:	7c af                	jl     80104ede <piperead+0x83>
80104f2f:	eb 01                	jmp    80104f32 <piperead+0xd7>
    if(p->nread == p->nwrite)
      break;
80104f31:	90                   	nop
    addr[i] = p->data[p->nread++ % PIPESIZE];
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
80104f32:	8b 45 08             	mov    0x8(%ebp),%eax
80104f35:	05 38 02 00 00       	add    $0x238,%eax
80104f3a:	83 ec 0c             	sub    $0xc,%esp
80104f3d:	50                   	push   %eax
80104f3e:	e8 33 0a 00 00       	call   80105976 <wakeup>
80104f43:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80104f46:	8b 45 08             	mov    0x8(%ebp),%eax
80104f49:	83 ec 0c             	sub    $0xc,%esp
80104f4c:	50                   	push   %eax
80104f4d:	e8 99 0c 00 00       	call   80105beb <release>
80104f52:	83 c4 10             	add    $0x10,%esp
  return i;
80104f55:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104f58:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104f5b:	c9                   	leave  
80104f5c:	c3                   	ret    

80104f5d <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80104f5d:	55                   	push   %ebp
80104f5e:	89 e5                	mov    %esp,%ebp
80104f60:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104f63:	9c                   	pushf  
80104f64:	58                   	pop    %eax
80104f65:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80104f68:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104f6b:	c9                   	leave  
80104f6c:	c3                   	ret    

80104f6d <sti>:
  asm volatile("cli");
}

static inline void
sti(void)
{
80104f6d:	55                   	push   %ebp
80104f6e:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80104f70:	fb                   	sti    
}
80104f71:	90                   	nop
80104f72:	5d                   	pop    %ebp
80104f73:	c3                   	ret    

80104f74 <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
80104f74:	55                   	push   %ebp
80104f75:	89 e5                	mov    %esp,%ebp
80104f77:	83 ec 08             	sub    $0x8,%esp
  initlock(&ptable.lock, "ptable");
80104f7a:	83 ec 08             	sub    $0x8,%esp
80104f7d:	68 a5 97 10 80       	push   $0x801097a5
80104f82:	68 80 3e 11 80       	push   $0x80113e80
80104f87:	e8 d6 0b 00 00       	call   80105b62 <initlock>
80104f8c:	83 c4 10             	add    $0x10,%esp
}
80104f8f:	90                   	nop
80104f90:	c9                   	leave  
80104f91:	c3                   	ret    

80104f92 <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
80104f92:	55                   	push   %ebp
80104f93:	89 e5                	mov    %esp,%ebp
80104f95:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
80104f98:	83 ec 0c             	sub    $0xc,%esp
80104f9b:	68 80 3e 11 80       	push   $0x80113e80
80104fa0:	e8 df 0b 00 00       	call   80105b84 <acquire>
80104fa5:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104fa8:	c7 45 f4 b4 3e 11 80 	movl   $0x80113eb4,-0xc(%ebp)
80104faf:	eb 0e                	jmp    80104fbf <allocproc+0x2d>
    if(p->state == UNUSED)
80104fb1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104fb4:	8b 40 0c             	mov    0xc(%eax),%eax
80104fb7:	85 c0                	test   %eax,%eax
80104fb9:	74 27                	je     80104fe2 <allocproc+0x50>
{
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104fbb:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80104fbf:	81 7d f4 b4 5d 11 80 	cmpl   $0x80115db4,-0xc(%ebp)
80104fc6:	72 e9                	jb     80104fb1 <allocproc+0x1f>
    if(p->state == UNUSED)
      goto found;
  release(&ptable.lock);
80104fc8:	83 ec 0c             	sub    $0xc,%esp
80104fcb:	68 80 3e 11 80       	push   $0x80113e80
80104fd0:	e8 16 0c 00 00       	call   80105beb <release>
80104fd5:	83 c4 10             	add    $0x10,%esp
  return 0;
80104fd8:	b8 00 00 00 00       	mov    $0x0,%eax
80104fdd:	e9 b4 00 00 00       	jmp    80105096 <allocproc+0x104>
  char *sp;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
    if(p->state == UNUSED)
      goto found;
80104fe2:	90                   	nop
  release(&ptable.lock);
  return 0;

found:
  p->state = EMBRYO;
80104fe3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104fe6:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
80104fed:	a1 04 c0 10 80       	mov    0x8010c004,%eax
80104ff2:	8d 50 01             	lea    0x1(%eax),%edx
80104ff5:	89 15 04 c0 10 80    	mov    %edx,0x8010c004
80104ffb:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104ffe:	89 42 10             	mov    %eax,0x10(%edx)
  release(&ptable.lock);
80105001:	83 ec 0c             	sub    $0xc,%esp
80105004:	68 80 3e 11 80       	push   $0x80113e80
80105009:	e8 dd 0b 00 00       	call   80105beb <release>
8010500e:	83 c4 10             	add    $0x10,%esp

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
80105011:	e8 5c e4 ff ff       	call   80103472 <kalloc>
80105016:	89 c2                	mov    %eax,%edx
80105018:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010501b:	89 50 08             	mov    %edx,0x8(%eax)
8010501e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105021:	8b 40 08             	mov    0x8(%eax),%eax
80105024:	85 c0                	test   %eax,%eax
80105026:	75 11                	jne    80105039 <allocproc+0xa7>
    p->state = UNUSED;
80105028:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010502b:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
80105032:	b8 00 00 00 00       	mov    $0x0,%eax
80105037:	eb 5d                	jmp    80105096 <allocproc+0x104>
  }
  sp = p->kstack + KSTACKSIZE;
80105039:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010503c:	8b 40 08             	mov    0x8(%eax),%eax
8010503f:	05 00 10 00 00       	add    $0x1000,%eax
80105044:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  // Leave room for trap frame.
  sp -= sizeof *p->tf;
80105047:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
8010504b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010504e:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105051:	89 50 18             	mov    %edx,0x18(%eax)
  
  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
80105054:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
80105058:	ba ac 74 10 80       	mov    $0x801074ac,%edx
8010505d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105060:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
80105062:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
80105066:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105069:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010506c:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
8010506f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105072:	8b 40 1c             	mov    0x1c(%eax),%eax
80105075:	83 ec 04             	sub    $0x4,%esp
80105078:	6a 14                	push   $0x14
8010507a:	6a 00                	push   $0x0
8010507c:	50                   	push   %eax
8010507d:	e8 65 0d 00 00       	call   80105de7 <memset>
80105082:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
80105085:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105088:	8b 40 1c             	mov    0x1c(%eax),%eax
8010508b:	ba 0b 58 10 80       	mov    $0x8010580b,%edx
80105090:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
80105093:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105096:	c9                   	leave  
80105097:	c3                   	ret    

80105098 <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
80105098:	55                   	push   %ebp
80105099:	89 e5                	mov    %esp,%ebp
8010509b:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];
  
  p = allocproc();
8010509e:	e8 ef fe ff ff       	call   80104f92 <allocproc>
801050a3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  initproc = p;
801050a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050a9:	a3 48 c6 10 80       	mov    %eax,0x8010c648
  if((p->pgdir = setupkvm()) == 0)
801050ae:	e8 be 3a 00 00       	call   80108b71 <setupkvm>
801050b3:	89 c2                	mov    %eax,%edx
801050b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050b8:	89 50 04             	mov    %edx,0x4(%eax)
801050bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050be:	8b 40 04             	mov    0x4(%eax),%eax
801050c1:	85 c0                	test   %eax,%eax
801050c3:	75 0d                	jne    801050d2 <userinit+0x3a>
    panic("userinit: out of memory?");
801050c5:	83 ec 0c             	sub    $0xc,%esp
801050c8:	68 ac 97 10 80       	push   $0x801097ac
801050cd:	e8 94 b4 ff ff       	call   80100566 <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
801050d2:	ba 2c 00 00 00       	mov    $0x2c,%edx
801050d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050da:	8b 40 04             	mov    0x4(%eax),%eax
801050dd:	83 ec 04             	sub    $0x4,%esp
801050e0:	52                   	push   %edx
801050e1:	68 e0 c4 10 80       	push   $0x8010c4e0
801050e6:	50                   	push   %eax
801050e7:	e8 df 3c 00 00       	call   80108dcb <inituvm>
801050ec:	83 c4 10             	add    $0x10,%esp
  p->sz = PGSIZE;
801050ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050f2:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
801050f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050fb:	8b 40 18             	mov    0x18(%eax),%eax
801050fe:	83 ec 04             	sub    $0x4,%esp
80105101:	6a 4c                	push   $0x4c
80105103:	6a 00                	push   $0x0
80105105:	50                   	push   %eax
80105106:	e8 dc 0c 00 00       	call   80105de7 <memset>
8010510b:	83 c4 10             	add    $0x10,%esp
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
8010510e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105111:	8b 40 18             	mov    0x18(%eax),%eax
80105114:	66 c7 40 3c 23 00    	movw   $0x23,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
8010511a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010511d:	8b 40 18             	mov    0x18(%eax),%eax
80105120:	66 c7 40 2c 2b 00    	movw   $0x2b,0x2c(%eax)
  p->tf->es = p->tf->ds;
80105126:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105129:	8b 40 18             	mov    0x18(%eax),%eax
8010512c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010512f:	8b 52 18             	mov    0x18(%edx),%edx
80105132:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80105136:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
8010513a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010513d:	8b 40 18             	mov    0x18(%eax),%eax
80105140:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105143:	8b 52 18             	mov    0x18(%edx),%edx
80105146:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
8010514a:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
8010514e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105151:	8b 40 18             	mov    0x18(%eax),%eax
80105154:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
8010515b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010515e:	8b 40 18             	mov    0x18(%eax),%eax
80105161:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
80105168:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010516b:	8b 40 18             	mov    0x18(%eax),%eax
8010516e:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
80105175:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105178:	83 c0 6c             	add    $0x6c,%eax
8010517b:	83 ec 04             	sub    $0x4,%esp
8010517e:	6a 10                	push   $0x10
80105180:	68 c5 97 10 80       	push   $0x801097c5
80105185:	50                   	push   %eax
80105186:	e8 5f 0e 00 00       	call   80105fea <safestrcpy>
8010518b:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
8010518e:	83 ec 0c             	sub    $0xc,%esp
80105191:	68 ce 97 10 80       	push   $0x801097ce
80105196:	e8 60 db ff ff       	call   80102cfb <namei>
8010519b:	83 c4 10             	add    $0x10,%esp
8010519e:	89 c2                	mov    %eax,%edx
801051a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051a3:	89 50 68             	mov    %edx,0x68(%eax)

  
 // cprintf("userinit-root inode addr %d \n",p->cwd);
  

  p->state = RUNNABLE;
801051a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051a9:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
}
801051b0:	90                   	nop
801051b1:	c9                   	leave  
801051b2:	c3                   	ret    

801051b3 <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
801051b3:	55                   	push   %ebp
801051b4:	89 e5                	mov    %esp,%ebp
801051b6:	83 ec 18             	sub    $0x18,%esp
  uint sz;
  
  sz = proc->sz;
801051b9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801051bf:	8b 00                	mov    (%eax),%eax
801051c1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
801051c4:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801051c8:	7e 31                	jle    801051fb <growproc+0x48>
    if((sz = allocuvm(proc->pgdir, sz, sz + n)) == 0)
801051ca:	8b 55 08             	mov    0x8(%ebp),%edx
801051cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051d0:	01 c2                	add    %eax,%edx
801051d2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801051d8:	8b 40 04             	mov    0x4(%eax),%eax
801051db:	83 ec 04             	sub    $0x4,%esp
801051de:	52                   	push   %edx
801051df:	ff 75 f4             	pushl  -0xc(%ebp)
801051e2:	50                   	push   %eax
801051e3:	e8 30 3d 00 00       	call   80108f18 <allocuvm>
801051e8:	83 c4 10             	add    $0x10,%esp
801051eb:	89 45 f4             	mov    %eax,-0xc(%ebp)
801051ee:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801051f2:	75 3e                	jne    80105232 <growproc+0x7f>
      return -1;
801051f4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801051f9:	eb 59                	jmp    80105254 <growproc+0xa1>
  } else if(n < 0){
801051fb:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801051ff:	79 31                	jns    80105232 <growproc+0x7f>
    if((sz = deallocuvm(proc->pgdir, sz, sz + n)) == 0)
80105201:	8b 55 08             	mov    0x8(%ebp),%edx
80105204:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105207:	01 c2                	add    %eax,%edx
80105209:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010520f:	8b 40 04             	mov    0x4(%eax),%eax
80105212:	83 ec 04             	sub    $0x4,%esp
80105215:	52                   	push   %edx
80105216:	ff 75 f4             	pushl  -0xc(%ebp)
80105219:	50                   	push   %eax
8010521a:	e8 c2 3d 00 00       	call   80108fe1 <deallocuvm>
8010521f:	83 c4 10             	add    $0x10,%esp
80105222:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105225:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105229:	75 07                	jne    80105232 <growproc+0x7f>
      return -1;
8010522b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105230:	eb 22                	jmp    80105254 <growproc+0xa1>
  }
  proc->sz = sz;
80105232:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105238:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010523b:	89 10                	mov    %edx,(%eax)
  switchuvm(proc);
8010523d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105243:	83 ec 0c             	sub    $0xc,%esp
80105246:	50                   	push   %eax
80105247:	e8 0c 3a 00 00       	call   80108c58 <switchuvm>
8010524c:	83 c4 10             	add    $0x10,%esp
  return 0;
8010524f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105254:	c9                   	leave  
80105255:	c3                   	ret    

80105256 <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
80105256:	55                   	push   %ebp
80105257:	89 e5                	mov    %esp,%ebp
80105259:	57                   	push   %edi
8010525a:	56                   	push   %esi
8010525b:	53                   	push   %ebx
8010525c:	83 ec 1c             	sub    $0x1c,%esp
  int i, pid;
  struct proc *np;

  // Allocate process.
  if((np = allocproc()) == 0)
8010525f:	e8 2e fd ff ff       	call   80104f92 <allocproc>
80105264:	89 45 e0             	mov    %eax,-0x20(%ebp)
80105267:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
8010526b:	75 0a                	jne    80105277 <fork+0x21>
    return -1;
8010526d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105272:	e9 68 01 00 00       	jmp    801053df <fork+0x189>

  // Copy process state from p.
  if((np->pgdir = copyuvm(proc->pgdir, proc->sz)) == 0){
80105277:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010527d:	8b 10                	mov    (%eax),%edx
8010527f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105285:	8b 40 04             	mov    0x4(%eax),%eax
80105288:	83 ec 08             	sub    $0x8,%esp
8010528b:	52                   	push   %edx
8010528c:	50                   	push   %eax
8010528d:	e8 ed 3e 00 00       	call   8010917f <copyuvm>
80105292:	83 c4 10             	add    $0x10,%esp
80105295:	89 c2                	mov    %eax,%edx
80105297:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010529a:	89 50 04             	mov    %edx,0x4(%eax)
8010529d:	8b 45 e0             	mov    -0x20(%ebp),%eax
801052a0:	8b 40 04             	mov    0x4(%eax),%eax
801052a3:	85 c0                	test   %eax,%eax
801052a5:	75 30                	jne    801052d7 <fork+0x81>
    kfree(np->kstack);
801052a7:	8b 45 e0             	mov    -0x20(%ebp),%eax
801052aa:	8b 40 08             	mov    0x8(%eax),%eax
801052ad:	83 ec 0c             	sub    $0xc,%esp
801052b0:	50                   	push   %eax
801052b1:	e8 1f e1 ff ff       	call   801033d5 <kfree>
801052b6:	83 c4 10             	add    $0x10,%esp
    np->kstack = 0;
801052b9:	8b 45 e0             	mov    -0x20(%ebp),%eax
801052bc:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
801052c3:	8b 45 e0             	mov    -0x20(%ebp),%eax
801052c6:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
801052cd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801052d2:	e9 08 01 00 00       	jmp    801053df <fork+0x189>
  }
  np->sz = proc->sz;
801052d7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801052dd:	8b 10                	mov    (%eax),%edx
801052df:	8b 45 e0             	mov    -0x20(%ebp),%eax
801052e2:	89 10                	mov    %edx,(%eax)
  np->parent = proc;
801052e4:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801052eb:	8b 45 e0             	mov    -0x20(%ebp),%eax
801052ee:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *proc->tf;
801052f1:	8b 45 e0             	mov    -0x20(%ebp),%eax
801052f4:	8b 50 18             	mov    0x18(%eax),%edx
801052f7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801052fd:	8b 40 18             	mov    0x18(%eax),%eax
80105300:	89 c3                	mov    %eax,%ebx
80105302:	b8 13 00 00 00       	mov    $0x13,%eax
80105307:	89 d7                	mov    %edx,%edi
80105309:	89 de                	mov    %ebx,%esi
8010530b:	89 c1                	mov    %eax,%ecx
8010530d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
8010530f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105312:	8b 40 18             	mov    0x18(%eax),%eax
80105315:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
8010531c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80105323:	eb 43                	jmp    80105368 <fork+0x112>
    if(proc->ofile[i])
80105325:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010532b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010532e:	83 c2 08             	add    $0x8,%edx
80105331:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105335:	85 c0                	test   %eax,%eax
80105337:	74 2b                	je     80105364 <fork+0x10e>
      np->ofile[i] = filedup(proc->ofile[i]);
80105339:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010533f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80105342:	83 c2 08             	add    $0x8,%edx
80105345:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105349:	83 ec 0c             	sub    $0xc,%esp
8010534c:	50                   	push   %eax
8010534d:	e8 06 bd ff ff       	call   80101058 <filedup>
80105352:	83 c4 10             	add    $0x10,%esp
80105355:	89 c1                	mov    %eax,%ecx
80105357:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010535a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010535d:	83 c2 08             	add    $0x8,%edx
80105360:	89 4c 90 08          	mov    %ecx,0x8(%eax,%edx,4)
  *np->tf = *proc->tf;

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
80105364:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80105368:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
8010536c:	7e b7                	jle    80105325 <fork+0xcf>
    if(proc->ofile[i])
      np->ofile[i] = filedup(proc->ofile[i]);
  np->cwd = idup(proc->cwd);
8010536e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105374:	8b 40 68             	mov    0x68(%eax),%eax
80105377:	83 ec 0c             	sub    $0xc,%esp
8010537a:	50                   	push   %eax
8010537b:	e8 30 cb ff ff       	call   80101eb0 <idup>
80105380:	83 c4 10             	add    $0x10,%esp
80105383:	89 c2                	mov    %eax,%edx
80105385:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105388:	89 50 68             	mov    %edx,0x68(%eax)

  safestrcpy(np->name, proc->name, sizeof(proc->name));
8010538b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105391:	8d 50 6c             	lea    0x6c(%eax),%edx
80105394:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105397:	83 c0 6c             	add    $0x6c,%eax
8010539a:	83 ec 04             	sub    $0x4,%esp
8010539d:	6a 10                	push   $0x10
8010539f:	52                   	push   %edx
801053a0:	50                   	push   %eax
801053a1:	e8 44 0c 00 00       	call   80105fea <safestrcpy>
801053a6:	83 c4 10             	add    $0x10,%esp
 
  pid = np->pid;
801053a9:	8b 45 e0             	mov    -0x20(%ebp),%eax
801053ac:	8b 40 10             	mov    0x10(%eax),%eax
801053af:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // lock to force the compiler to emit the np->state write last.
  acquire(&ptable.lock);
801053b2:	83 ec 0c             	sub    $0xc,%esp
801053b5:	68 80 3e 11 80       	push   $0x80113e80
801053ba:	e8 c5 07 00 00       	call   80105b84 <acquire>
801053bf:	83 c4 10             	add    $0x10,%esp
  np->state = RUNNABLE;
801053c2:	8b 45 e0             	mov    -0x20(%ebp),%eax
801053c5:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  release(&ptable.lock);
801053cc:	83 ec 0c             	sub    $0xc,%esp
801053cf:	68 80 3e 11 80       	push   $0x80113e80
801053d4:	e8 12 08 00 00       	call   80105beb <release>
801053d9:	83 c4 10             	add    $0x10,%esp
  
  return pid;
801053dc:	8b 45 dc             	mov    -0x24(%ebp),%eax
}
801053df:	8d 65 f4             	lea    -0xc(%ebp),%esp
801053e2:	5b                   	pop    %ebx
801053e3:	5e                   	pop    %esi
801053e4:	5f                   	pop    %edi
801053e5:	5d                   	pop    %ebp
801053e6:	c3                   	ret    

801053e7 <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
801053e7:	55                   	push   %ebp
801053e8:	89 e5                	mov    %esp,%ebp
801053ea:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int fd;

  if(proc == initproc)
801053ed:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801053f4:	a1 48 c6 10 80       	mov    0x8010c648,%eax
801053f9:	39 c2                	cmp    %eax,%edx
801053fb:	75 0d                	jne    8010540a <exit+0x23>
    panic("init exiting");
801053fd:	83 ec 0c             	sub    $0xc,%esp
80105400:	68 d0 97 10 80       	push   $0x801097d0
80105405:	e8 5c b1 ff ff       	call   80100566 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
8010540a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80105411:	eb 48                	jmp    8010545b <exit+0x74>
    if(proc->ofile[fd]){
80105413:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105419:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010541c:	83 c2 08             	add    $0x8,%edx
8010541f:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105423:	85 c0                	test   %eax,%eax
80105425:	74 30                	je     80105457 <exit+0x70>
      fileclose(proc->ofile[fd]);
80105427:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010542d:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105430:	83 c2 08             	add    $0x8,%edx
80105433:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105437:	83 ec 0c             	sub    $0xc,%esp
8010543a:	50                   	push   %eax
8010543b:	e8 69 bc ff ff       	call   801010a9 <fileclose>
80105440:	83 c4 10             	add    $0x10,%esp
      proc->ofile[fd] = 0;
80105443:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105449:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010544c:	83 c2 08             	add    $0x8,%edx
8010544f:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105456:	00 

  if(proc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80105457:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010545b:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
8010545f:	7e b2                	jle    80105413 <exit+0x2c>
      fileclose(proc->ofile[fd]);
      proc->ofile[fd] = 0;
    }
  }

  begin_op(proc->cwd->part->number);
80105461:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105467:	8b 40 68             	mov    0x68(%eax),%eax
8010546a:	8b 40 50             	mov    0x50(%eax),%eax
8010546d:	8b 40 14             	mov    0x14(%eax),%eax
80105470:	83 ec 0c             	sub    $0xc,%esp
80105473:	50                   	push   %eax
80105474:	e8 17 ea ff ff       	call   80103e90 <begin_op>
80105479:	83 c4 10             	add    $0x10,%esp
  iput(proc->cwd);
8010547c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105482:	8b 40 68             	mov    0x68(%eax),%eax
80105485:	83 ec 0c             	sub    $0xc,%esp
80105488:	50                   	push   %eax
80105489:	e8 6f cc ff ff       	call   801020fd <iput>
8010548e:	83 c4 10             	add    $0x10,%esp
  end_op(proc->cwd->part->number);
80105491:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105497:	8b 40 68             	mov    0x68(%eax),%eax
8010549a:	8b 40 50             	mov    0x50(%eax),%eax
8010549d:	8b 40 14             	mov    0x14(%eax),%eax
801054a0:	83 ec 0c             	sub    $0xc,%esp
801054a3:	50                   	push   %eax
801054a4:	e8 ee ea ff ff       	call   80103f97 <end_op>
801054a9:	83 c4 10             	add    $0x10,%esp
  proc->cwd = 0;
801054ac:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801054b2:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
801054b9:	83 ec 0c             	sub    $0xc,%esp
801054bc:	68 80 3e 11 80       	push   $0x80113e80
801054c1:	e8 be 06 00 00       	call   80105b84 <acquire>
801054c6:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);
801054c9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801054cf:	8b 40 14             	mov    0x14(%eax),%eax
801054d2:	83 ec 0c             	sub    $0xc,%esp
801054d5:	50                   	push   %eax
801054d6:	e8 5c 04 00 00       	call   80105937 <wakeup1>
801054db:	83 c4 10             	add    $0x10,%esp

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801054de:	c7 45 f4 b4 3e 11 80 	movl   $0x80113eb4,-0xc(%ebp)
801054e5:	eb 3c                	jmp    80105523 <exit+0x13c>
    if(p->parent == proc){
801054e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801054ea:	8b 50 14             	mov    0x14(%eax),%edx
801054ed:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801054f3:	39 c2                	cmp    %eax,%edx
801054f5:	75 28                	jne    8010551f <exit+0x138>
      p->parent = initproc;
801054f7:	8b 15 48 c6 10 80    	mov    0x8010c648,%edx
801054fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105500:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
80105503:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105506:	8b 40 0c             	mov    0xc(%eax),%eax
80105509:	83 f8 05             	cmp    $0x5,%eax
8010550c:	75 11                	jne    8010551f <exit+0x138>
        wakeup1(initproc);
8010550e:	a1 48 c6 10 80       	mov    0x8010c648,%eax
80105513:	83 ec 0c             	sub    $0xc,%esp
80105516:	50                   	push   %eax
80105517:	e8 1b 04 00 00       	call   80105937 <wakeup1>
8010551c:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010551f:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80105523:	81 7d f4 b4 5d 11 80 	cmpl   $0x80115db4,-0xc(%ebp)
8010552a:	72 bb                	jb     801054e7 <exit+0x100>
        wakeup1(initproc);
    }
  }

  // Jump into the scheduler, never to return.
  proc->state = ZOMBIE;
8010552c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105532:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
80105539:	e8 d6 01 00 00       	call   80105714 <sched>
  panic("zombie exit");
8010553e:	83 ec 0c             	sub    $0xc,%esp
80105541:	68 dd 97 10 80       	push   $0x801097dd
80105546:	e8 1b b0 ff ff       	call   80100566 <panic>

8010554b <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
8010554b:	55                   	push   %ebp
8010554c:	89 e5                	mov    %esp,%ebp
8010554e:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int havekids, pid;

  acquire(&ptable.lock);
80105551:	83 ec 0c             	sub    $0xc,%esp
80105554:	68 80 3e 11 80       	push   $0x80113e80
80105559:	e8 26 06 00 00       	call   80105b84 <acquire>
8010555e:	83 c4 10             	add    $0x10,%esp
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
80105561:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105568:	c7 45 f4 b4 3e 11 80 	movl   $0x80113eb4,-0xc(%ebp)
8010556f:	e9 a6 00 00 00       	jmp    8010561a <wait+0xcf>
      if(p->parent != proc)
80105574:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105577:	8b 50 14             	mov    0x14(%eax),%edx
8010557a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105580:	39 c2                	cmp    %eax,%edx
80105582:	0f 85 8d 00 00 00    	jne    80105615 <wait+0xca>
        continue;
      havekids = 1;
80105588:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
8010558f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105592:	8b 40 0c             	mov    0xc(%eax),%eax
80105595:	83 f8 05             	cmp    $0x5,%eax
80105598:	75 7c                	jne    80105616 <wait+0xcb>
        // Found one.
        pid = p->pid;
8010559a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010559d:	8b 40 10             	mov    0x10(%eax),%eax
801055a0:	89 45 ec             	mov    %eax,-0x14(%ebp)
        kfree(p->kstack);
801055a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055a6:	8b 40 08             	mov    0x8(%eax),%eax
801055a9:	83 ec 0c             	sub    $0xc,%esp
801055ac:	50                   	push   %eax
801055ad:	e8 23 de ff ff       	call   801033d5 <kfree>
801055b2:	83 c4 10             	add    $0x10,%esp
        p->kstack = 0;
801055b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055b8:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
801055bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055c2:	8b 40 04             	mov    0x4(%eax),%eax
801055c5:	83 ec 0c             	sub    $0xc,%esp
801055c8:	50                   	push   %eax
801055c9:	e8 d0 3a 00 00       	call   8010909e <freevm>
801055ce:	83 c4 10             	add    $0x10,%esp
        p->state = UNUSED;
801055d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055d4:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        p->pid = 0;
801055db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055de:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
801055e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055e8:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
801055ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055f2:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
801055f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055f9:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        release(&ptable.lock);
80105600:	83 ec 0c             	sub    $0xc,%esp
80105603:	68 80 3e 11 80       	push   $0x80113e80
80105608:	e8 de 05 00 00       	call   80105beb <release>
8010560d:	83 c4 10             	add    $0x10,%esp
        return pid;
80105610:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105613:	eb 58                	jmp    8010566d <wait+0x122>
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->parent != proc)
        continue;
80105615:	90                   	nop

  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105616:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
8010561a:	81 7d f4 b4 5d 11 80 	cmpl   $0x80115db4,-0xc(%ebp)
80105621:	0f 82 4d ff ff ff    	jb     80105574 <wait+0x29>
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
80105627:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010562b:	74 0d                	je     8010563a <wait+0xef>
8010562d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105633:	8b 40 24             	mov    0x24(%eax),%eax
80105636:	85 c0                	test   %eax,%eax
80105638:	74 17                	je     80105651 <wait+0x106>
      release(&ptable.lock);
8010563a:	83 ec 0c             	sub    $0xc,%esp
8010563d:	68 80 3e 11 80       	push   $0x80113e80
80105642:	e8 a4 05 00 00       	call   80105beb <release>
80105647:	83 c4 10             	add    $0x10,%esp
      return -1;
8010564a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010564f:	eb 1c                	jmp    8010566d <wait+0x122>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
80105651:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105657:	83 ec 08             	sub    $0x8,%esp
8010565a:	68 80 3e 11 80       	push   $0x80113e80
8010565f:	50                   	push   %eax
80105660:	e8 26 02 00 00       	call   8010588b <sleep>
80105665:	83 c4 10             	add    $0x10,%esp
  }
80105668:	e9 f4 fe ff ff       	jmp    80105561 <wait+0x16>
}
8010566d:	c9                   	leave  
8010566e:	c3                   	ret    

8010566f <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
8010566f:	55                   	push   %ebp
80105670:	89 e5                	mov    %esp,%ebp
80105672:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  for(;;){
    // Enable interrupts on this processor.
    sti();
80105675:	e8 f3 f8 ff ff       	call   80104f6d <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
8010567a:	83 ec 0c             	sub    $0xc,%esp
8010567d:	68 80 3e 11 80       	push   $0x80113e80
80105682:	e8 fd 04 00 00       	call   80105b84 <acquire>
80105687:	83 c4 10             	add    $0x10,%esp
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010568a:	c7 45 f4 b4 3e 11 80 	movl   $0x80113eb4,-0xc(%ebp)
80105691:	eb 63                	jmp    801056f6 <scheduler+0x87>
      if(p->state != RUNNABLE)
80105693:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105696:	8b 40 0c             	mov    0xc(%eax),%eax
80105699:	83 f8 03             	cmp    $0x3,%eax
8010569c:	75 53                	jne    801056f1 <scheduler+0x82>
        continue;

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      proc = p;
8010569e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056a1:	65 a3 04 00 00 00    	mov    %eax,%gs:0x4
      switchuvm(p);
801056a7:	83 ec 0c             	sub    $0xc,%esp
801056aa:	ff 75 f4             	pushl  -0xc(%ebp)
801056ad:	e8 a6 35 00 00       	call   80108c58 <switchuvm>
801056b2:	83 c4 10             	add    $0x10,%esp
      p->state = RUNNING;
801056b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056b8:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)
     // cprintf("selected %s \n",p->chan);
      swtch(&cpu->scheduler, proc->context);
801056bf:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801056c5:	8b 40 1c             	mov    0x1c(%eax),%eax
801056c8:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
801056cf:	83 c2 04             	add    $0x4,%edx
801056d2:	83 ec 08             	sub    $0x8,%esp
801056d5:	50                   	push   %eax
801056d6:	52                   	push   %edx
801056d7:	e8 7f 09 00 00       	call   8010605b <swtch>
801056dc:	83 c4 10             	add    $0x10,%esp
      switchkvm();
801056df:	e8 57 35 00 00       	call   80108c3b <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
801056e4:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
801056eb:	00 00 00 00 
801056ef:	eb 01                	jmp    801056f2 <scheduler+0x83>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->state != RUNNABLE)
        continue;
801056f1:	90                   	nop
    // Enable interrupts on this processor.
    sti();

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801056f2:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
801056f6:	81 7d f4 b4 5d 11 80 	cmpl   $0x80115db4,-0xc(%ebp)
801056fd:	72 94                	jb     80105693 <scheduler+0x24>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
    }
    release(&ptable.lock);
801056ff:	83 ec 0c             	sub    $0xc,%esp
80105702:	68 80 3e 11 80       	push   $0x80113e80
80105707:	e8 df 04 00 00       	call   80105beb <release>
8010570c:	83 c4 10             	add    $0x10,%esp

  }
8010570f:	e9 61 ff ff ff       	jmp    80105675 <scheduler+0x6>

80105714 <sched>:

// Enter scheduler.  Must hold only ptable.lock
// and have changed proc->state.
void
sched(void)
{
80105714:	55                   	push   %ebp
80105715:	89 e5                	mov    %esp,%ebp
80105717:	83 ec 18             	sub    $0x18,%esp
  int intena;

  if(!holding(&ptable.lock))
8010571a:	83 ec 0c             	sub    $0xc,%esp
8010571d:	68 80 3e 11 80       	push   $0x80113e80
80105722:	e8 90 05 00 00       	call   80105cb7 <holding>
80105727:	83 c4 10             	add    $0x10,%esp
8010572a:	85 c0                	test   %eax,%eax
8010572c:	75 0d                	jne    8010573b <sched+0x27>
    panic("sched ptable.lock");
8010572e:	83 ec 0c             	sub    $0xc,%esp
80105731:	68 e9 97 10 80       	push   $0x801097e9
80105736:	e8 2b ae ff ff       	call   80100566 <panic>
  if(cpu->ncli != 1)
8010573b:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105741:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80105747:	83 f8 01             	cmp    $0x1,%eax
8010574a:	74 0d                	je     80105759 <sched+0x45>
   panic("sched locks");
8010574c:	83 ec 0c             	sub    $0xc,%esp
8010574f:	68 fb 97 10 80       	push   $0x801097fb
80105754:	e8 0d ae ff ff       	call   80100566 <panic>
  if(proc->state == RUNNING)
80105759:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010575f:	8b 40 0c             	mov    0xc(%eax),%eax
80105762:	83 f8 04             	cmp    $0x4,%eax
80105765:	75 0d                	jne    80105774 <sched+0x60>
    panic("sched running");
80105767:	83 ec 0c             	sub    $0xc,%esp
8010576a:	68 07 98 10 80       	push   $0x80109807
8010576f:	e8 f2 ad ff ff       	call   80100566 <panic>
  if(readeflags()&FL_IF)
80105774:	e8 e4 f7 ff ff       	call   80104f5d <readeflags>
80105779:	25 00 02 00 00       	and    $0x200,%eax
8010577e:	85 c0                	test   %eax,%eax
80105780:	74 0d                	je     8010578f <sched+0x7b>
    panic("sched interruptible");
80105782:	83 ec 0c             	sub    $0xc,%esp
80105785:	68 15 98 10 80       	push   $0x80109815
8010578a:	e8 d7 ad ff ff       	call   80100566 <panic>
  intena = cpu->intena;
8010578f:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105795:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
8010579b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  swtch(&proc->context, cpu->scheduler);
8010579e:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801057a4:	8b 40 04             	mov    0x4(%eax),%eax
801057a7:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801057ae:	83 c2 1c             	add    $0x1c,%edx
801057b1:	83 ec 08             	sub    $0x8,%esp
801057b4:	50                   	push   %eax
801057b5:	52                   	push   %edx
801057b6:	e8 a0 08 00 00       	call   8010605b <swtch>
801057bb:	83 c4 10             	add    $0x10,%esp
  cpu->intena = intena;
801057be:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801057c4:	8b 55 f4             	mov    -0xc(%ebp),%edx
801057c7:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
801057cd:	90                   	nop
801057ce:	c9                   	leave  
801057cf:	c3                   	ret    

801057d0 <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
801057d0:	55                   	push   %ebp
801057d1:	89 e5                	mov    %esp,%ebp
801057d3:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
801057d6:	83 ec 0c             	sub    $0xc,%esp
801057d9:	68 80 3e 11 80       	push   $0x80113e80
801057de:	e8 a1 03 00 00       	call   80105b84 <acquire>
801057e3:	83 c4 10             	add    $0x10,%esp
  proc->state = RUNNABLE;
801057e6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801057ec:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
801057f3:	e8 1c ff ff ff       	call   80105714 <sched>
  release(&ptable.lock);
801057f8:	83 ec 0c             	sub    $0xc,%esp
801057fb:	68 80 3e 11 80       	push   $0x80113e80
80105800:	e8 e6 03 00 00       	call   80105beb <release>
80105805:	83 c4 10             	add    $0x10,%esp
}
80105808:	90                   	nop
80105809:	c9                   	leave  
8010580a:	c3                   	ret    

8010580b <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
8010580b:	55                   	push   %ebp
8010580c:	89 e5                	mov    %esp,%ebp
8010580e:	83 ec 18             	sub    $0x18,%esp
  static int first = 1;
 // static int iinitDone=0;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80105811:	83 ec 0c             	sub    $0xc,%esp
80105814:	68 80 3e 11 80       	push   $0x80113e80
80105819:	e8 cd 03 00 00       	call   80105beb <release>
8010581e:	83 c4 10             	add    $0x10,%esp


  if (first) {
80105821:	a1 08 c0 10 80       	mov    0x8010c008,%eax
80105826:	85 c0                	test   %eax,%eax
80105828:	74 5e                	je     80105888 <forkret+0x7d>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot 
    // be run from main().
    first = 0;
8010582a:	c7 05 08 c0 10 80 00 	movl   $0x0,0x8010c008
80105831:	00 00 00 
    cprintf("cpu %d iinit \n",cpu->id);
80105834:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010583a:	0f b6 00             	movzbl (%eax),%eax
8010583d:	0f b6 c0             	movzbl %al,%eax
80105840:	83 ec 08             	sub    $0x8,%esp
80105843:	50                   	push   %eax
80105844:	68 29 98 10 80       	push   $0x80109829
80105849:	e8 78 ab ff ff       	call   801003c6 <cprintf>
8010584e:	83 c4 10             	add    $0x10,%esp
    int bootfrom=iinit(proc,ROOTDEV);
80105851:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105857:	83 ec 08             	sub    $0x8,%esp
8010585a:	6a 00                	push   $0x0
8010585c:	50                   	push   %eax
8010585d:	e8 d8 c1 ff ff       	call   80101a3a <iinit>
80105862:	83 c4 10             	add    $0x10,%esp
80105865:	89 45 f4             	mov    %eax,-0xc(%ebp)
    // iinitDone=1;
    cprintf("boot from after iinit is %d \n",bootfrom);
80105868:	83 ec 08             	sub    $0x8,%esp
8010586b:	ff 75 f4             	pushl  -0xc(%ebp)
8010586e:	68 38 98 10 80       	push   $0x80109838
80105873:	e8 4e ab ff ff       	call   801003c6 <cprintf>
80105878:	83 c4 10             	add    $0x10,%esp
    initlog(ROOTDEV);
8010587b:	83 ec 0c             	sub    $0xc,%esp
8010587e:	6a 00                	push   $0x0
80105880:	e8 b6 e2 ff ff       	call   80103b3b <initlog>
80105885:	83 c4 10             	add    $0x10,%esp
 // }

 
  
  // Return to "caller", actually trapret (see allocproc).
}
80105888:	90                   	nop
80105889:	c9                   	leave  
8010588a:	c3                   	ret    

8010588b <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
8010588b:	55                   	push   %ebp
8010588c:	89 e5                	mov    %esp,%ebp
8010588e:	83 ec 08             	sub    $0x8,%esp
  if(proc == 0)
80105891:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105897:	85 c0                	test   %eax,%eax
80105899:	75 0d                	jne    801058a8 <sleep+0x1d>
    panic("sleep");
8010589b:	83 ec 0c             	sub    $0xc,%esp
8010589e:	68 56 98 10 80       	push   $0x80109856
801058a3:	e8 be ac ff ff       	call   80100566 <panic>

  if(lk == 0)
801058a8:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801058ac:	75 0d                	jne    801058bb <sleep+0x30>
    panic("sleep without lk");
801058ae:	83 ec 0c             	sub    $0xc,%esp
801058b1:	68 5c 98 10 80       	push   $0x8010985c
801058b6:	e8 ab ac ff ff       	call   80100566 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
801058bb:	81 7d 0c 80 3e 11 80 	cmpl   $0x80113e80,0xc(%ebp)
801058c2:	74 1e                	je     801058e2 <sleep+0x57>
    acquire(&ptable.lock);  //DOC: sleeplock1
801058c4:	83 ec 0c             	sub    $0xc,%esp
801058c7:	68 80 3e 11 80       	push   $0x80113e80
801058cc:	e8 b3 02 00 00       	call   80105b84 <acquire>
801058d1:	83 c4 10             	add    $0x10,%esp
    release(lk);
801058d4:	83 ec 0c             	sub    $0xc,%esp
801058d7:	ff 75 0c             	pushl  0xc(%ebp)
801058da:	e8 0c 03 00 00       	call   80105beb <release>
801058df:	83 c4 10             	add    $0x10,%esp
  }

  // Go to sleep.
  proc->chan = chan;
801058e2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801058e8:	8b 55 08             	mov    0x8(%ebp),%edx
801058eb:	89 50 20             	mov    %edx,0x20(%eax)
  proc->state = SLEEPING;
801058ee:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801058f4:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)
  sched();
801058fb:	e8 14 fe ff ff       	call   80105714 <sched>

  // Tidy up.
  proc->chan = 0;
80105900:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105906:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
8010590d:	81 7d 0c 80 3e 11 80 	cmpl   $0x80113e80,0xc(%ebp)
80105914:	74 1e                	je     80105934 <sleep+0xa9>
    release(&ptable.lock);
80105916:	83 ec 0c             	sub    $0xc,%esp
80105919:	68 80 3e 11 80       	push   $0x80113e80
8010591e:	e8 c8 02 00 00       	call   80105beb <release>
80105923:	83 c4 10             	add    $0x10,%esp
    acquire(lk);
80105926:	83 ec 0c             	sub    $0xc,%esp
80105929:	ff 75 0c             	pushl  0xc(%ebp)
8010592c:	e8 53 02 00 00       	call   80105b84 <acquire>
80105931:	83 c4 10             	add    $0x10,%esp
  }
}
80105934:	90                   	nop
80105935:	c9                   	leave  
80105936:	c3                   	ret    

80105937 <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80105937:	55                   	push   %ebp
80105938:	89 e5                	mov    %esp,%ebp
8010593a:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010593d:	c7 45 fc b4 3e 11 80 	movl   $0x80113eb4,-0x4(%ebp)
80105944:	eb 24                	jmp    8010596a <wakeup1+0x33>
    if(p->state == SLEEPING && p->chan == chan)
80105946:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105949:	8b 40 0c             	mov    0xc(%eax),%eax
8010594c:	83 f8 02             	cmp    $0x2,%eax
8010594f:	75 15                	jne    80105966 <wakeup1+0x2f>
80105951:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105954:	8b 40 20             	mov    0x20(%eax),%eax
80105957:	3b 45 08             	cmp    0x8(%ebp),%eax
8010595a:	75 0a                	jne    80105966 <wakeup1+0x2f>
      p->state = RUNNABLE;
8010595c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010595f:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80105966:	83 45 fc 7c          	addl   $0x7c,-0x4(%ebp)
8010596a:	81 7d fc b4 5d 11 80 	cmpl   $0x80115db4,-0x4(%ebp)
80105971:	72 d3                	jb     80105946 <wakeup1+0xf>
    if(p->state == SLEEPING && p->chan == chan)
      p->state = RUNNABLE;
}
80105973:	90                   	nop
80105974:	c9                   	leave  
80105975:	c3                   	ret    

80105976 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80105976:	55                   	push   %ebp
80105977:	89 e5                	mov    %esp,%ebp
80105979:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);
8010597c:	83 ec 0c             	sub    $0xc,%esp
8010597f:	68 80 3e 11 80       	push   $0x80113e80
80105984:	e8 fb 01 00 00       	call   80105b84 <acquire>
80105989:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
8010598c:	83 ec 0c             	sub    $0xc,%esp
8010598f:	ff 75 08             	pushl  0x8(%ebp)
80105992:	e8 a0 ff ff ff       	call   80105937 <wakeup1>
80105997:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
8010599a:	83 ec 0c             	sub    $0xc,%esp
8010599d:	68 80 3e 11 80       	push   $0x80113e80
801059a2:	e8 44 02 00 00       	call   80105beb <release>
801059a7:	83 c4 10             	add    $0x10,%esp
}
801059aa:	90                   	nop
801059ab:	c9                   	leave  
801059ac:	c3                   	ret    

801059ad <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
801059ad:	55                   	push   %ebp
801059ae:	89 e5                	mov    %esp,%ebp
801059b0:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  acquire(&ptable.lock);
801059b3:	83 ec 0c             	sub    $0xc,%esp
801059b6:	68 80 3e 11 80       	push   $0x80113e80
801059bb:	e8 c4 01 00 00       	call   80105b84 <acquire>
801059c0:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801059c3:	c7 45 f4 b4 3e 11 80 	movl   $0x80113eb4,-0xc(%ebp)
801059ca:	eb 45                	jmp    80105a11 <kill+0x64>
    if(p->pid == pid){
801059cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059cf:	8b 40 10             	mov    0x10(%eax),%eax
801059d2:	3b 45 08             	cmp    0x8(%ebp),%eax
801059d5:	75 36                	jne    80105a0d <kill+0x60>
      p->killed = 1;
801059d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059da:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
801059e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059e4:	8b 40 0c             	mov    0xc(%eax),%eax
801059e7:	83 f8 02             	cmp    $0x2,%eax
801059ea:	75 0a                	jne    801059f6 <kill+0x49>
        p->state = RUNNABLE;
801059ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059ef:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
801059f6:	83 ec 0c             	sub    $0xc,%esp
801059f9:	68 80 3e 11 80       	push   $0x80113e80
801059fe:	e8 e8 01 00 00       	call   80105beb <release>
80105a03:	83 c4 10             	add    $0x10,%esp
      return 0;
80105a06:	b8 00 00 00 00       	mov    $0x0,%eax
80105a0b:	eb 22                	jmp    80105a2f <kill+0x82>
kill(int pid)
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105a0d:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80105a11:	81 7d f4 b4 5d 11 80 	cmpl   $0x80115db4,-0xc(%ebp)
80105a18:	72 b2                	jb     801059cc <kill+0x1f>
        p->state = RUNNABLE;
      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
80105a1a:	83 ec 0c             	sub    $0xc,%esp
80105a1d:	68 80 3e 11 80       	push   $0x80113e80
80105a22:	e8 c4 01 00 00       	call   80105beb <release>
80105a27:	83 c4 10             	add    $0x10,%esp
  return -1;
80105a2a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105a2f:	c9                   	leave  
80105a30:	c3                   	ret    

80105a31 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80105a31:	55                   	push   %ebp
80105a32:	89 e5                	mov    %esp,%ebp
80105a34:	83 ec 48             	sub    $0x48,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105a37:	c7 45 f0 b4 3e 11 80 	movl   $0x80113eb4,-0x10(%ebp)
80105a3e:	e9 d7 00 00 00       	jmp    80105b1a <procdump+0xe9>
    if(p->state == UNUSED)
80105a43:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a46:	8b 40 0c             	mov    0xc(%eax),%eax
80105a49:	85 c0                	test   %eax,%eax
80105a4b:	0f 84 c4 00 00 00    	je     80105b15 <procdump+0xe4>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80105a51:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a54:	8b 40 0c             	mov    0xc(%eax),%eax
80105a57:	83 f8 05             	cmp    $0x5,%eax
80105a5a:	77 23                	ja     80105a7f <procdump+0x4e>
80105a5c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a5f:	8b 40 0c             	mov    0xc(%eax),%eax
80105a62:	8b 04 85 0c c0 10 80 	mov    -0x7fef3ff4(,%eax,4),%eax
80105a69:	85 c0                	test   %eax,%eax
80105a6b:	74 12                	je     80105a7f <procdump+0x4e>
      state = states[p->state];
80105a6d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a70:	8b 40 0c             	mov    0xc(%eax),%eax
80105a73:	8b 04 85 0c c0 10 80 	mov    -0x7fef3ff4(,%eax,4),%eax
80105a7a:	89 45 ec             	mov    %eax,-0x14(%ebp)
80105a7d:	eb 07                	jmp    80105a86 <procdump+0x55>
    else
      state = "???";
80105a7f:	c7 45 ec 6d 98 10 80 	movl   $0x8010986d,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
80105a86:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a89:	8d 50 6c             	lea    0x6c(%eax),%edx
80105a8c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a8f:	8b 40 10             	mov    0x10(%eax),%eax
80105a92:	52                   	push   %edx
80105a93:	ff 75 ec             	pushl  -0x14(%ebp)
80105a96:	50                   	push   %eax
80105a97:	68 71 98 10 80       	push   $0x80109871
80105a9c:	e8 25 a9 ff ff       	call   801003c6 <cprintf>
80105aa1:	83 c4 10             	add    $0x10,%esp
    if(p->state == SLEEPING){
80105aa4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105aa7:	8b 40 0c             	mov    0xc(%eax),%eax
80105aaa:	83 f8 02             	cmp    $0x2,%eax
80105aad:	75 54                	jne    80105b03 <procdump+0xd2>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80105aaf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ab2:	8b 40 1c             	mov    0x1c(%eax),%eax
80105ab5:	8b 40 0c             	mov    0xc(%eax),%eax
80105ab8:	83 c0 08             	add    $0x8,%eax
80105abb:	89 c2                	mov    %eax,%edx
80105abd:	83 ec 08             	sub    $0x8,%esp
80105ac0:	8d 45 c4             	lea    -0x3c(%ebp),%eax
80105ac3:	50                   	push   %eax
80105ac4:	52                   	push   %edx
80105ac5:	e8 73 01 00 00       	call   80105c3d <getcallerpcs>
80105aca:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
80105acd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80105ad4:	eb 1c                	jmp    80105af2 <procdump+0xc1>
        cprintf(" %p", pc[i]);
80105ad6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ad9:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80105add:	83 ec 08             	sub    $0x8,%esp
80105ae0:	50                   	push   %eax
80105ae1:	68 7a 98 10 80       	push   $0x8010987a
80105ae6:	e8 db a8 ff ff       	call   801003c6 <cprintf>
80105aeb:	83 c4 10             	add    $0x10,%esp
    else
      state = "???";
    cprintf("%d %s %s", p->pid, state, p->name);
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
80105aee:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80105af2:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80105af6:	7f 0b                	jg     80105b03 <procdump+0xd2>
80105af8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105afb:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80105aff:	85 c0                	test   %eax,%eax
80105b01:	75 d3                	jne    80105ad6 <procdump+0xa5>
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
80105b03:	83 ec 0c             	sub    $0xc,%esp
80105b06:	68 7e 98 10 80       	push   $0x8010987e
80105b0b:	e8 b6 a8 ff ff       	call   801003c6 <cprintf>
80105b10:	83 c4 10             	add    $0x10,%esp
80105b13:	eb 01                	jmp    80105b16 <procdump+0xe5>
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->state == UNUSED)
      continue;
80105b15:	90                   	nop
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105b16:	83 45 f0 7c          	addl   $0x7c,-0x10(%ebp)
80105b1a:	81 7d f0 b4 5d 11 80 	cmpl   $0x80115db4,-0x10(%ebp)
80105b21:	0f 82 1c ff ff ff    	jb     80105a43 <procdump+0x12>
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }
}
80105b27:	90                   	nop
80105b28:	c9                   	leave  
80105b29:	c3                   	ret    

80105b2a <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80105b2a:	55                   	push   %ebp
80105b2b:	89 e5                	mov    %esp,%ebp
80105b2d:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80105b30:	9c                   	pushf  
80105b31:	58                   	pop    %eax
80105b32:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80105b35:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105b38:	c9                   	leave  
80105b39:	c3                   	ret    

80105b3a <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80105b3a:	55                   	push   %ebp
80105b3b:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80105b3d:	fa                   	cli    
}
80105b3e:	90                   	nop
80105b3f:	5d                   	pop    %ebp
80105b40:	c3                   	ret    

80105b41 <sti>:

static inline void
sti(void)
{
80105b41:	55                   	push   %ebp
80105b42:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80105b44:	fb                   	sti    
}
80105b45:	90                   	nop
80105b46:	5d                   	pop    %ebp
80105b47:	c3                   	ret    

80105b48 <xchg>:

static inline uint
xchg(volatile uint *addr, uint newval)
{
80105b48:	55                   	push   %ebp
80105b49:	89 e5                	mov    %esp,%ebp
80105b4b:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80105b4e:	8b 55 08             	mov    0x8(%ebp),%edx
80105b51:	8b 45 0c             	mov    0xc(%ebp),%eax
80105b54:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105b57:	f0 87 02             	lock xchg %eax,(%edx)
80105b5a:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80105b5d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105b60:	c9                   	leave  
80105b61:	c3                   	ret    

80105b62 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80105b62:	55                   	push   %ebp
80105b63:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80105b65:	8b 45 08             	mov    0x8(%ebp),%eax
80105b68:	8b 55 0c             	mov    0xc(%ebp),%edx
80105b6b:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80105b6e:	8b 45 08             	mov    0x8(%ebp),%eax
80105b71:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80105b77:	8b 45 08             	mov    0x8(%ebp),%eax
80105b7a:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80105b81:	90                   	nop
80105b82:	5d                   	pop    %ebp
80105b83:	c3                   	ret    

80105b84 <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80105b84:	55                   	push   %ebp
80105b85:	89 e5                	mov    %esp,%ebp
80105b87:	83 ec 08             	sub    $0x8,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80105b8a:	e8 52 01 00 00       	call   80105ce1 <pushcli>
  if(holding(lk))
80105b8f:	8b 45 08             	mov    0x8(%ebp),%eax
80105b92:	83 ec 0c             	sub    $0xc,%esp
80105b95:	50                   	push   %eax
80105b96:	e8 1c 01 00 00       	call   80105cb7 <holding>
80105b9b:	83 c4 10             	add    $0x10,%esp
80105b9e:	85 c0                	test   %eax,%eax
80105ba0:	74 0d                	je     80105baf <acquire+0x2b>
    panic("acquire");
80105ba2:	83 ec 0c             	sub    $0xc,%esp
80105ba5:	68 aa 98 10 80       	push   $0x801098aa
80105baa:	e8 b7 a9 ff ff       	call   80100566 <panic>

  // The xchg is atomic.
  // It also serializes, so that reads after acquire are not
  // reordered before it. 
  while(xchg(&lk->locked, 1) != 0)
80105baf:	90                   	nop
80105bb0:	8b 45 08             	mov    0x8(%ebp),%eax
80105bb3:	83 ec 08             	sub    $0x8,%esp
80105bb6:	6a 01                	push   $0x1
80105bb8:	50                   	push   %eax
80105bb9:	e8 8a ff ff ff       	call   80105b48 <xchg>
80105bbe:	83 c4 10             	add    $0x10,%esp
80105bc1:	85 c0                	test   %eax,%eax
80105bc3:	75 eb                	jne    80105bb0 <acquire+0x2c>
    ;

  // Record info about lock acquisition for debugging.
  lk->cpu = cpu;
80105bc5:	8b 45 08             	mov    0x8(%ebp),%eax
80105bc8:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80105bcf:	89 50 08             	mov    %edx,0x8(%eax)
  getcallerpcs(&lk, lk->pcs);
80105bd2:	8b 45 08             	mov    0x8(%ebp),%eax
80105bd5:	83 c0 0c             	add    $0xc,%eax
80105bd8:	83 ec 08             	sub    $0x8,%esp
80105bdb:	50                   	push   %eax
80105bdc:	8d 45 08             	lea    0x8(%ebp),%eax
80105bdf:	50                   	push   %eax
80105be0:	e8 58 00 00 00       	call   80105c3d <getcallerpcs>
80105be5:	83 c4 10             	add    $0x10,%esp
}
80105be8:	90                   	nop
80105be9:	c9                   	leave  
80105bea:	c3                   	ret    

80105beb <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80105beb:	55                   	push   %ebp
80105bec:	89 e5                	mov    %esp,%ebp
80105bee:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
80105bf1:	83 ec 0c             	sub    $0xc,%esp
80105bf4:	ff 75 08             	pushl  0x8(%ebp)
80105bf7:	e8 bb 00 00 00       	call   80105cb7 <holding>
80105bfc:	83 c4 10             	add    $0x10,%esp
80105bff:	85 c0                	test   %eax,%eax
80105c01:	75 0d                	jne    80105c10 <release+0x25>
    panic("release");
80105c03:	83 ec 0c             	sub    $0xc,%esp
80105c06:	68 b2 98 10 80       	push   $0x801098b2
80105c0b:	e8 56 a9 ff ff       	call   80100566 <panic>

  lk->pcs[0] = 0;
80105c10:	8b 45 08             	mov    0x8(%ebp),%eax
80105c13:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
80105c1a:	8b 45 08             	mov    0x8(%ebp),%eax
80105c1d:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // But the 2007 Intel 64 Architecture Memory Ordering White
  // Paper says that Intel 64 and IA-32 will not move a load
  // after a store. So lock->locked = 0 would work here.
  // The xchg being asm volatile ensures gcc emits it after
  // the above assignments (and after the critical section).
  xchg(&lk->locked, 0);
80105c24:	8b 45 08             	mov    0x8(%ebp),%eax
80105c27:	83 ec 08             	sub    $0x8,%esp
80105c2a:	6a 00                	push   $0x0
80105c2c:	50                   	push   %eax
80105c2d:	e8 16 ff ff ff       	call   80105b48 <xchg>
80105c32:	83 c4 10             	add    $0x10,%esp

  popcli();
80105c35:	e8 ec 00 00 00       	call   80105d26 <popcli>
}
80105c3a:	90                   	nop
80105c3b:	c9                   	leave  
80105c3c:	c3                   	ret    

80105c3d <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80105c3d:	55                   	push   %ebp
80105c3e:	89 e5                	mov    %esp,%ebp
80105c40:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
80105c43:	8b 45 08             	mov    0x8(%ebp),%eax
80105c46:	83 e8 08             	sub    $0x8,%eax
80105c49:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80105c4c:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80105c53:	eb 38                	jmp    80105c8d <getcallerpcs+0x50>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80105c55:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80105c59:	74 53                	je     80105cae <getcallerpcs+0x71>
80105c5b:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80105c62:	76 4a                	jbe    80105cae <getcallerpcs+0x71>
80105c64:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
80105c68:	74 44                	je     80105cae <getcallerpcs+0x71>
      break;
    pcs[i] = ebp[1];     // saved %eip
80105c6a:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105c6d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80105c74:	8b 45 0c             	mov    0xc(%ebp),%eax
80105c77:	01 c2                	add    %eax,%edx
80105c79:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105c7c:	8b 40 04             	mov    0x4(%eax),%eax
80105c7f:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
80105c81:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105c84:	8b 00                	mov    (%eax),%eax
80105c86:	89 45 fc             	mov    %eax,-0x4(%ebp)
{
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
80105c89:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80105c8d:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105c91:	7e c2                	jle    80105c55 <getcallerpcs+0x18>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80105c93:	eb 19                	jmp    80105cae <getcallerpcs+0x71>
    pcs[i] = 0;
80105c95:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105c98:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80105c9f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105ca2:	01 d0                	add    %edx,%eax
80105ca4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80105caa:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80105cae:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105cb2:	7e e1                	jle    80105c95 <getcallerpcs+0x58>
    pcs[i] = 0;
}
80105cb4:	90                   	nop
80105cb5:	c9                   	leave  
80105cb6:	c3                   	ret    

80105cb7 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80105cb7:	55                   	push   %ebp
80105cb8:	89 e5                	mov    %esp,%ebp
  return lock->locked && lock->cpu == cpu;
80105cba:	8b 45 08             	mov    0x8(%ebp),%eax
80105cbd:	8b 00                	mov    (%eax),%eax
80105cbf:	85 c0                	test   %eax,%eax
80105cc1:	74 17                	je     80105cda <holding+0x23>
80105cc3:	8b 45 08             	mov    0x8(%ebp),%eax
80105cc6:	8b 50 08             	mov    0x8(%eax),%edx
80105cc9:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105ccf:	39 c2                	cmp    %eax,%edx
80105cd1:	75 07                	jne    80105cda <holding+0x23>
80105cd3:	b8 01 00 00 00       	mov    $0x1,%eax
80105cd8:	eb 05                	jmp    80105cdf <holding+0x28>
80105cda:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105cdf:	5d                   	pop    %ebp
80105ce0:	c3                   	ret    

80105ce1 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80105ce1:	55                   	push   %ebp
80105ce2:	89 e5                	mov    %esp,%ebp
80105ce4:	83 ec 10             	sub    $0x10,%esp
  int eflags;
  
  eflags = readeflags();
80105ce7:	e8 3e fe ff ff       	call   80105b2a <readeflags>
80105cec:	89 45 fc             	mov    %eax,-0x4(%ebp)
  cli();
80105cef:	e8 46 fe ff ff       	call   80105b3a <cli>
  if(cpu->ncli++ == 0)
80105cf4:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80105cfb:	8b 82 ac 00 00 00    	mov    0xac(%edx),%eax
80105d01:	8d 48 01             	lea    0x1(%eax),%ecx
80105d04:	89 8a ac 00 00 00    	mov    %ecx,0xac(%edx)
80105d0a:	85 c0                	test   %eax,%eax
80105d0c:	75 15                	jne    80105d23 <pushcli+0x42>
    cpu->intena = eflags & FL_IF;
80105d0e:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105d14:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105d17:	81 e2 00 02 00 00    	and    $0x200,%edx
80105d1d:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
80105d23:	90                   	nop
80105d24:	c9                   	leave  
80105d25:	c3                   	ret    

80105d26 <popcli>:

void
popcli(void)
{
80105d26:	55                   	push   %ebp
80105d27:	89 e5                	mov    %esp,%ebp
80105d29:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
80105d2c:	e8 f9 fd ff ff       	call   80105b2a <readeflags>
80105d31:	25 00 02 00 00       	and    $0x200,%eax
80105d36:	85 c0                	test   %eax,%eax
80105d38:	74 0d                	je     80105d47 <popcli+0x21>
    panic("popcli - interruptible");
80105d3a:	83 ec 0c             	sub    $0xc,%esp
80105d3d:	68 ba 98 10 80       	push   $0x801098ba
80105d42:	e8 1f a8 ff ff       	call   80100566 <panic>
  if(--cpu->ncli < 0)
80105d47:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105d4d:	8b 90 ac 00 00 00    	mov    0xac(%eax),%edx
80105d53:	83 ea 01             	sub    $0x1,%edx
80105d56:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
80105d5c:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80105d62:	85 c0                	test   %eax,%eax
80105d64:	79 0d                	jns    80105d73 <popcli+0x4d>
    panic("popcli");
80105d66:	83 ec 0c             	sub    $0xc,%esp
80105d69:	68 d1 98 10 80       	push   $0x801098d1
80105d6e:	e8 f3 a7 ff ff       	call   80100566 <panic>
  if(cpu->ncli == 0 && cpu->intena)
80105d73:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105d79:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80105d7f:	85 c0                	test   %eax,%eax
80105d81:	75 15                	jne    80105d98 <popcli+0x72>
80105d83:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105d89:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80105d8f:	85 c0                	test   %eax,%eax
80105d91:	74 05                	je     80105d98 <popcli+0x72>
    sti();
80105d93:	e8 a9 fd ff ff       	call   80105b41 <sti>
}
80105d98:	90                   	nop
80105d99:	c9                   	leave  
80105d9a:	c3                   	ret    

80105d9b <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
80105d9b:	55                   	push   %ebp
80105d9c:	89 e5                	mov    %esp,%ebp
80105d9e:	57                   	push   %edi
80105d9f:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80105da0:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105da3:	8b 55 10             	mov    0x10(%ebp),%edx
80105da6:	8b 45 0c             	mov    0xc(%ebp),%eax
80105da9:	89 cb                	mov    %ecx,%ebx
80105dab:	89 df                	mov    %ebx,%edi
80105dad:	89 d1                	mov    %edx,%ecx
80105daf:	fc                   	cld    
80105db0:	f3 aa                	rep stos %al,%es:(%edi)
80105db2:	89 ca                	mov    %ecx,%edx
80105db4:	89 fb                	mov    %edi,%ebx
80105db6:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105db9:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80105dbc:	90                   	nop
80105dbd:	5b                   	pop    %ebx
80105dbe:	5f                   	pop    %edi
80105dbf:	5d                   	pop    %ebp
80105dc0:	c3                   	ret    

80105dc1 <stosl>:

static inline void
stosl(void *addr, int data, int cnt)
{
80105dc1:	55                   	push   %ebp
80105dc2:	89 e5                	mov    %esp,%ebp
80105dc4:	57                   	push   %edi
80105dc5:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
80105dc6:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105dc9:	8b 55 10             	mov    0x10(%ebp),%edx
80105dcc:	8b 45 0c             	mov    0xc(%ebp),%eax
80105dcf:	89 cb                	mov    %ecx,%ebx
80105dd1:	89 df                	mov    %ebx,%edi
80105dd3:	89 d1                	mov    %edx,%ecx
80105dd5:	fc                   	cld    
80105dd6:	f3 ab                	rep stos %eax,%es:(%edi)
80105dd8:	89 ca                	mov    %ecx,%edx
80105dda:	89 fb                	mov    %edi,%ebx
80105ddc:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105ddf:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80105de2:	90                   	nop
80105de3:	5b                   	pop    %ebx
80105de4:	5f                   	pop    %edi
80105de5:	5d                   	pop    %ebp
80105de6:	c3                   	ret    

80105de7 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80105de7:	55                   	push   %ebp
80105de8:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
80105dea:	8b 45 08             	mov    0x8(%ebp),%eax
80105ded:	83 e0 03             	and    $0x3,%eax
80105df0:	85 c0                	test   %eax,%eax
80105df2:	75 43                	jne    80105e37 <memset+0x50>
80105df4:	8b 45 10             	mov    0x10(%ebp),%eax
80105df7:	83 e0 03             	and    $0x3,%eax
80105dfa:	85 c0                	test   %eax,%eax
80105dfc:	75 39                	jne    80105e37 <memset+0x50>
    c &= 0xFF;
80105dfe:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80105e05:	8b 45 10             	mov    0x10(%ebp),%eax
80105e08:	c1 e8 02             	shr    $0x2,%eax
80105e0b:	89 c1                	mov    %eax,%ecx
80105e0d:	8b 45 0c             	mov    0xc(%ebp),%eax
80105e10:	c1 e0 18             	shl    $0x18,%eax
80105e13:	89 c2                	mov    %eax,%edx
80105e15:	8b 45 0c             	mov    0xc(%ebp),%eax
80105e18:	c1 e0 10             	shl    $0x10,%eax
80105e1b:	09 c2                	or     %eax,%edx
80105e1d:	8b 45 0c             	mov    0xc(%ebp),%eax
80105e20:	c1 e0 08             	shl    $0x8,%eax
80105e23:	09 d0                	or     %edx,%eax
80105e25:	0b 45 0c             	or     0xc(%ebp),%eax
80105e28:	51                   	push   %ecx
80105e29:	50                   	push   %eax
80105e2a:	ff 75 08             	pushl  0x8(%ebp)
80105e2d:	e8 8f ff ff ff       	call   80105dc1 <stosl>
80105e32:	83 c4 0c             	add    $0xc,%esp
80105e35:	eb 12                	jmp    80105e49 <memset+0x62>
  } else
    stosb(dst, c, n);
80105e37:	8b 45 10             	mov    0x10(%ebp),%eax
80105e3a:	50                   	push   %eax
80105e3b:	ff 75 0c             	pushl  0xc(%ebp)
80105e3e:	ff 75 08             	pushl  0x8(%ebp)
80105e41:	e8 55 ff ff ff       	call   80105d9b <stosb>
80105e46:	83 c4 0c             	add    $0xc,%esp
  return dst;
80105e49:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105e4c:	c9                   	leave  
80105e4d:	c3                   	ret    

80105e4e <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80105e4e:	55                   	push   %ebp
80105e4f:	89 e5                	mov    %esp,%ebp
80105e51:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;
  
  s1 = v1;
80105e54:	8b 45 08             	mov    0x8(%ebp),%eax
80105e57:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
80105e5a:	8b 45 0c             	mov    0xc(%ebp),%eax
80105e5d:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
80105e60:	eb 30                	jmp    80105e92 <memcmp+0x44>
    if(*s1 != *s2)
80105e62:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105e65:	0f b6 10             	movzbl (%eax),%edx
80105e68:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105e6b:	0f b6 00             	movzbl (%eax),%eax
80105e6e:	38 c2                	cmp    %al,%dl
80105e70:	74 18                	je     80105e8a <memcmp+0x3c>
      return *s1 - *s2;
80105e72:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105e75:	0f b6 00             	movzbl (%eax),%eax
80105e78:	0f b6 d0             	movzbl %al,%edx
80105e7b:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105e7e:	0f b6 00             	movzbl (%eax),%eax
80105e81:	0f b6 c0             	movzbl %al,%eax
80105e84:	29 c2                	sub    %eax,%edx
80105e86:	89 d0                	mov    %edx,%eax
80105e88:	eb 1a                	jmp    80105ea4 <memcmp+0x56>
    s1++, s2++;
80105e8a:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105e8e:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  const uchar *s1, *s2;
  
  s1 = v1;
  s2 = v2;
  while(n-- > 0){
80105e92:	8b 45 10             	mov    0x10(%ebp),%eax
80105e95:	8d 50 ff             	lea    -0x1(%eax),%edx
80105e98:	89 55 10             	mov    %edx,0x10(%ebp)
80105e9b:	85 c0                	test   %eax,%eax
80105e9d:	75 c3                	jne    80105e62 <memcmp+0x14>
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
  }

  return 0;
80105e9f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105ea4:	c9                   	leave  
80105ea5:	c3                   	ret    

80105ea6 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80105ea6:	55                   	push   %ebp
80105ea7:	89 e5                	mov    %esp,%ebp
80105ea9:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
80105eac:	8b 45 0c             	mov    0xc(%ebp),%eax
80105eaf:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
80105eb2:	8b 45 08             	mov    0x8(%ebp),%eax
80105eb5:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80105eb8:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105ebb:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105ebe:	73 54                	jae    80105f14 <memmove+0x6e>
80105ec0:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105ec3:	8b 45 10             	mov    0x10(%ebp),%eax
80105ec6:	01 d0                	add    %edx,%eax
80105ec8:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105ecb:	76 47                	jbe    80105f14 <memmove+0x6e>
    s += n;
80105ecd:	8b 45 10             	mov    0x10(%ebp),%eax
80105ed0:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
80105ed3:	8b 45 10             	mov    0x10(%ebp),%eax
80105ed6:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80105ed9:	eb 13                	jmp    80105eee <memmove+0x48>
      *--d = *--s;
80105edb:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
80105edf:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
80105ee3:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105ee6:	0f b6 10             	movzbl (%eax),%edx
80105ee9:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105eec:	88 10                	mov    %dl,(%eax)
  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
    while(n-- > 0)
80105eee:	8b 45 10             	mov    0x10(%ebp),%eax
80105ef1:	8d 50 ff             	lea    -0x1(%eax),%edx
80105ef4:	89 55 10             	mov    %edx,0x10(%ebp)
80105ef7:	85 c0                	test   %eax,%eax
80105ef9:	75 e0                	jne    80105edb <memmove+0x35>
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
80105efb:	eb 24                	jmp    80105f21 <memmove+0x7b>
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
      *d++ = *s++;
80105efd:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105f00:	8d 50 01             	lea    0x1(%eax),%edx
80105f03:	89 55 f8             	mov    %edx,-0x8(%ebp)
80105f06:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105f09:	8d 4a 01             	lea    0x1(%edx),%ecx
80105f0c:	89 4d fc             	mov    %ecx,-0x4(%ebp)
80105f0f:	0f b6 12             	movzbl (%edx),%edx
80105f12:	88 10                	mov    %dl,(%eax)
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
80105f14:	8b 45 10             	mov    0x10(%ebp),%eax
80105f17:	8d 50 ff             	lea    -0x1(%eax),%edx
80105f1a:	89 55 10             	mov    %edx,0x10(%ebp)
80105f1d:	85 c0                	test   %eax,%eax
80105f1f:	75 dc                	jne    80105efd <memmove+0x57>
      *d++ = *s++;

  return dst;
80105f21:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105f24:	c9                   	leave  
80105f25:	c3                   	ret    

80105f26 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80105f26:	55                   	push   %ebp
80105f27:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
80105f29:	ff 75 10             	pushl  0x10(%ebp)
80105f2c:	ff 75 0c             	pushl  0xc(%ebp)
80105f2f:	ff 75 08             	pushl  0x8(%ebp)
80105f32:	e8 6f ff ff ff       	call   80105ea6 <memmove>
80105f37:	83 c4 0c             	add    $0xc,%esp
}
80105f3a:	c9                   	leave  
80105f3b:	c3                   	ret    

80105f3c <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80105f3c:	55                   	push   %ebp
80105f3d:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
80105f3f:	eb 0c                	jmp    80105f4d <strncmp+0x11>
    n--, p++, q++;
80105f41:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105f45:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80105f49:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
80105f4d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105f51:	74 1a                	je     80105f6d <strncmp+0x31>
80105f53:	8b 45 08             	mov    0x8(%ebp),%eax
80105f56:	0f b6 00             	movzbl (%eax),%eax
80105f59:	84 c0                	test   %al,%al
80105f5b:	74 10                	je     80105f6d <strncmp+0x31>
80105f5d:	8b 45 08             	mov    0x8(%ebp),%eax
80105f60:	0f b6 10             	movzbl (%eax),%edx
80105f63:	8b 45 0c             	mov    0xc(%ebp),%eax
80105f66:	0f b6 00             	movzbl (%eax),%eax
80105f69:	38 c2                	cmp    %al,%dl
80105f6b:	74 d4                	je     80105f41 <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
80105f6d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105f71:	75 07                	jne    80105f7a <strncmp+0x3e>
    return 0;
80105f73:	b8 00 00 00 00       	mov    $0x0,%eax
80105f78:	eb 16                	jmp    80105f90 <strncmp+0x54>
  return (uchar)*p - (uchar)*q;
80105f7a:	8b 45 08             	mov    0x8(%ebp),%eax
80105f7d:	0f b6 00             	movzbl (%eax),%eax
80105f80:	0f b6 d0             	movzbl %al,%edx
80105f83:	8b 45 0c             	mov    0xc(%ebp),%eax
80105f86:	0f b6 00             	movzbl (%eax),%eax
80105f89:	0f b6 c0             	movzbl %al,%eax
80105f8c:	29 c2                	sub    %eax,%edx
80105f8e:	89 d0                	mov    %edx,%eax
}
80105f90:	5d                   	pop    %ebp
80105f91:	c3                   	ret    

80105f92 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80105f92:	55                   	push   %ebp
80105f93:	89 e5                	mov    %esp,%ebp
80105f95:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
80105f98:	8b 45 08             	mov    0x8(%ebp),%eax
80105f9b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
80105f9e:	90                   	nop
80105f9f:	8b 45 10             	mov    0x10(%ebp),%eax
80105fa2:	8d 50 ff             	lea    -0x1(%eax),%edx
80105fa5:	89 55 10             	mov    %edx,0x10(%ebp)
80105fa8:	85 c0                	test   %eax,%eax
80105faa:	7e 2c                	jle    80105fd8 <strncpy+0x46>
80105fac:	8b 45 08             	mov    0x8(%ebp),%eax
80105faf:	8d 50 01             	lea    0x1(%eax),%edx
80105fb2:	89 55 08             	mov    %edx,0x8(%ebp)
80105fb5:	8b 55 0c             	mov    0xc(%ebp),%edx
80105fb8:	8d 4a 01             	lea    0x1(%edx),%ecx
80105fbb:	89 4d 0c             	mov    %ecx,0xc(%ebp)
80105fbe:	0f b6 12             	movzbl (%edx),%edx
80105fc1:	88 10                	mov    %dl,(%eax)
80105fc3:	0f b6 00             	movzbl (%eax),%eax
80105fc6:	84 c0                	test   %al,%al
80105fc8:	75 d5                	jne    80105f9f <strncpy+0xd>
    ;
  while(n-- > 0)
80105fca:	eb 0c                	jmp    80105fd8 <strncpy+0x46>
    *s++ = 0;
80105fcc:	8b 45 08             	mov    0x8(%ebp),%eax
80105fcf:	8d 50 01             	lea    0x1(%eax),%edx
80105fd2:	89 55 08             	mov    %edx,0x8(%ebp)
80105fd5:	c6 00 00             	movb   $0x0,(%eax)
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
80105fd8:	8b 45 10             	mov    0x10(%ebp),%eax
80105fdb:	8d 50 ff             	lea    -0x1(%eax),%edx
80105fde:	89 55 10             	mov    %edx,0x10(%ebp)
80105fe1:	85 c0                	test   %eax,%eax
80105fe3:	7f e7                	jg     80105fcc <strncpy+0x3a>
    *s++ = 0;
  return os;
80105fe5:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105fe8:	c9                   	leave  
80105fe9:	c3                   	ret    

80105fea <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80105fea:	55                   	push   %ebp
80105feb:	89 e5                	mov    %esp,%ebp
80105fed:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
80105ff0:	8b 45 08             	mov    0x8(%ebp),%eax
80105ff3:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
80105ff6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105ffa:	7f 05                	jg     80106001 <safestrcpy+0x17>
    return os;
80105ffc:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105fff:	eb 31                	jmp    80106032 <safestrcpy+0x48>
  while(--n > 0 && (*s++ = *t++) != 0)
80106001:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80106005:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80106009:	7e 1e                	jle    80106029 <safestrcpy+0x3f>
8010600b:	8b 45 08             	mov    0x8(%ebp),%eax
8010600e:	8d 50 01             	lea    0x1(%eax),%edx
80106011:	89 55 08             	mov    %edx,0x8(%ebp)
80106014:	8b 55 0c             	mov    0xc(%ebp),%edx
80106017:	8d 4a 01             	lea    0x1(%edx),%ecx
8010601a:	89 4d 0c             	mov    %ecx,0xc(%ebp)
8010601d:	0f b6 12             	movzbl (%edx),%edx
80106020:	88 10                	mov    %dl,(%eax)
80106022:	0f b6 00             	movzbl (%eax),%eax
80106025:	84 c0                	test   %al,%al
80106027:	75 d8                	jne    80106001 <safestrcpy+0x17>
    ;
  *s = 0;
80106029:	8b 45 08             	mov    0x8(%ebp),%eax
8010602c:	c6 00 00             	movb   $0x0,(%eax)
  return os;
8010602f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106032:	c9                   	leave  
80106033:	c3                   	ret    

80106034 <strlen>:

int
strlen(const char *s)
{
80106034:	55                   	push   %ebp
80106035:	89 e5                	mov    %esp,%ebp
80106037:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
8010603a:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80106041:	eb 04                	jmp    80106047 <strlen+0x13>
80106043:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80106047:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010604a:	8b 45 08             	mov    0x8(%ebp),%eax
8010604d:	01 d0                	add    %edx,%eax
8010604f:	0f b6 00             	movzbl (%eax),%eax
80106052:	84 c0                	test   %al,%al
80106054:	75 ed                	jne    80106043 <strlen+0xf>
    ;
  return n;
80106056:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106059:	c9                   	leave  
8010605a:	c3                   	ret    

8010605b <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
8010605b:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
8010605f:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
80106063:	55                   	push   %ebp
  pushl %ebx
80106064:	53                   	push   %ebx
  pushl %esi
80106065:	56                   	push   %esi
  pushl %edi
80106066:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80106067:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80106069:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
8010606b:	5f                   	pop    %edi
  popl %esi
8010606c:	5e                   	pop    %esi
  popl %ebx
8010606d:	5b                   	pop    %ebx
  popl %ebp
8010606e:	5d                   	pop    %ebp
  ret
8010606f:	c3                   	ret    

80106070 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80106070:	55                   	push   %ebp
80106071:	89 e5                	mov    %esp,%ebp
  if(addr >= proc->sz || addr+4 > proc->sz)
80106073:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106079:	8b 00                	mov    (%eax),%eax
8010607b:	3b 45 08             	cmp    0x8(%ebp),%eax
8010607e:	76 12                	jbe    80106092 <fetchint+0x22>
80106080:	8b 45 08             	mov    0x8(%ebp),%eax
80106083:	8d 50 04             	lea    0x4(%eax),%edx
80106086:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010608c:	8b 00                	mov    (%eax),%eax
8010608e:	39 c2                	cmp    %eax,%edx
80106090:	76 07                	jbe    80106099 <fetchint+0x29>
    return -1;
80106092:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106097:	eb 0f                	jmp    801060a8 <fetchint+0x38>
  *ip = *(int*)(addr);
80106099:	8b 45 08             	mov    0x8(%ebp),%eax
8010609c:	8b 10                	mov    (%eax),%edx
8010609e:	8b 45 0c             	mov    0xc(%ebp),%eax
801060a1:	89 10                	mov    %edx,(%eax)
  return 0;
801060a3:	b8 00 00 00 00       	mov    $0x0,%eax
}
801060a8:	5d                   	pop    %ebp
801060a9:	c3                   	ret    

801060aa <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
801060aa:	55                   	push   %ebp
801060ab:	89 e5                	mov    %esp,%ebp
801060ad:	83 ec 10             	sub    $0x10,%esp
  char *s, *ep;

  if(addr >= proc->sz)
801060b0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801060b6:	8b 00                	mov    (%eax),%eax
801060b8:	3b 45 08             	cmp    0x8(%ebp),%eax
801060bb:	77 07                	ja     801060c4 <fetchstr+0x1a>
    return -1;
801060bd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060c2:	eb 46                	jmp    8010610a <fetchstr+0x60>
  *pp = (char*)addr;
801060c4:	8b 55 08             	mov    0x8(%ebp),%edx
801060c7:	8b 45 0c             	mov    0xc(%ebp),%eax
801060ca:	89 10                	mov    %edx,(%eax)
  ep = (char*)proc->sz;
801060cc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801060d2:	8b 00                	mov    (%eax),%eax
801060d4:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(s = *pp; s < ep; s++)
801060d7:	8b 45 0c             	mov    0xc(%ebp),%eax
801060da:	8b 00                	mov    (%eax),%eax
801060dc:	89 45 fc             	mov    %eax,-0x4(%ebp)
801060df:	eb 1c                	jmp    801060fd <fetchstr+0x53>
    if(*s == 0)
801060e1:	8b 45 fc             	mov    -0x4(%ebp),%eax
801060e4:	0f b6 00             	movzbl (%eax),%eax
801060e7:	84 c0                	test   %al,%al
801060e9:	75 0e                	jne    801060f9 <fetchstr+0x4f>
      return s - *pp;
801060eb:	8b 55 fc             	mov    -0x4(%ebp),%edx
801060ee:	8b 45 0c             	mov    0xc(%ebp),%eax
801060f1:	8b 00                	mov    (%eax),%eax
801060f3:	29 c2                	sub    %eax,%edx
801060f5:	89 d0                	mov    %edx,%eax
801060f7:	eb 11                	jmp    8010610a <fetchstr+0x60>

  if(addr >= proc->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)proc->sz;
  for(s = *pp; s < ep; s++)
801060f9:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801060fd:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106100:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80106103:	72 dc                	jb     801060e1 <fetchstr+0x37>
    if(*s == 0)
      return s - *pp;
  return -1;
80106105:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010610a:	c9                   	leave  
8010610b:	c3                   	ret    

8010610c <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
8010610c:	55                   	push   %ebp
8010610d:	89 e5                	mov    %esp,%ebp
  return fetchint(proc->tf->esp + 4 + 4*n, ip);
8010610f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106115:	8b 40 18             	mov    0x18(%eax),%eax
80106118:	8b 40 44             	mov    0x44(%eax),%eax
8010611b:	8b 55 08             	mov    0x8(%ebp),%edx
8010611e:	c1 e2 02             	shl    $0x2,%edx
80106121:	01 d0                	add    %edx,%eax
80106123:	83 c0 04             	add    $0x4,%eax
80106126:	ff 75 0c             	pushl  0xc(%ebp)
80106129:	50                   	push   %eax
8010612a:	e8 41 ff ff ff       	call   80106070 <fetchint>
8010612f:	83 c4 08             	add    $0x8,%esp
}
80106132:	c9                   	leave  
80106133:	c3                   	ret    

80106134 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size n bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80106134:	55                   	push   %ebp
80106135:	89 e5                	mov    %esp,%ebp
80106137:	83 ec 10             	sub    $0x10,%esp
  int i;
  
  if(argint(n, &i) < 0)
8010613a:	8d 45 fc             	lea    -0x4(%ebp),%eax
8010613d:	50                   	push   %eax
8010613e:	ff 75 08             	pushl  0x8(%ebp)
80106141:	e8 c6 ff ff ff       	call   8010610c <argint>
80106146:	83 c4 08             	add    $0x8,%esp
80106149:	85 c0                	test   %eax,%eax
8010614b:	79 07                	jns    80106154 <argptr+0x20>
    return -1;
8010614d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106152:	eb 3b                	jmp    8010618f <argptr+0x5b>
  if((uint)i >= proc->sz || (uint)i+size > proc->sz)
80106154:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010615a:	8b 00                	mov    (%eax),%eax
8010615c:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010615f:	39 d0                	cmp    %edx,%eax
80106161:	76 16                	jbe    80106179 <argptr+0x45>
80106163:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106166:	89 c2                	mov    %eax,%edx
80106168:	8b 45 10             	mov    0x10(%ebp),%eax
8010616b:	01 c2                	add    %eax,%edx
8010616d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106173:	8b 00                	mov    (%eax),%eax
80106175:	39 c2                	cmp    %eax,%edx
80106177:	76 07                	jbe    80106180 <argptr+0x4c>
    return -1;
80106179:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010617e:	eb 0f                	jmp    8010618f <argptr+0x5b>
  *pp = (char*)i;
80106180:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106183:	89 c2                	mov    %eax,%edx
80106185:	8b 45 0c             	mov    0xc(%ebp),%eax
80106188:	89 10                	mov    %edx,(%eax)
  return 0;
8010618a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010618f:	c9                   	leave  
80106190:	c3                   	ret    

80106191 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80106191:	55                   	push   %ebp
80106192:	89 e5                	mov    %esp,%ebp
80106194:	83 ec 10             	sub    $0x10,%esp
  int addr;
  if(argint(n, &addr) < 0)
80106197:	8d 45 fc             	lea    -0x4(%ebp),%eax
8010619a:	50                   	push   %eax
8010619b:	ff 75 08             	pushl  0x8(%ebp)
8010619e:	e8 69 ff ff ff       	call   8010610c <argint>
801061a3:	83 c4 08             	add    $0x8,%esp
801061a6:	85 c0                	test   %eax,%eax
801061a8:	79 07                	jns    801061b1 <argstr+0x20>
    return -1;
801061aa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801061af:	eb 0f                	jmp    801061c0 <argstr+0x2f>
  return fetchstr(addr, pp);
801061b1:	8b 45 fc             	mov    -0x4(%ebp),%eax
801061b4:	ff 75 0c             	pushl  0xc(%ebp)
801061b7:	50                   	push   %eax
801061b8:	e8 ed fe ff ff       	call   801060aa <fetchstr>
801061bd:	83 c4 08             	add    $0x8,%esp
}
801061c0:	c9                   	leave  
801061c1:	c3                   	ret    

801061c2 <syscall>:
[SYS_mount]   sys_mount,
};

void
syscall(void)
{
801061c2:	55                   	push   %ebp
801061c3:	89 e5                	mov    %esp,%ebp
801061c5:	53                   	push   %ebx
801061c6:	83 ec 14             	sub    $0x14,%esp
  int num;

  num = proc->tf->eax;
801061c9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801061cf:	8b 40 18             	mov    0x18(%eax),%eax
801061d2:	8b 40 1c             	mov    0x1c(%eax),%eax
801061d5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
801061d8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801061dc:	7e 30                	jle    8010620e <syscall+0x4c>
801061de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061e1:	83 f8 16             	cmp    $0x16,%eax
801061e4:	77 28                	ja     8010620e <syscall+0x4c>
801061e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061e9:	8b 04 85 40 c0 10 80 	mov    -0x7fef3fc0(,%eax,4),%eax
801061f0:	85 c0                	test   %eax,%eax
801061f2:	74 1a                	je     8010620e <syscall+0x4c>
    proc->tf->eax = syscalls[num]();
801061f4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801061fa:	8b 58 18             	mov    0x18(%eax),%ebx
801061fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106200:	8b 04 85 40 c0 10 80 	mov    -0x7fef3fc0(,%eax,4),%eax
80106207:	ff d0                	call   *%eax
80106209:	89 43 1c             	mov    %eax,0x1c(%ebx)
8010620c:	eb 34                	jmp    80106242 <syscall+0x80>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            proc->pid, proc->name, num);
8010620e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106214:	8d 50 6c             	lea    0x6c(%eax),%edx
80106217:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax

  num = proc->tf->eax;
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    proc->tf->eax = syscalls[num]();
  } else {
    cprintf("%d %s: unknown sys call %d\n",
8010621d:	8b 40 10             	mov    0x10(%eax),%eax
80106220:	ff 75 f4             	pushl  -0xc(%ebp)
80106223:	52                   	push   %edx
80106224:	50                   	push   %eax
80106225:	68 d8 98 10 80       	push   $0x801098d8
8010622a:	e8 97 a1 ff ff       	call   801003c6 <cprintf>
8010622f:	83 c4 10             	add    $0x10,%esp
            proc->pid, proc->name, num);
    proc->tf->eax = -1;
80106232:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106238:	8b 40 18             	mov    0x18(%eax),%eax
8010623b:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
80106242:	90                   	nop
80106243:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80106246:	c9                   	leave  
80106247:	c3                   	ret    

80106248 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.

static int argfd(int n, int* pfd, struct file** pf)
{
80106248:	55                   	push   %ebp
80106249:	89 e5                	mov    %esp,%ebp
8010624b:	83 ec 18             	sub    $0x18,%esp
    int fd;
    struct file* f;

    if (argint(n, &fd) < 0)
8010624e:	83 ec 08             	sub    $0x8,%esp
80106251:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106254:	50                   	push   %eax
80106255:	ff 75 08             	pushl  0x8(%ebp)
80106258:	e8 af fe ff ff       	call   8010610c <argint>
8010625d:	83 c4 10             	add    $0x10,%esp
80106260:	85 c0                	test   %eax,%eax
80106262:	79 07                	jns    8010626b <argfd+0x23>
        return -1;
80106264:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106269:	eb 50                	jmp    801062bb <argfd+0x73>
    if (fd < 0 || fd >= NOFILE || (f = proc->ofile[fd]) == 0)
8010626b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010626e:	85 c0                	test   %eax,%eax
80106270:	78 21                	js     80106293 <argfd+0x4b>
80106272:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106275:	83 f8 0f             	cmp    $0xf,%eax
80106278:	7f 19                	jg     80106293 <argfd+0x4b>
8010627a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106280:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106283:	83 c2 08             	add    $0x8,%edx
80106286:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010628a:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010628d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106291:	75 07                	jne    8010629a <argfd+0x52>
        return -1;
80106293:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106298:	eb 21                	jmp    801062bb <argfd+0x73>
    if (pfd)
8010629a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010629e:	74 08                	je     801062a8 <argfd+0x60>
        *pfd = fd;
801062a0:	8b 55 f0             	mov    -0x10(%ebp),%edx
801062a3:	8b 45 0c             	mov    0xc(%ebp),%eax
801062a6:	89 10                	mov    %edx,(%eax)
    if (pf)
801062a8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801062ac:	74 08                	je     801062b6 <argfd+0x6e>
        *pf = f;
801062ae:	8b 45 10             	mov    0x10(%ebp),%eax
801062b1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801062b4:	89 10                	mov    %edx,(%eax)
    return 0;
801062b6:	b8 00 00 00 00       	mov    $0x0,%eax
}
801062bb:	c9                   	leave  
801062bc:	c3                   	ret    

801062bd <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int fdalloc(struct file* f)
{
801062bd:	55                   	push   %ebp
801062be:	89 e5                	mov    %esp,%ebp
801062c0:	83 ec 10             	sub    $0x10,%esp
    int fd;

    for (fd = 0; fd < NOFILE; fd++) {
801062c3:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801062ca:	eb 30                	jmp    801062fc <fdalloc+0x3f>
        if (proc->ofile[fd] == 0) {
801062cc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801062d2:	8b 55 fc             	mov    -0x4(%ebp),%edx
801062d5:	83 c2 08             	add    $0x8,%edx
801062d8:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801062dc:	85 c0                	test   %eax,%eax
801062de:	75 18                	jne    801062f8 <fdalloc+0x3b>
            proc->ofile[fd] = f;
801062e0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801062e6:	8b 55 fc             	mov    -0x4(%ebp),%edx
801062e9:	8d 4a 08             	lea    0x8(%edx),%ecx
801062ec:	8b 55 08             	mov    0x8(%ebp),%edx
801062ef:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
            return fd;
801062f3:	8b 45 fc             	mov    -0x4(%ebp),%eax
801062f6:	eb 0f                	jmp    80106307 <fdalloc+0x4a>
// Takes over file reference from caller on success.
static int fdalloc(struct file* f)
{
    int fd;

    for (fd = 0; fd < NOFILE; fd++) {
801062f8:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801062fc:	83 7d fc 0f          	cmpl   $0xf,-0x4(%ebp)
80106300:	7e ca                	jle    801062cc <fdalloc+0xf>
        if (proc->ofile[fd] == 0) {
            proc->ofile[fd] = f;
            return fd;
        }
    }
    return -1;
80106302:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80106307:	c9                   	leave  
80106308:	c3                   	ret    

80106309 <sys_dup>:

int sys_dup(void)
{
80106309:	55                   	push   %ebp
8010630a:	89 e5                	mov    %esp,%ebp
8010630c:	83 ec 18             	sub    $0x18,%esp
    struct file* f;
    int fd;

    if (argfd(0, 0, &f) < 0)
8010630f:	83 ec 04             	sub    $0x4,%esp
80106312:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106315:	50                   	push   %eax
80106316:	6a 00                	push   $0x0
80106318:	6a 00                	push   $0x0
8010631a:	e8 29 ff ff ff       	call   80106248 <argfd>
8010631f:	83 c4 10             	add    $0x10,%esp
80106322:	85 c0                	test   %eax,%eax
80106324:	79 07                	jns    8010632d <sys_dup+0x24>
        return -1;
80106326:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010632b:	eb 31                	jmp    8010635e <sys_dup+0x55>
    if ((fd = fdalloc(f)) < 0)
8010632d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106330:	83 ec 0c             	sub    $0xc,%esp
80106333:	50                   	push   %eax
80106334:	e8 84 ff ff ff       	call   801062bd <fdalloc>
80106339:	83 c4 10             	add    $0x10,%esp
8010633c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010633f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106343:	79 07                	jns    8010634c <sys_dup+0x43>
        return -1;
80106345:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010634a:	eb 12                	jmp    8010635e <sys_dup+0x55>
    filedup(f);
8010634c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010634f:	83 ec 0c             	sub    $0xc,%esp
80106352:	50                   	push   %eax
80106353:	e8 00 ad ff ff       	call   80101058 <filedup>
80106358:	83 c4 10             	add    $0x10,%esp
    return fd;
8010635b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010635e:	c9                   	leave  
8010635f:	c3                   	ret    

80106360 <sys_read>:

int sys_read(void)
{
80106360:	55                   	push   %ebp
80106361:	89 e5                	mov    %esp,%ebp
80106363:	83 ec 18             	sub    $0x18,%esp
    struct file* f;
    int n;
    char* p;

    if (argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80106366:	83 ec 04             	sub    $0x4,%esp
80106369:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010636c:	50                   	push   %eax
8010636d:	6a 00                	push   $0x0
8010636f:	6a 00                	push   $0x0
80106371:	e8 d2 fe ff ff       	call   80106248 <argfd>
80106376:	83 c4 10             	add    $0x10,%esp
80106379:	85 c0                	test   %eax,%eax
8010637b:	78 2e                	js     801063ab <sys_read+0x4b>
8010637d:	83 ec 08             	sub    $0x8,%esp
80106380:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106383:	50                   	push   %eax
80106384:	6a 02                	push   $0x2
80106386:	e8 81 fd ff ff       	call   8010610c <argint>
8010638b:	83 c4 10             	add    $0x10,%esp
8010638e:	85 c0                	test   %eax,%eax
80106390:	78 19                	js     801063ab <sys_read+0x4b>
80106392:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106395:	83 ec 04             	sub    $0x4,%esp
80106398:	50                   	push   %eax
80106399:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010639c:	50                   	push   %eax
8010639d:	6a 01                	push   $0x1
8010639f:	e8 90 fd ff ff       	call   80106134 <argptr>
801063a4:	83 c4 10             	add    $0x10,%esp
801063a7:	85 c0                	test   %eax,%eax
801063a9:	79 07                	jns    801063b2 <sys_read+0x52>
        return -1;
801063ab:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063b0:	eb 17                	jmp    801063c9 <sys_read+0x69>
    return fileread(f, p, n);
801063b2:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801063b5:	8b 55 ec             	mov    -0x14(%ebp),%edx
801063b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063bb:	83 ec 04             	sub    $0x4,%esp
801063be:	51                   	push   %ecx
801063bf:	52                   	push   %edx
801063c0:	50                   	push   %eax
801063c1:	e8 4a ae ff ff       	call   80101210 <fileread>
801063c6:	83 c4 10             	add    $0x10,%esp
}
801063c9:	c9                   	leave  
801063ca:	c3                   	ret    

801063cb <sys_write>:

int sys_write(void)
{
801063cb:	55                   	push   %ebp
801063cc:	89 e5                	mov    %esp,%ebp
801063ce:	83 ec 18             	sub    $0x18,%esp
    struct file* f;
    int n;
    char* p;

    if (argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801063d1:	83 ec 04             	sub    $0x4,%esp
801063d4:	8d 45 f4             	lea    -0xc(%ebp),%eax
801063d7:	50                   	push   %eax
801063d8:	6a 00                	push   $0x0
801063da:	6a 00                	push   $0x0
801063dc:	e8 67 fe ff ff       	call   80106248 <argfd>
801063e1:	83 c4 10             	add    $0x10,%esp
801063e4:	85 c0                	test   %eax,%eax
801063e6:	78 2e                	js     80106416 <sys_write+0x4b>
801063e8:	83 ec 08             	sub    $0x8,%esp
801063eb:	8d 45 f0             	lea    -0x10(%ebp),%eax
801063ee:	50                   	push   %eax
801063ef:	6a 02                	push   $0x2
801063f1:	e8 16 fd ff ff       	call   8010610c <argint>
801063f6:	83 c4 10             	add    $0x10,%esp
801063f9:	85 c0                	test   %eax,%eax
801063fb:	78 19                	js     80106416 <sys_write+0x4b>
801063fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106400:	83 ec 04             	sub    $0x4,%esp
80106403:	50                   	push   %eax
80106404:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106407:	50                   	push   %eax
80106408:	6a 01                	push   $0x1
8010640a:	e8 25 fd ff ff       	call   80106134 <argptr>
8010640f:	83 c4 10             	add    $0x10,%esp
80106412:	85 c0                	test   %eax,%eax
80106414:	79 07                	jns    8010641d <sys_write+0x52>
        return -1;
80106416:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010641b:	eb 17                	jmp    80106434 <sys_write+0x69>
    return filewrite(f, p, n);
8010641d:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80106420:	8b 55 ec             	mov    -0x14(%ebp),%edx
80106423:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106426:	83 ec 04             	sub    $0x4,%esp
80106429:	51                   	push   %ecx
8010642a:	52                   	push   %edx
8010642b:	50                   	push   %eax
8010642c:	e8 97 ae ff ff       	call   801012c8 <filewrite>
80106431:	83 c4 10             	add    $0x10,%esp
}
80106434:	c9                   	leave  
80106435:	c3                   	ret    

80106436 <sys_close>:

int sys_close(void)
{
80106436:	55                   	push   %ebp
80106437:	89 e5                	mov    %esp,%ebp
80106439:	83 ec 18             	sub    $0x18,%esp
    int fd;
    struct file* f;

    if (argfd(0, &fd, &f) < 0)
8010643c:	83 ec 04             	sub    $0x4,%esp
8010643f:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106442:	50                   	push   %eax
80106443:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106446:	50                   	push   %eax
80106447:	6a 00                	push   $0x0
80106449:	e8 fa fd ff ff       	call   80106248 <argfd>
8010644e:	83 c4 10             	add    $0x10,%esp
80106451:	85 c0                	test   %eax,%eax
80106453:	79 07                	jns    8010645c <sys_close+0x26>
        return -1;
80106455:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010645a:	eb 28                	jmp    80106484 <sys_close+0x4e>
    proc->ofile[fd] = 0;
8010645c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106462:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106465:	83 c2 08             	add    $0x8,%edx
80106468:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
8010646f:	00 
    fileclose(f);
80106470:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106473:	83 ec 0c             	sub    $0xc,%esp
80106476:	50                   	push   %eax
80106477:	e8 2d ac ff ff       	call   801010a9 <fileclose>
8010647c:	83 c4 10             	add    $0x10,%esp
    return 0;
8010647f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106484:	c9                   	leave  
80106485:	c3                   	ret    

80106486 <sys_fstat>:

int sys_fstat(void)
{
80106486:	55                   	push   %ebp
80106487:	89 e5                	mov    %esp,%ebp
80106489:	83 ec 18             	sub    $0x18,%esp
    struct file* f;
    struct stat* st;

    if (argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
8010648c:	83 ec 04             	sub    $0x4,%esp
8010648f:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106492:	50                   	push   %eax
80106493:	6a 00                	push   $0x0
80106495:	6a 00                	push   $0x0
80106497:	e8 ac fd ff ff       	call   80106248 <argfd>
8010649c:	83 c4 10             	add    $0x10,%esp
8010649f:	85 c0                	test   %eax,%eax
801064a1:	78 17                	js     801064ba <sys_fstat+0x34>
801064a3:	83 ec 04             	sub    $0x4,%esp
801064a6:	6a 14                	push   $0x14
801064a8:	8d 45 f0             	lea    -0x10(%ebp),%eax
801064ab:	50                   	push   %eax
801064ac:	6a 01                	push   $0x1
801064ae:	e8 81 fc ff ff       	call   80106134 <argptr>
801064b3:	83 c4 10             	add    $0x10,%esp
801064b6:	85 c0                	test   %eax,%eax
801064b8:	79 07                	jns    801064c1 <sys_fstat+0x3b>
        return -1;
801064ba:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064bf:	eb 13                	jmp    801064d4 <sys_fstat+0x4e>
    return filestat(f, st);
801064c1:	8b 55 f0             	mov    -0x10(%ebp),%edx
801064c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064c7:	83 ec 08             	sub    $0x8,%esp
801064ca:	52                   	push   %edx
801064cb:	50                   	push   %eax
801064cc:	e8 e8 ac ff ff       	call   801011b9 <filestat>
801064d1:	83 c4 10             	add    $0x10,%esp
}
801064d4:	c9                   	leave  
801064d5:	c3                   	ret    

801064d6 <sys_link>:

// Create the path new as a link to the same inode as old.
int sys_link(void)
{
801064d6:	55                   	push   %ebp
801064d7:	89 e5                	mov    %esp,%ebp
801064d9:	83 ec 28             	sub    $0x28,%esp
    char name[DIRSIZ], *new, *old;
    struct inode* dp, *ip;

    if (argstr(0, &old) < 0 || argstr(1, &new) < 0)
801064dc:	83 ec 08             	sub    $0x8,%esp
801064df:	8d 45 d8             	lea    -0x28(%ebp),%eax
801064e2:	50                   	push   %eax
801064e3:	6a 00                	push   $0x0
801064e5:	e8 a7 fc ff ff       	call   80106191 <argstr>
801064ea:	83 c4 10             	add    $0x10,%esp
801064ed:	85 c0                	test   %eax,%eax
801064ef:	78 15                	js     80106506 <sys_link+0x30>
801064f1:	83 ec 08             	sub    $0x8,%esp
801064f4:	8d 45 dc             	lea    -0x24(%ebp),%eax
801064f7:	50                   	push   %eax
801064f8:	6a 01                	push   $0x1
801064fa:	e8 92 fc ff ff       	call   80106191 <argstr>
801064ff:	83 c4 10             	add    $0x10,%esp
80106502:	85 c0                	test   %eax,%eax
80106504:	79 0a                	jns    80106510 <sys_link+0x3a>
        return -1;
80106506:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010650b:	e9 da 01 00 00       	jmp    801066ea <sys_link+0x214>

    begin_op(proc->cwd->part->number);
80106510:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106516:	8b 40 68             	mov    0x68(%eax),%eax
80106519:	8b 40 50             	mov    0x50(%eax),%eax
8010651c:	8b 40 14             	mov    0x14(%eax),%eax
8010651f:	83 ec 0c             	sub    $0xc,%esp
80106522:	50                   	push   %eax
80106523:	e8 68 d9 ff ff       	call   80103e90 <begin_op>
80106528:	83 c4 10             	add    $0x10,%esp
    if ((ip = namei(old)) == 0) {
8010652b:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010652e:	83 ec 0c             	sub    $0xc,%esp
80106531:	50                   	push   %eax
80106532:	e8 c4 c7 ff ff       	call   80102cfb <namei>
80106537:	83 c4 10             	add    $0x10,%esp
8010653a:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010653d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106541:	75 25                	jne    80106568 <sys_link+0x92>
        end_op(proc->cwd->part->number);
80106543:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106549:	8b 40 68             	mov    0x68(%eax),%eax
8010654c:	8b 40 50             	mov    0x50(%eax),%eax
8010654f:	8b 40 14             	mov    0x14(%eax),%eax
80106552:	83 ec 0c             	sub    $0xc,%esp
80106555:	50                   	push   %eax
80106556:	e8 3c da ff ff       	call   80103f97 <end_op>
8010655b:	83 c4 10             	add    $0x10,%esp
        return -1;
8010655e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106563:	e9 82 01 00 00       	jmp    801066ea <sys_link+0x214>
    }

    ilock(ip);
80106568:	83 ec 0c             	sub    $0xc,%esp
8010656b:	ff 75 f4             	pushl  -0xc(%ebp)
8010656e:	e8 77 b9 ff ff       	call   80101eea <ilock>
80106573:	83 c4 10             	add    $0x10,%esp
    if (ip->type == T_DIR) {
80106576:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106579:	0f b7 40 10          	movzwl 0x10(%eax),%eax
8010657d:	66 83 f8 01          	cmp    $0x1,%ax
80106581:	75 33                	jne    801065b6 <sys_link+0xe0>
        iunlockput(ip);
80106583:	83 ec 0c             	sub    $0xc,%esp
80106586:	ff 75 f4             	pushl  -0xc(%ebp)
80106589:	e8 5f bc ff ff       	call   801021ed <iunlockput>
8010658e:	83 c4 10             	add    $0x10,%esp
        end_op(proc->cwd->part->number);
80106591:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106597:	8b 40 68             	mov    0x68(%eax),%eax
8010659a:	8b 40 50             	mov    0x50(%eax),%eax
8010659d:	8b 40 14             	mov    0x14(%eax),%eax
801065a0:	83 ec 0c             	sub    $0xc,%esp
801065a3:	50                   	push   %eax
801065a4:	e8 ee d9 ff ff       	call   80103f97 <end_op>
801065a9:	83 c4 10             	add    $0x10,%esp
        return -1;
801065ac:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065b1:	e9 34 01 00 00       	jmp    801066ea <sys_link+0x214>
    }

    ip->nlink++;
801065b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065b9:	0f b7 40 16          	movzwl 0x16(%eax),%eax
801065bd:	83 c0 01             	add    $0x1,%eax
801065c0:	89 c2                	mov    %eax,%edx
801065c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065c5:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(ip);
801065c9:	83 ec 0c             	sub    $0xc,%esp
801065cc:	ff 75 f4             	pushl  -0xc(%ebp)
801065cf:	e8 b8 b6 ff ff       	call   80101c8c <iupdate>
801065d4:	83 c4 10             	add    $0x10,%esp
    iunlock(ip);
801065d7:	83 ec 0c             	sub    $0xc,%esp
801065da:	ff 75 f4             	pushl  -0xc(%ebp)
801065dd:	e8 a9 ba ff ff       	call   8010208b <iunlock>
801065e2:	83 c4 10             	add    $0x10,%esp

    if ((dp = nameiparent(new, name)) == 0)
801065e5:	8b 45 dc             	mov    -0x24(%ebp),%eax
801065e8:	83 ec 08             	sub    $0x8,%esp
801065eb:	8d 55 e2             	lea    -0x1e(%ebp),%edx
801065ee:	52                   	push   %edx
801065ef:	50                   	push   %eax
801065f0:	e8 3c c7 ff ff       	call   80102d31 <nameiparent>
801065f5:	83 c4 10             	add    $0x10,%esp
801065f8:	89 45 f0             	mov    %eax,-0x10(%ebp)
801065fb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801065ff:	0f 84 87 00 00 00    	je     8010668c <sys_link+0x1b6>
        goto bad;
    ilock(dp);
80106605:	83 ec 0c             	sub    $0xc,%esp
80106608:	ff 75 f0             	pushl  -0x10(%ebp)
8010660b:	e8 da b8 ff ff       	call   80101eea <ilock>
80106610:	83 c4 10             	add    $0x10,%esp
    if (dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0) {
80106613:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106616:	8b 10                	mov    (%eax),%edx
80106618:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010661b:	8b 00                	mov    (%eax),%eax
8010661d:	39 c2                	cmp    %eax,%edx
8010661f:	75 1d                	jne    8010663e <sys_link+0x168>
80106621:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106624:	8b 40 04             	mov    0x4(%eax),%eax
80106627:	83 ec 04             	sub    $0x4,%esp
8010662a:	50                   	push   %eax
8010662b:	8d 45 e2             	lea    -0x1e(%ebp),%eax
8010662e:	50                   	push   %eax
8010662f:	ff 75 f0             	pushl  -0x10(%ebp)
80106632:	e8 9e c3 ff ff       	call   801029d5 <dirlink>
80106637:	83 c4 10             	add    $0x10,%esp
8010663a:	85 c0                	test   %eax,%eax
8010663c:	79 10                	jns    8010664e <sys_link+0x178>
        iunlockput(dp);
8010663e:	83 ec 0c             	sub    $0xc,%esp
80106641:	ff 75 f0             	pushl  -0x10(%ebp)
80106644:	e8 a4 bb ff ff       	call   801021ed <iunlockput>
80106649:	83 c4 10             	add    $0x10,%esp
        goto bad;
8010664c:	eb 3f                	jmp    8010668d <sys_link+0x1b7>
    }
    iunlockput(dp);
8010664e:	83 ec 0c             	sub    $0xc,%esp
80106651:	ff 75 f0             	pushl  -0x10(%ebp)
80106654:	e8 94 bb ff ff       	call   801021ed <iunlockput>
80106659:	83 c4 10             	add    $0x10,%esp
    iput(ip);
8010665c:	83 ec 0c             	sub    $0xc,%esp
8010665f:	ff 75 f4             	pushl  -0xc(%ebp)
80106662:	e8 96 ba ff ff       	call   801020fd <iput>
80106667:	83 c4 10             	add    $0x10,%esp

    end_op(proc->cwd->part->number);
8010666a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106670:	8b 40 68             	mov    0x68(%eax),%eax
80106673:	8b 40 50             	mov    0x50(%eax),%eax
80106676:	8b 40 14             	mov    0x14(%eax),%eax
80106679:	83 ec 0c             	sub    $0xc,%esp
8010667c:	50                   	push   %eax
8010667d:	e8 15 d9 ff ff       	call   80103f97 <end_op>
80106682:	83 c4 10             	add    $0x10,%esp

    return 0;
80106685:	b8 00 00 00 00       	mov    $0x0,%eax
8010668a:	eb 5e                	jmp    801066ea <sys_link+0x214>
    ip->nlink++;
    iupdate(ip);
    iunlock(ip);

    if ((dp = nameiparent(new, name)) == 0)
        goto bad;
8010668c:	90                   	nop
    end_op(proc->cwd->part->number);

    return 0;

bad:
    ilock(ip);
8010668d:	83 ec 0c             	sub    $0xc,%esp
80106690:	ff 75 f4             	pushl  -0xc(%ebp)
80106693:	e8 52 b8 ff ff       	call   80101eea <ilock>
80106698:	83 c4 10             	add    $0x10,%esp
    ip->nlink--;
8010669b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010669e:	0f b7 40 16          	movzwl 0x16(%eax),%eax
801066a2:	83 e8 01             	sub    $0x1,%eax
801066a5:	89 c2                	mov    %eax,%edx
801066a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066aa:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(ip);
801066ae:	83 ec 0c             	sub    $0xc,%esp
801066b1:	ff 75 f4             	pushl  -0xc(%ebp)
801066b4:	e8 d3 b5 ff ff       	call   80101c8c <iupdate>
801066b9:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
801066bc:	83 ec 0c             	sub    $0xc,%esp
801066bf:	ff 75 f4             	pushl  -0xc(%ebp)
801066c2:	e8 26 bb ff ff       	call   801021ed <iunlockput>
801066c7:	83 c4 10             	add    $0x10,%esp
    end_op(proc->cwd->part->number);
801066ca:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801066d0:	8b 40 68             	mov    0x68(%eax),%eax
801066d3:	8b 40 50             	mov    0x50(%eax),%eax
801066d6:	8b 40 14             	mov    0x14(%eax),%eax
801066d9:	83 ec 0c             	sub    $0xc,%esp
801066dc:	50                   	push   %eax
801066dd:	e8 b5 d8 ff ff       	call   80103f97 <end_op>
801066e2:	83 c4 10             	add    $0x10,%esp
    return -1;
801066e5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801066ea:	c9                   	leave  
801066eb:	c3                   	ret    

801066ec <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int isdirempty(struct inode* dp)
{
801066ec:	55                   	push   %ebp
801066ed:	89 e5                	mov    %esp,%ebp
801066ef:	83 ec 28             	sub    $0x28,%esp
    int off;
    struct dirent de;

    for (off = 2 * sizeof(de); off < dp->size; off += sizeof(de)) {
801066f2:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
801066f9:	eb 40                	jmp    8010673b <isdirempty+0x4f>
        if (readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801066fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066fe:	6a 10                	push   $0x10
80106700:	50                   	push   %eax
80106701:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106704:	50                   	push   %eax
80106705:	ff 75 08             	pushl  0x8(%ebp)
80106708:	e8 6b be ff ff       	call   80102578 <readi>
8010670d:	83 c4 10             	add    $0x10,%esp
80106710:	83 f8 10             	cmp    $0x10,%eax
80106713:	74 0d                	je     80106722 <isdirempty+0x36>
            panic("isdirempty: readi");
80106715:	83 ec 0c             	sub    $0xc,%esp
80106718:	68 f4 98 10 80       	push   $0x801098f4
8010671d:	e8 44 9e ff ff       	call   80100566 <panic>
        if (de.inum != 0)
80106722:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
80106726:	66 85 c0             	test   %ax,%ax
80106729:	74 07                	je     80106732 <isdirempty+0x46>
            return 0;
8010672b:	b8 00 00 00 00       	mov    $0x0,%eax
80106730:	eb 1b                	jmp    8010674d <isdirempty+0x61>
static int isdirempty(struct inode* dp)
{
    int off;
    struct dirent de;

    for (off = 2 * sizeof(de); off < dp->size; off += sizeof(de)) {
80106732:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106735:	83 c0 10             	add    $0x10,%eax
80106738:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010673b:	8b 45 08             	mov    0x8(%ebp),%eax
8010673e:	8b 50 18             	mov    0x18(%eax),%edx
80106741:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106744:	39 c2                	cmp    %eax,%edx
80106746:	77 b3                	ja     801066fb <isdirempty+0xf>
        if (readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
            panic("isdirempty: readi");
        if (de.inum != 0)
            return 0;
    }
    return 1;
80106748:	b8 01 00 00 00       	mov    $0x1,%eax
}
8010674d:	c9                   	leave  
8010674e:	c3                   	ret    

8010674f <sys_unlink>:

// PAGEBREAK!
int sys_unlink(void)
{
8010674f:	55                   	push   %ebp
80106750:	89 e5                	mov    %esp,%ebp
80106752:	83 ec 38             	sub    $0x38,%esp
    struct inode* ip, *dp;
    struct dirent de;
    char name[DIRSIZ], *path;
    uint off;

    if (argstr(0, &path) < 0)
80106755:	83 ec 08             	sub    $0x8,%esp
80106758:	8d 45 cc             	lea    -0x34(%ebp),%eax
8010675b:	50                   	push   %eax
8010675c:	6a 00                	push   $0x0
8010675e:	e8 2e fa ff ff       	call   80106191 <argstr>
80106763:	83 c4 10             	add    $0x10,%esp
80106766:	85 c0                	test   %eax,%eax
80106768:	79 0a                	jns    80106774 <sys_unlink+0x25>
        return -1;
8010676a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010676f:	e9 14 02 00 00       	jmp    80106988 <sys_unlink+0x239>

    begin_op(proc->cwd->part->number);
80106774:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010677a:	8b 40 68             	mov    0x68(%eax),%eax
8010677d:	8b 40 50             	mov    0x50(%eax),%eax
80106780:	8b 40 14             	mov    0x14(%eax),%eax
80106783:	83 ec 0c             	sub    $0xc,%esp
80106786:	50                   	push   %eax
80106787:	e8 04 d7 ff ff       	call   80103e90 <begin_op>
8010678c:	83 c4 10             	add    $0x10,%esp
    if ((dp = nameiparent(path, name)) == 0) {
8010678f:	8b 45 cc             	mov    -0x34(%ebp),%eax
80106792:	83 ec 08             	sub    $0x8,%esp
80106795:	8d 55 d2             	lea    -0x2e(%ebp),%edx
80106798:	52                   	push   %edx
80106799:	50                   	push   %eax
8010679a:	e8 92 c5 ff ff       	call   80102d31 <nameiparent>
8010679f:	83 c4 10             	add    $0x10,%esp
801067a2:	89 45 f4             	mov    %eax,-0xc(%ebp)
801067a5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801067a9:	75 25                	jne    801067d0 <sys_unlink+0x81>
        end_op(proc->cwd->part->number);
801067ab:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801067b1:	8b 40 68             	mov    0x68(%eax),%eax
801067b4:	8b 40 50             	mov    0x50(%eax),%eax
801067b7:	8b 40 14             	mov    0x14(%eax),%eax
801067ba:	83 ec 0c             	sub    $0xc,%esp
801067bd:	50                   	push   %eax
801067be:	e8 d4 d7 ff ff       	call   80103f97 <end_op>
801067c3:	83 c4 10             	add    $0x10,%esp
        return -1;
801067c6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801067cb:	e9 b8 01 00 00       	jmp    80106988 <sys_unlink+0x239>
    }

    ilock(dp);
801067d0:	83 ec 0c             	sub    $0xc,%esp
801067d3:	ff 75 f4             	pushl  -0xc(%ebp)
801067d6:	e8 0f b7 ff ff       	call   80101eea <ilock>
801067db:	83 c4 10             	add    $0x10,%esp

    // Cannot unlink "." or "..".
    if (namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
801067de:	83 ec 08             	sub    $0x8,%esp
801067e1:	68 06 99 10 80       	push   $0x80109906
801067e6:	8d 45 d2             	lea    -0x2e(%ebp),%eax
801067e9:	50                   	push   %eax
801067ea:	e8 04 c1 ff ff       	call   801028f3 <namecmp>
801067ef:	83 c4 10             	add    $0x10,%esp
801067f2:	85 c0                	test   %eax,%eax
801067f4:	0f 84 60 01 00 00    	je     8010695a <sys_unlink+0x20b>
801067fa:	83 ec 08             	sub    $0x8,%esp
801067fd:	68 08 99 10 80       	push   $0x80109908
80106802:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80106805:	50                   	push   %eax
80106806:	e8 e8 c0 ff ff       	call   801028f3 <namecmp>
8010680b:	83 c4 10             	add    $0x10,%esp
8010680e:	85 c0                	test   %eax,%eax
80106810:	0f 84 44 01 00 00    	je     8010695a <sys_unlink+0x20b>
        goto bad;

    if ((ip = dirlookup(dp, name, &off)) == 0)
80106816:	83 ec 04             	sub    $0x4,%esp
80106819:	8d 45 c8             	lea    -0x38(%ebp),%eax
8010681c:	50                   	push   %eax
8010681d:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80106820:	50                   	push   %eax
80106821:	ff 75 f4             	pushl  -0xc(%ebp)
80106824:	e8 e5 c0 ff ff       	call   8010290e <dirlookup>
80106829:	83 c4 10             	add    $0x10,%esp
8010682c:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010682f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106833:	0f 84 20 01 00 00    	je     80106959 <sys_unlink+0x20a>
        goto bad;
    ilock(ip);
80106839:	83 ec 0c             	sub    $0xc,%esp
8010683c:	ff 75 f0             	pushl  -0x10(%ebp)
8010683f:	e8 a6 b6 ff ff       	call   80101eea <ilock>
80106844:	83 c4 10             	add    $0x10,%esp

    if (ip->nlink < 1)
80106847:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010684a:	0f b7 40 16          	movzwl 0x16(%eax),%eax
8010684e:	66 85 c0             	test   %ax,%ax
80106851:	7f 0d                	jg     80106860 <sys_unlink+0x111>
        panic("unlink: nlink < 1");
80106853:	83 ec 0c             	sub    $0xc,%esp
80106856:	68 0b 99 10 80       	push   $0x8010990b
8010685b:	e8 06 9d ff ff       	call   80100566 <panic>
    if (ip->type == T_DIR && !isdirempty(ip)) {
80106860:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106863:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106867:	66 83 f8 01          	cmp    $0x1,%ax
8010686b:	75 25                	jne    80106892 <sys_unlink+0x143>
8010686d:	83 ec 0c             	sub    $0xc,%esp
80106870:	ff 75 f0             	pushl  -0x10(%ebp)
80106873:	e8 74 fe ff ff       	call   801066ec <isdirempty>
80106878:	83 c4 10             	add    $0x10,%esp
8010687b:	85 c0                	test   %eax,%eax
8010687d:	75 13                	jne    80106892 <sys_unlink+0x143>
        iunlockput(ip);
8010687f:	83 ec 0c             	sub    $0xc,%esp
80106882:	ff 75 f0             	pushl  -0x10(%ebp)
80106885:	e8 63 b9 ff ff       	call   801021ed <iunlockput>
8010688a:	83 c4 10             	add    $0x10,%esp
        goto bad;
8010688d:	e9 c8 00 00 00       	jmp    8010695a <sys_unlink+0x20b>
    }

    memset(&de, 0, sizeof(de));
80106892:	83 ec 04             	sub    $0x4,%esp
80106895:	6a 10                	push   $0x10
80106897:	6a 00                	push   $0x0
80106899:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010689c:	50                   	push   %eax
8010689d:	e8 45 f5 ff ff       	call   80105de7 <memset>
801068a2:	83 c4 10             	add    $0x10,%esp
    if (writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801068a5:	8b 45 c8             	mov    -0x38(%ebp),%eax
801068a8:	6a 10                	push   $0x10
801068aa:	50                   	push   %eax
801068ab:	8d 45 e0             	lea    -0x20(%ebp),%eax
801068ae:	50                   	push   %eax
801068af:	ff 75 f4             	pushl  -0xc(%ebp)
801068b2:	e8 61 be ff ff       	call   80102718 <writei>
801068b7:	83 c4 10             	add    $0x10,%esp
801068ba:	83 f8 10             	cmp    $0x10,%eax
801068bd:	74 0d                	je     801068cc <sys_unlink+0x17d>
        panic("unlink: writei");
801068bf:	83 ec 0c             	sub    $0xc,%esp
801068c2:	68 1d 99 10 80       	push   $0x8010991d
801068c7:	e8 9a 9c ff ff       	call   80100566 <panic>
    if (ip->type == T_DIR) {
801068cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801068cf:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801068d3:	66 83 f8 01          	cmp    $0x1,%ax
801068d7:	75 21                	jne    801068fa <sys_unlink+0x1ab>
        dp->nlink--;
801068d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801068dc:	0f b7 40 16          	movzwl 0x16(%eax),%eax
801068e0:	83 e8 01             	sub    $0x1,%eax
801068e3:	89 c2                	mov    %eax,%edx
801068e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801068e8:	66 89 50 16          	mov    %dx,0x16(%eax)
        iupdate(dp);
801068ec:	83 ec 0c             	sub    $0xc,%esp
801068ef:	ff 75 f4             	pushl  -0xc(%ebp)
801068f2:	e8 95 b3 ff ff       	call   80101c8c <iupdate>
801068f7:	83 c4 10             	add    $0x10,%esp
    }
    iunlockput(dp);
801068fa:	83 ec 0c             	sub    $0xc,%esp
801068fd:	ff 75 f4             	pushl  -0xc(%ebp)
80106900:	e8 e8 b8 ff ff       	call   801021ed <iunlockput>
80106905:	83 c4 10             	add    $0x10,%esp

    ip->nlink--;
80106908:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010690b:	0f b7 40 16          	movzwl 0x16(%eax),%eax
8010690f:	83 e8 01             	sub    $0x1,%eax
80106912:	89 c2                	mov    %eax,%edx
80106914:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106917:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(ip);
8010691b:	83 ec 0c             	sub    $0xc,%esp
8010691e:	ff 75 f0             	pushl  -0x10(%ebp)
80106921:	e8 66 b3 ff ff       	call   80101c8c <iupdate>
80106926:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
80106929:	83 ec 0c             	sub    $0xc,%esp
8010692c:	ff 75 f0             	pushl  -0x10(%ebp)
8010692f:	e8 b9 b8 ff ff       	call   801021ed <iunlockput>
80106934:	83 c4 10             	add    $0x10,%esp

    end_op(proc->cwd->part->number);
80106937:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010693d:	8b 40 68             	mov    0x68(%eax),%eax
80106940:	8b 40 50             	mov    0x50(%eax),%eax
80106943:	8b 40 14             	mov    0x14(%eax),%eax
80106946:	83 ec 0c             	sub    $0xc,%esp
80106949:	50                   	push   %eax
8010694a:	e8 48 d6 ff ff       	call   80103f97 <end_op>
8010694f:	83 c4 10             	add    $0x10,%esp

    return 0;
80106952:	b8 00 00 00 00       	mov    $0x0,%eax
80106957:	eb 2f                	jmp    80106988 <sys_unlink+0x239>
    // Cannot unlink "." or "..".
    if (namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
        goto bad;

    if ((ip = dirlookup(dp, name, &off)) == 0)
        goto bad;
80106959:	90                   	nop
    end_op(proc->cwd->part->number);

    return 0;

bad:
    iunlockput(dp);
8010695a:	83 ec 0c             	sub    $0xc,%esp
8010695d:	ff 75 f4             	pushl  -0xc(%ebp)
80106960:	e8 88 b8 ff ff       	call   801021ed <iunlockput>
80106965:	83 c4 10             	add    $0x10,%esp
    end_op(proc->cwd->part->number);
80106968:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010696e:	8b 40 68             	mov    0x68(%eax),%eax
80106971:	8b 40 50             	mov    0x50(%eax),%eax
80106974:	8b 40 14             	mov    0x14(%eax),%eax
80106977:	83 ec 0c             	sub    $0xc,%esp
8010697a:	50                   	push   %eax
8010697b:	e8 17 d6 ff ff       	call   80103f97 <end_op>
80106980:	83 c4 10             	add    $0x10,%esp
    return -1;
80106983:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80106988:	c9                   	leave  
80106989:	c3                   	ret    

8010698a <create>:

static struct inode* create(char* path, short type, short major, short minor)
{
8010698a:	55                   	push   %ebp
8010698b:	89 e5                	mov    %esp,%ebp
8010698d:	83 ec 38             	sub    $0x38,%esp
80106990:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80106993:	8b 55 10             	mov    0x10(%ebp),%edx
80106996:	8b 45 14             	mov    0x14(%ebp),%eax
80106999:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
8010699d:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
801069a1:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
    uint off;
    struct inode* ip, *dp;
    char name[DIRSIZ];
    // cprintf("path %d  \n",path);
    if ((dp = nameiparent(path, name)) == 0)
801069a5:	83 ec 08             	sub    $0x8,%esp
801069a8:	8d 45 de             	lea    -0x22(%ebp),%eax
801069ab:	50                   	push   %eax
801069ac:	ff 75 08             	pushl  0x8(%ebp)
801069af:	e8 7d c3 ff ff       	call   80102d31 <nameiparent>
801069b4:	83 c4 10             	add    $0x10,%esp
801069b7:	89 45 f4             	mov    %eax,-0xc(%ebp)
801069ba:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801069be:	75 0a                	jne    801069ca <create+0x40>
        return 0;
801069c0:	b8 00 00 00 00       	mov    $0x0,%eax
801069c5:	e9 9c 01 00 00       	jmp    80106b66 <create+0x1dc>
    ilock(dp);
801069ca:	83 ec 0c             	sub    $0xc,%esp
801069cd:	ff 75 f4             	pushl  -0xc(%ebp)
801069d0:	e8 15 b5 ff ff       	call   80101eea <ilock>
801069d5:	83 c4 10             	add    $0x10,%esp

    if ((ip = dirlookup(dp, name, &off)) != 0) {
801069d8:	83 ec 04             	sub    $0x4,%esp
801069db:	8d 45 ec             	lea    -0x14(%ebp),%eax
801069de:	50                   	push   %eax
801069df:	8d 45 de             	lea    -0x22(%ebp),%eax
801069e2:	50                   	push   %eax
801069e3:	ff 75 f4             	pushl  -0xc(%ebp)
801069e6:	e8 23 bf ff ff       	call   8010290e <dirlookup>
801069eb:	83 c4 10             	add    $0x10,%esp
801069ee:	89 45 f0             	mov    %eax,-0x10(%ebp)
801069f1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801069f5:	74 50                	je     80106a47 <create+0xbd>
        iunlockput(dp);
801069f7:	83 ec 0c             	sub    $0xc,%esp
801069fa:	ff 75 f4             	pushl  -0xc(%ebp)
801069fd:	e8 eb b7 ff ff       	call   801021ed <iunlockput>
80106a02:	83 c4 10             	add    $0x10,%esp
        ilock(ip);
80106a05:	83 ec 0c             	sub    $0xc,%esp
80106a08:	ff 75 f0             	pushl  -0x10(%ebp)
80106a0b:	e8 da b4 ff ff       	call   80101eea <ilock>
80106a10:	83 c4 10             	add    $0x10,%esp
        if (type == T_FILE && ip->type == T_FILE)
80106a13:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80106a18:	75 15                	jne    80106a2f <create+0xa5>
80106a1a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106a1d:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106a21:	66 83 f8 02          	cmp    $0x2,%ax
80106a25:	75 08                	jne    80106a2f <create+0xa5>
            return ip;
80106a27:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106a2a:	e9 37 01 00 00       	jmp    80106b66 <create+0x1dc>
        iunlockput(ip);
80106a2f:	83 ec 0c             	sub    $0xc,%esp
80106a32:	ff 75 f0             	pushl  -0x10(%ebp)
80106a35:	e8 b3 b7 ff ff       	call   801021ed <iunlockput>
80106a3a:	83 c4 10             	add    $0x10,%esp
        return 0;
80106a3d:	b8 00 00 00 00       	mov    $0x0,%eax
80106a42:	e9 1f 01 00 00       	jmp    80106b66 <create+0x1dc>
    }
    if ((ip = ialloc(dp->dev, type, dp->part->number)) == 0)
80106a47:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a4a:	8b 40 50             	mov    0x50(%eax),%eax
80106a4d:	8b 40 14             	mov    0x14(%eax),%eax
80106a50:	89 c1                	mov    %eax,%ecx
80106a52:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80106a56:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a59:	8b 00                	mov    (%eax),%eax
80106a5b:	83 ec 04             	sub    $0x4,%esp
80106a5e:	51                   	push   %ecx
80106a5f:	52                   	push   %edx
80106a60:	50                   	push   %eax
80106a61:	e8 0d b1 ff ff       	call   80101b73 <ialloc>
80106a66:	83 c4 10             	add    $0x10,%esp
80106a69:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106a6c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106a70:	75 0d                	jne    80106a7f <create+0xf5>
        panic("create: ialloc");
80106a72:	83 ec 0c             	sub    $0xc,%esp
80106a75:	68 2c 99 10 80       	push   $0x8010992c
80106a7a:	e8 e7 9a ff ff       	call   80100566 <panic>

    ilock(ip);
80106a7f:	83 ec 0c             	sub    $0xc,%esp
80106a82:	ff 75 f0             	pushl  -0x10(%ebp)
80106a85:	e8 60 b4 ff ff       	call   80101eea <ilock>
80106a8a:	83 c4 10             	add    $0x10,%esp
    ip->major = major;
80106a8d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106a90:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
80106a94:	66 89 50 12          	mov    %dx,0x12(%eax)
    ip->minor = minor;
80106a98:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106a9b:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
80106a9f:	66 89 50 14          	mov    %dx,0x14(%eax)
    ip->nlink = 1;
80106aa3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106aa6:	66 c7 40 16 01 00    	movw   $0x1,0x16(%eax)
    iupdate(ip);
80106aac:	83 ec 0c             	sub    $0xc,%esp
80106aaf:	ff 75 f0             	pushl  -0x10(%ebp)
80106ab2:	e8 d5 b1 ff ff       	call   80101c8c <iupdate>
80106ab7:	83 c4 10             	add    $0x10,%esp

    if (type == T_DIR) { // Create . and .. entries.
80106aba:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80106abf:	75 6a                	jne    80106b2b <create+0x1a1>
        dp->nlink++;     // for ".."
80106ac1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ac4:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80106ac8:	83 c0 01             	add    $0x1,%eax
80106acb:	89 c2                	mov    %eax,%edx
80106acd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ad0:	66 89 50 16          	mov    %dx,0x16(%eax)
        iupdate(dp);
80106ad4:	83 ec 0c             	sub    $0xc,%esp
80106ad7:	ff 75 f4             	pushl  -0xc(%ebp)
80106ada:	e8 ad b1 ff ff       	call   80101c8c <iupdate>
80106adf:	83 c4 10             	add    $0x10,%esp
        // No ip->nlink++ for ".": avoid cyclic ref count.
        if (dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80106ae2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106ae5:	8b 40 04             	mov    0x4(%eax),%eax
80106ae8:	83 ec 04             	sub    $0x4,%esp
80106aeb:	50                   	push   %eax
80106aec:	68 06 99 10 80       	push   $0x80109906
80106af1:	ff 75 f0             	pushl  -0x10(%ebp)
80106af4:	e8 dc be ff ff       	call   801029d5 <dirlink>
80106af9:	83 c4 10             	add    $0x10,%esp
80106afc:	85 c0                	test   %eax,%eax
80106afe:	78 1e                	js     80106b1e <create+0x194>
80106b00:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b03:	8b 40 04             	mov    0x4(%eax),%eax
80106b06:	83 ec 04             	sub    $0x4,%esp
80106b09:	50                   	push   %eax
80106b0a:	68 08 99 10 80       	push   $0x80109908
80106b0f:	ff 75 f0             	pushl  -0x10(%ebp)
80106b12:	e8 be be ff ff       	call   801029d5 <dirlink>
80106b17:	83 c4 10             	add    $0x10,%esp
80106b1a:	85 c0                	test   %eax,%eax
80106b1c:	79 0d                	jns    80106b2b <create+0x1a1>
            panic("create dots");
80106b1e:	83 ec 0c             	sub    $0xc,%esp
80106b21:	68 3b 99 10 80       	push   $0x8010993b
80106b26:	e8 3b 9a ff ff       	call   80100566 <panic>
    }

    if (dirlink(dp, name, ip->inum) < 0)
80106b2b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106b2e:	8b 40 04             	mov    0x4(%eax),%eax
80106b31:	83 ec 04             	sub    $0x4,%esp
80106b34:	50                   	push   %eax
80106b35:	8d 45 de             	lea    -0x22(%ebp),%eax
80106b38:	50                   	push   %eax
80106b39:	ff 75 f4             	pushl  -0xc(%ebp)
80106b3c:	e8 94 be ff ff       	call   801029d5 <dirlink>
80106b41:	83 c4 10             	add    $0x10,%esp
80106b44:	85 c0                	test   %eax,%eax
80106b46:	79 0d                	jns    80106b55 <create+0x1cb>
        panic("create: dirlink");
80106b48:	83 ec 0c             	sub    $0xc,%esp
80106b4b:	68 47 99 10 80       	push   $0x80109947
80106b50:	e8 11 9a ff ff       	call   80100566 <panic>

    iunlockput(dp);
80106b55:	83 ec 0c             	sub    $0xc,%esp
80106b58:	ff 75 f4             	pushl  -0xc(%ebp)
80106b5b:	e8 8d b6 ff ff       	call   801021ed <iunlockput>
80106b60:	83 c4 10             	add    $0x10,%esp

    return ip;
80106b63:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80106b66:	c9                   	leave  
80106b67:	c3                   	ret    

80106b68 <sys_open>:

int sys_open(void)
{
80106b68:	55                   	push   %ebp
80106b69:	89 e5                	mov    %esp,%ebp
80106b6b:	83 ec 18             	sub    $0x18,%esp
    char* path;
    int omode;

    if (argstr(0, &path) < 0 || argint(1, &omode) < 0)
80106b6e:	83 ec 08             	sub    $0x8,%esp
80106b71:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106b74:	50                   	push   %eax
80106b75:	6a 00                	push   $0x0
80106b77:	e8 15 f6 ff ff       	call   80106191 <argstr>
80106b7c:	83 c4 10             	add    $0x10,%esp
80106b7f:	85 c0                	test   %eax,%eax
80106b81:	78 15                	js     80106b98 <sys_open+0x30>
80106b83:	83 ec 08             	sub    $0x8,%esp
80106b86:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106b89:	50                   	push   %eax
80106b8a:	6a 01                	push   $0x1
80106b8c:	e8 7b f5 ff ff       	call   8010610c <argint>
80106b91:	83 c4 10             	add    $0x10,%esp
80106b94:	85 c0                	test   %eax,%eax
80106b96:	79 07                	jns    80106b9f <sys_open+0x37>
        return -1;
80106b98:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106b9d:	eb 13                	jmp    80106bb2 <sys_open+0x4a>

    return openFile(path, omode);
80106b9f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106ba2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ba5:	83 ec 08             	sub    $0x8,%esp
80106ba8:	52                   	push   %edx
80106ba9:	50                   	push   %eax
80106baa:	e8 05 00 00 00       	call   80106bb4 <openFile>
80106baf:	83 c4 10             	add    $0x10,%esp
}
80106bb2:	c9                   	leave  
80106bb3:	c3                   	ret    

80106bb4 <openFile>:

int openFile(char* path, int omode)
{
80106bb4:	55                   	push   %ebp
80106bb5:	89 e5                	mov    %esp,%ebp
80106bb7:	83 ec 18             	sub    $0x18,%esp
    int fd;
    struct file* f;
    struct inode* ip;
    begin_op(proc->cwd->part->number);
80106bba:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106bc0:	8b 40 68             	mov    0x68(%eax),%eax
80106bc3:	8b 40 50             	mov    0x50(%eax),%eax
80106bc6:	8b 40 14             	mov    0x14(%eax),%eax
80106bc9:	83 ec 0c             	sub    $0xc,%esp
80106bcc:	50                   	push   %eax
80106bcd:	e8 be d2 ff ff       	call   80103e90 <begin_op>
80106bd2:	83 c4 10             	add    $0x10,%esp

    if (omode & O_CREATE) {
80106bd5:	8b 45 0c             	mov    0xc(%ebp),%eax
80106bd8:	25 00 02 00 00       	and    $0x200,%eax
80106bdd:	85 c0                	test   %eax,%eax
80106bdf:	74 43                	je     80106c24 <openFile+0x70>
        ip = create(path, T_FILE, 0, 0);
80106be1:	6a 00                	push   $0x0
80106be3:	6a 00                	push   $0x0
80106be5:	6a 02                	push   $0x2
80106be7:	ff 75 08             	pushl  0x8(%ebp)
80106bea:	e8 9b fd ff ff       	call   8010698a <create>
80106bef:	83 c4 10             	add    $0x10,%esp
80106bf2:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (ip == 0) {
80106bf5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106bf9:	0f 85 b5 00 00 00    	jne    80106cb4 <openFile+0x100>
            end_op(proc->cwd->part->number);
80106bff:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106c05:	8b 40 68             	mov    0x68(%eax),%eax
80106c08:	8b 40 50             	mov    0x50(%eax),%eax
80106c0b:	8b 40 14             	mov    0x14(%eax),%eax
80106c0e:	83 ec 0c             	sub    $0xc,%esp
80106c11:	50                   	push   %eax
80106c12:	e8 80 d3 ff ff       	call   80103f97 <end_op>
80106c17:	83 c4 10             	add    $0x10,%esp
            return -1;
80106c1a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106c1f:	e9 7f 01 00 00       	jmp    80106da3 <openFile+0x1ef>
        }
    } else {
        if ((ip = namei(path)) == 0) {
80106c24:	83 ec 0c             	sub    $0xc,%esp
80106c27:	ff 75 08             	pushl  0x8(%ebp)
80106c2a:	e8 cc c0 ff ff       	call   80102cfb <namei>
80106c2f:	83 c4 10             	add    $0x10,%esp
80106c32:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106c35:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106c39:	75 25                	jne    80106c60 <openFile+0xac>
            end_op(proc->cwd->part->number);
80106c3b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106c41:	8b 40 68             	mov    0x68(%eax),%eax
80106c44:	8b 40 50             	mov    0x50(%eax),%eax
80106c47:	8b 40 14             	mov    0x14(%eax),%eax
80106c4a:	83 ec 0c             	sub    $0xc,%esp
80106c4d:	50                   	push   %eax
80106c4e:	e8 44 d3 ff ff       	call   80103f97 <end_op>
80106c53:	83 c4 10             	add    $0x10,%esp
            return -1;
80106c56:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106c5b:	e9 43 01 00 00       	jmp    80106da3 <openFile+0x1ef>
        }
        ilock(ip);
80106c60:	83 ec 0c             	sub    $0xc,%esp
80106c63:	ff 75 f4             	pushl  -0xc(%ebp)
80106c66:	e8 7f b2 ff ff       	call   80101eea <ilock>
80106c6b:	83 c4 10             	add    $0x10,%esp
        if (ip->type == T_DIR && omode != O_RDONLY) {
80106c6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106c71:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106c75:	66 83 f8 01          	cmp    $0x1,%ax
80106c79:	75 39                	jne    80106cb4 <openFile+0x100>
80106c7b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80106c7f:	74 33                	je     80106cb4 <openFile+0x100>
            iunlockput(ip);
80106c81:	83 ec 0c             	sub    $0xc,%esp
80106c84:	ff 75 f4             	pushl  -0xc(%ebp)
80106c87:	e8 61 b5 ff ff       	call   801021ed <iunlockput>
80106c8c:	83 c4 10             	add    $0x10,%esp
            end_op(proc->cwd->part->number);
80106c8f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106c95:	8b 40 68             	mov    0x68(%eax),%eax
80106c98:	8b 40 50             	mov    0x50(%eax),%eax
80106c9b:	8b 40 14             	mov    0x14(%eax),%eax
80106c9e:	83 ec 0c             	sub    $0xc,%esp
80106ca1:	50                   	push   %eax
80106ca2:	e8 f0 d2 ff ff       	call   80103f97 <end_op>
80106ca7:	83 c4 10             	add    $0x10,%esp
            return -1;
80106caa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106caf:	e9 ef 00 00 00       	jmp    80106da3 <openFile+0x1ef>
        }
    }

    if ((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0) {
80106cb4:	e8 32 a3 ff ff       	call   80100feb <filealloc>
80106cb9:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106cbc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106cc0:	74 17                	je     80106cd9 <openFile+0x125>
80106cc2:	83 ec 0c             	sub    $0xc,%esp
80106cc5:	ff 75 f0             	pushl  -0x10(%ebp)
80106cc8:	e8 f0 f5 ff ff       	call   801062bd <fdalloc>
80106ccd:	83 c4 10             	add    $0x10,%esp
80106cd0:	89 45 ec             	mov    %eax,-0x14(%ebp)
80106cd3:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80106cd7:	79 47                	jns    80106d20 <openFile+0x16c>
        if (f)
80106cd9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106cdd:	74 0e                	je     80106ced <openFile+0x139>
            fileclose(f);
80106cdf:	83 ec 0c             	sub    $0xc,%esp
80106ce2:	ff 75 f0             	pushl  -0x10(%ebp)
80106ce5:	e8 bf a3 ff ff       	call   801010a9 <fileclose>
80106cea:	83 c4 10             	add    $0x10,%esp
        iunlockput(ip);
80106ced:	83 ec 0c             	sub    $0xc,%esp
80106cf0:	ff 75 f4             	pushl  -0xc(%ebp)
80106cf3:	e8 f5 b4 ff ff       	call   801021ed <iunlockput>
80106cf8:	83 c4 10             	add    $0x10,%esp
        end_op(proc->cwd->part->number);
80106cfb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106d01:	8b 40 68             	mov    0x68(%eax),%eax
80106d04:	8b 40 50             	mov    0x50(%eax),%eax
80106d07:	8b 40 14             	mov    0x14(%eax),%eax
80106d0a:	83 ec 0c             	sub    $0xc,%esp
80106d0d:	50                   	push   %eax
80106d0e:	e8 84 d2 ff ff       	call   80103f97 <end_op>
80106d13:	83 c4 10             	add    $0x10,%esp
        return -1;
80106d16:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106d1b:	e9 83 00 00 00       	jmp    80106da3 <openFile+0x1ef>
    }
    iunlock(ip);
80106d20:	83 ec 0c             	sub    $0xc,%esp
80106d23:	ff 75 f4             	pushl  -0xc(%ebp)
80106d26:	e8 60 b3 ff ff       	call   8010208b <iunlock>
80106d2b:	83 c4 10             	add    $0x10,%esp
    end_op(proc->cwd->part->number);
80106d2e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106d34:	8b 40 68             	mov    0x68(%eax),%eax
80106d37:	8b 40 50             	mov    0x50(%eax),%eax
80106d3a:	8b 40 14             	mov    0x14(%eax),%eax
80106d3d:	83 ec 0c             	sub    $0xc,%esp
80106d40:	50                   	push   %eax
80106d41:	e8 51 d2 ff ff       	call   80103f97 <end_op>
80106d46:	83 c4 10             	add    $0x10,%esp

    f->type = FD_INODE;
80106d49:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106d4c:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
    f->ip = ip;
80106d52:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106d55:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106d58:	89 50 0e             	mov    %edx,0xe(%eax)
    f->off = 0;
80106d5b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106d5e:	c7 40 12 00 00 00 00 	movl   $0x0,0x12(%eax)
    f->readable = !(omode & O_WRONLY);
80106d65:	8b 45 0c             	mov    0xc(%ebp),%eax
80106d68:	83 e0 01             	and    $0x1,%eax
80106d6b:	85 c0                	test   %eax,%eax
80106d6d:	0f 94 c0             	sete   %al
80106d70:	89 c2                	mov    %eax,%edx
80106d72:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106d75:	88 50 08             	mov    %dl,0x8(%eax)
    f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80106d78:	8b 45 0c             	mov    0xc(%ebp),%eax
80106d7b:	83 e0 01             	and    $0x1,%eax
80106d7e:	85 c0                	test   %eax,%eax
80106d80:	75 0a                	jne    80106d8c <openFile+0x1d8>
80106d82:	8b 45 0c             	mov    0xc(%ebp),%eax
80106d85:	83 e0 02             	and    $0x2,%eax
80106d88:	85 c0                	test   %eax,%eax
80106d8a:	74 07                	je     80106d93 <openFile+0x1df>
80106d8c:	b8 01 00 00 00       	mov    $0x1,%eax
80106d91:	eb 05                	jmp    80106d98 <openFile+0x1e4>
80106d93:	b8 00 00 00 00       	mov    $0x0,%eax
80106d98:	89 c2                	mov    %eax,%edx
80106d9a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106d9d:	88 50 09             	mov    %dl,0x9(%eax)
    return fd;
80106da0:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80106da3:	c9                   	leave  
80106da4:	c3                   	ret    

80106da5 <sys_mkdir>:

int sys_mkdir(void)
{
80106da5:	55                   	push   %ebp
80106da6:	89 e5                	mov    %esp,%ebp
80106da8:	83 ec 18             	sub    $0x18,%esp
    char* path;
    struct inode* ip;

    begin_op(proc->cwd->part->number);
80106dab:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106db1:	8b 40 68             	mov    0x68(%eax),%eax
80106db4:	8b 40 50             	mov    0x50(%eax),%eax
80106db7:	8b 40 14             	mov    0x14(%eax),%eax
80106dba:	83 ec 0c             	sub    $0xc,%esp
80106dbd:	50                   	push   %eax
80106dbe:	e8 cd d0 ff ff       	call   80103e90 <begin_op>
80106dc3:	83 c4 10             	add    $0x10,%esp
    if (argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0) {
80106dc6:	83 ec 08             	sub    $0x8,%esp
80106dc9:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106dcc:	50                   	push   %eax
80106dcd:	6a 00                	push   $0x0
80106dcf:	e8 bd f3 ff ff       	call   80106191 <argstr>
80106dd4:	83 c4 10             	add    $0x10,%esp
80106dd7:	85 c0                	test   %eax,%eax
80106dd9:	78 1b                	js     80106df6 <sys_mkdir+0x51>
80106ddb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106dde:	6a 00                	push   $0x0
80106de0:	6a 00                	push   $0x0
80106de2:	6a 01                	push   $0x1
80106de4:	50                   	push   %eax
80106de5:	e8 a0 fb ff ff       	call   8010698a <create>
80106dea:	83 c4 10             	add    $0x10,%esp
80106ded:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106df0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106df4:	75 22                	jne    80106e18 <sys_mkdir+0x73>
        end_op(proc->cwd->part->number);
80106df6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106dfc:	8b 40 68             	mov    0x68(%eax),%eax
80106dff:	8b 40 50             	mov    0x50(%eax),%eax
80106e02:	8b 40 14             	mov    0x14(%eax),%eax
80106e05:	83 ec 0c             	sub    $0xc,%esp
80106e08:	50                   	push   %eax
80106e09:	e8 89 d1 ff ff       	call   80103f97 <end_op>
80106e0e:	83 c4 10             	add    $0x10,%esp
        return -1;
80106e11:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106e16:	eb 2e                	jmp    80106e46 <sys_mkdir+0xa1>
    }
    iunlockput(ip);
80106e18:	83 ec 0c             	sub    $0xc,%esp
80106e1b:	ff 75 f4             	pushl  -0xc(%ebp)
80106e1e:	e8 ca b3 ff ff       	call   801021ed <iunlockput>
80106e23:	83 c4 10             	add    $0x10,%esp
    end_op(proc->cwd->part->number);
80106e26:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106e2c:	8b 40 68             	mov    0x68(%eax),%eax
80106e2f:	8b 40 50             	mov    0x50(%eax),%eax
80106e32:	8b 40 14             	mov    0x14(%eax),%eax
80106e35:	83 ec 0c             	sub    $0xc,%esp
80106e38:	50                   	push   %eax
80106e39:	e8 59 d1 ff ff       	call   80103f97 <end_op>
80106e3e:	83 c4 10             	add    $0x10,%esp
    return 0;
80106e41:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106e46:	c9                   	leave  
80106e47:	c3                   	ret    

80106e48 <sys_mknod>:

int sys_mknod(void)
{
80106e48:	55                   	push   %ebp
80106e49:	89 e5                	mov    %esp,%ebp
80106e4b:	83 ec 28             	sub    $0x28,%esp
    struct inode* ip;
    char* path;
    int len;
    int major, minor;

    begin_op(proc->cwd->part->number);
80106e4e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106e54:	8b 40 68             	mov    0x68(%eax),%eax
80106e57:	8b 40 50             	mov    0x50(%eax),%eax
80106e5a:	8b 40 14             	mov    0x14(%eax),%eax
80106e5d:	83 ec 0c             	sub    $0xc,%esp
80106e60:	50                   	push   %eax
80106e61:	e8 2a d0 ff ff       	call   80103e90 <begin_op>
80106e66:	83 c4 10             	add    $0x10,%esp
    if ((len = argstr(0, &path)) < 0 || argint(1, &major) < 0 || argint(2, &minor) < 0 ||
80106e69:	83 ec 08             	sub    $0x8,%esp
80106e6c:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106e6f:	50                   	push   %eax
80106e70:	6a 00                	push   $0x0
80106e72:	e8 1a f3 ff ff       	call   80106191 <argstr>
80106e77:	83 c4 10             	add    $0x10,%esp
80106e7a:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106e7d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106e81:	78 4f                	js     80106ed2 <sys_mknod+0x8a>
80106e83:	83 ec 08             	sub    $0x8,%esp
80106e86:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106e89:	50                   	push   %eax
80106e8a:	6a 01                	push   $0x1
80106e8c:	e8 7b f2 ff ff       	call   8010610c <argint>
80106e91:	83 c4 10             	add    $0x10,%esp
80106e94:	85 c0                	test   %eax,%eax
80106e96:	78 3a                	js     80106ed2 <sys_mknod+0x8a>
80106e98:	83 ec 08             	sub    $0x8,%esp
80106e9b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106e9e:	50                   	push   %eax
80106e9f:	6a 02                	push   $0x2
80106ea1:	e8 66 f2 ff ff       	call   8010610c <argint>
80106ea6:	83 c4 10             	add    $0x10,%esp
80106ea9:	85 c0                	test   %eax,%eax
80106eab:	78 25                	js     80106ed2 <sys_mknod+0x8a>
        (ip = create(path, T_DEV, major, minor)) == 0) {
80106ead:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106eb0:	0f bf c8             	movswl %ax,%ecx
80106eb3:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106eb6:	0f bf d0             	movswl %ax,%edx
80106eb9:	8b 45 ec             	mov    -0x14(%ebp),%eax
    char* path;
    int len;
    int major, minor;

    begin_op(proc->cwd->part->number);
    if ((len = argstr(0, &path)) < 0 || argint(1, &major) < 0 || argint(2, &minor) < 0 ||
80106ebc:	51                   	push   %ecx
80106ebd:	52                   	push   %edx
80106ebe:	6a 03                	push   $0x3
80106ec0:	50                   	push   %eax
80106ec1:	e8 c4 fa ff ff       	call   8010698a <create>
80106ec6:	83 c4 10             	add    $0x10,%esp
80106ec9:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106ecc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106ed0:	75 22                	jne    80106ef4 <sys_mknod+0xac>
        (ip = create(path, T_DEV, major, minor)) == 0) {
        end_op(proc->cwd->part->number);
80106ed2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106ed8:	8b 40 68             	mov    0x68(%eax),%eax
80106edb:	8b 40 50             	mov    0x50(%eax),%eax
80106ede:	8b 40 14             	mov    0x14(%eax),%eax
80106ee1:	83 ec 0c             	sub    $0xc,%esp
80106ee4:	50                   	push   %eax
80106ee5:	e8 ad d0 ff ff       	call   80103f97 <end_op>
80106eea:	83 c4 10             	add    $0x10,%esp
        return -1;
80106eed:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106ef2:	eb 2e                	jmp    80106f22 <sys_mknod+0xda>
    }
    iunlockput(ip);
80106ef4:	83 ec 0c             	sub    $0xc,%esp
80106ef7:	ff 75 f0             	pushl  -0x10(%ebp)
80106efa:	e8 ee b2 ff ff       	call   801021ed <iunlockput>
80106eff:	83 c4 10             	add    $0x10,%esp
    end_op(proc->cwd->part->number);
80106f02:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106f08:	8b 40 68             	mov    0x68(%eax),%eax
80106f0b:	8b 40 50             	mov    0x50(%eax),%eax
80106f0e:	8b 40 14             	mov    0x14(%eax),%eax
80106f11:	83 ec 0c             	sub    $0xc,%esp
80106f14:	50                   	push   %eax
80106f15:	e8 7d d0 ff ff       	call   80103f97 <end_op>
80106f1a:	83 c4 10             	add    $0x10,%esp
    return 0;
80106f1d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106f22:	c9                   	leave  
80106f23:	c3                   	ret    

80106f24 <sys_chdir>:

int sys_chdir(void)
{
80106f24:	55                   	push   %ebp
80106f25:	89 e5                	mov    %esp,%ebp
80106f27:	83 ec 18             	sub    $0x18,%esp
    char* path;
    struct inode* ip;

    begin_op(proc->cwd->part->number);
80106f2a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106f30:	8b 40 68             	mov    0x68(%eax),%eax
80106f33:	8b 40 50             	mov    0x50(%eax),%eax
80106f36:	8b 40 14             	mov    0x14(%eax),%eax
80106f39:	83 ec 0c             	sub    $0xc,%esp
80106f3c:	50                   	push   %eax
80106f3d:	e8 4e cf ff ff       	call   80103e90 <begin_op>
80106f42:	83 c4 10             	add    $0x10,%esp
    if (argstr(0, &path) < 0 || (ip = namei(path)) == 0) {
80106f45:	83 ec 08             	sub    $0x8,%esp
80106f48:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106f4b:	50                   	push   %eax
80106f4c:	6a 00                	push   $0x0
80106f4e:	e8 3e f2 ff ff       	call   80106191 <argstr>
80106f53:	83 c4 10             	add    $0x10,%esp
80106f56:	85 c0                	test   %eax,%eax
80106f58:	78 18                	js     80106f72 <sys_chdir+0x4e>
80106f5a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106f5d:	83 ec 0c             	sub    $0xc,%esp
80106f60:	50                   	push   %eax
80106f61:	e8 95 bd ff ff       	call   80102cfb <namei>
80106f66:	83 c4 10             	add    $0x10,%esp
80106f69:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106f6c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106f70:	75 25                	jne    80106f97 <sys_chdir+0x73>
        end_op(proc->cwd->part->number);
80106f72:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106f78:	8b 40 68             	mov    0x68(%eax),%eax
80106f7b:	8b 40 50             	mov    0x50(%eax),%eax
80106f7e:	8b 40 14             	mov    0x14(%eax),%eax
80106f81:	83 ec 0c             	sub    $0xc,%esp
80106f84:	50                   	push   %eax
80106f85:	e8 0d d0 ff ff       	call   80103f97 <end_op>
80106f8a:	83 c4 10             	add    $0x10,%esp
        return -1;
80106f8d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106f92:	e9 9a 00 00 00       	jmp    80107031 <sys_chdir+0x10d>
    }
    ilock(ip);
80106f97:	83 ec 0c             	sub    $0xc,%esp
80106f9a:	ff 75 f4             	pushl  -0xc(%ebp)
80106f9d:	e8 48 af ff ff       	call   80101eea <ilock>
80106fa2:	83 c4 10             	add    $0x10,%esp
    if (ip->type != T_DIR) {
80106fa5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106fa8:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106fac:	66 83 f8 01          	cmp    $0x1,%ax
80106fb0:	74 30                	je     80106fe2 <sys_chdir+0xbe>
        iunlockput(ip);
80106fb2:	83 ec 0c             	sub    $0xc,%esp
80106fb5:	ff 75 f4             	pushl  -0xc(%ebp)
80106fb8:	e8 30 b2 ff ff       	call   801021ed <iunlockput>
80106fbd:	83 c4 10             	add    $0x10,%esp
        end_op(proc->cwd->part->number);
80106fc0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106fc6:	8b 40 68             	mov    0x68(%eax),%eax
80106fc9:	8b 40 50             	mov    0x50(%eax),%eax
80106fcc:	8b 40 14             	mov    0x14(%eax),%eax
80106fcf:	83 ec 0c             	sub    $0xc,%esp
80106fd2:	50                   	push   %eax
80106fd3:	e8 bf cf ff ff       	call   80103f97 <end_op>
80106fd8:	83 c4 10             	add    $0x10,%esp
        return -1;
80106fdb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106fe0:	eb 4f                	jmp    80107031 <sys_chdir+0x10d>
    }
    iunlock(ip);
80106fe2:	83 ec 0c             	sub    $0xc,%esp
80106fe5:	ff 75 f4             	pushl  -0xc(%ebp)
80106fe8:	e8 9e b0 ff ff       	call   8010208b <iunlock>
80106fed:	83 c4 10             	add    $0x10,%esp
    iput(proc->cwd);
80106ff0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106ff6:	8b 40 68             	mov    0x68(%eax),%eax
80106ff9:	83 ec 0c             	sub    $0xc,%esp
80106ffc:	50                   	push   %eax
80106ffd:	e8 fb b0 ff ff       	call   801020fd <iput>
80107002:	83 c4 10             	add    $0x10,%esp
    end_op(proc->cwd->part->number);
80107005:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010700b:	8b 40 68             	mov    0x68(%eax),%eax
8010700e:	8b 40 50             	mov    0x50(%eax),%eax
80107011:	8b 40 14             	mov    0x14(%eax),%eax
80107014:	83 ec 0c             	sub    $0xc,%esp
80107017:	50                   	push   %eax
80107018:	e8 7a cf ff ff       	call   80103f97 <end_op>
8010701d:	83 c4 10             	add    $0x10,%esp
    proc->cwd = ip;
80107020:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107026:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107029:	89 50 68             	mov    %edx,0x68(%eax)
    return 0;
8010702c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107031:	c9                   	leave  
80107032:	c3                   	ret    

80107033 <sys_exec>:

int sys_exec(void)
{
80107033:	55                   	push   %ebp
80107034:	89 e5                	mov    %esp,%ebp
80107036:	81 ec 98 00 00 00    	sub    $0x98,%esp
    char* path, *argv[MAXARG];
    int i;
    uint uargv, uarg;

    if (argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0) {
8010703c:	83 ec 08             	sub    $0x8,%esp
8010703f:	8d 45 f0             	lea    -0x10(%ebp),%eax
80107042:	50                   	push   %eax
80107043:	6a 00                	push   $0x0
80107045:	e8 47 f1 ff ff       	call   80106191 <argstr>
8010704a:	83 c4 10             	add    $0x10,%esp
8010704d:	85 c0                	test   %eax,%eax
8010704f:	78 18                	js     80107069 <sys_exec+0x36>
80107051:	83 ec 08             	sub    $0x8,%esp
80107054:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
8010705a:	50                   	push   %eax
8010705b:	6a 01                	push   $0x1
8010705d:	e8 aa f0 ff ff       	call   8010610c <argint>
80107062:	83 c4 10             	add    $0x10,%esp
80107065:	85 c0                	test   %eax,%eax
80107067:	79 0a                	jns    80107073 <sys_exec+0x40>
        return -1;
80107069:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010706e:	e9 c6 00 00 00       	jmp    80107139 <sys_exec+0x106>
    }
    memset(argv, 0, sizeof(argv));
80107073:	83 ec 04             	sub    $0x4,%esp
80107076:	68 80 00 00 00       	push   $0x80
8010707b:	6a 00                	push   $0x0
8010707d:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80107083:	50                   	push   %eax
80107084:	e8 5e ed ff ff       	call   80105de7 <memset>
80107089:	83 c4 10             	add    $0x10,%esp
    for (i = 0;; i++) {
8010708c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
        if (i >= NELEM(argv))
80107093:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107096:	83 f8 1f             	cmp    $0x1f,%eax
80107099:	76 0a                	jbe    801070a5 <sys_exec+0x72>
            return -1;
8010709b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801070a0:	e9 94 00 00 00       	jmp    80107139 <sys_exec+0x106>
        if (fetchint(uargv + 4 * i, (int*)&uarg) < 0)
801070a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070a8:	c1 e0 02             	shl    $0x2,%eax
801070ab:	89 c2                	mov    %eax,%edx
801070ad:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
801070b3:	01 c2                	add    %eax,%edx
801070b5:	83 ec 08             	sub    $0x8,%esp
801070b8:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
801070be:	50                   	push   %eax
801070bf:	52                   	push   %edx
801070c0:	e8 ab ef ff ff       	call   80106070 <fetchint>
801070c5:	83 c4 10             	add    $0x10,%esp
801070c8:	85 c0                	test   %eax,%eax
801070ca:	79 07                	jns    801070d3 <sys_exec+0xa0>
            return -1;
801070cc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801070d1:	eb 66                	jmp    80107139 <sys_exec+0x106>
        if (uarg == 0) {
801070d3:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
801070d9:	85 c0                	test   %eax,%eax
801070db:	75 27                	jne    80107104 <sys_exec+0xd1>
            argv[i] = 0;
801070dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070e0:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
801070e7:	00 00 00 00 
            break;
801070eb:	90                   	nop
        }
        if (fetchstr(uarg, &argv[i]) < 0)
            return -1;
    }
    return exec(path, argv);
801070ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
801070ef:	83 ec 08             	sub    $0x8,%esp
801070f2:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
801070f8:	52                   	push   %edx
801070f9:	50                   	push   %eax
801070fa:	e8 72 9a ff ff       	call   80100b71 <exec>
801070ff:	83 c4 10             	add    $0x10,%esp
80107102:	eb 35                	jmp    80107139 <sys_exec+0x106>
            return -1;
        if (uarg == 0) {
            argv[i] = 0;
            break;
        }
        if (fetchstr(uarg, &argv[i]) < 0)
80107104:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
8010710a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010710d:	c1 e2 02             	shl    $0x2,%edx
80107110:	01 c2                	add    %eax,%edx
80107112:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80107118:	83 ec 08             	sub    $0x8,%esp
8010711b:	52                   	push   %edx
8010711c:	50                   	push   %eax
8010711d:	e8 88 ef ff ff       	call   801060aa <fetchstr>
80107122:	83 c4 10             	add    $0x10,%esp
80107125:	85 c0                	test   %eax,%eax
80107127:	79 07                	jns    80107130 <sys_exec+0xfd>
            return -1;
80107129:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010712e:	eb 09                	jmp    80107139 <sys_exec+0x106>

    if (argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0) {
        return -1;
    }
    memset(argv, 0, sizeof(argv));
    for (i = 0;; i++) {
80107130:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
            argv[i] = 0;
            break;
        }
        if (fetchstr(uarg, &argv[i]) < 0)
            return -1;
    }
80107134:	e9 5a ff ff ff       	jmp    80107093 <sys_exec+0x60>
    return exec(path, argv);
}
80107139:	c9                   	leave  
8010713a:	c3                   	ret    

8010713b <sys_pipe>:

int sys_pipe(void)
{
8010713b:	55                   	push   %ebp
8010713c:	89 e5                	mov    %esp,%ebp
8010713e:	83 ec 28             	sub    $0x28,%esp
    int* fd;
    struct file* rf, *wf;
    int fd0, fd1;

    if (argptr(0, (void*)&fd, 2 * sizeof(fd[0])) < 0)
80107141:	83 ec 04             	sub    $0x4,%esp
80107144:	6a 08                	push   $0x8
80107146:	8d 45 ec             	lea    -0x14(%ebp),%eax
80107149:	50                   	push   %eax
8010714a:	6a 00                	push   $0x0
8010714c:	e8 e3 ef ff ff       	call   80106134 <argptr>
80107151:	83 c4 10             	add    $0x10,%esp
80107154:	85 c0                	test   %eax,%eax
80107156:	79 0a                	jns    80107162 <sys_pipe+0x27>
        return -1;
80107158:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010715d:	e9 af 00 00 00       	jmp    80107211 <sys_pipe+0xd6>
    if (pipealloc(&rf, &wf) < 0)
80107162:	83 ec 08             	sub    $0x8,%esp
80107165:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80107168:	50                   	push   %eax
80107169:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010716c:	50                   	push   %eax
8010716d:	e8 ee d9 ff ff       	call   80104b60 <pipealloc>
80107172:	83 c4 10             	add    $0x10,%esp
80107175:	85 c0                	test   %eax,%eax
80107177:	79 0a                	jns    80107183 <sys_pipe+0x48>
        return -1;
80107179:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010717e:	e9 8e 00 00 00       	jmp    80107211 <sys_pipe+0xd6>
    fd0 = -1;
80107183:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
    if ((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0) {
8010718a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010718d:	83 ec 0c             	sub    $0xc,%esp
80107190:	50                   	push   %eax
80107191:	e8 27 f1 ff ff       	call   801062bd <fdalloc>
80107196:	83 c4 10             	add    $0x10,%esp
80107199:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010719c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801071a0:	78 18                	js     801071ba <sys_pipe+0x7f>
801071a2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801071a5:	83 ec 0c             	sub    $0xc,%esp
801071a8:	50                   	push   %eax
801071a9:	e8 0f f1 ff ff       	call   801062bd <fdalloc>
801071ae:	83 c4 10             	add    $0x10,%esp
801071b1:	89 45 f0             	mov    %eax,-0x10(%ebp)
801071b4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801071b8:	79 3f                	jns    801071f9 <sys_pipe+0xbe>
        if (fd0 >= 0)
801071ba:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801071be:	78 14                	js     801071d4 <sys_pipe+0x99>
            proc->ofile[fd0] = 0;
801071c0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801071c6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801071c9:	83 c2 08             	add    $0x8,%edx
801071cc:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801071d3:	00 
        fileclose(rf);
801071d4:	8b 45 e8             	mov    -0x18(%ebp),%eax
801071d7:	83 ec 0c             	sub    $0xc,%esp
801071da:	50                   	push   %eax
801071db:	e8 c9 9e ff ff       	call   801010a9 <fileclose>
801071e0:	83 c4 10             	add    $0x10,%esp
        fileclose(wf);
801071e3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801071e6:	83 ec 0c             	sub    $0xc,%esp
801071e9:	50                   	push   %eax
801071ea:	e8 ba 9e ff ff       	call   801010a9 <fileclose>
801071ef:	83 c4 10             	add    $0x10,%esp
        return -1;
801071f2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801071f7:	eb 18                	jmp    80107211 <sys_pipe+0xd6>
    }
    fd[0] = fd0;
801071f9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801071fc:	8b 55 f4             	mov    -0xc(%ebp),%edx
801071ff:	89 10                	mov    %edx,(%eax)
    fd[1] = fd1;
80107201:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107204:	8d 50 04             	lea    0x4(%eax),%edx
80107207:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010720a:	89 02                	mov    %eax,(%edx)
    return 0;
8010720c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107211:	c9                   	leave  
80107212:	c3                   	ret    

80107213 <sys_mount>:

int sys_mount(void)
{
80107213:	55                   	push   %ebp
80107214:	89 e5                	mov    %esp,%ebp
80107216:	83 ec 18             	sub    $0x18,%esp
    char* path;
    uint partitionNumber;
    struct inode * i;
    if (argstr(0, &path) < 0 || argint(1, (int*)&partitionNumber) < 0 || partitionNumber < 0 || partitionNumber > NPARTITIONS) {
80107219:	83 ec 08             	sub    $0x8,%esp
8010721c:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010721f:	50                   	push   %eax
80107220:	6a 00                	push   $0x0
80107222:	e8 6a ef ff ff       	call   80106191 <argstr>
80107227:	83 c4 10             	add    $0x10,%esp
8010722a:	85 c0                	test   %eax,%eax
8010722c:	78 1d                	js     8010724b <sys_mount+0x38>
8010722e:	83 ec 08             	sub    $0x8,%esp
80107231:	8d 45 ec             	lea    -0x14(%ebp),%eax
80107234:	50                   	push   %eax
80107235:	6a 01                	push   $0x1
80107237:	e8 d0 ee ff ff       	call   8010610c <argint>
8010723c:	83 c4 10             	add    $0x10,%esp
8010723f:	85 c0                	test   %eax,%eax
80107241:	78 08                	js     8010724b <sys_mount+0x38>
80107243:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107246:	83 f8 04             	cmp    $0x4,%eax
80107249:	76 07                	jbe    80107252 <sys_mount+0x3f>
        return -1;
8010724b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107250:	eb 55                	jmp    801072a7 <sys_mount+0x94>
    }

    i=nameiIgnoreMounts(path);
80107252:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107255:	83 ec 0c             	sub    $0xc,%esp
80107258:	50                   	push   %eax
80107259:	e8 b8 ba ff ff       	call   80102d16 <nameiIgnoreMounts>
8010725e:	83 c4 10             	add    $0x10,%esp
80107261:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(i==0){
80107264:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107268:	75 07                	jne    80107271 <sys_mount+0x5e>
        return -1;
8010726a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010726f:	eb 36                	jmp    801072a7 <sys_mount+0x94>
    }
    ilock(i);
80107271:	83 ec 0c             	sub    $0xc,%esp
80107274:	ff 75 f4             	pushl  -0xc(%ebp)
80107277:	e8 6e ac ff ff       	call   80101eea <ilock>
8010727c:	83 c4 10             	add    $0x10,%esp
    i->major=MOUNTING_POINT;
8010727f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107282:	66 c7 40 12 01 00    	movw   $0x1,0x12(%eax)
    i->minor=partitionNumber;
80107288:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010728b:	89 c2                	mov    %eax,%edx
8010728d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107290:	66 89 50 14          	mov    %dx,0x14(%eax)
    iunlockput(i);
80107294:	83 ec 0c             	sub    $0xc,%esp
80107297:	ff 75 f4             	pushl  -0xc(%ebp)
8010729a:	e8 4e af ff ff       	call   801021ed <iunlockput>
8010729f:	83 c4 10             	add    $0x10,%esp
    return 0;
801072a2:	b8 00 00 00 00       	mov    $0x0,%eax
}
801072a7:	c9                   	leave  
801072a8:	c3                   	ret    

801072a9 <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
801072a9:	55                   	push   %ebp
801072aa:	89 e5                	mov    %esp,%ebp
801072ac:	83 ec 08             	sub    $0x8,%esp
  return fork();
801072af:	e8 a2 df ff ff       	call   80105256 <fork>
}
801072b4:	c9                   	leave  
801072b5:	c3                   	ret    

801072b6 <sys_exit>:

int
sys_exit(void)
{
801072b6:	55                   	push   %ebp
801072b7:	89 e5                	mov    %esp,%ebp
801072b9:	83 ec 08             	sub    $0x8,%esp
  exit();
801072bc:	e8 26 e1 ff ff       	call   801053e7 <exit>
  return 0;  // not reached
801072c1:	b8 00 00 00 00       	mov    $0x0,%eax
}
801072c6:	c9                   	leave  
801072c7:	c3                   	ret    

801072c8 <sys_wait>:

int
sys_wait(void)
{
801072c8:	55                   	push   %ebp
801072c9:	89 e5                	mov    %esp,%ebp
801072cb:	83 ec 08             	sub    $0x8,%esp
  return wait();
801072ce:	e8 78 e2 ff ff       	call   8010554b <wait>
}
801072d3:	c9                   	leave  
801072d4:	c3                   	ret    

801072d5 <sys_kill>:

int
sys_kill(void)
{
801072d5:	55                   	push   %ebp
801072d6:	89 e5                	mov    %esp,%ebp
801072d8:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
801072db:	83 ec 08             	sub    $0x8,%esp
801072de:	8d 45 f4             	lea    -0xc(%ebp),%eax
801072e1:	50                   	push   %eax
801072e2:	6a 00                	push   $0x0
801072e4:	e8 23 ee ff ff       	call   8010610c <argint>
801072e9:	83 c4 10             	add    $0x10,%esp
801072ec:	85 c0                	test   %eax,%eax
801072ee:	79 07                	jns    801072f7 <sys_kill+0x22>
    return -1;
801072f0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801072f5:	eb 0f                	jmp    80107306 <sys_kill+0x31>
  return kill(pid);
801072f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072fa:	83 ec 0c             	sub    $0xc,%esp
801072fd:	50                   	push   %eax
801072fe:	e8 aa e6 ff ff       	call   801059ad <kill>
80107303:	83 c4 10             	add    $0x10,%esp
}
80107306:	c9                   	leave  
80107307:	c3                   	ret    

80107308 <sys_getpid>:

int
sys_getpid(void)
{
80107308:	55                   	push   %ebp
80107309:	89 e5                	mov    %esp,%ebp
  return proc->pid;
8010730b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107311:	8b 40 10             	mov    0x10(%eax),%eax
}
80107314:	5d                   	pop    %ebp
80107315:	c3                   	ret    

80107316 <sys_sbrk>:

int
sys_sbrk(void)
{
80107316:	55                   	push   %ebp
80107317:	89 e5                	mov    %esp,%ebp
80107319:	83 ec 18             	sub    $0x18,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
8010731c:	83 ec 08             	sub    $0x8,%esp
8010731f:	8d 45 f0             	lea    -0x10(%ebp),%eax
80107322:	50                   	push   %eax
80107323:	6a 00                	push   $0x0
80107325:	e8 e2 ed ff ff       	call   8010610c <argint>
8010732a:	83 c4 10             	add    $0x10,%esp
8010732d:	85 c0                	test   %eax,%eax
8010732f:	79 07                	jns    80107338 <sys_sbrk+0x22>
    return -1;
80107331:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107336:	eb 28                	jmp    80107360 <sys_sbrk+0x4a>
  addr = proc->sz;
80107338:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010733e:	8b 00                	mov    (%eax),%eax
80107340:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
80107343:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107346:	83 ec 0c             	sub    $0xc,%esp
80107349:	50                   	push   %eax
8010734a:	e8 64 de ff ff       	call   801051b3 <growproc>
8010734f:	83 c4 10             	add    $0x10,%esp
80107352:	85 c0                	test   %eax,%eax
80107354:	79 07                	jns    8010735d <sys_sbrk+0x47>
    return -1;
80107356:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010735b:	eb 03                	jmp    80107360 <sys_sbrk+0x4a>
  return addr;
8010735d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80107360:	c9                   	leave  
80107361:	c3                   	ret    

80107362 <sys_sleep>:

int
sys_sleep(void)
{
80107362:	55                   	push   %ebp
80107363:	89 e5                	mov    %esp,%ebp
80107365:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;
  
  if(argint(0, &n) < 0)
80107368:	83 ec 08             	sub    $0x8,%esp
8010736b:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010736e:	50                   	push   %eax
8010736f:	6a 00                	push   $0x0
80107371:	e8 96 ed ff ff       	call   8010610c <argint>
80107376:	83 c4 10             	add    $0x10,%esp
80107379:	85 c0                	test   %eax,%eax
8010737b:	79 07                	jns    80107384 <sys_sleep+0x22>
    return -1;
8010737d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107382:	eb 77                	jmp    801073fb <sys_sleep+0x99>
  acquire(&tickslock);
80107384:	83 ec 0c             	sub    $0xc,%esp
80107387:	68 c0 5d 11 80       	push   $0x80115dc0
8010738c:	e8 f3 e7 ff ff       	call   80105b84 <acquire>
80107391:	83 c4 10             	add    $0x10,%esp
  ticks0 = ticks;
80107394:	a1 00 66 11 80       	mov    0x80116600,%eax
80107399:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
8010739c:	eb 39                	jmp    801073d7 <sys_sleep+0x75>
    if(proc->killed){
8010739e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801073a4:	8b 40 24             	mov    0x24(%eax),%eax
801073a7:	85 c0                	test   %eax,%eax
801073a9:	74 17                	je     801073c2 <sys_sleep+0x60>
      release(&tickslock);
801073ab:	83 ec 0c             	sub    $0xc,%esp
801073ae:	68 c0 5d 11 80       	push   $0x80115dc0
801073b3:	e8 33 e8 ff ff       	call   80105beb <release>
801073b8:	83 c4 10             	add    $0x10,%esp
      return -1;
801073bb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801073c0:	eb 39                	jmp    801073fb <sys_sleep+0x99>
    }
    sleep(&ticks, &tickslock);
801073c2:	83 ec 08             	sub    $0x8,%esp
801073c5:	68 c0 5d 11 80       	push   $0x80115dc0
801073ca:	68 00 66 11 80       	push   $0x80116600
801073cf:	e8 b7 e4 ff ff       	call   8010588b <sleep>
801073d4:	83 c4 10             	add    $0x10,%esp
  
  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
801073d7:	a1 00 66 11 80       	mov    0x80116600,%eax
801073dc:	2b 45 f4             	sub    -0xc(%ebp),%eax
801073df:	8b 55 f0             	mov    -0x10(%ebp),%edx
801073e2:	39 d0                	cmp    %edx,%eax
801073e4:	72 b8                	jb     8010739e <sys_sleep+0x3c>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
801073e6:	83 ec 0c             	sub    $0xc,%esp
801073e9:	68 c0 5d 11 80       	push   $0x80115dc0
801073ee:	e8 f8 e7 ff ff       	call   80105beb <release>
801073f3:	83 c4 10             	add    $0x10,%esp
  return 0;
801073f6:	b8 00 00 00 00       	mov    $0x0,%eax
}
801073fb:	c9                   	leave  
801073fc:	c3                   	ret    

801073fd <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
801073fd:	55                   	push   %ebp
801073fe:	89 e5                	mov    %esp,%ebp
80107400:	83 ec 18             	sub    $0x18,%esp
  uint xticks;
  
  acquire(&tickslock);
80107403:	83 ec 0c             	sub    $0xc,%esp
80107406:	68 c0 5d 11 80       	push   $0x80115dc0
8010740b:	e8 74 e7 ff ff       	call   80105b84 <acquire>
80107410:	83 c4 10             	add    $0x10,%esp
  xticks = ticks;
80107413:	a1 00 66 11 80       	mov    0x80116600,%eax
80107418:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
8010741b:	83 ec 0c             	sub    $0xc,%esp
8010741e:	68 c0 5d 11 80       	push   $0x80115dc0
80107423:	e8 c3 e7 ff ff       	call   80105beb <release>
80107428:	83 c4 10             	add    $0x10,%esp
  return xticks;
8010742b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010742e:	c9                   	leave  
8010742f:	c3                   	ret    

80107430 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80107430:	55                   	push   %ebp
80107431:	89 e5                	mov    %esp,%ebp
80107433:	83 ec 08             	sub    $0x8,%esp
80107436:	8b 55 08             	mov    0x8(%ebp),%edx
80107439:	8b 45 0c             	mov    0xc(%ebp),%eax
8010743c:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80107440:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80107443:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80107447:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010744b:	ee                   	out    %al,(%dx)
}
8010744c:	90                   	nop
8010744d:	c9                   	leave  
8010744e:	c3                   	ret    

8010744f <timerinit>:
#define TIMER_RATEGEN   0x04    // mode 2, rate generator
#define TIMER_16BIT     0x30    // r/w counter 16 bits, LSB first

void
timerinit(void)
{
8010744f:	55                   	push   %ebp
80107450:	89 e5                	mov    %esp,%ebp
80107452:	83 ec 08             	sub    $0x8,%esp
  // Interrupt 100 times/sec.
  outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
80107455:	6a 34                	push   $0x34
80107457:	6a 43                	push   $0x43
80107459:	e8 d2 ff ff ff       	call   80107430 <outb>
8010745e:	83 c4 08             	add    $0x8,%esp
  outb(IO_TIMER1, TIMER_DIV(100) % 256);
80107461:	68 9c 00 00 00       	push   $0x9c
80107466:	6a 40                	push   $0x40
80107468:	e8 c3 ff ff ff       	call   80107430 <outb>
8010746d:	83 c4 08             	add    $0x8,%esp
  outb(IO_TIMER1, TIMER_DIV(100) / 256);
80107470:	6a 2e                	push   $0x2e
80107472:	6a 40                	push   $0x40
80107474:	e8 b7 ff ff ff       	call   80107430 <outb>
80107479:	83 c4 08             	add    $0x8,%esp
  picenable(IRQ_TIMER);
8010747c:	83 ec 0c             	sub    $0xc,%esp
8010747f:	6a 00                	push   $0x0
80107481:	e8 c4 d5 ff ff       	call   80104a4a <picenable>
80107486:	83 c4 10             	add    $0x10,%esp
}
80107489:	90                   	nop
8010748a:	c9                   	leave  
8010748b:	c3                   	ret    

8010748c <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
8010748c:	1e                   	push   %ds
  pushl %es
8010748d:	06                   	push   %es
  pushl %fs
8010748e:	0f a0                	push   %fs
  pushl %gs
80107490:	0f a8                	push   %gs
  pushal
80107492:	60                   	pusha  
  
  # Set up data and per-cpu segments.
  movw $(SEG_KDATA<<3), %ax
80107493:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80107497:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80107499:	8e c0                	mov    %eax,%es
  movw $(SEG_KCPU<<3), %ax
8010749b:	66 b8 18 00          	mov    $0x18,%ax
  movw %ax, %fs
8010749f:	8e e0                	mov    %eax,%fs
  movw %ax, %gs
801074a1:	8e e8                	mov    %eax,%gs

  # Call trap(tf), where tf=%esp
  pushl %esp
801074a3:	54                   	push   %esp
  call trap
801074a4:	e8 d7 01 00 00       	call   80107680 <trap>
  addl $4, %esp
801074a9:	83 c4 04             	add    $0x4,%esp

801074ac <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
801074ac:	61                   	popa   
  popl %gs
801074ad:	0f a9                	pop    %gs
  popl %fs
801074af:	0f a1                	pop    %fs
  popl %es
801074b1:	07                   	pop    %es
  popl %ds
801074b2:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
801074b3:	83 c4 08             	add    $0x8,%esp
  iret
801074b6:	cf                   	iret   

801074b7 <lidt>:

struct gatedesc;

static inline void
lidt(struct gatedesc *p, int size)
{
801074b7:	55                   	push   %ebp
801074b8:	89 e5                	mov    %esp,%ebp
801074ba:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
801074bd:	8b 45 0c             	mov    0xc(%ebp),%eax
801074c0:	83 e8 01             	sub    $0x1,%eax
801074c3:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
801074c7:	8b 45 08             	mov    0x8(%ebp),%eax
801074ca:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
801074ce:	8b 45 08             	mov    0x8(%ebp),%eax
801074d1:	c1 e8 10             	shr    $0x10,%eax
801074d4:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lidt (%0)" : : "r" (pd));
801074d8:	8d 45 fa             	lea    -0x6(%ebp),%eax
801074db:	0f 01 18             	lidtl  (%eax)
}
801074de:	90                   	nop
801074df:	c9                   	leave  
801074e0:	c3                   	ret    

801074e1 <rcr2>:
  return result;
}

static inline uint
rcr2(void)
{
801074e1:	55                   	push   %ebp
801074e2:	89 e5                	mov    %esp,%ebp
801074e4:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
801074e7:	0f 20 d0             	mov    %cr2,%eax
801074ea:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
801074ed:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801074f0:	c9                   	leave  
801074f1:	c3                   	ret    

801074f2 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
801074f2:	55                   	push   %ebp
801074f3:	89 e5                	mov    %esp,%ebp
801074f5:	83 ec 18             	sub    $0x18,%esp
  int i;

  for(i = 0; i < 256; i++)
801074f8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801074ff:	e9 c3 00 00 00       	jmp    801075c7 <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80107504:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107507:	8b 04 85 9c c0 10 80 	mov    -0x7fef3f64(,%eax,4),%eax
8010750e:	89 c2                	mov    %eax,%edx
80107510:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107513:	66 89 14 c5 00 5e 11 	mov    %dx,-0x7feea200(,%eax,8)
8010751a:	80 
8010751b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010751e:	66 c7 04 c5 02 5e 11 	movw   $0x8,-0x7feea1fe(,%eax,8)
80107525:	80 08 00 
80107528:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010752b:	0f b6 14 c5 04 5e 11 	movzbl -0x7feea1fc(,%eax,8),%edx
80107532:	80 
80107533:	83 e2 e0             	and    $0xffffffe0,%edx
80107536:	88 14 c5 04 5e 11 80 	mov    %dl,-0x7feea1fc(,%eax,8)
8010753d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107540:	0f b6 14 c5 04 5e 11 	movzbl -0x7feea1fc(,%eax,8),%edx
80107547:	80 
80107548:	83 e2 1f             	and    $0x1f,%edx
8010754b:	88 14 c5 04 5e 11 80 	mov    %dl,-0x7feea1fc(,%eax,8)
80107552:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107555:	0f b6 14 c5 05 5e 11 	movzbl -0x7feea1fb(,%eax,8),%edx
8010755c:	80 
8010755d:	83 e2 f0             	and    $0xfffffff0,%edx
80107560:	83 ca 0e             	or     $0xe,%edx
80107563:	88 14 c5 05 5e 11 80 	mov    %dl,-0x7feea1fb(,%eax,8)
8010756a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010756d:	0f b6 14 c5 05 5e 11 	movzbl -0x7feea1fb(,%eax,8),%edx
80107574:	80 
80107575:	83 e2 ef             	and    $0xffffffef,%edx
80107578:	88 14 c5 05 5e 11 80 	mov    %dl,-0x7feea1fb(,%eax,8)
8010757f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107582:	0f b6 14 c5 05 5e 11 	movzbl -0x7feea1fb(,%eax,8),%edx
80107589:	80 
8010758a:	83 e2 9f             	and    $0xffffff9f,%edx
8010758d:	88 14 c5 05 5e 11 80 	mov    %dl,-0x7feea1fb(,%eax,8)
80107594:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107597:	0f b6 14 c5 05 5e 11 	movzbl -0x7feea1fb(,%eax,8),%edx
8010759e:	80 
8010759f:	83 ca 80             	or     $0xffffff80,%edx
801075a2:	88 14 c5 05 5e 11 80 	mov    %dl,-0x7feea1fb(,%eax,8)
801075a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075ac:	8b 04 85 9c c0 10 80 	mov    -0x7fef3f64(,%eax,4),%eax
801075b3:	c1 e8 10             	shr    $0x10,%eax
801075b6:	89 c2                	mov    %eax,%edx
801075b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075bb:	66 89 14 c5 06 5e 11 	mov    %dx,-0x7feea1fa(,%eax,8)
801075c2:	80 
void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
801075c3:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801075c7:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
801075ce:	0f 8e 30 ff ff ff    	jle    80107504 <tvinit+0x12>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
801075d4:	a1 9c c1 10 80       	mov    0x8010c19c,%eax
801075d9:	66 a3 00 60 11 80    	mov    %ax,0x80116000
801075df:	66 c7 05 02 60 11 80 	movw   $0x8,0x80116002
801075e6:	08 00 
801075e8:	0f b6 05 04 60 11 80 	movzbl 0x80116004,%eax
801075ef:	83 e0 e0             	and    $0xffffffe0,%eax
801075f2:	a2 04 60 11 80       	mov    %al,0x80116004
801075f7:	0f b6 05 04 60 11 80 	movzbl 0x80116004,%eax
801075fe:	83 e0 1f             	and    $0x1f,%eax
80107601:	a2 04 60 11 80       	mov    %al,0x80116004
80107606:	0f b6 05 05 60 11 80 	movzbl 0x80116005,%eax
8010760d:	83 c8 0f             	or     $0xf,%eax
80107610:	a2 05 60 11 80       	mov    %al,0x80116005
80107615:	0f b6 05 05 60 11 80 	movzbl 0x80116005,%eax
8010761c:	83 e0 ef             	and    $0xffffffef,%eax
8010761f:	a2 05 60 11 80       	mov    %al,0x80116005
80107624:	0f b6 05 05 60 11 80 	movzbl 0x80116005,%eax
8010762b:	83 c8 60             	or     $0x60,%eax
8010762e:	a2 05 60 11 80       	mov    %al,0x80116005
80107633:	0f b6 05 05 60 11 80 	movzbl 0x80116005,%eax
8010763a:	83 c8 80             	or     $0xffffff80,%eax
8010763d:	a2 05 60 11 80       	mov    %al,0x80116005
80107642:	a1 9c c1 10 80       	mov    0x8010c19c,%eax
80107647:	c1 e8 10             	shr    $0x10,%eax
8010764a:	66 a3 06 60 11 80    	mov    %ax,0x80116006
  
  initlock(&tickslock, "time");
80107650:	83 ec 08             	sub    $0x8,%esp
80107653:	68 58 99 10 80       	push   $0x80109958
80107658:	68 c0 5d 11 80       	push   $0x80115dc0
8010765d:	e8 00 e5 ff ff       	call   80105b62 <initlock>
80107662:	83 c4 10             	add    $0x10,%esp
}
80107665:	90                   	nop
80107666:	c9                   	leave  
80107667:	c3                   	ret    

80107668 <idtinit>:

void
idtinit(void)
{
80107668:	55                   	push   %ebp
80107669:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
8010766b:	68 00 08 00 00       	push   $0x800
80107670:	68 00 5e 11 80       	push   $0x80115e00
80107675:	e8 3d fe ff ff       	call   801074b7 <lidt>
8010767a:	83 c4 08             	add    $0x8,%esp
}
8010767d:	90                   	nop
8010767e:	c9                   	leave  
8010767f:	c3                   	ret    

80107680 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80107680:	55                   	push   %ebp
80107681:	89 e5                	mov    %esp,%ebp
80107683:	57                   	push   %edi
80107684:	56                   	push   %esi
80107685:	53                   	push   %ebx
80107686:	83 ec 1c             	sub    $0x1c,%esp
  if(tf->trapno == T_SYSCALL){
80107689:	8b 45 08             	mov    0x8(%ebp),%eax
8010768c:	8b 40 30             	mov    0x30(%eax),%eax
8010768f:	83 f8 40             	cmp    $0x40,%eax
80107692:	75 3e                	jne    801076d2 <trap+0x52>
    if(proc->killed)
80107694:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010769a:	8b 40 24             	mov    0x24(%eax),%eax
8010769d:	85 c0                	test   %eax,%eax
8010769f:	74 05                	je     801076a6 <trap+0x26>
      exit();
801076a1:	e8 41 dd ff ff       	call   801053e7 <exit>
    proc->tf = tf;
801076a6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801076ac:	8b 55 08             	mov    0x8(%ebp),%edx
801076af:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
801076b2:	e8 0b eb ff ff       	call   801061c2 <syscall>
    if(proc->killed)
801076b7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801076bd:	8b 40 24             	mov    0x24(%eax),%eax
801076c0:	85 c0                	test   %eax,%eax
801076c2:	0f 84 1b 02 00 00    	je     801078e3 <trap+0x263>
      exit();
801076c8:	e8 1a dd ff ff       	call   801053e7 <exit>
    return;
801076cd:	e9 11 02 00 00       	jmp    801078e3 <trap+0x263>
  }

  switch(tf->trapno){
801076d2:	8b 45 08             	mov    0x8(%ebp),%eax
801076d5:	8b 40 30             	mov    0x30(%eax),%eax
801076d8:	83 e8 20             	sub    $0x20,%eax
801076db:	83 f8 1f             	cmp    $0x1f,%eax
801076de:	0f 87 c0 00 00 00    	ja     801077a4 <trap+0x124>
801076e4:	8b 04 85 00 9a 10 80 	mov    -0x7fef6600(,%eax,4),%eax
801076eb:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpu->id == 0){
801076ed:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801076f3:	0f b6 00             	movzbl (%eax),%eax
801076f6:	84 c0                	test   %al,%al
801076f8:	75 3d                	jne    80107737 <trap+0xb7>
      acquire(&tickslock);
801076fa:	83 ec 0c             	sub    $0xc,%esp
801076fd:	68 c0 5d 11 80       	push   $0x80115dc0
80107702:	e8 7d e4 ff ff       	call   80105b84 <acquire>
80107707:	83 c4 10             	add    $0x10,%esp
      ticks++;
8010770a:	a1 00 66 11 80       	mov    0x80116600,%eax
8010770f:	83 c0 01             	add    $0x1,%eax
80107712:	a3 00 66 11 80       	mov    %eax,0x80116600
      wakeup(&ticks);
80107717:	83 ec 0c             	sub    $0xc,%esp
8010771a:	68 00 66 11 80       	push   $0x80116600
8010771f:	e8 52 e2 ff ff       	call   80105976 <wakeup>
80107724:	83 c4 10             	add    $0x10,%esp
      release(&tickslock);
80107727:	83 ec 0c             	sub    $0xc,%esp
8010772a:	68 c0 5d 11 80       	push   $0x80115dc0
8010772f:	e8 b7 e4 ff ff       	call   80105beb <release>
80107734:	83 c4 10             	add    $0x10,%esp
    }
    lapiceoi();
80107737:	e8 f5 c0 ff ff       	call   80103831 <lapiceoi>
    break;
8010773c:	e9 1c 01 00 00       	jmp    8010785d <trap+0x1dd>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
80107741:	e8 ee b8 ff ff       	call   80103034 <ideintr>
    lapiceoi();
80107746:	e8 e6 c0 ff ff       	call   80103831 <lapiceoi>
    break;
8010774b:	e9 0d 01 00 00       	jmp    8010785d <trap+0x1dd>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
80107750:	e8 de be ff ff       	call   80103633 <kbdintr>
    lapiceoi();
80107755:	e8 d7 c0 ff ff       	call   80103831 <lapiceoi>
    break;
8010775a:	e9 fe 00 00 00       	jmp    8010785d <trap+0x1dd>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
8010775f:	e8 60 03 00 00       	call   80107ac4 <uartintr>
    lapiceoi();
80107764:	e8 c8 c0 ff ff       	call   80103831 <lapiceoi>
    break;
80107769:	e9 ef 00 00 00       	jmp    8010785d <trap+0x1dd>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
8010776e:	8b 45 08             	mov    0x8(%ebp),%eax
80107771:	8b 48 38             	mov    0x38(%eax),%ecx
            cpu->id, tf->cs, tf->eip);
80107774:	8b 45 08             	mov    0x8(%ebp),%eax
80107777:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
8010777b:	0f b7 d0             	movzwl %ax,%edx
            cpu->id, tf->cs, tf->eip);
8010777e:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107784:	0f b6 00             	movzbl (%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80107787:	0f b6 c0             	movzbl %al,%eax
8010778a:	51                   	push   %ecx
8010778b:	52                   	push   %edx
8010778c:	50                   	push   %eax
8010778d:	68 60 99 10 80       	push   $0x80109960
80107792:	e8 2f 8c ff ff       	call   801003c6 <cprintf>
80107797:	83 c4 10             	add    $0x10,%esp
            cpu->id, tf->cs, tf->eip);
    lapiceoi();
8010779a:	e8 92 c0 ff ff       	call   80103831 <lapiceoi>
    break;
8010779f:	e9 b9 00 00 00       	jmp    8010785d <trap+0x1dd>
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
801077a4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801077aa:	85 c0                	test   %eax,%eax
801077ac:	74 11                	je     801077bf <trap+0x13f>
801077ae:	8b 45 08             	mov    0x8(%ebp),%eax
801077b1:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
801077b5:	0f b7 c0             	movzwl %ax,%eax
801077b8:	83 e0 03             	and    $0x3,%eax
801077bb:	85 c0                	test   %eax,%eax
801077bd:	75 40                	jne    801077ff <trap+0x17f>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
801077bf:	e8 1d fd ff ff       	call   801074e1 <rcr2>
801077c4:	89 c3                	mov    %eax,%ebx
801077c6:	8b 45 08             	mov    0x8(%ebp),%eax
801077c9:	8b 48 38             	mov    0x38(%eax),%ecx
              tf->trapno, cpu->id, tf->eip, rcr2());
801077cc:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801077d2:	0f b6 00             	movzbl (%eax),%eax
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
801077d5:	0f b6 d0             	movzbl %al,%edx
801077d8:	8b 45 08             	mov    0x8(%ebp),%eax
801077db:	8b 40 30             	mov    0x30(%eax),%eax
801077de:	83 ec 0c             	sub    $0xc,%esp
801077e1:	53                   	push   %ebx
801077e2:	51                   	push   %ecx
801077e3:	52                   	push   %edx
801077e4:	50                   	push   %eax
801077e5:	68 84 99 10 80       	push   $0x80109984
801077ea:	e8 d7 8b ff ff       	call   801003c6 <cprintf>
801077ef:	83 c4 20             	add    $0x20,%esp
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
801077f2:	83 ec 0c             	sub    $0xc,%esp
801077f5:	68 b6 99 10 80       	push   $0x801099b6
801077fa:	e8 67 8d ff ff       	call   80100566 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801077ff:	e8 dd fc ff ff       	call   801074e1 <rcr2>
80107804:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80107807:	8b 45 08             	mov    0x8(%ebp),%eax
8010780a:	8b 70 38             	mov    0x38(%eax),%esi
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
8010780d:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107813:	0f b6 00             	movzbl (%eax),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80107816:	0f b6 d8             	movzbl %al,%ebx
80107819:	8b 45 08             	mov    0x8(%ebp),%eax
8010781c:	8b 48 34             	mov    0x34(%eax),%ecx
8010781f:	8b 45 08             	mov    0x8(%ebp),%eax
80107822:	8b 50 30             	mov    0x30(%eax),%edx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80107825:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010782b:	8d 78 6c             	lea    0x6c(%eax),%edi
8010782e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80107834:	8b 40 10             	mov    0x10(%eax),%eax
80107837:	ff 75 e4             	pushl  -0x1c(%ebp)
8010783a:	56                   	push   %esi
8010783b:	53                   	push   %ebx
8010783c:	51                   	push   %ecx
8010783d:	52                   	push   %edx
8010783e:	57                   	push   %edi
8010783f:	50                   	push   %eax
80107840:	68 bc 99 10 80       	push   $0x801099bc
80107845:	e8 7c 8b ff ff       	call   801003c6 <cprintf>
8010784a:	83 c4 20             	add    $0x20,%esp
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
            rcr2());
    proc->killed = 1;
8010784d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107853:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
8010785a:	eb 01                	jmp    8010785d <trap+0x1dd>
    ideintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
8010785c:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running 
  // until it gets to the regular system call return.)
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
8010785d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107863:	85 c0                	test   %eax,%eax
80107865:	74 24                	je     8010788b <trap+0x20b>
80107867:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010786d:	8b 40 24             	mov    0x24(%eax),%eax
80107870:	85 c0                	test   %eax,%eax
80107872:	74 17                	je     8010788b <trap+0x20b>
80107874:	8b 45 08             	mov    0x8(%ebp),%eax
80107877:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
8010787b:	0f b7 c0             	movzwl %ax,%eax
8010787e:	83 e0 03             	and    $0x3,%eax
80107881:	83 f8 03             	cmp    $0x3,%eax
80107884:	75 05                	jne    8010788b <trap+0x20b>
    exit();
80107886:	e8 5c db ff ff       	call   801053e7 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(proc && proc->state == RUNNING && tf->trapno == T_IRQ0+IRQ_TIMER)
8010788b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107891:	85 c0                	test   %eax,%eax
80107893:	74 1e                	je     801078b3 <trap+0x233>
80107895:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010789b:	8b 40 0c             	mov    0xc(%eax),%eax
8010789e:	83 f8 04             	cmp    $0x4,%eax
801078a1:	75 10                	jne    801078b3 <trap+0x233>
801078a3:	8b 45 08             	mov    0x8(%ebp),%eax
801078a6:	8b 40 30             	mov    0x30(%eax),%eax
801078a9:	83 f8 20             	cmp    $0x20,%eax
801078ac:	75 05                	jne    801078b3 <trap+0x233>
    yield();
801078ae:	e8 1d df ff ff       	call   801057d0 <yield>

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
801078b3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801078b9:	85 c0                	test   %eax,%eax
801078bb:	74 27                	je     801078e4 <trap+0x264>
801078bd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801078c3:	8b 40 24             	mov    0x24(%eax),%eax
801078c6:	85 c0                	test   %eax,%eax
801078c8:	74 1a                	je     801078e4 <trap+0x264>
801078ca:	8b 45 08             	mov    0x8(%ebp),%eax
801078cd:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
801078d1:	0f b7 c0             	movzwl %ax,%eax
801078d4:	83 e0 03             	and    $0x3,%eax
801078d7:	83 f8 03             	cmp    $0x3,%eax
801078da:	75 08                	jne    801078e4 <trap+0x264>
    exit();
801078dc:	e8 06 db ff ff       	call   801053e7 <exit>
801078e1:	eb 01                	jmp    801078e4 <trap+0x264>
      exit();
    proc->tf = tf;
    syscall();
    if(proc->killed)
      exit();
    return;
801078e3:	90                   	nop
    yield();

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
    exit();
}
801078e4:	8d 65 f4             	lea    -0xc(%ebp),%esp
801078e7:	5b                   	pop    %ebx
801078e8:	5e                   	pop    %esi
801078e9:	5f                   	pop    %edi
801078ea:	5d                   	pop    %ebp
801078eb:	c3                   	ret    

801078ec <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801078ec:	55                   	push   %ebp
801078ed:	89 e5                	mov    %esp,%ebp
801078ef:	83 ec 14             	sub    $0x14,%esp
801078f2:	8b 45 08             	mov    0x8(%ebp),%eax
801078f5:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801078f9:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801078fd:	89 c2                	mov    %eax,%edx
801078ff:	ec                   	in     (%dx),%al
80107900:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80107903:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80107907:	c9                   	leave  
80107908:	c3                   	ret    

80107909 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80107909:	55                   	push   %ebp
8010790a:	89 e5                	mov    %esp,%ebp
8010790c:	83 ec 08             	sub    $0x8,%esp
8010790f:	8b 55 08             	mov    0x8(%ebp),%edx
80107912:	8b 45 0c             	mov    0xc(%ebp),%eax
80107915:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80107919:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010791c:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80107920:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80107924:	ee                   	out    %al,(%dx)
}
80107925:	90                   	nop
80107926:	c9                   	leave  
80107927:	c3                   	ret    

80107928 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
80107928:	55                   	push   %ebp
80107929:	89 e5                	mov    %esp,%ebp
8010792b:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
8010792e:	6a 00                	push   $0x0
80107930:	68 fa 03 00 00       	push   $0x3fa
80107935:	e8 cf ff ff ff       	call   80107909 <outb>
8010793a:	83 c4 08             	add    $0x8,%esp
  
  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
8010793d:	68 80 00 00 00       	push   $0x80
80107942:	68 fb 03 00 00       	push   $0x3fb
80107947:	e8 bd ff ff ff       	call   80107909 <outb>
8010794c:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
8010794f:	6a 0c                	push   $0xc
80107951:	68 f8 03 00 00       	push   $0x3f8
80107956:	e8 ae ff ff ff       	call   80107909 <outb>
8010795b:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
8010795e:	6a 00                	push   $0x0
80107960:	68 f9 03 00 00       	push   $0x3f9
80107965:	e8 9f ff ff ff       	call   80107909 <outb>
8010796a:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
8010796d:	6a 03                	push   $0x3
8010796f:	68 fb 03 00 00       	push   $0x3fb
80107974:	e8 90 ff ff ff       	call   80107909 <outb>
80107979:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
8010797c:	6a 00                	push   $0x0
8010797e:	68 fc 03 00 00       	push   $0x3fc
80107983:	e8 81 ff ff ff       	call   80107909 <outb>
80107988:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
8010798b:	6a 01                	push   $0x1
8010798d:	68 f9 03 00 00       	push   $0x3f9
80107992:	e8 72 ff ff ff       	call   80107909 <outb>
80107997:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
8010799a:	68 fd 03 00 00       	push   $0x3fd
8010799f:	e8 48 ff ff ff       	call   801078ec <inb>
801079a4:	83 c4 04             	add    $0x4,%esp
801079a7:	3c ff                	cmp    $0xff,%al
801079a9:	74 6e                	je     80107a19 <uartinit+0xf1>
    return;
  uart = 1;
801079ab:	c7 05 4c c6 10 80 01 	movl   $0x1,0x8010c64c
801079b2:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
801079b5:	68 fa 03 00 00       	push   $0x3fa
801079ba:	e8 2d ff ff ff       	call   801078ec <inb>
801079bf:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
801079c2:	68 f8 03 00 00       	push   $0x3f8
801079c7:	e8 20 ff ff ff       	call   801078ec <inb>
801079cc:	83 c4 04             	add    $0x4,%esp
  picenable(IRQ_COM1);
801079cf:	83 ec 0c             	sub    $0xc,%esp
801079d2:	6a 04                	push   $0x4
801079d4:	e8 71 d0 ff ff       	call   80104a4a <picenable>
801079d9:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_COM1, 0);
801079dc:	83 ec 08             	sub    $0x8,%esp
801079df:	6a 00                	push   $0x0
801079e1:	6a 04                	push   $0x4
801079e3:	e8 fe b8 ff ff       	call   801032e6 <ioapicenable>
801079e8:	83 c4 10             	add    $0x10,%esp
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
801079eb:	c7 45 f4 80 9a 10 80 	movl   $0x80109a80,-0xc(%ebp)
801079f2:	eb 19                	jmp    80107a0d <uartinit+0xe5>
    uartputc(*p);
801079f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079f7:	0f b6 00             	movzbl (%eax),%eax
801079fa:	0f be c0             	movsbl %al,%eax
801079fd:	83 ec 0c             	sub    $0xc,%esp
80107a00:	50                   	push   %eax
80107a01:	e8 16 00 00 00       	call   80107a1c <uartputc>
80107a06:	83 c4 10             	add    $0x10,%esp
  inb(COM1+0);
  picenable(IRQ_COM1);
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80107a09:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107a0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a10:	0f b6 00             	movzbl (%eax),%eax
80107a13:	84 c0                	test   %al,%al
80107a15:	75 dd                	jne    801079f4 <uartinit+0xcc>
80107a17:	eb 01                	jmp    80107a1a <uartinit+0xf2>
  outb(COM1+4, 0);
  outb(COM1+1, 0x01);    // Enable receive interrupts.

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
    return;
80107a19:	90                   	nop
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
    uartputc(*p);
}
80107a1a:	c9                   	leave  
80107a1b:	c3                   	ret    

80107a1c <uartputc>:

void
uartputc(int c)
{
80107a1c:	55                   	push   %ebp
80107a1d:	89 e5                	mov    %esp,%ebp
80107a1f:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
80107a22:	a1 4c c6 10 80       	mov    0x8010c64c,%eax
80107a27:	85 c0                	test   %eax,%eax
80107a29:	74 53                	je     80107a7e <uartputc+0x62>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80107a2b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107a32:	eb 11                	jmp    80107a45 <uartputc+0x29>
    microdelay(10);
80107a34:	83 ec 0c             	sub    $0xc,%esp
80107a37:	6a 0a                	push   $0xa
80107a39:	e8 0e be ff ff       	call   8010384c <microdelay>
80107a3e:	83 c4 10             	add    $0x10,%esp
{
  int i;

  if(!uart)
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80107a41:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107a45:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80107a49:	7f 1a                	jg     80107a65 <uartputc+0x49>
80107a4b:	83 ec 0c             	sub    $0xc,%esp
80107a4e:	68 fd 03 00 00       	push   $0x3fd
80107a53:	e8 94 fe ff ff       	call   801078ec <inb>
80107a58:	83 c4 10             	add    $0x10,%esp
80107a5b:	0f b6 c0             	movzbl %al,%eax
80107a5e:	83 e0 20             	and    $0x20,%eax
80107a61:	85 c0                	test   %eax,%eax
80107a63:	74 cf                	je     80107a34 <uartputc+0x18>
    microdelay(10);
  outb(COM1+0, c);
80107a65:	8b 45 08             	mov    0x8(%ebp),%eax
80107a68:	0f b6 c0             	movzbl %al,%eax
80107a6b:	83 ec 08             	sub    $0x8,%esp
80107a6e:	50                   	push   %eax
80107a6f:	68 f8 03 00 00       	push   $0x3f8
80107a74:	e8 90 fe ff ff       	call   80107909 <outb>
80107a79:	83 c4 10             	add    $0x10,%esp
80107a7c:	eb 01                	jmp    80107a7f <uartputc+0x63>
uartputc(int c)
{
  int i;

  if(!uart)
    return;
80107a7e:	90                   	nop
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
    microdelay(10);
  outb(COM1+0, c);
}
80107a7f:	c9                   	leave  
80107a80:	c3                   	ret    

80107a81 <uartgetc>:

static int
uartgetc(void)
{
80107a81:	55                   	push   %ebp
80107a82:	89 e5                	mov    %esp,%ebp
  if(!uart)
80107a84:	a1 4c c6 10 80       	mov    0x8010c64c,%eax
80107a89:	85 c0                	test   %eax,%eax
80107a8b:	75 07                	jne    80107a94 <uartgetc+0x13>
    return -1;
80107a8d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107a92:	eb 2e                	jmp    80107ac2 <uartgetc+0x41>
  if(!(inb(COM1+5) & 0x01))
80107a94:	68 fd 03 00 00       	push   $0x3fd
80107a99:	e8 4e fe ff ff       	call   801078ec <inb>
80107a9e:	83 c4 04             	add    $0x4,%esp
80107aa1:	0f b6 c0             	movzbl %al,%eax
80107aa4:	83 e0 01             	and    $0x1,%eax
80107aa7:	85 c0                	test   %eax,%eax
80107aa9:	75 07                	jne    80107ab2 <uartgetc+0x31>
    return -1;
80107aab:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107ab0:	eb 10                	jmp    80107ac2 <uartgetc+0x41>
  return inb(COM1+0);
80107ab2:	68 f8 03 00 00       	push   $0x3f8
80107ab7:	e8 30 fe ff ff       	call   801078ec <inb>
80107abc:	83 c4 04             	add    $0x4,%esp
80107abf:	0f b6 c0             	movzbl %al,%eax
}
80107ac2:	c9                   	leave  
80107ac3:	c3                   	ret    

80107ac4 <uartintr>:

void
uartintr(void)
{
80107ac4:	55                   	push   %ebp
80107ac5:	89 e5                	mov    %esp,%ebp
80107ac7:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
80107aca:	83 ec 0c             	sub    $0xc,%esp
80107acd:	68 81 7a 10 80       	push   $0x80107a81
80107ad2:	e8 22 8d ff ff       	call   801007f9 <consoleintr>
80107ad7:	83 c4 10             	add    $0x10,%esp
}
80107ada:	90                   	nop
80107adb:	c9                   	leave  
80107adc:	c3                   	ret    

80107add <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80107add:	6a 00                	push   $0x0
  pushl $0
80107adf:	6a 00                	push   $0x0
  jmp alltraps
80107ae1:	e9 a6 f9 ff ff       	jmp    8010748c <alltraps>

80107ae6 <vector1>:
.globl vector1
vector1:
  pushl $0
80107ae6:	6a 00                	push   $0x0
  pushl $1
80107ae8:	6a 01                	push   $0x1
  jmp alltraps
80107aea:	e9 9d f9 ff ff       	jmp    8010748c <alltraps>

80107aef <vector2>:
.globl vector2
vector2:
  pushl $0
80107aef:	6a 00                	push   $0x0
  pushl $2
80107af1:	6a 02                	push   $0x2
  jmp alltraps
80107af3:	e9 94 f9 ff ff       	jmp    8010748c <alltraps>

80107af8 <vector3>:
.globl vector3
vector3:
  pushl $0
80107af8:	6a 00                	push   $0x0
  pushl $3
80107afa:	6a 03                	push   $0x3
  jmp alltraps
80107afc:	e9 8b f9 ff ff       	jmp    8010748c <alltraps>

80107b01 <vector4>:
.globl vector4
vector4:
  pushl $0
80107b01:	6a 00                	push   $0x0
  pushl $4
80107b03:	6a 04                	push   $0x4
  jmp alltraps
80107b05:	e9 82 f9 ff ff       	jmp    8010748c <alltraps>

80107b0a <vector5>:
.globl vector5
vector5:
  pushl $0
80107b0a:	6a 00                	push   $0x0
  pushl $5
80107b0c:	6a 05                	push   $0x5
  jmp alltraps
80107b0e:	e9 79 f9 ff ff       	jmp    8010748c <alltraps>

80107b13 <vector6>:
.globl vector6
vector6:
  pushl $0
80107b13:	6a 00                	push   $0x0
  pushl $6
80107b15:	6a 06                	push   $0x6
  jmp alltraps
80107b17:	e9 70 f9 ff ff       	jmp    8010748c <alltraps>

80107b1c <vector7>:
.globl vector7
vector7:
  pushl $0
80107b1c:	6a 00                	push   $0x0
  pushl $7
80107b1e:	6a 07                	push   $0x7
  jmp alltraps
80107b20:	e9 67 f9 ff ff       	jmp    8010748c <alltraps>

80107b25 <vector8>:
.globl vector8
vector8:
  pushl $8
80107b25:	6a 08                	push   $0x8
  jmp alltraps
80107b27:	e9 60 f9 ff ff       	jmp    8010748c <alltraps>

80107b2c <vector9>:
.globl vector9
vector9:
  pushl $0
80107b2c:	6a 00                	push   $0x0
  pushl $9
80107b2e:	6a 09                	push   $0x9
  jmp alltraps
80107b30:	e9 57 f9 ff ff       	jmp    8010748c <alltraps>

80107b35 <vector10>:
.globl vector10
vector10:
  pushl $10
80107b35:	6a 0a                	push   $0xa
  jmp alltraps
80107b37:	e9 50 f9 ff ff       	jmp    8010748c <alltraps>

80107b3c <vector11>:
.globl vector11
vector11:
  pushl $11
80107b3c:	6a 0b                	push   $0xb
  jmp alltraps
80107b3e:	e9 49 f9 ff ff       	jmp    8010748c <alltraps>

80107b43 <vector12>:
.globl vector12
vector12:
  pushl $12
80107b43:	6a 0c                	push   $0xc
  jmp alltraps
80107b45:	e9 42 f9 ff ff       	jmp    8010748c <alltraps>

80107b4a <vector13>:
.globl vector13
vector13:
  pushl $13
80107b4a:	6a 0d                	push   $0xd
  jmp alltraps
80107b4c:	e9 3b f9 ff ff       	jmp    8010748c <alltraps>

80107b51 <vector14>:
.globl vector14
vector14:
  pushl $14
80107b51:	6a 0e                	push   $0xe
  jmp alltraps
80107b53:	e9 34 f9 ff ff       	jmp    8010748c <alltraps>

80107b58 <vector15>:
.globl vector15
vector15:
  pushl $0
80107b58:	6a 00                	push   $0x0
  pushl $15
80107b5a:	6a 0f                	push   $0xf
  jmp alltraps
80107b5c:	e9 2b f9 ff ff       	jmp    8010748c <alltraps>

80107b61 <vector16>:
.globl vector16
vector16:
  pushl $0
80107b61:	6a 00                	push   $0x0
  pushl $16
80107b63:	6a 10                	push   $0x10
  jmp alltraps
80107b65:	e9 22 f9 ff ff       	jmp    8010748c <alltraps>

80107b6a <vector17>:
.globl vector17
vector17:
  pushl $17
80107b6a:	6a 11                	push   $0x11
  jmp alltraps
80107b6c:	e9 1b f9 ff ff       	jmp    8010748c <alltraps>

80107b71 <vector18>:
.globl vector18
vector18:
  pushl $0
80107b71:	6a 00                	push   $0x0
  pushl $18
80107b73:	6a 12                	push   $0x12
  jmp alltraps
80107b75:	e9 12 f9 ff ff       	jmp    8010748c <alltraps>

80107b7a <vector19>:
.globl vector19
vector19:
  pushl $0
80107b7a:	6a 00                	push   $0x0
  pushl $19
80107b7c:	6a 13                	push   $0x13
  jmp alltraps
80107b7e:	e9 09 f9 ff ff       	jmp    8010748c <alltraps>

80107b83 <vector20>:
.globl vector20
vector20:
  pushl $0
80107b83:	6a 00                	push   $0x0
  pushl $20
80107b85:	6a 14                	push   $0x14
  jmp alltraps
80107b87:	e9 00 f9 ff ff       	jmp    8010748c <alltraps>

80107b8c <vector21>:
.globl vector21
vector21:
  pushl $0
80107b8c:	6a 00                	push   $0x0
  pushl $21
80107b8e:	6a 15                	push   $0x15
  jmp alltraps
80107b90:	e9 f7 f8 ff ff       	jmp    8010748c <alltraps>

80107b95 <vector22>:
.globl vector22
vector22:
  pushl $0
80107b95:	6a 00                	push   $0x0
  pushl $22
80107b97:	6a 16                	push   $0x16
  jmp alltraps
80107b99:	e9 ee f8 ff ff       	jmp    8010748c <alltraps>

80107b9e <vector23>:
.globl vector23
vector23:
  pushl $0
80107b9e:	6a 00                	push   $0x0
  pushl $23
80107ba0:	6a 17                	push   $0x17
  jmp alltraps
80107ba2:	e9 e5 f8 ff ff       	jmp    8010748c <alltraps>

80107ba7 <vector24>:
.globl vector24
vector24:
  pushl $0
80107ba7:	6a 00                	push   $0x0
  pushl $24
80107ba9:	6a 18                	push   $0x18
  jmp alltraps
80107bab:	e9 dc f8 ff ff       	jmp    8010748c <alltraps>

80107bb0 <vector25>:
.globl vector25
vector25:
  pushl $0
80107bb0:	6a 00                	push   $0x0
  pushl $25
80107bb2:	6a 19                	push   $0x19
  jmp alltraps
80107bb4:	e9 d3 f8 ff ff       	jmp    8010748c <alltraps>

80107bb9 <vector26>:
.globl vector26
vector26:
  pushl $0
80107bb9:	6a 00                	push   $0x0
  pushl $26
80107bbb:	6a 1a                	push   $0x1a
  jmp alltraps
80107bbd:	e9 ca f8 ff ff       	jmp    8010748c <alltraps>

80107bc2 <vector27>:
.globl vector27
vector27:
  pushl $0
80107bc2:	6a 00                	push   $0x0
  pushl $27
80107bc4:	6a 1b                	push   $0x1b
  jmp alltraps
80107bc6:	e9 c1 f8 ff ff       	jmp    8010748c <alltraps>

80107bcb <vector28>:
.globl vector28
vector28:
  pushl $0
80107bcb:	6a 00                	push   $0x0
  pushl $28
80107bcd:	6a 1c                	push   $0x1c
  jmp alltraps
80107bcf:	e9 b8 f8 ff ff       	jmp    8010748c <alltraps>

80107bd4 <vector29>:
.globl vector29
vector29:
  pushl $0
80107bd4:	6a 00                	push   $0x0
  pushl $29
80107bd6:	6a 1d                	push   $0x1d
  jmp alltraps
80107bd8:	e9 af f8 ff ff       	jmp    8010748c <alltraps>

80107bdd <vector30>:
.globl vector30
vector30:
  pushl $0
80107bdd:	6a 00                	push   $0x0
  pushl $30
80107bdf:	6a 1e                	push   $0x1e
  jmp alltraps
80107be1:	e9 a6 f8 ff ff       	jmp    8010748c <alltraps>

80107be6 <vector31>:
.globl vector31
vector31:
  pushl $0
80107be6:	6a 00                	push   $0x0
  pushl $31
80107be8:	6a 1f                	push   $0x1f
  jmp alltraps
80107bea:	e9 9d f8 ff ff       	jmp    8010748c <alltraps>

80107bef <vector32>:
.globl vector32
vector32:
  pushl $0
80107bef:	6a 00                	push   $0x0
  pushl $32
80107bf1:	6a 20                	push   $0x20
  jmp alltraps
80107bf3:	e9 94 f8 ff ff       	jmp    8010748c <alltraps>

80107bf8 <vector33>:
.globl vector33
vector33:
  pushl $0
80107bf8:	6a 00                	push   $0x0
  pushl $33
80107bfa:	6a 21                	push   $0x21
  jmp alltraps
80107bfc:	e9 8b f8 ff ff       	jmp    8010748c <alltraps>

80107c01 <vector34>:
.globl vector34
vector34:
  pushl $0
80107c01:	6a 00                	push   $0x0
  pushl $34
80107c03:	6a 22                	push   $0x22
  jmp alltraps
80107c05:	e9 82 f8 ff ff       	jmp    8010748c <alltraps>

80107c0a <vector35>:
.globl vector35
vector35:
  pushl $0
80107c0a:	6a 00                	push   $0x0
  pushl $35
80107c0c:	6a 23                	push   $0x23
  jmp alltraps
80107c0e:	e9 79 f8 ff ff       	jmp    8010748c <alltraps>

80107c13 <vector36>:
.globl vector36
vector36:
  pushl $0
80107c13:	6a 00                	push   $0x0
  pushl $36
80107c15:	6a 24                	push   $0x24
  jmp alltraps
80107c17:	e9 70 f8 ff ff       	jmp    8010748c <alltraps>

80107c1c <vector37>:
.globl vector37
vector37:
  pushl $0
80107c1c:	6a 00                	push   $0x0
  pushl $37
80107c1e:	6a 25                	push   $0x25
  jmp alltraps
80107c20:	e9 67 f8 ff ff       	jmp    8010748c <alltraps>

80107c25 <vector38>:
.globl vector38
vector38:
  pushl $0
80107c25:	6a 00                	push   $0x0
  pushl $38
80107c27:	6a 26                	push   $0x26
  jmp alltraps
80107c29:	e9 5e f8 ff ff       	jmp    8010748c <alltraps>

80107c2e <vector39>:
.globl vector39
vector39:
  pushl $0
80107c2e:	6a 00                	push   $0x0
  pushl $39
80107c30:	6a 27                	push   $0x27
  jmp alltraps
80107c32:	e9 55 f8 ff ff       	jmp    8010748c <alltraps>

80107c37 <vector40>:
.globl vector40
vector40:
  pushl $0
80107c37:	6a 00                	push   $0x0
  pushl $40
80107c39:	6a 28                	push   $0x28
  jmp alltraps
80107c3b:	e9 4c f8 ff ff       	jmp    8010748c <alltraps>

80107c40 <vector41>:
.globl vector41
vector41:
  pushl $0
80107c40:	6a 00                	push   $0x0
  pushl $41
80107c42:	6a 29                	push   $0x29
  jmp alltraps
80107c44:	e9 43 f8 ff ff       	jmp    8010748c <alltraps>

80107c49 <vector42>:
.globl vector42
vector42:
  pushl $0
80107c49:	6a 00                	push   $0x0
  pushl $42
80107c4b:	6a 2a                	push   $0x2a
  jmp alltraps
80107c4d:	e9 3a f8 ff ff       	jmp    8010748c <alltraps>

80107c52 <vector43>:
.globl vector43
vector43:
  pushl $0
80107c52:	6a 00                	push   $0x0
  pushl $43
80107c54:	6a 2b                	push   $0x2b
  jmp alltraps
80107c56:	e9 31 f8 ff ff       	jmp    8010748c <alltraps>

80107c5b <vector44>:
.globl vector44
vector44:
  pushl $0
80107c5b:	6a 00                	push   $0x0
  pushl $44
80107c5d:	6a 2c                	push   $0x2c
  jmp alltraps
80107c5f:	e9 28 f8 ff ff       	jmp    8010748c <alltraps>

80107c64 <vector45>:
.globl vector45
vector45:
  pushl $0
80107c64:	6a 00                	push   $0x0
  pushl $45
80107c66:	6a 2d                	push   $0x2d
  jmp alltraps
80107c68:	e9 1f f8 ff ff       	jmp    8010748c <alltraps>

80107c6d <vector46>:
.globl vector46
vector46:
  pushl $0
80107c6d:	6a 00                	push   $0x0
  pushl $46
80107c6f:	6a 2e                	push   $0x2e
  jmp alltraps
80107c71:	e9 16 f8 ff ff       	jmp    8010748c <alltraps>

80107c76 <vector47>:
.globl vector47
vector47:
  pushl $0
80107c76:	6a 00                	push   $0x0
  pushl $47
80107c78:	6a 2f                	push   $0x2f
  jmp alltraps
80107c7a:	e9 0d f8 ff ff       	jmp    8010748c <alltraps>

80107c7f <vector48>:
.globl vector48
vector48:
  pushl $0
80107c7f:	6a 00                	push   $0x0
  pushl $48
80107c81:	6a 30                	push   $0x30
  jmp alltraps
80107c83:	e9 04 f8 ff ff       	jmp    8010748c <alltraps>

80107c88 <vector49>:
.globl vector49
vector49:
  pushl $0
80107c88:	6a 00                	push   $0x0
  pushl $49
80107c8a:	6a 31                	push   $0x31
  jmp alltraps
80107c8c:	e9 fb f7 ff ff       	jmp    8010748c <alltraps>

80107c91 <vector50>:
.globl vector50
vector50:
  pushl $0
80107c91:	6a 00                	push   $0x0
  pushl $50
80107c93:	6a 32                	push   $0x32
  jmp alltraps
80107c95:	e9 f2 f7 ff ff       	jmp    8010748c <alltraps>

80107c9a <vector51>:
.globl vector51
vector51:
  pushl $0
80107c9a:	6a 00                	push   $0x0
  pushl $51
80107c9c:	6a 33                	push   $0x33
  jmp alltraps
80107c9e:	e9 e9 f7 ff ff       	jmp    8010748c <alltraps>

80107ca3 <vector52>:
.globl vector52
vector52:
  pushl $0
80107ca3:	6a 00                	push   $0x0
  pushl $52
80107ca5:	6a 34                	push   $0x34
  jmp alltraps
80107ca7:	e9 e0 f7 ff ff       	jmp    8010748c <alltraps>

80107cac <vector53>:
.globl vector53
vector53:
  pushl $0
80107cac:	6a 00                	push   $0x0
  pushl $53
80107cae:	6a 35                	push   $0x35
  jmp alltraps
80107cb0:	e9 d7 f7 ff ff       	jmp    8010748c <alltraps>

80107cb5 <vector54>:
.globl vector54
vector54:
  pushl $0
80107cb5:	6a 00                	push   $0x0
  pushl $54
80107cb7:	6a 36                	push   $0x36
  jmp alltraps
80107cb9:	e9 ce f7 ff ff       	jmp    8010748c <alltraps>

80107cbe <vector55>:
.globl vector55
vector55:
  pushl $0
80107cbe:	6a 00                	push   $0x0
  pushl $55
80107cc0:	6a 37                	push   $0x37
  jmp alltraps
80107cc2:	e9 c5 f7 ff ff       	jmp    8010748c <alltraps>

80107cc7 <vector56>:
.globl vector56
vector56:
  pushl $0
80107cc7:	6a 00                	push   $0x0
  pushl $56
80107cc9:	6a 38                	push   $0x38
  jmp alltraps
80107ccb:	e9 bc f7 ff ff       	jmp    8010748c <alltraps>

80107cd0 <vector57>:
.globl vector57
vector57:
  pushl $0
80107cd0:	6a 00                	push   $0x0
  pushl $57
80107cd2:	6a 39                	push   $0x39
  jmp alltraps
80107cd4:	e9 b3 f7 ff ff       	jmp    8010748c <alltraps>

80107cd9 <vector58>:
.globl vector58
vector58:
  pushl $0
80107cd9:	6a 00                	push   $0x0
  pushl $58
80107cdb:	6a 3a                	push   $0x3a
  jmp alltraps
80107cdd:	e9 aa f7 ff ff       	jmp    8010748c <alltraps>

80107ce2 <vector59>:
.globl vector59
vector59:
  pushl $0
80107ce2:	6a 00                	push   $0x0
  pushl $59
80107ce4:	6a 3b                	push   $0x3b
  jmp alltraps
80107ce6:	e9 a1 f7 ff ff       	jmp    8010748c <alltraps>

80107ceb <vector60>:
.globl vector60
vector60:
  pushl $0
80107ceb:	6a 00                	push   $0x0
  pushl $60
80107ced:	6a 3c                	push   $0x3c
  jmp alltraps
80107cef:	e9 98 f7 ff ff       	jmp    8010748c <alltraps>

80107cf4 <vector61>:
.globl vector61
vector61:
  pushl $0
80107cf4:	6a 00                	push   $0x0
  pushl $61
80107cf6:	6a 3d                	push   $0x3d
  jmp alltraps
80107cf8:	e9 8f f7 ff ff       	jmp    8010748c <alltraps>

80107cfd <vector62>:
.globl vector62
vector62:
  pushl $0
80107cfd:	6a 00                	push   $0x0
  pushl $62
80107cff:	6a 3e                	push   $0x3e
  jmp alltraps
80107d01:	e9 86 f7 ff ff       	jmp    8010748c <alltraps>

80107d06 <vector63>:
.globl vector63
vector63:
  pushl $0
80107d06:	6a 00                	push   $0x0
  pushl $63
80107d08:	6a 3f                	push   $0x3f
  jmp alltraps
80107d0a:	e9 7d f7 ff ff       	jmp    8010748c <alltraps>

80107d0f <vector64>:
.globl vector64
vector64:
  pushl $0
80107d0f:	6a 00                	push   $0x0
  pushl $64
80107d11:	6a 40                	push   $0x40
  jmp alltraps
80107d13:	e9 74 f7 ff ff       	jmp    8010748c <alltraps>

80107d18 <vector65>:
.globl vector65
vector65:
  pushl $0
80107d18:	6a 00                	push   $0x0
  pushl $65
80107d1a:	6a 41                	push   $0x41
  jmp alltraps
80107d1c:	e9 6b f7 ff ff       	jmp    8010748c <alltraps>

80107d21 <vector66>:
.globl vector66
vector66:
  pushl $0
80107d21:	6a 00                	push   $0x0
  pushl $66
80107d23:	6a 42                	push   $0x42
  jmp alltraps
80107d25:	e9 62 f7 ff ff       	jmp    8010748c <alltraps>

80107d2a <vector67>:
.globl vector67
vector67:
  pushl $0
80107d2a:	6a 00                	push   $0x0
  pushl $67
80107d2c:	6a 43                	push   $0x43
  jmp alltraps
80107d2e:	e9 59 f7 ff ff       	jmp    8010748c <alltraps>

80107d33 <vector68>:
.globl vector68
vector68:
  pushl $0
80107d33:	6a 00                	push   $0x0
  pushl $68
80107d35:	6a 44                	push   $0x44
  jmp alltraps
80107d37:	e9 50 f7 ff ff       	jmp    8010748c <alltraps>

80107d3c <vector69>:
.globl vector69
vector69:
  pushl $0
80107d3c:	6a 00                	push   $0x0
  pushl $69
80107d3e:	6a 45                	push   $0x45
  jmp alltraps
80107d40:	e9 47 f7 ff ff       	jmp    8010748c <alltraps>

80107d45 <vector70>:
.globl vector70
vector70:
  pushl $0
80107d45:	6a 00                	push   $0x0
  pushl $70
80107d47:	6a 46                	push   $0x46
  jmp alltraps
80107d49:	e9 3e f7 ff ff       	jmp    8010748c <alltraps>

80107d4e <vector71>:
.globl vector71
vector71:
  pushl $0
80107d4e:	6a 00                	push   $0x0
  pushl $71
80107d50:	6a 47                	push   $0x47
  jmp alltraps
80107d52:	e9 35 f7 ff ff       	jmp    8010748c <alltraps>

80107d57 <vector72>:
.globl vector72
vector72:
  pushl $0
80107d57:	6a 00                	push   $0x0
  pushl $72
80107d59:	6a 48                	push   $0x48
  jmp alltraps
80107d5b:	e9 2c f7 ff ff       	jmp    8010748c <alltraps>

80107d60 <vector73>:
.globl vector73
vector73:
  pushl $0
80107d60:	6a 00                	push   $0x0
  pushl $73
80107d62:	6a 49                	push   $0x49
  jmp alltraps
80107d64:	e9 23 f7 ff ff       	jmp    8010748c <alltraps>

80107d69 <vector74>:
.globl vector74
vector74:
  pushl $0
80107d69:	6a 00                	push   $0x0
  pushl $74
80107d6b:	6a 4a                	push   $0x4a
  jmp alltraps
80107d6d:	e9 1a f7 ff ff       	jmp    8010748c <alltraps>

80107d72 <vector75>:
.globl vector75
vector75:
  pushl $0
80107d72:	6a 00                	push   $0x0
  pushl $75
80107d74:	6a 4b                	push   $0x4b
  jmp alltraps
80107d76:	e9 11 f7 ff ff       	jmp    8010748c <alltraps>

80107d7b <vector76>:
.globl vector76
vector76:
  pushl $0
80107d7b:	6a 00                	push   $0x0
  pushl $76
80107d7d:	6a 4c                	push   $0x4c
  jmp alltraps
80107d7f:	e9 08 f7 ff ff       	jmp    8010748c <alltraps>

80107d84 <vector77>:
.globl vector77
vector77:
  pushl $0
80107d84:	6a 00                	push   $0x0
  pushl $77
80107d86:	6a 4d                	push   $0x4d
  jmp alltraps
80107d88:	e9 ff f6 ff ff       	jmp    8010748c <alltraps>

80107d8d <vector78>:
.globl vector78
vector78:
  pushl $0
80107d8d:	6a 00                	push   $0x0
  pushl $78
80107d8f:	6a 4e                	push   $0x4e
  jmp alltraps
80107d91:	e9 f6 f6 ff ff       	jmp    8010748c <alltraps>

80107d96 <vector79>:
.globl vector79
vector79:
  pushl $0
80107d96:	6a 00                	push   $0x0
  pushl $79
80107d98:	6a 4f                	push   $0x4f
  jmp alltraps
80107d9a:	e9 ed f6 ff ff       	jmp    8010748c <alltraps>

80107d9f <vector80>:
.globl vector80
vector80:
  pushl $0
80107d9f:	6a 00                	push   $0x0
  pushl $80
80107da1:	6a 50                	push   $0x50
  jmp alltraps
80107da3:	e9 e4 f6 ff ff       	jmp    8010748c <alltraps>

80107da8 <vector81>:
.globl vector81
vector81:
  pushl $0
80107da8:	6a 00                	push   $0x0
  pushl $81
80107daa:	6a 51                	push   $0x51
  jmp alltraps
80107dac:	e9 db f6 ff ff       	jmp    8010748c <alltraps>

80107db1 <vector82>:
.globl vector82
vector82:
  pushl $0
80107db1:	6a 00                	push   $0x0
  pushl $82
80107db3:	6a 52                	push   $0x52
  jmp alltraps
80107db5:	e9 d2 f6 ff ff       	jmp    8010748c <alltraps>

80107dba <vector83>:
.globl vector83
vector83:
  pushl $0
80107dba:	6a 00                	push   $0x0
  pushl $83
80107dbc:	6a 53                	push   $0x53
  jmp alltraps
80107dbe:	e9 c9 f6 ff ff       	jmp    8010748c <alltraps>

80107dc3 <vector84>:
.globl vector84
vector84:
  pushl $0
80107dc3:	6a 00                	push   $0x0
  pushl $84
80107dc5:	6a 54                	push   $0x54
  jmp alltraps
80107dc7:	e9 c0 f6 ff ff       	jmp    8010748c <alltraps>

80107dcc <vector85>:
.globl vector85
vector85:
  pushl $0
80107dcc:	6a 00                	push   $0x0
  pushl $85
80107dce:	6a 55                	push   $0x55
  jmp alltraps
80107dd0:	e9 b7 f6 ff ff       	jmp    8010748c <alltraps>

80107dd5 <vector86>:
.globl vector86
vector86:
  pushl $0
80107dd5:	6a 00                	push   $0x0
  pushl $86
80107dd7:	6a 56                	push   $0x56
  jmp alltraps
80107dd9:	e9 ae f6 ff ff       	jmp    8010748c <alltraps>

80107dde <vector87>:
.globl vector87
vector87:
  pushl $0
80107dde:	6a 00                	push   $0x0
  pushl $87
80107de0:	6a 57                	push   $0x57
  jmp alltraps
80107de2:	e9 a5 f6 ff ff       	jmp    8010748c <alltraps>

80107de7 <vector88>:
.globl vector88
vector88:
  pushl $0
80107de7:	6a 00                	push   $0x0
  pushl $88
80107de9:	6a 58                	push   $0x58
  jmp alltraps
80107deb:	e9 9c f6 ff ff       	jmp    8010748c <alltraps>

80107df0 <vector89>:
.globl vector89
vector89:
  pushl $0
80107df0:	6a 00                	push   $0x0
  pushl $89
80107df2:	6a 59                	push   $0x59
  jmp alltraps
80107df4:	e9 93 f6 ff ff       	jmp    8010748c <alltraps>

80107df9 <vector90>:
.globl vector90
vector90:
  pushl $0
80107df9:	6a 00                	push   $0x0
  pushl $90
80107dfb:	6a 5a                	push   $0x5a
  jmp alltraps
80107dfd:	e9 8a f6 ff ff       	jmp    8010748c <alltraps>

80107e02 <vector91>:
.globl vector91
vector91:
  pushl $0
80107e02:	6a 00                	push   $0x0
  pushl $91
80107e04:	6a 5b                	push   $0x5b
  jmp alltraps
80107e06:	e9 81 f6 ff ff       	jmp    8010748c <alltraps>

80107e0b <vector92>:
.globl vector92
vector92:
  pushl $0
80107e0b:	6a 00                	push   $0x0
  pushl $92
80107e0d:	6a 5c                	push   $0x5c
  jmp alltraps
80107e0f:	e9 78 f6 ff ff       	jmp    8010748c <alltraps>

80107e14 <vector93>:
.globl vector93
vector93:
  pushl $0
80107e14:	6a 00                	push   $0x0
  pushl $93
80107e16:	6a 5d                	push   $0x5d
  jmp alltraps
80107e18:	e9 6f f6 ff ff       	jmp    8010748c <alltraps>

80107e1d <vector94>:
.globl vector94
vector94:
  pushl $0
80107e1d:	6a 00                	push   $0x0
  pushl $94
80107e1f:	6a 5e                	push   $0x5e
  jmp alltraps
80107e21:	e9 66 f6 ff ff       	jmp    8010748c <alltraps>

80107e26 <vector95>:
.globl vector95
vector95:
  pushl $0
80107e26:	6a 00                	push   $0x0
  pushl $95
80107e28:	6a 5f                	push   $0x5f
  jmp alltraps
80107e2a:	e9 5d f6 ff ff       	jmp    8010748c <alltraps>

80107e2f <vector96>:
.globl vector96
vector96:
  pushl $0
80107e2f:	6a 00                	push   $0x0
  pushl $96
80107e31:	6a 60                	push   $0x60
  jmp alltraps
80107e33:	e9 54 f6 ff ff       	jmp    8010748c <alltraps>

80107e38 <vector97>:
.globl vector97
vector97:
  pushl $0
80107e38:	6a 00                	push   $0x0
  pushl $97
80107e3a:	6a 61                	push   $0x61
  jmp alltraps
80107e3c:	e9 4b f6 ff ff       	jmp    8010748c <alltraps>

80107e41 <vector98>:
.globl vector98
vector98:
  pushl $0
80107e41:	6a 00                	push   $0x0
  pushl $98
80107e43:	6a 62                	push   $0x62
  jmp alltraps
80107e45:	e9 42 f6 ff ff       	jmp    8010748c <alltraps>

80107e4a <vector99>:
.globl vector99
vector99:
  pushl $0
80107e4a:	6a 00                	push   $0x0
  pushl $99
80107e4c:	6a 63                	push   $0x63
  jmp alltraps
80107e4e:	e9 39 f6 ff ff       	jmp    8010748c <alltraps>

80107e53 <vector100>:
.globl vector100
vector100:
  pushl $0
80107e53:	6a 00                	push   $0x0
  pushl $100
80107e55:	6a 64                	push   $0x64
  jmp alltraps
80107e57:	e9 30 f6 ff ff       	jmp    8010748c <alltraps>

80107e5c <vector101>:
.globl vector101
vector101:
  pushl $0
80107e5c:	6a 00                	push   $0x0
  pushl $101
80107e5e:	6a 65                	push   $0x65
  jmp alltraps
80107e60:	e9 27 f6 ff ff       	jmp    8010748c <alltraps>

80107e65 <vector102>:
.globl vector102
vector102:
  pushl $0
80107e65:	6a 00                	push   $0x0
  pushl $102
80107e67:	6a 66                	push   $0x66
  jmp alltraps
80107e69:	e9 1e f6 ff ff       	jmp    8010748c <alltraps>

80107e6e <vector103>:
.globl vector103
vector103:
  pushl $0
80107e6e:	6a 00                	push   $0x0
  pushl $103
80107e70:	6a 67                	push   $0x67
  jmp alltraps
80107e72:	e9 15 f6 ff ff       	jmp    8010748c <alltraps>

80107e77 <vector104>:
.globl vector104
vector104:
  pushl $0
80107e77:	6a 00                	push   $0x0
  pushl $104
80107e79:	6a 68                	push   $0x68
  jmp alltraps
80107e7b:	e9 0c f6 ff ff       	jmp    8010748c <alltraps>

80107e80 <vector105>:
.globl vector105
vector105:
  pushl $0
80107e80:	6a 00                	push   $0x0
  pushl $105
80107e82:	6a 69                	push   $0x69
  jmp alltraps
80107e84:	e9 03 f6 ff ff       	jmp    8010748c <alltraps>

80107e89 <vector106>:
.globl vector106
vector106:
  pushl $0
80107e89:	6a 00                	push   $0x0
  pushl $106
80107e8b:	6a 6a                	push   $0x6a
  jmp alltraps
80107e8d:	e9 fa f5 ff ff       	jmp    8010748c <alltraps>

80107e92 <vector107>:
.globl vector107
vector107:
  pushl $0
80107e92:	6a 00                	push   $0x0
  pushl $107
80107e94:	6a 6b                	push   $0x6b
  jmp alltraps
80107e96:	e9 f1 f5 ff ff       	jmp    8010748c <alltraps>

80107e9b <vector108>:
.globl vector108
vector108:
  pushl $0
80107e9b:	6a 00                	push   $0x0
  pushl $108
80107e9d:	6a 6c                	push   $0x6c
  jmp alltraps
80107e9f:	e9 e8 f5 ff ff       	jmp    8010748c <alltraps>

80107ea4 <vector109>:
.globl vector109
vector109:
  pushl $0
80107ea4:	6a 00                	push   $0x0
  pushl $109
80107ea6:	6a 6d                	push   $0x6d
  jmp alltraps
80107ea8:	e9 df f5 ff ff       	jmp    8010748c <alltraps>

80107ead <vector110>:
.globl vector110
vector110:
  pushl $0
80107ead:	6a 00                	push   $0x0
  pushl $110
80107eaf:	6a 6e                	push   $0x6e
  jmp alltraps
80107eb1:	e9 d6 f5 ff ff       	jmp    8010748c <alltraps>

80107eb6 <vector111>:
.globl vector111
vector111:
  pushl $0
80107eb6:	6a 00                	push   $0x0
  pushl $111
80107eb8:	6a 6f                	push   $0x6f
  jmp alltraps
80107eba:	e9 cd f5 ff ff       	jmp    8010748c <alltraps>

80107ebf <vector112>:
.globl vector112
vector112:
  pushl $0
80107ebf:	6a 00                	push   $0x0
  pushl $112
80107ec1:	6a 70                	push   $0x70
  jmp alltraps
80107ec3:	e9 c4 f5 ff ff       	jmp    8010748c <alltraps>

80107ec8 <vector113>:
.globl vector113
vector113:
  pushl $0
80107ec8:	6a 00                	push   $0x0
  pushl $113
80107eca:	6a 71                	push   $0x71
  jmp alltraps
80107ecc:	e9 bb f5 ff ff       	jmp    8010748c <alltraps>

80107ed1 <vector114>:
.globl vector114
vector114:
  pushl $0
80107ed1:	6a 00                	push   $0x0
  pushl $114
80107ed3:	6a 72                	push   $0x72
  jmp alltraps
80107ed5:	e9 b2 f5 ff ff       	jmp    8010748c <alltraps>

80107eda <vector115>:
.globl vector115
vector115:
  pushl $0
80107eda:	6a 00                	push   $0x0
  pushl $115
80107edc:	6a 73                	push   $0x73
  jmp alltraps
80107ede:	e9 a9 f5 ff ff       	jmp    8010748c <alltraps>

80107ee3 <vector116>:
.globl vector116
vector116:
  pushl $0
80107ee3:	6a 00                	push   $0x0
  pushl $116
80107ee5:	6a 74                	push   $0x74
  jmp alltraps
80107ee7:	e9 a0 f5 ff ff       	jmp    8010748c <alltraps>

80107eec <vector117>:
.globl vector117
vector117:
  pushl $0
80107eec:	6a 00                	push   $0x0
  pushl $117
80107eee:	6a 75                	push   $0x75
  jmp alltraps
80107ef0:	e9 97 f5 ff ff       	jmp    8010748c <alltraps>

80107ef5 <vector118>:
.globl vector118
vector118:
  pushl $0
80107ef5:	6a 00                	push   $0x0
  pushl $118
80107ef7:	6a 76                	push   $0x76
  jmp alltraps
80107ef9:	e9 8e f5 ff ff       	jmp    8010748c <alltraps>

80107efe <vector119>:
.globl vector119
vector119:
  pushl $0
80107efe:	6a 00                	push   $0x0
  pushl $119
80107f00:	6a 77                	push   $0x77
  jmp alltraps
80107f02:	e9 85 f5 ff ff       	jmp    8010748c <alltraps>

80107f07 <vector120>:
.globl vector120
vector120:
  pushl $0
80107f07:	6a 00                	push   $0x0
  pushl $120
80107f09:	6a 78                	push   $0x78
  jmp alltraps
80107f0b:	e9 7c f5 ff ff       	jmp    8010748c <alltraps>

80107f10 <vector121>:
.globl vector121
vector121:
  pushl $0
80107f10:	6a 00                	push   $0x0
  pushl $121
80107f12:	6a 79                	push   $0x79
  jmp alltraps
80107f14:	e9 73 f5 ff ff       	jmp    8010748c <alltraps>

80107f19 <vector122>:
.globl vector122
vector122:
  pushl $0
80107f19:	6a 00                	push   $0x0
  pushl $122
80107f1b:	6a 7a                	push   $0x7a
  jmp alltraps
80107f1d:	e9 6a f5 ff ff       	jmp    8010748c <alltraps>

80107f22 <vector123>:
.globl vector123
vector123:
  pushl $0
80107f22:	6a 00                	push   $0x0
  pushl $123
80107f24:	6a 7b                	push   $0x7b
  jmp alltraps
80107f26:	e9 61 f5 ff ff       	jmp    8010748c <alltraps>

80107f2b <vector124>:
.globl vector124
vector124:
  pushl $0
80107f2b:	6a 00                	push   $0x0
  pushl $124
80107f2d:	6a 7c                	push   $0x7c
  jmp alltraps
80107f2f:	e9 58 f5 ff ff       	jmp    8010748c <alltraps>

80107f34 <vector125>:
.globl vector125
vector125:
  pushl $0
80107f34:	6a 00                	push   $0x0
  pushl $125
80107f36:	6a 7d                	push   $0x7d
  jmp alltraps
80107f38:	e9 4f f5 ff ff       	jmp    8010748c <alltraps>

80107f3d <vector126>:
.globl vector126
vector126:
  pushl $0
80107f3d:	6a 00                	push   $0x0
  pushl $126
80107f3f:	6a 7e                	push   $0x7e
  jmp alltraps
80107f41:	e9 46 f5 ff ff       	jmp    8010748c <alltraps>

80107f46 <vector127>:
.globl vector127
vector127:
  pushl $0
80107f46:	6a 00                	push   $0x0
  pushl $127
80107f48:	6a 7f                	push   $0x7f
  jmp alltraps
80107f4a:	e9 3d f5 ff ff       	jmp    8010748c <alltraps>

80107f4f <vector128>:
.globl vector128
vector128:
  pushl $0
80107f4f:	6a 00                	push   $0x0
  pushl $128
80107f51:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80107f56:	e9 31 f5 ff ff       	jmp    8010748c <alltraps>

80107f5b <vector129>:
.globl vector129
vector129:
  pushl $0
80107f5b:	6a 00                	push   $0x0
  pushl $129
80107f5d:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80107f62:	e9 25 f5 ff ff       	jmp    8010748c <alltraps>

80107f67 <vector130>:
.globl vector130
vector130:
  pushl $0
80107f67:	6a 00                	push   $0x0
  pushl $130
80107f69:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80107f6e:	e9 19 f5 ff ff       	jmp    8010748c <alltraps>

80107f73 <vector131>:
.globl vector131
vector131:
  pushl $0
80107f73:	6a 00                	push   $0x0
  pushl $131
80107f75:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80107f7a:	e9 0d f5 ff ff       	jmp    8010748c <alltraps>

80107f7f <vector132>:
.globl vector132
vector132:
  pushl $0
80107f7f:	6a 00                	push   $0x0
  pushl $132
80107f81:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80107f86:	e9 01 f5 ff ff       	jmp    8010748c <alltraps>

80107f8b <vector133>:
.globl vector133
vector133:
  pushl $0
80107f8b:	6a 00                	push   $0x0
  pushl $133
80107f8d:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80107f92:	e9 f5 f4 ff ff       	jmp    8010748c <alltraps>

80107f97 <vector134>:
.globl vector134
vector134:
  pushl $0
80107f97:	6a 00                	push   $0x0
  pushl $134
80107f99:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80107f9e:	e9 e9 f4 ff ff       	jmp    8010748c <alltraps>

80107fa3 <vector135>:
.globl vector135
vector135:
  pushl $0
80107fa3:	6a 00                	push   $0x0
  pushl $135
80107fa5:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80107faa:	e9 dd f4 ff ff       	jmp    8010748c <alltraps>

80107faf <vector136>:
.globl vector136
vector136:
  pushl $0
80107faf:	6a 00                	push   $0x0
  pushl $136
80107fb1:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80107fb6:	e9 d1 f4 ff ff       	jmp    8010748c <alltraps>

80107fbb <vector137>:
.globl vector137
vector137:
  pushl $0
80107fbb:	6a 00                	push   $0x0
  pushl $137
80107fbd:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80107fc2:	e9 c5 f4 ff ff       	jmp    8010748c <alltraps>

80107fc7 <vector138>:
.globl vector138
vector138:
  pushl $0
80107fc7:	6a 00                	push   $0x0
  pushl $138
80107fc9:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80107fce:	e9 b9 f4 ff ff       	jmp    8010748c <alltraps>

80107fd3 <vector139>:
.globl vector139
vector139:
  pushl $0
80107fd3:	6a 00                	push   $0x0
  pushl $139
80107fd5:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80107fda:	e9 ad f4 ff ff       	jmp    8010748c <alltraps>

80107fdf <vector140>:
.globl vector140
vector140:
  pushl $0
80107fdf:	6a 00                	push   $0x0
  pushl $140
80107fe1:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80107fe6:	e9 a1 f4 ff ff       	jmp    8010748c <alltraps>

80107feb <vector141>:
.globl vector141
vector141:
  pushl $0
80107feb:	6a 00                	push   $0x0
  pushl $141
80107fed:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80107ff2:	e9 95 f4 ff ff       	jmp    8010748c <alltraps>

80107ff7 <vector142>:
.globl vector142
vector142:
  pushl $0
80107ff7:	6a 00                	push   $0x0
  pushl $142
80107ff9:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80107ffe:	e9 89 f4 ff ff       	jmp    8010748c <alltraps>

80108003 <vector143>:
.globl vector143
vector143:
  pushl $0
80108003:	6a 00                	push   $0x0
  pushl $143
80108005:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
8010800a:	e9 7d f4 ff ff       	jmp    8010748c <alltraps>

8010800f <vector144>:
.globl vector144
vector144:
  pushl $0
8010800f:	6a 00                	push   $0x0
  pushl $144
80108011:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80108016:	e9 71 f4 ff ff       	jmp    8010748c <alltraps>

8010801b <vector145>:
.globl vector145
vector145:
  pushl $0
8010801b:	6a 00                	push   $0x0
  pushl $145
8010801d:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80108022:	e9 65 f4 ff ff       	jmp    8010748c <alltraps>

80108027 <vector146>:
.globl vector146
vector146:
  pushl $0
80108027:	6a 00                	push   $0x0
  pushl $146
80108029:	68 92 00 00 00       	push   $0x92
  jmp alltraps
8010802e:	e9 59 f4 ff ff       	jmp    8010748c <alltraps>

80108033 <vector147>:
.globl vector147
vector147:
  pushl $0
80108033:	6a 00                	push   $0x0
  pushl $147
80108035:	68 93 00 00 00       	push   $0x93
  jmp alltraps
8010803a:	e9 4d f4 ff ff       	jmp    8010748c <alltraps>

8010803f <vector148>:
.globl vector148
vector148:
  pushl $0
8010803f:	6a 00                	push   $0x0
  pushl $148
80108041:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80108046:	e9 41 f4 ff ff       	jmp    8010748c <alltraps>

8010804b <vector149>:
.globl vector149
vector149:
  pushl $0
8010804b:	6a 00                	push   $0x0
  pushl $149
8010804d:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80108052:	e9 35 f4 ff ff       	jmp    8010748c <alltraps>

80108057 <vector150>:
.globl vector150
vector150:
  pushl $0
80108057:	6a 00                	push   $0x0
  pushl $150
80108059:	68 96 00 00 00       	push   $0x96
  jmp alltraps
8010805e:	e9 29 f4 ff ff       	jmp    8010748c <alltraps>

80108063 <vector151>:
.globl vector151
vector151:
  pushl $0
80108063:	6a 00                	push   $0x0
  pushl $151
80108065:	68 97 00 00 00       	push   $0x97
  jmp alltraps
8010806a:	e9 1d f4 ff ff       	jmp    8010748c <alltraps>

8010806f <vector152>:
.globl vector152
vector152:
  pushl $0
8010806f:	6a 00                	push   $0x0
  pushl $152
80108071:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80108076:	e9 11 f4 ff ff       	jmp    8010748c <alltraps>

8010807b <vector153>:
.globl vector153
vector153:
  pushl $0
8010807b:	6a 00                	push   $0x0
  pushl $153
8010807d:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80108082:	e9 05 f4 ff ff       	jmp    8010748c <alltraps>

80108087 <vector154>:
.globl vector154
vector154:
  pushl $0
80108087:	6a 00                	push   $0x0
  pushl $154
80108089:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
8010808e:	e9 f9 f3 ff ff       	jmp    8010748c <alltraps>

80108093 <vector155>:
.globl vector155
vector155:
  pushl $0
80108093:	6a 00                	push   $0x0
  pushl $155
80108095:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
8010809a:	e9 ed f3 ff ff       	jmp    8010748c <alltraps>

8010809f <vector156>:
.globl vector156
vector156:
  pushl $0
8010809f:	6a 00                	push   $0x0
  pushl $156
801080a1:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
801080a6:	e9 e1 f3 ff ff       	jmp    8010748c <alltraps>

801080ab <vector157>:
.globl vector157
vector157:
  pushl $0
801080ab:	6a 00                	push   $0x0
  pushl $157
801080ad:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
801080b2:	e9 d5 f3 ff ff       	jmp    8010748c <alltraps>

801080b7 <vector158>:
.globl vector158
vector158:
  pushl $0
801080b7:	6a 00                	push   $0x0
  pushl $158
801080b9:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
801080be:	e9 c9 f3 ff ff       	jmp    8010748c <alltraps>

801080c3 <vector159>:
.globl vector159
vector159:
  pushl $0
801080c3:	6a 00                	push   $0x0
  pushl $159
801080c5:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
801080ca:	e9 bd f3 ff ff       	jmp    8010748c <alltraps>

801080cf <vector160>:
.globl vector160
vector160:
  pushl $0
801080cf:	6a 00                	push   $0x0
  pushl $160
801080d1:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
801080d6:	e9 b1 f3 ff ff       	jmp    8010748c <alltraps>

801080db <vector161>:
.globl vector161
vector161:
  pushl $0
801080db:	6a 00                	push   $0x0
  pushl $161
801080dd:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
801080e2:	e9 a5 f3 ff ff       	jmp    8010748c <alltraps>

801080e7 <vector162>:
.globl vector162
vector162:
  pushl $0
801080e7:	6a 00                	push   $0x0
  pushl $162
801080e9:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
801080ee:	e9 99 f3 ff ff       	jmp    8010748c <alltraps>

801080f3 <vector163>:
.globl vector163
vector163:
  pushl $0
801080f3:	6a 00                	push   $0x0
  pushl $163
801080f5:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
801080fa:	e9 8d f3 ff ff       	jmp    8010748c <alltraps>

801080ff <vector164>:
.globl vector164
vector164:
  pushl $0
801080ff:	6a 00                	push   $0x0
  pushl $164
80108101:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80108106:	e9 81 f3 ff ff       	jmp    8010748c <alltraps>

8010810b <vector165>:
.globl vector165
vector165:
  pushl $0
8010810b:	6a 00                	push   $0x0
  pushl $165
8010810d:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80108112:	e9 75 f3 ff ff       	jmp    8010748c <alltraps>

80108117 <vector166>:
.globl vector166
vector166:
  pushl $0
80108117:	6a 00                	push   $0x0
  pushl $166
80108119:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
8010811e:	e9 69 f3 ff ff       	jmp    8010748c <alltraps>

80108123 <vector167>:
.globl vector167
vector167:
  pushl $0
80108123:	6a 00                	push   $0x0
  pushl $167
80108125:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
8010812a:	e9 5d f3 ff ff       	jmp    8010748c <alltraps>

8010812f <vector168>:
.globl vector168
vector168:
  pushl $0
8010812f:	6a 00                	push   $0x0
  pushl $168
80108131:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80108136:	e9 51 f3 ff ff       	jmp    8010748c <alltraps>

8010813b <vector169>:
.globl vector169
vector169:
  pushl $0
8010813b:	6a 00                	push   $0x0
  pushl $169
8010813d:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80108142:	e9 45 f3 ff ff       	jmp    8010748c <alltraps>

80108147 <vector170>:
.globl vector170
vector170:
  pushl $0
80108147:	6a 00                	push   $0x0
  pushl $170
80108149:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
8010814e:	e9 39 f3 ff ff       	jmp    8010748c <alltraps>

80108153 <vector171>:
.globl vector171
vector171:
  pushl $0
80108153:	6a 00                	push   $0x0
  pushl $171
80108155:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
8010815a:	e9 2d f3 ff ff       	jmp    8010748c <alltraps>

8010815f <vector172>:
.globl vector172
vector172:
  pushl $0
8010815f:	6a 00                	push   $0x0
  pushl $172
80108161:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80108166:	e9 21 f3 ff ff       	jmp    8010748c <alltraps>

8010816b <vector173>:
.globl vector173
vector173:
  pushl $0
8010816b:	6a 00                	push   $0x0
  pushl $173
8010816d:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80108172:	e9 15 f3 ff ff       	jmp    8010748c <alltraps>

80108177 <vector174>:
.globl vector174
vector174:
  pushl $0
80108177:	6a 00                	push   $0x0
  pushl $174
80108179:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
8010817e:	e9 09 f3 ff ff       	jmp    8010748c <alltraps>

80108183 <vector175>:
.globl vector175
vector175:
  pushl $0
80108183:	6a 00                	push   $0x0
  pushl $175
80108185:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
8010818a:	e9 fd f2 ff ff       	jmp    8010748c <alltraps>

8010818f <vector176>:
.globl vector176
vector176:
  pushl $0
8010818f:	6a 00                	push   $0x0
  pushl $176
80108191:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80108196:	e9 f1 f2 ff ff       	jmp    8010748c <alltraps>

8010819b <vector177>:
.globl vector177
vector177:
  pushl $0
8010819b:	6a 00                	push   $0x0
  pushl $177
8010819d:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
801081a2:	e9 e5 f2 ff ff       	jmp    8010748c <alltraps>

801081a7 <vector178>:
.globl vector178
vector178:
  pushl $0
801081a7:	6a 00                	push   $0x0
  pushl $178
801081a9:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
801081ae:	e9 d9 f2 ff ff       	jmp    8010748c <alltraps>

801081b3 <vector179>:
.globl vector179
vector179:
  pushl $0
801081b3:	6a 00                	push   $0x0
  pushl $179
801081b5:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
801081ba:	e9 cd f2 ff ff       	jmp    8010748c <alltraps>

801081bf <vector180>:
.globl vector180
vector180:
  pushl $0
801081bf:	6a 00                	push   $0x0
  pushl $180
801081c1:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
801081c6:	e9 c1 f2 ff ff       	jmp    8010748c <alltraps>

801081cb <vector181>:
.globl vector181
vector181:
  pushl $0
801081cb:	6a 00                	push   $0x0
  pushl $181
801081cd:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
801081d2:	e9 b5 f2 ff ff       	jmp    8010748c <alltraps>

801081d7 <vector182>:
.globl vector182
vector182:
  pushl $0
801081d7:	6a 00                	push   $0x0
  pushl $182
801081d9:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
801081de:	e9 a9 f2 ff ff       	jmp    8010748c <alltraps>

801081e3 <vector183>:
.globl vector183
vector183:
  pushl $0
801081e3:	6a 00                	push   $0x0
  pushl $183
801081e5:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
801081ea:	e9 9d f2 ff ff       	jmp    8010748c <alltraps>

801081ef <vector184>:
.globl vector184
vector184:
  pushl $0
801081ef:	6a 00                	push   $0x0
  pushl $184
801081f1:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
801081f6:	e9 91 f2 ff ff       	jmp    8010748c <alltraps>

801081fb <vector185>:
.globl vector185
vector185:
  pushl $0
801081fb:	6a 00                	push   $0x0
  pushl $185
801081fd:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80108202:	e9 85 f2 ff ff       	jmp    8010748c <alltraps>

80108207 <vector186>:
.globl vector186
vector186:
  pushl $0
80108207:	6a 00                	push   $0x0
  pushl $186
80108209:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
8010820e:	e9 79 f2 ff ff       	jmp    8010748c <alltraps>

80108213 <vector187>:
.globl vector187
vector187:
  pushl $0
80108213:	6a 00                	push   $0x0
  pushl $187
80108215:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
8010821a:	e9 6d f2 ff ff       	jmp    8010748c <alltraps>

8010821f <vector188>:
.globl vector188
vector188:
  pushl $0
8010821f:	6a 00                	push   $0x0
  pushl $188
80108221:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80108226:	e9 61 f2 ff ff       	jmp    8010748c <alltraps>

8010822b <vector189>:
.globl vector189
vector189:
  pushl $0
8010822b:	6a 00                	push   $0x0
  pushl $189
8010822d:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80108232:	e9 55 f2 ff ff       	jmp    8010748c <alltraps>

80108237 <vector190>:
.globl vector190
vector190:
  pushl $0
80108237:	6a 00                	push   $0x0
  pushl $190
80108239:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
8010823e:	e9 49 f2 ff ff       	jmp    8010748c <alltraps>

80108243 <vector191>:
.globl vector191
vector191:
  pushl $0
80108243:	6a 00                	push   $0x0
  pushl $191
80108245:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
8010824a:	e9 3d f2 ff ff       	jmp    8010748c <alltraps>

8010824f <vector192>:
.globl vector192
vector192:
  pushl $0
8010824f:	6a 00                	push   $0x0
  pushl $192
80108251:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80108256:	e9 31 f2 ff ff       	jmp    8010748c <alltraps>

8010825b <vector193>:
.globl vector193
vector193:
  pushl $0
8010825b:	6a 00                	push   $0x0
  pushl $193
8010825d:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80108262:	e9 25 f2 ff ff       	jmp    8010748c <alltraps>

80108267 <vector194>:
.globl vector194
vector194:
  pushl $0
80108267:	6a 00                	push   $0x0
  pushl $194
80108269:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
8010826e:	e9 19 f2 ff ff       	jmp    8010748c <alltraps>

80108273 <vector195>:
.globl vector195
vector195:
  pushl $0
80108273:	6a 00                	push   $0x0
  pushl $195
80108275:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
8010827a:	e9 0d f2 ff ff       	jmp    8010748c <alltraps>

8010827f <vector196>:
.globl vector196
vector196:
  pushl $0
8010827f:	6a 00                	push   $0x0
  pushl $196
80108281:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80108286:	e9 01 f2 ff ff       	jmp    8010748c <alltraps>

8010828b <vector197>:
.globl vector197
vector197:
  pushl $0
8010828b:	6a 00                	push   $0x0
  pushl $197
8010828d:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80108292:	e9 f5 f1 ff ff       	jmp    8010748c <alltraps>

80108297 <vector198>:
.globl vector198
vector198:
  pushl $0
80108297:	6a 00                	push   $0x0
  pushl $198
80108299:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
8010829e:	e9 e9 f1 ff ff       	jmp    8010748c <alltraps>

801082a3 <vector199>:
.globl vector199
vector199:
  pushl $0
801082a3:	6a 00                	push   $0x0
  pushl $199
801082a5:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
801082aa:	e9 dd f1 ff ff       	jmp    8010748c <alltraps>

801082af <vector200>:
.globl vector200
vector200:
  pushl $0
801082af:	6a 00                	push   $0x0
  pushl $200
801082b1:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
801082b6:	e9 d1 f1 ff ff       	jmp    8010748c <alltraps>

801082bb <vector201>:
.globl vector201
vector201:
  pushl $0
801082bb:	6a 00                	push   $0x0
  pushl $201
801082bd:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
801082c2:	e9 c5 f1 ff ff       	jmp    8010748c <alltraps>

801082c7 <vector202>:
.globl vector202
vector202:
  pushl $0
801082c7:	6a 00                	push   $0x0
  pushl $202
801082c9:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
801082ce:	e9 b9 f1 ff ff       	jmp    8010748c <alltraps>

801082d3 <vector203>:
.globl vector203
vector203:
  pushl $0
801082d3:	6a 00                	push   $0x0
  pushl $203
801082d5:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
801082da:	e9 ad f1 ff ff       	jmp    8010748c <alltraps>

801082df <vector204>:
.globl vector204
vector204:
  pushl $0
801082df:	6a 00                	push   $0x0
  pushl $204
801082e1:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
801082e6:	e9 a1 f1 ff ff       	jmp    8010748c <alltraps>

801082eb <vector205>:
.globl vector205
vector205:
  pushl $0
801082eb:	6a 00                	push   $0x0
  pushl $205
801082ed:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
801082f2:	e9 95 f1 ff ff       	jmp    8010748c <alltraps>

801082f7 <vector206>:
.globl vector206
vector206:
  pushl $0
801082f7:	6a 00                	push   $0x0
  pushl $206
801082f9:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
801082fe:	e9 89 f1 ff ff       	jmp    8010748c <alltraps>

80108303 <vector207>:
.globl vector207
vector207:
  pushl $0
80108303:	6a 00                	push   $0x0
  pushl $207
80108305:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
8010830a:	e9 7d f1 ff ff       	jmp    8010748c <alltraps>

8010830f <vector208>:
.globl vector208
vector208:
  pushl $0
8010830f:	6a 00                	push   $0x0
  pushl $208
80108311:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80108316:	e9 71 f1 ff ff       	jmp    8010748c <alltraps>

8010831b <vector209>:
.globl vector209
vector209:
  pushl $0
8010831b:	6a 00                	push   $0x0
  pushl $209
8010831d:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80108322:	e9 65 f1 ff ff       	jmp    8010748c <alltraps>

80108327 <vector210>:
.globl vector210
vector210:
  pushl $0
80108327:	6a 00                	push   $0x0
  pushl $210
80108329:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
8010832e:	e9 59 f1 ff ff       	jmp    8010748c <alltraps>

80108333 <vector211>:
.globl vector211
vector211:
  pushl $0
80108333:	6a 00                	push   $0x0
  pushl $211
80108335:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
8010833a:	e9 4d f1 ff ff       	jmp    8010748c <alltraps>

8010833f <vector212>:
.globl vector212
vector212:
  pushl $0
8010833f:	6a 00                	push   $0x0
  pushl $212
80108341:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80108346:	e9 41 f1 ff ff       	jmp    8010748c <alltraps>

8010834b <vector213>:
.globl vector213
vector213:
  pushl $0
8010834b:	6a 00                	push   $0x0
  pushl $213
8010834d:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80108352:	e9 35 f1 ff ff       	jmp    8010748c <alltraps>

80108357 <vector214>:
.globl vector214
vector214:
  pushl $0
80108357:	6a 00                	push   $0x0
  pushl $214
80108359:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
8010835e:	e9 29 f1 ff ff       	jmp    8010748c <alltraps>

80108363 <vector215>:
.globl vector215
vector215:
  pushl $0
80108363:	6a 00                	push   $0x0
  pushl $215
80108365:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
8010836a:	e9 1d f1 ff ff       	jmp    8010748c <alltraps>

8010836f <vector216>:
.globl vector216
vector216:
  pushl $0
8010836f:	6a 00                	push   $0x0
  pushl $216
80108371:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80108376:	e9 11 f1 ff ff       	jmp    8010748c <alltraps>

8010837b <vector217>:
.globl vector217
vector217:
  pushl $0
8010837b:	6a 00                	push   $0x0
  pushl $217
8010837d:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80108382:	e9 05 f1 ff ff       	jmp    8010748c <alltraps>

80108387 <vector218>:
.globl vector218
vector218:
  pushl $0
80108387:	6a 00                	push   $0x0
  pushl $218
80108389:	68 da 00 00 00       	push   $0xda
  jmp alltraps
8010838e:	e9 f9 f0 ff ff       	jmp    8010748c <alltraps>

80108393 <vector219>:
.globl vector219
vector219:
  pushl $0
80108393:	6a 00                	push   $0x0
  pushl $219
80108395:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
8010839a:	e9 ed f0 ff ff       	jmp    8010748c <alltraps>

8010839f <vector220>:
.globl vector220
vector220:
  pushl $0
8010839f:	6a 00                	push   $0x0
  pushl $220
801083a1:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
801083a6:	e9 e1 f0 ff ff       	jmp    8010748c <alltraps>

801083ab <vector221>:
.globl vector221
vector221:
  pushl $0
801083ab:	6a 00                	push   $0x0
  pushl $221
801083ad:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
801083b2:	e9 d5 f0 ff ff       	jmp    8010748c <alltraps>

801083b7 <vector222>:
.globl vector222
vector222:
  pushl $0
801083b7:	6a 00                	push   $0x0
  pushl $222
801083b9:	68 de 00 00 00       	push   $0xde
  jmp alltraps
801083be:	e9 c9 f0 ff ff       	jmp    8010748c <alltraps>

801083c3 <vector223>:
.globl vector223
vector223:
  pushl $0
801083c3:	6a 00                	push   $0x0
  pushl $223
801083c5:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
801083ca:	e9 bd f0 ff ff       	jmp    8010748c <alltraps>

801083cf <vector224>:
.globl vector224
vector224:
  pushl $0
801083cf:	6a 00                	push   $0x0
  pushl $224
801083d1:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
801083d6:	e9 b1 f0 ff ff       	jmp    8010748c <alltraps>

801083db <vector225>:
.globl vector225
vector225:
  pushl $0
801083db:	6a 00                	push   $0x0
  pushl $225
801083dd:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
801083e2:	e9 a5 f0 ff ff       	jmp    8010748c <alltraps>

801083e7 <vector226>:
.globl vector226
vector226:
  pushl $0
801083e7:	6a 00                	push   $0x0
  pushl $226
801083e9:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
801083ee:	e9 99 f0 ff ff       	jmp    8010748c <alltraps>

801083f3 <vector227>:
.globl vector227
vector227:
  pushl $0
801083f3:	6a 00                	push   $0x0
  pushl $227
801083f5:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
801083fa:	e9 8d f0 ff ff       	jmp    8010748c <alltraps>

801083ff <vector228>:
.globl vector228
vector228:
  pushl $0
801083ff:	6a 00                	push   $0x0
  pushl $228
80108401:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80108406:	e9 81 f0 ff ff       	jmp    8010748c <alltraps>

8010840b <vector229>:
.globl vector229
vector229:
  pushl $0
8010840b:	6a 00                	push   $0x0
  pushl $229
8010840d:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80108412:	e9 75 f0 ff ff       	jmp    8010748c <alltraps>

80108417 <vector230>:
.globl vector230
vector230:
  pushl $0
80108417:	6a 00                	push   $0x0
  pushl $230
80108419:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
8010841e:	e9 69 f0 ff ff       	jmp    8010748c <alltraps>

80108423 <vector231>:
.globl vector231
vector231:
  pushl $0
80108423:	6a 00                	push   $0x0
  pushl $231
80108425:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
8010842a:	e9 5d f0 ff ff       	jmp    8010748c <alltraps>

8010842f <vector232>:
.globl vector232
vector232:
  pushl $0
8010842f:	6a 00                	push   $0x0
  pushl $232
80108431:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80108436:	e9 51 f0 ff ff       	jmp    8010748c <alltraps>

8010843b <vector233>:
.globl vector233
vector233:
  pushl $0
8010843b:	6a 00                	push   $0x0
  pushl $233
8010843d:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80108442:	e9 45 f0 ff ff       	jmp    8010748c <alltraps>

80108447 <vector234>:
.globl vector234
vector234:
  pushl $0
80108447:	6a 00                	push   $0x0
  pushl $234
80108449:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
8010844e:	e9 39 f0 ff ff       	jmp    8010748c <alltraps>

80108453 <vector235>:
.globl vector235
vector235:
  pushl $0
80108453:	6a 00                	push   $0x0
  pushl $235
80108455:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
8010845a:	e9 2d f0 ff ff       	jmp    8010748c <alltraps>

8010845f <vector236>:
.globl vector236
vector236:
  pushl $0
8010845f:	6a 00                	push   $0x0
  pushl $236
80108461:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80108466:	e9 21 f0 ff ff       	jmp    8010748c <alltraps>

8010846b <vector237>:
.globl vector237
vector237:
  pushl $0
8010846b:	6a 00                	push   $0x0
  pushl $237
8010846d:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80108472:	e9 15 f0 ff ff       	jmp    8010748c <alltraps>

80108477 <vector238>:
.globl vector238
vector238:
  pushl $0
80108477:	6a 00                	push   $0x0
  pushl $238
80108479:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
8010847e:	e9 09 f0 ff ff       	jmp    8010748c <alltraps>

80108483 <vector239>:
.globl vector239
vector239:
  pushl $0
80108483:	6a 00                	push   $0x0
  pushl $239
80108485:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
8010848a:	e9 fd ef ff ff       	jmp    8010748c <alltraps>

8010848f <vector240>:
.globl vector240
vector240:
  pushl $0
8010848f:	6a 00                	push   $0x0
  pushl $240
80108491:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80108496:	e9 f1 ef ff ff       	jmp    8010748c <alltraps>

8010849b <vector241>:
.globl vector241
vector241:
  pushl $0
8010849b:	6a 00                	push   $0x0
  pushl $241
8010849d:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
801084a2:	e9 e5 ef ff ff       	jmp    8010748c <alltraps>

801084a7 <vector242>:
.globl vector242
vector242:
  pushl $0
801084a7:	6a 00                	push   $0x0
  pushl $242
801084a9:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
801084ae:	e9 d9 ef ff ff       	jmp    8010748c <alltraps>

801084b3 <vector243>:
.globl vector243
vector243:
  pushl $0
801084b3:	6a 00                	push   $0x0
  pushl $243
801084b5:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
801084ba:	e9 cd ef ff ff       	jmp    8010748c <alltraps>

801084bf <vector244>:
.globl vector244
vector244:
  pushl $0
801084bf:	6a 00                	push   $0x0
  pushl $244
801084c1:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
801084c6:	e9 c1 ef ff ff       	jmp    8010748c <alltraps>

801084cb <vector245>:
.globl vector245
vector245:
  pushl $0
801084cb:	6a 00                	push   $0x0
  pushl $245
801084cd:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
801084d2:	e9 b5 ef ff ff       	jmp    8010748c <alltraps>

801084d7 <vector246>:
.globl vector246
vector246:
  pushl $0
801084d7:	6a 00                	push   $0x0
  pushl $246
801084d9:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
801084de:	e9 a9 ef ff ff       	jmp    8010748c <alltraps>

801084e3 <vector247>:
.globl vector247
vector247:
  pushl $0
801084e3:	6a 00                	push   $0x0
  pushl $247
801084e5:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
801084ea:	e9 9d ef ff ff       	jmp    8010748c <alltraps>

801084ef <vector248>:
.globl vector248
vector248:
  pushl $0
801084ef:	6a 00                	push   $0x0
  pushl $248
801084f1:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
801084f6:	e9 91 ef ff ff       	jmp    8010748c <alltraps>

801084fb <vector249>:
.globl vector249
vector249:
  pushl $0
801084fb:	6a 00                	push   $0x0
  pushl $249
801084fd:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80108502:	e9 85 ef ff ff       	jmp    8010748c <alltraps>

80108507 <vector250>:
.globl vector250
vector250:
  pushl $0
80108507:	6a 00                	push   $0x0
  pushl $250
80108509:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
8010850e:	e9 79 ef ff ff       	jmp    8010748c <alltraps>

80108513 <vector251>:
.globl vector251
vector251:
  pushl $0
80108513:	6a 00                	push   $0x0
  pushl $251
80108515:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
8010851a:	e9 6d ef ff ff       	jmp    8010748c <alltraps>

8010851f <vector252>:
.globl vector252
vector252:
  pushl $0
8010851f:	6a 00                	push   $0x0
  pushl $252
80108521:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80108526:	e9 61 ef ff ff       	jmp    8010748c <alltraps>

8010852b <vector253>:
.globl vector253
vector253:
  pushl $0
8010852b:	6a 00                	push   $0x0
  pushl $253
8010852d:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80108532:	e9 55 ef ff ff       	jmp    8010748c <alltraps>

80108537 <vector254>:
.globl vector254
vector254:
  pushl $0
80108537:	6a 00                	push   $0x0
  pushl $254
80108539:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
8010853e:	e9 49 ef ff ff       	jmp    8010748c <alltraps>

80108543 <vector255>:
.globl vector255
vector255:
  pushl $0
80108543:	6a 00                	push   $0x0
  pushl $255
80108545:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
8010854a:	e9 3d ef ff ff       	jmp    8010748c <alltraps>

8010854f <lgdt>:

struct segdesc;

static inline void
lgdt(struct segdesc *p, int size)
{
8010854f:	55                   	push   %ebp
80108550:	89 e5                	mov    %esp,%ebp
80108552:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
80108555:	8b 45 0c             	mov    0xc(%ebp),%eax
80108558:	83 e8 01             	sub    $0x1,%eax
8010855b:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
8010855f:	8b 45 08             	mov    0x8(%ebp),%eax
80108562:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80108566:	8b 45 08             	mov    0x8(%ebp),%eax
80108569:	c1 e8 10             	shr    $0x10,%eax
8010856c:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lgdt (%0)" : : "r" (pd));
80108570:	8d 45 fa             	lea    -0x6(%ebp),%eax
80108573:	0f 01 10             	lgdtl  (%eax)
}
80108576:	90                   	nop
80108577:	c9                   	leave  
80108578:	c3                   	ret    

80108579 <ltr>:
  asm volatile("lidt (%0)" : : "r" (pd));
}

static inline void
ltr(ushort sel)
{
80108579:	55                   	push   %ebp
8010857a:	89 e5                	mov    %esp,%ebp
8010857c:	83 ec 04             	sub    $0x4,%esp
8010857f:	8b 45 08             	mov    0x8(%ebp),%eax
80108582:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
80108586:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
8010858a:	0f 00 d8             	ltr    %ax
}
8010858d:	90                   	nop
8010858e:	c9                   	leave  
8010858f:	c3                   	ret    

80108590 <loadgs>:
  return eflags;
}

static inline void
loadgs(ushort v)
{
80108590:	55                   	push   %ebp
80108591:	89 e5                	mov    %esp,%ebp
80108593:	83 ec 04             	sub    $0x4,%esp
80108596:	8b 45 08             	mov    0x8(%ebp),%eax
80108599:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("movw %0, %%gs" : : "r" (v));
8010859d:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801085a1:	8e e8                	mov    %eax,%gs
}
801085a3:	90                   	nop
801085a4:	c9                   	leave  
801085a5:	c3                   	ret    

801085a6 <lcr3>:
  return val;
}

static inline void
lcr3(uint val) 
{
801085a6:	55                   	push   %ebp
801085a7:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
801085a9:	8b 45 08             	mov    0x8(%ebp),%eax
801085ac:	0f 22 d8             	mov    %eax,%cr3
}
801085af:	90                   	nop
801085b0:	5d                   	pop    %ebp
801085b1:	c3                   	ret    

801085b2 <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
801085b2:	55                   	push   %ebp
801085b3:	89 e5                	mov    %esp,%ebp
801085b5:	8b 45 08             	mov    0x8(%ebp),%eax
801085b8:	05 00 00 00 80       	add    $0x80000000,%eax
801085bd:	5d                   	pop    %ebp
801085be:	c3                   	ret    

801085bf <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
801085bf:	55                   	push   %ebp
801085c0:	89 e5                	mov    %esp,%ebp
801085c2:	8b 45 08             	mov    0x8(%ebp),%eax
801085c5:	05 00 00 00 80       	add    $0x80000000,%eax
801085ca:	5d                   	pop    %ebp
801085cb:	c3                   	ret    

801085cc <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
801085cc:	55                   	push   %ebp
801085cd:	89 e5                	mov    %esp,%ebp
801085cf:	53                   	push   %ebx
801085d0:	83 ec 14             	sub    $0x14,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpunum()];
801085d3:	e8 00 b2 ff ff       	call   801037d8 <cpunum>
801085d8:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
801085de:	05 80 38 11 80       	add    $0x80113880,%eax
801085e3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
801085e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085e9:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
801085ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085f2:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
801085f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085fb:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
801085ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108602:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80108606:	83 e2 f0             	and    $0xfffffff0,%edx
80108609:	83 ca 0a             	or     $0xa,%edx
8010860c:	88 50 7d             	mov    %dl,0x7d(%eax)
8010860f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108612:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80108616:	83 ca 10             	or     $0x10,%edx
80108619:	88 50 7d             	mov    %dl,0x7d(%eax)
8010861c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010861f:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80108623:	83 e2 9f             	and    $0xffffff9f,%edx
80108626:	88 50 7d             	mov    %dl,0x7d(%eax)
80108629:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010862c:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80108630:	83 ca 80             	or     $0xffffff80,%edx
80108633:	88 50 7d             	mov    %dl,0x7d(%eax)
80108636:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108639:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010863d:	83 ca 0f             	or     $0xf,%edx
80108640:	88 50 7e             	mov    %dl,0x7e(%eax)
80108643:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108646:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010864a:	83 e2 ef             	and    $0xffffffef,%edx
8010864d:	88 50 7e             	mov    %dl,0x7e(%eax)
80108650:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108653:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80108657:	83 e2 df             	and    $0xffffffdf,%edx
8010865a:	88 50 7e             	mov    %dl,0x7e(%eax)
8010865d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108660:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80108664:	83 ca 40             	or     $0x40,%edx
80108667:	88 50 7e             	mov    %dl,0x7e(%eax)
8010866a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010866d:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80108671:	83 ca 80             	or     $0xffffff80,%edx
80108674:	88 50 7e             	mov    %dl,0x7e(%eax)
80108677:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010867a:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
8010867e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108681:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
80108688:	ff ff 
8010868a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010868d:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
80108694:	00 00 
80108696:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108699:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
801086a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086a3:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801086aa:	83 e2 f0             	and    $0xfffffff0,%edx
801086ad:	83 ca 02             	or     $0x2,%edx
801086b0:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801086b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086b9:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801086c0:	83 ca 10             	or     $0x10,%edx
801086c3:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801086c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086cc:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801086d3:	83 e2 9f             	and    $0xffffff9f,%edx
801086d6:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801086dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086df:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801086e6:	83 ca 80             	or     $0xffffff80,%edx
801086e9:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801086ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086f2:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801086f9:	83 ca 0f             	or     $0xf,%edx
801086fc:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80108702:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108705:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010870c:	83 e2 ef             	and    $0xffffffef,%edx
8010870f:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80108715:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108718:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010871f:	83 e2 df             	and    $0xffffffdf,%edx
80108722:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80108728:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010872b:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80108732:	83 ca 40             	or     $0x40,%edx
80108735:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010873b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010873e:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80108745:	83 ca 80             	or     $0xffffff80,%edx
80108748:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010874e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108751:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80108758:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010875b:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
80108762:	ff ff 
80108764:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108767:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
8010876e:	00 00 
80108770:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108773:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
8010877a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010877d:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80108784:	83 e2 f0             	and    $0xfffffff0,%edx
80108787:	83 ca 0a             	or     $0xa,%edx
8010878a:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80108790:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108793:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
8010879a:	83 ca 10             	or     $0x10,%edx
8010879d:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801087a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087a6:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801087ad:	83 ca 60             	or     $0x60,%edx
801087b0:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801087b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087b9:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801087c0:	83 ca 80             	or     $0xffffff80,%edx
801087c3:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801087c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087cc:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801087d3:	83 ca 0f             	or     $0xf,%edx
801087d6:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801087dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087df:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801087e6:	83 e2 ef             	and    $0xffffffef,%edx
801087e9:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801087ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087f2:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801087f9:	83 e2 df             	and    $0xffffffdf,%edx
801087fc:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80108802:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108805:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010880c:	83 ca 40             	or     $0x40,%edx
8010880f:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80108815:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108818:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010881f:	83 ca 80             	or     $0xffffff80,%edx
80108822:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80108828:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010882b:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80108832:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108835:	66 c7 80 98 00 00 00 	movw   $0xffff,0x98(%eax)
8010883c:	ff ff 
8010883e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108841:	66 c7 80 9a 00 00 00 	movw   $0x0,0x9a(%eax)
80108848:	00 00 
8010884a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010884d:	c6 80 9c 00 00 00 00 	movb   $0x0,0x9c(%eax)
80108854:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108857:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
8010885e:	83 e2 f0             	and    $0xfffffff0,%edx
80108861:	83 ca 02             	or     $0x2,%edx
80108864:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
8010886a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010886d:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80108874:	83 ca 10             	or     $0x10,%edx
80108877:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
8010887d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108880:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80108887:	83 ca 60             	or     $0x60,%edx
8010888a:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80108890:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108893:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
8010889a:	83 ca 80             	or     $0xffffff80,%edx
8010889d:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
801088a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088a6:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
801088ad:	83 ca 0f             	or     $0xf,%edx
801088b0:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
801088b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088b9:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
801088c0:	83 e2 ef             	and    $0xffffffef,%edx
801088c3:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
801088c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088cc:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
801088d3:	83 e2 df             	and    $0xffffffdf,%edx
801088d6:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
801088dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088df:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
801088e6:	83 ca 40             	or     $0x40,%edx
801088e9:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
801088ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088f2:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
801088f9:	83 ca 80             	or     $0xffffff80,%edx
801088fc:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80108902:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108905:	c6 80 9f 00 00 00 00 	movb   $0x0,0x9f(%eax)

  // Map cpu, and curproc
  c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);
8010890c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010890f:	05 b4 00 00 00       	add    $0xb4,%eax
80108914:	89 c3                	mov    %eax,%ebx
80108916:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108919:	05 b4 00 00 00       	add    $0xb4,%eax
8010891e:	c1 e8 10             	shr    $0x10,%eax
80108921:	89 c2                	mov    %eax,%edx
80108923:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108926:	05 b4 00 00 00       	add    $0xb4,%eax
8010892b:	c1 e8 18             	shr    $0x18,%eax
8010892e:	89 c1                	mov    %eax,%ecx
80108930:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108933:	66 c7 80 88 00 00 00 	movw   $0x0,0x88(%eax)
8010893a:	00 00 
8010893c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010893f:	66 89 98 8a 00 00 00 	mov    %bx,0x8a(%eax)
80108946:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108949:	88 90 8c 00 00 00    	mov    %dl,0x8c(%eax)
8010894f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108952:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80108959:	83 e2 f0             	and    $0xfffffff0,%edx
8010895c:	83 ca 02             	or     $0x2,%edx
8010895f:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80108965:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108968:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
8010896f:	83 ca 10             	or     $0x10,%edx
80108972:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80108978:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010897b:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80108982:	83 e2 9f             	and    $0xffffff9f,%edx
80108985:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
8010898b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010898e:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80108995:	83 ca 80             	or     $0xffffff80,%edx
80108998:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
8010899e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089a1:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801089a8:	83 e2 f0             	and    $0xfffffff0,%edx
801089ab:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801089b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089b4:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801089bb:	83 e2 ef             	and    $0xffffffef,%edx
801089be:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801089c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089c7:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801089ce:	83 e2 df             	and    $0xffffffdf,%edx
801089d1:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801089d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089da:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801089e1:	83 ca 40             	or     $0x40,%edx
801089e4:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801089ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089ed:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801089f4:	83 ca 80             	or     $0xffffff80,%edx
801089f7:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801089fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a00:	88 88 8f 00 00 00    	mov    %cl,0x8f(%eax)

  lgdt(c->gdt, sizeof(c->gdt));
80108a06:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a09:	83 c0 70             	add    $0x70,%eax
80108a0c:	83 ec 08             	sub    $0x8,%esp
80108a0f:	6a 38                	push   $0x38
80108a11:	50                   	push   %eax
80108a12:	e8 38 fb ff ff       	call   8010854f <lgdt>
80108a17:	83 c4 10             	add    $0x10,%esp
  loadgs(SEG_KCPU << 3);
80108a1a:	83 ec 0c             	sub    $0xc,%esp
80108a1d:	6a 18                	push   $0x18
80108a1f:	e8 6c fb ff ff       	call   80108590 <loadgs>
80108a24:	83 c4 10             	add    $0x10,%esp
  
  // Initialize cpu-local storage.
  cpu = c;
80108a27:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a2a:	65 a3 00 00 00 00    	mov    %eax,%gs:0x0
  proc = 0;
80108a30:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80108a37:	00 00 00 00 
}
80108a3b:	90                   	nop
80108a3c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108a3f:	c9                   	leave  
80108a40:	c3                   	ret    

80108a41 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80108a41:	55                   	push   %ebp
80108a42:	89 e5                	mov    %esp,%ebp
80108a44:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80108a47:	8b 45 0c             	mov    0xc(%ebp),%eax
80108a4a:	c1 e8 16             	shr    $0x16,%eax
80108a4d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108a54:	8b 45 08             	mov    0x8(%ebp),%eax
80108a57:	01 d0                	add    %edx,%eax
80108a59:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
80108a5c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108a5f:	8b 00                	mov    (%eax),%eax
80108a61:	83 e0 01             	and    $0x1,%eax
80108a64:	85 c0                	test   %eax,%eax
80108a66:	74 18                	je     80108a80 <walkpgdir+0x3f>
    pgtab = (pte_t*)p2v(PTE_ADDR(*pde));
80108a68:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108a6b:	8b 00                	mov    (%eax),%eax
80108a6d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108a72:	50                   	push   %eax
80108a73:	e8 47 fb ff ff       	call   801085bf <p2v>
80108a78:	83 c4 04             	add    $0x4,%esp
80108a7b:	89 45 f4             	mov    %eax,-0xc(%ebp)
80108a7e:	eb 48                	jmp    80108ac8 <walkpgdir+0x87>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80108a80:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80108a84:	74 0e                	je     80108a94 <walkpgdir+0x53>
80108a86:	e8 e7 a9 ff ff       	call   80103472 <kalloc>
80108a8b:	89 45 f4             	mov    %eax,-0xc(%ebp)
80108a8e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80108a92:	75 07                	jne    80108a9b <walkpgdir+0x5a>
      return 0;
80108a94:	b8 00 00 00 00       	mov    $0x0,%eax
80108a99:	eb 44                	jmp    80108adf <walkpgdir+0x9e>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80108a9b:	83 ec 04             	sub    $0x4,%esp
80108a9e:	68 00 10 00 00       	push   $0x1000
80108aa3:	6a 00                	push   $0x0
80108aa5:	ff 75 f4             	pushl  -0xc(%ebp)
80108aa8:	e8 3a d3 ff ff       	call   80105de7 <memset>
80108aad:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table 
    // entries, if necessary.
    *pde = v2p(pgtab) | PTE_P | PTE_W | PTE_U;
80108ab0:	83 ec 0c             	sub    $0xc,%esp
80108ab3:	ff 75 f4             	pushl  -0xc(%ebp)
80108ab6:	e8 f7 fa ff ff       	call   801085b2 <v2p>
80108abb:	83 c4 10             	add    $0x10,%esp
80108abe:	83 c8 07             	or     $0x7,%eax
80108ac1:	89 c2                	mov    %eax,%edx
80108ac3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108ac6:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80108ac8:	8b 45 0c             	mov    0xc(%ebp),%eax
80108acb:	c1 e8 0c             	shr    $0xc,%eax
80108ace:	25 ff 03 00 00       	and    $0x3ff,%eax
80108ad3:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108ada:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108add:	01 d0                	add    %edx,%eax
}
80108adf:	c9                   	leave  
80108ae0:	c3                   	ret    

80108ae1 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80108ae1:	55                   	push   %ebp
80108ae2:	89 e5                	mov    %esp,%ebp
80108ae4:	83 ec 18             	sub    $0x18,%esp
  char *a, *last;
  pte_t *pte;
  
  a = (char*)PGROUNDDOWN((uint)va);
80108ae7:	8b 45 0c             	mov    0xc(%ebp),%eax
80108aea:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108aef:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80108af2:	8b 55 0c             	mov    0xc(%ebp),%edx
80108af5:	8b 45 10             	mov    0x10(%ebp),%eax
80108af8:	01 d0                	add    %edx,%eax
80108afa:	83 e8 01             	sub    $0x1,%eax
80108afd:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108b02:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80108b05:	83 ec 04             	sub    $0x4,%esp
80108b08:	6a 01                	push   $0x1
80108b0a:	ff 75 f4             	pushl  -0xc(%ebp)
80108b0d:	ff 75 08             	pushl  0x8(%ebp)
80108b10:	e8 2c ff ff ff       	call   80108a41 <walkpgdir>
80108b15:	83 c4 10             	add    $0x10,%esp
80108b18:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108b1b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108b1f:	75 07                	jne    80108b28 <mappages+0x47>
      return -1;
80108b21:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108b26:	eb 47                	jmp    80108b6f <mappages+0x8e>
    if(*pte & PTE_P)
80108b28:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108b2b:	8b 00                	mov    (%eax),%eax
80108b2d:	83 e0 01             	and    $0x1,%eax
80108b30:	85 c0                	test   %eax,%eax
80108b32:	74 0d                	je     80108b41 <mappages+0x60>
      panic("remap");
80108b34:	83 ec 0c             	sub    $0xc,%esp
80108b37:	68 88 9a 10 80       	push   $0x80109a88
80108b3c:	e8 25 7a ff ff       	call   80100566 <panic>
    *pte = pa | perm | PTE_P;
80108b41:	8b 45 18             	mov    0x18(%ebp),%eax
80108b44:	0b 45 14             	or     0x14(%ebp),%eax
80108b47:	83 c8 01             	or     $0x1,%eax
80108b4a:	89 c2                	mov    %eax,%edx
80108b4c:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108b4f:	89 10                	mov    %edx,(%eax)
    if(a == last)
80108b51:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b54:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80108b57:	74 10                	je     80108b69 <mappages+0x88>
      break;
    a += PGSIZE;
80108b59:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
80108b60:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  }
80108b67:	eb 9c                	jmp    80108b05 <mappages+0x24>
      return -1;
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
    if(a == last)
      break;
80108b69:	90                   	nop
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
80108b6a:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108b6f:	c9                   	leave  
80108b70:	c3                   	ret    

80108b71 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
80108b71:	55                   	push   %ebp
80108b72:	89 e5                	mov    %esp,%ebp
80108b74:	53                   	push   %ebx
80108b75:	83 ec 14             	sub    $0x14,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
80108b78:	e8 f5 a8 ff ff       	call   80103472 <kalloc>
80108b7d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108b80:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108b84:	75 0a                	jne    80108b90 <setupkvm+0x1f>
    return 0;
80108b86:	b8 00 00 00 00       	mov    $0x0,%eax
80108b8b:	e9 8e 00 00 00       	jmp    80108c1e <setupkvm+0xad>
  memset(pgdir, 0, PGSIZE);
80108b90:	83 ec 04             	sub    $0x4,%esp
80108b93:	68 00 10 00 00       	push   $0x1000
80108b98:	6a 00                	push   $0x0
80108b9a:	ff 75 f0             	pushl  -0x10(%ebp)
80108b9d:	e8 45 d2 ff ff       	call   80105de7 <memset>
80108ba2:	83 c4 10             	add    $0x10,%esp
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
80108ba5:	83 ec 0c             	sub    $0xc,%esp
80108ba8:	68 00 00 00 0e       	push   $0xe000000
80108bad:	e8 0d fa ff ff       	call   801085bf <p2v>
80108bb2:	83 c4 10             	add    $0x10,%esp
80108bb5:	3d 00 00 00 fe       	cmp    $0xfe000000,%eax
80108bba:	76 0d                	jbe    80108bc9 <setupkvm+0x58>
    panic("PHYSTOP too high");
80108bbc:	83 ec 0c             	sub    $0xc,%esp
80108bbf:	68 8e 9a 10 80       	push   $0x80109a8e
80108bc4:	e8 9d 79 ff ff       	call   80100566 <panic>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80108bc9:	c7 45 f4 a0 c4 10 80 	movl   $0x8010c4a0,-0xc(%ebp)
80108bd0:	eb 40                	jmp    80108c12 <setupkvm+0xa1>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
80108bd2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108bd5:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0)
80108bd8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108bdb:	8b 50 04             	mov    0x4(%eax),%edx
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
80108bde:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108be1:	8b 58 08             	mov    0x8(%eax),%ebx
80108be4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108be7:	8b 40 04             	mov    0x4(%eax),%eax
80108bea:	29 c3                	sub    %eax,%ebx
80108bec:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108bef:	8b 00                	mov    (%eax),%eax
80108bf1:	83 ec 0c             	sub    $0xc,%esp
80108bf4:	51                   	push   %ecx
80108bf5:	52                   	push   %edx
80108bf6:	53                   	push   %ebx
80108bf7:	50                   	push   %eax
80108bf8:	ff 75 f0             	pushl  -0x10(%ebp)
80108bfb:	e8 e1 fe ff ff       	call   80108ae1 <mappages>
80108c00:	83 c4 20             	add    $0x20,%esp
80108c03:	85 c0                	test   %eax,%eax
80108c05:	79 07                	jns    80108c0e <setupkvm+0x9d>
                (uint)k->phys_start, k->perm) < 0)
      return 0;
80108c07:	b8 00 00 00 00       	mov    $0x0,%eax
80108c0c:	eb 10                	jmp    80108c1e <setupkvm+0xad>
  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80108c0e:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80108c12:	81 7d f4 e0 c4 10 80 	cmpl   $0x8010c4e0,-0xc(%ebp)
80108c19:	72 b7                	jb     80108bd2 <setupkvm+0x61>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
                (uint)k->phys_start, k->perm) < 0)
      return 0;
  return pgdir;
80108c1b:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80108c1e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108c21:	c9                   	leave  
80108c22:	c3                   	ret    

80108c23 <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80108c23:	55                   	push   %ebp
80108c24:	89 e5                	mov    %esp,%ebp
80108c26:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80108c29:	e8 43 ff ff ff       	call   80108b71 <setupkvm>
80108c2e:	a3 58 66 11 80       	mov    %eax,0x80116658
  switchkvm();
80108c33:	e8 03 00 00 00       	call   80108c3b <switchkvm>
}
80108c38:	90                   	nop
80108c39:	c9                   	leave  
80108c3a:	c3                   	ret    

80108c3b <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80108c3b:	55                   	push   %ebp
80108c3c:	89 e5                	mov    %esp,%ebp
  lcr3(v2p(kpgdir));   // switch to the kernel page table
80108c3e:	a1 58 66 11 80       	mov    0x80116658,%eax
80108c43:	50                   	push   %eax
80108c44:	e8 69 f9 ff ff       	call   801085b2 <v2p>
80108c49:	83 c4 04             	add    $0x4,%esp
80108c4c:	50                   	push   %eax
80108c4d:	e8 54 f9 ff ff       	call   801085a6 <lcr3>
80108c52:	83 c4 04             	add    $0x4,%esp
}
80108c55:	90                   	nop
80108c56:	c9                   	leave  
80108c57:	c3                   	ret    

80108c58 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80108c58:	55                   	push   %ebp
80108c59:	89 e5                	mov    %esp,%ebp
80108c5b:	56                   	push   %esi
80108c5c:	53                   	push   %ebx
  pushcli();
80108c5d:	e8 7f d0 ff ff       	call   80105ce1 <pushcli>
  cpu->gdt[SEG_TSS] = SEG16(STS_T32A, &cpu->ts, sizeof(cpu->ts)-1, 0);
80108c62:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108c68:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80108c6f:	83 c2 08             	add    $0x8,%edx
80108c72:	89 d6                	mov    %edx,%esi
80108c74:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80108c7b:	83 c2 08             	add    $0x8,%edx
80108c7e:	c1 ea 10             	shr    $0x10,%edx
80108c81:	89 d3                	mov    %edx,%ebx
80108c83:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80108c8a:	83 c2 08             	add    $0x8,%edx
80108c8d:	c1 ea 18             	shr    $0x18,%edx
80108c90:	89 d1                	mov    %edx,%ecx
80108c92:	66 c7 80 a0 00 00 00 	movw   $0x67,0xa0(%eax)
80108c99:	67 00 
80108c9b:	66 89 b0 a2 00 00 00 	mov    %si,0xa2(%eax)
80108ca2:	88 98 a4 00 00 00    	mov    %bl,0xa4(%eax)
80108ca8:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108caf:	83 e2 f0             	and    $0xfffffff0,%edx
80108cb2:	83 ca 09             	or     $0x9,%edx
80108cb5:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80108cbb:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108cc2:	83 ca 10             	or     $0x10,%edx
80108cc5:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80108ccb:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108cd2:	83 e2 9f             	and    $0xffffff9f,%edx
80108cd5:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80108cdb:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108ce2:	83 ca 80             	or     $0xffffff80,%edx
80108ce5:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80108ceb:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80108cf2:	83 e2 f0             	and    $0xfffffff0,%edx
80108cf5:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80108cfb:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80108d02:	83 e2 ef             	and    $0xffffffef,%edx
80108d05:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80108d0b:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80108d12:	83 e2 df             	and    $0xffffffdf,%edx
80108d15:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80108d1b:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80108d22:	83 ca 40             	or     $0x40,%edx
80108d25:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80108d2b:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80108d32:	83 e2 7f             	and    $0x7f,%edx
80108d35:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80108d3b:	88 88 a7 00 00 00    	mov    %cl,0xa7(%eax)
  cpu->gdt[SEG_TSS].s = 0;
80108d41:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108d47:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108d4e:	83 e2 ef             	and    $0xffffffef,%edx
80108d51:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
  cpu->ts.ss0 = SEG_KDATA << 3;
80108d57:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108d5d:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  cpu->ts.esp0 = (uint)proc->kstack + KSTACKSIZE;
80108d63:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108d69:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80108d70:	8b 52 08             	mov    0x8(%edx),%edx
80108d73:	81 c2 00 10 00 00    	add    $0x1000,%edx
80108d79:	89 50 0c             	mov    %edx,0xc(%eax)
  ltr(SEG_TSS << 3);
80108d7c:	83 ec 0c             	sub    $0xc,%esp
80108d7f:	6a 30                	push   $0x30
80108d81:	e8 f3 f7 ff ff       	call   80108579 <ltr>
80108d86:	83 c4 10             	add    $0x10,%esp
  if(p->pgdir == 0)
80108d89:	8b 45 08             	mov    0x8(%ebp),%eax
80108d8c:	8b 40 04             	mov    0x4(%eax),%eax
80108d8f:	85 c0                	test   %eax,%eax
80108d91:	75 0d                	jne    80108da0 <switchuvm+0x148>
    panic("switchuvm: no pgdir");
80108d93:	83 ec 0c             	sub    $0xc,%esp
80108d96:	68 9f 9a 10 80       	push   $0x80109a9f
80108d9b:	e8 c6 77 ff ff       	call   80100566 <panic>
  lcr3(v2p(p->pgdir));  // switch to new address space
80108da0:	8b 45 08             	mov    0x8(%ebp),%eax
80108da3:	8b 40 04             	mov    0x4(%eax),%eax
80108da6:	83 ec 0c             	sub    $0xc,%esp
80108da9:	50                   	push   %eax
80108daa:	e8 03 f8 ff ff       	call   801085b2 <v2p>
80108daf:	83 c4 10             	add    $0x10,%esp
80108db2:	83 ec 0c             	sub    $0xc,%esp
80108db5:	50                   	push   %eax
80108db6:	e8 eb f7 ff ff       	call   801085a6 <lcr3>
80108dbb:	83 c4 10             	add    $0x10,%esp
  popcli();
80108dbe:	e8 63 cf ff ff       	call   80105d26 <popcli>
}
80108dc3:	90                   	nop
80108dc4:	8d 65 f8             	lea    -0x8(%ebp),%esp
80108dc7:	5b                   	pop    %ebx
80108dc8:	5e                   	pop    %esi
80108dc9:	5d                   	pop    %ebp
80108dca:	c3                   	ret    

80108dcb <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80108dcb:	55                   	push   %ebp
80108dcc:	89 e5                	mov    %esp,%ebp
80108dce:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  
  if(sz >= PGSIZE)
80108dd1:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80108dd8:	76 0d                	jbe    80108de7 <inituvm+0x1c>
    panic("inituvm: more than a page");
80108dda:	83 ec 0c             	sub    $0xc,%esp
80108ddd:	68 b3 9a 10 80       	push   $0x80109ab3
80108de2:	e8 7f 77 ff ff       	call   80100566 <panic>
  mem = kalloc();
80108de7:	e8 86 a6 ff ff       	call   80103472 <kalloc>
80108dec:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80108def:	83 ec 04             	sub    $0x4,%esp
80108df2:	68 00 10 00 00       	push   $0x1000
80108df7:	6a 00                	push   $0x0
80108df9:	ff 75 f4             	pushl  -0xc(%ebp)
80108dfc:	e8 e6 cf ff ff       	call   80105de7 <memset>
80108e01:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, v2p(mem), PTE_W|PTE_U);
80108e04:	83 ec 0c             	sub    $0xc,%esp
80108e07:	ff 75 f4             	pushl  -0xc(%ebp)
80108e0a:	e8 a3 f7 ff ff       	call   801085b2 <v2p>
80108e0f:	83 c4 10             	add    $0x10,%esp
80108e12:	83 ec 0c             	sub    $0xc,%esp
80108e15:	6a 06                	push   $0x6
80108e17:	50                   	push   %eax
80108e18:	68 00 10 00 00       	push   $0x1000
80108e1d:	6a 00                	push   $0x0
80108e1f:	ff 75 08             	pushl  0x8(%ebp)
80108e22:	e8 ba fc ff ff       	call   80108ae1 <mappages>
80108e27:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
80108e2a:	83 ec 04             	sub    $0x4,%esp
80108e2d:	ff 75 10             	pushl  0x10(%ebp)
80108e30:	ff 75 0c             	pushl  0xc(%ebp)
80108e33:	ff 75 f4             	pushl  -0xc(%ebp)
80108e36:	e8 6b d0 ff ff       	call   80105ea6 <memmove>
80108e3b:	83 c4 10             	add    $0x10,%esp
}
80108e3e:	90                   	nop
80108e3f:	c9                   	leave  
80108e40:	c3                   	ret    

80108e41 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80108e41:	55                   	push   %ebp
80108e42:	89 e5                	mov    %esp,%ebp
80108e44:	53                   	push   %ebx
80108e45:	83 ec 14             	sub    $0x14,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80108e48:	8b 45 0c             	mov    0xc(%ebp),%eax
80108e4b:	25 ff 0f 00 00       	and    $0xfff,%eax
80108e50:	85 c0                	test   %eax,%eax
80108e52:	74 0d                	je     80108e61 <loaduvm+0x20>
    panic("loaduvm: addr must be page aligned");
80108e54:	83 ec 0c             	sub    $0xc,%esp
80108e57:	68 d0 9a 10 80       	push   $0x80109ad0
80108e5c:	e8 05 77 ff ff       	call   80100566 <panic>
  for(i = 0; i < sz; i += PGSIZE){
80108e61:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108e68:	e9 95 00 00 00       	jmp    80108f02 <loaduvm+0xc1>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80108e6d:	8b 55 0c             	mov    0xc(%ebp),%edx
80108e70:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e73:	01 d0                	add    %edx,%eax
80108e75:	83 ec 04             	sub    $0x4,%esp
80108e78:	6a 00                	push   $0x0
80108e7a:	50                   	push   %eax
80108e7b:	ff 75 08             	pushl  0x8(%ebp)
80108e7e:	e8 be fb ff ff       	call   80108a41 <walkpgdir>
80108e83:	83 c4 10             	add    $0x10,%esp
80108e86:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108e89:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108e8d:	75 0d                	jne    80108e9c <loaduvm+0x5b>
      panic("loaduvm: address should exist");
80108e8f:	83 ec 0c             	sub    $0xc,%esp
80108e92:	68 f3 9a 10 80       	push   $0x80109af3
80108e97:	e8 ca 76 ff ff       	call   80100566 <panic>
    pa = PTE_ADDR(*pte);
80108e9c:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108e9f:	8b 00                	mov    (%eax),%eax
80108ea1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108ea6:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80108ea9:	8b 45 18             	mov    0x18(%ebp),%eax
80108eac:	2b 45 f4             	sub    -0xc(%ebp),%eax
80108eaf:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80108eb4:	77 0b                	ja     80108ec1 <loaduvm+0x80>
      n = sz - i;
80108eb6:	8b 45 18             	mov    0x18(%ebp),%eax
80108eb9:	2b 45 f4             	sub    -0xc(%ebp),%eax
80108ebc:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108ebf:	eb 07                	jmp    80108ec8 <loaduvm+0x87>
    else
      n = PGSIZE;
80108ec1:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, p2v(pa), offset+i, n) != n)
80108ec8:	8b 55 14             	mov    0x14(%ebp),%edx
80108ecb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ece:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80108ed1:	83 ec 0c             	sub    $0xc,%esp
80108ed4:	ff 75 e8             	pushl  -0x18(%ebp)
80108ed7:	e8 e3 f6 ff ff       	call   801085bf <p2v>
80108edc:	83 c4 10             	add    $0x10,%esp
80108edf:	ff 75 f0             	pushl  -0x10(%ebp)
80108ee2:	53                   	push   %ebx
80108ee3:	50                   	push   %eax
80108ee4:	ff 75 10             	pushl  0x10(%ebp)
80108ee7:	e8 8c 96 ff ff       	call   80102578 <readi>
80108eec:	83 c4 10             	add    $0x10,%esp
80108eef:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80108ef2:	74 07                	je     80108efb <loaduvm+0xba>
      return -1;
80108ef4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108ef9:	eb 18                	jmp    80108f13 <loaduvm+0xd2>
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
80108efb:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108f02:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f05:	3b 45 18             	cmp    0x18(%ebp),%eax
80108f08:	0f 82 5f ff ff ff    	jb     80108e6d <loaduvm+0x2c>
    else
      n = PGSIZE;
    if(readi(ip, p2v(pa), offset+i, n) != n)
      return -1;
  }
  return 0;
80108f0e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108f13:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108f16:	c9                   	leave  
80108f17:	c3                   	ret    

80108f18 <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80108f18:	55                   	push   %ebp
80108f19:	89 e5                	mov    %esp,%ebp
80108f1b:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
80108f1e:	8b 45 10             	mov    0x10(%ebp),%eax
80108f21:	85 c0                	test   %eax,%eax
80108f23:	79 0a                	jns    80108f2f <allocuvm+0x17>
    return 0;
80108f25:	b8 00 00 00 00       	mov    $0x0,%eax
80108f2a:	e9 b0 00 00 00       	jmp    80108fdf <allocuvm+0xc7>
  if(newsz < oldsz)
80108f2f:	8b 45 10             	mov    0x10(%ebp),%eax
80108f32:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108f35:	73 08                	jae    80108f3f <allocuvm+0x27>
    return oldsz;
80108f37:	8b 45 0c             	mov    0xc(%ebp),%eax
80108f3a:	e9 a0 00 00 00       	jmp    80108fdf <allocuvm+0xc7>

  a = PGROUNDUP(oldsz);
80108f3f:	8b 45 0c             	mov    0xc(%ebp),%eax
80108f42:	05 ff 0f 00 00       	add    $0xfff,%eax
80108f47:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108f4c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
80108f4f:	eb 7f                	jmp    80108fd0 <allocuvm+0xb8>
    mem = kalloc();
80108f51:	e8 1c a5 ff ff       	call   80103472 <kalloc>
80108f56:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
80108f59:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108f5d:	75 2b                	jne    80108f8a <allocuvm+0x72>
      cprintf("allocuvm out of memory\n");
80108f5f:	83 ec 0c             	sub    $0xc,%esp
80108f62:	68 11 9b 10 80       	push   $0x80109b11
80108f67:	e8 5a 74 ff ff       	call   801003c6 <cprintf>
80108f6c:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80108f6f:	83 ec 04             	sub    $0x4,%esp
80108f72:	ff 75 0c             	pushl  0xc(%ebp)
80108f75:	ff 75 10             	pushl  0x10(%ebp)
80108f78:	ff 75 08             	pushl  0x8(%ebp)
80108f7b:	e8 61 00 00 00       	call   80108fe1 <deallocuvm>
80108f80:	83 c4 10             	add    $0x10,%esp
      return 0;
80108f83:	b8 00 00 00 00       	mov    $0x0,%eax
80108f88:	eb 55                	jmp    80108fdf <allocuvm+0xc7>
    }
    memset(mem, 0, PGSIZE);
80108f8a:	83 ec 04             	sub    $0x4,%esp
80108f8d:	68 00 10 00 00       	push   $0x1000
80108f92:	6a 00                	push   $0x0
80108f94:	ff 75 f0             	pushl  -0x10(%ebp)
80108f97:	e8 4b ce ff ff       	call   80105de7 <memset>
80108f9c:	83 c4 10             	add    $0x10,%esp
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
80108f9f:	83 ec 0c             	sub    $0xc,%esp
80108fa2:	ff 75 f0             	pushl  -0x10(%ebp)
80108fa5:	e8 08 f6 ff ff       	call   801085b2 <v2p>
80108faa:	83 c4 10             	add    $0x10,%esp
80108fad:	89 c2                	mov    %eax,%edx
80108faf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108fb2:	83 ec 0c             	sub    $0xc,%esp
80108fb5:	6a 06                	push   $0x6
80108fb7:	52                   	push   %edx
80108fb8:	68 00 10 00 00       	push   $0x1000
80108fbd:	50                   	push   %eax
80108fbe:	ff 75 08             	pushl  0x8(%ebp)
80108fc1:	e8 1b fb ff ff       	call   80108ae1 <mappages>
80108fc6:	83 c4 20             	add    $0x20,%esp
    return 0;
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){
80108fc9:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108fd0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108fd3:	3b 45 10             	cmp    0x10(%ebp),%eax
80108fd6:	0f 82 75 ff ff ff    	jb     80108f51 <allocuvm+0x39>
      return 0;
    }
    memset(mem, 0, PGSIZE);
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
  }
  return newsz;
80108fdc:	8b 45 10             	mov    0x10(%ebp),%eax
}
80108fdf:	c9                   	leave  
80108fe0:	c3                   	ret    

80108fe1 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80108fe1:	55                   	push   %ebp
80108fe2:	89 e5                	mov    %esp,%ebp
80108fe4:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80108fe7:	8b 45 10             	mov    0x10(%ebp),%eax
80108fea:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108fed:	72 08                	jb     80108ff7 <deallocuvm+0x16>
    return oldsz;
80108fef:	8b 45 0c             	mov    0xc(%ebp),%eax
80108ff2:	e9 a5 00 00 00       	jmp    8010909c <deallocuvm+0xbb>

  a = PGROUNDUP(newsz);
80108ff7:	8b 45 10             	mov    0x10(%ebp),%eax
80108ffa:	05 ff 0f 00 00       	add    $0xfff,%eax
80108fff:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109004:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80109007:	e9 81 00 00 00       	jmp    8010908d <deallocuvm+0xac>
    pte = walkpgdir(pgdir, (char*)a, 0);
8010900c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010900f:	83 ec 04             	sub    $0x4,%esp
80109012:	6a 00                	push   $0x0
80109014:	50                   	push   %eax
80109015:	ff 75 08             	pushl  0x8(%ebp)
80109018:	e8 24 fa ff ff       	call   80108a41 <walkpgdir>
8010901d:	83 c4 10             	add    $0x10,%esp
80109020:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
80109023:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80109027:	75 09                	jne    80109032 <deallocuvm+0x51>
      a += (NPTENTRIES - 1) * PGSIZE;
80109029:	81 45 f4 00 f0 3f 00 	addl   $0x3ff000,-0xc(%ebp)
80109030:	eb 54                	jmp    80109086 <deallocuvm+0xa5>
    else if((*pte & PTE_P) != 0){
80109032:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109035:	8b 00                	mov    (%eax),%eax
80109037:	83 e0 01             	and    $0x1,%eax
8010903a:	85 c0                	test   %eax,%eax
8010903c:	74 48                	je     80109086 <deallocuvm+0xa5>
      pa = PTE_ADDR(*pte);
8010903e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109041:	8b 00                	mov    (%eax),%eax
80109043:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109048:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
8010904b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010904f:	75 0d                	jne    8010905e <deallocuvm+0x7d>
        panic("kfree");
80109051:	83 ec 0c             	sub    $0xc,%esp
80109054:	68 29 9b 10 80       	push   $0x80109b29
80109059:	e8 08 75 ff ff       	call   80100566 <panic>
      char *v = p2v(pa);
8010905e:	83 ec 0c             	sub    $0xc,%esp
80109061:	ff 75 ec             	pushl  -0x14(%ebp)
80109064:	e8 56 f5 ff ff       	call   801085bf <p2v>
80109069:	83 c4 10             	add    $0x10,%esp
8010906c:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
8010906f:	83 ec 0c             	sub    $0xc,%esp
80109072:	ff 75 e8             	pushl  -0x18(%ebp)
80109075:	e8 5b a3 ff ff       	call   801033d5 <kfree>
8010907a:	83 c4 10             	add    $0x10,%esp
      *pte = 0;
8010907d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109080:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
80109086:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010908d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109090:	3b 45 0c             	cmp    0xc(%ebp),%eax
80109093:	0f 82 73 ff ff ff    	jb     8010900c <deallocuvm+0x2b>
      char *v = p2v(pa);
      kfree(v);
      *pte = 0;
    }
  }
  return newsz;
80109099:	8b 45 10             	mov    0x10(%ebp),%eax
}
8010909c:	c9                   	leave  
8010909d:	c3                   	ret    

8010909e <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
8010909e:	55                   	push   %ebp
8010909f:	89 e5                	mov    %esp,%ebp
801090a1:	83 ec 18             	sub    $0x18,%esp
  uint i;

  if(pgdir == 0)
801090a4:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801090a8:	75 0d                	jne    801090b7 <freevm+0x19>
    panic("freevm: no pgdir");
801090aa:	83 ec 0c             	sub    $0xc,%esp
801090ad:	68 2f 9b 10 80       	push   $0x80109b2f
801090b2:	e8 af 74 ff ff       	call   80100566 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
801090b7:	83 ec 04             	sub    $0x4,%esp
801090ba:	6a 00                	push   $0x0
801090bc:	68 00 00 00 80       	push   $0x80000000
801090c1:	ff 75 08             	pushl  0x8(%ebp)
801090c4:	e8 18 ff ff ff       	call   80108fe1 <deallocuvm>
801090c9:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
801090cc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801090d3:	eb 4f                	jmp    80109124 <freevm+0x86>
    if(pgdir[i] & PTE_P){
801090d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801090d8:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801090df:	8b 45 08             	mov    0x8(%ebp),%eax
801090e2:	01 d0                	add    %edx,%eax
801090e4:	8b 00                	mov    (%eax),%eax
801090e6:	83 e0 01             	and    $0x1,%eax
801090e9:	85 c0                	test   %eax,%eax
801090eb:	74 33                	je     80109120 <freevm+0x82>
      char * v = p2v(PTE_ADDR(pgdir[i]));
801090ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801090f0:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801090f7:	8b 45 08             	mov    0x8(%ebp),%eax
801090fa:	01 d0                	add    %edx,%eax
801090fc:	8b 00                	mov    (%eax),%eax
801090fe:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109103:	83 ec 0c             	sub    $0xc,%esp
80109106:	50                   	push   %eax
80109107:	e8 b3 f4 ff ff       	call   801085bf <p2v>
8010910c:	83 c4 10             	add    $0x10,%esp
8010910f:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
80109112:	83 ec 0c             	sub    $0xc,%esp
80109115:	ff 75 f0             	pushl  -0x10(%ebp)
80109118:	e8 b8 a2 ff ff       	call   801033d5 <kfree>
8010911d:	83 c4 10             	add    $0x10,%esp
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
80109120:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80109124:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
8010912b:	76 a8                	jbe    801090d5 <freevm+0x37>
    if(pgdir[i] & PTE_P){
      char * v = p2v(PTE_ADDR(pgdir[i]));
      kfree(v);
    }
  }
  kfree((char*)pgdir);
8010912d:	83 ec 0c             	sub    $0xc,%esp
80109130:	ff 75 08             	pushl  0x8(%ebp)
80109133:	e8 9d a2 ff ff       	call   801033d5 <kfree>
80109138:	83 c4 10             	add    $0x10,%esp
}
8010913b:	90                   	nop
8010913c:	c9                   	leave  
8010913d:	c3                   	ret    

8010913e <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
8010913e:	55                   	push   %ebp
8010913f:	89 e5                	mov    %esp,%ebp
80109141:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80109144:	83 ec 04             	sub    $0x4,%esp
80109147:	6a 00                	push   $0x0
80109149:	ff 75 0c             	pushl  0xc(%ebp)
8010914c:	ff 75 08             	pushl  0x8(%ebp)
8010914f:	e8 ed f8 ff ff       	call   80108a41 <walkpgdir>
80109154:	83 c4 10             	add    $0x10,%esp
80109157:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
8010915a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010915e:	75 0d                	jne    8010916d <clearpteu+0x2f>
    panic("clearpteu");
80109160:	83 ec 0c             	sub    $0xc,%esp
80109163:	68 40 9b 10 80       	push   $0x80109b40
80109168:	e8 f9 73 ff ff       	call   80100566 <panic>
  *pte &= ~PTE_U;
8010916d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109170:	8b 00                	mov    (%eax),%eax
80109172:	83 e0 fb             	and    $0xfffffffb,%eax
80109175:	89 c2                	mov    %eax,%edx
80109177:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010917a:	89 10                	mov    %edx,(%eax)
}
8010917c:	90                   	nop
8010917d:	c9                   	leave  
8010917e:	c3                   	ret    

8010917f <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
8010917f:	55                   	push   %ebp
80109180:	89 e5                	mov    %esp,%ebp
80109182:	53                   	push   %ebx
80109183:	83 ec 24             	sub    $0x24,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
80109186:	e8 e6 f9 ff ff       	call   80108b71 <setupkvm>
8010918b:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010918e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80109192:	75 0a                	jne    8010919e <copyuvm+0x1f>
    return 0;
80109194:	b8 00 00 00 00       	mov    $0x0,%eax
80109199:	e9 f8 00 00 00       	jmp    80109296 <copyuvm+0x117>
  for(i = 0; i < sz; i += PGSIZE){
8010919e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801091a5:	e9 c4 00 00 00       	jmp    8010926e <copyuvm+0xef>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
801091aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091ad:	83 ec 04             	sub    $0x4,%esp
801091b0:	6a 00                	push   $0x0
801091b2:	50                   	push   %eax
801091b3:	ff 75 08             	pushl  0x8(%ebp)
801091b6:	e8 86 f8 ff ff       	call   80108a41 <walkpgdir>
801091bb:	83 c4 10             	add    $0x10,%esp
801091be:	89 45 ec             	mov    %eax,-0x14(%ebp)
801091c1:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801091c5:	75 0d                	jne    801091d4 <copyuvm+0x55>
      panic("copyuvm: pte should exist");
801091c7:	83 ec 0c             	sub    $0xc,%esp
801091ca:	68 4a 9b 10 80       	push   $0x80109b4a
801091cf:	e8 92 73 ff ff       	call   80100566 <panic>
    if(!(*pte & PTE_P))
801091d4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801091d7:	8b 00                	mov    (%eax),%eax
801091d9:	83 e0 01             	and    $0x1,%eax
801091dc:	85 c0                	test   %eax,%eax
801091de:	75 0d                	jne    801091ed <copyuvm+0x6e>
      panic("copyuvm: page not present");
801091e0:	83 ec 0c             	sub    $0xc,%esp
801091e3:	68 64 9b 10 80       	push   $0x80109b64
801091e8:	e8 79 73 ff ff       	call   80100566 <panic>
    pa = PTE_ADDR(*pte);
801091ed:	8b 45 ec             	mov    -0x14(%ebp),%eax
801091f0:	8b 00                	mov    (%eax),%eax
801091f2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801091f7:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
801091fa:	8b 45 ec             	mov    -0x14(%ebp),%eax
801091fd:	8b 00                	mov    (%eax),%eax
801091ff:	25 ff 0f 00 00       	and    $0xfff,%eax
80109204:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
80109207:	e8 66 a2 ff ff       	call   80103472 <kalloc>
8010920c:	89 45 e0             	mov    %eax,-0x20(%ebp)
8010920f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80109213:	74 6a                	je     8010927f <copyuvm+0x100>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
80109215:	83 ec 0c             	sub    $0xc,%esp
80109218:	ff 75 e8             	pushl  -0x18(%ebp)
8010921b:	e8 9f f3 ff ff       	call   801085bf <p2v>
80109220:	83 c4 10             	add    $0x10,%esp
80109223:	83 ec 04             	sub    $0x4,%esp
80109226:	68 00 10 00 00       	push   $0x1000
8010922b:	50                   	push   %eax
8010922c:	ff 75 e0             	pushl  -0x20(%ebp)
8010922f:	e8 72 cc ff ff       	call   80105ea6 <memmove>
80109234:	83 c4 10             	add    $0x10,%esp
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
80109237:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
8010923a:	83 ec 0c             	sub    $0xc,%esp
8010923d:	ff 75 e0             	pushl  -0x20(%ebp)
80109240:	e8 6d f3 ff ff       	call   801085b2 <v2p>
80109245:	83 c4 10             	add    $0x10,%esp
80109248:	89 c2                	mov    %eax,%edx
8010924a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010924d:	83 ec 0c             	sub    $0xc,%esp
80109250:	53                   	push   %ebx
80109251:	52                   	push   %edx
80109252:	68 00 10 00 00       	push   $0x1000
80109257:	50                   	push   %eax
80109258:	ff 75 f0             	pushl  -0x10(%ebp)
8010925b:	e8 81 f8 ff ff       	call   80108ae1 <mappages>
80109260:	83 c4 20             	add    $0x20,%esp
80109263:	85 c0                	test   %eax,%eax
80109265:	78 1b                	js     80109282 <copyuvm+0x103>
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
80109267:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010926e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109271:	3b 45 0c             	cmp    0xc(%ebp),%eax
80109274:	0f 82 30 ff ff ff    	jb     801091aa <copyuvm+0x2b>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
      goto bad;
  }
  return d;
8010927a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010927d:	eb 17                	jmp    80109296 <copyuvm+0x117>
    if(!(*pte & PTE_P))
      panic("copyuvm: page not present");
    pa = PTE_ADDR(*pte);
    flags = PTE_FLAGS(*pte);
    if((mem = kalloc()) == 0)
      goto bad;
8010927f:	90                   	nop
80109280:	eb 01                	jmp    80109283 <copyuvm+0x104>
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
      goto bad;
80109282:	90                   	nop
  }
  return d;

bad:
  freevm(d);
80109283:	83 ec 0c             	sub    $0xc,%esp
80109286:	ff 75 f0             	pushl  -0x10(%ebp)
80109289:	e8 10 fe ff ff       	call   8010909e <freevm>
8010928e:	83 c4 10             	add    $0x10,%esp
  return 0;
80109291:	b8 00 00 00 00       	mov    $0x0,%eax
}
80109296:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80109299:	c9                   	leave  
8010929a:	c3                   	ret    

8010929b <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
8010929b:	55                   	push   %ebp
8010929c:	89 e5                	mov    %esp,%ebp
8010929e:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
801092a1:	83 ec 04             	sub    $0x4,%esp
801092a4:	6a 00                	push   $0x0
801092a6:	ff 75 0c             	pushl  0xc(%ebp)
801092a9:	ff 75 08             	pushl  0x8(%ebp)
801092ac:	e8 90 f7 ff ff       	call   80108a41 <walkpgdir>
801092b1:	83 c4 10             	add    $0x10,%esp
801092b4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
801092b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801092ba:	8b 00                	mov    (%eax),%eax
801092bc:	83 e0 01             	and    $0x1,%eax
801092bf:	85 c0                	test   %eax,%eax
801092c1:	75 07                	jne    801092ca <uva2ka+0x2f>
    return 0;
801092c3:	b8 00 00 00 00       	mov    $0x0,%eax
801092c8:	eb 29                	jmp    801092f3 <uva2ka+0x58>
  if((*pte & PTE_U) == 0)
801092ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801092cd:	8b 00                	mov    (%eax),%eax
801092cf:	83 e0 04             	and    $0x4,%eax
801092d2:	85 c0                	test   %eax,%eax
801092d4:	75 07                	jne    801092dd <uva2ka+0x42>
    return 0;
801092d6:	b8 00 00 00 00       	mov    $0x0,%eax
801092db:	eb 16                	jmp    801092f3 <uva2ka+0x58>
  return (char*)p2v(PTE_ADDR(*pte));
801092dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801092e0:	8b 00                	mov    (%eax),%eax
801092e2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801092e7:	83 ec 0c             	sub    $0xc,%esp
801092ea:	50                   	push   %eax
801092eb:	e8 cf f2 ff ff       	call   801085bf <p2v>
801092f0:	83 c4 10             	add    $0x10,%esp
}
801092f3:	c9                   	leave  
801092f4:	c3                   	ret    

801092f5 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
801092f5:	55                   	push   %ebp
801092f6:	89 e5                	mov    %esp,%ebp
801092f8:	83 ec 18             	sub    $0x18,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
801092fb:	8b 45 10             	mov    0x10(%ebp),%eax
801092fe:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
80109301:	eb 7f                	jmp    80109382 <copyout+0x8d>
    va0 = (uint)PGROUNDDOWN(va);
80109303:	8b 45 0c             	mov    0xc(%ebp),%eax
80109306:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010930b:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
8010930e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109311:	83 ec 08             	sub    $0x8,%esp
80109314:	50                   	push   %eax
80109315:	ff 75 08             	pushl  0x8(%ebp)
80109318:	e8 7e ff ff ff       	call   8010929b <uva2ka>
8010931d:	83 c4 10             	add    $0x10,%esp
80109320:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
80109323:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80109327:	75 07                	jne    80109330 <copyout+0x3b>
      return -1;
80109329:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010932e:	eb 61                	jmp    80109391 <copyout+0x9c>
    n = PGSIZE - (va - va0);
80109330:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109333:	2b 45 0c             	sub    0xc(%ebp),%eax
80109336:	05 00 10 00 00       	add    $0x1000,%eax
8010933b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
8010933e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109341:	3b 45 14             	cmp    0x14(%ebp),%eax
80109344:	76 06                	jbe    8010934c <copyout+0x57>
      n = len;
80109346:	8b 45 14             	mov    0x14(%ebp),%eax
80109349:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
8010934c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010934f:	2b 45 ec             	sub    -0x14(%ebp),%eax
80109352:	89 c2                	mov    %eax,%edx
80109354:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109357:	01 d0                	add    %edx,%eax
80109359:	83 ec 04             	sub    $0x4,%esp
8010935c:	ff 75 f0             	pushl  -0x10(%ebp)
8010935f:	ff 75 f4             	pushl  -0xc(%ebp)
80109362:	50                   	push   %eax
80109363:	e8 3e cb ff ff       	call   80105ea6 <memmove>
80109368:	83 c4 10             	add    $0x10,%esp
    len -= n;
8010936b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010936e:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
80109371:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109374:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
80109377:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010937a:	05 00 10 00 00       	add    $0x1000,%eax
8010937f:	89 45 0c             	mov    %eax,0xc(%ebp)
{
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
80109382:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80109386:	0f 85 77 ff ff ff    	jne    80109303 <copyout+0xe>
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
8010938c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80109391:	c9                   	leave  
80109392:	c3                   	ret    
