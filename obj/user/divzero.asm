
obj/user/divzero:     file format elf32-i386


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
  80002c:	e8 33 00 00 00       	call   800064 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

int zero;

void
umain(int argc, char **argv)
{
  800033:	f3 0f 1e fb          	endbr32 
  800037:	55                   	push   %ebp
  800038:	89 e5                	mov    %esp,%ebp
  80003a:	83 ec 10             	sub    $0x10,%esp
	zero = 0;
  80003d:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  800044:	00 00 00 
	cprintf("1/0 is %08x!\n", 1/zero);
  800047:	b8 01 00 00 00       	mov    $0x1,%eax
  80004c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800051:	99                   	cltd   
  800052:	f7 f9                	idiv   %ecx
  800054:	50                   	push   %eax
  800055:	68 80 10 80 00       	push   $0x801080
  80005a:	e8 02 01 00 00       	call   800161 <cprintf>
}
  80005f:	83 c4 10             	add    $0x10,%esp
  800062:	c9                   	leave  
  800063:	c3                   	ret    

00800064 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800064:	f3 0f 1e fb          	endbr32 
  800068:	55                   	push   %ebp
  800069:	89 e5                	mov    %esp,%ebp
  80006b:	56                   	push   %esi
  80006c:	53                   	push   %ebx
  80006d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800070:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv=&envs[ENVX(sys_getenvid())];
  800073:	e8 2e 0b 00 00       	call   800ba6 <sys_getenvid>
  800078:	25 ff 03 00 00       	and    $0x3ff,%eax
  80007d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800080:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800085:	a3 08 20 80 00       	mov    %eax,0x802008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80008a:	85 db                	test   %ebx,%ebx
  80008c:	7e 07                	jle    800095 <libmain+0x31>
		binaryname = argv[0];
  80008e:	8b 06                	mov    (%esi),%eax
  800090:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800095:	83 ec 08             	sub    $0x8,%esp
  800098:	56                   	push   %esi
  800099:	53                   	push   %ebx
  80009a:	e8 94 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80009f:	e8 0a 00 00 00       	call   8000ae <exit>
}
  8000a4:	83 c4 10             	add    $0x10,%esp
  8000a7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000aa:	5b                   	pop    %ebx
  8000ab:	5e                   	pop    %esi
  8000ac:	5d                   	pop    %ebp
  8000ad:	c3                   	ret    

008000ae <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000ae:	f3 0f 1e fb          	endbr32 
  8000b2:	55                   	push   %ebp
  8000b3:	89 e5                	mov    %esp,%ebp
  8000b5:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000b8:	6a 00                	push   $0x0
  8000ba:	e8 a2 0a 00 00       	call   800b61 <sys_env_destroy>
}
  8000bf:	83 c4 10             	add    $0x10,%esp
  8000c2:	c9                   	leave  
  8000c3:	c3                   	ret    

008000c4 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000c4:	f3 0f 1e fb          	endbr32 
  8000c8:	55                   	push   %ebp
  8000c9:	89 e5                	mov    %esp,%ebp
  8000cb:	53                   	push   %ebx
  8000cc:	83 ec 04             	sub    $0x4,%esp
  8000cf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000d2:	8b 13                	mov    (%ebx),%edx
  8000d4:	8d 42 01             	lea    0x1(%edx),%eax
  8000d7:	89 03                	mov    %eax,(%ebx)
  8000d9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000dc:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000e0:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000e5:	74 09                	je     8000f0 <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8000e7:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000eb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000ee:	c9                   	leave  
  8000ef:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8000f0:	83 ec 08             	sub    $0x8,%esp
  8000f3:	68 ff 00 00 00       	push   $0xff
  8000f8:	8d 43 08             	lea    0x8(%ebx),%eax
  8000fb:	50                   	push   %eax
  8000fc:	e8 1b 0a 00 00       	call   800b1c <sys_cputs>
		b->idx = 0;
  800101:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800107:	83 c4 10             	add    $0x10,%esp
  80010a:	eb db                	jmp    8000e7 <putch+0x23>

0080010c <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80010c:	f3 0f 1e fb          	endbr32 
  800110:	55                   	push   %ebp
  800111:	89 e5                	mov    %esp,%ebp
  800113:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800119:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800120:	00 00 00 
	b.cnt = 0;
  800123:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80012a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80012d:	ff 75 0c             	pushl  0xc(%ebp)
  800130:	ff 75 08             	pushl  0x8(%ebp)
  800133:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800139:	50                   	push   %eax
  80013a:	68 c4 00 80 00       	push   $0x8000c4
  80013f:	e8 20 01 00 00       	call   800264 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800144:	83 c4 08             	add    $0x8,%esp
  800147:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80014d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800153:	50                   	push   %eax
  800154:	e8 c3 09 00 00       	call   800b1c <sys_cputs>

	return b.cnt;
}
  800159:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80015f:	c9                   	leave  
  800160:	c3                   	ret    

00800161 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800161:	f3 0f 1e fb          	endbr32 
  800165:	55                   	push   %ebp
  800166:	89 e5                	mov    %esp,%ebp
  800168:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80016b:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80016e:	50                   	push   %eax
  80016f:	ff 75 08             	pushl  0x8(%ebp)
  800172:	e8 95 ff ff ff       	call   80010c <vcprintf>
	va_end(ap);

	return cnt;
}
  800177:	c9                   	leave  
  800178:	c3                   	ret    

00800179 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800179:	55                   	push   %ebp
  80017a:	89 e5                	mov    %esp,%ebp
  80017c:	57                   	push   %edi
  80017d:	56                   	push   %esi
  80017e:	53                   	push   %ebx
  80017f:	83 ec 1c             	sub    $0x1c,%esp
  800182:	89 c7                	mov    %eax,%edi
  800184:	89 d6                	mov    %edx,%esi
  800186:	8b 45 08             	mov    0x8(%ebp),%eax
  800189:	8b 55 0c             	mov    0xc(%ebp),%edx
  80018c:	89 d1                	mov    %edx,%ecx
  80018e:	89 c2                	mov    %eax,%edx
  800190:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800193:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800196:	8b 45 10             	mov    0x10(%ebp),%eax
  800199:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80019c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80019f:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8001a6:	39 c2                	cmp    %eax,%edx
  8001a8:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8001ab:	72 3e                	jb     8001eb <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001ad:	83 ec 0c             	sub    $0xc,%esp
  8001b0:	ff 75 18             	pushl  0x18(%ebp)
  8001b3:	83 eb 01             	sub    $0x1,%ebx
  8001b6:	53                   	push   %ebx
  8001b7:	50                   	push   %eax
  8001b8:	83 ec 08             	sub    $0x8,%esp
  8001bb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001be:	ff 75 e0             	pushl  -0x20(%ebp)
  8001c1:	ff 75 dc             	pushl  -0x24(%ebp)
  8001c4:	ff 75 d8             	pushl  -0x28(%ebp)
  8001c7:	e8 44 0c 00 00       	call   800e10 <__udivdi3>
  8001cc:	83 c4 18             	add    $0x18,%esp
  8001cf:	52                   	push   %edx
  8001d0:	50                   	push   %eax
  8001d1:	89 f2                	mov    %esi,%edx
  8001d3:	89 f8                	mov    %edi,%eax
  8001d5:	e8 9f ff ff ff       	call   800179 <printnum>
  8001da:	83 c4 20             	add    $0x20,%esp
  8001dd:	eb 13                	jmp    8001f2 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001df:	83 ec 08             	sub    $0x8,%esp
  8001e2:	56                   	push   %esi
  8001e3:	ff 75 18             	pushl  0x18(%ebp)
  8001e6:	ff d7                	call   *%edi
  8001e8:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8001eb:	83 eb 01             	sub    $0x1,%ebx
  8001ee:	85 db                	test   %ebx,%ebx
  8001f0:	7f ed                	jg     8001df <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001f2:	83 ec 08             	sub    $0x8,%esp
  8001f5:	56                   	push   %esi
  8001f6:	83 ec 04             	sub    $0x4,%esp
  8001f9:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001fc:	ff 75 e0             	pushl  -0x20(%ebp)
  8001ff:	ff 75 dc             	pushl  -0x24(%ebp)
  800202:	ff 75 d8             	pushl  -0x28(%ebp)
  800205:	e8 16 0d 00 00       	call   800f20 <__umoddi3>
  80020a:	83 c4 14             	add    $0x14,%esp
  80020d:	0f be 80 98 10 80 00 	movsbl 0x801098(%eax),%eax
  800214:	50                   	push   %eax
  800215:	ff d7                	call   *%edi
}
  800217:	83 c4 10             	add    $0x10,%esp
  80021a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80021d:	5b                   	pop    %ebx
  80021e:	5e                   	pop    %esi
  80021f:	5f                   	pop    %edi
  800220:	5d                   	pop    %ebp
  800221:	c3                   	ret    

00800222 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800222:	f3 0f 1e fb          	endbr32 
  800226:	55                   	push   %ebp
  800227:	89 e5                	mov    %esp,%ebp
  800229:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80022c:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800230:	8b 10                	mov    (%eax),%edx
  800232:	3b 50 04             	cmp    0x4(%eax),%edx
  800235:	73 0a                	jae    800241 <sprintputch+0x1f>
		*b->buf++ = ch;
  800237:	8d 4a 01             	lea    0x1(%edx),%ecx
  80023a:	89 08                	mov    %ecx,(%eax)
  80023c:	8b 45 08             	mov    0x8(%ebp),%eax
  80023f:	88 02                	mov    %al,(%edx)
}
  800241:	5d                   	pop    %ebp
  800242:	c3                   	ret    

00800243 <printfmt>:
{
  800243:	f3 0f 1e fb          	endbr32 
  800247:	55                   	push   %ebp
  800248:	89 e5                	mov    %esp,%ebp
  80024a:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80024d:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800250:	50                   	push   %eax
  800251:	ff 75 10             	pushl  0x10(%ebp)
  800254:	ff 75 0c             	pushl  0xc(%ebp)
  800257:	ff 75 08             	pushl  0x8(%ebp)
  80025a:	e8 05 00 00 00       	call   800264 <vprintfmt>
}
  80025f:	83 c4 10             	add    $0x10,%esp
  800262:	c9                   	leave  
  800263:	c3                   	ret    

00800264 <vprintfmt>:
{
  800264:	f3 0f 1e fb          	endbr32 
  800268:	55                   	push   %ebp
  800269:	89 e5                	mov    %esp,%ebp
  80026b:	57                   	push   %edi
  80026c:	56                   	push   %esi
  80026d:	53                   	push   %ebx
  80026e:	83 ec 3c             	sub    $0x3c,%esp
  800271:	8b 75 08             	mov    0x8(%ebp),%esi
  800274:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800277:	8b 7d 10             	mov    0x10(%ebp),%edi
  80027a:	e9 cd 03 00 00       	jmp    80064c <vprintfmt+0x3e8>
		padc = ' ';
  80027f:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800283:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  80028a:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800291:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800298:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80029d:	8d 47 01             	lea    0x1(%edi),%eax
  8002a0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002a3:	0f b6 17             	movzbl (%edi),%edx
  8002a6:	8d 42 dd             	lea    -0x23(%edx),%eax
  8002a9:	3c 55                	cmp    $0x55,%al
  8002ab:	0f 87 1e 04 00 00    	ja     8006cf <vprintfmt+0x46b>
  8002b1:	0f b6 c0             	movzbl %al,%eax
  8002b4:	3e ff 24 85 60 11 80 	notrack jmp *0x801160(,%eax,4)
  8002bb:	00 
  8002bc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8002bf:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  8002c3:	eb d8                	jmp    80029d <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8002c5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8002c8:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  8002cc:	eb cf                	jmp    80029d <vprintfmt+0x39>
  8002ce:	0f b6 d2             	movzbl %dl,%edx
  8002d1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8002d4:	b8 00 00 00 00       	mov    $0x0,%eax
  8002d9:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8002dc:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8002df:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8002e3:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8002e6:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8002e9:	83 f9 09             	cmp    $0x9,%ecx
  8002ec:	77 55                	ja     800343 <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  8002ee:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8002f1:	eb e9                	jmp    8002dc <vprintfmt+0x78>
			precision = va_arg(ap, int);
  8002f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8002f6:	8b 00                	mov    (%eax),%eax
  8002f8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8002fe:	8d 40 04             	lea    0x4(%eax),%eax
  800301:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800304:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800307:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80030b:	79 90                	jns    80029d <vprintfmt+0x39>
				width = precision, precision = -1;
  80030d:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800310:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800313:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80031a:	eb 81                	jmp    80029d <vprintfmt+0x39>
  80031c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80031f:	85 c0                	test   %eax,%eax
  800321:	ba 00 00 00 00       	mov    $0x0,%edx
  800326:	0f 49 d0             	cmovns %eax,%edx
  800329:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80032c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80032f:	e9 69 ff ff ff       	jmp    80029d <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800334:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800337:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  80033e:	e9 5a ff ff ff       	jmp    80029d <vprintfmt+0x39>
  800343:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800346:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800349:	eb bc                	jmp    800307 <vprintfmt+0xa3>
			lflag++;
  80034b:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80034e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800351:	e9 47 ff ff ff       	jmp    80029d <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  800356:	8b 45 14             	mov    0x14(%ebp),%eax
  800359:	8d 78 04             	lea    0x4(%eax),%edi
  80035c:	83 ec 08             	sub    $0x8,%esp
  80035f:	53                   	push   %ebx
  800360:	ff 30                	pushl  (%eax)
  800362:	ff d6                	call   *%esi
			break;
  800364:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800367:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  80036a:	e9 da 02 00 00       	jmp    800649 <vprintfmt+0x3e5>
			err = va_arg(ap, int);
  80036f:	8b 45 14             	mov    0x14(%ebp),%eax
  800372:	8d 78 04             	lea    0x4(%eax),%edi
  800375:	8b 00                	mov    (%eax),%eax
  800377:	99                   	cltd   
  800378:	31 d0                	xor    %edx,%eax
  80037a:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80037c:	83 f8 08             	cmp    $0x8,%eax
  80037f:	7f 23                	jg     8003a4 <vprintfmt+0x140>
  800381:	8b 14 85 c0 12 80 00 	mov    0x8012c0(,%eax,4),%edx
  800388:	85 d2                	test   %edx,%edx
  80038a:	74 18                	je     8003a4 <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  80038c:	52                   	push   %edx
  80038d:	68 b9 10 80 00       	push   $0x8010b9
  800392:	53                   	push   %ebx
  800393:	56                   	push   %esi
  800394:	e8 aa fe ff ff       	call   800243 <printfmt>
  800399:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80039c:	89 7d 14             	mov    %edi,0x14(%ebp)
  80039f:	e9 a5 02 00 00       	jmp    800649 <vprintfmt+0x3e5>
				printfmt(putch, putdat, "error %d", err);
  8003a4:	50                   	push   %eax
  8003a5:	68 b0 10 80 00       	push   $0x8010b0
  8003aa:	53                   	push   %ebx
  8003ab:	56                   	push   %esi
  8003ac:	e8 92 fe ff ff       	call   800243 <printfmt>
  8003b1:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003b4:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8003b7:	e9 8d 02 00 00       	jmp    800649 <vprintfmt+0x3e5>
			if ((p = va_arg(ap, char *)) == NULL)
  8003bc:	8b 45 14             	mov    0x14(%ebp),%eax
  8003bf:	83 c0 04             	add    $0x4,%eax
  8003c2:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8003c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c8:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  8003ca:	85 d2                	test   %edx,%edx
  8003cc:	b8 a9 10 80 00       	mov    $0x8010a9,%eax
  8003d1:	0f 45 c2             	cmovne %edx,%eax
  8003d4:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8003d7:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003db:	7e 06                	jle    8003e3 <vprintfmt+0x17f>
  8003dd:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  8003e1:	75 0d                	jne    8003f0 <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  8003e3:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8003e6:	89 c7                	mov    %eax,%edi
  8003e8:	03 45 e0             	add    -0x20(%ebp),%eax
  8003eb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003ee:	eb 55                	jmp    800445 <vprintfmt+0x1e1>
  8003f0:	83 ec 08             	sub    $0x8,%esp
  8003f3:	ff 75 d8             	pushl  -0x28(%ebp)
  8003f6:	ff 75 cc             	pushl  -0x34(%ebp)
  8003f9:	e8 85 03 00 00       	call   800783 <strnlen>
  8003fe:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800401:	29 c2                	sub    %eax,%edx
  800403:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  800406:	83 c4 10             	add    $0x10,%esp
  800409:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  80040b:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  80040f:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800412:	85 ff                	test   %edi,%edi
  800414:	7e 11                	jle    800427 <vprintfmt+0x1c3>
					putch(padc, putdat);
  800416:	83 ec 08             	sub    $0x8,%esp
  800419:	53                   	push   %ebx
  80041a:	ff 75 e0             	pushl  -0x20(%ebp)
  80041d:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  80041f:	83 ef 01             	sub    $0x1,%edi
  800422:	83 c4 10             	add    $0x10,%esp
  800425:	eb eb                	jmp    800412 <vprintfmt+0x1ae>
  800427:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  80042a:	85 d2                	test   %edx,%edx
  80042c:	b8 00 00 00 00       	mov    $0x0,%eax
  800431:	0f 49 c2             	cmovns %edx,%eax
  800434:	29 c2                	sub    %eax,%edx
  800436:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800439:	eb a8                	jmp    8003e3 <vprintfmt+0x17f>
					putch(ch, putdat);
  80043b:	83 ec 08             	sub    $0x8,%esp
  80043e:	53                   	push   %ebx
  80043f:	52                   	push   %edx
  800440:	ff d6                	call   *%esi
  800442:	83 c4 10             	add    $0x10,%esp
  800445:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800448:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80044a:	83 c7 01             	add    $0x1,%edi
  80044d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800451:	0f be d0             	movsbl %al,%edx
  800454:	85 d2                	test   %edx,%edx
  800456:	74 4b                	je     8004a3 <vprintfmt+0x23f>
  800458:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80045c:	78 06                	js     800464 <vprintfmt+0x200>
  80045e:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800462:	78 1e                	js     800482 <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
  800464:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800468:	74 d1                	je     80043b <vprintfmt+0x1d7>
  80046a:	0f be c0             	movsbl %al,%eax
  80046d:	83 e8 20             	sub    $0x20,%eax
  800470:	83 f8 5e             	cmp    $0x5e,%eax
  800473:	76 c6                	jbe    80043b <vprintfmt+0x1d7>
					putch('?', putdat);
  800475:	83 ec 08             	sub    $0x8,%esp
  800478:	53                   	push   %ebx
  800479:	6a 3f                	push   $0x3f
  80047b:	ff d6                	call   *%esi
  80047d:	83 c4 10             	add    $0x10,%esp
  800480:	eb c3                	jmp    800445 <vprintfmt+0x1e1>
  800482:	89 cf                	mov    %ecx,%edi
  800484:	eb 0e                	jmp    800494 <vprintfmt+0x230>
				putch(' ', putdat);
  800486:	83 ec 08             	sub    $0x8,%esp
  800489:	53                   	push   %ebx
  80048a:	6a 20                	push   $0x20
  80048c:	ff d6                	call   *%esi
			for (; width > 0; width--)
  80048e:	83 ef 01             	sub    $0x1,%edi
  800491:	83 c4 10             	add    $0x10,%esp
  800494:	85 ff                	test   %edi,%edi
  800496:	7f ee                	jg     800486 <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  800498:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80049b:	89 45 14             	mov    %eax,0x14(%ebp)
  80049e:	e9 a6 01 00 00       	jmp    800649 <vprintfmt+0x3e5>
  8004a3:	89 cf                	mov    %ecx,%edi
  8004a5:	eb ed                	jmp    800494 <vprintfmt+0x230>
	if (lflag >= 2)
  8004a7:	83 f9 01             	cmp    $0x1,%ecx
  8004aa:	7f 1f                	jg     8004cb <vprintfmt+0x267>
	else if (lflag)
  8004ac:	85 c9                	test   %ecx,%ecx
  8004ae:	74 67                	je     800517 <vprintfmt+0x2b3>
		return va_arg(*ap, long);
  8004b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b3:	8b 00                	mov    (%eax),%eax
  8004b5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004b8:	89 c1                	mov    %eax,%ecx
  8004ba:	c1 f9 1f             	sar    $0x1f,%ecx
  8004bd:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8004c0:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c3:	8d 40 04             	lea    0x4(%eax),%eax
  8004c6:	89 45 14             	mov    %eax,0x14(%ebp)
  8004c9:	eb 17                	jmp    8004e2 <vprintfmt+0x27e>
		return va_arg(*ap, long long);
  8004cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ce:	8b 50 04             	mov    0x4(%eax),%edx
  8004d1:	8b 00                	mov    (%eax),%eax
  8004d3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004d6:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8004d9:	8b 45 14             	mov    0x14(%ebp),%eax
  8004dc:	8d 40 08             	lea    0x8(%eax),%eax
  8004df:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8004e2:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8004e5:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8004e8:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  8004ed:	85 c9                	test   %ecx,%ecx
  8004ef:	0f 89 3a 01 00 00    	jns    80062f <vprintfmt+0x3cb>
				putch('-', putdat);
  8004f5:	83 ec 08             	sub    $0x8,%esp
  8004f8:	53                   	push   %ebx
  8004f9:	6a 2d                	push   $0x2d
  8004fb:	ff d6                	call   *%esi
				num = -(long long) num;
  8004fd:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800500:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800503:	f7 da                	neg    %edx
  800505:	83 d1 00             	adc    $0x0,%ecx
  800508:	f7 d9                	neg    %ecx
  80050a:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80050d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800512:	e9 18 01 00 00       	jmp    80062f <vprintfmt+0x3cb>
		return va_arg(*ap, int);
  800517:	8b 45 14             	mov    0x14(%ebp),%eax
  80051a:	8b 00                	mov    (%eax),%eax
  80051c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80051f:	89 c1                	mov    %eax,%ecx
  800521:	c1 f9 1f             	sar    $0x1f,%ecx
  800524:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800527:	8b 45 14             	mov    0x14(%ebp),%eax
  80052a:	8d 40 04             	lea    0x4(%eax),%eax
  80052d:	89 45 14             	mov    %eax,0x14(%ebp)
  800530:	eb b0                	jmp    8004e2 <vprintfmt+0x27e>
	if (lflag >= 2)
  800532:	83 f9 01             	cmp    $0x1,%ecx
  800535:	7f 1e                	jg     800555 <vprintfmt+0x2f1>
	else if (lflag)
  800537:	85 c9                	test   %ecx,%ecx
  800539:	74 32                	je     80056d <vprintfmt+0x309>
		return va_arg(*ap, unsigned long);
  80053b:	8b 45 14             	mov    0x14(%ebp),%eax
  80053e:	8b 10                	mov    (%eax),%edx
  800540:	b9 00 00 00 00       	mov    $0x0,%ecx
  800545:	8d 40 04             	lea    0x4(%eax),%eax
  800548:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80054b:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  800550:	e9 da 00 00 00       	jmp    80062f <vprintfmt+0x3cb>
		return va_arg(*ap, unsigned long long);
  800555:	8b 45 14             	mov    0x14(%ebp),%eax
  800558:	8b 10                	mov    (%eax),%edx
  80055a:	8b 48 04             	mov    0x4(%eax),%ecx
  80055d:	8d 40 08             	lea    0x8(%eax),%eax
  800560:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800563:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  800568:	e9 c2 00 00 00       	jmp    80062f <vprintfmt+0x3cb>
		return va_arg(*ap, unsigned int);
  80056d:	8b 45 14             	mov    0x14(%ebp),%eax
  800570:	8b 10                	mov    (%eax),%edx
  800572:	b9 00 00 00 00       	mov    $0x0,%ecx
  800577:	8d 40 04             	lea    0x4(%eax),%eax
  80057a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80057d:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  800582:	e9 a8 00 00 00       	jmp    80062f <vprintfmt+0x3cb>
	if (lflag >= 2)
  800587:	83 f9 01             	cmp    $0x1,%ecx
  80058a:	7f 1b                	jg     8005a7 <vprintfmt+0x343>
	else if (lflag)
  80058c:	85 c9                	test   %ecx,%ecx
  80058e:	74 5c                	je     8005ec <vprintfmt+0x388>
		return va_arg(*ap, long);
  800590:	8b 45 14             	mov    0x14(%ebp),%eax
  800593:	8b 00                	mov    (%eax),%eax
  800595:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800598:	99                   	cltd   
  800599:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80059c:	8b 45 14             	mov    0x14(%ebp),%eax
  80059f:	8d 40 04             	lea    0x4(%eax),%eax
  8005a2:	89 45 14             	mov    %eax,0x14(%ebp)
  8005a5:	eb 17                	jmp    8005be <vprintfmt+0x35a>
		return va_arg(*ap, long long);
  8005a7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005aa:	8b 50 04             	mov    0x4(%eax),%edx
  8005ad:	8b 00                	mov    (%eax),%eax
  8005af:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005b2:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b8:	8d 40 08             	lea    0x8(%eax),%eax
  8005bb:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8005be:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005c1:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 8;
  8005c4:	b8 08 00 00 00       	mov    $0x8,%eax
			if ((long long) num < 0) {
  8005c9:	85 c9                	test   %ecx,%ecx
  8005cb:	79 62                	jns    80062f <vprintfmt+0x3cb>
				putch('-', putdat);
  8005cd:	83 ec 08             	sub    $0x8,%esp
  8005d0:	53                   	push   %ebx
  8005d1:	6a 2d                	push   $0x2d
  8005d3:	ff d6                	call   *%esi
				num = -(long long) num;
  8005d5:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005d8:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005db:	f7 da                	neg    %edx
  8005dd:	83 d1 00             	adc    $0x0,%ecx
  8005e0:	f7 d9                	neg    %ecx
  8005e2:	83 c4 10             	add    $0x10,%esp
			base = 8;
  8005e5:	b8 08 00 00 00       	mov    $0x8,%eax
  8005ea:	eb 43                	jmp    80062f <vprintfmt+0x3cb>
		return va_arg(*ap, int);
  8005ec:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ef:	8b 00                	mov    (%eax),%eax
  8005f1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005f4:	89 c1                	mov    %eax,%ecx
  8005f6:	c1 f9 1f             	sar    $0x1f,%ecx
  8005f9:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005fc:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ff:	8d 40 04             	lea    0x4(%eax),%eax
  800602:	89 45 14             	mov    %eax,0x14(%ebp)
  800605:	eb b7                	jmp    8005be <vprintfmt+0x35a>
			putch('0', putdat);
  800607:	83 ec 08             	sub    $0x8,%esp
  80060a:	53                   	push   %ebx
  80060b:	6a 30                	push   $0x30
  80060d:	ff d6                	call   *%esi
			putch('x', putdat);
  80060f:	83 c4 08             	add    $0x8,%esp
  800612:	53                   	push   %ebx
  800613:	6a 78                	push   $0x78
  800615:	ff d6                	call   *%esi
			num = (unsigned long long)
  800617:	8b 45 14             	mov    0x14(%ebp),%eax
  80061a:	8b 10                	mov    (%eax),%edx
  80061c:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800621:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800624:	8d 40 04             	lea    0x4(%eax),%eax
  800627:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80062a:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  80062f:	83 ec 0c             	sub    $0xc,%esp
  800632:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  800636:	57                   	push   %edi
  800637:	ff 75 e0             	pushl  -0x20(%ebp)
  80063a:	50                   	push   %eax
  80063b:	51                   	push   %ecx
  80063c:	52                   	push   %edx
  80063d:	89 da                	mov    %ebx,%edx
  80063f:	89 f0                	mov    %esi,%eax
  800641:	e8 33 fb ff ff       	call   800179 <printnum>
			break;
  800646:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  800649:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80064c:	83 c7 01             	add    $0x1,%edi
  80064f:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800653:	83 f8 25             	cmp    $0x25,%eax
  800656:	0f 84 23 fc ff ff    	je     80027f <vprintfmt+0x1b>
			if (ch == '\0')
  80065c:	85 c0                	test   %eax,%eax
  80065e:	0f 84 8b 00 00 00    	je     8006ef <vprintfmt+0x48b>
			putch(ch, putdat);
  800664:	83 ec 08             	sub    $0x8,%esp
  800667:	53                   	push   %ebx
  800668:	50                   	push   %eax
  800669:	ff d6                	call   *%esi
  80066b:	83 c4 10             	add    $0x10,%esp
  80066e:	eb dc                	jmp    80064c <vprintfmt+0x3e8>
	if (lflag >= 2)
  800670:	83 f9 01             	cmp    $0x1,%ecx
  800673:	7f 1b                	jg     800690 <vprintfmt+0x42c>
	else if (lflag)
  800675:	85 c9                	test   %ecx,%ecx
  800677:	74 2c                	je     8006a5 <vprintfmt+0x441>
		return va_arg(*ap, unsigned long);
  800679:	8b 45 14             	mov    0x14(%ebp),%eax
  80067c:	8b 10                	mov    (%eax),%edx
  80067e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800683:	8d 40 04             	lea    0x4(%eax),%eax
  800686:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800689:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  80068e:	eb 9f                	jmp    80062f <vprintfmt+0x3cb>
		return va_arg(*ap, unsigned long long);
  800690:	8b 45 14             	mov    0x14(%ebp),%eax
  800693:	8b 10                	mov    (%eax),%edx
  800695:	8b 48 04             	mov    0x4(%eax),%ecx
  800698:	8d 40 08             	lea    0x8(%eax),%eax
  80069b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80069e:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  8006a3:	eb 8a                	jmp    80062f <vprintfmt+0x3cb>
		return va_arg(*ap, unsigned int);
  8006a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a8:	8b 10                	mov    (%eax),%edx
  8006aa:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006af:	8d 40 04             	lea    0x4(%eax),%eax
  8006b2:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006b5:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  8006ba:	e9 70 ff ff ff       	jmp    80062f <vprintfmt+0x3cb>
			putch(ch, putdat);
  8006bf:	83 ec 08             	sub    $0x8,%esp
  8006c2:	53                   	push   %ebx
  8006c3:	6a 25                	push   $0x25
  8006c5:	ff d6                	call   *%esi
			break;
  8006c7:	83 c4 10             	add    $0x10,%esp
  8006ca:	e9 7a ff ff ff       	jmp    800649 <vprintfmt+0x3e5>
			putch('%', putdat);
  8006cf:	83 ec 08             	sub    $0x8,%esp
  8006d2:	53                   	push   %ebx
  8006d3:	6a 25                	push   $0x25
  8006d5:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006d7:	83 c4 10             	add    $0x10,%esp
  8006da:	89 f8                	mov    %edi,%eax
  8006dc:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8006e0:	74 05                	je     8006e7 <vprintfmt+0x483>
  8006e2:	83 e8 01             	sub    $0x1,%eax
  8006e5:	eb f5                	jmp    8006dc <vprintfmt+0x478>
  8006e7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006ea:	e9 5a ff ff ff       	jmp    800649 <vprintfmt+0x3e5>
}
  8006ef:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006f2:	5b                   	pop    %ebx
  8006f3:	5e                   	pop    %esi
  8006f4:	5f                   	pop    %edi
  8006f5:	5d                   	pop    %ebp
  8006f6:	c3                   	ret    

008006f7 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006f7:	f3 0f 1e fb          	endbr32 
  8006fb:	55                   	push   %ebp
  8006fc:	89 e5                	mov    %esp,%ebp
  8006fe:	83 ec 18             	sub    $0x18,%esp
  800701:	8b 45 08             	mov    0x8(%ebp),%eax
  800704:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800707:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80070a:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80070e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800711:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800718:	85 c0                	test   %eax,%eax
  80071a:	74 26                	je     800742 <vsnprintf+0x4b>
  80071c:	85 d2                	test   %edx,%edx
  80071e:	7e 22                	jle    800742 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800720:	ff 75 14             	pushl  0x14(%ebp)
  800723:	ff 75 10             	pushl  0x10(%ebp)
  800726:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800729:	50                   	push   %eax
  80072a:	68 22 02 80 00       	push   $0x800222
  80072f:	e8 30 fb ff ff       	call   800264 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800734:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800737:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80073a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80073d:	83 c4 10             	add    $0x10,%esp
}
  800740:	c9                   	leave  
  800741:	c3                   	ret    
		return -E_INVAL;
  800742:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800747:	eb f7                	jmp    800740 <vsnprintf+0x49>

00800749 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800749:	f3 0f 1e fb          	endbr32 
  80074d:	55                   	push   %ebp
  80074e:	89 e5                	mov    %esp,%ebp
  800750:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800753:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800756:	50                   	push   %eax
  800757:	ff 75 10             	pushl  0x10(%ebp)
  80075a:	ff 75 0c             	pushl  0xc(%ebp)
  80075d:	ff 75 08             	pushl  0x8(%ebp)
  800760:	e8 92 ff ff ff       	call   8006f7 <vsnprintf>
	va_end(ap);

	return rc;
}
  800765:	c9                   	leave  
  800766:	c3                   	ret    

00800767 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800767:	f3 0f 1e fb          	endbr32 
  80076b:	55                   	push   %ebp
  80076c:	89 e5                	mov    %esp,%ebp
  80076e:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800771:	b8 00 00 00 00       	mov    $0x0,%eax
  800776:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80077a:	74 05                	je     800781 <strlen+0x1a>
		n++;
  80077c:	83 c0 01             	add    $0x1,%eax
  80077f:	eb f5                	jmp    800776 <strlen+0xf>
	return n;
}
  800781:	5d                   	pop    %ebp
  800782:	c3                   	ret    

00800783 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800783:	f3 0f 1e fb          	endbr32 
  800787:	55                   	push   %ebp
  800788:	89 e5                	mov    %esp,%ebp
  80078a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80078d:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800790:	b8 00 00 00 00       	mov    $0x0,%eax
  800795:	39 d0                	cmp    %edx,%eax
  800797:	74 0d                	je     8007a6 <strnlen+0x23>
  800799:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80079d:	74 05                	je     8007a4 <strnlen+0x21>
		n++;
  80079f:	83 c0 01             	add    $0x1,%eax
  8007a2:	eb f1                	jmp    800795 <strnlen+0x12>
  8007a4:	89 c2                	mov    %eax,%edx
	return n;
}
  8007a6:	89 d0                	mov    %edx,%eax
  8007a8:	5d                   	pop    %ebp
  8007a9:	c3                   	ret    

008007aa <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007aa:	f3 0f 1e fb          	endbr32 
  8007ae:	55                   	push   %ebp
  8007af:	89 e5                	mov    %esp,%ebp
  8007b1:	53                   	push   %ebx
  8007b2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007b5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007b8:	b8 00 00 00 00       	mov    $0x0,%eax
  8007bd:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8007c1:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8007c4:	83 c0 01             	add    $0x1,%eax
  8007c7:	84 d2                	test   %dl,%dl
  8007c9:	75 f2                	jne    8007bd <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  8007cb:	89 c8                	mov    %ecx,%eax
  8007cd:	5b                   	pop    %ebx
  8007ce:	5d                   	pop    %ebp
  8007cf:	c3                   	ret    

008007d0 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007d0:	f3 0f 1e fb          	endbr32 
  8007d4:	55                   	push   %ebp
  8007d5:	89 e5                	mov    %esp,%ebp
  8007d7:	53                   	push   %ebx
  8007d8:	83 ec 10             	sub    $0x10,%esp
  8007db:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007de:	53                   	push   %ebx
  8007df:	e8 83 ff ff ff       	call   800767 <strlen>
  8007e4:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8007e7:	ff 75 0c             	pushl  0xc(%ebp)
  8007ea:	01 d8                	add    %ebx,%eax
  8007ec:	50                   	push   %eax
  8007ed:	e8 b8 ff ff ff       	call   8007aa <strcpy>
	return dst;
}
  8007f2:	89 d8                	mov    %ebx,%eax
  8007f4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007f7:	c9                   	leave  
  8007f8:	c3                   	ret    

008007f9 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007f9:	f3 0f 1e fb          	endbr32 
  8007fd:	55                   	push   %ebp
  8007fe:	89 e5                	mov    %esp,%ebp
  800800:	56                   	push   %esi
  800801:	53                   	push   %ebx
  800802:	8b 75 08             	mov    0x8(%ebp),%esi
  800805:	8b 55 0c             	mov    0xc(%ebp),%edx
  800808:	89 f3                	mov    %esi,%ebx
  80080a:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80080d:	89 f0                	mov    %esi,%eax
  80080f:	39 d8                	cmp    %ebx,%eax
  800811:	74 11                	je     800824 <strncpy+0x2b>
		*dst++ = *src;
  800813:	83 c0 01             	add    $0x1,%eax
  800816:	0f b6 0a             	movzbl (%edx),%ecx
  800819:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80081c:	80 f9 01             	cmp    $0x1,%cl
  80081f:	83 da ff             	sbb    $0xffffffff,%edx
  800822:	eb eb                	jmp    80080f <strncpy+0x16>
	}
	return ret;
}
  800824:	89 f0                	mov    %esi,%eax
  800826:	5b                   	pop    %ebx
  800827:	5e                   	pop    %esi
  800828:	5d                   	pop    %ebp
  800829:	c3                   	ret    

0080082a <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80082a:	f3 0f 1e fb          	endbr32 
  80082e:	55                   	push   %ebp
  80082f:	89 e5                	mov    %esp,%ebp
  800831:	56                   	push   %esi
  800832:	53                   	push   %ebx
  800833:	8b 75 08             	mov    0x8(%ebp),%esi
  800836:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800839:	8b 55 10             	mov    0x10(%ebp),%edx
  80083c:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80083e:	85 d2                	test   %edx,%edx
  800840:	74 21                	je     800863 <strlcpy+0x39>
  800842:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800846:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  800848:	39 c2                	cmp    %eax,%edx
  80084a:	74 14                	je     800860 <strlcpy+0x36>
  80084c:	0f b6 19             	movzbl (%ecx),%ebx
  80084f:	84 db                	test   %bl,%bl
  800851:	74 0b                	je     80085e <strlcpy+0x34>
			*dst++ = *src++;
  800853:	83 c1 01             	add    $0x1,%ecx
  800856:	83 c2 01             	add    $0x1,%edx
  800859:	88 5a ff             	mov    %bl,-0x1(%edx)
  80085c:	eb ea                	jmp    800848 <strlcpy+0x1e>
  80085e:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800860:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800863:	29 f0                	sub    %esi,%eax
}
  800865:	5b                   	pop    %ebx
  800866:	5e                   	pop    %esi
  800867:	5d                   	pop    %ebp
  800868:	c3                   	ret    

00800869 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800869:	f3 0f 1e fb          	endbr32 
  80086d:	55                   	push   %ebp
  80086e:	89 e5                	mov    %esp,%ebp
  800870:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800873:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800876:	0f b6 01             	movzbl (%ecx),%eax
  800879:	84 c0                	test   %al,%al
  80087b:	74 0c                	je     800889 <strcmp+0x20>
  80087d:	3a 02                	cmp    (%edx),%al
  80087f:	75 08                	jne    800889 <strcmp+0x20>
		p++, q++;
  800881:	83 c1 01             	add    $0x1,%ecx
  800884:	83 c2 01             	add    $0x1,%edx
  800887:	eb ed                	jmp    800876 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800889:	0f b6 c0             	movzbl %al,%eax
  80088c:	0f b6 12             	movzbl (%edx),%edx
  80088f:	29 d0                	sub    %edx,%eax
}
  800891:	5d                   	pop    %ebp
  800892:	c3                   	ret    

00800893 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800893:	f3 0f 1e fb          	endbr32 
  800897:	55                   	push   %ebp
  800898:	89 e5                	mov    %esp,%ebp
  80089a:	53                   	push   %ebx
  80089b:	8b 45 08             	mov    0x8(%ebp),%eax
  80089e:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008a1:	89 c3                	mov    %eax,%ebx
  8008a3:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008a6:	eb 06                	jmp    8008ae <strncmp+0x1b>
		n--, p++, q++;
  8008a8:	83 c0 01             	add    $0x1,%eax
  8008ab:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8008ae:	39 d8                	cmp    %ebx,%eax
  8008b0:	74 16                	je     8008c8 <strncmp+0x35>
  8008b2:	0f b6 08             	movzbl (%eax),%ecx
  8008b5:	84 c9                	test   %cl,%cl
  8008b7:	74 04                	je     8008bd <strncmp+0x2a>
  8008b9:	3a 0a                	cmp    (%edx),%cl
  8008bb:	74 eb                	je     8008a8 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008bd:	0f b6 00             	movzbl (%eax),%eax
  8008c0:	0f b6 12             	movzbl (%edx),%edx
  8008c3:	29 d0                	sub    %edx,%eax
}
  8008c5:	5b                   	pop    %ebx
  8008c6:	5d                   	pop    %ebp
  8008c7:	c3                   	ret    
		return 0;
  8008c8:	b8 00 00 00 00       	mov    $0x0,%eax
  8008cd:	eb f6                	jmp    8008c5 <strncmp+0x32>

008008cf <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008cf:	f3 0f 1e fb          	endbr32 
  8008d3:	55                   	push   %ebp
  8008d4:	89 e5                	mov    %esp,%ebp
  8008d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008dd:	0f b6 10             	movzbl (%eax),%edx
  8008e0:	84 d2                	test   %dl,%dl
  8008e2:	74 09                	je     8008ed <strchr+0x1e>
		if (*s == c)
  8008e4:	38 ca                	cmp    %cl,%dl
  8008e6:	74 0a                	je     8008f2 <strchr+0x23>
	for (; *s; s++)
  8008e8:	83 c0 01             	add    $0x1,%eax
  8008eb:	eb f0                	jmp    8008dd <strchr+0xe>
			return (char *) s;
	return 0;
  8008ed:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008f2:	5d                   	pop    %ebp
  8008f3:	c3                   	ret    

008008f4 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008f4:	f3 0f 1e fb          	endbr32 
  8008f8:	55                   	push   %ebp
  8008f9:	89 e5                	mov    %esp,%ebp
  8008fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8008fe:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800902:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800905:	38 ca                	cmp    %cl,%dl
  800907:	74 09                	je     800912 <strfind+0x1e>
  800909:	84 d2                	test   %dl,%dl
  80090b:	74 05                	je     800912 <strfind+0x1e>
	for (; *s; s++)
  80090d:	83 c0 01             	add    $0x1,%eax
  800910:	eb f0                	jmp    800902 <strfind+0xe>
			break;
	return (char *) s;
}
  800912:	5d                   	pop    %ebp
  800913:	c3                   	ret    

00800914 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800914:	f3 0f 1e fb          	endbr32 
  800918:	55                   	push   %ebp
  800919:	89 e5                	mov    %esp,%ebp
  80091b:	57                   	push   %edi
  80091c:	56                   	push   %esi
  80091d:	53                   	push   %ebx
  80091e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800921:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800924:	85 c9                	test   %ecx,%ecx
  800926:	74 31                	je     800959 <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800928:	89 f8                	mov    %edi,%eax
  80092a:	09 c8                	or     %ecx,%eax
  80092c:	a8 03                	test   $0x3,%al
  80092e:	75 23                	jne    800953 <memset+0x3f>
		c &= 0xFF;
  800930:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800934:	89 d3                	mov    %edx,%ebx
  800936:	c1 e3 08             	shl    $0x8,%ebx
  800939:	89 d0                	mov    %edx,%eax
  80093b:	c1 e0 18             	shl    $0x18,%eax
  80093e:	89 d6                	mov    %edx,%esi
  800940:	c1 e6 10             	shl    $0x10,%esi
  800943:	09 f0                	or     %esi,%eax
  800945:	09 c2                	or     %eax,%edx
  800947:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800949:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  80094c:	89 d0                	mov    %edx,%eax
  80094e:	fc                   	cld    
  80094f:	f3 ab                	rep stos %eax,%es:(%edi)
  800951:	eb 06                	jmp    800959 <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800953:	8b 45 0c             	mov    0xc(%ebp),%eax
  800956:	fc                   	cld    
  800957:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800959:	89 f8                	mov    %edi,%eax
  80095b:	5b                   	pop    %ebx
  80095c:	5e                   	pop    %esi
  80095d:	5f                   	pop    %edi
  80095e:	5d                   	pop    %ebp
  80095f:	c3                   	ret    

00800960 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800960:	f3 0f 1e fb          	endbr32 
  800964:	55                   	push   %ebp
  800965:	89 e5                	mov    %esp,%ebp
  800967:	57                   	push   %edi
  800968:	56                   	push   %esi
  800969:	8b 45 08             	mov    0x8(%ebp),%eax
  80096c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80096f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800972:	39 c6                	cmp    %eax,%esi
  800974:	73 32                	jae    8009a8 <memmove+0x48>
  800976:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800979:	39 c2                	cmp    %eax,%edx
  80097b:	76 2b                	jbe    8009a8 <memmove+0x48>
		s += n;
		d += n;
  80097d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800980:	89 fe                	mov    %edi,%esi
  800982:	09 ce                	or     %ecx,%esi
  800984:	09 d6                	or     %edx,%esi
  800986:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80098c:	75 0e                	jne    80099c <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80098e:	83 ef 04             	sub    $0x4,%edi
  800991:	8d 72 fc             	lea    -0x4(%edx),%esi
  800994:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800997:	fd                   	std    
  800998:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80099a:	eb 09                	jmp    8009a5 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80099c:	83 ef 01             	sub    $0x1,%edi
  80099f:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8009a2:	fd                   	std    
  8009a3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009a5:	fc                   	cld    
  8009a6:	eb 1a                	jmp    8009c2 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009a8:	89 c2                	mov    %eax,%edx
  8009aa:	09 ca                	or     %ecx,%edx
  8009ac:	09 f2                	or     %esi,%edx
  8009ae:	f6 c2 03             	test   $0x3,%dl
  8009b1:	75 0a                	jne    8009bd <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009b3:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8009b6:	89 c7                	mov    %eax,%edi
  8009b8:	fc                   	cld    
  8009b9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009bb:	eb 05                	jmp    8009c2 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  8009bd:	89 c7                	mov    %eax,%edi
  8009bf:	fc                   	cld    
  8009c0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009c2:	5e                   	pop    %esi
  8009c3:	5f                   	pop    %edi
  8009c4:	5d                   	pop    %ebp
  8009c5:	c3                   	ret    

008009c6 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009c6:	f3 0f 1e fb          	endbr32 
  8009ca:	55                   	push   %ebp
  8009cb:	89 e5                	mov    %esp,%ebp
  8009cd:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009d0:	ff 75 10             	pushl  0x10(%ebp)
  8009d3:	ff 75 0c             	pushl  0xc(%ebp)
  8009d6:	ff 75 08             	pushl  0x8(%ebp)
  8009d9:	e8 82 ff ff ff       	call   800960 <memmove>
}
  8009de:	c9                   	leave  
  8009df:	c3                   	ret    

008009e0 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009e0:	f3 0f 1e fb          	endbr32 
  8009e4:	55                   	push   %ebp
  8009e5:	89 e5                	mov    %esp,%ebp
  8009e7:	56                   	push   %esi
  8009e8:	53                   	push   %ebx
  8009e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ec:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009ef:	89 c6                	mov    %eax,%esi
  8009f1:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009f4:	39 f0                	cmp    %esi,%eax
  8009f6:	74 1c                	je     800a14 <memcmp+0x34>
		if (*s1 != *s2)
  8009f8:	0f b6 08             	movzbl (%eax),%ecx
  8009fb:	0f b6 1a             	movzbl (%edx),%ebx
  8009fe:	38 d9                	cmp    %bl,%cl
  800a00:	75 08                	jne    800a0a <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800a02:	83 c0 01             	add    $0x1,%eax
  800a05:	83 c2 01             	add    $0x1,%edx
  800a08:	eb ea                	jmp    8009f4 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800a0a:	0f b6 c1             	movzbl %cl,%eax
  800a0d:	0f b6 db             	movzbl %bl,%ebx
  800a10:	29 d8                	sub    %ebx,%eax
  800a12:	eb 05                	jmp    800a19 <memcmp+0x39>
	}

	return 0;
  800a14:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a19:	5b                   	pop    %ebx
  800a1a:	5e                   	pop    %esi
  800a1b:	5d                   	pop    %ebp
  800a1c:	c3                   	ret    

00800a1d <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a1d:	f3 0f 1e fb          	endbr32 
  800a21:	55                   	push   %ebp
  800a22:	89 e5                	mov    %esp,%ebp
  800a24:	8b 45 08             	mov    0x8(%ebp),%eax
  800a27:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a2a:	89 c2                	mov    %eax,%edx
  800a2c:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a2f:	39 d0                	cmp    %edx,%eax
  800a31:	73 09                	jae    800a3c <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a33:	38 08                	cmp    %cl,(%eax)
  800a35:	74 05                	je     800a3c <memfind+0x1f>
	for (; s < ends; s++)
  800a37:	83 c0 01             	add    $0x1,%eax
  800a3a:	eb f3                	jmp    800a2f <memfind+0x12>
			break;
	return (void *) s;
}
  800a3c:	5d                   	pop    %ebp
  800a3d:	c3                   	ret    

00800a3e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a3e:	f3 0f 1e fb          	endbr32 
  800a42:	55                   	push   %ebp
  800a43:	89 e5                	mov    %esp,%ebp
  800a45:	57                   	push   %edi
  800a46:	56                   	push   %esi
  800a47:	53                   	push   %ebx
  800a48:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a4b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a4e:	eb 03                	jmp    800a53 <strtol+0x15>
		s++;
  800a50:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800a53:	0f b6 01             	movzbl (%ecx),%eax
  800a56:	3c 20                	cmp    $0x20,%al
  800a58:	74 f6                	je     800a50 <strtol+0x12>
  800a5a:	3c 09                	cmp    $0x9,%al
  800a5c:	74 f2                	je     800a50 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800a5e:	3c 2b                	cmp    $0x2b,%al
  800a60:	74 2a                	je     800a8c <strtol+0x4e>
	int neg = 0;
  800a62:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800a67:	3c 2d                	cmp    $0x2d,%al
  800a69:	74 2b                	je     800a96 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a6b:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a71:	75 0f                	jne    800a82 <strtol+0x44>
  800a73:	80 39 30             	cmpb   $0x30,(%ecx)
  800a76:	74 28                	je     800aa0 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a78:	85 db                	test   %ebx,%ebx
  800a7a:	b8 0a 00 00 00       	mov    $0xa,%eax
  800a7f:	0f 44 d8             	cmove  %eax,%ebx
  800a82:	b8 00 00 00 00       	mov    $0x0,%eax
  800a87:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a8a:	eb 46                	jmp    800ad2 <strtol+0x94>
		s++;
  800a8c:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800a8f:	bf 00 00 00 00       	mov    $0x0,%edi
  800a94:	eb d5                	jmp    800a6b <strtol+0x2d>
		s++, neg = 1;
  800a96:	83 c1 01             	add    $0x1,%ecx
  800a99:	bf 01 00 00 00       	mov    $0x1,%edi
  800a9e:	eb cb                	jmp    800a6b <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800aa0:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800aa4:	74 0e                	je     800ab4 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800aa6:	85 db                	test   %ebx,%ebx
  800aa8:	75 d8                	jne    800a82 <strtol+0x44>
		s++, base = 8;
  800aaa:	83 c1 01             	add    $0x1,%ecx
  800aad:	bb 08 00 00 00       	mov    $0x8,%ebx
  800ab2:	eb ce                	jmp    800a82 <strtol+0x44>
		s += 2, base = 16;
  800ab4:	83 c1 02             	add    $0x2,%ecx
  800ab7:	bb 10 00 00 00       	mov    $0x10,%ebx
  800abc:	eb c4                	jmp    800a82 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800abe:	0f be d2             	movsbl %dl,%edx
  800ac1:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800ac4:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ac7:	7d 3a                	jge    800b03 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800ac9:	83 c1 01             	add    $0x1,%ecx
  800acc:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ad0:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800ad2:	0f b6 11             	movzbl (%ecx),%edx
  800ad5:	8d 72 d0             	lea    -0x30(%edx),%esi
  800ad8:	89 f3                	mov    %esi,%ebx
  800ada:	80 fb 09             	cmp    $0x9,%bl
  800add:	76 df                	jbe    800abe <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800adf:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ae2:	89 f3                	mov    %esi,%ebx
  800ae4:	80 fb 19             	cmp    $0x19,%bl
  800ae7:	77 08                	ja     800af1 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800ae9:	0f be d2             	movsbl %dl,%edx
  800aec:	83 ea 57             	sub    $0x57,%edx
  800aef:	eb d3                	jmp    800ac4 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800af1:	8d 72 bf             	lea    -0x41(%edx),%esi
  800af4:	89 f3                	mov    %esi,%ebx
  800af6:	80 fb 19             	cmp    $0x19,%bl
  800af9:	77 08                	ja     800b03 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800afb:	0f be d2             	movsbl %dl,%edx
  800afe:	83 ea 37             	sub    $0x37,%edx
  800b01:	eb c1                	jmp    800ac4 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800b03:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b07:	74 05                	je     800b0e <strtol+0xd0>
		*endptr = (char *) s;
  800b09:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b0c:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800b0e:	89 c2                	mov    %eax,%edx
  800b10:	f7 da                	neg    %edx
  800b12:	85 ff                	test   %edi,%edi
  800b14:	0f 45 c2             	cmovne %edx,%eax
}
  800b17:	5b                   	pop    %ebx
  800b18:	5e                   	pop    %esi
  800b19:	5f                   	pop    %edi
  800b1a:	5d                   	pop    %ebp
  800b1b:	c3                   	ret    

00800b1c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b1c:	f3 0f 1e fb          	endbr32 
  800b20:	55                   	push   %ebp
  800b21:	89 e5                	mov    %esp,%ebp
  800b23:	57                   	push   %edi
  800b24:	56                   	push   %esi
  800b25:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b26:	b8 00 00 00 00       	mov    $0x0,%eax
  800b2b:	8b 55 08             	mov    0x8(%ebp),%edx
  800b2e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b31:	89 c3                	mov    %eax,%ebx
  800b33:	89 c7                	mov    %eax,%edi
  800b35:	89 c6                	mov    %eax,%esi
  800b37:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b39:	5b                   	pop    %ebx
  800b3a:	5e                   	pop    %esi
  800b3b:	5f                   	pop    %edi
  800b3c:	5d                   	pop    %ebp
  800b3d:	c3                   	ret    

00800b3e <sys_cgetc>:

int
sys_cgetc(void)
{
  800b3e:	f3 0f 1e fb          	endbr32 
  800b42:	55                   	push   %ebp
  800b43:	89 e5                	mov    %esp,%ebp
  800b45:	57                   	push   %edi
  800b46:	56                   	push   %esi
  800b47:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b48:	ba 00 00 00 00       	mov    $0x0,%edx
  800b4d:	b8 01 00 00 00       	mov    $0x1,%eax
  800b52:	89 d1                	mov    %edx,%ecx
  800b54:	89 d3                	mov    %edx,%ebx
  800b56:	89 d7                	mov    %edx,%edi
  800b58:	89 d6                	mov    %edx,%esi
  800b5a:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b5c:	5b                   	pop    %ebx
  800b5d:	5e                   	pop    %esi
  800b5e:	5f                   	pop    %edi
  800b5f:	5d                   	pop    %ebp
  800b60:	c3                   	ret    

00800b61 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b61:	f3 0f 1e fb          	endbr32 
  800b65:	55                   	push   %ebp
  800b66:	89 e5                	mov    %esp,%ebp
  800b68:	57                   	push   %edi
  800b69:	56                   	push   %esi
  800b6a:	53                   	push   %ebx
  800b6b:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b6e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b73:	8b 55 08             	mov    0x8(%ebp),%edx
  800b76:	b8 03 00 00 00       	mov    $0x3,%eax
  800b7b:	89 cb                	mov    %ecx,%ebx
  800b7d:	89 cf                	mov    %ecx,%edi
  800b7f:	89 ce                	mov    %ecx,%esi
  800b81:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b83:	85 c0                	test   %eax,%eax
  800b85:	7f 08                	jg     800b8f <sys_env_destroy+0x2e>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b87:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b8a:	5b                   	pop    %ebx
  800b8b:	5e                   	pop    %esi
  800b8c:	5f                   	pop    %edi
  800b8d:	5d                   	pop    %ebp
  800b8e:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b8f:	83 ec 0c             	sub    $0xc,%esp
  800b92:	50                   	push   %eax
  800b93:	6a 03                	push   $0x3
  800b95:	68 e4 12 80 00       	push   $0x8012e4
  800b9a:	6a 23                	push   $0x23
  800b9c:	68 01 13 80 00       	push   $0x801301
  800ba1:	e8 11 02 00 00       	call   800db7 <_panic>

00800ba6 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ba6:	f3 0f 1e fb          	endbr32 
  800baa:	55                   	push   %ebp
  800bab:	89 e5                	mov    %esp,%ebp
  800bad:	57                   	push   %edi
  800bae:	56                   	push   %esi
  800baf:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bb0:	ba 00 00 00 00       	mov    $0x0,%edx
  800bb5:	b8 02 00 00 00       	mov    $0x2,%eax
  800bba:	89 d1                	mov    %edx,%ecx
  800bbc:	89 d3                	mov    %edx,%ebx
  800bbe:	89 d7                	mov    %edx,%edi
  800bc0:	89 d6                	mov    %edx,%esi
  800bc2:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bc4:	5b                   	pop    %ebx
  800bc5:	5e                   	pop    %esi
  800bc6:	5f                   	pop    %edi
  800bc7:	5d                   	pop    %ebp
  800bc8:	c3                   	ret    

00800bc9 <sys_yield>:

void
sys_yield(void)
{
  800bc9:	f3 0f 1e fb          	endbr32 
  800bcd:	55                   	push   %ebp
  800bce:	89 e5                	mov    %esp,%ebp
  800bd0:	57                   	push   %edi
  800bd1:	56                   	push   %esi
  800bd2:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bd3:	ba 00 00 00 00       	mov    $0x0,%edx
  800bd8:	b8 0a 00 00 00       	mov    $0xa,%eax
  800bdd:	89 d1                	mov    %edx,%ecx
  800bdf:	89 d3                	mov    %edx,%ebx
  800be1:	89 d7                	mov    %edx,%edi
  800be3:	89 d6                	mov    %edx,%esi
  800be5:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800be7:	5b                   	pop    %ebx
  800be8:	5e                   	pop    %esi
  800be9:	5f                   	pop    %edi
  800bea:	5d                   	pop    %ebp
  800beb:	c3                   	ret    

00800bec <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bec:	f3 0f 1e fb          	endbr32 
  800bf0:	55                   	push   %ebp
  800bf1:	89 e5                	mov    %esp,%ebp
  800bf3:	57                   	push   %edi
  800bf4:	56                   	push   %esi
  800bf5:	53                   	push   %ebx
  800bf6:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800bf9:	be 00 00 00 00       	mov    $0x0,%esi
  800bfe:	8b 55 08             	mov    0x8(%ebp),%edx
  800c01:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c04:	b8 04 00 00 00       	mov    $0x4,%eax
  800c09:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c0c:	89 f7                	mov    %esi,%edi
  800c0e:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c10:	85 c0                	test   %eax,%eax
  800c12:	7f 08                	jg     800c1c <sys_page_alloc+0x30>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c14:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c17:	5b                   	pop    %ebx
  800c18:	5e                   	pop    %esi
  800c19:	5f                   	pop    %edi
  800c1a:	5d                   	pop    %ebp
  800c1b:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c1c:	83 ec 0c             	sub    $0xc,%esp
  800c1f:	50                   	push   %eax
  800c20:	6a 04                	push   $0x4
  800c22:	68 e4 12 80 00       	push   $0x8012e4
  800c27:	6a 23                	push   $0x23
  800c29:	68 01 13 80 00       	push   $0x801301
  800c2e:	e8 84 01 00 00       	call   800db7 <_panic>

00800c33 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c33:	f3 0f 1e fb          	endbr32 
  800c37:	55                   	push   %ebp
  800c38:	89 e5                	mov    %esp,%ebp
  800c3a:	57                   	push   %edi
  800c3b:	56                   	push   %esi
  800c3c:	53                   	push   %ebx
  800c3d:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c40:	8b 55 08             	mov    0x8(%ebp),%edx
  800c43:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c46:	b8 05 00 00 00       	mov    $0x5,%eax
  800c4b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c4e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c51:	8b 75 18             	mov    0x18(%ebp),%esi
  800c54:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c56:	85 c0                	test   %eax,%eax
  800c58:	7f 08                	jg     800c62 <sys_page_map+0x2f>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c5a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c5d:	5b                   	pop    %ebx
  800c5e:	5e                   	pop    %esi
  800c5f:	5f                   	pop    %edi
  800c60:	5d                   	pop    %ebp
  800c61:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c62:	83 ec 0c             	sub    $0xc,%esp
  800c65:	50                   	push   %eax
  800c66:	6a 05                	push   $0x5
  800c68:	68 e4 12 80 00       	push   $0x8012e4
  800c6d:	6a 23                	push   $0x23
  800c6f:	68 01 13 80 00       	push   $0x801301
  800c74:	e8 3e 01 00 00       	call   800db7 <_panic>

00800c79 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c79:	f3 0f 1e fb          	endbr32 
  800c7d:	55                   	push   %ebp
  800c7e:	89 e5                	mov    %esp,%ebp
  800c80:	57                   	push   %edi
  800c81:	56                   	push   %esi
  800c82:	53                   	push   %ebx
  800c83:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c86:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c8b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c8e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c91:	b8 06 00 00 00       	mov    $0x6,%eax
  800c96:	89 df                	mov    %ebx,%edi
  800c98:	89 de                	mov    %ebx,%esi
  800c9a:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c9c:	85 c0                	test   %eax,%eax
  800c9e:	7f 08                	jg     800ca8 <sys_page_unmap+0x2f>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800ca0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ca3:	5b                   	pop    %ebx
  800ca4:	5e                   	pop    %esi
  800ca5:	5f                   	pop    %edi
  800ca6:	5d                   	pop    %ebp
  800ca7:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca8:	83 ec 0c             	sub    $0xc,%esp
  800cab:	50                   	push   %eax
  800cac:	6a 06                	push   $0x6
  800cae:	68 e4 12 80 00       	push   $0x8012e4
  800cb3:	6a 23                	push   $0x23
  800cb5:	68 01 13 80 00       	push   $0x801301
  800cba:	e8 f8 00 00 00       	call   800db7 <_panic>

00800cbf <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cbf:	f3 0f 1e fb          	endbr32 
  800cc3:	55                   	push   %ebp
  800cc4:	89 e5                	mov    %esp,%ebp
  800cc6:	57                   	push   %edi
  800cc7:	56                   	push   %esi
  800cc8:	53                   	push   %ebx
  800cc9:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800ccc:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cd1:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd7:	b8 08 00 00 00       	mov    $0x8,%eax
  800cdc:	89 df                	mov    %ebx,%edi
  800cde:	89 de                	mov    %ebx,%esi
  800ce0:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ce2:	85 c0                	test   %eax,%eax
  800ce4:	7f 08                	jg     800cee <sys_env_set_status+0x2f>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800ce6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ce9:	5b                   	pop    %ebx
  800cea:	5e                   	pop    %esi
  800ceb:	5f                   	pop    %edi
  800cec:	5d                   	pop    %ebp
  800ced:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cee:	83 ec 0c             	sub    $0xc,%esp
  800cf1:	50                   	push   %eax
  800cf2:	6a 08                	push   $0x8
  800cf4:	68 e4 12 80 00       	push   $0x8012e4
  800cf9:	6a 23                	push   $0x23
  800cfb:	68 01 13 80 00       	push   $0x801301
  800d00:	e8 b2 00 00 00       	call   800db7 <_panic>

00800d05 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d05:	f3 0f 1e fb          	endbr32 
  800d09:	55                   	push   %ebp
  800d0a:	89 e5                	mov    %esp,%ebp
  800d0c:	57                   	push   %edi
  800d0d:	56                   	push   %esi
  800d0e:	53                   	push   %ebx
  800d0f:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d12:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d17:	8b 55 08             	mov    0x8(%ebp),%edx
  800d1a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d1d:	b8 09 00 00 00       	mov    $0x9,%eax
  800d22:	89 df                	mov    %ebx,%edi
  800d24:	89 de                	mov    %ebx,%esi
  800d26:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d28:	85 c0                	test   %eax,%eax
  800d2a:	7f 08                	jg     800d34 <sys_env_set_pgfault_upcall+0x2f>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d2c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d2f:	5b                   	pop    %ebx
  800d30:	5e                   	pop    %esi
  800d31:	5f                   	pop    %edi
  800d32:	5d                   	pop    %ebp
  800d33:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d34:	83 ec 0c             	sub    $0xc,%esp
  800d37:	50                   	push   %eax
  800d38:	6a 09                	push   $0x9
  800d3a:	68 e4 12 80 00       	push   $0x8012e4
  800d3f:	6a 23                	push   $0x23
  800d41:	68 01 13 80 00       	push   $0x801301
  800d46:	e8 6c 00 00 00       	call   800db7 <_panic>

00800d4b <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d4b:	f3 0f 1e fb          	endbr32 
  800d4f:	55                   	push   %ebp
  800d50:	89 e5                	mov    %esp,%ebp
  800d52:	57                   	push   %edi
  800d53:	56                   	push   %esi
  800d54:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d55:	8b 55 08             	mov    0x8(%ebp),%edx
  800d58:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d5b:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d60:	be 00 00 00 00       	mov    $0x0,%esi
  800d65:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d68:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d6b:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d6d:	5b                   	pop    %ebx
  800d6e:	5e                   	pop    %esi
  800d6f:	5f                   	pop    %edi
  800d70:	5d                   	pop    %ebp
  800d71:	c3                   	ret    

00800d72 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d72:	f3 0f 1e fb          	endbr32 
  800d76:	55                   	push   %ebp
  800d77:	89 e5                	mov    %esp,%ebp
  800d79:	57                   	push   %edi
  800d7a:	56                   	push   %esi
  800d7b:	53                   	push   %ebx
  800d7c:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d7f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d84:	8b 55 08             	mov    0x8(%ebp),%edx
  800d87:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d8c:	89 cb                	mov    %ecx,%ebx
  800d8e:	89 cf                	mov    %ecx,%edi
  800d90:	89 ce                	mov    %ecx,%esi
  800d92:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d94:	85 c0                	test   %eax,%eax
  800d96:	7f 08                	jg     800da0 <sys_ipc_recv+0x2e>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d98:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d9b:	5b                   	pop    %ebx
  800d9c:	5e                   	pop    %esi
  800d9d:	5f                   	pop    %edi
  800d9e:	5d                   	pop    %ebp
  800d9f:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800da0:	83 ec 0c             	sub    $0xc,%esp
  800da3:	50                   	push   %eax
  800da4:	6a 0c                	push   $0xc
  800da6:	68 e4 12 80 00       	push   $0x8012e4
  800dab:	6a 23                	push   $0x23
  800dad:	68 01 13 80 00       	push   $0x801301
  800db2:	e8 00 00 00 00       	call   800db7 <_panic>

00800db7 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800db7:	f3 0f 1e fb          	endbr32 
  800dbb:	55                   	push   %ebp
  800dbc:	89 e5                	mov    %esp,%ebp
  800dbe:	56                   	push   %esi
  800dbf:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800dc0:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800dc3:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800dc9:	e8 d8 fd ff ff       	call   800ba6 <sys_getenvid>
  800dce:	83 ec 0c             	sub    $0xc,%esp
  800dd1:	ff 75 0c             	pushl  0xc(%ebp)
  800dd4:	ff 75 08             	pushl  0x8(%ebp)
  800dd7:	56                   	push   %esi
  800dd8:	50                   	push   %eax
  800dd9:	68 10 13 80 00       	push   $0x801310
  800dde:	e8 7e f3 ff ff       	call   800161 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800de3:	83 c4 18             	add    $0x18,%esp
  800de6:	53                   	push   %ebx
  800de7:	ff 75 10             	pushl  0x10(%ebp)
  800dea:	e8 1d f3 ff ff       	call   80010c <vcprintf>
	cprintf("\n");
  800def:	c7 04 24 8c 10 80 00 	movl   $0x80108c,(%esp)
  800df6:	e8 66 f3 ff ff       	call   800161 <cprintf>
  800dfb:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800dfe:	cc                   	int3   
  800dff:	eb fd                	jmp    800dfe <_panic+0x47>
  800e01:	66 90                	xchg   %ax,%ax
  800e03:	66 90                	xchg   %ax,%ax
  800e05:	66 90                	xchg   %ax,%ax
  800e07:	66 90                	xchg   %ax,%ax
  800e09:	66 90                	xchg   %ax,%ax
  800e0b:	66 90                	xchg   %ax,%ax
  800e0d:	66 90                	xchg   %ax,%ax
  800e0f:	90                   	nop

00800e10 <__udivdi3>:
  800e10:	f3 0f 1e fb          	endbr32 
  800e14:	55                   	push   %ebp
  800e15:	57                   	push   %edi
  800e16:	56                   	push   %esi
  800e17:	53                   	push   %ebx
  800e18:	83 ec 1c             	sub    $0x1c,%esp
  800e1b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800e1f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800e23:	8b 74 24 34          	mov    0x34(%esp),%esi
  800e27:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800e2b:	85 d2                	test   %edx,%edx
  800e2d:	75 19                	jne    800e48 <__udivdi3+0x38>
  800e2f:	39 f3                	cmp    %esi,%ebx
  800e31:	76 4d                	jbe    800e80 <__udivdi3+0x70>
  800e33:	31 ff                	xor    %edi,%edi
  800e35:	89 e8                	mov    %ebp,%eax
  800e37:	89 f2                	mov    %esi,%edx
  800e39:	f7 f3                	div    %ebx
  800e3b:	89 fa                	mov    %edi,%edx
  800e3d:	83 c4 1c             	add    $0x1c,%esp
  800e40:	5b                   	pop    %ebx
  800e41:	5e                   	pop    %esi
  800e42:	5f                   	pop    %edi
  800e43:	5d                   	pop    %ebp
  800e44:	c3                   	ret    
  800e45:	8d 76 00             	lea    0x0(%esi),%esi
  800e48:	39 f2                	cmp    %esi,%edx
  800e4a:	76 14                	jbe    800e60 <__udivdi3+0x50>
  800e4c:	31 ff                	xor    %edi,%edi
  800e4e:	31 c0                	xor    %eax,%eax
  800e50:	89 fa                	mov    %edi,%edx
  800e52:	83 c4 1c             	add    $0x1c,%esp
  800e55:	5b                   	pop    %ebx
  800e56:	5e                   	pop    %esi
  800e57:	5f                   	pop    %edi
  800e58:	5d                   	pop    %ebp
  800e59:	c3                   	ret    
  800e5a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800e60:	0f bd fa             	bsr    %edx,%edi
  800e63:	83 f7 1f             	xor    $0x1f,%edi
  800e66:	75 48                	jne    800eb0 <__udivdi3+0xa0>
  800e68:	39 f2                	cmp    %esi,%edx
  800e6a:	72 06                	jb     800e72 <__udivdi3+0x62>
  800e6c:	31 c0                	xor    %eax,%eax
  800e6e:	39 eb                	cmp    %ebp,%ebx
  800e70:	77 de                	ja     800e50 <__udivdi3+0x40>
  800e72:	b8 01 00 00 00       	mov    $0x1,%eax
  800e77:	eb d7                	jmp    800e50 <__udivdi3+0x40>
  800e79:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e80:	89 d9                	mov    %ebx,%ecx
  800e82:	85 db                	test   %ebx,%ebx
  800e84:	75 0b                	jne    800e91 <__udivdi3+0x81>
  800e86:	b8 01 00 00 00       	mov    $0x1,%eax
  800e8b:	31 d2                	xor    %edx,%edx
  800e8d:	f7 f3                	div    %ebx
  800e8f:	89 c1                	mov    %eax,%ecx
  800e91:	31 d2                	xor    %edx,%edx
  800e93:	89 f0                	mov    %esi,%eax
  800e95:	f7 f1                	div    %ecx
  800e97:	89 c6                	mov    %eax,%esi
  800e99:	89 e8                	mov    %ebp,%eax
  800e9b:	89 f7                	mov    %esi,%edi
  800e9d:	f7 f1                	div    %ecx
  800e9f:	89 fa                	mov    %edi,%edx
  800ea1:	83 c4 1c             	add    $0x1c,%esp
  800ea4:	5b                   	pop    %ebx
  800ea5:	5e                   	pop    %esi
  800ea6:	5f                   	pop    %edi
  800ea7:	5d                   	pop    %ebp
  800ea8:	c3                   	ret    
  800ea9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800eb0:	89 f9                	mov    %edi,%ecx
  800eb2:	b8 20 00 00 00       	mov    $0x20,%eax
  800eb7:	29 f8                	sub    %edi,%eax
  800eb9:	d3 e2                	shl    %cl,%edx
  800ebb:	89 54 24 08          	mov    %edx,0x8(%esp)
  800ebf:	89 c1                	mov    %eax,%ecx
  800ec1:	89 da                	mov    %ebx,%edx
  800ec3:	d3 ea                	shr    %cl,%edx
  800ec5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800ec9:	09 d1                	or     %edx,%ecx
  800ecb:	89 f2                	mov    %esi,%edx
  800ecd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800ed1:	89 f9                	mov    %edi,%ecx
  800ed3:	d3 e3                	shl    %cl,%ebx
  800ed5:	89 c1                	mov    %eax,%ecx
  800ed7:	d3 ea                	shr    %cl,%edx
  800ed9:	89 f9                	mov    %edi,%ecx
  800edb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800edf:	89 eb                	mov    %ebp,%ebx
  800ee1:	d3 e6                	shl    %cl,%esi
  800ee3:	89 c1                	mov    %eax,%ecx
  800ee5:	d3 eb                	shr    %cl,%ebx
  800ee7:	09 de                	or     %ebx,%esi
  800ee9:	89 f0                	mov    %esi,%eax
  800eeb:	f7 74 24 08          	divl   0x8(%esp)
  800eef:	89 d6                	mov    %edx,%esi
  800ef1:	89 c3                	mov    %eax,%ebx
  800ef3:	f7 64 24 0c          	mull   0xc(%esp)
  800ef7:	39 d6                	cmp    %edx,%esi
  800ef9:	72 15                	jb     800f10 <__udivdi3+0x100>
  800efb:	89 f9                	mov    %edi,%ecx
  800efd:	d3 e5                	shl    %cl,%ebp
  800eff:	39 c5                	cmp    %eax,%ebp
  800f01:	73 04                	jae    800f07 <__udivdi3+0xf7>
  800f03:	39 d6                	cmp    %edx,%esi
  800f05:	74 09                	je     800f10 <__udivdi3+0x100>
  800f07:	89 d8                	mov    %ebx,%eax
  800f09:	31 ff                	xor    %edi,%edi
  800f0b:	e9 40 ff ff ff       	jmp    800e50 <__udivdi3+0x40>
  800f10:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800f13:	31 ff                	xor    %edi,%edi
  800f15:	e9 36 ff ff ff       	jmp    800e50 <__udivdi3+0x40>
  800f1a:	66 90                	xchg   %ax,%ax
  800f1c:	66 90                	xchg   %ax,%ax
  800f1e:	66 90                	xchg   %ax,%ax

00800f20 <__umoddi3>:
  800f20:	f3 0f 1e fb          	endbr32 
  800f24:	55                   	push   %ebp
  800f25:	57                   	push   %edi
  800f26:	56                   	push   %esi
  800f27:	53                   	push   %ebx
  800f28:	83 ec 1c             	sub    $0x1c,%esp
  800f2b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  800f2f:	8b 74 24 30          	mov    0x30(%esp),%esi
  800f33:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800f37:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800f3b:	85 c0                	test   %eax,%eax
  800f3d:	75 19                	jne    800f58 <__umoddi3+0x38>
  800f3f:	39 df                	cmp    %ebx,%edi
  800f41:	76 5d                	jbe    800fa0 <__umoddi3+0x80>
  800f43:	89 f0                	mov    %esi,%eax
  800f45:	89 da                	mov    %ebx,%edx
  800f47:	f7 f7                	div    %edi
  800f49:	89 d0                	mov    %edx,%eax
  800f4b:	31 d2                	xor    %edx,%edx
  800f4d:	83 c4 1c             	add    $0x1c,%esp
  800f50:	5b                   	pop    %ebx
  800f51:	5e                   	pop    %esi
  800f52:	5f                   	pop    %edi
  800f53:	5d                   	pop    %ebp
  800f54:	c3                   	ret    
  800f55:	8d 76 00             	lea    0x0(%esi),%esi
  800f58:	89 f2                	mov    %esi,%edx
  800f5a:	39 d8                	cmp    %ebx,%eax
  800f5c:	76 12                	jbe    800f70 <__umoddi3+0x50>
  800f5e:	89 f0                	mov    %esi,%eax
  800f60:	89 da                	mov    %ebx,%edx
  800f62:	83 c4 1c             	add    $0x1c,%esp
  800f65:	5b                   	pop    %ebx
  800f66:	5e                   	pop    %esi
  800f67:	5f                   	pop    %edi
  800f68:	5d                   	pop    %ebp
  800f69:	c3                   	ret    
  800f6a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800f70:	0f bd e8             	bsr    %eax,%ebp
  800f73:	83 f5 1f             	xor    $0x1f,%ebp
  800f76:	75 50                	jne    800fc8 <__umoddi3+0xa8>
  800f78:	39 d8                	cmp    %ebx,%eax
  800f7a:	0f 82 e0 00 00 00    	jb     801060 <__umoddi3+0x140>
  800f80:	89 d9                	mov    %ebx,%ecx
  800f82:	39 f7                	cmp    %esi,%edi
  800f84:	0f 86 d6 00 00 00    	jbe    801060 <__umoddi3+0x140>
  800f8a:	89 d0                	mov    %edx,%eax
  800f8c:	89 ca                	mov    %ecx,%edx
  800f8e:	83 c4 1c             	add    $0x1c,%esp
  800f91:	5b                   	pop    %ebx
  800f92:	5e                   	pop    %esi
  800f93:	5f                   	pop    %edi
  800f94:	5d                   	pop    %ebp
  800f95:	c3                   	ret    
  800f96:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f9d:	8d 76 00             	lea    0x0(%esi),%esi
  800fa0:	89 fd                	mov    %edi,%ebp
  800fa2:	85 ff                	test   %edi,%edi
  800fa4:	75 0b                	jne    800fb1 <__umoddi3+0x91>
  800fa6:	b8 01 00 00 00       	mov    $0x1,%eax
  800fab:	31 d2                	xor    %edx,%edx
  800fad:	f7 f7                	div    %edi
  800faf:	89 c5                	mov    %eax,%ebp
  800fb1:	89 d8                	mov    %ebx,%eax
  800fb3:	31 d2                	xor    %edx,%edx
  800fb5:	f7 f5                	div    %ebp
  800fb7:	89 f0                	mov    %esi,%eax
  800fb9:	f7 f5                	div    %ebp
  800fbb:	89 d0                	mov    %edx,%eax
  800fbd:	31 d2                	xor    %edx,%edx
  800fbf:	eb 8c                	jmp    800f4d <__umoddi3+0x2d>
  800fc1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800fc8:	89 e9                	mov    %ebp,%ecx
  800fca:	ba 20 00 00 00       	mov    $0x20,%edx
  800fcf:	29 ea                	sub    %ebp,%edx
  800fd1:	d3 e0                	shl    %cl,%eax
  800fd3:	89 44 24 08          	mov    %eax,0x8(%esp)
  800fd7:	89 d1                	mov    %edx,%ecx
  800fd9:	89 f8                	mov    %edi,%eax
  800fdb:	d3 e8                	shr    %cl,%eax
  800fdd:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800fe1:	89 54 24 04          	mov    %edx,0x4(%esp)
  800fe5:	8b 54 24 04          	mov    0x4(%esp),%edx
  800fe9:	09 c1                	or     %eax,%ecx
  800feb:	89 d8                	mov    %ebx,%eax
  800fed:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800ff1:	89 e9                	mov    %ebp,%ecx
  800ff3:	d3 e7                	shl    %cl,%edi
  800ff5:	89 d1                	mov    %edx,%ecx
  800ff7:	d3 e8                	shr    %cl,%eax
  800ff9:	89 e9                	mov    %ebp,%ecx
  800ffb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800fff:	d3 e3                	shl    %cl,%ebx
  801001:	89 c7                	mov    %eax,%edi
  801003:	89 d1                	mov    %edx,%ecx
  801005:	89 f0                	mov    %esi,%eax
  801007:	d3 e8                	shr    %cl,%eax
  801009:	89 e9                	mov    %ebp,%ecx
  80100b:	89 fa                	mov    %edi,%edx
  80100d:	d3 e6                	shl    %cl,%esi
  80100f:	09 d8                	or     %ebx,%eax
  801011:	f7 74 24 08          	divl   0x8(%esp)
  801015:	89 d1                	mov    %edx,%ecx
  801017:	89 f3                	mov    %esi,%ebx
  801019:	f7 64 24 0c          	mull   0xc(%esp)
  80101d:	89 c6                	mov    %eax,%esi
  80101f:	89 d7                	mov    %edx,%edi
  801021:	39 d1                	cmp    %edx,%ecx
  801023:	72 06                	jb     80102b <__umoddi3+0x10b>
  801025:	75 10                	jne    801037 <__umoddi3+0x117>
  801027:	39 c3                	cmp    %eax,%ebx
  801029:	73 0c                	jae    801037 <__umoddi3+0x117>
  80102b:	2b 44 24 0c          	sub    0xc(%esp),%eax
  80102f:	1b 54 24 08          	sbb    0x8(%esp),%edx
  801033:	89 d7                	mov    %edx,%edi
  801035:	89 c6                	mov    %eax,%esi
  801037:	89 ca                	mov    %ecx,%edx
  801039:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80103e:	29 f3                	sub    %esi,%ebx
  801040:	19 fa                	sbb    %edi,%edx
  801042:	89 d0                	mov    %edx,%eax
  801044:	d3 e0                	shl    %cl,%eax
  801046:	89 e9                	mov    %ebp,%ecx
  801048:	d3 eb                	shr    %cl,%ebx
  80104a:	d3 ea                	shr    %cl,%edx
  80104c:	09 d8                	or     %ebx,%eax
  80104e:	83 c4 1c             	add    $0x1c,%esp
  801051:	5b                   	pop    %ebx
  801052:	5e                   	pop    %esi
  801053:	5f                   	pop    %edi
  801054:	5d                   	pop    %ebp
  801055:	c3                   	ret    
  801056:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80105d:	8d 76 00             	lea    0x0(%esi),%esi
  801060:	29 fe                	sub    %edi,%esi
  801062:	19 c3                	sbb    %eax,%ebx
  801064:	89 f2                	mov    %esi,%edx
  801066:	89 d9                	mov    %ebx,%ecx
  801068:	e9 1d ff ff ff       	jmp    800f8a <__umoddi3+0x6a>
