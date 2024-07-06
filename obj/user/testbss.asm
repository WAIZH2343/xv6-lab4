
obj/user/testbss:     file format elf32-i386


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
  80002c:	e8 af 00 00 00       	call   8000e0 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

uint32_t bigarray[ARRAYSIZE];

void
umain(int argc, char **argv)
{
  800033:	f3 0f 1e fb          	endbr32 
  800037:	55                   	push   %ebp
  800038:	89 e5                	mov    %esp,%ebp
  80003a:	83 ec 14             	sub    $0x14,%esp
	int i;

	cprintf("Making sure bss works right...\n");
  80003d:	68 e0 10 80 00       	push   $0x8010e0
  800042:	e8 e0 01 00 00       	call   800227 <cprintf>
  800047:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < ARRAYSIZE; i++)
  80004a:	b8 00 00 00 00       	mov    $0x0,%eax
		if (bigarray[i] != 0)
  80004f:	83 3c 85 20 20 80 00 	cmpl   $0x0,0x802020(,%eax,4)
  800056:	00 
  800057:	75 63                	jne    8000bc <umain+0x89>
	for (i = 0; i < ARRAYSIZE; i++)
  800059:	83 c0 01             	add    $0x1,%eax
  80005c:	3d 00 00 10 00       	cmp    $0x100000,%eax
  800061:	75 ec                	jne    80004f <umain+0x1c>
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
  800063:	b8 00 00 00 00       	mov    $0x0,%eax
		bigarray[i] = i;
  800068:	89 04 85 20 20 80 00 	mov    %eax,0x802020(,%eax,4)
	for (i = 0; i < ARRAYSIZE; i++)
  80006f:	83 c0 01             	add    $0x1,%eax
  800072:	3d 00 00 10 00       	cmp    $0x100000,%eax
  800077:	75 ef                	jne    800068 <umain+0x35>
	for (i = 0; i < ARRAYSIZE; i++)
  800079:	b8 00 00 00 00       	mov    $0x0,%eax
		if (bigarray[i] != i)
  80007e:	39 04 85 20 20 80 00 	cmp    %eax,0x802020(,%eax,4)
  800085:	75 47                	jne    8000ce <umain+0x9b>
	for (i = 0; i < ARRAYSIZE; i++)
  800087:	83 c0 01             	add    $0x1,%eax
  80008a:	3d 00 00 10 00       	cmp    $0x100000,%eax
  80008f:	75 ed                	jne    80007e <umain+0x4b>
			panic("bigarray[%d] didn't hold its value!\n", i);

	cprintf("Yes, good.  Now doing a wild write off the end...\n");
  800091:	83 ec 0c             	sub    $0xc,%esp
  800094:	68 28 11 80 00       	push   $0x801128
  800099:	e8 89 01 00 00       	call   800227 <cprintf>
	bigarray[ARRAYSIZE+1024] = 0;
  80009e:	c7 05 20 30 c0 00 00 	movl   $0x0,0xc03020
  8000a5:	00 00 00 
	panic("SHOULD HAVE TRAPPED!!!");
  8000a8:	83 c4 0c             	add    $0xc,%esp
  8000ab:	68 87 11 80 00       	push   $0x801187
  8000b0:	6a 1a                	push   $0x1a
  8000b2:	68 78 11 80 00       	push   $0x801178
  8000b7:	e8 84 00 00 00       	call   800140 <_panic>
			panic("bigarray[%d] isn't cleared!\n", i);
  8000bc:	50                   	push   %eax
  8000bd:	68 5b 11 80 00       	push   $0x80115b
  8000c2:	6a 11                	push   $0x11
  8000c4:	68 78 11 80 00       	push   $0x801178
  8000c9:	e8 72 00 00 00       	call   800140 <_panic>
			panic("bigarray[%d] didn't hold its value!\n", i);
  8000ce:	50                   	push   %eax
  8000cf:	68 00 11 80 00       	push   $0x801100
  8000d4:	6a 16                	push   $0x16
  8000d6:	68 78 11 80 00       	push   $0x801178
  8000db:	e8 60 00 00 00       	call   800140 <_panic>

008000e0 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000e0:	f3 0f 1e fb          	endbr32 
  8000e4:	55                   	push   %ebp
  8000e5:	89 e5                	mov    %esp,%ebp
  8000e7:	56                   	push   %esi
  8000e8:	53                   	push   %ebx
  8000e9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000ec:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv=&envs[ENVX(sys_getenvid())];
  8000ef:	e8 78 0b 00 00       	call   800c6c <sys_getenvid>
  8000f4:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000f9:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000fc:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800101:	a3 20 20 c0 00       	mov    %eax,0xc02020

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800106:	85 db                	test   %ebx,%ebx
  800108:	7e 07                	jle    800111 <libmain+0x31>
		binaryname = argv[0];
  80010a:	8b 06                	mov    (%esi),%eax
  80010c:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800111:	83 ec 08             	sub    $0x8,%esp
  800114:	56                   	push   %esi
  800115:	53                   	push   %ebx
  800116:	e8 18 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80011b:	e8 0a 00 00 00       	call   80012a <exit>
}
  800120:	83 c4 10             	add    $0x10,%esp
  800123:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800126:	5b                   	pop    %ebx
  800127:	5e                   	pop    %esi
  800128:	5d                   	pop    %ebp
  800129:	c3                   	ret    

0080012a <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80012a:	f3 0f 1e fb          	endbr32 
  80012e:	55                   	push   %ebp
  80012f:	89 e5                	mov    %esp,%ebp
  800131:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800134:	6a 00                	push   $0x0
  800136:	e8 ec 0a 00 00       	call   800c27 <sys_env_destroy>
}
  80013b:	83 c4 10             	add    $0x10,%esp
  80013e:	c9                   	leave  
  80013f:	c3                   	ret    

00800140 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800140:	f3 0f 1e fb          	endbr32 
  800144:	55                   	push   %ebp
  800145:	89 e5                	mov    %esp,%ebp
  800147:	56                   	push   %esi
  800148:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800149:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80014c:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800152:	e8 15 0b 00 00       	call   800c6c <sys_getenvid>
  800157:	83 ec 0c             	sub    $0xc,%esp
  80015a:	ff 75 0c             	pushl  0xc(%ebp)
  80015d:	ff 75 08             	pushl  0x8(%ebp)
  800160:	56                   	push   %esi
  800161:	50                   	push   %eax
  800162:	68 a8 11 80 00       	push   $0x8011a8
  800167:	e8 bb 00 00 00       	call   800227 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80016c:	83 c4 18             	add    $0x18,%esp
  80016f:	53                   	push   %ebx
  800170:	ff 75 10             	pushl  0x10(%ebp)
  800173:	e8 5a 00 00 00       	call   8001d2 <vcprintf>
	cprintf("\n");
  800178:	c7 04 24 76 11 80 00 	movl   $0x801176,(%esp)
  80017f:	e8 a3 00 00 00       	call   800227 <cprintf>
  800184:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800187:	cc                   	int3   
  800188:	eb fd                	jmp    800187 <_panic+0x47>

0080018a <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80018a:	f3 0f 1e fb          	endbr32 
  80018e:	55                   	push   %ebp
  80018f:	89 e5                	mov    %esp,%ebp
  800191:	53                   	push   %ebx
  800192:	83 ec 04             	sub    $0x4,%esp
  800195:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800198:	8b 13                	mov    (%ebx),%edx
  80019a:	8d 42 01             	lea    0x1(%edx),%eax
  80019d:	89 03                	mov    %eax,(%ebx)
  80019f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001a2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001a6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001ab:	74 09                	je     8001b6 <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8001ad:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001b1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001b4:	c9                   	leave  
  8001b5:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8001b6:	83 ec 08             	sub    $0x8,%esp
  8001b9:	68 ff 00 00 00       	push   $0xff
  8001be:	8d 43 08             	lea    0x8(%ebx),%eax
  8001c1:	50                   	push   %eax
  8001c2:	e8 1b 0a 00 00       	call   800be2 <sys_cputs>
		b->idx = 0;
  8001c7:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001cd:	83 c4 10             	add    $0x10,%esp
  8001d0:	eb db                	jmp    8001ad <putch+0x23>

008001d2 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001d2:	f3 0f 1e fb          	endbr32 
  8001d6:	55                   	push   %ebp
  8001d7:	89 e5                	mov    %esp,%ebp
  8001d9:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001df:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001e6:	00 00 00 
	b.cnt = 0;
  8001e9:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001f0:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001f3:	ff 75 0c             	pushl  0xc(%ebp)
  8001f6:	ff 75 08             	pushl  0x8(%ebp)
  8001f9:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001ff:	50                   	push   %eax
  800200:	68 8a 01 80 00       	push   $0x80018a
  800205:	e8 20 01 00 00       	call   80032a <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80020a:	83 c4 08             	add    $0x8,%esp
  80020d:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800213:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800219:	50                   	push   %eax
  80021a:	e8 c3 09 00 00       	call   800be2 <sys_cputs>

	return b.cnt;
}
  80021f:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800225:	c9                   	leave  
  800226:	c3                   	ret    

00800227 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800227:	f3 0f 1e fb          	endbr32 
  80022b:	55                   	push   %ebp
  80022c:	89 e5                	mov    %esp,%ebp
  80022e:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800231:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800234:	50                   	push   %eax
  800235:	ff 75 08             	pushl  0x8(%ebp)
  800238:	e8 95 ff ff ff       	call   8001d2 <vcprintf>
	va_end(ap);

	return cnt;
}
  80023d:	c9                   	leave  
  80023e:	c3                   	ret    

0080023f <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80023f:	55                   	push   %ebp
  800240:	89 e5                	mov    %esp,%ebp
  800242:	57                   	push   %edi
  800243:	56                   	push   %esi
  800244:	53                   	push   %ebx
  800245:	83 ec 1c             	sub    $0x1c,%esp
  800248:	89 c7                	mov    %eax,%edi
  80024a:	89 d6                	mov    %edx,%esi
  80024c:	8b 45 08             	mov    0x8(%ebp),%eax
  80024f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800252:	89 d1                	mov    %edx,%ecx
  800254:	89 c2                	mov    %eax,%edx
  800256:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800259:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80025c:	8b 45 10             	mov    0x10(%ebp),%eax
  80025f:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800262:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800265:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80026c:	39 c2                	cmp    %eax,%edx
  80026e:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800271:	72 3e                	jb     8002b1 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800273:	83 ec 0c             	sub    $0xc,%esp
  800276:	ff 75 18             	pushl  0x18(%ebp)
  800279:	83 eb 01             	sub    $0x1,%ebx
  80027c:	53                   	push   %ebx
  80027d:	50                   	push   %eax
  80027e:	83 ec 08             	sub    $0x8,%esp
  800281:	ff 75 e4             	pushl  -0x1c(%ebp)
  800284:	ff 75 e0             	pushl  -0x20(%ebp)
  800287:	ff 75 dc             	pushl  -0x24(%ebp)
  80028a:	ff 75 d8             	pushl  -0x28(%ebp)
  80028d:	e8 ee 0b 00 00       	call   800e80 <__udivdi3>
  800292:	83 c4 18             	add    $0x18,%esp
  800295:	52                   	push   %edx
  800296:	50                   	push   %eax
  800297:	89 f2                	mov    %esi,%edx
  800299:	89 f8                	mov    %edi,%eax
  80029b:	e8 9f ff ff ff       	call   80023f <printnum>
  8002a0:	83 c4 20             	add    $0x20,%esp
  8002a3:	eb 13                	jmp    8002b8 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002a5:	83 ec 08             	sub    $0x8,%esp
  8002a8:	56                   	push   %esi
  8002a9:	ff 75 18             	pushl  0x18(%ebp)
  8002ac:	ff d7                	call   *%edi
  8002ae:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8002b1:	83 eb 01             	sub    $0x1,%ebx
  8002b4:	85 db                	test   %ebx,%ebx
  8002b6:	7f ed                	jg     8002a5 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002b8:	83 ec 08             	sub    $0x8,%esp
  8002bb:	56                   	push   %esi
  8002bc:	83 ec 04             	sub    $0x4,%esp
  8002bf:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002c2:	ff 75 e0             	pushl  -0x20(%ebp)
  8002c5:	ff 75 dc             	pushl  -0x24(%ebp)
  8002c8:	ff 75 d8             	pushl  -0x28(%ebp)
  8002cb:	e8 c0 0c 00 00       	call   800f90 <__umoddi3>
  8002d0:	83 c4 14             	add    $0x14,%esp
  8002d3:	0f be 80 cb 11 80 00 	movsbl 0x8011cb(%eax),%eax
  8002da:	50                   	push   %eax
  8002db:	ff d7                	call   *%edi
}
  8002dd:	83 c4 10             	add    $0x10,%esp
  8002e0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002e3:	5b                   	pop    %ebx
  8002e4:	5e                   	pop    %esi
  8002e5:	5f                   	pop    %edi
  8002e6:	5d                   	pop    %ebp
  8002e7:	c3                   	ret    

008002e8 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002e8:	f3 0f 1e fb          	endbr32 
  8002ec:	55                   	push   %ebp
  8002ed:	89 e5                	mov    %esp,%ebp
  8002ef:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002f2:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002f6:	8b 10                	mov    (%eax),%edx
  8002f8:	3b 50 04             	cmp    0x4(%eax),%edx
  8002fb:	73 0a                	jae    800307 <sprintputch+0x1f>
		*b->buf++ = ch;
  8002fd:	8d 4a 01             	lea    0x1(%edx),%ecx
  800300:	89 08                	mov    %ecx,(%eax)
  800302:	8b 45 08             	mov    0x8(%ebp),%eax
  800305:	88 02                	mov    %al,(%edx)
}
  800307:	5d                   	pop    %ebp
  800308:	c3                   	ret    

00800309 <printfmt>:
{
  800309:	f3 0f 1e fb          	endbr32 
  80030d:	55                   	push   %ebp
  80030e:	89 e5                	mov    %esp,%ebp
  800310:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800313:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800316:	50                   	push   %eax
  800317:	ff 75 10             	pushl  0x10(%ebp)
  80031a:	ff 75 0c             	pushl  0xc(%ebp)
  80031d:	ff 75 08             	pushl  0x8(%ebp)
  800320:	e8 05 00 00 00       	call   80032a <vprintfmt>
}
  800325:	83 c4 10             	add    $0x10,%esp
  800328:	c9                   	leave  
  800329:	c3                   	ret    

0080032a <vprintfmt>:
{
  80032a:	f3 0f 1e fb          	endbr32 
  80032e:	55                   	push   %ebp
  80032f:	89 e5                	mov    %esp,%ebp
  800331:	57                   	push   %edi
  800332:	56                   	push   %esi
  800333:	53                   	push   %ebx
  800334:	83 ec 3c             	sub    $0x3c,%esp
  800337:	8b 75 08             	mov    0x8(%ebp),%esi
  80033a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80033d:	8b 7d 10             	mov    0x10(%ebp),%edi
  800340:	e9 cd 03 00 00       	jmp    800712 <vprintfmt+0x3e8>
		padc = ' ';
  800345:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800349:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800350:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800357:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80035e:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800363:	8d 47 01             	lea    0x1(%edi),%eax
  800366:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800369:	0f b6 17             	movzbl (%edi),%edx
  80036c:	8d 42 dd             	lea    -0x23(%edx),%eax
  80036f:	3c 55                	cmp    $0x55,%al
  800371:	0f 87 1e 04 00 00    	ja     800795 <vprintfmt+0x46b>
  800377:	0f b6 c0             	movzbl %al,%eax
  80037a:	3e ff 24 85 a0 12 80 	notrack jmp *0x8012a0(,%eax,4)
  800381:	00 
  800382:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800385:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800389:	eb d8                	jmp    800363 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  80038b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80038e:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  800392:	eb cf                	jmp    800363 <vprintfmt+0x39>
  800394:	0f b6 d2             	movzbl %dl,%edx
  800397:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  80039a:	b8 00 00 00 00       	mov    $0x0,%eax
  80039f:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8003a2:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003a5:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8003a9:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8003ac:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8003af:	83 f9 09             	cmp    $0x9,%ecx
  8003b2:	77 55                	ja     800409 <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  8003b4:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8003b7:	eb e9                	jmp    8003a2 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  8003b9:	8b 45 14             	mov    0x14(%ebp),%eax
  8003bc:	8b 00                	mov    (%eax),%eax
  8003be:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c4:	8d 40 04             	lea    0x4(%eax),%eax
  8003c7:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003ca:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8003cd:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003d1:	79 90                	jns    800363 <vprintfmt+0x39>
				width = precision, precision = -1;
  8003d3:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8003d6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003d9:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8003e0:	eb 81                	jmp    800363 <vprintfmt+0x39>
  8003e2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003e5:	85 c0                	test   %eax,%eax
  8003e7:	ba 00 00 00 00       	mov    $0x0,%edx
  8003ec:	0f 49 d0             	cmovns %eax,%edx
  8003ef:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003f2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003f5:	e9 69 ff ff ff       	jmp    800363 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8003fa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8003fd:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  800404:	e9 5a ff ff ff       	jmp    800363 <vprintfmt+0x39>
  800409:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80040c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80040f:	eb bc                	jmp    8003cd <vprintfmt+0xa3>
			lflag++;
  800411:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800414:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800417:	e9 47 ff ff ff       	jmp    800363 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  80041c:	8b 45 14             	mov    0x14(%ebp),%eax
  80041f:	8d 78 04             	lea    0x4(%eax),%edi
  800422:	83 ec 08             	sub    $0x8,%esp
  800425:	53                   	push   %ebx
  800426:	ff 30                	pushl  (%eax)
  800428:	ff d6                	call   *%esi
			break;
  80042a:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  80042d:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800430:	e9 da 02 00 00       	jmp    80070f <vprintfmt+0x3e5>
			err = va_arg(ap, int);
  800435:	8b 45 14             	mov    0x14(%ebp),%eax
  800438:	8d 78 04             	lea    0x4(%eax),%edi
  80043b:	8b 00                	mov    (%eax),%eax
  80043d:	99                   	cltd   
  80043e:	31 d0                	xor    %edx,%eax
  800440:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800442:	83 f8 08             	cmp    $0x8,%eax
  800445:	7f 23                	jg     80046a <vprintfmt+0x140>
  800447:	8b 14 85 00 14 80 00 	mov    0x801400(,%eax,4),%edx
  80044e:	85 d2                	test   %edx,%edx
  800450:	74 18                	je     80046a <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  800452:	52                   	push   %edx
  800453:	68 ec 11 80 00       	push   $0x8011ec
  800458:	53                   	push   %ebx
  800459:	56                   	push   %esi
  80045a:	e8 aa fe ff ff       	call   800309 <printfmt>
  80045f:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800462:	89 7d 14             	mov    %edi,0x14(%ebp)
  800465:	e9 a5 02 00 00       	jmp    80070f <vprintfmt+0x3e5>
				printfmt(putch, putdat, "error %d", err);
  80046a:	50                   	push   %eax
  80046b:	68 e3 11 80 00       	push   $0x8011e3
  800470:	53                   	push   %ebx
  800471:	56                   	push   %esi
  800472:	e8 92 fe ff ff       	call   800309 <printfmt>
  800477:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80047a:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80047d:	e9 8d 02 00 00       	jmp    80070f <vprintfmt+0x3e5>
			if ((p = va_arg(ap, char *)) == NULL)
  800482:	8b 45 14             	mov    0x14(%ebp),%eax
  800485:	83 c0 04             	add    $0x4,%eax
  800488:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80048b:	8b 45 14             	mov    0x14(%ebp),%eax
  80048e:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  800490:	85 d2                	test   %edx,%edx
  800492:	b8 dc 11 80 00       	mov    $0x8011dc,%eax
  800497:	0f 45 c2             	cmovne %edx,%eax
  80049a:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  80049d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004a1:	7e 06                	jle    8004a9 <vprintfmt+0x17f>
  8004a3:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  8004a7:	75 0d                	jne    8004b6 <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004a9:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8004ac:	89 c7                	mov    %eax,%edi
  8004ae:	03 45 e0             	add    -0x20(%ebp),%eax
  8004b1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004b4:	eb 55                	jmp    80050b <vprintfmt+0x1e1>
  8004b6:	83 ec 08             	sub    $0x8,%esp
  8004b9:	ff 75 d8             	pushl  -0x28(%ebp)
  8004bc:	ff 75 cc             	pushl  -0x34(%ebp)
  8004bf:	e8 85 03 00 00       	call   800849 <strnlen>
  8004c4:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8004c7:	29 c2                	sub    %eax,%edx
  8004c9:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  8004cc:	83 c4 10             	add    $0x10,%esp
  8004cf:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  8004d1:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8004d5:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8004d8:	85 ff                	test   %edi,%edi
  8004da:	7e 11                	jle    8004ed <vprintfmt+0x1c3>
					putch(padc, putdat);
  8004dc:	83 ec 08             	sub    $0x8,%esp
  8004df:	53                   	push   %ebx
  8004e0:	ff 75 e0             	pushl  -0x20(%ebp)
  8004e3:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8004e5:	83 ef 01             	sub    $0x1,%edi
  8004e8:	83 c4 10             	add    $0x10,%esp
  8004eb:	eb eb                	jmp    8004d8 <vprintfmt+0x1ae>
  8004ed:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8004f0:	85 d2                	test   %edx,%edx
  8004f2:	b8 00 00 00 00       	mov    $0x0,%eax
  8004f7:	0f 49 c2             	cmovns %edx,%eax
  8004fa:	29 c2                	sub    %eax,%edx
  8004fc:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8004ff:	eb a8                	jmp    8004a9 <vprintfmt+0x17f>
					putch(ch, putdat);
  800501:	83 ec 08             	sub    $0x8,%esp
  800504:	53                   	push   %ebx
  800505:	52                   	push   %edx
  800506:	ff d6                	call   *%esi
  800508:	83 c4 10             	add    $0x10,%esp
  80050b:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80050e:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800510:	83 c7 01             	add    $0x1,%edi
  800513:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800517:	0f be d0             	movsbl %al,%edx
  80051a:	85 d2                	test   %edx,%edx
  80051c:	74 4b                	je     800569 <vprintfmt+0x23f>
  80051e:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800522:	78 06                	js     80052a <vprintfmt+0x200>
  800524:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800528:	78 1e                	js     800548 <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
  80052a:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80052e:	74 d1                	je     800501 <vprintfmt+0x1d7>
  800530:	0f be c0             	movsbl %al,%eax
  800533:	83 e8 20             	sub    $0x20,%eax
  800536:	83 f8 5e             	cmp    $0x5e,%eax
  800539:	76 c6                	jbe    800501 <vprintfmt+0x1d7>
					putch('?', putdat);
  80053b:	83 ec 08             	sub    $0x8,%esp
  80053e:	53                   	push   %ebx
  80053f:	6a 3f                	push   $0x3f
  800541:	ff d6                	call   *%esi
  800543:	83 c4 10             	add    $0x10,%esp
  800546:	eb c3                	jmp    80050b <vprintfmt+0x1e1>
  800548:	89 cf                	mov    %ecx,%edi
  80054a:	eb 0e                	jmp    80055a <vprintfmt+0x230>
				putch(' ', putdat);
  80054c:	83 ec 08             	sub    $0x8,%esp
  80054f:	53                   	push   %ebx
  800550:	6a 20                	push   $0x20
  800552:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800554:	83 ef 01             	sub    $0x1,%edi
  800557:	83 c4 10             	add    $0x10,%esp
  80055a:	85 ff                	test   %edi,%edi
  80055c:	7f ee                	jg     80054c <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  80055e:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800561:	89 45 14             	mov    %eax,0x14(%ebp)
  800564:	e9 a6 01 00 00       	jmp    80070f <vprintfmt+0x3e5>
  800569:	89 cf                	mov    %ecx,%edi
  80056b:	eb ed                	jmp    80055a <vprintfmt+0x230>
	if (lflag >= 2)
  80056d:	83 f9 01             	cmp    $0x1,%ecx
  800570:	7f 1f                	jg     800591 <vprintfmt+0x267>
	else if (lflag)
  800572:	85 c9                	test   %ecx,%ecx
  800574:	74 67                	je     8005dd <vprintfmt+0x2b3>
		return va_arg(*ap, long);
  800576:	8b 45 14             	mov    0x14(%ebp),%eax
  800579:	8b 00                	mov    (%eax),%eax
  80057b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80057e:	89 c1                	mov    %eax,%ecx
  800580:	c1 f9 1f             	sar    $0x1f,%ecx
  800583:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800586:	8b 45 14             	mov    0x14(%ebp),%eax
  800589:	8d 40 04             	lea    0x4(%eax),%eax
  80058c:	89 45 14             	mov    %eax,0x14(%ebp)
  80058f:	eb 17                	jmp    8005a8 <vprintfmt+0x27e>
		return va_arg(*ap, long long);
  800591:	8b 45 14             	mov    0x14(%ebp),%eax
  800594:	8b 50 04             	mov    0x4(%eax),%edx
  800597:	8b 00                	mov    (%eax),%eax
  800599:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80059c:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80059f:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a2:	8d 40 08             	lea    0x8(%eax),%eax
  8005a5:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8005a8:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005ab:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8005ae:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  8005b3:	85 c9                	test   %ecx,%ecx
  8005b5:	0f 89 3a 01 00 00    	jns    8006f5 <vprintfmt+0x3cb>
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
			base = 10;
  8005d3:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005d8:	e9 18 01 00 00       	jmp    8006f5 <vprintfmt+0x3cb>
		return va_arg(*ap, int);
  8005dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e0:	8b 00                	mov    (%eax),%eax
  8005e2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005e5:	89 c1                	mov    %eax,%ecx
  8005e7:	c1 f9 1f             	sar    $0x1f,%ecx
  8005ea:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005ed:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f0:	8d 40 04             	lea    0x4(%eax),%eax
  8005f3:	89 45 14             	mov    %eax,0x14(%ebp)
  8005f6:	eb b0                	jmp    8005a8 <vprintfmt+0x27e>
	if (lflag >= 2)
  8005f8:	83 f9 01             	cmp    $0x1,%ecx
  8005fb:	7f 1e                	jg     80061b <vprintfmt+0x2f1>
	else if (lflag)
  8005fd:	85 c9                	test   %ecx,%ecx
  8005ff:	74 32                	je     800633 <vprintfmt+0x309>
		return va_arg(*ap, unsigned long);
  800601:	8b 45 14             	mov    0x14(%ebp),%eax
  800604:	8b 10                	mov    (%eax),%edx
  800606:	b9 00 00 00 00       	mov    $0x0,%ecx
  80060b:	8d 40 04             	lea    0x4(%eax),%eax
  80060e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800611:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  800616:	e9 da 00 00 00       	jmp    8006f5 <vprintfmt+0x3cb>
		return va_arg(*ap, unsigned long long);
  80061b:	8b 45 14             	mov    0x14(%ebp),%eax
  80061e:	8b 10                	mov    (%eax),%edx
  800620:	8b 48 04             	mov    0x4(%eax),%ecx
  800623:	8d 40 08             	lea    0x8(%eax),%eax
  800626:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800629:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  80062e:	e9 c2 00 00 00       	jmp    8006f5 <vprintfmt+0x3cb>
		return va_arg(*ap, unsigned int);
  800633:	8b 45 14             	mov    0x14(%ebp),%eax
  800636:	8b 10                	mov    (%eax),%edx
  800638:	b9 00 00 00 00       	mov    $0x0,%ecx
  80063d:	8d 40 04             	lea    0x4(%eax),%eax
  800640:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800643:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  800648:	e9 a8 00 00 00       	jmp    8006f5 <vprintfmt+0x3cb>
	if (lflag >= 2)
  80064d:	83 f9 01             	cmp    $0x1,%ecx
  800650:	7f 1b                	jg     80066d <vprintfmt+0x343>
	else if (lflag)
  800652:	85 c9                	test   %ecx,%ecx
  800654:	74 5c                	je     8006b2 <vprintfmt+0x388>
		return va_arg(*ap, long);
  800656:	8b 45 14             	mov    0x14(%ebp),%eax
  800659:	8b 00                	mov    (%eax),%eax
  80065b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80065e:	99                   	cltd   
  80065f:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800662:	8b 45 14             	mov    0x14(%ebp),%eax
  800665:	8d 40 04             	lea    0x4(%eax),%eax
  800668:	89 45 14             	mov    %eax,0x14(%ebp)
  80066b:	eb 17                	jmp    800684 <vprintfmt+0x35a>
		return va_arg(*ap, long long);
  80066d:	8b 45 14             	mov    0x14(%ebp),%eax
  800670:	8b 50 04             	mov    0x4(%eax),%edx
  800673:	8b 00                	mov    (%eax),%eax
  800675:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800678:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80067b:	8b 45 14             	mov    0x14(%ebp),%eax
  80067e:	8d 40 08             	lea    0x8(%eax),%eax
  800681:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800684:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800687:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 8;
  80068a:	b8 08 00 00 00       	mov    $0x8,%eax
			if ((long long) num < 0) {
  80068f:	85 c9                	test   %ecx,%ecx
  800691:	79 62                	jns    8006f5 <vprintfmt+0x3cb>
				putch('-', putdat);
  800693:	83 ec 08             	sub    $0x8,%esp
  800696:	53                   	push   %ebx
  800697:	6a 2d                	push   $0x2d
  800699:	ff d6                	call   *%esi
				num = -(long long) num;
  80069b:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80069e:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8006a1:	f7 da                	neg    %edx
  8006a3:	83 d1 00             	adc    $0x0,%ecx
  8006a6:	f7 d9                	neg    %ecx
  8006a8:	83 c4 10             	add    $0x10,%esp
			base = 8;
  8006ab:	b8 08 00 00 00       	mov    $0x8,%eax
  8006b0:	eb 43                	jmp    8006f5 <vprintfmt+0x3cb>
		return va_arg(*ap, int);
  8006b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b5:	8b 00                	mov    (%eax),%eax
  8006b7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006ba:	89 c1                	mov    %eax,%ecx
  8006bc:	c1 f9 1f             	sar    $0x1f,%ecx
  8006bf:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c5:	8d 40 04             	lea    0x4(%eax),%eax
  8006c8:	89 45 14             	mov    %eax,0x14(%ebp)
  8006cb:	eb b7                	jmp    800684 <vprintfmt+0x35a>
			putch('0', putdat);
  8006cd:	83 ec 08             	sub    $0x8,%esp
  8006d0:	53                   	push   %ebx
  8006d1:	6a 30                	push   $0x30
  8006d3:	ff d6                	call   *%esi
			putch('x', putdat);
  8006d5:	83 c4 08             	add    $0x8,%esp
  8006d8:	53                   	push   %ebx
  8006d9:	6a 78                	push   $0x78
  8006db:	ff d6                	call   *%esi
			num = (unsigned long long)
  8006dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e0:	8b 10                	mov    (%eax),%edx
  8006e2:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8006e7:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8006ea:	8d 40 04             	lea    0x4(%eax),%eax
  8006ed:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006f0:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  8006f5:	83 ec 0c             	sub    $0xc,%esp
  8006f8:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  8006fc:	57                   	push   %edi
  8006fd:	ff 75 e0             	pushl  -0x20(%ebp)
  800700:	50                   	push   %eax
  800701:	51                   	push   %ecx
  800702:	52                   	push   %edx
  800703:	89 da                	mov    %ebx,%edx
  800705:	89 f0                	mov    %esi,%eax
  800707:	e8 33 fb ff ff       	call   80023f <printnum>
			break;
  80070c:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  80070f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800712:	83 c7 01             	add    $0x1,%edi
  800715:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800719:	83 f8 25             	cmp    $0x25,%eax
  80071c:	0f 84 23 fc ff ff    	je     800345 <vprintfmt+0x1b>
			if (ch == '\0')
  800722:	85 c0                	test   %eax,%eax
  800724:	0f 84 8b 00 00 00    	je     8007b5 <vprintfmt+0x48b>
			putch(ch, putdat);
  80072a:	83 ec 08             	sub    $0x8,%esp
  80072d:	53                   	push   %ebx
  80072e:	50                   	push   %eax
  80072f:	ff d6                	call   *%esi
  800731:	83 c4 10             	add    $0x10,%esp
  800734:	eb dc                	jmp    800712 <vprintfmt+0x3e8>
	if (lflag >= 2)
  800736:	83 f9 01             	cmp    $0x1,%ecx
  800739:	7f 1b                	jg     800756 <vprintfmt+0x42c>
	else if (lflag)
  80073b:	85 c9                	test   %ecx,%ecx
  80073d:	74 2c                	je     80076b <vprintfmt+0x441>
		return va_arg(*ap, unsigned long);
  80073f:	8b 45 14             	mov    0x14(%ebp),%eax
  800742:	8b 10                	mov    (%eax),%edx
  800744:	b9 00 00 00 00       	mov    $0x0,%ecx
  800749:	8d 40 04             	lea    0x4(%eax),%eax
  80074c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80074f:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  800754:	eb 9f                	jmp    8006f5 <vprintfmt+0x3cb>
		return va_arg(*ap, unsigned long long);
  800756:	8b 45 14             	mov    0x14(%ebp),%eax
  800759:	8b 10                	mov    (%eax),%edx
  80075b:	8b 48 04             	mov    0x4(%eax),%ecx
  80075e:	8d 40 08             	lea    0x8(%eax),%eax
  800761:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800764:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  800769:	eb 8a                	jmp    8006f5 <vprintfmt+0x3cb>
		return va_arg(*ap, unsigned int);
  80076b:	8b 45 14             	mov    0x14(%ebp),%eax
  80076e:	8b 10                	mov    (%eax),%edx
  800770:	b9 00 00 00 00       	mov    $0x0,%ecx
  800775:	8d 40 04             	lea    0x4(%eax),%eax
  800778:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80077b:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  800780:	e9 70 ff ff ff       	jmp    8006f5 <vprintfmt+0x3cb>
			putch(ch, putdat);
  800785:	83 ec 08             	sub    $0x8,%esp
  800788:	53                   	push   %ebx
  800789:	6a 25                	push   $0x25
  80078b:	ff d6                	call   *%esi
			break;
  80078d:	83 c4 10             	add    $0x10,%esp
  800790:	e9 7a ff ff ff       	jmp    80070f <vprintfmt+0x3e5>
			putch('%', putdat);
  800795:	83 ec 08             	sub    $0x8,%esp
  800798:	53                   	push   %ebx
  800799:	6a 25                	push   $0x25
  80079b:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80079d:	83 c4 10             	add    $0x10,%esp
  8007a0:	89 f8                	mov    %edi,%eax
  8007a2:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8007a6:	74 05                	je     8007ad <vprintfmt+0x483>
  8007a8:	83 e8 01             	sub    $0x1,%eax
  8007ab:	eb f5                	jmp    8007a2 <vprintfmt+0x478>
  8007ad:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8007b0:	e9 5a ff ff ff       	jmp    80070f <vprintfmt+0x3e5>
}
  8007b5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007b8:	5b                   	pop    %ebx
  8007b9:	5e                   	pop    %esi
  8007ba:	5f                   	pop    %edi
  8007bb:	5d                   	pop    %ebp
  8007bc:	c3                   	ret    

008007bd <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007bd:	f3 0f 1e fb          	endbr32 
  8007c1:	55                   	push   %ebp
  8007c2:	89 e5                	mov    %esp,%ebp
  8007c4:	83 ec 18             	sub    $0x18,%esp
  8007c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ca:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007cd:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007d0:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007d4:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007d7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007de:	85 c0                	test   %eax,%eax
  8007e0:	74 26                	je     800808 <vsnprintf+0x4b>
  8007e2:	85 d2                	test   %edx,%edx
  8007e4:	7e 22                	jle    800808 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007e6:	ff 75 14             	pushl  0x14(%ebp)
  8007e9:	ff 75 10             	pushl  0x10(%ebp)
  8007ec:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007ef:	50                   	push   %eax
  8007f0:	68 e8 02 80 00       	push   $0x8002e8
  8007f5:	e8 30 fb ff ff       	call   80032a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007fa:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007fd:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800800:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800803:	83 c4 10             	add    $0x10,%esp
}
  800806:	c9                   	leave  
  800807:	c3                   	ret    
		return -E_INVAL;
  800808:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80080d:	eb f7                	jmp    800806 <vsnprintf+0x49>

0080080f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80080f:	f3 0f 1e fb          	endbr32 
  800813:	55                   	push   %ebp
  800814:	89 e5                	mov    %esp,%ebp
  800816:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800819:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80081c:	50                   	push   %eax
  80081d:	ff 75 10             	pushl  0x10(%ebp)
  800820:	ff 75 0c             	pushl  0xc(%ebp)
  800823:	ff 75 08             	pushl  0x8(%ebp)
  800826:	e8 92 ff ff ff       	call   8007bd <vsnprintf>
	va_end(ap);

	return rc;
}
  80082b:	c9                   	leave  
  80082c:	c3                   	ret    

0080082d <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80082d:	f3 0f 1e fb          	endbr32 
  800831:	55                   	push   %ebp
  800832:	89 e5                	mov    %esp,%ebp
  800834:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800837:	b8 00 00 00 00       	mov    $0x0,%eax
  80083c:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800840:	74 05                	je     800847 <strlen+0x1a>
		n++;
  800842:	83 c0 01             	add    $0x1,%eax
  800845:	eb f5                	jmp    80083c <strlen+0xf>
	return n;
}
  800847:	5d                   	pop    %ebp
  800848:	c3                   	ret    

00800849 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800849:	f3 0f 1e fb          	endbr32 
  80084d:	55                   	push   %ebp
  80084e:	89 e5                	mov    %esp,%ebp
  800850:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800853:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800856:	b8 00 00 00 00       	mov    $0x0,%eax
  80085b:	39 d0                	cmp    %edx,%eax
  80085d:	74 0d                	je     80086c <strnlen+0x23>
  80085f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800863:	74 05                	je     80086a <strnlen+0x21>
		n++;
  800865:	83 c0 01             	add    $0x1,%eax
  800868:	eb f1                	jmp    80085b <strnlen+0x12>
  80086a:	89 c2                	mov    %eax,%edx
	return n;
}
  80086c:	89 d0                	mov    %edx,%eax
  80086e:	5d                   	pop    %ebp
  80086f:	c3                   	ret    

00800870 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800870:	f3 0f 1e fb          	endbr32 
  800874:	55                   	push   %ebp
  800875:	89 e5                	mov    %esp,%ebp
  800877:	53                   	push   %ebx
  800878:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80087b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80087e:	b8 00 00 00 00       	mov    $0x0,%eax
  800883:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800887:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  80088a:	83 c0 01             	add    $0x1,%eax
  80088d:	84 d2                	test   %dl,%dl
  80088f:	75 f2                	jne    800883 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  800891:	89 c8                	mov    %ecx,%eax
  800893:	5b                   	pop    %ebx
  800894:	5d                   	pop    %ebp
  800895:	c3                   	ret    

00800896 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800896:	f3 0f 1e fb          	endbr32 
  80089a:	55                   	push   %ebp
  80089b:	89 e5                	mov    %esp,%ebp
  80089d:	53                   	push   %ebx
  80089e:	83 ec 10             	sub    $0x10,%esp
  8008a1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008a4:	53                   	push   %ebx
  8008a5:	e8 83 ff ff ff       	call   80082d <strlen>
  8008aa:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8008ad:	ff 75 0c             	pushl  0xc(%ebp)
  8008b0:	01 d8                	add    %ebx,%eax
  8008b2:	50                   	push   %eax
  8008b3:	e8 b8 ff ff ff       	call   800870 <strcpy>
	return dst;
}
  8008b8:	89 d8                	mov    %ebx,%eax
  8008ba:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008bd:	c9                   	leave  
  8008be:	c3                   	ret    

008008bf <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008bf:	f3 0f 1e fb          	endbr32 
  8008c3:	55                   	push   %ebp
  8008c4:	89 e5                	mov    %esp,%ebp
  8008c6:	56                   	push   %esi
  8008c7:	53                   	push   %ebx
  8008c8:	8b 75 08             	mov    0x8(%ebp),%esi
  8008cb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008ce:	89 f3                	mov    %esi,%ebx
  8008d0:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008d3:	89 f0                	mov    %esi,%eax
  8008d5:	39 d8                	cmp    %ebx,%eax
  8008d7:	74 11                	je     8008ea <strncpy+0x2b>
		*dst++ = *src;
  8008d9:	83 c0 01             	add    $0x1,%eax
  8008dc:	0f b6 0a             	movzbl (%edx),%ecx
  8008df:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008e2:	80 f9 01             	cmp    $0x1,%cl
  8008e5:	83 da ff             	sbb    $0xffffffff,%edx
  8008e8:	eb eb                	jmp    8008d5 <strncpy+0x16>
	}
	return ret;
}
  8008ea:	89 f0                	mov    %esi,%eax
  8008ec:	5b                   	pop    %ebx
  8008ed:	5e                   	pop    %esi
  8008ee:	5d                   	pop    %ebp
  8008ef:	c3                   	ret    

008008f0 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008f0:	f3 0f 1e fb          	endbr32 
  8008f4:	55                   	push   %ebp
  8008f5:	89 e5                	mov    %esp,%ebp
  8008f7:	56                   	push   %esi
  8008f8:	53                   	push   %ebx
  8008f9:	8b 75 08             	mov    0x8(%ebp),%esi
  8008fc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008ff:	8b 55 10             	mov    0x10(%ebp),%edx
  800902:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800904:	85 d2                	test   %edx,%edx
  800906:	74 21                	je     800929 <strlcpy+0x39>
  800908:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80090c:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  80090e:	39 c2                	cmp    %eax,%edx
  800910:	74 14                	je     800926 <strlcpy+0x36>
  800912:	0f b6 19             	movzbl (%ecx),%ebx
  800915:	84 db                	test   %bl,%bl
  800917:	74 0b                	je     800924 <strlcpy+0x34>
			*dst++ = *src++;
  800919:	83 c1 01             	add    $0x1,%ecx
  80091c:	83 c2 01             	add    $0x1,%edx
  80091f:	88 5a ff             	mov    %bl,-0x1(%edx)
  800922:	eb ea                	jmp    80090e <strlcpy+0x1e>
  800924:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800926:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800929:	29 f0                	sub    %esi,%eax
}
  80092b:	5b                   	pop    %ebx
  80092c:	5e                   	pop    %esi
  80092d:	5d                   	pop    %ebp
  80092e:	c3                   	ret    

0080092f <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80092f:	f3 0f 1e fb          	endbr32 
  800933:	55                   	push   %ebp
  800934:	89 e5                	mov    %esp,%ebp
  800936:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800939:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80093c:	0f b6 01             	movzbl (%ecx),%eax
  80093f:	84 c0                	test   %al,%al
  800941:	74 0c                	je     80094f <strcmp+0x20>
  800943:	3a 02                	cmp    (%edx),%al
  800945:	75 08                	jne    80094f <strcmp+0x20>
		p++, q++;
  800947:	83 c1 01             	add    $0x1,%ecx
  80094a:	83 c2 01             	add    $0x1,%edx
  80094d:	eb ed                	jmp    80093c <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80094f:	0f b6 c0             	movzbl %al,%eax
  800952:	0f b6 12             	movzbl (%edx),%edx
  800955:	29 d0                	sub    %edx,%eax
}
  800957:	5d                   	pop    %ebp
  800958:	c3                   	ret    

00800959 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800959:	f3 0f 1e fb          	endbr32 
  80095d:	55                   	push   %ebp
  80095e:	89 e5                	mov    %esp,%ebp
  800960:	53                   	push   %ebx
  800961:	8b 45 08             	mov    0x8(%ebp),%eax
  800964:	8b 55 0c             	mov    0xc(%ebp),%edx
  800967:	89 c3                	mov    %eax,%ebx
  800969:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80096c:	eb 06                	jmp    800974 <strncmp+0x1b>
		n--, p++, q++;
  80096e:	83 c0 01             	add    $0x1,%eax
  800971:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800974:	39 d8                	cmp    %ebx,%eax
  800976:	74 16                	je     80098e <strncmp+0x35>
  800978:	0f b6 08             	movzbl (%eax),%ecx
  80097b:	84 c9                	test   %cl,%cl
  80097d:	74 04                	je     800983 <strncmp+0x2a>
  80097f:	3a 0a                	cmp    (%edx),%cl
  800981:	74 eb                	je     80096e <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800983:	0f b6 00             	movzbl (%eax),%eax
  800986:	0f b6 12             	movzbl (%edx),%edx
  800989:	29 d0                	sub    %edx,%eax
}
  80098b:	5b                   	pop    %ebx
  80098c:	5d                   	pop    %ebp
  80098d:	c3                   	ret    
		return 0;
  80098e:	b8 00 00 00 00       	mov    $0x0,%eax
  800993:	eb f6                	jmp    80098b <strncmp+0x32>

00800995 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800995:	f3 0f 1e fb          	endbr32 
  800999:	55                   	push   %ebp
  80099a:	89 e5                	mov    %esp,%ebp
  80099c:	8b 45 08             	mov    0x8(%ebp),%eax
  80099f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009a3:	0f b6 10             	movzbl (%eax),%edx
  8009a6:	84 d2                	test   %dl,%dl
  8009a8:	74 09                	je     8009b3 <strchr+0x1e>
		if (*s == c)
  8009aa:	38 ca                	cmp    %cl,%dl
  8009ac:	74 0a                	je     8009b8 <strchr+0x23>
	for (; *s; s++)
  8009ae:	83 c0 01             	add    $0x1,%eax
  8009b1:	eb f0                	jmp    8009a3 <strchr+0xe>
			return (char *) s;
	return 0;
  8009b3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009b8:	5d                   	pop    %ebp
  8009b9:	c3                   	ret    

008009ba <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009ba:	f3 0f 1e fb          	endbr32 
  8009be:	55                   	push   %ebp
  8009bf:	89 e5                	mov    %esp,%ebp
  8009c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009c8:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8009cb:	38 ca                	cmp    %cl,%dl
  8009cd:	74 09                	je     8009d8 <strfind+0x1e>
  8009cf:	84 d2                	test   %dl,%dl
  8009d1:	74 05                	je     8009d8 <strfind+0x1e>
	for (; *s; s++)
  8009d3:	83 c0 01             	add    $0x1,%eax
  8009d6:	eb f0                	jmp    8009c8 <strfind+0xe>
			break;
	return (char *) s;
}
  8009d8:	5d                   	pop    %ebp
  8009d9:	c3                   	ret    

008009da <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009da:	f3 0f 1e fb          	endbr32 
  8009de:	55                   	push   %ebp
  8009df:	89 e5                	mov    %esp,%ebp
  8009e1:	57                   	push   %edi
  8009e2:	56                   	push   %esi
  8009e3:	53                   	push   %ebx
  8009e4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009e7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009ea:	85 c9                	test   %ecx,%ecx
  8009ec:	74 31                	je     800a1f <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009ee:	89 f8                	mov    %edi,%eax
  8009f0:	09 c8                	or     %ecx,%eax
  8009f2:	a8 03                	test   $0x3,%al
  8009f4:	75 23                	jne    800a19 <memset+0x3f>
		c &= 0xFF;
  8009f6:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009fa:	89 d3                	mov    %edx,%ebx
  8009fc:	c1 e3 08             	shl    $0x8,%ebx
  8009ff:	89 d0                	mov    %edx,%eax
  800a01:	c1 e0 18             	shl    $0x18,%eax
  800a04:	89 d6                	mov    %edx,%esi
  800a06:	c1 e6 10             	shl    $0x10,%esi
  800a09:	09 f0                	or     %esi,%eax
  800a0b:	09 c2                	or     %eax,%edx
  800a0d:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a0f:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800a12:	89 d0                	mov    %edx,%eax
  800a14:	fc                   	cld    
  800a15:	f3 ab                	rep stos %eax,%es:(%edi)
  800a17:	eb 06                	jmp    800a1f <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a19:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a1c:	fc                   	cld    
  800a1d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a1f:	89 f8                	mov    %edi,%eax
  800a21:	5b                   	pop    %ebx
  800a22:	5e                   	pop    %esi
  800a23:	5f                   	pop    %edi
  800a24:	5d                   	pop    %ebp
  800a25:	c3                   	ret    

00800a26 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a26:	f3 0f 1e fb          	endbr32 
  800a2a:	55                   	push   %ebp
  800a2b:	89 e5                	mov    %esp,%ebp
  800a2d:	57                   	push   %edi
  800a2e:	56                   	push   %esi
  800a2f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a32:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a35:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a38:	39 c6                	cmp    %eax,%esi
  800a3a:	73 32                	jae    800a6e <memmove+0x48>
  800a3c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a3f:	39 c2                	cmp    %eax,%edx
  800a41:	76 2b                	jbe    800a6e <memmove+0x48>
		s += n;
		d += n;
  800a43:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a46:	89 fe                	mov    %edi,%esi
  800a48:	09 ce                	or     %ecx,%esi
  800a4a:	09 d6                	or     %edx,%esi
  800a4c:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a52:	75 0e                	jne    800a62 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a54:	83 ef 04             	sub    $0x4,%edi
  800a57:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a5a:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800a5d:	fd                   	std    
  800a5e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a60:	eb 09                	jmp    800a6b <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a62:	83 ef 01             	sub    $0x1,%edi
  800a65:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800a68:	fd                   	std    
  800a69:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a6b:	fc                   	cld    
  800a6c:	eb 1a                	jmp    800a88 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a6e:	89 c2                	mov    %eax,%edx
  800a70:	09 ca                	or     %ecx,%edx
  800a72:	09 f2                	or     %esi,%edx
  800a74:	f6 c2 03             	test   $0x3,%dl
  800a77:	75 0a                	jne    800a83 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a79:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800a7c:	89 c7                	mov    %eax,%edi
  800a7e:	fc                   	cld    
  800a7f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a81:	eb 05                	jmp    800a88 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800a83:	89 c7                	mov    %eax,%edi
  800a85:	fc                   	cld    
  800a86:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a88:	5e                   	pop    %esi
  800a89:	5f                   	pop    %edi
  800a8a:	5d                   	pop    %ebp
  800a8b:	c3                   	ret    

00800a8c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a8c:	f3 0f 1e fb          	endbr32 
  800a90:	55                   	push   %ebp
  800a91:	89 e5                	mov    %esp,%ebp
  800a93:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a96:	ff 75 10             	pushl  0x10(%ebp)
  800a99:	ff 75 0c             	pushl  0xc(%ebp)
  800a9c:	ff 75 08             	pushl  0x8(%ebp)
  800a9f:	e8 82 ff ff ff       	call   800a26 <memmove>
}
  800aa4:	c9                   	leave  
  800aa5:	c3                   	ret    

00800aa6 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800aa6:	f3 0f 1e fb          	endbr32 
  800aaa:	55                   	push   %ebp
  800aab:	89 e5                	mov    %esp,%ebp
  800aad:	56                   	push   %esi
  800aae:	53                   	push   %ebx
  800aaf:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab2:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ab5:	89 c6                	mov    %eax,%esi
  800ab7:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800aba:	39 f0                	cmp    %esi,%eax
  800abc:	74 1c                	je     800ada <memcmp+0x34>
		if (*s1 != *s2)
  800abe:	0f b6 08             	movzbl (%eax),%ecx
  800ac1:	0f b6 1a             	movzbl (%edx),%ebx
  800ac4:	38 d9                	cmp    %bl,%cl
  800ac6:	75 08                	jne    800ad0 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800ac8:	83 c0 01             	add    $0x1,%eax
  800acb:	83 c2 01             	add    $0x1,%edx
  800ace:	eb ea                	jmp    800aba <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800ad0:	0f b6 c1             	movzbl %cl,%eax
  800ad3:	0f b6 db             	movzbl %bl,%ebx
  800ad6:	29 d8                	sub    %ebx,%eax
  800ad8:	eb 05                	jmp    800adf <memcmp+0x39>
	}

	return 0;
  800ada:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800adf:	5b                   	pop    %ebx
  800ae0:	5e                   	pop    %esi
  800ae1:	5d                   	pop    %ebp
  800ae2:	c3                   	ret    

00800ae3 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ae3:	f3 0f 1e fb          	endbr32 
  800ae7:	55                   	push   %ebp
  800ae8:	89 e5                	mov    %esp,%ebp
  800aea:	8b 45 08             	mov    0x8(%ebp),%eax
  800aed:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800af0:	89 c2                	mov    %eax,%edx
  800af2:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800af5:	39 d0                	cmp    %edx,%eax
  800af7:	73 09                	jae    800b02 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800af9:	38 08                	cmp    %cl,(%eax)
  800afb:	74 05                	je     800b02 <memfind+0x1f>
	for (; s < ends; s++)
  800afd:	83 c0 01             	add    $0x1,%eax
  800b00:	eb f3                	jmp    800af5 <memfind+0x12>
			break;
	return (void *) s;
}
  800b02:	5d                   	pop    %ebp
  800b03:	c3                   	ret    

00800b04 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b04:	f3 0f 1e fb          	endbr32 
  800b08:	55                   	push   %ebp
  800b09:	89 e5                	mov    %esp,%ebp
  800b0b:	57                   	push   %edi
  800b0c:	56                   	push   %esi
  800b0d:	53                   	push   %ebx
  800b0e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b11:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b14:	eb 03                	jmp    800b19 <strtol+0x15>
		s++;
  800b16:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800b19:	0f b6 01             	movzbl (%ecx),%eax
  800b1c:	3c 20                	cmp    $0x20,%al
  800b1e:	74 f6                	je     800b16 <strtol+0x12>
  800b20:	3c 09                	cmp    $0x9,%al
  800b22:	74 f2                	je     800b16 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800b24:	3c 2b                	cmp    $0x2b,%al
  800b26:	74 2a                	je     800b52 <strtol+0x4e>
	int neg = 0;
  800b28:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800b2d:	3c 2d                	cmp    $0x2d,%al
  800b2f:	74 2b                	je     800b5c <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b31:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b37:	75 0f                	jne    800b48 <strtol+0x44>
  800b39:	80 39 30             	cmpb   $0x30,(%ecx)
  800b3c:	74 28                	je     800b66 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b3e:	85 db                	test   %ebx,%ebx
  800b40:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b45:	0f 44 d8             	cmove  %eax,%ebx
  800b48:	b8 00 00 00 00       	mov    $0x0,%eax
  800b4d:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800b50:	eb 46                	jmp    800b98 <strtol+0x94>
		s++;
  800b52:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800b55:	bf 00 00 00 00       	mov    $0x0,%edi
  800b5a:	eb d5                	jmp    800b31 <strtol+0x2d>
		s++, neg = 1;
  800b5c:	83 c1 01             	add    $0x1,%ecx
  800b5f:	bf 01 00 00 00       	mov    $0x1,%edi
  800b64:	eb cb                	jmp    800b31 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b66:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b6a:	74 0e                	je     800b7a <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800b6c:	85 db                	test   %ebx,%ebx
  800b6e:	75 d8                	jne    800b48 <strtol+0x44>
		s++, base = 8;
  800b70:	83 c1 01             	add    $0x1,%ecx
  800b73:	bb 08 00 00 00       	mov    $0x8,%ebx
  800b78:	eb ce                	jmp    800b48 <strtol+0x44>
		s += 2, base = 16;
  800b7a:	83 c1 02             	add    $0x2,%ecx
  800b7d:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b82:	eb c4                	jmp    800b48 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800b84:	0f be d2             	movsbl %dl,%edx
  800b87:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b8a:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b8d:	7d 3a                	jge    800bc9 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800b8f:	83 c1 01             	add    $0x1,%ecx
  800b92:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b96:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800b98:	0f b6 11             	movzbl (%ecx),%edx
  800b9b:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b9e:	89 f3                	mov    %esi,%ebx
  800ba0:	80 fb 09             	cmp    $0x9,%bl
  800ba3:	76 df                	jbe    800b84 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800ba5:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ba8:	89 f3                	mov    %esi,%ebx
  800baa:	80 fb 19             	cmp    $0x19,%bl
  800bad:	77 08                	ja     800bb7 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800baf:	0f be d2             	movsbl %dl,%edx
  800bb2:	83 ea 57             	sub    $0x57,%edx
  800bb5:	eb d3                	jmp    800b8a <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800bb7:	8d 72 bf             	lea    -0x41(%edx),%esi
  800bba:	89 f3                	mov    %esi,%ebx
  800bbc:	80 fb 19             	cmp    $0x19,%bl
  800bbf:	77 08                	ja     800bc9 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800bc1:	0f be d2             	movsbl %dl,%edx
  800bc4:	83 ea 37             	sub    $0x37,%edx
  800bc7:	eb c1                	jmp    800b8a <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800bc9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bcd:	74 05                	je     800bd4 <strtol+0xd0>
		*endptr = (char *) s;
  800bcf:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bd2:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800bd4:	89 c2                	mov    %eax,%edx
  800bd6:	f7 da                	neg    %edx
  800bd8:	85 ff                	test   %edi,%edi
  800bda:	0f 45 c2             	cmovne %edx,%eax
}
  800bdd:	5b                   	pop    %ebx
  800bde:	5e                   	pop    %esi
  800bdf:	5f                   	pop    %edi
  800be0:	5d                   	pop    %ebp
  800be1:	c3                   	ret    

00800be2 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800be2:	f3 0f 1e fb          	endbr32 
  800be6:	55                   	push   %ebp
  800be7:	89 e5                	mov    %esp,%ebp
  800be9:	57                   	push   %edi
  800bea:	56                   	push   %esi
  800beb:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bec:	b8 00 00 00 00       	mov    $0x0,%eax
  800bf1:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bf7:	89 c3                	mov    %eax,%ebx
  800bf9:	89 c7                	mov    %eax,%edi
  800bfb:	89 c6                	mov    %eax,%esi
  800bfd:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bff:	5b                   	pop    %ebx
  800c00:	5e                   	pop    %esi
  800c01:	5f                   	pop    %edi
  800c02:	5d                   	pop    %ebp
  800c03:	c3                   	ret    

00800c04 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c04:	f3 0f 1e fb          	endbr32 
  800c08:	55                   	push   %ebp
  800c09:	89 e5                	mov    %esp,%ebp
  800c0b:	57                   	push   %edi
  800c0c:	56                   	push   %esi
  800c0d:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c0e:	ba 00 00 00 00       	mov    $0x0,%edx
  800c13:	b8 01 00 00 00       	mov    $0x1,%eax
  800c18:	89 d1                	mov    %edx,%ecx
  800c1a:	89 d3                	mov    %edx,%ebx
  800c1c:	89 d7                	mov    %edx,%edi
  800c1e:	89 d6                	mov    %edx,%esi
  800c20:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c22:	5b                   	pop    %ebx
  800c23:	5e                   	pop    %esi
  800c24:	5f                   	pop    %edi
  800c25:	5d                   	pop    %ebp
  800c26:	c3                   	ret    

00800c27 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c27:	f3 0f 1e fb          	endbr32 
  800c2b:	55                   	push   %ebp
  800c2c:	89 e5                	mov    %esp,%ebp
  800c2e:	57                   	push   %edi
  800c2f:	56                   	push   %esi
  800c30:	53                   	push   %ebx
  800c31:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c34:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c39:	8b 55 08             	mov    0x8(%ebp),%edx
  800c3c:	b8 03 00 00 00       	mov    $0x3,%eax
  800c41:	89 cb                	mov    %ecx,%ebx
  800c43:	89 cf                	mov    %ecx,%edi
  800c45:	89 ce                	mov    %ecx,%esi
  800c47:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c49:	85 c0                	test   %eax,%eax
  800c4b:	7f 08                	jg     800c55 <sys_env_destroy+0x2e>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c4d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c50:	5b                   	pop    %ebx
  800c51:	5e                   	pop    %esi
  800c52:	5f                   	pop    %edi
  800c53:	5d                   	pop    %ebp
  800c54:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c55:	83 ec 0c             	sub    $0xc,%esp
  800c58:	50                   	push   %eax
  800c59:	6a 03                	push   $0x3
  800c5b:	68 24 14 80 00       	push   $0x801424
  800c60:	6a 23                	push   $0x23
  800c62:	68 41 14 80 00       	push   $0x801441
  800c67:	e8 d4 f4 ff ff       	call   800140 <_panic>

00800c6c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c6c:	f3 0f 1e fb          	endbr32 
  800c70:	55                   	push   %ebp
  800c71:	89 e5                	mov    %esp,%ebp
  800c73:	57                   	push   %edi
  800c74:	56                   	push   %esi
  800c75:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c76:	ba 00 00 00 00       	mov    $0x0,%edx
  800c7b:	b8 02 00 00 00       	mov    $0x2,%eax
  800c80:	89 d1                	mov    %edx,%ecx
  800c82:	89 d3                	mov    %edx,%ebx
  800c84:	89 d7                	mov    %edx,%edi
  800c86:	89 d6                	mov    %edx,%esi
  800c88:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c8a:	5b                   	pop    %ebx
  800c8b:	5e                   	pop    %esi
  800c8c:	5f                   	pop    %edi
  800c8d:	5d                   	pop    %ebp
  800c8e:	c3                   	ret    

00800c8f <sys_yield>:

void
sys_yield(void)
{
  800c8f:	f3 0f 1e fb          	endbr32 
  800c93:	55                   	push   %ebp
  800c94:	89 e5                	mov    %esp,%ebp
  800c96:	57                   	push   %edi
  800c97:	56                   	push   %esi
  800c98:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c99:	ba 00 00 00 00       	mov    $0x0,%edx
  800c9e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ca3:	89 d1                	mov    %edx,%ecx
  800ca5:	89 d3                	mov    %edx,%ebx
  800ca7:	89 d7                	mov    %edx,%edi
  800ca9:	89 d6                	mov    %edx,%esi
  800cab:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800cad:	5b                   	pop    %ebx
  800cae:	5e                   	pop    %esi
  800caf:	5f                   	pop    %edi
  800cb0:	5d                   	pop    %ebp
  800cb1:	c3                   	ret    

00800cb2 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800cb2:	f3 0f 1e fb          	endbr32 
  800cb6:	55                   	push   %ebp
  800cb7:	89 e5                	mov    %esp,%ebp
  800cb9:	57                   	push   %edi
  800cba:	56                   	push   %esi
  800cbb:	53                   	push   %ebx
  800cbc:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cbf:	be 00 00 00 00       	mov    $0x0,%esi
  800cc4:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cca:	b8 04 00 00 00       	mov    $0x4,%eax
  800ccf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cd2:	89 f7                	mov    %esi,%edi
  800cd4:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cd6:	85 c0                	test   %eax,%eax
  800cd8:	7f 08                	jg     800ce2 <sys_page_alloc+0x30>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
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
  800ce6:	6a 04                	push   $0x4
  800ce8:	68 24 14 80 00       	push   $0x801424
  800ced:	6a 23                	push   $0x23
  800cef:	68 41 14 80 00       	push   $0x801441
  800cf4:	e8 47 f4 ff ff       	call   800140 <_panic>

00800cf9 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800cf9:	f3 0f 1e fb          	endbr32 
  800cfd:	55                   	push   %ebp
  800cfe:	89 e5                	mov    %esp,%ebp
  800d00:	57                   	push   %edi
  800d01:	56                   	push   %esi
  800d02:	53                   	push   %ebx
  800d03:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d06:	8b 55 08             	mov    0x8(%ebp),%edx
  800d09:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d0c:	b8 05 00 00 00       	mov    $0x5,%eax
  800d11:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d14:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d17:	8b 75 18             	mov    0x18(%ebp),%esi
  800d1a:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d1c:	85 c0                	test   %eax,%eax
  800d1e:	7f 08                	jg     800d28 <sys_page_map+0x2f>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
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
  800d2c:	6a 05                	push   $0x5
  800d2e:	68 24 14 80 00       	push   $0x801424
  800d33:	6a 23                	push   $0x23
  800d35:	68 41 14 80 00       	push   $0x801441
  800d3a:	e8 01 f4 ff ff       	call   800140 <_panic>

00800d3f <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
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
  800d57:	b8 06 00 00 00       	mov    $0x6,%eax
  800d5c:	89 df                	mov    %ebx,%edi
  800d5e:	89 de                	mov    %ebx,%esi
  800d60:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d62:	85 c0                	test   %eax,%eax
  800d64:	7f 08                	jg     800d6e <sys_page_unmap+0x2f>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
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
  800d72:	6a 06                	push   $0x6
  800d74:	68 24 14 80 00       	push   $0x801424
  800d79:	6a 23                	push   $0x23
  800d7b:	68 41 14 80 00       	push   $0x801441
  800d80:	e8 bb f3 ff ff       	call   800140 <_panic>

00800d85 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d85:	f3 0f 1e fb          	endbr32 
  800d89:	55                   	push   %ebp
  800d8a:	89 e5                	mov    %esp,%ebp
  800d8c:	57                   	push   %edi
  800d8d:	56                   	push   %esi
  800d8e:	53                   	push   %ebx
  800d8f:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d92:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d97:	8b 55 08             	mov    0x8(%ebp),%edx
  800d9a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d9d:	b8 08 00 00 00       	mov    $0x8,%eax
  800da2:	89 df                	mov    %ebx,%edi
  800da4:	89 de                	mov    %ebx,%esi
  800da6:	cd 30                	int    $0x30
	if(check && ret > 0)
  800da8:	85 c0                	test   %eax,%eax
  800daa:	7f 08                	jg     800db4 <sys_env_set_status+0x2f>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800dac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800daf:	5b                   	pop    %ebx
  800db0:	5e                   	pop    %esi
  800db1:	5f                   	pop    %edi
  800db2:	5d                   	pop    %ebp
  800db3:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800db4:	83 ec 0c             	sub    $0xc,%esp
  800db7:	50                   	push   %eax
  800db8:	6a 08                	push   $0x8
  800dba:	68 24 14 80 00       	push   $0x801424
  800dbf:	6a 23                	push   $0x23
  800dc1:	68 41 14 80 00       	push   $0x801441
  800dc6:	e8 75 f3 ff ff       	call   800140 <_panic>

00800dcb <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800dcb:	f3 0f 1e fb          	endbr32 
  800dcf:	55                   	push   %ebp
  800dd0:	89 e5                	mov    %esp,%ebp
  800dd2:	57                   	push   %edi
  800dd3:	56                   	push   %esi
  800dd4:	53                   	push   %ebx
  800dd5:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800dd8:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ddd:	8b 55 08             	mov    0x8(%ebp),%edx
  800de0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800de3:	b8 09 00 00 00       	mov    $0x9,%eax
  800de8:	89 df                	mov    %ebx,%edi
  800dea:	89 de                	mov    %ebx,%esi
  800dec:	cd 30                	int    $0x30
	if(check && ret > 0)
  800dee:	85 c0                	test   %eax,%eax
  800df0:	7f 08                	jg     800dfa <sys_env_set_pgfault_upcall+0x2f>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800df2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800df5:	5b                   	pop    %ebx
  800df6:	5e                   	pop    %esi
  800df7:	5f                   	pop    %edi
  800df8:	5d                   	pop    %ebp
  800df9:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800dfa:	83 ec 0c             	sub    $0xc,%esp
  800dfd:	50                   	push   %eax
  800dfe:	6a 09                	push   $0x9
  800e00:	68 24 14 80 00       	push   $0x801424
  800e05:	6a 23                	push   $0x23
  800e07:	68 41 14 80 00       	push   $0x801441
  800e0c:	e8 2f f3 ff ff       	call   800140 <_panic>

00800e11 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e11:	f3 0f 1e fb          	endbr32 
  800e15:	55                   	push   %ebp
  800e16:	89 e5                	mov    %esp,%ebp
  800e18:	57                   	push   %edi
  800e19:	56                   	push   %esi
  800e1a:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e1b:	8b 55 08             	mov    0x8(%ebp),%edx
  800e1e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e21:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e26:	be 00 00 00 00       	mov    $0x0,%esi
  800e2b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e2e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e31:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e33:	5b                   	pop    %ebx
  800e34:	5e                   	pop    %esi
  800e35:	5f                   	pop    %edi
  800e36:	5d                   	pop    %ebp
  800e37:	c3                   	ret    

00800e38 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e38:	f3 0f 1e fb          	endbr32 
  800e3c:	55                   	push   %ebp
  800e3d:	89 e5                	mov    %esp,%ebp
  800e3f:	57                   	push   %edi
  800e40:	56                   	push   %esi
  800e41:	53                   	push   %ebx
  800e42:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e45:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e4a:	8b 55 08             	mov    0x8(%ebp),%edx
  800e4d:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e52:	89 cb                	mov    %ecx,%ebx
  800e54:	89 cf                	mov    %ecx,%edi
  800e56:	89 ce                	mov    %ecx,%esi
  800e58:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e5a:	85 c0                	test   %eax,%eax
  800e5c:	7f 08                	jg     800e66 <sys_ipc_recv+0x2e>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e5e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e61:	5b                   	pop    %ebx
  800e62:	5e                   	pop    %esi
  800e63:	5f                   	pop    %edi
  800e64:	5d                   	pop    %ebp
  800e65:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e66:	83 ec 0c             	sub    $0xc,%esp
  800e69:	50                   	push   %eax
  800e6a:	6a 0c                	push   $0xc
  800e6c:	68 24 14 80 00       	push   $0x801424
  800e71:	6a 23                	push   $0x23
  800e73:	68 41 14 80 00       	push   $0x801441
  800e78:	e8 c3 f2 ff ff       	call   800140 <_panic>
  800e7d:	66 90                	xchg   %ax,%ax
  800e7f:	90                   	nop

00800e80 <__udivdi3>:
  800e80:	f3 0f 1e fb          	endbr32 
  800e84:	55                   	push   %ebp
  800e85:	57                   	push   %edi
  800e86:	56                   	push   %esi
  800e87:	53                   	push   %ebx
  800e88:	83 ec 1c             	sub    $0x1c,%esp
  800e8b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800e8f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800e93:	8b 74 24 34          	mov    0x34(%esp),%esi
  800e97:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800e9b:	85 d2                	test   %edx,%edx
  800e9d:	75 19                	jne    800eb8 <__udivdi3+0x38>
  800e9f:	39 f3                	cmp    %esi,%ebx
  800ea1:	76 4d                	jbe    800ef0 <__udivdi3+0x70>
  800ea3:	31 ff                	xor    %edi,%edi
  800ea5:	89 e8                	mov    %ebp,%eax
  800ea7:	89 f2                	mov    %esi,%edx
  800ea9:	f7 f3                	div    %ebx
  800eab:	89 fa                	mov    %edi,%edx
  800ead:	83 c4 1c             	add    $0x1c,%esp
  800eb0:	5b                   	pop    %ebx
  800eb1:	5e                   	pop    %esi
  800eb2:	5f                   	pop    %edi
  800eb3:	5d                   	pop    %ebp
  800eb4:	c3                   	ret    
  800eb5:	8d 76 00             	lea    0x0(%esi),%esi
  800eb8:	39 f2                	cmp    %esi,%edx
  800eba:	76 14                	jbe    800ed0 <__udivdi3+0x50>
  800ebc:	31 ff                	xor    %edi,%edi
  800ebe:	31 c0                	xor    %eax,%eax
  800ec0:	89 fa                	mov    %edi,%edx
  800ec2:	83 c4 1c             	add    $0x1c,%esp
  800ec5:	5b                   	pop    %ebx
  800ec6:	5e                   	pop    %esi
  800ec7:	5f                   	pop    %edi
  800ec8:	5d                   	pop    %ebp
  800ec9:	c3                   	ret    
  800eca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800ed0:	0f bd fa             	bsr    %edx,%edi
  800ed3:	83 f7 1f             	xor    $0x1f,%edi
  800ed6:	75 48                	jne    800f20 <__udivdi3+0xa0>
  800ed8:	39 f2                	cmp    %esi,%edx
  800eda:	72 06                	jb     800ee2 <__udivdi3+0x62>
  800edc:	31 c0                	xor    %eax,%eax
  800ede:	39 eb                	cmp    %ebp,%ebx
  800ee0:	77 de                	ja     800ec0 <__udivdi3+0x40>
  800ee2:	b8 01 00 00 00       	mov    $0x1,%eax
  800ee7:	eb d7                	jmp    800ec0 <__udivdi3+0x40>
  800ee9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800ef0:	89 d9                	mov    %ebx,%ecx
  800ef2:	85 db                	test   %ebx,%ebx
  800ef4:	75 0b                	jne    800f01 <__udivdi3+0x81>
  800ef6:	b8 01 00 00 00       	mov    $0x1,%eax
  800efb:	31 d2                	xor    %edx,%edx
  800efd:	f7 f3                	div    %ebx
  800eff:	89 c1                	mov    %eax,%ecx
  800f01:	31 d2                	xor    %edx,%edx
  800f03:	89 f0                	mov    %esi,%eax
  800f05:	f7 f1                	div    %ecx
  800f07:	89 c6                	mov    %eax,%esi
  800f09:	89 e8                	mov    %ebp,%eax
  800f0b:	89 f7                	mov    %esi,%edi
  800f0d:	f7 f1                	div    %ecx
  800f0f:	89 fa                	mov    %edi,%edx
  800f11:	83 c4 1c             	add    $0x1c,%esp
  800f14:	5b                   	pop    %ebx
  800f15:	5e                   	pop    %esi
  800f16:	5f                   	pop    %edi
  800f17:	5d                   	pop    %ebp
  800f18:	c3                   	ret    
  800f19:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f20:	89 f9                	mov    %edi,%ecx
  800f22:	b8 20 00 00 00       	mov    $0x20,%eax
  800f27:	29 f8                	sub    %edi,%eax
  800f29:	d3 e2                	shl    %cl,%edx
  800f2b:	89 54 24 08          	mov    %edx,0x8(%esp)
  800f2f:	89 c1                	mov    %eax,%ecx
  800f31:	89 da                	mov    %ebx,%edx
  800f33:	d3 ea                	shr    %cl,%edx
  800f35:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800f39:	09 d1                	or     %edx,%ecx
  800f3b:	89 f2                	mov    %esi,%edx
  800f3d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800f41:	89 f9                	mov    %edi,%ecx
  800f43:	d3 e3                	shl    %cl,%ebx
  800f45:	89 c1                	mov    %eax,%ecx
  800f47:	d3 ea                	shr    %cl,%edx
  800f49:	89 f9                	mov    %edi,%ecx
  800f4b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800f4f:	89 eb                	mov    %ebp,%ebx
  800f51:	d3 e6                	shl    %cl,%esi
  800f53:	89 c1                	mov    %eax,%ecx
  800f55:	d3 eb                	shr    %cl,%ebx
  800f57:	09 de                	or     %ebx,%esi
  800f59:	89 f0                	mov    %esi,%eax
  800f5b:	f7 74 24 08          	divl   0x8(%esp)
  800f5f:	89 d6                	mov    %edx,%esi
  800f61:	89 c3                	mov    %eax,%ebx
  800f63:	f7 64 24 0c          	mull   0xc(%esp)
  800f67:	39 d6                	cmp    %edx,%esi
  800f69:	72 15                	jb     800f80 <__udivdi3+0x100>
  800f6b:	89 f9                	mov    %edi,%ecx
  800f6d:	d3 e5                	shl    %cl,%ebp
  800f6f:	39 c5                	cmp    %eax,%ebp
  800f71:	73 04                	jae    800f77 <__udivdi3+0xf7>
  800f73:	39 d6                	cmp    %edx,%esi
  800f75:	74 09                	je     800f80 <__udivdi3+0x100>
  800f77:	89 d8                	mov    %ebx,%eax
  800f79:	31 ff                	xor    %edi,%edi
  800f7b:	e9 40 ff ff ff       	jmp    800ec0 <__udivdi3+0x40>
  800f80:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800f83:	31 ff                	xor    %edi,%edi
  800f85:	e9 36 ff ff ff       	jmp    800ec0 <__udivdi3+0x40>
  800f8a:	66 90                	xchg   %ax,%ax
  800f8c:	66 90                	xchg   %ax,%ax
  800f8e:	66 90                	xchg   %ax,%ax

00800f90 <__umoddi3>:
  800f90:	f3 0f 1e fb          	endbr32 
  800f94:	55                   	push   %ebp
  800f95:	57                   	push   %edi
  800f96:	56                   	push   %esi
  800f97:	53                   	push   %ebx
  800f98:	83 ec 1c             	sub    $0x1c,%esp
  800f9b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  800f9f:	8b 74 24 30          	mov    0x30(%esp),%esi
  800fa3:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800fa7:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800fab:	85 c0                	test   %eax,%eax
  800fad:	75 19                	jne    800fc8 <__umoddi3+0x38>
  800faf:	39 df                	cmp    %ebx,%edi
  800fb1:	76 5d                	jbe    801010 <__umoddi3+0x80>
  800fb3:	89 f0                	mov    %esi,%eax
  800fb5:	89 da                	mov    %ebx,%edx
  800fb7:	f7 f7                	div    %edi
  800fb9:	89 d0                	mov    %edx,%eax
  800fbb:	31 d2                	xor    %edx,%edx
  800fbd:	83 c4 1c             	add    $0x1c,%esp
  800fc0:	5b                   	pop    %ebx
  800fc1:	5e                   	pop    %esi
  800fc2:	5f                   	pop    %edi
  800fc3:	5d                   	pop    %ebp
  800fc4:	c3                   	ret    
  800fc5:	8d 76 00             	lea    0x0(%esi),%esi
  800fc8:	89 f2                	mov    %esi,%edx
  800fca:	39 d8                	cmp    %ebx,%eax
  800fcc:	76 12                	jbe    800fe0 <__umoddi3+0x50>
  800fce:	89 f0                	mov    %esi,%eax
  800fd0:	89 da                	mov    %ebx,%edx
  800fd2:	83 c4 1c             	add    $0x1c,%esp
  800fd5:	5b                   	pop    %ebx
  800fd6:	5e                   	pop    %esi
  800fd7:	5f                   	pop    %edi
  800fd8:	5d                   	pop    %ebp
  800fd9:	c3                   	ret    
  800fda:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800fe0:	0f bd e8             	bsr    %eax,%ebp
  800fe3:	83 f5 1f             	xor    $0x1f,%ebp
  800fe6:	75 50                	jne    801038 <__umoddi3+0xa8>
  800fe8:	39 d8                	cmp    %ebx,%eax
  800fea:	0f 82 e0 00 00 00    	jb     8010d0 <__umoddi3+0x140>
  800ff0:	89 d9                	mov    %ebx,%ecx
  800ff2:	39 f7                	cmp    %esi,%edi
  800ff4:	0f 86 d6 00 00 00    	jbe    8010d0 <__umoddi3+0x140>
  800ffa:	89 d0                	mov    %edx,%eax
  800ffc:	89 ca                	mov    %ecx,%edx
  800ffe:	83 c4 1c             	add    $0x1c,%esp
  801001:	5b                   	pop    %ebx
  801002:	5e                   	pop    %esi
  801003:	5f                   	pop    %edi
  801004:	5d                   	pop    %ebp
  801005:	c3                   	ret    
  801006:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80100d:	8d 76 00             	lea    0x0(%esi),%esi
  801010:	89 fd                	mov    %edi,%ebp
  801012:	85 ff                	test   %edi,%edi
  801014:	75 0b                	jne    801021 <__umoddi3+0x91>
  801016:	b8 01 00 00 00       	mov    $0x1,%eax
  80101b:	31 d2                	xor    %edx,%edx
  80101d:	f7 f7                	div    %edi
  80101f:	89 c5                	mov    %eax,%ebp
  801021:	89 d8                	mov    %ebx,%eax
  801023:	31 d2                	xor    %edx,%edx
  801025:	f7 f5                	div    %ebp
  801027:	89 f0                	mov    %esi,%eax
  801029:	f7 f5                	div    %ebp
  80102b:	89 d0                	mov    %edx,%eax
  80102d:	31 d2                	xor    %edx,%edx
  80102f:	eb 8c                	jmp    800fbd <__umoddi3+0x2d>
  801031:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801038:	89 e9                	mov    %ebp,%ecx
  80103a:	ba 20 00 00 00       	mov    $0x20,%edx
  80103f:	29 ea                	sub    %ebp,%edx
  801041:	d3 e0                	shl    %cl,%eax
  801043:	89 44 24 08          	mov    %eax,0x8(%esp)
  801047:	89 d1                	mov    %edx,%ecx
  801049:	89 f8                	mov    %edi,%eax
  80104b:	d3 e8                	shr    %cl,%eax
  80104d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801051:	89 54 24 04          	mov    %edx,0x4(%esp)
  801055:	8b 54 24 04          	mov    0x4(%esp),%edx
  801059:	09 c1                	or     %eax,%ecx
  80105b:	89 d8                	mov    %ebx,%eax
  80105d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801061:	89 e9                	mov    %ebp,%ecx
  801063:	d3 e7                	shl    %cl,%edi
  801065:	89 d1                	mov    %edx,%ecx
  801067:	d3 e8                	shr    %cl,%eax
  801069:	89 e9                	mov    %ebp,%ecx
  80106b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80106f:	d3 e3                	shl    %cl,%ebx
  801071:	89 c7                	mov    %eax,%edi
  801073:	89 d1                	mov    %edx,%ecx
  801075:	89 f0                	mov    %esi,%eax
  801077:	d3 e8                	shr    %cl,%eax
  801079:	89 e9                	mov    %ebp,%ecx
  80107b:	89 fa                	mov    %edi,%edx
  80107d:	d3 e6                	shl    %cl,%esi
  80107f:	09 d8                	or     %ebx,%eax
  801081:	f7 74 24 08          	divl   0x8(%esp)
  801085:	89 d1                	mov    %edx,%ecx
  801087:	89 f3                	mov    %esi,%ebx
  801089:	f7 64 24 0c          	mull   0xc(%esp)
  80108d:	89 c6                	mov    %eax,%esi
  80108f:	89 d7                	mov    %edx,%edi
  801091:	39 d1                	cmp    %edx,%ecx
  801093:	72 06                	jb     80109b <__umoddi3+0x10b>
  801095:	75 10                	jne    8010a7 <__umoddi3+0x117>
  801097:	39 c3                	cmp    %eax,%ebx
  801099:	73 0c                	jae    8010a7 <__umoddi3+0x117>
  80109b:	2b 44 24 0c          	sub    0xc(%esp),%eax
  80109f:	1b 54 24 08          	sbb    0x8(%esp),%edx
  8010a3:	89 d7                	mov    %edx,%edi
  8010a5:	89 c6                	mov    %eax,%esi
  8010a7:	89 ca                	mov    %ecx,%edx
  8010a9:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8010ae:	29 f3                	sub    %esi,%ebx
  8010b0:	19 fa                	sbb    %edi,%edx
  8010b2:	89 d0                	mov    %edx,%eax
  8010b4:	d3 e0                	shl    %cl,%eax
  8010b6:	89 e9                	mov    %ebp,%ecx
  8010b8:	d3 eb                	shr    %cl,%ebx
  8010ba:	d3 ea                	shr    %cl,%edx
  8010bc:	09 d8                	or     %ebx,%eax
  8010be:	83 c4 1c             	add    $0x1c,%esp
  8010c1:	5b                   	pop    %ebx
  8010c2:	5e                   	pop    %esi
  8010c3:	5f                   	pop    %edi
  8010c4:	5d                   	pop    %ebp
  8010c5:	c3                   	ret    
  8010c6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8010cd:	8d 76 00             	lea    0x0(%esi),%esi
  8010d0:	29 fe                	sub    %edi,%esi
  8010d2:	19 c3                	sbb    %eax,%ebx
  8010d4:	89 f2                	mov    %esi,%edx
  8010d6:	89 d9                	mov    %ebx,%ecx
  8010d8:	e9 1d ff ff ff       	jmp    800ffa <__umoddi3+0x6a>
