
obj/user/primes:     file format elf32-i386


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
  80002c:	e8 cd 00 00 00       	call   8000fe <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <primeproc>:

#include <inc/lib.h>

unsigned
primeproc(void)
{
  800033:	f3 0f 1e fb          	endbr32 
  800037:	55                   	push   %ebp
  800038:	89 e5                	mov    %esp,%ebp
  80003a:	57                   	push   %edi
  80003b:	56                   	push   %esi
  80003c:	53                   	push   %ebx
  80003d:	83 ec 1c             	sub    $0x1c,%esp
	int i, id, p;
	envid_t envid;

	// fetch a prime from our left neighbor
top:
	p = ipc_recv(&envid, 0, 0);
  800040:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  800043:	83 ec 04             	sub    $0x4,%esp
  800046:	6a 00                	push   $0x0
  800048:	6a 00                	push   $0x0
  80004a:	56                   	push   %esi
  80004b:	e8 47 11 00 00       	call   801197 <ipc_recv>
  800050:	89 c3                	mov    %eax,%ebx
	cprintf("CPU %d: %d ", thisenv->env_cpunum, p);
  800052:	a1 04 20 80 00       	mov    0x802004,%eax
  800057:	8b 40 5c             	mov    0x5c(%eax),%eax
  80005a:	83 c4 0c             	add    $0xc,%esp
  80005d:	53                   	push   %ebx
  80005e:	50                   	push   %eax
  80005f:	68 80 15 80 00       	push   $0x801580
  800064:	e8 dc 01 00 00       	call   800245 <cprintf>

	// fork a right neighbor to continue the chain
	if ((id = fork()) < 0)
  800069:	e8 15 0f 00 00       	call   800f83 <fork>
  80006e:	89 c7                	mov    %eax,%edi
  800070:	83 c4 10             	add    $0x10,%esp
  800073:	85 c0                	test   %eax,%eax
  800075:	78 07                	js     80007e <primeproc+0x4b>
		panic("fork: %e", id);
	if (id == 0)
  800077:	74 ca                	je     800043 <primeproc+0x10>
		goto top;

	// filter out multiples of our prime
	while (1) {
		i = ipc_recv(&envid, 0, 0);
  800079:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  80007c:	eb 20                	jmp    80009e <primeproc+0x6b>
		panic("fork: %e", id);
  80007e:	50                   	push   %eax
  80007f:	68 8c 15 80 00       	push   $0x80158c
  800084:	6a 1a                	push   $0x1a
  800086:	68 95 15 80 00       	push   $0x801595
  80008b:	e8 ce 00 00 00       	call   80015e <_panic>
		if (i % p)
			ipc_send(id, i, 0, 0);
  800090:	6a 00                	push   $0x0
  800092:	6a 00                	push   $0x0
  800094:	51                   	push   %ecx
  800095:	57                   	push   %edi
  800096:	e8 69 11 00 00       	call   801204 <ipc_send>
  80009b:	83 c4 10             	add    $0x10,%esp
		i = ipc_recv(&envid, 0, 0);
  80009e:	83 ec 04             	sub    $0x4,%esp
  8000a1:	6a 00                	push   $0x0
  8000a3:	6a 00                	push   $0x0
  8000a5:	56                   	push   %esi
  8000a6:	e8 ec 10 00 00       	call   801197 <ipc_recv>
  8000ab:	89 c1                	mov    %eax,%ecx
		if (i % p)
  8000ad:	99                   	cltd   
  8000ae:	f7 fb                	idiv   %ebx
  8000b0:	83 c4 10             	add    $0x10,%esp
  8000b3:	85 d2                	test   %edx,%edx
  8000b5:	74 e7                	je     80009e <primeproc+0x6b>
  8000b7:	eb d7                	jmp    800090 <primeproc+0x5d>

008000b9 <umain>:
	}
}

void
umain(int argc, char **argv)
{
  8000b9:	f3 0f 1e fb          	endbr32 
  8000bd:	55                   	push   %ebp
  8000be:	89 e5                	mov    %esp,%ebp
  8000c0:	56                   	push   %esi
  8000c1:	53                   	push   %ebx
	int i, id;

	// fork the first prime process in the chain
	if ((id = fork()) < 0)
  8000c2:	e8 bc 0e 00 00       	call   800f83 <fork>
  8000c7:	89 c6                	mov    %eax,%esi
  8000c9:	85 c0                	test   %eax,%eax
  8000cb:	78 1a                	js     8000e7 <umain+0x2e>
		panic("fork: %e", id);
	if (id == 0)
		primeproc();

	// feed all the integers through
	for (i = 2; ; i++)
  8000cd:	bb 02 00 00 00       	mov    $0x2,%ebx
	if (id == 0)
  8000d2:	74 25                	je     8000f9 <umain+0x40>
		ipc_send(id, i, 0, 0);
  8000d4:	6a 00                	push   $0x0
  8000d6:	6a 00                	push   $0x0
  8000d8:	53                   	push   %ebx
  8000d9:	56                   	push   %esi
  8000da:	e8 25 11 00 00       	call   801204 <ipc_send>
	for (i = 2; ; i++)
  8000df:	83 c3 01             	add    $0x1,%ebx
  8000e2:	83 c4 10             	add    $0x10,%esp
  8000e5:	eb ed                	jmp    8000d4 <umain+0x1b>
		panic("fork: %e", id);
  8000e7:	50                   	push   %eax
  8000e8:	68 8c 15 80 00       	push   $0x80158c
  8000ed:	6a 2d                	push   $0x2d
  8000ef:	68 95 15 80 00       	push   $0x801595
  8000f4:	e8 65 00 00 00       	call   80015e <_panic>
		primeproc();
  8000f9:	e8 35 ff ff ff       	call   800033 <primeproc>

008000fe <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000fe:	f3 0f 1e fb          	endbr32 
  800102:	55                   	push   %ebp
  800103:	89 e5                	mov    %esp,%ebp
  800105:	56                   	push   %esi
  800106:	53                   	push   %ebx
  800107:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80010a:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv=&envs[ENVX(sys_getenvid())];
  80010d:	e8 78 0b 00 00       	call   800c8a <sys_getenvid>
  800112:	25 ff 03 00 00       	and    $0x3ff,%eax
  800117:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80011a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80011f:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800124:	85 db                	test   %ebx,%ebx
  800126:	7e 07                	jle    80012f <libmain+0x31>
		binaryname = argv[0];
  800128:	8b 06                	mov    (%esi),%eax
  80012a:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80012f:	83 ec 08             	sub    $0x8,%esp
  800132:	56                   	push   %esi
  800133:	53                   	push   %ebx
  800134:	e8 80 ff ff ff       	call   8000b9 <umain>

	// exit gracefully
	exit();
  800139:	e8 0a 00 00 00       	call   800148 <exit>
}
  80013e:	83 c4 10             	add    $0x10,%esp
  800141:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800144:	5b                   	pop    %ebx
  800145:	5e                   	pop    %esi
  800146:	5d                   	pop    %ebp
  800147:	c3                   	ret    

00800148 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800148:	f3 0f 1e fb          	endbr32 
  80014c:	55                   	push   %ebp
  80014d:	89 e5                	mov    %esp,%ebp
  80014f:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800152:	6a 00                	push   $0x0
  800154:	e8 ec 0a 00 00       	call   800c45 <sys_env_destroy>
}
  800159:	83 c4 10             	add    $0x10,%esp
  80015c:	c9                   	leave  
  80015d:	c3                   	ret    

0080015e <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80015e:	f3 0f 1e fb          	endbr32 
  800162:	55                   	push   %ebp
  800163:	89 e5                	mov    %esp,%ebp
  800165:	56                   	push   %esi
  800166:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800167:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80016a:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800170:	e8 15 0b 00 00       	call   800c8a <sys_getenvid>
  800175:	83 ec 0c             	sub    $0xc,%esp
  800178:	ff 75 0c             	pushl  0xc(%ebp)
  80017b:	ff 75 08             	pushl  0x8(%ebp)
  80017e:	56                   	push   %esi
  80017f:	50                   	push   %eax
  800180:	68 b0 15 80 00       	push   $0x8015b0
  800185:	e8 bb 00 00 00       	call   800245 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80018a:	83 c4 18             	add    $0x18,%esp
  80018d:	53                   	push   %ebx
  80018e:	ff 75 10             	pushl  0x10(%ebp)
  800191:	e8 5a 00 00 00       	call   8001f0 <vcprintf>
	cprintf("\n");
  800196:	c7 04 24 4e 19 80 00 	movl   $0x80194e,(%esp)
  80019d:	e8 a3 00 00 00       	call   800245 <cprintf>
  8001a2:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001a5:	cc                   	int3   
  8001a6:	eb fd                	jmp    8001a5 <_panic+0x47>

008001a8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001a8:	f3 0f 1e fb          	endbr32 
  8001ac:	55                   	push   %ebp
  8001ad:	89 e5                	mov    %esp,%ebp
  8001af:	53                   	push   %ebx
  8001b0:	83 ec 04             	sub    $0x4,%esp
  8001b3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001b6:	8b 13                	mov    (%ebx),%edx
  8001b8:	8d 42 01             	lea    0x1(%edx),%eax
  8001bb:	89 03                	mov    %eax,(%ebx)
  8001bd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001c0:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001c4:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001c9:	74 09                	je     8001d4 <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8001cb:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001cf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001d2:	c9                   	leave  
  8001d3:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8001d4:	83 ec 08             	sub    $0x8,%esp
  8001d7:	68 ff 00 00 00       	push   $0xff
  8001dc:	8d 43 08             	lea    0x8(%ebx),%eax
  8001df:	50                   	push   %eax
  8001e0:	e8 1b 0a 00 00       	call   800c00 <sys_cputs>
		b->idx = 0;
  8001e5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001eb:	83 c4 10             	add    $0x10,%esp
  8001ee:	eb db                	jmp    8001cb <putch+0x23>

008001f0 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001f0:	f3 0f 1e fb          	endbr32 
  8001f4:	55                   	push   %ebp
  8001f5:	89 e5                	mov    %esp,%ebp
  8001f7:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001fd:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800204:	00 00 00 
	b.cnt = 0;
  800207:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80020e:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800211:	ff 75 0c             	pushl  0xc(%ebp)
  800214:	ff 75 08             	pushl  0x8(%ebp)
  800217:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80021d:	50                   	push   %eax
  80021e:	68 a8 01 80 00       	push   $0x8001a8
  800223:	e8 20 01 00 00       	call   800348 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800228:	83 c4 08             	add    $0x8,%esp
  80022b:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800231:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800237:	50                   	push   %eax
  800238:	e8 c3 09 00 00       	call   800c00 <sys_cputs>

	return b.cnt;
}
  80023d:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800243:	c9                   	leave  
  800244:	c3                   	ret    

00800245 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800245:	f3 0f 1e fb          	endbr32 
  800249:	55                   	push   %ebp
  80024a:	89 e5                	mov    %esp,%ebp
  80024c:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80024f:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800252:	50                   	push   %eax
  800253:	ff 75 08             	pushl  0x8(%ebp)
  800256:	e8 95 ff ff ff       	call   8001f0 <vcprintf>
	va_end(ap);

	return cnt;
}
  80025b:	c9                   	leave  
  80025c:	c3                   	ret    

0080025d <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80025d:	55                   	push   %ebp
  80025e:	89 e5                	mov    %esp,%ebp
  800260:	57                   	push   %edi
  800261:	56                   	push   %esi
  800262:	53                   	push   %ebx
  800263:	83 ec 1c             	sub    $0x1c,%esp
  800266:	89 c7                	mov    %eax,%edi
  800268:	89 d6                	mov    %edx,%esi
  80026a:	8b 45 08             	mov    0x8(%ebp),%eax
  80026d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800270:	89 d1                	mov    %edx,%ecx
  800272:	89 c2                	mov    %eax,%edx
  800274:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800277:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80027a:	8b 45 10             	mov    0x10(%ebp),%eax
  80027d:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800280:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800283:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80028a:	39 c2                	cmp    %eax,%edx
  80028c:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  80028f:	72 3e                	jb     8002cf <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800291:	83 ec 0c             	sub    $0xc,%esp
  800294:	ff 75 18             	pushl  0x18(%ebp)
  800297:	83 eb 01             	sub    $0x1,%ebx
  80029a:	53                   	push   %ebx
  80029b:	50                   	push   %eax
  80029c:	83 ec 08             	sub    $0x8,%esp
  80029f:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002a2:	ff 75 e0             	pushl  -0x20(%ebp)
  8002a5:	ff 75 dc             	pushl  -0x24(%ebp)
  8002a8:	ff 75 d8             	pushl  -0x28(%ebp)
  8002ab:	e8 70 10 00 00       	call   801320 <__udivdi3>
  8002b0:	83 c4 18             	add    $0x18,%esp
  8002b3:	52                   	push   %edx
  8002b4:	50                   	push   %eax
  8002b5:	89 f2                	mov    %esi,%edx
  8002b7:	89 f8                	mov    %edi,%eax
  8002b9:	e8 9f ff ff ff       	call   80025d <printnum>
  8002be:	83 c4 20             	add    $0x20,%esp
  8002c1:	eb 13                	jmp    8002d6 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002c3:	83 ec 08             	sub    $0x8,%esp
  8002c6:	56                   	push   %esi
  8002c7:	ff 75 18             	pushl  0x18(%ebp)
  8002ca:	ff d7                	call   *%edi
  8002cc:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8002cf:	83 eb 01             	sub    $0x1,%ebx
  8002d2:	85 db                	test   %ebx,%ebx
  8002d4:	7f ed                	jg     8002c3 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002d6:	83 ec 08             	sub    $0x8,%esp
  8002d9:	56                   	push   %esi
  8002da:	83 ec 04             	sub    $0x4,%esp
  8002dd:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002e0:	ff 75 e0             	pushl  -0x20(%ebp)
  8002e3:	ff 75 dc             	pushl  -0x24(%ebp)
  8002e6:	ff 75 d8             	pushl  -0x28(%ebp)
  8002e9:	e8 42 11 00 00       	call   801430 <__umoddi3>
  8002ee:	83 c4 14             	add    $0x14,%esp
  8002f1:	0f be 80 d3 15 80 00 	movsbl 0x8015d3(%eax),%eax
  8002f8:	50                   	push   %eax
  8002f9:	ff d7                	call   *%edi
}
  8002fb:	83 c4 10             	add    $0x10,%esp
  8002fe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800301:	5b                   	pop    %ebx
  800302:	5e                   	pop    %esi
  800303:	5f                   	pop    %edi
  800304:	5d                   	pop    %ebp
  800305:	c3                   	ret    

00800306 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800306:	f3 0f 1e fb          	endbr32 
  80030a:	55                   	push   %ebp
  80030b:	89 e5                	mov    %esp,%ebp
  80030d:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800310:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800314:	8b 10                	mov    (%eax),%edx
  800316:	3b 50 04             	cmp    0x4(%eax),%edx
  800319:	73 0a                	jae    800325 <sprintputch+0x1f>
		*b->buf++ = ch;
  80031b:	8d 4a 01             	lea    0x1(%edx),%ecx
  80031e:	89 08                	mov    %ecx,(%eax)
  800320:	8b 45 08             	mov    0x8(%ebp),%eax
  800323:	88 02                	mov    %al,(%edx)
}
  800325:	5d                   	pop    %ebp
  800326:	c3                   	ret    

00800327 <printfmt>:
{
  800327:	f3 0f 1e fb          	endbr32 
  80032b:	55                   	push   %ebp
  80032c:	89 e5                	mov    %esp,%ebp
  80032e:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800331:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800334:	50                   	push   %eax
  800335:	ff 75 10             	pushl  0x10(%ebp)
  800338:	ff 75 0c             	pushl  0xc(%ebp)
  80033b:	ff 75 08             	pushl  0x8(%ebp)
  80033e:	e8 05 00 00 00       	call   800348 <vprintfmt>
}
  800343:	83 c4 10             	add    $0x10,%esp
  800346:	c9                   	leave  
  800347:	c3                   	ret    

00800348 <vprintfmt>:
{
  800348:	f3 0f 1e fb          	endbr32 
  80034c:	55                   	push   %ebp
  80034d:	89 e5                	mov    %esp,%ebp
  80034f:	57                   	push   %edi
  800350:	56                   	push   %esi
  800351:	53                   	push   %ebx
  800352:	83 ec 3c             	sub    $0x3c,%esp
  800355:	8b 75 08             	mov    0x8(%ebp),%esi
  800358:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80035b:	8b 7d 10             	mov    0x10(%ebp),%edi
  80035e:	e9 cd 03 00 00       	jmp    800730 <vprintfmt+0x3e8>
		padc = ' ';
  800363:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800367:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  80036e:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800375:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80037c:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800381:	8d 47 01             	lea    0x1(%edi),%eax
  800384:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800387:	0f b6 17             	movzbl (%edi),%edx
  80038a:	8d 42 dd             	lea    -0x23(%edx),%eax
  80038d:	3c 55                	cmp    $0x55,%al
  80038f:	0f 87 1e 04 00 00    	ja     8007b3 <vprintfmt+0x46b>
  800395:	0f b6 c0             	movzbl %al,%eax
  800398:	3e ff 24 85 a0 16 80 	notrack jmp *0x8016a0(,%eax,4)
  80039f:	00 
  8003a0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8003a3:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  8003a7:	eb d8                	jmp    800381 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8003a9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003ac:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  8003b0:	eb cf                	jmp    800381 <vprintfmt+0x39>
  8003b2:	0f b6 d2             	movzbl %dl,%edx
  8003b5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8003b8:	b8 00 00 00 00       	mov    $0x0,%eax
  8003bd:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8003c0:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003c3:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8003c7:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8003ca:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8003cd:	83 f9 09             	cmp    $0x9,%ecx
  8003d0:	77 55                	ja     800427 <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  8003d2:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8003d5:	eb e9                	jmp    8003c0 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  8003d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8003da:	8b 00                	mov    (%eax),%eax
  8003dc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003df:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e2:	8d 40 04             	lea    0x4(%eax),%eax
  8003e5:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003e8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8003eb:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003ef:	79 90                	jns    800381 <vprintfmt+0x39>
				width = precision, precision = -1;
  8003f1:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8003f4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003f7:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8003fe:	eb 81                	jmp    800381 <vprintfmt+0x39>
  800400:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800403:	85 c0                	test   %eax,%eax
  800405:	ba 00 00 00 00       	mov    $0x0,%edx
  80040a:	0f 49 d0             	cmovns %eax,%edx
  80040d:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800410:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800413:	e9 69 ff ff ff       	jmp    800381 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800418:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  80041b:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  800422:	e9 5a ff ff ff       	jmp    800381 <vprintfmt+0x39>
  800427:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80042a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80042d:	eb bc                	jmp    8003eb <vprintfmt+0xa3>
			lflag++;
  80042f:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800432:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800435:	e9 47 ff ff ff       	jmp    800381 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  80043a:	8b 45 14             	mov    0x14(%ebp),%eax
  80043d:	8d 78 04             	lea    0x4(%eax),%edi
  800440:	83 ec 08             	sub    $0x8,%esp
  800443:	53                   	push   %ebx
  800444:	ff 30                	pushl  (%eax)
  800446:	ff d6                	call   *%esi
			break;
  800448:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  80044b:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  80044e:	e9 da 02 00 00       	jmp    80072d <vprintfmt+0x3e5>
			err = va_arg(ap, int);
  800453:	8b 45 14             	mov    0x14(%ebp),%eax
  800456:	8d 78 04             	lea    0x4(%eax),%edi
  800459:	8b 00                	mov    (%eax),%eax
  80045b:	99                   	cltd   
  80045c:	31 d0                	xor    %edx,%eax
  80045e:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800460:	83 f8 08             	cmp    $0x8,%eax
  800463:	7f 23                	jg     800488 <vprintfmt+0x140>
  800465:	8b 14 85 00 18 80 00 	mov    0x801800(,%eax,4),%edx
  80046c:	85 d2                	test   %edx,%edx
  80046e:	74 18                	je     800488 <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  800470:	52                   	push   %edx
  800471:	68 f4 15 80 00       	push   $0x8015f4
  800476:	53                   	push   %ebx
  800477:	56                   	push   %esi
  800478:	e8 aa fe ff ff       	call   800327 <printfmt>
  80047d:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800480:	89 7d 14             	mov    %edi,0x14(%ebp)
  800483:	e9 a5 02 00 00       	jmp    80072d <vprintfmt+0x3e5>
				printfmt(putch, putdat, "error %d", err);
  800488:	50                   	push   %eax
  800489:	68 eb 15 80 00       	push   $0x8015eb
  80048e:	53                   	push   %ebx
  80048f:	56                   	push   %esi
  800490:	e8 92 fe ff ff       	call   800327 <printfmt>
  800495:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800498:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80049b:	e9 8d 02 00 00       	jmp    80072d <vprintfmt+0x3e5>
			if ((p = va_arg(ap, char *)) == NULL)
  8004a0:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a3:	83 c0 04             	add    $0x4,%eax
  8004a6:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8004a9:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ac:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  8004ae:	85 d2                	test   %edx,%edx
  8004b0:	b8 e4 15 80 00       	mov    $0x8015e4,%eax
  8004b5:	0f 45 c2             	cmovne %edx,%eax
  8004b8:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8004bb:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004bf:	7e 06                	jle    8004c7 <vprintfmt+0x17f>
  8004c1:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  8004c5:	75 0d                	jne    8004d4 <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004c7:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8004ca:	89 c7                	mov    %eax,%edi
  8004cc:	03 45 e0             	add    -0x20(%ebp),%eax
  8004cf:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004d2:	eb 55                	jmp    800529 <vprintfmt+0x1e1>
  8004d4:	83 ec 08             	sub    $0x8,%esp
  8004d7:	ff 75 d8             	pushl  -0x28(%ebp)
  8004da:	ff 75 cc             	pushl  -0x34(%ebp)
  8004dd:	e8 85 03 00 00       	call   800867 <strnlen>
  8004e2:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8004e5:	29 c2                	sub    %eax,%edx
  8004e7:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  8004ea:	83 c4 10             	add    $0x10,%esp
  8004ed:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  8004ef:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8004f3:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8004f6:	85 ff                	test   %edi,%edi
  8004f8:	7e 11                	jle    80050b <vprintfmt+0x1c3>
					putch(padc, putdat);
  8004fa:	83 ec 08             	sub    $0x8,%esp
  8004fd:	53                   	push   %ebx
  8004fe:	ff 75 e0             	pushl  -0x20(%ebp)
  800501:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800503:	83 ef 01             	sub    $0x1,%edi
  800506:	83 c4 10             	add    $0x10,%esp
  800509:	eb eb                	jmp    8004f6 <vprintfmt+0x1ae>
  80050b:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  80050e:	85 d2                	test   %edx,%edx
  800510:	b8 00 00 00 00       	mov    $0x0,%eax
  800515:	0f 49 c2             	cmovns %edx,%eax
  800518:	29 c2                	sub    %eax,%edx
  80051a:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80051d:	eb a8                	jmp    8004c7 <vprintfmt+0x17f>
					putch(ch, putdat);
  80051f:	83 ec 08             	sub    $0x8,%esp
  800522:	53                   	push   %ebx
  800523:	52                   	push   %edx
  800524:	ff d6                	call   *%esi
  800526:	83 c4 10             	add    $0x10,%esp
  800529:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80052c:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80052e:	83 c7 01             	add    $0x1,%edi
  800531:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800535:	0f be d0             	movsbl %al,%edx
  800538:	85 d2                	test   %edx,%edx
  80053a:	74 4b                	je     800587 <vprintfmt+0x23f>
  80053c:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800540:	78 06                	js     800548 <vprintfmt+0x200>
  800542:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800546:	78 1e                	js     800566 <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
  800548:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80054c:	74 d1                	je     80051f <vprintfmt+0x1d7>
  80054e:	0f be c0             	movsbl %al,%eax
  800551:	83 e8 20             	sub    $0x20,%eax
  800554:	83 f8 5e             	cmp    $0x5e,%eax
  800557:	76 c6                	jbe    80051f <vprintfmt+0x1d7>
					putch('?', putdat);
  800559:	83 ec 08             	sub    $0x8,%esp
  80055c:	53                   	push   %ebx
  80055d:	6a 3f                	push   $0x3f
  80055f:	ff d6                	call   *%esi
  800561:	83 c4 10             	add    $0x10,%esp
  800564:	eb c3                	jmp    800529 <vprintfmt+0x1e1>
  800566:	89 cf                	mov    %ecx,%edi
  800568:	eb 0e                	jmp    800578 <vprintfmt+0x230>
				putch(' ', putdat);
  80056a:	83 ec 08             	sub    $0x8,%esp
  80056d:	53                   	push   %ebx
  80056e:	6a 20                	push   $0x20
  800570:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800572:	83 ef 01             	sub    $0x1,%edi
  800575:	83 c4 10             	add    $0x10,%esp
  800578:	85 ff                	test   %edi,%edi
  80057a:	7f ee                	jg     80056a <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  80057c:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80057f:	89 45 14             	mov    %eax,0x14(%ebp)
  800582:	e9 a6 01 00 00       	jmp    80072d <vprintfmt+0x3e5>
  800587:	89 cf                	mov    %ecx,%edi
  800589:	eb ed                	jmp    800578 <vprintfmt+0x230>
	if (lflag >= 2)
  80058b:	83 f9 01             	cmp    $0x1,%ecx
  80058e:	7f 1f                	jg     8005af <vprintfmt+0x267>
	else if (lflag)
  800590:	85 c9                	test   %ecx,%ecx
  800592:	74 67                	je     8005fb <vprintfmt+0x2b3>
		return va_arg(*ap, long);
  800594:	8b 45 14             	mov    0x14(%ebp),%eax
  800597:	8b 00                	mov    (%eax),%eax
  800599:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80059c:	89 c1                	mov    %eax,%ecx
  80059e:	c1 f9 1f             	sar    $0x1f,%ecx
  8005a1:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005a4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a7:	8d 40 04             	lea    0x4(%eax),%eax
  8005aa:	89 45 14             	mov    %eax,0x14(%ebp)
  8005ad:	eb 17                	jmp    8005c6 <vprintfmt+0x27e>
		return va_arg(*ap, long long);
  8005af:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b2:	8b 50 04             	mov    0x4(%eax),%edx
  8005b5:	8b 00                	mov    (%eax),%eax
  8005b7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005ba:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c0:	8d 40 08             	lea    0x8(%eax),%eax
  8005c3:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8005c6:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005c9:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8005cc:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  8005d1:	85 c9                	test   %ecx,%ecx
  8005d3:	0f 89 3a 01 00 00    	jns    800713 <vprintfmt+0x3cb>
				putch('-', putdat);
  8005d9:	83 ec 08             	sub    $0x8,%esp
  8005dc:	53                   	push   %ebx
  8005dd:	6a 2d                	push   $0x2d
  8005df:	ff d6                	call   *%esi
				num = -(long long) num;
  8005e1:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005e4:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005e7:	f7 da                	neg    %edx
  8005e9:	83 d1 00             	adc    $0x0,%ecx
  8005ec:	f7 d9                	neg    %ecx
  8005ee:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8005f1:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005f6:	e9 18 01 00 00       	jmp    800713 <vprintfmt+0x3cb>
		return va_arg(*ap, int);
  8005fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fe:	8b 00                	mov    (%eax),%eax
  800600:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800603:	89 c1                	mov    %eax,%ecx
  800605:	c1 f9 1f             	sar    $0x1f,%ecx
  800608:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80060b:	8b 45 14             	mov    0x14(%ebp),%eax
  80060e:	8d 40 04             	lea    0x4(%eax),%eax
  800611:	89 45 14             	mov    %eax,0x14(%ebp)
  800614:	eb b0                	jmp    8005c6 <vprintfmt+0x27e>
	if (lflag >= 2)
  800616:	83 f9 01             	cmp    $0x1,%ecx
  800619:	7f 1e                	jg     800639 <vprintfmt+0x2f1>
	else if (lflag)
  80061b:	85 c9                	test   %ecx,%ecx
  80061d:	74 32                	je     800651 <vprintfmt+0x309>
		return va_arg(*ap, unsigned long);
  80061f:	8b 45 14             	mov    0x14(%ebp),%eax
  800622:	8b 10                	mov    (%eax),%edx
  800624:	b9 00 00 00 00       	mov    $0x0,%ecx
  800629:	8d 40 04             	lea    0x4(%eax),%eax
  80062c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80062f:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  800634:	e9 da 00 00 00       	jmp    800713 <vprintfmt+0x3cb>
		return va_arg(*ap, unsigned long long);
  800639:	8b 45 14             	mov    0x14(%ebp),%eax
  80063c:	8b 10                	mov    (%eax),%edx
  80063e:	8b 48 04             	mov    0x4(%eax),%ecx
  800641:	8d 40 08             	lea    0x8(%eax),%eax
  800644:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800647:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  80064c:	e9 c2 00 00 00       	jmp    800713 <vprintfmt+0x3cb>
		return va_arg(*ap, unsigned int);
  800651:	8b 45 14             	mov    0x14(%ebp),%eax
  800654:	8b 10                	mov    (%eax),%edx
  800656:	b9 00 00 00 00       	mov    $0x0,%ecx
  80065b:	8d 40 04             	lea    0x4(%eax),%eax
  80065e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800661:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  800666:	e9 a8 00 00 00       	jmp    800713 <vprintfmt+0x3cb>
	if (lflag >= 2)
  80066b:	83 f9 01             	cmp    $0x1,%ecx
  80066e:	7f 1b                	jg     80068b <vprintfmt+0x343>
	else if (lflag)
  800670:	85 c9                	test   %ecx,%ecx
  800672:	74 5c                	je     8006d0 <vprintfmt+0x388>
		return va_arg(*ap, long);
  800674:	8b 45 14             	mov    0x14(%ebp),%eax
  800677:	8b 00                	mov    (%eax),%eax
  800679:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80067c:	99                   	cltd   
  80067d:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800680:	8b 45 14             	mov    0x14(%ebp),%eax
  800683:	8d 40 04             	lea    0x4(%eax),%eax
  800686:	89 45 14             	mov    %eax,0x14(%ebp)
  800689:	eb 17                	jmp    8006a2 <vprintfmt+0x35a>
		return va_arg(*ap, long long);
  80068b:	8b 45 14             	mov    0x14(%ebp),%eax
  80068e:	8b 50 04             	mov    0x4(%eax),%edx
  800691:	8b 00                	mov    (%eax),%eax
  800693:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800696:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800699:	8b 45 14             	mov    0x14(%ebp),%eax
  80069c:	8d 40 08             	lea    0x8(%eax),%eax
  80069f:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8006a2:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8006a5:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 8;
  8006a8:	b8 08 00 00 00       	mov    $0x8,%eax
			if ((long long) num < 0) {
  8006ad:	85 c9                	test   %ecx,%ecx
  8006af:	79 62                	jns    800713 <vprintfmt+0x3cb>
				putch('-', putdat);
  8006b1:	83 ec 08             	sub    $0x8,%esp
  8006b4:	53                   	push   %ebx
  8006b5:	6a 2d                	push   $0x2d
  8006b7:	ff d6                	call   *%esi
				num = -(long long) num;
  8006b9:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8006bc:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8006bf:	f7 da                	neg    %edx
  8006c1:	83 d1 00             	adc    $0x0,%ecx
  8006c4:	f7 d9                	neg    %ecx
  8006c6:	83 c4 10             	add    $0x10,%esp
			base = 8;
  8006c9:	b8 08 00 00 00       	mov    $0x8,%eax
  8006ce:	eb 43                	jmp    800713 <vprintfmt+0x3cb>
		return va_arg(*ap, int);
  8006d0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d3:	8b 00                	mov    (%eax),%eax
  8006d5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006d8:	89 c1                	mov    %eax,%ecx
  8006da:	c1 f9 1f             	sar    $0x1f,%ecx
  8006dd:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e3:	8d 40 04             	lea    0x4(%eax),%eax
  8006e6:	89 45 14             	mov    %eax,0x14(%ebp)
  8006e9:	eb b7                	jmp    8006a2 <vprintfmt+0x35a>
			putch('0', putdat);
  8006eb:	83 ec 08             	sub    $0x8,%esp
  8006ee:	53                   	push   %ebx
  8006ef:	6a 30                	push   $0x30
  8006f1:	ff d6                	call   *%esi
			putch('x', putdat);
  8006f3:	83 c4 08             	add    $0x8,%esp
  8006f6:	53                   	push   %ebx
  8006f7:	6a 78                	push   $0x78
  8006f9:	ff d6                	call   *%esi
			num = (unsigned long long)
  8006fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8006fe:	8b 10                	mov    (%eax),%edx
  800700:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800705:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800708:	8d 40 04             	lea    0x4(%eax),%eax
  80070b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80070e:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  800713:	83 ec 0c             	sub    $0xc,%esp
  800716:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  80071a:	57                   	push   %edi
  80071b:	ff 75 e0             	pushl  -0x20(%ebp)
  80071e:	50                   	push   %eax
  80071f:	51                   	push   %ecx
  800720:	52                   	push   %edx
  800721:	89 da                	mov    %ebx,%edx
  800723:	89 f0                	mov    %esi,%eax
  800725:	e8 33 fb ff ff       	call   80025d <printnum>
			break;
  80072a:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  80072d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800730:	83 c7 01             	add    $0x1,%edi
  800733:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800737:	83 f8 25             	cmp    $0x25,%eax
  80073a:	0f 84 23 fc ff ff    	je     800363 <vprintfmt+0x1b>
			if (ch == '\0')
  800740:	85 c0                	test   %eax,%eax
  800742:	0f 84 8b 00 00 00    	je     8007d3 <vprintfmt+0x48b>
			putch(ch, putdat);
  800748:	83 ec 08             	sub    $0x8,%esp
  80074b:	53                   	push   %ebx
  80074c:	50                   	push   %eax
  80074d:	ff d6                	call   *%esi
  80074f:	83 c4 10             	add    $0x10,%esp
  800752:	eb dc                	jmp    800730 <vprintfmt+0x3e8>
	if (lflag >= 2)
  800754:	83 f9 01             	cmp    $0x1,%ecx
  800757:	7f 1b                	jg     800774 <vprintfmt+0x42c>
	else if (lflag)
  800759:	85 c9                	test   %ecx,%ecx
  80075b:	74 2c                	je     800789 <vprintfmt+0x441>
		return va_arg(*ap, unsigned long);
  80075d:	8b 45 14             	mov    0x14(%ebp),%eax
  800760:	8b 10                	mov    (%eax),%edx
  800762:	b9 00 00 00 00       	mov    $0x0,%ecx
  800767:	8d 40 04             	lea    0x4(%eax),%eax
  80076a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80076d:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  800772:	eb 9f                	jmp    800713 <vprintfmt+0x3cb>
		return va_arg(*ap, unsigned long long);
  800774:	8b 45 14             	mov    0x14(%ebp),%eax
  800777:	8b 10                	mov    (%eax),%edx
  800779:	8b 48 04             	mov    0x4(%eax),%ecx
  80077c:	8d 40 08             	lea    0x8(%eax),%eax
  80077f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800782:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  800787:	eb 8a                	jmp    800713 <vprintfmt+0x3cb>
		return va_arg(*ap, unsigned int);
  800789:	8b 45 14             	mov    0x14(%ebp),%eax
  80078c:	8b 10                	mov    (%eax),%edx
  80078e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800793:	8d 40 04             	lea    0x4(%eax),%eax
  800796:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800799:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  80079e:	e9 70 ff ff ff       	jmp    800713 <vprintfmt+0x3cb>
			putch(ch, putdat);
  8007a3:	83 ec 08             	sub    $0x8,%esp
  8007a6:	53                   	push   %ebx
  8007a7:	6a 25                	push   $0x25
  8007a9:	ff d6                	call   *%esi
			break;
  8007ab:	83 c4 10             	add    $0x10,%esp
  8007ae:	e9 7a ff ff ff       	jmp    80072d <vprintfmt+0x3e5>
			putch('%', putdat);
  8007b3:	83 ec 08             	sub    $0x8,%esp
  8007b6:	53                   	push   %ebx
  8007b7:	6a 25                	push   $0x25
  8007b9:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007bb:	83 c4 10             	add    $0x10,%esp
  8007be:	89 f8                	mov    %edi,%eax
  8007c0:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8007c4:	74 05                	je     8007cb <vprintfmt+0x483>
  8007c6:	83 e8 01             	sub    $0x1,%eax
  8007c9:	eb f5                	jmp    8007c0 <vprintfmt+0x478>
  8007cb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8007ce:	e9 5a ff ff ff       	jmp    80072d <vprintfmt+0x3e5>
}
  8007d3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007d6:	5b                   	pop    %ebx
  8007d7:	5e                   	pop    %esi
  8007d8:	5f                   	pop    %edi
  8007d9:	5d                   	pop    %ebp
  8007da:	c3                   	ret    

008007db <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007db:	f3 0f 1e fb          	endbr32 
  8007df:	55                   	push   %ebp
  8007e0:	89 e5                	mov    %esp,%ebp
  8007e2:	83 ec 18             	sub    $0x18,%esp
  8007e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e8:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007eb:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007ee:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007f2:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007f5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007fc:	85 c0                	test   %eax,%eax
  8007fe:	74 26                	je     800826 <vsnprintf+0x4b>
  800800:	85 d2                	test   %edx,%edx
  800802:	7e 22                	jle    800826 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800804:	ff 75 14             	pushl  0x14(%ebp)
  800807:	ff 75 10             	pushl  0x10(%ebp)
  80080a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80080d:	50                   	push   %eax
  80080e:	68 06 03 80 00       	push   $0x800306
  800813:	e8 30 fb ff ff       	call   800348 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800818:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80081b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80081e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800821:	83 c4 10             	add    $0x10,%esp
}
  800824:	c9                   	leave  
  800825:	c3                   	ret    
		return -E_INVAL;
  800826:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80082b:	eb f7                	jmp    800824 <vsnprintf+0x49>

0080082d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80082d:	f3 0f 1e fb          	endbr32 
  800831:	55                   	push   %ebp
  800832:	89 e5                	mov    %esp,%ebp
  800834:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800837:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80083a:	50                   	push   %eax
  80083b:	ff 75 10             	pushl  0x10(%ebp)
  80083e:	ff 75 0c             	pushl  0xc(%ebp)
  800841:	ff 75 08             	pushl  0x8(%ebp)
  800844:	e8 92 ff ff ff       	call   8007db <vsnprintf>
	va_end(ap);

	return rc;
}
  800849:	c9                   	leave  
  80084a:	c3                   	ret    

0080084b <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80084b:	f3 0f 1e fb          	endbr32 
  80084f:	55                   	push   %ebp
  800850:	89 e5                	mov    %esp,%ebp
  800852:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800855:	b8 00 00 00 00       	mov    $0x0,%eax
  80085a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80085e:	74 05                	je     800865 <strlen+0x1a>
		n++;
  800860:	83 c0 01             	add    $0x1,%eax
  800863:	eb f5                	jmp    80085a <strlen+0xf>
	return n;
}
  800865:	5d                   	pop    %ebp
  800866:	c3                   	ret    

00800867 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800867:	f3 0f 1e fb          	endbr32 
  80086b:	55                   	push   %ebp
  80086c:	89 e5                	mov    %esp,%ebp
  80086e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800871:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800874:	b8 00 00 00 00       	mov    $0x0,%eax
  800879:	39 d0                	cmp    %edx,%eax
  80087b:	74 0d                	je     80088a <strnlen+0x23>
  80087d:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800881:	74 05                	je     800888 <strnlen+0x21>
		n++;
  800883:	83 c0 01             	add    $0x1,%eax
  800886:	eb f1                	jmp    800879 <strnlen+0x12>
  800888:	89 c2                	mov    %eax,%edx
	return n;
}
  80088a:	89 d0                	mov    %edx,%eax
  80088c:	5d                   	pop    %ebp
  80088d:	c3                   	ret    

0080088e <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80088e:	f3 0f 1e fb          	endbr32 
  800892:	55                   	push   %ebp
  800893:	89 e5                	mov    %esp,%ebp
  800895:	53                   	push   %ebx
  800896:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800899:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80089c:	b8 00 00 00 00       	mov    $0x0,%eax
  8008a1:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8008a5:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8008a8:	83 c0 01             	add    $0x1,%eax
  8008ab:	84 d2                	test   %dl,%dl
  8008ad:	75 f2                	jne    8008a1 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  8008af:	89 c8                	mov    %ecx,%eax
  8008b1:	5b                   	pop    %ebx
  8008b2:	5d                   	pop    %ebp
  8008b3:	c3                   	ret    

008008b4 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008b4:	f3 0f 1e fb          	endbr32 
  8008b8:	55                   	push   %ebp
  8008b9:	89 e5                	mov    %esp,%ebp
  8008bb:	53                   	push   %ebx
  8008bc:	83 ec 10             	sub    $0x10,%esp
  8008bf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008c2:	53                   	push   %ebx
  8008c3:	e8 83 ff ff ff       	call   80084b <strlen>
  8008c8:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8008cb:	ff 75 0c             	pushl  0xc(%ebp)
  8008ce:	01 d8                	add    %ebx,%eax
  8008d0:	50                   	push   %eax
  8008d1:	e8 b8 ff ff ff       	call   80088e <strcpy>
	return dst;
}
  8008d6:	89 d8                	mov    %ebx,%eax
  8008d8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008db:	c9                   	leave  
  8008dc:	c3                   	ret    

008008dd <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008dd:	f3 0f 1e fb          	endbr32 
  8008e1:	55                   	push   %ebp
  8008e2:	89 e5                	mov    %esp,%ebp
  8008e4:	56                   	push   %esi
  8008e5:	53                   	push   %ebx
  8008e6:	8b 75 08             	mov    0x8(%ebp),%esi
  8008e9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008ec:	89 f3                	mov    %esi,%ebx
  8008ee:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008f1:	89 f0                	mov    %esi,%eax
  8008f3:	39 d8                	cmp    %ebx,%eax
  8008f5:	74 11                	je     800908 <strncpy+0x2b>
		*dst++ = *src;
  8008f7:	83 c0 01             	add    $0x1,%eax
  8008fa:	0f b6 0a             	movzbl (%edx),%ecx
  8008fd:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800900:	80 f9 01             	cmp    $0x1,%cl
  800903:	83 da ff             	sbb    $0xffffffff,%edx
  800906:	eb eb                	jmp    8008f3 <strncpy+0x16>
	}
	return ret;
}
  800908:	89 f0                	mov    %esi,%eax
  80090a:	5b                   	pop    %ebx
  80090b:	5e                   	pop    %esi
  80090c:	5d                   	pop    %ebp
  80090d:	c3                   	ret    

0080090e <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80090e:	f3 0f 1e fb          	endbr32 
  800912:	55                   	push   %ebp
  800913:	89 e5                	mov    %esp,%ebp
  800915:	56                   	push   %esi
  800916:	53                   	push   %ebx
  800917:	8b 75 08             	mov    0x8(%ebp),%esi
  80091a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80091d:	8b 55 10             	mov    0x10(%ebp),%edx
  800920:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800922:	85 d2                	test   %edx,%edx
  800924:	74 21                	je     800947 <strlcpy+0x39>
  800926:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80092a:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  80092c:	39 c2                	cmp    %eax,%edx
  80092e:	74 14                	je     800944 <strlcpy+0x36>
  800930:	0f b6 19             	movzbl (%ecx),%ebx
  800933:	84 db                	test   %bl,%bl
  800935:	74 0b                	je     800942 <strlcpy+0x34>
			*dst++ = *src++;
  800937:	83 c1 01             	add    $0x1,%ecx
  80093a:	83 c2 01             	add    $0x1,%edx
  80093d:	88 5a ff             	mov    %bl,-0x1(%edx)
  800940:	eb ea                	jmp    80092c <strlcpy+0x1e>
  800942:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800944:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800947:	29 f0                	sub    %esi,%eax
}
  800949:	5b                   	pop    %ebx
  80094a:	5e                   	pop    %esi
  80094b:	5d                   	pop    %ebp
  80094c:	c3                   	ret    

0080094d <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80094d:	f3 0f 1e fb          	endbr32 
  800951:	55                   	push   %ebp
  800952:	89 e5                	mov    %esp,%ebp
  800954:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800957:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80095a:	0f b6 01             	movzbl (%ecx),%eax
  80095d:	84 c0                	test   %al,%al
  80095f:	74 0c                	je     80096d <strcmp+0x20>
  800961:	3a 02                	cmp    (%edx),%al
  800963:	75 08                	jne    80096d <strcmp+0x20>
		p++, q++;
  800965:	83 c1 01             	add    $0x1,%ecx
  800968:	83 c2 01             	add    $0x1,%edx
  80096b:	eb ed                	jmp    80095a <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80096d:	0f b6 c0             	movzbl %al,%eax
  800970:	0f b6 12             	movzbl (%edx),%edx
  800973:	29 d0                	sub    %edx,%eax
}
  800975:	5d                   	pop    %ebp
  800976:	c3                   	ret    

00800977 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800977:	f3 0f 1e fb          	endbr32 
  80097b:	55                   	push   %ebp
  80097c:	89 e5                	mov    %esp,%ebp
  80097e:	53                   	push   %ebx
  80097f:	8b 45 08             	mov    0x8(%ebp),%eax
  800982:	8b 55 0c             	mov    0xc(%ebp),%edx
  800985:	89 c3                	mov    %eax,%ebx
  800987:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80098a:	eb 06                	jmp    800992 <strncmp+0x1b>
		n--, p++, q++;
  80098c:	83 c0 01             	add    $0x1,%eax
  80098f:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800992:	39 d8                	cmp    %ebx,%eax
  800994:	74 16                	je     8009ac <strncmp+0x35>
  800996:	0f b6 08             	movzbl (%eax),%ecx
  800999:	84 c9                	test   %cl,%cl
  80099b:	74 04                	je     8009a1 <strncmp+0x2a>
  80099d:	3a 0a                	cmp    (%edx),%cl
  80099f:	74 eb                	je     80098c <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009a1:	0f b6 00             	movzbl (%eax),%eax
  8009a4:	0f b6 12             	movzbl (%edx),%edx
  8009a7:	29 d0                	sub    %edx,%eax
}
  8009a9:	5b                   	pop    %ebx
  8009aa:	5d                   	pop    %ebp
  8009ab:	c3                   	ret    
		return 0;
  8009ac:	b8 00 00 00 00       	mov    $0x0,%eax
  8009b1:	eb f6                	jmp    8009a9 <strncmp+0x32>

008009b3 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009b3:	f3 0f 1e fb          	endbr32 
  8009b7:	55                   	push   %ebp
  8009b8:	89 e5                	mov    %esp,%ebp
  8009ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8009bd:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009c1:	0f b6 10             	movzbl (%eax),%edx
  8009c4:	84 d2                	test   %dl,%dl
  8009c6:	74 09                	je     8009d1 <strchr+0x1e>
		if (*s == c)
  8009c8:	38 ca                	cmp    %cl,%dl
  8009ca:	74 0a                	je     8009d6 <strchr+0x23>
	for (; *s; s++)
  8009cc:	83 c0 01             	add    $0x1,%eax
  8009cf:	eb f0                	jmp    8009c1 <strchr+0xe>
			return (char *) s;
	return 0;
  8009d1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009d6:	5d                   	pop    %ebp
  8009d7:	c3                   	ret    

008009d8 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009d8:	f3 0f 1e fb          	endbr32 
  8009dc:	55                   	push   %ebp
  8009dd:	89 e5                	mov    %esp,%ebp
  8009df:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e2:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009e6:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8009e9:	38 ca                	cmp    %cl,%dl
  8009eb:	74 09                	je     8009f6 <strfind+0x1e>
  8009ed:	84 d2                	test   %dl,%dl
  8009ef:	74 05                	je     8009f6 <strfind+0x1e>
	for (; *s; s++)
  8009f1:	83 c0 01             	add    $0x1,%eax
  8009f4:	eb f0                	jmp    8009e6 <strfind+0xe>
			break;
	return (char *) s;
}
  8009f6:	5d                   	pop    %ebp
  8009f7:	c3                   	ret    

008009f8 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009f8:	f3 0f 1e fb          	endbr32 
  8009fc:	55                   	push   %ebp
  8009fd:	89 e5                	mov    %esp,%ebp
  8009ff:	57                   	push   %edi
  800a00:	56                   	push   %esi
  800a01:	53                   	push   %ebx
  800a02:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a05:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a08:	85 c9                	test   %ecx,%ecx
  800a0a:	74 31                	je     800a3d <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a0c:	89 f8                	mov    %edi,%eax
  800a0e:	09 c8                	or     %ecx,%eax
  800a10:	a8 03                	test   $0x3,%al
  800a12:	75 23                	jne    800a37 <memset+0x3f>
		c &= 0xFF;
  800a14:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a18:	89 d3                	mov    %edx,%ebx
  800a1a:	c1 e3 08             	shl    $0x8,%ebx
  800a1d:	89 d0                	mov    %edx,%eax
  800a1f:	c1 e0 18             	shl    $0x18,%eax
  800a22:	89 d6                	mov    %edx,%esi
  800a24:	c1 e6 10             	shl    $0x10,%esi
  800a27:	09 f0                	or     %esi,%eax
  800a29:	09 c2                	or     %eax,%edx
  800a2b:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a2d:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800a30:	89 d0                	mov    %edx,%eax
  800a32:	fc                   	cld    
  800a33:	f3 ab                	rep stos %eax,%es:(%edi)
  800a35:	eb 06                	jmp    800a3d <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a37:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a3a:	fc                   	cld    
  800a3b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a3d:	89 f8                	mov    %edi,%eax
  800a3f:	5b                   	pop    %ebx
  800a40:	5e                   	pop    %esi
  800a41:	5f                   	pop    %edi
  800a42:	5d                   	pop    %ebp
  800a43:	c3                   	ret    

00800a44 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a44:	f3 0f 1e fb          	endbr32 
  800a48:	55                   	push   %ebp
  800a49:	89 e5                	mov    %esp,%ebp
  800a4b:	57                   	push   %edi
  800a4c:	56                   	push   %esi
  800a4d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a50:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a53:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a56:	39 c6                	cmp    %eax,%esi
  800a58:	73 32                	jae    800a8c <memmove+0x48>
  800a5a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a5d:	39 c2                	cmp    %eax,%edx
  800a5f:	76 2b                	jbe    800a8c <memmove+0x48>
		s += n;
		d += n;
  800a61:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a64:	89 fe                	mov    %edi,%esi
  800a66:	09 ce                	or     %ecx,%esi
  800a68:	09 d6                	or     %edx,%esi
  800a6a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a70:	75 0e                	jne    800a80 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a72:	83 ef 04             	sub    $0x4,%edi
  800a75:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a78:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800a7b:	fd                   	std    
  800a7c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a7e:	eb 09                	jmp    800a89 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a80:	83 ef 01             	sub    $0x1,%edi
  800a83:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800a86:	fd                   	std    
  800a87:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a89:	fc                   	cld    
  800a8a:	eb 1a                	jmp    800aa6 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a8c:	89 c2                	mov    %eax,%edx
  800a8e:	09 ca                	or     %ecx,%edx
  800a90:	09 f2                	or     %esi,%edx
  800a92:	f6 c2 03             	test   $0x3,%dl
  800a95:	75 0a                	jne    800aa1 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a97:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800a9a:	89 c7                	mov    %eax,%edi
  800a9c:	fc                   	cld    
  800a9d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a9f:	eb 05                	jmp    800aa6 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800aa1:	89 c7                	mov    %eax,%edi
  800aa3:	fc                   	cld    
  800aa4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800aa6:	5e                   	pop    %esi
  800aa7:	5f                   	pop    %edi
  800aa8:	5d                   	pop    %ebp
  800aa9:	c3                   	ret    

00800aaa <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800aaa:	f3 0f 1e fb          	endbr32 
  800aae:	55                   	push   %ebp
  800aaf:	89 e5                	mov    %esp,%ebp
  800ab1:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800ab4:	ff 75 10             	pushl  0x10(%ebp)
  800ab7:	ff 75 0c             	pushl  0xc(%ebp)
  800aba:	ff 75 08             	pushl  0x8(%ebp)
  800abd:	e8 82 ff ff ff       	call   800a44 <memmove>
}
  800ac2:	c9                   	leave  
  800ac3:	c3                   	ret    

00800ac4 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ac4:	f3 0f 1e fb          	endbr32 
  800ac8:	55                   	push   %ebp
  800ac9:	89 e5                	mov    %esp,%ebp
  800acb:	56                   	push   %esi
  800acc:	53                   	push   %ebx
  800acd:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad0:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ad3:	89 c6                	mov    %eax,%esi
  800ad5:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ad8:	39 f0                	cmp    %esi,%eax
  800ada:	74 1c                	je     800af8 <memcmp+0x34>
		if (*s1 != *s2)
  800adc:	0f b6 08             	movzbl (%eax),%ecx
  800adf:	0f b6 1a             	movzbl (%edx),%ebx
  800ae2:	38 d9                	cmp    %bl,%cl
  800ae4:	75 08                	jne    800aee <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800ae6:	83 c0 01             	add    $0x1,%eax
  800ae9:	83 c2 01             	add    $0x1,%edx
  800aec:	eb ea                	jmp    800ad8 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800aee:	0f b6 c1             	movzbl %cl,%eax
  800af1:	0f b6 db             	movzbl %bl,%ebx
  800af4:	29 d8                	sub    %ebx,%eax
  800af6:	eb 05                	jmp    800afd <memcmp+0x39>
	}

	return 0;
  800af8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800afd:	5b                   	pop    %ebx
  800afe:	5e                   	pop    %esi
  800aff:	5d                   	pop    %ebp
  800b00:	c3                   	ret    

00800b01 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b01:	f3 0f 1e fb          	endbr32 
  800b05:	55                   	push   %ebp
  800b06:	89 e5                	mov    %esp,%ebp
  800b08:	8b 45 08             	mov    0x8(%ebp),%eax
  800b0b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b0e:	89 c2                	mov    %eax,%edx
  800b10:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b13:	39 d0                	cmp    %edx,%eax
  800b15:	73 09                	jae    800b20 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b17:	38 08                	cmp    %cl,(%eax)
  800b19:	74 05                	je     800b20 <memfind+0x1f>
	for (; s < ends; s++)
  800b1b:	83 c0 01             	add    $0x1,%eax
  800b1e:	eb f3                	jmp    800b13 <memfind+0x12>
			break;
	return (void *) s;
}
  800b20:	5d                   	pop    %ebp
  800b21:	c3                   	ret    

00800b22 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b22:	f3 0f 1e fb          	endbr32 
  800b26:	55                   	push   %ebp
  800b27:	89 e5                	mov    %esp,%ebp
  800b29:	57                   	push   %edi
  800b2a:	56                   	push   %esi
  800b2b:	53                   	push   %ebx
  800b2c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b2f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b32:	eb 03                	jmp    800b37 <strtol+0x15>
		s++;
  800b34:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800b37:	0f b6 01             	movzbl (%ecx),%eax
  800b3a:	3c 20                	cmp    $0x20,%al
  800b3c:	74 f6                	je     800b34 <strtol+0x12>
  800b3e:	3c 09                	cmp    $0x9,%al
  800b40:	74 f2                	je     800b34 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800b42:	3c 2b                	cmp    $0x2b,%al
  800b44:	74 2a                	je     800b70 <strtol+0x4e>
	int neg = 0;
  800b46:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800b4b:	3c 2d                	cmp    $0x2d,%al
  800b4d:	74 2b                	je     800b7a <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b4f:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b55:	75 0f                	jne    800b66 <strtol+0x44>
  800b57:	80 39 30             	cmpb   $0x30,(%ecx)
  800b5a:	74 28                	je     800b84 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b5c:	85 db                	test   %ebx,%ebx
  800b5e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b63:	0f 44 d8             	cmove  %eax,%ebx
  800b66:	b8 00 00 00 00       	mov    $0x0,%eax
  800b6b:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800b6e:	eb 46                	jmp    800bb6 <strtol+0x94>
		s++;
  800b70:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800b73:	bf 00 00 00 00       	mov    $0x0,%edi
  800b78:	eb d5                	jmp    800b4f <strtol+0x2d>
		s++, neg = 1;
  800b7a:	83 c1 01             	add    $0x1,%ecx
  800b7d:	bf 01 00 00 00       	mov    $0x1,%edi
  800b82:	eb cb                	jmp    800b4f <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b84:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b88:	74 0e                	je     800b98 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800b8a:	85 db                	test   %ebx,%ebx
  800b8c:	75 d8                	jne    800b66 <strtol+0x44>
		s++, base = 8;
  800b8e:	83 c1 01             	add    $0x1,%ecx
  800b91:	bb 08 00 00 00       	mov    $0x8,%ebx
  800b96:	eb ce                	jmp    800b66 <strtol+0x44>
		s += 2, base = 16;
  800b98:	83 c1 02             	add    $0x2,%ecx
  800b9b:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ba0:	eb c4                	jmp    800b66 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800ba2:	0f be d2             	movsbl %dl,%edx
  800ba5:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800ba8:	3b 55 10             	cmp    0x10(%ebp),%edx
  800bab:	7d 3a                	jge    800be7 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800bad:	83 c1 01             	add    $0x1,%ecx
  800bb0:	0f af 45 10          	imul   0x10(%ebp),%eax
  800bb4:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800bb6:	0f b6 11             	movzbl (%ecx),%edx
  800bb9:	8d 72 d0             	lea    -0x30(%edx),%esi
  800bbc:	89 f3                	mov    %esi,%ebx
  800bbe:	80 fb 09             	cmp    $0x9,%bl
  800bc1:	76 df                	jbe    800ba2 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800bc3:	8d 72 9f             	lea    -0x61(%edx),%esi
  800bc6:	89 f3                	mov    %esi,%ebx
  800bc8:	80 fb 19             	cmp    $0x19,%bl
  800bcb:	77 08                	ja     800bd5 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800bcd:	0f be d2             	movsbl %dl,%edx
  800bd0:	83 ea 57             	sub    $0x57,%edx
  800bd3:	eb d3                	jmp    800ba8 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800bd5:	8d 72 bf             	lea    -0x41(%edx),%esi
  800bd8:	89 f3                	mov    %esi,%ebx
  800bda:	80 fb 19             	cmp    $0x19,%bl
  800bdd:	77 08                	ja     800be7 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800bdf:	0f be d2             	movsbl %dl,%edx
  800be2:	83 ea 37             	sub    $0x37,%edx
  800be5:	eb c1                	jmp    800ba8 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800be7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800beb:	74 05                	je     800bf2 <strtol+0xd0>
		*endptr = (char *) s;
  800bed:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bf0:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800bf2:	89 c2                	mov    %eax,%edx
  800bf4:	f7 da                	neg    %edx
  800bf6:	85 ff                	test   %edi,%edi
  800bf8:	0f 45 c2             	cmovne %edx,%eax
}
  800bfb:	5b                   	pop    %ebx
  800bfc:	5e                   	pop    %esi
  800bfd:	5f                   	pop    %edi
  800bfe:	5d                   	pop    %ebp
  800bff:	c3                   	ret    

00800c00 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c00:	f3 0f 1e fb          	endbr32 
  800c04:	55                   	push   %ebp
  800c05:	89 e5                	mov    %esp,%ebp
  800c07:	57                   	push   %edi
  800c08:	56                   	push   %esi
  800c09:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c0a:	b8 00 00 00 00       	mov    $0x0,%eax
  800c0f:	8b 55 08             	mov    0x8(%ebp),%edx
  800c12:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c15:	89 c3                	mov    %eax,%ebx
  800c17:	89 c7                	mov    %eax,%edi
  800c19:	89 c6                	mov    %eax,%esi
  800c1b:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c1d:	5b                   	pop    %ebx
  800c1e:	5e                   	pop    %esi
  800c1f:	5f                   	pop    %edi
  800c20:	5d                   	pop    %ebp
  800c21:	c3                   	ret    

00800c22 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c22:	f3 0f 1e fb          	endbr32 
  800c26:	55                   	push   %ebp
  800c27:	89 e5                	mov    %esp,%ebp
  800c29:	57                   	push   %edi
  800c2a:	56                   	push   %esi
  800c2b:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c2c:	ba 00 00 00 00       	mov    $0x0,%edx
  800c31:	b8 01 00 00 00       	mov    $0x1,%eax
  800c36:	89 d1                	mov    %edx,%ecx
  800c38:	89 d3                	mov    %edx,%ebx
  800c3a:	89 d7                	mov    %edx,%edi
  800c3c:	89 d6                	mov    %edx,%esi
  800c3e:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c40:	5b                   	pop    %ebx
  800c41:	5e                   	pop    %esi
  800c42:	5f                   	pop    %edi
  800c43:	5d                   	pop    %ebp
  800c44:	c3                   	ret    

00800c45 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c45:	f3 0f 1e fb          	endbr32 
  800c49:	55                   	push   %ebp
  800c4a:	89 e5                	mov    %esp,%ebp
  800c4c:	57                   	push   %edi
  800c4d:	56                   	push   %esi
  800c4e:	53                   	push   %ebx
  800c4f:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c52:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c57:	8b 55 08             	mov    0x8(%ebp),%edx
  800c5a:	b8 03 00 00 00       	mov    $0x3,%eax
  800c5f:	89 cb                	mov    %ecx,%ebx
  800c61:	89 cf                	mov    %ecx,%edi
  800c63:	89 ce                	mov    %ecx,%esi
  800c65:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c67:	85 c0                	test   %eax,%eax
  800c69:	7f 08                	jg     800c73 <sys_env_destroy+0x2e>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c6b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c6e:	5b                   	pop    %ebx
  800c6f:	5e                   	pop    %esi
  800c70:	5f                   	pop    %edi
  800c71:	5d                   	pop    %ebp
  800c72:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c73:	83 ec 0c             	sub    $0xc,%esp
  800c76:	50                   	push   %eax
  800c77:	6a 03                	push   $0x3
  800c79:	68 24 18 80 00       	push   $0x801824
  800c7e:	6a 23                	push   $0x23
  800c80:	68 41 18 80 00       	push   $0x801841
  800c85:	e8 d4 f4 ff ff       	call   80015e <_panic>

00800c8a <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c8a:	f3 0f 1e fb          	endbr32 
  800c8e:	55                   	push   %ebp
  800c8f:	89 e5                	mov    %esp,%ebp
  800c91:	57                   	push   %edi
  800c92:	56                   	push   %esi
  800c93:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c94:	ba 00 00 00 00       	mov    $0x0,%edx
  800c99:	b8 02 00 00 00       	mov    $0x2,%eax
  800c9e:	89 d1                	mov    %edx,%ecx
  800ca0:	89 d3                	mov    %edx,%ebx
  800ca2:	89 d7                	mov    %edx,%edi
  800ca4:	89 d6                	mov    %edx,%esi
  800ca6:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800ca8:	5b                   	pop    %ebx
  800ca9:	5e                   	pop    %esi
  800caa:	5f                   	pop    %edi
  800cab:	5d                   	pop    %ebp
  800cac:	c3                   	ret    

00800cad <sys_yield>:

void
sys_yield(void)
{
  800cad:	f3 0f 1e fb          	endbr32 
  800cb1:	55                   	push   %ebp
  800cb2:	89 e5                	mov    %esp,%ebp
  800cb4:	57                   	push   %edi
  800cb5:	56                   	push   %esi
  800cb6:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cb7:	ba 00 00 00 00       	mov    $0x0,%edx
  800cbc:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cc1:	89 d1                	mov    %edx,%ecx
  800cc3:	89 d3                	mov    %edx,%ebx
  800cc5:	89 d7                	mov    %edx,%edi
  800cc7:	89 d6                	mov    %edx,%esi
  800cc9:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800ccb:	5b                   	pop    %ebx
  800ccc:	5e                   	pop    %esi
  800ccd:	5f                   	pop    %edi
  800cce:	5d                   	pop    %ebp
  800ccf:	c3                   	ret    

00800cd0 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800cd0:	f3 0f 1e fb          	endbr32 
  800cd4:	55                   	push   %ebp
  800cd5:	89 e5                	mov    %esp,%ebp
  800cd7:	57                   	push   %edi
  800cd8:	56                   	push   %esi
  800cd9:	53                   	push   %ebx
  800cda:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cdd:	be 00 00 00 00       	mov    $0x0,%esi
  800ce2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce8:	b8 04 00 00 00       	mov    $0x4,%eax
  800ced:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cf0:	89 f7                	mov    %esi,%edi
  800cf2:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cf4:	85 c0                	test   %eax,%eax
  800cf6:	7f 08                	jg     800d00 <sys_page_alloc+0x30>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800cf8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cfb:	5b                   	pop    %ebx
  800cfc:	5e                   	pop    %esi
  800cfd:	5f                   	pop    %edi
  800cfe:	5d                   	pop    %ebp
  800cff:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d00:	83 ec 0c             	sub    $0xc,%esp
  800d03:	50                   	push   %eax
  800d04:	6a 04                	push   $0x4
  800d06:	68 24 18 80 00       	push   $0x801824
  800d0b:	6a 23                	push   $0x23
  800d0d:	68 41 18 80 00       	push   $0x801841
  800d12:	e8 47 f4 ff ff       	call   80015e <_panic>

00800d17 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d17:	f3 0f 1e fb          	endbr32 
  800d1b:	55                   	push   %ebp
  800d1c:	89 e5                	mov    %esp,%ebp
  800d1e:	57                   	push   %edi
  800d1f:	56                   	push   %esi
  800d20:	53                   	push   %ebx
  800d21:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d24:	8b 55 08             	mov    0x8(%ebp),%edx
  800d27:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d2a:	b8 05 00 00 00       	mov    $0x5,%eax
  800d2f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d32:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d35:	8b 75 18             	mov    0x18(%ebp),%esi
  800d38:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d3a:	85 c0                	test   %eax,%eax
  800d3c:	7f 08                	jg     800d46 <sys_page_map+0x2f>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d3e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d41:	5b                   	pop    %ebx
  800d42:	5e                   	pop    %esi
  800d43:	5f                   	pop    %edi
  800d44:	5d                   	pop    %ebp
  800d45:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d46:	83 ec 0c             	sub    $0xc,%esp
  800d49:	50                   	push   %eax
  800d4a:	6a 05                	push   $0x5
  800d4c:	68 24 18 80 00       	push   $0x801824
  800d51:	6a 23                	push   $0x23
  800d53:	68 41 18 80 00       	push   $0x801841
  800d58:	e8 01 f4 ff ff       	call   80015e <_panic>

00800d5d <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d5d:	f3 0f 1e fb          	endbr32 
  800d61:	55                   	push   %ebp
  800d62:	89 e5                	mov    %esp,%ebp
  800d64:	57                   	push   %edi
  800d65:	56                   	push   %esi
  800d66:	53                   	push   %ebx
  800d67:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d6a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d6f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d72:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d75:	b8 06 00 00 00       	mov    $0x6,%eax
  800d7a:	89 df                	mov    %ebx,%edi
  800d7c:	89 de                	mov    %ebx,%esi
  800d7e:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d80:	85 c0                	test   %eax,%eax
  800d82:	7f 08                	jg     800d8c <sys_page_unmap+0x2f>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d84:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d87:	5b                   	pop    %ebx
  800d88:	5e                   	pop    %esi
  800d89:	5f                   	pop    %edi
  800d8a:	5d                   	pop    %ebp
  800d8b:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d8c:	83 ec 0c             	sub    $0xc,%esp
  800d8f:	50                   	push   %eax
  800d90:	6a 06                	push   $0x6
  800d92:	68 24 18 80 00       	push   $0x801824
  800d97:	6a 23                	push   $0x23
  800d99:	68 41 18 80 00       	push   $0x801841
  800d9e:	e8 bb f3 ff ff       	call   80015e <_panic>

00800da3 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800da3:	f3 0f 1e fb          	endbr32 
  800da7:	55                   	push   %ebp
  800da8:	89 e5                	mov    %esp,%ebp
  800daa:	57                   	push   %edi
  800dab:	56                   	push   %esi
  800dac:	53                   	push   %ebx
  800dad:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800db0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800db5:	8b 55 08             	mov    0x8(%ebp),%edx
  800db8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dbb:	b8 08 00 00 00       	mov    $0x8,%eax
  800dc0:	89 df                	mov    %ebx,%edi
  800dc2:	89 de                	mov    %ebx,%esi
  800dc4:	cd 30                	int    $0x30
	if(check && ret > 0)
  800dc6:	85 c0                	test   %eax,%eax
  800dc8:	7f 08                	jg     800dd2 <sys_env_set_status+0x2f>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800dca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dcd:	5b                   	pop    %ebx
  800dce:	5e                   	pop    %esi
  800dcf:	5f                   	pop    %edi
  800dd0:	5d                   	pop    %ebp
  800dd1:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800dd2:	83 ec 0c             	sub    $0xc,%esp
  800dd5:	50                   	push   %eax
  800dd6:	6a 08                	push   $0x8
  800dd8:	68 24 18 80 00       	push   $0x801824
  800ddd:	6a 23                	push   $0x23
  800ddf:	68 41 18 80 00       	push   $0x801841
  800de4:	e8 75 f3 ff ff       	call   80015e <_panic>

00800de9 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800de9:	f3 0f 1e fb          	endbr32 
  800ded:	55                   	push   %ebp
  800dee:	89 e5                	mov    %esp,%ebp
  800df0:	57                   	push   %edi
  800df1:	56                   	push   %esi
  800df2:	53                   	push   %ebx
  800df3:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800df6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dfb:	8b 55 08             	mov    0x8(%ebp),%edx
  800dfe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e01:	b8 09 00 00 00       	mov    $0x9,%eax
  800e06:	89 df                	mov    %ebx,%edi
  800e08:	89 de                	mov    %ebx,%esi
  800e0a:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e0c:	85 c0                	test   %eax,%eax
  800e0e:	7f 08                	jg     800e18 <sys_env_set_pgfault_upcall+0x2f>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e10:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e13:	5b                   	pop    %ebx
  800e14:	5e                   	pop    %esi
  800e15:	5f                   	pop    %edi
  800e16:	5d                   	pop    %ebp
  800e17:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e18:	83 ec 0c             	sub    $0xc,%esp
  800e1b:	50                   	push   %eax
  800e1c:	6a 09                	push   $0x9
  800e1e:	68 24 18 80 00       	push   $0x801824
  800e23:	6a 23                	push   $0x23
  800e25:	68 41 18 80 00       	push   $0x801841
  800e2a:	e8 2f f3 ff ff       	call   80015e <_panic>

00800e2f <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e2f:	f3 0f 1e fb          	endbr32 
  800e33:	55                   	push   %ebp
  800e34:	89 e5                	mov    %esp,%ebp
  800e36:	57                   	push   %edi
  800e37:	56                   	push   %esi
  800e38:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e39:	8b 55 08             	mov    0x8(%ebp),%edx
  800e3c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e3f:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e44:	be 00 00 00 00       	mov    $0x0,%esi
  800e49:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e4c:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e4f:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e51:	5b                   	pop    %ebx
  800e52:	5e                   	pop    %esi
  800e53:	5f                   	pop    %edi
  800e54:	5d                   	pop    %ebp
  800e55:	c3                   	ret    

00800e56 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e56:	f3 0f 1e fb          	endbr32 
  800e5a:	55                   	push   %ebp
  800e5b:	89 e5                	mov    %esp,%ebp
  800e5d:	57                   	push   %edi
  800e5e:	56                   	push   %esi
  800e5f:	53                   	push   %ebx
  800e60:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e63:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e68:	8b 55 08             	mov    0x8(%ebp),%edx
  800e6b:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e70:	89 cb                	mov    %ecx,%ebx
  800e72:	89 cf                	mov    %ecx,%edi
  800e74:	89 ce                	mov    %ecx,%esi
  800e76:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e78:	85 c0                	test   %eax,%eax
  800e7a:	7f 08                	jg     800e84 <sys_ipc_recv+0x2e>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e7c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e7f:	5b                   	pop    %ebx
  800e80:	5e                   	pop    %esi
  800e81:	5f                   	pop    %edi
  800e82:	5d                   	pop    %ebp
  800e83:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e84:	83 ec 0c             	sub    $0xc,%esp
  800e87:	50                   	push   %eax
  800e88:	6a 0c                	push   $0xc
  800e8a:	68 24 18 80 00       	push   $0x801824
  800e8f:	6a 23                	push   $0x23
  800e91:	68 41 18 80 00       	push   $0x801841
  800e96:	e8 c3 f2 ff ff       	call   80015e <_panic>

00800e9b <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e9b:	f3 0f 1e fb          	endbr32 
  800e9f:	55                   	push   %ebp
  800ea0:	89 e5                	mov    %esp,%ebp
  800ea2:	53                   	push   %ebx
  800ea3:	83 ec 04             	sub    $0x4,%esp
  800ea6:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800ea9:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if(!(err & FEC_WR)){
  800eab:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800eaf:	74 74                	je     800f25 <pgfault+0x8a>
        panic("trapno is not FEC_WR");
    }
    if(!(uvpt[PGNUM(addr)] & PTE_COW)){
  800eb1:	89 d8                	mov    %ebx,%eax
  800eb3:	c1 e8 0c             	shr    $0xc,%eax
  800eb6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800ebd:	f6 c4 08             	test   $0x8,%ah
  800ec0:	74 77                	je     800f39 <pgfault+0x9e>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	addr = ROUNDDOWN(addr, PGSIZE);
  800ec2:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
    if ((r = sys_page_map(0, addr, 0, PFTEMP, PTE_U | PTE_P)) < 0)
  800ec8:	83 ec 0c             	sub    $0xc,%esp
  800ecb:	6a 05                	push   $0x5
  800ecd:	68 00 f0 7f 00       	push   $0x7ff000
  800ed2:	6a 00                	push   $0x0
  800ed4:	53                   	push   %ebx
  800ed5:	6a 00                	push   $0x0
  800ed7:	e8 3b fe ff ff       	call   800d17 <sys_page_map>
  800edc:	83 c4 20             	add    $0x20,%esp
  800edf:	85 c0                	test   %eax,%eax
  800ee1:	78 6a                	js     800f4d <pgfault+0xb2>
        panic("sys_page_map: %e", r);
    if ((r = sys_page_alloc(0, addr, PTE_W | PTE_U | PTE_P)) < 0)
  800ee3:	83 ec 04             	sub    $0x4,%esp
  800ee6:	6a 07                	push   $0x7
  800ee8:	53                   	push   %ebx
  800ee9:	6a 00                	push   $0x0
  800eeb:	e8 e0 fd ff ff       	call   800cd0 <sys_page_alloc>
  800ef0:	83 c4 10             	add    $0x10,%esp
  800ef3:	85 c0                	test   %eax,%eax
  800ef5:	78 68                	js     800f5f <pgfault+0xc4>
        panic("sys_page_alloc: %e", r);
    memmove(addr, PFTEMP, PGSIZE);
  800ef7:	83 ec 04             	sub    $0x4,%esp
  800efa:	68 00 10 00 00       	push   $0x1000
  800eff:	68 00 f0 7f 00       	push   $0x7ff000
  800f04:	53                   	push   %ebx
  800f05:	e8 3a fb ff ff       	call   800a44 <memmove>
    if ((r = sys_page_unmap(0, PFTEMP)) < 0)
  800f0a:	83 c4 08             	add    $0x8,%esp
  800f0d:	68 00 f0 7f 00       	push   $0x7ff000
  800f12:	6a 00                	push   $0x0
  800f14:	e8 44 fe ff ff       	call   800d5d <sys_page_unmap>
  800f19:	83 c4 10             	add    $0x10,%esp
  800f1c:	85 c0                	test   %eax,%eax
  800f1e:	78 51                	js     800f71 <pgfault+0xd6>
        panic("sys_page_unmap: %e", r);

	//panic("pgfault not implemented");
}
  800f20:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f23:	c9                   	leave  
  800f24:	c3                   	ret    
        panic("trapno is not FEC_WR");
  800f25:	83 ec 04             	sub    $0x4,%esp
  800f28:	68 4f 18 80 00       	push   $0x80184f
  800f2d:	6a 1d                	push   $0x1d
  800f2f:	68 64 18 80 00       	push   $0x801864
  800f34:	e8 25 f2 ff ff       	call   80015e <_panic>
        panic("fault addr is not COW");
  800f39:	83 ec 04             	sub    $0x4,%esp
  800f3c:	68 6f 18 80 00       	push   $0x80186f
  800f41:	6a 20                	push   $0x20
  800f43:	68 64 18 80 00       	push   $0x801864
  800f48:	e8 11 f2 ff ff       	call   80015e <_panic>
        panic("sys_page_map: %e", r);
  800f4d:	50                   	push   %eax
  800f4e:	68 85 18 80 00       	push   $0x801885
  800f53:	6a 2c                	push   $0x2c
  800f55:	68 64 18 80 00       	push   $0x801864
  800f5a:	e8 ff f1 ff ff       	call   80015e <_panic>
        panic("sys_page_alloc: %e", r);
  800f5f:	50                   	push   %eax
  800f60:	68 96 18 80 00       	push   $0x801896
  800f65:	6a 2e                	push   $0x2e
  800f67:	68 64 18 80 00       	push   $0x801864
  800f6c:	e8 ed f1 ff ff       	call   80015e <_panic>
        panic("sys_page_unmap: %e", r);
  800f71:	50                   	push   %eax
  800f72:	68 a9 18 80 00       	push   $0x8018a9
  800f77:	6a 31                	push   $0x31
  800f79:	68 64 18 80 00       	push   $0x801864
  800f7e:	e8 db f1 ff ff       	call   80015e <_panic>

00800f83 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f83:	f3 0f 1e fb          	endbr32 
  800f87:	55                   	push   %ebp
  800f88:	89 e5                	mov    %esp,%ebp
  800f8a:	57                   	push   %edi
  800f8b:	56                   	push   %esi
  800f8c:	53                   	push   %ebx
  800f8d:	83 ec 28             	sub    $0x28,%esp
    extern void _pgfault_upcall(void);

	set_pgfault_handler(pgfault);
  800f90:	68 9b 0e 80 00       	push   $0x800e9b
  800f95:	e8 ff 02 00 00       	call   801299 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800f9a:	b8 07 00 00 00       	mov    $0x7,%eax
  800f9f:	cd 30                	int    $0x30
  800fa1:	89 45 e4             	mov    %eax,-0x1c(%ebp)

    envid_t envid = sys_exofork();
    if (envid < 0)
  800fa4:	83 c4 10             	add    $0x10,%esp
  800fa7:	85 c0                	test   %eax,%eax
  800fa9:	78 2d                	js     800fd8 <fork+0x55>
  800fab:	89 c7                	mov    %eax,%edi
        thisenv = &envs[ENVX(sys_getenvid())];
        return 0;
    }

    // Parent
    for(uint32_t addr = 0; addr < USTACKTOP; addr += PGSIZE){
  800fad:	bb 00 00 00 00       	mov    $0x0,%ebx
    if (envid == 0) {
  800fb2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800fb6:	0f 85 92 00 00 00    	jne    80104e <fork+0xcb>
        thisenv = &envs[ENVX(sys_getenvid())];
  800fbc:	e8 c9 fc ff ff       	call   800c8a <sys_getenvid>
  800fc1:	25 ff 03 00 00       	and    $0x3ff,%eax
  800fc6:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800fc9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800fce:	a3 04 20 80 00       	mov    %eax,0x802004
        return 0;
  800fd3:	e9 57 01 00 00       	jmp    80112f <fork+0x1ac>
        panic("sys_exofork Failed, envid: %e", envid);
  800fd8:	50                   	push   %eax
  800fd9:	68 bc 18 80 00       	push   $0x8018bc
  800fde:	6a 71                	push   $0x71
  800fe0:	68 64 18 80 00       	push   $0x801864
  800fe5:	e8 74 f1 ff ff       	call   80015e <_panic>
        sys_page_map(0, addr, envid, addr, PTE_SYSCALL);
  800fea:	83 ec 0c             	sub    $0xc,%esp
  800fed:	68 07 0e 00 00       	push   $0xe07
  800ff2:	56                   	push   %esi
  800ff3:	57                   	push   %edi
  800ff4:	56                   	push   %esi
  800ff5:	6a 00                	push   $0x0
  800ff7:	e8 1b fd ff ff       	call   800d17 <sys_page_map>
  800ffc:	83 c4 20             	add    $0x20,%esp
  800fff:	eb 3b                	jmp    80103c <fork+0xb9>
        if ((r = sys_page_map(0, addr, envid, addr, PTE_COW|PTE_U|PTE_P)) < 0)
  801001:	83 ec 0c             	sub    $0xc,%esp
  801004:	68 05 08 00 00       	push   $0x805
  801009:	56                   	push   %esi
  80100a:	57                   	push   %edi
  80100b:	56                   	push   %esi
  80100c:	6a 00                	push   $0x0
  80100e:	e8 04 fd ff ff       	call   800d17 <sys_page_map>
  801013:	83 c4 20             	add    $0x20,%esp
  801016:	85 c0                	test   %eax,%eax
  801018:	0f 88 a9 00 00 00    	js     8010c7 <fork+0x144>
		if ((r = sys_page_map(0, addr, 0, addr, PTE_COW|PTE_U|PTE_P)) < 0)
  80101e:	83 ec 0c             	sub    $0xc,%esp
  801021:	68 05 08 00 00       	push   $0x805
  801026:	56                   	push   %esi
  801027:	6a 00                	push   $0x0
  801029:	56                   	push   %esi
  80102a:	6a 00                	push   $0x0
  80102c:	e8 e6 fc ff ff       	call   800d17 <sys_page_map>
  801031:	83 c4 20             	add    $0x20,%esp
  801034:	85 c0                	test   %eax,%eax
  801036:	0f 88 9d 00 00 00    	js     8010d9 <fork+0x156>
    for(uint32_t addr = 0; addr < USTACKTOP; addr += PGSIZE){
  80103c:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801042:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  801048:	0f 84 9d 00 00 00    	je     8010eb <fork+0x168>
		if((uvpd[PDX(addr)] & PTE_P) && 
  80104e:	89 d8                	mov    %ebx,%eax
  801050:	c1 e8 16             	shr    $0x16,%eax
  801053:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80105a:	a8 01                	test   $0x1,%al
  80105c:	74 de                	je     80103c <fork+0xb9>
		(uvpt[PGNUM(addr)]&PTE_P) && 
  80105e:	89 d8                	mov    %ebx,%eax
  801060:	c1 e8 0c             	shr    $0xc,%eax
  801063:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
		if((uvpd[PDX(addr)] & PTE_P) && 
  80106a:	f6 c2 01             	test   $0x1,%dl
  80106d:	74 cd                	je     80103c <fork+0xb9>
		(uvpt[PGNUM(addr)] &PTE_U)){
  80106f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
		(uvpt[PGNUM(addr)]&PTE_P) && 
  801076:	f6 c2 04             	test   $0x4,%dl
  801079:	74 c1                	je     80103c <fork+0xb9>
    void *addr=(void *)(pn*PGSIZE);
  80107b:	89 c6                	mov    %eax,%esi
  80107d:	c1 e6 0c             	shl    $0xc,%esi
    if(uvpt[pn] & PTE_SHARE){
  801080:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801087:	f6 c6 04             	test   $0x4,%dh
  80108a:	0f 85 5a ff ff ff    	jne    800fea <fork+0x67>
    else if((uvpt[pn]&PTE_W)|| (uvpt[pn] & PTE_COW)){
  801090:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801097:	f6 c2 02             	test   $0x2,%dl
  80109a:	0f 85 61 ff ff ff    	jne    801001 <fork+0x7e>
  8010a0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010a7:	f6 c4 08             	test   $0x8,%ah
  8010aa:	0f 85 51 ff ff ff    	jne    801001 <fork+0x7e>
        sys_page_map(0, addr, envid, addr, PTE_U|PTE_P);
  8010b0:	83 ec 0c             	sub    $0xc,%esp
  8010b3:	6a 05                	push   $0x5
  8010b5:	56                   	push   %esi
  8010b6:	57                   	push   %edi
  8010b7:	56                   	push   %esi
  8010b8:	6a 00                	push   $0x0
  8010ba:	e8 58 fc ff ff       	call   800d17 <sys_page_map>
  8010bf:	83 c4 20             	add    $0x20,%esp
  8010c2:	e9 75 ff ff ff       	jmp    80103c <fork+0xb9>
			panic("sys_page_map：%e", r);
  8010c7:	50                   	push   %eax
  8010c8:	68 da 18 80 00       	push   $0x8018da
  8010cd:	6a 4d                	push   $0x4d
  8010cf:	68 64 18 80 00       	push   $0x801864
  8010d4:	e8 85 f0 ff ff       	call   80015e <_panic>
			panic("sys_page_map：%e", r);
  8010d9:	50                   	push   %eax
  8010da:	68 da 18 80 00       	push   $0x8018da
  8010df:	6a 4f                	push   $0x4f
  8010e1:	68 64 18 80 00       	push   $0x801864
  8010e6:	e8 73 f0 ff ff       	call   80015e <_panic>
			duppage(envid, PGNUM(addr));
		}
	}

    // Allocate a new page for the child's user exception stack
    int r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_P|PTE_W|PTE_U);
  8010eb:	83 ec 04             	sub    $0x4,%esp
  8010ee:	6a 07                	push   $0x7
  8010f0:	68 00 f0 bf ee       	push   $0xeebff000
  8010f5:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010f8:	e8 d3 fb ff ff       	call   800cd0 <sys_page_alloc>
	if( r < 0)
  8010fd:	83 c4 10             	add    $0x10,%esp
  801100:	85 c0                	test   %eax,%eax
  801102:	78 36                	js     80113a <fork+0x1b7>
		panic("sys_page_alloc: %e", r);

    // Set the page fault upcall for the child
    r=sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  801104:	83 ec 08             	sub    $0x8,%esp
  801107:	68 f6 12 80 00       	push   $0x8012f6
  80110c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80110f:	e8 d5 fc ff ff       	call   800de9 <sys_env_set_pgfault_upcall>
    if( r < 0 )
  801114:	83 c4 10             	add    $0x10,%esp
  801117:	85 c0                	test   %eax,%eax
  801119:	78 34                	js     80114f <fork+0x1cc>
		panic("sys_env_set_pgfault_upcall: %e",r);
    
    // Mark the child as runnable
    r=sys_env_set_status(envid, ENV_RUNNABLE);
  80111b:	83 ec 08             	sub    $0x8,%esp
  80111e:	6a 02                	push   $0x2
  801120:	ff 75 e4             	pushl  -0x1c(%ebp)
  801123:	e8 7b fc ff ff       	call   800da3 <sys_env_set_status>
    if (r < 0)
  801128:	83 c4 10             	add    $0x10,%esp
  80112b:	85 c0                	test   %eax,%eax
  80112d:	78 35                	js     801164 <fork+0x1e1>
		panic("sys_env_set_status: %e", r);
    
    return envid;
	// LAB 4: Your code here.
	//panic("fork not implemented");
}
  80112f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801132:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801135:	5b                   	pop    %ebx
  801136:	5e                   	pop    %esi
  801137:	5f                   	pop    %edi
  801138:	5d                   	pop    %ebp
  801139:	c3                   	ret    
		panic("sys_page_alloc: %e", r);
  80113a:	50                   	push   %eax
  80113b:	68 96 18 80 00       	push   $0x801896
  801140:	68 84 00 00 00       	push   $0x84
  801145:	68 64 18 80 00       	push   $0x801864
  80114a:	e8 0f f0 ff ff       	call   80015e <_panic>
		panic("sys_env_set_pgfault_upcall: %e",r);
  80114f:	50                   	push   %eax
  801150:	68 1c 19 80 00       	push   $0x80191c
  801155:	68 89 00 00 00       	push   $0x89
  80115a:	68 64 18 80 00       	push   $0x801864
  80115f:	e8 fa ef ff ff       	call   80015e <_panic>
		panic("sys_env_set_status: %e", r);
  801164:	50                   	push   %eax
  801165:	68 ec 18 80 00       	push   $0x8018ec
  80116a:	68 8e 00 00 00       	push   $0x8e
  80116f:	68 64 18 80 00       	push   $0x801864
  801174:	e8 e5 ef ff ff       	call   80015e <_panic>

00801179 <sfork>:

// Challenge!
int
sfork(void)
{
  801179:	f3 0f 1e fb          	endbr32 
  80117d:	55                   	push   %ebp
  80117e:	89 e5                	mov    %esp,%ebp
  801180:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801183:	68 03 19 80 00       	push   $0x801903
  801188:	68 99 00 00 00       	push   $0x99
  80118d:	68 64 18 80 00       	push   $0x801864
  801192:	e8 c7 ef ff ff       	call   80015e <_panic>

00801197 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801197:	f3 0f 1e fb          	endbr32 
  80119b:	55                   	push   %ebp
  80119c:	89 e5                	mov    %esp,%ebp
  80119e:	56                   	push   %esi
  80119f:	53                   	push   %ebx
  8011a0:	8b 75 08             	mov    0x8(%ebp),%esi
  8011a3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011a6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// 检查pg是否为空
	if(pg==NULL){
		pg=(void *)-1;
  8011a9:	85 c0                	test   %eax,%eax
  8011ab:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  8011b0:	0f 44 c2             	cmove  %edx,%eax
	}
	//接收 message
	int r = sys_ipc_recv(pg);
  8011b3:	83 ec 0c             	sub    $0xc,%esp
  8011b6:	50                   	push   %eax
  8011b7:	e8 9a fc ff ff       	call   800e56 <sys_ipc_recv>
	if(r<0){
  8011bc:	83 c4 10             	add    $0x10,%esp
  8011bf:	85 c0                	test   %eax,%eax
  8011c1:	78 2b                	js     8011ee <ipc_recv+0x57>
		if(from_env_store) *from_env_store=0;
		if(perm_store) *perm_store=0;
		return r;
	}
	// 保存发送者的envid
	if(from_env_store) *from_env_store = thisenv->env_ipc_from;
  8011c3:	85 f6                	test   %esi,%esi
  8011c5:	74 0a                	je     8011d1 <ipc_recv+0x3a>
  8011c7:	a1 04 20 80 00       	mov    0x802004,%eax
  8011cc:	8b 40 74             	mov    0x74(%eax),%eax
  8011cf:	89 06                	mov    %eax,(%esi)
	// 保存发送来的页面的权限
	if(perm_store) *perm_store = thisenv->env_ipc_perm;
  8011d1:	85 db                	test   %ebx,%ebx
  8011d3:	74 0a                	je     8011df <ipc_recv+0x48>
  8011d5:	a1 04 20 80 00       	mov    0x802004,%eax
  8011da:	8b 40 78             	mov    0x78(%eax),%eax
  8011dd:	89 03                	mov    %eax,(%ebx)
	// 返回message的value
	return thisenv->env_ipc_value;
  8011df:	a1 04 20 80 00       	mov    0x802004,%eax
  8011e4:	8b 40 70             	mov    0x70(%eax),%eax

	//panic("ipc_recv not implemented");
	return 0;
}
  8011e7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011ea:	5b                   	pop    %ebx
  8011eb:	5e                   	pop    %esi
  8011ec:	5d                   	pop    %ebp
  8011ed:	c3                   	ret    
		if(from_env_store) *from_env_store=0;
  8011ee:	85 f6                	test   %esi,%esi
  8011f0:	74 06                	je     8011f8 <ipc_recv+0x61>
  8011f2:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store) *perm_store=0;
  8011f8:	85 db                	test   %ebx,%ebx
  8011fa:	74 eb                	je     8011e7 <ipc_recv+0x50>
  8011fc:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801202:	eb e3                	jmp    8011e7 <ipc_recv+0x50>

00801204 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801204:	f3 0f 1e fb          	endbr32 
  801208:	55                   	push   %ebp
  801209:	89 e5                	mov    %esp,%ebp
  80120b:	57                   	push   %edi
  80120c:	56                   	push   %esi
  80120d:	53                   	push   %ebx
  80120e:	83 ec 0c             	sub    $0xc,%esp
  801211:	8b 7d 08             	mov    0x8(%ebp),%edi
  801214:	8b 75 0c             	mov    0xc(%ebp),%esi
  801217:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	// 如果pg为NULL， 要提供给sys_ipc_try_send一个能表达“no page”的值，0是有效的地址
	if(pg==NULL)
	{
		pg = (void *)-1;
  80121a:	85 db                	test   %ebx,%ebx
  80121c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801221:	0f 44 d8             	cmove  %eax,%ebx
	}
	int r;
	//不停尝试发送消息直到成功
	while(1)
	{
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801224:	ff 75 14             	pushl  0x14(%ebp)
  801227:	53                   	push   %ebx
  801228:	56                   	push   %esi
  801229:	57                   	push   %edi
  80122a:	e8 00 fc ff ff       	call   800e2f <sys_ipc_try_send>
		if (r == 0) {		//发送成功
  80122f:	83 c4 10             	add    $0x10,%esp
  801232:	85 c0                	test   %eax,%eax
  801234:	74 1e                	je     801254 <ipc_send+0x50>
			return;
		} else if (r == -E_IPC_NOT_RECV) {	//接收环境未准备接收
  801236:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801239:	75 07                	jne    801242 <ipc_send+0x3e>
			sys_yield();
  80123b:	e8 6d fa ff ff       	call   800cad <sys_yield>
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801240:	eb e2                	jmp    801224 <ipc_send+0x20>
		}else{
			panic("ipc_send() fault:%e\n", r);
  801242:	50                   	push   %eax
  801243:	68 3b 19 80 00       	push   $0x80193b
  801248:	6a 4c                	push   $0x4c
  80124a:	68 50 19 80 00       	push   $0x801950
  80124f:	e8 0a ef ff ff       	call   80015e <_panic>
		}
	}
}
  801254:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801257:	5b                   	pop    %ebx
  801258:	5e                   	pop    %esi
  801259:	5f                   	pop    %edi
  80125a:	5d                   	pop    %ebp
  80125b:	c3                   	ret    

0080125c <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80125c:	f3 0f 1e fb          	endbr32 
  801260:	55                   	push   %ebp
  801261:	89 e5                	mov    %esp,%ebp
  801263:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801266:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80126b:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80126e:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801274:	8b 52 50             	mov    0x50(%edx),%edx
  801277:	39 ca                	cmp    %ecx,%edx
  801279:	74 11                	je     80128c <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  80127b:	83 c0 01             	add    $0x1,%eax
  80127e:	3d 00 04 00 00       	cmp    $0x400,%eax
  801283:	75 e6                	jne    80126b <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  801285:	b8 00 00 00 00       	mov    $0x0,%eax
  80128a:	eb 0b                	jmp    801297 <ipc_find_env+0x3b>
			return envs[i].env_id;
  80128c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80128f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801294:	8b 40 48             	mov    0x48(%eax),%eax
}
  801297:	5d                   	pop    %ebp
  801298:	c3                   	ret    

00801299 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801299:	f3 0f 1e fb          	endbr32 
  80129d:	55                   	push   %ebp
  80129e:	89 e5                	mov    %esp,%ebp
  8012a0:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  8012a3:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  8012aa:	74 0a                	je     8012b6 <set_pgfault_handler+0x1d>
        sys_env_set_pgfault_upcall(0, _pgfault_upcall);
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8012ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8012af:	a3 08 20 80 00       	mov    %eax,0x802008
}
  8012b4:	c9                   	leave  
  8012b5:	c3                   	ret    
		if (sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P) < 0)
  8012b6:	83 ec 04             	sub    $0x4,%esp
  8012b9:	6a 07                	push   $0x7
  8012bb:	68 00 f0 bf ee       	push   $0xeebff000
  8012c0:	6a 00                	push   $0x0
  8012c2:	e8 09 fa ff ff       	call   800cd0 <sys_page_alloc>
  8012c7:	83 c4 10             	add    $0x10,%esp
  8012ca:	85 c0                	test   %eax,%eax
  8012cc:	78 14                	js     8012e2 <set_pgfault_handler+0x49>
        sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  8012ce:	83 ec 08             	sub    $0x8,%esp
  8012d1:	68 f6 12 80 00       	push   $0x8012f6
  8012d6:	6a 00                	push   $0x0
  8012d8:	e8 0c fb ff ff       	call   800de9 <sys_env_set_pgfault_upcall>
  8012dd:	83 c4 10             	add    $0x10,%esp
  8012e0:	eb ca                	jmp    8012ac <set_pgfault_handler+0x13>
            panic("set_pgfault_handler failed.");
  8012e2:	83 ec 04             	sub    $0x4,%esp
  8012e5:	68 5a 19 80 00       	push   $0x80195a
  8012ea:	6a 21                	push   $0x21
  8012ec:	68 76 19 80 00       	push   $0x801976
  8012f1:	e8 68 ee ff ff       	call   80015e <_panic>

008012f6 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8012f6:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8012f7:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  8012fc:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8012fe:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	addl $8, %esp
  801301:	83 c4 08             	add    $0x8,%esp
	movl 32(%esp), %eax
  801304:	8b 44 24 20          	mov    0x20(%esp),%eax
	movl 40(%esp), %edx
  801308:	8b 54 24 28          	mov    0x28(%esp),%edx
	subl $4, %edx
  80130c:	83 ea 04             	sub    $0x4,%edx
	movl %eax, (%edx)
  80130f:	89 02                	mov    %eax,(%edx)
	movl %edx, 40(%esp)
  801311:	89 54 24 28          	mov    %edx,0x28(%esp)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal
  801315:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp
  801316:	83 c4 04             	add    $0x4,%esp
	popfl
  801319:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  80131a:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  80131b:	c3                   	ret    
  80131c:	66 90                	xchg   %ax,%ax
  80131e:	66 90                	xchg   %ax,%ax

00801320 <__udivdi3>:
  801320:	f3 0f 1e fb          	endbr32 
  801324:	55                   	push   %ebp
  801325:	57                   	push   %edi
  801326:	56                   	push   %esi
  801327:	53                   	push   %ebx
  801328:	83 ec 1c             	sub    $0x1c,%esp
  80132b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80132f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  801333:	8b 74 24 34          	mov    0x34(%esp),%esi
  801337:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  80133b:	85 d2                	test   %edx,%edx
  80133d:	75 19                	jne    801358 <__udivdi3+0x38>
  80133f:	39 f3                	cmp    %esi,%ebx
  801341:	76 4d                	jbe    801390 <__udivdi3+0x70>
  801343:	31 ff                	xor    %edi,%edi
  801345:	89 e8                	mov    %ebp,%eax
  801347:	89 f2                	mov    %esi,%edx
  801349:	f7 f3                	div    %ebx
  80134b:	89 fa                	mov    %edi,%edx
  80134d:	83 c4 1c             	add    $0x1c,%esp
  801350:	5b                   	pop    %ebx
  801351:	5e                   	pop    %esi
  801352:	5f                   	pop    %edi
  801353:	5d                   	pop    %ebp
  801354:	c3                   	ret    
  801355:	8d 76 00             	lea    0x0(%esi),%esi
  801358:	39 f2                	cmp    %esi,%edx
  80135a:	76 14                	jbe    801370 <__udivdi3+0x50>
  80135c:	31 ff                	xor    %edi,%edi
  80135e:	31 c0                	xor    %eax,%eax
  801360:	89 fa                	mov    %edi,%edx
  801362:	83 c4 1c             	add    $0x1c,%esp
  801365:	5b                   	pop    %ebx
  801366:	5e                   	pop    %esi
  801367:	5f                   	pop    %edi
  801368:	5d                   	pop    %ebp
  801369:	c3                   	ret    
  80136a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801370:	0f bd fa             	bsr    %edx,%edi
  801373:	83 f7 1f             	xor    $0x1f,%edi
  801376:	75 48                	jne    8013c0 <__udivdi3+0xa0>
  801378:	39 f2                	cmp    %esi,%edx
  80137a:	72 06                	jb     801382 <__udivdi3+0x62>
  80137c:	31 c0                	xor    %eax,%eax
  80137e:	39 eb                	cmp    %ebp,%ebx
  801380:	77 de                	ja     801360 <__udivdi3+0x40>
  801382:	b8 01 00 00 00       	mov    $0x1,%eax
  801387:	eb d7                	jmp    801360 <__udivdi3+0x40>
  801389:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801390:	89 d9                	mov    %ebx,%ecx
  801392:	85 db                	test   %ebx,%ebx
  801394:	75 0b                	jne    8013a1 <__udivdi3+0x81>
  801396:	b8 01 00 00 00       	mov    $0x1,%eax
  80139b:	31 d2                	xor    %edx,%edx
  80139d:	f7 f3                	div    %ebx
  80139f:	89 c1                	mov    %eax,%ecx
  8013a1:	31 d2                	xor    %edx,%edx
  8013a3:	89 f0                	mov    %esi,%eax
  8013a5:	f7 f1                	div    %ecx
  8013a7:	89 c6                	mov    %eax,%esi
  8013a9:	89 e8                	mov    %ebp,%eax
  8013ab:	89 f7                	mov    %esi,%edi
  8013ad:	f7 f1                	div    %ecx
  8013af:	89 fa                	mov    %edi,%edx
  8013b1:	83 c4 1c             	add    $0x1c,%esp
  8013b4:	5b                   	pop    %ebx
  8013b5:	5e                   	pop    %esi
  8013b6:	5f                   	pop    %edi
  8013b7:	5d                   	pop    %ebp
  8013b8:	c3                   	ret    
  8013b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8013c0:	89 f9                	mov    %edi,%ecx
  8013c2:	b8 20 00 00 00       	mov    $0x20,%eax
  8013c7:	29 f8                	sub    %edi,%eax
  8013c9:	d3 e2                	shl    %cl,%edx
  8013cb:	89 54 24 08          	mov    %edx,0x8(%esp)
  8013cf:	89 c1                	mov    %eax,%ecx
  8013d1:	89 da                	mov    %ebx,%edx
  8013d3:	d3 ea                	shr    %cl,%edx
  8013d5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8013d9:	09 d1                	or     %edx,%ecx
  8013db:	89 f2                	mov    %esi,%edx
  8013dd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8013e1:	89 f9                	mov    %edi,%ecx
  8013e3:	d3 e3                	shl    %cl,%ebx
  8013e5:	89 c1                	mov    %eax,%ecx
  8013e7:	d3 ea                	shr    %cl,%edx
  8013e9:	89 f9                	mov    %edi,%ecx
  8013eb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8013ef:	89 eb                	mov    %ebp,%ebx
  8013f1:	d3 e6                	shl    %cl,%esi
  8013f3:	89 c1                	mov    %eax,%ecx
  8013f5:	d3 eb                	shr    %cl,%ebx
  8013f7:	09 de                	or     %ebx,%esi
  8013f9:	89 f0                	mov    %esi,%eax
  8013fb:	f7 74 24 08          	divl   0x8(%esp)
  8013ff:	89 d6                	mov    %edx,%esi
  801401:	89 c3                	mov    %eax,%ebx
  801403:	f7 64 24 0c          	mull   0xc(%esp)
  801407:	39 d6                	cmp    %edx,%esi
  801409:	72 15                	jb     801420 <__udivdi3+0x100>
  80140b:	89 f9                	mov    %edi,%ecx
  80140d:	d3 e5                	shl    %cl,%ebp
  80140f:	39 c5                	cmp    %eax,%ebp
  801411:	73 04                	jae    801417 <__udivdi3+0xf7>
  801413:	39 d6                	cmp    %edx,%esi
  801415:	74 09                	je     801420 <__udivdi3+0x100>
  801417:	89 d8                	mov    %ebx,%eax
  801419:	31 ff                	xor    %edi,%edi
  80141b:	e9 40 ff ff ff       	jmp    801360 <__udivdi3+0x40>
  801420:	8d 43 ff             	lea    -0x1(%ebx),%eax
  801423:	31 ff                	xor    %edi,%edi
  801425:	e9 36 ff ff ff       	jmp    801360 <__udivdi3+0x40>
  80142a:	66 90                	xchg   %ax,%ax
  80142c:	66 90                	xchg   %ax,%ax
  80142e:	66 90                	xchg   %ax,%ax

00801430 <__umoddi3>:
  801430:	f3 0f 1e fb          	endbr32 
  801434:	55                   	push   %ebp
  801435:	57                   	push   %edi
  801436:	56                   	push   %esi
  801437:	53                   	push   %ebx
  801438:	83 ec 1c             	sub    $0x1c,%esp
  80143b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80143f:	8b 74 24 30          	mov    0x30(%esp),%esi
  801443:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  801447:	8b 7c 24 38          	mov    0x38(%esp),%edi
  80144b:	85 c0                	test   %eax,%eax
  80144d:	75 19                	jne    801468 <__umoddi3+0x38>
  80144f:	39 df                	cmp    %ebx,%edi
  801451:	76 5d                	jbe    8014b0 <__umoddi3+0x80>
  801453:	89 f0                	mov    %esi,%eax
  801455:	89 da                	mov    %ebx,%edx
  801457:	f7 f7                	div    %edi
  801459:	89 d0                	mov    %edx,%eax
  80145b:	31 d2                	xor    %edx,%edx
  80145d:	83 c4 1c             	add    $0x1c,%esp
  801460:	5b                   	pop    %ebx
  801461:	5e                   	pop    %esi
  801462:	5f                   	pop    %edi
  801463:	5d                   	pop    %ebp
  801464:	c3                   	ret    
  801465:	8d 76 00             	lea    0x0(%esi),%esi
  801468:	89 f2                	mov    %esi,%edx
  80146a:	39 d8                	cmp    %ebx,%eax
  80146c:	76 12                	jbe    801480 <__umoddi3+0x50>
  80146e:	89 f0                	mov    %esi,%eax
  801470:	89 da                	mov    %ebx,%edx
  801472:	83 c4 1c             	add    $0x1c,%esp
  801475:	5b                   	pop    %ebx
  801476:	5e                   	pop    %esi
  801477:	5f                   	pop    %edi
  801478:	5d                   	pop    %ebp
  801479:	c3                   	ret    
  80147a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801480:	0f bd e8             	bsr    %eax,%ebp
  801483:	83 f5 1f             	xor    $0x1f,%ebp
  801486:	75 50                	jne    8014d8 <__umoddi3+0xa8>
  801488:	39 d8                	cmp    %ebx,%eax
  80148a:	0f 82 e0 00 00 00    	jb     801570 <__umoddi3+0x140>
  801490:	89 d9                	mov    %ebx,%ecx
  801492:	39 f7                	cmp    %esi,%edi
  801494:	0f 86 d6 00 00 00    	jbe    801570 <__umoddi3+0x140>
  80149a:	89 d0                	mov    %edx,%eax
  80149c:	89 ca                	mov    %ecx,%edx
  80149e:	83 c4 1c             	add    $0x1c,%esp
  8014a1:	5b                   	pop    %ebx
  8014a2:	5e                   	pop    %esi
  8014a3:	5f                   	pop    %edi
  8014a4:	5d                   	pop    %ebp
  8014a5:	c3                   	ret    
  8014a6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8014ad:	8d 76 00             	lea    0x0(%esi),%esi
  8014b0:	89 fd                	mov    %edi,%ebp
  8014b2:	85 ff                	test   %edi,%edi
  8014b4:	75 0b                	jne    8014c1 <__umoddi3+0x91>
  8014b6:	b8 01 00 00 00       	mov    $0x1,%eax
  8014bb:	31 d2                	xor    %edx,%edx
  8014bd:	f7 f7                	div    %edi
  8014bf:	89 c5                	mov    %eax,%ebp
  8014c1:	89 d8                	mov    %ebx,%eax
  8014c3:	31 d2                	xor    %edx,%edx
  8014c5:	f7 f5                	div    %ebp
  8014c7:	89 f0                	mov    %esi,%eax
  8014c9:	f7 f5                	div    %ebp
  8014cb:	89 d0                	mov    %edx,%eax
  8014cd:	31 d2                	xor    %edx,%edx
  8014cf:	eb 8c                	jmp    80145d <__umoddi3+0x2d>
  8014d1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8014d8:	89 e9                	mov    %ebp,%ecx
  8014da:	ba 20 00 00 00       	mov    $0x20,%edx
  8014df:	29 ea                	sub    %ebp,%edx
  8014e1:	d3 e0                	shl    %cl,%eax
  8014e3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8014e7:	89 d1                	mov    %edx,%ecx
  8014e9:	89 f8                	mov    %edi,%eax
  8014eb:	d3 e8                	shr    %cl,%eax
  8014ed:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8014f1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8014f5:	8b 54 24 04          	mov    0x4(%esp),%edx
  8014f9:	09 c1                	or     %eax,%ecx
  8014fb:	89 d8                	mov    %ebx,%eax
  8014fd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801501:	89 e9                	mov    %ebp,%ecx
  801503:	d3 e7                	shl    %cl,%edi
  801505:	89 d1                	mov    %edx,%ecx
  801507:	d3 e8                	shr    %cl,%eax
  801509:	89 e9                	mov    %ebp,%ecx
  80150b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80150f:	d3 e3                	shl    %cl,%ebx
  801511:	89 c7                	mov    %eax,%edi
  801513:	89 d1                	mov    %edx,%ecx
  801515:	89 f0                	mov    %esi,%eax
  801517:	d3 e8                	shr    %cl,%eax
  801519:	89 e9                	mov    %ebp,%ecx
  80151b:	89 fa                	mov    %edi,%edx
  80151d:	d3 e6                	shl    %cl,%esi
  80151f:	09 d8                	or     %ebx,%eax
  801521:	f7 74 24 08          	divl   0x8(%esp)
  801525:	89 d1                	mov    %edx,%ecx
  801527:	89 f3                	mov    %esi,%ebx
  801529:	f7 64 24 0c          	mull   0xc(%esp)
  80152d:	89 c6                	mov    %eax,%esi
  80152f:	89 d7                	mov    %edx,%edi
  801531:	39 d1                	cmp    %edx,%ecx
  801533:	72 06                	jb     80153b <__umoddi3+0x10b>
  801535:	75 10                	jne    801547 <__umoddi3+0x117>
  801537:	39 c3                	cmp    %eax,%ebx
  801539:	73 0c                	jae    801547 <__umoddi3+0x117>
  80153b:	2b 44 24 0c          	sub    0xc(%esp),%eax
  80153f:	1b 54 24 08          	sbb    0x8(%esp),%edx
  801543:	89 d7                	mov    %edx,%edi
  801545:	89 c6                	mov    %eax,%esi
  801547:	89 ca                	mov    %ecx,%edx
  801549:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80154e:	29 f3                	sub    %esi,%ebx
  801550:	19 fa                	sbb    %edi,%edx
  801552:	89 d0                	mov    %edx,%eax
  801554:	d3 e0                	shl    %cl,%eax
  801556:	89 e9                	mov    %ebp,%ecx
  801558:	d3 eb                	shr    %cl,%ebx
  80155a:	d3 ea                	shr    %cl,%edx
  80155c:	09 d8                	or     %ebx,%eax
  80155e:	83 c4 1c             	add    $0x1c,%esp
  801561:	5b                   	pop    %ebx
  801562:	5e                   	pop    %esi
  801563:	5f                   	pop    %edi
  801564:	5d                   	pop    %ebp
  801565:	c3                   	ret    
  801566:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80156d:	8d 76 00             	lea    0x0(%esi),%esi
  801570:	29 fe                	sub    %edi,%esi
  801572:	19 c3                	sbb    %eax,%ebx
  801574:	89 f2                	mov    %esi,%edx
  801576:	89 d9                	mov    %ebx,%ecx
  801578:	e9 1d ff ff ff       	jmp    80149a <__umoddi3+0x6a>
