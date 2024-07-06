
obj/user/faultallocbad:     file format elf32-i386


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
  80002c:	e8 8c 00 00 00       	call   8000bd <libmain>
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
  80003a:	53                   	push   %ebx
  80003b:	83 ec 0c             	sub    $0xc,%esp
	int r;
	void *addr = (void*)utf->utf_fault_va;
  80003e:	8b 45 08             	mov    0x8(%ebp),%eax
  800041:	8b 18                	mov    (%eax),%ebx

	cprintf("fault %x\n", addr);
  800043:	53                   	push   %ebx
  800044:	68 40 11 80 00       	push   $0x801140
  800049:	e8 b6 01 00 00       	call   800204 <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  80004e:	83 c4 0c             	add    $0xc,%esp
  800051:	6a 07                	push   $0x7
  800053:	89 d8                	mov    %ebx,%eax
  800055:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80005a:	50                   	push   %eax
  80005b:	6a 00                	push   $0x0
  80005d:	e8 2d 0c 00 00       	call   800c8f <sys_page_alloc>
  800062:	83 c4 10             	add    $0x10,%esp
  800065:	85 c0                	test   %eax,%eax
  800067:	78 16                	js     80007f <handler+0x4c>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  800069:	53                   	push   %ebx
  80006a:	68 8c 11 80 00       	push   $0x80118c
  80006f:	6a 64                	push   $0x64
  800071:	53                   	push   %ebx
  800072:	e8 75 07 00 00       	call   8007ec <snprintf>
}
  800077:	83 c4 10             	add    $0x10,%esp
  80007a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80007d:	c9                   	leave  
  80007e:	c3                   	ret    
		panic("allocating at %x in page fault handler: %e", addr, r);
  80007f:	83 ec 0c             	sub    $0xc,%esp
  800082:	50                   	push   %eax
  800083:	53                   	push   %ebx
  800084:	68 60 11 80 00       	push   $0x801160
  800089:	6a 0f                	push   $0xf
  80008b:	68 4a 11 80 00       	push   $0x80114a
  800090:	e8 88 00 00 00       	call   80011d <_panic>

00800095 <umain>:

void
umain(int argc, char **argv)
{
  800095:	f3 0f 1e fb          	endbr32 
  800099:	55                   	push   %ebp
  80009a:	89 e5                	mov    %esp,%ebp
  80009c:	83 ec 14             	sub    $0x14,%esp
	set_pgfault_handler(handler);
  80009f:	68 33 00 80 00       	push   $0x800033
  8000a4:	e8 b1 0d 00 00       	call   800e5a <set_pgfault_handler>
	sys_cputs((char*)0xDEADBEEF, 4);
  8000a9:	83 c4 08             	add    $0x8,%esp
  8000ac:	6a 04                	push   $0x4
  8000ae:	68 ef be ad de       	push   $0xdeadbeef
  8000b3:	e8 07 0b 00 00       	call   800bbf <sys_cputs>
}
  8000b8:	83 c4 10             	add    $0x10,%esp
  8000bb:	c9                   	leave  
  8000bc:	c3                   	ret    

008000bd <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000bd:	f3 0f 1e fb          	endbr32 
  8000c1:	55                   	push   %ebp
  8000c2:	89 e5                	mov    %esp,%ebp
  8000c4:	56                   	push   %esi
  8000c5:	53                   	push   %ebx
  8000c6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000c9:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv=&envs[ENVX(sys_getenvid())];
  8000cc:	e8 78 0b 00 00       	call   800c49 <sys_getenvid>
  8000d1:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000d6:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000d9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000de:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000e3:	85 db                	test   %ebx,%ebx
  8000e5:	7e 07                	jle    8000ee <libmain+0x31>
		binaryname = argv[0];
  8000e7:	8b 06                	mov    (%esi),%eax
  8000e9:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000ee:	83 ec 08             	sub    $0x8,%esp
  8000f1:	56                   	push   %esi
  8000f2:	53                   	push   %ebx
  8000f3:	e8 9d ff ff ff       	call   800095 <umain>

	// exit gracefully
	exit();
  8000f8:	e8 0a 00 00 00       	call   800107 <exit>
}
  8000fd:	83 c4 10             	add    $0x10,%esp
  800100:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800103:	5b                   	pop    %ebx
  800104:	5e                   	pop    %esi
  800105:	5d                   	pop    %ebp
  800106:	c3                   	ret    

00800107 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800107:	f3 0f 1e fb          	endbr32 
  80010b:	55                   	push   %ebp
  80010c:	89 e5                	mov    %esp,%ebp
  80010e:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800111:	6a 00                	push   $0x0
  800113:	e8 ec 0a 00 00       	call   800c04 <sys_env_destroy>
}
  800118:	83 c4 10             	add    $0x10,%esp
  80011b:	c9                   	leave  
  80011c:	c3                   	ret    

0080011d <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80011d:	f3 0f 1e fb          	endbr32 
  800121:	55                   	push   %ebp
  800122:	89 e5                	mov    %esp,%ebp
  800124:	56                   	push   %esi
  800125:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800126:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800129:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80012f:	e8 15 0b 00 00       	call   800c49 <sys_getenvid>
  800134:	83 ec 0c             	sub    $0xc,%esp
  800137:	ff 75 0c             	pushl  0xc(%ebp)
  80013a:	ff 75 08             	pushl  0x8(%ebp)
  80013d:	56                   	push   %esi
  80013e:	50                   	push   %eax
  80013f:	68 b8 11 80 00       	push   $0x8011b8
  800144:	e8 bb 00 00 00       	call   800204 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800149:	83 c4 18             	add    $0x18,%esp
  80014c:	53                   	push   %ebx
  80014d:	ff 75 10             	pushl  0x10(%ebp)
  800150:	e8 5a 00 00 00       	call   8001af <vcprintf>
	cprintf("\n");
  800155:	c7 04 24 48 11 80 00 	movl   $0x801148,(%esp)
  80015c:	e8 a3 00 00 00       	call   800204 <cprintf>
  800161:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800164:	cc                   	int3   
  800165:	eb fd                	jmp    800164 <_panic+0x47>

00800167 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800167:	f3 0f 1e fb          	endbr32 
  80016b:	55                   	push   %ebp
  80016c:	89 e5                	mov    %esp,%ebp
  80016e:	53                   	push   %ebx
  80016f:	83 ec 04             	sub    $0x4,%esp
  800172:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800175:	8b 13                	mov    (%ebx),%edx
  800177:	8d 42 01             	lea    0x1(%edx),%eax
  80017a:	89 03                	mov    %eax,(%ebx)
  80017c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80017f:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800183:	3d ff 00 00 00       	cmp    $0xff,%eax
  800188:	74 09                	je     800193 <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80018a:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80018e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800191:	c9                   	leave  
  800192:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800193:	83 ec 08             	sub    $0x8,%esp
  800196:	68 ff 00 00 00       	push   $0xff
  80019b:	8d 43 08             	lea    0x8(%ebx),%eax
  80019e:	50                   	push   %eax
  80019f:	e8 1b 0a 00 00       	call   800bbf <sys_cputs>
		b->idx = 0;
  8001a4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001aa:	83 c4 10             	add    $0x10,%esp
  8001ad:	eb db                	jmp    80018a <putch+0x23>

008001af <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001af:	f3 0f 1e fb          	endbr32 
  8001b3:	55                   	push   %ebp
  8001b4:	89 e5                	mov    %esp,%ebp
  8001b6:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001bc:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001c3:	00 00 00 
	b.cnt = 0;
  8001c6:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001cd:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001d0:	ff 75 0c             	pushl  0xc(%ebp)
  8001d3:	ff 75 08             	pushl  0x8(%ebp)
  8001d6:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001dc:	50                   	push   %eax
  8001dd:	68 67 01 80 00       	push   $0x800167
  8001e2:	e8 20 01 00 00       	call   800307 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001e7:	83 c4 08             	add    $0x8,%esp
  8001ea:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001f0:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001f6:	50                   	push   %eax
  8001f7:	e8 c3 09 00 00       	call   800bbf <sys_cputs>

	return b.cnt;
}
  8001fc:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800202:	c9                   	leave  
  800203:	c3                   	ret    

00800204 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800204:	f3 0f 1e fb          	endbr32 
  800208:	55                   	push   %ebp
  800209:	89 e5                	mov    %esp,%ebp
  80020b:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80020e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800211:	50                   	push   %eax
  800212:	ff 75 08             	pushl  0x8(%ebp)
  800215:	e8 95 ff ff ff       	call   8001af <vcprintf>
	va_end(ap);

	return cnt;
}
  80021a:	c9                   	leave  
  80021b:	c3                   	ret    

0080021c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80021c:	55                   	push   %ebp
  80021d:	89 e5                	mov    %esp,%ebp
  80021f:	57                   	push   %edi
  800220:	56                   	push   %esi
  800221:	53                   	push   %ebx
  800222:	83 ec 1c             	sub    $0x1c,%esp
  800225:	89 c7                	mov    %eax,%edi
  800227:	89 d6                	mov    %edx,%esi
  800229:	8b 45 08             	mov    0x8(%ebp),%eax
  80022c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80022f:	89 d1                	mov    %edx,%ecx
  800231:	89 c2                	mov    %eax,%edx
  800233:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800236:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800239:	8b 45 10             	mov    0x10(%ebp),%eax
  80023c:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80023f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800242:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800249:	39 c2                	cmp    %eax,%edx
  80024b:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  80024e:	72 3e                	jb     80028e <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800250:	83 ec 0c             	sub    $0xc,%esp
  800253:	ff 75 18             	pushl  0x18(%ebp)
  800256:	83 eb 01             	sub    $0x1,%ebx
  800259:	53                   	push   %ebx
  80025a:	50                   	push   %eax
  80025b:	83 ec 08             	sub    $0x8,%esp
  80025e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800261:	ff 75 e0             	pushl  -0x20(%ebp)
  800264:	ff 75 dc             	pushl  -0x24(%ebp)
  800267:	ff 75 d8             	pushl  -0x28(%ebp)
  80026a:	e8 71 0c 00 00       	call   800ee0 <__udivdi3>
  80026f:	83 c4 18             	add    $0x18,%esp
  800272:	52                   	push   %edx
  800273:	50                   	push   %eax
  800274:	89 f2                	mov    %esi,%edx
  800276:	89 f8                	mov    %edi,%eax
  800278:	e8 9f ff ff ff       	call   80021c <printnum>
  80027d:	83 c4 20             	add    $0x20,%esp
  800280:	eb 13                	jmp    800295 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800282:	83 ec 08             	sub    $0x8,%esp
  800285:	56                   	push   %esi
  800286:	ff 75 18             	pushl  0x18(%ebp)
  800289:	ff d7                	call   *%edi
  80028b:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80028e:	83 eb 01             	sub    $0x1,%ebx
  800291:	85 db                	test   %ebx,%ebx
  800293:	7f ed                	jg     800282 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800295:	83 ec 08             	sub    $0x8,%esp
  800298:	56                   	push   %esi
  800299:	83 ec 04             	sub    $0x4,%esp
  80029c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80029f:	ff 75 e0             	pushl  -0x20(%ebp)
  8002a2:	ff 75 dc             	pushl  -0x24(%ebp)
  8002a5:	ff 75 d8             	pushl  -0x28(%ebp)
  8002a8:	e8 43 0d 00 00       	call   800ff0 <__umoddi3>
  8002ad:	83 c4 14             	add    $0x14,%esp
  8002b0:	0f be 80 db 11 80 00 	movsbl 0x8011db(%eax),%eax
  8002b7:	50                   	push   %eax
  8002b8:	ff d7                	call   *%edi
}
  8002ba:	83 c4 10             	add    $0x10,%esp
  8002bd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002c0:	5b                   	pop    %ebx
  8002c1:	5e                   	pop    %esi
  8002c2:	5f                   	pop    %edi
  8002c3:	5d                   	pop    %ebp
  8002c4:	c3                   	ret    

008002c5 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002c5:	f3 0f 1e fb          	endbr32 
  8002c9:	55                   	push   %ebp
  8002ca:	89 e5                	mov    %esp,%ebp
  8002cc:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002cf:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002d3:	8b 10                	mov    (%eax),%edx
  8002d5:	3b 50 04             	cmp    0x4(%eax),%edx
  8002d8:	73 0a                	jae    8002e4 <sprintputch+0x1f>
		*b->buf++ = ch;
  8002da:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002dd:	89 08                	mov    %ecx,(%eax)
  8002df:	8b 45 08             	mov    0x8(%ebp),%eax
  8002e2:	88 02                	mov    %al,(%edx)
}
  8002e4:	5d                   	pop    %ebp
  8002e5:	c3                   	ret    

008002e6 <printfmt>:
{
  8002e6:	f3 0f 1e fb          	endbr32 
  8002ea:	55                   	push   %ebp
  8002eb:	89 e5                	mov    %esp,%ebp
  8002ed:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8002f0:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002f3:	50                   	push   %eax
  8002f4:	ff 75 10             	pushl  0x10(%ebp)
  8002f7:	ff 75 0c             	pushl  0xc(%ebp)
  8002fa:	ff 75 08             	pushl  0x8(%ebp)
  8002fd:	e8 05 00 00 00       	call   800307 <vprintfmt>
}
  800302:	83 c4 10             	add    $0x10,%esp
  800305:	c9                   	leave  
  800306:	c3                   	ret    

00800307 <vprintfmt>:
{
  800307:	f3 0f 1e fb          	endbr32 
  80030b:	55                   	push   %ebp
  80030c:	89 e5                	mov    %esp,%ebp
  80030e:	57                   	push   %edi
  80030f:	56                   	push   %esi
  800310:	53                   	push   %ebx
  800311:	83 ec 3c             	sub    $0x3c,%esp
  800314:	8b 75 08             	mov    0x8(%ebp),%esi
  800317:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80031a:	8b 7d 10             	mov    0x10(%ebp),%edi
  80031d:	e9 cd 03 00 00       	jmp    8006ef <vprintfmt+0x3e8>
		padc = ' ';
  800322:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800326:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  80032d:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800334:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80033b:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800340:	8d 47 01             	lea    0x1(%edi),%eax
  800343:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800346:	0f b6 17             	movzbl (%edi),%edx
  800349:	8d 42 dd             	lea    -0x23(%edx),%eax
  80034c:	3c 55                	cmp    $0x55,%al
  80034e:	0f 87 1e 04 00 00    	ja     800772 <vprintfmt+0x46b>
  800354:	0f b6 c0             	movzbl %al,%eax
  800357:	3e ff 24 85 a0 12 80 	notrack jmp *0x8012a0(,%eax,4)
  80035e:	00 
  80035f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800362:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800366:	eb d8                	jmp    800340 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800368:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80036b:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  80036f:	eb cf                	jmp    800340 <vprintfmt+0x39>
  800371:	0f b6 d2             	movzbl %dl,%edx
  800374:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800377:	b8 00 00 00 00       	mov    $0x0,%eax
  80037c:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  80037f:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800382:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800386:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800389:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80038c:	83 f9 09             	cmp    $0x9,%ecx
  80038f:	77 55                	ja     8003e6 <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  800391:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800394:	eb e9                	jmp    80037f <vprintfmt+0x78>
			precision = va_arg(ap, int);
  800396:	8b 45 14             	mov    0x14(%ebp),%eax
  800399:	8b 00                	mov    (%eax),%eax
  80039b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80039e:	8b 45 14             	mov    0x14(%ebp),%eax
  8003a1:	8d 40 04             	lea    0x4(%eax),%eax
  8003a4:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003a7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8003aa:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003ae:	79 90                	jns    800340 <vprintfmt+0x39>
				width = precision, precision = -1;
  8003b0:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8003b3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003b6:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8003bd:	eb 81                	jmp    800340 <vprintfmt+0x39>
  8003bf:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003c2:	85 c0                	test   %eax,%eax
  8003c4:	ba 00 00 00 00       	mov    $0x0,%edx
  8003c9:	0f 49 d0             	cmovns %eax,%edx
  8003cc:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003cf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003d2:	e9 69 ff ff ff       	jmp    800340 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8003d7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8003da:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8003e1:	e9 5a ff ff ff       	jmp    800340 <vprintfmt+0x39>
  8003e6:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003e9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003ec:	eb bc                	jmp    8003aa <vprintfmt+0xa3>
			lflag++;
  8003ee:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8003f1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003f4:	e9 47 ff ff ff       	jmp    800340 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  8003f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8003fc:	8d 78 04             	lea    0x4(%eax),%edi
  8003ff:	83 ec 08             	sub    $0x8,%esp
  800402:	53                   	push   %ebx
  800403:	ff 30                	pushl  (%eax)
  800405:	ff d6                	call   *%esi
			break;
  800407:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  80040a:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  80040d:	e9 da 02 00 00       	jmp    8006ec <vprintfmt+0x3e5>
			err = va_arg(ap, int);
  800412:	8b 45 14             	mov    0x14(%ebp),%eax
  800415:	8d 78 04             	lea    0x4(%eax),%edi
  800418:	8b 00                	mov    (%eax),%eax
  80041a:	99                   	cltd   
  80041b:	31 d0                	xor    %edx,%eax
  80041d:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80041f:	83 f8 08             	cmp    $0x8,%eax
  800422:	7f 23                	jg     800447 <vprintfmt+0x140>
  800424:	8b 14 85 00 14 80 00 	mov    0x801400(,%eax,4),%edx
  80042b:	85 d2                	test   %edx,%edx
  80042d:	74 18                	je     800447 <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  80042f:	52                   	push   %edx
  800430:	68 fc 11 80 00       	push   $0x8011fc
  800435:	53                   	push   %ebx
  800436:	56                   	push   %esi
  800437:	e8 aa fe ff ff       	call   8002e6 <printfmt>
  80043c:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80043f:	89 7d 14             	mov    %edi,0x14(%ebp)
  800442:	e9 a5 02 00 00       	jmp    8006ec <vprintfmt+0x3e5>
				printfmt(putch, putdat, "error %d", err);
  800447:	50                   	push   %eax
  800448:	68 f3 11 80 00       	push   $0x8011f3
  80044d:	53                   	push   %ebx
  80044e:	56                   	push   %esi
  80044f:	e8 92 fe ff ff       	call   8002e6 <printfmt>
  800454:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800457:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80045a:	e9 8d 02 00 00       	jmp    8006ec <vprintfmt+0x3e5>
			if ((p = va_arg(ap, char *)) == NULL)
  80045f:	8b 45 14             	mov    0x14(%ebp),%eax
  800462:	83 c0 04             	add    $0x4,%eax
  800465:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800468:	8b 45 14             	mov    0x14(%ebp),%eax
  80046b:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  80046d:	85 d2                	test   %edx,%edx
  80046f:	b8 ec 11 80 00       	mov    $0x8011ec,%eax
  800474:	0f 45 c2             	cmovne %edx,%eax
  800477:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  80047a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80047e:	7e 06                	jle    800486 <vprintfmt+0x17f>
  800480:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  800484:	75 0d                	jne    800493 <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  800486:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800489:	89 c7                	mov    %eax,%edi
  80048b:	03 45 e0             	add    -0x20(%ebp),%eax
  80048e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800491:	eb 55                	jmp    8004e8 <vprintfmt+0x1e1>
  800493:	83 ec 08             	sub    $0x8,%esp
  800496:	ff 75 d8             	pushl  -0x28(%ebp)
  800499:	ff 75 cc             	pushl  -0x34(%ebp)
  80049c:	e8 85 03 00 00       	call   800826 <strnlen>
  8004a1:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8004a4:	29 c2                	sub    %eax,%edx
  8004a6:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  8004a9:	83 c4 10             	add    $0x10,%esp
  8004ac:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  8004ae:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8004b2:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8004b5:	85 ff                	test   %edi,%edi
  8004b7:	7e 11                	jle    8004ca <vprintfmt+0x1c3>
					putch(padc, putdat);
  8004b9:	83 ec 08             	sub    $0x8,%esp
  8004bc:	53                   	push   %ebx
  8004bd:	ff 75 e0             	pushl  -0x20(%ebp)
  8004c0:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8004c2:	83 ef 01             	sub    $0x1,%edi
  8004c5:	83 c4 10             	add    $0x10,%esp
  8004c8:	eb eb                	jmp    8004b5 <vprintfmt+0x1ae>
  8004ca:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8004cd:	85 d2                	test   %edx,%edx
  8004cf:	b8 00 00 00 00       	mov    $0x0,%eax
  8004d4:	0f 49 c2             	cmovns %edx,%eax
  8004d7:	29 c2                	sub    %eax,%edx
  8004d9:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8004dc:	eb a8                	jmp    800486 <vprintfmt+0x17f>
					putch(ch, putdat);
  8004de:	83 ec 08             	sub    $0x8,%esp
  8004e1:	53                   	push   %ebx
  8004e2:	52                   	push   %edx
  8004e3:	ff d6                	call   *%esi
  8004e5:	83 c4 10             	add    $0x10,%esp
  8004e8:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004eb:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004ed:	83 c7 01             	add    $0x1,%edi
  8004f0:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004f4:	0f be d0             	movsbl %al,%edx
  8004f7:	85 d2                	test   %edx,%edx
  8004f9:	74 4b                	je     800546 <vprintfmt+0x23f>
  8004fb:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004ff:	78 06                	js     800507 <vprintfmt+0x200>
  800501:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800505:	78 1e                	js     800525 <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
  800507:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80050b:	74 d1                	je     8004de <vprintfmt+0x1d7>
  80050d:	0f be c0             	movsbl %al,%eax
  800510:	83 e8 20             	sub    $0x20,%eax
  800513:	83 f8 5e             	cmp    $0x5e,%eax
  800516:	76 c6                	jbe    8004de <vprintfmt+0x1d7>
					putch('?', putdat);
  800518:	83 ec 08             	sub    $0x8,%esp
  80051b:	53                   	push   %ebx
  80051c:	6a 3f                	push   $0x3f
  80051e:	ff d6                	call   *%esi
  800520:	83 c4 10             	add    $0x10,%esp
  800523:	eb c3                	jmp    8004e8 <vprintfmt+0x1e1>
  800525:	89 cf                	mov    %ecx,%edi
  800527:	eb 0e                	jmp    800537 <vprintfmt+0x230>
				putch(' ', putdat);
  800529:	83 ec 08             	sub    $0x8,%esp
  80052c:	53                   	push   %ebx
  80052d:	6a 20                	push   $0x20
  80052f:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800531:	83 ef 01             	sub    $0x1,%edi
  800534:	83 c4 10             	add    $0x10,%esp
  800537:	85 ff                	test   %edi,%edi
  800539:	7f ee                	jg     800529 <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  80053b:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80053e:	89 45 14             	mov    %eax,0x14(%ebp)
  800541:	e9 a6 01 00 00       	jmp    8006ec <vprintfmt+0x3e5>
  800546:	89 cf                	mov    %ecx,%edi
  800548:	eb ed                	jmp    800537 <vprintfmt+0x230>
	if (lflag >= 2)
  80054a:	83 f9 01             	cmp    $0x1,%ecx
  80054d:	7f 1f                	jg     80056e <vprintfmt+0x267>
	else if (lflag)
  80054f:	85 c9                	test   %ecx,%ecx
  800551:	74 67                	je     8005ba <vprintfmt+0x2b3>
		return va_arg(*ap, long);
  800553:	8b 45 14             	mov    0x14(%ebp),%eax
  800556:	8b 00                	mov    (%eax),%eax
  800558:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80055b:	89 c1                	mov    %eax,%ecx
  80055d:	c1 f9 1f             	sar    $0x1f,%ecx
  800560:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800563:	8b 45 14             	mov    0x14(%ebp),%eax
  800566:	8d 40 04             	lea    0x4(%eax),%eax
  800569:	89 45 14             	mov    %eax,0x14(%ebp)
  80056c:	eb 17                	jmp    800585 <vprintfmt+0x27e>
		return va_arg(*ap, long long);
  80056e:	8b 45 14             	mov    0x14(%ebp),%eax
  800571:	8b 50 04             	mov    0x4(%eax),%edx
  800574:	8b 00                	mov    (%eax),%eax
  800576:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800579:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80057c:	8b 45 14             	mov    0x14(%ebp),%eax
  80057f:	8d 40 08             	lea    0x8(%eax),%eax
  800582:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800585:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800588:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  80058b:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  800590:	85 c9                	test   %ecx,%ecx
  800592:	0f 89 3a 01 00 00    	jns    8006d2 <vprintfmt+0x3cb>
				putch('-', putdat);
  800598:	83 ec 08             	sub    $0x8,%esp
  80059b:	53                   	push   %ebx
  80059c:	6a 2d                	push   $0x2d
  80059e:	ff d6                	call   *%esi
				num = -(long long) num;
  8005a0:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005a3:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005a6:	f7 da                	neg    %edx
  8005a8:	83 d1 00             	adc    $0x0,%ecx
  8005ab:	f7 d9                	neg    %ecx
  8005ad:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8005b0:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005b5:	e9 18 01 00 00       	jmp    8006d2 <vprintfmt+0x3cb>
		return va_arg(*ap, int);
  8005ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8005bd:	8b 00                	mov    (%eax),%eax
  8005bf:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005c2:	89 c1                	mov    %eax,%ecx
  8005c4:	c1 f9 1f             	sar    $0x1f,%ecx
  8005c7:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cd:	8d 40 04             	lea    0x4(%eax),%eax
  8005d0:	89 45 14             	mov    %eax,0x14(%ebp)
  8005d3:	eb b0                	jmp    800585 <vprintfmt+0x27e>
	if (lflag >= 2)
  8005d5:	83 f9 01             	cmp    $0x1,%ecx
  8005d8:	7f 1e                	jg     8005f8 <vprintfmt+0x2f1>
	else if (lflag)
  8005da:	85 c9                	test   %ecx,%ecx
  8005dc:	74 32                	je     800610 <vprintfmt+0x309>
		return va_arg(*ap, unsigned long);
  8005de:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e1:	8b 10                	mov    (%eax),%edx
  8005e3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005e8:	8d 40 04             	lea    0x4(%eax),%eax
  8005eb:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005ee:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  8005f3:	e9 da 00 00 00       	jmp    8006d2 <vprintfmt+0x3cb>
		return va_arg(*ap, unsigned long long);
  8005f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fb:	8b 10                	mov    (%eax),%edx
  8005fd:	8b 48 04             	mov    0x4(%eax),%ecx
  800600:	8d 40 08             	lea    0x8(%eax),%eax
  800603:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800606:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  80060b:	e9 c2 00 00 00       	jmp    8006d2 <vprintfmt+0x3cb>
		return va_arg(*ap, unsigned int);
  800610:	8b 45 14             	mov    0x14(%ebp),%eax
  800613:	8b 10                	mov    (%eax),%edx
  800615:	b9 00 00 00 00       	mov    $0x0,%ecx
  80061a:	8d 40 04             	lea    0x4(%eax),%eax
  80061d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800620:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  800625:	e9 a8 00 00 00       	jmp    8006d2 <vprintfmt+0x3cb>
	if (lflag >= 2)
  80062a:	83 f9 01             	cmp    $0x1,%ecx
  80062d:	7f 1b                	jg     80064a <vprintfmt+0x343>
	else if (lflag)
  80062f:	85 c9                	test   %ecx,%ecx
  800631:	74 5c                	je     80068f <vprintfmt+0x388>
		return va_arg(*ap, long);
  800633:	8b 45 14             	mov    0x14(%ebp),%eax
  800636:	8b 00                	mov    (%eax),%eax
  800638:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80063b:	99                   	cltd   
  80063c:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80063f:	8b 45 14             	mov    0x14(%ebp),%eax
  800642:	8d 40 04             	lea    0x4(%eax),%eax
  800645:	89 45 14             	mov    %eax,0x14(%ebp)
  800648:	eb 17                	jmp    800661 <vprintfmt+0x35a>
		return va_arg(*ap, long long);
  80064a:	8b 45 14             	mov    0x14(%ebp),%eax
  80064d:	8b 50 04             	mov    0x4(%eax),%edx
  800650:	8b 00                	mov    (%eax),%eax
  800652:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800655:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800658:	8b 45 14             	mov    0x14(%ebp),%eax
  80065b:	8d 40 08             	lea    0x8(%eax),%eax
  80065e:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800661:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800664:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 8;
  800667:	b8 08 00 00 00       	mov    $0x8,%eax
			if ((long long) num < 0) {
  80066c:	85 c9                	test   %ecx,%ecx
  80066e:	79 62                	jns    8006d2 <vprintfmt+0x3cb>
				putch('-', putdat);
  800670:	83 ec 08             	sub    $0x8,%esp
  800673:	53                   	push   %ebx
  800674:	6a 2d                	push   $0x2d
  800676:	ff d6                	call   *%esi
				num = -(long long) num;
  800678:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80067b:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80067e:	f7 da                	neg    %edx
  800680:	83 d1 00             	adc    $0x0,%ecx
  800683:	f7 d9                	neg    %ecx
  800685:	83 c4 10             	add    $0x10,%esp
			base = 8;
  800688:	b8 08 00 00 00       	mov    $0x8,%eax
  80068d:	eb 43                	jmp    8006d2 <vprintfmt+0x3cb>
		return va_arg(*ap, int);
  80068f:	8b 45 14             	mov    0x14(%ebp),%eax
  800692:	8b 00                	mov    (%eax),%eax
  800694:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800697:	89 c1                	mov    %eax,%ecx
  800699:	c1 f9 1f             	sar    $0x1f,%ecx
  80069c:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80069f:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a2:	8d 40 04             	lea    0x4(%eax),%eax
  8006a5:	89 45 14             	mov    %eax,0x14(%ebp)
  8006a8:	eb b7                	jmp    800661 <vprintfmt+0x35a>
			putch('0', putdat);
  8006aa:	83 ec 08             	sub    $0x8,%esp
  8006ad:	53                   	push   %ebx
  8006ae:	6a 30                	push   $0x30
  8006b0:	ff d6                	call   *%esi
			putch('x', putdat);
  8006b2:	83 c4 08             	add    $0x8,%esp
  8006b5:	53                   	push   %ebx
  8006b6:	6a 78                	push   $0x78
  8006b8:	ff d6                	call   *%esi
			num = (unsigned long long)
  8006ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8006bd:	8b 10                	mov    (%eax),%edx
  8006bf:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8006c4:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8006c7:	8d 40 04             	lea    0x4(%eax),%eax
  8006ca:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006cd:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  8006d2:	83 ec 0c             	sub    $0xc,%esp
  8006d5:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  8006d9:	57                   	push   %edi
  8006da:	ff 75 e0             	pushl  -0x20(%ebp)
  8006dd:	50                   	push   %eax
  8006de:	51                   	push   %ecx
  8006df:	52                   	push   %edx
  8006e0:	89 da                	mov    %ebx,%edx
  8006e2:	89 f0                	mov    %esi,%eax
  8006e4:	e8 33 fb ff ff       	call   80021c <printnum>
			break;
  8006e9:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  8006ec:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006ef:	83 c7 01             	add    $0x1,%edi
  8006f2:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8006f6:	83 f8 25             	cmp    $0x25,%eax
  8006f9:	0f 84 23 fc ff ff    	je     800322 <vprintfmt+0x1b>
			if (ch == '\0')
  8006ff:	85 c0                	test   %eax,%eax
  800701:	0f 84 8b 00 00 00    	je     800792 <vprintfmt+0x48b>
			putch(ch, putdat);
  800707:	83 ec 08             	sub    $0x8,%esp
  80070a:	53                   	push   %ebx
  80070b:	50                   	push   %eax
  80070c:	ff d6                	call   *%esi
  80070e:	83 c4 10             	add    $0x10,%esp
  800711:	eb dc                	jmp    8006ef <vprintfmt+0x3e8>
	if (lflag >= 2)
  800713:	83 f9 01             	cmp    $0x1,%ecx
  800716:	7f 1b                	jg     800733 <vprintfmt+0x42c>
	else if (lflag)
  800718:	85 c9                	test   %ecx,%ecx
  80071a:	74 2c                	je     800748 <vprintfmt+0x441>
		return va_arg(*ap, unsigned long);
  80071c:	8b 45 14             	mov    0x14(%ebp),%eax
  80071f:	8b 10                	mov    (%eax),%edx
  800721:	b9 00 00 00 00       	mov    $0x0,%ecx
  800726:	8d 40 04             	lea    0x4(%eax),%eax
  800729:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80072c:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  800731:	eb 9f                	jmp    8006d2 <vprintfmt+0x3cb>
		return va_arg(*ap, unsigned long long);
  800733:	8b 45 14             	mov    0x14(%ebp),%eax
  800736:	8b 10                	mov    (%eax),%edx
  800738:	8b 48 04             	mov    0x4(%eax),%ecx
  80073b:	8d 40 08             	lea    0x8(%eax),%eax
  80073e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800741:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  800746:	eb 8a                	jmp    8006d2 <vprintfmt+0x3cb>
		return va_arg(*ap, unsigned int);
  800748:	8b 45 14             	mov    0x14(%ebp),%eax
  80074b:	8b 10                	mov    (%eax),%edx
  80074d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800752:	8d 40 04             	lea    0x4(%eax),%eax
  800755:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800758:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  80075d:	e9 70 ff ff ff       	jmp    8006d2 <vprintfmt+0x3cb>
			putch(ch, putdat);
  800762:	83 ec 08             	sub    $0x8,%esp
  800765:	53                   	push   %ebx
  800766:	6a 25                	push   $0x25
  800768:	ff d6                	call   *%esi
			break;
  80076a:	83 c4 10             	add    $0x10,%esp
  80076d:	e9 7a ff ff ff       	jmp    8006ec <vprintfmt+0x3e5>
			putch('%', putdat);
  800772:	83 ec 08             	sub    $0x8,%esp
  800775:	53                   	push   %ebx
  800776:	6a 25                	push   $0x25
  800778:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80077a:	83 c4 10             	add    $0x10,%esp
  80077d:	89 f8                	mov    %edi,%eax
  80077f:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800783:	74 05                	je     80078a <vprintfmt+0x483>
  800785:	83 e8 01             	sub    $0x1,%eax
  800788:	eb f5                	jmp    80077f <vprintfmt+0x478>
  80078a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80078d:	e9 5a ff ff ff       	jmp    8006ec <vprintfmt+0x3e5>
}
  800792:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800795:	5b                   	pop    %ebx
  800796:	5e                   	pop    %esi
  800797:	5f                   	pop    %edi
  800798:	5d                   	pop    %ebp
  800799:	c3                   	ret    

0080079a <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80079a:	f3 0f 1e fb          	endbr32 
  80079e:	55                   	push   %ebp
  80079f:	89 e5                	mov    %esp,%ebp
  8007a1:	83 ec 18             	sub    $0x18,%esp
  8007a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8007a7:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007aa:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007ad:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007b1:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007b4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007bb:	85 c0                	test   %eax,%eax
  8007bd:	74 26                	je     8007e5 <vsnprintf+0x4b>
  8007bf:	85 d2                	test   %edx,%edx
  8007c1:	7e 22                	jle    8007e5 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007c3:	ff 75 14             	pushl  0x14(%ebp)
  8007c6:	ff 75 10             	pushl  0x10(%ebp)
  8007c9:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007cc:	50                   	push   %eax
  8007cd:	68 c5 02 80 00       	push   $0x8002c5
  8007d2:	e8 30 fb ff ff       	call   800307 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007d7:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007da:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007e0:	83 c4 10             	add    $0x10,%esp
}
  8007e3:	c9                   	leave  
  8007e4:	c3                   	ret    
		return -E_INVAL;
  8007e5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007ea:	eb f7                	jmp    8007e3 <vsnprintf+0x49>

008007ec <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007ec:	f3 0f 1e fb          	endbr32 
  8007f0:	55                   	push   %ebp
  8007f1:	89 e5                	mov    %esp,%ebp
  8007f3:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007f6:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007f9:	50                   	push   %eax
  8007fa:	ff 75 10             	pushl  0x10(%ebp)
  8007fd:	ff 75 0c             	pushl  0xc(%ebp)
  800800:	ff 75 08             	pushl  0x8(%ebp)
  800803:	e8 92 ff ff ff       	call   80079a <vsnprintf>
	va_end(ap);

	return rc;
}
  800808:	c9                   	leave  
  800809:	c3                   	ret    

0080080a <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80080a:	f3 0f 1e fb          	endbr32 
  80080e:	55                   	push   %ebp
  80080f:	89 e5                	mov    %esp,%ebp
  800811:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800814:	b8 00 00 00 00       	mov    $0x0,%eax
  800819:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80081d:	74 05                	je     800824 <strlen+0x1a>
		n++;
  80081f:	83 c0 01             	add    $0x1,%eax
  800822:	eb f5                	jmp    800819 <strlen+0xf>
	return n;
}
  800824:	5d                   	pop    %ebp
  800825:	c3                   	ret    

00800826 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800826:	f3 0f 1e fb          	endbr32 
  80082a:	55                   	push   %ebp
  80082b:	89 e5                	mov    %esp,%ebp
  80082d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800830:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800833:	b8 00 00 00 00       	mov    $0x0,%eax
  800838:	39 d0                	cmp    %edx,%eax
  80083a:	74 0d                	je     800849 <strnlen+0x23>
  80083c:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800840:	74 05                	je     800847 <strnlen+0x21>
		n++;
  800842:	83 c0 01             	add    $0x1,%eax
  800845:	eb f1                	jmp    800838 <strnlen+0x12>
  800847:	89 c2                	mov    %eax,%edx
	return n;
}
  800849:	89 d0                	mov    %edx,%eax
  80084b:	5d                   	pop    %ebp
  80084c:	c3                   	ret    

0080084d <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80084d:	f3 0f 1e fb          	endbr32 
  800851:	55                   	push   %ebp
  800852:	89 e5                	mov    %esp,%ebp
  800854:	53                   	push   %ebx
  800855:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800858:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80085b:	b8 00 00 00 00       	mov    $0x0,%eax
  800860:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800864:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800867:	83 c0 01             	add    $0x1,%eax
  80086a:	84 d2                	test   %dl,%dl
  80086c:	75 f2                	jne    800860 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  80086e:	89 c8                	mov    %ecx,%eax
  800870:	5b                   	pop    %ebx
  800871:	5d                   	pop    %ebp
  800872:	c3                   	ret    

00800873 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800873:	f3 0f 1e fb          	endbr32 
  800877:	55                   	push   %ebp
  800878:	89 e5                	mov    %esp,%ebp
  80087a:	53                   	push   %ebx
  80087b:	83 ec 10             	sub    $0x10,%esp
  80087e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800881:	53                   	push   %ebx
  800882:	e8 83 ff ff ff       	call   80080a <strlen>
  800887:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  80088a:	ff 75 0c             	pushl  0xc(%ebp)
  80088d:	01 d8                	add    %ebx,%eax
  80088f:	50                   	push   %eax
  800890:	e8 b8 ff ff ff       	call   80084d <strcpy>
	return dst;
}
  800895:	89 d8                	mov    %ebx,%eax
  800897:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80089a:	c9                   	leave  
  80089b:	c3                   	ret    

0080089c <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80089c:	f3 0f 1e fb          	endbr32 
  8008a0:	55                   	push   %ebp
  8008a1:	89 e5                	mov    %esp,%ebp
  8008a3:	56                   	push   %esi
  8008a4:	53                   	push   %ebx
  8008a5:	8b 75 08             	mov    0x8(%ebp),%esi
  8008a8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008ab:	89 f3                	mov    %esi,%ebx
  8008ad:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008b0:	89 f0                	mov    %esi,%eax
  8008b2:	39 d8                	cmp    %ebx,%eax
  8008b4:	74 11                	je     8008c7 <strncpy+0x2b>
		*dst++ = *src;
  8008b6:	83 c0 01             	add    $0x1,%eax
  8008b9:	0f b6 0a             	movzbl (%edx),%ecx
  8008bc:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008bf:	80 f9 01             	cmp    $0x1,%cl
  8008c2:	83 da ff             	sbb    $0xffffffff,%edx
  8008c5:	eb eb                	jmp    8008b2 <strncpy+0x16>
	}
	return ret;
}
  8008c7:	89 f0                	mov    %esi,%eax
  8008c9:	5b                   	pop    %ebx
  8008ca:	5e                   	pop    %esi
  8008cb:	5d                   	pop    %ebp
  8008cc:	c3                   	ret    

008008cd <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008cd:	f3 0f 1e fb          	endbr32 
  8008d1:	55                   	push   %ebp
  8008d2:	89 e5                	mov    %esp,%ebp
  8008d4:	56                   	push   %esi
  8008d5:	53                   	push   %ebx
  8008d6:	8b 75 08             	mov    0x8(%ebp),%esi
  8008d9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008dc:	8b 55 10             	mov    0x10(%ebp),%edx
  8008df:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008e1:	85 d2                	test   %edx,%edx
  8008e3:	74 21                	je     800906 <strlcpy+0x39>
  8008e5:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8008e9:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  8008eb:	39 c2                	cmp    %eax,%edx
  8008ed:	74 14                	je     800903 <strlcpy+0x36>
  8008ef:	0f b6 19             	movzbl (%ecx),%ebx
  8008f2:	84 db                	test   %bl,%bl
  8008f4:	74 0b                	je     800901 <strlcpy+0x34>
			*dst++ = *src++;
  8008f6:	83 c1 01             	add    $0x1,%ecx
  8008f9:	83 c2 01             	add    $0x1,%edx
  8008fc:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008ff:	eb ea                	jmp    8008eb <strlcpy+0x1e>
  800901:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800903:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800906:	29 f0                	sub    %esi,%eax
}
  800908:	5b                   	pop    %ebx
  800909:	5e                   	pop    %esi
  80090a:	5d                   	pop    %ebp
  80090b:	c3                   	ret    

0080090c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80090c:	f3 0f 1e fb          	endbr32 
  800910:	55                   	push   %ebp
  800911:	89 e5                	mov    %esp,%ebp
  800913:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800916:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800919:	0f b6 01             	movzbl (%ecx),%eax
  80091c:	84 c0                	test   %al,%al
  80091e:	74 0c                	je     80092c <strcmp+0x20>
  800920:	3a 02                	cmp    (%edx),%al
  800922:	75 08                	jne    80092c <strcmp+0x20>
		p++, q++;
  800924:	83 c1 01             	add    $0x1,%ecx
  800927:	83 c2 01             	add    $0x1,%edx
  80092a:	eb ed                	jmp    800919 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80092c:	0f b6 c0             	movzbl %al,%eax
  80092f:	0f b6 12             	movzbl (%edx),%edx
  800932:	29 d0                	sub    %edx,%eax
}
  800934:	5d                   	pop    %ebp
  800935:	c3                   	ret    

00800936 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800936:	f3 0f 1e fb          	endbr32 
  80093a:	55                   	push   %ebp
  80093b:	89 e5                	mov    %esp,%ebp
  80093d:	53                   	push   %ebx
  80093e:	8b 45 08             	mov    0x8(%ebp),%eax
  800941:	8b 55 0c             	mov    0xc(%ebp),%edx
  800944:	89 c3                	mov    %eax,%ebx
  800946:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800949:	eb 06                	jmp    800951 <strncmp+0x1b>
		n--, p++, q++;
  80094b:	83 c0 01             	add    $0x1,%eax
  80094e:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800951:	39 d8                	cmp    %ebx,%eax
  800953:	74 16                	je     80096b <strncmp+0x35>
  800955:	0f b6 08             	movzbl (%eax),%ecx
  800958:	84 c9                	test   %cl,%cl
  80095a:	74 04                	je     800960 <strncmp+0x2a>
  80095c:	3a 0a                	cmp    (%edx),%cl
  80095e:	74 eb                	je     80094b <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800960:	0f b6 00             	movzbl (%eax),%eax
  800963:	0f b6 12             	movzbl (%edx),%edx
  800966:	29 d0                	sub    %edx,%eax
}
  800968:	5b                   	pop    %ebx
  800969:	5d                   	pop    %ebp
  80096a:	c3                   	ret    
		return 0;
  80096b:	b8 00 00 00 00       	mov    $0x0,%eax
  800970:	eb f6                	jmp    800968 <strncmp+0x32>

00800972 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800972:	f3 0f 1e fb          	endbr32 
  800976:	55                   	push   %ebp
  800977:	89 e5                	mov    %esp,%ebp
  800979:	8b 45 08             	mov    0x8(%ebp),%eax
  80097c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800980:	0f b6 10             	movzbl (%eax),%edx
  800983:	84 d2                	test   %dl,%dl
  800985:	74 09                	je     800990 <strchr+0x1e>
		if (*s == c)
  800987:	38 ca                	cmp    %cl,%dl
  800989:	74 0a                	je     800995 <strchr+0x23>
	for (; *s; s++)
  80098b:	83 c0 01             	add    $0x1,%eax
  80098e:	eb f0                	jmp    800980 <strchr+0xe>
			return (char *) s;
	return 0;
  800990:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800995:	5d                   	pop    %ebp
  800996:	c3                   	ret    

00800997 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800997:	f3 0f 1e fb          	endbr32 
  80099b:	55                   	push   %ebp
  80099c:	89 e5                	mov    %esp,%ebp
  80099e:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009a5:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8009a8:	38 ca                	cmp    %cl,%dl
  8009aa:	74 09                	je     8009b5 <strfind+0x1e>
  8009ac:	84 d2                	test   %dl,%dl
  8009ae:	74 05                	je     8009b5 <strfind+0x1e>
	for (; *s; s++)
  8009b0:	83 c0 01             	add    $0x1,%eax
  8009b3:	eb f0                	jmp    8009a5 <strfind+0xe>
			break;
	return (char *) s;
}
  8009b5:	5d                   	pop    %ebp
  8009b6:	c3                   	ret    

008009b7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009b7:	f3 0f 1e fb          	endbr32 
  8009bb:	55                   	push   %ebp
  8009bc:	89 e5                	mov    %esp,%ebp
  8009be:	57                   	push   %edi
  8009bf:	56                   	push   %esi
  8009c0:	53                   	push   %ebx
  8009c1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009c4:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009c7:	85 c9                	test   %ecx,%ecx
  8009c9:	74 31                	je     8009fc <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009cb:	89 f8                	mov    %edi,%eax
  8009cd:	09 c8                	or     %ecx,%eax
  8009cf:	a8 03                	test   $0x3,%al
  8009d1:	75 23                	jne    8009f6 <memset+0x3f>
		c &= 0xFF;
  8009d3:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009d7:	89 d3                	mov    %edx,%ebx
  8009d9:	c1 e3 08             	shl    $0x8,%ebx
  8009dc:	89 d0                	mov    %edx,%eax
  8009de:	c1 e0 18             	shl    $0x18,%eax
  8009e1:	89 d6                	mov    %edx,%esi
  8009e3:	c1 e6 10             	shl    $0x10,%esi
  8009e6:	09 f0                	or     %esi,%eax
  8009e8:	09 c2                	or     %eax,%edx
  8009ea:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8009ec:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  8009ef:	89 d0                	mov    %edx,%eax
  8009f1:	fc                   	cld    
  8009f2:	f3 ab                	rep stos %eax,%es:(%edi)
  8009f4:	eb 06                	jmp    8009fc <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009f6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009f9:	fc                   	cld    
  8009fa:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009fc:	89 f8                	mov    %edi,%eax
  8009fe:	5b                   	pop    %ebx
  8009ff:	5e                   	pop    %esi
  800a00:	5f                   	pop    %edi
  800a01:	5d                   	pop    %ebp
  800a02:	c3                   	ret    

00800a03 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a03:	f3 0f 1e fb          	endbr32 
  800a07:	55                   	push   %ebp
  800a08:	89 e5                	mov    %esp,%ebp
  800a0a:	57                   	push   %edi
  800a0b:	56                   	push   %esi
  800a0c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a0f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a12:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a15:	39 c6                	cmp    %eax,%esi
  800a17:	73 32                	jae    800a4b <memmove+0x48>
  800a19:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a1c:	39 c2                	cmp    %eax,%edx
  800a1e:	76 2b                	jbe    800a4b <memmove+0x48>
		s += n;
		d += n;
  800a20:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a23:	89 fe                	mov    %edi,%esi
  800a25:	09 ce                	or     %ecx,%esi
  800a27:	09 d6                	or     %edx,%esi
  800a29:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a2f:	75 0e                	jne    800a3f <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a31:	83 ef 04             	sub    $0x4,%edi
  800a34:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a37:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800a3a:	fd                   	std    
  800a3b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a3d:	eb 09                	jmp    800a48 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a3f:	83 ef 01             	sub    $0x1,%edi
  800a42:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800a45:	fd                   	std    
  800a46:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a48:	fc                   	cld    
  800a49:	eb 1a                	jmp    800a65 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a4b:	89 c2                	mov    %eax,%edx
  800a4d:	09 ca                	or     %ecx,%edx
  800a4f:	09 f2                	or     %esi,%edx
  800a51:	f6 c2 03             	test   $0x3,%dl
  800a54:	75 0a                	jne    800a60 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a56:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800a59:	89 c7                	mov    %eax,%edi
  800a5b:	fc                   	cld    
  800a5c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a5e:	eb 05                	jmp    800a65 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800a60:	89 c7                	mov    %eax,%edi
  800a62:	fc                   	cld    
  800a63:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a65:	5e                   	pop    %esi
  800a66:	5f                   	pop    %edi
  800a67:	5d                   	pop    %ebp
  800a68:	c3                   	ret    

00800a69 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a69:	f3 0f 1e fb          	endbr32 
  800a6d:	55                   	push   %ebp
  800a6e:	89 e5                	mov    %esp,%ebp
  800a70:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a73:	ff 75 10             	pushl  0x10(%ebp)
  800a76:	ff 75 0c             	pushl  0xc(%ebp)
  800a79:	ff 75 08             	pushl  0x8(%ebp)
  800a7c:	e8 82 ff ff ff       	call   800a03 <memmove>
}
  800a81:	c9                   	leave  
  800a82:	c3                   	ret    

00800a83 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a83:	f3 0f 1e fb          	endbr32 
  800a87:	55                   	push   %ebp
  800a88:	89 e5                	mov    %esp,%ebp
  800a8a:	56                   	push   %esi
  800a8b:	53                   	push   %ebx
  800a8c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a8f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a92:	89 c6                	mov    %eax,%esi
  800a94:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a97:	39 f0                	cmp    %esi,%eax
  800a99:	74 1c                	je     800ab7 <memcmp+0x34>
		if (*s1 != *s2)
  800a9b:	0f b6 08             	movzbl (%eax),%ecx
  800a9e:	0f b6 1a             	movzbl (%edx),%ebx
  800aa1:	38 d9                	cmp    %bl,%cl
  800aa3:	75 08                	jne    800aad <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800aa5:	83 c0 01             	add    $0x1,%eax
  800aa8:	83 c2 01             	add    $0x1,%edx
  800aab:	eb ea                	jmp    800a97 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800aad:	0f b6 c1             	movzbl %cl,%eax
  800ab0:	0f b6 db             	movzbl %bl,%ebx
  800ab3:	29 d8                	sub    %ebx,%eax
  800ab5:	eb 05                	jmp    800abc <memcmp+0x39>
	}

	return 0;
  800ab7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800abc:	5b                   	pop    %ebx
  800abd:	5e                   	pop    %esi
  800abe:	5d                   	pop    %ebp
  800abf:	c3                   	ret    

00800ac0 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ac0:	f3 0f 1e fb          	endbr32 
  800ac4:	55                   	push   %ebp
  800ac5:	89 e5                	mov    %esp,%ebp
  800ac7:	8b 45 08             	mov    0x8(%ebp),%eax
  800aca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800acd:	89 c2                	mov    %eax,%edx
  800acf:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800ad2:	39 d0                	cmp    %edx,%eax
  800ad4:	73 09                	jae    800adf <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ad6:	38 08                	cmp    %cl,(%eax)
  800ad8:	74 05                	je     800adf <memfind+0x1f>
	for (; s < ends; s++)
  800ada:	83 c0 01             	add    $0x1,%eax
  800add:	eb f3                	jmp    800ad2 <memfind+0x12>
			break;
	return (void *) s;
}
  800adf:	5d                   	pop    %ebp
  800ae0:	c3                   	ret    

00800ae1 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ae1:	f3 0f 1e fb          	endbr32 
  800ae5:	55                   	push   %ebp
  800ae6:	89 e5                	mov    %esp,%ebp
  800ae8:	57                   	push   %edi
  800ae9:	56                   	push   %esi
  800aea:	53                   	push   %ebx
  800aeb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800aee:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800af1:	eb 03                	jmp    800af6 <strtol+0x15>
		s++;
  800af3:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800af6:	0f b6 01             	movzbl (%ecx),%eax
  800af9:	3c 20                	cmp    $0x20,%al
  800afb:	74 f6                	je     800af3 <strtol+0x12>
  800afd:	3c 09                	cmp    $0x9,%al
  800aff:	74 f2                	je     800af3 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800b01:	3c 2b                	cmp    $0x2b,%al
  800b03:	74 2a                	je     800b2f <strtol+0x4e>
	int neg = 0;
  800b05:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800b0a:	3c 2d                	cmp    $0x2d,%al
  800b0c:	74 2b                	je     800b39 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b0e:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b14:	75 0f                	jne    800b25 <strtol+0x44>
  800b16:	80 39 30             	cmpb   $0x30,(%ecx)
  800b19:	74 28                	je     800b43 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b1b:	85 db                	test   %ebx,%ebx
  800b1d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b22:	0f 44 d8             	cmove  %eax,%ebx
  800b25:	b8 00 00 00 00       	mov    $0x0,%eax
  800b2a:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800b2d:	eb 46                	jmp    800b75 <strtol+0x94>
		s++;
  800b2f:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800b32:	bf 00 00 00 00       	mov    $0x0,%edi
  800b37:	eb d5                	jmp    800b0e <strtol+0x2d>
		s++, neg = 1;
  800b39:	83 c1 01             	add    $0x1,%ecx
  800b3c:	bf 01 00 00 00       	mov    $0x1,%edi
  800b41:	eb cb                	jmp    800b0e <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b43:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b47:	74 0e                	je     800b57 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800b49:	85 db                	test   %ebx,%ebx
  800b4b:	75 d8                	jne    800b25 <strtol+0x44>
		s++, base = 8;
  800b4d:	83 c1 01             	add    $0x1,%ecx
  800b50:	bb 08 00 00 00       	mov    $0x8,%ebx
  800b55:	eb ce                	jmp    800b25 <strtol+0x44>
		s += 2, base = 16;
  800b57:	83 c1 02             	add    $0x2,%ecx
  800b5a:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b5f:	eb c4                	jmp    800b25 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800b61:	0f be d2             	movsbl %dl,%edx
  800b64:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b67:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b6a:	7d 3a                	jge    800ba6 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800b6c:	83 c1 01             	add    $0x1,%ecx
  800b6f:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b73:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800b75:	0f b6 11             	movzbl (%ecx),%edx
  800b78:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b7b:	89 f3                	mov    %esi,%ebx
  800b7d:	80 fb 09             	cmp    $0x9,%bl
  800b80:	76 df                	jbe    800b61 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800b82:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b85:	89 f3                	mov    %esi,%ebx
  800b87:	80 fb 19             	cmp    $0x19,%bl
  800b8a:	77 08                	ja     800b94 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800b8c:	0f be d2             	movsbl %dl,%edx
  800b8f:	83 ea 57             	sub    $0x57,%edx
  800b92:	eb d3                	jmp    800b67 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800b94:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b97:	89 f3                	mov    %esi,%ebx
  800b99:	80 fb 19             	cmp    $0x19,%bl
  800b9c:	77 08                	ja     800ba6 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800b9e:	0f be d2             	movsbl %dl,%edx
  800ba1:	83 ea 37             	sub    $0x37,%edx
  800ba4:	eb c1                	jmp    800b67 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800ba6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800baa:	74 05                	je     800bb1 <strtol+0xd0>
		*endptr = (char *) s;
  800bac:	8b 75 0c             	mov    0xc(%ebp),%esi
  800baf:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800bb1:	89 c2                	mov    %eax,%edx
  800bb3:	f7 da                	neg    %edx
  800bb5:	85 ff                	test   %edi,%edi
  800bb7:	0f 45 c2             	cmovne %edx,%eax
}
  800bba:	5b                   	pop    %ebx
  800bbb:	5e                   	pop    %esi
  800bbc:	5f                   	pop    %edi
  800bbd:	5d                   	pop    %ebp
  800bbe:	c3                   	ret    

00800bbf <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800bbf:	f3 0f 1e fb          	endbr32 
  800bc3:	55                   	push   %ebp
  800bc4:	89 e5                	mov    %esp,%ebp
  800bc6:	57                   	push   %edi
  800bc7:	56                   	push   %esi
  800bc8:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bc9:	b8 00 00 00 00       	mov    $0x0,%eax
  800bce:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bd4:	89 c3                	mov    %eax,%ebx
  800bd6:	89 c7                	mov    %eax,%edi
  800bd8:	89 c6                	mov    %eax,%esi
  800bda:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bdc:	5b                   	pop    %ebx
  800bdd:	5e                   	pop    %esi
  800bde:	5f                   	pop    %edi
  800bdf:	5d                   	pop    %ebp
  800be0:	c3                   	ret    

00800be1 <sys_cgetc>:

int
sys_cgetc(void)
{
  800be1:	f3 0f 1e fb          	endbr32 
  800be5:	55                   	push   %ebp
  800be6:	89 e5                	mov    %esp,%ebp
  800be8:	57                   	push   %edi
  800be9:	56                   	push   %esi
  800bea:	53                   	push   %ebx
	asm volatile("int %1\n"
  800beb:	ba 00 00 00 00       	mov    $0x0,%edx
  800bf0:	b8 01 00 00 00       	mov    $0x1,%eax
  800bf5:	89 d1                	mov    %edx,%ecx
  800bf7:	89 d3                	mov    %edx,%ebx
  800bf9:	89 d7                	mov    %edx,%edi
  800bfb:	89 d6                	mov    %edx,%esi
  800bfd:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bff:	5b                   	pop    %ebx
  800c00:	5e                   	pop    %esi
  800c01:	5f                   	pop    %edi
  800c02:	5d                   	pop    %ebp
  800c03:	c3                   	ret    

00800c04 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c04:	f3 0f 1e fb          	endbr32 
  800c08:	55                   	push   %ebp
  800c09:	89 e5                	mov    %esp,%ebp
  800c0b:	57                   	push   %edi
  800c0c:	56                   	push   %esi
  800c0d:	53                   	push   %ebx
  800c0e:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c11:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c16:	8b 55 08             	mov    0x8(%ebp),%edx
  800c19:	b8 03 00 00 00       	mov    $0x3,%eax
  800c1e:	89 cb                	mov    %ecx,%ebx
  800c20:	89 cf                	mov    %ecx,%edi
  800c22:	89 ce                	mov    %ecx,%esi
  800c24:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c26:	85 c0                	test   %eax,%eax
  800c28:	7f 08                	jg     800c32 <sys_env_destroy+0x2e>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c2a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c2d:	5b                   	pop    %ebx
  800c2e:	5e                   	pop    %esi
  800c2f:	5f                   	pop    %edi
  800c30:	5d                   	pop    %ebp
  800c31:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c32:	83 ec 0c             	sub    $0xc,%esp
  800c35:	50                   	push   %eax
  800c36:	6a 03                	push   $0x3
  800c38:	68 24 14 80 00       	push   $0x801424
  800c3d:	6a 23                	push   $0x23
  800c3f:	68 41 14 80 00       	push   $0x801441
  800c44:	e8 d4 f4 ff ff       	call   80011d <_panic>

00800c49 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c49:	f3 0f 1e fb          	endbr32 
  800c4d:	55                   	push   %ebp
  800c4e:	89 e5                	mov    %esp,%ebp
  800c50:	57                   	push   %edi
  800c51:	56                   	push   %esi
  800c52:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c53:	ba 00 00 00 00       	mov    $0x0,%edx
  800c58:	b8 02 00 00 00       	mov    $0x2,%eax
  800c5d:	89 d1                	mov    %edx,%ecx
  800c5f:	89 d3                	mov    %edx,%ebx
  800c61:	89 d7                	mov    %edx,%edi
  800c63:	89 d6                	mov    %edx,%esi
  800c65:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c67:	5b                   	pop    %ebx
  800c68:	5e                   	pop    %esi
  800c69:	5f                   	pop    %edi
  800c6a:	5d                   	pop    %ebp
  800c6b:	c3                   	ret    

00800c6c <sys_yield>:

void
sys_yield(void)
{
  800c6c:	f3 0f 1e fb          	endbr32 
  800c70:	55                   	push   %ebp
  800c71:	89 e5                	mov    %esp,%ebp
  800c73:	57                   	push   %edi
  800c74:	56                   	push   %esi
  800c75:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c76:	ba 00 00 00 00       	mov    $0x0,%edx
  800c7b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c80:	89 d1                	mov    %edx,%ecx
  800c82:	89 d3                	mov    %edx,%ebx
  800c84:	89 d7                	mov    %edx,%edi
  800c86:	89 d6                	mov    %edx,%esi
  800c88:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c8a:	5b                   	pop    %ebx
  800c8b:	5e                   	pop    %esi
  800c8c:	5f                   	pop    %edi
  800c8d:	5d                   	pop    %ebp
  800c8e:	c3                   	ret    

00800c8f <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c8f:	f3 0f 1e fb          	endbr32 
  800c93:	55                   	push   %ebp
  800c94:	89 e5                	mov    %esp,%ebp
  800c96:	57                   	push   %edi
  800c97:	56                   	push   %esi
  800c98:	53                   	push   %ebx
  800c99:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c9c:	be 00 00 00 00       	mov    $0x0,%esi
  800ca1:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca7:	b8 04 00 00 00       	mov    $0x4,%eax
  800cac:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800caf:	89 f7                	mov    %esi,%edi
  800cb1:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cb3:	85 c0                	test   %eax,%eax
  800cb5:	7f 08                	jg     800cbf <sys_page_alloc+0x30>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800cb7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cba:	5b                   	pop    %ebx
  800cbb:	5e                   	pop    %esi
  800cbc:	5f                   	pop    %edi
  800cbd:	5d                   	pop    %ebp
  800cbe:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cbf:	83 ec 0c             	sub    $0xc,%esp
  800cc2:	50                   	push   %eax
  800cc3:	6a 04                	push   $0x4
  800cc5:	68 24 14 80 00       	push   $0x801424
  800cca:	6a 23                	push   $0x23
  800ccc:	68 41 14 80 00       	push   $0x801441
  800cd1:	e8 47 f4 ff ff       	call   80011d <_panic>

00800cd6 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800cd6:	f3 0f 1e fb          	endbr32 
  800cda:	55                   	push   %ebp
  800cdb:	89 e5                	mov    %esp,%ebp
  800cdd:	57                   	push   %edi
  800cde:	56                   	push   %esi
  800cdf:	53                   	push   %ebx
  800ce0:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800ce3:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce9:	b8 05 00 00 00       	mov    $0x5,%eax
  800cee:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cf1:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cf4:	8b 75 18             	mov    0x18(%ebp),%esi
  800cf7:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cf9:	85 c0                	test   %eax,%eax
  800cfb:	7f 08                	jg     800d05 <sys_page_map+0x2f>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800cfd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d00:	5b                   	pop    %ebx
  800d01:	5e                   	pop    %esi
  800d02:	5f                   	pop    %edi
  800d03:	5d                   	pop    %ebp
  800d04:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d05:	83 ec 0c             	sub    $0xc,%esp
  800d08:	50                   	push   %eax
  800d09:	6a 05                	push   $0x5
  800d0b:	68 24 14 80 00       	push   $0x801424
  800d10:	6a 23                	push   $0x23
  800d12:	68 41 14 80 00       	push   $0x801441
  800d17:	e8 01 f4 ff ff       	call   80011d <_panic>

00800d1c <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d1c:	f3 0f 1e fb          	endbr32 
  800d20:	55                   	push   %ebp
  800d21:	89 e5                	mov    %esp,%ebp
  800d23:	57                   	push   %edi
  800d24:	56                   	push   %esi
  800d25:	53                   	push   %ebx
  800d26:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d29:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d2e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d31:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d34:	b8 06 00 00 00       	mov    $0x6,%eax
  800d39:	89 df                	mov    %ebx,%edi
  800d3b:	89 de                	mov    %ebx,%esi
  800d3d:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d3f:	85 c0                	test   %eax,%eax
  800d41:	7f 08                	jg     800d4b <sys_page_unmap+0x2f>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d43:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d46:	5b                   	pop    %ebx
  800d47:	5e                   	pop    %esi
  800d48:	5f                   	pop    %edi
  800d49:	5d                   	pop    %ebp
  800d4a:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d4b:	83 ec 0c             	sub    $0xc,%esp
  800d4e:	50                   	push   %eax
  800d4f:	6a 06                	push   $0x6
  800d51:	68 24 14 80 00       	push   $0x801424
  800d56:	6a 23                	push   $0x23
  800d58:	68 41 14 80 00       	push   $0x801441
  800d5d:	e8 bb f3 ff ff       	call   80011d <_panic>

00800d62 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d62:	f3 0f 1e fb          	endbr32 
  800d66:	55                   	push   %ebp
  800d67:	89 e5                	mov    %esp,%ebp
  800d69:	57                   	push   %edi
  800d6a:	56                   	push   %esi
  800d6b:	53                   	push   %ebx
  800d6c:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d6f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d74:	8b 55 08             	mov    0x8(%ebp),%edx
  800d77:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d7a:	b8 08 00 00 00       	mov    $0x8,%eax
  800d7f:	89 df                	mov    %ebx,%edi
  800d81:	89 de                	mov    %ebx,%esi
  800d83:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d85:	85 c0                	test   %eax,%eax
  800d87:	7f 08                	jg     800d91 <sys_env_set_status+0x2f>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d89:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d8c:	5b                   	pop    %ebx
  800d8d:	5e                   	pop    %esi
  800d8e:	5f                   	pop    %edi
  800d8f:	5d                   	pop    %ebp
  800d90:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d91:	83 ec 0c             	sub    $0xc,%esp
  800d94:	50                   	push   %eax
  800d95:	6a 08                	push   $0x8
  800d97:	68 24 14 80 00       	push   $0x801424
  800d9c:	6a 23                	push   $0x23
  800d9e:	68 41 14 80 00       	push   $0x801441
  800da3:	e8 75 f3 ff ff       	call   80011d <_panic>

00800da8 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800da8:	f3 0f 1e fb          	endbr32 
  800dac:	55                   	push   %ebp
  800dad:	89 e5                	mov    %esp,%ebp
  800daf:	57                   	push   %edi
  800db0:	56                   	push   %esi
  800db1:	53                   	push   %ebx
  800db2:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800db5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dba:	8b 55 08             	mov    0x8(%ebp),%edx
  800dbd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dc0:	b8 09 00 00 00       	mov    $0x9,%eax
  800dc5:	89 df                	mov    %ebx,%edi
  800dc7:	89 de                	mov    %ebx,%esi
  800dc9:	cd 30                	int    $0x30
	if(check && ret > 0)
  800dcb:	85 c0                	test   %eax,%eax
  800dcd:	7f 08                	jg     800dd7 <sys_env_set_pgfault_upcall+0x2f>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800dcf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dd2:	5b                   	pop    %ebx
  800dd3:	5e                   	pop    %esi
  800dd4:	5f                   	pop    %edi
  800dd5:	5d                   	pop    %ebp
  800dd6:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800dd7:	83 ec 0c             	sub    $0xc,%esp
  800dda:	50                   	push   %eax
  800ddb:	6a 09                	push   $0x9
  800ddd:	68 24 14 80 00       	push   $0x801424
  800de2:	6a 23                	push   $0x23
  800de4:	68 41 14 80 00       	push   $0x801441
  800de9:	e8 2f f3 ff ff       	call   80011d <_panic>

00800dee <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800dee:	f3 0f 1e fb          	endbr32 
  800df2:	55                   	push   %ebp
  800df3:	89 e5                	mov    %esp,%ebp
  800df5:	57                   	push   %edi
  800df6:	56                   	push   %esi
  800df7:	53                   	push   %ebx
	asm volatile("int %1\n"
  800df8:	8b 55 08             	mov    0x8(%ebp),%edx
  800dfb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dfe:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e03:	be 00 00 00 00       	mov    $0x0,%esi
  800e08:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e0b:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e0e:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e10:	5b                   	pop    %ebx
  800e11:	5e                   	pop    %esi
  800e12:	5f                   	pop    %edi
  800e13:	5d                   	pop    %ebp
  800e14:	c3                   	ret    

00800e15 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e15:	f3 0f 1e fb          	endbr32 
  800e19:	55                   	push   %ebp
  800e1a:	89 e5                	mov    %esp,%ebp
  800e1c:	57                   	push   %edi
  800e1d:	56                   	push   %esi
  800e1e:	53                   	push   %ebx
  800e1f:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e22:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e27:	8b 55 08             	mov    0x8(%ebp),%edx
  800e2a:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e2f:	89 cb                	mov    %ecx,%ebx
  800e31:	89 cf                	mov    %ecx,%edi
  800e33:	89 ce                	mov    %ecx,%esi
  800e35:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e37:	85 c0                	test   %eax,%eax
  800e39:	7f 08                	jg     800e43 <sys_ipc_recv+0x2e>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e3b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e3e:	5b                   	pop    %ebx
  800e3f:	5e                   	pop    %esi
  800e40:	5f                   	pop    %edi
  800e41:	5d                   	pop    %ebp
  800e42:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e43:	83 ec 0c             	sub    $0xc,%esp
  800e46:	50                   	push   %eax
  800e47:	6a 0c                	push   $0xc
  800e49:	68 24 14 80 00       	push   $0x801424
  800e4e:	6a 23                	push   $0x23
  800e50:	68 41 14 80 00       	push   $0x801441
  800e55:	e8 c3 f2 ff ff       	call   80011d <_panic>

00800e5a <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800e5a:	f3 0f 1e fb          	endbr32 
  800e5e:	55                   	push   %ebp
  800e5f:	89 e5                	mov    %esp,%ebp
  800e61:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  800e64:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  800e6b:	74 0a                	je     800e77 <set_pgfault_handler+0x1d>
        sys_env_set_pgfault_upcall(0, _pgfault_upcall);
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800e6d:	8b 45 08             	mov    0x8(%ebp),%eax
  800e70:	a3 08 20 80 00       	mov    %eax,0x802008
}
  800e75:	c9                   	leave  
  800e76:	c3                   	ret    
		if (sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P) < 0)
  800e77:	83 ec 04             	sub    $0x4,%esp
  800e7a:	6a 07                	push   $0x7
  800e7c:	68 00 f0 bf ee       	push   $0xeebff000
  800e81:	6a 00                	push   $0x0
  800e83:	e8 07 fe ff ff       	call   800c8f <sys_page_alloc>
  800e88:	83 c4 10             	add    $0x10,%esp
  800e8b:	85 c0                	test   %eax,%eax
  800e8d:	78 14                	js     800ea3 <set_pgfault_handler+0x49>
        sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  800e8f:	83 ec 08             	sub    $0x8,%esp
  800e92:	68 b7 0e 80 00       	push   $0x800eb7
  800e97:	6a 00                	push   $0x0
  800e99:	e8 0a ff ff ff       	call   800da8 <sys_env_set_pgfault_upcall>
  800e9e:	83 c4 10             	add    $0x10,%esp
  800ea1:	eb ca                	jmp    800e6d <set_pgfault_handler+0x13>
            panic("set_pgfault_handler failed.");
  800ea3:	83 ec 04             	sub    $0x4,%esp
  800ea6:	68 4f 14 80 00       	push   $0x80144f
  800eab:	6a 21                	push   $0x21
  800ead:	68 6b 14 80 00       	push   $0x80146b
  800eb2:	e8 66 f2 ff ff       	call   80011d <_panic>

00800eb7 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800eb7:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800eb8:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  800ebd:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800ebf:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	addl $8, %esp
  800ec2:	83 c4 08             	add    $0x8,%esp
	movl 32(%esp), %eax
  800ec5:	8b 44 24 20          	mov    0x20(%esp),%eax
	movl 40(%esp), %edx
  800ec9:	8b 54 24 28          	mov    0x28(%esp),%edx
	subl $4, %edx
  800ecd:	83 ea 04             	sub    $0x4,%edx
	movl %eax, (%edx)
  800ed0:	89 02                	mov    %eax,(%edx)
	movl %edx, 40(%esp)
  800ed2:	89 54 24 28          	mov    %edx,0x28(%esp)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal
  800ed6:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp
  800ed7:	83 c4 04             	add    $0x4,%esp
	popfl
  800eda:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  800edb:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  800edc:	c3                   	ret    
  800edd:	66 90                	xchg   %ax,%ax
  800edf:	90                   	nop

00800ee0 <__udivdi3>:
  800ee0:	f3 0f 1e fb          	endbr32 
  800ee4:	55                   	push   %ebp
  800ee5:	57                   	push   %edi
  800ee6:	56                   	push   %esi
  800ee7:	53                   	push   %ebx
  800ee8:	83 ec 1c             	sub    $0x1c,%esp
  800eeb:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800eef:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800ef3:	8b 74 24 34          	mov    0x34(%esp),%esi
  800ef7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800efb:	85 d2                	test   %edx,%edx
  800efd:	75 19                	jne    800f18 <__udivdi3+0x38>
  800eff:	39 f3                	cmp    %esi,%ebx
  800f01:	76 4d                	jbe    800f50 <__udivdi3+0x70>
  800f03:	31 ff                	xor    %edi,%edi
  800f05:	89 e8                	mov    %ebp,%eax
  800f07:	89 f2                	mov    %esi,%edx
  800f09:	f7 f3                	div    %ebx
  800f0b:	89 fa                	mov    %edi,%edx
  800f0d:	83 c4 1c             	add    $0x1c,%esp
  800f10:	5b                   	pop    %ebx
  800f11:	5e                   	pop    %esi
  800f12:	5f                   	pop    %edi
  800f13:	5d                   	pop    %ebp
  800f14:	c3                   	ret    
  800f15:	8d 76 00             	lea    0x0(%esi),%esi
  800f18:	39 f2                	cmp    %esi,%edx
  800f1a:	76 14                	jbe    800f30 <__udivdi3+0x50>
  800f1c:	31 ff                	xor    %edi,%edi
  800f1e:	31 c0                	xor    %eax,%eax
  800f20:	89 fa                	mov    %edi,%edx
  800f22:	83 c4 1c             	add    $0x1c,%esp
  800f25:	5b                   	pop    %ebx
  800f26:	5e                   	pop    %esi
  800f27:	5f                   	pop    %edi
  800f28:	5d                   	pop    %ebp
  800f29:	c3                   	ret    
  800f2a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800f30:	0f bd fa             	bsr    %edx,%edi
  800f33:	83 f7 1f             	xor    $0x1f,%edi
  800f36:	75 48                	jne    800f80 <__udivdi3+0xa0>
  800f38:	39 f2                	cmp    %esi,%edx
  800f3a:	72 06                	jb     800f42 <__udivdi3+0x62>
  800f3c:	31 c0                	xor    %eax,%eax
  800f3e:	39 eb                	cmp    %ebp,%ebx
  800f40:	77 de                	ja     800f20 <__udivdi3+0x40>
  800f42:	b8 01 00 00 00       	mov    $0x1,%eax
  800f47:	eb d7                	jmp    800f20 <__udivdi3+0x40>
  800f49:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f50:	89 d9                	mov    %ebx,%ecx
  800f52:	85 db                	test   %ebx,%ebx
  800f54:	75 0b                	jne    800f61 <__udivdi3+0x81>
  800f56:	b8 01 00 00 00       	mov    $0x1,%eax
  800f5b:	31 d2                	xor    %edx,%edx
  800f5d:	f7 f3                	div    %ebx
  800f5f:	89 c1                	mov    %eax,%ecx
  800f61:	31 d2                	xor    %edx,%edx
  800f63:	89 f0                	mov    %esi,%eax
  800f65:	f7 f1                	div    %ecx
  800f67:	89 c6                	mov    %eax,%esi
  800f69:	89 e8                	mov    %ebp,%eax
  800f6b:	89 f7                	mov    %esi,%edi
  800f6d:	f7 f1                	div    %ecx
  800f6f:	89 fa                	mov    %edi,%edx
  800f71:	83 c4 1c             	add    $0x1c,%esp
  800f74:	5b                   	pop    %ebx
  800f75:	5e                   	pop    %esi
  800f76:	5f                   	pop    %edi
  800f77:	5d                   	pop    %ebp
  800f78:	c3                   	ret    
  800f79:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f80:	89 f9                	mov    %edi,%ecx
  800f82:	b8 20 00 00 00       	mov    $0x20,%eax
  800f87:	29 f8                	sub    %edi,%eax
  800f89:	d3 e2                	shl    %cl,%edx
  800f8b:	89 54 24 08          	mov    %edx,0x8(%esp)
  800f8f:	89 c1                	mov    %eax,%ecx
  800f91:	89 da                	mov    %ebx,%edx
  800f93:	d3 ea                	shr    %cl,%edx
  800f95:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800f99:	09 d1                	or     %edx,%ecx
  800f9b:	89 f2                	mov    %esi,%edx
  800f9d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800fa1:	89 f9                	mov    %edi,%ecx
  800fa3:	d3 e3                	shl    %cl,%ebx
  800fa5:	89 c1                	mov    %eax,%ecx
  800fa7:	d3 ea                	shr    %cl,%edx
  800fa9:	89 f9                	mov    %edi,%ecx
  800fab:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800faf:	89 eb                	mov    %ebp,%ebx
  800fb1:	d3 e6                	shl    %cl,%esi
  800fb3:	89 c1                	mov    %eax,%ecx
  800fb5:	d3 eb                	shr    %cl,%ebx
  800fb7:	09 de                	or     %ebx,%esi
  800fb9:	89 f0                	mov    %esi,%eax
  800fbb:	f7 74 24 08          	divl   0x8(%esp)
  800fbf:	89 d6                	mov    %edx,%esi
  800fc1:	89 c3                	mov    %eax,%ebx
  800fc3:	f7 64 24 0c          	mull   0xc(%esp)
  800fc7:	39 d6                	cmp    %edx,%esi
  800fc9:	72 15                	jb     800fe0 <__udivdi3+0x100>
  800fcb:	89 f9                	mov    %edi,%ecx
  800fcd:	d3 e5                	shl    %cl,%ebp
  800fcf:	39 c5                	cmp    %eax,%ebp
  800fd1:	73 04                	jae    800fd7 <__udivdi3+0xf7>
  800fd3:	39 d6                	cmp    %edx,%esi
  800fd5:	74 09                	je     800fe0 <__udivdi3+0x100>
  800fd7:	89 d8                	mov    %ebx,%eax
  800fd9:	31 ff                	xor    %edi,%edi
  800fdb:	e9 40 ff ff ff       	jmp    800f20 <__udivdi3+0x40>
  800fe0:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800fe3:	31 ff                	xor    %edi,%edi
  800fe5:	e9 36 ff ff ff       	jmp    800f20 <__udivdi3+0x40>
  800fea:	66 90                	xchg   %ax,%ax
  800fec:	66 90                	xchg   %ax,%ax
  800fee:	66 90                	xchg   %ax,%ax

00800ff0 <__umoddi3>:
  800ff0:	f3 0f 1e fb          	endbr32 
  800ff4:	55                   	push   %ebp
  800ff5:	57                   	push   %edi
  800ff6:	56                   	push   %esi
  800ff7:	53                   	push   %ebx
  800ff8:	83 ec 1c             	sub    $0x1c,%esp
  800ffb:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  800fff:	8b 74 24 30          	mov    0x30(%esp),%esi
  801003:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  801007:	8b 7c 24 38          	mov    0x38(%esp),%edi
  80100b:	85 c0                	test   %eax,%eax
  80100d:	75 19                	jne    801028 <__umoddi3+0x38>
  80100f:	39 df                	cmp    %ebx,%edi
  801011:	76 5d                	jbe    801070 <__umoddi3+0x80>
  801013:	89 f0                	mov    %esi,%eax
  801015:	89 da                	mov    %ebx,%edx
  801017:	f7 f7                	div    %edi
  801019:	89 d0                	mov    %edx,%eax
  80101b:	31 d2                	xor    %edx,%edx
  80101d:	83 c4 1c             	add    $0x1c,%esp
  801020:	5b                   	pop    %ebx
  801021:	5e                   	pop    %esi
  801022:	5f                   	pop    %edi
  801023:	5d                   	pop    %ebp
  801024:	c3                   	ret    
  801025:	8d 76 00             	lea    0x0(%esi),%esi
  801028:	89 f2                	mov    %esi,%edx
  80102a:	39 d8                	cmp    %ebx,%eax
  80102c:	76 12                	jbe    801040 <__umoddi3+0x50>
  80102e:	89 f0                	mov    %esi,%eax
  801030:	89 da                	mov    %ebx,%edx
  801032:	83 c4 1c             	add    $0x1c,%esp
  801035:	5b                   	pop    %ebx
  801036:	5e                   	pop    %esi
  801037:	5f                   	pop    %edi
  801038:	5d                   	pop    %ebp
  801039:	c3                   	ret    
  80103a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801040:	0f bd e8             	bsr    %eax,%ebp
  801043:	83 f5 1f             	xor    $0x1f,%ebp
  801046:	75 50                	jne    801098 <__umoddi3+0xa8>
  801048:	39 d8                	cmp    %ebx,%eax
  80104a:	0f 82 e0 00 00 00    	jb     801130 <__umoddi3+0x140>
  801050:	89 d9                	mov    %ebx,%ecx
  801052:	39 f7                	cmp    %esi,%edi
  801054:	0f 86 d6 00 00 00    	jbe    801130 <__umoddi3+0x140>
  80105a:	89 d0                	mov    %edx,%eax
  80105c:	89 ca                	mov    %ecx,%edx
  80105e:	83 c4 1c             	add    $0x1c,%esp
  801061:	5b                   	pop    %ebx
  801062:	5e                   	pop    %esi
  801063:	5f                   	pop    %edi
  801064:	5d                   	pop    %ebp
  801065:	c3                   	ret    
  801066:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80106d:	8d 76 00             	lea    0x0(%esi),%esi
  801070:	89 fd                	mov    %edi,%ebp
  801072:	85 ff                	test   %edi,%edi
  801074:	75 0b                	jne    801081 <__umoddi3+0x91>
  801076:	b8 01 00 00 00       	mov    $0x1,%eax
  80107b:	31 d2                	xor    %edx,%edx
  80107d:	f7 f7                	div    %edi
  80107f:	89 c5                	mov    %eax,%ebp
  801081:	89 d8                	mov    %ebx,%eax
  801083:	31 d2                	xor    %edx,%edx
  801085:	f7 f5                	div    %ebp
  801087:	89 f0                	mov    %esi,%eax
  801089:	f7 f5                	div    %ebp
  80108b:	89 d0                	mov    %edx,%eax
  80108d:	31 d2                	xor    %edx,%edx
  80108f:	eb 8c                	jmp    80101d <__umoddi3+0x2d>
  801091:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801098:	89 e9                	mov    %ebp,%ecx
  80109a:	ba 20 00 00 00       	mov    $0x20,%edx
  80109f:	29 ea                	sub    %ebp,%edx
  8010a1:	d3 e0                	shl    %cl,%eax
  8010a3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010a7:	89 d1                	mov    %edx,%ecx
  8010a9:	89 f8                	mov    %edi,%eax
  8010ab:	d3 e8                	shr    %cl,%eax
  8010ad:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8010b1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8010b5:	8b 54 24 04          	mov    0x4(%esp),%edx
  8010b9:	09 c1                	or     %eax,%ecx
  8010bb:	89 d8                	mov    %ebx,%eax
  8010bd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8010c1:	89 e9                	mov    %ebp,%ecx
  8010c3:	d3 e7                	shl    %cl,%edi
  8010c5:	89 d1                	mov    %edx,%ecx
  8010c7:	d3 e8                	shr    %cl,%eax
  8010c9:	89 e9                	mov    %ebp,%ecx
  8010cb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8010cf:	d3 e3                	shl    %cl,%ebx
  8010d1:	89 c7                	mov    %eax,%edi
  8010d3:	89 d1                	mov    %edx,%ecx
  8010d5:	89 f0                	mov    %esi,%eax
  8010d7:	d3 e8                	shr    %cl,%eax
  8010d9:	89 e9                	mov    %ebp,%ecx
  8010db:	89 fa                	mov    %edi,%edx
  8010dd:	d3 e6                	shl    %cl,%esi
  8010df:	09 d8                	or     %ebx,%eax
  8010e1:	f7 74 24 08          	divl   0x8(%esp)
  8010e5:	89 d1                	mov    %edx,%ecx
  8010e7:	89 f3                	mov    %esi,%ebx
  8010e9:	f7 64 24 0c          	mull   0xc(%esp)
  8010ed:	89 c6                	mov    %eax,%esi
  8010ef:	89 d7                	mov    %edx,%edi
  8010f1:	39 d1                	cmp    %edx,%ecx
  8010f3:	72 06                	jb     8010fb <__umoddi3+0x10b>
  8010f5:	75 10                	jne    801107 <__umoddi3+0x117>
  8010f7:	39 c3                	cmp    %eax,%ebx
  8010f9:	73 0c                	jae    801107 <__umoddi3+0x117>
  8010fb:	2b 44 24 0c          	sub    0xc(%esp),%eax
  8010ff:	1b 54 24 08          	sbb    0x8(%esp),%edx
  801103:	89 d7                	mov    %edx,%edi
  801105:	89 c6                	mov    %eax,%esi
  801107:	89 ca                	mov    %ecx,%edx
  801109:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80110e:	29 f3                	sub    %esi,%ebx
  801110:	19 fa                	sbb    %edi,%edx
  801112:	89 d0                	mov    %edx,%eax
  801114:	d3 e0                	shl    %cl,%eax
  801116:	89 e9                	mov    %ebp,%ecx
  801118:	d3 eb                	shr    %cl,%ebx
  80111a:	d3 ea                	shr    %cl,%edx
  80111c:	09 d8                	or     %ebx,%eax
  80111e:	83 c4 1c             	add    $0x1c,%esp
  801121:	5b                   	pop    %ebx
  801122:	5e                   	pop    %esi
  801123:	5f                   	pop    %edi
  801124:	5d                   	pop    %ebp
  801125:	c3                   	ret    
  801126:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80112d:	8d 76 00             	lea    0x0(%esi),%esi
  801130:	29 fe                	sub    %edi,%esi
  801132:	19 c3                	sbb    %eax,%ebx
  801134:	89 f2                	mov    %esi,%edx
  801136:	89 d9                	mov    %ebx,%ecx
  801138:	e9 1d ff ff ff       	jmp    80105a <__umoddi3+0x6a>
