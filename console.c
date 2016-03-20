  // Console input and output.
  // Input is from the keyboard or serial port.
  // Output is written to the screen and serial port.

  #include "types.h"
  #include "defs.h"
  #include "param.h"
  #include "traps.h"
  #include "spinlock.h"
  #include "fs.h"
  #include "file.h"
  #include "memlayout.h"
  #include "mmu.h"
  #include "proc.h"
  #include "x86.h"



//void addHistory(char*,uint,uint);
static void moveBufferByOne(int left,char *buffer,int starting);
static int moveCRTByOne(int left,ushort *buffer,int starting);

#define MAX_HISTORY 16
#define MAX_INPUT 128
static char history_buffer [MAX_HISTORY][MAX_INPUT];
void addHistory(char* buf,uint from,uint to)
{
  uint i;
  //move content of array to the right

  for (i= MAX_HISTORY -2 ; i< 0;i--){
  safestrcpy(history_buffer[i],history_buffer[i-1],strlen(history_buffer[i-1]));
  }
  //add new entry   
  memmove(history_buffer[0],buf+from,to-from+1);
    //history_buffer[0]+i = buf[i];
}

int history(ushort *buffer,int history_id)
{
  if(history_id<0 || history_id>MAX_HISTORY-1){
    return -2;
  }
  else
    if(history_buffer[history_id]==0){
      return -1;
    }
    else
    {
    //int i;
    int len = strlen(history_buffer[history_id]);
    memmove(buffer,history_buffer[history_id],len);
    //for(i=0;i<len;i++)
     // buffer[i] = history_buffer[history_id][i];
     return 0;
   }
}

  static void consputc(int);

  static int panicked = 0;

  static struct {
    struct spinlock lock;
    int locking;
  } cons;

  static void
  printint(int xx, int base, int sign)
  {
    static char digits[] = "0123456789abcdef";
    char buf[16];
    int i;
    uint x;

    if(sign && (sign = xx < 0))
      x = -xx;
    else
      x = xx;

    i = 0;
    do{
      buf[i++] = digits[x % base];
    }while((x /= base) != 0);

    if(sign)
      buf[i++] = '-';

    while(--i >= 0)
      consputc(buf[i]);
  }
  //PAGEBREAK: 50

  // Print to the console. only understands %d, %x, %p, %s.
  void
  cprintf(char *fmt, ...)
  {
    int i, c, locking;
    uint *argp;
    char *s;

    locking = cons.locking;
    if(locking)
      acquire(&cons.lock);

    if (fmt == 0)
      panic("null fmt");

    argp = (uint*)(void*)(&fmt + 1);
    for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
      if(c != '%'){
        consputc(c);
        continue;
      }
      c = fmt[++i] & 0xff;
      if(c == 0)
        break;
      switch(c){
        case 'd':
        printint(*argp++, 10, 1);
        break;
        case 'x':
        case 'p':
        printint(*argp++, 16, 0);
        break;
        case 's':
        if((s = (char*)*argp++) == 0)
          s = "(null)";
        for(; *s; s++)
          consputc(*s);
        break;
        case '%':
        consputc('%');
        break;
        default:
        // Print unknown % sequence to draw attention.
        consputc('%');
        consputc(c);
        break;
      }
    }

    if(locking)
      release(&cons.lock);
  }

  void
  panic(char *s)
  {
    int i;
    uint pcs[10];
    
    cli();
    cons.locking = 0;
    cprintf("cpu%d: panic: ", cpu->id);
    cprintf(s);
    cprintf("\n");
    getcallerpcs(&s, pcs);
    for(i=0; i<10; i++)
      cprintf(" %p", pcs[i]);
    panicked = 1; // freeze other CPU
    for(;;)
      ;
  }

  //PAGEBREAK: 50
  #define KEY_LF 228
  #define KEY_RT 0xE5
  #define KEY_UP 0xE2
  #define KEY_DN 0xE3
  #define BACKSPACE 0x100
  #define CRTPORT 0x3d4
  static ushort *crt = (ushort*)P2V(0xb8000);  // CGA memory
  static int moved_left=0;
  //static char history_buffer[128];
  static int history_index=-1;



 static void put_history(int history_index, int crt_pos){
      history(crt+crt_pos,history_index);
      }
  


  static void cgaputc(int c)
  {
    char replace=' ';
    int pos;

    
    // Cursor position: col + 80*row.
    outb(CRTPORT, 14);
    pos = inb(CRTPORT+1) << 8;
    outb(CRTPORT, 15);
    pos |= inb(CRTPORT+1);

    if(c == '\n'){
      //outb(CRTPORT, 14);
      //outb(CRTPORT+1, (pos+moved_left)>>8);
      pos = pos + moved_left;
      pos = pos + (80 - (pos)%80);
      moved_left=0;
  }
  else if(c == BACKSPACE){
    if(pos > 0) {
      --pos;
      replace=moveCRTByOne(1,crt,pos);
    }
  } 
  else if(c== KEY_LF){ 
    if((pos%80) > 2){
    replace=crt[pos-1];
    pos--;
  }
    else
      if ((pos%80) == 2){
        replace=crt[pos];
      }
  }
  else if(c==KEY_RT){
    if(moved_left>=0){
      replace=crt[pos+1];
      pos++;
    }
  }
  else
   if(c==KEY_UP){
   //history_index++;
    put_history(history_index,80 - (pos%80));
  }
  else
   if(c==KEY_DN){
    //history_index--;
  put_history(history_index,80 - (pos%80));
  }

  else{
    if(moved_left>0){
      replace=moveCRTByOne(0,crt,pos);
    }
    

      crt[pos++] = (c&0xff) | 0x0700;  // black on white
    }
    if(pos < 0 || pos > 25*80)
      panic("pos under/overflow");
    
    if((pos/80) >= 24){  // Scroll up.
      memmove(crt, crt+80, sizeof(crt[0])*23*80);
      pos -= 80;
      memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
    }
   
    
  outb(CRTPORT, 14);
  outb(CRTPORT+1, pos>>8);
  outb(CRTPORT, 15);
  outb(CRTPORT+1, pos);
    crt[pos] = replace | 0x0700;
  }
  
 
  
  void
  consputc(int c)
  {
    if(panicked){
      cli();
      for(;;)
        ;
    }

    if(c == BACKSPACE){
      uartputc('\b'); uartputc(' '); uartputc('\b');
    } else
    uartputc(c);
    cgaputc(c);
  }



  #define INPUT_BUF 128
  struct {
    char buf[INPUT_BUF];
    uint r;  // Read index
    uint w;  // Write index
    uint e;  // Edit index
  } input;

  #define C(x)  ((x)-'@')  // Control-x

 static int  moveCRTByOne(int left,ushort *buffer,int starting){
    int i;
    if(!left){
      for(i=starting+moved_left;i>starting;i--){
          buffer[i]=buffer[i-1];

      }
      return buffer[starting+1];
    }
    else{
      for(i=starting;i<starting+moved_left+1;i++){
          buffer[i]=buffer[i+1];
      }
      return buffer[starting];
    }
  }

  static void  moveBufferByOne(int left,char *buffer,int starting){
    int i;
    if(!left){
      for(i=starting+moved_left;i>starting;i--){
          buffer[i]=buffer[i-1];
      }
    }
    else{
      for(i=starting;i<starting+moved_left+1;i++){
          buffer[i]=buffer[i+1];
      }
    }
  }

  static int writechar=1;

  void
  consoleintr(int (*getc)(void))
  {
    int c, doprocdump = 0;
      
    acquire(&cons.lock);
    while((c = getc()) >= 0){
      switch(c){
      case C('P'):  // Process listing.
        doprocdump = 1;   // procdump() locks cons.lock indirectly; invoke later
        break;
      case C('U'):  // Kill line.
      while(input.e != input.w &&
        input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
      consputc(BACKSPACE);
    }
    break;
      case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){

        input.e--;
        moveBufferByOne(1,input.buf,input.e);
        consputc(BACKSPACE);
      }
      break;
      default:
        if(c != 0 && input.e-input.r < INPUT_BUF){
        c = (c == '\r') ? '\n' : c;
        if(c == KEY_RT)
        {
          if (/*input.e < input.e + moved_left*/ moved_left > 0)
          {
          input.e++;
          moved_left--;
          writechar=1;
          }
          else
            writechar=0;
        }
        else
          if (c == KEY_LF)
          {
            if (input.e > input.r)
            {
            input.e--;
            moved_left++;
            writechar=1;
          }
          else
            writechar =0;
          }
          else
            if (c == KEY_UP)
            {
              history_index++;
              writechar=1;
            }
            else
              if (c== KEY_DN)
              {
                history_index--;
                writechar=1;
              }
         else if (c == '\n')
          {
           input.e = (input.e + moved_left) % INPUT_BUF;
           input.buf[input.e++ % INPUT_BUF] = c;
           writechar =1;
          }
          else
          {
            writechar =1;
        moveBufferByOne(0,input.buf,input.e);
        input.buf[input.e++ % INPUT_BUF] = c;
      }
      if (writechar)
        consputc(c);
      if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
        input.w = input.e;
        addHistory(input.buf, input.r,input.w);
        wakeup(&input.r);
        
        }
      }
      break;
    }
  }
  release(&cons.lock);
  if(doprocdump) {
      procdump();  // now call procdump() wo. cons.lock held
    }
  }

  

  int
  consoleread(struct inode *ip, char *dst, int n)
  {
    uint target;
    int c;

    iunlock(ip);
    target = n;
    acquire(&cons.lock);
    while(n > 0){
      while(input.r == input.w){
        if(proc->killed){
          release(&cons.lock);
          ilock(ip);
          return -1;
        }
        sleep(&input.r, &cons.lock);
      }
      c = input.buf[input.r++ % INPUT_BUF];
      if(c == C('D')){  // EOF
        if(n < target){
          // Save ^D for next time, to make sure
          // caller gets a 0-byte result.
          input.r--;
        }
        break;
      }
      *dst++ = c;
      --n;
      if(c == '\n')
        break;
    }
    release(&cons.lock);
    ilock(ip);

    return target - n;
  }

  int
  consolewrite(struct inode *ip, char *buf, int n)
  {
    int i;

    iunlock(ip);
    acquire(&cons.lock);
    for(i = 0; i < n; i++)
      consputc(buf[i] & 0xff);
    release(&cons.lock);
    ilock(ip);

    return n;
  }

  void
  consoleinit(void)
  {
    initlock(&cons.lock, "console");

    devsw[CONSOLE].write = consolewrite;
    devsw[CONSOLE].read = consoleread;
    cons.locking = 1;

    picenable(IRQ_KBD);
    ioapicenable(IRQ_KBD, 0);
  }

