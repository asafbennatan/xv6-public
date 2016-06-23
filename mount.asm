
_mount:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "user.h"


int
main(int argc, char *argv[])
{
   0:	8d 4c 24 04          	lea    0x4(%esp),%ecx
   4:	83 e4 f0             	and    $0xfffffff0,%esp
   7:	ff 71 fc             	pushl  -0x4(%ecx)
   a:	55                   	push   %ebp
   b:	89 e5                	mov    %esp,%ebp
   d:	51                   	push   %ecx
   e:	83 ec 14             	sub    $0x14,%esp
  11:	89 c8                	mov    %ecx,%eax
  int partitionNumber;
  char *filePath;
  
  if(argc < 3){
  13:	83 38 02             	cmpl   $0x2,(%eax)
  16:	7f 17                	jg     2f <main+0x2f>
    printf(1, "usage: mount [directory] [partition number]\n");
  18:	83 ec 08             	sub    $0x8,%esp
  1b:	68 20 08 00 00       	push   $0x820
  20:	6a 01                	push   $0x1
  22:	e8 41 04 00 00       	call   468 <printf>
  27:	83 c4 10             	add    $0x10,%esp
    exit();
  2a:	e8 ba 02 00 00       	call   2e9 <exit>
  }
  filePath=argv[1];
  2f:	8b 50 04             	mov    0x4(%eax),%edx
  32:	8b 52 04             	mov    0x4(%edx),%edx
  35:	89 55 f4             	mov    %edx,-0xc(%ebp)
  partitionNumber=atoi(argv[2]);
  38:	8b 40 04             	mov    0x4(%eax),%eax
  3b:	83 c0 08             	add    $0x8,%eax
  3e:	8b 00                	mov    (%eax),%eax
  40:	83 ec 0c             	sub    $0xc,%esp
  43:	50                   	push   %eax
  44:	e8 0e 02 00 00       	call   257 <atoi>
  49:	83 c4 10             	add    $0x10,%esp
  4c:	89 45 f0             	mov    %eax,-0x10(%ebp)
 if(mount(filePath,partitionNumber)==0){
  4f:	83 ec 08             	sub    $0x8,%esp
  52:	ff 75 f0             	pushl  -0x10(%ebp)
  55:	ff 75 f4             	pushl  -0xc(%ebp)
  58:	e8 2c 03 00 00       	call   389 <mount>
  5d:	83 c4 10             	add    $0x10,%esp
  60:	85 c0                	test   %eax,%eax
  62:	75 17                	jne    7b <main+0x7b>
     printf(1,"partition %d was successfully mounted on %s \n",partitionNumber,filePath);
  64:	ff 75 f4             	pushl  -0xc(%ebp)
  67:	ff 75 f0             	pushl  -0x10(%ebp)
  6a:	68 50 08 00 00       	push   $0x850
  6f:	6a 01                	push   $0x1
  71:	e8 f2 03 00 00       	call   468 <printf>
  76:	83 c4 10             	add    $0x10,%esp
  79:	eb 12                	jmp    8d <main+0x8d>
 }
 else{
     printf(1,"mount failed \n");
  7b:	83 ec 08             	sub    $0x8,%esp
  7e:	68 7e 08 00 00       	push   $0x87e
  83:	6a 01                	push   $0x1
  85:	e8 de 03 00 00       	call   468 <printf>
  8a:	83 c4 10             	add    $0x10,%esp
 }
  exit();
  8d:	e8 57 02 00 00       	call   2e9 <exit>

00000092 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
  92:	55                   	push   %ebp
  93:	89 e5                	mov    %esp,%ebp
  95:	57                   	push   %edi
  96:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
  97:	8b 4d 08             	mov    0x8(%ebp),%ecx
  9a:	8b 55 10             	mov    0x10(%ebp),%edx
  9d:	8b 45 0c             	mov    0xc(%ebp),%eax
  a0:	89 cb                	mov    %ecx,%ebx
  a2:	89 df                	mov    %ebx,%edi
  a4:	89 d1                	mov    %edx,%ecx
  a6:	fc                   	cld    
  a7:	f3 aa                	rep stos %al,%es:(%edi)
  a9:	89 ca                	mov    %ecx,%edx
  ab:	89 fb                	mov    %edi,%ebx
  ad:	89 5d 08             	mov    %ebx,0x8(%ebp)
  b0:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
  b3:	90                   	nop
  b4:	5b                   	pop    %ebx
  b5:	5f                   	pop    %edi
  b6:	5d                   	pop    %ebp
  b7:	c3                   	ret    

000000b8 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
  b8:	55                   	push   %ebp
  b9:	89 e5                	mov    %esp,%ebp
  bb:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
  be:	8b 45 08             	mov    0x8(%ebp),%eax
  c1:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
  c4:	90                   	nop
  c5:	8b 45 08             	mov    0x8(%ebp),%eax
  c8:	8d 50 01             	lea    0x1(%eax),%edx
  cb:	89 55 08             	mov    %edx,0x8(%ebp)
  ce:	8b 55 0c             	mov    0xc(%ebp),%edx
  d1:	8d 4a 01             	lea    0x1(%edx),%ecx
  d4:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  d7:	0f b6 12             	movzbl (%edx),%edx
  da:	88 10                	mov    %dl,(%eax)
  dc:	0f b6 00             	movzbl (%eax),%eax
  df:	84 c0                	test   %al,%al
  e1:	75 e2                	jne    c5 <strcpy+0xd>
    ;
  return os;
  e3:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  e6:	c9                   	leave  
  e7:	c3                   	ret    

000000e8 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  e8:	55                   	push   %ebp
  e9:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
  eb:	eb 08                	jmp    f5 <strcmp+0xd>
    p++, q++;
  ed:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  f1:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
  f5:	8b 45 08             	mov    0x8(%ebp),%eax
  f8:	0f b6 00             	movzbl (%eax),%eax
  fb:	84 c0                	test   %al,%al
  fd:	74 10                	je     10f <strcmp+0x27>
  ff:	8b 45 08             	mov    0x8(%ebp),%eax
 102:	0f b6 10             	movzbl (%eax),%edx
 105:	8b 45 0c             	mov    0xc(%ebp),%eax
 108:	0f b6 00             	movzbl (%eax),%eax
 10b:	38 c2                	cmp    %al,%dl
 10d:	74 de                	je     ed <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 10f:	8b 45 08             	mov    0x8(%ebp),%eax
 112:	0f b6 00             	movzbl (%eax),%eax
 115:	0f b6 d0             	movzbl %al,%edx
 118:	8b 45 0c             	mov    0xc(%ebp),%eax
 11b:	0f b6 00             	movzbl (%eax),%eax
 11e:	0f b6 c0             	movzbl %al,%eax
 121:	29 c2                	sub    %eax,%edx
 123:	89 d0                	mov    %edx,%eax
}
 125:	5d                   	pop    %ebp
 126:	c3                   	ret    

00000127 <strlen>:

uint
strlen(char *s)
{
 127:	55                   	push   %ebp
 128:	89 e5                	mov    %esp,%ebp
 12a:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 12d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 134:	eb 04                	jmp    13a <strlen+0x13>
 136:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 13a:	8b 55 fc             	mov    -0x4(%ebp),%edx
 13d:	8b 45 08             	mov    0x8(%ebp),%eax
 140:	01 d0                	add    %edx,%eax
 142:	0f b6 00             	movzbl (%eax),%eax
 145:	84 c0                	test   %al,%al
 147:	75 ed                	jne    136 <strlen+0xf>
    ;
  return n;
 149:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 14c:	c9                   	leave  
 14d:	c3                   	ret    

0000014e <memset>:

void*
memset(void *dst, int c, uint n)
{
 14e:	55                   	push   %ebp
 14f:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 151:	8b 45 10             	mov    0x10(%ebp),%eax
 154:	50                   	push   %eax
 155:	ff 75 0c             	pushl  0xc(%ebp)
 158:	ff 75 08             	pushl  0x8(%ebp)
 15b:	e8 32 ff ff ff       	call   92 <stosb>
 160:	83 c4 0c             	add    $0xc,%esp
  return dst;
 163:	8b 45 08             	mov    0x8(%ebp),%eax
}
 166:	c9                   	leave  
 167:	c3                   	ret    

00000168 <strchr>:

char*
strchr(const char *s, char c)
{
 168:	55                   	push   %ebp
 169:	89 e5                	mov    %esp,%ebp
 16b:	83 ec 04             	sub    $0x4,%esp
 16e:	8b 45 0c             	mov    0xc(%ebp),%eax
 171:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 174:	eb 14                	jmp    18a <strchr+0x22>
    if(*s == c)
 176:	8b 45 08             	mov    0x8(%ebp),%eax
 179:	0f b6 00             	movzbl (%eax),%eax
 17c:	3a 45 fc             	cmp    -0x4(%ebp),%al
 17f:	75 05                	jne    186 <strchr+0x1e>
      return (char*)s;
 181:	8b 45 08             	mov    0x8(%ebp),%eax
 184:	eb 13                	jmp    199 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 186:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 18a:	8b 45 08             	mov    0x8(%ebp),%eax
 18d:	0f b6 00             	movzbl (%eax),%eax
 190:	84 c0                	test   %al,%al
 192:	75 e2                	jne    176 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 194:	b8 00 00 00 00       	mov    $0x0,%eax
}
 199:	c9                   	leave  
 19a:	c3                   	ret    

0000019b <gets>:

char*
gets(char *buf, int max)
{
 19b:	55                   	push   %ebp
 19c:	89 e5                	mov    %esp,%ebp
 19e:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1a1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 1a8:	eb 42                	jmp    1ec <gets+0x51>
    cc = read(0, &c, 1);
 1aa:	83 ec 04             	sub    $0x4,%esp
 1ad:	6a 01                	push   $0x1
 1af:	8d 45 ef             	lea    -0x11(%ebp),%eax
 1b2:	50                   	push   %eax
 1b3:	6a 00                	push   $0x0
 1b5:	e8 47 01 00 00       	call   301 <read>
 1ba:	83 c4 10             	add    $0x10,%esp
 1bd:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 1c0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 1c4:	7e 33                	jle    1f9 <gets+0x5e>
      break;
    buf[i++] = c;
 1c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1c9:	8d 50 01             	lea    0x1(%eax),%edx
 1cc:	89 55 f4             	mov    %edx,-0xc(%ebp)
 1cf:	89 c2                	mov    %eax,%edx
 1d1:	8b 45 08             	mov    0x8(%ebp),%eax
 1d4:	01 c2                	add    %eax,%edx
 1d6:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1da:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 1dc:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1e0:	3c 0a                	cmp    $0xa,%al
 1e2:	74 16                	je     1fa <gets+0x5f>
 1e4:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1e8:	3c 0d                	cmp    $0xd,%al
 1ea:	74 0e                	je     1fa <gets+0x5f>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1ef:	83 c0 01             	add    $0x1,%eax
 1f2:	3b 45 0c             	cmp    0xc(%ebp),%eax
 1f5:	7c b3                	jl     1aa <gets+0xf>
 1f7:	eb 01                	jmp    1fa <gets+0x5f>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
 1f9:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 1fa:	8b 55 f4             	mov    -0xc(%ebp),%edx
 1fd:	8b 45 08             	mov    0x8(%ebp),%eax
 200:	01 d0                	add    %edx,%eax
 202:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 205:	8b 45 08             	mov    0x8(%ebp),%eax
}
 208:	c9                   	leave  
 209:	c3                   	ret    

0000020a <stat>:

int
stat(char *n, struct stat *st)
{
 20a:	55                   	push   %ebp
 20b:	89 e5                	mov    %esp,%ebp
 20d:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 210:	83 ec 08             	sub    $0x8,%esp
 213:	6a 00                	push   $0x0
 215:	ff 75 08             	pushl  0x8(%ebp)
 218:	e8 0c 01 00 00       	call   329 <open>
 21d:	83 c4 10             	add    $0x10,%esp
 220:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 223:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 227:	79 07                	jns    230 <stat+0x26>
    return -1;
 229:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 22e:	eb 25                	jmp    255 <stat+0x4b>
  r = fstat(fd, st);
 230:	83 ec 08             	sub    $0x8,%esp
 233:	ff 75 0c             	pushl  0xc(%ebp)
 236:	ff 75 f4             	pushl  -0xc(%ebp)
 239:	e8 03 01 00 00       	call   341 <fstat>
 23e:	83 c4 10             	add    $0x10,%esp
 241:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 244:	83 ec 0c             	sub    $0xc,%esp
 247:	ff 75 f4             	pushl  -0xc(%ebp)
 24a:	e8 c2 00 00 00       	call   311 <close>
 24f:	83 c4 10             	add    $0x10,%esp
  return r;
 252:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 255:	c9                   	leave  
 256:	c3                   	ret    

00000257 <atoi>:

int
atoi(const char *s)
{
 257:	55                   	push   %ebp
 258:	89 e5                	mov    %esp,%ebp
 25a:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 25d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 264:	eb 25                	jmp    28b <atoi+0x34>
    n = n*10 + *s++ - '0';
 266:	8b 55 fc             	mov    -0x4(%ebp),%edx
 269:	89 d0                	mov    %edx,%eax
 26b:	c1 e0 02             	shl    $0x2,%eax
 26e:	01 d0                	add    %edx,%eax
 270:	01 c0                	add    %eax,%eax
 272:	89 c1                	mov    %eax,%ecx
 274:	8b 45 08             	mov    0x8(%ebp),%eax
 277:	8d 50 01             	lea    0x1(%eax),%edx
 27a:	89 55 08             	mov    %edx,0x8(%ebp)
 27d:	0f b6 00             	movzbl (%eax),%eax
 280:	0f be c0             	movsbl %al,%eax
 283:	01 c8                	add    %ecx,%eax
 285:	83 e8 30             	sub    $0x30,%eax
 288:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 28b:	8b 45 08             	mov    0x8(%ebp),%eax
 28e:	0f b6 00             	movzbl (%eax),%eax
 291:	3c 2f                	cmp    $0x2f,%al
 293:	7e 0a                	jle    29f <atoi+0x48>
 295:	8b 45 08             	mov    0x8(%ebp),%eax
 298:	0f b6 00             	movzbl (%eax),%eax
 29b:	3c 39                	cmp    $0x39,%al
 29d:	7e c7                	jle    266 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 29f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 2a2:	c9                   	leave  
 2a3:	c3                   	ret    

000002a4 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 2a4:	55                   	push   %ebp
 2a5:	89 e5                	mov    %esp,%ebp
 2a7:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 2aa:	8b 45 08             	mov    0x8(%ebp),%eax
 2ad:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 2b0:	8b 45 0c             	mov    0xc(%ebp),%eax
 2b3:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 2b6:	eb 17                	jmp    2cf <memmove+0x2b>
    *dst++ = *src++;
 2b8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 2bb:	8d 50 01             	lea    0x1(%eax),%edx
 2be:	89 55 fc             	mov    %edx,-0x4(%ebp)
 2c1:	8b 55 f8             	mov    -0x8(%ebp),%edx
 2c4:	8d 4a 01             	lea    0x1(%edx),%ecx
 2c7:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 2ca:	0f b6 12             	movzbl (%edx),%edx
 2cd:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 2cf:	8b 45 10             	mov    0x10(%ebp),%eax
 2d2:	8d 50 ff             	lea    -0x1(%eax),%edx
 2d5:	89 55 10             	mov    %edx,0x10(%ebp)
 2d8:	85 c0                	test   %eax,%eax
 2da:	7f dc                	jg     2b8 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 2dc:	8b 45 08             	mov    0x8(%ebp),%eax
}
 2df:	c9                   	leave  
 2e0:	c3                   	ret    

000002e1 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 2e1:	b8 01 00 00 00       	mov    $0x1,%eax
 2e6:	cd 40                	int    $0x40
 2e8:	c3                   	ret    

000002e9 <exit>:
SYSCALL(exit)
 2e9:	b8 02 00 00 00       	mov    $0x2,%eax
 2ee:	cd 40                	int    $0x40
 2f0:	c3                   	ret    

000002f1 <wait>:
SYSCALL(wait)
 2f1:	b8 03 00 00 00       	mov    $0x3,%eax
 2f6:	cd 40                	int    $0x40
 2f8:	c3                   	ret    

000002f9 <pipe>:
SYSCALL(pipe)
 2f9:	b8 04 00 00 00       	mov    $0x4,%eax
 2fe:	cd 40                	int    $0x40
 300:	c3                   	ret    

00000301 <read>:
SYSCALL(read)
 301:	b8 05 00 00 00       	mov    $0x5,%eax
 306:	cd 40                	int    $0x40
 308:	c3                   	ret    

00000309 <write>:
SYSCALL(write)
 309:	b8 10 00 00 00       	mov    $0x10,%eax
 30e:	cd 40                	int    $0x40
 310:	c3                   	ret    

00000311 <close>:
SYSCALL(close)
 311:	b8 15 00 00 00       	mov    $0x15,%eax
 316:	cd 40                	int    $0x40
 318:	c3                   	ret    

00000319 <kill>:
SYSCALL(kill)
 319:	b8 06 00 00 00       	mov    $0x6,%eax
 31e:	cd 40                	int    $0x40
 320:	c3                   	ret    

00000321 <exec>:
SYSCALL(exec)
 321:	b8 07 00 00 00       	mov    $0x7,%eax
 326:	cd 40                	int    $0x40
 328:	c3                   	ret    

00000329 <open>:
SYSCALL(open)
 329:	b8 0f 00 00 00       	mov    $0xf,%eax
 32e:	cd 40                	int    $0x40
 330:	c3                   	ret    

00000331 <mknod>:
SYSCALL(mknod)
 331:	b8 11 00 00 00       	mov    $0x11,%eax
 336:	cd 40                	int    $0x40
 338:	c3                   	ret    

00000339 <unlink>:
SYSCALL(unlink)
 339:	b8 12 00 00 00       	mov    $0x12,%eax
 33e:	cd 40                	int    $0x40
 340:	c3                   	ret    

00000341 <fstat>:
SYSCALL(fstat)
 341:	b8 08 00 00 00       	mov    $0x8,%eax
 346:	cd 40                	int    $0x40
 348:	c3                   	ret    

00000349 <link>:
SYSCALL(link)
 349:	b8 13 00 00 00       	mov    $0x13,%eax
 34e:	cd 40                	int    $0x40
 350:	c3                   	ret    

00000351 <mkdir>:
SYSCALL(mkdir)
 351:	b8 14 00 00 00       	mov    $0x14,%eax
 356:	cd 40                	int    $0x40
 358:	c3                   	ret    

00000359 <chdir>:
SYSCALL(chdir)
 359:	b8 09 00 00 00       	mov    $0x9,%eax
 35e:	cd 40                	int    $0x40
 360:	c3                   	ret    

00000361 <dup>:
SYSCALL(dup)
 361:	b8 0a 00 00 00       	mov    $0xa,%eax
 366:	cd 40                	int    $0x40
 368:	c3                   	ret    

00000369 <getpid>:
SYSCALL(getpid)
 369:	b8 0b 00 00 00       	mov    $0xb,%eax
 36e:	cd 40                	int    $0x40
 370:	c3                   	ret    

00000371 <sbrk>:
SYSCALL(sbrk)
 371:	b8 0c 00 00 00       	mov    $0xc,%eax
 376:	cd 40                	int    $0x40
 378:	c3                   	ret    

00000379 <sleep>:
SYSCALL(sleep)
 379:	b8 0d 00 00 00       	mov    $0xd,%eax
 37e:	cd 40                	int    $0x40
 380:	c3                   	ret    

00000381 <uptime>:
SYSCALL(uptime)
 381:	b8 0e 00 00 00       	mov    $0xe,%eax
 386:	cd 40                	int    $0x40
 388:	c3                   	ret    

00000389 <mount>:
SYSCALL(mount)
 389:	b8 16 00 00 00       	mov    $0x16,%eax
 38e:	cd 40                	int    $0x40
 390:	c3                   	ret    

00000391 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 391:	55                   	push   %ebp
 392:	89 e5                	mov    %esp,%ebp
 394:	83 ec 18             	sub    $0x18,%esp
 397:	8b 45 0c             	mov    0xc(%ebp),%eax
 39a:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 39d:	83 ec 04             	sub    $0x4,%esp
 3a0:	6a 01                	push   $0x1
 3a2:	8d 45 f4             	lea    -0xc(%ebp),%eax
 3a5:	50                   	push   %eax
 3a6:	ff 75 08             	pushl  0x8(%ebp)
 3a9:	e8 5b ff ff ff       	call   309 <write>
 3ae:	83 c4 10             	add    $0x10,%esp
}
 3b1:	90                   	nop
 3b2:	c9                   	leave  
 3b3:	c3                   	ret    

000003b4 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 3b4:	55                   	push   %ebp
 3b5:	89 e5                	mov    %esp,%ebp
 3b7:	53                   	push   %ebx
 3b8:	83 ec 24             	sub    $0x24,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 3bb:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 3c2:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 3c6:	74 17                	je     3df <printint+0x2b>
 3c8:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 3cc:	79 11                	jns    3df <printint+0x2b>
    neg = 1;
 3ce:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 3d5:	8b 45 0c             	mov    0xc(%ebp),%eax
 3d8:	f7 d8                	neg    %eax
 3da:	89 45 ec             	mov    %eax,-0x14(%ebp)
 3dd:	eb 06                	jmp    3e5 <printint+0x31>
  } else {
    x = xx;
 3df:	8b 45 0c             	mov    0xc(%ebp),%eax
 3e2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 3e5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 3ec:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 3ef:	8d 41 01             	lea    0x1(%ecx),%eax
 3f2:	89 45 f4             	mov    %eax,-0xc(%ebp)
 3f5:	8b 5d 10             	mov    0x10(%ebp),%ebx
 3f8:	8b 45 ec             	mov    -0x14(%ebp),%eax
 3fb:	ba 00 00 00 00       	mov    $0x0,%edx
 400:	f7 f3                	div    %ebx
 402:	89 d0                	mov    %edx,%eax
 404:	0f b6 80 dc 0a 00 00 	movzbl 0xadc(%eax),%eax
 40b:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 40f:	8b 5d 10             	mov    0x10(%ebp),%ebx
 412:	8b 45 ec             	mov    -0x14(%ebp),%eax
 415:	ba 00 00 00 00       	mov    $0x0,%edx
 41a:	f7 f3                	div    %ebx
 41c:	89 45 ec             	mov    %eax,-0x14(%ebp)
 41f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 423:	75 c7                	jne    3ec <printint+0x38>
  if(neg)
 425:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 429:	74 2d                	je     458 <printint+0xa4>
    buf[i++] = '-';
 42b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 42e:	8d 50 01             	lea    0x1(%eax),%edx
 431:	89 55 f4             	mov    %edx,-0xc(%ebp)
 434:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 439:	eb 1d                	jmp    458 <printint+0xa4>
    putc(fd, buf[i]);
 43b:	8d 55 dc             	lea    -0x24(%ebp),%edx
 43e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 441:	01 d0                	add    %edx,%eax
 443:	0f b6 00             	movzbl (%eax),%eax
 446:	0f be c0             	movsbl %al,%eax
 449:	83 ec 08             	sub    $0x8,%esp
 44c:	50                   	push   %eax
 44d:	ff 75 08             	pushl  0x8(%ebp)
 450:	e8 3c ff ff ff       	call   391 <putc>
 455:	83 c4 10             	add    $0x10,%esp
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 458:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 45c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 460:	79 d9                	jns    43b <printint+0x87>
    putc(fd, buf[i]);
}
 462:	90                   	nop
 463:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 466:	c9                   	leave  
 467:	c3                   	ret    

00000468 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 468:	55                   	push   %ebp
 469:	89 e5                	mov    %esp,%ebp
 46b:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 46e:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 475:	8d 45 0c             	lea    0xc(%ebp),%eax
 478:	83 c0 04             	add    $0x4,%eax
 47b:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 47e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 485:	e9 59 01 00 00       	jmp    5e3 <printf+0x17b>
    c = fmt[i] & 0xff;
 48a:	8b 55 0c             	mov    0xc(%ebp),%edx
 48d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 490:	01 d0                	add    %edx,%eax
 492:	0f b6 00             	movzbl (%eax),%eax
 495:	0f be c0             	movsbl %al,%eax
 498:	25 ff 00 00 00       	and    $0xff,%eax
 49d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 4a0:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 4a4:	75 2c                	jne    4d2 <printf+0x6a>
      if(c == '%'){
 4a6:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 4aa:	75 0c                	jne    4b8 <printf+0x50>
        state = '%';
 4ac:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 4b3:	e9 27 01 00 00       	jmp    5df <printf+0x177>
      } else {
        putc(fd, c);
 4b8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 4bb:	0f be c0             	movsbl %al,%eax
 4be:	83 ec 08             	sub    $0x8,%esp
 4c1:	50                   	push   %eax
 4c2:	ff 75 08             	pushl  0x8(%ebp)
 4c5:	e8 c7 fe ff ff       	call   391 <putc>
 4ca:	83 c4 10             	add    $0x10,%esp
 4cd:	e9 0d 01 00 00       	jmp    5df <printf+0x177>
      }
    } else if(state == '%'){
 4d2:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 4d6:	0f 85 03 01 00 00    	jne    5df <printf+0x177>
      if(c == 'd'){
 4dc:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 4e0:	75 1e                	jne    500 <printf+0x98>
        printint(fd, *ap, 10, 1);
 4e2:	8b 45 e8             	mov    -0x18(%ebp),%eax
 4e5:	8b 00                	mov    (%eax),%eax
 4e7:	6a 01                	push   $0x1
 4e9:	6a 0a                	push   $0xa
 4eb:	50                   	push   %eax
 4ec:	ff 75 08             	pushl  0x8(%ebp)
 4ef:	e8 c0 fe ff ff       	call   3b4 <printint>
 4f4:	83 c4 10             	add    $0x10,%esp
        ap++;
 4f7:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 4fb:	e9 d8 00 00 00       	jmp    5d8 <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 500:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 504:	74 06                	je     50c <printf+0xa4>
 506:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 50a:	75 1e                	jne    52a <printf+0xc2>
        printint(fd, *ap, 16, 0);
 50c:	8b 45 e8             	mov    -0x18(%ebp),%eax
 50f:	8b 00                	mov    (%eax),%eax
 511:	6a 00                	push   $0x0
 513:	6a 10                	push   $0x10
 515:	50                   	push   %eax
 516:	ff 75 08             	pushl  0x8(%ebp)
 519:	e8 96 fe ff ff       	call   3b4 <printint>
 51e:	83 c4 10             	add    $0x10,%esp
        ap++;
 521:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 525:	e9 ae 00 00 00       	jmp    5d8 <printf+0x170>
      } else if(c == 's'){
 52a:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 52e:	75 43                	jne    573 <printf+0x10b>
        s = (char*)*ap;
 530:	8b 45 e8             	mov    -0x18(%ebp),%eax
 533:	8b 00                	mov    (%eax),%eax
 535:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 538:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 53c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 540:	75 25                	jne    567 <printf+0xff>
          s = "(null)";
 542:	c7 45 f4 8d 08 00 00 	movl   $0x88d,-0xc(%ebp)
        while(*s != 0){
 549:	eb 1c                	jmp    567 <printf+0xff>
          putc(fd, *s);
 54b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 54e:	0f b6 00             	movzbl (%eax),%eax
 551:	0f be c0             	movsbl %al,%eax
 554:	83 ec 08             	sub    $0x8,%esp
 557:	50                   	push   %eax
 558:	ff 75 08             	pushl  0x8(%ebp)
 55b:	e8 31 fe ff ff       	call   391 <putc>
 560:	83 c4 10             	add    $0x10,%esp
          s++;
 563:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 567:	8b 45 f4             	mov    -0xc(%ebp),%eax
 56a:	0f b6 00             	movzbl (%eax),%eax
 56d:	84 c0                	test   %al,%al
 56f:	75 da                	jne    54b <printf+0xe3>
 571:	eb 65                	jmp    5d8 <printf+0x170>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 573:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 577:	75 1d                	jne    596 <printf+0x12e>
        putc(fd, *ap);
 579:	8b 45 e8             	mov    -0x18(%ebp),%eax
 57c:	8b 00                	mov    (%eax),%eax
 57e:	0f be c0             	movsbl %al,%eax
 581:	83 ec 08             	sub    $0x8,%esp
 584:	50                   	push   %eax
 585:	ff 75 08             	pushl  0x8(%ebp)
 588:	e8 04 fe ff ff       	call   391 <putc>
 58d:	83 c4 10             	add    $0x10,%esp
        ap++;
 590:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 594:	eb 42                	jmp    5d8 <printf+0x170>
      } else if(c == '%'){
 596:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 59a:	75 17                	jne    5b3 <printf+0x14b>
        putc(fd, c);
 59c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 59f:	0f be c0             	movsbl %al,%eax
 5a2:	83 ec 08             	sub    $0x8,%esp
 5a5:	50                   	push   %eax
 5a6:	ff 75 08             	pushl  0x8(%ebp)
 5a9:	e8 e3 fd ff ff       	call   391 <putc>
 5ae:	83 c4 10             	add    $0x10,%esp
 5b1:	eb 25                	jmp    5d8 <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 5b3:	83 ec 08             	sub    $0x8,%esp
 5b6:	6a 25                	push   $0x25
 5b8:	ff 75 08             	pushl  0x8(%ebp)
 5bb:	e8 d1 fd ff ff       	call   391 <putc>
 5c0:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 5c3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 5c6:	0f be c0             	movsbl %al,%eax
 5c9:	83 ec 08             	sub    $0x8,%esp
 5cc:	50                   	push   %eax
 5cd:	ff 75 08             	pushl  0x8(%ebp)
 5d0:	e8 bc fd ff ff       	call   391 <putc>
 5d5:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 5d8:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 5df:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 5e3:	8b 55 0c             	mov    0xc(%ebp),%edx
 5e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
 5e9:	01 d0                	add    %edx,%eax
 5eb:	0f b6 00             	movzbl (%eax),%eax
 5ee:	84 c0                	test   %al,%al
 5f0:	0f 85 94 fe ff ff    	jne    48a <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 5f6:	90                   	nop
 5f7:	c9                   	leave  
 5f8:	c3                   	ret    

000005f9 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 5f9:	55                   	push   %ebp
 5fa:	89 e5                	mov    %esp,%ebp
 5fc:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 5ff:	8b 45 08             	mov    0x8(%ebp),%eax
 602:	83 e8 08             	sub    $0x8,%eax
 605:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 608:	a1 f8 0a 00 00       	mov    0xaf8,%eax
 60d:	89 45 fc             	mov    %eax,-0x4(%ebp)
 610:	eb 24                	jmp    636 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 612:	8b 45 fc             	mov    -0x4(%ebp),%eax
 615:	8b 00                	mov    (%eax),%eax
 617:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 61a:	77 12                	ja     62e <free+0x35>
 61c:	8b 45 f8             	mov    -0x8(%ebp),%eax
 61f:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 622:	77 24                	ja     648 <free+0x4f>
 624:	8b 45 fc             	mov    -0x4(%ebp),%eax
 627:	8b 00                	mov    (%eax),%eax
 629:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 62c:	77 1a                	ja     648 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 62e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 631:	8b 00                	mov    (%eax),%eax
 633:	89 45 fc             	mov    %eax,-0x4(%ebp)
 636:	8b 45 f8             	mov    -0x8(%ebp),%eax
 639:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 63c:	76 d4                	jbe    612 <free+0x19>
 63e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 641:	8b 00                	mov    (%eax),%eax
 643:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 646:	76 ca                	jbe    612 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 648:	8b 45 f8             	mov    -0x8(%ebp),%eax
 64b:	8b 40 04             	mov    0x4(%eax),%eax
 64e:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 655:	8b 45 f8             	mov    -0x8(%ebp),%eax
 658:	01 c2                	add    %eax,%edx
 65a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 65d:	8b 00                	mov    (%eax),%eax
 65f:	39 c2                	cmp    %eax,%edx
 661:	75 24                	jne    687 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 663:	8b 45 f8             	mov    -0x8(%ebp),%eax
 666:	8b 50 04             	mov    0x4(%eax),%edx
 669:	8b 45 fc             	mov    -0x4(%ebp),%eax
 66c:	8b 00                	mov    (%eax),%eax
 66e:	8b 40 04             	mov    0x4(%eax),%eax
 671:	01 c2                	add    %eax,%edx
 673:	8b 45 f8             	mov    -0x8(%ebp),%eax
 676:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 679:	8b 45 fc             	mov    -0x4(%ebp),%eax
 67c:	8b 00                	mov    (%eax),%eax
 67e:	8b 10                	mov    (%eax),%edx
 680:	8b 45 f8             	mov    -0x8(%ebp),%eax
 683:	89 10                	mov    %edx,(%eax)
 685:	eb 0a                	jmp    691 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 687:	8b 45 fc             	mov    -0x4(%ebp),%eax
 68a:	8b 10                	mov    (%eax),%edx
 68c:	8b 45 f8             	mov    -0x8(%ebp),%eax
 68f:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 691:	8b 45 fc             	mov    -0x4(%ebp),%eax
 694:	8b 40 04             	mov    0x4(%eax),%eax
 697:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 69e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6a1:	01 d0                	add    %edx,%eax
 6a3:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 6a6:	75 20                	jne    6c8 <free+0xcf>
    p->s.size += bp->s.size;
 6a8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6ab:	8b 50 04             	mov    0x4(%eax),%edx
 6ae:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6b1:	8b 40 04             	mov    0x4(%eax),%eax
 6b4:	01 c2                	add    %eax,%edx
 6b6:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6b9:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 6bc:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6bf:	8b 10                	mov    (%eax),%edx
 6c1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6c4:	89 10                	mov    %edx,(%eax)
 6c6:	eb 08                	jmp    6d0 <free+0xd7>
  } else
    p->s.ptr = bp;
 6c8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6cb:	8b 55 f8             	mov    -0x8(%ebp),%edx
 6ce:	89 10                	mov    %edx,(%eax)
  freep = p;
 6d0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6d3:	a3 f8 0a 00 00       	mov    %eax,0xaf8
}
 6d8:	90                   	nop
 6d9:	c9                   	leave  
 6da:	c3                   	ret    

000006db <morecore>:

static Header*
morecore(uint nu)
{
 6db:	55                   	push   %ebp
 6dc:	89 e5                	mov    %esp,%ebp
 6de:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 6e1:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 6e8:	77 07                	ja     6f1 <morecore+0x16>
    nu = 4096;
 6ea:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 6f1:	8b 45 08             	mov    0x8(%ebp),%eax
 6f4:	c1 e0 03             	shl    $0x3,%eax
 6f7:	83 ec 0c             	sub    $0xc,%esp
 6fa:	50                   	push   %eax
 6fb:	e8 71 fc ff ff       	call   371 <sbrk>
 700:	83 c4 10             	add    $0x10,%esp
 703:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 706:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 70a:	75 07                	jne    713 <morecore+0x38>
    return 0;
 70c:	b8 00 00 00 00       	mov    $0x0,%eax
 711:	eb 26                	jmp    739 <morecore+0x5e>
  hp = (Header*)p;
 713:	8b 45 f4             	mov    -0xc(%ebp),%eax
 716:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 719:	8b 45 f0             	mov    -0x10(%ebp),%eax
 71c:	8b 55 08             	mov    0x8(%ebp),%edx
 71f:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 722:	8b 45 f0             	mov    -0x10(%ebp),%eax
 725:	83 c0 08             	add    $0x8,%eax
 728:	83 ec 0c             	sub    $0xc,%esp
 72b:	50                   	push   %eax
 72c:	e8 c8 fe ff ff       	call   5f9 <free>
 731:	83 c4 10             	add    $0x10,%esp
  return freep;
 734:	a1 f8 0a 00 00       	mov    0xaf8,%eax
}
 739:	c9                   	leave  
 73a:	c3                   	ret    

0000073b <malloc>:

void*
malloc(uint nbytes)
{
 73b:	55                   	push   %ebp
 73c:	89 e5                	mov    %esp,%ebp
 73e:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 741:	8b 45 08             	mov    0x8(%ebp),%eax
 744:	83 c0 07             	add    $0x7,%eax
 747:	c1 e8 03             	shr    $0x3,%eax
 74a:	83 c0 01             	add    $0x1,%eax
 74d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 750:	a1 f8 0a 00 00       	mov    0xaf8,%eax
 755:	89 45 f0             	mov    %eax,-0x10(%ebp)
 758:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 75c:	75 23                	jne    781 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 75e:	c7 45 f0 f0 0a 00 00 	movl   $0xaf0,-0x10(%ebp)
 765:	8b 45 f0             	mov    -0x10(%ebp),%eax
 768:	a3 f8 0a 00 00       	mov    %eax,0xaf8
 76d:	a1 f8 0a 00 00       	mov    0xaf8,%eax
 772:	a3 f0 0a 00 00       	mov    %eax,0xaf0
    base.s.size = 0;
 777:	c7 05 f4 0a 00 00 00 	movl   $0x0,0xaf4
 77e:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 781:	8b 45 f0             	mov    -0x10(%ebp),%eax
 784:	8b 00                	mov    (%eax),%eax
 786:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 789:	8b 45 f4             	mov    -0xc(%ebp),%eax
 78c:	8b 40 04             	mov    0x4(%eax),%eax
 78f:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 792:	72 4d                	jb     7e1 <malloc+0xa6>
      if(p->s.size == nunits)
 794:	8b 45 f4             	mov    -0xc(%ebp),%eax
 797:	8b 40 04             	mov    0x4(%eax),%eax
 79a:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 79d:	75 0c                	jne    7ab <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 79f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7a2:	8b 10                	mov    (%eax),%edx
 7a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7a7:	89 10                	mov    %edx,(%eax)
 7a9:	eb 26                	jmp    7d1 <malloc+0x96>
      else {
        p->s.size -= nunits;
 7ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7ae:	8b 40 04             	mov    0x4(%eax),%eax
 7b1:	2b 45 ec             	sub    -0x14(%ebp),%eax
 7b4:	89 c2                	mov    %eax,%edx
 7b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7b9:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 7bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7bf:	8b 40 04             	mov    0x4(%eax),%eax
 7c2:	c1 e0 03             	shl    $0x3,%eax
 7c5:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 7c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7cb:	8b 55 ec             	mov    -0x14(%ebp),%edx
 7ce:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 7d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7d4:	a3 f8 0a 00 00       	mov    %eax,0xaf8
      return (void*)(p + 1);
 7d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7dc:	83 c0 08             	add    $0x8,%eax
 7df:	eb 3b                	jmp    81c <malloc+0xe1>
    }
    if(p == freep)
 7e1:	a1 f8 0a 00 00       	mov    0xaf8,%eax
 7e6:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 7e9:	75 1e                	jne    809 <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 7eb:	83 ec 0c             	sub    $0xc,%esp
 7ee:	ff 75 ec             	pushl  -0x14(%ebp)
 7f1:	e8 e5 fe ff ff       	call   6db <morecore>
 7f6:	83 c4 10             	add    $0x10,%esp
 7f9:	89 45 f4             	mov    %eax,-0xc(%ebp)
 7fc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 800:	75 07                	jne    809 <malloc+0xce>
        return 0;
 802:	b8 00 00 00 00       	mov    $0x0,%eax
 807:	eb 13                	jmp    81c <malloc+0xe1>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 809:	8b 45 f4             	mov    -0xc(%ebp),%eax
 80c:	89 45 f0             	mov    %eax,-0x10(%ebp)
 80f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 812:	8b 00                	mov    (%eax),%eax
 814:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 817:	e9 6d ff ff ff       	jmp    789 <malloc+0x4e>
}
 81c:	c9                   	leave  
 81d:	c3                   	ret    
