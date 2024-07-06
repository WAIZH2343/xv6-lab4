
obj/user/yield:     file format elf32-i386


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
  80002c:	e8 6d 00 00 00       	call   80009e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	f3 0f 1e fb          	endbr32 
  800037:	55                   	push   %ebp
  800038:	89 e5                	mov    %esp,%ebp
  80003a:	53                   	push   %ebx
  80003b:	83 ec 0c             	sub    $0xc,%esp
	int i;

	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
  80003e:	a1 04 20 80 00       	mov    0x802004,%eax
  800043:	8b 40 48             	mov    0x48(%eax),%eax
  800046:	50                   	push   %eax
  800047:	68 a0 10 80 00       	push   $0x8010a0
  80004c:	e8 4a 01 00 00       	call   80019b <cprintf>
  800051:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 5; i++) {
  800054:	bb 00 00 00 00       	mov    $0x0,%ebx
		sys_yield();
  800059:	e8 a5 0b 00 00       	call   800c03 <sys_yield>
		cprintf("Back in environment %08x, iteration %d.\n",
			thisenv->env_id, i);
  80005e:	a1 04 20 80 00       	mov    0x802004,%eax
		cprintf("Back in environment %08x, iteration %d.\n",
  800063:	8b 40 48             	mov    0x48(%eax),%eax
  800066:	83 ec 04             	sub    $0x4,%esp
  800069:	53                   	push   %ebx
  80006a:	50                   	push   %eax
  80006b:	68 c0 10 80 00       	push   $0x8010c0
  800070:	e8 26 01 00 00       	call   80019b <cprintf>
	for (i = 0; i < 5; i++) {
  800075:	83 c3 01             	add    $0x1,%ebx
  800078:	83 c4 10             	add    $0x10,%esp
  80007b:	83 fb 05             	cmp    $0x5,%ebx
  80007e:	75 d9                	jne    800059 <umain+0x26>
	}
	cprintf("All done in environment %08x.\n", thisenv->env_id);
  800080:	a1 04 20 80 00       	mov    0x802004,%eax
  800085:	8b 40 48             	mov    0x48(%eax),%eax
  800088:	83 ec 08             	sub    $0x8,%esp
  80008b:	50                   	push   %eax
  80008c:	68 ec 10 80 00       	push   $0x8010ec
  800091:	e8 05 01 00 00       	call   80019b <cprintf>
}
  800096:	83 c4 10             	add    $0x10,%esp
  800099:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80009c:	c9                   	leave  
  80009d:	c3                   	ret    

0080009e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80009e:	f3 0f 1e fb          	endbr32 
  8000a2:	55                   	push   %ebp
  8000a3:	89 e5                	mov    %esp,%ebp
  8000a5:	56                   	push   %esi
  8000a6:	53                   	push   %ebx
  8000a7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000aa:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv=&envs[ENVX(sys_getenvid())];
  8000ad:	e8 2e 0b 00 00       	call   800be0 <sys_getenvid>
  8000b2:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000b7:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000ba:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000bf:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000c4:	85 db                	test   %ebx,%ebx
  8000c6:	7e 07                	jle    8000cf <libmain+0x31>
		binaryname = argv[0];
  8000c8:	8b 06                	mov    (%esi),%eax
  8000ca:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000cf:	83 ec 08             	sub    $0x8,%esp
  8000d2:	56                   	push   %esi
  8000d3:	53                   	push   %ebx
  8000d4:	e8 5a ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000d9:	e8 0a 00 00 00       	call   8000e8 <exit>
}
  8000de:	83 c4 10             	add    $0x10,%esp
  8000e1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000e4:	5b                   	pop    %ebx
  8000e5:	5e                   	pop    %esi
  8000e6:	5d                   	pop    %ebp
  8000e7:	c3                   	ret    

008000e8 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000e8:	f3 0f 1e fb          	endbr32 
  8000ec:	55                   	push   %ebp
  8000ed:	89 e5                	mov    %esp,%ebp
  8000ef:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000f2:	6a 00                	push   $0x0
  8000f4:	e8 a2 0a 00 00       	call   800b9b <sys_env_destroy>
}
  8000f9:	83 c4 10             	add    $0x10,%esp
  8000fc:	c9                   	leave  
  8000fd:	c3                   	ret    

008000fe <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000fe:	f3 0f 1e fb          	endbr32 
  800102:	55                   	push   %ebp
  800103:	89 e5                	mov    %esp,%ebp
  800105:	53                   	push   %ebx
  800106:	83 ec 04             	sub    $0x4,%esp
  800109:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80010c:	8b 13                	mov    (%ebx),%edx
  80010e:	8d 42 01             	lea    0x1(%edx),%eax
  800111:	89 03                	mov    %eax,(%ebx)
  800113:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800116:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80011a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80011f:	74 09                	je     80012a <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800121:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800125:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800128:	c9                   	leave  
  800129:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80012a:	83 ec 08             	sub    $0x8,%esp
  80012d:	68 ff 00 00 00       	push   $0xff
  800132:	8d 43 08             	lea    0x8(%ebx),%eax
  800135:	50                   	push   %eax
  800136:	e8 1b 0a 00 00       	call   800b56 <sys_cputs>
		b->idx = 0;
  80013b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800141:	83 c4 10             	add    $0x10,%esp
  800144:	eb db                	jmp    800121 <putch+0x23>

00800146 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800146:	f3 0f 1e fb          	endbr32 
  80014a:	55                   	push   %ebp
  80014b:	89 e5                	mov    %esp,%ebp
  80014d:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800153:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80015a:	00 00 00 
	b.cnt = 0;
  80015d:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800164:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800167:	ff 75 0c             	pushl  0xc(%ebp)
  80016a:	ff 75 08             	pushl  0x8(%ebp)
  80016d:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800173:	50                   	push   %eax
  800174:	68 fe 00 80 00       	push   $0x8000fe
  800179:	e8 20 01 00 00       	call   80029e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80017e:	83 c4 08             	add    $0x8,%esp
  800181:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800187:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80018d:	50                   	push   %eax
  80018e:	e8 c3 09 00 00       	call   800b56 <sys_cputs>

	return b.cnt;
}
  800193:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800199:	c9                   	leave  
  80019a:	c3                   	ret    

0080019b <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80019b:	f3 0f 1e fb          	endbr32 
  80019f:	55                   	push   %ebp
  8001a0:	89 e5                	mov    %esp,%ebp
  8001a2:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001a5:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001a8:	50                   	push   %eax
  8001a9:	ff 75 08             	pushl  0x8(%ebp)
  8001ac:	e8 95 ff ff ff       	call   800146 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001b1:	c9                   	leave  
  8001b2:	c3                   	ret    

008001b3 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001b3:	55                   	push   %ebp
  8001b4:	89 e5                	mov    %esp,%ebp
  8001b6:	57                   	push   %edi
  8001b7:	56                   	push   %esi
  8001b8:	53                   	push   %ebx
  8001b9:	83 ec 1c             	sub    $0x1c,%esp
  8001bc:	89 c7                	mov    %eax,%edi
  8001be:	89 d6                	mov    %edx,%esi
  8001c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8001c3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001c6:	89 d1                	mov    %edx,%ecx
  8001c8:	89 c2                	mov    %eax,%edx
  8001ca:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001cd:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8001d0:	8b 45 10             	mov    0x10(%ebp),%eax
  8001d3:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001d6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001d9:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8001e0:	39 c2                	cmp    %eax,%edx
  8001e2:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8001e5:	72 3e                	jb     800225 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001e7:	83 ec 0c             	sub    $0xc,%esp
  8001ea:	ff 75 18             	pushl  0x18(%ebp)
  8001ed:	83 eb 01             	sub    $0x1,%ebx
  8001f0:	53                   	push   %ebx
  8001f1:	50                   	push   %eax
  8001f2:	83 ec 08             	sub    $0x8,%esp
  8001f5:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001f8:	ff 75 e0             	pushl  -0x20(%ebp)
  8001fb:	ff 75 dc             	pushl  -0x24(%ebp)
  8001fe:	ff 75 d8             	pushl  -0x28(%ebp)
  800201:	e8 3a 0c 00 00       	call   800e40 <__udivdi3>
  800206:	83 c4 18             	add    $0x18,%esp
  800209:	52                   	push   %edx
  80020a:	50                   	push   %eax
  80020b:	89 f2                	mov    %esi,%edx
  80020d:	89 f8                	mov    %edi,%eax
  80020f:	e8 9f ff ff ff       	call   8001b3 <printnum>
  800214:	83 c4 20             	add    $0x20,%esp
  800217:	eb 13                	jmp    80022c <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800219:	83 ec 08             	sub    $0x8,%esp
  80021c:	56                   	push   %esi
  80021d:	ff 75 18             	pushl  0x18(%ebp)
  800220:	ff d7                	call   *%edi
  800222:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800225:	83 eb 01             	sub    $0x1,%ebx
  800228:	85 db                	test   %ebx,%ebx
  80022a:	7f ed                	jg     800219 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80022c:	83 ec 08             	sub    $0x8,%esp
  80022f:	56                   	push   %esi
  800230:	83 ec 04             	sub    $0x4,%esp
  800233:	ff 75 e4             	pushl  -0x1c(%ebp)
  800236:	ff 75 e0             	pushl  -0x20(%ebp)
  800239:	ff 75 dc             	pushl  -0x24(%ebp)
  80023c:	ff 75 d8             	pushl  -0x28(%ebp)
  80023f:	e8 0c 0d 00 00       	call   800f50 <__umoddi3>
  800244:	83 c4 14             	add    $0x14,%esp
  800247:	0f be 80 15 11 80 00 	movsbl 0x801115(%eax),%eax
  80024e:	50                   	push   %eax
  80024f:	ff d7                	call   *%edi
}
  800251:	83 c4 10             	add    $0x10,%esp
  800254:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800257:	5b                   	pop    %ebx
  800258:	5e                   	pop    %esi
  800259:	5f                   	pop    %edi
  80025a:	5d                   	pop    %ebp
  80025b:	c3                   	ret    

0080025c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80025c:	f3 0f 1e fb          	endbr32 
  800260:	55                   	push   %ebp
  800261:	89 e5                	mov    %esp,%ebp
  800263:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800266:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80026a:	8b 10                	mov    (%eax),%edx
  80026c:	3b 50 04             	cmp    0x4(%eax),%edx
  80026f:	73 0a                	jae    80027b <sprintputch+0x1f>
		*b->buf++ = ch;
  800271:	8d 4a 01             	lea    0x1(%edx),%ecx
  800274:	89 08                	mov    %ecx,(%eax)
  800276:	8b 45 08             	mov    0x8(%ebp),%eax
  800279:	88 02                	mov    %al,(%edx)
}
  80027b:	5d                   	pop    %ebp
  80027c:	c3                   	ret    

0080027d <printfmt>:
{
  80027d:	f3 0f 1e fb          	endbr32 
  800281:	55                   	push   %ebp
  800282:	89 e5                	mov    %esp,%ebp
  800284:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800287:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80028a:	50                   	push   %eax
  80028b:	ff 75 10             	pushl  0x10(%ebp)
  80028e:	ff 75 0c             	pushl  0xc(%ebp)
  800291:	ff 75 08             	pushl  0x8(%ebp)
  800294:	e8 05 00 00 00       	call   80029e <vprintfmt>
}
  800299:	83 c4 10             	add    $0x10,%esp
  80029c:	c9                   	leave  
  80029d:	c3                   	ret    

0080029e <vprintfmt>:
{
  80029e:	f3 0f 1e fb          	endbr32 
  8002a2:	55                   	push   %ebp
  8002a3:	89 e5                	mov    %esp,%ebp
  8002a5:	57                   	push   %edi
  8002a6:	56                   	push   %esi
  8002a7:	53                   	push   %ebx
  8002a8:	83 ec 3c             	sub    $0x3c,%esp
  8002ab:	8b 75 08             	mov    0x8(%ebp),%esi
  8002ae:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002b1:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002b4:	e9 cd 03 00 00       	jmp    800686 <vprintfmt+0x3e8>
		padc = ' ';
  8002b9:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  8002bd:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8002c4:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8002cb:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8002d2:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8002d7:	8d 47 01             	lea    0x1(%edi),%eax
  8002da:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002dd:	0f b6 17             	movzbl (%edi),%edx
  8002e0:	8d 42 dd             	lea    -0x23(%edx),%eax
  8002e3:	3c 55                	cmp    $0x55,%al
  8002e5:	0f 87 1e 04 00 00    	ja     800709 <vprintfmt+0x46b>
  8002eb:	0f b6 c0             	movzbl %al,%eax
  8002ee:	3e ff 24 85 e0 11 80 	notrack jmp *0x8011e0(,%eax,4)
  8002f5:	00 
  8002f6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8002f9:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  8002fd:	eb d8                	jmp    8002d7 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8002ff:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800302:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  800306:	eb cf                	jmp    8002d7 <vprintfmt+0x39>
  800308:	0f b6 d2             	movzbl %dl,%edx
  80030b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  80030e:	b8 00 00 00 00       	mov    $0x0,%eax
  800313:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800316:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800319:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80031d:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800320:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800323:	83 f9 09             	cmp    $0x9,%ecx
  800326:	77 55                	ja     80037d <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  800328:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80032b:	eb e9                	jmp    800316 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  80032d:	8b 45 14             	mov    0x14(%ebp),%eax
  800330:	8b 00                	mov    (%eax),%eax
  800332:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800335:	8b 45 14             	mov    0x14(%ebp),%eax
  800338:	8d 40 04             	lea    0x4(%eax),%eax
  80033b:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80033e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800341:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800345:	79 90                	jns    8002d7 <vprintfmt+0x39>
				width = precision, precision = -1;
  800347:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80034a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80034d:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800354:	eb 81                	jmp    8002d7 <vprintfmt+0x39>
  800356:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800359:	85 c0                	test   %eax,%eax
  80035b:	ba 00 00 00 00       	mov    $0x0,%edx
  800360:	0f 49 d0             	cmovns %eax,%edx
  800363:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800366:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800369:	e9 69 ff ff ff       	jmp    8002d7 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  80036e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800371:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  800378:	e9 5a ff ff ff       	jmp    8002d7 <vprintfmt+0x39>
  80037d:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800380:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800383:	eb bc                	jmp    800341 <vprintfmt+0xa3>
			lflag++;
  800385:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800388:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80038b:	e9 47 ff ff ff       	jmp    8002d7 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  800390:	8b 45 14             	mov    0x14(%ebp),%eax
  800393:	8d 78 04             	lea    0x4(%eax),%edi
  800396:	83 ec 08             	sub    $0x8,%esp
  800399:	53                   	push   %ebx
  80039a:	ff 30                	pushl  (%eax)
  80039c:	ff d6                	call   *%esi
			break;
  80039e:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8003a1:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8003a4:	e9 da 02 00 00       	jmp    800683 <vprintfmt+0x3e5>
			err = va_arg(ap, int);
  8003a9:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ac:	8d 78 04             	lea    0x4(%eax),%edi
  8003af:	8b 00                	mov    (%eax),%eax
  8003b1:	99                   	cltd   
  8003b2:	31 d0                	xor    %edx,%eax
  8003b4:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003b6:	83 f8 08             	cmp    $0x8,%eax
  8003b9:	7f 23                	jg     8003de <vprintfmt+0x140>
  8003bb:	8b 14 85 40 13 80 00 	mov    0x801340(,%eax,4),%edx
  8003c2:	85 d2                	test   %edx,%edx
  8003c4:	74 18                	je     8003de <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  8003c6:	52                   	push   %edx
  8003c7:	68 36 11 80 00       	push   $0x801136
  8003cc:	53                   	push   %ebx
  8003cd:	56                   	push   %esi
  8003ce:	e8 aa fe ff ff       	call   80027d <printfmt>
  8003d3:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003d6:	89 7d 14             	mov    %edi,0x14(%ebp)
  8003d9:	e9 a5 02 00 00       	jmp    800683 <vprintfmt+0x3e5>
				printfmt(putch, putdat, "error %d", err);
  8003de:	50                   	push   %eax
  8003df:	68 2d 11 80 00       	push   $0x80112d
  8003e4:	53                   	push   %ebx
  8003e5:	56                   	push   %esi
  8003e6:	e8 92 fe ff ff       	call   80027d <printfmt>
  8003eb:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003ee:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8003f1:	e9 8d 02 00 00       	jmp    800683 <vprintfmt+0x3e5>
			if ((p = va_arg(ap, char *)) == NULL)
  8003f6:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f9:	83 c0 04             	add    $0x4,%eax
  8003fc:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8003ff:	8b 45 14             	mov    0x14(%ebp),%eax
  800402:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  800404:	85 d2                	test   %edx,%edx
  800406:	b8 26 11 80 00       	mov    $0x801126,%eax
  80040b:	0f 45 c2             	cmovne %edx,%eax
  80040e:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  800411:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800415:	7e 06                	jle    80041d <vprintfmt+0x17f>
  800417:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  80041b:	75 0d                	jne    80042a <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  80041d:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800420:	89 c7                	mov    %eax,%edi
  800422:	03 45 e0             	add    -0x20(%ebp),%eax
  800425:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800428:	eb 55                	jmp    80047f <vprintfmt+0x1e1>
  80042a:	83 ec 08             	sub    $0x8,%esp
  80042d:	ff 75 d8             	pushl  -0x28(%ebp)
  800430:	ff 75 cc             	pushl  -0x34(%ebp)
  800433:	e8 85 03 00 00       	call   8007bd <strnlen>
  800438:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80043b:	29 c2                	sub    %eax,%edx
  80043d:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  800440:	83 c4 10             	add    $0x10,%esp
  800443:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  800445:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  800449:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  80044c:	85 ff                	test   %edi,%edi
  80044e:	7e 11                	jle    800461 <vprintfmt+0x1c3>
					putch(padc, putdat);
  800450:	83 ec 08             	sub    $0x8,%esp
  800453:	53                   	push   %ebx
  800454:	ff 75 e0             	pushl  -0x20(%ebp)
  800457:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800459:	83 ef 01             	sub    $0x1,%edi
  80045c:	83 c4 10             	add    $0x10,%esp
  80045f:	eb eb                	jmp    80044c <vprintfmt+0x1ae>
  800461:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800464:	85 d2                	test   %edx,%edx
  800466:	b8 00 00 00 00       	mov    $0x0,%eax
  80046b:	0f 49 c2             	cmovns %edx,%eax
  80046e:	29 c2                	sub    %eax,%edx
  800470:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800473:	eb a8                	jmp    80041d <vprintfmt+0x17f>
					putch(ch, putdat);
  800475:	83 ec 08             	sub    $0x8,%esp
  800478:	53                   	push   %ebx
  800479:	52                   	push   %edx
  80047a:	ff d6                	call   *%esi
  80047c:	83 c4 10             	add    $0x10,%esp
  80047f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800482:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800484:	83 c7 01             	add    $0x1,%edi
  800487:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80048b:	0f be d0             	movsbl %al,%edx
  80048e:	85 d2                	test   %edx,%edx
  800490:	74 4b                	je     8004dd <vprintfmt+0x23f>
  800492:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800496:	78 06                	js     80049e <vprintfmt+0x200>
  800498:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  80049c:	78 1e                	js     8004bc <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
  80049e:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8004a2:	74 d1                	je     800475 <vprintfmt+0x1d7>
  8004a4:	0f be c0             	movsbl %al,%eax
  8004a7:	83 e8 20             	sub    $0x20,%eax
  8004aa:	83 f8 5e             	cmp    $0x5e,%eax
  8004ad:	76 c6                	jbe    800475 <vprintfmt+0x1d7>
					putch('?', putdat);
  8004af:	83 ec 08             	sub    $0x8,%esp
  8004b2:	53                   	push   %ebx
  8004b3:	6a 3f                	push   $0x3f
  8004b5:	ff d6                	call   *%esi
  8004b7:	83 c4 10             	add    $0x10,%esp
  8004ba:	eb c3                	jmp    80047f <vprintfmt+0x1e1>
  8004bc:	89 cf                	mov    %ecx,%edi
  8004be:	eb 0e                	jmp    8004ce <vprintfmt+0x230>
				putch(' ', putdat);
  8004c0:	83 ec 08             	sub    $0x8,%esp
  8004c3:	53                   	push   %ebx
  8004c4:	6a 20                	push   $0x20
  8004c6:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8004c8:	83 ef 01             	sub    $0x1,%edi
  8004cb:	83 c4 10             	add    $0x10,%esp
  8004ce:	85 ff                	test   %edi,%edi
  8004d0:	7f ee                	jg     8004c0 <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  8004d2:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8004d5:	89 45 14             	mov    %eax,0x14(%ebp)
  8004d8:	e9 a6 01 00 00       	jmp    800683 <vprintfmt+0x3e5>
  8004dd:	89 cf                	mov    %ecx,%edi
  8004df:	eb ed                	jmp    8004ce <vprintfmt+0x230>
	if (lflag >= 2)
  8004e1:	83 f9 01             	cmp    $0x1,%ecx
  8004e4:	7f 1f                	jg     800505 <vprintfmt+0x267>
	else if (lflag)
  8004e6:	85 c9                	test   %ecx,%ecx
  8004e8:	74 67                	je     800551 <vprintfmt+0x2b3>
		return va_arg(*ap, long);
  8004ea:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ed:	8b 00                	mov    (%eax),%eax
  8004ef:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004f2:	89 c1                	mov    %eax,%ecx
  8004f4:	c1 f9 1f             	sar    $0x1f,%ecx
  8004f7:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8004fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8004fd:	8d 40 04             	lea    0x4(%eax),%eax
  800500:	89 45 14             	mov    %eax,0x14(%ebp)
  800503:	eb 17                	jmp    80051c <vprintfmt+0x27e>
		return va_arg(*ap, long long);
  800505:	8b 45 14             	mov    0x14(%ebp),%eax
  800508:	8b 50 04             	mov    0x4(%eax),%edx
  80050b:	8b 00                	mov    (%eax),%eax
  80050d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800510:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800513:	8b 45 14             	mov    0x14(%ebp),%eax
  800516:	8d 40 08             	lea    0x8(%eax),%eax
  800519:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80051c:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80051f:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800522:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  800527:	85 c9                	test   %ecx,%ecx
  800529:	0f 89 3a 01 00 00    	jns    800669 <vprintfmt+0x3cb>
				putch('-', putdat);
  80052f:	83 ec 08             	sub    $0x8,%esp
  800532:	53                   	push   %ebx
  800533:	6a 2d                	push   $0x2d
  800535:	ff d6                	call   *%esi
				num = -(long long) num;
  800537:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80053a:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80053d:	f7 da                	neg    %edx
  80053f:	83 d1 00             	adc    $0x0,%ecx
  800542:	f7 d9                	neg    %ecx
  800544:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800547:	b8 0a 00 00 00       	mov    $0xa,%eax
  80054c:	e9 18 01 00 00       	jmp    800669 <vprintfmt+0x3cb>
		return va_arg(*ap, int);
  800551:	8b 45 14             	mov    0x14(%ebp),%eax
  800554:	8b 00                	mov    (%eax),%eax
  800556:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800559:	89 c1                	mov    %eax,%ecx
  80055b:	c1 f9 1f             	sar    $0x1f,%ecx
  80055e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800561:	8b 45 14             	mov    0x14(%ebp),%eax
  800564:	8d 40 04             	lea    0x4(%eax),%eax
  800567:	89 45 14             	mov    %eax,0x14(%ebp)
  80056a:	eb b0                	jmp    80051c <vprintfmt+0x27e>
	if (lflag >= 2)
  80056c:	83 f9 01             	cmp    $0x1,%ecx
  80056f:	7f 1e                	jg     80058f <vprintfmt+0x2f1>
	else if (lflag)
  800571:	85 c9                	test   %ecx,%ecx
  800573:	74 32                	je     8005a7 <vprintfmt+0x309>
		return va_arg(*ap, unsigned long);
  800575:	8b 45 14             	mov    0x14(%ebp),%eax
  800578:	8b 10                	mov    (%eax),%edx
  80057a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80057f:	8d 40 04             	lea    0x4(%eax),%eax
  800582:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800585:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  80058a:	e9 da 00 00 00       	jmp    800669 <vprintfmt+0x3cb>
		return va_arg(*ap, unsigned long long);
  80058f:	8b 45 14             	mov    0x14(%ebp),%eax
  800592:	8b 10                	mov    (%eax),%edx
  800594:	8b 48 04             	mov    0x4(%eax),%ecx
  800597:	8d 40 08             	lea    0x8(%eax),%eax
  80059a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80059d:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  8005a2:	e9 c2 00 00 00       	jmp    800669 <vprintfmt+0x3cb>
		return va_arg(*ap, unsigned int);
  8005a7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005aa:	8b 10                	mov    (%eax),%edx
  8005ac:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005b1:	8d 40 04             	lea    0x4(%eax),%eax
  8005b4:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005b7:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  8005bc:	e9 a8 00 00 00       	jmp    800669 <vprintfmt+0x3cb>
	if (lflag >= 2)
  8005c1:	83 f9 01             	cmp    $0x1,%ecx
  8005c4:	7f 1b                	jg     8005e1 <vprintfmt+0x343>
	else if (lflag)
  8005c6:	85 c9                	test   %ecx,%ecx
  8005c8:	74 5c                	je     800626 <vprintfmt+0x388>
		return va_arg(*ap, long);
  8005ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cd:	8b 00                	mov    (%eax),%eax
  8005cf:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005d2:	99                   	cltd   
  8005d3:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d9:	8d 40 04             	lea    0x4(%eax),%eax
  8005dc:	89 45 14             	mov    %eax,0x14(%ebp)
  8005df:	eb 17                	jmp    8005f8 <vprintfmt+0x35a>
		return va_arg(*ap, long long);
  8005e1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e4:	8b 50 04             	mov    0x4(%eax),%edx
  8005e7:	8b 00                	mov    (%eax),%eax
  8005e9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005ec:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f2:	8d 40 08             	lea    0x8(%eax),%eax
  8005f5:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8005f8:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005fb:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 8;
  8005fe:	b8 08 00 00 00       	mov    $0x8,%eax
			if ((long long) num < 0) {
  800603:	85 c9                	test   %ecx,%ecx
  800605:	79 62                	jns    800669 <vprintfmt+0x3cb>
				putch('-', putdat);
  800607:	83 ec 08             	sub    $0x8,%esp
  80060a:	53                   	push   %ebx
  80060b:	6a 2d                	push   $0x2d
  80060d:	ff d6                	call   *%esi
				num = -(long long) num;
  80060f:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800612:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800615:	f7 da                	neg    %edx
  800617:	83 d1 00             	adc    $0x0,%ecx
  80061a:	f7 d9                	neg    %ecx
  80061c:	83 c4 10             	add    $0x10,%esp
			base = 8;
  80061f:	b8 08 00 00 00       	mov    $0x8,%eax
  800624:	eb 43                	jmp    800669 <vprintfmt+0x3cb>
		return va_arg(*ap, int);
  800626:	8b 45 14             	mov    0x14(%ebp),%eax
  800629:	8b 00                	mov    (%eax),%eax
  80062b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80062e:	89 c1                	mov    %eax,%ecx
  800630:	c1 f9 1f             	sar    $0x1f,%ecx
  800633:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800636:	8b 45 14             	mov    0x14(%ebp),%eax
  800639:	8d 40 04             	lea    0x4(%eax),%eax
  80063c:	89 45 14             	mov    %eax,0x14(%ebp)
  80063f:	eb b7                	jmp    8005f8 <vprintfmt+0x35a>
			putch('0', putdat);
  800641:	83 ec 08             	sub    $0x8,%esp
  800644:	53                   	push   %ebx
  800645:	6a 30                	push   $0x30
  800647:	ff d6                	call   *%esi
			putch('x', putdat);
  800649:	83 c4 08             	add    $0x8,%esp
  80064c:	53                   	push   %ebx
  80064d:	6a 78                	push   $0x78
  80064f:	ff d6                	call   *%esi
			num = (unsigned long long)
  800651:	8b 45 14             	mov    0x14(%ebp),%eax
  800654:	8b 10                	mov    (%eax),%edx
  800656:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  80065b:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  80065e:	8d 40 04             	lea    0x4(%eax),%eax
  800661:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800664:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  800669:	83 ec 0c             	sub    $0xc,%esp
  80066c:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  800670:	57                   	push   %edi
  800671:	ff 75 e0             	pushl  -0x20(%ebp)
  800674:	50                   	push   %eax
  800675:	51                   	push   %ecx
  800676:	52                   	push   %edx
  800677:	89 da                	mov    %ebx,%edx
  800679:	89 f0                	mov    %esi,%eax
  80067b:	e8 33 fb ff ff       	call   8001b3 <printnum>
			break;
  800680:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  800683:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800686:	83 c7 01             	add    $0x1,%edi
  800689:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80068d:	83 f8 25             	cmp    $0x25,%eax
  800690:	0f 84 23 fc ff ff    	je     8002b9 <vprintfmt+0x1b>
			if (ch == '\0')
  800696:	85 c0                	test   %eax,%eax
  800698:	0f 84 8b 00 00 00    	je     800729 <vprintfmt+0x48b>
			putch(ch, putdat);
  80069e:	83 ec 08             	sub    $0x8,%esp
  8006a1:	53                   	push   %ebx
  8006a2:	50                   	push   %eax
  8006a3:	ff d6                	call   *%esi
  8006a5:	83 c4 10             	add    $0x10,%esp
  8006a8:	eb dc                	jmp    800686 <vprintfmt+0x3e8>
	if (lflag >= 2)
  8006aa:	83 f9 01             	cmp    $0x1,%ecx
  8006ad:	7f 1b                	jg     8006ca <vprintfmt+0x42c>
	else if (lflag)
  8006af:	85 c9                	test   %ecx,%ecx
  8006b1:	74 2c                	je     8006df <vprintfmt+0x441>
		return va_arg(*ap, unsigned long);
  8006b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b6:	8b 10                	mov    (%eax),%edx
  8006b8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006bd:	8d 40 04             	lea    0x4(%eax),%eax
  8006c0:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006c3:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  8006c8:	eb 9f                	jmp    800669 <vprintfmt+0x3cb>
		return va_arg(*ap, unsigned long long);
  8006ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8006cd:	8b 10                	mov    (%eax),%edx
  8006cf:	8b 48 04             	mov    0x4(%eax),%ecx
  8006d2:	8d 40 08             	lea    0x8(%eax),%eax
  8006d5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006d8:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  8006dd:	eb 8a                	jmp    800669 <vprintfmt+0x3cb>
		return va_arg(*ap, unsigned int);
  8006df:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e2:	8b 10                	mov    (%eax),%edx
  8006e4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006e9:	8d 40 04             	lea    0x4(%eax),%eax
  8006ec:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006ef:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  8006f4:	e9 70 ff ff ff       	jmp    800669 <vprintfmt+0x3cb>
			putch(ch, putdat);
  8006f9:	83 ec 08             	sub    $0x8,%esp
  8006fc:	53                   	push   %ebx
  8006fd:	6a 25                	push   $0x25
  8006ff:	ff d6                	call   *%esi
			break;
  800701:	83 c4 10             	add    $0x10,%esp
  800704:	e9 7a ff ff ff       	jmp    800683 <vprintfmt+0x3e5>
			putch('%', putdat);
  800709:	83 ec 08             	sub    $0x8,%esp
  80070c:	53                   	push   %ebx
  80070d:	6a 25                	push   $0x25
  80070f:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800711:	83 c4 10             	add    $0x10,%esp
  800714:	89 f8                	mov    %edi,%eax
  800716:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80071a:	74 05                	je     800721 <vprintfmt+0x483>
  80071c:	83 e8 01             	sub    $0x1,%eax
  80071f:	eb f5                	jmp    800716 <vprintfmt+0x478>
  800721:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800724:	e9 5a ff ff ff       	jmp    800683 <vprintfmt+0x3e5>
}
  800729:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80072c:	5b                   	pop    %ebx
  80072d:	5e                   	pop    %esi
  80072e:	5f                   	pop    %edi
  80072f:	5d                   	pop    %ebp
  800730:	c3                   	ret    

00800731 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800731:	f3 0f 1e fb          	endbr32 
  800735:	55                   	push   %ebp
  800736:	89 e5                	mov    %esp,%ebp
  800738:	83 ec 18             	sub    $0x18,%esp
  80073b:	8b 45 08             	mov    0x8(%ebp),%eax
  80073e:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800741:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800744:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800748:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80074b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800752:	85 c0                	test   %eax,%eax
  800754:	74 26                	je     80077c <vsnprintf+0x4b>
  800756:	85 d2                	test   %edx,%edx
  800758:	7e 22                	jle    80077c <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80075a:	ff 75 14             	pushl  0x14(%ebp)
  80075d:	ff 75 10             	pushl  0x10(%ebp)
  800760:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800763:	50                   	push   %eax
  800764:	68 5c 02 80 00       	push   $0x80025c
  800769:	e8 30 fb ff ff       	call   80029e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80076e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800771:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800774:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800777:	83 c4 10             	add    $0x10,%esp
}
  80077a:	c9                   	leave  
  80077b:	c3                   	ret    
		return -E_INVAL;
  80077c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800781:	eb f7                	jmp    80077a <vsnprintf+0x49>

00800783 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800783:	f3 0f 1e fb          	endbr32 
  800787:	55                   	push   %ebp
  800788:	89 e5                	mov    %esp,%ebp
  80078a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80078d:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800790:	50                   	push   %eax
  800791:	ff 75 10             	pushl  0x10(%ebp)
  800794:	ff 75 0c             	pushl  0xc(%ebp)
  800797:	ff 75 08             	pushl  0x8(%ebp)
  80079a:	e8 92 ff ff ff       	call   800731 <vsnprintf>
	va_end(ap);

	return rc;
}
  80079f:	c9                   	leave  
  8007a0:	c3                   	ret    

008007a1 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007a1:	f3 0f 1e fb          	endbr32 
  8007a5:	55                   	push   %ebp
  8007a6:	89 e5                	mov    %esp,%ebp
  8007a8:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007ab:	b8 00 00 00 00       	mov    $0x0,%eax
  8007b0:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007b4:	74 05                	je     8007bb <strlen+0x1a>
		n++;
  8007b6:	83 c0 01             	add    $0x1,%eax
  8007b9:	eb f5                	jmp    8007b0 <strlen+0xf>
	return n;
}
  8007bb:	5d                   	pop    %ebp
  8007bc:	c3                   	ret    

008007bd <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007bd:	f3 0f 1e fb          	endbr32 
  8007c1:	55                   	push   %ebp
  8007c2:	89 e5                	mov    %esp,%ebp
  8007c4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007c7:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007ca:	b8 00 00 00 00       	mov    $0x0,%eax
  8007cf:	39 d0                	cmp    %edx,%eax
  8007d1:	74 0d                	je     8007e0 <strnlen+0x23>
  8007d3:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007d7:	74 05                	je     8007de <strnlen+0x21>
		n++;
  8007d9:	83 c0 01             	add    $0x1,%eax
  8007dc:	eb f1                	jmp    8007cf <strnlen+0x12>
  8007de:	89 c2                	mov    %eax,%edx
	return n;
}
  8007e0:	89 d0                	mov    %edx,%eax
  8007e2:	5d                   	pop    %ebp
  8007e3:	c3                   	ret    

008007e4 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007e4:	f3 0f 1e fb          	endbr32 
  8007e8:	55                   	push   %ebp
  8007e9:	89 e5                	mov    %esp,%ebp
  8007eb:	53                   	push   %ebx
  8007ec:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007ef:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007f2:	b8 00 00 00 00       	mov    $0x0,%eax
  8007f7:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8007fb:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8007fe:	83 c0 01             	add    $0x1,%eax
  800801:	84 d2                	test   %dl,%dl
  800803:	75 f2                	jne    8007f7 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  800805:	89 c8                	mov    %ecx,%eax
  800807:	5b                   	pop    %ebx
  800808:	5d                   	pop    %ebp
  800809:	c3                   	ret    

0080080a <strcat>:

char *
strcat(char *dst, const char *src)
{
  80080a:	f3 0f 1e fb          	endbr32 
  80080e:	55                   	push   %ebp
  80080f:	89 e5                	mov    %esp,%ebp
  800811:	53                   	push   %ebx
  800812:	83 ec 10             	sub    $0x10,%esp
  800815:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800818:	53                   	push   %ebx
  800819:	e8 83 ff ff ff       	call   8007a1 <strlen>
  80081e:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800821:	ff 75 0c             	pushl  0xc(%ebp)
  800824:	01 d8                	add    %ebx,%eax
  800826:	50                   	push   %eax
  800827:	e8 b8 ff ff ff       	call   8007e4 <strcpy>
	return dst;
}
  80082c:	89 d8                	mov    %ebx,%eax
  80082e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800831:	c9                   	leave  
  800832:	c3                   	ret    

00800833 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800833:	f3 0f 1e fb          	endbr32 
  800837:	55                   	push   %ebp
  800838:	89 e5                	mov    %esp,%ebp
  80083a:	56                   	push   %esi
  80083b:	53                   	push   %ebx
  80083c:	8b 75 08             	mov    0x8(%ebp),%esi
  80083f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800842:	89 f3                	mov    %esi,%ebx
  800844:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800847:	89 f0                	mov    %esi,%eax
  800849:	39 d8                	cmp    %ebx,%eax
  80084b:	74 11                	je     80085e <strncpy+0x2b>
		*dst++ = *src;
  80084d:	83 c0 01             	add    $0x1,%eax
  800850:	0f b6 0a             	movzbl (%edx),%ecx
  800853:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800856:	80 f9 01             	cmp    $0x1,%cl
  800859:	83 da ff             	sbb    $0xffffffff,%edx
  80085c:	eb eb                	jmp    800849 <strncpy+0x16>
	}
	return ret;
}
  80085e:	89 f0                	mov    %esi,%eax
  800860:	5b                   	pop    %ebx
  800861:	5e                   	pop    %esi
  800862:	5d                   	pop    %ebp
  800863:	c3                   	ret    

00800864 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800864:	f3 0f 1e fb          	endbr32 
  800868:	55                   	push   %ebp
  800869:	89 e5                	mov    %esp,%ebp
  80086b:	56                   	push   %esi
  80086c:	53                   	push   %ebx
  80086d:	8b 75 08             	mov    0x8(%ebp),%esi
  800870:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800873:	8b 55 10             	mov    0x10(%ebp),%edx
  800876:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800878:	85 d2                	test   %edx,%edx
  80087a:	74 21                	je     80089d <strlcpy+0x39>
  80087c:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800880:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  800882:	39 c2                	cmp    %eax,%edx
  800884:	74 14                	je     80089a <strlcpy+0x36>
  800886:	0f b6 19             	movzbl (%ecx),%ebx
  800889:	84 db                	test   %bl,%bl
  80088b:	74 0b                	je     800898 <strlcpy+0x34>
			*dst++ = *src++;
  80088d:	83 c1 01             	add    $0x1,%ecx
  800890:	83 c2 01             	add    $0x1,%edx
  800893:	88 5a ff             	mov    %bl,-0x1(%edx)
  800896:	eb ea                	jmp    800882 <strlcpy+0x1e>
  800898:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  80089a:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80089d:	29 f0                	sub    %esi,%eax
}
  80089f:	5b                   	pop    %ebx
  8008a0:	5e                   	pop    %esi
  8008a1:	5d                   	pop    %ebp
  8008a2:	c3                   	ret    

008008a3 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008a3:	f3 0f 1e fb          	endbr32 
  8008a7:	55                   	push   %ebp
  8008a8:	89 e5                	mov    %esp,%ebp
  8008aa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008ad:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008b0:	0f b6 01             	movzbl (%ecx),%eax
  8008b3:	84 c0                	test   %al,%al
  8008b5:	74 0c                	je     8008c3 <strcmp+0x20>
  8008b7:	3a 02                	cmp    (%edx),%al
  8008b9:	75 08                	jne    8008c3 <strcmp+0x20>
		p++, q++;
  8008bb:	83 c1 01             	add    $0x1,%ecx
  8008be:	83 c2 01             	add    $0x1,%edx
  8008c1:	eb ed                	jmp    8008b0 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008c3:	0f b6 c0             	movzbl %al,%eax
  8008c6:	0f b6 12             	movzbl (%edx),%edx
  8008c9:	29 d0                	sub    %edx,%eax
}
  8008cb:	5d                   	pop    %ebp
  8008cc:	c3                   	ret    

008008cd <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008cd:	f3 0f 1e fb          	endbr32 
  8008d1:	55                   	push   %ebp
  8008d2:	89 e5                	mov    %esp,%ebp
  8008d4:	53                   	push   %ebx
  8008d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008db:	89 c3                	mov    %eax,%ebx
  8008dd:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008e0:	eb 06                	jmp    8008e8 <strncmp+0x1b>
		n--, p++, q++;
  8008e2:	83 c0 01             	add    $0x1,%eax
  8008e5:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8008e8:	39 d8                	cmp    %ebx,%eax
  8008ea:	74 16                	je     800902 <strncmp+0x35>
  8008ec:	0f b6 08             	movzbl (%eax),%ecx
  8008ef:	84 c9                	test   %cl,%cl
  8008f1:	74 04                	je     8008f7 <strncmp+0x2a>
  8008f3:	3a 0a                	cmp    (%edx),%cl
  8008f5:	74 eb                	je     8008e2 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008f7:	0f b6 00             	movzbl (%eax),%eax
  8008fa:	0f b6 12             	movzbl (%edx),%edx
  8008fd:	29 d0                	sub    %edx,%eax
}
  8008ff:	5b                   	pop    %ebx
  800900:	5d                   	pop    %ebp
  800901:	c3                   	ret    
		return 0;
  800902:	b8 00 00 00 00       	mov    $0x0,%eax
  800907:	eb f6                	jmp    8008ff <strncmp+0x32>

00800909 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800909:	f3 0f 1e fb          	endbr32 
  80090d:	55                   	push   %ebp
  80090e:	89 e5                	mov    %esp,%ebp
  800910:	8b 45 08             	mov    0x8(%ebp),%eax
  800913:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800917:	0f b6 10             	movzbl (%eax),%edx
  80091a:	84 d2                	test   %dl,%dl
  80091c:	74 09                	je     800927 <strchr+0x1e>
		if (*s == c)
  80091e:	38 ca                	cmp    %cl,%dl
  800920:	74 0a                	je     80092c <strchr+0x23>
	for (; *s; s++)
  800922:	83 c0 01             	add    $0x1,%eax
  800925:	eb f0                	jmp    800917 <strchr+0xe>
			return (char *) s;
	return 0;
  800927:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80092c:	5d                   	pop    %ebp
  80092d:	c3                   	ret    

0080092e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80092e:	f3 0f 1e fb          	endbr32 
  800932:	55                   	push   %ebp
  800933:	89 e5                	mov    %esp,%ebp
  800935:	8b 45 08             	mov    0x8(%ebp),%eax
  800938:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80093c:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80093f:	38 ca                	cmp    %cl,%dl
  800941:	74 09                	je     80094c <strfind+0x1e>
  800943:	84 d2                	test   %dl,%dl
  800945:	74 05                	je     80094c <strfind+0x1e>
	for (; *s; s++)
  800947:	83 c0 01             	add    $0x1,%eax
  80094a:	eb f0                	jmp    80093c <strfind+0xe>
			break;
	return (char *) s;
}
  80094c:	5d                   	pop    %ebp
  80094d:	c3                   	ret    

0080094e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80094e:	f3 0f 1e fb          	endbr32 
  800952:	55                   	push   %ebp
  800953:	89 e5                	mov    %esp,%ebp
  800955:	57                   	push   %edi
  800956:	56                   	push   %esi
  800957:	53                   	push   %ebx
  800958:	8b 7d 08             	mov    0x8(%ebp),%edi
  80095b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80095e:	85 c9                	test   %ecx,%ecx
  800960:	74 31                	je     800993 <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800962:	89 f8                	mov    %edi,%eax
  800964:	09 c8                	or     %ecx,%eax
  800966:	a8 03                	test   $0x3,%al
  800968:	75 23                	jne    80098d <memset+0x3f>
		c &= 0xFF;
  80096a:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80096e:	89 d3                	mov    %edx,%ebx
  800970:	c1 e3 08             	shl    $0x8,%ebx
  800973:	89 d0                	mov    %edx,%eax
  800975:	c1 e0 18             	shl    $0x18,%eax
  800978:	89 d6                	mov    %edx,%esi
  80097a:	c1 e6 10             	shl    $0x10,%esi
  80097d:	09 f0                	or     %esi,%eax
  80097f:	09 c2                	or     %eax,%edx
  800981:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800983:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800986:	89 d0                	mov    %edx,%eax
  800988:	fc                   	cld    
  800989:	f3 ab                	rep stos %eax,%es:(%edi)
  80098b:	eb 06                	jmp    800993 <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80098d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800990:	fc                   	cld    
  800991:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800993:	89 f8                	mov    %edi,%eax
  800995:	5b                   	pop    %ebx
  800996:	5e                   	pop    %esi
  800997:	5f                   	pop    %edi
  800998:	5d                   	pop    %ebp
  800999:	c3                   	ret    

0080099a <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80099a:	f3 0f 1e fb          	endbr32 
  80099e:	55                   	push   %ebp
  80099f:	89 e5                	mov    %esp,%ebp
  8009a1:	57                   	push   %edi
  8009a2:	56                   	push   %esi
  8009a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a6:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009a9:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009ac:	39 c6                	cmp    %eax,%esi
  8009ae:	73 32                	jae    8009e2 <memmove+0x48>
  8009b0:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009b3:	39 c2                	cmp    %eax,%edx
  8009b5:	76 2b                	jbe    8009e2 <memmove+0x48>
		s += n;
		d += n;
  8009b7:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009ba:	89 fe                	mov    %edi,%esi
  8009bc:	09 ce                	or     %ecx,%esi
  8009be:	09 d6                	or     %edx,%esi
  8009c0:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009c6:	75 0e                	jne    8009d6 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009c8:	83 ef 04             	sub    $0x4,%edi
  8009cb:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009ce:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8009d1:	fd                   	std    
  8009d2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009d4:	eb 09                	jmp    8009df <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009d6:	83 ef 01             	sub    $0x1,%edi
  8009d9:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8009dc:	fd                   	std    
  8009dd:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009df:	fc                   	cld    
  8009e0:	eb 1a                	jmp    8009fc <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009e2:	89 c2                	mov    %eax,%edx
  8009e4:	09 ca                	or     %ecx,%edx
  8009e6:	09 f2                	or     %esi,%edx
  8009e8:	f6 c2 03             	test   $0x3,%dl
  8009eb:	75 0a                	jne    8009f7 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009ed:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8009f0:	89 c7                	mov    %eax,%edi
  8009f2:	fc                   	cld    
  8009f3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009f5:	eb 05                	jmp    8009fc <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  8009f7:	89 c7                	mov    %eax,%edi
  8009f9:	fc                   	cld    
  8009fa:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009fc:	5e                   	pop    %esi
  8009fd:	5f                   	pop    %edi
  8009fe:	5d                   	pop    %ebp
  8009ff:	c3                   	ret    

00800a00 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a00:	f3 0f 1e fb          	endbr32 
  800a04:	55                   	push   %ebp
  800a05:	89 e5                	mov    %esp,%ebp
  800a07:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a0a:	ff 75 10             	pushl  0x10(%ebp)
  800a0d:	ff 75 0c             	pushl  0xc(%ebp)
  800a10:	ff 75 08             	pushl  0x8(%ebp)
  800a13:	e8 82 ff ff ff       	call   80099a <memmove>
}
  800a18:	c9                   	leave  
  800a19:	c3                   	ret    

00800a1a <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a1a:	f3 0f 1e fb          	endbr32 
  800a1e:	55                   	push   %ebp
  800a1f:	89 e5                	mov    %esp,%ebp
  800a21:	56                   	push   %esi
  800a22:	53                   	push   %ebx
  800a23:	8b 45 08             	mov    0x8(%ebp),%eax
  800a26:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a29:	89 c6                	mov    %eax,%esi
  800a2b:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a2e:	39 f0                	cmp    %esi,%eax
  800a30:	74 1c                	je     800a4e <memcmp+0x34>
		if (*s1 != *s2)
  800a32:	0f b6 08             	movzbl (%eax),%ecx
  800a35:	0f b6 1a             	movzbl (%edx),%ebx
  800a38:	38 d9                	cmp    %bl,%cl
  800a3a:	75 08                	jne    800a44 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800a3c:	83 c0 01             	add    $0x1,%eax
  800a3f:	83 c2 01             	add    $0x1,%edx
  800a42:	eb ea                	jmp    800a2e <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800a44:	0f b6 c1             	movzbl %cl,%eax
  800a47:	0f b6 db             	movzbl %bl,%ebx
  800a4a:	29 d8                	sub    %ebx,%eax
  800a4c:	eb 05                	jmp    800a53 <memcmp+0x39>
	}

	return 0;
  800a4e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a53:	5b                   	pop    %ebx
  800a54:	5e                   	pop    %esi
  800a55:	5d                   	pop    %ebp
  800a56:	c3                   	ret    

00800a57 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a57:	f3 0f 1e fb          	endbr32 
  800a5b:	55                   	push   %ebp
  800a5c:	89 e5                	mov    %esp,%ebp
  800a5e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a61:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a64:	89 c2                	mov    %eax,%edx
  800a66:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a69:	39 d0                	cmp    %edx,%eax
  800a6b:	73 09                	jae    800a76 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a6d:	38 08                	cmp    %cl,(%eax)
  800a6f:	74 05                	je     800a76 <memfind+0x1f>
	for (; s < ends; s++)
  800a71:	83 c0 01             	add    $0x1,%eax
  800a74:	eb f3                	jmp    800a69 <memfind+0x12>
			break;
	return (void *) s;
}
  800a76:	5d                   	pop    %ebp
  800a77:	c3                   	ret    

00800a78 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a78:	f3 0f 1e fb          	endbr32 
  800a7c:	55                   	push   %ebp
  800a7d:	89 e5                	mov    %esp,%ebp
  800a7f:	57                   	push   %edi
  800a80:	56                   	push   %esi
  800a81:	53                   	push   %ebx
  800a82:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a85:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a88:	eb 03                	jmp    800a8d <strtol+0x15>
		s++;
  800a8a:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800a8d:	0f b6 01             	movzbl (%ecx),%eax
  800a90:	3c 20                	cmp    $0x20,%al
  800a92:	74 f6                	je     800a8a <strtol+0x12>
  800a94:	3c 09                	cmp    $0x9,%al
  800a96:	74 f2                	je     800a8a <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800a98:	3c 2b                	cmp    $0x2b,%al
  800a9a:	74 2a                	je     800ac6 <strtol+0x4e>
	int neg = 0;
  800a9c:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800aa1:	3c 2d                	cmp    $0x2d,%al
  800aa3:	74 2b                	je     800ad0 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800aa5:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800aab:	75 0f                	jne    800abc <strtol+0x44>
  800aad:	80 39 30             	cmpb   $0x30,(%ecx)
  800ab0:	74 28                	je     800ada <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800ab2:	85 db                	test   %ebx,%ebx
  800ab4:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ab9:	0f 44 d8             	cmove  %eax,%ebx
  800abc:	b8 00 00 00 00       	mov    $0x0,%eax
  800ac1:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800ac4:	eb 46                	jmp    800b0c <strtol+0x94>
		s++;
  800ac6:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800ac9:	bf 00 00 00 00       	mov    $0x0,%edi
  800ace:	eb d5                	jmp    800aa5 <strtol+0x2d>
		s++, neg = 1;
  800ad0:	83 c1 01             	add    $0x1,%ecx
  800ad3:	bf 01 00 00 00       	mov    $0x1,%edi
  800ad8:	eb cb                	jmp    800aa5 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ada:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800ade:	74 0e                	je     800aee <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800ae0:	85 db                	test   %ebx,%ebx
  800ae2:	75 d8                	jne    800abc <strtol+0x44>
		s++, base = 8;
  800ae4:	83 c1 01             	add    $0x1,%ecx
  800ae7:	bb 08 00 00 00       	mov    $0x8,%ebx
  800aec:	eb ce                	jmp    800abc <strtol+0x44>
		s += 2, base = 16;
  800aee:	83 c1 02             	add    $0x2,%ecx
  800af1:	bb 10 00 00 00       	mov    $0x10,%ebx
  800af6:	eb c4                	jmp    800abc <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800af8:	0f be d2             	movsbl %dl,%edx
  800afb:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800afe:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b01:	7d 3a                	jge    800b3d <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800b03:	83 c1 01             	add    $0x1,%ecx
  800b06:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b0a:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800b0c:	0f b6 11             	movzbl (%ecx),%edx
  800b0f:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b12:	89 f3                	mov    %esi,%ebx
  800b14:	80 fb 09             	cmp    $0x9,%bl
  800b17:	76 df                	jbe    800af8 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800b19:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b1c:	89 f3                	mov    %esi,%ebx
  800b1e:	80 fb 19             	cmp    $0x19,%bl
  800b21:	77 08                	ja     800b2b <strtol+0xb3>
			dig = *s - 'a' + 10;
  800b23:	0f be d2             	movsbl %dl,%edx
  800b26:	83 ea 57             	sub    $0x57,%edx
  800b29:	eb d3                	jmp    800afe <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800b2b:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b2e:	89 f3                	mov    %esi,%ebx
  800b30:	80 fb 19             	cmp    $0x19,%bl
  800b33:	77 08                	ja     800b3d <strtol+0xc5>
			dig = *s - 'A' + 10;
  800b35:	0f be d2             	movsbl %dl,%edx
  800b38:	83 ea 37             	sub    $0x37,%edx
  800b3b:	eb c1                	jmp    800afe <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800b3d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b41:	74 05                	je     800b48 <strtol+0xd0>
		*endptr = (char *) s;
  800b43:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b46:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800b48:	89 c2                	mov    %eax,%edx
  800b4a:	f7 da                	neg    %edx
  800b4c:	85 ff                	test   %edi,%edi
  800b4e:	0f 45 c2             	cmovne %edx,%eax
}
  800b51:	5b                   	pop    %ebx
  800b52:	5e                   	pop    %esi
  800b53:	5f                   	pop    %edi
  800b54:	5d                   	pop    %ebp
  800b55:	c3                   	ret    

00800b56 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b56:	f3 0f 1e fb          	endbr32 
  800b5a:	55                   	push   %ebp
  800b5b:	89 e5                	mov    %esp,%ebp
  800b5d:	57                   	push   %edi
  800b5e:	56                   	push   %esi
  800b5f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b60:	b8 00 00 00 00       	mov    $0x0,%eax
  800b65:	8b 55 08             	mov    0x8(%ebp),%edx
  800b68:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b6b:	89 c3                	mov    %eax,%ebx
  800b6d:	89 c7                	mov    %eax,%edi
  800b6f:	89 c6                	mov    %eax,%esi
  800b71:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b73:	5b                   	pop    %ebx
  800b74:	5e                   	pop    %esi
  800b75:	5f                   	pop    %edi
  800b76:	5d                   	pop    %ebp
  800b77:	c3                   	ret    

00800b78 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b78:	f3 0f 1e fb          	endbr32 
  800b7c:	55                   	push   %ebp
  800b7d:	89 e5                	mov    %esp,%ebp
  800b7f:	57                   	push   %edi
  800b80:	56                   	push   %esi
  800b81:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b82:	ba 00 00 00 00       	mov    $0x0,%edx
  800b87:	b8 01 00 00 00       	mov    $0x1,%eax
  800b8c:	89 d1                	mov    %edx,%ecx
  800b8e:	89 d3                	mov    %edx,%ebx
  800b90:	89 d7                	mov    %edx,%edi
  800b92:	89 d6                	mov    %edx,%esi
  800b94:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b96:	5b                   	pop    %ebx
  800b97:	5e                   	pop    %esi
  800b98:	5f                   	pop    %edi
  800b99:	5d                   	pop    %ebp
  800b9a:	c3                   	ret    

00800b9b <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b9b:	f3 0f 1e fb          	endbr32 
  800b9f:	55                   	push   %ebp
  800ba0:	89 e5                	mov    %esp,%ebp
  800ba2:	57                   	push   %edi
  800ba3:	56                   	push   %esi
  800ba4:	53                   	push   %ebx
  800ba5:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800ba8:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bad:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb0:	b8 03 00 00 00       	mov    $0x3,%eax
  800bb5:	89 cb                	mov    %ecx,%ebx
  800bb7:	89 cf                	mov    %ecx,%edi
  800bb9:	89 ce                	mov    %ecx,%esi
  800bbb:	cd 30                	int    $0x30
	if(check && ret > 0)
  800bbd:	85 c0                	test   %eax,%eax
  800bbf:	7f 08                	jg     800bc9 <sys_env_destroy+0x2e>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bc1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bc4:	5b                   	pop    %ebx
  800bc5:	5e                   	pop    %esi
  800bc6:	5f                   	pop    %edi
  800bc7:	5d                   	pop    %ebp
  800bc8:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800bc9:	83 ec 0c             	sub    $0xc,%esp
  800bcc:	50                   	push   %eax
  800bcd:	6a 03                	push   $0x3
  800bcf:	68 64 13 80 00       	push   $0x801364
  800bd4:	6a 23                	push   $0x23
  800bd6:	68 81 13 80 00       	push   $0x801381
  800bdb:	e8 11 02 00 00       	call   800df1 <_panic>

00800be0 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800be0:	f3 0f 1e fb          	endbr32 
  800be4:	55                   	push   %ebp
  800be5:	89 e5                	mov    %esp,%ebp
  800be7:	57                   	push   %edi
  800be8:	56                   	push   %esi
  800be9:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bea:	ba 00 00 00 00       	mov    $0x0,%edx
  800bef:	b8 02 00 00 00       	mov    $0x2,%eax
  800bf4:	89 d1                	mov    %edx,%ecx
  800bf6:	89 d3                	mov    %edx,%ebx
  800bf8:	89 d7                	mov    %edx,%edi
  800bfa:	89 d6                	mov    %edx,%esi
  800bfc:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bfe:	5b                   	pop    %ebx
  800bff:	5e                   	pop    %esi
  800c00:	5f                   	pop    %edi
  800c01:	5d                   	pop    %ebp
  800c02:	c3                   	ret    

00800c03 <sys_yield>:

void
sys_yield(void)
{
  800c03:	f3 0f 1e fb          	endbr32 
  800c07:	55                   	push   %ebp
  800c08:	89 e5                	mov    %esp,%ebp
  800c0a:	57                   	push   %edi
  800c0b:	56                   	push   %esi
  800c0c:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c0d:	ba 00 00 00 00       	mov    $0x0,%edx
  800c12:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c17:	89 d1                	mov    %edx,%ecx
  800c19:	89 d3                	mov    %edx,%ebx
  800c1b:	89 d7                	mov    %edx,%edi
  800c1d:	89 d6                	mov    %edx,%esi
  800c1f:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c21:	5b                   	pop    %ebx
  800c22:	5e                   	pop    %esi
  800c23:	5f                   	pop    %edi
  800c24:	5d                   	pop    %ebp
  800c25:	c3                   	ret    

00800c26 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c26:	f3 0f 1e fb          	endbr32 
  800c2a:	55                   	push   %ebp
  800c2b:	89 e5                	mov    %esp,%ebp
  800c2d:	57                   	push   %edi
  800c2e:	56                   	push   %esi
  800c2f:	53                   	push   %ebx
  800c30:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c33:	be 00 00 00 00       	mov    $0x0,%esi
  800c38:	8b 55 08             	mov    0x8(%ebp),%edx
  800c3b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c3e:	b8 04 00 00 00       	mov    $0x4,%eax
  800c43:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c46:	89 f7                	mov    %esi,%edi
  800c48:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c4a:	85 c0                	test   %eax,%eax
  800c4c:	7f 08                	jg     800c56 <sys_page_alloc+0x30>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c4e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c51:	5b                   	pop    %ebx
  800c52:	5e                   	pop    %esi
  800c53:	5f                   	pop    %edi
  800c54:	5d                   	pop    %ebp
  800c55:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c56:	83 ec 0c             	sub    $0xc,%esp
  800c59:	50                   	push   %eax
  800c5a:	6a 04                	push   $0x4
  800c5c:	68 64 13 80 00       	push   $0x801364
  800c61:	6a 23                	push   $0x23
  800c63:	68 81 13 80 00       	push   $0x801381
  800c68:	e8 84 01 00 00       	call   800df1 <_panic>

00800c6d <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c6d:	f3 0f 1e fb          	endbr32 
  800c71:	55                   	push   %ebp
  800c72:	89 e5                	mov    %esp,%ebp
  800c74:	57                   	push   %edi
  800c75:	56                   	push   %esi
  800c76:	53                   	push   %ebx
  800c77:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c7a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c7d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c80:	b8 05 00 00 00       	mov    $0x5,%eax
  800c85:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c88:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c8b:	8b 75 18             	mov    0x18(%ebp),%esi
  800c8e:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c90:	85 c0                	test   %eax,%eax
  800c92:	7f 08                	jg     800c9c <sys_page_map+0x2f>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c94:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c97:	5b                   	pop    %ebx
  800c98:	5e                   	pop    %esi
  800c99:	5f                   	pop    %edi
  800c9a:	5d                   	pop    %ebp
  800c9b:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c9c:	83 ec 0c             	sub    $0xc,%esp
  800c9f:	50                   	push   %eax
  800ca0:	6a 05                	push   $0x5
  800ca2:	68 64 13 80 00       	push   $0x801364
  800ca7:	6a 23                	push   $0x23
  800ca9:	68 81 13 80 00       	push   $0x801381
  800cae:	e8 3e 01 00 00       	call   800df1 <_panic>

00800cb3 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800cb3:	f3 0f 1e fb          	endbr32 
  800cb7:	55                   	push   %ebp
  800cb8:	89 e5                	mov    %esp,%ebp
  800cba:	57                   	push   %edi
  800cbb:	56                   	push   %esi
  800cbc:	53                   	push   %ebx
  800cbd:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cc0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cc5:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ccb:	b8 06 00 00 00       	mov    $0x6,%eax
  800cd0:	89 df                	mov    %ebx,%edi
  800cd2:	89 de                	mov    %ebx,%esi
  800cd4:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cd6:	85 c0                	test   %eax,%eax
  800cd8:	7f 08                	jg     800ce2 <sys_page_unmap+0x2f>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cda:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cdd:	5b                   	pop    %ebx
  800cde:	5e                   	pop    %esi
  800cdf:	5f                   	pop    %edi
  800ce0:	5d                   	pop    %ebp
  800ce1:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce2:	83 ec 0c             	sub    $0xc,%esp
  800ce5:	50                   	push   %eax
  800ce6:	6a 06                	push   $0x6
  800ce8:	68 64 13 80 00       	push   $0x801364
  800ced:	6a 23                	push   $0x23
  800cef:	68 81 13 80 00       	push   $0x801381
  800cf4:	e8 f8 00 00 00       	call   800df1 <_panic>

00800cf9 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cf9:	f3 0f 1e fb          	endbr32 
  800cfd:	55                   	push   %ebp
  800cfe:	89 e5                	mov    %esp,%ebp
  800d00:	57                   	push   %edi
  800d01:	56                   	push   %esi
  800d02:	53                   	push   %ebx
  800d03:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d06:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d0b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d0e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d11:	b8 08 00 00 00       	mov    $0x8,%eax
  800d16:	89 df                	mov    %ebx,%edi
  800d18:	89 de                	mov    %ebx,%esi
  800d1a:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d1c:	85 c0                	test   %eax,%eax
  800d1e:	7f 08                	jg     800d28 <sys_env_set_status+0x2f>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d20:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d23:	5b                   	pop    %ebx
  800d24:	5e                   	pop    %esi
  800d25:	5f                   	pop    %edi
  800d26:	5d                   	pop    %ebp
  800d27:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d28:	83 ec 0c             	sub    $0xc,%esp
  800d2b:	50                   	push   %eax
  800d2c:	6a 08                	push   $0x8
  800d2e:	68 64 13 80 00       	push   $0x801364
  800d33:	6a 23                	push   $0x23
  800d35:	68 81 13 80 00       	push   $0x801381
  800d3a:	e8 b2 00 00 00       	call   800df1 <_panic>

00800d3f <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d3f:	f3 0f 1e fb          	endbr32 
  800d43:	55                   	push   %ebp
  800d44:	89 e5                	mov    %esp,%ebp
  800d46:	57                   	push   %edi
  800d47:	56                   	push   %esi
  800d48:	53                   	push   %ebx
  800d49:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d4c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d51:	8b 55 08             	mov    0x8(%ebp),%edx
  800d54:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d57:	b8 09 00 00 00       	mov    $0x9,%eax
  800d5c:	89 df                	mov    %ebx,%edi
  800d5e:	89 de                	mov    %ebx,%esi
  800d60:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d62:	85 c0                	test   %eax,%eax
  800d64:	7f 08                	jg     800d6e <sys_env_set_pgfault_upcall+0x2f>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d66:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d69:	5b                   	pop    %ebx
  800d6a:	5e                   	pop    %esi
  800d6b:	5f                   	pop    %edi
  800d6c:	5d                   	pop    %ebp
  800d6d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d6e:	83 ec 0c             	sub    $0xc,%esp
  800d71:	50                   	push   %eax
  800d72:	6a 09                	push   $0x9
  800d74:	68 64 13 80 00       	push   $0x801364
  800d79:	6a 23                	push   $0x23
  800d7b:	68 81 13 80 00       	push   $0x801381
  800d80:	e8 6c 00 00 00       	call   800df1 <_panic>

00800d85 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d85:	f3 0f 1e fb          	endbr32 
  800d89:	55                   	push   %ebp
  800d8a:	89 e5                	mov    %esp,%ebp
  800d8c:	57                   	push   %edi
  800d8d:	56                   	push   %esi
  800d8e:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d8f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d92:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d95:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d9a:	be 00 00 00 00       	mov    $0x0,%esi
  800d9f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800da2:	8b 7d 14             	mov    0x14(%ebp),%edi
  800da5:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800da7:	5b                   	pop    %ebx
  800da8:	5e                   	pop    %esi
  800da9:	5f                   	pop    %edi
  800daa:	5d                   	pop    %ebp
  800dab:	c3                   	ret    

00800dac <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800dac:	f3 0f 1e fb          	endbr32 
  800db0:	55                   	push   %ebp
  800db1:	89 e5                	mov    %esp,%ebp
  800db3:	57                   	push   %edi
  800db4:	56                   	push   %esi
  800db5:	53                   	push   %ebx
  800db6:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800db9:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dbe:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc1:	b8 0c 00 00 00       	mov    $0xc,%eax
  800dc6:	89 cb                	mov    %ecx,%ebx
  800dc8:	89 cf                	mov    %ecx,%edi
  800dca:	89 ce                	mov    %ecx,%esi
  800dcc:	cd 30                	int    $0x30
	if(check && ret > 0)
  800dce:	85 c0                	test   %eax,%eax
  800dd0:	7f 08                	jg     800dda <sys_ipc_recv+0x2e>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800dd2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dd5:	5b                   	pop    %ebx
  800dd6:	5e                   	pop    %esi
  800dd7:	5f                   	pop    %edi
  800dd8:	5d                   	pop    %ebp
  800dd9:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800dda:	83 ec 0c             	sub    $0xc,%esp
  800ddd:	50                   	push   %eax
  800dde:	6a 0c                	push   $0xc
  800de0:	68 64 13 80 00       	push   $0x801364
  800de5:	6a 23                	push   $0x23
  800de7:	68 81 13 80 00       	push   $0x801381
  800dec:	e8 00 00 00 00       	call   800df1 <_panic>

00800df1 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800df1:	f3 0f 1e fb          	endbr32 
  800df5:	55                   	push   %ebp
  800df6:	89 e5                	mov    %esp,%ebp
  800df8:	56                   	push   %esi
  800df9:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800dfa:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800dfd:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800e03:	e8 d8 fd ff ff       	call   800be0 <sys_getenvid>
  800e08:	83 ec 0c             	sub    $0xc,%esp
  800e0b:	ff 75 0c             	pushl  0xc(%ebp)
  800e0e:	ff 75 08             	pushl  0x8(%ebp)
  800e11:	56                   	push   %esi
  800e12:	50                   	push   %eax
  800e13:	68 90 13 80 00       	push   $0x801390
  800e18:	e8 7e f3 ff ff       	call   80019b <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800e1d:	83 c4 18             	add    $0x18,%esp
  800e20:	53                   	push   %ebx
  800e21:	ff 75 10             	pushl  0x10(%ebp)
  800e24:	e8 1d f3 ff ff       	call   800146 <vcprintf>
	cprintf("\n");
  800e29:	c7 04 24 b3 13 80 00 	movl   $0x8013b3,(%esp)
  800e30:	e8 66 f3 ff ff       	call   80019b <cprintf>
  800e35:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800e38:	cc                   	int3   
  800e39:	eb fd                	jmp    800e38 <_panic+0x47>
  800e3b:	66 90                	xchg   %ax,%ax
  800e3d:	66 90                	xchg   %ax,%ax
  800e3f:	90                   	nop

00800e40 <__udivdi3>:
  800e40:	f3 0f 1e fb          	endbr32 
  800e44:	55                   	push   %ebp
  800e45:	57                   	push   %edi
  800e46:	56                   	push   %esi
  800e47:	53                   	push   %ebx
  800e48:	83 ec 1c             	sub    $0x1c,%esp
  800e4b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800e4f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800e53:	8b 74 24 34          	mov    0x34(%esp),%esi
  800e57:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800e5b:	85 d2                	test   %edx,%edx
  800e5d:	75 19                	jne    800e78 <__udivdi3+0x38>
  800e5f:	39 f3                	cmp    %esi,%ebx
  800e61:	76 4d                	jbe    800eb0 <__udivdi3+0x70>
  800e63:	31 ff                	xor    %edi,%edi
  800e65:	89 e8                	mov    %ebp,%eax
  800e67:	89 f2                	mov    %esi,%edx
  800e69:	f7 f3                	div    %ebx
  800e6b:	89 fa                	mov    %edi,%edx
  800e6d:	83 c4 1c             	add    $0x1c,%esp
  800e70:	5b                   	pop    %ebx
  800e71:	5e                   	pop    %esi
  800e72:	5f                   	pop    %edi
  800e73:	5d                   	pop    %ebp
  800e74:	c3                   	ret    
  800e75:	8d 76 00             	lea    0x0(%esi),%esi
  800e78:	39 f2                	cmp    %esi,%edx
  800e7a:	76 14                	jbe    800e90 <__udivdi3+0x50>
  800e7c:	31 ff                	xor    %edi,%edi
  800e7e:	31 c0                	xor    %eax,%eax
  800e80:	89 fa                	mov    %edi,%edx
  800e82:	83 c4 1c             	add    $0x1c,%esp
  800e85:	5b                   	pop    %ebx
  800e86:	5e                   	pop    %esi
  800e87:	5f                   	pop    %edi
  800e88:	5d                   	pop    %ebp
  800e89:	c3                   	ret    
  800e8a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800e90:	0f bd fa             	bsr    %edx,%edi
  800e93:	83 f7 1f             	xor    $0x1f,%edi
  800e96:	75 48                	jne    800ee0 <__udivdi3+0xa0>
  800e98:	39 f2                	cmp    %esi,%edx
  800e9a:	72 06                	jb     800ea2 <__udivdi3+0x62>
  800e9c:	31 c0                	xor    %eax,%eax
  800e9e:	39 eb                	cmp    %ebp,%ebx
  800ea0:	77 de                	ja     800e80 <__udivdi3+0x40>
  800ea2:	b8 01 00 00 00       	mov    $0x1,%eax
  800ea7:	eb d7                	jmp    800e80 <__udivdi3+0x40>
  800ea9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800eb0:	89 d9                	mov    %ebx,%ecx
  800eb2:	85 db                	test   %ebx,%ebx
  800eb4:	75 0b                	jne    800ec1 <__udivdi3+0x81>
  800eb6:	b8 01 00 00 00       	mov    $0x1,%eax
  800ebb:	31 d2                	xor    %edx,%edx
  800ebd:	f7 f3                	div    %ebx
  800ebf:	89 c1                	mov    %eax,%ecx
  800ec1:	31 d2                	xor    %edx,%edx
  800ec3:	89 f0                	mov    %esi,%eax
  800ec5:	f7 f1                	div    %ecx
  800ec7:	89 c6                	mov    %eax,%esi
  800ec9:	89 e8                	mov    %ebp,%eax
  800ecb:	89 f7                	mov    %esi,%edi
  800ecd:	f7 f1                	div    %ecx
  800ecf:	89 fa                	mov    %edi,%edx
  800ed1:	83 c4 1c             	add    $0x1c,%esp
  800ed4:	5b                   	pop    %ebx
  800ed5:	5e                   	pop    %esi
  800ed6:	5f                   	pop    %edi
  800ed7:	5d                   	pop    %ebp
  800ed8:	c3                   	ret    
  800ed9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800ee0:	89 f9                	mov    %edi,%ecx
  800ee2:	b8 20 00 00 00       	mov    $0x20,%eax
  800ee7:	29 f8                	sub    %edi,%eax
  800ee9:	d3 e2                	shl    %cl,%edx
  800eeb:	89 54 24 08          	mov    %edx,0x8(%esp)
  800eef:	89 c1                	mov    %eax,%ecx
  800ef1:	89 da                	mov    %ebx,%edx
  800ef3:	d3 ea                	shr    %cl,%edx
  800ef5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800ef9:	09 d1                	or     %edx,%ecx
  800efb:	89 f2                	mov    %esi,%edx
  800efd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800f01:	89 f9                	mov    %edi,%ecx
  800f03:	d3 e3                	shl    %cl,%ebx
  800f05:	89 c1                	mov    %eax,%ecx
  800f07:	d3 ea                	shr    %cl,%edx
  800f09:	89 f9                	mov    %edi,%ecx
  800f0b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800f0f:	89 eb                	mov    %ebp,%ebx
  800f11:	d3 e6                	shl    %cl,%esi
  800f13:	89 c1                	mov    %eax,%ecx
  800f15:	d3 eb                	shr    %cl,%ebx
  800f17:	09 de                	or     %ebx,%esi
  800f19:	89 f0                	mov    %esi,%eax
  800f1b:	f7 74 24 08          	divl   0x8(%esp)
  800f1f:	89 d6                	mov    %edx,%esi
  800f21:	89 c3                	mov    %eax,%ebx
  800f23:	f7 64 24 0c          	mull   0xc(%esp)
  800f27:	39 d6                	cmp    %edx,%esi
  800f29:	72 15                	jb     800f40 <__udivdi3+0x100>
  800f2b:	89 f9                	mov    %edi,%ecx
  800f2d:	d3 e5                	shl    %cl,%ebp
  800f2f:	39 c5                	cmp    %eax,%ebp
  800f31:	73 04                	jae    800f37 <__udivdi3+0xf7>
  800f33:	39 d6                	cmp    %edx,%esi
  800f35:	74 09                	je     800f40 <__udivdi3+0x100>
  800f37:	89 d8                	mov    %ebx,%eax
  800f39:	31 ff                	xor    %edi,%edi
  800f3b:	e9 40 ff ff ff       	jmp    800e80 <__udivdi3+0x40>
  800f40:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800f43:	31 ff                	xor    %edi,%edi
  800f45:	e9 36 ff ff ff       	jmp    800e80 <__udivdi3+0x40>
  800f4a:	66 90                	xchg   %ax,%ax
  800f4c:	66 90                	xchg   %ax,%ax
  800f4e:	66 90                	xchg   %ax,%ax

00800f50 <__umoddi3>:
  800f50:	f3 0f 1e fb          	endbr32 
  800f54:	55                   	push   %ebp
  800f55:	57                   	push   %edi
  800f56:	56                   	push   %esi
  800f57:	53                   	push   %ebx
  800f58:	83 ec 1c             	sub    $0x1c,%esp
  800f5b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  800f5f:	8b 74 24 30          	mov    0x30(%esp),%esi
  800f63:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800f67:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800f6b:	85 c0                	test   %eax,%eax
  800f6d:	75 19                	jne    800f88 <__umoddi3+0x38>
  800f6f:	39 df                	cmp    %ebx,%edi
  800f71:	76 5d                	jbe    800fd0 <__umoddi3+0x80>
  800f73:	89 f0                	mov    %esi,%eax
  800f75:	89 da                	mov    %ebx,%edx
  800f77:	f7 f7                	div    %edi
  800f79:	89 d0                	mov    %edx,%eax
  800f7b:	31 d2                	xor    %edx,%edx
  800f7d:	83 c4 1c             	add    $0x1c,%esp
  800f80:	5b                   	pop    %ebx
  800f81:	5e                   	pop    %esi
  800f82:	5f                   	pop    %edi
  800f83:	5d                   	pop    %ebp
  800f84:	c3                   	ret    
  800f85:	8d 76 00             	lea    0x0(%esi),%esi
  800f88:	89 f2                	mov    %esi,%edx
  800f8a:	39 d8                	cmp    %ebx,%eax
  800f8c:	76 12                	jbe    800fa0 <__umoddi3+0x50>
  800f8e:	89 f0                	mov    %esi,%eax
  800f90:	89 da                	mov    %ebx,%edx
  800f92:	83 c4 1c             	add    $0x1c,%esp
  800f95:	5b                   	pop    %ebx
  800f96:	5e                   	pop    %esi
  800f97:	5f                   	pop    %edi
  800f98:	5d                   	pop    %ebp
  800f99:	c3                   	ret    
  800f9a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800fa0:	0f bd e8             	bsr    %eax,%ebp
  800fa3:	83 f5 1f             	xor    $0x1f,%ebp
  800fa6:	75 50                	jne    800ff8 <__umoddi3+0xa8>
  800fa8:	39 d8                	cmp    %ebx,%eax
  800faa:	0f 82 e0 00 00 00    	jb     801090 <__umoddi3+0x140>
  800fb0:	89 d9                	mov    %ebx,%ecx
  800fb2:	39 f7                	cmp    %esi,%edi
  800fb4:	0f 86 d6 00 00 00    	jbe    801090 <__umoddi3+0x140>
  800fba:	89 d0                	mov    %edx,%eax
  800fbc:	89 ca                	mov    %ecx,%edx
  800fbe:	83 c4 1c             	add    $0x1c,%esp
  800fc1:	5b                   	pop    %ebx
  800fc2:	5e                   	pop    %esi
  800fc3:	5f                   	pop    %edi
  800fc4:	5d                   	pop    %ebp
  800fc5:	c3                   	ret    
  800fc6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800fcd:	8d 76 00             	lea    0x0(%esi),%esi
  800fd0:	89 fd                	mov    %edi,%ebp
  800fd2:	85 ff                	test   %edi,%edi
  800fd4:	75 0b                	jne    800fe1 <__umoddi3+0x91>
  800fd6:	b8 01 00 00 00       	mov    $0x1,%eax
  800fdb:	31 d2                	xor    %edx,%edx
  800fdd:	f7 f7                	div    %edi
  800fdf:	89 c5                	mov    %eax,%ebp
  800fe1:	89 d8                	mov    %ebx,%eax
  800fe3:	31 d2                	xor    %edx,%edx
  800fe5:	f7 f5                	div    %ebp
  800fe7:	89 f0                	mov    %esi,%eax
  800fe9:	f7 f5                	div    %ebp
  800feb:	89 d0                	mov    %edx,%eax
  800fed:	31 d2                	xor    %edx,%edx
  800fef:	eb 8c                	jmp    800f7d <__umoddi3+0x2d>
  800ff1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800ff8:	89 e9                	mov    %ebp,%ecx
  800ffa:	ba 20 00 00 00       	mov    $0x20,%edx
  800fff:	29 ea                	sub    %ebp,%edx
  801001:	d3 e0                	shl    %cl,%eax
  801003:	89 44 24 08          	mov    %eax,0x8(%esp)
  801007:	89 d1                	mov    %edx,%ecx
  801009:	89 f8                	mov    %edi,%eax
  80100b:	d3 e8                	shr    %cl,%eax
  80100d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801011:	89 54 24 04          	mov    %edx,0x4(%esp)
  801015:	8b 54 24 04          	mov    0x4(%esp),%edx
  801019:	09 c1                	or     %eax,%ecx
  80101b:	89 d8                	mov    %ebx,%eax
  80101d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801021:	89 e9                	mov    %ebp,%ecx
  801023:	d3 e7                	shl    %cl,%edi
  801025:	89 d1                	mov    %edx,%ecx
  801027:	d3 e8                	shr    %cl,%eax
  801029:	89 e9                	mov    %ebp,%ecx
  80102b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80102f:	d3 e3                	shl    %cl,%ebx
  801031:	89 c7                	mov    %eax,%edi
  801033:	89 d1                	mov    %edx,%ecx
  801035:	89 f0                	mov    %esi,%eax
  801037:	d3 e8                	shr    %cl,%eax
  801039:	89 e9                	mov    %ebp,%ecx
  80103b:	89 fa                	mov    %edi,%edx
  80103d:	d3 e6                	shl    %cl,%esi
  80103f:	09 d8                	or     %ebx,%eax
  801041:	f7 74 24 08          	divl   0x8(%esp)
  801045:	89 d1                	mov    %edx,%ecx
  801047:	89 f3                	mov    %esi,%ebx
  801049:	f7 64 24 0c          	mull   0xc(%esp)
  80104d:	89 c6                	mov    %eax,%esi
  80104f:	89 d7                	mov    %edx,%edi
  801051:	39 d1                	cmp    %edx,%ecx
  801053:	72 06                	jb     80105b <__umoddi3+0x10b>
  801055:	75 10                	jne    801067 <__umoddi3+0x117>
  801057:	39 c3                	cmp    %eax,%ebx
  801059:	73 0c                	jae    801067 <__umoddi3+0x117>
  80105b:	2b 44 24 0c          	sub    0xc(%esp),%eax
  80105f:	1b 54 24 08          	sbb    0x8(%esp),%edx
  801063:	89 d7                	mov    %edx,%edi
  801065:	89 c6                	mov    %eax,%esi
  801067:	89 ca                	mov    %ecx,%edx
  801069:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80106e:	29 f3                	sub    %esi,%ebx
  801070:	19 fa                	sbb    %edi,%edx
  801072:	89 d0                	mov    %edx,%eax
  801074:	d3 e0                	shl    %cl,%eax
  801076:	89 e9                	mov    %ebp,%ecx
  801078:	d3 eb                	shr    %cl,%ebx
  80107a:	d3 ea                	shr    %cl,%edx
  80107c:	09 d8                	or     %ebx,%eax
  80107e:	83 c4 1c             	add    $0x1c,%esp
  801081:	5b                   	pop    %ebx
  801082:	5e                   	pop    %esi
  801083:	5f                   	pop    %edi
  801084:	5d                   	pop    %ebp
  801085:	c3                   	ret    
  801086:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80108d:	8d 76 00             	lea    0x0(%esi),%esi
  801090:	29 fe                	sub    %edi,%esi
  801092:	19 c3                	sbb    %eax,%ebx
  801094:	89 f2                	mov    %esi,%edx
  801096:	89 d9                	mov    %ebx,%ecx
  801098:	e9 1d ff ff ff       	jmp    800fba <__umoddi3+0x6a>
