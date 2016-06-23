
_init:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:

char *argv[] = { "sh", 0 };

int
main(void)
{
   0:	8d 4c 24 04          	lea    0x4(%esp),%ecx
   4:	83 e4 f0             	and    $0xfffffff0,%esp
   7:	ff 71 fc             	pushl  -0x4(%ecx)
   a:	55                   	push   %ebp
   b:	89 e5                	mov    %esp,%ebp
   d:	51                   	push   %ecx
   e:	83 ec 14             	sub    $0x14,%esp
  int pid, wpid;

printf(1,"before open \n");
  11:	83 ec 08             	sub    $0x8,%esp
  14:	68 a2 08 00 00       	push   $0x8a2
  19:	6a 01                	push   $0x1
  1b:	e8 c9 04 00 00       	call   4e9 <printf>
  20:	83 c4 10             	add    $0x10,%esp
  if(open("console", O_RDWR) < 0){
  23:	83 ec 08             	sub    $0x8,%esp
  26:	6a 02                	push   $0x2
  28:	68 b0 08 00 00       	push   $0x8b0
  2d:	e8 78 03 00 00       	call   3aa <open>
  32:	83 c4 10             	add    $0x10,%esp
  35:	85 c0                	test   %eax,%eax
  37:	79 26                	jns    5f <main+0x5f>
   //  printf(1,"after open \n");
    mknod("console", 1, 1);
  39:	83 ec 04             	sub    $0x4,%esp
  3c:	6a 01                	push   $0x1
  3e:	6a 01                	push   $0x1
  40:	68 b0 08 00 00       	push   $0x8b0
  45:	e8 68 03 00 00       	call   3b2 <mknod>
  4a:	83 c4 10             	add    $0x10,%esp
   // printf(1,"after mknod \n");
    open("console", O_RDWR);
  4d:	83 ec 08             	sub    $0x8,%esp
  50:	6a 02                	push   $0x2
  52:	68 b0 08 00 00       	push   $0x8b0
  57:	e8 4e 03 00 00       	call   3aa <open>
  5c:	83 c4 10             	add    $0x10,%esp
   // printf(1,"after open 2\n");
  }
  dup(0);  // stdout
  5f:	83 ec 0c             	sub    $0xc,%esp
  62:	6a 00                	push   $0x0
  64:	e8 79 03 00 00       	call   3e2 <dup>
  69:	83 c4 10             	add    $0x10,%esp
  dup(0);  // stderr
  6c:	83 ec 0c             	sub    $0xc,%esp
  6f:	6a 00                	push   $0x0
  71:	e8 6c 03 00 00       	call   3e2 <dup>
  76:	83 c4 10             	add    $0x10,%esp

  for(;;){
    printf(1, "init: starting sh\n");
  79:	83 ec 08             	sub    $0x8,%esp
  7c:	68 b8 08 00 00       	push   $0x8b8
  81:	6a 01                	push   $0x1
  83:	e8 61 04 00 00       	call   4e9 <printf>
  88:	83 c4 10             	add    $0x10,%esp
    pid = fork();
  8b:	e8 d2 02 00 00       	call   362 <fork>
  90:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(pid < 0){
  93:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  97:	79 17                	jns    b0 <main+0xb0>
      printf(1, "init: fork failed\n");
  99:	83 ec 08             	sub    $0x8,%esp
  9c:	68 cb 08 00 00       	push   $0x8cb
  a1:	6a 01                	push   $0x1
  a3:	e8 41 04 00 00       	call   4e9 <printf>
  a8:	83 c4 10             	add    $0x10,%esp
      exit();
  ab:	e8 ba 02 00 00       	call   36a <exit>
    }
    if(pid == 0){
  b0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  b4:	75 3e                	jne    f4 <main+0xf4>
      exec("sh", argv);
  b6:	83 ec 08             	sub    $0x8,%esp
  b9:	68 4c 0b 00 00       	push   $0xb4c
  be:	68 9f 08 00 00       	push   $0x89f
  c3:	e8 da 02 00 00       	call   3a2 <exec>
  c8:	83 c4 10             	add    $0x10,%esp
      printf(1, "init: exec sh failed\n");
  cb:	83 ec 08             	sub    $0x8,%esp
  ce:	68 de 08 00 00       	push   $0x8de
  d3:	6a 01                	push   $0x1
  d5:	e8 0f 04 00 00       	call   4e9 <printf>
  da:	83 c4 10             	add    $0x10,%esp
      exit();
  dd:	e8 88 02 00 00       	call   36a <exit>
    }
    while((wpid=wait()) >= 0 && wpid != pid)
      printf(1, "zombie!\n");
  e2:	83 ec 08             	sub    $0x8,%esp
  e5:	68 f4 08 00 00       	push   $0x8f4
  ea:	6a 01                	push   $0x1
  ec:	e8 f8 03 00 00       	call   4e9 <printf>
  f1:	83 c4 10             	add    $0x10,%esp
    if(pid == 0){
      exec("sh", argv);
      printf(1, "init: exec sh failed\n");
      exit();
    }
    while((wpid=wait()) >= 0 && wpid != pid)
  f4:	e8 79 02 00 00       	call   372 <wait>
  f9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  fc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 100:	0f 88 73 ff ff ff    	js     79 <main+0x79>
 106:	8b 45 f0             	mov    -0x10(%ebp),%eax
 109:	3b 45 f4             	cmp    -0xc(%ebp),%eax
 10c:	75 d4                	jne    e2 <main+0xe2>
      printf(1, "zombie!\n");
  }
 10e:	e9 66 ff ff ff       	jmp    79 <main+0x79>

00000113 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 113:	55                   	push   %ebp
 114:	89 e5                	mov    %esp,%ebp
 116:	57                   	push   %edi
 117:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 118:	8b 4d 08             	mov    0x8(%ebp),%ecx
 11b:	8b 55 10             	mov    0x10(%ebp),%edx
 11e:	8b 45 0c             	mov    0xc(%ebp),%eax
 121:	89 cb                	mov    %ecx,%ebx
 123:	89 df                	mov    %ebx,%edi
 125:	89 d1                	mov    %edx,%ecx
 127:	fc                   	cld    
 128:	f3 aa                	rep stos %al,%es:(%edi)
 12a:	89 ca                	mov    %ecx,%edx
 12c:	89 fb                	mov    %edi,%ebx
 12e:	89 5d 08             	mov    %ebx,0x8(%ebp)
 131:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 134:	90                   	nop
 135:	5b                   	pop    %ebx
 136:	5f                   	pop    %edi
 137:	5d                   	pop    %ebp
 138:	c3                   	ret    

00000139 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 139:	55                   	push   %ebp
 13a:	89 e5                	mov    %esp,%ebp
 13c:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 13f:	8b 45 08             	mov    0x8(%ebp),%eax
 142:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 145:	90                   	nop
 146:	8b 45 08             	mov    0x8(%ebp),%eax
 149:	8d 50 01             	lea    0x1(%eax),%edx
 14c:	89 55 08             	mov    %edx,0x8(%ebp)
 14f:	8b 55 0c             	mov    0xc(%ebp),%edx
 152:	8d 4a 01             	lea    0x1(%edx),%ecx
 155:	89 4d 0c             	mov    %ecx,0xc(%ebp)
 158:	0f b6 12             	movzbl (%edx),%edx
 15b:	88 10                	mov    %dl,(%eax)
 15d:	0f b6 00             	movzbl (%eax),%eax
 160:	84 c0                	test   %al,%al
 162:	75 e2                	jne    146 <strcpy+0xd>
    ;
  return os;
 164:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 167:	c9                   	leave  
 168:	c3                   	ret    

00000169 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 169:	55                   	push   %ebp
 16a:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 16c:	eb 08                	jmp    176 <strcmp+0xd>
    p++, q++;
 16e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 172:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 176:	8b 45 08             	mov    0x8(%ebp),%eax
 179:	0f b6 00             	movzbl (%eax),%eax
 17c:	84 c0                	test   %al,%al
 17e:	74 10                	je     190 <strcmp+0x27>
 180:	8b 45 08             	mov    0x8(%ebp),%eax
 183:	0f b6 10             	movzbl (%eax),%edx
 186:	8b 45 0c             	mov    0xc(%ebp),%eax
 189:	0f b6 00             	movzbl (%eax),%eax
 18c:	38 c2                	cmp    %al,%dl
 18e:	74 de                	je     16e <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 190:	8b 45 08             	mov    0x8(%ebp),%eax
 193:	0f b6 00             	movzbl (%eax),%eax
 196:	0f b6 d0             	movzbl %al,%edx
 199:	8b 45 0c             	mov    0xc(%ebp),%eax
 19c:	0f b6 00             	movzbl (%eax),%eax
 19f:	0f b6 c0             	movzbl %al,%eax
 1a2:	29 c2                	sub    %eax,%edx
 1a4:	89 d0                	mov    %edx,%eax
}
 1a6:	5d                   	pop    %ebp
 1a7:	c3                   	ret    

000001a8 <strlen>:

uint
strlen(char *s)
{
 1a8:	55                   	push   %ebp
 1a9:	89 e5                	mov    %esp,%ebp
 1ab:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 1ae:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 1b5:	eb 04                	jmp    1bb <strlen+0x13>
 1b7:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 1bb:	8b 55 fc             	mov    -0x4(%ebp),%edx
 1be:	8b 45 08             	mov    0x8(%ebp),%eax
 1c1:	01 d0                	add    %edx,%eax
 1c3:	0f b6 00             	movzbl (%eax),%eax
 1c6:	84 c0                	test   %al,%al
 1c8:	75 ed                	jne    1b7 <strlen+0xf>
    ;
  return n;
 1ca:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 1cd:	c9                   	leave  
 1ce:	c3                   	ret    

000001cf <memset>:

void*
memset(void *dst, int c, uint n)
{
 1cf:	55                   	push   %ebp
 1d0:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 1d2:	8b 45 10             	mov    0x10(%ebp),%eax
 1d5:	50                   	push   %eax
 1d6:	ff 75 0c             	pushl  0xc(%ebp)
 1d9:	ff 75 08             	pushl  0x8(%ebp)
 1dc:	e8 32 ff ff ff       	call   113 <stosb>
 1e1:	83 c4 0c             	add    $0xc,%esp
  return dst;
 1e4:	8b 45 08             	mov    0x8(%ebp),%eax
}
 1e7:	c9                   	leave  
 1e8:	c3                   	ret    

000001e9 <strchr>:

char*
strchr(const char *s, char c)
{
 1e9:	55                   	push   %ebp
 1ea:	89 e5                	mov    %esp,%ebp
 1ec:	83 ec 04             	sub    $0x4,%esp
 1ef:	8b 45 0c             	mov    0xc(%ebp),%eax
 1f2:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 1f5:	eb 14                	jmp    20b <strchr+0x22>
    if(*s == c)
 1f7:	8b 45 08             	mov    0x8(%ebp),%eax
 1fa:	0f b6 00             	movzbl (%eax),%eax
 1fd:	3a 45 fc             	cmp    -0x4(%ebp),%al
 200:	75 05                	jne    207 <strchr+0x1e>
      return (char*)s;
 202:	8b 45 08             	mov    0x8(%ebp),%eax
 205:	eb 13                	jmp    21a <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 207:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 20b:	8b 45 08             	mov    0x8(%ebp),%eax
 20e:	0f b6 00             	movzbl (%eax),%eax
 211:	84 c0                	test   %al,%al
 213:	75 e2                	jne    1f7 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 215:	b8 00 00 00 00       	mov    $0x0,%eax
}
 21a:	c9                   	leave  
 21b:	c3                   	ret    

0000021c <gets>:

char*
gets(char *buf, int max)
{
 21c:	55                   	push   %ebp
 21d:	89 e5                	mov    %esp,%ebp
 21f:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 222:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 229:	eb 42                	jmp    26d <gets+0x51>
    cc = read(0, &c, 1);
 22b:	83 ec 04             	sub    $0x4,%esp
 22e:	6a 01                	push   $0x1
 230:	8d 45 ef             	lea    -0x11(%ebp),%eax
 233:	50                   	push   %eax
 234:	6a 00                	push   $0x0
 236:	e8 47 01 00 00       	call   382 <read>
 23b:	83 c4 10             	add    $0x10,%esp
 23e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 241:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 245:	7e 33                	jle    27a <gets+0x5e>
      break;
    buf[i++] = c;
 247:	8b 45 f4             	mov    -0xc(%ebp),%eax
 24a:	8d 50 01             	lea    0x1(%eax),%edx
 24d:	89 55 f4             	mov    %edx,-0xc(%ebp)
 250:	89 c2                	mov    %eax,%edx
 252:	8b 45 08             	mov    0x8(%ebp),%eax
 255:	01 c2                	add    %eax,%edx
 257:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 25b:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 25d:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 261:	3c 0a                	cmp    $0xa,%al
 263:	74 16                	je     27b <gets+0x5f>
 265:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 269:	3c 0d                	cmp    $0xd,%al
 26b:	74 0e                	je     27b <gets+0x5f>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 26d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 270:	83 c0 01             	add    $0x1,%eax
 273:	3b 45 0c             	cmp    0xc(%ebp),%eax
 276:	7c b3                	jl     22b <gets+0xf>
 278:	eb 01                	jmp    27b <gets+0x5f>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
 27a:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 27b:	8b 55 f4             	mov    -0xc(%ebp),%edx
 27e:	8b 45 08             	mov    0x8(%ebp),%eax
 281:	01 d0                	add    %edx,%eax
 283:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 286:	8b 45 08             	mov    0x8(%ebp),%eax
}
 289:	c9                   	leave  
 28a:	c3                   	ret    

0000028b <stat>:

int
stat(char *n, struct stat *st)
{
 28b:	55                   	push   %ebp
 28c:	89 e5                	mov    %esp,%ebp
 28e:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 291:	83 ec 08             	sub    $0x8,%esp
 294:	6a 00                	push   $0x0
 296:	ff 75 08             	pushl  0x8(%ebp)
 299:	e8 0c 01 00 00       	call   3aa <open>
 29e:	83 c4 10             	add    $0x10,%esp
 2a1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 2a4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 2a8:	79 07                	jns    2b1 <stat+0x26>
    return -1;
 2aa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 2af:	eb 25                	jmp    2d6 <stat+0x4b>
  r = fstat(fd, st);
 2b1:	83 ec 08             	sub    $0x8,%esp
 2b4:	ff 75 0c             	pushl  0xc(%ebp)
 2b7:	ff 75 f4             	pushl  -0xc(%ebp)
 2ba:	e8 03 01 00 00       	call   3c2 <fstat>
 2bf:	83 c4 10             	add    $0x10,%esp
 2c2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 2c5:	83 ec 0c             	sub    $0xc,%esp
 2c8:	ff 75 f4             	pushl  -0xc(%ebp)
 2cb:	e8 c2 00 00 00       	call   392 <close>
 2d0:	83 c4 10             	add    $0x10,%esp
  return r;
 2d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 2d6:	c9                   	leave  
 2d7:	c3                   	ret    

000002d8 <atoi>:

int
atoi(const char *s)
{
 2d8:	55                   	push   %ebp
 2d9:	89 e5                	mov    %esp,%ebp
 2db:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 2de:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 2e5:	eb 25                	jmp    30c <atoi+0x34>
    n = n*10 + *s++ - '0';
 2e7:	8b 55 fc             	mov    -0x4(%ebp),%edx
 2ea:	89 d0                	mov    %edx,%eax
 2ec:	c1 e0 02             	shl    $0x2,%eax
 2ef:	01 d0                	add    %edx,%eax
 2f1:	01 c0                	add    %eax,%eax
 2f3:	89 c1                	mov    %eax,%ecx
 2f5:	8b 45 08             	mov    0x8(%ebp),%eax
 2f8:	8d 50 01             	lea    0x1(%eax),%edx
 2fb:	89 55 08             	mov    %edx,0x8(%ebp)
 2fe:	0f b6 00             	movzbl (%eax),%eax
 301:	0f be c0             	movsbl %al,%eax
 304:	01 c8                	add    %ecx,%eax
 306:	83 e8 30             	sub    $0x30,%eax
 309:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 30c:	8b 45 08             	mov    0x8(%ebp),%eax
 30f:	0f b6 00             	movzbl (%eax),%eax
 312:	3c 2f                	cmp    $0x2f,%al
 314:	7e 0a                	jle    320 <atoi+0x48>
 316:	8b 45 08             	mov    0x8(%ebp),%eax
 319:	0f b6 00             	movzbl (%eax),%eax
 31c:	3c 39                	cmp    $0x39,%al
 31e:	7e c7                	jle    2e7 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 320:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 323:	c9                   	leave  
 324:	c3                   	ret    

00000325 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 325:	55                   	push   %ebp
 326:	89 e5                	mov    %esp,%ebp
 328:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 32b:	8b 45 08             	mov    0x8(%ebp),%eax
 32e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 331:	8b 45 0c             	mov    0xc(%ebp),%eax
 334:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 337:	eb 17                	jmp    350 <memmove+0x2b>
    *dst++ = *src++;
 339:	8b 45 fc             	mov    -0x4(%ebp),%eax
 33c:	8d 50 01             	lea    0x1(%eax),%edx
 33f:	89 55 fc             	mov    %edx,-0x4(%ebp)
 342:	8b 55 f8             	mov    -0x8(%ebp),%edx
 345:	8d 4a 01             	lea    0x1(%edx),%ecx
 348:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 34b:	0f b6 12             	movzbl (%edx),%edx
 34e:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 350:	8b 45 10             	mov    0x10(%ebp),%eax
 353:	8d 50 ff             	lea    -0x1(%eax),%edx
 356:	89 55 10             	mov    %edx,0x10(%ebp)
 359:	85 c0                	test   %eax,%eax
 35b:	7f dc                	jg     339 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 35d:	8b 45 08             	mov    0x8(%ebp),%eax
}
 360:	c9                   	leave  
 361:	c3                   	ret    

00000362 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 362:	b8 01 00 00 00       	mov    $0x1,%eax
 367:	cd 40                	int    $0x40
 369:	c3                   	ret    

0000036a <exit>:
SYSCALL(exit)
 36a:	b8 02 00 00 00       	mov    $0x2,%eax
 36f:	cd 40                	int    $0x40
 371:	c3                   	ret    

00000372 <wait>:
SYSCALL(wait)
 372:	b8 03 00 00 00       	mov    $0x3,%eax
 377:	cd 40                	int    $0x40
 379:	c3                   	ret    

0000037a <pipe>:
SYSCALL(pipe)
 37a:	b8 04 00 00 00       	mov    $0x4,%eax
 37f:	cd 40                	int    $0x40
 381:	c3                   	ret    

00000382 <read>:
SYSCALL(read)
 382:	b8 05 00 00 00       	mov    $0x5,%eax
 387:	cd 40                	int    $0x40
 389:	c3                   	ret    

0000038a <write>:
SYSCALL(write)
 38a:	b8 10 00 00 00       	mov    $0x10,%eax
 38f:	cd 40                	int    $0x40
 391:	c3                   	ret    

00000392 <close>:
SYSCALL(close)
 392:	b8 15 00 00 00       	mov    $0x15,%eax
 397:	cd 40                	int    $0x40
 399:	c3                   	ret    

0000039a <kill>:
SYSCALL(kill)
 39a:	b8 06 00 00 00       	mov    $0x6,%eax
 39f:	cd 40                	int    $0x40
 3a1:	c3                   	ret    

000003a2 <exec>:
SYSCALL(exec)
 3a2:	b8 07 00 00 00       	mov    $0x7,%eax
 3a7:	cd 40                	int    $0x40
 3a9:	c3                   	ret    

000003aa <open>:
SYSCALL(open)
 3aa:	b8 0f 00 00 00       	mov    $0xf,%eax
 3af:	cd 40                	int    $0x40
 3b1:	c3                   	ret    

000003b2 <mknod>:
SYSCALL(mknod)
 3b2:	b8 11 00 00 00       	mov    $0x11,%eax
 3b7:	cd 40                	int    $0x40
 3b9:	c3                   	ret    

000003ba <unlink>:
SYSCALL(unlink)
 3ba:	b8 12 00 00 00       	mov    $0x12,%eax
 3bf:	cd 40                	int    $0x40
 3c1:	c3                   	ret    

000003c2 <fstat>:
SYSCALL(fstat)
 3c2:	b8 08 00 00 00       	mov    $0x8,%eax
 3c7:	cd 40                	int    $0x40
 3c9:	c3                   	ret    

000003ca <link>:
SYSCALL(link)
 3ca:	b8 13 00 00 00       	mov    $0x13,%eax
 3cf:	cd 40                	int    $0x40
 3d1:	c3                   	ret    

000003d2 <mkdir>:
SYSCALL(mkdir)
 3d2:	b8 14 00 00 00       	mov    $0x14,%eax
 3d7:	cd 40                	int    $0x40
 3d9:	c3                   	ret    

000003da <chdir>:
SYSCALL(chdir)
 3da:	b8 09 00 00 00       	mov    $0x9,%eax
 3df:	cd 40                	int    $0x40
 3e1:	c3                   	ret    

000003e2 <dup>:
SYSCALL(dup)
 3e2:	b8 0a 00 00 00       	mov    $0xa,%eax
 3e7:	cd 40                	int    $0x40
 3e9:	c3                   	ret    

000003ea <getpid>:
SYSCALL(getpid)
 3ea:	b8 0b 00 00 00       	mov    $0xb,%eax
 3ef:	cd 40                	int    $0x40
 3f1:	c3                   	ret    

000003f2 <sbrk>:
SYSCALL(sbrk)
 3f2:	b8 0c 00 00 00       	mov    $0xc,%eax
 3f7:	cd 40                	int    $0x40
 3f9:	c3                   	ret    

000003fa <sleep>:
SYSCALL(sleep)
 3fa:	b8 0d 00 00 00       	mov    $0xd,%eax
 3ff:	cd 40                	int    $0x40
 401:	c3                   	ret    

00000402 <uptime>:
SYSCALL(uptime)
 402:	b8 0e 00 00 00       	mov    $0xe,%eax
 407:	cd 40                	int    $0x40
 409:	c3                   	ret    

0000040a <mount>:
SYSCALL(mount)
 40a:	b8 16 00 00 00       	mov    $0x16,%eax
 40f:	cd 40                	int    $0x40
 411:	c3                   	ret    

00000412 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 412:	55                   	push   %ebp
 413:	89 e5                	mov    %esp,%ebp
 415:	83 ec 18             	sub    $0x18,%esp
 418:	8b 45 0c             	mov    0xc(%ebp),%eax
 41b:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 41e:	83 ec 04             	sub    $0x4,%esp
 421:	6a 01                	push   $0x1
 423:	8d 45 f4             	lea    -0xc(%ebp),%eax
 426:	50                   	push   %eax
 427:	ff 75 08             	pushl  0x8(%ebp)
 42a:	e8 5b ff ff ff       	call   38a <write>
 42f:	83 c4 10             	add    $0x10,%esp
}
 432:	90                   	nop
 433:	c9                   	leave  
 434:	c3                   	ret    

00000435 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 435:	55                   	push   %ebp
 436:	89 e5                	mov    %esp,%ebp
 438:	53                   	push   %ebx
 439:	83 ec 24             	sub    $0x24,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 43c:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 443:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 447:	74 17                	je     460 <printint+0x2b>
 449:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 44d:	79 11                	jns    460 <printint+0x2b>
    neg = 1;
 44f:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 456:	8b 45 0c             	mov    0xc(%ebp),%eax
 459:	f7 d8                	neg    %eax
 45b:	89 45 ec             	mov    %eax,-0x14(%ebp)
 45e:	eb 06                	jmp    466 <printint+0x31>
  } else {
    x = xx;
 460:	8b 45 0c             	mov    0xc(%ebp),%eax
 463:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 466:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 46d:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 470:	8d 41 01             	lea    0x1(%ecx),%eax
 473:	89 45 f4             	mov    %eax,-0xc(%ebp)
 476:	8b 5d 10             	mov    0x10(%ebp),%ebx
 479:	8b 45 ec             	mov    -0x14(%ebp),%eax
 47c:	ba 00 00 00 00       	mov    $0x0,%edx
 481:	f7 f3                	div    %ebx
 483:	89 d0                	mov    %edx,%eax
 485:	0f b6 80 54 0b 00 00 	movzbl 0xb54(%eax),%eax
 48c:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 490:	8b 5d 10             	mov    0x10(%ebp),%ebx
 493:	8b 45 ec             	mov    -0x14(%ebp),%eax
 496:	ba 00 00 00 00       	mov    $0x0,%edx
 49b:	f7 f3                	div    %ebx
 49d:	89 45 ec             	mov    %eax,-0x14(%ebp)
 4a0:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 4a4:	75 c7                	jne    46d <printint+0x38>
  if(neg)
 4a6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 4aa:	74 2d                	je     4d9 <printint+0xa4>
    buf[i++] = '-';
 4ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4af:	8d 50 01             	lea    0x1(%eax),%edx
 4b2:	89 55 f4             	mov    %edx,-0xc(%ebp)
 4b5:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 4ba:	eb 1d                	jmp    4d9 <printint+0xa4>
    putc(fd, buf[i]);
 4bc:	8d 55 dc             	lea    -0x24(%ebp),%edx
 4bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4c2:	01 d0                	add    %edx,%eax
 4c4:	0f b6 00             	movzbl (%eax),%eax
 4c7:	0f be c0             	movsbl %al,%eax
 4ca:	83 ec 08             	sub    $0x8,%esp
 4cd:	50                   	push   %eax
 4ce:	ff 75 08             	pushl  0x8(%ebp)
 4d1:	e8 3c ff ff ff       	call   412 <putc>
 4d6:	83 c4 10             	add    $0x10,%esp
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 4d9:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 4dd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 4e1:	79 d9                	jns    4bc <printint+0x87>
    putc(fd, buf[i]);
}
 4e3:	90                   	nop
 4e4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 4e7:	c9                   	leave  
 4e8:	c3                   	ret    

000004e9 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 4e9:	55                   	push   %ebp
 4ea:	89 e5                	mov    %esp,%ebp
 4ec:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 4ef:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 4f6:	8d 45 0c             	lea    0xc(%ebp),%eax
 4f9:	83 c0 04             	add    $0x4,%eax
 4fc:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 4ff:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 506:	e9 59 01 00 00       	jmp    664 <printf+0x17b>
    c = fmt[i] & 0xff;
 50b:	8b 55 0c             	mov    0xc(%ebp),%edx
 50e:	8b 45 f0             	mov    -0x10(%ebp),%eax
 511:	01 d0                	add    %edx,%eax
 513:	0f b6 00             	movzbl (%eax),%eax
 516:	0f be c0             	movsbl %al,%eax
 519:	25 ff 00 00 00       	and    $0xff,%eax
 51e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 521:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 525:	75 2c                	jne    553 <printf+0x6a>
      if(c == '%'){
 527:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 52b:	75 0c                	jne    539 <printf+0x50>
        state = '%';
 52d:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 534:	e9 27 01 00 00       	jmp    660 <printf+0x177>
      } else {
        putc(fd, c);
 539:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 53c:	0f be c0             	movsbl %al,%eax
 53f:	83 ec 08             	sub    $0x8,%esp
 542:	50                   	push   %eax
 543:	ff 75 08             	pushl  0x8(%ebp)
 546:	e8 c7 fe ff ff       	call   412 <putc>
 54b:	83 c4 10             	add    $0x10,%esp
 54e:	e9 0d 01 00 00       	jmp    660 <printf+0x177>
      }
    } else if(state == '%'){
 553:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 557:	0f 85 03 01 00 00    	jne    660 <printf+0x177>
      if(c == 'd'){
 55d:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 561:	75 1e                	jne    581 <printf+0x98>
        printint(fd, *ap, 10, 1);
 563:	8b 45 e8             	mov    -0x18(%ebp),%eax
 566:	8b 00                	mov    (%eax),%eax
 568:	6a 01                	push   $0x1
 56a:	6a 0a                	push   $0xa
 56c:	50                   	push   %eax
 56d:	ff 75 08             	pushl  0x8(%ebp)
 570:	e8 c0 fe ff ff       	call   435 <printint>
 575:	83 c4 10             	add    $0x10,%esp
        ap++;
 578:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 57c:	e9 d8 00 00 00       	jmp    659 <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 581:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 585:	74 06                	je     58d <printf+0xa4>
 587:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 58b:	75 1e                	jne    5ab <printf+0xc2>
        printint(fd, *ap, 16, 0);
 58d:	8b 45 e8             	mov    -0x18(%ebp),%eax
 590:	8b 00                	mov    (%eax),%eax
 592:	6a 00                	push   $0x0
 594:	6a 10                	push   $0x10
 596:	50                   	push   %eax
 597:	ff 75 08             	pushl  0x8(%ebp)
 59a:	e8 96 fe ff ff       	call   435 <printint>
 59f:	83 c4 10             	add    $0x10,%esp
        ap++;
 5a2:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 5a6:	e9 ae 00 00 00       	jmp    659 <printf+0x170>
      } else if(c == 's'){
 5ab:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 5af:	75 43                	jne    5f4 <printf+0x10b>
        s = (char*)*ap;
 5b1:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5b4:	8b 00                	mov    (%eax),%eax
 5b6:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 5b9:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 5bd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 5c1:	75 25                	jne    5e8 <printf+0xff>
          s = "(null)";
 5c3:	c7 45 f4 fd 08 00 00 	movl   $0x8fd,-0xc(%ebp)
        while(*s != 0){
 5ca:	eb 1c                	jmp    5e8 <printf+0xff>
          putc(fd, *s);
 5cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5cf:	0f b6 00             	movzbl (%eax),%eax
 5d2:	0f be c0             	movsbl %al,%eax
 5d5:	83 ec 08             	sub    $0x8,%esp
 5d8:	50                   	push   %eax
 5d9:	ff 75 08             	pushl  0x8(%ebp)
 5dc:	e8 31 fe ff ff       	call   412 <putc>
 5e1:	83 c4 10             	add    $0x10,%esp
          s++;
 5e4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 5e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5eb:	0f b6 00             	movzbl (%eax),%eax
 5ee:	84 c0                	test   %al,%al
 5f0:	75 da                	jne    5cc <printf+0xe3>
 5f2:	eb 65                	jmp    659 <printf+0x170>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 5f4:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 5f8:	75 1d                	jne    617 <printf+0x12e>
        putc(fd, *ap);
 5fa:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5fd:	8b 00                	mov    (%eax),%eax
 5ff:	0f be c0             	movsbl %al,%eax
 602:	83 ec 08             	sub    $0x8,%esp
 605:	50                   	push   %eax
 606:	ff 75 08             	pushl  0x8(%ebp)
 609:	e8 04 fe ff ff       	call   412 <putc>
 60e:	83 c4 10             	add    $0x10,%esp
        ap++;
 611:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 615:	eb 42                	jmp    659 <printf+0x170>
      } else if(c == '%'){
 617:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 61b:	75 17                	jne    634 <printf+0x14b>
        putc(fd, c);
 61d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 620:	0f be c0             	movsbl %al,%eax
 623:	83 ec 08             	sub    $0x8,%esp
 626:	50                   	push   %eax
 627:	ff 75 08             	pushl  0x8(%ebp)
 62a:	e8 e3 fd ff ff       	call   412 <putc>
 62f:	83 c4 10             	add    $0x10,%esp
 632:	eb 25                	jmp    659 <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 634:	83 ec 08             	sub    $0x8,%esp
 637:	6a 25                	push   $0x25
 639:	ff 75 08             	pushl  0x8(%ebp)
 63c:	e8 d1 fd ff ff       	call   412 <putc>
 641:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 644:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 647:	0f be c0             	movsbl %al,%eax
 64a:	83 ec 08             	sub    $0x8,%esp
 64d:	50                   	push   %eax
 64e:	ff 75 08             	pushl  0x8(%ebp)
 651:	e8 bc fd ff ff       	call   412 <putc>
 656:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 659:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 660:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 664:	8b 55 0c             	mov    0xc(%ebp),%edx
 667:	8b 45 f0             	mov    -0x10(%ebp),%eax
 66a:	01 d0                	add    %edx,%eax
 66c:	0f b6 00             	movzbl (%eax),%eax
 66f:	84 c0                	test   %al,%al
 671:	0f 85 94 fe ff ff    	jne    50b <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 677:	90                   	nop
 678:	c9                   	leave  
 679:	c3                   	ret    

0000067a <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 67a:	55                   	push   %ebp
 67b:	89 e5                	mov    %esp,%ebp
 67d:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 680:	8b 45 08             	mov    0x8(%ebp),%eax
 683:	83 e8 08             	sub    $0x8,%eax
 686:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 689:	a1 70 0b 00 00       	mov    0xb70,%eax
 68e:	89 45 fc             	mov    %eax,-0x4(%ebp)
 691:	eb 24                	jmp    6b7 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 693:	8b 45 fc             	mov    -0x4(%ebp),%eax
 696:	8b 00                	mov    (%eax),%eax
 698:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 69b:	77 12                	ja     6af <free+0x35>
 69d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6a0:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 6a3:	77 24                	ja     6c9 <free+0x4f>
 6a5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6a8:	8b 00                	mov    (%eax),%eax
 6aa:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 6ad:	77 1a                	ja     6c9 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6af:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6b2:	8b 00                	mov    (%eax),%eax
 6b4:	89 45 fc             	mov    %eax,-0x4(%ebp)
 6b7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6ba:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 6bd:	76 d4                	jbe    693 <free+0x19>
 6bf:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6c2:	8b 00                	mov    (%eax),%eax
 6c4:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 6c7:	76 ca                	jbe    693 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 6c9:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6cc:	8b 40 04             	mov    0x4(%eax),%eax
 6cf:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 6d6:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6d9:	01 c2                	add    %eax,%edx
 6db:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6de:	8b 00                	mov    (%eax),%eax
 6e0:	39 c2                	cmp    %eax,%edx
 6e2:	75 24                	jne    708 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 6e4:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6e7:	8b 50 04             	mov    0x4(%eax),%edx
 6ea:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6ed:	8b 00                	mov    (%eax),%eax
 6ef:	8b 40 04             	mov    0x4(%eax),%eax
 6f2:	01 c2                	add    %eax,%edx
 6f4:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6f7:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 6fa:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6fd:	8b 00                	mov    (%eax),%eax
 6ff:	8b 10                	mov    (%eax),%edx
 701:	8b 45 f8             	mov    -0x8(%ebp),%eax
 704:	89 10                	mov    %edx,(%eax)
 706:	eb 0a                	jmp    712 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 708:	8b 45 fc             	mov    -0x4(%ebp),%eax
 70b:	8b 10                	mov    (%eax),%edx
 70d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 710:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 712:	8b 45 fc             	mov    -0x4(%ebp),%eax
 715:	8b 40 04             	mov    0x4(%eax),%eax
 718:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 71f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 722:	01 d0                	add    %edx,%eax
 724:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 727:	75 20                	jne    749 <free+0xcf>
    p->s.size += bp->s.size;
 729:	8b 45 fc             	mov    -0x4(%ebp),%eax
 72c:	8b 50 04             	mov    0x4(%eax),%edx
 72f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 732:	8b 40 04             	mov    0x4(%eax),%eax
 735:	01 c2                	add    %eax,%edx
 737:	8b 45 fc             	mov    -0x4(%ebp),%eax
 73a:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 73d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 740:	8b 10                	mov    (%eax),%edx
 742:	8b 45 fc             	mov    -0x4(%ebp),%eax
 745:	89 10                	mov    %edx,(%eax)
 747:	eb 08                	jmp    751 <free+0xd7>
  } else
    p->s.ptr = bp;
 749:	8b 45 fc             	mov    -0x4(%ebp),%eax
 74c:	8b 55 f8             	mov    -0x8(%ebp),%edx
 74f:	89 10                	mov    %edx,(%eax)
  freep = p;
 751:	8b 45 fc             	mov    -0x4(%ebp),%eax
 754:	a3 70 0b 00 00       	mov    %eax,0xb70
}
 759:	90                   	nop
 75a:	c9                   	leave  
 75b:	c3                   	ret    

0000075c <morecore>:

static Header*
morecore(uint nu)
{
 75c:	55                   	push   %ebp
 75d:	89 e5                	mov    %esp,%ebp
 75f:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 762:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 769:	77 07                	ja     772 <morecore+0x16>
    nu = 4096;
 76b:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 772:	8b 45 08             	mov    0x8(%ebp),%eax
 775:	c1 e0 03             	shl    $0x3,%eax
 778:	83 ec 0c             	sub    $0xc,%esp
 77b:	50                   	push   %eax
 77c:	e8 71 fc ff ff       	call   3f2 <sbrk>
 781:	83 c4 10             	add    $0x10,%esp
 784:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 787:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 78b:	75 07                	jne    794 <morecore+0x38>
    return 0;
 78d:	b8 00 00 00 00       	mov    $0x0,%eax
 792:	eb 26                	jmp    7ba <morecore+0x5e>
  hp = (Header*)p;
 794:	8b 45 f4             	mov    -0xc(%ebp),%eax
 797:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 79a:	8b 45 f0             	mov    -0x10(%ebp),%eax
 79d:	8b 55 08             	mov    0x8(%ebp),%edx
 7a0:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 7a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7a6:	83 c0 08             	add    $0x8,%eax
 7a9:	83 ec 0c             	sub    $0xc,%esp
 7ac:	50                   	push   %eax
 7ad:	e8 c8 fe ff ff       	call   67a <free>
 7b2:	83 c4 10             	add    $0x10,%esp
  return freep;
 7b5:	a1 70 0b 00 00       	mov    0xb70,%eax
}
 7ba:	c9                   	leave  
 7bb:	c3                   	ret    

000007bc <malloc>:

void*
malloc(uint nbytes)
{
 7bc:	55                   	push   %ebp
 7bd:	89 e5                	mov    %esp,%ebp
 7bf:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 7c2:	8b 45 08             	mov    0x8(%ebp),%eax
 7c5:	83 c0 07             	add    $0x7,%eax
 7c8:	c1 e8 03             	shr    $0x3,%eax
 7cb:	83 c0 01             	add    $0x1,%eax
 7ce:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 7d1:	a1 70 0b 00 00       	mov    0xb70,%eax
 7d6:	89 45 f0             	mov    %eax,-0x10(%ebp)
 7d9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 7dd:	75 23                	jne    802 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 7df:	c7 45 f0 68 0b 00 00 	movl   $0xb68,-0x10(%ebp)
 7e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7e9:	a3 70 0b 00 00       	mov    %eax,0xb70
 7ee:	a1 70 0b 00 00       	mov    0xb70,%eax
 7f3:	a3 68 0b 00 00       	mov    %eax,0xb68
    base.s.size = 0;
 7f8:	c7 05 6c 0b 00 00 00 	movl   $0x0,0xb6c
 7ff:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 802:	8b 45 f0             	mov    -0x10(%ebp),%eax
 805:	8b 00                	mov    (%eax),%eax
 807:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 80a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 80d:	8b 40 04             	mov    0x4(%eax),%eax
 810:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 813:	72 4d                	jb     862 <malloc+0xa6>
      if(p->s.size == nunits)
 815:	8b 45 f4             	mov    -0xc(%ebp),%eax
 818:	8b 40 04             	mov    0x4(%eax),%eax
 81b:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 81e:	75 0c                	jne    82c <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 820:	8b 45 f4             	mov    -0xc(%ebp),%eax
 823:	8b 10                	mov    (%eax),%edx
 825:	8b 45 f0             	mov    -0x10(%ebp),%eax
 828:	89 10                	mov    %edx,(%eax)
 82a:	eb 26                	jmp    852 <malloc+0x96>
      else {
        p->s.size -= nunits;
 82c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 82f:	8b 40 04             	mov    0x4(%eax),%eax
 832:	2b 45 ec             	sub    -0x14(%ebp),%eax
 835:	89 c2                	mov    %eax,%edx
 837:	8b 45 f4             	mov    -0xc(%ebp),%eax
 83a:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 83d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 840:	8b 40 04             	mov    0x4(%eax),%eax
 843:	c1 e0 03             	shl    $0x3,%eax
 846:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 849:	8b 45 f4             	mov    -0xc(%ebp),%eax
 84c:	8b 55 ec             	mov    -0x14(%ebp),%edx
 84f:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 852:	8b 45 f0             	mov    -0x10(%ebp),%eax
 855:	a3 70 0b 00 00       	mov    %eax,0xb70
      return (void*)(p + 1);
 85a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 85d:	83 c0 08             	add    $0x8,%eax
 860:	eb 3b                	jmp    89d <malloc+0xe1>
    }
    if(p == freep)
 862:	a1 70 0b 00 00       	mov    0xb70,%eax
 867:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 86a:	75 1e                	jne    88a <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 86c:	83 ec 0c             	sub    $0xc,%esp
 86f:	ff 75 ec             	pushl  -0x14(%ebp)
 872:	e8 e5 fe ff ff       	call   75c <morecore>
 877:	83 c4 10             	add    $0x10,%esp
 87a:	89 45 f4             	mov    %eax,-0xc(%ebp)
 87d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 881:	75 07                	jne    88a <malloc+0xce>
        return 0;
 883:	b8 00 00 00 00       	mov    $0x0,%eax
 888:	eb 13                	jmp    89d <malloc+0xe1>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 88a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 88d:	89 45 f0             	mov    %eax,-0x10(%ebp)
 890:	8b 45 f4             	mov    -0xc(%ebp),%eax
 893:	8b 00                	mov    (%eax),%eax
 895:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 898:	e9 6d ff ff ff       	jmp    80a <malloc+0x4e>
}
 89d:	c9                   	leave  
 89e:	c3                   	ret    
