
obj/user/faultreadkernel:     file format elf32-i386


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
  80002c:	e8 21 00 00 00       	call   800052 <libmain>
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
  80003a:	83 ec 10             	sub    $0x10,%esp
	cprintf("I read %08x from location 0xf0100000!\n", *(unsigned*)0xf0100000);
  80003d:	ff 35 00 00 10 f0    	pushl  0xf0100000
  800043:	68 60 10 80 00       	push   $0x801060
  800048:	e8 02 01 00 00       	call   80014f <cprintf>
}
  80004d:	83 c4 10             	add    $0x10,%esp
  800050:	c9                   	leave  
  800051:	c3                   	ret    

00800052 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800052:	f3 0f 1e fb          	endbr32 
  800056:	55                   	push   %ebp
  800057:	89 e5                	mov    %esp,%ebp
  800059:	56                   	push   %esi
  80005a:	53                   	push   %ebx
  80005b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80005e:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv=&envs[ENVX(sys_getenvid())];
  800061:	e8 2e 0b 00 00       	call   800b94 <sys_getenvid>
  800066:	25 ff 03 00 00       	and    $0x3ff,%eax
  80006b:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80006e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800073:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800078:	85 db                	test   %ebx,%ebx
  80007a:	7e 07                	jle    800083 <libmain+0x31>
		binaryname = argv[0];
  80007c:	8b 06                	mov    (%esi),%eax
  80007e:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800083:	83 ec 08             	sub    $0x8,%esp
  800086:	56                   	push   %esi
  800087:	53                   	push   %ebx
  800088:	e8 a6 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80008d:	e8 0a 00 00 00       	call   80009c <exit>
}
  800092:	83 c4 10             	add    $0x10,%esp
  800095:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800098:	5b                   	pop    %ebx
  800099:	5e                   	pop    %esi
  80009a:	5d                   	pop    %ebp
  80009b:	c3                   	ret    

0080009c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80009c:	f3 0f 1e fb          	endbr32 
  8000a0:	55                   	push   %ebp
  8000a1:	89 e5                	mov    %esp,%ebp
  8000a3:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000a6:	6a 00                	push   $0x0
  8000a8:	e8 a2 0a 00 00       	call   800b4f <sys_env_destroy>
}
  8000ad:	83 c4 10             	add    $0x10,%esp
  8000b0:	c9                   	leave  
  8000b1:	c3                   	ret    

008000b2 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000b2:	f3 0f 1e fb          	endbr32 
  8000b6:	55                   	push   %ebp
  8000b7:	89 e5                	mov    %esp,%ebp
  8000b9:	53                   	push   %ebx
  8000ba:	83 ec 04             	sub    $0x4,%esp
  8000bd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000c0:	8b 13                	mov    (%ebx),%edx
  8000c2:	8d 42 01             	lea    0x1(%edx),%eax
  8000c5:	89 03                	mov    %eax,(%ebx)
  8000c7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000ca:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000ce:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000d3:	74 09                	je     8000de <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8000d5:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000d9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000dc:	c9                   	leave  
  8000dd:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8000de:	83 ec 08             	sub    $0x8,%esp
  8000e1:	68 ff 00 00 00       	push   $0xff
  8000e6:	8d 43 08             	lea    0x8(%ebx),%eax
  8000e9:	50                   	push   %eax
  8000ea:	e8 1b 0a 00 00       	call   800b0a <sys_cputs>
		b->idx = 0;
  8000ef:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8000f5:	83 c4 10             	add    $0x10,%esp
  8000f8:	eb db                	jmp    8000d5 <putch+0x23>

008000fa <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8000fa:	f3 0f 1e fb          	endbr32 
  8000fe:	55                   	push   %ebp
  8000ff:	89 e5                	mov    %esp,%ebp
  800101:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800107:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80010e:	00 00 00 
	b.cnt = 0;
  800111:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800118:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80011b:	ff 75 0c             	pushl  0xc(%ebp)
  80011e:	ff 75 08             	pushl  0x8(%ebp)
  800121:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800127:	50                   	push   %eax
  800128:	68 b2 00 80 00       	push   $0x8000b2
  80012d:	e8 20 01 00 00       	call   800252 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800132:	83 c4 08             	add    $0x8,%esp
  800135:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80013b:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800141:	50                   	push   %eax
  800142:	e8 c3 09 00 00       	call   800b0a <sys_cputs>

	return b.cnt;
}
  800147:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80014d:	c9                   	leave  
  80014e:	c3                   	ret    

0080014f <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80014f:	f3 0f 1e fb          	endbr32 
  800153:	55                   	push   %ebp
  800154:	89 e5                	mov    %esp,%ebp
  800156:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800159:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80015c:	50                   	push   %eax
  80015d:	ff 75 08             	pushl  0x8(%ebp)
  800160:	e8 95 ff ff ff       	call   8000fa <vcprintf>
	va_end(ap);

	return cnt;
}
  800165:	c9                   	leave  
  800166:	c3                   	ret    

00800167 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800167:	55                   	push   %ebp
  800168:	89 e5                	mov    %esp,%ebp
  80016a:	57                   	push   %edi
  80016b:	56                   	push   %esi
  80016c:	53                   	push   %ebx
  80016d:	83 ec 1c             	sub    $0x1c,%esp
  800170:	89 c7                	mov    %eax,%edi
  800172:	89 d6                	mov    %edx,%esi
  800174:	8b 45 08             	mov    0x8(%ebp),%eax
  800177:	8b 55 0c             	mov    0xc(%ebp),%edx
  80017a:	89 d1                	mov    %edx,%ecx
  80017c:	89 c2                	mov    %eax,%edx
  80017e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800181:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800184:	8b 45 10             	mov    0x10(%ebp),%eax
  800187:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80018a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80018d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800194:	39 c2                	cmp    %eax,%edx
  800196:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800199:	72 3e                	jb     8001d9 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80019b:	83 ec 0c             	sub    $0xc,%esp
  80019e:	ff 75 18             	pushl  0x18(%ebp)
  8001a1:	83 eb 01             	sub    $0x1,%ebx
  8001a4:	53                   	push   %ebx
  8001a5:	50                   	push   %eax
  8001a6:	83 ec 08             	sub    $0x8,%esp
  8001a9:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001ac:	ff 75 e0             	pushl  -0x20(%ebp)
  8001af:	ff 75 dc             	pushl  -0x24(%ebp)
  8001b2:	ff 75 d8             	pushl  -0x28(%ebp)
  8001b5:	e8 36 0c 00 00       	call   800df0 <__udivdi3>
  8001ba:	83 c4 18             	add    $0x18,%esp
  8001bd:	52                   	push   %edx
  8001be:	50                   	push   %eax
  8001bf:	89 f2                	mov    %esi,%edx
  8001c1:	89 f8                	mov    %edi,%eax
  8001c3:	e8 9f ff ff ff       	call   800167 <printnum>
  8001c8:	83 c4 20             	add    $0x20,%esp
  8001cb:	eb 13                	jmp    8001e0 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001cd:	83 ec 08             	sub    $0x8,%esp
  8001d0:	56                   	push   %esi
  8001d1:	ff 75 18             	pushl  0x18(%ebp)
  8001d4:	ff d7                	call   *%edi
  8001d6:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8001d9:	83 eb 01             	sub    $0x1,%ebx
  8001dc:	85 db                	test   %ebx,%ebx
  8001de:	7f ed                	jg     8001cd <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001e0:	83 ec 08             	sub    $0x8,%esp
  8001e3:	56                   	push   %esi
  8001e4:	83 ec 04             	sub    $0x4,%esp
  8001e7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001ea:	ff 75 e0             	pushl  -0x20(%ebp)
  8001ed:	ff 75 dc             	pushl  -0x24(%ebp)
  8001f0:	ff 75 d8             	pushl  -0x28(%ebp)
  8001f3:	e8 08 0d 00 00       	call   800f00 <__umoddi3>
  8001f8:	83 c4 14             	add    $0x14,%esp
  8001fb:	0f be 80 91 10 80 00 	movsbl 0x801091(%eax),%eax
  800202:	50                   	push   %eax
  800203:	ff d7                	call   *%edi
}
  800205:	83 c4 10             	add    $0x10,%esp
  800208:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80020b:	5b                   	pop    %ebx
  80020c:	5e                   	pop    %esi
  80020d:	5f                   	pop    %edi
  80020e:	5d                   	pop    %ebp
  80020f:	c3                   	ret    

00800210 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800210:	f3 0f 1e fb          	endbr32 
  800214:	55                   	push   %ebp
  800215:	89 e5                	mov    %esp,%ebp
  800217:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80021a:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80021e:	8b 10                	mov    (%eax),%edx
  800220:	3b 50 04             	cmp    0x4(%eax),%edx
  800223:	73 0a                	jae    80022f <sprintputch+0x1f>
		*b->buf++ = ch;
  800225:	8d 4a 01             	lea    0x1(%edx),%ecx
  800228:	89 08                	mov    %ecx,(%eax)
  80022a:	8b 45 08             	mov    0x8(%ebp),%eax
  80022d:	88 02                	mov    %al,(%edx)
}
  80022f:	5d                   	pop    %ebp
  800230:	c3                   	ret    

00800231 <printfmt>:
{
  800231:	f3 0f 1e fb          	endbr32 
  800235:	55                   	push   %ebp
  800236:	89 e5                	mov    %esp,%ebp
  800238:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80023b:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80023e:	50                   	push   %eax
  80023f:	ff 75 10             	pushl  0x10(%ebp)
  800242:	ff 75 0c             	pushl  0xc(%ebp)
  800245:	ff 75 08             	pushl  0x8(%ebp)
  800248:	e8 05 00 00 00       	call   800252 <vprintfmt>
}
  80024d:	83 c4 10             	add    $0x10,%esp
  800250:	c9                   	leave  
  800251:	c3                   	ret    

00800252 <vprintfmt>:
{
  800252:	f3 0f 1e fb          	endbr32 
  800256:	55                   	push   %ebp
  800257:	89 e5                	mov    %esp,%ebp
  800259:	57                   	push   %edi
  80025a:	56                   	push   %esi
  80025b:	53                   	push   %ebx
  80025c:	83 ec 3c             	sub    $0x3c,%esp
  80025f:	8b 75 08             	mov    0x8(%ebp),%esi
  800262:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800265:	8b 7d 10             	mov    0x10(%ebp),%edi
  800268:	e9 cd 03 00 00       	jmp    80063a <vprintfmt+0x3e8>
		padc = ' ';
  80026d:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800271:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800278:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  80027f:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800286:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80028b:	8d 47 01             	lea    0x1(%edi),%eax
  80028e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800291:	0f b6 17             	movzbl (%edi),%edx
  800294:	8d 42 dd             	lea    -0x23(%edx),%eax
  800297:	3c 55                	cmp    $0x55,%al
  800299:	0f 87 1e 04 00 00    	ja     8006bd <vprintfmt+0x46b>
  80029f:	0f b6 c0             	movzbl %al,%eax
  8002a2:	3e ff 24 85 60 11 80 	notrack jmp *0x801160(,%eax,4)
  8002a9:	00 
  8002aa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8002ad:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  8002b1:	eb d8                	jmp    80028b <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8002b3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8002b6:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  8002ba:	eb cf                	jmp    80028b <vprintfmt+0x39>
  8002bc:	0f b6 d2             	movzbl %dl,%edx
  8002bf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8002c2:	b8 00 00 00 00       	mov    $0x0,%eax
  8002c7:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8002ca:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8002cd:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8002d1:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8002d4:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8002d7:	83 f9 09             	cmp    $0x9,%ecx
  8002da:	77 55                	ja     800331 <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  8002dc:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8002df:	eb e9                	jmp    8002ca <vprintfmt+0x78>
			precision = va_arg(ap, int);
  8002e1:	8b 45 14             	mov    0x14(%ebp),%eax
  8002e4:	8b 00                	mov    (%eax),%eax
  8002e6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002e9:	8b 45 14             	mov    0x14(%ebp),%eax
  8002ec:	8d 40 04             	lea    0x4(%eax),%eax
  8002ef:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8002f2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8002f5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8002f9:	79 90                	jns    80028b <vprintfmt+0x39>
				width = precision, precision = -1;
  8002fb:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8002fe:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800301:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800308:	eb 81                	jmp    80028b <vprintfmt+0x39>
  80030a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80030d:	85 c0                	test   %eax,%eax
  80030f:	ba 00 00 00 00       	mov    $0x0,%edx
  800314:	0f 49 d0             	cmovns %eax,%edx
  800317:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80031a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80031d:	e9 69 ff ff ff       	jmp    80028b <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800322:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800325:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  80032c:	e9 5a ff ff ff       	jmp    80028b <vprintfmt+0x39>
  800331:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800334:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800337:	eb bc                	jmp    8002f5 <vprintfmt+0xa3>
			lflag++;
  800339:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80033c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80033f:	e9 47 ff ff ff       	jmp    80028b <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  800344:	8b 45 14             	mov    0x14(%ebp),%eax
  800347:	8d 78 04             	lea    0x4(%eax),%edi
  80034a:	83 ec 08             	sub    $0x8,%esp
  80034d:	53                   	push   %ebx
  80034e:	ff 30                	pushl  (%eax)
  800350:	ff d6                	call   *%esi
			break;
  800352:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800355:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800358:	e9 da 02 00 00       	jmp    800637 <vprintfmt+0x3e5>
			err = va_arg(ap, int);
  80035d:	8b 45 14             	mov    0x14(%ebp),%eax
  800360:	8d 78 04             	lea    0x4(%eax),%edi
  800363:	8b 00                	mov    (%eax),%eax
  800365:	99                   	cltd   
  800366:	31 d0                	xor    %edx,%eax
  800368:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80036a:	83 f8 08             	cmp    $0x8,%eax
  80036d:	7f 23                	jg     800392 <vprintfmt+0x140>
  80036f:	8b 14 85 c0 12 80 00 	mov    0x8012c0(,%eax,4),%edx
  800376:	85 d2                	test   %edx,%edx
  800378:	74 18                	je     800392 <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  80037a:	52                   	push   %edx
  80037b:	68 b2 10 80 00       	push   $0x8010b2
  800380:	53                   	push   %ebx
  800381:	56                   	push   %esi
  800382:	e8 aa fe ff ff       	call   800231 <printfmt>
  800387:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80038a:	89 7d 14             	mov    %edi,0x14(%ebp)
  80038d:	e9 a5 02 00 00       	jmp    800637 <vprintfmt+0x3e5>
				printfmt(putch, putdat, "error %d", err);
  800392:	50                   	push   %eax
  800393:	68 a9 10 80 00       	push   $0x8010a9
  800398:	53                   	push   %ebx
  800399:	56                   	push   %esi
  80039a:	e8 92 fe ff ff       	call   800231 <printfmt>
  80039f:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003a2:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8003a5:	e9 8d 02 00 00       	jmp    800637 <vprintfmt+0x3e5>
			if ((p = va_arg(ap, char *)) == NULL)
  8003aa:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ad:	83 c0 04             	add    $0x4,%eax
  8003b0:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8003b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b6:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  8003b8:	85 d2                	test   %edx,%edx
  8003ba:	b8 a2 10 80 00       	mov    $0x8010a2,%eax
  8003bf:	0f 45 c2             	cmovne %edx,%eax
  8003c2:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8003c5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003c9:	7e 06                	jle    8003d1 <vprintfmt+0x17f>
  8003cb:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  8003cf:	75 0d                	jne    8003de <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  8003d1:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8003d4:	89 c7                	mov    %eax,%edi
  8003d6:	03 45 e0             	add    -0x20(%ebp),%eax
  8003d9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003dc:	eb 55                	jmp    800433 <vprintfmt+0x1e1>
  8003de:	83 ec 08             	sub    $0x8,%esp
  8003e1:	ff 75 d8             	pushl  -0x28(%ebp)
  8003e4:	ff 75 cc             	pushl  -0x34(%ebp)
  8003e7:	e8 85 03 00 00       	call   800771 <strnlen>
  8003ec:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8003ef:	29 c2                	sub    %eax,%edx
  8003f1:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  8003f4:	83 c4 10             	add    $0x10,%esp
  8003f7:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  8003f9:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8003fd:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800400:	85 ff                	test   %edi,%edi
  800402:	7e 11                	jle    800415 <vprintfmt+0x1c3>
					putch(padc, putdat);
  800404:	83 ec 08             	sub    $0x8,%esp
  800407:	53                   	push   %ebx
  800408:	ff 75 e0             	pushl  -0x20(%ebp)
  80040b:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  80040d:	83 ef 01             	sub    $0x1,%edi
  800410:	83 c4 10             	add    $0x10,%esp
  800413:	eb eb                	jmp    800400 <vprintfmt+0x1ae>
  800415:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800418:	85 d2                	test   %edx,%edx
  80041a:	b8 00 00 00 00       	mov    $0x0,%eax
  80041f:	0f 49 c2             	cmovns %edx,%eax
  800422:	29 c2                	sub    %eax,%edx
  800424:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800427:	eb a8                	jmp    8003d1 <vprintfmt+0x17f>
					putch(ch, putdat);
  800429:	83 ec 08             	sub    $0x8,%esp
  80042c:	53                   	push   %ebx
  80042d:	52                   	push   %edx
  80042e:	ff d6                	call   *%esi
  800430:	83 c4 10             	add    $0x10,%esp
  800433:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800436:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800438:	83 c7 01             	add    $0x1,%edi
  80043b:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80043f:	0f be d0             	movsbl %al,%edx
  800442:	85 d2                	test   %edx,%edx
  800444:	74 4b                	je     800491 <vprintfmt+0x23f>
  800446:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80044a:	78 06                	js     800452 <vprintfmt+0x200>
  80044c:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800450:	78 1e                	js     800470 <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
  800452:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800456:	74 d1                	je     800429 <vprintfmt+0x1d7>
  800458:	0f be c0             	movsbl %al,%eax
  80045b:	83 e8 20             	sub    $0x20,%eax
  80045e:	83 f8 5e             	cmp    $0x5e,%eax
  800461:	76 c6                	jbe    800429 <vprintfmt+0x1d7>
					putch('?', putdat);
  800463:	83 ec 08             	sub    $0x8,%esp
  800466:	53                   	push   %ebx
  800467:	6a 3f                	push   $0x3f
  800469:	ff d6                	call   *%esi
  80046b:	83 c4 10             	add    $0x10,%esp
  80046e:	eb c3                	jmp    800433 <vprintfmt+0x1e1>
  800470:	89 cf                	mov    %ecx,%edi
  800472:	eb 0e                	jmp    800482 <vprintfmt+0x230>
				putch(' ', putdat);
  800474:	83 ec 08             	sub    $0x8,%esp
  800477:	53                   	push   %ebx
  800478:	6a 20                	push   $0x20
  80047a:	ff d6                	call   *%esi
			for (; width > 0; width--)
  80047c:	83 ef 01             	sub    $0x1,%edi
  80047f:	83 c4 10             	add    $0x10,%esp
  800482:	85 ff                	test   %edi,%edi
  800484:	7f ee                	jg     800474 <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  800486:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800489:	89 45 14             	mov    %eax,0x14(%ebp)
  80048c:	e9 a6 01 00 00       	jmp    800637 <vprintfmt+0x3e5>
  800491:	89 cf                	mov    %ecx,%edi
  800493:	eb ed                	jmp    800482 <vprintfmt+0x230>
	if (lflag >= 2)
  800495:	83 f9 01             	cmp    $0x1,%ecx
  800498:	7f 1f                	jg     8004b9 <vprintfmt+0x267>
	else if (lflag)
  80049a:	85 c9                	test   %ecx,%ecx
  80049c:	74 67                	je     800505 <vprintfmt+0x2b3>
		return va_arg(*ap, long);
  80049e:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a1:	8b 00                	mov    (%eax),%eax
  8004a3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004a6:	89 c1                	mov    %eax,%ecx
  8004a8:	c1 f9 1f             	sar    $0x1f,%ecx
  8004ab:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8004ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b1:	8d 40 04             	lea    0x4(%eax),%eax
  8004b4:	89 45 14             	mov    %eax,0x14(%ebp)
  8004b7:	eb 17                	jmp    8004d0 <vprintfmt+0x27e>
		return va_arg(*ap, long long);
  8004b9:	8b 45 14             	mov    0x14(%ebp),%eax
  8004bc:	8b 50 04             	mov    0x4(%eax),%edx
  8004bf:	8b 00                	mov    (%eax),%eax
  8004c1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004c4:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8004c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ca:	8d 40 08             	lea    0x8(%eax),%eax
  8004cd:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8004d0:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8004d3:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8004d6:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  8004db:	85 c9                	test   %ecx,%ecx
  8004dd:	0f 89 3a 01 00 00    	jns    80061d <vprintfmt+0x3cb>
				putch('-', putdat);
  8004e3:	83 ec 08             	sub    $0x8,%esp
  8004e6:	53                   	push   %ebx
  8004e7:	6a 2d                	push   $0x2d
  8004e9:	ff d6                	call   *%esi
				num = -(long long) num;
  8004eb:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8004ee:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8004f1:	f7 da                	neg    %edx
  8004f3:	83 d1 00             	adc    $0x0,%ecx
  8004f6:	f7 d9                	neg    %ecx
  8004f8:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8004fb:	b8 0a 00 00 00       	mov    $0xa,%eax
  800500:	e9 18 01 00 00       	jmp    80061d <vprintfmt+0x3cb>
		return va_arg(*ap, int);
  800505:	8b 45 14             	mov    0x14(%ebp),%eax
  800508:	8b 00                	mov    (%eax),%eax
  80050a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80050d:	89 c1                	mov    %eax,%ecx
  80050f:	c1 f9 1f             	sar    $0x1f,%ecx
  800512:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800515:	8b 45 14             	mov    0x14(%ebp),%eax
  800518:	8d 40 04             	lea    0x4(%eax),%eax
  80051b:	89 45 14             	mov    %eax,0x14(%ebp)
  80051e:	eb b0                	jmp    8004d0 <vprintfmt+0x27e>
	if (lflag >= 2)
  800520:	83 f9 01             	cmp    $0x1,%ecx
  800523:	7f 1e                	jg     800543 <vprintfmt+0x2f1>
	else if (lflag)
  800525:	85 c9                	test   %ecx,%ecx
  800527:	74 32                	je     80055b <vprintfmt+0x309>
		return va_arg(*ap, unsigned long);
  800529:	8b 45 14             	mov    0x14(%ebp),%eax
  80052c:	8b 10                	mov    (%eax),%edx
  80052e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800533:	8d 40 04             	lea    0x4(%eax),%eax
  800536:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800539:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  80053e:	e9 da 00 00 00       	jmp    80061d <vprintfmt+0x3cb>
		return va_arg(*ap, unsigned long long);
  800543:	8b 45 14             	mov    0x14(%ebp),%eax
  800546:	8b 10                	mov    (%eax),%edx
  800548:	8b 48 04             	mov    0x4(%eax),%ecx
  80054b:	8d 40 08             	lea    0x8(%eax),%eax
  80054e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800551:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  800556:	e9 c2 00 00 00       	jmp    80061d <vprintfmt+0x3cb>
		return va_arg(*ap, unsigned int);
  80055b:	8b 45 14             	mov    0x14(%ebp),%eax
  80055e:	8b 10                	mov    (%eax),%edx
  800560:	b9 00 00 00 00       	mov    $0x0,%ecx
  800565:	8d 40 04             	lea    0x4(%eax),%eax
  800568:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80056b:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  800570:	e9 a8 00 00 00       	jmp    80061d <vprintfmt+0x3cb>
	if (lflag >= 2)
  800575:	83 f9 01             	cmp    $0x1,%ecx
  800578:	7f 1b                	jg     800595 <vprintfmt+0x343>
	else if (lflag)
  80057a:	85 c9                	test   %ecx,%ecx
  80057c:	74 5c                	je     8005da <vprintfmt+0x388>
		return va_arg(*ap, long);
  80057e:	8b 45 14             	mov    0x14(%ebp),%eax
  800581:	8b 00                	mov    (%eax),%eax
  800583:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800586:	99                   	cltd   
  800587:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80058a:	8b 45 14             	mov    0x14(%ebp),%eax
  80058d:	8d 40 04             	lea    0x4(%eax),%eax
  800590:	89 45 14             	mov    %eax,0x14(%ebp)
  800593:	eb 17                	jmp    8005ac <vprintfmt+0x35a>
		return va_arg(*ap, long long);
  800595:	8b 45 14             	mov    0x14(%ebp),%eax
  800598:	8b 50 04             	mov    0x4(%eax),%edx
  80059b:	8b 00                	mov    (%eax),%eax
  80059d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005a0:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a6:	8d 40 08             	lea    0x8(%eax),%eax
  8005a9:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8005ac:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005af:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 8;
  8005b2:	b8 08 00 00 00       	mov    $0x8,%eax
			if ((long long) num < 0) {
  8005b7:	85 c9                	test   %ecx,%ecx
  8005b9:	79 62                	jns    80061d <vprintfmt+0x3cb>
				putch('-', putdat);
  8005bb:	83 ec 08             	sub    $0x8,%esp
  8005be:	53                   	push   %ebx
  8005bf:	6a 2d                	push   $0x2d
  8005c1:	ff d6                	call   *%esi
				num = -(long long) num;
  8005c3:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005c6:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005c9:	f7 da                	neg    %edx
  8005cb:	83 d1 00             	adc    $0x0,%ecx
  8005ce:	f7 d9                	neg    %ecx
  8005d0:	83 c4 10             	add    $0x10,%esp
			base = 8;
  8005d3:	b8 08 00 00 00       	mov    $0x8,%eax
  8005d8:	eb 43                	jmp    80061d <vprintfmt+0x3cb>
		return va_arg(*ap, int);
  8005da:	8b 45 14             	mov    0x14(%ebp),%eax
  8005dd:	8b 00                	mov    (%eax),%eax
  8005df:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005e2:	89 c1                	mov    %eax,%ecx
  8005e4:	c1 f9 1f             	sar    $0x1f,%ecx
  8005e7:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005ea:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ed:	8d 40 04             	lea    0x4(%eax),%eax
  8005f0:	89 45 14             	mov    %eax,0x14(%ebp)
  8005f3:	eb b7                	jmp    8005ac <vprintfmt+0x35a>
			putch('0', putdat);
  8005f5:	83 ec 08             	sub    $0x8,%esp
  8005f8:	53                   	push   %ebx
  8005f9:	6a 30                	push   $0x30
  8005fb:	ff d6                	call   *%esi
			putch('x', putdat);
  8005fd:	83 c4 08             	add    $0x8,%esp
  800600:	53                   	push   %ebx
  800601:	6a 78                	push   $0x78
  800603:	ff d6                	call   *%esi
			num = (unsigned long long)
  800605:	8b 45 14             	mov    0x14(%ebp),%eax
  800608:	8b 10                	mov    (%eax),%edx
  80060a:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  80060f:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800612:	8d 40 04             	lea    0x4(%eax),%eax
  800615:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800618:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  80061d:	83 ec 0c             	sub    $0xc,%esp
  800620:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  800624:	57                   	push   %edi
  800625:	ff 75 e0             	pushl  -0x20(%ebp)
  800628:	50                   	push   %eax
  800629:	51                   	push   %ecx
  80062a:	52                   	push   %edx
  80062b:	89 da                	mov    %ebx,%edx
  80062d:	89 f0                	mov    %esi,%eax
  80062f:	e8 33 fb ff ff       	call   800167 <printnum>
			break;
  800634:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  800637:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80063a:	83 c7 01             	add    $0x1,%edi
  80063d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800641:	83 f8 25             	cmp    $0x25,%eax
  800644:	0f 84 23 fc ff ff    	je     80026d <vprintfmt+0x1b>
			if (ch == '\0')
  80064a:	85 c0                	test   %eax,%eax
  80064c:	0f 84 8b 00 00 00    	je     8006dd <vprintfmt+0x48b>
			putch(ch, putdat);
  800652:	83 ec 08             	sub    $0x8,%esp
  800655:	53                   	push   %ebx
  800656:	50                   	push   %eax
  800657:	ff d6                	call   *%esi
  800659:	83 c4 10             	add    $0x10,%esp
  80065c:	eb dc                	jmp    80063a <vprintfmt+0x3e8>
	if (lflag >= 2)
  80065e:	83 f9 01             	cmp    $0x1,%ecx
  800661:	7f 1b                	jg     80067e <vprintfmt+0x42c>
	else if (lflag)
  800663:	85 c9                	test   %ecx,%ecx
  800665:	74 2c                	je     800693 <vprintfmt+0x441>
		return va_arg(*ap, unsigned long);
  800667:	8b 45 14             	mov    0x14(%ebp),%eax
  80066a:	8b 10                	mov    (%eax),%edx
  80066c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800671:	8d 40 04             	lea    0x4(%eax),%eax
  800674:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800677:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  80067c:	eb 9f                	jmp    80061d <vprintfmt+0x3cb>
		return va_arg(*ap, unsigned long long);
  80067e:	8b 45 14             	mov    0x14(%ebp),%eax
  800681:	8b 10                	mov    (%eax),%edx
  800683:	8b 48 04             	mov    0x4(%eax),%ecx
  800686:	8d 40 08             	lea    0x8(%eax),%eax
  800689:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80068c:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  800691:	eb 8a                	jmp    80061d <vprintfmt+0x3cb>
		return va_arg(*ap, unsigned int);
  800693:	8b 45 14             	mov    0x14(%ebp),%eax
  800696:	8b 10                	mov    (%eax),%edx
  800698:	b9 00 00 00 00       	mov    $0x0,%ecx
  80069d:	8d 40 04             	lea    0x4(%eax),%eax
  8006a0:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006a3:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  8006a8:	e9 70 ff ff ff       	jmp    80061d <vprintfmt+0x3cb>
			putch(ch, putdat);
  8006ad:	83 ec 08             	sub    $0x8,%esp
  8006b0:	53                   	push   %ebx
  8006b1:	6a 25                	push   $0x25
  8006b3:	ff d6                	call   *%esi
			break;
  8006b5:	83 c4 10             	add    $0x10,%esp
  8006b8:	e9 7a ff ff ff       	jmp    800637 <vprintfmt+0x3e5>
			putch('%', putdat);
  8006bd:	83 ec 08             	sub    $0x8,%esp
  8006c0:	53                   	push   %ebx
  8006c1:	6a 25                	push   $0x25
  8006c3:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006c5:	83 c4 10             	add    $0x10,%esp
  8006c8:	89 f8                	mov    %edi,%eax
  8006ca:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8006ce:	74 05                	je     8006d5 <vprintfmt+0x483>
  8006d0:	83 e8 01             	sub    $0x1,%eax
  8006d3:	eb f5                	jmp    8006ca <vprintfmt+0x478>
  8006d5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006d8:	e9 5a ff ff ff       	jmp    800637 <vprintfmt+0x3e5>
}
  8006dd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006e0:	5b                   	pop    %ebx
  8006e1:	5e                   	pop    %esi
  8006e2:	5f                   	pop    %edi
  8006e3:	5d                   	pop    %ebp
  8006e4:	c3                   	ret    

008006e5 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006e5:	f3 0f 1e fb          	endbr32 
  8006e9:	55                   	push   %ebp
  8006ea:	89 e5                	mov    %esp,%ebp
  8006ec:	83 ec 18             	sub    $0x18,%esp
  8006ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8006f2:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006f5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006f8:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006fc:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006ff:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800706:	85 c0                	test   %eax,%eax
  800708:	74 26                	je     800730 <vsnprintf+0x4b>
  80070a:	85 d2                	test   %edx,%edx
  80070c:	7e 22                	jle    800730 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80070e:	ff 75 14             	pushl  0x14(%ebp)
  800711:	ff 75 10             	pushl  0x10(%ebp)
  800714:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800717:	50                   	push   %eax
  800718:	68 10 02 80 00       	push   $0x800210
  80071d:	e8 30 fb ff ff       	call   800252 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800722:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800725:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800728:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80072b:	83 c4 10             	add    $0x10,%esp
}
  80072e:	c9                   	leave  
  80072f:	c3                   	ret    
		return -E_INVAL;
  800730:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800735:	eb f7                	jmp    80072e <vsnprintf+0x49>

00800737 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800737:	f3 0f 1e fb          	endbr32 
  80073b:	55                   	push   %ebp
  80073c:	89 e5                	mov    %esp,%ebp
  80073e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800741:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800744:	50                   	push   %eax
  800745:	ff 75 10             	pushl  0x10(%ebp)
  800748:	ff 75 0c             	pushl  0xc(%ebp)
  80074b:	ff 75 08             	pushl  0x8(%ebp)
  80074e:	e8 92 ff ff ff       	call   8006e5 <vsnprintf>
	va_end(ap);

	return rc;
}
  800753:	c9                   	leave  
  800754:	c3                   	ret    

00800755 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800755:	f3 0f 1e fb          	endbr32 
  800759:	55                   	push   %ebp
  80075a:	89 e5                	mov    %esp,%ebp
  80075c:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80075f:	b8 00 00 00 00       	mov    $0x0,%eax
  800764:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800768:	74 05                	je     80076f <strlen+0x1a>
		n++;
  80076a:	83 c0 01             	add    $0x1,%eax
  80076d:	eb f5                	jmp    800764 <strlen+0xf>
	return n;
}
  80076f:	5d                   	pop    %ebp
  800770:	c3                   	ret    

00800771 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800771:	f3 0f 1e fb          	endbr32 
  800775:	55                   	push   %ebp
  800776:	89 e5                	mov    %esp,%ebp
  800778:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80077b:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80077e:	b8 00 00 00 00       	mov    $0x0,%eax
  800783:	39 d0                	cmp    %edx,%eax
  800785:	74 0d                	je     800794 <strnlen+0x23>
  800787:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80078b:	74 05                	je     800792 <strnlen+0x21>
		n++;
  80078d:	83 c0 01             	add    $0x1,%eax
  800790:	eb f1                	jmp    800783 <strnlen+0x12>
  800792:	89 c2                	mov    %eax,%edx
	return n;
}
  800794:	89 d0                	mov    %edx,%eax
  800796:	5d                   	pop    %ebp
  800797:	c3                   	ret    

00800798 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800798:	f3 0f 1e fb          	endbr32 
  80079c:	55                   	push   %ebp
  80079d:	89 e5                	mov    %esp,%ebp
  80079f:	53                   	push   %ebx
  8007a0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007a3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007a6:	b8 00 00 00 00       	mov    $0x0,%eax
  8007ab:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8007af:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8007b2:	83 c0 01             	add    $0x1,%eax
  8007b5:	84 d2                	test   %dl,%dl
  8007b7:	75 f2                	jne    8007ab <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  8007b9:	89 c8                	mov    %ecx,%eax
  8007bb:	5b                   	pop    %ebx
  8007bc:	5d                   	pop    %ebp
  8007bd:	c3                   	ret    

008007be <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007be:	f3 0f 1e fb          	endbr32 
  8007c2:	55                   	push   %ebp
  8007c3:	89 e5                	mov    %esp,%ebp
  8007c5:	53                   	push   %ebx
  8007c6:	83 ec 10             	sub    $0x10,%esp
  8007c9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007cc:	53                   	push   %ebx
  8007cd:	e8 83 ff ff ff       	call   800755 <strlen>
  8007d2:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8007d5:	ff 75 0c             	pushl  0xc(%ebp)
  8007d8:	01 d8                	add    %ebx,%eax
  8007da:	50                   	push   %eax
  8007db:	e8 b8 ff ff ff       	call   800798 <strcpy>
	return dst;
}
  8007e0:	89 d8                	mov    %ebx,%eax
  8007e2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007e5:	c9                   	leave  
  8007e6:	c3                   	ret    

008007e7 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007e7:	f3 0f 1e fb          	endbr32 
  8007eb:	55                   	push   %ebp
  8007ec:	89 e5                	mov    %esp,%ebp
  8007ee:	56                   	push   %esi
  8007ef:	53                   	push   %ebx
  8007f0:	8b 75 08             	mov    0x8(%ebp),%esi
  8007f3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007f6:	89 f3                	mov    %esi,%ebx
  8007f8:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007fb:	89 f0                	mov    %esi,%eax
  8007fd:	39 d8                	cmp    %ebx,%eax
  8007ff:	74 11                	je     800812 <strncpy+0x2b>
		*dst++ = *src;
  800801:	83 c0 01             	add    $0x1,%eax
  800804:	0f b6 0a             	movzbl (%edx),%ecx
  800807:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80080a:	80 f9 01             	cmp    $0x1,%cl
  80080d:	83 da ff             	sbb    $0xffffffff,%edx
  800810:	eb eb                	jmp    8007fd <strncpy+0x16>
	}
	return ret;
}
  800812:	89 f0                	mov    %esi,%eax
  800814:	5b                   	pop    %ebx
  800815:	5e                   	pop    %esi
  800816:	5d                   	pop    %ebp
  800817:	c3                   	ret    

00800818 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800818:	f3 0f 1e fb          	endbr32 
  80081c:	55                   	push   %ebp
  80081d:	89 e5                	mov    %esp,%ebp
  80081f:	56                   	push   %esi
  800820:	53                   	push   %ebx
  800821:	8b 75 08             	mov    0x8(%ebp),%esi
  800824:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800827:	8b 55 10             	mov    0x10(%ebp),%edx
  80082a:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80082c:	85 d2                	test   %edx,%edx
  80082e:	74 21                	je     800851 <strlcpy+0x39>
  800830:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800834:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  800836:	39 c2                	cmp    %eax,%edx
  800838:	74 14                	je     80084e <strlcpy+0x36>
  80083a:	0f b6 19             	movzbl (%ecx),%ebx
  80083d:	84 db                	test   %bl,%bl
  80083f:	74 0b                	je     80084c <strlcpy+0x34>
			*dst++ = *src++;
  800841:	83 c1 01             	add    $0x1,%ecx
  800844:	83 c2 01             	add    $0x1,%edx
  800847:	88 5a ff             	mov    %bl,-0x1(%edx)
  80084a:	eb ea                	jmp    800836 <strlcpy+0x1e>
  80084c:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  80084e:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800851:	29 f0                	sub    %esi,%eax
}
  800853:	5b                   	pop    %ebx
  800854:	5e                   	pop    %esi
  800855:	5d                   	pop    %ebp
  800856:	c3                   	ret    

00800857 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800857:	f3 0f 1e fb          	endbr32 
  80085b:	55                   	push   %ebp
  80085c:	89 e5                	mov    %esp,%ebp
  80085e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800861:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800864:	0f b6 01             	movzbl (%ecx),%eax
  800867:	84 c0                	test   %al,%al
  800869:	74 0c                	je     800877 <strcmp+0x20>
  80086b:	3a 02                	cmp    (%edx),%al
  80086d:	75 08                	jne    800877 <strcmp+0x20>
		p++, q++;
  80086f:	83 c1 01             	add    $0x1,%ecx
  800872:	83 c2 01             	add    $0x1,%edx
  800875:	eb ed                	jmp    800864 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800877:	0f b6 c0             	movzbl %al,%eax
  80087a:	0f b6 12             	movzbl (%edx),%edx
  80087d:	29 d0                	sub    %edx,%eax
}
  80087f:	5d                   	pop    %ebp
  800880:	c3                   	ret    

00800881 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800881:	f3 0f 1e fb          	endbr32 
  800885:	55                   	push   %ebp
  800886:	89 e5                	mov    %esp,%ebp
  800888:	53                   	push   %ebx
  800889:	8b 45 08             	mov    0x8(%ebp),%eax
  80088c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80088f:	89 c3                	mov    %eax,%ebx
  800891:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800894:	eb 06                	jmp    80089c <strncmp+0x1b>
		n--, p++, q++;
  800896:	83 c0 01             	add    $0x1,%eax
  800899:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  80089c:	39 d8                	cmp    %ebx,%eax
  80089e:	74 16                	je     8008b6 <strncmp+0x35>
  8008a0:	0f b6 08             	movzbl (%eax),%ecx
  8008a3:	84 c9                	test   %cl,%cl
  8008a5:	74 04                	je     8008ab <strncmp+0x2a>
  8008a7:	3a 0a                	cmp    (%edx),%cl
  8008a9:	74 eb                	je     800896 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008ab:	0f b6 00             	movzbl (%eax),%eax
  8008ae:	0f b6 12             	movzbl (%edx),%edx
  8008b1:	29 d0                	sub    %edx,%eax
}
  8008b3:	5b                   	pop    %ebx
  8008b4:	5d                   	pop    %ebp
  8008b5:	c3                   	ret    
		return 0;
  8008b6:	b8 00 00 00 00       	mov    $0x0,%eax
  8008bb:	eb f6                	jmp    8008b3 <strncmp+0x32>

008008bd <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008bd:	f3 0f 1e fb          	endbr32 
  8008c1:	55                   	push   %ebp
  8008c2:	89 e5                	mov    %esp,%ebp
  8008c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c7:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008cb:	0f b6 10             	movzbl (%eax),%edx
  8008ce:	84 d2                	test   %dl,%dl
  8008d0:	74 09                	je     8008db <strchr+0x1e>
		if (*s == c)
  8008d2:	38 ca                	cmp    %cl,%dl
  8008d4:	74 0a                	je     8008e0 <strchr+0x23>
	for (; *s; s++)
  8008d6:	83 c0 01             	add    $0x1,%eax
  8008d9:	eb f0                	jmp    8008cb <strchr+0xe>
			return (char *) s;
	return 0;
  8008db:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008e0:	5d                   	pop    %ebp
  8008e1:	c3                   	ret    

008008e2 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008e2:	f3 0f 1e fb          	endbr32 
  8008e6:	55                   	push   %ebp
  8008e7:	89 e5                	mov    %esp,%ebp
  8008e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ec:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008f0:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008f3:	38 ca                	cmp    %cl,%dl
  8008f5:	74 09                	je     800900 <strfind+0x1e>
  8008f7:	84 d2                	test   %dl,%dl
  8008f9:	74 05                	je     800900 <strfind+0x1e>
	for (; *s; s++)
  8008fb:	83 c0 01             	add    $0x1,%eax
  8008fe:	eb f0                	jmp    8008f0 <strfind+0xe>
			break;
	return (char *) s;
}
  800900:	5d                   	pop    %ebp
  800901:	c3                   	ret    

00800902 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800902:	f3 0f 1e fb          	endbr32 
  800906:	55                   	push   %ebp
  800907:	89 e5                	mov    %esp,%ebp
  800909:	57                   	push   %edi
  80090a:	56                   	push   %esi
  80090b:	53                   	push   %ebx
  80090c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80090f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800912:	85 c9                	test   %ecx,%ecx
  800914:	74 31                	je     800947 <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800916:	89 f8                	mov    %edi,%eax
  800918:	09 c8                	or     %ecx,%eax
  80091a:	a8 03                	test   $0x3,%al
  80091c:	75 23                	jne    800941 <memset+0x3f>
		c &= 0xFF;
  80091e:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800922:	89 d3                	mov    %edx,%ebx
  800924:	c1 e3 08             	shl    $0x8,%ebx
  800927:	89 d0                	mov    %edx,%eax
  800929:	c1 e0 18             	shl    $0x18,%eax
  80092c:	89 d6                	mov    %edx,%esi
  80092e:	c1 e6 10             	shl    $0x10,%esi
  800931:	09 f0                	or     %esi,%eax
  800933:	09 c2                	or     %eax,%edx
  800935:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800937:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  80093a:	89 d0                	mov    %edx,%eax
  80093c:	fc                   	cld    
  80093d:	f3 ab                	rep stos %eax,%es:(%edi)
  80093f:	eb 06                	jmp    800947 <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800941:	8b 45 0c             	mov    0xc(%ebp),%eax
  800944:	fc                   	cld    
  800945:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800947:	89 f8                	mov    %edi,%eax
  800949:	5b                   	pop    %ebx
  80094a:	5e                   	pop    %esi
  80094b:	5f                   	pop    %edi
  80094c:	5d                   	pop    %ebp
  80094d:	c3                   	ret    

0080094e <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80094e:	f3 0f 1e fb          	endbr32 
  800952:	55                   	push   %ebp
  800953:	89 e5                	mov    %esp,%ebp
  800955:	57                   	push   %edi
  800956:	56                   	push   %esi
  800957:	8b 45 08             	mov    0x8(%ebp),%eax
  80095a:	8b 75 0c             	mov    0xc(%ebp),%esi
  80095d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800960:	39 c6                	cmp    %eax,%esi
  800962:	73 32                	jae    800996 <memmove+0x48>
  800964:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800967:	39 c2                	cmp    %eax,%edx
  800969:	76 2b                	jbe    800996 <memmove+0x48>
		s += n;
		d += n;
  80096b:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80096e:	89 fe                	mov    %edi,%esi
  800970:	09 ce                	or     %ecx,%esi
  800972:	09 d6                	or     %edx,%esi
  800974:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80097a:	75 0e                	jne    80098a <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80097c:	83 ef 04             	sub    $0x4,%edi
  80097f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800982:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800985:	fd                   	std    
  800986:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800988:	eb 09                	jmp    800993 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80098a:	83 ef 01             	sub    $0x1,%edi
  80098d:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800990:	fd                   	std    
  800991:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800993:	fc                   	cld    
  800994:	eb 1a                	jmp    8009b0 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800996:	89 c2                	mov    %eax,%edx
  800998:	09 ca                	or     %ecx,%edx
  80099a:	09 f2                	or     %esi,%edx
  80099c:	f6 c2 03             	test   $0x3,%dl
  80099f:	75 0a                	jne    8009ab <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009a1:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8009a4:	89 c7                	mov    %eax,%edi
  8009a6:	fc                   	cld    
  8009a7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009a9:	eb 05                	jmp    8009b0 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  8009ab:	89 c7                	mov    %eax,%edi
  8009ad:	fc                   	cld    
  8009ae:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009b0:	5e                   	pop    %esi
  8009b1:	5f                   	pop    %edi
  8009b2:	5d                   	pop    %ebp
  8009b3:	c3                   	ret    

008009b4 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009b4:	f3 0f 1e fb          	endbr32 
  8009b8:	55                   	push   %ebp
  8009b9:	89 e5                	mov    %esp,%ebp
  8009bb:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009be:	ff 75 10             	pushl  0x10(%ebp)
  8009c1:	ff 75 0c             	pushl  0xc(%ebp)
  8009c4:	ff 75 08             	pushl  0x8(%ebp)
  8009c7:	e8 82 ff ff ff       	call   80094e <memmove>
}
  8009cc:	c9                   	leave  
  8009cd:	c3                   	ret    

008009ce <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009ce:	f3 0f 1e fb          	endbr32 
  8009d2:	55                   	push   %ebp
  8009d3:	89 e5                	mov    %esp,%ebp
  8009d5:	56                   	push   %esi
  8009d6:	53                   	push   %ebx
  8009d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8009da:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009dd:	89 c6                	mov    %eax,%esi
  8009df:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009e2:	39 f0                	cmp    %esi,%eax
  8009e4:	74 1c                	je     800a02 <memcmp+0x34>
		if (*s1 != *s2)
  8009e6:	0f b6 08             	movzbl (%eax),%ecx
  8009e9:	0f b6 1a             	movzbl (%edx),%ebx
  8009ec:	38 d9                	cmp    %bl,%cl
  8009ee:	75 08                	jne    8009f8 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  8009f0:	83 c0 01             	add    $0x1,%eax
  8009f3:	83 c2 01             	add    $0x1,%edx
  8009f6:	eb ea                	jmp    8009e2 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  8009f8:	0f b6 c1             	movzbl %cl,%eax
  8009fb:	0f b6 db             	movzbl %bl,%ebx
  8009fe:	29 d8                	sub    %ebx,%eax
  800a00:	eb 05                	jmp    800a07 <memcmp+0x39>
	}

	return 0;
  800a02:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a07:	5b                   	pop    %ebx
  800a08:	5e                   	pop    %esi
  800a09:	5d                   	pop    %ebp
  800a0a:	c3                   	ret    

00800a0b <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a0b:	f3 0f 1e fb          	endbr32 
  800a0f:	55                   	push   %ebp
  800a10:	89 e5                	mov    %esp,%ebp
  800a12:	8b 45 08             	mov    0x8(%ebp),%eax
  800a15:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a18:	89 c2                	mov    %eax,%edx
  800a1a:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a1d:	39 d0                	cmp    %edx,%eax
  800a1f:	73 09                	jae    800a2a <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a21:	38 08                	cmp    %cl,(%eax)
  800a23:	74 05                	je     800a2a <memfind+0x1f>
	for (; s < ends; s++)
  800a25:	83 c0 01             	add    $0x1,%eax
  800a28:	eb f3                	jmp    800a1d <memfind+0x12>
			break;
	return (void *) s;
}
  800a2a:	5d                   	pop    %ebp
  800a2b:	c3                   	ret    

00800a2c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a2c:	f3 0f 1e fb          	endbr32 
  800a30:	55                   	push   %ebp
  800a31:	89 e5                	mov    %esp,%ebp
  800a33:	57                   	push   %edi
  800a34:	56                   	push   %esi
  800a35:	53                   	push   %ebx
  800a36:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a39:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a3c:	eb 03                	jmp    800a41 <strtol+0x15>
		s++;
  800a3e:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800a41:	0f b6 01             	movzbl (%ecx),%eax
  800a44:	3c 20                	cmp    $0x20,%al
  800a46:	74 f6                	je     800a3e <strtol+0x12>
  800a48:	3c 09                	cmp    $0x9,%al
  800a4a:	74 f2                	je     800a3e <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800a4c:	3c 2b                	cmp    $0x2b,%al
  800a4e:	74 2a                	je     800a7a <strtol+0x4e>
	int neg = 0;
  800a50:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800a55:	3c 2d                	cmp    $0x2d,%al
  800a57:	74 2b                	je     800a84 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a59:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a5f:	75 0f                	jne    800a70 <strtol+0x44>
  800a61:	80 39 30             	cmpb   $0x30,(%ecx)
  800a64:	74 28                	je     800a8e <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a66:	85 db                	test   %ebx,%ebx
  800a68:	b8 0a 00 00 00       	mov    $0xa,%eax
  800a6d:	0f 44 d8             	cmove  %eax,%ebx
  800a70:	b8 00 00 00 00       	mov    $0x0,%eax
  800a75:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a78:	eb 46                	jmp    800ac0 <strtol+0x94>
		s++;
  800a7a:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800a7d:	bf 00 00 00 00       	mov    $0x0,%edi
  800a82:	eb d5                	jmp    800a59 <strtol+0x2d>
		s++, neg = 1;
  800a84:	83 c1 01             	add    $0x1,%ecx
  800a87:	bf 01 00 00 00       	mov    $0x1,%edi
  800a8c:	eb cb                	jmp    800a59 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a8e:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a92:	74 0e                	je     800aa2 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800a94:	85 db                	test   %ebx,%ebx
  800a96:	75 d8                	jne    800a70 <strtol+0x44>
		s++, base = 8;
  800a98:	83 c1 01             	add    $0x1,%ecx
  800a9b:	bb 08 00 00 00       	mov    $0x8,%ebx
  800aa0:	eb ce                	jmp    800a70 <strtol+0x44>
		s += 2, base = 16;
  800aa2:	83 c1 02             	add    $0x2,%ecx
  800aa5:	bb 10 00 00 00       	mov    $0x10,%ebx
  800aaa:	eb c4                	jmp    800a70 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800aac:	0f be d2             	movsbl %dl,%edx
  800aaf:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800ab2:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ab5:	7d 3a                	jge    800af1 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800ab7:	83 c1 01             	add    $0x1,%ecx
  800aba:	0f af 45 10          	imul   0x10(%ebp),%eax
  800abe:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800ac0:	0f b6 11             	movzbl (%ecx),%edx
  800ac3:	8d 72 d0             	lea    -0x30(%edx),%esi
  800ac6:	89 f3                	mov    %esi,%ebx
  800ac8:	80 fb 09             	cmp    $0x9,%bl
  800acb:	76 df                	jbe    800aac <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800acd:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ad0:	89 f3                	mov    %esi,%ebx
  800ad2:	80 fb 19             	cmp    $0x19,%bl
  800ad5:	77 08                	ja     800adf <strtol+0xb3>
			dig = *s - 'a' + 10;
  800ad7:	0f be d2             	movsbl %dl,%edx
  800ada:	83 ea 57             	sub    $0x57,%edx
  800add:	eb d3                	jmp    800ab2 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800adf:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ae2:	89 f3                	mov    %esi,%ebx
  800ae4:	80 fb 19             	cmp    $0x19,%bl
  800ae7:	77 08                	ja     800af1 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800ae9:	0f be d2             	movsbl %dl,%edx
  800aec:	83 ea 37             	sub    $0x37,%edx
  800aef:	eb c1                	jmp    800ab2 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800af1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800af5:	74 05                	je     800afc <strtol+0xd0>
		*endptr = (char *) s;
  800af7:	8b 75 0c             	mov    0xc(%ebp),%esi
  800afa:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800afc:	89 c2                	mov    %eax,%edx
  800afe:	f7 da                	neg    %edx
  800b00:	85 ff                	test   %edi,%edi
  800b02:	0f 45 c2             	cmovne %edx,%eax
}
  800b05:	5b                   	pop    %ebx
  800b06:	5e                   	pop    %esi
  800b07:	5f                   	pop    %edi
  800b08:	5d                   	pop    %ebp
  800b09:	c3                   	ret    

00800b0a <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b0a:	f3 0f 1e fb          	endbr32 
  800b0e:	55                   	push   %ebp
  800b0f:	89 e5                	mov    %esp,%ebp
  800b11:	57                   	push   %edi
  800b12:	56                   	push   %esi
  800b13:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b14:	b8 00 00 00 00       	mov    $0x0,%eax
  800b19:	8b 55 08             	mov    0x8(%ebp),%edx
  800b1c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b1f:	89 c3                	mov    %eax,%ebx
  800b21:	89 c7                	mov    %eax,%edi
  800b23:	89 c6                	mov    %eax,%esi
  800b25:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b27:	5b                   	pop    %ebx
  800b28:	5e                   	pop    %esi
  800b29:	5f                   	pop    %edi
  800b2a:	5d                   	pop    %ebp
  800b2b:	c3                   	ret    

00800b2c <sys_cgetc>:

int
sys_cgetc(void)
{
  800b2c:	f3 0f 1e fb          	endbr32 
  800b30:	55                   	push   %ebp
  800b31:	89 e5                	mov    %esp,%ebp
  800b33:	57                   	push   %edi
  800b34:	56                   	push   %esi
  800b35:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b36:	ba 00 00 00 00       	mov    $0x0,%edx
  800b3b:	b8 01 00 00 00       	mov    $0x1,%eax
  800b40:	89 d1                	mov    %edx,%ecx
  800b42:	89 d3                	mov    %edx,%ebx
  800b44:	89 d7                	mov    %edx,%edi
  800b46:	89 d6                	mov    %edx,%esi
  800b48:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b4a:	5b                   	pop    %ebx
  800b4b:	5e                   	pop    %esi
  800b4c:	5f                   	pop    %edi
  800b4d:	5d                   	pop    %ebp
  800b4e:	c3                   	ret    

00800b4f <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b4f:	f3 0f 1e fb          	endbr32 
  800b53:	55                   	push   %ebp
  800b54:	89 e5                	mov    %esp,%ebp
  800b56:	57                   	push   %edi
  800b57:	56                   	push   %esi
  800b58:	53                   	push   %ebx
  800b59:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b5c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b61:	8b 55 08             	mov    0x8(%ebp),%edx
  800b64:	b8 03 00 00 00       	mov    $0x3,%eax
  800b69:	89 cb                	mov    %ecx,%ebx
  800b6b:	89 cf                	mov    %ecx,%edi
  800b6d:	89 ce                	mov    %ecx,%esi
  800b6f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b71:	85 c0                	test   %eax,%eax
  800b73:	7f 08                	jg     800b7d <sys_env_destroy+0x2e>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b75:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b78:	5b                   	pop    %ebx
  800b79:	5e                   	pop    %esi
  800b7a:	5f                   	pop    %edi
  800b7b:	5d                   	pop    %ebp
  800b7c:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b7d:	83 ec 0c             	sub    $0xc,%esp
  800b80:	50                   	push   %eax
  800b81:	6a 03                	push   $0x3
  800b83:	68 e4 12 80 00       	push   $0x8012e4
  800b88:	6a 23                	push   $0x23
  800b8a:	68 01 13 80 00       	push   $0x801301
  800b8f:	e8 11 02 00 00       	call   800da5 <_panic>

00800b94 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b94:	f3 0f 1e fb          	endbr32 
  800b98:	55                   	push   %ebp
  800b99:	89 e5                	mov    %esp,%ebp
  800b9b:	57                   	push   %edi
  800b9c:	56                   	push   %esi
  800b9d:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b9e:	ba 00 00 00 00       	mov    $0x0,%edx
  800ba3:	b8 02 00 00 00       	mov    $0x2,%eax
  800ba8:	89 d1                	mov    %edx,%ecx
  800baa:	89 d3                	mov    %edx,%ebx
  800bac:	89 d7                	mov    %edx,%edi
  800bae:	89 d6                	mov    %edx,%esi
  800bb0:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bb2:	5b                   	pop    %ebx
  800bb3:	5e                   	pop    %esi
  800bb4:	5f                   	pop    %edi
  800bb5:	5d                   	pop    %ebp
  800bb6:	c3                   	ret    

00800bb7 <sys_yield>:

void
sys_yield(void)
{
  800bb7:	f3 0f 1e fb          	endbr32 
  800bbb:	55                   	push   %ebp
  800bbc:	89 e5                	mov    %esp,%ebp
  800bbe:	57                   	push   %edi
  800bbf:	56                   	push   %esi
  800bc0:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bc1:	ba 00 00 00 00       	mov    $0x0,%edx
  800bc6:	b8 0a 00 00 00       	mov    $0xa,%eax
  800bcb:	89 d1                	mov    %edx,%ecx
  800bcd:	89 d3                	mov    %edx,%ebx
  800bcf:	89 d7                	mov    %edx,%edi
  800bd1:	89 d6                	mov    %edx,%esi
  800bd3:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bd5:	5b                   	pop    %ebx
  800bd6:	5e                   	pop    %esi
  800bd7:	5f                   	pop    %edi
  800bd8:	5d                   	pop    %ebp
  800bd9:	c3                   	ret    

00800bda <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bda:	f3 0f 1e fb          	endbr32 
  800bde:	55                   	push   %ebp
  800bdf:	89 e5                	mov    %esp,%ebp
  800be1:	57                   	push   %edi
  800be2:	56                   	push   %esi
  800be3:	53                   	push   %ebx
  800be4:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800be7:	be 00 00 00 00       	mov    $0x0,%esi
  800bec:	8b 55 08             	mov    0x8(%ebp),%edx
  800bef:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bf2:	b8 04 00 00 00       	mov    $0x4,%eax
  800bf7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bfa:	89 f7                	mov    %esi,%edi
  800bfc:	cd 30                	int    $0x30
	if(check && ret > 0)
  800bfe:	85 c0                	test   %eax,%eax
  800c00:	7f 08                	jg     800c0a <sys_page_alloc+0x30>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c02:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c05:	5b                   	pop    %ebx
  800c06:	5e                   	pop    %esi
  800c07:	5f                   	pop    %edi
  800c08:	5d                   	pop    %ebp
  800c09:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c0a:	83 ec 0c             	sub    $0xc,%esp
  800c0d:	50                   	push   %eax
  800c0e:	6a 04                	push   $0x4
  800c10:	68 e4 12 80 00       	push   $0x8012e4
  800c15:	6a 23                	push   $0x23
  800c17:	68 01 13 80 00       	push   $0x801301
  800c1c:	e8 84 01 00 00       	call   800da5 <_panic>

00800c21 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c21:	f3 0f 1e fb          	endbr32 
  800c25:	55                   	push   %ebp
  800c26:	89 e5                	mov    %esp,%ebp
  800c28:	57                   	push   %edi
  800c29:	56                   	push   %esi
  800c2a:	53                   	push   %ebx
  800c2b:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c2e:	8b 55 08             	mov    0x8(%ebp),%edx
  800c31:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c34:	b8 05 00 00 00       	mov    $0x5,%eax
  800c39:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c3c:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c3f:	8b 75 18             	mov    0x18(%ebp),%esi
  800c42:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c44:	85 c0                	test   %eax,%eax
  800c46:	7f 08                	jg     800c50 <sys_page_map+0x2f>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c48:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c4b:	5b                   	pop    %ebx
  800c4c:	5e                   	pop    %esi
  800c4d:	5f                   	pop    %edi
  800c4e:	5d                   	pop    %ebp
  800c4f:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c50:	83 ec 0c             	sub    $0xc,%esp
  800c53:	50                   	push   %eax
  800c54:	6a 05                	push   $0x5
  800c56:	68 e4 12 80 00       	push   $0x8012e4
  800c5b:	6a 23                	push   $0x23
  800c5d:	68 01 13 80 00       	push   $0x801301
  800c62:	e8 3e 01 00 00       	call   800da5 <_panic>

00800c67 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c67:	f3 0f 1e fb          	endbr32 
  800c6b:	55                   	push   %ebp
  800c6c:	89 e5                	mov    %esp,%ebp
  800c6e:	57                   	push   %edi
  800c6f:	56                   	push   %esi
  800c70:	53                   	push   %ebx
  800c71:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c74:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c79:	8b 55 08             	mov    0x8(%ebp),%edx
  800c7c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c7f:	b8 06 00 00 00       	mov    $0x6,%eax
  800c84:	89 df                	mov    %ebx,%edi
  800c86:	89 de                	mov    %ebx,%esi
  800c88:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c8a:	85 c0                	test   %eax,%eax
  800c8c:	7f 08                	jg     800c96 <sys_page_unmap+0x2f>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c8e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c91:	5b                   	pop    %ebx
  800c92:	5e                   	pop    %esi
  800c93:	5f                   	pop    %edi
  800c94:	5d                   	pop    %ebp
  800c95:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c96:	83 ec 0c             	sub    $0xc,%esp
  800c99:	50                   	push   %eax
  800c9a:	6a 06                	push   $0x6
  800c9c:	68 e4 12 80 00       	push   $0x8012e4
  800ca1:	6a 23                	push   $0x23
  800ca3:	68 01 13 80 00       	push   $0x801301
  800ca8:	e8 f8 00 00 00       	call   800da5 <_panic>

00800cad <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cad:	f3 0f 1e fb          	endbr32 
  800cb1:	55                   	push   %ebp
  800cb2:	89 e5                	mov    %esp,%ebp
  800cb4:	57                   	push   %edi
  800cb5:	56                   	push   %esi
  800cb6:	53                   	push   %ebx
  800cb7:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cba:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cbf:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc5:	b8 08 00 00 00       	mov    $0x8,%eax
  800cca:	89 df                	mov    %ebx,%edi
  800ccc:	89 de                	mov    %ebx,%esi
  800cce:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cd0:	85 c0                	test   %eax,%eax
  800cd2:	7f 08                	jg     800cdc <sys_env_set_status+0x2f>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cd4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cd7:	5b                   	pop    %ebx
  800cd8:	5e                   	pop    %esi
  800cd9:	5f                   	pop    %edi
  800cda:	5d                   	pop    %ebp
  800cdb:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cdc:	83 ec 0c             	sub    $0xc,%esp
  800cdf:	50                   	push   %eax
  800ce0:	6a 08                	push   $0x8
  800ce2:	68 e4 12 80 00       	push   $0x8012e4
  800ce7:	6a 23                	push   $0x23
  800ce9:	68 01 13 80 00       	push   $0x801301
  800cee:	e8 b2 00 00 00       	call   800da5 <_panic>

00800cf3 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cf3:	f3 0f 1e fb          	endbr32 
  800cf7:	55                   	push   %ebp
  800cf8:	89 e5                	mov    %esp,%ebp
  800cfa:	57                   	push   %edi
  800cfb:	56                   	push   %esi
  800cfc:	53                   	push   %ebx
  800cfd:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d00:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d05:	8b 55 08             	mov    0x8(%ebp),%edx
  800d08:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d0b:	b8 09 00 00 00       	mov    $0x9,%eax
  800d10:	89 df                	mov    %ebx,%edi
  800d12:	89 de                	mov    %ebx,%esi
  800d14:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d16:	85 c0                	test   %eax,%eax
  800d18:	7f 08                	jg     800d22 <sys_env_set_pgfault_upcall+0x2f>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d1a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d1d:	5b                   	pop    %ebx
  800d1e:	5e                   	pop    %esi
  800d1f:	5f                   	pop    %edi
  800d20:	5d                   	pop    %ebp
  800d21:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d22:	83 ec 0c             	sub    $0xc,%esp
  800d25:	50                   	push   %eax
  800d26:	6a 09                	push   $0x9
  800d28:	68 e4 12 80 00       	push   $0x8012e4
  800d2d:	6a 23                	push   $0x23
  800d2f:	68 01 13 80 00       	push   $0x801301
  800d34:	e8 6c 00 00 00       	call   800da5 <_panic>

00800d39 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d39:	f3 0f 1e fb          	endbr32 
  800d3d:	55                   	push   %ebp
  800d3e:	89 e5                	mov    %esp,%ebp
  800d40:	57                   	push   %edi
  800d41:	56                   	push   %esi
  800d42:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d43:	8b 55 08             	mov    0x8(%ebp),%edx
  800d46:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d49:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d4e:	be 00 00 00 00       	mov    $0x0,%esi
  800d53:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d56:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d59:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d5b:	5b                   	pop    %ebx
  800d5c:	5e                   	pop    %esi
  800d5d:	5f                   	pop    %edi
  800d5e:	5d                   	pop    %ebp
  800d5f:	c3                   	ret    

00800d60 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d60:	f3 0f 1e fb          	endbr32 
  800d64:	55                   	push   %ebp
  800d65:	89 e5                	mov    %esp,%ebp
  800d67:	57                   	push   %edi
  800d68:	56                   	push   %esi
  800d69:	53                   	push   %ebx
  800d6a:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d6d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d72:	8b 55 08             	mov    0x8(%ebp),%edx
  800d75:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d7a:	89 cb                	mov    %ecx,%ebx
  800d7c:	89 cf                	mov    %ecx,%edi
  800d7e:	89 ce                	mov    %ecx,%esi
  800d80:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d82:	85 c0                	test   %eax,%eax
  800d84:	7f 08                	jg     800d8e <sys_ipc_recv+0x2e>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d86:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d89:	5b                   	pop    %ebx
  800d8a:	5e                   	pop    %esi
  800d8b:	5f                   	pop    %edi
  800d8c:	5d                   	pop    %ebp
  800d8d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d8e:	83 ec 0c             	sub    $0xc,%esp
  800d91:	50                   	push   %eax
  800d92:	6a 0c                	push   $0xc
  800d94:	68 e4 12 80 00       	push   $0x8012e4
  800d99:	6a 23                	push   $0x23
  800d9b:	68 01 13 80 00       	push   $0x801301
  800da0:	e8 00 00 00 00       	call   800da5 <_panic>

00800da5 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800da5:	f3 0f 1e fb          	endbr32 
  800da9:	55                   	push   %ebp
  800daa:	89 e5                	mov    %esp,%ebp
  800dac:	56                   	push   %esi
  800dad:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800dae:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800db1:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800db7:	e8 d8 fd ff ff       	call   800b94 <sys_getenvid>
  800dbc:	83 ec 0c             	sub    $0xc,%esp
  800dbf:	ff 75 0c             	pushl  0xc(%ebp)
  800dc2:	ff 75 08             	pushl  0x8(%ebp)
  800dc5:	56                   	push   %esi
  800dc6:	50                   	push   %eax
  800dc7:	68 10 13 80 00       	push   $0x801310
  800dcc:	e8 7e f3 ff ff       	call   80014f <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800dd1:	83 c4 18             	add    $0x18,%esp
  800dd4:	53                   	push   %ebx
  800dd5:	ff 75 10             	pushl  0x10(%ebp)
  800dd8:	e8 1d f3 ff ff       	call   8000fa <vcprintf>
	cprintf("\n");
  800ddd:	c7 04 24 33 13 80 00 	movl   $0x801333,(%esp)
  800de4:	e8 66 f3 ff ff       	call   80014f <cprintf>
  800de9:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800dec:	cc                   	int3   
  800ded:	eb fd                	jmp    800dec <_panic+0x47>
  800def:	90                   	nop

00800df0 <__udivdi3>:
  800df0:	f3 0f 1e fb          	endbr32 
  800df4:	55                   	push   %ebp
  800df5:	57                   	push   %edi
  800df6:	56                   	push   %esi
  800df7:	53                   	push   %ebx
  800df8:	83 ec 1c             	sub    $0x1c,%esp
  800dfb:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800dff:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800e03:	8b 74 24 34          	mov    0x34(%esp),%esi
  800e07:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800e0b:	85 d2                	test   %edx,%edx
  800e0d:	75 19                	jne    800e28 <__udivdi3+0x38>
  800e0f:	39 f3                	cmp    %esi,%ebx
  800e11:	76 4d                	jbe    800e60 <__udivdi3+0x70>
  800e13:	31 ff                	xor    %edi,%edi
  800e15:	89 e8                	mov    %ebp,%eax
  800e17:	89 f2                	mov    %esi,%edx
  800e19:	f7 f3                	div    %ebx
  800e1b:	89 fa                	mov    %edi,%edx
  800e1d:	83 c4 1c             	add    $0x1c,%esp
  800e20:	5b                   	pop    %ebx
  800e21:	5e                   	pop    %esi
  800e22:	5f                   	pop    %edi
  800e23:	5d                   	pop    %ebp
  800e24:	c3                   	ret    
  800e25:	8d 76 00             	lea    0x0(%esi),%esi
  800e28:	39 f2                	cmp    %esi,%edx
  800e2a:	76 14                	jbe    800e40 <__udivdi3+0x50>
  800e2c:	31 ff                	xor    %edi,%edi
  800e2e:	31 c0                	xor    %eax,%eax
  800e30:	89 fa                	mov    %edi,%edx
  800e32:	83 c4 1c             	add    $0x1c,%esp
  800e35:	5b                   	pop    %ebx
  800e36:	5e                   	pop    %esi
  800e37:	5f                   	pop    %edi
  800e38:	5d                   	pop    %ebp
  800e39:	c3                   	ret    
  800e3a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800e40:	0f bd fa             	bsr    %edx,%edi
  800e43:	83 f7 1f             	xor    $0x1f,%edi
  800e46:	75 48                	jne    800e90 <__udivdi3+0xa0>
  800e48:	39 f2                	cmp    %esi,%edx
  800e4a:	72 06                	jb     800e52 <__udivdi3+0x62>
  800e4c:	31 c0                	xor    %eax,%eax
  800e4e:	39 eb                	cmp    %ebp,%ebx
  800e50:	77 de                	ja     800e30 <__udivdi3+0x40>
  800e52:	b8 01 00 00 00       	mov    $0x1,%eax
  800e57:	eb d7                	jmp    800e30 <__udivdi3+0x40>
  800e59:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e60:	89 d9                	mov    %ebx,%ecx
  800e62:	85 db                	test   %ebx,%ebx
  800e64:	75 0b                	jne    800e71 <__udivdi3+0x81>
  800e66:	b8 01 00 00 00       	mov    $0x1,%eax
  800e6b:	31 d2                	xor    %edx,%edx
  800e6d:	f7 f3                	div    %ebx
  800e6f:	89 c1                	mov    %eax,%ecx
  800e71:	31 d2                	xor    %edx,%edx
  800e73:	89 f0                	mov    %esi,%eax
  800e75:	f7 f1                	div    %ecx
  800e77:	89 c6                	mov    %eax,%esi
  800e79:	89 e8                	mov    %ebp,%eax
  800e7b:	89 f7                	mov    %esi,%edi
  800e7d:	f7 f1                	div    %ecx
  800e7f:	89 fa                	mov    %edi,%edx
  800e81:	83 c4 1c             	add    $0x1c,%esp
  800e84:	5b                   	pop    %ebx
  800e85:	5e                   	pop    %esi
  800e86:	5f                   	pop    %edi
  800e87:	5d                   	pop    %ebp
  800e88:	c3                   	ret    
  800e89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e90:	89 f9                	mov    %edi,%ecx
  800e92:	b8 20 00 00 00       	mov    $0x20,%eax
  800e97:	29 f8                	sub    %edi,%eax
  800e99:	d3 e2                	shl    %cl,%edx
  800e9b:	89 54 24 08          	mov    %edx,0x8(%esp)
  800e9f:	89 c1                	mov    %eax,%ecx
  800ea1:	89 da                	mov    %ebx,%edx
  800ea3:	d3 ea                	shr    %cl,%edx
  800ea5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800ea9:	09 d1                	or     %edx,%ecx
  800eab:	89 f2                	mov    %esi,%edx
  800ead:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800eb1:	89 f9                	mov    %edi,%ecx
  800eb3:	d3 e3                	shl    %cl,%ebx
  800eb5:	89 c1                	mov    %eax,%ecx
  800eb7:	d3 ea                	shr    %cl,%edx
  800eb9:	89 f9                	mov    %edi,%ecx
  800ebb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800ebf:	89 eb                	mov    %ebp,%ebx
  800ec1:	d3 e6                	shl    %cl,%esi
  800ec3:	89 c1                	mov    %eax,%ecx
  800ec5:	d3 eb                	shr    %cl,%ebx
  800ec7:	09 de                	or     %ebx,%esi
  800ec9:	89 f0                	mov    %esi,%eax
  800ecb:	f7 74 24 08          	divl   0x8(%esp)
  800ecf:	89 d6                	mov    %edx,%esi
  800ed1:	89 c3                	mov    %eax,%ebx
  800ed3:	f7 64 24 0c          	mull   0xc(%esp)
  800ed7:	39 d6                	cmp    %edx,%esi
  800ed9:	72 15                	jb     800ef0 <__udivdi3+0x100>
  800edb:	89 f9                	mov    %edi,%ecx
  800edd:	d3 e5                	shl    %cl,%ebp
  800edf:	39 c5                	cmp    %eax,%ebp
  800ee1:	73 04                	jae    800ee7 <__udivdi3+0xf7>
  800ee3:	39 d6                	cmp    %edx,%esi
  800ee5:	74 09                	je     800ef0 <__udivdi3+0x100>
  800ee7:	89 d8                	mov    %ebx,%eax
  800ee9:	31 ff                	xor    %edi,%edi
  800eeb:	e9 40 ff ff ff       	jmp    800e30 <__udivdi3+0x40>
  800ef0:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800ef3:	31 ff                	xor    %edi,%edi
  800ef5:	e9 36 ff ff ff       	jmp    800e30 <__udivdi3+0x40>
  800efa:	66 90                	xchg   %ax,%ax
  800efc:	66 90                	xchg   %ax,%ax
  800efe:	66 90                	xchg   %ax,%ax

00800f00 <__umoddi3>:
  800f00:	f3 0f 1e fb          	endbr32 
  800f04:	55                   	push   %ebp
  800f05:	57                   	push   %edi
  800f06:	56                   	push   %esi
  800f07:	53                   	push   %ebx
  800f08:	83 ec 1c             	sub    $0x1c,%esp
  800f0b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  800f0f:	8b 74 24 30          	mov    0x30(%esp),%esi
  800f13:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800f17:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800f1b:	85 c0                	test   %eax,%eax
  800f1d:	75 19                	jne    800f38 <__umoddi3+0x38>
  800f1f:	39 df                	cmp    %ebx,%edi
  800f21:	76 5d                	jbe    800f80 <__umoddi3+0x80>
  800f23:	89 f0                	mov    %esi,%eax
  800f25:	89 da                	mov    %ebx,%edx
  800f27:	f7 f7                	div    %edi
  800f29:	89 d0                	mov    %edx,%eax
  800f2b:	31 d2                	xor    %edx,%edx
  800f2d:	83 c4 1c             	add    $0x1c,%esp
  800f30:	5b                   	pop    %ebx
  800f31:	5e                   	pop    %esi
  800f32:	5f                   	pop    %edi
  800f33:	5d                   	pop    %ebp
  800f34:	c3                   	ret    
  800f35:	8d 76 00             	lea    0x0(%esi),%esi
  800f38:	89 f2                	mov    %esi,%edx
  800f3a:	39 d8                	cmp    %ebx,%eax
  800f3c:	76 12                	jbe    800f50 <__umoddi3+0x50>
  800f3e:	89 f0                	mov    %esi,%eax
  800f40:	89 da                	mov    %ebx,%edx
  800f42:	83 c4 1c             	add    $0x1c,%esp
  800f45:	5b                   	pop    %ebx
  800f46:	5e                   	pop    %esi
  800f47:	5f                   	pop    %edi
  800f48:	5d                   	pop    %ebp
  800f49:	c3                   	ret    
  800f4a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800f50:	0f bd e8             	bsr    %eax,%ebp
  800f53:	83 f5 1f             	xor    $0x1f,%ebp
  800f56:	75 50                	jne    800fa8 <__umoddi3+0xa8>
  800f58:	39 d8                	cmp    %ebx,%eax
  800f5a:	0f 82 e0 00 00 00    	jb     801040 <__umoddi3+0x140>
  800f60:	89 d9                	mov    %ebx,%ecx
  800f62:	39 f7                	cmp    %esi,%edi
  800f64:	0f 86 d6 00 00 00    	jbe    801040 <__umoddi3+0x140>
  800f6a:	89 d0                	mov    %edx,%eax
  800f6c:	89 ca                	mov    %ecx,%edx
  800f6e:	83 c4 1c             	add    $0x1c,%esp
  800f71:	5b                   	pop    %ebx
  800f72:	5e                   	pop    %esi
  800f73:	5f                   	pop    %edi
  800f74:	5d                   	pop    %ebp
  800f75:	c3                   	ret    
  800f76:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f7d:	8d 76 00             	lea    0x0(%esi),%esi
  800f80:	89 fd                	mov    %edi,%ebp
  800f82:	85 ff                	test   %edi,%edi
  800f84:	75 0b                	jne    800f91 <__umoddi3+0x91>
  800f86:	b8 01 00 00 00       	mov    $0x1,%eax
  800f8b:	31 d2                	xor    %edx,%edx
  800f8d:	f7 f7                	div    %edi
  800f8f:	89 c5                	mov    %eax,%ebp
  800f91:	89 d8                	mov    %ebx,%eax
  800f93:	31 d2                	xor    %edx,%edx
  800f95:	f7 f5                	div    %ebp
  800f97:	89 f0                	mov    %esi,%eax
  800f99:	f7 f5                	div    %ebp
  800f9b:	89 d0                	mov    %edx,%eax
  800f9d:	31 d2                	xor    %edx,%edx
  800f9f:	eb 8c                	jmp    800f2d <__umoddi3+0x2d>
  800fa1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800fa8:	89 e9                	mov    %ebp,%ecx
  800faa:	ba 20 00 00 00       	mov    $0x20,%edx
  800faf:	29 ea                	sub    %ebp,%edx
  800fb1:	d3 e0                	shl    %cl,%eax
  800fb3:	89 44 24 08          	mov    %eax,0x8(%esp)
  800fb7:	89 d1                	mov    %edx,%ecx
  800fb9:	89 f8                	mov    %edi,%eax
  800fbb:	d3 e8                	shr    %cl,%eax
  800fbd:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800fc1:	89 54 24 04          	mov    %edx,0x4(%esp)
  800fc5:	8b 54 24 04          	mov    0x4(%esp),%edx
  800fc9:	09 c1                	or     %eax,%ecx
  800fcb:	89 d8                	mov    %ebx,%eax
  800fcd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800fd1:	89 e9                	mov    %ebp,%ecx
  800fd3:	d3 e7                	shl    %cl,%edi
  800fd5:	89 d1                	mov    %edx,%ecx
  800fd7:	d3 e8                	shr    %cl,%eax
  800fd9:	89 e9                	mov    %ebp,%ecx
  800fdb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800fdf:	d3 e3                	shl    %cl,%ebx
  800fe1:	89 c7                	mov    %eax,%edi
  800fe3:	89 d1                	mov    %edx,%ecx
  800fe5:	89 f0                	mov    %esi,%eax
  800fe7:	d3 e8                	shr    %cl,%eax
  800fe9:	89 e9                	mov    %ebp,%ecx
  800feb:	89 fa                	mov    %edi,%edx
  800fed:	d3 e6                	shl    %cl,%esi
  800fef:	09 d8                	or     %ebx,%eax
  800ff1:	f7 74 24 08          	divl   0x8(%esp)
  800ff5:	89 d1                	mov    %edx,%ecx
  800ff7:	89 f3                	mov    %esi,%ebx
  800ff9:	f7 64 24 0c          	mull   0xc(%esp)
  800ffd:	89 c6                	mov    %eax,%esi
  800fff:	89 d7                	mov    %edx,%edi
  801001:	39 d1                	cmp    %edx,%ecx
  801003:	72 06                	jb     80100b <__umoddi3+0x10b>
  801005:	75 10                	jne    801017 <__umoddi3+0x117>
  801007:	39 c3                	cmp    %eax,%ebx
  801009:	73 0c                	jae    801017 <__umoddi3+0x117>
  80100b:	2b 44 24 0c          	sub    0xc(%esp),%eax
  80100f:	1b 54 24 08          	sbb    0x8(%esp),%edx
  801013:	89 d7                	mov    %edx,%edi
  801015:	89 c6                	mov    %eax,%esi
  801017:	89 ca                	mov    %ecx,%edx
  801019:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80101e:	29 f3                	sub    %esi,%ebx
  801020:	19 fa                	sbb    %edi,%edx
  801022:	89 d0                	mov    %edx,%eax
  801024:	d3 e0                	shl    %cl,%eax
  801026:	89 e9                	mov    %ebp,%ecx
  801028:	d3 eb                	shr    %cl,%ebx
  80102a:	d3 ea                	shr    %cl,%edx
  80102c:	09 d8                	or     %ebx,%eax
  80102e:	83 c4 1c             	add    $0x1c,%esp
  801031:	5b                   	pop    %ebx
  801032:	5e                   	pop    %esi
  801033:	5f                   	pop    %edi
  801034:	5d                   	pop    %ebp
  801035:	c3                   	ret    
  801036:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80103d:	8d 76 00             	lea    0x0(%esi),%esi
  801040:	29 fe                	sub    %edi,%esi
  801042:	19 c3                	sbb    %eax,%ebx
  801044:	89 f2                	mov    %esi,%edx
  801046:	89 d9                	mov    %ebx,%ecx
  801048:	e9 1d ff ff ff       	jmp    800f6a <__umoddi3+0x6a>
