
_mount:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "user.h"


int
main(int argc, char *argv[])
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 e4 f0             	and    $0xfffffff0,%esp
   6:	83 ec 20             	sub    $0x20,%esp
  int partitionNumber;
  char *filePath;
  
  if(argc < 3){
   9:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
   d:	7f 19                	jg     28 <main+0x28>
    printf(1, "usage: mount [directory] [partition number]\n");
   f:	c7 44 24 04 5c 08 00 	movl   $0x85c,0x4(%esp)
  16:	00 
  17:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1e:	e8 6a 04 00 00       	call   48d <printf>
    exit();
  23:	e8 dd 02 00 00       	call   305 <exit>
  }
  filePath=argv[1];
  28:	8b 45 0c             	mov    0xc(%ebp),%eax
  2b:	8b 40 04             	mov    0x4(%eax),%eax
  2e:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  partitionNumber=atoi(argv[2]);
  32:	8b 45 0c             	mov    0xc(%ebp),%eax
  35:	83 c0 08             	add    $0x8,%eax
  38:	8b 00                	mov    (%eax),%eax
  3a:	89 04 24             	mov    %eax,(%esp)
  3d:	e8 31 02 00 00       	call   273 <atoi>
  42:	89 44 24 18          	mov    %eax,0x18(%esp)
 if(mount(filePath,partitionNumber)==0){
  46:	8b 44 24 18          	mov    0x18(%esp),%eax
  4a:	89 44 24 04          	mov    %eax,0x4(%esp)
  4e:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  52:	89 04 24             	mov    %eax,(%esp)
  55:	e8 4b 03 00 00       	call   3a5 <mount>
  5a:	85 c0                	test   %eax,%eax
  5c:	75 26                	jne    84 <main+0x84>
     printf(1,"partition %d was successfully mounted on %s \n",partitionNumber,filePath);
  5e:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  62:	89 44 24 0c          	mov    %eax,0xc(%esp)
  66:	8b 44 24 18          	mov    0x18(%esp),%eax
  6a:	89 44 24 08          	mov    %eax,0x8(%esp)
  6e:	c7 44 24 04 8c 08 00 	movl   $0x88c,0x4(%esp)
  75:	00 
  76:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  7d:	e8 0b 04 00 00       	call   48d <printf>
  82:	eb 14                	jmp    98 <main+0x98>
 }
 else{
     printf(1,"mount failed \n");
  84:	c7 44 24 04 ba 08 00 	movl   $0x8ba,0x4(%esp)
  8b:	00 
  8c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  93:	e8 f5 03 00 00       	call   48d <printf>
 }
  exit();
  98:	e8 68 02 00 00       	call   305 <exit>

0000009d <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
  9d:	55                   	push   %ebp
  9e:	89 e5                	mov    %esp,%ebp
  a0:	57                   	push   %edi
  a1:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
  a2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  a5:	8b 55 10             	mov    0x10(%ebp),%edx
  a8:	8b 45 0c             	mov    0xc(%ebp),%eax
  ab:	89 cb                	mov    %ecx,%ebx
  ad:	89 df                	mov    %ebx,%edi
  af:	89 d1                	mov    %edx,%ecx
  b1:	fc                   	cld    
  b2:	f3 aa                	rep stos %al,%es:(%edi)
  b4:	89 ca                	mov    %ecx,%edx
  b6:	89 fb                	mov    %edi,%ebx
  b8:	89 5d 08             	mov    %ebx,0x8(%ebp)
  bb:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
  be:	5b                   	pop    %ebx
  bf:	5f                   	pop    %edi
  c0:	5d                   	pop    %ebp
  c1:	c3                   	ret    

000000c2 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
  c2:	55                   	push   %ebp
  c3:	89 e5                	mov    %esp,%ebp
  c5:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
  c8:	8b 45 08             	mov    0x8(%ebp),%eax
  cb:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
  ce:	90                   	nop
  cf:	8b 45 08             	mov    0x8(%ebp),%eax
  d2:	8d 50 01             	lea    0x1(%eax),%edx
  d5:	89 55 08             	mov    %edx,0x8(%ebp)
  d8:	8b 55 0c             	mov    0xc(%ebp),%edx
  db:	8d 4a 01             	lea    0x1(%edx),%ecx
  de:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  e1:	0f b6 12             	movzbl (%edx),%edx
  e4:	88 10                	mov    %dl,(%eax)
  e6:	0f b6 00             	movzbl (%eax),%eax
  e9:	84 c0                	test   %al,%al
  eb:	75 e2                	jne    cf <strcpy+0xd>
    ;
  return os;
  ed:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  f0:	c9                   	leave  
  f1:	c3                   	ret    

000000f2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  f2:	55                   	push   %ebp
  f3:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
  f5:	eb 08                	jmp    ff <strcmp+0xd>
    p++, q++;
  f7:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  fb:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
  ff:	8b 45 08             	mov    0x8(%ebp),%eax
 102:	0f b6 00             	movzbl (%eax),%eax
 105:	84 c0                	test   %al,%al
 107:	74 10                	je     119 <strcmp+0x27>
 109:	8b 45 08             	mov    0x8(%ebp),%eax
 10c:	0f b6 10             	movzbl (%eax),%edx
 10f:	8b 45 0c             	mov    0xc(%ebp),%eax
 112:	0f b6 00             	movzbl (%eax),%eax
 115:	38 c2                	cmp    %al,%dl
 117:	74 de                	je     f7 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 119:	8b 45 08             	mov    0x8(%ebp),%eax
 11c:	0f b6 00             	movzbl (%eax),%eax
 11f:	0f b6 d0             	movzbl %al,%edx
 122:	8b 45 0c             	mov    0xc(%ebp),%eax
 125:	0f b6 00             	movzbl (%eax),%eax
 128:	0f b6 c0             	movzbl %al,%eax
 12b:	29 c2                	sub    %eax,%edx
 12d:	89 d0                	mov    %edx,%eax
}
 12f:	5d                   	pop    %ebp
 130:	c3                   	ret    

00000131 <strlen>:

uint
strlen(char *s)
{
 131:	55                   	push   %ebp
 132:	89 e5                	mov    %esp,%ebp
 134:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 137:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 13e:	eb 04                	jmp    144 <strlen+0x13>
 140:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 144:	8b 55 fc             	mov    -0x4(%ebp),%edx
 147:	8b 45 08             	mov    0x8(%ebp),%eax
 14a:	01 d0                	add    %edx,%eax
 14c:	0f b6 00             	movzbl (%eax),%eax
 14f:	84 c0                	test   %al,%al
 151:	75 ed                	jne    140 <strlen+0xf>
    ;
  return n;
 153:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 156:	c9                   	leave  
 157:	c3                   	ret    

00000158 <memset>:

void*
memset(void *dst, int c, uint n)
{
 158:	55                   	push   %ebp
 159:	89 e5                	mov    %esp,%ebp
 15b:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 15e:	8b 45 10             	mov    0x10(%ebp),%eax
 161:	89 44 24 08          	mov    %eax,0x8(%esp)
 165:	8b 45 0c             	mov    0xc(%ebp),%eax
 168:	89 44 24 04          	mov    %eax,0x4(%esp)
 16c:	8b 45 08             	mov    0x8(%ebp),%eax
 16f:	89 04 24             	mov    %eax,(%esp)
 172:	e8 26 ff ff ff       	call   9d <stosb>
  return dst;
 177:	8b 45 08             	mov    0x8(%ebp),%eax
}
 17a:	c9                   	leave  
 17b:	c3                   	ret    

0000017c <strchr>:

char*
strchr(const char *s, char c)
{
 17c:	55                   	push   %ebp
 17d:	89 e5                	mov    %esp,%ebp
 17f:	83 ec 04             	sub    $0x4,%esp
 182:	8b 45 0c             	mov    0xc(%ebp),%eax
 185:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 188:	eb 14                	jmp    19e <strchr+0x22>
    if(*s == c)
 18a:	8b 45 08             	mov    0x8(%ebp),%eax
 18d:	0f b6 00             	movzbl (%eax),%eax
 190:	3a 45 fc             	cmp    -0x4(%ebp),%al
 193:	75 05                	jne    19a <strchr+0x1e>
      return (char*)s;
 195:	8b 45 08             	mov    0x8(%ebp),%eax
 198:	eb 13                	jmp    1ad <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 19a:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 19e:	8b 45 08             	mov    0x8(%ebp),%eax
 1a1:	0f b6 00             	movzbl (%eax),%eax
 1a4:	84 c0                	test   %al,%al
 1a6:	75 e2                	jne    18a <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 1a8:	b8 00 00 00 00       	mov    $0x0,%eax
}
 1ad:	c9                   	leave  
 1ae:	c3                   	ret    

000001af <gets>:

char*
gets(char *buf, int max)
{
 1af:	55                   	push   %ebp
 1b0:	89 e5                	mov    %esp,%ebp
 1b2:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1b5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 1bc:	eb 4c                	jmp    20a <gets+0x5b>
    cc = read(0, &c, 1);
 1be:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 1c5:	00 
 1c6:	8d 45 ef             	lea    -0x11(%ebp),%eax
 1c9:	89 44 24 04          	mov    %eax,0x4(%esp)
 1cd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 1d4:	e8 44 01 00 00       	call   31d <read>
 1d9:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 1dc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 1e0:	7f 02                	jg     1e4 <gets+0x35>
      break;
 1e2:	eb 31                	jmp    215 <gets+0x66>
    buf[i++] = c;
 1e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1e7:	8d 50 01             	lea    0x1(%eax),%edx
 1ea:	89 55 f4             	mov    %edx,-0xc(%ebp)
 1ed:	89 c2                	mov    %eax,%edx
 1ef:	8b 45 08             	mov    0x8(%ebp),%eax
 1f2:	01 c2                	add    %eax,%edx
 1f4:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1f8:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 1fa:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1fe:	3c 0a                	cmp    $0xa,%al
 200:	74 13                	je     215 <gets+0x66>
 202:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 206:	3c 0d                	cmp    $0xd,%al
 208:	74 0b                	je     215 <gets+0x66>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 20a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 20d:	83 c0 01             	add    $0x1,%eax
 210:	3b 45 0c             	cmp    0xc(%ebp),%eax
 213:	7c a9                	jl     1be <gets+0xf>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 215:	8b 55 f4             	mov    -0xc(%ebp),%edx
 218:	8b 45 08             	mov    0x8(%ebp),%eax
 21b:	01 d0                	add    %edx,%eax
 21d:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 220:	8b 45 08             	mov    0x8(%ebp),%eax
}
 223:	c9                   	leave  
 224:	c3                   	ret    

00000225 <stat>:

int
stat(char *n, struct stat *st)
{
 225:	55                   	push   %ebp
 226:	89 e5                	mov    %esp,%ebp
 228:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 22b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 232:	00 
 233:	8b 45 08             	mov    0x8(%ebp),%eax
 236:	89 04 24             	mov    %eax,(%esp)
 239:	e8 07 01 00 00       	call   345 <open>
 23e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 241:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 245:	79 07                	jns    24e <stat+0x29>
    return -1;
 247:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 24c:	eb 23                	jmp    271 <stat+0x4c>
  r = fstat(fd, st);
 24e:	8b 45 0c             	mov    0xc(%ebp),%eax
 251:	89 44 24 04          	mov    %eax,0x4(%esp)
 255:	8b 45 f4             	mov    -0xc(%ebp),%eax
 258:	89 04 24             	mov    %eax,(%esp)
 25b:	e8 fd 00 00 00       	call   35d <fstat>
 260:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 263:	8b 45 f4             	mov    -0xc(%ebp),%eax
 266:	89 04 24             	mov    %eax,(%esp)
 269:	e8 bf 00 00 00       	call   32d <close>
  return r;
 26e:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 271:	c9                   	leave  
 272:	c3                   	ret    

00000273 <atoi>:

int
atoi(const char *s)
{
 273:	55                   	push   %ebp
 274:	89 e5                	mov    %esp,%ebp
 276:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 279:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 280:	eb 25                	jmp    2a7 <atoi+0x34>
    n = n*10 + *s++ - '0';
 282:	8b 55 fc             	mov    -0x4(%ebp),%edx
 285:	89 d0                	mov    %edx,%eax
 287:	c1 e0 02             	shl    $0x2,%eax
 28a:	01 d0                	add    %edx,%eax
 28c:	01 c0                	add    %eax,%eax
 28e:	89 c1                	mov    %eax,%ecx
 290:	8b 45 08             	mov    0x8(%ebp),%eax
 293:	8d 50 01             	lea    0x1(%eax),%edx
 296:	89 55 08             	mov    %edx,0x8(%ebp)
 299:	0f b6 00             	movzbl (%eax),%eax
 29c:	0f be c0             	movsbl %al,%eax
 29f:	01 c8                	add    %ecx,%eax
 2a1:	83 e8 30             	sub    $0x30,%eax
 2a4:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 2a7:	8b 45 08             	mov    0x8(%ebp),%eax
 2aa:	0f b6 00             	movzbl (%eax),%eax
 2ad:	3c 2f                	cmp    $0x2f,%al
 2af:	7e 0a                	jle    2bb <atoi+0x48>
 2b1:	8b 45 08             	mov    0x8(%ebp),%eax
 2b4:	0f b6 00             	movzbl (%eax),%eax
 2b7:	3c 39                	cmp    $0x39,%al
 2b9:	7e c7                	jle    282 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 2bb:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 2be:	c9                   	leave  
 2bf:	c3                   	ret    

000002c0 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 2c0:	55                   	push   %ebp
 2c1:	89 e5                	mov    %esp,%ebp
 2c3:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 2c6:	8b 45 08             	mov    0x8(%ebp),%eax
 2c9:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 2cc:	8b 45 0c             	mov    0xc(%ebp),%eax
 2cf:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 2d2:	eb 17                	jmp    2eb <memmove+0x2b>
    *dst++ = *src++;
 2d4:	8b 45 fc             	mov    -0x4(%ebp),%eax
 2d7:	8d 50 01             	lea    0x1(%eax),%edx
 2da:	89 55 fc             	mov    %edx,-0x4(%ebp)
 2dd:	8b 55 f8             	mov    -0x8(%ebp),%edx
 2e0:	8d 4a 01             	lea    0x1(%edx),%ecx
 2e3:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 2e6:	0f b6 12             	movzbl (%edx),%edx
 2e9:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 2eb:	8b 45 10             	mov    0x10(%ebp),%eax
 2ee:	8d 50 ff             	lea    -0x1(%eax),%edx
 2f1:	89 55 10             	mov    %edx,0x10(%ebp)
 2f4:	85 c0                	test   %eax,%eax
 2f6:	7f dc                	jg     2d4 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 2f8:	8b 45 08             	mov    0x8(%ebp),%eax
}
 2fb:	c9                   	leave  
 2fc:	c3                   	ret    

000002fd <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 2fd:	b8 01 00 00 00       	mov    $0x1,%eax
 302:	cd 40                	int    $0x40
 304:	c3                   	ret    

00000305 <exit>:
SYSCALL(exit)
 305:	b8 02 00 00 00       	mov    $0x2,%eax
 30a:	cd 40                	int    $0x40
 30c:	c3                   	ret    

0000030d <wait>:
SYSCALL(wait)
 30d:	b8 03 00 00 00       	mov    $0x3,%eax
 312:	cd 40                	int    $0x40
 314:	c3                   	ret    

00000315 <pipe>:
SYSCALL(pipe)
 315:	b8 04 00 00 00       	mov    $0x4,%eax
 31a:	cd 40                	int    $0x40
 31c:	c3                   	ret    

0000031d <read>:
SYSCALL(read)
 31d:	b8 05 00 00 00       	mov    $0x5,%eax
 322:	cd 40                	int    $0x40
 324:	c3                   	ret    

00000325 <write>:
SYSCALL(write)
 325:	b8 10 00 00 00       	mov    $0x10,%eax
 32a:	cd 40                	int    $0x40
 32c:	c3                   	ret    

0000032d <close>:
SYSCALL(close)
 32d:	b8 15 00 00 00       	mov    $0x15,%eax
 332:	cd 40                	int    $0x40
 334:	c3                   	ret    

00000335 <kill>:
SYSCALL(kill)
 335:	b8 06 00 00 00       	mov    $0x6,%eax
 33a:	cd 40                	int    $0x40
 33c:	c3                   	ret    

0000033d <exec>:
SYSCALL(exec)
 33d:	b8 07 00 00 00       	mov    $0x7,%eax
 342:	cd 40                	int    $0x40
 344:	c3                   	ret    

00000345 <open>:
SYSCALL(open)
 345:	b8 0f 00 00 00       	mov    $0xf,%eax
 34a:	cd 40                	int    $0x40
 34c:	c3                   	ret    

0000034d <mknod>:
SYSCALL(mknod)
 34d:	b8 11 00 00 00       	mov    $0x11,%eax
 352:	cd 40                	int    $0x40
 354:	c3                   	ret    

00000355 <unlink>:
SYSCALL(unlink)
 355:	b8 12 00 00 00       	mov    $0x12,%eax
 35a:	cd 40                	int    $0x40
 35c:	c3                   	ret    

0000035d <fstat>:
SYSCALL(fstat)
 35d:	b8 08 00 00 00       	mov    $0x8,%eax
 362:	cd 40                	int    $0x40
 364:	c3                   	ret    

00000365 <link>:
SYSCALL(link)
 365:	b8 13 00 00 00       	mov    $0x13,%eax
 36a:	cd 40                	int    $0x40
 36c:	c3                   	ret    

0000036d <mkdir>:
SYSCALL(mkdir)
 36d:	b8 14 00 00 00       	mov    $0x14,%eax
 372:	cd 40                	int    $0x40
 374:	c3                   	ret    

00000375 <chdir>:
SYSCALL(chdir)
 375:	b8 09 00 00 00       	mov    $0x9,%eax
 37a:	cd 40                	int    $0x40
 37c:	c3                   	ret    

0000037d <dup>:
SYSCALL(dup)
 37d:	b8 0a 00 00 00       	mov    $0xa,%eax
 382:	cd 40                	int    $0x40
 384:	c3                   	ret    

00000385 <getpid>:
SYSCALL(getpid)
 385:	b8 0b 00 00 00       	mov    $0xb,%eax
 38a:	cd 40                	int    $0x40
 38c:	c3                   	ret    

0000038d <sbrk>:
SYSCALL(sbrk)
 38d:	b8 0c 00 00 00       	mov    $0xc,%eax
 392:	cd 40                	int    $0x40
 394:	c3                   	ret    

00000395 <sleep>:
SYSCALL(sleep)
 395:	b8 0d 00 00 00       	mov    $0xd,%eax
 39a:	cd 40                	int    $0x40
 39c:	c3                   	ret    

0000039d <uptime>:
SYSCALL(uptime)
 39d:	b8 0e 00 00 00       	mov    $0xe,%eax
 3a2:	cd 40                	int    $0x40
 3a4:	c3                   	ret    

000003a5 <mount>:
SYSCALL(mount)
 3a5:	b8 16 00 00 00       	mov    $0x16,%eax
 3aa:	cd 40                	int    $0x40
 3ac:	c3                   	ret    

000003ad <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 3ad:	55                   	push   %ebp
 3ae:	89 e5                	mov    %esp,%ebp
 3b0:	83 ec 18             	sub    $0x18,%esp
 3b3:	8b 45 0c             	mov    0xc(%ebp),%eax
 3b6:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 3b9:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 3c0:	00 
 3c1:	8d 45 f4             	lea    -0xc(%ebp),%eax
 3c4:	89 44 24 04          	mov    %eax,0x4(%esp)
 3c8:	8b 45 08             	mov    0x8(%ebp),%eax
 3cb:	89 04 24             	mov    %eax,(%esp)
 3ce:	e8 52 ff ff ff       	call   325 <write>
}
 3d3:	c9                   	leave  
 3d4:	c3                   	ret    

000003d5 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 3d5:	55                   	push   %ebp
 3d6:	89 e5                	mov    %esp,%ebp
 3d8:	56                   	push   %esi
 3d9:	53                   	push   %ebx
 3da:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 3dd:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 3e4:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 3e8:	74 17                	je     401 <printint+0x2c>
 3ea:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 3ee:	79 11                	jns    401 <printint+0x2c>
    neg = 1;
 3f0:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 3f7:	8b 45 0c             	mov    0xc(%ebp),%eax
 3fa:	f7 d8                	neg    %eax
 3fc:	89 45 ec             	mov    %eax,-0x14(%ebp)
 3ff:	eb 06                	jmp    407 <printint+0x32>
  } else {
    x = xx;
 401:	8b 45 0c             	mov    0xc(%ebp),%eax
 404:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 407:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 40e:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 411:	8d 41 01             	lea    0x1(%ecx),%eax
 414:	89 45 f4             	mov    %eax,-0xc(%ebp)
 417:	8b 5d 10             	mov    0x10(%ebp),%ebx
 41a:	8b 45 ec             	mov    -0x14(%ebp),%eax
 41d:	ba 00 00 00 00       	mov    $0x0,%edx
 422:	f7 f3                	div    %ebx
 424:	89 d0                	mov    %edx,%eax
 426:	0f b6 80 14 0b 00 00 	movzbl 0xb14(%eax),%eax
 42d:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 431:	8b 75 10             	mov    0x10(%ebp),%esi
 434:	8b 45 ec             	mov    -0x14(%ebp),%eax
 437:	ba 00 00 00 00       	mov    $0x0,%edx
 43c:	f7 f6                	div    %esi
 43e:	89 45 ec             	mov    %eax,-0x14(%ebp)
 441:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 445:	75 c7                	jne    40e <printint+0x39>
  if(neg)
 447:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 44b:	74 10                	je     45d <printint+0x88>
    buf[i++] = '-';
 44d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 450:	8d 50 01             	lea    0x1(%eax),%edx
 453:	89 55 f4             	mov    %edx,-0xc(%ebp)
 456:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 45b:	eb 1f                	jmp    47c <printint+0xa7>
 45d:	eb 1d                	jmp    47c <printint+0xa7>
    putc(fd, buf[i]);
 45f:	8d 55 dc             	lea    -0x24(%ebp),%edx
 462:	8b 45 f4             	mov    -0xc(%ebp),%eax
 465:	01 d0                	add    %edx,%eax
 467:	0f b6 00             	movzbl (%eax),%eax
 46a:	0f be c0             	movsbl %al,%eax
 46d:	89 44 24 04          	mov    %eax,0x4(%esp)
 471:	8b 45 08             	mov    0x8(%ebp),%eax
 474:	89 04 24             	mov    %eax,(%esp)
 477:	e8 31 ff ff ff       	call   3ad <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 47c:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 480:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 484:	79 d9                	jns    45f <printint+0x8a>
    putc(fd, buf[i]);
}
 486:	83 c4 30             	add    $0x30,%esp
 489:	5b                   	pop    %ebx
 48a:	5e                   	pop    %esi
 48b:	5d                   	pop    %ebp
 48c:	c3                   	ret    

0000048d <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 48d:	55                   	push   %ebp
 48e:	89 e5                	mov    %esp,%ebp
 490:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 493:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 49a:	8d 45 0c             	lea    0xc(%ebp),%eax
 49d:	83 c0 04             	add    $0x4,%eax
 4a0:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 4a3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 4aa:	e9 7c 01 00 00       	jmp    62b <printf+0x19e>
    c = fmt[i] & 0xff;
 4af:	8b 55 0c             	mov    0xc(%ebp),%edx
 4b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
 4b5:	01 d0                	add    %edx,%eax
 4b7:	0f b6 00             	movzbl (%eax),%eax
 4ba:	0f be c0             	movsbl %al,%eax
 4bd:	25 ff 00 00 00       	and    $0xff,%eax
 4c2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 4c5:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 4c9:	75 2c                	jne    4f7 <printf+0x6a>
      if(c == '%'){
 4cb:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 4cf:	75 0c                	jne    4dd <printf+0x50>
        state = '%';
 4d1:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 4d8:	e9 4a 01 00 00       	jmp    627 <printf+0x19a>
      } else {
        putc(fd, c);
 4dd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 4e0:	0f be c0             	movsbl %al,%eax
 4e3:	89 44 24 04          	mov    %eax,0x4(%esp)
 4e7:	8b 45 08             	mov    0x8(%ebp),%eax
 4ea:	89 04 24             	mov    %eax,(%esp)
 4ed:	e8 bb fe ff ff       	call   3ad <putc>
 4f2:	e9 30 01 00 00       	jmp    627 <printf+0x19a>
      }
    } else if(state == '%'){
 4f7:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 4fb:	0f 85 26 01 00 00    	jne    627 <printf+0x19a>
      if(c == 'd'){
 501:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 505:	75 2d                	jne    534 <printf+0xa7>
        printint(fd, *ap, 10, 1);
 507:	8b 45 e8             	mov    -0x18(%ebp),%eax
 50a:	8b 00                	mov    (%eax),%eax
 50c:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 513:	00 
 514:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 51b:	00 
 51c:	89 44 24 04          	mov    %eax,0x4(%esp)
 520:	8b 45 08             	mov    0x8(%ebp),%eax
 523:	89 04 24             	mov    %eax,(%esp)
 526:	e8 aa fe ff ff       	call   3d5 <printint>
        ap++;
 52b:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 52f:	e9 ec 00 00 00       	jmp    620 <printf+0x193>
      } else if(c == 'x' || c == 'p'){
 534:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 538:	74 06                	je     540 <printf+0xb3>
 53a:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 53e:	75 2d                	jne    56d <printf+0xe0>
        printint(fd, *ap, 16, 0);
 540:	8b 45 e8             	mov    -0x18(%ebp),%eax
 543:	8b 00                	mov    (%eax),%eax
 545:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 54c:	00 
 54d:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 554:	00 
 555:	89 44 24 04          	mov    %eax,0x4(%esp)
 559:	8b 45 08             	mov    0x8(%ebp),%eax
 55c:	89 04 24             	mov    %eax,(%esp)
 55f:	e8 71 fe ff ff       	call   3d5 <printint>
        ap++;
 564:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 568:	e9 b3 00 00 00       	jmp    620 <printf+0x193>
      } else if(c == 's'){
 56d:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 571:	75 45                	jne    5b8 <printf+0x12b>
        s = (char*)*ap;
 573:	8b 45 e8             	mov    -0x18(%ebp),%eax
 576:	8b 00                	mov    (%eax),%eax
 578:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 57b:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 57f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 583:	75 09                	jne    58e <printf+0x101>
          s = "(null)";
 585:	c7 45 f4 c9 08 00 00 	movl   $0x8c9,-0xc(%ebp)
        while(*s != 0){
 58c:	eb 1e                	jmp    5ac <printf+0x11f>
 58e:	eb 1c                	jmp    5ac <printf+0x11f>
          putc(fd, *s);
 590:	8b 45 f4             	mov    -0xc(%ebp),%eax
 593:	0f b6 00             	movzbl (%eax),%eax
 596:	0f be c0             	movsbl %al,%eax
 599:	89 44 24 04          	mov    %eax,0x4(%esp)
 59d:	8b 45 08             	mov    0x8(%ebp),%eax
 5a0:	89 04 24             	mov    %eax,(%esp)
 5a3:	e8 05 fe ff ff       	call   3ad <putc>
          s++;
 5a8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 5ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5af:	0f b6 00             	movzbl (%eax),%eax
 5b2:	84 c0                	test   %al,%al
 5b4:	75 da                	jne    590 <printf+0x103>
 5b6:	eb 68                	jmp    620 <printf+0x193>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 5b8:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 5bc:	75 1d                	jne    5db <printf+0x14e>
        putc(fd, *ap);
 5be:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5c1:	8b 00                	mov    (%eax),%eax
 5c3:	0f be c0             	movsbl %al,%eax
 5c6:	89 44 24 04          	mov    %eax,0x4(%esp)
 5ca:	8b 45 08             	mov    0x8(%ebp),%eax
 5cd:	89 04 24             	mov    %eax,(%esp)
 5d0:	e8 d8 fd ff ff       	call   3ad <putc>
        ap++;
 5d5:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 5d9:	eb 45                	jmp    620 <printf+0x193>
      } else if(c == '%'){
 5db:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 5df:	75 17                	jne    5f8 <printf+0x16b>
        putc(fd, c);
 5e1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 5e4:	0f be c0             	movsbl %al,%eax
 5e7:	89 44 24 04          	mov    %eax,0x4(%esp)
 5eb:	8b 45 08             	mov    0x8(%ebp),%eax
 5ee:	89 04 24             	mov    %eax,(%esp)
 5f1:	e8 b7 fd ff ff       	call   3ad <putc>
 5f6:	eb 28                	jmp    620 <printf+0x193>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 5f8:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 5ff:	00 
 600:	8b 45 08             	mov    0x8(%ebp),%eax
 603:	89 04 24             	mov    %eax,(%esp)
 606:	e8 a2 fd ff ff       	call   3ad <putc>
        putc(fd, c);
 60b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 60e:	0f be c0             	movsbl %al,%eax
 611:	89 44 24 04          	mov    %eax,0x4(%esp)
 615:	8b 45 08             	mov    0x8(%ebp),%eax
 618:	89 04 24             	mov    %eax,(%esp)
 61b:	e8 8d fd ff ff       	call   3ad <putc>
      }
      state = 0;
 620:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 627:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 62b:	8b 55 0c             	mov    0xc(%ebp),%edx
 62e:	8b 45 f0             	mov    -0x10(%ebp),%eax
 631:	01 d0                	add    %edx,%eax
 633:	0f b6 00             	movzbl (%eax),%eax
 636:	84 c0                	test   %al,%al
 638:	0f 85 71 fe ff ff    	jne    4af <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 63e:	c9                   	leave  
 63f:	c3                   	ret    

00000640 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 640:	55                   	push   %ebp
 641:	89 e5                	mov    %esp,%ebp
 643:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 646:	8b 45 08             	mov    0x8(%ebp),%eax
 649:	83 e8 08             	sub    $0x8,%eax
 64c:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 64f:	a1 30 0b 00 00       	mov    0xb30,%eax
 654:	89 45 fc             	mov    %eax,-0x4(%ebp)
 657:	eb 24                	jmp    67d <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 659:	8b 45 fc             	mov    -0x4(%ebp),%eax
 65c:	8b 00                	mov    (%eax),%eax
 65e:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 661:	77 12                	ja     675 <free+0x35>
 663:	8b 45 f8             	mov    -0x8(%ebp),%eax
 666:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 669:	77 24                	ja     68f <free+0x4f>
 66b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 66e:	8b 00                	mov    (%eax),%eax
 670:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 673:	77 1a                	ja     68f <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 675:	8b 45 fc             	mov    -0x4(%ebp),%eax
 678:	8b 00                	mov    (%eax),%eax
 67a:	89 45 fc             	mov    %eax,-0x4(%ebp)
 67d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 680:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 683:	76 d4                	jbe    659 <free+0x19>
 685:	8b 45 fc             	mov    -0x4(%ebp),%eax
 688:	8b 00                	mov    (%eax),%eax
 68a:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 68d:	76 ca                	jbe    659 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 68f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 692:	8b 40 04             	mov    0x4(%eax),%eax
 695:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 69c:	8b 45 f8             	mov    -0x8(%ebp),%eax
 69f:	01 c2                	add    %eax,%edx
 6a1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6a4:	8b 00                	mov    (%eax),%eax
 6a6:	39 c2                	cmp    %eax,%edx
 6a8:	75 24                	jne    6ce <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 6aa:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6ad:	8b 50 04             	mov    0x4(%eax),%edx
 6b0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6b3:	8b 00                	mov    (%eax),%eax
 6b5:	8b 40 04             	mov    0x4(%eax),%eax
 6b8:	01 c2                	add    %eax,%edx
 6ba:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6bd:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 6c0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6c3:	8b 00                	mov    (%eax),%eax
 6c5:	8b 10                	mov    (%eax),%edx
 6c7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6ca:	89 10                	mov    %edx,(%eax)
 6cc:	eb 0a                	jmp    6d8 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 6ce:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6d1:	8b 10                	mov    (%eax),%edx
 6d3:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6d6:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 6d8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6db:	8b 40 04             	mov    0x4(%eax),%eax
 6de:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 6e5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6e8:	01 d0                	add    %edx,%eax
 6ea:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 6ed:	75 20                	jne    70f <free+0xcf>
    p->s.size += bp->s.size;
 6ef:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6f2:	8b 50 04             	mov    0x4(%eax),%edx
 6f5:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6f8:	8b 40 04             	mov    0x4(%eax),%eax
 6fb:	01 c2                	add    %eax,%edx
 6fd:	8b 45 fc             	mov    -0x4(%ebp),%eax
 700:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 703:	8b 45 f8             	mov    -0x8(%ebp),%eax
 706:	8b 10                	mov    (%eax),%edx
 708:	8b 45 fc             	mov    -0x4(%ebp),%eax
 70b:	89 10                	mov    %edx,(%eax)
 70d:	eb 08                	jmp    717 <free+0xd7>
  } else
    p->s.ptr = bp;
 70f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 712:	8b 55 f8             	mov    -0x8(%ebp),%edx
 715:	89 10                	mov    %edx,(%eax)
  freep = p;
 717:	8b 45 fc             	mov    -0x4(%ebp),%eax
 71a:	a3 30 0b 00 00       	mov    %eax,0xb30
}
 71f:	c9                   	leave  
 720:	c3                   	ret    

00000721 <morecore>:

static Header*
morecore(uint nu)
{
 721:	55                   	push   %ebp
 722:	89 e5                	mov    %esp,%ebp
 724:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 727:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 72e:	77 07                	ja     737 <morecore+0x16>
    nu = 4096;
 730:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 737:	8b 45 08             	mov    0x8(%ebp),%eax
 73a:	c1 e0 03             	shl    $0x3,%eax
 73d:	89 04 24             	mov    %eax,(%esp)
 740:	e8 48 fc ff ff       	call   38d <sbrk>
 745:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 748:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 74c:	75 07                	jne    755 <morecore+0x34>
    return 0;
 74e:	b8 00 00 00 00       	mov    $0x0,%eax
 753:	eb 22                	jmp    777 <morecore+0x56>
  hp = (Header*)p;
 755:	8b 45 f4             	mov    -0xc(%ebp),%eax
 758:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 75b:	8b 45 f0             	mov    -0x10(%ebp),%eax
 75e:	8b 55 08             	mov    0x8(%ebp),%edx
 761:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 764:	8b 45 f0             	mov    -0x10(%ebp),%eax
 767:	83 c0 08             	add    $0x8,%eax
 76a:	89 04 24             	mov    %eax,(%esp)
 76d:	e8 ce fe ff ff       	call   640 <free>
  return freep;
 772:	a1 30 0b 00 00       	mov    0xb30,%eax
}
 777:	c9                   	leave  
 778:	c3                   	ret    

00000779 <malloc>:

void*
malloc(uint nbytes)
{
 779:	55                   	push   %ebp
 77a:	89 e5                	mov    %esp,%ebp
 77c:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 77f:	8b 45 08             	mov    0x8(%ebp),%eax
 782:	83 c0 07             	add    $0x7,%eax
 785:	c1 e8 03             	shr    $0x3,%eax
 788:	83 c0 01             	add    $0x1,%eax
 78b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 78e:	a1 30 0b 00 00       	mov    0xb30,%eax
 793:	89 45 f0             	mov    %eax,-0x10(%ebp)
 796:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 79a:	75 23                	jne    7bf <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 79c:	c7 45 f0 28 0b 00 00 	movl   $0xb28,-0x10(%ebp)
 7a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7a6:	a3 30 0b 00 00       	mov    %eax,0xb30
 7ab:	a1 30 0b 00 00       	mov    0xb30,%eax
 7b0:	a3 28 0b 00 00       	mov    %eax,0xb28
    base.s.size = 0;
 7b5:	c7 05 2c 0b 00 00 00 	movl   $0x0,0xb2c
 7bc:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7c2:	8b 00                	mov    (%eax),%eax
 7c4:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 7c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7ca:	8b 40 04             	mov    0x4(%eax),%eax
 7cd:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 7d0:	72 4d                	jb     81f <malloc+0xa6>
      if(p->s.size == nunits)
 7d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7d5:	8b 40 04             	mov    0x4(%eax),%eax
 7d8:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 7db:	75 0c                	jne    7e9 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 7dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7e0:	8b 10                	mov    (%eax),%edx
 7e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7e5:	89 10                	mov    %edx,(%eax)
 7e7:	eb 26                	jmp    80f <malloc+0x96>
      else {
        p->s.size -= nunits;
 7e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7ec:	8b 40 04             	mov    0x4(%eax),%eax
 7ef:	2b 45 ec             	sub    -0x14(%ebp),%eax
 7f2:	89 c2                	mov    %eax,%edx
 7f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7f7:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 7fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7fd:	8b 40 04             	mov    0x4(%eax),%eax
 800:	c1 e0 03             	shl    $0x3,%eax
 803:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 806:	8b 45 f4             	mov    -0xc(%ebp),%eax
 809:	8b 55 ec             	mov    -0x14(%ebp),%edx
 80c:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 80f:	8b 45 f0             	mov    -0x10(%ebp),%eax
 812:	a3 30 0b 00 00       	mov    %eax,0xb30
      return (void*)(p + 1);
 817:	8b 45 f4             	mov    -0xc(%ebp),%eax
 81a:	83 c0 08             	add    $0x8,%eax
 81d:	eb 38                	jmp    857 <malloc+0xde>
    }
    if(p == freep)
 81f:	a1 30 0b 00 00       	mov    0xb30,%eax
 824:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 827:	75 1b                	jne    844 <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 829:	8b 45 ec             	mov    -0x14(%ebp),%eax
 82c:	89 04 24             	mov    %eax,(%esp)
 82f:	e8 ed fe ff ff       	call   721 <morecore>
 834:	89 45 f4             	mov    %eax,-0xc(%ebp)
 837:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 83b:	75 07                	jne    844 <malloc+0xcb>
        return 0;
 83d:	b8 00 00 00 00       	mov    $0x0,%eax
 842:	eb 13                	jmp    857 <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 844:	8b 45 f4             	mov    -0xc(%ebp),%eax
 847:	89 45 f0             	mov    %eax,-0x10(%ebp)
 84a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 84d:	8b 00                	mov    (%eax),%eax
 84f:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 852:	e9 70 ff ff ff       	jmp    7c7 <malloc+0x4e>
}
 857:	c9                   	leave  
 858:	c3                   	ret    
