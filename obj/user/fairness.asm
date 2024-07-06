
obj/user/fairness:     file format elf32-i386


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
  80002c:	e8 74 00 00 00       	call   8000a5 <libmain>
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
  80003a:	56                   	push   %esi
  80003b:	53                   	push   %ebx
  80003c:	83 ec 10             	sub    $0x10,%esp
	envid_t who, id;

	id = sys_getenvid();
  80003f:	e8 a3 0b 00 00       	call   800be7 <sys_getenvid>
  800044:	89 c3                	mov    %eax,%ebx

	if (thisenv == &envs[1]) {
  800046:	81 3d 04 20 80 00 7c 	cmpl   $0xeec0007c,0x802004
  80004d:	00 c0 ee 
  800050:	74 2d                	je     80007f <umain+0x4c>
		while (1) {
			ipc_recv(&who, 0, 0);
			cprintf("%x recv from %x\n", id, who);
		}
	} else {
		cprintf("%x loop sending to %x\n", id, envs[1].env_id);
  800052:	a1 c4 00 c0 ee       	mov    0xeec000c4,%eax
  800057:	83 ec 04             	sub    $0x4,%esp
  80005a:	50                   	push   %eax
  80005b:	53                   	push   %ebx
  80005c:	68 d1 11 80 00       	push   $0x8011d1
  800061:	e8 3c 01 00 00       	call   8001a2 <cprintf>
  800066:	83 c4 10             	add    $0x10,%esp
		while (1)
			ipc_send(envs[1].env_id, 0, 0, 0);
  800069:	a1 c4 00 c0 ee       	mov    0xeec000c4,%eax
  80006e:	6a 00                	push   $0x0
  800070:	6a 00                	push   $0x0
  800072:	6a 00                	push   $0x0
  800074:	50                   	push   %eax
  800075:	e8 eb 0d 00 00       	call   800e65 <ipc_send>
  80007a:	83 c4 10             	add    $0x10,%esp
  80007d:	eb ea                	jmp    800069 <umain+0x36>
			ipc_recv(&who, 0, 0);
  80007f:	8d 75 f4             	lea    -0xc(%ebp),%esi
  800082:	83 ec 04             	sub    $0x4,%esp
  800085:	6a 00                	push   $0x0
  800087:	6a 00                	push   $0x0
  800089:	56                   	push   %esi
  80008a:	e8 69 0d 00 00       	call   800df8 <ipc_recv>
			cprintf("%x recv from %x\n", id, who);
  80008f:	83 c4 0c             	add    $0xc,%esp
  800092:	ff 75 f4             	pushl  -0xc(%ebp)
  800095:	53                   	push   %ebx
  800096:	68 c0 11 80 00       	push   $0x8011c0
  80009b:	e8 02 01 00 00       	call   8001a2 <cprintf>
  8000a0:	83 c4 10             	add    $0x10,%esp
  8000a3:	eb dd                	jmp    800082 <umain+0x4f>

008000a5 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000a5:	f3 0f 1e fb          	endbr32 
  8000a9:	55                   	push   %ebp
  8000aa:	89 e5                	mov    %esp,%ebp
  8000ac:	56                   	push   %esi
  8000ad:	53                   	push   %ebx
  8000ae:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000b1:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv=&envs[ENVX(sys_getenvid())];
  8000b4:	e8 2e 0b 00 00       	call   800be7 <sys_getenvid>
  8000b9:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000be:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000c1:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000c6:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000cb:	85 db                	test   %ebx,%ebx
  8000cd:	7e 07                	jle    8000d6 <libmain+0x31>
		binaryname = argv[0];
  8000cf:	8b 06                	mov    (%esi),%eax
  8000d1:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000d6:	83 ec 08             	sub    $0x8,%esp
  8000d9:	56                   	push   %esi
  8000da:	53                   	push   %ebx
  8000db:	e8 53 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000e0:	e8 0a 00 00 00       	call   8000ef <exit>
}
  8000e5:	83 c4 10             	add    $0x10,%esp
  8000e8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000eb:	5b                   	pop    %ebx
  8000ec:	5e                   	pop    %esi
  8000ed:	5d                   	pop    %ebp
  8000ee:	c3                   	ret    

008000ef <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000ef:	f3 0f 1e fb          	endbr32 
  8000f3:	55                   	push   %ebp
  8000f4:	89 e5                	mov    %esp,%ebp
  8000f6:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000f9:	6a 00                	push   $0x0
  8000fb:	e8 a2 0a 00 00       	call   800ba2 <sys_env_destroy>
}
  800100:	83 c4 10             	add    $0x10,%esp
  800103:	c9                   	leave  
  800104:	c3                   	ret    

00800105 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800105:	f3 0f 1e fb          	endbr32 
  800109:	55                   	push   %ebp
  80010a:	89 e5                	mov    %esp,%ebp
  80010c:	53                   	push   %ebx
  80010d:	83 ec 04             	sub    $0x4,%esp
  800110:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800113:	8b 13                	mov    (%ebx),%edx
  800115:	8d 42 01             	lea    0x1(%edx),%eax
  800118:	89 03                	mov    %eax,(%ebx)
  80011a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80011d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800121:	3d ff 00 00 00       	cmp    $0xff,%eax
  800126:	74 09                	je     800131 <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800128:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80012c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80012f:	c9                   	leave  
  800130:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800131:	83 ec 08             	sub    $0x8,%esp
  800134:	68 ff 00 00 00       	push   $0xff
  800139:	8d 43 08             	lea    0x8(%ebx),%eax
  80013c:	50                   	push   %eax
  80013d:	e8 1b 0a 00 00       	call   800b5d <sys_cputs>
		b->idx = 0;
  800142:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800148:	83 c4 10             	add    $0x10,%esp
  80014b:	eb db                	jmp    800128 <putch+0x23>

0080014d <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80014d:	f3 0f 1e fb          	endbr32 
  800151:	55                   	push   %ebp
  800152:	89 e5                	mov    %esp,%ebp
  800154:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80015a:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800161:	00 00 00 
	b.cnt = 0;
  800164:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80016b:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80016e:	ff 75 0c             	pushl  0xc(%ebp)
  800171:	ff 75 08             	pushl  0x8(%ebp)
  800174:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80017a:	50                   	push   %eax
  80017b:	68 05 01 80 00       	push   $0x800105
  800180:	e8 20 01 00 00       	call   8002a5 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800185:	83 c4 08             	add    $0x8,%esp
  800188:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80018e:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800194:	50                   	push   %eax
  800195:	e8 c3 09 00 00       	call   800b5d <sys_cputs>

	return b.cnt;
}
  80019a:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001a0:	c9                   	leave  
  8001a1:	c3                   	ret    

008001a2 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001a2:	f3 0f 1e fb          	endbr32 
  8001a6:	55                   	push   %ebp
  8001a7:	89 e5                	mov    %esp,%ebp
  8001a9:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001ac:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001af:	50                   	push   %eax
  8001b0:	ff 75 08             	pushl  0x8(%ebp)
  8001b3:	e8 95 ff ff ff       	call   80014d <vcprintf>
	va_end(ap);

	return cnt;
}
  8001b8:	c9                   	leave  
  8001b9:	c3                   	ret    

008001ba <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001ba:	55                   	push   %ebp
  8001bb:	89 e5                	mov    %esp,%ebp
  8001bd:	57                   	push   %edi
  8001be:	56                   	push   %esi
  8001bf:	53                   	push   %ebx
  8001c0:	83 ec 1c             	sub    $0x1c,%esp
  8001c3:	89 c7                	mov    %eax,%edi
  8001c5:	89 d6                	mov    %edx,%esi
  8001c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8001ca:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001cd:	89 d1                	mov    %edx,%ecx
  8001cf:	89 c2                	mov    %eax,%edx
  8001d1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001d4:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8001d7:	8b 45 10             	mov    0x10(%ebp),%eax
  8001da:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001dd:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001e0:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8001e7:	39 c2                	cmp    %eax,%edx
  8001e9:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8001ec:	72 3e                	jb     80022c <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001ee:	83 ec 0c             	sub    $0xc,%esp
  8001f1:	ff 75 18             	pushl  0x18(%ebp)
  8001f4:	83 eb 01             	sub    $0x1,%ebx
  8001f7:	53                   	push   %ebx
  8001f8:	50                   	push   %eax
  8001f9:	83 ec 08             	sub    $0x8,%esp
  8001fc:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001ff:	ff 75 e0             	pushl  -0x20(%ebp)
  800202:	ff 75 dc             	pushl  -0x24(%ebp)
  800205:	ff 75 d8             	pushl  -0x28(%ebp)
  800208:	e8 43 0d 00 00       	call   800f50 <__udivdi3>
  80020d:	83 c4 18             	add    $0x18,%esp
  800210:	52                   	push   %edx
  800211:	50                   	push   %eax
  800212:	89 f2                	mov    %esi,%edx
  800214:	89 f8                	mov    %edi,%eax
  800216:	e8 9f ff ff ff       	call   8001ba <printnum>
  80021b:	83 c4 20             	add    $0x20,%esp
  80021e:	eb 13                	jmp    800233 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800220:	83 ec 08             	sub    $0x8,%esp
  800223:	56                   	push   %esi
  800224:	ff 75 18             	pushl  0x18(%ebp)
  800227:	ff d7                	call   *%edi
  800229:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80022c:	83 eb 01             	sub    $0x1,%ebx
  80022f:	85 db                	test   %ebx,%ebx
  800231:	7f ed                	jg     800220 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800233:	83 ec 08             	sub    $0x8,%esp
  800236:	56                   	push   %esi
  800237:	83 ec 04             	sub    $0x4,%esp
  80023a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80023d:	ff 75 e0             	pushl  -0x20(%ebp)
  800240:	ff 75 dc             	pushl  -0x24(%ebp)
  800243:	ff 75 d8             	pushl  -0x28(%ebp)
  800246:	e8 15 0e 00 00       	call   801060 <__umoddi3>
  80024b:	83 c4 14             	add    $0x14,%esp
  80024e:	0f be 80 f2 11 80 00 	movsbl 0x8011f2(%eax),%eax
  800255:	50                   	push   %eax
  800256:	ff d7                	call   *%edi
}
  800258:	83 c4 10             	add    $0x10,%esp
  80025b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80025e:	5b                   	pop    %ebx
  80025f:	5e                   	pop    %esi
  800260:	5f                   	pop    %edi
  800261:	5d                   	pop    %ebp
  800262:	c3                   	ret    

00800263 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800263:	f3 0f 1e fb          	endbr32 
  800267:	55                   	push   %ebp
  800268:	89 e5                	mov    %esp,%ebp
  80026a:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80026d:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800271:	8b 10                	mov    (%eax),%edx
  800273:	3b 50 04             	cmp    0x4(%eax),%edx
  800276:	73 0a                	jae    800282 <sprintputch+0x1f>
		*b->buf++ = ch;
  800278:	8d 4a 01             	lea    0x1(%edx),%ecx
  80027b:	89 08                	mov    %ecx,(%eax)
  80027d:	8b 45 08             	mov    0x8(%ebp),%eax
  800280:	88 02                	mov    %al,(%edx)
}
  800282:	5d                   	pop    %ebp
  800283:	c3                   	ret    

00800284 <printfmt>:
{
  800284:	f3 0f 1e fb          	endbr32 
  800288:	55                   	push   %ebp
  800289:	89 e5                	mov    %esp,%ebp
  80028b:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80028e:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800291:	50                   	push   %eax
  800292:	ff 75 10             	pushl  0x10(%ebp)
  800295:	ff 75 0c             	pushl  0xc(%ebp)
  800298:	ff 75 08             	pushl  0x8(%ebp)
  80029b:	e8 05 00 00 00       	call   8002a5 <vprintfmt>
}
  8002a0:	83 c4 10             	add    $0x10,%esp
  8002a3:	c9                   	leave  
  8002a4:	c3                   	ret    

008002a5 <vprintfmt>:
{
  8002a5:	f3 0f 1e fb          	endbr32 
  8002a9:	55                   	push   %ebp
  8002aa:	89 e5                	mov    %esp,%ebp
  8002ac:	57                   	push   %edi
  8002ad:	56                   	push   %esi
  8002ae:	53                   	push   %ebx
  8002af:	83 ec 3c             	sub    $0x3c,%esp
  8002b2:	8b 75 08             	mov    0x8(%ebp),%esi
  8002b5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002b8:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002bb:	e9 cd 03 00 00       	jmp    80068d <vprintfmt+0x3e8>
		padc = ' ';
  8002c0:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  8002c4:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8002cb:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8002d2:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8002d9:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8002de:	8d 47 01             	lea    0x1(%edi),%eax
  8002e1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002e4:	0f b6 17             	movzbl (%edi),%edx
  8002e7:	8d 42 dd             	lea    -0x23(%edx),%eax
  8002ea:	3c 55                	cmp    $0x55,%al
  8002ec:	0f 87 1e 04 00 00    	ja     800710 <vprintfmt+0x46b>
  8002f2:	0f b6 c0             	movzbl %al,%eax
  8002f5:	3e ff 24 85 c0 12 80 	notrack jmp *0x8012c0(,%eax,4)
  8002fc:	00 
  8002fd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800300:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800304:	eb d8                	jmp    8002de <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800306:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800309:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  80030d:	eb cf                	jmp    8002de <vprintfmt+0x39>
  80030f:	0f b6 d2             	movzbl %dl,%edx
  800312:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800315:	b8 00 00 00 00       	mov    $0x0,%eax
  80031a:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  80031d:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800320:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800324:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800327:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80032a:	83 f9 09             	cmp    $0x9,%ecx
  80032d:	77 55                	ja     800384 <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  80032f:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800332:	eb e9                	jmp    80031d <vprintfmt+0x78>
			precision = va_arg(ap, int);
  800334:	8b 45 14             	mov    0x14(%ebp),%eax
  800337:	8b 00                	mov    (%eax),%eax
  800339:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80033c:	8b 45 14             	mov    0x14(%ebp),%eax
  80033f:	8d 40 04             	lea    0x4(%eax),%eax
  800342:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800345:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800348:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80034c:	79 90                	jns    8002de <vprintfmt+0x39>
				width = precision, precision = -1;
  80034e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800351:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800354:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80035b:	eb 81                	jmp    8002de <vprintfmt+0x39>
  80035d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800360:	85 c0                	test   %eax,%eax
  800362:	ba 00 00 00 00       	mov    $0x0,%edx
  800367:	0f 49 d0             	cmovns %eax,%edx
  80036a:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80036d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800370:	e9 69 ff ff ff       	jmp    8002de <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800375:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800378:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  80037f:	e9 5a ff ff ff       	jmp    8002de <vprintfmt+0x39>
  800384:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800387:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80038a:	eb bc                	jmp    800348 <vprintfmt+0xa3>
			lflag++;
  80038c:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80038f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800392:	e9 47 ff ff ff       	jmp    8002de <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  800397:	8b 45 14             	mov    0x14(%ebp),%eax
  80039a:	8d 78 04             	lea    0x4(%eax),%edi
  80039d:	83 ec 08             	sub    $0x8,%esp
  8003a0:	53                   	push   %ebx
  8003a1:	ff 30                	pushl  (%eax)
  8003a3:	ff d6                	call   *%esi
			break;
  8003a5:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8003a8:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8003ab:	e9 da 02 00 00       	jmp    80068a <vprintfmt+0x3e5>
			err = va_arg(ap, int);
  8003b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b3:	8d 78 04             	lea    0x4(%eax),%edi
  8003b6:	8b 00                	mov    (%eax),%eax
  8003b8:	99                   	cltd   
  8003b9:	31 d0                	xor    %edx,%eax
  8003bb:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003bd:	83 f8 08             	cmp    $0x8,%eax
  8003c0:	7f 23                	jg     8003e5 <vprintfmt+0x140>
  8003c2:	8b 14 85 20 14 80 00 	mov    0x801420(,%eax,4),%edx
  8003c9:	85 d2                	test   %edx,%edx
  8003cb:	74 18                	je     8003e5 <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  8003cd:	52                   	push   %edx
  8003ce:	68 13 12 80 00       	push   $0x801213
  8003d3:	53                   	push   %ebx
  8003d4:	56                   	push   %esi
  8003d5:	e8 aa fe ff ff       	call   800284 <printfmt>
  8003da:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003dd:	89 7d 14             	mov    %edi,0x14(%ebp)
  8003e0:	e9 a5 02 00 00       	jmp    80068a <vprintfmt+0x3e5>
				printfmt(putch, putdat, "error %d", err);
  8003e5:	50                   	push   %eax
  8003e6:	68 0a 12 80 00       	push   $0x80120a
  8003eb:	53                   	push   %ebx
  8003ec:	56                   	push   %esi
  8003ed:	e8 92 fe ff ff       	call   800284 <printfmt>
  8003f2:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003f5:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8003f8:	e9 8d 02 00 00       	jmp    80068a <vprintfmt+0x3e5>
			if ((p = va_arg(ap, char *)) == NULL)
  8003fd:	8b 45 14             	mov    0x14(%ebp),%eax
  800400:	83 c0 04             	add    $0x4,%eax
  800403:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800406:	8b 45 14             	mov    0x14(%ebp),%eax
  800409:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  80040b:	85 d2                	test   %edx,%edx
  80040d:	b8 03 12 80 00       	mov    $0x801203,%eax
  800412:	0f 45 c2             	cmovne %edx,%eax
  800415:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  800418:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80041c:	7e 06                	jle    800424 <vprintfmt+0x17f>
  80041e:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  800422:	75 0d                	jne    800431 <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  800424:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800427:	89 c7                	mov    %eax,%edi
  800429:	03 45 e0             	add    -0x20(%ebp),%eax
  80042c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80042f:	eb 55                	jmp    800486 <vprintfmt+0x1e1>
  800431:	83 ec 08             	sub    $0x8,%esp
  800434:	ff 75 d8             	pushl  -0x28(%ebp)
  800437:	ff 75 cc             	pushl  -0x34(%ebp)
  80043a:	e8 85 03 00 00       	call   8007c4 <strnlen>
  80043f:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800442:	29 c2                	sub    %eax,%edx
  800444:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  800447:	83 c4 10             	add    $0x10,%esp
  80044a:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  80044c:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  800450:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800453:	85 ff                	test   %edi,%edi
  800455:	7e 11                	jle    800468 <vprintfmt+0x1c3>
					putch(padc, putdat);
  800457:	83 ec 08             	sub    $0x8,%esp
  80045a:	53                   	push   %ebx
  80045b:	ff 75 e0             	pushl  -0x20(%ebp)
  80045e:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800460:	83 ef 01             	sub    $0x1,%edi
  800463:	83 c4 10             	add    $0x10,%esp
  800466:	eb eb                	jmp    800453 <vprintfmt+0x1ae>
  800468:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  80046b:	85 d2                	test   %edx,%edx
  80046d:	b8 00 00 00 00       	mov    $0x0,%eax
  800472:	0f 49 c2             	cmovns %edx,%eax
  800475:	29 c2                	sub    %eax,%edx
  800477:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80047a:	eb a8                	jmp    800424 <vprintfmt+0x17f>
					putch(ch, putdat);
  80047c:	83 ec 08             	sub    $0x8,%esp
  80047f:	53                   	push   %ebx
  800480:	52                   	push   %edx
  800481:	ff d6                	call   *%esi
  800483:	83 c4 10             	add    $0x10,%esp
  800486:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800489:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80048b:	83 c7 01             	add    $0x1,%edi
  80048e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800492:	0f be d0             	movsbl %al,%edx
  800495:	85 d2                	test   %edx,%edx
  800497:	74 4b                	je     8004e4 <vprintfmt+0x23f>
  800499:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80049d:	78 06                	js     8004a5 <vprintfmt+0x200>
  80049f:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8004a3:	78 1e                	js     8004c3 <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
  8004a5:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8004a9:	74 d1                	je     80047c <vprintfmt+0x1d7>
  8004ab:	0f be c0             	movsbl %al,%eax
  8004ae:	83 e8 20             	sub    $0x20,%eax
  8004b1:	83 f8 5e             	cmp    $0x5e,%eax
  8004b4:	76 c6                	jbe    80047c <vprintfmt+0x1d7>
					putch('?', putdat);
  8004b6:	83 ec 08             	sub    $0x8,%esp
  8004b9:	53                   	push   %ebx
  8004ba:	6a 3f                	push   $0x3f
  8004bc:	ff d6                	call   *%esi
  8004be:	83 c4 10             	add    $0x10,%esp
  8004c1:	eb c3                	jmp    800486 <vprintfmt+0x1e1>
  8004c3:	89 cf                	mov    %ecx,%edi
  8004c5:	eb 0e                	jmp    8004d5 <vprintfmt+0x230>
				putch(' ', putdat);
  8004c7:	83 ec 08             	sub    $0x8,%esp
  8004ca:	53                   	push   %ebx
  8004cb:	6a 20                	push   $0x20
  8004cd:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8004cf:	83 ef 01             	sub    $0x1,%edi
  8004d2:	83 c4 10             	add    $0x10,%esp
  8004d5:	85 ff                	test   %edi,%edi
  8004d7:	7f ee                	jg     8004c7 <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  8004d9:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8004dc:	89 45 14             	mov    %eax,0x14(%ebp)
  8004df:	e9 a6 01 00 00       	jmp    80068a <vprintfmt+0x3e5>
  8004e4:	89 cf                	mov    %ecx,%edi
  8004e6:	eb ed                	jmp    8004d5 <vprintfmt+0x230>
	if (lflag >= 2)
  8004e8:	83 f9 01             	cmp    $0x1,%ecx
  8004eb:	7f 1f                	jg     80050c <vprintfmt+0x267>
	else if (lflag)
  8004ed:	85 c9                	test   %ecx,%ecx
  8004ef:	74 67                	je     800558 <vprintfmt+0x2b3>
		return va_arg(*ap, long);
  8004f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8004f4:	8b 00                	mov    (%eax),%eax
  8004f6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004f9:	89 c1                	mov    %eax,%ecx
  8004fb:	c1 f9 1f             	sar    $0x1f,%ecx
  8004fe:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800501:	8b 45 14             	mov    0x14(%ebp),%eax
  800504:	8d 40 04             	lea    0x4(%eax),%eax
  800507:	89 45 14             	mov    %eax,0x14(%ebp)
  80050a:	eb 17                	jmp    800523 <vprintfmt+0x27e>
		return va_arg(*ap, long long);
  80050c:	8b 45 14             	mov    0x14(%ebp),%eax
  80050f:	8b 50 04             	mov    0x4(%eax),%edx
  800512:	8b 00                	mov    (%eax),%eax
  800514:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800517:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80051a:	8b 45 14             	mov    0x14(%ebp),%eax
  80051d:	8d 40 08             	lea    0x8(%eax),%eax
  800520:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800523:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800526:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800529:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  80052e:	85 c9                	test   %ecx,%ecx
  800530:	0f 89 3a 01 00 00    	jns    800670 <vprintfmt+0x3cb>
				putch('-', putdat);
  800536:	83 ec 08             	sub    $0x8,%esp
  800539:	53                   	push   %ebx
  80053a:	6a 2d                	push   $0x2d
  80053c:	ff d6                	call   *%esi
				num = -(long long) num;
  80053e:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800541:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800544:	f7 da                	neg    %edx
  800546:	83 d1 00             	adc    $0x0,%ecx
  800549:	f7 d9                	neg    %ecx
  80054b:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80054e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800553:	e9 18 01 00 00       	jmp    800670 <vprintfmt+0x3cb>
		return va_arg(*ap, int);
  800558:	8b 45 14             	mov    0x14(%ebp),%eax
  80055b:	8b 00                	mov    (%eax),%eax
  80055d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800560:	89 c1                	mov    %eax,%ecx
  800562:	c1 f9 1f             	sar    $0x1f,%ecx
  800565:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800568:	8b 45 14             	mov    0x14(%ebp),%eax
  80056b:	8d 40 04             	lea    0x4(%eax),%eax
  80056e:	89 45 14             	mov    %eax,0x14(%ebp)
  800571:	eb b0                	jmp    800523 <vprintfmt+0x27e>
	if (lflag >= 2)
  800573:	83 f9 01             	cmp    $0x1,%ecx
  800576:	7f 1e                	jg     800596 <vprintfmt+0x2f1>
	else if (lflag)
  800578:	85 c9                	test   %ecx,%ecx
  80057a:	74 32                	je     8005ae <vprintfmt+0x309>
		return va_arg(*ap, unsigned long);
  80057c:	8b 45 14             	mov    0x14(%ebp),%eax
  80057f:	8b 10                	mov    (%eax),%edx
  800581:	b9 00 00 00 00       	mov    $0x0,%ecx
  800586:	8d 40 04             	lea    0x4(%eax),%eax
  800589:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80058c:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  800591:	e9 da 00 00 00       	jmp    800670 <vprintfmt+0x3cb>
		return va_arg(*ap, unsigned long long);
  800596:	8b 45 14             	mov    0x14(%ebp),%eax
  800599:	8b 10                	mov    (%eax),%edx
  80059b:	8b 48 04             	mov    0x4(%eax),%ecx
  80059e:	8d 40 08             	lea    0x8(%eax),%eax
  8005a1:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005a4:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  8005a9:	e9 c2 00 00 00       	jmp    800670 <vprintfmt+0x3cb>
		return va_arg(*ap, unsigned int);
  8005ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b1:	8b 10                	mov    (%eax),%edx
  8005b3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005b8:	8d 40 04             	lea    0x4(%eax),%eax
  8005bb:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005be:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  8005c3:	e9 a8 00 00 00       	jmp    800670 <vprintfmt+0x3cb>
	if (lflag >= 2)
  8005c8:	83 f9 01             	cmp    $0x1,%ecx
  8005cb:	7f 1b                	jg     8005e8 <vprintfmt+0x343>
	else if (lflag)
  8005cd:	85 c9                	test   %ecx,%ecx
  8005cf:	74 5c                	je     80062d <vprintfmt+0x388>
		return va_arg(*ap, long);
  8005d1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d4:	8b 00                	mov    (%eax),%eax
  8005d6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005d9:	99                   	cltd   
  8005da:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e0:	8d 40 04             	lea    0x4(%eax),%eax
  8005e3:	89 45 14             	mov    %eax,0x14(%ebp)
  8005e6:	eb 17                	jmp    8005ff <vprintfmt+0x35a>
		return va_arg(*ap, long long);
  8005e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005eb:	8b 50 04             	mov    0x4(%eax),%edx
  8005ee:	8b 00                	mov    (%eax),%eax
  8005f0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005f3:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005f6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f9:	8d 40 08             	lea    0x8(%eax),%eax
  8005fc:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8005ff:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800602:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 8;
  800605:	b8 08 00 00 00       	mov    $0x8,%eax
			if ((long long) num < 0) {
  80060a:	85 c9                	test   %ecx,%ecx
  80060c:	79 62                	jns    800670 <vprintfmt+0x3cb>
				putch('-', putdat);
  80060e:	83 ec 08             	sub    $0x8,%esp
  800611:	53                   	push   %ebx
  800612:	6a 2d                	push   $0x2d
  800614:	ff d6                	call   *%esi
				num = -(long long) num;
  800616:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800619:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80061c:	f7 da                	neg    %edx
  80061e:	83 d1 00             	adc    $0x0,%ecx
  800621:	f7 d9                	neg    %ecx
  800623:	83 c4 10             	add    $0x10,%esp
			base = 8;
  800626:	b8 08 00 00 00       	mov    $0x8,%eax
  80062b:	eb 43                	jmp    800670 <vprintfmt+0x3cb>
		return va_arg(*ap, int);
  80062d:	8b 45 14             	mov    0x14(%ebp),%eax
  800630:	8b 00                	mov    (%eax),%eax
  800632:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800635:	89 c1                	mov    %eax,%ecx
  800637:	c1 f9 1f             	sar    $0x1f,%ecx
  80063a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80063d:	8b 45 14             	mov    0x14(%ebp),%eax
  800640:	8d 40 04             	lea    0x4(%eax),%eax
  800643:	89 45 14             	mov    %eax,0x14(%ebp)
  800646:	eb b7                	jmp    8005ff <vprintfmt+0x35a>
			putch('0', putdat);
  800648:	83 ec 08             	sub    $0x8,%esp
  80064b:	53                   	push   %ebx
  80064c:	6a 30                	push   $0x30
  80064e:	ff d6                	call   *%esi
			putch('x', putdat);
  800650:	83 c4 08             	add    $0x8,%esp
  800653:	53                   	push   %ebx
  800654:	6a 78                	push   $0x78
  800656:	ff d6                	call   *%esi
			num = (unsigned long long)
  800658:	8b 45 14             	mov    0x14(%ebp),%eax
  80065b:	8b 10                	mov    (%eax),%edx
  80065d:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800662:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800665:	8d 40 04             	lea    0x4(%eax),%eax
  800668:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80066b:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  800670:	83 ec 0c             	sub    $0xc,%esp
  800673:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  800677:	57                   	push   %edi
  800678:	ff 75 e0             	pushl  -0x20(%ebp)
  80067b:	50                   	push   %eax
  80067c:	51                   	push   %ecx
  80067d:	52                   	push   %edx
  80067e:	89 da                	mov    %ebx,%edx
  800680:	89 f0                	mov    %esi,%eax
  800682:	e8 33 fb ff ff       	call   8001ba <printnum>
			break;
  800687:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  80068a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80068d:	83 c7 01             	add    $0x1,%edi
  800690:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800694:	83 f8 25             	cmp    $0x25,%eax
  800697:	0f 84 23 fc ff ff    	je     8002c0 <vprintfmt+0x1b>
			if (ch == '\0')
  80069d:	85 c0                	test   %eax,%eax
  80069f:	0f 84 8b 00 00 00    	je     800730 <vprintfmt+0x48b>
			putch(ch, putdat);
  8006a5:	83 ec 08             	sub    $0x8,%esp
  8006a8:	53                   	push   %ebx
  8006a9:	50                   	push   %eax
  8006aa:	ff d6                	call   *%esi
  8006ac:	83 c4 10             	add    $0x10,%esp
  8006af:	eb dc                	jmp    80068d <vprintfmt+0x3e8>
	if (lflag >= 2)
  8006b1:	83 f9 01             	cmp    $0x1,%ecx
  8006b4:	7f 1b                	jg     8006d1 <vprintfmt+0x42c>
	else if (lflag)
  8006b6:	85 c9                	test   %ecx,%ecx
  8006b8:	74 2c                	je     8006e6 <vprintfmt+0x441>
		return va_arg(*ap, unsigned long);
  8006ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8006bd:	8b 10                	mov    (%eax),%edx
  8006bf:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006c4:	8d 40 04             	lea    0x4(%eax),%eax
  8006c7:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006ca:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  8006cf:	eb 9f                	jmp    800670 <vprintfmt+0x3cb>
		return va_arg(*ap, unsigned long long);
  8006d1:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d4:	8b 10                	mov    (%eax),%edx
  8006d6:	8b 48 04             	mov    0x4(%eax),%ecx
  8006d9:	8d 40 08             	lea    0x8(%eax),%eax
  8006dc:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006df:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  8006e4:	eb 8a                	jmp    800670 <vprintfmt+0x3cb>
		return va_arg(*ap, unsigned int);
  8006e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e9:	8b 10                	mov    (%eax),%edx
  8006eb:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006f0:	8d 40 04             	lea    0x4(%eax),%eax
  8006f3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006f6:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  8006fb:	e9 70 ff ff ff       	jmp    800670 <vprintfmt+0x3cb>
			putch(ch, putdat);
  800700:	83 ec 08             	sub    $0x8,%esp
  800703:	53                   	push   %ebx
  800704:	6a 25                	push   $0x25
  800706:	ff d6                	call   *%esi
			break;
  800708:	83 c4 10             	add    $0x10,%esp
  80070b:	e9 7a ff ff ff       	jmp    80068a <vprintfmt+0x3e5>
			putch('%', putdat);
  800710:	83 ec 08             	sub    $0x8,%esp
  800713:	53                   	push   %ebx
  800714:	6a 25                	push   $0x25
  800716:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800718:	83 c4 10             	add    $0x10,%esp
  80071b:	89 f8                	mov    %edi,%eax
  80071d:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800721:	74 05                	je     800728 <vprintfmt+0x483>
  800723:	83 e8 01             	sub    $0x1,%eax
  800726:	eb f5                	jmp    80071d <vprintfmt+0x478>
  800728:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80072b:	e9 5a ff ff ff       	jmp    80068a <vprintfmt+0x3e5>
}
  800730:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800733:	5b                   	pop    %ebx
  800734:	5e                   	pop    %esi
  800735:	5f                   	pop    %edi
  800736:	5d                   	pop    %ebp
  800737:	c3                   	ret    

00800738 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800738:	f3 0f 1e fb          	endbr32 
  80073c:	55                   	push   %ebp
  80073d:	89 e5                	mov    %esp,%ebp
  80073f:	83 ec 18             	sub    $0x18,%esp
  800742:	8b 45 08             	mov    0x8(%ebp),%eax
  800745:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800748:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80074b:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80074f:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800752:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800759:	85 c0                	test   %eax,%eax
  80075b:	74 26                	je     800783 <vsnprintf+0x4b>
  80075d:	85 d2                	test   %edx,%edx
  80075f:	7e 22                	jle    800783 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800761:	ff 75 14             	pushl  0x14(%ebp)
  800764:	ff 75 10             	pushl  0x10(%ebp)
  800767:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80076a:	50                   	push   %eax
  80076b:	68 63 02 80 00       	push   $0x800263
  800770:	e8 30 fb ff ff       	call   8002a5 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800775:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800778:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80077b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80077e:	83 c4 10             	add    $0x10,%esp
}
  800781:	c9                   	leave  
  800782:	c3                   	ret    
		return -E_INVAL;
  800783:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800788:	eb f7                	jmp    800781 <vsnprintf+0x49>

0080078a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80078a:	f3 0f 1e fb          	endbr32 
  80078e:	55                   	push   %ebp
  80078f:	89 e5                	mov    %esp,%ebp
  800791:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800794:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800797:	50                   	push   %eax
  800798:	ff 75 10             	pushl  0x10(%ebp)
  80079b:	ff 75 0c             	pushl  0xc(%ebp)
  80079e:	ff 75 08             	pushl  0x8(%ebp)
  8007a1:	e8 92 ff ff ff       	call   800738 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007a6:	c9                   	leave  
  8007a7:	c3                   	ret    

008007a8 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007a8:	f3 0f 1e fb          	endbr32 
  8007ac:	55                   	push   %ebp
  8007ad:	89 e5                	mov    %esp,%ebp
  8007af:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007b2:	b8 00 00 00 00       	mov    $0x0,%eax
  8007b7:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007bb:	74 05                	je     8007c2 <strlen+0x1a>
		n++;
  8007bd:	83 c0 01             	add    $0x1,%eax
  8007c0:	eb f5                	jmp    8007b7 <strlen+0xf>
	return n;
}
  8007c2:	5d                   	pop    %ebp
  8007c3:	c3                   	ret    

008007c4 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007c4:	f3 0f 1e fb          	endbr32 
  8007c8:	55                   	push   %ebp
  8007c9:	89 e5                	mov    %esp,%ebp
  8007cb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007ce:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007d1:	b8 00 00 00 00       	mov    $0x0,%eax
  8007d6:	39 d0                	cmp    %edx,%eax
  8007d8:	74 0d                	je     8007e7 <strnlen+0x23>
  8007da:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007de:	74 05                	je     8007e5 <strnlen+0x21>
		n++;
  8007e0:	83 c0 01             	add    $0x1,%eax
  8007e3:	eb f1                	jmp    8007d6 <strnlen+0x12>
  8007e5:	89 c2                	mov    %eax,%edx
	return n;
}
  8007e7:	89 d0                	mov    %edx,%eax
  8007e9:	5d                   	pop    %ebp
  8007ea:	c3                   	ret    

008007eb <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007eb:	f3 0f 1e fb          	endbr32 
  8007ef:	55                   	push   %ebp
  8007f0:	89 e5                	mov    %esp,%ebp
  8007f2:	53                   	push   %ebx
  8007f3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007f6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007f9:	b8 00 00 00 00       	mov    $0x0,%eax
  8007fe:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800802:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800805:	83 c0 01             	add    $0x1,%eax
  800808:	84 d2                	test   %dl,%dl
  80080a:	75 f2                	jne    8007fe <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  80080c:	89 c8                	mov    %ecx,%eax
  80080e:	5b                   	pop    %ebx
  80080f:	5d                   	pop    %ebp
  800810:	c3                   	ret    

00800811 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800811:	f3 0f 1e fb          	endbr32 
  800815:	55                   	push   %ebp
  800816:	89 e5                	mov    %esp,%ebp
  800818:	53                   	push   %ebx
  800819:	83 ec 10             	sub    $0x10,%esp
  80081c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80081f:	53                   	push   %ebx
  800820:	e8 83 ff ff ff       	call   8007a8 <strlen>
  800825:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800828:	ff 75 0c             	pushl  0xc(%ebp)
  80082b:	01 d8                	add    %ebx,%eax
  80082d:	50                   	push   %eax
  80082e:	e8 b8 ff ff ff       	call   8007eb <strcpy>
	return dst;
}
  800833:	89 d8                	mov    %ebx,%eax
  800835:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800838:	c9                   	leave  
  800839:	c3                   	ret    

0080083a <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80083a:	f3 0f 1e fb          	endbr32 
  80083e:	55                   	push   %ebp
  80083f:	89 e5                	mov    %esp,%ebp
  800841:	56                   	push   %esi
  800842:	53                   	push   %ebx
  800843:	8b 75 08             	mov    0x8(%ebp),%esi
  800846:	8b 55 0c             	mov    0xc(%ebp),%edx
  800849:	89 f3                	mov    %esi,%ebx
  80084b:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80084e:	89 f0                	mov    %esi,%eax
  800850:	39 d8                	cmp    %ebx,%eax
  800852:	74 11                	je     800865 <strncpy+0x2b>
		*dst++ = *src;
  800854:	83 c0 01             	add    $0x1,%eax
  800857:	0f b6 0a             	movzbl (%edx),%ecx
  80085a:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80085d:	80 f9 01             	cmp    $0x1,%cl
  800860:	83 da ff             	sbb    $0xffffffff,%edx
  800863:	eb eb                	jmp    800850 <strncpy+0x16>
	}
	return ret;
}
  800865:	89 f0                	mov    %esi,%eax
  800867:	5b                   	pop    %ebx
  800868:	5e                   	pop    %esi
  800869:	5d                   	pop    %ebp
  80086a:	c3                   	ret    

0080086b <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80086b:	f3 0f 1e fb          	endbr32 
  80086f:	55                   	push   %ebp
  800870:	89 e5                	mov    %esp,%ebp
  800872:	56                   	push   %esi
  800873:	53                   	push   %ebx
  800874:	8b 75 08             	mov    0x8(%ebp),%esi
  800877:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80087a:	8b 55 10             	mov    0x10(%ebp),%edx
  80087d:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80087f:	85 d2                	test   %edx,%edx
  800881:	74 21                	je     8008a4 <strlcpy+0x39>
  800883:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800887:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  800889:	39 c2                	cmp    %eax,%edx
  80088b:	74 14                	je     8008a1 <strlcpy+0x36>
  80088d:	0f b6 19             	movzbl (%ecx),%ebx
  800890:	84 db                	test   %bl,%bl
  800892:	74 0b                	je     80089f <strlcpy+0x34>
			*dst++ = *src++;
  800894:	83 c1 01             	add    $0x1,%ecx
  800897:	83 c2 01             	add    $0x1,%edx
  80089a:	88 5a ff             	mov    %bl,-0x1(%edx)
  80089d:	eb ea                	jmp    800889 <strlcpy+0x1e>
  80089f:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  8008a1:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008a4:	29 f0                	sub    %esi,%eax
}
  8008a6:	5b                   	pop    %ebx
  8008a7:	5e                   	pop    %esi
  8008a8:	5d                   	pop    %ebp
  8008a9:	c3                   	ret    

008008aa <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008aa:	f3 0f 1e fb          	endbr32 
  8008ae:	55                   	push   %ebp
  8008af:	89 e5                	mov    %esp,%ebp
  8008b1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008b4:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008b7:	0f b6 01             	movzbl (%ecx),%eax
  8008ba:	84 c0                	test   %al,%al
  8008bc:	74 0c                	je     8008ca <strcmp+0x20>
  8008be:	3a 02                	cmp    (%edx),%al
  8008c0:	75 08                	jne    8008ca <strcmp+0x20>
		p++, q++;
  8008c2:	83 c1 01             	add    $0x1,%ecx
  8008c5:	83 c2 01             	add    $0x1,%edx
  8008c8:	eb ed                	jmp    8008b7 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008ca:	0f b6 c0             	movzbl %al,%eax
  8008cd:	0f b6 12             	movzbl (%edx),%edx
  8008d0:	29 d0                	sub    %edx,%eax
}
  8008d2:	5d                   	pop    %ebp
  8008d3:	c3                   	ret    

008008d4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008d4:	f3 0f 1e fb          	endbr32 
  8008d8:	55                   	push   %ebp
  8008d9:	89 e5                	mov    %esp,%ebp
  8008db:	53                   	push   %ebx
  8008dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8008df:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008e2:	89 c3                	mov    %eax,%ebx
  8008e4:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008e7:	eb 06                	jmp    8008ef <strncmp+0x1b>
		n--, p++, q++;
  8008e9:	83 c0 01             	add    $0x1,%eax
  8008ec:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8008ef:	39 d8                	cmp    %ebx,%eax
  8008f1:	74 16                	je     800909 <strncmp+0x35>
  8008f3:	0f b6 08             	movzbl (%eax),%ecx
  8008f6:	84 c9                	test   %cl,%cl
  8008f8:	74 04                	je     8008fe <strncmp+0x2a>
  8008fa:	3a 0a                	cmp    (%edx),%cl
  8008fc:	74 eb                	je     8008e9 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008fe:	0f b6 00             	movzbl (%eax),%eax
  800901:	0f b6 12             	movzbl (%edx),%edx
  800904:	29 d0                	sub    %edx,%eax
}
  800906:	5b                   	pop    %ebx
  800907:	5d                   	pop    %ebp
  800908:	c3                   	ret    
		return 0;
  800909:	b8 00 00 00 00       	mov    $0x0,%eax
  80090e:	eb f6                	jmp    800906 <strncmp+0x32>

00800910 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800910:	f3 0f 1e fb          	endbr32 
  800914:	55                   	push   %ebp
  800915:	89 e5                	mov    %esp,%ebp
  800917:	8b 45 08             	mov    0x8(%ebp),%eax
  80091a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80091e:	0f b6 10             	movzbl (%eax),%edx
  800921:	84 d2                	test   %dl,%dl
  800923:	74 09                	je     80092e <strchr+0x1e>
		if (*s == c)
  800925:	38 ca                	cmp    %cl,%dl
  800927:	74 0a                	je     800933 <strchr+0x23>
	for (; *s; s++)
  800929:	83 c0 01             	add    $0x1,%eax
  80092c:	eb f0                	jmp    80091e <strchr+0xe>
			return (char *) s;
	return 0;
  80092e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800933:	5d                   	pop    %ebp
  800934:	c3                   	ret    

00800935 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800935:	f3 0f 1e fb          	endbr32 
  800939:	55                   	push   %ebp
  80093a:	89 e5                	mov    %esp,%ebp
  80093c:	8b 45 08             	mov    0x8(%ebp),%eax
  80093f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800943:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800946:	38 ca                	cmp    %cl,%dl
  800948:	74 09                	je     800953 <strfind+0x1e>
  80094a:	84 d2                	test   %dl,%dl
  80094c:	74 05                	je     800953 <strfind+0x1e>
	for (; *s; s++)
  80094e:	83 c0 01             	add    $0x1,%eax
  800951:	eb f0                	jmp    800943 <strfind+0xe>
			break;
	return (char *) s;
}
  800953:	5d                   	pop    %ebp
  800954:	c3                   	ret    

00800955 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800955:	f3 0f 1e fb          	endbr32 
  800959:	55                   	push   %ebp
  80095a:	89 e5                	mov    %esp,%ebp
  80095c:	57                   	push   %edi
  80095d:	56                   	push   %esi
  80095e:	53                   	push   %ebx
  80095f:	8b 7d 08             	mov    0x8(%ebp),%edi
  800962:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800965:	85 c9                	test   %ecx,%ecx
  800967:	74 31                	je     80099a <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800969:	89 f8                	mov    %edi,%eax
  80096b:	09 c8                	or     %ecx,%eax
  80096d:	a8 03                	test   $0x3,%al
  80096f:	75 23                	jne    800994 <memset+0x3f>
		c &= 0xFF;
  800971:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800975:	89 d3                	mov    %edx,%ebx
  800977:	c1 e3 08             	shl    $0x8,%ebx
  80097a:	89 d0                	mov    %edx,%eax
  80097c:	c1 e0 18             	shl    $0x18,%eax
  80097f:	89 d6                	mov    %edx,%esi
  800981:	c1 e6 10             	shl    $0x10,%esi
  800984:	09 f0                	or     %esi,%eax
  800986:	09 c2                	or     %eax,%edx
  800988:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80098a:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  80098d:	89 d0                	mov    %edx,%eax
  80098f:	fc                   	cld    
  800990:	f3 ab                	rep stos %eax,%es:(%edi)
  800992:	eb 06                	jmp    80099a <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800994:	8b 45 0c             	mov    0xc(%ebp),%eax
  800997:	fc                   	cld    
  800998:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80099a:	89 f8                	mov    %edi,%eax
  80099c:	5b                   	pop    %ebx
  80099d:	5e                   	pop    %esi
  80099e:	5f                   	pop    %edi
  80099f:	5d                   	pop    %ebp
  8009a0:	c3                   	ret    

008009a1 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009a1:	f3 0f 1e fb          	endbr32 
  8009a5:	55                   	push   %ebp
  8009a6:	89 e5                	mov    %esp,%ebp
  8009a8:	57                   	push   %edi
  8009a9:	56                   	push   %esi
  8009aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ad:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009b0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009b3:	39 c6                	cmp    %eax,%esi
  8009b5:	73 32                	jae    8009e9 <memmove+0x48>
  8009b7:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009ba:	39 c2                	cmp    %eax,%edx
  8009bc:	76 2b                	jbe    8009e9 <memmove+0x48>
		s += n;
		d += n;
  8009be:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009c1:	89 fe                	mov    %edi,%esi
  8009c3:	09 ce                	or     %ecx,%esi
  8009c5:	09 d6                	or     %edx,%esi
  8009c7:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009cd:	75 0e                	jne    8009dd <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009cf:	83 ef 04             	sub    $0x4,%edi
  8009d2:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009d5:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8009d8:	fd                   	std    
  8009d9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009db:	eb 09                	jmp    8009e6 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009dd:	83 ef 01             	sub    $0x1,%edi
  8009e0:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8009e3:	fd                   	std    
  8009e4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009e6:	fc                   	cld    
  8009e7:	eb 1a                	jmp    800a03 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009e9:	89 c2                	mov    %eax,%edx
  8009eb:	09 ca                	or     %ecx,%edx
  8009ed:	09 f2                	or     %esi,%edx
  8009ef:	f6 c2 03             	test   $0x3,%dl
  8009f2:	75 0a                	jne    8009fe <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009f4:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8009f7:	89 c7                	mov    %eax,%edi
  8009f9:	fc                   	cld    
  8009fa:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009fc:	eb 05                	jmp    800a03 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  8009fe:	89 c7                	mov    %eax,%edi
  800a00:	fc                   	cld    
  800a01:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a03:	5e                   	pop    %esi
  800a04:	5f                   	pop    %edi
  800a05:	5d                   	pop    %ebp
  800a06:	c3                   	ret    

00800a07 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a07:	f3 0f 1e fb          	endbr32 
  800a0b:	55                   	push   %ebp
  800a0c:	89 e5                	mov    %esp,%ebp
  800a0e:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a11:	ff 75 10             	pushl  0x10(%ebp)
  800a14:	ff 75 0c             	pushl  0xc(%ebp)
  800a17:	ff 75 08             	pushl  0x8(%ebp)
  800a1a:	e8 82 ff ff ff       	call   8009a1 <memmove>
}
  800a1f:	c9                   	leave  
  800a20:	c3                   	ret    

00800a21 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a21:	f3 0f 1e fb          	endbr32 
  800a25:	55                   	push   %ebp
  800a26:	89 e5                	mov    %esp,%ebp
  800a28:	56                   	push   %esi
  800a29:	53                   	push   %ebx
  800a2a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a2d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a30:	89 c6                	mov    %eax,%esi
  800a32:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a35:	39 f0                	cmp    %esi,%eax
  800a37:	74 1c                	je     800a55 <memcmp+0x34>
		if (*s1 != *s2)
  800a39:	0f b6 08             	movzbl (%eax),%ecx
  800a3c:	0f b6 1a             	movzbl (%edx),%ebx
  800a3f:	38 d9                	cmp    %bl,%cl
  800a41:	75 08                	jne    800a4b <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800a43:	83 c0 01             	add    $0x1,%eax
  800a46:	83 c2 01             	add    $0x1,%edx
  800a49:	eb ea                	jmp    800a35 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800a4b:	0f b6 c1             	movzbl %cl,%eax
  800a4e:	0f b6 db             	movzbl %bl,%ebx
  800a51:	29 d8                	sub    %ebx,%eax
  800a53:	eb 05                	jmp    800a5a <memcmp+0x39>
	}

	return 0;
  800a55:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a5a:	5b                   	pop    %ebx
  800a5b:	5e                   	pop    %esi
  800a5c:	5d                   	pop    %ebp
  800a5d:	c3                   	ret    

00800a5e <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a5e:	f3 0f 1e fb          	endbr32 
  800a62:	55                   	push   %ebp
  800a63:	89 e5                	mov    %esp,%ebp
  800a65:	8b 45 08             	mov    0x8(%ebp),%eax
  800a68:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a6b:	89 c2                	mov    %eax,%edx
  800a6d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a70:	39 d0                	cmp    %edx,%eax
  800a72:	73 09                	jae    800a7d <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a74:	38 08                	cmp    %cl,(%eax)
  800a76:	74 05                	je     800a7d <memfind+0x1f>
	for (; s < ends; s++)
  800a78:	83 c0 01             	add    $0x1,%eax
  800a7b:	eb f3                	jmp    800a70 <memfind+0x12>
			break;
	return (void *) s;
}
  800a7d:	5d                   	pop    %ebp
  800a7e:	c3                   	ret    

00800a7f <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a7f:	f3 0f 1e fb          	endbr32 
  800a83:	55                   	push   %ebp
  800a84:	89 e5                	mov    %esp,%ebp
  800a86:	57                   	push   %edi
  800a87:	56                   	push   %esi
  800a88:	53                   	push   %ebx
  800a89:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a8c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a8f:	eb 03                	jmp    800a94 <strtol+0x15>
		s++;
  800a91:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800a94:	0f b6 01             	movzbl (%ecx),%eax
  800a97:	3c 20                	cmp    $0x20,%al
  800a99:	74 f6                	je     800a91 <strtol+0x12>
  800a9b:	3c 09                	cmp    $0x9,%al
  800a9d:	74 f2                	je     800a91 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800a9f:	3c 2b                	cmp    $0x2b,%al
  800aa1:	74 2a                	je     800acd <strtol+0x4e>
	int neg = 0;
  800aa3:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800aa8:	3c 2d                	cmp    $0x2d,%al
  800aaa:	74 2b                	je     800ad7 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800aac:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800ab2:	75 0f                	jne    800ac3 <strtol+0x44>
  800ab4:	80 39 30             	cmpb   $0x30,(%ecx)
  800ab7:	74 28                	je     800ae1 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800ab9:	85 db                	test   %ebx,%ebx
  800abb:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ac0:	0f 44 d8             	cmove  %eax,%ebx
  800ac3:	b8 00 00 00 00       	mov    $0x0,%eax
  800ac8:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800acb:	eb 46                	jmp    800b13 <strtol+0x94>
		s++;
  800acd:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800ad0:	bf 00 00 00 00       	mov    $0x0,%edi
  800ad5:	eb d5                	jmp    800aac <strtol+0x2d>
		s++, neg = 1;
  800ad7:	83 c1 01             	add    $0x1,%ecx
  800ada:	bf 01 00 00 00       	mov    $0x1,%edi
  800adf:	eb cb                	jmp    800aac <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ae1:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800ae5:	74 0e                	je     800af5 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800ae7:	85 db                	test   %ebx,%ebx
  800ae9:	75 d8                	jne    800ac3 <strtol+0x44>
		s++, base = 8;
  800aeb:	83 c1 01             	add    $0x1,%ecx
  800aee:	bb 08 00 00 00       	mov    $0x8,%ebx
  800af3:	eb ce                	jmp    800ac3 <strtol+0x44>
		s += 2, base = 16;
  800af5:	83 c1 02             	add    $0x2,%ecx
  800af8:	bb 10 00 00 00       	mov    $0x10,%ebx
  800afd:	eb c4                	jmp    800ac3 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800aff:	0f be d2             	movsbl %dl,%edx
  800b02:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b05:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b08:	7d 3a                	jge    800b44 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800b0a:	83 c1 01             	add    $0x1,%ecx
  800b0d:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b11:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800b13:	0f b6 11             	movzbl (%ecx),%edx
  800b16:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b19:	89 f3                	mov    %esi,%ebx
  800b1b:	80 fb 09             	cmp    $0x9,%bl
  800b1e:	76 df                	jbe    800aff <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800b20:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b23:	89 f3                	mov    %esi,%ebx
  800b25:	80 fb 19             	cmp    $0x19,%bl
  800b28:	77 08                	ja     800b32 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800b2a:	0f be d2             	movsbl %dl,%edx
  800b2d:	83 ea 57             	sub    $0x57,%edx
  800b30:	eb d3                	jmp    800b05 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800b32:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b35:	89 f3                	mov    %esi,%ebx
  800b37:	80 fb 19             	cmp    $0x19,%bl
  800b3a:	77 08                	ja     800b44 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800b3c:	0f be d2             	movsbl %dl,%edx
  800b3f:	83 ea 37             	sub    $0x37,%edx
  800b42:	eb c1                	jmp    800b05 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800b44:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b48:	74 05                	je     800b4f <strtol+0xd0>
		*endptr = (char *) s;
  800b4a:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b4d:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800b4f:	89 c2                	mov    %eax,%edx
  800b51:	f7 da                	neg    %edx
  800b53:	85 ff                	test   %edi,%edi
  800b55:	0f 45 c2             	cmovne %edx,%eax
}
  800b58:	5b                   	pop    %ebx
  800b59:	5e                   	pop    %esi
  800b5a:	5f                   	pop    %edi
  800b5b:	5d                   	pop    %ebp
  800b5c:	c3                   	ret    

00800b5d <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b5d:	f3 0f 1e fb          	endbr32 
  800b61:	55                   	push   %ebp
  800b62:	89 e5                	mov    %esp,%ebp
  800b64:	57                   	push   %edi
  800b65:	56                   	push   %esi
  800b66:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b67:	b8 00 00 00 00       	mov    $0x0,%eax
  800b6c:	8b 55 08             	mov    0x8(%ebp),%edx
  800b6f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b72:	89 c3                	mov    %eax,%ebx
  800b74:	89 c7                	mov    %eax,%edi
  800b76:	89 c6                	mov    %eax,%esi
  800b78:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b7a:	5b                   	pop    %ebx
  800b7b:	5e                   	pop    %esi
  800b7c:	5f                   	pop    %edi
  800b7d:	5d                   	pop    %ebp
  800b7e:	c3                   	ret    

00800b7f <sys_cgetc>:

int
sys_cgetc(void)
{
  800b7f:	f3 0f 1e fb          	endbr32 
  800b83:	55                   	push   %ebp
  800b84:	89 e5                	mov    %esp,%ebp
  800b86:	57                   	push   %edi
  800b87:	56                   	push   %esi
  800b88:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b89:	ba 00 00 00 00       	mov    $0x0,%edx
  800b8e:	b8 01 00 00 00       	mov    $0x1,%eax
  800b93:	89 d1                	mov    %edx,%ecx
  800b95:	89 d3                	mov    %edx,%ebx
  800b97:	89 d7                	mov    %edx,%edi
  800b99:	89 d6                	mov    %edx,%esi
  800b9b:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b9d:	5b                   	pop    %ebx
  800b9e:	5e                   	pop    %esi
  800b9f:	5f                   	pop    %edi
  800ba0:	5d                   	pop    %ebp
  800ba1:	c3                   	ret    

00800ba2 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ba2:	f3 0f 1e fb          	endbr32 
  800ba6:	55                   	push   %ebp
  800ba7:	89 e5                	mov    %esp,%ebp
  800ba9:	57                   	push   %edi
  800baa:	56                   	push   %esi
  800bab:	53                   	push   %ebx
  800bac:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800baf:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bb4:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb7:	b8 03 00 00 00       	mov    $0x3,%eax
  800bbc:	89 cb                	mov    %ecx,%ebx
  800bbe:	89 cf                	mov    %ecx,%edi
  800bc0:	89 ce                	mov    %ecx,%esi
  800bc2:	cd 30                	int    $0x30
	if(check && ret > 0)
  800bc4:	85 c0                	test   %eax,%eax
  800bc6:	7f 08                	jg     800bd0 <sys_env_destroy+0x2e>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bc8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bcb:	5b                   	pop    %ebx
  800bcc:	5e                   	pop    %esi
  800bcd:	5f                   	pop    %edi
  800bce:	5d                   	pop    %ebp
  800bcf:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800bd0:	83 ec 0c             	sub    $0xc,%esp
  800bd3:	50                   	push   %eax
  800bd4:	6a 03                	push   $0x3
  800bd6:	68 44 14 80 00       	push   $0x801444
  800bdb:	6a 23                	push   $0x23
  800bdd:	68 61 14 80 00       	push   $0x801461
  800be2:	e8 13 03 00 00       	call   800efa <_panic>

00800be7 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800be7:	f3 0f 1e fb          	endbr32 
  800beb:	55                   	push   %ebp
  800bec:	89 e5                	mov    %esp,%ebp
  800bee:	57                   	push   %edi
  800bef:	56                   	push   %esi
  800bf0:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bf1:	ba 00 00 00 00       	mov    $0x0,%edx
  800bf6:	b8 02 00 00 00       	mov    $0x2,%eax
  800bfb:	89 d1                	mov    %edx,%ecx
  800bfd:	89 d3                	mov    %edx,%ebx
  800bff:	89 d7                	mov    %edx,%edi
  800c01:	89 d6                	mov    %edx,%esi
  800c03:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c05:	5b                   	pop    %ebx
  800c06:	5e                   	pop    %esi
  800c07:	5f                   	pop    %edi
  800c08:	5d                   	pop    %ebp
  800c09:	c3                   	ret    

00800c0a <sys_yield>:

void
sys_yield(void)
{
  800c0a:	f3 0f 1e fb          	endbr32 
  800c0e:	55                   	push   %ebp
  800c0f:	89 e5                	mov    %esp,%ebp
  800c11:	57                   	push   %edi
  800c12:	56                   	push   %esi
  800c13:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c14:	ba 00 00 00 00       	mov    $0x0,%edx
  800c19:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c1e:	89 d1                	mov    %edx,%ecx
  800c20:	89 d3                	mov    %edx,%ebx
  800c22:	89 d7                	mov    %edx,%edi
  800c24:	89 d6                	mov    %edx,%esi
  800c26:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c28:	5b                   	pop    %ebx
  800c29:	5e                   	pop    %esi
  800c2a:	5f                   	pop    %edi
  800c2b:	5d                   	pop    %ebp
  800c2c:	c3                   	ret    

00800c2d <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c2d:	f3 0f 1e fb          	endbr32 
  800c31:	55                   	push   %ebp
  800c32:	89 e5                	mov    %esp,%ebp
  800c34:	57                   	push   %edi
  800c35:	56                   	push   %esi
  800c36:	53                   	push   %ebx
  800c37:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c3a:	be 00 00 00 00       	mov    $0x0,%esi
  800c3f:	8b 55 08             	mov    0x8(%ebp),%edx
  800c42:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c45:	b8 04 00 00 00       	mov    $0x4,%eax
  800c4a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c4d:	89 f7                	mov    %esi,%edi
  800c4f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c51:	85 c0                	test   %eax,%eax
  800c53:	7f 08                	jg     800c5d <sys_page_alloc+0x30>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c55:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c58:	5b                   	pop    %ebx
  800c59:	5e                   	pop    %esi
  800c5a:	5f                   	pop    %edi
  800c5b:	5d                   	pop    %ebp
  800c5c:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c5d:	83 ec 0c             	sub    $0xc,%esp
  800c60:	50                   	push   %eax
  800c61:	6a 04                	push   $0x4
  800c63:	68 44 14 80 00       	push   $0x801444
  800c68:	6a 23                	push   $0x23
  800c6a:	68 61 14 80 00       	push   $0x801461
  800c6f:	e8 86 02 00 00       	call   800efa <_panic>

00800c74 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c74:	f3 0f 1e fb          	endbr32 
  800c78:	55                   	push   %ebp
  800c79:	89 e5                	mov    %esp,%ebp
  800c7b:	57                   	push   %edi
  800c7c:	56                   	push   %esi
  800c7d:	53                   	push   %ebx
  800c7e:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c81:	8b 55 08             	mov    0x8(%ebp),%edx
  800c84:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c87:	b8 05 00 00 00       	mov    $0x5,%eax
  800c8c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c8f:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c92:	8b 75 18             	mov    0x18(%ebp),%esi
  800c95:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c97:	85 c0                	test   %eax,%eax
  800c99:	7f 08                	jg     800ca3 <sys_page_map+0x2f>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c9b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c9e:	5b                   	pop    %ebx
  800c9f:	5e                   	pop    %esi
  800ca0:	5f                   	pop    %edi
  800ca1:	5d                   	pop    %ebp
  800ca2:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca3:	83 ec 0c             	sub    $0xc,%esp
  800ca6:	50                   	push   %eax
  800ca7:	6a 05                	push   $0x5
  800ca9:	68 44 14 80 00       	push   $0x801444
  800cae:	6a 23                	push   $0x23
  800cb0:	68 61 14 80 00       	push   $0x801461
  800cb5:	e8 40 02 00 00       	call   800efa <_panic>

00800cba <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800cba:	f3 0f 1e fb          	endbr32 
  800cbe:	55                   	push   %ebp
  800cbf:	89 e5                	mov    %esp,%ebp
  800cc1:	57                   	push   %edi
  800cc2:	56                   	push   %esi
  800cc3:	53                   	push   %ebx
  800cc4:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cc7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ccc:	8b 55 08             	mov    0x8(%ebp),%edx
  800ccf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd2:	b8 06 00 00 00       	mov    $0x6,%eax
  800cd7:	89 df                	mov    %ebx,%edi
  800cd9:	89 de                	mov    %ebx,%esi
  800cdb:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cdd:	85 c0                	test   %eax,%eax
  800cdf:	7f 08                	jg     800ce9 <sys_page_unmap+0x2f>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800ce1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ce4:	5b                   	pop    %ebx
  800ce5:	5e                   	pop    %esi
  800ce6:	5f                   	pop    %edi
  800ce7:	5d                   	pop    %ebp
  800ce8:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce9:	83 ec 0c             	sub    $0xc,%esp
  800cec:	50                   	push   %eax
  800ced:	6a 06                	push   $0x6
  800cef:	68 44 14 80 00       	push   $0x801444
  800cf4:	6a 23                	push   $0x23
  800cf6:	68 61 14 80 00       	push   $0x801461
  800cfb:	e8 fa 01 00 00       	call   800efa <_panic>

00800d00 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d00:	f3 0f 1e fb          	endbr32 
  800d04:	55                   	push   %ebp
  800d05:	89 e5                	mov    %esp,%ebp
  800d07:	57                   	push   %edi
  800d08:	56                   	push   %esi
  800d09:	53                   	push   %ebx
  800d0a:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d0d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d12:	8b 55 08             	mov    0x8(%ebp),%edx
  800d15:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d18:	b8 08 00 00 00       	mov    $0x8,%eax
  800d1d:	89 df                	mov    %ebx,%edi
  800d1f:	89 de                	mov    %ebx,%esi
  800d21:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d23:	85 c0                	test   %eax,%eax
  800d25:	7f 08                	jg     800d2f <sys_env_set_status+0x2f>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d27:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d2a:	5b                   	pop    %ebx
  800d2b:	5e                   	pop    %esi
  800d2c:	5f                   	pop    %edi
  800d2d:	5d                   	pop    %ebp
  800d2e:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d2f:	83 ec 0c             	sub    $0xc,%esp
  800d32:	50                   	push   %eax
  800d33:	6a 08                	push   $0x8
  800d35:	68 44 14 80 00       	push   $0x801444
  800d3a:	6a 23                	push   $0x23
  800d3c:	68 61 14 80 00       	push   $0x801461
  800d41:	e8 b4 01 00 00       	call   800efa <_panic>

00800d46 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d46:	f3 0f 1e fb          	endbr32 
  800d4a:	55                   	push   %ebp
  800d4b:	89 e5                	mov    %esp,%ebp
  800d4d:	57                   	push   %edi
  800d4e:	56                   	push   %esi
  800d4f:	53                   	push   %ebx
  800d50:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d53:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d58:	8b 55 08             	mov    0x8(%ebp),%edx
  800d5b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d5e:	b8 09 00 00 00       	mov    $0x9,%eax
  800d63:	89 df                	mov    %ebx,%edi
  800d65:	89 de                	mov    %ebx,%esi
  800d67:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d69:	85 c0                	test   %eax,%eax
  800d6b:	7f 08                	jg     800d75 <sys_env_set_pgfault_upcall+0x2f>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d6d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d70:	5b                   	pop    %ebx
  800d71:	5e                   	pop    %esi
  800d72:	5f                   	pop    %edi
  800d73:	5d                   	pop    %ebp
  800d74:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d75:	83 ec 0c             	sub    $0xc,%esp
  800d78:	50                   	push   %eax
  800d79:	6a 09                	push   $0x9
  800d7b:	68 44 14 80 00       	push   $0x801444
  800d80:	6a 23                	push   $0x23
  800d82:	68 61 14 80 00       	push   $0x801461
  800d87:	e8 6e 01 00 00       	call   800efa <_panic>

00800d8c <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d8c:	f3 0f 1e fb          	endbr32 
  800d90:	55                   	push   %ebp
  800d91:	89 e5                	mov    %esp,%ebp
  800d93:	57                   	push   %edi
  800d94:	56                   	push   %esi
  800d95:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d96:	8b 55 08             	mov    0x8(%ebp),%edx
  800d99:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d9c:	b8 0b 00 00 00       	mov    $0xb,%eax
  800da1:	be 00 00 00 00       	mov    $0x0,%esi
  800da6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800da9:	8b 7d 14             	mov    0x14(%ebp),%edi
  800dac:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800dae:	5b                   	pop    %ebx
  800daf:	5e                   	pop    %esi
  800db0:	5f                   	pop    %edi
  800db1:	5d                   	pop    %ebp
  800db2:	c3                   	ret    

00800db3 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800db3:	f3 0f 1e fb          	endbr32 
  800db7:	55                   	push   %ebp
  800db8:	89 e5                	mov    %esp,%ebp
  800dba:	57                   	push   %edi
  800dbb:	56                   	push   %esi
  800dbc:	53                   	push   %ebx
  800dbd:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800dc0:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dc5:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc8:	b8 0c 00 00 00       	mov    $0xc,%eax
  800dcd:	89 cb                	mov    %ecx,%ebx
  800dcf:	89 cf                	mov    %ecx,%edi
  800dd1:	89 ce                	mov    %ecx,%esi
  800dd3:	cd 30                	int    $0x30
	if(check && ret > 0)
  800dd5:	85 c0                	test   %eax,%eax
  800dd7:	7f 08                	jg     800de1 <sys_ipc_recv+0x2e>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800dd9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ddc:	5b                   	pop    %ebx
  800ddd:	5e                   	pop    %esi
  800dde:	5f                   	pop    %edi
  800ddf:	5d                   	pop    %ebp
  800de0:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800de1:	83 ec 0c             	sub    $0xc,%esp
  800de4:	50                   	push   %eax
  800de5:	6a 0c                	push   $0xc
  800de7:	68 44 14 80 00       	push   $0x801444
  800dec:	6a 23                	push   $0x23
  800dee:	68 61 14 80 00       	push   $0x801461
  800df3:	e8 02 01 00 00       	call   800efa <_panic>

00800df8 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  800df8:	f3 0f 1e fb          	endbr32 
  800dfc:	55                   	push   %ebp
  800dfd:	89 e5                	mov    %esp,%ebp
  800dff:	56                   	push   %esi
  800e00:	53                   	push   %ebx
  800e01:	8b 75 08             	mov    0x8(%ebp),%esi
  800e04:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e07:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// 检查pg是否为空
	if(pg==NULL){
		pg=(void *)-1;
  800e0a:	85 c0                	test   %eax,%eax
  800e0c:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  800e11:	0f 44 c2             	cmove  %edx,%eax
	}
	//接收 message
	int r = sys_ipc_recv(pg);
  800e14:	83 ec 0c             	sub    $0xc,%esp
  800e17:	50                   	push   %eax
  800e18:	e8 96 ff ff ff       	call   800db3 <sys_ipc_recv>
	if(r<0){
  800e1d:	83 c4 10             	add    $0x10,%esp
  800e20:	85 c0                	test   %eax,%eax
  800e22:	78 2b                	js     800e4f <ipc_recv+0x57>
		if(from_env_store) *from_env_store=0;
		if(perm_store) *perm_store=0;
		return r;
	}
	// 保存发送者的envid
	if(from_env_store) *from_env_store = thisenv->env_ipc_from;
  800e24:	85 f6                	test   %esi,%esi
  800e26:	74 0a                	je     800e32 <ipc_recv+0x3a>
  800e28:	a1 04 20 80 00       	mov    0x802004,%eax
  800e2d:	8b 40 74             	mov    0x74(%eax),%eax
  800e30:	89 06                	mov    %eax,(%esi)
	// 保存发送来的页面的权限
	if(perm_store) *perm_store = thisenv->env_ipc_perm;
  800e32:	85 db                	test   %ebx,%ebx
  800e34:	74 0a                	je     800e40 <ipc_recv+0x48>
  800e36:	a1 04 20 80 00       	mov    0x802004,%eax
  800e3b:	8b 40 78             	mov    0x78(%eax),%eax
  800e3e:	89 03                	mov    %eax,(%ebx)
	// 返回message的value
	return thisenv->env_ipc_value;
  800e40:	a1 04 20 80 00       	mov    0x802004,%eax
  800e45:	8b 40 70             	mov    0x70(%eax),%eax

	//panic("ipc_recv not implemented");
	return 0;
}
  800e48:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e4b:	5b                   	pop    %ebx
  800e4c:	5e                   	pop    %esi
  800e4d:	5d                   	pop    %ebp
  800e4e:	c3                   	ret    
		if(from_env_store) *from_env_store=0;
  800e4f:	85 f6                	test   %esi,%esi
  800e51:	74 06                	je     800e59 <ipc_recv+0x61>
  800e53:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store) *perm_store=0;
  800e59:	85 db                	test   %ebx,%ebx
  800e5b:	74 eb                	je     800e48 <ipc_recv+0x50>
  800e5d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800e63:	eb e3                	jmp    800e48 <ipc_recv+0x50>

00800e65 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  800e65:	f3 0f 1e fb          	endbr32 
  800e69:	55                   	push   %ebp
  800e6a:	89 e5                	mov    %esp,%ebp
  800e6c:	57                   	push   %edi
  800e6d:	56                   	push   %esi
  800e6e:	53                   	push   %ebx
  800e6f:	83 ec 0c             	sub    $0xc,%esp
  800e72:	8b 7d 08             	mov    0x8(%ebp),%edi
  800e75:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e78:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	// 如果pg为NULL， 要提供给sys_ipc_try_send一个能表达“no page”的值，0是有效的地址
	if(pg==NULL)
	{
		pg = (void *)-1;
  800e7b:	85 db                	test   %ebx,%ebx
  800e7d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  800e82:	0f 44 d8             	cmove  %eax,%ebx
	}
	int r;
	//不停尝试发送消息直到成功
	while(1)
	{
		r = sys_ipc_try_send(to_env, val, pg, perm);
  800e85:	ff 75 14             	pushl  0x14(%ebp)
  800e88:	53                   	push   %ebx
  800e89:	56                   	push   %esi
  800e8a:	57                   	push   %edi
  800e8b:	e8 fc fe ff ff       	call   800d8c <sys_ipc_try_send>
		if (r == 0) {		//发送成功
  800e90:	83 c4 10             	add    $0x10,%esp
  800e93:	85 c0                	test   %eax,%eax
  800e95:	74 1e                	je     800eb5 <ipc_send+0x50>
			return;
		} else if (r == -E_IPC_NOT_RECV) {	//接收环境未准备接收
  800e97:	83 f8 f9             	cmp    $0xfffffff9,%eax
  800e9a:	75 07                	jne    800ea3 <ipc_send+0x3e>
			sys_yield();
  800e9c:	e8 69 fd ff ff       	call   800c0a <sys_yield>
		r = sys_ipc_try_send(to_env, val, pg, perm);
  800ea1:	eb e2                	jmp    800e85 <ipc_send+0x20>
		}else{
			panic("ipc_send() fault:%e\n", r);
  800ea3:	50                   	push   %eax
  800ea4:	68 6f 14 80 00       	push   $0x80146f
  800ea9:	6a 4c                	push   $0x4c
  800eab:	68 84 14 80 00       	push   $0x801484
  800eb0:	e8 45 00 00 00       	call   800efa <_panic>
		}
	}
}
  800eb5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800eb8:	5b                   	pop    %ebx
  800eb9:	5e                   	pop    %esi
  800eba:	5f                   	pop    %edi
  800ebb:	5d                   	pop    %ebp
  800ebc:	c3                   	ret    

00800ebd <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  800ebd:	f3 0f 1e fb          	endbr32 
  800ec1:	55                   	push   %ebp
  800ec2:	89 e5                	mov    %esp,%ebp
  800ec4:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  800ec7:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  800ecc:	6b d0 7c             	imul   $0x7c,%eax,%edx
  800ecf:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  800ed5:	8b 52 50             	mov    0x50(%edx),%edx
  800ed8:	39 ca                	cmp    %ecx,%edx
  800eda:	74 11                	je     800eed <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  800edc:	83 c0 01             	add    $0x1,%eax
  800edf:	3d 00 04 00 00       	cmp    $0x400,%eax
  800ee4:	75 e6                	jne    800ecc <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  800ee6:	b8 00 00 00 00       	mov    $0x0,%eax
  800eeb:	eb 0b                	jmp    800ef8 <ipc_find_env+0x3b>
			return envs[i].env_id;
  800eed:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800ef0:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800ef5:	8b 40 48             	mov    0x48(%eax),%eax
}
  800ef8:	5d                   	pop    %ebp
  800ef9:	c3                   	ret    

00800efa <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800efa:	f3 0f 1e fb          	endbr32 
  800efe:	55                   	push   %ebp
  800eff:	89 e5                	mov    %esp,%ebp
  800f01:	56                   	push   %esi
  800f02:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800f03:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800f06:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800f0c:	e8 d6 fc ff ff       	call   800be7 <sys_getenvid>
  800f11:	83 ec 0c             	sub    $0xc,%esp
  800f14:	ff 75 0c             	pushl  0xc(%ebp)
  800f17:	ff 75 08             	pushl  0x8(%ebp)
  800f1a:	56                   	push   %esi
  800f1b:	50                   	push   %eax
  800f1c:	68 90 14 80 00       	push   $0x801490
  800f21:	e8 7c f2 ff ff       	call   8001a2 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800f26:	83 c4 18             	add    $0x18,%esp
  800f29:	53                   	push   %ebx
  800f2a:	ff 75 10             	pushl  0x10(%ebp)
  800f2d:	e8 1b f2 ff ff       	call   80014d <vcprintf>
	cprintf("\n");
  800f32:	c7 04 24 82 14 80 00 	movl   $0x801482,(%esp)
  800f39:	e8 64 f2 ff ff       	call   8001a2 <cprintf>
  800f3e:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800f41:	cc                   	int3   
  800f42:	eb fd                	jmp    800f41 <_panic+0x47>
  800f44:	66 90                	xchg   %ax,%ax
  800f46:	66 90                	xchg   %ax,%ax
  800f48:	66 90                	xchg   %ax,%ax
  800f4a:	66 90                	xchg   %ax,%ax
  800f4c:	66 90                	xchg   %ax,%ax
  800f4e:	66 90                	xchg   %ax,%ax

00800f50 <__udivdi3>:
  800f50:	f3 0f 1e fb          	endbr32 
  800f54:	55                   	push   %ebp
  800f55:	57                   	push   %edi
  800f56:	56                   	push   %esi
  800f57:	53                   	push   %ebx
  800f58:	83 ec 1c             	sub    $0x1c,%esp
  800f5b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800f5f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800f63:	8b 74 24 34          	mov    0x34(%esp),%esi
  800f67:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800f6b:	85 d2                	test   %edx,%edx
  800f6d:	75 19                	jne    800f88 <__udivdi3+0x38>
  800f6f:	39 f3                	cmp    %esi,%ebx
  800f71:	76 4d                	jbe    800fc0 <__udivdi3+0x70>
  800f73:	31 ff                	xor    %edi,%edi
  800f75:	89 e8                	mov    %ebp,%eax
  800f77:	89 f2                	mov    %esi,%edx
  800f79:	f7 f3                	div    %ebx
  800f7b:	89 fa                	mov    %edi,%edx
  800f7d:	83 c4 1c             	add    $0x1c,%esp
  800f80:	5b                   	pop    %ebx
  800f81:	5e                   	pop    %esi
  800f82:	5f                   	pop    %edi
  800f83:	5d                   	pop    %ebp
  800f84:	c3                   	ret    
  800f85:	8d 76 00             	lea    0x0(%esi),%esi
  800f88:	39 f2                	cmp    %esi,%edx
  800f8a:	76 14                	jbe    800fa0 <__udivdi3+0x50>
  800f8c:	31 ff                	xor    %edi,%edi
  800f8e:	31 c0                	xor    %eax,%eax
  800f90:	89 fa                	mov    %edi,%edx
  800f92:	83 c4 1c             	add    $0x1c,%esp
  800f95:	5b                   	pop    %ebx
  800f96:	5e                   	pop    %esi
  800f97:	5f                   	pop    %edi
  800f98:	5d                   	pop    %ebp
  800f99:	c3                   	ret    
  800f9a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800fa0:	0f bd fa             	bsr    %edx,%edi
  800fa3:	83 f7 1f             	xor    $0x1f,%edi
  800fa6:	75 48                	jne    800ff0 <__udivdi3+0xa0>
  800fa8:	39 f2                	cmp    %esi,%edx
  800faa:	72 06                	jb     800fb2 <__udivdi3+0x62>
  800fac:	31 c0                	xor    %eax,%eax
  800fae:	39 eb                	cmp    %ebp,%ebx
  800fb0:	77 de                	ja     800f90 <__udivdi3+0x40>
  800fb2:	b8 01 00 00 00       	mov    $0x1,%eax
  800fb7:	eb d7                	jmp    800f90 <__udivdi3+0x40>
  800fb9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800fc0:	89 d9                	mov    %ebx,%ecx
  800fc2:	85 db                	test   %ebx,%ebx
  800fc4:	75 0b                	jne    800fd1 <__udivdi3+0x81>
  800fc6:	b8 01 00 00 00       	mov    $0x1,%eax
  800fcb:	31 d2                	xor    %edx,%edx
  800fcd:	f7 f3                	div    %ebx
  800fcf:	89 c1                	mov    %eax,%ecx
  800fd1:	31 d2                	xor    %edx,%edx
  800fd3:	89 f0                	mov    %esi,%eax
  800fd5:	f7 f1                	div    %ecx
  800fd7:	89 c6                	mov    %eax,%esi
  800fd9:	89 e8                	mov    %ebp,%eax
  800fdb:	89 f7                	mov    %esi,%edi
  800fdd:	f7 f1                	div    %ecx
  800fdf:	89 fa                	mov    %edi,%edx
  800fe1:	83 c4 1c             	add    $0x1c,%esp
  800fe4:	5b                   	pop    %ebx
  800fe5:	5e                   	pop    %esi
  800fe6:	5f                   	pop    %edi
  800fe7:	5d                   	pop    %ebp
  800fe8:	c3                   	ret    
  800fe9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800ff0:	89 f9                	mov    %edi,%ecx
  800ff2:	b8 20 00 00 00       	mov    $0x20,%eax
  800ff7:	29 f8                	sub    %edi,%eax
  800ff9:	d3 e2                	shl    %cl,%edx
  800ffb:	89 54 24 08          	mov    %edx,0x8(%esp)
  800fff:	89 c1                	mov    %eax,%ecx
  801001:	89 da                	mov    %ebx,%edx
  801003:	d3 ea                	shr    %cl,%edx
  801005:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801009:	09 d1                	or     %edx,%ecx
  80100b:	89 f2                	mov    %esi,%edx
  80100d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801011:	89 f9                	mov    %edi,%ecx
  801013:	d3 e3                	shl    %cl,%ebx
  801015:	89 c1                	mov    %eax,%ecx
  801017:	d3 ea                	shr    %cl,%edx
  801019:	89 f9                	mov    %edi,%ecx
  80101b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80101f:	89 eb                	mov    %ebp,%ebx
  801021:	d3 e6                	shl    %cl,%esi
  801023:	89 c1                	mov    %eax,%ecx
  801025:	d3 eb                	shr    %cl,%ebx
  801027:	09 de                	or     %ebx,%esi
  801029:	89 f0                	mov    %esi,%eax
  80102b:	f7 74 24 08          	divl   0x8(%esp)
  80102f:	89 d6                	mov    %edx,%esi
  801031:	89 c3                	mov    %eax,%ebx
  801033:	f7 64 24 0c          	mull   0xc(%esp)
  801037:	39 d6                	cmp    %edx,%esi
  801039:	72 15                	jb     801050 <__udivdi3+0x100>
  80103b:	89 f9                	mov    %edi,%ecx
  80103d:	d3 e5                	shl    %cl,%ebp
  80103f:	39 c5                	cmp    %eax,%ebp
  801041:	73 04                	jae    801047 <__udivdi3+0xf7>
  801043:	39 d6                	cmp    %edx,%esi
  801045:	74 09                	je     801050 <__udivdi3+0x100>
  801047:	89 d8                	mov    %ebx,%eax
  801049:	31 ff                	xor    %edi,%edi
  80104b:	e9 40 ff ff ff       	jmp    800f90 <__udivdi3+0x40>
  801050:	8d 43 ff             	lea    -0x1(%ebx),%eax
  801053:	31 ff                	xor    %edi,%edi
  801055:	e9 36 ff ff ff       	jmp    800f90 <__udivdi3+0x40>
  80105a:	66 90                	xchg   %ax,%ax
  80105c:	66 90                	xchg   %ax,%ax
  80105e:	66 90                	xchg   %ax,%ax

00801060 <__umoddi3>:
  801060:	f3 0f 1e fb          	endbr32 
  801064:	55                   	push   %ebp
  801065:	57                   	push   %edi
  801066:	56                   	push   %esi
  801067:	53                   	push   %ebx
  801068:	83 ec 1c             	sub    $0x1c,%esp
  80106b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80106f:	8b 74 24 30          	mov    0x30(%esp),%esi
  801073:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  801077:	8b 7c 24 38          	mov    0x38(%esp),%edi
  80107b:	85 c0                	test   %eax,%eax
  80107d:	75 19                	jne    801098 <__umoddi3+0x38>
  80107f:	39 df                	cmp    %ebx,%edi
  801081:	76 5d                	jbe    8010e0 <__umoddi3+0x80>
  801083:	89 f0                	mov    %esi,%eax
  801085:	89 da                	mov    %ebx,%edx
  801087:	f7 f7                	div    %edi
  801089:	89 d0                	mov    %edx,%eax
  80108b:	31 d2                	xor    %edx,%edx
  80108d:	83 c4 1c             	add    $0x1c,%esp
  801090:	5b                   	pop    %ebx
  801091:	5e                   	pop    %esi
  801092:	5f                   	pop    %edi
  801093:	5d                   	pop    %ebp
  801094:	c3                   	ret    
  801095:	8d 76 00             	lea    0x0(%esi),%esi
  801098:	89 f2                	mov    %esi,%edx
  80109a:	39 d8                	cmp    %ebx,%eax
  80109c:	76 12                	jbe    8010b0 <__umoddi3+0x50>
  80109e:	89 f0                	mov    %esi,%eax
  8010a0:	89 da                	mov    %ebx,%edx
  8010a2:	83 c4 1c             	add    $0x1c,%esp
  8010a5:	5b                   	pop    %ebx
  8010a6:	5e                   	pop    %esi
  8010a7:	5f                   	pop    %edi
  8010a8:	5d                   	pop    %ebp
  8010a9:	c3                   	ret    
  8010aa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8010b0:	0f bd e8             	bsr    %eax,%ebp
  8010b3:	83 f5 1f             	xor    $0x1f,%ebp
  8010b6:	75 50                	jne    801108 <__umoddi3+0xa8>
  8010b8:	39 d8                	cmp    %ebx,%eax
  8010ba:	0f 82 e0 00 00 00    	jb     8011a0 <__umoddi3+0x140>
  8010c0:	89 d9                	mov    %ebx,%ecx
  8010c2:	39 f7                	cmp    %esi,%edi
  8010c4:	0f 86 d6 00 00 00    	jbe    8011a0 <__umoddi3+0x140>
  8010ca:	89 d0                	mov    %edx,%eax
  8010cc:	89 ca                	mov    %ecx,%edx
  8010ce:	83 c4 1c             	add    $0x1c,%esp
  8010d1:	5b                   	pop    %ebx
  8010d2:	5e                   	pop    %esi
  8010d3:	5f                   	pop    %edi
  8010d4:	5d                   	pop    %ebp
  8010d5:	c3                   	ret    
  8010d6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8010dd:	8d 76 00             	lea    0x0(%esi),%esi
  8010e0:	89 fd                	mov    %edi,%ebp
  8010e2:	85 ff                	test   %edi,%edi
  8010e4:	75 0b                	jne    8010f1 <__umoddi3+0x91>
  8010e6:	b8 01 00 00 00       	mov    $0x1,%eax
  8010eb:	31 d2                	xor    %edx,%edx
  8010ed:	f7 f7                	div    %edi
  8010ef:	89 c5                	mov    %eax,%ebp
  8010f1:	89 d8                	mov    %ebx,%eax
  8010f3:	31 d2                	xor    %edx,%edx
  8010f5:	f7 f5                	div    %ebp
  8010f7:	89 f0                	mov    %esi,%eax
  8010f9:	f7 f5                	div    %ebp
  8010fb:	89 d0                	mov    %edx,%eax
  8010fd:	31 d2                	xor    %edx,%edx
  8010ff:	eb 8c                	jmp    80108d <__umoddi3+0x2d>
  801101:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801108:	89 e9                	mov    %ebp,%ecx
  80110a:	ba 20 00 00 00       	mov    $0x20,%edx
  80110f:	29 ea                	sub    %ebp,%edx
  801111:	d3 e0                	shl    %cl,%eax
  801113:	89 44 24 08          	mov    %eax,0x8(%esp)
  801117:	89 d1                	mov    %edx,%ecx
  801119:	89 f8                	mov    %edi,%eax
  80111b:	d3 e8                	shr    %cl,%eax
  80111d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801121:	89 54 24 04          	mov    %edx,0x4(%esp)
  801125:	8b 54 24 04          	mov    0x4(%esp),%edx
  801129:	09 c1                	or     %eax,%ecx
  80112b:	89 d8                	mov    %ebx,%eax
  80112d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801131:	89 e9                	mov    %ebp,%ecx
  801133:	d3 e7                	shl    %cl,%edi
  801135:	89 d1                	mov    %edx,%ecx
  801137:	d3 e8                	shr    %cl,%eax
  801139:	89 e9                	mov    %ebp,%ecx
  80113b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80113f:	d3 e3                	shl    %cl,%ebx
  801141:	89 c7                	mov    %eax,%edi
  801143:	89 d1                	mov    %edx,%ecx
  801145:	89 f0                	mov    %esi,%eax
  801147:	d3 e8                	shr    %cl,%eax
  801149:	89 e9                	mov    %ebp,%ecx
  80114b:	89 fa                	mov    %edi,%edx
  80114d:	d3 e6                	shl    %cl,%esi
  80114f:	09 d8                	or     %ebx,%eax
  801151:	f7 74 24 08          	divl   0x8(%esp)
  801155:	89 d1                	mov    %edx,%ecx
  801157:	89 f3                	mov    %esi,%ebx
  801159:	f7 64 24 0c          	mull   0xc(%esp)
  80115d:	89 c6                	mov    %eax,%esi
  80115f:	89 d7                	mov    %edx,%edi
  801161:	39 d1                	cmp    %edx,%ecx
  801163:	72 06                	jb     80116b <__umoddi3+0x10b>
  801165:	75 10                	jne    801177 <__umoddi3+0x117>
  801167:	39 c3                	cmp    %eax,%ebx
  801169:	73 0c                	jae    801177 <__umoddi3+0x117>
  80116b:	2b 44 24 0c          	sub    0xc(%esp),%eax
  80116f:	1b 54 24 08          	sbb    0x8(%esp),%edx
  801173:	89 d7                	mov    %edx,%edi
  801175:	89 c6                	mov    %eax,%esi
  801177:	89 ca                	mov    %ecx,%edx
  801179:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80117e:	29 f3                	sub    %esi,%ebx
  801180:	19 fa                	sbb    %edi,%edx
  801182:	89 d0                	mov    %edx,%eax
  801184:	d3 e0                	shl    %cl,%eax
  801186:	89 e9                	mov    %ebp,%ecx
  801188:	d3 eb                	shr    %cl,%ebx
  80118a:	d3 ea                	shr    %cl,%edx
  80118c:	09 d8                	or     %ebx,%eax
  80118e:	83 c4 1c             	add    $0x1c,%esp
  801191:	5b                   	pop    %ebx
  801192:	5e                   	pop    %esi
  801193:	5f                   	pop    %edi
  801194:	5d                   	pop    %ebp
  801195:	c3                   	ret    
  801196:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80119d:	8d 76 00             	lea    0x0(%esi),%esi
  8011a0:	29 fe                	sub    %edi,%esi
  8011a2:	19 c3                	sbb    %eax,%ebx
  8011a4:	89 f2                	mov    %esi,%edx
  8011a6:	89 d9                	mov    %ebx,%ecx
  8011a8:	e9 1d ff ff ff       	jmp    8010ca <__umoddi3+0x6a>
