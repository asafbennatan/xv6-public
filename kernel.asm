
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
80100015:	b8 00 a0 10 00       	mov    $0x10a000,%eax
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
80100028:	bc 50 c6 10 80       	mov    $0x8010c650,%esp

  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
  mov $main, %eax
8010002d:	b8 4b 3c 10 80       	mov    $0x80103c4b,%eax
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
8010003d:	68 f0 88 10 80       	push   $0x801088f0
80100042:	68 e0 c6 10 80       	push   $0x8010c6e0
80100047:	e8 4f 53 00 00       	call   8010539b <initlock>
8010004c:	83 c4 10             	add    $0x10,%esp

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
8010004f:	c7 05 f0 05 11 80 e4 	movl   $0x801105e4,0x801105f0
80100056:	05 11 80 
  bcache.head.next = &bcache.head;
80100059:	c7 05 f4 05 11 80 e4 	movl   $0x801105e4,0x801105f4
80100060:	05 11 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100063:	c7 45 f4 14 c7 10 80 	movl   $0x8010c714,-0xc(%ebp)
8010006a:	eb 3a                	jmp    801000a6 <binit+0x72>
    b->next = bcache.head.next;
8010006c:	8b 15 f4 05 11 80    	mov    0x801105f4,%edx
80100072:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100075:	89 50 10             	mov    %edx,0x10(%eax)
    b->prev = &bcache.head;
80100078:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010007b:	c7 40 0c e4 05 11 80 	movl   $0x801105e4,0xc(%eax)
    b->dev = -1;
80100082:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100085:	c7 40 04 ff ff ff ff 	movl   $0xffffffff,0x4(%eax)
    bcache.head.next->prev = b;
8010008c:	a1 f4 05 11 80       	mov    0x801105f4,%eax
80100091:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100094:	89 50 0c             	mov    %edx,0xc(%eax)
    bcache.head.next = b;
80100097:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010009a:	a3 f4 05 11 80       	mov    %eax,0x801105f4

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
  bcache.head.next = &bcache.head;
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
8010009f:	81 45 f4 18 02 00 00 	addl   $0x218,-0xc(%ebp)
801000a6:	b8 e4 05 11 80       	mov    $0x801105e4,%eax
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
801000bc:	68 e0 c6 10 80       	push   $0x8010c6e0
801000c1:	e8 f7 52 00 00       	call   801053bd <acquire>
801000c6:	83 c4 10             	add    $0x10,%esp

 loop:
  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
801000c9:	a1 f4 05 11 80       	mov    0x801105f4,%eax
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
80100107:	68 e0 c6 10 80       	push   $0x8010c6e0
8010010c:	e8 13 53 00 00       	call   80105424 <release>
80100111:	83 c4 10             	add    $0x10,%esp
        return b;
80100114:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100117:	e9 98 00 00 00       	jmp    801001b4 <bget+0x101>
      }
      sleep(b, &bcache.lock);
8010011c:	83 ec 08             	sub    $0x8,%esp
8010011f:	68 e0 c6 10 80       	push   $0x8010c6e0
80100124:	ff 75 f4             	pushl  -0xc(%ebp)
80100127:	e8 98 4f 00 00       	call   801050c4 <sleep>
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
8010013a:	81 7d f4 e4 05 11 80 	cmpl   $0x801105e4,-0xc(%ebp)
80100141:	75 90                	jne    801000d3 <bget+0x20>
  }

  // Not cached; recycle some non-busy and clean buffer.
  // "clean" because B_DIRTY and !B_BUSY means log.c
  // hasn't yet committed the changes to the buffer.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100143:	a1 f0 05 11 80       	mov    0x801105f0,%eax
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
80100183:	68 e0 c6 10 80       	push   $0x8010c6e0
80100188:	e8 97 52 00 00       	call   80105424 <release>
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
8010019e:	81 7d f4 e4 05 11 80 	cmpl   $0x801105e4,-0xc(%ebp)
801001a5:	75 a6                	jne    8010014d <bget+0x9a>
      b->flags = B_BUSY;
      release(&bcache.lock);
      return b;
    }
  }
  panic("bget: no buffers");
801001a7:	83 ec 0c             	sub    $0xc,%esp
801001aa:	68 f7 88 10 80       	push   $0x801088f7
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
801001e2:	e8 be 2a 00 00       	call   80102ca5 <iderw>
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
80100204:	68 08 89 10 80       	push   $0x80108908
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
80100223:	e8 7d 2a 00 00       	call   80102ca5 <iderw>
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
80100243:	68 0f 89 10 80       	push   $0x8010890f
80100248:	e8 19 03 00 00       	call   80100566 <panic>

  acquire(&bcache.lock);
8010024d:	83 ec 0c             	sub    $0xc,%esp
80100250:	68 e0 c6 10 80       	push   $0x8010c6e0
80100255:	e8 63 51 00 00       	call   801053bd <acquire>
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
8010027b:	8b 15 f4 05 11 80    	mov    0x801105f4,%edx
80100281:	8b 45 08             	mov    0x8(%ebp),%eax
80100284:	89 50 10             	mov    %edx,0x10(%eax)
  b->prev = &bcache.head;
80100287:	8b 45 08             	mov    0x8(%ebp),%eax
8010028a:	c7 40 0c e4 05 11 80 	movl   $0x801105e4,0xc(%eax)
  bcache.head.next->prev = b;
80100291:	a1 f4 05 11 80       	mov    0x801105f4,%eax
80100296:	8b 55 08             	mov    0x8(%ebp),%edx
80100299:	89 50 0c             	mov    %edx,0xc(%eax)
  bcache.head.next = b;
8010029c:	8b 45 08             	mov    0x8(%ebp),%eax
8010029f:	a3 f4 05 11 80       	mov    %eax,0x801105f4

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
801002b9:	e8 f1 4e 00 00       	call   801051af <wakeup>
801002be:	83 c4 10             	add    $0x10,%esp

  release(&bcache.lock);
801002c1:	83 ec 0c             	sub    $0xc,%esp
801002c4:	68 e0 c6 10 80       	push   $0x8010c6e0
801002c9:	e8 56 51 00 00       	call   80105424 <release>
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
80100365:	0f b6 80 04 90 10 80 	movzbl -0x7fef6ffc(%eax),%eax
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
801003cc:	a1 f4 b5 10 80       	mov    0x8010b5f4,%eax
801003d1:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(locking)
801003d4:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801003d8:	74 10                	je     801003ea <cprintf+0x24>
    acquire(&cons.lock);
801003da:	83 ec 0c             	sub    $0xc,%esp
801003dd:	68 c0 b5 10 80       	push   $0x8010b5c0
801003e2:	e8 d6 4f 00 00       	call   801053bd <acquire>
801003e7:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
801003ea:	8b 45 08             	mov    0x8(%ebp),%eax
801003ed:	85 c0                	test   %eax,%eax
801003ef:	75 0d                	jne    801003fe <cprintf+0x38>
    panic("null fmt");
801003f1:	83 ec 0c             	sub    $0xc,%esp
801003f4:	68 16 89 10 80       	push   $0x80108916
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
801004cd:	c7 45 ec 1f 89 10 80 	movl   $0x8010891f,-0x14(%ebp)
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
80100556:	68 c0 b5 10 80       	push   $0x8010b5c0
8010055b:	e8 c4 4e 00 00       	call   80105424 <release>
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
80100571:	c7 05 f4 b5 10 80 00 	movl   $0x0,0x8010b5f4
80100578:	00 00 00 
  cprintf("cpu%d: panic: ", cpu->id);
8010057b:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80100581:	0f b6 00             	movzbl (%eax),%eax
80100584:	0f b6 c0             	movzbl %al,%eax
80100587:	83 ec 08             	sub    $0x8,%esp
8010058a:	50                   	push   %eax
8010058b:	68 26 89 10 80       	push   $0x80108926
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
801005aa:	68 35 89 10 80       	push   $0x80108935
801005af:	e8 12 fe ff ff       	call   801003c6 <cprintf>
801005b4:	83 c4 10             	add    $0x10,%esp
  getcallerpcs(&s, pcs);
801005b7:	83 ec 08             	sub    $0x8,%esp
801005ba:	8d 45 cc             	lea    -0x34(%ebp),%eax
801005bd:	50                   	push   %eax
801005be:	8d 45 08             	lea    0x8(%ebp),%eax
801005c1:	50                   	push   %eax
801005c2:	e8 af 4e 00 00       	call   80105476 <getcallerpcs>
801005c7:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
801005ca:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801005d1:	eb 1c                	jmp    801005ef <panic+0x89>
    cprintf(" %p", pcs[i]);
801005d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801005d6:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
801005da:	83 ec 08             	sub    $0x8,%esp
801005dd:	50                   	push   %eax
801005de:	68 37 89 10 80       	push   $0x80108937
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
801005f5:	c7 05 a0 b5 10 80 01 	movl   $0x1,0x8010b5a0
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
80100699:	8b 0d 00 90 10 80    	mov    0x80109000,%ecx
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
801006ca:	68 3b 89 10 80       	push   $0x8010893b
801006cf:	e8 92 fe ff ff       	call   80100566 <panic>
  
  if((pos/80) >= 24){  // Scroll up.
801006d4:	81 7d f4 7f 07 00 00 	cmpl   $0x77f,-0xc(%ebp)
801006db:	7e 4c                	jle    80100729 <cgaputc+0x128>
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
801006dd:	a1 00 90 10 80       	mov    0x80109000,%eax
801006e2:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
801006e8:	a1 00 90 10 80       	mov    0x80109000,%eax
801006ed:	83 ec 04             	sub    $0x4,%esp
801006f0:	68 60 0e 00 00       	push   $0xe60
801006f5:	52                   	push   %edx
801006f6:	50                   	push   %eax
801006f7:	e8 e3 4f 00 00       	call   801056df <memmove>
801006fc:	83 c4 10             	add    $0x10,%esp
    pos -= 80;
801006ff:	83 6d f4 50          	subl   $0x50,-0xc(%ebp)
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
80100703:	b8 80 07 00 00       	mov    $0x780,%eax
80100708:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010070b:	8d 14 00             	lea    (%eax,%eax,1),%edx
8010070e:	a1 00 90 10 80       	mov    0x80109000,%eax
80100713:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80100716:	01 c9                	add    %ecx,%ecx
80100718:	01 c8                	add    %ecx,%eax
8010071a:	83 ec 04             	sub    $0x4,%esp
8010071d:	52                   	push   %edx
8010071e:	6a 00                	push   $0x0
80100720:	50                   	push   %eax
80100721:	e8 fa 4e 00 00       	call   80105620 <memset>
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
8010077e:	a1 00 90 10 80       	mov    0x80109000,%eax
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
80100798:	a1 a0 b5 10 80       	mov    0x8010b5a0,%eax
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
801007b6:	e8 bb 67 00 00       	call   80106f76 <uartputc>
801007bb:	83 c4 10             	add    $0x10,%esp
801007be:	83 ec 0c             	sub    $0xc,%esp
801007c1:	6a 20                	push   $0x20
801007c3:	e8 ae 67 00 00       	call   80106f76 <uartputc>
801007c8:	83 c4 10             	add    $0x10,%esp
801007cb:	83 ec 0c             	sub    $0xc,%esp
801007ce:	6a 08                	push   $0x8
801007d0:	e8 a1 67 00 00       	call   80106f76 <uartputc>
801007d5:	83 c4 10             	add    $0x10,%esp
801007d8:	eb 0e                	jmp    801007e8 <consputc+0x56>
  } else
    uartputc(c);
801007da:	83 ec 0c             	sub    $0xc,%esp
801007dd:	ff 75 08             	pushl  0x8(%ebp)
801007e0:	e8 91 67 00 00       	call   80106f76 <uartputc>
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
80100809:	68 c0 b5 10 80       	push   $0x8010b5c0
8010080e:	e8 aa 4b 00 00       	call   801053bd <acquire>
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
8010084d:	a1 e8 08 11 80       	mov    0x801108e8,%eax
80100852:	83 e8 01             	sub    $0x1,%eax
80100855:	a3 e8 08 11 80       	mov    %eax,0x801108e8
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
8010086a:	8b 15 e8 08 11 80    	mov    0x801108e8,%edx
80100870:	a1 e4 08 11 80       	mov    0x801108e4,%eax
80100875:	39 c2                	cmp    %eax,%edx
80100877:	0f 84 e2 00 00 00    	je     8010095f <consoleintr+0x166>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
8010087d:	a1 e8 08 11 80       	mov    0x801108e8,%eax
80100882:	83 e8 01             	sub    $0x1,%eax
80100885:	83 e0 7f             	and    $0x7f,%eax
80100888:	0f b6 80 60 08 11 80 	movzbl -0x7feef7a0(%eax),%eax
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
80100898:	8b 15 e8 08 11 80    	mov    0x801108e8,%edx
8010089e:	a1 e4 08 11 80       	mov    0x801108e4,%eax
801008a3:	39 c2                	cmp    %eax,%edx
801008a5:	0f 84 b4 00 00 00    	je     8010095f <consoleintr+0x166>
        input.e--;
801008ab:	a1 e8 08 11 80       	mov    0x801108e8,%eax
801008b0:	83 e8 01             	sub    $0x1,%eax
801008b3:	a3 e8 08 11 80       	mov    %eax,0x801108e8
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
801008d7:	8b 15 e8 08 11 80    	mov    0x801108e8,%edx
801008dd:	a1 e0 08 11 80       	mov    0x801108e0,%eax
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
801008fe:	a1 e8 08 11 80       	mov    0x801108e8,%eax
80100903:	8d 50 01             	lea    0x1(%eax),%edx
80100906:	89 15 e8 08 11 80    	mov    %edx,0x801108e8
8010090c:	83 e0 7f             	and    $0x7f,%eax
8010090f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80100912:	88 90 60 08 11 80    	mov    %dl,-0x7feef7a0(%eax)
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
80100932:	a1 e8 08 11 80       	mov    0x801108e8,%eax
80100937:	8b 15 e0 08 11 80    	mov    0x801108e0,%edx
8010093d:	83 ea 80             	sub    $0xffffff80,%edx
80100940:	39 d0                	cmp    %edx,%eax
80100942:	75 1a                	jne    8010095e <consoleintr+0x165>
          input.w = input.e;
80100944:	a1 e8 08 11 80       	mov    0x801108e8,%eax
80100949:	a3 e4 08 11 80       	mov    %eax,0x801108e4
          wakeup(&input.r);
8010094e:	83 ec 0c             	sub    $0xc,%esp
80100951:	68 e0 08 11 80       	push   $0x801108e0
80100956:	e8 54 48 00 00       	call   801051af <wakeup>
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
80100974:	68 c0 b5 10 80       	push   $0x8010b5c0
80100979:	e8 a6 4a 00 00       	call   80105424 <release>
8010097e:	83 c4 10             	add    $0x10,%esp
  if(doprocdump) {
80100981:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100985:	74 05                	je     8010098c <consoleintr+0x193>
    procdump();  // now call procdump() wo. cons.lock held
80100987:	e8 de 48 00 00       	call   8010526a <procdump>
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

  iunlock(ip);
80100995:	83 ec 0c             	sub    $0xc,%esp
80100998:	ff 75 08             	pushl  0x8(%ebp)
8010099b:	e8 65 14 00 00       	call   80101e05 <iunlock>
801009a0:	83 c4 10             	add    $0x10,%esp
  target = n;
801009a3:	8b 45 10             	mov    0x10(%ebp),%eax
801009a6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&cons.lock);
801009a9:	83 ec 0c             	sub    $0xc,%esp
801009ac:	68 c0 b5 10 80       	push   $0x8010b5c0
801009b1:	e8 07 4a 00 00       	call   801053bd <acquire>
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
801009ce:	68 c0 b5 10 80       	push   $0x8010b5c0
801009d3:	e8 4c 4a 00 00       	call   80105424 <release>
801009d8:	83 c4 10             	add    $0x10,%esp
        ilock(ip);
801009db:	83 ec 0c             	sub    $0xc,%esp
801009de:	ff 75 08             	pushl  0x8(%ebp)
801009e1:	e8 7e 12 00 00       	call   80101c64 <ilock>
801009e6:	83 c4 10             	add    $0x10,%esp
        return -1;
801009e9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801009ee:	e9 ab 00 00 00       	jmp    80100a9e <consoleread+0x10f>
      }
      sleep(&input.r, &cons.lock);
801009f3:	83 ec 08             	sub    $0x8,%esp
801009f6:	68 c0 b5 10 80       	push   $0x8010b5c0
801009fb:	68 e0 08 11 80       	push   $0x801108e0
80100a00:	e8 bf 46 00 00       	call   801050c4 <sleep>
80100a05:	83 c4 10             	add    $0x10,%esp

  iunlock(ip);
  target = n;
  acquire(&cons.lock);
  while(n > 0){
    while(input.r == input.w){
80100a08:	8b 15 e0 08 11 80    	mov    0x801108e0,%edx
80100a0e:	a1 e4 08 11 80       	mov    0x801108e4,%eax
80100a13:	39 c2                	cmp    %eax,%edx
80100a15:	74 a7                	je     801009be <consoleread+0x2f>
        ilock(ip);
        return -1;
      }
      sleep(&input.r, &cons.lock);
    }
    c = input.buf[input.r++ % INPUT_BUF];
80100a17:	a1 e0 08 11 80       	mov    0x801108e0,%eax
80100a1c:	8d 50 01             	lea    0x1(%eax),%edx
80100a1f:	89 15 e0 08 11 80    	mov    %edx,0x801108e0
80100a25:	83 e0 7f             	and    $0x7f,%eax
80100a28:	0f b6 80 60 08 11 80 	movzbl -0x7feef7a0(%eax),%eax
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
80100a43:	a1 e0 08 11 80       	mov    0x801108e0,%eax
80100a48:	83 e8 01             	sub    $0x1,%eax
80100a4b:	a3 e0 08 11 80       	mov    %eax,0x801108e0
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
80100a79:	68 c0 b5 10 80       	push   $0x8010b5c0
80100a7e:	e8 a1 49 00 00       	call   80105424 <release>
80100a83:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100a86:	83 ec 0c             	sub    $0xc,%esp
80100a89:	ff 75 08             	pushl  0x8(%ebp)
80100a8c:	e8 d3 11 00 00       	call   80101c64 <ilock>
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

  iunlock(ip);
80100aa6:	83 ec 0c             	sub    $0xc,%esp
80100aa9:	ff 75 08             	pushl  0x8(%ebp)
80100aac:	e8 54 13 00 00       	call   80101e05 <iunlock>
80100ab1:	83 c4 10             	add    $0x10,%esp
  acquire(&cons.lock);
80100ab4:	83 ec 0c             	sub    $0xc,%esp
80100ab7:	68 c0 b5 10 80       	push   $0x8010b5c0
80100abc:	e8 fc 48 00 00       	call   801053bd <acquire>
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
{
  int i;

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
80100af9:	68 c0 b5 10 80       	push   $0x8010b5c0
80100afe:	e8 21 49 00 00       	call   80105424 <release>
80100b03:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100b06:	83 ec 0c             	sub    $0xc,%esp
80100b09:	ff 75 08             	pushl  0x8(%ebp)
80100b0c:	e8 53 11 00 00       	call   80101c64 <ilock>
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
80100b22:	68 4e 89 10 80       	push   $0x8010894e
80100b27:	68 c0 b5 10 80       	push   $0x8010b5c0
80100b2c:	e8 6a 48 00 00       	call   8010539b <initlock>
80100b31:	83 c4 10             	add    $0x10,%esp

  devsw[CONSOLE].write = consolewrite;
80100b34:	c7 05 ec 11 11 80 a0 	movl   $0x80100aa0,0x801111ec
80100b3b:	0a 10 80 
  devsw[CONSOLE].read = consoleread;
80100b3e:	c7 05 e8 11 11 80 8f 	movl   $0x8010098f,0x801111e8
80100b45:	09 10 80 
  cons.locking = 1;
80100b48:	c7 05 f4 b5 10 80 01 	movl   $0x1,0x8010b5f4
80100b4f:	00 00 00 

  picenable(IRQ_KBD);
80100b52:	83 ec 0c             	sub    $0xc,%esp
80100b55:	6a 01                	push   $0x1
80100b57:	e8 8b 37 00 00       	call   801042e7 <picenable>
80100b5c:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_KBD, 0);
80100b5f:	83 ec 08             	sub    $0x8,%esp
80100b62:	6a 00                	push   $0x0
80100b64:	6a 01                	push   $0x1
80100b66:	e8 07 23 00 00       	call   80102e72 <ioapicenable>
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
80100b7a:	e8 8a 2d 00 00       	call   80103909 <begin_op>
  if((ip = namei(path)) == 0){
80100b7f:	83 ec 0c             	sub    $0xc,%esp
80100b82:	ff 75 08             	pushl  0x8(%ebp)
80100b85:	e8 36 1d 00 00       	call   801028c0 <namei>
80100b8a:	83 c4 10             	add    $0x10,%esp
80100b8d:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100b90:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100b94:	75 0f                	jne    80100ba5 <exec+0x34>
    end_op();
80100b96:	e8 fa 2d 00 00       	call   80103995 <end_op>
    return -1;
80100b9b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100ba0:	e9 ce 03 00 00       	jmp    80100f73 <exec+0x402>
  }
  ilock(ip);
80100ba5:	83 ec 0c             	sub    $0xc,%esp
80100ba8:	ff 75 d8             	pushl  -0x28(%ebp)
80100bab:	e8 b4 10 00 00       	call   80101c64 <ilock>
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
80100bc8:	e8 90 16 00 00       	call   8010225d <readi>
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
80100bea:	e8 dc 74 00 00       	call   801080cb <setupkvm>
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
80100c28:	e8 30 16 00 00       	call   8010225d <readi>
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
80100c70:	e8 fd 77 00 00       	call   80108472 <allocuvm>
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
80100ca3:	e8 f3 76 00 00       	call   8010839b <loaduvm>
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
80100cdc:	e8 86 12 00 00       	call   80101f67 <iunlockput>
80100ce1:	83 c4 10             	add    $0x10,%esp
  end_op();
80100ce4:	e8 ac 2c 00 00       	call   80103995 <end_op>
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
80100d12:	e8 5b 77 00 00       	call   80108472 <allocuvm>
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
80100d36:	e8 5d 79 00 00       	call   80108698 <clearpteu>
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
80100d6f:	e8 f9 4a 00 00       	call   8010586d <strlen>
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
80100d9c:	e8 cc 4a 00 00       	call   8010586d <strlen>
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
80100dc2:	e8 88 7a 00 00       	call   8010884f <copyout>
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
80100e5e:	e8 ec 79 00 00       	call   8010884f <copyout>
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
80100eaf:	e8 6f 49 00 00       	call   80105823 <safestrcpy>
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
80100f05:	e8 a8 72 00 00       	call   801081b2 <switchuvm>
80100f0a:	83 c4 10             	add    $0x10,%esp
  freevm(oldpgdir);
80100f0d:	83 ec 0c             	sub    $0xc,%esp
80100f10:	ff 75 d0             	pushl  -0x30(%ebp)
80100f13:	e8 e0 76 00 00       	call   801085f8 <freevm>
80100f18:	83 c4 10             	add    $0x10,%esp
  return 0;
80100f1b:	b8 00 00 00 00       	mov    $0x0,%eax
80100f20:	eb 51                	jmp    80100f73 <exec+0x402>
  ilock(ip);
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
80100f4d:	e8 a6 76 00 00       	call   801085f8 <freevm>
80100f52:	83 c4 10             	add    $0x10,%esp
  if(ip){
80100f55:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100f59:	74 13                	je     80100f6e <exec+0x3fd>
    iunlockput(ip);
80100f5b:	83 ec 0c             	sub    $0xc,%esp
80100f5e:	ff 75 d8             	pushl  -0x28(%ebp)
80100f61:	e8 01 10 00 00       	call   80101f67 <iunlockput>
80100f66:	83 c4 10             	add    $0x10,%esp
    end_op();
80100f69:	e8 27 2a 00 00       	call   80103995 <end_op>
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
80100f7e:	68 56 89 10 80       	push   $0x80108956
80100f83:	68 00 09 11 80       	push   $0x80110900
80100f88:	e8 0e 44 00 00       	call   8010539b <initlock>
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
80100f9c:	68 00 09 11 80       	push   $0x80110900
80100fa1:	e8 17 44 00 00       	call   801053bd <acquire>
80100fa6:	83 c4 10             	add    $0x10,%esp
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100fa9:	c7 45 f4 34 09 11 80 	movl   $0x80110934,-0xc(%ebp)
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
80100fc9:	68 00 09 11 80       	push   $0x80110900
80100fce:	e8 51 44 00 00       	call   80105424 <release>
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
80100fdf:	b8 cc 11 11 80       	mov    $0x801111cc,%eax
80100fe4:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80100fe7:	72 c9                	jb     80100fb2 <filealloc+0x1f>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
80100fe9:	83 ec 0c             	sub    $0xc,%esp
80100fec:	68 00 09 11 80       	push   $0x80110900
80100ff1:	e8 2e 44 00 00       	call   80105424 <release>
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
80101009:	68 00 09 11 80       	push   $0x80110900
8010100e:	e8 aa 43 00 00       	call   801053bd <acquire>
80101013:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
80101016:	8b 45 08             	mov    0x8(%ebp),%eax
80101019:	8b 40 04             	mov    0x4(%eax),%eax
8010101c:	85 c0                	test   %eax,%eax
8010101e:	7f 0d                	jg     8010102d <filedup+0x2d>
    panic("filedup");
80101020:	83 ec 0c             	sub    $0xc,%esp
80101023:	68 5d 89 10 80       	push   $0x8010895d
80101028:	e8 39 f5 ff ff       	call   80100566 <panic>
  f->ref++;
8010102d:	8b 45 08             	mov    0x8(%ebp),%eax
80101030:	8b 40 04             	mov    0x4(%eax),%eax
80101033:	8d 50 01             	lea    0x1(%eax),%edx
80101036:	8b 45 08             	mov    0x8(%ebp),%eax
80101039:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
8010103c:	83 ec 0c             	sub    $0xc,%esp
8010103f:	68 00 09 11 80       	push   $0x80110900
80101044:	e8 db 43 00 00       	call   80105424 <release>
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
8010105a:	68 00 09 11 80       	push   $0x80110900
8010105f:	e8 59 43 00 00       	call   801053bd <acquire>
80101064:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
80101067:	8b 45 08             	mov    0x8(%ebp),%eax
8010106a:	8b 40 04             	mov    0x4(%eax),%eax
8010106d:	85 c0                	test   %eax,%eax
8010106f:	7f 0d                	jg     8010107e <fileclose+0x2d>
    panic("fileclose");
80101071:	83 ec 0c             	sub    $0xc,%esp
80101074:	68 65 89 10 80       	push   $0x80108965
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
8010109a:	68 00 09 11 80       	push   $0x80110900
8010109f:	e8 80 43 00 00       	call   80105424 <release>
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
801010ea:	68 00 09 11 80       	push   $0x80110900
801010ef:	e8 30 43 00 00       	call   80105424 <release>
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
8010110e:	e8 3d 34 00 00       	call   80104550 <pipeclose>
80101113:	83 c4 10             	add    $0x10,%esp
80101116:	eb 21                	jmp    80101139 <fileclose+0xe8>
  else if(ff.type == FD_INODE){
80101118:	8b 45 e2             	mov    -0x1e(%ebp),%eax
8010111b:	83 f8 02             	cmp    $0x2,%eax
8010111e:	75 19                	jne    80101139 <fileclose+0xe8>
    begin_op();
80101120:	e8 e4 27 00 00       	call   80103909 <begin_op>
    iput(ff.ip);
80101125:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101128:	83 ec 0c             	sub    $0xc,%esp
8010112b:	50                   	push   %eax
8010112c:	e8 46 0d 00 00       	call   80101e77 <iput>
80101131:	83 c4 10             	add    $0x10,%esp
    end_op();
80101134:	e8 5c 28 00 00       	call   80103995 <end_op>
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
80101155:	e8 0a 0b 00 00       	call   80101c64 <ilock>
8010115a:	83 c4 10             	add    $0x10,%esp
    stati(f->ip, st);
8010115d:	8b 45 08             	mov    0x8(%ebp),%eax
80101160:	8b 40 0e             	mov    0xe(%eax),%eax
80101163:	83 ec 08             	sub    $0x8,%esp
80101166:	ff 75 0c             	pushl  0xc(%ebp)
80101169:	50                   	push   %eax
8010116a:	e8 a8 10 00 00       	call   80102217 <stati>
8010116f:	83 c4 10             	add    $0x10,%esp
    iunlock(f->ip);
80101172:	8b 45 08             	mov    0x8(%ebp),%eax
80101175:	8b 40 0e             	mov    0xe(%eax),%eax
80101178:	83 ec 0c             	sub    $0xc,%esp
8010117b:	50                   	push   %eax
8010117c:	e8 84 0c 00 00       	call   80101e05 <iunlock>
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
801011c7:	e8 2c 35 00 00       	call   801046f8 <piperead>
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
801011e5:	e8 7a 0a 00 00       	call   80101c64 <ilock>
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
80101202:	e8 56 10 00 00       	call   8010225d <readi>
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
    iunlock(f->ip);
80101224:	8b 45 08             	mov    0x8(%ebp),%eax
80101227:	8b 40 0e             	mov    0xe(%eax),%eax
8010122a:	83 ec 0c             	sub    $0xc,%esp
8010122d:	50                   	push   %eax
8010122e:	e8 d2 0b 00 00       	call   80101e05 <iunlock>
80101233:	83 c4 10             	add    $0x10,%esp
    return r;
80101236:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101239:	eb 0d                	jmp    80101248 <fileread+0xb6>
  }
  panic("fileread");
8010123b:	83 ec 0c             	sub    $0xc,%esp
8010123e:	68 6f 89 10 80       	push   $0x8010896f
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
80101280:	e8 75 33 00 00       	call   801045fa <pipewrite>
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
801012c5:	e8 3f 26 00 00       	call   80103909 <begin_op>
      ilock(f->ip);
801012ca:	8b 45 08             	mov    0x8(%ebp),%eax
801012cd:	8b 40 0e             	mov    0xe(%eax),%eax
801012d0:	83 ec 0c             	sub    $0xc,%esp
801012d3:	50                   	push   %eax
801012d4:	e8 8b 09 00 00       	call   80101c64 <ilock>
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
801012f7:	e8 b8 10 00 00       	call   801023b4 <writei>
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
      iunlock(f->ip);
80101319:	8b 45 08             	mov    0x8(%ebp),%eax
8010131c:	8b 40 0e             	mov    0xe(%eax),%eax
8010131f:	83 ec 0c             	sub    $0xc,%esp
80101322:	50                   	push   %eax
80101323:	e8 dd 0a 00 00       	call   80101e05 <iunlock>
80101328:	83 c4 10             	add    $0x10,%esp
      end_op();
8010132b:	e8 65 26 00 00       	call   80103995 <end_op>

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
80101341:	68 78 89 10 80       	push   $0x80108978
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
        f->off += r;
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
80101377:	68 88 89 10 80       	push   $0x80108988
8010137c:	e8 e5 f1 ff ff       	call   80100566 <panic>
}
80101381:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101384:	c9                   	leave  
80101385:	c3                   	ret    

80101386 <readsb>:
struct mbr mbrI;
 int bootfrom=-1;
// Read the super block.
void
readsb(int dev, int partitionNumber)
{
80101386:	55                   	push   %ebp
80101387:	89 e5                	mov    %esp,%ebp
80101389:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  
  bp = bread(dev, mbrI.partitions[partitionNumber].offset);
8010138c:	8b 55 0c             	mov    0xc(%ebp),%edx
8010138f:	89 d0                	mov    %edx,%eax
80101391:	c1 e0 02             	shl    $0x2,%eax
80101394:	01 d0                	add    %edx,%eax
80101396:	c1 e0 02             	shl    $0x2,%eax
80101399:	05 f0 13 11 80       	add    $0x801113f0,%eax
8010139e:	8b 50 16             	mov    0x16(%eax),%edx
801013a1:	8b 45 08             	mov    0x8(%ebp),%eax
801013a4:	83 ec 08             	sub    $0x8,%esp
801013a7:	52                   	push   %edx
801013a8:	50                   	push   %eax
801013a9:	e8 08 ee ff ff       	call   801001b6 <bread>
801013ae:	83 c4 10             	add    $0x10,%esp
801013b1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(&(sbs[partitionNumber]), bp->data, sizeof(struct superblock));
801013b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013b7:	8d 50 18             	lea    0x18(%eax),%edx
801013ba:	8b 45 0c             	mov    0xc(%ebp),%eax
801013bd:	c1 e0 05             	shl    $0x5,%eax
801013c0:	05 60 c6 10 80       	add    $0x8010c660,%eax
801013c5:	83 ec 04             	sub    $0x4,%esp
801013c8:	6a 20                	push   $0x20
801013ca:	52                   	push   %edx
801013cb:	50                   	push   %eax
801013cc:	e8 0e 43 00 00       	call   801056df <memmove>
801013d1:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801013d4:	83 ec 0c             	sub    $0xc,%esp
801013d7:	ff 75 f4             	pushl  -0xc(%ebp)
801013da:	e8 4f ee ff ff       	call   8010022e <brelse>
801013df:	83 c4 10             	add    $0x10,%esp
}
801013e2:	90                   	nop
801013e3:	c9                   	leave  
801013e4:	c3                   	ret    

801013e5 <readmbr>:


void readmbr(int dev)
{
801013e5:	55                   	push   %ebp
801013e6:	89 e5                	mov    %esp,%ebp
801013e8:	83 ec 18             	sub    $0x18,%esp
     struct buf *bp;
  
  bp = bread(dev, 0);
801013eb:	8b 45 08             	mov    0x8(%ebp),%eax
801013ee:	83 ec 08             	sub    $0x8,%esp
801013f1:	6a 00                	push   $0x0
801013f3:	50                   	push   %eax
801013f4:	e8 bd ed ff ff       	call   801001b6 <bread>
801013f9:	83 c4 10             	add    $0x10,%esp
801013fc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(&mbrI, bp->data, sizeof(struct mbr));
801013ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101402:	83 c0 18             	add    $0x18,%eax
80101405:	83 ec 04             	sub    $0x4,%esp
80101408:	68 10 02 00 00       	push   $0x210
8010140d:	50                   	push   %eax
8010140e:	68 40 12 11 80       	push   $0x80111240
80101413:	e8 c7 42 00 00       	call   801056df <memmove>
80101418:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
8010141b:	83 ec 0c             	sub    $0xc,%esp
8010141e:	ff 75 f4             	pushl  -0xc(%ebp)
80101421:	e8 08 ee ff ff       	call   8010022e <brelse>
80101426:	83 c4 10             	add    $0x10,%esp
}
80101429:	90                   	nop
8010142a:	c9                   	leave  
8010142b:	c3                   	ret    

8010142c <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
8010142c:	55                   	push   %ebp
8010142d:	89 e5                	mov    %esp,%ebp
8010142f:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  
  bp = bread(dev, bno);
80101432:	8b 55 0c             	mov    0xc(%ebp),%edx
80101435:	8b 45 08             	mov    0x8(%ebp),%eax
80101438:	83 ec 08             	sub    $0x8,%esp
8010143b:	52                   	push   %edx
8010143c:	50                   	push   %eax
8010143d:	e8 74 ed ff ff       	call   801001b6 <bread>
80101442:	83 c4 10             	add    $0x10,%esp
80101445:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
80101448:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010144b:	83 c0 18             	add    $0x18,%eax
8010144e:	83 ec 04             	sub    $0x4,%esp
80101451:	68 00 02 00 00       	push   $0x200
80101456:	6a 00                	push   $0x0
80101458:	50                   	push   %eax
80101459:	e8 c2 41 00 00       	call   80105620 <memset>
8010145e:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
80101461:	83 ec 0c             	sub    $0xc,%esp
80101464:	ff 75 f4             	pushl  -0xc(%ebp)
80101467:	e8 d5 26 00 00       	call   80103b41 <log_write>
8010146c:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
8010146f:	83 ec 0c             	sub    $0xc,%esp
80101472:	ff 75 f4             	pushl  -0xc(%ebp)
80101475:	e8 b4 ed ff ff       	call   8010022e <brelse>
8010147a:	83 c4 10             	add    $0x10,%esp
}
8010147d:	90                   	nop
8010147e:	c9                   	leave  
8010147f:	c3                   	ret    

80101480 <balloc>:
// Blocks. 

// Allocate a zeroed disk block.
static uint
balloc(uint dev,int partitionNumber)
{
80101480:	55                   	push   %ebp
80101481:	89 e5                	mov    %esp,%ebp
80101483:	83 ec 38             	sub    $0x38,%esp
  int b, bi, m;
  struct buf *bp;

    struct superblock sb;
    sb=sbs[partitionNumber];
80101486:	8b 45 0c             	mov    0xc(%ebp),%eax
80101489:	c1 e0 05             	shl    $0x5,%eax
8010148c:	05 60 c6 10 80       	add    $0x8010c660,%eax
80101491:	8b 10                	mov    (%eax),%edx
80101493:	89 55 c8             	mov    %edx,-0x38(%ebp)
80101496:	8b 50 04             	mov    0x4(%eax),%edx
80101499:	89 55 cc             	mov    %edx,-0x34(%ebp)
8010149c:	8b 50 08             	mov    0x8(%eax),%edx
8010149f:	89 55 d0             	mov    %edx,-0x30(%ebp)
801014a2:	8b 50 0c             	mov    0xc(%eax),%edx
801014a5:	89 55 d4             	mov    %edx,-0x2c(%ebp)
801014a8:	8b 50 10             	mov    0x10(%eax),%edx
801014ab:	89 55 d8             	mov    %edx,-0x28(%ebp)
801014ae:	8b 50 14             	mov    0x14(%eax),%edx
801014b1:	89 55 dc             	mov    %edx,-0x24(%ebp)
801014b4:	8b 50 18             	mov    0x18(%eax),%edx
801014b7:	89 55 e0             	mov    %edx,-0x20(%ebp)
801014ba:	8b 40 1c             	mov    0x1c(%eax),%eax
801014bd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  bp = 0;
801014c0:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(b = 0; b < sb.size; b += BPB){
801014c7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801014ce:	e9 14 01 00 00       	jmp    801015e7 <balloc+0x167>
    bp = bread(dev, BBLOCK(b, sb));
801014d3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801014d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801014d9:	8d 88 ff 0f 00 00    	lea    0xfff(%eax),%ecx
801014df:	85 c0                	test   %eax,%eax
801014e1:	0f 48 c1             	cmovs  %ecx,%eax
801014e4:	c1 f8 0c             	sar    $0xc,%eax
801014e7:	89 c1                	mov    %eax,%ecx
801014e9:	8b 45 e0             	mov    -0x20(%ebp),%eax
801014ec:	01 c8                	add    %ecx,%eax
801014ee:	01 d0                	add    %edx,%eax
801014f0:	83 ec 08             	sub    $0x8,%esp
801014f3:	50                   	push   %eax
801014f4:	ff 75 08             	pushl  0x8(%ebp)
801014f7:	e8 ba ec ff ff       	call   801001b6 <bread>
801014fc:	83 c4 10             	add    $0x10,%esp
801014ff:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
80101502:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101509:	e9 a6 00 00 00       	jmp    801015b4 <balloc+0x134>
      m = 1 << (bi % 8);
8010150e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101511:	99                   	cltd   
80101512:	c1 ea 1d             	shr    $0x1d,%edx
80101515:	01 d0                	add    %edx,%eax
80101517:	83 e0 07             	and    $0x7,%eax
8010151a:	29 d0                	sub    %edx,%eax
8010151c:	ba 01 00 00 00       	mov    $0x1,%edx
80101521:	89 c1                	mov    %eax,%ecx
80101523:	d3 e2                	shl    %cl,%edx
80101525:	89 d0                	mov    %edx,%eax
80101527:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
8010152a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010152d:	8d 50 07             	lea    0x7(%eax),%edx
80101530:	85 c0                	test   %eax,%eax
80101532:	0f 48 c2             	cmovs  %edx,%eax
80101535:	c1 f8 03             	sar    $0x3,%eax
80101538:	89 c2                	mov    %eax,%edx
8010153a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010153d:	0f b6 44 10 18       	movzbl 0x18(%eax,%edx,1),%eax
80101542:	0f b6 c0             	movzbl %al,%eax
80101545:	23 45 e8             	and    -0x18(%ebp),%eax
80101548:	85 c0                	test   %eax,%eax
8010154a:	75 64                	jne    801015b0 <balloc+0x130>
        bp->data[bi/8] |= m;  // Mark block in use.
8010154c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010154f:	8d 50 07             	lea    0x7(%eax),%edx
80101552:	85 c0                	test   %eax,%eax
80101554:	0f 48 c2             	cmovs  %edx,%eax
80101557:	c1 f8 03             	sar    $0x3,%eax
8010155a:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010155d:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
80101562:	89 d1                	mov    %edx,%ecx
80101564:	8b 55 e8             	mov    -0x18(%ebp),%edx
80101567:	09 ca                	or     %ecx,%edx
80101569:	89 d1                	mov    %edx,%ecx
8010156b:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010156e:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
        log_write(bp);
80101572:	83 ec 0c             	sub    $0xc,%esp
80101575:	ff 75 ec             	pushl  -0x14(%ebp)
80101578:	e8 c4 25 00 00       	call   80103b41 <log_write>
8010157d:	83 c4 10             	add    $0x10,%esp
        brelse(bp);
80101580:	83 ec 0c             	sub    $0xc,%esp
80101583:	ff 75 ec             	pushl  -0x14(%ebp)
80101586:	e8 a3 ec ff ff       	call   8010022e <brelse>
8010158b:	83 c4 10             	add    $0x10,%esp
        bzero(dev, b + bi);
8010158e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101591:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101594:	01 c2                	add    %eax,%edx
80101596:	8b 45 08             	mov    0x8(%ebp),%eax
80101599:	83 ec 08             	sub    $0x8,%esp
8010159c:	52                   	push   %edx
8010159d:	50                   	push   %eax
8010159e:	e8 89 fe ff ff       	call   8010142c <bzero>
801015a3:	83 c4 10             	add    $0x10,%esp
        return b + bi;
801015a6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801015a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015ac:	01 d0                	add    %edx,%eax
801015ae:	eb 52                	jmp    80101602 <balloc+0x182>
    struct superblock sb;
    sb=sbs[partitionNumber];
  bp = 0;
  for(b = 0; b < sb.size; b += BPB){
    bp = bread(dev, BBLOCK(b, sb));
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
801015b0:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801015b4:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
801015bb:	7f 15                	jg     801015d2 <balloc+0x152>
801015bd:	8b 55 f4             	mov    -0xc(%ebp),%edx
801015c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015c3:	01 d0                	add    %edx,%eax
801015c5:	89 c2                	mov    %eax,%edx
801015c7:	8b 45 c8             	mov    -0x38(%ebp),%eax
801015ca:	39 c2                	cmp    %eax,%edx
801015cc:	0f 82 3c ff ff ff    	jb     8010150e <balloc+0x8e>
        brelse(bp);
        bzero(dev, b + bi);
        return b + bi;
      }
    }
    brelse(bp);
801015d2:	83 ec 0c             	sub    $0xc,%esp
801015d5:	ff 75 ec             	pushl  -0x14(%ebp)
801015d8:	e8 51 ec ff ff       	call   8010022e <brelse>
801015dd:	83 c4 10             	add    $0x10,%esp
  struct buf *bp;

    struct superblock sb;
    sb=sbs[partitionNumber];
  bp = 0;
  for(b = 0; b < sb.size; b += BPB){
801015e0:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801015e7:	8b 55 c8             	mov    -0x38(%ebp),%edx
801015ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801015ed:	39 c2                	cmp    %eax,%edx
801015ef:	0f 87 de fe ff ff    	ja     801014d3 <balloc+0x53>
        return b + bi;
      }
    }
    brelse(bp);
  }
  panic("balloc: out of blocks");
801015f5:	83 ec 0c             	sub    $0xc,%esp
801015f8:	68 94 89 10 80       	push   $0x80108994
801015fd:	e8 64 ef ff ff       	call   80100566 <panic>
}
80101602:	c9                   	leave  
80101603:	c3                   	ret    

80101604 <bfree>:

// Free a disk block.
static void
bfree(int dev, uint b,int partitionNumber)
{
80101604:	55                   	push   %ebp
80101605:	89 e5                	mov    %esp,%ebp
80101607:	83 ec 38             	sub    $0x38,%esp
  struct buf *bp;
  int bi, m;
    struct superblock sb;
    sb=sbs[partitionNumber];
8010160a:	8b 45 10             	mov    0x10(%ebp),%eax
8010160d:	c1 e0 05             	shl    $0x5,%eax
80101610:	05 60 c6 10 80       	add    $0x8010c660,%eax
80101615:	8b 10                	mov    (%eax),%edx
80101617:	89 55 cc             	mov    %edx,-0x34(%ebp)
8010161a:	8b 50 04             	mov    0x4(%eax),%edx
8010161d:	89 55 d0             	mov    %edx,-0x30(%ebp)
80101620:	8b 50 08             	mov    0x8(%eax),%edx
80101623:	89 55 d4             	mov    %edx,-0x2c(%ebp)
80101626:	8b 50 0c             	mov    0xc(%eax),%edx
80101629:	89 55 d8             	mov    %edx,-0x28(%ebp)
8010162c:	8b 50 10             	mov    0x10(%eax),%edx
8010162f:	89 55 dc             	mov    %edx,-0x24(%ebp)
80101632:	8b 50 14             	mov    0x14(%eax),%edx
80101635:	89 55 e0             	mov    %edx,-0x20(%ebp)
80101638:	8b 50 18             	mov    0x18(%eax),%edx
8010163b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
8010163e:	8b 40 1c             	mov    0x1c(%eax),%eax
80101641:	89 45 e8             	mov    %eax,-0x18(%ebp)
  readsb(dev,partitionNumber);
80101644:	83 ec 08             	sub    $0x8,%esp
80101647:	ff 75 10             	pushl  0x10(%ebp)
8010164a:	ff 75 08             	pushl  0x8(%ebp)
8010164d:	e8 34 fd ff ff       	call   80101386 <readsb>
80101652:	83 c4 10             	add    $0x10,%esp
  bp = bread(dev, BBLOCK(b, sb));
80101655:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101658:	8b 55 0c             	mov    0xc(%ebp),%edx
8010165b:	89 d1                	mov    %edx,%ecx
8010165d:	c1 e9 0c             	shr    $0xc,%ecx
80101660:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80101663:	01 ca                	add    %ecx,%edx
80101665:	01 c2                	add    %eax,%edx
80101667:	8b 45 08             	mov    0x8(%ebp),%eax
8010166a:	83 ec 08             	sub    $0x8,%esp
8010166d:	52                   	push   %edx
8010166e:	50                   	push   %eax
8010166f:	e8 42 eb ff ff       	call   801001b6 <bread>
80101674:	83 c4 10             	add    $0x10,%esp
80101677:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
8010167a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010167d:	25 ff 0f 00 00       	and    $0xfff,%eax
80101682:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
80101685:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101688:	99                   	cltd   
80101689:	c1 ea 1d             	shr    $0x1d,%edx
8010168c:	01 d0                	add    %edx,%eax
8010168e:	83 e0 07             	and    $0x7,%eax
80101691:	29 d0                	sub    %edx,%eax
80101693:	ba 01 00 00 00       	mov    $0x1,%edx
80101698:	89 c1                	mov    %eax,%ecx
8010169a:	d3 e2                	shl    %cl,%edx
8010169c:	89 d0                	mov    %edx,%eax
8010169e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
801016a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801016a4:	8d 50 07             	lea    0x7(%eax),%edx
801016a7:	85 c0                	test   %eax,%eax
801016a9:	0f 48 c2             	cmovs  %edx,%eax
801016ac:	c1 f8 03             	sar    $0x3,%eax
801016af:	89 c2                	mov    %eax,%edx
801016b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801016b4:	0f b6 44 10 18       	movzbl 0x18(%eax,%edx,1),%eax
801016b9:	0f b6 c0             	movzbl %al,%eax
801016bc:	23 45 ec             	and    -0x14(%ebp),%eax
801016bf:	85 c0                	test   %eax,%eax
801016c1:	75 0d                	jne    801016d0 <bfree+0xcc>
    panic("freeing free block");
801016c3:	83 ec 0c             	sub    $0xc,%esp
801016c6:	68 aa 89 10 80       	push   $0x801089aa
801016cb:	e8 96 ee ff ff       	call   80100566 <panic>
  bp->data[bi/8] &= ~m;
801016d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801016d3:	8d 50 07             	lea    0x7(%eax),%edx
801016d6:	85 c0                	test   %eax,%eax
801016d8:	0f 48 c2             	cmovs  %edx,%eax
801016db:	c1 f8 03             	sar    $0x3,%eax
801016de:	8b 55 f4             	mov    -0xc(%ebp),%edx
801016e1:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
801016e6:	89 d1                	mov    %edx,%ecx
801016e8:	8b 55 ec             	mov    -0x14(%ebp),%edx
801016eb:	f7 d2                	not    %edx
801016ed:	21 ca                	and    %ecx,%edx
801016ef:	89 d1                	mov    %edx,%ecx
801016f1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801016f4:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
  log_write(bp);
801016f8:	83 ec 0c             	sub    $0xc,%esp
801016fb:	ff 75 f4             	pushl  -0xc(%ebp)
801016fe:	e8 3e 24 00 00       	call   80103b41 <log_write>
80101703:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101706:	83 ec 0c             	sub    $0xc,%esp
80101709:	ff 75 f4             	pushl  -0xc(%ebp)
8010170c:	e8 1d eb ff ff       	call   8010022e <brelse>
80101711:	83 c4 10             	add    $0x10,%esp
}
80101714:	90                   	nop
80101715:	c9                   	leave  
80101716:	c3                   	ret    

80101717 <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(int dev)
{
80101717:	55                   	push   %ebp
80101718:	89 e5                	mov    %esp,%ebp
8010171a:	57                   	push   %edi
8010171b:	56                   	push   %esi
8010171c:	53                   	push   %ebx
8010171d:	83 ec 4c             	sub    $0x4c,%esp
    //TODO: change ot iterate over all partitions
  initlock(&icache.lock, "icache");
80101720:	83 ec 08             	sub    $0x8,%esp
80101723:	68 bd 89 10 80       	push   $0x801089bd
80101728:	68 60 14 11 80       	push   $0x80111460
8010172d:	e8 69 3c 00 00       	call   8010539b <initlock>
80101732:	83 c4 10             	add    $0x10,%esp
  readmbr(dev);
80101735:	83 ec 0c             	sub    $0xc,%esp
80101738:	ff 75 08             	pushl  0x8(%ebp)
8010173b:	e8 a5 fc ff ff       	call   801013e5 <readmbr>
80101740:	83 c4 10             	add    $0x10,%esp
  int i;
 
  for(i=0;i<NPARTITIONS;i++){
80101743:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
8010174a:	e9 12 01 00 00       	jmp    80101861 <iinit+0x14a>
      if(mbrI.partitions[i].flags==PART_BOOTABLE&&bootfrom==-1){
8010174f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80101752:	89 d0                	mov    %edx,%eax
80101754:	c1 e0 02             	shl    $0x2,%eax
80101757:	01 d0                	add    %edx,%eax
80101759:	c1 e0 02             	shl    $0x2,%eax
8010175c:	05 f0 13 11 80       	add    $0x801113f0,%eax
80101761:	8b 40 0e             	mov    0xe(%eax),%eax
80101764:	83 f8 02             	cmp    $0x2,%eax
80101767:	75 12                	jne    8010177b <iinit+0x64>
80101769:	a1 18 90 10 80       	mov    0x80109018,%eax
8010176e:	83 f8 ff             	cmp    $0xffffffff,%eax
80101771:	75 08                	jne    8010177b <iinit+0x64>
          bootfrom=i;
80101773:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101776:	a3 18 90 10 80       	mov    %eax,0x80109018
          
      }
      partitions[i].dev=dev;
8010177b:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010177e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80101781:	89 d0                	mov    %edx,%eax
80101783:	01 c0                	add    %eax,%eax
80101785:	01 d0                	add    %edx,%eax
80101787:	c1 e0 03             	shl    $0x3,%eax
8010178a:	05 00 08 11 80       	add    $0x80110800,%eax
8010178f:	89 08                	mov    %ecx,(%eax)
      partitions[i].flags=mbrI.partitions[i].flags;
80101791:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80101794:	89 d0                	mov    %edx,%eax
80101796:	c1 e0 02             	shl    $0x2,%eax
80101799:	01 d0                	add    %edx,%eax
8010179b:	c1 e0 02             	shl    $0x2,%eax
8010179e:	05 f0 13 11 80       	add    $0x801113f0,%eax
801017a3:	8b 48 0e             	mov    0xe(%eax),%ecx
801017a6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801017a9:	89 d0                	mov    %edx,%eax
801017ab:	01 c0                	add    %eax,%eax
801017ad:	01 d0                	add    %edx,%eax
801017af:	c1 e0 03             	shl    $0x3,%eax
801017b2:	05 00 08 11 80       	add    $0x80110800,%eax
801017b7:	89 48 04             	mov    %ecx,0x4(%eax)
      partitions[i].type=mbrI.partitions[i].type;
801017ba:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801017bd:	89 d0                	mov    %edx,%eax
801017bf:	c1 e0 02             	shl    $0x2,%eax
801017c2:	01 d0                	add    %edx,%eax
801017c4:	c1 e0 02             	shl    $0x2,%eax
801017c7:	05 f0 13 11 80       	add    $0x801113f0,%eax
801017cc:	8b 48 12             	mov    0x12(%eax),%ecx
801017cf:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801017d2:	89 d0                	mov    %edx,%eax
801017d4:	01 c0                	add    %eax,%eax
801017d6:	01 d0                	add    %edx,%eax
801017d8:	c1 e0 03             	shl    $0x3,%eax
801017db:	05 00 08 11 80       	add    $0x80110800,%eax
801017e0:	89 48 08             	mov    %ecx,0x8(%eax)
      partitions[i].number=mbrI.partitions[i].number;
801017e3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801017e6:	89 d0                	mov    %edx,%eax
801017e8:	c1 e0 02             	shl    $0x2,%eax
801017eb:	01 d0                	add    %edx,%eax
801017ed:	c1 e0 02             	shl    $0x2,%eax
801017f0:	05 00 14 11 80       	add    $0x80111400,%eax
801017f5:	8b 48 0e             	mov    0xe(%eax),%ecx
801017f8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801017fb:	89 d0                	mov    %edx,%eax
801017fd:	01 c0                	add    %eax,%eax
801017ff:	01 d0                	add    %edx,%eax
80101801:	c1 e0 03             	shl    $0x3,%eax
80101804:	05 10 08 11 80       	add    $0x80110810,%eax
80101809:	89 48 04             	mov    %ecx,0x4(%eax)
      partitions[i].offset=mbrI.partitions[i].offset;
8010180c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010180f:	89 d0                	mov    %edx,%eax
80101811:	c1 e0 02             	shl    $0x2,%eax
80101814:	01 d0                	add    %edx,%eax
80101816:	c1 e0 02             	shl    $0x2,%eax
80101819:	05 f0 13 11 80       	add    $0x801113f0,%eax
8010181e:	8b 48 16             	mov    0x16(%eax),%ecx
80101821:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80101824:	89 d0                	mov    %edx,%eax
80101826:	01 c0                	add    %eax,%eax
80101828:	01 d0                	add    %edx,%eax
8010182a:	c1 e0 03             	shl    $0x3,%eax
8010182d:	05 00 08 11 80       	add    $0x80110800,%eax
80101832:	89 48 0c             	mov    %ecx,0xc(%eax)
      partitions[i].size=mbrI.partitions[i].size;
80101835:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80101838:	89 d0                	mov    %edx,%eax
8010183a:	c1 e0 02             	shl    $0x2,%eax
8010183d:	01 d0                	add    %edx,%eax
8010183f:	c1 e0 02             	shl    $0x2,%eax
80101842:	05 f0 13 11 80       	add    $0x801113f0,%eax
80101847:	8b 48 1a             	mov    0x1a(%eax),%ecx
8010184a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010184d:	89 d0                	mov    %edx,%eax
8010184f:	01 c0                	add    %eax,%eax
80101851:	01 d0                	add    %edx,%eax
80101853:	c1 e0 03             	shl    $0x3,%eax
80101856:	05 10 08 11 80       	add    $0x80110810,%eax
8010185b:	89 08                	mov    %ecx,(%eax)
    //TODO: change ot iterate over all partitions
  initlock(&icache.lock, "icache");
  readmbr(dev);
  int i;
 
  for(i=0;i<NPARTITIONS;i++){
8010185d:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80101861:	83 7d e4 03          	cmpl   $0x3,-0x1c(%ebp)
80101865:	0f 8e e4 fe ff ff    	jle    8010174f <iinit+0x38>
      partitions[i].number=mbrI.partitions[i].number;
      partitions[i].offset=mbrI.partitions[i].offset;
      partitions[i].size=mbrI.partitions[i].size;
  }
  
  if(bootfrom==-1){
8010186b:	a1 18 90 10 80       	mov    0x80109018,%eax
80101870:	83 f8 ff             	cmp    $0xffffffff,%eax
80101873:	75 0d                	jne    80101882 <iinit+0x16b>
      panic("no bootable partition");
80101875:	83 ec 0c             	sub    $0xc,%esp
80101878:	68 c4 89 10 80       	push   $0x801089c4
8010187d:	e8 e4 ec ff ff       	call   80100566 <panic>
  }
  readsb(dev, bootfrom);
80101882:	a1 18 90 10 80       	mov    0x80109018,%eax
80101887:	83 ec 08             	sub    $0x8,%esp
8010188a:	50                   	push   %eax
8010188b:	ff 75 08             	pushl  0x8(%ebp)
8010188e:	e8 f3 fa ff ff       	call   80101386 <readsb>
80101893:	83 c4 10             	add    $0x10,%esp
  struct superblock sb;
  sb=sbs[bootfrom];
80101896:	a1 18 90 10 80       	mov    0x80109018,%eax
8010189b:	c1 e0 05             	shl    $0x5,%eax
8010189e:	05 60 c6 10 80       	add    $0x8010c660,%eax
801018a3:	8b 10                	mov    (%eax),%edx
801018a5:	89 55 c4             	mov    %edx,-0x3c(%ebp)
801018a8:	8b 50 04             	mov    0x4(%eax),%edx
801018ab:	89 55 c8             	mov    %edx,-0x38(%ebp)
801018ae:	8b 50 08             	mov    0x8(%eax),%edx
801018b1:	89 55 cc             	mov    %edx,-0x34(%ebp)
801018b4:	8b 50 0c             	mov    0xc(%eax),%edx
801018b7:	89 55 d0             	mov    %edx,-0x30(%ebp)
801018ba:	8b 50 10             	mov    0x10(%eax),%edx
801018bd:	89 55 d4             	mov    %edx,-0x2c(%ebp)
801018c0:	8b 50 14             	mov    0x14(%eax),%edx
801018c3:	89 55 d8             	mov    %edx,-0x28(%ebp)
801018c6:	8b 50 18             	mov    0x18(%eax),%edx
801018c9:	89 55 dc             	mov    %edx,-0x24(%ebp)
801018cc:	8b 40 1c             	mov    0x1c(%eax),%eax
801018cf:	89 45 e0             	mov    %eax,-0x20(%ebp)
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d inodestart %d bmap start %d\n", sb.size,
801018d2:	8b 45 dc             	mov    -0x24(%ebp),%eax
801018d5:	89 45 b4             	mov    %eax,-0x4c(%ebp)
801018d8:	8b 7d d8             	mov    -0x28(%ebp),%edi
801018db:	8b 75 d4             	mov    -0x2c(%ebp),%esi
801018de:	8b 5d d0             	mov    -0x30(%ebp),%ebx
801018e1:	8b 4d cc             	mov    -0x34(%ebp),%ecx
801018e4:	8b 55 c8             	mov    -0x38(%ebp),%edx
801018e7:	8b 45 c4             	mov    -0x3c(%ebp),%eax
801018ea:	ff 75 b4             	pushl  -0x4c(%ebp)
801018ed:	57                   	push   %edi
801018ee:	56                   	push   %esi
801018ef:	53                   	push   %ebx
801018f0:	51                   	push   %ecx
801018f1:	52                   	push   %edx
801018f2:	50                   	push   %eax
801018f3:	68 dc 89 10 80       	push   $0x801089dc
801018f8:	e8 c9 ea ff ff       	call   801003c6 <cprintf>
801018fd:	83 c4 20             	add    $0x20,%esp
          sb.nblocks, sb.ninodes, sb.nlog, sb.logstart, sb.inodestart, sb.bmapstart);
}
80101900:	90                   	nop
80101901:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101904:	5b                   	pop    %ebx
80101905:	5e                   	pop    %esi
80101906:	5f                   	pop    %edi
80101907:	5d                   	pop    %ebp
80101908:	c3                   	ret    

80101909 <ialloc>:
//PAGEBREAK!
// Allocate a new inode with the given type on device dev.
// A free inode has a type of zero.
struct inode*
ialloc(uint dev, short type,int partitionNumber)
{
80101909:	55                   	push   %ebp
8010190a:	89 e5                	mov    %esp,%ebp
8010190c:	83 ec 48             	sub    $0x48,%esp
8010190f:	8b 45 0c             	mov    0xc(%ebp),%eax
80101912:	66 89 45 c4          	mov    %ax,-0x3c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;
    struct superblock sb;
    sb=sbs[partitionNumber];
80101916:	8b 45 10             	mov    0x10(%ebp),%eax
80101919:	c1 e0 05             	shl    $0x5,%eax
8010191c:	05 60 c6 10 80       	add    $0x8010c660,%eax
80101921:	8b 10                	mov    (%eax),%edx
80101923:	89 55 cc             	mov    %edx,-0x34(%ebp)
80101926:	8b 50 04             	mov    0x4(%eax),%edx
80101929:	89 55 d0             	mov    %edx,-0x30(%ebp)
8010192c:	8b 50 08             	mov    0x8(%eax),%edx
8010192f:	89 55 d4             	mov    %edx,-0x2c(%ebp)
80101932:	8b 50 0c             	mov    0xc(%eax),%edx
80101935:	89 55 d8             	mov    %edx,-0x28(%ebp)
80101938:	8b 50 10             	mov    0x10(%eax),%edx
8010193b:	89 55 dc             	mov    %edx,-0x24(%ebp)
8010193e:	8b 50 14             	mov    0x14(%eax),%edx
80101941:	89 55 e0             	mov    %edx,-0x20(%ebp)
80101944:	8b 50 18             	mov    0x18(%eax),%edx
80101947:	89 55 e4             	mov    %edx,-0x1c(%ebp)
8010194a:	8b 40 1c             	mov    0x1c(%eax),%eax
8010194d:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(inum = 1; inum < sb.ninodes; inum++){
80101950:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
80101957:	e9 a5 00 00 00       	jmp    80101a01 <ialloc+0xf8>
    bp = bread(dev, IBLOCK(inum, sb));
8010195c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010195f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101962:	89 d1                	mov    %edx,%ecx
80101964:	c1 e9 03             	shr    $0x3,%ecx
80101967:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010196a:	01 ca                	add    %ecx,%edx
8010196c:	01 d0                	add    %edx,%eax
8010196e:	83 ec 08             	sub    $0x8,%esp
80101971:	50                   	push   %eax
80101972:	ff 75 08             	pushl  0x8(%ebp)
80101975:	e8 3c e8 ff ff       	call   801001b6 <bread>
8010197a:	83 c4 10             	add    $0x10,%esp
8010197d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
80101980:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101983:	8d 50 18             	lea    0x18(%eax),%edx
80101986:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101989:	83 e0 07             	and    $0x7,%eax
8010198c:	c1 e0 06             	shl    $0x6,%eax
8010198f:	01 d0                	add    %edx,%eax
80101991:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
80101994:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101997:	0f b7 00             	movzwl (%eax),%eax
8010199a:	66 85 c0             	test   %ax,%ax
8010199d:	75 50                	jne    801019ef <ialloc+0xe6>
      memset(dip, 0, sizeof(*dip));
8010199f:	83 ec 04             	sub    $0x4,%esp
801019a2:	6a 40                	push   $0x40
801019a4:	6a 00                	push   $0x0
801019a6:	ff 75 ec             	pushl  -0x14(%ebp)
801019a9:	e8 72 3c 00 00       	call   80105620 <memset>
801019ae:	83 c4 10             	add    $0x10,%esp
      dip->type = type;
801019b1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801019b4:	0f b7 55 c4          	movzwl -0x3c(%ebp),%edx
801019b8:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
801019bb:	83 ec 0c             	sub    $0xc,%esp
801019be:	ff 75 f0             	pushl  -0x10(%ebp)
801019c1:	e8 7b 21 00 00       	call   80103b41 <log_write>
801019c6:	83 c4 10             	add    $0x10,%esp
      brelse(bp);
801019c9:	83 ec 0c             	sub    $0xc,%esp
801019cc:	ff 75 f0             	pushl  -0x10(%ebp)
801019cf:	e8 5a e8 ff ff       	call   8010022e <brelse>
801019d4:	83 c4 10             	add    $0x10,%esp
      return iget(dev, inum,partitionNumber);
801019d7:	8b 55 10             	mov    0x10(%ebp),%edx
801019da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019dd:	83 ec 04             	sub    $0x4,%esp
801019e0:	52                   	push   %edx
801019e1:	50                   	push   %eax
801019e2:	ff 75 08             	pushl  0x8(%ebp)
801019e5:	e8 38 01 00 00       	call   80101b22 <iget>
801019ea:	83 c4 10             	add    $0x10,%esp
801019ed:	eb 2d                	jmp    80101a1c <ialloc+0x113>
    }
    brelse(bp);
801019ef:	83 ec 0c             	sub    $0xc,%esp
801019f2:	ff 75 f0             	pushl  -0x10(%ebp)
801019f5:	e8 34 e8 ff ff       	call   8010022e <brelse>
801019fa:	83 c4 10             	add    $0x10,%esp
  int inum;
  struct buf *bp;
  struct dinode *dip;
    struct superblock sb;
    sb=sbs[partitionNumber];
  for(inum = 1; inum < sb.ninodes; inum++){
801019fd:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101a01:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80101a04:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a07:	39 c2                	cmp    %eax,%edx
80101a09:	0f 87 4d ff ff ff    	ja     8010195c <ialloc+0x53>
      brelse(bp);
      return iget(dev, inum,partitionNumber);
    }
    brelse(bp);
  }
  panic("ialloc: no inodes");
80101a0f:	83 ec 0c             	sub    $0xc,%esp
80101a12:	68 2f 8a 10 80       	push   $0x80108a2f
80101a17:	e8 4a eb ff ff       	call   80100566 <panic>
}
80101a1c:	c9                   	leave  
80101a1d:	c3                   	ret    

80101a1e <iupdate>:

// Copy a modified in-memory inode to disk.
void
iupdate(struct inode *ip)
{
80101a1e:	55                   	push   %ebp
80101a1f:	89 e5                	mov    %esp,%ebp
80101a21:	83 ec 38             	sub    $0x38,%esp
  struct buf *bp;
  struct dinode *dip;
    struct superblock sb;

    sb=sbs[ip->part->number];
80101a24:	8b 45 08             	mov    0x8(%ebp),%eax
80101a27:	8b 40 50             	mov    0x50(%eax),%eax
80101a2a:	8b 40 14             	mov    0x14(%eax),%eax
80101a2d:	c1 e0 05             	shl    $0x5,%eax
80101a30:	05 60 c6 10 80       	add    $0x8010c660,%eax
80101a35:	8b 10                	mov    (%eax),%edx
80101a37:	89 55 d0             	mov    %edx,-0x30(%ebp)
80101a3a:	8b 50 04             	mov    0x4(%eax),%edx
80101a3d:	89 55 d4             	mov    %edx,-0x2c(%ebp)
80101a40:	8b 50 08             	mov    0x8(%eax),%edx
80101a43:	89 55 d8             	mov    %edx,-0x28(%ebp)
80101a46:	8b 50 0c             	mov    0xc(%eax),%edx
80101a49:	89 55 dc             	mov    %edx,-0x24(%ebp)
80101a4c:	8b 50 10             	mov    0x10(%eax),%edx
80101a4f:	89 55 e0             	mov    %edx,-0x20(%ebp)
80101a52:	8b 50 14             	mov    0x14(%eax),%edx
80101a55:	89 55 e4             	mov    %edx,-0x1c(%ebp)
80101a58:	8b 50 18             	mov    0x18(%eax),%edx
80101a5b:	89 55 e8             	mov    %edx,-0x18(%ebp)
80101a5e:	8b 40 1c             	mov    0x1c(%eax),%eax
80101a61:	89 45 ec             	mov    %eax,-0x14(%ebp)
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101a64:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101a67:	8b 45 08             	mov    0x8(%ebp),%eax
80101a6a:	8b 40 04             	mov    0x4(%eax),%eax
80101a6d:	c1 e8 03             	shr    $0x3,%eax
80101a70:	89 c1                	mov    %eax,%ecx
80101a72:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101a75:	01 c8                	add    %ecx,%eax
80101a77:	01 c2                	add    %eax,%edx
80101a79:	8b 45 08             	mov    0x8(%ebp),%eax
80101a7c:	8b 00                	mov    (%eax),%eax
80101a7e:	83 ec 08             	sub    $0x8,%esp
80101a81:	52                   	push   %edx
80101a82:	50                   	push   %eax
80101a83:	e8 2e e7 ff ff       	call   801001b6 <bread>
80101a88:	83 c4 10             	add    $0x10,%esp
80101a8b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
80101a8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a91:	8d 50 18             	lea    0x18(%eax),%edx
80101a94:	8b 45 08             	mov    0x8(%ebp),%eax
80101a97:	8b 40 04             	mov    0x4(%eax),%eax
80101a9a:	83 e0 07             	and    $0x7,%eax
80101a9d:	c1 e0 06             	shl    $0x6,%eax
80101aa0:	01 d0                	add    %edx,%eax
80101aa2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
80101aa5:	8b 45 08             	mov    0x8(%ebp),%eax
80101aa8:	0f b7 50 10          	movzwl 0x10(%eax),%edx
80101aac:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101aaf:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
80101ab2:	8b 45 08             	mov    0x8(%ebp),%eax
80101ab5:	0f b7 50 12          	movzwl 0x12(%eax),%edx
80101ab9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101abc:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
80101ac0:	8b 45 08             	mov    0x8(%ebp),%eax
80101ac3:	0f b7 50 14          	movzwl 0x14(%eax),%edx
80101ac7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101aca:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
80101ace:	8b 45 08             	mov    0x8(%ebp),%eax
80101ad1:	0f b7 50 16          	movzwl 0x16(%eax),%edx
80101ad5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ad8:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
80101adc:	8b 45 08             	mov    0x8(%ebp),%eax
80101adf:	8b 50 18             	mov    0x18(%eax),%edx
80101ae2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ae5:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
80101ae8:	8b 45 08             	mov    0x8(%ebp),%eax
80101aeb:	8d 50 1c             	lea    0x1c(%eax),%edx
80101aee:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101af1:	83 c0 0c             	add    $0xc,%eax
80101af4:	83 ec 04             	sub    $0x4,%esp
80101af7:	6a 34                	push   $0x34
80101af9:	52                   	push   %edx
80101afa:	50                   	push   %eax
80101afb:	e8 df 3b 00 00       	call   801056df <memmove>
80101b00:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
80101b03:	83 ec 0c             	sub    $0xc,%esp
80101b06:	ff 75 f4             	pushl  -0xc(%ebp)
80101b09:	e8 33 20 00 00       	call   80103b41 <log_write>
80101b0e:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101b11:	83 ec 0c             	sub    $0xc,%esp
80101b14:	ff 75 f4             	pushl  -0xc(%ebp)
80101b17:	e8 12 e7 ff ff       	call   8010022e <brelse>
80101b1c:	83 c4 10             	add    $0x10,%esp
}
80101b1f:	90                   	nop
80101b20:	c9                   	leave  
80101b21:	c3                   	ret    

80101b22 <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum,uint partitionNumber)
{
80101b22:	55                   	push   %ebp
80101b23:	89 e5                	mov    %esp,%ebp
80101b25:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
80101b28:	83 ec 0c             	sub    $0xc,%esp
80101b2b:	68 60 14 11 80       	push   $0x80111460
80101b30:	e8 88 38 00 00       	call   801053bd <acquire>
80101b35:	83 c4 10             	add    $0x10,%esp

  // Is the inode already cached?
  empty = 0;
80101b38:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101b3f:	c7 45 f4 94 14 11 80 	movl   $0x80111494,-0xc(%ebp)
80101b46:	eb 6e                	jmp    80101bb6 <iget+0x94>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum&&ip->part->number==partitionNumber){
80101b48:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b4b:	8b 40 08             	mov    0x8(%eax),%eax
80101b4e:	85 c0                	test   %eax,%eax
80101b50:	7e 4a                	jle    80101b9c <iget+0x7a>
80101b52:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b55:	8b 00                	mov    (%eax),%eax
80101b57:	3b 45 08             	cmp    0x8(%ebp),%eax
80101b5a:	75 40                	jne    80101b9c <iget+0x7a>
80101b5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b5f:	8b 40 04             	mov    0x4(%eax),%eax
80101b62:	3b 45 0c             	cmp    0xc(%ebp),%eax
80101b65:	75 35                	jne    80101b9c <iget+0x7a>
80101b67:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b6a:	8b 40 50             	mov    0x50(%eax),%eax
80101b6d:	8b 40 14             	mov    0x14(%eax),%eax
80101b70:	3b 45 10             	cmp    0x10(%ebp),%eax
80101b73:	75 27                	jne    80101b9c <iget+0x7a>
      ip->ref++;
80101b75:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b78:	8b 40 08             	mov    0x8(%eax),%eax
80101b7b:	8d 50 01             	lea    0x1(%eax),%edx
80101b7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b81:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
80101b84:	83 ec 0c             	sub    $0xc,%esp
80101b87:	68 60 14 11 80       	push   $0x80111460
80101b8c:	e8 93 38 00 00       	call   80105424 <release>
80101b91:	83 c4 10             	add    $0x10,%esp
      return ip;
80101b94:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b97:	e9 8c 00 00 00       	jmp    80101c28 <iget+0x106>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
80101b9c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101ba0:	75 10                	jne    80101bb2 <iget+0x90>
80101ba2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ba5:	8b 40 08             	mov    0x8(%eax),%eax
80101ba8:	85 c0                	test   %eax,%eax
80101baa:	75 06                	jne    80101bb2 <iget+0x90>
      empty = ip;
80101bac:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101baf:	89 45 f0             	mov    %eax,-0x10(%ebp)

  acquire(&icache.lock);

  // Is the inode already cached?
  empty = 0;
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101bb2:	83 45 f4 54          	addl   $0x54,-0xc(%ebp)
80101bb6:	81 7d f4 fc 24 11 80 	cmpl   $0x801124fc,-0xc(%ebp)
80101bbd:	72 89                	jb     80101b48 <iget+0x26>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
      empty = ip;
  }

  // Recycle an inode cache entry.
  if(empty == 0)
80101bbf:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101bc3:	75 0d                	jne    80101bd2 <iget+0xb0>
    panic("iget: no inodes");
80101bc5:	83 ec 0c             	sub    $0xc,%esp
80101bc8:	68 41 8a 10 80       	push   $0x80108a41
80101bcd:	e8 94 e9 ff ff       	call   80100566 <panic>

  ip = empty;
80101bd2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101bd5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
80101bd8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101bdb:	8b 55 08             	mov    0x8(%ebp),%edx
80101bde:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
80101be0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101be3:	8b 55 0c             	mov    0xc(%ebp),%edx
80101be6:	89 50 04             	mov    %edx,0x4(%eax)
  ip->part=&(partitions[partitionNumber]);
80101be9:	8b 55 10             	mov    0x10(%ebp),%edx
80101bec:	89 d0                	mov    %edx,%eax
80101bee:	01 c0                	add    %eax,%eax
80101bf0:	01 d0                	add    %edx,%eax
80101bf2:	c1 e0 03             	shl    $0x3,%eax
80101bf5:	8d 90 00 08 11 80    	lea    -0x7feef800(%eax),%edx
80101bfb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101bfe:	89 50 50             	mov    %edx,0x50(%eax)
  ip->ref = 1;
80101c01:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101c04:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->flags = 0;
80101c0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101c0e:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  release(&icache.lock);
80101c15:	83 ec 0c             	sub    $0xc,%esp
80101c18:	68 60 14 11 80       	push   $0x80111460
80101c1d:	e8 02 38 00 00       	call   80105424 <release>
80101c22:	83 c4 10             	add    $0x10,%esp

  return ip;
80101c25:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80101c28:	c9                   	leave  
80101c29:	c3                   	ret    

80101c2a <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
80101c2a:	55                   	push   %ebp
80101c2b:	89 e5                	mov    %esp,%ebp
80101c2d:	83 ec 08             	sub    $0x8,%esp
  acquire(&icache.lock);
80101c30:	83 ec 0c             	sub    $0xc,%esp
80101c33:	68 60 14 11 80       	push   $0x80111460
80101c38:	e8 80 37 00 00       	call   801053bd <acquire>
80101c3d:	83 c4 10             	add    $0x10,%esp
  ip->ref++;
80101c40:	8b 45 08             	mov    0x8(%ebp),%eax
80101c43:	8b 40 08             	mov    0x8(%eax),%eax
80101c46:	8d 50 01             	lea    0x1(%eax),%edx
80101c49:	8b 45 08             	mov    0x8(%ebp),%eax
80101c4c:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101c4f:	83 ec 0c             	sub    $0xc,%esp
80101c52:	68 60 14 11 80       	push   $0x80111460
80101c57:	e8 c8 37 00 00       	call   80105424 <release>
80101c5c:	83 c4 10             	add    $0x10,%esp
  return ip;
80101c5f:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101c62:	c9                   	leave  
80101c63:	c3                   	ret    

80101c64 <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
80101c64:	55                   	push   %ebp
80101c65:	89 e5                	mov    %esp,%ebp
80101c67:	83 ec 38             	sub    $0x38,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
80101c6a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101c6e:	74 0a                	je     80101c7a <ilock+0x16>
80101c70:	8b 45 08             	mov    0x8(%ebp),%eax
80101c73:	8b 40 08             	mov    0x8(%eax),%eax
80101c76:	85 c0                	test   %eax,%eax
80101c78:	7f 0d                	jg     80101c87 <ilock+0x23>
    panic("ilock");
80101c7a:	83 ec 0c             	sub    $0xc,%esp
80101c7d:	68 51 8a 10 80       	push   $0x80108a51
80101c82:	e8 df e8 ff ff       	call   80100566 <panic>

  acquire(&icache.lock);
80101c87:	83 ec 0c             	sub    $0xc,%esp
80101c8a:	68 60 14 11 80       	push   $0x80111460
80101c8f:	e8 29 37 00 00       	call   801053bd <acquire>
80101c94:	83 c4 10             	add    $0x10,%esp
  while(ip->flags & I_BUSY)
80101c97:	eb 13                	jmp    80101cac <ilock+0x48>
    sleep(ip, &icache.lock);
80101c99:	83 ec 08             	sub    $0x8,%esp
80101c9c:	68 60 14 11 80       	push   $0x80111460
80101ca1:	ff 75 08             	pushl  0x8(%ebp)
80101ca4:	e8 1b 34 00 00       	call   801050c4 <sleep>
80101ca9:	83 c4 10             	add    $0x10,%esp

  if(ip == 0 || ip->ref < 1)
    panic("ilock");

  acquire(&icache.lock);
  while(ip->flags & I_BUSY)
80101cac:	8b 45 08             	mov    0x8(%ebp),%eax
80101caf:	8b 40 0c             	mov    0xc(%eax),%eax
80101cb2:	83 e0 01             	and    $0x1,%eax
80101cb5:	85 c0                	test   %eax,%eax
80101cb7:	75 e0                	jne    80101c99 <ilock+0x35>
    sleep(ip, &icache.lock);
  ip->flags |= I_BUSY;
80101cb9:	8b 45 08             	mov    0x8(%ebp),%eax
80101cbc:	8b 40 0c             	mov    0xc(%eax),%eax
80101cbf:	83 c8 01             	or     $0x1,%eax
80101cc2:	89 c2                	mov    %eax,%edx
80101cc4:	8b 45 08             	mov    0x8(%ebp),%eax
80101cc7:	89 50 0c             	mov    %edx,0xc(%eax)
  release(&icache.lock);
80101cca:	83 ec 0c             	sub    $0xc,%esp
80101ccd:	68 60 14 11 80       	push   $0x80111460
80101cd2:	e8 4d 37 00 00       	call   80105424 <release>
80101cd7:	83 c4 10             	add    $0x10,%esp

  if(!(ip->flags & I_VALID)){
80101cda:	8b 45 08             	mov    0x8(%ebp),%eax
80101cdd:	8b 40 0c             	mov    0xc(%eax),%eax
80101ce0:	83 e0 02             	and    $0x2,%eax
80101ce3:	85 c0                	test   %eax,%eax
80101ce5:	0f 85 17 01 00 00    	jne    80101e02 <ilock+0x19e>
      struct superblock sb;
      sb=sbs[ip->part->number];
80101ceb:	8b 45 08             	mov    0x8(%ebp),%eax
80101cee:	8b 40 50             	mov    0x50(%eax),%eax
80101cf1:	8b 40 14             	mov    0x14(%eax),%eax
80101cf4:	c1 e0 05             	shl    $0x5,%eax
80101cf7:	05 60 c6 10 80       	add    $0x8010c660,%eax
80101cfc:	8b 10                	mov    (%eax),%edx
80101cfe:	89 55 d0             	mov    %edx,-0x30(%ebp)
80101d01:	8b 50 04             	mov    0x4(%eax),%edx
80101d04:	89 55 d4             	mov    %edx,-0x2c(%ebp)
80101d07:	8b 50 08             	mov    0x8(%eax),%edx
80101d0a:	89 55 d8             	mov    %edx,-0x28(%ebp)
80101d0d:	8b 50 0c             	mov    0xc(%eax),%edx
80101d10:	89 55 dc             	mov    %edx,-0x24(%ebp)
80101d13:	8b 50 10             	mov    0x10(%eax),%edx
80101d16:	89 55 e0             	mov    %edx,-0x20(%ebp)
80101d19:	8b 50 14             	mov    0x14(%eax),%edx
80101d1c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
80101d1f:	8b 50 18             	mov    0x18(%eax),%edx
80101d22:	89 55 e8             	mov    %edx,-0x18(%ebp)
80101d25:	8b 40 1c             	mov    0x1c(%eax),%eax
80101d28:	89 45 ec             	mov    %eax,-0x14(%ebp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101d2b:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101d2e:	8b 45 08             	mov    0x8(%ebp),%eax
80101d31:	8b 40 04             	mov    0x4(%eax),%eax
80101d34:	c1 e8 03             	shr    $0x3,%eax
80101d37:	89 c1                	mov    %eax,%ecx
80101d39:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101d3c:	01 c8                	add    %ecx,%eax
80101d3e:	01 c2                	add    %eax,%edx
80101d40:	8b 45 08             	mov    0x8(%ebp),%eax
80101d43:	8b 00                	mov    (%eax),%eax
80101d45:	83 ec 08             	sub    $0x8,%esp
80101d48:	52                   	push   %edx
80101d49:	50                   	push   %eax
80101d4a:	e8 67 e4 ff ff       	call   801001b6 <bread>
80101d4f:	83 c4 10             	add    $0x10,%esp
80101d52:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
80101d55:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d58:	8d 50 18             	lea    0x18(%eax),%edx
80101d5b:	8b 45 08             	mov    0x8(%ebp),%eax
80101d5e:	8b 40 04             	mov    0x4(%eax),%eax
80101d61:	83 e0 07             	and    $0x7,%eax
80101d64:	c1 e0 06             	shl    $0x6,%eax
80101d67:	01 d0                	add    %edx,%eax
80101d69:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
80101d6c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101d6f:	0f b7 10             	movzwl (%eax),%edx
80101d72:	8b 45 08             	mov    0x8(%ebp),%eax
80101d75:	66 89 50 10          	mov    %dx,0x10(%eax)
    ip->major = dip->major;
80101d79:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101d7c:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80101d80:	8b 45 08             	mov    0x8(%ebp),%eax
80101d83:	66 89 50 12          	mov    %dx,0x12(%eax)
    ip->minor = dip->minor;
80101d87:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101d8a:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80101d8e:	8b 45 08             	mov    0x8(%ebp),%eax
80101d91:	66 89 50 14          	mov    %dx,0x14(%eax)
    ip->nlink = dip->nlink;
80101d95:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101d98:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80101d9c:	8b 45 08             	mov    0x8(%ebp),%eax
80101d9f:	66 89 50 16          	mov    %dx,0x16(%eax)
    ip->size = dip->size;
80101da3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101da6:	8b 50 08             	mov    0x8(%eax),%edx
80101da9:	8b 45 08             	mov    0x8(%ebp),%eax
80101dac:	89 50 18             	mov    %edx,0x18(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101daf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101db2:	8d 50 0c             	lea    0xc(%eax),%edx
80101db5:	8b 45 08             	mov    0x8(%ebp),%eax
80101db8:	83 c0 1c             	add    $0x1c,%eax
80101dbb:	83 ec 04             	sub    $0x4,%esp
80101dbe:	6a 34                	push   $0x34
80101dc0:	52                   	push   %edx
80101dc1:	50                   	push   %eax
80101dc2:	e8 18 39 00 00       	call   801056df <memmove>
80101dc7:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80101dca:	83 ec 0c             	sub    $0xc,%esp
80101dcd:	ff 75 f4             	pushl  -0xc(%ebp)
80101dd0:	e8 59 e4 ff ff       	call   8010022e <brelse>
80101dd5:	83 c4 10             	add    $0x10,%esp
    ip->flags |= I_VALID;
80101dd8:	8b 45 08             	mov    0x8(%ebp),%eax
80101ddb:	8b 40 0c             	mov    0xc(%eax),%eax
80101dde:	83 c8 02             	or     $0x2,%eax
80101de1:	89 c2                	mov    %eax,%edx
80101de3:	8b 45 08             	mov    0x8(%ebp),%eax
80101de6:	89 50 0c             	mov    %edx,0xc(%eax)
    if(ip->type == 0)
80101de9:	8b 45 08             	mov    0x8(%ebp),%eax
80101dec:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101df0:	66 85 c0             	test   %ax,%ax
80101df3:	75 0d                	jne    80101e02 <ilock+0x19e>
      panic("ilock: no type");
80101df5:	83 ec 0c             	sub    $0xc,%esp
80101df8:	68 57 8a 10 80       	push   $0x80108a57
80101dfd:	e8 64 e7 ff ff       	call   80100566 <panic>
  }
}
80101e02:	90                   	nop
80101e03:	c9                   	leave  
80101e04:	c3                   	ret    

80101e05 <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
80101e05:	55                   	push   %ebp
80101e06:	89 e5                	mov    %esp,%ebp
80101e08:	83 ec 08             	sub    $0x8,%esp
  if(ip == 0 || !(ip->flags & I_BUSY) || ip->ref < 1)
80101e0b:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101e0f:	74 17                	je     80101e28 <iunlock+0x23>
80101e11:	8b 45 08             	mov    0x8(%ebp),%eax
80101e14:	8b 40 0c             	mov    0xc(%eax),%eax
80101e17:	83 e0 01             	and    $0x1,%eax
80101e1a:	85 c0                	test   %eax,%eax
80101e1c:	74 0a                	je     80101e28 <iunlock+0x23>
80101e1e:	8b 45 08             	mov    0x8(%ebp),%eax
80101e21:	8b 40 08             	mov    0x8(%eax),%eax
80101e24:	85 c0                	test   %eax,%eax
80101e26:	7f 0d                	jg     80101e35 <iunlock+0x30>
    panic("iunlock");
80101e28:	83 ec 0c             	sub    $0xc,%esp
80101e2b:	68 66 8a 10 80       	push   $0x80108a66
80101e30:	e8 31 e7 ff ff       	call   80100566 <panic>

  acquire(&icache.lock);
80101e35:	83 ec 0c             	sub    $0xc,%esp
80101e38:	68 60 14 11 80       	push   $0x80111460
80101e3d:	e8 7b 35 00 00       	call   801053bd <acquire>
80101e42:	83 c4 10             	add    $0x10,%esp
  ip->flags &= ~I_BUSY;
80101e45:	8b 45 08             	mov    0x8(%ebp),%eax
80101e48:	8b 40 0c             	mov    0xc(%eax),%eax
80101e4b:	83 e0 fe             	and    $0xfffffffe,%eax
80101e4e:	89 c2                	mov    %eax,%edx
80101e50:	8b 45 08             	mov    0x8(%ebp),%eax
80101e53:	89 50 0c             	mov    %edx,0xc(%eax)
  wakeup(ip);
80101e56:	83 ec 0c             	sub    $0xc,%esp
80101e59:	ff 75 08             	pushl  0x8(%ebp)
80101e5c:	e8 4e 33 00 00       	call   801051af <wakeup>
80101e61:	83 c4 10             	add    $0x10,%esp
  release(&icache.lock);
80101e64:	83 ec 0c             	sub    $0xc,%esp
80101e67:	68 60 14 11 80       	push   $0x80111460
80101e6c:	e8 b3 35 00 00       	call   80105424 <release>
80101e71:	83 c4 10             	add    $0x10,%esp
}
80101e74:	90                   	nop
80101e75:	c9                   	leave  
80101e76:	c3                   	ret    

80101e77 <iput>:
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void
iput(struct inode *ip)
{
80101e77:	55                   	push   %ebp
80101e78:	89 e5                	mov    %esp,%ebp
80101e7a:	83 ec 08             	sub    $0x8,%esp
  acquire(&icache.lock);
80101e7d:	83 ec 0c             	sub    $0xc,%esp
80101e80:	68 60 14 11 80       	push   $0x80111460
80101e85:	e8 33 35 00 00       	call   801053bd <acquire>
80101e8a:	83 c4 10             	add    $0x10,%esp
  if(ip->ref == 1 && (ip->flags & I_VALID) && ip->nlink == 0){
80101e8d:	8b 45 08             	mov    0x8(%ebp),%eax
80101e90:	8b 40 08             	mov    0x8(%eax),%eax
80101e93:	83 f8 01             	cmp    $0x1,%eax
80101e96:	0f 85 a9 00 00 00    	jne    80101f45 <iput+0xce>
80101e9c:	8b 45 08             	mov    0x8(%ebp),%eax
80101e9f:	8b 40 0c             	mov    0xc(%eax),%eax
80101ea2:	83 e0 02             	and    $0x2,%eax
80101ea5:	85 c0                	test   %eax,%eax
80101ea7:	0f 84 98 00 00 00    	je     80101f45 <iput+0xce>
80101ead:	8b 45 08             	mov    0x8(%ebp),%eax
80101eb0:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80101eb4:	66 85 c0             	test   %ax,%ax
80101eb7:	0f 85 88 00 00 00    	jne    80101f45 <iput+0xce>
    // inode has no links and no other references: truncate and free.
    if(ip->flags & I_BUSY)
80101ebd:	8b 45 08             	mov    0x8(%ebp),%eax
80101ec0:	8b 40 0c             	mov    0xc(%eax),%eax
80101ec3:	83 e0 01             	and    $0x1,%eax
80101ec6:	85 c0                	test   %eax,%eax
80101ec8:	74 0d                	je     80101ed7 <iput+0x60>
      panic("iput busy");
80101eca:	83 ec 0c             	sub    $0xc,%esp
80101ecd:	68 6e 8a 10 80       	push   $0x80108a6e
80101ed2:	e8 8f e6 ff ff       	call   80100566 <panic>
    ip->flags |= I_BUSY;
80101ed7:	8b 45 08             	mov    0x8(%ebp),%eax
80101eda:	8b 40 0c             	mov    0xc(%eax),%eax
80101edd:	83 c8 01             	or     $0x1,%eax
80101ee0:	89 c2                	mov    %eax,%edx
80101ee2:	8b 45 08             	mov    0x8(%ebp),%eax
80101ee5:	89 50 0c             	mov    %edx,0xc(%eax)
    release(&icache.lock);
80101ee8:	83 ec 0c             	sub    $0xc,%esp
80101eeb:	68 60 14 11 80       	push   $0x80111460
80101ef0:	e8 2f 35 00 00       	call   80105424 <release>
80101ef5:	83 c4 10             	add    $0x10,%esp
    itrunc(ip);
80101ef8:	83 ec 0c             	sub    $0xc,%esp
80101efb:	ff 75 08             	pushl  0x8(%ebp)
80101efe:	e8 cc 01 00 00       	call   801020cf <itrunc>
80101f03:	83 c4 10             	add    $0x10,%esp
    ip->type = 0;
80101f06:	8b 45 08             	mov    0x8(%ebp),%eax
80101f09:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)
    iupdate(ip);
80101f0f:	83 ec 0c             	sub    $0xc,%esp
80101f12:	ff 75 08             	pushl  0x8(%ebp)
80101f15:	e8 04 fb ff ff       	call   80101a1e <iupdate>
80101f1a:	83 c4 10             	add    $0x10,%esp
    acquire(&icache.lock);
80101f1d:	83 ec 0c             	sub    $0xc,%esp
80101f20:	68 60 14 11 80       	push   $0x80111460
80101f25:	e8 93 34 00 00       	call   801053bd <acquire>
80101f2a:	83 c4 10             	add    $0x10,%esp
    ip->flags = 0;
80101f2d:	8b 45 08             	mov    0x8(%ebp),%eax
80101f30:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    wakeup(ip);
80101f37:	83 ec 0c             	sub    $0xc,%esp
80101f3a:	ff 75 08             	pushl  0x8(%ebp)
80101f3d:	e8 6d 32 00 00       	call   801051af <wakeup>
80101f42:	83 c4 10             	add    $0x10,%esp
  }
  ip->ref--;
80101f45:	8b 45 08             	mov    0x8(%ebp),%eax
80101f48:	8b 40 08             	mov    0x8(%eax),%eax
80101f4b:	8d 50 ff             	lea    -0x1(%eax),%edx
80101f4e:	8b 45 08             	mov    0x8(%ebp),%eax
80101f51:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101f54:	83 ec 0c             	sub    $0xc,%esp
80101f57:	68 60 14 11 80       	push   $0x80111460
80101f5c:	e8 c3 34 00 00       	call   80105424 <release>
80101f61:	83 c4 10             	add    $0x10,%esp
}
80101f64:	90                   	nop
80101f65:	c9                   	leave  
80101f66:	c3                   	ret    

80101f67 <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101f67:	55                   	push   %ebp
80101f68:	89 e5                	mov    %esp,%ebp
80101f6a:	83 ec 08             	sub    $0x8,%esp
  iunlock(ip);
80101f6d:	83 ec 0c             	sub    $0xc,%esp
80101f70:	ff 75 08             	pushl  0x8(%ebp)
80101f73:	e8 8d fe ff ff       	call   80101e05 <iunlock>
80101f78:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80101f7b:	83 ec 0c             	sub    $0xc,%esp
80101f7e:	ff 75 08             	pushl  0x8(%ebp)
80101f81:	e8 f1 fe ff ff       	call   80101e77 <iput>
80101f86:	83 c4 10             	add    $0x10,%esp
}
80101f89:	90                   	nop
80101f8a:	c9                   	leave  
80101f8b:	c3                   	ret    

80101f8c <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101f8c:	55                   	push   %ebp
80101f8d:	89 e5                	mov    %esp,%ebp
80101f8f:	53                   	push   %ebx
80101f90:	83 ec 14             	sub    $0x14,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101f93:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101f97:	77 4e                	ja     80101fe7 <bmap+0x5b>
    if((addr = ip->addrs[bn]) == 0)
80101f99:	8b 45 08             	mov    0x8(%ebp),%eax
80101f9c:	8b 55 0c             	mov    0xc(%ebp),%edx
80101f9f:	83 c2 04             	add    $0x4,%edx
80101fa2:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101fa6:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101fa9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101fad:	75 30                	jne    80101fdf <bmap+0x53>
      ip->addrs[bn] = addr = balloc(ip->dev,ip->part->number);
80101faf:	8b 45 08             	mov    0x8(%ebp),%eax
80101fb2:	8b 40 50             	mov    0x50(%eax),%eax
80101fb5:	8b 40 14             	mov    0x14(%eax),%eax
80101fb8:	89 c2                	mov    %eax,%edx
80101fba:	8b 45 08             	mov    0x8(%ebp),%eax
80101fbd:	8b 00                	mov    (%eax),%eax
80101fbf:	83 ec 08             	sub    $0x8,%esp
80101fc2:	52                   	push   %edx
80101fc3:	50                   	push   %eax
80101fc4:	e8 b7 f4 ff ff       	call   80101480 <balloc>
80101fc9:	83 c4 10             	add    $0x10,%esp
80101fcc:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101fcf:	8b 45 08             	mov    0x8(%ebp),%eax
80101fd2:	8b 55 0c             	mov    0xc(%ebp),%edx
80101fd5:	8d 4a 04             	lea    0x4(%edx),%ecx
80101fd8:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101fdb:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80101fdf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101fe2:	e9 e3 00 00 00       	jmp    801020ca <bmap+0x13e>
  }
  bn -= NDIRECT;
80101fe7:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80101feb:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101fef:	0f 87 c8 00 00 00    	ja     801020bd <bmap+0x131>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101ff5:	8b 45 08             	mov    0x8(%ebp),%eax
80101ff8:	8b 40 4c             	mov    0x4c(%eax),%eax
80101ffb:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101ffe:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102002:	75 29                	jne    8010202d <bmap+0xa1>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev,ip->part->number);
80102004:	8b 45 08             	mov    0x8(%ebp),%eax
80102007:	8b 40 50             	mov    0x50(%eax),%eax
8010200a:	8b 40 14             	mov    0x14(%eax),%eax
8010200d:	89 c2                	mov    %eax,%edx
8010200f:	8b 45 08             	mov    0x8(%ebp),%eax
80102012:	8b 00                	mov    (%eax),%eax
80102014:	83 ec 08             	sub    $0x8,%esp
80102017:	52                   	push   %edx
80102018:	50                   	push   %eax
80102019:	e8 62 f4 ff ff       	call   80101480 <balloc>
8010201e:	83 c4 10             	add    $0x10,%esp
80102021:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102024:	8b 45 08             	mov    0x8(%ebp),%eax
80102027:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010202a:	89 50 4c             	mov    %edx,0x4c(%eax)
    bp = bread(ip->dev, addr);
8010202d:	8b 45 08             	mov    0x8(%ebp),%eax
80102030:	8b 00                	mov    (%eax),%eax
80102032:	83 ec 08             	sub    $0x8,%esp
80102035:	ff 75 f4             	pushl  -0xc(%ebp)
80102038:	50                   	push   %eax
80102039:	e8 78 e1 ff ff       	call   801001b6 <bread>
8010203e:	83 c4 10             	add    $0x10,%esp
80102041:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80102044:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102047:	83 c0 18             	add    $0x18,%eax
8010204a:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
8010204d:	8b 45 0c             	mov    0xc(%ebp),%eax
80102050:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80102057:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010205a:	01 d0                	add    %edx,%eax
8010205c:	8b 00                	mov    (%eax),%eax
8010205e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102061:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102065:	75 43                	jne    801020aa <bmap+0x11e>
      a[bn] = addr = balloc(ip->dev,ip->part->number);
80102067:	8b 45 0c             	mov    0xc(%ebp),%eax
8010206a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80102071:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102074:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80102077:	8b 45 08             	mov    0x8(%ebp),%eax
8010207a:	8b 40 50             	mov    0x50(%eax),%eax
8010207d:	8b 40 14             	mov    0x14(%eax),%eax
80102080:	89 c2                	mov    %eax,%edx
80102082:	8b 45 08             	mov    0x8(%ebp),%eax
80102085:	8b 00                	mov    (%eax),%eax
80102087:	83 ec 08             	sub    $0x8,%esp
8010208a:	52                   	push   %edx
8010208b:	50                   	push   %eax
8010208c:	e8 ef f3 ff ff       	call   80101480 <balloc>
80102091:	83 c4 10             	add    $0x10,%esp
80102094:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102097:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010209a:	89 03                	mov    %eax,(%ebx)
      log_write(bp);
8010209c:	83 ec 0c             	sub    $0xc,%esp
8010209f:	ff 75 f0             	pushl  -0x10(%ebp)
801020a2:	e8 9a 1a 00 00       	call   80103b41 <log_write>
801020a7:	83 c4 10             	add    $0x10,%esp
    }
    brelse(bp);
801020aa:	83 ec 0c             	sub    $0xc,%esp
801020ad:	ff 75 f0             	pushl  -0x10(%ebp)
801020b0:	e8 79 e1 ff ff       	call   8010022e <brelse>
801020b5:	83 c4 10             	add    $0x10,%esp
    return addr;
801020b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801020bb:	eb 0d                	jmp    801020ca <bmap+0x13e>
  }

  panic("bmap: out of range");
801020bd:	83 ec 0c             	sub    $0xc,%esp
801020c0:	68 78 8a 10 80       	push   $0x80108a78
801020c5:	e8 9c e4 ff ff       	call   80100566 <panic>
}
801020ca:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801020cd:	c9                   	leave  
801020ce:	c3                   	ret    

801020cf <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
801020cf:	55                   	push   %ebp
801020d0:	89 e5                	mov    %esp,%ebp
801020d2:	83 ec 18             	sub    $0x18,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
801020d5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801020dc:	eb 51                	jmp    8010212f <itrunc+0x60>
    if(ip->addrs[i]){
801020de:	8b 45 08             	mov    0x8(%ebp),%eax
801020e1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801020e4:	83 c2 04             	add    $0x4,%edx
801020e7:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
801020eb:	85 c0                	test   %eax,%eax
801020ed:	74 3c                	je     8010212b <itrunc+0x5c>
      bfree(ip->dev, ip->addrs[i],ip->part->number);
801020ef:	8b 45 08             	mov    0x8(%ebp),%eax
801020f2:	8b 40 50             	mov    0x50(%eax),%eax
801020f5:	8b 40 14             	mov    0x14(%eax),%eax
801020f8:	89 c1                	mov    %eax,%ecx
801020fa:	8b 45 08             	mov    0x8(%ebp),%eax
801020fd:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102100:	83 c2 04             	add    $0x4,%edx
80102103:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80102107:	8b 55 08             	mov    0x8(%ebp),%edx
8010210a:	8b 12                	mov    (%edx),%edx
8010210c:	83 ec 04             	sub    $0x4,%esp
8010210f:	51                   	push   %ecx
80102110:	50                   	push   %eax
80102111:	52                   	push   %edx
80102112:	e8 ed f4 ff ff       	call   80101604 <bfree>
80102117:	83 c4 10             	add    $0x10,%esp
      ip->addrs[i] = 0;
8010211a:	8b 45 08             	mov    0x8(%ebp),%eax
8010211d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102120:	83 c2 04             	add    $0x4,%edx
80102123:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
8010212a:	00 
{
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
8010212b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010212f:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80102133:	7e a9                	jle    801020de <itrunc+0xf>
      bfree(ip->dev, ip->addrs[i],ip->part->number);
      ip->addrs[i] = 0;
    }
  }
  
  if(ip->addrs[NDIRECT]){
80102135:	8b 45 08             	mov    0x8(%ebp),%eax
80102138:	8b 40 4c             	mov    0x4c(%eax),%eax
8010213b:	85 c0                	test   %eax,%eax
8010213d:	0f 84 b9 00 00 00    	je     801021fc <itrunc+0x12d>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80102143:	8b 45 08             	mov    0x8(%ebp),%eax
80102146:	8b 50 4c             	mov    0x4c(%eax),%edx
80102149:	8b 45 08             	mov    0x8(%ebp),%eax
8010214c:	8b 00                	mov    (%eax),%eax
8010214e:	83 ec 08             	sub    $0x8,%esp
80102151:	52                   	push   %edx
80102152:	50                   	push   %eax
80102153:	e8 5e e0 ff ff       	call   801001b6 <bread>
80102158:	83 c4 10             	add    $0x10,%esp
8010215b:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
8010215e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102161:	83 c0 18             	add    $0x18,%eax
80102164:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80102167:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010216e:	eb 48                	jmp    801021b8 <itrunc+0xe9>
      if(a[j])
80102170:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102173:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010217a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010217d:	01 d0                	add    %edx,%eax
8010217f:	8b 00                	mov    (%eax),%eax
80102181:	85 c0                	test   %eax,%eax
80102183:	74 2f                	je     801021b4 <itrunc+0xe5>
        bfree(ip->dev, a[j],ip->part->number);
80102185:	8b 45 08             	mov    0x8(%ebp),%eax
80102188:	8b 40 50             	mov    0x50(%eax),%eax
8010218b:	8b 40 14             	mov    0x14(%eax),%eax
8010218e:	89 c1                	mov    %eax,%ecx
80102190:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102193:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010219a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010219d:	01 d0                	add    %edx,%eax
8010219f:	8b 00                	mov    (%eax),%eax
801021a1:	8b 55 08             	mov    0x8(%ebp),%edx
801021a4:	8b 12                	mov    (%edx),%edx
801021a6:	83 ec 04             	sub    $0x4,%esp
801021a9:	51                   	push   %ecx
801021aa:	50                   	push   %eax
801021ab:	52                   	push   %edx
801021ac:	e8 53 f4 ff ff       	call   80101604 <bfree>
801021b1:	83 c4 10             	add    $0x10,%esp
  }
  
  if(ip->addrs[NDIRECT]){
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    a = (uint*)bp->data;
    for(j = 0; j < NINDIRECT; j++){
801021b4:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801021b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801021bb:	83 f8 7f             	cmp    $0x7f,%eax
801021be:	76 b0                	jbe    80102170 <itrunc+0xa1>
      if(a[j])
        bfree(ip->dev, a[j],ip->part->number);
    }
    brelse(bp);
801021c0:	83 ec 0c             	sub    $0xc,%esp
801021c3:	ff 75 ec             	pushl  -0x14(%ebp)
801021c6:	e8 63 e0 ff ff       	call   8010022e <brelse>
801021cb:	83 c4 10             	add    $0x10,%esp
    bfree(ip->dev, ip->addrs[NDIRECT],ip->part->number);
801021ce:	8b 45 08             	mov    0x8(%ebp),%eax
801021d1:	8b 40 50             	mov    0x50(%eax),%eax
801021d4:	8b 40 14             	mov    0x14(%eax),%eax
801021d7:	89 c1                	mov    %eax,%ecx
801021d9:	8b 45 08             	mov    0x8(%ebp),%eax
801021dc:	8b 40 4c             	mov    0x4c(%eax),%eax
801021df:	8b 55 08             	mov    0x8(%ebp),%edx
801021e2:	8b 12                	mov    (%edx),%edx
801021e4:	83 ec 04             	sub    $0x4,%esp
801021e7:	51                   	push   %ecx
801021e8:	50                   	push   %eax
801021e9:	52                   	push   %edx
801021ea:	e8 15 f4 ff ff       	call   80101604 <bfree>
801021ef:	83 c4 10             	add    $0x10,%esp
    ip->addrs[NDIRECT] = 0;
801021f2:	8b 45 08             	mov    0x8(%ebp),%eax
801021f5:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  }

  ip->size = 0;
801021fc:	8b 45 08             	mov    0x8(%ebp),%eax
801021ff:	c7 40 18 00 00 00 00 	movl   $0x0,0x18(%eax)
  iupdate(ip);
80102206:	83 ec 0c             	sub    $0xc,%esp
80102209:	ff 75 08             	pushl  0x8(%ebp)
8010220c:	e8 0d f8 ff ff       	call   80101a1e <iupdate>
80102211:	83 c4 10             	add    $0x10,%esp
}
80102214:	90                   	nop
80102215:	c9                   	leave  
80102216:	c3                   	ret    

80102217 <stati>:

// Copy stat information from inode.
void
stati(struct inode *ip, struct stat *st)
{
80102217:	55                   	push   %ebp
80102218:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
8010221a:	8b 45 08             	mov    0x8(%ebp),%eax
8010221d:	8b 00                	mov    (%eax),%eax
8010221f:	89 c2                	mov    %eax,%edx
80102221:	8b 45 0c             	mov    0xc(%ebp),%eax
80102224:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
80102227:	8b 45 08             	mov    0x8(%ebp),%eax
8010222a:	8b 50 04             	mov    0x4(%eax),%edx
8010222d:	8b 45 0c             	mov    0xc(%ebp),%eax
80102230:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
80102233:	8b 45 08             	mov    0x8(%ebp),%eax
80102236:	0f b7 50 10          	movzwl 0x10(%eax),%edx
8010223a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010223d:	66 89 10             	mov    %dx,(%eax)
  st->nlink = ip->nlink;
80102240:	8b 45 08             	mov    0x8(%ebp),%eax
80102243:	0f b7 50 16          	movzwl 0x16(%eax),%edx
80102247:	8b 45 0c             	mov    0xc(%ebp),%eax
8010224a:	66 89 50 0c          	mov    %dx,0xc(%eax)
  st->size = ip->size;
8010224e:	8b 45 08             	mov    0x8(%ebp),%eax
80102251:	8b 50 18             	mov    0x18(%eax),%edx
80102254:	8b 45 0c             	mov    0xc(%ebp),%eax
80102257:	89 50 10             	mov    %edx,0x10(%eax)
}
8010225a:	90                   	nop
8010225b:	5d                   	pop    %ebp
8010225c:	c3                   	ret    

8010225d <readi>:

//PAGEBREAK!
// Read data from inode.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
8010225d:	55                   	push   %ebp
8010225e:	89 e5                	mov    %esp,%ebp
80102260:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80102263:	8b 45 08             	mov    0x8(%ebp),%eax
80102266:	0f b7 40 10          	movzwl 0x10(%eax),%eax
8010226a:	66 83 f8 03          	cmp    $0x3,%ax
8010226e:	75 5c                	jne    801022cc <readi+0x6f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80102270:	8b 45 08             	mov    0x8(%ebp),%eax
80102273:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102277:	66 85 c0             	test   %ax,%ax
8010227a:	78 20                	js     8010229c <readi+0x3f>
8010227c:	8b 45 08             	mov    0x8(%ebp),%eax
8010227f:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102283:	66 83 f8 09          	cmp    $0x9,%ax
80102287:	7f 13                	jg     8010229c <readi+0x3f>
80102289:	8b 45 08             	mov    0x8(%ebp),%eax
8010228c:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102290:	98                   	cwtl   
80102291:	8b 04 c5 e0 11 11 80 	mov    -0x7feeee20(,%eax,8),%eax
80102298:	85 c0                	test   %eax,%eax
8010229a:	75 0a                	jne    801022a6 <readi+0x49>
      return -1;
8010229c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801022a1:	e9 0c 01 00 00       	jmp    801023b2 <readi+0x155>
    return devsw[ip->major].read(ip, dst, n);
801022a6:	8b 45 08             	mov    0x8(%ebp),%eax
801022a9:	0f b7 40 12          	movzwl 0x12(%eax),%eax
801022ad:	98                   	cwtl   
801022ae:	8b 04 c5 e0 11 11 80 	mov    -0x7feeee20(,%eax,8),%eax
801022b5:	8b 55 14             	mov    0x14(%ebp),%edx
801022b8:	83 ec 04             	sub    $0x4,%esp
801022bb:	52                   	push   %edx
801022bc:	ff 75 0c             	pushl  0xc(%ebp)
801022bf:	ff 75 08             	pushl  0x8(%ebp)
801022c2:	ff d0                	call   *%eax
801022c4:	83 c4 10             	add    $0x10,%esp
801022c7:	e9 e6 00 00 00       	jmp    801023b2 <readi+0x155>
  }

  if(off > ip->size || off + n < off)
801022cc:	8b 45 08             	mov    0x8(%ebp),%eax
801022cf:	8b 40 18             	mov    0x18(%eax),%eax
801022d2:	3b 45 10             	cmp    0x10(%ebp),%eax
801022d5:	72 0d                	jb     801022e4 <readi+0x87>
801022d7:	8b 55 10             	mov    0x10(%ebp),%edx
801022da:	8b 45 14             	mov    0x14(%ebp),%eax
801022dd:	01 d0                	add    %edx,%eax
801022df:	3b 45 10             	cmp    0x10(%ebp),%eax
801022e2:	73 0a                	jae    801022ee <readi+0x91>
    return -1;
801022e4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801022e9:	e9 c4 00 00 00       	jmp    801023b2 <readi+0x155>
  if(off + n > ip->size)
801022ee:	8b 55 10             	mov    0x10(%ebp),%edx
801022f1:	8b 45 14             	mov    0x14(%ebp),%eax
801022f4:	01 c2                	add    %eax,%edx
801022f6:	8b 45 08             	mov    0x8(%ebp),%eax
801022f9:	8b 40 18             	mov    0x18(%eax),%eax
801022fc:	39 c2                	cmp    %eax,%edx
801022fe:	76 0c                	jbe    8010230c <readi+0xaf>
    n = ip->size - off;
80102300:	8b 45 08             	mov    0x8(%ebp),%eax
80102303:	8b 40 18             	mov    0x18(%eax),%eax
80102306:	2b 45 10             	sub    0x10(%ebp),%eax
80102309:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
8010230c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102313:	e9 8b 00 00 00       	jmp    801023a3 <readi+0x146>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80102318:	8b 45 10             	mov    0x10(%ebp),%eax
8010231b:	c1 e8 09             	shr    $0x9,%eax
8010231e:	83 ec 08             	sub    $0x8,%esp
80102321:	50                   	push   %eax
80102322:	ff 75 08             	pushl  0x8(%ebp)
80102325:	e8 62 fc ff ff       	call   80101f8c <bmap>
8010232a:	83 c4 10             	add    $0x10,%esp
8010232d:	89 c2                	mov    %eax,%edx
8010232f:	8b 45 08             	mov    0x8(%ebp),%eax
80102332:	8b 00                	mov    (%eax),%eax
80102334:	83 ec 08             	sub    $0x8,%esp
80102337:	52                   	push   %edx
80102338:	50                   	push   %eax
80102339:	e8 78 de ff ff       	call   801001b6 <bread>
8010233e:	83 c4 10             	add    $0x10,%esp
80102341:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80102344:	8b 45 10             	mov    0x10(%ebp),%eax
80102347:	25 ff 01 00 00       	and    $0x1ff,%eax
8010234c:	ba 00 02 00 00       	mov    $0x200,%edx
80102351:	29 c2                	sub    %eax,%edx
80102353:	8b 45 14             	mov    0x14(%ebp),%eax
80102356:	2b 45 f4             	sub    -0xc(%ebp),%eax
80102359:	39 c2                	cmp    %eax,%edx
8010235b:	0f 46 c2             	cmovbe %edx,%eax
8010235e:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
80102361:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102364:	8d 50 18             	lea    0x18(%eax),%edx
80102367:	8b 45 10             	mov    0x10(%ebp),%eax
8010236a:	25 ff 01 00 00       	and    $0x1ff,%eax
8010236f:	01 d0                	add    %edx,%eax
80102371:	83 ec 04             	sub    $0x4,%esp
80102374:	ff 75 ec             	pushl  -0x14(%ebp)
80102377:	50                   	push   %eax
80102378:	ff 75 0c             	pushl  0xc(%ebp)
8010237b:	e8 5f 33 00 00       	call   801056df <memmove>
80102380:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80102383:	83 ec 0c             	sub    $0xc,%esp
80102386:	ff 75 f0             	pushl  -0x10(%ebp)
80102389:	e8 a0 de ff ff       	call   8010022e <brelse>
8010238e:	83 c4 10             	add    $0x10,%esp
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80102391:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102394:	01 45 f4             	add    %eax,-0xc(%ebp)
80102397:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010239a:	01 45 10             	add    %eax,0x10(%ebp)
8010239d:	8b 45 ec             	mov    -0x14(%ebp),%eax
801023a0:	01 45 0c             	add    %eax,0xc(%ebp)
801023a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023a6:	3b 45 14             	cmp    0x14(%ebp),%eax
801023a9:	0f 82 69 ff ff ff    	jb     80102318 <readi+0xbb>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    memmove(dst, bp->data + off%BSIZE, m);
    brelse(bp);
  }
  return n;
801023af:	8b 45 14             	mov    0x14(%ebp),%eax
}
801023b2:	c9                   	leave  
801023b3:	c3                   	ret    

801023b4 <writei>:

// PAGEBREAK!
// Write data to inode.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
801023b4:	55                   	push   %ebp
801023b5:	89 e5                	mov    %esp,%ebp
801023b7:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
801023ba:	8b 45 08             	mov    0x8(%ebp),%eax
801023bd:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801023c1:	66 83 f8 03          	cmp    $0x3,%ax
801023c5:	75 5c                	jne    80102423 <writei+0x6f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
801023c7:	8b 45 08             	mov    0x8(%ebp),%eax
801023ca:	0f b7 40 12          	movzwl 0x12(%eax),%eax
801023ce:	66 85 c0             	test   %ax,%ax
801023d1:	78 20                	js     801023f3 <writei+0x3f>
801023d3:	8b 45 08             	mov    0x8(%ebp),%eax
801023d6:	0f b7 40 12          	movzwl 0x12(%eax),%eax
801023da:	66 83 f8 09          	cmp    $0x9,%ax
801023de:	7f 13                	jg     801023f3 <writei+0x3f>
801023e0:	8b 45 08             	mov    0x8(%ebp),%eax
801023e3:	0f b7 40 12          	movzwl 0x12(%eax),%eax
801023e7:	98                   	cwtl   
801023e8:	8b 04 c5 e4 11 11 80 	mov    -0x7feeee1c(,%eax,8),%eax
801023ef:	85 c0                	test   %eax,%eax
801023f1:	75 0a                	jne    801023fd <writei+0x49>
      return -1;
801023f3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801023f8:	e9 3d 01 00 00       	jmp    8010253a <writei+0x186>
    return devsw[ip->major].write(ip, src, n);
801023fd:	8b 45 08             	mov    0x8(%ebp),%eax
80102400:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102404:	98                   	cwtl   
80102405:	8b 04 c5 e4 11 11 80 	mov    -0x7feeee1c(,%eax,8),%eax
8010240c:	8b 55 14             	mov    0x14(%ebp),%edx
8010240f:	83 ec 04             	sub    $0x4,%esp
80102412:	52                   	push   %edx
80102413:	ff 75 0c             	pushl  0xc(%ebp)
80102416:	ff 75 08             	pushl  0x8(%ebp)
80102419:	ff d0                	call   *%eax
8010241b:	83 c4 10             	add    $0x10,%esp
8010241e:	e9 17 01 00 00       	jmp    8010253a <writei+0x186>
  }

  if(off > ip->size || off + n < off)
80102423:	8b 45 08             	mov    0x8(%ebp),%eax
80102426:	8b 40 18             	mov    0x18(%eax),%eax
80102429:	3b 45 10             	cmp    0x10(%ebp),%eax
8010242c:	72 0d                	jb     8010243b <writei+0x87>
8010242e:	8b 55 10             	mov    0x10(%ebp),%edx
80102431:	8b 45 14             	mov    0x14(%ebp),%eax
80102434:	01 d0                	add    %edx,%eax
80102436:	3b 45 10             	cmp    0x10(%ebp),%eax
80102439:	73 0a                	jae    80102445 <writei+0x91>
    return -1;
8010243b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102440:	e9 f5 00 00 00       	jmp    8010253a <writei+0x186>
  if(off + n > MAXFILE*BSIZE)
80102445:	8b 55 10             	mov    0x10(%ebp),%edx
80102448:	8b 45 14             	mov    0x14(%ebp),%eax
8010244b:	01 d0                	add    %edx,%eax
8010244d:	3d 00 18 01 00       	cmp    $0x11800,%eax
80102452:	76 0a                	jbe    8010245e <writei+0xaa>
    return -1;
80102454:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102459:	e9 dc 00 00 00       	jmp    8010253a <writei+0x186>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
8010245e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102465:	e9 99 00 00 00       	jmp    80102503 <writei+0x14f>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
8010246a:	8b 45 10             	mov    0x10(%ebp),%eax
8010246d:	c1 e8 09             	shr    $0x9,%eax
80102470:	83 ec 08             	sub    $0x8,%esp
80102473:	50                   	push   %eax
80102474:	ff 75 08             	pushl  0x8(%ebp)
80102477:	e8 10 fb ff ff       	call   80101f8c <bmap>
8010247c:	83 c4 10             	add    $0x10,%esp
8010247f:	89 c2                	mov    %eax,%edx
80102481:	8b 45 08             	mov    0x8(%ebp),%eax
80102484:	8b 00                	mov    (%eax),%eax
80102486:	83 ec 08             	sub    $0x8,%esp
80102489:	52                   	push   %edx
8010248a:	50                   	push   %eax
8010248b:	e8 26 dd ff ff       	call   801001b6 <bread>
80102490:	83 c4 10             	add    $0x10,%esp
80102493:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80102496:	8b 45 10             	mov    0x10(%ebp),%eax
80102499:	25 ff 01 00 00       	and    $0x1ff,%eax
8010249e:	ba 00 02 00 00       	mov    $0x200,%edx
801024a3:	29 c2                	sub    %eax,%edx
801024a5:	8b 45 14             	mov    0x14(%ebp),%eax
801024a8:	2b 45 f4             	sub    -0xc(%ebp),%eax
801024ab:	39 c2                	cmp    %eax,%edx
801024ad:	0f 46 c2             	cmovbe %edx,%eax
801024b0:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
801024b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801024b6:	8d 50 18             	lea    0x18(%eax),%edx
801024b9:	8b 45 10             	mov    0x10(%ebp),%eax
801024bc:	25 ff 01 00 00       	and    $0x1ff,%eax
801024c1:	01 d0                	add    %edx,%eax
801024c3:	83 ec 04             	sub    $0x4,%esp
801024c6:	ff 75 ec             	pushl  -0x14(%ebp)
801024c9:	ff 75 0c             	pushl  0xc(%ebp)
801024cc:	50                   	push   %eax
801024cd:	e8 0d 32 00 00       	call   801056df <memmove>
801024d2:	83 c4 10             	add    $0x10,%esp
    log_write(bp);
801024d5:	83 ec 0c             	sub    $0xc,%esp
801024d8:	ff 75 f0             	pushl  -0x10(%ebp)
801024db:	e8 61 16 00 00       	call   80103b41 <log_write>
801024e0:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
801024e3:	83 ec 0c             	sub    $0xc,%esp
801024e6:	ff 75 f0             	pushl  -0x10(%ebp)
801024e9:	e8 40 dd ff ff       	call   8010022e <brelse>
801024ee:	83 c4 10             	add    $0x10,%esp
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > MAXFILE*BSIZE)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
801024f1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801024f4:	01 45 f4             	add    %eax,-0xc(%ebp)
801024f7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801024fa:	01 45 10             	add    %eax,0x10(%ebp)
801024fd:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102500:	01 45 0c             	add    %eax,0xc(%ebp)
80102503:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102506:	3b 45 14             	cmp    0x14(%ebp),%eax
80102509:	0f 82 5b ff ff ff    	jb     8010246a <writei+0xb6>
    memmove(bp->data + off%BSIZE, src, m);
    log_write(bp);
    brelse(bp);
  }

  if(n > 0 && off > ip->size){
8010250f:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80102513:	74 22                	je     80102537 <writei+0x183>
80102515:	8b 45 08             	mov    0x8(%ebp),%eax
80102518:	8b 40 18             	mov    0x18(%eax),%eax
8010251b:	3b 45 10             	cmp    0x10(%ebp),%eax
8010251e:	73 17                	jae    80102537 <writei+0x183>
    ip->size = off;
80102520:	8b 45 08             	mov    0x8(%ebp),%eax
80102523:	8b 55 10             	mov    0x10(%ebp),%edx
80102526:	89 50 18             	mov    %edx,0x18(%eax)
    iupdate(ip);
80102529:	83 ec 0c             	sub    $0xc,%esp
8010252c:	ff 75 08             	pushl  0x8(%ebp)
8010252f:	e8 ea f4 ff ff       	call   80101a1e <iupdate>
80102534:	83 c4 10             	add    $0x10,%esp
  }
  return n;
80102537:	8b 45 14             	mov    0x14(%ebp),%eax
}
8010253a:	c9                   	leave  
8010253b:	c3                   	ret    

8010253c <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
8010253c:	55                   	push   %ebp
8010253d:	89 e5                	mov    %esp,%ebp
8010253f:	83 ec 08             	sub    $0x8,%esp
  return strncmp(s, t, DIRSIZ);
80102542:	83 ec 04             	sub    $0x4,%esp
80102545:	6a 0e                	push   $0xe
80102547:	ff 75 0c             	pushl  0xc(%ebp)
8010254a:	ff 75 08             	pushl  0x8(%ebp)
8010254d:	e8 23 32 00 00       	call   80105775 <strncmp>
80102552:	83 c4 10             	add    $0x10,%esp
}
80102555:	c9                   	leave  
80102556:	c3                   	ret    

80102557 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
80102557:	55                   	push   %ebp
80102558:	89 e5                	mov    %esp,%ebp
8010255a:	83 ec 28             	sub    $0x28,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
8010255d:	8b 45 08             	mov    0x8(%ebp),%eax
80102560:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80102564:	66 83 f8 01          	cmp    $0x1,%ax
80102568:	74 0d                	je     80102577 <dirlookup+0x20>
    panic("dirlookup not DIR");
8010256a:	83 ec 0c             	sub    $0xc,%esp
8010256d:	68 8b 8a 10 80       	push   $0x80108a8b
80102572:	e8 ef df ff ff       	call   80100566 <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
80102577:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010257e:	e9 85 00 00 00       	jmp    80102608 <dirlookup+0xb1>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102583:	6a 10                	push   $0x10
80102585:	ff 75 f4             	pushl  -0xc(%ebp)
80102588:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010258b:	50                   	push   %eax
8010258c:	ff 75 08             	pushl  0x8(%ebp)
8010258f:	e8 c9 fc ff ff       	call   8010225d <readi>
80102594:	83 c4 10             	add    $0x10,%esp
80102597:	83 f8 10             	cmp    $0x10,%eax
8010259a:	74 0d                	je     801025a9 <dirlookup+0x52>
      panic("dirlink read");
8010259c:	83 ec 0c             	sub    $0xc,%esp
8010259f:	68 9d 8a 10 80       	push   $0x80108a9d
801025a4:	e8 bd df ff ff       	call   80100566 <panic>
    if(de.inum == 0)
801025a9:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801025ad:	66 85 c0             	test   %ax,%ax
801025b0:	74 51                	je     80102603 <dirlookup+0xac>
      continue;
    if(namecmp(name, de.name) == 0){
801025b2:	83 ec 08             	sub    $0x8,%esp
801025b5:	8d 45 e0             	lea    -0x20(%ebp),%eax
801025b8:	83 c0 02             	add    $0x2,%eax
801025bb:	50                   	push   %eax
801025bc:	ff 75 0c             	pushl  0xc(%ebp)
801025bf:	e8 78 ff ff ff       	call   8010253c <namecmp>
801025c4:	83 c4 10             	add    $0x10,%esp
801025c7:	85 c0                	test   %eax,%eax
801025c9:	75 39                	jne    80102604 <dirlookup+0xad>
      // entry matches path element
      if(poff)
801025cb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801025cf:	74 08                	je     801025d9 <dirlookup+0x82>
        *poff = off;
801025d1:	8b 45 10             	mov    0x10(%ebp),%eax
801025d4:	8b 55 f4             	mov    -0xc(%ebp),%edx
801025d7:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
801025d9:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801025dd:	0f b7 c0             	movzwl %ax,%eax
801025e0:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum,dp->part->number);
801025e3:	8b 45 08             	mov    0x8(%ebp),%eax
801025e6:	8b 40 50             	mov    0x50(%eax),%eax
801025e9:	8b 50 14             	mov    0x14(%eax),%edx
801025ec:	8b 45 08             	mov    0x8(%ebp),%eax
801025ef:	8b 00                	mov    (%eax),%eax
801025f1:	83 ec 04             	sub    $0x4,%esp
801025f4:	52                   	push   %edx
801025f5:	ff 75 f0             	pushl  -0x10(%ebp)
801025f8:	50                   	push   %eax
801025f9:	e8 24 f5 ff ff       	call   80101b22 <iget>
801025fe:	83 c4 10             	add    $0x10,%esp
80102601:	eb 19                	jmp    8010261c <dirlookup+0xc5>

  for(off = 0; off < dp->size; off += sizeof(de)){
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("dirlink read");
    if(de.inum == 0)
      continue;
80102603:	90                   	nop
  struct dirent de;

  if(dp->type != T_DIR)
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
80102604:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80102608:	8b 45 08             	mov    0x8(%ebp),%eax
8010260b:	8b 40 18             	mov    0x18(%eax),%eax
8010260e:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80102611:	0f 87 6c ff ff ff    	ja     80102583 <dirlookup+0x2c>
      inum = de.inum;
      return iget(dp->dev, inum,dp->part->number);
    }
  }

  return 0;
80102617:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010261c:	c9                   	leave  
8010261d:	c3                   	ret    

8010261e <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
8010261e:	55                   	push   %ebp
8010261f:	89 e5                	mov    %esp,%ebp
80102621:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
80102624:	83 ec 04             	sub    $0x4,%esp
80102627:	6a 00                	push   $0x0
80102629:	ff 75 0c             	pushl  0xc(%ebp)
8010262c:	ff 75 08             	pushl  0x8(%ebp)
8010262f:	e8 23 ff ff ff       	call   80102557 <dirlookup>
80102634:	83 c4 10             	add    $0x10,%esp
80102637:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010263a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010263e:	74 18                	je     80102658 <dirlink+0x3a>
    iput(ip);
80102640:	83 ec 0c             	sub    $0xc,%esp
80102643:	ff 75 f0             	pushl  -0x10(%ebp)
80102646:	e8 2c f8 ff ff       	call   80101e77 <iput>
8010264b:	83 c4 10             	add    $0x10,%esp
    return -1;
8010264e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102653:	e9 9c 00 00 00       	jmp    801026f4 <dirlink+0xd6>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
80102658:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010265f:	eb 39                	jmp    8010269a <dirlink+0x7c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102661:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102664:	6a 10                	push   $0x10
80102666:	50                   	push   %eax
80102667:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010266a:	50                   	push   %eax
8010266b:	ff 75 08             	pushl  0x8(%ebp)
8010266e:	e8 ea fb ff ff       	call   8010225d <readi>
80102673:	83 c4 10             	add    $0x10,%esp
80102676:	83 f8 10             	cmp    $0x10,%eax
80102679:	74 0d                	je     80102688 <dirlink+0x6a>
      panic("dirlink read");
8010267b:	83 ec 0c             	sub    $0xc,%esp
8010267e:	68 9d 8a 10 80       	push   $0x80108a9d
80102683:	e8 de de ff ff       	call   80100566 <panic>
    if(de.inum == 0)
80102688:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
8010268c:	66 85 c0             	test   %ax,%ax
8010268f:	74 18                	je     801026a9 <dirlink+0x8b>
    iput(ip);
    return -1;
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
80102691:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102694:	83 c0 10             	add    $0x10,%eax
80102697:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010269a:	8b 45 08             	mov    0x8(%ebp),%eax
8010269d:	8b 50 18             	mov    0x18(%eax),%edx
801026a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801026a3:	39 c2                	cmp    %eax,%edx
801026a5:	77 ba                	ja     80102661 <dirlink+0x43>
801026a7:	eb 01                	jmp    801026aa <dirlink+0x8c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("dirlink read");
    if(de.inum == 0)
      break;
801026a9:	90                   	nop
  }

  strncpy(de.name, name, DIRSIZ);
801026aa:	83 ec 04             	sub    $0x4,%esp
801026ad:	6a 0e                	push   $0xe
801026af:	ff 75 0c             	pushl  0xc(%ebp)
801026b2:	8d 45 e0             	lea    -0x20(%ebp),%eax
801026b5:	83 c0 02             	add    $0x2,%eax
801026b8:	50                   	push   %eax
801026b9:	e8 0d 31 00 00       	call   801057cb <strncpy>
801026be:	83 c4 10             	add    $0x10,%esp
  de.inum = inum;
801026c1:	8b 45 10             	mov    0x10(%ebp),%eax
801026c4:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801026c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801026cb:	6a 10                	push   $0x10
801026cd:	50                   	push   %eax
801026ce:	8d 45 e0             	lea    -0x20(%ebp),%eax
801026d1:	50                   	push   %eax
801026d2:	ff 75 08             	pushl  0x8(%ebp)
801026d5:	e8 da fc ff ff       	call   801023b4 <writei>
801026da:	83 c4 10             	add    $0x10,%esp
801026dd:	83 f8 10             	cmp    $0x10,%eax
801026e0:	74 0d                	je     801026ef <dirlink+0xd1>
    panic("dirlink");
801026e2:	83 ec 0c             	sub    $0xc,%esp
801026e5:	68 aa 8a 10 80       	push   $0x80108aaa
801026ea:	e8 77 de ff ff       	call   80100566 <panic>
  
  return 0;
801026ef:	b8 00 00 00 00       	mov    $0x0,%eax
}
801026f4:	c9                   	leave  
801026f5:	c3                   	ret    

801026f6 <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
801026f6:	55                   	push   %ebp
801026f7:	89 e5                	mov    %esp,%ebp
801026f9:	83 ec 18             	sub    $0x18,%esp
  char *s;
  int len;

  while(*path == '/')
801026fc:	eb 04                	jmp    80102702 <skipelem+0xc>
    path++;
801026fe:	83 45 08 01          	addl   $0x1,0x8(%ebp)
skipelem(char *path, char *name)
{
  char *s;
  int len;

  while(*path == '/')
80102702:	8b 45 08             	mov    0x8(%ebp),%eax
80102705:	0f b6 00             	movzbl (%eax),%eax
80102708:	3c 2f                	cmp    $0x2f,%al
8010270a:	74 f2                	je     801026fe <skipelem+0x8>
    path++;
  if(*path == 0)
8010270c:	8b 45 08             	mov    0x8(%ebp),%eax
8010270f:	0f b6 00             	movzbl (%eax),%eax
80102712:	84 c0                	test   %al,%al
80102714:	75 07                	jne    8010271d <skipelem+0x27>
    return 0;
80102716:	b8 00 00 00 00       	mov    $0x0,%eax
8010271b:	eb 7b                	jmp    80102798 <skipelem+0xa2>
  s = path;
8010271d:	8b 45 08             	mov    0x8(%ebp),%eax
80102720:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
80102723:	eb 04                	jmp    80102729 <skipelem+0x33>
    path++;
80102725:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
    path++;
  if(*path == 0)
    return 0;
  s = path;
  while(*path != '/' && *path != 0)
80102729:	8b 45 08             	mov    0x8(%ebp),%eax
8010272c:	0f b6 00             	movzbl (%eax),%eax
8010272f:	3c 2f                	cmp    $0x2f,%al
80102731:	74 0a                	je     8010273d <skipelem+0x47>
80102733:	8b 45 08             	mov    0x8(%ebp),%eax
80102736:	0f b6 00             	movzbl (%eax),%eax
80102739:	84 c0                	test   %al,%al
8010273b:	75 e8                	jne    80102725 <skipelem+0x2f>
    path++;
  len = path - s;
8010273d:	8b 55 08             	mov    0x8(%ebp),%edx
80102740:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102743:	29 c2                	sub    %eax,%edx
80102745:	89 d0                	mov    %edx,%eax
80102747:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
8010274a:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
8010274e:	7e 15                	jle    80102765 <skipelem+0x6f>
    memmove(name, s, DIRSIZ);
80102750:	83 ec 04             	sub    $0x4,%esp
80102753:	6a 0e                	push   $0xe
80102755:	ff 75 f4             	pushl  -0xc(%ebp)
80102758:	ff 75 0c             	pushl  0xc(%ebp)
8010275b:	e8 7f 2f 00 00       	call   801056df <memmove>
80102760:	83 c4 10             	add    $0x10,%esp
80102763:	eb 26                	jmp    8010278b <skipelem+0x95>
  else {
    memmove(name, s, len);
80102765:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102768:	83 ec 04             	sub    $0x4,%esp
8010276b:	50                   	push   %eax
8010276c:	ff 75 f4             	pushl  -0xc(%ebp)
8010276f:	ff 75 0c             	pushl  0xc(%ebp)
80102772:	e8 68 2f 00 00       	call   801056df <memmove>
80102777:	83 c4 10             	add    $0x10,%esp
    name[len] = 0;
8010277a:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010277d:	8b 45 0c             	mov    0xc(%ebp),%eax
80102780:	01 d0                	add    %edx,%eax
80102782:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
80102785:	eb 04                	jmp    8010278b <skipelem+0x95>
    path++;
80102787:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
8010278b:	8b 45 08             	mov    0x8(%ebp),%eax
8010278e:	0f b6 00             	movzbl (%eax),%eax
80102791:	3c 2f                	cmp    $0x2f,%al
80102793:	74 f2                	je     80102787 <skipelem+0x91>
    path++;
  return path;
80102795:	8b 45 08             	mov    0x8(%ebp),%eax
}
80102798:	c9                   	leave  
80102799:	c3                   	ret    

8010279a <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
8010279a:	55                   	push   %ebp
8010279b:	89 e5                	mov    %esp,%ebp
8010279d:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *next;

  if(*path == '/')
801027a0:	8b 45 08             	mov    0x8(%ebp),%eax
801027a3:	0f b6 00             	movzbl (%eax),%eax
801027a6:	3c 2f                	cmp    $0x2f,%al
801027a8:	75 1d                	jne    801027c7 <namex+0x2d>
    ip = iget(ROOTDEV, ROOTINO,bootfrom);
801027aa:	a1 18 90 10 80       	mov    0x80109018,%eax
801027af:	83 ec 04             	sub    $0x4,%esp
801027b2:	50                   	push   %eax
801027b3:	6a 01                	push   $0x1
801027b5:	6a 00                	push   $0x0
801027b7:	e8 66 f3 ff ff       	call   80101b22 <iget>
801027bc:	83 c4 10             	add    $0x10,%esp
801027bf:	89 45 f4             	mov    %eax,-0xc(%ebp)
801027c2:	e9 bb 00 00 00       	jmp    80102882 <namex+0xe8>
  else
    ip = idup(proc->cwd);
801027c7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801027cd:	8b 40 68             	mov    0x68(%eax),%eax
801027d0:	83 ec 0c             	sub    $0xc,%esp
801027d3:	50                   	push   %eax
801027d4:	e8 51 f4 ff ff       	call   80101c2a <idup>
801027d9:	83 c4 10             	add    $0x10,%esp
801027dc:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
801027df:	e9 9e 00 00 00       	jmp    80102882 <namex+0xe8>
    ilock(ip);
801027e4:	83 ec 0c             	sub    $0xc,%esp
801027e7:	ff 75 f4             	pushl  -0xc(%ebp)
801027ea:	e8 75 f4 ff ff       	call   80101c64 <ilock>
801027ef:	83 c4 10             	add    $0x10,%esp
    if(ip->type != T_DIR){
801027f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801027f5:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801027f9:	66 83 f8 01          	cmp    $0x1,%ax
801027fd:	74 18                	je     80102817 <namex+0x7d>
      iunlockput(ip);
801027ff:	83 ec 0c             	sub    $0xc,%esp
80102802:	ff 75 f4             	pushl  -0xc(%ebp)
80102805:	e8 5d f7 ff ff       	call   80101f67 <iunlockput>
8010280a:	83 c4 10             	add    $0x10,%esp
      return 0;
8010280d:	b8 00 00 00 00       	mov    $0x0,%eax
80102812:	e9 a7 00 00 00       	jmp    801028be <namex+0x124>
    }
    if(nameiparent && *path == '\0'){
80102817:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010281b:	74 20                	je     8010283d <namex+0xa3>
8010281d:	8b 45 08             	mov    0x8(%ebp),%eax
80102820:	0f b6 00             	movzbl (%eax),%eax
80102823:	84 c0                	test   %al,%al
80102825:	75 16                	jne    8010283d <namex+0xa3>
      // Stop one level early.
      iunlock(ip);
80102827:	83 ec 0c             	sub    $0xc,%esp
8010282a:	ff 75 f4             	pushl  -0xc(%ebp)
8010282d:	e8 d3 f5 ff ff       	call   80101e05 <iunlock>
80102832:	83 c4 10             	add    $0x10,%esp
      return ip;
80102835:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102838:	e9 81 00 00 00       	jmp    801028be <namex+0x124>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
8010283d:	83 ec 04             	sub    $0x4,%esp
80102840:	6a 00                	push   $0x0
80102842:	ff 75 10             	pushl  0x10(%ebp)
80102845:	ff 75 f4             	pushl  -0xc(%ebp)
80102848:	e8 0a fd ff ff       	call   80102557 <dirlookup>
8010284d:	83 c4 10             	add    $0x10,%esp
80102850:	89 45 f0             	mov    %eax,-0x10(%ebp)
80102853:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102857:	75 15                	jne    8010286e <namex+0xd4>
      iunlockput(ip);
80102859:	83 ec 0c             	sub    $0xc,%esp
8010285c:	ff 75 f4             	pushl  -0xc(%ebp)
8010285f:	e8 03 f7 ff ff       	call   80101f67 <iunlockput>
80102864:	83 c4 10             	add    $0x10,%esp
      return 0;
80102867:	b8 00 00 00 00       	mov    $0x0,%eax
8010286c:	eb 50                	jmp    801028be <namex+0x124>
    }
    iunlockput(ip);
8010286e:	83 ec 0c             	sub    $0xc,%esp
80102871:	ff 75 f4             	pushl  -0xc(%ebp)
80102874:	e8 ee f6 ff ff       	call   80101f67 <iunlockput>
80102879:	83 c4 10             	add    $0x10,%esp
    ip = next;
8010287c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010287f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO,bootfrom);
  else
    ip = idup(proc->cwd);

  while((path = skipelem(path, name)) != 0){
80102882:	83 ec 08             	sub    $0x8,%esp
80102885:	ff 75 10             	pushl  0x10(%ebp)
80102888:	ff 75 08             	pushl  0x8(%ebp)
8010288b:	e8 66 fe ff ff       	call   801026f6 <skipelem>
80102890:	83 c4 10             	add    $0x10,%esp
80102893:	89 45 08             	mov    %eax,0x8(%ebp)
80102896:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010289a:	0f 85 44 ff ff ff    	jne    801027e4 <namex+0x4a>
      return 0;
    }
    iunlockput(ip);
    ip = next;
  }
  if(nameiparent){
801028a0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801028a4:	74 15                	je     801028bb <namex+0x121>
    iput(ip);
801028a6:	83 ec 0c             	sub    $0xc,%esp
801028a9:	ff 75 f4             	pushl  -0xc(%ebp)
801028ac:	e8 c6 f5 ff ff       	call   80101e77 <iput>
801028b1:	83 c4 10             	add    $0x10,%esp
    return 0;
801028b4:	b8 00 00 00 00       	mov    $0x0,%eax
801028b9:	eb 03                	jmp    801028be <namex+0x124>
  }
  return ip;
801028bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801028be:	c9                   	leave  
801028bf:	c3                   	ret    

801028c0 <namei>:

struct inode*
namei(char *path)
{
801028c0:	55                   	push   %ebp
801028c1:	89 e5                	mov    %esp,%ebp
801028c3:	83 ec 18             	sub    $0x18,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
801028c6:	83 ec 04             	sub    $0x4,%esp
801028c9:	8d 45 ea             	lea    -0x16(%ebp),%eax
801028cc:	50                   	push   %eax
801028cd:	6a 00                	push   $0x0
801028cf:	ff 75 08             	pushl  0x8(%ebp)
801028d2:	e8 c3 fe ff ff       	call   8010279a <namex>
801028d7:	83 c4 10             	add    $0x10,%esp
}
801028da:	c9                   	leave  
801028db:	c3                   	ret    

801028dc <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
801028dc:	55                   	push   %ebp
801028dd:	89 e5                	mov    %esp,%ebp
801028df:	83 ec 08             	sub    $0x8,%esp
  return namex(path, 1, name);
801028e2:	83 ec 04             	sub    $0x4,%esp
801028e5:	ff 75 0c             	pushl  0xc(%ebp)
801028e8:	6a 01                	push   $0x1
801028ea:	ff 75 08             	pushl  0x8(%ebp)
801028ed:	e8 a8 fe ff ff       	call   8010279a <namex>
801028f2:	83 c4 10             	add    $0x10,%esp
}
801028f5:	c9                   	leave  
801028f6:	c3                   	ret    

801028f7 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801028f7:	55                   	push   %ebp
801028f8:	89 e5                	mov    %esp,%ebp
801028fa:	83 ec 14             	sub    $0x14,%esp
801028fd:	8b 45 08             	mov    0x8(%ebp),%eax
80102900:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102904:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102908:	89 c2                	mov    %eax,%edx
8010290a:	ec                   	in     (%dx),%al
8010290b:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
8010290e:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102912:	c9                   	leave  
80102913:	c3                   	ret    

80102914 <insl>:

static inline void
insl(int port, void *addr, int cnt)
{
80102914:	55                   	push   %ebp
80102915:	89 e5                	mov    %esp,%ebp
80102917:	57                   	push   %edi
80102918:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
80102919:	8b 55 08             	mov    0x8(%ebp),%edx
8010291c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
8010291f:	8b 45 10             	mov    0x10(%ebp),%eax
80102922:	89 cb                	mov    %ecx,%ebx
80102924:	89 df                	mov    %ebx,%edi
80102926:	89 c1                	mov    %eax,%ecx
80102928:	fc                   	cld    
80102929:	f3 6d                	rep insl (%dx),%es:(%edi)
8010292b:	89 c8                	mov    %ecx,%eax
8010292d:	89 fb                	mov    %edi,%ebx
8010292f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
80102932:	89 45 10             	mov    %eax,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "memory", "cc");
}
80102935:	90                   	nop
80102936:	5b                   	pop    %ebx
80102937:	5f                   	pop    %edi
80102938:	5d                   	pop    %ebp
80102939:	c3                   	ret    

8010293a <outb>:

static inline void
outb(ushort port, uchar data)
{
8010293a:	55                   	push   %ebp
8010293b:	89 e5                	mov    %esp,%ebp
8010293d:	83 ec 08             	sub    $0x8,%esp
80102940:	8b 55 08             	mov    0x8(%ebp),%edx
80102943:	8b 45 0c             	mov    0xc(%ebp),%eax
80102946:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
8010294a:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010294d:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102951:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102955:	ee                   	out    %al,(%dx)
}
80102956:	90                   	nop
80102957:	c9                   	leave  
80102958:	c3                   	ret    

80102959 <outsl>:
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
}

static inline void
outsl(int port, const void *addr, int cnt)
{
80102959:	55                   	push   %ebp
8010295a:	89 e5                	mov    %esp,%ebp
8010295c:	56                   	push   %esi
8010295d:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
8010295e:	8b 55 08             	mov    0x8(%ebp),%edx
80102961:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102964:	8b 45 10             	mov    0x10(%ebp),%eax
80102967:	89 cb                	mov    %ecx,%ebx
80102969:	89 de                	mov    %ebx,%esi
8010296b:	89 c1                	mov    %eax,%ecx
8010296d:	fc                   	cld    
8010296e:	f3 6f                	rep outsl %ds:(%esi),(%dx)
80102970:	89 c8                	mov    %ecx,%eax
80102972:	89 f3                	mov    %esi,%ebx
80102974:	89 5d 0c             	mov    %ebx,0xc(%ebp)
80102977:	89 45 10             	mov    %eax,0x10(%ebp)
               "=S" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "cc");
}
8010297a:	90                   	nop
8010297b:	5b                   	pop    %ebx
8010297c:	5e                   	pop    %esi
8010297d:	5d                   	pop    %ebp
8010297e:	c3                   	ret    

8010297f <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
8010297f:	55                   	push   %ebp
80102980:	89 e5                	mov    %esp,%ebp
80102982:	83 ec 10             	sub    $0x10,%esp
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY) 
80102985:	90                   	nop
80102986:	68 f7 01 00 00       	push   $0x1f7
8010298b:	e8 67 ff ff ff       	call   801028f7 <inb>
80102990:	83 c4 04             	add    $0x4,%esp
80102993:	0f b6 c0             	movzbl %al,%eax
80102996:	89 45 fc             	mov    %eax,-0x4(%ebp)
80102999:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010299c:	25 c0 00 00 00       	and    $0xc0,%eax
801029a1:	83 f8 40             	cmp    $0x40,%eax
801029a4:	75 e0                	jne    80102986 <idewait+0x7>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
801029a6:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801029aa:	74 11                	je     801029bd <idewait+0x3e>
801029ac:	8b 45 fc             	mov    -0x4(%ebp),%eax
801029af:	83 e0 21             	and    $0x21,%eax
801029b2:	85 c0                	test   %eax,%eax
801029b4:	74 07                	je     801029bd <idewait+0x3e>
    return -1;
801029b6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801029bb:	eb 05                	jmp    801029c2 <idewait+0x43>
  return 0;
801029bd:	b8 00 00 00 00       	mov    $0x0,%eax
}
801029c2:	c9                   	leave  
801029c3:	c3                   	ret    

801029c4 <ideinit>:

void
ideinit(void)
{
801029c4:	55                   	push   %ebp
801029c5:	89 e5                	mov    %esp,%ebp
801029c7:	83 ec 18             	sub    $0x18,%esp
  int i;
  
  initlock(&idelock, "ide");
801029ca:	83 ec 08             	sub    $0x8,%esp
801029cd:	68 b2 8a 10 80       	push   $0x80108ab2
801029d2:	68 00 b6 10 80       	push   $0x8010b600
801029d7:	e8 bf 29 00 00       	call   8010539b <initlock>
801029dc:	83 c4 10             	add    $0x10,%esp
  picenable(IRQ_IDE);
801029df:	83 ec 0c             	sub    $0xc,%esp
801029e2:	6a 0e                	push   $0xe
801029e4:	e8 fe 18 00 00       	call   801042e7 <picenable>
801029e9:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_IDE, ncpu - 1);
801029ec:	a1 20 2c 11 80       	mov    0x80112c20,%eax
801029f1:	83 e8 01             	sub    $0x1,%eax
801029f4:	83 ec 08             	sub    $0x8,%esp
801029f7:	50                   	push   %eax
801029f8:	6a 0e                	push   $0xe
801029fa:	e8 73 04 00 00       	call   80102e72 <ioapicenable>
801029ff:	83 c4 10             	add    $0x10,%esp
  idewait(0);
80102a02:	83 ec 0c             	sub    $0xc,%esp
80102a05:	6a 00                	push   $0x0
80102a07:	e8 73 ff ff ff       	call   8010297f <idewait>
80102a0c:	83 c4 10             	add    $0x10,%esp
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
80102a0f:	83 ec 08             	sub    $0x8,%esp
80102a12:	68 f0 00 00 00       	push   $0xf0
80102a17:	68 f6 01 00 00       	push   $0x1f6
80102a1c:	e8 19 ff ff ff       	call   8010293a <outb>
80102a21:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<1000; i++){
80102a24:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102a2b:	eb 24                	jmp    80102a51 <ideinit+0x8d>
    if(inb(0x1f7) != 0){
80102a2d:	83 ec 0c             	sub    $0xc,%esp
80102a30:	68 f7 01 00 00       	push   $0x1f7
80102a35:	e8 bd fe ff ff       	call   801028f7 <inb>
80102a3a:	83 c4 10             	add    $0x10,%esp
80102a3d:	84 c0                	test   %al,%al
80102a3f:	74 0c                	je     80102a4d <ideinit+0x89>
      havedisk1 = 1;
80102a41:	c7 05 38 b6 10 80 01 	movl   $0x1,0x8010b638
80102a48:	00 00 00 
      break;
80102a4b:	eb 0d                	jmp    80102a5a <ideinit+0x96>
  ioapicenable(IRQ_IDE, ncpu - 1);
  idewait(0);
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
  for(i=0; i<1000; i++){
80102a4d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102a51:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
80102a58:	7e d3                	jle    80102a2d <ideinit+0x69>
      break;
    }
  }
  
  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
80102a5a:	83 ec 08             	sub    $0x8,%esp
80102a5d:	68 e0 00 00 00       	push   $0xe0
80102a62:	68 f6 01 00 00       	push   $0x1f6
80102a67:	e8 ce fe ff ff       	call   8010293a <outb>
80102a6c:	83 c4 10             	add    $0x10,%esp
}
80102a6f:	90                   	nop
80102a70:	c9                   	leave  
80102a71:	c3                   	ret    

80102a72 <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
80102a72:	55                   	push   %ebp
80102a73:	89 e5                	mov    %esp,%ebp
80102a75:	83 ec 18             	sub    $0x18,%esp
  if(b == 0)
80102a78:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102a7c:	75 0d                	jne    80102a8b <idestart+0x19>
    panic("idestart");
80102a7e:	83 ec 0c             	sub    $0xc,%esp
80102a81:	68 b6 8a 10 80       	push   $0x80108ab6
80102a86:	e8 db da ff ff       	call   80100566 <panic>
  if(b->blockno >= FSSIZE)
80102a8b:	8b 45 08             	mov    0x8(%ebp),%eax
80102a8e:	8b 40 08             	mov    0x8(%eax),%eax
80102a91:	3d e7 03 00 00       	cmp    $0x3e7,%eax
80102a96:	76 0d                	jbe    80102aa5 <idestart+0x33>
    panic("incorrect blockno");
80102a98:	83 ec 0c             	sub    $0xc,%esp
80102a9b:	68 bf 8a 10 80       	push   $0x80108abf
80102aa0:	e8 c1 da ff ff       	call   80100566 <panic>
  int sector_per_block =  BSIZE/SECTOR_SIZE;
80102aa5:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  int sector = b->blockno * sector_per_block;
80102aac:	8b 45 08             	mov    0x8(%ebp),%eax
80102aaf:	8b 50 08             	mov    0x8(%eax),%edx
80102ab2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ab5:	0f af c2             	imul   %edx,%eax
80102ab8:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if (sector_per_block > 7) panic("idestart");
80102abb:	83 7d f4 07          	cmpl   $0x7,-0xc(%ebp)
80102abf:	7e 0d                	jle    80102ace <idestart+0x5c>
80102ac1:	83 ec 0c             	sub    $0xc,%esp
80102ac4:	68 b6 8a 10 80       	push   $0x80108ab6
80102ac9:	e8 98 da ff ff       	call   80100566 <panic>
  
  idewait(0);
80102ace:	83 ec 0c             	sub    $0xc,%esp
80102ad1:	6a 00                	push   $0x0
80102ad3:	e8 a7 fe ff ff       	call   8010297f <idewait>
80102ad8:	83 c4 10             	add    $0x10,%esp
  outb(0x3f6, 0);  // generate interrupt
80102adb:	83 ec 08             	sub    $0x8,%esp
80102ade:	6a 00                	push   $0x0
80102ae0:	68 f6 03 00 00       	push   $0x3f6
80102ae5:	e8 50 fe ff ff       	call   8010293a <outb>
80102aea:	83 c4 10             	add    $0x10,%esp
  outb(0x1f2, sector_per_block);  // number of sectors
80102aed:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102af0:	0f b6 c0             	movzbl %al,%eax
80102af3:	83 ec 08             	sub    $0x8,%esp
80102af6:	50                   	push   %eax
80102af7:	68 f2 01 00 00       	push   $0x1f2
80102afc:	e8 39 fe ff ff       	call   8010293a <outb>
80102b01:	83 c4 10             	add    $0x10,%esp
  outb(0x1f3, sector & 0xff);
80102b04:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102b07:	0f b6 c0             	movzbl %al,%eax
80102b0a:	83 ec 08             	sub    $0x8,%esp
80102b0d:	50                   	push   %eax
80102b0e:	68 f3 01 00 00       	push   $0x1f3
80102b13:	e8 22 fe ff ff       	call   8010293a <outb>
80102b18:	83 c4 10             	add    $0x10,%esp
  outb(0x1f4, (sector >> 8) & 0xff);
80102b1b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102b1e:	c1 f8 08             	sar    $0x8,%eax
80102b21:	0f b6 c0             	movzbl %al,%eax
80102b24:	83 ec 08             	sub    $0x8,%esp
80102b27:	50                   	push   %eax
80102b28:	68 f4 01 00 00       	push   $0x1f4
80102b2d:	e8 08 fe ff ff       	call   8010293a <outb>
80102b32:	83 c4 10             	add    $0x10,%esp
  outb(0x1f5, (sector >> 16) & 0xff);
80102b35:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102b38:	c1 f8 10             	sar    $0x10,%eax
80102b3b:	0f b6 c0             	movzbl %al,%eax
80102b3e:	83 ec 08             	sub    $0x8,%esp
80102b41:	50                   	push   %eax
80102b42:	68 f5 01 00 00       	push   $0x1f5
80102b47:	e8 ee fd ff ff       	call   8010293a <outb>
80102b4c:	83 c4 10             	add    $0x10,%esp
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
80102b4f:	8b 45 08             	mov    0x8(%ebp),%eax
80102b52:	8b 40 04             	mov    0x4(%eax),%eax
80102b55:	83 e0 01             	and    $0x1,%eax
80102b58:	c1 e0 04             	shl    $0x4,%eax
80102b5b:	89 c2                	mov    %eax,%edx
80102b5d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102b60:	c1 f8 18             	sar    $0x18,%eax
80102b63:	83 e0 0f             	and    $0xf,%eax
80102b66:	09 d0                	or     %edx,%eax
80102b68:	83 c8 e0             	or     $0xffffffe0,%eax
80102b6b:	0f b6 c0             	movzbl %al,%eax
80102b6e:	83 ec 08             	sub    $0x8,%esp
80102b71:	50                   	push   %eax
80102b72:	68 f6 01 00 00       	push   $0x1f6
80102b77:	e8 be fd ff ff       	call   8010293a <outb>
80102b7c:	83 c4 10             	add    $0x10,%esp
  if(b->flags & B_DIRTY){
80102b7f:	8b 45 08             	mov    0x8(%ebp),%eax
80102b82:	8b 00                	mov    (%eax),%eax
80102b84:	83 e0 04             	and    $0x4,%eax
80102b87:	85 c0                	test   %eax,%eax
80102b89:	74 30                	je     80102bbb <idestart+0x149>
    outb(0x1f7, IDE_CMD_WRITE);
80102b8b:	83 ec 08             	sub    $0x8,%esp
80102b8e:	6a 30                	push   $0x30
80102b90:	68 f7 01 00 00       	push   $0x1f7
80102b95:	e8 a0 fd ff ff       	call   8010293a <outb>
80102b9a:	83 c4 10             	add    $0x10,%esp
    outsl(0x1f0, b->data, BSIZE/4);
80102b9d:	8b 45 08             	mov    0x8(%ebp),%eax
80102ba0:	83 c0 18             	add    $0x18,%eax
80102ba3:	83 ec 04             	sub    $0x4,%esp
80102ba6:	68 80 00 00 00       	push   $0x80
80102bab:	50                   	push   %eax
80102bac:	68 f0 01 00 00       	push   $0x1f0
80102bb1:	e8 a3 fd ff ff       	call   80102959 <outsl>
80102bb6:	83 c4 10             	add    $0x10,%esp
  } else {
    outb(0x1f7, IDE_CMD_READ);
  }
}
80102bb9:	eb 12                	jmp    80102bcd <idestart+0x15b>
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
  if(b->flags & B_DIRTY){
    outb(0x1f7, IDE_CMD_WRITE);
    outsl(0x1f0, b->data, BSIZE/4);
  } else {
    outb(0x1f7, IDE_CMD_READ);
80102bbb:	83 ec 08             	sub    $0x8,%esp
80102bbe:	6a 20                	push   $0x20
80102bc0:	68 f7 01 00 00       	push   $0x1f7
80102bc5:	e8 70 fd ff ff       	call   8010293a <outb>
80102bca:	83 c4 10             	add    $0x10,%esp
  }
}
80102bcd:	90                   	nop
80102bce:	c9                   	leave  
80102bcf:	c3                   	ret    

80102bd0 <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
80102bd0:	55                   	push   %ebp
80102bd1:	89 e5                	mov    %esp,%ebp
80102bd3:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
80102bd6:	83 ec 0c             	sub    $0xc,%esp
80102bd9:	68 00 b6 10 80       	push   $0x8010b600
80102bde:	e8 da 27 00 00       	call   801053bd <acquire>
80102be3:	83 c4 10             	add    $0x10,%esp
  if((b = idequeue) == 0){
80102be6:	a1 34 b6 10 80       	mov    0x8010b634,%eax
80102beb:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102bee:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102bf2:	75 15                	jne    80102c09 <ideintr+0x39>
    release(&idelock);
80102bf4:	83 ec 0c             	sub    $0xc,%esp
80102bf7:	68 00 b6 10 80       	push   $0x8010b600
80102bfc:	e8 23 28 00 00       	call   80105424 <release>
80102c01:	83 c4 10             	add    $0x10,%esp
    // cprintf("spurious IDE interrupt\n");
    return;
80102c04:	e9 9a 00 00 00       	jmp    80102ca3 <ideintr+0xd3>
  }
  idequeue = b->qnext;
80102c09:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c0c:	8b 40 14             	mov    0x14(%eax),%eax
80102c0f:	a3 34 b6 10 80       	mov    %eax,0x8010b634

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
80102c14:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c17:	8b 00                	mov    (%eax),%eax
80102c19:	83 e0 04             	and    $0x4,%eax
80102c1c:	85 c0                	test   %eax,%eax
80102c1e:	75 2d                	jne    80102c4d <ideintr+0x7d>
80102c20:	83 ec 0c             	sub    $0xc,%esp
80102c23:	6a 01                	push   $0x1
80102c25:	e8 55 fd ff ff       	call   8010297f <idewait>
80102c2a:	83 c4 10             	add    $0x10,%esp
80102c2d:	85 c0                	test   %eax,%eax
80102c2f:	78 1c                	js     80102c4d <ideintr+0x7d>
    insl(0x1f0, b->data, BSIZE/4);
80102c31:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c34:	83 c0 18             	add    $0x18,%eax
80102c37:	83 ec 04             	sub    $0x4,%esp
80102c3a:	68 80 00 00 00       	push   $0x80
80102c3f:	50                   	push   %eax
80102c40:	68 f0 01 00 00       	push   $0x1f0
80102c45:	e8 ca fc ff ff       	call   80102914 <insl>
80102c4a:	83 c4 10             	add    $0x10,%esp
  
  // Wake process waiting for this buf.
  b->flags |= B_VALID;
80102c4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c50:	8b 00                	mov    (%eax),%eax
80102c52:	83 c8 02             	or     $0x2,%eax
80102c55:	89 c2                	mov    %eax,%edx
80102c57:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c5a:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
80102c5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c5f:	8b 00                	mov    (%eax),%eax
80102c61:	83 e0 fb             	and    $0xfffffffb,%eax
80102c64:	89 c2                	mov    %eax,%edx
80102c66:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c69:	89 10                	mov    %edx,(%eax)
  wakeup(b);
80102c6b:	83 ec 0c             	sub    $0xc,%esp
80102c6e:	ff 75 f4             	pushl  -0xc(%ebp)
80102c71:	e8 39 25 00 00       	call   801051af <wakeup>
80102c76:	83 c4 10             	add    $0x10,%esp
  
  // Start disk on next buf in queue.
  if(idequeue != 0)
80102c79:	a1 34 b6 10 80       	mov    0x8010b634,%eax
80102c7e:	85 c0                	test   %eax,%eax
80102c80:	74 11                	je     80102c93 <ideintr+0xc3>
    idestart(idequeue);
80102c82:	a1 34 b6 10 80       	mov    0x8010b634,%eax
80102c87:	83 ec 0c             	sub    $0xc,%esp
80102c8a:	50                   	push   %eax
80102c8b:	e8 e2 fd ff ff       	call   80102a72 <idestart>
80102c90:	83 c4 10             	add    $0x10,%esp

  release(&idelock);
80102c93:	83 ec 0c             	sub    $0xc,%esp
80102c96:	68 00 b6 10 80       	push   $0x8010b600
80102c9b:	e8 84 27 00 00       	call   80105424 <release>
80102ca0:	83 c4 10             	add    $0x10,%esp
}
80102ca3:	c9                   	leave  
80102ca4:	c3                   	ret    

80102ca5 <iderw>:
// Sync buf with disk. 
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
80102ca5:	55                   	push   %ebp
80102ca6:	89 e5                	mov    %esp,%ebp
80102ca8:	83 ec 18             	sub    $0x18,%esp
  struct buf **pp;

  if(!(b->flags & B_BUSY))
80102cab:	8b 45 08             	mov    0x8(%ebp),%eax
80102cae:	8b 00                	mov    (%eax),%eax
80102cb0:	83 e0 01             	and    $0x1,%eax
80102cb3:	85 c0                	test   %eax,%eax
80102cb5:	75 0d                	jne    80102cc4 <iderw+0x1f>
    panic("iderw: buf not busy");
80102cb7:	83 ec 0c             	sub    $0xc,%esp
80102cba:	68 d1 8a 10 80       	push   $0x80108ad1
80102cbf:	e8 a2 d8 ff ff       	call   80100566 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
80102cc4:	8b 45 08             	mov    0x8(%ebp),%eax
80102cc7:	8b 00                	mov    (%eax),%eax
80102cc9:	83 e0 06             	and    $0x6,%eax
80102ccc:	83 f8 02             	cmp    $0x2,%eax
80102ccf:	75 0d                	jne    80102cde <iderw+0x39>
    panic("iderw: nothing to do");
80102cd1:	83 ec 0c             	sub    $0xc,%esp
80102cd4:	68 e5 8a 10 80       	push   $0x80108ae5
80102cd9:	e8 88 d8 ff ff       	call   80100566 <panic>
  if(b->dev != 0 && !havedisk1)
80102cde:	8b 45 08             	mov    0x8(%ebp),%eax
80102ce1:	8b 40 04             	mov    0x4(%eax),%eax
80102ce4:	85 c0                	test   %eax,%eax
80102ce6:	74 16                	je     80102cfe <iderw+0x59>
80102ce8:	a1 38 b6 10 80       	mov    0x8010b638,%eax
80102ced:	85 c0                	test   %eax,%eax
80102cef:	75 0d                	jne    80102cfe <iderw+0x59>
    panic("iderw: ide disk 1 not present");
80102cf1:	83 ec 0c             	sub    $0xc,%esp
80102cf4:	68 fa 8a 10 80       	push   $0x80108afa
80102cf9:	e8 68 d8 ff ff       	call   80100566 <panic>

  acquire(&idelock);  //DOC:acquire-lock
80102cfe:	83 ec 0c             	sub    $0xc,%esp
80102d01:	68 00 b6 10 80       	push   $0x8010b600
80102d06:	e8 b2 26 00 00       	call   801053bd <acquire>
80102d0b:	83 c4 10             	add    $0x10,%esp

  // Append b to idequeue.
  b->qnext = 0;
80102d0e:	8b 45 08             	mov    0x8(%ebp),%eax
80102d11:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80102d18:	c7 45 f4 34 b6 10 80 	movl   $0x8010b634,-0xc(%ebp)
80102d1f:	eb 0b                	jmp    80102d2c <iderw+0x87>
80102d21:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102d24:	8b 00                	mov    (%eax),%eax
80102d26:	83 c0 14             	add    $0x14,%eax
80102d29:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102d2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102d2f:	8b 00                	mov    (%eax),%eax
80102d31:	85 c0                	test   %eax,%eax
80102d33:	75 ec                	jne    80102d21 <iderw+0x7c>
    ;
  *pp = b;
80102d35:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102d38:	8b 55 08             	mov    0x8(%ebp),%edx
80102d3b:	89 10                	mov    %edx,(%eax)
  
  // Start disk if necessary.
  if(idequeue == b)
80102d3d:	a1 34 b6 10 80       	mov    0x8010b634,%eax
80102d42:	3b 45 08             	cmp    0x8(%ebp),%eax
80102d45:	75 23                	jne    80102d6a <iderw+0xc5>
    idestart(b);
80102d47:	83 ec 0c             	sub    $0xc,%esp
80102d4a:	ff 75 08             	pushl  0x8(%ebp)
80102d4d:	e8 20 fd ff ff       	call   80102a72 <idestart>
80102d52:	83 c4 10             	add    $0x10,%esp
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102d55:	eb 13                	jmp    80102d6a <iderw+0xc5>
    sleep(b, &idelock);
80102d57:	83 ec 08             	sub    $0x8,%esp
80102d5a:	68 00 b6 10 80       	push   $0x8010b600
80102d5f:	ff 75 08             	pushl  0x8(%ebp)
80102d62:	e8 5d 23 00 00       	call   801050c4 <sleep>
80102d67:	83 c4 10             	add    $0x10,%esp
  // Start disk if necessary.
  if(idequeue == b)
    idestart(b);
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102d6a:	8b 45 08             	mov    0x8(%ebp),%eax
80102d6d:	8b 00                	mov    (%eax),%eax
80102d6f:	83 e0 06             	and    $0x6,%eax
80102d72:	83 f8 02             	cmp    $0x2,%eax
80102d75:	75 e0                	jne    80102d57 <iderw+0xb2>
    sleep(b, &idelock);
  }

  release(&idelock);
80102d77:	83 ec 0c             	sub    $0xc,%esp
80102d7a:	68 00 b6 10 80       	push   $0x8010b600
80102d7f:	e8 a0 26 00 00       	call   80105424 <release>
80102d84:	83 c4 10             	add    $0x10,%esp
}
80102d87:	90                   	nop
80102d88:	c9                   	leave  
80102d89:	c3                   	ret    

80102d8a <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
80102d8a:	55                   	push   %ebp
80102d8b:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102d8d:	a1 fc 24 11 80       	mov    0x801124fc,%eax
80102d92:	8b 55 08             	mov    0x8(%ebp),%edx
80102d95:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80102d97:	a1 fc 24 11 80       	mov    0x801124fc,%eax
80102d9c:	8b 40 10             	mov    0x10(%eax),%eax
}
80102d9f:	5d                   	pop    %ebp
80102da0:	c3                   	ret    

80102da1 <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
80102da1:	55                   	push   %ebp
80102da2:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102da4:	a1 fc 24 11 80       	mov    0x801124fc,%eax
80102da9:	8b 55 08             	mov    0x8(%ebp),%edx
80102dac:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
80102dae:	a1 fc 24 11 80       	mov    0x801124fc,%eax
80102db3:	8b 55 0c             	mov    0xc(%ebp),%edx
80102db6:	89 50 10             	mov    %edx,0x10(%eax)
}
80102db9:	90                   	nop
80102dba:	5d                   	pop    %ebp
80102dbb:	c3                   	ret    

80102dbc <ioapicinit>:

void
ioapicinit(void)
{
80102dbc:	55                   	push   %ebp
80102dbd:	89 e5                	mov    %esp,%ebp
80102dbf:	83 ec 18             	sub    $0x18,%esp
  int i, id, maxintr;

  if(!ismp)
80102dc2:	a1 24 26 11 80       	mov    0x80112624,%eax
80102dc7:	85 c0                	test   %eax,%eax
80102dc9:	0f 84 a0 00 00 00    	je     80102e6f <ioapicinit+0xb3>
    return;

  ioapic = (volatile struct ioapic*)IOAPIC;
80102dcf:	c7 05 fc 24 11 80 00 	movl   $0xfec00000,0x801124fc
80102dd6:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80102dd9:	6a 01                	push   $0x1
80102ddb:	e8 aa ff ff ff       	call   80102d8a <ioapicread>
80102de0:	83 c4 04             	add    $0x4,%esp
80102de3:	c1 e8 10             	shr    $0x10,%eax
80102de6:	25 ff 00 00 00       	and    $0xff,%eax
80102deb:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
80102dee:	6a 00                	push   $0x0
80102df0:	e8 95 ff ff ff       	call   80102d8a <ioapicread>
80102df5:	83 c4 04             	add    $0x4,%esp
80102df8:	c1 e8 18             	shr    $0x18,%eax
80102dfb:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
80102dfe:	0f b6 05 20 26 11 80 	movzbl 0x80112620,%eax
80102e05:	0f b6 c0             	movzbl %al,%eax
80102e08:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80102e0b:	74 10                	je     80102e1d <ioapicinit+0x61>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80102e0d:	83 ec 0c             	sub    $0xc,%esp
80102e10:	68 18 8b 10 80       	push   $0x80108b18
80102e15:	e8 ac d5 ff ff       	call   801003c6 <cprintf>
80102e1a:	83 c4 10             	add    $0x10,%esp

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102e1d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102e24:	eb 3f                	jmp    80102e65 <ioapicinit+0xa9>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80102e26:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e29:	83 c0 20             	add    $0x20,%eax
80102e2c:	0d 00 00 01 00       	or     $0x10000,%eax
80102e31:	89 c2                	mov    %eax,%edx
80102e33:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e36:	83 c0 08             	add    $0x8,%eax
80102e39:	01 c0                	add    %eax,%eax
80102e3b:	83 ec 08             	sub    $0x8,%esp
80102e3e:	52                   	push   %edx
80102e3f:	50                   	push   %eax
80102e40:	e8 5c ff ff ff       	call   80102da1 <ioapicwrite>
80102e45:	83 c4 10             	add    $0x10,%esp
    ioapicwrite(REG_TABLE+2*i+1, 0);
80102e48:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e4b:	83 c0 08             	add    $0x8,%eax
80102e4e:	01 c0                	add    %eax,%eax
80102e50:	83 c0 01             	add    $0x1,%eax
80102e53:	83 ec 08             	sub    $0x8,%esp
80102e56:	6a 00                	push   $0x0
80102e58:	50                   	push   %eax
80102e59:	e8 43 ff ff ff       	call   80102da1 <ioapicwrite>
80102e5e:	83 c4 10             	add    $0x10,%esp
  if(id != ioapicid)
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102e61:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102e65:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e68:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102e6b:	7e b9                	jle    80102e26 <ioapicinit+0x6a>
80102e6d:	eb 01                	jmp    80102e70 <ioapicinit+0xb4>
ioapicinit(void)
{
  int i, id, maxintr;

  if(!ismp)
    return;
80102e6f:	90                   	nop
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
    ioapicwrite(REG_TABLE+2*i+1, 0);
  }
}
80102e70:	c9                   	leave  
80102e71:	c3                   	ret    

80102e72 <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80102e72:	55                   	push   %ebp
80102e73:	89 e5                	mov    %esp,%ebp
  if(!ismp)
80102e75:	a1 24 26 11 80       	mov    0x80112624,%eax
80102e7a:	85 c0                	test   %eax,%eax
80102e7c:	74 39                	je     80102eb7 <ioapicenable+0x45>
    return;

  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102e7e:	8b 45 08             	mov    0x8(%ebp),%eax
80102e81:	83 c0 20             	add    $0x20,%eax
80102e84:	89 c2                	mov    %eax,%edx
80102e86:	8b 45 08             	mov    0x8(%ebp),%eax
80102e89:	83 c0 08             	add    $0x8,%eax
80102e8c:	01 c0                	add    %eax,%eax
80102e8e:	52                   	push   %edx
80102e8f:	50                   	push   %eax
80102e90:	e8 0c ff ff ff       	call   80102da1 <ioapicwrite>
80102e95:	83 c4 08             	add    $0x8,%esp
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80102e98:	8b 45 0c             	mov    0xc(%ebp),%eax
80102e9b:	c1 e0 18             	shl    $0x18,%eax
80102e9e:	89 c2                	mov    %eax,%edx
80102ea0:	8b 45 08             	mov    0x8(%ebp),%eax
80102ea3:	83 c0 08             	add    $0x8,%eax
80102ea6:	01 c0                	add    %eax,%eax
80102ea8:	83 c0 01             	add    $0x1,%eax
80102eab:	52                   	push   %edx
80102eac:	50                   	push   %eax
80102ead:	e8 ef fe ff ff       	call   80102da1 <ioapicwrite>
80102eb2:	83 c4 08             	add    $0x8,%esp
80102eb5:	eb 01                	jmp    80102eb8 <ioapicenable+0x46>

void
ioapicenable(int irq, int cpunum)
{
  if(!ismp)
    return;
80102eb7:	90                   	nop
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
}
80102eb8:	c9                   	leave  
80102eb9:	c3                   	ret    

80102eba <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
80102eba:	55                   	push   %ebp
80102ebb:	89 e5                	mov    %esp,%ebp
80102ebd:	8b 45 08             	mov    0x8(%ebp),%eax
80102ec0:	05 00 00 00 80       	add    $0x80000000,%eax
80102ec5:	5d                   	pop    %ebp
80102ec6:	c3                   	ret    

80102ec7 <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
80102ec7:	55                   	push   %ebp
80102ec8:	89 e5                	mov    %esp,%ebp
80102eca:	83 ec 08             	sub    $0x8,%esp
  initlock(&kmem.lock, "kmem");
80102ecd:	83 ec 08             	sub    $0x8,%esp
80102ed0:	68 4a 8b 10 80       	push   $0x80108b4a
80102ed5:	68 00 25 11 80       	push   $0x80112500
80102eda:	e8 bc 24 00 00       	call   8010539b <initlock>
80102edf:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 0;
80102ee2:	c7 05 34 25 11 80 00 	movl   $0x0,0x80112534
80102ee9:	00 00 00 
  freerange(vstart, vend);
80102eec:	83 ec 08             	sub    $0x8,%esp
80102eef:	ff 75 0c             	pushl  0xc(%ebp)
80102ef2:	ff 75 08             	pushl  0x8(%ebp)
80102ef5:	e8 2a 00 00 00       	call   80102f24 <freerange>
80102efa:	83 c4 10             	add    $0x10,%esp
}
80102efd:	90                   	nop
80102efe:	c9                   	leave  
80102eff:	c3                   	ret    

80102f00 <kinit2>:

void
kinit2(void *vstart, void *vend)
{
80102f00:	55                   	push   %ebp
80102f01:	89 e5                	mov    %esp,%ebp
80102f03:	83 ec 08             	sub    $0x8,%esp
  freerange(vstart, vend);
80102f06:	83 ec 08             	sub    $0x8,%esp
80102f09:	ff 75 0c             	pushl  0xc(%ebp)
80102f0c:	ff 75 08             	pushl  0x8(%ebp)
80102f0f:	e8 10 00 00 00       	call   80102f24 <freerange>
80102f14:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 1;
80102f17:	c7 05 34 25 11 80 01 	movl   $0x1,0x80112534
80102f1e:	00 00 00 
}
80102f21:	90                   	nop
80102f22:	c9                   	leave  
80102f23:	c3                   	ret    

80102f24 <freerange>:

void
freerange(void *vstart, void *vend)
{
80102f24:	55                   	push   %ebp
80102f25:	89 e5                	mov    %esp,%ebp
80102f27:	83 ec 18             	sub    $0x18,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
80102f2a:	8b 45 08             	mov    0x8(%ebp),%eax
80102f2d:	05 ff 0f 00 00       	add    $0xfff,%eax
80102f32:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80102f37:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102f3a:	eb 15                	jmp    80102f51 <freerange+0x2d>
    kfree(p);
80102f3c:	83 ec 0c             	sub    $0xc,%esp
80102f3f:	ff 75 f4             	pushl  -0xc(%ebp)
80102f42:	e8 1a 00 00 00       	call   80102f61 <kfree>
80102f47:	83 c4 10             	add    $0x10,%esp
void
freerange(void *vstart, void *vend)
{
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102f4a:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80102f51:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102f54:	05 00 10 00 00       	add    $0x1000,%eax
80102f59:	3b 45 0c             	cmp    0xc(%ebp),%eax
80102f5c:	76 de                	jbe    80102f3c <freerange+0x18>
    kfree(p);
}
80102f5e:	90                   	nop
80102f5f:	c9                   	leave  
80102f60:	c3                   	ret    

80102f61 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102f61:	55                   	push   %ebp
80102f62:	89 e5                	mov    %esp,%ebp
80102f64:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || v2p(v) >= PHYSTOP)
80102f67:	8b 45 08             	mov    0x8(%ebp),%eax
80102f6a:	25 ff 0f 00 00       	and    $0xfff,%eax
80102f6f:	85 c0                	test   %eax,%eax
80102f71:	75 1b                	jne    80102f8e <kfree+0x2d>
80102f73:	81 7d 08 1c 54 11 80 	cmpl   $0x8011541c,0x8(%ebp)
80102f7a:	72 12                	jb     80102f8e <kfree+0x2d>
80102f7c:	ff 75 08             	pushl  0x8(%ebp)
80102f7f:	e8 36 ff ff ff       	call   80102eba <v2p>
80102f84:	83 c4 04             	add    $0x4,%esp
80102f87:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80102f8c:	76 0d                	jbe    80102f9b <kfree+0x3a>
    panic("kfree");
80102f8e:	83 ec 0c             	sub    $0xc,%esp
80102f91:	68 4f 8b 10 80       	push   $0x80108b4f
80102f96:	e8 cb d5 ff ff       	call   80100566 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102f9b:	83 ec 04             	sub    $0x4,%esp
80102f9e:	68 00 10 00 00       	push   $0x1000
80102fa3:	6a 01                	push   $0x1
80102fa5:	ff 75 08             	pushl  0x8(%ebp)
80102fa8:	e8 73 26 00 00       	call   80105620 <memset>
80102fad:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
80102fb0:	a1 34 25 11 80       	mov    0x80112534,%eax
80102fb5:	85 c0                	test   %eax,%eax
80102fb7:	74 10                	je     80102fc9 <kfree+0x68>
    acquire(&kmem.lock);
80102fb9:	83 ec 0c             	sub    $0xc,%esp
80102fbc:	68 00 25 11 80       	push   $0x80112500
80102fc1:	e8 f7 23 00 00       	call   801053bd <acquire>
80102fc6:	83 c4 10             	add    $0x10,%esp
  r = (struct run*)v;
80102fc9:	8b 45 08             	mov    0x8(%ebp),%eax
80102fcc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102fcf:	8b 15 38 25 11 80    	mov    0x80112538,%edx
80102fd5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102fd8:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80102fda:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102fdd:	a3 38 25 11 80       	mov    %eax,0x80112538
  if(kmem.use_lock)
80102fe2:	a1 34 25 11 80       	mov    0x80112534,%eax
80102fe7:	85 c0                	test   %eax,%eax
80102fe9:	74 10                	je     80102ffb <kfree+0x9a>
    release(&kmem.lock);
80102feb:	83 ec 0c             	sub    $0xc,%esp
80102fee:	68 00 25 11 80       	push   $0x80112500
80102ff3:	e8 2c 24 00 00       	call   80105424 <release>
80102ff8:	83 c4 10             	add    $0x10,%esp
}
80102ffb:	90                   	nop
80102ffc:	c9                   	leave  
80102ffd:	c3                   	ret    

80102ffe <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80102ffe:	55                   	push   %ebp
80102fff:	89 e5                	mov    %esp,%ebp
80103001:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if(kmem.use_lock)
80103004:	a1 34 25 11 80       	mov    0x80112534,%eax
80103009:	85 c0                	test   %eax,%eax
8010300b:	74 10                	je     8010301d <kalloc+0x1f>
    acquire(&kmem.lock);
8010300d:	83 ec 0c             	sub    $0xc,%esp
80103010:	68 00 25 11 80       	push   $0x80112500
80103015:	e8 a3 23 00 00       	call   801053bd <acquire>
8010301a:	83 c4 10             	add    $0x10,%esp
  r = kmem.freelist;
8010301d:	a1 38 25 11 80       	mov    0x80112538,%eax
80103022:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
80103025:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103029:	74 0a                	je     80103035 <kalloc+0x37>
    kmem.freelist = r->next;
8010302b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010302e:	8b 00                	mov    (%eax),%eax
80103030:	a3 38 25 11 80       	mov    %eax,0x80112538
  if(kmem.use_lock)
80103035:	a1 34 25 11 80       	mov    0x80112534,%eax
8010303a:	85 c0                	test   %eax,%eax
8010303c:	74 10                	je     8010304e <kalloc+0x50>
    release(&kmem.lock);
8010303e:	83 ec 0c             	sub    $0xc,%esp
80103041:	68 00 25 11 80       	push   $0x80112500
80103046:	e8 d9 23 00 00       	call   80105424 <release>
8010304b:	83 c4 10             	add    $0x10,%esp
  return (char*)r;
8010304e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80103051:	c9                   	leave  
80103052:	c3                   	ret    

80103053 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80103053:	55                   	push   %ebp
80103054:	89 e5                	mov    %esp,%ebp
80103056:	83 ec 14             	sub    $0x14,%esp
80103059:	8b 45 08             	mov    0x8(%ebp),%eax
8010305c:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80103060:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80103064:	89 c2                	mov    %eax,%edx
80103066:	ec                   	in     (%dx),%al
80103067:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
8010306a:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
8010306e:	c9                   	leave  
8010306f:	c3                   	ret    

80103070 <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80103070:	55                   	push   %ebp
80103071:	89 e5                	mov    %esp,%ebp
80103073:	83 ec 10             	sub    $0x10,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80103076:	6a 64                	push   $0x64
80103078:	e8 d6 ff ff ff       	call   80103053 <inb>
8010307d:	83 c4 04             	add    $0x4,%esp
80103080:	0f b6 c0             	movzbl %al,%eax
80103083:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80103086:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103089:	83 e0 01             	and    $0x1,%eax
8010308c:	85 c0                	test   %eax,%eax
8010308e:	75 0a                	jne    8010309a <kbdgetc+0x2a>
    return -1;
80103090:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103095:	e9 23 01 00 00       	jmp    801031bd <kbdgetc+0x14d>
  data = inb(KBDATAP);
8010309a:	6a 60                	push   $0x60
8010309c:	e8 b2 ff ff ff       	call   80103053 <inb>
801030a1:	83 c4 04             	add    $0x4,%esp
801030a4:	0f b6 c0             	movzbl %al,%eax
801030a7:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
801030aa:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
801030b1:	75 17                	jne    801030ca <kbdgetc+0x5a>
    shift |= E0ESC;
801030b3:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
801030b8:	83 c8 40             	or     $0x40,%eax
801030bb:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
    return 0;
801030c0:	b8 00 00 00 00       	mov    $0x0,%eax
801030c5:	e9 f3 00 00 00       	jmp    801031bd <kbdgetc+0x14d>
  } else if(data & 0x80){
801030ca:	8b 45 fc             	mov    -0x4(%ebp),%eax
801030cd:	25 80 00 00 00       	and    $0x80,%eax
801030d2:	85 c0                	test   %eax,%eax
801030d4:	74 45                	je     8010311b <kbdgetc+0xab>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
801030d6:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
801030db:	83 e0 40             	and    $0x40,%eax
801030de:	85 c0                	test   %eax,%eax
801030e0:	75 08                	jne    801030ea <kbdgetc+0x7a>
801030e2:	8b 45 fc             	mov    -0x4(%ebp),%eax
801030e5:	83 e0 7f             	and    $0x7f,%eax
801030e8:	eb 03                	jmp    801030ed <kbdgetc+0x7d>
801030ea:	8b 45 fc             	mov    -0x4(%ebp),%eax
801030ed:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
801030f0:	8b 45 fc             	mov    -0x4(%ebp),%eax
801030f3:	05 20 90 10 80       	add    $0x80109020,%eax
801030f8:	0f b6 00             	movzbl (%eax),%eax
801030fb:	83 c8 40             	or     $0x40,%eax
801030fe:	0f b6 c0             	movzbl %al,%eax
80103101:	f7 d0                	not    %eax
80103103:	89 c2                	mov    %eax,%edx
80103105:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
8010310a:	21 d0                	and    %edx,%eax
8010310c:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
    return 0;
80103111:	b8 00 00 00 00       	mov    $0x0,%eax
80103116:	e9 a2 00 00 00       	jmp    801031bd <kbdgetc+0x14d>
  } else if(shift & E0ESC){
8010311b:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80103120:	83 e0 40             	and    $0x40,%eax
80103123:	85 c0                	test   %eax,%eax
80103125:	74 14                	je     8010313b <kbdgetc+0xcb>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80103127:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
8010312e:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80103133:	83 e0 bf             	and    $0xffffffbf,%eax
80103136:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
  }

  shift |= shiftcode[data];
8010313b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010313e:	05 20 90 10 80       	add    $0x80109020,%eax
80103143:	0f b6 00             	movzbl (%eax),%eax
80103146:	0f b6 d0             	movzbl %al,%edx
80103149:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
8010314e:	09 d0                	or     %edx,%eax
80103150:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
  shift ^= togglecode[data];
80103155:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103158:	05 20 91 10 80       	add    $0x80109120,%eax
8010315d:	0f b6 00             	movzbl (%eax),%eax
80103160:	0f b6 d0             	movzbl %al,%edx
80103163:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80103168:	31 d0                	xor    %edx,%eax
8010316a:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
  c = charcode[shift & (CTL | SHIFT)][data];
8010316f:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80103174:	83 e0 03             	and    $0x3,%eax
80103177:	8b 14 85 20 95 10 80 	mov    -0x7fef6ae0(,%eax,4),%edx
8010317e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103181:	01 d0                	add    %edx,%eax
80103183:	0f b6 00             	movzbl (%eax),%eax
80103186:	0f b6 c0             	movzbl %al,%eax
80103189:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
8010318c:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80103191:	83 e0 08             	and    $0x8,%eax
80103194:	85 c0                	test   %eax,%eax
80103196:	74 22                	je     801031ba <kbdgetc+0x14a>
    if('a' <= c && c <= 'z')
80103198:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
8010319c:	76 0c                	jbe    801031aa <kbdgetc+0x13a>
8010319e:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
801031a2:	77 06                	ja     801031aa <kbdgetc+0x13a>
      c += 'A' - 'a';
801031a4:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
801031a8:	eb 10                	jmp    801031ba <kbdgetc+0x14a>
    else if('A' <= c && c <= 'Z')
801031aa:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
801031ae:	76 0a                	jbe    801031ba <kbdgetc+0x14a>
801031b0:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
801031b4:	77 04                	ja     801031ba <kbdgetc+0x14a>
      c += 'a' - 'A';
801031b6:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
801031ba:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
801031bd:	c9                   	leave  
801031be:	c3                   	ret    

801031bf <kbdintr>:

void
kbdintr(void)
{
801031bf:	55                   	push   %ebp
801031c0:	89 e5                	mov    %esp,%ebp
801031c2:	83 ec 08             	sub    $0x8,%esp
  consoleintr(kbdgetc);
801031c5:	83 ec 0c             	sub    $0xc,%esp
801031c8:	68 70 30 10 80       	push   $0x80103070
801031cd:	e8 27 d6 ff ff       	call   801007f9 <consoleintr>
801031d2:	83 c4 10             	add    $0x10,%esp
}
801031d5:	90                   	nop
801031d6:	c9                   	leave  
801031d7:	c3                   	ret    

801031d8 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801031d8:	55                   	push   %ebp
801031d9:	89 e5                	mov    %esp,%ebp
801031db:	83 ec 14             	sub    $0x14,%esp
801031de:	8b 45 08             	mov    0x8(%ebp),%eax
801031e1:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801031e5:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801031e9:	89 c2                	mov    %eax,%edx
801031eb:	ec                   	in     (%dx),%al
801031ec:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801031ef:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801031f3:	c9                   	leave  
801031f4:	c3                   	ret    

801031f5 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801031f5:	55                   	push   %ebp
801031f6:	89 e5                	mov    %esp,%ebp
801031f8:	83 ec 08             	sub    $0x8,%esp
801031fb:	8b 55 08             	mov    0x8(%ebp),%edx
801031fe:	8b 45 0c             	mov    0xc(%ebp),%eax
80103201:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103205:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103208:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
8010320c:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103210:	ee                   	out    %al,(%dx)
}
80103211:	90                   	nop
80103212:	c9                   	leave  
80103213:	c3                   	ret    

80103214 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80103214:	55                   	push   %ebp
80103215:	89 e5                	mov    %esp,%ebp
80103217:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
8010321a:	9c                   	pushf  
8010321b:	58                   	pop    %eax
8010321c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
8010321f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103222:	c9                   	leave  
80103223:	c3                   	ret    

80103224 <lapicw>:

volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
80103224:	55                   	push   %ebp
80103225:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
80103227:	a1 3c 25 11 80       	mov    0x8011253c,%eax
8010322c:	8b 55 08             	mov    0x8(%ebp),%edx
8010322f:	c1 e2 02             	shl    $0x2,%edx
80103232:	01 c2                	add    %eax,%edx
80103234:	8b 45 0c             	mov    0xc(%ebp),%eax
80103237:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
80103239:	a1 3c 25 11 80       	mov    0x8011253c,%eax
8010323e:	83 c0 20             	add    $0x20,%eax
80103241:	8b 00                	mov    (%eax),%eax
}
80103243:	90                   	nop
80103244:	5d                   	pop    %ebp
80103245:	c3                   	ret    

80103246 <lapicinit>:
//PAGEBREAK!

void
lapicinit(void)
{
80103246:	55                   	push   %ebp
80103247:	89 e5                	mov    %esp,%ebp
  if(!lapic) 
80103249:	a1 3c 25 11 80       	mov    0x8011253c,%eax
8010324e:	85 c0                	test   %eax,%eax
80103250:	0f 84 0b 01 00 00    	je     80103361 <lapicinit+0x11b>
    return;

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
80103256:	68 3f 01 00 00       	push   $0x13f
8010325b:	6a 3c                	push   $0x3c
8010325d:	e8 c2 ff ff ff       	call   80103224 <lapicw>
80103262:	83 c4 08             	add    $0x8,%esp

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.  
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
80103265:	6a 0b                	push   $0xb
80103267:	68 f8 00 00 00       	push   $0xf8
8010326c:	e8 b3 ff ff ff       	call   80103224 <lapicw>
80103271:	83 c4 08             	add    $0x8,%esp
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
80103274:	68 20 00 02 00       	push   $0x20020
80103279:	68 c8 00 00 00       	push   $0xc8
8010327e:	e8 a1 ff ff ff       	call   80103224 <lapicw>
80103283:	83 c4 08             	add    $0x8,%esp
  lapicw(TICR, 10000000); 
80103286:	68 80 96 98 00       	push   $0x989680
8010328b:	68 e0 00 00 00       	push   $0xe0
80103290:	e8 8f ff ff ff       	call   80103224 <lapicw>
80103295:	83 c4 08             	add    $0x8,%esp

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
80103298:	68 00 00 01 00       	push   $0x10000
8010329d:	68 d4 00 00 00       	push   $0xd4
801032a2:	e8 7d ff ff ff       	call   80103224 <lapicw>
801032a7:	83 c4 08             	add    $0x8,%esp
  lapicw(LINT1, MASKED);
801032aa:	68 00 00 01 00       	push   $0x10000
801032af:	68 d8 00 00 00       	push   $0xd8
801032b4:	e8 6b ff ff ff       	call   80103224 <lapicw>
801032b9:	83 c4 08             	add    $0x8,%esp

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
801032bc:	a1 3c 25 11 80       	mov    0x8011253c,%eax
801032c1:	83 c0 30             	add    $0x30,%eax
801032c4:	8b 00                	mov    (%eax),%eax
801032c6:	c1 e8 10             	shr    $0x10,%eax
801032c9:	0f b6 c0             	movzbl %al,%eax
801032cc:	83 f8 03             	cmp    $0x3,%eax
801032cf:	76 12                	jbe    801032e3 <lapicinit+0x9d>
    lapicw(PCINT, MASKED);
801032d1:	68 00 00 01 00       	push   $0x10000
801032d6:	68 d0 00 00 00       	push   $0xd0
801032db:	e8 44 ff ff ff       	call   80103224 <lapicw>
801032e0:	83 c4 08             	add    $0x8,%esp

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
801032e3:	6a 33                	push   $0x33
801032e5:	68 dc 00 00 00       	push   $0xdc
801032ea:	e8 35 ff ff ff       	call   80103224 <lapicw>
801032ef:	83 c4 08             	add    $0x8,%esp

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
801032f2:	6a 00                	push   $0x0
801032f4:	68 a0 00 00 00       	push   $0xa0
801032f9:	e8 26 ff ff ff       	call   80103224 <lapicw>
801032fe:	83 c4 08             	add    $0x8,%esp
  lapicw(ESR, 0);
80103301:	6a 00                	push   $0x0
80103303:	68 a0 00 00 00       	push   $0xa0
80103308:	e8 17 ff ff ff       	call   80103224 <lapicw>
8010330d:	83 c4 08             	add    $0x8,%esp

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
80103310:	6a 00                	push   $0x0
80103312:	6a 2c                	push   $0x2c
80103314:	e8 0b ff ff ff       	call   80103224 <lapicw>
80103319:	83 c4 08             	add    $0x8,%esp

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
8010331c:	6a 00                	push   $0x0
8010331e:	68 c4 00 00 00       	push   $0xc4
80103323:	e8 fc fe ff ff       	call   80103224 <lapicw>
80103328:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, BCAST | INIT | LEVEL);
8010332b:	68 00 85 08 00       	push   $0x88500
80103330:	68 c0 00 00 00       	push   $0xc0
80103335:	e8 ea fe ff ff       	call   80103224 <lapicw>
8010333a:	83 c4 08             	add    $0x8,%esp
  while(lapic[ICRLO] & DELIVS)
8010333d:	90                   	nop
8010333e:	a1 3c 25 11 80       	mov    0x8011253c,%eax
80103343:	05 00 03 00 00       	add    $0x300,%eax
80103348:	8b 00                	mov    (%eax),%eax
8010334a:	25 00 10 00 00       	and    $0x1000,%eax
8010334f:	85 c0                	test   %eax,%eax
80103351:	75 eb                	jne    8010333e <lapicinit+0xf8>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
80103353:	6a 00                	push   $0x0
80103355:	6a 20                	push   $0x20
80103357:	e8 c8 fe ff ff       	call   80103224 <lapicw>
8010335c:	83 c4 08             	add    $0x8,%esp
8010335f:	eb 01                	jmp    80103362 <lapicinit+0x11c>

void
lapicinit(void)
{
  if(!lapic) 
    return;
80103361:	90                   	nop
  while(lapic[ICRLO] & DELIVS)
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
}
80103362:	c9                   	leave  
80103363:	c3                   	ret    

80103364 <cpunum>:

int
cpunum(void)
{
80103364:	55                   	push   %ebp
80103365:	89 e5                	mov    %esp,%ebp
80103367:	83 ec 08             	sub    $0x8,%esp
  // Cannot call cpu when interrupts are enabled:
  // result not guaranteed to last long enough to be used!
  // Would prefer to panic but even printing is chancy here:
  // almost everything, including cprintf and panic, calls cpu,
  // often indirectly through acquire and release.
  if(readeflags()&FL_IF){
8010336a:	e8 a5 fe ff ff       	call   80103214 <readeflags>
8010336f:	25 00 02 00 00       	and    $0x200,%eax
80103374:	85 c0                	test   %eax,%eax
80103376:	74 26                	je     8010339e <cpunum+0x3a>
    static int n;
    if(n++ == 0)
80103378:	a1 40 b6 10 80       	mov    0x8010b640,%eax
8010337d:	8d 50 01             	lea    0x1(%eax),%edx
80103380:	89 15 40 b6 10 80    	mov    %edx,0x8010b640
80103386:	85 c0                	test   %eax,%eax
80103388:	75 14                	jne    8010339e <cpunum+0x3a>
      cprintf("cpu called from %x with interrupts enabled\n",
8010338a:	8b 45 04             	mov    0x4(%ebp),%eax
8010338d:	83 ec 08             	sub    $0x8,%esp
80103390:	50                   	push   %eax
80103391:	68 58 8b 10 80       	push   $0x80108b58
80103396:	e8 2b d0 ff ff       	call   801003c6 <cprintf>
8010339b:	83 c4 10             	add    $0x10,%esp
        __builtin_return_address(0));
  }

  if(lapic)
8010339e:	a1 3c 25 11 80       	mov    0x8011253c,%eax
801033a3:	85 c0                	test   %eax,%eax
801033a5:	74 0f                	je     801033b6 <cpunum+0x52>
    return lapic[ID]>>24;
801033a7:	a1 3c 25 11 80       	mov    0x8011253c,%eax
801033ac:	83 c0 20             	add    $0x20,%eax
801033af:	8b 00                	mov    (%eax),%eax
801033b1:	c1 e8 18             	shr    $0x18,%eax
801033b4:	eb 05                	jmp    801033bb <cpunum+0x57>
  return 0;
801033b6:	b8 00 00 00 00       	mov    $0x0,%eax
}
801033bb:	c9                   	leave  
801033bc:	c3                   	ret    

801033bd <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
801033bd:	55                   	push   %ebp
801033be:	89 e5                	mov    %esp,%ebp
  if(lapic)
801033c0:	a1 3c 25 11 80       	mov    0x8011253c,%eax
801033c5:	85 c0                	test   %eax,%eax
801033c7:	74 0c                	je     801033d5 <lapiceoi+0x18>
    lapicw(EOI, 0);
801033c9:	6a 00                	push   $0x0
801033cb:	6a 2c                	push   $0x2c
801033cd:	e8 52 fe ff ff       	call   80103224 <lapicw>
801033d2:	83 c4 08             	add    $0x8,%esp
}
801033d5:	90                   	nop
801033d6:	c9                   	leave  
801033d7:	c3                   	ret    

801033d8 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
801033d8:	55                   	push   %ebp
801033d9:	89 e5                	mov    %esp,%ebp
}
801033db:	90                   	nop
801033dc:	5d                   	pop    %ebp
801033dd:	c3                   	ret    

801033de <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
801033de:	55                   	push   %ebp
801033df:	89 e5                	mov    %esp,%ebp
801033e1:	83 ec 14             	sub    $0x14,%esp
801033e4:	8b 45 08             	mov    0x8(%ebp),%eax
801033e7:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;
  
  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
801033ea:	6a 0f                	push   $0xf
801033ec:	6a 70                	push   $0x70
801033ee:	e8 02 fe ff ff       	call   801031f5 <outb>
801033f3:	83 c4 08             	add    $0x8,%esp
  outb(CMOS_PORT+1, 0x0A);
801033f6:	6a 0a                	push   $0xa
801033f8:	6a 71                	push   $0x71
801033fa:	e8 f6 fd ff ff       	call   801031f5 <outb>
801033ff:	83 c4 08             	add    $0x8,%esp
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
80103402:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
80103409:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010340c:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
80103411:	8b 45 f8             	mov    -0x8(%ebp),%eax
80103414:	83 c0 02             	add    $0x2,%eax
80103417:	8b 55 0c             	mov    0xc(%ebp),%edx
8010341a:	c1 ea 04             	shr    $0x4,%edx
8010341d:	66 89 10             	mov    %dx,(%eax)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
80103420:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80103424:	c1 e0 18             	shl    $0x18,%eax
80103427:	50                   	push   %eax
80103428:	68 c4 00 00 00       	push   $0xc4
8010342d:	e8 f2 fd ff ff       	call   80103224 <lapicw>
80103432:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
80103435:	68 00 c5 00 00       	push   $0xc500
8010343a:	68 c0 00 00 00       	push   $0xc0
8010343f:	e8 e0 fd ff ff       	call   80103224 <lapicw>
80103444:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
80103447:	68 c8 00 00 00       	push   $0xc8
8010344c:	e8 87 ff ff ff       	call   801033d8 <microdelay>
80103451:	83 c4 04             	add    $0x4,%esp
  lapicw(ICRLO, INIT | LEVEL);
80103454:	68 00 85 00 00       	push   $0x8500
80103459:	68 c0 00 00 00       	push   $0xc0
8010345e:	e8 c1 fd ff ff       	call   80103224 <lapicw>
80103463:	83 c4 08             	add    $0x8,%esp
  microdelay(100);    // should be 10ms, but too slow in Bochs!
80103466:	6a 64                	push   $0x64
80103468:	e8 6b ff ff ff       	call   801033d8 <microdelay>
8010346d:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
80103470:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80103477:	eb 3d                	jmp    801034b6 <lapicstartap+0xd8>
    lapicw(ICRHI, apicid<<24);
80103479:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
8010347d:	c1 e0 18             	shl    $0x18,%eax
80103480:	50                   	push   %eax
80103481:	68 c4 00 00 00       	push   $0xc4
80103486:	e8 99 fd ff ff       	call   80103224 <lapicw>
8010348b:	83 c4 08             	add    $0x8,%esp
    lapicw(ICRLO, STARTUP | (addr>>12));
8010348e:	8b 45 0c             	mov    0xc(%ebp),%eax
80103491:	c1 e8 0c             	shr    $0xc,%eax
80103494:	80 cc 06             	or     $0x6,%ah
80103497:	50                   	push   %eax
80103498:	68 c0 00 00 00       	push   $0xc0
8010349d:	e8 82 fd ff ff       	call   80103224 <lapicw>
801034a2:	83 c4 08             	add    $0x8,%esp
    microdelay(200);
801034a5:	68 c8 00 00 00       	push   $0xc8
801034aa:	e8 29 ff ff ff       	call   801033d8 <microdelay>
801034af:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
801034b2:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801034b6:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
801034ba:	7e bd                	jle    80103479 <lapicstartap+0x9b>
    lapicw(ICRHI, apicid<<24);
    lapicw(ICRLO, STARTUP | (addr>>12));
    microdelay(200);
  }
}
801034bc:	90                   	nop
801034bd:	c9                   	leave  
801034be:	c3                   	ret    

801034bf <cmos_read>:
#define DAY     0x07
#define MONTH   0x08
#define YEAR    0x09

static uint cmos_read(uint reg)
{
801034bf:	55                   	push   %ebp
801034c0:	89 e5                	mov    %esp,%ebp
  outb(CMOS_PORT,  reg);
801034c2:	8b 45 08             	mov    0x8(%ebp),%eax
801034c5:	0f b6 c0             	movzbl %al,%eax
801034c8:	50                   	push   %eax
801034c9:	6a 70                	push   $0x70
801034cb:	e8 25 fd ff ff       	call   801031f5 <outb>
801034d0:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
801034d3:	68 c8 00 00 00       	push   $0xc8
801034d8:	e8 fb fe ff ff       	call   801033d8 <microdelay>
801034dd:	83 c4 04             	add    $0x4,%esp

  return inb(CMOS_RETURN);
801034e0:	6a 71                	push   $0x71
801034e2:	e8 f1 fc ff ff       	call   801031d8 <inb>
801034e7:	83 c4 04             	add    $0x4,%esp
801034ea:	0f b6 c0             	movzbl %al,%eax
}
801034ed:	c9                   	leave  
801034ee:	c3                   	ret    

801034ef <fill_rtcdate>:

static void fill_rtcdate(struct rtcdate *r)
{
801034ef:	55                   	push   %ebp
801034f0:	89 e5                	mov    %esp,%ebp
  r->second = cmos_read(SECS);
801034f2:	6a 00                	push   $0x0
801034f4:	e8 c6 ff ff ff       	call   801034bf <cmos_read>
801034f9:	83 c4 04             	add    $0x4,%esp
801034fc:	89 c2                	mov    %eax,%edx
801034fe:	8b 45 08             	mov    0x8(%ebp),%eax
80103501:	89 10                	mov    %edx,(%eax)
  r->minute = cmos_read(MINS);
80103503:	6a 02                	push   $0x2
80103505:	e8 b5 ff ff ff       	call   801034bf <cmos_read>
8010350a:	83 c4 04             	add    $0x4,%esp
8010350d:	89 c2                	mov    %eax,%edx
8010350f:	8b 45 08             	mov    0x8(%ebp),%eax
80103512:	89 50 04             	mov    %edx,0x4(%eax)
  r->hour   = cmos_read(HOURS);
80103515:	6a 04                	push   $0x4
80103517:	e8 a3 ff ff ff       	call   801034bf <cmos_read>
8010351c:	83 c4 04             	add    $0x4,%esp
8010351f:	89 c2                	mov    %eax,%edx
80103521:	8b 45 08             	mov    0x8(%ebp),%eax
80103524:	89 50 08             	mov    %edx,0x8(%eax)
  r->day    = cmos_read(DAY);
80103527:	6a 07                	push   $0x7
80103529:	e8 91 ff ff ff       	call   801034bf <cmos_read>
8010352e:	83 c4 04             	add    $0x4,%esp
80103531:	89 c2                	mov    %eax,%edx
80103533:	8b 45 08             	mov    0x8(%ebp),%eax
80103536:	89 50 0c             	mov    %edx,0xc(%eax)
  r->month  = cmos_read(MONTH);
80103539:	6a 08                	push   $0x8
8010353b:	e8 7f ff ff ff       	call   801034bf <cmos_read>
80103540:	83 c4 04             	add    $0x4,%esp
80103543:	89 c2                	mov    %eax,%edx
80103545:	8b 45 08             	mov    0x8(%ebp),%eax
80103548:	89 50 10             	mov    %edx,0x10(%eax)
  r->year   = cmos_read(YEAR);
8010354b:	6a 09                	push   $0x9
8010354d:	e8 6d ff ff ff       	call   801034bf <cmos_read>
80103552:	83 c4 04             	add    $0x4,%esp
80103555:	89 c2                	mov    %eax,%edx
80103557:	8b 45 08             	mov    0x8(%ebp),%eax
8010355a:	89 50 14             	mov    %edx,0x14(%eax)
}
8010355d:	90                   	nop
8010355e:	c9                   	leave  
8010355f:	c3                   	ret    

80103560 <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
80103560:	55                   	push   %ebp
80103561:	89 e5                	mov    %esp,%ebp
80103563:	83 ec 48             	sub    $0x48,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
80103566:	6a 0b                	push   $0xb
80103568:	e8 52 ff ff ff       	call   801034bf <cmos_read>
8010356d:	83 c4 04             	add    $0x4,%esp
80103570:	89 45 f4             	mov    %eax,-0xc(%ebp)

  bcd = (sb & (1 << 2)) == 0;
80103573:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103576:	83 e0 04             	and    $0x4,%eax
80103579:	85 c0                	test   %eax,%eax
8010357b:	0f 94 c0             	sete   %al
8010357e:	0f b6 c0             	movzbl %al,%eax
80103581:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for (;;) {
    fill_rtcdate(&t1);
80103584:	8d 45 d8             	lea    -0x28(%ebp),%eax
80103587:	50                   	push   %eax
80103588:	e8 62 ff ff ff       	call   801034ef <fill_rtcdate>
8010358d:	83 c4 04             	add    $0x4,%esp
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
80103590:	6a 0a                	push   $0xa
80103592:	e8 28 ff ff ff       	call   801034bf <cmos_read>
80103597:	83 c4 04             	add    $0x4,%esp
8010359a:	25 80 00 00 00       	and    $0x80,%eax
8010359f:	85 c0                	test   %eax,%eax
801035a1:	75 27                	jne    801035ca <cmostime+0x6a>
        continue;
    fill_rtcdate(&t2);
801035a3:	8d 45 c0             	lea    -0x40(%ebp),%eax
801035a6:	50                   	push   %eax
801035a7:	e8 43 ff ff ff       	call   801034ef <fill_rtcdate>
801035ac:	83 c4 04             	add    $0x4,%esp
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
801035af:	83 ec 04             	sub    $0x4,%esp
801035b2:	6a 18                	push   $0x18
801035b4:	8d 45 c0             	lea    -0x40(%ebp),%eax
801035b7:	50                   	push   %eax
801035b8:	8d 45 d8             	lea    -0x28(%ebp),%eax
801035bb:	50                   	push   %eax
801035bc:	e8 c6 20 00 00       	call   80105687 <memcmp>
801035c1:	83 c4 10             	add    $0x10,%esp
801035c4:	85 c0                	test   %eax,%eax
801035c6:	74 05                	je     801035cd <cmostime+0x6d>
801035c8:	eb ba                	jmp    80103584 <cmostime+0x24>

  // make sure CMOS doesn't modify time while we read it
  for (;;) {
    fill_rtcdate(&t1);
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
        continue;
801035ca:	90                   	nop
    fill_rtcdate(&t2);
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
      break;
  }
801035cb:	eb b7                	jmp    80103584 <cmostime+0x24>
    fill_rtcdate(&t1);
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
        continue;
    fill_rtcdate(&t2);
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
      break;
801035cd:	90                   	nop
  }

  // convert
  if (bcd) {
801035ce:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801035d2:	0f 84 b4 00 00 00    	je     8010368c <cmostime+0x12c>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
801035d8:	8b 45 d8             	mov    -0x28(%ebp),%eax
801035db:	c1 e8 04             	shr    $0x4,%eax
801035de:	89 c2                	mov    %eax,%edx
801035e0:	89 d0                	mov    %edx,%eax
801035e2:	c1 e0 02             	shl    $0x2,%eax
801035e5:	01 d0                	add    %edx,%eax
801035e7:	01 c0                	add    %eax,%eax
801035e9:	89 c2                	mov    %eax,%edx
801035eb:	8b 45 d8             	mov    -0x28(%ebp),%eax
801035ee:	83 e0 0f             	and    $0xf,%eax
801035f1:	01 d0                	add    %edx,%eax
801035f3:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(minute);
801035f6:	8b 45 dc             	mov    -0x24(%ebp),%eax
801035f9:	c1 e8 04             	shr    $0x4,%eax
801035fc:	89 c2                	mov    %eax,%edx
801035fe:	89 d0                	mov    %edx,%eax
80103600:	c1 e0 02             	shl    $0x2,%eax
80103603:	01 d0                	add    %edx,%eax
80103605:	01 c0                	add    %eax,%eax
80103607:	89 c2                	mov    %eax,%edx
80103609:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010360c:	83 e0 0f             	and    $0xf,%eax
8010360f:	01 d0                	add    %edx,%eax
80103611:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(hour  );
80103614:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103617:	c1 e8 04             	shr    $0x4,%eax
8010361a:	89 c2                	mov    %eax,%edx
8010361c:	89 d0                	mov    %edx,%eax
8010361e:	c1 e0 02             	shl    $0x2,%eax
80103621:	01 d0                	add    %edx,%eax
80103623:	01 c0                	add    %eax,%eax
80103625:	89 c2                	mov    %eax,%edx
80103627:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010362a:	83 e0 0f             	and    $0xf,%eax
8010362d:	01 d0                	add    %edx,%eax
8010362f:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(day   );
80103632:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103635:	c1 e8 04             	shr    $0x4,%eax
80103638:	89 c2                	mov    %eax,%edx
8010363a:	89 d0                	mov    %edx,%eax
8010363c:	c1 e0 02             	shl    $0x2,%eax
8010363f:	01 d0                	add    %edx,%eax
80103641:	01 c0                	add    %eax,%eax
80103643:	89 c2                	mov    %eax,%edx
80103645:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103648:	83 e0 0f             	and    $0xf,%eax
8010364b:	01 d0                	add    %edx,%eax
8010364d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    CONV(month );
80103650:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103653:	c1 e8 04             	shr    $0x4,%eax
80103656:	89 c2                	mov    %eax,%edx
80103658:	89 d0                	mov    %edx,%eax
8010365a:	c1 e0 02             	shl    $0x2,%eax
8010365d:	01 d0                	add    %edx,%eax
8010365f:	01 c0                	add    %eax,%eax
80103661:	89 c2                	mov    %eax,%edx
80103663:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103666:	83 e0 0f             	and    $0xf,%eax
80103669:	01 d0                	add    %edx,%eax
8010366b:	89 45 e8             	mov    %eax,-0x18(%ebp)
    CONV(year  );
8010366e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103671:	c1 e8 04             	shr    $0x4,%eax
80103674:	89 c2                	mov    %eax,%edx
80103676:	89 d0                	mov    %edx,%eax
80103678:	c1 e0 02             	shl    $0x2,%eax
8010367b:	01 d0                	add    %edx,%eax
8010367d:	01 c0                	add    %eax,%eax
8010367f:	89 c2                	mov    %eax,%edx
80103681:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103684:	83 e0 0f             	and    $0xf,%eax
80103687:	01 d0                	add    %edx,%eax
80103689:	89 45 ec             	mov    %eax,-0x14(%ebp)
#undef     CONV
  }

  *r = t1;
8010368c:	8b 45 08             	mov    0x8(%ebp),%eax
8010368f:	8b 55 d8             	mov    -0x28(%ebp),%edx
80103692:	89 10                	mov    %edx,(%eax)
80103694:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103697:	89 50 04             	mov    %edx,0x4(%eax)
8010369a:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010369d:	89 50 08             	mov    %edx,0x8(%eax)
801036a0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801036a3:	89 50 0c             	mov    %edx,0xc(%eax)
801036a6:	8b 55 e8             	mov    -0x18(%ebp),%edx
801036a9:	89 50 10             	mov    %edx,0x10(%eax)
801036ac:	8b 55 ec             	mov    -0x14(%ebp),%edx
801036af:	89 50 14             	mov    %edx,0x14(%eax)
  r->year += 2000;
801036b2:	8b 45 08             	mov    0x8(%ebp),%eax
801036b5:	8b 40 14             	mov    0x14(%eax),%eax
801036b8:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
801036be:	8b 45 08             	mov    0x8(%ebp),%eax
801036c1:	89 50 14             	mov    %edx,0x14(%eax)
}
801036c4:	90                   	nop
801036c5:	c9                   	leave  
801036c6:	c3                   	ret    

801036c7 <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(int dev,int partitionNumber)
{
801036c7:	55                   	push   %ebp
801036c8:	89 e5                	mov    %esp,%ebp
801036ca:	83 ec 08             	sub    $0x8,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  initlock(&log.lock, "log");
801036cd:	83 ec 08             	sub    $0x8,%esp
801036d0:	68 84 8b 10 80       	push   $0x80108b84
801036d5:	68 40 25 11 80       	push   $0x80112540
801036da:	e8 bc 1c 00 00       	call   8010539b <initlock>
801036df:	83 c4 10             	add    $0x10,%esp
  readsb(dev, partitionNumber);
801036e2:	83 ec 08             	sub    $0x8,%esp
801036e5:	ff 75 0c             	pushl  0xc(%ebp)
801036e8:	ff 75 08             	pushl  0x8(%ebp)
801036eb:	e8 96 dc ff ff       	call   80101386 <readsb>
801036f0:	83 c4 10             	add    $0x10,%esp
  log.start = sbs[partitionNumber].offset+sbs[partitionNumber].logstart;
801036f3:	8b 45 0c             	mov    0xc(%ebp),%eax
801036f6:	c1 e0 05             	shl    $0x5,%eax
801036f9:	05 70 c6 10 80       	add    $0x8010c670,%eax
801036fe:	8b 50 0c             	mov    0xc(%eax),%edx
80103701:	8b 45 0c             	mov    0xc(%ebp),%eax
80103704:	c1 e0 05             	shl    $0x5,%eax
80103707:	05 70 c6 10 80       	add    $0x8010c670,%eax
8010370c:	8b 00                	mov    (%eax),%eax
8010370e:	01 d0                	add    %edx,%eax
80103710:	a3 74 25 11 80       	mov    %eax,0x80112574
  log.size =  sbs[partitionNumber].nlog;
80103715:	8b 45 0c             	mov    0xc(%ebp),%eax
80103718:	c1 e0 05             	shl    $0x5,%eax
8010371b:	05 60 c6 10 80       	add    $0x8010c660,%eax
80103720:	8b 40 0c             	mov    0xc(%eax),%eax
80103723:	a3 78 25 11 80       	mov    %eax,0x80112578
  log.dev = dev;
80103728:	8b 45 08             	mov    0x8(%ebp),%eax
8010372b:	a3 84 25 11 80       	mov    %eax,0x80112584
  recover_from_log();
80103730:	e8 b2 01 00 00       	call   801038e7 <recover_from_log>
}
80103735:	90                   	nop
80103736:	c9                   	leave  
80103737:	c3                   	ret    

80103738 <install_trans>:

// Copy committed blocks from log to their home location
static void 
install_trans(void)
{
80103738:	55                   	push   %ebp
80103739:	89 e5                	mov    %esp,%ebp
8010373b:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
8010373e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103745:	e9 95 00 00 00       	jmp    801037df <install_trans+0xa7>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
8010374a:	8b 15 74 25 11 80    	mov    0x80112574,%edx
80103750:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103753:	01 d0                	add    %edx,%eax
80103755:	83 c0 01             	add    $0x1,%eax
80103758:	89 c2                	mov    %eax,%edx
8010375a:	a1 84 25 11 80       	mov    0x80112584,%eax
8010375f:	83 ec 08             	sub    $0x8,%esp
80103762:	52                   	push   %edx
80103763:	50                   	push   %eax
80103764:	e8 4d ca ff ff       	call   801001b6 <bread>
80103769:	83 c4 10             	add    $0x10,%esp
8010376c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
8010376f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103772:	83 c0 10             	add    $0x10,%eax
80103775:	8b 04 85 4c 25 11 80 	mov    -0x7feedab4(,%eax,4),%eax
8010377c:	89 c2                	mov    %eax,%edx
8010377e:	a1 84 25 11 80       	mov    0x80112584,%eax
80103783:	83 ec 08             	sub    $0x8,%esp
80103786:	52                   	push   %edx
80103787:	50                   	push   %eax
80103788:	e8 29 ca ff ff       	call   801001b6 <bread>
8010378d:	83 c4 10             	add    $0x10,%esp
80103790:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
80103793:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103796:	8d 50 18             	lea    0x18(%eax),%edx
80103799:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010379c:	83 c0 18             	add    $0x18,%eax
8010379f:	83 ec 04             	sub    $0x4,%esp
801037a2:	68 00 02 00 00       	push   $0x200
801037a7:	52                   	push   %edx
801037a8:	50                   	push   %eax
801037a9:	e8 31 1f 00 00       	call   801056df <memmove>
801037ae:	83 c4 10             	add    $0x10,%esp
    bwrite(dbuf);  // write dst to disk
801037b1:	83 ec 0c             	sub    $0xc,%esp
801037b4:	ff 75 ec             	pushl  -0x14(%ebp)
801037b7:	e8 33 ca ff ff       	call   801001ef <bwrite>
801037bc:	83 c4 10             	add    $0x10,%esp
    brelse(lbuf); 
801037bf:	83 ec 0c             	sub    $0xc,%esp
801037c2:	ff 75 f0             	pushl  -0x10(%ebp)
801037c5:	e8 64 ca ff ff       	call   8010022e <brelse>
801037ca:	83 c4 10             	add    $0x10,%esp
    brelse(dbuf);
801037cd:	83 ec 0c             	sub    $0xc,%esp
801037d0:	ff 75 ec             	pushl  -0x14(%ebp)
801037d3:	e8 56 ca ff ff       	call   8010022e <brelse>
801037d8:	83 c4 10             	add    $0x10,%esp
static void 
install_trans(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801037db:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801037df:	a1 88 25 11 80       	mov    0x80112588,%eax
801037e4:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801037e7:	0f 8f 5d ff ff ff    	jg     8010374a <install_trans+0x12>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    bwrite(dbuf);  // write dst to disk
    brelse(lbuf); 
    brelse(dbuf);
  }
}
801037ed:	90                   	nop
801037ee:	c9                   	leave  
801037ef:	c3                   	ret    

801037f0 <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
801037f0:	55                   	push   %ebp
801037f1:	89 e5                	mov    %esp,%ebp
801037f3:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
801037f6:	a1 74 25 11 80       	mov    0x80112574,%eax
801037fb:	89 c2                	mov    %eax,%edx
801037fd:	a1 84 25 11 80       	mov    0x80112584,%eax
80103802:	83 ec 08             	sub    $0x8,%esp
80103805:	52                   	push   %edx
80103806:	50                   	push   %eax
80103807:	e8 aa c9 ff ff       	call   801001b6 <bread>
8010380c:	83 c4 10             	add    $0x10,%esp
8010380f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
80103812:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103815:	83 c0 18             	add    $0x18,%eax
80103818:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
8010381b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010381e:	8b 00                	mov    (%eax),%eax
80103820:	a3 88 25 11 80       	mov    %eax,0x80112588
  for (i = 0; i < log.lh.n; i++) {
80103825:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010382c:	eb 1b                	jmp    80103849 <read_head+0x59>
    log.lh.block[i] = lh->block[i];
8010382e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103831:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103834:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
80103838:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010383b:	83 c2 10             	add    $0x10,%edx
8010383e:	89 04 95 4c 25 11 80 	mov    %eax,-0x7feedab4(,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
  for (i = 0; i < log.lh.n; i++) {
80103845:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103849:	a1 88 25 11 80       	mov    0x80112588,%eax
8010384e:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103851:	7f db                	jg     8010382e <read_head+0x3e>
    log.lh.block[i] = lh->block[i];
  }
  brelse(buf);
80103853:	83 ec 0c             	sub    $0xc,%esp
80103856:	ff 75 f0             	pushl  -0x10(%ebp)
80103859:	e8 d0 c9 ff ff       	call   8010022e <brelse>
8010385e:	83 c4 10             	add    $0x10,%esp
}
80103861:	90                   	nop
80103862:	c9                   	leave  
80103863:	c3                   	ret    

80103864 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
80103864:	55                   	push   %ebp
80103865:	89 e5                	mov    %esp,%ebp
80103867:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
8010386a:	a1 74 25 11 80       	mov    0x80112574,%eax
8010386f:	89 c2                	mov    %eax,%edx
80103871:	a1 84 25 11 80       	mov    0x80112584,%eax
80103876:	83 ec 08             	sub    $0x8,%esp
80103879:	52                   	push   %edx
8010387a:	50                   	push   %eax
8010387b:	e8 36 c9 ff ff       	call   801001b6 <bread>
80103880:	83 c4 10             	add    $0x10,%esp
80103883:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
80103886:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103889:	83 c0 18             	add    $0x18,%eax
8010388c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
8010388f:	8b 15 88 25 11 80    	mov    0x80112588,%edx
80103895:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103898:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
8010389a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801038a1:	eb 1b                	jmp    801038be <write_head+0x5a>
    hb->block[i] = log.lh.block[i];
801038a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801038a6:	83 c0 10             	add    $0x10,%eax
801038a9:	8b 0c 85 4c 25 11 80 	mov    -0x7feedab4(,%eax,4),%ecx
801038b0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801038b3:	8b 55 f4             	mov    -0xc(%ebp),%edx
801038b6:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
  for (i = 0; i < log.lh.n; i++) {
801038ba:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801038be:	a1 88 25 11 80       	mov    0x80112588,%eax
801038c3:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801038c6:	7f db                	jg     801038a3 <write_head+0x3f>
    hb->block[i] = log.lh.block[i];
  }
  bwrite(buf);
801038c8:	83 ec 0c             	sub    $0xc,%esp
801038cb:	ff 75 f0             	pushl  -0x10(%ebp)
801038ce:	e8 1c c9 ff ff       	call   801001ef <bwrite>
801038d3:	83 c4 10             	add    $0x10,%esp
  brelse(buf);
801038d6:	83 ec 0c             	sub    $0xc,%esp
801038d9:	ff 75 f0             	pushl  -0x10(%ebp)
801038dc:	e8 4d c9 ff ff       	call   8010022e <brelse>
801038e1:	83 c4 10             	add    $0x10,%esp
}
801038e4:	90                   	nop
801038e5:	c9                   	leave  
801038e6:	c3                   	ret    

801038e7 <recover_from_log>:

static void
recover_from_log(void)
{
801038e7:	55                   	push   %ebp
801038e8:	89 e5                	mov    %esp,%ebp
801038ea:	83 ec 08             	sub    $0x8,%esp
  read_head();      
801038ed:	e8 fe fe ff ff       	call   801037f0 <read_head>
  install_trans(); // if committed, copy from log to disk
801038f2:	e8 41 fe ff ff       	call   80103738 <install_trans>
  log.lh.n = 0;
801038f7:	c7 05 88 25 11 80 00 	movl   $0x0,0x80112588
801038fe:	00 00 00 
  write_head(); // clear the log
80103901:	e8 5e ff ff ff       	call   80103864 <write_head>
}
80103906:	90                   	nop
80103907:	c9                   	leave  
80103908:	c3                   	ret    

80103909 <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
80103909:	55                   	push   %ebp
8010390a:	89 e5                	mov    %esp,%ebp
8010390c:	83 ec 08             	sub    $0x8,%esp
  acquire(&log.lock);
8010390f:	83 ec 0c             	sub    $0xc,%esp
80103912:	68 40 25 11 80       	push   $0x80112540
80103917:	e8 a1 1a 00 00       	call   801053bd <acquire>
8010391c:	83 c4 10             	add    $0x10,%esp
  while(1){
    if(log.committing){
8010391f:	a1 80 25 11 80       	mov    0x80112580,%eax
80103924:	85 c0                	test   %eax,%eax
80103926:	74 17                	je     8010393f <begin_op+0x36>
      sleep(&log, &log.lock);
80103928:	83 ec 08             	sub    $0x8,%esp
8010392b:	68 40 25 11 80       	push   $0x80112540
80103930:	68 40 25 11 80       	push   $0x80112540
80103935:	e8 8a 17 00 00       	call   801050c4 <sleep>
8010393a:	83 c4 10             	add    $0x10,%esp
8010393d:	eb e0                	jmp    8010391f <begin_op+0x16>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
8010393f:	8b 0d 88 25 11 80    	mov    0x80112588,%ecx
80103945:	a1 7c 25 11 80       	mov    0x8011257c,%eax
8010394a:	8d 50 01             	lea    0x1(%eax),%edx
8010394d:	89 d0                	mov    %edx,%eax
8010394f:	c1 e0 02             	shl    $0x2,%eax
80103952:	01 d0                	add    %edx,%eax
80103954:	01 c0                	add    %eax,%eax
80103956:	01 c8                	add    %ecx,%eax
80103958:	83 f8 1e             	cmp    $0x1e,%eax
8010395b:	7e 17                	jle    80103974 <begin_op+0x6b>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
8010395d:	83 ec 08             	sub    $0x8,%esp
80103960:	68 40 25 11 80       	push   $0x80112540
80103965:	68 40 25 11 80       	push   $0x80112540
8010396a:	e8 55 17 00 00       	call   801050c4 <sleep>
8010396f:	83 c4 10             	add    $0x10,%esp
80103972:	eb ab                	jmp    8010391f <begin_op+0x16>
    } else {
      log.outstanding += 1;
80103974:	a1 7c 25 11 80       	mov    0x8011257c,%eax
80103979:	83 c0 01             	add    $0x1,%eax
8010397c:	a3 7c 25 11 80       	mov    %eax,0x8011257c
      release(&log.lock);
80103981:	83 ec 0c             	sub    $0xc,%esp
80103984:	68 40 25 11 80       	push   $0x80112540
80103989:	e8 96 1a 00 00       	call   80105424 <release>
8010398e:	83 c4 10             	add    $0x10,%esp
      break;
80103991:	90                   	nop
    }
  }
}
80103992:	90                   	nop
80103993:	c9                   	leave  
80103994:	c3                   	ret    

80103995 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
80103995:	55                   	push   %ebp
80103996:	89 e5                	mov    %esp,%ebp
80103998:	83 ec 18             	sub    $0x18,%esp
  int do_commit = 0;
8010399b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
801039a2:	83 ec 0c             	sub    $0xc,%esp
801039a5:	68 40 25 11 80       	push   $0x80112540
801039aa:	e8 0e 1a 00 00       	call   801053bd <acquire>
801039af:	83 c4 10             	add    $0x10,%esp
  log.outstanding -= 1;
801039b2:	a1 7c 25 11 80       	mov    0x8011257c,%eax
801039b7:	83 e8 01             	sub    $0x1,%eax
801039ba:	a3 7c 25 11 80       	mov    %eax,0x8011257c
  if(log.committing)
801039bf:	a1 80 25 11 80       	mov    0x80112580,%eax
801039c4:	85 c0                	test   %eax,%eax
801039c6:	74 0d                	je     801039d5 <end_op+0x40>
    panic("log.committing");
801039c8:	83 ec 0c             	sub    $0xc,%esp
801039cb:	68 88 8b 10 80       	push   $0x80108b88
801039d0:	e8 91 cb ff ff       	call   80100566 <panic>
  if(log.outstanding == 0){
801039d5:	a1 7c 25 11 80       	mov    0x8011257c,%eax
801039da:	85 c0                	test   %eax,%eax
801039dc:	75 13                	jne    801039f1 <end_op+0x5c>
    do_commit = 1;
801039de:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
801039e5:	c7 05 80 25 11 80 01 	movl   $0x1,0x80112580
801039ec:	00 00 00 
801039ef:	eb 10                	jmp    80103a01 <end_op+0x6c>
  } else {
    // begin_op() may be waiting for log space.
    wakeup(&log);
801039f1:	83 ec 0c             	sub    $0xc,%esp
801039f4:	68 40 25 11 80       	push   $0x80112540
801039f9:	e8 b1 17 00 00       	call   801051af <wakeup>
801039fe:	83 c4 10             	add    $0x10,%esp
  }
  release(&log.lock);
80103a01:	83 ec 0c             	sub    $0xc,%esp
80103a04:	68 40 25 11 80       	push   $0x80112540
80103a09:	e8 16 1a 00 00       	call   80105424 <release>
80103a0e:	83 c4 10             	add    $0x10,%esp

  if(do_commit){
80103a11:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103a15:	74 3f                	je     80103a56 <end_op+0xc1>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
80103a17:	e8 f5 00 00 00       	call   80103b11 <commit>
    acquire(&log.lock);
80103a1c:	83 ec 0c             	sub    $0xc,%esp
80103a1f:	68 40 25 11 80       	push   $0x80112540
80103a24:	e8 94 19 00 00       	call   801053bd <acquire>
80103a29:	83 c4 10             	add    $0x10,%esp
    log.committing = 0;
80103a2c:	c7 05 80 25 11 80 00 	movl   $0x0,0x80112580
80103a33:	00 00 00 
    wakeup(&log);
80103a36:	83 ec 0c             	sub    $0xc,%esp
80103a39:	68 40 25 11 80       	push   $0x80112540
80103a3e:	e8 6c 17 00 00       	call   801051af <wakeup>
80103a43:	83 c4 10             	add    $0x10,%esp
    release(&log.lock);
80103a46:	83 ec 0c             	sub    $0xc,%esp
80103a49:	68 40 25 11 80       	push   $0x80112540
80103a4e:	e8 d1 19 00 00       	call   80105424 <release>
80103a53:	83 c4 10             	add    $0x10,%esp
  }
}
80103a56:	90                   	nop
80103a57:	c9                   	leave  
80103a58:	c3                   	ret    

80103a59 <write_log>:

// Copy modified blocks from cache to log.
static void 
write_log(void)
{
80103a59:	55                   	push   %ebp
80103a5a:	89 e5                	mov    %esp,%ebp
80103a5c:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103a5f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103a66:	e9 95 00 00 00       	jmp    80103b00 <write_log+0xa7>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
80103a6b:	8b 15 74 25 11 80    	mov    0x80112574,%edx
80103a71:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a74:	01 d0                	add    %edx,%eax
80103a76:	83 c0 01             	add    $0x1,%eax
80103a79:	89 c2                	mov    %eax,%edx
80103a7b:	a1 84 25 11 80       	mov    0x80112584,%eax
80103a80:	83 ec 08             	sub    $0x8,%esp
80103a83:	52                   	push   %edx
80103a84:	50                   	push   %eax
80103a85:	e8 2c c7 ff ff       	call   801001b6 <bread>
80103a8a:	83 c4 10             	add    $0x10,%esp
80103a8d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
80103a90:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a93:	83 c0 10             	add    $0x10,%eax
80103a96:	8b 04 85 4c 25 11 80 	mov    -0x7feedab4(,%eax,4),%eax
80103a9d:	89 c2                	mov    %eax,%edx
80103a9f:	a1 84 25 11 80       	mov    0x80112584,%eax
80103aa4:	83 ec 08             	sub    $0x8,%esp
80103aa7:	52                   	push   %edx
80103aa8:	50                   	push   %eax
80103aa9:	e8 08 c7 ff ff       	call   801001b6 <bread>
80103aae:	83 c4 10             	add    $0x10,%esp
80103ab1:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
80103ab4:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103ab7:	8d 50 18             	lea    0x18(%eax),%edx
80103aba:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103abd:	83 c0 18             	add    $0x18,%eax
80103ac0:	83 ec 04             	sub    $0x4,%esp
80103ac3:	68 00 02 00 00       	push   $0x200
80103ac8:	52                   	push   %edx
80103ac9:	50                   	push   %eax
80103aca:	e8 10 1c 00 00       	call   801056df <memmove>
80103acf:	83 c4 10             	add    $0x10,%esp
    bwrite(to);  // write the log
80103ad2:	83 ec 0c             	sub    $0xc,%esp
80103ad5:	ff 75 f0             	pushl  -0x10(%ebp)
80103ad8:	e8 12 c7 ff ff       	call   801001ef <bwrite>
80103add:	83 c4 10             	add    $0x10,%esp
    brelse(from); 
80103ae0:	83 ec 0c             	sub    $0xc,%esp
80103ae3:	ff 75 ec             	pushl  -0x14(%ebp)
80103ae6:	e8 43 c7 ff ff       	call   8010022e <brelse>
80103aeb:	83 c4 10             	add    $0x10,%esp
    brelse(to);
80103aee:	83 ec 0c             	sub    $0xc,%esp
80103af1:	ff 75 f0             	pushl  -0x10(%ebp)
80103af4:	e8 35 c7 ff ff       	call   8010022e <brelse>
80103af9:	83 c4 10             	add    $0x10,%esp
static void 
write_log(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103afc:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103b00:	a1 88 25 11 80       	mov    0x80112588,%eax
80103b05:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103b08:	0f 8f 5d ff ff ff    	jg     80103a6b <write_log+0x12>
    memmove(to->data, from->data, BSIZE);
    bwrite(to);  // write the log
    brelse(from); 
    brelse(to);
  }
}
80103b0e:	90                   	nop
80103b0f:	c9                   	leave  
80103b10:	c3                   	ret    

80103b11 <commit>:

static void
commit()
{
80103b11:	55                   	push   %ebp
80103b12:	89 e5                	mov    %esp,%ebp
80103b14:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
80103b17:	a1 88 25 11 80       	mov    0x80112588,%eax
80103b1c:	85 c0                	test   %eax,%eax
80103b1e:	7e 1e                	jle    80103b3e <commit+0x2d>
    write_log();     // Write modified blocks from cache to log
80103b20:	e8 34 ff ff ff       	call   80103a59 <write_log>
    write_head();    // Write header to disk -- the real commit
80103b25:	e8 3a fd ff ff       	call   80103864 <write_head>
    install_trans(); // Now install writes to home locations
80103b2a:	e8 09 fc ff ff       	call   80103738 <install_trans>
    log.lh.n = 0; 
80103b2f:	c7 05 88 25 11 80 00 	movl   $0x0,0x80112588
80103b36:	00 00 00 
    write_head();    // Erase the transaction from the log
80103b39:	e8 26 fd ff ff       	call   80103864 <write_head>
  }
}
80103b3e:	90                   	nop
80103b3f:	c9                   	leave  
80103b40:	c3                   	ret    

80103b41 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
80103b41:	55                   	push   %ebp
80103b42:	89 e5                	mov    %esp,%ebp
80103b44:	83 ec 18             	sub    $0x18,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
80103b47:	a1 88 25 11 80       	mov    0x80112588,%eax
80103b4c:	83 f8 1d             	cmp    $0x1d,%eax
80103b4f:	7f 12                	jg     80103b63 <log_write+0x22>
80103b51:	a1 88 25 11 80       	mov    0x80112588,%eax
80103b56:	8b 15 78 25 11 80    	mov    0x80112578,%edx
80103b5c:	83 ea 01             	sub    $0x1,%edx
80103b5f:	39 d0                	cmp    %edx,%eax
80103b61:	7c 0d                	jl     80103b70 <log_write+0x2f>
    panic("too big a transaction");
80103b63:	83 ec 0c             	sub    $0xc,%esp
80103b66:	68 97 8b 10 80       	push   $0x80108b97
80103b6b:	e8 f6 c9 ff ff       	call   80100566 <panic>
  if (log.outstanding < 1)
80103b70:	a1 7c 25 11 80       	mov    0x8011257c,%eax
80103b75:	85 c0                	test   %eax,%eax
80103b77:	7f 0d                	jg     80103b86 <log_write+0x45>
    panic("log_write outside of trans");
80103b79:	83 ec 0c             	sub    $0xc,%esp
80103b7c:	68 ad 8b 10 80       	push   $0x80108bad
80103b81:	e8 e0 c9 ff ff       	call   80100566 <panic>

  acquire(&log.lock);
80103b86:	83 ec 0c             	sub    $0xc,%esp
80103b89:	68 40 25 11 80       	push   $0x80112540
80103b8e:	e8 2a 18 00 00       	call   801053bd <acquire>
80103b93:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < log.lh.n; i++) {
80103b96:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103b9d:	eb 1d                	jmp    80103bbc <log_write+0x7b>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
80103b9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ba2:	83 c0 10             	add    $0x10,%eax
80103ba5:	8b 04 85 4c 25 11 80 	mov    -0x7feedab4(,%eax,4),%eax
80103bac:	89 c2                	mov    %eax,%edx
80103bae:	8b 45 08             	mov    0x8(%ebp),%eax
80103bb1:	8b 40 08             	mov    0x8(%eax),%eax
80103bb4:	39 c2                	cmp    %eax,%edx
80103bb6:	74 10                	je     80103bc8 <log_write+0x87>
    panic("too big a transaction");
  if (log.outstanding < 1)
    panic("log_write outside of trans");

  acquire(&log.lock);
  for (i = 0; i < log.lh.n; i++) {
80103bb8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103bbc:	a1 88 25 11 80       	mov    0x80112588,%eax
80103bc1:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103bc4:	7f d9                	jg     80103b9f <log_write+0x5e>
80103bc6:	eb 01                	jmp    80103bc9 <log_write+0x88>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
      break;
80103bc8:	90                   	nop
  }
  log.lh.block[i] = b->blockno;
80103bc9:	8b 45 08             	mov    0x8(%ebp),%eax
80103bcc:	8b 40 08             	mov    0x8(%eax),%eax
80103bcf:	89 c2                	mov    %eax,%edx
80103bd1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bd4:	83 c0 10             	add    $0x10,%eax
80103bd7:	89 14 85 4c 25 11 80 	mov    %edx,-0x7feedab4(,%eax,4)
  if (i == log.lh.n)
80103bde:	a1 88 25 11 80       	mov    0x80112588,%eax
80103be3:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103be6:	75 0d                	jne    80103bf5 <log_write+0xb4>
    log.lh.n++;
80103be8:	a1 88 25 11 80       	mov    0x80112588,%eax
80103bed:	83 c0 01             	add    $0x1,%eax
80103bf0:	a3 88 25 11 80       	mov    %eax,0x80112588
  b->flags |= B_DIRTY; // prevent eviction
80103bf5:	8b 45 08             	mov    0x8(%ebp),%eax
80103bf8:	8b 00                	mov    (%eax),%eax
80103bfa:	83 c8 04             	or     $0x4,%eax
80103bfd:	89 c2                	mov    %eax,%edx
80103bff:	8b 45 08             	mov    0x8(%ebp),%eax
80103c02:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
80103c04:	83 ec 0c             	sub    $0xc,%esp
80103c07:	68 40 25 11 80       	push   $0x80112540
80103c0c:	e8 13 18 00 00       	call   80105424 <release>
80103c11:	83 c4 10             	add    $0x10,%esp
}
80103c14:	90                   	nop
80103c15:	c9                   	leave  
80103c16:	c3                   	ret    

80103c17 <v2p>:
80103c17:	55                   	push   %ebp
80103c18:	89 e5                	mov    %esp,%ebp
80103c1a:	8b 45 08             	mov    0x8(%ebp),%eax
80103c1d:	05 00 00 00 80       	add    $0x80000000,%eax
80103c22:	5d                   	pop    %ebp
80103c23:	c3                   	ret    

80103c24 <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
80103c24:	55                   	push   %ebp
80103c25:	89 e5                	mov    %esp,%ebp
80103c27:	8b 45 08             	mov    0x8(%ebp),%eax
80103c2a:	05 00 00 00 80       	add    $0x80000000,%eax
80103c2f:	5d                   	pop    %ebp
80103c30:	c3                   	ret    

80103c31 <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
80103c31:	55                   	push   %ebp
80103c32:	89 e5                	mov    %esp,%ebp
80103c34:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80103c37:	8b 55 08             	mov    0x8(%ebp),%edx
80103c3a:	8b 45 0c             	mov    0xc(%ebp),%eax
80103c3d:	8b 4d 08             	mov    0x8(%ebp),%ecx
80103c40:	f0 87 02             	lock xchg %eax,(%edx)
80103c43:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80103c46:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103c49:	c9                   	leave  
80103c4a:	c3                   	ret    

80103c4b <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
80103c4b:	8d 4c 24 04          	lea    0x4(%esp),%ecx
80103c4f:	83 e4 f0             	and    $0xfffffff0,%esp
80103c52:	ff 71 fc             	pushl  -0x4(%ecx)
80103c55:	55                   	push   %ebp
80103c56:	89 e5                	mov    %esp,%ebp
80103c58:	51                   	push   %ecx
80103c59:	83 ec 04             	sub    $0x4,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
80103c5c:	83 ec 08             	sub    $0x8,%esp
80103c5f:	68 00 00 40 80       	push   $0x80400000
80103c64:	68 1c 54 11 80       	push   $0x8011541c
80103c69:	e8 59 f2 ff ff       	call   80102ec7 <kinit1>
80103c6e:	83 c4 10             	add    $0x10,%esp
  kvmalloc();      // kernel page table
80103c71:	e8 07 45 00 00       	call   8010817d <kvmalloc>
  mpinit();        // collect info about this machine
80103c76:	e8 43 04 00 00       	call   801040be <mpinit>
  lapicinit();
80103c7b:	e8 c6 f5 ff ff       	call   80103246 <lapicinit>
  seginit();       // set up segments
80103c80:	e8 a1 3e 00 00       	call   80107b26 <seginit>
  cprintf("\ncpu%d: starting xv6\n\n", cpu->id);
80103c85:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80103c8b:	0f b6 00             	movzbl (%eax),%eax
80103c8e:	0f b6 c0             	movzbl %al,%eax
80103c91:	83 ec 08             	sub    $0x8,%esp
80103c94:	50                   	push   %eax
80103c95:	68 c8 8b 10 80       	push   $0x80108bc8
80103c9a:	e8 27 c7 ff ff       	call   801003c6 <cprintf>
80103c9f:	83 c4 10             	add    $0x10,%esp
  picinit();       // interrupt controller
80103ca2:	e8 6d 06 00 00       	call   80104314 <picinit>
  ioapicinit();    // another interrupt controller
80103ca7:	e8 10 f1 ff ff       	call   80102dbc <ioapicinit>
  consoleinit();   // I/O devices & their interrupts
80103cac:	e8 68 ce ff ff       	call   80100b19 <consoleinit>
  uartinit();      // serial port
80103cb1:	e8 cc 31 00 00       	call   80106e82 <uartinit>
  pinit();         // process table
80103cb6:	e8 56 0b 00 00       	call   80104811 <pinit>
  tvinit();        // trap vectors
80103cbb:	e8 8c 2d 00 00       	call   80106a4c <tvinit>
  binit();         // buffer cache
80103cc0:	e8 6f c3 ff ff       	call   80100034 <binit>
  fileinit();      // file table
80103cc5:	e8 ab d2 ff ff       	call   80100f75 <fileinit>
  ideinit();       // disk
80103cca:	e8 f5 ec ff ff       	call   801029c4 <ideinit>
  if(!ismp)
80103ccf:	a1 24 26 11 80       	mov    0x80112624,%eax
80103cd4:	85 c0                	test   %eax,%eax
80103cd6:	75 05                	jne    80103cdd <main+0x92>
    timerinit();   // uniprocessor timer
80103cd8:	e8 cc 2c 00 00       	call   801069a9 <timerinit>
  startothers();   // start other processors
80103cdd:	e8 7f 00 00 00       	call   80103d61 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80103ce2:	83 ec 08             	sub    $0x8,%esp
80103ce5:	68 00 00 00 8e       	push   $0x8e000000
80103cea:	68 00 00 40 80       	push   $0x80400000
80103cef:	e8 0c f2 ff ff       	call   80102f00 <kinit2>
80103cf4:	83 c4 10             	add    $0x10,%esp
  userinit();      // first user process
80103cf7:	e8 39 0c 00 00       	call   80104935 <userinit>
  // Finish setting up this processor in mpmain.
  mpmain();
80103cfc:	e8 1a 00 00 00       	call   80103d1b <mpmain>

80103d01 <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
80103d01:	55                   	push   %ebp
80103d02:	89 e5                	mov    %esp,%ebp
80103d04:	83 ec 08             	sub    $0x8,%esp
  switchkvm(); 
80103d07:	e8 89 44 00 00       	call   80108195 <switchkvm>
  seginit();
80103d0c:	e8 15 3e 00 00       	call   80107b26 <seginit>
  lapicinit();
80103d11:	e8 30 f5 ff ff       	call   80103246 <lapicinit>
  mpmain();
80103d16:	e8 00 00 00 00       	call   80103d1b <mpmain>

80103d1b <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
80103d1b:	55                   	push   %ebp
80103d1c:	89 e5                	mov    %esp,%ebp
80103d1e:	83 ec 08             	sub    $0x8,%esp
  cprintf("cpu%d: starting\n", cpu->id);
80103d21:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80103d27:	0f b6 00             	movzbl (%eax),%eax
80103d2a:	0f b6 c0             	movzbl %al,%eax
80103d2d:	83 ec 08             	sub    $0x8,%esp
80103d30:	50                   	push   %eax
80103d31:	68 df 8b 10 80       	push   $0x80108bdf
80103d36:	e8 8b c6 ff ff       	call   801003c6 <cprintf>
80103d3b:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
80103d3e:	e8 7f 2e 00 00       	call   80106bc2 <idtinit>
  xchg(&cpu->started, 1); // tell startothers() we're up
80103d43:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80103d49:	05 a8 00 00 00       	add    $0xa8,%eax
80103d4e:	83 ec 08             	sub    $0x8,%esp
80103d51:	6a 01                	push   $0x1
80103d53:	50                   	push   %eax
80103d54:	e8 d8 fe ff ff       	call   80103c31 <xchg>
80103d59:	83 c4 10             	add    $0x10,%esp
  scheduler();     // start running processes
80103d5c:	e8 7f 11 00 00       	call   80104ee0 <scheduler>

80103d61 <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
80103d61:	55                   	push   %ebp
80103d62:	89 e5                	mov    %esp,%ebp
80103d64:	53                   	push   %ebx
80103d65:	83 ec 14             	sub    $0x14,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
80103d68:	68 00 70 00 00       	push   $0x7000
80103d6d:	e8 b2 fe ff ff       	call   80103c24 <p2v>
80103d72:	83 c4 04             	add    $0x4,%esp
80103d75:	89 45 f0             	mov    %eax,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
80103d78:	b8 8a 00 00 00       	mov    $0x8a,%eax
80103d7d:	83 ec 04             	sub    $0x4,%esp
80103d80:	50                   	push   %eax
80103d81:	68 0c b5 10 80       	push   $0x8010b50c
80103d86:	ff 75 f0             	pushl  -0x10(%ebp)
80103d89:	e8 51 19 00 00       	call   801056df <memmove>
80103d8e:	83 c4 10             	add    $0x10,%esp

  for(c = cpus; c < cpus+ncpu; c++){
80103d91:	c7 45 f4 40 26 11 80 	movl   $0x80112640,-0xc(%ebp)
80103d98:	e9 90 00 00 00       	jmp    80103e2d <startothers+0xcc>
    if(c == cpus+cpunum())  // We've started already.
80103d9d:	e8 c2 f5 ff ff       	call   80103364 <cpunum>
80103da2:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103da8:	05 40 26 11 80       	add    $0x80112640,%eax
80103dad:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103db0:	74 73                	je     80103e25 <startothers+0xc4>
      continue;

    // Tell entryother.S what stack to use, where to enter, and what 
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
80103db2:	e8 47 f2 ff ff       	call   80102ffe <kalloc>
80103db7:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
80103dba:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103dbd:	83 e8 04             	sub    $0x4,%eax
80103dc0:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103dc3:	81 c2 00 10 00 00    	add    $0x1000,%edx
80103dc9:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
80103dcb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103dce:	83 e8 08             	sub    $0x8,%eax
80103dd1:	c7 00 01 3d 10 80    	movl   $0x80103d01,(%eax)
    *(int**)(code-12) = (void *) v2p(entrypgdir);
80103dd7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103dda:	8d 58 f4             	lea    -0xc(%eax),%ebx
80103ddd:	83 ec 0c             	sub    $0xc,%esp
80103de0:	68 00 a0 10 80       	push   $0x8010a000
80103de5:	e8 2d fe ff ff       	call   80103c17 <v2p>
80103dea:	83 c4 10             	add    $0x10,%esp
80103ded:	89 03                	mov    %eax,(%ebx)

    lapicstartap(c->id, v2p(code));
80103def:	83 ec 0c             	sub    $0xc,%esp
80103df2:	ff 75 f0             	pushl  -0x10(%ebp)
80103df5:	e8 1d fe ff ff       	call   80103c17 <v2p>
80103dfa:	83 c4 10             	add    $0x10,%esp
80103dfd:	89 c2                	mov    %eax,%edx
80103dff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e02:	0f b6 00             	movzbl (%eax),%eax
80103e05:	0f b6 c0             	movzbl %al,%eax
80103e08:	83 ec 08             	sub    $0x8,%esp
80103e0b:	52                   	push   %edx
80103e0c:	50                   	push   %eax
80103e0d:	e8 cc f5 ff ff       	call   801033de <lapicstartap>
80103e12:	83 c4 10             	add    $0x10,%esp

    // wait for cpu to finish mpmain()
    while(c->started == 0)
80103e15:	90                   	nop
80103e16:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e19:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80103e1f:	85 c0                	test   %eax,%eax
80103e21:	74 f3                	je     80103e16 <startothers+0xb5>
80103e23:	eb 01                	jmp    80103e26 <startothers+0xc5>
  code = p2v(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
    if(c == cpus+cpunum())  // We've started already.
      continue;
80103e25:	90                   	nop
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
80103e26:	81 45 f4 bc 00 00 00 	addl   $0xbc,-0xc(%ebp)
80103e2d:	a1 20 2c 11 80       	mov    0x80112c20,%eax
80103e32:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103e38:	05 40 26 11 80       	add    $0x80112640,%eax
80103e3d:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103e40:	0f 87 57 ff ff ff    	ja     80103d9d <startothers+0x3c>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
      ;
  }
}
80103e46:	90                   	nop
80103e47:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103e4a:	c9                   	leave  
80103e4b:	c3                   	ret    

80103e4c <p2v>:
80103e4c:	55                   	push   %ebp
80103e4d:	89 e5                	mov    %esp,%ebp
80103e4f:	8b 45 08             	mov    0x8(%ebp),%eax
80103e52:	05 00 00 00 80       	add    $0x80000000,%eax
80103e57:	5d                   	pop    %ebp
80103e58:	c3                   	ret    

80103e59 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80103e59:	55                   	push   %ebp
80103e5a:	89 e5                	mov    %esp,%ebp
80103e5c:	83 ec 14             	sub    $0x14,%esp
80103e5f:	8b 45 08             	mov    0x8(%ebp),%eax
80103e62:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80103e66:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80103e6a:	89 c2                	mov    %eax,%edx
80103e6c:	ec                   	in     (%dx),%al
80103e6d:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80103e70:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80103e74:	c9                   	leave  
80103e75:	c3                   	ret    

80103e76 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103e76:	55                   	push   %ebp
80103e77:	89 e5                	mov    %esp,%ebp
80103e79:	83 ec 08             	sub    $0x8,%esp
80103e7c:	8b 55 08             	mov    0x8(%ebp),%edx
80103e7f:	8b 45 0c             	mov    0xc(%ebp),%eax
80103e82:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103e86:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103e89:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103e8d:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103e91:	ee                   	out    %al,(%dx)
}
80103e92:	90                   	nop
80103e93:	c9                   	leave  
80103e94:	c3                   	ret    

80103e95 <mpbcpu>:
int ncpu;
uchar ioapicid;

int
mpbcpu(void)
{
80103e95:	55                   	push   %ebp
80103e96:	89 e5                	mov    %esp,%ebp
  return bcpu-cpus;
80103e98:	a1 44 b6 10 80       	mov    0x8010b644,%eax
80103e9d:	89 c2                	mov    %eax,%edx
80103e9f:	b8 40 26 11 80       	mov    $0x80112640,%eax
80103ea4:	29 c2                	sub    %eax,%edx
80103ea6:	89 d0                	mov    %edx,%eax
80103ea8:	c1 f8 02             	sar    $0x2,%eax
80103eab:	69 c0 cf 46 7d 67    	imul   $0x677d46cf,%eax,%eax
}
80103eb1:	5d                   	pop    %ebp
80103eb2:	c3                   	ret    

80103eb3 <sum>:

static uchar
sum(uchar *addr, int len)
{
80103eb3:	55                   	push   %ebp
80103eb4:	89 e5                	mov    %esp,%ebp
80103eb6:	83 ec 10             	sub    $0x10,%esp
  int i, sum;
  
  sum = 0;
80103eb9:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(i=0; i<len; i++)
80103ec0:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80103ec7:	eb 15                	jmp    80103ede <sum+0x2b>
    sum += addr[i];
80103ec9:	8b 55 fc             	mov    -0x4(%ebp),%edx
80103ecc:	8b 45 08             	mov    0x8(%ebp),%eax
80103ecf:	01 d0                	add    %edx,%eax
80103ed1:	0f b6 00             	movzbl (%eax),%eax
80103ed4:	0f b6 c0             	movzbl %al,%eax
80103ed7:	01 45 f8             	add    %eax,-0x8(%ebp)
sum(uchar *addr, int len)
{
  int i, sum;
  
  sum = 0;
  for(i=0; i<len; i++)
80103eda:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80103ede:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103ee1:	3b 45 0c             	cmp    0xc(%ebp),%eax
80103ee4:	7c e3                	jl     80103ec9 <sum+0x16>
    sum += addr[i];
  return sum;
80103ee6:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80103ee9:	c9                   	leave  
80103eea:	c3                   	ret    

80103eeb <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80103eeb:	55                   	push   %ebp
80103eec:	89 e5                	mov    %esp,%ebp
80103eee:	83 ec 18             	sub    $0x18,%esp
  uchar *e, *p, *addr;

  addr = p2v(a);
80103ef1:	ff 75 08             	pushl  0x8(%ebp)
80103ef4:	e8 53 ff ff ff       	call   80103e4c <p2v>
80103ef9:	83 c4 04             	add    $0x4,%esp
80103efc:	89 45 f0             	mov    %eax,-0x10(%ebp)
  e = addr+len;
80103eff:	8b 55 0c             	mov    0xc(%ebp),%edx
80103f02:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103f05:	01 d0                	add    %edx,%eax
80103f07:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(p = addr; p < e; p += sizeof(struct mp))
80103f0a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103f0d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103f10:	eb 36                	jmp    80103f48 <mpsearch1+0x5d>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80103f12:	83 ec 04             	sub    $0x4,%esp
80103f15:	6a 04                	push   $0x4
80103f17:	68 f0 8b 10 80       	push   $0x80108bf0
80103f1c:	ff 75 f4             	pushl  -0xc(%ebp)
80103f1f:	e8 63 17 00 00       	call   80105687 <memcmp>
80103f24:	83 c4 10             	add    $0x10,%esp
80103f27:	85 c0                	test   %eax,%eax
80103f29:	75 19                	jne    80103f44 <mpsearch1+0x59>
80103f2b:	83 ec 08             	sub    $0x8,%esp
80103f2e:	6a 10                	push   $0x10
80103f30:	ff 75 f4             	pushl  -0xc(%ebp)
80103f33:	e8 7b ff ff ff       	call   80103eb3 <sum>
80103f38:	83 c4 10             	add    $0x10,%esp
80103f3b:	84 c0                	test   %al,%al
80103f3d:	75 05                	jne    80103f44 <mpsearch1+0x59>
      return (struct mp*)p;
80103f3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f42:	eb 11                	jmp    80103f55 <mpsearch1+0x6a>
{
  uchar *e, *p, *addr;

  addr = p2v(a);
  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
80103f44:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80103f48:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f4b:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103f4e:	72 c2                	jb     80103f12 <mpsearch1+0x27>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
      return (struct mp*)p;
  return 0;
80103f50:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103f55:	c9                   	leave  
80103f56:	c3                   	ret    

80103f57 <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
80103f57:	55                   	push   %ebp
80103f58:	89 e5                	mov    %esp,%ebp
80103f5a:	83 ec 18             	sub    $0x18,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
80103f5d:	c7 45 f4 00 04 00 80 	movl   $0x80000400,-0xc(%ebp)
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80103f64:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f67:	83 c0 0f             	add    $0xf,%eax
80103f6a:	0f b6 00             	movzbl (%eax),%eax
80103f6d:	0f b6 c0             	movzbl %al,%eax
80103f70:	c1 e0 08             	shl    $0x8,%eax
80103f73:	89 c2                	mov    %eax,%edx
80103f75:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f78:	83 c0 0e             	add    $0xe,%eax
80103f7b:	0f b6 00             	movzbl (%eax),%eax
80103f7e:	0f b6 c0             	movzbl %al,%eax
80103f81:	09 d0                	or     %edx,%eax
80103f83:	c1 e0 04             	shl    $0x4,%eax
80103f86:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103f89:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103f8d:	74 21                	je     80103fb0 <mpsearch+0x59>
    if((mp = mpsearch1(p, 1024)))
80103f8f:	83 ec 08             	sub    $0x8,%esp
80103f92:	68 00 04 00 00       	push   $0x400
80103f97:	ff 75 f0             	pushl  -0x10(%ebp)
80103f9a:	e8 4c ff ff ff       	call   80103eeb <mpsearch1>
80103f9f:	83 c4 10             	add    $0x10,%esp
80103fa2:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103fa5:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103fa9:	74 51                	je     80103ffc <mpsearch+0xa5>
      return mp;
80103fab:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103fae:	eb 61                	jmp    80104011 <mpsearch+0xba>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80103fb0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103fb3:	83 c0 14             	add    $0x14,%eax
80103fb6:	0f b6 00             	movzbl (%eax),%eax
80103fb9:	0f b6 c0             	movzbl %al,%eax
80103fbc:	c1 e0 08             	shl    $0x8,%eax
80103fbf:	89 c2                	mov    %eax,%edx
80103fc1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103fc4:	83 c0 13             	add    $0x13,%eax
80103fc7:	0f b6 00             	movzbl (%eax),%eax
80103fca:	0f b6 c0             	movzbl %al,%eax
80103fcd:	09 d0                	or     %edx,%eax
80103fcf:	c1 e0 0a             	shl    $0xa,%eax
80103fd2:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((mp = mpsearch1(p-1024, 1024)))
80103fd5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103fd8:	2d 00 04 00 00       	sub    $0x400,%eax
80103fdd:	83 ec 08             	sub    $0x8,%esp
80103fe0:	68 00 04 00 00       	push   $0x400
80103fe5:	50                   	push   %eax
80103fe6:	e8 00 ff ff ff       	call   80103eeb <mpsearch1>
80103feb:	83 c4 10             	add    $0x10,%esp
80103fee:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103ff1:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103ff5:	74 05                	je     80103ffc <mpsearch+0xa5>
      return mp;
80103ff7:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103ffa:	eb 15                	jmp    80104011 <mpsearch+0xba>
  }
  return mpsearch1(0xF0000, 0x10000);
80103ffc:	83 ec 08             	sub    $0x8,%esp
80103fff:	68 00 00 01 00       	push   $0x10000
80104004:	68 00 00 0f 00       	push   $0xf0000
80104009:	e8 dd fe ff ff       	call   80103eeb <mpsearch1>
8010400e:	83 c4 10             	add    $0x10,%esp
}
80104011:	c9                   	leave  
80104012:	c3                   	ret    

80104013 <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80104013:	55                   	push   %ebp
80104014:	89 e5                	mov    %esp,%ebp
80104016:	83 ec 18             	sub    $0x18,%esp
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80104019:	e8 39 ff ff ff       	call   80103f57 <mpsearch>
8010401e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104021:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104025:	74 0a                	je     80104031 <mpconfig+0x1e>
80104027:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010402a:	8b 40 04             	mov    0x4(%eax),%eax
8010402d:	85 c0                	test   %eax,%eax
8010402f:	75 0a                	jne    8010403b <mpconfig+0x28>
    return 0;
80104031:	b8 00 00 00 00       	mov    $0x0,%eax
80104036:	e9 81 00 00 00       	jmp    801040bc <mpconfig+0xa9>
  conf = (struct mpconf*) p2v((uint) mp->physaddr);
8010403b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010403e:	8b 40 04             	mov    0x4(%eax),%eax
80104041:	83 ec 0c             	sub    $0xc,%esp
80104044:	50                   	push   %eax
80104045:	e8 02 fe ff ff       	call   80103e4c <p2v>
8010404a:	83 c4 10             	add    $0x10,%esp
8010404d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
80104050:	83 ec 04             	sub    $0x4,%esp
80104053:	6a 04                	push   $0x4
80104055:	68 f5 8b 10 80       	push   $0x80108bf5
8010405a:	ff 75 f0             	pushl  -0x10(%ebp)
8010405d:	e8 25 16 00 00       	call   80105687 <memcmp>
80104062:	83 c4 10             	add    $0x10,%esp
80104065:	85 c0                	test   %eax,%eax
80104067:	74 07                	je     80104070 <mpconfig+0x5d>
    return 0;
80104069:	b8 00 00 00 00       	mov    $0x0,%eax
8010406e:	eb 4c                	jmp    801040bc <mpconfig+0xa9>
  if(conf->version != 1 && conf->version != 4)
80104070:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104073:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80104077:	3c 01                	cmp    $0x1,%al
80104079:	74 12                	je     8010408d <mpconfig+0x7a>
8010407b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010407e:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80104082:	3c 04                	cmp    $0x4,%al
80104084:	74 07                	je     8010408d <mpconfig+0x7a>
    return 0;
80104086:	b8 00 00 00 00       	mov    $0x0,%eax
8010408b:	eb 2f                	jmp    801040bc <mpconfig+0xa9>
  if(sum((uchar*)conf, conf->length) != 0)
8010408d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104090:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80104094:	0f b7 c0             	movzwl %ax,%eax
80104097:	83 ec 08             	sub    $0x8,%esp
8010409a:	50                   	push   %eax
8010409b:	ff 75 f0             	pushl  -0x10(%ebp)
8010409e:	e8 10 fe ff ff       	call   80103eb3 <sum>
801040a3:	83 c4 10             	add    $0x10,%esp
801040a6:	84 c0                	test   %al,%al
801040a8:	74 07                	je     801040b1 <mpconfig+0x9e>
    return 0;
801040aa:	b8 00 00 00 00       	mov    $0x0,%eax
801040af:	eb 0b                	jmp    801040bc <mpconfig+0xa9>
  *pmp = mp;
801040b1:	8b 45 08             	mov    0x8(%ebp),%eax
801040b4:	8b 55 f4             	mov    -0xc(%ebp),%edx
801040b7:	89 10                	mov    %edx,(%eax)
  return conf;
801040b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
801040bc:	c9                   	leave  
801040bd:	c3                   	ret    

801040be <mpinit>:

void
mpinit(void)
{
801040be:	55                   	push   %ebp
801040bf:	89 e5                	mov    %esp,%ebp
801040c1:	83 ec 28             	sub    $0x28,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
801040c4:	c7 05 44 b6 10 80 40 	movl   $0x80112640,0x8010b644
801040cb:	26 11 80 
  if((conf = mpconfig(&mp)) == 0)
801040ce:	83 ec 0c             	sub    $0xc,%esp
801040d1:	8d 45 e0             	lea    -0x20(%ebp),%eax
801040d4:	50                   	push   %eax
801040d5:	e8 39 ff ff ff       	call   80104013 <mpconfig>
801040da:	83 c4 10             	add    $0x10,%esp
801040dd:	89 45 f0             	mov    %eax,-0x10(%ebp)
801040e0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801040e4:	0f 84 96 01 00 00    	je     80104280 <mpinit+0x1c2>
    return;
  ismp = 1;
801040ea:	c7 05 24 26 11 80 01 	movl   $0x1,0x80112624
801040f1:	00 00 00 
  lapic = (uint*)conf->lapicaddr;
801040f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801040f7:	8b 40 24             	mov    0x24(%eax),%eax
801040fa:	a3 3c 25 11 80       	mov    %eax,0x8011253c
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
801040ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104102:	83 c0 2c             	add    $0x2c,%eax
80104105:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104108:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010410b:	0f b7 40 04          	movzwl 0x4(%eax),%eax
8010410f:	0f b7 d0             	movzwl %ax,%edx
80104112:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104115:	01 d0                	add    %edx,%eax
80104117:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010411a:	e9 f2 00 00 00       	jmp    80104211 <mpinit+0x153>
    switch(*p){
8010411f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104122:	0f b6 00             	movzbl (%eax),%eax
80104125:	0f b6 c0             	movzbl %al,%eax
80104128:	83 f8 04             	cmp    $0x4,%eax
8010412b:	0f 87 bc 00 00 00    	ja     801041ed <mpinit+0x12f>
80104131:	8b 04 85 38 8c 10 80 	mov    -0x7fef73c8(,%eax,4),%eax
80104138:	ff e0                	jmp    *%eax
    case MPPROC:
      proc = (struct mpproc*)p;
8010413a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010413d:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if(ncpu != proc->apicid){
80104140:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104143:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80104147:	0f b6 d0             	movzbl %al,%edx
8010414a:	a1 20 2c 11 80       	mov    0x80112c20,%eax
8010414f:	39 c2                	cmp    %eax,%edx
80104151:	74 2b                	je     8010417e <mpinit+0xc0>
        cprintf("mpinit: ncpu=%d apicid=%d\n", ncpu, proc->apicid);
80104153:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104156:	0f b6 40 01          	movzbl 0x1(%eax),%eax
8010415a:	0f b6 d0             	movzbl %al,%edx
8010415d:	a1 20 2c 11 80       	mov    0x80112c20,%eax
80104162:	83 ec 04             	sub    $0x4,%esp
80104165:	52                   	push   %edx
80104166:	50                   	push   %eax
80104167:	68 fa 8b 10 80       	push   $0x80108bfa
8010416c:	e8 55 c2 ff ff       	call   801003c6 <cprintf>
80104171:	83 c4 10             	add    $0x10,%esp
        ismp = 0;
80104174:	c7 05 24 26 11 80 00 	movl   $0x0,0x80112624
8010417b:	00 00 00 
      }
      if(proc->flags & MPBOOT)
8010417e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104181:	0f b6 40 03          	movzbl 0x3(%eax),%eax
80104185:	0f b6 c0             	movzbl %al,%eax
80104188:	83 e0 02             	and    $0x2,%eax
8010418b:	85 c0                	test   %eax,%eax
8010418d:	74 15                	je     801041a4 <mpinit+0xe6>
        bcpu = &cpus[ncpu];
8010418f:	a1 20 2c 11 80       	mov    0x80112c20,%eax
80104194:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
8010419a:	05 40 26 11 80       	add    $0x80112640,%eax
8010419f:	a3 44 b6 10 80       	mov    %eax,0x8010b644
      cpus[ncpu].id = ncpu;
801041a4:	a1 20 2c 11 80       	mov    0x80112c20,%eax
801041a9:	8b 15 20 2c 11 80    	mov    0x80112c20,%edx
801041af:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
801041b5:	05 40 26 11 80       	add    $0x80112640,%eax
801041ba:	88 10                	mov    %dl,(%eax)
      ncpu++;
801041bc:	a1 20 2c 11 80       	mov    0x80112c20,%eax
801041c1:	83 c0 01             	add    $0x1,%eax
801041c4:	a3 20 2c 11 80       	mov    %eax,0x80112c20
      p += sizeof(struct mpproc);
801041c9:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
      continue;
801041cd:	eb 42                	jmp    80104211 <mpinit+0x153>
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
801041cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041d2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      ioapicid = ioapic->apicno;
801041d5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801041d8:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801041dc:	a2 20 26 11 80       	mov    %al,0x80112620
      p += sizeof(struct mpioapic);
801041e1:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
801041e5:	eb 2a                	jmp    80104211 <mpinit+0x153>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
801041e7:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
801041eb:	eb 24                	jmp    80104211 <mpinit+0x153>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
801041ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041f0:	0f b6 00             	movzbl (%eax),%eax
801041f3:	0f b6 c0             	movzbl %al,%eax
801041f6:	83 ec 08             	sub    $0x8,%esp
801041f9:	50                   	push   %eax
801041fa:	68 18 8c 10 80       	push   $0x80108c18
801041ff:	e8 c2 c1 ff ff       	call   801003c6 <cprintf>
80104204:	83 c4 10             	add    $0x10,%esp
      ismp = 0;
80104207:	c7 05 24 26 11 80 00 	movl   $0x0,0x80112624
8010420e:	00 00 00 
  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80104211:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104214:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80104217:	0f 82 02 ff ff ff    	jb     8010411f <mpinit+0x61>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
      ismp = 0;
    }
  }
  if(!ismp){
8010421d:	a1 24 26 11 80       	mov    0x80112624,%eax
80104222:	85 c0                	test   %eax,%eax
80104224:	75 1d                	jne    80104243 <mpinit+0x185>
    // Didn't like what we found; fall back to no MP.
    ncpu = 1;
80104226:	c7 05 20 2c 11 80 01 	movl   $0x1,0x80112c20
8010422d:	00 00 00 
    lapic = 0;
80104230:	c7 05 3c 25 11 80 00 	movl   $0x0,0x8011253c
80104237:	00 00 00 
    ioapicid = 0;
8010423a:	c6 05 20 26 11 80 00 	movb   $0x0,0x80112620
    return;
80104241:	eb 3e                	jmp    80104281 <mpinit+0x1c3>
  }

  if(mp->imcrp){
80104243:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104246:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
8010424a:	84 c0                	test   %al,%al
8010424c:	74 33                	je     80104281 <mpinit+0x1c3>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
8010424e:	83 ec 08             	sub    $0x8,%esp
80104251:	6a 70                	push   $0x70
80104253:	6a 22                	push   $0x22
80104255:	e8 1c fc ff ff       	call   80103e76 <outb>
8010425a:	83 c4 10             	add    $0x10,%esp
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
8010425d:	83 ec 0c             	sub    $0xc,%esp
80104260:	6a 23                	push   $0x23
80104262:	e8 f2 fb ff ff       	call   80103e59 <inb>
80104267:	83 c4 10             	add    $0x10,%esp
8010426a:	83 c8 01             	or     $0x1,%eax
8010426d:	0f b6 c0             	movzbl %al,%eax
80104270:	83 ec 08             	sub    $0x8,%esp
80104273:	50                   	push   %eax
80104274:	6a 23                	push   $0x23
80104276:	e8 fb fb ff ff       	call   80103e76 <outb>
8010427b:	83 c4 10             	add    $0x10,%esp
8010427e:	eb 01                	jmp    80104281 <mpinit+0x1c3>
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
80104280:	90                   	nop
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
  }
}
80104281:	c9                   	leave  
80104282:	c3                   	ret    

80104283 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80104283:	55                   	push   %ebp
80104284:	89 e5                	mov    %esp,%ebp
80104286:	83 ec 08             	sub    $0x8,%esp
80104289:	8b 55 08             	mov    0x8(%ebp),%edx
8010428c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010428f:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80104293:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80104296:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
8010429a:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010429e:	ee                   	out    %al,(%dx)
}
8010429f:	90                   	nop
801042a0:	c9                   	leave  
801042a1:	c3                   	ret    

801042a2 <picsetmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static ushort irqmask = 0xFFFF & ~(1<<IRQ_SLAVE);

static void
picsetmask(ushort mask)
{
801042a2:	55                   	push   %ebp
801042a3:	89 e5                	mov    %esp,%ebp
801042a5:	83 ec 04             	sub    $0x4,%esp
801042a8:	8b 45 08             	mov    0x8(%ebp),%eax
801042ab:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  irqmask = mask;
801042af:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801042b3:	66 a3 00 b0 10 80    	mov    %ax,0x8010b000
  outb(IO_PIC1+1, mask);
801042b9:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801042bd:	0f b6 c0             	movzbl %al,%eax
801042c0:	50                   	push   %eax
801042c1:	6a 21                	push   $0x21
801042c3:	e8 bb ff ff ff       	call   80104283 <outb>
801042c8:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, mask >> 8);
801042cb:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801042cf:	66 c1 e8 08          	shr    $0x8,%ax
801042d3:	0f b6 c0             	movzbl %al,%eax
801042d6:	50                   	push   %eax
801042d7:	68 a1 00 00 00       	push   $0xa1
801042dc:	e8 a2 ff ff ff       	call   80104283 <outb>
801042e1:	83 c4 08             	add    $0x8,%esp
}
801042e4:	90                   	nop
801042e5:	c9                   	leave  
801042e6:	c3                   	ret    

801042e7 <picenable>:

void
picenable(int irq)
{
801042e7:	55                   	push   %ebp
801042e8:	89 e5                	mov    %esp,%ebp
  picsetmask(irqmask & ~(1<<irq));
801042ea:	8b 45 08             	mov    0x8(%ebp),%eax
801042ed:	ba 01 00 00 00       	mov    $0x1,%edx
801042f2:	89 c1                	mov    %eax,%ecx
801042f4:	d3 e2                	shl    %cl,%edx
801042f6:	89 d0                	mov    %edx,%eax
801042f8:	f7 d0                	not    %eax
801042fa:	89 c2                	mov    %eax,%edx
801042fc:	0f b7 05 00 b0 10 80 	movzwl 0x8010b000,%eax
80104303:	21 d0                	and    %edx,%eax
80104305:	0f b7 c0             	movzwl %ax,%eax
80104308:	50                   	push   %eax
80104309:	e8 94 ff ff ff       	call   801042a2 <picsetmask>
8010430e:	83 c4 04             	add    $0x4,%esp
}
80104311:	90                   	nop
80104312:	c9                   	leave  
80104313:	c3                   	ret    

80104314 <picinit>:

// Initialize the 8259A interrupt controllers.
void
picinit(void)
{
80104314:	55                   	push   %ebp
80104315:	89 e5                	mov    %esp,%ebp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80104317:	68 ff 00 00 00       	push   $0xff
8010431c:	6a 21                	push   $0x21
8010431e:	e8 60 ff ff ff       	call   80104283 <outb>
80104323:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, 0xFF);
80104326:	68 ff 00 00 00       	push   $0xff
8010432b:	68 a1 00 00 00       	push   $0xa1
80104330:	e8 4e ff ff ff       	call   80104283 <outb>
80104335:	83 c4 08             	add    $0x8,%esp

  // ICW1:  0001g0hi
  //    g:  0 = edge triggering, 1 = level triggering
  //    h:  0 = cascaded PICs, 1 = master only
  //    i:  0 = no ICW4, 1 = ICW4 required
  outb(IO_PIC1, 0x11);
80104338:	6a 11                	push   $0x11
8010433a:	6a 20                	push   $0x20
8010433c:	e8 42 ff ff ff       	call   80104283 <outb>
80104341:	83 c4 08             	add    $0x8,%esp

  // ICW2:  Vector offset
  outb(IO_PIC1+1, T_IRQ0);
80104344:	6a 20                	push   $0x20
80104346:	6a 21                	push   $0x21
80104348:	e8 36 ff ff ff       	call   80104283 <outb>
8010434d:	83 c4 08             	add    $0x8,%esp

  // ICW3:  (master PIC) bit mask of IR lines connected to slaves
  //        (slave PIC) 3-bit # of slave's connection to master
  outb(IO_PIC1+1, 1<<IRQ_SLAVE);
80104350:	6a 04                	push   $0x4
80104352:	6a 21                	push   $0x21
80104354:	e8 2a ff ff ff       	call   80104283 <outb>
80104359:	83 c4 08             	add    $0x8,%esp
  //    m:  0 = slave PIC, 1 = master PIC
  //      (ignored when b is 0, as the master/slave role
  //      can be hardwired).
  //    a:  1 = Automatic EOI mode
  //    p:  0 = MCS-80/85 mode, 1 = intel x86 mode
  outb(IO_PIC1+1, 0x3);
8010435c:	6a 03                	push   $0x3
8010435e:	6a 21                	push   $0x21
80104360:	e8 1e ff ff ff       	call   80104283 <outb>
80104365:	83 c4 08             	add    $0x8,%esp

  // Set up slave (8259A-2)
  outb(IO_PIC2, 0x11);                  // ICW1
80104368:	6a 11                	push   $0x11
8010436a:	68 a0 00 00 00       	push   $0xa0
8010436f:	e8 0f ff ff ff       	call   80104283 <outb>
80104374:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, T_IRQ0 + 8);      // ICW2
80104377:	6a 28                	push   $0x28
80104379:	68 a1 00 00 00       	push   $0xa1
8010437e:	e8 00 ff ff ff       	call   80104283 <outb>
80104383:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, IRQ_SLAVE);           // ICW3
80104386:	6a 02                	push   $0x2
80104388:	68 a1 00 00 00       	push   $0xa1
8010438d:	e8 f1 fe ff ff       	call   80104283 <outb>
80104392:	83 c4 08             	add    $0x8,%esp
  // NB Automatic EOI mode doesn't tend to work on the slave.
  // Linux source code says it's "to be investigated".
  outb(IO_PIC2+1, 0x3);                 // ICW4
80104395:	6a 03                	push   $0x3
80104397:	68 a1 00 00 00       	push   $0xa1
8010439c:	e8 e2 fe ff ff       	call   80104283 <outb>
801043a1:	83 c4 08             	add    $0x8,%esp

  // OCW3:  0ef01prs
  //   ef:  0x = NOP, 10 = clear specific mask, 11 = set specific mask
  //    p:  0 = no polling, 1 = polling mode
  //   rs:  0x = NOP, 10 = read IRR, 11 = read ISR
  outb(IO_PIC1, 0x68);             // clear specific mask
801043a4:	6a 68                	push   $0x68
801043a6:	6a 20                	push   $0x20
801043a8:	e8 d6 fe ff ff       	call   80104283 <outb>
801043ad:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC1, 0x0a);             // read IRR by default
801043b0:	6a 0a                	push   $0xa
801043b2:	6a 20                	push   $0x20
801043b4:	e8 ca fe ff ff       	call   80104283 <outb>
801043b9:	83 c4 08             	add    $0x8,%esp

  outb(IO_PIC2, 0x68);             // OCW3
801043bc:	6a 68                	push   $0x68
801043be:	68 a0 00 00 00       	push   $0xa0
801043c3:	e8 bb fe ff ff       	call   80104283 <outb>
801043c8:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2, 0x0a);             // OCW3
801043cb:	6a 0a                	push   $0xa
801043cd:	68 a0 00 00 00       	push   $0xa0
801043d2:	e8 ac fe ff ff       	call   80104283 <outb>
801043d7:	83 c4 08             	add    $0x8,%esp

  if(irqmask != 0xFFFF)
801043da:	0f b7 05 00 b0 10 80 	movzwl 0x8010b000,%eax
801043e1:	66 83 f8 ff          	cmp    $0xffff,%ax
801043e5:	74 13                	je     801043fa <picinit+0xe6>
    picsetmask(irqmask);
801043e7:	0f b7 05 00 b0 10 80 	movzwl 0x8010b000,%eax
801043ee:	0f b7 c0             	movzwl %ax,%eax
801043f1:	50                   	push   %eax
801043f2:	e8 ab fe ff ff       	call   801042a2 <picsetmask>
801043f7:	83 c4 04             	add    $0x4,%esp
}
801043fa:	90                   	nop
801043fb:	c9                   	leave  
801043fc:	c3                   	ret    

801043fd <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
801043fd:	55                   	push   %ebp
801043fe:	89 e5                	mov    %esp,%ebp
80104400:	83 ec 18             	sub    $0x18,%esp
  struct pipe *p;

  p = 0;
80104403:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
8010440a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010440d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80104413:	8b 45 0c             	mov    0xc(%ebp),%eax
80104416:	8b 10                	mov    (%eax),%edx
80104418:	8b 45 08             	mov    0x8(%ebp),%eax
8010441b:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
8010441d:	e8 71 cb ff ff       	call   80100f93 <filealloc>
80104422:	89 c2                	mov    %eax,%edx
80104424:	8b 45 08             	mov    0x8(%ebp),%eax
80104427:	89 10                	mov    %edx,(%eax)
80104429:	8b 45 08             	mov    0x8(%ebp),%eax
8010442c:	8b 00                	mov    (%eax),%eax
8010442e:	85 c0                	test   %eax,%eax
80104430:	0f 84 cb 00 00 00    	je     80104501 <pipealloc+0x104>
80104436:	e8 58 cb ff ff       	call   80100f93 <filealloc>
8010443b:	89 c2                	mov    %eax,%edx
8010443d:	8b 45 0c             	mov    0xc(%ebp),%eax
80104440:	89 10                	mov    %edx,(%eax)
80104442:	8b 45 0c             	mov    0xc(%ebp),%eax
80104445:	8b 00                	mov    (%eax),%eax
80104447:	85 c0                	test   %eax,%eax
80104449:	0f 84 b2 00 00 00    	je     80104501 <pipealloc+0x104>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
8010444f:	e8 aa eb ff ff       	call   80102ffe <kalloc>
80104454:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104457:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010445b:	0f 84 9f 00 00 00    	je     80104500 <pipealloc+0x103>
    goto bad;
  p->readopen = 1;
80104461:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104464:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
8010446b:	00 00 00 
  p->writeopen = 1;
8010446e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104471:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80104478:	00 00 00 
  p->nwrite = 0;
8010447b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010447e:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80104485:	00 00 00 
  p->nread = 0;
80104488:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010448b:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80104492:	00 00 00 
  initlock(&p->lock, "pipe");
80104495:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104498:	83 ec 08             	sub    $0x8,%esp
8010449b:	68 4c 8c 10 80       	push   $0x80108c4c
801044a0:	50                   	push   %eax
801044a1:	e8 f5 0e 00 00       	call   8010539b <initlock>
801044a6:	83 c4 10             	add    $0x10,%esp
  (*f0)->type = FD_PIPE;
801044a9:	8b 45 08             	mov    0x8(%ebp),%eax
801044ac:	8b 00                	mov    (%eax),%eax
801044ae:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
801044b4:	8b 45 08             	mov    0x8(%ebp),%eax
801044b7:	8b 00                	mov    (%eax),%eax
801044b9:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
801044bd:	8b 45 08             	mov    0x8(%ebp),%eax
801044c0:	8b 00                	mov    (%eax),%eax
801044c2:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
801044c6:	8b 45 08             	mov    0x8(%ebp),%eax
801044c9:	8b 00                	mov    (%eax),%eax
801044cb:	8b 55 f4             	mov    -0xc(%ebp),%edx
801044ce:	89 50 0a             	mov    %edx,0xa(%eax)
  (*f1)->type = FD_PIPE;
801044d1:	8b 45 0c             	mov    0xc(%ebp),%eax
801044d4:	8b 00                	mov    (%eax),%eax
801044d6:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
801044dc:	8b 45 0c             	mov    0xc(%ebp),%eax
801044df:	8b 00                	mov    (%eax),%eax
801044e1:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
801044e5:	8b 45 0c             	mov    0xc(%ebp),%eax
801044e8:	8b 00                	mov    (%eax),%eax
801044ea:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
801044ee:	8b 45 0c             	mov    0xc(%ebp),%eax
801044f1:	8b 00                	mov    (%eax),%eax
801044f3:	8b 55 f4             	mov    -0xc(%ebp),%edx
801044f6:	89 50 0a             	mov    %edx,0xa(%eax)
  return 0;
801044f9:	b8 00 00 00 00       	mov    $0x0,%eax
801044fe:	eb 4e                	jmp    8010454e <pipealloc+0x151>
  p = 0;
  *f0 = *f1 = 0;
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
    goto bad;
80104500:	90                   	nop
  (*f1)->pipe = p;
  return 0;

//PAGEBREAK: 20
 bad:
  if(p)
80104501:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104505:	74 0e                	je     80104515 <pipealloc+0x118>
    kfree((char*)p);
80104507:	83 ec 0c             	sub    $0xc,%esp
8010450a:	ff 75 f4             	pushl  -0xc(%ebp)
8010450d:	e8 4f ea ff ff       	call   80102f61 <kfree>
80104512:	83 c4 10             	add    $0x10,%esp
  if(*f0)
80104515:	8b 45 08             	mov    0x8(%ebp),%eax
80104518:	8b 00                	mov    (%eax),%eax
8010451a:	85 c0                	test   %eax,%eax
8010451c:	74 11                	je     8010452f <pipealloc+0x132>
    fileclose(*f0);
8010451e:	8b 45 08             	mov    0x8(%ebp),%eax
80104521:	8b 00                	mov    (%eax),%eax
80104523:	83 ec 0c             	sub    $0xc,%esp
80104526:	50                   	push   %eax
80104527:	e8 25 cb ff ff       	call   80101051 <fileclose>
8010452c:	83 c4 10             	add    $0x10,%esp
  if(*f1)
8010452f:	8b 45 0c             	mov    0xc(%ebp),%eax
80104532:	8b 00                	mov    (%eax),%eax
80104534:	85 c0                	test   %eax,%eax
80104536:	74 11                	je     80104549 <pipealloc+0x14c>
    fileclose(*f1);
80104538:	8b 45 0c             	mov    0xc(%ebp),%eax
8010453b:	8b 00                	mov    (%eax),%eax
8010453d:	83 ec 0c             	sub    $0xc,%esp
80104540:	50                   	push   %eax
80104541:	e8 0b cb ff ff       	call   80101051 <fileclose>
80104546:	83 c4 10             	add    $0x10,%esp
  return -1;
80104549:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010454e:	c9                   	leave  
8010454f:	c3                   	ret    

80104550 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
80104550:	55                   	push   %ebp
80104551:	89 e5                	mov    %esp,%ebp
80104553:	83 ec 08             	sub    $0x8,%esp
  acquire(&p->lock);
80104556:	8b 45 08             	mov    0x8(%ebp),%eax
80104559:	83 ec 0c             	sub    $0xc,%esp
8010455c:	50                   	push   %eax
8010455d:	e8 5b 0e 00 00       	call   801053bd <acquire>
80104562:	83 c4 10             	add    $0x10,%esp
  if(writable){
80104565:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104569:	74 23                	je     8010458e <pipeclose+0x3e>
    p->writeopen = 0;
8010456b:	8b 45 08             	mov    0x8(%ebp),%eax
8010456e:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
80104575:	00 00 00 
    wakeup(&p->nread);
80104578:	8b 45 08             	mov    0x8(%ebp),%eax
8010457b:	05 34 02 00 00       	add    $0x234,%eax
80104580:	83 ec 0c             	sub    $0xc,%esp
80104583:	50                   	push   %eax
80104584:	e8 26 0c 00 00       	call   801051af <wakeup>
80104589:	83 c4 10             	add    $0x10,%esp
8010458c:	eb 21                	jmp    801045af <pipeclose+0x5f>
  } else {
    p->readopen = 0;
8010458e:	8b 45 08             	mov    0x8(%ebp),%eax
80104591:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
80104598:	00 00 00 
    wakeup(&p->nwrite);
8010459b:	8b 45 08             	mov    0x8(%ebp),%eax
8010459e:	05 38 02 00 00       	add    $0x238,%eax
801045a3:	83 ec 0c             	sub    $0xc,%esp
801045a6:	50                   	push   %eax
801045a7:	e8 03 0c 00 00       	call   801051af <wakeup>
801045ac:	83 c4 10             	add    $0x10,%esp
  }
  if(p->readopen == 0 && p->writeopen == 0){
801045af:	8b 45 08             	mov    0x8(%ebp),%eax
801045b2:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
801045b8:	85 c0                	test   %eax,%eax
801045ba:	75 2c                	jne    801045e8 <pipeclose+0x98>
801045bc:	8b 45 08             	mov    0x8(%ebp),%eax
801045bf:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
801045c5:	85 c0                	test   %eax,%eax
801045c7:	75 1f                	jne    801045e8 <pipeclose+0x98>
    release(&p->lock);
801045c9:	8b 45 08             	mov    0x8(%ebp),%eax
801045cc:	83 ec 0c             	sub    $0xc,%esp
801045cf:	50                   	push   %eax
801045d0:	e8 4f 0e 00 00       	call   80105424 <release>
801045d5:	83 c4 10             	add    $0x10,%esp
    kfree((char*)p);
801045d8:	83 ec 0c             	sub    $0xc,%esp
801045db:	ff 75 08             	pushl  0x8(%ebp)
801045de:	e8 7e e9 ff ff       	call   80102f61 <kfree>
801045e3:	83 c4 10             	add    $0x10,%esp
801045e6:	eb 0f                	jmp    801045f7 <pipeclose+0xa7>
  } else
    release(&p->lock);
801045e8:	8b 45 08             	mov    0x8(%ebp),%eax
801045eb:	83 ec 0c             	sub    $0xc,%esp
801045ee:	50                   	push   %eax
801045ef:	e8 30 0e 00 00       	call   80105424 <release>
801045f4:	83 c4 10             	add    $0x10,%esp
}
801045f7:	90                   	nop
801045f8:	c9                   	leave  
801045f9:	c3                   	ret    

801045fa <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
801045fa:	55                   	push   %ebp
801045fb:	89 e5                	mov    %esp,%ebp
801045fd:	83 ec 18             	sub    $0x18,%esp
  int i;

  acquire(&p->lock);
80104600:	8b 45 08             	mov    0x8(%ebp),%eax
80104603:	83 ec 0c             	sub    $0xc,%esp
80104606:	50                   	push   %eax
80104607:	e8 b1 0d 00 00       	call   801053bd <acquire>
8010460c:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++){
8010460f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104616:	e9 ad 00 00 00       	jmp    801046c8 <pipewrite+0xce>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || proc->killed){
8010461b:	8b 45 08             	mov    0x8(%ebp),%eax
8010461e:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80104624:	85 c0                	test   %eax,%eax
80104626:	74 0d                	je     80104635 <pipewrite+0x3b>
80104628:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010462e:	8b 40 24             	mov    0x24(%eax),%eax
80104631:	85 c0                	test   %eax,%eax
80104633:	74 19                	je     8010464e <pipewrite+0x54>
        release(&p->lock);
80104635:	8b 45 08             	mov    0x8(%ebp),%eax
80104638:	83 ec 0c             	sub    $0xc,%esp
8010463b:	50                   	push   %eax
8010463c:	e8 e3 0d 00 00       	call   80105424 <release>
80104641:	83 c4 10             	add    $0x10,%esp
        return -1;
80104644:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104649:	e9 a8 00 00 00       	jmp    801046f6 <pipewrite+0xfc>
      }
      wakeup(&p->nread);
8010464e:	8b 45 08             	mov    0x8(%ebp),%eax
80104651:	05 34 02 00 00       	add    $0x234,%eax
80104656:	83 ec 0c             	sub    $0xc,%esp
80104659:	50                   	push   %eax
8010465a:	e8 50 0b 00 00       	call   801051af <wakeup>
8010465f:	83 c4 10             	add    $0x10,%esp
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
80104662:	8b 45 08             	mov    0x8(%ebp),%eax
80104665:	8b 55 08             	mov    0x8(%ebp),%edx
80104668:	81 c2 38 02 00 00    	add    $0x238,%edx
8010466e:	83 ec 08             	sub    $0x8,%esp
80104671:	50                   	push   %eax
80104672:	52                   	push   %edx
80104673:	e8 4c 0a 00 00       	call   801050c4 <sleep>
80104678:	83 c4 10             	add    $0x10,%esp
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
8010467b:	8b 45 08             	mov    0x8(%ebp),%eax
8010467e:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
80104684:	8b 45 08             	mov    0x8(%ebp),%eax
80104687:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
8010468d:	05 00 02 00 00       	add    $0x200,%eax
80104692:	39 c2                	cmp    %eax,%edx
80104694:	74 85                	je     8010461b <pipewrite+0x21>
        return -1;
      }
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
80104696:	8b 45 08             	mov    0x8(%ebp),%eax
80104699:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
8010469f:	8d 48 01             	lea    0x1(%eax),%ecx
801046a2:	8b 55 08             	mov    0x8(%ebp),%edx
801046a5:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
801046ab:	25 ff 01 00 00       	and    $0x1ff,%eax
801046b0:	89 c1                	mov    %eax,%ecx
801046b2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801046b5:	8b 45 0c             	mov    0xc(%ebp),%eax
801046b8:	01 d0                	add    %edx,%eax
801046ba:	0f b6 10             	movzbl (%eax),%edx
801046bd:	8b 45 08             	mov    0x8(%ebp),%eax
801046c0:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
pipewrite(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
801046c4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801046c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046cb:	3b 45 10             	cmp    0x10(%ebp),%eax
801046ce:	7c ab                	jl     8010467b <pipewrite+0x81>
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
801046d0:	8b 45 08             	mov    0x8(%ebp),%eax
801046d3:	05 34 02 00 00       	add    $0x234,%eax
801046d8:	83 ec 0c             	sub    $0xc,%esp
801046db:	50                   	push   %eax
801046dc:	e8 ce 0a 00 00       	call   801051af <wakeup>
801046e1:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
801046e4:	8b 45 08             	mov    0x8(%ebp),%eax
801046e7:	83 ec 0c             	sub    $0xc,%esp
801046ea:	50                   	push   %eax
801046eb:	e8 34 0d 00 00       	call   80105424 <release>
801046f0:	83 c4 10             	add    $0x10,%esp
  return n;
801046f3:	8b 45 10             	mov    0x10(%ebp),%eax
}
801046f6:	c9                   	leave  
801046f7:	c3                   	ret    

801046f8 <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
801046f8:	55                   	push   %ebp
801046f9:	89 e5                	mov    %esp,%ebp
801046fb:	53                   	push   %ebx
801046fc:	83 ec 14             	sub    $0x14,%esp
  int i;

  acquire(&p->lock);
801046ff:	8b 45 08             	mov    0x8(%ebp),%eax
80104702:	83 ec 0c             	sub    $0xc,%esp
80104705:	50                   	push   %eax
80104706:	e8 b2 0c 00 00       	call   801053bd <acquire>
8010470b:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
8010470e:	eb 3f                	jmp    8010474f <piperead+0x57>
    if(proc->killed){
80104710:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104716:	8b 40 24             	mov    0x24(%eax),%eax
80104719:	85 c0                	test   %eax,%eax
8010471b:	74 19                	je     80104736 <piperead+0x3e>
      release(&p->lock);
8010471d:	8b 45 08             	mov    0x8(%ebp),%eax
80104720:	83 ec 0c             	sub    $0xc,%esp
80104723:	50                   	push   %eax
80104724:	e8 fb 0c 00 00       	call   80105424 <release>
80104729:	83 c4 10             	add    $0x10,%esp
      return -1;
8010472c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104731:	e9 bf 00 00 00       	jmp    801047f5 <piperead+0xfd>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
80104736:	8b 45 08             	mov    0x8(%ebp),%eax
80104739:	8b 55 08             	mov    0x8(%ebp),%edx
8010473c:	81 c2 34 02 00 00    	add    $0x234,%edx
80104742:	83 ec 08             	sub    $0x8,%esp
80104745:	50                   	push   %eax
80104746:	52                   	push   %edx
80104747:	e8 78 09 00 00       	call   801050c4 <sleep>
8010474c:	83 c4 10             	add    $0x10,%esp
piperead(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
8010474f:	8b 45 08             	mov    0x8(%ebp),%eax
80104752:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80104758:	8b 45 08             	mov    0x8(%ebp),%eax
8010475b:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104761:	39 c2                	cmp    %eax,%edx
80104763:	75 0d                	jne    80104772 <piperead+0x7a>
80104765:	8b 45 08             	mov    0x8(%ebp),%eax
80104768:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
8010476e:	85 c0                	test   %eax,%eax
80104770:	75 9e                	jne    80104710 <piperead+0x18>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80104772:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104779:	eb 49                	jmp    801047c4 <piperead+0xcc>
    if(p->nread == p->nwrite)
8010477b:	8b 45 08             	mov    0x8(%ebp),%eax
8010477e:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80104784:	8b 45 08             	mov    0x8(%ebp),%eax
80104787:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
8010478d:	39 c2                	cmp    %eax,%edx
8010478f:	74 3d                	je     801047ce <piperead+0xd6>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
80104791:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104794:	8b 45 0c             	mov    0xc(%ebp),%eax
80104797:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
8010479a:	8b 45 08             	mov    0x8(%ebp),%eax
8010479d:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
801047a3:	8d 48 01             	lea    0x1(%eax),%ecx
801047a6:	8b 55 08             	mov    0x8(%ebp),%edx
801047a9:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
801047af:	25 ff 01 00 00       	and    $0x1ff,%eax
801047b4:	89 c2                	mov    %eax,%edx
801047b6:	8b 45 08             	mov    0x8(%ebp),%eax
801047b9:	0f b6 44 10 34       	movzbl 0x34(%eax,%edx,1),%eax
801047be:	88 03                	mov    %al,(%ebx)
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
801047c0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801047c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047c7:	3b 45 10             	cmp    0x10(%ebp),%eax
801047ca:	7c af                	jl     8010477b <piperead+0x83>
801047cc:	eb 01                	jmp    801047cf <piperead+0xd7>
    if(p->nread == p->nwrite)
      break;
801047ce:	90                   	nop
    addr[i] = p->data[p->nread++ % PIPESIZE];
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
801047cf:	8b 45 08             	mov    0x8(%ebp),%eax
801047d2:	05 38 02 00 00       	add    $0x238,%eax
801047d7:	83 ec 0c             	sub    $0xc,%esp
801047da:	50                   	push   %eax
801047db:	e8 cf 09 00 00       	call   801051af <wakeup>
801047e0:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
801047e3:	8b 45 08             	mov    0x8(%ebp),%eax
801047e6:	83 ec 0c             	sub    $0xc,%esp
801047e9:	50                   	push   %eax
801047ea:	e8 35 0c 00 00       	call   80105424 <release>
801047ef:	83 c4 10             	add    $0x10,%esp
  return i;
801047f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801047f5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801047f8:	c9                   	leave  
801047f9:	c3                   	ret    

801047fa <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
801047fa:	55                   	push   %ebp
801047fb:	89 e5                	mov    %esp,%ebp
801047fd:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104800:	9c                   	pushf  
80104801:	58                   	pop    %eax
80104802:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80104805:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104808:	c9                   	leave  
80104809:	c3                   	ret    

8010480a <sti>:
  asm volatile("cli");
}

static inline void
sti(void)
{
8010480a:	55                   	push   %ebp
8010480b:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
8010480d:	fb                   	sti    
}
8010480e:	90                   	nop
8010480f:	5d                   	pop    %ebp
80104810:	c3                   	ret    

80104811 <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
80104811:	55                   	push   %ebp
80104812:	89 e5                	mov    %esp,%ebp
80104814:	83 ec 08             	sub    $0x8,%esp
  initlock(&ptable.lock, "ptable");
80104817:	83 ec 08             	sub    $0x8,%esp
8010481a:	68 51 8c 10 80       	push   $0x80108c51
8010481f:	68 40 2c 11 80       	push   $0x80112c40
80104824:	e8 72 0b 00 00       	call   8010539b <initlock>
80104829:	83 c4 10             	add    $0x10,%esp
}
8010482c:	90                   	nop
8010482d:	c9                   	leave  
8010482e:	c3                   	ret    

8010482f <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
8010482f:	55                   	push   %ebp
80104830:	89 e5                	mov    %esp,%ebp
80104832:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
80104835:	83 ec 0c             	sub    $0xc,%esp
80104838:	68 40 2c 11 80       	push   $0x80112c40
8010483d:	e8 7b 0b 00 00       	call   801053bd <acquire>
80104842:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104845:	c7 45 f4 74 2c 11 80 	movl   $0x80112c74,-0xc(%ebp)
8010484c:	eb 0e                	jmp    8010485c <allocproc+0x2d>
    if(p->state == UNUSED)
8010484e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104851:	8b 40 0c             	mov    0xc(%eax),%eax
80104854:	85 c0                	test   %eax,%eax
80104856:	74 27                	je     8010487f <allocproc+0x50>
{
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104858:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
8010485c:	81 7d f4 74 4b 11 80 	cmpl   $0x80114b74,-0xc(%ebp)
80104863:	72 e9                	jb     8010484e <allocproc+0x1f>
    if(p->state == UNUSED)
      goto found;
  release(&ptable.lock);
80104865:	83 ec 0c             	sub    $0xc,%esp
80104868:	68 40 2c 11 80       	push   $0x80112c40
8010486d:	e8 b2 0b 00 00       	call   80105424 <release>
80104872:	83 c4 10             	add    $0x10,%esp
  return 0;
80104875:	b8 00 00 00 00       	mov    $0x0,%eax
8010487a:	e9 b4 00 00 00       	jmp    80104933 <allocproc+0x104>
  char *sp;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
    if(p->state == UNUSED)
      goto found;
8010487f:	90                   	nop
  release(&ptable.lock);
  return 0;

found:
  p->state = EMBRYO;
80104880:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104883:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
8010488a:	a1 04 b0 10 80       	mov    0x8010b004,%eax
8010488f:	8d 50 01             	lea    0x1(%eax),%edx
80104892:	89 15 04 b0 10 80    	mov    %edx,0x8010b004
80104898:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010489b:	89 42 10             	mov    %eax,0x10(%edx)
  release(&ptable.lock);
8010489e:	83 ec 0c             	sub    $0xc,%esp
801048a1:	68 40 2c 11 80       	push   $0x80112c40
801048a6:	e8 79 0b 00 00       	call   80105424 <release>
801048ab:	83 c4 10             	add    $0x10,%esp

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
801048ae:	e8 4b e7 ff ff       	call   80102ffe <kalloc>
801048b3:	89 c2                	mov    %eax,%edx
801048b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048b8:	89 50 08             	mov    %edx,0x8(%eax)
801048bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048be:	8b 40 08             	mov    0x8(%eax),%eax
801048c1:	85 c0                	test   %eax,%eax
801048c3:	75 11                	jne    801048d6 <allocproc+0xa7>
    p->state = UNUSED;
801048c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048c8:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
801048cf:	b8 00 00 00 00       	mov    $0x0,%eax
801048d4:	eb 5d                	jmp    80104933 <allocproc+0x104>
  }
  sp = p->kstack + KSTACKSIZE;
801048d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048d9:	8b 40 08             	mov    0x8(%eax),%eax
801048dc:	05 00 10 00 00       	add    $0x1000,%eax
801048e1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  // Leave room for trap frame.
  sp -= sizeof *p->tf;
801048e4:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
801048e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048eb:	8b 55 f0             	mov    -0x10(%ebp),%edx
801048ee:	89 50 18             	mov    %edx,0x18(%eax)
  
  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
801048f1:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
801048f5:	ba 06 6a 10 80       	mov    $0x80106a06,%edx
801048fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
801048fd:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
801048ff:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
80104903:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104906:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104909:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
8010490c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010490f:	8b 40 1c             	mov    0x1c(%eax),%eax
80104912:	83 ec 04             	sub    $0x4,%esp
80104915:	6a 14                	push   $0x14
80104917:	6a 00                	push   $0x0
80104919:	50                   	push   %eax
8010491a:	e8 01 0d 00 00       	call   80105620 <memset>
8010491f:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
80104922:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104925:	8b 40 1c             	mov    0x1c(%eax),%eax
80104928:	ba 7c 50 10 80       	mov    $0x8010507c,%edx
8010492d:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
80104930:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104933:	c9                   	leave  
80104934:	c3                   	ret    

80104935 <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
80104935:	55                   	push   %ebp
80104936:	89 e5                	mov    %esp,%ebp
80104938:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];
  
  p = allocproc();
8010493b:	e8 ef fe ff ff       	call   8010482f <allocproc>
80104940:	89 45 f4             	mov    %eax,-0xc(%ebp)
  initproc = p;
80104943:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104946:	a3 48 b6 10 80       	mov    %eax,0x8010b648
  if((p->pgdir = setupkvm()) == 0)
8010494b:	e8 7b 37 00 00       	call   801080cb <setupkvm>
80104950:	89 c2                	mov    %eax,%edx
80104952:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104955:	89 50 04             	mov    %edx,0x4(%eax)
80104958:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010495b:	8b 40 04             	mov    0x4(%eax),%eax
8010495e:	85 c0                	test   %eax,%eax
80104960:	75 0d                	jne    8010496f <userinit+0x3a>
    panic("userinit: out of memory?");
80104962:	83 ec 0c             	sub    $0xc,%esp
80104965:	68 58 8c 10 80       	push   $0x80108c58
8010496a:	e8 f7 bb ff ff       	call   80100566 <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
8010496f:	ba 2c 00 00 00       	mov    $0x2c,%edx
80104974:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104977:	8b 40 04             	mov    0x4(%eax),%eax
8010497a:	83 ec 04             	sub    $0x4,%esp
8010497d:	52                   	push   %edx
8010497e:	68 e0 b4 10 80       	push   $0x8010b4e0
80104983:	50                   	push   %eax
80104984:	e8 9c 39 00 00       	call   80108325 <inituvm>
80104989:	83 c4 10             	add    $0x10,%esp
  p->sz = PGSIZE;
8010498c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010498f:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
80104995:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104998:	8b 40 18             	mov    0x18(%eax),%eax
8010499b:	83 ec 04             	sub    $0x4,%esp
8010499e:	6a 4c                	push   $0x4c
801049a0:	6a 00                	push   $0x0
801049a2:	50                   	push   %eax
801049a3:	e8 78 0c 00 00       	call   80105620 <memset>
801049a8:	83 c4 10             	add    $0x10,%esp
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
801049ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049ae:	8b 40 18             	mov    0x18(%eax),%eax
801049b1:	66 c7 40 3c 23 00    	movw   $0x23,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
801049b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049ba:	8b 40 18             	mov    0x18(%eax),%eax
801049bd:	66 c7 40 2c 2b 00    	movw   $0x2b,0x2c(%eax)
  p->tf->es = p->tf->ds;
801049c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049c6:	8b 40 18             	mov    0x18(%eax),%eax
801049c9:	8b 55 f4             	mov    -0xc(%ebp),%edx
801049cc:	8b 52 18             	mov    0x18(%edx),%edx
801049cf:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
801049d3:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
801049d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049da:	8b 40 18             	mov    0x18(%eax),%eax
801049dd:	8b 55 f4             	mov    -0xc(%ebp),%edx
801049e0:	8b 52 18             	mov    0x18(%edx),%edx
801049e3:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
801049e7:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
801049eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049ee:	8b 40 18             	mov    0x18(%eax),%eax
801049f1:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
801049f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049fb:	8b 40 18             	mov    0x18(%eax),%eax
801049fe:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
80104a05:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a08:	8b 40 18             	mov    0x18(%eax),%eax
80104a0b:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
80104a12:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a15:	83 c0 6c             	add    $0x6c,%eax
80104a18:	83 ec 04             	sub    $0x4,%esp
80104a1b:	6a 10                	push   $0x10
80104a1d:	68 71 8c 10 80       	push   $0x80108c71
80104a22:	50                   	push   %eax
80104a23:	e8 fb 0d 00 00       	call   80105823 <safestrcpy>
80104a28:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
80104a2b:	83 ec 0c             	sub    $0xc,%esp
80104a2e:	68 7a 8c 10 80       	push   $0x80108c7a
80104a33:	e8 88 de ff ff       	call   801028c0 <namei>
80104a38:	83 c4 10             	add    $0x10,%esp
80104a3b:	89 c2                	mov    %eax,%edx
80104a3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a40:	89 50 68             	mov    %edx,0x68(%eax)

  p->state = RUNNABLE;
80104a43:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a46:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
}
80104a4d:	90                   	nop
80104a4e:	c9                   	leave  
80104a4f:	c3                   	ret    

80104a50 <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
80104a50:	55                   	push   %ebp
80104a51:	89 e5                	mov    %esp,%ebp
80104a53:	83 ec 18             	sub    $0x18,%esp
  uint sz;
  
  sz = proc->sz;
80104a56:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a5c:	8b 00                	mov    (%eax),%eax
80104a5e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
80104a61:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104a65:	7e 31                	jle    80104a98 <growproc+0x48>
    if((sz = allocuvm(proc->pgdir, sz, sz + n)) == 0)
80104a67:	8b 55 08             	mov    0x8(%ebp),%edx
80104a6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a6d:	01 c2                	add    %eax,%edx
80104a6f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a75:	8b 40 04             	mov    0x4(%eax),%eax
80104a78:	83 ec 04             	sub    $0x4,%esp
80104a7b:	52                   	push   %edx
80104a7c:	ff 75 f4             	pushl  -0xc(%ebp)
80104a7f:	50                   	push   %eax
80104a80:	e8 ed 39 00 00       	call   80108472 <allocuvm>
80104a85:	83 c4 10             	add    $0x10,%esp
80104a88:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104a8b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104a8f:	75 3e                	jne    80104acf <growproc+0x7f>
      return -1;
80104a91:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104a96:	eb 59                	jmp    80104af1 <growproc+0xa1>
  } else if(n < 0){
80104a98:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104a9c:	79 31                	jns    80104acf <growproc+0x7f>
    if((sz = deallocuvm(proc->pgdir, sz, sz + n)) == 0)
80104a9e:	8b 55 08             	mov    0x8(%ebp),%edx
80104aa1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104aa4:	01 c2                	add    %eax,%edx
80104aa6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104aac:	8b 40 04             	mov    0x4(%eax),%eax
80104aaf:	83 ec 04             	sub    $0x4,%esp
80104ab2:	52                   	push   %edx
80104ab3:	ff 75 f4             	pushl  -0xc(%ebp)
80104ab6:	50                   	push   %eax
80104ab7:	e8 7f 3a 00 00       	call   8010853b <deallocuvm>
80104abc:	83 c4 10             	add    $0x10,%esp
80104abf:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104ac2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104ac6:	75 07                	jne    80104acf <growproc+0x7f>
      return -1;
80104ac8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104acd:	eb 22                	jmp    80104af1 <growproc+0xa1>
  }
  proc->sz = sz;
80104acf:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104ad5:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104ad8:	89 10                	mov    %edx,(%eax)
  switchuvm(proc);
80104ada:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104ae0:	83 ec 0c             	sub    $0xc,%esp
80104ae3:	50                   	push   %eax
80104ae4:	e8 c9 36 00 00       	call   801081b2 <switchuvm>
80104ae9:	83 c4 10             	add    $0x10,%esp
  return 0;
80104aec:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104af1:	c9                   	leave  
80104af2:	c3                   	ret    

80104af3 <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
80104af3:	55                   	push   %ebp
80104af4:	89 e5                	mov    %esp,%ebp
80104af6:	57                   	push   %edi
80104af7:	56                   	push   %esi
80104af8:	53                   	push   %ebx
80104af9:	83 ec 1c             	sub    $0x1c,%esp
  int i, pid;
  struct proc *np;

  // Allocate process.
  if((np = allocproc()) == 0)
80104afc:	e8 2e fd ff ff       	call   8010482f <allocproc>
80104b01:	89 45 e0             	mov    %eax,-0x20(%ebp)
80104b04:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80104b08:	75 0a                	jne    80104b14 <fork+0x21>
    return -1;
80104b0a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104b0f:	e9 68 01 00 00       	jmp    80104c7c <fork+0x189>

  // Copy process state from p.
  if((np->pgdir = copyuvm(proc->pgdir, proc->sz)) == 0){
80104b14:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b1a:	8b 10                	mov    (%eax),%edx
80104b1c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b22:	8b 40 04             	mov    0x4(%eax),%eax
80104b25:	83 ec 08             	sub    $0x8,%esp
80104b28:	52                   	push   %edx
80104b29:	50                   	push   %eax
80104b2a:	e8 aa 3b 00 00       	call   801086d9 <copyuvm>
80104b2f:	83 c4 10             	add    $0x10,%esp
80104b32:	89 c2                	mov    %eax,%edx
80104b34:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104b37:	89 50 04             	mov    %edx,0x4(%eax)
80104b3a:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104b3d:	8b 40 04             	mov    0x4(%eax),%eax
80104b40:	85 c0                	test   %eax,%eax
80104b42:	75 30                	jne    80104b74 <fork+0x81>
    kfree(np->kstack);
80104b44:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104b47:	8b 40 08             	mov    0x8(%eax),%eax
80104b4a:	83 ec 0c             	sub    $0xc,%esp
80104b4d:	50                   	push   %eax
80104b4e:	e8 0e e4 ff ff       	call   80102f61 <kfree>
80104b53:	83 c4 10             	add    $0x10,%esp
    np->kstack = 0;
80104b56:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104b59:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
80104b60:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104b63:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
80104b6a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104b6f:	e9 08 01 00 00       	jmp    80104c7c <fork+0x189>
  }
  np->sz = proc->sz;
80104b74:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b7a:	8b 10                	mov    (%eax),%edx
80104b7c:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104b7f:	89 10                	mov    %edx,(%eax)
  np->parent = proc;
80104b81:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104b88:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104b8b:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *proc->tf;
80104b8e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104b91:	8b 50 18             	mov    0x18(%eax),%edx
80104b94:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b9a:	8b 40 18             	mov    0x18(%eax),%eax
80104b9d:	89 c3                	mov    %eax,%ebx
80104b9f:	b8 13 00 00 00       	mov    $0x13,%eax
80104ba4:	89 d7                	mov    %edx,%edi
80104ba6:	89 de                	mov    %ebx,%esi
80104ba8:	89 c1                	mov    %eax,%ecx
80104baa:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
80104bac:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104baf:	8b 40 18             	mov    0x18(%eax),%eax
80104bb2:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
80104bb9:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80104bc0:	eb 43                	jmp    80104c05 <fork+0x112>
    if(proc->ofile[i])
80104bc2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104bc8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104bcb:	83 c2 08             	add    $0x8,%edx
80104bce:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104bd2:	85 c0                	test   %eax,%eax
80104bd4:	74 2b                	je     80104c01 <fork+0x10e>
      np->ofile[i] = filedup(proc->ofile[i]);
80104bd6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104bdc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104bdf:	83 c2 08             	add    $0x8,%edx
80104be2:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104be6:	83 ec 0c             	sub    $0xc,%esp
80104be9:	50                   	push   %eax
80104bea:	e8 11 c4 ff ff       	call   80101000 <filedup>
80104bef:	83 c4 10             	add    $0x10,%esp
80104bf2:	89 c1                	mov    %eax,%ecx
80104bf4:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104bf7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104bfa:	83 c2 08             	add    $0x8,%edx
80104bfd:	89 4c 90 08          	mov    %ecx,0x8(%eax,%edx,4)
  *np->tf = *proc->tf;

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
80104c01:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80104c05:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
80104c09:	7e b7                	jle    80104bc2 <fork+0xcf>
    if(proc->ofile[i])
      np->ofile[i] = filedup(proc->ofile[i]);
  np->cwd = idup(proc->cwd);
80104c0b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104c11:	8b 40 68             	mov    0x68(%eax),%eax
80104c14:	83 ec 0c             	sub    $0xc,%esp
80104c17:	50                   	push   %eax
80104c18:	e8 0d d0 ff ff       	call   80101c2a <idup>
80104c1d:	83 c4 10             	add    $0x10,%esp
80104c20:	89 c2                	mov    %eax,%edx
80104c22:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104c25:	89 50 68             	mov    %edx,0x68(%eax)

  safestrcpy(np->name, proc->name, sizeof(proc->name));
80104c28:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104c2e:	8d 50 6c             	lea    0x6c(%eax),%edx
80104c31:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104c34:	83 c0 6c             	add    $0x6c,%eax
80104c37:	83 ec 04             	sub    $0x4,%esp
80104c3a:	6a 10                	push   $0x10
80104c3c:	52                   	push   %edx
80104c3d:	50                   	push   %eax
80104c3e:	e8 e0 0b 00 00       	call   80105823 <safestrcpy>
80104c43:	83 c4 10             	add    $0x10,%esp
 
  pid = np->pid;
80104c46:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104c49:	8b 40 10             	mov    0x10(%eax),%eax
80104c4c:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // lock to force the compiler to emit the np->state write last.
  acquire(&ptable.lock);
80104c4f:	83 ec 0c             	sub    $0xc,%esp
80104c52:	68 40 2c 11 80       	push   $0x80112c40
80104c57:	e8 61 07 00 00       	call   801053bd <acquire>
80104c5c:	83 c4 10             	add    $0x10,%esp
  np->state = RUNNABLE;
80104c5f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104c62:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  release(&ptable.lock);
80104c69:	83 ec 0c             	sub    $0xc,%esp
80104c6c:	68 40 2c 11 80       	push   $0x80112c40
80104c71:	e8 ae 07 00 00       	call   80105424 <release>
80104c76:	83 c4 10             	add    $0x10,%esp
  
  return pid;
80104c79:	8b 45 dc             	mov    -0x24(%ebp),%eax
}
80104c7c:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104c7f:	5b                   	pop    %ebx
80104c80:	5e                   	pop    %esi
80104c81:	5f                   	pop    %edi
80104c82:	5d                   	pop    %ebp
80104c83:	c3                   	ret    

80104c84 <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
80104c84:	55                   	push   %ebp
80104c85:	89 e5                	mov    %esp,%ebp
80104c87:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int fd;

  if(proc == initproc)
80104c8a:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104c91:	a1 48 b6 10 80       	mov    0x8010b648,%eax
80104c96:	39 c2                	cmp    %eax,%edx
80104c98:	75 0d                	jne    80104ca7 <exit+0x23>
    panic("init exiting");
80104c9a:	83 ec 0c             	sub    $0xc,%esp
80104c9d:	68 7c 8c 10 80       	push   $0x80108c7c
80104ca2:	e8 bf b8 ff ff       	call   80100566 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104ca7:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80104cae:	eb 48                	jmp    80104cf8 <exit+0x74>
    if(proc->ofile[fd]){
80104cb0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104cb6:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104cb9:	83 c2 08             	add    $0x8,%edx
80104cbc:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104cc0:	85 c0                	test   %eax,%eax
80104cc2:	74 30                	je     80104cf4 <exit+0x70>
      fileclose(proc->ofile[fd]);
80104cc4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104cca:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104ccd:	83 c2 08             	add    $0x8,%edx
80104cd0:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104cd4:	83 ec 0c             	sub    $0xc,%esp
80104cd7:	50                   	push   %eax
80104cd8:	e8 74 c3 ff ff       	call   80101051 <fileclose>
80104cdd:	83 c4 10             	add    $0x10,%esp
      proc->ofile[fd] = 0;
80104ce0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104ce6:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104ce9:	83 c2 08             	add    $0x8,%edx
80104cec:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80104cf3:	00 

  if(proc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104cf4:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80104cf8:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
80104cfc:	7e b2                	jle    80104cb0 <exit+0x2c>
      fileclose(proc->ofile[fd]);
      proc->ofile[fd] = 0;
    }
  }

  begin_op();
80104cfe:	e8 06 ec ff ff       	call   80103909 <begin_op>
  iput(proc->cwd);
80104d03:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d09:	8b 40 68             	mov    0x68(%eax),%eax
80104d0c:	83 ec 0c             	sub    $0xc,%esp
80104d0f:	50                   	push   %eax
80104d10:	e8 62 d1 ff ff       	call   80101e77 <iput>
80104d15:	83 c4 10             	add    $0x10,%esp
  end_op();
80104d18:	e8 78 ec ff ff       	call   80103995 <end_op>
  proc->cwd = 0;
80104d1d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d23:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
80104d2a:	83 ec 0c             	sub    $0xc,%esp
80104d2d:	68 40 2c 11 80       	push   $0x80112c40
80104d32:	e8 86 06 00 00       	call   801053bd <acquire>
80104d37:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);
80104d3a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d40:	8b 40 14             	mov    0x14(%eax),%eax
80104d43:	83 ec 0c             	sub    $0xc,%esp
80104d46:	50                   	push   %eax
80104d47:	e8 24 04 00 00       	call   80105170 <wakeup1>
80104d4c:	83 c4 10             	add    $0x10,%esp

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104d4f:	c7 45 f4 74 2c 11 80 	movl   $0x80112c74,-0xc(%ebp)
80104d56:	eb 3c                	jmp    80104d94 <exit+0x110>
    if(p->parent == proc){
80104d58:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d5b:	8b 50 14             	mov    0x14(%eax),%edx
80104d5e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d64:	39 c2                	cmp    %eax,%edx
80104d66:	75 28                	jne    80104d90 <exit+0x10c>
      p->parent = initproc;
80104d68:	8b 15 48 b6 10 80    	mov    0x8010b648,%edx
80104d6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d71:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
80104d74:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d77:	8b 40 0c             	mov    0xc(%eax),%eax
80104d7a:	83 f8 05             	cmp    $0x5,%eax
80104d7d:	75 11                	jne    80104d90 <exit+0x10c>
        wakeup1(initproc);
80104d7f:	a1 48 b6 10 80       	mov    0x8010b648,%eax
80104d84:	83 ec 0c             	sub    $0xc,%esp
80104d87:	50                   	push   %eax
80104d88:	e8 e3 03 00 00       	call   80105170 <wakeup1>
80104d8d:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104d90:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80104d94:	81 7d f4 74 4b 11 80 	cmpl   $0x80114b74,-0xc(%ebp)
80104d9b:	72 bb                	jb     80104d58 <exit+0xd4>
        wakeup1(initproc);
    }
  }

  // Jump into the scheduler, never to return.
  proc->state = ZOMBIE;
80104d9d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104da3:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
80104daa:	e8 d6 01 00 00       	call   80104f85 <sched>
  panic("zombie exit");
80104daf:	83 ec 0c             	sub    $0xc,%esp
80104db2:	68 89 8c 10 80       	push   $0x80108c89
80104db7:	e8 aa b7 ff ff       	call   80100566 <panic>

80104dbc <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
80104dbc:	55                   	push   %ebp
80104dbd:	89 e5                	mov    %esp,%ebp
80104dbf:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int havekids, pid;

  acquire(&ptable.lock);
80104dc2:	83 ec 0c             	sub    $0xc,%esp
80104dc5:	68 40 2c 11 80       	push   $0x80112c40
80104dca:	e8 ee 05 00 00       	call   801053bd <acquire>
80104dcf:	83 c4 10             	add    $0x10,%esp
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
80104dd2:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104dd9:	c7 45 f4 74 2c 11 80 	movl   $0x80112c74,-0xc(%ebp)
80104de0:	e9 a6 00 00 00       	jmp    80104e8b <wait+0xcf>
      if(p->parent != proc)
80104de5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104de8:	8b 50 14             	mov    0x14(%eax),%edx
80104deb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104df1:	39 c2                	cmp    %eax,%edx
80104df3:	0f 85 8d 00 00 00    	jne    80104e86 <wait+0xca>
        continue;
      havekids = 1;
80104df9:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
80104e00:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e03:	8b 40 0c             	mov    0xc(%eax),%eax
80104e06:	83 f8 05             	cmp    $0x5,%eax
80104e09:	75 7c                	jne    80104e87 <wait+0xcb>
        // Found one.
        pid = p->pid;
80104e0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e0e:	8b 40 10             	mov    0x10(%eax),%eax
80104e11:	89 45 ec             	mov    %eax,-0x14(%ebp)
        kfree(p->kstack);
80104e14:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e17:	8b 40 08             	mov    0x8(%eax),%eax
80104e1a:	83 ec 0c             	sub    $0xc,%esp
80104e1d:	50                   	push   %eax
80104e1e:	e8 3e e1 ff ff       	call   80102f61 <kfree>
80104e23:	83 c4 10             	add    $0x10,%esp
        p->kstack = 0;
80104e26:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e29:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
80104e30:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e33:	8b 40 04             	mov    0x4(%eax),%eax
80104e36:	83 ec 0c             	sub    $0xc,%esp
80104e39:	50                   	push   %eax
80104e3a:	e8 b9 37 00 00       	call   801085f8 <freevm>
80104e3f:	83 c4 10             	add    $0x10,%esp
        p->state = UNUSED;
80104e42:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e45:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        p->pid = 0;
80104e4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e4f:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
80104e56:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e59:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
80104e60:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e63:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
80104e67:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e6a:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        release(&ptable.lock);
80104e71:	83 ec 0c             	sub    $0xc,%esp
80104e74:	68 40 2c 11 80       	push   $0x80112c40
80104e79:	e8 a6 05 00 00       	call   80105424 <release>
80104e7e:	83 c4 10             	add    $0x10,%esp
        return pid;
80104e81:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104e84:	eb 58                	jmp    80104ede <wait+0x122>
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->parent != proc)
        continue;
80104e86:	90                   	nop

  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104e87:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80104e8b:	81 7d f4 74 4b 11 80 	cmpl   $0x80114b74,-0xc(%ebp)
80104e92:	0f 82 4d ff ff ff    	jb     80104de5 <wait+0x29>
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
80104e98:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104e9c:	74 0d                	je     80104eab <wait+0xef>
80104e9e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104ea4:	8b 40 24             	mov    0x24(%eax),%eax
80104ea7:	85 c0                	test   %eax,%eax
80104ea9:	74 17                	je     80104ec2 <wait+0x106>
      release(&ptable.lock);
80104eab:	83 ec 0c             	sub    $0xc,%esp
80104eae:	68 40 2c 11 80       	push   $0x80112c40
80104eb3:	e8 6c 05 00 00       	call   80105424 <release>
80104eb8:	83 c4 10             	add    $0x10,%esp
      return -1;
80104ebb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104ec0:	eb 1c                	jmp    80104ede <wait+0x122>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
80104ec2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104ec8:	83 ec 08             	sub    $0x8,%esp
80104ecb:	68 40 2c 11 80       	push   $0x80112c40
80104ed0:	50                   	push   %eax
80104ed1:	e8 ee 01 00 00       	call   801050c4 <sleep>
80104ed6:	83 c4 10             	add    $0x10,%esp
  }
80104ed9:	e9 f4 fe ff ff       	jmp    80104dd2 <wait+0x16>
}
80104ede:	c9                   	leave  
80104edf:	c3                   	ret    

80104ee0 <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
80104ee0:	55                   	push   %ebp
80104ee1:	89 e5                	mov    %esp,%ebp
80104ee3:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  for(;;){
    // Enable interrupts on this processor.
    sti();
80104ee6:	e8 1f f9 ff ff       	call   8010480a <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
80104eeb:	83 ec 0c             	sub    $0xc,%esp
80104eee:	68 40 2c 11 80       	push   $0x80112c40
80104ef3:	e8 c5 04 00 00       	call   801053bd <acquire>
80104ef8:	83 c4 10             	add    $0x10,%esp
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104efb:	c7 45 f4 74 2c 11 80 	movl   $0x80112c74,-0xc(%ebp)
80104f02:	eb 63                	jmp    80104f67 <scheduler+0x87>
      if(p->state != RUNNABLE)
80104f04:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f07:	8b 40 0c             	mov    0xc(%eax),%eax
80104f0a:	83 f8 03             	cmp    $0x3,%eax
80104f0d:	75 53                	jne    80104f62 <scheduler+0x82>
        continue;

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      proc = p;
80104f0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f12:	65 a3 04 00 00 00    	mov    %eax,%gs:0x4
      switchuvm(p);
80104f18:	83 ec 0c             	sub    $0xc,%esp
80104f1b:	ff 75 f4             	pushl  -0xc(%ebp)
80104f1e:	e8 8f 32 00 00       	call   801081b2 <switchuvm>
80104f23:	83 c4 10             	add    $0x10,%esp
      p->state = RUNNING;
80104f26:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f29:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)
      swtch(&cpu->scheduler, proc->context);
80104f30:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104f36:	8b 40 1c             	mov    0x1c(%eax),%eax
80104f39:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80104f40:	83 c2 04             	add    $0x4,%edx
80104f43:	83 ec 08             	sub    $0x8,%esp
80104f46:	50                   	push   %eax
80104f47:	52                   	push   %edx
80104f48:	e8 47 09 00 00       	call   80105894 <swtch>
80104f4d:	83 c4 10             	add    $0x10,%esp
      switchkvm();
80104f50:	e8 40 32 00 00       	call   80108195 <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
80104f55:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80104f5c:	00 00 00 00 
80104f60:	eb 01                	jmp    80104f63 <scheduler+0x83>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->state != RUNNABLE)
        continue;
80104f62:	90                   	nop
    // Enable interrupts on this processor.
    sti();

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104f63:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80104f67:	81 7d f4 74 4b 11 80 	cmpl   $0x80114b74,-0xc(%ebp)
80104f6e:	72 94                	jb     80104f04 <scheduler+0x24>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
    }
    release(&ptable.lock);
80104f70:	83 ec 0c             	sub    $0xc,%esp
80104f73:	68 40 2c 11 80       	push   $0x80112c40
80104f78:	e8 a7 04 00 00       	call   80105424 <release>
80104f7d:	83 c4 10             	add    $0x10,%esp

  }
80104f80:	e9 61 ff ff ff       	jmp    80104ee6 <scheduler+0x6>

80104f85 <sched>:

// Enter scheduler.  Must hold only ptable.lock
// and have changed proc->state.
void
sched(void)
{
80104f85:	55                   	push   %ebp
80104f86:	89 e5                	mov    %esp,%ebp
80104f88:	83 ec 18             	sub    $0x18,%esp
  int intena;

  if(!holding(&ptable.lock))
80104f8b:	83 ec 0c             	sub    $0xc,%esp
80104f8e:	68 40 2c 11 80       	push   $0x80112c40
80104f93:	e8 58 05 00 00       	call   801054f0 <holding>
80104f98:	83 c4 10             	add    $0x10,%esp
80104f9b:	85 c0                	test   %eax,%eax
80104f9d:	75 0d                	jne    80104fac <sched+0x27>
    panic("sched ptable.lock");
80104f9f:	83 ec 0c             	sub    $0xc,%esp
80104fa2:	68 95 8c 10 80       	push   $0x80108c95
80104fa7:	e8 ba b5 ff ff       	call   80100566 <panic>
  if(cpu->ncli != 1)
80104fac:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104fb2:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80104fb8:	83 f8 01             	cmp    $0x1,%eax
80104fbb:	74 0d                	je     80104fca <sched+0x45>
    panic("sched locks");
80104fbd:	83 ec 0c             	sub    $0xc,%esp
80104fc0:	68 a7 8c 10 80       	push   $0x80108ca7
80104fc5:	e8 9c b5 ff ff       	call   80100566 <panic>
  if(proc->state == RUNNING)
80104fca:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104fd0:	8b 40 0c             	mov    0xc(%eax),%eax
80104fd3:	83 f8 04             	cmp    $0x4,%eax
80104fd6:	75 0d                	jne    80104fe5 <sched+0x60>
    panic("sched running");
80104fd8:	83 ec 0c             	sub    $0xc,%esp
80104fdb:	68 b3 8c 10 80       	push   $0x80108cb3
80104fe0:	e8 81 b5 ff ff       	call   80100566 <panic>
  if(readeflags()&FL_IF)
80104fe5:	e8 10 f8 ff ff       	call   801047fa <readeflags>
80104fea:	25 00 02 00 00       	and    $0x200,%eax
80104fef:	85 c0                	test   %eax,%eax
80104ff1:	74 0d                	je     80105000 <sched+0x7b>
    panic("sched interruptible");
80104ff3:	83 ec 0c             	sub    $0xc,%esp
80104ff6:	68 c1 8c 10 80       	push   $0x80108cc1
80104ffb:	e8 66 b5 ff ff       	call   80100566 <panic>
  intena = cpu->intena;
80105000:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105006:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
8010500c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  swtch(&proc->context, cpu->scheduler);
8010500f:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105015:	8b 40 04             	mov    0x4(%eax),%eax
80105018:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
8010501f:	83 c2 1c             	add    $0x1c,%edx
80105022:	83 ec 08             	sub    $0x8,%esp
80105025:	50                   	push   %eax
80105026:	52                   	push   %edx
80105027:	e8 68 08 00 00       	call   80105894 <swtch>
8010502c:	83 c4 10             	add    $0x10,%esp
  cpu->intena = intena;
8010502f:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105035:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105038:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
8010503e:	90                   	nop
8010503f:	c9                   	leave  
80105040:	c3                   	ret    

80105041 <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
80105041:	55                   	push   %ebp
80105042:	89 e5                	mov    %esp,%ebp
80105044:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80105047:	83 ec 0c             	sub    $0xc,%esp
8010504a:	68 40 2c 11 80       	push   $0x80112c40
8010504f:	e8 69 03 00 00       	call   801053bd <acquire>
80105054:	83 c4 10             	add    $0x10,%esp
  proc->state = RUNNABLE;
80105057:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010505d:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80105064:	e8 1c ff ff ff       	call   80104f85 <sched>
  release(&ptable.lock);
80105069:	83 ec 0c             	sub    $0xc,%esp
8010506c:	68 40 2c 11 80       	push   $0x80112c40
80105071:	e8 ae 03 00 00       	call   80105424 <release>
80105076:	83 c4 10             	add    $0x10,%esp
}
80105079:	90                   	nop
8010507a:	c9                   	leave  
8010507b:	c3                   	ret    

8010507c <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
8010507c:	55                   	push   %ebp
8010507d:	89 e5                	mov    %esp,%ebp
8010507f:	83 ec 08             	sub    $0x8,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80105082:	83 ec 0c             	sub    $0xc,%esp
80105085:	68 40 2c 11 80       	push   $0x80112c40
8010508a:	e8 95 03 00 00       	call   80105424 <release>
8010508f:	83 c4 10             	add    $0x10,%esp

  if (first) {
80105092:	a1 08 b0 10 80       	mov    0x8010b008,%eax
80105097:	85 c0                	test   %eax,%eax
80105099:	74 26                	je     801050c1 <forkret+0x45>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot 
    // be run from main().
    first = 0;
8010509b:	c7 05 08 b0 10 80 00 	movl   $0x0,0x8010b008
801050a2:	00 00 00 
    iinit(ROOTDEV);
801050a5:	83 ec 0c             	sub    $0xc,%esp
801050a8:	6a 00                	push   $0x0
801050aa:	e8 68 c6 ff ff       	call   80101717 <iinit>
801050af:	83 c4 10             	add    $0x10,%esp
    initlog(ROOTDEV,0);
801050b2:	83 ec 08             	sub    $0x8,%esp
801050b5:	6a 00                	push   $0x0
801050b7:	6a 00                	push   $0x0
801050b9:	e8 09 e6 ff ff       	call   801036c7 <initlog>
801050be:	83 c4 10             	add    $0x10,%esp
  }
  
  // Return to "caller", actually trapret (see allocproc).
}
801050c1:	90                   	nop
801050c2:	c9                   	leave  
801050c3:	c3                   	ret    

801050c4 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
801050c4:	55                   	push   %ebp
801050c5:	89 e5                	mov    %esp,%ebp
801050c7:	83 ec 08             	sub    $0x8,%esp
  if(proc == 0)
801050ca:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801050d0:	85 c0                	test   %eax,%eax
801050d2:	75 0d                	jne    801050e1 <sleep+0x1d>
    panic("sleep");
801050d4:	83 ec 0c             	sub    $0xc,%esp
801050d7:	68 d5 8c 10 80       	push   $0x80108cd5
801050dc:	e8 85 b4 ff ff       	call   80100566 <panic>

  if(lk == 0)
801050e1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801050e5:	75 0d                	jne    801050f4 <sleep+0x30>
    panic("sleep without lk");
801050e7:	83 ec 0c             	sub    $0xc,%esp
801050ea:	68 db 8c 10 80       	push   $0x80108cdb
801050ef:	e8 72 b4 ff ff       	call   80100566 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
801050f4:	81 7d 0c 40 2c 11 80 	cmpl   $0x80112c40,0xc(%ebp)
801050fb:	74 1e                	je     8010511b <sleep+0x57>
    acquire(&ptable.lock);  //DOC: sleeplock1
801050fd:	83 ec 0c             	sub    $0xc,%esp
80105100:	68 40 2c 11 80       	push   $0x80112c40
80105105:	e8 b3 02 00 00       	call   801053bd <acquire>
8010510a:	83 c4 10             	add    $0x10,%esp
    release(lk);
8010510d:	83 ec 0c             	sub    $0xc,%esp
80105110:	ff 75 0c             	pushl  0xc(%ebp)
80105113:	e8 0c 03 00 00       	call   80105424 <release>
80105118:	83 c4 10             	add    $0x10,%esp
  }

  // Go to sleep.
  proc->chan = chan;
8010511b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105121:	8b 55 08             	mov    0x8(%ebp),%edx
80105124:	89 50 20             	mov    %edx,0x20(%eax)
  proc->state = SLEEPING;
80105127:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010512d:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)
  sched();
80105134:	e8 4c fe ff ff       	call   80104f85 <sched>

  // Tidy up.
  proc->chan = 0;
80105139:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010513f:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
80105146:	81 7d 0c 40 2c 11 80 	cmpl   $0x80112c40,0xc(%ebp)
8010514d:	74 1e                	je     8010516d <sleep+0xa9>
    release(&ptable.lock);
8010514f:	83 ec 0c             	sub    $0xc,%esp
80105152:	68 40 2c 11 80       	push   $0x80112c40
80105157:	e8 c8 02 00 00       	call   80105424 <release>
8010515c:	83 c4 10             	add    $0x10,%esp
    acquire(lk);
8010515f:	83 ec 0c             	sub    $0xc,%esp
80105162:	ff 75 0c             	pushl  0xc(%ebp)
80105165:	e8 53 02 00 00       	call   801053bd <acquire>
8010516a:	83 c4 10             	add    $0x10,%esp
  }
}
8010516d:	90                   	nop
8010516e:	c9                   	leave  
8010516f:	c3                   	ret    

80105170 <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80105170:	55                   	push   %ebp
80105171:	89 e5                	mov    %esp,%ebp
80105173:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80105176:	c7 45 fc 74 2c 11 80 	movl   $0x80112c74,-0x4(%ebp)
8010517d:	eb 24                	jmp    801051a3 <wakeup1+0x33>
    if(p->state == SLEEPING && p->chan == chan)
8010517f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105182:	8b 40 0c             	mov    0xc(%eax),%eax
80105185:	83 f8 02             	cmp    $0x2,%eax
80105188:	75 15                	jne    8010519f <wakeup1+0x2f>
8010518a:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010518d:	8b 40 20             	mov    0x20(%eax),%eax
80105190:	3b 45 08             	cmp    0x8(%ebp),%eax
80105193:	75 0a                	jne    8010519f <wakeup1+0x2f>
      p->state = RUNNABLE;
80105195:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105198:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010519f:	83 45 fc 7c          	addl   $0x7c,-0x4(%ebp)
801051a3:	81 7d fc 74 4b 11 80 	cmpl   $0x80114b74,-0x4(%ebp)
801051aa:	72 d3                	jb     8010517f <wakeup1+0xf>
    if(p->state == SLEEPING && p->chan == chan)
      p->state = RUNNABLE;
}
801051ac:	90                   	nop
801051ad:	c9                   	leave  
801051ae:	c3                   	ret    

801051af <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
801051af:	55                   	push   %ebp
801051b0:	89 e5                	mov    %esp,%ebp
801051b2:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);
801051b5:	83 ec 0c             	sub    $0xc,%esp
801051b8:	68 40 2c 11 80       	push   $0x80112c40
801051bd:	e8 fb 01 00 00       	call   801053bd <acquire>
801051c2:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
801051c5:	83 ec 0c             	sub    $0xc,%esp
801051c8:	ff 75 08             	pushl  0x8(%ebp)
801051cb:	e8 a0 ff ff ff       	call   80105170 <wakeup1>
801051d0:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
801051d3:	83 ec 0c             	sub    $0xc,%esp
801051d6:	68 40 2c 11 80       	push   $0x80112c40
801051db:	e8 44 02 00 00       	call   80105424 <release>
801051e0:	83 c4 10             	add    $0x10,%esp
}
801051e3:	90                   	nop
801051e4:	c9                   	leave  
801051e5:	c3                   	ret    

801051e6 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
801051e6:	55                   	push   %ebp
801051e7:	89 e5                	mov    %esp,%ebp
801051e9:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  acquire(&ptable.lock);
801051ec:	83 ec 0c             	sub    $0xc,%esp
801051ef:	68 40 2c 11 80       	push   $0x80112c40
801051f4:	e8 c4 01 00 00       	call   801053bd <acquire>
801051f9:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801051fc:	c7 45 f4 74 2c 11 80 	movl   $0x80112c74,-0xc(%ebp)
80105203:	eb 45                	jmp    8010524a <kill+0x64>
    if(p->pid == pid){
80105205:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105208:	8b 40 10             	mov    0x10(%eax),%eax
8010520b:	3b 45 08             	cmp    0x8(%ebp),%eax
8010520e:	75 36                	jne    80105246 <kill+0x60>
      p->killed = 1;
80105210:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105213:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
8010521a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010521d:	8b 40 0c             	mov    0xc(%eax),%eax
80105220:	83 f8 02             	cmp    $0x2,%eax
80105223:	75 0a                	jne    8010522f <kill+0x49>
        p->state = RUNNABLE;
80105225:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105228:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
8010522f:	83 ec 0c             	sub    $0xc,%esp
80105232:	68 40 2c 11 80       	push   $0x80112c40
80105237:	e8 e8 01 00 00       	call   80105424 <release>
8010523c:	83 c4 10             	add    $0x10,%esp
      return 0;
8010523f:	b8 00 00 00 00       	mov    $0x0,%eax
80105244:	eb 22                	jmp    80105268 <kill+0x82>
kill(int pid)
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105246:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
8010524a:	81 7d f4 74 4b 11 80 	cmpl   $0x80114b74,-0xc(%ebp)
80105251:	72 b2                	jb     80105205 <kill+0x1f>
        p->state = RUNNABLE;
      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
80105253:	83 ec 0c             	sub    $0xc,%esp
80105256:	68 40 2c 11 80       	push   $0x80112c40
8010525b:	e8 c4 01 00 00       	call   80105424 <release>
80105260:	83 c4 10             	add    $0x10,%esp
  return -1;
80105263:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105268:	c9                   	leave  
80105269:	c3                   	ret    

8010526a <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
8010526a:	55                   	push   %ebp
8010526b:	89 e5                	mov    %esp,%ebp
8010526d:	83 ec 48             	sub    $0x48,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105270:	c7 45 f0 74 2c 11 80 	movl   $0x80112c74,-0x10(%ebp)
80105277:	e9 d7 00 00 00       	jmp    80105353 <procdump+0xe9>
    if(p->state == UNUSED)
8010527c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010527f:	8b 40 0c             	mov    0xc(%eax),%eax
80105282:	85 c0                	test   %eax,%eax
80105284:	0f 84 c4 00 00 00    	je     8010534e <procdump+0xe4>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
8010528a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010528d:	8b 40 0c             	mov    0xc(%eax),%eax
80105290:	83 f8 05             	cmp    $0x5,%eax
80105293:	77 23                	ja     801052b8 <procdump+0x4e>
80105295:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105298:	8b 40 0c             	mov    0xc(%eax),%eax
8010529b:	8b 04 85 0c b0 10 80 	mov    -0x7fef4ff4(,%eax,4),%eax
801052a2:	85 c0                	test   %eax,%eax
801052a4:	74 12                	je     801052b8 <procdump+0x4e>
      state = states[p->state];
801052a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801052a9:	8b 40 0c             	mov    0xc(%eax),%eax
801052ac:	8b 04 85 0c b0 10 80 	mov    -0x7fef4ff4(,%eax,4),%eax
801052b3:	89 45 ec             	mov    %eax,-0x14(%ebp)
801052b6:	eb 07                	jmp    801052bf <procdump+0x55>
    else
      state = "???";
801052b8:	c7 45 ec ec 8c 10 80 	movl   $0x80108cec,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
801052bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801052c2:	8d 50 6c             	lea    0x6c(%eax),%edx
801052c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801052c8:	8b 40 10             	mov    0x10(%eax),%eax
801052cb:	52                   	push   %edx
801052cc:	ff 75 ec             	pushl  -0x14(%ebp)
801052cf:	50                   	push   %eax
801052d0:	68 f0 8c 10 80       	push   $0x80108cf0
801052d5:	e8 ec b0 ff ff       	call   801003c6 <cprintf>
801052da:	83 c4 10             	add    $0x10,%esp
    if(p->state == SLEEPING){
801052dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801052e0:	8b 40 0c             	mov    0xc(%eax),%eax
801052e3:	83 f8 02             	cmp    $0x2,%eax
801052e6:	75 54                	jne    8010533c <procdump+0xd2>
      getcallerpcs((uint*)p->context->ebp+2, pc);
801052e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801052eb:	8b 40 1c             	mov    0x1c(%eax),%eax
801052ee:	8b 40 0c             	mov    0xc(%eax),%eax
801052f1:	83 c0 08             	add    $0x8,%eax
801052f4:	89 c2                	mov    %eax,%edx
801052f6:	83 ec 08             	sub    $0x8,%esp
801052f9:	8d 45 c4             	lea    -0x3c(%ebp),%eax
801052fc:	50                   	push   %eax
801052fd:	52                   	push   %edx
801052fe:	e8 73 01 00 00       	call   80105476 <getcallerpcs>
80105303:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
80105306:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010530d:	eb 1c                	jmp    8010532b <procdump+0xc1>
        cprintf(" %p", pc[i]);
8010530f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105312:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80105316:	83 ec 08             	sub    $0x8,%esp
80105319:	50                   	push   %eax
8010531a:	68 f9 8c 10 80       	push   $0x80108cf9
8010531f:	e8 a2 b0 ff ff       	call   801003c6 <cprintf>
80105324:	83 c4 10             	add    $0x10,%esp
    else
      state = "???";
    cprintf("%d %s %s", p->pid, state, p->name);
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
80105327:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010532b:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
8010532f:	7f 0b                	jg     8010533c <procdump+0xd2>
80105331:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105334:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80105338:	85 c0                	test   %eax,%eax
8010533a:	75 d3                	jne    8010530f <procdump+0xa5>
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
8010533c:	83 ec 0c             	sub    $0xc,%esp
8010533f:	68 fd 8c 10 80       	push   $0x80108cfd
80105344:	e8 7d b0 ff ff       	call   801003c6 <cprintf>
80105349:	83 c4 10             	add    $0x10,%esp
8010534c:	eb 01                	jmp    8010534f <procdump+0xe5>
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->state == UNUSED)
      continue;
8010534e:	90                   	nop
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010534f:	83 45 f0 7c          	addl   $0x7c,-0x10(%ebp)
80105353:	81 7d f0 74 4b 11 80 	cmpl   $0x80114b74,-0x10(%ebp)
8010535a:	0f 82 1c ff ff ff    	jb     8010527c <procdump+0x12>
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }
}
80105360:	90                   	nop
80105361:	c9                   	leave  
80105362:	c3                   	ret    

80105363 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80105363:	55                   	push   %ebp
80105364:	89 e5                	mov    %esp,%ebp
80105366:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80105369:	9c                   	pushf  
8010536a:	58                   	pop    %eax
8010536b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
8010536e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105371:	c9                   	leave  
80105372:	c3                   	ret    

80105373 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80105373:	55                   	push   %ebp
80105374:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80105376:	fa                   	cli    
}
80105377:	90                   	nop
80105378:	5d                   	pop    %ebp
80105379:	c3                   	ret    

8010537a <sti>:

static inline void
sti(void)
{
8010537a:	55                   	push   %ebp
8010537b:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
8010537d:	fb                   	sti    
}
8010537e:	90                   	nop
8010537f:	5d                   	pop    %ebp
80105380:	c3                   	ret    

80105381 <xchg>:

static inline uint
xchg(volatile uint *addr, uint newval)
{
80105381:	55                   	push   %ebp
80105382:	89 e5                	mov    %esp,%ebp
80105384:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80105387:	8b 55 08             	mov    0x8(%ebp),%edx
8010538a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010538d:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105390:	f0 87 02             	lock xchg %eax,(%edx)
80105393:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80105396:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105399:	c9                   	leave  
8010539a:	c3                   	ret    

8010539b <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
8010539b:	55                   	push   %ebp
8010539c:	89 e5                	mov    %esp,%ebp
  lk->name = name;
8010539e:	8b 45 08             	mov    0x8(%ebp),%eax
801053a1:	8b 55 0c             	mov    0xc(%ebp),%edx
801053a4:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
801053a7:	8b 45 08             	mov    0x8(%ebp),%eax
801053aa:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
801053b0:	8b 45 08             	mov    0x8(%ebp),%eax
801053b3:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
801053ba:	90                   	nop
801053bb:	5d                   	pop    %ebp
801053bc:	c3                   	ret    

801053bd <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
801053bd:	55                   	push   %ebp
801053be:	89 e5                	mov    %esp,%ebp
801053c0:	83 ec 08             	sub    $0x8,%esp
  pushcli(); // disable interrupts to avoid deadlock.
801053c3:	e8 52 01 00 00       	call   8010551a <pushcli>
  if(holding(lk))
801053c8:	8b 45 08             	mov    0x8(%ebp),%eax
801053cb:	83 ec 0c             	sub    $0xc,%esp
801053ce:	50                   	push   %eax
801053cf:	e8 1c 01 00 00       	call   801054f0 <holding>
801053d4:	83 c4 10             	add    $0x10,%esp
801053d7:	85 c0                	test   %eax,%eax
801053d9:	74 0d                	je     801053e8 <acquire+0x2b>
    panic("acquire");
801053db:	83 ec 0c             	sub    $0xc,%esp
801053de:	68 29 8d 10 80       	push   $0x80108d29
801053e3:	e8 7e b1 ff ff       	call   80100566 <panic>

  // The xchg is atomic.
  // It also serializes, so that reads after acquire are not
  // reordered before it. 
  while(xchg(&lk->locked, 1) != 0)
801053e8:	90                   	nop
801053e9:	8b 45 08             	mov    0x8(%ebp),%eax
801053ec:	83 ec 08             	sub    $0x8,%esp
801053ef:	6a 01                	push   $0x1
801053f1:	50                   	push   %eax
801053f2:	e8 8a ff ff ff       	call   80105381 <xchg>
801053f7:	83 c4 10             	add    $0x10,%esp
801053fa:	85 c0                	test   %eax,%eax
801053fc:	75 eb                	jne    801053e9 <acquire+0x2c>
    ;

  // Record info about lock acquisition for debugging.
  lk->cpu = cpu;
801053fe:	8b 45 08             	mov    0x8(%ebp),%eax
80105401:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80105408:	89 50 08             	mov    %edx,0x8(%eax)
  getcallerpcs(&lk, lk->pcs);
8010540b:	8b 45 08             	mov    0x8(%ebp),%eax
8010540e:	83 c0 0c             	add    $0xc,%eax
80105411:	83 ec 08             	sub    $0x8,%esp
80105414:	50                   	push   %eax
80105415:	8d 45 08             	lea    0x8(%ebp),%eax
80105418:	50                   	push   %eax
80105419:	e8 58 00 00 00       	call   80105476 <getcallerpcs>
8010541e:	83 c4 10             	add    $0x10,%esp
}
80105421:	90                   	nop
80105422:	c9                   	leave  
80105423:	c3                   	ret    

80105424 <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80105424:	55                   	push   %ebp
80105425:	89 e5                	mov    %esp,%ebp
80105427:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
8010542a:	83 ec 0c             	sub    $0xc,%esp
8010542d:	ff 75 08             	pushl  0x8(%ebp)
80105430:	e8 bb 00 00 00       	call   801054f0 <holding>
80105435:	83 c4 10             	add    $0x10,%esp
80105438:	85 c0                	test   %eax,%eax
8010543a:	75 0d                	jne    80105449 <release+0x25>
    panic("release");
8010543c:	83 ec 0c             	sub    $0xc,%esp
8010543f:	68 31 8d 10 80       	push   $0x80108d31
80105444:	e8 1d b1 ff ff       	call   80100566 <panic>

  lk->pcs[0] = 0;
80105449:	8b 45 08             	mov    0x8(%ebp),%eax
8010544c:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
80105453:	8b 45 08             	mov    0x8(%ebp),%eax
80105456:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // But the 2007 Intel 64 Architecture Memory Ordering White
  // Paper says that Intel 64 and IA-32 will not move a load
  // after a store. So lock->locked = 0 would work here.
  // The xchg being asm volatile ensures gcc emits it after
  // the above assignments (and after the critical section).
  xchg(&lk->locked, 0);
8010545d:	8b 45 08             	mov    0x8(%ebp),%eax
80105460:	83 ec 08             	sub    $0x8,%esp
80105463:	6a 00                	push   $0x0
80105465:	50                   	push   %eax
80105466:	e8 16 ff ff ff       	call   80105381 <xchg>
8010546b:	83 c4 10             	add    $0x10,%esp

  popcli();
8010546e:	e8 ec 00 00 00       	call   8010555f <popcli>
}
80105473:	90                   	nop
80105474:	c9                   	leave  
80105475:	c3                   	ret    

80105476 <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80105476:	55                   	push   %ebp
80105477:	89 e5                	mov    %esp,%ebp
80105479:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
8010547c:	8b 45 08             	mov    0x8(%ebp),%eax
8010547f:	83 e8 08             	sub    $0x8,%eax
80105482:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80105485:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
8010548c:	eb 38                	jmp    801054c6 <getcallerpcs+0x50>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
8010548e:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80105492:	74 53                	je     801054e7 <getcallerpcs+0x71>
80105494:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
8010549b:	76 4a                	jbe    801054e7 <getcallerpcs+0x71>
8010549d:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
801054a1:	74 44                	je     801054e7 <getcallerpcs+0x71>
      break;
    pcs[i] = ebp[1];     // saved %eip
801054a3:	8b 45 f8             	mov    -0x8(%ebp),%eax
801054a6:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801054ad:	8b 45 0c             	mov    0xc(%ebp),%eax
801054b0:	01 c2                	add    %eax,%edx
801054b2:	8b 45 fc             	mov    -0x4(%ebp),%eax
801054b5:	8b 40 04             	mov    0x4(%eax),%eax
801054b8:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
801054ba:	8b 45 fc             	mov    -0x4(%ebp),%eax
801054bd:	8b 00                	mov    (%eax),%eax
801054bf:	89 45 fc             	mov    %eax,-0x4(%ebp)
{
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
801054c2:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
801054c6:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
801054ca:	7e c2                	jle    8010548e <getcallerpcs+0x18>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
801054cc:	eb 19                	jmp    801054e7 <getcallerpcs+0x71>
    pcs[i] = 0;
801054ce:	8b 45 f8             	mov    -0x8(%ebp),%eax
801054d1:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801054d8:	8b 45 0c             	mov    0xc(%ebp),%eax
801054db:	01 d0                	add    %edx,%eax
801054dd:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
801054e3:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
801054e7:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
801054eb:	7e e1                	jle    801054ce <getcallerpcs+0x58>
    pcs[i] = 0;
}
801054ed:	90                   	nop
801054ee:	c9                   	leave  
801054ef:	c3                   	ret    

801054f0 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
801054f0:	55                   	push   %ebp
801054f1:	89 e5                	mov    %esp,%ebp
  return lock->locked && lock->cpu == cpu;
801054f3:	8b 45 08             	mov    0x8(%ebp),%eax
801054f6:	8b 00                	mov    (%eax),%eax
801054f8:	85 c0                	test   %eax,%eax
801054fa:	74 17                	je     80105513 <holding+0x23>
801054fc:	8b 45 08             	mov    0x8(%ebp),%eax
801054ff:	8b 50 08             	mov    0x8(%eax),%edx
80105502:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105508:	39 c2                	cmp    %eax,%edx
8010550a:	75 07                	jne    80105513 <holding+0x23>
8010550c:	b8 01 00 00 00       	mov    $0x1,%eax
80105511:	eb 05                	jmp    80105518 <holding+0x28>
80105513:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105518:	5d                   	pop    %ebp
80105519:	c3                   	ret    

8010551a <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
8010551a:	55                   	push   %ebp
8010551b:	89 e5                	mov    %esp,%ebp
8010551d:	83 ec 10             	sub    $0x10,%esp
  int eflags;
  
  eflags = readeflags();
80105520:	e8 3e fe ff ff       	call   80105363 <readeflags>
80105525:	89 45 fc             	mov    %eax,-0x4(%ebp)
  cli();
80105528:	e8 46 fe ff ff       	call   80105373 <cli>
  if(cpu->ncli++ == 0)
8010552d:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80105534:	8b 82 ac 00 00 00    	mov    0xac(%edx),%eax
8010553a:	8d 48 01             	lea    0x1(%eax),%ecx
8010553d:	89 8a ac 00 00 00    	mov    %ecx,0xac(%edx)
80105543:	85 c0                	test   %eax,%eax
80105545:	75 15                	jne    8010555c <pushcli+0x42>
    cpu->intena = eflags & FL_IF;
80105547:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010554d:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105550:	81 e2 00 02 00 00    	and    $0x200,%edx
80105556:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
8010555c:	90                   	nop
8010555d:	c9                   	leave  
8010555e:	c3                   	ret    

8010555f <popcli>:

void
popcli(void)
{
8010555f:	55                   	push   %ebp
80105560:	89 e5                	mov    %esp,%ebp
80105562:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
80105565:	e8 f9 fd ff ff       	call   80105363 <readeflags>
8010556a:	25 00 02 00 00       	and    $0x200,%eax
8010556f:	85 c0                	test   %eax,%eax
80105571:	74 0d                	je     80105580 <popcli+0x21>
    panic("popcli - interruptible");
80105573:	83 ec 0c             	sub    $0xc,%esp
80105576:	68 39 8d 10 80       	push   $0x80108d39
8010557b:	e8 e6 af ff ff       	call   80100566 <panic>
  if(--cpu->ncli < 0)
80105580:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105586:	8b 90 ac 00 00 00    	mov    0xac(%eax),%edx
8010558c:	83 ea 01             	sub    $0x1,%edx
8010558f:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
80105595:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
8010559b:	85 c0                	test   %eax,%eax
8010559d:	79 0d                	jns    801055ac <popcli+0x4d>
    panic("popcli");
8010559f:	83 ec 0c             	sub    $0xc,%esp
801055a2:	68 50 8d 10 80       	push   $0x80108d50
801055a7:	e8 ba af ff ff       	call   80100566 <panic>
  if(cpu->ncli == 0 && cpu->intena)
801055ac:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801055b2:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
801055b8:	85 c0                	test   %eax,%eax
801055ba:	75 15                	jne    801055d1 <popcli+0x72>
801055bc:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801055c2:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
801055c8:	85 c0                	test   %eax,%eax
801055ca:	74 05                	je     801055d1 <popcli+0x72>
    sti();
801055cc:	e8 a9 fd ff ff       	call   8010537a <sti>
}
801055d1:	90                   	nop
801055d2:	c9                   	leave  
801055d3:	c3                   	ret    

801055d4 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
801055d4:	55                   	push   %ebp
801055d5:	89 e5                	mov    %esp,%ebp
801055d7:	57                   	push   %edi
801055d8:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
801055d9:	8b 4d 08             	mov    0x8(%ebp),%ecx
801055dc:	8b 55 10             	mov    0x10(%ebp),%edx
801055df:	8b 45 0c             	mov    0xc(%ebp),%eax
801055e2:	89 cb                	mov    %ecx,%ebx
801055e4:	89 df                	mov    %ebx,%edi
801055e6:	89 d1                	mov    %edx,%ecx
801055e8:	fc                   	cld    
801055e9:	f3 aa                	rep stos %al,%es:(%edi)
801055eb:	89 ca                	mov    %ecx,%edx
801055ed:	89 fb                	mov    %edi,%ebx
801055ef:	89 5d 08             	mov    %ebx,0x8(%ebp)
801055f2:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
801055f5:	90                   	nop
801055f6:	5b                   	pop    %ebx
801055f7:	5f                   	pop    %edi
801055f8:	5d                   	pop    %ebp
801055f9:	c3                   	ret    

801055fa <stosl>:

static inline void
stosl(void *addr, int data, int cnt)
{
801055fa:	55                   	push   %ebp
801055fb:	89 e5                	mov    %esp,%ebp
801055fd:	57                   	push   %edi
801055fe:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
801055ff:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105602:	8b 55 10             	mov    0x10(%ebp),%edx
80105605:	8b 45 0c             	mov    0xc(%ebp),%eax
80105608:	89 cb                	mov    %ecx,%ebx
8010560a:	89 df                	mov    %ebx,%edi
8010560c:	89 d1                	mov    %edx,%ecx
8010560e:	fc                   	cld    
8010560f:	f3 ab                	rep stos %eax,%es:(%edi)
80105611:	89 ca                	mov    %ecx,%edx
80105613:	89 fb                	mov    %edi,%ebx
80105615:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105618:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
8010561b:	90                   	nop
8010561c:	5b                   	pop    %ebx
8010561d:	5f                   	pop    %edi
8010561e:	5d                   	pop    %ebp
8010561f:	c3                   	ret    

80105620 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80105620:	55                   	push   %ebp
80105621:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
80105623:	8b 45 08             	mov    0x8(%ebp),%eax
80105626:	83 e0 03             	and    $0x3,%eax
80105629:	85 c0                	test   %eax,%eax
8010562b:	75 43                	jne    80105670 <memset+0x50>
8010562d:	8b 45 10             	mov    0x10(%ebp),%eax
80105630:	83 e0 03             	and    $0x3,%eax
80105633:	85 c0                	test   %eax,%eax
80105635:	75 39                	jne    80105670 <memset+0x50>
    c &= 0xFF;
80105637:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
8010563e:	8b 45 10             	mov    0x10(%ebp),%eax
80105641:	c1 e8 02             	shr    $0x2,%eax
80105644:	89 c1                	mov    %eax,%ecx
80105646:	8b 45 0c             	mov    0xc(%ebp),%eax
80105649:	c1 e0 18             	shl    $0x18,%eax
8010564c:	89 c2                	mov    %eax,%edx
8010564e:	8b 45 0c             	mov    0xc(%ebp),%eax
80105651:	c1 e0 10             	shl    $0x10,%eax
80105654:	09 c2                	or     %eax,%edx
80105656:	8b 45 0c             	mov    0xc(%ebp),%eax
80105659:	c1 e0 08             	shl    $0x8,%eax
8010565c:	09 d0                	or     %edx,%eax
8010565e:	0b 45 0c             	or     0xc(%ebp),%eax
80105661:	51                   	push   %ecx
80105662:	50                   	push   %eax
80105663:	ff 75 08             	pushl  0x8(%ebp)
80105666:	e8 8f ff ff ff       	call   801055fa <stosl>
8010566b:	83 c4 0c             	add    $0xc,%esp
8010566e:	eb 12                	jmp    80105682 <memset+0x62>
  } else
    stosb(dst, c, n);
80105670:	8b 45 10             	mov    0x10(%ebp),%eax
80105673:	50                   	push   %eax
80105674:	ff 75 0c             	pushl  0xc(%ebp)
80105677:	ff 75 08             	pushl  0x8(%ebp)
8010567a:	e8 55 ff ff ff       	call   801055d4 <stosb>
8010567f:	83 c4 0c             	add    $0xc,%esp
  return dst;
80105682:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105685:	c9                   	leave  
80105686:	c3                   	ret    

80105687 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80105687:	55                   	push   %ebp
80105688:	89 e5                	mov    %esp,%ebp
8010568a:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;
  
  s1 = v1;
8010568d:	8b 45 08             	mov    0x8(%ebp),%eax
80105690:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
80105693:	8b 45 0c             	mov    0xc(%ebp),%eax
80105696:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
80105699:	eb 30                	jmp    801056cb <memcmp+0x44>
    if(*s1 != *s2)
8010569b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010569e:	0f b6 10             	movzbl (%eax),%edx
801056a1:	8b 45 f8             	mov    -0x8(%ebp),%eax
801056a4:	0f b6 00             	movzbl (%eax),%eax
801056a7:	38 c2                	cmp    %al,%dl
801056a9:	74 18                	je     801056c3 <memcmp+0x3c>
      return *s1 - *s2;
801056ab:	8b 45 fc             	mov    -0x4(%ebp),%eax
801056ae:	0f b6 00             	movzbl (%eax),%eax
801056b1:	0f b6 d0             	movzbl %al,%edx
801056b4:	8b 45 f8             	mov    -0x8(%ebp),%eax
801056b7:	0f b6 00             	movzbl (%eax),%eax
801056ba:	0f b6 c0             	movzbl %al,%eax
801056bd:	29 c2                	sub    %eax,%edx
801056bf:	89 d0                	mov    %edx,%eax
801056c1:	eb 1a                	jmp    801056dd <memcmp+0x56>
    s1++, s2++;
801056c3:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801056c7:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  const uchar *s1, *s2;
  
  s1 = v1;
  s2 = v2;
  while(n-- > 0){
801056cb:	8b 45 10             	mov    0x10(%ebp),%eax
801056ce:	8d 50 ff             	lea    -0x1(%eax),%edx
801056d1:	89 55 10             	mov    %edx,0x10(%ebp)
801056d4:	85 c0                	test   %eax,%eax
801056d6:	75 c3                	jne    8010569b <memcmp+0x14>
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
  }

  return 0;
801056d8:	b8 00 00 00 00       	mov    $0x0,%eax
}
801056dd:	c9                   	leave  
801056de:	c3                   	ret    

801056df <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
801056df:	55                   	push   %ebp
801056e0:	89 e5                	mov    %esp,%ebp
801056e2:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
801056e5:	8b 45 0c             	mov    0xc(%ebp),%eax
801056e8:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
801056eb:	8b 45 08             	mov    0x8(%ebp),%eax
801056ee:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
801056f1:	8b 45 fc             	mov    -0x4(%ebp),%eax
801056f4:	3b 45 f8             	cmp    -0x8(%ebp),%eax
801056f7:	73 54                	jae    8010574d <memmove+0x6e>
801056f9:	8b 55 fc             	mov    -0x4(%ebp),%edx
801056fc:	8b 45 10             	mov    0x10(%ebp),%eax
801056ff:	01 d0                	add    %edx,%eax
80105701:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105704:	76 47                	jbe    8010574d <memmove+0x6e>
    s += n;
80105706:	8b 45 10             	mov    0x10(%ebp),%eax
80105709:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
8010570c:	8b 45 10             	mov    0x10(%ebp),%eax
8010570f:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80105712:	eb 13                	jmp    80105727 <memmove+0x48>
      *--d = *--s;
80105714:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
80105718:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
8010571c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010571f:	0f b6 10             	movzbl (%eax),%edx
80105722:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105725:	88 10                	mov    %dl,(%eax)
  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
    while(n-- > 0)
80105727:	8b 45 10             	mov    0x10(%ebp),%eax
8010572a:	8d 50 ff             	lea    -0x1(%eax),%edx
8010572d:	89 55 10             	mov    %edx,0x10(%ebp)
80105730:	85 c0                	test   %eax,%eax
80105732:	75 e0                	jne    80105714 <memmove+0x35>
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
80105734:	eb 24                	jmp    8010575a <memmove+0x7b>
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
      *d++ = *s++;
80105736:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105739:	8d 50 01             	lea    0x1(%eax),%edx
8010573c:	89 55 f8             	mov    %edx,-0x8(%ebp)
8010573f:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105742:	8d 4a 01             	lea    0x1(%edx),%ecx
80105745:	89 4d fc             	mov    %ecx,-0x4(%ebp)
80105748:	0f b6 12             	movzbl (%edx),%edx
8010574b:	88 10                	mov    %dl,(%eax)
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
8010574d:	8b 45 10             	mov    0x10(%ebp),%eax
80105750:	8d 50 ff             	lea    -0x1(%eax),%edx
80105753:	89 55 10             	mov    %edx,0x10(%ebp)
80105756:	85 c0                	test   %eax,%eax
80105758:	75 dc                	jne    80105736 <memmove+0x57>
      *d++ = *s++;

  return dst;
8010575a:	8b 45 08             	mov    0x8(%ebp),%eax
}
8010575d:	c9                   	leave  
8010575e:	c3                   	ret    

8010575f <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
8010575f:	55                   	push   %ebp
80105760:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
80105762:	ff 75 10             	pushl  0x10(%ebp)
80105765:	ff 75 0c             	pushl  0xc(%ebp)
80105768:	ff 75 08             	pushl  0x8(%ebp)
8010576b:	e8 6f ff ff ff       	call   801056df <memmove>
80105770:	83 c4 0c             	add    $0xc,%esp
}
80105773:	c9                   	leave  
80105774:	c3                   	ret    

80105775 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80105775:	55                   	push   %ebp
80105776:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
80105778:	eb 0c                	jmp    80105786 <strncmp+0x11>
    n--, p++, q++;
8010577a:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
8010577e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80105782:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
80105786:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010578a:	74 1a                	je     801057a6 <strncmp+0x31>
8010578c:	8b 45 08             	mov    0x8(%ebp),%eax
8010578f:	0f b6 00             	movzbl (%eax),%eax
80105792:	84 c0                	test   %al,%al
80105794:	74 10                	je     801057a6 <strncmp+0x31>
80105796:	8b 45 08             	mov    0x8(%ebp),%eax
80105799:	0f b6 10             	movzbl (%eax),%edx
8010579c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010579f:	0f b6 00             	movzbl (%eax),%eax
801057a2:	38 c2                	cmp    %al,%dl
801057a4:	74 d4                	je     8010577a <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
801057a6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801057aa:	75 07                	jne    801057b3 <strncmp+0x3e>
    return 0;
801057ac:	b8 00 00 00 00       	mov    $0x0,%eax
801057b1:	eb 16                	jmp    801057c9 <strncmp+0x54>
  return (uchar)*p - (uchar)*q;
801057b3:	8b 45 08             	mov    0x8(%ebp),%eax
801057b6:	0f b6 00             	movzbl (%eax),%eax
801057b9:	0f b6 d0             	movzbl %al,%edx
801057bc:	8b 45 0c             	mov    0xc(%ebp),%eax
801057bf:	0f b6 00             	movzbl (%eax),%eax
801057c2:	0f b6 c0             	movzbl %al,%eax
801057c5:	29 c2                	sub    %eax,%edx
801057c7:	89 d0                	mov    %edx,%eax
}
801057c9:	5d                   	pop    %ebp
801057ca:	c3                   	ret    

801057cb <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
801057cb:	55                   	push   %ebp
801057cc:	89 e5                	mov    %esp,%ebp
801057ce:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
801057d1:	8b 45 08             	mov    0x8(%ebp),%eax
801057d4:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
801057d7:	90                   	nop
801057d8:	8b 45 10             	mov    0x10(%ebp),%eax
801057db:	8d 50 ff             	lea    -0x1(%eax),%edx
801057de:	89 55 10             	mov    %edx,0x10(%ebp)
801057e1:	85 c0                	test   %eax,%eax
801057e3:	7e 2c                	jle    80105811 <strncpy+0x46>
801057e5:	8b 45 08             	mov    0x8(%ebp),%eax
801057e8:	8d 50 01             	lea    0x1(%eax),%edx
801057eb:	89 55 08             	mov    %edx,0x8(%ebp)
801057ee:	8b 55 0c             	mov    0xc(%ebp),%edx
801057f1:	8d 4a 01             	lea    0x1(%edx),%ecx
801057f4:	89 4d 0c             	mov    %ecx,0xc(%ebp)
801057f7:	0f b6 12             	movzbl (%edx),%edx
801057fa:	88 10                	mov    %dl,(%eax)
801057fc:	0f b6 00             	movzbl (%eax),%eax
801057ff:	84 c0                	test   %al,%al
80105801:	75 d5                	jne    801057d8 <strncpy+0xd>
    ;
  while(n-- > 0)
80105803:	eb 0c                	jmp    80105811 <strncpy+0x46>
    *s++ = 0;
80105805:	8b 45 08             	mov    0x8(%ebp),%eax
80105808:	8d 50 01             	lea    0x1(%eax),%edx
8010580b:	89 55 08             	mov    %edx,0x8(%ebp)
8010580e:	c6 00 00             	movb   $0x0,(%eax)
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
80105811:	8b 45 10             	mov    0x10(%ebp),%eax
80105814:	8d 50 ff             	lea    -0x1(%eax),%edx
80105817:	89 55 10             	mov    %edx,0x10(%ebp)
8010581a:	85 c0                	test   %eax,%eax
8010581c:	7f e7                	jg     80105805 <strncpy+0x3a>
    *s++ = 0;
  return os;
8010581e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105821:	c9                   	leave  
80105822:	c3                   	ret    

80105823 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80105823:	55                   	push   %ebp
80105824:	89 e5                	mov    %esp,%ebp
80105826:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
80105829:	8b 45 08             	mov    0x8(%ebp),%eax
8010582c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
8010582f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105833:	7f 05                	jg     8010583a <safestrcpy+0x17>
    return os;
80105835:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105838:	eb 31                	jmp    8010586b <safestrcpy+0x48>
  while(--n > 0 && (*s++ = *t++) != 0)
8010583a:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
8010583e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105842:	7e 1e                	jle    80105862 <safestrcpy+0x3f>
80105844:	8b 45 08             	mov    0x8(%ebp),%eax
80105847:	8d 50 01             	lea    0x1(%eax),%edx
8010584a:	89 55 08             	mov    %edx,0x8(%ebp)
8010584d:	8b 55 0c             	mov    0xc(%ebp),%edx
80105850:	8d 4a 01             	lea    0x1(%edx),%ecx
80105853:	89 4d 0c             	mov    %ecx,0xc(%ebp)
80105856:	0f b6 12             	movzbl (%edx),%edx
80105859:	88 10                	mov    %dl,(%eax)
8010585b:	0f b6 00             	movzbl (%eax),%eax
8010585e:	84 c0                	test   %al,%al
80105860:	75 d8                	jne    8010583a <safestrcpy+0x17>
    ;
  *s = 0;
80105862:	8b 45 08             	mov    0x8(%ebp),%eax
80105865:	c6 00 00             	movb   $0x0,(%eax)
  return os;
80105868:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010586b:	c9                   	leave  
8010586c:	c3                   	ret    

8010586d <strlen>:

int
strlen(const char *s)
{
8010586d:	55                   	push   %ebp
8010586e:	89 e5                	mov    %esp,%ebp
80105870:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
80105873:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
8010587a:	eb 04                	jmp    80105880 <strlen+0x13>
8010587c:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105880:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105883:	8b 45 08             	mov    0x8(%ebp),%eax
80105886:	01 d0                	add    %edx,%eax
80105888:	0f b6 00             	movzbl (%eax),%eax
8010588b:	84 c0                	test   %al,%al
8010588d:	75 ed                	jne    8010587c <strlen+0xf>
    ;
  return n;
8010588f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105892:	c9                   	leave  
80105893:	c3                   	ret    

80105894 <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
80105894:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80105898:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
8010589c:	55                   	push   %ebp
  pushl %ebx
8010589d:	53                   	push   %ebx
  pushl %esi
8010589e:	56                   	push   %esi
  pushl %edi
8010589f:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
801058a0:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
801058a2:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
801058a4:	5f                   	pop    %edi
  popl %esi
801058a5:	5e                   	pop    %esi
  popl %ebx
801058a6:	5b                   	pop    %ebx
  popl %ebp
801058a7:	5d                   	pop    %ebp
  ret
801058a8:	c3                   	ret    

801058a9 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
801058a9:	55                   	push   %ebp
801058aa:	89 e5                	mov    %esp,%ebp
  if(addr >= proc->sz || addr+4 > proc->sz)
801058ac:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801058b2:	8b 00                	mov    (%eax),%eax
801058b4:	3b 45 08             	cmp    0x8(%ebp),%eax
801058b7:	76 12                	jbe    801058cb <fetchint+0x22>
801058b9:	8b 45 08             	mov    0x8(%ebp),%eax
801058bc:	8d 50 04             	lea    0x4(%eax),%edx
801058bf:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801058c5:	8b 00                	mov    (%eax),%eax
801058c7:	39 c2                	cmp    %eax,%edx
801058c9:	76 07                	jbe    801058d2 <fetchint+0x29>
    return -1;
801058cb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801058d0:	eb 0f                	jmp    801058e1 <fetchint+0x38>
  *ip = *(int*)(addr);
801058d2:	8b 45 08             	mov    0x8(%ebp),%eax
801058d5:	8b 10                	mov    (%eax),%edx
801058d7:	8b 45 0c             	mov    0xc(%ebp),%eax
801058da:	89 10                	mov    %edx,(%eax)
  return 0;
801058dc:	b8 00 00 00 00       	mov    $0x0,%eax
}
801058e1:	5d                   	pop    %ebp
801058e2:	c3                   	ret    

801058e3 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
801058e3:	55                   	push   %ebp
801058e4:	89 e5                	mov    %esp,%ebp
801058e6:	83 ec 10             	sub    $0x10,%esp
  char *s, *ep;

  if(addr >= proc->sz)
801058e9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801058ef:	8b 00                	mov    (%eax),%eax
801058f1:	3b 45 08             	cmp    0x8(%ebp),%eax
801058f4:	77 07                	ja     801058fd <fetchstr+0x1a>
    return -1;
801058f6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801058fb:	eb 46                	jmp    80105943 <fetchstr+0x60>
  *pp = (char*)addr;
801058fd:	8b 55 08             	mov    0x8(%ebp),%edx
80105900:	8b 45 0c             	mov    0xc(%ebp),%eax
80105903:	89 10                	mov    %edx,(%eax)
  ep = (char*)proc->sz;
80105905:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010590b:	8b 00                	mov    (%eax),%eax
8010590d:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(s = *pp; s < ep; s++)
80105910:	8b 45 0c             	mov    0xc(%ebp),%eax
80105913:	8b 00                	mov    (%eax),%eax
80105915:	89 45 fc             	mov    %eax,-0x4(%ebp)
80105918:	eb 1c                	jmp    80105936 <fetchstr+0x53>
    if(*s == 0)
8010591a:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010591d:	0f b6 00             	movzbl (%eax),%eax
80105920:	84 c0                	test   %al,%al
80105922:	75 0e                	jne    80105932 <fetchstr+0x4f>
      return s - *pp;
80105924:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105927:	8b 45 0c             	mov    0xc(%ebp),%eax
8010592a:	8b 00                	mov    (%eax),%eax
8010592c:	29 c2                	sub    %eax,%edx
8010592e:	89 d0                	mov    %edx,%eax
80105930:	eb 11                	jmp    80105943 <fetchstr+0x60>

  if(addr >= proc->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)proc->sz;
  for(s = *pp; s < ep; s++)
80105932:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105936:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105939:	3b 45 f8             	cmp    -0x8(%ebp),%eax
8010593c:	72 dc                	jb     8010591a <fetchstr+0x37>
    if(*s == 0)
      return s - *pp;
  return -1;
8010593e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105943:	c9                   	leave  
80105944:	c3                   	ret    

80105945 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80105945:	55                   	push   %ebp
80105946:	89 e5                	mov    %esp,%ebp
  return fetchint(proc->tf->esp + 4 + 4*n, ip);
80105948:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010594e:	8b 40 18             	mov    0x18(%eax),%eax
80105951:	8b 40 44             	mov    0x44(%eax),%eax
80105954:	8b 55 08             	mov    0x8(%ebp),%edx
80105957:	c1 e2 02             	shl    $0x2,%edx
8010595a:	01 d0                	add    %edx,%eax
8010595c:	83 c0 04             	add    $0x4,%eax
8010595f:	ff 75 0c             	pushl  0xc(%ebp)
80105962:	50                   	push   %eax
80105963:	e8 41 ff ff ff       	call   801058a9 <fetchint>
80105968:	83 c4 08             	add    $0x8,%esp
}
8010596b:	c9                   	leave  
8010596c:	c3                   	ret    

8010596d <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size n bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
8010596d:	55                   	push   %ebp
8010596e:	89 e5                	mov    %esp,%ebp
80105970:	83 ec 10             	sub    $0x10,%esp
  int i;
  
  if(argint(n, &i) < 0)
80105973:	8d 45 fc             	lea    -0x4(%ebp),%eax
80105976:	50                   	push   %eax
80105977:	ff 75 08             	pushl  0x8(%ebp)
8010597a:	e8 c6 ff ff ff       	call   80105945 <argint>
8010597f:	83 c4 08             	add    $0x8,%esp
80105982:	85 c0                	test   %eax,%eax
80105984:	79 07                	jns    8010598d <argptr+0x20>
    return -1;
80105986:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010598b:	eb 3b                	jmp    801059c8 <argptr+0x5b>
  if((uint)i >= proc->sz || (uint)i+size > proc->sz)
8010598d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105993:	8b 00                	mov    (%eax),%eax
80105995:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105998:	39 d0                	cmp    %edx,%eax
8010599a:	76 16                	jbe    801059b2 <argptr+0x45>
8010599c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010599f:	89 c2                	mov    %eax,%edx
801059a1:	8b 45 10             	mov    0x10(%ebp),%eax
801059a4:	01 c2                	add    %eax,%edx
801059a6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801059ac:	8b 00                	mov    (%eax),%eax
801059ae:	39 c2                	cmp    %eax,%edx
801059b0:	76 07                	jbe    801059b9 <argptr+0x4c>
    return -1;
801059b2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801059b7:	eb 0f                	jmp    801059c8 <argptr+0x5b>
  *pp = (char*)i;
801059b9:	8b 45 fc             	mov    -0x4(%ebp),%eax
801059bc:	89 c2                	mov    %eax,%edx
801059be:	8b 45 0c             	mov    0xc(%ebp),%eax
801059c1:	89 10                	mov    %edx,(%eax)
  return 0;
801059c3:	b8 00 00 00 00       	mov    $0x0,%eax
}
801059c8:	c9                   	leave  
801059c9:	c3                   	ret    

801059ca <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
801059ca:	55                   	push   %ebp
801059cb:	89 e5                	mov    %esp,%ebp
801059cd:	83 ec 10             	sub    $0x10,%esp
  int addr;
  if(argint(n, &addr) < 0)
801059d0:	8d 45 fc             	lea    -0x4(%ebp),%eax
801059d3:	50                   	push   %eax
801059d4:	ff 75 08             	pushl  0x8(%ebp)
801059d7:	e8 69 ff ff ff       	call   80105945 <argint>
801059dc:	83 c4 08             	add    $0x8,%esp
801059df:	85 c0                	test   %eax,%eax
801059e1:	79 07                	jns    801059ea <argstr+0x20>
    return -1;
801059e3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801059e8:	eb 0f                	jmp    801059f9 <argstr+0x2f>
  return fetchstr(addr, pp);
801059ea:	8b 45 fc             	mov    -0x4(%ebp),%eax
801059ed:	ff 75 0c             	pushl  0xc(%ebp)
801059f0:	50                   	push   %eax
801059f1:	e8 ed fe ff ff       	call   801058e3 <fetchstr>
801059f6:	83 c4 08             	add    $0x8,%esp
}
801059f9:	c9                   	leave  
801059fa:	c3                   	ret    

801059fb <syscall>:
[SYS_close]   sys_close,
};

void
syscall(void)
{
801059fb:	55                   	push   %ebp
801059fc:	89 e5                	mov    %esp,%ebp
801059fe:	53                   	push   %ebx
801059ff:	83 ec 14             	sub    $0x14,%esp
  int num;

  num = proc->tf->eax;
80105a02:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105a08:	8b 40 18             	mov    0x18(%eax),%eax
80105a0b:	8b 40 1c             	mov    0x1c(%eax),%eax
80105a0e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80105a11:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105a15:	7e 30                	jle    80105a47 <syscall+0x4c>
80105a17:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a1a:	83 f8 15             	cmp    $0x15,%eax
80105a1d:	77 28                	ja     80105a47 <syscall+0x4c>
80105a1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a22:	8b 04 85 40 b0 10 80 	mov    -0x7fef4fc0(,%eax,4),%eax
80105a29:	85 c0                	test   %eax,%eax
80105a2b:	74 1a                	je     80105a47 <syscall+0x4c>
    proc->tf->eax = syscalls[num]();
80105a2d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105a33:	8b 58 18             	mov    0x18(%eax),%ebx
80105a36:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a39:	8b 04 85 40 b0 10 80 	mov    -0x7fef4fc0(,%eax,4),%eax
80105a40:	ff d0                	call   *%eax
80105a42:	89 43 1c             	mov    %eax,0x1c(%ebx)
80105a45:	eb 34                	jmp    80105a7b <syscall+0x80>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            proc->pid, proc->name, num);
80105a47:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105a4d:	8d 50 6c             	lea    0x6c(%eax),%edx
80105a50:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax

  num = proc->tf->eax;
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    proc->tf->eax = syscalls[num]();
  } else {
    cprintf("%d %s: unknown sys call %d\n",
80105a56:	8b 40 10             	mov    0x10(%eax),%eax
80105a59:	ff 75 f4             	pushl  -0xc(%ebp)
80105a5c:	52                   	push   %edx
80105a5d:	50                   	push   %eax
80105a5e:	68 57 8d 10 80       	push   $0x80108d57
80105a63:	e8 5e a9 ff ff       	call   801003c6 <cprintf>
80105a68:	83 c4 10             	add    $0x10,%esp
            proc->pid, proc->name, num);
    proc->tf->eax = -1;
80105a6b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105a71:	8b 40 18             	mov    0x18(%eax),%eax
80105a74:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
80105a7b:	90                   	nop
80105a7c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105a7f:	c9                   	leave  
80105a80:	c3                   	ret    

80105a81 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80105a81:	55                   	push   %ebp
80105a82:	89 e5                	mov    %esp,%ebp
80105a84:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80105a87:	83 ec 08             	sub    $0x8,%esp
80105a8a:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105a8d:	50                   	push   %eax
80105a8e:	ff 75 08             	pushl  0x8(%ebp)
80105a91:	e8 af fe ff ff       	call   80105945 <argint>
80105a96:	83 c4 10             	add    $0x10,%esp
80105a99:	85 c0                	test   %eax,%eax
80105a9b:	79 07                	jns    80105aa4 <argfd+0x23>
    return -1;
80105a9d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105aa2:	eb 50                	jmp    80105af4 <argfd+0x73>
  if(fd < 0 || fd >= NOFILE || (f=proc->ofile[fd]) == 0)
80105aa4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105aa7:	85 c0                	test   %eax,%eax
80105aa9:	78 21                	js     80105acc <argfd+0x4b>
80105aab:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105aae:	83 f8 0f             	cmp    $0xf,%eax
80105ab1:	7f 19                	jg     80105acc <argfd+0x4b>
80105ab3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105ab9:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105abc:	83 c2 08             	add    $0x8,%edx
80105abf:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105ac3:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105ac6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105aca:	75 07                	jne    80105ad3 <argfd+0x52>
    return -1;
80105acc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ad1:	eb 21                	jmp    80105af4 <argfd+0x73>
  if(pfd)
80105ad3:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80105ad7:	74 08                	je     80105ae1 <argfd+0x60>
    *pfd = fd;
80105ad9:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105adc:	8b 45 0c             	mov    0xc(%ebp),%eax
80105adf:	89 10                	mov    %edx,(%eax)
  if(pf)
80105ae1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105ae5:	74 08                	je     80105aef <argfd+0x6e>
    *pf = f;
80105ae7:	8b 45 10             	mov    0x10(%ebp),%eax
80105aea:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105aed:	89 10                	mov    %edx,(%eax)
  return 0;
80105aef:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105af4:	c9                   	leave  
80105af5:	c3                   	ret    

80105af6 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
80105af6:	55                   	push   %ebp
80105af7:	89 e5                	mov    %esp,%ebp
80105af9:	83 ec 10             	sub    $0x10,%esp
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
80105afc:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80105b03:	eb 30                	jmp    80105b35 <fdalloc+0x3f>
    if(proc->ofile[fd] == 0){
80105b05:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105b0b:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105b0e:	83 c2 08             	add    $0x8,%edx
80105b11:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105b15:	85 c0                	test   %eax,%eax
80105b17:	75 18                	jne    80105b31 <fdalloc+0x3b>
      proc->ofile[fd] = f;
80105b19:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105b1f:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105b22:	8d 4a 08             	lea    0x8(%edx),%ecx
80105b25:	8b 55 08             	mov    0x8(%ebp),%edx
80105b28:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
80105b2c:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105b2f:	eb 0f                	jmp    80105b40 <fdalloc+0x4a>
static int
fdalloc(struct file *f)
{
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
80105b31:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105b35:	83 7d fc 0f          	cmpl   $0xf,-0x4(%ebp)
80105b39:	7e ca                	jle    80105b05 <fdalloc+0xf>
    if(proc->ofile[fd] == 0){
      proc->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
80105b3b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105b40:	c9                   	leave  
80105b41:	c3                   	ret    

80105b42 <sys_dup>:

int
sys_dup(void)
{
80105b42:	55                   	push   %ebp
80105b43:	89 e5                	mov    %esp,%ebp
80105b45:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int fd;
  
  if(argfd(0, 0, &f) < 0)
80105b48:	83 ec 04             	sub    $0x4,%esp
80105b4b:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105b4e:	50                   	push   %eax
80105b4f:	6a 00                	push   $0x0
80105b51:	6a 00                	push   $0x0
80105b53:	e8 29 ff ff ff       	call   80105a81 <argfd>
80105b58:	83 c4 10             	add    $0x10,%esp
80105b5b:	85 c0                	test   %eax,%eax
80105b5d:	79 07                	jns    80105b66 <sys_dup+0x24>
    return -1;
80105b5f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b64:	eb 31                	jmp    80105b97 <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
80105b66:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b69:	83 ec 0c             	sub    $0xc,%esp
80105b6c:	50                   	push   %eax
80105b6d:	e8 84 ff ff ff       	call   80105af6 <fdalloc>
80105b72:	83 c4 10             	add    $0x10,%esp
80105b75:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105b78:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105b7c:	79 07                	jns    80105b85 <sys_dup+0x43>
    return -1;
80105b7e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b83:	eb 12                	jmp    80105b97 <sys_dup+0x55>
  filedup(f);
80105b85:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b88:	83 ec 0c             	sub    $0xc,%esp
80105b8b:	50                   	push   %eax
80105b8c:	e8 6f b4 ff ff       	call   80101000 <filedup>
80105b91:	83 c4 10             	add    $0x10,%esp
  return fd;
80105b94:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105b97:	c9                   	leave  
80105b98:	c3                   	ret    

80105b99 <sys_read>:

int
sys_read(void)
{
80105b99:	55                   	push   %ebp
80105b9a:	89 e5                	mov    %esp,%ebp
80105b9c:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105b9f:	83 ec 04             	sub    $0x4,%esp
80105ba2:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105ba5:	50                   	push   %eax
80105ba6:	6a 00                	push   $0x0
80105ba8:	6a 00                	push   $0x0
80105baa:	e8 d2 fe ff ff       	call   80105a81 <argfd>
80105baf:	83 c4 10             	add    $0x10,%esp
80105bb2:	85 c0                	test   %eax,%eax
80105bb4:	78 2e                	js     80105be4 <sys_read+0x4b>
80105bb6:	83 ec 08             	sub    $0x8,%esp
80105bb9:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105bbc:	50                   	push   %eax
80105bbd:	6a 02                	push   $0x2
80105bbf:	e8 81 fd ff ff       	call   80105945 <argint>
80105bc4:	83 c4 10             	add    $0x10,%esp
80105bc7:	85 c0                	test   %eax,%eax
80105bc9:	78 19                	js     80105be4 <sys_read+0x4b>
80105bcb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bce:	83 ec 04             	sub    $0x4,%esp
80105bd1:	50                   	push   %eax
80105bd2:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105bd5:	50                   	push   %eax
80105bd6:	6a 01                	push   $0x1
80105bd8:	e8 90 fd ff ff       	call   8010596d <argptr>
80105bdd:	83 c4 10             	add    $0x10,%esp
80105be0:	85 c0                	test   %eax,%eax
80105be2:	79 07                	jns    80105beb <sys_read+0x52>
    return -1;
80105be4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105be9:	eb 17                	jmp    80105c02 <sys_read+0x69>
  return fileread(f, p, n);
80105beb:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105bee:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105bf1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bf4:	83 ec 04             	sub    $0x4,%esp
80105bf7:	51                   	push   %ecx
80105bf8:	52                   	push   %edx
80105bf9:	50                   	push   %eax
80105bfa:	e8 93 b5 ff ff       	call   80101192 <fileread>
80105bff:	83 c4 10             	add    $0x10,%esp
}
80105c02:	c9                   	leave  
80105c03:	c3                   	ret    

80105c04 <sys_write>:

int
sys_write(void)
{
80105c04:	55                   	push   %ebp
80105c05:	89 e5                	mov    %esp,%ebp
80105c07:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105c0a:	83 ec 04             	sub    $0x4,%esp
80105c0d:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105c10:	50                   	push   %eax
80105c11:	6a 00                	push   $0x0
80105c13:	6a 00                	push   $0x0
80105c15:	e8 67 fe ff ff       	call   80105a81 <argfd>
80105c1a:	83 c4 10             	add    $0x10,%esp
80105c1d:	85 c0                	test   %eax,%eax
80105c1f:	78 2e                	js     80105c4f <sys_write+0x4b>
80105c21:	83 ec 08             	sub    $0x8,%esp
80105c24:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105c27:	50                   	push   %eax
80105c28:	6a 02                	push   $0x2
80105c2a:	e8 16 fd ff ff       	call   80105945 <argint>
80105c2f:	83 c4 10             	add    $0x10,%esp
80105c32:	85 c0                	test   %eax,%eax
80105c34:	78 19                	js     80105c4f <sys_write+0x4b>
80105c36:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c39:	83 ec 04             	sub    $0x4,%esp
80105c3c:	50                   	push   %eax
80105c3d:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105c40:	50                   	push   %eax
80105c41:	6a 01                	push   $0x1
80105c43:	e8 25 fd ff ff       	call   8010596d <argptr>
80105c48:	83 c4 10             	add    $0x10,%esp
80105c4b:	85 c0                	test   %eax,%eax
80105c4d:	79 07                	jns    80105c56 <sys_write+0x52>
    return -1;
80105c4f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c54:	eb 17                	jmp    80105c6d <sys_write+0x69>
  return filewrite(f, p, n);
80105c56:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105c59:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105c5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c5f:	83 ec 04             	sub    $0x4,%esp
80105c62:	51                   	push   %ecx
80105c63:	52                   	push   %edx
80105c64:	50                   	push   %eax
80105c65:	e8 e0 b5 ff ff       	call   8010124a <filewrite>
80105c6a:	83 c4 10             	add    $0x10,%esp
}
80105c6d:	c9                   	leave  
80105c6e:	c3                   	ret    

80105c6f <sys_close>:

int
sys_close(void)
{
80105c6f:	55                   	push   %ebp
80105c70:	89 e5                	mov    %esp,%ebp
80105c72:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;
  
  if(argfd(0, &fd, &f) < 0)
80105c75:	83 ec 04             	sub    $0x4,%esp
80105c78:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105c7b:	50                   	push   %eax
80105c7c:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105c7f:	50                   	push   %eax
80105c80:	6a 00                	push   $0x0
80105c82:	e8 fa fd ff ff       	call   80105a81 <argfd>
80105c87:	83 c4 10             	add    $0x10,%esp
80105c8a:	85 c0                	test   %eax,%eax
80105c8c:	79 07                	jns    80105c95 <sys_close+0x26>
    return -1;
80105c8e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c93:	eb 28                	jmp    80105cbd <sys_close+0x4e>
  proc->ofile[fd] = 0;
80105c95:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105c9b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105c9e:	83 c2 08             	add    $0x8,%edx
80105ca1:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105ca8:	00 
  fileclose(f);
80105ca9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105cac:	83 ec 0c             	sub    $0xc,%esp
80105caf:	50                   	push   %eax
80105cb0:	e8 9c b3 ff ff       	call   80101051 <fileclose>
80105cb5:	83 c4 10             	add    $0x10,%esp
  return 0;
80105cb8:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105cbd:	c9                   	leave  
80105cbe:	c3                   	ret    

80105cbf <sys_fstat>:

int
sys_fstat(void)
{
80105cbf:	55                   	push   %ebp
80105cc0:	89 e5                	mov    %esp,%ebp
80105cc2:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  struct stat *st;
  
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80105cc5:	83 ec 04             	sub    $0x4,%esp
80105cc8:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105ccb:	50                   	push   %eax
80105ccc:	6a 00                	push   $0x0
80105cce:	6a 00                	push   $0x0
80105cd0:	e8 ac fd ff ff       	call   80105a81 <argfd>
80105cd5:	83 c4 10             	add    $0x10,%esp
80105cd8:	85 c0                	test   %eax,%eax
80105cda:	78 17                	js     80105cf3 <sys_fstat+0x34>
80105cdc:	83 ec 04             	sub    $0x4,%esp
80105cdf:	6a 14                	push   $0x14
80105ce1:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105ce4:	50                   	push   %eax
80105ce5:	6a 01                	push   $0x1
80105ce7:	e8 81 fc ff ff       	call   8010596d <argptr>
80105cec:	83 c4 10             	add    $0x10,%esp
80105cef:	85 c0                	test   %eax,%eax
80105cf1:	79 07                	jns    80105cfa <sys_fstat+0x3b>
    return -1;
80105cf3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105cf8:	eb 13                	jmp    80105d0d <sys_fstat+0x4e>
  return filestat(f, st);
80105cfa:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105cfd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d00:	83 ec 08             	sub    $0x8,%esp
80105d03:	52                   	push   %edx
80105d04:	50                   	push   %eax
80105d05:	e8 31 b4 ff ff       	call   8010113b <filestat>
80105d0a:	83 c4 10             	add    $0x10,%esp
}
80105d0d:	c9                   	leave  
80105d0e:	c3                   	ret    

80105d0f <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
80105d0f:	55                   	push   %ebp
80105d10:	89 e5                	mov    %esp,%ebp
80105d12:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80105d15:	83 ec 08             	sub    $0x8,%esp
80105d18:	8d 45 d8             	lea    -0x28(%ebp),%eax
80105d1b:	50                   	push   %eax
80105d1c:	6a 00                	push   $0x0
80105d1e:	e8 a7 fc ff ff       	call   801059ca <argstr>
80105d23:	83 c4 10             	add    $0x10,%esp
80105d26:	85 c0                	test   %eax,%eax
80105d28:	78 15                	js     80105d3f <sys_link+0x30>
80105d2a:	83 ec 08             	sub    $0x8,%esp
80105d2d:	8d 45 dc             	lea    -0x24(%ebp),%eax
80105d30:	50                   	push   %eax
80105d31:	6a 01                	push   $0x1
80105d33:	e8 92 fc ff ff       	call   801059ca <argstr>
80105d38:	83 c4 10             	add    $0x10,%esp
80105d3b:	85 c0                	test   %eax,%eax
80105d3d:	79 0a                	jns    80105d49 <sys_link+0x3a>
    return -1;
80105d3f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d44:	e9 68 01 00 00       	jmp    80105eb1 <sys_link+0x1a2>

  begin_op();
80105d49:	e8 bb db ff ff       	call   80103909 <begin_op>
  if((ip = namei(old)) == 0){
80105d4e:	8b 45 d8             	mov    -0x28(%ebp),%eax
80105d51:	83 ec 0c             	sub    $0xc,%esp
80105d54:	50                   	push   %eax
80105d55:	e8 66 cb ff ff       	call   801028c0 <namei>
80105d5a:	83 c4 10             	add    $0x10,%esp
80105d5d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105d60:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105d64:	75 0f                	jne    80105d75 <sys_link+0x66>
    end_op();
80105d66:	e8 2a dc ff ff       	call   80103995 <end_op>
    return -1;
80105d6b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d70:	e9 3c 01 00 00       	jmp    80105eb1 <sys_link+0x1a2>
  }

  ilock(ip);
80105d75:	83 ec 0c             	sub    $0xc,%esp
80105d78:	ff 75 f4             	pushl  -0xc(%ebp)
80105d7b:	e8 e4 be ff ff       	call   80101c64 <ilock>
80105d80:	83 c4 10             	add    $0x10,%esp
  if(ip->type == T_DIR){
80105d83:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d86:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105d8a:	66 83 f8 01          	cmp    $0x1,%ax
80105d8e:	75 1d                	jne    80105dad <sys_link+0x9e>
    iunlockput(ip);
80105d90:	83 ec 0c             	sub    $0xc,%esp
80105d93:	ff 75 f4             	pushl  -0xc(%ebp)
80105d96:	e8 cc c1 ff ff       	call   80101f67 <iunlockput>
80105d9b:	83 c4 10             	add    $0x10,%esp
    end_op();
80105d9e:	e8 f2 db ff ff       	call   80103995 <end_op>
    return -1;
80105da3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105da8:	e9 04 01 00 00       	jmp    80105eb1 <sys_link+0x1a2>
  }

  ip->nlink++;
80105dad:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105db0:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105db4:	83 c0 01             	add    $0x1,%eax
80105db7:	89 c2                	mov    %eax,%edx
80105db9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105dbc:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105dc0:	83 ec 0c             	sub    $0xc,%esp
80105dc3:	ff 75 f4             	pushl  -0xc(%ebp)
80105dc6:	e8 53 bc ff ff       	call   80101a1e <iupdate>
80105dcb:	83 c4 10             	add    $0x10,%esp
  iunlock(ip);
80105dce:	83 ec 0c             	sub    $0xc,%esp
80105dd1:	ff 75 f4             	pushl  -0xc(%ebp)
80105dd4:	e8 2c c0 ff ff       	call   80101e05 <iunlock>
80105dd9:	83 c4 10             	add    $0x10,%esp

  if((dp = nameiparent(new, name)) == 0)
80105ddc:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105ddf:	83 ec 08             	sub    $0x8,%esp
80105de2:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80105de5:	52                   	push   %edx
80105de6:	50                   	push   %eax
80105de7:	e8 f0 ca ff ff       	call   801028dc <nameiparent>
80105dec:	83 c4 10             	add    $0x10,%esp
80105def:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105df2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105df6:	74 71                	je     80105e69 <sys_link+0x15a>
    goto bad;
  ilock(dp);
80105df8:	83 ec 0c             	sub    $0xc,%esp
80105dfb:	ff 75 f0             	pushl  -0x10(%ebp)
80105dfe:	e8 61 be ff ff       	call   80101c64 <ilock>
80105e03:	83 c4 10             	add    $0x10,%esp
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80105e06:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e09:	8b 10                	mov    (%eax),%edx
80105e0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e0e:	8b 00                	mov    (%eax),%eax
80105e10:	39 c2                	cmp    %eax,%edx
80105e12:	75 1d                	jne    80105e31 <sys_link+0x122>
80105e14:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e17:	8b 40 04             	mov    0x4(%eax),%eax
80105e1a:	83 ec 04             	sub    $0x4,%esp
80105e1d:	50                   	push   %eax
80105e1e:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80105e21:	50                   	push   %eax
80105e22:	ff 75 f0             	pushl  -0x10(%ebp)
80105e25:	e8 f4 c7 ff ff       	call   8010261e <dirlink>
80105e2a:	83 c4 10             	add    $0x10,%esp
80105e2d:	85 c0                	test   %eax,%eax
80105e2f:	79 10                	jns    80105e41 <sys_link+0x132>
    iunlockput(dp);
80105e31:	83 ec 0c             	sub    $0xc,%esp
80105e34:	ff 75 f0             	pushl  -0x10(%ebp)
80105e37:	e8 2b c1 ff ff       	call   80101f67 <iunlockput>
80105e3c:	83 c4 10             	add    $0x10,%esp
    goto bad;
80105e3f:	eb 29                	jmp    80105e6a <sys_link+0x15b>
  }
  iunlockput(dp);
80105e41:	83 ec 0c             	sub    $0xc,%esp
80105e44:	ff 75 f0             	pushl  -0x10(%ebp)
80105e47:	e8 1b c1 ff ff       	call   80101f67 <iunlockput>
80105e4c:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80105e4f:	83 ec 0c             	sub    $0xc,%esp
80105e52:	ff 75 f4             	pushl  -0xc(%ebp)
80105e55:	e8 1d c0 ff ff       	call   80101e77 <iput>
80105e5a:	83 c4 10             	add    $0x10,%esp

  end_op();
80105e5d:	e8 33 db ff ff       	call   80103995 <end_op>

  return 0;
80105e62:	b8 00 00 00 00       	mov    $0x0,%eax
80105e67:	eb 48                	jmp    80105eb1 <sys_link+0x1a2>
  ip->nlink++;
  iupdate(ip);
  iunlock(ip);

  if((dp = nameiparent(new, name)) == 0)
    goto bad;
80105e69:	90                   	nop
  end_op();

  return 0;

bad:
  ilock(ip);
80105e6a:	83 ec 0c             	sub    $0xc,%esp
80105e6d:	ff 75 f4             	pushl  -0xc(%ebp)
80105e70:	e8 ef bd ff ff       	call   80101c64 <ilock>
80105e75:	83 c4 10             	add    $0x10,%esp
  ip->nlink--;
80105e78:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e7b:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105e7f:	83 e8 01             	sub    $0x1,%eax
80105e82:	89 c2                	mov    %eax,%edx
80105e84:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e87:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105e8b:	83 ec 0c             	sub    $0xc,%esp
80105e8e:	ff 75 f4             	pushl  -0xc(%ebp)
80105e91:	e8 88 bb ff ff       	call   80101a1e <iupdate>
80105e96:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80105e99:	83 ec 0c             	sub    $0xc,%esp
80105e9c:	ff 75 f4             	pushl  -0xc(%ebp)
80105e9f:	e8 c3 c0 ff ff       	call   80101f67 <iunlockput>
80105ea4:	83 c4 10             	add    $0x10,%esp
  end_op();
80105ea7:	e8 e9 da ff ff       	call   80103995 <end_op>
  return -1;
80105eac:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105eb1:	c9                   	leave  
80105eb2:	c3                   	ret    

80105eb3 <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80105eb3:	55                   	push   %ebp
80105eb4:	89 e5                	mov    %esp,%ebp
80105eb6:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105eb9:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80105ec0:	eb 40                	jmp    80105f02 <isdirempty+0x4f>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105ec2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ec5:	6a 10                	push   $0x10
80105ec7:	50                   	push   %eax
80105ec8:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105ecb:	50                   	push   %eax
80105ecc:	ff 75 08             	pushl  0x8(%ebp)
80105ecf:	e8 89 c3 ff ff       	call   8010225d <readi>
80105ed4:	83 c4 10             	add    $0x10,%esp
80105ed7:	83 f8 10             	cmp    $0x10,%eax
80105eda:	74 0d                	je     80105ee9 <isdirempty+0x36>
      panic("isdirempty: readi");
80105edc:	83 ec 0c             	sub    $0xc,%esp
80105edf:	68 73 8d 10 80       	push   $0x80108d73
80105ee4:	e8 7d a6 ff ff       	call   80100566 <panic>
    if(de.inum != 0)
80105ee9:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
80105eed:	66 85 c0             	test   %ax,%ax
80105ef0:	74 07                	je     80105ef9 <isdirempty+0x46>
      return 0;
80105ef2:	b8 00 00 00 00       	mov    $0x0,%eax
80105ef7:	eb 1b                	jmp    80105f14 <isdirempty+0x61>
isdirempty(struct inode *dp)
{
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105ef9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105efc:	83 c0 10             	add    $0x10,%eax
80105eff:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105f02:	8b 45 08             	mov    0x8(%ebp),%eax
80105f05:	8b 50 18             	mov    0x18(%eax),%edx
80105f08:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f0b:	39 c2                	cmp    %eax,%edx
80105f0d:	77 b3                	ja     80105ec2 <isdirempty+0xf>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("isdirempty: readi");
    if(de.inum != 0)
      return 0;
  }
  return 1;
80105f0f:	b8 01 00 00 00       	mov    $0x1,%eax
}
80105f14:	c9                   	leave  
80105f15:	c3                   	ret    

80105f16 <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80105f16:	55                   	push   %ebp
80105f17:	89 e5                	mov    %esp,%ebp
80105f19:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80105f1c:	83 ec 08             	sub    $0x8,%esp
80105f1f:	8d 45 cc             	lea    -0x34(%ebp),%eax
80105f22:	50                   	push   %eax
80105f23:	6a 00                	push   $0x0
80105f25:	e8 a0 fa ff ff       	call   801059ca <argstr>
80105f2a:	83 c4 10             	add    $0x10,%esp
80105f2d:	85 c0                	test   %eax,%eax
80105f2f:	79 0a                	jns    80105f3b <sys_unlink+0x25>
    return -1;
80105f31:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f36:	e9 bc 01 00 00       	jmp    801060f7 <sys_unlink+0x1e1>

  begin_op();
80105f3b:	e8 c9 d9 ff ff       	call   80103909 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80105f40:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105f43:	83 ec 08             	sub    $0x8,%esp
80105f46:	8d 55 d2             	lea    -0x2e(%ebp),%edx
80105f49:	52                   	push   %edx
80105f4a:	50                   	push   %eax
80105f4b:	e8 8c c9 ff ff       	call   801028dc <nameiparent>
80105f50:	83 c4 10             	add    $0x10,%esp
80105f53:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105f56:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105f5a:	75 0f                	jne    80105f6b <sys_unlink+0x55>
    end_op();
80105f5c:	e8 34 da ff ff       	call   80103995 <end_op>
    return -1;
80105f61:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f66:	e9 8c 01 00 00       	jmp    801060f7 <sys_unlink+0x1e1>
  }

  ilock(dp);
80105f6b:	83 ec 0c             	sub    $0xc,%esp
80105f6e:	ff 75 f4             	pushl  -0xc(%ebp)
80105f71:	e8 ee bc ff ff       	call   80101c64 <ilock>
80105f76:	83 c4 10             	add    $0x10,%esp

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80105f79:	83 ec 08             	sub    $0x8,%esp
80105f7c:	68 85 8d 10 80       	push   $0x80108d85
80105f81:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105f84:	50                   	push   %eax
80105f85:	e8 b2 c5 ff ff       	call   8010253c <namecmp>
80105f8a:	83 c4 10             	add    $0x10,%esp
80105f8d:	85 c0                	test   %eax,%eax
80105f8f:	0f 84 4a 01 00 00    	je     801060df <sys_unlink+0x1c9>
80105f95:	83 ec 08             	sub    $0x8,%esp
80105f98:	68 87 8d 10 80       	push   $0x80108d87
80105f9d:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105fa0:	50                   	push   %eax
80105fa1:	e8 96 c5 ff ff       	call   8010253c <namecmp>
80105fa6:	83 c4 10             	add    $0x10,%esp
80105fa9:	85 c0                	test   %eax,%eax
80105fab:	0f 84 2e 01 00 00    	je     801060df <sys_unlink+0x1c9>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80105fb1:	83 ec 04             	sub    $0x4,%esp
80105fb4:	8d 45 c8             	lea    -0x38(%ebp),%eax
80105fb7:	50                   	push   %eax
80105fb8:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105fbb:	50                   	push   %eax
80105fbc:	ff 75 f4             	pushl  -0xc(%ebp)
80105fbf:	e8 93 c5 ff ff       	call   80102557 <dirlookup>
80105fc4:	83 c4 10             	add    $0x10,%esp
80105fc7:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105fca:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105fce:	0f 84 0a 01 00 00    	je     801060de <sys_unlink+0x1c8>
    goto bad;
  ilock(ip);
80105fd4:	83 ec 0c             	sub    $0xc,%esp
80105fd7:	ff 75 f0             	pushl  -0x10(%ebp)
80105fda:	e8 85 bc ff ff       	call   80101c64 <ilock>
80105fdf:	83 c4 10             	add    $0x10,%esp

  if(ip->nlink < 1)
80105fe2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fe5:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105fe9:	66 85 c0             	test   %ax,%ax
80105fec:	7f 0d                	jg     80105ffb <sys_unlink+0xe5>
    panic("unlink: nlink < 1");
80105fee:	83 ec 0c             	sub    $0xc,%esp
80105ff1:	68 8a 8d 10 80       	push   $0x80108d8a
80105ff6:	e8 6b a5 ff ff       	call   80100566 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80105ffb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ffe:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106002:	66 83 f8 01          	cmp    $0x1,%ax
80106006:	75 25                	jne    8010602d <sys_unlink+0x117>
80106008:	83 ec 0c             	sub    $0xc,%esp
8010600b:	ff 75 f0             	pushl  -0x10(%ebp)
8010600e:	e8 a0 fe ff ff       	call   80105eb3 <isdirempty>
80106013:	83 c4 10             	add    $0x10,%esp
80106016:	85 c0                	test   %eax,%eax
80106018:	75 13                	jne    8010602d <sys_unlink+0x117>
    iunlockput(ip);
8010601a:	83 ec 0c             	sub    $0xc,%esp
8010601d:	ff 75 f0             	pushl  -0x10(%ebp)
80106020:	e8 42 bf ff ff       	call   80101f67 <iunlockput>
80106025:	83 c4 10             	add    $0x10,%esp
    goto bad;
80106028:	e9 b2 00 00 00       	jmp    801060df <sys_unlink+0x1c9>
  }

  memset(&de, 0, sizeof(de));
8010602d:	83 ec 04             	sub    $0x4,%esp
80106030:	6a 10                	push   $0x10
80106032:	6a 00                	push   $0x0
80106034:	8d 45 e0             	lea    -0x20(%ebp),%eax
80106037:	50                   	push   %eax
80106038:	e8 e3 f5 ff ff       	call   80105620 <memset>
8010603d:	83 c4 10             	add    $0x10,%esp
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80106040:	8b 45 c8             	mov    -0x38(%ebp),%eax
80106043:	6a 10                	push   $0x10
80106045:	50                   	push   %eax
80106046:	8d 45 e0             	lea    -0x20(%ebp),%eax
80106049:	50                   	push   %eax
8010604a:	ff 75 f4             	pushl  -0xc(%ebp)
8010604d:	e8 62 c3 ff ff       	call   801023b4 <writei>
80106052:	83 c4 10             	add    $0x10,%esp
80106055:	83 f8 10             	cmp    $0x10,%eax
80106058:	74 0d                	je     80106067 <sys_unlink+0x151>
    panic("unlink: writei");
8010605a:	83 ec 0c             	sub    $0xc,%esp
8010605d:	68 9c 8d 10 80       	push   $0x80108d9c
80106062:	e8 ff a4 ff ff       	call   80100566 <panic>
  if(ip->type == T_DIR){
80106067:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010606a:	0f b7 40 10          	movzwl 0x10(%eax),%eax
8010606e:	66 83 f8 01          	cmp    $0x1,%ax
80106072:	75 21                	jne    80106095 <sys_unlink+0x17f>
    dp->nlink--;
80106074:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106077:	0f b7 40 16          	movzwl 0x16(%eax),%eax
8010607b:	83 e8 01             	sub    $0x1,%eax
8010607e:	89 c2                	mov    %eax,%edx
80106080:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106083:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
80106087:	83 ec 0c             	sub    $0xc,%esp
8010608a:	ff 75 f4             	pushl  -0xc(%ebp)
8010608d:	e8 8c b9 ff ff       	call   80101a1e <iupdate>
80106092:	83 c4 10             	add    $0x10,%esp
  }
  iunlockput(dp);
80106095:	83 ec 0c             	sub    $0xc,%esp
80106098:	ff 75 f4             	pushl  -0xc(%ebp)
8010609b:	e8 c7 be ff ff       	call   80101f67 <iunlockput>
801060a0:	83 c4 10             	add    $0x10,%esp

  ip->nlink--;
801060a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060a6:	0f b7 40 16          	movzwl 0x16(%eax),%eax
801060aa:	83 e8 01             	sub    $0x1,%eax
801060ad:	89 c2                	mov    %eax,%edx
801060af:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060b2:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
801060b6:	83 ec 0c             	sub    $0xc,%esp
801060b9:	ff 75 f0             	pushl  -0x10(%ebp)
801060bc:	e8 5d b9 ff ff       	call   80101a1e <iupdate>
801060c1:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
801060c4:	83 ec 0c             	sub    $0xc,%esp
801060c7:	ff 75 f0             	pushl  -0x10(%ebp)
801060ca:	e8 98 be ff ff       	call   80101f67 <iunlockput>
801060cf:	83 c4 10             	add    $0x10,%esp

  end_op();
801060d2:	e8 be d8 ff ff       	call   80103995 <end_op>

  return 0;
801060d7:	b8 00 00 00 00       	mov    $0x0,%eax
801060dc:	eb 19                	jmp    801060f7 <sys_unlink+0x1e1>
  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
    goto bad;
801060de:	90                   	nop
  end_op();

  return 0;

bad:
  iunlockput(dp);
801060df:	83 ec 0c             	sub    $0xc,%esp
801060e2:	ff 75 f4             	pushl  -0xc(%ebp)
801060e5:	e8 7d be ff ff       	call   80101f67 <iunlockput>
801060ea:	83 c4 10             	add    $0x10,%esp
  end_op();
801060ed:	e8 a3 d8 ff ff       	call   80103995 <end_op>
  return -1;
801060f2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801060f7:	c9                   	leave  
801060f8:	c3                   	ret    

801060f9 <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
801060f9:	55                   	push   %ebp
801060fa:	89 e5                	mov    %esp,%ebp
801060fc:	83 ec 38             	sub    $0x38,%esp
801060ff:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80106102:	8b 55 10             	mov    0x10(%ebp),%edx
80106105:	8b 45 14             	mov    0x14(%ebp),%eax
80106108:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
8010610c:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
80106110:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80106114:	83 ec 08             	sub    $0x8,%esp
80106117:	8d 45 de             	lea    -0x22(%ebp),%eax
8010611a:	50                   	push   %eax
8010611b:	ff 75 08             	pushl  0x8(%ebp)
8010611e:	e8 b9 c7 ff ff       	call   801028dc <nameiparent>
80106123:	83 c4 10             	add    $0x10,%esp
80106126:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106129:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010612d:	75 0a                	jne    80106139 <create+0x40>
    return 0;
8010612f:	b8 00 00 00 00       	mov    $0x0,%eax
80106134:	e9 9c 01 00 00       	jmp    801062d5 <create+0x1dc>
  ilock(dp);
80106139:	83 ec 0c             	sub    $0xc,%esp
8010613c:	ff 75 f4             	pushl  -0xc(%ebp)
8010613f:	e8 20 bb ff ff       	call   80101c64 <ilock>
80106144:	83 c4 10             	add    $0x10,%esp

  if((ip = dirlookup(dp, name, &off)) != 0){
80106147:	83 ec 04             	sub    $0x4,%esp
8010614a:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010614d:	50                   	push   %eax
8010614e:	8d 45 de             	lea    -0x22(%ebp),%eax
80106151:	50                   	push   %eax
80106152:	ff 75 f4             	pushl  -0xc(%ebp)
80106155:	e8 fd c3 ff ff       	call   80102557 <dirlookup>
8010615a:	83 c4 10             	add    $0x10,%esp
8010615d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106160:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106164:	74 50                	je     801061b6 <create+0xbd>
    iunlockput(dp);
80106166:	83 ec 0c             	sub    $0xc,%esp
80106169:	ff 75 f4             	pushl  -0xc(%ebp)
8010616c:	e8 f6 bd ff ff       	call   80101f67 <iunlockput>
80106171:	83 c4 10             	add    $0x10,%esp
    ilock(ip);
80106174:	83 ec 0c             	sub    $0xc,%esp
80106177:	ff 75 f0             	pushl  -0x10(%ebp)
8010617a:	e8 e5 ba ff ff       	call   80101c64 <ilock>
8010617f:	83 c4 10             	add    $0x10,%esp
    if(type == T_FILE && ip->type == T_FILE)
80106182:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80106187:	75 15                	jne    8010619e <create+0xa5>
80106189:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010618c:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106190:	66 83 f8 02          	cmp    $0x2,%ax
80106194:	75 08                	jne    8010619e <create+0xa5>
      return ip;
80106196:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106199:	e9 37 01 00 00       	jmp    801062d5 <create+0x1dc>
    iunlockput(ip);
8010619e:	83 ec 0c             	sub    $0xc,%esp
801061a1:	ff 75 f0             	pushl  -0x10(%ebp)
801061a4:	e8 be bd ff ff       	call   80101f67 <iunlockput>
801061a9:	83 c4 10             	add    $0x10,%esp
    return 0;
801061ac:	b8 00 00 00 00       	mov    $0x0,%eax
801061b1:	e9 1f 01 00 00       	jmp    801062d5 <create+0x1dc>
  }

  if((ip = ialloc(dp->dev, type,dp->part->number)) == 0)
801061b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061b9:	8b 40 50             	mov    0x50(%eax),%eax
801061bc:	8b 40 14             	mov    0x14(%eax),%eax
801061bf:	89 c1                	mov    %eax,%ecx
801061c1:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
801061c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061c8:	8b 00                	mov    (%eax),%eax
801061ca:	83 ec 04             	sub    $0x4,%esp
801061cd:	51                   	push   %ecx
801061ce:	52                   	push   %edx
801061cf:	50                   	push   %eax
801061d0:	e8 34 b7 ff ff       	call   80101909 <ialloc>
801061d5:	83 c4 10             	add    $0x10,%esp
801061d8:	89 45 f0             	mov    %eax,-0x10(%ebp)
801061db:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801061df:	75 0d                	jne    801061ee <create+0xf5>
    panic("create: ialloc");
801061e1:	83 ec 0c             	sub    $0xc,%esp
801061e4:	68 ab 8d 10 80       	push   $0x80108dab
801061e9:	e8 78 a3 ff ff       	call   80100566 <panic>

  ilock(ip);
801061ee:	83 ec 0c             	sub    $0xc,%esp
801061f1:	ff 75 f0             	pushl  -0x10(%ebp)
801061f4:	e8 6b ba ff ff       	call   80101c64 <ilock>
801061f9:	83 c4 10             	add    $0x10,%esp
  ip->major = major;
801061fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061ff:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
80106203:	66 89 50 12          	mov    %dx,0x12(%eax)
  ip->minor = minor;
80106207:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010620a:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
8010620e:	66 89 50 14          	mov    %dx,0x14(%eax)
  ip->nlink = 1;
80106212:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106215:	66 c7 40 16 01 00    	movw   $0x1,0x16(%eax)
  iupdate(ip);
8010621b:	83 ec 0c             	sub    $0xc,%esp
8010621e:	ff 75 f0             	pushl  -0x10(%ebp)
80106221:	e8 f8 b7 ff ff       	call   80101a1e <iupdate>
80106226:	83 c4 10             	add    $0x10,%esp

  if(type == T_DIR){  // Create . and .. entries.
80106229:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
8010622e:	75 6a                	jne    8010629a <create+0x1a1>
    dp->nlink++;  // for ".."
80106230:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106233:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80106237:	83 c0 01             	add    $0x1,%eax
8010623a:	89 c2                	mov    %eax,%edx
8010623c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010623f:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
80106243:	83 ec 0c             	sub    $0xc,%esp
80106246:	ff 75 f4             	pushl  -0xc(%ebp)
80106249:	e8 d0 b7 ff ff       	call   80101a1e <iupdate>
8010624e:	83 c4 10             	add    $0x10,%esp
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80106251:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106254:	8b 40 04             	mov    0x4(%eax),%eax
80106257:	83 ec 04             	sub    $0x4,%esp
8010625a:	50                   	push   %eax
8010625b:	68 85 8d 10 80       	push   $0x80108d85
80106260:	ff 75 f0             	pushl  -0x10(%ebp)
80106263:	e8 b6 c3 ff ff       	call   8010261e <dirlink>
80106268:	83 c4 10             	add    $0x10,%esp
8010626b:	85 c0                	test   %eax,%eax
8010626d:	78 1e                	js     8010628d <create+0x194>
8010626f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106272:	8b 40 04             	mov    0x4(%eax),%eax
80106275:	83 ec 04             	sub    $0x4,%esp
80106278:	50                   	push   %eax
80106279:	68 87 8d 10 80       	push   $0x80108d87
8010627e:	ff 75 f0             	pushl  -0x10(%ebp)
80106281:	e8 98 c3 ff ff       	call   8010261e <dirlink>
80106286:	83 c4 10             	add    $0x10,%esp
80106289:	85 c0                	test   %eax,%eax
8010628b:	79 0d                	jns    8010629a <create+0x1a1>
      panic("create dots");
8010628d:	83 ec 0c             	sub    $0xc,%esp
80106290:	68 ba 8d 10 80       	push   $0x80108dba
80106295:	e8 cc a2 ff ff       	call   80100566 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
8010629a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010629d:	8b 40 04             	mov    0x4(%eax),%eax
801062a0:	83 ec 04             	sub    $0x4,%esp
801062a3:	50                   	push   %eax
801062a4:	8d 45 de             	lea    -0x22(%ebp),%eax
801062a7:	50                   	push   %eax
801062a8:	ff 75 f4             	pushl  -0xc(%ebp)
801062ab:	e8 6e c3 ff ff       	call   8010261e <dirlink>
801062b0:	83 c4 10             	add    $0x10,%esp
801062b3:	85 c0                	test   %eax,%eax
801062b5:	79 0d                	jns    801062c4 <create+0x1cb>
    panic("create: dirlink");
801062b7:	83 ec 0c             	sub    $0xc,%esp
801062ba:	68 c6 8d 10 80       	push   $0x80108dc6
801062bf:	e8 a2 a2 ff ff       	call   80100566 <panic>

  iunlockput(dp);
801062c4:	83 ec 0c             	sub    $0xc,%esp
801062c7:	ff 75 f4             	pushl  -0xc(%ebp)
801062ca:	e8 98 bc ff ff       	call   80101f67 <iunlockput>
801062cf:	83 c4 10             	add    $0x10,%esp

  return ip;
801062d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
801062d5:	c9                   	leave  
801062d6:	c3                   	ret    

801062d7 <sys_open>:

int
sys_open(void)
{
801062d7:	55                   	push   %ebp
801062d8:	89 e5                	mov    %esp,%ebp
801062da:	83 ec 28             	sub    $0x28,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
801062dd:	83 ec 08             	sub    $0x8,%esp
801062e0:	8d 45 e8             	lea    -0x18(%ebp),%eax
801062e3:	50                   	push   %eax
801062e4:	6a 00                	push   $0x0
801062e6:	e8 df f6 ff ff       	call   801059ca <argstr>
801062eb:	83 c4 10             	add    $0x10,%esp
801062ee:	85 c0                	test   %eax,%eax
801062f0:	78 15                	js     80106307 <sys_open+0x30>
801062f2:	83 ec 08             	sub    $0x8,%esp
801062f5:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801062f8:	50                   	push   %eax
801062f9:	6a 01                	push   $0x1
801062fb:	e8 45 f6 ff ff       	call   80105945 <argint>
80106300:	83 c4 10             	add    $0x10,%esp
80106303:	85 c0                	test   %eax,%eax
80106305:	79 0a                	jns    80106311 <sys_open+0x3a>
    return -1;
80106307:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010630c:	e9 61 01 00 00       	jmp    80106472 <sys_open+0x19b>

  begin_op();
80106311:	e8 f3 d5 ff ff       	call   80103909 <begin_op>

  if(omode & O_CREATE){
80106316:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106319:	25 00 02 00 00       	and    $0x200,%eax
8010631e:	85 c0                	test   %eax,%eax
80106320:	74 2a                	je     8010634c <sys_open+0x75>
    ip = create(path, T_FILE, 0, 0);
80106322:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106325:	6a 00                	push   $0x0
80106327:	6a 00                	push   $0x0
80106329:	6a 02                	push   $0x2
8010632b:	50                   	push   %eax
8010632c:	e8 c8 fd ff ff       	call   801060f9 <create>
80106331:	83 c4 10             	add    $0x10,%esp
80106334:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
80106337:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010633b:	75 75                	jne    801063b2 <sys_open+0xdb>
      end_op();
8010633d:	e8 53 d6 ff ff       	call   80103995 <end_op>
      return -1;
80106342:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106347:	e9 26 01 00 00       	jmp    80106472 <sys_open+0x19b>
    }
  } else {
    if((ip = namei(path)) == 0){
8010634c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010634f:	83 ec 0c             	sub    $0xc,%esp
80106352:	50                   	push   %eax
80106353:	e8 68 c5 ff ff       	call   801028c0 <namei>
80106358:	83 c4 10             	add    $0x10,%esp
8010635b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010635e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106362:	75 0f                	jne    80106373 <sys_open+0x9c>
      end_op();
80106364:	e8 2c d6 ff ff       	call   80103995 <end_op>
      return -1;
80106369:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010636e:	e9 ff 00 00 00       	jmp    80106472 <sys_open+0x19b>
    }
    ilock(ip);
80106373:	83 ec 0c             	sub    $0xc,%esp
80106376:	ff 75 f4             	pushl  -0xc(%ebp)
80106379:	e8 e6 b8 ff ff       	call   80101c64 <ilock>
8010637e:	83 c4 10             	add    $0x10,%esp
    if(ip->type == T_DIR && omode != O_RDONLY){
80106381:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106384:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106388:	66 83 f8 01          	cmp    $0x1,%ax
8010638c:	75 24                	jne    801063b2 <sys_open+0xdb>
8010638e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106391:	85 c0                	test   %eax,%eax
80106393:	74 1d                	je     801063b2 <sys_open+0xdb>
      iunlockput(ip);
80106395:	83 ec 0c             	sub    $0xc,%esp
80106398:	ff 75 f4             	pushl  -0xc(%ebp)
8010639b:	e8 c7 bb ff ff       	call   80101f67 <iunlockput>
801063a0:	83 c4 10             	add    $0x10,%esp
      end_op();
801063a3:	e8 ed d5 ff ff       	call   80103995 <end_op>
      return -1;
801063a8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063ad:	e9 c0 00 00 00       	jmp    80106472 <sys_open+0x19b>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
801063b2:	e8 dc ab ff ff       	call   80100f93 <filealloc>
801063b7:	89 45 f0             	mov    %eax,-0x10(%ebp)
801063ba:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801063be:	74 17                	je     801063d7 <sys_open+0x100>
801063c0:	83 ec 0c             	sub    $0xc,%esp
801063c3:	ff 75 f0             	pushl  -0x10(%ebp)
801063c6:	e8 2b f7 ff ff       	call   80105af6 <fdalloc>
801063cb:	83 c4 10             	add    $0x10,%esp
801063ce:	89 45 ec             	mov    %eax,-0x14(%ebp)
801063d1:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801063d5:	79 2e                	jns    80106405 <sys_open+0x12e>
    if(f)
801063d7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801063db:	74 0e                	je     801063eb <sys_open+0x114>
      fileclose(f);
801063dd:	83 ec 0c             	sub    $0xc,%esp
801063e0:	ff 75 f0             	pushl  -0x10(%ebp)
801063e3:	e8 69 ac ff ff       	call   80101051 <fileclose>
801063e8:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
801063eb:	83 ec 0c             	sub    $0xc,%esp
801063ee:	ff 75 f4             	pushl  -0xc(%ebp)
801063f1:	e8 71 bb ff ff       	call   80101f67 <iunlockput>
801063f6:	83 c4 10             	add    $0x10,%esp
    end_op();
801063f9:	e8 97 d5 ff ff       	call   80103995 <end_op>
    return -1;
801063fe:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106403:	eb 6d                	jmp    80106472 <sys_open+0x19b>
  }
  iunlock(ip);
80106405:	83 ec 0c             	sub    $0xc,%esp
80106408:	ff 75 f4             	pushl  -0xc(%ebp)
8010640b:	e8 f5 b9 ff ff       	call   80101e05 <iunlock>
80106410:	83 c4 10             	add    $0x10,%esp
  end_op();
80106413:	e8 7d d5 ff ff       	call   80103995 <end_op>

  f->type = FD_INODE;
80106418:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010641b:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
80106421:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106424:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106427:	89 50 0e             	mov    %edx,0xe(%eax)
  f->off = 0;
8010642a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010642d:	c7 40 12 00 00 00 00 	movl   $0x0,0x12(%eax)
  f->readable = !(omode & O_WRONLY);
80106434:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106437:	83 e0 01             	and    $0x1,%eax
8010643a:	85 c0                	test   %eax,%eax
8010643c:	0f 94 c0             	sete   %al
8010643f:	89 c2                	mov    %eax,%edx
80106441:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106444:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80106447:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010644a:	83 e0 01             	and    $0x1,%eax
8010644d:	85 c0                	test   %eax,%eax
8010644f:	75 0a                	jne    8010645b <sys_open+0x184>
80106451:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106454:	83 e0 02             	and    $0x2,%eax
80106457:	85 c0                	test   %eax,%eax
80106459:	74 07                	je     80106462 <sys_open+0x18b>
8010645b:	b8 01 00 00 00       	mov    $0x1,%eax
80106460:	eb 05                	jmp    80106467 <sys_open+0x190>
80106462:	b8 00 00 00 00       	mov    $0x0,%eax
80106467:	89 c2                	mov    %eax,%edx
80106469:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010646c:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
8010646f:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80106472:	c9                   	leave  
80106473:	c3                   	ret    

80106474 <sys_mkdir>:

int
sys_mkdir(void)
{
80106474:	55                   	push   %ebp
80106475:	89 e5                	mov    %esp,%ebp
80106477:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
8010647a:	e8 8a d4 ff ff       	call   80103909 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
8010647f:	83 ec 08             	sub    $0x8,%esp
80106482:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106485:	50                   	push   %eax
80106486:	6a 00                	push   $0x0
80106488:	e8 3d f5 ff ff       	call   801059ca <argstr>
8010648d:	83 c4 10             	add    $0x10,%esp
80106490:	85 c0                	test   %eax,%eax
80106492:	78 1b                	js     801064af <sys_mkdir+0x3b>
80106494:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106497:	6a 00                	push   $0x0
80106499:	6a 00                	push   $0x0
8010649b:	6a 01                	push   $0x1
8010649d:	50                   	push   %eax
8010649e:	e8 56 fc ff ff       	call   801060f9 <create>
801064a3:	83 c4 10             	add    $0x10,%esp
801064a6:	89 45 f4             	mov    %eax,-0xc(%ebp)
801064a9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801064ad:	75 0c                	jne    801064bb <sys_mkdir+0x47>
    end_op();
801064af:	e8 e1 d4 ff ff       	call   80103995 <end_op>
    return -1;
801064b4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064b9:	eb 18                	jmp    801064d3 <sys_mkdir+0x5f>
  }
  iunlockput(ip);
801064bb:	83 ec 0c             	sub    $0xc,%esp
801064be:	ff 75 f4             	pushl  -0xc(%ebp)
801064c1:	e8 a1 ba ff ff       	call   80101f67 <iunlockput>
801064c6:	83 c4 10             	add    $0x10,%esp
  end_op();
801064c9:	e8 c7 d4 ff ff       	call   80103995 <end_op>
  return 0;
801064ce:	b8 00 00 00 00       	mov    $0x0,%eax
}
801064d3:	c9                   	leave  
801064d4:	c3                   	ret    

801064d5 <sys_mknod>:

int
sys_mknod(void)
{
801064d5:	55                   	push   %ebp
801064d6:	89 e5                	mov    %esp,%ebp
801064d8:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip;
  char *path;
  int len;
  int major, minor;
  
  begin_op();
801064db:	e8 29 d4 ff ff       	call   80103909 <begin_op>
  if((len=argstr(0, &path)) < 0 ||
801064e0:	83 ec 08             	sub    $0x8,%esp
801064e3:	8d 45 ec             	lea    -0x14(%ebp),%eax
801064e6:	50                   	push   %eax
801064e7:	6a 00                	push   $0x0
801064e9:	e8 dc f4 ff ff       	call   801059ca <argstr>
801064ee:	83 c4 10             	add    $0x10,%esp
801064f1:	89 45 f4             	mov    %eax,-0xc(%ebp)
801064f4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801064f8:	78 4f                	js     80106549 <sys_mknod+0x74>
     argint(1, &major) < 0 ||
801064fa:	83 ec 08             	sub    $0x8,%esp
801064fd:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106500:	50                   	push   %eax
80106501:	6a 01                	push   $0x1
80106503:	e8 3d f4 ff ff       	call   80105945 <argint>
80106508:	83 c4 10             	add    $0x10,%esp
  char *path;
  int len;
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
8010650b:	85 c0                	test   %eax,%eax
8010650d:	78 3a                	js     80106549 <sys_mknod+0x74>
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
8010650f:	83 ec 08             	sub    $0x8,%esp
80106512:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106515:	50                   	push   %eax
80106516:	6a 02                	push   $0x2
80106518:	e8 28 f4 ff ff       	call   80105945 <argint>
8010651d:	83 c4 10             	add    $0x10,%esp
  int len;
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
80106520:	85 c0                	test   %eax,%eax
80106522:	78 25                	js     80106549 <sys_mknod+0x74>
     argint(2, &minor) < 0 ||
     (ip = create(path, T_DEV, major, minor)) == 0){
80106524:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106527:	0f bf c8             	movswl %ax,%ecx
8010652a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010652d:	0f bf d0             	movswl %ax,%edx
80106530:	8b 45 ec             	mov    -0x14(%ebp),%eax
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
80106533:	51                   	push   %ecx
80106534:	52                   	push   %edx
80106535:	6a 03                	push   $0x3
80106537:	50                   	push   %eax
80106538:	e8 bc fb ff ff       	call   801060f9 <create>
8010653d:	83 c4 10             	add    $0x10,%esp
80106540:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106543:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106547:	75 0c                	jne    80106555 <sys_mknod+0x80>
     (ip = create(path, T_DEV, major, minor)) == 0){
    end_op();
80106549:	e8 47 d4 ff ff       	call   80103995 <end_op>
    return -1;
8010654e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106553:	eb 18                	jmp    8010656d <sys_mknod+0x98>
  }
  iunlockput(ip);
80106555:	83 ec 0c             	sub    $0xc,%esp
80106558:	ff 75 f0             	pushl  -0x10(%ebp)
8010655b:	e8 07 ba ff ff       	call   80101f67 <iunlockput>
80106560:	83 c4 10             	add    $0x10,%esp
  end_op();
80106563:	e8 2d d4 ff ff       	call   80103995 <end_op>
  return 0;
80106568:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010656d:	c9                   	leave  
8010656e:	c3                   	ret    

8010656f <sys_chdir>:

int
sys_chdir(void)
{
8010656f:	55                   	push   %ebp
80106570:	89 e5                	mov    %esp,%ebp
80106572:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80106575:	e8 8f d3 ff ff       	call   80103909 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
8010657a:	83 ec 08             	sub    $0x8,%esp
8010657d:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106580:	50                   	push   %eax
80106581:	6a 00                	push   $0x0
80106583:	e8 42 f4 ff ff       	call   801059ca <argstr>
80106588:	83 c4 10             	add    $0x10,%esp
8010658b:	85 c0                	test   %eax,%eax
8010658d:	78 18                	js     801065a7 <sys_chdir+0x38>
8010658f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106592:	83 ec 0c             	sub    $0xc,%esp
80106595:	50                   	push   %eax
80106596:	e8 25 c3 ff ff       	call   801028c0 <namei>
8010659b:	83 c4 10             	add    $0x10,%esp
8010659e:	89 45 f4             	mov    %eax,-0xc(%ebp)
801065a1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801065a5:	75 0c                	jne    801065b3 <sys_chdir+0x44>
    end_op();
801065a7:	e8 e9 d3 ff ff       	call   80103995 <end_op>
    return -1;
801065ac:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065b1:	eb 6e                	jmp    80106621 <sys_chdir+0xb2>
  }
  ilock(ip);
801065b3:	83 ec 0c             	sub    $0xc,%esp
801065b6:	ff 75 f4             	pushl  -0xc(%ebp)
801065b9:	e8 a6 b6 ff ff       	call   80101c64 <ilock>
801065be:	83 c4 10             	add    $0x10,%esp
  if(ip->type != T_DIR){
801065c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065c4:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801065c8:	66 83 f8 01          	cmp    $0x1,%ax
801065cc:	74 1a                	je     801065e8 <sys_chdir+0x79>
    iunlockput(ip);
801065ce:	83 ec 0c             	sub    $0xc,%esp
801065d1:	ff 75 f4             	pushl  -0xc(%ebp)
801065d4:	e8 8e b9 ff ff       	call   80101f67 <iunlockput>
801065d9:	83 c4 10             	add    $0x10,%esp
    end_op();
801065dc:	e8 b4 d3 ff ff       	call   80103995 <end_op>
    return -1;
801065e1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065e6:	eb 39                	jmp    80106621 <sys_chdir+0xb2>
  }
  iunlock(ip);
801065e8:	83 ec 0c             	sub    $0xc,%esp
801065eb:	ff 75 f4             	pushl  -0xc(%ebp)
801065ee:	e8 12 b8 ff ff       	call   80101e05 <iunlock>
801065f3:	83 c4 10             	add    $0x10,%esp
  iput(proc->cwd);
801065f6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801065fc:	8b 40 68             	mov    0x68(%eax),%eax
801065ff:	83 ec 0c             	sub    $0xc,%esp
80106602:	50                   	push   %eax
80106603:	e8 6f b8 ff ff       	call   80101e77 <iput>
80106608:	83 c4 10             	add    $0x10,%esp
  end_op();
8010660b:	e8 85 d3 ff ff       	call   80103995 <end_op>
  proc->cwd = ip;
80106610:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106616:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106619:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
8010661c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106621:	c9                   	leave  
80106622:	c3                   	ret    

80106623 <sys_exec>:

int
sys_exec(void)
{
80106623:	55                   	push   %ebp
80106624:	89 e5                	mov    %esp,%ebp
80106626:	81 ec 98 00 00 00    	sub    $0x98,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
8010662c:	83 ec 08             	sub    $0x8,%esp
8010662f:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106632:	50                   	push   %eax
80106633:	6a 00                	push   $0x0
80106635:	e8 90 f3 ff ff       	call   801059ca <argstr>
8010663a:	83 c4 10             	add    $0x10,%esp
8010663d:	85 c0                	test   %eax,%eax
8010663f:	78 18                	js     80106659 <sys_exec+0x36>
80106641:	83 ec 08             	sub    $0x8,%esp
80106644:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
8010664a:	50                   	push   %eax
8010664b:	6a 01                	push   $0x1
8010664d:	e8 f3 f2 ff ff       	call   80105945 <argint>
80106652:	83 c4 10             	add    $0x10,%esp
80106655:	85 c0                	test   %eax,%eax
80106657:	79 0a                	jns    80106663 <sys_exec+0x40>
    return -1;
80106659:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010665e:	e9 c6 00 00 00       	jmp    80106729 <sys_exec+0x106>
  }
  memset(argv, 0, sizeof(argv));
80106663:	83 ec 04             	sub    $0x4,%esp
80106666:	68 80 00 00 00       	push   $0x80
8010666b:	6a 00                	push   $0x0
8010666d:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106673:	50                   	push   %eax
80106674:	e8 a7 ef ff ff       	call   80105620 <memset>
80106679:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
8010667c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
80106683:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106686:	83 f8 1f             	cmp    $0x1f,%eax
80106689:	76 0a                	jbe    80106695 <sys_exec+0x72>
      return -1;
8010668b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106690:	e9 94 00 00 00       	jmp    80106729 <sys_exec+0x106>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80106695:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106698:	c1 e0 02             	shl    $0x2,%eax
8010669b:	89 c2                	mov    %eax,%edx
8010669d:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
801066a3:	01 c2                	add    %eax,%edx
801066a5:	83 ec 08             	sub    $0x8,%esp
801066a8:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
801066ae:	50                   	push   %eax
801066af:	52                   	push   %edx
801066b0:	e8 f4 f1 ff ff       	call   801058a9 <fetchint>
801066b5:	83 c4 10             	add    $0x10,%esp
801066b8:	85 c0                	test   %eax,%eax
801066ba:	79 07                	jns    801066c3 <sys_exec+0xa0>
      return -1;
801066bc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801066c1:	eb 66                	jmp    80106729 <sys_exec+0x106>
    if(uarg == 0){
801066c3:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
801066c9:	85 c0                	test   %eax,%eax
801066cb:	75 27                	jne    801066f4 <sys_exec+0xd1>
      argv[i] = 0;
801066cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066d0:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
801066d7:	00 00 00 00 
      break;
801066db:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
801066dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801066df:	83 ec 08             	sub    $0x8,%esp
801066e2:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
801066e8:	52                   	push   %edx
801066e9:	50                   	push   %eax
801066ea:	e8 82 a4 ff ff       	call   80100b71 <exec>
801066ef:	83 c4 10             	add    $0x10,%esp
801066f2:	eb 35                	jmp    80106729 <sys_exec+0x106>
      return -1;
    if(uarg == 0){
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
801066f4:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
801066fa:	8b 55 f4             	mov    -0xc(%ebp),%edx
801066fd:	c1 e2 02             	shl    $0x2,%edx
80106700:	01 c2                	add    %eax,%edx
80106702:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106708:	83 ec 08             	sub    $0x8,%esp
8010670b:	52                   	push   %edx
8010670c:	50                   	push   %eax
8010670d:	e8 d1 f1 ff ff       	call   801058e3 <fetchstr>
80106712:	83 c4 10             	add    $0x10,%esp
80106715:	85 c0                	test   %eax,%eax
80106717:	79 07                	jns    80106720 <sys_exec+0xfd>
      return -1;
80106719:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010671e:	eb 09                	jmp    80106729 <sys_exec+0x106>

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
80106720:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
80106724:	e9 5a ff ff ff       	jmp    80106683 <sys_exec+0x60>
  return exec(path, argv);
}
80106729:	c9                   	leave  
8010672a:	c3                   	ret    

8010672b <sys_pipe>:

int
sys_pipe(void)
{
8010672b:	55                   	push   %ebp
8010672c:	89 e5                	mov    %esp,%ebp
8010672e:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80106731:	83 ec 04             	sub    $0x4,%esp
80106734:	6a 08                	push   $0x8
80106736:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106739:	50                   	push   %eax
8010673a:	6a 00                	push   $0x0
8010673c:	e8 2c f2 ff ff       	call   8010596d <argptr>
80106741:	83 c4 10             	add    $0x10,%esp
80106744:	85 c0                	test   %eax,%eax
80106746:	79 0a                	jns    80106752 <sys_pipe+0x27>
    return -1;
80106748:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010674d:	e9 af 00 00 00       	jmp    80106801 <sys_pipe+0xd6>
  if(pipealloc(&rf, &wf) < 0)
80106752:	83 ec 08             	sub    $0x8,%esp
80106755:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106758:	50                   	push   %eax
80106759:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010675c:	50                   	push   %eax
8010675d:	e8 9b dc ff ff       	call   801043fd <pipealloc>
80106762:	83 c4 10             	add    $0x10,%esp
80106765:	85 c0                	test   %eax,%eax
80106767:	79 0a                	jns    80106773 <sys_pipe+0x48>
    return -1;
80106769:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010676e:	e9 8e 00 00 00       	jmp    80106801 <sys_pipe+0xd6>
  fd0 = -1;
80106773:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
8010677a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010677d:	83 ec 0c             	sub    $0xc,%esp
80106780:	50                   	push   %eax
80106781:	e8 70 f3 ff ff       	call   80105af6 <fdalloc>
80106786:	83 c4 10             	add    $0x10,%esp
80106789:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010678c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106790:	78 18                	js     801067aa <sys_pipe+0x7f>
80106792:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106795:	83 ec 0c             	sub    $0xc,%esp
80106798:	50                   	push   %eax
80106799:	e8 58 f3 ff ff       	call   80105af6 <fdalloc>
8010679e:	83 c4 10             	add    $0x10,%esp
801067a1:	89 45 f0             	mov    %eax,-0x10(%ebp)
801067a4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801067a8:	79 3f                	jns    801067e9 <sys_pipe+0xbe>
    if(fd0 >= 0)
801067aa:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801067ae:	78 14                	js     801067c4 <sys_pipe+0x99>
      proc->ofile[fd0] = 0;
801067b0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801067b6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801067b9:	83 c2 08             	add    $0x8,%edx
801067bc:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801067c3:	00 
    fileclose(rf);
801067c4:	8b 45 e8             	mov    -0x18(%ebp),%eax
801067c7:	83 ec 0c             	sub    $0xc,%esp
801067ca:	50                   	push   %eax
801067cb:	e8 81 a8 ff ff       	call   80101051 <fileclose>
801067d0:	83 c4 10             	add    $0x10,%esp
    fileclose(wf);
801067d3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801067d6:	83 ec 0c             	sub    $0xc,%esp
801067d9:	50                   	push   %eax
801067da:	e8 72 a8 ff ff       	call   80101051 <fileclose>
801067df:	83 c4 10             	add    $0x10,%esp
    return -1;
801067e2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801067e7:	eb 18                	jmp    80106801 <sys_pipe+0xd6>
  }
  fd[0] = fd0;
801067e9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801067ec:	8b 55 f4             	mov    -0xc(%ebp),%edx
801067ef:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
801067f1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801067f4:	8d 50 04             	lea    0x4(%eax),%edx
801067f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801067fa:	89 02                	mov    %eax,(%edx)
  return 0;
801067fc:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106801:	c9                   	leave  
80106802:	c3                   	ret    

80106803 <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
80106803:	55                   	push   %ebp
80106804:	89 e5                	mov    %esp,%ebp
80106806:	83 ec 08             	sub    $0x8,%esp
  return fork();
80106809:	e8 e5 e2 ff ff       	call   80104af3 <fork>
}
8010680e:	c9                   	leave  
8010680f:	c3                   	ret    

80106810 <sys_exit>:

int
sys_exit(void)
{
80106810:	55                   	push   %ebp
80106811:	89 e5                	mov    %esp,%ebp
80106813:	83 ec 08             	sub    $0x8,%esp
  exit();
80106816:	e8 69 e4 ff ff       	call   80104c84 <exit>
  return 0;  // not reached
8010681b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106820:	c9                   	leave  
80106821:	c3                   	ret    

80106822 <sys_wait>:

int
sys_wait(void)
{
80106822:	55                   	push   %ebp
80106823:	89 e5                	mov    %esp,%ebp
80106825:	83 ec 08             	sub    $0x8,%esp
  return wait();
80106828:	e8 8f e5 ff ff       	call   80104dbc <wait>
}
8010682d:	c9                   	leave  
8010682e:	c3                   	ret    

8010682f <sys_kill>:

int
sys_kill(void)
{
8010682f:	55                   	push   %ebp
80106830:	89 e5                	mov    %esp,%ebp
80106832:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
80106835:	83 ec 08             	sub    $0x8,%esp
80106838:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010683b:	50                   	push   %eax
8010683c:	6a 00                	push   $0x0
8010683e:	e8 02 f1 ff ff       	call   80105945 <argint>
80106843:	83 c4 10             	add    $0x10,%esp
80106846:	85 c0                	test   %eax,%eax
80106848:	79 07                	jns    80106851 <sys_kill+0x22>
    return -1;
8010684a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010684f:	eb 0f                	jmp    80106860 <sys_kill+0x31>
  return kill(pid);
80106851:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106854:	83 ec 0c             	sub    $0xc,%esp
80106857:	50                   	push   %eax
80106858:	e8 89 e9 ff ff       	call   801051e6 <kill>
8010685d:	83 c4 10             	add    $0x10,%esp
}
80106860:	c9                   	leave  
80106861:	c3                   	ret    

80106862 <sys_getpid>:

int
sys_getpid(void)
{
80106862:	55                   	push   %ebp
80106863:	89 e5                	mov    %esp,%ebp
  return proc->pid;
80106865:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010686b:	8b 40 10             	mov    0x10(%eax),%eax
}
8010686e:	5d                   	pop    %ebp
8010686f:	c3                   	ret    

80106870 <sys_sbrk>:

int
sys_sbrk(void)
{
80106870:	55                   	push   %ebp
80106871:	89 e5                	mov    %esp,%ebp
80106873:	83 ec 18             	sub    $0x18,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80106876:	83 ec 08             	sub    $0x8,%esp
80106879:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010687c:	50                   	push   %eax
8010687d:	6a 00                	push   $0x0
8010687f:	e8 c1 f0 ff ff       	call   80105945 <argint>
80106884:	83 c4 10             	add    $0x10,%esp
80106887:	85 c0                	test   %eax,%eax
80106889:	79 07                	jns    80106892 <sys_sbrk+0x22>
    return -1;
8010688b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106890:	eb 28                	jmp    801068ba <sys_sbrk+0x4a>
  addr = proc->sz;
80106892:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106898:	8b 00                	mov    (%eax),%eax
8010689a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
8010689d:	8b 45 f0             	mov    -0x10(%ebp),%eax
801068a0:	83 ec 0c             	sub    $0xc,%esp
801068a3:	50                   	push   %eax
801068a4:	e8 a7 e1 ff ff       	call   80104a50 <growproc>
801068a9:	83 c4 10             	add    $0x10,%esp
801068ac:	85 c0                	test   %eax,%eax
801068ae:	79 07                	jns    801068b7 <sys_sbrk+0x47>
    return -1;
801068b0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801068b5:	eb 03                	jmp    801068ba <sys_sbrk+0x4a>
  return addr;
801068b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801068ba:	c9                   	leave  
801068bb:	c3                   	ret    

801068bc <sys_sleep>:

int
sys_sleep(void)
{
801068bc:	55                   	push   %ebp
801068bd:	89 e5                	mov    %esp,%ebp
801068bf:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;
  
  if(argint(0, &n) < 0)
801068c2:	83 ec 08             	sub    $0x8,%esp
801068c5:	8d 45 f0             	lea    -0x10(%ebp),%eax
801068c8:	50                   	push   %eax
801068c9:	6a 00                	push   $0x0
801068cb:	e8 75 f0 ff ff       	call   80105945 <argint>
801068d0:	83 c4 10             	add    $0x10,%esp
801068d3:	85 c0                	test   %eax,%eax
801068d5:	79 07                	jns    801068de <sys_sleep+0x22>
    return -1;
801068d7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801068dc:	eb 77                	jmp    80106955 <sys_sleep+0x99>
  acquire(&tickslock);
801068de:	83 ec 0c             	sub    $0xc,%esp
801068e1:	68 80 4b 11 80       	push   $0x80114b80
801068e6:	e8 d2 ea ff ff       	call   801053bd <acquire>
801068eb:	83 c4 10             	add    $0x10,%esp
  ticks0 = ticks;
801068ee:	a1 c0 53 11 80       	mov    0x801153c0,%eax
801068f3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
801068f6:	eb 39                	jmp    80106931 <sys_sleep+0x75>
    if(proc->killed){
801068f8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801068fe:	8b 40 24             	mov    0x24(%eax),%eax
80106901:	85 c0                	test   %eax,%eax
80106903:	74 17                	je     8010691c <sys_sleep+0x60>
      release(&tickslock);
80106905:	83 ec 0c             	sub    $0xc,%esp
80106908:	68 80 4b 11 80       	push   $0x80114b80
8010690d:	e8 12 eb ff ff       	call   80105424 <release>
80106912:	83 c4 10             	add    $0x10,%esp
      return -1;
80106915:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010691a:	eb 39                	jmp    80106955 <sys_sleep+0x99>
    }
    sleep(&ticks, &tickslock);
8010691c:	83 ec 08             	sub    $0x8,%esp
8010691f:	68 80 4b 11 80       	push   $0x80114b80
80106924:	68 c0 53 11 80       	push   $0x801153c0
80106929:	e8 96 e7 ff ff       	call   801050c4 <sleep>
8010692e:	83 c4 10             	add    $0x10,%esp
  
  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
80106931:	a1 c0 53 11 80       	mov    0x801153c0,%eax
80106936:	2b 45 f4             	sub    -0xc(%ebp),%eax
80106939:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010693c:	39 d0                	cmp    %edx,%eax
8010693e:	72 b8                	jb     801068f8 <sys_sleep+0x3c>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
80106940:	83 ec 0c             	sub    $0xc,%esp
80106943:	68 80 4b 11 80       	push   $0x80114b80
80106948:	e8 d7 ea ff ff       	call   80105424 <release>
8010694d:	83 c4 10             	add    $0x10,%esp
  return 0;
80106950:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106955:	c9                   	leave  
80106956:	c3                   	ret    

80106957 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80106957:	55                   	push   %ebp
80106958:	89 e5                	mov    %esp,%ebp
8010695a:	83 ec 18             	sub    $0x18,%esp
  uint xticks;
  
  acquire(&tickslock);
8010695d:	83 ec 0c             	sub    $0xc,%esp
80106960:	68 80 4b 11 80       	push   $0x80114b80
80106965:	e8 53 ea ff ff       	call   801053bd <acquire>
8010696a:	83 c4 10             	add    $0x10,%esp
  xticks = ticks;
8010696d:	a1 c0 53 11 80       	mov    0x801153c0,%eax
80106972:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
80106975:	83 ec 0c             	sub    $0xc,%esp
80106978:	68 80 4b 11 80       	push   $0x80114b80
8010697d:	e8 a2 ea ff ff       	call   80105424 <release>
80106982:	83 c4 10             	add    $0x10,%esp
  return xticks;
80106985:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106988:	c9                   	leave  
80106989:	c3                   	ret    

8010698a <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
8010698a:	55                   	push   %ebp
8010698b:	89 e5                	mov    %esp,%ebp
8010698d:	83 ec 08             	sub    $0x8,%esp
80106990:	8b 55 08             	mov    0x8(%ebp),%edx
80106993:	8b 45 0c             	mov    0xc(%ebp),%eax
80106996:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
8010699a:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010699d:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801069a1:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801069a5:	ee                   	out    %al,(%dx)
}
801069a6:	90                   	nop
801069a7:	c9                   	leave  
801069a8:	c3                   	ret    

801069a9 <timerinit>:
#define TIMER_RATEGEN   0x04    // mode 2, rate generator
#define TIMER_16BIT     0x30    // r/w counter 16 bits, LSB first

void
timerinit(void)
{
801069a9:	55                   	push   %ebp
801069aa:	89 e5                	mov    %esp,%ebp
801069ac:	83 ec 08             	sub    $0x8,%esp
  // Interrupt 100 times/sec.
  outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
801069af:	6a 34                	push   $0x34
801069b1:	6a 43                	push   $0x43
801069b3:	e8 d2 ff ff ff       	call   8010698a <outb>
801069b8:	83 c4 08             	add    $0x8,%esp
  outb(IO_TIMER1, TIMER_DIV(100) % 256);
801069bb:	68 9c 00 00 00       	push   $0x9c
801069c0:	6a 40                	push   $0x40
801069c2:	e8 c3 ff ff ff       	call   8010698a <outb>
801069c7:	83 c4 08             	add    $0x8,%esp
  outb(IO_TIMER1, TIMER_DIV(100) / 256);
801069ca:	6a 2e                	push   $0x2e
801069cc:	6a 40                	push   $0x40
801069ce:	e8 b7 ff ff ff       	call   8010698a <outb>
801069d3:	83 c4 08             	add    $0x8,%esp
  picenable(IRQ_TIMER);
801069d6:	83 ec 0c             	sub    $0xc,%esp
801069d9:	6a 00                	push   $0x0
801069db:	e8 07 d9 ff ff       	call   801042e7 <picenable>
801069e0:	83 c4 10             	add    $0x10,%esp
}
801069e3:	90                   	nop
801069e4:	c9                   	leave  
801069e5:	c3                   	ret    

801069e6 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
801069e6:	1e                   	push   %ds
  pushl %es
801069e7:	06                   	push   %es
  pushl %fs
801069e8:	0f a0                	push   %fs
  pushl %gs
801069ea:	0f a8                	push   %gs
  pushal
801069ec:	60                   	pusha  
  
  # Set up data and per-cpu segments.
  movw $(SEG_KDATA<<3), %ax
801069ed:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
801069f1:	8e d8                	mov    %eax,%ds
  movw %ax, %es
801069f3:	8e c0                	mov    %eax,%es
  movw $(SEG_KCPU<<3), %ax
801069f5:	66 b8 18 00          	mov    $0x18,%ax
  movw %ax, %fs
801069f9:	8e e0                	mov    %eax,%fs
  movw %ax, %gs
801069fb:	8e e8                	mov    %eax,%gs

  # Call trap(tf), where tf=%esp
  pushl %esp
801069fd:	54                   	push   %esp
  call trap
801069fe:	e8 d7 01 00 00       	call   80106bda <trap>
  addl $4, %esp
80106a03:	83 c4 04             	add    $0x4,%esp

80106a06 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80106a06:	61                   	popa   
  popl %gs
80106a07:	0f a9                	pop    %gs
  popl %fs
80106a09:	0f a1                	pop    %fs
  popl %es
80106a0b:	07                   	pop    %es
  popl %ds
80106a0c:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80106a0d:	83 c4 08             	add    $0x8,%esp
  iret
80106a10:	cf                   	iret   

80106a11 <lidt>:

struct gatedesc;

static inline void
lidt(struct gatedesc *p, int size)
{
80106a11:	55                   	push   %ebp
80106a12:	89 e5                	mov    %esp,%ebp
80106a14:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
80106a17:	8b 45 0c             	mov    0xc(%ebp),%eax
80106a1a:	83 e8 01             	sub    $0x1,%eax
80106a1d:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80106a21:	8b 45 08             	mov    0x8(%ebp),%eax
80106a24:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80106a28:	8b 45 08             	mov    0x8(%ebp),%eax
80106a2b:	c1 e8 10             	shr    $0x10,%eax
80106a2e:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lidt (%0)" : : "r" (pd));
80106a32:	8d 45 fa             	lea    -0x6(%ebp),%eax
80106a35:	0f 01 18             	lidtl  (%eax)
}
80106a38:	90                   	nop
80106a39:	c9                   	leave  
80106a3a:	c3                   	ret    

80106a3b <rcr2>:
  return result;
}

static inline uint
rcr2(void)
{
80106a3b:	55                   	push   %ebp
80106a3c:	89 e5                	mov    %esp,%ebp
80106a3e:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80106a41:	0f 20 d0             	mov    %cr2,%eax
80106a44:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
80106a47:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106a4a:	c9                   	leave  
80106a4b:	c3                   	ret    

80106a4c <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80106a4c:	55                   	push   %ebp
80106a4d:	89 e5                	mov    %esp,%ebp
80106a4f:	83 ec 18             	sub    $0x18,%esp
  int i;

  for(i = 0; i < 256; i++)
80106a52:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106a59:	e9 c3 00 00 00       	jmp    80106b21 <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80106a5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a61:	8b 04 85 98 b0 10 80 	mov    -0x7fef4f68(,%eax,4),%eax
80106a68:	89 c2                	mov    %eax,%edx
80106a6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a6d:	66 89 14 c5 c0 4b 11 	mov    %dx,-0x7feeb440(,%eax,8)
80106a74:	80 
80106a75:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a78:	66 c7 04 c5 c2 4b 11 	movw   $0x8,-0x7feeb43e(,%eax,8)
80106a7f:	80 08 00 
80106a82:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a85:	0f b6 14 c5 c4 4b 11 	movzbl -0x7feeb43c(,%eax,8),%edx
80106a8c:	80 
80106a8d:	83 e2 e0             	and    $0xffffffe0,%edx
80106a90:	88 14 c5 c4 4b 11 80 	mov    %dl,-0x7feeb43c(,%eax,8)
80106a97:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a9a:	0f b6 14 c5 c4 4b 11 	movzbl -0x7feeb43c(,%eax,8),%edx
80106aa1:	80 
80106aa2:	83 e2 1f             	and    $0x1f,%edx
80106aa5:	88 14 c5 c4 4b 11 80 	mov    %dl,-0x7feeb43c(,%eax,8)
80106aac:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106aaf:	0f b6 14 c5 c5 4b 11 	movzbl -0x7feeb43b(,%eax,8),%edx
80106ab6:	80 
80106ab7:	83 e2 f0             	and    $0xfffffff0,%edx
80106aba:	83 ca 0e             	or     $0xe,%edx
80106abd:	88 14 c5 c5 4b 11 80 	mov    %dl,-0x7feeb43b(,%eax,8)
80106ac4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ac7:	0f b6 14 c5 c5 4b 11 	movzbl -0x7feeb43b(,%eax,8),%edx
80106ace:	80 
80106acf:	83 e2 ef             	and    $0xffffffef,%edx
80106ad2:	88 14 c5 c5 4b 11 80 	mov    %dl,-0x7feeb43b(,%eax,8)
80106ad9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106adc:	0f b6 14 c5 c5 4b 11 	movzbl -0x7feeb43b(,%eax,8),%edx
80106ae3:	80 
80106ae4:	83 e2 9f             	and    $0xffffff9f,%edx
80106ae7:	88 14 c5 c5 4b 11 80 	mov    %dl,-0x7feeb43b(,%eax,8)
80106aee:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106af1:	0f b6 14 c5 c5 4b 11 	movzbl -0x7feeb43b(,%eax,8),%edx
80106af8:	80 
80106af9:	83 ca 80             	or     $0xffffff80,%edx
80106afc:	88 14 c5 c5 4b 11 80 	mov    %dl,-0x7feeb43b(,%eax,8)
80106b03:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b06:	8b 04 85 98 b0 10 80 	mov    -0x7fef4f68(,%eax,4),%eax
80106b0d:	c1 e8 10             	shr    $0x10,%eax
80106b10:	89 c2                	mov    %eax,%edx
80106b12:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b15:	66 89 14 c5 c6 4b 11 	mov    %dx,-0x7feeb43a(,%eax,8)
80106b1c:	80 
void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
80106b1d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106b21:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80106b28:	0f 8e 30 ff ff ff    	jle    80106a5e <tvinit+0x12>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80106b2e:	a1 98 b1 10 80       	mov    0x8010b198,%eax
80106b33:	66 a3 c0 4d 11 80    	mov    %ax,0x80114dc0
80106b39:	66 c7 05 c2 4d 11 80 	movw   $0x8,0x80114dc2
80106b40:	08 00 
80106b42:	0f b6 05 c4 4d 11 80 	movzbl 0x80114dc4,%eax
80106b49:	83 e0 e0             	and    $0xffffffe0,%eax
80106b4c:	a2 c4 4d 11 80       	mov    %al,0x80114dc4
80106b51:	0f b6 05 c4 4d 11 80 	movzbl 0x80114dc4,%eax
80106b58:	83 e0 1f             	and    $0x1f,%eax
80106b5b:	a2 c4 4d 11 80       	mov    %al,0x80114dc4
80106b60:	0f b6 05 c5 4d 11 80 	movzbl 0x80114dc5,%eax
80106b67:	83 c8 0f             	or     $0xf,%eax
80106b6a:	a2 c5 4d 11 80       	mov    %al,0x80114dc5
80106b6f:	0f b6 05 c5 4d 11 80 	movzbl 0x80114dc5,%eax
80106b76:	83 e0 ef             	and    $0xffffffef,%eax
80106b79:	a2 c5 4d 11 80       	mov    %al,0x80114dc5
80106b7e:	0f b6 05 c5 4d 11 80 	movzbl 0x80114dc5,%eax
80106b85:	83 c8 60             	or     $0x60,%eax
80106b88:	a2 c5 4d 11 80       	mov    %al,0x80114dc5
80106b8d:	0f b6 05 c5 4d 11 80 	movzbl 0x80114dc5,%eax
80106b94:	83 c8 80             	or     $0xffffff80,%eax
80106b97:	a2 c5 4d 11 80       	mov    %al,0x80114dc5
80106b9c:	a1 98 b1 10 80       	mov    0x8010b198,%eax
80106ba1:	c1 e8 10             	shr    $0x10,%eax
80106ba4:	66 a3 c6 4d 11 80    	mov    %ax,0x80114dc6
  
  initlock(&tickslock, "time");
80106baa:	83 ec 08             	sub    $0x8,%esp
80106bad:	68 d8 8d 10 80       	push   $0x80108dd8
80106bb2:	68 80 4b 11 80       	push   $0x80114b80
80106bb7:	e8 df e7 ff ff       	call   8010539b <initlock>
80106bbc:	83 c4 10             	add    $0x10,%esp
}
80106bbf:	90                   	nop
80106bc0:	c9                   	leave  
80106bc1:	c3                   	ret    

80106bc2 <idtinit>:

void
idtinit(void)
{
80106bc2:	55                   	push   %ebp
80106bc3:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
80106bc5:	68 00 08 00 00       	push   $0x800
80106bca:	68 c0 4b 11 80       	push   $0x80114bc0
80106bcf:	e8 3d fe ff ff       	call   80106a11 <lidt>
80106bd4:	83 c4 08             	add    $0x8,%esp
}
80106bd7:	90                   	nop
80106bd8:	c9                   	leave  
80106bd9:	c3                   	ret    

80106bda <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80106bda:	55                   	push   %ebp
80106bdb:	89 e5                	mov    %esp,%ebp
80106bdd:	57                   	push   %edi
80106bde:	56                   	push   %esi
80106bdf:	53                   	push   %ebx
80106be0:	83 ec 1c             	sub    $0x1c,%esp
  if(tf->trapno == T_SYSCALL){
80106be3:	8b 45 08             	mov    0x8(%ebp),%eax
80106be6:	8b 40 30             	mov    0x30(%eax),%eax
80106be9:	83 f8 40             	cmp    $0x40,%eax
80106bec:	75 3e                	jne    80106c2c <trap+0x52>
    if(proc->killed)
80106bee:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106bf4:	8b 40 24             	mov    0x24(%eax),%eax
80106bf7:	85 c0                	test   %eax,%eax
80106bf9:	74 05                	je     80106c00 <trap+0x26>
      exit();
80106bfb:	e8 84 e0 ff ff       	call   80104c84 <exit>
    proc->tf = tf;
80106c00:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106c06:	8b 55 08             	mov    0x8(%ebp),%edx
80106c09:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
80106c0c:	e8 ea ed ff ff       	call   801059fb <syscall>
    if(proc->killed)
80106c11:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106c17:	8b 40 24             	mov    0x24(%eax),%eax
80106c1a:	85 c0                	test   %eax,%eax
80106c1c:	0f 84 1b 02 00 00    	je     80106e3d <trap+0x263>
      exit();
80106c22:	e8 5d e0 ff ff       	call   80104c84 <exit>
    return;
80106c27:	e9 11 02 00 00       	jmp    80106e3d <trap+0x263>
  }

  switch(tf->trapno){
80106c2c:	8b 45 08             	mov    0x8(%ebp),%eax
80106c2f:	8b 40 30             	mov    0x30(%eax),%eax
80106c32:	83 e8 20             	sub    $0x20,%eax
80106c35:	83 f8 1f             	cmp    $0x1f,%eax
80106c38:	0f 87 c0 00 00 00    	ja     80106cfe <trap+0x124>
80106c3e:	8b 04 85 80 8e 10 80 	mov    -0x7fef7180(,%eax,4),%eax
80106c45:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpu->id == 0){
80106c47:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106c4d:	0f b6 00             	movzbl (%eax),%eax
80106c50:	84 c0                	test   %al,%al
80106c52:	75 3d                	jne    80106c91 <trap+0xb7>
      acquire(&tickslock);
80106c54:	83 ec 0c             	sub    $0xc,%esp
80106c57:	68 80 4b 11 80       	push   $0x80114b80
80106c5c:	e8 5c e7 ff ff       	call   801053bd <acquire>
80106c61:	83 c4 10             	add    $0x10,%esp
      ticks++;
80106c64:	a1 c0 53 11 80       	mov    0x801153c0,%eax
80106c69:	83 c0 01             	add    $0x1,%eax
80106c6c:	a3 c0 53 11 80       	mov    %eax,0x801153c0
      wakeup(&ticks);
80106c71:	83 ec 0c             	sub    $0xc,%esp
80106c74:	68 c0 53 11 80       	push   $0x801153c0
80106c79:	e8 31 e5 ff ff       	call   801051af <wakeup>
80106c7e:	83 c4 10             	add    $0x10,%esp
      release(&tickslock);
80106c81:	83 ec 0c             	sub    $0xc,%esp
80106c84:	68 80 4b 11 80       	push   $0x80114b80
80106c89:	e8 96 e7 ff ff       	call   80105424 <release>
80106c8e:	83 c4 10             	add    $0x10,%esp
    }
    lapiceoi();
80106c91:	e8 27 c7 ff ff       	call   801033bd <lapiceoi>
    break;
80106c96:	e9 1c 01 00 00       	jmp    80106db7 <trap+0x1dd>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
80106c9b:	e8 30 bf ff ff       	call   80102bd0 <ideintr>
    lapiceoi();
80106ca0:	e8 18 c7 ff ff       	call   801033bd <lapiceoi>
    break;
80106ca5:	e9 0d 01 00 00       	jmp    80106db7 <trap+0x1dd>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
80106caa:	e8 10 c5 ff ff       	call   801031bf <kbdintr>
    lapiceoi();
80106caf:	e8 09 c7 ff ff       	call   801033bd <lapiceoi>
    break;
80106cb4:	e9 fe 00 00 00       	jmp    80106db7 <trap+0x1dd>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
80106cb9:	e8 60 03 00 00       	call   8010701e <uartintr>
    lapiceoi();
80106cbe:	e8 fa c6 ff ff       	call   801033bd <lapiceoi>
    break;
80106cc3:	e9 ef 00 00 00       	jmp    80106db7 <trap+0x1dd>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106cc8:	8b 45 08             	mov    0x8(%ebp),%eax
80106ccb:	8b 48 38             	mov    0x38(%eax),%ecx
            cpu->id, tf->cs, tf->eip);
80106cce:	8b 45 08             	mov    0x8(%ebp),%eax
80106cd1:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106cd5:	0f b7 d0             	movzwl %ax,%edx
            cpu->id, tf->cs, tf->eip);
80106cd8:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106cde:	0f b6 00             	movzbl (%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106ce1:	0f b6 c0             	movzbl %al,%eax
80106ce4:	51                   	push   %ecx
80106ce5:	52                   	push   %edx
80106ce6:	50                   	push   %eax
80106ce7:	68 e0 8d 10 80       	push   $0x80108de0
80106cec:	e8 d5 96 ff ff       	call   801003c6 <cprintf>
80106cf1:	83 c4 10             	add    $0x10,%esp
            cpu->id, tf->cs, tf->eip);
    lapiceoi();
80106cf4:	e8 c4 c6 ff ff       	call   801033bd <lapiceoi>
    break;
80106cf9:	e9 b9 00 00 00       	jmp    80106db7 <trap+0x1dd>
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
80106cfe:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106d04:	85 c0                	test   %eax,%eax
80106d06:	74 11                	je     80106d19 <trap+0x13f>
80106d08:	8b 45 08             	mov    0x8(%ebp),%eax
80106d0b:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106d0f:	0f b7 c0             	movzwl %ax,%eax
80106d12:	83 e0 03             	and    $0x3,%eax
80106d15:	85 c0                	test   %eax,%eax
80106d17:	75 40                	jne    80106d59 <trap+0x17f>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106d19:	e8 1d fd ff ff       	call   80106a3b <rcr2>
80106d1e:	89 c3                	mov    %eax,%ebx
80106d20:	8b 45 08             	mov    0x8(%ebp),%eax
80106d23:	8b 48 38             	mov    0x38(%eax),%ecx
              tf->trapno, cpu->id, tf->eip, rcr2());
80106d26:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106d2c:	0f b6 00             	movzbl (%eax),%eax
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106d2f:	0f b6 d0             	movzbl %al,%edx
80106d32:	8b 45 08             	mov    0x8(%ebp),%eax
80106d35:	8b 40 30             	mov    0x30(%eax),%eax
80106d38:	83 ec 0c             	sub    $0xc,%esp
80106d3b:	53                   	push   %ebx
80106d3c:	51                   	push   %ecx
80106d3d:	52                   	push   %edx
80106d3e:	50                   	push   %eax
80106d3f:	68 04 8e 10 80       	push   $0x80108e04
80106d44:	e8 7d 96 ff ff       	call   801003c6 <cprintf>
80106d49:	83 c4 20             	add    $0x20,%esp
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
80106d4c:	83 ec 0c             	sub    $0xc,%esp
80106d4f:	68 36 8e 10 80       	push   $0x80108e36
80106d54:	e8 0d 98 ff ff       	call   80100566 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106d59:	e8 dd fc ff ff       	call   80106a3b <rcr2>
80106d5e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80106d61:	8b 45 08             	mov    0x8(%ebp),%eax
80106d64:	8b 70 38             	mov    0x38(%eax),%esi
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106d67:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106d6d:	0f b6 00             	movzbl (%eax),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106d70:	0f b6 d8             	movzbl %al,%ebx
80106d73:	8b 45 08             	mov    0x8(%ebp),%eax
80106d76:	8b 48 34             	mov    0x34(%eax),%ecx
80106d79:	8b 45 08             	mov    0x8(%ebp),%eax
80106d7c:	8b 50 30             	mov    0x30(%eax),%edx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106d7f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106d85:	8d 78 6c             	lea    0x6c(%eax),%edi
80106d88:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106d8e:	8b 40 10             	mov    0x10(%eax),%eax
80106d91:	ff 75 e4             	pushl  -0x1c(%ebp)
80106d94:	56                   	push   %esi
80106d95:	53                   	push   %ebx
80106d96:	51                   	push   %ecx
80106d97:	52                   	push   %edx
80106d98:	57                   	push   %edi
80106d99:	50                   	push   %eax
80106d9a:	68 3c 8e 10 80       	push   $0x80108e3c
80106d9f:	e8 22 96 ff ff       	call   801003c6 <cprintf>
80106da4:	83 c4 20             	add    $0x20,%esp
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
            rcr2());
    proc->killed = 1;
80106da7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106dad:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80106db4:	eb 01                	jmp    80106db7 <trap+0x1dd>
    ideintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
80106db6:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running 
  // until it gets to the regular system call return.)
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80106db7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106dbd:	85 c0                	test   %eax,%eax
80106dbf:	74 24                	je     80106de5 <trap+0x20b>
80106dc1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106dc7:	8b 40 24             	mov    0x24(%eax),%eax
80106dca:	85 c0                	test   %eax,%eax
80106dcc:	74 17                	je     80106de5 <trap+0x20b>
80106dce:	8b 45 08             	mov    0x8(%ebp),%eax
80106dd1:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106dd5:	0f b7 c0             	movzwl %ax,%eax
80106dd8:	83 e0 03             	and    $0x3,%eax
80106ddb:	83 f8 03             	cmp    $0x3,%eax
80106dde:	75 05                	jne    80106de5 <trap+0x20b>
    exit();
80106de0:	e8 9f de ff ff       	call   80104c84 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(proc && proc->state == RUNNING && tf->trapno == T_IRQ0+IRQ_TIMER)
80106de5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106deb:	85 c0                	test   %eax,%eax
80106ded:	74 1e                	je     80106e0d <trap+0x233>
80106def:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106df5:	8b 40 0c             	mov    0xc(%eax),%eax
80106df8:	83 f8 04             	cmp    $0x4,%eax
80106dfb:	75 10                	jne    80106e0d <trap+0x233>
80106dfd:	8b 45 08             	mov    0x8(%ebp),%eax
80106e00:	8b 40 30             	mov    0x30(%eax),%eax
80106e03:	83 f8 20             	cmp    $0x20,%eax
80106e06:	75 05                	jne    80106e0d <trap+0x233>
    yield();
80106e08:	e8 34 e2 ff ff       	call   80105041 <yield>

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80106e0d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106e13:	85 c0                	test   %eax,%eax
80106e15:	74 27                	je     80106e3e <trap+0x264>
80106e17:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106e1d:	8b 40 24             	mov    0x24(%eax),%eax
80106e20:	85 c0                	test   %eax,%eax
80106e22:	74 1a                	je     80106e3e <trap+0x264>
80106e24:	8b 45 08             	mov    0x8(%ebp),%eax
80106e27:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106e2b:	0f b7 c0             	movzwl %ax,%eax
80106e2e:	83 e0 03             	and    $0x3,%eax
80106e31:	83 f8 03             	cmp    $0x3,%eax
80106e34:	75 08                	jne    80106e3e <trap+0x264>
    exit();
80106e36:	e8 49 de ff ff       	call   80104c84 <exit>
80106e3b:	eb 01                	jmp    80106e3e <trap+0x264>
      exit();
    proc->tf = tf;
    syscall();
    if(proc->killed)
      exit();
    return;
80106e3d:	90                   	nop
    yield();

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
    exit();
}
80106e3e:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106e41:	5b                   	pop    %ebx
80106e42:	5e                   	pop    %esi
80106e43:	5f                   	pop    %edi
80106e44:	5d                   	pop    %ebp
80106e45:	c3                   	ret    

80106e46 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80106e46:	55                   	push   %ebp
80106e47:	89 e5                	mov    %esp,%ebp
80106e49:	83 ec 14             	sub    $0x14,%esp
80106e4c:	8b 45 08             	mov    0x8(%ebp),%eax
80106e4f:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80106e53:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80106e57:	89 c2                	mov    %eax,%edx
80106e59:	ec                   	in     (%dx),%al
80106e5a:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80106e5d:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80106e61:	c9                   	leave  
80106e62:	c3                   	ret    

80106e63 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80106e63:	55                   	push   %ebp
80106e64:	89 e5                	mov    %esp,%ebp
80106e66:	83 ec 08             	sub    $0x8,%esp
80106e69:	8b 55 08             	mov    0x8(%ebp),%edx
80106e6c:	8b 45 0c             	mov    0xc(%ebp),%eax
80106e6f:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80106e73:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106e76:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80106e7a:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80106e7e:	ee                   	out    %al,(%dx)
}
80106e7f:	90                   	nop
80106e80:	c9                   	leave  
80106e81:	c3                   	ret    

80106e82 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
80106e82:	55                   	push   %ebp
80106e83:	89 e5                	mov    %esp,%ebp
80106e85:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80106e88:	6a 00                	push   $0x0
80106e8a:	68 fa 03 00 00       	push   $0x3fa
80106e8f:	e8 cf ff ff ff       	call   80106e63 <outb>
80106e94:	83 c4 08             	add    $0x8,%esp
  
  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80106e97:	68 80 00 00 00       	push   $0x80
80106e9c:	68 fb 03 00 00       	push   $0x3fb
80106ea1:	e8 bd ff ff ff       	call   80106e63 <outb>
80106ea6:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80106ea9:	6a 0c                	push   $0xc
80106eab:	68 f8 03 00 00       	push   $0x3f8
80106eb0:	e8 ae ff ff ff       	call   80106e63 <outb>
80106eb5:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
80106eb8:	6a 00                	push   $0x0
80106eba:	68 f9 03 00 00       	push   $0x3f9
80106ebf:	e8 9f ff ff ff       	call   80106e63 <outb>
80106ec4:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80106ec7:	6a 03                	push   $0x3
80106ec9:	68 fb 03 00 00       	push   $0x3fb
80106ece:	e8 90 ff ff ff       	call   80106e63 <outb>
80106ed3:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
80106ed6:	6a 00                	push   $0x0
80106ed8:	68 fc 03 00 00       	push   $0x3fc
80106edd:	e8 81 ff ff ff       	call   80106e63 <outb>
80106ee2:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80106ee5:	6a 01                	push   $0x1
80106ee7:	68 f9 03 00 00       	push   $0x3f9
80106eec:	e8 72 ff ff ff       	call   80106e63 <outb>
80106ef1:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80106ef4:	68 fd 03 00 00       	push   $0x3fd
80106ef9:	e8 48 ff ff ff       	call   80106e46 <inb>
80106efe:	83 c4 04             	add    $0x4,%esp
80106f01:	3c ff                	cmp    $0xff,%al
80106f03:	74 6e                	je     80106f73 <uartinit+0xf1>
    return;
  uart = 1;
80106f05:	c7 05 4c b6 10 80 01 	movl   $0x1,0x8010b64c
80106f0c:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80106f0f:	68 fa 03 00 00       	push   $0x3fa
80106f14:	e8 2d ff ff ff       	call   80106e46 <inb>
80106f19:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
80106f1c:	68 f8 03 00 00       	push   $0x3f8
80106f21:	e8 20 ff ff ff       	call   80106e46 <inb>
80106f26:	83 c4 04             	add    $0x4,%esp
  picenable(IRQ_COM1);
80106f29:	83 ec 0c             	sub    $0xc,%esp
80106f2c:	6a 04                	push   $0x4
80106f2e:	e8 b4 d3 ff ff       	call   801042e7 <picenable>
80106f33:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_COM1, 0);
80106f36:	83 ec 08             	sub    $0x8,%esp
80106f39:	6a 00                	push   $0x0
80106f3b:	6a 04                	push   $0x4
80106f3d:	e8 30 bf ff ff       	call   80102e72 <ioapicenable>
80106f42:	83 c4 10             	add    $0x10,%esp
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106f45:	c7 45 f4 00 8f 10 80 	movl   $0x80108f00,-0xc(%ebp)
80106f4c:	eb 19                	jmp    80106f67 <uartinit+0xe5>
    uartputc(*p);
80106f4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f51:	0f b6 00             	movzbl (%eax),%eax
80106f54:	0f be c0             	movsbl %al,%eax
80106f57:	83 ec 0c             	sub    $0xc,%esp
80106f5a:	50                   	push   %eax
80106f5b:	e8 16 00 00 00       	call   80106f76 <uartputc>
80106f60:	83 c4 10             	add    $0x10,%esp
  inb(COM1+0);
  picenable(IRQ_COM1);
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106f63:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106f67:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f6a:	0f b6 00             	movzbl (%eax),%eax
80106f6d:	84 c0                	test   %al,%al
80106f6f:	75 dd                	jne    80106f4e <uartinit+0xcc>
80106f71:	eb 01                	jmp    80106f74 <uartinit+0xf2>
  outb(COM1+4, 0);
  outb(COM1+1, 0x01);    // Enable receive interrupts.

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
    return;
80106f73:	90                   	nop
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
    uartputc(*p);
}
80106f74:	c9                   	leave  
80106f75:	c3                   	ret    

80106f76 <uartputc>:

void
uartputc(int c)
{
80106f76:	55                   	push   %ebp
80106f77:	89 e5                	mov    %esp,%ebp
80106f79:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
80106f7c:	a1 4c b6 10 80       	mov    0x8010b64c,%eax
80106f81:	85 c0                	test   %eax,%eax
80106f83:	74 53                	je     80106fd8 <uartputc+0x62>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106f85:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106f8c:	eb 11                	jmp    80106f9f <uartputc+0x29>
    microdelay(10);
80106f8e:	83 ec 0c             	sub    $0xc,%esp
80106f91:	6a 0a                	push   $0xa
80106f93:	e8 40 c4 ff ff       	call   801033d8 <microdelay>
80106f98:	83 c4 10             	add    $0x10,%esp
{
  int i;

  if(!uart)
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106f9b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106f9f:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80106fa3:	7f 1a                	jg     80106fbf <uartputc+0x49>
80106fa5:	83 ec 0c             	sub    $0xc,%esp
80106fa8:	68 fd 03 00 00       	push   $0x3fd
80106fad:	e8 94 fe ff ff       	call   80106e46 <inb>
80106fb2:	83 c4 10             	add    $0x10,%esp
80106fb5:	0f b6 c0             	movzbl %al,%eax
80106fb8:	83 e0 20             	and    $0x20,%eax
80106fbb:	85 c0                	test   %eax,%eax
80106fbd:	74 cf                	je     80106f8e <uartputc+0x18>
    microdelay(10);
  outb(COM1+0, c);
80106fbf:	8b 45 08             	mov    0x8(%ebp),%eax
80106fc2:	0f b6 c0             	movzbl %al,%eax
80106fc5:	83 ec 08             	sub    $0x8,%esp
80106fc8:	50                   	push   %eax
80106fc9:	68 f8 03 00 00       	push   $0x3f8
80106fce:	e8 90 fe ff ff       	call   80106e63 <outb>
80106fd3:	83 c4 10             	add    $0x10,%esp
80106fd6:	eb 01                	jmp    80106fd9 <uartputc+0x63>
uartputc(int c)
{
  int i;

  if(!uart)
    return;
80106fd8:	90                   	nop
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
    microdelay(10);
  outb(COM1+0, c);
}
80106fd9:	c9                   	leave  
80106fda:	c3                   	ret    

80106fdb <uartgetc>:

static int
uartgetc(void)
{
80106fdb:	55                   	push   %ebp
80106fdc:	89 e5                	mov    %esp,%ebp
  if(!uart)
80106fde:	a1 4c b6 10 80       	mov    0x8010b64c,%eax
80106fe3:	85 c0                	test   %eax,%eax
80106fe5:	75 07                	jne    80106fee <uartgetc+0x13>
    return -1;
80106fe7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106fec:	eb 2e                	jmp    8010701c <uartgetc+0x41>
  if(!(inb(COM1+5) & 0x01))
80106fee:	68 fd 03 00 00       	push   $0x3fd
80106ff3:	e8 4e fe ff ff       	call   80106e46 <inb>
80106ff8:	83 c4 04             	add    $0x4,%esp
80106ffb:	0f b6 c0             	movzbl %al,%eax
80106ffe:	83 e0 01             	and    $0x1,%eax
80107001:	85 c0                	test   %eax,%eax
80107003:	75 07                	jne    8010700c <uartgetc+0x31>
    return -1;
80107005:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010700a:	eb 10                	jmp    8010701c <uartgetc+0x41>
  return inb(COM1+0);
8010700c:	68 f8 03 00 00       	push   $0x3f8
80107011:	e8 30 fe ff ff       	call   80106e46 <inb>
80107016:	83 c4 04             	add    $0x4,%esp
80107019:	0f b6 c0             	movzbl %al,%eax
}
8010701c:	c9                   	leave  
8010701d:	c3                   	ret    

8010701e <uartintr>:

void
uartintr(void)
{
8010701e:	55                   	push   %ebp
8010701f:	89 e5                	mov    %esp,%ebp
80107021:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
80107024:	83 ec 0c             	sub    $0xc,%esp
80107027:	68 db 6f 10 80       	push   $0x80106fdb
8010702c:	e8 c8 97 ff ff       	call   801007f9 <consoleintr>
80107031:	83 c4 10             	add    $0x10,%esp
}
80107034:	90                   	nop
80107035:	c9                   	leave  
80107036:	c3                   	ret    

80107037 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80107037:	6a 00                	push   $0x0
  pushl $0
80107039:	6a 00                	push   $0x0
  jmp alltraps
8010703b:	e9 a6 f9 ff ff       	jmp    801069e6 <alltraps>

80107040 <vector1>:
.globl vector1
vector1:
  pushl $0
80107040:	6a 00                	push   $0x0
  pushl $1
80107042:	6a 01                	push   $0x1
  jmp alltraps
80107044:	e9 9d f9 ff ff       	jmp    801069e6 <alltraps>

80107049 <vector2>:
.globl vector2
vector2:
  pushl $0
80107049:	6a 00                	push   $0x0
  pushl $2
8010704b:	6a 02                	push   $0x2
  jmp alltraps
8010704d:	e9 94 f9 ff ff       	jmp    801069e6 <alltraps>

80107052 <vector3>:
.globl vector3
vector3:
  pushl $0
80107052:	6a 00                	push   $0x0
  pushl $3
80107054:	6a 03                	push   $0x3
  jmp alltraps
80107056:	e9 8b f9 ff ff       	jmp    801069e6 <alltraps>

8010705b <vector4>:
.globl vector4
vector4:
  pushl $0
8010705b:	6a 00                	push   $0x0
  pushl $4
8010705d:	6a 04                	push   $0x4
  jmp alltraps
8010705f:	e9 82 f9 ff ff       	jmp    801069e6 <alltraps>

80107064 <vector5>:
.globl vector5
vector5:
  pushl $0
80107064:	6a 00                	push   $0x0
  pushl $5
80107066:	6a 05                	push   $0x5
  jmp alltraps
80107068:	e9 79 f9 ff ff       	jmp    801069e6 <alltraps>

8010706d <vector6>:
.globl vector6
vector6:
  pushl $0
8010706d:	6a 00                	push   $0x0
  pushl $6
8010706f:	6a 06                	push   $0x6
  jmp alltraps
80107071:	e9 70 f9 ff ff       	jmp    801069e6 <alltraps>

80107076 <vector7>:
.globl vector7
vector7:
  pushl $0
80107076:	6a 00                	push   $0x0
  pushl $7
80107078:	6a 07                	push   $0x7
  jmp alltraps
8010707a:	e9 67 f9 ff ff       	jmp    801069e6 <alltraps>

8010707f <vector8>:
.globl vector8
vector8:
  pushl $8
8010707f:	6a 08                	push   $0x8
  jmp alltraps
80107081:	e9 60 f9 ff ff       	jmp    801069e6 <alltraps>

80107086 <vector9>:
.globl vector9
vector9:
  pushl $0
80107086:	6a 00                	push   $0x0
  pushl $9
80107088:	6a 09                	push   $0x9
  jmp alltraps
8010708a:	e9 57 f9 ff ff       	jmp    801069e6 <alltraps>

8010708f <vector10>:
.globl vector10
vector10:
  pushl $10
8010708f:	6a 0a                	push   $0xa
  jmp alltraps
80107091:	e9 50 f9 ff ff       	jmp    801069e6 <alltraps>

80107096 <vector11>:
.globl vector11
vector11:
  pushl $11
80107096:	6a 0b                	push   $0xb
  jmp alltraps
80107098:	e9 49 f9 ff ff       	jmp    801069e6 <alltraps>

8010709d <vector12>:
.globl vector12
vector12:
  pushl $12
8010709d:	6a 0c                	push   $0xc
  jmp alltraps
8010709f:	e9 42 f9 ff ff       	jmp    801069e6 <alltraps>

801070a4 <vector13>:
.globl vector13
vector13:
  pushl $13
801070a4:	6a 0d                	push   $0xd
  jmp alltraps
801070a6:	e9 3b f9 ff ff       	jmp    801069e6 <alltraps>

801070ab <vector14>:
.globl vector14
vector14:
  pushl $14
801070ab:	6a 0e                	push   $0xe
  jmp alltraps
801070ad:	e9 34 f9 ff ff       	jmp    801069e6 <alltraps>

801070b2 <vector15>:
.globl vector15
vector15:
  pushl $0
801070b2:	6a 00                	push   $0x0
  pushl $15
801070b4:	6a 0f                	push   $0xf
  jmp alltraps
801070b6:	e9 2b f9 ff ff       	jmp    801069e6 <alltraps>

801070bb <vector16>:
.globl vector16
vector16:
  pushl $0
801070bb:	6a 00                	push   $0x0
  pushl $16
801070bd:	6a 10                	push   $0x10
  jmp alltraps
801070bf:	e9 22 f9 ff ff       	jmp    801069e6 <alltraps>

801070c4 <vector17>:
.globl vector17
vector17:
  pushl $17
801070c4:	6a 11                	push   $0x11
  jmp alltraps
801070c6:	e9 1b f9 ff ff       	jmp    801069e6 <alltraps>

801070cb <vector18>:
.globl vector18
vector18:
  pushl $0
801070cb:	6a 00                	push   $0x0
  pushl $18
801070cd:	6a 12                	push   $0x12
  jmp alltraps
801070cf:	e9 12 f9 ff ff       	jmp    801069e6 <alltraps>

801070d4 <vector19>:
.globl vector19
vector19:
  pushl $0
801070d4:	6a 00                	push   $0x0
  pushl $19
801070d6:	6a 13                	push   $0x13
  jmp alltraps
801070d8:	e9 09 f9 ff ff       	jmp    801069e6 <alltraps>

801070dd <vector20>:
.globl vector20
vector20:
  pushl $0
801070dd:	6a 00                	push   $0x0
  pushl $20
801070df:	6a 14                	push   $0x14
  jmp alltraps
801070e1:	e9 00 f9 ff ff       	jmp    801069e6 <alltraps>

801070e6 <vector21>:
.globl vector21
vector21:
  pushl $0
801070e6:	6a 00                	push   $0x0
  pushl $21
801070e8:	6a 15                	push   $0x15
  jmp alltraps
801070ea:	e9 f7 f8 ff ff       	jmp    801069e6 <alltraps>

801070ef <vector22>:
.globl vector22
vector22:
  pushl $0
801070ef:	6a 00                	push   $0x0
  pushl $22
801070f1:	6a 16                	push   $0x16
  jmp alltraps
801070f3:	e9 ee f8 ff ff       	jmp    801069e6 <alltraps>

801070f8 <vector23>:
.globl vector23
vector23:
  pushl $0
801070f8:	6a 00                	push   $0x0
  pushl $23
801070fa:	6a 17                	push   $0x17
  jmp alltraps
801070fc:	e9 e5 f8 ff ff       	jmp    801069e6 <alltraps>

80107101 <vector24>:
.globl vector24
vector24:
  pushl $0
80107101:	6a 00                	push   $0x0
  pushl $24
80107103:	6a 18                	push   $0x18
  jmp alltraps
80107105:	e9 dc f8 ff ff       	jmp    801069e6 <alltraps>

8010710a <vector25>:
.globl vector25
vector25:
  pushl $0
8010710a:	6a 00                	push   $0x0
  pushl $25
8010710c:	6a 19                	push   $0x19
  jmp alltraps
8010710e:	e9 d3 f8 ff ff       	jmp    801069e6 <alltraps>

80107113 <vector26>:
.globl vector26
vector26:
  pushl $0
80107113:	6a 00                	push   $0x0
  pushl $26
80107115:	6a 1a                	push   $0x1a
  jmp alltraps
80107117:	e9 ca f8 ff ff       	jmp    801069e6 <alltraps>

8010711c <vector27>:
.globl vector27
vector27:
  pushl $0
8010711c:	6a 00                	push   $0x0
  pushl $27
8010711e:	6a 1b                	push   $0x1b
  jmp alltraps
80107120:	e9 c1 f8 ff ff       	jmp    801069e6 <alltraps>

80107125 <vector28>:
.globl vector28
vector28:
  pushl $0
80107125:	6a 00                	push   $0x0
  pushl $28
80107127:	6a 1c                	push   $0x1c
  jmp alltraps
80107129:	e9 b8 f8 ff ff       	jmp    801069e6 <alltraps>

8010712e <vector29>:
.globl vector29
vector29:
  pushl $0
8010712e:	6a 00                	push   $0x0
  pushl $29
80107130:	6a 1d                	push   $0x1d
  jmp alltraps
80107132:	e9 af f8 ff ff       	jmp    801069e6 <alltraps>

80107137 <vector30>:
.globl vector30
vector30:
  pushl $0
80107137:	6a 00                	push   $0x0
  pushl $30
80107139:	6a 1e                	push   $0x1e
  jmp alltraps
8010713b:	e9 a6 f8 ff ff       	jmp    801069e6 <alltraps>

80107140 <vector31>:
.globl vector31
vector31:
  pushl $0
80107140:	6a 00                	push   $0x0
  pushl $31
80107142:	6a 1f                	push   $0x1f
  jmp alltraps
80107144:	e9 9d f8 ff ff       	jmp    801069e6 <alltraps>

80107149 <vector32>:
.globl vector32
vector32:
  pushl $0
80107149:	6a 00                	push   $0x0
  pushl $32
8010714b:	6a 20                	push   $0x20
  jmp alltraps
8010714d:	e9 94 f8 ff ff       	jmp    801069e6 <alltraps>

80107152 <vector33>:
.globl vector33
vector33:
  pushl $0
80107152:	6a 00                	push   $0x0
  pushl $33
80107154:	6a 21                	push   $0x21
  jmp alltraps
80107156:	e9 8b f8 ff ff       	jmp    801069e6 <alltraps>

8010715b <vector34>:
.globl vector34
vector34:
  pushl $0
8010715b:	6a 00                	push   $0x0
  pushl $34
8010715d:	6a 22                	push   $0x22
  jmp alltraps
8010715f:	e9 82 f8 ff ff       	jmp    801069e6 <alltraps>

80107164 <vector35>:
.globl vector35
vector35:
  pushl $0
80107164:	6a 00                	push   $0x0
  pushl $35
80107166:	6a 23                	push   $0x23
  jmp alltraps
80107168:	e9 79 f8 ff ff       	jmp    801069e6 <alltraps>

8010716d <vector36>:
.globl vector36
vector36:
  pushl $0
8010716d:	6a 00                	push   $0x0
  pushl $36
8010716f:	6a 24                	push   $0x24
  jmp alltraps
80107171:	e9 70 f8 ff ff       	jmp    801069e6 <alltraps>

80107176 <vector37>:
.globl vector37
vector37:
  pushl $0
80107176:	6a 00                	push   $0x0
  pushl $37
80107178:	6a 25                	push   $0x25
  jmp alltraps
8010717a:	e9 67 f8 ff ff       	jmp    801069e6 <alltraps>

8010717f <vector38>:
.globl vector38
vector38:
  pushl $0
8010717f:	6a 00                	push   $0x0
  pushl $38
80107181:	6a 26                	push   $0x26
  jmp alltraps
80107183:	e9 5e f8 ff ff       	jmp    801069e6 <alltraps>

80107188 <vector39>:
.globl vector39
vector39:
  pushl $0
80107188:	6a 00                	push   $0x0
  pushl $39
8010718a:	6a 27                	push   $0x27
  jmp alltraps
8010718c:	e9 55 f8 ff ff       	jmp    801069e6 <alltraps>

80107191 <vector40>:
.globl vector40
vector40:
  pushl $0
80107191:	6a 00                	push   $0x0
  pushl $40
80107193:	6a 28                	push   $0x28
  jmp alltraps
80107195:	e9 4c f8 ff ff       	jmp    801069e6 <alltraps>

8010719a <vector41>:
.globl vector41
vector41:
  pushl $0
8010719a:	6a 00                	push   $0x0
  pushl $41
8010719c:	6a 29                	push   $0x29
  jmp alltraps
8010719e:	e9 43 f8 ff ff       	jmp    801069e6 <alltraps>

801071a3 <vector42>:
.globl vector42
vector42:
  pushl $0
801071a3:	6a 00                	push   $0x0
  pushl $42
801071a5:	6a 2a                	push   $0x2a
  jmp alltraps
801071a7:	e9 3a f8 ff ff       	jmp    801069e6 <alltraps>

801071ac <vector43>:
.globl vector43
vector43:
  pushl $0
801071ac:	6a 00                	push   $0x0
  pushl $43
801071ae:	6a 2b                	push   $0x2b
  jmp alltraps
801071b0:	e9 31 f8 ff ff       	jmp    801069e6 <alltraps>

801071b5 <vector44>:
.globl vector44
vector44:
  pushl $0
801071b5:	6a 00                	push   $0x0
  pushl $44
801071b7:	6a 2c                	push   $0x2c
  jmp alltraps
801071b9:	e9 28 f8 ff ff       	jmp    801069e6 <alltraps>

801071be <vector45>:
.globl vector45
vector45:
  pushl $0
801071be:	6a 00                	push   $0x0
  pushl $45
801071c0:	6a 2d                	push   $0x2d
  jmp alltraps
801071c2:	e9 1f f8 ff ff       	jmp    801069e6 <alltraps>

801071c7 <vector46>:
.globl vector46
vector46:
  pushl $0
801071c7:	6a 00                	push   $0x0
  pushl $46
801071c9:	6a 2e                	push   $0x2e
  jmp alltraps
801071cb:	e9 16 f8 ff ff       	jmp    801069e6 <alltraps>

801071d0 <vector47>:
.globl vector47
vector47:
  pushl $0
801071d0:	6a 00                	push   $0x0
  pushl $47
801071d2:	6a 2f                	push   $0x2f
  jmp alltraps
801071d4:	e9 0d f8 ff ff       	jmp    801069e6 <alltraps>

801071d9 <vector48>:
.globl vector48
vector48:
  pushl $0
801071d9:	6a 00                	push   $0x0
  pushl $48
801071db:	6a 30                	push   $0x30
  jmp alltraps
801071dd:	e9 04 f8 ff ff       	jmp    801069e6 <alltraps>

801071e2 <vector49>:
.globl vector49
vector49:
  pushl $0
801071e2:	6a 00                	push   $0x0
  pushl $49
801071e4:	6a 31                	push   $0x31
  jmp alltraps
801071e6:	e9 fb f7 ff ff       	jmp    801069e6 <alltraps>

801071eb <vector50>:
.globl vector50
vector50:
  pushl $0
801071eb:	6a 00                	push   $0x0
  pushl $50
801071ed:	6a 32                	push   $0x32
  jmp alltraps
801071ef:	e9 f2 f7 ff ff       	jmp    801069e6 <alltraps>

801071f4 <vector51>:
.globl vector51
vector51:
  pushl $0
801071f4:	6a 00                	push   $0x0
  pushl $51
801071f6:	6a 33                	push   $0x33
  jmp alltraps
801071f8:	e9 e9 f7 ff ff       	jmp    801069e6 <alltraps>

801071fd <vector52>:
.globl vector52
vector52:
  pushl $0
801071fd:	6a 00                	push   $0x0
  pushl $52
801071ff:	6a 34                	push   $0x34
  jmp alltraps
80107201:	e9 e0 f7 ff ff       	jmp    801069e6 <alltraps>

80107206 <vector53>:
.globl vector53
vector53:
  pushl $0
80107206:	6a 00                	push   $0x0
  pushl $53
80107208:	6a 35                	push   $0x35
  jmp alltraps
8010720a:	e9 d7 f7 ff ff       	jmp    801069e6 <alltraps>

8010720f <vector54>:
.globl vector54
vector54:
  pushl $0
8010720f:	6a 00                	push   $0x0
  pushl $54
80107211:	6a 36                	push   $0x36
  jmp alltraps
80107213:	e9 ce f7 ff ff       	jmp    801069e6 <alltraps>

80107218 <vector55>:
.globl vector55
vector55:
  pushl $0
80107218:	6a 00                	push   $0x0
  pushl $55
8010721a:	6a 37                	push   $0x37
  jmp alltraps
8010721c:	e9 c5 f7 ff ff       	jmp    801069e6 <alltraps>

80107221 <vector56>:
.globl vector56
vector56:
  pushl $0
80107221:	6a 00                	push   $0x0
  pushl $56
80107223:	6a 38                	push   $0x38
  jmp alltraps
80107225:	e9 bc f7 ff ff       	jmp    801069e6 <alltraps>

8010722a <vector57>:
.globl vector57
vector57:
  pushl $0
8010722a:	6a 00                	push   $0x0
  pushl $57
8010722c:	6a 39                	push   $0x39
  jmp alltraps
8010722e:	e9 b3 f7 ff ff       	jmp    801069e6 <alltraps>

80107233 <vector58>:
.globl vector58
vector58:
  pushl $0
80107233:	6a 00                	push   $0x0
  pushl $58
80107235:	6a 3a                	push   $0x3a
  jmp alltraps
80107237:	e9 aa f7 ff ff       	jmp    801069e6 <alltraps>

8010723c <vector59>:
.globl vector59
vector59:
  pushl $0
8010723c:	6a 00                	push   $0x0
  pushl $59
8010723e:	6a 3b                	push   $0x3b
  jmp alltraps
80107240:	e9 a1 f7 ff ff       	jmp    801069e6 <alltraps>

80107245 <vector60>:
.globl vector60
vector60:
  pushl $0
80107245:	6a 00                	push   $0x0
  pushl $60
80107247:	6a 3c                	push   $0x3c
  jmp alltraps
80107249:	e9 98 f7 ff ff       	jmp    801069e6 <alltraps>

8010724e <vector61>:
.globl vector61
vector61:
  pushl $0
8010724e:	6a 00                	push   $0x0
  pushl $61
80107250:	6a 3d                	push   $0x3d
  jmp alltraps
80107252:	e9 8f f7 ff ff       	jmp    801069e6 <alltraps>

80107257 <vector62>:
.globl vector62
vector62:
  pushl $0
80107257:	6a 00                	push   $0x0
  pushl $62
80107259:	6a 3e                	push   $0x3e
  jmp alltraps
8010725b:	e9 86 f7 ff ff       	jmp    801069e6 <alltraps>

80107260 <vector63>:
.globl vector63
vector63:
  pushl $0
80107260:	6a 00                	push   $0x0
  pushl $63
80107262:	6a 3f                	push   $0x3f
  jmp alltraps
80107264:	e9 7d f7 ff ff       	jmp    801069e6 <alltraps>

80107269 <vector64>:
.globl vector64
vector64:
  pushl $0
80107269:	6a 00                	push   $0x0
  pushl $64
8010726b:	6a 40                	push   $0x40
  jmp alltraps
8010726d:	e9 74 f7 ff ff       	jmp    801069e6 <alltraps>

80107272 <vector65>:
.globl vector65
vector65:
  pushl $0
80107272:	6a 00                	push   $0x0
  pushl $65
80107274:	6a 41                	push   $0x41
  jmp alltraps
80107276:	e9 6b f7 ff ff       	jmp    801069e6 <alltraps>

8010727b <vector66>:
.globl vector66
vector66:
  pushl $0
8010727b:	6a 00                	push   $0x0
  pushl $66
8010727d:	6a 42                	push   $0x42
  jmp alltraps
8010727f:	e9 62 f7 ff ff       	jmp    801069e6 <alltraps>

80107284 <vector67>:
.globl vector67
vector67:
  pushl $0
80107284:	6a 00                	push   $0x0
  pushl $67
80107286:	6a 43                	push   $0x43
  jmp alltraps
80107288:	e9 59 f7 ff ff       	jmp    801069e6 <alltraps>

8010728d <vector68>:
.globl vector68
vector68:
  pushl $0
8010728d:	6a 00                	push   $0x0
  pushl $68
8010728f:	6a 44                	push   $0x44
  jmp alltraps
80107291:	e9 50 f7 ff ff       	jmp    801069e6 <alltraps>

80107296 <vector69>:
.globl vector69
vector69:
  pushl $0
80107296:	6a 00                	push   $0x0
  pushl $69
80107298:	6a 45                	push   $0x45
  jmp alltraps
8010729a:	e9 47 f7 ff ff       	jmp    801069e6 <alltraps>

8010729f <vector70>:
.globl vector70
vector70:
  pushl $0
8010729f:	6a 00                	push   $0x0
  pushl $70
801072a1:	6a 46                	push   $0x46
  jmp alltraps
801072a3:	e9 3e f7 ff ff       	jmp    801069e6 <alltraps>

801072a8 <vector71>:
.globl vector71
vector71:
  pushl $0
801072a8:	6a 00                	push   $0x0
  pushl $71
801072aa:	6a 47                	push   $0x47
  jmp alltraps
801072ac:	e9 35 f7 ff ff       	jmp    801069e6 <alltraps>

801072b1 <vector72>:
.globl vector72
vector72:
  pushl $0
801072b1:	6a 00                	push   $0x0
  pushl $72
801072b3:	6a 48                	push   $0x48
  jmp alltraps
801072b5:	e9 2c f7 ff ff       	jmp    801069e6 <alltraps>

801072ba <vector73>:
.globl vector73
vector73:
  pushl $0
801072ba:	6a 00                	push   $0x0
  pushl $73
801072bc:	6a 49                	push   $0x49
  jmp alltraps
801072be:	e9 23 f7 ff ff       	jmp    801069e6 <alltraps>

801072c3 <vector74>:
.globl vector74
vector74:
  pushl $0
801072c3:	6a 00                	push   $0x0
  pushl $74
801072c5:	6a 4a                	push   $0x4a
  jmp alltraps
801072c7:	e9 1a f7 ff ff       	jmp    801069e6 <alltraps>

801072cc <vector75>:
.globl vector75
vector75:
  pushl $0
801072cc:	6a 00                	push   $0x0
  pushl $75
801072ce:	6a 4b                	push   $0x4b
  jmp alltraps
801072d0:	e9 11 f7 ff ff       	jmp    801069e6 <alltraps>

801072d5 <vector76>:
.globl vector76
vector76:
  pushl $0
801072d5:	6a 00                	push   $0x0
  pushl $76
801072d7:	6a 4c                	push   $0x4c
  jmp alltraps
801072d9:	e9 08 f7 ff ff       	jmp    801069e6 <alltraps>

801072de <vector77>:
.globl vector77
vector77:
  pushl $0
801072de:	6a 00                	push   $0x0
  pushl $77
801072e0:	6a 4d                	push   $0x4d
  jmp alltraps
801072e2:	e9 ff f6 ff ff       	jmp    801069e6 <alltraps>

801072e7 <vector78>:
.globl vector78
vector78:
  pushl $0
801072e7:	6a 00                	push   $0x0
  pushl $78
801072e9:	6a 4e                	push   $0x4e
  jmp alltraps
801072eb:	e9 f6 f6 ff ff       	jmp    801069e6 <alltraps>

801072f0 <vector79>:
.globl vector79
vector79:
  pushl $0
801072f0:	6a 00                	push   $0x0
  pushl $79
801072f2:	6a 4f                	push   $0x4f
  jmp alltraps
801072f4:	e9 ed f6 ff ff       	jmp    801069e6 <alltraps>

801072f9 <vector80>:
.globl vector80
vector80:
  pushl $0
801072f9:	6a 00                	push   $0x0
  pushl $80
801072fb:	6a 50                	push   $0x50
  jmp alltraps
801072fd:	e9 e4 f6 ff ff       	jmp    801069e6 <alltraps>

80107302 <vector81>:
.globl vector81
vector81:
  pushl $0
80107302:	6a 00                	push   $0x0
  pushl $81
80107304:	6a 51                	push   $0x51
  jmp alltraps
80107306:	e9 db f6 ff ff       	jmp    801069e6 <alltraps>

8010730b <vector82>:
.globl vector82
vector82:
  pushl $0
8010730b:	6a 00                	push   $0x0
  pushl $82
8010730d:	6a 52                	push   $0x52
  jmp alltraps
8010730f:	e9 d2 f6 ff ff       	jmp    801069e6 <alltraps>

80107314 <vector83>:
.globl vector83
vector83:
  pushl $0
80107314:	6a 00                	push   $0x0
  pushl $83
80107316:	6a 53                	push   $0x53
  jmp alltraps
80107318:	e9 c9 f6 ff ff       	jmp    801069e6 <alltraps>

8010731d <vector84>:
.globl vector84
vector84:
  pushl $0
8010731d:	6a 00                	push   $0x0
  pushl $84
8010731f:	6a 54                	push   $0x54
  jmp alltraps
80107321:	e9 c0 f6 ff ff       	jmp    801069e6 <alltraps>

80107326 <vector85>:
.globl vector85
vector85:
  pushl $0
80107326:	6a 00                	push   $0x0
  pushl $85
80107328:	6a 55                	push   $0x55
  jmp alltraps
8010732a:	e9 b7 f6 ff ff       	jmp    801069e6 <alltraps>

8010732f <vector86>:
.globl vector86
vector86:
  pushl $0
8010732f:	6a 00                	push   $0x0
  pushl $86
80107331:	6a 56                	push   $0x56
  jmp alltraps
80107333:	e9 ae f6 ff ff       	jmp    801069e6 <alltraps>

80107338 <vector87>:
.globl vector87
vector87:
  pushl $0
80107338:	6a 00                	push   $0x0
  pushl $87
8010733a:	6a 57                	push   $0x57
  jmp alltraps
8010733c:	e9 a5 f6 ff ff       	jmp    801069e6 <alltraps>

80107341 <vector88>:
.globl vector88
vector88:
  pushl $0
80107341:	6a 00                	push   $0x0
  pushl $88
80107343:	6a 58                	push   $0x58
  jmp alltraps
80107345:	e9 9c f6 ff ff       	jmp    801069e6 <alltraps>

8010734a <vector89>:
.globl vector89
vector89:
  pushl $0
8010734a:	6a 00                	push   $0x0
  pushl $89
8010734c:	6a 59                	push   $0x59
  jmp alltraps
8010734e:	e9 93 f6 ff ff       	jmp    801069e6 <alltraps>

80107353 <vector90>:
.globl vector90
vector90:
  pushl $0
80107353:	6a 00                	push   $0x0
  pushl $90
80107355:	6a 5a                	push   $0x5a
  jmp alltraps
80107357:	e9 8a f6 ff ff       	jmp    801069e6 <alltraps>

8010735c <vector91>:
.globl vector91
vector91:
  pushl $0
8010735c:	6a 00                	push   $0x0
  pushl $91
8010735e:	6a 5b                	push   $0x5b
  jmp alltraps
80107360:	e9 81 f6 ff ff       	jmp    801069e6 <alltraps>

80107365 <vector92>:
.globl vector92
vector92:
  pushl $0
80107365:	6a 00                	push   $0x0
  pushl $92
80107367:	6a 5c                	push   $0x5c
  jmp alltraps
80107369:	e9 78 f6 ff ff       	jmp    801069e6 <alltraps>

8010736e <vector93>:
.globl vector93
vector93:
  pushl $0
8010736e:	6a 00                	push   $0x0
  pushl $93
80107370:	6a 5d                	push   $0x5d
  jmp alltraps
80107372:	e9 6f f6 ff ff       	jmp    801069e6 <alltraps>

80107377 <vector94>:
.globl vector94
vector94:
  pushl $0
80107377:	6a 00                	push   $0x0
  pushl $94
80107379:	6a 5e                	push   $0x5e
  jmp alltraps
8010737b:	e9 66 f6 ff ff       	jmp    801069e6 <alltraps>

80107380 <vector95>:
.globl vector95
vector95:
  pushl $0
80107380:	6a 00                	push   $0x0
  pushl $95
80107382:	6a 5f                	push   $0x5f
  jmp alltraps
80107384:	e9 5d f6 ff ff       	jmp    801069e6 <alltraps>

80107389 <vector96>:
.globl vector96
vector96:
  pushl $0
80107389:	6a 00                	push   $0x0
  pushl $96
8010738b:	6a 60                	push   $0x60
  jmp alltraps
8010738d:	e9 54 f6 ff ff       	jmp    801069e6 <alltraps>

80107392 <vector97>:
.globl vector97
vector97:
  pushl $0
80107392:	6a 00                	push   $0x0
  pushl $97
80107394:	6a 61                	push   $0x61
  jmp alltraps
80107396:	e9 4b f6 ff ff       	jmp    801069e6 <alltraps>

8010739b <vector98>:
.globl vector98
vector98:
  pushl $0
8010739b:	6a 00                	push   $0x0
  pushl $98
8010739d:	6a 62                	push   $0x62
  jmp alltraps
8010739f:	e9 42 f6 ff ff       	jmp    801069e6 <alltraps>

801073a4 <vector99>:
.globl vector99
vector99:
  pushl $0
801073a4:	6a 00                	push   $0x0
  pushl $99
801073a6:	6a 63                	push   $0x63
  jmp alltraps
801073a8:	e9 39 f6 ff ff       	jmp    801069e6 <alltraps>

801073ad <vector100>:
.globl vector100
vector100:
  pushl $0
801073ad:	6a 00                	push   $0x0
  pushl $100
801073af:	6a 64                	push   $0x64
  jmp alltraps
801073b1:	e9 30 f6 ff ff       	jmp    801069e6 <alltraps>

801073b6 <vector101>:
.globl vector101
vector101:
  pushl $0
801073b6:	6a 00                	push   $0x0
  pushl $101
801073b8:	6a 65                	push   $0x65
  jmp alltraps
801073ba:	e9 27 f6 ff ff       	jmp    801069e6 <alltraps>

801073bf <vector102>:
.globl vector102
vector102:
  pushl $0
801073bf:	6a 00                	push   $0x0
  pushl $102
801073c1:	6a 66                	push   $0x66
  jmp alltraps
801073c3:	e9 1e f6 ff ff       	jmp    801069e6 <alltraps>

801073c8 <vector103>:
.globl vector103
vector103:
  pushl $0
801073c8:	6a 00                	push   $0x0
  pushl $103
801073ca:	6a 67                	push   $0x67
  jmp alltraps
801073cc:	e9 15 f6 ff ff       	jmp    801069e6 <alltraps>

801073d1 <vector104>:
.globl vector104
vector104:
  pushl $0
801073d1:	6a 00                	push   $0x0
  pushl $104
801073d3:	6a 68                	push   $0x68
  jmp alltraps
801073d5:	e9 0c f6 ff ff       	jmp    801069e6 <alltraps>

801073da <vector105>:
.globl vector105
vector105:
  pushl $0
801073da:	6a 00                	push   $0x0
  pushl $105
801073dc:	6a 69                	push   $0x69
  jmp alltraps
801073de:	e9 03 f6 ff ff       	jmp    801069e6 <alltraps>

801073e3 <vector106>:
.globl vector106
vector106:
  pushl $0
801073e3:	6a 00                	push   $0x0
  pushl $106
801073e5:	6a 6a                	push   $0x6a
  jmp alltraps
801073e7:	e9 fa f5 ff ff       	jmp    801069e6 <alltraps>

801073ec <vector107>:
.globl vector107
vector107:
  pushl $0
801073ec:	6a 00                	push   $0x0
  pushl $107
801073ee:	6a 6b                	push   $0x6b
  jmp alltraps
801073f0:	e9 f1 f5 ff ff       	jmp    801069e6 <alltraps>

801073f5 <vector108>:
.globl vector108
vector108:
  pushl $0
801073f5:	6a 00                	push   $0x0
  pushl $108
801073f7:	6a 6c                	push   $0x6c
  jmp alltraps
801073f9:	e9 e8 f5 ff ff       	jmp    801069e6 <alltraps>

801073fe <vector109>:
.globl vector109
vector109:
  pushl $0
801073fe:	6a 00                	push   $0x0
  pushl $109
80107400:	6a 6d                	push   $0x6d
  jmp alltraps
80107402:	e9 df f5 ff ff       	jmp    801069e6 <alltraps>

80107407 <vector110>:
.globl vector110
vector110:
  pushl $0
80107407:	6a 00                	push   $0x0
  pushl $110
80107409:	6a 6e                	push   $0x6e
  jmp alltraps
8010740b:	e9 d6 f5 ff ff       	jmp    801069e6 <alltraps>

80107410 <vector111>:
.globl vector111
vector111:
  pushl $0
80107410:	6a 00                	push   $0x0
  pushl $111
80107412:	6a 6f                	push   $0x6f
  jmp alltraps
80107414:	e9 cd f5 ff ff       	jmp    801069e6 <alltraps>

80107419 <vector112>:
.globl vector112
vector112:
  pushl $0
80107419:	6a 00                	push   $0x0
  pushl $112
8010741b:	6a 70                	push   $0x70
  jmp alltraps
8010741d:	e9 c4 f5 ff ff       	jmp    801069e6 <alltraps>

80107422 <vector113>:
.globl vector113
vector113:
  pushl $0
80107422:	6a 00                	push   $0x0
  pushl $113
80107424:	6a 71                	push   $0x71
  jmp alltraps
80107426:	e9 bb f5 ff ff       	jmp    801069e6 <alltraps>

8010742b <vector114>:
.globl vector114
vector114:
  pushl $0
8010742b:	6a 00                	push   $0x0
  pushl $114
8010742d:	6a 72                	push   $0x72
  jmp alltraps
8010742f:	e9 b2 f5 ff ff       	jmp    801069e6 <alltraps>

80107434 <vector115>:
.globl vector115
vector115:
  pushl $0
80107434:	6a 00                	push   $0x0
  pushl $115
80107436:	6a 73                	push   $0x73
  jmp alltraps
80107438:	e9 a9 f5 ff ff       	jmp    801069e6 <alltraps>

8010743d <vector116>:
.globl vector116
vector116:
  pushl $0
8010743d:	6a 00                	push   $0x0
  pushl $116
8010743f:	6a 74                	push   $0x74
  jmp alltraps
80107441:	e9 a0 f5 ff ff       	jmp    801069e6 <alltraps>

80107446 <vector117>:
.globl vector117
vector117:
  pushl $0
80107446:	6a 00                	push   $0x0
  pushl $117
80107448:	6a 75                	push   $0x75
  jmp alltraps
8010744a:	e9 97 f5 ff ff       	jmp    801069e6 <alltraps>

8010744f <vector118>:
.globl vector118
vector118:
  pushl $0
8010744f:	6a 00                	push   $0x0
  pushl $118
80107451:	6a 76                	push   $0x76
  jmp alltraps
80107453:	e9 8e f5 ff ff       	jmp    801069e6 <alltraps>

80107458 <vector119>:
.globl vector119
vector119:
  pushl $0
80107458:	6a 00                	push   $0x0
  pushl $119
8010745a:	6a 77                	push   $0x77
  jmp alltraps
8010745c:	e9 85 f5 ff ff       	jmp    801069e6 <alltraps>

80107461 <vector120>:
.globl vector120
vector120:
  pushl $0
80107461:	6a 00                	push   $0x0
  pushl $120
80107463:	6a 78                	push   $0x78
  jmp alltraps
80107465:	e9 7c f5 ff ff       	jmp    801069e6 <alltraps>

8010746a <vector121>:
.globl vector121
vector121:
  pushl $0
8010746a:	6a 00                	push   $0x0
  pushl $121
8010746c:	6a 79                	push   $0x79
  jmp alltraps
8010746e:	e9 73 f5 ff ff       	jmp    801069e6 <alltraps>

80107473 <vector122>:
.globl vector122
vector122:
  pushl $0
80107473:	6a 00                	push   $0x0
  pushl $122
80107475:	6a 7a                	push   $0x7a
  jmp alltraps
80107477:	e9 6a f5 ff ff       	jmp    801069e6 <alltraps>

8010747c <vector123>:
.globl vector123
vector123:
  pushl $0
8010747c:	6a 00                	push   $0x0
  pushl $123
8010747e:	6a 7b                	push   $0x7b
  jmp alltraps
80107480:	e9 61 f5 ff ff       	jmp    801069e6 <alltraps>

80107485 <vector124>:
.globl vector124
vector124:
  pushl $0
80107485:	6a 00                	push   $0x0
  pushl $124
80107487:	6a 7c                	push   $0x7c
  jmp alltraps
80107489:	e9 58 f5 ff ff       	jmp    801069e6 <alltraps>

8010748e <vector125>:
.globl vector125
vector125:
  pushl $0
8010748e:	6a 00                	push   $0x0
  pushl $125
80107490:	6a 7d                	push   $0x7d
  jmp alltraps
80107492:	e9 4f f5 ff ff       	jmp    801069e6 <alltraps>

80107497 <vector126>:
.globl vector126
vector126:
  pushl $0
80107497:	6a 00                	push   $0x0
  pushl $126
80107499:	6a 7e                	push   $0x7e
  jmp alltraps
8010749b:	e9 46 f5 ff ff       	jmp    801069e6 <alltraps>

801074a0 <vector127>:
.globl vector127
vector127:
  pushl $0
801074a0:	6a 00                	push   $0x0
  pushl $127
801074a2:	6a 7f                	push   $0x7f
  jmp alltraps
801074a4:	e9 3d f5 ff ff       	jmp    801069e6 <alltraps>

801074a9 <vector128>:
.globl vector128
vector128:
  pushl $0
801074a9:	6a 00                	push   $0x0
  pushl $128
801074ab:	68 80 00 00 00       	push   $0x80
  jmp alltraps
801074b0:	e9 31 f5 ff ff       	jmp    801069e6 <alltraps>

801074b5 <vector129>:
.globl vector129
vector129:
  pushl $0
801074b5:	6a 00                	push   $0x0
  pushl $129
801074b7:	68 81 00 00 00       	push   $0x81
  jmp alltraps
801074bc:	e9 25 f5 ff ff       	jmp    801069e6 <alltraps>

801074c1 <vector130>:
.globl vector130
vector130:
  pushl $0
801074c1:	6a 00                	push   $0x0
  pushl $130
801074c3:	68 82 00 00 00       	push   $0x82
  jmp alltraps
801074c8:	e9 19 f5 ff ff       	jmp    801069e6 <alltraps>

801074cd <vector131>:
.globl vector131
vector131:
  pushl $0
801074cd:	6a 00                	push   $0x0
  pushl $131
801074cf:	68 83 00 00 00       	push   $0x83
  jmp alltraps
801074d4:	e9 0d f5 ff ff       	jmp    801069e6 <alltraps>

801074d9 <vector132>:
.globl vector132
vector132:
  pushl $0
801074d9:	6a 00                	push   $0x0
  pushl $132
801074db:	68 84 00 00 00       	push   $0x84
  jmp alltraps
801074e0:	e9 01 f5 ff ff       	jmp    801069e6 <alltraps>

801074e5 <vector133>:
.globl vector133
vector133:
  pushl $0
801074e5:	6a 00                	push   $0x0
  pushl $133
801074e7:	68 85 00 00 00       	push   $0x85
  jmp alltraps
801074ec:	e9 f5 f4 ff ff       	jmp    801069e6 <alltraps>

801074f1 <vector134>:
.globl vector134
vector134:
  pushl $0
801074f1:	6a 00                	push   $0x0
  pushl $134
801074f3:	68 86 00 00 00       	push   $0x86
  jmp alltraps
801074f8:	e9 e9 f4 ff ff       	jmp    801069e6 <alltraps>

801074fd <vector135>:
.globl vector135
vector135:
  pushl $0
801074fd:	6a 00                	push   $0x0
  pushl $135
801074ff:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80107504:	e9 dd f4 ff ff       	jmp    801069e6 <alltraps>

80107509 <vector136>:
.globl vector136
vector136:
  pushl $0
80107509:	6a 00                	push   $0x0
  pushl $136
8010750b:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80107510:	e9 d1 f4 ff ff       	jmp    801069e6 <alltraps>

80107515 <vector137>:
.globl vector137
vector137:
  pushl $0
80107515:	6a 00                	push   $0x0
  pushl $137
80107517:	68 89 00 00 00       	push   $0x89
  jmp alltraps
8010751c:	e9 c5 f4 ff ff       	jmp    801069e6 <alltraps>

80107521 <vector138>:
.globl vector138
vector138:
  pushl $0
80107521:	6a 00                	push   $0x0
  pushl $138
80107523:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80107528:	e9 b9 f4 ff ff       	jmp    801069e6 <alltraps>

8010752d <vector139>:
.globl vector139
vector139:
  pushl $0
8010752d:	6a 00                	push   $0x0
  pushl $139
8010752f:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80107534:	e9 ad f4 ff ff       	jmp    801069e6 <alltraps>

80107539 <vector140>:
.globl vector140
vector140:
  pushl $0
80107539:	6a 00                	push   $0x0
  pushl $140
8010753b:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80107540:	e9 a1 f4 ff ff       	jmp    801069e6 <alltraps>

80107545 <vector141>:
.globl vector141
vector141:
  pushl $0
80107545:	6a 00                	push   $0x0
  pushl $141
80107547:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
8010754c:	e9 95 f4 ff ff       	jmp    801069e6 <alltraps>

80107551 <vector142>:
.globl vector142
vector142:
  pushl $0
80107551:	6a 00                	push   $0x0
  pushl $142
80107553:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80107558:	e9 89 f4 ff ff       	jmp    801069e6 <alltraps>

8010755d <vector143>:
.globl vector143
vector143:
  pushl $0
8010755d:	6a 00                	push   $0x0
  pushl $143
8010755f:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80107564:	e9 7d f4 ff ff       	jmp    801069e6 <alltraps>

80107569 <vector144>:
.globl vector144
vector144:
  pushl $0
80107569:	6a 00                	push   $0x0
  pushl $144
8010756b:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80107570:	e9 71 f4 ff ff       	jmp    801069e6 <alltraps>

80107575 <vector145>:
.globl vector145
vector145:
  pushl $0
80107575:	6a 00                	push   $0x0
  pushl $145
80107577:	68 91 00 00 00       	push   $0x91
  jmp alltraps
8010757c:	e9 65 f4 ff ff       	jmp    801069e6 <alltraps>

80107581 <vector146>:
.globl vector146
vector146:
  pushl $0
80107581:	6a 00                	push   $0x0
  pushl $146
80107583:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80107588:	e9 59 f4 ff ff       	jmp    801069e6 <alltraps>

8010758d <vector147>:
.globl vector147
vector147:
  pushl $0
8010758d:	6a 00                	push   $0x0
  pushl $147
8010758f:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80107594:	e9 4d f4 ff ff       	jmp    801069e6 <alltraps>

80107599 <vector148>:
.globl vector148
vector148:
  pushl $0
80107599:	6a 00                	push   $0x0
  pushl $148
8010759b:	68 94 00 00 00       	push   $0x94
  jmp alltraps
801075a0:	e9 41 f4 ff ff       	jmp    801069e6 <alltraps>

801075a5 <vector149>:
.globl vector149
vector149:
  pushl $0
801075a5:	6a 00                	push   $0x0
  pushl $149
801075a7:	68 95 00 00 00       	push   $0x95
  jmp alltraps
801075ac:	e9 35 f4 ff ff       	jmp    801069e6 <alltraps>

801075b1 <vector150>:
.globl vector150
vector150:
  pushl $0
801075b1:	6a 00                	push   $0x0
  pushl $150
801075b3:	68 96 00 00 00       	push   $0x96
  jmp alltraps
801075b8:	e9 29 f4 ff ff       	jmp    801069e6 <alltraps>

801075bd <vector151>:
.globl vector151
vector151:
  pushl $0
801075bd:	6a 00                	push   $0x0
  pushl $151
801075bf:	68 97 00 00 00       	push   $0x97
  jmp alltraps
801075c4:	e9 1d f4 ff ff       	jmp    801069e6 <alltraps>

801075c9 <vector152>:
.globl vector152
vector152:
  pushl $0
801075c9:	6a 00                	push   $0x0
  pushl $152
801075cb:	68 98 00 00 00       	push   $0x98
  jmp alltraps
801075d0:	e9 11 f4 ff ff       	jmp    801069e6 <alltraps>

801075d5 <vector153>:
.globl vector153
vector153:
  pushl $0
801075d5:	6a 00                	push   $0x0
  pushl $153
801075d7:	68 99 00 00 00       	push   $0x99
  jmp alltraps
801075dc:	e9 05 f4 ff ff       	jmp    801069e6 <alltraps>

801075e1 <vector154>:
.globl vector154
vector154:
  pushl $0
801075e1:	6a 00                	push   $0x0
  pushl $154
801075e3:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
801075e8:	e9 f9 f3 ff ff       	jmp    801069e6 <alltraps>

801075ed <vector155>:
.globl vector155
vector155:
  pushl $0
801075ed:	6a 00                	push   $0x0
  pushl $155
801075ef:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
801075f4:	e9 ed f3 ff ff       	jmp    801069e6 <alltraps>

801075f9 <vector156>:
.globl vector156
vector156:
  pushl $0
801075f9:	6a 00                	push   $0x0
  pushl $156
801075fb:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80107600:	e9 e1 f3 ff ff       	jmp    801069e6 <alltraps>

80107605 <vector157>:
.globl vector157
vector157:
  pushl $0
80107605:	6a 00                	push   $0x0
  pushl $157
80107607:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
8010760c:	e9 d5 f3 ff ff       	jmp    801069e6 <alltraps>

80107611 <vector158>:
.globl vector158
vector158:
  pushl $0
80107611:	6a 00                	push   $0x0
  pushl $158
80107613:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80107618:	e9 c9 f3 ff ff       	jmp    801069e6 <alltraps>

8010761d <vector159>:
.globl vector159
vector159:
  pushl $0
8010761d:	6a 00                	push   $0x0
  pushl $159
8010761f:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80107624:	e9 bd f3 ff ff       	jmp    801069e6 <alltraps>

80107629 <vector160>:
.globl vector160
vector160:
  pushl $0
80107629:	6a 00                	push   $0x0
  pushl $160
8010762b:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80107630:	e9 b1 f3 ff ff       	jmp    801069e6 <alltraps>

80107635 <vector161>:
.globl vector161
vector161:
  pushl $0
80107635:	6a 00                	push   $0x0
  pushl $161
80107637:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
8010763c:	e9 a5 f3 ff ff       	jmp    801069e6 <alltraps>

80107641 <vector162>:
.globl vector162
vector162:
  pushl $0
80107641:	6a 00                	push   $0x0
  pushl $162
80107643:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80107648:	e9 99 f3 ff ff       	jmp    801069e6 <alltraps>

8010764d <vector163>:
.globl vector163
vector163:
  pushl $0
8010764d:	6a 00                	push   $0x0
  pushl $163
8010764f:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80107654:	e9 8d f3 ff ff       	jmp    801069e6 <alltraps>

80107659 <vector164>:
.globl vector164
vector164:
  pushl $0
80107659:	6a 00                	push   $0x0
  pushl $164
8010765b:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80107660:	e9 81 f3 ff ff       	jmp    801069e6 <alltraps>

80107665 <vector165>:
.globl vector165
vector165:
  pushl $0
80107665:	6a 00                	push   $0x0
  pushl $165
80107667:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
8010766c:	e9 75 f3 ff ff       	jmp    801069e6 <alltraps>

80107671 <vector166>:
.globl vector166
vector166:
  pushl $0
80107671:	6a 00                	push   $0x0
  pushl $166
80107673:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80107678:	e9 69 f3 ff ff       	jmp    801069e6 <alltraps>

8010767d <vector167>:
.globl vector167
vector167:
  pushl $0
8010767d:	6a 00                	push   $0x0
  pushl $167
8010767f:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80107684:	e9 5d f3 ff ff       	jmp    801069e6 <alltraps>

80107689 <vector168>:
.globl vector168
vector168:
  pushl $0
80107689:	6a 00                	push   $0x0
  pushl $168
8010768b:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80107690:	e9 51 f3 ff ff       	jmp    801069e6 <alltraps>

80107695 <vector169>:
.globl vector169
vector169:
  pushl $0
80107695:	6a 00                	push   $0x0
  pushl $169
80107697:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
8010769c:	e9 45 f3 ff ff       	jmp    801069e6 <alltraps>

801076a1 <vector170>:
.globl vector170
vector170:
  pushl $0
801076a1:	6a 00                	push   $0x0
  pushl $170
801076a3:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
801076a8:	e9 39 f3 ff ff       	jmp    801069e6 <alltraps>

801076ad <vector171>:
.globl vector171
vector171:
  pushl $0
801076ad:	6a 00                	push   $0x0
  pushl $171
801076af:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
801076b4:	e9 2d f3 ff ff       	jmp    801069e6 <alltraps>

801076b9 <vector172>:
.globl vector172
vector172:
  pushl $0
801076b9:	6a 00                	push   $0x0
  pushl $172
801076bb:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
801076c0:	e9 21 f3 ff ff       	jmp    801069e6 <alltraps>

801076c5 <vector173>:
.globl vector173
vector173:
  pushl $0
801076c5:	6a 00                	push   $0x0
  pushl $173
801076c7:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
801076cc:	e9 15 f3 ff ff       	jmp    801069e6 <alltraps>

801076d1 <vector174>:
.globl vector174
vector174:
  pushl $0
801076d1:	6a 00                	push   $0x0
  pushl $174
801076d3:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
801076d8:	e9 09 f3 ff ff       	jmp    801069e6 <alltraps>

801076dd <vector175>:
.globl vector175
vector175:
  pushl $0
801076dd:	6a 00                	push   $0x0
  pushl $175
801076df:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
801076e4:	e9 fd f2 ff ff       	jmp    801069e6 <alltraps>

801076e9 <vector176>:
.globl vector176
vector176:
  pushl $0
801076e9:	6a 00                	push   $0x0
  pushl $176
801076eb:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
801076f0:	e9 f1 f2 ff ff       	jmp    801069e6 <alltraps>

801076f5 <vector177>:
.globl vector177
vector177:
  pushl $0
801076f5:	6a 00                	push   $0x0
  pushl $177
801076f7:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
801076fc:	e9 e5 f2 ff ff       	jmp    801069e6 <alltraps>

80107701 <vector178>:
.globl vector178
vector178:
  pushl $0
80107701:	6a 00                	push   $0x0
  pushl $178
80107703:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80107708:	e9 d9 f2 ff ff       	jmp    801069e6 <alltraps>

8010770d <vector179>:
.globl vector179
vector179:
  pushl $0
8010770d:	6a 00                	push   $0x0
  pushl $179
8010770f:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80107714:	e9 cd f2 ff ff       	jmp    801069e6 <alltraps>

80107719 <vector180>:
.globl vector180
vector180:
  pushl $0
80107719:	6a 00                	push   $0x0
  pushl $180
8010771b:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80107720:	e9 c1 f2 ff ff       	jmp    801069e6 <alltraps>

80107725 <vector181>:
.globl vector181
vector181:
  pushl $0
80107725:	6a 00                	push   $0x0
  pushl $181
80107727:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
8010772c:	e9 b5 f2 ff ff       	jmp    801069e6 <alltraps>

80107731 <vector182>:
.globl vector182
vector182:
  pushl $0
80107731:	6a 00                	push   $0x0
  pushl $182
80107733:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80107738:	e9 a9 f2 ff ff       	jmp    801069e6 <alltraps>

8010773d <vector183>:
.globl vector183
vector183:
  pushl $0
8010773d:	6a 00                	push   $0x0
  pushl $183
8010773f:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80107744:	e9 9d f2 ff ff       	jmp    801069e6 <alltraps>

80107749 <vector184>:
.globl vector184
vector184:
  pushl $0
80107749:	6a 00                	push   $0x0
  pushl $184
8010774b:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80107750:	e9 91 f2 ff ff       	jmp    801069e6 <alltraps>

80107755 <vector185>:
.globl vector185
vector185:
  pushl $0
80107755:	6a 00                	push   $0x0
  pushl $185
80107757:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
8010775c:	e9 85 f2 ff ff       	jmp    801069e6 <alltraps>

80107761 <vector186>:
.globl vector186
vector186:
  pushl $0
80107761:	6a 00                	push   $0x0
  pushl $186
80107763:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80107768:	e9 79 f2 ff ff       	jmp    801069e6 <alltraps>

8010776d <vector187>:
.globl vector187
vector187:
  pushl $0
8010776d:	6a 00                	push   $0x0
  pushl $187
8010776f:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80107774:	e9 6d f2 ff ff       	jmp    801069e6 <alltraps>

80107779 <vector188>:
.globl vector188
vector188:
  pushl $0
80107779:	6a 00                	push   $0x0
  pushl $188
8010777b:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80107780:	e9 61 f2 ff ff       	jmp    801069e6 <alltraps>

80107785 <vector189>:
.globl vector189
vector189:
  pushl $0
80107785:	6a 00                	push   $0x0
  pushl $189
80107787:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
8010778c:	e9 55 f2 ff ff       	jmp    801069e6 <alltraps>

80107791 <vector190>:
.globl vector190
vector190:
  pushl $0
80107791:	6a 00                	push   $0x0
  pushl $190
80107793:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80107798:	e9 49 f2 ff ff       	jmp    801069e6 <alltraps>

8010779d <vector191>:
.globl vector191
vector191:
  pushl $0
8010779d:	6a 00                	push   $0x0
  pushl $191
8010779f:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
801077a4:	e9 3d f2 ff ff       	jmp    801069e6 <alltraps>

801077a9 <vector192>:
.globl vector192
vector192:
  pushl $0
801077a9:	6a 00                	push   $0x0
  pushl $192
801077ab:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
801077b0:	e9 31 f2 ff ff       	jmp    801069e6 <alltraps>

801077b5 <vector193>:
.globl vector193
vector193:
  pushl $0
801077b5:	6a 00                	push   $0x0
  pushl $193
801077b7:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
801077bc:	e9 25 f2 ff ff       	jmp    801069e6 <alltraps>

801077c1 <vector194>:
.globl vector194
vector194:
  pushl $0
801077c1:	6a 00                	push   $0x0
  pushl $194
801077c3:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
801077c8:	e9 19 f2 ff ff       	jmp    801069e6 <alltraps>

801077cd <vector195>:
.globl vector195
vector195:
  pushl $0
801077cd:	6a 00                	push   $0x0
  pushl $195
801077cf:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
801077d4:	e9 0d f2 ff ff       	jmp    801069e6 <alltraps>

801077d9 <vector196>:
.globl vector196
vector196:
  pushl $0
801077d9:	6a 00                	push   $0x0
  pushl $196
801077db:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
801077e0:	e9 01 f2 ff ff       	jmp    801069e6 <alltraps>

801077e5 <vector197>:
.globl vector197
vector197:
  pushl $0
801077e5:	6a 00                	push   $0x0
  pushl $197
801077e7:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
801077ec:	e9 f5 f1 ff ff       	jmp    801069e6 <alltraps>

801077f1 <vector198>:
.globl vector198
vector198:
  pushl $0
801077f1:	6a 00                	push   $0x0
  pushl $198
801077f3:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
801077f8:	e9 e9 f1 ff ff       	jmp    801069e6 <alltraps>

801077fd <vector199>:
.globl vector199
vector199:
  pushl $0
801077fd:	6a 00                	push   $0x0
  pushl $199
801077ff:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80107804:	e9 dd f1 ff ff       	jmp    801069e6 <alltraps>

80107809 <vector200>:
.globl vector200
vector200:
  pushl $0
80107809:	6a 00                	push   $0x0
  pushl $200
8010780b:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80107810:	e9 d1 f1 ff ff       	jmp    801069e6 <alltraps>

80107815 <vector201>:
.globl vector201
vector201:
  pushl $0
80107815:	6a 00                	push   $0x0
  pushl $201
80107817:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
8010781c:	e9 c5 f1 ff ff       	jmp    801069e6 <alltraps>

80107821 <vector202>:
.globl vector202
vector202:
  pushl $0
80107821:	6a 00                	push   $0x0
  pushl $202
80107823:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80107828:	e9 b9 f1 ff ff       	jmp    801069e6 <alltraps>

8010782d <vector203>:
.globl vector203
vector203:
  pushl $0
8010782d:	6a 00                	push   $0x0
  pushl $203
8010782f:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80107834:	e9 ad f1 ff ff       	jmp    801069e6 <alltraps>

80107839 <vector204>:
.globl vector204
vector204:
  pushl $0
80107839:	6a 00                	push   $0x0
  pushl $204
8010783b:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80107840:	e9 a1 f1 ff ff       	jmp    801069e6 <alltraps>

80107845 <vector205>:
.globl vector205
vector205:
  pushl $0
80107845:	6a 00                	push   $0x0
  pushl $205
80107847:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
8010784c:	e9 95 f1 ff ff       	jmp    801069e6 <alltraps>

80107851 <vector206>:
.globl vector206
vector206:
  pushl $0
80107851:	6a 00                	push   $0x0
  pushl $206
80107853:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80107858:	e9 89 f1 ff ff       	jmp    801069e6 <alltraps>

8010785d <vector207>:
.globl vector207
vector207:
  pushl $0
8010785d:	6a 00                	push   $0x0
  pushl $207
8010785f:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80107864:	e9 7d f1 ff ff       	jmp    801069e6 <alltraps>

80107869 <vector208>:
.globl vector208
vector208:
  pushl $0
80107869:	6a 00                	push   $0x0
  pushl $208
8010786b:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80107870:	e9 71 f1 ff ff       	jmp    801069e6 <alltraps>

80107875 <vector209>:
.globl vector209
vector209:
  pushl $0
80107875:	6a 00                	push   $0x0
  pushl $209
80107877:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
8010787c:	e9 65 f1 ff ff       	jmp    801069e6 <alltraps>

80107881 <vector210>:
.globl vector210
vector210:
  pushl $0
80107881:	6a 00                	push   $0x0
  pushl $210
80107883:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80107888:	e9 59 f1 ff ff       	jmp    801069e6 <alltraps>

8010788d <vector211>:
.globl vector211
vector211:
  pushl $0
8010788d:	6a 00                	push   $0x0
  pushl $211
8010788f:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80107894:	e9 4d f1 ff ff       	jmp    801069e6 <alltraps>

80107899 <vector212>:
.globl vector212
vector212:
  pushl $0
80107899:	6a 00                	push   $0x0
  pushl $212
8010789b:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
801078a0:	e9 41 f1 ff ff       	jmp    801069e6 <alltraps>

801078a5 <vector213>:
.globl vector213
vector213:
  pushl $0
801078a5:	6a 00                	push   $0x0
  pushl $213
801078a7:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
801078ac:	e9 35 f1 ff ff       	jmp    801069e6 <alltraps>

801078b1 <vector214>:
.globl vector214
vector214:
  pushl $0
801078b1:	6a 00                	push   $0x0
  pushl $214
801078b3:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
801078b8:	e9 29 f1 ff ff       	jmp    801069e6 <alltraps>

801078bd <vector215>:
.globl vector215
vector215:
  pushl $0
801078bd:	6a 00                	push   $0x0
  pushl $215
801078bf:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
801078c4:	e9 1d f1 ff ff       	jmp    801069e6 <alltraps>

801078c9 <vector216>:
.globl vector216
vector216:
  pushl $0
801078c9:	6a 00                	push   $0x0
  pushl $216
801078cb:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
801078d0:	e9 11 f1 ff ff       	jmp    801069e6 <alltraps>

801078d5 <vector217>:
.globl vector217
vector217:
  pushl $0
801078d5:	6a 00                	push   $0x0
  pushl $217
801078d7:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
801078dc:	e9 05 f1 ff ff       	jmp    801069e6 <alltraps>

801078e1 <vector218>:
.globl vector218
vector218:
  pushl $0
801078e1:	6a 00                	push   $0x0
  pushl $218
801078e3:	68 da 00 00 00       	push   $0xda
  jmp alltraps
801078e8:	e9 f9 f0 ff ff       	jmp    801069e6 <alltraps>

801078ed <vector219>:
.globl vector219
vector219:
  pushl $0
801078ed:	6a 00                	push   $0x0
  pushl $219
801078ef:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
801078f4:	e9 ed f0 ff ff       	jmp    801069e6 <alltraps>

801078f9 <vector220>:
.globl vector220
vector220:
  pushl $0
801078f9:	6a 00                	push   $0x0
  pushl $220
801078fb:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80107900:	e9 e1 f0 ff ff       	jmp    801069e6 <alltraps>

80107905 <vector221>:
.globl vector221
vector221:
  pushl $0
80107905:	6a 00                	push   $0x0
  pushl $221
80107907:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
8010790c:	e9 d5 f0 ff ff       	jmp    801069e6 <alltraps>

80107911 <vector222>:
.globl vector222
vector222:
  pushl $0
80107911:	6a 00                	push   $0x0
  pushl $222
80107913:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80107918:	e9 c9 f0 ff ff       	jmp    801069e6 <alltraps>

8010791d <vector223>:
.globl vector223
vector223:
  pushl $0
8010791d:	6a 00                	push   $0x0
  pushl $223
8010791f:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80107924:	e9 bd f0 ff ff       	jmp    801069e6 <alltraps>

80107929 <vector224>:
.globl vector224
vector224:
  pushl $0
80107929:	6a 00                	push   $0x0
  pushl $224
8010792b:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80107930:	e9 b1 f0 ff ff       	jmp    801069e6 <alltraps>

80107935 <vector225>:
.globl vector225
vector225:
  pushl $0
80107935:	6a 00                	push   $0x0
  pushl $225
80107937:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
8010793c:	e9 a5 f0 ff ff       	jmp    801069e6 <alltraps>

80107941 <vector226>:
.globl vector226
vector226:
  pushl $0
80107941:	6a 00                	push   $0x0
  pushl $226
80107943:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80107948:	e9 99 f0 ff ff       	jmp    801069e6 <alltraps>

8010794d <vector227>:
.globl vector227
vector227:
  pushl $0
8010794d:	6a 00                	push   $0x0
  pushl $227
8010794f:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80107954:	e9 8d f0 ff ff       	jmp    801069e6 <alltraps>

80107959 <vector228>:
.globl vector228
vector228:
  pushl $0
80107959:	6a 00                	push   $0x0
  pushl $228
8010795b:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80107960:	e9 81 f0 ff ff       	jmp    801069e6 <alltraps>

80107965 <vector229>:
.globl vector229
vector229:
  pushl $0
80107965:	6a 00                	push   $0x0
  pushl $229
80107967:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
8010796c:	e9 75 f0 ff ff       	jmp    801069e6 <alltraps>

80107971 <vector230>:
.globl vector230
vector230:
  pushl $0
80107971:	6a 00                	push   $0x0
  pushl $230
80107973:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80107978:	e9 69 f0 ff ff       	jmp    801069e6 <alltraps>

8010797d <vector231>:
.globl vector231
vector231:
  pushl $0
8010797d:	6a 00                	push   $0x0
  pushl $231
8010797f:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80107984:	e9 5d f0 ff ff       	jmp    801069e6 <alltraps>

80107989 <vector232>:
.globl vector232
vector232:
  pushl $0
80107989:	6a 00                	push   $0x0
  pushl $232
8010798b:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80107990:	e9 51 f0 ff ff       	jmp    801069e6 <alltraps>

80107995 <vector233>:
.globl vector233
vector233:
  pushl $0
80107995:	6a 00                	push   $0x0
  pushl $233
80107997:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
8010799c:	e9 45 f0 ff ff       	jmp    801069e6 <alltraps>

801079a1 <vector234>:
.globl vector234
vector234:
  pushl $0
801079a1:	6a 00                	push   $0x0
  pushl $234
801079a3:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
801079a8:	e9 39 f0 ff ff       	jmp    801069e6 <alltraps>

801079ad <vector235>:
.globl vector235
vector235:
  pushl $0
801079ad:	6a 00                	push   $0x0
  pushl $235
801079af:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
801079b4:	e9 2d f0 ff ff       	jmp    801069e6 <alltraps>

801079b9 <vector236>:
.globl vector236
vector236:
  pushl $0
801079b9:	6a 00                	push   $0x0
  pushl $236
801079bb:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
801079c0:	e9 21 f0 ff ff       	jmp    801069e6 <alltraps>

801079c5 <vector237>:
.globl vector237
vector237:
  pushl $0
801079c5:	6a 00                	push   $0x0
  pushl $237
801079c7:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
801079cc:	e9 15 f0 ff ff       	jmp    801069e6 <alltraps>

801079d1 <vector238>:
.globl vector238
vector238:
  pushl $0
801079d1:	6a 00                	push   $0x0
  pushl $238
801079d3:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
801079d8:	e9 09 f0 ff ff       	jmp    801069e6 <alltraps>

801079dd <vector239>:
.globl vector239
vector239:
  pushl $0
801079dd:	6a 00                	push   $0x0
  pushl $239
801079df:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
801079e4:	e9 fd ef ff ff       	jmp    801069e6 <alltraps>

801079e9 <vector240>:
.globl vector240
vector240:
  pushl $0
801079e9:	6a 00                	push   $0x0
  pushl $240
801079eb:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
801079f0:	e9 f1 ef ff ff       	jmp    801069e6 <alltraps>

801079f5 <vector241>:
.globl vector241
vector241:
  pushl $0
801079f5:	6a 00                	push   $0x0
  pushl $241
801079f7:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
801079fc:	e9 e5 ef ff ff       	jmp    801069e6 <alltraps>

80107a01 <vector242>:
.globl vector242
vector242:
  pushl $0
80107a01:	6a 00                	push   $0x0
  pushl $242
80107a03:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80107a08:	e9 d9 ef ff ff       	jmp    801069e6 <alltraps>

80107a0d <vector243>:
.globl vector243
vector243:
  pushl $0
80107a0d:	6a 00                	push   $0x0
  pushl $243
80107a0f:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80107a14:	e9 cd ef ff ff       	jmp    801069e6 <alltraps>

80107a19 <vector244>:
.globl vector244
vector244:
  pushl $0
80107a19:	6a 00                	push   $0x0
  pushl $244
80107a1b:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80107a20:	e9 c1 ef ff ff       	jmp    801069e6 <alltraps>

80107a25 <vector245>:
.globl vector245
vector245:
  pushl $0
80107a25:	6a 00                	push   $0x0
  pushl $245
80107a27:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80107a2c:	e9 b5 ef ff ff       	jmp    801069e6 <alltraps>

80107a31 <vector246>:
.globl vector246
vector246:
  pushl $0
80107a31:	6a 00                	push   $0x0
  pushl $246
80107a33:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80107a38:	e9 a9 ef ff ff       	jmp    801069e6 <alltraps>

80107a3d <vector247>:
.globl vector247
vector247:
  pushl $0
80107a3d:	6a 00                	push   $0x0
  pushl $247
80107a3f:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80107a44:	e9 9d ef ff ff       	jmp    801069e6 <alltraps>

80107a49 <vector248>:
.globl vector248
vector248:
  pushl $0
80107a49:	6a 00                	push   $0x0
  pushl $248
80107a4b:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80107a50:	e9 91 ef ff ff       	jmp    801069e6 <alltraps>

80107a55 <vector249>:
.globl vector249
vector249:
  pushl $0
80107a55:	6a 00                	push   $0x0
  pushl $249
80107a57:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80107a5c:	e9 85 ef ff ff       	jmp    801069e6 <alltraps>

80107a61 <vector250>:
.globl vector250
vector250:
  pushl $0
80107a61:	6a 00                	push   $0x0
  pushl $250
80107a63:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80107a68:	e9 79 ef ff ff       	jmp    801069e6 <alltraps>

80107a6d <vector251>:
.globl vector251
vector251:
  pushl $0
80107a6d:	6a 00                	push   $0x0
  pushl $251
80107a6f:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80107a74:	e9 6d ef ff ff       	jmp    801069e6 <alltraps>

80107a79 <vector252>:
.globl vector252
vector252:
  pushl $0
80107a79:	6a 00                	push   $0x0
  pushl $252
80107a7b:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80107a80:	e9 61 ef ff ff       	jmp    801069e6 <alltraps>

80107a85 <vector253>:
.globl vector253
vector253:
  pushl $0
80107a85:	6a 00                	push   $0x0
  pushl $253
80107a87:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80107a8c:	e9 55 ef ff ff       	jmp    801069e6 <alltraps>

80107a91 <vector254>:
.globl vector254
vector254:
  pushl $0
80107a91:	6a 00                	push   $0x0
  pushl $254
80107a93:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80107a98:	e9 49 ef ff ff       	jmp    801069e6 <alltraps>

80107a9d <vector255>:
.globl vector255
vector255:
  pushl $0
80107a9d:	6a 00                	push   $0x0
  pushl $255
80107a9f:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80107aa4:	e9 3d ef ff ff       	jmp    801069e6 <alltraps>

80107aa9 <lgdt>:

struct segdesc;

static inline void
lgdt(struct segdesc *p, int size)
{
80107aa9:	55                   	push   %ebp
80107aaa:	89 e5                	mov    %esp,%ebp
80107aac:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
80107aaf:	8b 45 0c             	mov    0xc(%ebp),%eax
80107ab2:	83 e8 01             	sub    $0x1,%eax
80107ab5:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80107ab9:	8b 45 08             	mov    0x8(%ebp),%eax
80107abc:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80107ac0:	8b 45 08             	mov    0x8(%ebp),%eax
80107ac3:	c1 e8 10             	shr    $0x10,%eax
80107ac6:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lgdt (%0)" : : "r" (pd));
80107aca:	8d 45 fa             	lea    -0x6(%ebp),%eax
80107acd:	0f 01 10             	lgdtl  (%eax)
}
80107ad0:	90                   	nop
80107ad1:	c9                   	leave  
80107ad2:	c3                   	ret    

80107ad3 <ltr>:
  asm volatile("lidt (%0)" : : "r" (pd));
}

static inline void
ltr(ushort sel)
{
80107ad3:	55                   	push   %ebp
80107ad4:	89 e5                	mov    %esp,%ebp
80107ad6:	83 ec 04             	sub    $0x4,%esp
80107ad9:	8b 45 08             	mov    0x8(%ebp),%eax
80107adc:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
80107ae0:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80107ae4:	0f 00 d8             	ltr    %ax
}
80107ae7:	90                   	nop
80107ae8:	c9                   	leave  
80107ae9:	c3                   	ret    

80107aea <loadgs>:
  return eflags;
}

static inline void
loadgs(ushort v)
{
80107aea:	55                   	push   %ebp
80107aeb:	89 e5                	mov    %esp,%ebp
80107aed:	83 ec 04             	sub    $0x4,%esp
80107af0:	8b 45 08             	mov    0x8(%ebp),%eax
80107af3:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("movw %0, %%gs" : : "r" (v));
80107af7:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80107afb:	8e e8                	mov    %eax,%gs
}
80107afd:	90                   	nop
80107afe:	c9                   	leave  
80107aff:	c3                   	ret    

80107b00 <lcr3>:
  return val;
}

static inline void
lcr3(uint val) 
{
80107b00:	55                   	push   %ebp
80107b01:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
80107b03:	8b 45 08             	mov    0x8(%ebp),%eax
80107b06:	0f 22 d8             	mov    %eax,%cr3
}
80107b09:	90                   	nop
80107b0a:	5d                   	pop    %ebp
80107b0b:	c3                   	ret    

80107b0c <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
80107b0c:	55                   	push   %ebp
80107b0d:	89 e5                	mov    %esp,%ebp
80107b0f:	8b 45 08             	mov    0x8(%ebp),%eax
80107b12:	05 00 00 00 80       	add    $0x80000000,%eax
80107b17:	5d                   	pop    %ebp
80107b18:	c3                   	ret    

80107b19 <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
80107b19:	55                   	push   %ebp
80107b1a:	89 e5                	mov    %esp,%ebp
80107b1c:	8b 45 08             	mov    0x8(%ebp),%eax
80107b1f:	05 00 00 00 80       	add    $0x80000000,%eax
80107b24:	5d                   	pop    %ebp
80107b25:	c3                   	ret    

80107b26 <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
80107b26:	55                   	push   %ebp
80107b27:	89 e5                	mov    %esp,%ebp
80107b29:	53                   	push   %ebx
80107b2a:	83 ec 14             	sub    $0x14,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpunum()];
80107b2d:	e8 32 b8 ff ff       	call   80103364 <cpunum>
80107b32:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80107b38:	05 40 26 11 80       	add    $0x80112640,%eax
80107b3d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80107b40:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b43:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
80107b49:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b4c:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
80107b52:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b55:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
80107b59:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b5c:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107b60:	83 e2 f0             	and    $0xfffffff0,%edx
80107b63:	83 ca 0a             	or     $0xa,%edx
80107b66:	88 50 7d             	mov    %dl,0x7d(%eax)
80107b69:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b6c:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107b70:	83 ca 10             	or     $0x10,%edx
80107b73:	88 50 7d             	mov    %dl,0x7d(%eax)
80107b76:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b79:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107b7d:	83 e2 9f             	and    $0xffffff9f,%edx
80107b80:	88 50 7d             	mov    %dl,0x7d(%eax)
80107b83:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b86:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107b8a:	83 ca 80             	or     $0xffffff80,%edx
80107b8d:	88 50 7d             	mov    %dl,0x7d(%eax)
80107b90:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b93:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107b97:	83 ca 0f             	or     $0xf,%edx
80107b9a:	88 50 7e             	mov    %dl,0x7e(%eax)
80107b9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ba0:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107ba4:	83 e2 ef             	and    $0xffffffef,%edx
80107ba7:	88 50 7e             	mov    %dl,0x7e(%eax)
80107baa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bad:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107bb1:	83 e2 df             	and    $0xffffffdf,%edx
80107bb4:	88 50 7e             	mov    %dl,0x7e(%eax)
80107bb7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bba:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107bbe:	83 ca 40             	or     $0x40,%edx
80107bc1:	88 50 7e             	mov    %dl,0x7e(%eax)
80107bc4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bc7:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107bcb:	83 ca 80             	or     $0xffffff80,%edx
80107bce:	88 50 7e             	mov    %dl,0x7e(%eax)
80107bd1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bd4:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80107bd8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bdb:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
80107be2:	ff ff 
80107be4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107be7:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
80107bee:	00 00 
80107bf0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bf3:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
80107bfa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bfd:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107c04:	83 e2 f0             	and    $0xfffffff0,%edx
80107c07:	83 ca 02             	or     $0x2,%edx
80107c0a:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107c10:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c13:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107c1a:	83 ca 10             	or     $0x10,%edx
80107c1d:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107c23:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c26:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107c2d:	83 e2 9f             	and    $0xffffff9f,%edx
80107c30:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107c36:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c39:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107c40:	83 ca 80             	or     $0xffffff80,%edx
80107c43:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107c49:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c4c:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107c53:	83 ca 0f             	or     $0xf,%edx
80107c56:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107c5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c5f:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107c66:	83 e2 ef             	and    $0xffffffef,%edx
80107c69:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107c6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c72:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107c79:	83 e2 df             	and    $0xffffffdf,%edx
80107c7c:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107c82:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c85:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107c8c:	83 ca 40             	or     $0x40,%edx
80107c8f:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107c95:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c98:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107c9f:	83 ca 80             	or     $0xffffff80,%edx
80107ca2:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107ca8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cab:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80107cb2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cb5:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
80107cbc:	ff ff 
80107cbe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cc1:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
80107cc8:	00 00 
80107cca:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ccd:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
80107cd4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cd7:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107cde:	83 e2 f0             	and    $0xfffffff0,%edx
80107ce1:	83 ca 0a             	or     $0xa,%edx
80107ce4:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107cea:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ced:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107cf4:	83 ca 10             	or     $0x10,%edx
80107cf7:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107cfd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d00:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107d07:	83 ca 60             	or     $0x60,%edx
80107d0a:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107d10:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d13:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107d1a:	83 ca 80             	or     $0xffffff80,%edx
80107d1d:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107d23:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d26:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107d2d:	83 ca 0f             	or     $0xf,%edx
80107d30:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107d36:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d39:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107d40:	83 e2 ef             	and    $0xffffffef,%edx
80107d43:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107d49:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d4c:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107d53:	83 e2 df             	and    $0xffffffdf,%edx
80107d56:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107d5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d5f:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107d66:	83 ca 40             	or     $0x40,%edx
80107d69:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107d6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d72:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107d79:	83 ca 80             	or     $0xffffff80,%edx
80107d7c:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107d82:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d85:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80107d8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d8f:	66 c7 80 98 00 00 00 	movw   $0xffff,0x98(%eax)
80107d96:	ff ff 
80107d98:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d9b:	66 c7 80 9a 00 00 00 	movw   $0x0,0x9a(%eax)
80107da2:	00 00 
80107da4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107da7:	c6 80 9c 00 00 00 00 	movb   $0x0,0x9c(%eax)
80107dae:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107db1:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107db8:	83 e2 f0             	and    $0xfffffff0,%edx
80107dbb:	83 ca 02             	or     $0x2,%edx
80107dbe:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107dc4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dc7:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107dce:	83 ca 10             	or     $0x10,%edx
80107dd1:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107dd7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dda:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107de1:	83 ca 60             	or     $0x60,%edx
80107de4:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107dea:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ded:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107df4:	83 ca 80             	or     $0xffffff80,%edx
80107df7:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107dfd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e00:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107e07:	83 ca 0f             	or     $0xf,%edx
80107e0a:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107e10:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e13:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107e1a:	83 e2 ef             	and    $0xffffffef,%edx
80107e1d:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107e23:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e26:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107e2d:	83 e2 df             	and    $0xffffffdf,%edx
80107e30:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107e36:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e39:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107e40:	83 ca 40             	or     $0x40,%edx
80107e43:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107e49:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e4c:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107e53:	83 ca 80             	or     $0xffffff80,%edx
80107e56:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107e5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e5f:	c6 80 9f 00 00 00 00 	movb   $0x0,0x9f(%eax)

  // Map cpu, and curproc
  c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);
80107e66:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e69:	05 b4 00 00 00       	add    $0xb4,%eax
80107e6e:	89 c3                	mov    %eax,%ebx
80107e70:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e73:	05 b4 00 00 00       	add    $0xb4,%eax
80107e78:	c1 e8 10             	shr    $0x10,%eax
80107e7b:	89 c2                	mov    %eax,%edx
80107e7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e80:	05 b4 00 00 00       	add    $0xb4,%eax
80107e85:	c1 e8 18             	shr    $0x18,%eax
80107e88:	89 c1                	mov    %eax,%ecx
80107e8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e8d:	66 c7 80 88 00 00 00 	movw   $0x0,0x88(%eax)
80107e94:	00 00 
80107e96:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e99:	66 89 98 8a 00 00 00 	mov    %bx,0x8a(%eax)
80107ea0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ea3:	88 90 8c 00 00 00    	mov    %dl,0x8c(%eax)
80107ea9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107eac:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107eb3:	83 e2 f0             	and    $0xfffffff0,%edx
80107eb6:	83 ca 02             	or     $0x2,%edx
80107eb9:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107ebf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ec2:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107ec9:	83 ca 10             	or     $0x10,%edx
80107ecc:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107ed2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ed5:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107edc:	83 e2 9f             	and    $0xffffff9f,%edx
80107edf:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107ee5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ee8:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107eef:	83 ca 80             	or     $0xffffff80,%edx
80107ef2:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107ef8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107efb:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107f02:	83 e2 f0             	and    $0xfffffff0,%edx
80107f05:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107f0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f0e:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107f15:	83 e2 ef             	and    $0xffffffef,%edx
80107f18:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107f1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f21:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107f28:	83 e2 df             	and    $0xffffffdf,%edx
80107f2b:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107f31:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f34:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107f3b:	83 ca 40             	or     $0x40,%edx
80107f3e:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107f44:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f47:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107f4e:	83 ca 80             	or     $0xffffff80,%edx
80107f51:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107f57:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f5a:	88 88 8f 00 00 00    	mov    %cl,0x8f(%eax)

  lgdt(c->gdt, sizeof(c->gdt));
80107f60:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f63:	83 c0 70             	add    $0x70,%eax
80107f66:	83 ec 08             	sub    $0x8,%esp
80107f69:	6a 38                	push   $0x38
80107f6b:	50                   	push   %eax
80107f6c:	e8 38 fb ff ff       	call   80107aa9 <lgdt>
80107f71:	83 c4 10             	add    $0x10,%esp
  loadgs(SEG_KCPU << 3);
80107f74:	83 ec 0c             	sub    $0xc,%esp
80107f77:	6a 18                	push   $0x18
80107f79:	e8 6c fb ff ff       	call   80107aea <loadgs>
80107f7e:	83 c4 10             	add    $0x10,%esp
  
  // Initialize cpu-local storage.
  cpu = c;
80107f81:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f84:	65 a3 00 00 00 00    	mov    %eax,%gs:0x0
  proc = 0;
80107f8a:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80107f91:	00 00 00 00 
}
80107f95:	90                   	nop
80107f96:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80107f99:	c9                   	leave  
80107f9a:	c3                   	ret    

80107f9b <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80107f9b:	55                   	push   %ebp
80107f9c:	89 e5                	mov    %esp,%ebp
80107f9e:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80107fa1:	8b 45 0c             	mov    0xc(%ebp),%eax
80107fa4:	c1 e8 16             	shr    $0x16,%eax
80107fa7:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107fae:	8b 45 08             	mov    0x8(%ebp),%eax
80107fb1:	01 d0                	add    %edx,%eax
80107fb3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
80107fb6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107fb9:	8b 00                	mov    (%eax),%eax
80107fbb:	83 e0 01             	and    $0x1,%eax
80107fbe:	85 c0                	test   %eax,%eax
80107fc0:	74 18                	je     80107fda <walkpgdir+0x3f>
    pgtab = (pte_t*)p2v(PTE_ADDR(*pde));
80107fc2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107fc5:	8b 00                	mov    (%eax),%eax
80107fc7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107fcc:	50                   	push   %eax
80107fcd:	e8 47 fb ff ff       	call   80107b19 <p2v>
80107fd2:	83 c4 04             	add    $0x4,%esp
80107fd5:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107fd8:	eb 48                	jmp    80108022 <walkpgdir+0x87>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80107fda:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80107fde:	74 0e                	je     80107fee <walkpgdir+0x53>
80107fe0:	e8 19 b0 ff ff       	call   80102ffe <kalloc>
80107fe5:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107fe8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107fec:	75 07                	jne    80107ff5 <walkpgdir+0x5a>
      return 0;
80107fee:	b8 00 00 00 00       	mov    $0x0,%eax
80107ff3:	eb 44                	jmp    80108039 <walkpgdir+0x9e>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80107ff5:	83 ec 04             	sub    $0x4,%esp
80107ff8:	68 00 10 00 00       	push   $0x1000
80107ffd:	6a 00                	push   $0x0
80107fff:	ff 75 f4             	pushl  -0xc(%ebp)
80108002:	e8 19 d6 ff ff       	call   80105620 <memset>
80108007:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table 
    // entries, if necessary.
    *pde = v2p(pgtab) | PTE_P | PTE_W | PTE_U;
8010800a:	83 ec 0c             	sub    $0xc,%esp
8010800d:	ff 75 f4             	pushl  -0xc(%ebp)
80108010:	e8 f7 fa ff ff       	call   80107b0c <v2p>
80108015:	83 c4 10             	add    $0x10,%esp
80108018:	83 c8 07             	or     $0x7,%eax
8010801b:	89 c2                	mov    %eax,%edx
8010801d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108020:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80108022:	8b 45 0c             	mov    0xc(%ebp),%eax
80108025:	c1 e8 0c             	shr    $0xc,%eax
80108028:	25 ff 03 00 00       	and    $0x3ff,%eax
8010802d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108034:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108037:	01 d0                	add    %edx,%eax
}
80108039:	c9                   	leave  
8010803a:	c3                   	ret    

8010803b <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
8010803b:	55                   	push   %ebp
8010803c:	89 e5                	mov    %esp,%ebp
8010803e:	83 ec 18             	sub    $0x18,%esp
  char *a, *last;
  pte_t *pte;
  
  a = (char*)PGROUNDDOWN((uint)va);
80108041:	8b 45 0c             	mov    0xc(%ebp),%eax
80108044:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108049:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
8010804c:	8b 55 0c             	mov    0xc(%ebp),%edx
8010804f:	8b 45 10             	mov    0x10(%ebp),%eax
80108052:	01 d0                	add    %edx,%eax
80108054:	83 e8 01             	sub    $0x1,%eax
80108057:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010805c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
8010805f:	83 ec 04             	sub    $0x4,%esp
80108062:	6a 01                	push   $0x1
80108064:	ff 75 f4             	pushl  -0xc(%ebp)
80108067:	ff 75 08             	pushl  0x8(%ebp)
8010806a:	e8 2c ff ff ff       	call   80107f9b <walkpgdir>
8010806f:	83 c4 10             	add    $0x10,%esp
80108072:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108075:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108079:	75 07                	jne    80108082 <mappages+0x47>
      return -1;
8010807b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108080:	eb 47                	jmp    801080c9 <mappages+0x8e>
    if(*pte & PTE_P)
80108082:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108085:	8b 00                	mov    (%eax),%eax
80108087:	83 e0 01             	and    $0x1,%eax
8010808a:	85 c0                	test   %eax,%eax
8010808c:	74 0d                	je     8010809b <mappages+0x60>
      panic("remap");
8010808e:	83 ec 0c             	sub    $0xc,%esp
80108091:	68 08 8f 10 80       	push   $0x80108f08
80108096:	e8 cb 84 ff ff       	call   80100566 <panic>
    *pte = pa | perm | PTE_P;
8010809b:	8b 45 18             	mov    0x18(%ebp),%eax
8010809e:	0b 45 14             	or     0x14(%ebp),%eax
801080a1:	83 c8 01             	or     $0x1,%eax
801080a4:	89 c2                	mov    %eax,%edx
801080a6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801080a9:	89 10                	mov    %edx,(%eax)
    if(a == last)
801080ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080ae:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801080b1:	74 10                	je     801080c3 <mappages+0x88>
      break;
    a += PGSIZE;
801080b3:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
801080ba:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  }
801080c1:	eb 9c                	jmp    8010805f <mappages+0x24>
      return -1;
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
    if(a == last)
      break;
801080c3:	90                   	nop
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
801080c4:	b8 00 00 00 00       	mov    $0x0,%eax
}
801080c9:	c9                   	leave  
801080ca:	c3                   	ret    

801080cb <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
801080cb:	55                   	push   %ebp
801080cc:	89 e5                	mov    %esp,%ebp
801080ce:	53                   	push   %ebx
801080cf:	83 ec 14             	sub    $0x14,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
801080d2:	e8 27 af ff ff       	call   80102ffe <kalloc>
801080d7:	89 45 f0             	mov    %eax,-0x10(%ebp)
801080da:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801080de:	75 0a                	jne    801080ea <setupkvm+0x1f>
    return 0;
801080e0:	b8 00 00 00 00       	mov    $0x0,%eax
801080e5:	e9 8e 00 00 00       	jmp    80108178 <setupkvm+0xad>
  memset(pgdir, 0, PGSIZE);
801080ea:	83 ec 04             	sub    $0x4,%esp
801080ed:	68 00 10 00 00       	push   $0x1000
801080f2:	6a 00                	push   $0x0
801080f4:	ff 75 f0             	pushl  -0x10(%ebp)
801080f7:	e8 24 d5 ff ff       	call   80105620 <memset>
801080fc:	83 c4 10             	add    $0x10,%esp
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
801080ff:	83 ec 0c             	sub    $0xc,%esp
80108102:	68 00 00 00 0e       	push   $0xe000000
80108107:	e8 0d fa ff ff       	call   80107b19 <p2v>
8010810c:	83 c4 10             	add    $0x10,%esp
8010810f:	3d 00 00 00 fe       	cmp    $0xfe000000,%eax
80108114:	76 0d                	jbe    80108123 <setupkvm+0x58>
    panic("PHYSTOP too high");
80108116:	83 ec 0c             	sub    $0xc,%esp
80108119:	68 0e 8f 10 80       	push   $0x80108f0e
8010811e:	e8 43 84 ff ff       	call   80100566 <panic>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80108123:	c7 45 f4 a0 b4 10 80 	movl   $0x8010b4a0,-0xc(%ebp)
8010812a:	eb 40                	jmp    8010816c <setupkvm+0xa1>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
8010812c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010812f:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0)
80108132:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108135:	8b 50 04             	mov    0x4(%eax),%edx
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
80108138:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010813b:	8b 58 08             	mov    0x8(%eax),%ebx
8010813e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108141:	8b 40 04             	mov    0x4(%eax),%eax
80108144:	29 c3                	sub    %eax,%ebx
80108146:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108149:	8b 00                	mov    (%eax),%eax
8010814b:	83 ec 0c             	sub    $0xc,%esp
8010814e:	51                   	push   %ecx
8010814f:	52                   	push   %edx
80108150:	53                   	push   %ebx
80108151:	50                   	push   %eax
80108152:	ff 75 f0             	pushl  -0x10(%ebp)
80108155:	e8 e1 fe ff ff       	call   8010803b <mappages>
8010815a:	83 c4 20             	add    $0x20,%esp
8010815d:	85 c0                	test   %eax,%eax
8010815f:	79 07                	jns    80108168 <setupkvm+0x9d>
                (uint)k->phys_start, k->perm) < 0)
      return 0;
80108161:	b8 00 00 00 00       	mov    $0x0,%eax
80108166:	eb 10                	jmp    80108178 <setupkvm+0xad>
  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80108168:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
8010816c:	81 7d f4 e0 b4 10 80 	cmpl   $0x8010b4e0,-0xc(%ebp)
80108173:	72 b7                	jb     8010812c <setupkvm+0x61>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
                (uint)k->phys_start, k->perm) < 0)
      return 0;
  return pgdir;
80108175:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80108178:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010817b:	c9                   	leave  
8010817c:	c3                   	ret    

8010817d <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
8010817d:	55                   	push   %ebp
8010817e:	89 e5                	mov    %esp,%ebp
80108180:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80108183:	e8 43 ff ff ff       	call   801080cb <setupkvm>
80108188:	a3 18 54 11 80       	mov    %eax,0x80115418
  switchkvm();
8010818d:	e8 03 00 00 00       	call   80108195 <switchkvm>
}
80108192:	90                   	nop
80108193:	c9                   	leave  
80108194:	c3                   	ret    

80108195 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80108195:	55                   	push   %ebp
80108196:	89 e5                	mov    %esp,%ebp
  lcr3(v2p(kpgdir));   // switch to the kernel page table
80108198:	a1 18 54 11 80       	mov    0x80115418,%eax
8010819d:	50                   	push   %eax
8010819e:	e8 69 f9 ff ff       	call   80107b0c <v2p>
801081a3:	83 c4 04             	add    $0x4,%esp
801081a6:	50                   	push   %eax
801081a7:	e8 54 f9 ff ff       	call   80107b00 <lcr3>
801081ac:	83 c4 04             	add    $0x4,%esp
}
801081af:	90                   	nop
801081b0:	c9                   	leave  
801081b1:	c3                   	ret    

801081b2 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
801081b2:	55                   	push   %ebp
801081b3:	89 e5                	mov    %esp,%ebp
801081b5:	56                   	push   %esi
801081b6:	53                   	push   %ebx
  pushcli();
801081b7:	e8 5e d3 ff ff       	call   8010551a <pushcli>
  cpu->gdt[SEG_TSS] = SEG16(STS_T32A, &cpu->ts, sizeof(cpu->ts)-1, 0);
801081bc:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801081c2:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
801081c9:	83 c2 08             	add    $0x8,%edx
801081cc:	89 d6                	mov    %edx,%esi
801081ce:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
801081d5:	83 c2 08             	add    $0x8,%edx
801081d8:	c1 ea 10             	shr    $0x10,%edx
801081db:	89 d3                	mov    %edx,%ebx
801081dd:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
801081e4:	83 c2 08             	add    $0x8,%edx
801081e7:	c1 ea 18             	shr    $0x18,%edx
801081ea:	89 d1                	mov    %edx,%ecx
801081ec:	66 c7 80 a0 00 00 00 	movw   $0x67,0xa0(%eax)
801081f3:	67 00 
801081f5:	66 89 b0 a2 00 00 00 	mov    %si,0xa2(%eax)
801081fc:	88 98 a4 00 00 00    	mov    %bl,0xa4(%eax)
80108202:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108209:	83 e2 f0             	and    $0xfffffff0,%edx
8010820c:	83 ca 09             	or     $0x9,%edx
8010820f:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80108215:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
8010821c:	83 ca 10             	or     $0x10,%edx
8010821f:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80108225:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
8010822c:	83 e2 9f             	and    $0xffffff9f,%edx
8010822f:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80108235:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
8010823c:	83 ca 80             	or     $0xffffff80,%edx
8010823f:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80108245:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
8010824c:	83 e2 f0             	and    $0xfffffff0,%edx
8010824f:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80108255:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
8010825c:	83 e2 ef             	and    $0xffffffef,%edx
8010825f:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80108265:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
8010826c:	83 e2 df             	and    $0xffffffdf,%edx
8010826f:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80108275:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
8010827c:	83 ca 40             	or     $0x40,%edx
8010827f:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80108285:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
8010828c:	83 e2 7f             	and    $0x7f,%edx
8010828f:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80108295:	88 88 a7 00 00 00    	mov    %cl,0xa7(%eax)
  cpu->gdt[SEG_TSS].s = 0;
8010829b:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801082a1:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
801082a8:	83 e2 ef             	and    $0xffffffef,%edx
801082ab:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
  cpu->ts.ss0 = SEG_KDATA << 3;
801082b1:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801082b7:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  cpu->ts.esp0 = (uint)proc->kstack + KSTACKSIZE;
801082bd:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801082c3:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801082ca:	8b 52 08             	mov    0x8(%edx),%edx
801082cd:	81 c2 00 10 00 00    	add    $0x1000,%edx
801082d3:	89 50 0c             	mov    %edx,0xc(%eax)
  ltr(SEG_TSS << 3);
801082d6:	83 ec 0c             	sub    $0xc,%esp
801082d9:	6a 30                	push   $0x30
801082db:	e8 f3 f7 ff ff       	call   80107ad3 <ltr>
801082e0:	83 c4 10             	add    $0x10,%esp
  if(p->pgdir == 0)
801082e3:	8b 45 08             	mov    0x8(%ebp),%eax
801082e6:	8b 40 04             	mov    0x4(%eax),%eax
801082e9:	85 c0                	test   %eax,%eax
801082eb:	75 0d                	jne    801082fa <switchuvm+0x148>
    panic("switchuvm: no pgdir");
801082ed:	83 ec 0c             	sub    $0xc,%esp
801082f0:	68 1f 8f 10 80       	push   $0x80108f1f
801082f5:	e8 6c 82 ff ff       	call   80100566 <panic>
  lcr3(v2p(p->pgdir));  // switch to new address space
801082fa:	8b 45 08             	mov    0x8(%ebp),%eax
801082fd:	8b 40 04             	mov    0x4(%eax),%eax
80108300:	83 ec 0c             	sub    $0xc,%esp
80108303:	50                   	push   %eax
80108304:	e8 03 f8 ff ff       	call   80107b0c <v2p>
80108309:	83 c4 10             	add    $0x10,%esp
8010830c:	83 ec 0c             	sub    $0xc,%esp
8010830f:	50                   	push   %eax
80108310:	e8 eb f7 ff ff       	call   80107b00 <lcr3>
80108315:	83 c4 10             	add    $0x10,%esp
  popcli();
80108318:	e8 42 d2 ff ff       	call   8010555f <popcli>
}
8010831d:	90                   	nop
8010831e:	8d 65 f8             	lea    -0x8(%ebp),%esp
80108321:	5b                   	pop    %ebx
80108322:	5e                   	pop    %esi
80108323:	5d                   	pop    %ebp
80108324:	c3                   	ret    

80108325 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80108325:	55                   	push   %ebp
80108326:	89 e5                	mov    %esp,%ebp
80108328:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  
  if(sz >= PGSIZE)
8010832b:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80108332:	76 0d                	jbe    80108341 <inituvm+0x1c>
    panic("inituvm: more than a page");
80108334:	83 ec 0c             	sub    $0xc,%esp
80108337:	68 33 8f 10 80       	push   $0x80108f33
8010833c:	e8 25 82 ff ff       	call   80100566 <panic>
  mem = kalloc();
80108341:	e8 b8 ac ff ff       	call   80102ffe <kalloc>
80108346:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80108349:	83 ec 04             	sub    $0x4,%esp
8010834c:	68 00 10 00 00       	push   $0x1000
80108351:	6a 00                	push   $0x0
80108353:	ff 75 f4             	pushl  -0xc(%ebp)
80108356:	e8 c5 d2 ff ff       	call   80105620 <memset>
8010835b:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, v2p(mem), PTE_W|PTE_U);
8010835e:	83 ec 0c             	sub    $0xc,%esp
80108361:	ff 75 f4             	pushl  -0xc(%ebp)
80108364:	e8 a3 f7 ff ff       	call   80107b0c <v2p>
80108369:	83 c4 10             	add    $0x10,%esp
8010836c:	83 ec 0c             	sub    $0xc,%esp
8010836f:	6a 06                	push   $0x6
80108371:	50                   	push   %eax
80108372:	68 00 10 00 00       	push   $0x1000
80108377:	6a 00                	push   $0x0
80108379:	ff 75 08             	pushl  0x8(%ebp)
8010837c:	e8 ba fc ff ff       	call   8010803b <mappages>
80108381:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
80108384:	83 ec 04             	sub    $0x4,%esp
80108387:	ff 75 10             	pushl  0x10(%ebp)
8010838a:	ff 75 0c             	pushl  0xc(%ebp)
8010838d:	ff 75 f4             	pushl  -0xc(%ebp)
80108390:	e8 4a d3 ff ff       	call   801056df <memmove>
80108395:	83 c4 10             	add    $0x10,%esp
}
80108398:	90                   	nop
80108399:	c9                   	leave  
8010839a:	c3                   	ret    

8010839b <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
8010839b:	55                   	push   %ebp
8010839c:	89 e5                	mov    %esp,%ebp
8010839e:	53                   	push   %ebx
8010839f:	83 ec 14             	sub    $0x14,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
801083a2:	8b 45 0c             	mov    0xc(%ebp),%eax
801083a5:	25 ff 0f 00 00       	and    $0xfff,%eax
801083aa:	85 c0                	test   %eax,%eax
801083ac:	74 0d                	je     801083bb <loaduvm+0x20>
    panic("loaduvm: addr must be page aligned");
801083ae:	83 ec 0c             	sub    $0xc,%esp
801083b1:	68 50 8f 10 80       	push   $0x80108f50
801083b6:	e8 ab 81 ff ff       	call   80100566 <panic>
  for(i = 0; i < sz; i += PGSIZE){
801083bb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801083c2:	e9 95 00 00 00       	jmp    8010845c <loaduvm+0xc1>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
801083c7:	8b 55 0c             	mov    0xc(%ebp),%edx
801083ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083cd:	01 d0                	add    %edx,%eax
801083cf:	83 ec 04             	sub    $0x4,%esp
801083d2:	6a 00                	push   $0x0
801083d4:	50                   	push   %eax
801083d5:	ff 75 08             	pushl  0x8(%ebp)
801083d8:	e8 be fb ff ff       	call   80107f9b <walkpgdir>
801083dd:	83 c4 10             	add    $0x10,%esp
801083e0:	89 45 ec             	mov    %eax,-0x14(%ebp)
801083e3:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801083e7:	75 0d                	jne    801083f6 <loaduvm+0x5b>
      panic("loaduvm: address should exist");
801083e9:	83 ec 0c             	sub    $0xc,%esp
801083ec:	68 73 8f 10 80       	push   $0x80108f73
801083f1:	e8 70 81 ff ff       	call   80100566 <panic>
    pa = PTE_ADDR(*pte);
801083f6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801083f9:	8b 00                	mov    (%eax),%eax
801083fb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108400:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80108403:	8b 45 18             	mov    0x18(%ebp),%eax
80108406:	2b 45 f4             	sub    -0xc(%ebp),%eax
80108409:	3d ff 0f 00 00       	cmp    $0xfff,%eax
8010840e:	77 0b                	ja     8010841b <loaduvm+0x80>
      n = sz - i;
80108410:	8b 45 18             	mov    0x18(%ebp),%eax
80108413:	2b 45 f4             	sub    -0xc(%ebp),%eax
80108416:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108419:	eb 07                	jmp    80108422 <loaduvm+0x87>
    else
      n = PGSIZE;
8010841b:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, p2v(pa), offset+i, n) != n)
80108422:	8b 55 14             	mov    0x14(%ebp),%edx
80108425:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108428:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
8010842b:	83 ec 0c             	sub    $0xc,%esp
8010842e:	ff 75 e8             	pushl  -0x18(%ebp)
80108431:	e8 e3 f6 ff ff       	call   80107b19 <p2v>
80108436:	83 c4 10             	add    $0x10,%esp
80108439:	ff 75 f0             	pushl  -0x10(%ebp)
8010843c:	53                   	push   %ebx
8010843d:	50                   	push   %eax
8010843e:	ff 75 10             	pushl  0x10(%ebp)
80108441:	e8 17 9e ff ff       	call   8010225d <readi>
80108446:	83 c4 10             	add    $0x10,%esp
80108449:	3b 45 f0             	cmp    -0x10(%ebp),%eax
8010844c:	74 07                	je     80108455 <loaduvm+0xba>
      return -1;
8010844e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108453:	eb 18                	jmp    8010846d <loaduvm+0xd2>
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
80108455:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010845c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010845f:	3b 45 18             	cmp    0x18(%ebp),%eax
80108462:	0f 82 5f ff ff ff    	jb     801083c7 <loaduvm+0x2c>
    else
      n = PGSIZE;
    if(readi(ip, p2v(pa), offset+i, n) != n)
      return -1;
  }
  return 0;
80108468:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010846d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108470:	c9                   	leave  
80108471:	c3                   	ret    

80108472 <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80108472:	55                   	push   %ebp
80108473:	89 e5                	mov    %esp,%ebp
80108475:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
80108478:	8b 45 10             	mov    0x10(%ebp),%eax
8010847b:	85 c0                	test   %eax,%eax
8010847d:	79 0a                	jns    80108489 <allocuvm+0x17>
    return 0;
8010847f:	b8 00 00 00 00       	mov    $0x0,%eax
80108484:	e9 b0 00 00 00       	jmp    80108539 <allocuvm+0xc7>
  if(newsz < oldsz)
80108489:	8b 45 10             	mov    0x10(%ebp),%eax
8010848c:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010848f:	73 08                	jae    80108499 <allocuvm+0x27>
    return oldsz;
80108491:	8b 45 0c             	mov    0xc(%ebp),%eax
80108494:	e9 a0 00 00 00       	jmp    80108539 <allocuvm+0xc7>

  a = PGROUNDUP(oldsz);
80108499:	8b 45 0c             	mov    0xc(%ebp),%eax
8010849c:	05 ff 0f 00 00       	add    $0xfff,%eax
801084a1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801084a6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
801084a9:	eb 7f                	jmp    8010852a <allocuvm+0xb8>
    mem = kalloc();
801084ab:	e8 4e ab ff ff       	call   80102ffe <kalloc>
801084b0:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
801084b3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801084b7:	75 2b                	jne    801084e4 <allocuvm+0x72>
      cprintf("allocuvm out of memory\n");
801084b9:	83 ec 0c             	sub    $0xc,%esp
801084bc:	68 91 8f 10 80       	push   $0x80108f91
801084c1:	e8 00 7f ff ff       	call   801003c6 <cprintf>
801084c6:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
801084c9:	83 ec 04             	sub    $0x4,%esp
801084cc:	ff 75 0c             	pushl  0xc(%ebp)
801084cf:	ff 75 10             	pushl  0x10(%ebp)
801084d2:	ff 75 08             	pushl  0x8(%ebp)
801084d5:	e8 61 00 00 00       	call   8010853b <deallocuvm>
801084da:	83 c4 10             	add    $0x10,%esp
      return 0;
801084dd:	b8 00 00 00 00       	mov    $0x0,%eax
801084e2:	eb 55                	jmp    80108539 <allocuvm+0xc7>
    }
    memset(mem, 0, PGSIZE);
801084e4:	83 ec 04             	sub    $0x4,%esp
801084e7:	68 00 10 00 00       	push   $0x1000
801084ec:	6a 00                	push   $0x0
801084ee:	ff 75 f0             	pushl  -0x10(%ebp)
801084f1:	e8 2a d1 ff ff       	call   80105620 <memset>
801084f6:	83 c4 10             	add    $0x10,%esp
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
801084f9:	83 ec 0c             	sub    $0xc,%esp
801084fc:	ff 75 f0             	pushl  -0x10(%ebp)
801084ff:	e8 08 f6 ff ff       	call   80107b0c <v2p>
80108504:	83 c4 10             	add    $0x10,%esp
80108507:	89 c2                	mov    %eax,%edx
80108509:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010850c:	83 ec 0c             	sub    $0xc,%esp
8010850f:	6a 06                	push   $0x6
80108511:	52                   	push   %edx
80108512:	68 00 10 00 00       	push   $0x1000
80108517:	50                   	push   %eax
80108518:	ff 75 08             	pushl  0x8(%ebp)
8010851b:	e8 1b fb ff ff       	call   8010803b <mappages>
80108520:	83 c4 20             	add    $0x20,%esp
    return 0;
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){
80108523:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010852a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010852d:	3b 45 10             	cmp    0x10(%ebp),%eax
80108530:	0f 82 75 ff ff ff    	jb     801084ab <allocuvm+0x39>
      return 0;
    }
    memset(mem, 0, PGSIZE);
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
  }
  return newsz;
80108536:	8b 45 10             	mov    0x10(%ebp),%eax
}
80108539:	c9                   	leave  
8010853a:	c3                   	ret    

8010853b <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
8010853b:	55                   	push   %ebp
8010853c:	89 e5                	mov    %esp,%ebp
8010853e:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80108541:	8b 45 10             	mov    0x10(%ebp),%eax
80108544:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108547:	72 08                	jb     80108551 <deallocuvm+0x16>
    return oldsz;
80108549:	8b 45 0c             	mov    0xc(%ebp),%eax
8010854c:	e9 a5 00 00 00       	jmp    801085f6 <deallocuvm+0xbb>

  a = PGROUNDUP(newsz);
80108551:	8b 45 10             	mov    0x10(%ebp),%eax
80108554:	05 ff 0f 00 00       	add    $0xfff,%eax
80108559:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010855e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80108561:	e9 81 00 00 00       	jmp    801085e7 <deallocuvm+0xac>
    pte = walkpgdir(pgdir, (char*)a, 0);
80108566:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108569:	83 ec 04             	sub    $0x4,%esp
8010856c:	6a 00                	push   $0x0
8010856e:	50                   	push   %eax
8010856f:	ff 75 08             	pushl  0x8(%ebp)
80108572:	e8 24 fa ff ff       	call   80107f9b <walkpgdir>
80108577:	83 c4 10             	add    $0x10,%esp
8010857a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
8010857d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108581:	75 09                	jne    8010858c <deallocuvm+0x51>
      a += (NPTENTRIES - 1) * PGSIZE;
80108583:	81 45 f4 00 f0 3f 00 	addl   $0x3ff000,-0xc(%ebp)
8010858a:	eb 54                	jmp    801085e0 <deallocuvm+0xa5>
    else if((*pte & PTE_P) != 0){
8010858c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010858f:	8b 00                	mov    (%eax),%eax
80108591:	83 e0 01             	and    $0x1,%eax
80108594:	85 c0                	test   %eax,%eax
80108596:	74 48                	je     801085e0 <deallocuvm+0xa5>
      pa = PTE_ADDR(*pte);
80108598:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010859b:	8b 00                	mov    (%eax),%eax
8010859d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801085a2:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
801085a5:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801085a9:	75 0d                	jne    801085b8 <deallocuvm+0x7d>
        panic("kfree");
801085ab:	83 ec 0c             	sub    $0xc,%esp
801085ae:	68 a9 8f 10 80       	push   $0x80108fa9
801085b3:	e8 ae 7f ff ff       	call   80100566 <panic>
      char *v = p2v(pa);
801085b8:	83 ec 0c             	sub    $0xc,%esp
801085bb:	ff 75 ec             	pushl  -0x14(%ebp)
801085be:	e8 56 f5 ff ff       	call   80107b19 <p2v>
801085c3:	83 c4 10             	add    $0x10,%esp
801085c6:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
801085c9:	83 ec 0c             	sub    $0xc,%esp
801085cc:	ff 75 e8             	pushl  -0x18(%ebp)
801085cf:	e8 8d a9 ff ff       	call   80102f61 <kfree>
801085d4:	83 c4 10             	add    $0x10,%esp
      *pte = 0;
801085d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801085da:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
801085e0:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801085e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085ea:	3b 45 0c             	cmp    0xc(%ebp),%eax
801085ed:	0f 82 73 ff ff ff    	jb     80108566 <deallocuvm+0x2b>
      char *v = p2v(pa);
      kfree(v);
      *pte = 0;
    }
  }
  return newsz;
801085f3:	8b 45 10             	mov    0x10(%ebp),%eax
}
801085f6:	c9                   	leave  
801085f7:	c3                   	ret    

801085f8 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
801085f8:	55                   	push   %ebp
801085f9:	89 e5                	mov    %esp,%ebp
801085fb:	83 ec 18             	sub    $0x18,%esp
  uint i;

  if(pgdir == 0)
801085fe:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80108602:	75 0d                	jne    80108611 <freevm+0x19>
    panic("freevm: no pgdir");
80108604:	83 ec 0c             	sub    $0xc,%esp
80108607:	68 af 8f 10 80       	push   $0x80108faf
8010860c:	e8 55 7f ff ff       	call   80100566 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
80108611:	83 ec 04             	sub    $0x4,%esp
80108614:	6a 00                	push   $0x0
80108616:	68 00 00 00 80       	push   $0x80000000
8010861b:	ff 75 08             	pushl  0x8(%ebp)
8010861e:	e8 18 ff ff ff       	call   8010853b <deallocuvm>
80108623:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80108626:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010862d:	eb 4f                	jmp    8010867e <freevm+0x86>
    if(pgdir[i] & PTE_P){
8010862f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108632:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108639:	8b 45 08             	mov    0x8(%ebp),%eax
8010863c:	01 d0                	add    %edx,%eax
8010863e:	8b 00                	mov    (%eax),%eax
80108640:	83 e0 01             	and    $0x1,%eax
80108643:	85 c0                	test   %eax,%eax
80108645:	74 33                	je     8010867a <freevm+0x82>
      char * v = p2v(PTE_ADDR(pgdir[i]));
80108647:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010864a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108651:	8b 45 08             	mov    0x8(%ebp),%eax
80108654:	01 d0                	add    %edx,%eax
80108656:	8b 00                	mov    (%eax),%eax
80108658:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010865d:	83 ec 0c             	sub    $0xc,%esp
80108660:	50                   	push   %eax
80108661:	e8 b3 f4 ff ff       	call   80107b19 <p2v>
80108666:	83 c4 10             	add    $0x10,%esp
80108669:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
8010866c:	83 ec 0c             	sub    $0xc,%esp
8010866f:	ff 75 f0             	pushl  -0x10(%ebp)
80108672:	e8 ea a8 ff ff       	call   80102f61 <kfree>
80108677:	83 c4 10             	add    $0x10,%esp
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
8010867a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010867e:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
80108685:	76 a8                	jbe    8010862f <freevm+0x37>
    if(pgdir[i] & PTE_P){
      char * v = p2v(PTE_ADDR(pgdir[i]));
      kfree(v);
    }
  }
  kfree((char*)pgdir);
80108687:	83 ec 0c             	sub    $0xc,%esp
8010868a:	ff 75 08             	pushl  0x8(%ebp)
8010868d:	e8 cf a8 ff ff       	call   80102f61 <kfree>
80108692:	83 c4 10             	add    $0x10,%esp
}
80108695:	90                   	nop
80108696:	c9                   	leave  
80108697:	c3                   	ret    

80108698 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80108698:	55                   	push   %ebp
80108699:	89 e5                	mov    %esp,%ebp
8010869b:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
8010869e:	83 ec 04             	sub    $0x4,%esp
801086a1:	6a 00                	push   $0x0
801086a3:	ff 75 0c             	pushl  0xc(%ebp)
801086a6:	ff 75 08             	pushl  0x8(%ebp)
801086a9:	e8 ed f8 ff ff       	call   80107f9b <walkpgdir>
801086ae:	83 c4 10             	add    $0x10,%esp
801086b1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
801086b4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801086b8:	75 0d                	jne    801086c7 <clearpteu+0x2f>
    panic("clearpteu");
801086ba:	83 ec 0c             	sub    $0xc,%esp
801086bd:	68 c0 8f 10 80       	push   $0x80108fc0
801086c2:	e8 9f 7e ff ff       	call   80100566 <panic>
  *pte &= ~PTE_U;
801086c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086ca:	8b 00                	mov    (%eax),%eax
801086cc:	83 e0 fb             	and    $0xfffffffb,%eax
801086cf:	89 c2                	mov    %eax,%edx
801086d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086d4:	89 10                	mov    %edx,(%eax)
}
801086d6:	90                   	nop
801086d7:	c9                   	leave  
801086d8:	c3                   	ret    

801086d9 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
801086d9:	55                   	push   %ebp
801086da:	89 e5                	mov    %esp,%ebp
801086dc:	53                   	push   %ebx
801086dd:	83 ec 24             	sub    $0x24,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
801086e0:	e8 e6 f9 ff ff       	call   801080cb <setupkvm>
801086e5:	89 45 f0             	mov    %eax,-0x10(%ebp)
801086e8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801086ec:	75 0a                	jne    801086f8 <copyuvm+0x1f>
    return 0;
801086ee:	b8 00 00 00 00       	mov    $0x0,%eax
801086f3:	e9 f8 00 00 00       	jmp    801087f0 <copyuvm+0x117>
  for(i = 0; i < sz; i += PGSIZE){
801086f8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801086ff:	e9 c4 00 00 00       	jmp    801087c8 <copyuvm+0xef>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80108704:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108707:	83 ec 04             	sub    $0x4,%esp
8010870a:	6a 00                	push   $0x0
8010870c:	50                   	push   %eax
8010870d:	ff 75 08             	pushl  0x8(%ebp)
80108710:	e8 86 f8 ff ff       	call   80107f9b <walkpgdir>
80108715:	83 c4 10             	add    $0x10,%esp
80108718:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010871b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010871f:	75 0d                	jne    8010872e <copyuvm+0x55>
      panic("copyuvm: pte should exist");
80108721:	83 ec 0c             	sub    $0xc,%esp
80108724:	68 ca 8f 10 80       	push   $0x80108fca
80108729:	e8 38 7e ff ff       	call   80100566 <panic>
    if(!(*pte & PTE_P))
8010872e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108731:	8b 00                	mov    (%eax),%eax
80108733:	83 e0 01             	and    $0x1,%eax
80108736:	85 c0                	test   %eax,%eax
80108738:	75 0d                	jne    80108747 <copyuvm+0x6e>
      panic("copyuvm: page not present");
8010873a:	83 ec 0c             	sub    $0xc,%esp
8010873d:	68 e4 8f 10 80       	push   $0x80108fe4
80108742:	e8 1f 7e ff ff       	call   80100566 <panic>
    pa = PTE_ADDR(*pte);
80108747:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010874a:	8b 00                	mov    (%eax),%eax
8010874c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108751:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
80108754:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108757:	8b 00                	mov    (%eax),%eax
80108759:	25 ff 0f 00 00       	and    $0xfff,%eax
8010875e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
80108761:	e8 98 a8 ff ff       	call   80102ffe <kalloc>
80108766:	89 45 e0             	mov    %eax,-0x20(%ebp)
80108769:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
8010876d:	74 6a                	je     801087d9 <copyuvm+0x100>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
8010876f:	83 ec 0c             	sub    $0xc,%esp
80108772:	ff 75 e8             	pushl  -0x18(%ebp)
80108775:	e8 9f f3 ff ff       	call   80107b19 <p2v>
8010877a:	83 c4 10             	add    $0x10,%esp
8010877d:	83 ec 04             	sub    $0x4,%esp
80108780:	68 00 10 00 00       	push   $0x1000
80108785:	50                   	push   %eax
80108786:	ff 75 e0             	pushl  -0x20(%ebp)
80108789:	e8 51 cf ff ff       	call   801056df <memmove>
8010878e:	83 c4 10             	add    $0x10,%esp
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
80108791:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
80108794:	83 ec 0c             	sub    $0xc,%esp
80108797:	ff 75 e0             	pushl  -0x20(%ebp)
8010879a:	e8 6d f3 ff ff       	call   80107b0c <v2p>
8010879f:	83 c4 10             	add    $0x10,%esp
801087a2:	89 c2                	mov    %eax,%edx
801087a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087a7:	83 ec 0c             	sub    $0xc,%esp
801087aa:	53                   	push   %ebx
801087ab:	52                   	push   %edx
801087ac:	68 00 10 00 00       	push   $0x1000
801087b1:	50                   	push   %eax
801087b2:	ff 75 f0             	pushl  -0x10(%ebp)
801087b5:	e8 81 f8 ff ff       	call   8010803b <mappages>
801087ba:	83 c4 20             	add    $0x20,%esp
801087bd:	85 c0                	test   %eax,%eax
801087bf:	78 1b                	js     801087dc <copyuvm+0x103>
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
801087c1:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801087c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087cb:	3b 45 0c             	cmp    0xc(%ebp),%eax
801087ce:	0f 82 30 ff ff ff    	jb     80108704 <copyuvm+0x2b>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
      goto bad;
  }
  return d;
801087d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801087d7:	eb 17                	jmp    801087f0 <copyuvm+0x117>
    if(!(*pte & PTE_P))
      panic("copyuvm: page not present");
    pa = PTE_ADDR(*pte);
    flags = PTE_FLAGS(*pte);
    if((mem = kalloc()) == 0)
      goto bad;
801087d9:	90                   	nop
801087da:	eb 01                	jmp    801087dd <copyuvm+0x104>
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
      goto bad;
801087dc:	90                   	nop
  }
  return d;

bad:
  freevm(d);
801087dd:	83 ec 0c             	sub    $0xc,%esp
801087e0:	ff 75 f0             	pushl  -0x10(%ebp)
801087e3:	e8 10 fe ff ff       	call   801085f8 <freevm>
801087e8:	83 c4 10             	add    $0x10,%esp
  return 0;
801087eb:	b8 00 00 00 00       	mov    $0x0,%eax
}
801087f0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801087f3:	c9                   	leave  
801087f4:	c3                   	ret    

801087f5 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
801087f5:	55                   	push   %ebp
801087f6:	89 e5                	mov    %esp,%ebp
801087f8:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
801087fb:	83 ec 04             	sub    $0x4,%esp
801087fe:	6a 00                	push   $0x0
80108800:	ff 75 0c             	pushl  0xc(%ebp)
80108803:	ff 75 08             	pushl  0x8(%ebp)
80108806:	e8 90 f7 ff ff       	call   80107f9b <walkpgdir>
8010880b:	83 c4 10             	add    $0x10,%esp
8010880e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
80108811:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108814:	8b 00                	mov    (%eax),%eax
80108816:	83 e0 01             	and    $0x1,%eax
80108819:	85 c0                	test   %eax,%eax
8010881b:	75 07                	jne    80108824 <uva2ka+0x2f>
    return 0;
8010881d:	b8 00 00 00 00       	mov    $0x0,%eax
80108822:	eb 29                	jmp    8010884d <uva2ka+0x58>
  if((*pte & PTE_U) == 0)
80108824:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108827:	8b 00                	mov    (%eax),%eax
80108829:	83 e0 04             	and    $0x4,%eax
8010882c:	85 c0                	test   %eax,%eax
8010882e:	75 07                	jne    80108837 <uva2ka+0x42>
    return 0;
80108830:	b8 00 00 00 00       	mov    $0x0,%eax
80108835:	eb 16                	jmp    8010884d <uva2ka+0x58>
  return (char*)p2v(PTE_ADDR(*pte));
80108837:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010883a:	8b 00                	mov    (%eax),%eax
8010883c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108841:	83 ec 0c             	sub    $0xc,%esp
80108844:	50                   	push   %eax
80108845:	e8 cf f2 ff ff       	call   80107b19 <p2v>
8010884a:	83 c4 10             	add    $0x10,%esp
}
8010884d:	c9                   	leave  
8010884e:	c3                   	ret    

8010884f <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
8010884f:	55                   	push   %ebp
80108850:	89 e5                	mov    %esp,%ebp
80108852:	83 ec 18             	sub    $0x18,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
80108855:	8b 45 10             	mov    0x10(%ebp),%eax
80108858:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
8010885b:	eb 7f                	jmp    801088dc <copyout+0x8d>
    va0 = (uint)PGROUNDDOWN(va);
8010885d:	8b 45 0c             	mov    0xc(%ebp),%eax
80108860:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108865:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
80108868:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010886b:	83 ec 08             	sub    $0x8,%esp
8010886e:	50                   	push   %eax
8010886f:	ff 75 08             	pushl  0x8(%ebp)
80108872:	e8 7e ff ff ff       	call   801087f5 <uva2ka>
80108877:	83 c4 10             	add    $0x10,%esp
8010887a:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
8010887d:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80108881:	75 07                	jne    8010888a <copyout+0x3b>
      return -1;
80108883:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108888:	eb 61                	jmp    801088eb <copyout+0x9c>
    n = PGSIZE - (va - va0);
8010888a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010888d:	2b 45 0c             	sub    0xc(%ebp),%eax
80108890:	05 00 10 00 00       	add    $0x1000,%eax
80108895:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
80108898:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010889b:	3b 45 14             	cmp    0x14(%ebp),%eax
8010889e:	76 06                	jbe    801088a6 <copyout+0x57>
      n = len;
801088a0:	8b 45 14             	mov    0x14(%ebp),%eax
801088a3:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
801088a6:	8b 45 0c             	mov    0xc(%ebp),%eax
801088a9:	2b 45 ec             	sub    -0x14(%ebp),%eax
801088ac:	89 c2                	mov    %eax,%edx
801088ae:	8b 45 e8             	mov    -0x18(%ebp),%eax
801088b1:	01 d0                	add    %edx,%eax
801088b3:	83 ec 04             	sub    $0x4,%esp
801088b6:	ff 75 f0             	pushl  -0x10(%ebp)
801088b9:	ff 75 f4             	pushl  -0xc(%ebp)
801088bc:	50                   	push   %eax
801088bd:	e8 1d ce ff ff       	call   801056df <memmove>
801088c2:	83 c4 10             	add    $0x10,%esp
    len -= n;
801088c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801088c8:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
801088cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801088ce:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
801088d1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801088d4:	05 00 10 00 00       	add    $0x1000,%eax
801088d9:	89 45 0c             	mov    %eax,0xc(%ebp)
{
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
801088dc:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
801088e0:	0f 85 77 ff ff ff    	jne    8010885d <copyout+0xe>
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
801088e6:	b8 00 00 00 00       	mov    $0x0,%eax
}
801088eb:	c9                   	leave  
801088ec:	c3                   	ret    
