
obj/user/faultalloc:     file format elf32-i386


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
  80002c:	e8 a1 00 00 00       	call   8000d2 <libmain>
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
  800044:	68 60 11 80 00       	push   $0x801160
  800049:	e8 cb 01 00 00       	call   800219 <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  80004e:	83 c4 0c             	add    $0xc,%esp
  800051:	6a 07                	push   $0x7
  800053:	89 d8                	mov    %ebx,%eax
  800055:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80005a:	50                   	push   %eax
  80005b:	6a 00                	push   $0x0
  80005d:	e8 42 0c 00 00       	call   800ca4 <sys_page_alloc>
  800062:	83 c4 10             	add    $0x10,%esp
  800065:	85 c0                	test   %eax,%eax
  800067:	78 16                	js     80007f <handler+0x4c>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  800069:	53                   	push   %ebx
  80006a:	68 ac 11 80 00       	push   $0x8011ac
  80006f:	6a 64                	push   $0x64
  800071:	53                   	push   %ebx
  800072:	e8 8a 07 00 00       	call   800801 <snprintf>
}
  800077:	83 c4 10             	add    $0x10,%esp
  80007a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80007d:	c9                   	leave  
  80007e:	c3                   	ret    
		panic("allocating at %x in page fault handler: %e", addr, r);
  80007f:	83 ec 0c             	sub    $0xc,%esp
  800082:	50                   	push   %eax
  800083:	53                   	push   %ebx
  800084:	68 80 11 80 00       	push   $0x801180
  800089:	6a 0e                	push   $0xe
  80008b:	68 6a 11 80 00       	push   $0x80116a
  800090:	e8 9d 00 00 00       	call   800132 <_panic>

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
  8000a4:	e8 c6 0d 00 00       	call   800e6f <set_pgfault_handler>
	cprintf("%s\n", (char*)0xDeadBeef);
  8000a9:	83 c4 08             	add    $0x8,%esp
  8000ac:	68 ef be ad de       	push   $0xdeadbeef
  8000b1:	68 7c 11 80 00       	push   $0x80117c
  8000b6:	e8 5e 01 00 00       	call   800219 <cprintf>
	cprintf("%s\n", (char*)0xCafeBffe);
  8000bb:	83 c4 08             	add    $0x8,%esp
  8000be:	68 fe bf fe ca       	push   $0xcafebffe
  8000c3:	68 7c 11 80 00       	push   $0x80117c
  8000c8:	e8 4c 01 00 00       	call   800219 <cprintf>
}
  8000cd:	83 c4 10             	add    $0x10,%esp
  8000d0:	c9                   	leave  
  8000d1:	c3                   	ret    

008000d2 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000d2:	f3 0f 1e fb          	endbr32 
  8000d6:	55                   	push   %ebp
  8000d7:	89 e5                	mov    %esp,%ebp
  8000d9:	56                   	push   %esi
  8000da:	53                   	push   %ebx
  8000db:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000de:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv=&envs[ENVX(sys_getenvid())];
  8000e1:	e8 78 0b 00 00       	call   800c5e <sys_getenvid>
  8000e6:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000eb:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000ee:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000f3:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000f8:	85 db                	test   %ebx,%ebx
  8000fa:	7e 07                	jle    800103 <libmain+0x31>
		binaryname = argv[0];
  8000fc:	8b 06                	mov    (%esi),%eax
  8000fe:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800103:	83 ec 08             	sub    $0x8,%esp
  800106:	56                   	push   %esi
  800107:	53                   	push   %ebx
  800108:	e8 88 ff ff ff       	call   800095 <umain>

	// exit gracefully
	exit();
  80010d:	e8 0a 00 00 00       	call   80011c <exit>
}
  800112:	83 c4 10             	add    $0x10,%esp
  800115:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800118:	5b                   	pop    %ebx
  800119:	5e                   	pop    %esi
  80011a:	5d                   	pop    %ebp
  80011b:	c3                   	ret    

0080011c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80011c:	f3 0f 1e fb          	endbr32 
  800120:	55                   	push   %ebp
  800121:	89 e5                	mov    %esp,%ebp
  800123:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800126:	6a 00                	push   $0x0
  800128:	e8 ec 0a 00 00       	call   800c19 <sys_env_destroy>
}
  80012d:	83 c4 10             	add    $0x10,%esp
  800130:	c9                   	leave  
  800131:	c3                   	ret    

00800132 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800132:	f3 0f 1e fb          	endbr32 
  800136:	55                   	push   %ebp
  800137:	89 e5                	mov    %esp,%ebp
  800139:	56                   	push   %esi
  80013a:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80013b:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80013e:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800144:	e8 15 0b 00 00       	call   800c5e <sys_getenvid>
  800149:	83 ec 0c             	sub    $0xc,%esp
  80014c:	ff 75 0c             	pushl  0xc(%ebp)
  80014f:	ff 75 08             	pushl  0x8(%ebp)
  800152:	56                   	push   %esi
  800153:	50                   	push   %eax
  800154:	68 d8 11 80 00       	push   $0x8011d8
  800159:	e8 bb 00 00 00       	call   800219 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80015e:	83 c4 18             	add    $0x18,%esp
  800161:	53                   	push   %ebx
  800162:	ff 75 10             	pushl  0x10(%ebp)
  800165:	e8 5a 00 00 00       	call   8001c4 <vcprintf>
	cprintf("\n");
  80016a:	c7 04 24 7e 11 80 00 	movl   $0x80117e,(%esp)
  800171:	e8 a3 00 00 00       	call   800219 <cprintf>
  800176:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800179:	cc                   	int3   
  80017a:	eb fd                	jmp    800179 <_panic+0x47>

0080017c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80017c:	f3 0f 1e fb          	endbr32 
  800180:	55                   	push   %ebp
  800181:	89 e5                	mov    %esp,%ebp
  800183:	53                   	push   %ebx
  800184:	83 ec 04             	sub    $0x4,%esp
  800187:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80018a:	8b 13                	mov    (%ebx),%edx
  80018c:	8d 42 01             	lea    0x1(%edx),%eax
  80018f:	89 03                	mov    %eax,(%ebx)
  800191:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800194:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800198:	3d ff 00 00 00       	cmp    $0xff,%eax
  80019d:	74 09                	je     8001a8 <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80019f:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001a3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001a6:	c9                   	leave  
  8001a7:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8001a8:	83 ec 08             	sub    $0x8,%esp
  8001ab:	68 ff 00 00 00       	push   $0xff
  8001b0:	8d 43 08             	lea    0x8(%ebx),%eax
  8001b3:	50                   	push   %eax
  8001b4:	e8 1b 0a 00 00       	call   800bd4 <sys_cputs>
		b->idx = 0;
  8001b9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001bf:	83 c4 10             	add    $0x10,%esp
  8001c2:	eb db                	jmp    80019f <putch+0x23>

008001c4 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001c4:	f3 0f 1e fb          	endbr32 
  8001c8:	55                   	push   %ebp
  8001c9:	89 e5                	mov    %esp,%ebp
  8001cb:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001d1:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001d8:	00 00 00 
	b.cnt = 0;
  8001db:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001e2:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001e5:	ff 75 0c             	pushl  0xc(%ebp)
  8001e8:	ff 75 08             	pushl  0x8(%ebp)
  8001eb:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001f1:	50                   	push   %eax
  8001f2:	68 7c 01 80 00       	push   $0x80017c
  8001f7:	e8 20 01 00 00       	call   80031c <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001fc:	83 c4 08             	add    $0x8,%esp
  8001ff:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800205:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80020b:	50                   	push   %eax
  80020c:	e8 c3 09 00 00       	call   800bd4 <sys_cputs>

	return b.cnt;
}
  800211:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800217:	c9                   	leave  
  800218:	c3                   	ret    

00800219 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800219:	f3 0f 1e fb          	endbr32 
  80021d:	55                   	push   %ebp
  80021e:	89 e5                	mov    %esp,%ebp
  800220:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800223:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800226:	50                   	push   %eax
  800227:	ff 75 08             	pushl  0x8(%ebp)
  80022a:	e8 95 ff ff ff       	call   8001c4 <vcprintf>
	va_end(ap);

	return cnt;
}
  80022f:	c9                   	leave  
  800230:	c3                   	ret    

00800231 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800231:	55                   	push   %ebp
  800232:	89 e5                	mov    %esp,%ebp
  800234:	57                   	push   %edi
  800235:	56                   	push   %esi
  800236:	53                   	push   %ebx
  800237:	83 ec 1c             	sub    $0x1c,%esp
  80023a:	89 c7                	mov    %eax,%edi
  80023c:	89 d6                	mov    %edx,%esi
  80023e:	8b 45 08             	mov    0x8(%ebp),%eax
  800241:	8b 55 0c             	mov    0xc(%ebp),%edx
  800244:	89 d1                	mov    %edx,%ecx
  800246:	89 c2                	mov    %eax,%edx
  800248:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80024b:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80024e:	8b 45 10             	mov    0x10(%ebp),%eax
  800251:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800254:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800257:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80025e:	39 c2                	cmp    %eax,%edx
  800260:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800263:	72 3e                	jb     8002a3 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800265:	83 ec 0c             	sub    $0xc,%esp
  800268:	ff 75 18             	pushl  0x18(%ebp)
  80026b:	83 eb 01             	sub    $0x1,%ebx
  80026e:	53                   	push   %ebx
  80026f:	50                   	push   %eax
  800270:	83 ec 08             	sub    $0x8,%esp
  800273:	ff 75 e4             	pushl  -0x1c(%ebp)
  800276:	ff 75 e0             	pushl  -0x20(%ebp)
  800279:	ff 75 dc             	pushl  -0x24(%ebp)
  80027c:	ff 75 d8             	pushl  -0x28(%ebp)
  80027f:	e8 7c 0c 00 00       	call   800f00 <__udivdi3>
  800284:	83 c4 18             	add    $0x18,%esp
  800287:	52                   	push   %edx
  800288:	50                   	push   %eax
  800289:	89 f2                	mov    %esi,%edx
  80028b:	89 f8                	mov    %edi,%eax
  80028d:	e8 9f ff ff ff       	call   800231 <printnum>
  800292:	83 c4 20             	add    $0x20,%esp
  800295:	eb 13                	jmp    8002aa <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800297:	83 ec 08             	sub    $0x8,%esp
  80029a:	56                   	push   %esi
  80029b:	ff 75 18             	pushl  0x18(%ebp)
  80029e:	ff d7                	call   *%edi
  8002a0:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8002a3:	83 eb 01             	sub    $0x1,%ebx
  8002a6:	85 db                	test   %ebx,%ebx
  8002a8:	7f ed                	jg     800297 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002aa:	83 ec 08             	sub    $0x8,%esp
  8002ad:	56                   	push   %esi
  8002ae:	83 ec 04             	sub    $0x4,%esp
  8002b1:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002b4:	ff 75 e0             	pushl  -0x20(%ebp)
  8002b7:	ff 75 dc             	pushl  -0x24(%ebp)
  8002ba:	ff 75 d8             	pushl  -0x28(%ebp)
  8002bd:	e8 4e 0d 00 00       	call   801010 <__umoddi3>
  8002c2:	83 c4 14             	add    $0x14,%esp
  8002c5:	0f be 80 fb 11 80 00 	movsbl 0x8011fb(%eax),%eax
  8002cc:	50                   	push   %eax
  8002cd:	ff d7                	call   *%edi
}
  8002cf:	83 c4 10             	add    $0x10,%esp
  8002d2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002d5:	5b                   	pop    %ebx
  8002d6:	5e                   	pop    %esi
  8002d7:	5f                   	pop    %edi
  8002d8:	5d                   	pop    %ebp
  8002d9:	c3                   	ret    

008002da <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002da:	f3 0f 1e fb          	endbr32 
  8002de:	55                   	push   %ebp
  8002df:	89 e5                	mov    %esp,%ebp
  8002e1:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002e4:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002e8:	8b 10                	mov    (%eax),%edx
  8002ea:	3b 50 04             	cmp    0x4(%eax),%edx
  8002ed:	73 0a                	jae    8002f9 <sprintputch+0x1f>
		*b->buf++ = ch;
  8002ef:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002f2:	89 08                	mov    %ecx,(%eax)
  8002f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8002f7:	88 02                	mov    %al,(%edx)
}
  8002f9:	5d                   	pop    %ebp
  8002fa:	c3                   	ret    

008002fb <printfmt>:
{
  8002fb:	f3 0f 1e fb          	endbr32 
  8002ff:	55                   	push   %ebp
  800300:	89 e5                	mov    %esp,%ebp
  800302:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800305:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800308:	50                   	push   %eax
  800309:	ff 75 10             	pushl  0x10(%ebp)
  80030c:	ff 75 0c             	pushl  0xc(%ebp)
  80030f:	ff 75 08             	pushl  0x8(%ebp)
  800312:	e8 05 00 00 00       	call   80031c <vprintfmt>
}
  800317:	83 c4 10             	add    $0x10,%esp
  80031a:	c9                   	leave  
  80031b:	c3                   	ret    

0080031c <vprintfmt>:
{
  80031c:	f3 0f 1e fb          	endbr32 
  800320:	55                   	push   %ebp
  800321:	89 e5                	mov    %esp,%ebp
  800323:	57                   	push   %edi
  800324:	56                   	push   %esi
  800325:	53                   	push   %ebx
  800326:	83 ec 3c             	sub    $0x3c,%esp
  800329:	8b 75 08             	mov    0x8(%ebp),%esi
  80032c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80032f:	8b 7d 10             	mov    0x10(%ebp),%edi
  800332:	e9 cd 03 00 00       	jmp    800704 <vprintfmt+0x3e8>
		padc = ' ';
  800337:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  80033b:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800342:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800349:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800350:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800355:	8d 47 01             	lea    0x1(%edi),%eax
  800358:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80035b:	0f b6 17             	movzbl (%edi),%edx
  80035e:	8d 42 dd             	lea    -0x23(%edx),%eax
  800361:	3c 55                	cmp    $0x55,%al
  800363:	0f 87 1e 04 00 00    	ja     800787 <vprintfmt+0x46b>
  800369:	0f b6 c0             	movzbl %al,%eax
  80036c:	3e ff 24 85 c0 12 80 	notrack jmp *0x8012c0(,%eax,4)
  800373:	00 
  800374:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800377:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  80037b:	eb d8                	jmp    800355 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  80037d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800380:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  800384:	eb cf                	jmp    800355 <vprintfmt+0x39>
  800386:	0f b6 d2             	movzbl %dl,%edx
  800389:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  80038c:	b8 00 00 00 00       	mov    $0x0,%eax
  800391:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800394:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800397:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80039b:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80039e:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8003a1:	83 f9 09             	cmp    $0x9,%ecx
  8003a4:	77 55                	ja     8003fb <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  8003a6:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8003a9:	eb e9                	jmp    800394 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  8003ab:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ae:	8b 00                	mov    (%eax),%eax
  8003b0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b6:	8d 40 04             	lea    0x4(%eax),%eax
  8003b9:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003bc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8003bf:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003c3:	79 90                	jns    800355 <vprintfmt+0x39>
				width = precision, precision = -1;
  8003c5:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8003c8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003cb:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8003d2:	eb 81                	jmp    800355 <vprintfmt+0x39>
  8003d4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003d7:	85 c0                	test   %eax,%eax
  8003d9:	ba 00 00 00 00       	mov    $0x0,%edx
  8003de:	0f 49 d0             	cmovns %eax,%edx
  8003e1:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003e4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003e7:	e9 69 ff ff ff       	jmp    800355 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8003ec:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8003ef:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8003f6:	e9 5a ff ff ff       	jmp    800355 <vprintfmt+0x39>
  8003fb:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003fe:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800401:	eb bc                	jmp    8003bf <vprintfmt+0xa3>
			lflag++;
  800403:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800406:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800409:	e9 47 ff ff ff       	jmp    800355 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  80040e:	8b 45 14             	mov    0x14(%ebp),%eax
  800411:	8d 78 04             	lea    0x4(%eax),%edi
  800414:	83 ec 08             	sub    $0x8,%esp
  800417:	53                   	push   %ebx
  800418:	ff 30                	pushl  (%eax)
  80041a:	ff d6                	call   *%esi
			break;
  80041c:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  80041f:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800422:	e9 da 02 00 00       	jmp    800701 <vprintfmt+0x3e5>
			err = va_arg(ap, int);
  800427:	8b 45 14             	mov    0x14(%ebp),%eax
  80042a:	8d 78 04             	lea    0x4(%eax),%edi
  80042d:	8b 00                	mov    (%eax),%eax
  80042f:	99                   	cltd   
  800430:	31 d0                	xor    %edx,%eax
  800432:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800434:	83 f8 08             	cmp    $0x8,%eax
  800437:	7f 23                	jg     80045c <vprintfmt+0x140>
  800439:	8b 14 85 20 14 80 00 	mov    0x801420(,%eax,4),%edx
  800440:	85 d2                	test   %edx,%edx
  800442:	74 18                	je     80045c <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  800444:	52                   	push   %edx
  800445:	68 1c 12 80 00       	push   $0x80121c
  80044a:	53                   	push   %ebx
  80044b:	56                   	push   %esi
  80044c:	e8 aa fe ff ff       	call   8002fb <printfmt>
  800451:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800454:	89 7d 14             	mov    %edi,0x14(%ebp)
  800457:	e9 a5 02 00 00       	jmp    800701 <vprintfmt+0x3e5>
				printfmt(putch, putdat, "error %d", err);
  80045c:	50                   	push   %eax
  80045d:	68 13 12 80 00       	push   $0x801213
  800462:	53                   	push   %ebx
  800463:	56                   	push   %esi
  800464:	e8 92 fe ff ff       	call   8002fb <printfmt>
  800469:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80046c:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80046f:	e9 8d 02 00 00       	jmp    800701 <vprintfmt+0x3e5>
			if ((p = va_arg(ap, char *)) == NULL)
  800474:	8b 45 14             	mov    0x14(%ebp),%eax
  800477:	83 c0 04             	add    $0x4,%eax
  80047a:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80047d:	8b 45 14             	mov    0x14(%ebp),%eax
  800480:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  800482:	85 d2                	test   %edx,%edx
  800484:	b8 0c 12 80 00       	mov    $0x80120c,%eax
  800489:	0f 45 c2             	cmovne %edx,%eax
  80048c:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  80048f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800493:	7e 06                	jle    80049b <vprintfmt+0x17f>
  800495:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  800499:	75 0d                	jne    8004a8 <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  80049b:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80049e:	89 c7                	mov    %eax,%edi
  8004a0:	03 45 e0             	add    -0x20(%ebp),%eax
  8004a3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004a6:	eb 55                	jmp    8004fd <vprintfmt+0x1e1>
  8004a8:	83 ec 08             	sub    $0x8,%esp
  8004ab:	ff 75 d8             	pushl  -0x28(%ebp)
  8004ae:	ff 75 cc             	pushl  -0x34(%ebp)
  8004b1:	e8 85 03 00 00       	call   80083b <strnlen>
  8004b6:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8004b9:	29 c2                	sub    %eax,%edx
  8004bb:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  8004be:	83 c4 10             	add    $0x10,%esp
  8004c1:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  8004c3:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8004c7:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ca:	85 ff                	test   %edi,%edi
  8004cc:	7e 11                	jle    8004df <vprintfmt+0x1c3>
					putch(padc, putdat);
  8004ce:	83 ec 08             	sub    $0x8,%esp
  8004d1:	53                   	push   %ebx
  8004d2:	ff 75 e0             	pushl  -0x20(%ebp)
  8004d5:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8004d7:	83 ef 01             	sub    $0x1,%edi
  8004da:	83 c4 10             	add    $0x10,%esp
  8004dd:	eb eb                	jmp    8004ca <vprintfmt+0x1ae>
  8004df:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8004e2:	85 d2                	test   %edx,%edx
  8004e4:	b8 00 00 00 00       	mov    $0x0,%eax
  8004e9:	0f 49 c2             	cmovns %edx,%eax
  8004ec:	29 c2                	sub    %eax,%edx
  8004ee:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8004f1:	eb a8                	jmp    80049b <vprintfmt+0x17f>
					putch(ch, putdat);
  8004f3:	83 ec 08             	sub    $0x8,%esp
  8004f6:	53                   	push   %ebx
  8004f7:	52                   	push   %edx
  8004f8:	ff d6                	call   *%esi
  8004fa:	83 c4 10             	add    $0x10,%esp
  8004fd:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800500:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800502:	83 c7 01             	add    $0x1,%edi
  800505:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800509:	0f be d0             	movsbl %al,%edx
  80050c:	85 d2                	test   %edx,%edx
  80050e:	74 4b                	je     80055b <vprintfmt+0x23f>
  800510:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800514:	78 06                	js     80051c <vprintfmt+0x200>
  800516:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  80051a:	78 1e                	js     80053a <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
  80051c:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800520:	74 d1                	je     8004f3 <vprintfmt+0x1d7>
  800522:	0f be c0             	movsbl %al,%eax
  800525:	83 e8 20             	sub    $0x20,%eax
  800528:	83 f8 5e             	cmp    $0x5e,%eax
  80052b:	76 c6                	jbe    8004f3 <vprintfmt+0x1d7>
					putch('?', putdat);
  80052d:	83 ec 08             	sub    $0x8,%esp
  800530:	53                   	push   %ebx
  800531:	6a 3f                	push   $0x3f
  800533:	ff d6                	call   *%esi
  800535:	83 c4 10             	add    $0x10,%esp
  800538:	eb c3                	jmp    8004fd <vprintfmt+0x1e1>
  80053a:	89 cf                	mov    %ecx,%edi
  80053c:	eb 0e                	jmp    80054c <vprintfmt+0x230>
				putch(' ', putdat);
  80053e:	83 ec 08             	sub    $0x8,%esp
  800541:	53                   	push   %ebx
  800542:	6a 20                	push   $0x20
  800544:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800546:	83 ef 01             	sub    $0x1,%edi
  800549:	83 c4 10             	add    $0x10,%esp
  80054c:	85 ff                	test   %edi,%edi
  80054e:	7f ee                	jg     80053e <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  800550:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800553:	89 45 14             	mov    %eax,0x14(%ebp)
  800556:	e9 a6 01 00 00       	jmp    800701 <vprintfmt+0x3e5>
  80055b:	89 cf                	mov    %ecx,%edi
  80055d:	eb ed                	jmp    80054c <vprintfmt+0x230>
	if (lflag >= 2)
  80055f:	83 f9 01             	cmp    $0x1,%ecx
  800562:	7f 1f                	jg     800583 <vprintfmt+0x267>
	else if (lflag)
  800564:	85 c9                	test   %ecx,%ecx
  800566:	74 67                	je     8005cf <vprintfmt+0x2b3>
		return va_arg(*ap, long);
  800568:	8b 45 14             	mov    0x14(%ebp),%eax
  80056b:	8b 00                	mov    (%eax),%eax
  80056d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800570:	89 c1                	mov    %eax,%ecx
  800572:	c1 f9 1f             	sar    $0x1f,%ecx
  800575:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800578:	8b 45 14             	mov    0x14(%ebp),%eax
  80057b:	8d 40 04             	lea    0x4(%eax),%eax
  80057e:	89 45 14             	mov    %eax,0x14(%ebp)
  800581:	eb 17                	jmp    80059a <vprintfmt+0x27e>
		return va_arg(*ap, long long);
  800583:	8b 45 14             	mov    0x14(%ebp),%eax
  800586:	8b 50 04             	mov    0x4(%eax),%edx
  800589:	8b 00                	mov    (%eax),%eax
  80058b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80058e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800591:	8b 45 14             	mov    0x14(%ebp),%eax
  800594:	8d 40 08             	lea    0x8(%eax),%eax
  800597:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80059a:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80059d:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8005a0:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  8005a5:	85 c9                	test   %ecx,%ecx
  8005a7:	0f 89 3a 01 00 00    	jns    8006e7 <vprintfmt+0x3cb>
				putch('-', putdat);
  8005ad:	83 ec 08             	sub    $0x8,%esp
  8005b0:	53                   	push   %ebx
  8005b1:	6a 2d                	push   $0x2d
  8005b3:	ff d6                	call   *%esi
				num = -(long long) num;
  8005b5:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005b8:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005bb:	f7 da                	neg    %edx
  8005bd:	83 d1 00             	adc    $0x0,%ecx
  8005c0:	f7 d9                	neg    %ecx
  8005c2:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8005c5:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005ca:	e9 18 01 00 00       	jmp    8006e7 <vprintfmt+0x3cb>
		return va_arg(*ap, int);
  8005cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d2:	8b 00                	mov    (%eax),%eax
  8005d4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005d7:	89 c1                	mov    %eax,%ecx
  8005d9:	c1 f9 1f             	sar    $0x1f,%ecx
  8005dc:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005df:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e2:	8d 40 04             	lea    0x4(%eax),%eax
  8005e5:	89 45 14             	mov    %eax,0x14(%ebp)
  8005e8:	eb b0                	jmp    80059a <vprintfmt+0x27e>
	if (lflag >= 2)
  8005ea:	83 f9 01             	cmp    $0x1,%ecx
  8005ed:	7f 1e                	jg     80060d <vprintfmt+0x2f1>
	else if (lflag)
  8005ef:	85 c9                	test   %ecx,%ecx
  8005f1:	74 32                	je     800625 <vprintfmt+0x309>
		return va_arg(*ap, unsigned long);
  8005f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f6:	8b 10                	mov    (%eax),%edx
  8005f8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005fd:	8d 40 04             	lea    0x4(%eax),%eax
  800600:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800603:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  800608:	e9 da 00 00 00       	jmp    8006e7 <vprintfmt+0x3cb>
		return va_arg(*ap, unsigned long long);
  80060d:	8b 45 14             	mov    0x14(%ebp),%eax
  800610:	8b 10                	mov    (%eax),%edx
  800612:	8b 48 04             	mov    0x4(%eax),%ecx
  800615:	8d 40 08             	lea    0x8(%eax),%eax
  800618:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80061b:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  800620:	e9 c2 00 00 00       	jmp    8006e7 <vprintfmt+0x3cb>
		return va_arg(*ap, unsigned int);
  800625:	8b 45 14             	mov    0x14(%ebp),%eax
  800628:	8b 10                	mov    (%eax),%edx
  80062a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80062f:	8d 40 04             	lea    0x4(%eax),%eax
  800632:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800635:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  80063a:	e9 a8 00 00 00       	jmp    8006e7 <vprintfmt+0x3cb>
	if (lflag >= 2)
  80063f:	83 f9 01             	cmp    $0x1,%ecx
  800642:	7f 1b                	jg     80065f <vprintfmt+0x343>
	else if (lflag)
  800644:	85 c9                	test   %ecx,%ecx
  800646:	74 5c                	je     8006a4 <vprintfmt+0x388>
		return va_arg(*ap, long);
  800648:	8b 45 14             	mov    0x14(%ebp),%eax
  80064b:	8b 00                	mov    (%eax),%eax
  80064d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800650:	99                   	cltd   
  800651:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800654:	8b 45 14             	mov    0x14(%ebp),%eax
  800657:	8d 40 04             	lea    0x4(%eax),%eax
  80065a:	89 45 14             	mov    %eax,0x14(%ebp)
  80065d:	eb 17                	jmp    800676 <vprintfmt+0x35a>
		return va_arg(*ap, long long);
  80065f:	8b 45 14             	mov    0x14(%ebp),%eax
  800662:	8b 50 04             	mov    0x4(%eax),%edx
  800665:	8b 00                	mov    (%eax),%eax
  800667:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80066a:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80066d:	8b 45 14             	mov    0x14(%ebp),%eax
  800670:	8d 40 08             	lea    0x8(%eax),%eax
  800673:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800676:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800679:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 8;
  80067c:	b8 08 00 00 00       	mov    $0x8,%eax
			if ((long long) num < 0) {
  800681:	85 c9                	test   %ecx,%ecx
  800683:	79 62                	jns    8006e7 <vprintfmt+0x3cb>
				putch('-', putdat);
  800685:	83 ec 08             	sub    $0x8,%esp
  800688:	53                   	push   %ebx
  800689:	6a 2d                	push   $0x2d
  80068b:	ff d6                	call   *%esi
				num = -(long long) num;
  80068d:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800690:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800693:	f7 da                	neg    %edx
  800695:	83 d1 00             	adc    $0x0,%ecx
  800698:	f7 d9                	neg    %ecx
  80069a:	83 c4 10             	add    $0x10,%esp
			base = 8;
  80069d:	b8 08 00 00 00       	mov    $0x8,%eax
  8006a2:	eb 43                	jmp    8006e7 <vprintfmt+0x3cb>
		return va_arg(*ap, int);
  8006a4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a7:	8b 00                	mov    (%eax),%eax
  8006a9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006ac:	89 c1                	mov    %eax,%ecx
  8006ae:	c1 f9 1f             	sar    $0x1f,%ecx
  8006b1:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b7:	8d 40 04             	lea    0x4(%eax),%eax
  8006ba:	89 45 14             	mov    %eax,0x14(%ebp)
  8006bd:	eb b7                	jmp    800676 <vprintfmt+0x35a>
			putch('0', putdat);
  8006bf:	83 ec 08             	sub    $0x8,%esp
  8006c2:	53                   	push   %ebx
  8006c3:	6a 30                	push   $0x30
  8006c5:	ff d6                	call   *%esi
			putch('x', putdat);
  8006c7:	83 c4 08             	add    $0x8,%esp
  8006ca:	53                   	push   %ebx
  8006cb:	6a 78                	push   $0x78
  8006cd:	ff d6                	call   *%esi
			num = (unsigned long long)
  8006cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d2:	8b 10                	mov    (%eax),%edx
  8006d4:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8006d9:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8006dc:	8d 40 04             	lea    0x4(%eax),%eax
  8006df:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006e2:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  8006e7:	83 ec 0c             	sub    $0xc,%esp
  8006ea:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  8006ee:	57                   	push   %edi
  8006ef:	ff 75 e0             	pushl  -0x20(%ebp)
  8006f2:	50                   	push   %eax
  8006f3:	51                   	push   %ecx
  8006f4:	52                   	push   %edx
  8006f5:	89 da                	mov    %ebx,%edx
  8006f7:	89 f0                	mov    %esi,%eax
  8006f9:	e8 33 fb ff ff       	call   800231 <printnum>
			break;
  8006fe:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  800701:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800704:	83 c7 01             	add    $0x1,%edi
  800707:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80070b:	83 f8 25             	cmp    $0x25,%eax
  80070e:	0f 84 23 fc ff ff    	je     800337 <vprintfmt+0x1b>
			if (ch == '\0')
  800714:	85 c0                	test   %eax,%eax
  800716:	0f 84 8b 00 00 00    	je     8007a7 <vprintfmt+0x48b>
			putch(ch, putdat);
  80071c:	83 ec 08             	sub    $0x8,%esp
  80071f:	53                   	push   %ebx
  800720:	50                   	push   %eax
  800721:	ff d6                	call   *%esi
  800723:	83 c4 10             	add    $0x10,%esp
  800726:	eb dc                	jmp    800704 <vprintfmt+0x3e8>
	if (lflag >= 2)
  800728:	83 f9 01             	cmp    $0x1,%ecx
  80072b:	7f 1b                	jg     800748 <vprintfmt+0x42c>
	else if (lflag)
  80072d:	85 c9                	test   %ecx,%ecx
  80072f:	74 2c                	je     80075d <vprintfmt+0x441>
		return va_arg(*ap, unsigned long);
  800731:	8b 45 14             	mov    0x14(%ebp),%eax
  800734:	8b 10                	mov    (%eax),%edx
  800736:	b9 00 00 00 00       	mov    $0x0,%ecx
  80073b:	8d 40 04             	lea    0x4(%eax),%eax
  80073e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800741:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  800746:	eb 9f                	jmp    8006e7 <vprintfmt+0x3cb>
		return va_arg(*ap, unsigned long long);
  800748:	8b 45 14             	mov    0x14(%ebp),%eax
  80074b:	8b 10                	mov    (%eax),%edx
  80074d:	8b 48 04             	mov    0x4(%eax),%ecx
  800750:	8d 40 08             	lea    0x8(%eax),%eax
  800753:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800756:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  80075b:	eb 8a                	jmp    8006e7 <vprintfmt+0x3cb>
		return va_arg(*ap, unsigned int);
  80075d:	8b 45 14             	mov    0x14(%ebp),%eax
  800760:	8b 10                	mov    (%eax),%edx
  800762:	b9 00 00 00 00       	mov    $0x0,%ecx
  800767:	8d 40 04             	lea    0x4(%eax),%eax
  80076a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80076d:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  800772:	e9 70 ff ff ff       	jmp    8006e7 <vprintfmt+0x3cb>
			putch(ch, putdat);
  800777:	83 ec 08             	sub    $0x8,%esp
  80077a:	53                   	push   %ebx
  80077b:	6a 25                	push   $0x25
  80077d:	ff d6                	call   *%esi
			break;
  80077f:	83 c4 10             	add    $0x10,%esp
  800782:	e9 7a ff ff ff       	jmp    800701 <vprintfmt+0x3e5>
			putch('%', putdat);
  800787:	83 ec 08             	sub    $0x8,%esp
  80078a:	53                   	push   %ebx
  80078b:	6a 25                	push   $0x25
  80078d:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80078f:	83 c4 10             	add    $0x10,%esp
  800792:	89 f8                	mov    %edi,%eax
  800794:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800798:	74 05                	je     80079f <vprintfmt+0x483>
  80079a:	83 e8 01             	sub    $0x1,%eax
  80079d:	eb f5                	jmp    800794 <vprintfmt+0x478>
  80079f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8007a2:	e9 5a ff ff ff       	jmp    800701 <vprintfmt+0x3e5>
}
  8007a7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007aa:	5b                   	pop    %ebx
  8007ab:	5e                   	pop    %esi
  8007ac:	5f                   	pop    %edi
  8007ad:	5d                   	pop    %ebp
  8007ae:	c3                   	ret    

008007af <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007af:	f3 0f 1e fb          	endbr32 
  8007b3:	55                   	push   %ebp
  8007b4:	89 e5                	mov    %esp,%ebp
  8007b6:	83 ec 18             	sub    $0x18,%esp
  8007b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8007bc:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007bf:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007c2:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007c6:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007c9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007d0:	85 c0                	test   %eax,%eax
  8007d2:	74 26                	je     8007fa <vsnprintf+0x4b>
  8007d4:	85 d2                	test   %edx,%edx
  8007d6:	7e 22                	jle    8007fa <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007d8:	ff 75 14             	pushl  0x14(%ebp)
  8007db:	ff 75 10             	pushl  0x10(%ebp)
  8007de:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007e1:	50                   	push   %eax
  8007e2:	68 da 02 80 00       	push   $0x8002da
  8007e7:	e8 30 fb ff ff       	call   80031c <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007ec:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007ef:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007f5:	83 c4 10             	add    $0x10,%esp
}
  8007f8:	c9                   	leave  
  8007f9:	c3                   	ret    
		return -E_INVAL;
  8007fa:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007ff:	eb f7                	jmp    8007f8 <vsnprintf+0x49>

00800801 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800801:	f3 0f 1e fb          	endbr32 
  800805:	55                   	push   %ebp
  800806:	89 e5                	mov    %esp,%ebp
  800808:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80080b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80080e:	50                   	push   %eax
  80080f:	ff 75 10             	pushl  0x10(%ebp)
  800812:	ff 75 0c             	pushl  0xc(%ebp)
  800815:	ff 75 08             	pushl  0x8(%ebp)
  800818:	e8 92 ff ff ff       	call   8007af <vsnprintf>
	va_end(ap);

	return rc;
}
  80081d:	c9                   	leave  
  80081e:	c3                   	ret    

0080081f <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80081f:	f3 0f 1e fb          	endbr32 
  800823:	55                   	push   %ebp
  800824:	89 e5                	mov    %esp,%ebp
  800826:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800829:	b8 00 00 00 00       	mov    $0x0,%eax
  80082e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800832:	74 05                	je     800839 <strlen+0x1a>
		n++;
  800834:	83 c0 01             	add    $0x1,%eax
  800837:	eb f5                	jmp    80082e <strlen+0xf>
	return n;
}
  800839:	5d                   	pop    %ebp
  80083a:	c3                   	ret    

0080083b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80083b:	f3 0f 1e fb          	endbr32 
  80083f:	55                   	push   %ebp
  800840:	89 e5                	mov    %esp,%ebp
  800842:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800845:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800848:	b8 00 00 00 00       	mov    $0x0,%eax
  80084d:	39 d0                	cmp    %edx,%eax
  80084f:	74 0d                	je     80085e <strnlen+0x23>
  800851:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800855:	74 05                	je     80085c <strnlen+0x21>
		n++;
  800857:	83 c0 01             	add    $0x1,%eax
  80085a:	eb f1                	jmp    80084d <strnlen+0x12>
  80085c:	89 c2                	mov    %eax,%edx
	return n;
}
  80085e:	89 d0                	mov    %edx,%eax
  800860:	5d                   	pop    %ebp
  800861:	c3                   	ret    

00800862 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800862:	f3 0f 1e fb          	endbr32 
  800866:	55                   	push   %ebp
  800867:	89 e5                	mov    %esp,%ebp
  800869:	53                   	push   %ebx
  80086a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80086d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800870:	b8 00 00 00 00       	mov    $0x0,%eax
  800875:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800879:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  80087c:	83 c0 01             	add    $0x1,%eax
  80087f:	84 d2                	test   %dl,%dl
  800881:	75 f2                	jne    800875 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  800883:	89 c8                	mov    %ecx,%eax
  800885:	5b                   	pop    %ebx
  800886:	5d                   	pop    %ebp
  800887:	c3                   	ret    

00800888 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800888:	f3 0f 1e fb          	endbr32 
  80088c:	55                   	push   %ebp
  80088d:	89 e5                	mov    %esp,%ebp
  80088f:	53                   	push   %ebx
  800890:	83 ec 10             	sub    $0x10,%esp
  800893:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800896:	53                   	push   %ebx
  800897:	e8 83 ff ff ff       	call   80081f <strlen>
  80089c:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  80089f:	ff 75 0c             	pushl  0xc(%ebp)
  8008a2:	01 d8                	add    %ebx,%eax
  8008a4:	50                   	push   %eax
  8008a5:	e8 b8 ff ff ff       	call   800862 <strcpy>
	return dst;
}
  8008aa:	89 d8                	mov    %ebx,%eax
  8008ac:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008af:	c9                   	leave  
  8008b0:	c3                   	ret    

008008b1 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008b1:	f3 0f 1e fb          	endbr32 
  8008b5:	55                   	push   %ebp
  8008b6:	89 e5                	mov    %esp,%ebp
  8008b8:	56                   	push   %esi
  8008b9:	53                   	push   %ebx
  8008ba:	8b 75 08             	mov    0x8(%ebp),%esi
  8008bd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008c0:	89 f3                	mov    %esi,%ebx
  8008c2:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008c5:	89 f0                	mov    %esi,%eax
  8008c7:	39 d8                	cmp    %ebx,%eax
  8008c9:	74 11                	je     8008dc <strncpy+0x2b>
		*dst++ = *src;
  8008cb:	83 c0 01             	add    $0x1,%eax
  8008ce:	0f b6 0a             	movzbl (%edx),%ecx
  8008d1:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008d4:	80 f9 01             	cmp    $0x1,%cl
  8008d7:	83 da ff             	sbb    $0xffffffff,%edx
  8008da:	eb eb                	jmp    8008c7 <strncpy+0x16>
	}
	return ret;
}
  8008dc:	89 f0                	mov    %esi,%eax
  8008de:	5b                   	pop    %ebx
  8008df:	5e                   	pop    %esi
  8008e0:	5d                   	pop    %ebp
  8008e1:	c3                   	ret    

008008e2 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008e2:	f3 0f 1e fb          	endbr32 
  8008e6:	55                   	push   %ebp
  8008e7:	89 e5                	mov    %esp,%ebp
  8008e9:	56                   	push   %esi
  8008ea:	53                   	push   %ebx
  8008eb:	8b 75 08             	mov    0x8(%ebp),%esi
  8008ee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008f1:	8b 55 10             	mov    0x10(%ebp),%edx
  8008f4:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008f6:	85 d2                	test   %edx,%edx
  8008f8:	74 21                	je     80091b <strlcpy+0x39>
  8008fa:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8008fe:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  800900:	39 c2                	cmp    %eax,%edx
  800902:	74 14                	je     800918 <strlcpy+0x36>
  800904:	0f b6 19             	movzbl (%ecx),%ebx
  800907:	84 db                	test   %bl,%bl
  800909:	74 0b                	je     800916 <strlcpy+0x34>
			*dst++ = *src++;
  80090b:	83 c1 01             	add    $0x1,%ecx
  80090e:	83 c2 01             	add    $0x1,%edx
  800911:	88 5a ff             	mov    %bl,-0x1(%edx)
  800914:	eb ea                	jmp    800900 <strlcpy+0x1e>
  800916:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800918:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80091b:	29 f0                	sub    %esi,%eax
}
  80091d:	5b                   	pop    %ebx
  80091e:	5e                   	pop    %esi
  80091f:	5d                   	pop    %ebp
  800920:	c3                   	ret    

00800921 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800921:	f3 0f 1e fb          	endbr32 
  800925:	55                   	push   %ebp
  800926:	89 e5                	mov    %esp,%ebp
  800928:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80092b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80092e:	0f b6 01             	movzbl (%ecx),%eax
  800931:	84 c0                	test   %al,%al
  800933:	74 0c                	je     800941 <strcmp+0x20>
  800935:	3a 02                	cmp    (%edx),%al
  800937:	75 08                	jne    800941 <strcmp+0x20>
		p++, q++;
  800939:	83 c1 01             	add    $0x1,%ecx
  80093c:	83 c2 01             	add    $0x1,%edx
  80093f:	eb ed                	jmp    80092e <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800941:	0f b6 c0             	movzbl %al,%eax
  800944:	0f b6 12             	movzbl (%edx),%edx
  800947:	29 d0                	sub    %edx,%eax
}
  800949:	5d                   	pop    %ebp
  80094a:	c3                   	ret    

0080094b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80094b:	f3 0f 1e fb          	endbr32 
  80094f:	55                   	push   %ebp
  800950:	89 e5                	mov    %esp,%ebp
  800952:	53                   	push   %ebx
  800953:	8b 45 08             	mov    0x8(%ebp),%eax
  800956:	8b 55 0c             	mov    0xc(%ebp),%edx
  800959:	89 c3                	mov    %eax,%ebx
  80095b:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80095e:	eb 06                	jmp    800966 <strncmp+0x1b>
		n--, p++, q++;
  800960:	83 c0 01             	add    $0x1,%eax
  800963:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800966:	39 d8                	cmp    %ebx,%eax
  800968:	74 16                	je     800980 <strncmp+0x35>
  80096a:	0f b6 08             	movzbl (%eax),%ecx
  80096d:	84 c9                	test   %cl,%cl
  80096f:	74 04                	je     800975 <strncmp+0x2a>
  800971:	3a 0a                	cmp    (%edx),%cl
  800973:	74 eb                	je     800960 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800975:	0f b6 00             	movzbl (%eax),%eax
  800978:	0f b6 12             	movzbl (%edx),%edx
  80097b:	29 d0                	sub    %edx,%eax
}
  80097d:	5b                   	pop    %ebx
  80097e:	5d                   	pop    %ebp
  80097f:	c3                   	ret    
		return 0;
  800980:	b8 00 00 00 00       	mov    $0x0,%eax
  800985:	eb f6                	jmp    80097d <strncmp+0x32>

00800987 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800987:	f3 0f 1e fb          	endbr32 
  80098b:	55                   	push   %ebp
  80098c:	89 e5                	mov    %esp,%ebp
  80098e:	8b 45 08             	mov    0x8(%ebp),%eax
  800991:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800995:	0f b6 10             	movzbl (%eax),%edx
  800998:	84 d2                	test   %dl,%dl
  80099a:	74 09                	je     8009a5 <strchr+0x1e>
		if (*s == c)
  80099c:	38 ca                	cmp    %cl,%dl
  80099e:	74 0a                	je     8009aa <strchr+0x23>
	for (; *s; s++)
  8009a0:	83 c0 01             	add    $0x1,%eax
  8009a3:	eb f0                	jmp    800995 <strchr+0xe>
			return (char *) s;
	return 0;
  8009a5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009aa:	5d                   	pop    %ebp
  8009ab:	c3                   	ret    

008009ac <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009ac:	f3 0f 1e fb          	endbr32 
  8009b0:	55                   	push   %ebp
  8009b1:	89 e5                	mov    %esp,%ebp
  8009b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b6:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009ba:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8009bd:	38 ca                	cmp    %cl,%dl
  8009bf:	74 09                	je     8009ca <strfind+0x1e>
  8009c1:	84 d2                	test   %dl,%dl
  8009c3:	74 05                	je     8009ca <strfind+0x1e>
	for (; *s; s++)
  8009c5:	83 c0 01             	add    $0x1,%eax
  8009c8:	eb f0                	jmp    8009ba <strfind+0xe>
			break;
	return (char *) s;
}
  8009ca:	5d                   	pop    %ebp
  8009cb:	c3                   	ret    

008009cc <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009cc:	f3 0f 1e fb          	endbr32 
  8009d0:	55                   	push   %ebp
  8009d1:	89 e5                	mov    %esp,%ebp
  8009d3:	57                   	push   %edi
  8009d4:	56                   	push   %esi
  8009d5:	53                   	push   %ebx
  8009d6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009d9:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009dc:	85 c9                	test   %ecx,%ecx
  8009de:	74 31                	je     800a11 <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009e0:	89 f8                	mov    %edi,%eax
  8009e2:	09 c8                	or     %ecx,%eax
  8009e4:	a8 03                	test   $0x3,%al
  8009e6:	75 23                	jne    800a0b <memset+0x3f>
		c &= 0xFF;
  8009e8:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009ec:	89 d3                	mov    %edx,%ebx
  8009ee:	c1 e3 08             	shl    $0x8,%ebx
  8009f1:	89 d0                	mov    %edx,%eax
  8009f3:	c1 e0 18             	shl    $0x18,%eax
  8009f6:	89 d6                	mov    %edx,%esi
  8009f8:	c1 e6 10             	shl    $0x10,%esi
  8009fb:	09 f0                	or     %esi,%eax
  8009fd:	09 c2                	or     %eax,%edx
  8009ff:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a01:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800a04:	89 d0                	mov    %edx,%eax
  800a06:	fc                   	cld    
  800a07:	f3 ab                	rep stos %eax,%es:(%edi)
  800a09:	eb 06                	jmp    800a11 <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a0b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a0e:	fc                   	cld    
  800a0f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a11:	89 f8                	mov    %edi,%eax
  800a13:	5b                   	pop    %ebx
  800a14:	5e                   	pop    %esi
  800a15:	5f                   	pop    %edi
  800a16:	5d                   	pop    %ebp
  800a17:	c3                   	ret    

00800a18 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a18:	f3 0f 1e fb          	endbr32 
  800a1c:	55                   	push   %ebp
  800a1d:	89 e5                	mov    %esp,%ebp
  800a1f:	57                   	push   %edi
  800a20:	56                   	push   %esi
  800a21:	8b 45 08             	mov    0x8(%ebp),%eax
  800a24:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a27:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a2a:	39 c6                	cmp    %eax,%esi
  800a2c:	73 32                	jae    800a60 <memmove+0x48>
  800a2e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a31:	39 c2                	cmp    %eax,%edx
  800a33:	76 2b                	jbe    800a60 <memmove+0x48>
		s += n;
		d += n;
  800a35:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a38:	89 fe                	mov    %edi,%esi
  800a3a:	09 ce                	or     %ecx,%esi
  800a3c:	09 d6                	or     %edx,%esi
  800a3e:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a44:	75 0e                	jne    800a54 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a46:	83 ef 04             	sub    $0x4,%edi
  800a49:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a4c:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800a4f:	fd                   	std    
  800a50:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a52:	eb 09                	jmp    800a5d <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a54:	83 ef 01             	sub    $0x1,%edi
  800a57:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800a5a:	fd                   	std    
  800a5b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a5d:	fc                   	cld    
  800a5e:	eb 1a                	jmp    800a7a <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a60:	89 c2                	mov    %eax,%edx
  800a62:	09 ca                	or     %ecx,%edx
  800a64:	09 f2                	or     %esi,%edx
  800a66:	f6 c2 03             	test   $0x3,%dl
  800a69:	75 0a                	jne    800a75 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a6b:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800a6e:	89 c7                	mov    %eax,%edi
  800a70:	fc                   	cld    
  800a71:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a73:	eb 05                	jmp    800a7a <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800a75:	89 c7                	mov    %eax,%edi
  800a77:	fc                   	cld    
  800a78:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a7a:	5e                   	pop    %esi
  800a7b:	5f                   	pop    %edi
  800a7c:	5d                   	pop    %ebp
  800a7d:	c3                   	ret    

00800a7e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a7e:	f3 0f 1e fb          	endbr32 
  800a82:	55                   	push   %ebp
  800a83:	89 e5                	mov    %esp,%ebp
  800a85:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a88:	ff 75 10             	pushl  0x10(%ebp)
  800a8b:	ff 75 0c             	pushl  0xc(%ebp)
  800a8e:	ff 75 08             	pushl  0x8(%ebp)
  800a91:	e8 82 ff ff ff       	call   800a18 <memmove>
}
  800a96:	c9                   	leave  
  800a97:	c3                   	ret    

00800a98 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a98:	f3 0f 1e fb          	endbr32 
  800a9c:	55                   	push   %ebp
  800a9d:	89 e5                	mov    %esp,%ebp
  800a9f:	56                   	push   %esi
  800aa0:	53                   	push   %ebx
  800aa1:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa4:	8b 55 0c             	mov    0xc(%ebp),%edx
  800aa7:	89 c6                	mov    %eax,%esi
  800aa9:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800aac:	39 f0                	cmp    %esi,%eax
  800aae:	74 1c                	je     800acc <memcmp+0x34>
		if (*s1 != *s2)
  800ab0:	0f b6 08             	movzbl (%eax),%ecx
  800ab3:	0f b6 1a             	movzbl (%edx),%ebx
  800ab6:	38 d9                	cmp    %bl,%cl
  800ab8:	75 08                	jne    800ac2 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800aba:	83 c0 01             	add    $0x1,%eax
  800abd:	83 c2 01             	add    $0x1,%edx
  800ac0:	eb ea                	jmp    800aac <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800ac2:	0f b6 c1             	movzbl %cl,%eax
  800ac5:	0f b6 db             	movzbl %bl,%ebx
  800ac8:	29 d8                	sub    %ebx,%eax
  800aca:	eb 05                	jmp    800ad1 <memcmp+0x39>
	}

	return 0;
  800acc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ad1:	5b                   	pop    %ebx
  800ad2:	5e                   	pop    %esi
  800ad3:	5d                   	pop    %ebp
  800ad4:	c3                   	ret    

00800ad5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ad5:	f3 0f 1e fb          	endbr32 
  800ad9:	55                   	push   %ebp
  800ada:	89 e5                	mov    %esp,%ebp
  800adc:	8b 45 08             	mov    0x8(%ebp),%eax
  800adf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800ae2:	89 c2                	mov    %eax,%edx
  800ae4:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800ae7:	39 d0                	cmp    %edx,%eax
  800ae9:	73 09                	jae    800af4 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800aeb:	38 08                	cmp    %cl,(%eax)
  800aed:	74 05                	je     800af4 <memfind+0x1f>
	for (; s < ends; s++)
  800aef:	83 c0 01             	add    $0x1,%eax
  800af2:	eb f3                	jmp    800ae7 <memfind+0x12>
			break;
	return (void *) s;
}
  800af4:	5d                   	pop    %ebp
  800af5:	c3                   	ret    

00800af6 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800af6:	f3 0f 1e fb          	endbr32 
  800afa:	55                   	push   %ebp
  800afb:	89 e5                	mov    %esp,%ebp
  800afd:	57                   	push   %edi
  800afe:	56                   	push   %esi
  800aff:	53                   	push   %ebx
  800b00:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b03:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b06:	eb 03                	jmp    800b0b <strtol+0x15>
		s++;
  800b08:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800b0b:	0f b6 01             	movzbl (%ecx),%eax
  800b0e:	3c 20                	cmp    $0x20,%al
  800b10:	74 f6                	je     800b08 <strtol+0x12>
  800b12:	3c 09                	cmp    $0x9,%al
  800b14:	74 f2                	je     800b08 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800b16:	3c 2b                	cmp    $0x2b,%al
  800b18:	74 2a                	je     800b44 <strtol+0x4e>
	int neg = 0;
  800b1a:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800b1f:	3c 2d                	cmp    $0x2d,%al
  800b21:	74 2b                	je     800b4e <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b23:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b29:	75 0f                	jne    800b3a <strtol+0x44>
  800b2b:	80 39 30             	cmpb   $0x30,(%ecx)
  800b2e:	74 28                	je     800b58 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b30:	85 db                	test   %ebx,%ebx
  800b32:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b37:	0f 44 d8             	cmove  %eax,%ebx
  800b3a:	b8 00 00 00 00       	mov    $0x0,%eax
  800b3f:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800b42:	eb 46                	jmp    800b8a <strtol+0x94>
		s++;
  800b44:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800b47:	bf 00 00 00 00       	mov    $0x0,%edi
  800b4c:	eb d5                	jmp    800b23 <strtol+0x2d>
		s++, neg = 1;
  800b4e:	83 c1 01             	add    $0x1,%ecx
  800b51:	bf 01 00 00 00       	mov    $0x1,%edi
  800b56:	eb cb                	jmp    800b23 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b58:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b5c:	74 0e                	je     800b6c <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800b5e:	85 db                	test   %ebx,%ebx
  800b60:	75 d8                	jne    800b3a <strtol+0x44>
		s++, base = 8;
  800b62:	83 c1 01             	add    $0x1,%ecx
  800b65:	bb 08 00 00 00       	mov    $0x8,%ebx
  800b6a:	eb ce                	jmp    800b3a <strtol+0x44>
		s += 2, base = 16;
  800b6c:	83 c1 02             	add    $0x2,%ecx
  800b6f:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b74:	eb c4                	jmp    800b3a <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800b76:	0f be d2             	movsbl %dl,%edx
  800b79:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b7c:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b7f:	7d 3a                	jge    800bbb <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800b81:	83 c1 01             	add    $0x1,%ecx
  800b84:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b88:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800b8a:	0f b6 11             	movzbl (%ecx),%edx
  800b8d:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b90:	89 f3                	mov    %esi,%ebx
  800b92:	80 fb 09             	cmp    $0x9,%bl
  800b95:	76 df                	jbe    800b76 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800b97:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b9a:	89 f3                	mov    %esi,%ebx
  800b9c:	80 fb 19             	cmp    $0x19,%bl
  800b9f:	77 08                	ja     800ba9 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800ba1:	0f be d2             	movsbl %dl,%edx
  800ba4:	83 ea 57             	sub    $0x57,%edx
  800ba7:	eb d3                	jmp    800b7c <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800ba9:	8d 72 bf             	lea    -0x41(%edx),%esi
  800bac:	89 f3                	mov    %esi,%ebx
  800bae:	80 fb 19             	cmp    $0x19,%bl
  800bb1:	77 08                	ja     800bbb <strtol+0xc5>
			dig = *s - 'A' + 10;
  800bb3:	0f be d2             	movsbl %dl,%edx
  800bb6:	83 ea 37             	sub    $0x37,%edx
  800bb9:	eb c1                	jmp    800b7c <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800bbb:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bbf:	74 05                	je     800bc6 <strtol+0xd0>
		*endptr = (char *) s;
  800bc1:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bc4:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800bc6:	89 c2                	mov    %eax,%edx
  800bc8:	f7 da                	neg    %edx
  800bca:	85 ff                	test   %edi,%edi
  800bcc:	0f 45 c2             	cmovne %edx,%eax
}
  800bcf:	5b                   	pop    %ebx
  800bd0:	5e                   	pop    %esi
  800bd1:	5f                   	pop    %edi
  800bd2:	5d                   	pop    %ebp
  800bd3:	c3                   	ret    

00800bd4 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800bd4:	f3 0f 1e fb          	endbr32 
  800bd8:	55                   	push   %ebp
  800bd9:	89 e5                	mov    %esp,%ebp
  800bdb:	57                   	push   %edi
  800bdc:	56                   	push   %esi
  800bdd:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bde:	b8 00 00 00 00       	mov    $0x0,%eax
  800be3:	8b 55 08             	mov    0x8(%ebp),%edx
  800be6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800be9:	89 c3                	mov    %eax,%ebx
  800beb:	89 c7                	mov    %eax,%edi
  800bed:	89 c6                	mov    %eax,%esi
  800bef:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bf1:	5b                   	pop    %ebx
  800bf2:	5e                   	pop    %esi
  800bf3:	5f                   	pop    %edi
  800bf4:	5d                   	pop    %ebp
  800bf5:	c3                   	ret    

00800bf6 <sys_cgetc>:

int
sys_cgetc(void)
{
  800bf6:	f3 0f 1e fb          	endbr32 
  800bfa:	55                   	push   %ebp
  800bfb:	89 e5                	mov    %esp,%ebp
  800bfd:	57                   	push   %edi
  800bfe:	56                   	push   %esi
  800bff:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c00:	ba 00 00 00 00       	mov    $0x0,%edx
  800c05:	b8 01 00 00 00       	mov    $0x1,%eax
  800c0a:	89 d1                	mov    %edx,%ecx
  800c0c:	89 d3                	mov    %edx,%ebx
  800c0e:	89 d7                	mov    %edx,%edi
  800c10:	89 d6                	mov    %edx,%esi
  800c12:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c14:	5b                   	pop    %ebx
  800c15:	5e                   	pop    %esi
  800c16:	5f                   	pop    %edi
  800c17:	5d                   	pop    %ebp
  800c18:	c3                   	ret    

00800c19 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c19:	f3 0f 1e fb          	endbr32 
  800c1d:	55                   	push   %ebp
  800c1e:	89 e5                	mov    %esp,%ebp
  800c20:	57                   	push   %edi
  800c21:	56                   	push   %esi
  800c22:	53                   	push   %ebx
  800c23:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c26:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c2b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c2e:	b8 03 00 00 00       	mov    $0x3,%eax
  800c33:	89 cb                	mov    %ecx,%ebx
  800c35:	89 cf                	mov    %ecx,%edi
  800c37:	89 ce                	mov    %ecx,%esi
  800c39:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c3b:	85 c0                	test   %eax,%eax
  800c3d:	7f 08                	jg     800c47 <sys_env_destroy+0x2e>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c3f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c42:	5b                   	pop    %ebx
  800c43:	5e                   	pop    %esi
  800c44:	5f                   	pop    %edi
  800c45:	5d                   	pop    %ebp
  800c46:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c47:	83 ec 0c             	sub    $0xc,%esp
  800c4a:	50                   	push   %eax
  800c4b:	6a 03                	push   $0x3
  800c4d:	68 44 14 80 00       	push   $0x801444
  800c52:	6a 23                	push   $0x23
  800c54:	68 61 14 80 00       	push   $0x801461
  800c59:	e8 d4 f4 ff ff       	call   800132 <_panic>

00800c5e <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c5e:	f3 0f 1e fb          	endbr32 
  800c62:	55                   	push   %ebp
  800c63:	89 e5                	mov    %esp,%ebp
  800c65:	57                   	push   %edi
  800c66:	56                   	push   %esi
  800c67:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c68:	ba 00 00 00 00       	mov    $0x0,%edx
  800c6d:	b8 02 00 00 00       	mov    $0x2,%eax
  800c72:	89 d1                	mov    %edx,%ecx
  800c74:	89 d3                	mov    %edx,%ebx
  800c76:	89 d7                	mov    %edx,%edi
  800c78:	89 d6                	mov    %edx,%esi
  800c7a:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c7c:	5b                   	pop    %ebx
  800c7d:	5e                   	pop    %esi
  800c7e:	5f                   	pop    %edi
  800c7f:	5d                   	pop    %ebp
  800c80:	c3                   	ret    

00800c81 <sys_yield>:

void
sys_yield(void)
{
  800c81:	f3 0f 1e fb          	endbr32 
  800c85:	55                   	push   %ebp
  800c86:	89 e5                	mov    %esp,%ebp
  800c88:	57                   	push   %edi
  800c89:	56                   	push   %esi
  800c8a:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c8b:	ba 00 00 00 00       	mov    $0x0,%edx
  800c90:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c95:	89 d1                	mov    %edx,%ecx
  800c97:	89 d3                	mov    %edx,%ebx
  800c99:	89 d7                	mov    %edx,%edi
  800c9b:	89 d6                	mov    %edx,%esi
  800c9d:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c9f:	5b                   	pop    %ebx
  800ca0:	5e                   	pop    %esi
  800ca1:	5f                   	pop    %edi
  800ca2:	5d                   	pop    %ebp
  800ca3:	c3                   	ret    

00800ca4 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800ca4:	f3 0f 1e fb          	endbr32 
  800ca8:	55                   	push   %ebp
  800ca9:	89 e5                	mov    %esp,%ebp
  800cab:	57                   	push   %edi
  800cac:	56                   	push   %esi
  800cad:	53                   	push   %ebx
  800cae:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cb1:	be 00 00 00 00       	mov    $0x0,%esi
  800cb6:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cbc:	b8 04 00 00 00       	mov    $0x4,%eax
  800cc1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cc4:	89 f7                	mov    %esi,%edi
  800cc6:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cc8:	85 c0                	test   %eax,%eax
  800cca:	7f 08                	jg     800cd4 <sys_page_alloc+0x30>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800ccc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ccf:	5b                   	pop    %ebx
  800cd0:	5e                   	pop    %esi
  800cd1:	5f                   	pop    %edi
  800cd2:	5d                   	pop    %ebp
  800cd3:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cd4:	83 ec 0c             	sub    $0xc,%esp
  800cd7:	50                   	push   %eax
  800cd8:	6a 04                	push   $0x4
  800cda:	68 44 14 80 00       	push   $0x801444
  800cdf:	6a 23                	push   $0x23
  800ce1:	68 61 14 80 00       	push   $0x801461
  800ce6:	e8 47 f4 ff ff       	call   800132 <_panic>

00800ceb <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ceb:	f3 0f 1e fb          	endbr32 
  800cef:	55                   	push   %ebp
  800cf0:	89 e5                	mov    %esp,%ebp
  800cf2:	57                   	push   %edi
  800cf3:	56                   	push   %esi
  800cf4:	53                   	push   %ebx
  800cf5:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cf8:	8b 55 08             	mov    0x8(%ebp),%edx
  800cfb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cfe:	b8 05 00 00 00       	mov    $0x5,%eax
  800d03:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d06:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d09:	8b 75 18             	mov    0x18(%ebp),%esi
  800d0c:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d0e:	85 c0                	test   %eax,%eax
  800d10:	7f 08                	jg     800d1a <sys_page_map+0x2f>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d12:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d15:	5b                   	pop    %ebx
  800d16:	5e                   	pop    %esi
  800d17:	5f                   	pop    %edi
  800d18:	5d                   	pop    %ebp
  800d19:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d1a:	83 ec 0c             	sub    $0xc,%esp
  800d1d:	50                   	push   %eax
  800d1e:	6a 05                	push   $0x5
  800d20:	68 44 14 80 00       	push   $0x801444
  800d25:	6a 23                	push   $0x23
  800d27:	68 61 14 80 00       	push   $0x801461
  800d2c:	e8 01 f4 ff ff       	call   800132 <_panic>

00800d31 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d31:	f3 0f 1e fb          	endbr32 
  800d35:	55                   	push   %ebp
  800d36:	89 e5                	mov    %esp,%ebp
  800d38:	57                   	push   %edi
  800d39:	56                   	push   %esi
  800d3a:	53                   	push   %ebx
  800d3b:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d3e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d43:	8b 55 08             	mov    0x8(%ebp),%edx
  800d46:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d49:	b8 06 00 00 00       	mov    $0x6,%eax
  800d4e:	89 df                	mov    %ebx,%edi
  800d50:	89 de                	mov    %ebx,%esi
  800d52:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d54:	85 c0                	test   %eax,%eax
  800d56:	7f 08                	jg     800d60 <sys_page_unmap+0x2f>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d58:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d5b:	5b                   	pop    %ebx
  800d5c:	5e                   	pop    %esi
  800d5d:	5f                   	pop    %edi
  800d5e:	5d                   	pop    %ebp
  800d5f:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d60:	83 ec 0c             	sub    $0xc,%esp
  800d63:	50                   	push   %eax
  800d64:	6a 06                	push   $0x6
  800d66:	68 44 14 80 00       	push   $0x801444
  800d6b:	6a 23                	push   $0x23
  800d6d:	68 61 14 80 00       	push   $0x801461
  800d72:	e8 bb f3 ff ff       	call   800132 <_panic>

00800d77 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d77:	f3 0f 1e fb          	endbr32 
  800d7b:	55                   	push   %ebp
  800d7c:	89 e5                	mov    %esp,%ebp
  800d7e:	57                   	push   %edi
  800d7f:	56                   	push   %esi
  800d80:	53                   	push   %ebx
  800d81:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d84:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d89:	8b 55 08             	mov    0x8(%ebp),%edx
  800d8c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d8f:	b8 08 00 00 00       	mov    $0x8,%eax
  800d94:	89 df                	mov    %ebx,%edi
  800d96:	89 de                	mov    %ebx,%esi
  800d98:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d9a:	85 c0                	test   %eax,%eax
  800d9c:	7f 08                	jg     800da6 <sys_env_set_status+0x2f>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d9e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800da1:	5b                   	pop    %ebx
  800da2:	5e                   	pop    %esi
  800da3:	5f                   	pop    %edi
  800da4:	5d                   	pop    %ebp
  800da5:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800da6:	83 ec 0c             	sub    $0xc,%esp
  800da9:	50                   	push   %eax
  800daa:	6a 08                	push   $0x8
  800dac:	68 44 14 80 00       	push   $0x801444
  800db1:	6a 23                	push   $0x23
  800db3:	68 61 14 80 00       	push   $0x801461
  800db8:	e8 75 f3 ff ff       	call   800132 <_panic>

00800dbd <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800dbd:	f3 0f 1e fb          	endbr32 
  800dc1:	55                   	push   %ebp
  800dc2:	89 e5                	mov    %esp,%ebp
  800dc4:	57                   	push   %edi
  800dc5:	56                   	push   %esi
  800dc6:	53                   	push   %ebx
  800dc7:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800dca:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dcf:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dd5:	b8 09 00 00 00       	mov    $0x9,%eax
  800dda:	89 df                	mov    %ebx,%edi
  800ddc:	89 de                	mov    %ebx,%esi
  800dde:	cd 30                	int    $0x30
	if(check && ret > 0)
  800de0:	85 c0                	test   %eax,%eax
  800de2:	7f 08                	jg     800dec <sys_env_set_pgfault_upcall+0x2f>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800de4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800de7:	5b                   	pop    %ebx
  800de8:	5e                   	pop    %esi
  800de9:	5f                   	pop    %edi
  800dea:	5d                   	pop    %ebp
  800deb:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800dec:	83 ec 0c             	sub    $0xc,%esp
  800def:	50                   	push   %eax
  800df0:	6a 09                	push   $0x9
  800df2:	68 44 14 80 00       	push   $0x801444
  800df7:	6a 23                	push   $0x23
  800df9:	68 61 14 80 00       	push   $0x801461
  800dfe:	e8 2f f3 ff ff       	call   800132 <_panic>

00800e03 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e03:	f3 0f 1e fb          	endbr32 
  800e07:	55                   	push   %ebp
  800e08:	89 e5                	mov    %esp,%ebp
  800e0a:	57                   	push   %edi
  800e0b:	56                   	push   %esi
  800e0c:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e0d:	8b 55 08             	mov    0x8(%ebp),%edx
  800e10:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e13:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e18:	be 00 00 00 00       	mov    $0x0,%esi
  800e1d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e20:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e23:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e25:	5b                   	pop    %ebx
  800e26:	5e                   	pop    %esi
  800e27:	5f                   	pop    %edi
  800e28:	5d                   	pop    %ebp
  800e29:	c3                   	ret    

00800e2a <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e2a:	f3 0f 1e fb          	endbr32 
  800e2e:	55                   	push   %ebp
  800e2f:	89 e5                	mov    %esp,%ebp
  800e31:	57                   	push   %edi
  800e32:	56                   	push   %esi
  800e33:	53                   	push   %ebx
  800e34:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e37:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e3c:	8b 55 08             	mov    0x8(%ebp),%edx
  800e3f:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e44:	89 cb                	mov    %ecx,%ebx
  800e46:	89 cf                	mov    %ecx,%edi
  800e48:	89 ce                	mov    %ecx,%esi
  800e4a:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e4c:	85 c0                	test   %eax,%eax
  800e4e:	7f 08                	jg     800e58 <sys_ipc_recv+0x2e>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e50:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e53:	5b                   	pop    %ebx
  800e54:	5e                   	pop    %esi
  800e55:	5f                   	pop    %edi
  800e56:	5d                   	pop    %ebp
  800e57:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e58:	83 ec 0c             	sub    $0xc,%esp
  800e5b:	50                   	push   %eax
  800e5c:	6a 0c                	push   $0xc
  800e5e:	68 44 14 80 00       	push   $0x801444
  800e63:	6a 23                	push   $0x23
  800e65:	68 61 14 80 00       	push   $0x801461
  800e6a:	e8 c3 f2 ff ff       	call   800132 <_panic>

00800e6f <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800e6f:	f3 0f 1e fb          	endbr32 
  800e73:	55                   	push   %ebp
  800e74:	89 e5                	mov    %esp,%ebp
  800e76:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  800e79:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  800e80:	74 0a                	je     800e8c <set_pgfault_handler+0x1d>
        sys_env_set_pgfault_upcall(0, _pgfault_upcall);
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800e82:	8b 45 08             	mov    0x8(%ebp),%eax
  800e85:	a3 08 20 80 00       	mov    %eax,0x802008
}
  800e8a:	c9                   	leave  
  800e8b:	c3                   	ret    
		if (sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P) < 0)
  800e8c:	83 ec 04             	sub    $0x4,%esp
  800e8f:	6a 07                	push   $0x7
  800e91:	68 00 f0 bf ee       	push   $0xeebff000
  800e96:	6a 00                	push   $0x0
  800e98:	e8 07 fe ff ff       	call   800ca4 <sys_page_alloc>
  800e9d:	83 c4 10             	add    $0x10,%esp
  800ea0:	85 c0                	test   %eax,%eax
  800ea2:	78 14                	js     800eb8 <set_pgfault_handler+0x49>
        sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  800ea4:	83 ec 08             	sub    $0x8,%esp
  800ea7:	68 cc 0e 80 00       	push   $0x800ecc
  800eac:	6a 00                	push   $0x0
  800eae:	e8 0a ff ff ff       	call   800dbd <sys_env_set_pgfault_upcall>
  800eb3:	83 c4 10             	add    $0x10,%esp
  800eb6:	eb ca                	jmp    800e82 <set_pgfault_handler+0x13>
            panic("set_pgfault_handler failed.");
  800eb8:	83 ec 04             	sub    $0x4,%esp
  800ebb:	68 6f 14 80 00       	push   $0x80146f
  800ec0:	6a 21                	push   $0x21
  800ec2:	68 8b 14 80 00       	push   $0x80148b
  800ec7:	e8 66 f2 ff ff       	call   800132 <_panic>

00800ecc <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800ecc:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800ecd:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  800ed2:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800ed4:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	addl $8, %esp
  800ed7:	83 c4 08             	add    $0x8,%esp
	movl 32(%esp), %eax
  800eda:	8b 44 24 20          	mov    0x20(%esp),%eax
	movl 40(%esp), %edx
  800ede:	8b 54 24 28          	mov    0x28(%esp),%edx
	subl $4, %edx
  800ee2:	83 ea 04             	sub    $0x4,%edx
	movl %eax, (%edx)
  800ee5:	89 02                	mov    %eax,(%edx)
	movl %edx, 40(%esp)
  800ee7:	89 54 24 28          	mov    %edx,0x28(%esp)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal
  800eeb:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp
  800eec:	83 c4 04             	add    $0x4,%esp
	popfl
  800eef:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  800ef0:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  800ef1:	c3                   	ret    
  800ef2:	66 90                	xchg   %ax,%ax
  800ef4:	66 90                	xchg   %ax,%ax
  800ef6:	66 90                	xchg   %ax,%ax
  800ef8:	66 90                	xchg   %ax,%ax
  800efa:	66 90                	xchg   %ax,%ax
  800efc:	66 90                	xchg   %ax,%ax
  800efe:	66 90                	xchg   %ax,%ax

00800f00 <__udivdi3>:
  800f00:	f3 0f 1e fb          	endbr32 
  800f04:	55                   	push   %ebp
  800f05:	57                   	push   %edi
  800f06:	56                   	push   %esi
  800f07:	53                   	push   %ebx
  800f08:	83 ec 1c             	sub    $0x1c,%esp
  800f0b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800f0f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800f13:	8b 74 24 34          	mov    0x34(%esp),%esi
  800f17:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800f1b:	85 d2                	test   %edx,%edx
  800f1d:	75 19                	jne    800f38 <__udivdi3+0x38>
  800f1f:	39 f3                	cmp    %esi,%ebx
  800f21:	76 4d                	jbe    800f70 <__udivdi3+0x70>
  800f23:	31 ff                	xor    %edi,%edi
  800f25:	89 e8                	mov    %ebp,%eax
  800f27:	89 f2                	mov    %esi,%edx
  800f29:	f7 f3                	div    %ebx
  800f2b:	89 fa                	mov    %edi,%edx
  800f2d:	83 c4 1c             	add    $0x1c,%esp
  800f30:	5b                   	pop    %ebx
  800f31:	5e                   	pop    %esi
  800f32:	5f                   	pop    %edi
  800f33:	5d                   	pop    %ebp
  800f34:	c3                   	ret    
  800f35:	8d 76 00             	lea    0x0(%esi),%esi
  800f38:	39 f2                	cmp    %esi,%edx
  800f3a:	76 14                	jbe    800f50 <__udivdi3+0x50>
  800f3c:	31 ff                	xor    %edi,%edi
  800f3e:	31 c0                	xor    %eax,%eax
  800f40:	89 fa                	mov    %edi,%edx
  800f42:	83 c4 1c             	add    $0x1c,%esp
  800f45:	5b                   	pop    %ebx
  800f46:	5e                   	pop    %esi
  800f47:	5f                   	pop    %edi
  800f48:	5d                   	pop    %ebp
  800f49:	c3                   	ret    
  800f4a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800f50:	0f bd fa             	bsr    %edx,%edi
  800f53:	83 f7 1f             	xor    $0x1f,%edi
  800f56:	75 48                	jne    800fa0 <__udivdi3+0xa0>
  800f58:	39 f2                	cmp    %esi,%edx
  800f5a:	72 06                	jb     800f62 <__udivdi3+0x62>
  800f5c:	31 c0                	xor    %eax,%eax
  800f5e:	39 eb                	cmp    %ebp,%ebx
  800f60:	77 de                	ja     800f40 <__udivdi3+0x40>
  800f62:	b8 01 00 00 00       	mov    $0x1,%eax
  800f67:	eb d7                	jmp    800f40 <__udivdi3+0x40>
  800f69:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f70:	89 d9                	mov    %ebx,%ecx
  800f72:	85 db                	test   %ebx,%ebx
  800f74:	75 0b                	jne    800f81 <__udivdi3+0x81>
  800f76:	b8 01 00 00 00       	mov    $0x1,%eax
  800f7b:	31 d2                	xor    %edx,%edx
  800f7d:	f7 f3                	div    %ebx
  800f7f:	89 c1                	mov    %eax,%ecx
  800f81:	31 d2                	xor    %edx,%edx
  800f83:	89 f0                	mov    %esi,%eax
  800f85:	f7 f1                	div    %ecx
  800f87:	89 c6                	mov    %eax,%esi
  800f89:	89 e8                	mov    %ebp,%eax
  800f8b:	89 f7                	mov    %esi,%edi
  800f8d:	f7 f1                	div    %ecx
  800f8f:	89 fa                	mov    %edi,%edx
  800f91:	83 c4 1c             	add    $0x1c,%esp
  800f94:	5b                   	pop    %ebx
  800f95:	5e                   	pop    %esi
  800f96:	5f                   	pop    %edi
  800f97:	5d                   	pop    %ebp
  800f98:	c3                   	ret    
  800f99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800fa0:	89 f9                	mov    %edi,%ecx
  800fa2:	b8 20 00 00 00       	mov    $0x20,%eax
  800fa7:	29 f8                	sub    %edi,%eax
  800fa9:	d3 e2                	shl    %cl,%edx
  800fab:	89 54 24 08          	mov    %edx,0x8(%esp)
  800faf:	89 c1                	mov    %eax,%ecx
  800fb1:	89 da                	mov    %ebx,%edx
  800fb3:	d3 ea                	shr    %cl,%edx
  800fb5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800fb9:	09 d1                	or     %edx,%ecx
  800fbb:	89 f2                	mov    %esi,%edx
  800fbd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800fc1:	89 f9                	mov    %edi,%ecx
  800fc3:	d3 e3                	shl    %cl,%ebx
  800fc5:	89 c1                	mov    %eax,%ecx
  800fc7:	d3 ea                	shr    %cl,%edx
  800fc9:	89 f9                	mov    %edi,%ecx
  800fcb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800fcf:	89 eb                	mov    %ebp,%ebx
  800fd1:	d3 e6                	shl    %cl,%esi
  800fd3:	89 c1                	mov    %eax,%ecx
  800fd5:	d3 eb                	shr    %cl,%ebx
  800fd7:	09 de                	or     %ebx,%esi
  800fd9:	89 f0                	mov    %esi,%eax
  800fdb:	f7 74 24 08          	divl   0x8(%esp)
  800fdf:	89 d6                	mov    %edx,%esi
  800fe1:	89 c3                	mov    %eax,%ebx
  800fe3:	f7 64 24 0c          	mull   0xc(%esp)
  800fe7:	39 d6                	cmp    %edx,%esi
  800fe9:	72 15                	jb     801000 <__udivdi3+0x100>
  800feb:	89 f9                	mov    %edi,%ecx
  800fed:	d3 e5                	shl    %cl,%ebp
  800fef:	39 c5                	cmp    %eax,%ebp
  800ff1:	73 04                	jae    800ff7 <__udivdi3+0xf7>
  800ff3:	39 d6                	cmp    %edx,%esi
  800ff5:	74 09                	je     801000 <__udivdi3+0x100>
  800ff7:	89 d8                	mov    %ebx,%eax
  800ff9:	31 ff                	xor    %edi,%edi
  800ffb:	e9 40 ff ff ff       	jmp    800f40 <__udivdi3+0x40>
  801000:	8d 43 ff             	lea    -0x1(%ebx),%eax
  801003:	31 ff                	xor    %edi,%edi
  801005:	e9 36 ff ff ff       	jmp    800f40 <__udivdi3+0x40>
  80100a:	66 90                	xchg   %ax,%ax
  80100c:	66 90                	xchg   %ax,%ax
  80100e:	66 90                	xchg   %ax,%ax

00801010 <__umoddi3>:
  801010:	f3 0f 1e fb          	endbr32 
  801014:	55                   	push   %ebp
  801015:	57                   	push   %edi
  801016:	56                   	push   %esi
  801017:	53                   	push   %ebx
  801018:	83 ec 1c             	sub    $0x1c,%esp
  80101b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80101f:	8b 74 24 30          	mov    0x30(%esp),%esi
  801023:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  801027:	8b 7c 24 38          	mov    0x38(%esp),%edi
  80102b:	85 c0                	test   %eax,%eax
  80102d:	75 19                	jne    801048 <__umoddi3+0x38>
  80102f:	39 df                	cmp    %ebx,%edi
  801031:	76 5d                	jbe    801090 <__umoddi3+0x80>
  801033:	89 f0                	mov    %esi,%eax
  801035:	89 da                	mov    %ebx,%edx
  801037:	f7 f7                	div    %edi
  801039:	89 d0                	mov    %edx,%eax
  80103b:	31 d2                	xor    %edx,%edx
  80103d:	83 c4 1c             	add    $0x1c,%esp
  801040:	5b                   	pop    %ebx
  801041:	5e                   	pop    %esi
  801042:	5f                   	pop    %edi
  801043:	5d                   	pop    %ebp
  801044:	c3                   	ret    
  801045:	8d 76 00             	lea    0x0(%esi),%esi
  801048:	89 f2                	mov    %esi,%edx
  80104a:	39 d8                	cmp    %ebx,%eax
  80104c:	76 12                	jbe    801060 <__umoddi3+0x50>
  80104e:	89 f0                	mov    %esi,%eax
  801050:	89 da                	mov    %ebx,%edx
  801052:	83 c4 1c             	add    $0x1c,%esp
  801055:	5b                   	pop    %ebx
  801056:	5e                   	pop    %esi
  801057:	5f                   	pop    %edi
  801058:	5d                   	pop    %ebp
  801059:	c3                   	ret    
  80105a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801060:	0f bd e8             	bsr    %eax,%ebp
  801063:	83 f5 1f             	xor    $0x1f,%ebp
  801066:	75 50                	jne    8010b8 <__umoddi3+0xa8>
  801068:	39 d8                	cmp    %ebx,%eax
  80106a:	0f 82 e0 00 00 00    	jb     801150 <__umoddi3+0x140>
  801070:	89 d9                	mov    %ebx,%ecx
  801072:	39 f7                	cmp    %esi,%edi
  801074:	0f 86 d6 00 00 00    	jbe    801150 <__umoddi3+0x140>
  80107a:	89 d0                	mov    %edx,%eax
  80107c:	89 ca                	mov    %ecx,%edx
  80107e:	83 c4 1c             	add    $0x1c,%esp
  801081:	5b                   	pop    %ebx
  801082:	5e                   	pop    %esi
  801083:	5f                   	pop    %edi
  801084:	5d                   	pop    %ebp
  801085:	c3                   	ret    
  801086:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80108d:	8d 76 00             	lea    0x0(%esi),%esi
  801090:	89 fd                	mov    %edi,%ebp
  801092:	85 ff                	test   %edi,%edi
  801094:	75 0b                	jne    8010a1 <__umoddi3+0x91>
  801096:	b8 01 00 00 00       	mov    $0x1,%eax
  80109b:	31 d2                	xor    %edx,%edx
  80109d:	f7 f7                	div    %edi
  80109f:	89 c5                	mov    %eax,%ebp
  8010a1:	89 d8                	mov    %ebx,%eax
  8010a3:	31 d2                	xor    %edx,%edx
  8010a5:	f7 f5                	div    %ebp
  8010a7:	89 f0                	mov    %esi,%eax
  8010a9:	f7 f5                	div    %ebp
  8010ab:	89 d0                	mov    %edx,%eax
  8010ad:	31 d2                	xor    %edx,%edx
  8010af:	eb 8c                	jmp    80103d <__umoddi3+0x2d>
  8010b1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8010b8:	89 e9                	mov    %ebp,%ecx
  8010ba:	ba 20 00 00 00       	mov    $0x20,%edx
  8010bf:	29 ea                	sub    %ebp,%edx
  8010c1:	d3 e0                	shl    %cl,%eax
  8010c3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010c7:	89 d1                	mov    %edx,%ecx
  8010c9:	89 f8                	mov    %edi,%eax
  8010cb:	d3 e8                	shr    %cl,%eax
  8010cd:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8010d1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8010d5:	8b 54 24 04          	mov    0x4(%esp),%edx
  8010d9:	09 c1                	or     %eax,%ecx
  8010db:	89 d8                	mov    %ebx,%eax
  8010dd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8010e1:	89 e9                	mov    %ebp,%ecx
  8010e3:	d3 e7                	shl    %cl,%edi
  8010e5:	89 d1                	mov    %edx,%ecx
  8010e7:	d3 e8                	shr    %cl,%eax
  8010e9:	89 e9                	mov    %ebp,%ecx
  8010eb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8010ef:	d3 e3                	shl    %cl,%ebx
  8010f1:	89 c7                	mov    %eax,%edi
  8010f3:	89 d1                	mov    %edx,%ecx
  8010f5:	89 f0                	mov    %esi,%eax
  8010f7:	d3 e8                	shr    %cl,%eax
  8010f9:	89 e9                	mov    %ebp,%ecx
  8010fb:	89 fa                	mov    %edi,%edx
  8010fd:	d3 e6                	shl    %cl,%esi
  8010ff:	09 d8                	or     %ebx,%eax
  801101:	f7 74 24 08          	divl   0x8(%esp)
  801105:	89 d1                	mov    %edx,%ecx
  801107:	89 f3                	mov    %esi,%ebx
  801109:	f7 64 24 0c          	mull   0xc(%esp)
  80110d:	89 c6                	mov    %eax,%esi
  80110f:	89 d7                	mov    %edx,%edi
  801111:	39 d1                	cmp    %edx,%ecx
  801113:	72 06                	jb     80111b <__umoddi3+0x10b>
  801115:	75 10                	jne    801127 <__umoddi3+0x117>
  801117:	39 c3                	cmp    %eax,%ebx
  801119:	73 0c                	jae    801127 <__umoddi3+0x117>
  80111b:	2b 44 24 0c          	sub    0xc(%esp),%eax
  80111f:	1b 54 24 08          	sbb    0x8(%esp),%edx
  801123:	89 d7                	mov    %edx,%edi
  801125:	89 c6                	mov    %eax,%esi
  801127:	89 ca                	mov    %ecx,%edx
  801129:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80112e:	29 f3                	sub    %esi,%ebx
  801130:	19 fa                	sbb    %edi,%edx
  801132:	89 d0                	mov    %edx,%eax
  801134:	d3 e0                	shl    %cl,%eax
  801136:	89 e9                	mov    %ebp,%ecx
  801138:	d3 eb                	shr    %cl,%ebx
  80113a:	d3 ea                	shr    %cl,%edx
  80113c:	09 d8                	or     %ebx,%eax
  80113e:	83 c4 1c             	add    $0x1c,%esp
  801141:	5b                   	pop    %ebx
  801142:	5e                   	pop    %esi
  801143:	5f                   	pop    %edi
  801144:	5d                   	pop    %ebp
  801145:	c3                   	ret    
  801146:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80114d:	8d 76 00             	lea    0x0(%esi),%esi
  801150:	29 fe                	sub    %edi,%esi
  801152:	19 c3                	sbb    %eax,%ebx
  801154:	89 f2                	mov    %esi,%edx
  801156:	89 d9                	mov    %ebx,%ecx
  801158:	e9 1d ff ff ff       	jmp    80107a <__umoddi3+0x6a>
