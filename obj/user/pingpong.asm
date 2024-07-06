
obj/user/pingpong:     file format elf32-i386


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
  80002c:	e8 93 00 00 00       	call   8000c4 <libmain>
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
  80003a:	57                   	push   %edi
  80003b:	56                   	push   %esi
  80003c:	53                   	push   %ebx
  80003d:	83 ec 1c             	sub    $0x1c,%esp
	envid_t who;

	if ((who = fork()) != 0) {
  800040:	e8 ba 0e 00 00       	call   800eff <fork>
  800045:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800048:	85 c0                	test   %eax,%eax
  80004a:	75 4f                	jne    80009b <umain+0x68>
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
		ipc_send(who, 0, 0, 0);
	}

	while (1) {
		uint32_t i = ipc_recv(&who, 0, 0);
  80004c:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  80004f:	83 ec 04             	sub    $0x4,%esp
  800052:	6a 00                	push   $0x0
  800054:	6a 00                	push   $0x0
  800056:	56                   	push   %esi
  800057:	e8 b7 10 00 00       	call   801113 <ipc_recv>
  80005c:	89 c3                	mov    %eax,%ebx
		cprintf("%x got %d from %x\n", sys_getenvid(), i, who);
  80005e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800061:	e8 a0 0b 00 00       	call   800c06 <sys_getenvid>
  800066:	57                   	push   %edi
  800067:	53                   	push   %ebx
  800068:	50                   	push   %eax
  800069:	68 76 15 80 00       	push   $0x801576
  80006e:	e8 4e 01 00 00       	call   8001c1 <cprintf>
		if (i == 10)
  800073:	83 c4 20             	add    $0x20,%esp
  800076:	83 fb 0a             	cmp    $0xa,%ebx
  800079:	74 18                	je     800093 <umain+0x60>
			return;
		i++;
  80007b:	83 c3 01             	add    $0x1,%ebx
		ipc_send(who, i, 0, 0);
  80007e:	6a 00                	push   $0x0
  800080:	6a 00                	push   $0x0
  800082:	53                   	push   %ebx
  800083:	ff 75 e4             	pushl  -0x1c(%ebp)
  800086:	e8 f5 10 00 00       	call   801180 <ipc_send>
		if (i == 10)
  80008b:	83 c4 10             	add    $0x10,%esp
  80008e:	83 fb 0a             	cmp    $0xa,%ebx
  800091:	75 bc                	jne    80004f <umain+0x1c>
			return;
	}

}
  800093:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800096:	5b                   	pop    %ebx
  800097:	5e                   	pop    %esi
  800098:	5f                   	pop    %edi
  800099:	5d                   	pop    %ebp
  80009a:	c3                   	ret    
  80009b:	89 c3                	mov    %eax,%ebx
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  80009d:	e8 64 0b 00 00       	call   800c06 <sys_getenvid>
  8000a2:	83 ec 04             	sub    $0x4,%esp
  8000a5:	53                   	push   %ebx
  8000a6:	50                   	push   %eax
  8000a7:	68 60 15 80 00       	push   $0x801560
  8000ac:	e8 10 01 00 00       	call   8001c1 <cprintf>
		ipc_send(who, 0, 0, 0);
  8000b1:	6a 00                	push   $0x0
  8000b3:	6a 00                	push   $0x0
  8000b5:	6a 00                	push   $0x0
  8000b7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8000ba:	e8 c1 10 00 00       	call   801180 <ipc_send>
  8000bf:	83 c4 20             	add    $0x20,%esp
  8000c2:	eb 88                	jmp    80004c <umain+0x19>

008000c4 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000c4:	f3 0f 1e fb          	endbr32 
  8000c8:	55                   	push   %ebp
  8000c9:	89 e5                	mov    %esp,%ebp
  8000cb:	56                   	push   %esi
  8000cc:	53                   	push   %ebx
  8000cd:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000d0:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv=&envs[ENVX(sys_getenvid())];
  8000d3:	e8 2e 0b 00 00       	call   800c06 <sys_getenvid>
  8000d8:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000dd:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000e0:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000e5:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000ea:	85 db                	test   %ebx,%ebx
  8000ec:	7e 07                	jle    8000f5 <libmain+0x31>
		binaryname = argv[0];
  8000ee:	8b 06                	mov    (%esi),%eax
  8000f0:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000f5:	83 ec 08             	sub    $0x8,%esp
  8000f8:	56                   	push   %esi
  8000f9:	53                   	push   %ebx
  8000fa:	e8 34 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000ff:	e8 0a 00 00 00       	call   80010e <exit>
}
  800104:	83 c4 10             	add    $0x10,%esp
  800107:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80010a:	5b                   	pop    %ebx
  80010b:	5e                   	pop    %esi
  80010c:	5d                   	pop    %ebp
  80010d:	c3                   	ret    

0080010e <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80010e:	f3 0f 1e fb          	endbr32 
  800112:	55                   	push   %ebp
  800113:	89 e5                	mov    %esp,%ebp
  800115:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800118:	6a 00                	push   $0x0
  80011a:	e8 a2 0a 00 00       	call   800bc1 <sys_env_destroy>
}
  80011f:	83 c4 10             	add    $0x10,%esp
  800122:	c9                   	leave  
  800123:	c3                   	ret    

00800124 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800124:	f3 0f 1e fb          	endbr32 
  800128:	55                   	push   %ebp
  800129:	89 e5                	mov    %esp,%ebp
  80012b:	53                   	push   %ebx
  80012c:	83 ec 04             	sub    $0x4,%esp
  80012f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800132:	8b 13                	mov    (%ebx),%edx
  800134:	8d 42 01             	lea    0x1(%edx),%eax
  800137:	89 03                	mov    %eax,(%ebx)
  800139:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80013c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800140:	3d ff 00 00 00       	cmp    $0xff,%eax
  800145:	74 09                	je     800150 <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800147:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80014b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80014e:	c9                   	leave  
  80014f:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800150:	83 ec 08             	sub    $0x8,%esp
  800153:	68 ff 00 00 00       	push   $0xff
  800158:	8d 43 08             	lea    0x8(%ebx),%eax
  80015b:	50                   	push   %eax
  80015c:	e8 1b 0a 00 00       	call   800b7c <sys_cputs>
		b->idx = 0;
  800161:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800167:	83 c4 10             	add    $0x10,%esp
  80016a:	eb db                	jmp    800147 <putch+0x23>

0080016c <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80016c:	f3 0f 1e fb          	endbr32 
  800170:	55                   	push   %ebp
  800171:	89 e5                	mov    %esp,%ebp
  800173:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800179:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800180:	00 00 00 
	b.cnt = 0;
  800183:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80018a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80018d:	ff 75 0c             	pushl  0xc(%ebp)
  800190:	ff 75 08             	pushl  0x8(%ebp)
  800193:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800199:	50                   	push   %eax
  80019a:	68 24 01 80 00       	push   $0x800124
  80019f:	e8 20 01 00 00       	call   8002c4 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001a4:	83 c4 08             	add    $0x8,%esp
  8001a7:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001ad:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001b3:	50                   	push   %eax
  8001b4:	e8 c3 09 00 00       	call   800b7c <sys_cputs>

	return b.cnt;
}
  8001b9:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001bf:	c9                   	leave  
  8001c0:	c3                   	ret    

008001c1 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001c1:	f3 0f 1e fb          	endbr32 
  8001c5:	55                   	push   %ebp
  8001c6:	89 e5                	mov    %esp,%ebp
  8001c8:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001cb:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001ce:	50                   	push   %eax
  8001cf:	ff 75 08             	pushl  0x8(%ebp)
  8001d2:	e8 95 ff ff ff       	call   80016c <vcprintf>
	va_end(ap);

	return cnt;
}
  8001d7:	c9                   	leave  
  8001d8:	c3                   	ret    

008001d9 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001d9:	55                   	push   %ebp
  8001da:	89 e5                	mov    %esp,%ebp
  8001dc:	57                   	push   %edi
  8001dd:	56                   	push   %esi
  8001de:	53                   	push   %ebx
  8001df:	83 ec 1c             	sub    $0x1c,%esp
  8001e2:	89 c7                	mov    %eax,%edi
  8001e4:	89 d6                	mov    %edx,%esi
  8001e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8001e9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001ec:	89 d1                	mov    %edx,%ecx
  8001ee:	89 c2                	mov    %eax,%edx
  8001f0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001f3:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8001f6:	8b 45 10             	mov    0x10(%ebp),%eax
  8001f9:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001fc:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001ff:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800206:	39 c2                	cmp    %eax,%edx
  800208:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  80020b:	72 3e                	jb     80024b <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80020d:	83 ec 0c             	sub    $0xc,%esp
  800210:	ff 75 18             	pushl  0x18(%ebp)
  800213:	83 eb 01             	sub    $0x1,%ebx
  800216:	53                   	push   %ebx
  800217:	50                   	push   %eax
  800218:	83 ec 08             	sub    $0x8,%esp
  80021b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80021e:	ff 75 e0             	pushl  -0x20(%ebp)
  800221:	ff 75 dc             	pushl  -0x24(%ebp)
  800224:	ff 75 d8             	pushl  -0x28(%ebp)
  800227:	e8 c4 10 00 00       	call   8012f0 <__udivdi3>
  80022c:	83 c4 18             	add    $0x18,%esp
  80022f:	52                   	push   %edx
  800230:	50                   	push   %eax
  800231:	89 f2                	mov    %esi,%edx
  800233:	89 f8                	mov    %edi,%eax
  800235:	e8 9f ff ff ff       	call   8001d9 <printnum>
  80023a:	83 c4 20             	add    $0x20,%esp
  80023d:	eb 13                	jmp    800252 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80023f:	83 ec 08             	sub    $0x8,%esp
  800242:	56                   	push   %esi
  800243:	ff 75 18             	pushl  0x18(%ebp)
  800246:	ff d7                	call   *%edi
  800248:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80024b:	83 eb 01             	sub    $0x1,%ebx
  80024e:	85 db                	test   %ebx,%ebx
  800250:	7f ed                	jg     80023f <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800252:	83 ec 08             	sub    $0x8,%esp
  800255:	56                   	push   %esi
  800256:	83 ec 04             	sub    $0x4,%esp
  800259:	ff 75 e4             	pushl  -0x1c(%ebp)
  80025c:	ff 75 e0             	pushl  -0x20(%ebp)
  80025f:	ff 75 dc             	pushl  -0x24(%ebp)
  800262:	ff 75 d8             	pushl  -0x28(%ebp)
  800265:	e8 96 11 00 00       	call   801400 <__umoddi3>
  80026a:	83 c4 14             	add    $0x14,%esp
  80026d:	0f be 80 93 15 80 00 	movsbl 0x801593(%eax),%eax
  800274:	50                   	push   %eax
  800275:	ff d7                	call   *%edi
}
  800277:	83 c4 10             	add    $0x10,%esp
  80027a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80027d:	5b                   	pop    %ebx
  80027e:	5e                   	pop    %esi
  80027f:	5f                   	pop    %edi
  800280:	5d                   	pop    %ebp
  800281:	c3                   	ret    

00800282 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800282:	f3 0f 1e fb          	endbr32 
  800286:	55                   	push   %ebp
  800287:	89 e5                	mov    %esp,%ebp
  800289:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80028c:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800290:	8b 10                	mov    (%eax),%edx
  800292:	3b 50 04             	cmp    0x4(%eax),%edx
  800295:	73 0a                	jae    8002a1 <sprintputch+0x1f>
		*b->buf++ = ch;
  800297:	8d 4a 01             	lea    0x1(%edx),%ecx
  80029a:	89 08                	mov    %ecx,(%eax)
  80029c:	8b 45 08             	mov    0x8(%ebp),%eax
  80029f:	88 02                	mov    %al,(%edx)
}
  8002a1:	5d                   	pop    %ebp
  8002a2:	c3                   	ret    

008002a3 <printfmt>:
{
  8002a3:	f3 0f 1e fb          	endbr32 
  8002a7:	55                   	push   %ebp
  8002a8:	89 e5                	mov    %esp,%ebp
  8002aa:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8002ad:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002b0:	50                   	push   %eax
  8002b1:	ff 75 10             	pushl  0x10(%ebp)
  8002b4:	ff 75 0c             	pushl  0xc(%ebp)
  8002b7:	ff 75 08             	pushl  0x8(%ebp)
  8002ba:	e8 05 00 00 00       	call   8002c4 <vprintfmt>
}
  8002bf:	83 c4 10             	add    $0x10,%esp
  8002c2:	c9                   	leave  
  8002c3:	c3                   	ret    

008002c4 <vprintfmt>:
{
  8002c4:	f3 0f 1e fb          	endbr32 
  8002c8:	55                   	push   %ebp
  8002c9:	89 e5                	mov    %esp,%ebp
  8002cb:	57                   	push   %edi
  8002cc:	56                   	push   %esi
  8002cd:	53                   	push   %ebx
  8002ce:	83 ec 3c             	sub    $0x3c,%esp
  8002d1:	8b 75 08             	mov    0x8(%ebp),%esi
  8002d4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002d7:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002da:	e9 cd 03 00 00       	jmp    8006ac <vprintfmt+0x3e8>
		padc = ' ';
  8002df:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  8002e3:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8002ea:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8002f1:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8002f8:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8002fd:	8d 47 01             	lea    0x1(%edi),%eax
  800300:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800303:	0f b6 17             	movzbl (%edi),%edx
  800306:	8d 42 dd             	lea    -0x23(%edx),%eax
  800309:	3c 55                	cmp    $0x55,%al
  80030b:	0f 87 1e 04 00 00    	ja     80072f <vprintfmt+0x46b>
  800311:	0f b6 c0             	movzbl %al,%eax
  800314:	3e ff 24 85 60 16 80 	notrack jmp *0x801660(,%eax,4)
  80031b:	00 
  80031c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80031f:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800323:	eb d8                	jmp    8002fd <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800325:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800328:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  80032c:	eb cf                	jmp    8002fd <vprintfmt+0x39>
  80032e:	0f b6 d2             	movzbl %dl,%edx
  800331:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800334:	b8 00 00 00 00       	mov    $0x0,%eax
  800339:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  80033c:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80033f:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800343:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800346:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800349:	83 f9 09             	cmp    $0x9,%ecx
  80034c:	77 55                	ja     8003a3 <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  80034e:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800351:	eb e9                	jmp    80033c <vprintfmt+0x78>
			precision = va_arg(ap, int);
  800353:	8b 45 14             	mov    0x14(%ebp),%eax
  800356:	8b 00                	mov    (%eax),%eax
  800358:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80035b:	8b 45 14             	mov    0x14(%ebp),%eax
  80035e:	8d 40 04             	lea    0x4(%eax),%eax
  800361:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800364:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800367:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80036b:	79 90                	jns    8002fd <vprintfmt+0x39>
				width = precision, precision = -1;
  80036d:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800370:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800373:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80037a:	eb 81                	jmp    8002fd <vprintfmt+0x39>
  80037c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80037f:	85 c0                	test   %eax,%eax
  800381:	ba 00 00 00 00       	mov    $0x0,%edx
  800386:	0f 49 d0             	cmovns %eax,%edx
  800389:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80038c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80038f:	e9 69 ff ff ff       	jmp    8002fd <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800394:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800397:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  80039e:	e9 5a ff ff ff       	jmp    8002fd <vprintfmt+0x39>
  8003a3:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003a6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003a9:	eb bc                	jmp    800367 <vprintfmt+0xa3>
			lflag++;
  8003ab:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8003ae:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003b1:	e9 47 ff ff ff       	jmp    8002fd <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  8003b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b9:	8d 78 04             	lea    0x4(%eax),%edi
  8003bc:	83 ec 08             	sub    $0x8,%esp
  8003bf:	53                   	push   %ebx
  8003c0:	ff 30                	pushl  (%eax)
  8003c2:	ff d6                	call   *%esi
			break;
  8003c4:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8003c7:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8003ca:	e9 da 02 00 00       	jmp    8006a9 <vprintfmt+0x3e5>
			err = va_arg(ap, int);
  8003cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d2:	8d 78 04             	lea    0x4(%eax),%edi
  8003d5:	8b 00                	mov    (%eax),%eax
  8003d7:	99                   	cltd   
  8003d8:	31 d0                	xor    %edx,%eax
  8003da:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003dc:	83 f8 08             	cmp    $0x8,%eax
  8003df:	7f 23                	jg     800404 <vprintfmt+0x140>
  8003e1:	8b 14 85 c0 17 80 00 	mov    0x8017c0(,%eax,4),%edx
  8003e8:	85 d2                	test   %edx,%edx
  8003ea:	74 18                	je     800404 <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  8003ec:	52                   	push   %edx
  8003ed:	68 b4 15 80 00       	push   $0x8015b4
  8003f2:	53                   	push   %ebx
  8003f3:	56                   	push   %esi
  8003f4:	e8 aa fe ff ff       	call   8002a3 <printfmt>
  8003f9:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003fc:	89 7d 14             	mov    %edi,0x14(%ebp)
  8003ff:	e9 a5 02 00 00       	jmp    8006a9 <vprintfmt+0x3e5>
				printfmt(putch, putdat, "error %d", err);
  800404:	50                   	push   %eax
  800405:	68 ab 15 80 00       	push   $0x8015ab
  80040a:	53                   	push   %ebx
  80040b:	56                   	push   %esi
  80040c:	e8 92 fe ff ff       	call   8002a3 <printfmt>
  800411:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800414:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800417:	e9 8d 02 00 00       	jmp    8006a9 <vprintfmt+0x3e5>
			if ((p = va_arg(ap, char *)) == NULL)
  80041c:	8b 45 14             	mov    0x14(%ebp),%eax
  80041f:	83 c0 04             	add    $0x4,%eax
  800422:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800425:	8b 45 14             	mov    0x14(%ebp),%eax
  800428:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  80042a:	85 d2                	test   %edx,%edx
  80042c:	b8 a4 15 80 00       	mov    $0x8015a4,%eax
  800431:	0f 45 c2             	cmovne %edx,%eax
  800434:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  800437:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80043b:	7e 06                	jle    800443 <vprintfmt+0x17f>
  80043d:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  800441:	75 0d                	jne    800450 <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  800443:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800446:	89 c7                	mov    %eax,%edi
  800448:	03 45 e0             	add    -0x20(%ebp),%eax
  80044b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80044e:	eb 55                	jmp    8004a5 <vprintfmt+0x1e1>
  800450:	83 ec 08             	sub    $0x8,%esp
  800453:	ff 75 d8             	pushl  -0x28(%ebp)
  800456:	ff 75 cc             	pushl  -0x34(%ebp)
  800459:	e8 85 03 00 00       	call   8007e3 <strnlen>
  80045e:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800461:	29 c2                	sub    %eax,%edx
  800463:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  800466:	83 c4 10             	add    $0x10,%esp
  800469:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  80046b:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  80046f:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800472:	85 ff                	test   %edi,%edi
  800474:	7e 11                	jle    800487 <vprintfmt+0x1c3>
					putch(padc, putdat);
  800476:	83 ec 08             	sub    $0x8,%esp
  800479:	53                   	push   %ebx
  80047a:	ff 75 e0             	pushl  -0x20(%ebp)
  80047d:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  80047f:	83 ef 01             	sub    $0x1,%edi
  800482:	83 c4 10             	add    $0x10,%esp
  800485:	eb eb                	jmp    800472 <vprintfmt+0x1ae>
  800487:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  80048a:	85 d2                	test   %edx,%edx
  80048c:	b8 00 00 00 00       	mov    $0x0,%eax
  800491:	0f 49 c2             	cmovns %edx,%eax
  800494:	29 c2                	sub    %eax,%edx
  800496:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800499:	eb a8                	jmp    800443 <vprintfmt+0x17f>
					putch(ch, putdat);
  80049b:	83 ec 08             	sub    $0x8,%esp
  80049e:	53                   	push   %ebx
  80049f:	52                   	push   %edx
  8004a0:	ff d6                	call   *%esi
  8004a2:	83 c4 10             	add    $0x10,%esp
  8004a5:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004a8:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004aa:	83 c7 01             	add    $0x1,%edi
  8004ad:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004b1:	0f be d0             	movsbl %al,%edx
  8004b4:	85 d2                	test   %edx,%edx
  8004b6:	74 4b                	je     800503 <vprintfmt+0x23f>
  8004b8:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004bc:	78 06                	js     8004c4 <vprintfmt+0x200>
  8004be:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8004c2:	78 1e                	js     8004e2 <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
  8004c4:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8004c8:	74 d1                	je     80049b <vprintfmt+0x1d7>
  8004ca:	0f be c0             	movsbl %al,%eax
  8004cd:	83 e8 20             	sub    $0x20,%eax
  8004d0:	83 f8 5e             	cmp    $0x5e,%eax
  8004d3:	76 c6                	jbe    80049b <vprintfmt+0x1d7>
					putch('?', putdat);
  8004d5:	83 ec 08             	sub    $0x8,%esp
  8004d8:	53                   	push   %ebx
  8004d9:	6a 3f                	push   $0x3f
  8004db:	ff d6                	call   *%esi
  8004dd:	83 c4 10             	add    $0x10,%esp
  8004e0:	eb c3                	jmp    8004a5 <vprintfmt+0x1e1>
  8004e2:	89 cf                	mov    %ecx,%edi
  8004e4:	eb 0e                	jmp    8004f4 <vprintfmt+0x230>
				putch(' ', putdat);
  8004e6:	83 ec 08             	sub    $0x8,%esp
  8004e9:	53                   	push   %ebx
  8004ea:	6a 20                	push   $0x20
  8004ec:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8004ee:	83 ef 01             	sub    $0x1,%edi
  8004f1:	83 c4 10             	add    $0x10,%esp
  8004f4:	85 ff                	test   %edi,%edi
  8004f6:	7f ee                	jg     8004e6 <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  8004f8:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8004fb:	89 45 14             	mov    %eax,0x14(%ebp)
  8004fe:	e9 a6 01 00 00       	jmp    8006a9 <vprintfmt+0x3e5>
  800503:	89 cf                	mov    %ecx,%edi
  800505:	eb ed                	jmp    8004f4 <vprintfmt+0x230>
	if (lflag >= 2)
  800507:	83 f9 01             	cmp    $0x1,%ecx
  80050a:	7f 1f                	jg     80052b <vprintfmt+0x267>
	else if (lflag)
  80050c:	85 c9                	test   %ecx,%ecx
  80050e:	74 67                	je     800577 <vprintfmt+0x2b3>
		return va_arg(*ap, long);
  800510:	8b 45 14             	mov    0x14(%ebp),%eax
  800513:	8b 00                	mov    (%eax),%eax
  800515:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800518:	89 c1                	mov    %eax,%ecx
  80051a:	c1 f9 1f             	sar    $0x1f,%ecx
  80051d:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800520:	8b 45 14             	mov    0x14(%ebp),%eax
  800523:	8d 40 04             	lea    0x4(%eax),%eax
  800526:	89 45 14             	mov    %eax,0x14(%ebp)
  800529:	eb 17                	jmp    800542 <vprintfmt+0x27e>
		return va_arg(*ap, long long);
  80052b:	8b 45 14             	mov    0x14(%ebp),%eax
  80052e:	8b 50 04             	mov    0x4(%eax),%edx
  800531:	8b 00                	mov    (%eax),%eax
  800533:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800536:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800539:	8b 45 14             	mov    0x14(%ebp),%eax
  80053c:	8d 40 08             	lea    0x8(%eax),%eax
  80053f:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800542:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800545:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800548:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  80054d:	85 c9                	test   %ecx,%ecx
  80054f:	0f 89 3a 01 00 00    	jns    80068f <vprintfmt+0x3cb>
				putch('-', putdat);
  800555:	83 ec 08             	sub    $0x8,%esp
  800558:	53                   	push   %ebx
  800559:	6a 2d                	push   $0x2d
  80055b:	ff d6                	call   *%esi
				num = -(long long) num;
  80055d:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800560:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800563:	f7 da                	neg    %edx
  800565:	83 d1 00             	adc    $0x0,%ecx
  800568:	f7 d9                	neg    %ecx
  80056a:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80056d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800572:	e9 18 01 00 00       	jmp    80068f <vprintfmt+0x3cb>
		return va_arg(*ap, int);
  800577:	8b 45 14             	mov    0x14(%ebp),%eax
  80057a:	8b 00                	mov    (%eax),%eax
  80057c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80057f:	89 c1                	mov    %eax,%ecx
  800581:	c1 f9 1f             	sar    $0x1f,%ecx
  800584:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800587:	8b 45 14             	mov    0x14(%ebp),%eax
  80058a:	8d 40 04             	lea    0x4(%eax),%eax
  80058d:	89 45 14             	mov    %eax,0x14(%ebp)
  800590:	eb b0                	jmp    800542 <vprintfmt+0x27e>
	if (lflag >= 2)
  800592:	83 f9 01             	cmp    $0x1,%ecx
  800595:	7f 1e                	jg     8005b5 <vprintfmt+0x2f1>
	else if (lflag)
  800597:	85 c9                	test   %ecx,%ecx
  800599:	74 32                	je     8005cd <vprintfmt+0x309>
		return va_arg(*ap, unsigned long);
  80059b:	8b 45 14             	mov    0x14(%ebp),%eax
  80059e:	8b 10                	mov    (%eax),%edx
  8005a0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005a5:	8d 40 04             	lea    0x4(%eax),%eax
  8005a8:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005ab:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  8005b0:	e9 da 00 00 00       	jmp    80068f <vprintfmt+0x3cb>
		return va_arg(*ap, unsigned long long);
  8005b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b8:	8b 10                	mov    (%eax),%edx
  8005ba:	8b 48 04             	mov    0x4(%eax),%ecx
  8005bd:	8d 40 08             	lea    0x8(%eax),%eax
  8005c0:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005c3:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  8005c8:	e9 c2 00 00 00       	jmp    80068f <vprintfmt+0x3cb>
		return va_arg(*ap, unsigned int);
  8005cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d0:	8b 10                	mov    (%eax),%edx
  8005d2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005d7:	8d 40 04             	lea    0x4(%eax),%eax
  8005da:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005dd:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  8005e2:	e9 a8 00 00 00       	jmp    80068f <vprintfmt+0x3cb>
	if (lflag >= 2)
  8005e7:	83 f9 01             	cmp    $0x1,%ecx
  8005ea:	7f 1b                	jg     800607 <vprintfmt+0x343>
	else if (lflag)
  8005ec:	85 c9                	test   %ecx,%ecx
  8005ee:	74 5c                	je     80064c <vprintfmt+0x388>
		return va_arg(*ap, long);
  8005f0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f3:	8b 00                	mov    (%eax),%eax
  8005f5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005f8:	99                   	cltd   
  8005f9:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005fc:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ff:	8d 40 04             	lea    0x4(%eax),%eax
  800602:	89 45 14             	mov    %eax,0x14(%ebp)
  800605:	eb 17                	jmp    80061e <vprintfmt+0x35a>
		return va_arg(*ap, long long);
  800607:	8b 45 14             	mov    0x14(%ebp),%eax
  80060a:	8b 50 04             	mov    0x4(%eax),%edx
  80060d:	8b 00                	mov    (%eax),%eax
  80060f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800612:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800615:	8b 45 14             	mov    0x14(%ebp),%eax
  800618:	8d 40 08             	lea    0x8(%eax),%eax
  80061b:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80061e:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800621:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 8;
  800624:	b8 08 00 00 00       	mov    $0x8,%eax
			if ((long long) num < 0) {
  800629:	85 c9                	test   %ecx,%ecx
  80062b:	79 62                	jns    80068f <vprintfmt+0x3cb>
				putch('-', putdat);
  80062d:	83 ec 08             	sub    $0x8,%esp
  800630:	53                   	push   %ebx
  800631:	6a 2d                	push   $0x2d
  800633:	ff d6                	call   *%esi
				num = -(long long) num;
  800635:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800638:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80063b:	f7 da                	neg    %edx
  80063d:	83 d1 00             	adc    $0x0,%ecx
  800640:	f7 d9                	neg    %ecx
  800642:	83 c4 10             	add    $0x10,%esp
			base = 8;
  800645:	b8 08 00 00 00       	mov    $0x8,%eax
  80064a:	eb 43                	jmp    80068f <vprintfmt+0x3cb>
		return va_arg(*ap, int);
  80064c:	8b 45 14             	mov    0x14(%ebp),%eax
  80064f:	8b 00                	mov    (%eax),%eax
  800651:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800654:	89 c1                	mov    %eax,%ecx
  800656:	c1 f9 1f             	sar    $0x1f,%ecx
  800659:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80065c:	8b 45 14             	mov    0x14(%ebp),%eax
  80065f:	8d 40 04             	lea    0x4(%eax),%eax
  800662:	89 45 14             	mov    %eax,0x14(%ebp)
  800665:	eb b7                	jmp    80061e <vprintfmt+0x35a>
			putch('0', putdat);
  800667:	83 ec 08             	sub    $0x8,%esp
  80066a:	53                   	push   %ebx
  80066b:	6a 30                	push   $0x30
  80066d:	ff d6                	call   *%esi
			putch('x', putdat);
  80066f:	83 c4 08             	add    $0x8,%esp
  800672:	53                   	push   %ebx
  800673:	6a 78                	push   $0x78
  800675:	ff d6                	call   *%esi
			num = (unsigned long long)
  800677:	8b 45 14             	mov    0x14(%ebp),%eax
  80067a:	8b 10                	mov    (%eax),%edx
  80067c:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800681:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800684:	8d 40 04             	lea    0x4(%eax),%eax
  800687:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80068a:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  80068f:	83 ec 0c             	sub    $0xc,%esp
  800692:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  800696:	57                   	push   %edi
  800697:	ff 75 e0             	pushl  -0x20(%ebp)
  80069a:	50                   	push   %eax
  80069b:	51                   	push   %ecx
  80069c:	52                   	push   %edx
  80069d:	89 da                	mov    %ebx,%edx
  80069f:	89 f0                	mov    %esi,%eax
  8006a1:	e8 33 fb ff ff       	call   8001d9 <printnum>
			break;
  8006a6:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  8006a9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006ac:	83 c7 01             	add    $0x1,%edi
  8006af:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8006b3:	83 f8 25             	cmp    $0x25,%eax
  8006b6:	0f 84 23 fc ff ff    	je     8002df <vprintfmt+0x1b>
			if (ch == '\0')
  8006bc:	85 c0                	test   %eax,%eax
  8006be:	0f 84 8b 00 00 00    	je     80074f <vprintfmt+0x48b>
			putch(ch, putdat);
  8006c4:	83 ec 08             	sub    $0x8,%esp
  8006c7:	53                   	push   %ebx
  8006c8:	50                   	push   %eax
  8006c9:	ff d6                	call   *%esi
  8006cb:	83 c4 10             	add    $0x10,%esp
  8006ce:	eb dc                	jmp    8006ac <vprintfmt+0x3e8>
	if (lflag >= 2)
  8006d0:	83 f9 01             	cmp    $0x1,%ecx
  8006d3:	7f 1b                	jg     8006f0 <vprintfmt+0x42c>
	else if (lflag)
  8006d5:	85 c9                	test   %ecx,%ecx
  8006d7:	74 2c                	je     800705 <vprintfmt+0x441>
		return va_arg(*ap, unsigned long);
  8006d9:	8b 45 14             	mov    0x14(%ebp),%eax
  8006dc:	8b 10                	mov    (%eax),%edx
  8006de:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006e3:	8d 40 04             	lea    0x4(%eax),%eax
  8006e6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006e9:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  8006ee:	eb 9f                	jmp    80068f <vprintfmt+0x3cb>
		return va_arg(*ap, unsigned long long);
  8006f0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f3:	8b 10                	mov    (%eax),%edx
  8006f5:	8b 48 04             	mov    0x4(%eax),%ecx
  8006f8:	8d 40 08             	lea    0x8(%eax),%eax
  8006fb:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006fe:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  800703:	eb 8a                	jmp    80068f <vprintfmt+0x3cb>
		return va_arg(*ap, unsigned int);
  800705:	8b 45 14             	mov    0x14(%ebp),%eax
  800708:	8b 10                	mov    (%eax),%edx
  80070a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80070f:	8d 40 04             	lea    0x4(%eax),%eax
  800712:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800715:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  80071a:	e9 70 ff ff ff       	jmp    80068f <vprintfmt+0x3cb>
			putch(ch, putdat);
  80071f:	83 ec 08             	sub    $0x8,%esp
  800722:	53                   	push   %ebx
  800723:	6a 25                	push   $0x25
  800725:	ff d6                	call   *%esi
			break;
  800727:	83 c4 10             	add    $0x10,%esp
  80072a:	e9 7a ff ff ff       	jmp    8006a9 <vprintfmt+0x3e5>
			putch('%', putdat);
  80072f:	83 ec 08             	sub    $0x8,%esp
  800732:	53                   	push   %ebx
  800733:	6a 25                	push   $0x25
  800735:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800737:	83 c4 10             	add    $0x10,%esp
  80073a:	89 f8                	mov    %edi,%eax
  80073c:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800740:	74 05                	je     800747 <vprintfmt+0x483>
  800742:	83 e8 01             	sub    $0x1,%eax
  800745:	eb f5                	jmp    80073c <vprintfmt+0x478>
  800747:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80074a:	e9 5a ff ff ff       	jmp    8006a9 <vprintfmt+0x3e5>
}
  80074f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800752:	5b                   	pop    %ebx
  800753:	5e                   	pop    %esi
  800754:	5f                   	pop    %edi
  800755:	5d                   	pop    %ebp
  800756:	c3                   	ret    

00800757 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800757:	f3 0f 1e fb          	endbr32 
  80075b:	55                   	push   %ebp
  80075c:	89 e5                	mov    %esp,%ebp
  80075e:	83 ec 18             	sub    $0x18,%esp
  800761:	8b 45 08             	mov    0x8(%ebp),%eax
  800764:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800767:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80076a:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80076e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800771:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800778:	85 c0                	test   %eax,%eax
  80077a:	74 26                	je     8007a2 <vsnprintf+0x4b>
  80077c:	85 d2                	test   %edx,%edx
  80077e:	7e 22                	jle    8007a2 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800780:	ff 75 14             	pushl  0x14(%ebp)
  800783:	ff 75 10             	pushl  0x10(%ebp)
  800786:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800789:	50                   	push   %eax
  80078a:	68 82 02 80 00       	push   $0x800282
  80078f:	e8 30 fb ff ff       	call   8002c4 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800794:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800797:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80079a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80079d:	83 c4 10             	add    $0x10,%esp
}
  8007a0:	c9                   	leave  
  8007a1:	c3                   	ret    
		return -E_INVAL;
  8007a2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007a7:	eb f7                	jmp    8007a0 <vsnprintf+0x49>

008007a9 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007a9:	f3 0f 1e fb          	endbr32 
  8007ad:	55                   	push   %ebp
  8007ae:	89 e5                	mov    %esp,%ebp
  8007b0:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007b3:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007b6:	50                   	push   %eax
  8007b7:	ff 75 10             	pushl  0x10(%ebp)
  8007ba:	ff 75 0c             	pushl  0xc(%ebp)
  8007bd:	ff 75 08             	pushl  0x8(%ebp)
  8007c0:	e8 92 ff ff ff       	call   800757 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007c5:	c9                   	leave  
  8007c6:	c3                   	ret    

008007c7 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007c7:	f3 0f 1e fb          	endbr32 
  8007cb:	55                   	push   %ebp
  8007cc:	89 e5                	mov    %esp,%ebp
  8007ce:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007d1:	b8 00 00 00 00       	mov    $0x0,%eax
  8007d6:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007da:	74 05                	je     8007e1 <strlen+0x1a>
		n++;
  8007dc:	83 c0 01             	add    $0x1,%eax
  8007df:	eb f5                	jmp    8007d6 <strlen+0xf>
	return n;
}
  8007e1:	5d                   	pop    %ebp
  8007e2:	c3                   	ret    

008007e3 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007e3:	f3 0f 1e fb          	endbr32 
  8007e7:	55                   	push   %ebp
  8007e8:	89 e5                	mov    %esp,%ebp
  8007ea:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007ed:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007f0:	b8 00 00 00 00       	mov    $0x0,%eax
  8007f5:	39 d0                	cmp    %edx,%eax
  8007f7:	74 0d                	je     800806 <strnlen+0x23>
  8007f9:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007fd:	74 05                	je     800804 <strnlen+0x21>
		n++;
  8007ff:	83 c0 01             	add    $0x1,%eax
  800802:	eb f1                	jmp    8007f5 <strnlen+0x12>
  800804:	89 c2                	mov    %eax,%edx
	return n;
}
  800806:	89 d0                	mov    %edx,%eax
  800808:	5d                   	pop    %ebp
  800809:	c3                   	ret    

0080080a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80080a:	f3 0f 1e fb          	endbr32 
  80080e:	55                   	push   %ebp
  80080f:	89 e5                	mov    %esp,%ebp
  800811:	53                   	push   %ebx
  800812:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800815:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800818:	b8 00 00 00 00       	mov    $0x0,%eax
  80081d:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800821:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800824:	83 c0 01             	add    $0x1,%eax
  800827:	84 d2                	test   %dl,%dl
  800829:	75 f2                	jne    80081d <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  80082b:	89 c8                	mov    %ecx,%eax
  80082d:	5b                   	pop    %ebx
  80082e:	5d                   	pop    %ebp
  80082f:	c3                   	ret    

00800830 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800830:	f3 0f 1e fb          	endbr32 
  800834:	55                   	push   %ebp
  800835:	89 e5                	mov    %esp,%ebp
  800837:	53                   	push   %ebx
  800838:	83 ec 10             	sub    $0x10,%esp
  80083b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80083e:	53                   	push   %ebx
  80083f:	e8 83 ff ff ff       	call   8007c7 <strlen>
  800844:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800847:	ff 75 0c             	pushl  0xc(%ebp)
  80084a:	01 d8                	add    %ebx,%eax
  80084c:	50                   	push   %eax
  80084d:	e8 b8 ff ff ff       	call   80080a <strcpy>
	return dst;
}
  800852:	89 d8                	mov    %ebx,%eax
  800854:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800857:	c9                   	leave  
  800858:	c3                   	ret    

00800859 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800859:	f3 0f 1e fb          	endbr32 
  80085d:	55                   	push   %ebp
  80085e:	89 e5                	mov    %esp,%ebp
  800860:	56                   	push   %esi
  800861:	53                   	push   %ebx
  800862:	8b 75 08             	mov    0x8(%ebp),%esi
  800865:	8b 55 0c             	mov    0xc(%ebp),%edx
  800868:	89 f3                	mov    %esi,%ebx
  80086a:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80086d:	89 f0                	mov    %esi,%eax
  80086f:	39 d8                	cmp    %ebx,%eax
  800871:	74 11                	je     800884 <strncpy+0x2b>
		*dst++ = *src;
  800873:	83 c0 01             	add    $0x1,%eax
  800876:	0f b6 0a             	movzbl (%edx),%ecx
  800879:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80087c:	80 f9 01             	cmp    $0x1,%cl
  80087f:	83 da ff             	sbb    $0xffffffff,%edx
  800882:	eb eb                	jmp    80086f <strncpy+0x16>
	}
	return ret;
}
  800884:	89 f0                	mov    %esi,%eax
  800886:	5b                   	pop    %ebx
  800887:	5e                   	pop    %esi
  800888:	5d                   	pop    %ebp
  800889:	c3                   	ret    

0080088a <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80088a:	f3 0f 1e fb          	endbr32 
  80088e:	55                   	push   %ebp
  80088f:	89 e5                	mov    %esp,%ebp
  800891:	56                   	push   %esi
  800892:	53                   	push   %ebx
  800893:	8b 75 08             	mov    0x8(%ebp),%esi
  800896:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800899:	8b 55 10             	mov    0x10(%ebp),%edx
  80089c:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80089e:	85 d2                	test   %edx,%edx
  8008a0:	74 21                	je     8008c3 <strlcpy+0x39>
  8008a2:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8008a6:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  8008a8:	39 c2                	cmp    %eax,%edx
  8008aa:	74 14                	je     8008c0 <strlcpy+0x36>
  8008ac:	0f b6 19             	movzbl (%ecx),%ebx
  8008af:	84 db                	test   %bl,%bl
  8008b1:	74 0b                	je     8008be <strlcpy+0x34>
			*dst++ = *src++;
  8008b3:	83 c1 01             	add    $0x1,%ecx
  8008b6:	83 c2 01             	add    $0x1,%edx
  8008b9:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008bc:	eb ea                	jmp    8008a8 <strlcpy+0x1e>
  8008be:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  8008c0:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008c3:	29 f0                	sub    %esi,%eax
}
  8008c5:	5b                   	pop    %ebx
  8008c6:	5e                   	pop    %esi
  8008c7:	5d                   	pop    %ebp
  8008c8:	c3                   	ret    

008008c9 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008c9:	f3 0f 1e fb          	endbr32 
  8008cd:	55                   	push   %ebp
  8008ce:	89 e5                	mov    %esp,%ebp
  8008d0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008d3:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008d6:	0f b6 01             	movzbl (%ecx),%eax
  8008d9:	84 c0                	test   %al,%al
  8008db:	74 0c                	je     8008e9 <strcmp+0x20>
  8008dd:	3a 02                	cmp    (%edx),%al
  8008df:	75 08                	jne    8008e9 <strcmp+0x20>
		p++, q++;
  8008e1:	83 c1 01             	add    $0x1,%ecx
  8008e4:	83 c2 01             	add    $0x1,%edx
  8008e7:	eb ed                	jmp    8008d6 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008e9:	0f b6 c0             	movzbl %al,%eax
  8008ec:	0f b6 12             	movzbl (%edx),%edx
  8008ef:	29 d0                	sub    %edx,%eax
}
  8008f1:	5d                   	pop    %ebp
  8008f2:	c3                   	ret    

008008f3 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008f3:	f3 0f 1e fb          	endbr32 
  8008f7:	55                   	push   %ebp
  8008f8:	89 e5                	mov    %esp,%ebp
  8008fa:	53                   	push   %ebx
  8008fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8008fe:	8b 55 0c             	mov    0xc(%ebp),%edx
  800901:	89 c3                	mov    %eax,%ebx
  800903:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800906:	eb 06                	jmp    80090e <strncmp+0x1b>
		n--, p++, q++;
  800908:	83 c0 01             	add    $0x1,%eax
  80090b:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  80090e:	39 d8                	cmp    %ebx,%eax
  800910:	74 16                	je     800928 <strncmp+0x35>
  800912:	0f b6 08             	movzbl (%eax),%ecx
  800915:	84 c9                	test   %cl,%cl
  800917:	74 04                	je     80091d <strncmp+0x2a>
  800919:	3a 0a                	cmp    (%edx),%cl
  80091b:	74 eb                	je     800908 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80091d:	0f b6 00             	movzbl (%eax),%eax
  800920:	0f b6 12             	movzbl (%edx),%edx
  800923:	29 d0                	sub    %edx,%eax
}
  800925:	5b                   	pop    %ebx
  800926:	5d                   	pop    %ebp
  800927:	c3                   	ret    
		return 0;
  800928:	b8 00 00 00 00       	mov    $0x0,%eax
  80092d:	eb f6                	jmp    800925 <strncmp+0x32>

0080092f <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80092f:	f3 0f 1e fb          	endbr32 
  800933:	55                   	push   %ebp
  800934:	89 e5                	mov    %esp,%ebp
  800936:	8b 45 08             	mov    0x8(%ebp),%eax
  800939:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80093d:	0f b6 10             	movzbl (%eax),%edx
  800940:	84 d2                	test   %dl,%dl
  800942:	74 09                	je     80094d <strchr+0x1e>
		if (*s == c)
  800944:	38 ca                	cmp    %cl,%dl
  800946:	74 0a                	je     800952 <strchr+0x23>
	for (; *s; s++)
  800948:	83 c0 01             	add    $0x1,%eax
  80094b:	eb f0                	jmp    80093d <strchr+0xe>
			return (char *) s;
	return 0;
  80094d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800952:	5d                   	pop    %ebp
  800953:	c3                   	ret    

00800954 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800954:	f3 0f 1e fb          	endbr32 
  800958:	55                   	push   %ebp
  800959:	89 e5                	mov    %esp,%ebp
  80095b:	8b 45 08             	mov    0x8(%ebp),%eax
  80095e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800962:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800965:	38 ca                	cmp    %cl,%dl
  800967:	74 09                	je     800972 <strfind+0x1e>
  800969:	84 d2                	test   %dl,%dl
  80096b:	74 05                	je     800972 <strfind+0x1e>
	for (; *s; s++)
  80096d:	83 c0 01             	add    $0x1,%eax
  800970:	eb f0                	jmp    800962 <strfind+0xe>
			break;
	return (char *) s;
}
  800972:	5d                   	pop    %ebp
  800973:	c3                   	ret    

00800974 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800974:	f3 0f 1e fb          	endbr32 
  800978:	55                   	push   %ebp
  800979:	89 e5                	mov    %esp,%ebp
  80097b:	57                   	push   %edi
  80097c:	56                   	push   %esi
  80097d:	53                   	push   %ebx
  80097e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800981:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800984:	85 c9                	test   %ecx,%ecx
  800986:	74 31                	je     8009b9 <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800988:	89 f8                	mov    %edi,%eax
  80098a:	09 c8                	or     %ecx,%eax
  80098c:	a8 03                	test   $0x3,%al
  80098e:	75 23                	jne    8009b3 <memset+0x3f>
		c &= 0xFF;
  800990:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800994:	89 d3                	mov    %edx,%ebx
  800996:	c1 e3 08             	shl    $0x8,%ebx
  800999:	89 d0                	mov    %edx,%eax
  80099b:	c1 e0 18             	shl    $0x18,%eax
  80099e:	89 d6                	mov    %edx,%esi
  8009a0:	c1 e6 10             	shl    $0x10,%esi
  8009a3:	09 f0                	or     %esi,%eax
  8009a5:	09 c2                	or     %eax,%edx
  8009a7:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8009a9:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  8009ac:	89 d0                	mov    %edx,%eax
  8009ae:	fc                   	cld    
  8009af:	f3 ab                	rep stos %eax,%es:(%edi)
  8009b1:	eb 06                	jmp    8009b9 <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009b3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009b6:	fc                   	cld    
  8009b7:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009b9:	89 f8                	mov    %edi,%eax
  8009bb:	5b                   	pop    %ebx
  8009bc:	5e                   	pop    %esi
  8009bd:	5f                   	pop    %edi
  8009be:	5d                   	pop    %ebp
  8009bf:	c3                   	ret    

008009c0 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009c0:	f3 0f 1e fb          	endbr32 
  8009c4:	55                   	push   %ebp
  8009c5:	89 e5                	mov    %esp,%ebp
  8009c7:	57                   	push   %edi
  8009c8:	56                   	push   %esi
  8009c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8009cc:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009cf:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009d2:	39 c6                	cmp    %eax,%esi
  8009d4:	73 32                	jae    800a08 <memmove+0x48>
  8009d6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009d9:	39 c2                	cmp    %eax,%edx
  8009db:	76 2b                	jbe    800a08 <memmove+0x48>
		s += n;
		d += n;
  8009dd:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009e0:	89 fe                	mov    %edi,%esi
  8009e2:	09 ce                	or     %ecx,%esi
  8009e4:	09 d6                	or     %edx,%esi
  8009e6:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009ec:	75 0e                	jne    8009fc <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009ee:	83 ef 04             	sub    $0x4,%edi
  8009f1:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009f4:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8009f7:	fd                   	std    
  8009f8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009fa:	eb 09                	jmp    800a05 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009fc:	83 ef 01             	sub    $0x1,%edi
  8009ff:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800a02:	fd                   	std    
  800a03:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a05:	fc                   	cld    
  800a06:	eb 1a                	jmp    800a22 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a08:	89 c2                	mov    %eax,%edx
  800a0a:	09 ca                	or     %ecx,%edx
  800a0c:	09 f2                	or     %esi,%edx
  800a0e:	f6 c2 03             	test   $0x3,%dl
  800a11:	75 0a                	jne    800a1d <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a13:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800a16:	89 c7                	mov    %eax,%edi
  800a18:	fc                   	cld    
  800a19:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a1b:	eb 05                	jmp    800a22 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800a1d:	89 c7                	mov    %eax,%edi
  800a1f:	fc                   	cld    
  800a20:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a22:	5e                   	pop    %esi
  800a23:	5f                   	pop    %edi
  800a24:	5d                   	pop    %ebp
  800a25:	c3                   	ret    

00800a26 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a26:	f3 0f 1e fb          	endbr32 
  800a2a:	55                   	push   %ebp
  800a2b:	89 e5                	mov    %esp,%ebp
  800a2d:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a30:	ff 75 10             	pushl  0x10(%ebp)
  800a33:	ff 75 0c             	pushl  0xc(%ebp)
  800a36:	ff 75 08             	pushl  0x8(%ebp)
  800a39:	e8 82 ff ff ff       	call   8009c0 <memmove>
}
  800a3e:	c9                   	leave  
  800a3f:	c3                   	ret    

00800a40 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a40:	f3 0f 1e fb          	endbr32 
  800a44:	55                   	push   %ebp
  800a45:	89 e5                	mov    %esp,%ebp
  800a47:	56                   	push   %esi
  800a48:	53                   	push   %ebx
  800a49:	8b 45 08             	mov    0x8(%ebp),%eax
  800a4c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a4f:	89 c6                	mov    %eax,%esi
  800a51:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a54:	39 f0                	cmp    %esi,%eax
  800a56:	74 1c                	je     800a74 <memcmp+0x34>
		if (*s1 != *s2)
  800a58:	0f b6 08             	movzbl (%eax),%ecx
  800a5b:	0f b6 1a             	movzbl (%edx),%ebx
  800a5e:	38 d9                	cmp    %bl,%cl
  800a60:	75 08                	jne    800a6a <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800a62:	83 c0 01             	add    $0x1,%eax
  800a65:	83 c2 01             	add    $0x1,%edx
  800a68:	eb ea                	jmp    800a54 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800a6a:	0f b6 c1             	movzbl %cl,%eax
  800a6d:	0f b6 db             	movzbl %bl,%ebx
  800a70:	29 d8                	sub    %ebx,%eax
  800a72:	eb 05                	jmp    800a79 <memcmp+0x39>
	}

	return 0;
  800a74:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a79:	5b                   	pop    %ebx
  800a7a:	5e                   	pop    %esi
  800a7b:	5d                   	pop    %ebp
  800a7c:	c3                   	ret    

00800a7d <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a7d:	f3 0f 1e fb          	endbr32 
  800a81:	55                   	push   %ebp
  800a82:	89 e5                	mov    %esp,%ebp
  800a84:	8b 45 08             	mov    0x8(%ebp),%eax
  800a87:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a8a:	89 c2                	mov    %eax,%edx
  800a8c:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a8f:	39 d0                	cmp    %edx,%eax
  800a91:	73 09                	jae    800a9c <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a93:	38 08                	cmp    %cl,(%eax)
  800a95:	74 05                	je     800a9c <memfind+0x1f>
	for (; s < ends; s++)
  800a97:	83 c0 01             	add    $0x1,%eax
  800a9a:	eb f3                	jmp    800a8f <memfind+0x12>
			break;
	return (void *) s;
}
  800a9c:	5d                   	pop    %ebp
  800a9d:	c3                   	ret    

00800a9e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a9e:	f3 0f 1e fb          	endbr32 
  800aa2:	55                   	push   %ebp
  800aa3:	89 e5                	mov    %esp,%ebp
  800aa5:	57                   	push   %edi
  800aa6:	56                   	push   %esi
  800aa7:	53                   	push   %ebx
  800aa8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800aab:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800aae:	eb 03                	jmp    800ab3 <strtol+0x15>
		s++;
  800ab0:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800ab3:	0f b6 01             	movzbl (%ecx),%eax
  800ab6:	3c 20                	cmp    $0x20,%al
  800ab8:	74 f6                	je     800ab0 <strtol+0x12>
  800aba:	3c 09                	cmp    $0x9,%al
  800abc:	74 f2                	je     800ab0 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800abe:	3c 2b                	cmp    $0x2b,%al
  800ac0:	74 2a                	je     800aec <strtol+0x4e>
	int neg = 0;
  800ac2:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800ac7:	3c 2d                	cmp    $0x2d,%al
  800ac9:	74 2b                	je     800af6 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800acb:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800ad1:	75 0f                	jne    800ae2 <strtol+0x44>
  800ad3:	80 39 30             	cmpb   $0x30,(%ecx)
  800ad6:	74 28                	je     800b00 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800ad8:	85 db                	test   %ebx,%ebx
  800ada:	b8 0a 00 00 00       	mov    $0xa,%eax
  800adf:	0f 44 d8             	cmove  %eax,%ebx
  800ae2:	b8 00 00 00 00       	mov    $0x0,%eax
  800ae7:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800aea:	eb 46                	jmp    800b32 <strtol+0x94>
		s++;
  800aec:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800aef:	bf 00 00 00 00       	mov    $0x0,%edi
  800af4:	eb d5                	jmp    800acb <strtol+0x2d>
		s++, neg = 1;
  800af6:	83 c1 01             	add    $0x1,%ecx
  800af9:	bf 01 00 00 00       	mov    $0x1,%edi
  800afe:	eb cb                	jmp    800acb <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b00:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b04:	74 0e                	je     800b14 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800b06:	85 db                	test   %ebx,%ebx
  800b08:	75 d8                	jne    800ae2 <strtol+0x44>
		s++, base = 8;
  800b0a:	83 c1 01             	add    $0x1,%ecx
  800b0d:	bb 08 00 00 00       	mov    $0x8,%ebx
  800b12:	eb ce                	jmp    800ae2 <strtol+0x44>
		s += 2, base = 16;
  800b14:	83 c1 02             	add    $0x2,%ecx
  800b17:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b1c:	eb c4                	jmp    800ae2 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800b1e:	0f be d2             	movsbl %dl,%edx
  800b21:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b24:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b27:	7d 3a                	jge    800b63 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800b29:	83 c1 01             	add    $0x1,%ecx
  800b2c:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b30:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800b32:	0f b6 11             	movzbl (%ecx),%edx
  800b35:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b38:	89 f3                	mov    %esi,%ebx
  800b3a:	80 fb 09             	cmp    $0x9,%bl
  800b3d:	76 df                	jbe    800b1e <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800b3f:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b42:	89 f3                	mov    %esi,%ebx
  800b44:	80 fb 19             	cmp    $0x19,%bl
  800b47:	77 08                	ja     800b51 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800b49:	0f be d2             	movsbl %dl,%edx
  800b4c:	83 ea 57             	sub    $0x57,%edx
  800b4f:	eb d3                	jmp    800b24 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800b51:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b54:	89 f3                	mov    %esi,%ebx
  800b56:	80 fb 19             	cmp    $0x19,%bl
  800b59:	77 08                	ja     800b63 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800b5b:	0f be d2             	movsbl %dl,%edx
  800b5e:	83 ea 37             	sub    $0x37,%edx
  800b61:	eb c1                	jmp    800b24 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800b63:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b67:	74 05                	je     800b6e <strtol+0xd0>
		*endptr = (char *) s;
  800b69:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b6c:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800b6e:	89 c2                	mov    %eax,%edx
  800b70:	f7 da                	neg    %edx
  800b72:	85 ff                	test   %edi,%edi
  800b74:	0f 45 c2             	cmovne %edx,%eax
}
  800b77:	5b                   	pop    %ebx
  800b78:	5e                   	pop    %esi
  800b79:	5f                   	pop    %edi
  800b7a:	5d                   	pop    %ebp
  800b7b:	c3                   	ret    

00800b7c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b7c:	f3 0f 1e fb          	endbr32 
  800b80:	55                   	push   %ebp
  800b81:	89 e5                	mov    %esp,%ebp
  800b83:	57                   	push   %edi
  800b84:	56                   	push   %esi
  800b85:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b86:	b8 00 00 00 00       	mov    $0x0,%eax
  800b8b:	8b 55 08             	mov    0x8(%ebp),%edx
  800b8e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b91:	89 c3                	mov    %eax,%ebx
  800b93:	89 c7                	mov    %eax,%edi
  800b95:	89 c6                	mov    %eax,%esi
  800b97:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b99:	5b                   	pop    %ebx
  800b9a:	5e                   	pop    %esi
  800b9b:	5f                   	pop    %edi
  800b9c:	5d                   	pop    %ebp
  800b9d:	c3                   	ret    

00800b9e <sys_cgetc>:

int
sys_cgetc(void)
{
  800b9e:	f3 0f 1e fb          	endbr32 
  800ba2:	55                   	push   %ebp
  800ba3:	89 e5                	mov    %esp,%ebp
  800ba5:	57                   	push   %edi
  800ba6:	56                   	push   %esi
  800ba7:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ba8:	ba 00 00 00 00       	mov    $0x0,%edx
  800bad:	b8 01 00 00 00       	mov    $0x1,%eax
  800bb2:	89 d1                	mov    %edx,%ecx
  800bb4:	89 d3                	mov    %edx,%ebx
  800bb6:	89 d7                	mov    %edx,%edi
  800bb8:	89 d6                	mov    %edx,%esi
  800bba:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bbc:	5b                   	pop    %ebx
  800bbd:	5e                   	pop    %esi
  800bbe:	5f                   	pop    %edi
  800bbf:	5d                   	pop    %ebp
  800bc0:	c3                   	ret    

00800bc1 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bc1:	f3 0f 1e fb          	endbr32 
  800bc5:	55                   	push   %ebp
  800bc6:	89 e5                	mov    %esp,%ebp
  800bc8:	57                   	push   %edi
  800bc9:	56                   	push   %esi
  800bca:	53                   	push   %ebx
  800bcb:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800bce:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bd3:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd6:	b8 03 00 00 00       	mov    $0x3,%eax
  800bdb:	89 cb                	mov    %ecx,%ebx
  800bdd:	89 cf                	mov    %ecx,%edi
  800bdf:	89 ce                	mov    %ecx,%esi
  800be1:	cd 30                	int    $0x30
	if(check && ret > 0)
  800be3:	85 c0                	test   %eax,%eax
  800be5:	7f 08                	jg     800bef <sys_env_destroy+0x2e>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800be7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bea:	5b                   	pop    %ebx
  800beb:	5e                   	pop    %esi
  800bec:	5f                   	pop    %edi
  800bed:	5d                   	pop    %ebp
  800bee:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800bef:	83 ec 0c             	sub    $0xc,%esp
  800bf2:	50                   	push   %eax
  800bf3:	6a 03                	push   $0x3
  800bf5:	68 e4 17 80 00       	push   $0x8017e4
  800bfa:	6a 23                	push   $0x23
  800bfc:	68 01 18 80 00       	push   $0x801801
  800c01:	e8 0f 06 00 00       	call   801215 <_panic>

00800c06 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c06:	f3 0f 1e fb          	endbr32 
  800c0a:	55                   	push   %ebp
  800c0b:	89 e5                	mov    %esp,%ebp
  800c0d:	57                   	push   %edi
  800c0e:	56                   	push   %esi
  800c0f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c10:	ba 00 00 00 00       	mov    $0x0,%edx
  800c15:	b8 02 00 00 00       	mov    $0x2,%eax
  800c1a:	89 d1                	mov    %edx,%ecx
  800c1c:	89 d3                	mov    %edx,%ebx
  800c1e:	89 d7                	mov    %edx,%edi
  800c20:	89 d6                	mov    %edx,%esi
  800c22:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c24:	5b                   	pop    %ebx
  800c25:	5e                   	pop    %esi
  800c26:	5f                   	pop    %edi
  800c27:	5d                   	pop    %ebp
  800c28:	c3                   	ret    

00800c29 <sys_yield>:

void
sys_yield(void)
{
  800c29:	f3 0f 1e fb          	endbr32 
  800c2d:	55                   	push   %ebp
  800c2e:	89 e5                	mov    %esp,%ebp
  800c30:	57                   	push   %edi
  800c31:	56                   	push   %esi
  800c32:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c33:	ba 00 00 00 00       	mov    $0x0,%edx
  800c38:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c3d:	89 d1                	mov    %edx,%ecx
  800c3f:	89 d3                	mov    %edx,%ebx
  800c41:	89 d7                	mov    %edx,%edi
  800c43:	89 d6                	mov    %edx,%esi
  800c45:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c47:	5b                   	pop    %ebx
  800c48:	5e                   	pop    %esi
  800c49:	5f                   	pop    %edi
  800c4a:	5d                   	pop    %ebp
  800c4b:	c3                   	ret    

00800c4c <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c4c:	f3 0f 1e fb          	endbr32 
  800c50:	55                   	push   %ebp
  800c51:	89 e5                	mov    %esp,%ebp
  800c53:	57                   	push   %edi
  800c54:	56                   	push   %esi
  800c55:	53                   	push   %ebx
  800c56:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c59:	be 00 00 00 00       	mov    $0x0,%esi
  800c5e:	8b 55 08             	mov    0x8(%ebp),%edx
  800c61:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c64:	b8 04 00 00 00       	mov    $0x4,%eax
  800c69:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c6c:	89 f7                	mov    %esi,%edi
  800c6e:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c70:	85 c0                	test   %eax,%eax
  800c72:	7f 08                	jg     800c7c <sys_page_alloc+0x30>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c74:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c77:	5b                   	pop    %ebx
  800c78:	5e                   	pop    %esi
  800c79:	5f                   	pop    %edi
  800c7a:	5d                   	pop    %ebp
  800c7b:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c7c:	83 ec 0c             	sub    $0xc,%esp
  800c7f:	50                   	push   %eax
  800c80:	6a 04                	push   $0x4
  800c82:	68 e4 17 80 00       	push   $0x8017e4
  800c87:	6a 23                	push   $0x23
  800c89:	68 01 18 80 00       	push   $0x801801
  800c8e:	e8 82 05 00 00       	call   801215 <_panic>

00800c93 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c93:	f3 0f 1e fb          	endbr32 
  800c97:	55                   	push   %ebp
  800c98:	89 e5                	mov    %esp,%ebp
  800c9a:	57                   	push   %edi
  800c9b:	56                   	push   %esi
  800c9c:	53                   	push   %ebx
  800c9d:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800ca0:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca6:	b8 05 00 00 00       	mov    $0x5,%eax
  800cab:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cae:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cb1:	8b 75 18             	mov    0x18(%ebp),%esi
  800cb4:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cb6:	85 c0                	test   %eax,%eax
  800cb8:	7f 08                	jg     800cc2 <sys_page_map+0x2f>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800cba:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cbd:	5b                   	pop    %ebx
  800cbe:	5e                   	pop    %esi
  800cbf:	5f                   	pop    %edi
  800cc0:	5d                   	pop    %ebp
  800cc1:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc2:	83 ec 0c             	sub    $0xc,%esp
  800cc5:	50                   	push   %eax
  800cc6:	6a 05                	push   $0x5
  800cc8:	68 e4 17 80 00       	push   $0x8017e4
  800ccd:	6a 23                	push   $0x23
  800ccf:	68 01 18 80 00       	push   $0x801801
  800cd4:	e8 3c 05 00 00       	call   801215 <_panic>

00800cd9 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800cd9:	f3 0f 1e fb          	endbr32 
  800cdd:	55                   	push   %ebp
  800cde:	89 e5                	mov    %esp,%ebp
  800ce0:	57                   	push   %edi
  800ce1:	56                   	push   %esi
  800ce2:	53                   	push   %ebx
  800ce3:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800ce6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ceb:	8b 55 08             	mov    0x8(%ebp),%edx
  800cee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf1:	b8 06 00 00 00       	mov    $0x6,%eax
  800cf6:	89 df                	mov    %ebx,%edi
  800cf8:	89 de                	mov    %ebx,%esi
  800cfa:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cfc:	85 c0                	test   %eax,%eax
  800cfe:	7f 08                	jg     800d08 <sys_page_unmap+0x2f>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d00:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d03:	5b                   	pop    %ebx
  800d04:	5e                   	pop    %esi
  800d05:	5f                   	pop    %edi
  800d06:	5d                   	pop    %ebp
  800d07:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d08:	83 ec 0c             	sub    $0xc,%esp
  800d0b:	50                   	push   %eax
  800d0c:	6a 06                	push   $0x6
  800d0e:	68 e4 17 80 00       	push   $0x8017e4
  800d13:	6a 23                	push   $0x23
  800d15:	68 01 18 80 00       	push   $0x801801
  800d1a:	e8 f6 04 00 00       	call   801215 <_panic>

00800d1f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d1f:	f3 0f 1e fb          	endbr32 
  800d23:	55                   	push   %ebp
  800d24:	89 e5                	mov    %esp,%ebp
  800d26:	57                   	push   %edi
  800d27:	56                   	push   %esi
  800d28:	53                   	push   %ebx
  800d29:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d2c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d31:	8b 55 08             	mov    0x8(%ebp),%edx
  800d34:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d37:	b8 08 00 00 00       	mov    $0x8,%eax
  800d3c:	89 df                	mov    %ebx,%edi
  800d3e:	89 de                	mov    %ebx,%esi
  800d40:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d42:	85 c0                	test   %eax,%eax
  800d44:	7f 08                	jg     800d4e <sys_env_set_status+0x2f>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d46:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d49:	5b                   	pop    %ebx
  800d4a:	5e                   	pop    %esi
  800d4b:	5f                   	pop    %edi
  800d4c:	5d                   	pop    %ebp
  800d4d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d4e:	83 ec 0c             	sub    $0xc,%esp
  800d51:	50                   	push   %eax
  800d52:	6a 08                	push   $0x8
  800d54:	68 e4 17 80 00       	push   $0x8017e4
  800d59:	6a 23                	push   $0x23
  800d5b:	68 01 18 80 00       	push   $0x801801
  800d60:	e8 b0 04 00 00       	call   801215 <_panic>

00800d65 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d65:	f3 0f 1e fb          	endbr32 
  800d69:	55                   	push   %ebp
  800d6a:	89 e5                	mov    %esp,%ebp
  800d6c:	57                   	push   %edi
  800d6d:	56                   	push   %esi
  800d6e:	53                   	push   %ebx
  800d6f:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d72:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d77:	8b 55 08             	mov    0x8(%ebp),%edx
  800d7a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d7d:	b8 09 00 00 00       	mov    $0x9,%eax
  800d82:	89 df                	mov    %ebx,%edi
  800d84:	89 de                	mov    %ebx,%esi
  800d86:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d88:	85 c0                	test   %eax,%eax
  800d8a:	7f 08                	jg     800d94 <sys_env_set_pgfault_upcall+0x2f>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d8c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d8f:	5b                   	pop    %ebx
  800d90:	5e                   	pop    %esi
  800d91:	5f                   	pop    %edi
  800d92:	5d                   	pop    %ebp
  800d93:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d94:	83 ec 0c             	sub    $0xc,%esp
  800d97:	50                   	push   %eax
  800d98:	6a 09                	push   $0x9
  800d9a:	68 e4 17 80 00       	push   $0x8017e4
  800d9f:	6a 23                	push   $0x23
  800da1:	68 01 18 80 00       	push   $0x801801
  800da6:	e8 6a 04 00 00       	call   801215 <_panic>

00800dab <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800dab:	f3 0f 1e fb          	endbr32 
  800daf:	55                   	push   %ebp
  800db0:	89 e5                	mov    %esp,%ebp
  800db2:	57                   	push   %edi
  800db3:	56                   	push   %esi
  800db4:	53                   	push   %ebx
	asm volatile("int %1\n"
  800db5:	8b 55 08             	mov    0x8(%ebp),%edx
  800db8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dbb:	b8 0b 00 00 00       	mov    $0xb,%eax
  800dc0:	be 00 00 00 00       	mov    $0x0,%esi
  800dc5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dc8:	8b 7d 14             	mov    0x14(%ebp),%edi
  800dcb:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800dcd:	5b                   	pop    %ebx
  800dce:	5e                   	pop    %esi
  800dcf:	5f                   	pop    %edi
  800dd0:	5d                   	pop    %ebp
  800dd1:	c3                   	ret    

00800dd2 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800dd2:	f3 0f 1e fb          	endbr32 
  800dd6:	55                   	push   %ebp
  800dd7:	89 e5                	mov    %esp,%ebp
  800dd9:	57                   	push   %edi
  800dda:	56                   	push   %esi
  800ddb:	53                   	push   %ebx
  800ddc:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800ddf:	b9 00 00 00 00       	mov    $0x0,%ecx
  800de4:	8b 55 08             	mov    0x8(%ebp),%edx
  800de7:	b8 0c 00 00 00       	mov    $0xc,%eax
  800dec:	89 cb                	mov    %ecx,%ebx
  800dee:	89 cf                	mov    %ecx,%edi
  800df0:	89 ce                	mov    %ecx,%esi
  800df2:	cd 30                	int    $0x30
	if(check && ret > 0)
  800df4:	85 c0                	test   %eax,%eax
  800df6:	7f 08                	jg     800e00 <sys_ipc_recv+0x2e>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800df8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dfb:	5b                   	pop    %ebx
  800dfc:	5e                   	pop    %esi
  800dfd:	5f                   	pop    %edi
  800dfe:	5d                   	pop    %ebp
  800dff:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e00:	83 ec 0c             	sub    $0xc,%esp
  800e03:	50                   	push   %eax
  800e04:	6a 0c                	push   $0xc
  800e06:	68 e4 17 80 00       	push   $0x8017e4
  800e0b:	6a 23                	push   $0x23
  800e0d:	68 01 18 80 00       	push   $0x801801
  800e12:	e8 fe 03 00 00       	call   801215 <_panic>

00800e17 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e17:	f3 0f 1e fb          	endbr32 
  800e1b:	55                   	push   %ebp
  800e1c:	89 e5                	mov    %esp,%ebp
  800e1e:	53                   	push   %ebx
  800e1f:	83 ec 04             	sub    $0x4,%esp
  800e22:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e25:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if(!(err & FEC_WR)){
  800e27:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e2b:	74 74                	je     800ea1 <pgfault+0x8a>
        panic("trapno is not FEC_WR");
    }
    if(!(uvpt[PGNUM(addr)] & PTE_COW)){
  800e2d:	89 d8                	mov    %ebx,%eax
  800e2f:	c1 e8 0c             	shr    $0xc,%eax
  800e32:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800e39:	f6 c4 08             	test   $0x8,%ah
  800e3c:	74 77                	je     800eb5 <pgfault+0x9e>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	addr = ROUNDDOWN(addr, PGSIZE);
  800e3e:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
    if ((r = sys_page_map(0, addr, 0, PFTEMP, PTE_U | PTE_P)) < 0)
  800e44:	83 ec 0c             	sub    $0xc,%esp
  800e47:	6a 05                	push   $0x5
  800e49:	68 00 f0 7f 00       	push   $0x7ff000
  800e4e:	6a 00                	push   $0x0
  800e50:	53                   	push   %ebx
  800e51:	6a 00                	push   $0x0
  800e53:	e8 3b fe ff ff       	call   800c93 <sys_page_map>
  800e58:	83 c4 20             	add    $0x20,%esp
  800e5b:	85 c0                	test   %eax,%eax
  800e5d:	78 6a                	js     800ec9 <pgfault+0xb2>
        panic("sys_page_map: %e", r);
    if ((r = sys_page_alloc(0, addr, PTE_W | PTE_U | PTE_P)) < 0)
  800e5f:	83 ec 04             	sub    $0x4,%esp
  800e62:	6a 07                	push   $0x7
  800e64:	53                   	push   %ebx
  800e65:	6a 00                	push   $0x0
  800e67:	e8 e0 fd ff ff       	call   800c4c <sys_page_alloc>
  800e6c:	83 c4 10             	add    $0x10,%esp
  800e6f:	85 c0                	test   %eax,%eax
  800e71:	78 68                	js     800edb <pgfault+0xc4>
        panic("sys_page_alloc: %e", r);
    memmove(addr, PFTEMP, PGSIZE);
  800e73:	83 ec 04             	sub    $0x4,%esp
  800e76:	68 00 10 00 00       	push   $0x1000
  800e7b:	68 00 f0 7f 00       	push   $0x7ff000
  800e80:	53                   	push   %ebx
  800e81:	e8 3a fb ff ff       	call   8009c0 <memmove>
    if ((r = sys_page_unmap(0, PFTEMP)) < 0)
  800e86:	83 c4 08             	add    $0x8,%esp
  800e89:	68 00 f0 7f 00       	push   $0x7ff000
  800e8e:	6a 00                	push   $0x0
  800e90:	e8 44 fe ff ff       	call   800cd9 <sys_page_unmap>
  800e95:	83 c4 10             	add    $0x10,%esp
  800e98:	85 c0                	test   %eax,%eax
  800e9a:	78 51                	js     800eed <pgfault+0xd6>
        panic("sys_page_unmap: %e", r);

	//panic("pgfault not implemented");
}
  800e9c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e9f:	c9                   	leave  
  800ea0:	c3                   	ret    
        panic("trapno is not FEC_WR");
  800ea1:	83 ec 04             	sub    $0x4,%esp
  800ea4:	68 0f 18 80 00       	push   $0x80180f
  800ea9:	6a 1d                	push   $0x1d
  800eab:	68 24 18 80 00       	push   $0x801824
  800eb0:	e8 60 03 00 00       	call   801215 <_panic>
        panic("fault addr is not COW");
  800eb5:	83 ec 04             	sub    $0x4,%esp
  800eb8:	68 2f 18 80 00       	push   $0x80182f
  800ebd:	6a 20                	push   $0x20
  800ebf:	68 24 18 80 00       	push   $0x801824
  800ec4:	e8 4c 03 00 00       	call   801215 <_panic>
        panic("sys_page_map: %e", r);
  800ec9:	50                   	push   %eax
  800eca:	68 45 18 80 00       	push   $0x801845
  800ecf:	6a 2c                	push   $0x2c
  800ed1:	68 24 18 80 00       	push   $0x801824
  800ed6:	e8 3a 03 00 00       	call   801215 <_panic>
        panic("sys_page_alloc: %e", r);
  800edb:	50                   	push   %eax
  800edc:	68 56 18 80 00       	push   $0x801856
  800ee1:	6a 2e                	push   $0x2e
  800ee3:	68 24 18 80 00       	push   $0x801824
  800ee8:	e8 28 03 00 00       	call   801215 <_panic>
        panic("sys_page_unmap: %e", r);
  800eed:	50                   	push   %eax
  800eee:	68 69 18 80 00       	push   $0x801869
  800ef3:	6a 31                	push   $0x31
  800ef5:	68 24 18 80 00       	push   $0x801824
  800efa:	e8 16 03 00 00       	call   801215 <_panic>

00800eff <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800eff:	f3 0f 1e fb          	endbr32 
  800f03:	55                   	push   %ebp
  800f04:	89 e5                	mov    %esp,%ebp
  800f06:	57                   	push   %edi
  800f07:	56                   	push   %esi
  800f08:	53                   	push   %ebx
  800f09:	83 ec 28             	sub    $0x28,%esp
    extern void _pgfault_upcall(void);

	set_pgfault_handler(pgfault);
  800f0c:	68 17 0e 80 00       	push   $0x800e17
  800f11:	e8 49 03 00 00       	call   80125f <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800f16:	b8 07 00 00 00       	mov    $0x7,%eax
  800f1b:	cd 30                	int    $0x30
  800f1d:	89 45 e4             	mov    %eax,-0x1c(%ebp)

    envid_t envid = sys_exofork();
    if (envid < 0)
  800f20:	83 c4 10             	add    $0x10,%esp
  800f23:	85 c0                	test   %eax,%eax
  800f25:	78 2d                	js     800f54 <fork+0x55>
  800f27:	89 c7                	mov    %eax,%edi
        thisenv = &envs[ENVX(sys_getenvid())];
        return 0;
    }

    // Parent
    for(uint32_t addr = 0; addr < USTACKTOP; addr += PGSIZE){
  800f29:	bb 00 00 00 00       	mov    $0x0,%ebx
    if (envid == 0) {
  800f2e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800f32:	0f 85 92 00 00 00    	jne    800fca <fork+0xcb>
        thisenv = &envs[ENVX(sys_getenvid())];
  800f38:	e8 c9 fc ff ff       	call   800c06 <sys_getenvid>
  800f3d:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f42:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800f45:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f4a:	a3 04 20 80 00       	mov    %eax,0x802004
        return 0;
  800f4f:	e9 57 01 00 00       	jmp    8010ab <fork+0x1ac>
        panic("sys_exofork Failed, envid: %e", envid);
  800f54:	50                   	push   %eax
  800f55:	68 7c 18 80 00       	push   $0x80187c
  800f5a:	6a 71                	push   $0x71
  800f5c:	68 24 18 80 00       	push   $0x801824
  800f61:	e8 af 02 00 00       	call   801215 <_panic>
        sys_page_map(0, addr, envid, addr, PTE_SYSCALL);
  800f66:	83 ec 0c             	sub    $0xc,%esp
  800f69:	68 07 0e 00 00       	push   $0xe07
  800f6e:	56                   	push   %esi
  800f6f:	57                   	push   %edi
  800f70:	56                   	push   %esi
  800f71:	6a 00                	push   $0x0
  800f73:	e8 1b fd ff ff       	call   800c93 <sys_page_map>
  800f78:	83 c4 20             	add    $0x20,%esp
  800f7b:	eb 3b                	jmp    800fb8 <fork+0xb9>
        if ((r = sys_page_map(0, addr, envid, addr, PTE_COW|PTE_U|PTE_P)) < 0)
  800f7d:	83 ec 0c             	sub    $0xc,%esp
  800f80:	68 05 08 00 00       	push   $0x805
  800f85:	56                   	push   %esi
  800f86:	57                   	push   %edi
  800f87:	56                   	push   %esi
  800f88:	6a 00                	push   $0x0
  800f8a:	e8 04 fd ff ff       	call   800c93 <sys_page_map>
  800f8f:	83 c4 20             	add    $0x20,%esp
  800f92:	85 c0                	test   %eax,%eax
  800f94:	0f 88 a9 00 00 00    	js     801043 <fork+0x144>
		if ((r = sys_page_map(0, addr, 0, addr, PTE_COW|PTE_U|PTE_P)) < 0)
  800f9a:	83 ec 0c             	sub    $0xc,%esp
  800f9d:	68 05 08 00 00       	push   $0x805
  800fa2:	56                   	push   %esi
  800fa3:	6a 00                	push   $0x0
  800fa5:	56                   	push   %esi
  800fa6:	6a 00                	push   $0x0
  800fa8:	e8 e6 fc ff ff       	call   800c93 <sys_page_map>
  800fad:	83 c4 20             	add    $0x20,%esp
  800fb0:	85 c0                	test   %eax,%eax
  800fb2:	0f 88 9d 00 00 00    	js     801055 <fork+0x156>
    for(uint32_t addr = 0; addr < USTACKTOP; addr += PGSIZE){
  800fb8:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800fbe:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  800fc4:	0f 84 9d 00 00 00    	je     801067 <fork+0x168>
		if((uvpd[PDX(addr)] & PTE_P) && 
  800fca:	89 d8                	mov    %ebx,%eax
  800fcc:	c1 e8 16             	shr    $0x16,%eax
  800fcf:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fd6:	a8 01                	test   $0x1,%al
  800fd8:	74 de                	je     800fb8 <fork+0xb9>
		(uvpt[PGNUM(addr)]&PTE_P) && 
  800fda:	89 d8                	mov    %ebx,%eax
  800fdc:	c1 e8 0c             	shr    $0xc,%eax
  800fdf:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
		if((uvpd[PDX(addr)] & PTE_P) && 
  800fe6:	f6 c2 01             	test   $0x1,%dl
  800fe9:	74 cd                	je     800fb8 <fork+0xb9>
		(uvpt[PGNUM(addr)] &PTE_U)){
  800feb:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
		(uvpt[PGNUM(addr)]&PTE_P) && 
  800ff2:	f6 c2 04             	test   $0x4,%dl
  800ff5:	74 c1                	je     800fb8 <fork+0xb9>
    void *addr=(void *)(pn*PGSIZE);
  800ff7:	89 c6                	mov    %eax,%esi
  800ff9:	c1 e6 0c             	shl    $0xc,%esi
    if(uvpt[pn] & PTE_SHARE){
  800ffc:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801003:	f6 c6 04             	test   $0x4,%dh
  801006:	0f 85 5a ff ff ff    	jne    800f66 <fork+0x67>
    else if((uvpt[pn]&PTE_W)|| (uvpt[pn] & PTE_COW)){
  80100c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801013:	f6 c2 02             	test   $0x2,%dl
  801016:	0f 85 61 ff ff ff    	jne    800f7d <fork+0x7e>
  80101c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801023:	f6 c4 08             	test   $0x8,%ah
  801026:	0f 85 51 ff ff ff    	jne    800f7d <fork+0x7e>
        sys_page_map(0, addr, envid, addr, PTE_U|PTE_P);
  80102c:	83 ec 0c             	sub    $0xc,%esp
  80102f:	6a 05                	push   $0x5
  801031:	56                   	push   %esi
  801032:	57                   	push   %edi
  801033:	56                   	push   %esi
  801034:	6a 00                	push   $0x0
  801036:	e8 58 fc ff ff       	call   800c93 <sys_page_map>
  80103b:	83 c4 20             	add    $0x20,%esp
  80103e:	e9 75 ff ff ff       	jmp    800fb8 <fork+0xb9>
			panic("sys_page_map：%e", r);
  801043:	50                   	push   %eax
  801044:	68 9a 18 80 00       	push   $0x80189a
  801049:	6a 4d                	push   $0x4d
  80104b:	68 24 18 80 00       	push   $0x801824
  801050:	e8 c0 01 00 00       	call   801215 <_panic>
			panic("sys_page_map：%e", r);
  801055:	50                   	push   %eax
  801056:	68 9a 18 80 00       	push   $0x80189a
  80105b:	6a 4f                	push   $0x4f
  80105d:	68 24 18 80 00       	push   $0x801824
  801062:	e8 ae 01 00 00       	call   801215 <_panic>
			duppage(envid, PGNUM(addr));
		}
	}

    // Allocate a new page for the child's user exception stack
    int r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_P|PTE_W|PTE_U);
  801067:	83 ec 04             	sub    $0x4,%esp
  80106a:	6a 07                	push   $0x7
  80106c:	68 00 f0 bf ee       	push   $0xeebff000
  801071:	ff 75 e4             	pushl  -0x1c(%ebp)
  801074:	e8 d3 fb ff ff       	call   800c4c <sys_page_alloc>
	if( r < 0)
  801079:	83 c4 10             	add    $0x10,%esp
  80107c:	85 c0                	test   %eax,%eax
  80107e:	78 36                	js     8010b6 <fork+0x1b7>
		panic("sys_page_alloc: %e", r);

    // Set the page fault upcall for the child
    r=sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  801080:	83 ec 08             	sub    $0x8,%esp
  801083:	68 bc 12 80 00       	push   $0x8012bc
  801088:	ff 75 e4             	pushl  -0x1c(%ebp)
  80108b:	e8 d5 fc ff ff       	call   800d65 <sys_env_set_pgfault_upcall>
    if( r < 0 )
  801090:	83 c4 10             	add    $0x10,%esp
  801093:	85 c0                	test   %eax,%eax
  801095:	78 34                	js     8010cb <fork+0x1cc>
		panic("sys_env_set_pgfault_upcall: %e",r);
    
    // Mark the child as runnable
    r=sys_env_set_status(envid, ENV_RUNNABLE);
  801097:	83 ec 08             	sub    $0x8,%esp
  80109a:	6a 02                	push   $0x2
  80109c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80109f:	e8 7b fc ff ff       	call   800d1f <sys_env_set_status>
    if (r < 0)
  8010a4:	83 c4 10             	add    $0x10,%esp
  8010a7:	85 c0                	test   %eax,%eax
  8010a9:	78 35                	js     8010e0 <fork+0x1e1>
		panic("sys_env_set_status: %e", r);
    
    return envid;
	// LAB 4: Your code here.
	//panic("fork not implemented");
}
  8010ab:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8010ae:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010b1:	5b                   	pop    %ebx
  8010b2:	5e                   	pop    %esi
  8010b3:	5f                   	pop    %edi
  8010b4:	5d                   	pop    %ebp
  8010b5:	c3                   	ret    
		panic("sys_page_alloc: %e", r);
  8010b6:	50                   	push   %eax
  8010b7:	68 56 18 80 00       	push   $0x801856
  8010bc:	68 84 00 00 00       	push   $0x84
  8010c1:	68 24 18 80 00       	push   $0x801824
  8010c6:	e8 4a 01 00 00       	call   801215 <_panic>
		panic("sys_env_set_pgfault_upcall: %e",r);
  8010cb:	50                   	push   %eax
  8010cc:	68 dc 18 80 00       	push   $0x8018dc
  8010d1:	68 89 00 00 00       	push   $0x89
  8010d6:	68 24 18 80 00       	push   $0x801824
  8010db:	e8 35 01 00 00       	call   801215 <_panic>
		panic("sys_env_set_status: %e", r);
  8010e0:	50                   	push   %eax
  8010e1:	68 ac 18 80 00       	push   $0x8018ac
  8010e6:	68 8e 00 00 00       	push   $0x8e
  8010eb:	68 24 18 80 00       	push   $0x801824
  8010f0:	e8 20 01 00 00       	call   801215 <_panic>

008010f5 <sfork>:

// Challenge!
int
sfork(void)
{
  8010f5:	f3 0f 1e fb          	endbr32 
  8010f9:	55                   	push   %ebp
  8010fa:	89 e5                	mov    %esp,%ebp
  8010fc:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8010ff:	68 c3 18 80 00       	push   $0x8018c3
  801104:	68 99 00 00 00       	push   $0x99
  801109:	68 24 18 80 00       	push   $0x801824
  80110e:	e8 02 01 00 00       	call   801215 <_panic>

00801113 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801113:	f3 0f 1e fb          	endbr32 
  801117:	55                   	push   %ebp
  801118:	89 e5                	mov    %esp,%ebp
  80111a:	56                   	push   %esi
  80111b:	53                   	push   %ebx
  80111c:	8b 75 08             	mov    0x8(%ebp),%esi
  80111f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801122:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// 检查pg是否为空
	if(pg==NULL){
		pg=(void *)-1;
  801125:	85 c0                	test   %eax,%eax
  801127:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  80112c:	0f 44 c2             	cmove  %edx,%eax
	}
	//接收 message
	int r = sys_ipc_recv(pg);
  80112f:	83 ec 0c             	sub    $0xc,%esp
  801132:	50                   	push   %eax
  801133:	e8 9a fc ff ff       	call   800dd2 <sys_ipc_recv>
	if(r<0){
  801138:	83 c4 10             	add    $0x10,%esp
  80113b:	85 c0                	test   %eax,%eax
  80113d:	78 2b                	js     80116a <ipc_recv+0x57>
		if(from_env_store) *from_env_store=0;
		if(perm_store) *perm_store=0;
		return r;
	}
	// 保存发送者的envid
	if(from_env_store) *from_env_store = thisenv->env_ipc_from;
  80113f:	85 f6                	test   %esi,%esi
  801141:	74 0a                	je     80114d <ipc_recv+0x3a>
  801143:	a1 04 20 80 00       	mov    0x802004,%eax
  801148:	8b 40 74             	mov    0x74(%eax),%eax
  80114b:	89 06                	mov    %eax,(%esi)
	// 保存发送来的页面的权限
	if(perm_store) *perm_store = thisenv->env_ipc_perm;
  80114d:	85 db                	test   %ebx,%ebx
  80114f:	74 0a                	je     80115b <ipc_recv+0x48>
  801151:	a1 04 20 80 00       	mov    0x802004,%eax
  801156:	8b 40 78             	mov    0x78(%eax),%eax
  801159:	89 03                	mov    %eax,(%ebx)
	// 返回message的value
	return thisenv->env_ipc_value;
  80115b:	a1 04 20 80 00       	mov    0x802004,%eax
  801160:	8b 40 70             	mov    0x70(%eax),%eax

	//panic("ipc_recv not implemented");
	return 0;
}
  801163:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801166:	5b                   	pop    %ebx
  801167:	5e                   	pop    %esi
  801168:	5d                   	pop    %ebp
  801169:	c3                   	ret    
		if(from_env_store) *from_env_store=0;
  80116a:	85 f6                	test   %esi,%esi
  80116c:	74 06                	je     801174 <ipc_recv+0x61>
  80116e:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store) *perm_store=0;
  801174:	85 db                	test   %ebx,%ebx
  801176:	74 eb                	je     801163 <ipc_recv+0x50>
  801178:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80117e:	eb e3                	jmp    801163 <ipc_recv+0x50>

00801180 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801180:	f3 0f 1e fb          	endbr32 
  801184:	55                   	push   %ebp
  801185:	89 e5                	mov    %esp,%ebp
  801187:	57                   	push   %edi
  801188:	56                   	push   %esi
  801189:	53                   	push   %ebx
  80118a:	83 ec 0c             	sub    $0xc,%esp
  80118d:	8b 7d 08             	mov    0x8(%ebp),%edi
  801190:	8b 75 0c             	mov    0xc(%ebp),%esi
  801193:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	// 如果pg为NULL， 要提供给sys_ipc_try_send一个能表达“no page”的值，0是有效的地址
	if(pg==NULL)
	{
		pg = (void *)-1;
  801196:	85 db                	test   %ebx,%ebx
  801198:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  80119d:	0f 44 d8             	cmove  %eax,%ebx
	}
	int r;
	//不停尝试发送消息直到成功
	while(1)
	{
		r = sys_ipc_try_send(to_env, val, pg, perm);
  8011a0:	ff 75 14             	pushl  0x14(%ebp)
  8011a3:	53                   	push   %ebx
  8011a4:	56                   	push   %esi
  8011a5:	57                   	push   %edi
  8011a6:	e8 00 fc ff ff       	call   800dab <sys_ipc_try_send>
		if (r == 0) {		//发送成功
  8011ab:	83 c4 10             	add    $0x10,%esp
  8011ae:	85 c0                	test   %eax,%eax
  8011b0:	74 1e                	je     8011d0 <ipc_send+0x50>
			return;
		} else if (r == -E_IPC_NOT_RECV) {	//接收环境未准备接收
  8011b2:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8011b5:	75 07                	jne    8011be <ipc_send+0x3e>
			sys_yield();
  8011b7:	e8 6d fa ff ff       	call   800c29 <sys_yield>
		r = sys_ipc_try_send(to_env, val, pg, perm);
  8011bc:	eb e2                	jmp    8011a0 <ipc_send+0x20>
		}else{
			panic("ipc_send() fault:%e\n", r);
  8011be:	50                   	push   %eax
  8011bf:	68 fb 18 80 00       	push   $0x8018fb
  8011c4:	6a 4c                	push   $0x4c
  8011c6:	68 10 19 80 00       	push   $0x801910
  8011cb:	e8 45 00 00 00       	call   801215 <_panic>
		}
	}
}
  8011d0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011d3:	5b                   	pop    %ebx
  8011d4:	5e                   	pop    %esi
  8011d5:	5f                   	pop    %edi
  8011d6:	5d                   	pop    %ebp
  8011d7:	c3                   	ret    

008011d8 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8011d8:	f3 0f 1e fb          	endbr32 
  8011dc:	55                   	push   %ebp
  8011dd:	89 e5                	mov    %esp,%ebp
  8011df:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8011e2:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8011e7:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8011ea:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8011f0:	8b 52 50             	mov    0x50(%edx),%edx
  8011f3:	39 ca                	cmp    %ecx,%edx
  8011f5:	74 11                	je     801208 <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  8011f7:	83 c0 01             	add    $0x1,%eax
  8011fa:	3d 00 04 00 00       	cmp    $0x400,%eax
  8011ff:	75 e6                	jne    8011e7 <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  801201:	b8 00 00 00 00       	mov    $0x0,%eax
  801206:	eb 0b                	jmp    801213 <ipc_find_env+0x3b>
			return envs[i].env_id;
  801208:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80120b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801210:	8b 40 48             	mov    0x48(%eax),%eax
}
  801213:	5d                   	pop    %ebp
  801214:	c3                   	ret    

00801215 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801215:	f3 0f 1e fb          	endbr32 
  801219:	55                   	push   %ebp
  80121a:	89 e5                	mov    %esp,%ebp
  80121c:	56                   	push   %esi
  80121d:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80121e:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801221:	8b 35 00 20 80 00    	mov    0x802000,%esi
  801227:	e8 da f9 ff ff       	call   800c06 <sys_getenvid>
  80122c:	83 ec 0c             	sub    $0xc,%esp
  80122f:	ff 75 0c             	pushl  0xc(%ebp)
  801232:	ff 75 08             	pushl  0x8(%ebp)
  801235:	56                   	push   %esi
  801236:	50                   	push   %eax
  801237:	68 1c 19 80 00       	push   $0x80191c
  80123c:	e8 80 ef ff ff       	call   8001c1 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801241:	83 c4 18             	add    $0x18,%esp
  801244:	53                   	push   %ebx
  801245:	ff 75 10             	pushl  0x10(%ebp)
  801248:	e8 1f ef ff ff       	call   80016c <vcprintf>
	cprintf("\n");
  80124d:	c7 04 24 0e 19 80 00 	movl   $0x80190e,(%esp)
  801254:	e8 68 ef ff ff       	call   8001c1 <cprintf>
  801259:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80125c:	cc                   	int3   
  80125d:	eb fd                	jmp    80125c <_panic+0x47>

0080125f <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80125f:	f3 0f 1e fb          	endbr32 
  801263:	55                   	push   %ebp
  801264:	89 e5                	mov    %esp,%ebp
  801266:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801269:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  801270:	74 0a                	je     80127c <set_pgfault_handler+0x1d>
        sys_env_set_pgfault_upcall(0, _pgfault_upcall);
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801272:	8b 45 08             	mov    0x8(%ebp),%eax
  801275:	a3 08 20 80 00       	mov    %eax,0x802008
}
  80127a:	c9                   	leave  
  80127b:	c3                   	ret    
		if (sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P) < 0)
  80127c:	83 ec 04             	sub    $0x4,%esp
  80127f:	6a 07                	push   $0x7
  801281:	68 00 f0 bf ee       	push   $0xeebff000
  801286:	6a 00                	push   $0x0
  801288:	e8 bf f9 ff ff       	call   800c4c <sys_page_alloc>
  80128d:	83 c4 10             	add    $0x10,%esp
  801290:	85 c0                	test   %eax,%eax
  801292:	78 14                	js     8012a8 <set_pgfault_handler+0x49>
        sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  801294:	83 ec 08             	sub    $0x8,%esp
  801297:	68 bc 12 80 00       	push   $0x8012bc
  80129c:	6a 00                	push   $0x0
  80129e:	e8 c2 fa ff ff       	call   800d65 <sys_env_set_pgfault_upcall>
  8012a3:	83 c4 10             	add    $0x10,%esp
  8012a6:	eb ca                	jmp    801272 <set_pgfault_handler+0x13>
            panic("set_pgfault_handler failed.");
  8012a8:	83 ec 04             	sub    $0x4,%esp
  8012ab:	68 3f 19 80 00       	push   $0x80193f
  8012b0:	6a 21                	push   $0x21
  8012b2:	68 5b 19 80 00       	push   $0x80195b
  8012b7:	e8 59 ff ff ff       	call   801215 <_panic>

008012bc <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8012bc:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8012bd:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  8012c2:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8012c4:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	addl $8, %esp
  8012c7:	83 c4 08             	add    $0x8,%esp
	movl 32(%esp), %eax
  8012ca:	8b 44 24 20          	mov    0x20(%esp),%eax
	movl 40(%esp), %edx
  8012ce:	8b 54 24 28          	mov    0x28(%esp),%edx
	subl $4, %edx
  8012d2:	83 ea 04             	sub    $0x4,%edx
	movl %eax, (%edx)
  8012d5:	89 02                	mov    %eax,(%edx)
	movl %edx, 40(%esp)
  8012d7:	89 54 24 28          	mov    %edx,0x28(%esp)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal
  8012db:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp
  8012dc:	83 c4 04             	add    $0x4,%esp
	popfl
  8012df:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  8012e0:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  8012e1:	c3                   	ret    
  8012e2:	66 90                	xchg   %ax,%ax
  8012e4:	66 90                	xchg   %ax,%ax
  8012e6:	66 90                	xchg   %ax,%ax
  8012e8:	66 90                	xchg   %ax,%ax
  8012ea:	66 90                	xchg   %ax,%ax
  8012ec:	66 90                	xchg   %ax,%ax
  8012ee:	66 90                	xchg   %ax,%ax

008012f0 <__udivdi3>:
  8012f0:	f3 0f 1e fb          	endbr32 
  8012f4:	55                   	push   %ebp
  8012f5:	57                   	push   %edi
  8012f6:	56                   	push   %esi
  8012f7:	53                   	push   %ebx
  8012f8:	83 ec 1c             	sub    $0x1c,%esp
  8012fb:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8012ff:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  801303:	8b 74 24 34          	mov    0x34(%esp),%esi
  801307:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  80130b:	85 d2                	test   %edx,%edx
  80130d:	75 19                	jne    801328 <__udivdi3+0x38>
  80130f:	39 f3                	cmp    %esi,%ebx
  801311:	76 4d                	jbe    801360 <__udivdi3+0x70>
  801313:	31 ff                	xor    %edi,%edi
  801315:	89 e8                	mov    %ebp,%eax
  801317:	89 f2                	mov    %esi,%edx
  801319:	f7 f3                	div    %ebx
  80131b:	89 fa                	mov    %edi,%edx
  80131d:	83 c4 1c             	add    $0x1c,%esp
  801320:	5b                   	pop    %ebx
  801321:	5e                   	pop    %esi
  801322:	5f                   	pop    %edi
  801323:	5d                   	pop    %ebp
  801324:	c3                   	ret    
  801325:	8d 76 00             	lea    0x0(%esi),%esi
  801328:	39 f2                	cmp    %esi,%edx
  80132a:	76 14                	jbe    801340 <__udivdi3+0x50>
  80132c:	31 ff                	xor    %edi,%edi
  80132e:	31 c0                	xor    %eax,%eax
  801330:	89 fa                	mov    %edi,%edx
  801332:	83 c4 1c             	add    $0x1c,%esp
  801335:	5b                   	pop    %ebx
  801336:	5e                   	pop    %esi
  801337:	5f                   	pop    %edi
  801338:	5d                   	pop    %ebp
  801339:	c3                   	ret    
  80133a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801340:	0f bd fa             	bsr    %edx,%edi
  801343:	83 f7 1f             	xor    $0x1f,%edi
  801346:	75 48                	jne    801390 <__udivdi3+0xa0>
  801348:	39 f2                	cmp    %esi,%edx
  80134a:	72 06                	jb     801352 <__udivdi3+0x62>
  80134c:	31 c0                	xor    %eax,%eax
  80134e:	39 eb                	cmp    %ebp,%ebx
  801350:	77 de                	ja     801330 <__udivdi3+0x40>
  801352:	b8 01 00 00 00       	mov    $0x1,%eax
  801357:	eb d7                	jmp    801330 <__udivdi3+0x40>
  801359:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801360:	89 d9                	mov    %ebx,%ecx
  801362:	85 db                	test   %ebx,%ebx
  801364:	75 0b                	jne    801371 <__udivdi3+0x81>
  801366:	b8 01 00 00 00       	mov    $0x1,%eax
  80136b:	31 d2                	xor    %edx,%edx
  80136d:	f7 f3                	div    %ebx
  80136f:	89 c1                	mov    %eax,%ecx
  801371:	31 d2                	xor    %edx,%edx
  801373:	89 f0                	mov    %esi,%eax
  801375:	f7 f1                	div    %ecx
  801377:	89 c6                	mov    %eax,%esi
  801379:	89 e8                	mov    %ebp,%eax
  80137b:	89 f7                	mov    %esi,%edi
  80137d:	f7 f1                	div    %ecx
  80137f:	89 fa                	mov    %edi,%edx
  801381:	83 c4 1c             	add    $0x1c,%esp
  801384:	5b                   	pop    %ebx
  801385:	5e                   	pop    %esi
  801386:	5f                   	pop    %edi
  801387:	5d                   	pop    %ebp
  801388:	c3                   	ret    
  801389:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801390:	89 f9                	mov    %edi,%ecx
  801392:	b8 20 00 00 00       	mov    $0x20,%eax
  801397:	29 f8                	sub    %edi,%eax
  801399:	d3 e2                	shl    %cl,%edx
  80139b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80139f:	89 c1                	mov    %eax,%ecx
  8013a1:	89 da                	mov    %ebx,%edx
  8013a3:	d3 ea                	shr    %cl,%edx
  8013a5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8013a9:	09 d1                	or     %edx,%ecx
  8013ab:	89 f2                	mov    %esi,%edx
  8013ad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8013b1:	89 f9                	mov    %edi,%ecx
  8013b3:	d3 e3                	shl    %cl,%ebx
  8013b5:	89 c1                	mov    %eax,%ecx
  8013b7:	d3 ea                	shr    %cl,%edx
  8013b9:	89 f9                	mov    %edi,%ecx
  8013bb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8013bf:	89 eb                	mov    %ebp,%ebx
  8013c1:	d3 e6                	shl    %cl,%esi
  8013c3:	89 c1                	mov    %eax,%ecx
  8013c5:	d3 eb                	shr    %cl,%ebx
  8013c7:	09 de                	or     %ebx,%esi
  8013c9:	89 f0                	mov    %esi,%eax
  8013cb:	f7 74 24 08          	divl   0x8(%esp)
  8013cf:	89 d6                	mov    %edx,%esi
  8013d1:	89 c3                	mov    %eax,%ebx
  8013d3:	f7 64 24 0c          	mull   0xc(%esp)
  8013d7:	39 d6                	cmp    %edx,%esi
  8013d9:	72 15                	jb     8013f0 <__udivdi3+0x100>
  8013db:	89 f9                	mov    %edi,%ecx
  8013dd:	d3 e5                	shl    %cl,%ebp
  8013df:	39 c5                	cmp    %eax,%ebp
  8013e1:	73 04                	jae    8013e7 <__udivdi3+0xf7>
  8013e3:	39 d6                	cmp    %edx,%esi
  8013e5:	74 09                	je     8013f0 <__udivdi3+0x100>
  8013e7:	89 d8                	mov    %ebx,%eax
  8013e9:	31 ff                	xor    %edi,%edi
  8013eb:	e9 40 ff ff ff       	jmp    801330 <__udivdi3+0x40>
  8013f0:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8013f3:	31 ff                	xor    %edi,%edi
  8013f5:	e9 36 ff ff ff       	jmp    801330 <__udivdi3+0x40>
  8013fa:	66 90                	xchg   %ax,%ax
  8013fc:	66 90                	xchg   %ax,%ax
  8013fe:	66 90                	xchg   %ax,%ax

00801400 <__umoddi3>:
  801400:	f3 0f 1e fb          	endbr32 
  801404:	55                   	push   %ebp
  801405:	57                   	push   %edi
  801406:	56                   	push   %esi
  801407:	53                   	push   %ebx
  801408:	83 ec 1c             	sub    $0x1c,%esp
  80140b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80140f:	8b 74 24 30          	mov    0x30(%esp),%esi
  801413:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  801417:	8b 7c 24 38          	mov    0x38(%esp),%edi
  80141b:	85 c0                	test   %eax,%eax
  80141d:	75 19                	jne    801438 <__umoddi3+0x38>
  80141f:	39 df                	cmp    %ebx,%edi
  801421:	76 5d                	jbe    801480 <__umoddi3+0x80>
  801423:	89 f0                	mov    %esi,%eax
  801425:	89 da                	mov    %ebx,%edx
  801427:	f7 f7                	div    %edi
  801429:	89 d0                	mov    %edx,%eax
  80142b:	31 d2                	xor    %edx,%edx
  80142d:	83 c4 1c             	add    $0x1c,%esp
  801430:	5b                   	pop    %ebx
  801431:	5e                   	pop    %esi
  801432:	5f                   	pop    %edi
  801433:	5d                   	pop    %ebp
  801434:	c3                   	ret    
  801435:	8d 76 00             	lea    0x0(%esi),%esi
  801438:	89 f2                	mov    %esi,%edx
  80143a:	39 d8                	cmp    %ebx,%eax
  80143c:	76 12                	jbe    801450 <__umoddi3+0x50>
  80143e:	89 f0                	mov    %esi,%eax
  801440:	89 da                	mov    %ebx,%edx
  801442:	83 c4 1c             	add    $0x1c,%esp
  801445:	5b                   	pop    %ebx
  801446:	5e                   	pop    %esi
  801447:	5f                   	pop    %edi
  801448:	5d                   	pop    %ebp
  801449:	c3                   	ret    
  80144a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801450:	0f bd e8             	bsr    %eax,%ebp
  801453:	83 f5 1f             	xor    $0x1f,%ebp
  801456:	75 50                	jne    8014a8 <__umoddi3+0xa8>
  801458:	39 d8                	cmp    %ebx,%eax
  80145a:	0f 82 e0 00 00 00    	jb     801540 <__umoddi3+0x140>
  801460:	89 d9                	mov    %ebx,%ecx
  801462:	39 f7                	cmp    %esi,%edi
  801464:	0f 86 d6 00 00 00    	jbe    801540 <__umoddi3+0x140>
  80146a:	89 d0                	mov    %edx,%eax
  80146c:	89 ca                	mov    %ecx,%edx
  80146e:	83 c4 1c             	add    $0x1c,%esp
  801471:	5b                   	pop    %ebx
  801472:	5e                   	pop    %esi
  801473:	5f                   	pop    %edi
  801474:	5d                   	pop    %ebp
  801475:	c3                   	ret    
  801476:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80147d:	8d 76 00             	lea    0x0(%esi),%esi
  801480:	89 fd                	mov    %edi,%ebp
  801482:	85 ff                	test   %edi,%edi
  801484:	75 0b                	jne    801491 <__umoddi3+0x91>
  801486:	b8 01 00 00 00       	mov    $0x1,%eax
  80148b:	31 d2                	xor    %edx,%edx
  80148d:	f7 f7                	div    %edi
  80148f:	89 c5                	mov    %eax,%ebp
  801491:	89 d8                	mov    %ebx,%eax
  801493:	31 d2                	xor    %edx,%edx
  801495:	f7 f5                	div    %ebp
  801497:	89 f0                	mov    %esi,%eax
  801499:	f7 f5                	div    %ebp
  80149b:	89 d0                	mov    %edx,%eax
  80149d:	31 d2                	xor    %edx,%edx
  80149f:	eb 8c                	jmp    80142d <__umoddi3+0x2d>
  8014a1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8014a8:	89 e9                	mov    %ebp,%ecx
  8014aa:	ba 20 00 00 00       	mov    $0x20,%edx
  8014af:	29 ea                	sub    %ebp,%edx
  8014b1:	d3 e0                	shl    %cl,%eax
  8014b3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8014b7:	89 d1                	mov    %edx,%ecx
  8014b9:	89 f8                	mov    %edi,%eax
  8014bb:	d3 e8                	shr    %cl,%eax
  8014bd:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8014c1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8014c5:	8b 54 24 04          	mov    0x4(%esp),%edx
  8014c9:	09 c1                	or     %eax,%ecx
  8014cb:	89 d8                	mov    %ebx,%eax
  8014cd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8014d1:	89 e9                	mov    %ebp,%ecx
  8014d3:	d3 e7                	shl    %cl,%edi
  8014d5:	89 d1                	mov    %edx,%ecx
  8014d7:	d3 e8                	shr    %cl,%eax
  8014d9:	89 e9                	mov    %ebp,%ecx
  8014db:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8014df:	d3 e3                	shl    %cl,%ebx
  8014e1:	89 c7                	mov    %eax,%edi
  8014e3:	89 d1                	mov    %edx,%ecx
  8014e5:	89 f0                	mov    %esi,%eax
  8014e7:	d3 e8                	shr    %cl,%eax
  8014e9:	89 e9                	mov    %ebp,%ecx
  8014eb:	89 fa                	mov    %edi,%edx
  8014ed:	d3 e6                	shl    %cl,%esi
  8014ef:	09 d8                	or     %ebx,%eax
  8014f1:	f7 74 24 08          	divl   0x8(%esp)
  8014f5:	89 d1                	mov    %edx,%ecx
  8014f7:	89 f3                	mov    %esi,%ebx
  8014f9:	f7 64 24 0c          	mull   0xc(%esp)
  8014fd:	89 c6                	mov    %eax,%esi
  8014ff:	89 d7                	mov    %edx,%edi
  801501:	39 d1                	cmp    %edx,%ecx
  801503:	72 06                	jb     80150b <__umoddi3+0x10b>
  801505:	75 10                	jne    801517 <__umoddi3+0x117>
  801507:	39 c3                	cmp    %eax,%ebx
  801509:	73 0c                	jae    801517 <__umoddi3+0x117>
  80150b:	2b 44 24 0c          	sub    0xc(%esp),%eax
  80150f:	1b 54 24 08          	sbb    0x8(%esp),%edx
  801513:	89 d7                	mov    %edx,%edi
  801515:	89 c6                	mov    %eax,%esi
  801517:	89 ca                	mov    %ecx,%edx
  801519:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80151e:	29 f3                	sub    %esi,%ebx
  801520:	19 fa                	sbb    %edi,%edx
  801522:	89 d0                	mov    %edx,%eax
  801524:	d3 e0                	shl    %cl,%eax
  801526:	89 e9                	mov    %ebp,%ecx
  801528:	d3 eb                	shr    %cl,%ebx
  80152a:	d3 ea                	shr    %cl,%edx
  80152c:	09 d8                	or     %ebx,%eax
  80152e:	83 c4 1c             	add    $0x1c,%esp
  801531:	5b                   	pop    %ebx
  801532:	5e                   	pop    %esi
  801533:	5f                   	pop    %edi
  801534:	5d                   	pop    %ebp
  801535:	c3                   	ret    
  801536:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80153d:	8d 76 00             	lea    0x0(%esi),%esi
  801540:	29 fe                	sub    %edi,%esi
  801542:	19 c3                	sbb    %eax,%ebx
  801544:	89 f2                	mov    %esi,%edx
  801546:	89 d9                	mov    %ebx,%ecx
  801548:	e9 1d ff ff ff       	jmp    80146a <__umoddi3+0x6a>
