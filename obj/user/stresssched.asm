
obj/user/stresssched:     file format elf32-i386


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
  80002c:	e8 b6 00 00 00       	call   8000e7 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

volatile int counter;

void
umain(int argc, char **argv)
{
  800033:	f3 0f 1e fb          	endbr32 
  800037:	55                   	push   %ebp
  800038:	89 e5                	mov    %esp,%ebp
  80003a:	56                   	push   %esi
  80003b:	53                   	push   %ebx
	int i, j;
	int seen;
	envid_t parent = sys_getenvid();
  80003c:	e8 32 0c 00 00       	call   800c73 <sys_getenvid>
  800041:	89 c6                	mov    %eax,%esi

	// Fork several environments
	for (i = 0; i < 20; i++)
  800043:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (fork() == 0)
  800048:	e8 1f 0f 00 00       	call   800f6c <fork>
  80004d:	85 c0                	test   %eax,%eax
  80004f:	74 0f                	je     800060 <umain+0x2d>
	for (i = 0; i < 20; i++)
  800051:	83 c3 01             	add    $0x1,%ebx
  800054:	83 fb 14             	cmp    $0x14,%ebx
  800057:	75 ef                	jne    800048 <umain+0x15>
			break;
	if (i == 20) {
		sys_yield();
  800059:	e8 38 0c 00 00       	call   800c96 <sys_yield>
		return;
  80005e:	eb 69                	jmp    8000c9 <umain+0x96>
	}

	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
  800060:	89 f0                	mov    %esi,%eax
  800062:	25 ff 03 00 00       	and    $0x3ff,%eax
  800067:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80006a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80006f:	eb 02                	jmp    800073 <umain+0x40>
		asm volatile("pause");
  800071:	f3 90                	pause  
	while (envs[ENVX(parent)].env_status != ENV_FREE)
  800073:	8b 50 54             	mov    0x54(%eax),%edx
  800076:	85 d2                	test   %edx,%edx
  800078:	75 f7                	jne    800071 <umain+0x3e>
  80007a:	bb 0a 00 00 00       	mov    $0xa,%ebx

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
		sys_yield();
  80007f:	e8 12 0c 00 00       	call   800c96 <sys_yield>
  800084:	ba 10 27 00 00       	mov    $0x2710,%edx
		for (j = 0; j < 10000; j++)
			counter++;
  800089:	a1 04 20 80 00       	mov    0x802004,%eax
  80008e:	83 c0 01             	add    $0x1,%eax
  800091:	a3 04 20 80 00       	mov    %eax,0x802004
		for (j = 0; j < 10000; j++)
  800096:	83 ea 01             	sub    $0x1,%edx
  800099:	75 ee                	jne    800089 <umain+0x56>
	for (i = 0; i < 10; i++) {
  80009b:	83 eb 01             	sub    $0x1,%ebx
  80009e:	75 df                	jne    80007f <umain+0x4c>
	}

	if (counter != 10*10000)
  8000a0:	a1 04 20 80 00       	mov    0x802004,%eax
  8000a5:	3d a0 86 01 00       	cmp    $0x186a0,%eax
  8000aa:	75 24                	jne    8000d0 <umain+0x9d>
		panic("ran on two CPUs at once (counter is %d)", counter);

	// Check that we see environments running on different CPUs
	cprintf("[%08x] stresssched on CPU %d\n", thisenv->env_id, thisenv->env_cpunum);
  8000ac:	a1 08 20 80 00       	mov    0x802008,%eax
  8000b1:	8b 50 5c             	mov    0x5c(%eax),%edx
  8000b4:	8b 40 48             	mov    0x48(%eax),%eax
  8000b7:	83 ec 04             	sub    $0x4,%esp
  8000ba:	52                   	push   %edx
  8000bb:	50                   	push   %eax
  8000bc:	68 bb 14 80 00       	push   $0x8014bb
  8000c1:	e8 68 01 00 00       	call   80022e <cprintf>
  8000c6:	83 c4 10             	add    $0x10,%esp

}
  8000c9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000cc:	5b                   	pop    %ebx
  8000cd:	5e                   	pop    %esi
  8000ce:	5d                   	pop    %ebp
  8000cf:	c3                   	ret    
		panic("ran on two CPUs at once (counter is %d)", counter);
  8000d0:	a1 04 20 80 00       	mov    0x802004,%eax
  8000d5:	50                   	push   %eax
  8000d6:	68 80 14 80 00       	push   $0x801480
  8000db:	6a 21                	push   $0x21
  8000dd:	68 a8 14 80 00       	push   $0x8014a8
  8000e2:	e8 60 00 00 00       	call   800147 <_panic>

008000e7 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000e7:	f3 0f 1e fb          	endbr32 
  8000eb:	55                   	push   %ebp
  8000ec:	89 e5                	mov    %esp,%ebp
  8000ee:	56                   	push   %esi
  8000ef:	53                   	push   %ebx
  8000f0:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000f3:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv=&envs[ENVX(sys_getenvid())];
  8000f6:	e8 78 0b 00 00       	call   800c73 <sys_getenvid>
  8000fb:	25 ff 03 00 00       	and    $0x3ff,%eax
  800100:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800103:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800108:	a3 08 20 80 00       	mov    %eax,0x802008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80010d:	85 db                	test   %ebx,%ebx
  80010f:	7e 07                	jle    800118 <libmain+0x31>
		binaryname = argv[0];
  800111:	8b 06                	mov    (%esi),%eax
  800113:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800118:	83 ec 08             	sub    $0x8,%esp
  80011b:	56                   	push   %esi
  80011c:	53                   	push   %ebx
  80011d:	e8 11 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800122:	e8 0a 00 00 00       	call   800131 <exit>
}
  800127:	83 c4 10             	add    $0x10,%esp
  80012a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80012d:	5b                   	pop    %ebx
  80012e:	5e                   	pop    %esi
  80012f:	5d                   	pop    %ebp
  800130:	c3                   	ret    

00800131 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800131:	f3 0f 1e fb          	endbr32 
  800135:	55                   	push   %ebp
  800136:	89 e5                	mov    %esp,%ebp
  800138:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80013b:	6a 00                	push   $0x0
  80013d:	e8 ec 0a 00 00       	call   800c2e <sys_env_destroy>
}
  800142:	83 c4 10             	add    $0x10,%esp
  800145:	c9                   	leave  
  800146:	c3                   	ret    

00800147 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800147:	f3 0f 1e fb          	endbr32 
  80014b:	55                   	push   %ebp
  80014c:	89 e5                	mov    %esp,%ebp
  80014e:	56                   	push   %esi
  80014f:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800150:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800153:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800159:	e8 15 0b 00 00       	call   800c73 <sys_getenvid>
  80015e:	83 ec 0c             	sub    $0xc,%esp
  800161:	ff 75 0c             	pushl  0xc(%ebp)
  800164:	ff 75 08             	pushl  0x8(%ebp)
  800167:	56                   	push   %esi
  800168:	50                   	push   %eax
  800169:	68 e4 14 80 00       	push   $0x8014e4
  80016e:	e8 bb 00 00 00       	call   80022e <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800173:	83 c4 18             	add    $0x18,%esp
  800176:	53                   	push   %ebx
  800177:	ff 75 10             	pushl  0x10(%ebp)
  80017a:	e8 5a 00 00 00       	call   8001d9 <vcprintf>
	cprintf("\n");
  80017f:	c7 04 24 d7 14 80 00 	movl   $0x8014d7,(%esp)
  800186:	e8 a3 00 00 00       	call   80022e <cprintf>
  80018b:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80018e:	cc                   	int3   
  80018f:	eb fd                	jmp    80018e <_panic+0x47>

00800191 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800191:	f3 0f 1e fb          	endbr32 
  800195:	55                   	push   %ebp
  800196:	89 e5                	mov    %esp,%ebp
  800198:	53                   	push   %ebx
  800199:	83 ec 04             	sub    $0x4,%esp
  80019c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80019f:	8b 13                	mov    (%ebx),%edx
  8001a1:	8d 42 01             	lea    0x1(%edx),%eax
  8001a4:	89 03                	mov    %eax,(%ebx)
  8001a6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001a9:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001ad:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001b2:	74 09                	je     8001bd <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8001b4:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001b8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001bb:	c9                   	leave  
  8001bc:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8001bd:	83 ec 08             	sub    $0x8,%esp
  8001c0:	68 ff 00 00 00       	push   $0xff
  8001c5:	8d 43 08             	lea    0x8(%ebx),%eax
  8001c8:	50                   	push   %eax
  8001c9:	e8 1b 0a 00 00       	call   800be9 <sys_cputs>
		b->idx = 0;
  8001ce:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001d4:	83 c4 10             	add    $0x10,%esp
  8001d7:	eb db                	jmp    8001b4 <putch+0x23>

008001d9 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001d9:	f3 0f 1e fb          	endbr32 
  8001dd:	55                   	push   %ebp
  8001de:	89 e5                	mov    %esp,%ebp
  8001e0:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001e6:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001ed:	00 00 00 
	b.cnt = 0;
  8001f0:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001f7:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001fa:	ff 75 0c             	pushl  0xc(%ebp)
  8001fd:	ff 75 08             	pushl  0x8(%ebp)
  800200:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800206:	50                   	push   %eax
  800207:	68 91 01 80 00       	push   $0x800191
  80020c:	e8 20 01 00 00       	call   800331 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800211:	83 c4 08             	add    $0x8,%esp
  800214:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80021a:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800220:	50                   	push   %eax
  800221:	e8 c3 09 00 00       	call   800be9 <sys_cputs>

	return b.cnt;
}
  800226:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80022c:	c9                   	leave  
  80022d:	c3                   	ret    

0080022e <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80022e:	f3 0f 1e fb          	endbr32 
  800232:	55                   	push   %ebp
  800233:	89 e5                	mov    %esp,%ebp
  800235:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800238:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80023b:	50                   	push   %eax
  80023c:	ff 75 08             	pushl  0x8(%ebp)
  80023f:	e8 95 ff ff ff       	call   8001d9 <vcprintf>
	va_end(ap);

	return cnt;
}
  800244:	c9                   	leave  
  800245:	c3                   	ret    

00800246 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800246:	55                   	push   %ebp
  800247:	89 e5                	mov    %esp,%ebp
  800249:	57                   	push   %edi
  80024a:	56                   	push   %esi
  80024b:	53                   	push   %ebx
  80024c:	83 ec 1c             	sub    $0x1c,%esp
  80024f:	89 c7                	mov    %eax,%edi
  800251:	89 d6                	mov    %edx,%esi
  800253:	8b 45 08             	mov    0x8(%ebp),%eax
  800256:	8b 55 0c             	mov    0xc(%ebp),%edx
  800259:	89 d1                	mov    %edx,%ecx
  80025b:	89 c2                	mov    %eax,%edx
  80025d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800260:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800263:	8b 45 10             	mov    0x10(%ebp),%eax
  800266:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800269:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80026c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800273:	39 c2                	cmp    %eax,%edx
  800275:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800278:	72 3e                	jb     8002b8 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80027a:	83 ec 0c             	sub    $0xc,%esp
  80027d:	ff 75 18             	pushl  0x18(%ebp)
  800280:	83 eb 01             	sub    $0x1,%ebx
  800283:	53                   	push   %ebx
  800284:	50                   	push   %eax
  800285:	83 ec 08             	sub    $0x8,%esp
  800288:	ff 75 e4             	pushl  -0x1c(%ebp)
  80028b:	ff 75 e0             	pushl  -0x20(%ebp)
  80028e:	ff 75 dc             	pushl  -0x24(%ebp)
  800291:	ff 75 d8             	pushl  -0x28(%ebp)
  800294:	e8 77 0f 00 00       	call   801210 <__udivdi3>
  800299:	83 c4 18             	add    $0x18,%esp
  80029c:	52                   	push   %edx
  80029d:	50                   	push   %eax
  80029e:	89 f2                	mov    %esi,%edx
  8002a0:	89 f8                	mov    %edi,%eax
  8002a2:	e8 9f ff ff ff       	call   800246 <printnum>
  8002a7:	83 c4 20             	add    $0x20,%esp
  8002aa:	eb 13                	jmp    8002bf <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002ac:	83 ec 08             	sub    $0x8,%esp
  8002af:	56                   	push   %esi
  8002b0:	ff 75 18             	pushl  0x18(%ebp)
  8002b3:	ff d7                	call   *%edi
  8002b5:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8002b8:	83 eb 01             	sub    $0x1,%ebx
  8002bb:	85 db                	test   %ebx,%ebx
  8002bd:	7f ed                	jg     8002ac <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002bf:	83 ec 08             	sub    $0x8,%esp
  8002c2:	56                   	push   %esi
  8002c3:	83 ec 04             	sub    $0x4,%esp
  8002c6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002c9:	ff 75 e0             	pushl  -0x20(%ebp)
  8002cc:	ff 75 dc             	pushl  -0x24(%ebp)
  8002cf:	ff 75 d8             	pushl  -0x28(%ebp)
  8002d2:	e8 49 10 00 00       	call   801320 <__umoddi3>
  8002d7:	83 c4 14             	add    $0x14,%esp
  8002da:	0f be 80 07 15 80 00 	movsbl 0x801507(%eax),%eax
  8002e1:	50                   	push   %eax
  8002e2:	ff d7                	call   *%edi
}
  8002e4:	83 c4 10             	add    $0x10,%esp
  8002e7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002ea:	5b                   	pop    %ebx
  8002eb:	5e                   	pop    %esi
  8002ec:	5f                   	pop    %edi
  8002ed:	5d                   	pop    %ebp
  8002ee:	c3                   	ret    

008002ef <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002ef:	f3 0f 1e fb          	endbr32 
  8002f3:	55                   	push   %ebp
  8002f4:	89 e5                	mov    %esp,%ebp
  8002f6:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002f9:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002fd:	8b 10                	mov    (%eax),%edx
  8002ff:	3b 50 04             	cmp    0x4(%eax),%edx
  800302:	73 0a                	jae    80030e <sprintputch+0x1f>
		*b->buf++ = ch;
  800304:	8d 4a 01             	lea    0x1(%edx),%ecx
  800307:	89 08                	mov    %ecx,(%eax)
  800309:	8b 45 08             	mov    0x8(%ebp),%eax
  80030c:	88 02                	mov    %al,(%edx)
}
  80030e:	5d                   	pop    %ebp
  80030f:	c3                   	ret    

00800310 <printfmt>:
{
  800310:	f3 0f 1e fb          	endbr32 
  800314:	55                   	push   %ebp
  800315:	89 e5                	mov    %esp,%ebp
  800317:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80031a:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80031d:	50                   	push   %eax
  80031e:	ff 75 10             	pushl  0x10(%ebp)
  800321:	ff 75 0c             	pushl  0xc(%ebp)
  800324:	ff 75 08             	pushl  0x8(%ebp)
  800327:	e8 05 00 00 00       	call   800331 <vprintfmt>
}
  80032c:	83 c4 10             	add    $0x10,%esp
  80032f:	c9                   	leave  
  800330:	c3                   	ret    

00800331 <vprintfmt>:
{
  800331:	f3 0f 1e fb          	endbr32 
  800335:	55                   	push   %ebp
  800336:	89 e5                	mov    %esp,%ebp
  800338:	57                   	push   %edi
  800339:	56                   	push   %esi
  80033a:	53                   	push   %ebx
  80033b:	83 ec 3c             	sub    $0x3c,%esp
  80033e:	8b 75 08             	mov    0x8(%ebp),%esi
  800341:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800344:	8b 7d 10             	mov    0x10(%ebp),%edi
  800347:	e9 cd 03 00 00       	jmp    800719 <vprintfmt+0x3e8>
		padc = ' ';
  80034c:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800350:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800357:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  80035e:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800365:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80036a:	8d 47 01             	lea    0x1(%edi),%eax
  80036d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800370:	0f b6 17             	movzbl (%edi),%edx
  800373:	8d 42 dd             	lea    -0x23(%edx),%eax
  800376:	3c 55                	cmp    $0x55,%al
  800378:	0f 87 1e 04 00 00    	ja     80079c <vprintfmt+0x46b>
  80037e:	0f b6 c0             	movzbl %al,%eax
  800381:	3e ff 24 85 c0 15 80 	notrack jmp *0x8015c0(,%eax,4)
  800388:	00 
  800389:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80038c:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800390:	eb d8                	jmp    80036a <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800392:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800395:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  800399:	eb cf                	jmp    80036a <vprintfmt+0x39>
  80039b:	0f b6 d2             	movzbl %dl,%edx
  80039e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8003a1:	b8 00 00 00 00       	mov    $0x0,%eax
  8003a6:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8003a9:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003ac:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8003b0:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8003b3:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8003b6:	83 f9 09             	cmp    $0x9,%ecx
  8003b9:	77 55                	ja     800410 <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  8003bb:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8003be:	eb e9                	jmp    8003a9 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  8003c0:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c3:	8b 00                	mov    (%eax),%eax
  8003c5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8003cb:	8d 40 04             	lea    0x4(%eax),%eax
  8003ce:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003d1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8003d4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003d8:	79 90                	jns    80036a <vprintfmt+0x39>
				width = precision, precision = -1;
  8003da:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8003dd:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003e0:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8003e7:	eb 81                	jmp    80036a <vprintfmt+0x39>
  8003e9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003ec:	85 c0                	test   %eax,%eax
  8003ee:	ba 00 00 00 00       	mov    $0x0,%edx
  8003f3:	0f 49 d0             	cmovns %eax,%edx
  8003f6:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003f9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003fc:	e9 69 ff ff ff       	jmp    80036a <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800401:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800404:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  80040b:	e9 5a ff ff ff       	jmp    80036a <vprintfmt+0x39>
  800410:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800413:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800416:	eb bc                	jmp    8003d4 <vprintfmt+0xa3>
			lflag++;
  800418:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80041b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80041e:	e9 47 ff ff ff       	jmp    80036a <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  800423:	8b 45 14             	mov    0x14(%ebp),%eax
  800426:	8d 78 04             	lea    0x4(%eax),%edi
  800429:	83 ec 08             	sub    $0x8,%esp
  80042c:	53                   	push   %ebx
  80042d:	ff 30                	pushl  (%eax)
  80042f:	ff d6                	call   *%esi
			break;
  800431:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800434:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800437:	e9 da 02 00 00       	jmp    800716 <vprintfmt+0x3e5>
			err = va_arg(ap, int);
  80043c:	8b 45 14             	mov    0x14(%ebp),%eax
  80043f:	8d 78 04             	lea    0x4(%eax),%edi
  800442:	8b 00                	mov    (%eax),%eax
  800444:	99                   	cltd   
  800445:	31 d0                	xor    %edx,%eax
  800447:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800449:	83 f8 08             	cmp    $0x8,%eax
  80044c:	7f 23                	jg     800471 <vprintfmt+0x140>
  80044e:	8b 14 85 20 17 80 00 	mov    0x801720(,%eax,4),%edx
  800455:	85 d2                	test   %edx,%edx
  800457:	74 18                	je     800471 <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  800459:	52                   	push   %edx
  80045a:	68 28 15 80 00       	push   $0x801528
  80045f:	53                   	push   %ebx
  800460:	56                   	push   %esi
  800461:	e8 aa fe ff ff       	call   800310 <printfmt>
  800466:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800469:	89 7d 14             	mov    %edi,0x14(%ebp)
  80046c:	e9 a5 02 00 00       	jmp    800716 <vprintfmt+0x3e5>
				printfmt(putch, putdat, "error %d", err);
  800471:	50                   	push   %eax
  800472:	68 1f 15 80 00       	push   $0x80151f
  800477:	53                   	push   %ebx
  800478:	56                   	push   %esi
  800479:	e8 92 fe ff ff       	call   800310 <printfmt>
  80047e:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800481:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800484:	e9 8d 02 00 00       	jmp    800716 <vprintfmt+0x3e5>
			if ((p = va_arg(ap, char *)) == NULL)
  800489:	8b 45 14             	mov    0x14(%ebp),%eax
  80048c:	83 c0 04             	add    $0x4,%eax
  80048f:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800492:	8b 45 14             	mov    0x14(%ebp),%eax
  800495:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  800497:	85 d2                	test   %edx,%edx
  800499:	b8 18 15 80 00       	mov    $0x801518,%eax
  80049e:	0f 45 c2             	cmovne %edx,%eax
  8004a1:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8004a4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004a8:	7e 06                	jle    8004b0 <vprintfmt+0x17f>
  8004aa:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  8004ae:	75 0d                	jne    8004bd <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004b0:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8004b3:	89 c7                	mov    %eax,%edi
  8004b5:	03 45 e0             	add    -0x20(%ebp),%eax
  8004b8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004bb:	eb 55                	jmp    800512 <vprintfmt+0x1e1>
  8004bd:	83 ec 08             	sub    $0x8,%esp
  8004c0:	ff 75 d8             	pushl  -0x28(%ebp)
  8004c3:	ff 75 cc             	pushl  -0x34(%ebp)
  8004c6:	e8 85 03 00 00       	call   800850 <strnlen>
  8004cb:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8004ce:	29 c2                	sub    %eax,%edx
  8004d0:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  8004d3:	83 c4 10             	add    $0x10,%esp
  8004d6:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  8004d8:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8004dc:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8004df:	85 ff                	test   %edi,%edi
  8004e1:	7e 11                	jle    8004f4 <vprintfmt+0x1c3>
					putch(padc, putdat);
  8004e3:	83 ec 08             	sub    $0x8,%esp
  8004e6:	53                   	push   %ebx
  8004e7:	ff 75 e0             	pushl  -0x20(%ebp)
  8004ea:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ec:	83 ef 01             	sub    $0x1,%edi
  8004ef:	83 c4 10             	add    $0x10,%esp
  8004f2:	eb eb                	jmp    8004df <vprintfmt+0x1ae>
  8004f4:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8004f7:	85 d2                	test   %edx,%edx
  8004f9:	b8 00 00 00 00       	mov    $0x0,%eax
  8004fe:	0f 49 c2             	cmovns %edx,%eax
  800501:	29 c2                	sub    %eax,%edx
  800503:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800506:	eb a8                	jmp    8004b0 <vprintfmt+0x17f>
					putch(ch, putdat);
  800508:	83 ec 08             	sub    $0x8,%esp
  80050b:	53                   	push   %ebx
  80050c:	52                   	push   %edx
  80050d:	ff d6                	call   *%esi
  80050f:	83 c4 10             	add    $0x10,%esp
  800512:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800515:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800517:	83 c7 01             	add    $0x1,%edi
  80051a:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80051e:	0f be d0             	movsbl %al,%edx
  800521:	85 d2                	test   %edx,%edx
  800523:	74 4b                	je     800570 <vprintfmt+0x23f>
  800525:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800529:	78 06                	js     800531 <vprintfmt+0x200>
  80052b:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  80052f:	78 1e                	js     80054f <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
  800531:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800535:	74 d1                	je     800508 <vprintfmt+0x1d7>
  800537:	0f be c0             	movsbl %al,%eax
  80053a:	83 e8 20             	sub    $0x20,%eax
  80053d:	83 f8 5e             	cmp    $0x5e,%eax
  800540:	76 c6                	jbe    800508 <vprintfmt+0x1d7>
					putch('?', putdat);
  800542:	83 ec 08             	sub    $0x8,%esp
  800545:	53                   	push   %ebx
  800546:	6a 3f                	push   $0x3f
  800548:	ff d6                	call   *%esi
  80054a:	83 c4 10             	add    $0x10,%esp
  80054d:	eb c3                	jmp    800512 <vprintfmt+0x1e1>
  80054f:	89 cf                	mov    %ecx,%edi
  800551:	eb 0e                	jmp    800561 <vprintfmt+0x230>
				putch(' ', putdat);
  800553:	83 ec 08             	sub    $0x8,%esp
  800556:	53                   	push   %ebx
  800557:	6a 20                	push   $0x20
  800559:	ff d6                	call   *%esi
			for (; width > 0; width--)
  80055b:	83 ef 01             	sub    $0x1,%edi
  80055e:	83 c4 10             	add    $0x10,%esp
  800561:	85 ff                	test   %edi,%edi
  800563:	7f ee                	jg     800553 <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  800565:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800568:	89 45 14             	mov    %eax,0x14(%ebp)
  80056b:	e9 a6 01 00 00       	jmp    800716 <vprintfmt+0x3e5>
  800570:	89 cf                	mov    %ecx,%edi
  800572:	eb ed                	jmp    800561 <vprintfmt+0x230>
	if (lflag >= 2)
  800574:	83 f9 01             	cmp    $0x1,%ecx
  800577:	7f 1f                	jg     800598 <vprintfmt+0x267>
	else if (lflag)
  800579:	85 c9                	test   %ecx,%ecx
  80057b:	74 67                	je     8005e4 <vprintfmt+0x2b3>
		return va_arg(*ap, long);
  80057d:	8b 45 14             	mov    0x14(%ebp),%eax
  800580:	8b 00                	mov    (%eax),%eax
  800582:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800585:	89 c1                	mov    %eax,%ecx
  800587:	c1 f9 1f             	sar    $0x1f,%ecx
  80058a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80058d:	8b 45 14             	mov    0x14(%ebp),%eax
  800590:	8d 40 04             	lea    0x4(%eax),%eax
  800593:	89 45 14             	mov    %eax,0x14(%ebp)
  800596:	eb 17                	jmp    8005af <vprintfmt+0x27e>
		return va_arg(*ap, long long);
  800598:	8b 45 14             	mov    0x14(%ebp),%eax
  80059b:	8b 50 04             	mov    0x4(%eax),%edx
  80059e:	8b 00                	mov    (%eax),%eax
  8005a0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005a3:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a9:	8d 40 08             	lea    0x8(%eax),%eax
  8005ac:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8005af:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005b2:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8005b5:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  8005ba:	85 c9                	test   %ecx,%ecx
  8005bc:	0f 89 3a 01 00 00    	jns    8006fc <vprintfmt+0x3cb>
				putch('-', putdat);
  8005c2:	83 ec 08             	sub    $0x8,%esp
  8005c5:	53                   	push   %ebx
  8005c6:	6a 2d                	push   $0x2d
  8005c8:	ff d6                	call   *%esi
				num = -(long long) num;
  8005ca:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005cd:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005d0:	f7 da                	neg    %edx
  8005d2:	83 d1 00             	adc    $0x0,%ecx
  8005d5:	f7 d9                	neg    %ecx
  8005d7:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8005da:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005df:	e9 18 01 00 00       	jmp    8006fc <vprintfmt+0x3cb>
		return va_arg(*ap, int);
  8005e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e7:	8b 00                	mov    (%eax),%eax
  8005e9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005ec:	89 c1                	mov    %eax,%ecx
  8005ee:	c1 f9 1f             	sar    $0x1f,%ecx
  8005f1:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f7:	8d 40 04             	lea    0x4(%eax),%eax
  8005fa:	89 45 14             	mov    %eax,0x14(%ebp)
  8005fd:	eb b0                	jmp    8005af <vprintfmt+0x27e>
	if (lflag >= 2)
  8005ff:	83 f9 01             	cmp    $0x1,%ecx
  800602:	7f 1e                	jg     800622 <vprintfmt+0x2f1>
	else if (lflag)
  800604:	85 c9                	test   %ecx,%ecx
  800606:	74 32                	je     80063a <vprintfmt+0x309>
		return va_arg(*ap, unsigned long);
  800608:	8b 45 14             	mov    0x14(%ebp),%eax
  80060b:	8b 10                	mov    (%eax),%edx
  80060d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800612:	8d 40 04             	lea    0x4(%eax),%eax
  800615:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800618:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  80061d:	e9 da 00 00 00       	jmp    8006fc <vprintfmt+0x3cb>
		return va_arg(*ap, unsigned long long);
  800622:	8b 45 14             	mov    0x14(%ebp),%eax
  800625:	8b 10                	mov    (%eax),%edx
  800627:	8b 48 04             	mov    0x4(%eax),%ecx
  80062a:	8d 40 08             	lea    0x8(%eax),%eax
  80062d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800630:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  800635:	e9 c2 00 00 00       	jmp    8006fc <vprintfmt+0x3cb>
		return va_arg(*ap, unsigned int);
  80063a:	8b 45 14             	mov    0x14(%ebp),%eax
  80063d:	8b 10                	mov    (%eax),%edx
  80063f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800644:	8d 40 04             	lea    0x4(%eax),%eax
  800647:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80064a:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  80064f:	e9 a8 00 00 00       	jmp    8006fc <vprintfmt+0x3cb>
	if (lflag >= 2)
  800654:	83 f9 01             	cmp    $0x1,%ecx
  800657:	7f 1b                	jg     800674 <vprintfmt+0x343>
	else if (lflag)
  800659:	85 c9                	test   %ecx,%ecx
  80065b:	74 5c                	je     8006b9 <vprintfmt+0x388>
		return va_arg(*ap, long);
  80065d:	8b 45 14             	mov    0x14(%ebp),%eax
  800660:	8b 00                	mov    (%eax),%eax
  800662:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800665:	99                   	cltd   
  800666:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800669:	8b 45 14             	mov    0x14(%ebp),%eax
  80066c:	8d 40 04             	lea    0x4(%eax),%eax
  80066f:	89 45 14             	mov    %eax,0x14(%ebp)
  800672:	eb 17                	jmp    80068b <vprintfmt+0x35a>
		return va_arg(*ap, long long);
  800674:	8b 45 14             	mov    0x14(%ebp),%eax
  800677:	8b 50 04             	mov    0x4(%eax),%edx
  80067a:	8b 00                	mov    (%eax),%eax
  80067c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80067f:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800682:	8b 45 14             	mov    0x14(%ebp),%eax
  800685:	8d 40 08             	lea    0x8(%eax),%eax
  800688:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80068b:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80068e:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 8;
  800691:	b8 08 00 00 00       	mov    $0x8,%eax
			if ((long long) num < 0) {
  800696:	85 c9                	test   %ecx,%ecx
  800698:	79 62                	jns    8006fc <vprintfmt+0x3cb>
				putch('-', putdat);
  80069a:	83 ec 08             	sub    $0x8,%esp
  80069d:	53                   	push   %ebx
  80069e:	6a 2d                	push   $0x2d
  8006a0:	ff d6                	call   *%esi
				num = -(long long) num;
  8006a2:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8006a5:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8006a8:	f7 da                	neg    %edx
  8006aa:	83 d1 00             	adc    $0x0,%ecx
  8006ad:	f7 d9                	neg    %ecx
  8006af:	83 c4 10             	add    $0x10,%esp
			base = 8;
  8006b2:	b8 08 00 00 00       	mov    $0x8,%eax
  8006b7:	eb 43                	jmp    8006fc <vprintfmt+0x3cb>
		return va_arg(*ap, int);
  8006b9:	8b 45 14             	mov    0x14(%ebp),%eax
  8006bc:	8b 00                	mov    (%eax),%eax
  8006be:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006c1:	89 c1                	mov    %eax,%ecx
  8006c3:	c1 f9 1f             	sar    $0x1f,%ecx
  8006c6:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006c9:	8b 45 14             	mov    0x14(%ebp),%eax
  8006cc:	8d 40 04             	lea    0x4(%eax),%eax
  8006cf:	89 45 14             	mov    %eax,0x14(%ebp)
  8006d2:	eb b7                	jmp    80068b <vprintfmt+0x35a>
			putch('0', putdat);
  8006d4:	83 ec 08             	sub    $0x8,%esp
  8006d7:	53                   	push   %ebx
  8006d8:	6a 30                	push   $0x30
  8006da:	ff d6                	call   *%esi
			putch('x', putdat);
  8006dc:	83 c4 08             	add    $0x8,%esp
  8006df:	53                   	push   %ebx
  8006e0:	6a 78                	push   $0x78
  8006e2:	ff d6                	call   *%esi
			num = (unsigned long long)
  8006e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e7:	8b 10                	mov    (%eax),%edx
  8006e9:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8006ee:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8006f1:	8d 40 04             	lea    0x4(%eax),%eax
  8006f4:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006f7:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  8006fc:	83 ec 0c             	sub    $0xc,%esp
  8006ff:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  800703:	57                   	push   %edi
  800704:	ff 75 e0             	pushl  -0x20(%ebp)
  800707:	50                   	push   %eax
  800708:	51                   	push   %ecx
  800709:	52                   	push   %edx
  80070a:	89 da                	mov    %ebx,%edx
  80070c:	89 f0                	mov    %esi,%eax
  80070e:	e8 33 fb ff ff       	call   800246 <printnum>
			break;
  800713:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  800716:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800719:	83 c7 01             	add    $0x1,%edi
  80071c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800720:	83 f8 25             	cmp    $0x25,%eax
  800723:	0f 84 23 fc ff ff    	je     80034c <vprintfmt+0x1b>
			if (ch == '\0')
  800729:	85 c0                	test   %eax,%eax
  80072b:	0f 84 8b 00 00 00    	je     8007bc <vprintfmt+0x48b>
			putch(ch, putdat);
  800731:	83 ec 08             	sub    $0x8,%esp
  800734:	53                   	push   %ebx
  800735:	50                   	push   %eax
  800736:	ff d6                	call   *%esi
  800738:	83 c4 10             	add    $0x10,%esp
  80073b:	eb dc                	jmp    800719 <vprintfmt+0x3e8>
	if (lflag >= 2)
  80073d:	83 f9 01             	cmp    $0x1,%ecx
  800740:	7f 1b                	jg     80075d <vprintfmt+0x42c>
	else if (lflag)
  800742:	85 c9                	test   %ecx,%ecx
  800744:	74 2c                	je     800772 <vprintfmt+0x441>
		return va_arg(*ap, unsigned long);
  800746:	8b 45 14             	mov    0x14(%ebp),%eax
  800749:	8b 10                	mov    (%eax),%edx
  80074b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800750:	8d 40 04             	lea    0x4(%eax),%eax
  800753:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800756:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  80075b:	eb 9f                	jmp    8006fc <vprintfmt+0x3cb>
		return va_arg(*ap, unsigned long long);
  80075d:	8b 45 14             	mov    0x14(%ebp),%eax
  800760:	8b 10                	mov    (%eax),%edx
  800762:	8b 48 04             	mov    0x4(%eax),%ecx
  800765:	8d 40 08             	lea    0x8(%eax),%eax
  800768:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80076b:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  800770:	eb 8a                	jmp    8006fc <vprintfmt+0x3cb>
		return va_arg(*ap, unsigned int);
  800772:	8b 45 14             	mov    0x14(%ebp),%eax
  800775:	8b 10                	mov    (%eax),%edx
  800777:	b9 00 00 00 00       	mov    $0x0,%ecx
  80077c:	8d 40 04             	lea    0x4(%eax),%eax
  80077f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800782:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  800787:	e9 70 ff ff ff       	jmp    8006fc <vprintfmt+0x3cb>
			putch(ch, putdat);
  80078c:	83 ec 08             	sub    $0x8,%esp
  80078f:	53                   	push   %ebx
  800790:	6a 25                	push   $0x25
  800792:	ff d6                	call   *%esi
			break;
  800794:	83 c4 10             	add    $0x10,%esp
  800797:	e9 7a ff ff ff       	jmp    800716 <vprintfmt+0x3e5>
			putch('%', putdat);
  80079c:	83 ec 08             	sub    $0x8,%esp
  80079f:	53                   	push   %ebx
  8007a0:	6a 25                	push   $0x25
  8007a2:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007a4:	83 c4 10             	add    $0x10,%esp
  8007a7:	89 f8                	mov    %edi,%eax
  8007a9:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8007ad:	74 05                	je     8007b4 <vprintfmt+0x483>
  8007af:	83 e8 01             	sub    $0x1,%eax
  8007b2:	eb f5                	jmp    8007a9 <vprintfmt+0x478>
  8007b4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8007b7:	e9 5a ff ff ff       	jmp    800716 <vprintfmt+0x3e5>
}
  8007bc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007bf:	5b                   	pop    %ebx
  8007c0:	5e                   	pop    %esi
  8007c1:	5f                   	pop    %edi
  8007c2:	5d                   	pop    %ebp
  8007c3:	c3                   	ret    

008007c4 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007c4:	f3 0f 1e fb          	endbr32 
  8007c8:	55                   	push   %ebp
  8007c9:	89 e5                	mov    %esp,%ebp
  8007cb:	83 ec 18             	sub    $0x18,%esp
  8007ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8007d1:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007d4:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007d7:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007db:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007de:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007e5:	85 c0                	test   %eax,%eax
  8007e7:	74 26                	je     80080f <vsnprintf+0x4b>
  8007e9:	85 d2                	test   %edx,%edx
  8007eb:	7e 22                	jle    80080f <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007ed:	ff 75 14             	pushl  0x14(%ebp)
  8007f0:	ff 75 10             	pushl  0x10(%ebp)
  8007f3:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007f6:	50                   	push   %eax
  8007f7:	68 ef 02 80 00       	push   $0x8002ef
  8007fc:	e8 30 fb ff ff       	call   800331 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800801:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800804:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800807:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80080a:	83 c4 10             	add    $0x10,%esp
}
  80080d:	c9                   	leave  
  80080e:	c3                   	ret    
		return -E_INVAL;
  80080f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800814:	eb f7                	jmp    80080d <vsnprintf+0x49>

00800816 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800816:	f3 0f 1e fb          	endbr32 
  80081a:	55                   	push   %ebp
  80081b:	89 e5                	mov    %esp,%ebp
  80081d:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800820:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800823:	50                   	push   %eax
  800824:	ff 75 10             	pushl  0x10(%ebp)
  800827:	ff 75 0c             	pushl  0xc(%ebp)
  80082a:	ff 75 08             	pushl  0x8(%ebp)
  80082d:	e8 92 ff ff ff       	call   8007c4 <vsnprintf>
	va_end(ap);

	return rc;
}
  800832:	c9                   	leave  
  800833:	c3                   	ret    

00800834 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800834:	f3 0f 1e fb          	endbr32 
  800838:	55                   	push   %ebp
  800839:	89 e5                	mov    %esp,%ebp
  80083b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80083e:	b8 00 00 00 00       	mov    $0x0,%eax
  800843:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800847:	74 05                	je     80084e <strlen+0x1a>
		n++;
  800849:	83 c0 01             	add    $0x1,%eax
  80084c:	eb f5                	jmp    800843 <strlen+0xf>
	return n;
}
  80084e:	5d                   	pop    %ebp
  80084f:	c3                   	ret    

00800850 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800850:	f3 0f 1e fb          	endbr32 
  800854:	55                   	push   %ebp
  800855:	89 e5                	mov    %esp,%ebp
  800857:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80085a:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80085d:	b8 00 00 00 00       	mov    $0x0,%eax
  800862:	39 d0                	cmp    %edx,%eax
  800864:	74 0d                	je     800873 <strnlen+0x23>
  800866:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80086a:	74 05                	je     800871 <strnlen+0x21>
		n++;
  80086c:	83 c0 01             	add    $0x1,%eax
  80086f:	eb f1                	jmp    800862 <strnlen+0x12>
  800871:	89 c2                	mov    %eax,%edx
	return n;
}
  800873:	89 d0                	mov    %edx,%eax
  800875:	5d                   	pop    %ebp
  800876:	c3                   	ret    

00800877 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800877:	f3 0f 1e fb          	endbr32 
  80087b:	55                   	push   %ebp
  80087c:	89 e5                	mov    %esp,%ebp
  80087e:	53                   	push   %ebx
  80087f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800882:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800885:	b8 00 00 00 00       	mov    $0x0,%eax
  80088a:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  80088e:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800891:	83 c0 01             	add    $0x1,%eax
  800894:	84 d2                	test   %dl,%dl
  800896:	75 f2                	jne    80088a <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  800898:	89 c8                	mov    %ecx,%eax
  80089a:	5b                   	pop    %ebx
  80089b:	5d                   	pop    %ebp
  80089c:	c3                   	ret    

0080089d <strcat>:

char *
strcat(char *dst, const char *src)
{
  80089d:	f3 0f 1e fb          	endbr32 
  8008a1:	55                   	push   %ebp
  8008a2:	89 e5                	mov    %esp,%ebp
  8008a4:	53                   	push   %ebx
  8008a5:	83 ec 10             	sub    $0x10,%esp
  8008a8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008ab:	53                   	push   %ebx
  8008ac:	e8 83 ff ff ff       	call   800834 <strlen>
  8008b1:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8008b4:	ff 75 0c             	pushl  0xc(%ebp)
  8008b7:	01 d8                	add    %ebx,%eax
  8008b9:	50                   	push   %eax
  8008ba:	e8 b8 ff ff ff       	call   800877 <strcpy>
	return dst;
}
  8008bf:	89 d8                	mov    %ebx,%eax
  8008c1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008c4:	c9                   	leave  
  8008c5:	c3                   	ret    

008008c6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008c6:	f3 0f 1e fb          	endbr32 
  8008ca:	55                   	push   %ebp
  8008cb:	89 e5                	mov    %esp,%ebp
  8008cd:	56                   	push   %esi
  8008ce:	53                   	push   %ebx
  8008cf:	8b 75 08             	mov    0x8(%ebp),%esi
  8008d2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008d5:	89 f3                	mov    %esi,%ebx
  8008d7:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008da:	89 f0                	mov    %esi,%eax
  8008dc:	39 d8                	cmp    %ebx,%eax
  8008de:	74 11                	je     8008f1 <strncpy+0x2b>
		*dst++ = *src;
  8008e0:	83 c0 01             	add    $0x1,%eax
  8008e3:	0f b6 0a             	movzbl (%edx),%ecx
  8008e6:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008e9:	80 f9 01             	cmp    $0x1,%cl
  8008ec:	83 da ff             	sbb    $0xffffffff,%edx
  8008ef:	eb eb                	jmp    8008dc <strncpy+0x16>
	}
	return ret;
}
  8008f1:	89 f0                	mov    %esi,%eax
  8008f3:	5b                   	pop    %ebx
  8008f4:	5e                   	pop    %esi
  8008f5:	5d                   	pop    %ebp
  8008f6:	c3                   	ret    

008008f7 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008f7:	f3 0f 1e fb          	endbr32 
  8008fb:	55                   	push   %ebp
  8008fc:	89 e5                	mov    %esp,%ebp
  8008fe:	56                   	push   %esi
  8008ff:	53                   	push   %ebx
  800900:	8b 75 08             	mov    0x8(%ebp),%esi
  800903:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800906:	8b 55 10             	mov    0x10(%ebp),%edx
  800909:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80090b:	85 d2                	test   %edx,%edx
  80090d:	74 21                	je     800930 <strlcpy+0x39>
  80090f:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800913:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  800915:	39 c2                	cmp    %eax,%edx
  800917:	74 14                	je     80092d <strlcpy+0x36>
  800919:	0f b6 19             	movzbl (%ecx),%ebx
  80091c:	84 db                	test   %bl,%bl
  80091e:	74 0b                	je     80092b <strlcpy+0x34>
			*dst++ = *src++;
  800920:	83 c1 01             	add    $0x1,%ecx
  800923:	83 c2 01             	add    $0x1,%edx
  800926:	88 5a ff             	mov    %bl,-0x1(%edx)
  800929:	eb ea                	jmp    800915 <strlcpy+0x1e>
  80092b:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  80092d:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800930:	29 f0                	sub    %esi,%eax
}
  800932:	5b                   	pop    %ebx
  800933:	5e                   	pop    %esi
  800934:	5d                   	pop    %ebp
  800935:	c3                   	ret    

00800936 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800936:	f3 0f 1e fb          	endbr32 
  80093a:	55                   	push   %ebp
  80093b:	89 e5                	mov    %esp,%ebp
  80093d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800940:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800943:	0f b6 01             	movzbl (%ecx),%eax
  800946:	84 c0                	test   %al,%al
  800948:	74 0c                	je     800956 <strcmp+0x20>
  80094a:	3a 02                	cmp    (%edx),%al
  80094c:	75 08                	jne    800956 <strcmp+0x20>
		p++, q++;
  80094e:	83 c1 01             	add    $0x1,%ecx
  800951:	83 c2 01             	add    $0x1,%edx
  800954:	eb ed                	jmp    800943 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800956:	0f b6 c0             	movzbl %al,%eax
  800959:	0f b6 12             	movzbl (%edx),%edx
  80095c:	29 d0                	sub    %edx,%eax
}
  80095e:	5d                   	pop    %ebp
  80095f:	c3                   	ret    

00800960 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800960:	f3 0f 1e fb          	endbr32 
  800964:	55                   	push   %ebp
  800965:	89 e5                	mov    %esp,%ebp
  800967:	53                   	push   %ebx
  800968:	8b 45 08             	mov    0x8(%ebp),%eax
  80096b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80096e:	89 c3                	mov    %eax,%ebx
  800970:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800973:	eb 06                	jmp    80097b <strncmp+0x1b>
		n--, p++, q++;
  800975:	83 c0 01             	add    $0x1,%eax
  800978:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  80097b:	39 d8                	cmp    %ebx,%eax
  80097d:	74 16                	je     800995 <strncmp+0x35>
  80097f:	0f b6 08             	movzbl (%eax),%ecx
  800982:	84 c9                	test   %cl,%cl
  800984:	74 04                	je     80098a <strncmp+0x2a>
  800986:	3a 0a                	cmp    (%edx),%cl
  800988:	74 eb                	je     800975 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80098a:	0f b6 00             	movzbl (%eax),%eax
  80098d:	0f b6 12             	movzbl (%edx),%edx
  800990:	29 d0                	sub    %edx,%eax
}
  800992:	5b                   	pop    %ebx
  800993:	5d                   	pop    %ebp
  800994:	c3                   	ret    
		return 0;
  800995:	b8 00 00 00 00       	mov    $0x0,%eax
  80099a:	eb f6                	jmp    800992 <strncmp+0x32>

0080099c <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80099c:	f3 0f 1e fb          	endbr32 
  8009a0:	55                   	push   %ebp
  8009a1:	89 e5                	mov    %esp,%ebp
  8009a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a6:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009aa:	0f b6 10             	movzbl (%eax),%edx
  8009ad:	84 d2                	test   %dl,%dl
  8009af:	74 09                	je     8009ba <strchr+0x1e>
		if (*s == c)
  8009b1:	38 ca                	cmp    %cl,%dl
  8009b3:	74 0a                	je     8009bf <strchr+0x23>
	for (; *s; s++)
  8009b5:	83 c0 01             	add    $0x1,%eax
  8009b8:	eb f0                	jmp    8009aa <strchr+0xe>
			return (char *) s;
	return 0;
  8009ba:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009bf:	5d                   	pop    %ebp
  8009c0:	c3                   	ret    

008009c1 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009c1:	f3 0f 1e fb          	endbr32 
  8009c5:	55                   	push   %ebp
  8009c6:	89 e5                	mov    %esp,%ebp
  8009c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8009cb:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009cf:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8009d2:	38 ca                	cmp    %cl,%dl
  8009d4:	74 09                	je     8009df <strfind+0x1e>
  8009d6:	84 d2                	test   %dl,%dl
  8009d8:	74 05                	je     8009df <strfind+0x1e>
	for (; *s; s++)
  8009da:	83 c0 01             	add    $0x1,%eax
  8009dd:	eb f0                	jmp    8009cf <strfind+0xe>
			break;
	return (char *) s;
}
  8009df:	5d                   	pop    %ebp
  8009e0:	c3                   	ret    

008009e1 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009e1:	f3 0f 1e fb          	endbr32 
  8009e5:	55                   	push   %ebp
  8009e6:	89 e5                	mov    %esp,%ebp
  8009e8:	57                   	push   %edi
  8009e9:	56                   	push   %esi
  8009ea:	53                   	push   %ebx
  8009eb:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009ee:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009f1:	85 c9                	test   %ecx,%ecx
  8009f3:	74 31                	je     800a26 <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009f5:	89 f8                	mov    %edi,%eax
  8009f7:	09 c8                	or     %ecx,%eax
  8009f9:	a8 03                	test   $0x3,%al
  8009fb:	75 23                	jne    800a20 <memset+0x3f>
		c &= 0xFF;
  8009fd:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a01:	89 d3                	mov    %edx,%ebx
  800a03:	c1 e3 08             	shl    $0x8,%ebx
  800a06:	89 d0                	mov    %edx,%eax
  800a08:	c1 e0 18             	shl    $0x18,%eax
  800a0b:	89 d6                	mov    %edx,%esi
  800a0d:	c1 e6 10             	shl    $0x10,%esi
  800a10:	09 f0                	or     %esi,%eax
  800a12:	09 c2                	or     %eax,%edx
  800a14:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a16:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800a19:	89 d0                	mov    %edx,%eax
  800a1b:	fc                   	cld    
  800a1c:	f3 ab                	rep stos %eax,%es:(%edi)
  800a1e:	eb 06                	jmp    800a26 <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a20:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a23:	fc                   	cld    
  800a24:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a26:	89 f8                	mov    %edi,%eax
  800a28:	5b                   	pop    %ebx
  800a29:	5e                   	pop    %esi
  800a2a:	5f                   	pop    %edi
  800a2b:	5d                   	pop    %ebp
  800a2c:	c3                   	ret    

00800a2d <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a2d:	f3 0f 1e fb          	endbr32 
  800a31:	55                   	push   %ebp
  800a32:	89 e5                	mov    %esp,%ebp
  800a34:	57                   	push   %edi
  800a35:	56                   	push   %esi
  800a36:	8b 45 08             	mov    0x8(%ebp),%eax
  800a39:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a3c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a3f:	39 c6                	cmp    %eax,%esi
  800a41:	73 32                	jae    800a75 <memmove+0x48>
  800a43:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a46:	39 c2                	cmp    %eax,%edx
  800a48:	76 2b                	jbe    800a75 <memmove+0x48>
		s += n;
		d += n;
  800a4a:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a4d:	89 fe                	mov    %edi,%esi
  800a4f:	09 ce                	or     %ecx,%esi
  800a51:	09 d6                	or     %edx,%esi
  800a53:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a59:	75 0e                	jne    800a69 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a5b:	83 ef 04             	sub    $0x4,%edi
  800a5e:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a61:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800a64:	fd                   	std    
  800a65:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a67:	eb 09                	jmp    800a72 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a69:	83 ef 01             	sub    $0x1,%edi
  800a6c:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800a6f:	fd                   	std    
  800a70:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a72:	fc                   	cld    
  800a73:	eb 1a                	jmp    800a8f <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a75:	89 c2                	mov    %eax,%edx
  800a77:	09 ca                	or     %ecx,%edx
  800a79:	09 f2                	or     %esi,%edx
  800a7b:	f6 c2 03             	test   $0x3,%dl
  800a7e:	75 0a                	jne    800a8a <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a80:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800a83:	89 c7                	mov    %eax,%edi
  800a85:	fc                   	cld    
  800a86:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a88:	eb 05                	jmp    800a8f <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800a8a:	89 c7                	mov    %eax,%edi
  800a8c:	fc                   	cld    
  800a8d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a8f:	5e                   	pop    %esi
  800a90:	5f                   	pop    %edi
  800a91:	5d                   	pop    %ebp
  800a92:	c3                   	ret    

00800a93 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a93:	f3 0f 1e fb          	endbr32 
  800a97:	55                   	push   %ebp
  800a98:	89 e5                	mov    %esp,%ebp
  800a9a:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a9d:	ff 75 10             	pushl  0x10(%ebp)
  800aa0:	ff 75 0c             	pushl  0xc(%ebp)
  800aa3:	ff 75 08             	pushl  0x8(%ebp)
  800aa6:	e8 82 ff ff ff       	call   800a2d <memmove>
}
  800aab:	c9                   	leave  
  800aac:	c3                   	ret    

00800aad <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800aad:	f3 0f 1e fb          	endbr32 
  800ab1:	55                   	push   %ebp
  800ab2:	89 e5                	mov    %esp,%ebp
  800ab4:	56                   	push   %esi
  800ab5:	53                   	push   %ebx
  800ab6:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab9:	8b 55 0c             	mov    0xc(%ebp),%edx
  800abc:	89 c6                	mov    %eax,%esi
  800abe:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ac1:	39 f0                	cmp    %esi,%eax
  800ac3:	74 1c                	je     800ae1 <memcmp+0x34>
		if (*s1 != *s2)
  800ac5:	0f b6 08             	movzbl (%eax),%ecx
  800ac8:	0f b6 1a             	movzbl (%edx),%ebx
  800acb:	38 d9                	cmp    %bl,%cl
  800acd:	75 08                	jne    800ad7 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800acf:	83 c0 01             	add    $0x1,%eax
  800ad2:	83 c2 01             	add    $0x1,%edx
  800ad5:	eb ea                	jmp    800ac1 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800ad7:	0f b6 c1             	movzbl %cl,%eax
  800ada:	0f b6 db             	movzbl %bl,%ebx
  800add:	29 d8                	sub    %ebx,%eax
  800adf:	eb 05                	jmp    800ae6 <memcmp+0x39>
	}

	return 0;
  800ae1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ae6:	5b                   	pop    %ebx
  800ae7:	5e                   	pop    %esi
  800ae8:	5d                   	pop    %ebp
  800ae9:	c3                   	ret    

00800aea <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800aea:	f3 0f 1e fb          	endbr32 
  800aee:	55                   	push   %ebp
  800aef:	89 e5                	mov    %esp,%ebp
  800af1:	8b 45 08             	mov    0x8(%ebp),%eax
  800af4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800af7:	89 c2                	mov    %eax,%edx
  800af9:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800afc:	39 d0                	cmp    %edx,%eax
  800afe:	73 09                	jae    800b09 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b00:	38 08                	cmp    %cl,(%eax)
  800b02:	74 05                	je     800b09 <memfind+0x1f>
	for (; s < ends; s++)
  800b04:	83 c0 01             	add    $0x1,%eax
  800b07:	eb f3                	jmp    800afc <memfind+0x12>
			break;
	return (void *) s;
}
  800b09:	5d                   	pop    %ebp
  800b0a:	c3                   	ret    

00800b0b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b0b:	f3 0f 1e fb          	endbr32 
  800b0f:	55                   	push   %ebp
  800b10:	89 e5                	mov    %esp,%ebp
  800b12:	57                   	push   %edi
  800b13:	56                   	push   %esi
  800b14:	53                   	push   %ebx
  800b15:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b18:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b1b:	eb 03                	jmp    800b20 <strtol+0x15>
		s++;
  800b1d:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800b20:	0f b6 01             	movzbl (%ecx),%eax
  800b23:	3c 20                	cmp    $0x20,%al
  800b25:	74 f6                	je     800b1d <strtol+0x12>
  800b27:	3c 09                	cmp    $0x9,%al
  800b29:	74 f2                	je     800b1d <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800b2b:	3c 2b                	cmp    $0x2b,%al
  800b2d:	74 2a                	je     800b59 <strtol+0x4e>
	int neg = 0;
  800b2f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800b34:	3c 2d                	cmp    $0x2d,%al
  800b36:	74 2b                	je     800b63 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b38:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b3e:	75 0f                	jne    800b4f <strtol+0x44>
  800b40:	80 39 30             	cmpb   $0x30,(%ecx)
  800b43:	74 28                	je     800b6d <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b45:	85 db                	test   %ebx,%ebx
  800b47:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b4c:	0f 44 d8             	cmove  %eax,%ebx
  800b4f:	b8 00 00 00 00       	mov    $0x0,%eax
  800b54:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800b57:	eb 46                	jmp    800b9f <strtol+0x94>
		s++;
  800b59:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800b5c:	bf 00 00 00 00       	mov    $0x0,%edi
  800b61:	eb d5                	jmp    800b38 <strtol+0x2d>
		s++, neg = 1;
  800b63:	83 c1 01             	add    $0x1,%ecx
  800b66:	bf 01 00 00 00       	mov    $0x1,%edi
  800b6b:	eb cb                	jmp    800b38 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b6d:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b71:	74 0e                	je     800b81 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800b73:	85 db                	test   %ebx,%ebx
  800b75:	75 d8                	jne    800b4f <strtol+0x44>
		s++, base = 8;
  800b77:	83 c1 01             	add    $0x1,%ecx
  800b7a:	bb 08 00 00 00       	mov    $0x8,%ebx
  800b7f:	eb ce                	jmp    800b4f <strtol+0x44>
		s += 2, base = 16;
  800b81:	83 c1 02             	add    $0x2,%ecx
  800b84:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b89:	eb c4                	jmp    800b4f <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800b8b:	0f be d2             	movsbl %dl,%edx
  800b8e:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b91:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b94:	7d 3a                	jge    800bd0 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800b96:	83 c1 01             	add    $0x1,%ecx
  800b99:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b9d:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800b9f:	0f b6 11             	movzbl (%ecx),%edx
  800ba2:	8d 72 d0             	lea    -0x30(%edx),%esi
  800ba5:	89 f3                	mov    %esi,%ebx
  800ba7:	80 fb 09             	cmp    $0x9,%bl
  800baa:	76 df                	jbe    800b8b <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800bac:	8d 72 9f             	lea    -0x61(%edx),%esi
  800baf:	89 f3                	mov    %esi,%ebx
  800bb1:	80 fb 19             	cmp    $0x19,%bl
  800bb4:	77 08                	ja     800bbe <strtol+0xb3>
			dig = *s - 'a' + 10;
  800bb6:	0f be d2             	movsbl %dl,%edx
  800bb9:	83 ea 57             	sub    $0x57,%edx
  800bbc:	eb d3                	jmp    800b91 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800bbe:	8d 72 bf             	lea    -0x41(%edx),%esi
  800bc1:	89 f3                	mov    %esi,%ebx
  800bc3:	80 fb 19             	cmp    $0x19,%bl
  800bc6:	77 08                	ja     800bd0 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800bc8:	0f be d2             	movsbl %dl,%edx
  800bcb:	83 ea 37             	sub    $0x37,%edx
  800bce:	eb c1                	jmp    800b91 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800bd0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bd4:	74 05                	je     800bdb <strtol+0xd0>
		*endptr = (char *) s;
  800bd6:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bd9:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800bdb:	89 c2                	mov    %eax,%edx
  800bdd:	f7 da                	neg    %edx
  800bdf:	85 ff                	test   %edi,%edi
  800be1:	0f 45 c2             	cmovne %edx,%eax
}
  800be4:	5b                   	pop    %ebx
  800be5:	5e                   	pop    %esi
  800be6:	5f                   	pop    %edi
  800be7:	5d                   	pop    %ebp
  800be8:	c3                   	ret    

00800be9 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800be9:	f3 0f 1e fb          	endbr32 
  800bed:	55                   	push   %ebp
  800bee:	89 e5                	mov    %esp,%ebp
  800bf0:	57                   	push   %edi
  800bf1:	56                   	push   %esi
  800bf2:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bf3:	b8 00 00 00 00       	mov    $0x0,%eax
  800bf8:	8b 55 08             	mov    0x8(%ebp),%edx
  800bfb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bfe:	89 c3                	mov    %eax,%ebx
  800c00:	89 c7                	mov    %eax,%edi
  800c02:	89 c6                	mov    %eax,%esi
  800c04:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c06:	5b                   	pop    %ebx
  800c07:	5e                   	pop    %esi
  800c08:	5f                   	pop    %edi
  800c09:	5d                   	pop    %ebp
  800c0a:	c3                   	ret    

00800c0b <sys_cgetc>:

int
sys_cgetc(void)
{
  800c0b:	f3 0f 1e fb          	endbr32 
  800c0f:	55                   	push   %ebp
  800c10:	89 e5                	mov    %esp,%ebp
  800c12:	57                   	push   %edi
  800c13:	56                   	push   %esi
  800c14:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c15:	ba 00 00 00 00       	mov    $0x0,%edx
  800c1a:	b8 01 00 00 00       	mov    $0x1,%eax
  800c1f:	89 d1                	mov    %edx,%ecx
  800c21:	89 d3                	mov    %edx,%ebx
  800c23:	89 d7                	mov    %edx,%edi
  800c25:	89 d6                	mov    %edx,%esi
  800c27:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c29:	5b                   	pop    %ebx
  800c2a:	5e                   	pop    %esi
  800c2b:	5f                   	pop    %edi
  800c2c:	5d                   	pop    %ebp
  800c2d:	c3                   	ret    

00800c2e <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c2e:	f3 0f 1e fb          	endbr32 
  800c32:	55                   	push   %ebp
  800c33:	89 e5                	mov    %esp,%ebp
  800c35:	57                   	push   %edi
  800c36:	56                   	push   %esi
  800c37:	53                   	push   %ebx
  800c38:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c3b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c40:	8b 55 08             	mov    0x8(%ebp),%edx
  800c43:	b8 03 00 00 00       	mov    $0x3,%eax
  800c48:	89 cb                	mov    %ecx,%ebx
  800c4a:	89 cf                	mov    %ecx,%edi
  800c4c:	89 ce                	mov    %ecx,%esi
  800c4e:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c50:	85 c0                	test   %eax,%eax
  800c52:	7f 08                	jg     800c5c <sys_env_destroy+0x2e>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c54:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c57:	5b                   	pop    %ebx
  800c58:	5e                   	pop    %esi
  800c59:	5f                   	pop    %edi
  800c5a:	5d                   	pop    %ebp
  800c5b:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c5c:	83 ec 0c             	sub    $0xc,%esp
  800c5f:	50                   	push   %eax
  800c60:	6a 03                	push   $0x3
  800c62:	68 44 17 80 00       	push   $0x801744
  800c67:	6a 23                	push   $0x23
  800c69:	68 61 17 80 00       	push   $0x801761
  800c6e:	e8 d4 f4 ff ff       	call   800147 <_panic>

00800c73 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c73:	f3 0f 1e fb          	endbr32 
  800c77:	55                   	push   %ebp
  800c78:	89 e5                	mov    %esp,%ebp
  800c7a:	57                   	push   %edi
  800c7b:	56                   	push   %esi
  800c7c:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c7d:	ba 00 00 00 00       	mov    $0x0,%edx
  800c82:	b8 02 00 00 00       	mov    $0x2,%eax
  800c87:	89 d1                	mov    %edx,%ecx
  800c89:	89 d3                	mov    %edx,%ebx
  800c8b:	89 d7                	mov    %edx,%edi
  800c8d:	89 d6                	mov    %edx,%esi
  800c8f:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c91:	5b                   	pop    %ebx
  800c92:	5e                   	pop    %esi
  800c93:	5f                   	pop    %edi
  800c94:	5d                   	pop    %ebp
  800c95:	c3                   	ret    

00800c96 <sys_yield>:

void
sys_yield(void)
{
  800c96:	f3 0f 1e fb          	endbr32 
  800c9a:	55                   	push   %ebp
  800c9b:	89 e5                	mov    %esp,%ebp
  800c9d:	57                   	push   %edi
  800c9e:	56                   	push   %esi
  800c9f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ca0:	ba 00 00 00 00       	mov    $0x0,%edx
  800ca5:	b8 0a 00 00 00       	mov    $0xa,%eax
  800caa:	89 d1                	mov    %edx,%ecx
  800cac:	89 d3                	mov    %edx,%ebx
  800cae:	89 d7                	mov    %edx,%edi
  800cb0:	89 d6                	mov    %edx,%esi
  800cb2:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800cb4:	5b                   	pop    %ebx
  800cb5:	5e                   	pop    %esi
  800cb6:	5f                   	pop    %edi
  800cb7:	5d                   	pop    %ebp
  800cb8:	c3                   	ret    

00800cb9 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800cb9:	f3 0f 1e fb          	endbr32 
  800cbd:	55                   	push   %ebp
  800cbe:	89 e5                	mov    %esp,%ebp
  800cc0:	57                   	push   %edi
  800cc1:	56                   	push   %esi
  800cc2:	53                   	push   %ebx
  800cc3:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cc6:	be 00 00 00 00       	mov    $0x0,%esi
  800ccb:	8b 55 08             	mov    0x8(%ebp),%edx
  800cce:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd1:	b8 04 00 00 00       	mov    $0x4,%eax
  800cd6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cd9:	89 f7                	mov    %esi,%edi
  800cdb:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cdd:	85 c0                	test   %eax,%eax
  800cdf:	7f 08                	jg     800ce9 <sys_page_alloc+0x30>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
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
  800ced:	6a 04                	push   $0x4
  800cef:	68 44 17 80 00       	push   $0x801744
  800cf4:	6a 23                	push   $0x23
  800cf6:	68 61 17 80 00       	push   $0x801761
  800cfb:	e8 47 f4 ff ff       	call   800147 <_panic>

00800d00 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d00:	f3 0f 1e fb          	endbr32 
  800d04:	55                   	push   %ebp
  800d05:	89 e5                	mov    %esp,%ebp
  800d07:	57                   	push   %edi
  800d08:	56                   	push   %esi
  800d09:	53                   	push   %ebx
  800d0a:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d0d:	8b 55 08             	mov    0x8(%ebp),%edx
  800d10:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d13:	b8 05 00 00 00       	mov    $0x5,%eax
  800d18:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d1b:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d1e:	8b 75 18             	mov    0x18(%ebp),%esi
  800d21:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d23:	85 c0                	test   %eax,%eax
  800d25:	7f 08                	jg     800d2f <sys_page_map+0x2f>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
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
  800d33:	6a 05                	push   $0x5
  800d35:	68 44 17 80 00       	push   $0x801744
  800d3a:	6a 23                	push   $0x23
  800d3c:	68 61 17 80 00       	push   $0x801761
  800d41:	e8 01 f4 ff ff       	call   800147 <_panic>

00800d46 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
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
  800d5e:	b8 06 00 00 00       	mov    $0x6,%eax
  800d63:	89 df                	mov    %ebx,%edi
  800d65:	89 de                	mov    %ebx,%esi
  800d67:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d69:	85 c0                	test   %eax,%eax
  800d6b:	7f 08                	jg     800d75 <sys_page_unmap+0x2f>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
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
  800d79:	6a 06                	push   $0x6
  800d7b:	68 44 17 80 00       	push   $0x801744
  800d80:	6a 23                	push   $0x23
  800d82:	68 61 17 80 00       	push   $0x801761
  800d87:	e8 bb f3 ff ff       	call   800147 <_panic>

00800d8c <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d8c:	f3 0f 1e fb          	endbr32 
  800d90:	55                   	push   %ebp
  800d91:	89 e5                	mov    %esp,%ebp
  800d93:	57                   	push   %edi
  800d94:	56                   	push   %esi
  800d95:	53                   	push   %ebx
  800d96:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d99:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d9e:	8b 55 08             	mov    0x8(%ebp),%edx
  800da1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800da4:	b8 08 00 00 00       	mov    $0x8,%eax
  800da9:	89 df                	mov    %ebx,%edi
  800dab:	89 de                	mov    %ebx,%esi
  800dad:	cd 30                	int    $0x30
	if(check && ret > 0)
  800daf:	85 c0                	test   %eax,%eax
  800db1:	7f 08                	jg     800dbb <sys_env_set_status+0x2f>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800db3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800db6:	5b                   	pop    %ebx
  800db7:	5e                   	pop    %esi
  800db8:	5f                   	pop    %edi
  800db9:	5d                   	pop    %ebp
  800dba:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800dbb:	83 ec 0c             	sub    $0xc,%esp
  800dbe:	50                   	push   %eax
  800dbf:	6a 08                	push   $0x8
  800dc1:	68 44 17 80 00       	push   $0x801744
  800dc6:	6a 23                	push   $0x23
  800dc8:	68 61 17 80 00       	push   $0x801761
  800dcd:	e8 75 f3 ff ff       	call   800147 <_panic>

00800dd2 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800dd2:	f3 0f 1e fb          	endbr32 
  800dd6:	55                   	push   %ebp
  800dd7:	89 e5                	mov    %esp,%ebp
  800dd9:	57                   	push   %edi
  800dda:	56                   	push   %esi
  800ddb:	53                   	push   %ebx
  800ddc:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800ddf:	bb 00 00 00 00       	mov    $0x0,%ebx
  800de4:	8b 55 08             	mov    0x8(%ebp),%edx
  800de7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dea:	b8 09 00 00 00       	mov    $0x9,%eax
  800def:	89 df                	mov    %ebx,%edi
  800df1:	89 de                	mov    %ebx,%esi
  800df3:	cd 30                	int    $0x30
	if(check && ret > 0)
  800df5:	85 c0                	test   %eax,%eax
  800df7:	7f 08                	jg     800e01 <sys_env_set_pgfault_upcall+0x2f>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800df9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dfc:	5b                   	pop    %ebx
  800dfd:	5e                   	pop    %esi
  800dfe:	5f                   	pop    %edi
  800dff:	5d                   	pop    %ebp
  800e00:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e01:	83 ec 0c             	sub    $0xc,%esp
  800e04:	50                   	push   %eax
  800e05:	6a 09                	push   $0x9
  800e07:	68 44 17 80 00       	push   $0x801744
  800e0c:	6a 23                	push   $0x23
  800e0e:	68 61 17 80 00       	push   $0x801761
  800e13:	e8 2f f3 ff ff       	call   800147 <_panic>

00800e18 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e18:	f3 0f 1e fb          	endbr32 
  800e1c:	55                   	push   %ebp
  800e1d:	89 e5                	mov    %esp,%ebp
  800e1f:	57                   	push   %edi
  800e20:	56                   	push   %esi
  800e21:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e22:	8b 55 08             	mov    0x8(%ebp),%edx
  800e25:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e28:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e2d:	be 00 00 00 00       	mov    $0x0,%esi
  800e32:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e35:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e38:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e3a:	5b                   	pop    %ebx
  800e3b:	5e                   	pop    %esi
  800e3c:	5f                   	pop    %edi
  800e3d:	5d                   	pop    %ebp
  800e3e:	c3                   	ret    

00800e3f <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e3f:	f3 0f 1e fb          	endbr32 
  800e43:	55                   	push   %ebp
  800e44:	89 e5                	mov    %esp,%ebp
  800e46:	57                   	push   %edi
  800e47:	56                   	push   %esi
  800e48:	53                   	push   %ebx
  800e49:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e4c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e51:	8b 55 08             	mov    0x8(%ebp),%edx
  800e54:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e59:	89 cb                	mov    %ecx,%ebx
  800e5b:	89 cf                	mov    %ecx,%edi
  800e5d:	89 ce                	mov    %ecx,%esi
  800e5f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e61:	85 c0                	test   %eax,%eax
  800e63:	7f 08                	jg     800e6d <sys_ipc_recv+0x2e>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e65:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e68:	5b                   	pop    %ebx
  800e69:	5e                   	pop    %esi
  800e6a:	5f                   	pop    %edi
  800e6b:	5d                   	pop    %ebp
  800e6c:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e6d:	83 ec 0c             	sub    $0xc,%esp
  800e70:	50                   	push   %eax
  800e71:	6a 0c                	push   $0xc
  800e73:	68 44 17 80 00       	push   $0x801744
  800e78:	6a 23                	push   $0x23
  800e7a:	68 61 17 80 00       	push   $0x801761
  800e7f:	e8 c3 f2 ff ff       	call   800147 <_panic>

00800e84 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e84:	f3 0f 1e fb          	endbr32 
  800e88:	55                   	push   %ebp
  800e89:	89 e5                	mov    %esp,%ebp
  800e8b:	53                   	push   %ebx
  800e8c:	83 ec 04             	sub    $0x4,%esp
  800e8f:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e92:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if(!(err & FEC_WR)){
  800e94:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e98:	74 74                	je     800f0e <pgfault+0x8a>
        panic("trapno is not FEC_WR");
    }
    if(!(uvpt[PGNUM(addr)] & PTE_COW)){
  800e9a:	89 d8                	mov    %ebx,%eax
  800e9c:	c1 e8 0c             	shr    $0xc,%eax
  800e9f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800ea6:	f6 c4 08             	test   $0x8,%ah
  800ea9:	74 77                	je     800f22 <pgfault+0x9e>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	addr = ROUNDDOWN(addr, PGSIZE);
  800eab:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
    if ((r = sys_page_map(0, addr, 0, PFTEMP, PTE_U | PTE_P)) < 0)
  800eb1:	83 ec 0c             	sub    $0xc,%esp
  800eb4:	6a 05                	push   $0x5
  800eb6:	68 00 f0 7f 00       	push   $0x7ff000
  800ebb:	6a 00                	push   $0x0
  800ebd:	53                   	push   %ebx
  800ebe:	6a 00                	push   $0x0
  800ec0:	e8 3b fe ff ff       	call   800d00 <sys_page_map>
  800ec5:	83 c4 20             	add    $0x20,%esp
  800ec8:	85 c0                	test   %eax,%eax
  800eca:	78 6a                	js     800f36 <pgfault+0xb2>
        panic("sys_page_map: %e", r);
    if ((r = sys_page_alloc(0, addr, PTE_W | PTE_U | PTE_P)) < 0)
  800ecc:	83 ec 04             	sub    $0x4,%esp
  800ecf:	6a 07                	push   $0x7
  800ed1:	53                   	push   %ebx
  800ed2:	6a 00                	push   $0x0
  800ed4:	e8 e0 fd ff ff       	call   800cb9 <sys_page_alloc>
  800ed9:	83 c4 10             	add    $0x10,%esp
  800edc:	85 c0                	test   %eax,%eax
  800ede:	78 68                	js     800f48 <pgfault+0xc4>
        panic("sys_page_alloc: %e", r);
    memmove(addr, PFTEMP, PGSIZE);
  800ee0:	83 ec 04             	sub    $0x4,%esp
  800ee3:	68 00 10 00 00       	push   $0x1000
  800ee8:	68 00 f0 7f 00       	push   $0x7ff000
  800eed:	53                   	push   %ebx
  800eee:	e8 3a fb ff ff       	call   800a2d <memmove>
    if ((r = sys_page_unmap(0, PFTEMP)) < 0)
  800ef3:	83 c4 08             	add    $0x8,%esp
  800ef6:	68 00 f0 7f 00       	push   $0x7ff000
  800efb:	6a 00                	push   $0x0
  800efd:	e8 44 fe ff ff       	call   800d46 <sys_page_unmap>
  800f02:	83 c4 10             	add    $0x10,%esp
  800f05:	85 c0                	test   %eax,%eax
  800f07:	78 51                	js     800f5a <pgfault+0xd6>
        panic("sys_page_unmap: %e", r);

	//panic("pgfault not implemented");
}
  800f09:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f0c:	c9                   	leave  
  800f0d:	c3                   	ret    
        panic("trapno is not FEC_WR");
  800f0e:	83 ec 04             	sub    $0x4,%esp
  800f11:	68 6f 17 80 00       	push   $0x80176f
  800f16:	6a 1d                	push   $0x1d
  800f18:	68 84 17 80 00       	push   $0x801784
  800f1d:	e8 25 f2 ff ff       	call   800147 <_panic>
        panic("fault addr is not COW");
  800f22:	83 ec 04             	sub    $0x4,%esp
  800f25:	68 8f 17 80 00       	push   $0x80178f
  800f2a:	6a 20                	push   $0x20
  800f2c:	68 84 17 80 00       	push   $0x801784
  800f31:	e8 11 f2 ff ff       	call   800147 <_panic>
        panic("sys_page_map: %e", r);
  800f36:	50                   	push   %eax
  800f37:	68 a5 17 80 00       	push   $0x8017a5
  800f3c:	6a 2c                	push   $0x2c
  800f3e:	68 84 17 80 00       	push   $0x801784
  800f43:	e8 ff f1 ff ff       	call   800147 <_panic>
        panic("sys_page_alloc: %e", r);
  800f48:	50                   	push   %eax
  800f49:	68 b6 17 80 00       	push   $0x8017b6
  800f4e:	6a 2e                	push   $0x2e
  800f50:	68 84 17 80 00       	push   $0x801784
  800f55:	e8 ed f1 ff ff       	call   800147 <_panic>
        panic("sys_page_unmap: %e", r);
  800f5a:	50                   	push   %eax
  800f5b:	68 c9 17 80 00       	push   $0x8017c9
  800f60:	6a 31                	push   $0x31
  800f62:	68 84 17 80 00       	push   $0x801784
  800f67:	e8 db f1 ff ff       	call   800147 <_panic>

00800f6c <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f6c:	f3 0f 1e fb          	endbr32 
  800f70:	55                   	push   %ebp
  800f71:	89 e5                	mov    %esp,%ebp
  800f73:	57                   	push   %edi
  800f74:	56                   	push   %esi
  800f75:	53                   	push   %ebx
  800f76:	83 ec 28             	sub    $0x28,%esp
    extern void _pgfault_upcall(void);

	set_pgfault_handler(pgfault);
  800f79:	68 84 0e 80 00       	push   $0x800e84
  800f7e:	e8 fd 01 00 00       	call   801180 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800f83:	b8 07 00 00 00       	mov    $0x7,%eax
  800f88:	cd 30                	int    $0x30
  800f8a:	89 45 e4             	mov    %eax,-0x1c(%ebp)

    envid_t envid = sys_exofork();
    if (envid < 0)
  800f8d:	83 c4 10             	add    $0x10,%esp
  800f90:	85 c0                	test   %eax,%eax
  800f92:	78 2d                	js     800fc1 <fork+0x55>
  800f94:	89 c7                	mov    %eax,%edi
        thisenv = &envs[ENVX(sys_getenvid())];
        return 0;
    }

    // Parent
    for(uint32_t addr = 0; addr < USTACKTOP; addr += PGSIZE){
  800f96:	bb 00 00 00 00       	mov    $0x0,%ebx
    if (envid == 0) {
  800f9b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800f9f:	0f 85 92 00 00 00    	jne    801037 <fork+0xcb>
        thisenv = &envs[ENVX(sys_getenvid())];
  800fa5:	e8 c9 fc ff ff       	call   800c73 <sys_getenvid>
  800faa:	25 ff 03 00 00       	and    $0x3ff,%eax
  800faf:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800fb2:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800fb7:	a3 08 20 80 00       	mov    %eax,0x802008
        return 0;
  800fbc:	e9 57 01 00 00       	jmp    801118 <fork+0x1ac>
        panic("sys_exofork Failed, envid: %e", envid);
  800fc1:	50                   	push   %eax
  800fc2:	68 dc 17 80 00       	push   $0x8017dc
  800fc7:	6a 71                	push   $0x71
  800fc9:	68 84 17 80 00       	push   $0x801784
  800fce:	e8 74 f1 ff ff       	call   800147 <_panic>
        sys_page_map(0, addr, envid, addr, PTE_SYSCALL);
  800fd3:	83 ec 0c             	sub    $0xc,%esp
  800fd6:	68 07 0e 00 00       	push   $0xe07
  800fdb:	56                   	push   %esi
  800fdc:	57                   	push   %edi
  800fdd:	56                   	push   %esi
  800fde:	6a 00                	push   $0x0
  800fe0:	e8 1b fd ff ff       	call   800d00 <sys_page_map>
  800fe5:	83 c4 20             	add    $0x20,%esp
  800fe8:	eb 3b                	jmp    801025 <fork+0xb9>
        if ((r = sys_page_map(0, addr, envid, addr, PTE_COW|PTE_U|PTE_P)) < 0)
  800fea:	83 ec 0c             	sub    $0xc,%esp
  800fed:	68 05 08 00 00       	push   $0x805
  800ff2:	56                   	push   %esi
  800ff3:	57                   	push   %edi
  800ff4:	56                   	push   %esi
  800ff5:	6a 00                	push   $0x0
  800ff7:	e8 04 fd ff ff       	call   800d00 <sys_page_map>
  800ffc:	83 c4 20             	add    $0x20,%esp
  800fff:	85 c0                	test   %eax,%eax
  801001:	0f 88 a9 00 00 00    	js     8010b0 <fork+0x144>
		if ((r = sys_page_map(0, addr, 0, addr, PTE_COW|PTE_U|PTE_P)) < 0)
  801007:	83 ec 0c             	sub    $0xc,%esp
  80100a:	68 05 08 00 00       	push   $0x805
  80100f:	56                   	push   %esi
  801010:	6a 00                	push   $0x0
  801012:	56                   	push   %esi
  801013:	6a 00                	push   $0x0
  801015:	e8 e6 fc ff ff       	call   800d00 <sys_page_map>
  80101a:	83 c4 20             	add    $0x20,%esp
  80101d:	85 c0                	test   %eax,%eax
  80101f:	0f 88 9d 00 00 00    	js     8010c2 <fork+0x156>
    for(uint32_t addr = 0; addr < USTACKTOP; addr += PGSIZE){
  801025:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80102b:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  801031:	0f 84 9d 00 00 00    	je     8010d4 <fork+0x168>
		if((uvpd[PDX(addr)] & PTE_P) && 
  801037:	89 d8                	mov    %ebx,%eax
  801039:	c1 e8 16             	shr    $0x16,%eax
  80103c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801043:	a8 01                	test   $0x1,%al
  801045:	74 de                	je     801025 <fork+0xb9>
		(uvpt[PGNUM(addr)]&PTE_P) && 
  801047:	89 d8                	mov    %ebx,%eax
  801049:	c1 e8 0c             	shr    $0xc,%eax
  80104c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
		if((uvpd[PDX(addr)] & PTE_P) && 
  801053:	f6 c2 01             	test   $0x1,%dl
  801056:	74 cd                	je     801025 <fork+0xb9>
		(uvpt[PGNUM(addr)] &PTE_U)){
  801058:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
		(uvpt[PGNUM(addr)]&PTE_P) && 
  80105f:	f6 c2 04             	test   $0x4,%dl
  801062:	74 c1                	je     801025 <fork+0xb9>
    void *addr=(void *)(pn*PGSIZE);
  801064:	89 c6                	mov    %eax,%esi
  801066:	c1 e6 0c             	shl    $0xc,%esi
    if(uvpt[pn] & PTE_SHARE){
  801069:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801070:	f6 c6 04             	test   $0x4,%dh
  801073:	0f 85 5a ff ff ff    	jne    800fd3 <fork+0x67>
    else if((uvpt[pn]&PTE_W)|| (uvpt[pn] & PTE_COW)){
  801079:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801080:	f6 c2 02             	test   $0x2,%dl
  801083:	0f 85 61 ff ff ff    	jne    800fea <fork+0x7e>
  801089:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801090:	f6 c4 08             	test   $0x8,%ah
  801093:	0f 85 51 ff ff ff    	jne    800fea <fork+0x7e>
        sys_page_map(0, addr, envid, addr, PTE_U|PTE_P);
  801099:	83 ec 0c             	sub    $0xc,%esp
  80109c:	6a 05                	push   $0x5
  80109e:	56                   	push   %esi
  80109f:	57                   	push   %edi
  8010a0:	56                   	push   %esi
  8010a1:	6a 00                	push   $0x0
  8010a3:	e8 58 fc ff ff       	call   800d00 <sys_page_map>
  8010a8:	83 c4 20             	add    $0x20,%esp
  8010ab:	e9 75 ff ff ff       	jmp    801025 <fork+0xb9>
			panic("sys_page_map：%e", r);
  8010b0:	50                   	push   %eax
  8010b1:	68 fa 17 80 00       	push   $0x8017fa
  8010b6:	6a 4d                	push   $0x4d
  8010b8:	68 84 17 80 00       	push   $0x801784
  8010bd:	e8 85 f0 ff ff       	call   800147 <_panic>
			panic("sys_page_map：%e", r);
  8010c2:	50                   	push   %eax
  8010c3:	68 fa 17 80 00       	push   $0x8017fa
  8010c8:	6a 4f                	push   $0x4f
  8010ca:	68 84 17 80 00       	push   $0x801784
  8010cf:	e8 73 f0 ff ff       	call   800147 <_panic>
			duppage(envid, PGNUM(addr));
		}
	}

    // Allocate a new page for the child's user exception stack
    int r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_P|PTE_W|PTE_U);
  8010d4:	83 ec 04             	sub    $0x4,%esp
  8010d7:	6a 07                	push   $0x7
  8010d9:	68 00 f0 bf ee       	push   $0xeebff000
  8010de:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010e1:	e8 d3 fb ff ff       	call   800cb9 <sys_page_alloc>
	if( r < 0)
  8010e6:	83 c4 10             	add    $0x10,%esp
  8010e9:	85 c0                	test   %eax,%eax
  8010eb:	78 36                	js     801123 <fork+0x1b7>
		panic("sys_page_alloc: %e", r);

    // Set the page fault upcall for the child
    r=sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  8010ed:	83 ec 08             	sub    $0x8,%esp
  8010f0:	68 dd 11 80 00       	push   $0x8011dd
  8010f5:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010f8:	e8 d5 fc ff ff       	call   800dd2 <sys_env_set_pgfault_upcall>
    if( r < 0 )
  8010fd:	83 c4 10             	add    $0x10,%esp
  801100:	85 c0                	test   %eax,%eax
  801102:	78 34                	js     801138 <fork+0x1cc>
		panic("sys_env_set_pgfault_upcall: %e",r);
    
    // Mark the child as runnable
    r=sys_env_set_status(envid, ENV_RUNNABLE);
  801104:	83 ec 08             	sub    $0x8,%esp
  801107:	6a 02                	push   $0x2
  801109:	ff 75 e4             	pushl  -0x1c(%ebp)
  80110c:	e8 7b fc ff ff       	call   800d8c <sys_env_set_status>
    if (r < 0)
  801111:	83 c4 10             	add    $0x10,%esp
  801114:	85 c0                	test   %eax,%eax
  801116:	78 35                	js     80114d <fork+0x1e1>
		panic("sys_env_set_status: %e", r);
    
    return envid;
	// LAB 4: Your code here.
	//panic("fork not implemented");
}
  801118:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80111b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80111e:	5b                   	pop    %ebx
  80111f:	5e                   	pop    %esi
  801120:	5f                   	pop    %edi
  801121:	5d                   	pop    %ebp
  801122:	c3                   	ret    
		panic("sys_page_alloc: %e", r);
  801123:	50                   	push   %eax
  801124:	68 b6 17 80 00       	push   $0x8017b6
  801129:	68 84 00 00 00       	push   $0x84
  80112e:	68 84 17 80 00       	push   $0x801784
  801133:	e8 0f f0 ff ff       	call   800147 <_panic>
		panic("sys_env_set_pgfault_upcall: %e",r);
  801138:	50                   	push   %eax
  801139:	68 3c 18 80 00       	push   $0x80183c
  80113e:	68 89 00 00 00       	push   $0x89
  801143:	68 84 17 80 00       	push   $0x801784
  801148:	e8 fa ef ff ff       	call   800147 <_panic>
		panic("sys_env_set_status: %e", r);
  80114d:	50                   	push   %eax
  80114e:	68 0c 18 80 00       	push   $0x80180c
  801153:	68 8e 00 00 00       	push   $0x8e
  801158:	68 84 17 80 00       	push   $0x801784
  80115d:	e8 e5 ef ff ff       	call   800147 <_panic>

00801162 <sfork>:

// Challenge!
int
sfork(void)
{
  801162:	f3 0f 1e fb          	endbr32 
  801166:	55                   	push   %ebp
  801167:	89 e5                	mov    %esp,%ebp
  801169:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  80116c:	68 23 18 80 00       	push   $0x801823
  801171:	68 99 00 00 00       	push   $0x99
  801176:	68 84 17 80 00       	push   $0x801784
  80117b:	e8 c7 ef ff ff       	call   800147 <_panic>

00801180 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801180:	f3 0f 1e fb          	endbr32 
  801184:	55                   	push   %ebp
  801185:	89 e5                	mov    %esp,%ebp
  801187:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  80118a:	83 3d 0c 20 80 00 00 	cmpl   $0x0,0x80200c
  801191:	74 0a                	je     80119d <set_pgfault_handler+0x1d>
        sys_env_set_pgfault_upcall(0, _pgfault_upcall);
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801193:	8b 45 08             	mov    0x8(%ebp),%eax
  801196:	a3 0c 20 80 00       	mov    %eax,0x80200c
}
  80119b:	c9                   	leave  
  80119c:	c3                   	ret    
		if (sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P) < 0)
  80119d:	83 ec 04             	sub    $0x4,%esp
  8011a0:	6a 07                	push   $0x7
  8011a2:	68 00 f0 bf ee       	push   $0xeebff000
  8011a7:	6a 00                	push   $0x0
  8011a9:	e8 0b fb ff ff       	call   800cb9 <sys_page_alloc>
  8011ae:	83 c4 10             	add    $0x10,%esp
  8011b1:	85 c0                	test   %eax,%eax
  8011b3:	78 14                	js     8011c9 <set_pgfault_handler+0x49>
        sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  8011b5:	83 ec 08             	sub    $0x8,%esp
  8011b8:	68 dd 11 80 00       	push   $0x8011dd
  8011bd:	6a 00                	push   $0x0
  8011bf:	e8 0e fc ff ff       	call   800dd2 <sys_env_set_pgfault_upcall>
  8011c4:	83 c4 10             	add    $0x10,%esp
  8011c7:	eb ca                	jmp    801193 <set_pgfault_handler+0x13>
            panic("set_pgfault_handler failed.");
  8011c9:	83 ec 04             	sub    $0x4,%esp
  8011cc:	68 5b 18 80 00       	push   $0x80185b
  8011d1:	6a 21                	push   $0x21
  8011d3:	68 77 18 80 00       	push   $0x801877
  8011d8:	e8 6a ef ff ff       	call   800147 <_panic>

008011dd <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8011dd:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8011de:	a1 0c 20 80 00       	mov    0x80200c,%eax
	call *%eax
  8011e3:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8011e5:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	addl $8, %esp
  8011e8:	83 c4 08             	add    $0x8,%esp
	movl 32(%esp), %eax
  8011eb:	8b 44 24 20          	mov    0x20(%esp),%eax
	movl 40(%esp), %edx
  8011ef:	8b 54 24 28          	mov    0x28(%esp),%edx
	subl $4, %edx
  8011f3:	83 ea 04             	sub    $0x4,%edx
	movl %eax, (%edx)
  8011f6:	89 02                	mov    %eax,(%edx)
	movl %edx, 40(%esp)
  8011f8:	89 54 24 28          	mov    %edx,0x28(%esp)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal
  8011fc:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp
  8011fd:	83 c4 04             	add    $0x4,%esp
	popfl
  801200:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  801201:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801202:	c3                   	ret    
  801203:	66 90                	xchg   %ax,%ax
  801205:	66 90                	xchg   %ax,%ax
  801207:	66 90                	xchg   %ax,%ax
  801209:	66 90                	xchg   %ax,%ax
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
