
obj/user/forktree:     file format elf32-i386


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
  80002c:	e8 be 00 00 00       	call   8000ef <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <forktree>:
	}
}

void
forktree(const char *cur)
{
  800033:	f3 0f 1e fb          	endbr32 
  800037:	55                   	push   %ebp
  800038:	89 e5                	mov    %esp,%ebp
  80003a:	53                   	push   %ebx
  80003b:	83 ec 04             	sub    $0x4,%esp
  80003e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("%04x: I am '%s'\n", sys_getenvid(), cur);
  800041:	e8 eb 0b 00 00       	call   800c31 <sys_getenvid>
  800046:	83 ec 04             	sub    $0x4,%esp
  800049:	53                   	push   %ebx
  80004a:	50                   	push   %eax
  80004b:	68 80 14 80 00       	push   $0x801480
  800050:	e8 97 01 00 00       	call   8001ec <cprintf>

	forkchild(cur, '0');
  800055:	83 c4 08             	add    $0x8,%esp
  800058:	6a 30                	push   $0x30
  80005a:	53                   	push   %ebx
  80005b:	e8 13 00 00 00       	call   800073 <forkchild>
	forkchild(cur, '1');
  800060:	83 c4 08             	add    $0x8,%esp
  800063:	6a 31                	push   $0x31
  800065:	53                   	push   %ebx
  800066:	e8 08 00 00 00       	call   800073 <forkchild>
}
  80006b:	83 c4 10             	add    $0x10,%esp
  80006e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800071:	c9                   	leave  
  800072:	c3                   	ret    

00800073 <forkchild>:
{
  800073:	f3 0f 1e fb          	endbr32 
  800077:	55                   	push   %ebp
  800078:	89 e5                	mov    %esp,%ebp
  80007a:	56                   	push   %esi
  80007b:	53                   	push   %ebx
  80007c:	83 ec 1c             	sub    $0x1c,%esp
  80007f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800082:	8b 75 0c             	mov    0xc(%ebp),%esi
	if (strlen(cur) >= DEPTH)
  800085:	53                   	push   %ebx
  800086:	e8 67 07 00 00       	call   8007f2 <strlen>
  80008b:	83 c4 10             	add    $0x10,%esp
  80008e:	83 f8 02             	cmp    $0x2,%eax
  800091:	7e 07                	jle    80009a <forkchild+0x27>
}
  800093:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800096:	5b                   	pop    %ebx
  800097:	5e                   	pop    %esi
  800098:	5d                   	pop    %ebp
  800099:	c3                   	ret    
	snprintf(nxt, DEPTH+1, "%s%c", cur, branch);
  80009a:	83 ec 0c             	sub    $0xc,%esp
  80009d:	89 f0                	mov    %esi,%eax
  80009f:	0f be f0             	movsbl %al,%esi
  8000a2:	56                   	push   %esi
  8000a3:	53                   	push   %ebx
  8000a4:	68 91 14 80 00       	push   $0x801491
  8000a9:	6a 04                	push   $0x4
  8000ab:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8000ae:	50                   	push   %eax
  8000af:	e8 20 07 00 00       	call   8007d4 <snprintf>
	if (fork() == 0) {
  8000b4:	83 c4 20             	add    $0x20,%esp
  8000b7:	e8 6e 0e 00 00       	call   800f2a <fork>
  8000bc:	85 c0                	test   %eax,%eax
  8000be:	75 d3                	jne    800093 <forkchild+0x20>
		forktree(nxt);
  8000c0:	83 ec 0c             	sub    $0xc,%esp
  8000c3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8000c6:	50                   	push   %eax
  8000c7:	e8 67 ff ff ff       	call   800033 <forktree>
		exit();
  8000cc:	e8 68 00 00 00       	call   800139 <exit>
  8000d1:	83 c4 10             	add    $0x10,%esp
  8000d4:	eb bd                	jmp    800093 <forkchild+0x20>

008000d6 <umain>:

void
umain(int argc, char **argv)
{
  8000d6:	f3 0f 1e fb          	endbr32 
  8000da:	55                   	push   %ebp
  8000db:	89 e5                	mov    %esp,%ebp
  8000dd:	83 ec 14             	sub    $0x14,%esp
	forktree("");
  8000e0:	68 90 14 80 00       	push   $0x801490
  8000e5:	e8 49 ff ff ff       	call   800033 <forktree>
}
  8000ea:	83 c4 10             	add    $0x10,%esp
  8000ed:	c9                   	leave  
  8000ee:	c3                   	ret    

008000ef <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000ef:	f3 0f 1e fb          	endbr32 
  8000f3:	55                   	push   %ebp
  8000f4:	89 e5                	mov    %esp,%ebp
  8000f6:	56                   	push   %esi
  8000f7:	53                   	push   %ebx
  8000f8:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000fb:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv=&envs[ENVX(sys_getenvid())];
  8000fe:	e8 2e 0b 00 00       	call   800c31 <sys_getenvid>
  800103:	25 ff 03 00 00       	and    $0x3ff,%eax
  800108:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80010b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800110:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800115:	85 db                	test   %ebx,%ebx
  800117:	7e 07                	jle    800120 <libmain+0x31>
		binaryname = argv[0];
  800119:	8b 06                	mov    (%esi),%eax
  80011b:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800120:	83 ec 08             	sub    $0x8,%esp
  800123:	56                   	push   %esi
  800124:	53                   	push   %ebx
  800125:	e8 ac ff ff ff       	call   8000d6 <umain>

	// exit gracefully
	exit();
  80012a:	e8 0a 00 00 00       	call   800139 <exit>
}
  80012f:	83 c4 10             	add    $0x10,%esp
  800132:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800135:	5b                   	pop    %ebx
  800136:	5e                   	pop    %esi
  800137:	5d                   	pop    %ebp
  800138:	c3                   	ret    

00800139 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800139:	f3 0f 1e fb          	endbr32 
  80013d:	55                   	push   %ebp
  80013e:	89 e5                	mov    %esp,%ebp
  800140:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800143:	6a 00                	push   $0x0
  800145:	e8 a2 0a 00 00       	call   800bec <sys_env_destroy>
}
  80014a:	83 c4 10             	add    $0x10,%esp
  80014d:	c9                   	leave  
  80014e:	c3                   	ret    

0080014f <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80014f:	f3 0f 1e fb          	endbr32 
  800153:	55                   	push   %ebp
  800154:	89 e5                	mov    %esp,%ebp
  800156:	53                   	push   %ebx
  800157:	83 ec 04             	sub    $0x4,%esp
  80015a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80015d:	8b 13                	mov    (%ebx),%edx
  80015f:	8d 42 01             	lea    0x1(%edx),%eax
  800162:	89 03                	mov    %eax,(%ebx)
  800164:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800167:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80016b:	3d ff 00 00 00       	cmp    $0xff,%eax
  800170:	74 09                	je     80017b <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800172:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800176:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800179:	c9                   	leave  
  80017a:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80017b:	83 ec 08             	sub    $0x8,%esp
  80017e:	68 ff 00 00 00       	push   $0xff
  800183:	8d 43 08             	lea    0x8(%ebx),%eax
  800186:	50                   	push   %eax
  800187:	e8 1b 0a 00 00       	call   800ba7 <sys_cputs>
		b->idx = 0;
  80018c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800192:	83 c4 10             	add    $0x10,%esp
  800195:	eb db                	jmp    800172 <putch+0x23>

00800197 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800197:	f3 0f 1e fb          	endbr32 
  80019b:	55                   	push   %ebp
  80019c:	89 e5                	mov    %esp,%ebp
  80019e:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001a4:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001ab:	00 00 00 
	b.cnt = 0;
  8001ae:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001b5:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001b8:	ff 75 0c             	pushl  0xc(%ebp)
  8001bb:	ff 75 08             	pushl  0x8(%ebp)
  8001be:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001c4:	50                   	push   %eax
  8001c5:	68 4f 01 80 00       	push   $0x80014f
  8001ca:	e8 20 01 00 00       	call   8002ef <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001cf:	83 c4 08             	add    $0x8,%esp
  8001d2:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001d8:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001de:	50                   	push   %eax
  8001df:	e8 c3 09 00 00       	call   800ba7 <sys_cputs>

	return b.cnt;
}
  8001e4:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001ea:	c9                   	leave  
  8001eb:	c3                   	ret    

008001ec <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001ec:	f3 0f 1e fb          	endbr32 
  8001f0:	55                   	push   %ebp
  8001f1:	89 e5                	mov    %esp,%ebp
  8001f3:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001f6:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001f9:	50                   	push   %eax
  8001fa:	ff 75 08             	pushl  0x8(%ebp)
  8001fd:	e8 95 ff ff ff       	call   800197 <vcprintf>
	va_end(ap);

	return cnt;
}
  800202:	c9                   	leave  
  800203:	c3                   	ret    

00800204 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800204:	55                   	push   %ebp
  800205:	89 e5                	mov    %esp,%ebp
  800207:	57                   	push   %edi
  800208:	56                   	push   %esi
  800209:	53                   	push   %ebx
  80020a:	83 ec 1c             	sub    $0x1c,%esp
  80020d:	89 c7                	mov    %eax,%edi
  80020f:	89 d6                	mov    %edx,%esi
  800211:	8b 45 08             	mov    0x8(%ebp),%eax
  800214:	8b 55 0c             	mov    0xc(%ebp),%edx
  800217:	89 d1                	mov    %edx,%ecx
  800219:	89 c2                	mov    %eax,%edx
  80021b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80021e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800221:	8b 45 10             	mov    0x10(%ebp),%eax
  800224:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800227:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80022a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800231:	39 c2                	cmp    %eax,%edx
  800233:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800236:	72 3e                	jb     800276 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800238:	83 ec 0c             	sub    $0xc,%esp
  80023b:	ff 75 18             	pushl  0x18(%ebp)
  80023e:	83 eb 01             	sub    $0x1,%ebx
  800241:	53                   	push   %ebx
  800242:	50                   	push   %eax
  800243:	83 ec 08             	sub    $0x8,%esp
  800246:	ff 75 e4             	pushl  -0x1c(%ebp)
  800249:	ff 75 e0             	pushl  -0x20(%ebp)
  80024c:	ff 75 dc             	pushl  -0x24(%ebp)
  80024f:	ff 75 d8             	pushl  -0x28(%ebp)
  800252:	e8 b9 0f 00 00       	call   801210 <__udivdi3>
  800257:	83 c4 18             	add    $0x18,%esp
  80025a:	52                   	push   %edx
  80025b:	50                   	push   %eax
  80025c:	89 f2                	mov    %esi,%edx
  80025e:	89 f8                	mov    %edi,%eax
  800260:	e8 9f ff ff ff       	call   800204 <printnum>
  800265:	83 c4 20             	add    $0x20,%esp
  800268:	eb 13                	jmp    80027d <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80026a:	83 ec 08             	sub    $0x8,%esp
  80026d:	56                   	push   %esi
  80026e:	ff 75 18             	pushl  0x18(%ebp)
  800271:	ff d7                	call   *%edi
  800273:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800276:	83 eb 01             	sub    $0x1,%ebx
  800279:	85 db                	test   %ebx,%ebx
  80027b:	7f ed                	jg     80026a <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80027d:	83 ec 08             	sub    $0x8,%esp
  800280:	56                   	push   %esi
  800281:	83 ec 04             	sub    $0x4,%esp
  800284:	ff 75 e4             	pushl  -0x1c(%ebp)
  800287:	ff 75 e0             	pushl  -0x20(%ebp)
  80028a:	ff 75 dc             	pushl  -0x24(%ebp)
  80028d:	ff 75 d8             	pushl  -0x28(%ebp)
  800290:	e8 8b 10 00 00       	call   801320 <__umoddi3>
  800295:	83 c4 14             	add    $0x14,%esp
  800298:	0f be 80 a0 14 80 00 	movsbl 0x8014a0(%eax),%eax
  80029f:	50                   	push   %eax
  8002a0:	ff d7                	call   *%edi
}
  8002a2:	83 c4 10             	add    $0x10,%esp
  8002a5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002a8:	5b                   	pop    %ebx
  8002a9:	5e                   	pop    %esi
  8002aa:	5f                   	pop    %edi
  8002ab:	5d                   	pop    %ebp
  8002ac:	c3                   	ret    

008002ad <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002ad:	f3 0f 1e fb          	endbr32 
  8002b1:	55                   	push   %ebp
  8002b2:	89 e5                	mov    %esp,%ebp
  8002b4:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002b7:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002bb:	8b 10                	mov    (%eax),%edx
  8002bd:	3b 50 04             	cmp    0x4(%eax),%edx
  8002c0:	73 0a                	jae    8002cc <sprintputch+0x1f>
		*b->buf++ = ch;
  8002c2:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002c5:	89 08                	mov    %ecx,(%eax)
  8002c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8002ca:	88 02                	mov    %al,(%edx)
}
  8002cc:	5d                   	pop    %ebp
  8002cd:	c3                   	ret    

008002ce <printfmt>:
{
  8002ce:	f3 0f 1e fb          	endbr32 
  8002d2:	55                   	push   %ebp
  8002d3:	89 e5                	mov    %esp,%ebp
  8002d5:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8002d8:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002db:	50                   	push   %eax
  8002dc:	ff 75 10             	pushl  0x10(%ebp)
  8002df:	ff 75 0c             	pushl  0xc(%ebp)
  8002e2:	ff 75 08             	pushl  0x8(%ebp)
  8002e5:	e8 05 00 00 00       	call   8002ef <vprintfmt>
}
  8002ea:	83 c4 10             	add    $0x10,%esp
  8002ed:	c9                   	leave  
  8002ee:	c3                   	ret    

008002ef <vprintfmt>:
{
  8002ef:	f3 0f 1e fb          	endbr32 
  8002f3:	55                   	push   %ebp
  8002f4:	89 e5                	mov    %esp,%ebp
  8002f6:	57                   	push   %edi
  8002f7:	56                   	push   %esi
  8002f8:	53                   	push   %ebx
  8002f9:	83 ec 3c             	sub    $0x3c,%esp
  8002fc:	8b 75 08             	mov    0x8(%ebp),%esi
  8002ff:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800302:	8b 7d 10             	mov    0x10(%ebp),%edi
  800305:	e9 cd 03 00 00       	jmp    8006d7 <vprintfmt+0x3e8>
		padc = ' ';
  80030a:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  80030e:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800315:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  80031c:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800323:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800328:	8d 47 01             	lea    0x1(%edi),%eax
  80032b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80032e:	0f b6 17             	movzbl (%edi),%edx
  800331:	8d 42 dd             	lea    -0x23(%edx),%eax
  800334:	3c 55                	cmp    $0x55,%al
  800336:	0f 87 1e 04 00 00    	ja     80075a <vprintfmt+0x46b>
  80033c:	0f b6 c0             	movzbl %al,%eax
  80033f:	3e ff 24 85 60 15 80 	notrack jmp *0x801560(,%eax,4)
  800346:	00 
  800347:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80034a:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  80034e:	eb d8                	jmp    800328 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800350:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800353:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  800357:	eb cf                	jmp    800328 <vprintfmt+0x39>
  800359:	0f b6 d2             	movzbl %dl,%edx
  80035c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  80035f:	b8 00 00 00 00       	mov    $0x0,%eax
  800364:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800367:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80036a:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80036e:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800371:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800374:	83 f9 09             	cmp    $0x9,%ecx
  800377:	77 55                	ja     8003ce <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  800379:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80037c:	eb e9                	jmp    800367 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  80037e:	8b 45 14             	mov    0x14(%ebp),%eax
  800381:	8b 00                	mov    (%eax),%eax
  800383:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800386:	8b 45 14             	mov    0x14(%ebp),%eax
  800389:	8d 40 04             	lea    0x4(%eax),%eax
  80038c:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80038f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800392:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800396:	79 90                	jns    800328 <vprintfmt+0x39>
				width = precision, precision = -1;
  800398:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80039b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80039e:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8003a5:	eb 81                	jmp    800328 <vprintfmt+0x39>
  8003a7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003aa:	85 c0                	test   %eax,%eax
  8003ac:	ba 00 00 00 00       	mov    $0x0,%edx
  8003b1:	0f 49 d0             	cmovns %eax,%edx
  8003b4:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003b7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003ba:	e9 69 ff ff ff       	jmp    800328 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8003bf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8003c2:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8003c9:	e9 5a ff ff ff       	jmp    800328 <vprintfmt+0x39>
  8003ce:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003d1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003d4:	eb bc                	jmp    800392 <vprintfmt+0xa3>
			lflag++;
  8003d6:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8003d9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003dc:	e9 47 ff ff ff       	jmp    800328 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  8003e1:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e4:	8d 78 04             	lea    0x4(%eax),%edi
  8003e7:	83 ec 08             	sub    $0x8,%esp
  8003ea:	53                   	push   %ebx
  8003eb:	ff 30                	pushl  (%eax)
  8003ed:	ff d6                	call   *%esi
			break;
  8003ef:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8003f2:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8003f5:	e9 da 02 00 00       	jmp    8006d4 <vprintfmt+0x3e5>
			err = va_arg(ap, int);
  8003fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8003fd:	8d 78 04             	lea    0x4(%eax),%edi
  800400:	8b 00                	mov    (%eax),%eax
  800402:	99                   	cltd   
  800403:	31 d0                	xor    %edx,%eax
  800405:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800407:	83 f8 08             	cmp    $0x8,%eax
  80040a:	7f 23                	jg     80042f <vprintfmt+0x140>
  80040c:	8b 14 85 c0 16 80 00 	mov    0x8016c0(,%eax,4),%edx
  800413:	85 d2                	test   %edx,%edx
  800415:	74 18                	je     80042f <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  800417:	52                   	push   %edx
  800418:	68 c1 14 80 00       	push   $0x8014c1
  80041d:	53                   	push   %ebx
  80041e:	56                   	push   %esi
  80041f:	e8 aa fe ff ff       	call   8002ce <printfmt>
  800424:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800427:	89 7d 14             	mov    %edi,0x14(%ebp)
  80042a:	e9 a5 02 00 00       	jmp    8006d4 <vprintfmt+0x3e5>
				printfmt(putch, putdat, "error %d", err);
  80042f:	50                   	push   %eax
  800430:	68 b8 14 80 00       	push   $0x8014b8
  800435:	53                   	push   %ebx
  800436:	56                   	push   %esi
  800437:	e8 92 fe ff ff       	call   8002ce <printfmt>
  80043c:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80043f:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800442:	e9 8d 02 00 00       	jmp    8006d4 <vprintfmt+0x3e5>
			if ((p = va_arg(ap, char *)) == NULL)
  800447:	8b 45 14             	mov    0x14(%ebp),%eax
  80044a:	83 c0 04             	add    $0x4,%eax
  80044d:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800450:	8b 45 14             	mov    0x14(%ebp),%eax
  800453:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  800455:	85 d2                	test   %edx,%edx
  800457:	b8 b1 14 80 00       	mov    $0x8014b1,%eax
  80045c:	0f 45 c2             	cmovne %edx,%eax
  80045f:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  800462:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800466:	7e 06                	jle    80046e <vprintfmt+0x17f>
  800468:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  80046c:	75 0d                	jne    80047b <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  80046e:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800471:	89 c7                	mov    %eax,%edi
  800473:	03 45 e0             	add    -0x20(%ebp),%eax
  800476:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800479:	eb 55                	jmp    8004d0 <vprintfmt+0x1e1>
  80047b:	83 ec 08             	sub    $0x8,%esp
  80047e:	ff 75 d8             	pushl  -0x28(%ebp)
  800481:	ff 75 cc             	pushl  -0x34(%ebp)
  800484:	e8 85 03 00 00       	call   80080e <strnlen>
  800489:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80048c:	29 c2                	sub    %eax,%edx
  80048e:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  800491:	83 c4 10             	add    $0x10,%esp
  800494:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  800496:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  80049a:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  80049d:	85 ff                	test   %edi,%edi
  80049f:	7e 11                	jle    8004b2 <vprintfmt+0x1c3>
					putch(padc, putdat);
  8004a1:	83 ec 08             	sub    $0x8,%esp
  8004a4:	53                   	push   %ebx
  8004a5:	ff 75 e0             	pushl  -0x20(%ebp)
  8004a8:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8004aa:	83 ef 01             	sub    $0x1,%edi
  8004ad:	83 c4 10             	add    $0x10,%esp
  8004b0:	eb eb                	jmp    80049d <vprintfmt+0x1ae>
  8004b2:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8004b5:	85 d2                	test   %edx,%edx
  8004b7:	b8 00 00 00 00       	mov    $0x0,%eax
  8004bc:	0f 49 c2             	cmovns %edx,%eax
  8004bf:	29 c2                	sub    %eax,%edx
  8004c1:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8004c4:	eb a8                	jmp    80046e <vprintfmt+0x17f>
					putch(ch, putdat);
  8004c6:	83 ec 08             	sub    $0x8,%esp
  8004c9:	53                   	push   %ebx
  8004ca:	52                   	push   %edx
  8004cb:	ff d6                	call   *%esi
  8004cd:	83 c4 10             	add    $0x10,%esp
  8004d0:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004d3:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004d5:	83 c7 01             	add    $0x1,%edi
  8004d8:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004dc:	0f be d0             	movsbl %al,%edx
  8004df:	85 d2                	test   %edx,%edx
  8004e1:	74 4b                	je     80052e <vprintfmt+0x23f>
  8004e3:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004e7:	78 06                	js     8004ef <vprintfmt+0x200>
  8004e9:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8004ed:	78 1e                	js     80050d <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
  8004ef:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8004f3:	74 d1                	je     8004c6 <vprintfmt+0x1d7>
  8004f5:	0f be c0             	movsbl %al,%eax
  8004f8:	83 e8 20             	sub    $0x20,%eax
  8004fb:	83 f8 5e             	cmp    $0x5e,%eax
  8004fe:	76 c6                	jbe    8004c6 <vprintfmt+0x1d7>
					putch('?', putdat);
  800500:	83 ec 08             	sub    $0x8,%esp
  800503:	53                   	push   %ebx
  800504:	6a 3f                	push   $0x3f
  800506:	ff d6                	call   *%esi
  800508:	83 c4 10             	add    $0x10,%esp
  80050b:	eb c3                	jmp    8004d0 <vprintfmt+0x1e1>
  80050d:	89 cf                	mov    %ecx,%edi
  80050f:	eb 0e                	jmp    80051f <vprintfmt+0x230>
				putch(' ', putdat);
  800511:	83 ec 08             	sub    $0x8,%esp
  800514:	53                   	push   %ebx
  800515:	6a 20                	push   $0x20
  800517:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800519:	83 ef 01             	sub    $0x1,%edi
  80051c:	83 c4 10             	add    $0x10,%esp
  80051f:	85 ff                	test   %edi,%edi
  800521:	7f ee                	jg     800511 <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  800523:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800526:	89 45 14             	mov    %eax,0x14(%ebp)
  800529:	e9 a6 01 00 00       	jmp    8006d4 <vprintfmt+0x3e5>
  80052e:	89 cf                	mov    %ecx,%edi
  800530:	eb ed                	jmp    80051f <vprintfmt+0x230>
	if (lflag >= 2)
  800532:	83 f9 01             	cmp    $0x1,%ecx
  800535:	7f 1f                	jg     800556 <vprintfmt+0x267>
	else if (lflag)
  800537:	85 c9                	test   %ecx,%ecx
  800539:	74 67                	je     8005a2 <vprintfmt+0x2b3>
		return va_arg(*ap, long);
  80053b:	8b 45 14             	mov    0x14(%ebp),%eax
  80053e:	8b 00                	mov    (%eax),%eax
  800540:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800543:	89 c1                	mov    %eax,%ecx
  800545:	c1 f9 1f             	sar    $0x1f,%ecx
  800548:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80054b:	8b 45 14             	mov    0x14(%ebp),%eax
  80054e:	8d 40 04             	lea    0x4(%eax),%eax
  800551:	89 45 14             	mov    %eax,0x14(%ebp)
  800554:	eb 17                	jmp    80056d <vprintfmt+0x27e>
		return va_arg(*ap, long long);
  800556:	8b 45 14             	mov    0x14(%ebp),%eax
  800559:	8b 50 04             	mov    0x4(%eax),%edx
  80055c:	8b 00                	mov    (%eax),%eax
  80055e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800561:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800564:	8b 45 14             	mov    0x14(%ebp),%eax
  800567:	8d 40 08             	lea    0x8(%eax),%eax
  80056a:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80056d:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800570:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800573:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  800578:	85 c9                	test   %ecx,%ecx
  80057a:	0f 89 3a 01 00 00    	jns    8006ba <vprintfmt+0x3cb>
				putch('-', putdat);
  800580:	83 ec 08             	sub    $0x8,%esp
  800583:	53                   	push   %ebx
  800584:	6a 2d                	push   $0x2d
  800586:	ff d6                	call   *%esi
				num = -(long long) num;
  800588:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80058b:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80058e:	f7 da                	neg    %edx
  800590:	83 d1 00             	adc    $0x0,%ecx
  800593:	f7 d9                	neg    %ecx
  800595:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800598:	b8 0a 00 00 00       	mov    $0xa,%eax
  80059d:	e9 18 01 00 00       	jmp    8006ba <vprintfmt+0x3cb>
		return va_arg(*ap, int);
  8005a2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a5:	8b 00                	mov    (%eax),%eax
  8005a7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005aa:	89 c1                	mov    %eax,%ecx
  8005ac:	c1 f9 1f             	sar    $0x1f,%ecx
  8005af:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b5:	8d 40 04             	lea    0x4(%eax),%eax
  8005b8:	89 45 14             	mov    %eax,0x14(%ebp)
  8005bb:	eb b0                	jmp    80056d <vprintfmt+0x27e>
	if (lflag >= 2)
  8005bd:	83 f9 01             	cmp    $0x1,%ecx
  8005c0:	7f 1e                	jg     8005e0 <vprintfmt+0x2f1>
	else if (lflag)
  8005c2:	85 c9                	test   %ecx,%ecx
  8005c4:	74 32                	je     8005f8 <vprintfmt+0x309>
		return va_arg(*ap, unsigned long);
  8005c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c9:	8b 10                	mov    (%eax),%edx
  8005cb:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005d0:	8d 40 04             	lea    0x4(%eax),%eax
  8005d3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005d6:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  8005db:	e9 da 00 00 00       	jmp    8006ba <vprintfmt+0x3cb>
		return va_arg(*ap, unsigned long long);
  8005e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e3:	8b 10                	mov    (%eax),%edx
  8005e5:	8b 48 04             	mov    0x4(%eax),%ecx
  8005e8:	8d 40 08             	lea    0x8(%eax),%eax
  8005eb:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005ee:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  8005f3:	e9 c2 00 00 00       	jmp    8006ba <vprintfmt+0x3cb>
		return va_arg(*ap, unsigned int);
  8005f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fb:	8b 10                	mov    (%eax),%edx
  8005fd:	b9 00 00 00 00       	mov    $0x0,%ecx
  800602:	8d 40 04             	lea    0x4(%eax),%eax
  800605:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800608:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  80060d:	e9 a8 00 00 00       	jmp    8006ba <vprintfmt+0x3cb>
	if (lflag >= 2)
  800612:	83 f9 01             	cmp    $0x1,%ecx
  800615:	7f 1b                	jg     800632 <vprintfmt+0x343>
	else if (lflag)
  800617:	85 c9                	test   %ecx,%ecx
  800619:	74 5c                	je     800677 <vprintfmt+0x388>
		return va_arg(*ap, long);
  80061b:	8b 45 14             	mov    0x14(%ebp),%eax
  80061e:	8b 00                	mov    (%eax),%eax
  800620:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800623:	99                   	cltd   
  800624:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800627:	8b 45 14             	mov    0x14(%ebp),%eax
  80062a:	8d 40 04             	lea    0x4(%eax),%eax
  80062d:	89 45 14             	mov    %eax,0x14(%ebp)
  800630:	eb 17                	jmp    800649 <vprintfmt+0x35a>
		return va_arg(*ap, long long);
  800632:	8b 45 14             	mov    0x14(%ebp),%eax
  800635:	8b 50 04             	mov    0x4(%eax),%edx
  800638:	8b 00                	mov    (%eax),%eax
  80063a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80063d:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800640:	8b 45 14             	mov    0x14(%ebp),%eax
  800643:	8d 40 08             	lea    0x8(%eax),%eax
  800646:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800649:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80064c:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 8;
  80064f:	b8 08 00 00 00       	mov    $0x8,%eax
			if ((long long) num < 0) {
  800654:	85 c9                	test   %ecx,%ecx
  800656:	79 62                	jns    8006ba <vprintfmt+0x3cb>
				putch('-', putdat);
  800658:	83 ec 08             	sub    $0x8,%esp
  80065b:	53                   	push   %ebx
  80065c:	6a 2d                	push   $0x2d
  80065e:	ff d6                	call   *%esi
				num = -(long long) num;
  800660:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800663:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800666:	f7 da                	neg    %edx
  800668:	83 d1 00             	adc    $0x0,%ecx
  80066b:	f7 d9                	neg    %ecx
  80066d:	83 c4 10             	add    $0x10,%esp
			base = 8;
  800670:	b8 08 00 00 00       	mov    $0x8,%eax
  800675:	eb 43                	jmp    8006ba <vprintfmt+0x3cb>
		return va_arg(*ap, int);
  800677:	8b 45 14             	mov    0x14(%ebp),%eax
  80067a:	8b 00                	mov    (%eax),%eax
  80067c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80067f:	89 c1                	mov    %eax,%ecx
  800681:	c1 f9 1f             	sar    $0x1f,%ecx
  800684:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800687:	8b 45 14             	mov    0x14(%ebp),%eax
  80068a:	8d 40 04             	lea    0x4(%eax),%eax
  80068d:	89 45 14             	mov    %eax,0x14(%ebp)
  800690:	eb b7                	jmp    800649 <vprintfmt+0x35a>
			putch('0', putdat);
  800692:	83 ec 08             	sub    $0x8,%esp
  800695:	53                   	push   %ebx
  800696:	6a 30                	push   $0x30
  800698:	ff d6                	call   *%esi
			putch('x', putdat);
  80069a:	83 c4 08             	add    $0x8,%esp
  80069d:	53                   	push   %ebx
  80069e:	6a 78                	push   $0x78
  8006a0:	ff d6                	call   *%esi
			num = (unsigned long long)
  8006a2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a5:	8b 10                	mov    (%eax),%edx
  8006a7:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8006ac:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8006af:	8d 40 04             	lea    0x4(%eax),%eax
  8006b2:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006b5:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  8006ba:	83 ec 0c             	sub    $0xc,%esp
  8006bd:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  8006c1:	57                   	push   %edi
  8006c2:	ff 75 e0             	pushl  -0x20(%ebp)
  8006c5:	50                   	push   %eax
  8006c6:	51                   	push   %ecx
  8006c7:	52                   	push   %edx
  8006c8:	89 da                	mov    %ebx,%edx
  8006ca:	89 f0                	mov    %esi,%eax
  8006cc:	e8 33 fb ff ff       	call   800204 <printnum>
			break;
  8006d1:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  8006d4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006d7:	83 c7 01             	add    $0x1,%edi
  8006da:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8006de:	83 f8 25             	cmp    $0x25,%eax
  8006e1:	0f 84 23 fc ff ff    	je     80030a <vprintfmt+0x1b>
			if (ch == '\0')
  8006e7:	85 c0                	test   %eax,%eax
  8006e9:	0f 84 8b 00 00 00    	je     80077a <vprintfmt+0x48b>
			putch(ch, putdat);
  8006ef:	83 ec 08             	sub    $0x8,%esp
  8006f2:	53                   	push   %ebx
  8006f3:	50                   	push   %eax
  8006f4:	ff d6                	call   *%esi
  8006f6:	83 c4 10             	add    $0x10,%esp
  8006f9:	eb dc                	jmp    8006d7 <vprintfmt+0x3e8>
	if (lflag >= 2)
  8006fb:	83 f9 01             	cmp    $0x1,%ecx
  8006fe:	7f 1b                	jg     80071b <vprintfmt+0x42c>
	else if (lflag)
  800700:	85 c9                	test   %ecx,%ecx
  800702:	74 2c                	je     800730 <vprintfmt+0x441>
		return va_arg(*ap, unsigned long);
  800704:	8b 45 14             	mov    0x14(%ebp),%eax
  800707:	8b 10                	mov    (%eax),%edx
  800709:	b9 00 00 00 00       	mov    $0x0,%ecx
  80070e:	8d 40 04             	lea    0x4(%eax),%eax
  800711:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800714:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  800719:	eb 9f                	jmp    8006ba <vprintfmt+0x3cb>
		return va_arg(*ap, unsigned long long);
  80071b:	8b 45 14             	mov    0x14(%ebp),%eax
  80071e:	8b 10                	mov    (%eax),%edx
  800720:	8b 48 04             	mov    0x4(%eax),%ecx
  800723:	8d 40 08             	lea    0x8(%eax),%eax
  800726:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800729:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  80072e:	eb 8a                	jmp    8006ba <vprintfmt+0x3cb>
		return va_arg(*ap, unsigned int);
  800730:	8b 45 14             	mov    0x14(%ebp),%eax
  800733:	8b 10                	mov    (%eax),%edx
  800735:	b9 00 00 00 00       	mov    $0x0,%ecx
  80073a:	8d 40 04             	lea    0x4(%eax),%eax
  80073d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800740:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  800745:	e9 70 ff ff ff       	jmp    8006ba <vprintfmt+0x3cb>
			putch(ch, putdat);
  80074a:	83 ec 08             	sub    $0x8,%esp
  80074d:	53                   	push   %ebx
  80074e:	6a 25                	push   $0x25
  800750:	ff d6                	call   *%esi
			break;
  800752:	83 c4 10             	add    $0x10,%esp
  800755:	e9 7a ff ff ff       	jmp    8006d4 <vprintfmt+0x3e5>
			putch('%', putdat);
  80075a:	83 ec 08             	sub    $0x8,%esp
  80075d:	53                   	push   %ebx
  80075e:	6a 25                	push   $0x25
  800760:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800762:	83 c4 10             	add    $0x10,%esp
  800765:	89 f8                	mov    %edi,%eax
  800767:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80076b:	74 05                	je     800772 <vprintfmt+0x483>
  80076d:	83 e8 01             	sub    $0x1,%eax
  800770:	eb f5                	jmp    800767 <vprintfmt+0x478>
  800772:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800775:	e9 5a ff ff ff       	jmp    8006d4 <vprintfmt+0x3e5>
}
  80077a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80077d:	5b                   	pop    %ebx
  80077e:	5e                   	pop    %esi
  80077f:	5f                   	pop    %edi
  800780:	5d                   	pop    %ebp
  800781:	c3                   	ret    

00800782 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800782:	f3 0f 1e fb          	endbr32 
  800786:	55                   	push   %ebp
  800787:	89 e5                	mov    %esp,%ebp
  800789:	83 ec 18             	sub    $0x18,%esp
  80078c:	8b 45 08             	mov    0x8(%ebp),%eax
  80078f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800792:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800795:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800799:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80079c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007a3:	85 c0                	test   %eax,%eax
  8007a5:	74 26                	je     8007cd <vsnprintf+0x4b>
  8007a7:	85 d2                	test   %edx,%edx
  8007a9:	7e 22                	jle    8007cd <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007ab:	ff 75 14             	pushl  0x14(%ebp)
  8007ae:	ff 75 10             	pushl  0x10(%ebp)
  8007b1:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007b4:	50                   	push   %eax
  8007b5:	68 ad 02 80 00       	push   $0x8002ad
  8007ba:	e8 30 fb ff ff       	call   8002ef <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007bf:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007c2:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007c8:	83 c4 10             	add    $0x10,%esp
}
  8007cb:	c9                   	leave  
  8007cc:	c3                   	ret    
		return -E_INVAL;
  8007cd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007d2:	eb f7                	jmp    8007cb <vsnprintf+0x49>

008007d4 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007d4:	f3 0f 1e fb          	endbr32 
  8007d8:	55                   	push   %ebp
  8007d9:	89 e5                	mov    %esp,%ebp
  8007db:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007de:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007e1:	50                   	push   %eax
  8007e2:	ff 75 10             	pushl  0x10(%ebp)
  8007e5:	ff 75 0c             	pushl  0xc(%ebp)
  8007e8:	ff 75 08             	pushl  0x8(%ebp)
  8007eb:	e8 92 ff ff ff       	call   800782 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007f0:	c9                   	leave  
  8007f1:	c3                   	ret    

008007f2 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007f2:	f3 0f 1e fb          	endbr32 
  8007f6:	55                   	push   %ebp
  8007f7:	89 e5                	mov    %esp,%ebp
  8007f9:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007fc:	b8 00 00 00 00       	mov    $0x0,%eax
  800801:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800805:	74 05                	je     80080c <strlen+0x1a>
		n++;
  800807:	83 c0 01             	add    $0x1,%eax
  80080a:	eb f5                	jmp    800801 <strlen+0xf>
	return n;
}
  80080c:	5d                   	pop    %ebp
  80080d:	c3                   	ret    

0080080e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80080e:	f3 0f 1e fb          	endbr32 
  800812:	55                   	push   %ebp
  800813:	89 e5                	mov    %esp,%ebp
  800815:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800818:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80081b:	b8 00 00 00 00       	mov    $0x0,%eax
  800820:	39 d0                	cmp    %edx,%eax
  800822:	74 0d                	je     800831 <strnlen+0x23>
  800824:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800828:	74 05                	je     80082f <strnlen+0x21>
		n++;
  80082a:	83 c0 01             	add    $0x1,%eax
  80082d:	eb f1                	jmp    800820 <strnlen+0x12>
  80082f:	89 c2                	mov    %eax,%edx
	return n;
}
  800831:	89 d0                	mov    %edx,%eax
  800833:	5d                   	pop    %ebp
  800834:	c3                   	ret    

00800835 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800835:	f3 0f 1e fb          	endbr32 
  800839:	55                   	push   %ebp
  80083a:	89 e5                	mov    %esp,%ebp
  80083c:	53                   	push   %ebx
  80083d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800840:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800843:	b8 00 00 00 00       	mov    $0x0,%eax
  800848:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  80084c:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  80084f:	83 c0 01             	add    $0x1,%eax
  800852:	84 d2                	test   %dl,%dl
  800854:	75 f2                	jne    800848 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  800856:	89 c8                	mov    %ecx,%eax
  800858:	5b                   	pop    %ebx
  800859:	5d                   	pop    %ebp
  80085a:	c3                   	ret    

0080085b <strcat>:

char *
strcat(char *dst, const char *src)
{
  80085b:	f3 0f 1e fb          	endbr32 
  80085f:	55                   	push   %ebp
  800860:	89 e5                	mov    %esp,%ebp
  800862:	53                   	push   %ebx
  800863:	83 ec 10             	sub    $0x10,%esp
  800866:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800869:	53                   	push   %ebx
  80086a:	e8 83 ff ff ff       	call   8007f2 <strlen>
  80086f:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800872:	ff 75 0c             	pushl  0xc(%ebp)
  800875:	01 d8                	add    %ebx,%eax
  800877:	50                   	push   %eax
  800878:	e8 b8 ff ff ff       	call   800835 <strcpy>
	return dst;
}
  80087d:	89 d8                	mov    %ebx,%eax
  80087f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800882:	c9                   	leave  
  800883:	c3                   	ret    

00800884 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800884:	f3 0f 1e fb          	endbr32 
  800888:	55                   	push   %ebp
  800889:	89 e5                	mov    %esp,%ebp
  80088b:	56                   	push   %esi
  80088c:	53                   	push   %ebx
  80088d:	8b 75 08             	mov    0x8(%ebp),%esi
  800890:	8b 55 0c             	mov    0xc(%ebp),%edx
  800893:	89 f3                	mov    %esi,%ebx
  800895:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800898:	89 f0                	mov    %esi,%eax
  80089a:	39 d8                	cmp    %ebx,%eax
  80089c:	74 11                	je     8008af <strncpy+0x2b>
		*dst++ = *src;
  80089e:	83 c0 01             	add    $0x1,%eax
  8008a1:	0f b6 0a             	movzbl (%edx),%ecx
  8008a4:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008a7:	80 f9 01             	cmp    $0x1,%cl
  8008aa:	83 da ff             	sbb    $0xffffffff,%edx
  8008ad:	eb eb                	jmp    80089a <strncpy+0x16>
	}
	return ret;
}
  8008af:	89 f0                	mov    %esi,%eax
  8008b1:	5b                   	pop    %ebx
  8008b2:	5e                   	pop    %esi
  8008b3:	5d                   	pop    %ebp
  8008b4:	c3                   	ret    

008008b5 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008b5:	f3 0f 1e fb          	endbr32 
  8008b9:	55                   	push   %ebp
  8008ba:	89 e5                	mov    %esp,%ebp
  8008bc:	56                   	push   %esi
  8008bd:	53                   	push   %ebx
  8008be:	8b 75 08             	mov    0x8(%ebp),%esi
  8008c1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008c4:	8b 55 10             	mov    0x10(%ebp),%edx
  8008c7:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008c9:	85 d2                	test   %edx,%edx
  8008cb:	74 21                	je     8008ee <strlcpy+0x39>
  8008cd:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8008d1:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  8008d3:	39 c2                	cmp    %eax,%edx
  8008d5:	74 14                	je     8008eb <strlcpy+0x36>
  8008d7:	0f b6 19             	movzbl (%ecx),%ebx
  8008da:	84 db                	test   %bl,%bl
  8008dc:	74 0b                	je     8008e9 <strlcpy+0x34>
			*dst++ = *src++;
  8008de:	83 c1 01             	add    $0x1,%ecx
  8008e1:	83 c2 01             	add    $0x1,%edx
  8008e4:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008e7:	eb ea                	jmp    8008d3 <strlcpy+0x1e>
  8008e9:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  8008eb:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008ee:	29 f0                	sub    %esi,%eax
}
  8008f0:	5b                   	pop    %ebx
  8008f1:	5e                   	pop    %esi
  8008f2:	5d                   	pop    %ebp
  8008f3:	c3                   	ret    

008008f4 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008f4:	f3 0f 1e fb          	endbr32 
  8008f8:	55                   	push   %ebp
  8008f9:	89 e5                	mov    %esp,%ebp
  8008fb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008fe:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800901:	0f b6 01             	movzbl (%ecx),%eax
  800904:	84 c0                	test   %al,%al
  800906:	74 0c                	je     800914 <strcmp+0x20>
  800908:	3a 02                	cmp    (%edx),%al
  80090a:	75 08                	jne    800914 <strcmp+0x20>
		p++, q++;
  80090c:	83 c1 01             	add    $0x1,%ecx
  80090f:	83 c2 01             	add    $0x1,%edx
  800912:	eb ed                	jmp    800901 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800914:	0f b6 c0             	movzbl %al,%eax
  800917:	0f b6 12             	movzbl (%edx),%edx
  80091a:	29 d0                	sub    %edx,%eax
}
  80091c:	5d                   	pop    %ebp
  80091d:	c3                   	ret    

0080091e <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80091e:	f3 0f 1e fb          	endbr32 
  800922:	55                   	push   %ebp
  800923:	89 e5                	mov    %esp,%ebp
  800925:	53                   	push   %ebx
  800926:	8b 45 08             	mov    0x8(%ebp),%eax
  800929:	8b 55 0c             	mov    0xc(%ebp),%edx
  80092c:	89 c3                	mov    %eax,%ebx
  80092e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800931:	eb 06                	jmp    800939 <strncmp+0x1b>
		n--, p++, q++;
  800933:	83 c0 01             	add    $0x1,%eax
  800936:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800939:	39 d8                	cmp    %ebx,%eax
  80093b:	74 16                	je     800953 <strncmp+0x35>
  80093d:	0f b6 08             	movzbl (%eax),%ecx
  800940:	84 c9                	test   %cl,%cl
  800942:	74 04                	je     800948 <strncmp+0x2a>
  800944:	3a 0a                	cmp    (%edx),%cl
  800946:	74 eb                	je     800933 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800948:	0f b6 00             	movzbl (%eax),%eax
  80094b:	0f b6 12             	movzbl (%edx),%edx
  80094e:	29 d0                	sub    %edx,%eax
}
  800950:	5b                   	pop    %ebx
  800951:	5d                   	pop    %ebp
  800952:	c3                   	ret    
		return 0;
  800953:	b8 00 00 00 00       	mov    $0x0,%eax
  800958:	eb f6                	jmp    800950 <strncmp+0x32>

0080095a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80095a:	f3 0f 1e fb          	endbr32 
  80095e:	55                   	push   %ebp
  80095f:	89 e5                	mov    %esp,%ebp
  800961:	8b 45 08             	mov    0x8(%ebp),%eax
  800964:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800968:	0f b6 10             	movzbl (%eax),%edx
  80096b:	84 d2                	test   %dl,%dl
  80096d:	74 09                	je     800978 <strchr+0x1e>
		if (*s == c)
  80096f:	38 ca                	cmp    %cl,%dl
  800971:	74 0a                	je     80097d <strchr+0x23>
	for (; *s; s++)
  800973:	83 c0 01             	add    $0x1,%eax
  800976:	eb f0                	jmp    800968 <strchr+0xe>
			return (char *) s;
	return 0;
  800978:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80097d:	5d                   	pop    %ebp
  80097e:	c3                   	ret    

0080097f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80097f:	f3 0f 1e fb          	endbr32 
  800983:	55                   	push   %ebp
  800984:	89 e5                	mov    %esp,%ebp
  800986:	8b 45 08             	mov    0x8(%ebp),%eax
  800989:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80098d:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800990:	38 ca                	cmp    %cl,%dl
  800992:	74 09                	je     80099d <strfind+0x1e>
  800994:	84 d2                	test   %dl,%dl
  800996:	74 05                	je     80099d <strfind+0x1e>
	for (; *s; s++)
  800998:	83 c0 01             	add    $0x1,%eax
  80099b:	eb f0                	jmp    80098d <strfind+0xe>
			break;
	return (char *) s;
}
  80099d:	5d                   	pop    %ebp
  80099e:	c3                   	ret    

0080099f <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80099f:	f3 0f 1e fb          	endbr32 
  8009a3:	55                   	push   %ebp
  8009a4:	89 e5                	mov    %esp,%ebp
  8009a6:	57                   	push   %edi
  8009a7:	56                   	push   %esi
  8009a8:	53                   	push   %ebx
  8009a9:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009ac:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009af:	85 c9                	test   %ecx,%ecx
  8009b1:	74 31                	je     8009e4 <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009b3:	89 f8                	mov    %edi,%eax
  8009b5:	09 c8                	or     %ecx,%eax
  8009b7:	a8 03                	test   $0x3,%al
  8009b9:	75 23                	jne    8009de <memset+0x3f>
		c &= 0xFF;
  8009bb:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009bf:	89 d3                	mov    %edx,%ebx
  8009c1:	c1 e3 08             	shl    $0x8,%ebx
  8009c4:	89 d0                	mov    %edx,%eax
  8009c6:	c1 e0 18             	shl    $0x18,%eax
  8009c9:	89 d6                	mov    %edx,%esi
  8009cb:	c1 e6 10             	shl    $0x10,%esi
  8009ce:	09 f0                	or     %esi,%eax
  8009d0:	09 c2                	or     %eax,%edx
  8009d2:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8009d4:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  8009d7:	89 d0                	mov    %edx,%eax
  8009d9:	fc                   	cld    
  8009da:	f3 ab                	rep stos %eax,%es:(%edi)
  8009dc:	eb 06                	jmp    8009e4 <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009de:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009e1:	fc                   	cld    
  8009e2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009e4:	89 f8                	mov    %edi,%eax
  8009e6:	5b                   	pop    %ebx
  8009e7:	5e                   	pop    %esi
  8009e8:	5f                   	pop    %edi
  8009e9:	5d                   	pop    %ebp
  8009ea:	c3                   	ret    

008009eb <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009eb:	f3 0f 1e fb          	endbr32 
  8009ef:	55                   	push   %ebp
  8009f0:	89 e5                	mov    %esp,%ebp
  8009f2:	57                   	push   %edi
  8009f3:	56                   	push   %esi
  8009f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f7:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009fa:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009fd:	39 c6                	cmp    %eax,%esi
  8009ff:	73 32                	jae    800a33 <memmove+0x48>
  800a01:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a04:	39 c2                	cmp    %eax,%edx
  800a06:	76 2b                	jbe    800a33 <memmove+0x48>
		s += n;
		d += n;
  800a08:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a0b:	89 fe                	mov    %edi,%esi
  800a0d:	09 ce                	or     %ecx,%esi
  800a0f:	09 d6                	or     %edx,%esi
  800a11:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a17:	75 0e                	jne    800a27 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a19:	83 ef 04             	sub    $0x4,%edi
  800a1c:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a1f:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800a22:	fd                   	std    
  800a23:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a25:	eb 09                	jmp    800a30 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a27:	83 ef 01             	sub    $0x1,%edi
  800a2a:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800a2d:	fd                   	std    
  800a2e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a30:	fc                   	cld    
  800a31:	eb 1a                	jmp    800a4d <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a33:	89 c2                	mov    %eax,%edx
  800a35:	09 ca                	or     %ecx,%edx
  800a37:	09 f2                	or     %esi,%edx
  800a39:	f6 c2 03             	test   $0x3,%dl
  800a3c:	75 0a                	jne    800a48 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a3e:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800a41:	89 c7                	mov    %eax,%edi
  800a43:	fc                   	cld    
  800a44:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a46:	eb 05                	jmp    800a4d <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800a48:	89 c7                	mov    %eax,%edi
  800a4a:	fc                   	cld    
  800a4b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a4d:	5e                   	pop    %esi
  800a4e:	5f                   	pop    %edi
  800a4f:	5d                   	pop    %ebp
  800a50:	c3                   	ret    

00800a51 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a51:	f3 0f 1e fb          	endbr32 
  800a55:	55                   	push   %ebp
  800a56:	89 e5                	mov    %esp,%ebp
  800a58:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a5b:	ff 75 10             	pushl  0x10(%ebp)
  800a5e:	ff 75 0c             	pushl  0xc(%ebp)
  800a61:	ff 75 08             	pushl  0x8(%ebp)
  800a64:	e8 82 ff ff ff       	call   8009eb <memmove>
}
  800a69:	c9                   	leave  
  800a6a:	c3                   	ret    

00800a6b <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a6b:	f3 0f 1e fb          	endbr32 
  800a6f:	55                   	push   %ebp
  800a70:	89 e5                	mov    %esp,%ebp
  800a72:	56                   	push   %esi
  800a73:	53                   	push   %ebx
  800a74:	8b 45 08             	mov    0x8(%ebp),%eax
  800a77:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a7a:	89 c6                	mov    %eax,%esi
  800a7c:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a7f:	39 f0                	cmp    %esi,%eax
  800a81:	74 1c                	je     800a9f <memcmp+0x34>
		if (*s1 != *s2)
  800a83:	0f b6 08             	movzbl (%eax),%ecx
  800a86:	0f b6 1a             	movzbl (%edx),%ebx
  800a89:	38 d9                	cmp    %bl,%cl
  800a8b:	75 08                	jne    800a95 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800a8d:	83 c0 01             	add    $0x1,%eax
  800a90:	83 c2 01             	add    $0x1,%edx
  800a93:	eb ea                	jmp    800a7f <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800a95:	0f b6 c1             	movzbl %cl,%eax
  800a98:	0f b6 db             	movzbl %bl,%ebx
  800a9b:	29 d8                	sub    %ebx,%eax
  800a9d:	eb 05                	jmp    800aa4 <memcmp+0x39>
	}

	return 0;
  800a9f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800aa4:	5b                   	pop    %ebx
  800aa5:	5e                   	pop    %esi
  800aa6:	5d                   	pop    %ebp
  800aa7:	c3                   	ret    

00800aa8 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800aa8:	f3 0f 1e fb          	endbr32 
  800aac:	55                   	push   %ebp
  800aad:	89 e5                	mov    %esp,%ebp
  800aaf:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800ab5:	89 c2                	mov    %eax,%edx
  800ab7:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800aba:	39 d0                	cmp    %edx,%eax
  800abc:	73 09                	jae    800ac7 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800abe:	38 08                	cmp    %cl,(%eax)
  800ac0:	74 05                	je     800ac7 <memfind+0x1f>
	for (; s < ends; s++)
  800ac2:	83 c0 01             	add    $0x1,%eax
  800ac5:	eb f3                	jmp    800aba <memfind+0x12>
			break;
	return (void *) s;
}
  800ac7:	5d                   	pop    %ebp
  800ac8:	c3                   	ret    

00800ac9 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ac9:	f3 0f 1e fb          	endbr32 
  800acd:	55                   	push   %ebp
  800ace:	89 e5                	mov    %esp,%ebp
  800ad0:	57                   	push   %edi
  800ad1:	56                   	push   %esi
  800ad2:	53                   	push   %ebx
  800ad3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ad6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ad9:	eb 03                	jmp    800ade <strtol+0x15>
		s++;
  800adb:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800ade:	0f b6 01             	movzbl (%ecx),%eax
  800ae1:	3c 20                	cmp    $0x20,%al
  800ae3:	74 f6                	je     800adb <strtol+0x12>
  800ae5:	3c 09                	cmp    $0x9,%al
  800ae7:	74 f2                	je     800adb <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800ae9:	3c 2b                	cmp    $0x2b,%al
  800aeb:	74 2a                	je     800b17 <strtol+0x4e>
	int neg = 0;
  800aed:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800af2:	3c 2d                	cmp    $0x2d,%al
  800af4:	74 2b                	je     800b21 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800af6:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800afc:	75 0f                	jne    800b0d <strtol+0x44>
  800afe:	80 39 30             	cmpb   $0x30,(%ecx)
  800b01:	74 28                	je     800b2b <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b03:	85 db                	test   %ebx,%ebx
  800b05:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b0a:	0f 44 d8             	cmove  %eax,%ebx
  800b0d:	b8 00 00 00 00       	mov    $0x0,%eax
  800b12:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800b15:	eb 46                	jmp    800b5d <strtol+0x94>
		s++;
  800b17:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800b1a:	bf 00 00 00 00       	mov    $0x0,%edi
  800b1f:	eb d5                	jmp    800af6 <strtol+0x2d>
		s++, neg = 1;
  800b21:	83 c1 01             	add    $0x1,%ecx
  800b24:	bf 01 00 00 00       	mov    $0x1,%edi
  800b29:	eb cb                	jmp    800af6 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b2b:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b2f:	74 0e                	je     800b3f <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800b31:	85 db                	test   %ebx,%ebx
  800b33:	75 d8                	jne    800b0d <strtol+0x44>
		s++, base = 8;
  800b35:	83 c1 01             	add    $0x1,%ecx
  800b38:	bb 08 00 00 00       	mov    $0x8,%ebx
  800b3d:	eb ce                	jmp    800b0d <strtol+0x44>
		s += 2, base = 16;
  800b3f:	83 c1 02             	add    $0x2,%ecx
  800b42:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b47:	eb c4                	jmp    800b0d <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800b49:	0f be d2             	movsbl %dl,%edx
  800b4c:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b4f:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b52:	7d 3a                	jge    800b8e <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800b54:	83 c1 01             	add    $0x1,%ecx
  800b57:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b5b:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800b5d:	0f b6 11             	movzbl (%ecx),%edx
  800b60:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b63:	89 f3                	mov    %esi,%ebx
  800b65:	80 fb 09             	cmp    $0x9,%bl
  800b68:	76 df                	jbe    800b49 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800b6a:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b6d:	89 f3                	mov    %esi,%ebx
  800b6f:	80 fb 19             	cmp    $0x19,%bl
  800b72:	77 08                	ja     800b7c <strtol+0xb3>
			dig = *s - 'a' + 10;
  800b74:	0f be d2             	movsbl %dl,%edx
  800b77:	83 ea 57             	sub    $0x57,%edx
  800b7a:	eb d3                	jmp    800b4f <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800b7c:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b7f:	89 f3                	mov    %esi,%ebx
  800b81:	80 fb 19             	cmp    $0x19,%bl
  800b84:	77 08                	ja     800b8e <strtol+0xc5>
			dig = *s - 'A' + 10;
  800b86:	0f be d2             	movsbl %dl,%edx
  800b89:	83 ea 37             	sub    $0x37,%edx
  800b8c:	eb c1                	jmp    800b4f <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800b8e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b92:	74 05                	je     800b99 <strtol+0xd0>
		*endptr = (char *) s;
  800b94:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b97:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800b99:	89 c2                	mov    %eax,%edx
  800b9b:	f7 da                	neg    %edx
  800b9d:	85 ff                	test   %edi,%edi
  800b9f:	0f 45 c2             	cmovne %edx,%eax
}
  800ba2:	5b                   	pop    %ebx
  800ba3:	5e                   	pop    %esi
  800ba4:	5f                   	pop    %edi
  800ba5:	5d                   	pop    %ebp
  800ba6:	c3                   	ret    

00800ba7 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ba7:	f3 0f 1e fb          	endbr32 
  800bab:	55                   	push   %ebp
  800bac:	89 e5                	mov    %esp,%ebp
  800bae:	57                   	push   %edi
  800baf:	56                   	push   %esi
  800bb0:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bb1:	b8 00 00 00 00       	mov    $0x0,%eax
  800bb6:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bbc:	89 c3                	mov    %eax,%ebx
  800bbe:	89 c7                	mov    %eax,%edi
  800bc0:	89 c6                	mov    %eax,%esi
  800bc2:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bc4:	5b                   	pop    %ebx
  800bc5:	5e                   	pop    %esi
  800bc6:	5f                   	pop    %edi
  800bc7:	5d                   	pop    %ebp
  800bc8:	c3                   	ret    

00800bc9 <sys_cgetc>:

int
sys_cgetc(void)
{
  800bc9:	f3 0f 1e fb          	endbr32 
  800bcd:	55                   	push   %ebp
  800bce:	89 e5                	mov    %esp,%ebp
  800bd0:	57                   	push   %edi
  800bd1:	56                   	push   %esi
  800bd2:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bd3:	ba 00 00 00 00       	mov    $0x0,%edx
  800bd8:	b8 01 00 00 00       	mov    $0x1,%eax
  800bdd:	89 d1                	mov    %edx,%ecx
  800bdf:	89 d3                	mov    %edx,%ebx
  800be1:	89 d7                	mov    %edx,%edi
  800be3:	89 d6                	mov    %edx,%esi
  800be5:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800be7:	5b                   	pop    %ebx
  800be8:	5e                   	pop    %esi
  800be9:	5f                   	pop    %edi
  800bea:	5d                   	pop    %ebp
  800beb:	c3                   	ret    

00800bec <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bec:	f3 0f 1e fb          	endbr32 
  800bf0:	55                   	push   %ebp
  800bf1:	89 e5                	mov    %esp,%ebp
  800bf3:	57                   	push   %edi
  800bf4:	56                   	push   %esi
  800bf5:	53                   	push   %ebx
  800bf6:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800bf9:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bfe:	8b 55 08             	mov    0x8(%ebp),%edx
  800c01:	b8 03 00 00 00       	mov    $0x3,%eax
  800c06:	89 cb                	mov    %ecx,%ebx
  800c08:	89 cf                	mov    %ecx,%edi
  800c0a:	89 ce                	mov    %ecx,%esi
  800c0c:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c0e:	85 c0                	test   %eax,%eax
  800c10:	7f 08                	jg     800c1a <sys_env_destroy+0x2e>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c12:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c15:	5b                   	pop    %ebx
  800c16:	5e                   	pop    %esi
  800c17:	5f                   	pop    %edi
  800c18:	5d                   	pop    %ebp
  800c19:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c1a:	83 ec 0c             	sub    $0xc,%esp
  800c1d:	50                   	push   %eax
  800c1e:	6a 03                	push   $0x3
  800c20:	68 e4 16 80 00       	push   $0x8016e4
  800c25:	6a 23                	push   $0x23
  800c27:	68 01 17 80 00       	push   $0x801701
  800c2c:	e8 0d 05 00 00       	call   80113e <_panic>

00800c31 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c31:	f3 0f 1e fb          	endbr32 
  800c35:	55                   	push   %ebp
  800c36:	89 e5                	mov    %esp,%ebp
  800c38:	57                   	push   %edi
  800c39:	56                   	push   %esi
  800c3a:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c3b:	ba 00 00 00 00       	mov    $0x0,%edx
  800c40:	b8 02 00 00 00       	mov    $0x2,%eax
  800c45:	89 d1                	mov    %edx,%ecx
  800c47:	89 d3                	mov    %edx,%ebx
  800c49:	89 d7                	mov    %edx,%edi
  800c4b:	89 d6                	mov    %edx,%esi
  800c4d:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c4f:	5b                   	pop    %ebx
  800c50:	5e                   	pop    %esi
  800c51:	5f                   	pop    %edi
  800c52:	5d                   	pop    %ebp
  800c53:	c3                   	ret    

00800c54 <sys_yield>:

void
sys_yield(void)
{
  800c54:	f3 0f 1e fb          	endbr32 
  800c58:	55                   	push   %ebp
  800c59:	89 e5                	mov    %esp,%ebp
  800c5b:	57                   	push   %edi
  800c5c:	56                   	push   %esi
  800c5d:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c5e:	ba 00 00 00 00       	mov    $0x0,%edx
  800c63:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c68:	89 d1                	mov    %edx,%ecx
  800c6a:	89 d3                	mov    %edx,%ebx
  800c6c:	89 d7                	mov    %edx,%edi
  800c6e:	89 d6                	mov    %edx,%esi
  800c70:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c72:	5b                   	pop    %ebx
  800c73:	5e                   	pop    %esi
  800c74:	5f                   	pop    %edi
  800c75:	5d                   	pop    %ebp
  800c76:	c3                   	ret    

00800c77 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c77:	f3 0f 1e fb          	endbr32 
  800c7b:	55                   	push   %ebp
  800c7c:	89 e5                	mov    %esp,%ebp
  800c7e:	57                   	push   %edi
  800c7f:	56                   	push   %esi
  800c80:	53                   	push   %ebx
  800c81:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c84:	be 00 00 00 00       	mov    $0x0,%esi
  800c89:	8b 55 08             	mov    0x8(%ebp),%edx
  800c8c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c8f:	b8 04 00 00 00       	mov    $0x4,%eax
  800c94:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c97:	89 f7                	mov    %esi,%edi
  800c99:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c9b:	85 c0                	test   %eax,%eax
  800c9d:	7f 08                	jg     800ca7 <sys_page_alloc+0x30>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c9f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ca2:	5b                   	pop    %ebx
  800ca3:	5e                   	pop    %esi
  800ca4:	5f                   	pop    %edi
  800ca5:	5d                   	pop    %ebp
  800ca6:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca7:	83 ec 0c             	sub    $0xc,%esp
  800caa:	50                   	push   %eax
  800cab:	6a 04                	push   $0x4
  800cad:	68 e4 16 80 00       	push   $0x8016e4
  800cb2:	6a 23                	push   $0x23
  800cb4:	68 01 17 80 00       	push   $0x801701
  800cb9:	e8 80 04 00 00       	call   80113e <_panic>

00800cbe <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800cbe:	f3 0f 1e fb          	endbr32 
  800cc2:	55                   	push   %ebp
  800cc3:	89 e5                	mov    %esp,%ebp
  800cc5:	57                   	push   %edi
  800cc6:	56                   	push   %esi
  800cc7:	53                   	push   %ebx
  800cc8:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800ccb:	8b 55 08             	mov    0x8(%ebp),%edx
  800cce:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd1:	b8 05 00 00 00       	mov    $0x5,%eax
  800cd6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cd9:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cdc:	8b 75 18             	mov    0x18(%ebp),%esi
  800cdf:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ce1:	85 c0                	test   %eax,%eax
  800ce3:	7f 08                	jg     800ced <sys_page_map+0x2f>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800ce5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ce8:	5b                   	pop    %ebx
  800ce9:	5e                   	pop    %esi
  800cea:	5f                   	pop    %edi
  800ceb:	5d                   	pop    %ebp
  800cec:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ced:	83 ec 0c             	sub    $0xc,%esp
  800cf0:	50                   	push   %eax
  800cf1:	6a 05                	push   $0x5
  800cf3:	68 e4 16 80 00       	push   $0x8016e4
  800cf8:	6a 23                	push   $0x23
  800cfa:	68 01 17 80 00       	push   $0x801701
  800cff:	e8 3a 04 00 00       	call   80113e <_panic>

00800d04 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d04:	f3 0f 1e fb          	endbr32 
  800d08:	55                   	push   %ebp
  800d09:	89 e5                	mov    %esp,%ebp
  800d0b:	57                   	push   %edi
  800d0c:	56                   	push   %esi
  800d0d:	53                   	push   %ebx
  800d0e:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d11:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d16:	8b 55 08             	mov    0x8(%ebp),%edx
  800d19:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d1c:	b8 06 00 00 00       	mov    $0x6,%eax
  800d21:	89 df                	mov    %ebx,%edi
  800d23:	89 de                	mov    %ebx,%esi
  800d25:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d27:	85 c0                	test   %eax,%eax
  800d29:	7f 08                	jg     800d33 <sys_page_unmap+0x2f>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d2b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d2e:	5b                   	pop    %ebx
  800d2f:	5e                   	pop    %esi
  800d30:	5f                   	pop    %edi
  800d31:	5d                   	pop    %ebp
  800d32:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d33:	83 ec 0c             	sub    $0xc,%esp
  800d36:	50                   	push   %eax
  800d37:	6a 06                	push   $0x6
  800d39:	68 e4 16 80 00       	push   $0x8016e4
  800d3e:	6a 23                	push   $0x23
  800d40:	68 01 17 80 00       	push   $0x801701
  800d45:	e8 f4 03 00 00       	call   80113e <_panic>

00800d4a <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d4a:	f3 0f 1e fb          	endbr32 
  800d4e:	55                   	push   %ebp
  800d4f:	89 e5                	mov    %esp,%ebp
  800d51:	57                   	push   %edi
  800d52:	56                   	push   %esi
  800d53:	53                   	push   %ebx
  800d54:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d57:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d5c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d5f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d62:	b8 08 00 00 00       	mov    $0x8,%eax
  800d67:	89 df                	mov    %ebx,%edi
  800d69:	89 de                	mov    %ebx,%esi
  800d6b:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d6d:	85 c0                	test   %eax,%eax
  800d6f:	7f 08                	jg     800d79 <sys_env_set_status+0x2f>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d71:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d74:	5b                   	pop    %ebx
  800d75:	5e                   	pop    %esi
  800d76:	5f                   	pop    %edi
  800d77:	5d                   	pop    %ebp
  800d78:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d79:	83 ec 0c             	sub    $0xc,%esp
  800d7c:	50                   	push   %eax
  800d7d:	6a 08                	push   $0x8
  800d7f:	68 e4 16 80 00       	push   $0x8016e4
  800d84:	6a 23                	push   $0x23
  800d86:	68 01 17 80 00       	push   $0x801701
  800d8b:	e8 ae 03 00 00       	call   80113e <_panic>

00800d90 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d90:	f3 0f 1e fb          	endbr32 
  800d94:	55                   	push   %ebp
  800d95:	89 e5                	mov    %esp,%ebp
  800d97:	57                   	push   %edi
  800d98:	56                   	push   %esi
  800d99:	53                   	push   %ebx
  800d9a:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d9d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800da2:	8b 55 08             	mov    0x8(%ebp),%edx
  800da5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800da8:	b8 09 00 00 00       	mov    $0x9,%eax
  800dad:	89 df                	mov    %ebx,%edi
  800daf:	89 de                	mov    %ebx,%esi
  800db1:	cd 30                	int    $0x30
	if(check && ret > 0)
  800db3:	85 c0                	test   %eax,%eax
  800db5:	7f 08                	jg     800dbf <sys_env_set_pgfault_upcall+0x2f>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800db7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dba:	5b                   	pop    %ebx
  800dbb:	5e                   	pop    %esi
  800dbc:	5f                   	pop    %edi
  800dbd:	5d                   	pop    %ebp
  800dbe:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800dbf:	83 ec 0c             	sub    $0xc,%esp
  800dc2:	50                   	push   %eax
  800dc3:	6a 09                	push   $0x9
  800dc5:	68 e4 16 80 00       	push   $0x8016e4
  800dca:	6a 23                	push   $0x23
  800dcc:	68 01 17 80 00       	push   $0x801701
  800dd1:	e8 68 03 00 00       	call   80113e <_panic>

00800dd6 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800dd6:	f3 0f 1e fb          	endbr32 
  800dda:	55                   	push   %ebp
  800ddb:	89 e5                	mov    %esp,%ebp
  800ddd:	57                   	push   %edi
  800dde:	56                   	push   %esi
  800ddf:	53                   	push   %ebx
	asm volatile("int %1\n"
  800de0:	8b 55 08             	mov    0x8(%ebp),%edx
  800de3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800de6:	b8 0b 00 00 00       	mov    $0xb,%eax
  800deb:	be 00 00 00 00       	mov    $0x0,%esi
  800df0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800df3:	8b 7d 14             	mov    0x14(%ebp),%edi
  800df6:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800df8:	5b                   	pop    %ebx
  800df9:	5e                   	pop    %esi
  800dfa:	5f                   	pop    %edi
  800dfb:	5d                   	pop    %ebp
  800dfc:	c3                   	ret    

00800dfd <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800dfd:	f3 0f 1e fb          	endbr32 
  800e01:	55                   	push   %ebp
  800e02:	89 e5                	mov    %esp,%ebp
  800e04:	57                   	push   %edi
  800e05:	56                   	push   %esi
  800e06:	53                   	push   %ebx
  800e07:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e0a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e0f:	8b 55 08             	mov    0x8(%ebp),%edx
  800e12:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e17:	89 cb                	mov    %ecx,%ebx
  800e19:	89 cf                	mov    %ecx,%edi
  800e1b:	89 ce                	mov    %ecx,%esi
  800e1d:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e1f:	85 c0                	test   %eax,%eax
  800e21:	7f 08                	jg     800e2b <sys_ipc_recv+0x2e>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e23:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e26:	5b                   	pop    %ebx
  800e27:	5e                   	pop    %esi
  800e28:	5f                   	pop    %edi
  800e29:	5d                   	pop    %ebp
  800e2a:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e2b:	83 ec 0c             	sub    $0xc,%esp
  800e2e:	50                   	push   %eax
  800e2f:	6a 0c                	push   $0xc
  800e31:	68 e4 16 80 00       	push   $0x8016e4
  800e36:	6a 23                	push   $0x23
  800e38:	68 01 17 80 00       	push   $0x801701
  800e3d:	e8 fc 02 00 00       	call   80113e <_panic>

00800e42 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e42:	f3 0f 1e fb          	endbr32 
  800e46:	55                   	push   %ebp
  800e47:	89 e5                	mov    %esp,%ebp
  800e49:	53                   	push   %ebx
  800e4a:	83 ec 04             	sub    $0x4,%esp
  800e4d:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e50:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if(!(err & FEC_WR)){
  800e52:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e56:	74 74                	je     800ecc <pgfault+0x8a>
        panic("trapno is not FEC_WR");
    }
    if(!(uvpt[PGNUM(addr)] & PTE_COW)){
  800e58:	89 d8                	mov    %ebx,%eax
  800e5a:	c1 e8 0c             	shr    $0xc,%eax
  800e5d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800e64:	f6 c4 08             	test   $0x8,%ah
  800e67:	74 77                	je     800ee0 <pgfault+0x9e>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	addr = ROUNDDOWN(addr, PGSIZE);
  800e69:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
    if ((r = sys_page_map(0, addr, 0, PFTEMP, PTE_U | PTE_P)) < 0)
  800e6f:	83 ec 0c             	sub    $0xc,%esp
  800e72:	6a 05                	push   $0x5
  800e74:	68 00 f0 7f 00       	push   $0x7ff000
  800e79:	6a 00                	push   $0x0
  800e7b:	53                   	push   %ebx
  800e7c:	6a 00                	push   $0x0
  800e7e:	e8 3b fe ff ff       	call   800cbe <sys_page_map>
  800e83:	83 c4 20             	add    $0x20,%esp
  800e86:	85 c0                	test   %eax,%eax
  800e88:	78 6a                	js     800ef4 <pgfault+0xb2>
        panic("sys_page_map: %e", r);
    if ((r = sys_page_alloc(0, addr, PTE_W | PTE_U | PTE_P)) < 0)
  800e8a:	83 ec 04             	sub    $0x4,%esp
  800e8d:	6a 07                	push   $0x7
  800e8f:	53                   	push   %ebx
  800e90:	6a 00                	push   $0x0
  800e92:	e8 e0 fd ff ff       	call   800c77 <sys_page_alloc>
  800e97:	83 c4 10             	add    $0x10,%esp
  800e9a:	85 c0                	test   %eax,%eax
  800e9c:	78 68                	js     800f06 <pgfault+0xc4>
        panic("sys_page_alloc: %e", r);
    memmove(addr, PFTEMP, PGSIZE);
  800e9e:	83 ec 04             	sub    $0x4,%esp
  800ea1:	68 00 10 00 00       	push   $0x1000
  800ea6:	68 00 f0 7f 00       	push   $0x7ff000
  800eab:	53                   	push   %ebx
  800eac:	e8 3a fb ff ff       	call   8009eb <memmove>
    if ((r = sys_page_unmap(0, PFTEMP)) < 0)
  800eb1:	83 c4 08             	add    $0x8,%esp
  800eb4:	68 00 f0 7f 00       	push   $0x7ff000
  800eb9:	6a 00                	push   $0x0
  800ebb:	e8 44 fe ff ff       	call   800d04 <sys_page_unmap>
  800ec0:	83 c4 10             	add    $0x10,%esp
  800ec3:	85 c0                	test   %eax,%eax
  800ec5:	78 51                	js     800f18 <pgfault+0xd6>
        panic("sys_page_unmap: %e", r);

	//panic("pgfault not implemented");
}
  800ec7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800eca:	c9                   	leave  
  800ecb:	c3                   	ret    
        panic("trapno is not FEC_WR");
  800ecc:	83 ec 04             	sub    $0x4,%esp
  800ecf:	68 0f 17 80 00       	push   $0x80170f
  800ed4:	6a 1d                	push   $0x1d
  800ed6:	68 24 17 80 00       	push   $0x801724
  800edb:	e8 5e 02 00 00       	call   80113e <_panic>
        panic("fault addr is not COW");
  800ee0:	83 ec 04             	sub    $0x4,%esp
  800ee3:	68 2f 17 80 00       	push   $0x80172f
  800ee8:	6a 20                	push   $0x20
  800eea:	68 24 17 80 00       	push   $0x801724
  800eef:	e8 4a 02 00 00       	call   80113e <_panic>
        panic("sys_page_map: %e", r);
  800ef4:	50                   	push   %eax
  800ef5:	68 45 17 80 00       	push   $0x801745
  800efa:	6a 2c                	push   $0x2c
  800efc:	68 24 17 80 00       	push   $0x801724
  800f01:	e8 38 02 00 00       	call   80113e <_panic>
        panic("sys_page_alloc: %e", r);
  800f06:	50                   	push   %eax
  800f07:	68 56 17 80 00       	push   $0x801756
  800f0c:	6a 2e                	push   $0x2e
  800f0e:	68 24 17 80 00       	push   $0x801724
  800f13:	e8 26 02 00 00       	call   80113e <_panic>
        panic("sys_page_unmap: %e", r);
  800f18:	50                   	push   %eax
  800f19:	68 69 17 80 00       	push   $0x801769
  800f1e:	6a 31                	push   $0x31
  800f20:	68 24 17 80 00       	push   $0x801724
  800f25:	e8 14 02 00 00       	call   80113e <_panic>

00800f2a <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f2a:	f3 0f 1e fb          	endbr32 
  800f2e:	55                   	push   %ebp
  800f2f:	89 e5                	mov    %esp,%ebp
  800f31:	57                   	push   %edi
  800f32:	56                   	push   %esi
  800f33:	53                   	push   %ebx
  800f34:	83 ec 28             	sub    $0x28,%esp
    extern void _pgfault_upcall(void);

	set_pgfault_handler(pgfault);
  800f37:	68 42 0e 80 00       	push   $0x800e42
  800f3c:	e8 47 02 00 00       	call   801188 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800f41:	b8 07 00 00 00       	mov    $0x7,%eax
  800f46:	cd 30                	int    $0x30
  800f48:	89 45 e4             	mov    %eax,-0x1c(%ebp)

    envid_t envid = sys_exofork();
    if (envid < 0)
  800f4b:	83 c4 10             	add    $0x10,%esp
  800f4e:	85 c0                	test   %eax,%eax
  800f50:	78 2d                	js     800f7f <fork+0x55>
  800f52:	89 c7                	mov    %eax,%edi
        thisenv = &envs[ENVX(sys_getenvid())];
        return 0;
    }

    // Parent
    for(uint32_t addr = 0; addr < USTACKTOP; addr += PGSIZE){
  800f54:	bb 00 00 00 00       	mov    $0x0,%ebx
    if (envid == 0) {
  800f59:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800f5d:	0f 85 92 00 00 00    	jne    800ff5 <fork+0xcb>
        thisenv = &envs[ENVX(sys_getenvid())];
  800f63:	e8 c9 fc ff ff       	call   800c31 <sys_getenvid>
  800f68:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f6d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800f70:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f75:	a3 04 20 80 00       	mov    %eax,0x802004
        return 0;
  800f7a:	e9 57 01 00 00       	jmp    8010d6 <fork+0x1ac>
        panic("sys_exofork Failed, envid: %e", envid);
  800f7f:	50                   	push   %eax
  800f80:	68 7c 17 80 00       	push   $0x80177c
  800f85:	6a 71                	push   $0x71
  800f87:	68 24 17 80 00       	push   $0x801724
  800f8c:	e8 ad 01 00 00       	call   80113e <_panic>
        sys_page_map(0, addr, envid, addr, PTE_SYSCALL);
  800f91:	83 ec 0c             	sub    $0xc,%esp
  800f94:	68 07 0e 00 00       	push   $0xe07
  800f99:	56                   	push   %esi
  800f9a:	57                   	push   %edi
  800f9b:	56                   	push   %esi
  800f9c:	6a 00                	push   $0x0
  800f9e:	e8 1b fd ff ff       	call   800cbe <sys_page_map>
  800fa3:	83 c4 20             	add    $0x20,%esp
  800fa6:	eb 3b                	jmp    800fe3 <fork+0xb9>
        if ((r = sys_page_map(0, addr, envid, addr, PTE_COW|PTE_U|PTE_P)) < 0)
  800fa8:	83 ec 0c             	sub    $0xc,%esp
  800fab:	68 05 08 00 00       	push   $0x805
  800fb0:	56                   	push   %esi
  800fb1:	57                   	push   %edi
  800fb2:	56                   	push   %esi
  800fb3:	6a 00                	push   $0x0
  800fb5:	e8 04 fd ff ff       	call   800cbe <sys_page_map>
  800fba:	83 c4 20             	add    $0x20,%esp
  800fbd:	85 c0                	test   %eax,%eax
  800fbf:	0f 88 a9 00 00 00    	js     80106e <fork+0x144>
		if ((r = sys_page_map(0, addr, 0, addr, PTE_COW|PTE_U|PTE_P)) < 0)
  800fc5:	83 ec 0c             	sub    $0xc,%esp
  800fc8:	68 05 08 00 00       	push   $0x805
  800fcd:	56                   	push   %esi
  800fce:	6a 00                	push   $0x0
  800fd0:	56                   	push   %esi
  800fd1:	6a 00                	push   $0x0
  800fd3:	e8 e6 fc ff ff       	call   800cbe <sys_page_map>
  800fd8:	83 c4 20             	add    $0x20,%esp
  800fdb:	85 c0                	test   %eax,%eax
  800fdd:	0f 88 9d 00 00 00    	js     801080 <fork+0x156>
    for(uint32_t addr = 0; addr < USTACKTOP; addr += PGSIZE){
  800fe3:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800fe9:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  800fef:	0f 84 9d 00 00 00    	je     801092 <fork+0x168>
		if((uvpd[PDX(addr)] & PTE_P) && 
  800ff5:	89 d8                	mov    %ebx,%eax
  800ff7:	c1 e8 16             	shr    $0x16,%eax
  800ffa:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801001:	a8 01                	test   $0x1,%al
  801003:	74 de                	je     800fe3 <fork+0xb9>
		(uvpt[PGNUM(addr)]&PTE_P) && 
  801005:	89 d8                	mov    %ebx,%eax
  801007:	c1 e8 0c             	shr    $0xc,%eax
  80100a:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
		if((uvpd[PDX(addr)] & PTE_P) && 
  801011:	f6 c2 01             	test   $0x1,%dl
  801014:	74 cd                	je     800fe3 <fork+0xb9>
		(uvpt[PGNUM(addr)] &PTE_U)){
  801016:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
		(uvpt[PGNUM(addr)]&PTE_P) && 
  80101d:	f6 c2 04             	test   $0x4,%dl
  801020:	74 c1                	je     800fe3 <fork+0xb9>
    void *addr=(void *)(pn*PGSIZE);
  801022:	89 c6                	mov    %eax,%esi
  801024:	c1 e6 0c             	shl    $0xc,%esi
    if(uvpt[pn] & PTE_SHARE){
  801027:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80102e:	f6 c6 04             	test   $0x4,%dh
  801031:	0f 85 5a ff ff ff    	jne    800f91 <fork+0x67>
    else if((uvpt[pn]&PTE_W)|| (uvpt[pn] & PTE_COW)){
  801037:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80103e:	f6 c2 02             	test   $0x2,%dl
  801041:	0f 85 61 ff ff ff    	jne    800fa8 <fork+0x7e>
  801047:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80104e:	f6 c4 08             	test   $0x8,%ah
  801051:	0f 85 51 ff ff ff    	jne    800fa8 <fork+0x7e>
        sys_page_map(0, addr, envid, addr, PTE_U|PTE_P);
  801057:	83 ec 0c             	sub    $0xc,%esp
  80105a:	6a 05                	push   $0x5
  80105c:	56                   	push   %esi
  80105d:	57                   	push   %edi
  80105e:	56                   	push   %esi
  80105f:	6a 00                	push   $0x0
  801061:	e8 58 fc ff ff       	call   800cbe <sys_page_map>
  801066:	83 c4 20             	add    $0x20,%esp
  801069:	e9 75 ff ff ff       	jmp    800fe3 <fork+0xb9>
			panic("sys_page_map：%e", r);
  80106e:	50                   	push   %eax
  80106f:	68 9a 17 80 00       	push   $0x80179a
  801074:	6a 4d                	push   $0x4d
  801076:	68 24 17 80 00       	push   $0x801724
  80107b:	e8 be 00 00 00       	call   80113e <_panic>
			panic("sys_page_map：%e", r);
  801080:	50                   	push   %eax
  801081:	68 9a 17 80 00       	push   $0x80179a
  801086:	6a 4f                	push   $0x4f
  801088:	68 24 17 80 00       	push   $0x801724
  80108d:	e8 ac 00 00 00       	call   80113e <_panic>
			duppage(envid, PGNUM(addr));
		}
	}

    // Allocate a new page for the child's user exception stack
    int r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_P|PTE_W|PTE_U);
  801092:	83 ec 04             	sub    $0x4,%esp
  801095:	6a 07                	push   $0x7
  801097:	68 00 f0 bf ee       	push   $0xeebff000
  80109c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80109f:	e8 d3 fb ff ff       	call   800c77 <sys_page_alloc>
	if( r < 0)
  8010a4:	83 c4 10             	add    $0x10,%esp
  8010a7:	85 c0                	test   %eax,%eax
  8010a9:	78 36                	js     8010e1 <fork+0x1b7>
		panic("sys_page_alloc: %e", r);

    // Set the page fault upcall for the child
    r=sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  8010ab:	83 ec 08             	sub    $0x8,%esp
  8010ae:	68 e5 11 80 00       	push   $0x8011e5
  8010b3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010b6:	e8 d5 fc ff ff       	call   800d90 <sys_env_set_pgfault_upcall>
    if( r < 0 )
  8010bb:	83 c4 10             	add    $0x10,%esp
  8010be:	85 c0                	test   %eax,%eax
  8010c0:	78 34                	js     8010f6 <fork+0x1cc>
		panic("sys_env_set_pgfault_upcall: %e",r);
    
    // Mark the child as runnable
    r=sys_env_set_status(envid, ENV_RUNNABLE);
  8010c2:	83 ec 08             	sub    $0x8,%esp
  8010c5:	6a 02                	push   $0x2
  8010c7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010ca:	e8 7b fc ff ff       	call   800d4a <sys_env_set_status>
    if (r < 0)
  8010cf:	83 c4 10             	add    $0x10,%esp
  8010d2:	85 c0                	test   %eax,%eax
  8010d4:	78 35                	js     80110b <fork+0x1e1>
		panic("sys_env_set_status: %e", r);
    
    return envid;
	// LAB 4: Your code here.
	//panic("fork not implemented");
}
  8010d6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8010d9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010dc:	5b                   	pop    %ebx
  8010dd:	5e                   	pop    %esi
  8010de:	5f                   	pop    %edi
  8010df:	5d                   	pop    %ebp
  8010e0:	c3                   	ret    
		panic("sys_page_alloc: %e", r);
  8010e1:	50                   	push   %eax
  8010e2:	68 56 17 80 00       	push   $0x801756
  8010e7:	68 84 00 00 00       	push   $0x84
  8010ec:	68 24 17 80 00       	push   $0x801724
  8010f1:	e8 48 00 00 00       	call   80113e <_panic>
		panic("sys_env_set_pgfault_upcall: %e",r);
  8010f6:	50                   	push   %eax
  8010f7:	68 dc 17 80 00       	push   $0x8017dc
  8010fc:	68 89 00 00 00       	push   $0x89
  801101:	68 24 17 80 00       	push   $0x801724
  801106:	e8 33 00 00 00       	call   80113e <_panic>
		panic("sys_env_set_status: %e", r);
  80110b:	50                   	push   %eax
  80110c:	68 ac 17 80 00       	push   $0x8017ac
  801111:	68 8e 00 00 00       	push   $0x8e
  801116:	68 24 17 80 00       	push   $0x801724
  80111b:	e8 1e 00 00 00       	call   80113e <_panic>

00801120 <sfork>:

// Challenge!
int
sfork(void)
{
  801120:	f3 0f 1e fb          	endbr32 
  801124:	55                   	push   %ebp
  801125:	89 e5                	mov    %esp,%ebp
  801127:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  80112a:	68 c3 17 80 00       	push   $0x8017c3
  80112f:	68 99 00 00 00       	push   $0x99
  801134:	68 24 17 80 00       	push   $0x801724
  801139:	e8 00 00 00 00       	call   80113e <_panic>

0080113e <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80113e:	f3 0f 1e fb          	endbr32 
  801142:	55                   	push   %ebp
  801143:	89 e5                	mov    %esp,%ebp
  801145:	56                   	push   %esi
  801146:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801147:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80114a:	8b 35 00 20 80 00    	mov    0x802000,%esi
  801150:	e8 dc fa ff ff       	call   800c31 <sys_getenvid>
  801155:	83 ec 0c             	sub    $0xc,%esp
  801158:	ff 75 0c             	pushl  0xc(%ebp)
  80115b:	ff 75 08             	pushl  0x8(%ebp)
  80115e:	56                   	push   %esi
  80115f:	50                   	push   %eax
  801160:	68 fc 17 80 00       	push   $0x8017fc
  801165:	e8 82 f0 ff ff       	call   8001ec <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80116a:	83 c4 18             	add    $0x18,%esp
  80116d:	53                   	push   %ebx
  80116e:	ff 75 10             	pushl  0x10(%ebp)
  801171:	e8 21 f0 ff ff       	call   800197 <vcprintf>
	cprintf("\n");
  801176:	c7 04 24 8f 14 80 00 	movl   $0x80148f,(%esp)
  80117d:	e8 6a f0 ff ff       	call   8001ec <cprintf>
  801182:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801185:	cc                   	int3   
  801186:	eb fd                	jmp    801185 <_panic+0x47>

00801188 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801188:	f3 0f 1e fb          	endbr32 
  80118c:	55                   	push   %ebp
  80118d:	89 e5                	mov    %esp,%ebp
  80118f:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801192:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  801199:	74 0a                	je     8011a5 <set_pgfault_handler+0x1d>
        sys_env_set_pgfault_upcall(0, _pgfault_upcall);
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80119b:	8b 45 08             	mov    0x8(%ebp),%eax
  80119e:	a3 08 20 80 00       	mov    %eax,0x802008
}
  8011a3:	c9                   	leave  
  8011a4:	c3                   	ret    
		if (sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P) < 0)
  8011a5:	83 ec 04             	sub    $0x4,%esp
  8011a8:	6a 07                	push   $0x7
  8011aa:	68 00 f0 bf ee       	push   $0xeebff000
  8011af:	6a 00                	push   $0x0
  8011b1:	e8 c1 fa ff ff       	call   800c77 <sys_page_alloc>
  8011b6:	83 c4 10             	add    $0x10,%esp
  8011b9:	85 c0                	test   %eax,%eax
  8011bb:	78 14                	js     8011d1 <set_pgfault_handler+0x49>
        sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  8011bd:	83 ec 08             	sub    $0x8,%esp
  8011c0:	68 e5 11 80 00       	push   $0x8011e5
  8011c5:	6a 00                	push   $0x0
  8011c7:	e8 c4 fb ff ff       	call   800d90 <sys_env_set_pgfault_upcall>
  8011cc:	83 c4 10             	add    $0x10,%esp
  8011cf:	eb ca                	jmp    80119b <set_pgfault_handler+0x13>
            panic("set_pgfault_handler failed.");
  8011d1:	83 ec 04             	sub    $0x4,%esp
  8011d4:	68 1f 18 80 00       	push   $0x80181f
  8011d9:	6a 21                	push   $0x21
  8011db:	68 3b 18 80 00       	push   $0x80183b
  8011e0:	e8 59 ff ff ff       	call   80113e <_panic>

008011e5 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8011e5:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8011e6:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  8011eb:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8011ed:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	addl $8, %esp
  8011f0:	83 c4 08             	add    $0x8,%esp
	movl 32(%esp), %eax
  8011f3:	8b 44 24 20          	mov    0x20(%esp),%eax
	movl 40(%esp), %edx
  8011f7:	8b 54 24 28          	mov    0x28(%esp),%edx
	subl $4, %edx
  8011fb:	83 ea 04             	sub    $0x4,%edx
	movl %eax, (%edx)
  8011fe:	89 02                	mov    %eax,(%edx)
	movl %edx, 40(%esp)
  801200:	89 54 24 28          	mov    %edx,0x28(%esp)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal
  801204:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp
  801205:	83 c4 04             	add    $0x4,%esp
	popfl
  801208:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  801209:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  80120a:	c3                   	ret    
  80120b:	66 90                	xchg   %ax,%ax
  80120d:	66 90                	xchg   %ax,%ax
  80120f:	90                   	nop

00801210 <__udivdi3>:
  801210:	f3 0f 1e fb          	endbr32 
  801214:	55                   	push   %ebp
  801215:	57                   	push   %edi
  801216:	56                   	push   %esi
  801217:	53                   	push   %ebx
  801218:	83 ec 1c             	sub    $0x1c,%esp
  80121b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80121f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  801223:	8b 74 24 34          	mov    0x34(%esp),%esi
  801227:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  80122b:	85 d2                	test   %edx,%edx
  80122d:	75 19                	jne    801248 <__udivdi3+0x38>
  80122f:	39 f3                	cmp    %esi,%ebx
  801231:	76 4d                	jbe    801280 <__udivdi3+0x70>
  801233:	31 ff                	xor    %edi,%edi
  801235:	89 e8                	mov    %ebp,%eax
  801237:	89 f2                	mov    %esi,%edx
  801239:	f7 f3                	div    %ebx
  80123b:	89 fa                	mov    %edi,%edx
  80123d:	83 c4 1c             	add    $0x1c,%esp
  801240:	5b                   	pop    %ebx
  801241:	5e                   	pop    %esi
  801242:	5f                   	pop    %edi
  801243:	5d                   	pop    %ebp
  801244:	c3                   	ret    
  801245:	8d 76 00             	lea    0x0(%esi),%esi
  801248:	39 f2                	cmp    %esi,%edx
  80124a:	76 14                	jbe    801260 <__udivdi3+0x50>
  80124c:	31 ff                	xor    %edi,%edi
  80124e:	31 c0                	xor    %eax,%eax
  801250:	89 fa                	mov    %edi,%edx
  801252:	83 c4 1c             	add    $0x1c,%esp
  801255:	5b                   	pop    %ebx
  801256:	5e                   	pop    %esi
  801257:	5f                   	pop    %edi
  801258:	5d                   	pop    %ebp
  801259:	c3                   	ret    
  80125a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801260:	0f bd fa             	bsr    %edx,%edi
  801263:	83 f7 1f             	xor    $0x1f,%edi
  801266:	75 48                	jne    8012b0 <__udivdi3+0xa0>
  801268:	39 f2                	cmp    %esi,%edx
  80126a:	72 06                	jb     801272 <__udivdi3+0x62>
  80126c:	31 c0                	xor    %eax,%eax
  80126e:	39 eb                	cmp    %ebp,%ebx
  801270:	77 de                	ja     801250 <__udivdi3+0x40>
  801272:	b8 01 00 00 00       	mov    $0x1,%eax
  801277:	eb d7                	jmp    801250 <__udivdi3+0x40>
  801279:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801280:	89 d9                	mov    %ebx,%ecx
  801282:	85 db                	test   %ebx,%ebx
  801284:	75 0b                	jne    801291 <__udivdi3+0x81>
  801286:	b8 01 00 00 00       	mov    $0x1,%eax
  80128b:	31 d2                	xor    %edx,%edx
  80128d:	f7 f3                	div    %ebx
  80128f:	89 c1                	mov    %eax,%ecx
  801291:	31 d2                	xor    %edx,%edx
  801293:	89 f0                	mov    %esi,%eax
  801295:	f7 f1                	div    %ecx
  801297:	89 c6                	mov    %eax,%esi
  801299:	89 e8                	mov    %ebp,%eax
  80129b:	89 f7                	mov    %esi,%edi
  80129d:	f7 f1                	div    %ecx
  80129f:	89 fa                	mov    %edi,%edx
  8012a1:	83 c4 1c             	add    $0x1c,%esp
  8012a4:	5b                   	pop    %ebx
  8012a5:	5e                   	pop    %esi
  8012a6:	5f                   	pop    %edi
  8012a7:	5d                   	pop    %ebp
  8012a8:	c3                   	ret    
  8012a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8012b0:	89 f9                	mov    %edi,%ecx
  8012b2:	b8 20 00 00 00       	mov    $0x20,%eax
  8012b7:	29 f8                	sub    %edi,%eax
  8012b9:	d3 e2                	shl    %cl,%edx
  8012bb:	89 54 24 08          	mov    %edx,0x8(%esp)
  8012bf:	89 c1                	mov    %eax,%ecx
  8012c1:	89 da                	mov    %ebx,%edx
  8012c3:	d3 ea                	shr    %cl,%edx
  8012c5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8012c9:	09 d1                	or     %edx,%ecx
  8012cb:	89 f2                	mov    %esi,%edx
  8012cd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8012d1:	89 f9                	mov    %edi,%ecx
  8012d3:	d3 e3                	shl    %cl,%ebx
  8012d5:	89 c1                	mov    %eax,%ecx
  8012d7:	d3 ea                	shr    %cl,%edx
  8012d9:	89 f9                	mov    %edi,%ecx
  8012db:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8012df:	89 eb                	mov    %ebp,%ebx
  8012e1:	d3 e6                	shl    %cl,%esi
  8012e3:	89 c1                	mov    %eax,%ecx
  8012e5:	d3 eb                	shr    %cl,%ebx
  8012e7:	09 de                	or     %ebx,%esi
  8012e9:	89 f0                	mov    %esi,%eax
  8012eb:	f7 74 24 08          	divl   0x8(%esp)
  8012ef:	89 d6                	mov    %edx,%esi
  8012f1:	89 c3                	mov    %eax,%ebx
  8012f3:	f7 64 24 0c          	mull   0xc(%esp)
  8012f7:	39 d6                	cmp    %edx,%esi
  8012f9:	72 15                	jb     801310 <__udivdi3+0x100>
  8012fb:	89 f9                	mov    %edi,%ecx
  8012fd:	d3 e5                	shl    %cl,%ebp
  8012ff:	39 c5                	cmp    %eax,%ebp
  801301:	73 04                	jae    801307 <__udivdi3+0xf7>
  801303:	39 d6                	cmp    %edx,%esi
  801305:	74 09                	je     801310 <__udivdi3+0x100>
  801307:	89 d8                	mov    %ebx,%eax
  801309:	31 ff                	xor    %edi,%edi
  80130b:	e9 40 ff ff ff       	jmp    801250 <__udivdi3+0x40>
  801310:	8d 43 ff             	lea    -0x1(%ebx),%eax
  801313:	31 ff                	xor    %edi,%edi
  801315:	e9 36 ff ff ff       	jmp    801250 <__udivdi3+0x40>
  80131a:	66 90                	xchg   %ax,%ax
  80131c:	66 90                	xchg   %ax,%ax
  80131e:	66 90                	xchg   %ax,%ax

00801320 <__umoddi3>:
  801320:	f3 0f 1e fb          	endbr32 
  801324:	55                   	push   %ebp
  801325:	57                   	push   %edi
  801326:	56                   	push   %esi
  801327:	53                   	push   %ebx
  801328:	83 ec 1c             	sub    $0x1c,%esp
  80132b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80132f:	8b 74 24 30          	mov    0x30(%esp),%esi
  801333:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  801337:	8b 7c 24 38          	mov    0x38(%esp),%edi
  80133b:	85 c0                	test   %eax,%eax
  80133d:	75 19                	jne    801358 <__umoddi3+0x38>
  80133f:	39 df                	cmp    %ebx,%edi
  801341:	76 5d                	jbe    8013a0 <__umoddi3+0x80>
  801343:	89 f0                	mov    %esi,%eax
  801345:	89 da                	mov    %ebx,%edx
  801347:	f7 f7                	div    %edi
  801349:	89 d0                	mov    %edx,%eax
  80134b:	31 d2                	xor    %edx,%edx
  80134d:	83 c4 1c             	add    $0x1c,%esp
  801350:	5b                   	pop    %ebx
  801351:	5e                   	pop    %esi
  801352:	5f                   	pop    %edi
  801353:	5d                   	pop    %ebp
  801354:	c3                   	ret    
  801355:	8d 76 00             	lea    0x0(%esi),%esi
  801358:	89 f2                	mov    %esi,%edx
  80135a:	39 d8                	cmp    %ebx,%eax
  80135c:	76 12                	jbe    801370 <__umoddi3+0x50>
  80135e:	89 f0                	mov    %esi,%eax
  801360:	89 da                	mov    %ebx,%edx
  801362:	83 c4 1c             	add    $0x1c,%esp
  801365:	5b                   	pop    %ebx
  801366:	5e                   	pop    %esi
  801367:	5f                   	pop    %edi
  801368:	5d                   	pop    %ebp
  801369:	c3                   	ret    
  80136a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801370:	0f bd e8             	bsr    %eax,%ebp
  801373:	83 f5 1f             	xor    $0x1f,%ebp
  801376:	75 50                	jne    8013c8 <__umoddi3+0xa8>
  801378:	39 d8                	cmp    %ebx,%eax
  80137a:	0f 82 e0 00 00 00    	jb     801460 <__umoddi3+0x140>
  801380:	89 d9                	mov    %ebx,%ecx
  801382:	39 f7                	cmp    %esi,%edi
  801384:	0f 86 d6 00 00 00    	jbe    801460 <__umoddi3+0x140>
  80138a:	89 d0                	mov    %edx,%eax
  80138c:	89 ca                	mov    %ecx,%edx
  80138e:	83 c4 1c             	add    $0x1c,%esp
  801391:	5b                   	pop    %ebx
  801392:	5e                   	pop    %esi
  801393:	5f                   	pop    %edi
  801394:	5d                   	pop    %ebp
  801395:	c3                   	ret    
  801396:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80139d:	8d 76 00             	lea    0x0(%esi),%esi
  8013a0:	89 fd                	mov    %edi,%ebp
  8013a2:	85 ff                	test   %edi,%edi
  8013a4:	75 0b                	jne    8013b1 <__umoddi3+0x91>
  8013a6:	b8 01 00 00 00       	mov    $0x1,%eax
  8013ab:	31 d2                	xor    %edx,%edx
  8013ad:	f7 f7                	div    %edi
  8013af:	89 c5                	mov    %eax,%ebp
  8013b1:	89 d8                	mov    %ebx,%eax
  8013b3:	31 d2                	xor    %edx,%edx
  8013b5:	f7 f5                	div    %ebp
  8013b7:	89 f0                	mov    %esi,%eax
  8013b9:	f7 f5                	div    %ebp
  8013bb:	89 d0                	mov    %edx,%eax
  8013bd:	31 d2                	xor    %edx,%edx
  8013bf:	eb 8c                	jmp    80134d <__umoddi3+0x2d>
  8013c1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8013c8:	89 e9                	mov    %ebp,%ecx
  8013ca:	ba 20 00 00 00       	mov    $0x20,%edx
  8013cf:	29 ea                	sub    %ebp,%edx
  8013d1:	d3 e0                	shl    %cl,%eax
  8013d3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8013d7:	89 d1                	mov    %edx,%ecx
  8013d9:	89 f8                	mov    %edi,%eax
  8013db:	d3 e8                	shr    %cl,%eax
  8013dd:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8013e1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8013e5:	8b 54 24 04          	mov    0x4(%esp),%edx
  8013e9:	09 c1                	or     %eax,%ecx
  8013eb:	89 d8                	mov    %ebx,%eax
  8013ed:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8013f1:	89 e9                	mov    %ebp,%ecx
  8013f3:	d3 e7                	shl    %cl,%edi
  8013f5:	89 d1                	mov    %edx,%ecx
  8013f7:	d3 e8                	shr    %cl,%eax
  8013f9:	89 e9                	mov    %ebp,%ecx
  8013fb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8013ff:	d3 e3                	shl    %cl,%ebx
  801401:	89 c7                	mov    %eax,%edi
  801403:	89 d1                	mov    %edx,%ecx
  801405:	89 f0                	mov    %esi,%eax
  801407:	d3 e8                	shr    %cl,%eax
  801409:	89 e9                	mov    %ebp,%ecx
  80140b:	89 fa                	mov    %edi,%edx
  80140d:	d3 e6                	shl    %cl,%esi
  80140f:	09 d8                	or     %ebx,%eax
  801411:	f7 74 24 08          	divl   0x8(%esp)
  801415:	89 d1                	mov    %edx,%ecx
  801417:	89 f3                	mov    %esi,%ebx
  801419:	f7 64 24 0c          	mull   0xc(%esp)
  80141d:	89 c6                	mov    %eax,%esi
  80141f:	89 d7                	mov    %edx,%edi
  801421:	39 d1                	cmp    %edx,%ecx
  801423:	72 06                	jb     80142b <__umoddi3+0x10b>
  801425:	75 10                	jne    801437 <__umoddi3+0x117>
  801427:	39 c3                	cmp    %eax,%ebx
  801429:	73 0c                	jae    801437 <__umoddi3+0x117>
  80142b:	2b 44 24 0c          	sub    0xc(%esp),%eax
  80142f:	1b 54 24 08          	sbb    0x8(%esp),%edx
  801433:	89 d7                	mov    %edx,%edi
  801435:	89 c6                	mov    %eax,%esi
  801437:	89 ca                	mov    %ecx,%edx
  801439:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80143e:	29 f3                	sub    %esi,%ebx
  801440:	19 fa                	sbb    %edi,%edx
  801442:	89 d0                	mov    %edx,%eax
  801444:	d3 e0                	shl    %cl,%eax
  801446:	89 e9                	mov    %ebp,%ecx
  801448:	d3 eb                	shr    %cl,%ebx
  80144a:	d3 ea                	shr    %cl,%edx
  80144c:	09 d8                	or     %ebx,%eax
  80144e:	83 c4 1c             	add    $0x1c,%esp
  801451:	5b                   	pop    %ebx
  801452:	5e                   	pop    %esi
  801453:	5f                   	pop    %edi
  801454:	5d                   	pop    %ebp
  801455:	c3                   	ret    
  801456:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80145d:	8d 76 00             	lea    0x0(%esi),%esi
  801460:	29 fe                	sub    %edi,%esi
  801462:	19 c3                	sbb    %eax,%ebx
  801464:	89 f2                	mov    %esi,%edx
  801466:	89 d9                	mov    %ebx,%ecx
  801468:	e9 1d ff ff ff       	jmp    80138a <__umoddi3+0x6a>
