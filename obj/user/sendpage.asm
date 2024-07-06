
obj/user/sendpage:     file format elf32-i386


Disassembly of section .text:

00800020 <_start>:
// starts us running when we are initially loaded into a new environment.
.text
.globl _start
_start:
	// See if we were started with arguments on the stack
	cmpl $USTACKTOP, %esp
  800020:	81 fc 00 e0 bf ee    	cmp    $0xeebfe000,%esp
	jne args_exist
  800026:	75 04                	jne    80002c <args_exist>

	// If not, push dummy argc/argv arguments.
	// This happens when we are loaded by the kernel,
	// because the kernel does not know about passing arguments.
	pushl $0
  800028:	6a 00                	push   $0x0
	pushl $0
  80002a:	6a 00                	push   $0x0

0080002c <args_exist>:

args_exist:
	call libmain
  80002c:	e8 77 01 00 00       	call   8001a8 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#define TEMP_ADDR	((char*)0xa00000)
#define TEMP_ADDR_CHILD	((char*)0xb00000)

void
umain(int argc, char **argv)
{
  800033:	f3 0f 1e fb          	endbr32 
  800037:	55                   	push   %ebp
  800038:	89 e5                	mov    %esp,%ebp
  80003a:	83 ec 18             	sub    $0x18,%esp
	envid_t who;

	if ((who = fork()) == 0) {
  80003d:	e8 a1 0f 00 00       	call   800fe3 <fork>
  800042:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800045:	85 c0                	test   %eax,%eax
  800047:	0f 84 a5 00 00 00    	je     8000f2 <umain+0xbf>
		ipc_send(who, 0, TEMP_ADDR_CHILD, PTE_P | PTE_W | PTE_U);
		return;
	}

	// Parent
	sys_page_alloc(thisenv->env_id, TEMP_ADDR, PTE_P | PTE_W | PTE_U);
  80004d:	a1 0c 20 80 00       	mov    0x80200c,%eax
  800052:	8b 40 48             	mov    0x48(%eax),%eax
  800055:	83 ec 04             	sub    $0x4,%esp
  800058:	6a 07                	push   $0x7
  80005a:	68 00 00 a0 00       	push   $0xa00000
  80005f:	50                   	push   %eax
  800060:	e8 cb 0c 00 00       	call   800d30 <sys_page_alloc>
	memcpy(TEMP_ADDR, str1, strlen(str1) + 1);
  800065:	83 c4 04             	add    $0x4,%esp
  800068:	ff 35 04 20 80 00    	pushl  0x802004
  80006e:	e8 38 08 00 00       	call   8008ab <strlen>
  800073:	83 c4 0c             	add    $0xc,%esp
  800076:	83 c0 01             	add    $0x1,%eax
  800079:	50                   	push   %eax
  80007a:	ff 35 04 20 80 00    	pushl  0x802004
  800080:	68 00 00 a0 00       	push   $0xa00000
  800085:	e8 80 0a 00 00       	call   800b0a <memcpy>
	ipc_send(who, 0, TEMP_ADDR, PTE_P | PTE_W | PTE_U);
  80008a:	6a 07                	push   $0x7
  80008c:	68 00 00 a0 00       	push   $0xa00000
  800091:	6a 00                	push   $0x0
  800093:	ff 75 f4             	pushl  -0xc(%ebp)
  800096:	e8 c9 11 00 00       	call   801264 <ipc_send>

	ipc_recv(&who, TEMP_ADDR, 0);
  80009b:	83 c4 1c             	add    $0x1c,%esp
  80009e:	6a 00                	push   $0x0
  8000a0:	68 00 00 a0 00       	push   $0xa00000
  8000a5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8000a8:	50                   	push   %eax
  8000a9:	e8 49 11 00 00       	call   8011f7 <ipc_recv>
	cprintf("%x got message: %s\n", who, TEMP_ADDR);
  8000ae:	83 c4 0c             	add    $0xc,%esp
  8000b1:	68 00 00 a0 00       	push   $0xa00000
  8000b6:	ff 75 f4             	pushl  -0xc(%ebp)
  8000b9:	68 40 16 80 00       	push   $0x801640
  8000be:	e8 e2 01 00 00       	call   8002a5 <cprintf>
	if (strncmp(TEMP_ADDR, str2, strlen(str2)) == 0)
  8000c3:	83 c4 04             	add    $0x4,%esp
  8000c6:	ff 35 00 20 80 00    	pushl  0x802000
  8000cc:	e8 da 07 00 00       	call   8008ab <strlen>
  8000d1:	83 c4 0c             	add    $0xc,%esp
  8000d4:	50                   	push   %eax
  8000d5:	ff 35 00 20 80 00    	pushl  0x802000
  8000db:	68 00 00 a0 00       	push   $0xa00000
  8000e0:	e8 f2 08 00 00       	call   8009d7 <strncmp>
  8000e5:	83 c4 10             	add    $0x10,%esp
  8000e8:	85 c0                	test   %eax,%eax
  8000ea:	0f 84 a3 00 00 00    	je     800193 <umain+0x160>
		cprintf("parent received correct message\n");
	return;
}
  8000f0:	c9                   	leave  
  8000f1:	c3                   	ret    
		ipc_recv(&who, TEMP_ADDR_CHILD, 0);
  8000f2:	83 ec 04             	sub    $0x4,%esp
  8000f5:	6a 00                	push   $0x0
  8000f7:	68 00 00 b0 00       	push   $0xb00000
  8000fc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8000ff:	50                   	push   %eax
  800100:	e8 f2 10 00 00       	call   8011f7 <ipc_recv>
		cprintf("%x got message: %s\n", who, TEMP_ADDR_CHILD);
  800105:	83 c4 0c             	add    $0xc,%esp
  800108:	68 00 00 b0 00       	push   $0xb00000
  80010d:	ff 75 f4             	pushl  -0xc(%ebp)
  800110:	68 40 16 80 00       	push   $0x801640
  800115:	e8 8b 01 00 00       	call   8002a5 <cprintf>
		if (strncmp(TEMP_ADDR_CHILD, str1, strlen(str1)) == 0)
  80011a:	83 c4 04             	add    $0x4,%esp
  80011d:	ff 35 04 20 80 00    	pushl  0x802004
  800123:	e8 83 07 00 00       	call   8008ab <strlen>
  800128:	83 c4 0c             	add    $0xc,%esp
  80012b:	50                   	push   %eax
  80012c:	ff 35 04 20 80 00    	pushl  0x802004
  800132:	68 00 00 b0 00       	push   $0xb00000
  800137:	e8 9b 08 00 00       	call   8009d7 <strncmp>
  80013c:	83 c4 10             	add    $0x10,%esp
  80013f:	85 c0                	test   %eax,%eax
  800141:	74 3e                	je     800181 <umain+0x14e>
		memcpy(TEMP_ADDR_CHILD, str2, strlen(str2) + 1);
  800143:	83 ec 0c             	sub    $0xc,%esp
  800146:	ff 35 00 20 80 00    	pushl  0x802000
  80014c:	e8 5a 07 00 00       	call   8008ab <strlen>
  800151:	83 c4 0c             	add    $0xc,%esp
  800154:	83 c0 01             	add    $0x1,%eax
  800157:	50                   	push   %eax
  800158:	ff 35 00 20 80 00    	pushl  0x802000
  80015e:	68 00 00 b0 00       	push   $0xb00000
  800163:	e8 a2 09 00 00       	call   800b0a <memcpy>
		ipc_send(who, 0, TEMP_ADDR_CHILD, PTE_P | PTE_W | PTE_U);
  800168:	6a 07                	push   $0x7
  80016a:	68 00 00 b0 00       	push   $0xb00000
  80016f:	6a 00                	push   $0x0
  800171:	ff 75 f4             	pushl  -0xc(%ebp)
  800174:	e8 eb 10 00 00       	call   801264 <ipc_send>
		return;
  800179:	83 c4 20             	add    $0x20,%esp
  80017c:	e9 6f ff ff ff       	jmp    8000f0 <umain+0xbd>
			cprintf("child received correct message\n");
  800181:	83 ec 0c             	sub    $0xc,%esp
  800184:	68 54 16 80 00       	push   $0x801654
  800189:	e8 17 01 00 00       	call   8002a5 <cprintf>
  80018e:	83 c4 10             	add    $0x10,%esp
  800191:	eb b0                	jmp    800143 <umain+0x110>
		cprintf("parent received correct message\n");
  800193:	83 ec 0c             	sub    $0xc,%esp
  800196:	68 74 16 80 00       	push   $0x801674
  80019b:	e8 05 01 00 00       	call   8002a5 <cprintf>
  8001a0:	83 c4 10             	add    $0x10,%esp
  8001a3:	e9 48 ff ff ff       	jmp    8000f0 <umain+0xbd>

008001a8 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001a8:	f3 0f 1e fb          	endbr32 
  8001ac:	55                   	push   %ebp
  8001ad:	89 e5                	mov    %esp,%ebp
  8001af:	56                   	push   %esi
  8001b0:	53                   	push   %ebx
  8001b1:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001b4:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv=&envs[ENVX(sys_getenvid())];
  8001b7:	e8 2e 0b 00 00       	call   800cea <sys_getenvid>
  8001bc:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001c1:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8001c4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001c9:	a3 0c 20 80 00       	mov    %eax,0x80200c

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001ce:	85 db                	test   %ebx,%ebx
  8001d0:	7e 07                	jle    8001d9 <libmain+0x31>
		binaryname = argv[0];
  8001d2:	8b 06                	mov    (%esi),%eax
  8001d4:	a3 08 20 80 00       	mov    %eax,0x802008

	// call user main routine
	umain(argc, argv);
  8001d9:	83 ec 08             	sub    $0x8,%esp
  8001dc:	56                   	push   %esi
  8001dd:	53                   	push   %ebx
  8001de:	e8 50 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8001e3:	e8 0a 00 00 00       	call   8001f2 <exit>
}
  8001e8:	83 c4 10             	add    $0x10,%esp
  8001eb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001ee:	5b                   	pop    %ebx
  8001ef:	5e                   	pop    %esi
  8001f0:	5d                   	pop    %ebp
  8001f1:	c3                   	ret    

008001f2 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001f2:	f3 0f 1e fb          	endbr32 
  8001f6:	55                   	push   %ebp
  8001f7:	89 e5                	mov    %esp,%ebp
  8001f9:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8001fc:	6a 00                	push   $0x0
  8001fe:	e8 a2 0a 00 00       	call   800ca5 <sys_env_destroy>
}
  800203:	83 c4 10             	add    $0x10,%esp
  800206:	c9                   	leave  
  800207:	c3                   	ret    

00800208 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800208:	f3 0f 1e fb          	endbr32 
  80020c:	55                   	push   %ebp
  80020d:	89 e5                	mov    %esp,%ebp
  80020f:	53                   	push   %ebx
  800210:	83 ec 04             	sub    $0x4,%esp
  800213:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800216:	8b 13                	mov    (%ebx),%edx
  800218:	8d 42 01             	lea    0x1(%edx),%eax
  80021b:	89 03                	mov    %eax,(%ebx)
  80021d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800220:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800224:	3d ff 00 00 00       	cmp    $0xff,%eax
  800229:	74 09                	je     800234 <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80022b:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80022f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800232:	c9                   	leave  
  800233:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800234:	83 ec 08             	sub    $0x8,%esp
  800237:	68 ff 00 00 00       	push   $0xff
  80023c:	8d 43 08             	lea    0x8(%ebx),%eax
  80023f:	50                   	push   %eax
  800240:	e8 1b 0a 00 00       	call   800c60 <sys_cputs>
		b->idx = 0;
  800245:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80024b:	83 c4 10             	add    $0x10,%esp
  80024e:	eb db                	jmp    80022b <putch+0x23>

00800250 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800250:	f3 0f 1e fb          	endbr32 
  800254:	55                   	push   %ebp
  800255:	89 e5                	mov    %esp,%ebp
  800257:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80025d:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800264:	00 00 00 
	b.cnt = 0;
  800267:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80026e:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800271:	ff 75 0c             	pushl  0xc(%ebp)
  800274:	ff 75 08             	pushl  0x8(%ebp)
  800277:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80027d:	50                   	push   %eax
  80027e:	68 08 02 80 00       	push   $0x800208
  800283:	e8 20 01 00 00       	call   8003a8 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800288:	83 c4 08             	add    $0x8,%esp
  80028b:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800291:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800297:	50                   	push   %eax
  800298:	e8 c3 09 00 00       	call   800c60 <sys_cputs>

	return b.cnt;
}
  80029d:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002a3:	c9                   	leave  
  8002a4:	c3                   	ret    

008002a5 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002a5:	f3 0f 1e fb          	endbr32 
  8002a9:	55                   	push   %ebp
  8002aa:	89 e5                	mov    %esp,%ebp
  8002ac:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002af:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002b2:	50                   	push   %eax
  8002b3:	ff 75 08             	pushl  0x8(%ebp)
  8002b6:	e8 95 ff ff ff       	call   800250 <vcprintf>
	va_end(ap);

	return cnt;
}
  8002bb:	c9                   	leave  
  8002bc:	c3                   	ret    

008002bd <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002bd:	55                   	push   %ebp
  8002be:	89 e5                	mov    %esp,%ebp
  8002c0:	57                   	push   %edi
  8002c1:	56                   	push   %esi
  8002c2:	53                   	push   %ebx
  8002c3:	83 ec 1c             	sub    $0x1c,%esp
  8002c6:	89 c7                	mov    %eax,%edi
  8002c8:	89 d6                	mov    %edx,%esi
  8002ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8002cd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002d0:	89 d1                	mov    %edx,%ecx
  8002d2:	89 c2                	mov    %eax,%edx
  8002d4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002d7:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8002da:	8b 45 10             	mov    0x10(%ebp),%eax
  8002dd:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002e0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002e3:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8002ea:	39 c2                	cmp    %eax,%edx
  8002ec:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8002ef:	72 3e                	jb     80032f <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002f1:	83 ec 0c             	sub    $0xc,%esp
  8002f4:	ff 75 18             	pushl  0x18(%ebp)
  8002f7:	83 eb 01             	sub    $0x1,%ebx
  8002fa:	53                   	push   %ebx
  8002fb:	50                   	push   %eax
  8002fc:	83 ec 08             	sub    $0x8,%esp
  8002ff:	ff 75 e4             	pushl  -0x1c(%ebp)
  800302:	ff 75 e0             	pushl  -0x20(%ebp)
  800305:	ff 75 dc             	pushl  -0x24(%ebp)
  800308:	ff 75 d8             	pushl  -0x28(%ebp)
  80030b:	e8 c0 10 00 00       	call   8013d0 <__udivdi3>
  800310:	83 c4 18             	add    $0x18,%esp
  800313:	52                   	push   %edx
  800314:	50                   	push   %eax
  800315:	89 f2                	mov    %esi,%edx
  800317:	89 f8                	mov    %edi,%eax
  800319:	e8 9f ff ff ff       	call   8002bd <printnum>
  80031e:	83 c4 20             	add    $0x20,%esp
  800321:	eb 13                	jmp    800336 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800323:	83 ec 08             	sub    $0x8,%esp
  800326:	56                   	push   %esi
  800327:	ff 75 18             	pushl  0x18(%ebp)
  80032a:	ff d7                	call   *%edi
  80032c:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80032f:	83 eb 01             	sub    $0x1,%ebx
  800332:	85 db                	test   %ebx,%ebx
  800334:	7f ed                	jg     800323 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800336:	83 ec 08             	sub    $0x8,%esp
  800339:	56                   	push   %esi
  80033a:	83 ec 04             	sub    $0x4,%esp
  80033d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800340:	ff 75 e0             	pushl  -0x20(%ebp)
  800343:	ff 75 dc             	pushl  -0x24(%ebp)
  800346:	ff 75 d8             	pushl  -0x28(%ebp)
  800349:	e8 92 11 00 00       	call   8014e0 <__umoddi3>
  80034e:	83 c4 14             	add    $0x14,%esp
  800351:	0f be 80 ec 16 80 00 	movsbl 0x8016ec(%eax),%eax
  800358:	50                   	push   %eax
  800359:	ff d7                	call   *%edi
}
  80035b:	83 c4 10             	add    $0x10,%esp
  80035e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800361:	5b                   	pop    %ebx
  800362:	5e                   	pop    %esi
  800363:	5f                   	pop    %edi
  800364:	5d                   	pop    %ebp
  800365:	c3                   	ret    

00800366 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800366:	f3 0f 1e fb          	endbr32 
  80036a:	55                   	push   %ebp
  80036b:	89 e5                	mov    %esp,%ebp
  80036d:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800370:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800374:	8b 10                	mov    (%eax),%edx
  800376:	3b 50 04             	cmp    0x4(%eax),%edx
  800379:	73 0a                	jae    800385 <sprintputch+0x1f>
		*b->buf++ = ch;
  80037b:	8d 4a 01             	lea    0x1(%edx),%ecx
  80037e:	89 08                	mov    %ecx,(%eax)
  800380:	8b 45 08             	mov    0x8(%ebp),%eax
  800383:	88 02                	mov    %al,(%edx)
}
  800385:	5d                   	pop    %ebp
  800386:	c3                   	ret    

00800387 <printfmt>:
{
  800387:	f3 0f 1e fb          	endbr32 
  80038b:	55                   	push   %ebp
  80038c:	89 e5                	mov    %esp,%ebp
  80038e:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800391:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800394:	50                   	push   %eax
  800395:	ff 75 10             	pushl  0x10(%ebp)
  800398:	ff 75 0c             	pushl  0xc(%ebp)
  80039b:	ff 75 08             	pushl  0x8(%ebp)
  80039e:	e8 05 00 00 00       	call   8003a8 <vprintfmt>
}
  8003a3:	83 c4 10             	add    $0x10,%esp
  8003a6:	c9                   	leave  
  8003a7:	c3                   	ret    

008003a8 <vprintfmt>:
{
  8003a8:	f3 0f 1e fb          	endbr32 
  8003ac:	55                   	push   %ebp
  8003ad:	89 e5                	mov    %esp,%ebp
  8003af:	57                   	push   %edi
  8003b0:	56                   	push   %esi
  8003b1:	53                   	push   %ebx
  8003b2:	83 ec 3c             	sub    $0x3c,%esp
  8003b5:	8b 75 08             	mov    0x8(%ebp),%esi
  8003b8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003bb:	8b 7d 10             	mov    0x10(%ebp),%edi
  8003be:	e9 cd 03 00 00       	jmp    800790 <vprintfmt+0x3e8>
		padc = ' ';
  8003c3:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  8003c7:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8003ce:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8003d5:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8003dc:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8003e1:	8d 47 01             	lea    0x1(%edi),%eax
  8003e4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003e7:	0f b6 17             	movzbl (%edi),%edx
  8003ea:	8d 42 dd             	lea    -0x23(%edx),%eax
  8003ed:	3c 55                	cmp    $0x55,%al
  8003ef:	0f 87 1e 04 00 00    	ja     800813 <vprintfmt+0x46b>
  8003f5:	0f b6 c0             	movzbl %al,%eax
  8003f8:	3e ff 24 85 c0 17 80 	notrack jmp *0x8017c0(,%eax,4)
  8003ff:	00 
  800400:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800403:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800407:	eb d8                	jmp    8003e1 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800409:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80040c:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  800410:	eb cf                	jmp    8003e1 <vprintfmt+0x39>
  800412:	0f b6 d2             	movzbl %dl,%edx
  800415:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800418:	b8 00 00 00 00       	mov    $0x0,%eax
  80041d:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800420:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800423:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800427:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80042a:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80042d:	83 f9 09             	cmp    $0x9,%ecx
  800430:	77 55                	ja     800487 <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  800432:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800435:	eb e9                	jmp    800420 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  800437:	8b 45 14             	mov    0x14(%ebp),%eax
  80043a:	8b 00                	mov    (%eax),%eax
  80043c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80043f:	8b 45 14             	mov    0x14(%ebp),%eax
  800442:	8d 40 04             	lea    0x4(%eax),%eax
  800445:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800448:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  80044b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80044f:	79 90                	jns    8003e1 <vprintfmt+0x39>
				width = precision, precision = -1;
  800451:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800454:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800457:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80045e:	eb 81                	jmp    8003e1 <vprintfmt+0x39>
  800460:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800463:	85 c0                	test   %eax,%eax
  800465:	ba 00 00 00 00       	mov    $0x0,%edx
  80046a:	0f 49 d0             	cmovns %eax,%edx
  80046d:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800470:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800473:	e9 69 ff ff ff       	jmp    8003e1 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800478:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  80047b:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  800482:	e9 5a ff ff ff       	jmp    8003e1 <vprintfmt+0x39>
  800487:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80048a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80048d:	eb bc                	jmp    80044b <vprintfmt+0xa3>
			lflag++;
  80048f:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800492:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800495:	e9 47 ff ff ff       	jmp    8003e1 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  80049a:	8b 45 14             	mov    0x14(%ebp),%eax
  80049d:	8d 78 04             	lea    0x4(%eax),%edi
  8004a0:	83 ec 08             	sub    $0x8,%esp
  8004a3:	53                   	push   %ebx
  8004a4:	ff 30                	pushl  (%eax)
  8004a6:	ff d6                	call   *%esi
			break;
  8004a8:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8004ab:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8004ae:	e9 da 02 00 00       	jmp    80078d <vprintfmt+0x3e5>
			err = va_arg(ap, int);
  8004b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b6:	8d 78 04             	lea    0x4(%eax),%edi
  8004b9:	8b 00                	mov    (%eax),%eax
  8004bb:	99                   	cltd   
  8004bc:	31 d0                	xor    %edx,%eax
  8004be:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004c0:	83 f8 08             	cmp    $0x8,%eax
  8004c3:	7f 23                	jg     8004e8 <vprintfmt+0x140>
  8004c5:	8b 14 85 20 19 80 00 	mov    0x801920(,%eax,4),%edx
  8004cc:	85 d2                	test   %edx,%edx
  8004ce:	74 18                	je     8004e8 <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  8004d0:	52                   	push   %edx
  8004d1:	68 0d 17 80 00       	push   $0x80170d
  8004d6:	53                   	push   %ebx
  8004d7:	56                   	push   %esi
  8004d8:	e8 aa fe ff ff       	call   800387 <printfmt>
  8004dd:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8004e0:	89 7d 14             	mov    %edi,0x14(%ebp)
  8004e3:	e9 a5 02 00 00       	jmp    80078d <vprintfmt+0x3e5>
				printfmt(putch, putdat, "error %d", err);
  8004e8:	50                   	push   %eax
  8004e9:	68 04 17 80 00       	push   $0x801704
  8004ee:	53                   	push   %ebx
  8004ef:	56                   	push   %esi
  8004f0:	e8 92 fe ff ff       	call   800387 <printfmt>
  8004f5:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8004f8:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8004fb:	e9 8d 02 00 00       	jmp    80078d <vprintfmt+0x3e5>
			if ((p = va_arg(ap, char *)) == NULL)
  800500:	8b 45 14             	mov    0x14(%ebp),%eax
  800503:	83 c0 04             	add    $0x4,%eax
  800506:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800509:	8b 45 14             	mov    0x14(%ebp),%eax
  80050c:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  80050e:	85 d2                	test   %edx,%edx
  800510:	b8 fd 16 80 00       	mov    $0x8016fd,%eax
  800515:	0f 45 c2             	cmovne %edx,%eax
  800518:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  80051b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80051f:	7e 06                	jle    800527 <vprintfmt+0x17f>
  800521:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  800525:	75 0d                	jne    800534 <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  800527:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80052a:	89 c7                	mov    %eax,%edi
  80052c:	03 45 e0             	add    -0x20(%ebp),%eax
  80052f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800532:	eb 55                	jmp    800589 <vprintfmt+0x1e1>
  800534:	83 ec 08             	sub    $0x8,%esp
  800537:	ff 75 d8             	pushl  -0x28(%ebp)
  80053a:	ff 75 cc             	pushl  -0x34(%ebp)
  80053d:	e8 85 03 00 00       	call   8008c7 <strnlen>
  800542:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800545:	29 c2                	sub    %eax,%edx
  800547:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  80054a:	83 c4 10             	add    $0x10,%esp
  80054d:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  80054f:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  800553:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800556:	85 ff                	test   %edi,%edi
  800558:	7e 11                	jle    80056b <vprintfmt+0x1c3>
					putch(padc, putdat);
  80055a:	83 ec 08             	sub    $0x8,%esp
  80055d:	53                   	push   %ebx
  80055e:	ff 75 e0             	pushl  -0x20(%ebp)
  800561:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800563:	83 ef 01             	sub    $0x1,%edi
  800566:	83 c4 10             	add    $0x10,%esp
  800569:	eb eb                	jmp    800556 <vprintfmt+0x1ae>
  80056b:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  80056e:	85 d2                	test   %edx,%edx
  800570:	b8 00 00 00 00       	mov    $0x0,%eax
  800575:	0f 49 c2             	cmovns %edx,%eax
  800578:	29 c2                	sub    %eax,%edx
  80057a:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80057d:	eb a8                	jmp    800527 <vprintfmt+0x17f>
					putch(ch, putdat);
  80057f:	83 ec 08             	sub    $0x8,%esp
  800582:	53                   	push   %ebx
  800583:	52                   	push   %edx
  800584:	ff d6                	call   *%esi
  800586:	83 c4 10             	add    $0x10,%esp
  800589:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80058c:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80058e:	83 c7 01             	add    $0x1,%edi
  800591:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800595:	0f be d0             	movsbl %al,%edx
  800598:	85 d2                	test   %edx,%edx
  80059a:	74 4b                	je     8005e7 <vprintfmt+0x23f>
  80059c:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005a0:	78 06                	js     8005a8 <vprintfmt+0x200>
  8005a2:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8005a6:	78 1e                	js     8005c6 <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
  8005a8:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8005ac:	74 d1                	je     80057f <vprintfmt+0x1d7>
  8005ae:	0f be c0             	movsbl %al,%eax
  8005b1:	83 e8 20             	sub    $0x20,%eax
  8005b4:	83 f8 5e             	cmp    $0x5e,%eax
  8005b7:	76 c6                	jbe    80057f <vprintfmt+0x1d7>
					putch('?', putdat);
  8005b9:	83 ec 08             	sub    $0x8,%esp
  8005bc:	53                   	push   %ebx
  8005bd:	6a 3f                	push   $0x3f
  8005bf:	ff d6                	call   *%esi
  8005c1:	83 c4 10             	add    $0x10,%esp
  8005c4:	eb c3                	jmp    800589 <vprintfmt+0x1e1>
  8005c6:	89 cf                	mov    %ecx,%edi
  8005c8:	eb 0e                	jmp    8005d8 <vprintfmt+0x230>
				putch(' ', putdat);
  8005ca:	83 ec 08             	sub    $0x8,%esp
  8005cd:	53                   	push   %ebx
  8005ce:	6a 20                	push   $0x20
  8005d0:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8005d2:	83 ef 01             	sub    $0x1,%edi
  8005d5:	83 c4 10             	add    $0x10,%esp
  8005d8:	85 ff                	test   %edi,%edi
  8005da:	7f ee                	jg     8005ca <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  8005dc:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8005df:	89 45 14             	mov    %eax,0x14(%ebp)
  8005e2:	e9 a6 01 00 00       	jmp    80078d <vprintfmt+0x3e5>
  8005e7:	89 cf                	mov    %ecx,%edi
  8005e9:	eb ed                	jmp    8005d8 <vprintfmt+0x230>
	if (lflag >= 2)
  8005eb:	83 f9 01             	cmp    $0x1,%ecx
  8005ee:	7f 1f                	jg     80060f <vprintfmt+0x267>
	else if (lflag)
  8005f0:	85 c9                	test   %ecx,%ecx
  8005f2:	74 67                	je     80065b <vprintfmt+0x2b3>
		return va_arg(*ap, long);
  8005f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f7:	8b 00                	mov    (%eax),%eax
  8005f9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005fc:	89 c1                	mov    %eax,%ecx
  8005fe:	c1 f9 1f             	sar    $0x1f,%ecx
  800601:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800604:	8b 45 14             	mov    0x14(%ebp),%eax
  800607:	8d 40 04             	lea    0x4(%eax),%eax
  80060a:	89 45 14             	mov    %eax,0x14(%ebp)
  80060d:	eb 17                	jmp    800626 <vprintfmt+0x27e>
		return va_arg(*ap, long long);
  80060f:	8b 45 14             	mov    0x14(%ebp),%eax
  800612:	8b 50 04             	mov    0x4(%eax),%edx
  800615:	8b 00                	mov    (%eax),%eax
  800617:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80061a:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80061d:	8b 45 14             	mov    0x14(%ebp),%eax
  800620:	8d 40 08             	lea    0x8(%eax),%eax
  800623:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800626:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800629:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  80062c:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  800631:	85 c9                	test   %ecx,%ecx
  800633:	0f 89 3a 01 00 00    	jns    800773 <vprintfmt+0x3cb>
				putch('-', putdat);
  800639:	83 ec 08             	sub    $0x8,%esp
  80063c:	53                   	push   %ebx
  80063d:	6a 2d                	push   $0x2d
  80063f:	ff d6                	call   *%esi
				num = -(long long) num;
  800641:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800644:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800647:	f7 da                	neg    %edx
  800649:	83 d1 00             	adc    $0x0,%ecx
  80064c:	f7 d9                	neg    %ecx
  80064e:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800651:	b8 0a 00 00 00       	mov    $0xa,%eax
  800656:	e9 18 01 00 00       	jmp    800773 <vprintfmt+0x3cb>
		return va_arg(*ap, int);
  80065b:	8b 45 14             	mov    0x14(%ebp),%eax
  80065e:	8b 00                	mov    (%eax),%eax
  800660:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800663:	89 c1                	mov    %eax,%ecx
  800665:	c1 f9 1f             	sar    $0x1f,%ecx
  800668:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80066b:	8b 45 14             	mov    0x14(%ebp),%eax
  80066e:	8d 40 04             	lea    0x4(%eax),%eax
  800671:	89 45 14             	mov    %eax,0x14(%ebp)
  800674:	eb b0                	jmp    800626 <vprintfmt+0x27e>
	if (lflag >= 2)
  800676:	83 f9 01             	cmp    $0x1,%ecx
  800679:	7f 1e                	jg     800699 <vprintfmt+0x2f1>
	else if (lflag)
  80067b:	85 c9                	test   %ecx,%ecx
  80067d:	74 32                	je     8006b1 <vprintfmt+0x309>
		return va_arg(*ap, unsigned long);
  80067f:	8b 45 14             	mov    0x14(%ebp),%eax
  800682:	8b 10                	mov    (%eax),%edx
  800684:	b9 00 00 00 00       	mov    $0x0,%ecx
  800689:	8d 40 04             	lea    0x4(%eax),%eax
  80068c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80068f:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  800694:	e9 da 00 00 00       	jmp    800773 <vprintfmt+0x3cb>
		return va_arg(*ap, unsigned long long);
  800699:	8b 45 14             	mov    0x14(%ebp),%eax
  80069c:	8b 10                	mov    (%eax),%edx
  80069e:	8b 48 04             	mov    0x4(%eax),%ecx
  8006a1:	8d 40 08             	lea    0x8(%eax),%eax
  8006a4:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006a7:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  8006ac:	e9 c2 00 00 00       	jmp    800773 <vprintfmt+0x3cb>
		return va_arg(*ap, unsigned int);
  8006b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b4:	8b 10                	mov    (%eax),%edx
  8006b6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006bb:	8d 40 04             	lea    0x4(%eax),%eax
  8006be:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006c1:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  8006c6:	e9 a8 00 00 00       	jmp    800773 <vprintfmt+0x3cb>
	if (lflag >= 2)
  8006cb:	83 f9 01             	cmp    $0x1,%ecx
  8006ce:	7f 1b                	jg     8006eb <vprintfmt+0x343>
	else if (lflag)
  8006d0:	85 c9                	test   %ecx,%ecx
  8006d2:	74 5c                	je     800730 <vprintfmt+0x388>
		return va_arg(*ap, long);
  8006d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d7:	8b 00                	mov    (%eax),%eax
  8006d9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006dc:	99                   	cltd   
  8006dd:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e3:	8d 40 04             	lea    0x4(%eax),%eax
  8006e6:	89 45 14             	mov    %eax,0x14(%ebp)
  8006e9:	eb 17                	jmp    800702 <vprintfmt+0x35a>
		return va_arg(*ap, long long);
  8006eb:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ee:	8b 50 04             	mov    0x4(%eax),%edx
  8006f1:	8b 00                	mov    (%eax),%eax
  8006f3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006f6:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8006fc:	8d 40 08             	lea    0x8(%eax),%eax
  8006ff:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800702:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800705:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 8;
  800708:	b8 08 00 00 00       	mov    $0x8,%eax
			if ((long long) num < 0) {
  80070d:	85 c9                	test   %ecx,%ecx
  80070f:	79 62                	jns    800773 <vprintfmt+0x3cb>
				putch('-', putdat);
  800711:	83 ec 08             	sub    $0x8,%esp
  800714:	53                   	push   %ebx
  800715:	6a 2d                	push   $0x2d
  800717:	ff d6                	call   *%esi
				num = -(long long) num;
  800719:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80071c:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80071f:	f7 da                	neg    %edx
  800721:	83 d1 00             	adc    $0x0,%ecx
  800724:	f7 d9                	neg    %ecx
  800726:	83 c4 10             	add    $0x10,%esp
			base = 8;
  800729:	b8 08 00 00 00       	mov    $0x8,%eax
  80072e:	eb 43                	jmp    800773 <vprintfmt+0x3cb>
		return va_arg(*ap, int);
  800730:	8b 45 14             	mov    0x14(%ebp),%eax
  800733:	8b 00                	mov    (%eax),%eax
  800735:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800738:	89 c1                	mov    %eax,%ecx
  80073a:	c1 f9 1f             	sar    $0x1f,%ecx
  80073d:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800740:	8b 45 14             	mov    0x14(%ebp),%eax
  800743:	8d 40 04             	lea    0x4(%eax),%eax
  800746:	89 45 14             	mov    %eax,0x14(%ebp)
  800749:	eb b7                	jmp    800702 <vprintfmt+0x35a>
			putch('0', putdat);
  80074b:	83 ec 08             	sub    $0x8,%esp
  80074e:	53                   	push   %ebx
  80074f:	6a 30                	push   $0x30
  800751:	ff d6                	call   *%esi
			putch('x', putdat);
  800753:	83 c4 08             	add    $0x8,%esp
  800756:	53                   	push   %ebx
  800757:	6a 78                	push   $0x78
  800759:	ff d6                	call   *%esi
			num = (unsigned long long)
  80075b:	8b 45 14             	mov    0x14(%ebp),%eax
  80075e:	8b 10                	mov    (%eax),%edx
  800760:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800765:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800768:	8d 40 04             	lea    0x4(%eax),%eax
  80076b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80076e:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  800773:	83 ec 0c             	sub    $0xc,%esp
  800776:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  80077a:	57                   	push   %edi
  80077b:	ff 75 e0             	pushl  -0x20(%ebp)
  80077e:	50                   	push   %eax
  80077f:	51                   	push   %ecx
  800780:	52                   	push   %edx
  800781:	89 da                	mov    %ebx,%edx
  800783:	89 f0                	mov    %esi,%eax
  800785:	e8 33 fb ff ff       	call   8002bd <printnum>
			break;
  80078a:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  80078d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800790:	83 c7 01             	add    $0x1,%edi
  800793:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800797:	83 f8 25             	cmp    $0x25,%eax
  80079a:	0f 84 23 fc ff ff    	je     8003c3 <vprintfmt+0x1b>
			if (ch == '\0')
  8007a0:	85 c0                	test   %eax,%eax
  8007a2:	0f 84 8b 00 00 00    	je     800833 <vprintfmt+0x48b>
			putch(ch, putdat);
  8007a8:	83 ec 08             	sub    $0x8,%esp
  8007ab:	53                   	push   %ebx
  8007ac:	50                   	push   %eax
  8007ad:	ff d6                	call   *%esi
  8007af:	83 c4 10             	add    $0x10,%esp
  8007b2:	eb dc                	jmp    800790 <vprintfmt+0x3e8>
	if (lflag >= 2)
  8007b4:	83 f9 01             	cmp    $0x1,%ecx
  8007b7:	7f 1b                	jg     8007d4 <vprintfmt+0x42c>
	else if (lflag)
  8007b9:	85 c9                	test   %ecx,%ecx
  8007bb:	74 2c                	je     8007e9 <vprintfmt+0x441>
		return va_arg(*ap, unsigned long);
  8007bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c0:	8b 10                	mov    (%eax),%edx
  8007c2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007c7:	8d 40 04             	lea    0x4(%eax),%eax
  8007ca:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007cd:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  8007d2:	eb 9f                	jmp    800773 <vprintfmt+0x3cb>
		return va_arg(*ap, unsigned long long);
  8007d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d7:	8b 10                	mov    (%eax),%edx
  8007d9:	8b 48 04             	mov    0x4(%eax),%ecx
  8007dc:	8d 40 08             	lea    0x8(%eax),%eax
  8007df:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007e2:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  8007e7:	eb 8a                	jmp    800773 <vprintfmt+0x3cb>
		return va_arg(*ap, unsigned int);
  8007e9:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ec:	8b 10                	mov    (%eax),%edx
  8007ee:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007f3:	8d 40 04             	lea    0x4(%eax),%eax
  8007f6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007f9:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  8007fe:	e9 70 ff ff ff       	jmp    800773 <vprintfmt+0x3cb>
			putch(ch, putdat);
  800803:	83 ec 08             	sub    $0x8,%esp
  800806:	53                   	push   %ebx
  800807:	6a 25                	push   $0x25
  800809:	ff d6                	call   *%esi
			break;
  80080b:	83 c4 10             	add    $0x10,%esp
  80080e:	e9 7a ff ff ff       	jmp    80078d <vprintfmt+0x3e5>
			putch('%', putdat);
  800813:	83 ec 08             	sub    $0x8,%esp
  800816:	53                   	push   %ebx
  800817:	6a 25                	push   $0x25
  800819:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80081b:	83 c4 10             	add    $0x10,%esp
  80081e:	89 f8                	mov    %edi,%eax
  800820:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800824:	74 05                	je     80082b <vprintfmt+0x483>
  800826:	83 e8 01             	sub    $0x1,%eax
  800829:	eb f5                	jmp    800820 <vprintfmt+0x478>
  80082b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80082e:	e9 5a ff ff ff       	jmp    80078d <vprintfmt+0x3e5>
}
  800833:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800836:	5b                   	pop    %ebx
  800837:	5e                   	pop    %esi
  800838:	5f                   	pop    %edi
  800839:	5d                   	pop    %ebp
  80083a:	c3                   	ret    

0080083b <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80083b:	f3 0f 1e fb          	endbr32 
  80083f:	55                   	push   %ebp
  800840:	89 e5                	mov    %esp,%ebp
  800842:	83 ec 18             	sub    $0x18,%esp
  800845:	8b 45 08             	mov    0x8(%ebp),%eax
  800848:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80084b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80084e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800852:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800855:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80085c:	85 c0                	test   %eax,%eax
  80085e:	74 26                	je     800886 <vsnprintf+0x4b>
  800860:	85 d2                	test   %edx,%edx
  800862:	7e 22                	jle    800886 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800864:	ff 75 14             	pushl  0x14(%ebp)
  800867:	ff 75 10             	pushl  0x10(%ebp)
  80086a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80086d:	50                   	push   %eax
  80086e:	68 66 03 80 00       	push   $0x800366
  800873:	e8 30 fb ff ff       	call   8003a8 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800878:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80087b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80087e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800881:	83 c4 10             	add    $0x10,%esp
}
  800884:	c9                   	leave  
  800885:	c3                   	ret    
		return -E_INVAL;
  800886:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80088b:	eb f7                	jmp    800884 <vsnprintf+0x49>

0080088d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80088d:	f3 0f 1e fb          	endbr32 
  800891:	55                   	push   %ebp
  800892:	89 e5                	mov    %esp,%ebp
  800894:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800897:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80089a:	50                   	push   %eax
  80089b:	ff 75 10             	pushl  0x10(%ebp)
  80089e:	ff 75 0c             	pushl  0xc(%ebp)
  8008a1:	ff 75 08             	pushl  0x8(%ebp)
  8008a4:	e8 92 ff ff ff       	call   80083b <vsnprintf>
	va_end(ap);

	return rc;
}
  8008a9:	c9                   	leave  
  8008aa:	c3                   	ret    

008008ab <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008ab:	f3 0f 1e fb          	endbr32 
  8008af:	55                   	push   %ebp
  8008b0:	89 e5                	mov    %esp,%ebp
  8008b2:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008b5:	b8 00 00 00 00       	mov    $0x0,%eax
  8008ba:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008be:	74 05                	je     8008c5 <strlen+0x1a>
		n++;
  8008c0:	83 c0 01             	add    $0x1,%eax
  8008c3:	eb f5                	jmp    8008ba <strlen+0xf>
	return n;
}
  8008c5:	5d                   	pop    %ebp
  8008c6:	c3                   	ret    

008008c7 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008c7:	f3 0f 1e fb          	endbr32 
  8008cb:	55                   	push   %ebp
  8008cc:	89 e5                	mov    %esp,%ebp
  8008ce:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008d1:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008d4:	b8 00 00 00 00       	mov    $0x0,%eax
  8008d9:	39 d0                	cmp    %edx,%eax
  8008db:	74 0d                	je     8008ea <strnlen+0x23>
  8008dd:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8008e1:	74 05                	je     8008e8 <strnlen+0x21>
		n++;
  8008e3:	83 c0 01             	add    $0x1,%eax
  8008e6:	eb f1                	jmp    8008d9 <strnlen+0x12>
  8008e8:	89 c2                	mov    %eax,%edx
	return n;
}
  8008ea:	89 d0                	mov    %edx,%eax
  8008ec:	5d                   	pop    %ebp
  8008ed:	c3                   	ret    

008008ee <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008ee:	f3 0f 1e fb          	endbr32 
  8008f2:	55                   	push   %ebp
  8008f3:	89 e5                	mov    %esp,%ebp
  8008f5:	53                   	push   %ebx
  8008f6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008f9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008fc:	b8 00 00 00 00       	mov    $0x0,%eax
  800901:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800905:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800908:	83 c0 01             	add    $0x1,%eax
  80090b:	84 d2                	test   %dl,%dl
  80090d:	75 f2                	jne    800901 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  80090f:	89 c8                	mov    %ecx,%eax
  800911:	5b                   	pop    %ebx
  800912:	5d                   	pop    %ebp
  800913:	c3                   	ret    

00800914 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800914:	f3 0f 1e fb          	endbr32 
  800918:	55                   	push   %ebp
  800919:	89 e5                	mov    %esp,%ebp
  80091b:	53                   	push   %ebx
  80091c:	83 ec 10             	sub    $0x10,%esp
  80091f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800922:	53                   	push   %ebx
  800923:	e8 83 ff ff ff       	call   8008ab <strlen>
  800928:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  80092b:	ff 75 0c             	pushl  0xc(%ebp)
  80092e:	01 d8                	add    %ebx,%eax
  800930:	50                   	push   %eax
  800931:	e8 b8 ff ff ff       	call   8008ee <strcpy>
	return dst;
}
  800936:	89 d8                	mov    %ebx,%eax
  800938:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80093b:	c9                   	leave  
  80093c:	c3                   	ret    

0080093d <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80093d:	f3 0f 1e fb          	endbr32 
  800941:	55                   	push   %ebp
  800942:	89 e5                	mov    %esp,%ebp
  800944:	56                   	push   %esi
  800945:	53                   	push   %ebx
  800946:	8b 75 08             	mov    0x8(%ebp),%esi
  800949:	8b 55 0c             	mov    0xc(%ebp),%edx
  80094c:	89 f3                	mov    %esi,%ebx
  80094e:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800951:	89 f0                	mov    %esi,%eax
  800953:	39 d8                	cmp    %ebx,%eax
  800955:	74 11                	je     800968 <strncpy+0x2b>
		*dst++ = *src;
  800957:	83 c0 01             	add    $0x1,%eax
  80095a:	0f b6 0a             	movzbl (%edx),%ecx
  80095d:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800960:	80 f9 01             	cmp    $0x1,%cl
  800963:	83 da ff             	sbb    $0xffffffff,%edx
  800966:	eb eb                	jmp    800953 <strncpy+0x16>
	}
	return ret;
}
  800968:	89 f0                	mov    %esi,%eax
  80096a:	5b                   	pop    %ebx
  80096b:	5e                   	pop    %esi
  80096c:	5d                   	pop    %ebp
  80096d:	c3                   	ret    

0080096e <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80096e:	f3 0f 1e fb          	endbr32 
  800972:	55                   	push   %ebp
  800973:	89 e5                	mov    %esp,%ebp
  800975:	56                   	push   %esi
  800976:	53                   	push   %ebx
  800977:	8b 75 08             	mov    0x8(%ebp),%esi
  80097a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80097d:	8b 55 10             	mov    0x10(%ebp),%edx
  800980:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800982:	85 d2                	test   %edx,%edx
  800984:	74 21                	je     8009a7 <strlcpy+0x39>
  800986:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80098a:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  80098c:	39 c2                	cmp    %eax,%edx
  80098e:	74 14                	je     8009a4 <strlcpy+0x36>
  800990:	0f b6 19             	movzbl (%ecx),%ebx
  800993:	84 db                	test   %bl,%bl
  800995:	74 0b                	je     8009a2 <strlcpy+0x34>
			*dst++ = *src++;
  800997:	83 c1 01             	add    $0x1,%ecx
  80099a:	83 c2 01             	add    $0x1,%edx
  80099d:	88 5a ff             	mov    %bl,-0x1(%edx)
  8009a0:	eb ea                	jmp    80098c <strlcpy+0x1e>
  8009a2:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  8009a4:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8009a7:	29 f0                	sub    %esi,%eax
}
  8009a9:	5b                   	pop    %ebx
  8009aa:	5e                   	pop    %esi
  8009ab:	5d                   	pop    %ebp
  8009ac:	c3                   	ret    

008009ad <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009ad:	f3 0f 1e fb          	endbr32 
  8009b1:	55                   	push   %ebp
  8009b2:	89 e5                	mov    %esp,%ebp
  8009b4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009b7:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009ba:	0f b6 01             	movzbl (%ecx),%eax
  8009bd:	84 c0                	test   %al,%al
  8009bf:	74 0c                	je     8009cd <strcmp+0x20>
  8009c1:	3a 02                	cmp    (%edx),%al
  8009c3:	75 08                	jne    8009cd <strcmp+0x20>
		p++, q++;
  8009c5:	83 c1 01             	add    $0x1,%ecx
  8009c8:	83 c2 01             	add    $0x1,%edx
  8009cb:	eb ed                	jmp    8009ba <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009cd:	0f b6 c0             	movzbl %al,%eax
  8009d0:	0f b6 12             	movzbl (%edx),%edx
  8009d3:	29 d0                	sub    %edx,%eax
}
  8009d5:	5d                   	pop    %ebp
  8009d6:	c3                   	ret    

008009d7 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009d7:	f3 0f 1e fb          	endbr32 
  8009db:	55                   	push   %ebp
  8009dc:	89 e5                	mov    %esp,%ebp
  8009de:	53                   	push   %ebx
  8009df:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009e5:	89 c3                	mov    %eax,%ebx
  8009e7:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8009ea:	eb 06                	jmp    8009f2 <strncmp+0x1b>
		n--, p++, q++;
  8009ec:	83 c0 01             	add    $0x1,%eax
  8009ef:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8009f2:	39 d8                	cmp    %ebx,%eax
  8009f4:	74 16                	je     800a0c <strncmp+0x35>
  8009f6:	0f b6 08             	movzbl (%eax),%ecx
  8009f9:	84 c9                	test   %cl,%cl
  8009fb:	74 04                	je     800a01 <strncmp+0x2a>
  8009fd:	3a 0a                	cmp    (%edx),%cl
  8009ff:	74 eb                	je     8009ec <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a01:	0f b6 00             	movzbl (%eax),%eax
  800a04:	0f b6 12             	movzbl (%edx),%edx
  800a07:	29 d0                	sub    %edx,%eax
}
  800a09:	5b                   	pop    %ebx
  800a0a:	5d                   	pop    %ebp
  800a0b:	c3                   	ret    
		return 0;
  800a0c:	b8 00 00 00 00       	mov    $0x0,%eax
  800a11:	eb f6                	jmp    800a09 <strncmp+0x32>

00800a13 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a13:	f3 0f 1e fb          	endbr32 
  800a17:	55                   	push   %ebp
  800a18:	89 e5                	mov    %esp,%ebp
  800a1a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a1d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a21:	0f b6 10             	movzbl (%eax),%edx
  800a24:	84 d2                	test   %dl,%dl
  800a26:	74 09                	je     800a31 <strchr+0x1e>
		if (*s == c)
  800a28:	38 ca                	cmp    %cl,%dl
  800a2a:	74 0a                	je     800a36 <strchr+0x23>
	for (; *s; s++)
  800a2c:	83 c0 01             	add    $0x1,%eax
  800a2f:	eb f0                	jmp    800a21 <strchr+0xe>
			return (char *) s;
	return 0;
  800a31:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a36:	5d                   	pop    %ebp
  800a37:	c3                   	ret    

00800a38 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a38:	f3 0f 1e fb          	endbr32 
  800a3c:	55                   	push   %ebp
  800a3d:	89 e5                	mov    %esp,%ebp
  800a3f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a42:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a46:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a49:	38 ca                	cmp    %cl,%dl
  800a4b:	74 09                	je     800a56 <strfind+0x1e>
  800a4d:	84 d2                	test   %dl,%dl
  800a4f:	74 05                	je     800a56 <strfind+0x1e>
	for (; *s; s++)
  800a51:	83 c0 01             	add    $0x1,%eax
  800a54:	eb f0                	jmp    800a46 <strfind+0xe>
			break;
	return (char *) s;
}
  800a56:	5d                   	pop    %ebp
  800a57:	c3                   	ret    

00800a58 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a58:	f3 0f 1e fb          	endbr32 
  800a5c:	55                   	push   %ebp
  800a5d:	89 e5                	mov    %esp,%ebp
  800a5f:	57                   	push   %edi
  800a60:	56                   	push   %esi
  800a61:	53                   	push   %ebx
  800a62:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a65:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a68:	85 c9                	test   %ecx,%ecx
  800a6a:	74 31                	je     800a9d <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a6c:	89 f8                	mov    %edi,%eax
  800a6e:	09 c8                	or     %ecx,%eax
  800a70:	a8 03                	test   $0x3,%al
  800a72:	75 23                	jne    800a97 <memset+0x3f>
		c &= 0xFF;
  800a74:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a78:	89 d3                	mov    %edx,%ebx
  800a7a:	c1 e3 08             	shl    $0x8,%ebx
  800a7d:	89 d0                	mov    %edx,%eax
  800a7f:	c1 e0 18             	shl    $0x18,%eax
  800a82:	89 d6                	mov    %edx,%esi
  800a84:	c1 e6 10             	shl    $0x10,%esi
  800a87:	09 f0                	or     %esi,%eax
  800a89:	09 c2                	or     %eax,%edx
  800a8b:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a8d:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800a90:	89 d0                	mov    %edx,%eax
  800a92:	fc                   	cld    
  800a93:	f3 ab                	rep stos %eax,%es:(%edi)
  800a95:	eb 06                	jmp    800a9d <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a97:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a9a:	fc                   	cld    
  800a9b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a9d:	89 f8                	mov    %edi,%eax
  800a9f:	5b                   	pop    %ebx
  800aa0:	5e                   	pop    %esi
  800aa1:	5f                   	pop    %edi
  800aa2:	5d                   	pop    %ebp
  800aa3:	c3                   	ret    

00800aa4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800aa4:	f3 0f 1e fb          	endbr32 
  800aa8:	55                   	push   %ebp
  800aa9:	89 e5                	mov    %esp,%ebp
  800aab:	57                   	push   %edi
  800aac:	56                   	push   %esi
  800aad:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab0:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ab3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ab6:	39 c6                	cmp    %eax,%esi
  800ab8:	73 32                	jae    800aec <memmove+0x48>
  800aba:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800abd:	39 c2                	cmp    %eax,%edx
  800abf:	76 2b                	jbe    800aec <memmove+0x48>
		s += n;
		d += n;
  800ac1:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ac4:	89 fe                	mov    %edi,%esi
  800ac6:	09 ce                	or     %ecx,%esi
  800ac8:	09 d6                	or     %edx,%esi
  800aca:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800ad0:	75 0e                	jne    800ae0 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800ad2:	83 ef 04             	sub    $0x4,%edi
  800ad5:	8d 72 fc             	lea    -0x4(%edx),%esi
  800ad8:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800adb:	fd                   	std    
  800adc:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ade:	eb 09                	jmp    800ae9 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800ae0:	83 ef 01             	sub    $0x1,%edi
  800ae3:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800ae6:	fd                   	std    
  800ae7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ae9:	fc                   	cld    
  800aea:	eb 1a                	jmp    800b06 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800aec:	89 c2                	mov    %eax,%edx
  800aee:	09 ca                	or     %ecx,%edx
  800af0:	09 f2                	or     %esi,%edx
  800af2:	f6 c2 03             	test   $0x3,%dl
  800af5:	75 0a                	jne    800b01 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800af7:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800afa:	89 c7                	mov    %eax,%edi
  800afc:	fc                   	cld    
  800afd:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800aff:	eb 05                	jmp    800b06 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800b01:	89 c7                	mov    %eax,%edi
  800b03:	fc                   	cld    
  800b04:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b06:	5e                   	pop    %esi
  800b07:	5f                   	pop    %edi
  800b08:	5d                   	pop    %ebp
  800b09:	c3                   	ret    

00800b0a <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b0a:	f3 0f 1e fb          	endbr32 
  800b0e:	55                   	push   %ebp
  800b0f:	89 e5                	mov    %esp,%ebp
  800b11:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800b14:	ff 75 10             	pushl  0x10(%ebp)
  800b17:	ff 75 0c             	pushl  0xc(%ebp)
  800b1a:	ff 75 08             	pushl  0x8(%ebp)
  800b1d:	e8 82 ff ff ff       	call   800aa4 <memmove>
}
  800b22:	c9                   	leave  
  800b23:	c3                   	ret    

00800b24 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b24:	f3 0f 1e fb          	endbr32 
  800b28:	55                   	push   %ebp
  800b29:	89 e5                	mov    %esp,%ebp
  800b2b:	56                   	push   %esi
  800b2c:	53                   	push   %ebx
  800b2d:	8b 45 08             	mov    0x8(%ebp),%eax
  800b30:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b33:	89 c6                	mov    %eax,%esi
  800b35:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b38:	39 f0                	cmp    %esi,%eax
  800b3a:	74 1c                	je     800b58 <memcmp+0x34>
		if (*s1 != *s2)
  800b3c:	0f b6 08             	movzbl (%eax),%ecx
  800b3f:	0f b6 1a             	movzbl (%edx),%ebx
  800b42:	38 d9                	cmp    %bl,%cl
  800b44:	75 08                	jne    800b4e <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800b46:	83 c0 01             	add    $0x1,%eax
  800b49:	83 c2 01             	add    $0x1,%edx
  800b4c:	eb ea                	jmp    800b38 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800b4e:	0f b6 c1             	movzbl %cl,%eax
  800b51:	0f b6 db             	movzbl %bl,%ebx
  800b54:	29 d8                	sub    %ebx,%eax
  800b56:	eb 05                	jmp    800b5d <memcmp+0x39>
	}

	return 0;
  800b58:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b5d:	5b                   	pop    %ebx
  800b5e:	5e                   	pop    %esi
  800b5f:	5d                   	pop    %ebp
  800b60:	c3                   	ret    

00800b61 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b61:	f3 0f 1e fb          	endbr32 
  800b65:	55                   	push   %ebp
  800b66:	89 e5                	mov    %esp,%ebp
  800b68:	8b 45 08             	mov    0x8(%ebp),%eax
  800b6b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b6e:	89 c2                	mov    %eax,%edx
  800b70:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b73:	39 d0                	cmp    %edx,%eax
  800b75:	73 09                	jae    800b80 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b77:	38 08                	cmp    %cl,(%eax)
  800b79:	74 05                	je     800b80 <memfind+0x1f>
	for (; s < ends; s++)
  800b7b:	83 c0 01             	add    $0x1,%eax
  800b7e:	eb f3                	jmp    800b73 <memfind+0x12>
			break;
	return (void *) s;
}
  800b80:	5d                   	pop    %ebp
  800b81:	c3                   	ret    

00800b82 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b82:	f3 0f 1e fb          	endbr32 
  800b86:	55                   	push   %ebp
  800b87:	89 e5                	mov    %esp,%ebp
  800b89:	57                   	push   %edi
  800b8a:	56                   	push   %esi
  800b8b:	53                   	push   %ebx
  800b8c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b8f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b92:	eb 03                	jmp    800b97 <strtol+0x15>
		s++;
  800b94:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800b97:	0f b6 01             	movzbl (%ecx),%eax
  800b9a:	3c 20                	cmp    $0x20,%al
  800b9c:	74 f6                	je     800b94 <strtol+0x12>
  800b9e:	3c 09                	cmp    $0x9,%al
  800ba0:	74 f2                	je     800b94 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800ba2:	3c 2b                	cmp    $0x2b,%al
  800ba4:	74 2a                	je     800bd0 <strtol+0x4e>
	int neg = 0;
  800ba6:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800bab:	3c 2d                	cmp    $0x2d,%al
  800bad:	74 2b                	je     800bda <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800baf:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800bb5:	75 0f                	jne    800bc6 <strtol+0x44>
  800bb7:	80 39 30             	cmpb   $0x30,(%ecx)
  800bba:	74 28                	je     800be4 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800bbc:	85 db                	test   %ebx,%ebx
  800bbe:	b8 0a 00 00 00       	mov    $0xa,%eax
  800bc3:	0f 44 d8             	cmove  %eax,%ebx
  800bc6:	b8 00 00 00 00       	mov    $0x0,%eax
  800bcb:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800bce:	eb 46                	jmp    800c16 <strtol+0x94>
		s++;
  800bd0:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800bd3:	bf 00 00 00 00       	mov    $0x0,%edi
  800bd8:	eb d5                	jmp    800baf <strtol+0x2d>
		s++, neg = 1;
  800bda:	83 c1 01             	add    $0x1,%ecx
  800bdd:	bf 01 00 00 00       	mov    $0x1,%edi
  800be2:	eb cb                	jmp    800baf <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800be4:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800be8:	74 0e                	je     800bf8 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800bea:	85 db                	test   %ebx,%ebx
  800bec:	75 d8                	jne    800bc6 <strtol+0x44>
		s++, base = 8;
  800bee:	83 c1 01             	add    $0x1,%ecx
  800bf1:	bb 08 00 00 00       	mov    $0x8,%ebx
  800bf6:	eb ce                	jmp    800bc6 <strtol+0x44>
		s += 2, base = 16;
  800bf8:	83 c1 02             	add    $0x2,%ecx
  800bfb:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c00:	eb c4                	jmp    800bc6 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800c02:	0f be d2             	movsbl %dl,%edx
  800c05:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800c08:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c0b:	7d 3a                	jge    800c47 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800c0d:	83 c1 01             	add    $0x1,%ecx
  800c10:	0f af 45 10          	imul   0x10(%ebp),%eax
  800c14:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800c16:	0f b6 11             	movzbl (%ecx),%edx
  800c19:	8d 72 d0             	lea    -0x30(%edx),%esi
  800c1c:	89 f3                	mov    %esi,%ebx
  800c1e:	80 fb 09             	cmp    $0x9,%bl
  800c21:	76 df                	jbe    800c02 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800c23:	8d 72 9f             	lea    -0x61(%edx),%esi
  800c26:	89 f3                	mov    %esi,%ebx
  800c28:	80 fb 19             	cmp    $0x19,%bl
  800c2b:	77 08                	ja     800c35 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800c2d:	0f be d2             	movsbl %dl,%edx
  800c30:	83 ea 57             	sub    $0x57,%edx
  800c33:	eb d3                	jmp    800c08 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800c35:	8d 72 bf             	lea    -0x41(%edx),%esi
  800c38:	89 f3                	mov    %esi,%ebx
  800c3a:	80 fb 19             	cmp    $0x19,%bl
  800c3d:	77 08                	ja     800c47 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800c3f:	0f be d2             	movsbl %dl,%edx
  800c42:	83 ea 37             	sub    $0x37,%edx
  800c45:	eb c1                	jmp    800c08 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800c47:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c4b:	74 05                	je     800c52 <strtol+0xd0>
		*endptr = (char *) s;
  800c4d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c50:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800c52:	89 c2                	mov    %eax,%edx
  800c54:	f7 da                	neg    %edx
  800c56:	85 ff                	test   %edi,%edi
  800c58:	0f 45 c2             	cmovne %edx,%eax
}
  800c5b:	5b                   	pop    %ebx
  800c5c:	5e                   	pop    %esi
  800c5d:	5f                   	pop    %edi
  800c5e:	5d                   	pop    %ebp
  800c5f:	c3                   	ret    

00800c60 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c60:	f3 0f 1e fb          	endbr32 
  800c64:	55                   	push   %ebp
  800c65:	89 e5                	mov    %esp,%ebp
  800c67:	57                   	push   %edi
  800c68:	56                   	push   %esi
  800c69:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c6a:	b8 00 00 00 00       	mov    $0x0,%eax
  800c6f:	8b 55 08             	mov    0x8(%ebp),%edx
  800c72:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c75:	89 c3                	mov    %eax,%ebx
  800c77:	89 c7                	mov    %eax,%edi
  800c79:	89 c6                	mov    %eax,%esi
  800c7b:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c7d:	5b                   	pop    %ebx
  800c7e:	5e                   	pop    %esi
  800c7f:	5f                   	pop    %edi
  800c80:	5d                   	pop    %ebp
  800c81:	c3                   	ret    

00800c82 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c82:	f3 0f 1e fb          	endbr32 
  800c86:	55                   	push   %ebp
  800c87:	89 e5                	mov    %esp,%ebp
  800c89:	57                   	push   %edi
  800c8a:	56                   	push   %esi
  800c8b:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c8c:	ba 00 00 00 00       	mov    $0x0,%edx
  800c91:	b8 01 00 00 00       	mov    $0x1,%eax
  800c96:	89 d1                	mov    %edx,%ecx
  800c98:	89 d3                	mov    %edx,%ebx
  800c9a:	89 d7                	mov    %edx,%edi
  800c9c:	89 d6                	mov    %edx,%esi
  800c9e:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ca0:	5b                   	pop    %ebx
  800ca1:	5e                   	pop    %esi
  800ca2:	5f                   	pop    %edi
  800ca3:	5d                   	pop    %ebp
  800ca4:	c3                   	ret    

00800ca5 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ca5:	f3 0f 1e fb          	endbr32 
  800ca9:	55                   	push   %ebp
  800caa:	89 e5                	mov    %esp,%ebp
  800cac:	57                   	push   %edi
  800cad:	56                   	push   %esi
  800cae:	53                   	push   %ebx
  800caf:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cb2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cb7:	8b 55 08             	mov    0x8(%ebp),%edx
  800cba:	b8 03 00 00 00       	mov    $0x3,%eax
  800cbf:	89 cb                	mov    %ecx,%ebx
  800cc1:	89 cf                	mov    %ecx,%edi
  800cc3:	89 ce                	mov    %ecx,%esi
  800cc5:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cc7:	85 c0                	test   %eax,%eax
  800cc9:	7f 08                	jg     800cd3 <sys_env_destroy+0x2e>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ccb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cce:	5b                   	pop    %ebx
  800ccf:	5e                   	pop    %esi
  800cd0:	5f                   	pop    %edi
  800cd1:	5d                   	pop    %ebp
  800cd2:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cd3:	83 ec 0c             	sub    $0xc,%esp
  800cd6:	50                   	push   %eax
  800cd7:	6a 03                	push   $0x3
  800cd9:	68 44 19 80 00       	push   $0x801944
  800cde:	6a 23                	push   $0x23
  800ce0:	68 61 19 80 00       	push   $0x801961
  800ce5:	e8 0f 06 00 00       	call   8012f9 <_panic>

00800cea <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800cea:	f3 0f 1e fb          	endbr32 
  800cee:	55                   	push   %ebp
  800cef:	89 e5                	mov    %esp,%ebp
  800cf1:	57                   	push   %edi
  800cf2:	56                   	push   %esi
  800cf3:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cf4:	ba 00 00 00 00       	mov    $0x0,%edx
  800cf9:	b8 02 00 00 00       	mov    $0x2,%eax
  800cfe:	89 d1                	mov    %edx,%ecx
  800d00:	89 d3                	mov    %edx,%ebx
  800d02:	89 d7                	mov    %edx,%edi
  800d04:	89 d6                	mov    %edx,%esi
  800d06:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d08:	5b                   	pop    %ebx
  800d09:	5e                   	pop    %esi
  800d0a:	5f                   	pop    %edi
  800d0b:	5d                   	pop    %ebp
  800d0c:	c3                   	ret    

00800d0d <sys_yield>:

void
sys_yield(void)
{
  800d0d:	f3 0f 1e fb          	endbr32 
  800d11:	55                   	push   %ebp
  800d12:	89 e5                	mov    %esp,%ebp
  800d14:	57                   	push   %edi
  800d15:	56                   	push   %esi
  800d16:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d17:	ba 00 00 00 00       	mov    $0x0,%edx
  800d1c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d21:	89 d1                	mov    %edx,%ecx
  800d23:	89 d3                	mov    %edx,%ebx
  800d25:	89 d7                	mov    %edx,%edi
  800d27:	89 d6                	mov    %edx,%esi
  800d29:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d2b:	5b                   	pop    %ebx
  800d2c:	5e                   	pop    %esi
  800d2d:	5f                   	pop    %edi
  800d2e:	5d                   	pop    %ebp
  800d2f:	c3                   	ret    

00800d30 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d30:	f3 0f 1e fb          	endbr32 
  800d34:	55                   	push   %ebp
  800d35:	89 e5                	mov    %esp,%ebp
  800d37:	57                   	push   %edi
  800d38:	56                   	push   %esi
  800d39:	53                   	push   %ebx
  800d3a:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d3d:	be 00 00 00 00       	mov    $0x0,%esi
  800d42:	8b 55 08             	mov    0x8(%ebp),%edx
  800d45:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d48:	b8 04 00 00 00       	mov    $0x4,%eax
  800d4d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d50:	89 f7                	mov    %esi,%edi
  800d52:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d54:	85 c0                	test   %eax,%eax
  800d56:	7f 08                	jg     800d60 <sys_page_alloc+0x30>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d58:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d5b:	5b                   	pop    %ebx
  800d5c:	5e                   	pop    %esi
  800d5d:	5f                   	pop    %edi
  800d5e:	5d                   	pop    %ebp
  800d5f:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d60:	83 ec 0c             	sub    $0xc,%esp
  800d63:	50                   	push   %eax
  800d64:	6a 04                	push   $0x4
  800d66:	68 44 19 80 00       	push   $0x801944
  800d6b:	6a 23                	push   $0x23
  800d6d:	68 61 19 80 00       	push   $0x801961
  800d72:	e8 82 05 00 00       	call   8012f9 <_panic>

00800d77 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d77:	f3 0f 1e fb          	endbr32 
  800d7b:	55                   	push   %ebp
  800d7c:	89 e5                	mov    %esp,%ebp
  800d7e:	57                   	push   %edi
  800d7f:	56                   	push   %esi
  800d80:	53                   	push   %ebx
  800d81:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d84:	8b 55 08             	mov    0x8(%ebp),%edx
  800d87:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d8a:	b8 05 00 00 00       	mov    $0x5,%eax
  800d8f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d92:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d95:	8b 75 18             	mov    0x18(%ebp),%esi
  800d98:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d9a:	85 c0                	test   %eax,%eax
  800d9c:	7f 08                	jg     800da6 <sys_page_map+0x2f>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d9e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800da1:	5b                   	pop    %ebx
  800da2:	5e                   	pop    %esi
  800da3:	5f                   	pop    %edi
  800da4:	5d                   	pop    %ebp
  800da5:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800da6:	83 ec 0c             	sub    $0xc,%esp
  800da9:	50                   	push   %eax
  800daa:	6a 05                	push   $0x5
  800dac:	68 44 19 80 00       	push   $0x801944
  800db1:	6a 23                	push   $0x23
  800db3:	68 61 19 80 00       	push   $0x801961
  800db8:	e8 3c 05 00 00       	call   8012f9 <_panic>

00800dbd <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800dbd:	f3 0f 1e fb          	endbr32 
  800dc1:	55                   	push   %ebp
  800dc2:	89 e5                	mov    %esp,%ebp
  800dc4:	57                   	push   %edi
  800dc5:	56                   	push   %esi
  800dc6:	53                   	push   %ebx
  800dc7:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800dca:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dcf:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dd5:	b8 06 00 00 00       	mov    $0x6,%eax
  800dda:	89 df                	mov    %ebx,%edi
  800ddc:	89 de                	mov    %ebx,%esi
  800dde:	cd 30                	int    $0x30
	if(check && ret > 0)
  800de0:	85 c0                	test   %eax,%eax
  800de2:	7f 08                	jg     800dec <sys_page_unmap+0x2f>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800de4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800de7:	5b                   	pop    %ebx
  800de8:	5e                   	pop    %esi
  800de9:	5f                   	pop    %edi
  800dea:	5d                   	pop    %ebp
  800deb:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800dec:	83 ec 0c             	sub    $0xc,%esp
  800def:	50                   	push   %eax
  800df0:	6a 06                	push   $0x6
  800df2:	68 44 19 80 00       	push   $0x801944
  800df7:	6a 23                	push   $0x23
  800df9:	68 61 19 80 00       	push   $0x801961
  800dfe:	e8 f6 04 00 00       	call   8012f9 <_panic>

00800e03 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e03:	f3 0f 1e fb          	endbr32 
  800e07:	55                   	push   %ebp
  800e08:	89 e5                	mov    %esp,%ebp
  800e0a:	57                   	push   %edi
  800e0b:	56                   	push   %esi
  800e0c:	53                   	push   %ebx
  800e0d:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e10:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e15:	8b 55 08             	mov    0x8(%ebp),%edx
  800e18:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e1b:	b8 08 00 00 00       	mov    $0x8,%eax
  800e20:	89 df                	mov    %ebx,%edi
  800e22:	89 de                	mov    %ebx,%esi
  800e24:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e26:	85 c0                	test   %eax,%eax
  800e28:	7f 08                	jg     800e32 <sys_env_set_status+0x2f>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e2a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e2d:	5b                   	pop    %ebx
  800e2e:	5e                   	pop    %esi
  800e2f:	5f                   	pop    %edi
  800e30:	5d                   	pop    %ebp
  800e31:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e32:	83 ec 0c             	sub    $0xc,%esp
  800e35:	50                   	push   %eax
  800e36:	6a 08                	push   $0x8
  800e38:	68 44 19 80 00       	push   $0x801944
  800e3d:	6a 23                	push   $0x23
  800e3f:	68 61 19 80 00       	push   $0x801961
  800e44:	e8 b0 04 00 00       	call   8012f9 <_panic>

00800e49 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e49:	f3 0f 1e fb          	endbr32 
  800e4d:	55                   	push   %ebp
  800e4e:	89 e5                	mov    %esp,%ebp
  800e50:	57                   	push   %edi
  800e51:	56                   	push   %esi
  800e52:	53                   	push   %ebx
  800e53:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e56:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e5b:	8b 55 08             	mov    0x8(%ebp),%edx
  800e5e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e61:	b8 09 00 00 00       	mov    $0x9,%eax
  800e66:	89 df                	mov    %ebx,%edi
  800e68:	89 de                	mov    %ebx,%esi
  800e6a:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e6c:	85 c0                	test   %eax,%eax
  800e6e:	7f 08                	jg     800e78 <sys_env_set_pgfault_upcall+0x2f>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e70:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e73:	5b                   	pop    %ebx
  800e74:	5e                   	pop    %esi
  800e75:	5f                   	pop    %edi
  800e76:	5d                   	pop    %ebp
  800e77:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e78:	83 ec 0c             	sub    $0xc,%esp
  800e7b:	50                   	push   %eax
  800e7c:	6a 09                	push   $0x9
  800e7e:	68 44 19 80 00       	push   $0x801944
  800e83:	6a 23                	push   $0x23
  800e85:	68 61 19 80 00       	push   $0x801961
  800e8a:	e8 6a 04 00 00       	call   8012f9 <_panic>

00800e8f <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e8f:	f3 0f 1e fb          	endbr32 
  800e93:	55                   	push   %ebp
  800e94:	89 e5                	mov    %esp,%ebp
  800e96:	57                   	push   %edi
  800e97:	56                   	push   %esi
  800e98:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e99:	8b 55 08             	mov    0x8(%ebp),%edx
  800e9c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e9f:	b8 0b 00 00 00       	mov    $0xb,%eax
  800ea4:	be 00 00 00 00       	mov    $0x0,%esi
  800ea9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800eac:	8b 7d 14             	mov    0x14(%ebp),%edi
  800eaf:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800eb1:	5b                   	pop    %ebx
  800eb2:	5e                   	pop    %esi
  800eb3:	5f                   	pop    %edi
  800eb4:	5d                   	pop    %ebp
  800eb5:	c3                   	ret    

00800eb6 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800eb6:	f3 0f 1e fb          	endbr32 
  800eba:	55                   	push   %ebp
  800ebb:	89 e5                	mov    %esp,%ebp
  800ebd:	57                   	push   %edi
  800ebe:	56                   	push   %esi
  800ebf:	53                   	push   %ebx
  800ec0:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800ec3:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ec8:	8b 55 08             	mov    0x8(%ebp),%edx
  800ecb:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ed0:	89 cb                	mov    %ecx,%ebx
  800ed2:	89 cf                	mov    %ecx,%edi
  800ed4:	89 ce                	mov    %ecx,%esi
  800ed6:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ed8:	85 c0                	test   %eax,%eax
  800eda:	7f 08                	jg     800ee4 <sys_ipc_recv+0x2e>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800edc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800edf:	5b                   	pop    %ebx
  800ee0:	5e                   	pop    %esi
  800ee1:	5f                   	pop    %edi
  800ee2:	5d                   	pop    %ebp
  800ee3:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ee4:	83 ec 0c             	sub    $0xc,%esp
  800ee7:	50                   	push   %eax
  800ee8:	6a 0c                	push   $0xc
  800eea:	68 44 19 80 00       	push   $0x801944
  800eef:	6a 23                	push   $0x23
  800ef1:	68 61 19 80 00       	push   $0x801961
  800ef6:	e8 fe 03 00 00       	call   8012f9 <_panic>

00800efb <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800efb:	f3 0f 1e fb          	endbr32 
  800eff:	55                   	push   %ebp
  800f00:	89 e5                	mov    %esp,%ebp
  800f02:	53                   	push   %ebx
  800f03:	83 ec 04             	sub    $0x4,%esp
  800f06:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800f09:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if(!(err & FEC_WR)){
  800f0b:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800f0f:	74 74                	je     800f85 <pgfault+0x8a>
        panic("trapno is not FEC_WR");
    }
    if(!(uvpt[PGNUM(addr)] & PTE_COW)){
  800f11:	89 d8                	mov    %ebx,%eax
  800f13:	c1 e8 0c             	shr    $0xc,%eax
  800f16:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f1d:	f6 c4 08             	test   $0x8,%ah
  800f20:	74 77                	je     800f99 <pgfault+0x9e>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	addr = ROUNDDOWN(addr, PGSIZE);
  800f22:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
    if ((r = sys_page_map(0, addr, 0, PFTEMP, PTE_U | PTE_P)) < 0)
  800f28:	83 ec 0c             	sub    $0xc,%esp
  800f2b:	6a 05                	push   $0x5
  800f2d:	68 00 f0 7f 00       	push   $0x7ff000
  800f32:	6a 00                	push   $0x0
  800f34:	53                   	push   %ebx
  800f35:	6a 00                	push   $0x0
  800f37:	e8 3b fe ff ff       	call   800d77 <sys_page_map>
  800f3c:	83 c4 20             	add    $0x20,%esp
  800f3f:	85 c0                	test   %eax,%eax
  800f41:	78 6a                	js     800fad <pgfault+0xb2>
        panic("sys_page_map: %e", r);
    if ((r = sys_page_alloc(0, addr, PTE_W | PTE_U | PTE_P)) < 0)
  800f43:	83 ec 04             	sub    $0x4,%esp
  800f46:	6a 07                	push   $0x7
  800f48:	53                   	push   %ebx
  800f49:	6a 00                	push   $0x0
  800f4b:	e8 e0 fd ff ff       	call   800d30 <sys_page_alloc>
  800f50:	83 c4 10             	add    $0x10,%esp
  800f53:	85 c0                	test   %eax,%eax
  800f55:	78 68                	js     800fbf <pgfault+0xc4>
        panic("sys_page_alloc: %e", r);
    memmove(addr, PFTEMP, PGSIZE);
  800f57:	83 ec 04             	sub    $0x4,%esp
  800f5a:	68 00 10 00 00       	push   $0x1000
  800f5f:	68 00 f0 7f 00       	push   $0x7ff000
  800f64:	53                   	push   %ebx
  800f65:	e8 3a fb ff ff       	call   800aa4 <memmove>
    if ((r = sys_page_unmap(0, PFTEMP)) < 0)
  800f6a:	83 c4 08             	add    $0x8,%esp
  800f6d:	68 00 f0 7f 00       	push   $0x7ff000
  800f72:	6a 00                	push   $0x0
  800f74:	e8 44 fe ff ff       	call   800dbd <sys_page_unmap>
  800f79:	83 c4 10             	add    $0x10,%esp
  800f7c:	85 c0                	test   %eax,%eax
  800f7e:	78 51                	js     800fd1 <pgfault+0xd6>
        panic("sys_page_unmap: %e", r);

	//panic("pgfault not implemented");
}
  800f80:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f83:	c9                   	leave  
  800f84:	c3                   	ret    
        panic("trapno is not FEC_WR");
  800f85:	83 ec 04             	sub    $0x4,%esp
  800f88:	68 6f 19 80 00       	push   $0x80196f
  800f8d:	6a 1d                	push   $0x1d
  800f8f:	68 84 19 80 00       	push   $0x801984
  800f94:	e8 60 03 00 00       	call   8012f9 <_panic>
        panic("fault addr is not COW");
  800f99:	83 ec 04             	sub    $0x4,%esp
  800f9c:	68 8f 19 80 00       	push   $0x80198f
  800fa1:	6a 20                	push   $0x20
  800fa3:	68 84 19 80 00       	push   $0x801984
  800fa8:	e8 4c 03 00 00       	call   8012f9 <_panic>
        panic("sys_page_map: %e", r);
  800fad:	50                   	push   %eax
  800fae:	68 a5 19 80 00       	push   $0x8019a5
  800fb3:	6a 2c                	push   $0x2c
  800fb5:	68 84 19 80 00       	push   $0x801984
  800fba:	e8 3a 03 00 00       	call   8012f9 <_panic>
        panic("sys_page_alloc: %e", r);
  800fbf:	50                   	push   %eax
  800fc0:	68 b6 19 80 00       	push   $0x8019b6
  800fc5:	6a 2e                	push   $0x2e
  800fc7:	68 84 19 80 00       	push   $0x801984
  800fcc:	e8 28 03 00 00       	call   8012f9 <_panic>
        panic("sys_page_unmap: %e", r);
  800fd1:	50                   	push   %eax
  800fd2:	68 c9 19 80 00       	push   $0x8019c9
  800fd7:	6a 31                	push   $0x31
  800fd9:	68 84 19 80 00       	push   $0x801984
  800fde:	e8 16 03 00 00       	call   8012f9 <_panic>

00800fe3 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800fe3:	f3 0f 1e fb          	endbr32 
  800fe7:	55                   	push   %ebp
  800fe8:	89 e5                	mov    %esp,%ebp
  800fea:	57                   	push   %edi
  800feb:	56                   	push   %esi
  800fec:	53                   	push   %ebx
  800fed:	83 ec 28             	sub    $0x28,%esp
    extern void _pgfault_upcall(void);

	set_pgfault_handler(pgfault);
  800ff0:	68 fb 0e 80 00       	push   $0x800efb
  800ff5:	e8 49 03 00 00       	call   801343 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800ffa:	b8 07 00 00 00       	mov    $0x7,%eax
  800fff:	cd 30                	int    $0x30
  801001:	89 45 e4             	mov    %eax,-0x1c(%ebp)

    envid_t envid = sys_exofork();
    if (envid < 0)
  801004:	83 c4 10             	add    $0x10,%esp
  801007:	85 c0                	test   %eax,%eax
  801009:	78 2d                	js     801038 <fork+0x55>
  80100b:	89 c7                	mov    %eax,%edi
        thisenv = &envs[ENVX(sys_getenvid())];
        return 0;
    }

    // Parent
    for(uint32_t addr = 0; addr < USTACKTOP; addr += PGSIZE){
  80100d:	bb 00 00 00 00       	mov    $0x0,%ebx
    if (envid == 0) {
  801012:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801016:	0f 85 92 00 00 00    	jne    8010ae <fork+0xcb>
        thisenv = &envs[ENVX(sys_getenvid())];
  80101c:	e8 c9 fc ff ff       	call   800cea <sys_getenvid>
  801021:	25 ff 03 00 00       	and    $0x3ff,%eax
  801026:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801029:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80102e:	a3 0c 20 80 00       	mov    %eax,0x80200c
        return 0;
  801033:	e9 57 01 00 00       	jmp    80118f <fork+0x1ac>
        panic("sys_exofork Failed, envid: %e", envid);
  801038:	50                   	push   %eax
  801039:	68 dc 19 80 00       	push   $0x8019dc
  80103e:	6a 71                	push   $0x71
  801040:	68 84 19 80 00       	push   $0x801984
  801045:	e8 af 02 00 00       	call   8012f9 <_panic>
        sys_page_map(0, addr, envid, addr, PTE_SYSCALL);
  80104a:	83 ec 0c             	sub    $0xc,%esp
  80104d:	68 07 0e 00 00       	push   $0xe07
  801052:	56                   	push   %esi
  801053:	57                   	push   %edi
  801054:	56                   	push   %esi
  801055:	6a 00                	push   $0x0
  801057:	e8 1b fd ff ff       	call   800d77 <sys_page_map>
  80105c:	83 c4 20             	add    $0x20,%esp
  80105f:	eb 3b                	jmp    80109c <fork+0xb9>
        if ((r = sys_page_map(0, addr, envid, addr, PTE_COW|PTE_U|PTE_P)) < 0)
  801061:	83 ec 0c             	sub    $0xc,%esp
  801064:	68 05 08 00 00       	push   $0x805
  801069:	56                   	push   %esi
  80106a:	57                   	push   %edi
  80106b:	56                   	push   %esi
  80106c:	6a 00                	push   $0x0
  80106e:	e8 04 fd ff ff       	call   800d77 <sys_page_map>
  801073:	83 c4 20             	add    $0x20,%esp
  801076:	85 c0                	test   %eax,%eax
  801078:	0f 88 a9 00 00 00    	js     801127 <fork+0x144>
		if ((r = sys_page_map(0, addr, 0, addr, PTE_COW|PTE_U|PTE_P)) < 0)
  80107e:	83 ec 0c             	sub    $0xc,%esp
  801081:	68 05 08 00 00       	push   $0x805
  801086:	56                   	push   %esi
  801087:	6a 00                	push   $0x0
  801089:	56                   	push   %esi
  80108a:	6a 00                	push   $0x0
  80108c:	e8 e6 fc ff ff       	call   800d77 <sys_page_map>
  801091:	83 c4 20             	add    $0x20,%esp
  801094:	85 c0                	test   %eax,%eax
  801096:	0f 88 9d 00 00 00    	js     801139 <fork+0x156>
    for(uint32_t addr = 0; addr < USTACKTOP; addr += PGSIZE){
  80109c:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8010a2:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  8010a8:	0f 84 9d 00 00 00    	je     80114b <fork+0x168>
		if((uvpd[PDX(addr)] & PTE_P) && 
  8010ae:	89 d8                	mov    %ebx,%eax
  8010b0:	c1 e8 16             	shr    $0x16,%eax
  8010b3:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010ba:	a8 01                	test   $0x1,%al
  8010bc:	74 de                	je     80109c <fork+0xb9>
		(uvpt[PGNUM(addr)]&PTE_P) && 
  8010be:	89 d8                	mov    %ebx,%eax
  8010c0:	c1 e8 0c             	shr    $0xc,%eax
  8010c3:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
		if((uvpd[PDX(addr)] & PTE_P) && 
  8010ca:	f6 c2 01             	test   $0x1,%dl
  8010cd:	74 cd                	je     80109c <fork+0xb9>
		(uvpt[PGNUM(addr)] &PTE_U)){
  8010cf:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
		(uvpt[PGNUM(addr)]&PTE_P) && 
  8010d6:	f6 c2 04             	test   $0x4,%dl
  8010d9:	74 c1                	je     80109c <fork+0xb9>
    void *addr=(void *)(pn*PGSIZE);
  8010db:	89 c6                	mov    %eax,%esi
  8010dd:	c1 e6 0c             	shl    $0xc,%esi
    if(uvpt[pn] & PTE_SHARE){
  8010e0:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010e7:	f6 c6 04             	test   $0x4,%dh
  8010ea:	0f 85 5a ff ff ff    	jne    80104a <fork+0x67>
    else if((uvpt[pn]&PTE_W)|| (uvpt[pn] & PTE_COW)){
  8010f0:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010f7:	f6 c2 02             	test   $0x2,%dl
  8010fa:	0f 85 61 ff ff ff    	jne    801061 <fork+0x7e>
  801100:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801107:	f6 c4 08             	test   $0x8,%ah
  80110a:	0f 85 51 ff ff ff    	jne    801061 <fork+0x7e>
        sys_page_map(0, addr, envid, addr, PTE_U|PTE_P);
  801110:	83 ec 0c             	sub    $0xc,%esp
  801113:	6a 05                	push   $0x5
  801115:	56                   	push   %esi
  801116:	57                   	push   %edi
  801117:	56                   	push   %esi
  801118:	6a 00                	push   $0x0
  80111a:	e8 58 fc ff ff       	call   800d77 <sys_page_map>
  80111f:	83 c4 20             	add    $0x20,%esp
  801122:	e9 75 ff ff ff       	jmp    80109c <fork+0xb9>
			panic("sys_page_map：%e", r);
  801127:	50                   	push   %eax
  801128:	68 fa 19 80 00       	push   $0x8019fa
  80112d:	6a 4d                	push   $0x4d
  80112f:	68 84 19 80 00       	push   $0x801984
  801134:	e8 c0 01 00 00       	call   8012f9 <_panic>
			panic("sys_page_map：%e", r);
  801139:	50                   	push   %eax
  80113a:	68 fa 19 80 00       	push   $0x8019fa
  80113f:	6a 4f                	push   $0x4f
  801141:	68 84 19 80 00       	push   $0x801984
  801146:	e8 ae 01 00 00       	call   8012f9 <_panic>
			duppage(envid, PGNUM(addr));
		}
	}

    // Allocate a new page for the child's user exception stack
    int r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_P|PTE_W|PTE_U);
  80114b:	83 ec 04             	sub    $0x4,%esp
  80114e:	6a 07                	push   $0x7
  801150:	68 00 f0 bf ee       	push   $0xeebff000
  801155:	ff 75 e4             	pushl  -0x1c(%ebp)
  801158:	e8 d3 fb ff ff       	call   800d30 <sys_page_alloc>
	if( r < 0)
  80115d:	83 c4 10             	add    $0x10,%esp
  801160:	85 c0                	test   %eax,%eax
  801162:	78 36                	js     80119a <fork+0x1b7>
		panic("sys_page_alloc: %e", r);

    // Set the page fault upcall for the child
    r=sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  801164:	83 ec 08             	sub    $0x8,%esp
  801167:	68 a0 13 80 00       	push   $0x8013a0
  80116c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80116f:	e8 d5 fc ff ff       	call   800e49 <sys_env_set_pgfault_upcall>
    if( r < 0 )
  801174:	83 c4 10             	add    $0x10,%esp
  801177:	85 c0                	test   %eax,%eax
  801179:	78 34                	js     8011af <fork+0x1cc>
		panic("sys_env_set_pgfault_upcall: %e",r);
    
    // Mark the child as runnable
    r=sys_env_set_status(envid, ENV_RUNNABLE);
  80117b:	83 ec 08             	sub    $0x8,%esp
  80117e:	6a 02                	push   $0x2
  801180:	ff 75 e4             	pushl  -0x1c(%ebp)
  801183:	e8 7b fc ff ff       	call   800e03 <sys_env_set_status>
    if (r < 0)
  801188:	83 c4 10             	add    $0x10,%esp
  80118b:	85 c0                	test   %eax,%eax
  80118d:	78 35                	js     8011c4 <fork+0x1e1>
		panic("sys_env_set_status: %e", r);
    
    return envid;
	// LAB 4: Your code here.
	//panic("fork not implemented");
}
  80118f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801192:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801195:	5b                   	pop    %ebx
  801196:	5e                   	pop    %esi
  801197:	5f                   	pop    %edi
  801198:	5d                   	pop    %ebp
  801199:	c3                   	ret    
		panic("sys_page_alloc: %e", r);
  80119a:	50                   	push   %eax
  80119b:	68 b6 19 80 00       	push   $0x8019b6
  8011a0:	68 84 00 00 00       	push   $0x84
  8011a5:	68 84 19 80 00       	push   $0x801984
  8011aa:	e8 4a 01 00 00       	call   8012f9 <_panic>
		panic("sys_env_set_pgfault_upcall: %e",r);
  8011af:	50                   	push   %eax
  8011b0:	68 3c 1a 80 00       	push   $0x801a3c
  8011b5:	68 89 00 00 00       	push   $0x89
  8011ba:	68 84 19 80 00       	push   $0x801984
  8011bf:	e8 35 01 00 00       	call   8012f9 <_panic>
		panic("sys_env_set_status: %e", r);
  8011c4:	50                   	push   %eax
  8011c5:	68 0c 1a 80 00       	push   $0x801a0c
  8011ca:	68 8e 00 00 00       	push   $0x8e
  8011cf:	68 84 19 80 00       	push   $0x801984
  8011d4:	e8 20 01 00 00       	call   8012f9 <_panic>

008011d9 <sfork>:

// Challenge!
int
sfork(void)
{
  8011d9:	f3 0f 1e fb          	endbr32 
  8011dd:	55                   	push   %ebp
  8011de:	89 e5                	mov    %esp,%ebp
  8011e0:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8011e3:	68 23 1a 80 00       	push   $0x801a23
  8011e8:	68 99 00 00 00       	push   $0x99
  8011ed:	68 84 19 80 00       	push   $0x801984
  8011f2:	e8 02 01 00 00       	call   8012f9 <_panic>

008011f7 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8011f7:	f3 0f 1e fb          	endbr32 
  8011fb:	55                   	push   %ebp
  8011fc:	89 e5                	mov    %esp,%ebp
  8011fe:	56                   	push   %esi
  8011ff:	53                   	push   %ebx
  801200:	8b 75 08             	mov    0x8(%ebp),%esi
  801203:	8b 45 0c             	mov    0xc(%ebp),%eax
  801206:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// 检查pg是否为空
	if(pg==NULL){
		pg=(void *)-1;
  801209:	85 c0                	test   %eax,%eax
  80120b:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801210:	0f 44 c2             	cmove  %edx,%eax
	}
	//接收 message
	int r = sys_ipc_recv(pg);
  801213:	83 ec 0c             	sub    $0xc,%esp
  801216:	50                   	push   %eax
  801217:	e8 9a fc ff ff       	call   800eb6 <sys_ipc_recv>
	if(r<0){
  80121c:	83 c4 10             	add    $0x10,%esp
  80121f:	85 c0                	test   %eax,%eax
  801221:	78 2b                	js     80124e <ipc_recv+0x57>
		if(from_env_store) *from_env_store=0;
		if(perm_store) *perm_store=0;
		return r;
	}
	// 保存发送者的envid
	if(from_env_store) *from_env_store = thisenv->env_ipc_from;
  801223:	85 f6                	test   %esi,%esi
  801225:	74 0a                	je     801231 <ipc_recv+0x3a>
  801227:	a1 0c 20 80 00       	mov    0x80200c,%eax
  80122c:	8b 40 74             	mov    0x74(%eax),%eax
  80122f:	89 06                	mov    %eax,(%esi)
	// 保存发送来的页面的权限
	if(perm_store) *perm_store = thisenv->env_ipc_perm;
  801231:	85 db                	test   %ebx,%ebx
  801233:	74 0a                	je     80123f <ipc_recv+0x48>
  801235:	a1 0c 20 80 00       	mov    0x80200c,%eax
  80123a:	8b 40 78             	mov    0x78(%eax),%eax
  80123d:	89 03                	mov    %eax,(%ebx)
	// 返回message的value
	return thisenv->env_ipc_value;
  80123f:	a1 0c 20 80 00       	mov    0x80200c,%eax
  801244:	8b 40 70             	mov    0x70(%eax),%eax

	//panic("ipc_recv not implemented");
	return 0;
}
  801247:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80124a:	5b                   	pop    %ebx
  80124b:	5e                   	pop    %esi
  80124c:	5d                   	pop    %ebp
  80124d:	c3                   	ret    
		if(from_env_store) *from_env_store=0;
  80124e:	85 f6                	test   %esi,%esi
  801250:	74 06                	je     801258 <ipc_recv+0x61>
  801252:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store) *perm_store=0;
  801258:	85 db                	test   %ebx,%ebx
  80125a:	74 eb                	je     801247 <ipc_recv+0x50>
  80125c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801262:	eb e3                	jmp    801247 <ipc_recv+0x50>

00801264 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801264:	f3 0f 1e fb          	endbr32 
  801268:	55                   	push   %ebp
  801269:	89 e5                	mov    %esp,%ebp
  80126b:	57                   	push   %edi
  80126c:	56                   	push   %esi
  80126d:	53                   	push   %ebx
  80126e:	83 ec 0c             	sub    $0xc,%esp
  801271:	8b 7d 08             	mov    0x8(%ebp),%edi
  801274:	8b 75 0c             	mov    0xc(%ebp),%esi
  801277:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	// 如果pg为NULL， 要提供给sys_ipc_try_send一个能表达“no page”的值，0是有效的地址
	if(pg==NULL)
	{
		pg = (void *)-1;
  80127a:	85 db                	test   %ebx,%ebx
  80127c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801281:	0f 44 d8             	cmove  %eax,%ebx
	}
	int r;
	//不停尝试发送消息直到成功
	while(1)
	{
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801284:	ff 75 14             	pushl  0x14(%ebp)
  801287:	53                   	push   %ebx
  801288:	56                   	push   %esi
  801289:	57                   	push   %edi
  80128a:	e8 00 fc ff ff       	call   800e8f <sys_ipc_try_send>
		if (r == 0) {		//发送成功
  80128f:	83 c4 10             	add    $0x10,%esp
  801292:	85 c0                	test   %eax,%eax
  801294:	74 1e                	je     8012b4 <ipc_send+0x50>
			return;
		} else if (r == -E_IPC_NOT_RECV) {	//接收环境未准备接收
  801296:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801299:	75 07                	jne    8012a2 <ipc_send+0x3e>
			sys_yield();
  80129b:	e8 6d fa ff ff       	call   800d0d <sys_yield>
		r = sys_ipc_try_send(to_env, val, pg, perm);
  8012a0:	eb e2                	jmp    801284 <ipc_send+0x20>
		}else{
			panic("ipc_send() fault:%e\n", r);
  8012a2:	50                   	push   %eax
  8012a3:	68 5b 1a 80 00       	push   $0x801a5b
  8012a8:	6a 4c                	push   $0x4c
  8012aa:	68 70 1a 80 00       	push   $0x801a70
  8012af:	e8 45 00 00 00       	call   8012f9 <_panic>
		}
	}
}
  8012b4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012b7:	5b                   	pop    %ebx
  8012b8:	5e                   	pop    %esi
  8012b9:	5f                   	pop    %edi
  8012ba:	5d                   	pop    %ebp
  8012bb:	c3                   	ret    

008012bc <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8012bc:	f3 0f 1e fb          	endbr32 
  8012c0:	55                   	push   %ebp
  8012c1:	89 e5                	mov    %esp,%ebp
  8012c3:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8012c6:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8012cb:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8012ce:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8012d4:	8b 52 50             	mov    0x50(%edx),%edx
  8012d7:	39 ca                	cmp    %ecx,%edx
  8012d9:	74 11                	je     8012ec <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  8012db:	83 c0 01             	add    $0x1,%eax
  8012de:	3d 00 04 00 00       	cmp    $0x400,%eax
  8012e3:	75 e6                	jne    8012cb <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  8012e5:	b8 00 00 00 00       	mov    $0x0,%eax
  8012ea:	eb 0b                	jmp    8012f7 <ipc_find_env+0x3b>
			return envs[i].env_id;
  8012ec:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8012ef:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8012f4:	8b 40 48             	mov    0x48(%eax),%eax
}
  8012f7:	5d                   	pop    %ebp
  8012f8:	c3                   	ret    

008012f9 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8012f9:	f3 0f 1e fb          	endbr32 
  8012fd:	55                   	push   %ebp
  8012fe:	89 e5                	mov    %esp,%ebp
  801300:	56                   	push   %esi
  801301:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801302:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801305:	8b 35 08 20 80 00    	mov    0x802008,%esi
  80130b:	e8 da f9 ff ff       	call   800cea <sys_getenvid>
  801310:	83 ec 0c             	sub    $0xc,%esp
  801313:	ff 75 0c             	pushl  0xc(%ebp)
  801316:	ff 75 08             	pushl  0x8(%ebp)
  801319:	56                   	push   %esi
  80131a:	50                   	push   %eax
  80131b:	68 7c 1a 80 00       	push   $0x801a7c
  801320:	e8 80 ef ff ff       	call   8002a5 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801325:	83 c4 18             	add    $0x18,%esp
  801328:	53                   	push   %ebx
  801329:	ff 75 10             	pushl  0x10(%ebp)
  80132c:	e8 1f ef ff ff       	call   800250 <vcprintf>
	cprintf("\n");
  801331:	c7 04 24 6e 1a 80 00 	movl   $0x801a6e,(%esp)
  801338:	e8 68 ef ff ff       	call   8002a5 <cprintf>
  80133d:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801340:	cc                   	int3   
  801341:	eb fd                	jmp    801340 <_panic+0x47>

00801343 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801343:	f3 0f 1e fb          	endbr32 
  801347:	55                   	push   %ebp
  801348:	89 e5                	mov    %esp,%ebp
  80134a:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  80134d:	83 3d 10 20 80 00 00 	cmpl   $0x0,0x802010
  801354:	74 0a                	je     801360 <set_pgfault_handler+0x1d>
        sys_env_set_pgfault_upcall(0, _pgfault_upcall);
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801356:	8b 45 08             	mov    0x8(%ebp),%eax
  801359:	a3 10 20 80 00       	mov    %eax,0x802010
}
  80135e:	c9                   	leave  
  80135f:	c3                   	ret    
		if (sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P) < 0)
  801360:	83 ec 04             	sub    $0x4,%esp
  801363:	6a 07                	push   $0x7
  801365:	68 00 f0 bf ee       	push   $0xeebff000
  80136a:	6a 00                	push   $0x0
  80136c:	e8 bf f9 ff ff       	call   800d30 <sys_page_alloc>
  801371:	83 c4 10             	add    $0x10,%esp
  801374:	85 c0                	test   %eax,%eax
  801376:	78 14                	js     80138c <set_pgfault_handler+0x49>
        sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  801378:	83 ec 08             	sub    $0x8,%esp
  80137b:	68 a0 13 80 00       	push   $0x8013a0
  801380:	6a 00                	push   $0x0
  801382:	e8 c2 fa ff ff       	call   800e49 <sys_env_set_pgfault_upcall>
  801387:	83 c4 10             	add    $0x10,%esp
  80138a:	eb ca                	jmp    801356 <set_pgfault_handler+0x13>
            panic("set_pgfault_handler failed.");
  80138c:	83 ec 04             	sub    $0x4,%esp
  80138f:	68 9f 1a 80 00       	push   $0x801a9f
  801394:	6a 21                	push   $0x21
  801396:	68 bb 1a 80 00       	push   $0x801abb
  80139b:	e8 59 ff ff ff       	call   8012f9 <_panic>

008013a0 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8013a0:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8013a1:	a1 10 20 80 00       	mov    0x802010,%eax
	call *%eax
  8013a6:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8013a8:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	addl $8, %esp
  8013ab:	83 c4 08             	add    $0x8,%esp
	movl 32(%esp), %eax
  8013ae:	8b 44 24 20          	mov    0x20(%esp),%eax
	movl 40(%esp), %edx
  8013b2:	8b 54 24 28          	mov    0x28(%esp),%edx
	subl $4, %edx
  8013b6:	83 ea 04             	sub    $0x4,%edx
	movl %eax, (%edx)
  8013b9:	89 02                	mov    %eax,(%edx)
	movl %edx, 40(%esp)
  8013bb:	89 54 24 28          	mov    %edx,0x28(%esp)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal
  8013bf:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp
  8013c0:	83 c4 04             	add    $0x4,%esp
	popfl
  8013c3:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  8013c4:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  8013c5:	c3                   	ret    
  8013c6:	66 90                	xchg   %ax,%ax
  8013c8:	66 90                	xchg   %ax,%ax
  8013ca:	66 90                	xchg   %ax,%ax
  8013cc:	66 90                	xchg   %ax,%ax
  8013ce:	66 90                	xchg   %ax,%ax

008013d0 <__udivdi3>:
  8013d0:	f3 0f 1e fb          	endbr32 
  8013d4:	55                   	push   %ebp
  8013d5:	57                   	push   %edi
  8013d6:	56                   	push   %esi
  8013d7:	53                   	push   %ebx
  8013d8:	83 ec 1c             	sub    $0x1c,%esp
  8013db:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8013df:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  8013e3:	8b 74 24 34          	mov    0x34(%esp),%esi
  8013e7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  8013eb:	85 d2                	test   %edx,%edx
  8013ed:	75 19                	jne    801408 <__udivdi3+0x38>
  8013ef:	39 f3                	cmp    %esi,%ebx
  8013f1:	76 4d                	jbe    801440 <__udivdi3+0x70>
  8013f3:	31 ff                	xor    %edi,%edi
  8013f5:	89 e8                	mov    %ebp,%eax
  8013f7:	89 f2                	mov    %esi,%edx
  8013f9:	f7 f3                	div    %ebx
  8013fb:	89 fa                	mov    %edi,%edx
  8013fd:	83 c4 1c             	add    $0x1c,%esp
  801400:	5b                   	pop    %ebx
  801401:	5e                   	pop    %esi
  801402:	5f                   	pop    %edi
  801403:	5d                   	pop    %ebp
  801404:	c3                   	ret    
  801405:	8d 76 00             	lea    0x0(%esi),%esi
  801408:	39 f2                	cmp    %esi,%edx
  80140a:	76 14                	jbe    801420 <__udivdi3+0x50>
  80140c:	31 ff                	xor    %edi,%edi
  80140e:	31 c0                	xor    %eax,%eax
  801410:	89 fa                	mov    %edi,%edx
  801412:	83 c4 1c             	add    $0x1c,%esp
  801415:	5b                   	pop    %ebx
  801416:	5e                   	pop    %esi
  801417:	5f                   	pop    %edi
  801418:	5d                   	pop    %ebp
  801419:	c3                   	ret    
  80141a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801420:	0f bd fa             	bsr    %edx,%edi
  801423:	83 f7 1f             	xor    $0x1f,%edi
  801426:	75 48                	jne    801470 <__udivdi3+0xa0>
  801428:	39 f2                	cmp    %esi,%edx
  80142a:	72 06                	jb     801432 <__udivdi3+0x62>
  80142c:	31 c0                	xor    %eax,%eax
  80142e:	39 eb                	cmp    %ebp,%ebx
  801430:	77 de                	ja     801410 <__udivdi3+0x40>
  801432:	b8 01 00 00 00       	mov    $0x1,%eax
  801437:	eb d7                	jmp    801410 <__udivdi3+0x40>
  801439:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801440:	89 d9                	mov    %ebx,%ecx
  801442:	85 db                	test   %ebx,%ebx
  801444:	75 0b                	jne    801451 <__udivdi3+0x81>
  801446:	b8 01 00 00 00       	mov    $0x1,%eax
  80144b:	31 d2                	xor    %edx,%edx
  80144d:	f7 f3                	div    %ebx
  80144f:	89 c1                	mov    %eax,%ecx
  801451:	31 d2                	xor    %edx,%edx
  801453:	89 f0                	mov    %esi,%eax
  801455:	f7 f1                	div    %ecx
  801457:	89 c6                	mov    %eax,%esi
  801459:	89 e8                	mov    %ebp,%eax
  80145b:	89 f7                	mov    %esi,%edi
  80145d:	f7 f1                	div    %ecx
  80145f:	89 fa                	mov    %edi,%edx
  801461:	83 c4 1c             	add    $0x1c,%esp
  801464:	5b                   	pop    %ebx
  801465:	5e                   	pop    %esi
  801466:	5f                   	pop    %edi
  801467:	5d                   	pop    %ebp
  801468:	c3                   	ret    
  801469:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801470:	89 f9                	mov    %edi,%ecx
  801472:	b8 20 00 00 00       	mov    $0x20,%eax
  801477:	29 f8                	sub    %edi,%eax
  801479:	d3 e2                	shl    %cl,%edx
  80147b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80147f:	89 c1                	mov    %eax,%ecx
  801481:	89 da                	mov    %ebx,%edx
  801483:	d3 ea                	shr    %cl,%edx
  801485:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801489:	09 d1                	or     %edx,%ecx
  80148b:	89 f2                	mov    %esi,%edx
  80148d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801491:	89 f9                	mov    %edi,%ecx
  801493:	d3 e3                	shl    %cl,%ebx
  801495:	89 c1                	mov    %eax,%ecx
  801497:	d3 ea                	shr    %cl,%edx
  801499:	89 f9                	mov    %edi,%ecx
  80149b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80149f:	89 eb                	mov    %ebp,%ebx
  8014a1:	d3 e6                	shl    %cl,%esi
  8014a3:	89 c1                	mov    %eax,%ecx
  8014a5:	d3 eb                	shr    %cl,%ebx
  8014a7:	09 de                	or     %ebx,%esi
  8014a9:	89 f0                	mov    %esi,%eax
  8014ab:	f7 74 24 08          	divl   0x8(%esp)
  8014af:	89 d6                	mov    %edx,%esi
  8014b1:	89 c3                	mov    %eax,%ebx
  8014b3:	f7 64 24 0c          	mull   0xc(%esp)
  8014b7:	39 d6                	cmp    %edx,%esi
  8014b9:	72 15                	jb     8014d0 <__udivdi3+0x100>
  8014bb:	89 f9                	mov    %edi,%ecx
  8014bd:	d3 e5                	shl    %cl,%ebp
  8014bf:	39 c5                	cmp    %eax,%ebp
  8014c1:	73 04                	jae    8014c7 <__udivdi3+0xf7>
  8014c3:	39 d6                	cmp    %edx,%esi
  8014c5:	74 09                	je     8014d0 <__udivdi3+0x100>
  8014c7:	89 d8                	mov    %ebx,%eax
  8014c9:	31 ff                	xor    %edi,%edi
  8014cb:	e9 40 ff ff ff       	jmp    801410 <__udivdi3+0x40>
  8014d0:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8014d3:	31 ff                	xor    %edi,%edi
  8014d5:	e9 36 ff ff ff       	jmp    801410 <__udivdi3+0x40>
  8014da:	66 90                	xchg   %ax,%ax
  8014dc:	66 90                	xchg   %ax,%ax
  8014de:	66 90                	xchg   %ax,%ax

008014e0 <__umoddi3>:
  8014e0:	f3 0f 1e fb          	endbr32 
  8014e4:	55                   	push   %ebp
  8014e5:	57                   	push   %edi
  8014e6:	56                   	push   %esi
  8014e7:	53                   	push   %ebx
  8014e8:	83 ec 1c             	sub    $0x1c,%esp
  8014eb:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  8014ef:	8b 74 24 30          	mov    0x30(%esp),%esi
  8014f3:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  8014f7:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8014fb:	85 c0                	test   %eax,%eax
  8014fd:	75 19                	jne    801518 <__umoddi3+0x38>
  8014ff:	39 df                	cmp    %ebx,%edi
  801501:	76 5d                	jbe    801560 <__umoddi3+0x80>
  801503:	89 f0                	mov    %esi,%eax
  801505:	89 da                	mov    %ebx,%edx
  801507:	f7 f7                	div    %edi
  801509:	89 d0                	mov    %edx,%eax
  80150b:	31 d2                	xor    %edx,%edx
  80150d:	83 c4 1c             	add    $0x1c,%esp
  801510:	5b                   	pop    %ebx
  801511:	5e                   	pop    %esi
  801512:	5f                   	pop    %edi
  801513:	5d                   	pop    %ebp
  801514:	c3                   	ret    
  801515:	8d 76 00             	lea    0x0(%esi),%esi
  801518:	89 f2                	mov    %esi,%edx
  80151a:	39 d8                	cmp    %ebx,%eax
  80151c:	76 12                	jbe    801530 <__umoddi3+0x50>
  80151e:	89 f0                	mov    %esi,%eax
  801520:	89 da                	mov    %ebx,%edx
  801522:	83 c4 1c             	add    $0x1c,%esp
  801525:	5b                   	pop    %ebx
  801526:	5e                   	pop    %esi
  801527:	5f                   	pop    %edi
  801528:	5d                   	pop    %ebp
  801529:	c3                   	ret    
  80152a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801530:	0f bd e8             	bsr    %eax,%ebp
  801533:	83 f5 1f             	xor    $0x1f,%ebp
  801536:	75 50                	jne    801588 <__umoddi3+0xa8>
  801538:	39 d8                	cmp    %ebx,%eax
  80153a:	0f 82 e0 00 00 00    	jb     801620 <__umoddi3+0x140>
  801540:	89 d9                	mov    %ebx,%ecx
  801542:	39 f7                	cmp    %esi,%edi
  801544:	0f 86 d6 00 00 00    	jbe    801620 <__umoddi3+0x140>
  80154a:	89 d0                	mov    %edx,%eax
  80154c:	89 ca                	mov    %ecx,%edx
  80154e:	83 c4 1c             	add    $0x1c,%esp
  801551:	5b                   	pop    %ebx
  801552:	5e                   	pop    %esi
  801553:	5f                   	pop    %edi
  801554:	5d                   	pop    %ebp
  801555:	c3                   	ret    
  801556:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80155d:	8d 76 00             	lea    0x0(%esi),%esi
  801560:	89 fd                	mov    %edi,%ebp
  801562:	85 ff                	test   %edi,%edi
  801564:	75 0b                	jne    801571 <__umoddi3+0x91>
  801566:	b8 01 00 00 00       	mov    $0x1,%eax
  80156b:	31 d2                	xor    %edx,%edx
  80156d:	f7 f7                	div    %edi
  80156f:	89 c5                	mov    %eax,%ebp
  801571:	89 d8                	mov    %ebx,%eax
  801573:	31 d2                	xor    %edx,%edx
  801575:	f7 f5                	div    %ebp
  801577:	89 f0                	mov    %esi,%eax
  801579:	f7 f5                	div    %ebp
  80157b:	89 d0                	mov    %edx,%eax
  80157d:	31 d2                	xor    %edx,%edx
  80157f:	eb 8c                	jmp    80150d <__umoddi3+0x2d>
  801581:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801588:	89 e9                	mov    %ebp,%ecx
  80158a:	ba 20 00 00 00       	mov    $0x20,%edx
  80158f:	29 ea                	sub    %ebp,%edx
  801591:	d3 e0                	shl    %cl,%eax
  801593:	89 44 24 08          	mov    %eax,0x8(%esp)
  801597:	89 d1                	mov    %edx,%ecx
  801599:	89 f8                	mov    %edi,%eax
  80159b:	d3 e8                	shr    %cl,%eax
  80159d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8015a1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8015a5:	8b 54 24 04          	mov    0x4(%esp),%edx
  8015a9:	09 c1                	or     %eax,%ecx
  8015ab:	89 d8                	mov    %ebx,%eax
  8015ad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8015b1:	89 e9                	mov    %ebp,%ecx
  8015b3:	d3 e7                	shl    %cl,%edi
  8015b5:	89 d1                	mov    %edx,%ecx
  8015b7:	d3 e8                	shr    %cl,%eax
  8015b9:	89 e9                	mov    %ebp,%ecx
  8015bb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8015bf:	d3 e3                	shl    %cl,%ebx
  8015c1:	89 c7                	mov    %eax,%edi
  8015c3:	89 d1                	mov    %edx,%ecx
  8015c5:	89 f0                	mov    %esi,%eax
  8015c7:	d3 e8                	shr    %cl,%eax
  8015c9:	89 e9                	mov    %ebp,%ecx
  8015cb:	89 fa                	mov    %edi,%edx
  8015cd:	d3 e6                	shl    %cl,%esi
  8015cf:	09 d8                	or     %ebx,%eax
  8015d1:	f7 74 24 08          	divl   0x8(%esp)
  8015d5:	89 d1                	mov    %edx,%ecx
  8015d7:	89 f3                	mov    %esi,%ebx
  8015d9:	f7 64 24 0c          	mull   0xc(%esp)
  8015dd:	89 c6                	mov    %eax,%esi
  8015df:	89 d7                	mov    %edx,%edi
  8015e1:	39 d1                	cmp    %edx,%ecx
  8015e3:	72 06                	jb     8015eb <__umoddi3+0x10b>
  8015e5:	75 10                	jne    8015f7 <__umoddi3+0x117>
  8015e7:	39 c3                	cmp    %eax,%ebx
  8015e9:	73 0c                	jae    8015f7 <__umoddi3+0x117>
  8015eb:	2b 44 24 0c          	sub    0xc(%esp),%eax
  8015ef:	1b 54 24 08          	sbb    0x8(%esp),%edx
  8015f3:	89 d7                	mov    %edx,%edi
  8015f5:	89 c6                	mov    %eax,%esi
  8015f7:	89 ca                	mov    %ecx,%edx
  8015f9:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8015fe:	29 f3                	sub    %esi,%ebx
  801600:	19 fa                	sbb    %edi,%edx
  801602:	89 d0                	mov    %edx,%eax
  801604:	d3 e0                	shl    %cl,%eax
  801606:	89 e9                	mov    %ebp,%ecx
  801608:	d3 eb                	shr    %cl,%ebx
  80160a:	d3 ea                	shr    %cl,%edx
  80160c:	09 d8                	or     %ebx,%eax
  80160e:	83 c4 1c             	add    $0x1c,%esp
  801611:	5b                   	pop    %ebx
  801612:	5e                   	pop    %esi
  801613:	5f                   	pop    %edi
  801614:	5d                   	pop    %ebp
  801615:	c3                   	ret    
  801616:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80161d:	8d 76 00             	lea    0x0(%esi),%esi
  801620:	29 fe                	sub    %edi,%esi
  801622:	19 c3                	sbb    %eax,%ebx
  801624:	89 f2                	mov    %esi,%edx
  801626:	89 d9                	mov    %ebx,%ecx
  801628:	e9 1d ff ff ff       	jmp    80154a <__umoddi3+0x6a>
