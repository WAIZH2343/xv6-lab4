
obj/user/spin:     file format elf32-i386


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
  80002c:	e8 88 00 00 00       	call   8000b9 <libmain>
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
  80003b:	83 ec 10             	sub    $0x10,%esp
	envid_t env;

	cprintf("I am the parent.  Forking the child...\n");
  80003e:	68 40 14 80 00       	push   $0x801440
  800043:	e8 6e 01 00 00       	call   8001b6 <cprintf>
	if ((env = fork()) == 0) {
  800048:	e8 a7 0e 00 00       	call   800ef4 <fork>
  80004d:	83 c4 10             	add    $0x10,%esp
  800050:	85 c0                	test   %eax,%eax
  800052:	75 12                	jne    800066 <umain+0x33>
		cprintf("I am the child.  Spinning...\n");
  800054:	83 ec 0c             	sub    $0xc,%esp
  800057:	68 b8 14 80 00       	push   $0x8014b8
  80005c:	e8 55 01 00 00       	call   8001b6 <cprintf>
  800061:	83 c4 10             	add    $0x10,%esp
  800064:	eb fe                	jmp    800064 <umain+0x31>
  800066:	89 c3                	mov    %eax,%ebx
		while (1)
			/* do nothing */;
	}

	cprintf("I am the parent.  Running the child...\n");
  800068:	83 ec 0c             	sub    $0xc,%esp
  80006b:	68 68 14 80 00       	push   $0x801468
  800070:	e8 41 01 00 00       	call   8001b6 <cprintf>
	sys_yield();
  800075:	e8 a4 0b 00 00       	call   800c1e <sys_yield>
	sys_yield();
  80007a:	e8 9f 0b 00 00       	call   800c1e <sys_yield>
	sys_yield();
  80007f:	e8 9a 0b 00 00       	call   800c1e <sys_yield>
	sys_yield();
  800084:	e8 95 0b 00 00       	call   800c1e <sys_yield>
	sys_yield();
  800089:	e8 90 0b 00 00       	call   800c1e <sys_yield>
	sys_yield();
  80008e:	e8 8b 0b 00 00       	call   800c1e <sys_yield>
	sys_yield();
  800093:	e8 86 0b 00 00       	call   800c1e <sys_yield>
	sys_yield();
  800098:	e8 81 0b 00 00       	call   800c1e <sys_yield>

	cprintf("I am the parent.  Killing the child...\n");
  80009d:	c7 04 24 90 14 80 00 	movl   $0x801490,(%esp)
  8000a4:	e8 0d 01 00 00       	call   8001b6 <cprintf>
	sys_env_destroy(env);
  8000a9:	89 1c 24             	mov    %ebx,(%esp)
  8000ac:	e8 05 0b 00 00       	call   800bb6 <sys_env_destroy>
}
  8000b1:	83 c4 10             	add    $0x10,%esp
  8000b4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000b7:	c9                   	leave  
  8000b8:	c3                   	ret    

008000b9 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000b9:	f3 0f 1e fb          	endbr32 
  8000bd:	55                   	push   %ebp
  8000be:	89 e5                	mov    %esp,%ebp
  8000c0:	56                   	push   %esi
  8000c1:	53                   	push   %ebx
  8000c2:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000c5:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv=&envs[ENVX(sys_getenvid())];
  8000c8:	e8 2e 0b 00 00       	call   800bfb <sys_getenvid>
  8000cd:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000d2:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000d5:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000da:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000df:	85 db                	test   %ebx,%ebx
  8000e1:	7e 07                	jle    8000ea <libmain+0x31>
		binaryname = argv[0];
  8000e3:	8b 06                	mov    (%esi),%eax
  8000e5:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000ea:	83 ec 08             	sub    $0x8,%esp
  8000ed:	56                   	push   %esi
  8000ee:	53                   	push   %ebx
  8000ef:	e8 3f ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000f4:	e8 0a 00 00 00       	call   800103 <exit>
}
  8000f9:	83 c4 10             	add    $0x10,%esp
  8000fc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000ff:	5b                   	pop    %ebx
  800100:	5e                   	pop    %esi
  800101:	5d                   	pop    %ebp
  800102:	c3                   	ret    

00800103 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800103:	f3 0f 1e fb          	endbr32 
  800107:	55                   	push   %ebp
  800108:	89 e5                	mov    %esp,%ebp
  80010a:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80010d:	6a 00                	push   $0x0
  80010f:	e8 a2 0a 00 00       	call   800bb6 <sys_env_destroy>
}
  800114:	83 c4 10             	add    $0x10,%esp
  800117:	c9                   	leave  
  800118:	c3                   	ret    

00800119 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800119:	f3 0f 1e fb          	endbr32 
  80011d:	55                   	push   %ebp
  80011e:	89 e5                	mov    %esp,%ebp
  800120:	53                   	push   %ebx
  800121:	83 ec 04             	sub    $0x4,%esp
  800124:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800127:	8b 13                	mov    (%ebx),%edx
  800129:	8d 42 01             	lea    0x1(%edx),%eax
  80012c:	89 03                	mov    %eax,(%ebx)
  80012e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800131:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800135:	3d ff 00 00 00       	cmp    $0xff,%eax
  80013a:	74 09                	je     800145 <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80013c:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800140:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800143:	c9                   	leave  
  800144:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800145:	83 ec 08             	sub    $0x8,%esp
  800148:	68 ff 00 00 00       	push   $0xff
  80014d:	8d 43 08             	lea    0x8(%ebx),%eax
  800150:	50                   	push   %eax
  800151:	e8 1b 0a 00 00       	call   800b71 <sys_cputs>
		b->idx = 0;
  800156:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80015c:	83 c4 10             	add    $0x10,%esp
  80015f:	eb db                	jmp    80013c <putch+0x23>

00800161 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800161:	f3 0f 1e fb          	endbr32 
  800165:	55                   	push   %ebp
  800166:	89 e5                	mov    %esp,%ebp
  800168:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80016e:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800175:	00 00 00 
	b.cnt = 0;
  800178:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80017f:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800182:	ff 75 0c             	pushl  0xc(%ebp)
  800185:	ff 75 08             	pushl  0x8(%ebp)
  800188:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80018e:	50                   	push   %eax
  80018f:	68 19 01 80 00       	push   $0x800119
  800194:	e8 20 01 00 00       	call   8002b9 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800199:	83 c4 08             	add    $0x8,%esp
  80019c:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001a2:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001a8:	50                   	push   %eax
  8001a9:	e8 c3 09 00 00       	call   800b71 <sys_cputs>

	return b.cnt;
}
  8001ae:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001b4:	c9                   	leave  
  8001b5:	c3                   	ret    

008001b6 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001b6:	f3 0f 1e fb          	endbr32 
  8001ba:	55                   	push   %ebp
  8001bb:	89 e5                	mov    %esp,%ebp
  8001bd:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001c0:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001c3:	50                   	push   %eax
  8001c4:	ff 75 08             	pushl  0x8(%ebp)
  8001c7:	e8 95 ff ff ff       	call   800161 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001cc:	c9                   	leave  
  8001cd:	c3                   	ret    

008001ce <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001ce:	55                   	push   %ebp
  8001cf:	89 e5                	mov    %esp,%ebp
  8001d1:	57                   	push   %edi
  8001d2:	56                   	push   %esi
  8001d3:	53                   	push   %ebx
  8001d4:	83 ec 1c             	sub    $0x1c,%esp
  8001d7:	89 c7                	mov    %eax,%edi
  8001d9:	89 d6                	mov    %edx,%esi
  8001db:	8b 45 08             	mov    0x8(%ebp),%eax
  8001de:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001e1:	89 d1                	mov    %edx,%ecx
  8001e3:	89 c2                	mov    %eax,%edx
  8001e5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001e8:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8001eb:	8b 45 10             	mov    0x10(%ebp),%eax
  8001ee:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001f1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001f4:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8001fb:	39 c2                	cmp    %eax,%edx
  8001fd:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800200:	72 3e                	jb     800240 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800202:	83 ec 0c             	sub    $0xc,%esp
  800205:	ff 75 18             	pushl  0x18(%ebp)
  800208:	83 eb 01             	sub    $0x1,%ebx
  80020b:	53                   	push   %ebx
  80020c:	50                   	push   %eax
  80020d:	83 ec 08             	sub    $0x8,%esp
  800210:	ff 75 e4             	pushl  -0x1c(%ebp)
  800213:	ff 75 e0             	pushl  -0x20(%ebp)
  800216:	ff 75 dc             	pushl  -0x24(%ebp)
  800219:	ff 75 d8             	pushl  -0x28(%ebp)
  80021c:	e8 bf 0f 00 00       	call   8011e0 <__udivdi3>
  800221:	83 c4 18             	add    $0x18,%esp
  800224:	52                   	push   %edx
  800225:	50                   	push   %eax
  800226:	89 f2                	mov    %esi,%edx
  800228:	89 f8                	mov    %edi,%eax
  80022a:	e8 9f ff ff ff       	call   8001ce <printnum>
  80022f:	83 c4 20             	add    $0x20,%esp
  800232:	eb 13                	jmp    800247 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800234:	83 ec 08             	sub    $0x8,%esp
  800237:	56                   	push   %esi
  800238:	ff 75 18             	pushl  0x18(%ebp)
  80023b:	ff d7                	call   *%edi
  80023d:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800240:	83 eb 01             	sub    $0x1,%ebx
  800243:	85 db                	test   %ebx,%ebx
  800245:	7f ed                	jg     800234 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800247:	83 ec 08             	sub    $0x8,%esp
  80024a:	56                   	push   %esi
  80024b:	83 ec 04             	sub    $0x4,%esp
  80024e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800251:	ff 75 e0             	pushl  -0x20(%ebp)
  800254:	ff 75 dc             	pushl  -0x24(%ebp)
  800257:	ff 75 d8             	pushl  -0x28(%ebp)
  80025a:	e8 91 10 00 00       	call   8012f0 <__umoddi3>
  80025f:	83 c4 14             	add    $0x14,%esp
  800262:	0f be 80 e0 14 80 00 	movsbl 0x8014e0(%eax),%eax
  800269:	50                   	push   %eax
  80026a:	ff d7                	call   *%edi
}
  80026c:	83 c4 10             	add    $0x10,%esp
  80026f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800272:	5b                   	pop    %ebx
  800273:	5e                   	pop    %esi
  800274:	5f                   	pop    %edi
  800275:	5d                   	pop    %ebp
  800276:	c3                   	ret    

00800277 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800277:	f3 0f 1e fb          	endbr32 
  80027b:	55                   	push   %ebp
  80027c:	89 e5                	mov    %esp,%ebp
  80027e:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800281:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800285:	8b 10                	mov    (%eax),%edx
  800287:	3b 50 04             	cmp    0x4(%eax),%edx
  80028a:	73 0a                	jae    800296 <sprintputch+0x1f>
		*b->buf++ = ch;
  80028c:	8d 4a 01             	lea    0x1(%edx),%ecx
  80028f:	89 08                	mov    %ecx,(%eax)
  800291:	8b 45 08             	mov    0x8(%ebp),%eax
  800294:	88 02                	mov    %al,(%edx)
}
  800296:	5d                   	pop    %ebp
  800297:	c3                   	ret    

00800298 <printfmt>:
{
  800298:	f3 0f 1e fb          	endbr32 
  80029c:	55                   	push   %ebp
  80029d:	89 e5                	mov    %esp,%ebp
  80029f:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8002a2:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002a5:	50                   	push   %eax
  8002a6:	ff 75 10             	pushl  0x10(%ebp)
  8002a9:	ff 75 0c             	pushl  0xc(%ebp)
  8002ac:	ff 75 08             	pushl  0x8(%ebp)
  8002af:	e8 05 00 00 00       	call   8002b9 <vprintfmt>
}
  8002b4:	83 c4 10             	add    $0x10,%esp
  8002b7:	c9                   	leave  
  8002b8:	c3                   	ret    

008002b9 <vprintfmt>:
{
  8002b9:	f3 0f 1e fb          	endbr32 
  8002bd:	55                   	push   %ebp
  8002be:	89 e5                	mov    %esp,%ebp
  8002c0:	57                   	push   %edi
  8002c1:	56                   	push   %esi
  8002c2:	53                   	push   %ebx
  8002c3:	83 ec 3c             	sub    $0x3c,%esp
  8002c6:	8b 75 08             	mov    0x8(%ebp),%esi
  8002c9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002cc:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002cf:	e9 cd 03 00 00       	jmp    8006a1 <vprintfmt+0x3e8>
		padc = ' ';
  8002d4:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  8002d8:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8002df:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8002e6:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8002ed:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8002f2:	8d 47 01             	lea    0x1(%edi),%eax
  8002f5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002f8:	0f b6 17             	movzbl (%edi),%edx
  8002fb:	8d 42 dd             	lea    -0x23(%edx),%eax
  8002fe:	3c 55                	cmp    $0x55,%al
  800300:	0f 87 1e 04 00 00    	ja     800724 <vprintfmt+0x46b>
  800306:	0f b6 c0             	movzbl %al,%eax
  800309:	3e ff 24 85 a0 15 80 	notrack jmp *0x8015a0(,%eax,4)
  800310:	00 
  800311:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800314:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800318:	eb d8                	jmp    8002f2 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  80031a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80031d:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  800321:	eb cf                	jmp    8002f2 <vprintfmt+0x39>
  800323:	0f b6 d2             	movzbl %dl,%edx
  800326:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800329:	b8 00 00 00 00       	mov    $0x0,%eax
  80032e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800331:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800334:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800338:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80033b:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80033e:	83 f9 09             	cmp    $0x9,%ecx
  800341:	77 55                	ja     800398 <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  800343:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800346:	eb e9                	jmp    800331 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  800348:	8b 45 14             	mov    0x14(%ebp),%eax
  80034b:	8b 00                	mov    (%eax),%eax
  80034d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800350:	8b 45 14             	mov    0x14(%ebp),%eax
  800353:	8d 40 04             	lea    0x4(%eax),%eax
  800356:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800359:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  80035c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800360:	79 90                	jns    8002f2 <vprintfmt+0x39>
				width = precision, precision = -1;
  800362:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800365:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800368:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80036f:	eb 81                	jmp    8002f2 <vprintfmt+0x39>
  800371:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800374:	85 c0                	test   %eax,%eax
  800376:	ba 00 00 00 00       	mov    $0x0,%edx
  80037b:	0f 49 d0             	cmovns %eax,%edx
  80037e:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800381:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800384:	e9 69 ff ff ff       	jmp    8002f2 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800389:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  80038c:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  800393:	e9 5a ff ff ff       	jmp    8002f2 <vprintfmt+0x39>
  800398:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80039b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80039e:	eb bc                	jmp    80035c <vprintfmt+0xa3>
			lflag++;
  8003a0:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8003a3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003a6:	e9 47 ff ff ff       	jmp    8002f2 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  8003ab:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ae:	8d 78 04             	lea    0x4(%eax),%edi
  8003b1:	83 ec 08             	sub    $0x8,%esp
  8003b4:	53                   	push   %ebx
  8003b5:	ff 30                	pushl  (%eax)
  8003b7:	ff d6                	call   *%esi
			break;
  8003b9:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8003bc:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8003bf:	e9 da 02 00 00       	jmp    80069e <vprintfmt+0x3e5>
			err = va_arg(ap, int);
  8003c4:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c7:	8d 78 04             	lea    0x4(%eax),%edi
  8003ca:	8b 00                	mov    (%eax),%eax
  8003cc:	99                   	cltd   
  8003cd:	31 d0                	xor    %edx,%eax
  8003cf:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003d1:	83 f8 08             	cmp    $0x8,%eax
  8003d4:	7f 23                	jg     8003f9 <vprintfmt+0x140>
  8003d6:	8b 14 85 00 17 80 00 	mov    0x801700(,%eax,4),%edx
  8003dd:	85 d2                	test   %edx,%edx
  8003df:	74 18                	je     8003f9 <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  8003e1:	52                   	push   %edx
  8003e2:	68 01 15 80 00       	push   $0x801501
  8003e7:	53                   	push   %ebx
  8003e8:	56                   	push   %esi
  8003e9:	e8 aa fe ff ff       	call   800298 <printfmt>
  8003ee:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003f1:	89 7d 14             	mov    %edi,0x14(%ebp)
  8003f4:	e9 a5 02 00 00       	jmp    80069e <vprintfmt+0x3e5>
				printfmt(putch, putdat, "error %d", err);
  8003f9:	50                   	push   %eax
  8003fa:	68 f8 14 80 00       	push   $0x8014f8
  8003ff:	53                   	push   %ebx
  800400:	56                   	push   %esi
  800401:	e8 92 fe ff ff       	call   800298 <printfmt>
  800406:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800409:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80040c:	e9 8d 02 00 00       	jmp    80069e <vprintfmt+0x3e5>
			if ((p = va_arg(ap, char *)) == NULL)
  800411:	8b 45 14             	mov    0x14(%ebp),%eax
  800414:	83 c0 04             	add    $0x4,%eax
  800417:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80041a:	8b 45 14             	mov    0x14(%ebp),%eax
  80041d:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  80041f:	85 d2                	test   %edx,%edx
  800421:	b8 f1 14 80 00       	mov    $0x8014f1,%eax
  800426:	0f 45 c2             	cmovne %edx,%eax
  800429:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  80042c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800430:	7e 06                	jle    800438 <vprintfmt+0x17f>
  800432:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  800436:	75 0d                	jne    800445 <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  800438:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80043b:	89 c7                	mov    %eax,%edi
  80043d:	03 45 e0             	add    -0x20(%ebp),%eax
  800440:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800443:	eb 55                	jmp    80049a <vprintfmt+0x1e1>
  800445:	83 ec 08             	sub    $0x8,%esp
  800448:	ff 75 d8             	pushl  -0x28(%ebp)
  80044b:	ff 75 cc             	pushl  -0x34(%ebp)
  80044e:	e8 85 03 00 00       	call   8007d8 <strnlen>
  800453:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800456:	29 c2                	sub    %eax,%edx
  800458:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  80045b:	83 c4 10             	add    $0x10,%esp
  80045e:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  800460:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  800464:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800467:	85 ff                	test   %edi,%edi
  800469:	7e 11                	jle    80047c <vprintfmt+0x1c3>
					putch(padc, putdat);
  80046b:	83 ec 08             	sub    $0x8,%esp
  80046e:	53                   	push   %ebx
  80046f:	ff 75 e0             	pushl  -0x20(%ebp)
  800472:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800474:	83 ef 01             	sub    $0x1,%edi
  800477:	83 c4 10             	add    $0x10,%esp
  80047a:	eb eb                	jmp    800467 <vprintfmt+0x1ae>
  80047c:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  80047f:	85 d2                	test   %edx,%edx
  800481:	b8 00 00 00 00       	mov    $0x0,%eax
  800486:	0f 49 c2             	cmovns %edx,%eax
  800489:	29 c2                	sub    %eax,%edx
  80048b:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80048e:	eb a8                	jmp    800438 <vprintfmt+0x17f>
					putch(ch, putdat);
  800490:	83 ec 08             	sub    $0x8,%esp
  800493:	53                   	push   %ebx
  800494:	52                   	push   %edx
  800495:	ff d6                	call   *%esi
  800497:	83 c4 10             	add    $0x10,%esp
  80049a:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80049d:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80049f:	83 c7 01             	add    $0x1,%edi
  8004a2:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004a6:	0f be d0             	movsbl %al,%edx
  8004a9:	85 d2                	test   %edx,%edx
  8004ab:	74 4b                	je     8004f8 <vprintfmt+0x23f>
  8004ad:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004b1:	78 06                	js     8004b9 <vprintfmt+0x200>
  8004b3:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8004b7:	78 1e                	js     8004d7 <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
  8004b9:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8004bd:	74 d1                	je     800490 <vprintfmt+0x1d7>
  8004bf:	0f be c0             	movsbl %al,%eax
  8004c2:	83 e8 20             	sub    $0x20,%eax
  8004c5:	83 f8 5e             	cmp    $0x5e,%eax
  8004c8:	76 c6                	jbe    800490 <vprintfmt+0x1d7>
					putch('?', putdat);
  8004ca:	83 ec 08             	sub    $0x8,%esp
  8004cd:	53                   	push   %ebx
  8004ce:	6a 3f                	push   $0x3f
  8004d0:	ff d6                	call   *%esi
  8004d2:	83 c4 10             	add    $0x10,%esp
  8004d5:	eb c3                	jmp    80049a <vprintfmt+0x1e1>
  8004d7:	89 cf                	mov    %ecx,%edi
  8004d9:	eb 0e                	jmp    8004e9 <vprintfmt+0x230>
				putch(' ', putdat);
  8004db:	83 ec 08             	sub    $0x8,%esp
  8004de:	53                   	push   %ebx
  8004df:	6a 20                	push   $0x20
  8004e1:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8004e3:	83 ef 01             	sub    $0x1,%edi
  8004e6:	83 c4 10             	add    $0x10,%esp
  8004e9:	85 ff                	test   %edi,%edi
  8004eb:	7f ee                	jg     8004db <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  8004ed:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8004f0:	89 45 14             	mov    %eax,0x14(%ebp)
  8004f3:	e9 a6 01 00 00       	jmp    80069e <vprintfmt+0x3e5>
  8004f8:	89 cf                	mov    %ecx,%edi
  8004fa:	eb ed                	jmp    8004e9 <vprintfmt+0x230>
	if (lflag >= 2)
  8004fc:	83 f9 01             	cmp    $0x1,%ecx
  8004ff:	7f 1f                	jg     800520 <vprintfmt+0x267>
	else if (lflag)
  800501:	85 c9                	test   %ecx,%ecx
  800503:	74 67                	je     80056c <vprintfmt+0x2b3>
		return va_arg(*ap, long);
  800505:	8b 45 14             	mov    0x14(%ebp),%eax
  800508:	8b 00                	mov    (%eax),%eax
  80050a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80050d:	89 c1                	mov    %eax,%ecx
  80050f:	c1 f9 1f             	sar    $0x1f,%ecx
  800512:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800515:	8b 45 14             	mov    0x14(%ebp),%eax
  800518:	8d 40 04             	lea    0x4(%eax),%eax
  80051b:	89 45 14             	mov    %eax,0x14(%ebp)
  80051e:	eb 17                	jmp    800537 <vprintfmt+0x27e>
		return va_arg(*ap, long long);
  800520:	8b 45 14             	mov    0x14(%ebp),%eax
  800523:	8b 50 04             	mov    0x4(%eax),%edx
  800526:	8b 00                	mov    (%eax),%eax
  800528:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80052b:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80052e:	8b 45 14             	mov    0x14(%ebp),%eax
  800531:	8d 40 08             	lea    0x8(%eax),%eax
  800534:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800537:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80053a:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  80053d:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  800542:	85 c9                	test   %ecx,%ecx
  800544:	0f 89 3a 01 00 00    	jns    800684 <vprintfmt+0x3cb>
				putch('-', putdat);
  80054a:	83 ec 08             	sub    $0x8,%esp
  80054d:	53                   	push   %ebx
  80054e:	6a 2d                	push   $0x2d
  800550:	ff d6                	call   *%esi
				num = -(long long) num;
  800552:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800555:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800558:	f7 da                	neg    %edx
  80055a:	83 d1 00             	adc    $0x0,%ecx
  80055d:	f7 d9                	neg    %ecx
  80055f:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800562:	b8 0a 00 00 00       	mov    $0xa,%eax
  800567:	e9 18 01 00 00       	jmp    800684 <vprintfmt+0x3cb>
		return va_arg(*ap, int);
  80056c:	8b 45 14             	mov    0x14(%ebp),%eax
  80056f:	8b 00                	mov    (%eax),%eax
  800571:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800574:	89 c1                	mov    %eax,%ecx
  800576:	c1 f9 1f             	sar    $0x1f,%ecx
  800579:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80057c:	8b 45 14             	mov    0x14(%ebp),%eax
  80057f:	8d 40 04             	lea    0x4(%eax),%eax
  800582:	89 45 14             	mov    %eax,0x14(%ebp)
  800585:	eb b0                	jmp    800537 <vprintfmt+0x27e>
	if (lflag >= 2)
  800587:	83 f9 01             	cmp    $0x1,%ecx
  80058a:	7f 1e                	jg     8005aa <vprintfmt+0x2f1>
	else if (lflag)
  80058c:	85 c9                	test   %ecx,%ecx
  80058e:	74 32                	je     8005c2 <vprintfmt+0x309>
		return va_arg(*ap, unsigned long);
  800590:	8b 45 14             	mov    0x14(%ebp),%eax
  800593:	8b 10                	mov    (%eax),%edx
  800595:	b9 00 00 00 00       	mov    $0x0,%ecx
  80059a:	8d 40 04             	lea    0x4(%eax),%eax
  80059d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005a0:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  8005a5:	e9 da 00 00 00       	jmp    800684 <vprintfmt+0x3cb>
		return va_arg(*ap, unsigned long long);
  8005aa:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ad:	8b 10                	mov    (%eax),%edx
  8005af:	8b 48 04             	mov    0x4(%eax),%ecx
  8005b2:	8d 40 08             	lea    0x8(%eax),%eax
  8005b5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005b8:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  8005bd:	e9 c2 00 00 00       	jmp    800684 <vprintfmt+0x3cb>
		return va_arg(*ap, unsigned int);
  8005c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c5:	8b 10                	mov    (%eax),%edx
  8005c7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005cc:	8d 40 04             	lea    0x4(%eax),%eax
  8005cf:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005d2:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  8005d7:	e9 a8 00 00 00       	jmp    800684 <vprintfmt+0x3cb>
	if (lflag >= 2)
  8005dc:	83 f9 01             	cmp    $0x1,%ecx
  8005df:	7f 1b                	jg     8005fc <vprintfmt+0x343>
	else if (lflag)
  8005e1:	85 c9                	test   %ecx,%ecx
  8005e3:	74 5c                	je     800641 <vprintfmt+0x388>
		return va_arg(*ap, long);
  8005e5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e8:	8b 00                	mov    (%eax),%eax
  8005ea:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005ed:	99                   	cltd   
  8005ee:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f4:	8d 40 04             	lea    0x4(%eax),%eax
  8005f7:	89 45 14             	mov    %eax,0x14(%ebp)
  8005fa:	eb 17                	jmp    800613 <vprintfmt+0x35a>
		return va_arg(*ap, long long);
  8005fc:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ff:	8b 50 04             	mov    0x4(%eax),%edx
  800602:	8b 00                	mov    (%eax),%eax
  800604:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800607:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80060a:	8b 45 14             	mov    0x14(%ebp),%eax
  80060d:	8d 40 08             	lea    0x8(%eax),%eax
  800610:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800613:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800616:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 8;
  800619:	b8 08 00 00 00       	mov    $0x8,%eax
			if ((long long) num < 0) {
  80061e:	85 c9                	test   %ecx,%ecx
  800620:	79 62                	jns    800684 <vprintfmt+0x3cb>
				putch('-', putdat);
  800622:	83 ec 08             	sub    $0x8,%esp
  800625:	53                   	push   %ebx
  800626:	6a 2d                	push   $0x2d
  800628:	ff d6                	call   *%esi
				num = -(long long) num;
  80062a:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80062d:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800630:	f7 da                	neg    %edx
  800632:	83 d1 00             	adc    $0x0,%ecx
  800635:	f7 d9                	neg    %ecx
  800637:	83 c4 10             	add    $0x10,%esp
			base = 8;
  80063a:	b8 08 00 00 00       	mov    $0x8,%eax
  80063f:	eb 43                	jmp    800684 <vprintfmt+0x3cb>
		return va_arg(*ap, int);
  800641:	8b 45 14             	mov    0x14(%ebp),%eax
  800644:	8b 00                	mov    (%eax),%eax
  800646:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800649:	89 c1                	mov    %eax,%ecx
  80064b:	c1 f9 1f             	sar    $0x1f,%ecx
  80064e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800651:	8b 45 14             	mov    0x14(%ebp),%eax
  800654:	8d 40 04             	lea    0x4(%eax),%eax
  800657:	89 45 14             	mov    %eax,0x14(%ebp)
  80065a:	eb b7                	jmp    800613 <vprintfmt+0x35a>
			putch('0', putdat);
  80065c:	83 ec 08             	sub    $0x8,%esp
  80065f:	53                   	push   %ebx
  800660:	6a 30                	push   $0x30
  800662:	ff d6                	call   *%esi
			putch('x', putdat);
  800664:	83 c4 08             	add    $0x8,%esp
  800667:	53                   	push   %ebx
  800668:	6a 78                	push   $0x78
  80066a:	ff d6                	call   *%esi
			num = (unsigned long long)
  80066c:	8b 45 14             	mov    0x14(%ebp),%eax
  80066f:	8b 10                	mov    (%eax),%edx
  800671:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800676:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800679:	8d 40 04             	lea    0x4(%eax),%eax
  80067c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80067f:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  800684:	83 ec 0c             	sub    $0xc,%esp
  800687:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  80068b:	57                   	push   %edi
  80068c:	ff 75 e0             	pushl  -0x20(%ebp)
  80068f:	50                   	push   %eax
  800690:	51                   	push   %ecx
  800691:	52                   	push   %edx
  800692:	89 da                	mov    %ebx,%edx
  800694:	89 f0                	mov    %esi,%eax
  800696:	e8 33 fb ff ff       	call   8001ce <printnum>
			break;
  80069b:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  80069e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006a1:	83 c7 01             	add    $0x1,%edi
  8006a4:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8006a8:	83 f8 25             	cmp    $0x25,%eax
  8006ab:	0f 84 23 fc ff ff    	je     8002d4 <vprintfmt+0x1b>
			if (ch == '\0')
  8006b1:	85 c0                	test   %eax,%eax
  8006b3:	0f 84 8b 00 00 00    	je     800744 <vprintfmt+0x48b>
			putch(ch, putdat);
  8006b9:	83 ec 08             	sub    $0x8,%esp
  8006bc:	53                   	push   %ebx
  8006bd:	50                   	push   %eax
  8006be:	ff d6                	call   *%esi
  8006c0:	83 c4 10             	add    $0x10,%esp
  8006c3:	eb dc                	jmp    8006a1 <vprintfmt+0x3e8>
	if (lflag >= 2)
  8006c5:	83 f9 01             	cmp    $0x1,%ecx
  8006c8:	7f 1b                	jg     8006e5 <vprintfmt+0x42c>
	else if (lflag)
  8006ca:	85 c9                	test   %ecx,%ecx
  8006cc:	74 2c                	je     8006fa <vprintfmt+0x441>
		return va_arg(*ap, unsigned long);
  8006ce:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d1:	8b 10                	mov    (%eax),%edx
  8006d3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006d8:	8d 40 04             	lea    0x4(%eax),%eax
  8006db:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006de:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  8006e3:	eb 9f                	jmp    800684 <vprintfmt+0x3cb>
		return va_arg(*ap, unsigned long long);
  8006e5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e8:	8b 10                	mov    (%eax),%edx
  8006ea:	8b 48 04             	mov    0x4(%eax),%ecx
  8006ed:	8d 40 08             	lea    0x8(%eax),%eax
  8006f0:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006f3:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  8006f8:	eb 8a                	jmp    800684 <vprintfmt+0x3cb>
		return va_arg(*ap, unsigned int);
  8006fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8006fd:	8b 10                	mov    (%eax),%edx
  8006ff:	b9 00 00 00 00       	mov    $0x0,%ecx
  800704:	8d 40 04             	lea    0x4(%eax),%eax
  800707:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80070a:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  80070f:	e9 70 ff ff ff       	jmp    800684 <vprintfmt+0x3cb>
			putch(ch, putdat);
  800714:	83 ec 08             	sub    $0x8,%esp
  800717:	53                   	push   %ebx
  800718:	6a 25                	push   $0x25
  80071a:	ff d6                	call   *%esi
			break;
  80071c:	83 c4 10             	add    $0x10,%esp
  80071f:	e9 7a ff ff ff       	jmp    80069e <vprintfmt+0x3e5>
			putch('%', putdat);
  800724:	83 ec 08             	sub    $0x8,%esp
  800727:	53                   	push   %ebx
  800728:	6a 25                	push   $0x25
  80072a:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80072c:	83 c4 10             	add    $0x10,%esp
  80072f:	89 f8                	mov    %edi,%eax
  800731:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800735:	74 05                	je     80073c <vprintfmt+0x483>
  800737:	83 e8 01             	sub    $0x1,%eax
  80073a:	eb f5                	jmp    800731 <vprintfmt+0x478>
  80073c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80073f:	e9 5a ff ff ff       	jmp    80069e <vprintfmt+0x3e5>
}
  800744:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800747:	5b                   	pop    %ebx
  800748:	5e                   	pop    %esi
  800749:	5f                   	pop    %edi
  80074a:	5d                   	pop    %ebp
  80074b:	c3                   	ret    

0080074c <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80074c:	f3 0f 1e fb          	endbr32 
  800750:	55                   	push   %ebp
  800751:	89 e5                	mov    %esp,%ebp
  800753:	83 ec 18             	sub    $0x18,%esp
  800756:	8b 45 08             	mov    0x8(%ebp),%eax
  800759:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80075c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80075f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800763:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800766:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80076d:	85 c0                	test   %eax,%eax
  80076f:	74 26                	je     800797 <vsnprintf+0x4b>
  800771:	85 d2                	test   %edx,%edx
  800773:	7e 22                	jle    800797 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800775:	ff 75 14             	pushl  0x14(%ebp)
  800778:	ff 75 10             	pushl  0x10(%ebp)
  80077b:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80077e:	50                   	push   %eax
  80077f:	68 77 02 80 00       	push   $0x800277
  800784:	e8 30 fb ff ff       	call   8002b9 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800789:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80078c:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80078f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800792:	83 c4 10             	add    $0x10,%esp
}
  800795:	c9                   	leave  
  800796:	c3                   	ret    
		return -E_INVAL;
  800797:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80079c:	eb f7                	jmp    800795 <vsnprintf+0x49>

0080079e <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80079e:	f3 0f 1e fb          	endbr32 
  8007a2:	55                   	push   %ebp
  8007a3:	89 e5                	mov    %esp,%ebp
  8007a5:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007a8:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007ab:	50                   	push   %eax
  8007ac:	ff 75 10             	pushl  0x10(%ebp)
  8007af:	ff 75 0c             	pushl  0xc(%ebp)
  8007b2:	ff 75 08             	pushl  0x8(%ebp)
  8007b5:	e8 92 ff ff ff       	call   80074c <vsnprintf>
	va_end(ap);

	return rc;
}
  8007ba:	c9                   	leave  
  8007bb:	c3                   	ret    

008007bc <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007bc:	f3 0f 1e fb          	endbr32 
  8007c0:	55                   	push   %ebp
  8007c1:	89 e5                	mov    %esp,%ebp
  8007c3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007c6:	b8 00 00 00 00       	mov    $0x0,%eax
  8007cb:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007cf:	74 05                	je     8007d6 <strlen+0x1a>
		n++;
  8007d1:	83 c0 01             	add    $0x1,%eax
  8007d4:	eb f5                	jmp    8007cb <strlen+0xf>
	return n;
}
  8007d6:	5d                   	pop    %ebp
  8007d7:	c3                   	ret    

008007d8 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007d8:	f3 0f 1e fb          	endbr32 
  8007dc:	55                   	push   %ebp
  8007dd:	89 e5                	mov    %esp,%ebp
  8007df:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007e2:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007e5:	b8 00 00 00 00       	mov    $0x0,%eax
  8007ea:	39 d0                	cmp    %edx,%eax
  8007ec:	74 0d                	je     8007fb <strnlen+0x23>
  8007ee:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007f2:	74 05                	je     8007f9 <strnlen+0x21>
		n++;
  8007f4:	83 c0 01             	add    $0x1,%eax
  8007f7:	eb f1                	jmp    8007ea <strnlen+0x12>
  8007f9:	89 c2                	mov    %eax,%edx
	return n;
}
  8007fb:	89 d0                	mov    %edx,%eax
  8007fd:	5d                   	pop    %ebp
  8007fe:	c3                   	ret    

008007ff <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007ff:	f3 0f 1e fb          	endbr32 
  800803:	55                   	push   %ebp
  800804:	89 e5                	mov    %esp,%ebp
  800806:	53                   	push   %ebx
  800807:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80080a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80080d:	b8 00 00 00 00       	mov    $0x0,%eax
  800812:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800816:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800819:	83 c0 01             	add    $0x1,%eax
  80081c:	84 d2                	test   %dl,%dl
  80081e:	75 f2                	jne    800812 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  800820:	89 c8                	mov    %ecx,%eax
  800822:	5b                   	pop    %ebx
  800823:	5d                   	pop    %ebp
  800824:	c3                   	ret    

00800825 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800825:	f3 0f 1e fb          	endbr32 
  800829:	55                   	push   %ebp
  80082a:	89 e5                	mov    %esp,%ebp
  80082c:	53                   	push   %ebx
  80082d:	83 ec 10             	sub    $0x10,%esp
  800830:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800833:	53                   	push   %ebx
  800834:	e8 83 ff ff ff       	call   8007bc <strlen>
  800839:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  80083c:	ff 75 0c             	pushl  0xc(%ebp)
  80083f:	01 d8                	add    %ebx,%eax
  800841:	50                   	push   %eax
  800842:	e8 b8 ff ff ff       	call   8007ff <strcpy>
	return dst;
}
  800847:	89 d8                	mov    %ebx,%eax
  800849:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80084c:	c9                   	leave  
  80084d:	c3                   	ret    

0080084e <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80084e:	f3 0f 1e fb          	endbr32 
  800852:	55                   	push   %ebp
  800853:	89 e5                	mov    %esp,%ebp
  800855:	56                   	push   %esi
  800856:	53                   	push   %ebx
  800857:	8b 75 08             	mov    0x8(%ebp),%esi
  80085a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80085d:	89 f3                	mov    %esi,%ebx
  80085f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800862:	89 f0                	mov    %esi,%eax
  800864:	39 d8                	cmp    %ebx,%eax
  800866:	74 11                	je     800879 <strncpy+0x2b>
		*dst++ = *src;
  800868:	83 c0 01             	add    $0x1,%eax
  80086b:	0f b6 0a             	movzbl (%edx),%ecx
  80086e:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800871:	80 f9 01             	cmp    $0x1,%cl
  800874:	83 da ff             	sbb    $0xffffffff,%edx
  800877:	eb eb                	jmp    800864 <strncpy+0x16>
	}
	return ret;
}
  800879:	89 f0                	mov    %esi,%eax
  80087b:	5b                   	pop    %ebx
  80087c:	5e                   	pop    %esi
  80087d:	5d                   	pop    %ebp
  80087e:	c3                   	ret    

0080087f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80087f:	f3 0f 1e fb          	endbr32 
  800883:	55                   	push   %ebp
  800884:	89 e5                	mov    %esp,%ebp
  800886:	56                   	push   %esi
  800887:	53                   	push   %ebx
  800888:	8b 75 08             	mov    0x8(%ebp),%esi
  80088b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80088e:	8b 55 10             	mov    0x10(%ebp),%edx
  800891:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800893:	85 d2                	test   %edx,%edx
  800895:	74 21                	je     8008b8 <strlcpy+0x39>
  800897:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80089b:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  80089d:	39 c2                	cmp    %eax,%edx
  80089f:	74 14                	je     8008b5 <strlcpy+0x36>
  8008a1:	0f b6 19             	movzbl (%ecx),%ebx
  8008a4:	84 db                	test   %bl,%bl
  8008a6:	74 0b                	je     8008b3 <strlcpy+0x34>
			*dst++ = *src++;
  8008a8:	83 c1 01             	add    $0x1,%ecx
  8008ab:	83 c2 01             	add    $0x1,%edx
  8008ae:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008b1:	eb ea                	jmp    80089d <strlcpy+0x1e>
  8008b3:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  8008b5:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008b8:	29 f0                	sub    %esi,%eax
}
  8008ba:	5b                   	pop    %ebx
  8008bb:	5e                   	pop    %esi
  8008bc:	5d                   	pop    %ebp
  8008bd:	c3                   	ret    

008008be <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008be:	f3 0f 1e fb          	endbr32 
  8008c2:	55                   	push   %ebp
  8008c3:	89 e5                	mov    %esp,%ebp
  8008c5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008c8:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008cb:	0f b6 01             	movzbl (%ecx),%eax
  8008ce:	84 c0                	test   %al,%al
  8008d0:	74 0c                	je     8008de <strcmp+0x20>
  8008d2:	3a 02                	cmp    (%edx),%al
  8008d4:	75 08                	jne    8008de <strcmp+0x20>
		p++, q++;
  8008d6:	83 c1 01             	add    $0x1,%ecx
  8008d9:	83 c2 01             	add    $0x1,%edx
  8008dc:	eb ed                	jmp    8008cb <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008de:	0f b6 c0             	movzbl %al,%eax
  8008e1:	0f b6 12             	movzbl (%edx),%edx
  8008e4:	29 d0                	sub    %edx,%eax
}
  8008e6:	5d                   	pop    %ebp
  8008e7:	c3                   	ret    

008008e8 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008e8:	f3 0f 1e fb          	endbr32 
  8008ec:	55                   	push   %ebp
  8008ed:	89 e5                	mov    %esp,%ebp
  8008ef:	53                   	push   %ebx
  8008f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008f6:	89 c3                	mov    %eax,%ebx
  8008f8:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008fb:	eb 06                	jmp    800903 <strncmp+0x1b>
		n--, p++, q++;
  8008fd:	83 c0 01             	add    $0x1,%eax
  800900:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800903:	39 d8                	cmp    %ebx,%eax
  800905:	74 16                	je     80091d <strncmp+0x35>
  800907:	0f b6 08             	movzbl (%eax),%ecx
  80090a:	84 c9                	test   %cl,%cl
  80090c:	74 04                	je     800912 <strncmp+0x2a>
  80090e:	3a 0a                	cmp    (%edx),%cl
  800910:	74 eb                	je     8008fd <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800912:	0f b6 00             	movzbl (%eax),%eax
  800915:	0f b6 12             	movzbl (%edx),%edx
  800918:	29 d0                	sub    %edx,%eax
}
  80091a:	5b                   	pop    %ebx
  80091b:	5d                   	pop    %ebp
  80091c:	c3                   	ret    
		return 0;
  80091d:	b8 00 00 00 00       	mov    $0x0,%eax
  800922:	eb f6                	jmp    80091a <strncmp+0x32>

00800924 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800924:	f3 0f 1e fb          	endbr32 
  800928:	55                   	push   %ebp
  800929:	89 e5                	mov    %esp,%ebp
  80092b:	8b 45 08             	mov    0x8(%ebp),%eax
  80092e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800932:	0f b6 10             	movzbl (%eax),%edx
  800935:	84 d2                	test   %dl,%dl
  800937:	74 09                	je     800942 <strchr+0x1e>
		if (*s == c)
  800939:	38 ca                	cmp    %cl,%dl
  80093b:	74 0a                	je     800947 <strchr+0x23>
	for (; *s; s++)
  80093d:	83 c0 01             	add    $0x1,%eax
  800940:	eb f0                	jmp    800932 <strchr+0xe>
			return (char *) s;
	return 0;
  800942:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800947:	5d                   	pop    %ebp
  800948:	c3                   	ret    

00800949 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800949:	f3 0f 1e fb          	endbr32 
  80094d:	55                   	push   %ebp
  80094e:	89 e5                	mov    %esp,%ebp
  800950:	8b 45 08             	mov    0x8(%ebp),%eax
  800953:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800957:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80095a:	38 ca                	cmp    %cl,%dl
  80095c:	74 09                	je     800967 <strfind+0x1e>
  80095e:	84 d2                	test   %dl,%dl
  800960:	74 05                	je     800967 <strfind+0x1e>
	for (; *s; s++)
  800962:	83 c0 01             	add    $0x1,%eax
  800965:	eb f0                	jmp    800957 <strfind+0xe>
			break;
	return (char *) s;
}
  800967:	5d                   	pop    %ebp
  800968:	c3                   	ret    

00800969 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800969:	f3 0f 1e fb          	endbr32 
  80096d:	55                   	push   %ebp
  80096e:	89 e5                	mov    %esp,%ebp
  800970:	57                   	push   %edi
  800971:	56                   	push   %esi
  800972:	53                   	push   %ebx
  800973:	8b 7d 08             	mov    0x8(%ebp),%edi
  800976:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800979:	85 c9                	test   %ecx,%ecx
  80097b:	74 31                	je     8009ae <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80097d:	89 f8                	mov    %edi,%eax
  80097f:	09 c8                	or     %ecx,%eax
  800981:	a8 03                	test   $0x3,%al
  800983:	75 23                	jne    8009a8 <memset+0x3f>
		c &= 0xFF;
  800985:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800989:	89 d3                	mov    %edx,%ebx
  80098b:	c1 e3 08             	shl    $0x8,%ebx
  80098e:	89 d0                	mov    %edx,%eax
  800990:	c1 e0 18             	shl    $0x18,%eax
  800993:	89 d6                	mov    %edx,%esi
  800995:	c1 e6 10             	shl    $0x10,%esi
  800998:	09 f0                	or     %esi,%eax
  80099a:	09 c2                	or     %eax,%edx
  80099c:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80099e:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  8009a1:	89 d0                	mov    %edx,%eax
  8009a3:	fc                   	cld    
  8009a4:	f3 ab                	rep stos %eax,%es:(%edi)
  8009a6:	eb 06                	jmp    8009ae <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009a8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009ab:	fc                   	cld    
  8009ac:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009ae:	89 f8                	mov    %edi,%eax
  8009b0:	5b                   	pop    %ebx
  8009b1:	5e                   	pop    %esi
  8009b2:	5f                   	pop    %edi
  8009b3:	5d                   	pop    %ebp
  8009b4:	c3                   	ret    

008009b5 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009b5:	f3 0f 1e fb          	endbr32 
  8009b9:	55                   	push   %ebp
  8009ba:	89 e5                	mov    %esp,%ebp
  8009bc:	57                   	push   %edi
  8009bd:	56                   	push   %esi
  8009be:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c1:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009c4:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009c7:	39 c6                	cmp    %eax,%esi
  8009c9:	73 32                	jae    8009fd <memmove+0x48>
  8009cb:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009ce:	39 c2                	cmp    %eax,%edx
  8009d0:	76 2b                	jbe    8009fd <memmove+0x48>
		s += n;
		d += n;
  8009d2:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009d5:	89 fe                	mov    %edi,%esi
  8009d7:	09 ce                	or     %ecx,%esi
  8009d9:	09 d6                	or     %edx,%esi
  8009db:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009e1:	75 0e                	jne    8009f1 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009e3:	83 ef 04             	sub    $0x4,%edi
  8009e6:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009e9:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8009ec:	fd                   	std    
  8009ed:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009ef:	eb 09                	jmp    8009fa <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009f1:	83 ef 01             	sub    $0x1,%edi
  8009f4:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8009f7:	fd                   	std    
  8009f8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009fa:	fc                   	cld    
  8009fb:	eb 1a                	jmp    800a17 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009fd:	89 c2                	mov    %eax,%edx
  8009ff:	09 ca                	or     %ecx,%edx
  800a01:	09 f2                	or     %esi,%edx
  800a03:	f6 c2 03             	test   $0x3,%dl
  800a06:	75 0a                	jne    800a12 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a08:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800a0b:	89 c7                	mov    %eax,%edi
  800a0d:	fc                   	cld    
  800a0e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a10:	eb 05                	jmp    800a17 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800a12:	89 c7                	mov    %eax,%edi
  800a14:	fc                   	cld    
  800a15:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a17:	5e                   	pop    %esi
  800a18:	5f                   	pop    %edi
  800a19:	5d                   	pop    %ebp
  800a1a:	c3                   	ret    

00800a1b <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a1b:	f3 0f 1e fb          	endbr32 
  800a1f:	55                   	push   %ebp
  800a20:	89 e5                	mov    %esp,%ebp
  800a22:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a25:	ff 75 10             	pushl  0x10(%ebp)
  800a28:	ff 75 0c             	pushl  0xc(%ebp)
  800a2b:	ff 75 08             	pushl  0x8(%ebp)
  800a2e:	e8 82 ff ff ff       	call   8009b5 <memmove>
}
  800a33:	c9                   	leave  
  800a34:	c3                   	ret    

00800a35 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a35:	f3 0f 1e fb          	endbr32 
  800a39:	55                   	push   %ebp
  800a3a:	89 e5                	mov    %esp,%ebp
  800a3c:	56                   	push   %esi
  800a3d:	53                   	push   %ebx
  800a3e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a41:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a44:	89 c6                	mov    %eax,%esi
  800a46:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a49:	39 f0                	cmp    %esi,%eax
  800a4b:	74 1c                	je     800a69 <memcmp+0x34>
		if (*s1 != *s2)
  800a4d:	0f b6 08             	movzbl (%eax),%ecx
  800a50:	0f b6 1a             	movzbl (%edx),%ebx
  800a53:	38 d9                	cmp    %bl,%cl
  800a55:	75 08                	jne    800a5f <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800a57:	83 c0 01             	add    $0x1,%eax
  800a5a:	83 c2 01             	add    $0x1,%edx
  800a5d:	eb ea                	jmp    800a49 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800a5f:	0f b6 c1             	movzbl %cl,%eax
  800a62:	0f b6 db             	movzbl %bl,%ebx
  800a65:	29 d8                	sub    %ebx,%eax
  800a67:	eb 05                	jmp    800a6e <memcmp+0x39>
	}

	return 0;
  800a69:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a6e:	5b                   	pop    %ebx
  800a6f:	5e                   	pop    %esi
  800a70:	5d                   	pop    %ebp
  800a71:	c3                   	ret    

00800a72 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a72:	f3 0f 1e fb          	endbr32 
  800a76:	55                   	push   %ebp
  800a77:	89 e5                	mov    %esp,%ebp
  800a79:	8b 45 08             	mov    0x8(%ebp),%eax
  800a7c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a7f:	89 c2                	mov    %eax,%edx
  800a81:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a84:	39 d0                	cmp    %edx,%eax
  800a86:	73 09                	jae    800a91 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a88:	38 08                	cmp    %cl,(%eax)
  800a8a:	74 05                	je     800a91 <memfind+0x1f>
	for (; s < ends; s++)
  800a8c:	83 c0 01             	add    $0x1,%eax
  800a8f:	eb f3                	jmp    800a84 <memfind+0x12>
			break;
	return (void *) s;
}
  800a91:	5d                   	pop    %ebp
  800a92:	c3                   	ret    

00800a93 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a93:	f3 0f 1e fb          	endbr32 
  800a97:	55                   	push   %ebp
  800a98:	89 e5                	mov    %esp,%ebp
  800a9a:	57                   	push   %edi
  800a9b:	56                   	push   %esi
  800a9c:	53                   	push   %ebx
  800a9d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800aa0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800aa3:	eb 03                	jmp    800aa8 <strtol+0x15>
		s++;
  800aa5:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800aa8:	0f b6 01             	movzbl (%ecx),%eax
  800aab:	3c 20                	cmp    $0x20,%al
  800aad:	74 f6                	je     800aa5 <strtol+0x12>
  800aaf:	3c 09                	cmp    $0x9,%al
  800ab1:	74 f2                	je     800aa5 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800ab3:	3c 2b                	cmp    $0x2b,%al
  800ab5:	74 2a                	je     800ae1 <strtol+0x4e>
	int neg = 0;
  800ab7:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800abc:	3c 2d                	cmp    $0x2d,%al
  800abe:	74 2b                	je     800aeb <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ac0:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800ac6:	75 0f                	jne    800ad7 <strtol+0x44>
  800ac8:	80 39 30             	cmpb   $0x30,(%ecx)
  800acb:	74 28                	je     800af5 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800acd:	85 db                	test   %ebx,%ebx
  800acf:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ad4:	0f 44 d8             	cmove  %eax,%ebx
  800ad7:	b8 00 00 00 00       	mov    $0x0,%eax
  800adc:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800adf:	eb 46                	jmp    800b27 <strtol+0x94>
		s++;
  800ae1:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800ae4:	bf 00 00 00 00       	mov    $0x0,%edi
  800ae9:	eb d5                	jmp    800ac0 <strtol+0x2d>
		s++, neg = 1;
  800aeb:	83 c1 01             	add    $0x1,%ecx
  800aee:	bf 01 00 00 00       	mov    $0x1,%edi
  800af3:	eb cb                	jmp    800ac0 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800af5:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800af9:	74 0e                	je     800b09 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800afb:	85 db                	test   %ebx,%ebx
  800afd:	75 d8                	jne    800ad7 <strtol+0x44>
		s++, base = 8;
  800aff:	83 c1 01             	add    $0x1,%ecx
  800b02:	bb 08 00 00 00       	mov    $0x8,%ebx
  800b07:	eb ce                	jmp    800ad7 <strtol+0x44>
		s += 2, base = 16;
  800b09:	83 c1 02             	add    $0x2,%ecx
  800b0c:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b11:	eb c4                	jmp    800ad7 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800b13:	0f be d2             	movsbl %dl,%edx
  800b16:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b19:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b1c:	7d 3a                	jge    800b58 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800b1e:	83 c1 01             	add    $0x1,%ecx
  800b21:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b25:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800b27:	0f b6 11             	movzbl (%ecx),%edx
  800b2a:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b2d:	89 f3                	mov    %esi,%ebx
  800b2f:	80 fb 09             	cmp    $0x9,%bl
  800b32:	76 df                	jbe    800b13 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800b34:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b37:	89 f3                	mov    %esi,%ebx
  800b39:	80 fb 19             	cmp    $0x19,%bl
  800b3c:	77 08                	ja     800b46 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800b3e:	0f be d2             	movsbl %dl,%edx
  800b41:	83 ea 57             	sub    $0x57,%edx
  800b44:	eb d3                	jmp    800b19 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800b46:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b49:	89 f3                	mov    %esi,%ebx
  800b4b:	80 fb 19             	cmp    $0x19,%bl
  800b4e:	77 08                	ja     800b58 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800b50:	0f be d2             	movsbl %dl,%edx
  800b53:	83 ea 37             	sub    $0x37,%edx
  800b56:	eb c1                	jmp    800b19 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800b58:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b5c:	74 05                	je     800b63 <strtol+0xd0>
		*endptr = (char *) s;
  800b5e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b61:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800b63:	89 c2                	mov    %eax,%edx
  800b65:	f7 da                	neg    %edx
  800b67:	85 ff                	test   %edi,%edi
  800b69:	0f 45 c2             	cmovne %edx,%eax
}
  800b6c:	5b                   	pop    %ebx
  800b6d:	5e                   	pop    %esi
  800b6e:	5f                   	pop    %edi
  800b6f:	5d                   	pop    %ebp
  800b70:	c3                   	ret    

00800b71 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b71:	f3 0f 1e fb          	endbr32 
  800b75:	55                   	push   %ebp
  800b76:	89 e5                	mov    %esp,%ebp
  800b78:	57                   	push   %edi
  800b79:	56                   	push   %esi
  800b7a:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b7b:	b8 00 00 00 00       	mov    $0x0,%eax
  800b80:	8b 55 08             	mov    0x8(%ebp),%edx
  800b83:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b86:	89 c3                	mov    %eax,%ebx
  800b88:	89 c7                	mov    %eax,%edi
  800b8a:	89 c6                	mov    %eax,%esi
  800b8c:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b8e:	5b                   	pop    %ebx
  800b8f:	5e                   	pop    %esi
  800b90:	5f                   	pop    %edi
  800b91:	5d                   	pop    %ebp
  800b92:	c3                   	ret    

00800b93 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b93:	f3 0f 1e fb          	endbr32 
  800b97:	55                   	push   %ebp
  800b98:	89 e5                	mov    %esp,%ebp
  800b9a:	57                   	push   %edi
  800b9b:	56                   	push   %esi
  800b9c:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b9d:	ba 00 00 00 00       	mov    $0x0,%edx
  800ba2:	b8 01 00 00 00       	mov    $0x1,%eax
  800ba7:	89 d1                	mov    %edx,%ecx
  800ba9:	89 d3                	mov    %edx,%ebx
  800bab:	89 d7                	mov    %edx,%edi
  800bad:	89 d6                	mov    %edx,%esi
  800baf:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bb1:	5b                   	pop    %ebx
  800bb2:	5e                   	pop    %esi
  800bb3:	5f                   	pop    %edi
  800bb4:	5d                   	pop    %ebp
  800bb5:	c3                   	ret    

00800bb6 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bb6:	f3 0f 1e fb          	endbr32 
  800bba:	55                   	push   %ebp
  800bbb:	89 e5                	mov    %esp,%ebp
  800bbd:	57                   	push   %edi
  800bbe:	56                   	push   %esi
  800bbf:	53                   	push   %ebx
  800bc0:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800bc3:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bc8:	8b 55 08             	mov    0x8(%ebp),%edx
  800bcb:	b8 03 00 00 00       	mov    $0x3,%eax
  800bd0:	89 cb                	mov    %ecx,%ebx
  800bd2:	89 cf                	mov    %ecx,%edi
  800bd4:	89 ce                	mov    %ecx,%esi
  800bd6:	cd 30                	int    $0x30
	if(check && ret > 0)
  800bd8:	85 c0                	test   %eax,%eax
  800bda:	7f 08                	jg     800be4 <sys_env_destroy+0x2e>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bdc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bdf:	5b                   	pop    %ebx
  800be0:	5e                   	pop    %esi
  800be1:	5f                   	pop    %edi
  800be2:	5d                   	pop    %ebp
  800be3:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800be4:	83 ec 0c             	sub    $0xc,%esp
  800be7:	50                   	push   %eax
  800be8:	6a 03                	push   $0x3
  800bea:	68 24 17 80 00       	push   $0x801724
  800bef:	6a 23                	push   $0x23
  800bf1:	68 41 17 80 00       	push   $0x801741
  800bf6:	e8 0d 05 00 00       	call   801108 <_panic>

00800bfb <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bfb:	f3 0f 1e fb          	endbr32 
  800bff:	55                   	push   %ebp
  800c00:	89 e5                	mov    %esp,%ebp
  800c02:	57                   	push   %edi
  800c03:	56                   	push   %esi
  800c04:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c05:	ba 00 00 00 00       	mov    $0x0,%edx
  800c0a:	b8 02 00 00 00       	mov    $0x2,%eax
  800c0f:	89 d1                	mov    %edx,%ecx
  800c11:	89 d3                	mov    %edx,%ebx
  800c13:	89 d7                	mov    %edx,%edi
  800c15:	89 d6                	mov    %edx,%esi
  800c17:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c19:	5b                   	pop    %ebx
  800c1a:	5e                   	pop    %esi
  800c1b:	5f                   	pop    %edi
  800c1c:	5d                   	pop    %ebp
  800c1d:	c3                   	ret    

00800c1e <sys_yield>:

void
sys_yield(void)
{
  800c1e:	f3 0f 1e fb          	endbr32 
  800c22:	55                   	push   %ebp
  800c23:	89 e5                	mov    %esp,%ebp
  800c25:	57                   	push   %edi
  800c26:	56                   	push   %esi
  800c27:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c28:	ba 00 00 00 00       	mov    $0x0,%edx
  800c2d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c32:	89 d1                	mov    %edx,%ecx
  800c34:	89 d3                	mov    %edx,%ebx
  800c36:	89 d7                	mov    %edx,%edi
  800c38:	89 d6                	mov    %edx,%esi
  800c3a:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c3c:	5b                   	pop    %ebx
  800c3d:	5e                   	pop    %esi
  800c3e:	5f                   	pop    %edi
  800c3f:	5d                   	pop    %ebp
  800c40:	c3                   	ret    

00800c41 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c41:	f3 0f 1e fb          	endbr32 
  800c45:	55                   	push   %ebp
  800c46:	89 e5                	mov    %esp,%ebp
  800c48:	57                   	push   %edi
  800c49:	56                   	push   %esi
  800c4a:	53                   	push   %ebx
  800c4b:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c4e:	be 00 00 00 00       	mov    $0x0,%esi
  800c53:	8b 55 08             	mov    0x8(%ebp),%edx
  800c56:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c59:	b8 04 00 00 00       	mov    $0x4,%eax
  800c5e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c61:	89 f7                	mov    %esi,%edi
  800c63:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c65:	85 c0                	test   %eax,%eax
  800c67:	7f 08                	jg     800c71 <sys_page_alloc+0x30>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c69:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c6c:	5b                   	pop    %ebx
  800c6d:	5e                   	pop    %esi
  800c6e:	5f                   	pop    %edi
  800c6f:	5d                   	pop    %ebp
  800c70:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c71:	83 ec 0c             	sub    $0xc,%esp
  800c74:	50                   	push   %eax
  800c75:	6a 04                	push   $0x4
  800c77:	68 24 17 80 00       	push   $0x801724
  800c7c:	6a 23                	push   $0x23
  800c7e:	68 41 17 80 00       	push   $0x801741
  800c83:	e8 80 04 00 00       	call   801108 <_panic>

00800c88 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c88:	f3 0f 1e fb          	endbr32 
  800c8c:	55                   	push   %ebp
  800c8d:	89 e5                	mov    %esp,%ebp
  800c8f:	57                   	push   %edi
  800c90:	56                   	push   %esi
  800c91:	53                   	push   %ebx
  800c92:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c95:	8b 55 08             	mov    0x8(%ebp),%edx
  800c98:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c9b:	b8 05 00 00 00       	mov    $0x5,%eax
  800ca0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ca3:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ca6:	8b 75 18             	mov    0x18(%ebp),%esi
  800ca9:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cab:	85 c0                	test   %eax,%eax
  800cad:	7f 08                	jg     800cb7 <sys_page_map+0x2f>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800caf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cb2:	5b                   	pop    %ebx
  800cb3:	5e                   	pop    %esi
  800cb4:	5f                   	pop    %edi
  800cb5:	5d                   	pop    %ebp
  800cb6:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cb7:	83 ec 0c             	sub    $0xc,%esp
  800cba:	50                   	push   %eax
  800cbb:	6a 05                	push   $0x5
  800cbd:	68 24 17 80 00       	push   $0x801724
  800cc2:	6a 23                	push   $0x23
  800cc4:	68 41 17 80 00       	push   $0x801741
  800cc9:	e8 3a 04 00 00       	call   801108 <_panic>

00800cce <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800cce:	f3 0f 1e fb          	endbr32 
  800cd2:	55                   	push   %ebp
  800cd3:	89 e5                	mov    %esp,%ebp
  800cd5:	57                   	push   %edi
  800cd6:	56                   	push   %esi
  800cd7:	53                   	push   %ebx
  800cd8:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cdb:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ce0:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce6:	b8 06 00 00 00       	mov    $0x6,%eax
  800ceb:	89 df                	mov    %ebx,%edi
  800ced:	89 de                	mov    %ebx,%esi
  800cef:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cf1:	85 c0                	test   %eax,%eax
  800cf3:	7f 08                	jg     800cfd <sys_page_unmap+0x2f>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cf5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cf8:	5b                   	pop    %ebx
  800cf9:	5e                   	pop    %esi
  800cfa:	5f                   	pop    %edi
  800cfb:	5d                   	pop    %ebp
  800cfc:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cfd:	83 ec 0c             	sub    $0xc,%esp
  800d00:	50                   	push   %eax
  800d01:	6a 06                	push   $0x6
  800d03:	68 24 17 80 00       	push   $0x801724
  800d08:	6a 23                	push   $0x23
  800d0a:	68 41 17 80 00       	push   $0x801741
  800d0f:	e8 f4 03 00 00       	call   801108 <_panic>

00800d14 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d14:	f3 0f 1e fb          	endbr32 
  800d18:	55                   	push   %ebp
  800d19:	89 e5                	mov    %esp,%ebp
  800d1b:	57                   	push   %edi
  800d1c:	56                   	push   %esi
  800d1d:	53                   	push   %ebx
  800d1e:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d21:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d26:	8b 55 08             	mov    0x8(%ebp),%edx
  800d29:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d2c:	b8 08 00 00 00       	mov    $0x8,%eax
  800d31:	89 df                	mov    %ebx,%edi
  800d33:	89 de                	mov    %ebx,%esi
  800d35:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d37:	85 c0                	test   %eax,%eax
  800d39:	7f 08                	jg     800d43 <sys_env_set_status+0x2f>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d3b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d3e:	5b                   	pop    %ebx
  800d3f:	5e                   	pop    %esi
  800d40:	5f                   	pop    %edi
  800d41:	5d                   	pop    %ebp
  800d42:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d43:	83 ec 0c             	sub    $0xc,%esp
  800d46:	50                   	push   %eax
  800d47:	6a 08                	push   $0x8
  800d49:	68 24 17 80 00       	push   $0x801724
  800d4e:	6a 23                	push   $0x23
  800d50:	68 41 17 80 00       	push   $0x801741
  800d55:	e8 ae 03 00 00       	call   801108 <_panic>

00800d5a <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d5a:	f3 0f 1e fb          	endbr32 
  800d5e:	55                   	push   %ebp
  800d5f:	89 e5                	mov    %esp,%ebp
  800d61:	57                   	push   %edi
  800d62:	56                   	push   %esi
  800d63:	53                   	push   %ebx
  800d64:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d67:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d6c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d6f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d72:	b8 09 00 00 00       	mov    $0x9,%eax
  800d77:	89 df                	mov    %ebx,%edi
  800d79:	89 de                	mov    %ebx,%esi
  800d7b:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d7d:	85 c0                	test   %eax,%eax
  800d7f:	7f 08                	jg     800d89 <sys_env_set_pgfault_upcall+0x2f>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d81:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d84:	5b                   	pop    %ebx
  800d85:	5e                   	pop    %esi
  800d86:	5f                   	pop    %edi
  800d87:	5d                   	pop    %ebp
  800d88:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d89:	83 ec 0c             	sub    $0xc,%esp
  800d8c:	50                   	push   %eax
  800d8d:	6a 09                	push   $0x9
  800d8f:	68 24 17 80 00       	push   $0x801724
  800d94:	6a 23                	push   $0x23
  800d96:	68 41 17 80 00       	push   $0x801741
  800d9b:	e8 68 03 00 00       	call   801108 <_panic>

00800da0 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800da0:	f3 0f 1e fb          	endbr32 
  800da4:	55                   	push   %ebp
  800da5:	89 e5                	mov    %esp,%ebp
  800da7:	57                   	push   %edi
  800da8:	56                   	push   %esi
  800da9:	53                   	push   %ebx
	asm volatile("int %1\n"
  800daa:	8b 55 08             	mov    0x8(%ebp),%edx
  800dad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db0:	b8 0b 00 00 00       	mov    $0xb,%eax
  800db5:	be 00 00 00 00       	mov    $0x0,%esi
  800dba:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dbd:	8b 7d 14             	mov    0x14(%ebp),%edi
  800dc0:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800dc2:	5b                   	pop    %ebx
  800dc3:	5e                   	pop    %esi
  800dc4:	5f                   	pop    %edi
  800dc5:	5d                   	pop    %ebp
  800dc6:	c3                   	ret    

00800dc7 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800dc7:	f3 0f 1e fb          	endbr32 
  800dcb:	55                   	push   %ebp
  800dcc:	89 e5                	mov    %esp,%ebp
  800dce:	57                   	push   %edi
  800dcf:	56                   	push   %esi
  800dd0:	53                   	push   %ebx
  800dd1:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800dd4:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dd9:	8b 55 08             	mov    0x8(%ebp),%edx
  800ddc:	b8 0c 00 00 00       	mov    $0xc,%eax
  800de1:	89 cb                	mov    %ecx,%ebx
  800de3:	89 cf                	mov    %ecx,%edi
  800de5:	89 ce                	mov    %ecx,%esi
  800de7:	cd 30                	int    $0x30
	if(check && ret > 0)
  800de9:	85 c0                	test   %eax,%eax
  800deb:	7f 08                	jg     800df5 <sys_ipc_recv+0x2e>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800ded:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800df0:	5b                   	pop    %ebx
  800df1:	5e                   	pop    %esi
  800df2:	5f                   	pop    %edi
  800df3:	5d                   	pop    %ebp
  800df4:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800df5:	83 ec 0c             	sub    $0xc,%esp
  800df8:	50                   	push   %eax
  800df9:	6a 0c                	push   $0xc
  800dfb:	68 24 17 80 00       	push   $0x801724
  800e00:	6a 23                	push   $0x23
  800e02:	68 41 17 80 00       	push   $0x801741
  800e07:	e8 fc 02 00 00       	call   801108 <_panic>

00800e0c <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e0c:	f3 0f 1e fb          	endbr32 
  800e10:	55                   	push   %ebp
  800e11:	89 e5                	mov    %esp,%ebp
  800e13:	53                   	push   %ebx
  800e14:	83 ec 04             	sub    $0x4,%esp
  800e17:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e1a:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if(!(err & FEC_WR)){
  800e1c:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e20:	74 74                	je     800e96 <pgfault+0x8a>
        panic("trapno is not FEC_WR");
    }
    if(!(uvpt[PGNUM(addr)] & PTE_COW)){
  800e22:	89 d8                	mov    %ebx,%eax
  800e24:	c1 e8 0c             	shr    $0xc,%eax
  800e27:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800e2e:	f6 c4 08             	test   $0x8,%ah
  800e31:	74 77                	je     800eaa <pgfault+0x9e>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	addr = ROUNDDOWN(addr, PGSIZE);
  800e33:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
    if ((r = sys_page_map(0, addr, 0, PFTEMP, PTE_U | PTE_P)) < 0)
  800e39:	83 ec 0c             	sub    $0xc,%esp
  800e3c:	6a 05                	push   $0x5
  800e3e:	68 00 f0 7f 00       	push   $0x7ff000
  800e43:	6a 00                	push   $0x0
  800e45:	53                   	push   %ebx
  800e46:	6a 00                	push   $0x0
  800e48:	e8 3b fe ff ff       	call   800c88 <sys_page_map>
  800e4d:	83 c4 20             	add    $0x20,%esp
  800e50:	85 c0                	test   %eax,%eax
  800e52:	78 6a                	js     800ebe <pgfault+0xb2>
        panic("sys_page_map: %e", r);
    if ((r = sys_page_alloc(0, addr, PTE_W | PTE_U | PTE_P)) < 0)
  800e54:	83 ec 04             	sub    $0x4,%esp
  800e57:	6a 07                	push   $0x7
  800e59:	53                   	push   %ebx
  800e5a:	6a 00                	push   $0x0
  800e5c:	e8 e0 fd ff ff       	call   800c41 <sys_page_alloc>
  800e61:	83 c4 10             	add    $0x10,%esp
  800e64:	85 c0                	test   %eax,%eax
  800e66:	78 68                	js     800ed0 <pgfault+0xc4>
        panic("sys_page_alloc: %e", r);
    memmove(addr, PFTEMP, PGSIZE);
  800e68:	83 ec 04             	sub    $0x4,%esp
  800e6b:	68 00 10 00 00       	push   $0x1000
  800e70:	68 00 f0 7f 00       	push   $0x7ff000
  800e75:	53                   	push   %ebx
  800e76:	e8 3a fb ff ff       	call   8009b5 <memmove>
    if ((r = sys_page_unmap(0, PFTEMP)) < 0)
  800e7b:	83 c4 08             	add    $0x8,%esp
  800e7e:	68 00 f0 7f 00       	push   $0x7ff000
  800e83:	6a 00                	push   $0x0
  800e85:	e8 44 fe ff ff       	call   800cce <sys_page_unmap>
  800e8a:	83 c4 10             	add    $0x10,%esp
  800e8d:	85 c0                	test   %eax,%eax
  800e8f:	78 51                	js     800ee2 <pgfault+0xd6>
        panic("sys_page_unmap: %e", r);

	//panic("pgfault not implemented");
}
  800e91:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e94:	c9                   	leave  
  800e95:	c3                   	ret    
        panic("trapno is not FEC_WR");
  800e96:	83 ec 04             	sub    $0x4,%esp
  800e99:	68 4f 17 80 00       	push   $0x80174f
  800e9e:	6a 1d                	push   $0x1d
  800ea0:	68 64 17 80 00       	push   $0x801764
  800ea5:	e8 5e 02 00 00       	call   801108 <_panic>
        panic("fault addr is not COW");
  800eaa:	83 ec 04             	sub    $0x4,%esp
  800ead:	68 6f 17 80 00       	push   $0x80176f
  800eb2:	6a 20                	push   $0x20
  800eb4:	68 64 17 80 00       	push   $0x801764
  800eb9:	e8 4a 02 00 00       	call   801108 <_panic>
        panic("sys_page_map: %e", r);
  800ebe:	50                   	push   %eax
  800ebf:	68 85 17 80 00       	push   $0x801785
  800ec4:	6a 2c                	push   $0x2c
  800ec6:	68 64 17 80 00       	push   $0x801764
  800ecb:	e8 38 02 00 00       	call   801108 <_panic>
        panic("sys_page_alloc: %e", r);
  800ed0:	50                   	push   %eax
  800ed1:	68 96 17 80 00       	push   $0x801796
  800ed6:	6a 2e                	push   $0x2e
  800ed8:	68 64 17 80 00       	push   $0x801764
  800edd:	e8 26 02 00 00       	call   801108 <_panic>
        panic("sys_page_unmap: %e", r);
  800ee2:	50                   	push   %eax
  800ee3:	68 a9 17 80 00       	push   $0x8017a9
  800ee8:	6a 31                	push   $0x31
  800eea:	68 64 17 80 00       	push   $0x801764
  800eef:	e8 14 02 00 00       	call   801108 <_panic>

00800ef4 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800ef4:	f3 0f 1e fb          	endbr32 
  800ef8:	55                   	push   %ebp
  800ef9:	89 e5                	mov    %esp,%ebp
  800efb:	57                   	push   %edi
  800efc:	56                   	push   %esi
  800efd:	53                   	push   %ebx
  800efe:	83 ec 28             	sub    $0x28,%esp
    extern void _pgfault_upcall(void);

	set_pgfault_handler(pgfault);
  800f01:	68 0c 0e 80 00       	push   $0x800e0c
  800f06:	e8 47 02 00 00       	call   801152 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800f0b:	b8 07 00 00 00       	mov    $0x7,%eax
  800f10:	cd 30                	int    $0x30
  800f12:	89 45 e4             	mov    %eax,-0x1c(%ebp)

    envid_t envid = sys_exofork();
    if (envid < 0)
  800f15:	83 c4 10             	add    $0x10,%esp
  800f18:	85 c0                	test   %eax,%eax
  800f1a:	78 2d                	js     800f49 <fork+0x55>
  800f1c:	89 c7                	mov    %eax,%edi
        thisenv = &envs[ENVX(sys_getenvid())];
        return 0;
    }

    // Parent
    for(uint32_t addr = 0; addr < USTACKTOP; addr += PGSIZE){
  800f1e:	bb 00 00 00 00       	mov    $0x0,%ebx
    if (envid == 0) {
  800f23:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800f27:	0f 85 92 00 00 00    	jne    800fbf <fork+0xcb>
        thisenv = &envs[ENVX(sys_getenvid())];
  800f2d:	e8 c9 fc ff ff       	call   800bfb <sys_getenvid>
  800f32:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f37:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800f3a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f3f:	a3 04 20 80 00       	mov    %eax,0x802004
        return 0;
  800f44:	e9 57 01 00 00       	jmp    8010a0 <fork+0x1ac>
        panic("sys_exofork Failed, envid: %e", envid);
  800f49:	50                   	push   %eax
  800f4a:	68 bc 17 80 00       	push   $0x8017bc
  800f4f:	6a 71                	push   $0x71
  800f51:	68 64 17 80 00       	push   $0x801764
  800f56:	e8 ad 01 00 00       	call   801108 <_panic>
        sys_page_map(0, addr, envid, addr, PTE_SYSCALL);
  800f5b:	83 ec 0c             	sub    $0xc,%esp
  800f5e:	68 07 0e 00 00       	push   $0xe07
  800f63:	56                   	push   %esi
  800f64:	57                   	push   %edi
  800f65:	56                   	push   %esi
  800f66:	6a 00                	push   $0x0
  800f68:	e8 1b fd ff ff       	call   800c88 <sys_page_map>
  800f6d:	83 c4 20             	add    $0x20,%esp
  800f70:	eb 3b                	jmp    800fad <fork+0xb9>
        if ((r = sys_page_map(0, addr, envid, addr, PTE_COW|PTE_U|PTE_P)) < 0)
  800f72:	83 ec 0c             	sub    $0xc,%esp
  800f75:	68 05 08 00 00       	push   $0x805
  800f7a:	56                   	push   %esi
  800f7b:	57                   	push   %edi
  800f7c:	56                   	push   %esi
  800f7d:	6a 00                	push   $0x0
  800f7f:	e8 04 fd ff ff       	call   800c88 <sys_page_map>
  800f84:	83 c4 20             	add    $0x20,%esp
  800f87:	85 c0                	test   %eax,%eax
  800f89:	0f 88 a9 00 00 00    	js     801038 <fork+0x144>
		if ((r = sys_page_map(0, addr, 0, addr, PTE_COW|PTE_U|PTE_P)) < 0)
  800f8f:	83 ec 0c             	sub    $0xc,%esp
  800f92:	68 05 08 00 00       	push   $0x805
  800f97:	56                   	push   %esi
  800f98:	6a 00                	push   $0x0
  800f9a:	56                   	push   %esi
  800f9b:	6a 00                	push   $0x0
  800f9d:	e8 e6 fc ff ff       	call   800c88 <sys_page_map>
  800fa2:	83 c4 20             	add    $0x20,%esp
  800fa5:	85 c0                	test   %eax,%eax
  800fa7:	0f 88 9d 00 00 00    	js     80104a <fork+0x156>
    for(uint32_t addr = 0; addr < USTACKTOP; addr += PGSIZE){
  800fad:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800fb3:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  800fb9:	0f 84 9d 00 00 00    	je     80105c <fork+0x168>
		if((uvpd[PDX(addr)] & PTE_P) && 
  800fbf:	89 d8                	mov    %ebx,%eax
  800fc1:	c1 e8 16             	shr    $0x16,%eax
  800fc4:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fcb:	a8 01                	test   $0x1,%al
  800fcd:	74 de                	je     800fad <fork+0xb9>
		(uvpt[PGNUM(addr)]&PTE_P) && 
  800fcf:	89 d8                	mov    %ebx,%eax
  800fd1:	c1 e8 0c             	shr    $0xc,%eax
  800fd4:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
		if((uvpd[PDX(addr)] & PTE_P) && 
  800fdb:	f6 c2 01             	test   $0x1,%dl
  800fde:	74 cd                	je     800fad <fork+0xb9>
		(uvpt[PGNUM(addr)] &PTE_U)){
  800fe0:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
		(uvpt[PGNUM(addr)]&PTE_P) && 
  800fe7:	f6 c2 04             	test   $0x4,%dl
  800fea:	74 c1                	je     800fad <fork+0xb9>
    void *addr=(void *)(pn*PGSIZE);
  800fec:	89 c6                	mov    %eax,%esi
  800fee:	c1 e6 0c             	shl    $0xc,%esi
    if(uvpt[pn] & PTE_SHARE){
  800ff1:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800ff8:	f6 c6 04             	test   $0x4,%dh
  800ffb:	0f 85 5a ff ff ff    	jne    800f5b <fork+0x67>
    else if((uvpt[pn]&PTE_W)|| (uvpt[pn] & PTE_COW)){
  801001:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801008:	f6 c2 02             	test   $0x2,%dl
  80100b:	0f 85 61 ff ff ff    	jne    800f72 <fork+0x7e>
  801011:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801018:	f6 c4 08             	test   $0x8,%ah
  80101b:	0f 85 51 ff ff ff    	jne    800f72 <fork+0x7e>
        sys_page_map(0, addr, envid, addr, PTE_U|PTE_P);
  801021:	83 ec 0c             	sub    $0xc,%esp
  801024:	6a 05                	push   $0x5
  801026:	56                   	push   %esi
  801027:	57                   	push   %edi
  801028:	56                   	push   %esi
  801029:	6a 00                	push   $0x0
  80102b:	e8 58 fc ff ff       	call   800c88 <sys_page_map>
  801030:	83 c4 20             	add    $0x20,%esp
  801033:	e9 75 ff ff ff       	jmp    800fad <fork+0xb9>
			panic("sys_page_map：%e", r);
  801038:	50                   	push   %eax
  801039:	68 da 17 80 00       	push   $0x8017da
  80103e:	6a 4d                	push   $0x4d
  801040:	68 64 17 80 00       	push   $0x801764
  801045:	e8 be 00 00 00       	call   801108 <_panic>
			panic("sys_page_map：%e", r);
  80104a:	50                   	push   %eax
  80104b:	68 da 17 80 00       	push   $0x8017da
  801050:	6a 4f                	push   $0x4f
  801052:	68 64 17 80 00       	push   $0x801764
  801057:	e8 ac 00 00 00       	call   801108 <_panic>
			duppage(envid, PGNUM(addr));
		}
	}

    // Allocate a new page for the child's user exception stack
    int r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_P|PTE_W|PTE_U);
  80105c:	83 ec 04             	sub    $0x4,%esp
  80105f:	6a 07                	push   $0x7
  801061:	68 00 f0 bf ee       	push   $0xeebff000
  801066:	ff 75 e4             	pushl  -0x1c(%ebp)
  801069:	e8 d3 fb ff ff       	call   800c41 <sys_page_alloc>
	if( r < 0)
  80106e:	83 c4 10             	add    $0x10,%esp
  801071:	85 c0                	test   %eax,%eax
  801073:	78 36                	js     8010ab <fork+0x1b7>
		panic("sys_page_alloc: %e", r);

    // Set the page fault upcall for the child
    r=sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  801075:	83 ec 08             	sub    $0x8,%esp
  801078:	68 af 11 80 00       	push   $0x8011af
  80107d:	ff 75 e4             	pushl  -0x1c(%ebp)
  801080:	e8 d5 fc ff ff       	call   800d5a <sys_env_set_pgfault_upcall>
    if( r < 0 )
  801085:	83 c4 10             	add    $0x10,%esp
  801088:	85 c0                	test   %eax,%eax
  80108a:	78 34                	js     8010c0 <fork+0x1cc>
		panic("sys_env_set_pgfault_upcall: %e",r);
    
    // Mark the child as runnable
    r=sys_env_set_status(envid, ENV_RUNNABLE);
  80108c:	83 ec 08             	sub    $0x8,%esp
  80108f:	6a 02                	push   $0x2
  801091:	ff 75 e4             	pushl  -0x1c(%ebp)
  801094:	e8 7b fc ff ff       	call   800d14 <sys_env_set_status>
    if (r < 0)
  801099:	83 c4 10             	add    $0x10,%esp
  80109c:	85 c0                	test   %eax,%eax
  80109e:	78 35                	js     8010d5 <fork+0x1e1>
		panic("sys_env_set_status: %e", r);
    
    return envid;
	// LAB 4: Your code here.
	//panic("fork not implemented");
}
  8010a0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8010a3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010a6:	5b                   	pop    %ebx
  8010a7:	5e                   	pop    %esi
  8010a8:	5f                   	pop    %edi
  8010a9:	5d                   	pop    %ebp
  8010aa:	c3                   	ret    
		panic("sys_page_alloc: %e", r);
  8010ab:	50                   	push   %eax
  8010ac:	68 96 17 80 00       	push   $0x801796
  8010b1:	68 84 00 00 00       	push   $0x84
  8010b6:	68 64 17 80 00       	push   $0x801764
  8010bb:	e8 48 00 00 00       	call   801108 <_panic>
		panic("sys_env_set_pgfault_upcall: %e",r);
  8010c0:	50                   	push   %eax
  8010c1:	68 1c 18 80 00       	push   $0x80181c
  8010c6:	68 89 00 00 00       	push   $0x89
  8010cb:	68 64 17 80 00       	push   $0x801764
  8010d0:	e8 33 00 00 00       	call   801108 <_panic>
		panic("sys_env_set_status: %e", r);
  8010d5:	50                   	push   %eax
  8010d6:	68 ec 17 80 00       	push   $0x8017ec
  8010db:	68 8e 00 00 00       	push   $0x8e
  8010e0:	68 64 17 80 00       	push   $0x801764
  8010e5:	e8 1e 00 00 00       	call   801108 <_panic>

008010ea <sfork>:

// Challenge!
int
sfork(void)
{
  8010ea:	f3 0f 1e fb          	endbr32 
  8010ee:	55                   	push   %ebp
  8010ef:	89 e5                	mov    %esp,%ebp
  8010f1:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8010f4:	68 03 18 80 00       	push   $0x801803
  8010f9:	68 99 00 00 00       	push   $0x99
  8010fe:	68 64 17 80 00       	push   $0x801764
  801103:	e8 00 00 00 00       	call   801108 <_panic>

00801108 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801108:	f3 0f 1e fb          	endbr32 
  80110c:	55                   	push   %ebp
  80110d:	89 e5                	mov    %esp,%ebp
  80110f:	56                   	push   %esi
  801110:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801111:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801114:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80111a:	e8 dc fa ff ff       	call   800bfb <sys_getenvid>
  80111f:	83 ec 0c             	sub    $0xc,%esp
  801122:	ff 75 0c             	pushl  0xc(%ebp)
  801125:	ff 75 08             	pushl  0x8(%ebp)
  801128:	56                   	push   %esi
  801129:	50                   	push   %eax
  80112a:	68 3c 18 80 00       	push   $0x80183c
  80112f:	e8 82 f0 ff ff       	call   8001b6 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801134:	83 c4 18             	add    $0x18,%esp
  801137:	53                   	push   %ebx
  801138:	ff 75 10             	pushl  0x10(%ebp)
  80113b:	e8 21 f0 ff ff       	call   800161 <vcprintf>
	cprintf("\n");
  801140:	c7 04 24 d4 14 80 00 	movl   $0x8014d4,(%esp)
  801147:	e8 6a f0 ff ff       	call   8001b6 <cprintf>
  80114c:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80114f:	cc                   	int3   
  801150:	eb fd                	jmp    80114f <_panic+0x47>

00801152 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801152:	f3 0f 1e fb          	endbr32 
  801156:	55                   	push   %ebp
  801157:	89 e5                	mov    %esp,%ebp
  801159:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  80115c:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  801163:	74 0a                	je     80116f <set_pgfault_handler+0x1d>
        sys_env_set_pgfault_upcall(0, _pgfault_upcall);
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801165:	8b 45 08             	mov    0x8(%ebp),%eax
  801168:	a3 08 20 80 00       	mov    %eax,0x802008
}
  80116d:	c9                   	leave  
  80116e:	c3                   	ret    
		if (sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P) < 0)
  80116f:	83 ec 04             	sub    $0x4,%esp
  801172:	6a 07                	push   $0x7
  801174:	68 00 f0 bf ee       	push   $0xeebff000
  801179:	6a 00                	push   $0x0
  80117b:	e8 c1 fa ff ff       	call   800c41 <sys_page_alloc>
  801180:	83 c4 10             	add    $0x10,%esp
  801183:	85 c0                	test   %eax,%eax
  801185:	78 14                	js     80119b <set_pgfault_handler+0x49>
        sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  801187:	83 ec 08             	sub    $0x8,%esp
  80118a:	68 af 11 80 00       	push   $0x8011af
  80118f:	6a 00                	push   $0x0
  801191:	e8 c4 fb ff ff       	call   800d5a <sys_env_set_pgfault_upcall>
  801196:	83 c4 10             	add    $0x10,%esp
  801199:	eb ca                	jmp    801165 <set_pgfault_handler+0x13>
            panic("set_pgfault_handler failed.");
  80119b:	83 ec 04             	sub    $0x4,%esp
  80119e:	68 5f 18 80 00       	push   $0x80185f
  8011a3:	6a 21                	push   $0x21
  8011a5:	68 7b 18 80 00       	push   $0x80187b
  8011aa:	e8 59 ff ff ff       	call   801108 <_panic>

008011af <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8011af:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8011b0:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  8011b5:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8011b7:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	addl $8, %esp
  8011ba:	83 c4 08             	add    $0x8,%esp
	movl 32(%esp), %eax
  8011bd:	8b 44 24 20          	mov    0x20(%esp),%eax
	movl 40(%esp), %edx
  8011c1:	8b 54 24 28          	mov    0x28(%esp),%edx
	subl $4, %edx
  8011c5:	83 ea 04             	sub    $0x4,%edx
	movl %eax, (%edx)
  8011c8:	89 02                	mov    %eax,(%edx)
	movl %edx, 40(%esp)
  8011ca:	89 54 24 28          	mov    %edx,0x28(%esp)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal
  8011ce:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp
  8011cf:	83 c4 04             	add    $0x4,%esp
	popfl
  8011d2:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  8011d3:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  8011d4:	c3                   	ret    
  8011d5:	66 90                	xchg   %ax,%ax
  8011d7:	66 90                	xchg   %ax,%ax
  8011d9:	66 90                	xchg   %ax,%ax
  8011db:	66 90                	xchg   %ax,%ax
  8011dd:	66 90                	xchg   %ax,%ax
  8011df:	90                   	nop

008011e0 <__udivdi3>:
  8011e0:	f3 0f 1e fb          	endbr32 
  8011e4:	55                   	push   %ebp
  8011e5:	57                   	push   %edi
  8011e6:	56                   	push   %esi
  8011e7:	53                   	push   %ebx
  8011e8:	83 ec 1c             	sub    $0x1c,%esp
  8011eb:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8011ef:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  8011f3:	8b 74 24 34          	mov    0x34(%esp),%esi
  8011f7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  8011fb:	85 d2                	test   %edx,%edx
  8011fd:	75 19                	jne    801218 <__udivdi3+0x38>
  8011ff:	39 f3                	cmp    %esi,%ebx
  801201:	76 4d                	jbe    801250 <__udivdi3+0x70>
  801203:	31 ff                	xor    %edi,%edi
  801205:	89 e8                	mov    %ebp,%eax
  801207:	89 f2                	mov    %esi,%edx
  801209:	f7 f3                	div    %ebx
  80120b:	89 fa                	mov    %edi,%edx
  80120d:	83 c4 1c             	add    $0x1c,%esp
  801210:	5b                   	pop    %ebx
  801211:	5e                   	pop    %esi
  801212:	5f                   	pop    %edi
  801213:	5d                   	pop    %ebp
  801214:	c3                   	ret    
  801215:	8d 76 00             	lea    0x0(%esi),%esi
  801218:	39 f2                	cmp    %esi,%edx
  80121a:	76 14                	jbe    801230 <__udivdi3+0x50>
  80121c:	31 ff                	xor    %edi,%edi
  80121e:	31 c0                	xor    %eax,%eax
  801220:	89 fa                	mov    %edi,%edx
  801222:	83 c4 1c             	add    $0x1c,%esp
  801225:	5b                   	pop    %ebx
  801226:	5e                   	pop    %esi
  801227:	5f                   	pop    %edi
  801228:	5d                   	pop    %ebp
  801229:	c3                   	ret    
  80122a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801230:	0f bd fa             	bsr    %edx,%edi
  801233:	83 f7 1f             	xor    $0x1f,%edi
  801236:	75 48                	jne    801280 <__udivdi3+0xa0>
  801238:	39 f2                	cmp    %esi,%edx
  80123a:	72 06                	jb     801242 <__udivdi3+0x62>
  80123c:	31 c0                	xor    %eax,%eax
  80123e:	39 eb                	cmp    %ebp,%ebx
  801240:	77 de                	ja     801220 <__udivdi3+0x40>
  801242:	b8 01 00 00 00       	mov    $0x1,%eax
  801247:	eb d7                	jmp    801220 <__udivdi3+0x40>
  801249:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801250:	89 d9                	mov    %ebx,%ecx
  801252:	85 db                	test   %ebx,%ebx
  801254:	75 0b                	jne    801261 <__udivdi3+0x81>
  801256:	b8 01 00 00 00       	mov    $0x1,%eax
  80125b:	31 d2                	xor    %edx,%edx
  80125d:	f7 f3                	div    %ebx
  80125f:	89 c1                	mov    %eax,%ecx
  801261:	31 d2                	xor    %edx,%edx
  801263:	89 f0                	mov    %esi,%eax
  801265:	f7 f1                	div    %ecx
  801267:	89 c6                	mov    %eax,%esi
  801269:	89 e8                	mov    %ebp,%eax
  80126b:	89 f7                	mov    %esi,%edi
  80126d:	f7 f1                	div    %ecx
  80126f:	89 fa                	mov    %edi,%edx
  801271:	83 c4 1c             	add    $0x1c,%esp
  801274:	5b                   	pop    %ebx
  801275:	5e                   	pop    %esi
  801276:	5f                   	pop    %edi
  801277:	5d                   	pop    %ebp
  801278:	c3                   	ret    
  801279:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801280:	89 f9                	mov    %edi,%ecx
  801282:	b8 20 00 00 00       	mov    $0x20,%eax
  801287:	29 f8                	sub    %edi,%eax
  801289:	d3 e2                	shl    %cl,%edx
  80128b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80128f:	89 c1                	mov    %eax,%ecx
  801291:	89 da                	mov    %ebx,%edx
  801293:	d3 ea                	shr    %cl,%edx
  801295:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801299:	09 d1                	or     %edx,%ecx
  80129b:	89 f2                	mov    %esi,%edx
  80129d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8012a1:	89 f9                	mov    %edi,%ecx
  8012a3:	d3 e3                	shl    %cl,%ebx
  8012a5:	89 c1                	mov    %eax,%ecx
  8012a7:	d3 ea                	shr    %cl,%edx
  8012a9:	89 f9                	mov    %edi,%ecx
  8012ab:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8012af:	89 eb                	mov    %ebp,%ebx
  8012b1:	d3 e6                	shl    %cl,%esi
  8012b3:	89 c1                	mov    %eax,%ecx
  8012b5:	d3 eb                	shr    %cl,%ebx
  8012b7:	09 de                	or     %ebx,%esi
  8012b9:	89 f0                	mov    %esi,%eax
  8012bb:	f7 74 24 08          	divl   0x8(%esp)
  8012bf:	89 d6                	mov    %edx,%esi
  8012c1:	89 c3                	mov    %eax,%ebx
  8012c3:	f7 64 24 0c          	mull   0xc(%esp)
  8012c7:	39 d6                	cmp    %edx,%esi
  8012c9:	72 15                	jb     8012e0 <__udivdi3+0x100>
  8012cb:	89 f9                	mov    %edi,%ecx
  8012cd:	d3 e5                	shl    %cl,%ebp
  8012cf:	39 c5                	cmp    %eax,%ebp
  8012d1:	73 04                	jae    8012d7 <__udivdi3+0xf7>
  8012d3:	39 d6                	cmp    %edx,%esi
  8012d5:	74 09                	je     8012e0 <__udivdi3+0x100>
  8012d7:	89 d8                	mov    %ebx,%eax
  8012d9:	31 ff                	xor    %edi,%edi
  8012db:	e9 40 ff ff ff       	jmp    801220 <__udivdi3+0x40>
  8012e0:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8012e3:	31 ff                	xor    %edi,%edi
  8012e5:	e9 36 ff ff ff       	jmp    801220 <__udivdi3+0x40>
  8012ea:	66 90                	xchg   %ax,%ax
  8012ec:	66 90                	xchg   %ax,%ax
  8012ee:	66 90                	xchg   %ax,%ax

008012f0 <__umoddi3>:
  8012f0:	f3 0f 1e fb          	endbr32 
  8012f4:	55                   	push   %ebp
  8012f5:	57                   	push   %edi
  8012f6:	56                   	push   %esi
  8012f7:	53                   	push   %ebx
  8012f8:	83 ec 1c             	sub    $0x1c,%esp
  8012fb:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  8012ff:	8b 74 24 30          	mov    0x30(%esp),%esi
  801303:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  801307:	8b 7c 24 38          	mov    0x38(%esp),%edi
  80130b:	85 c0                	test   %eax,%eax
  80130d:	75 19                	jne    801328 <__umoddi3+0x38>
  80130f:	39 df                	cmp    %ebx,%edi
  801311:	76 5d                	jbe    801370 <__umoddi3+0x80>
  801313:	89 f0                	mov    %esi,%eax
  801315:	89 da                	mov    %ebx,%edx
  801317:	f7 f7                	div    %edi
  801319:	89 d0                	mov    %edx,%eax
  80131b:	31 d2                	xor    %edx,%edx
  80131d:	83 c4 1c             	add    $0x1c,%esp
  801320:	5b                   	pop    %ebx
  801321:	5e                   	pop    %esi
  801322:	5f                   	pop    %edi
  801323:	5d                   	pop    %ebp
  801324:	c3                   	ret    
  801325:	8d 76 00             	lea    0x0(%esi),%esi
  801328:	89 f2                	mov    %esi,%edx
  80132a:	39 d8                	cmp    %ebx,%eax
  80132c:	76 12                	jbe    801340 <__umoddi3+0x50>
  80132e:	89 f0                	mov    %esi,%eax
  801330:	89 da                	mov    %ebx,%edx
  801332:	83 c4 1c             	add    $0x1c,%esp
  801335:	5b                   	pop    %ebx
  801336:	5e                   	pop    %esi
  801337:	5f                   	pop    %edi
  801338:	5d                   	pop    %ebp
  801339:	c3                   	ret    
  80133a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801340:	0f bd e8             	bsr    %eax,%ebp
  801343:	83 f5 1f             	xor    $0x1f,%ebp
  801346:	75 50                	jne    801398 <__umoddi3+0xa8>
  801348:	39 d8                	cmp    %ebx,%eax
  80134a:	0f 82 e0 00 00 00    	jb     801430 <__umoddi3+0x140>
  801350:	89 d9                	mov    %ebx,%ecx
  801352:	39 f7                	cmp    %esi,%edi
  801354:	0f 86 d6 00 00 00    	jbe    801430 <__umoddi3+0x140>
  80135a:	89 d0                	mov    %edx,%eax
  80135c:	89 ca                	mov    %ecx,%edx
  80135e:	83 c4 1c             	add    $0x1c,%esp
  801361:	5b                   	pop    %ebx
  801362:	5e                   	pop    %esi
  801363:	5f                   	pop    %edi
  801364:	5d                   	pop    %ebp
  801365:	c3                   	ret    
  801366:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80136d:	8d 76 00             	lea    0x0(%esi),%esi
  801370:	89 fd                	mov    %edi,%ebp
  801372:	85 ff                	test   %edi,%edi
  801374:	75 0b                	jne    801381 <__umoddi3+0x91>
  801376:	b8 01 00 00 00       	mov    $0x1,%eax
  80137b:	31 d2                	xor    %edx,%edx
  80137d:	f7 f7                	div    %edi
  80137f:	89 c5                	mov    %eax,%ebp
  801381:	89 d8                	mov    %ebx,%eax
  801383:	31 d2                	xor    %edx,%edx
  801385:	f7 f5                	div    %ebp
  801387:	89 f0                	mov    %esi,%eax
  801389:	f7 f5                	div    %ebp
  80138b:	89 d0                	mov    %edx,%eax
  80138d:	31 d2                	xor    %edx,%edx
  80138f:	eb 8c                	jmp    80131d <__umoddi3+0x2d>
  801391:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801398:	89 e9                	mov    %ebp,%ecx
  80139a:	ba 20 00 00 00       	mov    $0x20,%edx
  80139f:	29 ea                	sub    %ebp,%edx
  8013a1:	d3 e0                	shl    %cl,%eax
  8013a3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8013a7:	89 d1                	mov    %edx,%ecx
  8013a9:	89 f8                	mov    %edi,%eax
  8013ab:	d3 e8                	shr    %cl,%eax
  8013ad:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8013b1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8013b5:	8b 54 24 04          	mov    0x4(%esp),%edx
  8013b9:	09 c1                	or     %eax,%ecx
  8013bb:	89 d8                	mov    %ebx,%eax
  8013bd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8013c1:	89 e9                	mov    %ebp,%ecx
  8013c3:	d3 e7                	shl    %cl,%edi
  8013c5:	89 d1                	mov    %edx,%ecx
  8013c7:	d3 e8                	shr    %cl,%eax
  8013c9:	89 e9                	mov    %ebp,%ecx
  8013cb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8013cf:	d3 e3                	shl    %cl,%ebx
  8013d1:	89 c7                	mov    %eax,%edi
  8013d3:	89 d1                	mov    %edx,%ecx
  8013d5:	89 f0                	mov    %esi,%eax
  8013d7:	d3 e8                	shr    %cl,%eax
  8013d9:	89 e9                	mov    %ebp,%ecx
  8013db:	89 fa                	mov    %edi,%edx
  8013dd:	d3 e6                	shl    %cl,%esi
  8013df:	09 d8                	or     %ebx,%eax
  8013e1:	f7 74 24 08          	divl   0x8(%esp)
  8013e5:	89 d1                	mov    %edx,%ecx
  8013e7:	89 f3                	mov    %esi,%ebx
  8013e9:	f7 64 24 0c          	mull   0xc(%esp)
  8013ed:	89 c6                	mov    %eax,%esi
  8013ef:	89 d7                	mov    %edx,%edi
  8013f1:	39 d1                	cmp    %edx,%ecx
  8013f3:	72 06                	jb     8013fb <__umoddi3+0x10b>
  8013f5:	75 10                	jne    801407 <__umoddi3+0x117>
  8013f7:	39 c3                	cmp    %eax,%ebx
  8013f9:	73 0c                	jae    801407 <__umoddi3+0x117>
  8013fb:	2b 44 24 0c          	sub    0xc(%esp),%eax
  8013ff:	1b 54 24 08          	sbb    0x8(%esp),%edx
  801403:	89 d7                	mov    %edx,%edi
  801405:	89 c6                	mov    %eax,%esi
  801407:	89 ca                	mov    %ecx,%edx
  801409:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80140e:	29 f3                	sub    %esi,%ebx
  801410:	19 fa                	sbb    %edi,%edx
  801412:	89 d0                	mov    %edx,%eax
  801414:	d3 e0                	shl    %cl,%eax
  801416:	89 e9                	mov    %ebp,%ecx
  801418:	d3 eb                	shr    %cl,%ebx
  80141a:	d3 ea                	shr    %cl,%edx
  80141c:	09 d8                	or     %ebx,%eax
  80141e:	83 c4 1c             	add    $0x1c,%esp
  801421:	5b                   	pop    %ebx
  801422:	5e                   	pop    %esi
  801423:	5f                   	pop    %edi
  801424:	5d                   	pop    %ebp
  801425:	c3                   	ret    
  801426:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80142d:	8d 76 00             	lea    0x0(%esi),%esi
  801430:	29 fe                	sub    %edi,%esi
  801432:	19 c3                	sbb    %eax,%ebx
  801434:	89 f2                	mov    %esi,%edx
  801436:	89 d9                	mov    %ebx,%ecx
  801438:	e9 1d ff ff ff       	jmp    80135a <__umoddi3+0x6a>
