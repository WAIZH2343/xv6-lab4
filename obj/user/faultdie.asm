
obj/user/faultdie:     file format elf32-i386


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
  80002c:	e8 57 00 00 00       	call   800088 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <handler>:

#include <inc/lib.h>

void
handler(struct UTrapframe *utf)
{
  800033:	f3 0f 1e fb          	endbr32 
  800037:	55                   	push   %ebp
  800038:	89 e5                	mov    %esp,%ebp
  80003a:	83 ec 0c             	sub    $0xc,%esp
  80003d:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void*)utf->utf_fault_va;
	uint32_t err = utf->utf_err;
	cprintf("i faulted at va %x, err %x\n", addr, err & 7);
  800040:	8b 42 04             	mov    0x4(%edx),%eax
  800043:	83 e0 07             	and    $0x7,%eax
  800046:	50                   	push   %eax
  800047:	ff 32                	pushl  (%edx)
  800049:	68 20 11 80 00       	push   $0x801120
  80004e:	e8 32 01 00 00       	call   800185 <cprintf>
	sys_env_destroy(sys_getenvid());
  800053:	e8 72 0b 00 00       	call   800bca <sys_getenvid>
  800058:	89 04 24             	mov    %eax,(%esp)
  80005b:	e8 25 0b 00 00       	call   800b85 <sys_env_destroy>
}
  800060:	83 c4 10             	add    $0x10,%esp
  800063:	c9                   	leave  
  800064:	c3                   	ret    

00800065 <umain>:

void
umain(int argc, char **argv)
{
  800065:	f3 0f 1e fb          	endbr32 
  800069:	55                   	push   %ebp
  80006a:	89 e5                	mov    %esp,%ebp
  80006c:	83 ec 14             	sub    $0x14,%esp
	set_pgfault_handler(handler);
  80006f:	68 33 00 80 00       	push   $0x800033
  800074:	e8 62 0d 00 00       	call   800ddb <set_pgfault_handler>
	*(int*)0xDeadBeef = 0;
  800079:	c7 05 ef be ad de 00 	movl   $0x0,0xdeadbeef
  800080:	00 00 00 
}
  800083:	83 c4 10             	add    $0x10,%esp
  800086:	c9                   	leave  
  800087:	c3                   	ret    

00800088 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800088:	f3 0f 1e fb          	endbr32 
  80008c:	55                   	push   %ebp
  80008d:	89 e5                	mov    %esp,%ebp
  80008f:	56                   	push   %esi
  800090:	53                   	push   %ebx
  800091:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800094:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv=&envs[ENVX(sys_getenvid())];
  800097:	e8 2e 0b 00 00       	call   800bca <sys_getenvid>
  80009c:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000a1:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000a4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000a9:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000ae:	85 db                	test   %ebx,%ebx
  8000b0:	7e 07                	jle    8000b9 <libmain+0x31>
		binaryname = argv[0];
  8000b2:	8b 06                	mov    (%esi),%eax
  8000b4:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000b9:	83 ec 08             	sub    $0x8,%esp
  8000bc:	56                   	push   %esi
  8000bd:	53                   	push   %ebx
  8000be:	e8 a2 ff ff ff       	call   800065 <umain>

	// exit gracefully
	exit();
  8000c3:	e8 0a 00 00 00       	call   8000d2 <exit>
}
  8000c8:	83 c4 10             	add    $0x10,%esp
  8000cb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000ce:	5b                   	pop    %ebx
  8000cf:	5e                   	pop    %esi
  8000d0:	5d                   	pop    %ebp
  8000d1:	c3                   	ret    

008000d2 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000d2:	f3 0f 1e fb          	endbr32 
  8000d6:	55                   	push   %ebp
  8000d7:	89 e5                	mov    %esp,%ebp
  8000d9:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000dc:	6a 00                	push   $0x0
  8000de:	e8 a2 0a 00 00       	call   800b85 <sys_env_destroy>
}
  8000e3:	83 c4 10             	add    $0x10,%esp
  8000e6:	c9                   	leave  
  8000e7:	c3                   	ret    

008000e8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000e8:	f3 0f 1e fb          	endbr32 
  8000ec:	55                   	push   %ebp
  8000ed:	89 e5                	mov    %esp,%ebp
  8000ef:	53                   	push   %ebx
  8000f0:	83 ec 04             	sub    $0x4,%esp
  8000f3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000f6:	8b 13                	mov    (%ebx),%edx
  8000f8:	8d 42 01             	lea    0x1(%edx),%eax
  8000fb:	89 03                	mov    %eax,(%ebx)
  8000fd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800100:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800104:	3d ff 00 00 00       	cmp    $0xff,%eax
  800109:	74 09                	je     800114 <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80010b:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80010f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800112:	c9                   	leave  
  800113:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800114:	83 ec 08             	sub    $0x8,%esp
  800117:	68 ff 00 00 00       	push   $0xff
  80011c:	8d 43 08             	lea    0x8(%ebx),%eax
  80011f:	50                   	push   %eax
  800120:	e8 1b 0a 00 00       	call   800b40 <sys_cputs>
		b->idx = 0;
  800125:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80012b:	83 c4 10             	add    $0x10,%esp
  80012e:	eb db                	jmp    80010b <putch+0x23>

00800130 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800130:	f3 0f 1e fb          	endbr32 
  800134:	55                   	push   %ebp
  800135:	89 e5                	mov    %esp,%ebp
  800137:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80013d:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800144:	00 00 00 
	b.cnt = 0;
  800147:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80014e:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800151:	ff 75 0c             	pushl  0xc(%ebp)
  800154:	ff 75 08             	pushl  0x8(%ebp)
  800157:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80015d:	50                   	push   %eax
  80015e:	68 e8 00 80 00       	push   $0x8000e8
  800163:	e8 20 01 00 00       	call   800288 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800168:	83 c4 08             	add    $0x8,%esp
  80016b:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800171:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800177:	50                   	push   %eax
  800178:	e8 c3 09 00 00       	call   800b40 <sys_cputs>

	return b.cnt;
}
  80017d:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800183:	c9                   	leave  
  800184:	c3                   	ret    

00800185 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800185:	f3 0f 1e fb          	endbr32 
  800189:	55                   	push   %ebp
  80018a:	89 e5                	mov    %esp,%ebp
  80018c:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80018f:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800192:	50                   	push   %eax
  800193:	ff 75 08             	pushl  0x8(%ebp)
  800196:	e8 95 ff ff ff       	call   800130 <vcprintf>
	va_end(ap);

	return cnt;
}
  80019b:	c9                   	leave  
  80019c:	c3                   	ret    

0080019d <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80019d:	55                   	push   %ebp
  80019e:	89 e5                	mov    %esp,%ebp
  8001a0:	57                   	push   %edi
  8001a1:	56                   	push   %esi
  8001a2:	53                   	push   %ebx
  8001a3:	83 ec 1c             	sub    $0x1c,%esp
  8001a6:	89 c7                	mov    %eax,%edi
  8001a8:	89 d6                	mov    %edx,%esi
  8001aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8001ad:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001b0:	89 d1                	mov    %edx,%ecx
  8001b2:	89 c2                	mov    %eax,%edx
  8001b4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001b7:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8001ba:	8b 45 10             	mov    0x10(%ebp),%eax
  8001bd:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001c0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001c3:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8001ca:	39 c2                	cmp    %eax,%edx
  8001cc:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8001cf:	72 3e                	jb     80020f <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001d1:	83 ec 0c             	sub    $0xc,%esp
  8001d4:	ff 75 18             	pushl  0x18(%ebp)
  8001d7:	83 eb 01             	sub    $0x1,%ebx
  8001da:	53                   	push   %ebx
  8001db:	50                   	push   %eax
  8001dc:	83 ec 08             	sub    $0x8,%esp
  8001df:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001e2:	ff 75 e0             	pushl  -0x20(%ebp)
  8001e5:	ff 75 dc             	pushl  -0x24(%ebp)
  8001e8:	ff 75 d8             	pushl  -0x28(%ebp)
  8001eb:	e8 c0 0c 00 00       	call   800eb0 <__udivdi3>
  8001f0:	83 c4 18             	add    $0x18,%esp
  8001f3:	52                   	push   %edx
  8001f4:	50                   	push   %eax
  8001f5:	89 f2                	mov    %esi,%edx
  8001f7:	89 f8                	mov    %edi,%eax
  8001f9:	e8 9f ff ff ff       	call   80019d <printnum>
  8001fe:	83 c4 20             	add    $0x20,%esp
  800201:	eb 13                	jmp    800216 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800203:	83 ec 08             	sub    $0x8,%esp
  800206:	56                   	push   %esi
  800207:	ff 75 18             	pushl  0x18(%ebp)
  80020a:	ff d7                	call   *%edi
  80020c:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80020f:	83 eb 01             	sub    $0x1,%ebx
  800212:	85 db                	test   %ebx,%ebx
  800214:	7f ed                	jg     800203 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800216:	83 ec 08             	sub    $0x8,%esp
  800219:	56                   	push   %esi
  80021a:	83 ec 04             	sub    $0x4,%esp
  80021d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800220:	ff 75 e0             	pushl  -0x20(%ebp)
  800223:	ff 75 dc             	pushl  -0x24(%ebp)
  800226:	ff 75 d8             	pushl  -0x28(%ebp)
  800229:	e8 92 0d 00 00       	call   800fc0 <__umoddi3>
  80022e:	83 c4 14             	add    $0x14,%esp
  800231:	0f be 80 46 11 80 00 	movsbl 0x801146(%eax),%eax
  800238:	50                   	push   %eax
  800239:	ff d7                	call   *%edi
}
  80023b:	83 c4 10             	add    $0x10,%esp
  80023e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800241:	5b                   	pop    %ebx
  800242:	5e                   	pop    %esi
  800243:	5f                   	pop    %edi
  800244:	5d                   	pop    %ebp
  800245:	c3                   	ret    

00800246 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800246:	f3 0f 1e fb          	endbr32 
  80024a:	55                   	push   %ebp
  80024b:	89 e5                	mov    %esp,%ebp
  80024d:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800250:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800254:	8b 10                	mov    (%eax),%edx
  800256:	3b 50 04             	cmp    0x4(%eax),%edx
  800259:	73 0a                	jae    800265 <sprintputch+0x1f>
		*b->buf++ = ch;
  80025b:	8d 4a 01             	lea    0x1(%edx),%ecx
  80025e:	89 08                	mov    %ecx,(%eax)
  800260:	8b 45 08             	mov    0x8(%ebp),%eax
  800263:	88 02                	mov    %al,(%edx)
}
  800265:	5d                   	pop    %ebp
  800266:	c3                   	ret    

00800267 <printfmt>:
{
  800267:	f3 0f 1e fb          	endbr32 
  80026b:	55                   	push   %ebp
  80026c:	89 e5                	mov    %esp,%ebp
  80026e:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800271:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800274:	50                   	push   %eax
  800275:	ff 75 10             	pushl  0x10(%ebp)
  800278:	ff 75 0c             	pushl  0xc(%ebp)
  80027b:	ff 75 08             	pushl  0x8(%ebp)
  80027e:	e8 05 00 00 00       	call   800288 <vprintfmt>
}
  800283:	83 c4 10             	add    $0x10,%esp
  800286:	c9                   	leave  
  800287:	c3                   	ret    

00800288 <vprintfmt>:
{
  800288:	f3 0f 1e fb          	endbr32 
  80028c:	55                   	push   %ebp
  80028d:	89 e5                	mov    %esp,%ebp
  80028f:	57                   	push   %edi
  800290:	56                   	push   %esi
  800291:	53                   	push   %ebx
  800292:	83 ec 3c             	sub    $0x3c,%esp
  800295:	8b 75 08             	mov    0x8(%ebp),%esi
  800298:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80029b:	8b 7d 10             	mov    0x10(%ebp),%edi
  80029e:	e9 cd 03 00 00       	jmp    800670 <vprintfmt+0x3e8>
		padc = ' ';
  8002a3:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  8002a7:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8002ae:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8002b5:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8002bc:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8002c1:	8d 47 01             	lea    0x1(%edi),%eax
  8002c4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002c7:	0f b6 17             	movzbl (%edi),%edx
  8002ca:	8d 42 dd             	lea    -0x23(%edx),%eax
  8002cd:	3c 55                	cmp    $0x55,%al
  8002cf:	0f 87 1e 04 00 00    	ja     8006f3 <vprintfmt+0x46b>
  8002d5:	0f b6 c0             	movzbl %al,%eax
  8002d8:	3e ff 24 85 00 12 80 	notrack jmp *0x801200(,%eax,4)
  8002df:	00 
  8002e0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8002e3:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  8002e7:	eb d8                	jmp    8002c1 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8002e9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8002ec:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  8002f0:	eb cf                	jmp    8002c1 <vprintfmt+0x39>
  8002f2:	0f b6 d2             	movzbl %dl,%edx
  8002f5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8002f8:	b8 00 00 00 00       	mov    $0x0,%eax
  8002fd:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800300:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800303:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800307:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80030a:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80030d:	83 f9 09             	cmp    $0x9,%ecx
  800310:	77 55                	ja     800367 <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  800312:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800315:	eb e9                	jmp    800300 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  800317:	8b 45 14             	mov    0x14(%ebp),%eax
  80031a:	8b 00                	mov    (%eax),%eax
  80031c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80031f:	8b 45 14             	mov    0x14(%ebp),%eax
  800322:	8d 40 04             	lea    0x4(%eax),%eax
  800325:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800328:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  80032b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80032f:	79 90                	jns    8002c1 <vprintfmt+0x39>
				width = precision, precision = -1;
  800331:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800334:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800337:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80033e:	eb 81                	jmp    8002c1 <vprintfmt+0x39>
  800340:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800343:	85 c0                	test   %eax,%eax
  800345:	ba 00 00 00 00       	mov    $0x0,%edx
  80034a:	0f 49 d0             	cmovns %eax,%edx
  80034d:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800350:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800353:	e9 69 ff ff ff       	jmp    8002c1 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800358:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  80035b:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  800362:	e9 5a ff ff ff       	jmp    8002c1 <vprintfmt+0x39>
  800367:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80036a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80036d:	eb bc                	jmp    80032b <vprintfmt+0xa3>
			lflag++;
  80036f:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800372:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800375:	e9 47 ff ff ff       	jmp    8002c1 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  80037a:	8b 45 14             	mov    0x14(%ebp),%eax
  80037d:	8d 78 04             	lea    0x4(%eax),%edi
  800380:	83 ec 08             	sub    $0x8,%esp
  800383:	53                   	push   %ebx
  800384:	ff 30                	pushl  (%eax)
  800386:	ff d6                	call   *%esi
			break;
  800388:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  80038b:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  80038e:	e9 da 02 00 00       	jmp    80066d <vprintfmt+0x3e5>
			err = va_arg(ap, int);
  800393:	8b 45 14             	mov    0x14(%ebp),%eax
  800396:	8d 78 04             	lea    0x4(%eax),%edi
  800399:	8b 00                	mov    (%eax),%eax
  80039b:	99                   	cltd   
  80039c:	31 d0                	xor    %edx,%eax
  80039e:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003a0:	83 f8 08             	cmp    $0x8,%eax
  8003a3:	7f 23                	jg     8003c8 <vprintfmt+0x140>
  8003a5:	8b 14 85 60 13 80 00 	mov    0x801360(,%eax,4),%edx
  8003ac:	85 d2                	test   %edx,%edx
  8003ae:	74 18                	je     8003c8 <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  8003b0:	52                   	push   %edx
  8003b1:	68 67 11 80 00       	push   $0x801167
  8003b6:	53                   	push   %ebx
  8003b7:	56                   	push   %esi
  8003b8:	e8 aa fe ff ff       	call   800267 <printfmt>
  8003bd:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003c0:	89 7d 14             	mov    %edi,0x14(%ebp)
  8003c3:	e9 a5 02 00 00       	jmp    80066d <vprintfmt+0x3e5>
				printfmt(putch, putdat, "error %d", err);
  8003c8:	50                   	push   %eax
  8003c9:	68 5e 11 80 00       	push   $0x80115e
  8003ce:	53                   	push   %ebx
  8003cf:	56                   	push   %esi
  8003d0:	e8 92 fe ff ff       	call   800267 <printfmt>
  8003d5:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003d8:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8003db:	e9 8d 02 00 00       	jmp    80066d <vprintfmt+0x3e5>
			if ((p = va_arg(ap, char *)) == NULL)
  8003e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e3:	83 c0 04             	add    $0x4,%eax
  8003e6:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8003e9:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ec:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  8003ee:	85 d2                	test   %edx,%edx
  8003f0:	b8 57 11 80 00       	mov    $0x801157,%eax
  8003f5:	0f 45 c2             	cmovne %edx,%eax
  8003f8:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8003fb:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003ff:	7e 06                	jle    800407 <vprintfmt+0x17f>
  800401:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  800405:	75 0d                	jne    800414 <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  800407:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80040a:	89 c7                	mov    %eax,%edi
  80040c:	03 45 e0             	add    -0x20(%ebp),%eax
  80040f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800412:	eb 55                	jmp    800469 <vprintfmt+0x1e1>
  800414:	83 ec 08             	sub    $0x8,%esp
  800417:	ff 75 d8             	pushl  -0x28(%ebp)
  80041a:	ff 75 cc             	pushl  -0x34(%ebp)
  80041d:	e8 85 03 00 00       	call   8007a7 <strnlen>
  800422:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800425:	29 c2                	sub    %eax,%edx
  800427:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  80042a:	83 c4 10             	add    $0x10,%esp
  80042d:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  80042f:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  800433:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800436:	85 ff                	test   %edi,%edi
  800438:	7e 11                	jle    80044b <vprintfmt+0x1c3>
					putch(padc, putdat);
  80043a:	83 ec 08             	sub    $0x8,%esp
  80043d:	53                   	push   %ebx
  80043e:	ff 75 e0             	pushl  -0x20(%ebp)
  800441:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800443:	83 ef 01             	sub    $0x1,%edi
  800446:	83 c4 10             	add    $0x10,%esp
  800449:	eb eb                	jmp    800436 <vprintfmt+0x1ae>
  80044b:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  80044e:	85 d2                	test   %edx,%edx
  800450:	b8 00 00 00 00       	mov    $0x0,%eax
  800455:	0f 49 c2             	cmovns %edx,%eax
  800458:	29 c2                	sub    %eax,%edx
  80045a:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80045d:	eb a8                	jmp    800407 <vprintfmt+0x17f>
					putch(ch, putdat);
  80045f:	83 ec 08             	sub    $0x8,%esp
  800462:	53                   	push   %ebx
  800463:	52                   	push   %edx
  800464:	ff d6                	call   *%esi
  800466:	83 c4 10             	add    $0x10,%esp
  800469:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80046c:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80046e:	83 c7 01             	add    $0x1,%edi
  800471:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800475:	0f be d0             	movsbl %al,%edx
  800478:	85 d2                	test   %edx,%edx
  80047a:	74 4b                	je     8004c7 <vprintfmt+0x23f>
  80047c:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800480:	78 06                	js     800488 <vprintfmt+0x200>
  800482:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800486:	78 1e                	js     8004a6 <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
  800488:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80048c:	74 d1                	je     80045f <vprintfmt+0x1d7>
  80048e:	0f be c0             	movsbl %al,%eax
  800491:	83 e8 20             	sub    $0x20,%eax
  800494:	83 f8 5e             	cmp    $0x5e,%eax
  800497:	76 c6                	jbe    80045f <vprintfmt+0x1d7>
					putch('?', putdat);
  800499:	83 ec 08             	sub    $0x8,%esp
  80049c:	53                   	push   %ebx
  80049d:	6a 3f                	push   $0x3f
  80049f:	ff d6                	call   *%esi
  8004a1:	83 c4 10             	add    $0x10,%esp
  8004a4:	eb c3                	jmp    800469 <vprintfmt+0x1e1>
  8004a6:	89 cf                	mov    %ecx,%edi
  8004a8:	eb 0e                	jmp    8004b8 <vprintfmt+0x230>
				putch(' ', putdat);
  8004aa:	83 ec 08             	sub    $0x8,%esp
  8004ad:	53                   	push   %ebx
  8004ae:	6a 20                	push   $0x20
  8004b0:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8004b2:	83 ef 01             	sub    $0x1,%edi
  8004b5:	83 c4 10             	add    $0x10,%esp
  8004b8:	85 ff                	test   %edi,%edi
  8004ba:	7f ee                	jg     8004aa <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  8004bc:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8004bf:	89 45 14             	mov    %eax,0x14(%ebp)
  8004c2:	e9 a6 01 00 00       	jmp    80066d <vprintfmt+0x3e5>
  8004c7:	89 cf                	mov    %ecx,%edi
  8004c9:	eb ed                	jmp    8004b8 <vprintfmt+0x230>
	if (lflag >= 2)
  8004cb:	83 f9 01             	cmp    $0x1,%ecx
  8004ce:	7f 1f                	jg     8004ef <vprintfmt+0x267>
	else if (lflag)
  8004d0:	85 c9                	test   %ecx,%ecx
  8004d2:	74 67                	je     80053b <vprintfmt+0x2b3>
		return va_arg(*ap, long);
  8004d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d7:	8b 00                	mov    (%eax),%eax
  8004d9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004dc:	89 c1                	mov    %eax,%ecx
  8004de:	c1 f9 1f             	sar    $0x1f,%ecx
  8004e1:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8004e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e7:	8d 40 04             	lea    0x4(%eax),%eax
  8004ea:	89 45 14             	mov    %eax,0x14(%ebp)
  8004ed:	eb 17                	jmp    800506 <vprintfmt+0x27e>
		return va_arg(*ap, long long);
  8004ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8004f2:	8b 50 04             	mov    0x4(%eax),%edx
  8004f5:	8b 00                	mov    (%eax),%eax
  8004f7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004fa:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8004fd:	8b 45 14             	mov    0x14(%ebp),%eax
  800500:	8d 40 08             	lea    0x8(%eax),%eax
  800503:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800506:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800509:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  80050c:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  800511:	85 c9                	test   %ecx,%ecx
  800513:	0f 89 3a 01 00 00    	jns    800653 <vprintfmt+0x3cb>
				putch('-', putdat);
  800519:	83 ec 08             	sub    $0x8,%esp
  80051c:	53                   	push   %ebx
  80051d:	6a 2d                	push   $0x2d
  80051f:	ff d6                	call   *%esi
				num = -(long long) num;
  800521:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800524:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800527:	f7 da                	neg    %edx
  800529:	83 d1 00             	adc    $0x0,%ecx
  80052c:	f7 d9                	neg    %ecx
  80052e:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800531:	b8 0a 00 00 00       	mov    $0xa,%eax
  800536:	e9 18 01 00 00       	jmp    800653 <vprintfmt+0x3cb>
		return va_arg(*ap, int);
  80053b:	8b 45 14             	mov    0x14(%ebp),%eax
  80053e:	8b 00                	mov    (%eax),%eax
  800540:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800543:	89 c1                	mov    %eax,%ecx
  800545:	c1 f9 1f             	sar    $0x1f,%ecx
  800548:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80054b:	8b 45 14             	mov    0x14(%ebp),%eax
  80054e:	8d 40 04             	lea    0x4(%eax),%eax
  800551:	89 45 14             	mov    %eax,0x14(%ebp)
  800554:	eb b0                	jmp    800506 <vprintfmt+0x27e>
	if (lflag >= 2)
  800556:	83 f9 01             	cmp    $0x1,%ecx
  800559:	7f 1e                	jg     800579 <vprintfmt+0x2f1>
	else if (lflag)
  80055b:	85 c9                	test   %ecx,%ecx
  80055d:	74 32                	je     800591 <vprintfmt+0x309>
		return va_arg(*ap, unsigned long);
  80055f:	8b 45 14             	mov    0x14(%ebp),%eax
  800562:	8b 10                	mov    (%eax),%edx
  800564:	b9 00 00 00 00       	mov    $0x0,%ecx
  800569:	8d 40 04             	lea    0x4(%eax),%eax
  80056c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80056f:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  800574:	e9 da 00 00 00       	jmp    800653 <vprintfmt+0x3cb>
		return va_arg(*ap, unsigned long long);
  800579:	8b 45 14             	mov    0x14(%ebp),%eax
  80057c:	8b 10                	mov    (%eax),%edx
  80057e:	8b 48 04             	mov    0x4(%eax),%ecx
  800581:	8d 40 08             	lea    0x8(%eax),%eax
  800584:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800587:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  80058c:	e9 c2 00 00 00       	jmp    800653 <vprintfmt+0x3cb>
		return va_arg(*ap, unsigned int);
  800591:	8b 45 14             	mov    0x14(%ebp),%eax
  800594:	8b 10                	mov    (%eax),%edx
  800596:	b9 00 00 00 00       	mov    $0x0,%ecx
  80059b:	8d 40 04             	lea    0x4(%eax),%eax
  80059e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005a1:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  8005a6:	e9 a8 00 00 00       	jmp    800653 <vprintfmt+0x3cb>
	if (lflag >= 2)
  8005ab:	83 f9 01             	cmp    $0x1,%ecx
  8005ae:	7f 1b                	jg     8005cb <vprintfmt+0x343>
	else if (lflag)
  8005b0:	85 c9                	test   %ecx,%ecx
  8005b2:	74 5c                	je     800610 <vprintfmt+0x388>
		return va_arg(*ap, long);
  8005b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b7:	8b 00                	mov    (%eax),%eax
  8005b9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005bc:	99                   	cltd   
  8005bd:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005c0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c3:	8d 40 04             	lea    0x4(%eax),%eax
  8005c6:	89 45 14             	mov    %eax,0x14(%ebp)
  8005c9:	eb 17                	jmp    8005e2 <vprintfmt+0x35a>
		return va_arg(*ap, long long);
  8005cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ce:	8b 50 04             	mov    0x4(%eax),%edx
  8005d1:	8b 00                	mov    (%eax),%eax
  8005d3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005d6:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005d9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005dc:	8d 40 08             	lea    0x8(%eax),%eax
  8005df:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8005e2:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005e5:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 8;
  8005e8:	b8 08 00 00 00       	mov    $0x8,%eax
			if ((long long) num < 0) {
  8005ed:	85 c9                	test   %ecx,%ecx
  8005ef:	79 62                	jns    800653 <vprintfmt+0x3cb>
				putch('-', putdat);
  8005f1:	83 ec 08             	sub    $0x8,%esp
  8005f4:	53                   	push   %ebx
  8005f5:	6a 2d                	push   $0x2d
  8005f7:	ff d6                	call   *%esi
				num = -(long long) num;
  8005f9:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005fc:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005ff:	f7 da                	neg    %edx
  800601:	83 d1 00             	adc    $0x0,%ecx
  800604:	f7 d9                	neg    %ecx
  800606:	83 c4 10             	add    $0x10,%esp
			base = 8;
  800609:	b8 08 00 00 00       	mov    $0x8,%eax
  80060e:	eb 43                	jmp    800653 <vprintfmt+0x3cb>
		return va_arg(*ap, int);
  800610:	8b 45 14             	mov    0x14(%ebp),%eax
  800613:	8b 00                	mov    (%eax),%eax
  800615:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800618:	89 c1                	mov    %eax,%ecx
  80061a:	c1 f9 1f             	sar    $0x1f,%ecx
  80061d:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800620:	8b 45 14             	mov    0x14(%ebp),%eax
  800623:	8d 40 04             	lea    0x4(%eax),%eax
  800626:	89 45 14             	mov    %eax,0x14(%ebp)
  800629:	eb b7                	jmp    8005e2 <vprintfmt+0x35a>
			putch('0', putdat);
  80062b:	83 ec 08             	sub    $0x8,%esp
  80062e:	53                   	push   %ebx
  80062f:	6a 30                	push   $0x30
  800631:	ff d6                	call   *%esi
			putch('x', putdat);
  800633:	83 c4 08             	add    $0x8,%esp
  800636:	53                   	push   %ebx
  800637:	6a 78                	push   $0x78
  800639:	ff d6                	call   *%esi
			num = (unsigned long long)
  80063b:	8b 45 14             	mov    0x14(%ebp),%eax
  80063e:	8b 10                	mov    (%eax),%edx
  800640:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800645:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800648:	8d 40 04             	lea    0x4(%eax),%eax
  80064b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80064e:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  800653:	83 ec 0c             	sub    $0xc,%esp
  800656:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  80065a:	57                   	push   %edi
  80065b:	ff 75 e0             	pushl  -0x20(%ebp)
  80065e:	50                   	push   %eax
  80065f:	51                   	push   %ecx
  800660:	52                   	push   %edx
  800661:	89 da                	mov    %ebx,%edx
  800663:	89 f0                	mov    %esi,%eax
  800665:	e8 33 fb ff ff       	call   80019d <printnum>
			break;
  80066a:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  80066d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800670:	83 c7 01             	add    $0x1,%edi
  800673:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800677:	83 f8 25             	cmp    $0x25,%eax
  80067a:	0f 84 23 fc ff ff    	je     8002a3 <vprintfmt+0x1b>
			if (ch == '\0')
  800680:	85 c0                	test   %eax,%eax
  800682:	0f 84 8b 00 00 00    	je     800713 <vprintfmt+0x48b>
			putch(ch, putdat);
  800688:	83 ec 08             	sub    $0x8,%esp
  80068b:	53                   	push   %ebx
  80068c:	50                   	push   %eax
  80068d:	ff d6                	call   *%esi
  80068f:	83 c4 10             	add    $0x10,%esp
  800692:	eb dc                	jmp    800670 <vprintfmt+0x3e8>
	if (lflag >= 2)
  800694:	83 f9 01             	cmp    $0x1,%ecx
  800697:	7f 1b                	jg     8006b4 <vprintfmt+0x42c>
	else if (lflag)
  800699:	85 c9                	test   %ecx,%ecx
  80069b:	74 2c                	je     8006c9 <vprintfmt+0x441>
		return va_arg(*ap, unsigned long);
  80069d:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a0:	8b 10                	mov    (%eax),%edx
  8006a2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006a7:	8d 40 04             	lea    0x4(%eax),%eax
  8006aa:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006ad:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  8006b2:	eb 9f                	jmp    800653 <vprintfmt+0x3cb>
		return va_arg(*ap, unsigned long long);
  8006b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b7:	8b 10                	mov    (%eax),%edx
  8006b9:	8b 48 04             	mov    0x4(%eax),%ecx
  8006bc:	8d 40 08             	lea    0x8(%eax),%eax
  8006bf:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006c2:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  8006c7:	eb 8a                	jmp    800653 <vprintfmt+0x3cb>
		return va_arg(*ap, unsigned int);
  8006c9:	8b 45 14             	mov    0x14(%ebp),%eax
  8006cc:	8b 10                	mov    (%eax),%edx
  8006ce:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006d3:	8d 40 04             	lea    0x4(%eax),%eax
  8006d6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006d9:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  8006de:	e9 70 ff ff ff       	jmp    800653 <vprintfmt+0x3cb>
			putch(ch, putdat);
  8006e3:	83 ec 08             	sub    $0x8,%esp
  8006e6:	53                   	push   %ebx
  8006e7:	6a 25                	push   $0x25
  8006e9:	ff d6                	call   *%esi
			break;
  8006eb:	83 c4 10             	add    $0x10,%esp
  8006ee:	e9 7a ff ff ff       	jmp    80066d <vprintfmt+0x3e5>
			putch('%', putdat);
  8006f3:	83 ec 08             	sub    $0x8,%esp
  8006f6:	53                   	push   %ebx
  8006f7:	6a 25                	push   $0x25
  8006f9:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006fb:	83 c4 10             	add    $0x10,%esp
  8006fe:	89 f8                	mov    %edi,%eax
  800700:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800704:	74 05                	je     80070b <vprintfmt+0x483>
  800706:	83 e8 01             	sub    $0x1,%eax
  800709:	eb f5                	jmp    800700 <vprintfmt+0x478>
  80070b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80070e:	e9 5a ff ff ff       	jmp    80066d <vprintfmt+0x3e5>
}
  800713:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800716:	5b                   	pop    %ebx
  800717:	5e                   	pop    %esi
  800718:	5f                   	pop    %edi
  800719:	5d                   	pop    %ebp
  80071a:	c3                   	ret    

0080071b <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80071b:	f3 0f 1e fb          	endbr32 
  80071f:	55                   	push   %ebp
  800720:	89 e5                	mov    %esp,%ebp
  800722:	83 ec 18             	sub    $0x18,%esp
  800725:	8b 45 08             	mov    0x8(%ebp),%eax
  800728:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80072b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80072e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800732:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800735:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80073c:	85 c0                	test   %eax,%eax
  80073e:	74 26                	je     800766 <vsnprintf+0x4b>
  800740:	85 d2                	test   %edx,%edx
  800742:	7e 22                	jle    800766 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800744:	ff 75 14             	pushl  0x14(%ebp)
  800747:	ff 75 10             	pushl  0x10(%ebp)
  80074a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80074d:	50                   	push   %eax
  80074e:	68 46 02 80 00       	push   $0x800246
  800753:	e8 30 fb ff ff       	call   800288 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800758:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80075b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80075e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800761:	83 c4 10             	add    $0x10,%esp
}
  800764:	c9                   	leave  
  800765:	c3                   	ret    
		return -E_INVAL;
  800766:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80076b:	eb f7                	jmp    800764 <vsnprintf+0x49>

0080076d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80076d:	f3 0f 1e fb          	endbr32 
  800771:	55                   	push   %ebp
  800772:	89 e5                	mov    %esp,%ebp
  800774:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800777:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80077a:	50                   	push   %eax
  80077b:	ff 75 10             	pushl  0x10(%ebp)
  80077e:	ff 75 0c             	pushl  0xc(%ebp)
  800781:	ff 75 08             	pushl  0x8(%ebp)
  800784:	e8 92 ff ff ff       	call   80071b <vsnprintf>
	va_end(ap);

	return rc;
}
  800789:	c9                   	leave  
  80078a:	c3                   	ret    

0080078b <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80078b:	f3 0f 1e fb          	endbr32 
  80078f:	55                   	push   %ebp
  800790:	89 e5                	mov    %esp,%ebp
  800792:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800795:	b8 00 00 00 00       	mov    $0x0,%eax
  80079a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80079e:	74 05                	je     8007a5 <strlen+0x1a>
		n++;
  8007a0:	83 c0 01             	add    $0x1,%eax
  8007a3:	eb f5                	jmp    80079a <strlen+0xf>
	return n;
}
  8007a5:	5d                   	pop    %ebp
  8007a6:	c3                   	ret    

008007a7 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007a7:	f3 0f 1e fb          	endbr32 
  8007ab:	55                   	push   %ebp
  8007ac:	89 e5                	mov    %esp,%ebp
  8007ae:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007b1:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007b4:	b8 00 00 00 00       	mov    $0x0,%eax
  8007b9:	39 d0                	cmp    %edx,%eax
  8007bb:	74 0d                	je     8007ca <strnlen+0x23>
  8007bd:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007c1:	74 05                	je     8007c8 <strnlen+0x21>
		n++;
  8007c3:	83 c0 01             	add    $0x1,%eax
  8007c6:	eb f1                	jmp    8007b9 <strnlen+0x12>
  8007c8:	89 c2                	mov    %eax,%edx
	return n;
}
  8007ca:	89 d0                	mov    %edx,%eax
  8007cc:	5d                   	pop    %ebp
  8007cd:	c3                   	ret    

008007ce <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007ce:	f3 0f 1e fb          	endbr32 
  8007d2:	55                   	push   %ebp
  8007d3:	89 e5                	mov    %esp,%ebp
  8007d5:	53                   	push   %ebx
  8007d6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007d9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007dc:	b8 00 00 00 00       	mov    $0x0,%eax
  8007e1:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8007e5:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8007e8:	83 c0 01             	add    $0x1,%eax
  8007eb:	84 d2                	test   %dl,%dl
  8007ed:	75 f2                	jne    8007e1 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  8007ef:	89 c8                	mov    %ecx,%eax
  8007f1:	5b                   	pop    %ebx
  8007f2:	5d                   	pop    %ebp
  8007f3:	c3                   	ret    

008007f4 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007f4:	f3 0f 1e fb          	endbr32 
  8007f8:	55                   	push   %ebp
  8007f9:	89 e5                	mov    %esp,%ebp
  8007fb:	53                   	push   %ebx
  8007fc:	83 ec 10             	sub    $0x10,%esp
  8007ff:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800802:	53                   	push   %ebx
  800803:	e8 83 ff ff ff       	call   80078b <strlen>
  800808:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  80080b:	ff 75 0c             	pushl  0xc(%ebp)
  80080e:	01 d8                	add    %ebx,%eax
  800810:	50                   	push   %eax
  800811:	e8 b8 ff ff ff       	call   8007ce <strcpy>
	return dst;
}
  800816:	89 d8                	mov    %ebx,%eax
  800818:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80081b:	c9                   	leave  
  80081c:	c3                   	ret    

0080081d <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80081d:	f3 0f 1e fb          	endbr32 
  800821:	55                   	push   %ebp
  800822:	89 e5                	mov    %esp,%ebp
  800824:	56                   	push   %esi
  800825:	53                   	push   %ebx
  800826:	8b 75 08             	mov    0x8(%ebp),%esi
  800829:	8b 55 0c             	mov    0xc(%ebp),%edx
  80082c:	89 f3                	mov    %esi,%ebx
  80082e:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800831:	89 f0                	mov    %esi,%eax
  800833:	39 d8                	cmp    %ebx,%eax
  800835:	74 11                	je     800848 <strncpy+0x2b>
		*dst++ = *src;
  800837:	83 c0 01             	add    $0x1,%eax
  80083a:	0f b6 0a             	movzbl (%edx),%ecx
  80083d:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800840:	80 f9 01             	cmp    $0x1,%cl
  800843:	83 da ff             	sbb    $0xffffffff,%edx
  800846:	eb eb                	jmp    800833 <strncpy+0x16>
	}
	return ret;
}
  800848:	89 f0                	mov    %esi,%eax
  80084a:	5b                   	pop    %ebx
  80084b:	5e                   	pop    %esi
  80084c:	5d                   	pop    %ebp
  80084d:	c3                   	ret    

0080084e <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80084e:	f3 0f 1e fb          	endbr32 
  800852:	55                   	push   %ebp
  800853:	89 e5                	mov    %esp,%ebp
  800855:	56                   	push   %esi
  800856:	53                   	push   %ebx
  800857:	8b 75 08             	mov    0x8(%ebp),%esi
  80085a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80085d:	8b 55 10             	mov    0x10(%ebp),%edx
  800860:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800862:	85 d2                	test   %edx,%edx
  800864:	74 21                	je     800887 <strlcpy+0x39>
  800866:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80086a:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  80086c:	39 c2                	cmp    %eax,%edx
  80086e:	74 14                	je     800884 <strlcpy+0x36>
  800870:	0f b6 19             	movzbl (%ecx),%ebx
  800873:	84 db                	test   %bl,%bl
  800875:	74 0b                	je     800882 <strlcpy+0x34>
			*dst++ = *src++;
  800877:	83 c1 01             	add    $0x1,%ecx
  80087a:	83 c2 01             	add    $0x1,%edx
  80087d:	88 5a ff             	mov    %bl,-0x1(%edx)
  800880:	eb ea                	jmp    80086c <strlcpy+0x1e>
  800882:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800884:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800887:	29 f0                	sub    %esi,%eax
}
  800889:	5b                   	pop    %ebx
  80088a:	5e                   	pop    %esi
  80088b:	5d                   	pop    %ebp
  80088c:	c3                   	ret    

0080088d <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80088d:	f3 0f 1e fb          	endbr32 
  800891:	55                   	push   %ebp
  800892:	89 e5                	mov    %esp,%ebp
  800894:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800897:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80089a:	0f b6 01             	movzbl (%ecx),%eax
  80089d:	84 c0                	test   %al,%al
  80089f:	74 0c                	je     8008ad <strcmp+0x20>
  8008a1:	3a 02                	cmp    (%edx),%al
  8008a3:	75 08                	jne    8008ad <strcmp+0x20>
		p++, q++;
  8008a5:	83 c1 01             	add    $0x1,%ecx
  8008a8:	83 c2 01             	add    $0x1,%edx
  8008ab:	eb ed                	jmp    80089a <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008ad:	0f b6 c0             	movzbl %al,%eax
  8008b0:	0f b6 12             	movzbl (%edx),%edx
  8008b3:	29 d0                	sub    %edx,%eax
}
  8008b5:	5d                   	pop    %ebp
  8008b6:	c3                   	ret    

008008b7 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008b7:	f3 0f 1e fb          	endbr32 
  8008bb:	55                   	push   %ebp
  8008bc:	89 e5                	mov    %esp,%ebp
  8008be:	53                   	push   %ebx
  8008bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008c5:	89 c3                	mov    %eax,%ebx
  8008c7:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008ca:	eb 06                	jmp    8008d2 <strncmp+0x1b>
		n--, p++, q++;
  8008cc:	83 c0 01             	add    $0x1,%eax
  8008cf:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8008d2:	39 d8                	cmp    %ebx,%eax
  8008d4:	74 16                	je     8008ec <strncmp+0x35>
  8008d6:	0f b6 08             	movzbl (%eax),%ecx
  8008d9:	84 c9                	test   %cl,%cl
  8008db:	74 04                	je     8008e1 <strncmp+0x2a>
  8008dd:	3a 0a                	cmp    (%edx),%cl
  8008df:	74 eb                	je     8008cc <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008e1:	0f b6 00             	movzbl (%eax),%eax
  8008e4:	0f b6 12             	movzbl (%edx),%edx
  8008e7:	29 d0                	sub    %edx,%eax
}
  8008e9:	5b                   	pop    %ebx
  8008ea:	5d                   	pop    %ebp
  8008eb:	c3                   	ret    
		return 0;
  8008ec:	b8 00 00 00 00       	mov    $0x0,%eax
  8008f1:	eb f6                	jmp    8008e9 <strncmp+0x32>

008008f3 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008f3:	f3 0f 1e fb          	endbr32 
  8008f7:	55                   	push   %ebp
  8008f8:	89 e5                	mov    %esp,%ebp
  8008fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8008fd:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800901:	0f b6 10             	movzbl (%eax),%edx
  800904:	84 d2                	test   %dl,%dl
  800906:	74 09                	je     800911 <strchr+0x1e>
		if (*s == c)
  800908:	38 ca                	cmp    %cl,%dl
  80090a:	74 0a                	je     800916 <strchr+0x23>
	for (; *s; s++)
  80090c:	83 c0 01             	add    $0x1,%eax
  80090f:	eb f0                	jmp    800901 <strchr+0xe>
			return (char *) s;
	return 0;
  800911:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800916:	5d                   	pop    %ebp
  800917:	c3                   	ret    

00800918 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800918:	f3 0f 1e fb          	endbr32 
  80091c:	55                   	push   %ebp
  80091d:	89 e5                	mov    %esp,%ebp
  80091f:	8b 45 08             	mov    0x8(%ebp),%eax
  800922:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800926:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800929:	38 ca                	cmp    %cl,%dl
  80092b:	74 09                	je     800936 <strfind+0x1e>
  80092d:	84 d2                	test   %dl,%dl
  80092f:	74 05                	je     800936 <strfind+0x1e>
	for (; *s; s++)
  800931:	83 c0 01             	add    $0x1,%eax
  800934:	eb f0                	jmp    800926 <strfind+0xe>
			break;
	return (char *) s;
}
  800936:	5d                   	pop    %ebp
  800937:	c3                   	ret    

00800938 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800938:	f3 0f 1e fb          	endbr32 
  80093c:	55                   	push   %ebp
  80093d:	89 e5                	mov    %esp,%ebp
  80093f:	57                   	push   %edi
  800940:	56                   	push   %esi
  800941:	53                   	push   %ebx
  800942:	8b 7d 08             	mov    0x8(%ebp),%edi
  800945:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800948:	85 c9                	test   %ecx,%ecx
  80094a:	74 31                	je     80097d <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80094c:	89 f8                	mov    %edi,%eax
  80094e:	09 c8                	or     %ecx,%eax
  800950:	a8 03                	test   $0x3,%al
  800952:	75 23                	jne    800977 <memset+0x3f>
		c &= 0xFF;
  800954:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800958:	89 d3                	mov    %edx,%ebx
  80095a:	c1 e3 08             	shl    $0x8,%ebx
  80095d:	89 d0                	mov    %edx,%eax
  80095f:	c1 e0 18             	shl    $0x18,%eax
  800962:	89 d6                	mov    %edx,%esi
  800964:	c1 e6 10             	shl    $0x10,%esi
  800967:	09 f0                	or     %esi,%eax
  800969:	09 c2                	or     %eax,%edx
  80096b:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80096d:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800970:	89 d0                	mov    %edx,%eax
  800972:	fc                   	cld    
  800973:	f3 ab                	rep stos %eax,%es:(%edi)
  800975:	eb 06                	jmp    80097d <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800977:	8b 45 0c             	mov    0xc(%ebp),%eax
  80097a:	fc                   	cld    
  80097b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80097d:	89 f8                	mov    %edi,%eax
  80097f:	5b                   	pop    %ebx
  800980:	5e                   	pop    %esi
  800981:	5f                   	pop    %edi
  800982:	5d                   	pop    %ebp
  800983:	c3                   	ret    

00800984 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800984:	f3 0f 1e fb          	endbr32 
  800988:	55                   	push   %ebp
  800989:	89 e5                	mov    %esp,%ebp
  80098b:	57                   	push   %edi
  80098c:	56                   	push   %esi
  80098d:	8b 45 08             	mov    0x8(%ebp),%eax
  800990:	8b 75 0c             	mov    0xc(%ebp),%esi
  800993:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800996:	39 c6                	cmp    %eax,%esi
  800998:	73 32                	jae    8009cc <memmove+0x48>
  80099a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80099d:	39 c2                	cmp    %eax,%edx
  80099f:	76 2b                	jbe    8009cc <memmove+0x48>
		s += n;
		d += n;
  8009a1:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009a4:	89 fe                	mov    %edi,%esi
  8009a6:	09 ce                	or     %ecx,%esi
  8009a8:	09 d6                	or     %edx,%esi
  8009aa:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009b0:	75 0e                	jne    8009c0 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009b2:	83 ef 04             	sub    $0x4,%edi
  8009b5:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009b8:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8009bb:	fd                   	std    
  8009bc:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009be:	eb 09                	jmp    8009c9 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009c0:	83 ef 01             	sub    $0x1,%edi
  8009c3:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8009c6:	fd                   	std    
  8009c7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009c9:	fc                   	cld    
  8009ca:	eb 1a                	jmp    8009e6 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009cc:	89 c2                	mov    %eax,%edx
  8009ce:	09 ca                	or     %ecx,%edx
  8009d0:	09 f2                	or     %esi,%edx
  8009d2:	f6 c2 03             	test   $0x3,%dl
  8009d5:	75 0a                	jne    8009e1 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009d7:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8009da:	89 c7                	mov    %eax,%edi
  8009dc:	fc                   	cld    
  8009dd:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009df:	eb 05                	jmp    8009e6 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  8009e1:	89 c7                	mov    %eax,%edi
  8009e3:	fc                   	cld    
  8009e4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009e6:	5e                   	pop    %esi
  8009e7:	5f                   	pop    %edi
  8009e8:	5d                   	pop    %ebp
  8009e9:	c3                   	ret    

008009ea <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009ea:	f3 0f 1e fb          	endbr32 
  8009ee:	55                   	push   %ebp
  8009ef:	89 e5                	mov    %esp,%ebp
  8009f1:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009f4:	ff 75 10             	pushl  0x10(%ebp)
  8009f7:	ff 75 0c             	pushl  0xc(%ebp)
  8009fa:	ff 75 08             	pushl  0x8(%ebp)
  8009fd:	e8 82 ff ff ff       	call   800984 <memmove>
}
  800a02:	c9                   	leave  
  800a03:	c3                   	ret    

00800a04 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a04:	f3 0f 1e fb          	endbr32 
  800a08:	55                   	push   %ebp
  800a09:	89 e5                	mov    %esp,%ebp
  800a0b:	56                   	push   %esi
  800a0c:	53                   	push   %ebx
  800a0d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a10:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a13:	89 c6                	mov    %eax,%esi
  800a15:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a18:	39 f0                	cmp    %esi,%eax
  800a1a:	74 1c                	je     800a38 <memcmp+0x34>
		if (*s1 != *s2)
  800a1c:	0f b6 08             	movzbl (%eax),%ecx
  800a1f:	0f b6 1a             	movzbl (%edx),%ebx
  800a22:	38 d9                	cmp    %bl,%cl
  800a24:	75 08                	jne    800a2e <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800a26:	83 c0 01             	add    $0x1,%eax
  800a29:	83 c2 01             	add    $0x1,%edx
  800a2c:	eb ea                	jmp    800a18 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800a2e:	0f b6 c1             	movzbl %cl,%eax
  800a31:	0f b6 db             	movzbl %bl,%ebx
  800a34:	29 d8                	sub    %ebx,%eax
  800a36:	eb 05                	jmp    800a3d <memcmp+0x39>
	}

	return 0;
  800a38:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a3d:	5b                   	pop    %ebx
  800a3e:	5e                   	pop    %esi
  800a3f:	5d                   	pop    %ebp
  800a40:	c3                   	ret    

00800a41 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a41:	f3 0f 1e fb          	endbr32 
  800a45:	55                   	push   %ebp
  800a46:	89 e5                	mov    %esp,%ebp
  800a48:	8b 45 08             	mov    0x8(%ebp),%eax
  800a4b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a4e:	89 c2                	mov    %eax,%edx
  800a50:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a53:	39 d0                	cmp    %edx,%eax
  800a55:	73 09                	jae    800a60 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a57:	38 08                	cmp    %cl,(%eax)
  800a59:	74 05                	je     800a60 <memfind+0x1f>
	for (; s < ends; s++)
  800a5b:	83 c0 01             	add    $0x1,%eax
  800a5e:	eb f3                	jmp    800a53 <memfind+0x12>
			break;
	return (void *) s;
}
  800a60:	5d                   	pop    %ebp
  800a61:	c3                   	ret    

00800a62 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a62:	f3 0f 1e fb          	endbr32 
  800a66:	55                   	push   %ebp
  800a67:	89 e5                	mov    %esp,%ebp
  800a69:	57                   	push   %edi
  800a6a:	56                   	push   %esi
  800a6b:	53                   	push   %ebx
  800a6c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a6f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a72:	eb 03                	jmp    800a77 <strtol+0x15>
		s++;
  800a74:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800a77:	0f b6 01             	movzbl (%ecx),%eax
  800a7a:	3c 20                	cmp    $0x20,%al
  800a7c:	74 f6                	je     800a74 <strtol+0x12>
  800a7e:	3c 09                	cmp    $0x9,%al
  800a80:	74 f2                	je     800a74 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800a82:	3c 2b                	cmp    $0x2b,%al
  800a84:	74 2a                	je     800ab0 <strtol+0x4e>
	int neg = 0;
  800a86:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800a8b:	3c 2d                	cmp    $0x2d,%al
  800a8d:	74 2b                	je     800aba <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a8f:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a95:	75 0f                	jne    800aa6 <strtol+0x44>
  800a97:	80 39 30             	cmpb   $0x30,(%ecx)
  800a9a:	74 28                	je     800ac4 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a9c:	85 db                	test   %ebx,%ebx
  800a9e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800aa3:	0f 44 d8             	cmove  %eax,%ebx
  800aa6:	b8 00 00 00 00       	mov    $0x0,%eax
  800aab:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800aae:	eb 46                	jmp    800af6 <strtol+0x94>
		s++;
  800ab0:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800ab3:	bf 00 00 00 00       	mov    $0x0,%edi
  800ab8:	eb d5                	jmp    800a8f <strtol+0x2d>
		s++, neg = 1;
  800aba:	83 c1 01             	add    $0x1,%ecx
  800abd:	bf 01 00 00 00       	mov    $0x1,%edi
  800ac2:	eb cb                	jmp    800a8f <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ac4:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800ac8:	74 0e                	je     800ad8 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800aca:	85 db                	test   %ebx,%ebx
  800acc:	75 d8                	jne    800aa6 <strtol+0x44>
		s++, base = 8;
  800ace:	83 c1 01             	add    $0x1,%ecx
  800ad1:	bb 08 00 00 00       	mov    $0x8,%ebx
  800ad6:	eb ce                	jmp    800aa6 <strtol+0x44>
		s += 2, base = 16;
  800ad8:	83 c1 02             	add    $0x2,%ecx
  800adb:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ae0:	eb c4                	jmp    800aa6 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800ae2:	0f be d2             	movsbl %dl,%edx
  800ae5:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800ae8:	3b 55 10             	cmp    0x10(%ebp),%edx
  800aeb:	7d 3a                	jge    800b27 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800aed:	83 c1 01             	add    $0x1,%ecx
  800af0:	0f af 45 10          	imul   0x10(%ebp),%eax
  800af4:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800af6:	0f b6 11             	movzbl (%ecx),%edx
  800af9:	8d 72 d0             	lea    -0x30(%edx),%esi
  800afc:	89 f3                	mov    %esi,%ebx
  800afe:	80 fb 09             	cmp    $0x9,%bl
  800b01:	76 df                	jbe    800ae2 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800b03:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b06:	89 f3                	mov    %esi,%ebx
  800b08:	80 fb 19             	cmp    $0x19,%bl
  800b0b:	77 08                	ja     800b15 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800b0d:	0f be d2             	movsbl %dl,%edx
  800b10:	83 ea 57             	sub    $0x57,%edx
  800b13:	eb d3                	jmp    800ae8 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800b15:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b18:	89 f3                	mov    %esi,%ebx
  800b1a:	80 fb 19             	cmp    $0x19,%bl
  800b1d:	77 08                	ja     800b27 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800b1f:	0f be d2             	movsbl %dl,%edx
  800b22:	83 ea 37             	sub    $0x37,%edx
  800b25:	eb c1                	jmp    800ae8 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800b27:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b2b:	74 05                	je     800b32 <strtol+0xd0>
		*endptr = (char *) s;
  800b2d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b30:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800b32:	89 c2                	mov    %eax,%edx
  800b34:	f7 da                	neg    %edx
  800b36:	85 ff                	test   %edi,%edi
  800b38:	0f 45 c2             	cmovne %edx,%eax
}
  800b3b:	5b                   	pop    %ebx
  800b3c:	5e                   	pop    %esi
  800b3d:	5f                   	pop    %edi
  800b3e:	5d                   	pop    %ebp
  800b3f:	c3                   	ret    

00800b40 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b40:	f3 0f 1e fb          	endbr32 
  800b44:	55                   	push   %ebp
  800b45:	89 e5                	mov    %esp,%ebp
  800b47:	57                   	push   %edi
  800b48:	56                   	push   %esi
  800b49:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b4a:	b8 00 00 00 00       	mov    $0x0,%eax
  800b4f:	8b 55 08             	mov    0x8(%ebp),%edx
  800b52:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b55:	89 c3                	mov    %eax,%ebx
  800b57:	89 c7                	mov    %eax,%edi
  800b59:	89 c6                	mov    %eax,%esi
  800b5b:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b5d:	5b                   	pop    %ebx
  800b5e:	5e                   	pop    %esi
  800b5f:	5f                   	pop    %edi
  800b60:	5d                   	pop    %ebp
  800b61:	c3                   	ret    

00800b62 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b62:	f3 0f 1e fb          	endbr32 
  800b66:	55                   	push   %ebp
  800b67:	89 e5                	mov    %esp,%ebp
  800b69:	57                   	push   %edi
  800b6a:	56                   	push   %esi
  800b6b:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b6c:	ba 00 00 00 00       	mov    $0x0,%edx
  800b71:	b8 01 00 00 00       	mov    $0x1,%eax
  800b76:	89 d1                	mov    %edx,%ecx
  800b78:	89 d3                	mov    %edx,%ebx
  800b7a:	89 d7                	mov    %edx,%edi
  800b7c:	89 d6                	mov    %edx,%esi
  800b7e:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b80:	5b                   	pop    %ebx
  800b81:	5e                   	pop    %esi
  800b82:	5f                   	pop    %edi
  800b83:	5d                   	pop    %ebp
  800b84:	c3                   	ret    

00800b85 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b85:	f3 0f 1e fb          	endbr32 
  800b89:	55                   	push   %ebp
  800b8a:	89 e5                	mov    %esp,%ebp
  800b8c:	57                   	push   %edi
  800b8d:	56                   	push   %esi
  800b8e:	53                   	push   %ebx
  800b8f:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b92:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b97:	8b 55 08             	mov    0x8(%ebp),%edx
  800b9a:	b8 03 00 00 00       	mov    $0x3,%eax
  800b9f:	89 cb                	mov    %ecx,%ebx
  800ba1:	89 cf                	mov    %ecx,%edi
  800ba3:	89 ce                	mov    %ecx,%esi
  800ba5:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ba7:	85 c0                	test   %eax,%eax
  800ba9:	7f 08                	jg     800bb3 <sys_env_destroy+0x2e>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bab:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bae:	5b                   	pop    %ebx
  800baf:	5e                   	pop    %esi
  800bb0:	5f                   	pop    %edi
  800bb1:	5d                   	pop    %ebp
  800bb2:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800bb3:	83 ec 0c             	sub    $0xc,%esp
  800bb6:	50                   	push   %eax
  800bb7:	6a 03                	push   $0x3
  800bb9:	68 84 13 80 00       	push   $0x801384
  800bbe:	6a 23                	push   $0x23
  800bc0:	68 a1 13 80 00       	push   $0x8013a1
  800bc5:	e8 94 02 00 00       	call   800e5e <_panic>

00800bca <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bca:	f3 0f 1e fb          	endbr32 
  800bce:	55                   	push   %ebp
  800bcf:	89 e5                	mov    %esp,%ebp
  800bd1:	57                   	push   %edi
  800bd2:	56                   	push   %esi
  800bd3:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bd4:	ba 00 00 00 00       	mov    $0x0,%edx
  800bd9:	b8 02 00 00 00       	mov    $0x2,%eax
  800bde:	89 d1                	mov    %edx,%ecx
  800be0:	89 d3                	mov    %edx,%ebx
  800be2:	89 d7                	mov    %edx,%edi
  800be4:	89 d6                	mov    %edx,%esi
  800be6:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800be8:	5b                   	pop    %ebx
  800be9:	5e                   	pop    %esi
  800bea:	5f                   	pop    %edi
  800beb:	5d                   	pop    %ebp
  800bec:	c3                   	ret    

00800bed <sys_yield>:

void
sys_yield(void)
{
  800bed:	f3 0f 1e fb          	endbr32 
  800bf1:	55                   	push   %ebp
  800bf2:	89 e5                	mov    %esp,%ebp
  800bf4:	57                   	push   %edi
  800bf5:	56                   	push   %esi
  800bf6:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bf7:	ba 00 00 00 00       	mov    $0x0,%edx
  800bfc:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c01:	89 d1                	mov    %edx,%ecx
  800c03:	89 d3                	mov    %edx,%ebx
  800c05:	89 d7                	mov    %edx,%edi
  800c07:	89 d6                	mov    %edx,%esi
  800c09:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c0b:	5b                   	pop    %ebx
  800c0c:	5e                   	pop    %esi
  800c0d:	5f                   	pop    %edi
  800c0e:	5d                   	pop    %ebp
  800c0f:	c3                   	ret    

00800c10 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c10:	f3 0f 1e fb          	endbr32 
  800c14:	55                   	push   %ebp
  800c15:	89 e5                	mov    %esp,%ebp
  800c17:	57                   	push   %edi
  800c18:	56                   	push   %esi
  800c19:	53                   	push   %ebx
  800c1a:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c1d:	be 00 00 00 00       	mov    $0x0,%esi
  800c22:	8b 55 08             	mov    0x8(%ebp),%edx
  800c25:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c28:	b8 04 00 00 00       	mov    $0x4,%eax
  800c2d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c30:	89 f7                	mov    %esi,%edi
  800c32:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c34:	85 c0                	test   %eax,%eax
  800c36:	7f 08                	jg     800c40 <sys_page_alloc+0x30>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c38:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c3b:	5b                   	pop    %ebx
  800c3c:	5e                   	pop    %esi
  800c3d:	5f                   	pop    %edi
  800c3e:	5d                   	pop    %ebp
  800c3f:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c40:	83 ec 0c             	sub    $0xc,%esp
  800c43:	50                   	push   %eax
  800c44:	6a 04                	push   $0x4
  800c46:	68 84 13 80 00       	push   $0x801384
  800c4b:	6a 23                	push   $0x23
  800c4d:	68 a1 13 80 00       	push   $0x8013a1
  800c52:	e8 07 02 00 00       	call   800e5e <_panic>

00800c57 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c57:	f3 0f 1e fb          	endbr32 
  800c5b:	55                   	push   %ebp
  800c5c:	89 e5                	mov    %esp,%ebp
  800c5e:	57                   	push   %edi
  800c5f:	56                   	push   %esi
  800c60:	53                   	push   %ebx
  800c61:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c64:	8b 55 08             	mov    0x8(%ebp),%edx
  800c67:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c6a:	b8 05 00 00 00       	mov    $0x5,%eax
  800c6f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c72:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c75:	8b 75 18             	mov    0x18(%ebp),%esi
  800c78:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c7a:	85 c0                	test   %eax,%eax
  800c7c:	7f 08                	jg     800c86 <sys_page_map+0x2f>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c7e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c81:	5b                   	pop    %ebx
  800c82:	5e                   	pop    %esi
  800c83:	5f                   	pop    %edi
  800c84:	5d                   	pop    %ebp
  800c85:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c86:	83 ec 0c             	sub    $0xc,%esp
  800c89:	50                   	push   %eax
  800c8a:	6a 05                	push   $0x5
  800c8c:	68 84 13 80 00       	push   $0x801384
  800c91:	6a 23                	push   $0x23
  800c93:	68 a1 13 80 00       	push   $0x8013a1
  800c98:	e8 c1 01 00 00       	call   800e5e <_panic>

00800c9d <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c9d:	f3 0f 1e fb          	endbr32 
  800ca1:	55                   	push   %ebp
  800ca2:	89 e5                	mov    %esp,%ebp
  800ca4:	57                   	push   %edi
  800ca5:	56                   	push   %esi
  800ca6:	53                   	push   %ebx
  800ca7:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800caa:	bb 00 00 00 00       	mov    $0x0,%ebx
  800caf:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb5:	b8 06 00 00 00       	mov    $0x6,%eax
  800cba:	89 df                	mov    %ebx,%edi
  800cbc:	89 de                	mov    %ebx,%esi
  800cbe:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cc0:	85 c0                	test   %eax,%eax
  800cc2:	7f 08                	jg     800ccc <sys_page_unmap+0x2f>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cc4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cc7:	5b                   	pop    %ebx
  800cc8:	5e                   	pop    %esi
  800cc9:	5f                   	pop    %edi
  800cca:	5d                   	pop    %ebp
  800ccb:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ccc:	83 ec 0c             	sub    $0xc,%esp
  800ccf:	50                   	push   %eax
  800cd0:	6a 06                	push   $0x6
  800cd2:	68 84 13 80 00       	push   $0x801384
  800cd7:	6a 23                	push   $0x23
  800cd9:	68 a1 13 80 00       	push   $0x8013a1
  800cde:	e8 7b 01 00 00       	call   800e5e <_panic>

00800ce3 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ce3:	f3 0f 1e fb          	endbr32 
  800ce7:	55                   	push   %ebp
  800ce8:	89 e5                	mov    %esp,%ebp
  800cea:	57                   	push   %edi
  800ceb:	56                   	push   %esi
  800cec:	53                   	push   %ebx
  800ced:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cf0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cf5:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cfb:	b8 08 00 00 00       	mov    $0x8,%eax
  800d00:	89 df                	mov    %ebx,%edi
  800d02:	89 de                	mov    %ebx,%esi
  800d04:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d06:	85 c0                	test   %eax,%eax
  800d08:	7f 08                	jg     800d12 <sys_env_set_status+0x2f>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d0a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d0d:	5b                   	pop    %ebx
  800d0e:	5e                   	pop    %esi
  800d0f:	5f                   	pop    %edi
  800d10:	5d                   	pop    %ebp
  800d11:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d12:	83 ec 0c             	sub    $0xc,%esp
  800d15:	50                   	push   %eax
  800d16:	6a 08                	push   $0x8
  800d18:	68 84 13 80 00       	push   $0x801384
  800d1d:	6a 23                	push   $0x23
  800d1f:	68 a1 13 80 00       	push   $0x8013a1
  800d24:	e8 35 01 00 00       	call   800e5e <_panic>

00800d29 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d29:	f3 0f 1e fb          	endbr32 
  800d2d:	55                   	push   %ebp
  800d2e:	89 e5                	mov    %esp,%ebp
  800d30:	57                   	push   %edi
  800d31:	56                   	push   %esi
  800d32:	53                   	push   %ebx
  800d33:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d36:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d3b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d3e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d41:	b8 09 00 00 00       	mov    $0x9,%eax
  800d46:	89 df                	mov    %ebx,%edi
  800d48:	89 de                	mov    %ebx,%esi
  800d4a:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d4c:	85 c0                	test   %eax,%eax
  800d4e:	7f 08                	jg     800d58 <sys_env_set_pgfault_upcall+0x2f>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d50:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d53:	5b                   	pop    %ebx
  800d54:	5e                   	pop    %esi
  800d55:	5f                   	pop    %edi
  800d56:	5d                   	pop    %ebp
  800d57:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d58:	83 ec 0c             	sub    $0xc,%esp
  800d5b:	50                   	push   %eax
  800d5c:	6a 09                	push   $0x9
  800d5e:	68 84 13 80 00       	push   $0x801384
  800d63:	6a 23                	push   $0x23
  800d65:	68 a1 13 80 00       	push   $0x8013a1
  800d6a:	e8 ef 00 00 00       	call   800e5e <_panic>

00800d6f <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d6f:	f3 0f 1e fb          	endbr32 
  800d73:	55                   	push   %ebp
  800d74:	89 e5                	mov    %esp,%ebp
  800d76:	57                   	push   %edi
  800d77:	56                   	push   %esi
  800d78:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d79:	8b 55 08             	mov    0x8(%ebp),%edx
  800d7c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d7f:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d84:	be 00 00 00 00       	mov    $0x0,%esi
  800d89:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d8c:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d8f:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d91:	5b                   	pop    %ebx
  800d92:	5e                   	pop    %esi
  800d93:	5f                   	pop    %edi
  800d94:	5d                   	pop    %ebp
  800d95:	c3                   	ret    

00800d96 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d96:	f3 0f 1e fb          	endbr32 
  800d9a:	55                   	push   %ebp
  800d9b:	89 e5                	mov    %esp,%ebp
  800d9d:	57                   	push   %edi
  800d9e:	56                   	push   %esi
  800d9f:	53                   	push   %ebx
  800da0:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800da3:	b9 00 00 00 00       	mov    $0x0,%ecx
  800da8:	8b 55 08             	mov    0x8(%ebp),%edx
  800dab:	b8 0c 00 00 00       	mov    $0xc,%eax
  800db0:	89 cb                	mov    %ecx,%ebx
  800db2:	89 cf                	mov    %ecx,%edi
  800db4:	89 ce                	mov    %ecx,%esi
  800db6:	cd 30                	int    $0x30
	if(check && ret > 0)
  800db8:	85 c0                	test   %eax,%eax
  800dba:	7f 08                	jg     800dc4 <sys_ipc_recv+0x2e>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800dbc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dbf:	5b                   	pop    %ebx
  800dc0:	5e                   	pop    %esi
  800dc1:	5f                   	pop    %edi
  800dc2:	5d                   	pop    %ebp
  800dc3:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800dc4:	83 ec 0c             	sub    $0xc,%esp
  800dc7:	50                   	push   %eax
  800dc8:	6a 0c                	push   $0xc
  800dca:	68 84 13 80 00       	push   $0x801384
  800dcf:	6a 23                	push   $0x23
  800dd1:	68 a1 13 80 00       	push   $0x8013a1
  800dd6:	e8 83 00 00 00       	call   800e5e <_panic>

00800ddb <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800ddb:	f3 0f 1e fb          	endbr32 
  800ddf:	55                   	push   %ebp
  800de0:	89 e5                	mov    %esp,%ebp
  800de2:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  800de5:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  800dec:	74 0a                	je     800df8 <set_pgfault_handler+0x1d>
        sys_env_set_pgfault_upcall(0, _pgfault_upcall);
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800dee:	8b 45 08             	mov    0x8(%ebp),%eax
  800df1:	a3 08 20 80 00       	mov    %eax,0x802008
}
  800df6:	c9                   	leave  
  800df7:	c3                   	ret    
		if (sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P) < 0)
  800df8:	83 ec 04             	sub    $0x4,%esp
  800dfb:	6a 07                	push   $0x7
  800dfd:	68 00 f0 bf ee       	push   $0xeebff000
  800e02:	6a 00                	push   $0x0
  800e04:	e8 07 fe ff ff       	call   800c10 <sys_page_alloc>
  800e09:	83 c4 10             	add    $0x10,%esp
  800e0c:	85 c0                	test   %eax,%eax
  800e0e:	78 14                	js     800e24 <set_pgfault_handler+0x49>
        sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  800e10:	83 ec 08             	sub    $0x8,%esp
  800e13:	68 38 0e 80 00       	push   $0x800e38
  800e18:	6a 00                	push   $0x0
  800e1a:	e8 0a ff ff ff       	call   800d29 <sys_env_set_pgfault_upcall>
  800e1f:	83 c4 10             	add    $0x10,%esp
  800e22:	eb ca                	jmp    800dee <set_pgfault_handler+0x13>
            panic("set_pgfault_handler failed.");
  800e24:	83 ec 04             	sub    $0x4,%esp
  800e27:	68 af 13 80 00       	push   $0x8013af
  800e2c:	6a 21                	push   $0x21
  800e2e:	68 cb 13 80 00       	push   $0x8013cb
  800e33:	e8 26 00 00 00       	call   800e5e <_panic>

00800e38 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800e38:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800e39:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  800e3e:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800e40:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	addl $8, %esp
  800e43:	83 c4 08             	add    $0x8,%esp
	movl 32(%esp), %eax
  800e46:	8b 44 24 20          	mov    0x20(%esp),%eax
	movl 40(%esp), %edx
  800e4a:	8b 54 24 28          	mov    0x28(%esp),%edx
	subl $4, %edx
  800e4e:	83 ea 04             	sub    $0x4,%edx
	movl %eax, (%edx)
  800e51:	89 02                	mov    %eax,(%edx)
	movl %edx, 40(%esp)
  800e53:	89 54 24 28          	mov    %edx,0x28(%esp)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal
  800e57:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp
  800e58:	83 c4 04             	add    $0x4,%esp
	popfl
  800e5b:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  800e5c:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  800e5d:	c3                   	ret    

00800e5e <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800e5e:	f3 0f 1e fb          	endbr32 
  800e62:	55                   	push   %ebp
  800e63:	89 e5                	mov    %esp,%ebp
  800e65:	56                   	push   %esi
  800e66:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800e67:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800e6a:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800e70:	e8 55 fd ff ff       	call   800bca <sys_getenvid>
  800e75:	83 ec 0c             	sub    $0xc,%esp
  800e78:	ff 75 0c             	pushl  0xc(%ebp)
  800e7b:	ff 75 08             	pushl  0x8(%ebp)
  800e7e:	56                   	push   %esi
  800e7f:	50                   	push   %eax
  800e80:	68 dc 13 80 00       	push   $0x8013dc
  800e85:	e8 fb f2 ff ff       	call   800185 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800e8a:	83 c4 18             	add    $0x18,%esp
  800e8d:	53                   	push   %ebx
  800e8e:	ff 75 10             	pushl  0x10(%ebp)
  800e91:	e8 9a f2 ff ff       	call   800130 <vcprintf>
	cprintf("\n");
  800e96:	c7 04 24 3a 11 80 00 	movl   $0x80113a,(%esp)
  800e9d:	e8 e3 f2 ff ff       	call   800185 <cprintf>
  800ea2:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800ea5:	cc                   	int3   
  800ea6:	eb fd                	jmp    800ea5 <_panic+0x47>
  800ea8:	66 90                	xchg   %ax,%ax
  800eaa:	66 90                	xchg   %ax,%ax
  800eac:	66 90                	xchg   %ax,%ax
  800eae:	66 90                	xchg   %ax,%ax

00800eb0 <__udivdi3>:
  800eb0:	f3 0f 1e fb          	endbr32 
  800eb4:	55                   	push   %ebp
  800eb5:	57                   	push   %edi
  800eb6:	56                   	push   %esi
  800eb7:	53                   	push   %ebx
  800eb8:	83 ec 1c             	sub    $0x1c,%esp
  800ebb:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800ebf:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800ec3:	8b 74 24 34          	mov    0x34(%esp),%esi
  800ec7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800ecb:	85 d2                	test   %edx,%edx
  800ecd:	75 19                	jne    800ee8 <__udivdi3+0x38>
  800ecf:	39 f3                	cmp    %esi,%ebx
  800ed1:	76 4d                	jbe    800f20 <__udivdi3+0x70>
  800ed3:	31 ff                	xor    %edi,%edi
  800ed5:	89 e8                	mov    %ebp,%eax
  800ed7:	89 f2                	mov    %esi,%edx
  800ed9:	f7 f3                	div    %ebx
  800edb:	89 fa                	mov    %edi,%edx
  800edd:	83 c4 1c             	add    $0x1c,%esp
  800ee0:	5b                   	pop    %ebx
  800ee1:	5e                   	pop    %esi
  800ee2:	5f                   	pop    %edi
  800ee3:	5d                   	pop    %ebp
  800ee4:	c3                   	ret    
  800ee5:	8d 76 00             	lea    0x0(%esi),%esi
  800ee8:	39 f2                	cmp    %esi,%edx
  800eea:	76 14                	jbe    800f00 <__udivdi3+0x50>
  800eec:	31 ff                	xor    %edi,%edi
  800eee:	31 c0                	xor    %eax,%eax
  800ef0:	89 fa                	mov    %edi,%edx
  800ef2:	83 c4 1c             	add    $0x1c,%esp
  800ef5:	5b                   	pop    %ebx
  800ef6:	5e                   	pop    %esi
  800ef7:	5f                   	pop    %edi
  800ef8:	5d                   	pop    %ebp
  800ef9:	c3                   	ret    
  800efa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800f00:	0f bd fa             	bsr    %edx,%edi
  800f03:	83 f7 1f             	xor    $0x1f,%edi
  800f06:	75 48                	jne    800f50 <__udivdi3+0xa0>
  800f08:	39 f2                	cmp    %esi,%edx
  800f0a:	72 06                	jb     800f12 <__udivdi3+0x62>
  800f0c:	31 c0                	xor    %eax,%eax
  800f0e:	39 eb                	cmp    %ebp,%ebx
  800f10:	77 de                	ja     800ef0 <__udivdi3+0x40>
  800f12:	b8 01 00 00 00       	mov    $0x1,%eax
  800f17:	eb d7                	jmp    800ef0 <__udivdi3+0x40>
  800f19:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f20:	89 d9                	mov    %ebx,%ecx
  800f22:	85 db                	test   %ebx,%ebx
  800f24:	75 0b                	jne    800f31 <__udivdi3+0x81>
  800f26:	b8 01 00 00 00       	mov    $0x1,%eax
  800f2b:	31 d2                	xor    %edx,%edx
  800f2d:	f7 f3                	div    %ebx
  800f2f:	89 c1                	mov    %eax,%ecx
  800f31:	31 d2                	xor    %edx,%edx
  800f33:	89 f0                	mov    %esi,%eax
  800f35:	f7 f1                	div    %ecx
  800f37:	89 c6                	mov    %eax,%esi
  800f39:	89 e8                	mov    %ebp,%eax
  800f3b:	89 f7                	mov    %esi,%edi
  800f3d:	f7 f1                	div    %ecx
  800f3f:	89 fa                	mov    %edi,%edx
  800f41:	83 c4 1c             	add    $0x1c,%esp
  800f44:	5b                   	pop    %ebx
  800f45:	5e                   	pop    %esi
  800f46:	5f                   	pop    %edi
  800f47:	5d                   	pop    %ebp
  800f48:	c3                   	ret    
  800f49:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f50:	89 f9                	mov    %edi,%ecx
  800f52:	b8 20 00 00 00       	mov    $0x20,%eax
  800f57:	29 f8                	sub    %edi,%eax
  800f59:	d3 e2                	shl    %cl,%edx
  800f5b:	89 54 24 08          	mov    %edx,0x8(%esp)
  800f5f:	89 c1                	mov    %eax,%ecx
  800f61:	89 da                	mov    %ebx,%edx
  800f63:	d3 ea                	shr    %cl,%edx
  800f65:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800f69:	09 d1                	or     %edx,%ecx
  800f6b:	89 f2                	mov    %esi,%edx
  800f6d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800f71:	89 f9                	mov    %edi,%ecx
  800f73:	d3 e3                	shl    %cl,%ebx
  800f75:	89 c1                	mov    %eax,%ecx
  800f77:	d3 ea                	shr    %cl,%edx
  800f79:	89 f9                	mov    %edi,%ecx
  800f7b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800f7f:	89 eb                	mov    %ebp,%ebx
  800f81:	d3 e6                	shl    %cl,%esi
  800f83:	89 c1                	mov    %eax,%ecx
  800f85:	d3 eb                	shr    %cl,%ebx
  800f87:	09 de                	or     %ebx,%esi
  800f89:	89 f0                	mov    %esi,%eax
  800f8b:	f7 74 24 08          	divl   0x8(%esp)
  800f8f:	89 d6                	mov    %edx,%esi
  800f91:	89 c3                	mov    %eax,%ebx
  800f93:	f7 64 24 0c          	mull   0xc(%esp)
  800f97:	39 d6                	cmp    %edx,%esi
  800f99:	72 15                	jb     800fb0 <__udivdi3+0x100>
  800f9b:	89 f9                	mov    %edi,%ecx
  800f9d:	d3 e5                	shl    %cl,%ebp
  800f9f:	39 c5                	cmp    %eax,%ebp
  800fa1:	73 04                	jae    800fa7 <__udivdi3+0xf7>
  800fa3:	39 d6                	cmp    %edx,%esi
  800fa5:	74 09                	je     800fb0 <__udivdi3+0x100>
  800fa7:	89 d8                	mov    %ebx,%eax
  800fa9:	31 ff                	xor    %edi,%edi
  800fab:	e9 40 ff ff ff       	jmp    800ef0 <__udivdi3+0x40>
  800fb0:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800fb3:	31 ff                	xor    %edi,%edi
  800fb5:	e9 36 ff ff ff       	jmp    800ef0 <__udivdi3+0x40>
  800fba:	66 90                	xchg   %ax,%ax
  800fbc:	66 90                	xchg   %ax,%ax
  800fbe:	66 90                	xchg   %ax,%ax

00800fc0 <__umoddi3>:
  800fc0:	f3 0f 1e fb          	endbr32 
  800fc4:	55                   	push   %ebp
  800fc5:	57                   	push   %edi
  800fc6:	56                   	push   %esi
  800fc7:	53                   	push   %ebx
  800fc8:	83 ec 1c             	sub    $0x1c,%esp
  800fcb:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  800fcf:	8b 74 24 30          	mov    0x30(%esp),%esi
  800fd3:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800fd7:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800fdb:	85 c0                	test   %eax,%eax
  800fdd:	75 19                	jne    800ff8 <__umoddi3+0x38>
  800fdf:	39 df                	cmp    %ebx,%edi
  800fe1:	76 5d                	jbe    801040 <__umoddi3+0x80>
  800fe3:	89 f0                	mov    %esi,%eax
  800fe5:	89 da                	mov    %ebx,%edx
  800fe7:	f7 f7                	div    %edi
  800fe9:	89 d0                	mov    %edx,%eax
  800feb:	31 d2                	xor    %edx,%edx
  800fed:	83 c4 1c             	add    $0x1c,%esp
  800ff0:	5b                   	pop    %ebx
  800ff1:	5e                   	pop    %esi
  800ff2:	5f                   	pop    %edi
  800ff3:	5d                   	pop    %ebp
  800ff4:	c3                   	ret    
  800ff5:	8d 76 00             	lea    0x0(%esi),%esi
  800ff8:	89 f2                	mov    %esi,%edx
  800ffa:	39 d8                	cmp    %ebx,%eax
  800ffc:	76 12                	jbe    801010 <__umoddi3+0x50>
  800ffe:	89 f0                	mov    %esi,%eax
  801000:	89 da                	mov    %ebx,%edx
  801002:	83 c4 1c             	add    $0x1c,%esp
  801005:	5b                   	pop    %ebx
  801006:	5e                   	pop    %esi
  801007:	5f                   	pop    %edi
  801008:	5d                   	pop    %ebp
  801009:	c3                   	ret    
  80100a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801010:	0f bd e8             	bsr    %eax,%ebp
  801013:	83 f5 1f             	xor    $0x1f,%ebp
  801016:	75 50                	jne    801068 <__umoddi3+0xa8>
  801018:	39 d8                	cmp    %ebx,%eax
  80101a:	0f 82 e0 00 00 00    	jb     801100 <__umoddi3+0x140>
  801020:	89 d9                	mov    %ebx,%ecx
  801022:	39 f7                	cmp    %esi,%edi
  801024:	0f 86 d6 00 00 00    	jbe    801100 <__umoddi3+0x140>
  80102a:	89 d0                	mov    %edx,%eax
  80102c:	89 ca                	mov    %ecx,%edx
  80102e:	83 c4 1c             	add    $0x1c,%esp
  801031:	5b                   	pop    %ebx
  801032:	5e                   	pop    %esi
  801033:	5f                   	pop    %edi
  801034:	5d                   	pop    %ebp
  801035:	c3                   	ret    
  801036:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80103d:	8d 76 00             	lea    0x0(%esi),%esi
  801040:	89 fd                	mov    %edi,%ebp
  801042:	85 ff                	test   %edi,%edi
  801044:	75 0b                	jne    801051 <__umoddi3+0x91>
  801046:	b8 01 00 00 00       	mov    $0x1,%eax
  80104b:	31 d2                	xor    %edx,%edx
  80104d:	f7 f7                	div    %edi
  80104f:	89 c5                	mov    %eax,%ebp
  801051:	89 d8                	mov    %ebx,%eax
  801053:	31 d2                	xor    %edx,%edx
  801055:	f7 f5                	div    %ebp
  801057:	89 f0                	mov    %esi,%eax
  801059:	f7 f5                	div    %ebp
  80105b:	89 d0                	mov    %edx,%eax
  80105d:	31 d2                	xor    %edx,%edx
  80105f:	eb 8c                	jmp    800fed <__umoddi3+0x2d>
  801061:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801068:	89 e9                	mov    %ebp,%ecx
  80106a:	ba 20 00 00 00       	mov    $0x20,%edx
  80106f:	29 ea                	sub    %ebp,%edx
  801071:	d3 e0                	shl    %cl,%eax
  801073:	89 44 24 08          	mov    %eax,0x8(%esp)
  801077:	89 d1                	mov    %edx,%ecx
  801079:	89 f8                	mov    %edi,%eax
  80107b:	d3 e8                	shr    %cl,%eax
  80107d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801081:	89 54 24 04          	mov    %edx,0x4(%esp)
  801085:	8b 54 24 04          	mov    0x4(%esp),%edx
  801089:	09 c1                	or     %eax,%ecx
  80108b:	89 d8                	mov    %ebx,%eax
  80108d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801091:	89 e9                	mov    %ebp,%ecx
  801093:	d3 e7                	shl    %cl,%edi
  801095:	89 d1                	mov    %edx,%ecx
  801097:	d3 e8                	shr    %cl,%eax
  801099:	89 e9                	mov    %ebp,%ecx
  80109b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80109f:	d3 e3                	shl    %cl,%ebx
  8010a1:	89 c7                	mov    %eax,%edi
  8010a3:	89 d1                	mov    %edx,%ecx
  8010a5:	89 f0                	mov    %esi,%eax
  8010a7:	d3 e8                	shr    %cl,%eax
  8010a9:	89 e9                	mov    %ebp,%ecx
  8010ab:	89 fa                	mov    %edi,%edx
  8010ad:	d3 e6                	shl    %cl,%esi
  8010af:	09 d8                	or     %ebx,%eax
  8010b1:	f7 74 24 08          	divl   0x8(%esp)
  8010b5:	89 d1                	mov    %edx,%ecx
  8010b7:	89 f3                	mov    %esi,%ebx
  8010b9:	f7 64 24 0c          	mull   0xc(%esp)
  8010bd:	89 c6                	mov    %eax,%esi
  8010bf:	89 d7                	mov    %edx,%edi
  8010c1:	39 d1                	cmp    %edx,%ecx
  8010c3:	72 06                	jb     8010cb <__umoddi3+0x10b>
  8010c5:	75 10                	jne    8010d7 <__umoddi3+0x117>
  8010c7:	39 c3                	cmp    %eax,%ebx
  8010c9:	73 0c                	jae    8010d7 <__umoddi3+0x117>
  8010cb:	2b 44 24 0c          	sub    0xc(%esp),%eax
  8010cf:	1b 54 24 08          	sbb    0x8(%esp),%edx
  8010d3:	89 d7                	mov    %edx,%edi
  8010d5:	89 c6                	mov    %eax,%esi
  8010d7:	89 ca                	mov    %ecx,%edx
  8010d9:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8010de:	29 f3                	sub    %esi,%ebx
  8010e0:	19 fa                	sbb    %edi,%edx
  8010e2:	89 d0                	mov    %edx,%eax
  8010e4:	d3 e0                	shl    %cl,%eax
  8010e6:	89 e9                	mov    %ebp,%ecx
  8010e8:	d3 eb                	shr    %cl,%ebx
  8010ea:	d3 ea                	shr    %cl,%edx
  8010ec:	09 d8                	or     %ebx,%eax
  8010ee:	83 c4 1c             	add    $0x1c,%esp
  8010f1:	5b                   	pop    %ebx
  8010f2:	5e                   	pop    %esi
  8010f3:	5f                   	pop    %edi
  8010f4:	5d                   	pop    %ebp
  8010f5:	c3                   	ret    
  8010f6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8010fd:	8d 76 00             	lea    0x0(%esi),%esi
  801100:	29 fe                	sub    %edi,%esi
  801102:	19 c3                	sbb    %eax,%ebx
  801104:	89 f2                	mov    %esi,%edx
  801106:	89 d9                	mov    %ebx,%ecx
  801108:	e9 1d ff ff ff       	jmp    80102a <__umoddi3+0x6a>
