
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
8010002d:	b8 ed 43 10 80       	mov    $0x801043ed,%eax
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
8010003d:	68 f4 93 10 80       	push   $0x801093f4
80100042:	68 e0 d6 10 80       	push   $0x8010d6e0
80100047:	e8 22 5b 00 00       	call   80105b6e <initlock>
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
801000c1:	e8 ca 5a 00 00       	call   80105b90 <acquire>
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
8010010c:	e8 e6 5a 00 00       	call   80105bf7 <release>
80100111:	83 c4 10             	add    $0x10,%esp
        return b;
80100114:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100117:	e9 98 00 00 00       	jmp    801001b4 <bget+0x101>
      }
      sleep(b, &bcache.lock);
8010011c:	83 ec 08             	sub    $0x8,%esp
8010011f:	68 e0 d6 10 80       	push   $0x8010d6e0
80100124:	ff 75 f4             	pushl  -0xc(%ebp)
80100127:	e8 6b 57 00 00       	call   80105897 <sleep>
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
80100188:	e8 6a 5a 00 00       	call   80105bf7 <release>
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
801001aa:	68 fb 93 10 80       	push   $0x801093fb
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
801001e2:	e8 3b 2f 00 00       	call   80103122 <iderw>
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
80100204:	68 0c 94 10 80       	push   $0x8010940c
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
80100223:	e8 fa 2e 00 00       	call   80103122 <iderw>
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
80100243:	68 13 94 10 80       	push   $0x80109413
80100248:	e8 19 03 00 00       	call   80100566 <panic>

  acquire(&bcache.lock);
8010024d:	83 ec 0c             	sub    $0xc,%esp
80100250:	68 e0 d6 10 80       	push   $0x8010d6e0
80100255:	e8 36 59 00 00       	call   80105b90 <acquire>
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
801002b9:	e8 c4 56 00 00       	call   80105982 <wakeup>
801002be:	83 c4 10             	add    $0x10,%esp

  release(&bcache.lock);
801002c1:	83 ec 0c             	sub    $0xc,%esp
801002c4:	68 e0 d6 10 80       	push   $0x8010d6e0
801002c9:	e8 29 59 00 00       	call   80105bf7 <release>
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
801003e2:	e8 a9 57 00 00       	call   80105b90 <acquire>
801003e7:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
801003ea:	8b 45 08             	mov    0x8(%ebp),%eax
801003ed:	85 c0                	test   %eax,%eax
801003ef:	75 0d                	jne    801003fe <cprintf+0x38>
    panic("null fmt");
801003f1:	83 ec 0c             	sub    $0xc,%esp
801003f4:	68 1a 94 10 80       	push   $0x8010941a
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
801004cd:	c7 45 ec 23 94 10 80 	movl   $0x80109423,-0x14(%ebp)
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
8010055b:	e8 97 56 00 00       	call   80105bf7 <release>
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
8010058b:	68 2a 94 10 80       	push   $0x8010942a
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
801005aa:	68 39 94 10 80       	push   $0x80109439
801005af:	e8 12 fe ff ff       	call   801003c6 <cprintf>
801005b4:	83 c4 10             	add    $0x10,%esp
  getcallerpcs(&s, pcs);
801005b7:	83 ec 08             	sub    $0x8,%esp
801005ba:	8d 45 cc             	lea    -0x34(%ebp),%eax
801005bd:	50                   	push   %eax
801005be:	8d 45 08             	lea    0x8(%ebp),%eax
801005c1:	50                   	push   %eax
801005c2:	e8 82 56 00 00       	call   80105c49 <getcallerpcs>
801005c7:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
801005ca:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801005d1:	eb 1c                	jmp    801005ef <panic+0x89>
    cprintf(" %p", pcs[i]);
801005d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801005d6:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
801005da:	83 ec 08             	sub    $0x8,%esp
801005dd:	50                   	push   %eax
801005de:	68 3b 94 10 80       	push   $0x8010943b
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
801006ca:	68 3f 94 10 80       	push   $0x8010943f
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
801006f7:	e8 b6 57 00 00       	call   80105eb2 <memmove>
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
80100721:	e8 cd 56 00 00       	call   80105df3 <memset>
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
801007b6:	e8 bf 72 00 00       	call   80107a7a <uartputc>
801007bb:	83 c4 10             	add    $0x10,%esp
801007be:	83 ec 0c             	sub    $0xc,%esp
801007c1:	6a 20                	push   $0x20
801007c3:	e8 b2 72 00 00       	call   80107a7a <uartputc>
801007c8:	83 c4 10             	add    $0x10,%esp
801007cb:	83 ec 0c             	sub    $0xc,%esp
801007ce:	6a 08                	push   $0x8
801007d0:	e8 a5 72 00 00       	call   80107a7a <uartputc>
801007d5:	83 c4 10             	add    $0x10,%esp
801007d8:	eb 0e                	jmp    801007e8 <consputc+0x56>
  } else
    uartputc(c);
801007da:	83 ec 0c             	sub    $0xc,%esp
801007dd:	ff 75 08             	pushl  0x8(%ebp)
801007e0:	e8 95 72 00 00       	call   80107a7a <uartputc>
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
8010080e:	e8 7d 53 00 00       	call   80105b90 <acquire>
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
80100956:	e8 27 50 00 00       	call   80105982 <wakeup>
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
80100979:	e8 79 52 00 00       	call   80105bf7 <release>
8010097e:	83 c4 10             	add    $0x10,%esp
  if(doprocdump) {
80100981:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100985:	74 05                	je     8010098c <consoleintr+0x193>
    procdump();  // now call procdump() wo. cons.lock held
80100987:	e8 b1 50 00 00       	call   80105a3d <procdump>
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
801009b1:	e8 da 51 00 00       	call   80105b90 <acquire>
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
801009d3:	e8 1f 52 00 00       	call   80105bf7 <release>
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
80100a00:	e8 92 4e 00 00       	call   80105897 <sleep>
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
80100a7e:	e8 74 51 00 00       	call   80105bf7 <release>
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
80100abc:	e8 cf 50 00 00       	call   80105b90 <acquire>
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
80100afe:	e8 f4 50 00 00       	call   80105bf7 <release>
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
80100b22:	68 52 94 10 80       	push   $0x80109452
80100b27:	68 c0 c5 10 80       	push   $0x8010c5c0
80100b2c:	e8 3d 50 00 00       	call   80105b6e <initlock>
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
80100b57:	e8 10 3f 00 00       	call   80104a6c <picenable>
80100b5c:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_KBD, 0);
80100b5f:	83 ec 08             	sub    $0x8,%esp
80100b62:	6a 00                	push   $0x0
80100b64:	6a 01                	push   $0x1
80100b66:	e8 84 27 00 00       	call   801032ef <ioapicenable>
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
80100b8d:	e8 20 33 00 00       	call   80103eb2 <begin_op>
80100b92:	83 c4 10             	add    $0x10,%esp
  if((ip = namei(path)) == 0){
80100b95:	83 ec 0c             	sub    $0xc,%esp
80100b98:	ff 75 08             	pushl  0x8(%ebp)
80100b9b:	e8 74 21 00 00       	call   80102d14 <namei>
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
80100bbf:	e8 f5 33 00 00       	call   80103fb9 <end_op>
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
80100c16:	e8 b4 7f 00 00       	call   80108bcf <setupkvm>
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
80100c9c:	e8 d5 82 00 00       	call   80108f76 <allocuvm>
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
80100ccf:	e8 cb 81 00 00       	call   80108e9f <loaduvm>
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
80100d23:	e8 91 32 00 00       	call   80103fb9 <end_op>
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
80100d54:	e8 1d 82 00 00       	call   80108f76 <allocuvm>
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
80100d78:	e8 1f 84 00 00       	call   8010919c <clearpteu>
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
80100db1:	e8 8a 52 00 00       	call   80106040 <strlen>
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
80100dde:	e8 5d 52 00 00       	call   80106040 <strlen>
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
80100e04:	e8 4a 85 00 00       	call   80109353 <copyout>
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
80100ea0:	e8 ae 84 00 00       	call   80109353 <copyout>
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
80100ef1:	e8 00 51 00 00       	call   80105ff6 <safestrcpy>
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
80100f47:	e8 6a 7d 00 00       	call   80108cb6 <switchuvm>
80100f4c:	83 c4 10             	add    $0x10,%esp
  freevm(oldpgdir);
80100f4f:	83 ec 0c             	sub    $0xc,%esp
80100f52:	ff 75 d0             	pushl  -0x30(%ebp)
80100f55:	e8 a2 81 00 00       	call   801090fc <freevm>
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
80100f8f:	e8 68 81 00 00       	call   801090fc <freevm>
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
80100fbe:	e8 f6 2f 00 00       	call   80103fb9 <end_op>
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
80100fd6:	68 5a 94 10 80       	push   $0x8010945a
80100fdb:	68 00 1b 11 80       	push   $0x80111b00
80100fe0:	e8 89 4b 00 00       	call   80105b6e <initlock>
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
80100ff9:	e8 92 4b 00 00       	call   80105b90 <acquire>
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
80101026:	e8 cc 4b 00 00       	call   80105bf7 <release>
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
80101049:	e8 a9 4b 00 00       	call   80105bf7 <release>
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
80101066:	e8 25 4b 00 00       	call   80105b90 <acquire>
8010106b:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
8010106e:	8b 45 08             	mov    0x8(%ebp),%eax
80101071:	8b 40 04             	mov    0x4(%eax),%eax
80101074:	85 c0                	test   %eax,%eax
80101076:	7f 0d                	jg     80101085 <filedup+0x2d>
    panic("filedup");
80101078:	83 ec 0c             	sub    $0xc,%esp
8010107b:	68 61 94 10 80       	push   $0x80109461
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
8010109c:	e8 56 4b 00 00       	call   80105bf7 <release>
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
801010b7:	e8 d4 4a 00 00       	call   80105b90 <acquire>
801010bc:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
801010bf:	8b 45 08             	mov    0x8(%ebp),%eax
801010c2:	8b 40 04             	mov    0x4(%eax),%eax
801010c5:	85 c0                	test   %eax,%eax
801010c7:	7f 0d                	jg     801010d6 <fileclose+0x2d>
    panic("fileclose");
801010c9:	83 ec 0c             	sub    $0xc,%esp
801010cc:	68 69 94 10 80       	push   $0x80109469
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
801010f7:	e8 fb 4a 00 00       	call   80105bf7 <release>
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
80101147:	e8 ab 4a 00 00       	call   80105bf7 <release>
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
80101166:	e8 6a 3b 00 00       	call   80104cd5 <pipeclose>
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
80101188:	e8 25 2d 00 00       	call   80103eb2 <begin_op>
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
801011af:	e8 05 2e 00 00       	call   80103fb9 <end_op>
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
80101245:	e8 33 3c 00 00       	call   80104e7d <piperead>
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
801012bc:	68 73 94 10 80       	push   $0x80109473
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
801012fe:	e8 7c 3a 00 00       	call   80104d7f <pipewrite>
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
80101353:	e8 5a 2b 00 00       	call   80103eb2 <begin_op>
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
801013cc:	e8 e8 2b 00 00       	call   80103fb9 <end_op>
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
801013e5:	68 7c 94 10 80       	push   $0x8010947c
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
8010141b:	68 8c 94 10 80       	push   $0x8010948c
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
8010146c:	e8 41 4a 00 00       	call   80105eb2 <memmove>
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
801014d3:	e8 da 49 00 00       	call   80105eb2 <memmove>
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
80101519:	e8 d5 48 00 00       	call   80105df3 <memset>
8010151e:	83 c4 10             	add    $0x10,%esp
    log_write(bp, partitionNumber);
80101521:	83 ec 08             	sub    $0x8,%esp
80101524:	ff 75 10             	pushl  0x10(%ebp)
80101527:	ff 75 f4             	pushl  -0xc(%ebp)
8010152a:	e8 30 2d 00 00       	call   8010425f <log_write>
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
8010163f:	e8 1b 2c 00 00       	call   8010425f <log_write>
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
801016ca:	68 98 94 10 80       	push   $0x80109498
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
80101787:	68 ae 94 10 80       	push   $0x801094ae
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
801017c3:	e8 97 2a 00 00       	call   8010425f <log_write>
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
801017e5:	68 c1 94 10 80       	push   $0x801094c1
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
8010182a:	c7 45 f0 cc 94 10 80 	movl   $0x801094cc,-0x10(%ebp)
80101831:	eb 07                	jmp    8010183a <printMBR+0x5e>

        } else {
            bootable = "NO";
80101833:	c7 45 f0 d0 94 10 80 	movl   $0x801094d0,-0x10(%ebp)
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
80101889:	c7 45 ec d3 94 10 80 	movl   $0x801094d3,-0x14(%ebp)
            cprintf("unknown type %d \n", m->partitions[i].type);
80101890:	8b 45 08             	mov    0x8(%ebp),%eax
80101893:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101896:	83 c2 1b             	add    $0x1b,%edx
80101899:	c1 e2 04             	shl    $0x4,%edx
8010189c:	01 d0                	add    %edx,%eax
8010189e:	8b 40 12             	mov    0x12(%eax),%eax
801018a1:	83 ec 08             	sub    $0x8,%esp
801018a4:	50                   	push   %eax
801018a5:	68 d7 94 10 80       	push   $0x801094d7
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
801018e2:	68 ec 94 10 80       	push   $0x801094ec
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
80101909:	68 22 95 10 80       	push   $0x80109522
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
80101a3e:	68 2d 95 10 80       	push   $0x8010952d
80101a43:	e8 7e e9 ff ff       	call   801003c6 <cprintf>
80101a48:	83 c4 10             	add    $0x10,%esp
    initlock(&icache.lock, "icache");
80101a4b:	83 ec 08             	sub    $0x8,%esp
80101a4e:	68 48 95 10 80       	push   $0x80109548
80101a53:	68 60 24 11 80       	push   $0x80112460
80101a58:	e8 11 41 00 00       	call   80105b6e <initlock>
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
80101a90:	68 4f 95 10 80       	push   $0x8010954f
80101a95:	e8 2c e9 ff ff       	call   801003c6 <cprintf>
80101a9a:	83 c4 10             	add    $0x10,%esp
    if (bootfrom == -1) {
80101a9d:	a1 18 a0 10 80       	mov    0x8010a018,%eax
80101aa2:	83 f8 ff             	cmp    $0xffffffff,%eax
80101aa5:	75 0d                	jne    80101ab4 <iinit+0x82>
        panic("no bootable partition");
80101aa7:	83 ec 0c             	sub    $0xc,%esp
80101aaa:	68 61 95 10 80       	push   $0x80109561
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
80101b53:	68 78 95 10 80       	push   $0x80109578
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
80101c1b:	e8 d3 41 00 00       	call   80105df3 <memset>
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
80101c37:	e8 23 26 00 00       	call   8010425f <log_write>
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
80101c88:	68 d5 95 10 80       	push   $0x801095d5
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
80101d71:	e8 3c 41 00 00       	call   80105eb2 <memmove>
80101d76:	83 c4 10             	add    $0x10,%esp
    log_write(bp, ip->part->number);
80101d79:	8b 45 08             	mov    0x8(%ebp),%eax
80101d7c:	8b 40 50             	mov    0x50(%eax),%eax
80101d7f:	8b 40 14             	mov    0x14(%eax),%eax
80101d82:	83 ec 08             	sub    $0x8,%esp
80101d85:	50                   	push   %eax
80101d86:	ff 75 f4             	pushl  -0xc(%ebp)
80101d89:	e8 d1 24 00 00       	call   8010425f <log_write>
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
80101db0:	e8 db 3d 00 00       	call   80105b90 <acquire>
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
80101e16:	e8 dc 3d 00 00       	call   80105bf7 <release>
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
80101e56:	68 e7 95 10 80       	push   $0x801095e7
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
80101eab:	e8 47 3d 00 00       	call   80105bf7 <release>
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
80101ec6:	e8 c5 3c 00 00       	call   80105b90 <acquire>
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
80101ee5:	e8 0d 3d 00 00       	call   80105bf7 <release>
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
80101f0b:	68 f7 95 10 80       	push   $0x801095f7
80101f10:	e8 51 e6 ff ff       	call   80100566 <panic>

    acquire(&icache.lock);
80101f15:	83 ec 0c             	sub    $0xc,%esp
80101f18:	68 60 24 11 80       	push   $0x80112460
80101f1d:	e8 6e 3c 00 00       	call   80105b90 <acquire>
80101f22:	83 c4 10             	add    $0x10,%esp
    while (ip->flags & I_BUSY)
80101f25:	eb 13                	jmp    80101f3a <ilock+0x48>
        sleep(ip, &icache.lock);
80101f27:	83 ec 08             	sub    $0x8,%esp
80101f2a:	68 60 24 11 80       	push   $0x80112460
80101f2f:	ff 75 08             	pushl  0x8(%ebp)
80101f32:	e8 60 39 00 00       	call   80105897 <sleep>
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
80101f60:	e8 92 3c 00 00       	call   80105bf7 <release>
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
80102050:	e8 5d 3e 00 00       	call   80105eb2 <memmove>
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
80102086:	68 fd 95 10 80       	push   $0x801095fd
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
801020b9:	68 0c 96 10 80       	push   $0x8010960c
801020be:	e8 a3 e4 ff ff       	call   80100566 <panic>
    }

    acquire(&icache.lock);
801020c3:	83 ec 0c             	sub    $0xc,%esp
801020c6:	68 60 24 11 80       	push   $0x80112460
801020cb:	e8 c0 3a 00 00       	call   80105b90 <acquire>
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
801020ea:	e8 93 38 00 00       	call   80105982 <wakeup>
801020ef:	83 c4 10             	add    $0x10,%esp
    release(&icache.lock);
801020f2:	83 ec 0c             	sub    $0xc,%esp
801020f5:	68 60 24 11 80       	push   $0x80112460
801020fa:	e8 f8 3a 00 00       	call   80105bf7 <release>
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
80102113:	e8 78 3a 00 00       	call   80105b90 <acquire>
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
8010215b:	68 14 96 10 80       	push   $0x80109614
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
8010217e:	e8 74 3a 00 00       	call   80105bf7 <release>
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
801021b3:	e8 d8 39 00 00       	call   80105b90 <acquire>
801021b8:	83 c4 10             	add    $0x10,%esp
        ip->flags = 0;
801021bb:	8b 45 08             	mov    0x8(%ebp),%eax
801021be:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        wakeup(ip);
801021c5:	83 ec 0c             	sub    $0xc,%esp
801021c8:	ff 75 08             	pushl  0x8(%ebp)
801021cb:	e8 b2 37 00 00       	call   80105982 <wakeup>
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
801021ea:	e8 08 3a 00 00       	call   80105bf7 <release>
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
80102380:	e8 da 1e 00 00       	call   8010425f <log_write>
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
8010239e:	68 1e 96 10 80       	push   $0x8010961e
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
801026e7:	e8 c6 37 00 00       	call   80105eb2 <memmove>
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
80102882:	e8 2b 36 00 00       	call   80105eb2 <memmove>
80102887:	83 c4 10             	add    $0x10,%esp
        log_write(bp, ip->part->number);
8010288a:	8b 45 08             	mov    0x8(%ebp),%eax
8010288d:	8b 40 50             	mov    0x50(%eax),%eax
80102890:	8b 40 14             	mov    0x14(%eax),%eax
80102893:	83 ec 08             	sub    $0x8,%esp
80102896:	50                   	push   %eax
80102897:	ff 75 ec             	pushl  -0x14(%ebp)
8010289a:	e8 c0 19 00 00       	call   8010425f <log_write>
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
8010290c:	e8 37 36 00 00       	call   80105f48 <strncmp>
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
8010292c:	68 31 96 10 80       	push   $0x80109631
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
8010295e:	68 43 96 10 80       	push   $0x80109643
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
80102a3d:	68 43 96 10 80       	push   $0x80109643
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
80102a78:	e8 21 35 00 00       	call   80105f9e <strncpy>
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
80102aa4:	68 50 96 10 80       	push   $0x80109650
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
80102b1a:	e8 93 33 00 00       	call   80105eb2 <memmove>
80102b1f:	83 c4 10             	add    $0x10,%esp
80102b22:	eb 26                	jmp    80102b4a <skipelem+0x95>
    else {
        memmove(name, s, len);
80102b24:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102b27:	83 ec 04             	sub    $0x4,%esp
80102b2a:	50                   	push   %eax
80102b2b:	ff 75 f4             	pushl  -0xc(%ebp)
80102b2e:	ff 75 0c             	pushl  0xc(%ebp)
80102b31:	e8 7c 33 00 00       	call   80105eb2 <memmove>
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
80102b74:	6a 01                	push   $0x1
80102b76:	e8 27 f2 ff ff       	call   80101da2 <iget>
80102b7b:	83 c4 10             	add    $0x10,%esp
80102b7e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102b81:	e9 50 01 00 00       	jmp    80102cd6 <namex+0x17d>
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
80102b9e:	e9 33 01 00 00       	jmp    80102cd6 <namex+0x17d>
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
80102bd1:	e9 3c 01 00 00       	jmp    80102d12 <namex+0x1b9>
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
80102bf7:	e9 16 01 00 00       	jmp    80102d12 <namex+0x1b9>
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
80102c2b:	e9 e2 00 00 00       	jmp    80102d12 <namex+0x1b9>
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

        if (!ignoreMounts && !nameiparent && next->type == T_DIR && next->major == MOUNTING_POINT) {
80102c69:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80102c6d:	75 53                	jne    80102cc2 <namex+0x169>
80102c6f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102c73:	75 4d                	jne    80102cc2 <namex+0x169>
80102c75:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102c78:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80102c7c:	66 83 f8 01          	cmp    $0x1,%ax
80102c80:	75 40                	jne    80102cc2 <namex+0x169>
80102c82:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102c85:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102c89:	66 83 f8 01          	cmp    $0x1,%ax
80102c8d:	75 33                	jne    80102cc2 <namex+0x169>
           // cprintf("got into condition \n");
                        iunlock(next);
80102c8f:	83 ec 0c             	sub    $0xc,%esp
80102c92:	ff 75 f0             	pushl  -0x10(%ebp)
80102c95:	e8 f9 f3 ff ff       	call   80102093 <iunlock>
80102c9a:	83 c4 10             	add    $0x10,%esp

            // iunlockput(ip);
            uint partitionNumnber = next->minor;
80102c9d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102ca0:	0f b7 40 14          	movzwl 0x14(%eax),%eax
80102ca4:	98                   	cwtl   
80102ca5:	89 45 ec             	mov    %eax,-0x14(%ebp)
            ip = iget(ROOTDEV, 1, partitionNumnber);
80102ca8:	83 ec 04             	sub    $0x4,%esp
80102cab:	ff 75 ec             	pushl  -0x14(%ebp)
80102cae:	6a 01                	push   $0x1
80102cb0:	6a 01                	push   $0x1
80102cb2:	e8 eb f0 ff ff       	call   80101da2 <iget>
80102cb7:	83 c4 10             	add    $0x10,%esp
80102cba:	89 45 f4             	mov    %eax,-0xc(%ebp)
            return ip;
80102cbd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102cc0:	eb 50                	jmp    80102d12 <namex+0x1b9>
        }
        iunlock(next);
80102cc2:	83 ec 0c             	sub    $0xc,%esp
80102cc5:	ff 75 f0             	pushl  -0x10(%ebp)
80102cc8:	e8 c6 f3 ff ff       	call   80102093 <iunlock>
80102ccd:	83 c4 10             	add    $0x10,%esp

        // testing

        ip = next;
80102cd0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102cd3:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (*path == '/')
        ip = iget(ROOTDEV, ROOTINO, bootfrom);
    else
        ip = idup(proc->cwd);

    while ((path = skipelem(path, name)) != 0) {
80102cd6:	83 ec 08             	sub    $0x8,%esp
80102cd9:	ff 75 14             	pushl  0x14(%ebp)
80102cdc:	ff 75 08             	pushl  0x8(%ebp)
80102cdf:	e8 d1 fd ff ff       	call   80102ab5 <skipelem>
80102ce4:	83 c4 10             	add    $0x10,%esp
80102ce7:	89 45 08             	mov    %eax,0x8(%ebp)
80102cea:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102cee:	0f 85 af fe ff ff    	jne    80102ba3 <namex+0x4a>

        // testing

        ip = next;
    }
    if (nameiparent) {
80102cf4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102cf8:	74 15                	je     80102d0f <namex+0x1b6>
        iput(ip);
80102cfa:	83 ec 0c             	sub    $0xc,%esp
80102cfd:	ff 75 f4             	pushl  -0xc(%ebp)
80102d00:	e8 00 f4 ff ff       	call   80102105 <iput>
80102d05:	83 c4 10             	add    $0x10,%esp
        return 0;
80102d08:	b8 00 00 00 00       	mov    $0x0,%eax
80102d0d:	eb 03                	jmp    80102d12 <namex+0x1b9>
    }
    // cprintf("ip returned is %d \n", ip->inum);
    return ip;
80102d0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102d12:	c9                   	leave  
80102d13:	c3                   	ret    

80102d14 <namei>:

struct inode* namei(char* path)
{
80102d14:	55                   	push   %ebp
80102d15:	89 e5                	mov    %esp,%ebp
80102d17:	83 ec 18             	sub    $0x18,%esp
    char name[DIRSIZ];
    return namex(path, 0, 0, name);
80102d1a:	8d 45 ea             	lea    -0x16(%ebp),%eax
80102d1d:	50                   	push   %eax
80102d1e:	6a 00                	push   $0x0
80102d20:	6a 00                	push   $0x0
80102d22:	ff 75 08             	pushl  0x8(%ebp)
80102d25:	e8 2f fe ff ff       	call   80102b59 <namex>
80102d2a:	83 c4 10             	add    $0x10,%esp
}
80102d2d:	c9                   	leave  
80102d2e:	c3                   	ret    

80102d2f <nameiIgnoreMounts>:

struct inode* nameiIgnoreMounts(char* path)
{
80102d2f:	55                   	push   %ebp
80102d30:	89 e5                	mov    %esp,%ebp
80102d32:	83 ec 18             	sub    $0x18,%esp
    char name[DIRSIZ];
    return namex(path, 0, 1, name);
80102d35:	8d 45 ea             	lea    -0x16(%ebp),%eax
80102d38:	50                   	push   %eax
80102d39:	6a 01                	push   $0x1
80102d3b:	6a 00                	push   $0x0
80102d3d:	ff 75 08             	pushl  0x8(%ebp)
80102d40:	e8 14 fe ff ff       	call   80102b59 <namex>
80102d45:	83 c4 10             	add    $0x10,%esp
}
80102d48:	c9                   	leave  
80102d49:	c3                   	ret    

80102d4a <nameiparent>:

struct inode* nameiparent(char* path, char* name)
{
80102d4a:	55                   	push   %ebp
80102d4b:	89 e5                	mov    %esp,%ebp
80102d4d:	83 ec 08             	sub    $0x8,%esp
    return namex(path, 1, 0, name);
80102d50:	ff 75 0c             	pushl  0xc(%ebp)
80102d53:	6a 00                	push   $0x0
80102d55:	6a 01                	push   $0x1
80102d57:	ff 75 08             	pushl  0x8(%ebp)
80102d5a:	e8 fa fd ff ff       	call   80102b59 <namex>
80102d5f:	83 c4 10             	add    $0x10,%esp
}
80102d62:	c9                   	leave  
80102d63:	c3                   	ret    

80102d64 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102d64:	55                   	push   %ebp
80102d65:	89 e5                	mov    %esp,%ebp
80102d67:	83 ec 14             	sub    $0x14,%esp
80102d6a:	8b 45 08             	mov    0x8(%ebp),%eax
80102d6d:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102d71:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102d75:	89 c2                	mov    %eax,%edx
80102d77:	ec                   	in     (%dx),%al
80102d78:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102d7b:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102d7f:	c9                   	leave  
80102d80:	c3                   	ret    

80102d81 <insl>:

static inline void
insl(int port, void *addr, int cnt)
{
80102d81:	55                   	push   %ebp
80102d82:	89 e5                	mov    %esp,%ebp
80102d84:	57                   	push   %edi
80102d85:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
80102d86:	8b 55 08             	mov    0x8(%ebp),%edx
80102d89:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102d8c:	8b 45 10             	mov    0x10(%ebp),%eax
80102d8f:	89 cb                	mov    %ecx,%ebx
80102d91:	89 df                	mov    %ebx,%edi
80102d93:	89 c1                	mov    %eax,%ecx
80102d95:	fc                   	cld    
80102d96:	f3 6d                	rep insl (%dx),%es:(%edi)
80102d98:	89 c8                	mov    %ecx,%eax
80102d9a:	89 fb                	mov    %edi,%ebx
80102d9c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
80102d9f:	89 45 10             	mov    %eax,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "memory", "cc");
}
80102da2:	90                   	nop
80102da3:	5b                   	pop    %ebx
80102da4:	5f                   	pop    %edi
80102da5:	5d                   	pop    %ebp
80102da6:	c3                   	ret    

80102da7 <outb>:

static inline void
outb(ushort port, uchar data)
{
80102da7:	55                   	push   %ebp
80102da8:	89 e5                	mov    %esp,%ebp
80102daa:	83 ec 08             	sub    $0x8,%esp
80102dad:	8b 55 08             	mov    0x8(%ebp),%edx
80102db0:	8b 45 0c             	mov    0xc(%ebp),%eax
80102db3:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80102db7:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102dba:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102dbe:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102dc2:	ee                   	out    %al,(%dx)
}
80102dc3:	90                   	nop
80102dc4:	c9                   	leave  
80102dc5:	c3                   	ret    

80102dc6 <outsl>:
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
}

static inline void
outsl(int port, const void *addr, int cnt)
{
80102dc6:	55                   	push   %ebp
80102dc7:	89 e5                	mov    %esp,%ebp
80102dc9:	56                   	push   %esi
80102dca:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
80102dcb:	8b 55 08             	mov    0x8(%ebp),%edx
80102dce:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102dd1:	8b 45 10             	mov    0x10(%ebp),%eax
80102dd4:	89 cb                	mov    %ecx,%ebx
80102dd6:	89 de                	mov    %ebx,%esi
80102dd8:	89 c1                	mov    %eax,%ecx
80102dda:	fc                   	cld    
80102ddb:	f3 6f                	rep outsl %ds:(%esi),(%dx)
80102ddd:	89 c8                	mov    %ecx,%eax
80102ddf:	89 f3                	mov    %esi,%ebx
80102de1:	89 5d 0c             	mov    %ebx,0xc(%ebp)
80102de4:	89 45 10             	mov    %eax,0x10(%ebp)
               "=S" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "cc");
}
80102de7:	90                   	nop
80102de8:	5b                   	pop    %ebx
80102de9:	5e                   	pop    %esi
80102dea:	5d                   	pop    %ebp
80102deb:	c3                   	ret    

80102dec <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
80102dec:	55                   	push   %ebp
80102ded:	89 e5                	mov    %esp,%ebp
80102def:	83 ec 10             	sub    $0x10,%esp
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY) 
80102df2:	90                   	nop
80102df3:	68 f7 01 00 00       	push   $0x1f7
80102df8:	e8 67 ff ff ff       	call   80102d64 <inb>
80102dfd:	83 c4 04             	add    $0x4,%esp
80102e00:	0f b6 c0             	movzbl %al,%eax
80102e03:	89 45 fc             	mov    %eax,-0x4(%ebp)
80102e06:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102e09:	25 c0 00 00 00       	and    $0xc0,%eax
80102e0e:	83 f8 40             	cmp    $0x40,%eax
80102e11:	75 e0                	jne    80102df3 <idewait+0x7>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
80102e13:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102e17:	74 11                	je     80102e2a <idewait+0x3e>
80102e19:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102e1c:	83 e0 21             	and    $0x21,%eax
80102e1f:	85 c0                	test   %eax,%eax
80102e21:	74 07                	je     80102e2a <idewait+0x3e>
    return -1;
80102e23:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102e28:	eb 05                	jmp    80102e2f <idewait+0x43>
  return 0;
80102e2a:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102e2f:	c9                   	leave  
80102e30:	c3                   	ret    

80102e31 <ideinit>:

void
ideinit(void)
{
80102e31:	55                   	push   %ebp
80102e32:	89 e5                	mov    %esp,%ebp
80102e34:	83 ec 18             	sub    $0x18,%esp
  int i;
  
  initlock(&idelock, "ide");
80102e37:	83 ec 08             	sub    $0x8,%esp
80102e3a:	68 62 96 10 80       	push   $0x80109662
80102e3f:	68 00 c6 10 80       	push   $0x8010c600
80102e44:	e8 25 2d 00 00       	call   80105b6e <initlock>
80102e49:	83 c4 10             	add    $0x10,%esp
  picenable(IRQ_IDE);
80102e4c:	83 ec 0c             	sub    $0xc,%esp
80102e4f:	6a 0e                	push   $0xe
80102e51:	e8 16 1c 00 00       	call   80104a6c <picenable>
80102e56:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_IDE, ncpu - 1);
80102e59:	a1 60 3e 11 80       	mov    0x80113e60,%eax
80102e5e:	83 e8 01             	sub    $0x1,%eax
80102e61:	83 ec 08             	sub    $0x8,%esp
80102e64:	50                   	push   %eax
80102e65:	6a 0e                	push   $0xe
80102e67:	e8 83 04 00 00       	call   801032ef <ioapicenable>
80102e6c:	83 c4 10             	add    $0x10,%esp
  idewait(0);
80102e6f:	83 ec 0c             	sub    $0xc,%esp
80102e72:	6a 00                	push   $0x0
80102e74:	e8 73 ff ff ff       	call   80102dec <idewait>
80102e79:	83 c4 10             	add    $0x10,%esp
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
80102e7c:	83 ec 08             	sub    $0x8,%esp
80102e7f:	68 f0 00 00 00       	push   $0xf0
80102e84:	68 f6 01 00 00       	push   $0x1f6
80102e89:	e8 19 ff ff ff       	call   80102da7 <outb>
80102e8e:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<1000; i++){
80102e91:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102e98:	eb 24                	jmp    80102ebe <ideinit+0x8d>
    if(inb(0x1f7) != 0){
80102e9a:	83 ec 0c             	sub    $0xc,%esp
80102e9d:	68 f7 01 00 00       	push   $0x1f7
80102ea2:	e8 bd fe ff ff       	call   80102d64 <inb>
80102ea7:	83 c4 10             	add    $0x10,%esp
80102eaa:	84 c0                	test   %al,%al
80102eac:	74 0c                	je     80102eba <ideinit+0x89>
      havedisk1 = 1;
80102eae:	c7 05 38 c6 10 80 01 	movl   $0x1,0x8010c638
80102eb5:	00 00 00 
      break;
80102eb8:	eb 0d                	jmp    80102ec7 <ideinit+0x96>
  ioapicenable(IRQ_IDE, ncpu - 1);
  idewait(0);
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
  for(i=0; i<1000; i++){
80102eba:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102ebe:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
80102ec5:	7e d3                	jle    80102e9a <ideinit+0x69>
      break;
    }
  }
  
  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
80102ec7:	83 ec 08             	sub    $0x8,%esp
80102eca:	68 e0 00 00 00       	push   $0xe0
80102ecf:	68 f6 01 00 00       	push   $0x1f6
80102ed4:	e8 ce fe ff ff       	call   80102da7 <outb>
80102ed9:	83 c4 10             	add    $0x10,%esp
}
80102edc:	90                   	nop
80102edd:	c9                   	leave  
80102ede:	c3                   	ret    

80102edf <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
80102edf:	55                   	push   %ebp
80102ee0:	89 e5                	mov    %esp,%ebp
80102ee2:	83 ec 18             	sub    $0x18,%esp
  if(b == 0)
80102ee5:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102ee9:	75 0d                	jne    80102ef8 <idestart+0x19>
    panic("idestart");
80102eeb:	83 ec 0c             	sub    $0xc,%esp
80102eee:	68 66 96 10 80       	push   $0x80109666
80102ef3:	e8 6e d6 ff ff       	call   80100566 <panic>
  if(b->blockno >= FSSIZE){
80102ef8:	8b 45 08             	mov    0x8(%ebp),%eax
80102efb:	8b 40 08             	mov    0x8(%eax),%eax
80102efe:	3d 9f 0f 00 00       	cmp    $0xf9f,%eax
80102f03:	76 1d                	jbe    80102f22 <idestart+0x43>
      cprintf("block %d \n");
80102f05:	83 ec 0c             	sub    $0xc,%esp
80102f08:	68 6f 96 10 80       	push   $0x8010966f
80102f0d:	e8 b4 d4 ff ff       	call   801003c6 <cprintf>
80102f12:	83 c4 10             	add    $0x10,%esp
          panic("incorrect blockno");
80102f15:	83 ec 0c             	sub    $0xc,%esp
80102f18:	68 7a 96 10 80       	push   $0x8010967a
80102f1d:	e8 44 d6 ff ff       	call   80100566 <panic>

  }
  int sector_per_block =  BSIZE/SECTOR_SIZE;
80102f22:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  int sector = b->blockno * sector_per_block;
80102f29:	8b 45 08             	mov    0x8(%ebp),%eax
80102f2c:	8b 50 08             	mov    0x8(%eax),%edx
80102f2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102f32:	0f af c2             	imul   %edx,%eax
80102f35:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if (sector_per_block > 7) panic("idestart");
80102f38:	83 7d f4 07          	cmpl   $0x7,-0xc(%ebp)
80102f3c:	7e 0d                	jle    80102f4b <idestart+0x6c>
80102f3e:	83 ec 0c             	sub    $0xc,%esp
80102f41:	68 66 96 10 80       	push   $0x80109666
80102f46:	e8 1b d6 ff ff       	call   80100566 <panic>
  
  idewait(0);
80102f4b:	83 ec 0c             	sub    $0xc,%esp
80102f4e:	6a 00                	push   $0x0
80102f50:	e8 97 fe ff ff       	call   80102dec <idewait>
80102f55:	83 c4 10             	add    $0x10,%esp
  outb(0x3f6, 0);  // generate interrupt
80102f58:	83 ec 08             	sub    $0x8,%esp
80102f5b:	6a 00                	push   $0x0
80102f5d:	68 f6 03 00 00       	push   $0x3f6
80102f62:	e8 40 fe ff ff       	call   80102da7 <outb>
80102f67:	83 c4 10             	add    $0x10,%esp
  outb(0x1f2, sector_per_block);  // number of sectors
80102f6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102f6d:	0f b6 c0             	movzbl %al,%eax
80102f70:	83 ec 08             	sub    $0x8,%esp
80102f73:	50                   	push   %eax
80102f74:	68 f2 01 00 00       	push   $0x1f2
80102f79:	e8 29 fe ff ff       	call   80102da7 <outb>
80102f7e:	83 c4 10             	add    $0x10,%esp
  outb(0x1f3, sector & 0xff);
80102f81:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102f84:	0f b6 c0             	movzbl %al,%eax
80102f87:	83 ec 08             	sub    $0x8,%esp
80102f8a:	50                   	push   %eax
80102f8b:	68 f3 01 00 00       	push   $0x1f3
80102f90:	e8 12 fe ff ff       	call   80102da7 <outb>
80102f95:	83 c4 10             	add    $0x10,%esp
  outb(0x1f4, (sector >> 8) & 0xff);
80102f98:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102f9b:	c1 f8 08             	sar    $0x8,%eax
80102f9e:	0f b6 c0             	movzbl %al,%eax
80102fa1:	83 ec 08             	sub    $0x8,%esp
80102fa4:	50                   	push   %eax
80102fa5:	68 f4 01 00 00       	push   $0x1f4
80102faa:	e8 f8 fd ff ff       	call   80102da7 <outb>
80102faf:	83 c4 10             	add    $0x10,%esp
  outb(0x1f5, (sector >> 16) & 0xff);
80102fb2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102fb5:	c1 f8 10             	sar    $0x10,%eax
80102fb8:	0f b6 c0             	movzbl %al,%eax
80102fbb:	83 ec 08             	sub    $0x8,%esp
80102fbe:	50                   	push   %eax
80102fbf:	68 f5 01 00 00       	push   $0x1f5
80102fc4:	e8 de fd ff ff       	call   80102da7 <outb>
80102fc9:	83 c4 10             	add    $0x10,%esp
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
80102fcc:	8b 45 08             	mov    0x8(%ebp),%eax
80102fcf:	8b 40 04             	mov    0x4(%eax),%eax
80102fd2:	83 e0 01             	and    $0x1,%eax
80102fd5:	c1 e0 04             	shl    $0x4,%eax
80102fd8:	89 c2                	mov    %eax,%edx
80102fda:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102fdd:	c1 f8 18             	sar    $0x18,%eax
80102fe0:	83 e0 0f             	and    $0xf,%eax
80102fe3:	09 d0                	or     %edx,%eax
80102fe5:	83 c8 e0             	or     $0xffffffe0,%eax
80102fe8:	0f b6 c0             	movzbl %al,%eax
80102feb:	83 ec 08             	sub    $0x8,%esp
80102fee:	50                   	push   %eax
80102fef:	68 f6 01 00 00       	push   $0x1f6
80102ff4:	e8 ae fd ff ff       	call   80102da7 <outb>
80102ff9:	83 c4 10             	add    $0x10,%esp
  if(b->flags & B_DIRTY){
80102ffc:	8b 45 08             	mov    0x8(%ebp),%eax
80102fff:	8b 00                	mov    (%eax),%eax
80103001:	83 e0 04             	and    $0x4,%eax
80103004:	85 c0                	test   %eax,%eax
80103006:	74 30                	je     80103038 <idestart+0x159>
    outb(0x1f7, IDE_CMD_WRITE);
80103008:	83 ec 08             	sub    $0x8,%esp
8010300b:	6a 30                	push   $0x30
8010300d:	68 f7 01 00 00       	push   $0x1f7
80103012:	e8 90 fd ff ff       	call   80102da7 <outb>
80103017:	83 c4 10             	add    $0x10,%esp
    outsl(0x1f0, b->data, BSIZE/4);
8010301a:	8b 45 08             	mov    0x8(%ebp),%eax
8010301d:	83 c0 18             	add    $0x18,%eax
80103020:	83 ec 04             	sub    $0x4,%esp
80103023:	68 80 00 00 00       	push   $0x80
80103028:	50                   	push   %eax
80103029:	68 f0 01 00 00       	push   $0x1f0
8010302e:	e8 93 fd ff ff       	call   80102dc6 <outsl>
80103033:	83 c4 10             	add    $0x10,%esp
  } else {
    outb(0x1f7, IDE_CMD_READ);
  }
}
80103036:	eb 12                	jmp    8010304a <idestart+0x16b>
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
  if(b->flags & B_DIRTY){
    outb(0x1f7, IDE_CMD_WRITE);
    outsl(0x1f0, b->data, BSIZE/4);
  } else {
    outb(0x1f7, IDE_CMD_READ);
80103038:	83 ec 08             	sub    $0x8,%esp
8010303b:	6a 20                	push   $0x20
8010303d:	68 f7 01 00 00       	push   $0x1f7
80103042:	e8 60 fd ff ff       	call   80102da7 <outb>
80103047:	83 c4 10             	add    $0x10,%esp
  }
}
8010304a:	90                   	nop
8010304b:	c9                   	leave  
8010304c:	c3                   	ret    

8010304d <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
8010304d:	55                   	push   %ebp
8010304e:	89 e5                	mov    %esp,%ebp
80103050:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
80103053:	83 ec 0c             	sub    $0xc,%esp
80103056:	68 00 c6 10 80       	push   $0x8010c600
8010305b:	e8 30 2b 00 00       	call   80105b90 <acquire>
80103060:	83 c4 10             	add    $0x10,%esp
  if((b = idequeue) == 0){
80103063:	a1 34 c6 10 80       	mov    0x8010c634,%eax
80103068:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010306b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010306f:	75 15                	jne    80103086 <ideintr+0x39>
    release(&idelock);
80103071:	83 ec 0c             	sub    $0xc,%esp
80103074:	68 00 c6 10 80       	push   $0x8010c600
80103079:	e8 79 2b 00 00       	call   80105bf7 <release>
8010307e:	83 c4 10             	add    $0x10,%esp
    // cprintf("spurious IDE interrupt\n");
    return;
80103081:	e9 9a 00 00 00       	jmp    80103120 <ideintr+0xd3>
  }
  idequeue = b->qnext;
80103086:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103089:	8b 40 14             	mov    0x14(%eax),%eax
8010308c:	a3 34 c6 10 80       	mov    %eax,0x8010c634

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
80103091:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103094:	8b 00                	mov    (%eax),%eax
80103096:	83 e0 04             	and    $0x4,%eax
80103099:	85 c0                	test   %eax,%eax
8010309b:	75 2d                	jne    801030ca <ideintr+0x7d>
8010309d:	83 ec 0c             	sub    $0xc,%esp
801030a0:	6a 01                	push   $0x1
801030a2:	e8 45 fd ff ff       	call   80102dec <idewait>
801030a7:	83 c4 10             	add    $0x10,%esp
801030aa:	85 c0                	test   %eax,%eax
801030ac:	78 1c                	js     801030ca <ideintr+0x7d>
    insl(0x1f0, b->data, BSIZE/4);
801030ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801030b1:	83 c0 18             	add    $0x18,%eax
801030b4:	83 ec 04             	sub    $0x4,%esp
801030b7:	68 80 00 00 00       	push   $0x80
801030bc:	50                   	push   %eax
801030bd:	68 f0 01 00 00       	push   $0x1f0
801030c2:	e8 ba fc ff ff       	call   80102d81 <insl>
801030c7:	83 c4 10             	add    $0x10,%esp
  
  // Wake process waiting for this buf.
  b->flags |= B_VALID;
801030ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801030cd:	8b 00                	mov    (%eax),%eax
801030cf:	83 c8 02             	or     $0x2,%eax
801030d2:	89 c2                	mov    %eax,%edx
801030d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801030d7:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
801030d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801030dc:	8b 00                	mov    (%eax),%eax
801030de:	83 e0 fb             	and    $0xfffffffb,%eax
801030e1:	89 c2                	mov    %eax,%edx
801030e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801030e6:	89 10                	mov    %edx,(%eax)
  wakeup(b);
801030e8:	83 ec 0c             	sub    $0xc,%esp
801030eb:	ff 75 f4             	pushl  -0xc(%ebp)
801030ee:	e8 8f 28 00 00       	call   80105982 <wakeup>
801030f3:	83 c4 10             	add    $0x10,%esp
  
  // Start disk on next buf in queue.
  if(idequeue != 0){
801030f6:	a1 34 c6 10 80       	mov    0x8010c634,%eax
801030fb:	85 c0                	test   %eax,%eax
801030fd:	74 11                	je     80103110 <ideintr+0xc3>
            //cprintf("ideintr \n");
                idestart(idequeue);
801030ff:	a1 34 c6 10 80       	mov    0x8010c634,%eax
80103104:	83 ec 0c             	sub    $0xc,%esp
80103107:	50                   	push   %eax
80103108:	e8 d2 fd ff ff       	call   80102edf <idestart>
8010310d:	83 c4 10             	add    $0x10,%esp


  }

  release(&idelock);
80103110:	83 ec 0c             	sub    $0xc,%esp
80103113:	68 00 c6 10 80       	push   $0x8010c600
80103118:	e8 da 2a 00 00       	call   80105bf7 <release>
8010311d:	83 c4 10             	add    $0x10,%esp
}
80103120:	c9                   	leave  
80103121:	c3                   	ret    

80103122 <iderw>:
// Sync buf with disk. 
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
80103122:	55                   	push   %ebp
80103123:	89 e5                	mov    %esp,%ebp
80103125:	83 ec 18             	sub    $0x18,%esp
  struct buf **pp;

  if(!(b->flags & B_BUSY))
80103128:	8b 45 08             	mov    0x8(%ebp),%eax
8010312b:	8b 00                	mov    (%eax),%eax
8010312d:	83 e0 01             	and    $0x1,%eax
80103130:	85 c0                	test   %eax,%eax
80103132:	75 0d                	jne    80103141 <iderw+0x1f>
    panic("iderw: buf not busy");
80103134:	83 ec 0c             	sub    $0xc,%esp
80103137:	68 8c 96 10 80       	push   $0x8010968c
8010313c:	e8 25 d4 ff ff       	call   80100566 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
80103141:	8b 45 08             	mov    0x8(%ebp),%eax
80103144:	8b 00                	mov    (%eax),%eax
80103146:	83 e0 06             	and    $0x6,%eax
80103149:	83 f8 02             	cmp    $0x2,%eax
8010314c:	75 0d                	jne    8010315b <iderw+0x39>
    panic("iderw: nothing to do");
8010314e:	83 ec 0c             	sub    $0xc,%esp
80103151:	68 a0 96 10 80       	push   $0x801096a0
80103156:	e8 0b d4 ff ff       	call   80100566 <panic>
  if(b->dev != 0 && !havedisk1)
8010315b:	8b 45 08             	mov    0x8(%ebp),%eax
8010315e:	8b 40 04             	mov    0x4(%eax),%eax
80103161:	85 c0                	test   %eax,%eax
80103163:	74 16                	je     8010317b <iderw+0x59>
80103165:	a1 38 c6 10 80       	mov    0x8010c638,%eax
8010316a:	85 c0                	test   %eax,%eax
8010316c:	75 0d                	jne    8010317b <iderw+0x59>
    panic("iderw: ide disk 1 not present");
8010316e:	83 ec 0c             	sub    $0xc,%esp
80103171:	68 b5 96 10 80       	push   $0x801096b5
80103176:	e8 eb d3 ff ff       	call   80100566 <panic>

  acquire(&idelock);  //DOC:acquire-lock
8010317b:	83 ec 0c             	sub    $0xc,%esp
8010317e:	68 00 c6 10 80       	push   $0x8010c600
80103183:	e8 08 2a 00 00       	call   80105b90 <acquire>
80103188:	83 c4 10             	add    $0x10,%esp

  // Append b to idequeue.
  b->qnext = 0;
8010318b:	8b 45 08             	mov    0x8(%ebp),%eax
8010318e:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80103195:	c7 45 f4 34 c6 10 80 	movl   $0x8010c634,-0xc(%ebp)
8010319c:	eb 0b                	jmp    801031a9 <iderw+0x87>
8010319e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801031a1:	8b 00                	mov    (%eax),%eax
801031a3:	83 c0 14             	add    $0x14,%eax
801031a6:	89 45 f4             	mov    %eax,-0xc(%ebp)
801031a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801031ac:	8b 00                	mov    (%eax),%eax
801031ae:	85 c0                	test   %eax,%eax
801031b0:	75 ec                	jne    8010319e <iderw+0x7c>
    ;
  *pp = b;
801031b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801031b5:	8b 55 08             	mov    0x8(%ebp),%edx
801031b8:	89 10                	mov    %edx,(%eax)
  
  // Start disk if necessary.
  if(idequeue == b){
801031ba:	a1 34 c6 10 80       	mov    0x8010c634,%eax
801031bf:	3b 45 08             	cmp    0x8(%ebp),%eax
801031c2:	75 23                	jne    801031e7 <iderw+0xc5>
     // cprintf("iderw \n");
          idestart(b);
801031c4:	83 ec 0c             	sub    $0xc,%esp
801031c7:	ff 75 08             	pushl  0x8(%ebp)
801031ca:	e8 10 fd ff ff       	call   80102edf <idestart>
801031cf:	83 c4 10             	add    $0x10,%esp

  }
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
801031d2:	eb 13                	jmp    801031e7 <iderw+0xc5>
    sleep(b, &idelock);
801031d4:	83 ec 08             	sub    $0x8,%esp
801031d7:	68 00 c6 10 80       	push   $0x8010c600
801031dc:	ff 75 08             	pushl  0x8(%ebp)
801031df:	e8 b3 26 00 00       	call   80105897 <sleep>
801031e4:	83 c4 10             	add    $0x10,%esp
          idestart(b);

  }
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
801031e7:	8b 45 08             	mov    0x8(%ebp),%eax
801031ea:	8b 00                	mov    (%eax),%eax
801031ec:	83 e0 06             	and    $0x6,%eax
801031ef:	83 f8 02             	cmp    $0x2,%eax
801031f2:	75 e0                	jne    801031d4 <iderw+0xb2>
    sleep(b, &idelock);
  }

  release(&idelock);
801031f4:	83 ec 0c             	sub    $0xc,%esp
801031f7:	68 00 c6 10 80       	push   $0x8010c600
801031fc:	e8 f6 29 00 00       	call   80105bf7 <release>
80103201:	83 c4 10             	add    $0x10,%esp
}
80103204:	90                   	nop
80103205:	c9                   	leave  
80103206:	c3                   	ret    

80103207 <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
80103207:	55                   	push   %ebp
80103208:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
8010320a:	a1 fc 34 11 80       	mov    0x801134fc,%eax
8010320f:	8b 55 08             	mov    0x8(%ebp),%edx
80103212:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80103214:	a1 fc 34 11 80       	mov    0x801134fc,%eax
80103219:	8b 40 10             	mov    0x10(%eax),%eax
}
8010321c:	5d                   	pop    %ebp
8010321d:	c3                   	ret    

8010321e <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
8010321e:	55                   	push   %ebp
8010321f:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80103221:	a1 fc 34 11 80       	mov    0x801134fc,%eax
80103226:	8b 55 08             	mov    0x8(%ebp),%edx
80103229:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
8010322b:	a1 fc 34 11 80       	mov    0x801134fc,%eax
80103230:	8b 55 0c             	mov    0xc(%ebp),%edx
80103233:	89 50 10             	mov    %edx,0x10(%eax)
}
80103236:	90                   	nop
80103237:	5d                   	pop    %ebp
80103238:	c3                   	ret    

80103239 <ioapicinit>:

void
ioapicinit(void)
{
80103239:	55                   	push   %ebp
8010323a:	89 e5                	mov    %esp,%ebp
8010323c:	83 ec 18             	sub    $0x18,%esp
  int i, id, maxintr;

  if(!ismp)
8010323f:	a1 64 38 11 80       	mov    0x80113864,%eax
80103244:	85 c0                	test   %eax,%eax
80103246:	0f 84 a0 00 00 00    	je     801032ec <ioapicinit+0xb3>
    return;

  ioapic = (volatile struct ioapic*)IOAPIC;
8010324c:	c7 05 fc 34 11 80 00 	movl   $0xfec00000,0x801134fc
80103253:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80103256:	6a 01                	push   $0x1
80103258:	e8 aa ff ff ff       	call   80103207 <ioapicread>
8010325d:	83 c4 04             	add    $0x4,%esp
80103260:	c1 e8 10             	shr    $0x10,%eax
80103263:	25 ff 00 00 00       	and    $0xff,%eax
80103268:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
8010326b:	6a 00                	push   $0x0
8010326d:	e8 95 ff ff ff       	call   80103207 <ioapicread>
80103272:	83 c4 04             	add    $0x4,%esp
80103275:	c1 e8 18             	shr    $0x18,%eax
80103278:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
8010327b:	0f b6 05 60 38 11 80 	movzbl 0x80113860,%eax
80103282:	0f b6 c0             	movzbl %al,%eax
80103285:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103288:	74 10                	je     8010329a <ioapicinit+0x61>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
8010328a:	83 ec 0c             	sub    $0xc,%esp
8010328d:	68 d4 96 10 80       	push   $0x801096d4
80103292:	e8 2f d1 ff ff       	call   801003c6 <cprintf>
80103297:	83 c4 10             	add    $0x10,%esp

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
8010329a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801032a1:	eb 3f                	jmp    801032e2 <ioapicinit+0xa9>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
801032a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801032a6:	83 c0 20             	add    $0x20,%eax
801032a9:	0d 00 00 01 00       	or     $0x10000,%eax
801032ae:	89 c2                	mov    %eax,%edx
801032b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801032b3:	83 c0 08             	add    $0x8,%eax
801032b6:	01 c0                	add    %eax,%eax
801032b8:	83 ec 08             	sub    $0x8,%esp
801032bb:	52                   	push   %edx
801032bc:	50                   	push   %eax
801032bd:	e8 5c ff ff ff       	call   8010321e <ioapicwrite>
801032c2:	83 c4 10             	add    $0x10,%esp
    ioapicwrite(REG_TABLE+2*i+1, 0);
801032c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801032c8:	83 c0 08             	add    $0x8,%eax
801032cb:	01 c0                	add    %eax,%eax
801032cd:	83 c0 01             	add    $0x1,%eax
801032d0:	83 ec 08             	sub    $0x8,%esp
801032d3:	6a 00                	push   $0x0
801032d5:	50                   	push   %eax
801032d6:	e8 43 ff ff ff       	call   8010321e <ioapicwrite>
801032db:	83 c4 10             	add    $0x10,%esp
  if(id != ioapicid)
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
801032de:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801032e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801032e5:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801032e8:	7e b9                	jle    801032a3 <ioapicinit+0x6a>
801032ea:	eb 01                	jmp    801032ed <ioapicinit+0xb4>
ioapicinit(void)
{
  int i, id, maxintr;

  if(!ismp)
    return;
801032ec:	90                   	nop
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
    ioapicwrite(REG_TABLE+2*i+1, 0);
  }
}
801032ed:	c9                   	leave  
801032ee:	c3                   	ret    

801032ef <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
801032ef:	55                   	push   %ebp
801032f0:	89 e5                	mov    %esp,%ebp
  if(!ismp)
801032f2:	a1 64 38 11 80       	mov    0x80113864,%eax
801032f7:	85 c0                	test   %eax,%eax
801032f9:	74 39                	je     80103334 <ioapicenable+0x45>
    return;

  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
801032fb:	8b 45 08             	mov    0x8(%ebp),%eax
801032fe:	83 c0 20             	add    $0x20,%eax
80103301:	89 c2                	mov    %eax,%edx
80103303:	8b 45 08             	mov    0x8(%ebp),%eax
80103306:	83 c0 08             	add    $0x8,%eax
80103309:	01 c0                	add    %eax,%eax
8010330b:	52                   	push   %edx
8010330c:	50                   	push   %eax
8010330d:	e8 0c ff ff ff       	call   8010321e <ioapicwrite>
80103312:	83 c4 08             	add    $0x8,%esp
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80103315:	8b 45 0c             	mov    0xc(%ebp),%eax
80103318:	c1 e0 18             	shl    $0x18,%eax
8010331b:	89 c2                	mov    %eax,%edx
8010331d:	8b 45 08             	mov    0x8(%ebp),%eax
80103320:	83 c0 08             	add    $0x8,%eax
80103323:	01 c0                	add    %eax,%eax
80103325:	83 c0 01             	add    $0x1,%eax
80103328:	52                   	push   %edx
80103329:	50                   	push   %eax
8010332a:	e8 ef fe ff ff       	call   8010321e <ioapicwrite>
8010332f:	83 c4 08             	add    $0x8,%esp
80103332:	eb 01                	jmp    80103335 <ioapicenable+0x46>

void
ioapicenable(int irq, int cpunum)
{
  if(!ismp)
    return;
80103334:	90                   	nop
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
}
80103335:	c9                   	leave  
80103336:	c3                   	ret    

80103337 <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
80103337:	55                   	push   %ebp
80103338:	89 e5                	mov    %esp,%ebp
8010333a:	8b 45 08             	mov    0x8(%ebp),%eax
8010333d:	05 00 00 00 80       	add    $0x80000000,%eax
80103342:	5d                   	pop    %ebp
80103343:	c3                   	ret    

80103344 <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
80103344:	55                   	push   %ebp
80103345:	89 e5                	mov    %esp,%ebp
80103347:	83 ec 08             	sub    $0x8,%esp
  initlock(&kmem.lock, "kmem");
8010334a:	83 ec 08             	sub    $0x8,%esp
8010334d:	68 06 97 10 80       	push   $0x80109706
80103352:	68 00 35 11 80       	push   $0x80113500
80103357:	e8 12 28 00 00       	call   80105b6e <initlock>
8010335c:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 0;
8010335f:	c7 05 34 35 11 80 00 	movl   $0x0,0x80113534
80103366:	00 00 00 
  freerange(vstart, vend);
80103369:	83 ec 08             	sub    $0x8,%esp
8010336c:	ff 75 0c             	pushl  0xc(%ebp)
8010336f:	ff 75 08             	pushl  0x8(%ebp)
80103372:	e8 2a 00 00 00       	call   801033a1 <freerange>
80103377:	83 c4 10             	add    $0x10,%esp
}
8010337a:	90                   	nop
8010337b:	c9                   	leave  
8010337c:	c3                   	ret    

8010337d <kinit2>:

void
kinit2(void *vstart, void *vend)
{
8010337d:	55                   	push   %ebp
8010337e:	89 e5                	mov    %esp,%ebp
80103380:	83 ec 08             	sub    $0x8,%esp
  freerange(vstart, vend);
80103383:	83 ec 08             	sub    $0x8,%esp
80103386:	ff 75 0c             	pushl  0xc(%ebp)
80103389:	ff 75 08             	pushl  0x8(%ebp)
8010338c:	e8 10 00 00 00       	call   801033a1 <freerange>
80103391:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 1;
80103394:	c7 05 34 35 11 80 01 	movl   $0x1,0x80113534
8010339b:	00 00 00 
}
8010339e:	90                   	nop
8010339f:	c9                   	leave  
801033a0:	c3                   	ret    

801033a1 <freerange>:

void
freerange(void *vstart, void *vend)
{
801033a1:	55                   	push   %ebp
801033a2:	89 e5                	mov    %esp,%ebp
801033a4:	83 ec 18             	sub    $0x18,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
801033a7:	8b 45 08             	mov    0x8(%ebp),%eax
801033aa:	05 ff 0f 00 00       	add    $0xfff,%eax
801033af:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801033b4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
801033b7:	eb 15                	jmp    801033ce <freerange+0x2d>
    kfree(p);
801033b9:	83 ec 0c             	sub    $0xc,%esp
801033bc:	ff 75 f4             	pushl  -0xc(%ebp)
801033bf:	e8 1a 00 00 00       	call   801033de <kfree>
801033c4:	83 c4 10             	add    $0x10,%esp
void
freerange(void *vstart, void *vend)
{
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
801033c7:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801033ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801033d1:	05 00 10 00 00       	add    $0x1000,%eax
801033d6:	3b 45 0c             	cmp    0xc(%ebp),%eax
801033d9:	76 de                	jbe    801033b9 <freerange+0x18>
    kfree(p);
}
801033db:	90                   	nop
801033dc:	c9                   	leave  
801033dd:	c3                   	ret    

801033de <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
801033de:	55                   	push   %ebp
801033df:	89 e5                	mov    %esp,%ebp
801033e1:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || v2p(v) >= PHYSTOP)
801033e4:	8b 45 08             	mov    0x8(%ebp),%eax
801033e7:	25 ff 0f 00 00       	and    $0xfff,%eax
801033ec:	85 c0                	test   %eax,%eax
801033ee:	75 1b                	jne    8010340b <kfree+0x2d>
801033f0:	81 7d 08 5c 66 11 80 	cmpl   $0x8011665c,0x8(%ebp)
801033f7:	72 12                	jb     8010340b <kfree+0x2d>
801033f9:	ff 75 08             	pushl  0x8(%ebp)
801033fc:	e8 36 ff ff ff       	call   80103337 <v2p>
80103401:	83 c4 04             	add    $0x4,%esp
80103404:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80103409:	76 0d                	jbe    80103418 <kfree+0x3a>
    panic("kfree");
8010340b:	83 ec 0c             	sub    $0xc,%esp
8010340e:	68 0b 97 10 80       	push   $0x8010970b
80103413:	e8 4e d1 ff ff       	call   80100566 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80103418:	83 ec 04             	sub    $0x4,%esp
8010341b:	68 00 10 00 00       	push   $0x1000
80103420:	6a 01                	push   $0x1
80103422:	ff 75 08             	pushl  0x8(%ebp)
80103425:	e8 c9 29 00 00       	call   80105df3 <memset>
8010342a:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
8010342d:	a1 34 35 11 80       	mov    0x80113534,%eax
80103432:	85 c0                	test   %eax,%eax
80103434:	74 10                	je     80103446 <kfree+0x68>
    acquire(&kmem.lock);
80103436:	83 ec 0c             	sub    $0xc,%esp
80103439:	68 00 35 11 80       	push   $0x80113500
8010343e:	e8 4d 27 00 00       	call   80105b90 <acquire>
80103443:	83 c4 10             	add    $0x10,%esp
  r = (struct run*)v;
80103446:	8b 45 08             	mov    0x8(%ebp),%eax
80103449:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
8010344c:	8b 15 38 35 11 80    	mov    0x80113538,%edx
80103452:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103455:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80103457:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010345a:	a3 38 35 11 80       	mov    %eax,0x80113538
  if(kmem.use_lock)
8010345f:	a1 34 35 11 80       	mov    0x80113534,%eax
80103464:	85 c0                	test   %eax,%eax
80103466:	74 10                	je     80103478 <kfree+0x9a>
    release(&kmem.lock);
80103468:	83 ec 0c             	sub    $0xc,%esp
8010346b:	68 00 35 11 80       	push   $0x80113500
80103470:	e8 82 27 00 00       	call   80105bf7 <release>
80103475:	83 c4 10             	add    $0x10,%esp
}
80103478:	90                   	nop
80103479:	c9                   	leave  
8010347a:	c3                   	ret    

8010347b <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
8010347b:	55                   	push   %ebp
8010347c:	89 e5                	mov    %esp,%ebp
8010347e:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if(kmem.use_lock)
80103481:	a1 34 35 11 80       	mov    0x80113534,%eax
80103486:	85 c0                	test   %eax,%eax
80103488:	74 10                	je     8010349a <kalloc+0x1f>
    acquire(&kmem.lock);
8010348a:	83 ec 0c             	sub    $0xc,%esp
8010348d:	68 00 35 11 80       	push   $0x80113500
80103492:	e8 f9 26 00 00       	call   80105b90 <acquire>
80103497:	83 c4 10             	add    $0x10,%esp
  r = kmem.freelist;
8010349a:	a1 38 35 11 80       	mov    0x80113538,%eax
8010349f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
801034a2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801034a6:	74 0a                	je     801034b2 <kalloc+0x37>
    kmem.freelist = r->next;
801034a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801034ab:	8b 00                	mov    (%eax),%eax
801034ad:	a3 38 35 11 80       	mov    %eax,0x80113538
  if(kmem.use_lock)
801034b2:	a1 34 35 11 80       	mov    0x80113534,%eax
801034b7:	85 c0                	test   %eax,%eax
801034b9:	74 10                	je     801034cb <kalloc+0x50>
    release(&kmem.lock);
801034bb:	83 ec 0c             	sub    $0xc,%esp
801034be:	68 00 35 11 80       	push   $0x80113500
801034c3:	e8 2f 27 00 00       	call   80105bf7 <release>
801034c8:	83 c4 10             	add    $0x10,%esp
  return (char*)r;
801034cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801034ce:	c9                   	leave  
801034cf:	c3                   	ret    

801034d0 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801034d0:	55                   	push   %ebp
801034d1:	89 e5                	mov    %esp,%ebp
801034d3:	83 ec 14             	sub    $0x14,%esp
801034d6:	8b 45 08             	mov    0x8(%ebp),%eax
801034d9:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801034dd:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801034e1:	89 c2                	mov    %eax,%edx
801034e3:	ec                   	in     (%dx),%al
801034e4:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801034e7:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801034eb:	c9                   	leave  
801034ec:	c3                   	ret    

801034ed <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
801034ed:	55                   	push   %ebp
801034ee:	89 e5                	mov    %esp,%ebp
801034f0:	83 ec 10             	sub    $0x10,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
801034f3:	6a 64                	push   $0x64
801034f5:	e8 d6 ff ff ff       	call   801034d0 <inb>
801034fa:	83 c4 04             	add    $0x4,%esp
801034fd:	0f b6 c0             	movzbl %al,%eax
80103500:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80103503:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103506:	83 e0 01             	and    $0x1,%eax
80103509:	85 c0                	test   %eax,%eax
8010350b:	75 0a                	jne    80103517 <kbdgetc+0x2a>
    return -1;
8010350d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103512:	e9 23 01 00 00       	jmp    8010363a <kbdgetc+0x14d>
  data = inb(KBDATAP);
80103517:	6a 60                	push   $0x60
80103519:	e8 b2 ff ff ff       	call   801034d0 <inb>
8010351e:	83 c4 04             	add    $0x4,%esp
80103521:	0f b6 c0             	movzbl %al,%eax
80103524:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
80103527:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
8010352e:	75 17                	jne    80103547 <kbdgetc+0x5a>
    shift |= E0ESC;
80103530:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80103535:	83 c8 40             	or     $0x40,%eax
80103538:	a3 3c c6 10 80       	mov    %eax,0x8010c63c
    return 0;
8010353d:	b8 00 00 00 00       	mov    $0x0,%eax
80103542:	e9 f3 00 00 00       	jmp    8010363a <kbdgetc+0x14d>
  } else if(data & 0x80){
80103547:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010354a:	25 80 00 00 00       	and    $0x80,%eax
8010354f:	85 c0                	test   %eax,%eax
80103551:	74 45                	je     80103598 <kbdgetc+0xab>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80103553:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80103558:	83 e0 40             	and    $0x40,%eax
8010355b:	85 c0                	test   %eax,%eax
8010355d:	75 08                	jne    80103567 <kbdgetc+0x7a>
8010355f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103562:	83 e0 7f             	and    $0x7f,%eax
80103565:	eb 03                	jmp    8010356a <kbdgetc+0x7d>
80103567:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010356a:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
8010356d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103570:	05 40 a0 10 80       	add    $0x8010a040,%eax
80103575:	0f b6 00             	movzbl (%eax),%eax
80103578:	83 c8 40             	or     $0x40,%eax
8010357b:	0f b6 c0             	movzbl %al,%eax
8010357e:	f7 d0                	not    %eax
80103580:	89 c2                	mov    %eax,%edx
80103582:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80103587:	21 d0                	and    %edx,%eax
80103589:	a3 3c c6 10 80       	mov    %eax,0x8010c63c
    return 0;
8010358e:	b8 00 00 00 00       	mov    $0x0,%eax
80103593:	e9 a2 00 00 00       	jmp    8010363a <kbdgetc+0x14d>
  } else if(shift & E0ESC){
80103598:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
8010359d:	83 e0 40             	and    $0x40,%eax
801035a0:	85 c0                	test   %eax,%eax
801035a2:	74 14                	je     801035b8 <kbdgetc+0xcb>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
801035a4:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
801035ab:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
801035b0:	83 e0 bf             	and    $0xffffffbf,%eax
801035b3:	a3 3c c6 10 80       	mov    %eax,0x8010c63c
  }

  shift |= shiftcode[data];
801035b8:	8b 45 fc             	mov    -0x4(%ebp),%eax
801035bb:	05 40 a0 10 80       	add    $0x8010a040,%eax
801035c0:	0f b6 00             	movzbl (%eax),%eax
801035c3:	0f b6 d0             	movzbl %al,%edx
801035c6:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
801035cb:	09 d0                	or     %edx,%eax
801035cd:	a3 3c c6 10 80       	mov    %eax,0x8010c63c
  shift ^= togglecode[data];
801035d2:	8b 45 fc             	mov    -0x4(%ebp),%eax
801035d5:	05 40 a1 10 80       	add    $0x8010a140,%eax
801035da:	0f b6 00             	movzbl (%eax),%eax
801035dd:	0f b6 d0             	movzbl %al,%edx
801035e0:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
801035e5:	31 d0                	xor    %edx,%eax
801035e7:	a3 3c c6 10 80       	mov    %eax,0x8010c63c
  c = charcode[shift & (CTL | SHIFT)][data];
801035ec:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
801035f1:	83 e0 03             	and    $0x3,%eax
801035f4:	8b 14 85 40 a5 10 80 	mov    -0x7fef5ac0(,%eax,4),%edx
801035fb:	8b 45 fc             	mov    -0x4(%ebp),%eax
801035fe:	01 d0                	add    %edx,%eax
80103600:	0f b6 00             	movzbl (%eax),%eax
80103603:	0f b6 c0             	movzbl %al,%eax
80103606:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80103609:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
8010360e:	83 e0 08             	and    $0x8,%eax
80103611:	85 c0                	test   %eax,%eax
80103613:	74 22                	je     80103637 <kbdgetc+0x14a>
    if('a' <= c && c <= 'z')
80103615:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80103619:	76 0c                	jbe    80103627 <kbdgetc+0x13a>
8010361b:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
8010361f:	77 06                	ja     80103627 <kbdgetc+0x13a>
      c += 'A' - 'a';
80103621:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80103625:	eb 10                	jmp    80103637 <kbdgetc+0x14a>
    else if('A' <= c && c <= 'Z')
80103627:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
8010362b:	76 0a                	jbe    80103637 <kbdgetc+0x14a>
8010362d:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80103631:	77 04                	ja     80103637 <kbdgetc+0x14a>
      c += 'a' - 'A';
80103633:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
80103637:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
8010363a:	c9                   	leave  
8010363b:	c3                   	ret    

8010363c <kbdintr>:

void
kbdintr(void)
{
8010363c:	55                   	push   %ebp
8010363d:	89 e5                	mov    %esp,%ebp
8010363f:	83 ec 08             	sub    $0x8,%esp
  consoleintr(kbdgetc);
80103642:	83 ec 0c             	sub    $0xc,%esp
80103645:	68 ed 34 10 80       	push   $0x801034ed
8010364a:	e8 aa d1 ff ff       	call   801007f9 <consoleintr>
8010364f:	83 c4 10             	add    $0x10,%esp
}
80103652:	90                   	nop
80103653:	c9                   	leave  
80103654:	c3                   	ret    

80103655 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80103655:	55                   	push   %ebp
80103656:	89 e5                	mov    %esp,%ebp
80103658:	83 ec 14             	sub    $0x14,%esp
8010365b:	8b 45 08             	mov    0x8(%ebp),%eax
8010365e:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80103662:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80103666:	89 c2                	mov    %eax,%edx
80103668:	ec                   	in     (%dx),%al
80103669:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
8010366c:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80103670:	c9                   	leave  
80103671:	c3                   	ret    

80103672 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103672:	55                   	push   %ebp
80103673:	89 e5                	mov    %esp,%ebp
80103675:	83 ec 08             	sub    $0x8,%esp
80103678:	8b 55 08             	mov    0x8(%ebp),%edx
8010367b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010367e:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103682:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103685:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103689:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010368d:	ee                   	out    %al,(%dx)
}
8010368e:	90                   	nop
8010368f:	c9                   	leave  
80103690:	c3                   	ret    

80103691 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80103691:	55                   	push   %ebp
80103692:	89 e5                	mov    %esp,%ebp
80103694:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80103697:	9c                   	pushf  
80103698:	58                   	pop    %eax
80103699:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
8010369c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010369f:	c9                   	leave  
801036a0:	c3                   	ret    

801036a1 <lapicw>:

volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
801036a1:	55                   	push   %ebp
801036a2:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
801036a4:	a1 3c 35 11 80       	mov    0x8011353c,%eax
801036a9:	8b 55 08             	mov    0x8(%ebp),%edx
801036ac:	c1 e2 02             	shl    $0x2,%edx
801036af:	01 c2                	add    %eax,%edx
801036b1:	8b 45 0c             	mov    0xc(%ebp),%eax
801036b4:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
801036b6:	a1 3c 35 11 80       	mov    0x8011353c,%eax
801036bb:	83 c0 20             	add    $0x20,%eax
801036be:	8b 00                	mov    (%eax),%eax
}
801036c0:	90                   	nop
801036c1:	5d                   	pop    %ebp
801036c2:	c3                   	ret    

801036c3 <lapicinit>:
//PAGEBREAK!

void
lapicinit(void)
{
801036c3:	55                   	push   %ebp
801036c4:	89 e5                	mov    %esp,%ebp
  if(!lapic) 
801036c6:	a1 3c 35 11 80       	mov    0x8011353c,%eax
801036cb:	85 c0                	test   %eax,%eax
801036cd:	0f 84 0b 01 00 00    	je     801037de <lapicinit+0x11b>
    return;

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
801036d3:	68 3f 01 00 00       	push   $0x13f
801036d8:	6a 3c                	push   $0x3c
801036da:	e8 c2 ff ff ff       	call   801036a1 <lapicw>
801036df:	83 c4 08             	add    $0x8,%esp

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.  
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
801036e2:	6a 0b                	push   $0xb
801036e4:	68 f8 00 00 00       	push   $0xf8
801036e9:	e8 b3 ff ff ff       	call   801036a1 <lapicw>
801036ee:	83 c4 08             	add    $0x8,%esp
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
801036f1:	68 20 00 02 00       	push   $0x20020
801036f6:	68 c8 00 00 00       	push   $0xc8
801036fb:	e8 a1 ff ff ff       	call   801036a1 <lapicw>
80103700:	83 c4 08             	add    $0x8,%esp
  lapicw(TICR, 10000000); 
80103703:	68 80 96 98 00       	push   $0x989680
80103708:	68 e0 00 00 00       	push   $0xe0
8010370d:	e8 8f ff ff ff       	call   801036a1 <lapicw>
80103712:	83 c4 08             	add    $0x8,%esp

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
80103715:	68 00 00 01 00       	push   $0x10000
8010371a:	68 d4 00 00 00       	push   $0xd4
8010371f:	e8 7d ff ff ff       	call   801036a1 <lapicw>
80103724:	83 c4 08             	add    $0x8,%esp
  lapicw(LINT1, MASKED);
80103727:	68 00 00 01 00       	push   $0x10000
8010372c:	68 d8 00 00 00       	push   $0xd8
80103731:	e8 6b ff ff ff       	call   801036a1 <lapicw>
80103736:	83 c4 08             	add    $0x8,%esp

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80103739:	a1 3c 35 11 80       	mov    0x8011353c,%eax
8010373e:	83 c0 30             	add    $0x30,%eax
80103741:	8b 00                	mov    (%eax),%eax
80103743:	c1 e8 10             	shr    $0x10,%eax
80103746:	0f b6 c0             	movzbl %al,%eax
80103749:	83 f8 03             	cmp    $0x3,%eax
8010374c:	76 12                	jbe    80103760 <lapicinit+0x9d>
    lapicw(PCINT, MASKED);
8010374e:	68 00 00 01 00       	push   $0x10000
80103753:	68 d0 00 00 00       	push   $0xd0
80103758:	e8 44 ff ff ff       	call   801036a1 <lapicw>
8010375d:	83 c4 08             	add    $0x8,%esp

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80103760:	6a 33                	push   $0x33
80103762:	68 dc 00 00 00       	push   $0xdc
80103767:	e8 35 ff ff ff       	call   801036a1 <lapicw>
8010376c:	83 c4 08             	add    $0x8,%esp

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
8010376f:	6a 00                	push   $0x0
80103771:	68 a0 00 00 00       	push   $0xa0
80103776:	e8 26 ff ff ff       	call   801036a1 <lapicw>
8010377b:	83 c4 08             	add    $0x8,%esp
  lapicw(ESR, 0);
8010377e:	6a 00                	push   $0x0
80103780:	68 a0 00 00 00       	push   $0xa0
80103785:	e8 17 ff ff ff       	call   801036a1 <lapicw>
8010378a:	83 c4 08             	add    $0x8,%esp

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
8010378d:	6a 00                	push   $0x0
8010378f:	6a 2c                	push   $0x2c
80103791:	e8 0b ff ff ff       	call   801036a1 <lapicw>
80103796:	83 c4 08             	add    $0x8,%esp

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
80103799:	6a 00                	push   $0x0
8010379b:	68 c4 00 00 00       	push   $0xc4
801037a0:	e8 fc fe ff ff       	call   801036a1 <lapicw>
801037a5:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, BCAST | INIT | LEVEL);
801037a8:	68 00 85 08 00       	push   $0x88500
801037ad:	68 c0 00 00 00       	push   $0xc0
801037b2:	e8 ea fe ff ff       	call   801036a1 <lapicw>
801037b7:	83 c4 08             	add    $0x8,%esp
  while(lapic[ICRLO] & DELIVS)
801037ba:	90                   	nop
801037bb:	a1 3c 35 11 80       	mov    0x8011353c,%eax
801037c0:	05 00 03 00 00       	add    $0x300,%eax
801037c5:	8b 00                	mov    (%eax),%eax
801037c7:	25 00 10 00 00       	and    $0x1000,%eax
801037cc:	85 c0                	test   %eax,%eax
801037ce:	75 eb                	jne    801037bb <lapicinit+0xf8>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
801037d0:	6a 00                	push   $0x0
801037d2:	6a 20                	push   $0x20
801037d4:	e8 c8 fe ff ff       	call   801036a1 <lapicw>
801037d9:	83 c4 08             	add    $0x8,%esp
801037dc:	eb 01                	jmp    801037df <lapicinit+0x11c>

void
lapicinit(void)
{
  if(!lapic) 
    return;
801037de:	90                   	nop
  while(lapic[ICRLO] & DELIVS)
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
}
801037df:	c9                   	leave  
801037e0:	c3                   	ret    

801037e1 <cpunum>:

int
cpunum(void)
{
801037e1:	55                   	push   %ebp
801037e2:	89 e5                	mov    %esp,%ebp
801037e4:	83 ec 08             	sub    $0x8,%esp
  // Cannot call cpu when interrupts are enabled:
  // result not guaranteed to last long enough to be used!
  // Would prefer to panic but even printing is chancy here:
  // almost everything, including cprintf and panic, calls cpu,
  // often indirectly through acquire and release.
  if(readeflags()&FL_IF){
801037e7:	e8 a5 fe ff ff       	call   80103691 <readeflags>
801037ec:	25 00 02 00 00       	and    $0x200,%eax
801037f1:	85 c0                	test   %eax,%eax
801037f3:	74 26                	je     8010381b <cpunum+0x3a>
    static int n;
    if(n++ == 0)
801037f5:	a1 40 c6 10 80       	mov    0x8010c640,%eax
801037fa:	8d 50 01             	lea    0x1(%eax),%edx
801037fd:	89 15 40 c6 10 80    	mov    %edx,0x8010c640
80103803:	85 c0                	test   %eax,%eax
80103805:	75 14                	jne    8010381b <cpunum+0x3a>
      cprintf("cpu called from %x with interrupts enabled\n",
80103807:	8b 45 04             	mov    0x4(%ebp),%eax
8010380a:	83 ec 08             	sub    $0x8,%esp
8010380d:	50                   	push   %eax
8010380e:	68 14 97 10 80       	push   $0x80109714
80103813:	e8 ae cb ff ff       	call   801003c6 <cprintf>
80103818:	83 c4 10             	add    $0x10,%esp
        __builtin_return_address(0));
  }

  if(lapic)
8010381b:	a1 3c 35 11 80       	mov    0x8011353c,%eax
80103820:	85 c0                	test   %eax,%eax
80103822:	74 0f                	je     80103833 <cpunum+0x52>
    return lapic[ID]>>24;
80103824:	a1 3c 35 11 80       	mov    0x8011353c,%eax
80103829:	83 c0 20             	add    $0x20,%eax
8010382c:	8b 00                	mov    (%eax),%eax
8010382e:	c1 e8 18             	shr    $0x18,%eax
80103831:	eb 05                	jmp    80103838 <cpunum+0x57>
  return 0;
80103833:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103838:	c9                   	leave  
80103839:	c3                   	ret    

8010383a <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
8010383a:	55                   	push   %ebp
8010383b:	89 e5                	mov    %esp,%ebp
  if(lapic)
8010383d:	a1 3c 35 11 80       	mov    0x8011353c,%eax
80103842:	85 c0                	test   %eax,%eax
80103844:	74 0c                	je     80103852 <lapiceoi+0x18>
    lapicw(EOI, 0);
80103846:	6a 00                	push   $0x0
80103848:	6a 2c                	push   $0x2c
8010384a:	e8 52 fe ff ff       	call   801036a1 <lapicw>
8010384f:	83 c4 08             	add    $0x8,%esp
}
80103852:	90                   	nop
80103853:	c9                   	leave  
80103854:	c3                   	ret    

80103855 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
80103855:	55                   	push   %ebp
80103856:	89 e5                	mov    %esp,%ebp
}
80103858:	90                   	nop
80103859:	5d                   	pop    %ebp
8010385a:	c3                   	ret    

8010385b <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
8010385b:	55                   	push   %ebp
8010385c:	89 e5                	mov    %esp,%ebp
8010385e:	83 ec 14             	sub    $0x14,%esp
80103861:	8b 45 08             	mov    0x8(%ebp),%eax
80103864:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;
  
  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
80103867:	6a 0f                	push   $0xf
80103869:	6a 70                	push   $0x70
8010386b:	e8 02 fe ff ff       	call   80103672 <outb>
80103870:	83 c4 08             	add    $0x8,%esp
  outb(CMOS_PORT+1, 0x0A);
80103873:	6a 0a                	push   $0xa
80103875:	6a 71                	push   $0x71
80103877:	e8 f6 fd ff ff       	call   80103672 <outb>
8010387c:	83 c4 08             	add    $0x8,%esp
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
8010387f:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
80103886:	8b 45 f8             	mov    -0x8(%ebp),%eax
80103889:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
8010388e:	8b 45 f8             	mov    -0x8(%ebp),%eax
80103891:	83 c0 02             	add    $0x2,%eax
80103894:	8b 55 0c             	mov    0xc(%ebp),%edx
80103897:	c1 ea 04             	shr    $0x4,%edx
8010389a:	66 89 10             	mov    %dx,(%eax)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
8010389d:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
801038a1:	c1 e0 18             	shl    $0x18,%eax
801038a4:	50                   	push   %eax
801038a5:	68 c4 00 00 00       	push   $0xc4
801038aa:	e8 f2 fd ff ff       	call   801036a1 <lapicw>
801038af:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
801038b2:	68 00 c5 00 00       	push   $0xc500
801038b7:	68 c0 00 00 00       	push   $0xc0
801038bc:	e8 e0 fd ff ff       	call   801036a1 <lapicw>
801038c1:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
801038c4:	68 c8 00 00 00       	push   $0xc8
801038c9:	e8 87 ff ff ff       	call   80103855 <microdelay>
801038ce:	83 c4 04             	add    $0x4,%esp
  lapicw(ICRLO, INIT | LEVEL);
801038d1:	68 00 85 00 00       	push   $0x8500
801038d6:	68 c0 00 00 00       	push   $0xc0
801038db:	e8 c1 fd ff ff       	call   801036a1 <lapicw>
801038e0:	83 c4 08             	add    $0x8,%esp
  microdelay(100);    // should be 10ms, but too slow in Bochs!
801038e3:	6a 64                	push   $0x64
801038e5:	e8 6b ff ff ff       	call   80103855 <microdelay>
801038ea:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
801038ed:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801038f4:	eb 3d                	jmp    80103933 <lapicstartap+0xd8>
    lapicw(ICRHI, apicid<<24);
801038f6:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
801038fa:	c1 e0 18             	shl    $0x18,%eax
801038fd:	50                   	push   %eax
801038fe:	68 c4 00 00 00       	push   $0xc4
80103903:	e8 99 fd ff ff       	call   801036a1 <lapicw>
80103908:	83 c4 08             	add    $0x8,%esp
    lapicw(ICRLO, STARTUP | (addr>>12));
8010390b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010390e:	c1 e8 0c             	shr    $0xc,%eax
80103911:	80 cc 06             	or     $0x6,%ah
80103914:	50                   	push   %eax
80103915:	68 c0 00 00 00       	push   $0xc0
8010391a:	e8 82 fd ff ff       	call   801036a1 <lapicw>
8010391f:	83 c4 08             	add    $0x8,%esp
    microdelay(200);
80103922:	68 c8 00 00 00       	push   $0xc8
80103927:	e8 29 ff ff ff       	call   80103855 <microdelay>
8010392c:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
8010392f:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80103933:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
80103937:	7e bd                	jle    801038f6 <lapicstartap+0x9b>
    lapicw(ICRHI, apicid<<24);
    lapicw(ICRLO, STARTUP | (addr>>12));
    microdelay(200);
  }
}
80103939:	90                   	nop
8010393a:	c9                   	leave  
8010393b:	c3                   	ret    

8010393c <cmos_read>:
#define DAY     0x07
#define MONTH   0x08
#define YEAR    0x09

static uint cmos_read(uint reg)
{
8010393c:	55                   	push   %ebp
8010393d:	89 e5                	mov    %esp,%ebp
  outb(CMOS_PORT,  reg);
8010393f:	8b 45 08             	mov    0x8(%ebp),%eax
80103942:	0f b6 c0             	movzbl %al,%eax
80103945:	50                   	push   %eax
80103946:	6a 70                	push   $0x70
80103948:	e8 25 fd ff ff       	call   80103672 <outb>
8010394d:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
80103950:	68 c8 00 00 00       	push   $0xc8
80103955:	e8 fb fe ff ff       	call   80103855 <microdelay>
8010395a:	83 c4 04             	add    $0x4,%esp

  return inb(CMOS_RETURN);
8010395d:	6a 71                	push   $0x71
8010395f:	e8 f1 fc ff ff       	call   80103655 <inb>
80103964:	83 c4 04             	add    $0x4,%esp
80103967:	0f b6 c0             	movzbl %al,%eax
}
8010396a:	c9                   	leave  
8010396b:	c3                   	ret    

8010396c <fill_rtcdate>:

static void fill_rtcdate(struct rtcdate *r)
{
8010396c:	55                   	push   %ebp
8010396d:	89 e5                	mov    %esp,%ebp
  r->second = cmos_read(SECS);
8010396f:	6a 00                	push   $0x0
80103971:	e8 c6 ff ff ff       	call   8010393c <cmos_read>
80103976:	83 c4 04             	add    $0x4,%esp
80103979:	89 c2                	mov    %eax,%edx
8010397b:	8b 45 08             	mov    0x8(%ebp),%eax
8010397e:	89 10                	mov    %edx,(%eax)
  r->minute = cmos_read(MINS);
80103980:	6a 02                	push   $0x2
80103982:	e8 b5 ff ff ff       	call   8010393c <cmos_read>
80103987:	83 c4 04             	add    $0x4,%esp
8010398a:	89 c2                	mov    %eax,%edx
8010398c:	8b 45 08             	mov    0x8(%ebp),%eax
8010398f:	89 50 04             	mov    %edx,0x4(%eax)
  r->hour   = cmos_read(HOURS);
80103992:	6a 04                	push   $0x4
80103994:	e8 a3 ff ff ff       	call   8010393c <cmos_read>
80103999:	83 c4 04             	add    $0x4,%esp
8010399c:	89 c2                	mov    %eax,%edx
8010399e:	8b 45 08             	mov    0x8(%ebp),%eax
801039a1:	89 50 08             	mov    %edx,0x8(%eax)
  r->day    = cmos_read(DAY);
801039a4:	6a 07                	push   $0x7
801039a6:	e8 91 ff ff ff       	call   8010393c <cmos_read>
801039ab:	83 c4 04             	add    $0x4,%esp
801039ae:	89 c2                	mov    %eax,%edx
801039b0:	8b 45 08             	mov    0x8(%ebp),%eax
801039b3:	89 50 0c             	mov    %edx,0xc(%eax)
  r->month  = cmos_read(MONTH);
801039b6:	6a 08                	push   $0x8
801039b8:	e8 7f ff ff ff       	call   8010393c <cmos_read>
801039bd:	83 c4 04             	add    $0x4,%esp
801039c0:	89 c2                	mov    %eax,%edx
801039c2:	8b 45 08             	mov    0x8(%ebp),%eax
801039c5:	89 50 10             	mov    %edx,0x10(%eax)
  r->year   = cmos_read(YEAR);
801039c8:	6a 09                	push   $0x9
801039ca:	e8 6d ff ff ff       	call   8010393c <cmos_read>
801039cf:	83 c4 04             	add    $0x4,%esp
801039d2:	89 c2                	mov    %eax,%edx
801039d4:	8b 45 08             	mov    0x8(%ebp),%eax
801039d7:	89 50 14             	mov    %edx,0x14(%eax)
}
801039da:	90                   	nop
801039db:	c9                   	leave  
801039dc:	c3                   	ret    

801039dd <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
801039dd:	55                   	push   %ebp
801039de:	89 e5                	mov    %esp,%ebp
801039e0:	83 ec 48             	sub    $0x48,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
801039e3:	6a 0b                	push   $0xb
801039e5:	e8 52 ff ff ff       	call   8010393c <cmos_read>
801039ea:	83 c4 04             	add    $0x4,%esp
801039ed:	89 45 f4             	mov    %eax,-0xc(%ebp)

  bcd = (sb & (1 << 2)) == 0;
801039f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039f3:	83 e0 04             	and    $0x4,%eax
801039f6:	85 c0                	test   %eax,%eax
801039f8:	0f 94 c0             	sete   %al
801039fb:	0f b6 c0             	movzbl %al,%eax
801039fe:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for (;;) {
    fill_rtcdate(&t1);
80103a01:	8d 45 d8             	lea    -0x28(%ebp),%eax
80103a04:	50                   	push   %eax
80103a05:	e8 62 ff ff ff       	call   8010396c <fill_rtcdate>
80103a0a:	83 c4 04             	add    $0x4,%esp
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
80103a0d:	6a 0a                	push   $0xa
80103a0f:	e8 28 ff ff ff       	call   8010393c <cmos_read>
80103a14:	83 c4 04             	add    $0x4,%esp
80103a17:	25 80 00 00 00       	and    $0x80,%eax
80103a1c:	85 c0                	test   %eax,%eax
80103a1e:	75 27                	jne    80103a47 <cmostime+0x6a>
        continue;
    fill_rtcdate(&t2);
80103a20:	8d 45 c0             	lea    -0x40(%ebp),%eax
80103a23:	50                   	push   %eax
80103a24:	e8 43 ff ff ff       	call   8010396c <fill_rtcdate>
80103a29:	83 c4 04             	add    $0x4,%esp
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
80103a2c:	83 ec 04             	sub    $0x4,%esp
80103a2f:	6a 18                	push   $0x18
80103a31:	8d 45 c0             	lea    -0x40(%ebp),%eax
80103a34:	50                   	push   %eax
80103a35:	8d 45 d8             	lea    -0x28(%ebp),%eax
80103a38:	50                   	push   %eax
80103a39:	e8 1c 24 00 00       	call   80105e5a <memcmp>
80103a3e:	83 c4 10             	add    $0x10,%esp
80103a41:	85 c0                	test   %eax,%eax
80103a43:	74 05                	je     80103a4a <cmostime+0x6d>
80103a45:	eb ba                	jmp    80103a01 <cmostime+0x24>

  // make sure CMOS doesn't modify time while we read it
  for (;;) {
    fill_rtcdate(&t1);
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
        continue;
80103a47:	90                   	nop
    fill_rtcdate(&t2);
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
      break;
  }
80103a48:	eb b7                	jmp    80103a01 <cmostime+0x24>
    fill_rtcdate(&t1);
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
        continue;
    fill_rtcdate(&t2);
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
      break;
80103a4a:	90                   	nop
  }

  // convert
  if (bcd) {
80103a4b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103a4f:	0f 84 b4 00 00 00    	je     80103b09 <cmostime+0x12c>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
80103a55:	8b 45 d8             	mov    -0x28(%ebp),%eax
80103a58:	c1 e8 04             	shr    $0x4,%eax
80103a5b:	89 c2                	mov    %eax,%edx
80103a5d:	89 d0                	mov    %edx,%eax
80103a5f:	c1 e0 02             	shl    $0x2,%eax
80103a62:	01 d0                	add    %edx,%eax
80103a64:	01 c0                	add    %eax,%eax
80103a66:	89 c2                	mov    %eax,%edx
80103a68:	8b 45 d8             	mov    -0x28(%ebp),%eax
80103a6b:	83 e0 0f             	and    $0xf,%eax
80103a6e:	01 d0                	add    %edx,%eax
80103a70:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(minute);
80103a73:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103a76:	c1 e8 04             	shr    $0x4,%eax
80103a79:	89 c2                	mov    %eax,%edx
80103a7b:	89 d0                	mov    %edx,%eax
80103a7d:	c1 e0 02             	shl    $0x2,%eax
80103a80:	01 d0                	add    %edx,%eax
80103a82:	01 c0                	add    %eax,%eax
80103a84:	89 c2                	mov    %eax,%edx
80103a86:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103a89:	83 e0 0f             	and    $0xf,%eax
80103a8c:	01 d0                	add    %edx,%eax
80103a8e:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(hour  );
80103a91:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103a94:	c1 e8 04             	shr    $0x4,%eax
80103a97:	89 c2                	mov    %eax,%edx
80103a99:	89 d0                	mov    %edx,%eax
80103a9b:	c1 e0 02             	shl    $0x2,%eax
80103a9e:	01 d0                	add    %edx,%eax
80103aa0:	01 c0                	add    %eax,%eax
80103aa2:	89 c2                	mov    %eax,%edx
80103aa4:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103aa7:	83 e0 0f             	and    $0xf,%eax
80103aaa:	01 d0                	add    %edx,%eax
80103aac:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(day   );
80103aaf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103ab2:	c1 e8 04             	shr    $0x4,%eax
80103ab5:	89 c2                	mov    %eax,%edx
80103ab7:	89 d0                	mov    %edx,%eax
80103ab9:	c1 e0 02             	shl    $0x2,%eax
80103abc:	01 d0                	add    %edx,%eax
80103abe:	01 c0                	add    %eax,%eax
80103ac0:	89 c2                	mov    %eax,%edx
80103ac2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103ac5:	83 e0 0f             	and    $0xf,%eax
80103ac8:	01 d0                	add    %edx,%eax
80103aca:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    CONV(month );
80103acd:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103ad0:	c1 e8 04             	shr    $0x4,%eax
80103ad3:	89 c2                	mov    %eax,%edx
80103ad5:	89 d0                	mov    %edx,%eax
80103ad7:	c1 e0 02             	shl    $0x2,%eax
80103ada:	01 d0                	add    %edx,%eax
80103adc:	01 c0                	add    %eax,%eax
80103ade:	89 c2                	mov    %eax,%edx
80103ae0:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103ae3:	83 e0 0f             	and    $0xf,%eax
80103ae6:	01 d0                	add    %edx,%eax
80103ae8:	89 45 e8             	mov    %eax,-0x18(%ebp)
    CONV(year  );
80103aeb:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103aee:	c1 e8 04             	shr    $0x4,%eax
80103af1:	89 c2                	mov    %eax,%edx
80103af3:	89 d0                	mov    %edx,%eax
80103af5:	c1 e0 02             	shl    $0x2,%eax
80103af8:	01 d0                	add    %edx,%eax
80103afa:	01 c0                	add    %eax,%eax
80103afc:	89 c2                	mov    %eax,%edx
80103afe:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103b01:	83 e0 0f             	and    $0xf,%eax
80103b04:	01 d0                	add    %edx,%eax
80103b06:	89 45 ec             	mov    %eax,-0x14(%ebp)
#undef     CONV
  }

  *r = t1;
80103b09:	8b 45 08             	mov    0x8(%ebp),%eax
80103b0c:	8b 55 d8             	mov    -0x28(%ebp),%edx
80103b0f:	89 10                	mov    %edx,(%eax)
80103b11:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103b14:	89 50 04             	mov    %edx,0x4(%eax)
80103b17:	8b 55 e0             	mov    -0x20(%ebp),%edx
80103b1a:	89 50 08             	mov    %edx,0x8(%eax)
80103b1d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103b20:	89 50 0c             	mov    %edx,0xc(%eax)
80103b23:	8b 55 e8             	mov    -0x18(%ebp),%edx
80103b26:	89 50 10             	mov    %edx,0x10(%eax)
80103b29:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103b2c:	89 50 14             	mov    %edx,0x14(%eax)
  r->year += 2000;
80103b2f:	8b 45 08             	mov    0x8(%ebp),%eax
80103b32:	8b 40 14             	mov    0x14(%eax),%eax
80103b35:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
80103b3b:	8b 45 08             	mov    0x8(%ebp),%eax
80103b3e:	89 50 14             	mov    %edx,0x14(%eax)
}
80103b41:	90                   	nop
80103b42:	c9                   	leave  
80103b43:	c3                   	ret    

80103b44 <initlog>:
static void recover_from_log(uint partitionNumber);
static void commit(uint partitionNumber);

void
initlog(int dev)
{
80103b44:	55                   	push   %ebp
80103b45:	89 e5                	mov    %esp,%ebp
80103b47:	83 ec 18             	sub    $0x18,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");
    int i;
for(i=0;i<NPARTITIONS;i++){
80103b4a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103b51:	e9 b1 00 00 00       	jmp    80103c07 <initlog+0xc3>
    if(mbrI.partitions[i].size > 0){
80103b56:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b59:	83 c0 1b             	add    $0x1b,%eax
80103b5c:	c1 e0 04             	shl    $0x4,%eax
80103b5f:	05 00 18 11 80       	add    $0x80111800,%eax
80103b64:	8b 40 1a             	mov    0x1a(%eax),%eax
80103b67:	85 c0                	test   %eax,%eax
80103b69:	0f 84 94 00 00 00    	je     80103c03 <initlog+0xbf>
        initlock(&logs[i].lock, "log");
80103b6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b72:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103b78:	05 40 35 11 80       	add    $0x80113540,%eax
80103b7d:	83 ec 08             	sub    $0x8,%esp
80103b80:	68 40 97 10 80       	push   $0x80109740
80103b85:	50                   	push   %eax
80103b86:	e8 e3 1f 00 00       	call   80105b6e <initlock>
80103b8b:	83 c4 10             	add    $0x10,%esp
 // readsb(dev, partitionNumber);
  logs[i].start = sbs[i].offset+sbs[i].logstart;
80103b8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b91:	c1 e0 05             	shl    $0x5,%eax
80103b94:	05 70 d6 10 80       	add    $0x8010d670,%eax
80103b99:	8b 50 0c             	mov    0xc(%eax),%edx
80103b9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b9f:	c1 e0 05             	shl    $0x5,%eax
80103ba2:	05 70 d6 10 80       	add    $0x8010d670,%eax
80103ba7:	8b 00                	mov    (%eax),%eax
80103ba9:	01 d0                	add    %edx,%eax
80103bab:	89 c2                	mov    %eax,%edx
80103bad:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bb0:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103bb6:	05 70 35 11 80       	add    $0x80113570,%eax
80103bbb:	89 50 04             	mov    %edx,0x4(%eax)
  logs[i].size =  sbs[i].nlog;
80103bbe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bc1:	c1 e0 05             	shl    $0x5,%eax
80103bc4:	05 60 d6 10 80       	add    $0x8010d660,%eax
80103bc9:	8b 40 0c             	mov    0xc(%eax),%eax
80103bcc:	89 c2                	mov    %eax,%edx
80103bce:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bd1:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103bd7:	05 70 35 11 80       	add    $0x80113570,%eax
80103bdc:	89 50 08             	mov    %edx,0x8(%eax)
  logs[i].dev = dev;
80103bdf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103be2:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103be8:	8d 90 80 35 11 80    	lea    -0x7feeca80(%eax),%edx
80103bee:	8b 45 08             	mov    0x8(%ebp),%eax
80103bf1:	89 42 04             	mov    %eax,0x4(%edx)
  recover_from_log(i);
80103bf4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bf7:	83 ec 0c             	sub    $0xc,%esp
80103bfa:	50                   	push   %eax
80103bfb:	e8 6a 02 00 00       	call   80103e6a <recover_from_log>
80103c00:	83 c4 10             	add    $0x10,%esp
initlog(int dev)
{
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");
    int i;
for(i=0;i<NPARTITIONS;i++){
80103c03:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103c07:	83 7d f4 03          	cmpl   $0x3,-0xc(%ebp)
80103c0b:	0f 8e 45 ff ff ff    	jle    80103b56 <initlog+0x12>
  recover_from_log(i);
    }
     
}
 
}
80103c11:	90                   	nop
80103c12:	c9                   	leave  
80103c13:	c3                   	ret    

80103c14 <install_trans>:

// Copy committed blocks from log to their home location
static void 
install_trans(uint partitionNumber)
{
80103c14:	55                   	push   %ebp
80103c15:	89 e5                	mov    %esp,%ebp
80103c17:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < logs[partitionNumber].lh.n; tail++) {
80103c1a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103c21:	e9 c0 00 00 00       	jmp    80103ce6 <install_trans+0xd2>
    struct buf *lbuf = bread(logs[partitionNumber].dev, logs[partitionNumber].start+tail+1); // read log block
80103c26:	8b 45 08             	mov    0x8(%ebp),%eax
80103c29:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103c2f:	05 70 35 11 80       	add    $0x80113570,%eax
80103c34:	8b 50 04             	mov    0x4(%eax),%edx
80103c37:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c3a:	01 d0                	add    %edx,%eax
80103c3c:	83 c0 01             	add    $0x1,%eax
80103c3f:	89 c2                	mov    %eax,%edx
80103c41:	8b 45 08             	mov    0x8(%ebp),%eax
80103c44:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103c4a:	05 80 35 11 80       	add    $0x80113580,%eax
80103c4f:	8b 40 04             	mov    0x4(%eax),%eax
80103c52:	83 ec 08             	sub    $0x8,%esp
80103c55:	52                   	push   %edx
80103c56:	50                   	push   %eax
80103c57:	e8 5a c5 ff ff       	call   801001b6 <bread>
80103c5c:	83 c4 10             	add    $0x10,%esp
80103c5f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(logs[partitionNumber].dev, logs[partitionNumber].lh.block[tail]); // read dst
80103c62:	8b 45 08             	mov    0x8(%ebp),%eax
80103c65:	6b d0 31             	imul   $0x31,%eax,%edx
80103c68:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c6b:	01 d0                	add    %edx,%eax
80103c6d:	83 c0 10             	add    $0x10,%eax
80103c70:	8b 04 85 4c 35 11 80 	mov    -0x7feecab4(,%eax,4),%eax
80103c77:	89 c2                	mov    %eax,%edx
80103c79:	8b 45 08             	mov    0x8(%ebp),%eax
80103c7c:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103c82:	05 80 35 11 80       	add    $0x80113580,%eax
80103c87:	8b 40 04             	mov    0x4(%eax),%eax
80103c8a:	83 ec 08             	sub    $0x8,%esp
80103c8d:	52                   	push   %edx
80103c8e:	50                   	push   %eax
80103c8f:	e8 22 c5 ff ff       	call   801001b6 <bread>
80103c94:	83 c4 10             	add    $0x10,%esp
80103c97:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
80103c9a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c9d:	8d 50 18             	lea    0x18(%eax),%edx
80103ca0:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103ca3:	83 c0 18             	add    $0x18,%eax
80103ca6:	83 ec 04             	sub    $0x4,%esp
80103ca9:	68 00 02 00 00       	push   $0x200
80103cae:	52                   	push   %edx
80103caf:	50                   	push   %eax
80103cb0:	e8 fd 21 00 00       	call   80105eb2 <memmove>
80103cb5:	83 c4 10             	add    $0x10,%esp
    bwrite(dbuf);  // write dst to disk
80103cb8:	83 ec 0c             	sub    $0xc,%esp
80103cbb:	ff 75 ec             	pushl  -0x14(%ebp)
80103cbe:	e8 2c c5 ff ff       	call   801001ef <bwrite>
80103cc3:	83 c4 10             	add    $0x10,%esp
    brelse(lbuf); 
80103cc6:	83 ec 0c             	sub    $0xc,%esp
80103cc9:	ff 75 f0             	pushl  -0x10(%ebp)
80103ccc:	e8 5d c5 ff ff       	call   8010022e <brelse>
80103cd1:	83 c4 10             	add    $0x10,%esp
    brelse(dbuf);
80103cd4:	83 ec 0c             	sub    $0xc,%esp
80103cd7:	ff 75 ec             	pushl  -0x14(%ebp)
80103cda:	e8 4f c5 ff ff       	call   8010022e <brelse>
80103cdf:	83 c4 10             	add    $0x10,%esp
static void 
install_trans(uint partitionNumber)
{
  int tail;

  for (tail = 0; tail < logs[partitionNumber].lh.n; tail++) {
80103ce2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103ce6:	8b 45 08             	mov    0x8(%ebp),%eax
80103ce9:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103cef:	05 80 35 11 80       	add    $0x80113580,%eax
80103cf4:	8b 40 08             	mov    0x8(%eax),%eax
80103cf7:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103cfa:	0f 8f 26 ff ff ff    	jg     80103c26 <install_trans+0x12>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    bwrite(dbuf);  // write dst to disk
    brelse(lbuf); 
    brelse(dbuf);
  }
}
80103d00:	90                   	nop
80103d01:	c9                   	leave  
80103d02:	c3                   	ret    

80103d03 <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(uint partitionNumber)
{
80103d03:	55                   	push   %ebp
80103d04:	89 e5                	mov    %esp,%ebp
80103d06:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(logs[partitionNumber].dev, logs[partitionNumber].start);
80103d09:	8b 45 08             	mov    0x8(%ebp),%eax
80103d0c:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103d12:	05 70 35 11 80       	add    $0x80113570,%eax
80103d17:	8b 40 04             	mov    0x4(%eax),%eax
80103d1a:	89 c2                	mov    %eax,%edx
80103d1c:	8b 45 08             	mov    0x8(%ebp),%eax
80103d1f:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103d25:	05 80 35 11 80       	add    $0x80113580,%eax
80103d2a:	8b 40 04             	mov    0x4(%eax),%eax
80103d2d:	83 ec 08             	sub    $0x8,%esp
80103d30:	52                   	push   %edx
80103d31:	50                   	push   %eax
80103d32:	e8 7f c4 ff ff       	call   801001b6 <bread>
80103d37:	83 c4 10             	add    $0x10,%esp
80103d3a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
80103d3d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d40:	83 c0 18             	add    $0x18,%eax
80103d43:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  logs[partitionNumber].lh.n = lh->n;
80103d46:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103d49:	8b 00                	mov    (%eax),%eax
80103d4b:	8b 55 08             	mov    0x8(%ebp),%edx
80103d4e:	69 d2 c4 00 00 00    	imul   $0xc4,%edx,%edx
80103d54:	81 c2 80 35 11 80    	add    $0x80113580,%edx
80103d5a:	89 42 08             	mov    %eax,0x8(%edx)
  for (i = 0; i < logs[partitionNumber].lh.n; i++) {
80103d5d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103d64:	eb 23                	jmp    80103d89 <read_head+0x86>
    logs[partitionNumber].lh.block[i] = lh->block[i];
80103d66:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103d69:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103d6c:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
80103d70:	8b 55 08             	mov    0x8(%ebp),%edx
80103d73:	6b ca 31             	imul   $0x31,%edx,%ecx
80103d76:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103d79:	01 ca                	add    %ecx,%edx
80103d7b:	83 c2 10             	add    $0x10,%edx
80103d7e:	89 04 95 4c 35 11 80 	mov    %eax,-0x7feecab4(,%edx,4)
{
  struct buf *buf = bread(logs[partitionNumber].dev, logs[partitionNumber].start);
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  logs[partitionNumber].lh.n = lh->n;
  for (i = 0; i < logs[partitionNumber].lh.n; i++) {
80103d85:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103d89:	8b 45 08             	mov    0x8(%ebp),%eax
80103d8c:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103d92:	05 80 35 11 80       	add    $0x80113580,%eax
80103d97:	8b 40 08             	mov    0x8(%eax),%eax
80103d9a:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103d9d:	7f c7                	jg     80103d66 <read_head+0x63>
    logs[partitionNumber].lh.block[i] = lh->block[i];
  }
  brelse(buf);
80103d9f:	83 ec 0c             	sub    $0xc,%esp
80103da2:	ff 75 f0             	pushl  -0x10(%ebp)
80103da5:	e8 84 c4 ff ff       	call   8010022e <brelse>
80103daa:	83 c4 10             	add    $0x10,%esp
}
80103dad:	90                   	nop
80103dae:	c9                   	leave  
80103daf:	c3                   	ret    

80103db0 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(uint partitionNumber)
{
80103db0:	55                   	push   %ebp
80103db1:	89 e5                	mov    %esp,%ebp
80103db3:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(logs[partitionNumber].dev, logs[partitionNumber].start);
80103db6:	8b 45 08             	mov    0x8(%ebp),%eax
80103db9:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103dbf:	05 70 35 11 80       	add    $0x80113570,%eax
80103dc4:	8b 40 04             	mov    0x4(%eax),%eax
80103dc7:	89 c2                	mov    %eax,%edx
80103dc9:	8b 45 08             	mov    0x8(%ebp),%eax
80103dcc:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103dd2:	05 80 35 11 80       	add    $0x80113580,%eax
80103dd7:	8b 40 04             	mov    0x4(%eax),%eax
80103dda:	83 ec 08             	sub    $0x8,%esp
80103ddd:	52                   	push   %edx
80103dde:	50                   	push   %eax
80103ddf:	e8 d2 c3 ff ff       	call   801001b6 <bread>
80103de4:	83 c4 10             	add    $0x10,%esp
80103de7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
80103dea:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ded:	83 c0 18             	add    $0x18,%eax
80103df0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = logs[partitionNumber].lh.n;
80103df3:	8b 45 08             	mov    0x8(%ebp),%eax
80103df6:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103dfc:	05 80 35 11 80       	add    $0x80113580,%eax
80103e01:	8b 50 08             	mov    0x8(%eax),%edx
80103e04:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103e07:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < logs[partitionNumber].lh.n; i++) {
80103e09:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103e10:	eb 23                	jmp    80103e35 <write_head+0x85>
    hb->block[i] = logs[partitionNumber].lh.block[i];
80103e12:	8b 45 08             	mov    0x8(%ebp),%eax
80103e15:	6b d0 31             	imul   $0x31,%eax,%edx
80103e18:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e1b:	01 d0                	add    %edx,%eax
80103e1d:	83 c0 10             	add    $0x10,%eax
80103e20:	8b 0c 85 4c 35 11 80 	mov    -0x7feecab4(,%eax,4),%ecx
80103e27:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103e2a:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103e2d:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
{
  struct buf *buf = bread(logs[partitionNumber].dev, logs[partitionNumber].start);
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = logs[partitionNumber].lh.n;
  for (i = 0; i < logs[partitionNumber].lh.n; i++) {
80103e31:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103e35:	8b 45 08             	mov    0x8(%ebp),%eax
80103e38:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103e3e:	05 80 35 11 80       	add    $0x80113580,%eax
80103e43:	8b 40 08             	mov    0x8(%eax),%eax
80103e46:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103e49:	7f c7                	jg     80103e12 <write_head+0x62>
    hb->block[i] = logs[partitionNumber].lh.block[i];
  }
  bwrite(buf);
80103e4b:	83 ec 0c             	sub    $0xc,%esp
80103e4e:	ff 75 f0             	pushl  -0x10(%ebp)
80103e51:	e8 99 c3 ff ff       	call   801001ef <bwrite>
80103e56:	83 c4 10             	add    $0x10,%esp
  brelse(buf);
80103e59:	83 ec 0c             	sub    $0xc,%esp
80103e5c:	ff 75 f0             	pushl  -0x10(%ebp)
80103e5f:	e8 ca c3 ff ff       	call   8010022e <brelse>
80103e64:	83 c4 10             	add    $0x10,%esp
}
80103e67:	90                   	nop
80103e68:	c9                   	leave  
80103e69:	c3                   	ret    

80103e6a <recover_from_log>:

static void
recover_from_log(uint partitionNumber)
{
80103e6a:	55                   	push   %ebp
80103e6b:	89 e5                	mov    %esp,%ebp
80103e6d:	83 ec 08             	sub    $0x8,%esp
  read_head(partitionNumber);      
80103e70:	83 ec 0c             	sub    $0xc,%esp
80103e73:	ff 75 08             	pushl  0x8(%ebp)
80103e76:	e8 88 fe ff ff       	call   80103d03 <read_head>
80103e7b:	83 c4 10             	add    $0x10,%esp
  install_trans(partitionNumber); // if committed, copy from log to disk
80103e7e:	83 ec 0c             	sub    $0xc,%esp
80103e81:	ff 75 08             	pushl  0x8(%ebp)
80103e84:	e8 8b fd ff ff       	call   80103c14 <install_trans>
80103e89:	83 c4 10             	add    $0x10,%esp
  logs[partitionNumber].lh.n = 0;
80103e8c:	8b 45 08             	mov    0x8(%ebp),%eax
80103e8f:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103e95:	05 80 35 11 80       	add    $0x80113580,%eax
80103e9a:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  write_head(partitionNumber); // clear the log
80103ea1:	83 ec 0c             	sub    $0xc,%esp
80103ea4:	ff 75 08             	pushl  0x8(%ebp)
80103ea7:	e8 04 ff ff ff       	call   80103db0 <write_head>
80103eac:	83 c4 10             	add    $0x10,%esp
}
80103eaf:	90                   	nop
80103eb0:	c9                   	leave  
80103eb1:	c3                   	ret    

80103eb2 <begin_op>:

// called at the start of each FS system call.
void
begin_op(uint partitionNumber)
{
80103eb2:	55                   	push   %ebp
80103eb3:	89 e5                	mov    %esp,%ebp
80103eb5:	83 ec 08             	sub    $0x8,%esp
  acquire(&logs[partitionNumber].lock);
80103eb8:	8b 45 08             	mov    0x8(%ebp),%eax
80103ebb:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103ec1:	05 40 35 11 80       	add    $0x80113540,%eax
80103ec6:	83 ec 0c             	sub    $0xc,%esp
80103ec9:	50                   	push   %eax
80103eca:	e8 c1 1c 00 00       	call   80105b90 <acquire>
80103ecf:	83 c4 10             	add    $0x10,%esp
  while(1){
    if(logs[partitionNumber].committing){
80103ed2:	8b 45 08             	mov    0x8(%ebp),%eax
80103ed5:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103edb:	05 80 35 11 80       	add    $0x80113580,%eax
80103ee0:	8b 00                	mov    (%eax),%eax
80103ee2:	85 c0                	test   %eax,%eax
80103ee4:	74 2c                	je     80103f12 <begin_op+0x60>
      sleep(&logs[partitionNumber], &logs[partitionNumber].lock);
80103ee6:	8b 45 08             	mov    0x8(%ebp),%eax
80103ee9:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103eef:	8d 90 40 35 11 80    	lea    -0x7feecac0(%eax),%edx
80103ef5:	8b 45 08             	mov    0x8(%ebp),%eax
80103ef8:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103efe:	05 40 35 11 80       	add    $0x80113540,%eax
80103f03:	83 ec 08             	sub    $0x8,%esp
80103f06:	52                   	push   %edx
80103f07:	50                   	push   %eax
80103f08:	e8 8a 19 00 00       	call   80105897 <sleep>
80103f0d:	83 c4 10             	add    $0x10,%esp
80103f10:	eb c0                	jmp    80103ed2 <begin_op+0x20>
    } else if(logs[partitionNumber].lh.n + (logs[partitionNumber].outstanding+1)*MAXOPBLOCKS > LOGSIZE){
80103f12:	8b 45 08             	mov    0x8(%ebp),%eax
80103f15:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103f1b:	05 80 35 11 80       	add    $0x80113580,%eax
80103f20:	8b 48 08             	mov    0x8(%eax),%ecx
80103f23:	8b 45 08             	mov    0x8(%ebp),%eax
80103f26:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103f2c:	05 70 35 11 80       	add    $0x80113570,%eax
80103f31:	8b 40 0c             	mov    0xc(%eax),%eax
80103f34:	8d 50 01             	lea    0x1(%eax),%edx
80103f37:	89 d0                	mov    %edx,%eax
80103f39:	c1 e0 02             	shl    $0x2,%eax
80103f3c:	01 d0                	add    %edx,%eax
80103f3e:	01 c0                	add    %eax,%eax
80103f40:	01 c8                	add    %ecx,%eax
80103f42:	83 f8 1e             	cmp    $0x1e,%eax
80103f45:	7e 2f                	jle    80103f76 <begin_op+0xc4>
      // this op might exhaust log space; wait for commit.
      sleep(&logs[partitionNumber], &logs[partitionNumber].lock);
80103f47:	8b 45 08             	mov    0x8(%ebp),%eax
80103f4a:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103f50:	8d 90 40 35 11 80    	lea    -0x7feecac0(%eax),%edx
80103f56:	8b 45 08             	mov    0x8(%ebp),%eax
80103f59:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103f5f:	05 40 35 11 80       	add    $0x80113540,%eax
80103f64:	83 ec 08             	sub    $0x8,%esp
80103f67:	52                   	push   %edx
80103f68:	50                   	push   %eax
80103f69:	e8 29 19 00 00       	call   80105897 <sleep>
80103f6e:	83 c4 10             	add    $0x10,%esp
80103f71:	e9 5c ff ff ff       	jmp    80103ed2 <begin_op+0x20>
    } else {
      logs[partitionNumber].outstanding += 1;
80103f76:	8b 45 08             	mov    0x8(%ebp),%eax
80103f79:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103f7f:	05 70 35 11 80       	add    $0x80113570,%eax
80103f84:	8b 40 0c             	mov    0xc(%eax),%eax
80103f87:	8d 50 01             	lea    0x1(%eax),%edx
80103f8a:	8b 45 08             	mov    0x8(%ebp),%eax
80103f8d:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103f93:	05 70 35 11 80       	add    $0x80113570,%eax
80103f98:	89 50 0c             	mov    %edx,0xc(%eax)
      release(&logs[partitionNumber].lock);
80103f9b:	8b 45 08             	mov    0x8(%ebp),%eax
80103f9e:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103fa4:	05 40 35 11 80       	add    $0x80113540,%eax
80103fa9:	83 ec 0c             	sub    $0xc,%esp
80103fac:	50                   	push   %eax
80103fad:	e8 45 1c 00 00       	call   80105bf7 <release>
80103fb2:	83 c4 10             	add    $0x10,%esp
      break;
80103fb5:	90                   	nop
    }
  }
}
80103fb6:	90                   	nop
80103fb7:	c9                   	leave  
80103fb8:	c3                   	ret    

80103fb9 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(uint partitionNumber)
{
80103fb9:	55                   	push   %ebp
80103fba:	89 e5                	mov    %esp,%ebp
80103fbc:	83 ec 18             	sub    $0x18,%esp
  int do_commit = 0;
80103fbf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&logs[partitionNumber].lock);
80103fc6:	8b 45 08             	mov    0x8(%ebp),%eax
80103fc9:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103fcf:	05 40 35 11 80       	add    $0x80113540,%eax
80103fd4:	83 ec 0c             	sub    $0xc,%esp
80103fd7:	50                   	push   %eax
80103fd8:	e8 b3 1b 00 00       	call   80105b90 <acquire>
80103fdd:	83 c4 10             	add    $0x10,%esp
  logs[partitionNumber].outstanding -= 1;
80103fe0:	8b 45 08             	mov    0x8(%ebp),%eax
80103fe3:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103fe9:	05 70 35 11 80       	add    $0x80113570,%eax
80103fee:	8b 40 0c             	mov    0xc(%eax),%eax
80103ff1:	8d 50 ff             	lea    -0x1(%eax),%edx
80103ff4:	8b 45 08             	mov    0x8(%ebp),%eax
80103ff7:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80103ffd:	05 70 35 11 80       	add    $0x80113570,%eax
80104002:	89 50 0c             	mov    %edx,0xc(%eax)
  if(logs[partitionNumber].committing)
80104005:	8b 45 08             	mov    0x8(%ebp),%eax
80104008:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
8010400e:	05 80 35 11 80       	add    $0x80113580,%eax
80104013:	8b 00                	mov    (%eax),%eax
80104015:	85 c0                	test   %eax,%eax
80104017:	74 0d                	je     80104026 <end_op+0x6d>
    panic("log.committing");
80104019:	83 ec 0c             	sub    $0xc,%esp
8010401c:	68 44 97 10 80       	push   $0x80109744
80104021:	e8 40 c5 ff ff       	call   80100566 <panic>
  if(logs[partitionNumber].outstanding == 0){
80104026:	8b 45 08             	mov    0x8(%ebp),%eax
80104029:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
8010402f:	05 70 35 11 80       	add    $0x80113570,%eax
80104034:	8b 40 0c             	mov    0xc(%eax),%eax
80104037:	85 c0                	test   %eax,%eax
80104039:	75 1d                	jne    80104058 <end_op+0x9f>
    do_commit = 1;
8010403b:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    logs[partitionNumber].committing = 1;
80104042:	8b 45 08             	mov    0x8(%ebp),%eax
80104045:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
8010404b:	05 80 35 11 80       	add    $0x80113580,%eax
80104050:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
80104056:	eb 1a                	jmp    80104072 <end_op+0xb9>
  } else {
    // begin_op() may be waiting for log space.
    wakeup(&logs[partitionNumber]);
80104058:	8b 45 08             	mov    0x8(%ebp),%eax
8010405b:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80104061:	05 40 35 11 80       	add    $0x80113540,%eax
80104066:	83 ec 0c             	sub    $0xc,%esp
80104069:	50                   	push   %eax
8010406a:	e8 13 19 00 00       	call   80105982 <wakeup>
8010406f:	83 c4 10             	add    $0x10,%esp
  }
  release(&logs[partitionNumber].lock);
80104072:	8b 45 08             	mov    0x8(%ebp),%eax
80104075:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
8010407b:	05 40 35 11 80       	add    $0x80113540,%eax
80104080:	83 ec 0c             	sub    $0xc,%esp
80104083:	50                   	push   %eax
80104084:	e8 6e 1b 00 00       	call   80105bf7 <release>
80104089:	83 c4 10             	add    $0x10,%esp

  if(do_commit){
8010408c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104090:	74 70                	je     80104102 <end_op+0x149>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit(partitionNumber);
80104092:	83 ec 0c             	sub    $0xc,%esp
80104095:	ff 75 08             	pushl  0x8(%ebp)
80104098:	e8 57 01 00 00       	call   801041f4 <commit>
8010409d:	83 c4 10             	add    $0x10,%esp
    acquire(&logs[partitionNumber].lock);
801040a0:	8b 45 08             	mov    0x8(%ebp),%eax
801040a3:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
801040a9:	05 40 35 11 80       	add    $0x80113540,%eax
801040ae:	83 ec 0c             	sub    $0xc,%esp
801040b1:	50                   	push   %eax
801040b2:	e8 d9 1a 00 00       	call   80105b90 <acquire>
801040b7:	83 c4 10             	add    $0x10,%esp
    logs[partitionNumber].committing = 0;
801040ba:	8b 45 08             	mov    0x8(%ebp),%eax
801040bd:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
801040c3:	05 80 35 11 80       	add    $0x80113580,%eax
801040c8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    wakeup(&logs[partitionNumber]);
801040ce:	8b 45 08             	mov    0x8(%ebp),%eax
801040d1:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
801040d7:	05 40 35 11 80       	add    $0x80113540,%eax
801040dc:	83 ec 0c             	sub    $0xc,%esp
801040df:	50                   	push   %eax
801040e0:	e8 9d 18 00 00       	call   80105982 <wakeup>
801040e5:	83 c4 10             	add    $0x10,%esp
    release(&logs[partitionNumber].lock);
801040e8:	8b 45 08             	mov    0x8(%ebp),%eax
801040eb:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
801040f1:	05 40 35 11 80       	add    $0x80113540,%eax
801040f6:	83 ec 0c             	sub    $0xc,%esp
801040f9:	50                   	push   %eax
801040fa:	e8 f8 1a 00 00       	call   80105bf7 <release>
801040ff:	83 c4 10             	add    $0x10,%esp
  }
}
80104102:	90                   	nop
80104103:	c9                   	leave  
80104104:	c3                   	ret    

80104105 <write_log>:

// Copy modified blocks from cache to log.
static void 
write_log(uint partitionNumber)
{
80104105:	55                   	push   %ebp
80104106:	89 e5                	mov    %esp,%ebp
80104108:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < logs[partitionNumber].lh.n; tail++) {
8010410b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104112:	e9 c0 00 00 00       	jmp    801041d7 <write_log+0xd2>
    struct buf *to = bread(logs[partitionNumber].dev, logs[partitionNumber].start+tail+1); // log block
80104117:	8b 45 08             	mov    0x8(%ebp),%eax
8010411a:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80104120:	05 70 35 11 80       	add    $0x80113570,%eax
80104125:	8b 50 04             	mov    0x4(%eax),%edx
80104128:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010412b:	01 d0                	add    %edx,%eax
8010412d:	83 c0 01             	add    $0x1,%eax
80104130:	89 c2                	mov    %eax,%edx
80104132:	8b 45 08             	mov    0x8(%ebp),%eax
80104135:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
8010413b:	05 80 35 11 80       	add    $0x80113580,%eax
80104140:	8b 40 04             	mov    0x4(%eax),%eax
80104143:	83 ec 08             	sub    $0x8,%esp
80104146:	52                   	push   %edx
80104147:	50                   	push   %eax
80104148:	e8 69 c0 ff ff       	call   801001b6 <bread>
8010414d:	83 c4 10             	add    $0x10,%esp
80104150:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(logs[partitionNumber].dev, logs[partitionNumber].lh.block[tail]); // cache block
80104153:	8b 45 08             	mov    0x8(%ebp),%eax
80104156:	6b d0 31             	imul   $0x31,%eax,%edx
80104159:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010415c:	01 d0                	add    %edx,%eax
8010415e:	83 c0 10             	add    $0x10,%eax
80104161:	8b 04 85 4c 35 11 80 	mov    -0x7feecab4(,%eax,4),%eax
80104168:	89 c2                	mov    %eax,%edx
8010416a:	8b 45 08             	mov    0x8(%ebp),%eax
8010416d:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80104173:	05 80 35 11 80       	add    $0x80113580,%eax
80104178:	8b 40 04             	mov    0x4(%eax),%eax
8010417b:	83 ec 08             	sub    $0x8,%esp
8010417e:	52                   	push   %edx
8010417f:	50                   	push   %eax
80104180:	e8 31 c0 ff ff       	call   801001b6 <bread>
80104185:	83 c4 10             	add    $0x10,%esp
80104188:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
8010418b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010418e:	8d 50 18             	lea    0x18(%eax),%edx
80104191:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104194:	83 c0 18             	add    $0x18,%eax
80104197:	83 ec 04             	sub    $0x4,%esp
8010419a:	68 00 02 00 00       	push   $0x200
8010419f:	52                   	push   %edx
801041a0:	50                   	push   %eax
801041a1:	e8 0c 1d 00 00       	call   80105eb2 <memmove>
801041a6:	83 c4 10             	add    $0x10,%esp
    bwrite(to);  // write the log
801041a9:	83 ec 0c             	sub    $0xc,%esp
801041ac:	ff 75 f0             	pushl  -0x10(%ebp)
801041af:	e8 3b c0 ff ff       	call   801001ef <bwrite>
801041b4:	83 c4 10             	add    $0x10,%esp
    brelse(from); 
801041b7:	83 ec 0c             	sub    $0xc,%esp
801041ba:	ff 75 ec             	pushl  -0x14(%ebp)
801041bd:	e8 6c c0 ff ff       	call   8010022e <brelse>
801041c2:	83 c4 10             	add    $0x10,%esp
    brelse(to);
801041c5:	83 ec 0c             	sub    $0xc,%esp
801041c8:	ff 75 f0             	pushl  -0x10(%ebp)
801041cb:	e8 5e c0 ff ff       	call   8010022e <brelse>
801041d0:	83 c4 10             	add    $0x10,%esp
static void 
write_log(uint partitionNumber)
{
  int tail;

  for (tail = 0; tail < logs[partitionNumber].lh.n; tail++) {
801041d3:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801041d7:	8b 45 08             	mov    0x8(%ebp),%eax
801041da:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
801041e0:	05 80 35 11 80       	add    $0x80113580,%eax
801041e5:	8b 40 08             	mov    0x8(%eax),%eax
801041e8:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801041eb:	0f 8f 26 ff ff ff    	jg     80104117 <write_log+0x12>
    memmove(to->data, from->data, BSIZE);
    bwrite(to);  // write the log
    brelse(from); 
    brelse(to);
  }
}
801041f1:	90                   	nop
801041f2:	c9                   	leave  
801041f3:	c3                   	ret    

801041f4 <commit>:

static void
commit(uint partitionNumber)
{
801041f4:	55                   	push   %ebp
801041f5:	89 e5                	mov    %esp,%ebp
801041f7:	83 ec 08             	sub    $0x8,%esp
  if (logs[partitionNumber].lh.n > 0) {
801041fa:	8b 45 08             	mov    0x8(%ebp),%eax
801041fd:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80104203:	05 80 35 11 80       	add    $0x80113580,%eax
80104208:	8b 40 08             	mov    0x8(%eax),%eax
8010420b:	85 c0                	test   %eax,%eax
8010420d:	7e 4d                	jle    8010425c <commit+0x68>
    write_log(partitionNumber);     // Write modified blocks from cache to log
8010420f:	83 ec 0c             	sub    $0xc,%esp
80104212:	ff 75 08             	pushl  0x8(%ebp)
80104215:	e8 eb fe ff ff       	call   80104105 <write_log>
8010421a:	83 c4 10             	add    $0x10,%esp
    write_head(partitionNumber);    // Write header to disk -- the real commit
8010421d:	83 ec 0c             	sub    $0xc,%esp
80104220:	ff 75 08             	pushl  0x8(%ebp)
80104223:	e8 88 fb ff ff       	call   80103db0 <write_head>
80104228:	83 c4 10             	add    $0x10,%esp
    install_trans(partitionNumber); // Now install writes to home locations
8010422b:	83 ec 0c             	sub    $0xc,%esp
8010422e:	ff 75 08             	pushl  0x8(%ebp)
80104231:	e8 de f9 ff ff       	call   80103c14 <install_trans>
80104236:	83 c4 10             	add    $0x10,%esp
    logs[partitionNumber].lh.n = 0; 
80104239:	8b 45 08             	mov    0x8(%ebp),%eax
8010423c:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80104242:	05 80 35 11 80       	add    $0x80113580,%eax
80104247:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    write_head(partitionNumber);    // Erase the transaction from the log
8010424e:	83 ec 0c             	sub    $0xc,%esp
80104251:	ff 75 08             	pushl  0x8(%ebp)
80104254:	e8 57 fb ff ff       	call   80103db0 <write_head>
80104259:	83 c4 10             	add    $0x10,%esp
  }
}
8010425c:	90                   	nop
8010425d:	c9                   	leave  
8010425e:	c3                   	ret    

8010425f <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b,uint partitionNumber)
{
8010425f:	55                   	push   %ebp
80104260:	89 e5                	mov    %esp,%ebp
80104262:	83 ec 18             	sub    $0x18,%esp
  int i;

  if (logs[partitionNumber].lh.n >= LOGSIZE || logs[partitionNumber].lh.n >= logs[partitionNumber].size - 1)
80104265:	8b 45 0c             	mov    0xc(%ebp),%eax
80104268:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
8010426e:	05 80 35 11 80       	add    $0x80113580,%eax
80104273:	8b 40 08             	mov    0x8(%eax),%eax
80104276:	83 f8 1d             	cmp    $0x1d,%eax
80104279:	7f 2a                	jg     801042a5 <log_write+0x46>
8010427b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010427e:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80104284:	05 80 35 11 80       	add    $0x80113580,%eax
80104289:	8b 40 08             	mov    0x8(%eax),%eax
8010428c:	8b 55 0c             	mov    0xc(%ebp),%edx
8010428f:	69 d2 c4 00 00 00    	imul   $0xc4,%edx,%edx
80104295:	81 c2 70 35 11 80    	add    $0x80113570,%edx
8010429b:	8b 52 08             	mov    0x8(%edx),%edx
8010429e:	83 ea 01             	sub    $0x1,%edx
801042a1:	39 d0                	cmp    %edx,%eax
801042a3:	7c 0d                	jl     801042b2 <log_write+0x53>
    panic("too big a transaction");
801042a5:	83 ec 0c             	sub    $0xc,%esp
801042a8:	68 53 97 10 80       	push   $0x80109753
801042ad:	e8 b4 c2 ff ff       	call   80100566 <panic>
  if (logs[partitionNumber].outstanding < 1)
801042b2:	8b 45 0c             	mov    0xc(%ebp),%eax
801042b5:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
801042bb:	05 70 35 11 80       	add    $0x80113570,%eax
801042c0:	8b 40 0c             	mov    0xc(%eax),%eax
801042c3:	85 c0                	test   %eax,%eax
801042c5:	7f 0d                	jg     801042d4 <log_write+0x75>
    panic("log_write outside of trans");
801042c7:	83 ec 0c             	sub    $0xc,%esp
801042ca:	68 69 97 10 80       	push   $0x80109769
801042cf:	e8 92 c2 ff ff       	call   80100566 <panic>

  acquire(&logs[partitionNumber].lock);
801042d4:	8b 45 0c             	mov    0xc(%ebp),%eax
801042d7:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
801042dd:	05 40 35 11 80       	add    $0x80113540,%eax
801042e2:	83 ec 0c             	sub    $0xc,%esp
801042e5:	50                   	push   %eax
801042e6:	e8 a5 18 00 00       	call   80105b90 <acquire>
801042eb:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < logs[partitionNumber].lh.n; i++) {
801042ee:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801042f5:	eb 25                	jmp    8010431c <log_write+0xbd>
    if (logs[partitionNumber].lh.block[i] == b->blockno)   // log absorbtion
801042f7:	8b 45 0c             	mov    0xc(%ebp),%eax
801042fa:	6b d0 31             	imul   $0x31,%eax,%edx
801042fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104300:	01 d0                	add    %edx,%eax
80104302:	83 c0 10             	add    $0x10,%eax
80104305:	8b 04 85 4c 35 11 80 	mov    -0x7feecab4(,%eax,4),%eax
8010430c:	89 c2                	mov    %eax,%edx
8010430e:	8b 45 08             	mov    0x8(%ebp),%eax
80104311:	8b 40 08             	mov    0x8(%eax),%eax
80104314:	39 c2                	cmp    %eax,%edx
80104316:	74 1c                	je     80104334 <log_write+0xd5>
    panic("too big a transaction");
  if (logs[partitionNumber].outstanding < 1)
    panic("log_write outside of trans");

  acquire(&logs[partitionNumber].lock);
  for (i = 0; i < logs[partitionNumber].lh.n; i++) {
80104318:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010431c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010431f:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80104325:	05 80 35 11 80       	add    $0x80113580,%eax
8010432a:	8b 40 08             	mov    0x8(%eax),%eax
8010432d:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80104330:	7f c5                	jg     801042f7 <log_write+0x98>
80104332:	eb 01                	jmp    80104335 <log_write+0xd6>
    if (logs[partitionNumber].lh.block[i] == b->blockno)   // log absorbtion
      break;
80104334:	90                   	nop
  }
  logs[partitionNumber].lh.block[i] = b->blockno;
80104335:	8b 45 08             	mov    0x8(%ebp),%eax
80104338:	8b 40 08             	mov    0x8(%eax),%eax
8010433b:	89 c1                	mov    %eax,%ecx
8010433d:	8b 45 0c             	mov    0xc(%ebp),%eax
80104340:	6b d0 31             	imul   $0x31,%eax,%edx
80104343:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104346:	01 d0                	add    %edx,%eax
80104348:	83 c0 10             	add    $0x10,%eax
8010434b:	89 0c 85 4c 35 11 80 	mov    %ecx,-0x7feecab4(,%eax,4)
  if (i == logs[partitionNumber].lh.n)
80104352:	8b 45 0c             	mov    0xc(%ebp),%eax
80104355:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
8010435b:	05 80 35 11 80       	add    $0x80113580,%eax
80104360:	8b 40 08             	mov    0x8(%eax),%eax
80104363:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80104366:	75 25                	jne    8010438d <log_write+0x12e>
    logs[partitionNumber].lh.n++;
80104368:	8b 45 0c             	mov    0xc(%ebp),%eax
8010436b:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80104371:	05 80 35 11 80       	add    $0x80113580,%eax
80104376:	8b 40 08             	mov    0x8(%eax),%eax
80104379:	8d 50 01             	lea    0x1(%eax),%edx
8010437c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010437f:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
80104385:	05 80 35 11 80       	add    $0x80113580,%eax
8010438a:	89 50 08             	mov    %edx,0x8(%eax)
  b->flags |= B_DIRTY; // prevent eviction
8010438d:	8b 45 08             	mov    0x8(%ebp),%eax
80104390:	8b 00                	mov    (%eax),%eax
80104392:	83 c8 04             	or     $0x4,%eax
80104395:	89 c2                	mov    %eax,%edx
80104397:	8b 45 08             	mov    0x8(%ebp),%eax
8010439a:	89 10                	mov    %edx,(%eax)
  release(&logs[partitionNumber].lock);
8010439c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010439f:	69 c0 c4 00 00 00    	imul   $0xc4,%eax,%eax
801043a5:	05 40 35 11 80       	add    $0x80113540,%eax
801043aa:	83 ec 0c             	sub    $0xc,%esp
801043ad:	50                   	push   %eax
801043ae:	e8 44 18 00 00       	call   80105bf7 <release>
801043b3:	83 c4 10             	add    $0x10,%esp
}
801043b6:	90                   	nop
801043b7:	c9                   	leave  
801043b8:	c3                   	ret    

801043b9 <v2p>:
801043b9:	55                   	push   %ebp
801043ba:	89 e5                	mov    %esp,%ebp
801043bc:	8b 45 08             	mov    0x8(%ebp),%eax
801043bf:	05 00 00 00 80       	add    $0x80000000,%eax
801043c4:	5d                   	pop    %ebp
801043c5:	c3                   	ret    

801043c6 <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
801043c6:	55                   	push   %ebp
801043c7:	89 e5                	mov    %esp,%ebp
801043c9:	8b 45 08             	mov    0x8(%ebp),%eax
801043cc:	05 00 00 00 80       	add    $0x80000000,%eax
801043d1:	5d                   	pop    %ebp
801043d2:	c3                   	ret    

801043d3 <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
801043d3:	55                   	push   %ebp
801043d4:	89 e5                	mov    %esp,%ebp
801043d6:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
801043d9:	8b 55 08             	mov    0x8(%ebp),%edx
801043dc:	8b 45 0c             	mov    0xc(%ebp),%eax
801043df:	8b 4d 08             	mov    0x8(%ebp),%ecx
801043e2:	f0 87 02             	lock xchg %eax,(%edx)
801043e5:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
801043e8:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801043eb:	c9                   	leave  
801043ec:	c3                   	ret    

801043ed <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
801043ed:	8d 4c 24 04          	lea    0x4(%esp),%ecx
801043f1:	83 e4 f0             	and    $0xfffffff0,%esp
801043f4:	ff 71 fc             	pushl  -0x4(%ecx)
801043f7:	55                   	push   %ebp
801043f8:	89 e5                	mov    %esp,%ebp
801043fa:	51                   	push   %ecx
801043fb:	83 ec 04             	sub    $0x4,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
801043fe:	83 ec 08             	sub    $0x8,%esp
80104401:	68 00 00 40 80       	push   $0x80400000
80104406:	68 5c 66 11 80       	push   $0x8011665c
8010440b:	e8 34 ef ff ff       	call   80103344 <kinit1>
80104410:	83 c4 10             	add    $0x10,%esp
  kvmalloc();      // kernel page table
80104413:	e8 69 48 00 00       	call   80108c81 <kvmalloc>
  mpinit();        // collect info about this machine
80104418:	e8 26 04 00 00       	call   80104843 <mpinit>
  lapicinit();
8010441d:	e8 a1 f2 ff ff       	call   801036c3 <lapicinit>
  seginit();       // set up segments
80104422:	e8 03 42 00 00       	call   8010862a <seginit>
 // cprintf("\ncpu%d: starting xv6\n\n", cpu->id);
  picinit();       // interrupt controller
80104427:	e8 6d 06 00 00       	call   80104a99 <picinit>
  ioapicinit();    // another interrupt controller
8010442c:	e8 08 ee ff ff       	call   80103239 <ioapicinit>
  consoleinit();   // I/O devices & their interrupts
80104431:	e8 e3 c6 ff ff       	call   80100b19 <consoleinit>
  uartinit();      // serial port
80104436:	e8 4b 35 00 00       	call   80107986 <uartinit>
  pinit();         // process table
8010443b:	e8 56 0b 00 00       	call   80104f96 <pinit>
  tvinit();        // trap vectors
80104440:	e8 0b 31 00 00       	call   80107550 <tvinit>
  binit();         // buffer cache
80104445:	e8 ea bb ff ff       	call   80100034 <binit>
 // cprintf("after b cache");
  fileinit();      // file table
8010444a:	e8 7e cb ff ff       	call   80100fcd <fileinit>
  //  cprintf("after f init");

  ideinit();       // disk
8010444f:	e8 dd e9 ff ff       	call   80102e31 <ideinit>
   //   cprintf("after ide init");

  if(!ismp)
80104454:	a1 64 38 11 80       	mov    0x80113864,%eax
80104459:	85 c0                	test   %eax,%eax
8010445b:	75 05                	jne    80104462 <main+0x75>
    timerinit();   // uniprocessor timer
8010445d:	e8 4b 30 00 00       	call   801074ad <timerinit>
  //  int a=3;
 //   if(a==4)
 startothers();   // start other processors
80104462:	e8 7f 00 00 00       	call   801044e6 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80104467:	83 ec 08             	sub    $0x8,%esp
8010446a:	68 00 00 00 8e       	push   $0x8e000000
8010446f:	68 00 00 40 80       	push   $0x80400000
80104474:	e8 04 ef ff ff       	call   8010337d <kinit2>
80104479:	83 c4 10             	add    $0x10,%esp

  userinit();      // first user process
8010447c:	e8 39 0c 00 00       	call   801050ba <userinit>
  // Finish setting up this processor in mpmain.

  mpmain();
80104481:	e8 1a 00 00 00       	call   801044a0 <mpmain>

80104486 <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
80104486:	55                   	push   %ebp
80104487:	89 e5                	mov    %esp,%ebp
80104489:	83 ec 08             	sub    $0x8,%esp
  switchkvm(); 
8010448c:	e8 08 48 00 00       	call   80108c99 <switchkvm>
  seginit();
80104491:	e8 94 41 00 00       	call   8010862a <seginit>
  lapicinit();
80104496:	e8 28 f2 ff ff       	call   801036c3 <lapicinit>
  mpmain();
8010449b:	e8 00 00 00 00       	call   801044a0 <mpmain>

801044a0 <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
801044a0:	55                   	push   %ebp
801044a1:	89 e5                	mov    %esp,%ebp
801044a3:	83 ec 08             	sub    $0x8,%esp
  cprintf("cpu%d: starting\n", cpu->id);
801044a6:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801044ac:	0f b6 00             	movzbl (%eax),%eax
801044af:	0f b6 c0             	movzbl %al,%eax
801044b2:	83 ec 08             	sub    $0x8,%esp
801044b5:	50                   	push   %eax
801044b6:	68 84 97 10 80       	push   $0x80109784
801044bb:	e8 06 bf ff ff       	call   801003c6 <cprintf>
801044c0:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
801044c3:	e8 fe 31 00 00       	call   801076c6 <idtinit>
  xchg(&cpu->started, 1); // tell startothers() we're up
801044c8:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801044ce:	05 a8 00 00 00       	add    $0xa8,%eax
801044d3:	83 ec 08             	sub    $0x8,%esp
801044d6:	6a 01                	push   $0x1
801044d8:	50                   	push   %eax
801044d9:	e8 f5 fe ff ff       	call   801043d3 <xchg>
801044de:	83 c4 10             	add    $0x10,%esp
  scheduler();     // start running processes
801044e1:	e8 ab 11 00 00       	call   80105691 <scheduler>

801044e6 <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
801044e6:	55                   	push   %ebp
801044e7:	89 e5                	mov    %esp,%ebp
801044e9:	53                   	push   %ebx
801044ea:	83 ec 14             	sub    $0x14,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
801044ed:	68 00 70 00 00       	push   $0x7000
801044f2:	e8 cf fe ff ff       	call   801043c6 <p2v>
801044f7:	83 c4 04             	add    $0x4,%esp
801044fa:	89 45 f0             	mov    %eax,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
801044fd:	b8 8a 00 00 00       	mov    $0x8a,%eax
80104502:	83 ec 04             	sub    $0x4,%esp
80104505:	50                   	push   %eax
80104506:	68 0c c5 10 80       	push   $0x8010c50c
8010450b:	ff 75 f0             	pushl  -0x10(%ebp)
8010450e:	e8 9f 19 00 00       	call   80105eb2 <memmove>
80104513:	83 c4 10             	add    $0x10,%esp

  for(c = cpus; c < cpus+ncpu; c++){
80104516:	c7 45 f4 80 38 11 80 	movl   $0x80113880,-0xc(%ebp)
8010451d:	e9 90 00 00 00       	jmp    801045b2 <startothers+0xcc>
    if(c == cpus+cpunum())  // We've started already.
80104522:	e8 ba f2 ff ff       	call   801037e1 <cpunum>
80104527:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
8010452d:	05 80 38 11 80       	add    $0x80113880,%eax
80104532:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80104535:	74 73                	je     801045aa <startothers+0xc4>
      continue;

    // Tell entryother.S what stack to use, where to enter, and what 
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
80104537:	e8 3f ef ff ff       	call   8010347b <kalloc>
8010453c:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
8010453f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104542:	83 e8 04             	sub    $0x4,%eax
80104545:	8b 55 ec             	mov    -0x14(%ebp),%edx
80104548:	81 c2 00 10 00 00    	add    $0x1000,%edx
8010454e:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
80104550:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104553:	83 e8 08             	sub    $0x8,%eax
80104556:	c7 00 86 44 10 80    	movl   $0x80104486,(%eax)
    *(int**)(code-12) = (void *) v2p(entrypgdir);
8010455c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010455f:	8d 58 f4             	lea    -0xc(%eax),%ebx
80104562:	83 ec 0c             	sub    $0xc,%esp
80104565:	68 00 b0 10 80       	push   $0x8010b000
8010456a:	e8 4a fe ff ff       	call   801043b9 <v2p>
8010456f:	83 c4 10             	add    $0x10,%esp
80104572:	89 03                	mov    %eax,(%ebx)

    lapicstartap(c->id, v2p(code));
80104574:	83 ec 0c             	sub    $0xc,%esp
80104577:	ff 75 f0             	pushl  -0x10(%ebp)
8010457a:	e8 3a fe ff ff       	call   801043b9 <v2p>
8010457f:	83 c4 10             	add    $0x10,%esp
80104582:	89 c2                	mov    %eax,%edx
80104584:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104587:	0f b6 00             	movzbl (%eax),%eax
8010458a:	0f b6 c0             	movzbl %al,%eax
8010458d:	83 ec 08             	sub    $0x8,%esp
80104590:	52                   	push   %edx
80104591:	50                   	push   %eax
80104592:	e8 c4 f2 ff ff       	call   8010385b <lapicstartap>
80104597:	83 c4 10             	add    $0x10,%esp

    // wait for cpu to finish mpmain()
    while(c->started == 0)
8010459a:	90                   	nop
8010459b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010459e:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
801045a4:	85 c0                	test   %eax,%eax
801045a6:	74 f3                	je     8010459b <startothers+0xb5>
801045a8:	eb 01                	jmp    801045ab <startothers+0xc5>
  code = p2v(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
    if(c == cpus+cpunum())  // We've started already.
      continue;
801045aa:	90                   	nop
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
801045ab:	81 45 f4 bc 00 00 00 	addl   $0xbc,-0xc(%ebp)
801045b2:	a1 60 3e 11 80       	mov    0x80113e60,%eax
801045b7:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
801045bd:	05 80 38 11 80       	add    $0x80113880,%eax
801045c2:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801045c5:	0f 87 57 ff ff ff    	ja     80104522 <startothers+0x3c>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
      ;
  }
}
801045cb:	90                   	nop
801045cc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801045cf:	c9                   	leave  
801045d0:	c3                   	ret    

801045d1 <p2v>:
801045d1:	55                   	push   %ebp
801045d2:	89 e5                	mov    %esp,%ebp
801045d4:	8b 45 08             	mov    0x8(%ebp),%eax
801045d7:	05 00 00 00 80       	add    $0x80000000,%eax
801045dc:	5d                   	pop    %ebp
801045dd:	c3                   	ret    

801045de <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801045de:	55                   	push   %ebp
801045df:	89 e5                	mov    %esp,%ebp
801045e1:	83 ec 14             	sub    $0x14,%esp
801045e4:	8b 45 08             	mov    0x8(%ebp),%eax
801045e7:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801045eb:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801045ef:	89 c2                	mov    %eax,%edx
801045f1:	ec                   	in     (%dx),%al
801045f2:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801045f5:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801045f9:	c9                   	leave  
801045fa:	c3                   	ret    

801045fb <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801045fb:	55                   	push   %ebp
801045fc:	89 e5                	mov    %esp,%ebp
801045fe:	83 ec 08             	sub    $0x8,%esp
80104601:	8b 55 08             	mov    0x8(%ebp),%edx
80104604:	8b 45 0c             	mov    0xc(%ebp),%eax
80104607:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
8010460b:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010460e:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80104612:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80104616:	ee                   	out    %al,(%dx)
}
80104617:	90                   	nop
80104618:	c9                   	leave  
80104619:	c3                   	ret    

8010461a <mpbcpu>:
int ncpu;
uchar ioapicid;

int
mpbcpu(void)
{
8010461a:	55                   	push   %ebp
8010461b:	89 e5                	mov    %esp,%ebp
  return bcpu-cpus;
8010461d:	a1 44 c6 10 80       	mov    0x8010c644,%eax
80104622:	89 c2                	mov    %eax,%edx
80104624:	b8 80 38 11 80       	mov    $0x80113880,%eax
80104629:	29 c2                	sub    %eax,%edx
8010462b:	89 d0                	mov    %edx,%eax
8010462d:	c1 f8 02             	sar    $0x2,%eax
80104630:	69 c0 cf 46 7d 67    	imul   $0x677d46cf,%eax,%eax
}
80104636:	5d                   	pop    %ebp
80104637:	c3                   	ret    

80104638 <sum>:

static uchar
sum(uchar *addr, int len)
{
80104638:	55                   	push   %ebp
80104639:	89 e5                	mov    %esp,%ebp
8010463b:	83 ec 10             	sub    $0x10,%esp
  int i, sum;
  
  sum = 0;
8010463e:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(i=0; i<len; i++)
80104645:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
8010464c:	eb 15                	jmp    80104663 <sum+0x2b>
    sum += addr[i];
8010464e:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104651:	8b 45 08             	mov    0x8(%ebp),%eax
80104654:	01 d0                	add    %edx,%eax
80104656:	0f b6 00             	movzbl (%eax),%eax
80104659:	0f b6 c0             	movzbl %al,%eax
8010465c:	01 45 f8             	add    %eax,-0x8(%ebp)
sum(uchar *addr, int len)
{
  int i, sum;
  
  sum = 0;
  for(i=0; i<len; i++)
8010465f:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80104663:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104666:	3b 45 0c             	cmp    0xc(%ebp),%eax
80104669:	7c e3                	jl     8010464e <sum+0x16>
    sum += addr[i];
  return sum;
8010466b:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
8010466e:	c9                   	leave  
8010466f:	c3                   	ret    

80104670 <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80104670:	55                   	push   %ebp
80104671:	89 e5                	mov    %esp,%ebp
80104673:	83 ec 18             	sub    $0x18,%esp
  uchar *e, *p, *addr;

  addr = p2v(a);
80104676:	ff 75 08             	pushl  0x8(%ebp)
80104679:	e8 53 ff ff ff       	call   801045d1 <p2v>
8010467e:	83 c4 04             	add    $0x4,%esp
80104681:	89 45 f0             	mov    %eax,-0x10(%ebp)
  e = addr+len;
80104684:	8b 55 0c             	mov    0xc(%ebp),%edx
80104687:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010468a:	01 d0                	add    %edx,%eax
8010468c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(p = addr; p < e; p += sizeof(struct mp))
8010468f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104692:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104695:	eb 36                	jmp    801046cd <mpsearch1+0x5d>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80104697:	83 ec 04             	sub    $0x4,%esp
8010469a:	6a 04                	push   $0x4
8010469c:	68 98 97 10 80       	push   $0x80109798
801046a1:	ff 75 f4             	pushl  -0xc(%ebp)
801046a4:	e8 b1 17 00 00       	call   80105e5a <memcmp>
801046a9:	83 c4 10             	add    $0x10,%esp
801046ac:	85 c0                	test   %eax,%eax
801046ae:	75 19                	jne    801046c9 <mpsearch1+0x59>
801046b0:	83 ec 08             	sub    $0x8,%esp
801046b3:	6a 10                	push   $0x10
801046b5:	ff 75 f4             	pushl  -0xc(%ebp)
801046b8:	e8 7b ff ff ff       	call   80104638 <sum>
801046bd:	83 c4 10             	add    $0x10,%esp
801046c0:	84 c0                	test   %al,%al
801046c2:	75 05                	jne    801046c9 <mpsearch1+0x59>
      return (struct mp*)p;
801046c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046c7:	eb 11                	jmp    801046da <mpsearch1+0x6a>
{
  uchar *e, *p, *addr;

  addr = p2v(a);
  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
801046c9:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
801046cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046d0:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801046d3:	72 c2                	jb     80104697 <mpsearch1+0x27>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
      return (struct mp*)p;
  return 0;
801046d5:	b8 00 00 00 00       	mov    $0x0,%eax
}
801046da:	c9                   	leave  
801046db:	c3                   	ret    

801046dc <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
801046dc:	55                   	push   %ebp
801046dd:	89 e5                	mov    %esp,%ebp
801046df:	83 ec 18             	sub    $0x18,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
801046e2:	c7 45 f4 00 04 00 80 	movl   $0x80000400,-0xc(%ebp)
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
801046e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046ec:	83 c0 0f             	add    $0xf,%eax
801046ef:	0f b6 00             	movzbl (%eax),%eax
801046f2:	0f b6 c0             	movzbl %al,%eax
801046f5:	c1 e0 08             	shl    $0x8,%eax
801046f8:	89 c2                	mov    %eax,%edx
801046fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046fd:	83 c0 0e             	add    $0xe,%eax
80104700:	0f b6 00             	movzbl (%eax),%eax
80104703:	0f b6 c0             	movzbl %al,%eax
80104706:	09 d0                	or     %edx,%eax
80104708:	c1 e0 04             	shl    $0x4,%eax
8010470b:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010470e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104712:	74 21                	je     80104735 <mpsearch+0x59>
    if((mp = mpsearch1(p, 1024)))
80104714:	83 ec 08             	sub    $0x8,%esp
80104717:	68 00 04 00 00       	push   $0x400
8010471c:	ff 75 f0             	pushl  -0x10(%ebp)
8010471f:	e8 4c ff ff ff       	call   80104670 <mpsearch1>
80104724:	83 c4 10             	add    $0x10,%esp
80104727:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010472a:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010472e:	74 51                	je     80104781 <mpsearch+0xa5>
      return mp;
80104730:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104733:	eb 61                	jmp    80104796 <mpsearch+0xba>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80104735:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104738:	83 c0 14             	add    $0x14,%eax
8010473b:	0f b6 00             	movzbl (%eax),%eax
8010473e:	0f b6 c0             	movzbl %al,%eax
80104741:	c1 e0 08             	shl    $0x8,%eax
80104744:	89 c2                	mov    %eax,%edx
80104746:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104749:	83 c0 13             	add    $0x13,%eax
8010474c:	0f b6 00             	movzbl (%eax),%eax
8010474f:	0f b6 c0             	movzbl %al,%eax
80104752:	09 d0                	or     %edx,%eax
80104754:	c1 e0 0a             	shl    $0xa,%eax
80104757:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((mp = mpsearch1(p-1024, 1024)))
8010475a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010475d:	2d 00 04 00 00       	sub    $0x400,%eax
80104762:	83 ec 08             	sub    $0x8,%esp
80104765:	68 00 04 00 00       	push   $0x400
8010476a:	50                   	push   %eax
8010476b:	e8 00 ff ff ff       	call   80104670 <mpsearch1>
80104770:	83 c4 10             	add    $0x10,%esp
80104773:	89 45 ec             	mov    %eax,-0x14(%ebp)
80104776:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010477a:	74 05                	je     80104781 <mpsearch+0xa5>
      return mp;
8010477c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010477f:	eb 15                	jmp    80104796 <mpsearch+0xba>
  }
  return mpsearch1(0xF0000, 0x10000);
80104781:	83 ec 08             	sub    $0x8,%esp
80104784:	68 00 00 01 00       	push   $0x10000
80104789:	68 00 00 0f 00       	push   $0xf0000
8010478e:	e8 dd fe ff ff       	call   80104670 <mpsearch1>
80104793:	83 c4 10             	add    $0x10,%esp
}
80104796:	c9                   	leave  
80104797:	c3                   	ret    

80104798 <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80104798:	55                   	push   %ebp
80104799:	89 e5                	mov    %esp,%ebp
8010479b:	83 ec 18             	sub    $0x18,%esp
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
8010479e:	e8 39 ff ff ff       	call   801046dc <mpsearch>
801047a3:	89 45 f4             	mov    %eax,-0xc(%ebp)
801047a6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801047aa:	74 0a                	je     801047b6 <mpconfig+0x1e>
801047ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047af:	8b 40 04             	mov    0x4(%eax),%eax
801047b2:	85 c0                	test   %eax,%eax
801047b4:	75 0a                	jne    801047c0 <mpconfig+0x28>
    return 0;
801047b6:	b8 00 00 00 00       	mov    $0x0,%eax
801047bb:	e9 81 00 00 00       	jmp    80104841 <mpconfig+0xa9>
  conf = (struct mpconf*) p2v((uint) mp->physaddr);
801047c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047c3:	8b 40 04             	mov    0x4(%eax),%eax
801047c6:	83 ec 0c             	sub    $0xc,%esp
801047c9:	50                   	push   %eax
801047ca:	e8 02 fe ff ff       	call   801045d1 <p2v>
801047cf:	83 c4 10             	add    $0x10,%esp
801047d2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
801047d5:	83 ec 04             	sub    $0x4,%esp
801047d8:	6a 04                	push   $0x4
801047da:	68 9d 97 10 80       	push   $0x8010979d
801047df:	ff 75 f0             	pushl  -0x10(%ebp)
801047e2:	e8 73 16 00 00       	call   80105e5a <memcmp>
801047e7:	83 c4 10             	add    $0x10,%esp
801047ea:	85 c0                	test   %eax,%eax
801047ec:	74 07                	je     801047f5 <mpconfig+0x5d>
    return 0;
801047ee:	b8 00 00 00 00       	mov    $0x0,%eax
801047f3:	eb 4c                	jmp    80104841 <mpconfig+0xa9>
  if(conf->version != 1 && conf->version != 4)
801047f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801047f8:	0f b6 40 06          	movzbl 0x6(%eax),%eax
801047fc:	3c 01                	cmp    $0x1,%al
801047fe:	74 12                	je     80104812 <mpconfig+0x7a>
80104800:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104803:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80104807:	3c 04                	cmp    $0x4,%al
80104809:	74 07                	je     80104812 <mpconfig+0x7a>
    return 0;
8010480b:	b8 00 00 00 00       	mov    $0x0,%eax
80104810:	eb 2f                	jmp    80104841 <mpconfig+0xa9>
  if(sum((uchar*)conf, conf->length) != 0)
80104812:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104815:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80104819:	0f b7 c0             	movzwl %ax,%eax
8010481c:	83 ec 08             	sub    $0x8,%esp
8010481f:	50                   	push   %eax
80104820:	ff 75 f0             	pushl  -0x10(%ebp)
80104823:	e8 10 fe ff ff       	call   80104638 <sum>
80104828:	83 c4 10             	add    $0x10,%esp
8010482b:	84 c0                	test   %al,%al
8010482d:	74 07                	je     80104836 <mpconfig+0x9e>
    return 0;
8010482f:	b8 00 00 00 00       	mov    $0x0,%eax
80104834:	eb 0b                	jmp    80104841 <mpconfig+0xa9>
  *pmp = mp;
80104836:	8b 45 08             	mov    0x8(%ebp),%eax
80104839:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010483c:	89 10                	mov    %edx,(%eax)
  return conf;
8010483e:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80104841:	c9                   	leave  
80104842:	c3                   	ret    

80104843 <mpinit>:

void
mpinit(void)
{
80104843:	55                   	push   %ebp
80104844:	89 e5                	mov    %esp,%ebp
80104846:	83 ec 28             	sub    $0x28,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
80104849:	c7 05 44 c6 10 80 80 	movl   $0x80113880,0x8010c644
80104850:	38 11 80 
  if((conf = mpconfig(&mp)) == 0)
80104853:	83 ec 0c             	sub    $0xc,%esp
80104856:	8d 45 e0             	lea    -0x20(%ebp),%eax
80104859:	50                   	push   %eax
8010485a:	e8 39 ff ff ff       	call   80104798 <mpconfig>
8010485f:	83 c4 10             	add    $0x10,%esp
80104862:	89 45 f0             	mov    %eax,-0x10(%ebp)
80104865:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104869:	0f 84 96 01 00 00    	je     80104a05 <mpinit+0x1c2>
    return;
  ismp = 1;
8010486f:	c7 05 64 38 11 80 01 	movl   $0x1,0x80113864
80104876:	00 00 00 
  lapic = (uint*)conf->lapicaddr;
80104879:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010487c:	8b 40 24             	mov    0x24(%eax),%eax
8010487f:	a3 3c 35 11 80       	mov    %eax,0x8011353c
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80104884:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104887:	83 c0 2c             	add    $0x2c,%eax
8010488a:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010488d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104890:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80104894:	0f b7 d0             	movzwl %ax,%edx
80104897:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010489a:	01 d0                	add    %edx,%eax
8010489c:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010489f:	e9 f2 00 00 00       	jmp    80104996 <mpinit+0x153>
    switch(*p){
801048a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048a7:	0f b6 00             	movzbl (%eax),%eax
801048aa:	0f b6 c0             	movzbl %al,%eax
801048ad:	83 f8 04             	cmp    $0x4,%eax
801048b0:	0f 87 bc 00 00 00    	ja     80104972 <mpinit+0x12f>
801048b6:	8b 04 85 e0 97 10 80 	mov    -0x7fef6820(,%eax,4),%eax
801048bd:	ff e0                	jmp    *%eax
    case MPPROC:
      proc = (struct mpproc*)p;
801048bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048c2:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if(ncpu != proc->apicid){
801048c5:	8b 45 e8             	mov    -0x18(%ebp),%eax
801048c8:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801048cc:	0f b6 d0             	movzbl %al,%edx
801048cf:	a1 60 3e 11 80       	mov    0x80113e60,%eax
801048d4:	39 c2                	cmp    %eax,%edx
801048d6:	74 2b                	je     80104903 <mpinit+0xc0>
        cprintf("mpinit: ncpu=%d apicid=%d\n", ncpu, proc->apicid);
801048d8:	8b 45 e8             	mov    -0x18(%ebp),%eax
801048db:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801048df:	0f b6 d0             	movzbl %al,%edx
801048e2:	a1 60 3e 11 80       	mov    0x80113e60,%eax
801048e7:	83 ec 04             	sub    $0x4,%esp
801048ea:	52                   	push   %edx
801048eb:	50                   	push   %eax
801048ec:	68 a2 97 10 80       	push   $0x801097a2
801048f1:	e8 d0 ba ff ff       	call   801003c6 <cprintf>
801048f6:	83 c4 10             	add    $0x10,%esp
        ismp = 0;
801048f9:	c7 05 64 38 11 80 00 	movl   $0x0,0x80113864
80104900:	00 00 00 
      }
      if(proc->flags & MPBOOT)
80104903:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104906:	0f b6 40 03          	movzbl 0x3(%eax),%eax
8010490a:	0f b6 c0             	movzbl %al,%eax
8010490d:	83 e0 02             	and    $0x2,%eax
80104910:	85 c0                	test   %eax,%eax
80104912:	74 15                	je     80104929 <mpinit+0xe6>
        bcpu = &cpus[ncpu];
80104914:	a1 60 3e 11 80       	mov    0x80113e60,%eax
80104919:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
8010491f:	05 80 38 11 80       	add    $0x80113880,%eax
80104924:	a3 44 c6 10 80       	mov    %eax,0x8010c644
      cpus[ncpu].id = ncpu;
80104929:	a1 60 3e 11 80       	mov    0x80113e60,%eax
8010492e:	8b 15 60 3e 11 80    	mov    0x80113e60,%edx
80104934:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
8010493a:	05 80 38 11 80       	add    $0x80113880,%eax
8010493f:	88 10                	mov    %dl,(%eax)
      ncpu++;
80104941:	a1 60 3e 11 80       	mov    0x80113e60,%eax
80104946:	83 c0 01             	add    $0x1,%eax
80104949:	a3 60 3e 11 80       	mov    %eax,0x80113e60
      p += sizeof(struct mpproc);
8010494e:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
      continue;
80104952:	eb 42                	jmp    80104996 <mpinit+0x153>
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
80104954:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104957:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      ioapicid = ioapic->apicno;
8010495a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010495d:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80104961:	a2 60 38 11 80       	mov    %al,0x80113860
      p += sizeof(struct mpioapic);
80104966:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
8010496a:	eb 2a                	jmp    80104996 <mpinit+0x153>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
8010496c:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80104970:	eb 24                	jmp    80104996 <mpinit+0x153>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
80104972:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104975:	0f b6 00             	movzbl (%eax),%eax
80104978:	0f b6 c0             	movzbl %al,%eax
8010497b:	83 ec 08             	sub    $0x8,%esp
8010497e:	50                   	push   %eax
8010497f:	68 c0 97 10 80       	push   $0x801097c0
80104984:	e8 3d ba ff ff       	call   801003c6 <cprintf>
80104989:	83 c4 10             	add    $0x10,%esp
      ismp = 0;
8010498c:	c7 05 64 38 11 80 00 	movl   $0x0,0x80113864
80104993:	00 00 00 
  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80104996:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104999:	3b 45 ec             	cmp    -0x14(%ebp),%eax
8010499c:	0f 82 02 ff ff ff    	jb     801048a4 <mpinit+0x61>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
      ismp = 0;
    }
  }
  if(!ismp){
801049a2:	a1 64 38 11 80       	mov    0x80113864,%eax
801049a7:	85 c0                	test   %eax,%eax
801049a9:	75 1d                	jne    801049c8 <mpinit+0x185>
    // Didn't like what we found; fall back to no MP.
    ncpu = 1;
801049ab:	c7 05 60 3e 11 80 01 	movl   $0x1,0x80113e60
801049b2:	00 00 00 
    lapic = 0;
801049b5:	c7 05 3c 35 11 80 00 	movl   $0x0,0x8011353c
801049bc:	00 00 00 
    ioapicid = 0;
801049bf:	c6 05 60 38 11 80 00 	movb   $0x0,0x80113860
    return;
801049c6:	eb 3e                	jmp    80104a06 <mpinit+0x1c3>
  }

  if(mp->imcrp){
801049c8:	8b 45 e0             	mov    -0x20(%ebp),%eax
801049cb:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
801049cf:	84 c0                	test   %al,%al
801049d1:	74 33                	je     80104a06 <mpinit+0x1c3>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
801049d3:	83 ec 08             	sub    $0x8,%esp
801049d6:	6a 70                	push   $0x70
801049d8:	6a 22                	push   $0x22
801049da:	e8 1c fc ff ff       	call   801045fb <outb>
801049df:	83 c4 10             	add    $0x10,%esp
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
801049e2:	83 ec 0c             	sub    $0xc,%esp
801049e5:	6a 23                	push   $0x23
801049e7:	e8 f2 fb ff ff       	call   801045de <inb>
801049ec:	83 c4 10             	add    $0x10,%esp
801049ef:	83 c8 01             	or     $0x1,%eax
801049f2:	0f b6 c0             	movzbl %al,%eax
801049f5:	83 ec 08             	sub    $0x8,%esp
801049f8:	50                   	push   %eax
801049f9:	6a 23                	push   $0x23
801049fb:	e8 fb fb ff ff       	call   801045fb <outb>
80104a00:	83 c4 10             	add    $0x10,%esp
80104a03:	eb 01                	jmp    80104a06 <mpinit+0x1c3>
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
80104a05:	90                   	nop
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
  }
}
80104a06:	c9                   	leave  
80104a07:	c3                   	ret    

80104a08 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80104a08:	55                   	push   %ebp
80104a09:	89 e5                	mov    %esp,%ebp
80104a0b:	83 ec 08             	sub    $0x8,%esp
80104a0e:	8b 55 08             	mov    0x8(%ebp),%edx
80104a11:	8b 45 0c             	mov    0xc(%ebp),%eax
80104a14:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80104a18:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80104a1b:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80104a1f:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80104a23:	ee                   	out    %al,(%dx)
}
80104a24:	90                   	nop
80104a25:	c9                   	leave  
80104a26:	c3                   	ret    

80104a27 <picsetmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static ushort irqmask = 0xFFFF & ~(1<<IRQ_SLAVE);

static void
picsetmask(ushort mask)
{
80104a27:	55                   	push   %ebp
80104a28:	89 e5                	mov    %esp,%ebp
80104a2a:	83 ec 04             	sub    $0x4,%esp
80104a2d:	8b 45 08             	mov    0x8(%ebp),%eax
80104a30:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  irqmask = mask;
80104a34:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80104a38:	66 a3 00 c0 10 80    	mov    %ax,0x8010c000
  outb(IO_PIC1+1, mask);
80104a3e:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80104a42:	0f b6 c0             	movzbl %al,%eax
80104a45:	50                   	push   %eax
80104a46:	6a 21                	push   $0x21
80104a48:	e8 bb ff ff ff       	call   80104a08 <outb>
80104a4d:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, mask >> 8);
80104a50:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80104a54:	66 c1 e8 08          	shr    $0x8,%ax
80104a58:	0f b6 c0             	movzbl %al,%eax
80104a5b:	50                   	push   %eax
80104a5c:	68 a1 00 00 00       	push   $0xa1
80104a61:	e8 a2 ff ff ff       	call   80104a08 <outb>
80104a66:	83 c4 08             	add    $0x8,%esp
}
80104a69:	90                   	nop
80104a6a:	c9                   	leave  
80104a6b:	c3                   	ret    

80104a6c <picenable>:

void
picenable(int irq)
{
80104a6c:	55                   	push   %ebp
80104a6d:	89 e5                	mov    %esp,%ebp
  picsetmask(irqmask & ~(1<<irq));
80104a6f:	8b 45 08             	mov    0x8(%ebp),%eax
80104a72:	ba 01 00 00 00       	mov    $0x1,%edx
80104a77:	89 c1                	mov    %eax,%ecx
80104a79:	d3 e2                	shl    %cl,%edx
80104a7b:	89 d0                	mov    %edx,%eax
80104a7d:	f7 d0                	not    %eax
80104a7f:	89 c2                	mov    %eax,%edx
80104a81:	0f b7 05 00 c0 10 80 	movzwl 0x8010c000,%eax
80104a88:	21 d0                	and    %edx,%eax
80104a8a:	0f b7 c0             	movzwl %ax,%eax
80104a8d:	50                   	push   %eax
80104a8e:	e8 94 ff ff ff       	call   80104a27 <picsetmask>
80104a93:	83 c4 04             	add    $0x4,%esp
}
80104a96:	90                   	nop
80104a97:	c9                   	leave  
80104a98:	c3                   	ret    

80104a99 <picinit>:

// Initialize the 8259A interrupt controllers.
void
picinit(void)
{
80104a99:	55                   	push   %ebp
80104a9a:	89 e5                	mov    %esp,%ebp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80104a9c:	68 ff 00 00 00       	push   $0xff
80104aa1:	6a 21                	push   $0x21
80104aa3:	e8 60 ff ff ff       	call   80104a08 <outb>
80104aa8:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, 0xFF);
80104aab:	68 ff 00 00 00       	push   $0xff
80104ab0:	68 a1 00 00 00       	push   $0xa1
80104ab5:	e8 4e ff ff ff       	call   80104a08 <outb>
80104aba:	83 c4 08             	add    $0x8,%esp

  // ICW1:  0001g0hi
  //    g:  0 = edge triggering, 1 = level triggering
  //    h:  0 = cascaded PICs, 1 = master only
  //    i:  0 = no ICW4, 1 = ICW4 required
  outb(IO_PIC1, 0x11);
80104abd:	6a 11                	push   $0x11
80104abf:	6a 20                	push   $0x20
80104ac1:	e8 42 ff ff ff       	call   80104a08 <outb>
80104ac6:	83 c4 08             	add    $0x8,%esp

  // ICW2:  Vector offset
  outb(IO_PIC1+1, T_IRQ0);
80104ac9:	6a 20                	push   $0x20
80104acb:	6a 21                	push   $0x21
80104acd:	e8 36 ff ff ff       	call   80104a08 <outb>
80104ad2:	83 c4 08             	add    $0x8,%esp

  // ICW3:  (master PIC) bit mask of IR lines connected to slaves
  //        (slave PIC) 3-bit # of slave's connection to master
  outb(IO_PIC1+1, 1<<IRQ_SLAVE);
80104ad5:	6a 04                	push   $0x4
80104ad7:	6a 21                	push   $0x21
80104ad9:	e8 2a ff ff ff       	call   80104a08 <outb>
80104ade:	83 c4 08             	add    $0x8,%esp
  //    m:  0 = slave PIC, 1 = master PIC
  //      (ignored when b is 0, as the master/slave role
  //      can be hardwired).
  //    a:  1 = Automatic EOI mode
  //    p:  0 = MCS-80/85 mode, 1 = intel x86 mode
  outb(IO_PIC1+1, 0x3);
80104ae1:	6a 03                	push   $0x3
80104ae3:	6a 21                	push   $0x21
80104ae5:	e8 1e ff ff ff       	call   80104a08 <outb>
80104aea:	83 c4 08             	add    $0x8,%esp

  // Set up slave (8259A-2)
  outb(IO_PIC2, 0x11);                  // ICW1
80104aed:	6a 11                	push   $0x11
80104aef:	68 a0 00 00 00       	push   $0xa0
80104af4:	e8 0f ff ff ff       	call   80104a08 <outb>
80104af9:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, T_IRQ0 + 8);      // ICW2
80104afc:	6a 28                	push   $0x28
80104afe:	68 a1 00 00 00       	push   $0xa1
80104b03:	e8 00 ff ff ff       	call   80104a08 <outb>
80104b08:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, IRQ_SLAVE);           // ICW3
80104b0b:	6a 02                	push   $0x2
80104b0d:	68 a1 00 00 00       	push   $0xa1
80104b12:	e8 f1 fe ff ff       	call   80104a08 <outb>
80104b17:	83 c4 08             	add    $0x8,%esp
  // NB Automatic EOI mode doesn't tend to work on the slave.
  // Linux source code says it's "to be investigated".
  outb(IO_PIC2+1, 0x3);                 // ICW4
80104b1a:	6a 03                	push   $0x3
80104b1c:	68 a1 00 00 00       	push   $0xa1
80104b21:	e8 e2 fe ff ff       	call   80104a08 <outb>
80104b26:	83 c4 08             	add    $0x8,%esp

  // OCW3:  0ef01prs
  //   ef:  0x = NOP, 10 = clear specific mask, 11 = set specific mask
  //    p:  0 = no polling, 1 = polling mode
  //   rs:  0x = NOP, 10 = read IRR, 11 = read ISR
  outb(IO_PIC1, 0x68);             // clear specific mask
80104b29:	6a 68                	push   $0x68
80104b2b:	6a 20                	push   $0x20
80104b2d:	e8 d6 fe ff ff       	call   80104a08 <outb>
80104b32:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC1, 0x0a);             // read IRR by default
80104b35:	6a 0a                	push   $0xa
80104b37:	6a 20                	push   $0x20
80104b39:	e8 ca fe ff ff       	call   80104a08 <outb>
80104b3e:	83 c4 08             	add    $0x8,%esp

  outb(IO_PIC2, 0x68);             // OCW3
80104b41:	6a 68                	push   $0x68
80104b43:	68 a0 00 00 00       	push   $0xa0
80104b48:	e8 bb fe ff ff       	call   80104a08 <outb>
80104b4d:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2, 0x0a);             // OCW3
80104b50:	6a 0a                	push   $0xa
80104b52:	68 a0 00 00 00       	push   $0xa0
80104b57:	e8 ac fe ff ff       	call   80104a08 <outb>
80104b5c:	83 c4 08             	add    $0x8,%esp

  if(irqmask != 0xFFFF)
80104b5f:	0f b7 05 00 c0 10 80 	movzwl 0x8010c000,%eax
80104b66:	66 83 f8 ff          	cmp    $0xffff,%ax
80104b6a:	74 13                	je     80104b7f <picinit+0xe6>
    picsetmask(irqmask);
80104b6c:	0f b7 05 00 c0 10 80 	movzwl 0x8010c000,%eax
80104b73:	0f b7 c0             	movzwl %ax,%eax
80104b76:	50                   	push   %eax
80104b77:	e8 ab fe ff ff       	call   80104a27 <picsetmask>
80104b7c:	83 c4 04             	add    $0x4,%esp
}
80104b7f:	90                   	nop
80104b80:	c9                   	leave  
80104b81:	c3                   	ret    

80104b82 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80104b82:	55                   	push   %ebp
80104b83:	89 e5                	mov    %esp,%ebp
80104b85:	83 ec 18             	sub    $0x18,%esp
  struct pipe *p;

  p = 0;
80104b88:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
80104b8f:	8b 45 0c             	mov    0xc(%ebp),%eax
80104b92:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80104b98:	8b 45 0c             	mov    0xc(%ebp),%eax
80104b9b:	8b 10                	mov    (%eax),%edx
80104b9d:	8b 45 08             	mov    0x8(%ebp),%eax
80104ba0:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80104ba2:	e8 44 c4 ff ff       	call   80100feb <filealloc>
80104ba7:	89 c2                	mov    %eax,%edx
80104ba9:	8b 45 08             	mov    0x8(%ebp),%eax
80104bac:	89 10                	mov    %edx,(%eax)
80104bae:	8b 45 08             	mov    0x8(%ebp),%eax
80104bb1:	8b 00                	mov    (%eax),%eax
80104bb3:	85 c0                	test   %eax,%eax
80104bb5:	0f 84 cb 00 00 00    	je     80104c86 <pipealloc+0x104>
80104bbb:	e8 2b c4 ff ff       	call   80100feb <filealloc>
80104bc0:	89 c2                	mov    %eax,%edx
80104bc2:	8b 45 0c             	mov    0xc(%ebp),%eax
80104bc5:	89 10                	mov    %edx,(%eax)
80104bc7:	8b 45 0c             	mov    0xc(%ebp),%eax
80104bca:	8b 00                	mov    (%eax),%eax
80104bcc:	85 c0                	test   %eax,%eax
80104bce:	0f 84 b2 00 00 00    	je     80104c86 <pipealloc+0x104>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80104bd4:	e8 a2 e8 ff ff       	call   8010347b <kalloc>
80104bd9:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104bdc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104be0:	0f 84 9f 00 00 00    	je     80104c85 <pipealloc+0x103>
    goto bad;
  p->readopen = 1;
80104be6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104be9:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80104bf0:	00 00 00 
  p->writeopen = 1;
80104bf3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bf6:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80104bfd:	00 00 00 
  p->nwrite = 0;
80104c00:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c03:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80104c0a:	00 00 00 
  p->nread = 0;
80104c0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c10:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80104c17:	00 00 00 
  initlock(&p->lock, "pipe");
80104c1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c1d:	83 ec 08             	sub    $0x8,%esp
80104c20:	68 f4 97 10 80       	push   $0x801097f4
80104c25:	50                   	push   %eax
80104c26:	e8 43 0f 00 00       	call   80105b6e <initlock>
80104c2b:	83 c4 10             	add    $0x10,%esp
  (*f0)->type = FD_PIPE;
80104c2e:	8b 45 08             	mov    0x8(%ebp),%eax
80104c31:	8b 00                	mov    (%eax),%eax
80104c33:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80104c39:	8b 45 08             	mov    0x8(%ebp),%eax
80104c3c:	8b 00                	mov    (%eax),%eax
80104c3e:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80104c42:	8b 45 08             	mov    0x8(%ebp),%eax
80104c45:	8b 00                	mov    (%eax),%eax
80104c47:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80104c4b:	8b 45 08             	mov    0x8(%ebp),%eax
80104c4e:	8b 00                	mov    (%eax),%eax
80104c50:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104c53:	89 50 0a             	mov    %edx,0xa(%eax)
  (*f1)->type = FD_PIPE;
80104c56:	8b 45 0c             	mov    0xc(%ebp),%eax
80104c59:	8b 00                	mov    (%eax),%eax
80104c5b:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80104c61:	8b 45 0c             	mov    0xc(%ebp),%eax
80104c64:	8b 00                	mov    (%eax),%eax
80104c66:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80104c6a:	8b 45 0c             	mov    0xc(%ebp),%eax
80104c6d:	8b 00                	mov    (%eax),%eax
80104c6f:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
80104c73:	8b 45 0c             	mov    0xc(%ebp),%eax
80104c76:	8b 00                	mov    (%eax),%eax
80104c78:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104c7b:	89 50 0a             	mov    %edx,0xa(%eax)
  return 0;
80104c7e:	b8 00 00 00 00       	mov    $0x0,%eax
80104c83:	eb 4e                	jmp    80104cd3 <pipealloc+0x151>
  p = 0;
  *f0 = *f1 = 0;
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
    goto bad;
80104c85:	90                   	nop
  (*f1)->pipe = p;
  return 0;

//PAGEBREAK: 20
 bad:
  if(p)
80104c86:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104c8a:	74 0e                	je     80104c9a <pipealloc+0x118>
    kfree((char*)p);
80104c8c:	83 ec 0c             	sub    $0xc,%esp
80104c8f:	ff 75 f4             	pushl  -0xc(%ebp)
80104c92:	e8 47 e7 ff ff       	call   801033de <kfree>
80104c97:	83 c4 10             	add    $0x10,%esp
  if(*f0)
80104c9a:	8b 45 08             	mov    0x8(%ebp),%eax
80104c9d:	8b 00                	mov    (%eax),%eax
80104c9f:	85 c0                	test   %eax,%eax
80104ca1:	74 11                	je     80104cb4 <pipealloc+0x132>
    fileclose(*f0);
80104ca3:	8b 45 08             	mov    0x8(%ebp),%eax
80104ca6:	8b 00                	mov    (%eax),%eax
80104ca8:	83 ec 0c             	sub    $0xc,%esp
80104cab:	50                   	push   %eax
80104cac:	e8 f8 c3 ff ff       	call   801010a9 <fileclose>
80104cb1:	83 c4 10             	add    $0x10,%esp
  if(*f1)
80104cb4:	8b 45 0c             	mov    0xc(%ebp),%eax
80104cb7:	8b 00                	mov    (%eax),%eax
80104cb9:	85 c0                	test   %eax,%eax
80104cbb:	74 11                	je     80104cce <pipealloc+0x14c>
    fileclose(*f1);
80104cbd:	8b 45 0c             	mov    0xc(%ebp),%eax
80104cc0:	8b 00                	mov    (%eax),%eax
80104cc2:	83 ec 0c             	sub    $0xc,%esp
80104cc5:	50                   	push   %eax
80104cc6:	e8 de c3 ff ff       	call   801010a9 <fileclose>
80104ccb:	83 c4 10             	add    $0x10,%esp
  return -1;
80104cce:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104cd3:	c9                   	leave  
80104cd4:	c3                   	ret    

80104cd5 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
80104cd5:	55                   	push   %ebp
80104cd6:	89 e5                	mov    %esp,%ebp
80104cd8:	83 ec 08             	sub    $0x8,%esp
  acquire(&p->lock);
80104cdb:	8b 45 08             	mov    0x8(%ebp),%eax
80104cde:	83 ec 0c             	sub    $0xc,%esp
80104ce1:	50                   	push   %eax
80104ce2:	e8 a9 0e 00 00       	call   80105b90 <acquire>
80104ce7:	83 c4 10             	add    $0x10,%esp
  if(writable){
80104cea:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104cee:	74 23                	je     80104d13 <pipeclose+0x3e>
    p->writeopen = 0;
80104cf0:	8b 45 08             	mov    0x8(%ebp),%eax
80104cf3:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
80104cfa:	00 00 00 
    wakeup(&p->nread);
80104cfd:	8b 45 08             	mov    0x8(%ebp),%eax
80104d00:	05 34 02 00 00       	add    $0x234,%eax
80104d05:	83 ec 0c             	sub    $0xc,%esp
80104d08:	50                   	push   %eax
80104d09:	e8 74 0c 00 00       	call   80105982 <wakeup>
80104d0e:	83 c4 10             	add    $0x10,%esp
80104d11:	eb 21                	jmp    80104d34 <pipeclose+0x5f>
  } else {
    p->readopen = 0;
80104d13:	8b 45 08             	mov    0x8(%ebp),%eax
80104d16:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
80104d1d:	00 00 00 
    wakeup(&p->nwrite);
80104d20:	8b 45 08             	mov    0x8(%ebp),%eax
80104d23:	05 38 02 00 00       	add    $0x238,%eax
80104d28:	83 ec 0c             	sub    $0xc,%esp
80104d2b:	50                   	push   %eax
80104d2c:	e8 51 0c 00 00       	call   80105982 <wakeup>
80104d31:	83 c4 10             	add    $0x10,%esp
  }
  if(p->readopen == 0 && p->writeopen == 0){
80104d34:	8b 45 08             	mov    0x8(%ebp),%eax
80104d37:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80104d3d:	85 c0                	test   %eax,%eax
80104d3f:	75 2c                	jne    80104d6d <pipeclose+0x98>
80104d41:	8b 45 08             	mov    0x8(%ebp),%eax
80104d44:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80104d4a:	85 c0                	test   %eax,%eax
80104d4c:	75 1f                	jne    80104d6d <pipeclose+0x98>
    release(&p->lock);
80104d4e:	8b 45 08             	mov    0x8(%ebp),%eax
80104d51:	83 ec 0c             	sub    $0xc,%esp
80104d54:	50                   	push   %eax
80104d55:	e8 9d 0e 00 00       	call   80105bf7 <release>
80104d5a:	83 c4 10             	add    $0x10,%esp
    kfree((char*)p);
80104d5d:	83 ec 0c             	sub    $0xc,%esp
80104d60:	ff 75 08             	pushl  0x8(%ebp)
80104d63:	e8 76 e6 ff ff       	call   801033de <kfree>
80104d68:	83 c4 10             	add    $0x10,%esp
80104d6b:	eb 0f                	jmp    80104d7c <pipeclose+0xa7>
  } else
    release(&p->lock);
80104d6d:	8b 45 08             	mov    0x8(%ebp),%eax
80104d70:	83 ec 0c             	sub    $0xc,%esp
80104d73:	50                   	push   %eax
80104d74:	e8 7e 0e 00 00       	call   80105bf7 <release>
80104d79:	83 c4 10             	add    $0x10,%esp
}
80104d7c:	90                   	nop
80104d7d:	c9                   	leave  
80104d7e:	c3                   	ret    

80104d7f <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
80104d7f:	55                   	push   %ebp
80104d80:	89 e5                	mov    %esp,%ebp
80104d82:	83 ec 18             	sub    $0x18,%esp
  int i;

  acquire(&p->lock);
80104d85:	8b 45 08             	mov    0x8(%ebp),%eax
80104d88:	83 ec 0c             	sub    $0xc,%esp
80104d8b:	50                   	push   %eax
80104d8c:	e8 ff 0d 00 00       	call   80105b90 <acquire>
80104d91:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++){
80104d94:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104d9b:	e9 ad 00 00 00       	jmp    80104e4d <pipewrite+0xce>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || proc->killed){
80104da0:	8b 45 08             	mov    0x8(%ebp),%eax
80104da3:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80104da9:	85 c0                	test   %eax,%eax
80104dab:	74 0d                	je     80104dba <pipewrite+0x3b>
80104dad:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104db3:	8b 40 24             	mov    0x24(%eax),%eax
80104db6:	85 c0                	test   %eax,%eax
80104db8:	74 19                	je     80104dd3 <pipewrite+0x54>
        release(&p->lock);
80104dba:	8b 45 08             	mov    0x8(%ebp),%eax
80104dbd:	83 ec 0c             	sub    $0xc,%esp
80104dc0:	50                   	push   %eax
80104dc1:	e8 31 0e 00 00       	call   80105bf7 <release>
80104dc6:	83 c4 10             	add    $0x10,%esp
        return -1;
80104dc9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104dce:	e9 a8 00 00 00       	jmp    80104e7b <pipewrite+0xfc>
      }
      wakeup(&p->nread);
80104dd3:	8b 45 08             	mov    0x8(%ebp),%eax
80104dd6:	05 34 02 00 00       	add    $0x234,%eax
80104ddb:	83 ec 0c             	sub    $0xc,%esp
80104dde:	50                   	push   %eax
80104ddf:	e8 9e 0b 00 00       	call   80105982 <wakeup>
80104de4:	83 c4 10             	add    $0x10,%esp
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
80104de7:	8b 45 08             	mov    0x8(%ebp),%eax
80104dea:	8b 55 08             	mov    0x8(%ebp),%edx
80104ded:	81 c2 38 02 00 00    	add    $0x238,%edx
80104df3:	83 ec 08             	sub    $0x8,%esp
80104df6:	50                   	push   %eax
80104df7:	52                   	push   %edx
80104df8:	e8 9a 0a 00 00       	call   80105897 <sleep>
80104dfd:	83 c4 10             	add    $0x10,%esp
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80104e00:	8b 45 08             	mov    0x8(%ebp),%eax
80104e03:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
80104e09:	8b 45 08             	mov    0x8(%ebp),%eax
80104e0c:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80104e12:	05 00 02 00 00       	add    $0x200,%eax
80104e17:	39 c2                	cmp    %eax,%edx
80104e19:	74 85                	je     80104da0 <pipewrite+0x21>
        return -1;
      }
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
80104e1b:	8b 45 08             	mov    0x8(%ebp),%eax
80104e1e:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104e24:	8d 48 01             	lea    0x1(%eax),%ecx
80104e27:	8b 55 08             	mov    0x8(%ebp),%edx
80104e2a:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
80104e30:	25 ff 01 00 00       	and    $0x1ff,%eax
80104e35:	89 c1                	mov    %eax,%ecx
80104e37:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104e3a:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e3d:	01 d0                	add    %edx,%eax
80104e3f:	0f b6 10             	movzbl (%eax),%edx
80104e42:	8b 45 08             	mov    0x8(%ebp),%eax
80104e45:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
pipewrite(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
80104e49:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104e4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e50:	3b 45 10             	cmp    0x10(%ebp),%eax
80104e53:	7c ab                	jl     80104e00 <pipewrite+0x81>
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80104e55:	8b 45 08             	mov    0x8(%ebp),%eax
80104e58:	05 34 02 00 00       	add    $0x234,%eax
80104e5d:	83 ec 0c             	sub    $0xc,%esp
80104e60:	50                   	push   %eax
80104e61:	e8 1c 0b 00 00       	call   80105982 <wakeup>
80104e66:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80104e69:	8b 45 08             	mov    0x8(%ebp),%eax
80104e6c:	83 ec 0c             	sub    $0xc,%esp
80104e6f:	50                   	push   %eax
80104e70:	e8 82 0d 00 00       	call   80105bf7 <release>
80104e75:	83 c4 10             	add    $0x10,%esp
  return n;
80104e78:	8b 45 10             	mov    0x10(%ebp),%eax
}
80104e7b:	c9                   	leave  
80104e7c:	c3                   	ret    

80104e7d <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
80104e7d:	55                   	push   %ebp
80104e7e:	89 e5                	mov    %esp,%ebp
80104e80:	53                   	push   %ebx
80104e81:	83 ec 14             	sub    $0x14,%esp
  int i;

  acquire(&p->lock);
80104e84:	8b 45 08             	mov    0x8(%ebp),%eax
80104e87:	83 ec 0c             	sub    $0xc,%esp
80104e8a:	50                   	push   %eax
80104e8b:	e8 00 0d 00 00       	call   80105b90 <acquire>
80104e90:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80104e93:	eb 3f                	jmp    80104ed4 <piperead+0x57>
    if(proc->killed){
80104e95:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104e9b:	8b 40 24             	mov    0x24(%eax),%eax
80104e9e:	85 c0                	test   %eax,%eax
80104ea0:	74 19                	je     80104ebb <piperead+0x3e>
      release(&p->lock);
80104ea2:	8b 45 08             	mov    0x8(%ebp),%eax
80104ea5:	83 ec 0c             	sub    $0xc,%esp
80104ea8:	50                   	push   %eax
80104ea9:	e8 49 0d 00 00       	call   80105bf7 <release>
80104eae:	83 c4 10             	add    $0x10,%esp
      return -1;
80104eb1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104eb6:	e9 bf 00 00 00       	jmp    80104f7a <piperead+0xfd>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
80104ebb:	8b 45 08             	mov    0x8(%ebp),%eax
80104ebe:	8b 55 08             	mov    0x8(%ebp),%edx
80104ec1:	81 c2 34 02 00 00    	add    $0x234,%edx
80104ec7:	83 ec 08             	sub    $0x8,%esp
80104eca:	50                   	push   %eax
80104ecb:	52                   	push   %edx
80104ecc:	e8 c6 09 00 00       	call   80105897 <sleep>
80104ed1:	83 c4 10             	add    $0x10,%esp
piperead(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80104ed4:	8b 45 08             	mov    0x8(%ebp),%eax
80104ed7:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80104edd:	8b 45 08             	mov    0x8(%ebp),%eax
80104ee0:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104ee6:	39 c2                	cmp    %eax,%edx
80104ee8:	75 0d                	jne    80104ef7 <piperead+0x7a>
80104eea:	8b 45 08             	mov    0x8(%ebp),%eax
80104eed:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80104ef3:	85 c0                	test   %eax,%eax
80104ef5:	75 9e                	jne    80104e95 <piperead+0x18>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80104ef7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104efe:	eb 49                	jmp    80104f49 <piperead+0xcc>
    if(p->nread == p->nwrite)
80104f00:	8b 45 08             	mov    0x8(%ebp),%eax
80104f03:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80104f09:	8b 45 08             	mov    0x8(%ebp),%eax
80104f0c:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104f12:	39 c2                	cmp    %eax,%edx
80104f14:	74 3d                	je     80104f53 <piperead+0xd6>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
80104f16:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104f19:	8b 45 0c             	mov    0xc(%ebp),%eax
80104f1c:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80104f1f:	8b 45 08             	mov    0x8(%ebp),%eax
80104f22:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80104f28:	8d 48 01             	lea    0x1(%eax),%ecx
80104f2b:	8b 55 08             	mov    0x8(%ebp),%edx
80104f2e:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
80104f34:	25 ff 01 00 00       	and    $0x1ff,%eax
80104f39:	89 c2                	mov    %eax,%edx
80104f3b:	8b 45 08             	mov    0x8(%ebp),%eax
80104f3e:	0f b6 44 10 34       	movzbl 0x34(%eax,%edx,1),%eax
80104f43:	88 03                	mov    %al,(%ebx)
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80104f45:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104f49:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f4c:	3b 45 10             	cmp    0x10(%ebp),%eax
80104f4f:	7c af                	jl     80104f00 <piperead+0x83>
80104f51:	eb 01                	jmp    80104f54 <piperead+0xd7>
    if(p->nread == p->nwrite)
      break;
80104f53:	90                   	nop
    addr[i] = p->data[p->nread++ % PIPESIZE];
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
80104f54:	8b 45 08             	mov    0x8(%ebp),%eax
80104f57:	05 38 02 00 00       	add    $0x238,%eax
80104f5c:	83 ec 0c             	sub    $0xc,%esp
80104f5f:	50                   	push   %eax
80104f60:	e8 1d 0a 00 00       	call   80105982 <wakeup>
80104f65:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80104f68:	8b 45 08             	mov    0x8(%ebp),%eax
80104f6b:	83 ec 0c             	sub    $0xc,%esp
80104f6e:	50                   	push   %eax
80104f6f:	e8 83 0c 00 00       	call   80105bf7 <release>
80104f74:	83 c4 10             	add    $0x10,%esp
  return i;
80104f77:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104f7a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104f7d:	c9                   	leave  
80104f7e:	c3                   	ret    

80104f7f <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80104f7f:	55                   	push   %ebp
80104f80:	89 e5                	mov    %esp,%ebp
80104f82:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104f85:	9c                   	pushf  
80104f86:	58                   	pop    %eax
80104f87:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80104f8a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104f8d:	c9                   	leave  
80104f8e:	c3                   	ret    

80104f8f <sti>:
  asm volatile("cli");
}

static inline void
sti(void)
{
80104f8f:	55                   	push   %ebp
80104f90:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80104f92:	fb                   	sti    
}
80104f93:	90                   	nop
80104f94:	5d                   	pop    %ebp
80104f95:	c3                   	ret    

80104f96 <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
80104f96:	55                   	push   %ebp
80104f97:	89 e5                	mov    %esp,%ebp
80104f99:	83 ec 08             	sub    $0x8,%esp
  initlock(&ptable.lock, "ptable");
80104f9c:	83 ec 08             	sub    $0x8,%esp
80104f9f:	68 f9 97 10 80       	push   $0x801097f9
80104fa4:	68 80 3e 11 80       	push   $0x80113e80
80104fa9:	e8 c0 0b 00 00       	call   80105b6e <initlock>
80104fae:	83 c4 10             	add    $0x10,%esp
}
80104fb1:	90                   	nop
80104fb2:	c9                   	leave  
80104fb3:	c3                   	ret    

80104fb4 <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
80104fb4:	55                   	push   %ebp
80104fb5:	89 e5                	mov    %esp,%ebp
80104fb7:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
80104fba:	83 ec 0c             	sub    $0xc,%esp
80104fbd:	68 80 3e 11 80       	push   $0x80113e80
80104fc2:	e8 c9 0b 00 00       	call   80105b90 <acquire>
80104fc7:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104fca:	c7 45 f4 b4 3e 11 80 	movl   $0x80113eb4,-0xc(%ebp)
80104fd1:	eb 0e                	jmp    80104fe1 <allocproc+0x2d>
    if(p->state == UNUSED)
80104fd3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104fd6:	8b 40 0c             	mov    0xc(%eax),%eax
80104fd9:	85 c0                	test   %eax,%eax
80104fdb:	74 27                	je     80105004 <allocproc+0x50>
{
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104fdd:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80104fe1:	81 7d f4 b4 5d 11 80 	cmpl   $0x80115db4,-0xc(%ebp)
80104fe8:	72 e9                	jb     80104fd3 <allocproc+0x1f>
    if(p->state == UNUSED)
      goto found;
  release(&ptable.lock);
80104fea:	83 ec 0c             	sub    $0xc,%esp
80104fed:	68 80 3e 11 80       	push   $0x80113e80
80104ff2:	e8 00 0c 00 00       	call   80105bf7 <release>
80104ff7:	83 c4 10             	add    $0x10,%esp
  return 0;
80104ffa:	b8 00 00 00 00       	mov    $0x0,%eax
80104fff:	e9 b4 00 00 00       	jmp    801050b8 <allocproc+0x104>
  char *sp;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
    if(p->state == UNUSED)
      goto found;
80105004:	90                   	nop
  release(&ptable.lock);
  return 0;

found:
  p->state = EMBRYO;
80105005:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105008:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
8010500f:	a1 04 c0 10 80       	mov    0x8010c004,%eax
80105014:	8d 50 01             	lea    0x1(%eax),%edx
80105017:	89 15 04 c0 10 80    	mov    %edx,0x8010c004
8010501d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105020:	89 42 10             	mov    %eax,0x10(%edx)
  release(&ptable.lock);
80105023:	83 ec 0c             	sub    $0xc,%esp
80105026:	68 80 3e 11 80       	push   $0x80113e80
8010502b:	e8 c7 0b 00 00       	call   80105bf7 <release>
80105030:	83 c4 10             	add    $0x10,%esp

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
80105033:	e8 43 e4 ff ff       	call   8010347b <kalloc>
80105038:	89 c2                	mov    %eax,%edx
8010503a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010503d:	89 50 08             	mov    %edx,0x8(%eax)
80105040:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105043:	8b 40 08             	mov    0x8(%eax),%eax
80105046:	85 c0                	test   %eax,%eax
80105048:	75 11                	jne    8010505b <allocproc+0xa7>
    p->state = UNUSED;
8010504a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010504d:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
80105054:	b8 00 00 00 00       	mov    $0x0,%eax
80105059:	eb 5d                	jmp    801050b8 <allocproc+0x104>
  }
  sp = p->kstack + KSTACKSIZE;
8010505b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010505e:	8b 40 08             	mov    0x8(%eax),%eax
80105061:	05 00 10 00 00       	add    $0x1000,%eax
80105066:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  // Leave room for trap frame.
  sp -= sizeof *p->tf;
80105069:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
8010506d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105070:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105073:	89 50 18             	mov    %edx,0x18(%eax)
  
  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
80105076:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
8010507a:	ba 0a 75 10 80       	mov    $0x8010750a,%edx
8010507f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105082:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
80105084:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
80105088:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010508b:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010508e:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
80105091:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105094:	8b 40 1c             	mov    0x1c(%eax),%eax
80105097:	83 ec 04             	sub    $0x4,%esp
8010509a:	6a 14                	push   $0x14
8010509c:	6a 00                	push   $0x0
8010509e:	50                   	push   %eax
8010509f:	e8 4f 0d 00 00       	call   80105df3 <memset>
801050a4:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
801050a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050aa:	8b 40 1c             	mov    0x1c(%eax),%eax
801050ad:	ba 2d 58 10 80       	mov    $0x8010582d,%edx
801050b2:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
801050b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801050b8:	c9                   	leave  
801050b9:	c3                   	ret    

801050ba <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
801050ba:	55                   	push   %ebp
801050bb:	89 e5                	mov    %esp,%ebp
801050bd:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];
  
  p = allocproc();
801050c0:	e8 ef fe ff ff       	call   80104fb4 <allocproc>
801050c5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  initproc = p;
801050c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050cb:	a3 48 c6 10 80       	mov    %eax,0x8010c648
  if((p->pgdir = setupkvm()) == 0)
801050d0:	e8 fa 3a 00 00       	call   80108bcf <setupkvm>
801050d5:	89 c2                	mov    %eax,%edx
801050d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050da:	89 50 04             	mov    %edx,0x4(%eax)
801050dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050e0:	8b 40 04             	mov    0x4(%eax),%eax
801050e3:	85 c0                	test   %eax,%eax
801050e5:	75 0d                	jne    801050f4 <userinit+0x3a>
    panic("userinit: out of memory?");
801050e7:	83 ec 0c             	sub    $0xc,%esp
801050ea:	68 00 98 10 80       	push   $0x80109800
801050ef:	e8 72 b4 ff ff       	call   80100566 <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
801050f4:	ba 2c 00 00 00       	mov    $0x2c,%edx
801050f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050fc:	8b 40 04             	mov    0x4(%eax),%eax
801050ff:	83 ec 04             	sub    $0x4,%esp
80105102:	52                   	push   %edx
80105103:	68 e0 c4 10 80       	push   $0x8010c4e0
80105108:	50                   	push   %eax
80105109:	e8 1b 3d 00 00       	call   80108e29 <inituvm>
8010510e:	83 c4 10             	add    $0x10,%esp
  p->sz = PGSIZE;
80105111:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105114:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
8010511a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010511d:	8b 40 18             	mov    0x18(%eax),%eax
80105120:	83 ec 04             	sub    $0x4,%esp
80105123:	6a 4c                	push   $0x4c
80105125:	6a 00                	push   $0x0
80105127:	50                   	push   %eax
80105128:	e8 c6 0c 00 00       	call   80105df3 <memset>
8010512d:	83 c4 10             	add    $0x10,%esp
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80105130:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105133:	8b 40 18             	mov    0x18(%eax),%eax
80105136:	66 c7 40 3c 23 00    	movw   $0x23,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
8010513c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010513f:	8b 40 18             	mov    0x18(%eax),%eax
80105142:	66 c7 40 2c 2b 00    	movw   $0x2b,0x2c(%eax)
  p->tf->es = p->tf->ds;
80105148:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010514b:	8b 40 18             	mov    0x18(%eax),%eax
8010514e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105151:	8b 52 18             	mov    0x18(%edx),%edx
80105154:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80105158:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
8010515c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010515f:	8b 40 18             	mov    0x18(%eax),%eax
80105162:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105165:	8b 52 18             	mov    0x18(%edx),%edx
80105168:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
8010516c:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
80105170:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105173:	8b 40 18             	mov    0x18(%eax),%eax
80105176:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
8010517d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105180:	8b 40 18             	mov    0x18(%eax),%eax
80105183:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
8010518a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010518d:	8b 40 18             	mov    0x18(%eax),%eax
80105190:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
80105197:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010519a:	83 c0 6c             	add    $0x6c,%eax
8010519d:	83 ec 04             	sub    $0x4,%esp
801051a0:	6a 10                	push   $0x10
801051a2:	68 19 98 10 80       	push   $0x80109819
801051a7:	50                   	push   %eax
801051a8:	e8 49 0e 00 00       	call   80105ff6 <safestrcpy>
801051ad:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
801051b0:	83 ec 0c             	sub    $0xc,%esp
801051b3:	68 22 98 10 80       	push   $0x80109822
801051b8:	e8 57 db ff ff       	call   80102d14 <namei>
801051bd:	83 c4 10             	add    $0x10,%esp
801051c0:	89 c2                	mov    %eax,%edx
801051c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051c5:	89 50 68             	mov    %edx,0x68(%eax)

  
 // cprintf("userinit-root inode addr %d \n",p->cwd);
  

  p->state = RUNNABLE;
801051c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051cb:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
}
801051d2:	90                   	nop
801051d3:	c9                   	leave  
801051d4:	c3                   	ret    

801051d5 <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
801051d5:	55                   	push   %ebp
801051d6:	89 e5                	mov    %esp,%ebp
801051d8:	83 ec 18             	sub    $0x18,%esp
  uint sz;
  
  sz = proc->sz;
801051db:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801051e1:	8b 00                	mov    (%eax),%eax
801051e3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
801051e6:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801051ea:	7e 31                	jle    8010521d <growproc+0x48>
    if((sz = allocuvm(proc->pgdir, sz, sz + n)) == 0)
801051ec:	8b 55 08             	mov    0x8(%ebp),%edx
801051ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051f2:	01 c2                	add    %eax,%edx
801051f4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801051fa:	8b 40 04             	mov    0x4(%eax),%eax
801051fd:	83 ec 04             	sub    $0x4,%esp
80105200:	52                   	push   %edx
80105201:	ff 75 f4             	pushl  -0xc(%ebp)
80105204:	50                   	push   %eax
80105205:	e8 6c 3d 00 00       	call   80108f76 <allocuvm>
8010520a:	83 c4 10             	add    $0x10,%esp
8010520d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105210:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105214:	75 3e                	jne    80105254 <growproc+0x7f>
      return -1;
80105216:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010521b:	eb 59                	jmp    80105276 <growproc+0xa1>
  } else if(n < 0){
8010521d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80105221:	79 31                	jns    80105254 <growproc+0x7f>
    if((sz = deallocuvm(proc->pgdir, sz, sz + n)) == 0)
80105223:	8b 55 08             	mov    0x8(%ebp),%edx
80105226:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105229:	01 c2                	add    %eax,%edx
8010522b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105231:	8b 40 04             	mov    0x4(%eax),%eax
80105234:	83 ec 04             	sub    $0x4,%esp
80105237:	52                   	push   %edx
80105238:	ff 75 f4             	pushl  -0xc(%ebp)
8010523b:	50                   	push   %eax
8010523c:	e8 fe 3d 00 00       	call   8010903f <deallocuvm>
80105241:	83 c4 10             	add    $0x10,%esp
80105244:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105247:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010524b:	75 07                	jne    80105254 <growproc+0x7f>
      return -1;
8010524d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105252:	eb 22                	jmp    80105276 <growproc+0xa1>
  }
  proc->sz = sz;
80105254:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010525a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010525d:	89 10                	mov    %edx,(%eax)
  switchuvm(proc);
8010525f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105265:	83 ec 0c             	sub    $0xc,%esp
80105268:	50                   	push   %eax
80105269:	e8 48 3a 00 00       	call   80108cb6 <switchuvm>
8010526e:	83 c4 10             	add    $0x10,%esp
  return 0;
80105271:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105276:	c9                   	leave  
80105277:	c3                   	ret    

80105278 <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
80105278:	55                   	push   %ebp
80105279:	89 e5                	mov    %esp,%ebp
8010527b:	57                   	push   %edi
8010527c:	56                   	push   %esi
8010527d:	53                   	push   %ebx
8010527e:	83 ec 1c             	sub    $0x1c,%esp
  int i, pid;
  struct proc *np;

  // Allocate process.
  if((np = allocproc()) == 0)
80105281:	e8 2e fd ff ff       	call   80104fb4 <allocproc>
80105286:	89 45 e0             	mov    %eax,-0x20(%ebp)
80105289:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
8010528d:	75 0a                	jne    80105299 <fork+0x21>
    return -1;
8010528f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105294:	e9 68 01 00 00       	jmp    80105401 <fork+0x189>

  // Copy process state from p.
  if((np->pgdir = copyuvm(proc->pgdir, proc->sz)) == 0){
80105299:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010529f:	8b 10                	mov    (%eax),%edx
801052a1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801052a7:	8b 40 04             	mov    0x4(%eax),%eax
801052aa:	83 ec 08             	sub    $0x8,%esp
801052ad:	52                   	push   %edx
801052ae:	50                   	push   %eax
801052af:	e8 29 3f 00 00       	call   801091dd <copyuvm>
801052b4:	83 c4 10             	add    $0x10,%esp
801052b7:	89 c2                	mov    %eax,%edx
801052b9:	8b 45 e0             	mov    -0x20(%ebp),%eax
801052bc:	89 50 04             	mov    %edx,0x4(%eax)
801052bf:	8b 45 e0             	mov    -0x20(%ebp),%eax
801052c2:	8b 40 04             	mov    0x4(%eax),%eax
801052c5:	85 c0                	test   %eax,%eax
801052c7:	75 30                	jne    801052f9 <fork+0x81>
    kfree(np->kstack);
801052c9:	8b 45 e0             	mov    -0x20(%ebp),%eax
801052cc:	8b 40 08             	mov    0x8(%eax),%eax
801052cf:	83 ec 0c             	sub    $0xc,%esp
801052d2:	50                   	push   %eax
801052d3:	e8 06 e1 ff ff       	call   801033de <kfree>
801052d8:	83 c4 10             	add    $0x10,%esp
    np->kstack = 0;
801052db:	8b 45 e0             	mov    -0x20(%ebp),%eax
801052de:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
801052e5:	8b 45 e0             	mov    -0x20(%ebp),%eax
801052e8:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
801052ef:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801052f4:	e9 08 01 00 00       	jmp    80105401 <fork+0x189>
  }
  np->sz = proc->sz;
801052f9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801052ff:	8b 10                	mov    (%eax),%edx
80105301:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105304:	89 10                	mov    %edx,(%eax)
  np->parent = proc;
80105306:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
8010530d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105310:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *proc->tf;
80105313:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105316:	8b 50 18             	mov    0x18(%eax),%edx
80105319:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010531f:	8b 40 18             	mov    0x18(%eax),%eax
80105322:	89 c3                	mov    %eax,%ebx
80105324:	b8 13 00 00 00       	mov    $0x13,%eax
80105329:	89 d7                	mov    %edx,%edi
8010532b:	89 de                	mov    %ebx,%esi
8010532d:	89 c1                	mov    %eax,%ecx
8010532f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
80105331:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105334:	8b 40 18             	mov    0x18(%eax),%eax
80105337:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
8010533e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80105345:	eb 43                	jmp    8010538a <fork+0x112>
    if(proc->ofile[i])
80105347:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010534d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80105350:	83 c2 08             	add    $0x8,%edx
80105353:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105357:	85 c0                	test   %eax,%eax
80105359:	74 2b                	je     80105386 <fork+0x10e>
      np->ofile[i] = filedup(proc->ofile[i]);
8010535b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105361:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80105364:	83 c2 08             	add    $0x8,%edx
80105367:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010536b:	83 ec 0c             	sub    $0xc,%esp
8010536e:	50                   	push   %eax
8010536f:	e8 e4 bc ff ff       	call   80101058 <filedup>
80105374:	83 c4 10             	add    $0x10,%esp
80105377:	89 c1                	mov    %eax,%ecx
80105379:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010537c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010537f:	83 c2 08             	add    $0x8,%edx
80105382:	89 4c 90 08          	mov    %ecx,0x8(%eax,%edx,4)
  *np->tf = *proc->tf;

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
80105386:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
8010538a:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
8010538e:	7e b7                	jle    80105347 <fork+0xcf>
    if(proc->ofile[i])
      np->ofile[i] = filedup(proc->ofile[i]);
  np->cwd = idup(proc->cwd);
80105390:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105396:	8b 40 68             	mov    0x68(%eax),%eax
80105399:	83 ec 0c             	sub    $0xc,%esp
8010539c:	50                   	push   %eax
8010539d:	e8 16 cb ff ff       	call   80101eb8 <idup>
801053a2:	83 c4 10             	add    $0x10,%esp
801053a5:	89 c2                	mov    %eax,%edx
801053a7:	8b 45 e0             	mov    -0x20(%ebp),%eax
801053aa:	89 50 68             	mov    %edx,0x68(%eax)

  safestrcpy(np->name, proc->name, sizeof(proc->name));
801053ad:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801053b3:	8d 50 6c             	lea    0x6c(%eax),%edx
801053b6:	8b 45 e0             	mov    -0x20(%ebp),%eax
801053b9:	83 c0 6c             	add    $0x6c,%eax
801053bc:	83 ec 04             	sub    $0x4,%esp
801053bf:	6a 10                	push   $0x10
801053c1:	52                   	push   %edx
801053c2:	50                   	push   %eax
801053c3:	e8 2e 0c 00 00       	call   80105ff6 <safestrcpy>
801053c8:	83 c4 10             	add    $0x10,%esp
 
  pid = np->pid;
801053cb:	8b 45 e0             	mov    -0x20(%ebp),%eax
801053ce:	8b 40 10             	mov    0x10(%eax),%eax
801053d1:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // lock to force the compiler to emit the np->state write last.
  acquire(&ptable.lock);
801053d4:	83 ec 0c             	sub    $0xc,%esp
801053d7:	68 80 3e 11 80       	push   $0x80113e80
801053dc:	e8 af 07 00 00       	call   80105b90 <acquire>
801053e1:	83 c4 10             	add    $0x10,%esp
  np->state = RUNNABLE;
801053e4:	8b 45 e0             	mov    -0x20(%ebp),%eax
801053e7:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  release(&ptable.lock);
801053ee:	83 ec 0c             	sub    $0xc,%esp
801053f1:	68 80 3e 11 80       	push   $0x80113e80
801053f6:	e8 fc 07 00 00       	call   80105bf7 <release>
801053fb:	83 c4 10             	add    $0x10,%esp
  
  return pid;
801053fe:	8b 45 dc             	mov    -0x24(%ebp),%eax
}
80105401:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105404:	5b                   	pop    %ebx
80105405:	5e                   	pop    %esi
80105406:	5f                   	pop    %edi
80105407:	5d                   	pop    %ebp
80105408:	c3                   	ret    

80105409 <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
80105409:	55                   	push   %ebp
8010540a:	89 e5                	mov    %esp,%ebp
8010540c:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int fd;

  if(proc == initproc)
8010540f:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80105416:	a1 48 c6 10 80       	mov    0x8010c648,%eax
8010541b:	39 c2                	cmp    %eax,%edx
8010541d:	75 0d                	jne    8010542c <exit+0x23>
    panic("init exiting");
8010541f:	83 ec 0c             	sub    $0xc,%esp
80105422:	68 24 98 10 80       	push   $0x80109824
80105427:	e8 3a b1 ff ff       	call   80100566 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
8010542c:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80105433:	eb 48                	jmp    8010547d <exit+0x74>
    if(proc->ofile[fd]){
80105435:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010543b:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010543e:	83 c2 08             	add    $0x8,%edx
80105441:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105445:	85 c0                	test   %eax,%eax
80105447:	74 30                	je     80105479 <exit+0x70>
      fileclose(proc->ofile[fd]);
80105449:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010544f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105452:	83 c2 08             	add    $0x8,%edx
80105455:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105459:	83 ec 0c             	sub    $0xc,%esp
8010545c:	50                   	push   %eax
8010545d:	e8 47 bc ff ff       	call   801010a9 <fileclose>
80105462:	83 c4 10             	add    $0x10,%esp
      proc->ofile[fd] = 0;
80105465:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010546b:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010546e:	83 c2 08             	add    $0x8,%edx
80105471:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105478:	00 

  if(proc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80105479:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010547d:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
80105481:	7e b2                	jle    80105435 <exit+0x2c>
      fileclose(proc->ofile[fd]);
      proc->ofile[fd] = 0;
    }
  }

  begin_op(proc->cwd->part->number);
80105483:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105489:	8b 40 68             	mov    0x68(%eax),%eax
8010548c:	8b 40 50             	mov    0x50(%eax),%eax
8010548f:	8b 40 14             	mov    0x14(%eax),%eax
80105492:	83 ec 0c             	sub    $0xc,%esp
80105495:	50                   	push   %eax
80105496:	e8 17 ea ff ff       	call   80103eb2 <begin_op>
8010549b:	83 c4 10             	add    $0x10,%esp
  iput(proc->cwd);
8010549e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801054a4:	8b 40 68             	mov    0x68(%eax),%eax
801054a7:	83 ec 0c             	sub    $0xc,%esp
801054aa:	50                   	push   %eax
801054ab:	e8 55 cc ff ff       	call   80102105 <iput>
801054b0:	83 c4 10             	add    $0x10,%esp
  end_op(proc->cwd->part->number);
801054b3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801054b9:	8b 40 68             	mov    0x68(%eax),%eax
801054bc:	8b 40 50             	mov    0x50(%eax),%eax
801054bf:	8b 40 14             	mov    0x14(%eax),%eax
801054c2:	83 ec 0c             	sub    $0xc,%esp
801054c5:	50                   	push   %eax
801054c6:	e8 ee ea ff ff       	call   80103fb9 <end_op>
801054cb:	83 c4 10             	add    $0x10,%esp
  proc->cwd = 0;
801054ce:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801054d4:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
801054db:	83 ec 0c             	sub    $0xc,%esp
801054de:	68 80 3e 11 80       	push   $0x80113e80
801054e3:	e8 a8 06 00 00       	call   80105b90 <acquire>
801054e8:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);
801054eb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801054f1:	8b 40 14             	mov    0x14(%eax),%eax
801054f4:	83 ec 0c             	sub    $0xc,%esp
801054f7:	50                   	push   %eax
801054f8:	e8 46 04 00 00       	call   80105943 <wakeup1>
801054fd:	83 c4 10             	add    $0x10,%esp

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105500:	c7 45 f4 b4 3e 11 80 	movl   $0x80113eb4,-0xc(%ebp)
80105507:	eb 3c                	jmp    80105545 <exit+0x13c>
    if(p->parent == proc){
80105509:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010550c:	8b 50 14             	mov    0x14(%eax),%edx
8010550f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105515:	39 c2                	cmp    %eax,%edx
80105517:	75 28                	jne    80105541 <exit+0x138>
      p->parent = initproc;
80105519:	8b 15 48 c6 10 80    	mov    0x8010c648,%edx
8010551f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105522:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
80105525:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105528:	8b 40 0c             	mov    0xc(%eax),%eax
8010552b:	83 f8 05             	cmp    $0x5,%eax
8010552e:	75 11                	jne    80105541 <exit+0x138>
        wakeup1(initproc);
80105530:	a1 48 c6 10 80       	mov    0x8010c648,%eax
80105535:	83 ec 0c             	sub    $0xc,%esp
80105538:	50                   	push   %eax
80105539:	e8 05 04 00 00       	call   80105943 <wakeup1>
8010553e:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105541:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80105545:	81 7d f4 b4 5d 11 80 	cmpl   $0x80115db4,-0xc(%ebp)
8010554c:	72 bb                	jb     80105509 <exit+0x100>
        wakeup1(initproc);
    }
  }

  // Jump into the scheduler, never to return.
  proc->state = ZOMBIE;
8010554e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105554:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
8010555b:	e8 d6 01 00 00       	call   80105736 <sched>
  panic("zombie exit");
80105560:	83 ec 0c             	sub    $0xc,%esp
80105563:	68 31 98 10 80       	push   $0x80109831
80105568:	e8 f9 af ff ff       	call   80100566 <panic>

8010556d <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
8010556d:	55                   	push   %ebp
8010556e:	89 e5                	mov    %esp,%ebp
80105570:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int havekids, pid;

  acquire(&ptable.lock);
80105573:	83 ec 0c             	sub    $0xc,%esp
80105576:	68 80 3e 11 80       	push   $0x80113e80
8010557b:	e8 10 06 00 00       	call   80105b90 <acquire>
80105580:	83 c4 10             	add    $0x10,%esp
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
80105583:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010558a:	c7 45 f4 b4 3e 11 80 	movl   $0x80113eb4,-0xc(%ebp)
80105591:	e9 a6 00 00 00       	jmp    8010563c <wait+0xcf>
      if(p->parent != proc)
80105596:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105599:	8b 50 14             	mov    0x14(%eax),%edx
8010559c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801055a2:	39 c2                	cmp    %eax,%edx
801055a4:	0f 85 8d 00 00 00    	jne    80105637 <wait+0xca>
        continue;
      havekids = 1;
801055aa:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
801055b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055b4:	8b 40 0c             	mov    0xc(%eax),%eax
801055b7:	83 f8 05             	cmp    $0x5,%eax
801055ba:	75 7c                	jne    80105638 <wait+0xcb>
        // Found one.
        pid = p->pid;
801055bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055bf:	8b 40 10             	mov    0x10(%eax),%eax
801055c2:	89 45 ec             	mov    %eax,-0x14(%ebp)
        kfree(p->kstack);
801055c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055c8:	8b 40 08             	mov    0x8(%eax),%eax
801055cb:	83 ec 0c             	sub    $0xc,%esp
801055ce:	50                   	push   %eax
801055cf:	e8 0a de ff ff       	call   801033de <kfree>
801055d4:	83 c4 10             	add    $0x10,%esp
        p->kstack = 0;
801055d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055da:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
801055e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055e4:	8b 40 04             	mov    0x4(%eax),%eax
801055e7:	83 ec 0c             	sub    $0xc,%esp
801055ea:	50                   	push   %eax
801055eb:	e8 0c 3b 00 00       	call   801090fc <freevm>
801055f0:	83 c4 10             	add    $0x10,%esp
        p->state = UNUSED;
801055f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055f6:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        p->pid = 0;
801055fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105600:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
80105607:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010560a:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
80105611:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105614:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
80105618:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010561b:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        release(&ptable.lock);
80105622:	83 ec 0c             	sub    $0xc,%esp
80105625:	68 80 3e 11 80       	push   $0x80113e80
8010562a:	e8 c8 05 00 00       	call   80105bf7 <release>
8010562f:	83 c4 10             	add    $0x10,%esp
        return pid;
80105632:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105635:	eb 58                	jmp    8010568f <wait+0x122>
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->parent != proc)
        continue;
80105637:	90                   	nop

  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105638:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
8010563c:	81 7d f4 b4 5d 11 80 	cmpl   $0x80115db4,-0xc(%ebp)
80105643:	0f 82 4d ff ff ff    	jb     80105596 <wait+0x29>
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
80105649:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010564d:	74 0d                	je     8010565c <wait+0xef>
8010564f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105655:	8b 40 24             	mov    0x24(%eax),%eax
80105658:	85 c0                	test   %eax,%eax
8010565a:	74 17                	je     80105673 <wait+0x106>
      release(&ptable.lock);
8010565c:	83 ec 0c             	sub    $0xc,%esp
8010565f:	68 80 3e 11 80       	push   $0x80113e80
80105664:	e8 8e 05 00 00       	call   80105bf7 <release>
80105669:	83 c4 10             	add    $0x10,%esp
      return -1;
8010566c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105671:	eb 1c                	jmp    8010568f <wait+0x122>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
80105673:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105679:	83 ec 08             	sub    $0x8,%esp
8010567c:	68 80 3e 11 80       	push   $0x80113e80
80105681:	50                   	push   %eax
80105682:	e8 10 02 00 00       	call   80105897 <sleep>
80105687:	83 c4 10             	add    $0x10,%esp
  }
8010568a:	e9 f4 fe ff ff       	jmp    80105583 <wait+0x16>
}
8010568f:	c9                   	leave  
80105690:	c3                   	ret    

80105691 <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
80105691:	55                   	push   %ebp
80105692:	89 e5                	mov    %esp,%ebp
80105694:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  for(;;){
    // Enable interrupts on this processor.
    sti();
80105697:	e8 f3 f8 ff ff       	call   80104f8f <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
8010569c:	83 ec 0c             	sub    $0xc,%esp
8010569f:	68 80 3e 11 80       	push   $0x80113e80
801056a4:	e8 e7 04 00 00       	call   80105b90 <acquire>
801056a9:	83 c4 10             	add    $0x10,%esp
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801056ac:	c7 45 f4 b4 3e 11 80 	movl   $0x80113eb4,-0xc(%ebp)
801056b3:	eb 63                	jmp    80105718 <scheduler+0x87>
      if(p->state != RUNNABLE)
801056b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056b8:	8b 40 0c             	mov    0xc(%eax),%eax
801056bb:	83 f8 03             	cmp    $0x3,%eax
801056be:	75 53                	jne    80105713 <scheduler+0x82>
        continue;

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      proc = p;
801056c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056c3:	65 a3 04 00 00 00    	mov    %eax,%gs:0x4
      switchuvm(p);
801056c9:	83 ec 0c             	sub    $0xc,%esp
801056cc:	ff 75 f4             	pushl  -0xc(%ebp)
801056cf:	e8 e2 35 00 00       	call   80108cb6 <switchuvm>
801056d4:	83 c4 10             	add    $0x10,%esp
      p->state = RUNNING;
801056d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056da:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)
     // cprintf("selected %s \n",p->chan);
      swtch(&cpu->scheduler, proc->context);
801056e1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801056e7:	8b 40 1c             	mov    0x1c(%eax),%eax
801056ea:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
801056f1:	83 c2 04             	add    $0x4,%edx
801056f4:	83 ec 08             	sub    $0x8,%esp
801056f7:	50                   	push   %eax
801056f8:	52                   	push   %edx
801056f9:	e8 69 09 00 00       	call   80106067 <swtch>
801056fe:	83 c4 10             	add    $0x10,%esp
      switchkvm();
80105701:	e8 93 35 00 00       	call   80108c99 <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
80105706:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
8010570d:	00 00 00 00 
80105711:	eb 01                	jmp    80105714 <scheduler+0x83>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->state != RUNNABLE)
        continue;
80105713:	90                   	nop
    // Enable interrupts on this processor.
    sti();

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105714:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80105718:	81 7d f4 b4 5d 11 80 	cmpl   $0x80115db4,-0xc(%ebp)
8010571f:	72 94                	jb     801056b5 <scheduler+0x24>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
    }
    release(&ptable.lock);
80105721:	83 ec 0c             	sub    $0xc,%esp
80105724:	68 80 3e 11 80       	push   $0x80113e80
80105729:	e8 c9 04 00 00       	call   80105bf7 <release>
8010572e:	83 c4 10             	add    $0x10,%esp

  }
80105731:	e9 61 ff ff ff       	jmp    80105697 <scheduler+0x6>

80105736 <sched>:

// Enter scheduler.  Must hold only ptable.lock
// and have changed proc->state.
void
sched(void)
{
80105736:	55                   	push   %ebp
80105737:	89 e5                	mov    %esp,%ebp
80105739:	83 ec 18             	sub    $0x18,%esp
  int intena;

  if(!holding(&ptable.lock))
8010573c:	83 ec 0c             	sub    $0xc,%esp
8010573f:	68 80 3e 11 80       	push   $0x80113e80
80105744:	e8 7a 05 00 00       	call   80105cc3 <holding>
80105749:	83 c4 10             	add    $0x10,%esp
8010574c:	85 c0                	test   %eax,%eax
8010574e:	75 0d                	jne    8010575d <sched+0x27>
    panic("sched ptable.lock");
80105750:	83 ec 0c             	sub    $0xc,%esp
80105753:	68 3d 98 10 80       	push   $0x8010983d
80105758:	e8 09 ae ff ff       	call   80100566 <panic>
  if(cpu->ncli != 1)
8010575d:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105763:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80105769:	83 f8 01             	cmp    $0x1,%eax
8010576c:	74 0d                	je     8010577b <sched+0x45>
   panic("sched locks");
8010576e:	83 ec 0c             	sub    $0xc,%esp
80105771:	68 4f 98 10 80       	push   $0x8010984f
80105776:	e8 eb ad ff ff       	call   80100566 <panic>
  if(proc->state == RUNNING)
8010577b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105781:	8b 40 0c             	mov    0xc(%eax),%eax
80105784:	83 f8 04             	cmp    $0x4,%eax
80105787:	75 0d                	jne    80105796 <sched+0x60>
    panic("sched running");
80105789:	83 ec 0c             	sub    $0xc,%esp
8010578c:	68 5b 98 10 80       	push   $0x8010985b
80105791:	e8 d0 ad ff ff       	call   80100566 <panic>
  if(readeflags()&FL_IF)
80105796:	e8 e4 f7 ff ff       	call   80104f7f <readeflags>
8010579b:	25 00 02 00 00       	and    $0x200,%eax
801057a0:	85 c0                	test   %eax,%eax
801057a2:	74 0d                	je     801057b1 <sched+0x7b>
    panic("sched interruptible");
801057a4:	83 ec 0c             	sub    $0xc,%esp
801057a7:	68 69 98 10 80       	push   $0x80109869
801057ac:	e8 b5 ad ff ff       	call   80100566 <panic>
  intena = cpu->intena;
801057b1:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801057b7:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
801057bd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  swtch(&proc->context, cpu->scheduler);
801057c0:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801057c6:	8b 40 04             	mov    0x4(%eax),%eax
801057c9:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801057d0:	83 c2 1c             	add    $0x1c,%edx
801057d3:	83 ec 08             	sub    $0x8,%esp
801057d6:	50                   	push   %eax
801057d7:	52                   	push   %edx
801057d8:	e8 8a 08 00 00       	call   80106067 <swtch>
801057dd:	83 c4 10             	add    $0x10,%esp
  cpu->intena = intena;
801057e0:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801057e6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801057e9:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
801057ef:	90                   	nop
801057f0:	c9                   	leave  
801057f1:	c3                   	ret    

801057f2 <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
801057f2:	55                   	push   %ebp
801057f3:	89 e5                	mov    %esp,%ebp
801057f5:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
801057f8:	83 ec 0c             	sub    $0xc,%esp
801057fb:	68 80 3e 11 80       	push   $0x80113e80
80105800:	e8 8b 03 00 00       	call   80105b90 <acquire>
80105805:	83 c4 10             	add    $0x10,%esp
  proc->state = RUNNABLE;
80105808:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010580e:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80105815:	e8 1c ff ff ff       	call   80105736 <sched>
  release(&ptable.lock);
8010581a:	83 ec 0c             	sub    $0xc,%esp
8010581d:	68 80 3e 11 80       	push   $0x80113e80
80105822:	e8 d0 03 00 00       	call   80105bf7 <release>
80105827:	83 c4 10             	add    $0x10,%esp
}
8010582a:	90                   	nop
8010582b:	c9                   	leave  
8010582c:	c3                   	ret    

8010582d <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
8010582d:	55                   	push   %ebp
8010582e:	89 e5                	mov    %esp,%ebp
80105830:	83 ec 08             	sub    $0x8,%esp
  static int first = 1;
 // static int iinitDone=0;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80105833:	83 ec 0c             	sub    $0xc,%esp
80105836:	68 80 3e 11 80       	push   $0x80113e80
8010583b:	e8 b7 03 00 00       	call   80105bf7 <release>
80105840:	83 c4 10             	add    $0x10,%esp


  if (first) {
80105843:	a1 08 c0 10 80       	mov    0x8010c008,%eax
80105848:	85 c0                	test   %eax,%eax
8010584a:	74 48                	je     80105894 <forkret+0x67>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot 
    // be run from main().
    first = 0;
8010584c:	c7 05 08 c0 10 80 00 	movl   $0x0,0x8010c008
80105853:	00 00 00 
    cprintf("cpu %d iinit \n",cpu->id);
80105856:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010585c:	0f b6 00             	movzbl (%eax),%eax
8010585f:	0f b6 c0             	movzbl %al,%eax
80105862:	83 ec 08             	sub    $0x8,%esp
80105865:	50                   	push   %eax
80105866:	68 7d 98 10 80       	push   $0x8010987d
8010586b:	e8 56 ab ff ff       	call   801003c6 <cprintf>
80105870:	83 c4 10             	add    $0x10,%esp
iinit(proc,ROOTDEV);
80105873:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105879:	83 ec 08             	sub    $0x8,%esp
8010587c:	6a 01                	push   $0x1
8010587e:	50                   	push   %eax
8010587f:	e8 ae c1 ff ff       	call   80101a32 <iinit>
80105884:	83 c4 10             	add    $0x10,%esp
    // iinitDone=1;
   // cprintf("boot from after iinit is %d \n",bootfrom);
    initlog(ROOTDEV);
80105887:	83 ec 0c             	sub    $0xc,%esp
8010588a:	6a 01                	push   $0x1
8010588c:	e8 b3 e2 ff ff       	call   80103b44 <initlog>
80105891:	83 c4 10             	add    $0x10,%esp
 // }

 
  
  // Return to "caller", actually trapret (see allocproc).
}
80105894:	90                   	nop
80105895:	c9                   	leave  
80105896:	c3                   	ret    

80105897 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
80105897:	55                   	push   %ebp
80105898:	89 e5                	mov    %esp,%ebp
8010589a:	83 ec 08             	sub    $0x8,%esp
  if(proc == 0)
8010589d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801058a3:	85 c0                	test   %eax,%eax
801058a5:	75 0d                	jne    801058b4 <sleep+0x1d>
    panic("sleep");
801058a7:	83 ec 0c             	sub    $0xc,%esp
801058aa:	68 8c 98 10 80       	push   $0x8010988c
801058af:	e8 b2 ac ff ff       	call   80100566 <panic>

  if(lk == 0)
801058b4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801058b8:	75 0d                	jne    801058c7 <sleep+0x30>
    panic("sleep without lk");
801058ba:	83 ec 0c             	sub    $0xc,%esp
801058bd:	68 92 98 10 80       	push   $0x80109892
801058c2:	e8 9f ac ff ff       	call   80100566 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
801058c7:	81 7d 0c 80 3e 11 80 	cmpl   $0x80113e80,0xc(%ebp)
801058ce:	74 1e                	je     801058ee <sleep+0x57>
    acquire(&ptable.lock);  //DOC: sleeplock1
801058d0:	83 ec 0c             	sub    $0xc,%esp
801058d3:	68 80 3e 11 80       	push   $0x80113e80
801058d8:	e8 b3 02 00 00       	call   80105b90 <acquire>
801058dd:	83 c4 10             	add    $0x10,%esp
    release(lk);
801058e0:	83 ec 0c             	sub    $0xc,%esp
801058e3:	ff 75 0c             	pushl  0xc(%ebp)
801058e6:	e8 0c 03 00 00       	call   80105bf7 <release>
801058eb:	83 c4 10             	add    $0x10,%esp
  }

  // Go to sleep.
  proc->chan = chan;
801058ee:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801058f4:	8b 55 08             	mov    0x8(%ebp),%edx
801058f7:	89 50 20             	mov    %edx,0x20(%eax)
  proc->state = SLEEPING;
801058fa:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105900:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)
  sched();
80105907:	e8 2a fe ff ff       	call   80105736 <sched>

  // Tidy up.
  proc->chan = 0;
8010590c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105912:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
80105919:	81 7d 0c 80 3e 11 80 	cmpl   $0x80113e80,0xc(%ebp)
80105920:	74 1e                	je     80105940 <sleep+0xa9>
    release(&ptable.lock);
80105922:	83 ec 0c             	sub    $0xc,%esp
80105925:	68 80 3e 11 80       	push   $0x80113e80
8010592a:	e8 c8 02 00 00       	call   80105bf7 <release>
8010592f:	83 c4 10             	add    $0x10,%esp
    acquire(lk);
80105932:	83 ec 0c             	sub    $0xc,%esp
80105935:	ff 75 0c             	pushl  0xc(%ebp)
80105938:	e8 53 02 00 00       	call   80105b90 <acquire>
8010593d:	83 c4 10             	add    $0x10,%esp
  }
}
80105940:	90                   	nop
80105941:	c9                   	leave  
80105942:	c3                   	ret    

80105943 <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80105943:	55                   	push   %ebp
80105944:	89 e5                	mov    %esp,%ebp
80105946:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80105949:	c7 45 fc b4 3e 11 80 	movl   $0x80113eb4,-0x4(%ebp)
80105950:	eb 24                	jmp    80105976 <wakeup1+0x33>
    if(p->state == SLEEPING && p->chan == chan)
80105952:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105955:	8b 40 0c             	mov    0xc(%eax),%eax
80105958:	83 f8 02             	cmp    $0x2,%eax
8010595b:	75 15                	jne    80105972 <wakeup1+0x2f>
8010595d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105960:	8b 40 20             	mov    0x20(%eax),%eax
80105963:	3b 45 08             	cmp    0x8(%ebp),%eax
80105966:	75 0a                	jne    80105972 <wakeup1+0x2f>
      p->state = RUNNABLE;
80105968:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010596b:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80105972:	83 45 fc 7c          	addl   $0x7c,-0x4(%ebp)
80105976:	81 7d fc b4 5d 11 80 	cmpl   $0x80115db4,-0x4(%ebp)
8010597d:	72 d3                	jb     80105952 <wakeup1+0xf>
    if(p->state == SLEEPING && p->chan == chan)
      p->state = RUNNABLE;
}
8010597f:	90                   	nop
80105980:	c9                   	leave  
80105981:	c3                   	ret    

80105982 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80105982:	55                   	push   %ebp
80105983:	89 e5                	mov    %esp,%ebp
80105985:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);
80105988:	83 ec 0c             	sub    $0xc,%esp
8010598b:	68 80 3e 11 80       	push   $0x80113e80
80105990:	e8 fb 01 00 00       	call   80105b90 <acquire>
80105995:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
80105998:	83 ec 0c             	sub    $0xc,%esp
8010599b:	ff 75 08             	pushl  0x8(%ebp)
8010599e:	e8 a0 ff ff ff       	call   80105943 <wakeup1>
801059a3:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
801059a6:	83 ec 0c             	sub    $0xc,%esp
801059a9:	68 80 3e 11 80       	push   $0x80113e80
801059ae:	e8 44 02 00 00       	call   80105bf7 <release>
801059b3:	83 c4 10             	add    $0x10,%esp
}
801059b6:	90                   	nop
801059b7:	c9                   	leave  
801059b8:	c3                   	ret    

801059b9 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
801059b9:	55                   	push   %ebp
801059ba:	89 e5                	mov    %esp,%ebp
801059bc:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  acquire(&ptable.lock);
801059bf:	83 ec 0c             	sub    $0xc,%esp
801059c2:	68 80 3e 11 80       	push   $0x80113e80
801059c7:	e8 c4 01 00 00       	call   80105b90 <acquire>
801059cc:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801059cf:	c7 45 f4 b4 3e 11 80 	movl   $0x80113eb4,-0xc(%ebp)
801059d6:	eb 45                	jmp    80105a1d <kill+0x64>
    if(p->pid == pid){
801059d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059db:	8b 40 10             	mov    0x10(%eax),%eax
801059de:	3b 45 08             	cmp    0x8(%ebp),%eax
801059e1:	75 36                	jne    80105a19 <kill+0x60>
      p->killed = 1;
801059e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059e6:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
801059ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059f0:	8b 40 0c             	mov    0xc(%eax),%eax
801059f3:	83 f8 02             	cmp    $0x2,%eax
801059f6:	75 0a                	jne    80105a02 <kill+0x49>
        p->state = RUNNABLE;
801059f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059fb:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
80105a02:	83 ec 0c             	sub    $0xc,%esp
80105a05:	68 80 3e 11 80       	push   $0x80113e80
80105a0a:	e8 e8 01 00 00       	call   80105bf7 <release>
80105a0f:	83 c4 10             	add    $0x10,%esp
      return 0;
80105a12:	b8 00 00 00 00       	mov    $0x0,%eax
80105a17:	eb 22                	jmp    80105a3b <kill+0x82>
kill(int pid)
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105a19:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80105a1d:	81 7d f4 b4 5d 11 80 	cmpl   $0x80115db4,-0xc(%ebp)
80105a24:	72 b2                	jb     801059d8 <kill+0x1f>
        p->state = RUNNABLE;
      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
80105a26:	83 ec 0c             	sub    $0xc,%esp
80105a29:	68 80 3e 11 80       	push   $0x80113e80
80105a2e:	e8 c4 01 00 00       	call   80105bf7 <release>
80105a33:	83 c4 10             	add    $0x10,%esp
  return -1;
80105a36:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105a3b:	c9                   	leave  
80105a3c:	c3                   	ret    

80105a3d <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80105a3d:	55                   	push   %ebp
80105a3e:	89 e5                	mov    %esp,%ebp
80105a40:	83 ec 48             	sub    $0x48,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105a43:	c7 45 f0 b4 3e 11 80 	movl   $0x80113eb4,-0x10(%ebp)
80105a4a:	e9 d7 00 00 00       	jmp    80105b26 <procdump+0xe9>
    if(p->state == UNUSED)
80105a4f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a52:	8b 40 0c             	mov    0xc(%eax),%eax
80105a55:	85 c0                	test   %eax,%eax
80105a57:	0f 84 c4 00 00 00    	je     80105b21 <procdump+0xe4>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80105a5d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a60:	8b 40 0c             	mov    0xc(%eax),%eax
80105a63:	83 f8 05             	cmp    $0x5,%eax
80105a66:	77 23                	ja     80105a8b <procdump+0x4e>
80105a68:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a6b:	8b 40 0c             	mov    0xc(%eax),%eax
80105a6e:	8b 04 85 0c c0 10 80 	mov    -0x7fef3ff4(,%eax,4),%eax
80105a75:	85 c0                	test   %eax,%eax
80105a77:	74 12                	je     80105a8b <procdump+0x4e>
      state = states[p->state];
80105a79:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a7c:	8b 40 0c             	mov    0xc(%eax),%eax
80105a7f:	8b 04 85 0c c0 10 80 	mov    -0x7fef3ff4(,%eax,4),%eax
80105a86:	89 45 ec             	mov    %eax,-0x14(%ebp)
80105a89:	eb 07                	jmp    80105a92 <procdump+0x55>
    else
      state = "???";
80105a8b:	c7 45 ec a3 98 10 80 	movl   $0x801098a3,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
80105a92:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a95:	8d 50 6c             	lea    0x6c(%eax),%edx
80105a98:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a9b:	8b 40 10             	mov    0x10(%eax),%eax
80105a9e:	52                   	push   %edx
80105a9f:	ff 75 ec             	pushl  -0x14(%ebp)
80105aa2:	50                   	push   %eax
80105aa3:	68 a7 98 10 80       	push   $0x801098a7
80105aa8:	e8 19 a9 ff ff       	call   801003c6 <cprintf>
80105aad:	83 c4 10             	add    $0x10,%esp
    if(p->state == SLEEPING){
80105ab0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ab3:	8b 40 0c             	mov    0xc(%eax),%eax
80105ab6:	83 f8 02             	cmp    $0x2,%eax
80105ab9:	75 54                	jne    80105b0f <procdump+0xd2>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80105abb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105abe:	8b 40 1c             	mov    0x1c(%eax),%eax
80105ac1:	8b 40 0c             	mov    0xc(%eax),%eax
80105ac4:	83 c0 08             	add    $0x8,%eax
80105ac7:	89 c2                	mov    %eax,%edx
80105ac9:	83 ec 08             	sub    $0x8,%esp
80105acc:	8d 45 c4             	lea    -0x3c(%ebp),%eax
80105acf:	50                   	push   %eax
80105ad0:	52                   	push   %edx
80105ad1:	e8 73 01 00 00       	call   80105c49 <getcallerpcs>
80105ad6:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
80105ad9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80105ae0:	eb 1c                	jmp    80105afe <procdump+0xc1>
        cprintf(" %p", pc[i]);
80105ae2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ae5:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80105ae9:	83 ec 08             	sub    $0x8,%esp
80105aec:	50                   	push   %eax
80105aed:	68 b0 98 10 80       	push   $0x801098b0
80105af2:	e8 cf a8 ff ff       	call   801003c6 <cprintf>
80105af7:	83 c4 10             	add    $0x10,%esp
    else
      state = "???";
    cprintf("%d %s %s", p->pid, state, p->name);
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
80105afa:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80105afe:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80105b02:	7f 0b                	jg     80105b0f <procdump+0xd2>
80105b04:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b07:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80105b0b:	85 c0                	test   %eax,%eax
80105b0d:	75 d3                	jne    80105ae2 <procdump+0xa5>
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
80105b0f:	83 ec 0c             	sub    $0xc,%esp
80105b12:	68 b4 98 10 80       	push   $0x801098b4
80105b17:	e8 aa a8 ff ff       	call   801003c6 <cprintf>
80105b1c:	83 c4 10             	add    $0x10,%esp
80105b1f:	eb 01                	jmp    80105b22 <procdump+0xe5>
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->state == UNUSED)
      continue;
80105b21:	90                   	nop
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105b22:	83 45 f0 7c          	addl   $0x7c,-0x10(%ebp)
80105b26:	81 7d f0 b4 5d 11 80 	cmpl   $0x80115db4,-0x10(%ebp)
80105b2d:	0f 82 1c ff ff ff    	jb     80105a4f <procdump+0x12>
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }
}
80105b33:	90                   	nop
80105b34:	c9                   	leave  
80105b35:	c3                   	ret    

80105b36 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80105b36:	55                   	push   %ebp
80105b37:	89 e5                	mov    %esp,%ebp
80105b39:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80105b3c:	9c                   	pushf  
80105b3d:	58                   	pop    %eax
80105b3e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80105b41:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105b44:	c9                   	leave  
80105b45:	c3                   	ret    

80105b46 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80105b46:	55                   	push   %ebp
80105b47:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80105b49:	fa                   	cli    
}
80105b4a:	90                   	nop
80105b4b:	5d                   	pop    %ebp
80105b4c:	c3                   	ret    

80105b4d <sti>:

static inline void
sti(void)
{
80105b4d:	55                   	push   %ebp
80105b4e:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80105b50:	fb                   	sti    
}
80105b51:	90                   	nop
80105b52:	5d                   	pop    %ebp
80105b53:	c3                   	ret    

80105b54 <xchg>:

static inline uint
xchg(volatile uint *addr, uint newval)
{
80105b54:	55                   	push   %ebp
80105b55:	89 e5                	mov    %esp,%ebp
80105b57:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80105b5a:	8b 55 08             	mov    0x8(%ebp),%edx
80105b5d:	8b 45 0c             	mov    0xc(%ebp),%eax
80105b60:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105b63:	f0 87 02             	lock xchg %eax,(%edx)
80105b66:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80105b69:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105b6c:	c9                   	leave  
80105b6d:	c3                   	ret    

80105b6e <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80105b6e:	55                   	push   %ebp
80105b6f:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80105b71:	8b 45 08             	mov    0x8(%ebp),%eax
80105b74:	8b 55 0c             	mov    0xc(%ebp),%edx
80105b77:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80105b7a:	8b 45 08             	mov    0x8(%ebp),%eax
80105b7d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80105b83:	8b 45 08             	mov    0x8(%ebp),%eax
80105b86:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80105b8d:	90                   	nop
80105b8e:	5d                   	pop    %ebp
80105b8f:	c3                   	ret    

80105b90 <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80105b90:	55                   	push   %ebp
80105b91:	89 e5                	mov    %esp,%ebp
80105b93:	83 ec 08             	sub    $0x8,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80105b96:	e8 52 01 00 00       	call   80105ced <pushcli>
  if(holding(lk))
80105b9b:	8b 45 08             	mov    0x8(%ebp),%eax
80105b9e:	83 ec 0c             	sub    $0xc,%esp
80105ba1:	50                   	push   %eax
80105ba2:	e8 1c 01 00 00       	call   80105cc3 <holding>
80105ba7:	83 c4 10             	add    $0x10,%esp
80105baa:	85 c0                	test   %eax,%eax
80105bac:	74 0d                	je     80105bbb <acquire+0x2b>
    panic("acquire");
80105bae:	83 ec 0c             	sub    $0xc,%esp
80105bb1:	68 e0 98 10 80       	push   $0x801098e0
80105bb6:	e8 ab a9 ff ff       	call   80100566 <panic>

  // The xchg is atomic.
  // It also serializes, so that reads after acquire are not
  // reordered before it. 
  while(xchg(&lk->locked, 1) != 0)
80105bbb:	90                   	nop
80105bbc:	8b 45 08             	mov    0x8(%ebp),%eax
80105bbf:	83 ec 08             	sub    $0x8,%esp
80105bc2:	6a 01                	push   $0x1
80105bc4:	50                   	push   %eax
80105bc5:	e8 8a ff ff ff       	call   80105b54 <xchg>
80105bca:	83 c4 10             	add    $0x10,%esp
80105bcd:	85 c0                	test   %eax,%eax
80105bcf:	75 eb                	jne    80105bbc <acquire+0x2c>
    ;

  // Record info about lock acquisition for debugging.
  lk->cpu = cpu;
80105bd1:	8b 45 08             	mov    0x8(%ebp),%eax
80105bd4:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80105bdb:	89 50 08             	mov    %edx,0x8(%eax)
  getcallerpcs(&lk, lk->pcs);
80105bde:	8b 45 08             	mov    0x8(%ebp),%eax
80105be1:	83 c0 0c             	add    $0xc,%eax
80105be4:	83 ec 08             	sub    $0x8,%esp
80105be7:	50                   	push   %eax
80105be8:	8d 45 08             	lea    0x8(%ebp),%eax
80105beb:	50                   	push   %eax
80105bec:	e8 58 00 00 00       	call   80105c49 <getcallerpcs>
80105bf1:	83 c4 10             	add    $0x10,%esp
}
80105bf4:	90                   	nop
80105bf5:	c9                   	leave  
80105bf6:	c3                   	ret    

80105bf7 <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80105bf7:	55                   	push   %ebp
80105bf8:	89 e5                	mov    %esp,%ebp
80105bfa:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
80105bfd:	83 ec 0c             	sub    $0xc,%esp
80105c00:	ff 75 08             	pushl  0x8(%ebp)
80105c03:	e8 bb 00 00 00       	call   80105cc3 <holding>
80105c08:	83 c4 10             	add    $0x10,%esp
80105c0b:	85 c0                	test   %eax,%eax
80105c0d:	75 0d                	jne    80105c1c <release+0x25>
    panic("release");
80105c0f:	83 ec 0c             	sub    $0xc,%esp
80105c12:	68 e8 98 10 80       	push   $0x801098e8
80105c17:	e8 4a a9 ff ff       	call   80100566 <panic>

  lk->pcs[0] = 0;
80105c1c:	8b 45 08             	mov    0x8(%ebp),%eax
80105c1f:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
80105c26:	8b 45 08             	mov    0x8(%ebp),%eax
80105c29:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // But the 2007 Intel 64 Architecture Memory Ordering White
  // Paper says that Intel 64 and IA-32 will not move a load
  // after a store. So lock->locked = 0 would work here.
  // The xchg being asm volatile ensures gcc emits it after
  // the above assignments (and after the critical section).
  xchg(&lk->locked, 0);
80105c30:	8b 45 08             	mov    0x8(%ebp),%eax
80105c33:	83 ec 08             	sub    $0x8,%esp
80105c36:	6a 00                	push   $0x0
80105c38:	50                   	push   %eax
80105c39:	e8 16 ff ff ff       	call   80105b54 <xchg>
80105c3e:	83 c4 10             	add    $0x10,%esp

  popcli();
80105c41:	e8 ec 00 00 00       	call   80105d32 <popcli>
}
80105c46:	90                   	nop
80105c47:	c9                   	leave  
80105c48:	c3                   	ret    

80105c49 <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80105c49:	55                   	push   %ebp
80105c4a:	89 e5                	mov    %esp,%ebp
80105c4c:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
80105c4f:	8b 45 08             	mov    0x8(%ebp),%eax
80105c52:	83 e8 08             	sub    $0x8,%eax
80105c55:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80105c58:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80105c5f:	eb 38                	jmp    80105c99 <getcallerpcs+0x50>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80105c61:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80105c65:	74 53                	je     80105cba <getcallerpcs+0x71>
80105c67:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80105c6e:	76 4a                	jbe    80105cba <getcallerpcs+0x71>
80105c70:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
80105c74:	74 44                	je     80105cba <getcallerpcs+0x71>
      break;
    pcs[i] = ebp[1];     // saved %eip
80105c76:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105c79:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80105c80:	8b 45 0c             	mov    0xc(%ebp),%eax
80105c83:	01 c2                	add    %eax,%edx
80105c85:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105c88:	8b 40 04             	mov    0x4(%eax),%eax
80105c8b:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
80105c8d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105c90:	8b 00                	mov    (%eax),%eax
80105c92:	89 45 fc             	mov    %eax,-0x4(%ebp)
{
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
80105c95:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80105c99:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105c9d:	7e c2                	jle    80105c61 <getcallerpcs+0x18>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80105c9f:	eb 19                	jmp    80105cba <getcallerpcs+0x71>
    pcs[i] = 0;
80105ca1:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105ca4:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80105cab:	8b 45 0c             	mov    0xc(%ebp),%eax
80105cae:	01 d0                	add    %edx,%eax
80105cb0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80105cb6:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80105cba:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105cbe:	7e e1                	jle    80105ca1 <getcallerpcs+0x58>
    pcs[i] = 0;
}
80105cc0:	90                   	nop
80105cc1:	c9                   	leave  
80105cc2:	c3                   	ret    

80105cc3 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80105cc3:	55                   	push   %ebp
80105cc4:	89 e5                	mov    %esp,%ebp
  return lock->locked && lock->cpu == cpu;
80105cc6:	8b 45 08             	mov    0x8(%ebp),%eax
80105cc9:	8b 00                	mov    (%eax),%eax
80105ccb:	85 c0                	test   %eax,%eax
80105ccd:	74 17                	je     80105ce6 <holding+0x23>
80105ccf:	8b 45 08             	mov    0x8(%ebp),%eax
80105cd2:	8b 50 08             	mov    0x8(%eax),%edx
80105cd5:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105cdb:	39 c2                	cmp    %eax,%edx
80105cdd:	75 07                	jne    80105ce6 <holding+0x23>
80105cdf:	b8 01 00 00 00       	mov    $0x1,%eax
80105ce4:	eb 05                	jmp    80105ceb <holding+0x28>
80105ce6:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105ceb:	5d                   	pop    %ebp
80105cec:	c3                   	ret    

80105ced <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80105ced:	55                   	push   %ebp
80105cee:	89 e5                	mov    %esp,%ebp
80105cf0:	83 ec 10             	sub    $0x10,%esp
  int eflags;
  
  eflags = readeflags();
80105cf3:	e8 3e fe ff ff       	call   80105b36 <readeflags>
80105cf8:	89 45 fc             	mov    %eax,-0x4(%ebp)
  cli();
80105cfb:	e8 46 fe ff ff       	call   80105b46 <cli>
  if(cpu->ncli++ == 0)
80105d00:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80105d07:	8b 82 ac 00 00 00    	mov    0xac(%edx),%eax
80105d0d:	8d 48 01             	lea    0x1(%eax),%ecx
80105d10:	89 8a ac 00 00 00    	mov    %ecx,0xac(%edx)
80105d16:	85 c0                	test   %eax,%eax
80105d18:	75 15                	jne    80105d2f <pushcli+0x42>
    cpu->intena = eflags & FL_IF;
80105d1a:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105d20:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105d23:	81 e2 00 02 00 00    	and    $0x200,%edx
80105d29:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
80105d2f:	90                   	nop
80105d30:	c9                   	leave  
80105d31:	c3                   	ret    

80105d32 <popcli>:

void
popcli(void)
{
80105d32:	55                   	push   %ebp
80105d33:	89 e5                	mov    %esp,%ebp
80105d35:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
80105d38:	e8 f9 fd ff ff       	call   80105b36 <readeflags>
80105d3d:	25 00 02 00 00       	and    $0x200,%eax
80105d42:	85 c0                	test   %eax,%eax
80105d44:	74 0d                	je     80105d53 <popcli+0x21>
    panic("popcli - interruptible");
80105d46:	83 ec 0c             	sub    $0xc,%esp
80105d49:	68 f0 98 10 80       	push   $0x801098f0
80105d4e:	e8 13 a8 ff ff       	call   80100566 <panic>
  if(--cpu->ncli < 0)
80105d53:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105d59:	8b 90 ac 00 00 00    	mov    0xac(%eax),%edx
80105d5f:	83 ea 01             	sub    $0x1,%edx
80105d62:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
80105d68:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80105d6e:	85 c0                	test   %eax,%eax
80105d70:	79 0d                	jns    80105d7f <popcli+0x4d>
    panic("popcli");
80105d72:	83 ec 0c             	sub    $0xc,%esp
80105d75:	68 07 99 10 80       	push   $0x80109907
80105d7a:	e8 e7 a7 ff ff       	call   80100566 <panic>
  if(cpu->ncli == 0 && cpu->intena)
80105d7f:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105d85:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80105d8b:	85 c0                	test   %eax,%eax
80105d8d:	75 15                	jne    80105da4 <popcli+0x72>
80105d8f:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105d95:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80105d9b:	85 c0                	test   %eax,%eax
80105d9d:	74 05                	je     80105da4 <popcli+0x72>
    sti();
80105d9f:	e8 a9 fd ff ff       	call   80105b4d <sti>
}
80105da4:	90                   	nop
80105da5:	c9                   	leave  
80105da6:	c3                   	ret    

80105da7 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
80105da7:	55                   	push   %ebp
80105da8:	89 e5                	mov    %esp,%ebp
80105daa:	57                   	push   %edi
80105dab:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80105dac:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105daf:	8b 55 10             	mov    0x10(%ebp),%edx
80105db2:	8b 45 0c             	mov    0xc(%ebp),%eax
80105db5:	89 cb                	mov    %ecx,%ebx
80105db7:	89 df                	mov    %ebx,%edi
80105db9:	89 d1                	mov    %edx,%ecx
80105dbb:	fc                   	cld    
80105dbc:	f3 aa                	rep stos %al,%es:(%edi)
80105dbe:	89 ca                	mov    %ecx,%edx
80105dc0:	89 fb                	mov    %edi,%ebx
80105dc2:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105dc5:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80105dc8:	90                   	nop
80105dc9:	5b                   	pop    %ebx
80105dca:	5f                   	pop    %edi
80105dcb:	5d                   	pop    %ebp
80105dcc:	c3                   	ret    

80105dcd <stosl>:

static inline void
stosl(void *addr, int data, int cnt)
{
80105dcd:	55                   	push   %ebp
80105dce:	89 e5                	mov    %esp,%ebp
80105dd0:	57                   	push   %edi
80105dd1:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
80105dd2:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105dd5:	8b 55 10             	mov    0x10(%ebp),%edx
80105dd8:	8b 45 0c             	mov    0xc(%ebp),%eax
80105ddb:	89 cb                	mov    %ecx,%ebx
80105ddd:	89 df                	mov    %ebx,%edi
80105ddf:	89 d1                	mov    %edx,%ecx
80105de1:	fc                   	cld    
80105de2:	f3 ab                	rep stos %eax,%es:(%edi)
80105de4:	89 ca                	mov    %ecx,%edx
80105de6:	89 fb                	mov    %edi,%ebx
80105de8:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105deb:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80105dee:	90                   	nop
80105def:	5b                   	pop    %ebx
80105df0:	5f                   	pop    %edi
80105df1:	5d                   	pop    %ebp
80105df2:	c3                   	ret    

80105df3 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80105df3:	55                   	push   %ebp
80105df4:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
80105df6:	8b 45 08             	mov    0x8(%ebp),%eax
80105df9:	83 e0 03             	and    $0x3,%eax
80105dfc:	85 c0                	test   %eax,%eax
80105dfe:	75 43                	jne    80105e43 <memset+0x50>
80105e00:	8b 45 10             	mov    0x10(%ebp),%eax
80105e03:	83 e0 03             	and    $0x3,%eax
80105e06:	85 c0                	test   %eax,%eax
80105e08:	75 39                	jne    80105e43 <memset+0x50>
    c &= 0xFF;
80105e0a:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80105e11:	8b 45 10             	mov    0x10(%ebp),%eax
80105e14:	c1 e8 02             	shr    $0x2,%eax
80105e17:	89 c1                	mov    %eax,%ecx
80105e19:	8b 45 0c             	mov    0xc(%ebp),%eax
80105e1c:	c1 e0 18             	shl    $0x18,%eax
80105e1f:	89 c2                	mov    %eax,%edx
80105e21:	8b 45 0c             	mov    0xc(%ebp),%eax
80105e24:	c1 e0 10             	shl    $0x10,%eax
80105e27:	09 c2                	or     %eax,%edx
80105e29:	8b 45 0c             	mov    0xc(%ebp),%eax
80105e2c:	c1 e0 08             	shl    $0x8,%eax
80105e2f:	09 d0                	or     %edx,%eax
80105e31:	0b 45 0c             	or     0xc(%ebp),%eax
80105e34:	51                   	push   %ecx
80105e35:	50                   	push   %eax
80105e36:	ff 75 08             	pushl  0x8(%ebp)
80105e39:	e8 8f ff ff ff       	call   80105dcd <stosl>
80105e3e:	83 c4 0c             	add    $0xc,%esp
80105e41:	eb 12                	jmp    80105e55 <memset+0x62>
  } else
    stosb(dst, c, n);
80105e43:	8b 45 10             	mov    0x10(%ebp),%eax
80105e46:	50                   	push   %eax
80105e47:	ff 75 0c             	pushl  0xc(%ebp)
80105e4a:	ff 75 08             	pushl  0x8(%ebp)
80105e4d:	e8 55 ff ff ff       	call   80105da7 <stosb>
80105e52:	83 c4 0c             	add    $0xc,%esp
  return dst;
80105e55:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105e58:	c9                   	leave  
80105e59:	c3                   	ret    

80105e5a <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80105e5a:	55                   	push   %ebp
80105e5b:	89 e5                	mov    %esp,%ebp
80105e5d:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;
  
  s1 = v1;
80105e60:	8b 45 08             	mov    0x8(%ebp),%eax
80105e63:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
80105e66:	8b 45 0c             	mov    0xc(%ebp),%eax
80105e69:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
80105e6c:	eb 30                	jmp    80105e9e <memcmp+0x44>
    if(*s1 != *s2)
80105e6e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105e71:	0f b6 10             	movzbl (%eax),%edx
80105e74:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105e77:	0f b6 00             	movzbl (%eax),%eax
80105e7a:	38 c2                	cmp    %al,%dl
80105e7c:	74 18                	je     80105e96 <memcmp+0x3c>
      return *s1 - *s2;
80105e7e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105e81:	0f b6 00             	movzbl (%eax),%eax
80105e84:	0f b6 d0             	movzbl %al,%edx
80105e87:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105e8a:	0f b6 00             	movzbl (%eax),%eax
80105e8d:	0f b6 c0             	movzbl %al,%eax
80105e90:	29 c2                	sub    %eax,%edx
80105e92:	89 d0                	mov    %edx,%eax
80105e94:	eb 1a                	jmp    80105eb0 <memcmp+0x56>
    s1++, s2++;
80105e96:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105e9a:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  const uchar *s1, *s2;
  
  s1 = v1;
  s2 = v2;
  while(n-- > 0){
80105e9e:	8b 45 10             	mov    0x10(%ebp),%eax
80105ea1:	8d 50 ff             	lea    -0x1(%eax),%edx
80105ea4:	89 55 10             	mov    %edx,0x10(%ebp)
80105ea7:	85 c0                	test   %eax,%eax
80105ea9:	75 c3                	jne    80105e6e <memcmp+0x14>
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
  }

  return 0;
80105eab:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105eb0:	c9                   	leave  
80105eb1:	c3                   	ret    

80105eb2 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80105eb2:	55                   	push   %ebp
80105eb3:	89 e5                	mov    %esp,%ebp
80105eb5:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
80105eb8:	8b 45 0c             	mov    0xc(%ebp),%eax
80105ebb:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
80105ebe:	8b 45 08             	mov    0x8(%ebp),%eax
80105ec1:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80105ec4:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105ec7:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105eca:	73 54                	jae    80105f20 <memmove+0x6e>
80105ecc:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105ecf:	8b 45 10             	mov    0x10(%ebp),%eax
80105ed2:	01 d0                	add    %edx,%eax
80105ed4:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105ed7:	76 47                	jbe    80105f20 <memmove+0x6e>
    s += n;
80105ed9:	8b 45 10             	mov    0x10(%ebp),%eax
80105edc:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
80105edf:	8b 45 10             	mov    0x10(%ebp),%eax
80105ee2:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80105ee5:	eb 13                	jmp    80105efa <memmove+0x48>
      *--d = *--s;
80105ee7:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
80105eeb:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
80105eef:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105ef2:	0f b6 10             	movzbl (%eax),%edx
80105ef5:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105ef8:	88 10                	mov    %dl,(%eax)
  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
    while(n-- > 0)
80105efa:	8b 45 10             	mov    0x10(%ebp),%eax
80105efd:	8d 50 ff             	lea    -0x1(%eax),%edx
80105f00:	89 55 10             	mov    %edx,0x10(%ebp)
80105f03:	85 c0                	test   %eax,%eax
80105f05:	75 e0                	jne    80105ee7 <memmove+0x35>
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
80105f07:	eb 24                	jmp    80105f2d <memmove+0x7b>
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
      *d++ = *s++;
80105f09:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105f0c:	8d 50 01             	lea    0x1(%eax),%edx
80105f0f:	89 55 f8             	mov    %edx,-0x8(%ebp)
80105f12:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105f15:	8d 4a 01             	lea    0x1(%edx),%ecx
80105f18:	89 4d fc             	mov    %ecx,-0x4(%ebp)
80105f1b:	0f b6 12             	movzbl (%edx),%edx
80105f1e:	88 10                	mov    %dl,(%eax)
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
80105f20:	8b 45 10             	mov    0x10(%ebp),%eax
80105f23:	8d 50 ff             	lea    -0x1(%eax),%edx
80105f26:	89 55 10             	mov    %edx,0x10(%ebp)
80105f29:	85 c0                	test   %eax,%eax
80105f2b:	75 dc                	jne    80105f09 <memmove+0x57>
      *d++ = *s++;

  return dst;
80105f2d:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105f30:	c9                   	leave  
80105f31:	c3                   	ret    

80105f32 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80105f32:	55                   	push   %ebp
80105f33:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
80105f35:	ff 75 10             	pushl  0x10(%ebp)
80105f38:	ff 75 0c             	pushl  0xc(%ebp)
80105f3b:	ff 75 08             	pushl  0x8(%ebp)
80105f3e:	e8 6f ff ff ff       	call   80105eb2 <memmove>
80105f43:	83 c4 0c             	add    $0xc,%esp
}
80105f46:	c9                   	leave  
80105f47:	c3                   	ret    

80105f48 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80105f48:	55                   	push   %ebp
80105f49:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
80105f4b:	eb 0c                	jmp    80105f59 <strncmp+0x11>
    n--, p++, q++;
80105f4d:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105f51:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80105f55:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
80105f59:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105f5d:	74 1a                	je     80105f79 <strncmp+0x31>
80105f5f:	8b 45 08             	mov    0x8(%ebp),%eax
80105f62:	0f b6 00             	movzbl (%eax),%eax
80105f65:	84 c0                	test   %al,%al
80105f67:	74 10                	je     80105f79 <strncmp+0x31>
80105f69:	8b 45 08             	mov    0x8(%ebp),%eax
80105f6c:	0f b6 10             	movzbl (%eax),%edx
80105f6f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105f72:	0f b6 00             	movzbl (%eax),%eax
80105f75:	38 c2                	cmp    %al,%dl
80105f77:	74 d4                	je     80105f4d <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
80105f79:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105f7d:	75 07                	jne    80105f86 <strncmp+0x3e>
    return 0;
80105f7f:	b8 00 00 00 00       	mov    $0x0,%eax
80105f84:	eb 16                	jmp    80105f9c <strncmp+0x54>
  return (uchar)*p - (uchar)*q;
80105f86:	8b 45 08             	mov    0x8(%ebp),%eax
80105f89:	0f b6 00             	movzbl (%eax),%eax
80105f8c:	0f b6 d0             	movzbl %al,%edx
80105f8f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105f92:	0f b6 00             	movzbl (%eax),%eax
80105f95:	0f b6 c0             	movzbl %al,%eax
80105f98:	29 c2                	sub    %eax,%edx
80105f9a:	89 d0                	mov    %edx,%eax
}
80105f9c:	5d                   	pop    %ebp
80105f9d:	c3                   	ret    

80105f9e <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80105f9e:	55                   	push   %ebp
80105f9f:	89 e5                	mov    %esp,%ebp
80105fa1:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
80105fa4:	8b 45 08             	mov    0x8(%ebp),%eax
80105fa7:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
80105faa:	90                   	nop
80105fab:	8b 45 10             	mov    0x10(%ebp),%eax
80105fae:	8d 50 ff             	lea    -0x1(%eax),%edx
80105fb1:	89 55 10             	mov    %edx,0x10(%ebp)
80105fb4:	85 c0                	test   %eax,%eax
80105fb6:	7e 2c                	jle    80105fe4 <strncpy+0x46>
80105fb8:	8b 45 08             	mov    0x8(%ebp),%eax
80105fbb:	8d 50 01             	lea    0x1(%eax),%edx
80105fbe:	89 55 08             	mov    %edx,0x8(%ebp)
80105fc1:	8b 55 0c             	mov    0xc(%ebp),%edx
80105fc4:	8d 4a 01             	lea    0x1(%edx),%ecx
80105fc7:	89 4d 0c             	mov    %ecx,0xc(%ebp)
80105fca:	0f b6 12             	movzbl (%edx),%edx
80105fcd:	88 10                	mov    %dl,(%eax)
80105fcf:	0f b6 00             	movzbl (%eax),%eax
80105fd2:	84 c0                	test   %al,%al
80105fd4:	75 d5                	jne    80105fab <strncpy+0xd>
    ;
  while(n-- > 0)
80105fd6:	eb 0c                	jmp    80105fe4 <strncpy+0x46>
    *s++ = 0;
80105fd8:	8b 45 08             	mov    0x8(%ebp),%eax
80105fdb:	8d 50 01             	lea    0x1(%eax),%edx
80105fde:	89 55 08             	mov    %edx,0x8(%ebp)
80105fe1:	c6 00 00             	movb   $0x0,(%eax)
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
80105fe4:	8b 45 10             	mov    0x10(%ebp),%eax
80105fe7:	8d 50 ff             	lea    -0x1(%eax),%edx
80105fea:	89 55 10             	mov    %edx,0x10(%ebp)
80105fed:	85 c0                	test   %eax,%eax
80105fef:	7f e7                	jg     80105fd8 <strncpy+0x3a>
    *s++ = 0;
  return os;
80105ff1:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105ff4:	c9                   	leave  
80105ff5:	c3                   	ret    

80105ff6 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80105ff6:	55                   	push   %ebp
80105ff7:	89 e5                	mov    %esp,%ebp
80105ff9:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
80105ffc:	8b 45 08             	mov    0x8(%ebp),%eax
80105fff:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
80106002:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80106006:	7f 05                	jg     8010600d <safestrcpy+0x17>
    return os;
80106008:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010600b:	eb 31                	jmp    8010603e <safestrcpy+0x48>
  while(--n > 0 && (*s++ = *t++) != 0)
8010600d:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80106011:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80106015:	7e 1e                	jle    80106035 <safestrcpy+0x3f>
80106017:	8b 45 08             	mov    0x8(%ebp),%eax
8010601a:	8d 50 01             	lea    0x1(%eax),%edx
8010601d:	89 55 08             	mov    %edx,0x8(%ebp)
80106020:	8b 55 0c             	mov    0xc(%ebp),%edx
80106023:	8d 4a 01             	lea    0x1(%edx),%ecx
80106026:	89 4d 0c             	mov    %ecx,0xc(%ebp)
80106029:	0f b6 12             	movzbl (%edx),%edx
8010602c:	88 10                	mov    %dl,(%eax)
8010602e:	0f b6 00             	movzbl (%eax),%eax
80106031:	84 c0                	test   %al,%al
80106033:	75 d8                	jne    8010600d <safestrcpy+0x17>
    ;
  *s = 0;
80106035:	8b 45 08             	mov    0x8(%ebp),%eax
80106038:	c6 00 00             	movb   $0x0,(%eax)
  return os;
8010603b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010603e:	c9                   	leave  
8010603f:	c3                   	ret    

80106040 <strlen>:

int
strlen(const char *s)
{
80106040:	55                   	push   %ebp
80106041:	89 e5                	mov    %esp,%ebp
80106043:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
80106046:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
8010604d:	eb 04                	jmp    80106053 <strlen+0x13>
8010604f:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80106053:	8b 55 fc             	mov    -0x4(%ebp),%edx
80106056:	8b 45 08             	mov    0x8(%ebp),%eax
80106059:	01 d0                	add    %edx,%eax
8010605b:	0f b6 00             	movzbl (%eax),%eax
8010605e:	84 c0                	test   %al,%al
80106060:	75 ed                	jne    8010604f <strlen+0xf>
    ;
  return n;
80106062:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106065:	c9                   	leave  
80106066:	c3                   	ret    

80106067 <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
80106067:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
8010606b:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
8010606f:	55                   	push   %ebp
  pushl %ebx
80106070:	53                   	push   %ebx
  pushl %esi
80106071:	56                   	push   %esi
  pushl %edi
80106072:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80106073:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80106075:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
80106077:	5f                   	pop    %edi
  popl %esi
80106078:	5e                   	pop    %esi
  popl %ebx
80106079:	5b                   	pop    %ebx
  popl %ebp
8010607a:	5d                   	pop    %ebp
  ret
8010607b:	c3                   	ret    

8010607c <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
8010607c:	55                   	push   %ebp
8010607d:	89 e5                	mov    %esp,%ebp
  if(addr >= proc->sz || addr+4 > proc->sz)
8010607f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106085:	8b 00                	mov    (%eax),%eax
80106087:	3b 45 08             	cmp    0x8(%ebp),%eax
8010608a:	76 12                	jbe    8010609e <fetchint+0x22>
8010608c:	8b 45 08             	mov    0x8(%ebp),%eax
8010608f:	8d 50 04             	lea    0x4(%eax),%edx
80106092:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106098:	8b 00                	mov    (%eax),%eax
8010609a:	39 c2                	cmp    %eax,%edx
8010609c:	76 07                	jbe    801060a5 <fetchint+0x29>
    return -1;
8010609e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060a3:	eb 0f                	jmp    801060b4 <fetchint+0x38>
  *ip = *(int*)(addr);
801060a5:	8b 45 08             	mov    0x8(%ebp),%eax
801060a8:	8b 10                	mov    (%eax),%edx
801060aa:	8b 45 0c             	mov    0xc(%ebp),%eax
801060ad:	89 10                	mov    %edx,(%eax)
  return 0;
801060af:	b8 00 00 00 00       	mov    $0x0,%eax
}
801060b4:	5d                   	pop    %ebp
801060b5:	c3                   	ret    

801060b6 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
801060b6:	55                   	push   %ebp
801060b7:	89 e5                	mov    %esp,%ebp
801060b9:	83 ec 10             	sub    $0x10,%esp
  char *s, *ep;

  if(addr >= proc->sz)
801060bc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801060c2:	8b 00                	mov    (%eax),%eax
801060c4:	3b 45 08             	cmp    0x8(%ebp),%eax
801060c7:	77 07                	ja     801060d0 <fetchstr+0x1a>
    return -1;
801060c9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060ce:	eb 46                	jmp    80106116 <fetchstr+0x60>
  *pp = (char*)addr;
801060d0:	8b 55 08             	mov    0x8(%ebp),%edx
801060d3:	8b 45 0c             	mov    0xc(%ebp),%eax
801060d6:	89 10                	mov    %edx,(%eax)
  ep = (char*)proc->sz;
801060d8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801060de:	8b 00                	mov    (%eax),%eax
801060e0:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(s = *pp; s < ep; s++)
801060e3:	8b 45 0c             	mov    0xc(%ebp),%eax
801060e6:	8b 00                	mov    (%eax),%eax
801060e8:	89 45 fc             	mov    %eax,-0x4(%ebp)
801060eb:	eb 1c                	jmp    80106109 <fetchstr+0x53>
    if(*s == 0)
801060ed:	8b 45 fc             	mov    -0x4(%ebp),%eax
801060f0:	0f b6 00             	movzbl (%eax),%eax
801060f3:	84 c0                	test   %al,%al
801060f5:	75 0e                	jne    80106105 <fetchstr+0x4f>
      return s - *pp;
801060f7:	8b 55 fc             	mov    -0x4(%ebp),%edx
801060fa:	8b 45 0c             	mov    0xc(%ebp),%eax
801060fd:	8b 00                	mov    (%eax),%eax
801060ff:	29 c2                	sub    %eax,%edx
80106101:	89 d0                	mov    %edx,%eax
80106103:	eb 11                	jmp    80106116 <fetchstr+0x60>

  if(addr >= proc->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)proc->sz;
  for(s = *pp; s < ep; s++)
80106105:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80106109:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010610c:	3b 45 f8             	cmp    -0x8(%ebp),%eax
8010610f:	72 dc                	jb     801060ed <fetchstr+0x37>
    if(*s == 0)
      return s - *pp;
  return -1;
80106111:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80106116:	c9                   	leave  
80106117:	c3                   	ret    

80106118 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80106118:	55                   	push   %ebp
80106119:	89 e5                	mov    %esp,%ebp
  return fetchint(proc->tf->esp + 4 + 4*n, ip);
8010611b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106121:	8b 40 18             	mov    0x18(%eax),%eax
80106124:	8b 40 44             	mov    0x44(%eax),%eax
80106127:	8b 55 08             	mov    0x8(%ebp),%edx
8010612a:	c1 e2 02             	shl    $0x2,%edx
8010612d:	01 d0                	add    %edx,%eax
8010612f:	83 c0 04             	add    $0x4,%eax
80106132:	ff 75 0c             	pushl  0xc(%ebp)
80106135:	50                   	push   %eax
80106136:	e8 41 ff ff ff       	call   8010607c <fetchint>
8010613b:	83 c4 08             	add    $0x8,%esp
}
8010613e:	c9                   	leave  
8010613f:	c3                   	ret    

80106140 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size n bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80106140:	55                   	push   %ebp
80106141:	89 e5                	mov    %esp,%ebp
80106143:	83 ec 10             	sub    $0x10,%esp
  int i;
  
  if(argint(n, &i) < 0)
80106146:	8d 45 fc             	lea    -0x4(%ebp),%eax
80106149:	50                   	push   %eax
8010614a:	ff 75 08             	pushl  0x8(%ebp)
8010614d:	e8 c6 ff ff ff       	call   80106118 <argint>
80106152:	83 c4 08             	add    $0x8,%esp
80106155:	85 c0                	test   %eax,%eax
80106157:	79 07                	jns    80106160 <argptr+0x20>
    return -1;
80106159:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010615e:	eb 3b                	jmp    8010619b <argptr+0x5b>
  if((uint)i >= proc->sz || (uint)i+size > proc->sz)
80106160:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106166:	8b 00                	mov    (%eax),%eax
80106168:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010616b:	39 d0                	cmp    %edx,%eax
8010616d:	76 16                	jbe    80106185 <argptr+0x45>
8010616f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106172:	89 c2                	mov    %eax,%edx
80106174:	8b 45 10             	mov    0x10(%ebp),%eax
80106177:	01 c2                	add    %eax,%edx
80106179:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010617f:	8b 00                	mov    (%eax),%eax
80106181:	39 c2                	cmp    %eax,%edx
80106183:	76 07                	jbe    8010618c <argptr+0x4c>
    return -1;
80106185:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010618a:	eb 0f                	jmp    8010619b <argptr+0x5b>
  *pp = (char*)i;
8010618c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010618f:	89 c2                	mov    %eax,%edx
80106191:	8b 45 0c             	mov    0xc(%ebp),%eax
80106194:	89 10                	mov    %edx,(%eax)
  return 0;
80106196:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010619b:	c9                   	leave  
8010619c:	c3                   	ret    

8010619d <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
8010619d:	55                   	push   %ebp
8010619e:	89 e5                	mov    %esp,%ebp
801061a0:	83 ec 10             	sub    $0x10,%esp
  int addr;
  if(argint(n, &addr) < 0)
801061a3:	8d 45 fc             	lea    -0x4(%ebp),%eax
801061a6:	50                   	push   %eax
801061a7:	ff 75 08             	pushl  0x8(%ebp)
801061aa:	e8 69 ff ff ff       	call   80106118 <argint>
801061af:	83 c4 08             	add    $0x8,%esp
801061b2:	85 c0                	test   %eax,%eax
801061b4:	79 07                	jns    801061bd <argstr+0x20>
    return -1;
801061b6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801061bb:	eb 0f                	jmp    801061cc <argstr+0x2f>
  return fetchstr(addr, pp);
801061bd:	8b 45 fc             	mov    -0x4(%ebp),%eax
801061c0:	ff 75 0c             	pushl  0xc(%ebp)
801061c3:	50                   	push   %eax
801061c4:	e8 ed fe ff ff       	call   801060b6 <fetchstr>
801061c9:	83 c4 08             	add    $0x8,%esp
}
801061cc:	c9                   	leave  
801061cd:	c3                   	ret    

801061ce <syscall>:
[SYS_mount]   sys_mount,
};

void
syscall(void)
{
801061ce:	55                   	push   %ebp
801061cf:	89 e5                	mov    %esp,%ebp
801061d1:	53                   	push   %ebx
801061d2:	83 ec 14             	sub    $0x14,%esp
  int num;

  num = proc->tf->eax;
801061d5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801061db:	8b 40 18             	mov    0x18(%eax),%eax
801061de:	8b 40 1c             	mov    0x1c(%eax),%eax
801061e1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
801061e4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801061e8:	7e 30                	jle    8010621a <syscall+0x4c>
801061ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061ed:	83 f8 16             	cmp    $0x16,%eax
801061f0:	77 28                	ja     8010621a <syscall+0x4c>
801061f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061f5:	8b 04 85 40 c0 10 80 	mov    -0x7fef3fc0(,%eax,4),%eax
801061fc:	85 c0                	test   %eax,%eax
801061fe:	74 1a                	je     8010621a <syscall+0x4c>
    proc->tf->eax = syscalls[num]();
80106200:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106206:	8b 58 18             	mov    0x18(%eax),%ebx
80106209:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010620c:	8b 04 85 40 c0 10 80 	mov    -0x7fef3fc0(,%eax,4),%eax
80106213:	ff d0                	call   *%eax
80106215:	89 43 1c             	mov    %eax,0x1c(%ebx)
80106218:	eb 34                	jmp    8010624e <syscall+0x80>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            proc->pid, proc->name, num);
8010621a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106220:	8d 50 6c             	lea    0x6c(%eax),%edx
80106223:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax

  num = proc->tf->eax;
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    proc->tf->eax = syscalls[num]();
  } else {
    cprintf("%d %s: unknown sys call %d\n",
80106229:	8b 40 10             	mov    0x10(%eax),%eax
8010622c:	ff 75 f4             	pushl  -0xc(%ebp)
8010622f:	52                   	push   %edx
80106230:	50                   	push   %eax
80106231:	68 0e 99 10 80       	push   $0x8010990e
80106236:	e8 8b a1 ff ff       	call   801003c6 <cprintf>
8010623b:	83 c4 10             	add    $0x10,%esp
            proc->pid, proc->name, num);
    proc->tf->eax = -1;
8010623e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106244:	8b 40 18             	mov    0x18(%eax),%eax
80106247:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
8010624e:	90                   	nop
8010624f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80106252:	c9                   	leave  
80106253:	c3                   	ret    

80106254 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.

static int argfd(int n, int* pfd, struct file** pf)
{
80106254:	55                   	push   %ebp
80106255:	89 e5                	mov    %esp,%ebp
80106257:	83 ec 18             	sub    $0x18,%esp
    int fd;
    struct file* f;

    if (argint(n, &fd) < 0)
8010625a:	83 ec 08             	sub    $0x8,%esp
8010625d:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106260:	50                   	push   %eax
80106261:	ff 75 08             	pushl  0x8(%ebp)
80106264:	e8 af fe ff ff       	call   80106118 <argint>
80106269:	83 c4 10             	add    $0x10,%esp
8010626c:	85 c0                	test   %eax,%eax
8010626e:	79 07                	jns    80106277 <argfd+0x23>
        return -1;
80106270:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106275:	eb 50                	jmp    801062c7 <argfd+0x73>
    if (fd < 0 || fd >= NOFILE || (f = proc->ofile[fd]) == 0)
80106277:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010627a:	85 c0                	test   %eax,%eax
8010627c:	78 21                	js     8010629f <argfd+0x4b>
8010627e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106281:	83 f8 0f             	cmp    $0xf,%eax
80106284:	7f 19                	jg     8010629f <argfd+0x4b>
80106286:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010628c:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010628f:	83 c2 08             	add    $0x8,%edx
80106292:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80106296:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106299:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010629d:	75 07                	jne    801062a6 <argfd+0x52>
        return -1;
8010629f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062a4:	eb 21                	jmp    801062c7 <argfd+0x73>
    if (pfd)
801062a6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801062aa:	74 08                	je     801062b4 <argfd+0x60>
        *pfd = fd;
801062ac:	8b 55 f0             	mov    -0x10(%ebp),%edx
801062af:	8b 45 0c             	mov    0xc(%ebp),%eax
801062b2:	89 10                	mov    %edx,(%eax)
    if (pf)
801062b4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801062b8:	74 08                	je     801062c2 <argfd+0x6e>
        *pf = f;
801062ba:	8b 45 10             	mov    0x10(%ebp),%eax
801062bd:	8b 55 f4             	mov    -0xc(%ebp),%edx
801062c0:	89 10                	mov    %edx,(%eax)
    return 0;
801062c2:	b8 00 00 00 00       	mov    $0x0,%eax
}
801062c7:	c9                   	leave  
801062c8:	c3                   	ret    

801062c9 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int fdalloc(struct file* f)
{
801062c9:	55                   	push   %ebp
801062ca:	89 e5                	mov    %esp,%ebp
801062cc:	83 ec 10             	sub    $0x10,%esp
    int fd;

    for (fd = 0; fd < NOFILE; fd++) {
801062cf:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801062d6:	eb 30                	jmp    80106308 <fdalloc+0x3f>
        if (proc->ofile[fd] == 0) {
801062d8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801062de:	8b 55 fc             	mov    -0x4(%ebp),%edx
801062e1:	83 c2 08             	add    $0x8,%edx
801062e4:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801062e8:	85 c0                	test   %eax,%eax
801062ea:	75 18                	jne    80106304 <fdalloc+0x3b>
            proc->ofile[fd] = f;
801062ec:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801062f2:	8b 55 fc             	mov    -0x4(%ebp),%edx
801062f5:	8d 4a 08             	lea    0x8(%edx),%ecx
801062f8:	8b 55 08             	mov    0x8(%ebp),%edx
801062fb:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
            return fd;
801062ff:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106302:	eb 0f                	jmp    80106313 <fdalloc+0x4a>
// Takes over file reference from caller on success.
static int fdalloc(struct file* f)
{
    int fd;

    for (fd = 0; fd < NOFILE; fd++) {
80106304:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80106308:	83 7d fc 0f          	cmpl   $0xf,-0x4(%ebp)
8010630c:	7e ca                	jle    801062d8 <fdalloc+0xf>
        if (proc->ofile[fd] == 0) {
            proc->ofile[fd] = f;
            return fd;
        }
    }
    return -1;
8010630e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80106313:	c9                   	leave  
80106314:	c3                   	ret    

80106315 <sys_dup>:

int sys_dup(void)
{
80106315:	55                   	push   %ebp
80106316:	89 e5                	mov    %esp,%ebp
80106318:	83 ec 18             	sub    $0x18,%esp
    struct file* f;
    int fd;

    if (argfd(0, 0, &f) < 0)
8010631b:	83 ec 04             	sub    $0x4,%esp
8010631e:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106321:	50                   	push   %eax
80106322:	6a 00                	push   $0x0
80106324:	6a 00                	push   $0x0
80106326:	e8 29 ff ff ff       	call   80106254 <argfd>
8010632b:	83 c4 10             	add    $0x10,%esp
8010632e:	85 c0                	test   %eax,%eax
80106330:	79 07                	jns    80106339 <sys_dup+0x24>
        return -1;
80106332:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106337:	eb 31                	jmp    8010636a <sys_dup+0x55>
    if ((fd = fdalloc(f)) < 0)
80106339:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010633c:	83 ec 0c             	sub    $0xc,%esp
8010633f:	50                   	push   %eax
80106340:	e8 84 ff ff ff       	call   801062c9 <fdalloc>
80106345:	83 c4 10             	add    $0x10,%esp
80106348:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010634b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010634f:	79 07                	jns    80106358 <sys_dup+0x43>
        return -1;
80106351:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106356:	eb 12                	jmp    8010636a <sys_dup+0x55>
    filedup(f);
80106358:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010635b:	83 ec 0c             	sub    $0xc,%esp
8010635e:	50                   	push   %eax
8010635f:	e8 f4 ac ff ff       	call   80101058 <filedup>
80106364:	83 c4 10             	add    $0x10,%esp
    return fd;
80106367:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010636a:	c9                   	leave  
8010636b:	c3                   	ret    

8010636c <sys_read>:

int sys_read(void)
{
8010636c:	55                   	push   %ebp
8010636d:	89 e5                	mov    %esp,%ebp
8010636f:	83 ec 18             	sub    $0x18,%esp
    struct file* f;
    int n;
    char* p;

    if (argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80106372:	83 ec 04             	sub    $0x4,%esp
80106375:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106378:	50                   	push   %eax
80106379:	6a 00                	push   $0x0
8010637b:	6a 00                	push   $0x0
8010637d:	e8 d2 fe ff ff       	call   80106254 <argfd>
80106382:	83 c4 10             	add    $0x10,%esp
80106385:	85 c0                	test   %eax,%eax
80106387:	78 2e                	js     801063b7 <sys_read+0x4b>
80106389:	83 ec 08             	sub    $0x8,%esp
8010638c:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010638f:	50                   	push   %eax
80106390:	6a 02                	push   $0x2
80106392:	e8 81 fd ff ff       	call   80106118 <argint>
80106397:	83 c4 10             	add    $0x10,%esp
8010639a:	85 c0                	test   %eax,%eax
8010639c:	78 19                	js     801063b7 <sys_read+0x4b>
8010639e:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063a1:	83 ec 04             	sub    $0x4,%esp
801063a4:	50                   	push   %eax
801063a5:	8d 45 ec             	lea    -0x14(%ebp),%eax
801063a8:	50                   	push   %eax
801063a9:	6a 01                	push   $0x1
801063ab:	e8 90 fd ff ff       	call   80106140 <argptr>
801063b0:	83 c4 10             	add    $0x10,%esp
801063b3:	85 c0                	test   %eax,%eax
801063b5:	79 07                	jns    801063be <sys_read+0x52>
        return -1;
801063b7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063bc:	eb 17                	jmp    801063d5 <sys_read+0x69>
    return fileread(f, p, n);
801063be:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801063c1:	8b 55 ec             	mov    -0x14(%ebp),%edx
801063c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063c7:	83 ec 04             	sub    $0x4,%esp
801063ca:	51                   	push   %ecx
801063cb:	52                   	push   %edx
801063cc:	50                   	push   %eax
801063cd:	e8 3e ae ff ff       	call   80101210 <fileread>
801063d2:	83 c4 10             	add    $0x10,%esp
}
801063d5:	c9                   	leave  
801063d6:	c3                   	ret    

801063d7 <sys_write>:

int sys_write(void)
{
801063d7:	55                   	push   %ebp
801063d8:	89 e5                	mov    %esp,%ebp
801063da:	83 ec 18             	sub    $0x18,%esp
    struct file* f;
    int n;
    char* p;

    if (argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801063dd:	83 ec 04             	sub    $0x4,%esp
801063e0:	8d 45 f4             	lea    -0xc(%ebp),%eax
801063e3:	50                   	push   %eax
801063e4:	6a 00                	push   $0x0
801063e6:	6a 00                	push   $0x0
801063e8:	e8 67 fe ff ff       	call   80106254 <argfd>
801063ed:	83 c4 10             	add    $0x10,%esp
801063f0:	85 c0                	test   %eax,%eax
801063f2:	78 2e                	js     80106422 <sys_write+0x4b>
801063f4:	83 ec 08             	sub    $0x8,%esp
801063f7:	8d 45 f0             	lea    -0x10(%ebp),%eax
801063fa:	50                   	push   %eax
801063fb:	6a 02                	push   $0x2
801063fd:	e8 16 fd ff ff       	call   80106118 <argint>
80106402:	83 c4 10             	add    $0x10,%esp
80106405:	85 c0                	test   %eax,%eax
80106407:	78 19                	js     80106422 <sys_write+0x4b>
80106409:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010640c:	83 ec 04             	sub    $0x4,%esp
8010640f:	50                   	push   %eax
80106410:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106413:	50                   	push   %eax
80106414:	6a 01                	push   $0x1
80106416:	e8 25 fd ff ff       	call   80106140 <argptr>
8010641b:	83 c4 10             	add    $0x10,%esp
8010641e:	85 c0                	test   %eax,%eax
80106420:	79 07                	jns    80106429 <sys_write+0x52>
        return -1;
80106422:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106427:	eb 17                	jmp    80106440 <sys_write+0x69>
    return filewrite(f, p, n);
80106429:	8b 4d f0             	mov    -0x10(%ebp),%ecx
8010642c:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010642f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106432:	83 ec 04             	sub    $0x4,%esp
80106435:	51                   	push   %ecx
80106436:	52                   	push   %edx
80106437:	50                   	push   %eax
80106438:	e8 8b ae ff ff       	call   801012c8 <filewrite>
8010643d:	83 c4 10             	add    $0x10,%esp
}
80106440:	c9                   	leave  
80106441:	c3                   	ret    

80106442 <sys_close>:

int sys_close(void)
{
80106442:	55                   	push   %ebp
80106443:	89 e5                	mov    %esp,%ebp
80106445:	83 ec 18             	sub    $0x18,%esp
    int fd;
    struct file* f;

    if (argfd(0, &fd, &f) < 0)
80106448:	83 ec 04             	sub    $0x4,%esp
8010644b:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010644e:	50                   	push   %eax
8010644f:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106452:	50                   	push   %eax
80106453:	6a 00                	push   $0x0
80106455:	e8 fa fd ff ff       	call   80106254 <argfd>
8010645a:	83 c4 10             	add    $0x10,%esp
8010645d:	85 c0                	test   %eax,%eax
8010645f:	79 07                	jns    80106468 <sys_close+0x26>
        return -1;
80106461:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106466:	eb 28                	jmp    80106490 <sys_close+0x4e>
    proc->ofile[fd] = 0;
80106468:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010646e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106471:	83 c2 08             	add    $0x8,%edx
80106474:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
8010647b:	00 
    fileclose(f);
8010647c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010647f:	83 ec 0c             	sub    $0xc,%esp
80106482:	50                   	push   %eax
80106483:	e8 21 ac ff ff       	call   801010a9 <fileclose>
80106488:	83 c4 10             	add    $0x10,%esp
    return 0;
8010648b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106490:	c9                   	leave  
80106491:	c3                   	ret    

80106492 <sys_fstat>:

int sys_fstat(void)
{
80106492:	55                   	push   %ebp
80106493:	89 e5                	mov    %esp,%ebp
80106495:	83 ec 18             	sub    $0x18,%esp
    struct file* f;
    struct stat* st;

    if (argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80106498:	83 ec 04             	sub    $0x4,%esp
8010649b:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010649e:	50                   	push   %eax
8010649f:	6a 00                	push   $0x0
801064a1:	6a 00                	push   $0x0
801064a3:	e8 ac fd ff ff       	call   80106254 <argfd>
801064a8:	83 c4 10             	add    $0x10,%esp
801064ab:	85 c0                	test   %eax,%eax
801064ad:	78 17                	js     801064c6 <sys_fstat+0x34>
801064af:	83 ec 04             	sub    $0x4,%esp
801064b2:	6a 14                	push   $0x14
801064b4:	8d 45 f0             	lea    -0x10(%ebp),%eax
801064b7:	50                   	push   %eax
801064b8:	6a 01                	push   $0x1
801064ba:	e8 81 fc ff ff       	call   80106140 <argptr>
801064bf:	83 c4 10             	add    $0x10,%esp
801064c2:	85 c0                	test   %eax,%eax
801064c4:	79 07                	jns    801064cd <sys_fstat+0x3b>
        return -1;
801064c6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064cb:	eb 13                	jmp    801064e0 <sys_fstat+0x4e>
    return filestat(f, st);
801064cd:	8b 55 f0             	mov    -0x10(%ebp),%edx
801064d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064d3:	83 ec 08             	sub    $0x8,%esp
801064d6:	52                   	push   %edx
801064d7:	50                   	push   %eax
801064d8:	e8 dc ac ff ff       	call   801011b9 <filestat>
801064dd:	83 c4 10             	add    $0x10,%esp
}
801064e0:	c9                   	leave  
801064e1:	c3                   	ret    

801064e2 <sys_link>:

// Create the path new as a link to the same inode as old.
int sys_link(void)
{
801064e2:	55                   	push   %ebp
801064e3:	89 e5                	mov    %esp,%ebp
801064e5:	83 ec 28             	sub    $0x28,%esp
    char name[DIRSIZ], *new, *old;
    struct inode* dp, *ip;

    if (argstr(0, &old) < 0 || argstr(1, &new) < 0)
801064e8:	83 ec 08             	sub    $0x8,%esp
801064eb:	8d 45 d8             	lea    -0x28(%ebp),%eax
801064ee:	50                   	push   %eax
801064ef:	6a 00                	push   $0x0
801064f1:	e8 a7 fc ff ff       	call   8010619d <argstr>
801064f6:	83 c4 10             	add    $0x10,%esp
801064f9:	85 c0                	test   %eax,%eax
801064fb:	78 15                	js     80106512 <sys_link+0x30>
801064fd:	83 ec 08             	sub    $0x8,%esp
80106500:	8d 45 dc             	lea    -0x24(%ebp),%eax
80106503:	50                   	push   %eax
80106504:	6a 01                	push   $0x1
80106506:	e8 92 fc ff ff       	call   8010619d <argstr>
8010650b:	83 c4 10             	add    $0x10,%esp
8010650e:	85 c0                	test   %eax,%eax
80106510:	79 0a                	jns    8010651c <sys_link+0x3a>
        return -1;
80106512:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106517:	e9 da 01 00 00       	jmp    801066f6 <sys_link+0x214>

    begin_op(proc->cwd->part->number);
8010651c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106522:	8b 40 68             	mov    0x68(%eax),%eax
80106525:	8b 40 50             	mov    0x50(%eax),%eax
80106528:	8b 40 14             	mov    0x14(%eax),%eax
8010652b:	83 ec 0c             	sub    $0xc,%esp
8010652e:	50                   	push   %eax
8010652f:	e8 7e d9 ff ff       	call   80103eb2 <begin_op>
80106534:	83 c4 10             	add    $0x10,%esp
    if ((ip = namei(old)) == 0) {
80106537:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010653a:	83 ec 0c             	sub    $0xc,%esp
8010653d:	50                   	push   %eax
8010653e:	e8 d1 c7 ff ff       	call   80102d14 <namei>
80106543:	83 c4 10             	add    $0x10,%esp
80106546:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106549:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010654d:	75 25                	jne    80106574 <sys_link+0x92>
        end_op(proc->cwd->part->number);
8010654f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106555:	8b 40 68             	mov    0x68(%eax),%eax
80106558:	8b 40 50             	mov    0x50(%eax),%eax
8010655b:	8b 40 14             	mov    0x14(%eax),%eax
8010655e:	83 ec 0c             	sub    $0xc,%esp
80106561:	50                   	push   %eax
80106562:	e8 52 da ff ff       	call   80103fb9 <end_op>
80106567:	83 c4 10             	add    $0x10,%esp
        return -1;
8010656a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010656f:	e9 82 01 00 00       	jmp    801066f6 <sys_link+0x214>
    }

    ilock(ip);
80106574:	83 ec 0c             	sub    $0xc,%esp
80106577:	ff 75 f4             	pushl  -0xc(%ebp)
8010657a:	e8 73 b9 ff ff       	call   80101ef2 <ilock>
8010657f:	83 c4 10             	add    $0x10,%esp
    if (ip->type == T_DIR) {
80106582:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106585:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106589:	66 83 f8 01          	cmp    $0x1,%ax
8010658d:	75 33                	jne    801065c2 <sys_link+0xe0>
        iunlockput(ip);
8010658f:	83 ec 0c             	sub    $0xc,%esp
80106592:	ff 75 f4             	pushl  -0xc(%ebp)
80106595:	e8 5b bc ff ff       	call   801021f5 <iunlockput>
8010659a:	83 c4 10             	add    $0x10,%esp
        end_op(proc->cwd->part->number);
8010659d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801065a3:	8b 40 68             	mov    0x68(%eax),%eax
801065a6:	8b 40 50             	mov    0x50(%eax),%eax
801065a9:	8b 40 14             	mov    0x14(%eax),%eax
801065ac:	83 ec 0c             	sub    $0xc,%esp
801065af:	50                   	push   %eax
801065b0:	e8 04 da ff ff       	call   80103fb9 <end_op>
801065b5:	83 c4 10             	add    $0x10,%esp
        return -1;
801065b8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065bd:	e9 34 01 00 00       	jmp    801066f6 <sys_link+0x214>
    }

    ip->nlink++;
801065c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065c5:	0f b7 40 16          	movzwl 0x16(%eax),%eax
801065c9:	83 c0 01             	add    $0x1,%eax
801065cc:	89 c2                	mov    %eax,%edx
801065ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065d1:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(ip);
801065d5:	83 ec 0c             	sub    $0xc,%esp
801065d8:	ff 75 f4             	pushl  -0xc(%ebp)
801065db:	e8 b4 b6 ff ff       	call   80101c94 <iupdate>
801065e0:	83 c4 10             	add    $0x10,%esp
    iunlock(ip);
801065e3:	83 ec 0c             	sub    $0xc,%esp
801065e6:	ff 75 f4             	pushl  -0xc(%ebp)
801065e9:	e8 a5 ba ff ff       	call   80102093 <iunlock>
801065ee:	83 c4 10             	add    $0x10,%esp

    if ((dp = nameiparent(new, name)) == 0)
801065f1:	8b 45 dc             	mov    -0x24(%ebp),%eax
801065f4:	83 ec 08             	sub    $0x8,%esp
801065f7:	8d 55 e2             	lea    -0x1e(%ebp),%edx
801065fa:	52                   	push   %edx
801065fb:	50                   	push   %eax
801065fc:	e8 49 c7 ff ff       	call   80102d4a <nameiparent>
80106601:	83 c4 10             	add    $0x10,%esp
80106604:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106607:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010660b:	0f 84 87 00 00 00    	je     80106698 <sys_link+0x1b6>
        goto bad;
    ilock(dp);
80106611:	83 ec 0c             	sub    $0xc,%esp
80106614:	ff 75 f0             	pushl  -0x10(%ebp)
80106617:	e8 d6 b8 ff ff       	call   80101ef2 <ilock>
8010661c:	83 c4 10             	add    $0x10,%esp
    if (dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0) {
8010661f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106622:	8b 10                	mov    (%eax),%edx
80106624:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106627:	8b 00                	mov    (%eax),%eax
80106629:	39 c2                	cmp    %eax,%edx
8010662b:	75 1d                	jne    8010664a <sys_link+0x168>
8010662d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106630:	8b 40 04             	mov    0x4(%eax),%eax
80106633:	83 ec 04             	sub    $0x4,%esp
80106636:	50                   	push   %eax
80106637:	8d 45 e2             	lea    -0x1e(%ebp),%eax
8010663a:	50                   	push   %eax
8010663b:	ff 75 f0             	pushl  -0x10(%ebp)
8010663e:	e8 9a c3 ff ff       	call   801029dd <dirlink>
80106643:	83 c4 10             	add    $0x10,%esp
80106646:	85 c0                	test   %eax,%eax
80106648:	79 10                	jns    8010665a <sys_link+0x178>
        iunlockput(dp);
8010664a:	83 ec 0c             	sub    $0xc,%esp
8010664d:	ff 75 f0             	pushl  -0x10(%ebp)
80106650:	e8 a0 bb ff ff       	call   801021f5 <iunlockput>
80106655:	83 c4 10             	add    $0x10,%esp
        goto bad;
80106658:	eb 3f                	jmp    80106699 <sys_link+0x1b7>
    }
    iunlockput(dp);
8010665a:	83 ec 0c             	sub    $0xc,%esp
8010665d:	ff 75 f0             	pushl  -0x10(%ebp)
80106660:	e8 90 bb ff ff       	call   801021f5 <iunlockput>
80106665:	83 c4 10             	add    $0x10,%esp
    iput(ip);
80106668:	83 ec 0c             	sub    $0xc,%esp
8010666b:	ff 75 f4             	pushl  -0xc(%ebp)
8010666e:	e8 92 ba ff ff       	call   80102105 <iput>
80106673:	83 c4 10             	add    $0x10,%esp

    end_op(proc->cwd->part->number);
80106676:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010667c:	8b 40 68             	mov    0x68(%eax),%eax
8010667f:	8b 40 50             	mov    0x50(%eax),%eax
80106682:	8b 40 14             	mov    0x14(%eax),%eax
80106685:	83 ec 0c             	sub    $0xc,%esp
80106688:	50                   	push   %eax
80106689:	e8 2b d9 ff ff       	call   80103fb9 <end_op>
8010668e:	83 c4 10             	add    $0x10,%esp

    return 0;
80106691:	b8 00 00 00 00       	mov    $0x0,%eax
80106696:	eb 5e                	jmp    801066f6 <sys_link+0x214>
    ip->nlink++;
    iupdate(ip);
    iunlock(ip);

    if ((dp = nameiparent(new, name)) == 0)
        goto bad;
80106698:	90                   	nop
    end_op(proc->cwd->part->number);

    return 0;

bad:
    ilock(ip);
80106699:	83 ec 0c             	sub    $0xc,%esp
8010669c:	ff 75 f4             	pushl  -0xc(%ebp)
8010669f:	e8 4e b8 ff ff       	call   80101ef2 <ilock>
801066a4:	83 c4 10             	add    $0x10,%esp
    ip->nlink--;
801066a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066aa:	0f b7 40 16          	movzwl 0x16(%eax),%eax
801066ae:	83 e8 01             	sub    $0x1,%eax
801066b1:	89 c2                	mov    %eax,%edx
801066b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066b6:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(ip);
801066ba:	83 ec 0c             	sub    $0xc,%esp
801066bd:	ff 75 f4             	pushl  -0xc(%ebp)
801066c0:	e8 cf b5 ff ff       	call   80101c94 <iupdate>
801066c5:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
801066c8:	83 ec 0c             	sub    $0xc,%esp
801066cb:	ff 75 f4             	pushl  -0xc(%ebp)
801066ce:	e8 22 bb ff ff       	call   801021f5 <iunlockput>
801066d3:	83 c4 10             	add    $0x10,%esp
    end_op(proc->cwd->part->number);
801066d6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801066dc:	8b 40 68             	mov    0x68(%eax),%eax
801066df:	8b 40 50             	mov    0x50(%eax),%eax
801066e2:	8b 40 14             	mov    0x14(%eax),%eax
801066e5:	83 ec 0c             	sub    $0xc,%esp
801066e8:	50                   	push   %eax
801066e9:	e8 cb d8 ff ff       	call   80103fb9 <end_op>
801066ee:	83 c4 10             	add    $0x10,%esp
    return -1;
801066f1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801066f6:	c9                   	leave  
801066f7:	c3                   	ret    

801066f8 <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int isdirempty(struct inode* dp)
{
801066f8:	55                   	push   %ebp
801066f9:	89 e5                	mov    %esp,%ebp
801066fb:	83 ec 28             	sub    $0x28,%esp
    int off;
    struct dirent de;

    for (off = 2 * sizeof(de); off < dp->size; off += sizeof(de)) {
801066fe:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80106705:	eb 40                	jmp    80106747 <isdirempty+0x4f>
        if (readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80106707:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010670a:	6a 10                	push   $0x10
8010670c:	50                   	push   %eax
8010670d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106710:	50                   	push   %eax
80106711:	ff 75 08             	pushl  0x8(%ebp)
80106714:	e8 67 be ff ff       	call   80102580 <readi>
80106719:	83 c4 10             	add    $0x10,%esp
8010671c:	83 f8 10             	cmp    $0x10,%eax
8010671f:	74 0d                	je     8010672e <isdirempty+0x36>
            panic("isdirempty: readi");
80106721:	83 ec 0c             	sub    $0xc,%esp
80106724:	68 2a 99 10 80       	push   $0x8010992a
80106729:	e8 38 9e ff ff       	call   80100566 <panic>
        if (de.inum != 0)
8010672e:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
80106732:	66 85 c0             	test   %ax,%ax
80106735:	74 07                	je     8010673e <isdirempty+0x46>
            return 0;
80106737:	b8 00 00 00 00       	mov    $0x0,%eax
8010673c:	eb 1b                	jmp    80106759 <isdirempty+0x61>
static int isdirempty(struct inode* dp)
{
    int off;
    struct dirent de;

    for (off = 2 * sizeof(de); off < dp->size; off += sizeof(de)) {
8010673e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106741:	83 c0 10             	add    $0x10,%eax
80106744:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106747:	8b 45 08             	mov    0x8(%ebp),%eax
8010674a:	8b 50 18             	mov    0x18(%eax),%edx
8010674d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106750:	39 c2                	cmp    %eax,%edx
80106752:	77 b3                	ja     80106707 <isdirempty+0xf>
        if (readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
            panic("isdirempty: readi");
        if (de.inum != 0)
            return 0;
    }
    return 1;
80106754:	b8 01 00 00 00       	mov    $0x1,%eax
}
80106759:	c9                   	leave  
8010675a:	c3                   	ret    

8010675b <sys_unlink>:

// PAGEBREAK!
int sys_unlink(void)
{
8010675b:	55                   	push   %ebp
8010675c:	89 e5                	mov    %esp,%ebp
8010675e:	83 ec 38             	sub    $0x38,%esp
    struct inode* ip, *dp;
    struct dirent de;
    char name[DIRSIZ], *path;
    uint off;

    if (argstr(0, &path) < 0)
80106761:	83 ec 08             	sub    $0x8,%esp
80106764:	8d 45 cc             	lea    -0x34(%ebp),%eax
80106767:	50                   	push   %eax
80106768:	6a 00                	push   $0x0
8010676a:	e8 2e fa ff ff       	call   8010619d <argstr>
8010676f:	83 c4 10             	add    $0x10,%esp
80106772:	85 c0                	test   %eax,%eax
80106774:	79 0a                	jns    80106780 <sys_unlink+0x25>
        return -1;
80106776:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010677b:	e9 14 02 00 00       	jmp    80106994 <sys_unlink+0x239>

    begin_op(proc->cwd->part->number);
80106780:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106786:	8b 40 68             	mov    0x68(%eax),%eax
80106789:	8b 40 50             	mov    0x50(%eax),%eax
8010678c:	8b 40 14             	mov    0x14(%eax),%eax
8010678f:	83 ec 0c             	sub    $0xc,%esp
80106792:	50                   	push   %eax
80106793:	e8 1a d7 ff ff       	call   80103eb2 <begin_op>
80106798:	83 c4 10             	add    $0x10,%esp
    if ((dp = nameiparent(path, name)) == 0) {
8010679b:	8b 45 cc             	mov    -0x34(%ebp),%eax
8010679e:	83 ec 08             	sub    $0x8,%esp
801067a1:	8d 55 d2             	lea    -0x2e(%ebp),%edx
801067a4:	52                   	push   %edx
801067a5:	50                   	push   %eax
801067a6:	e8 9f c5 ff ff       	call   80102d4a <nameiparent>
801067ab:	83 c4 10             	add    $0x10,%esp
801067ae:	89 45 f4             	mov    %eax,-0xc(%ebp)
801067b1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801067b5:	75 25                	jne    801067dc <sys_unlink+0x81>
        end_op(proc->cwd->part->number);
801067b7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801067bd:	8b 40 68             	mov    0x68(%eax),%eax
801067c0:	8b 40 50             	mov    0x50(%eax),%eax
801067c3:	8b 40 14             	mov    0x14(%eax),%eax
801067c6:	83 ec 0c             	sub    $0xc,%esp
801067c9:	50                   	push   %eax
801067ca:	e8 ea d7 ff ff       	call   80103fb9 <end_op>
801067cf:	83 c4 10             	add    $0x10,%esp
        return -1;
801067d2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801067d7:	e9 b8 01 00 00       	jmp    80106994 <sys_unlink+0x239>
    }

    ilock(dp);
801067dc:	83 ec 0c             	sub    $0xc,%esp
801067df:	ff 75 f4             	pushl  -0xc(%ebp)
801067e2:	e8 0b b7 ff ff       	call   80101ef2 <ilock>
801067e7:	83 c4 10             	add    $0x10,%esp

    // Cannot unlink "." or "..".
    if (namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
801067ea:	83 ec 08             	sub    $0x8,%esp
801067ed:	68 3c 99 10 80       	push   $0x8010993c
801067f2:	8d 45 d2             	lea    -0x2e(%ebp),%eax
801067f5:	50                   	push   %eax
801067f6:	e8 00 c1 ff ff       	call   801028fb <namecmp>
801067fb:	83 c4 10             	add    $0x10,%esp
801067fe:	85 c0                	test   %eax,%eax
80106800:	0f 84 60 01 00 00    	je     80106966 <sys_unlink+0x20b>
80106806:	83 ec 08             	sub    $0x8,%esp
80106809:	68 3e 99 10 80       	push   $0x8010993e
8010680e:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80106811:	50                   	push   %eax
80106812:	e8 e4 c0 ff ff       	call   801028fb <namecmp>
80106817:	83 c4 10             	add    $0x10,%esp
8010681a:	85 c0                	test   %eax,%eax
8010681c:	0f 84 44 01 00 00    	je     80106966 <sys_unlink+0x20b>
        goto bad;

    if ((ip = dirlookup(dp, name, &off)) == 0)
80106822:	83 ec 04             	sub    $0x4,%esp
80106825:	8d 45 c8             	lea    -0x38(%ebp),%eax
80106828:	50                   	push   %eax
80106829:	8d 45 d2             	lea    -0x2e(%ebp),%eax
8010682c:	50                   	push   %eax
8010682d:	ff 75 f4             	pushl  -0xc(%ebp)
80106830:	e8 e1 c0 ff ff       	call   80102916 <dirlookup>
80106835:	83 c4 10             	add    $0x10,%esp
80106838:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010683b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010683f:	0f 84 20 01 00 00    	je     80106965 <sys_unlink+0x20a>
        goto bad;
    ilock(ip);
80106845:	83 ec 0c             	sub    $0xc,%esp
80106848:	ff 75 f0             	pushl  -0x10(%ebp)
8010684b:	e8 a2 b6 ff ff       	call   80101ef2 <ilock>
80106850:	83 c4 10             	add    $0x10,%esp

    if (ip->nlink < 1)
80106853:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106856:	0f b7 40 16          	movzwl 0x16(%eax),%eax
8010685a:	66 85 c0             	test   %ax,%ax
8010685d:	7f 0d                	jg     8010686c <sys_unlink+0x111>
        panic("unlink: nlink < 1");
8010685f:	83 ec 0c             	sub    $0xc,%esp
80106862:	68 41 99 10 80       	push   $0x80109941
80106867:	e8 fa 9c ff ff       	call   80100566 <panic>
    if (ip->type == T_DIR && !isdirempty(ip)) {
8010686c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010686f:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106873:	66 83 f8 01          	cmp    $0x1,%ax
80106877:	75 25                	jne    8010689e <sys_unlink+0x143>
80106879:	83 ec 0c             	sub    $0xc,%esp
8010687c:	ff 75 f0             	pushl  -0x10(%ebp)
8010687f:	e8 74 fe ff ff       	call   801066f8 <isdirempty>
80106884:	83 c4 10             	add    $0x10,%esp
80106887:	85 c0                	test   %eax,%eax
80106889:	75 13                	jne    8010689e <sys_unlink+0x143>
        iunlockput(ip);
8010688b:	83 ec 0c             	sub    $0xc,%esp
8010688e:	ff 75 f0             	pushl  -0x10(%ebp)
80106891:	e8 5f b9 ff ff       	call   801021f5 <iunlockput>
80106896:	83 c4 10             	add    $0x10,%esp
        goto bad;
80106899:	e9 c8 00 00 00       	jmp    80106966 <sys_unlink+0x20b>
    }

    memset(&de, 0, sizeof(de));
8010689e:	83 ec 04             	sub    $0x4,%esp
801068a1:	6a 10                	push   $0x10
801068a3:	6a 00                	push   $0x0
801068a5:	8d 45 e0             	lea    -0x20(%ebp),%eax
801068a8:	50                   	push   %eax
801068a9:	e8 45 f5 ff ff       	call   80105df3 <memset>
801068ae:	83 c4 10             	add    $0x10,%esp
    if (writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801068b1:	8b 45 c8             	mov    -0x38(%ebp),%eax
801068b4:	6a 10                	push   $0x10
801068b6:	50                   	push   %eax
801068b7:	8d 45 e0             	lea    -0x20(%ebp),%eax
801068ba:	50                   	push   %eax
801068bb:	ff 75 f4             	pushl  -0xc(%ebp)
801068be:	e8 5d be ff ff       	call   80102720 <writei>
801068c3:	83 c4 10             	add    $0x10,%esp
801068c6:	83 f8 10             	cmp    $0x10,%eax
801068c9:	74 0d                	je     801068d8 <sys_unlink+0x17d>
        panic("unlink: writei");
801068cb:	83 ec 0c             	sub    $0xc,%esp
801068ce:	68 53 99 10 80       	push   $0x80109953
801068d3:	e8 8e 9c ff ff       	call   80100566 <panic>
    if (ip->type == T_DIR) {
801068d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801068db:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801068df:	66 83 f8 01          	cmp    $0x1,%ax
801068e3:	75 21                	jne    80106906 <sys_unlink+0x1ab>
        dp->nlink--;
801068e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801068e8:	0f b7 40 16          	movzwl 0x16(%eax),%eax
801068ec:	83 e8 01             	sub    $0x1,%eax
801068ef:	89 c2                	mov    %eax,%edx
801068f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801068f4:	66 89 50 16          	mov    %dx,0x16(%eax)
        iupdate(dp);
801068f8:	83 ec 0c             	sub    $0xc,%esp
801068fb:	ff 75 f4             	pushl  -0xc(%ebp)
801068fe:	e8 91 b3 ff ff       	call   80101c94 <iupdate>
80106903:	83 c4 10             	add    $0x10,%esp
    }
    iunlockput(dp);
80106906:	83 ec 0c             	sub    $0xc,%esp
80106909:	ff 75 f4             	pushl  -0xc(%ebp)
8010690c:	e8 e4 b8 ff ff       	call   801021f5 <iunlockput>
80106911:	83 c4 10             	add    $0x10,%esp

    ip->nlink--;
80106914:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106917:	0f b7 40 16          	movzwl 0x16(%eax),%eax
8010691b:	83 e8 01             	sub    $0x1,%eax
8010691e:	89 c2                	mov    %eax,%edx
80106920:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106923:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(ip);
80106927:	83 ec 0c             	sub    $0xc,%esp
8010692a:	ff 75 f0             	pushl  -0x10(%ebp)
8010692d:	e8 62 b3 ff ff       	call   80101c94 <iupdate>
80106932:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
80106935:	83 ec 0c             	sub    $0xc,%esp
80106938:	ff 75 f0             	pushl  -0x10(%ebp)
8010693b:	e8 b5 b8 ff ff       	call   801021f5 <iunlockput>
80106940:	83 c4 10             	add    $0x10,%esp

    end_op(proc->cwd->part->number);
80106943:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106949:	8b 40 68             	mov    0x68(%eax),%eax
8010694c:	8b 40 50             	mov    0x50(%eax),%eax
8010694f:	8b 40 14             	mov    0x14(%eax),%eax
80106952:	83 ec 0c             	sub    $0xc,%esp
80106955:	50                   	push   %eax
80106956:	e8 5e d6 ff ff       	call   80103fb9 <end_op>
8010695b:	83 c4 10             	add    $0x10,%esp

    return 0;
8010695e:	b8 00 00 00 00       	mov    $0x0,%eax
80106963:	eb 2f                	jmp    80106994 <sys_unlink+0x239>
    // Cannot unlink "." or "..".
    if (namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
        goto bad;

    if ((ip = dirlookup(dp, name, &off)) == 0)
        goto bad;
80106965:	90                   	nop
    end_op(proc->cwd->part->number);

    return 0;

bad:
    iunlockput(dp);
80106966:	83 ec 0c             	sub    $0xc,%esp
80106969:	ff 75 f4             	pushl  -0xc(%ebp)
8010696c:	e8 84 b8 ff ff       	call   801021f5 <iunlockput>
80106971:	83 c4 10             	add    $0x10,%esp
    end_op(proc->cwd->part->number);
80106974:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010697a:	8b 40 68             	mov    0x68(%eax),%eax
8010697d:	8b 40 50             	mov    0x50(%eax),%eax
80106980:	8b 40 14             	mov    0x14(%eax),%eax
80106983:	83 ec 0c             	sub    $0xc,%esp
80106986:	50                   	push   %eax
80106987:	e8 2d d6 ff ff       	call   80103fb9 <end_op>
8010698c:	83 c4 10             	add    $0x10,%esp
    return -1;
8010698f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80106994:	c9                   	leave  
80106995:	c3                   	ret    

80106996 <create>:

static struct inode* create(char* path, short type, short major, short minor)
{
80106996:	55                   	push   %ebp
80106997:	89 e5                	mov    %esp,%ebp
80106999:	83 ec 38             	sub    $0x38,%esp
8010699c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
8010699f:	8b 55 10             	mov    0x10(%ebp),%edx
801069a2:	8b 45 14             	mov    0x14(%ebp),%eax
801069a5:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
801069a9:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
801069ad:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
    uint off;
    struct inode* ip, *dp;
    char name[DIRSIZ];
    // cprintf("path %d  \n",path);
    if ((dp = nameiparent(path, name)) == 0)
801069b1:	83 ec 08             	sub    $0x8,%esp
801069b4:	8d 45 de             	lea    -0x22(%ebp),%eax
801069b7:	50                   	push   %eax
801069b8:	ff 75 08             	pushl  0x8(%ebp)
801069bb:	e8 8a c3 ff ff       	call   80102d4a <nameiparent>
801069c0:	83 c4 10             	add    $0x10,%esp
801069c3:	89 45 f4             	mov    %eax,-0xc(%ebp)
801069c6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801069ca:	75 0a                	jne    801069d6 <create+0x40>
        return 0;
801069cc:	b8 00 00 00 00       	mov    $0x0,%eax
801069d1:	e9 9c 01 00 00       	jmp    80106b72 <create+0x1dc>
    ilock(dp);
801069d6:	83 ec 0c             	sub    $0xc,%esp
801069d9:	ff 75 f4             	pushl  -0xc(%ebp)
801069dc:	e8 11 b5 ff ff       	call   80101ef2 <ilock>
801069e1:	83 c4 10             	add    $0x10,%esp

    if ((ip = dirlookup(dp, name, &off)) != 0) {
801069e4:	83 ec 04             	sub    $0x4,%esp
801069e7:	8d 45 ec             	lea    -0x14(%ebp),%eax
801069ea:	50                   	push   %eax
801069eb:	8d 45 de             	lea    -0x22(%ebp),%eax
801069ee:	50                   	push   %eax
801069ef:	ff 75 f4             	pushl  -0xc(%ebp)
801069f2:	e8 1f bf ff ff       	call   80102916 <dirlookup>
801069f7:	83 c4 10             	add    $0x10,%esp
801069fa:	89 45 f0             	mov    %eax,-0x10(%ebp)
801069fd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106a01:	74 50                	je     80106a53 <create+0xbd>
        iunlockput(dp);
80106a03:	83 ec 0c             	sub    $0xc,%esp
80106a06:	ff 75 f4             	pushl  -0xc(%ebp)
80106a09:	e8 e7 b7 ff ff       	call   801021f5 <iunlockput>
80106a0e:	83 c4 10             	add    $0x10,%esp
        ilock(ip);
80106a11:	83 ec 0c             	sub    $0xc,%esp
80106a14:	ff 75 f0             	pushl  -0x10(%ebp)
80106a17:	e8 d6 b4 ff ff       	call   80101ef2 <ilock>
80106a1c:	83 c4 10             	add    $0x10,%esp
        if (type == T_FILE && ip->type == T_FILE)
80106a1f:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80106a24:	75 15                	jne    80106a3b <create+0xa5>
80106a26:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106a29:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106a2d:	66 83 f8 02          	cmp    $0x2,%ax
80106a31:	75 08                	jne    80106a3b <create+0xa5>
            return ip;
80106a33:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106a36:	e9 37 01 00 00       	jmp    80106b72 <create+0x1dc>
        iunlockput(ip);
80106a3b:	83 ec 0c             	sub    $0xc,%esp
80106a3e:	ff 75 f0             	pushl  -0x10(%ebp)
80106a41:	e8 af b7 ff ff       	call   801021f5 <iunlockput>
80106a46:	83 c4 10             	add    $0x10,%esp
        return 0;
80106a49:	b8 00 00 00 00       	mov    $0x0,%eax
80106a4e:	e9 1f 01 00 00       	jmp    80106b72 <create+0x1dc>
    }
    if ((ip = ialloc(dp->dev, type, dp->part->number)) == 0)
80106a53:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a56:	8b 40 50             	mov    0x50(%eax),%eax
80106a59:	8b 40 14             	mov    0x14(%eax),%eax
80106a5c:	89 c1                	mov    %eax,%ecx
80106a5e:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80106a62:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a65:	8b 00                	mov    (%eax),%eax
80106a67:	83 ec 04             	sub    $0x4,%esp
80106a6a:	51                   	push   %ecx
80106a6b:	52                   	push   %edx
80106a6c:	50                   	push   %eax
80106a6d:	e8 09 b1 ff ff       	call   80101b7b <ialloc>
80106a72:	83 c4 10             	add    $0x10,%esp
80106a75:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106a78:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106a7c:	75 0d                	jne    80106a8b <create+0xf5>
        panic("create: ialloc");
80106a7e:	83 ec 0c             	sub    $0xc,%esp
80106a81:	68 62 99 10 80       	push   $0x80109962
80106a86:	e8 db 9a ff ff       	call   80100566 <panic>

    ilock(ip);
80106a8b:	83 ec 0c             	sub    $0xc,%esp
80106a8e:	ff 75 f0             	pushl  -0x10(%ebp)
80106a91:	e8 5c b4 ff ff       	call   80101ef2 <ilock>
80106a96:	83 c4 10             	add    $0x10,%esp
    ip->major = major;
80106a99:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106a9c:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
80106aa0:	66 89 50 12          	mov    %dx,0x12(%eax)
    ip->minor = minor;
80106aa4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106aa7:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
80106aab:	66 89 50 14          	mov    %dx,0x14(%eax)
    ip->nlink = 1;
80106aaf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106ab2:	66 c7 40 16 01 00    	movw   $0x1,0x16(%eax)
    iupdate(ip);
80106ab8:	83 ec 0c             	sub    $0xc,%esp
80106abb:	ff 75 f0             	pushl  -0x10(%ebp)
80106abe:	e8 d1 b1 ff ff       	call   80101c94 <iupdate>
80106ac3:	83 c4 10             	add    $0x10,%esp

    if (type == T_DIR) { // Create . and .. entries.
80106ac6:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80106acb:	75 6a                	jne    80106b37 <create+0x1a1>
        dp->nlink++;     // for ".."
80106acd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ad0:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80106ad4:	83 c0 01             	add    $0x1,%eax
80106ad7:	89 c2                	mov    %eax,%edx
80106ad9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106adc:	66 89 50 16          	mov    %dx,0x16(%eax)
        iupdate(dp);
80106ae0:	83 ec 0c             	sub    $0xc,%esp
80106ae3:	ff 75 f4             	pushl  -0xc(%ebp)
80106ae6:	e8 a9 b1 ff ff       	call   80101c94 <iupdate>
80106aeb:	83 c4 10             	add    $0x10,%esp
        // No ip->nlink++ for ".": avoid cyclic ref count.
        if (dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80106aee:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106af1:	8b 40 04             	mov    0x4(%eax),%eax
80106af4:	83 ec 04             	sub    $0x4,%esp
80106af7:	50                   	push   %eax
80106af8:	68 3c 99 10 80       	push   $0x8010993c
80106afd:	ff 75 f0             	pushl  -0x10(%ebp)
80106b00:	e8 d8 be ff ff       	call   801029dd <dirlink>
80106b05:	83 c4 10             	add    $0x10,%esp
80106b08:	85 c0                	test   %eax,%eax
80106b0a:	78 1e                	js     80106b2a <create+0x194>
80106b0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b0f:	8b 40 04             	mov    0x4(%eax),%eax
80106b12:	83 ec 04             	sub    $0x4,%esp
80106b15:	50                   	push   %eax
80106b16:	68 3e 99 10 80       	push   $0x8010993e
80106b1b:	ff 75 f0             	pushl  -0x10(%ebp)
80106b1e:	e8 ba be ff ff       	call   801029dd <dirlink>
80106b23:	83 c4 10             	add    $0x10,%esp
80106b26:	85 c0                	test   %eax,%eax
80106b28:	79 0d                	jns    80106b37 <create+0x1a1>
            panic("create dots");
80106b2a:	83 ec 0c             	sub    $0xc,%esp
80106b2d:	68 71 99 10 80       	push   $0x80109971
80106b32:	e8 2f 9a ff ff       	call   80100566 <panic>
    }

    if (dirlink(dp, name, ip->inum) < 0)
80106b37:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106b3a:	8b 40 04             	mov    0x4(%eax),%eax
80106b3d:	83 ec 04             	sub    $0x4,%esp
80106b40:	50                   	push   %eax
80106b41:	8d 45 de             	lea    -0x22(%ebp),%eax
80106b44:	50                   	push   %eax
80106b45:	ff 75 f4             	pushl  -0xc(%ebp)
80106b48:	e8 90 be ff ff       	call   801029dd <dirlink>
80106b4d:	83 c4 10             	add    $0x10,%esp
80106b50:	85 c0                	test   %eax,%eax
80106b52:	79 0d                	jns    80106b61 <create+0x1cb>
        panic("create: dirlink");
80106b54:	83 ec 0c             	sub    $0xc,%esp
80106b57:	68 7d 99 10 80       	push   $0x8010997d
80106b5c:	e8 05 9a ff ff       	call   80100566 <panic>

    iunlockput(dp);
80106b61:	83 ec 0c             	sub    $0xc,%esp
80106b64:	ff 75 f4             	pushl  -0xc(%ebp)
80106b67:	e8 89 b6 ff ff       	call   801021f5 <iunlockput>
80106b6c:	83 c4 10             	add    $0x10,%esp

    return ip;
80106b6f:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80106b72:	c9                   	leave  
80106b73:	c3                   	ret    

80106b74 <sys_open>:

int sys_open(void)
{
80106b74:	55                   	push   %ebp
80106b75:	89 e5                	mov    %esp,%ebp
80106b77:	83 ec 18             	sub    $0x18,%esp
    char* path;
    int omode;

    if (argstr(0, &path) < 0 || argint(1, &omode) < 0)
80106b7a:	83 ec 08             	sub    $0x8,%esp
80106b7d:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106b80:	50                   	push   %eax
80106b81:	6a 00                	push   $0x0
80106b83:	e8 15 f6 ff ff       	call   8010619d <argstr>
80106b88:	83 c4 10             	add    $0x10,%esp
80106b8b:	85 c0                	test   %eax,%eax
80106b8d:	78 15                	js     80106ba4 <sys_open+0x30>
80106b8f:	83 ec 08             	sub    $0x8,%esp
80106b92:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106b95:	50                   	push   %eax
80106b96:	6a 01                	push   $0x1
80106b98:	e8 7b f5 ff ff       	call   80106118 <argint>
80106b9d:	83 c4 10             	add    $0x10,%esp
80106ba0:	85 c0                	test   %eax,%eax
80106ba2:	79 07                	jns    80106bab <sys_open+0x37>
        return -1;
80106ba4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106ba9:	eb 13                	jmp    80106bbe <sys_open+0x4a>

    return openFile(path, omode);
80106bab:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106bae:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106bb1:	83 ec 08             	sub    $0x8,%esp
80106bb4:	52                   	push   %edx
80106bb5:	50                   	push   %eax
80106bb6:	e8 05 00 00 00       	call   80106bc0 <openFile>
80106bbb:	83 c4 10             	add    $0x10,%esp
}
80106bbe:	c9                   	leave  
80106bbf:	c3                   	ret    

80106bc0 <openFile>:

int openFile(char* path, int omode)
{
80106bc0:	55                   	push   %ebp
80106bc1:	89 e5                	mov    %esp,%ebp
80106bc3:	83 ec 18             	sub    $0x18,%esp
    int fd;
    struct file* f;
    struct inode* ip;
    begin_op(proc->cwd->part->number);
80106bc6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106bcc:	8b 40 68             	mov    0x68(%eax),%eax
80106bcf:	8b 40 50             	mov    0x50(%eax),%eax
80106bd2:	8b 40 14             	mov    0x14(%eax),%eax
80106bd5:	83 ec 0c             	sub    $0xc,%esp
80106bd8:	50                   	push   %eax
80106bd9:	e8 d4 d2 ff ff       	call   80103eb2 <begin_op>
80106bde:	83 c4 10             	add    $0x10,%esp

    if (omode & O_CREATE) {
80106be1:	8b 45 0c             	mov    0xc(%ebp),%eax
80106be4:	25 00 02 00 00       	and    $0x200,%eax
80106be9:	85 c0                	test   %eax,%eax
80106beb:	74 43                	je     80106c30 <openFile+0x70>
        ip = create(path, T_FILE, 0, 0);
80106bed:	6a 00                	push   $0x0
80106bef:	6a 00                	push   $0x0
80106bf1:	6a 02                	push   $0x2
80106bf3:	ff 75 08             	pushl  0x8(%ebp)
80106bf6:	e8 9b fd ff ff       	call   80106996 <create>
80106bfb:	83 c4 10             	add    $0x10,%esp
80106bfe:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (ip == 0) {
80106c01:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106c05:	0f 85 b5 00 00 00    	jne    80106cc0 <openFile+0x100>
            end_op(proc->cwd->part->number);
80106c0b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106c11:	8b 40 68             	mov    0x68(%eax),%eax
80106c14:	8b 40 50             	mov    0x50(%eax),%eax
80106c17:	8b 40 14             	mov    0x14(%eax),%eax
80106c1a:	83 ec 0c             	sub    $0xc,%esp
80106c1d:	50                   	push   %eax
80106c1e:	e8 96 d3 ff ff       	call   80103fb9 <end_op>
80106c23:	83 c4 10             	add    $0x10,%esp
            return -1;
80106c26:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106c2b:	e9 7f 01 00 00       	jmp    80106daf <openFile+0x1ef>
        }
    } else {
        if ((ip = namei(path)) == 0) {
80106c30:	83 ec 0c             	sub    $0xc,%esp
80106c33:	ff 75 08             	pushl  0x8(%ebp)
80106c36:	e8 d9 c0 ff ff       	call   80102d14 <namei>
80106c3b:	83 c4 10             	add    $0x10,%esp
80106c3e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106c41:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106c45:	75 25                	jne    80106c6c <openFile+0xac>
            end_op(proc->cwd->part->number);
80106c47:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106c4d:	8b 40 68             	mov    0x68(%eax),%eax
80106c50:	8b 40 50             	mov    0x50(%eax),%eax
80106c53:	8b 40 14             	mov    0x14(%eax),%eax
80106c56:	83 ec 0c             	sub    $0xc,%esp
80106c59:	50                   	push   %eax
80106c5a:	e8 5a d3 ff ff       	call   80103fb9 <end_op>
80106c5f:	83 c4 10             	add    $0x10,%esp
            return -1;
80106c62:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106c67:	e9 43 01 00 00       	jmp    80106daf <openFile+0x1ef>
        }
        ilock(ip);
80106c6c:	83 ec 0c             	sub    $0xc,%esp
80106c6f:	ff 75 f4             	pushl  -0xc(%ebp)
80106c72:	e8 7b b2 ff ff       	call   80101ef2 <ilock>
80106c77:	83 c4 10             	add    $0x10,%esp
        if (ip->type == T_DIR && omode != O_RDONLY) {
80106c7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106c7d:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106c81:	66 83 f8 01          	cmp    $0x1,%ax
80106c85:	75 39                	jne    80106cc0 <openFile+0x100>
80106c87:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80106c8b:	74 33                	je     80106cc0 <openFile+0x100>
            iunlockput(ip);
80106c8d:	83 ec 0c             	sub    $0xc,%esp
80106c90:	ff 75 f4             	pushl  -0xc(%ebp)
80106c93:	e8 5d b5 ff ff       	call   801021f5 <iunlockput>
80106c98:	83 c4 10             	add    $0x10,%esp
            end_op(proc->cwd->part->number);
80106c9b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106ca1:	8b 40 68             	mov    0x68(%eax),%eax
80106ca4:	8b 40 50             	mov    0x50(%eax),%eax
80106ca7:	8b 40 14             	mov    0x14(%eax),%eax
80106caa:	83 ec 0c             	sub    $0xc,%esp
80106cad:	50                   	push   %eax
80106cae:	e8 06 d3 ff ff       	call   80103fb9 <end_op>
80106cb3:	83 c4 10             	add    $0x10,%esp
            return -1;
80106cb6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106cbb:	e9 ef 00 00 00       	jmp    80106daf <openFile+0x1ef>
        }
    }

    if ((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0) {
80106cc0:	e8 26 a3 ff ff       	call   80100feb <filealloc>
80106cc5:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106cc8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106ccc:	74 17                	je     80106ce5 <openFile+0x125>
80106cce:	83 ec 0c             	sub    $0xc,%esp
80106cd1:	ff 75 f0             	pushl  -0x10(%ebp)
80106cd4:	e8 f0 f5 ff ff       	call   801062c9 <fdalloc>
80106cd9:	83 c4 10             	add    $0x10,%esp
80106cdc:	89 45 ec             	mov    %eax,-0x14(%ebp)
80106cdf:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80106ce3:	79 47                	jns    80106d2c <openFile+0x16c>
        if (f)
80106ce5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106ce9:	74 0e                	je     80106cf9 <openFile+0x139>
            fileclose(f);
80106ceb:	83 ec 0c             	sub    $0xc,%esp
80106cee:	ff 75 f0             	pushl  -0x10(%ebp)
80106cf1:	e8 b3 a3 ff ff       	call   801010a9 <fileclose>
80106cf6:	83 c4 10             	add    $0x10,%esp
        iunlockput(ip);
80106cf9:	83 ec 0c             	sub    $0xc,%esp
80106cfc:	ff 75 f4             	pushl  -0xc(%ebp)
80106cff:	e8 f1 b4 ff ff       	call   801021f5 <iunlockput>
80106d04:	83 c4 10             	add    $0x10,%esp
        end_op(proc->cwd->part->number);
80106d07:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106d0d:	8b 40 68             	mov    0x68(%eax),%eax
80106d10:	8b 40 50             	mov    0x50(%eax),%eax
80106d13:	8b 40 14             	mov    0x14(%eax),%eax
80106d16:	83 ec 0c             	sub    $0xc,%esp
80106d19:	50                   	push   %eax
80106d1a:	e8 9a d2 ff ff       	call   80103fb9 <end_op>
80106d1f:	83 c4 10             	add    $0x10,%esp
        return -1;
80106d22:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106d27:	e9 83 00 00 00       	jmp    80106daf <openFile+0x1ef>
    }
    iunlock(ip);
80106d2c:	83 ec 0c             	sub    $0xc,%esp
80106d2f:	ff 75 f4             	pushl  -0xc(%ebp)
80106d32:	e8 5c b3 ff ff       	call   80102093 <iunlock>
80106d37:	83 c4 10             	add    $0x10,%esp
    end_op(proc->cwd->part->number);
80106d3a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106d40:	8b 40 68             	mov    0x68(%eax),%eax
80106d43:	8b 40 50             	mov    0x50(%eax),%eax
80106d46:	8b 40 14             	mov    0x14(%eax),%eax
80106d49:	83 ec 0c             	sub    $0xc,%esp
80106d4c:	50                   	push   %eax
80106d4d:	e8 67 d2 ff ff       	call   80103fb9 <end_op>
80106d52:	83 c4 10             	add    $0x10,%esp

    f->type = FD_INODE;
80106d55:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106d58:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
    f->ip = ip;
80106d5e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106d61:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106d64:	89 50 0e             	mov    %edx,0xe(%eax)
    f->off = 0;
80106d67:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106d6a:	c7 40 12 00 00 00 00 	movl   $0x0,0x12(%eax)
    f->readable = !(omode & O_WRONLY);
80106d71:	8b 45 0c             	mov    0xc(%ebp),%eax
80106d74:	83 e0 01             	and    $0x1,%eax
80106d77:	85 c0                	test   %eax,%eax
80106d79:	0f 94 c0             	sete   %al
80106d7c:	89 c2                	mov    %eax,%edx
80106d7e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106d81:	88 50 08             	mov    %dl,0x8(%eax)
    f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80106d84:	8b 45 0c             	mov    0xc(%ebp),%eax
80106d87:	83 e0 01             	and    $0x1,%eax
80106d8a:	85 c0                	test   %eax,%eax
80106d8c:	75 0a                	jne    80106d98 <openFile+0x1d8>
80106d8e:	8b 45 0c             	mov    0xc(%ebp),%eax
80106d91:	83 e0 02             	and    $0x2,%eax
80106d94:	85 c0                	test   %eax,%eax
80106d96:	74 07                	je     80106d9f <openFile+0x1df>
80106d98:	b8 01 00 00 00       	mov    $0x1,%eax
80106d9d:	eb 05                	jmp    80106da4 <openFile+0x1e4>
80106d9f:	b8 00 00 00 00       	mov    $0x0,%eax
80106da4:	89 c2                	mov    %eax,%edx
80106da6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106da9:	88 50 09             	mov    %dl,0x9(%eax)
    return fd;
80106dac:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80106daf:	c9                   	leave  
80106db0:	c3                   	ret    

80106db1 <sys_mkdir>:

int sys_mkdir(void)
{
80106db1:	55                   	push   %ebp
80106db2:	89 e5                	mov    %esp,%ebp
80106db4:	83 ec 18             	sub    $0x18,%esp
    char* path;
    struct inode* ip;

    begin_op(proc->cwd->part->number);
80106db7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106dbd:	8b 40 68             	mov    0x68(%eax),%eax
80106dc0:	8b 40 50             	mov    0x50(%eax),%eax
80106dc3:	8b 40 14             	mov    0x14(%eax),%eax
80106dc6:	83 ec 0c             	sub    $0xc,%esp
80106dc9:	50                   	push   %eax
80106dca:	e8 e3 d0 ff ff       	call   80103eb2 <begin_op>
80106dcf:	83 c4 10             	add    $0x10,%esp
    if (argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0) {
80106dd2:	83 ec 08             	sub    $0x8,%esp
80106dd5:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106dd8:	50                   	push   %eax
80106dd9:	6a 00                	push   $0x0
80106ddb:	e8 bd f3 ff ff       	call   8010619d <argstr>
80106de0:	83 c4 10             	add    $0x10,%esp
80106de3:	85 c0                	test   %eax,%eax
80106de5:	78 1b                	js     80106e02 <sys_mkdir+0x51>
80106de7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106dea:	6a 00                	push   $0x0
80106dec:	6a 00                	push   $0x0
80106dee:	6a 01                	push   $0x1
80106df0:	50                   	push   %eax
80106df1:	e8 a0 fb ff ff       	call   80106996 <create>
80106df6:	83 c4 10             	add    $0x10,%esp
80106df9:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106dfc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106e00:	75 22                	jne    80106e24 <sys_mkdir+0x73>
        end_op(proc->cwd->part->number);
80106e02:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106e08:	8b 40 68             	mov    0x68(%eax),%eax
80106e0b:	8b 40 50             	mov    0x50(%eax),%eax
80106e0e:	8b 40 14             	mov    0x14(%eax),%eax
80106e11:	83 ec 0c             	sub    $0xc,%esp
80106e14:	50                   	push   %eax
80106e15:	e8 9f d1 ff ff       	call   80103fb9 <end_op>
80106e1a:	83 c4 10             	add    $0x10,%esp
        return -1;
80106e1d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106e22:	eb 2e                	jmp    80106e52 <sys_mkdir+0xa1>
    }
    iunlockput(ip);
80106e24:	83 ec 0c             	sub    $0xc,%esp
80106e27:	ff 75 f4             	pushl  -0xc(%ebp)
80106e2a:	e8 c6 b3 ff ff       	call   801021f5 <iunlockput>
80106e2f:	83 c4 10             	add    $0x10,%esp
    end_op(proc->cwd->part->number);
80106e32:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106e38:	8b 40 68             	mov    0x68(%eax),%eax
80106e3b:	8b 40 50             	mov    0x50(%eax),%eax
80106e3e:	8b 40 14             	mov    0x14(%eax),%eax
80106e41:	83 ec 0c             	sub    $0xc,%esp
80106e44:	50                   	push   %eax
80106e45:	e8 6f d1 ff ff       	call   80103fb9 <end_op>
80106e4a:	83 c4 10             	add    $0x10,%esp
    return 0;
80106e4d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106e52:	c9                   	leave  
80106e53:	c3                   	ret    

80106e54 <sys_mknod>:

int sys_mknod(void)
{
80106e54:	55                   	push   %ebp
80106e55:	89 e5                	mov    %esp,%ebp
80106e57:	83 ec 28             	sub    $0x28,%esp
    struct inode* ip;
    char* path;
    int len;
    int major, minor;

    begin_op(proc->cwd->part->number);
80106e5a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106e60:	8b 40 68             	mov    0x68(%eax),%eax
80106e63:	8b 40 50             	mov    0x50(%eax),%eax
80106e66:	8b 40 14             	mov    0x14(%eax),%eax
80106e69:	83 ec 0c             	sub    $0xc,%esp
80106e6c:	50                   	push   %eax
80106e6d:	e8 40 d0 ff ff       	call   80103eb2 <begin_op>
80106e72:	83 c4 10             	add    $0x10,%esp
    if ((len = argstr(0, &path)) < 0 || argint(1, &major) < 0 || argint(2, &minor) < 0 ||
80106e75:	83 ec 08             	sub    $0x8,%esp
80106e78:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106e7b:	50                   	push   %eax
80106e7c:	6a 00                	push   $0x0
80106e7e:	e8 1a f3 ff ff       	call   8010619d <argstr>
80106e83:	83 c4 10             	add    $0x10,%esp
80106e86:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106e89:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106e8d:	78 4f                	js     80106ede <sys_mknod+0x8a>
80106e8f:	83 ec 08             	sub    $0x8,%esp
80106e92:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106e95:	50                   	push   %eax
80106e96:	6a 01                	push   $0x1
80106e98:	e8 7b f2 ff ff       	call   80106118 <argint>
80106e9d:	83 c4 10             	add    $0x10,%esp
80106ea0:	85 c0                	test   %eax,%eax
80106ea2:	78 3a                	js     80106ede <sys_mknod+0x8a>
80106ea4:	83 ec 08             	sub    $0x8,%esp
80106ea7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106eaa:	50                   	push   %eax
80106eab:	6a 02                	push   $0x2
80106ead:	e8 66 f2 ff ff       	call   80106118 <argint>
80106eb2:	83 c4 10             	add    $0x10,%esp
80106eb5:	85 c0                	test   %eax,%eax
80106eb7:	78 25                	js     80106ede <sys_mknod+0x8a>
        (ip = create(path, T_DEV, major, minor)) == 0) {
80106eb9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106ebc:	0f bf c8             	movswl %ax,%ecx
80106ebf:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106ec2:	0f bf d0             	movswl %ax,%edx
80106ec5:	8b 45 ec             	mov    -0x14(%ebp),%eax
    char* path;
    int len;
    int major, minor;

    begin_op(proc->cwd->part->number);
    if ((len = argstr(0, &path)) < 0 || argint(1, &major) < 0 || argint(2, &minor) < 0 ||
80106ec8:	51                   	push   %ecx
80106ec9:	52                   	push   %edx
80106eca:	6a 03                	push   $0x3
80106ecc:	50                   	push   %eax
80106ecd:	e8 c4 fa ff ff       	call   80106996 <create>
80106ed2:	83 c4 10             	add    $0x10,%esp
80106ed5:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106ed8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106edc:	75 22                	jne    80106f00 <sys_mknod+0xac>
        (ip = create(path, T_DEV, major, minor)) == 0) {
        end_op(proc->cwd->part->number);
80106ede:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106ee4:	8b 40 68             	mov    0x68(%eax),%eax
80106ee7:	8b 40 50             	mov    0x50(%eax),%eax
80106eea:	8b 40 14             	mov    0x14(%eax),%eax
80106eed:	83 ec 0c             	sub    $0xc,%esp
80106ef0:	50                   	push   %eax
80106ef1:	e8 c3 d0 ff ff       	call   80103fb9 <end_op>
80106ef6:	83 c4 10             	add    $0x10,%esp
        return -1;
80106ef9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106efe:	eb 2e                	jmp    80106f2e <sys_mknod+0xda>
    }
    iunlockput(ip);
80106f00:	83 ec 0c             	sub    $0xc,%esp
80106f03:	ff 75 f0             	pushl  -0x10(%ebp)
80106f06:	e8 ea b2 ff ff       	call   801021f5 <iunlockput>
80106f0b:	83 c4 10             	add    $0x10,%esp
    end_op(proc->cwd->part->number);
80106f0e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106f14:	8b 40 68             	mov    0x68(%eax),%eax
80106f17:	8b 40 50             	mov    0x50(%eax),%eax
80106f1a:	8b 40 14             	mov    0x14(%eax),%eax
80106f1d:	83 ec 0c             	sub    $0xc,%esp
80106f20:	50                   	push   %eax
80106f21:	e8 93 d0 ff ff       	call   80103fb9 <end_op>
80106f26:	83 c4 10             	add    $0x10,%esp
    return 0;
80106f29:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106f2e:	c9                   	leave  
80106f2f:	c3                   	ret    

80106f30 <sys_chdir>:

int sys_chdir(void)
{
80106f30:	55                   	push   %ebp
80106f31:	89 e5                	mov    %esp,%ebp
80106f33:	83 ec 18             	sub    $0x18,%esp
    char* path;
    struct inode* ip;


    begin_op(proc->cwd->part->number);
80106f36:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106f3c:	8b 40 68             	mov    0x68(%eax),%eax
80106f3f:	8b 40 50             	mov    0x50(%eax),%eax
80106f42:	8b 40 14             	mov    0x14(%eax),%eax
80106f45:	83 ec 0c             	sub    $0xc,%esp
80106f48:	50                   	push   %eax
80106f49:	e8 64 cf ff ff       	call   80103eb2 <begin_op>
80106f4e:	83 c4 10             	add    $0x10,%esp
    if (argstr(0, &path) < 0 || (ip = namei(path)) == 0) {
80106f51:	83 ec 08             	sub    $0x8,%esp
80106f54:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106f57:	50                   	push   %eax
80106f58:	6a 00                	push   $0x0
80106f5a:	e8 3e f2 ff ff       	call   8010619d <argstr>
80106f5f:	83 c4 10             	add    $0x10,%esp
80106f62:	85 c0                	test   %eax,%eax
80106f64:	78 18                	js     80106f7e <sys_chdir+0x4e>
80106f66:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106f69:	83 ec 0c             	sub    $0xc,%esp
80106f6c:	50                   	push   %eax
80106f6d:	e8 a2 bd ff ff       	call   80102d14 <namei>
80106f72:	83 c4 10             	add    $0x10,%esp
80106f75:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106f78:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106f7c:	75 25                	jne    80106fa3 <sys_chdir+0x73>
        end_op(proc->cwd->part->number);
80106f7e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106f84:	8b 40 68             	mov    0x68(%eax),%eax
80106f87:	8b 40 50             	mov    0x50(%eax),%eax
80106f8a:	8b 40 14             	mov    0x14(%eax),%eax
80106f8d:	83 ec 0c             	sub    $0xc,%esp
80106f90:	50                   	push   %eax
80106f91:	e8 23 d0 ff ff       	call   80103fb9 <end_op>
80106f96:	83 c4 10             	add    $0x10,%esp
        return -1;
80106f99:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106f9e:	e9 9a 00 00 00       	jmp    8010703d <sys_chdir+0x10d>
    }
    //cprintf("cd path %s \n",path);
    ilock(ip);
80106fa3:	83 ec 0c             	sub    $0xc,%esp
80106fa6:	ff 75 f4             	pushl  -0xc(%ebp)
80106fa9:	e8 44 af ff ff       	call   80101ef2 <ilock>
80106fae:	83 c4 10             	add    $0x10,%esp
    if (ip->type != T_DIR) {
80106fb1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106fb4:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106fb8:	66 83 f8 01          	cmp    $0x1,%ax
80106fbc:	74 30                	je     80106fee <sys_chdir+0xbe>
        iunlockput(ip);
80106fbe:	83 ec 0c             	sub    $0xc,%esp
80106fc1:	ff 75 f4             	pushl  -0xc(%ebp)
80106fc4:	e8 2c b2 ff ff       	call   801021f5 <iunlockput>
80106fc9:	83 c4 10             	add    $0x10,%esp
        end_op(proc->cwd->part->number);
80106fcc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106fd2:	8b 40 68             	mov    0x68(%eax),%eax
80106fd5:	8b 40 50             	mov    0x50(%eax),%eax
80106fd8:	8b 40 14             	mov    0x14(%eax),%eax
80106fdb:	83 ec 0c             	sub    $0xc,%esp
80106fde:	50                   	push   %eax
80106fdf:	e8 d5 cf ff ff       	call   80103fb9 <end_op>
80106fe4:	83 c4 10             	add    $0x10,%esp
        return -1;
80106fe7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106fec:	eb 4f                	jmp    8010703d <sys_chdir+0x10d>
    }
    iunlock(ip);
80106fee:	83 ec 0c             	sub    $0xc,%esp
80106ff1:	ff 75 f4             	pushl  -0xc(%ebp)
80106ff4:	e8 9a b0 ff ff       	call   80102093 <iunlock>
80106ff9:	83 c4 10             	add    $0x10,%esp
    iput(proc->cwd);
80106ffc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107002:	8b 40 68             	mov    0x68(%eax),%eax
80107005:	83 ec 0c             	sub    $0xc,%esp
80107008:	50                   	push   %eax
80107009:	e8 f7 b0 ff ff       	call   80102105 <iput>
8010700e:	83 c4 10             	add    $0x10,%esp
    end_op(proc->cwd->part->number);
80107011:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107017:	8b 40 68             	mov    0x68(%eax),%eax
8010701a:	8b 40 50             	mov    0x50(%eax),%eax
8010701d:	8b 40 14             	mov    0x14(%eax),%eax
80107020:	83 ec 0c             	sub    $0xc,%esp
80107023:	50                   	push   %eax
80107024:	e8 90 cf ff ff       	call   80103fb9 <end_op>
80107029:	83 c4 10             	add    $0x10,%esp
    proc->cwd = ip;
8010702c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107032:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107035:	89 50 68             	mov    %edx,0x68(%eax)
    return 0;
80107038:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010703d:	c9                   	leave  
8010703e:	c3                   	ret    

8010703f <sys_exec>:

int sys_exec(void)
{
8010703f:	55                   	push   %ebp
80107040:	89 e5                	mov    %esp,%ebp
80107042:	81 ec 98 00 00 00    	sub    $0x98,%esp
    char* path, *argv[MAXARG];
    int i;
    uint uargv, uarg;

    if (argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0) {
80107048:	83 ec 08             	sub    $0x8,%esp
8010704b:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010704e:	50                   	push   %eax
8010704f:	6a 00                	push   $0x0
80107051:	e8 47 f1 ff ff       	call   8010619d <argstr>
80107056:	83 c4 10             	add    $0x10,%esp
80107059:	85 c0                	test   %eax,%eax
8010705b:	78 18                	js     80107075 <sys_exec+0x36>
8010705d:	83 ec 08             	sub    $0x8,%esp
80107060:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80107066:	50                   	push   %eax
80107067:	6a 01                	push   $0x1
80107069:	e8 aa f0 ff ff       	call   80106118 <argint>
8010706e:	83 c4 10             	add    $0x10,%esp
80107071:	85 c0                	test   %eax,%eax
80107073:	79 0a                	jns    8010707f <sys_exec+0x40>
        return -1;
80107075:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010707a:	e9 c6 00 00 00       	jmp    80107145 <sys_exec+0x106>
    }
    memset(argv, 0, sizeof(argv));
8010707f:	83 ec 04             	sub    $0x4,%esp
80107082:	68 80 00 00 00       	push   $0x80
80107087:	6a 00                	push   $0x0
80107089:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
8010708f:	50                   	push   %eax
80107090:	e8 5e ed ff ff       	call   80105df3 <memset>
80107095:	83 c4 10             	add    $0x10,%esp
    for (i = 0;; i++) {
80107098:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
        if (i >= NELEM(argv))
8010709f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070a2:	83 f8 1f             	cmp    $0x1f,%eax
801070a5:	76 0a                	jbe    801070b1 <sys_exec+0x72>
            return -1;
801070a7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801070ac:	e9 94 00 00 00       	jmp    80107145 <sys_exec+0x106>
        if (fetchint(uargv + 4 * i, (int*)&uarg) < 0)
801070b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070b4:	c1 e0 02             	shl    $0x2,%eax
801070b7:	89 c2                	mov    %eax,%edx
801070b9:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
801070bf:	01 c2                	add    %eax,%edx
801070c1:	83 ec 08             	sub    $0x8,%esp
801070c4:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
801070ca:	50                   	push   %eax
801070cb:	52                   	push   %edx
801070cc:	e8 ab ef ff ff       	call   8010607c <fetchint>
801070d1:	83 c4 10             	add    $0x10,%esp
801070d4:	85 c0                	test   %eax,%eax
801070d6:	79 07                	jns    801070df <sys_exec+0xa0>
            return -1;
801070d8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801070dd:	eb 66                	jmp    80107145 <sys_exec+0x106>
        if (uarg == 0) {
801070df:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
801070e5:	85 c0                	test   %eax,%eax
801070e7:	75 27                	jne    80107110 <sys_exec+0xd1>
            argv[i] = 0;
801070e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070ec:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
801070f3:	00 00 00 00 
            break;
801070f7:	90                   	nop
        }
        if (fetchstr(uarg, &argv[i]) < 0)
            return -1;
    }
    return exec(path, argv);
801070f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801070fb:	83 ec 08             	sub    $0x8,%esp
801070fe:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80107104:	52                   	push   %edx
80107105:	50                   	push   %eax
80107106:	e8 66 9a ff ff       	call   80100b71 <exec>
8010710b:	83 c4 10             	add    $0x10,%esp
8010710e:	eb 35                	jmp    80107145 <sys_exec+0x106>
            return -1;
        if (uarg == 0) {
            argv[i] = 0;
            break;
        }
        if (fetchstr(uarg, &argv[i]) < 0)
80107110:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80107116:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107119:	c1 e2 02             	shl    $0x2,%edx
8010711c:	01 c2                	add    %eax,%edx
8010711e:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80107124:	83 ec 08             	sub    $0x8,%esp
80107127:	52                   	push   %edx
80107128:	50                   	push   %eax
80107129:	e8 88 ef ff ff       	call   801060b6 <fetchstr>
8010712e:	83 c4 10             	add    $0x10,%esp
80107131:	85 c0                	test   %eax,%eax
80107133:	79 07                	jns    8010713c <sys_exec+0xfd>
            return -1;
80107135:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010713a:	eb 09                	jmp    80107145 <sys_exec+0x106>

    if (argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0) {
        return -1;
    }
    memset(argv, 0, sizeof(argv));
    for (i = 0;; i++) {
8010713c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
            argv[i] = 0;
            break;
        }
        if (fetchstr(uarg, &argv[i]) < 0)
            return -1;
    }
80107140:	e9 5a ff ff ff       	jmp    8010709f <sys_exec+0x60>
    return exec(path, argv);
}
80107145:	c9                   	leave  
80107146:	c3                   	ret    

80107147 <sys_pipe>:

int sys_pipe(void)
{
80107147:	55                   	push   %ebp
80107148:	89 e5                	mov    %esp,%ebp
8010714a:	83 ec 28             	sub    $0x28,%esp
    int* fd;
    struct file* rf, *wf;
    int fd0, fd1;

    if (argptr(0, (void*)&fd, 2 * sizeof(fd[0])) < 0)
8010714d:	83 ec 04             	sub    $0x4,%esp
80107150:	6a 08                	push   $0x8
80107152:	8d 45 ec             	lea    -0x14(%ebp),%eax
80107155:	50                   	push   %eax
80107156:	6a 00                	push   $0x0
80107158:	e8 e3 ef ff ff       	call   80106140 <argptr>
8010715d:	83 c4 10             	add    $0x10,%esp
80107160:	85 c0                	test   %eax,%eax
80107162:	79 0a                	jns    8010716e <sys_pipe+0x27>
        return -1;
80107164:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107169:	e9 af 00 00 00       	jmp    8010721d <sys_pipe+0xd6>
    if (pipealloc(&rf, &wf) < 0)
8010716e:	83 ec 08             	sub    $0x8,%esp
80107171:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80107174:	50                   	push   %eax
80107175:	8d 45 e8             	lea    -0x18(%ebp),%eax
80107178:	50                   	push   %eax
80107179:	e8 04 da ff ff       	call   80104b82 <pipealloc>
8010717e:	83 c4 10             	add    $0x10,%esp
80107181:	85 c0                	test   %eax,%eax
80107183:	79 0a                	jns    8010718f <sys_pipe+0x48>
        return -1;
80107185:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010718a:	e9 8e 00 00 00       	jmp    8010721d <sys_pipe+0xd6>
    fd0 = -1;
8010718f:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
    if ((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0) {
80107196:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107199:	83 ec 0c             	sub    $0xc,%esp
8010719c:	50                   	push   %eax
8010719d:	e8 27 f1 ff ff       	call   801062c9 <fdalloc>
801071a2:	83 c4 10             	add    $0x10,%esp
801071a5:	89 45 f4             	mov    %eax,-0xc(%ebp)
801071a8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801071ac:	78 18                	js     801071c6 <sys_pipe+0x7f>
801071ae:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801071b1:	83 ec 0c             	sub    $0xc,%esp
801071b4:	50                   	push   %eax
801071b5:	e8 0f f1 ff ff       	call   801062c9 <fdalloc>
801071ba:	83 c4 10             	add    $0x10,%esp
801071bd:	89 45 f0             	mov    %eax,-0x10(%ebp)
801071c0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801071c4:	79 3f                	jns    80107205 <sys_pipe+0xbe>
        if (fd0 >= 0)
801071c6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801071ca:	78 14                	js     801071e0 <sys_pipe+0x99>
            proc->ofile[fd0] = 0;
801071cc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801071d2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801071d5:	83 c2 08             	add    $0x8,%edx
801071d8:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801071df:	00 
        fileclose(rf);
801071e0:	8b 45 e8             	mov    -0x18(%ebp),%eax
801071e3:	83 ec 0c             	sub    $0xc,%esp
801071e6:	50                   	push   %eax
801071e7:	e8 bd 9e ff ff       	call   801010a9 <fileclose>
801071ec:	83 c4 10             	add    $0x10,%esp
        fileclose(wf);
801071ef:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801071f2:	83 ec 0c             	sub    $0xc,%esp
801071f5:	50                   	push   %eax
801071f6:	e8 ae 9e ff ff       	call   801010a9 <fileclose>
801071fb:	83 c4 10             	add    $0x10,%esp
        return -1;
801071fe:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107203:	eb 18                	jmp    8010721d <sys_pipe+0xd6>
    }
    fd[0] = fd0;
80107205:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107208:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010720b:	89 10                	mov    %edx,(%eax)
    fd[1] = fd1;
8010720d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107210:	8d 50 04             	lea    0x4(%eax),%edx
80107213:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107216:	89 02                	mov    %eax,(%edx)
    return 0;
80107218:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010721d:	c9                   	leave  
8010721e:	c3                   	ret    

8010721f <sys_mount>:

int sys_mount(void)
{
8010721f:	55                   	push   %ebp
80107220:	89 e5                	mov    %esp,%ebp
80107222:	83 ec 18             	sub    $0x18,%esp
    char* path;
    uint partitionNumber;
    struct inode * i;
    if (argstr(0, &path) < 0 || argint(1, (int*)&partitionNumber) < 0 || partitionNumber < 0 || partitionNumber > NPARTITIONS) {
80107225:	83 ec 08             	sub    $0x8,%esp
80107228:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010722b:	50                   	push   %eax
8010722c:	6a 00                	push   $0x0
8010722e:	e8 6a ef ff ff       	call   8010619d <argstr>
80107233:	83 c4 10             	add    $0x10,%esp
80107236:	85 c0                	test   %eax,%eax
80107238:	78 1d                	js     80107257 <sys_mount+0x38>
8010723a:	83 ec 08             	sub    $0x8,%esp
8010723d:	8d 45 ec             	lea    -0x14(%ebp),%eax
80107240:	50                   	push   %eax
80107241:	6a 01                	push   $0x1
80107243:	e8 d0 ee ff ff       	call   80106118 <argint>
80107248:	83 c4 10             	add    $0x10,%esp
8010724b:	85 c0                	test   %eax,%eax
8010724d:	78 08                	js     80107257 <sys_mount+0x38>
8010724f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107252:	83 f8 04             	cmp    $0x4,%eax
80107255:	76 0a                	jbe    80107261 <sys_mount+0x42>
        return -1;
80107257:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010725c:	e9 a4 00 00 00       	jmp    80107305 <sys_mount+0xe6>
    }
    //cprintf("cwd %d , part %d \n",proc->cwd->inum,proc->cwd->part->number);

    i=nameiIgnoreMounts(path);
80107261:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107264:	83 ec 0c             	sub    $0xc,%esp
80107267:	50                   	push   %eax
80107268:	e8 c2 ba ff ff       	call   80102d2f <nameiIgnoreMounts>
8010726d:	83 c4 10             	add    $0x10,%esp
80107270:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(i==0){
80107273:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107277:	75 0a                	jne    80107283 <sys_mount+0x64>
        return -1;
80107279:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010727e:	e9 82 00 00 00       	jmp    80107305 <sys_mount+0xe6>
    }
    ilock(i);
80107283:	83 ec 0c             	sub    $0xc,%esp
80107286:	ff 75 f4             	pushl  -0xc(%ebp)
80107289:	e8 64 ac ff ff       	call   80101ef2 <ilock>
8010728e:	83 c4 10             	add    $0x10,%esp
    if(i->type!=T_DIR){
80107291:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107294:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80107298:	66 83 f8 01          	cmp    $0x1,%ax
8010729c:	74 07                	je     801072a5 <sys_mount+0x86>
        return -1;
8010729e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801072a3:	eb 60                	jmp    80107305 <sys_mount+0xe6>
    }
    i->major=MOUNTING_POINT;
801072a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072a8:	66 c7 40 12 01 00    	movw   $0x1,0x12(%eax)
    i->minor=partitionNumber;
801072ae:	8b 45 ec             	mov    -0x14(%ebp),%eax
801072b1:	89 c2                	mov    %eax,%edx
801072b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072b6:	66 89 50 14          	mov    %dx,0x14(%eax)
    begin_op(i->part->number);
801072ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072bd:	8b 40 50             	mov    0x50(%eax),%eax
801072c0:	8b 40 14             	mov    0x14(%eax),%eax
801072c3:	83 ec 0c             	sub    $0xc,%esp
801072c6:	50                   	push   %eax
801072c7:	e8 e6 cb ff ff       	call   80103eb2 <begin_op>
801072cc:	83 c4 10             	add    $0x10,%esp
    iupdate(i);
801072cf:	83 ec 0c             	sub    $0xc,%esp
801072d2:	ff 75 f4             	pushl  -0xc(%ebp)
801072d5:	e8 ba a9 ff ff       	call   80101c94 <iupdate>
801072da:	83 c4 10             	add    $0x10,%esp
    end_op(i->part->number);
801072dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072e0:	8b 40 50             	mov    0x50(%eax),%eax
801072e3:	8b 40 14             	mov    0x14(%eax),%eax
801072e6:	83 ec 0c             	sub    $0xc,%esp
801072e9:	50                   	push   %eax
801072ea:	e8 ca cc ff ff       	call   80103fb9 <end_op>
801072ef:	83 c4 10             	add    $0x10,%esp
    iunlockput(i);
801072f2:	83 ec 0c             	sub    $0xc,%esp
801072f5:	ff 75 f4             	pushl  -0xc(%ebp)
801072f8:	e8 f8 ae ff ff       	call   801021f5 <iunlockput>
801072fd:	83 c4 10             	add    $0x10,%esp
   // cprintf("cwd %d , part %d \n",proc->cwd->inum,proc->cwd->part->number);
    return 0;
80107300:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107305:	c9                   	leave  
80107306:	c3                   	ret    

80107307 <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
80107307:	55                   	push   %ebp
80107308:	89 e5                	mov    %esp,%ebp
8010730a:	83 ec 08             	sub    $0x8,%esp
  return fork();
8010730d:	e8 66 df ff ff       	call   80105278 <fork>
}
80107312:	c9                   	leave  
80107313:	c3                   	ret    

80107314 <sys_exit>:

int
sys_exit(void)
{
80107314:	55                   	push   %ebp
80107315:	89 e5                	mov    %esp,%ebp
80107317:	83 ec 08             	sub    $0x8,%esp
  exit();
8010731a:	e8 ea e0 ff ff       	call   80105409 <exit>
  return 0;  // not reached
8010731f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107324:	c9                   	leave  
80107325:	c3                   	ret    

80107326 <sys_wait>:

int
sys_wait(void)
{
80107326:	55                   	push   %ebp
80107327:	89 e5                	mov    %esp,%ebp
80107329:	83 ec 08             	sub    $0x8,%esp
  return wait();
8010732c:	e8 3c e2 ff ff       	call   8010556d <wait>
}
80107331:	c9                   	leave  
80107332:	c3                   	ret    

80107333 <sys_kill>:

int
sys_kill(void)
{
80107333:	55                   	push   %ebp
80107334:	89 e5                	mov    %esp,%ebp
80107336:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
80107339:	83 ec 08             	sub    $0x8,%esp
8010733c:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010733f:	50                   	push   %eax
80107340:	6a 00                	push   $0x0
80107342:	e8 d1 ed ff ff       	call   80106118 <argint>
80107347:	83 c4 10             	add    $0x10,%esp
8010734a:	85 c0                	test   %eax,%eax
8010734c:	79 07                	jns    80107355 <sys_kill+0x22>
    return -1;
8010734e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107353:	eb 0f                	jmp    80107364 <sys_kill+0x31>
  return kill(pid);
80107355:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107358:	83 ec 0c             	sub    $0xc,%esp
8010735b:	50                   	push   %eax
8010735c:	e8 58 e6 ff ff       	call   801059b9 <kill>
80107361:	83 c4 10             	add    $0x10,%esp
}
80107364:	c9                   	leave  
80107365:	c3                   	ret    

80107366 <sys_getpid>:

int
sys_getpid(void)
{
80107366:	55                   	push   %ebp
80107367:	89 e5                	mov    %esp,%ebp
  return proc->pid;
80107369:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010736f:	8b 40 10             	mov    0x10(%eax),%eax
}
80107372:	5d                   	pop    %ebp
80107373:	c3                   	ret    

80107374 <sys_sbrk>:

int
sys_sbrk(void)
{
80107374:	55                   	push   %ebp
80107375:	89 e5                	mov    %esp,%ebp
80107377:	83 ec 18             	sub    $0x18,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
8010737a:	83 ec 08             	sub    $0x8,%esp
8010737d:	8d 45 f0             	lea    -0x10(%ebp),%eax
80107380:	50                   	push   %eax
80107381:	6a 00                	push   $0x0
80107383:	e8 90 ed ff ff       	call   80106118 <argint>
80107388:	83 c4 10             	add    $0x10,%esp
8010738b:	85 c0                	test   %eax,%eax
8010738d:	79 07                	jns    80107396 <sys_sbrk+0x22>
    return -1;
8010738f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107394:	eb 28                	jmp    801073be <sys_sbrk+0x4a>
  addr = proc->sz;
80107396:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010739c:	8b 00                	mov    (%eax),%eax
8010739e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
801073a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801073a4:	83 ec 0c             	sub    $0xc,%esp
801073a7:	50                   	push   %eax
801073a8:	e8 28 de ff ff       	call   801051d5 <growproc>
801073ad:	83 c4 10             	add    $0x10,%esp
801073b0:	85 c0                	test   %eax,%eax
801073b2:	79 07                	jns    801073bb <sys_sbrk+0x47>
    return -1;
801073b4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801073b9:	eb 03                	jmp    801073be <sys_sbrk+0x4a>
  return addr;
801073bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801073be:	c9                   	leave  
801073bf:	c3                   	ret    

801073c0 <sys_sleep>:

int
sys_sleep(void)
{
801073c0:	55                   	push   %ebp
801073c1:	89 e5                	mov    %esp,%ebp
801073c3:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;
  
  if(argint(0, &n) < 0)
801073c6:	83 ec 08             	sub    $0x8,%esp
801073c9:	8d 45 f0             	lea    -0x10(%ebp),%eax
801073cc:	50                   	push   %eax
801073cd:	6a 00                	push   $0x0
801073cf:	e8 44 ed ff ff       	call   80106118 <argint>
801073d4:	83 c4 10             	add    $0x10,%esp
801073d7:	85 c0                	test   %eax,%eax
801073d9:	79 07                	jns    801073e2 <sys_sleep+0x22>
    return -1;
801073db:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801073e0:	eb 77                	jmp    80107459 <sys_sleep+0x99>
  acquire(&tickslock);
801073e2:	83 ec 0c             	sub    $0xc,%esp
801073e5:	68 c0 5d 11 80       	push   $0x80115dc0
801073ea:	e8 a1 e7 ff ff       	call   80105b90 <acquire>
801073ef:	83 c4 10             	add    $0x10,%esp
  ticks0 = ticks;
801073f2:	a1 00 66 11 80       	mov    0x80116600,%eax
801073f7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
801073fa:	eb 39                	jmp    80107435 <sys_sleep+0x75>
    if(proc->killed){
801073fc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107402:	8b 40 24             	mov    0x24(%eax),%eax
80107405:	85 c0                	test   %eax,%eax
80107407:	74 17                	je     80107420 <sys_sleep+0x60>
      release(&tickslock);
80107409:	83 ec 0c             	sub    $0xc,%esp
8010740c:	68 c0 5d 11 80       	push   $0x80115dc0
80107411:	e8 e1 e7 ff ff       	call   80105bf7 <release>
80107416:	83 c4 10             	add    $0x10,%esp
      return -1;
80107419:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010741e:	eb 39                	jmp    80107459 <sys_sleep+0x99>
    }
    sleep(&ticks, &tickslock);
80107420:	83 ec 08             	sub    $0x8,%esp
80107423:	68 c0 5d 11 80       	push   $0x80115dc0
80107428:	68 00 66 11 80       	push   $0x80116600
8010742d:	e8 65 e4 ff ff       	call   80105897 <sleep>
80107432:	83 c4 10             	add    $0x10,%esp
  
  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
80107435:	a1 00 66 11 80       	mov    0x80116600,%eax
8010743a:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010743d:	8b 55 f0             	mov    -0x10(%ebp),%edx
80107440:	39 d0                	cmp    %edx,%eax
80107442:	72 b8                	jb     801073fc <sys_sleep+0x3c>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
80107444:	83 ec 0c             	sub    $0xc,%esp
80107447:	68 c0 5d 11 80       	push   $0x80115dc0
8010744c:	e8 a6 e7 ff ff       	call   80105bf7 <release>
80107451:	83 c4 10             	add    $0x10,%esp
  return 0;
80107454:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107459:	c9                   	leave  
8010745a:	c3                   	ret    

8010745b <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
8010745b:	55                   	push   %ebp
8010745c:	89 e5                	mov    %esp,%ebp
8010745e:	83 ec 18             	sub    $0x18,%esp
  uint xticks;
  
  acquire(&tickslock);
80107461:	83 ec 0c             	sub    $0xc,%esp
80107464:	68 c0 5d 11 80       	push   $0x80115dc0
80107469:	e8 22 e7 ff ff       	call   80105b90 <acquire>
8010746e:	83 c4 10             	add    $0x10,%esp
  xticks = ticks;
80107471:	a1 00 66 11 80       	mov    0x80116600,%eax
80107476:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
80107479:	83 ec 0c             	sub    $0xc,%esp
8010747c:	68 c0 5d 11 80       	push   $0x80115dc0
80107481:	e8 71 e7 ff ff       	call   80105bf7 <release>
80107486:	83 c4 10             	add    $0x10,%esp
  return xticks;
80107489:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010748c:	c9                   	leave  
8010748d:	c3                   	ret    

8010748e <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
8010748e:	55                   	push   %ebp
8010748f:	89 e5                	mov    %esp,%ebp
80107491:	83 ec 08             	sub    $0x8,%esp
80107494:	8b 55 08             	mov    0x8(%ebp),%edx
80107497:	8b 45 0c             	mov    0xc(%ebp),%eax
8010749a:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
8010749e:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801074a1:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801074a5:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801074a9:	ee                   	out    %al,(%dx)
}
801074aa:	90                   	nop
801074ab:	c9                   	leave  
801074ac:	c3                   	ret    

801074ad <timerinit>:
#define TIMER_RATEGEN   0x04    // mode 2, rate generator
#define TIMER_16BIT     0x30    // r/w counter 16 bits, LSB first

void
timerinit(void)
{
801074ad:	55                   	push   %ebp
801074ae:	89 e5                	mov    %esp,%ebp
801074b0:	83 ec 08             	sub    $0x8,%esp
  // Interrupt 100 times/sec.
  outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
801074b3:	6a 34                	push   $0x34
801074b5:	6a 43                	push   $0x43
801074b7:	e8 d2 ff ff ff       	call   8010748e <outb>
801074bc:	83 c4 08             	add    $0x8,%esp
  outb(IO_TIMER1, TIMER_DIV(100) % 256);
801074bf:	68 9c 00 00 00       	push   $0x9c
801074c4:	6a 40                	push   $0x40
801074c6:	e8 c3 ff ff ff       	call   8010748e <outb>
801074cb:	83 c4 08             	add    $0x8,%esp
  outb(IO_TIMER1, TIMER_DIV(100) / 256);
801074ce:	6a 2e                	push   $0x2e
801074d0:	6a 40                	push   $0x40
801074d2:	e8 b7 ff ff ff       	call   8010748e <outb>
801074d7:	83 c4 08             	add    $0x8,%esp
  picenable(IRQ_TIMER);
801074da:	83 ec 0c             	sub    $0xc,%esp
801074dd:	6a 00                	push   $0x0
801074df:	e8 88 d5 ff ff       	call   80104a6c <picenable>
801074e4:	83 c4 10             	add    $0x10,%esp
}
801074e7:	90                   	nop
801074e8:	c9                   	leave  
801074e9:	c3                   	ret    

801074ea <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
801074ea:	1e                   	push   %ds
  pushl %es
801074eb:	06                   	push   %es
  pushl %fs
801074ec:	0f a0                	push   %fs
  pushl %gs
801074ee:	0f a8                	push   %gs
  pushal
801074f0:	60                   	pusha  
  
  # Set up data and per-cpu segments.
  movw $(SEG_KDATA<<3), %ax
801074f1:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
801074f5:	8e d8                	mov    %eax,%ds
  movw %ax, %es
801074f7:	8e c0                	mov    %eax,%es
  movw $(SEG_KCPU<<3), %ax
801074f9:	66 b8 18 00          	mov    $0x18,%ax
  movw %ax, %fs
801074fd:	8e e0                	mov    %eax,%fs
  movw %ax, %gs
801074ff:	8e e8                	mov    %eax,%gs

  # Call trap(tf), where tf=%esp
  pushl %esp
80107501:	54                   	push   %esp
  call trap
80107502:	e8 d7 01 00 00       	call   801076de <trap>
  addl $4, %esp
80107507:	83 c4 04             	add    $0x4,%esp

8010750a <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
8010750a:	61                   	popa   
  popl %gs
8010750b:	0f a9                	pop    %gs
  popl %fs
8010750d:	0f a1                	pop    %fs
  popl %es
8010750f:	07                   	pop    %es
  popl %ds
80107510:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80107511:	83 c4 08             	add    $0x8,%esp
  iret
80107514:	cf                   	iret   

80107515 <lidt>:

struct gatedesc;

static inline void
lidt(struct gatedesc *p, int size)
{
80107515:	55                   	push   %ebp
80107516:	89 e5                	mov    %esp,%ebp
80107518:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
8010751b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010751e:	83 e8 01             	sub    $0x1,%eax
80107521:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80107525:	8b 45 08             	mov    0x8(%ebp),%eax
80107528:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
8010752c:	8b 45 08             	mov    0x8(%ebp),%eax
8010752f:	c1 e8 10             	shr    $0x10,%eax
80107532:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lidt (%0)" : : "r" (pd));
80107536:	8d 45 fa             	lea    -0x6(%ebp),%eax
80107539:	0f 01 18             	lidtl  (%eax)
}
8010753c:	90                   	nop
8010753d:	c9                   	leave  
8010753e:	c3                   	ret    

8010753f <rcr2>:
  return result;
}

static inline uint
rcr2(void)
{
8010753f:	55                   	push   %ebp
80107540:	89 e5                	mov    %esp,%ebp
80107542:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80107545:	0f 20 d0             	mov    %cr2,%eax
80107548:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
8010754b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010754e:	c9                   	leave  
8010754f:	c3                   	ret    

80107550 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80107550:	55                   	push   %ebp
80107551:	89 e5                	mov    %esp,%ebp
80107553:	83 ec 18             	sub    $0x18,%esp
  int i;

  for(i = 0; i < 256; i++)
80107556:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010755d:	e9 c3 00 00 00       	jmp    80107625 <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80107562:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107565:	8b 04 85 9c c0 10 80 	mov    -0x7fef3f64(,%eax,4),%eax
8010756c:	89 c2                	mov    %eax,%edx
8010756e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107571:	66 89 14 c5 00 5e 11 	mov    %dx,-0x7feea200(,%eax,8)
80107578:	80 
80107579:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010757c:	66 c7 04 c5 02 5e 11 	movw   $0x8,-0x7feea1fe(,%eax,8)
80107583:	80 08 00 
80107586:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107589:	0f b6 14 c5 04 5e 11 	movzbl -0x7feea1fc(,%eax,8),%edx
80107590:	80 
80107591:	83 e2 e0             	and    $0xffffffe0,%edx
80107594:	88 14 c5 04 5e 11 80 	mov    %dl,-0x7feea1fc(,%eax,8)
8010759b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010759e:	0f b6 14 c5 04 5e 11 	movzbl -0x7feea1fc(,%eax,8),%edx
801075a5:	80 
801075a6:	83 e2 1f             	and    $0x1f,%edx
801075a9:	88 14 c5 04 5e 11 80 	mov    %dl,-0x7feea1fc(,%eax,8)
801075b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075b3:	0f b6 14 c5 05 5e 11 	movzbl -0x7feea1fb(,%eax,8),%edx
801075ba:	80 
801075bb:	83 e2 f0             	and    $0xfffffff0,%edx
801075be:	83 ca 0e             	or     $0xe,%edx
801075c1:	88 14 c5 05 5e 11 80 	mov    %dl,-0x7feea1fb(,%eax,8)
801075c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075cb:	0f b6 14 c5 05 5e 11 	movzbl -0x7feea1fb(,%eax,8),%edx
801075d2:	80 
801075d3:	83 e2 ef             	and    $0xffffffef,%edx
801075d6:	88 14 c5 05 5e 11 80 	mov    %dl,-0x7feea1fb(,%eax,8)
801075dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075e0:	0f b6 14 c5 05 5e 11 	movzbl -0x7feea1fb(,%eax,8),%edx
801075e7:	80 
801075e8:	83 e2 9f             	and    $0xffffff9f,%edx
801075eb:	88 14 c5 05 5e 11 80 	mov    %dl,-0x7feea1fb(,%eax,8)
801075f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075f5:	0f b6 14 c5 05 5e 11 	movzbl -0x7feea1fb(,%eax,8),%edx
801075fc:	80 
801075fd:	83 ca 80             	or     $0xffffff80,%edx
80107600:	88 14 c5 05 5e 11 80 	mov    %dl,-0x7feea1fb(,%eax,8)
80107607:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010760a:	8b 04 85 9c c0 10 80 	mov    -0x7fef3f64(,%eax,4),%eax
80107611:	c1 e8 10             	shr    $0x10,%eax
80107614:	89 c2                	mov    %eax,%edx
80107616:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107619:	66 89 14 c5 06 5e 11 	mov    %dx,-0x7feea1fa(,%eax,8)
80107620:	80 
void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
80107621:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107625:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
8010762c:	0f 8e 30 ff ff ff    	jle    80107562 <tvinit+0x12>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80107632:	a1 9c c1 10 80       	mov    0x8010c19c,%eax
80107637:	66 a3 00 60 11 80    	mov    %ax,0x80116000
8010763d:	66 c7 05 02 60 11 80 	movw   $0x8,0x80116002
80107644:	08 00 
80107646:	0f b6 05 04 60 11 80 	movzbl 0x80116004,%eax
8010764d:	83 e0 e0             	and    $0xffffffe0,%eax
80107650:	a2 04 60 11 80       	mov    %al,0x80116004
80107655:	0f b6 05 04 60 11 80 	movzbl 0x80116004,%eax
8010765c:	83 e0 1f             	and    $0x1f,%eax
8010765f:	a2 04 60 11 80       	mov    %al,0x80116004
80107664:	0f b6 05 05 60 11 80 	movzbl 0x80116005,%eax
8010766b:	83 c8 0f             	or     $0xf,%eax
8010766e:	a2 05 60 11 80       	mov    %al,0x80116005
80107673:	0f b6 05 05 60 11 80 	movzbl 0x80116005,%eax
8010767a:	83 e0 ef             	and    $0xffffffef,%eax
8010767d:	a2 05 60 11 80       	mov    %al,0x80116005
80107682:	0f b6 05 05 60 11 80 	movzbl 0x80116005,%eax
80107689:	83 c8 60             	or     $0x60,%eax
8010768c:	a2 05 60 11 80       	mov    %al,0x80116005
80107691:	0f b6 05 05 60 11 80 	movzbl 0x80116005,%eax
80107698:	83 c8 80             	or     $0xffffff80,%eax
8010769b:	a2 05 60 11 80       	mov    %al,0x80116005
801076a0:	a1 9c c1 10 80       	mov    0x8010c19c,%eax
801076a5:	c1 e8 10             	shr    $0x10,%eax
801076a8:	66 a3 06 60 11 80    	mov    %ax,0x80116006
  
  initlock(&tickslock, "time");
801076ae:	83 ec 08             	sub    $0x8,%esp
801076b1:	68 90 99 10 80       	push   $0x80109990
801076b6:	68 c0 5d 11 80       	push   $0x80115dc0
801076bb:	e8 ae e4 ff ff       	call   80105b6e <initlock>
801076c0:	83 c4 10             	add    $0x10,%esp
}
801076c3:	90                   	nop
801076c4:	c9                   	leave  
801076c5:	c3                   	ret    

801076c6 <idtinit>:

void
idtinit(void)
{
801076c6:	55                   	push   %ebp
801076c7:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
801076c9:	68 00 08 00 00       	push   $0x800
801076ce:	68 00 5e 11 80       	push   $0x80115e00
801076d3:	e8 3d fe ff ff       	call   80107515 <lidt>
801076d8:	83 c4 08             	add    $0x8,%esp
}
801076db:	90                   	nop
801076dc:	c9                   	leave  
801076dd:	c3                   	ret    

801076de <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
801076de:	55                   	push   %ebp
801076df:	89 e5                	mov    %esp,%ebp
801076e1:	57                   	push   %edi
801076e2:	56                   	push   %esi
801076e3:	53                   	push   %ebx
801076e4:	83 ec 1c             	sub    $0x1c,%esp
  if(tf->trapno == T_SYSCALL){
801076e7:	8b 45 08             	mov    0x8(%ebp),%eax
801076ea:	8b 40 30             	mov    0x30(%eax),%eax
801076ed:	83 f8 40             	cmp    $0x40,%eax
801076f0:	75 3e                	jne    80107730 <trap+0x52>
    if(proc->killed)
801076f2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801076f8:	8b 40 24             	mov    0x24(%eax),%eax
801076fb:	85 c0                	test   %eax,%eax
801076fd:	74 05                	je     80107704 <trap+0x26>
      exit();
801076ff:	e8 05 dd ff ff       	call   80105409 <exit>
    proc->tf = tf;
80107704:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010770a:	8b 55 08             	mov    0x8(%ebp),%edx
8010770d:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
80107710:	e8 b9 ea ff ff       	call   801061ce <syscall>
    if(proc->killed)
80107715:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010771b:	8b 40 24             	mov    0x24(%eax),%eax
8010771e:	85 c0                	test   %eax,%eax
80107720:	0f 84 1b 02 00 00    	je     80107941 <trap+0x263>
      exit();
80107726:	e8 de dc ff ff       	call   80105409 <exit>
    return;
8010772b:	e9 11 02 00 00       	jmp    80107941 <trap+0x263>
  }

  switch(tf->trapno){
80107730:	8b 45 08             	mov    0x8(%ebp),%eax
80107733:	8b 40 30             	mov    0x30(%eax),%eax
80107736:	83 e8 20             	sub    $0x20,%eax
80107739:	83 f8 1f             	cmp    $0x1f,%eax
8010773c:	0f 87 c0 00 00 00    	ja     80107802 <trap+0x124>
80107742:	8b 04 85 38 9a 10 80 	mov    -0x7fef65c8(,%eax,4),%eax
80107749:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpu->id == 0){
8010774b:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107751:	0f b6 00             	movzbl (%eax),%eax
80107754:	84 c0                	test   %al,%al
80107756:	75 3d                	jne    80107795 <trap+0xb7>
      acquire(&tickslock);
80107758:	83 ec 0c             	sub    $0xc,%esp
8010775b:	68 c0 5d 11 80       	push   $0x80115dc0
80107760:	e8 2b e4 ff ff       	call   80105b90 <acquire>
80107765:	83 c4 10             	add    $0x10,%esp
      ticks++;
80107768:	a1 00 66 11 80       	mov    0x80116600,%eax
8010776d:	83 c0 01             	add    $0x1,%eax
80107770:	a3 00 66 11 80       	mov    %eax,0x80116600
      wakeup(&ticks);
80107775:	83 ec 0c             	sub    $0xc,%esp
80107778:	68 00 66 11 80       	push   $0x80116600
8010777d:	e8 00 e2 ff ff       	call   80105982 <wakeup>
80107782:	83 c4 10             	add    $0x10,%esp
      release(&tickslock);
80107785:	83 ec 0c             	sub    $0xc,%esp
80107788:	68 c0 5d 11 80       	push   $0x80115dc0
8010778d:	e8 65 e4 ff ff       	call   80105bf7 <release>
80107792:	83 c4 10             	add    $0x10,%esp
    }
    lapiceoi();
80107795:	e8 a0 c0 ff ff       	call   8010383a <lapiceoi>
    break;
8010779a:	e9 1c 01 00 00       	jmp    801078bb <trap+0x1dd>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
8010779f:	e8 a9 b8 ff ff       	call   8010304d <ideintr>
    lapiceoi();
801077a4:	e8 91 c0 ff ff       	call   8010383a <lapiceoi>
    break;
801077a9:	e9 0d 01 00 00       	jmp    801078bb <trap+0x1dd>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
801077ae:	e8 89 be ff ff       	call   8010363c <kbdintr>
    lapiceoi();
801077b3:	e8 82 c0 ff ff       	call   8010383a <lapiceoi>
    break;
801077b8:	e9 fe 00 00 00       	jmp    801078bb <trap+0x1dd>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
801077bd:	e8 60 03 00 00       	call   80107b22 <uartintr>
    lapiceoi();
801077c2:	e8 73 c0 ff ff       	call   8010383a <lapiceoi>
    break;
801077c7:	e9 ef 00 00 00       	jmp    801078bb <trap+0x1dd>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801077cc:	8b 45 08             	mov    0x8(%ebp),%eax
801077cf:	8b 48 38             	mov    0x38(%eax),%ecx
            cpu->id, tf->cs, tf->eip);
801077d2:	8b 45 08             	mov    0x8(%ebp),%eax
801077d5:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801077d9:	0f b7 d0             	movzwl %ax,%edx
            cpu->id, tf->cs, tf->eip);
801077dc:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801077e2:	0f b6 00             	movzbl (%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801077e5:	0f b6 c0             	movzbl %al,%eax
801077e8:	51                   	push   %ecx
801077e9:	52                   	push   %edx
801077ea:	50                   	push   %eax
801077eb:	68 98 99 10 80       	push   $0x80109998
801077f0:	e8 d1 8b ff ff       	call   801003c6 <cprintf>
801077f5:	83 c4 10             	add    $0x10,%esp
            cpu->id, tf->cs, tf->eip);
    lapiceoi();
801077f8:	e8 3d c0 ff ff       	call   8010383a <lapiceoi>
    break;
801077fd:	e9 b9 00 00 00       	jmp    801078bb <trap+0x1dd>
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
80107802:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107808:	85 c0                	test   %eax,%eax
8010780a:	74 11                	je     8010781d <trap+0x13f>
8010780c:	8b 45 08             	mov    0x8(%ebp),%eax
8010780f:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80107813:	0f b7 c0             	movzwl %ax,%eax
80107816:	83 e0 03             	and    $0x3,%eax
80107819:	85 c0                	test   %eax,%eax
8010781b:	75 40                	jne    8010785d <trap+0x17f>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
8010781d:	e8 1d fd ff ff       	call   8010753f <rcr2>
80107822:	89 c3                	mov    %eax,%ebx
80107824:	8b 45 08             	mov    0x8(%ebp),%eax
80107827:	8b 48 38             	mov    0x38(%eax),%ecx
              tf->trapno, cpu->id, tf->eip, rcr2());
8010782a:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107830:	0f b6 00             	movzbl (%eax),%eax
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80107833:	0f b6 d0             	movzbl %al,%edx
80107836:	8b 45 08             	mov    0x8(%ebp),%eax
80107839:	8b 40 30             	mov    0x30(%eax),%eax
8010783c:	83 ec 0c             	sub    $0xc,%esp
8010783f:	53                   	push   %ebx
80107840:	51                   	push   %ecx
80107841:	52                   	push   %edx
80107842:	50                   	push   %eax
80107843:	68 bc 99 10 80       	push   $0x801099bc
80107848:	e8 79 8b ff ff       	call   801003c6 <cprintf>
8010784d:	83 c4 20             	add    $0x20,%esp
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
80107850:	83 ec 0c             	sub    $0xc,%esp
80107853:	68 ee 99 10 80       	push   $0x801099ee
80107858:	e8 09 8d ff ff       	call   80100566 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
8010785d:	e8 dd fc ff ff       	call   8010753f <rcr2>
80107862:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80107865:	8b 45 08             	mov    0x8(%ebp),%eax
80107868:	8b 70 38             	mov    0x38(%eax),%esi
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
8010786b:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107871:	0f b6 00             	movzbl (%eax),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80107874:	0f b6 d8             	movzbl %al,%ebx
80107877:	8b 45 08             	mov    0x8(%ebp),%eax
8010787a:	8b 48 34             	mov    0x34(%eax),%ecx
8010787d:	8b 45 08             	mov    0x8(%ebp),%eax
80107880:	8b 50 30             	mov    0x30(%eax),%edx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80107883:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107889:	8d 78 6c             	lea    0x6c(%eax),%edi
8010788c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80107892:	8b 40 10             	mov    0x10(%eax),%eax
80107895:	ff 75 e4             	pushl  -0x1c(%ebp)
80107898:	56                   	push   %esi
80107899:	53                   	push   %ebx
8010789a:	51                   	push   %ecx
8010789b:	52                   	push   %edx
8010789c:	57                   	push   %edi
8010789d:	50                   	push   %eax
8010789e:	68 f4 99 10 80       	push   $0x801099f4
801078a3:	e8 1e 8b ff ff       	call   801003c6 <cprintf>
801078a8:	83 c4 20             	add    $0x20,%esp
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
            rcr2());
    proc->killed = 1;
801078ab:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801078b1:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
801078b8:	eb 01                	jmp    801078bb <trap+0x1dd>
    ideintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
801078ba:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running 
  // until it gets to the regular system call return.)
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
801078bb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801078c1:	85 c0                	test   %eax,%eax
801078c3:	74 24                	je     801078e9 <trap+0x20b>
801078c5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801078cb:	8b 40 24             	mov    0x24(%eax),%eax
801078ce:	85 c0                	test   %eax,%eax
801078d0:	74 17                	je     801078e9 <trap+0x20b>
801078d2:	8b 45 08             	mov    0x8(%ebp),%eax
801078d5:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
801078d9:	0f b7 c0             	movzwl %ax,%eax
801078dc:	83 e0 03             	and    $0x3,%eax
801078df:	83 f8 03             	cmp    $0x3,%eax
801078e2:	75 05                	jne    801078e9 <trap+0x20b>
    exit();
801078e4:	e8 20 db ff ff       	call   80105409 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(proc && proc->state == RUNNING && tf->trapno == T_IRQ0+IRQ_TIMER)
801078e9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801078ef:	85 c0                	test   %eax,%eax
801078f1:	74 1e                	je     80107911 <trap+0x233>
801078f3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801078f9:	8b 40 0c             	mov    0xc(%eax),%eax
801078fc:	83 f8 04             	cmp    $0x4,%eax
801078ff:	75 10                	jne    80107911 <trap+0x233>
80107901:	8b 45 08             	mov    0x8(%ebp),%eax
80107904:	8b 40 30             	mov    0x30(%eax),%eax
80107907:	83 f8 20             	cmp    $0x20,%eax
8010790a:	75 05                	jne    80107911 <trap+0x233>
    yield();
8010790c:	e8 e1 de ff ff       	call   801057f2 <yield>

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80107911:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107917:	85 c0                	test   %eax,%eax
80107919:	74 27                	je     80107942 <trap+0x264>
8010791b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107921:	8b 40 24             	mov    0x24(%eax),%eax
80107924:	85 c0                	test   %eax,%eax
80107926:	74 1a                	je     80107942 <trap+0x264>
80107928:	8b 45 08             	mov    0x8(%ebp),%eax
8010792b:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
8010792f:	0f b7 c0             	movzwl %ax,%eax
80107932:	83 e0 03             	and    $0x3,%eax
80107935:	83 f8 03             	cmp    $0x3,%eax
80107938:	75 08                	jne    80107942 <trap+0x264>
    exit();
8010793a:	e8 ca da ff ff       	call   80105409 <exit>
8010793f:	eb 01                	jmp    80107942 <trap+0x264>
      exit();
    proc->tf = tf;
    syscall();
    if(proc->killed)
      exit();
    return;
80107941:	90                   	nop
    yield();

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
    exit();
}
80107942:	8d 65 f4             	lea    -0xc(%ebp),%esp
80107945:	5b                   	pop    %ebx
80107946:	5e                   	pop    %esi
80107947:	5f                   	pop    %edi
80107948:	5d                   	pop    %ebp
80107949:	c3                   	ret    

8010794a <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
8010794a:	55                   	push   %ebp
8010794b:	89 e5                	mov    %esp,%ebp
8010794d:	83 ec 14             	sub    $0x14,%esp
80107950:	8b 45 08             	mov    0x8(%ebp),%eax
80107953:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80107957:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
8010795b:	89 c2                	mov    %eax,%edx
8010795d:	ec                   	in     (%dx),%al
8010795e:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80107961:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80107965:	c9                   	leave  
80107966:	c3                   	ret    

80107967 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80107967:	55                   	push   %ebp
80107968:	89 e5                	mov    %esp,%ebp
8010796a:	83 ec 08             	sub    $0x8,%esp
8010796d:	8b 55 08             	mov    0x8(%ebp),%edx
80107970:	8b 45 0c             	mov    0xc(%ebp),%eax
80107973:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80107977:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010797a:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
8010797e:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80107982:	ee                   	out    %al,(%dx)
}
80107983:	90                   	nop
80107984:	c9                   	leave  
80107985:	c3                   	ret    

80107986 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
80107986:	55                   	push   %ebp
80107987:	89 e5                	mov    %esp,%ebp
80107989:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
8010798c:	6a 00                	push   $0x0
8010798e:	68 fa 03 00 00       	push   $0x3fa
80107993:	e8 cf ff ff ff       	call   80107967 <outb>
80107998:	83 c4 08             	add    $0x8,%esp
  
  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
8010799b:	68 80 00 00 00       	push   $0x80
801079a0:	68 fb 03 00 00       	push   $0x3fb
801079a5:	e8 bd ff ff ff       	call   80107967 <outb>
801079aa:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
801079ad:	6a 0c                	push   $0xc
801079af:	68 f8 03 00 00       	push   $0x3f8
801079b4:	e8 ae ff ff ff       	call   80107967 <outb>
801079b9:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
801079bc:	6a 00                	push   $0x0
801079be:	68 f9 03 00 00       	push   $0x3f9
801079c3:	e8 9f ff ff ff       	call   80107967 <outb>
801079c8:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
801079cb:	6a 03                	push   $0x3
801079cd:	68 fb 03 00 00       	push   $0x3fb
801079d2:	e8 90 ff ff ff       	call   80107967 <outb>
801079d7:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
801079da:	6a 00                	push   $0x0
801079dc:	68 fc 03 00 00       	push   $0x3fc
801079e1:	e8 81 ff ff ff       	call   80107967 <outb>
801079e6:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
801079e9:	6a 01                	push   $0x1
801079eb:	68 f9 03 00 00       	push   $0x3f9
801079f0:	e8 72 ff ff ff       	call   80107967 <outb>
801079f5:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
801079f8:	68 fd 03 00 00       	push   $0x3fd
801079fd:	e8 48 ff ff ff       	call   8010794a <inb>
80107a02:	83 c4 04             	add    $0x4,%esp
80107a05:	3c ff                	cmp    $0xff,%al
80107a07:	74 6e                	je     80107a77 <uartinit+0xf1>
    return;
  uart = 1;
80107a09:	c7 05 4c c6 10 80 01 	movl   $0x1,0x8010c64c
80107a10:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80107a13:	68 fa 03 00 00       	push   $0x3fa
80107a18:	e8 2d ff ff ff       	call   8010794a <inb>
80107a1d:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
80107a20:	68 f8 03 00 00       	push   $0x3f8
80107a25:	e8 20 ff ff ff       	call   8010794a <inb>
80107a2a:	83 c4 04             	add    $0x4,%esp
  picenable(IRQ_COM1);
80107a2d:	83 ec 0c             	sub    $0xc,%esp
80107a30:	6a 04                	push   $0x4
80107a32:	e8 35 d0 ff ff       	call   80104a6c <picenable>
80107a37:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_COM1, 0);
80107a3a:	83 ec 08             	sub    $0x8,%esp
80107a3d:	6a 00                	push   $0x0
80107a3f:	6a 04                	push   $0x4
80107a41:	e8 a9 b8 ff ff       	call   801032ef <ioapicenable>
80107a46:	83 c4 10             	add    $0x10,%esp
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80107a49:	c7 45 f4 b8 9a 10 80 	movl   $0x80109ab8,-0xc(%ebp)
80107a50:	eb 19                	jmp    80107a6b <uartinit+0xe5>
    uartputc(*p);
80107a52:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a55:	0f b6 00             	movzbl (%eax),%eax
80107a58:	0f be c0             	movsbl %al,%eax
80107a5b:	83 ec 0c             	sub    $0xc,%esp
80107a5e:	50                   	push   %eax
80107a5f:	e8 16 00 00 00       	call   80107a7a <uartputc>
80107a64:	83 c4 10             	add    $0x10,%esp
  inb(COM1+0);
  picenable(IRQ_COM1);
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80107a67:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107a6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a6e:	0f b6 00             	movzbl (%eax),%eax
80107a71:	84 c0                	test   %al,%al
80107a73:	75 dd                	jne    80107a52 <uartinit+0xcc>
80107a75:	eb 01                	jmp    80107a78 <uartinit+0xf2>
  outb(COM1+4, 0);
  outb(COM1+1, 0x01);    // Enable receive interrupts.

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
    return;
80107a77:	90                   	nop
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
    uartputc(*p);
}
80107a78:	c9                   	leave  
80107a79:	c3                   	ret    

80107a7a <uartputc>:

void
uartputc(int c)
{
80107a7a:	55                   	push   %ebp
80107a7b:	89 e5                	mov    %esp,%ebp
80107a7d:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
80107a80:	a1 4c c6 10 80       	mov    0x8010c64c,%eax
80107a85:	85 c0                	test   %eax,%eax
80107a87:	74 53                	je     80107adc <uartputc+0x62>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80107a89:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107a90:	eb 11                	jmp    80107aa3 <uartputc+0x29>
    microdelay(10);
80107a92:	83 ec 0c             	sub    $0xc,%esp
80107a95:	6a 0a                	push   $0xa
80107a97:	e8 b9 bd ff ff       	call   80103855 <microdelay>
80107a9c:	83 c4 10             	add    $0x10,%esp
{
  int i;

  if(!uart)
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80107a9f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107aa3:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80107aa7:	7f 1a                	jg     80107ac3 <uartputc+0x49>
80107aa9:	83 ec 0c             	sub    $0xc,%esp
80107aac:	68 fd 03 00 00       	push   $0x3fd
80107ab1:	e8 94 fe ff ff       	call   8010794a <inb>
80107ab6:	83 c4 10             	add    $0x10,%esp
80107ab9:	0f b6 c0             	movzbl %al,%eax
80107abc:	83 e0 20             	and    $0x20,%eax
80107abf:	85 c0                	test   %eax,%eax
80107ac1:	74 cf                	je     80107a92 <uartputc+0x18>
    microdelay(10);
  outb(COM1+0, c);
80107ac3:	8b 45 08             	mov    0x8(%ebp),%eax
80107ac6:	0f b6 c0             	movzbl %al,%eax
80107ac9:	83 ec 08             	sub    $0x8,%esp
80107acc:	50                   	push   %eax
80107acd:	68 f8 03 00 00       	push   $0x3f8
80107ad2:	e8 90 fe ff ff       	call   80107967 <outb>
80107ad7:	83 c4 10             	add    $0x10,%esp
80107ada:	eb 01                	jmp    80107add <uartputc+0x63>
uartputc(int c)
{
  int i;

  if(!uart)
    return;
80107adc:	90                   	nop
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
    microdelay(10);
  outb(COM1+0, c);
}
80107add:	c9                   	leave  
80107ade:	c3                   	ret    

80107adf <uartgetc>:

static int
uartgetc(void)
{
80107adf:	55                   	push   %ebp
80107ae0:	89 e5                	mov    %esp,%ebp
  if(!uart)
80107ae2:	a1 4c c6 10 80       	mov    0x8010c64c,%eax
80107ae7:	85 c0                	test   %eax,%eax
80107ae9:	75 07                	jne    80107af2 <uartgetc+0x13>
    return -1;
80107aeb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107af0:	eb 2e                	jmp    80107b20 <uartgetc+0x41>
  if(!(inb(COM1+5) & 0x01))
80107af2:	68 fd 03 00 00       	push   $0x3fd
80107af7:	e8 4e fe ff ff       	call   8010794a <inb>
80107afc:	83 c4 04             	add    $0x4,%esp
80107aff:	0f b6 c0             	movzbl %al,%eax
80107b02:	83 e0 01             	and    $0x1,%eax
80107b05:	85 c0                	test   %eax,%eax
80107b07:	75 07                	jne    80107b10 <uartgetc+0x31>
    return -1;
80107b09:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107b0e:	eb 10                	jmp    80107b20 <uartgetc+0x41>
  return inb(COM1+0);
80107b10:	68 f8 03 00 00       	push   $0x3f8
80107b15:	e8 30 fe ff ff       	call   8010794a <inb>
80107b1a:	83 c4 04             	add    $0x4,%esp
80107b1d:	0f b6 c0             	movzbl %al,%eax
}
80107b20:	c9                   	leave  
80107b21:	c3                   	ret    

80107b22 <uartintr>:

void
uartintr(void)
{
80107b22:	55                   	push   %ebp
80107b23:	89 e5                	mov    %esp,%ebp
80107b25:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
80107b28:	83 ec 0c             	sub    $0xc,%esp
80107b2b:	68 df 7a 10 80       	push   $0x80107adf
80107b30:	e8 c4 8c ff ff       	call   801007f9 <consoleintr>
80107b35:	83 c4 10             	add    $0x10,%esp
}
80107b38:	90                   	nop
80107b39:	c9                   	leave  
80107b3a:	c3                   	ret    

80107b3b <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80107b3b:	6a 00                	push   $0x0
  pushl $0
80107b3d:	6a 00                	push   $0x0
  jmp alltraps
80107b3f:	e9 a6 f9 ff ff       	jmp    801074ea <alltraps>

80107b44 <vector1>:
.globl vector1
vector1:
  pushl $0
80107b44:	6a 00                	push   $0x0
  pushl $1
80107b46:	6a 01                	push   $0x1
  jmp alltraps
80107b48:	e9 9d f9 ff ff       	jmp    801074ea <alltraps>

80107b4d <vector2>:
.globl vector2
vector2:
  pushl $0
80107b4d:	6a 00                	push   $0x0
  pushl $2
80107b4f:	6a 02                	push   $0x2
  jmp alltraps
80107b51:	e9 94 f9 ff ff       	jmp    801074ea <alltraps>

80107b56 <vector3>:
.globl vector3
vector3:
  pushl $0
80107b56:	6a 00                	push   $0x0
  pushl $3
80107b58:	6a 03                	push   $0x3
  jmp alltraps
80107b5a:	e9 8b f9 ff ff       	jmp    801074ea <alltraps>

80107b5f <vector4>:
.globl vector4
vector4:
  pushl $0
80107b5f:	6a 00                	push   $0x0
  pushl $4
80107b61:	6a 04                	push   $0x4
  jmp alltraps
80107b63:	e9 82 f9 ff ff       	jmp    801074ea <alltraps>

80107b68 <vector5>:
.globl vector5
vector5:
  pushl $0
80107b68:	6a 00                	push   $0x0
  pushl $5
80107b6a:	6a 05                	push   $0x5
  jmp alltraps
80107b6c:	e9 79 f9 ff ff       	jmp    801074ea <alltraps>

80107b71 <vector6>:
.globl vector6
vector6:
  pushl $0
80107b71:	6a 00                	push   $0x0
  pushl $6
80107b73:	6a 06                	push   $0x6
  jmp alltraps
80107b75:	e9 70 f9 ff ff       	jmp    801074ea <alltraps>

80107b7a <vector7>:
.globl vector7
vector7:
  pushl $0
80107b7a:	6a 00                	push   $0x0
  pushl $7
80107b7c:	6a 07                	push   $0x7
  jmp alltraps
80107b7e:	e9 67 f9 ff ff       	jmp    801074ea <alltraps>

80107b83 <vector8>:
.globl vector8
vector8:
  pushl $8
80107b83:	6a 08                	push   $0x8
  jmp alltraps
80107b85:	e9 60 f9 ff ff       	jmp    801074ea <alltraps>

80107b8a <vector9>:
.globl vector9
vector9:
  pushl $0
80107b8a:	6a 00                	push   $0x0
  pushl $9
80107b8c:	6a 09                	push   $0x9
  jmp alltraps
80107b8e:	e9 57 f9 ff ff       	jmp    801074ea <alltraps>

80107b93 <vector10>:
.globl vector10
vector10:
  pushl $10
80107b93:	6a 0a                	push   $0xa
  jmp alltraps
80107b95:	e9 50 f9 ff ff       	jmp    801074ea <alltraps>

80107b9a <vector11>:
.globl vector11
vector11:
  pushl $11
80107b9a:	6a 0b                	push   $0xb
  jmp alltraps
80107b9c:	e9 49 f9 ff ff       	jmp    801074ea <alltraps>

80107ba1 <vector12>:
.globl vector12
vector12:
  pushl $12
80107ba1:	6a 0c                	push   $0xc
  jmp alltraps
80107ba3:	e9 42 f9 ff ff       	jmp    801074ea <alltraps>

80107ba8 <vector13>:
.globl vector13
vector13:
  pushl $13
80107ba8:	6a 0d                	push   $0xd
  jmp alltraps
80107baa:	e9 3b f9 ff ff       	jmp    801074ea <alltraps>

80107baf <vector14>:
.globl vector14
vector14:
  pushl $14
80107baf:	6a 0e                	push   $0xe
  jmp alltraps
80107bb1:	e9 34 f9 ff ff       	jmp    801074ea <alltraps>

80107bb6 <vector15>:
.globl vector15
vector15:
  pushl $0
80107bb6:	6a 00                	push   $0x0
  pushl $15
80107bb8:	6a 0f                	push   $0xf
  jmp alltraps
80107bba:	e9 2b f9 ff ff       	jmp    801074ea <alltraps>

80107bbf <vector16>:
.globl vector16
vector16:
  pushl $0
80107bbf:	6a 00                	push   $0x0
  pushl $16
80107bc1:	6a 10                	push   $0x10
  jmp alltraps
80107bc3:	e9 22 f9 ff ff       	jmp    801074ea <alltraps>

80107bc8 <vector17>:
.globl vector17
vector17:
  pushl $17
80107bc8:	6a 11                	push   $0x11
  jmp alltraps
80107bca:	e9 1b f9 ff ff       	jmp    801074ea <alltraps>

80107bcf <vector18>:
.globl vector18
vector18:
  pushl $0
80107bcf:	6a 00                	push   $0x0
  pushl $18
80107bd1:	6a 12                	push   $0x12
  jmp alltraps
80107bd3:	e9 12 f9 ff ff       	jmp    801074ea <alltraps>

80107bd8 <vector19>:
.globl vector19
vector19:
  pushl $0
80107bd8:	6a 00                	push   $0x0
  pushl $19
80107bda:	6a 13                	push   $0x13
  jmp alltraps
80107bdc:	e9 09 f9 ff ff       	jmp    801074ea <alltraps>

80107be1 <vector20>:
.globl vector20
vector20:
  pushl $0
80107be1:	6a 00                	push   $0x0
  pushl $20
80107be3:	6a 14                	push   $0x14
  jmp alltraps
80107be5:	e9 00 f9 ff ff       	jmp    801074ea <alltraps>

80107bea <vector21>:
.globl vector21
vector21:
  pushl $0
80107bea:	6a 00                	push   $0x0
  pushl $21
80107bec:	6a 15                	push   $0x15
  jmp alltraps
80107bee:	e9 f7 f8 ff ff       	jmp    801074ea <alltraps>

80107bf3 <vector22>:
.globl vector22
vector22:
  pushl $0
80107bf3:	6a 00                	push   $0x0
  pushl $22
80107bf5:	6a 16                	push   $0x16
  jmp alltraps
80107bf7:	e9 ee f8 ff ff       	jmp    801074ea <alltraps>

80107bfc <vector23>:
.globl vector23
vector23:
  pushl $0
80107bfc:	6a 00                	push   $0x0
  pushl $23
80107bfe:	6a 17                	push   $0x17
  jmp alltraps
80107c00:	e9 e5 f8 ff ff       	jmp    801074ea <alltraps>

80107c05 <vector24>:
.globl vector24
vector24:
  pushl $0
80107c05:	6a 00                	push   $0x0
  pushl $24
80107c07:	6a 18                	push   $0x18
  jmp alltraps
80107c09:	e9 dc f8 ff ff       	jmp    801074ea <alltraps>

80107c0e <vector25>:
.globl vector25
vector25:
  pushl $0
80107c0e:	6a 00                	push   $0x0
  pushl $25
80107c10:	6a 19                	push   $0x19
  jmp alltraps
80107c12:	e9 d3 f8 ff ff       	jmp    801074ea <alltraps>

80107c17 <vector26>:
.globl vector26
vector26:
  pushl $0
80107c17:	6a 00                	push   $0x0
  pushl $26
80107c19:	6a 1a                	push   $0x1a
  jmp alltraps
80107c1b:	e9 ca f8 ff ff       	jmp    801074ea <alltraps>

80107c20 <vector27>:
.globl vector27
vector27:
  pushl $0
80107c20:	6a 00                	push   $0x0
  pushl $27
80107c22:	6a 1b                	push   $0x1b
  jmp alltraps
80107c24:	e9 c1 f8 ff ff       	jmp    801074ea <alltraps>

80107c29 <vector28>:
.globl vector28
vector28:
  pushl $0
80107c29:	6a 00                	push   $0x0
  pushl $28
80107c2b:	6a 1c                	push   $0x1c
  jmp alltraps
80107c2d:	e9 b8 f8 ff ff       	jmp    801074ea <alltraps>

80107c32 <vector29>:
.globl vector29
vector29:
  pushl $0
80107c32:	6a 00                	push   $0x0
  pushl $29
80107c34:	6a 1d                	push   $0x1d
  jmp alltraps
80107c36:	e9 af f8 ff ff       	jmp    801074ea <alltraps>

80107c3b <vector30>:
.globl vector30
vector30:
  pushl $0
80107c3b:	6a 00                	push   $0x0
  pushl $30
80107c3d:	6a 1e                	push   $0x1e
  jmp alltraps
80107c3f:	e9 a6 f8 ff ff       	jmp    801074ea <alltraps>

80107c44 <vector31>:
.globl vector31
vector31:
  pushl $0
80107c44:	6a 00                	push   $0x0
  pushl $31
80107c46:	6a 1f                	push   $0x1f
  jmp alltraps
80107c48:	e9 9d f8 ff ff       	jmp    801074ea <alltraps>

80107c4d <vector32>:
.globl vector32
vector32:
  pushl $0
80107c4d:	6a 00                	push   $0x0
  pushl $32
80107c4f:	6a 20                	push   $0x20
  jmp alltraps
80107c51:	e9 94 f8 ff ff       	jmp    801074ea <alltraps>

80107c56 <vector33>:
.globl vector33
vector33:
  pushl $0
80107c56:	6a 00                	push   $0x0
  pushl $33
80107c58:	6a 21                	push   $0x21
  jmp alltraps
80107c5a:	e9 8b f8 ff ff       	jmp    801074ea <alltraps>

80107c5f <vector34>:
.globl vector34
vector34:
  pushl $0
80107c5f:	6a 00                	push   $0x0
  pushl $34
80107c61:	6a 22                	push   $0x22
  jmp alltraps
80107c63:	e9 82 f8 ff ff       	jmp    801074ea <alltraps>

80107c68 <vector35>:
.globl vector35
vector35:
  pushl $0
80107c68:	6a 00                	push   $0x0
  pushl $35
80107c6a:	6a 23                	push   $0x23
  jmp alltraps
80107c6c:	e9 79 f8 ff ff       	jmp    801074ea <alltraps>

80107c71 <vector36>:
.globl vector36
vector36:
  pushl $0
80107c71:	6a 00                	push   $0x0
  pushl $36
80107c73:	6a 24                	push   $0x24
  jmp alltraps
80107c75:	e9 70 f8 ff ff       	jmp    801074ea <alltraps>

80107c7a <vector37>:
.globl vector37
vector37:
  pushl $0
80107c7a:	6a 00                	push   $0x0
  pushl $37
80107c7c:	6a 25                	push   $0x25
  jmp alltraps
80107c7e:	e9 67 f8 ff ff       	jmp    801074ea <alltraps>

80107c83 <vector38>:
.globl vector38
vector38:
  pushl $0
80107c83:	6a 00                	push   $0x0
  pushl $38
80107c85:	6a 26                	push   $0x26
  jmp alltraps
80107c87:	e9 5e f8 ff ff       	jmp    801074ea <alltraps>

80107c8c <vector39>:
.globl vector39
vector39:
  pushl $0
80107c8c:	6a 00                	push   $0x0
  pushl $39
80107c8e:	6a 27                	push   $0x27
  jmp alltraps
80107c90:	e9 55 f8 ff ff       	jmp    801074ea <alltraps>

80107c95 <vector40>:
.globl vector40
vector40:
  pushl $0
80107c95:	6a 00                	push   $0x0
  pushl $40
80107c97:	6a 28                	push   $0x28
  jmp alltraps
80107c99:	e9 4c f8 ff ff       	jmp    801074ea <alltraps>

80107c9e <vector41>:
.globl vector41
vector41:
  pushl $0
80107c9e:	6a 00                	push   $0x0
  pushl $41
80107ca0:	6a 29                	push   $0x29
  jmp alltraps
80107ca2:	e9 43 f8 ff ff       	jmp    801074ea <alltraps>

80107ca7 <vector42>:
.globl vector42
vector42:
  pushl $0
80107ca7:	6a 00                	push   $0x0
  pushl $42
80107ca9:	6a 2a                	push   $0x2a
  jmp alltraps
80107cab:	e9 3a f8 ff ff       	jmp    801074ea <alltraps>

80107cb0 <vector43>:
.globl vector43
vector43:
  pushl $0
80107cb0:	6a 00                	push   $0x0
  pushl $43
80107cb2:	6a 2b                	push   $0x2b
  jmp alltraps
80107cb4:	e9 31 f8 ff ff       	jmp    801074ea <alltraps>

80107cb9 <vector44>:
.globl vector44
vector44:
  pushl $0
80107cb9:	6a 00                	push   $0x0
  pushl $44
80107cbb:	6a 2c                	push   $0x2c
  jmp alltraps
80107cbd:	e9 28 f8 ff ff       	jmp    801074ea <alltraps>

80107cc2 <vector45>:
.globl vector45
vector45:
  pushl $0
80107cc2:	6a 00                	push   $0x0
  pushl $45
80107cc4:	6a 2d                	push   $0x2d
  jmp alltraps
80107cc6:	e9 1f f8 ff ff       	jmp    801074ea <alltraps>

80107ccb <vector46>:
.globl vector46
vector46:
  pushl $0
80107ccb:	6a 00                	push   $0x0
  pushl $46
80107ccd:	6a 2e                	push   $0x2e
  jmp alltraps
80107ccf:	e9 16 f8 ff ff       	jmp    801074ea <alltraps>

80107cd4 <vector47>:
.globl vector47
vector47:
  pushl $0
80107cd4:	6a 00                	push   $0x0
  pushl $47
80107cd6:	6a 2f                	push   $0x2f
  jmp alltraps
80107cd8:	e9 0d f8 ff ff       	jmp    801074ea <alltraps>

80107cdd <vector48>:
.globl vector48
vector48:
  pushl $0
80107cdd:	6a 00                	push   $0x0
  pushl $48
80107cdf:	6a 30                	push   $0x30
  jmp alltraps
80107ce1:	e9 04 f8 ff ff       	jmp    801074ea <alltraps>

80107ce6 <vector49>:
.globl vector49
vector49:
  pushl $0
80107ce6:	6a 00                	push   $0x0
  pushl $49
80107ce8:	6a 31                	push   $0x31
  jmp alltraps
80107cea:	e9 fb f7 ff ff       	jmp    801074ea <alltraps>

80107cef <vector50>:
.globl vector50
vector50:
  pushl $0
80107cef:	6a 00                	push   $0x0
  pushl $50
80107cf1:	6a 32                	push   $0x32
  jmp alltraps
80107cf3:	e9 f2 f7 ff ff       	jmp    801074ea <alltraps>

80107cf8 <vector51>:
.globl vector51
vector51:
  pushl $0
80107cf8:	6a 00                	push   $0x0
  pushl $51
80107cfa:	6a 33                	push   $0x33
  jmp alltraps
80107cfc:	e9 e9 f7 ff ff       	jmp    801074ea <alltraps>

80107d01 <vector52>:
.globl vector52
vector52:
  pushl $0
80107d01:	6a 00                	push   $0x0
  pushl $52
80107d03:	6a 34                	push   $0x34
  jmp alltraps
80107d05:	e9 e0 f7 ff ff       	jmp    801074ea <alltraps>

80107d0a <vector53>:
.globl vector53
vector53:
  pushl $0
80107d0a:	6a 00                	push   $0x0
  pushl $53
80107d0c:	6a 35                	push   $0x35
  jmp alltraps
80107d0e:	e9 d7 f7 ff ff       	jmp    801074ea <alltraps>

80107d13 <vector54>:
.globl vector54
vector54:
  pushl $0
80107d13:	6a 00                	push   $0x0
  pushl $54
80107d15:	6a 36                	push   $0x36
  jmp alltraps
80107d17:	e9 ce f7 ff ff       	jmp    801074ea <alltraps>

80107d1c <vector55>:
.globl vector55
vector55:
  pushl $0
80107d1c:	6a 00                	push   $0x0
  pushl $55
80107d1e:	6a 37                	push   $0x37
  jmp alltraps
80107d20:	e9 c5 f7 ff ff       	jmp    801074ea <alltraps>

80107d25 <vector56>:
.globl vector56
vector56:
  pushl $0
80107d25:	6a 00                	push   $0x0
  pushl $56
80107d27:	6a 38                	push   $0x38
  jmp alltraps
80107d29:	e9 bc f7 ff ff       	jmp    801074ea <alltraps>

80107d2e <vector57>:
.globl vector57
vector57:
  pushl $0
80107d2e:	6a 00                	push   $0x0
  pushl $57
80107d30:	6a 39                	push   $0x39
  jmp alltraps
80107d32:	e9 b3 f7 ff ff       	jmp    801074ea <alltraps>

80107d37 <vector58>:
.globl vector58
vector58:
  pushl $0
80107d37:	6a 00                	push   $0x0
  pushl $58
80107d39:	6a 3a                	push   $0x3a
  jmp alltraps
80107d3b:	e9 aa f7 ff ff       	jmp    801074ea <alltraps>

80107d40 <vector59>:
.globl vector59
vector59:
  pushl $0
80107d40:	6a 00                	push   $0x0
  pushl $59
80107d42:	6a 3b                	push   $0x3b
  jmp alltraps
80107d44:	e9 a1 f7 ff ff       	jmp    801074ea <alltraps>

80107d49 <vector60>:
.globl vector60
vector60:
  pushl $0
80107d49:	6a 00                	push   $0x0
  pushl $60
80107d4b:	6a 3c                	push   $0x3c
  jmp alltraps
80107d4d:	e9 98 f7 ff ff       	jmp    801074ea <alltraps>

80107d52 <vector61>:
.globl vector61
vector61:
  pushl $0
80107d52:	6a 00                	push   $0x0
  pushl $61
80107d54:	6a 3d                	push   $0x3d
  jmp alltraps
80107d56:	e9 8f f7 ff ff       	jmp    801074ea <alltraps>

80107d5b <vector62>:
.globl vector62
vector62:
  pushl $0
80107d5b:	6a 00                	push   $0x0
  pushl $62
80107d5d:	6a 3e                	push   $0x3e
  jmp alltraps
80107d5f:	e9 86 f7 ff ff       	jmp    801074ea <alltraps>

80107d64 <vector63>:
.globl vector63
vector63:
  pushl $0
80107d64:	6a 00                	push   $0x0
  pushl $63
80107d66:	6a 3f                	push   $0x3f
  jmp alltraps
80107d68:	e9 7d f7 ff ff       	jmp    801074ea <alltraps>

80107d6d <vector64>:
.globl vector64
vector64:
  pushl $0
80107d6d:	6a 00                	push   $0x0
  pushl $64
80107d6f:	6a 40                	push   $0x40
  jmp alltraps
80107d71:	e9 74 f7 ff ff       	jmp    801074ea <alltraps>

80107d76 <vector65>:
.globl vector65
vector65:
  pushl $0
80107d76:	6a 00                	push   $0x0
  pushl $65
80107d78:	6a 41                	push   $0x41
  jmp alltraps
80107d7a:	e9 6b f7 ff ff       	jmp    801074ea <alltraps>

80107d7f <vector66>:
.globl vector66
vector66:
  pushl $0
80107d7f:	6a 00                	push   $0x0
  pushl $66
80107d81:	6a 42                	push   $0x42
  jmp alltraps
80107d83:	e9 62 f7 ff ff       	jmp    801074ea <alltraps>

80107d88 <vector67>:
.globl vector67
vector67:
  pushl $0
80107d88:	6a 00                	push   $0x0
  pushl $67
80107d8a:	6a 43                	push   $0x43
  jmp alltraps
80107d8c:	e9 59 f7 ff ff       	jmp    801074ea <alltraps>

80107d91 <vector68>:
.globl vector68
vector68:
  pushl $0
80107d91:	6a 00                	push   $0x0
  pushl $68
80107d93:	6a 44                	push   $0x44
  jmp alltraps
80107d95:	e9 50 f7 ff ff       	jmp    801074ea <alltraps>

80107d9a <vector69>:
.globl vector69
vector69:
  pushl $0
80107d9a:	6a 00                	push   $0x0
  pushl $69
80107d9c:	6a 45                	push   $0x45
  jmp alltraps
80107d9e:	e9 47 f7 ff ff       	jmp    801074ea <alltraps>

80107da3 <vector70>:
.globl vector70
vector70:
  pushl $0
80107da3:	6a 00                	push   $0x0
  pushl $70
80107da5:	6a 46                	push   $0x46
  jmp alltraps
80107da7:	e9 3e f7 ff ff       	jmp    801074ea <alltraps>

80107dac <vector71>:
.globl vector71
vector71:
  pushl $0
80107dac:	6a 00                	push   $0x0
  pushl $71
80107dae:	6a 47                	push   $0x47
  jmp alltraps
80107db0:	e9 35 f7 ff ff       	jmp    801074ea <alltraps>

80107db5 <vector72>:
.globl vector72
vector72:
  pushl $0
80107db5:	6a 00                	push   $0x0
  pushl $72
80107db7:	6a 48                	push   $0x48
  jmp alltraps
80107db9:	e9 2c f7 ff ff       	jmp    801074ea <alltraps>

80107dbe <vector73>:
.globl vector73
vector73:
  pushl $0
80107dbe:	6a 00                	push   $0x0
  pushl $73
80107dc0:	6a 49                	push   $0x49
  jmp alltraps
80107dc2:	e9 23 f7 ff ff       	jmp    801074ea <alltraps>

80107dc7 <vector74>:
.globl vector74
vector74:
  pushl $0
80107dc7:	6a 00                	push   $0x0
  pushl $74
80107dc9:	6a 4a                	push   $0x4a
  jmp alltraps
80107dcb:	e9 1a f7 ff ff       	jmp    801074ea <alltraps>

80107dd0 <vector75>:
.globl vector75
vector75:
  pushl $0
80107dd0:	6a 00                	push   $0x0
  pushl $75
80107dd2:	6a 4b                	push   $0x4b
  jmp alltraps
80107dd4:	e9 11 f7 ff ff       	jmp    801074ea <alltraps>

80107dd9 <vector76>:
.globl vector76
vector76:
  pushl $0
80107dd9:	6a 00                	push   $0x0
  pushl $76
80107ddb:	6a 4c                	push   $0x4c
  jmp alltraps
80107ddd:	e9 08 f7 ff ff       	jmp    801074ea <alltraps>

80107de2 <vector77>:
.globl vector77
vector77:
  pushl $0
80107de2:	6a 00                	push   $0x0
  pushl $77
80107de4:	6a 4d                	push   $0x4d
  jmp alltraps
80107de6:	e9 ff f6 ff ff       	jmp    801074ea <alltraps>

80107deb <vector78>:
.globl vector78
vector78:
  pushl $0
80107deb:	6a 00                	push   $0x0
  pushl $78
80107ded:	6a 4e                	push   $0x4e
  jmp alltraps
80107def:	e9 f6 f6 ff ff       	jmp    801074ea <alltraps>

80107df4 <vector79>:
.globl vector79
vector79:
  pushl $0
80107df4:	6a 00                	push   $0x0
  pushl $79
80107df6:	6a 4f                	push   $0x4f
  jmp alltraps
80107df8:	e9 ed f6 ff ff       	jmp    801074ea <alltraps>

80107dfd <vector80>:
.globl vector80
vector80:
  pushl $0
80107dfd:	6a 00                	push   $0x0
  pushl $80
80107dff:	6a 50                	push   $0x50
  jmp alltraps
80107e01:	e9 e4 f6 ff ff       	jmp    801074ea <alltraps>

80107e06 <vector81>:
.globl vector81
vector81:
  pushl $0
80107e06:	6a 00                	push   $0x0
  pushl $81
80107e08:	6a 51                	push   $0x51
  jmp alltraps
80107e0a:	e9 db f6 ff ff       	jmp    801074ea <alltraps>

80107e0f <vector82>:
.globl vector82
vector82:
  pushl $0
80107e0f:	6a 00                	push   $0x0
  pushl $82
80107e11:	6a 52                	push   $0x52
  jmp alltraps
80107e13:	e9 d2 f6 ff ff       	jmp    801074ea <alltraps>

80107e18 <vector83>:
.globl vector83
vector83:
  pushl $0
80107e18:	6a 00                	push   $0x0
  pushl $83
80107e1a:	6a 53                	push   $0x53
  jmp alltraps
80107e1c:	e9 c9 f6 ff ff       	jmp    801074ea <alltraps>

80107e21 <vector84>:
.globl vector84
vector84:
  pushl $0
80107e21:	6a 00                	push   $0x0
  pushl $84
80107e23:	6a 54                	push   $0x54
  jmp alltraps
80107e25:	e9 c0 f6 ff ff       	jmp    801074ea <alltraps>

80107e2a <vector85>:
.globl vector85
vector85:
  pushl $0
80107e2a:	6a 00                	push   $0x0
  pushl $85
80107e2c:	6a 55                	push   $0x55
  jmp alltraps
80107e2e:	e9 b7 f6 ff ff       	jmp    801074ea <alltraps>

80107e33 <vector86>:
.globl vector86
vector86:
  pushl $0
80107e33:	6a 00                	push   $0x0
  pushl $86
80107e35:	6a 56                	push   $0x56
  jmp alltraps
80107e37:	e9 ae f6 ff ff       	jmp    801074ea <alltraps>

80107e3c <vector87>:
.globl vector87
vector87:
  pushl $0
80107e3c:	6a 00                	push   $0x0
  pushl $87
80107e3e:	6a 57                	push   $0x57
  jmp alltraps
80107e40:	e9 a5 f6 ff ff       	jmp    801074ea <alltraps>

80107e45 <vector88>:
.globl vector88
vector88:
  pushl $0
80107e45:	6a 00                	push   $0x0
  pushl $88
80107e47:	6a 58                	push   $0x58
  jmp alltraps
80107e49:	e9 9c f6 ff ff       	jmp    801074ea <alltraps>

80107e4e <vector89>:
.globl vector89
vector89:
  pushl $0
80107e4e:	6a 00                	push   $0x0
  pushl $89
80107e50:	6a 59                	push   $0x59
  jmp alltraps
80107e52:	e9 93 f6 ff ff       	jmp    801074ea <alltraps>

80107e57 <vector90>:
.globl vector90
vector90:
  pushl $0
80107e57:	6a 00                	push   $0x0
  pushl $90
80107e59:	6a 5a                	push   $0x5a
  jmp alltraps
80107e5b:	e9 8a f6 ff ff       	jmp    801074ea <alltraps>

80107e60 <vector91>:
.globl vector91
vector91:
  pushl $0
80107e60:	6a 00                	push   $0x0
  pushl $91
80107e62:	6a 5b                	push   $0x5b
  jmp alltraps
80107e64:	e9 81 f6 ff ff       	jmp    801074ea <alltraps>

80107e69 <vector92>:
.globl vector92
vector92:
  pushl $0
80107e69:	6a 00                	push   $0x0
  pushl $92
80107e6b:	6a 5c                	push   $0x5c
  jmp alltraps
80107e6d:	e9 78 f6 ff ff       	jmp    801074ea <alltraps>

80107e72 <vector93>:
.globl vector93
vector93:
  pushl $0
80107e72:	6a 00                	push   $0x0
  pushl $93
80107e74:	6a 5d                	push   $0x5d
  jmp alltraps
80107e76:	e9 6f f6 ff ff       	jmp    801074ea <alltraps>

80107e7b <vector94>:
.globl vector94
vector94:
  pushl $0
80107e7b:	6a 00                	push   $0x0
  pushl $94
80107e7d:	6a 5e                	push   $0x5e
  jmp alltraps
80107e7f:	e9 66 f6 ff ff       	jmp    801074ea <alltraps>

80107e84 <vector95>:
.globl vector95
vector95:
  pushl $0
80107e84:	6a 00                	push   $0x0
  pushl $95
80107e86:	6a 5f                	push   $0x5f
  jmp alltraps
80107e88:	e9 5d f6 ff ff       	jmp    801074ea <alltraps>

80107e8d <vector96>:
.globl vector96
vector96:
  pushl $0
80107e8d:	6a 00                	push   $0x0
  pushl $96
80107e8f:	6a 60                	push   $0x60
  jmp alltraps
80107e91:	e9 54 f6 ff ff       	jmp    801074ea <alltraps>

80107e96 <vector97>:
.globl vector97
vector97:
  pushl $0
80107e96:	6a 00                	push   $0x0
  pushl $97
80107e98:	6a 61                	push   $0x61
  jmp alltraps
80107e9a:	e9 4b f6 ff ff       	jmp    801074ea <alltraps>

80107e9f <vector98>:
.globl vector98
vector98:
  pushl $0
80107e9f:	6a 00                	push   $0x0
  pushl $98
80107ea1:	6a 62                	push   $0x62
  jmp alltraps
80107ea3:	e9 42 f6 ff ff       	jmp    801074ea <alltraps>

80107ea8 <vector99>:
.globl vector99
vector99:
  pushl $0
80107ea8:	6a 00                	push   $0x0
  pushl $99
80107eaa:	6a 63                	push   $0x63
  jmp alltraps
80107eac:	e9 39 f6 ff ff       	jmp    801074ea <alltraps>

80107eb1 <vector100>:
.globl vector100
vector100:
  pushl $0
80107eb1:	6a 00                	push   $0x0
  pushl $100
80107eb3:	6a 64                	push   $0x64
  jmp alltraps
80107eb5:	e9 30 f6 ff ff       	jmp    801074ea <alltraps>

80107eba <vector101>:
.globl vector101
vector101:
  pushl $0
80107eba:	6a 00                	push   $0x0
  pushl $101
80107ebc:	6a 65                	push   $0x65
  jmp alltraps
80107ebe:	e9 27 f6 ff ff       	jmp    801074ea <alltraps>

80107ec3 <vector102>:
.globl vector102
vector102:
  pushl $0
80107ec3:	6a 00                	push   $0x0
  pushl $102
80107ec5:	6a 66                	push   $0x66
  jmp alltraps
80107ec7:	e9 1e f6 ff ff       	jmp    801074ea <alltraps>

80107ecc <vector103>:
.globl vector103
vector103:
  pushl $0
80107ecc:	6a 00                	push   $0x0
  pushl $103
80107ece:	6a 67                	push   $0x67
  jmp alltraps
80107ed0:	e9 15 f6 ff ff       	jmp    801074ea <alltraps>

80107ed5 <vector104>:
.globl vector104
vector104:
  pushl $0
80107ed5:	6a 00                	push   $0x0
  pushl $104
80107ed7:	6a 68                	push   $0x68
  jmp alltraps
80107ed9:	e9 0c f6 ff ff       	jmp    801074ea <alltraps>

80107ede <vector105>:
.globl vector105
vector105:
  pushl $0
80107ede:	6a 00                	push   $0x0
  pushl $105
80107ee0:	6a 69                	push   $0x69
  jmp alltraps
80107ee2:	e9 03 f6 ff ff       	jmp    801074ea <alltraps>

80107ee7 <vector106>:
.globl vector106
vector106:
  pushl $0
80107ee7:	6a 00                	push   $0x0
  pushl $106
80107ee9:	6a 6a                	push   $0x6a
  jmp alltraps
80107eeb:	e9 fa f5 ff ff       	jmp    801074ea <alltraps>

80107ef0 <vector107>:
.globl vector107
vector107:
  pushl $0
80107ef0:	6a 00                	push   $0x0
  pushl $107
80107ef2:	6a 6b                	push   $0x6b
  jmp alltraps
80107ef4:	e9 f1 f5 ff ff       	jmp    801074ea <alltraps>

80107ef9 <vector108>:
.globl vector108
vector108:
  pushl $0
80107ef9:	6a 00                	push   $0x0
  pushl $108
80107efb:	6a 6c                	push   $0x6c
  jmp alltraps
80107efd:	e9 e8 f5 ff ff       	jmp    801074ea <alltraps>

80107f02 <vector109>:
.globl vector109
vector109:
  pushl $0
80107f02:	6a 00                	push   $0x0
  pushl $109
80107f04:	6a 6d                	push   $0x6d
  jmp alltraps
80107f06:	e9 df f5 ff ff       	jmp    801074ea <alltraps>

80107f0b <vector110>:
.globl vector110
vector110:
  pushl $0
80107f0b:	6a 00                	push   $0x0
  pushl $110
80107f0d:	6a 6e                	push   $0x6e
  jmp alltraps
80107f0f:	e9 d6 f5 ff ff       	jmp    801074ea <alltraps>

80107f14 <vector111>:
.globl vector111
vector111:
  pushl $0
80107f14:	6a 00                	push   $0x0
  pushl $111
80107f16:	6a 6f                	push   $0x6f
  jmp alltraps
80107f18:	e9 cd f5 ff ff       	jmp    801074ea <alltraps>

80107f1d <vector112>:
.globl vector112
vector112:
  pushl $0
80107f1d:	6a 00                	push   $0x0
  pushl $112
80107f1f:	6a 70                	push   $0x70
  jmp alltraps
80107f21:	e9 c4 f5 ff ff       	jmp    801074ea <alltraps>

80107f26 <vector113>:
.globl vector113
vector113:
  pushl $0
80107f26:	6a 00                	push   $0x0
  pushl $113
80107f28:	6a 71                	push   $0x71
  jmp alltraps
80107f2a:	e9 bb f5 ff ff       	jmp    801074ea <alltraps>

80107f2f <vector114>:
.globl vector114
vector114:
  pushl $0
80107f2f:	6a 00                	push   $0x0
  pushl $114
80107f31:	6a 72                	push   $0x72
  jmp alltraps
80107f33:	e9 b2 f5 ff ff       	jmp    801074ea <alltraps>

80107f38 <vector115>:
.globl vector115
vector115:
  pushl $0
80107f38:	6a 00                	push   $0x0
  pushl $115
80107f3a:	6a 73                	push   $0x73
  jmp alltraps
80107f3c:	e9 a9 f5 ff ff       	jmp    801074ea <alltraps>

80107f41 <vector116>:
.globl vector116
vector116:
  pushl $0
80107f41:	6a 00                	push   $0x0
  pushl $116
80107f43:	6a 74                	push   $0x74
  jmp alltraps
80107f45:	e9 a0 f5 ff ff       	jmp    801074ea <alltraps>

80107f4a <vector117>:
.globl vector117
vector117:
  pushl $0
80107f4a:	6a 00                	push   $0x0
  pushl $117
80107f4c:	6a 75                	push   $0x75
  jmp alltraps
80107f4e:	e9 97 f5 ff ff       	jmp    801074ea <alltraps>

80107f53 <vector118>:
.globl vector118
vector118:
  pushl $0
80107f53:	6a 00                	push   $0x0
  pushl $118
80107f55:	6a 76                	push   $0x76
  jmp alltraps
80107f57:	e9 8e f5 ff ff       	jmp    801074ea <alltraps>

80107f5c <vector119>:
.globl vector119
vector119:
  pushl $0
80107f5c:	6a 00                	push   $0x0
  pushl $119
80107f5e:	6a 77                	push   $0x77
  jmp alltraps
80107f60:	e9 85 f5 ff ff       	jmp    801074ea <alltraps>

80107f65 <vector120>:
.globl vector120
vector120:
  pushl $0
80107f65:	6a 00                	push   $0x0
  pushl $120
80107f67:	6a 78                	push   $0x78
  jmp alltraps
80107f69:	e9 7c f5 ff ff       	jmp    801074ea <alltraps>

80107f6e <vector121>:
.globl vector121
vector121:
  pushl $0
80107f6e:	6a 00                	push   $0x0
  pushl $121
80107f70:	6a 79                	push   $0x79
  jmp alltraps
80107f72:	e9 73 f5 ff ff       	jmp    801074ea <alltraps>

80107f77 <vector122>:
.globl vector122
vector122:
  pushl $0
80107f77:	6a 00                	push   $0x0
  pushl $122
80107f79:	6a 7a                	push   $0x7a
  jmp alltraps
80107f7b:	e9 6a f5 ff ff       	jmp    801074ea <alltraps>

80107f80 <vector123>:
.globl vector123
vector123:
  pushl $0
80107f80:	6a 00                	push   $0x0
  pushl $123
80107f82:	6a 7b                	push   $0x7b
  jmp alltraps
80107f84:	e9 61 f5 ff ff       	jmp    801074ea <alltraps>

80107f89 <vector124>:
.globl vector124
vector124:
  pushl $0
80107f89:	6a 00                	push   $0x0
  pushl $124
80107f8b:	6a 7c                	push   $0x7c
  jmp alltraps
80107f8d:	e9 58 f5 ff ff       	jmp    801074ea <alltraps>

80107f92 <vector125>:
.globl vector125
vector125:
  pushl $0
80107f92:	6a 00                	push   $0x0
  pushl $125
80107f94:	6a 7d                	push   $0x7d
  jmp alltraps
80107f96:	e9 4f f5 ff ff       	jmp    801074ea <alltraps>

80107f9b <vector126>:
.globl vector126
vector126:
  pushl $0
80107f9b:	6a 00                	push   $0x0
  pushl $126
80107f9d:	6a 7e                	push   $0x7e
  jmp alltraps
80107f9f:	e9 46 f5 ff ff       	jmp    801074ea <alltraps>

80107fa4 <vector127>:
.globl vector127
vector127:
  pushl $0
80107fa4:	6a 00                	push   $0x0
  pushl $127
80107fa6:	6a 7f                	push   $0x7f
  jmp alltraps
80107fa8:	e9 3d f5 ff ff       	jmp    801074ea <alltraps>

80107fad <vector128>:
.globl vector128
vector128:
  pushl $0
80107fad:	6a 00                	push   $0x0
  pushl $128
80107faf:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80107fb4:	e9 31 f5 ff ff       	jmp    801074ea <alltraps>

80107fb9 <vector129>:
.globl vector129
vector129:
  pushl $0
80107fb9:	6a 00                	push   $0x0
  pushl $129
80107fbb:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80107fc0:	e9 25 f5 ff ff       	jmp    801074ea <alltraps>

80107fc5 <vector130>:
.globl vector130
vector130:
  pushl $0
80107fc5:	6a 00                	push   $0x0
  pushl $130
80107fc7:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80107fcc:	e9 19 f5 ff ff       	jmp    801074ea <alltraps>

80107fd1 <vector131>:
.globl vector131
vector131:
  pushl $0
80107fd1:	6a 00                	push   $0x0
  pushl $131
80107fd3:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80107fd8:	e9 0d f5 ff ff       	jmp    801074ea <alltraps>

80107fdd <vector132>:
.globl vector132
vector132:
  pushl $0
80107fdd:	6a 00                	push   $0x0
  pushl $132
80107fdf:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80107fe4:	e9 01 f5 ff ff       	jmp    801074ea <alltraps>

80107fe9 <vector133>:
.globl vector133
vector133:
  pushl $0
80107fe9:	6a 00                	push   $0x0
  pushl $133
80107feb:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80107ff0:	e9 f5 f4 ff ff       	jmp    801074ea <alltraps>

80107ff5 <vector134>:
.globl vector134
vector134:
  pushl $0
80107ff5:	6a 00                	push   $0x0
  pushl $134
80107ff7:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80107ffc:	e9 e9 f4 ff ff       	jmp    801074ea <alltraps>

80108001 <vector135>:
.globl vector135
vector135:
  pushl $0
80108001:	6a 00                	push   $0x0
  pushl $135
80108003:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80108008:	e9 dd f4 ff ff       	jmp    801074ea <alltraps>

8010800d <vector136>:
.globl vector136
vector136:
  pushl $0
8010800d:	6a 00                	push   $0x0
  pushl $136
8010800f:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80108014:	e9 d1 f4 ff ff       	jmp    801074ea <alltraps>

80108019 <vector137>:
.globl vector137
vector137:
  pushl $0
80108019:	6a 00                	push   $0x0
  pushl $137
8010801b:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80108020:	e9 c5 f4 ff ff       	jmp    801074ea <alltraps>

80108025 <vector138>:
.globl vector138
vector138:
  pushl $0
80108025:	6a 00                	push   $0x0
  pushl $138
80108027:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
8010802c:	e9 b9 f4 ff ff       	jmp    801074ea <alltraps>

80108031 <vector139>:
.globl vector139
vector139:
  pushl $0
80108031:	6a 00                	push   $0x0
  pushl $139
80108033:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80108038:	e9 ad f4 ff ff       	jmp    801074ea <alltraps>

8010803d <vector140>:
.globl vector140
vector140:
  pushl $0
8010803d:	6a 00                	push   $0x0
  pushl $140
8010803f:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80108044:	e9 a1 f4 ff ff       	jmp    801074ea <alltraps>

80108049 <vector141>:
.globl vector141
vector141:
  pushl $0
80108049:	6a 00                	push   $0x0
  pushl $141
8010804b:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80108050:	e9 95 f4 ff ff       	jmp    801074ea <alltraps>

80108055 <vector142>:
.globl vector142
vector142:
  pushl $0
80108055:	6a 00                	push   $0x0
  pushl $142
80108057:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
8010805c:	e9 89 f4 ff ff       	jmp    801074ea <alltraps>

80108061 <vector143>:
.globl vector143
vector143:
  pushl $0
80108061:	6a 00                	push   $0x0
  pushl $143
80108063:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80108068:	e9 7d f4 ff ff       	jmp    801074ea <alltraps>

8010806d <vector144>:
.globl vector144
vector144:
  pushl $0
8010806d:	6a 00                	push   $0x0
  pushl $144
8010806f:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80108074:	e9 71 f4 ff ff       	jmp    801074ea <alltraps>

80108079 <vector145>:
.globl vector145
vector145:
  pushl $0
80108079:	6a 00                	push   $0x0
  pushl $145
8010807b:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80108080:	e9 65 f4 ff ff       	jmp    801074ea <alltraps>

80108085 <vector146>:
.globl vector146
vector146:
  pushl $0
80108085:	6a 00                	push   $0x0
  pushl $146
80108087:	68 92 00 00 00       	push   $0x92
  jmp alltraps
8010808c:	e9 59 f4 ff ff       	jmp    801074ea <alltraps>

80108091 <vector147>:
.globl vector147
vector147:
  pushl $0
80108091:	6a 00                	push   $0x0
  pushl $147
80108093:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80108098:	e9 4d f4 ff ff       	jmp    801074ea <alltraps>

8010809d <vector148>:
.globl vector148
vector148:
  pushl $0
8010809d:	6a 00                	push   $0x0
  pushl $148
8010809f:	68 94 00 00 00       	push   $0x94
  jmp alltraps
801080a4:	e9 41 f4 ff ff       	jmp    801074ea <alltraps>

801080a9 <vector149>:
.globl vector149
vector149:
  pushl $0
801080a9:	6a 00                	push   $0x0
  pushl $149
801080ab:	68 95 00 00 00       	push   $0x95
  jmp alltraps
801080b0:	e9 35 f4 ff ff       	jmp    801074ea <alltraps>

801080b5 <vector150>:
.globl vector150
vector150:
  pushl $0
801080b5:	6a 00                	push   $0x0
  pushl $150
801080b7:	68 96 00 00 00       	push   $0x96
  jmp alltraps
801080bc:	e9 29 f4 ff ff       	jmp    801074ea <alltraps>

801080c1 <vector151>:
.globl vector151
vector151:
  pushl $0
801080c1:	6a 00                	push   $0x0
  pushl $151
801080c3:	68 97 00 00 00       	push   $0x97
  jmp alltraps
801080c8:	e9 1d f4 ff ff       	jmp    801074ea <alltraps>

801080cd <vector152>:
.globl vector152
vector152:
  pushl $0
801080cd:	6a 00                	push   $0x0
  pushl $152
801080cf:	68 98 00 00 00       	push   $0x98
  jmp alltraps
801080d4:	e9 11 f4 ff ff       	jmp    801074ea <alltraps>

801080d9 <vector153>:
.globl vector153
vector153:
  pushl $0
801080d9:	6a 00                	push   $0x0
  pushl $153
801080db:	68 99 00 00 00       	push   $0x99
  jmp alltraps
801080e0:	e9 05 f4 ff ff       	jmp    801074ea <alltraps>

801080e5 <vector154>:
.globl vector154
vector154:
  pushl $0
801080e5:	6a 00                	push   $0x0
  pushl $154
801080e7:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
801080ec:	e9 f9 f3 ff ff       	jmp    801074ea <alltraps>

801080f1 <vector155>:
.globl vector155
vector155:
  pushl $0
801080f1:	6a 00                	push   $0x0
  pushl $155
801080f3:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
801080f8:	e9 ed f3 ff ff       	jmp    801074ea <alltraps>

801080fd <vector156>:
.globl vector156
vector156:
  pushl $0
801080fd:	6a 00                	push   $0x0
  pushl $156
801080ff:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80108104:	e9 e1 f3 ff ff       	jmp    801074ea <alltraps>

80108109 <vector157>:
.globl vector157
vector157:
  pushl $0
80108109:	6a 00                	push   $0x0
  pushl $157
8010810b:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80108110:	e9 d5 f3 ff ff       	jmp    801074ea <alltraps>

80108115 <vector158>:
.globl vector158
vector158:
  pushl $0
80108115:	6a 00                	push   $0x0
  pushl $158
80108117:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
8010811c:	e9 c9 f3 ff ff       	jmp    801074ea <alltraps>

80108121 <vector159>:
.globl vector159
vector159:
  pushl $0
80108121:	6a 00                	push   $0x0
  pushl $159
80108123:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80108128:	e9 bd f3 ff ff       	jmp    801074ea <alltraps>

8010812d <vector160>:
.globl vector160
vector160:
  pushl $0
8010812d:	6a 00                	push   $0x0
  pushl $160
8010812f:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80108134:	e9 b1 f3 ff ff       	jmp    801074ea <alltraps>

80108139 <vector161>:
.globl vector161
vector161:
  pushl $0
80108139:	6a 00                	push   $0x0
  pushl $161
8010813b:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80108140:	e9 a5 f3 ff ff       	jmp    801074ea <alltraps>

80108145 <vector162>:
.globl vector162
vector162:
  pushl $0
80108145:	6a 00                	push   $0x0
  pushl $162
80108147:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
8010814c:	e9 99 f3 ff ff       	jmp    801074ea <alltraps>

80108151 <vector163>:
.globl vector163
vector163:
  pushl $0
80108151:	6a 00                	push   $0x0
  pushl $163
80108153:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80108158:	e9 8d f3 ff ff       	jmp    801074ea <alltraps>

8010815d <vector164>:
.globl vector164
vector164:
  pushl $0
8010815d:	6a 00                	push   $0x0
  pushl $164
8010815f:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80108164:	e9 81 f3 ff ff       	jmp    801074ea <alltraps>

80108169 <vector165>:
.globl vector165
vector165:
  pushl $0
80108169:	6a 00                	push   $0x0
  pushl $165
8010816b:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80108170:	e9 75 f3 ff ff       	jmp    801074ea <alltraps>

80108175 <vector166>:
.globl vector166
vector166:
  pushl $0
80108175:	6a 00                	push   $0x0
  pushl $166
80108177:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
8010817c:	e9 69 f3 ff ff       	jmp    801074ea <alltraps>

80108181 <vector167>:
.globl vector167
vector167:
  pushl $0
80108181:	6a 00                	push   $0x0
  pushl $167
80108183:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80108188:	e9 5d f3 ff ff       	jmp    801074ea <alltraps>

8010818d <vector168>:
.globl vector168
vector168:
  pushl $0
8010818d:	6a 00                	push   $0x0
  pushl $168
8010818f:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80108194:	e9 51 f3 ff ff       	jmp    801074ea <alltraps>

80108199 <vector169>:
.globl vector169
vector169:
  pushl $0
80108199:	6a 00                	push   $0x0
  pushl $169
8010819b:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
801081a0:	e9 45 f3 ff ff       	jmp    801074ea <alltraps>

801081a5 <vector170>:
.globl vector170
vector170:
  pushl $0
801081a5:	6a 00                	push   $0x0
  pushl $170
801081a7:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
801081ac:	e9 39 f3 ff ff       	jmp    801074ea <alltraps>

801081b1 <vector171>:
.globl vector171
vector171:
  pushl $0
801081b1:	6a 00                	push   $0x0
  pushl $171
801081b3:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
801081b8:	e9 2d f3 ff ff       	jmp    801074ea <alltraps>

801081bd <vector172>:
.globl vector172
vector172:
  pushl $0
801081bd:	6a 00                	push   $0x0
  pushl $172
801081bf:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
801081c4:	e9 21 f3 ff ff       	jmp    801074ea <alltraps>

801081c9 <vector173>:
.globl vector173
vector173:
  pushl $0
801081c9:	6a 00                	push   $0x0
  pushl $173
801081cb:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
801081d0:	e9 15 f3 ff ff       	jmp    801074ea <alltraps>

801081d5 <vector174>:
.globl vector174
vector174:
  pushl $0
801081d5:	6a 00                	push   $0x0
  pushl $174
801081d7:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
801081dc:	e9 09 f3 ff ff       	jmp    801074ea <alltraps>

801081e1 <vector175>:
.globl vector175
vector175:
  pushl $0
801081e1:	6a 00                	push   $0x0
  pushl $175
801081e3:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
801081e8:	e9 fd f2 ff ff       	jmp    801074ea <alltraps>

801081ed <vector176>:
.globl vector176
vector176:
  pushl $0
801081ed:	6a 00                	push   $0x0
  pushl $176
801081ef:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
801081f4:	e9 f1 f2 ff ff       	jmp    801074ea <alltraps>

801081f9 <vector177>:
.globl vector177
vector177:
  pushl $0
801081f9:	6a 00                	push   $0x0
  pushl $177
801081fb:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80108200:	e9 e5 f2 ff ff       	jmp    801074ea <alltraps>

80108205 <vector178>:
.globl vector178
vector178:
  pushl $0
80108205:	6a 00                	push   $0x0
  pushl $178
80108207:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
8010820c:	e9 d9 f2 ff ff       	jmp    801074ea <alltraps>

80108211 <vector179>:
.globl vector179
vector179:
  pushl $0
80108211:	6a 00                	push   $0x0
  pushl $179
80108213:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80108218:	e9 cd f2 ff ff       	jmp    801074ea <alltraps>

8010821d <vector180>:
.globl vector180
vector180:
  pushl $0
8010821d:	6a 00                	push   $0x0
  pushl $180
8010821f:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80108224:	e9 c1 f2 ff ff       	jmp    801074ea <alltraps>

80108229 <vector181>:
.globl vector181
vector181:
  pushl $0
80108229:	6a 00                	push   $0x0
  pushl $181
8010822b:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80108230:	e9 b5 f2 ff ff       	jmp    801074ea <alltraps>

80108235 <vector182>:
.globl vector182
vector182:
  pushl $0
80108235:	6a 00                	push   $0x0
  pushl $182
80108237:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
8010823c:	e9 a9 f2 ff ff       	jmp    801074ea <alltraps>

80108241 <vector183>:
.globl vector183
vector183:
  pushl $0
80108241:	6a 00                	push   $0x0
  pushl $183
80108243:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80108248:	e9 9d f2 ff ff       	jmp    801074ea <alltraps>

8010824d <vector184>:
.globl vector184
vector184:
  pushl $0
8010824d:	6a 00                	push   $0x0
  pushl $184
8010824f:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80108254:	e9 91 f2 ff ff       	jmp    801074ea <alltraps>

80108259 <vector185>:
.globl vector185
vector185:
  pushl $0
80108259:	6a 00                	push   $0x0
  pushl $185
8010825b:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80108260:	e9 85 f2 ff ff       	jmp    801074ea <alltraps>

80108265 <vector186>:
.globl vector186
vector186:
  pushl $0
80108265:	6a 00                	push   $0x0
  pushl $186
80108267:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
8010826c:	e9 79 f2 ff ff       	jmp    801074ea <alltraps>

80108271 <vector187>:
.globl vector187
vector187:
  pushl $0
80108271:	6a 00                	push   $0x0
  pushl $187
80108273:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80108278:	e9 6d f2 ff ff       	jmp    801074ea <alltraps>

8010827d <vector188>:
.globl vector188
vector188:
  pushl $0
8010827d:	6a 00                	push   $0x0
  pushl $188
8010827f:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80108284:	e9 61 f2 ff ff       	jmp    801074ea <alltraps>

80108289 <vector189>:
.globl vector189
vector189:
  pushl $0
80108289:	6a 00                	push   $0x0
  pushl $189
8010828b:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80108290:	e9 55 f2 ff ff       	jmp    801074ea <alltraps>

80108295 <vector190>:
.globl vector190
vector190:
  pushl $0
80108295:	6a 00                	push   $0x0
  pushl $190
80108297:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
8010829c:	e9 49 f2 ff ff       	jmp    801074ea <alltraps>

801082a1 <vector191>:
.globl vector191
vector191:
  pushl $0
801082a1:	6a 00                	push   $0x0
  pushl $191
801082a3:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
801082a8:	e9 3d f2 ff ff       	jmp    801074ea <alltraps>

801082ad <vector192>:
.globl vector192
vector192:
  pushl $0
801082ad:	6a 00                	push   $0x0
  pushl $192
801082af:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
801082b4:	e9 31 f2 ff ff       	jmp    801074ea <alltraps>

801082b9 <vector193>:
.globl vector193
vector193:
  pushl $0
801082b9:	6a 00                	push   $0x0
  pushl $193
801082bb:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
801082c0:	e9 25 f2 ff ff       	jmp    801074ea <alltraps>

801082c5 <vector194>:
.globl vector194
vector194:
  pushl $0
801082c5:	6a 00                	push   $0x0
  pushl $194
801082c7:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
801082cc:	e9 19 f2 ff ff       	jmp    801074ea <alltraps>

801082d1 <vector195>:
.globl vector195
vector195:
  pushl $0
801082d1:	6a 00                	push   $0x0
  pushl $195
801082d3:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
801082d8:	e9 0d f2 ff ff       	jmp    801074ea <alltraps>

801082dd <vector196>:
.globl vector196
vector196:
  pushl $0
801082dd:	6a 00                	push   $0x0
  pushl $196
801082df:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
801082e4:	e9 01 f2 ff ff       	jmp    801074ea <alltraps>

801082e9 <vector197>:
.globl vector197
vector197:
  pushl $0
801082e9:	6a 00                	push   $0x0
  pushl $197
801082eb:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
801082f0:	e9 f5 f1 ff ff       	jmp    801074ea <alltraps>

801082f5 <vector198>:
.globl vector198
vector198:
  pushl $0
801082f5:	6a 00                	push   $0x0
  pushl $198
801082f7:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
801082fc:	e9 e9 f1 ff ff       	jmp    801074ea <alltraps>

80108301 <vector199>:
.globl vector199
vector199:
  pushl $0
80108301:	6a 00                	push   $0x0
  pushl $199
80108303:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80108308:	e9 dd f1 ff ff       	jmp    801074ea <alltraps>

8010830d <vector200>:
.globl vector200
vector200:
  pushl $0
8010830d:	6a 00                	push   $0x0
  pushl $200
8010830f:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80108314:	e9 d1 f1 ff ff       	jmp    801074ea <alltraps>

80108319 <vector201>:
.globl vector201
vector201:
  pushl $0
80108319:	6a 00                	push   $0x0
  pushl $201
8010831b:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80108320:	e9 c5 f1 ff ff       	jmp    801074ea <alltraps>

80108325 <vector202>:
.globl vector202
vector202:
  pushl $0
80108325:	6a 00                	push   $0x0
  pushl $202
80108327:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
8010832c:	e9 b9 f1 ff ff       	jmp    801074ea <alltraps>

80108331 <vector203>:
.globl vector203
vector203:
  pushl $0
80108331:	6a 00                	push   $0x0
  pushl $203
80108333:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80108338:	e9 ad f1 ff ff       	jmp    801074ea <alltraps>

8010833d <vector204>:
.globl vector204
vector204:
  pushl $0
8010833d:	6a 00                	push   $0x0
  pushl $204
8010833f:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80108344:	e9 a1 f1 ff ff       	jmp    801074ea <alltraps>

80108349 <vector205>:
.globl vector205
vector205:
  pushl $0
80108349:	6a 00                	push   $0x0
  pushl $205
8010834b:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80108350:	e9 95 f1 ff ff       	jmp    801074ea <alltraps>

80108355 <vector206>:
.globl vector206
vector206:
  pushl $0
80108355:	6a 00                	push   $0x0
  pushl $206
80108357:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
8010835c:	e9 89 f1 ff ff       	jmp    801074ea <alltraps>

80108361 <vector207>:
.globl vector207
vector207:
  pushl $0
80108361:	6a 00                	push   $0x0
  pushl $207
80108363:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80108368:	e9 7d f1 ff ff       	jmp    801074ea <alltraps>

8010836d <vector208>:
.globl vector208
vector208:
  pushl $0
8010836d:	6a 00                	push   $0x0
  pushl $208
8010836f:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80108374:	e9 71 f1 ff ff       	jmp    801074ea <alltraps>

80108379 <vector209>:
.globl vector209
vector209:
  pushl $0
80108379:	6a 00                	push   $0x0
  pushl $209
8010837b:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80108380:	e9 65 f1 ff ff       	jmp    801074ea <alltraps>

80108385 <vector210>:
.globl vector210
vector210:
  pushl $0
80108385:	6a 00                	push   $0x0
  pushl $210
80108387:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
8010838c:	e9 59 f1 ff ff       	jmp    801074ea <alltraps>

80108391 <vector211>:
.globl vector211
vector211:
  pushl $0
80108391:	6a 00                	push   $0x0
  pushl $211
80108393:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80108398:	e9 4d f1 ff ff       	jmp    801074ea <alltraps>

8010839d <vector212>:
.globl vector212
vector212:
  pushl $0
8010839d:	6a 00                	push   $0x0
  pushl $212
8010839f:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
801083a4:	e9 41 f1 ff ff       	jmp    801074ea <alltraps>

801083a9 <vector213>:
.globl vector213
vector213:
  pushl $0
801083a9:	6a 00                	push   $0x0
  pushl $213
801083ab:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
801083b0:	e9 35 f1 ff ff       	jmp    801074ea <alltraps>

801083b5 <vector214>:
.globl vector214
vector214:
  pushl $0
801083b5:	6a 00                	push   $0x0
  pushl $214
801083b7:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
801083bc:	e9 29 f1 ff ff       	jmp    801074ea <alltraps>

801083c1 <vector215>:
.globl vector215
vector215:
  pushl $0
801083c1:	6a 00                	push   $0x0
  pushl $215
801083c3:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
801083c8:	e9 1d f1 ff ff       	jmp    801074ea <alltraps>

801083cd <vector216>:
.globl vector216
vector216:
  pushl $0
801083cd:	6a 00                	push   $0x0
  pushl $216
801083cf:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
801083d4:	e9 11 f1 ff ff       	jmp    801074ea <alltraps>

801083d9 <vector217>:
.globl vector217
vector217:
  pushl $0
801083d9:	6a 00                	push   $0x0
  pushl $217
801083db:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
801083e0:	e9 05 f1 ff ff       	jmp    801074ea <alltraps>

801083e5 <vector218>:
.globl vector218
vector218:
  pushl $0
801083e5:	6a 00                	push   $0x0
  pushl $218
801083e7:	68 da 00 00 00       	push   $0xda
  jmp alltraps
801083ec:	e9 f9 f0 ff ff       	jmp    801074ea <alltraps>

801083f1 <vector219>:
.globl vector219
vector219:
  pushl $0
801083f1:	6a 00                	push   $0x0
  pushl $219
801083f3:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
801083f8:	e9 ed f0 ff ff       	jmp    801074ea <alltraps>

801083fd <vector220>:
.globl vector220
vector220:
  pushl $0
801083fd:	6a 00                	push   $0x0
  pushl $220
801083ff:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80108404:	e9 e1 f0 ff ff       	jmp    801074ea <alltraps>

80108409 <vector221>:
.globl vector221
vector221:
  pushl $0
80108409:	6a 00                	push   $0x0
  pushl $221
8010840b:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80108410:	e9 d5 f0 ff ff       	jmp    801074ea <alltraps>

80108415 <vector222>:
.globl vector222
vector222:
  pushl $0
80108415:	6a 00                	push   $0x0
  pushl $222
80108417:	68 de 00 00 00       	push   $0xde
  jmp alltraps
8010841c:	e9 c9 f0 ff ff       	jmp    801074ea <alltraps>

80108421 <vector223>:
.globl vector223
vector223:
  pushl $0
80108421:	6a 00                	push   $0x0
  pushl $223
80108423:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80108428:	e9 bd f0 ff ff       	jmp    801074ea <alltraps>

8010842d <vector224>:
.globl vector224
vector224:
  pushl $0
8010842d:	6a 00                	push   $0x0
  pushl $224
8010842f:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80108434:	e9 b1 f0 ff ff       	jmp    801074ea <alltraps>

80108439 <vector225>:
.globl vector225
vector225:
  pushl $0
80108439:	6a 00                	push   $0x0
  pushl $225
8010843b:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80108440:	e9 a5 f0 ff ff       	jmp    801074ea <alltraps>

80108445 <vector226>:
.globl vector226
vector226:
  pushl $0
80108445:	6a 00                	push   $0x0
  pushl $226
80108447:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
8010844c:	e9 99 f0 ff ff       	jmp    801074ea <alltraps>

80108451 <vector227>:
.globl vector227
vector227:
  pushl $0
80108451:	6a 00                	push   $0x0
  pushl $227
80108453:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80108458:	e9 8d f0 ff ff       	jmp    801074ea <alltraps>

8010845d <vector228>:
.globl vector228
vector228:
  pushl $0
8010845d:	6a 00                	push   $0x0
  pushl $228
8010845f:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80108464:	e9 81 f0 ff ff       	jmp    801074ea <alltraps>

80108469 <vector229>:
.globl vector229
vector229:
  pushl $0
80108469:	6a 00                	push   $0x0
  pushl $229
8010846b:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80108470:	e9 75 f0 ff ff       	jmp    801074ea <alltraps>

80108475 <vector230>:
.globl vector230
vector230:
  pushl $0
80108475:	6a 00                	push   $0x0
  pushl $230
80108477:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
8010847c:	e9 69 f0 ff ff       	jmp    801074ea <alltraps>

80108481 <vector231>:
.globl vector231
vector231:
  pushl $0
80108481:	6a 00                	push   $0x0
  pushl $231
80108483:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80108488:	e9 5d f0 ff ff       	jmp    801074ea <alltraps>

8010848d <vector232>:
.globl vector232
vector232:
  pushl $0
8010848d:	6a 00                	push   $0x0
  pushl $232
8010848f:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80108494:	e9 51 f0 ff ff       	jmp    801074ea <alltraps>

80108499 <vector233>:
.globl vector233
vector233:
  pushl $0
80108499:	6a 00                	push   $0x0
  pushl $233
8010849b:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
801084a0:	e9 45 f0 ff ff       	jmp    801074ea <alltraps>

801084a5 <vector234>:
.globl vector234
vector234:
  pushl $0
801084a5:	6a 00                	push   $0x0
  pushl $234
801084a7:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
801084ac:	e9 39 f0 ff ff       	jmp    801074ea <alltraps>

801084b1 <vector235>:
.globl vector235
vector235:
  pushl $0
801084b1:	6a 00                	push   $0x0
  pushl $235
801084b3:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
801084b8:	e9 2d f0 ff ff       	jmp    801074ea <alltraps>

801084bd <vector236>:
.globl vector236
vector236:
  pushl $0
801084bd:	6a 00                	push   $0x0
  pushl $236
801084bf:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
801084c4:	e9 21 f0 ff ff       	jmp    801074ea <alltraps>

801084c9 <vector237>:
.globl vector237
vector237:
  pushl $0
801084c9:	6a 00                	push   $0x0
  pushl $237
801084cb:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
801084d0:	e9 15 f0 ff ff       	jmp    801074ea <alltraps>

801084d5 <vector238>:
.globl vector238
vector238:
  pushl $0
801084d5:	6a 00                	push   $0x0
  pushl $238
801084d7:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
801084dc:	e9 09 f0 ff ff       	jmp    801074ea <alltraps>

801084e1 <vector239>:
.globl vector239
vector239:
  pushl $0
801084e1:	6a 00                	push   $0x0
  pushl $239
801084e3:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
801084e8:	e9 fd ef ff ff       	jmp    801074ea <alltraps>

801084ed <vector240>:
.globl vector240
vector240:
  pushl $0
801084ed:	6a 00                	push   $0x0
  pushl $240
801084ef:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
801084f4:	e9 f1 ef ff ff       	jmp    801074ea <alltraps>

801084f9 <vector241>:
.globl vector241
vector241:
  pushl $0
801084f9:	6a 00                	push   $0x0
  pushl $241
801084fb:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80108500:	e9 e5 ef ff ff       	jmp    801074ea <alltraps>

80108505 <vector242>:
.globl vector242
vector242:
  pushl $0
80108505:	6a 00                	push   $0x0
  pushl $242
80108507:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
8010850c:	e9 d9 ef ff ff       	jmp    801074ea <alltraps>

80108511 <vector243>:
.globl vector243
vector243:
  pushl $0
80108511:	6a 00                	push   $0x0
  pushl $243
80108513:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80108518:	e9 cd ef ff ff       	jmp    801074ea <alltraps>

8010851d <vector244>:
.globl vector244
vector244:
  pushl $0
8010851d:	6a 00                	push   $0x0
  pushl $244
8010851f:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80108524:	e9 c1 ef ff ff       	jmp    801074ea <alltraps>

80108529 <vector245>:
.globl vector245
vector245:
  pushl $0
80108529:	6a 00                	push   $0x0
  pushl $245
8010852b:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80108530:	e9 b5 ef ff ff       	jmp    801074ea <alltraps>

80108535 <vector246>:
.globl vector246
vector246:
  pushl $0
80108535:	6a 00                	push   $0x0
  pushl $246
80108537:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
8010853c:	e9 a9 ef ff ff       	jmp    801074ea <alltraps>

80108541 <vector247>:
.globl vector247
vector247:
  pushl $0
80108541:	6a 00                	push   $0x0
  pushl $247
80108543:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80108548:	e9 9d ef ff ff       	jmp    801074ea <alltraps>

8010854d <vector248>:
.globl vector248
vector248:
  pushl $0
8010854d:	6a 00                	push   $0x0
  pushl $248
8010854f:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80108554:	e9 91 ef ff ff       	jmp    801074ea <alltraps>

80108559 <vector249>:
.globl vector249
vector249:
  pushl $0
80108559:	6a 00                	push   $0x0
  pushl $249
8010855b:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80108560:	e9 85 ef ff ff       	jmp    801074ea <alltraps>

80108565 <vector250>:
.globl vector250
vector250:
  pushl $0
80108565:	6a 00                	push   $0x0
  pushl $250
80108567:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
8010856c:	e9 79 ef ff ff       	jmp    801074ea <alltraps>

80108571 <vector251>:
.globl vector251
vector251:
  pushl $0
80108571:	6a 00                	push   $0x0
  pushl $251
80108573:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80108578:	e9 6d ef ff ff       	jmp    801074ea <alltraps>

8010857d <vector252>:
.globl vector252
vector252:
  pushl $0
8010857d:	6a 00                	push   $0x0
  pushl $252
8010857f:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80108584:	e9 61 ef ff ff       	jmp    801074ea <alltraps>

80108589 <vector253>:
.globl vector253
vector253:
  pushl $0
80108589:	6a 00                	push   $0x0
  pushl $253
8010858b:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80108590:	e9 55 ef ff ff       	jmp    801074ea <alltraps>

80108595 <vector254>:
.globl vector254
vector254:
  pushl $0
80108595:	6a 00                	push   $0x0
  pushl $254
80108597:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
8010859c:	e9 49 ef ff ff       	jmp    801074ea <alltraps>

801085a1 <vector255>:
.globl vector255
vector255:
  pushl $0
801085a1:	6a 00                	push   $0x0
  pushl $255
801085a3:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
801085a8:	e9 3d ef ff ff       	jmp    801074ea <alltraps>

801085ad <lgdt>:

struct segdesc;

static inline void
lgdt(struct segdesc *p, int size)
{
801085ad:	55                   	push   %ebp
801085ae:	89 e5                	mov    %esp,%ebp
801085b0:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
801085b3:	8b 45 0c             	mov    0xc(%ebp),%eax
801085b6:	83 e8 01             	sub    $0x1,%eax
801085b9:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
801085bd:	8b 45 08             	mov    0x8(%ebp),%eax
801085c0:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
801085c4:	8b 45 08             	mov    0x8(%ebp),%eax
801085c7:	c1 e8 10             	shr    $0x10,%eax
801085ca:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lgdt (%0)" : : "r" (pd));
801085ce:	8d 45 fa             	lea    -0x6(%ebp),%eax
801085d1:	0f 01 10             	lgdtl  (%eax)
}
801085d4:	90                   	nop
801085d5:	c9                   	leave  
801085d6:	c3                   	ret    

801085d7 <ltr>:
  asm volatile("lidt (%0)" : : "r" (pd));
}

static inline void
ltr(ushort sel)
{
801085d7:	55                   	push   %ebp
801085d8:	89 e5                	mov    %esp,%ebp
801085da:	83 ec 04             	sub    $0x4,%esp
801085dd:	8b 45 08             	mov    0x8(%ebp),%eax
801085e0:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
801085e4:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801085e8:	0f 00 d8             	ltr    %ax
}
801085eb:	90                   	nop
801085ec:	c9                   	leave  
801085ed:	c3                   	ret    

801085ee <loadgs>:
  return eflags;
}

static inline void
loadgs(ushort v)
{
801085ee:	55                   	push   %ebp
801085ef:	89 e5                	mov    %esp,%ebp
801085f1:	83 ec 04             	sub    $0x4,%esp
801085f4:	8b 45 08             	mov    0x8(%ebp),%eax
801085f7:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("movw %0, %%gs" : : "r" (v));
801085fb:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801085ff:	8e e8                	mov    %eax,%gs
}
80108601:	90                   	nop
80108602:	c9                   	leave  
80108603:	c3                   	ret    

80108604 <lcr3>:
  return val;
}

static inline void
lcr3(uint val) 
{
80108604:	55                   	push   %ebp
80108605:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
80108607:	8b 45 08             	mov    0x8(%ebp),%eax
8010860a:	0f 22 d8             	mov    %eax,%cr3
}
8010860d:	90                   	nop
8010860e:	5d                   	pop    %ebp
8010860f:	c3                   	ret    

80108610 <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
80108610:	55                   	push   %ebp
80108611:	89 e5                	mov    %esp,%ebp
80108613:	8b 45 08             	mov    0x8(%ebp),%eax
80108616:	05 00 00 00 80       	add    $0x80000000,%eax
8010861b:	5d                   	pop    %ebp
8010861c:	c3                   	ret    

8010861d <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
8010861d:	55                   	push   %ebp
8010861e:	89 e5                	mov    %esp,%ebp
80108620:	8b 45 08             	mov    0x8(%ebp),%eax
80108623:	05 00 00 00 80       	add    $0x80000000,%eax
80108628:	5d                   	pop    %ebp
80108629:	c3                   	ret    

8010862a <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
8010862a:	55                   	push   %ebp
8010862b:	89 e5                	mov    %esp,%ebp
8010862d:	53                   	push   %ebx
8010862e:	83 ec 14             	sub    $0x14,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpunum()];
80108631:	e8 ab b1 ff ff       	call   801037e1 <cpunum>
80108636:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
8010863c:	05 80 38 11 80       	add    $0x80113880,%eax
80108641:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80108644:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108647:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
8010864d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108650:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
80108656:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108659:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
8010865d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108660:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80108664:	83 e2 f0             	and    $0xfffffff0,%edx
80108667:	83 ca 0a             	or     $0xa,%edx
8010866a:	88 50 7d             	mov    %dl,0x7d(%eax)
8010866d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108670:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80108674:	83 ca 10             	or     $0x10,%edx
80108677:	88 50 7d             	mov    %dl,0x7d(%eax)
8010867a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010867d:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80108681:	83 e2 9f             	and    $0xffffff9f,%edx
80108684:	88 50 7d             	mov    %dl,0x7d(%eax)
80108687:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010868a:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
8010868e:	83 ca 80             	or     $0xffffff80,%edx
80108691:	88 50 7d             	mov    %dl,0x7d(%eax)
80108694:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108697:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010869b:	83 ca 0f             	or     $0xf,%edx
8010869e:	88 50 7e             	mov    %dl,0x7e(%eax)
801086a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086a4:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801086a8:	83 e2 ef             	and    $0xffffffef,%edx
801086ab:	88 50 7e             	mov    %dl,0x7e(%eax)
801086ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086b1:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801086b5:	83 e2 df             	and    $0xffffffdf,%edx
801086b8:	88 50 7e             	mov    %dl,0x7e(%eax)
801086bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086be:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801086c2:	83 ca 40             	or     $0x40,%edx
801086c5:	88 50 7e             	mov    %dl,0x7e(%eax)
801086c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086cb:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801086cf:	83 ca 80             	or     $0xffffff80,%edx
801086d2:	88 50 7e             	mov    %dl,0x7e(%eax)
801086d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086d8:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
801086dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086df:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
801086e6:	ff ff 
801086e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086eb:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
801086f2:	00 00 
801086f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086f7:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
801086fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108701:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80108708:	83 e2 f0             	and    $0xfffffff0,%edx
8010870b:	83 ca 02             	or     $0x2,%edx
8010870e:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80108714:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108717:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
8010871e:	83 ca 10             	or     $0x10,%edx
80108721:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80108727:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010872a:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80108731:	83 e2 9f             	and    $0xffffff9f,%edx
80108734:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
8010873a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010873d:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80108744:	83 ca 80             	or     $0xffffff80,%edx
80108747:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
8010874d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108750:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80108757:	83 ca 0f             	or     $0xf,%edx
8010875a:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80108760:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108763:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010876a:	83 e2 ef             	and    $0xffffffef,%edx
8010876d:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80108773:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108776:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010877d:	83 e2 df             	and    $0xffffffdf,%edx
80108780:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80108786:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108789:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80108790:	83 ca 40             	or     $0x40,%edx
80108793:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80108799:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010879c:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801087a3:	83 ca 80             	or     $0xffffff80,%edx
801087a6:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801087ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087af:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
801087b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087b9:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
801087c0:	ff ff 
801087c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087c5:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
801087cc:	00 00 
801087ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087d1:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
801087d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087db:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801087e2:	83 e2 f0             	and    $0xfffffff0,%edx
801087e5:	83 ca 0a             	or     $0xa,%edx
801087e8:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801087ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087f1:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801087f8:	83 ca 10             	or     $0x10,%edx
801087fb:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80108801:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108804:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
8010880b:	83 ca 60             	or     $0x60,%edx
8010880e:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80108814:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108817:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
8010881e:	83 ca 80             	or     $0xffffff80,%edx
80108821:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80108827:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010882a:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80108831:	83 ca 0f             	or     $0xf,%edx
80108834:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010883a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010883d:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80108844:	83 e2 ef             	and    $0xffffffef,%edx
80108847:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010884d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108850:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80108857:	83 e2 df             	and    $0xffffffdf,%edx
8010885a:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80108860:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108863:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010886a:	83 ca 40             	or     $0x40,%edx
8010886d:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80108873:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108876:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010887d:	83 ca 80             	or     $0xffffff80,%edx
80108880:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80108886:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108889:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80108890:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108893:	66 c7 80 98 00 00 00 	movw   $0xffff,0x98(%eax)
8010889a:	ff ff 
8010889c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010889f:	66 c7 80 9a 00 00 00 	movw   $0x0,0x9a(%eax)
801088a6:	00 00 
801088a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088ab:	c6 80 9c 00 00 00 00 	movb   $0x0,0x9c(%eax)
801088b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088b5:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
801088bc:	83 e2 f0             	and    $0xfffffff0,%edx
801088bf:	83 ca 02             	or     $0x2,%edx
801088c2:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
801088c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088cb:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
801088d2:	83 ca 10             	or     $0x10,%edx
801088d5:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
801088db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088de:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
801088e5:	83 ca 60             	or     $0x60,%edx
801088e8:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
801088ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088f1:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
801088f8:	83 ca 80             	or     $0xffffff80,%edx
801088fb:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80108901:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108904:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
8010890b:	83 ca 0f             	or     $0xf,%edx
8010890e:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80108914:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108917:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
8010891e:	83 e2 ef             	and    $0xffffffef,%edx
80108921:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80108927:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010892a:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80108931:	83 e2 df             	and    $0xffffffdf,%edx
80108934:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
8010893a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010893d:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80108944:	83 ca 40             	or     $0x40,%edx
80108947:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
8010894d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108950:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80108957:	83 ca 80             	or     $0xffffff80,%edx
8010895a:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80108960:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108963:	c6 80 9f 00 00 00 00 	movb   $0x0,0x9f(%eax)

  // Map cpu, and curproc
  c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);
8010896a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010896d:	05 b4 00 00 00       	add    $0xb4,%eax
80108972:	89 c3                	mov    %eax,%ebx
80108974:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108977:	05 b4 00 00 00       	add    $0xb4,%eax
8010897c:	c1 e8 10             	shr    $0x10,%eax
8010897f:	89 c2                	mov    %eax,%edx
80108981:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108984:	05 b4 00 00 00       	add    $0xb4,%eax
80108989:	c1 e8 18             	shr    $0x18,%eax
8010898c:	89 c1                	mov    %eax,%ecx
8010898e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108991:	66 c7 80 88 00 00 00 	movw   $0x0,0x88(%eax)
80108998:	00 00 
8010899a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010899d:	66 89 98 8a 00 00 00 	mov    %bx,0x8a(%eax)
801089a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089a7:	88 90 8c 00 00 00    	mov    %dl,0x8c(%eax)
801089ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089b0:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
801089b7:	83 e2 f0             	and    $0xfffffff0,%edx
801089ba:	83 ca 02             	or     $0x2,%edx
801089bd:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801089c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089c6:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
801089cd:	83 ca 10             	or     $0x10,%edx
801089d0:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801089d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089d9:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
801089e0:	83 e2 9f             	and    $0xffffff9f,%edx
801089e3:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801089e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089ec:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
801089f3:	83 ca 80             	or     $0xffffff80,%edx
801089f6:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801089fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089ff:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80108a06:	83 e2 f0             	and    $0xfffffff0,%edx
80108a09:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80108a0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a12:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80108a19:	83 e2 ef             	and    $0xffffffef,%edx
80108a1c:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80108a22:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a25:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80108a2c:	83 e2 df             	and    $0xffffffdf,%edx
80108a2f:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80108a35:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a38:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80108a3f:	83 ca 40             	or     $0x40,%edx
80108a42:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80108a48:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a4b:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80108a52:	83 ca 80             	or     $0xffffff80,%edx
80108a55:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80108a5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a5e:	88 88 8f 00 00 00    	mov    %cl,0x8f(%eax)

  lgdt(c->gdt, sizeof(c->gdt));
80108a64:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a67:	83 c0 70             	add    $0x70,%eax
80108a6a:	83 ec 08             	sub    $0x8,%esp
80108a6d:	6a 38                	push   $0x38
80108a6f:	50                   	push   %eax
80108a70:	e8 38 fb ff ff       	call   801085ad <lgdt>
80108a75:	83 c4 10             	add    $0x10,%esp
  loadgs(SEG_KCPU << 3);
80108a78:	83 ec 0c             	sub    $0xc,%esp
80108a7b:	6a 18                	push   $0x18
80108a7d:	e8 6c fb ff ff       	call   801085ee <loadgs>
80108a82:	83 c4 10             	add    $0x10,%esp
  
  // Initialize cpu-local storage.
  cpu = c;
80108a85:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a88:	65 a3 00 00 00 00    	mov    %eax,%gs:0x0
  proc = 0;
80108a8e:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80108a95:	00 00 00 00 
}
80108a99:	90                   	nop
80108a9a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108a9d:	c9                   	leave  
80108a9e:	c3                   	ret    

80108a9f <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80108a9f:	55                   	push   %ebp
80108aa0:	89 e5                	mov    %esp,%ebp
80108aa2:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80108aa5:	8b 45 0c             	mov    0xc(%ebp),%eax
80108aa8:	c1 e8 16             	shr    $0x16,%eax
80108aab:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108ab2:	8b 45 08             	mov    0x8(%ebp),%eax
80108ab5:	01 d0                	add    %edx,%eax
80108ab7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
80108aba:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108abd:	8b 00                	mov    (%eax),%eax
80108abf:	83 e0 01             	and    $0x1,%eax
80108ac2:	85 c0                	test   %eax,%eax
80108ac4:	74 18                	je     80108ade <walkpgdir+0x3f>
    pgtab = (pte_t*)p2v(PTE_ADDR(*pde));
80108ac6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108ac9:	8b 00                	mov    (%eax),%eax
80108acb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108ad0:	50                   	push   %eax
80108ad1:	e8 47 fb ff ff       	call   8010861d <p2v>
80108ad6:	83 c4 04             	add    $0x4,%esp
80108ad9:	89 45 f4             	mov    %eax,-0xc(%ebp)
80108adc:	eb 48                	jmp    80108b26 <walkpgdir+0x87>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80108ade:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80108ae2:	74 0e                	je     80108af2 <walkpgdir+0x53>
80108ae4:	e8 92 a9 ff ff       	call   8010347b <kalloc>
80108ae9:	89 45 f4             	mov    %eax,-0xc(%ebp)
80108aec:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80108af0:	75 07                	jne    80108af9 <walkpgdir+0x5a>
      return 0;
80108af2:	b8 00 00 00 00       	mov    $0x0,%eax
80108af7:	eb 44                	jmp    80108b3d <walkpgdir+0x9e>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80108af9:	83 ec 04             	sub    $0x4,%esp
80108afc:	68 00 10 00 00       	push   $0x1000
80108b01:	6a 00                	push   $0x0
80108b03:	ff 75 f4             	pushl  -0xc(%ebp)
80108b06:	e8 e8 d2 ff ff       	call   80105df3 <memset>
80108b0b:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table 
    // entries, if necessary.
    *pde = v2p(pgtab) | PTE_P | PTE_W | PTE_U;
80108b0e:	83 ec 0c             	sub    $0xc,%esp
80108b11:	ff 75 f4             	pushl  -0xc(%ebp)
80108b14:	e8 f7 fa ff ff       	call   80108610 <v2p>
80108b19:	83 c4 10             	add    $0x10,%esp
80108b1c:	83 c8 07             	or     $0x7,%eax
80108b1f:	89 c2                	mov    %eax,%edx
80108b21:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108b24:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80108b26:	8b 45 0c             	mov    0xc(%ebp),%eax
80108b29:	c1 e8 0c             	shr    $0xc,%eax
80108b2c:	25 ff 03 00 00       	and    $0x3ff,%eax
80108b31:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108b38:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b3b:	01 d0                	add    %edx,%eax
}
80108b3d:	c9                   	leave  
80108b3e:	c3                   	ret    

80108b3f <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80108b3f:	55                   	push   %ebp
80108b40:	89 e5                	mov    %esp,%ebp
80108b42:	83 ec 18             	sub    $0x18,%esp
  char *a, *last;
  pte_t *pte;
  
  a = (char*)PGROUNDDOWN((uint)va);
80108b45:	8b 45 0c             	mov    0xc(%ebp),%eax
80108b48:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108b4d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80108b50:	8b 55 0c             	mov    0xc(%ebp),%edx
80108b53:	8b 45 10             	mov    0x10(%ebp),%eax
80108b56:	01 d0                	add    %edx,%eax
80108b58:	83 e8 01             	sub    $0x1,%eax
80108b5b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108b60:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80108b63:	83 ec 04             	sub    $0x4,%esp
80108b66:	6a 01                	push   $0x1
80108b68:	ff 75 f4             	pushl  -0xc(%ebp)
80108b6b:	ff 75 08             	pushl  0x8(%ebp)
80108b6e:	e8 2c ff ff ff       	call   80108a9f <walkpgdir>
80108b73:	83 c4 10             	add    $0x10,%esp
80108b76:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108b79:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108b7d:	75 07                	jne    80108b86 <mappages+0x47>
      return -1;
80108b7f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108b84:	eb 47                	jmp    80108bcd <mappages+0x8e>
    if(*pte & PTE_P)
80108b86:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108b89:	8b 00                	mov    (%eax),%eax
80108b8b:	83 e0 01             	and    $0x1,%eax
80108b8e:	85 c0                	test   %eax,%eax
80108b90:	74 0d                	je     80108b9f <mappages+0x60>
      panic("remap");
80108b92:	83 ec 0c             	sub    $0xc,%esp
80108b95:	68 c0 9a 10 80       	push   $0x80109ac0
80108b9a:	e8 c7 79 ff ff       	call   80100566 <panic>
    *pte = pa | perm | PTE_P;
80108b9f:	8b 45 18             	mov    0x18(%ebp),%eax
80108ba2:	0b 45 14             	or     0x14(%ebp),%eax
80108ba5:	83 c8 01             	or     $0x1,%eax
80108ba8:	89 c2                	mov    %eax,%edx
80108baa:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108bad:	89 10                	mov    %edx,(%eax)
    if(a == last)
80108baf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108bb2:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80108bb5:	74 10                	je     80108bc7 <mappages+0x88>
      break;
    a += PGSIZE;
80108bb7:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
80108bbe:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  }
80108bc5:	eb 9c                	jmp    80108b63 <mappages+0x24>
      return -1;
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
    if(a == last)
      break;
80108bc7:	90                   	nop
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
80108bc8:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108bcd:	c9                   	leave  
80108bce:	c3                   	ret    

80108bcf <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
80108bcf:	55                   	push   %ebp
80108bd0:	89 e5                	mov    %esp,%ebp
80108bd2:	53                   	push   %ebx
80108bd3:	83 ec 14             	sub    $0x14,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
80108bd6:	e8 a0 a8 ff ff       	call   8010347b <kalloc>
80108bdb:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108bde:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108be2:	75 0a                	jne    80108bee <setupkvm+0x1f>
    return 0;
80108be4:	b8 00 00 00 00       	mov    $0x0,%eax
80108be9:	e9 8e 00 00 00       	jmp    80108c7c <setupkvm+0xad>
  memset(pgdir, 0, PGSIZE);
80108bee:	83 ec 04             	sub    $0x4,%esp
80108bf1:	68 00 10 00 00       	push   $0x1000
80108bf6:	6a 00                	push   $0x0
80108bf8:	ff 75 f0             	pushl  -0x10(%ebp)
80108bfb:	e8 f3 d1 ff ff       	call   80105df3 <memset>
80108c00:	83 c4 10             	add    $0x10,%esp
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
80108c03:	83 ec 0c             	sub    $0xc,%esp
80108c06:	68 00 00 00 0e       	push   $0xe000000
80108c0b:	e8 0d fa ff ff       	call   8010861d <p2v>
80108c10:	83 c4 10             	add    $0x10,%esp
80108c13:	3d 00 00 00 fe       	cmp    $0xfe000000,%eax
80108c18:	76 0d                	jbe    80108c27 <setupkvm+0x58>
    panic("PHYSTOP too high");
80108c1a:	83 ec 0c             	sub    $0xc,%esp
80108c1d:	68 c6 9a 10 80       	push   $0x80109ac6
80108c22:	e8 3f 79 ff ff       	call   80100566 <panic>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80108c27:	c7 45 f4 a0 c4 10 80 	movl   $0x8010c4a0,-0xc(%ebp)
80108c2e:	eb 40                	jmp    80108c70 <setupkvm+0xa1>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
80108c30:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c33:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0)
80108c36:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c39:	8b 50 04             	mov    0x4(%eax),%edx
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
80108c3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c3f:	8b 58 08             	mov    0x8(%eax),%ebx
80108c42:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c45:	8b 40 04             	mov    0x4(%eax),%eax
80108c48:	29 c3                	sub    %eax,%ebx
80108c4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c4d:	8b 00                	mov    (%eax),%eax
80108c4f:	83 ec 0c             	sub    $0xc,%esp
80108c52:	51                   	push   %ecx
80108c53:	52                   	push   %edx
80108c54:	53                   	push   %ebx
80108c55:	50                   	push   %eax
80108c56:	ff 75 f0             	pushl  -0x10(%ebp)
80108c59:	e8 e1 fe ff ff       	call   80108b3f <mappages>
80108c5e:	83 c4 20             	add    $0x20,%esp
80108c61:	85 c0                	test   %eax,%eax
80108c63:	79 07                	jns    80108c6c <setupkvm+0x9d>
                (uint)k->phys_start, k->perm) < 0)
      return 0;
80108c65:	b8 00 00 00 00       	mov    $0x0,%eax
80108c6a:	eb 10                	jmp    80108c7c <setupkvm+0xad>
  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80108c6c:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80108c70:	81 7d f4 e0 c4 10 80 	cmpl   $0x8010c4e0,-0xc(%ebp)
80108c77:	72 b7                	jb     80108c30 <setupkvm+0x61>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
                (uint)k->phys_start, k->perm) < 0)
      return 0;
  return pgdir;
80108c79:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80108c7c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108c7f:	c9                   	leave  
80108c80:	c3                   	ret    

80108c81 <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80108c81:	55                   	push   %ebp
80108c82:	89 e5                	mov    %esp,%ebp
80108c84:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80108c87:	e8 43 ff ff ff       	call   80108bcf <setupkvm>
80108c8c:	a3 58 66 11 80       	mov    %eax,0x80116658
  switchkvm();
80108c91:	e8 03 00 00 00       	call   80108c99 <switchkvm>
}
80108c96:	90                   	nop
80108c97:	c9                   	leave  
80108c98:	c3                   	ret    

80108c99 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80108c99:	55                   	push   %ebp
80108c9a:	89 e5                	mov    %esp,%ebp
  lcr3(v2p(kpgdir));   // switch to the kernel page table
80108c9c:	a1 58 66 11 80       	mov    0x80116658,%eax
80108ca1:	50                   	push   %eax
80108ca2:	e8 69 f9 ff ff       	call   80108610 <v2p>
80108ca7:	83 c4 04             	add    $0x4,%esp
80108caa:	50                   	push   %eax
80108cab:	e8 54 f9 ff ff       	call   80108604 <lcr3>
80108cb0:	83 c4 04             	add    $0x4,%esp
}
80108cb3:	90                   	nop
80108cb4:	c9                   	leave  
80108cb5:	c3                   	ret    

80108cb6 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80108cb6:	55                   	push   %ebp
80108cb7:	89 e5                	mov    %esp,%ebp
80108cb9:	56                   	push   %esi
80108cba:	53                   	push   %ebx
  pushcli();
80108cbb:	e8 2d d0 ff ff       	call   80105ced <pushcli>
  cpu->gdt[SEG_TSS] = SEG16(STS_T32A, &cpu->ts, sizeof(cpu->ts)-1, 0);
80108cc0:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108cc6:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80108ccd:	83 c2 08             	add    $0x8,%edx
80108cd0:	89 d6                	mov    %edx,%esi
80108cd2:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80108cd9:	83 c2 08             	add    $0x8,%edx
80108cdc:	c1 ea 10             	shr    $0x10,%edx
80108cdf:	89 d3                	mov    %edx,%ebx
80108ce1:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80108ce8:	83 c2 08             	add    $0x8,%edx
80108ceb:	c1 ea 18             	shr    $0x18,%edx
80108cee:	89 d1                	mov    %edx,%ecx
80108cf0:	66 c7 80 a0 00 00 00 	movw   $0x67,0xa0(%eax)
80108cf7:	67 00 
80108cf9:	66 89 b0 a2 00 00 00 	mov    %si,0xa2(%eax)
80108d00:	88 98 a4 00 00 00    	mov    %bl,0xa4(%eax)
80108d06:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108d0d:	83 e2 f0             	and    $0xfffffff0,%edx
80108d10:	83 ca 09             	or     $0x9,%edx
80108d13:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80108d19:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108d20:	83 ca 10             	or     $0x10,%edx
80108d23:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80108d29:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108d30:	83 e2 9f             	and    $0xffffff9f,%edx
80108d33:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80108d39:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108d40:	83 ca 80             	or     $0xffffff80,%edx
80108d43:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80108d49:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80108d50:	83 e2 f0             	and    $0xfffffff0,%edx
80108d53:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80108d59:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80108d60:	83 e2 ef             	and    $0xffffffef,%edx
80108d63:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80108d69:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80108d70:	83 e2 df             	and    $0xffffffdf,%edx
80108d73:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80108d79:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80108d80:	83 ca 40             	or     $0x40,%edx
80108d83:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80108d89:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80108d90:	83 e2 7f             	and    $0x7f,%edx
80108d93:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80108d99:	88 88 a7 00 00 00    	mov    %cl,0xa7(%eax)
  cpu->gdt[SEG_TSS].s = 0;
80108d9f:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108da5:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108dac:	83 e2 ef             	and    $0xffffffef,%edx
80108daf:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
  cpu->ts.ss0 = SEG_KDATA << 3;
80108db5:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108dbb:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  cpu->ts.esp0 = (uint)proc->kstack + KSTACKSIZE;
80108dc1:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108dc7:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80108dce:	8b 52 08             	mov    0x8(%edx),%edx
80108dd1:	81 c2 00 10 00 00    	add    $0x1000,%edx
80108dd7:	89 50 0c             	mov    %edx,0xc(%eax)
  ltr(SEG_TSS << 3);
80108dda:	83 ec 0c             	sub    $0xc,%esp
80108ddd:	6a 30                	push   $0x30
80108ddf:	e8 f3 f7 ff ff       	call   801085d7 <ltr>
80108de4:	83 c4 10             	add    $0x10,%esp
  if(p->pgdir == 0)
80108de7:	8b 45 08             	mov    0x8(%ebp),%eax
80108dea:	8b 40 04             	mov    0x4(%eax),%eax
80108ded:	85 c0                	test   %eax,%eax
80108def:	75 0d                	jne    80108dfe <switchuvm+0x148>
    panic("switchuvm: no pgdir");
80108df1:	83 ec 0c             	sub    $0xc,%esp
80108df4:	68 d7 9a 10 80       	push   $0x80109ad7
80108df9:	e8 68 77 ff ff       	call   80100566 <panic>
  lcr3(v2p(p->pgdir));  // switch to new address space
80108dfe:	8b 45 08             	mov    0x8(%ebp),%eax
80108e01:	8b 40 04             	mov    0x4(%eax),%eax
80108e04:	83 ec 0c             	sub    $0xc,%esp
80108e07:	50                   	push   %eax
80108e08:	e8 03 f8 ff ff       	call   80108610 <v2p>
80108e0d:	83 c4 10             	add    $0x10,%esp
80108e10:	83 ec 0c             	sub    $0xc,%esp
80108e13:	50                   	push   %eax
80108e14:	e8 eb f7 ff ff       	call   80108604 <lcr3>
80108e19:	83 c4 10             	add    $0x10,%esp
  popcli();
80108e1c:	e8 11 cf ff ff       	call   80105d32 <popcli>
}
80108e21:	90                   	nop
80108e22:	8d 65 f8             	lea    -0x8(%ebp),%esp
80108e25:	5b                   	pop    %ebx
80108e26:	5e                   	pop    %esi
80108e27:	5d                   	pop    %ebp
80108e28:	c3                   	ret    

80108e29 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80108e29:	55                   	push   %ebp
80108e2a:	89 e5                	mov    %esp,%ebp
80108e2c:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  
  if(sz >= PGSIZE)
80108e2f:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80108e36:	76 0d                	jbe    80108e45 <inituvm+0x1c>
    panic("inituvm: more than a page");
80108e38:	83 ec 0c             	sub    $0xc,%esp
80108e3b:	68 eb 9a 10 80       	push   $0x80109aeb
80108e40:	e8 21 77 ff ff       	call   80100566 <panic>
  mem = kalloc();
80108e45:	e8 31 a6 ff ff       	call   8010347b <kalloc>
80108e4a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80108e4d:	83 ec 04             	sub    $0x4,%esp
80108e50:	68 00 10 00 00       	push   $0x1000
80108e55:	6a 00                	push   $0x0
80108e57:	ff 75 f4             	pushl  -0xc(%ebp)
80108e5a:	e8 94 cf ff ff       	call   80105df3 <memset>
80108e5f:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, v2p(mem), PTE_W|PTE_U);
80108e62:	83 ec 0c             	sub    $0xc,%esp
80108e65:	ff 75 f4             	pushl  -0xc(%ebp)
80108e68:	e8 a3 f7 ff ff       	call   80108610 <v2p>
80108e6d:	83 c4 10             	add    $0x10,%esp
80108e70:	83 ec 0c             	sub    $0xc,%esp
80108e73:	6a 06                	push   $0x6
80108e75:	50                   	push   %eax
80108e76:	68 00 10 00 00       	push   $0x1000
80108e7b:	6a 00                	push   $0x0
80108e7d:	ff 75 08             	pushl  0x8(%ebp)
80108e80:	e8 ba fc ff ff       	call   80108b3f <mappages>
80108e85:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
80108e88:	83 ec 04             	sub    $0x4,%esp
80108e8b:	ff 75 10             	pushl  0x10(%ebp)
80108e8e:	ff 75 0c             	pushl  0xc(%ebp)
80108e91:	ff 75 f4             	pushl  -0xc(%ebp)
80108e94:	e8 19 d0 ff ff       	call   80105eb2 <memmove>
80108e99:	83 c4 10             	add    $0x10,%esp
}
80108e9c:	90                   	nop
80108e9d:	c9                   	leave  
80108e9e:	c3                   	ret    

80108e9f <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80108e9f:	55                   	push   %ebp
80108ea0:	89 e5                	mov    %esp,%ebp
80108ea2:	53                   	push   %ebx
80108ea3:	83 ec 14             	sub    $0x14,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80108ea6:	8b 45 0c             	mov    0xc(%ebp),%eax
80108ea9:	25 ff 0f 00 00       	and    $0xfff,%eax
80108eae:	85 c0                	test   %eax,%eax
80108eb0:	74 0d                	je     80108ebf <loaduvm+0x20>
    panic("loaduvm: addr must be page aligned");
80108eb2:	83 ec 0c             	sub    $0xc,%esp
80108eb5:	68 08 9b 10 80       	push   $0x80109b08
80108eba:	e8 a7 76 ff ff       	call   80100566 <panic>
  for(i = 0; i < sz; i += PGSIZE){
80108ebf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108ec6:	e9 95 00 00 00       	jmp    80108f60 <loaduvm+0xc1>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80108ecb:	8b 55 0c             	mov    0xc(%ebp),%edx
80108ece:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ed1:	01 d0                	add    %edx,%eax
80108ed3:	83 ec 04             	sub    $0x4,%esp
80108ed6:	6a 00                	push   $0x0
80108ed8:	50                   	push   %eax
80108ed9:	ff 75 08             	pushl  0x8(%ebp)
80108edc:	e8 be fb ff ff       	call   80108a9f <walkpgdir>
80108ee1:	83 c4 10             	add    $0x10,%esp
80108ee4:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108ee7:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108eeb:	75 0d                	jne    80108efa <loaduvm+0x5b>
      panic("loaduvm: address should exist");
80108eed:	83 ec 0c             	sub    $0xc,%esp
80108ef0:	68 2b 9b 10 80       	push   $0x80109b2b
80108ef5:	e8 6c 76 ff ff       	call   80100566 <panic>
    pa = PTE_ADDR(*pte);
80108efa:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108efd:	8b 00                	mov    (%eax),%eax
80108eff:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108f04:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80108f07:	8b 45 18             	mov    0x18(%ebp),%eax
80108f0a:	2b 45 f4             	sub    -0xc(%ebp),%eax
80108f0d:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80108f12:	77 0b                	ja     80108f1f <loaduvm+0x80>
      n = sz - i;
80108f14:	8b 45 18             	mov    0x18(%ebp),%eax
80108f17:	2b 45 f4             	sub    -0xc(%ebp),%eax
80108f1a:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108f1d:	eb 07                	jmp    80108f26 <loaduvm+0x87>
    else
      n = PGSIZE;
80108f1f:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, p2v(pa), offset+i, n) != n)
80108f26:	8b 55 14             	mov    0x14(%ebp),%edx
80108f29:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f2c:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80108f2f:	83 ec 0c             	sub    $0xc,%esp
80108f32:	ff 75 e8             	pushl  -0x18(%ebp)
80108f35:	e8 e3 f6 ff ff       	call   8010861d <p2v>
80108f3a:	83 c4 10             	add    $0x10,%esp
80108f3d:	ff 75 f0             	pushl  -0x10(%ebp)
80108f40:	53                   	push   %ebx
80108f41:	50                   	push   %eax
80108f42:	ff 75 10             	pushl  0x10(%ebp)
80108f45:	e8 36 96 ff ff       	call   80102580 <readi>
80108f4a:	83 c4 10             	add    $0x10,%esp
80108f4d:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80108f50:	74 07                	je     80108f59 <loaduvm+0xba>
      return -1;
80108f52:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108f57:	eb 18                	jmp    80108f71 <loaduvm+0xd2>
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
80108f59:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108f60:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f63:	3b 45 18             	cmp    0x18(%ebp),%eax
80108f66:	0f 82 5f ff ff ff    	jb     80108ecb <loaduvm+0x2c>
    else
      n = PGSIZE;
    if(readi(ip, p2v(pa), offset+i, n) != n)
      return -1;
  }
  return 0;
80108f6c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108f71:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108f74:	c9                   	leave  
80108f75:	c3                   	ret    

80108f76 <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80108f76:	55                   	push   %ebp
80108f77:	89 e5                	mov    %esp,%ebp
80108f79:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
80108f7c:	8b 45 10             	mov    0x10(%ebp),%eax
80108f7f:	85 c0                	test   %eax,%eax
80108f81:	79 0a                	jns    80108f8d <allocuvm+0x17>
    return 0;
80108f83:	b8 00 00 00 00       	mov    $0x0,%eax
80108f88:	e9 b0 00 00 00       	jmp    8010903d <allocuvm+0xc7>
  if(newsz < oldsz)
80108f8d:	8b 45 10             	mov    0x10(%ebp),%eax
80108f90:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108f93:	73 08                	jae    80108f9d <allocuvm+0x27>
    return oldsz;
80108f95:	8b 45 0c             	mov    0xc(%ebp),%eax
80108f98:	e9 a0 00 00 00       	jmp    8010903d <allocuvm+0xc7>

  a = PGROUNDUP(oldsz);
80108f9d:	8b 45 0c             	mov    0xc(%ebp),%eax
80108fa0:	05 ff 0f 00 00       	add    $0xfff,%eax
80108fa5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108faa:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
80108fad:	eb 7f                	jmp    8010902e <allocuvm+0xb8>
    mem = kalloc();
80108faf:	e8 c7 a4 ff ff       	call   8010347b <kalloc>
80108fb4:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
80108fb7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108fbb:	75 2b                	jne    80108fe8 <allocuvm+0x72>
      cprintf("allocuvm out of memory\n");
80108fbd:	83 ec 0c             	sub    $0xc,%esp
80108fc0:	68 49 9b 10 80       	push   $0x80109b49
80108fc5:	e8 fc 73 ff ff       	call   801003c6 <cprintf>
80108fca:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80108fcd:	83 ec 04             	sub    $0x4,%esp
80108fd0:	ff 75 0c             	pushl  0xc(%ebp)
80108fd3:	ff 75 10             	pushl  0x10(%ebp)
80108fd6:	ff 75 08             	pushl  0x8(%ebp)
80108fd9:	e8 61 00 00 00       	call   8010903f <deallocuvm>
80108fde:	83 c4 10             	add    $0x10,%esp
      return 0;
80108fe1:	b8 00 00 00 00       	mov    $0x0,%eax
80108fe6:	eb 55                	jmp    8010903d <allocuvm+0xc7>
    }
    memset(mem, 0, PGSIZE);
80108fe8:	83 ec 04             	sub    $0x4,%esp
80108feb:	68 00 10 00 00       	push   $0x1000
80108ff0:	6a 00                	push   $0x0
80108ff2:	ff 75 f0             	pushl  -0x10(%ebp)
80108ff5:	e8 f9 cd ff ff       	call   80105df3 <memset>
80108ffa:	83 c4 10             	add    $0x10,%esp
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
80108ffd:	83 ec 0c             	sub    $0xc,%esp
80109000:	ff 75 f0             	pushl  -0x10(%ebp)
80109003:	e8 08 f6 ff ff       	call   80108610 <v2p>
80109008:	83 c4 10             	add    $0x10,%esp
8010900b:	89 c2                	mov    %eax,%edx
8010900d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109010:	83 ec 0c             	sub    $0xc,%esp
80109013:	6a 06                	push   $0x6
80109015:	52                   	push   %edx
80109016:	68 00 10 00 00       	push   $0x1000
8010901b:	50                   	push   %eax
8010901c:	ff 75 08             	pushl  0x8(%ebp)
8010901f:	e8 1b fb ff ff       	call   80108b3f <mappages>
80109024:	83 c4 20             	add    $0x20,%esp
    return 0;
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){
80109027:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010902e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109031:	3b 45 10             	cmp    0x10(%ebp),%eax
80109034:	0f 82 75 ff ff ff    	jb     80108faf <allocuvm+0x39>
      return 0;
    }
    memset(mem, 0, PGSIZE);
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
  }
  return newsz;
8010903a:	8b 45 10             	mov    0x10(%ebp),%eax
}
8010903d:	c9                   	leave  
8010903e:	c3                   	ret    

8010903f <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
8010903f:	55                   	push   %ebp
80109040:	89 e5                	mov    %esp,%ebp
80109042:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80109045:	8b 45 10             	mov    0x10(%ebp),%eax
80109048:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010904b:	72 08                	jb     80109055 <deallocuvm+0x16>
    return oldsz;
8010904d:	8b 45 0c             	mov    0xc(%ebp),%eax
80109050:	e9 a5 00 00 00       	jmp    801090fa <deallocuvm+0xbb>

  a = PGROUNDUP(newsz);
80109055:	8b 45 10             	mov    0x10(%ebp),%eax
80109058:	05 ff 0f 00 00       	add    $0xfff,%eax
8010905d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109062:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80109065:	e9 81 00 00 00       	jmp    801090eb <deallocuvm+0xac>
    pte = walkpgdir(pgdir, (char*)a, 0);
8010906a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010906d:	83 ec 04             	sub    $0x4,%esp
80109070:	6a 00                	push   $0x0
80109072:	50                   	push   %eax
80109073:	ff 75 08             	pushl  0x8(%ebp)
80109076:	e8 24 fa ff ff       	call   80108a9f <walkpgdir>
8010907b:	83 c4 10             	add    $0x10,%esp
8010907e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
80109081:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80109085:	75 09                	jne    80109090 <deallocuvm+0x51>
      a += (NPTENTRIES - 1) * PGSIZE;
80109087:	81 45 f4 00 f0 3f 00 	addl   $0x3ff000,-0xc(%ebp)
8010908e:	eb 54                	jmp    801090e4 <deallocuvm+0xa5>
    else if((*pte & PTE_P) != 0){
80109090:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109093:	8b 00                	mov    (%eax),%eax
80109095:	83 e0 01             	and    $0x1,%eax
80109098:	85 c0                	test   %eax,%eax
8010909a:	74 48                	je     801090e4 <deallocuvm+0xa5>
      pa = PTE_ADDR(*pte);
8010909c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010909f:	8b 00                	mov    (%eax),%eax
801090a1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801090a6:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
801090a9:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801090ad:	75 0d                	jne    801090bc <deallocuvm+0x7d>
        panic("kfree");
801090af:	83 ec 0c             	sub    $0xc,%esp
801090b2:	68 61 9b 10 80       	push   $0x80109b61
801090b7:	e8 aa 74 ff ff       	call   80100566 <panic>
      char *v = p2v(pa);
801090bc:	83 ec 0c             	sub    $0xc,%esp
801090bf:	ff 75 ec             	pushl  -0x14(%ebp)
801090c2:	e8 56 f5 ff ff       	call   8010861d <p2v>
801090c7:	83 c4 10             	add    $0x10,%esp
801090ca:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
801090cd:	83 ec 0c             	sub    $0xc,%esp
801090d0:	ff 75 e8             	pushl  -0x18(%ebp)
801090d3:	e8 06 a3 ff ff       	call   801033de <kfree>
801090d8:	83 c4 10             	add    $0x10,%esp
      *pte = 0;
801090db:	8b 45 f0             	mov    -0x10(%ebp),%eax
801090de:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
801090e4:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801090eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801090ee:	3b 45 0c             	cmp    0xc(%ebp),%eax
801090f1:	0f 82 73 ff ff ff    	jb     8010906a <deallocuvm+0x2b>
      char *v = p2v(pa);
      kfree(v);
      *pte = 0;
    }
  }
  return newsz;
801090f7:	8b 45 10             	mov    0x10(%ebp),%eax
}
801090fa:	c9                   	leave  
801090fb:	c3                   	ret    

801090fc <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
801090fc:	55                   	push   %ebp
801090fd:	89 e5                	mov    %esp,%ebp
801090ff:	83 ec 18             	sub    $0x18,%esp
  uint i;

  if(pgdir == 0)
80109102:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80109106:	75 0d                	jne    80109115 <freevm+0x19>
    panic("freevm: no pgdir");
80109108:	83 ec 0c             	sub    $0xc,%esp
8010910b:	68 67 9b 10 80       	push   $0x80109b67
80109110:	e8 51 74 ff ff       	call   80100566 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
80109115:	83 ec 04             	sub    $0x4,%esp
80109118:	6a 00                	push   $0x0
8010911a:	68 00 00 00 80       	push   $0x80000000
8010911f:	ff 75 08             	pushl  0x8(%ebp)
80109122:	e8 18 ff ff ff       	call   8010903f <deallocuvm>
80109127:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
8010912a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80109131:	eb 4f                	jmp    80109182 <freevm+0x86>
    if(pgdir[i] & PTE_P){
80109133:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109136:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010913d:	8b 45 08             	mov    0x8(%ebp),%eax
80109140:	01 d0                	add    %edx,%eax
80109142:	8b 00                	mov    (%eax),%eax
80109144:	83 e0 01             	and    $0x1,%eax
80109147:	85 c0                	test   %eax,%eax
80109149:	74 33                	je     8010917e <freevm+0x82>
      char * v = p2v(PTE_ADDR(pgdir[i]));
8010914b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010914e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109155:	8b 45 08             	mov    0x8(%ebp),%eax
80109158:	01 d0                	add    %edx,%eax
8010915a:	8b 00                	mov    (%eax),%eax
8010915c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109161:	83 ec 0c             	sub    $0xc,%esp
80109164:	50                   	push   %eax
80109165:	e8 b3 f4 ff ff       	call   8010861d <p2v>
8010916a:	83 c4 10             	add    $0x10,%esp
8010916d:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
80109170:	83 ec 0c             	sub    $0xc,%esp
80109173:	ff 75 f0             	pushl  -0x10(%ebp)
80109176:	e8 63 a2 ff ff       	call   801033de <kfree>
8010917b:	83 c4 10             	add    $0x10,%esp
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
8010917e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80109182:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
80109189:	76 a8                	jbe    80109133 <freevm+0x37>
    if(pgdir[i] & PTE_P){
      char * v = p2v(PTE_ADDR(pgdir[i]));
      kfree(v);
    }
  }
  kfree((char*)pgdir);
8010918b:	83 ec 0c             	sub    $0xc,%esp
8010918e:	ff 75 08             	pushl  0x8(%ebp)
80109191:	e8 48 a2 ff ff       	call   801033de <kfree>
80109196:	83 c4 10             	add    $0x10,%esp
}
80109199:	90                   	nop
8010919a:	c9                   	leave  
8010919b:	c3                   	ret    

8010919c <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
8010919c:	55                   	push   %ebp
8010919d:	89 e5                	mov    %esp,%ebp
8010919f:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
801091a2:	83 ec 04             	sub    $0x4,%esp
801091a5:	6a 00                	push   $0x0
801091a7:	ff 75 0c             	pushl  0xc(%ebp)
801091aa:	ff 75 08             	pushl  0x8(%ebp)
801091ad:	e8 ed f8 ff ff       	call   80108a9f <walkpgdir>
801091b2:	83 c4 10             	add    $0x10,%esp
801091b5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
801091b8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801091bc:	75 0d                	jne    801091cb <clearpteu+0x2f>
    panic("clearpteu");
801091be:	83 ec 0c             	sub    $0xc,%esp
801091c1:	68 78 9b 10 80       	push   $0x80109b78
801091c6:	e8 9b 73 ff ff       	call   80100566 <panic>
  *pte &= ~PTE_U;
801091cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091ce:	8b 00                	mov    (%eax),%eax
801091d0:	83 e0 fb             	and    $0xfffffffb,%eax
801091d3:	89 c2                	mov    %eax,%edx
801091d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091d8:	89 10                	mov    %edx,(%eax)
}
801091da:	90                   	nop
801091db:	c9                   	leave  
801091dc:	c3                   	ret    

801091dd <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
801091dd:	55                   	push   %ebp
801091de:	89 e5                	mov    %esp,%ebp
801091e0:	53                   	push   %ebx
801091e1:	83 ec 24             	sub    $0x24,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
801091e4:	e8 e6 f9 ff ff       	call   80108bcf <setupkvm>
801091e9:	89 45 f0             	mov    %eax,-0x10(%ebp)
801091ec:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801091f0:	75 0a                	jne    801091fc <copyuvm+0x1f>
    return 0;
801091f2:	b8 00 00 00 00       	mov    $0x0,%eax
801091f7:	e9 f8 00 00 00       	jmp    801092f4 <copyuvm+0x117>
  for(i = 0; i < sz; i += PGSIZE){
801091fc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80109203:	e9 c4 00 00 00       	jmp    801092cc <copyuvm+0xef>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80109208:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010920b:	83 ec 04             	sub    $0x4,%esp
8010920e:	6a 00                	push   $0x0
80109210:	50                   	push   %eax
80109211:	ff 75 08             	pushl  0x8(%ebp)
80109214:	e8 86 f8 ff ff       	call   80108a9f <walkpgdir>
80109219:	83 c4 10             	add    $0x10,%esp
8010921c:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010921f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80109223:	75 0d                	jne    80109232 <copyuvm+0x55>
      panic("copyuvm: pte should exist");
80109225:	83 ec 0c             	sub    $0xc,%esp
80109228:	68 82 9b 10 80       	push   $0x80109b82
8010922d:	e8 34 73 ff ff       	call   80100566 <panic>
    if(!(*pte & PTE_P))
80109232:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109235:	8b 00                	mov    (%eax),%eax
80109237:	83 e0 01             	and    $0x1,%eax
8010923a:	85 c0                	test   %eax,%eax
8010923c:	75 0d                	jne    8010924b <copyuvm+0x6e>
      panic("copyuvm: page not present");
8010923e:	83 ec 0c             	sub    $0xc,%esp
80109241:	68 9c 9b 10 80       	push   $0x80109b9c
80109246:	e8 1b 73 ff ff       	call   80100566 <panic>
    pa = PTE_ADDR(*pte);
8010924b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010924e:	8b 00                	mov    (%eax),%eax
80109250:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109255:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
80109258:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010925b:	8b 00                	mov    (%eax),%eax
8010925d:	25 ff 0f 00 00       	and    $0xfff,%eax
80109262:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
80109265:	e8 11 a2 ff ff       	call   8010347b <kalloc>
8010926a:	89 45 e0             	mov    %eax,-0x20(%ebp)
8010926d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80109271:	74 6a                	je     801092dd <copyuvm+0x100>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
80109273:	83 ec 0c             	sub    $0xc,%esp
80109276:	ff 75 e8             	pushl  -0x18(%ebp)
80109279:	e8 9f f3 ff ff       	call   8010861d <p2v>
8010927e:	83 c4 10             	add    $0x10,%esp
80109281:	83 ec 04             	sub    $0x4,%esp
80109284:	68 00 10 00 00       	push   $0x1000
80109289:	50                   	push   %eax
8010928a:	ff 75 e0             	pushl  -0x20(%ebp)
8010928d:	e8 20 cc ff ff       	call   80105eb2 <memmove>
80109292:	83 c4 10             	add    $0x10,%esp
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
80109295:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
80109298:	83 ec 0c             	sub    $0xc,%esp
8010929b:	ff 75 e0             	pushl  -0x20(%ebp)
8010929e:	e8 6d f3 ff ff       	call   80108610 <v2p>
801092a3:	83 c4 10             	add    $0x10,%esp
801092a6:	89 c2                	mov    %eax,%edx
801092a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801092ab:	83 ec 0c             	sub    $0xc,%esp
801092ae:	53                   	push   %ebx
801092af:	52                   	push   %edx
801092b0:	68 00 10 00 00       	push   $0x1000
801092b5:	50                   	push   %eax
801092b6:	ff 75 f0             	pushl  -0x10(%ebp)
801092b9:	e8 81 f8 ff ff       	call   80108b3f <mappages>
801092be:	83 c4 20             	add    $0x20,%esp
801092c1:	85 c0                	test   %eax,%eax
801092c3:	78 1b                	js     801092e0 <copyuvm+0x103>
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
801092c5:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801092cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801092cf:	3b 45 0c             	cmp    0xc(%ebp),%eax
801092d2:	0f 82 30 ff ff ff    	jb     80109208 <copyuvm+0x2b>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
      goto bad;
  }
  return d;
801092d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801092db:	eb 17                	jmp    801092f4 <copyuvm+0x117>
    if(!(*pte & PTE_P))
      panic("copyuvm: page not present");
    pa = PTE_ADDR(*pte);
    flags = PTE_FLAGS(*pte);
    if((mem = kalloc()) == 0)
      goto bad;
801092dd:	90                   	nop
801092de:	eb 01                	jmp    801092e1 <copyuvm+0x104>
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
      goto bad;
801092e0:	90                   	nop
  }
  return d;

bad:
  freevm(d);
801092e1:	83 ec 0c             	sub    $0xc,%esp
801092e4:	ff 75 f0             	pushl  -0x10(%ebp)
801092e7:	e8 10 fe ff ff       	call   801090fc <freevm>
801092ec:	83 c4 10             	add    $0x10,%esp
  return 0;
801092ef:	b8 00 00 00 00       	mov    $0x0,%eax
}
801092f4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801092f7:	c9                   	leave  
801092f8:	c3                   	ret    

801092f9 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
801092f9:	55                   	push   %ebp
801092fa:	89 e5                	mov    %esp,%ebp
801092fc:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
801092ff:	83 ec 04             	sub    $0x4,%esp
80109302:	6a 00                	push   $0x0
80109304:	ff 75 0c             	pushl  0xc(%ebp)
80109307:	ff 75 08             	pushl  0x8(%ebp)
8010930a:	e8 90 f7 ff ff       	call   80108a9f <walkpgdir>
8010930f:	83 c4 10             	add    $0x10,%esp
80109312:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
80109315:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109318:	8b 00                	mov    (%eax),%eax
8010931a:	83 e0 01             	and    $0x1,%eax
8010931d:	85 c0                	test   %eax,%eax
8010931f:	75 07                	jne    80109328 <uva2ka+0x2f>
    return 0;
80109321:	b8 00 00 00 00       	mov    $0x0,%eax
80109326:	eb 29                	jmp    80109351 <uva2ka+0x58>
  if((*pte & PTE_U) == 0)
80109328:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010932b:	8b 00                	mov    (%eax),%eax
8010932d:	83 e0 04             	and    $0x4,%eax
80109330:	85 c0                	test   %eax,%eax
80109332:	75 07                	jne    8010933b <uva2ka+0x42>
    return 0;
80109334:	b8 00 00 00 00       	mov    $0x0,%eax
80109339:	eb 16                	jmp    80109351 <uva2ka+0x58>
  return (char*)p2v(PTE_ADDR(*pte));
8010933b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010933e:	8b 00                	mov    (%eax),%eax
80109340:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109345:	83 ec 0c             	sub    $0xc,%esp
80109348:	50                   	push   %eax
80109349:	e8 cf f2 ff ff       	call   8010861d <p2v>
8010934e:	83 c4 10             	add    $0x10,%esp
}
80109351:	c9                   	leave  
80109352:	c3                   	ret    

80109353 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80109353:	55                   	push   %ebp
80109354:	89 e5                	mov    %esp,%ebp
80109356:	83 ec 18             	sub    $0x18,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
80109359:	8b 45 10             	mov    0x10(%ebp),%eax
8010935c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
8010935f:	eb 7f                	jmp    801093e0 <copyout+0x8d>
    va0 = (uint)PGROUNDDOWN(va);
80109361:	8b 45 0c             	mov    0xc(%ebp),%eax
80109364:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109369:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
8010936c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010936f:	83 ec 08             	sub    $0x8,%esp
80109372:	50                   	push   %eax
80109373:	ff 75 08             	pushl  0x8(%ebp)
80109376:	e8 7e ff ff ff       	call   801092f9 <uva2ka>
8010937b:	83 c4 10             	add    $0x10,%esp
8010937e:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
80109381:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80109385:	75 07                	jne    8010938e <copyout+0x3b>
      return -1;
80109387:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010938c:	eb 61                	jmp    801093ef <copyout+0x9c>
    n = PGSIZE - (va - va0);
8010938e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109391:	2b 45 0c             	sub    0xc(%ebp),%eax
80109394:	05 00 10 00 00       	add    $0x1000,%eax
80109399:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
8010939c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010939f:	3b 45 14             	cmp    0x14(%ebp),%eax
801093a2:	76 06                	jbe    801093aa <copyout+0x57>
      n = len;
801093a4:	8b 45 14             	mov    0x14(%ebp),%eax
801093a7:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
801093aa:	8b 45 0c             	mov    0xc(%ebp),%eax
801093ad:	2b 45 ec             	sub    -0x14(%ebp),%eax
801093b0:	89 c2                	mov    %eax,%edx
801093b2:	8b 45 e8             	mov    -0x18(%ebp),%eax
801093b5:	01 d0                	add    %edx,%eax
801093b7:	83 ec 04             	sub    $0x4,%esp
801093ba:	ff 75 f0             	pushl  -0x10(%ebp)
801093bd:	ff 75 f4             	pushl  -0xc(%ebp)
801093c0:	50                   	push   %eax
801093c1:	e8 ec ca ff ff       	call   80105eb2 <memmove>
801093c6:	83 c4 10             	add    $0x10,%esp
    len -= n;
801093c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801093cc:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
801093cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801093d2:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
801093d5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801093d8:	05 00 10 00 00       	add    $0x1000,%eax
801093dd:	89 45 0c             	mov    %eax,0xc(%ebp)
{
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
801093e0:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
801093e4:	0f 85 77 ff ff ff    	jne    80109361 <copyout+0xe>
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
801093ea:	b8 00 00 00 00       	mov    $0x0,%eax
}
801093ef:	c9                   	leave  
801093f0:	c3                   	ret    
