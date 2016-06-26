
_sh:     file format elf32-i386


Disassembly of section .text:

00000000 <runcmd>:
struct cmd *parsecmd(char*);

// Execute cmd.  Never returns.
void
runcmd(struct cmd *cmd)
{
       0:	55                   	push   %ebp
       1:	89 e5                	mov    %esp,%ebp
       3:	83 ec 28             	sub    $0x28,%esp
  struct execcmd *ecmd;
  struct listcmd *lcmd;
  struct pipecmd *pcmd;
  struct redircmd *rcmd;

  if(cmd == 0)
       6:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
       a:	75 05                	jne    11 <runcmd+0x11>
    exit();
       c:	e8 c7 0e 00 00       	call   ed8 <exit>
  
  switch(cmd->type){
      11:	8b 45 08             	mov    0x8(%ebp),%eax
      14:	8b 00                	mov    (%eax),%eax
      16:	83 f8 05             	cmp    $0x5,%eax
      19:	77 09                	ja     24 <runcmd+0x24>
      1b:	8b 04 85 48 14 00 00 	mov    0x1448(,%eax,4),%eax
      22:	ff e0                	jmp    *%eax
  default:
    panic("runcmd");
      24:	83 ec 0c             	sub    $0xc,%esp
      27:	68 10 14 00 00       	push   $0x1410
      2c:	e8 6e 03 00 00       	call   39f <panic>
      31:	83 c4 10             	add    $0x10,%esp

  case EXEC:
    ecmd = (struct execcmd*)cmd;
      34:	8b 45 08             	mov    0x8(%ebp),%eax
      37:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ecmd->argv[0] == 0)
      3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
      3d:	8b 40 04             	mov    0x4(%eax),%eax
      40:	85 c0                	test   %eax,%eax
      42:	75 05                	jne    49 <runcmd+0x49>
      exit();
      44:	e8 8f 0e 00 00       	call   ed8 <exit>
    int val=exec(ecmd->argv[0], ecmd->argv);
      49:	8b 45 f4             	mov    -0xc(%ebp),%eax
      4c:	8d 50 04             	lea    0x4(%eax),%edx
      4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
      52:	8b 40 04             	mov    0x4(%eax),%eax
      55:	83 ec 08             	sub    $0x8,%esp
      58:	52                   	push   %edx
      59:	50                   	push   %eax
      5a:	e8 b1 0e 00 00       	call   f10 <exec>
      5f:	83 c4 10             	add    $0x10,%esp
      62:	89 45 f0             	mov    %eax,-0x10(%ebp)
    printf(2, "exec %s failed with val %d\n", ecmd->argv[0],val);
      65:	8b 45 f4             	mov    -0xc(%ebp),%eax
      68:	8b 40 04             	mov    0x4(%eax),%eax
      6b:	ff 75 f0             	pushl  -0x10(%ebp)
      6e:	50                   	push   %eax
      6f:	68 17 14 00 00       	push   $0x1417
      74:	6a 02                	push   $0x2
      76:	e8 dc 0f 00 00       	call   1057 <printf>
      7b:	83 c4 10             	add    $0x10,%esp
    break;
      7e:	e9 c6 01 00 00       	jmp    249 <runcmd+0x249>

  case REDIR:
    rcmd = (struct redircmd*)cmd;
      83:	8b 45 08             	mov    0x8(%ebp),%eax
      86:	89 45 ec             	mov    %eax,-0x14(%ebp)
    close(rcmd->fd);
      89:	8b 45 ec             	mov    -0x14(%ebp),%eax
      8c:	8b 40 14             	mov    0x14(%eax),%eax
      8f:	83 ec 0c             	sub    $0xc,%esp
      92:	50                   	push   %eax
      93:	e8 68 0e 00 00       	call   f00 <close>
      98:	83 c4 10             	add    $0x10,%esp
    if(open(rcmd->file, rcmd->mode) < 0){
      9b:	8b 45 ec             	mov    -0x14(%ebp),%eax
      9e:	8b 50 10             	mov    0x10(%eax),%edx
      a1:	8b 45 ec             	mov    -0x14(%ebp),%eax
      a4:	8b 40 08             	mov    0x8(%eax),%eax
      a7:	83 ec 08             	sub    $0x8,%esp
      aa:	52                   	push   %edx
      ab:	50                   	push   %eax
      ac:	e8 67 0e 00 00       	call   f18 <open>
      b1:	83 c4 10             	add    $0x10,%esp
      b4:	85 c0                	test   %eax,%eax
      b6:	79 1e                	jns    d6 <runcmd+0xd6>
      printf(2, "open %s failed\n", rcmd->file);
      b8:	8b 45 ec             	mov    -0x14(%ebp),%eax
      bb:	8b 40 08             	mov    0x8(%eax),%eax
      be:	83 ec 04             	sub    $0x4,%esp
      c1:	50                   	push   %eax
      c2:	68 33 14 00 00       	push   $0x1433
      c7:	6a 02                	push   $0x2
      c9:	e8 89 0f 00 00       	call   1057 <printf>
      ce:	83 c4 10             	add    $0x10,%esp
      exit();
      d1:	e8 02 0e 00 00       	call   ed8 <exit>
    }
    runcmd(rcmd->cmd);
      d6:	8b 45 ec             	mov    -0x14(%ebp),%eax
      d9:	8b 40 04             	mov    0x4(%eax),%eax
      dc:	83 ec 0c             	sub    $0xc,%esp
      df:	50                   	push   %eax
      e0:	e8 1b ff ff ff       	call   0 <runcmd>
      e5:	83 c4 10             	add    $0x10,%esp
    break;
      e8:	e9 5c 01 00 00       	jmp    249 <runcmd+0x249>

  case LIST:
    lcmd = (struct listcmd*)cmd;
      ed:	8b 45 08             	mov    0x8(%ebp),%eax
      f0:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(fork1() == 0)
      f3:	e8 c7 02 00 00       	call   3bf <fork1>
      f8:	85 c0                	test   %eax,%eax
      fa:	75 12                	jne    10e <runcmd+0x10e>
      runcmd(lcmd->left);
      fc:	8b 45 e8             	mov    -0x18(%ebp),%eax
      ff:	8b 40 04             	mov    0x4(%eax),%eax
     102:	83 ec 0c             	sub    $0xc,%esp
     105:	50                   	push   %eax
     106:	e8 f5 fe ff ff       	call   0 <runcmd>
     10b:	83 c4 10             	add    $0x10,%esp
    wait();
     10e:	e8 cd 0d 00 00       	call   ee0 <wait>
    runcmd(lcmd->right);
     113:	8b 45 e8             	mov    -0x18(%ebp),%eax
     116:	8b 40 08             	mov    0x8(%eax),%eax
     119:	83 ec 0c             	sub    $0xc,%esp
     11c:	50                   	push   %eax
     11d:	e8 de fe ff ff       	call   0 <runcmd>
     122:	83 c4 10             	add    $0x10,%esp
    break;
     125:	e9 1f 01 00 00       	jmp    249 <runcmd+0x249>

  case PIPE:
    pcmd = (struct pipecmd*)cmd;
     12a:	8b 45 08             	mov    0x8(%ebp),%eax
     12d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(pipe(p) < 0)
     130:	83 ec 0c             	sub    $0xc,%esp
     133:	8d 45 d8             	lea    -0x28(%ebp),%eax
     136:	50                   	push   %eax
     137:	e8 ac 0d 00 00       	call   ee8 <pipe>
     13c:	83 c4 10             	add    $0x10,%esp
     13f:	85 c0                	test   %eax,%eax
     141:	79 10                	jns    153 <runcmd+0x153>
      panic("pipe");
     143:	83 ec 0c             	sub    $0xc,%esp
     146:	68 43 14 00 00       	push   $0x1443
     14b:	e8 4f 02 00 00       	call   39f <panic>
     150:	83 c4 10             	add    $0x10,%esp
    if(fork1() == 0){
     153:	e8 67 02 00 00       	call   3bf <fork1>
     158:	85 c0                	test   %eax,%eax
     15a:	75 4c                	jne    1a8 <runcmd+0x1a8>
      close(1);
     15c:	83 ec 0c             	sub    $0xc,%esp
     15f:	6a 01                	push   $0x1
     161:	e8 9a 0d 00 00       	call   f00 <close>
     166:	83 c4 10             	add    $0x10,%esp
      dup(p[1]);
     169:	8b 45 dc             	mov    -0x24(%ebp),%eax
     16c:	83 ec 0c             	sub    $0xc,%esp
     16f:	50                   	push   %eax
     170:	e8 db 0d 00 00       	call   f50 <dup>
     175:	83 c4 10             	add    $0x10,%esp
      close(p[0]);
     178:	8b 45 d8             	mov    -0x28(%ebp),%eax
     17b:	83 ec 0c             	sub    $0xc,%esp
     17e:	50                   	push   %eax
     17f:	e8 7c 0d 00 00       	call   f00 <close>
     184:	83 c4 10             	add    $0x10,%esp
      close(p[1]);
     187:	8b 45 dc             	mov    -0x24(%ebp),%eax
     18a:	83 ec 0c             	sub    $0xc,%esp
     18d:	50                   	push   %eax
     18e:	e8 6d 0d 00 00       	call   f00 <close>
     193:	83 c4 10             	add    $0x10,%esp
      runcmd(pcmd->left);
     196:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     199:	8b 40 04             	mov    0x4(%eax),%eax
     19c:	83 ec 0c             	sub    $0xc,%esp
     19f:	50                   	push   %eax
     1a0:	e8 5b fe ff ff       	call   0 <runcmd>
     1a5:	83 c4 10             	add    $0x10,%esp
    }
    if(fork1() == 0){
     1a8:	e8 12 02 00 00       	call   3bf <fork1>
     1ad:	85 c0                	test   %eax,%eax
     1af:	75 4c                	jne    1fd <runcmd+0x1fd>
      close(0);
     1b1:	83 ec 0c             	sub    $0xc,%esp
     1b4:	6a 00                	push   $0x0
     1b6:	e8 45 0d 00 00       	call   f00 <close>
     1bb:	83 c4 10             	add    $0x10,%esp
      dup(p[0]);
     1be:	8b 45 d8             	mov    -0x28(%ebp),%eax
     1c1:	83 ec 0c             	sub    $0xc,%esp
     1c4:	50                   	push   %eax
     1c5:	e8 86 0d 00 00       	call   f50 <dup>
     1ca:	83 c4 10             	add    $0x10,%esp
      close(p[0]);
     1cd:	8b 45 d8             	mov    -0x28(%ebp),%eax
     1d0:	83 ec 0c             	sub    $0xc,%esp
     1d3:	50                   	push   %eax
     1d4:	e8 27 0d 00 00       	call   f00 <close>
     1d9:	83 c4 10             	add    $0x10,%esp
      close(p[1]);
     1dc:	8b 45 dc             	mov    -0x24(%ebp),%eax
     1df:	83 ec 0c             	sub    $0xc,%esp
     1e2:	50                   	push   %eax
     1e3:	e8 18 0d 00 00       	call   f00 <close>
     1e8:	83 c4 10             	add    $0x10,%esp
      runcmd(pcmd->right);
     1eb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     1ee:	8b 40 08             	mov    0x8(%eax),%eax
     1f1:	83 ec 0c             	sub    $0xc,%esp
     1f4:	50                   	push   %eax
     1f5:	e8 06 fe ff ff       	call   0 <runcmd>
     1fa:	83 c4 10             	add    $0x10,%esp
    }
    close(p[0]);
     1fd:	8b 45 d8             	mov    -0x28(%ebp),%eax
     200:	83 ec 0c             	sub    $0xc,%esp
     203:	50                   	push   %eax
     204:	e8 f7 0c 00 00       	call   f00 <close>
     209:	83 c4 10             	add    $0x10,%esp
    close(p[1]);
     20c:	8b 45 dc             	mov    -0x24(%ebp),%eax
     20f:	83 ec 0c             	sub    $0xc,%esp
     212:	50                   	push   %eax
     213:	e8 e8 0c 00 00       	call   f00 <close>
     218:	83 c4 10             	add    $0x10,%esp
    wait();
     21b:	e8 c0 0c 00 00       	call   ee0 <wait>
    wait();
     220:	e8 bb 0c 00 00       	call   ee0 <wait>
    break;
     225:	eb 22                	jmp    249 <runcmd+0x249>
    
  case BACK:
    bcmd = (struct backcmd*)cmd;
     227:	8b 45 08             	mov    0x8(%ebp),%eax
     22a:	89 45 e0             	mov    %eax,-0x20(%ebp)
    if(fork1() == 0)
     22d:	e8 8d 01 00 00       	call   3bf <fork1>
     232:	85 c0                	test   %eax,%eax
     234:	75 12                	jne    248 <runcmd+0x248>
      runcmd(bcmd->cmd);
     236:	8b 45 e0             	mov    -0x20(%ebp),%eax
     239:	8b 40 04             	mov    0x4(%eax),%eax
     23c:	83 ec 0c             	sub    $0xc,%esp
     23f:	50                   	push   %eax
     240:	e8 bb fd ff ff       	call   0 <runcmd>
     245:	83 c4 10             	add    $0x10,%esp
    break;
     248:	90                   	nop
  }
  exit();
     249:	e8 8a 0c 00 00       	call   ed8 <exit>

0000024e <getcmd>:
}

int
getcmd(char *buf, int nbuf)
{
     24e:	55                   	push   %ebp
     24f:	89 e5                	mov    %esp,%ebp
     251:	83 ec 08             	sub    $0x8,%esp
  printf(2, "$ ");
     254:	83 ec 08             	sub    $0x8,%esp
     257:	68 60 14 00 00       	push   $0x1460
     25c:	6a 02                	push   $0x2
     25e:	e8 f4 0d 00 00       	call   1057 <printf>
     263:	83 c4 10             	add    $0x10,%esp
  memset(buf, 0, nbuf);
     266:	8b 45 0c             	mov    0xc(%ebp),%eax
     269:	83 ec 04             	sub    $0x4,%esp
     26c:	50                   	push   %eax
     26d:	6a 00                	push   $0x0
     26f:	ff 75 08             	pushl  0x8(%ebp)
     272:	e8 c6 0a 00 00       	call   d3d <memset>
     277:	83 c4 10             	add    $0x10,%esp
  gets(buf, nbuf);
     27a:	83 ec 08             	sub    $0x8,%esp
     27d:	ff 75 0c             	pushl  0xc(%ebp)
     280:	ff 75 08             	pushl  0x8(%ebp)
     283:	e8 02 0b 00 00       	call   d8a <gets>
     288:	83 c4 10             	add    $0x10,%esp
  if(buf[0] == 0) // EOF
     28b:	8b 45 08             	mov    0x8(%ebp),%eax
     28e:	0f b6 00             	movzbl (%eax),%eax
     291:	84 c0                	test   %al,%al
     293:	75 07                	jne    29c <getcmd+0x4e>
    return -1;
     295:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
     29a:	eb 05                	jmp    2a1 <getcmd+0x53>
  return 0;
     29c:	b8 00 00 00 00       	mov    $0x0,%eax
}
     2a1:	c9                   	leave  
     2a2:	c3                   	ret    

000002a3 <main>:

int
main(void)
{
     2a3:	8d 4c 24 04          	lea    0x4(%esp),%ecx
     2a7:	83 e4 f0             	and    $0xfffffff0,%esp
     2aa:	ff 71 fc             	pushl  -0x4(%ecx)
     2ad:	55                   	push   %ebp
     2ae:	89 e5                	mov    %esp,%ebp
     2b0:	51                   	push   %ecx
     2b1:	83 ec 14             	sub    $0x14,%esp
  static char buf[100];
  int fd;
  
  // Assumes three file descriptors open.
  while((fd = open("console", O_RDWR)) >= 0){
     2b4:	eb 16                	jmp    2cc <main+0x29>
    if(fd >= 3){
     2b6:	83 7d f4 02          	cmpl   $0x2,-0xc(%ebp)
     2ba:	7e 10                	jle    2cc <main+0x29>
      close(fd);
     2bc:	83 ec 0c             	sub    $0xc,%esp
     2bf:	ff 75 f4             	pushl  -0xc(%ebp)
     2c2:	e8 39 0c 00 00       	call   f00 <close>
     2c7:	83 c4 10             	add    $0x10,%esp
      break;
     2ca:	eb 1b                	jmp    2e7 <main+0x44>
{
  static char buf[100];
  int fd;
  
  // Assumes three file descriptors open.
  while((fd = open("console", O_RDWR)) >= 0){
     2cc:	83 ec 08             	sub    $0x8,%esp
     2cf:	6a 02                	push   $0x2
     2d1:	68 63 14 00 00       	push   $0x1463
     2d6:	e8 3d 0c 00 00       	call   f18 <open>
     2db:	83 c4 10             	add    $0x10,%esp
     2de:	89 45 f4             	mov    %eax,-0xc(%ebp)
     2e1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
     2e5:	79 cf                	jns    2b6 <main+0x13>
      break;
    }
  }
  
  // Read and run input commands.
  while(getcmd(buf, sizeof(buf)) >= 0){
     2e7:	e9 94 00 00 00       	jmp    380 <main+0xdd>
    if(buf[0] == 'c' && buf[1] == 'd' && buf[2] == ' '){
     2ec:	0f b6 05 c0 19 00 00 	movzbl 0x19c0,%eax
     2f3:	3c 63                	cmp    $0x63,%al
     2f5:	75 5f                	jne    356 <main+0xb3>
     2f7:	0f b6 05 c1 19 00 00 	movzbl 0x19c1,%eax
     2fe:	3c 64                	cmp    $0x64,%al
     300:	75 54                	jne    356 <main+0xb3>
     302:	0f b6 05 c2 19 00 00 	movzbl 0x19c2,%eax
     309:	3c 20                	cmp    $0x20,%al
     30b:	75 49                	jne    356 <main+0xb3>
      // Clumsy but will have to do for now.
      // Chdir has no effect on the parent if run in the child.
      buf[strlen(buf)-1] = 0;  // chop \n
     30d:	83 ec 0c             	sub    $0xc,%esp
     310:	68 c0 19 00 00       	push   $0x19c0
     315:	e8 fc 09 00 00       	call   d16 <strlen>
     31a:	83 c4 10             	add    $0x10,%esp
     31d:	83 e8 01             	sub    $0x1,%eax
     320:	c6 80 c0 19 00 00 00 	movb   $0x0,0x19c0(%eax)
      if(chdir(buf+3) < 0)
     327:	b8 c3 19 00 00       	mov    $0x19c3,%eax
     32c:	83 ec 0c             	sub    $0xc,%esp
     32f:	50                   	push   %eax
     330:	e8 13 0c 00 00       	call   f48 <chdir>
     335:	83 c4 10             	add    $0x10,%esp
     338:	85 c0                	test   %eax,%eax
     33a:	79 44                	jns    380 <main+0xdd>
        printf(2, "cannot cd %s\n", buf+3);
     33c:	b8 c3 19 00 00       	mov    $0x19c3,%eax
     341:	83 ec 04             	sub    $0x4,%esp
     344:	50                   	push   %eax
     345:	68 6b 14 00 00       	push   $0x146b
     34a:	6a 02                	push   $0x2
     34c:	e8 06 0d 00 00       	call   1057 <printf>
     351:	83 c4 10             	add    $0x10,%esp
      continue;
     354:	eb 2a                	jmp    380 <main+0xdd>
    }
    if(fork1() == 0)
     356:	e8 64 00 00 00       	call   3bf <fork1>
     35b:	85 c0                	test   %eax,%eax
     35d:	75 1c                	jne    37b <main+0xd8>
      runcmd(parsecmd(buf));
     35f:	83 ec 0c             	sub    $0xc,%esp
     362:	68 c0 19 00 00       	push   $0x19c0
     367:	e8 ab 03 00 00       	call   717 <parsecmd>
     36c:	83 c4 10             	add    $0x10,%esp
     36f:	83 ec 0c             	sub    $0xc,%esp
     372:	50                   	push   %eax
     373:	e8 88 fc ff ff       	call   0 <runcmd>
     378:	83 c4 10             	add    $0x10,%esp
    wait();
     37b:	e8 60 0b 00 00       	call   ee0 <wait>
      break;
    }
  }
  
  // Read and run input commands.
  while(getcmd(buf, sizeof(buf)) >= 0){
     380:	83 ec 08             	sub    $0x8,%esp
     383:	6a 64                	push   $0x64
     385:	68 c0 19 00 00       	push   $0x19c0
     38a:	e8 bf fe ff ff       	call   24e <getcmd>
     38f:	83 c4 10             	add    $0x10,%esp
     392:	85 c0                	test   %eax,%eax
     394:	0f 89 52 ff ff ff    	jns    2ec <main+0x49>
    }
    if(fork1() == 0)
      runcmd(parsecmd(buf));
    wait();
  }
  exit();
     39a:	e8 39 0b 00 00       	call   ed8 <exit>

0000039f <panic>:
}

void
panic(char *s)
{
     39f:	55                   	push   %ebp
     3a0:	89 e5                	mov    %esp,%ebp
     3a2:	83 ec 08             	sub    $0x8,%esp
  printf(2, "%s\n", s);
     3a5:	83 ec 04             	sub    $0x4,%esp
     3a8:	ff 75 08             	pushl  0x8(%ebp)
     3ab:	68 79 14 00 00       	push   $0x1479
     3b0:	6a 02                	push   $0x2
     3b2:	e8 a0 0c 00 00       	call   1057 <printf>
     3b7:	83 c4 10             	add    $0x10,%esp
  exit();
     3ba:	e8 19 0b 00 00       	call   ed8 <exit>

000003bf <fork1>:
}

int
fork1(void)
{
     3bf:	55                   	push   %ebp
     3c0:	89 e5                	mov    %esp,%ebp
     3c2:	83 ec 18             	sub    $0x18,%esp
  int pid;
  
  pid = fork();
     3c5:	e8 06 0b 00 00       	call   ed0 <fork>
     3ca:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pid == -1)
     3cd:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
     3d1:	75 10                	jne    3e3 <fork1+0x24>
    panic("fork");
     3d3:	83 ec 0c             	sub    $0xc,%esp
     3d6:	68 7d 14 00 00       	push   $0x147d
     3db:	e8 bf ff ff ff       	call   39f <panic>
     3e0:	83 c4 10             	add    $0x10,%esp
  return pid;
     3e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     3e6:	c9                   	leave  
     3e7:	c3                   	ret    

000003e8 <execcmd>:
//PAGEBREAK!
// Constructors

struct cmd*
execcmd(void)
{
     3e8:	55                   	push   %ebp
     3e9:	89 e5                	mov    %esp,%ebp
     3eb:	83 ec 18             	sub    $0x18,%esp
  struct execcmd *cmd;

  cmd = malloc(sizeof(*cmd));
     3ee:	83 ec 0c             	sub    $0xc,%esp
     3f1:	6a 54                	push   $0x54
     3f3:	e8 32 0f 00 00       	call   132a <malloc>
     3f8:	83 c4 10             	add    $0x10,%esp
     3fb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(cmd, 0, sizeof(*cmd));
     3fe:	83 ec 04             	sub    $0x4,%esp
     401:	6a 54                	push   $0x54
     403:	6a 00                	push   $0x0
     405:	ff 75 f4             	pushl  -0xc(%ebp)
     408:	e8 30 09 00 00       	call   d3d <memset>
     40d:	83 c4 10             	add    $0x10,%esp
  cmd->type = EXEC;
     410:	8b 45 f4             	mov    -0xc(%ebp),%eax
     413:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  return (struct cmd*)cmd;
     419:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     41c:	c9                   	leave  
     41d:	c3                   	ret    

0000041e <redircmd>:

struct cmd*
redircmd(struct cmd *subcmd, char *file, char *efile, int mode, int fd)
{
     41e:	55                   	push   %ebp
     41f:	89 e5                	mov    %esp,%ebp
     421:	83 ec 18             	sub    $0x18,%esp
  struct redircmd *cmd;

  cmd = malloc(sizeof(*cmd));
     424:	83 ec 0c             	sub    $0xc,%esp
     427:	6a 18                	push   $0x18
     429:	e8 fc 0e 00 00       	call   132a <malloc>
     42e:	83 c4 10             	add    $0x10,%esp
     431:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(cmd, 0, sizeof(*cmd));
     434:	83 ec 04             	sub    $0x4,%esp
     437:	6a 18                	push   $0x18
     439:	6a 00                	push   $0x0
     43b:	ff 75 f4             	pushl  -0xc(%ebp)
     43e:	e8 fa 08 00 00       	call   d3d <memset>
     443:	83 c4 10             	add    $0x10,%esp
  cmd->type = REDIR;
     446:	8b 45 f4             	mov    -0xc(%ebp),%eax
     449:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  cmd->cmd = subcmd;
     44f:	8b 45 f4             	mov    -0xc(%ebp),%eax
     452:	8b 55 08             	mov    0x8(%ebp),%edx
     455:	89 50 04             	mov    %edx,0x4(%eax)
  cmd->file = file;
     458:	8b 45 f4             	mov    -0xc(%ebp),%eax
     45b:	8b 55 0c             	mov    0xc(%ebp),%edx
     45e:	89 50 08             	mov    %edx,0x8(%eax)
  cmd->efile = efile;
     461:	8b 45 f4             	mov    -0xc(%ebp),%eax
     464:	8b 55 10             	mov    0x10(%ebp),%edx
     467:	89 50 0c             	mov    %edx,0xc(%eax)
  cmd->mode = mode;
     46a:	8b 45 f4             	mov    -0xc(%ebp),%eax
     46d:	8b 55 14             	mov    0x14(%ebp),%edx
     470:	89 50 10             	mov    %edx,0x10(%eax)
  cmd->fd = fd;
     473:	8b 45 f4             	mov    -0xc(%ebp),%eax
     476:	8b 55 18             	mov    0x18(%ebp),%edx
     479:	89 50 14             	mov    %edx,0x14(%eax)
  return (struct cmd*)cmd;
     47c:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     47f:	c9                   	leave  
     480:	c3                   	ret    

00000481 <pipecmd>:

struct cmd*
pipecmd(struct cmd *left, struct cmd *right)
{
     481:	55                   	push   %ebp
     482:	89 e5                	mov    %esp,%ebp
     484:	83 ec 18             	sub    $0x18,%esp
  struct pipecmd *cmd;

  cmd = malloc(sizeof(*cmd));
     487:	83 ec 0c             	sub    $0xc,%esp
     48a:	6a 0c                	push   $0xc
     48c:	e8 99 0e 00 00       	call   132a <malloc>
     491:	83 c4 10             	add    $0x10,%esp
     494:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(cmd, 0, sizeof(*cmd));
     497:	83 ec 04             	sub    $0x4,%esp
     49a:	6a 0c                	push   $0xc
     49c:	6a 00                	push   $0x0
     49e:	ff 75 f4             	pushl  -0xc(%ebp)
     4a1:	e8 97 08 00 00       	call   d3d <memset>
     4a6:	83 c4 10             	add    $0x10,%esp
  cmd->type = PIPE;
     4a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
     4ac:	c7 00 03 00 00 00    	movl   $0x3,(%eax)
  cmd->left = left;
     4b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
     4b5:	8b 55 08             	mov    0x8(%ebp),%edx
     4b8:	89 50 04             	mov    %edx,0x4(%eax)
  cmd->right = right;
     4bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
     4be:	8b 55 0c             	mov    0xc(%ebp),%edx
     4c1:	89 50 08             	mov    %edx,0x8(%eax)
  return (struct cmd*)cmd;
     4c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     4c7:	c9                   	leave  
     4c8:	c3                   	ret    

000004c9 <listcmd>:

struct cmd*
listcmd(struct cmd *left, struct cmd *right)
{
     4c9:	55                   	push   %ebp
     4ca:	89 e5                	mov    %esp,%ebp
     4cc:	83 ec 18             	sub    $0x18,%esp
  struct listcmd *cmd;

  cmd = malloc(sizeof(*cmd));
     4cf:	83 ec 0c             	sub    $0xc,%esp
     4d2:	6a 0c                	push   $0xc
     4d4:	e8 51 0e 00 00       	call   132a <malloc>
     4d9:	83 c4 10             	add    $0x10,%esp
     4dc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(cmd, 0, sizeof(*cmd));
     4df:	83 ec 04             	sub    $0x4,%esp
     4e2:	6a 0c                	push   $0xc
     4e4:	6a 00                	push   $0x0
     4e6:	ff 75 f4             	pushl  -0xc(%ebp)
     4e9:	e8 4f 08 00 00       	call   d3d <memset>
     4ee:	83 c4 10             	add    $0x10,%esp
  cmd->type = LIST;
     4f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
     4f4:	c7 00 04 00 00 00    	movl   $0x4,(%eax)
  cmd->left = left;
     4fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
     4fd:	8b 55 08             	mov    0x8(%ebp),%edx
     500:	89 50 04             	mov    %edx,0x4(%eax)
  cmd->right = right;
     503:	8b 45 f4             	mov    -0xc(%ebp),%eax
     506:	8b 55 0c             	mov    0xc(%ebp),%edx
     509:	89 50 08             	mov    %edx,0x8(%eax)
  return (struct cmd*)cmd;
     50c:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     50f:	c9                   	leave  
     510:	c3                   	ret    

00000511 <backcmd>:

struct cmd*
backcmd(struct cmd *subcmd)
{
     511:	55                   	push   %ebp
     512:	89 e5                	mov    %esp,%ebp
     514:	83 ec 18             	sub    $0x18,%esp
  struct backcmd *cmd;

  cmd = malloc(sizeof(*cmd));
     517:	83 ec 0c             	sub    $0xc,%esp
     51a:	6a 08                	push   $0x8
     51c:	e8 09 0e 00 00       	call   132a <malloc>
     521:	83 c4 10             	add    $0x10,%esp
     524:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(cmd, 0, sizeof(*cmd));
     527:	83 ec 04             	sub    $0x4,%esp
     52a:	6a 08                	push   $0x8
     52c:	6a 00                	push   $0x0
     52e:	ff 75 f4             	pushl  -0xc(%ebp)
     531:	e8 07 08 00 00       	call   d3d <memset>
     536:	83 c4 10             	add    $0x10,%esp
  cmd->type = BACK;
     539:	8b 45 f4             	mov    -0xc(%ebp),%eax
     53c:	c7 00 05 00 00 00    	movl   $0x5,(%eax)
  cmd->cmd = subcmd;
     542:	8b 45 f4             	mov    -0xc(%ebp),%eax
     545:	8b 55 08             	mov    0x8(%ebp),%edx
     548:	89 50 04             	mov    %edx,0x4(%eax)
  return (struct cmd*)cmd;
     54b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     54e:	c9                   	leave  
     54f:	c3                   	ret    

00000550 <gettoken>:
char whitespace[] = " \t\r\n\v";
char symbols[] = "<|>&;()";

int
gettoken(char **ps, char *es, char **q, char **eq)
{
     550:	55                   	push   %ebp
     551:	89 e5                	mov    %esp,%ebp
     553:	83 ec 18             	sub    $0x18,%esp
  char *s;
  int ret;
  
  s = *ps;
     556:	8b 45 08             	mov    0x8(%ebp),%eax
     559:	8b 00                	mov    (%eax),%eax
     55b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(s < es && strchr(whitespace, *s))
     55e:	eb 04                	jmp    564 <gettoken+0x14>
    s++;
     560:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
{
  char *s;
  int ret;
  
  s = *ps;
  while(s < es && strchr(whitespace, *s))
     564:	8b 45 f4             	mov    -0xc(%ebp),%eax
     567:	3b 45 0c             	cmp    0xc(%ebp),%eax
     56a:	73 1e                	jae    58a <gettoken+0x3a>
     56c:	8b 45 f4             	mov    -0xc(%ebp),%eax
     56f:	0f b6 00             	movzbl (%eax),%eax
     572:	0f be c0             	movsbl %al,%eax
     575:	83 ec 08             	sub    $0x8,%esp
     578:	50                   	push   %eax
     579:	68 98 19 00 00       	push   $0x1998
     57e:	e8 d4 07 00 00       	call   d57 <strchr>
     583:	83 c4 10             	add    $0x10,%esp
     586:	85 c0                	test   %eax,%eax
     588:	75 d6                	jne    560 <gettoken+0x10>
    s++;
  if(q)
     58a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
     58e:	74 08                	je     598 <gettoken+0x48>
    *q = s;
     590:	8b 45 10             	mov    0x10(%ebp),%eax
     593:	8b 55 f4             	mov    -0xc(%ebp),%edx
     596:	89 10                	mov    %edx,(%eax)
  ret = *s;
     598:	8b 45 f4             	mov    -0xc(%ebp),%eax
     59b:	0f b6 00             	movzbl (%eax),%eax
     59e:	0f be c0             	movsbl %al,%eax
     5a1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  switch(*s){
     5a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
     5a7:	0f b6 00             	movzbl (%eax),%eax
     5aa:	0f be c0             	movsbl %al,%eax
     5ad:	83 f8 29             	cmp    $0x29,%eax
     5b0:	7f 14                	jg     5c6 <gettoken+0x76>
     5b2:	83 f8 28             	cmp    $0x28,%eax
     5b5:	7d 28                	jge    5df <gettoken+0x8f>
     5b7:	85 c0                	test   %eax,%eax
     5b9:	0f 84 94 00 00 00    	je     653 <gettoken+0x103>
     5bf:	83 f8 26             	cmp    $0x26,%eax
     5c2:	74 1b                	je     5df <gettoken+0x8f>
     5c4:	eb 3a                	jmp    600 <gettoken+0xb0>
     5c6:	83 f8 3e             	cmp    $0x3e,%eax
     5c9:	74 1a                	je     5e5 <gettoken+0x95>
     5cb:	83 f8 3e             	cmp    $0x3e,%eax
     5ce:	7f 0a                	jg     5da <gettoken+0x8a>
     5d0:	83 e8 3b             	sub    $0x3b,%eax
     5d3:	83 f8 01             	cmp    $0x1,%eax
     5d6:	77 28                	ja     600 <gettoken+0xb0>
     5d8:	eb 05                	jmp    5df <gettoken+0x8f>
     5da:	83 f8 7c             	cmp    $0x7c,%eax
     5dd:	75 21                	jne    600 <gettoken+0xb0>
  case '(':
  case ')':
  case ';':
  case '&':
  case '<':
    s++;
     5df:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    break;
     5e3:	eb 75                	jmp    65a <gettoken+0x10a>
  case '>':
    s++;
     5e5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(*s == '>'){
     5e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
     5ec:	0f b6 00             	movzbl (%eax),%eax
     5ef:	3c 3e                	cmp    $0x3e,%al
     5f1:	75 63                	jne    656 <gettoken+0x106>
      ret = '+';
     5f3:	c7 45 f0 2b 00 00 00 	movl   $0x2b,-0x10(%ebp)
      s++;
     5fa:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    }
    break;
     5fe:	eb 56                	jmp    656 <gettoken+0x106>
  default:
    ret = 'a';
     600:	c7 45 f0 61 00 00 00 	movl   $0x61,-0x10(%ebp)
    while(s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
     607:	eb 04                	jmp    60d <gettoken+0xbd>
      s++;
     609:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      s++;
    }
    break;
  default:
    ret = 'a';
    while(s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
     60d:	8b 45 f4             	mov    -0xc(%ebp),%eax
     610:	3b 45 0c             	cmp    0xc(%ebp),%eax
     613:	73 44                	jae    659 <gettoken+0x109>
     615:	8b 45 f4             	mov    -0xc(%ebp),%eax
     618:	0f b6 00             	movzbl (%eax),%eax
     61b:	0f be c0             	movsbl %al,%eax
     61e:	83 ec 08             	sub    $0x8,%esp
     621:	50                   	push   %eax
     622:	68 98 19 00 00       	push   $0x1998
     627:	e8 2b 07 00 00       	call   d57 <strchr>
     62c:	83 c4 10             	add    $0x10,%esp
     62f:	85 c0                	test   %eax,%eax
     631:	75 26                	jne    659 <gettoken+0x109>
     633:	8b 45 f4             	mov    -0xc(%ebp),%eax
     636:	0f b6 00             	movzbl (%eax),%eax
     639:	0f be c0             	movsbl %al,%eax
     63c:	83 ec 08             	sub    $0x8,%esp
     63f:	50                   	push   %eax
     640:	68 a0 19 00 00       	push   $0x19a0
     645:	e8 0d 07 00 00       	call   d57 <strchr>
     64a:	83 c4 10             	add    $0x10,%esp
     64d:	85 c0                	test   %eax,%eax
     64f:	74 b8                	je     609 <gettoken+0xb9>
      s++;
    break;
     651:	eb 06                	jmp    659 <gettoken+0x109>
  if(q)
    *q = s;
  ret = *s;
  switch(*s){
  case 0:
    break;
     653:	90                   	nop
     654:	eb 04                	jmp    65a <gettoken+0x10a>
    s++;
    if(*s == '>'){
      ret = '+';
      s++;
    }
    break;
     656:	90                   	nop
     657:	eb 01                	jmp    65a <gettoken+0x10a>
  default:
    ret = 'a';
    while(s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
      s++;
    break;
     659:	90                   	nop
  }
  if(eq)
     65a:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
     65e:	74 0e                	je     66e <gettoken+0x11e>
    *eq = s;
     660:	8b 45 14             	mov    0x14(%ebp),%eax
     663:	8b 55 f4             	mov    -0xc(%ebp),%edx
     666:	89 10                	mov    %edx,(%eax)
  
  while(s < es && strchr(whitespace, *s))
     668:	eb 04                	jmp    66e <gettoken+0x11e>
    s++;
     66a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    break;
  }
  if(eq)
    *eq = s;
  
  while(s < es && strchr(whitespace, *s))
     66e:	8b 45 f4             	mov    -0xc(%ebp),%eax
     671:	3b 45 0c             	cmp    0xc(%ebp),%eax
     674:	73 1e                	jae    694 <gettoken+0x144>
     676:	8b 45 f4             	mov    -0xc(%ebp),%eax
     679:	0f b6 00             	movzbl (%eax),%eax
     67c:	0f be c0             	movsbl %al,%eax
     67f:	83 ec 08             	sub    $0x8,%esp
     682:	50                   	push   %eax
     683:	68 98 19 00 00       	push   $0x1998
     688:	e8 ca 06 00 00       	call   d57 <strchr>
     68d:	83 c4 10             	add    $0x10,%esp
     690:	85 c0                	test   %eax,%eax
     692:	75 d6                	jne    66a <gettoken+0x11a>
    s++;
  *ps = s;
     694:	8b 45 08             	mov    0x8(%ebp),%eax
     697:	8b 55 f4             	mov    -0xc(%ebp),%edx
     69a:	89 10                	mov    %edx,(%eax)
  return ret;
     69c:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
     69f:	c9                   	leave  
     6a0:	c3                   	ret    

000006a1 <peek>:

int
peek(char **ps, char *es, char *toks)
{
     6a1:	55                   	push   %ebp
     6a2:	89 e5                	mov    %esp,%ebp
     6a4:	83 ec 18             	sub    $0x18,%esp
  char *s;
  
  s = *ps;
     6a7:	8b 45 08             	mov    0x8(%ebp),%eax
     6aa:	8b 00                	mov    (%eax),%eax
     6ac:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(s < es && strchr(whitespace, *s))
     6af:	eb 04                	jmp    6b5 <peek+0x14>
    s++;
     6b1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
peek(char **ps, char *es, char *toks)
{
  char *s;
  
  s = *ps;
  while(s < es && strchr(whitespace, *s))
     6b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
     6b8:	3b 45 0c             	cmp    0xc(%ebp),%eax
     6bb:	73 1e                	jae    6db <peek+0x3a>
     6bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
     6c0:	0f b6 00             	movzbl (%eax),%eax
     6c3:	0f be c0             	movsbl %al,%eax
     6c6:	83 ec 08             	sub    $0x8,%esp
     6c9:	50                   	push   %eax
     6ca:	68 98 19 00 00       	push   $0x1998
     6cf:	e8 83 06 00 00       	call   d57 <strchr>
     6d4:	83 c4 10             	add    $0x10,%esp
     6d7:	85 c0                	test   %eax,%eax
     6d9:	75 d6                	jne    6b1 <peek+0x10>
    s++;
  *ps = s;
     6db:	8b 45 08             	mov    0x8(%ebp),%eax
     6de:	8b 55 f4             	mov    -0xc(%ebp),%edx
     6e1:	89 10                	mov    %edx,(%eax)
  return *s && strchr(toks, *s);
     6e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
     6e6:	0f b6 00             	movzbl (%eax),%eax
     6e9:	84 c0                	test   %al,%al
     6eb:	74 23                	je     710 <peek+0x6f>
     6ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
     6f0:	0f b6 00             	movzbl (%eax),%eax
     6f3:	0f be c0             	movsbl %al,%eax
     6f6:	83 ec 08             	sub    $0x8,%esp
     6f9:	50                   	push   %eax
     6fa:	ff 75 10             	pushl  0x10(%ebp)
     6fd:	e8 55 06 00 00       	call   d57 <strchr>
     702:	83 c4 10             	add    $0x10,%esp
     705:	85 c0                	test   %eax,%eax
     707:	74 07                	je     710 <peek+0x6f>
     709:	b8 01 00 00 00       	mov    $0x1,%eax
     70e:	eb 05                	jmp    715 <peek+0x74>
     710:	b8 00 00 00 00       	mov    $0x0,%eax
}
     715:	c9                   	leave  
     716:	c3                   	ret    

00000717 <parsecmd>:
struct cmd *parseexec(char**, char*);
struct cmd *nulterminate(struct cmd*);

struct cmd*
parsecmd(char *s)
{
     717:	55                   	push   %ebp
     718:	89 e5                	mov    %esp,%ebp
     71a:	53                   	push   %ebx
     71b:	83 ec 14             	sub    $0x14,%esp
  char *es;
  struct cmd *cmd;

  es = s + strlen(s);
     71e:	8b 5d 08             	mov    0x8(%ebp),%ebx
     721:	8b 45 08             	mov    0x8(%ebp),%eax
     724:	83 ec 0c             	sub    $0xc,%esp
     727:	50                   	push   %eax
     728:	e8 e9 05 00 00       	call   d16 <strlen>
     72d:	83 c4 10             	add    $0x10,%esp
     730:	01 d8                	add    %ebx,%eax
     732:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cmd = parseline(&s, es);
     735:	83 ec 08             	sub    $0x8,%esp
     738:	ff 75 f4             	pushl  -0xc(%ebp)
     73b:	8d 45 08             	lea    0x8(%ebp),%eax
     73e:	50                   	push   %eax
     73f:	e8 61 00 00 00       	call   7a5 <parseline>
     744:	83 c4 10             	add    $0x10,%esp
     747:	89 45 f0             	mov    %eax,-0x10(%ebp)
  peek(&s, es, "");
     74a:	83 ec 04             	sub    $0x4,%esp
     74d:	68 82 14 00 00       	push   $0x1482
     752:	ff 75 f4             	pushl  -0xc(%ebp)
     755:	8d 45 08             	lea    0x8(%ebp),%eax
     758:	50                   	push   %eax
     759:	e8 43 ff ff ff       	call   6a1 <peek>
     75e:	83 c4 10             	add    $0x10,%esp
  if(s != es){
     761:	8b 45 08             	mov    0x8(%ebp),%eax
     764:	3b 45 f4             	cmp    -0xc(%ebp),%eax
     767:	74 26                	je     78f <parsecmd+0x78>
    printf(2, "leftovers: %s\n", s);
     769:	8b 45 08             	mov    0x8(%ebp),%eax
     76c:	83 ec 04             	sub    $0x4,%esp
     76f:	50                   	push   %eax
     770:	68 83 14 00 00       	push   $0x1483
     775:	6a 02                	push   $0x2
     777:	e8 db 08 00 00       	call   1057 <printf>
     77c:	83 c4 10             	add    $0x10,%esp
    panic("syntax");
     77f:	83 ec 0c             	sub    $0xc,%esp
     782:	68 92 14 00 00       	push   $0x1492
     787:	e8 13 fc ff ff       	call   39f <panic>
     78c:	83 c4 10             	add    $0x10,%esp
  }
  nulterminate(cmd);
     78f:	83 ec 0c             	sub    $0xc,%esp
     792:	ff 75 f0             	pushl  -0x10(%ebp)
     795:	e8 eb 03 00 00       	call   b85 <nulterminate>
     79a:	83 c4 10             	add    $0x10,%esp
  return cmd;
     79d:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
     7a0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
     7a3:	c9                   	leave  
     7a4:	c3                   	ret    

000007a5 <parseline>:

struct cmd*
parseline(char **ps, char *es)
{
     7a5:	55                   	push   %ebp
     7a6:	89 e5                	mov    %esp,%ebp
     7a8:	83 ec 18             	sub    $0x18,%esp
  struct cmd *cmd;

  cmd = parsepipe(ps, es);
     7ab:	83 ec 08             	sub    $0x8,%esp
     7ae:	ff 75 0c             	pushl  0xc(%ebp)
     7b1:	ff 75 08             	pushl  0x8(%ebp)
     7b4:	e8 99 00 00 00       	call   852 <parsepipe>
     7b9:	83 c4 10             	add    $0x10,%esp
     7bc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(peek(ps, es, "&")){
     7bf:	eb 23                	jmp    7e4 <parseline+0x3f>
    gettoken(ps, es, 0, 0);
     7c1:	6a 00                	push   $0x0
     7c3:	6a 00                	push   $0x0
     7c5:	ff 75 0c             	pushl  0xc(%ebp)
     7c8:	ff 75 08             	pushl  0x8(%ebp)
     7cb:	e8 80 fd ff ff       	call   550 <gettoken>
     7d0:	83 c4 10             	add    $0x10,%esp
    cmd = backcmd(cmd);
     7d3:	83 ec 0c             	sub    $0xc,%esp
     7d6:	ff 75 f4             	pushl  -0xc(%ebp)
     7d9:	e8 33 fd ff ff       	call   511 <backcmd>
     7de:	83 c4 10             	add    $0x10,%esp
     7e1:	89 45 f4             	mov    %eax,-0xc(%ebp)
parseline(char **ps, char *es)
{
  struct cmd *cmd;

  cmd = parsepipe(ps, es);
  while(peek(ps, es, "&")){
     7e4:	83 ec 04             	sub    $0x4,%esp
     7e7:	68 99 14 00 00       	push   $0x1499
     7ec:	ff 75 0c             	pushl  0xc(%ebp)
     7ef:	ff 75 08             	pushl  0x8(%ebp)
     7f2:	e8 aa fe ff ff       	call   6a1 <peek>
     7f7:	83 c4 10             	add    $0x10,%esp
     7fa:	85 c0                	test   %eax,%eax
     7fc:	75 c3                	jne    7c1 <parseline+0x1c>
    gettoken(ps, es, 0, 0);
    cmd = backcmd(cmd);
  }
  if(peek(ps, es, ";")){
     7fe:	83 ec 04             	sub    $0x4,%esp
     801:	68 9b 14 00 00       	push   $0x149b
     806:	ff 75 0c             	pushl  0xc(%ebp)
     809:	ff 75 08             	pushl  0x8(%ebp)
     80c:	e8 90 fe ff ff       	call   6a1 <peek>
     811:	83 c4 10             	add    $0x10,%esp
     814:	85 c0                	test   %eax,%eax
     816:	74 35                	je     84d <parseline+0xa8>
    gettoken(ps, es, 0, 0);
     818:	6a 00                	push   $0x0
     81a:	6a 00                	push   $0x0
     81c:	ff 75 0c             	pushl  0xc(%ebp)
     81f:	ff 75 08             	pushl  0x8(%ebp)
     822:	e8 29 fd ff ff       	call   550 <gettoken>
     827:	83 c4 10             	add    $0x10,%esp
    cmd = listcmd(cmd, parseline(ps, es));
     82a:	83 ec 08             	sub    $0x8,%esp
     82d:	ff 75 0c             	pushl  0xc(%ebp)
     830:	ff 75 08             	pushl  0x8(%ebp)
     833:	e8 6d ff ff ff       	call   7a5 <parseline>
     838:	83 c4 10             	add    $0x10,%esp
     83b:	83 ec 08             	sub    $0x8,%esp
     83e:	50                   	push   %eax
     83f:	ff 75 f4             	pushl  -0xc(%ebp)
     842:	e8 82 fc ff ff       	call   4c9 <listcmd>
     847:	83 c4 10             	add    $0x10,%esp
     84a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  }
  return cmd;
     84d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     850:	c9                   	leave  
     851:	c3                   	ret    

00000852 <parsepipe>:

struct cmd*
parsepipe(char **ps, char *es)
{
     852:	55                   	push   %ebp
     853:	89 e5                	mov    %esp,%ebp
     855:	83 ec 18             	sub    $0x18,%esp
  struct cmd *cmd;

  cmd = parseexec(ps, es);
     858:	83 ec 08             	sub    $0x8,%esp
     85b:	ff 75 0c             	pushl  0xc(%ebp)
     85e:	ff 75 08             	pushl  0x8(%ebp)
     861:	e8 ec 01 00 00       	call   a52 <parseexec>
     866:	83 c4 10             	add    $0x10,%esp
     869:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(peek(ps, es, "|")){
     86c:	83 ec 04             	sub    $0x4,%esp
     86f:	68 9d 14 00 00       	push   $0x149d
     874:	ff 75 0c             	pushl  0xc(%ebp)
     877:	ff 75 08             	pushl  0x8(%ebp)
     87a:	e8 22 fe ff ff       	call   6a1 <peek>
     87f:	83 c4 10             	add    $0x10,%esp
     882:	85 c0                	test   %eax,%eax
     884:	74 35                	je     8bb <parsepipe+0x69>
    gettoken(ps, es, 0, 0);
     886:	6a 00                	push   $0x0
     888:	6a 00                	push   $0x0
     88a:	ff 75 0c             	pushl  0xc(%ebp)
     88d:	ff 75 08             	pushl  0x8(%ebp)
     890:	e8 bb fc ff ff       	call   550 <gettoken>
     895:	83 c4 10             	add    $0x10,%esp
    cmd = pipecmd(cmd, parsepipe(ps, es));
     898:	83 ec 08             	sub    $0x8,%esp
     89b:	ff 75 0c             	pushl  0xc(%ebp)
     89e:	ff 75 08             	pushl  0x8(%ebp)
     8a1:	e8 ac ff ff ff       	call   852 <parsepipe>
     8a6:	83 c4 10             	add    $0x10,%esp
     8a9:	83 ec 08             	sub    $0x8,%esp
     8ac:	50                   	push   %eax
     8ad:	ff 75 f4             	pushl  -0xc(%ebp)
     8b0:	e8 cc fb ff ff       	call   481 <pipecmd>
     8b5:	83 c4 10             	add    $0x10,%esp
     8b8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  }
  return cmd;
     8bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     8be:	c9                   	leave  
     8bf:	c3                   	ret    

000008c0 <parseredirs>:

struct cmd*
parseredirs(struct cmd *cmd, char **ps, char *es)
{
     8c0:	55                   	push   %ebp
     8c1:	89 e5                	mov    %esp,%ebp
     8c3:	83 ec 18             	sub    $0x18,%esp
  int tok;
  char *q, *eq;

  while(peek(ps, es, "<>")){
     8c6:	e9 b6 00 00 00       	jmp    981 <parseredirs+0xc1>
    tok = gettoken(ps, es, 0, 0);
     8cb:	6a 00                	push   $0x0
     8cd:	6a 00                	push   $0x0
     8cf:	ff 75 10             	pushl  0x10(%ebp)
     8d2:	ff 75 0c             	pushl  0xc(%ebp)
     8d5:	e8 76 fc ff ff       	call   550 <gettoken>
     8da:	83 c4 10             	add    $0x10,%esp
     8dd:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(gettoken(ps, es, &q, &eq) != 'a')
     8e0:	8d 45 ec             	lea    -0x14(%ebp),%eax
     8e3:	50                   	push   %eax
     8e4:	8d 45 f0             	lea    -0x10(%ebp),%eax
     8e7:	50                   	push   %eax
     8e8:	ff 75 10             	pushl  0x10(%ebp)
     8eb:	ff 75 0c             	pushl  0xc(%ebp)
     8ee:	e8 5d fc ff ff       	call   550 <gettoken>
     8f3:	83 c4 10             	add    $0x10,%esp
     8f6:	83 f8 61             	cmp    $0x61,%eax
     8f9:	74 10                	je     90b <parseredirs+0x4b>
      panic("missing file for redirection");
     8fb:	83 ec 0c             	sub    $0xc,%esp
     8fe:	68 9f 14 00 00       	push   $0x149f
     903:	e8 97 fa ff ff       	call   39f <panic>
     908:	83 c4 10             	add    $0x10,%esp
    switch(tok){
     90b:	8b 45 f4             	mov    -0xc(%ebp),%eax
     90e:	83 f8 3c             	cmp    $0x3c,%eax
     911:	74 0c                	je     91f <parseredirs+0x5f>
     913:	83 f8 3e             	cmp    $0x3e,%eax
     916:	74 26                	je     93e <parseredirs+0x7e>
     918:	83 f8 2b             	cmp    $0x2b,%eax
     91b:	74 43                	je     960 <parseredirs+0xa0>
     91d:	eb 62                	jmp    981 <parseredirs+0xc1>
    case '<':
      cmd = redircmd(cmd, q, eq, O_RDONLY, 0);
     91f:	8b 55 ec             	mov    -0x14(%ebp),%edx
     922:	8b 45 f0             	mov    -0x10(%ebp),%eax
     925:	83 ec 0c             	sub    $0xc,%esp
     928:	6a 00                	push   $0x0
     92a:	6a 00                	push   $0x0
     92c:	52                   	push   %edx
     92d:	50                   	push   %eax
     92e:	ff 75 08             	pushl  0x8(%ebp)
     931:	e8 e8 fa ff ff       	call   41e <redircmd>
     936:	83 c4 20             	add    $0x20,%esp
     939:	89 45 08             	mov    %eax,0x8(%ebp)
      break;
     93c:	eb 43                	jmp    981 <parseredirs+0xc1>
    case '>':
      cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE, 1);
     93e:	8b 55 ec             	mov    -0x14(%ebp),%edx
     941:	8b 45 f0             	mov    -0x10(%ebp),%eax
     944:	83 ec 0c             	sub    $0xc,%esp
     947:	6a 01                	push   $0x1
     949:	68 01 02 00 00       	push   $0x201
     94e:	52                   	push   %edx
     94f:	50                   	push   %eax
     950:	ff 75 08             	pushl  0x8(%ebp)
     953:	e8 c6 fa ff ff       	call   41e <redircmd>
     958:	83 c4 20             	add    $0x20,%esp
     95b:	89 45 08             	mov    %eax,0x8(%ebp)
      break;
     95e:	eb 21                	jmp    981 <parseredirs+0xc1>
    case '+':  // >>
      cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE, 1);
     960:	8b 55 ec             	mov    -0x14(%ebp),%edx
     963:	8b 45 f0             	mov    -0x10(%ebp),%eax
     966:	83 ec 0c             	sub    $0xc,%esp
     969:	6a 01                	push   $0x1
     96b:	68 01 02 00 00       	push   $0x201
     970:	52                   	push   %edx
     971:	50                   	push   %eax
     972:	ff 75 08             	pushl  0x8(%ebp)
     975:	e8 a4 fa ff ff       	call   41e <redircmd>
     97a:	83 c4 20             	add    $0x20,%esp
     97d:	89 45 08             	mov    %eax,0x8(%ebp)
      break;
     980:	90                   	nop
parseredirs(struct cmd *cmd, char **ps, char *es)
{
  int tok;
  char *q, *eq;

  while(peek(ps, es, "<>")){
     981:	83 ec 04             	sub    $0x4,%esp
     984:	68 bc 14 00 00       	push   $0x14bc
     989:	ff 75 10             	pushl  0x10(%ebp)
     98c:	ff 75 0c             	pushl  0xc(%ebp)
     98f:	e8 0d fd ff ff       	call   6a1 <peek>
     994:	83 c4 10             	add    $0x10,%esp
     997:	85 c0                	test   %eax,%eax
     999:	0f 85 2c ff ff ff    	jne    8cb <parseredirs+0xb>
    case '+':  // >>
      cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE, 1);
      break;
    }
  }
  return cmd;
     99f:	8b 45 08             	mov    0x8(%ebp),%eax
}
     9a2:	c9                   	leave  
     9a3:	c3                   	ret    

000009a4 <parseblock>:

struct cmd*
parseblock(char **ps, char *es)
{
     9a4:	55                   	push   %ebp
     9a5:	89 e5                	mov    %esp,%ebp
     9a7:	83 ec 18             	sub    $0x18,%esp
  struct cmd *cmd;

  if(!peek(ps, es, "("))
     9aa:	83 ec 04             	sub    $0x4,%esp
     9ad:	68 bf 14 00 00       	push   $0x14bf
     9b2:	ff 75 0c             	pushl  0xc(%ebp)
     9b5:	ff 75 08             	pushl  0x8(%ebp)
     9b8:	e8 e4 fc ff ff       	call   6a1 <peek>
     9bd:	83 c4 10             	add    $0x10,%esp
     9c0:	85 c0                	test   %eax,%eax
     9c2:	75 10                	jne    9d4 <parseblock+0x30>
    panic("parseblock");
     9c4:	83 ec 0c             	sub    $0xc,%esp
     9c7:	68 c1 14 00 00       	push   $0x14c1
     9cc:	e8 ce f9 ff ff       	call   39f <panic>
     9d1:	83 c4 10             	add    $0x10,%esp
  gettoken(ps, es, 0, 0);
     9d4:	6a 00                	push   $0x0
     9d6:	6a 00                	push   $0x0
     9d8:	ff 75 0c             	pushl  0xc(%ebp)
     9db:	ff 75 08             	pushl  0x8(%ebp)
     9de:	e8 6d fb ff ff       	call   550 <gettoken>
     9e3:	83 c4 10             	add    $0x10,%esp
  cmd = parseline(ps, es);
     9e6:	83 ec 08             	sub    $0x8,%esp
     9e9:	ff 75 0c             	pushl  0xc(%ebp)
     9ec:	ff 75 08             	pushl  0x8(%ebp)
     9ef:	e8 b1 fd ff ff       	call   7a5 <parseline>
     9f4:	83 c4 10             	add    $0x10,%esp
     9f7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(!peek(ps, es, ")"))
     9fa:	83 ec 04             	sub    $0x4,%esp
     9fd:	68 cc 14 00 00       	push   $0x14cc
     a02:	ff 75 0c             	pushl  0xc(%ebp)
     a05:	ff 75 08             	pushl  0x8(%ebp)
     a08:	e8 94 fc ff ff       	call   6a1 <peek>
     a0d:	83 c4 10             	add    $0x10,%esp
     a10:	85 c0                	test   %eax,%eax
     a12:	75 10                	jne    a24 <parseblock+0x80>
    panic("syntax - missing )");
     a14:	83 ec 0c             	sub    $0xc,%esp
     a17:	68 ce 14 00 00       	push   $0x14ce
     a1c:	e8 7e f9 ff ff       	call   39f <panic>
     a21:	83 c4 10             	add    $0x10,%esp
  gettoken(ps, es, 0, 0);
     a24:	6a 00                	push   $0x0
     a26:	6a 00                	push   $0x0
     a28:	ff 75 0c             	pushl  0xc(%ebp)
     a2b:	ff 75 08             	pushl  0x8(%ebp)
     a2e:	e8 1d fb ff ff       	call   550 <gettoken>
     a33:	83 c4 10             	add    $0x10,%esp
  cmd = parseredirs(cmd, ps, es);
     a36:	83 ec 04             	sub    $0x4,%esp
     a39:	ff 75 0c             	pushl  0xc(%ebp)
     a3c:	ff 75 08             	pushl  0x8(%ebp)
     a3f:	ff 75 f4             	pushl  -0xc(%ebp)
     a42:	e8 79 fe ff ff       	call   8c0 <parseredirs>
     a47:	83 c4 10             	add    $0x10,%esp
     a4a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  return cmd;
     a4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     a50:	c9                   	leave  
     a51:	c3                   	ret    

00000a52 <parseexec>:

struct cmd*
parseexec(char **ps, char *es)
{
     a52:	55                   	push   %ebp
     a53:	89 e5                	mov    %esp,%ebp
     a55:	83 ec 28             	sub    $0x28,%esp
  char *q, *eq;
  int tok, argc;
  struct execcmd *cmd;
  struct cmd *ret;
  
  if(peek(ps, es, "("))
     a58:	83 ec 04             	sub    $0x4,%esp
     a5b:	68 bf 14 00 00       	push   $0x14bf
     a60:	ff 75 0c             	pushl  0xc(%ebp)
     a63:	ff 75 08             	pushl  0x8(%ebp)
     a66:	e8 36 fc ff ff       	call   6a1 <peek>
     a6b:	83 c4 10             	add    $0x10,%esp
     a6e:	85 c0                	test   %eax,%eax
     a70:	74 16                	je     a88 <parseexec+0x36>
    return parseblock(ps, es);
     a72:	83 ec 08             	sub    $0x8,%esp
     a75:	ff 75 0c             	pushl  0xc(%ebp)
     a78:	ff 75 08             	pushl  0x8(%ebp)
     a7b:	e8 24 ff ff ff       	call   9a4 <parseblock>
     a80:	83 c4 10             	add    $0x10,%esp
     a83:	e9 fb 00 00 00       	jmp    b83 <parseexec+0x131>

  ret = execcmd();
     a88:	e8 5b f9 ff ff       	call   3e8 <execcmd>
     a8d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  cmd = (struct execcmd*)ret;
     a90:	8b 45 f0             	mov    -0x10(%ebp),%eax
     a93:	89 45 ec             	mov    %eax,-0x14(%ebp)

  argc = 0;
     a96:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  ret = parseredirs(ret, ps, es);
     a9d:	83 ec 04             	sub    $0x4,%esp
     aa0:	ff 75 0c             	pushl  0xc(%ebp)
     aa3:	ff 75 08             	pushl  0x8(%ebp)
     aa6:	ff 75 f0             	pushl  -0x10(%ebp)
     aa9:	e8 12 fe ff ff       	call   8c0 <parseredirs>
     aae:	83 c4 10             	add    $0x10,%esp
     ab1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  while(!peek(ps, es, "|)&;")){
     ab4:	e9 87 00 00 00       	jmp    b40 <parseexec+0xee>
    if((tok=gettoken(ps, es, &q, &eq)) == 0)
     ab9:	8d 45 e0             	lea    -0x20(%ebp),%eax
     abc:	50                   	push   %eax
     abd:	8d 45 e4             	lea    -0x1c(%ebp),%eax
     ac0:	50                   	push   %eax
     ac1:	ff 75 0c             	pushl  0xc(%ebp)
     ac4:	ff 75 08             	pushl  0x8(%ebp)
     ac7:	e8 84 fa ff ff       	call   550 <gettoken>
     acc:	83 c4 10             	add    $0x10,%esp
     acf:	89 45 e8             	mov    %eax,-0x18(%ebp)
     ad2:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
     ad6:	0f 84 84 00 00 00    	je     b60 <parseexec+0x10e>
      break;
    if(tok != 'a')
     adc:	83 7d e8 61          	cmpl   $0x61,-0x18(%ebp)
     ae0:	74 10                	je     af2 <parseexec+0xa0>
      panic("syntax");
     ae2:	83 ec 0c             	sub    $0xc,%esp
     ae5:	68 92 14 00 00       	push   $0x1492
     aea:	e8 b0 f8 ff ff       	call   39f <panic>
     aef:	83 c4 10             	add    $0x10,%esp
    cmd->argv[argc] = q;
     af2:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
     af5:	8b 45 ec             	mov    -0x14(%ebp),%eax
     af8:	8b 55 f4             	mov    -0xc(%ebp),%edx
     afb:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
    cmd->eargv[argc] = eq;
     aff:	8b 55 e0             	mov    -0x20(%ebp),%edx
     b02:	8b 45 ec             	mov    -0x14(%ebp),%eax
     b05:	8b 4d f4             	mov    -0xc(%ebp),%ecx
     b08:	83 c1 08             	add    $0x8,%ecx
     b0b:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    argc++;
     b0f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(argc >= MAXARGS)
     b13:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
     b17:	7e 10                	jle    b29 <parseexec+0xd7>
      panic("too many args");
     b19:	83 ec 0c             	sub    $0xc,%esp
     b1c:	68 e1 14 00 00       	push   $0x14e1
     b21:	e8 79 f8 ff ff       	call   39f <panic>
     b26:	83 c4 10             	add    $0x10,%esp
    ret = parseredirs(ret, ps, es);
     b29:	83 ec 04             	sub    $0x4,%esp
     b2c:	ff 75 0c             	pushl  0xc(%ebp)
     b2f:	ff 75 08             	pushl  0x8(%ebp)
     b32:	ff 75 f0             	pushl  -0x10(%ebp)
     b35:	e8 86 fd ff ff       	call   8c0 <parseredirs>
     b3a:	83 c4 10             	add    $0x10,%esp
     b3d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  ret = execcmd();
  cmd = (struct execcmd*)ret;

  argc = 0;
  ret = parseredirs(ret, ps, es);
  while(!peek(ps, es, "|)&;")){
     b40:	83 ec 04             	sub    $0x4,%esp
     b43:	68 ef 14 00 00       	push   $0x14ef
     b48:	ff 75 0c             	pushl  0xc(%ebp)
     b4b:	ff 75 08             	pushl  0x8(%ebp)
     b4e:	e8 4e fb ff ff       	call   6a1 <peek>
     b53:	83 c4 10             	add    $0x10,%esp
     b56:	85 c0                	test   %eax,%eax
     b58:	0f 84 5b ff ff ff    	je     ab9 <parseexec+0x67>
     b5e:	eb 01                	jmp    b61 <parseexec+0x10f>
    if((tok=gettoken(ps, es, &q, &eq)) == 0)
      break;
     b60:	90                   	nop
    argc++;
    if(argc >= MAXARGS)
      panic("too many args");
    ret = parseredirs(ret, ps, es);
  }
  cmd->argv[argc] = 0;
     b61:	8b 45 ec             	mov    -0x14(%ebp),%eax
     b64:	8b 55 f4             	mov    -0xc(%ebp),%edx
     b67:	c7 44 90 04 00 00 00 	movl   $0x0,0x4(%eax,%edx,4)
     b6e:	00 
  cmd->eargv[argc] = 0;
     b6f:	8b 45 ec             	mov    -0x14(%ebp),%eax
     b72:	8b 55 f4             	mov    -0xc(%ebp),%edx
     b75:	83 c2 08             	add    $0x8,%edx
     b78:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
     b7f:	00 
  return ret;
     b80:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
     b83:	c9                   	leave  
     b84:	c3                   	ret    

00000b85 <nulterminate>:

// NUL-terminate all the counted strings.
struct cmd*
nulterminate(struct cmd *cmd)
{
     b85:	55                   	push   %ebp
     b86:	89 e5                	mov    %esp,%ebp
     b88:	83 ec 28             	sub    $0x28,%esp
  struct execcmd *ecmd;
  struct listcmd *lcmd;
  struct pipecmd *pcmd;
  struct redircmd *rcmd;

  if(cmd == 0)
     b8b:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
     b8f:	75 0a                	jne    b9b <nulterminate+0x16>
    return 0;
     b91:	b8 00 00 00 00       	mov    $0x0,%eax
     b96:	e9 e4 00 00 00       	jmp    c7f <nulterminate+0xfa>
  
  switch(cmd->type){
     b9b:	8b 45 08             	mov    0x8(%ebp),%eax
     b9e:	8b 00                	mov    (%eax),%eax
     ba0:	83 f8 05             	cmp    $0x5,%eax
     ba3:	0f 87 d3 00 00 00    	ja     c7c <nulterminate+0xf7>
     ba9:	8b 04 85 f4 14 00 00 	mov    0x14f4(,%eax,4),%eax
     bb0:	ff e0                	jmp    *%eax
  case EXEC:
    ecmd = (struct execcmd*)cmd;
     bb2:	8b 45 08             	mov    0x8(%ebp),%eax
     bb5:	89 45 f0             	mov    %eax,-0x10(%ebp)
    for(i=0; ecmd->argv[i]; i++)
     bb8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
     bbf:	eb 14                	jmp    bd5 <nulterminate+0x50>
      *ecmd->eargv[i] = 0;
     bc1:	8b 45 f0             	mov    -0x10(%ebp),%eax
     bc4:	8b 55 f4             	mov    -0xc(%ebp),%edx
     bc7:	83 c2 08             	add    $0x8,%edx
     bca:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
     bce:	c6 00 00             	movb   $0x0,(%eax)
    return 0;
  
  switch(cmd->type){
  case EXEC:
    ecmd = (struct execcmd*)cmd;
    for(i=0; ecmd->argv[i]; i++)
     bd1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
     bd5:	8b 45 f0             	mov    -0x10(%ebp),%eax
     bd8:	8b 55 f4             	mov    -0xc(%ebp),%edx
     bdb:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
     bdf:	85 c0                	test   %eax,%eax
     be1:	75 de                	jne    bc1 <nulterminate+0x3c>
      *ecmd->eargv[i] = 0;
    break;
     be3:	e9 94 00 00 00       	jmp    c7c <nulterminate+0xf7>

  case REDIR:
    rcmd = (struct redircmd*)cmd;
     be8:	8b 45 08             	mov    0x8(%ebp),%eax
     beb:	89 45 ec             	mov    %eax,-0x14(%ebp)
    nulterminate(rcmd->cmd);
     bee:	8b 45 ec             	mov    -0x14(%ebp),%eax
     bf1:	8b 40 04             	mov    0x4(%eax),%eax
     bf4:	83 ec 0c             	sub    $0xc,%esp
     bf7:	50                   	push   %eax
     bf8:	e8 88 ff ff ff       	call   b85 <nulterminate>
     bfd:	83 c4 10             	add    $0x10,%esp
    *rcmd->efile = 0;
     c00:	8b 45 ec             	mov    -0x14(%ebp),%eax
     c03:	8b 40 0c             	mov    0xc(%eax),%eax
     c06:	c6 00 00             	movb   $0x0,(%eax)
    break;
     c09:	eb 71                	jmp    c7c <nulterminate+0xf7>

  case PIPE:
    pcmd = (struct pipecmd*)cmd;
     c0b:	8b 45 08             	mov    0x8(%ebp),%eax
     c0e:	89 45 e8             	mov    %eax,-0x18(%ebp)
    nulterminate(pcmd->left);
     c11:	8b 45 e8             	mov    -0x18(%ebp),%eax
     c14:	8b 40 04             	mov    0x4(%eax),%eax
     c17:	83 ec 0c             	sub    $0xc,%esp
     c1a:	50                   	push   %eax
     c1b:	e8 65 ff ff ff       	call   b85 <nulterminate>
     c20:	83 c4 10             	add    $0x10,%esp
    nulterminate(pcmd->right);
     c23:	8b 45 e8             	mov    -0x18(%ebp),%eax
     c26:	8b 40 08             	mov    0x8(%eax),%eax
     c29:	83 ec 0c             	sub    $0xc,%esp
     c2c:	50                   	push   %eax
     c2d:	e8 53 ff ff ff       	call   b85 <nulterminate>
     c32:	83 c4 10             	add    $0x10,%esp
    break;
     c35:	eb 45                	jmp    c7c <nulterminate+0xf7>
    
  case LIST:
    lcmd = (struct listcmd*)cmd;
     c37:	8b 45 08             	mov    0x8(%ebp),%eax
     c3a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    nulterminate(lcmd->left);
     c3d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     c40:	8b 40 04             	mov    0x4(%eax),%eax
     c43:	83 ec 0c             	sub    $0xc,%esp
     c46:	50                   	push   %eax
     c47:	e8 39 ff ff ff       	call   b85 <nulterminate>
     c4c:	83 c4 10             	add    $0x10,%esp
    nulterminate(lcmd->right);
     c4f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     c52:	8b 40 08             	mov    0x8(%eax),%eax
     c55:	83 ec 0c             	sub    $0xc,%esp
     c58:	50                   	push   %eax
     c59:	e8 27 ff ff ff       	call   b85 <nulterminate>
     c5e:	83 c4 10             	add    $0x10,%esp
    break;
     c61:	eb 19                	jmp    c7c <nulterminate+0xf7>

  case BACK:
    bcmd = (struct backcmd*)cmd;
     c63:	8b 45 08             	mov    0x8(%ebp),%eax
     c66:	89 45 e0             	mov    %eax,-0x20(%ebp)
    nulterminate(bcmd->cmd);
     c69:	8b 45 e0             	mov    -0x20(%ebp),%eax
     c6c:	8b 40 04             	mov    0x4(%eax),%eax
     c6f:	83 ec 0c             	sub    $0xc,%esp
     c72:	50                   	push   %eax
     c73:	e8 0d ff ff ff       	call   b85 <nulterminate>
     c78:	83 c4 10             	add    $0x10,%esp
    break;
     c7b:	90                   	nop
  }
  return cmd;
     c7c:	8b 45 08             	mov    0x8(%ebp),%eax
}
     c7f:	c9                   	leave  
     c80:	c3                   	ret    

00000c81 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
     c81:	55                   	push   %ebp
     c82:	89 e5                	mov    %esp,%ebp
     c84:	57                   	push   %edi
     c85:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
     c86:	8b 4d 08             	mov    0x8(%ebp),%ecx
     c89:	8b 55 10             	mov    0x10(%ebp),%edx
     c8c:	8b 45 0c             	mov    0xc(%ebp),%eax
     c8f:	89 cb                	mov    %ecx,%ebx
     c91:	89 df                	mov    %ebx,%edi
     c93:	89 d1                	mov    %edx,%ecx
     c95:	fc                   	cld    
     c96:	f3 aa                	rep stos %al,%es:(%edi)
     c98:	89 ca                	mov    %ecx,%edx
     c9a:	89 fb                	mov    %edi,%ebx
     c9c:	89 5d 08             	mov    %ebx,0x8(%ebp)
     c9f:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
     ca2:	90                   	nop
     ca3:	5b                   	pop    %ebx
     ca4:	5f                   	pop    %edi
     ca5:	5d                   	pop    %ebp
     ca6:	c3                   	ret    

00000ca7 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
     ca7:	55                   	push   %ebp
     ca8:	89 e5                	mov    %esp,%ebp
     caa:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
     cad:	8b 45 08             	mov    0x8(%ebp),%eax
     cb0:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
     cb3:	90                   	nop
     cb4:	8b 45 08             	mov    0x8(%ebp),%eax
     cb7:	8d 50 01             	lea    0x1(%eax),%edx
     cba:	89 55 08             	mov    %edx,0x8(%ebp)
     cbd:	8b 55 0c             	mov    0xc(%ebp),%edx
     cc0:	8d 4a 01             	lea    0x1(%edx),%ecx
     cc3:	89 4d 0c             	mov    %ecx,0xc(%ebp)
     cc6:	0f b6 12             	movzbl (%edx),%edx
     cc9:	88 10                	mov    %dl,(%eax)
     ccb:	0f b6 00             	movzbl (%eax),%eax
     cce:	84 c0                	test   %al,%al
     cd0:	75 e2                	jne    cb4 <strcpy+0xd>
    ;
  return os;
     cd2:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
     cd5:	c9                   	leave  
     cd6:	c3                   	ret    

00000cd7 <strcmp>:

int
strcmp(const char *p, const char *q)
{
     cd7:	55                   	push   %ebp
     cd8:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
     cda:	eb 08                	jmp    ce4 <strcmp+0xd>
    p++, q++;
     cdc:	83 45 08 01          	addl   $0x1,0x8(%ebp)
     ce0:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
     ce4:	8b 45 08             	mov    0x8(%ebp),%eax
     ce7:	0f b6 00             	movzbl (%eax),%eax
     cea:	84 c0                	test   %al,%al
     cec:	74 10                	je     cfe <strcmp+0x27>
     cee:	8b 45 08             	mov    0x8(%ebp),%eax
     cf1:	0f b6 10             	movzbl (%eax),%edx
     cf4:	8b 45 0c             	mov    0xc(%ebp),%eax
     cf7:	0f b6 00             	movzbl (%eax),%eax
     cfa:	38 c2                	cmp    %al,%dl
     cfc:	74 de                	je     cdc <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
     cfe:	8b 45 08             	mov    0x8(%ebp),%eax
     d01:	0f b6 00             	movzbl (%eax),%eax
     d04:	0f b6 d0             	movzbl %al,%edx
     d07:	8b 45 0c             	mov    0xc(%ebp),%eax
     d0a:	0f b6 00             	movzbl (%eax),%eax
     d0d:	0f b6 c0             	movzbl %al,%eax
     d10:	29 c2                	sub    %eax,%edx
     d12:	89 d0                	mov    %edx,%eax
}
     d14:	5d                   	pop    %ebp
     d15:	c3                   	ret    

00000d16 <strlen>:

uint
strlen(char *s)
{
     d16:	55                   	push   %ebp
     d17:	89 e5                	mov    %esp,%ebp
     d19:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
     d1c:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
     d23:	eb 04                	jmp    d29 <strlen+0x13>
     d25:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
     d29:	8b 55 fc             	mov    -0x4(%ebp),%edx
     d2c:	8b 45 08             	mov    0x8(%ebp),%eax
     d2f:	01 d0                	add    %edx,%eax
     d31:	0f b6 00             	movzbl (%eax),%eax
     d34:	84 c0                	test   %al,%al
     d36:	75 ed                	jne    d25 <strlen+0xf>
    ;
  return n;
     d38:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
     d3b:	c9                   	leave  
     d3c:	c3                   	ret    

00000d3d <memset>:

void*
memset(void *dst, int c, uint n)
{
     d3d:	55                   	push   %ebp
     d3e:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
     d40:	8b 45 10             	mov    0x10(%ebp),%eax
     d43:	50                   	push   %eax
     d44:	ff 75 0c             	pushl  0xc(%ebp)
     d47:	ff 75 08             	pushl  0x8(%ebp)
     d4a:	e8 32 ff ff ff       	call   c81 <stosb>
     d4f:	83 c4 0c             	add    $0xc,%esp
  return dst;
     d52:	8b 45 08             	mov    0x8(%ebp),%eax
}
     d55:	c9                   	leave  
     d56:	c3                   	ret    

00000d57 <strchr>:

char*
strchr(const char *s, char c)
{
     d57:	55                   	push   %ebp
     d58:	89 e5                	mov    %esp,%ebp
     d5a:	83 ec 04             	sub    $0x4,%esp
     d5d:	8b 45 0c             	mov    0xc(%ebp),%eax
     d60:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
     d63:	eb 14                	jmp    d79 <strchr+0x22>
    if(*s == c)
     d65:	8b 45 08             	mov    0x8(%ebp),%eax
     d68:	0f b6 00             	movzbl (%eax),%eax
     d6b:	3a 45 fc             	cmp    -0x4(%ebp),%al
     d6e:	75 05                	jne    d75 <strchr+0x1e>
      return (char*)s;
     d70:	8b 45 08             	mov    0x8(%ebp),%eax
     d73:	eb 13                	jmp    d88 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
     d75:	83 45 08 01          	addl   $0x1,0x8(%ebp)
     d79:	8b 45 08             	mov    0x8(%ebp),%eax
     d7c:	0f b6 00             	movzbl (%eax),%eax
     d7f:	84 c0                	test   %al,%al
     d81:	75 e2                	jne    d65 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
     d83:	b8 00 00 00 00       	mov    $0x0,%eax
}
     d88:	c9                   	leave  
     d89:	c3                   	ret    

00000d8a <gets>:

char*
gets(char *buf, int max)
{
     d8a:	55                   	push   %ebp
     d8b:	89 e5                	mov    %esp,%ebp
     d8d:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
     d90:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
     d97:	eb 42                	jmp    ddb <gets+0x51>
    cc = read(0, &c, 1);
     d99:	83 ec 04             	sub    $0x4,%esp
     d9c:	6a 01                	push   $0x1
     d9e:	8d 45 ef             	lea    -0x11(%ebp),%eax
     da1:	50                   	push   %eax
     da2:	6a 00                	push   $0x0
     da4:	e8 47 01 00 00       	call   ef0 <read>
     da9:	83 c4 10             	add    $0x10,%esp
     dac:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
     daf:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
     db3:	7e 33                	jle    de8 <gets+0x5e>
      break;
    buf[i++] = c;
     db5:	8b 45 f4             	mov    -0xc(%ebp),%eax
     db8:	8d 50 01             	lea    0x1(%eax),%edx
     dbb:	89 55 f4             	mov    %edx,-0xc(%ebp)
     dbe:	89 c2                	mov    %eax,%edx
     dc0:	8b 45 08             	mov    0x8(%ebp),%eax
     dc3:	01 c2                	add    %eax,%edx
     dc5:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
     dc9:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
     dcb:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
     dcf:	3c 0a                	cmp    $0xa,%al
     dd1:	74 16                	je     de9 <gets+0x5f>
     dd3:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
     dd7:	3c 0d                	cmp    $0xd,%al
     dd9:	74 0e                	je     de9 <gets+0x5f>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
     ddb:	8b 45 f4             	mov    -0xc(%ebp),%eax
     dde:	83 c0 01             	add    $0x1,%eax
     de1:	3b 45 0c             	cmp    0xc(%ebp),%eax
     de4:	7c b3                	jl     d99 <gets+0xf>
     de6:	eb 01                	jmp    de9 <gets+0x5f>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
     de8:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
     de9:	8b 55 f4             	mov    -0xc(%ebp),%edx
     dec:	8b 45 08             	mov    0x8(%ebp),%eax
     def:	01 d0                	add    %edx,%eax
     df1:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
     df4:	8b 45 08             	mov    0x8(%ebp),%eax
}
     df7:	c9                   	leave  
     df8:	c3                   	ret    

00000df9 <stat>:

int
stat(char *n, struct stat *st)
{
     df9:	55                   	push   %ebp
     dfa:	89 e5                	mov    %esp,%ebp
     dfc:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
     dff:	83 ec 08             	sub    $0x8,%esp
     e02:	6a 00                	push   $0x0
     e04:	ff 75 08             	pushl  0x8(%ebp)
     e07:	e8 0c 01 00 00       	call   f18 <open>
     e0c:	83 c4 10             	add    $0x10,%esp
     e0f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
     e12:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
     e16:	79 07                	jns    e1f <stat+0x26>
    return -1;
     e18:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
     e1d:	eb 25                	jmp    e44 <stat+0x4b>
  r = fstat(fd, st);
     e1f:	83 ec 08             	sub    $0x8,%esp
     e22:	ff 75 0c             	pushl  0xc(%ebp)
     e25:	ff 75 f4             	pushl  -0xc(%ebp)
     e28:	e8 03 01 00 00       	call   f30 <fstat>
     e2d:	83 c4 10             	add    $0x10,%esp
     e30:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
     e33:	83 ec 0c             	sub    $0xc,%esp
     e36:	ff 75 f4             	pushl  -0xc(%ebp)
     e39:	e8 c2 00 00 00       	call   f00 <close>
     e3e:	83 c4 10             	add    $0x10,%esp
  return r;
     e41:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
     e44:	c9                   	leave  
     e45:	c3                   	ret    

00000e46 <atoi>:

int
atoi(const char *s)
{
     e46:	55                   	push   %ebp
     e47:	89 e5                	mov    %esp,%ebp
     e49:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
     e4c:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
     e53:	eb 25                	jmp    e7a <atoi+0x34>
    n = n*10 + *s++ - '0';
     e55:	8b 55 fc             	mov    -0x4(%ebp),%edx
     e58:	89 d0                	mov    %edx,%eax
     e5a:	c1 e0 02             	shl    $0x2,%eax
     e5d:	01 d0                	add    %edx,%eax
     e5f:	01 c0                	add    %eax,%eax
     e61:	89 c1                	mov    %eax,%ecx
     e63:	8b 45 08             	mov    0x8(%ebp),%eax
     e66:	8d 50 01             	lea    0x1(%eax),%edx
     e69:	89 55 08             	mov    %edx,0x8(%ebp)
     e6c:	0f b6 00             	movzbl (%eax),%eax
     e6f:	0f be c0             	movsbl %al,%eax
     e72:	01 c8                	add    %ecx,%eax
     e74:	83 e8 30             	sub    $0x30,%eax
     e77:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
     e7a:	8b 45 08             	mov    0x8(%ebp),%eax
     e7d:	0f b6 00             	movzbl (%eax),%eax
     e80:	3c 2f                	cmp    $0x2f,%al
     e82:	7e 0a                	jle    e8e <atoi+0x48>
     e84:	8b 45 08             	mov    0x8(%ebp),%eax
     e87:	0f b6 00             	movzbl (%eax),%eax
     e8a:	3c 39                	cmp    $0x39,%al
     e8c:	7e c7                	jle    e55 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
     e8e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
     e91:	c9                   	leave  
     e92:	c3                   	ret    

00000e93 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
     e93:	55                   	push   %ebp
     e94:	89 e5                	mov    %esp,%ebp
     e96:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
     e99:	8b 45 08             	mov    0x8(%ebp),%eax
     e9c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
     e9f:	8b 45 0c             	mov    0xc(%ebp),%eax
     ea2:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
     ea5:	eb 17                	jmp    ebe <memmove+0x2b>
    *dst++ = *src++;
     ea7:	8b 45 fc             	mov    -0x4(%ebp),%eax
     eaa:	8d 50 01             	lea    0x1(%eax),%edx
     ead:	89 55 fc             	mov    %edx,-0x4(%ebp)
     eb0:	8b 55 f8             	mov    -0x8(%ebp),%edx
     eb3:	8d 4a 01             	lea    0x1(%edx),%ecx
     eb6:	89 4d f8             	mov    %ecx,-0x8(%ebp)
     eb9:	0f b6 12             	movzbl (%edx),%edx
     ebc:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
     ebe:	8b 45 10             	mov    0x10(%ebp),%eax
     ec1:	8d 50 ff             	lea    -0x1(%eax),%edx
     ec4:	89 55 10             	mov    %edx,0x10(%ebp)
     ec7:	85 c0                	test   %eax,%eax
     ec9:	7f dc                	jg     ea7 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
     ecb:	8b 45 08             	mov    0x8(%ebp),%eax
}
     ece:	c9                   	leave  
     ecf:	c3                   	ret    

00000ed0 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
     ed0:	b8 01 00 00 00       	mov    $0x1,%eax
     ed5:	cd 40                	int    $0x40
     ed7:	c3                   	ret    

00000ed8 <exit>:
SYSCALL(exit)
     ed8:	b8 02 00 00 00       	mov    $0x2,%eax
     edd:	cd 40                	int    $0x40
     edf:	c3                   	ret    

00000ee0 <wait>:
SYSCALL(wait)
     ee0:	b8 03 00 00 00       	mov    $0x3,%eax
     ee5:	cd 40                	int    $0x40
     ee7:	c3                   	ret    

00000ee8 <pipe>:
SYSCALL(pipe)
     ee8:	b8 04 00 00 00       	mov    $0x4,%eax
     eed:	cd 40                	int    $0x40
     eef:	c3                   	ret    

00000ef0 <read>:
SYSCALL(read)
     ef0:	b8 05 00 00 00       	mov    $0x5,%eax
     ef5:	cd 40                	int    $0x40
     ef7:	c3                   	ret    

00000ef8 <write>:
SYSCALL(write)
     ef8:	b8 10 00 00 00       	mov    $0x10,%eax
     efd:	cd 40                	int    $0x40
     eff:	c3                   	ret    

00000f00 <close>:
SYSCALL(close)
     f00:	b8 15 00 00 00       	mov    $0x15,%eax
     f05:	cd 40                	int    $0x40
     f07:	c3                   	ret    

00000f08 <kill>:
SYSCALL(kill)
     f08:	b8 06 00 00 00       	mov    $0x6,%eax
     f0d:	cd 40                	int    $0x40
     f0f:	c3                   	ret    

00000f10 <exec>:
SYSCALL(exec)
     f10:	b8 07 00 00 00       	mov    $0x7,%eax
     f15:	cd 40                	int    $0x40
     f17:	c3                   	ret    

00000f18 <open>:
SYSCALL(open)
     f18:	b8 0f 00 00 00       	mov    $0xf,%eax
     f1d:	cd 40                	int    $0x40
     f1f:	c3                   	ret    

00000f20 <mknod>:
SYSCALL(mknod)
     f20:	b8 11 00 00 00       	mov    $0x11,%eax
     f25:	cd 40                	int    $0x40
     f27:	c3                   	ret    

00000f28 <unlink>:
SYSCALL(unlink)
     f28:	b8 12 00 00 00       	mov    $0x12,%eax
     f2d:	cd 40                	int    $0x40
     f2f:	c3                   	ret    

00000f30 <fstat>:
SYSCALL(fstat)
     f30:	b8 08 00 00 00       	mov    $0x8,%eax
     f35:	cd 40                	int    $0x40
     f37:	c3                   	ret    

00000f38 <link>:
SYSCALL(link)
     f38:	b8 13 00 00 00       	mov    $0x13,%eax
     f3d:	cd 40                	int    $0x40
     f3f:	c3                   	ret    

00000f40 <mkdir>:
SYSCALL(mkdir)
     f40:	b8 14 00 00 00       	mov    $0x14,%eax
     f45:	cd 40                	int    $0x40
     f47:	c3                   	ret    

00000f48 <chdir>:
SYSCALL(chdir)
     f48:	b8 09 00 00 00       	mov    $0x9,%eax
     f4d:	cd 40                	int    $0x40
     f4f:	c3                   	ret    

00000f50 <dup>:
SYSCALL(dup)
     f50:	b8 0a 00 00 00       	mov    $0xa,%eax
     f55:	cd 40                	int    $0x40
     f57:	c3                   	ret    

00000f58 <getpid>:
SYSCALL(getpid)
     f58:	b8 0b 00 00 00       	mov    $0xb,%eax
     f5d:	cd 40                	int    $0x40
     f5f:	c3                   	ret    

00000f60 <sbrk>:
SYSCALL(sbrk)
     f60:	b8 0c 00 00 00       	mov    $0xc,%eax
     f65:	cd 40                	int    $0x40
     f67:	c3                   	ret    

00000f68 <sleep>:
SYSCALL(sleep)
     f68:	b8 0d 00 00 00       	mov    $0xd,%eax
     f6d:	cd 40                	int    $0x40
     f6f:	c3                   	ret    

00000f70 <uptime>:
SYSCALL(uptime)
     f70:	b8 0e 00 00 00       	mov    $0xe,%eax
     f75:	cd 40                	int    $0x40
     f77:	c3                   	ret    

00000f78 <mount>:
SYSCALL(mount)
     f78:	b8 16 00 00 00       	mov    $0x16,%eax
     f7d:	cd 40                	int    $0x40
     f7f:	c3                   	ret    

00000f80 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
     f80:	55                   	push   %ebp
     f81:	89 e5                	mov    %esp,%ebp
     f83:	83 ec 18             	sub    $0x18,%esp
     f86:	8b 45 0c             	mov    0xc(%ebp),%eax
     f89:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
     f8c:	83 ec 04             	sub    $0x4,%esp
     f8f:	6a 01                	push   $0x1
     f91:	8d 45 f4             	lea    -0xc(%ebp),%eax
     f94:	50                   	push   %eax
     f95:	ff 75 08             	pushl  0x8(%ebp)
     f98:	e8 5b ff ff ff       	call   ef8 <write>
     f9d:	83 c4 10             	add    $0x10,%esp
}
     fa0:	90                   	nop
     fa1:	c9                   	leave  
     fa2:	c3                   	ret    

00000fa3 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
     fa3:	55                   	push   %ebp
     fa4:	89 e5                	mov    %esp,%ebp
     fa6:	53                   	push   %ebx
     fa7:	83 ec 24             	sub    $0x24,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
     faa:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
     fb1:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
     fb5:	74 17                	je     fce <printint+0x2b>
     fb7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
     fbb:	79 11                	jns    fce <printint+0x2b>
    neg = 1;
     fbd:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
     fc4:	8b 45 0c             	mov    0xc(%ebp),%eax
     fc7:	f7 d8                	neg    %eax
     fc9:	89 45 ec             	mov    %eax,-0x14(%ebp)
     fcc:	eb 06                	jmp    fd4 <printint+0x31>
  } else {
    x = xx;
     fce:	8b 45 0c             	mov    0xc(%ebp),%eax
     fd1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
     fd4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
     fdb:	8b 4d f4             	mov    -0xc(%ebp),%ecx
     fde:	8d 41 01             	lea    0x1(%ecx),%eax
     fe1:	89 45 f4             	mov    %eax,-0xc(%ebp)
     fe4:	8b 5d 10             	mov    0x10(%ebp),%ebx
     fe7:	8b 45 ec             	mov    -0x14(%ebp),%eax
     fea:	ba 00 00 00 00       	mov    $0x0,%edx
     fef:	f7 f3                	div    %ebx
     ff1:	89 d0                	mov    %edx,%eax
     ff3:	0f b6 80 a8 19 00 00 	movzbl 0x19a8(%eax),%eax
     ffa:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
     ffe:	8b 5d 10             	mov    0x10(%ebp),%ebx
    1001:	8b 45 ec             	mov    -0x14(%ebp),%eax
    1004:	ba 00 00 00 00       	mov    $0x0,%edx
    1009:	f7 f3                	div    %ebx
    100b:	89 45 ec             	mov    %eax,-0x14(%ebp)
    100e:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    1012:	75 c7                	jne    fdb <printint+0x38>
  if(neg)
    1014:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    1018:	74 2d                	je     1047 <printint+0xa4>
    buf[i++] = '-';
    101a:	8b 45 f4             	mov    -0xc(%ebp),%eax
    101d:	8d 50 01             	lea    0x1(%eax),%edx
    1020:	89 55 f4             	mov    %edx,-0xc(%ebp)
    1023:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
    1028:	eb 1d                	jmp    1047 <printint+0xa4>
    putc(fd, buf[i]);
    102a:	8d 55 dc             	lea    -0x24(%ebp),%edx
    102d:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1030:	01 d0                	add    %edx,%eax
    1032:	0f b6 00             	movzbl (%eax),%eax
    1035:	0f be c0             	movsbl %al,%eax
    1038:	83 ec 08             	sub    $0x8,%esp
    103b:	50                   	push   %eax
    103c:	ff 75 08             	pushl  0x8(%ebp)
    103f:	e8 3c ff ff ff       	call   f80 <putc>
    1044:	83 c4 10             	add    $0x10,%esp
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
    1047:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
    104b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    104f:	79 d9                	jns    102a <printint+0x87>
    putc(fd, buf[i]);
}
    1051:	90                   	nop
    1052:	8b 5d fc             	mov    -0x4(%ebp),%ebx
    1055:	c9                   	leave  
    1056:	c3                   	ret    

00001057 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
    1057:	55                   	push   %ebp
    1058:	89 e5                	mov    %esp,%ebp
    105a:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
    105d:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
    1064:	8d 45 0c             	lea    0xc(%ebp),%eax
    1067:	83 c0 04             	add    $0x4,%eax
    106a:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
    106d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    1074:	e9 59 01 00 00       	jmp    11d2 <printf+0x17b>
    c = fmt[i] & 0xff;
    1079:	8b 55 0c             	mov    0xc(%ebp),%edx
    107c:	8b 45 f0             	mov    -0x10(%ebp),%eax
    107f:	01 d0                	add    %edx,%eax
    1081:	0f b6 00             	movzbl (%eax),%eax
    1084:	0f be c0             	movsbl %al,%eax
    1087:	25 ff 00 00 00       	and    $0xff,%eax
    108c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
    108f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    1093:	75 2c                	jne    10c1 <printf+0x6a>
      if(c == '%'){
    1095:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
    1099:	75 0c                	jne    10a7 <printf+0x50>
        state = '%';
    109b:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
    10a2:	e9 27 01 00 00       	jmp    11ce <printf+0x177>
      } else {
        putc(fd, c);
    10a7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    10aa:	0f be c0             	movsbl %al,%eax
    10ad:	83 ec 08             	sub    $0x8,%esp
    10b0:	50                   	push   %eax
    10b1:	ff 75 08             	pushl  0x8(%ebp)
    10b4:	e8 c7 fe ff ff       	call   f80 <putc>
    10b9:	83 c4 10             	add    $0x10,%esp
    10bc:	e9 0d 01 00 00       	jmp    11ce <printf+0x177>
      }
    } else if(state == '%'){
    10c1:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
    10c5:	0f 85 03 01 00 00    	jne    11ce <printf+0x177>
      if(c == 'd'){
    10cb:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
    10cf:	75 1e                	jne    10ef <printf+0x98>
        printint(fd, *ap, 10, 1);
    10d1:	8b 45 e8             	mov    -0x18(%ebp),%eax
    10d4:	8b 00                	mov    (%eax),%eax
    10d6:	6a 01                	push   $0x1
    10d8:	6a 0a                	push   $0xa
    10da:	50                   	push   %eax
    10db:	ff 75 08             	pushl  0x8(%ebp)
    10de:	e8 c0 fe ff ff       	call   fa3 <printint>
    10e3:	83 c4 10             	add    $0x10,%esp
        ap++;
    10e6:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    10ea:	e9 d8 00 00 00       	jmp    11c7 <printf+0x170>
      } else if(c == 'x' || c == 'p'){
    10ef:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
    10f3:	74 06                	je     10fb <printf+0xa4>
    10f5:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
    10f9:	75 1e                	jne    1119 <printf+0xc2>
        printint(fd, *ap, 16, 0);
    10fb:	8b 45 e8             	mov    -0x18(%ebp),%eax
    10fe:	8b 00                	mov    (%eax),%eax
    1100:	6a 00                	push   $0x0
    1102:	6a 10                	push   $0x10
    1104:	50                   	push   %eax
    1105:	ff 75 08             	pushl  0x8(%ebp)
    1108:	e8 96 fe ff ff       	call   fa3 <printint>
    110d:	83 c4 10             	add    $0x10,%esp
        ap++;
    1110:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    1114:	e9 ae 00 00 00       	jmp    11c7 <printf+0x170>
      } else if(c == 's'){
    1119:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
    111d:	75 43                	jne    1162 <printf+0x10b>
        s = (char*)*ap;
    111f:	8b 45 e8             	mov    -0x18(%ebp),%eax
    1122:	8b 00                	mov    (%eax),%eax
    1124:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
    1127:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
    112b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    112f:	75 25                	jne    1156 <printf+0xff>
          s = "(null)";
    1131:	c7 45 f4 0c 15 00 00 	movl   $0x150c,-0xc(%ebp)
        while(*s != 0){
    1138:	eb 1c                	jmp    1156 <printf+0xff>
          putc(fd, *s);
    113a:	8b 45 f4             	mov    -0xc(%ebp),%eax
    113d:	0f b6 00             	movzbl (%eax),%eax
    1140:	0f be c0             	movsbl %al,%eax
    1143:	83 ec 08             	sub    $0x8,%esp
    1146:	50                   	push   %eax
    1147:	ff 75 08             	pushl  0x8(%ebp)
    114a:	e8 31 fe ff ff       	call   f80 <putc>
    114f:	83 c4 10             	add    $0x10,%esp
          s++;
    1152:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
    1156:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1159:	0f b6 00             	movzbl (%eax),%eax
    115c:	84 c0                	test   %al,%al
    115e:	75 da                	jne    113a <printf+0xe3>
    1160:	eb 65                	jmp    11c7 <printf+0x170>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
    1162:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
    1166:	75 1d                	jne    1185 <printf+0x12e>
        putc(fd, *ap);
    1168:	8b 45 e8             	mov    -0x18(%ebp),%eax
    116b:	8b 00                	mov    (%eax),%eax
    116d:	0f be c0             	movsbl %al,%eax
    1170:	83 ec 08             	sub    $0x8,%esp
    1173:	50                   	push   %eax
    1174:	ff 75 08             	pushl  0x8(%ebp)
    1177:	e8 04 fe ff ff       	call   f80 <putc>
    117c:	83 c4 10             	add    $0x10,%esp
        ap++;
    117f:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    1183:	eb 42                	jmp    11c7 <printf+0x170>
      } else if(c == '%'){
    1185:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
    1189:	75 17                	jne    11a2 <printf+0x14b>
        putc(fd, c);
    118b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    118e:	0f be c0             	movsbl %al,%eax
    1191:	83 ec 08             	sub    $0x8,%esp
    1194:	50                   	push   %eax
    1195:	ff 75 08             	pushl  0x8(%ebp)
    1198:	e8 e3 fd ff ff       	call   f80 <putc>
    119d:	83 c4 10             	add    $0x10,%esp
    11a0:	eb 25                	jmp    11c7 <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
    11a2:	83 ec 08             	sub    $0x8,%esp
    11a5:	6a 25                	push   $0x25
    11a7:	ff 75 08             	pushl  0x8(%ebp)
    11aa:	e8 d1 fd ff ff       	call   f80 <putc>
    11af:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
    11b2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    11b5:	0f be c0             	movsbl %al,%eax
    11b8:	83 ec 08             	sub    $0x8,%esp
    11bb:	50                   	push   %eax
    11bc:	ff 75 08             	pushl  0x8(%ebp)
    11bf:	e8 bc fd ff ff       	call   f80 <putc>
    11c4:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
    11c7:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
    11ce:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
    11d2:	8b 55 0c             	mov    0xc(%ebp),%edx
    11d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
    11d8:	01 d0                	add    %edx,%eax
    11da:	0f b6 00             	movzbl (%eax),%eax
    11dd:	84 c0                	test   %al,%al
    11df:	0f 85 94 fe ff ff    	jne    1079 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
    11e5:	90                   	nop
    11e6:	c9                   	leave  
    11e7:	c3                   	ret    

000011e8 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    11e8:	55                   	push   %ebp
    11e9:	89 e5                	mov    %esp,%ebp
    11eb:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
    11ee:	8b 45 08             	mov    0x8(%ebp),%eax
    11f1:	83 e8 08             	sub    $0x8,%eax
    11f4:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    11f7:	a1 2c 1a 00 00       	mov    0x1a2c,%eax
    11fc:	89 45 fc             	mov    %eax,-0x4(%ebp)
    11ff:	eb 24                	jmp    1225 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    1201:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1204:	8b 00                	mov    (%eax),%eax
    1206:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    1209:	77 12                	ja     121d <free+0x35>
    120b:	8b 45 f8             	mov    -0x8(%ebp),%eax
    120e:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    1211:	77 24                	ja     1237 <free+0x4f>
    1213:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1216:	8b 00                	mov    (%eax),%eax
    1218:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    121b:	77 1a                	ja     1237 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    121d:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1220:	8b 00                	mov    (%eax),%eax
    1222:	89 45 fc             	mov    %eax,-0x4(%ebp)
    1225:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1228:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    122b:	76 d4                	jbe    1201 <free+0x19>
    122d:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1230:	8b 00                	mov    (%eax),%eax
    1232:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    1235:	76 ca                	jbe    1201 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    1237:	8b 45 f8             	mov    -0x8(%ebp),%eax
    123a:	8b 40 04             	mov    0x4(%eax),%eax
    123d:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
    1244:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1247:	01 c2                	add    %eax,%edx
    1249:	8b 45 fc             	mov    -0x4(%ebp),%eax
    124c:	8b 00                	mov    (%eax),%eax
    124e:	39 c2                	cmp    %eax,%edx
    1250:	75 24                	jne    1276 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
    1252:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1255:	8b 50 04             	mov    0x4(%eax),%edx
    1258:	8b 45 fc             	mov    -0x4(%ebp),%eax
    125b:	8b 00                	mov    (%eax),%eax
    125d:	8b 40 04             	mov    0x4(%eax),%eax
    1260:	01 c2                	add    %eax,%edx
    1262:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1265:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
    1268:	8b 45 fc             	mov    -0x4(%ebp),%eax
    126b:	8b 00                	mov    (%eax),%eax
    126d:	8b 10                	mov    (%eax),%edx
    126f:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1272:	89 10                	mov    %edx,(%eax)
    1274:	eb 0a                	jmp    1280 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
    1276:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1279:	8b 10                	mov    (%eax),%edx
    127b:	8b 45 f8             	mov    -0x8(%ebp),%eax
    127e:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
    1280:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1283:	8b 40 04             	mov    0x4(%eax),%eax
    1286:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
    128d:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1290:	01 d0                	add    %edx,%eax
    1292:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    1295:	75 20                	jne    12b7 <free+0xcf>
    p->s.size += bp->s.size;
    1297:	8b 45 fc             	mov    -0x4(%ebp),%eax
    129a:	8b 50 04             	mov    0x4(%eax),%edx
    129d:	8b 45 f8             	mov    -0x8(%ebp),%eax
    12a0:	8b 40 04             	mov    0x4(%eax),%eax
    12a3:	01 c2                	add    %eax,%edx
    12a5:	8b 45 fc             	mov    -0x4(%ebp),%eax
    12a8:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
    12ab:	8b 45 f8             	mov    -0x8(%ebp),%eax
    12ae:	8b 10                	mov    (%eax),%edx
    12b0:	8b 45 fc             	mov    -0x4(%ebp),%eax
    12b3:	89 10                	mov    %edx,(%eax)
    12b5:	eb 08                	jmp    12bf <free+0xd7>
  } else
    p->s.ptr = bp;
    12b7:	8b 45 fc             	mov    -0x4(%ebp),%eax
    12ba:	8b 55 f8             	mov    -0x8(%ebp),%edx
    12bd:	89 10                	mov    %edx,(%eax)
  freep = p;
    12bf:	8b 45 fc             	mov    -0x4(%ebp),%eax
    12c2:	a3 2c 1a 00 00       	mov    %eax,0x1a2c
}
    12c7:	90                   	nop
    12c8:	c9                   	leave  
    12c9:	c3                   	ret    

000012ca <morecore>:

static Header*
morecore(uint nu)
{
    12ca:	55                   	push   %ebp
    12cb:	89 e5                	mov    %esp,%ebp
    12cd:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
    12d0:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
    12d7:	77 07                	ja     12e0 <morecore+0x16>
    nu = 4096;
    12d9:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
    12e0:	8b 45 08             	mov    0x8(%ebp),%eax
    12e3:	c1 e0 03             	shl    $0x3,%eax
    12e6:	83 ec 0c             	sub    $0xc,%esp
    12e9:	50                   	push   %eax
    12ea:	e8 71 fc ff ff       	call   f60 <sbrk>
    12ef:	83 c4 10             	add    $0x10,%esp
    12f2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
    12f5:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
    12f9:	75 07                	jne    1302 <morecore+0x38>
    return 0;
    12fb:	b8 00 00 00 00       	mov    $0x0,%eax
    1300:	eb 26                	jmp    1328 <morecore+0x5e>
  hp = (Header*)p;
    1302:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1305:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
    1308:	8b 45 f0             	mov    -0x10(%ebp),%eax
    130b:	8b 55 08             	mov    0x8(%ebp),%edx
    130e:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
    1311:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1314:	83 c0 08             	add    $0x8,%eax
    1317:	83 ec 0c             	sub    $0xc,%esp
    131a:	50                   	push   %eax
    131b:	e8 c8 fe ff ff       	call   11e8 <free>
    1320:	83 c4 10             	add    $0x10,%esp
  return freep;
    1323:	a1 2c 1a 00 00       	mov    0x1a2c,%eax
}
    1328:	c9                   	leave  
    1329:	c3                   	ret    

0000132a <malloc>:

void*
malloc(uint nbytes)
{
    132a:	55                   	push   %ebp
    132b:	89 e5                	mov    %esp,%ebp
    132d:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    1330:	8b 45 08             	mov    0x8(%ebp),%eax
    1333:	83 c0 07             	add    $0x7,%eax
    1336:	c1 e8 03             	shr    $0x3,%eax
    1339:	83 c0 01             	add    $0x1,%eax
    133c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
    133f:	a1 2c 1a 00 00       	mov    0x1a2c,%eax
    1344:	89 45 f0             	mov    %eax,-0x10(%ebp)
    1347:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    134b:	75 23                	jne    1370 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
    134d:	c7 45 f0 24 1a 00 00 	movl   $0x1a24,-0x10(%ebp)
    1354:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1357:	a3 2c 1a 00 00       	mov    %eax,0x1a2c
    135c:	a1 2c 1a 00 00       	mov    0x1a2c,%eax
    1361:	a3 24 1a 00 00       	mov    %eax,0x1a24
    base.s.size = 0;
    1366:	c7 05 28 1a 00 00 00 	movl   $0x0,0x1a28
    136d:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    1370:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1373:	8b 00                	mov    (%eax),%eax
    1375:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
    1378:	8b 45 f4             	mov    -0xc(%ebp),%eax
    137b:	8b 40 04             	mov    0x4(%eax),%eax
    137e:	3b 45 ec             	cmp    -0x14(%ebp),%eax
    1381:	72 4d                	jb     13d0 <malloc+0xa6>
      if(p->s.size == nunits)
    1383:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1386:	8b 40 04             	mov    0x4(%eax),%eax
    1389:	3b 45 ec             	cmp    -0x14(%ebp),%eax
    138c:	75 0c                	jne    139a <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
    138e:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1391:	8b 10                	mov    (%eax),%edx
    1393:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1396:	89 10                	mov    %edx,(%eax)
    1398:	eb 26                	jmp    13c0 <malloc+0x96>
      else {
        p->s.size -= nunits;
    139a:	8b 45 f4             	mov    -0xc(%ebp),%eax
    139d:	8b 40 04             	mov    0x4(%eax),%eax
    13a0:	2b 45 ec             	sub    -0x14(%ebp),%eax
    13a3:	89 c2                	mov    %eax,%edx
    13a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
    13a8:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
    13ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
    13ae:	8b 40 04             	mov    0x4(%eax),%eax
    13b1:	c1 e0 03             	shl    $0x3,%eax
    13b4:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
    13b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
    13ba:	8b 55 ec             	mov    -0x14(%ebp),%edx
    13bd:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
    13c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
    13c3:	a3 2c 1a 00 00       	mov    %eax,0x1a2c
      return (void*)(p + 1);
    13c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
    13cb:	83 c0 08             	add    $0x8,%eax
    13ce:	eb 3b                	jmp    140b <malloc+0xe1>
    }
    if(p == freep)
    13d0:	a1 2c 1a 00 00       	mov    0x1a2c,%eax
    13d5:	39 45 f4             	cmp    %eax,-0xc(%ebp)
    13d8:	75 1e                	jne    13f8 <malloc+0xce>
      if((p = morecore(nunits)) == 0)
    13da:	83 ec 0c             	sub    $0xc,%esp
    13dd:	ff 75 ec             	pushl  -0x14(%ebp)
    13e0:	e8 e5 fe ff ff       	call   12ca <morecore>
    13e5:	83 c4 10             	add    $0x10,%esp
    13e8:	89 45 f4             	mov    %eax,-0xc(%ebp)
    13eb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    13ef:	75 07                	jne    13f8 <malloc+0xce>
        return 0;
    13f1:	b8 00 00 00 00       	mov    $0x0,%eax
    13f6:	eb 13                	jmp    140b <malloc+0xe1>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    13f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
    13fb:	89 45 f0             	mov    %eax,-0x10(%ebp)
    13fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1401:	8b 00                	mov    (%eax),%eax
    1403:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
    1406:	e9 6d ff ff ff       	jmp    1378 <malloc+0x4e>
}
    140b:	c9                   	leave  
    140c:	c3                   	ret    
