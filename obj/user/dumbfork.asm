
obj/user/dumbfork:     file format elf32-i386


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
  80002c:	e8 ad 01 00 00       	call   8001de <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <duppage>:
	}
}

void
duppage(envid_t dstenv, void *addr)
{
  800033:	f3 0f 1e fb          	endbr32 
  800037:	55                   	push   %ebp
  800038:	89 e5                	mov    %esp,%ebp
  80003a:	56                   	push   %esi
  80003b:	53                   	push   %ebx
  80003c:	8b 75 08             	mov    0x8(%ebp),%esi
  80003f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	// This is NOT what you should do in your fork.
	if ((r = sys_page_alloc(dstenv, addr, PTE_P|PTE_U|PTE_W)) < 0)
  800042:	83 ec 04             	sub    $0x4,%esp
  800045:	6a 07                	push   $0x7
  800047:	53                   	push   %ebx
  800048:	56                   	push   %esi
  800049:	e8 62 0d 00 00       	call   800db0 <sys_page_alloc>
  80004e:	83 c4 10             	add    $0x10,%esp
  800051:	85 c0                	test   %eax,%eax
  800053:	78 4a                	js     80009f <duppage+0x6c>
		panic("sys_page_alloc: %e", r);
	if ((r = sys_page_map(dstenv, addr, 0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  800055:	83 ec 0c             	sub    $0xc,%esp
  800058:	6a 07                	push   $0x7
  80005a:	68 00 00 40 00       	push   $0x400000
  80005f:	6a 00                	push   $0x0
  800061:	53                   	push   %ebx
  800062:	56                   	push   %esi
  800063:	e8 8f 0d 00 00       	call   800df7 <sys_page_map>
  800068:	83 c4 20             	add    $0x20,%esp
  80006b:	85 c0                	test   %eax,%eax
  80006d:	78 42                	js     8000b1 <duppage+0x7e>
		panic("sys_page_map: %e", r);
	memmove(UTEMP, addr, PGSIZE);
  80006f:	83 ec 04             	sub    $0x4,%esp
  800072:	68 00 10 00 00       	push   $0x1000
  800077:	53                   	push   %ebx
  800078:	68 00 00 40 00       	push   $0x400000
  80007d:	e8 a2 0a 00 00       	call   800b24 <memmove>
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  800082:	83 c4 08             	add    $0x8,%esp
  800085:	68 00 00 40 00       	push   $0x400000
  80008a:	6a 00                	push   $0x0
  80008c:	e8 ac 0d 00 00       	call   800e3d <sys_page_unmap>
  800091:	83 c4 10             	add    $0x10,%esp
  800094:	85 c0                	test   %eax,%eax
  800096:	78 2b                	js     8000c3 <duppage+0x90>
		panic("sys_page_unmap: %e", r);
}
  800098:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80009b:	5b                   	pop    %ebx
  80009c:	5e                   	pop    %esi
  80009d:	5d                   	pop    %ebp
  80009e:	c3                   	ret    
		panic("sys_page_alloc: %e", r);
  80009f:	50                   	push   %eax
  8000a0:	68 e0 11 80 00       	push   $0x8011e0
  8000a5:	6a 20                	push   $0x20
  8000a7:	68 f3 11 80 00       	push   $0x8011f3
  8000ac:	e8 8d 01 00 00       	call   80023e <_panic>
		panic("sys_page_map: %e", r);
  8000b1:	50                   	push   %eax
  8000b2:	68 03 12 80 00       	push   $0x801203
  8000b7:	6a 22                	push   $0x22
  8000b9:	68 f3 11 80 00       	push   $0x8011f3
  8000be:	e8 7b 01 00 00       	call   80023e <_panic>
		panic("sys_page_unmap: %e", r);
  8000c3:	50                   	push   %eax
  8000c4:	68 14 12 80 00       	push   $0x801214
  8000c9:	6a 25                	push   $0x25
  8000cb:	68 f3 11 80 00       	push   $0x8011f3
  8000d0:	e8 69 01 00 00       	call   80023e <_panic>

008000d5 <dumbfork>:

envid_t
dumbfork(void)
{
  8000d5:	f3 0f 1e fb          	endbr32 
  8000d9:	55                   	push   %ebp
  8000da:	89 e5                	mov    %esp,%ebp
  8000dc:	56                   	push   %esi
  8000dd:	53                   	push   %ebx
  8000de:	83 ec 10             	sub    $0x10,%esp
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  8000e1:	b8 07 00 00 00       	mov    $0x7,%eax
  8000e6:	cd 30                	int    $0x30
  8000e8:	89 c3                	mov    %eax,%ebx
	// The kernel will initialize it with a copy of our register state,
	// so that the child will appear to have called sys_exofork() too -
	// except that in the child, this "fake" call to sys_exofork()
	// will return 0 instead of the envid of the child.
	envid = sys_exofork();
	if (envid < 0)
  8000ea:	85 c0                	test   %eax,%eax
  8000ec:	78 0d                	js     8000fb <dumbfork+0x26>
  8000ee:	89 c6                	mov    %eax,%esi
		panic("sys_exofork: %e", envid);
	if (envid == 0) {
  8000f0:	74 1b                	je     80010d <dumbfork+0x38>
	}

	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
  8000f2:	c7 45 f4 00 00 80 00 	movl   $0x800000,-0xc(%ebp)
  8000f9:	eb 3f                	jmp    80013a <dumbfork+0x65>
		panic("sys_exofork: %e", envid);
  8000fb:	50                   	push   %eax
  8000fc:	68 27 12 80 00       	push   $0x801227
  800101:	6a 37                	push   $0x37
  800103:	68 f3 11 80 00       	push   $0x8011f3
  800108:	e8 31 01 00 00       	call   80023e <_panic>
		thisenv = &envs[ENVX(sys_getenvid())];
  80010d:	e8 58 0c 00 00       	call   800d6a <sys_getenvid>
  800112:	25 ff 03 00 00       	and    $0x3ff,%eax
  800117:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80011a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80011f:	a3 04 20 80 00       	mov    %eax,0x802004
		return 0;
  800124:	eb 43                	jmp    800169 <dumbfork+0x94>
		duppage(envid, addr);
  800126:	83 ec 08             	sub    $0x8,%esp
  800129:	52                   	push   %edx
  80012a:	56                   	push   %esi
  80012b:	e8 03 ff ff ff       	call   800033 <duppage>
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
  800130:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
  800137:	83 c4 10             	add    $0x10,%esp
  80013a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80013d:	81 fa 08 20 80 00    	cmp    $0x802008,%edx
  800143:	72 e1                	jb     800126 <dumbfork+0x51>

	// Also copy the stack we are currently running on.
	duppage(envid, ROUNDDOWN(&addr, PGSIZE));
  800145:	83 ec 08             	sub    $0x8,%esp
  800148:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80014b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800150:	50                   	push   %eax
  800151:	53                   	push   %ebx
  800152:	e8 dc fe ff ff       	call   800033 <duppage>

	// Start the child environment running
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  800157:	83 c4 08             	add    $0x8,%esp
  80015a:	6a 02                	push   $0x2
  80015c:	53                   	push   %ebx
  80015d:	e8 21 0d 00 00       	call   800e83 <sys_env_set_status>
  800162:	83 c4 10             	add    $0x10,%esp
  800165:	85 c0                	test   %eax,%eax
  800167:	78 09                	js     800172 <dumbfork+0x9d>
		panic("sys_env_set_status: %e", r);

	return envid;
}
  800169:	89 d8                	mov    %ebx,%eax
  80016b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80016e:	5b                   	pop    %ebx
  80016f:	5e                   	pop    %esi
  800170:	5d                   	pop    %ebp
  800171:	c3                   	ret    
		panic("sys_env_set_status: %e", r);
  800172:	50                   	push   %eax
  800173:	68 37 12 80 00       	push   $0x801237
  800178:	6a 4c                	push   $0x4c
  80017a:	68 f3 11 80 00       	push   $0x8011f3
  80017f:	e8 ba 00 00 00       	call   80023e <_panic>

00800184 <umain>:
{
  800184:	f3 0f 1e fb          	endbr32 
  800188:	55                   	push   %ebp
  800189:	89 e5                	mov    %esp,%ebp
  80018b:	57                   	push   %edi
  80018c:	56                   	push   %esi
  80018d:	53                   	push   %ebx
  80018e:	83 ec 0c             	sub    $0xc,%esp
	who = dumbfork();
  800191:	e8 3f ff ff ff       	call   8000d5 <dumbfork>
  800196:	89 c6                	mov    %eax,%esi
  800198:	85 c0                	test   %eax,%eax
  80019a:	bf 4e 12 80 00       	mov    $0x80124e,%edi
  80019f:	b8 55 12 80 00       	mov    $0x801255,%eax
  8001a4:	0f 44 f8             	cmove  %eax,%edi
	for (i = 0; i < (who ? 10 : 20); i++) {
  8001a7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001ac:	eb 1f                	jmp    8001cd <umain+0x49>
  8001ae:	83 fb 13             	cmp    $0x13,%ebx
  8001b1:	7f 23                	jg     8001d6 <umain+0x52>
		cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
  8001b3:	83 ec 04             	sub    $0x4,%esp
  8001b6:	57                   	push   %edi
  8001b7:	53                   	push   %ebx
  8001b8:	68 5b 12 80 00       	push   $0x80125b
  8001bd:	e8 63 01 00 00       	call   800325 <cprintf>
		sys_yield();
  8001c2:	e8 c6 0b 00 00       	call   800d8d <sys_yield>
	for (i = 0; i < (who ? 10 : 20); i++) {
  8001c7:	83 c3 01             	add    $0x1,%ebx
  8001ca:	83 c4 10             	add    $0x10,%esp
  8001cd:	85 f6                	test   %esi,%esi
  8001cf:	74 dd                	je     8001ae <umain+0x2a>
  8001d1:	83 fb 09             	cmp    $0x9,%ebx
  8001d4:	7e dd                	jle    8001b3 <umain+0x2f>
}
  8001d6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001d9:	5b                   	pop    %ebx
  8001da:	5e                   	pop    %esi
  8001db:	5f                   	pop    %edi
  8001dc:	5d                   	pop    %ebp
  8001dd:	c3                   	ret    

008001de <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001de:	f3 0f 1e fb          	endbr32 
  8001e2:	55                   	push   %ebp
  8001e3:	89 e5                	mov    %esp,%ebp
  8001e5:	56                   	push   %esi
  8001e6:	53                   	push   %ebx
  8001e7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001ea:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv=&envs[ENVX(sys_getenvid())];
  8001ed:	e8 78 0b 00 00       	call   800d6a <sys_getenvid>
  8001f2:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001f7:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8001fa:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001ff:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800204:	85 db                	test   %ebx,%ebx
  800206:	7e 07                	jle    80020f <libmain+0x31>
		binaryname = argv[0];
  800208:	8b 06                	mov    (%esi),%eax
  80020a:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80020f:	83 ec 08             	sub    $0x8,%esp
  800212:	56                   	push   %esi
  800213:	53                   	push   %ebx
  800214:	e8 6b ff ff ff       	call   800184 <umain>

	// exit gracefully
	exit();
  800219:	e8 0a 00 00 00       	call   800228 <exit>
}
  80021e:	83 c4 10             	add    $0x10,%esp
  800221:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800224:	5b                   	pop    %ebx
  800225:	5e                   	pop    %esi
  800226:	5d                   	pop    %ebp
  800227:	c3                   	ret    

00800228 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800228:	f3 0f 1e fb          	endbr32 
  80022c:	55                   	push   %ebp
  80022d:	89 e5                	mov    %esp,%ebp
  80022f:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800232:	6a 00                	push   $0x0
  800234:	e8 ec 0a 00 00       	call   800d25 <sys_env_destroy>
}
  800239:	83 c4 10             	add    $0x10,%esp
  80023c:	c9                   	leave  
  80023d:	c3                   	ret    

0080023e <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80023e:	f3 0f 1e fb          	endbr32 
  800242:	55                   	push   %ebp
  800243:	89 e5                	mov    %esp,%ebp
  800245:	56                   	push   %esi
  800246:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800247:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80024a:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800250:	e8 15 0b 00 00       	call   800d6a <sys_getenvid>
  800255:	83 ec 0c             	sub    $0xc,%esp
  800258:	ff 75 0c             	pushl  0xc(%ebp)
  80025b:	ff 75 08             	pushl  0x8(%ebp)
  80025e:	56                   	push   %esi
  80025f:	50                   	push   %eax
  800260:	68 78 12 80 00       	push   $0x801278
  800265:	e8 bb 00 00 00       	call   800325 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80026a:	83 c4 18             	add    $0x18,%esp
  80026d:	53                   	push   %ebx
  80026e:	ff 75 10             	pushl  0x10(%ebp)
  800271:	e8 5a 00 00 00       	call   8002d0 <vcprintf>
	cprintf("\n");
  800276:	c7 04 24 6b 12 80 00 	movl   $0x80126b,(%esp)
  80027d:	e8 a3 00 00 00       	call   800325 <cprintf>
  800282:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800285:	cc                   	int3   
  800286:	eb fd                	jmp    800285 <_panic+0x47>

00800288 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800288:	f3 0f 1e fb          	endbr32 
  80028c:	55                   	push   %ebp
  80028d:	89 e5                	mov    %esp,%ebp
  80028f:	53                   	push   %ebx
  800290:	83 ec 04             	sub    $0x4,%esp
  800293:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800296:	8b 13                	mov    (%ebx),%edx
  800298:	8d 42 01             	lea    0x1(%edx),%eax
  80029b:	89 03                	mov    %eax,(%ebx)
  80029d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002a0:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8002a4:	3d ff 00 00 00       	cmp    $0xff,%eax
  8002a9:	74 09                	je     8002b4 <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8002ab:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8002af:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8002b2:	c9                   	leave  
  8002b3:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8002b4:	83 ec 08             	sub    $0x8,%esp
  8002b7:	68 ff 00 00 00       	push   $0xff
  8002bc:	8d 43 08             	lea    0x8(%ebx),%eax
  8002bf:	50                   	push   %eax
  8002c0:	e8 1b 0a 00 00       	call   800ce0 <sys_cputs>
		b->idx = 0;
  8002c5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8002cb:	83 c4 10             	add    $0x10,%esp
  8002ce:	eb db                	jmp    8002ab <putch+0x23>

008002d0 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002d0:	f3 0f 1e fb          	endbr32 
  8002d4:	55                   	push   %ebp
  8002d5:	89 e5                	mov    %esp,%ebp
  8002d7:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8002dd:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002e4:	00 00 00 
	b.cnt = 0;
  8002e7:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002ee:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002f1:	ff 75 0c             	pushl  0xc(%ebp)
  8002f4:	ff 75 08             	pushl  0x8(%ebp)
  8002f7:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002fd:	50                   	push   %eax
  8002fe:	68 88 02 80 00       	push   $0x800288
  800303:	e8 20 01 00 00       	call   800428 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800308:	83 c4 08             	add    $0x8,%esp
  80030b:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800311:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800317:	50                   	push   %eax
  800318:	e8 c3 09 00 00       	call   800ce0 <sys_cputs>

	return b.cnt;
}
  80031d:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800323:	c9                   	leave  
  800324:	c3                   	ret    

00800325 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800325:	f3 0f 1e fb          	endbr32 
  800329:	55                   	push   %ebp
  80032a:	89 e5                	mov    %esp,%ebp
  80032c:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80032f:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800332:	50                   	push   %eax
  800333:	ff 75 08             	pushl  0x8(%ebp)
  800336:	e8 95 ff ff ff       	call   8002d0 <vcprintf>
	va_end(ap);

	return cnt;
}
  80033b:	c9                   	leave  
  80033c:	c3                   	ret    

0080033d <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80033d:	55                   	push   %ebp
  80033e:	89 e5                	mov    %esp,%ebp
  800340:	57                   	push   %edi
  800341:	56                   	push   %esi
  800342:	53                   	push   %ebx
  800343:	83 ec 1c             	sub    $0x1c,%esp
  800346:	89 c7                	mov    %eax,%edi
  800348:	89 d6                	mov    %edx,%esi
  80034a:	8b 45 08             	mov    0x8(%ebp),%eax
  80034d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800350:	89 d1                	mov    %edx,%ecx
  800352:	89 c2                	mov    %eax,%edx
  800354:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800357:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80035a:	8b 45 10             	mov    0x10(%ebp),%eax
  80035d:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800360:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800363:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80036a:	39 c2                	cmp    %eax,%edx
  80036c:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  80036f:	72 3e                	jb     8003af <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800371:	83 ec 0c             	sub    $0xc,%esp
  800374:	ff 75 18             	pushl  0x18(%ebp)
  800377:	83 eb 01             	sub    $0x1,%ebx
  80037a:	53                   	push   %ebx
  80037b:	50                   	push   %eax
  80037c:	83 ec 08             	sub    $0x8,%esp
  80037f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800382:	ff 75 e0             	pushl  -0x20(%ebp)
  800385:	ff 75 dc             	pushl  -0x24(%ebp)
  800388:	ff 75 d8             	pushl  -0x28(%ebp)
  80038b:	e8 f0 0b 00 00       	call   800f80 <__udivdi3>
  800390:	83 c4 18             	add    $0x18,%esp
  800393:	52                   	push   %edx
  800394:	50                   	push   %eax
  800395:	89 f2                	mov    %esi,%edx
  800397:	89 f8                	mov    %edi,%eax
  800399:	e8 9f ff ff ff       	call   80033d <printnum>
  80039e:	83 c4 20             	add    $0x20,%esp
  8003a1:	eb 13                	jmp    8003b6 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8003a3:	83 ec 08             	sub    $0x8,%esp
  8003a6:	56                   	push   %esi
  8003a7:	ff 75 18             	pushl  0x18(%ebp)
  8003aa:	ff d7                	call   *%edi
  8003ac:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8003af:	83 eb 01             	sub    $0x1,%ebx
  8003b2:	85 db                	test   %ebx,%ebx
  8003b4:	7f ed                	jg     8003a3 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003b6:	83 ec 08             	sub    $0x8,%esp
  8003b9:	56                   	push   %esi
  8003ba:	83 ec 04             	sub    $0x4,%esp
  8003bd:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003c0:	ff 75 e0             	pushl  -0x20(%ebp)
  8003c3:	ff 75 dc             	pushl  -0x24(%ebp)
  8003c6:	ff 75 d8             	pushl  -0x28(%ebp)
  8003c9:	e8 c2 0c 00 00       	call   801090 <__umoddi3>
  8003ce:	83 c4 14             	add    $0x14,%esp
  8003d1:	0f be 80 9b 12 80 00 	movsbl 0x80129b(%eax),%eax
  8003d8:	50                   	push   %eax
  8003d9:	ff d7                	call   *%edi
}
  8003db:	83 c4 10             	add    $0x10,%esp
  8003de:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003e1:	5b                   	pop    %ebx
  8003e2:	5e                   	pop    %esi
  8003e3:	5f                   	pop    %edi
  8003e4:	5d                   	pop    %ebp
  8003e5:	c3                   	ret    

008003e6 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003e6:	f3 0f 1e fb          	endbr32 
  8003ea:	55                   	push   %ebp
  8003eb:	89 e5                	mov    %esp,%ebp
  8003ed:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003f0:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003f4:	8b 10                	mov    (%eax),%edx
  8003f6:	3b 50 04             	cmp    0x4(%eax),%edx
  8003f9:	73 0a                	jae    800405 <sprintputch+0x1f>
		*b->buf++ = ch;
  8003fb:	8d 4a 01             	lea    0x1(%edx),%ecx
  8003fe:	89 08                	mov    %ecx,(%eax)
  800400:	8b 45 08             	mov    0x8(%ebp),%eax
  800403:	88 02                	mov    %al,(%edx)
}
  800405:	5d                   	pop    %ebp
  800406:	c3                   	ret    

00800407 <printfmt>:
{
  800407:	f3 0f 1e fb          	endbr32 
  80040b:	55                   	push   %ebp
  80040c:	89 e5                	mov    %esp,%ebp
  80040e:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800411:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800414:	50                   	push   %eax
  800415:	ff 75 10             	pushl  0x10(%ebp)
  800418:	ff 75 0c             	pushl  0xc(%ebp)
  80041b:	ff 75 08             	pushl  0x8(%ebp)
  80041e:	e8 05 00 00 00       	call   800428 <vprintfmt>
}
  800423:	83 c4 10             	add    $0x10,%esp
  800426:	c9                   	leave  
  800427:	c3                   	ret    

00800428 <vprintfmt>:
{
  800428:	f3 0f 1e fb          	endbr32 
  80042c:	55                   	push   %ebp
  80042d:	89 e5                	mov    %esp,%ebp
  80042f:	57                   	push   %edi
  800430:	56                   	push   %esi
  800431:	53                   	push   %ebx
  800432:	83 ec 3c             	sub    $0x3c,%esp
  800435:	8b 75 08             	mov    0x8(%ebp),%esi
  800438:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80043b:	8b 7d 10             	mov    0x10(%ebp),%edi
  80043e:	e9 cd 03 00 00       	jmp    800810 <vprintfmt+0x3e8>
		padc = ' ';
  800443:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800447:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  80044e:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800455:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80045c:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800461:	8d 47 01             	lea    0x1(%edi),%eax
  800464:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800467:	0f b6 17             	movzbl (%edi),%edx
  80046a:	8d 42 dd             	lea    -0x23(%edx),%eax
  80046d:	3c 55                	cmp    $0x55,%al
  80046f:	0f 87 1e 04 00 00    	ja     800893 <vprintfmt+0x46b>
  800475:	0f b6 c0             	movzbl %al,%eax
  800478:	3e ff 24 85 60 13 80 	notrack jmp *0x801360(,%eax,4)
  80047f:	00 
  800480:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800483:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800487:	eb d8                	jmp    800461 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800489:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80048c:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  800490:	eb cf                	jmp    800461 <vprintfmt+0x39>
  800492:	0f b6 d2             	movzbl %dl,%edx
  800495:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800498:	b8 00 00 00 00       	mov    $0x0,%eax
  80049d:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8004a0:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8004a3:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8004a7:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8004aa:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8004ad:	83 f9 09             	cmp    $0x9,%ecx
  8004b0:	77 55                	ja     800507 <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  8004b2:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8004b5:	eb e9                	jmp    8004a0 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  8004b7:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ba:	8b 00                	mov    (%eax),%eax
  8004bc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004bf:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c2:	8d 40 04             	lea    0x4(%eax),%eax
  8004c5:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8004c8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8004cb:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004cf:	79 90                	jns    800461 <vprintfmt+0x39>
				width = precision, precision = -1;
  8004d1:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8004d4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004d7:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8004de:	eb 81                	jmp    800461 <vprintfmt+0x39>
  8004e0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004e3:	85 c0                	test   %eax,%eax
  8004e5:	ba 00 00 00 00       	mov    $0x0,%edx
  8004ea:	0f 49 d0             	cmovns %eax,%edx
  8004ed:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8004f0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8004f3:	e9 69 ff ff ff       	jmp    800461 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8004f8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8004fb:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  800502:	e9 5a ff ff ff       	jmp    800461 <vprintfmt+0x39>
  800507:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80050a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80050d:	eb bc                	jmp    8004cb <vprintfmt+0xa3>
			lflag++;
  80050f:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800512:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800515:	e9 47 ff ff ff       	jmp    800461 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  80051a:	8b 45 14             	mov    0x14(%ebp),%eax
  80051d:	8d 78 04             	lea    0x4(%eax),%edi
  800520:	83 ec 08             	sub    $0x8,%esp
  800523:	53                   	push   %ebx
  800524:	ff 30                	pushl  (%eax)
  800526:	ff d6                	call   *%esi
			break;
  800528:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  80052b:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  80052e:	e9 da 02 00 00       	jmp    80080d <vprintfmt+0x3e5>
			err = va_arg(ap, int);
  800533:	8b 45 14             	mov    0x14(%ebp),%eax
  800536:	8d 78 04             	lea    0x4(%eax),%edi
  800539:	8b 00                	mov    (%eax),%eax
  80053b:	99                   	cltd   
  80053c:	31 d0                	xor    %edx,%eax
  80053e:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800540:	83 f8 08             	cmp    $0x8,%eax
  800543:	7f 23                	jg     800568 <vprintfmt+0x140>
  800545:	8b 14 85 c0 14 80 00 	mov    0x8014c0(,%eax,4),%edx
  80054c:	85 d2                	test   %edx,%edx
  80054e:	74 18                	je     800568 <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  800550:	52                   	push   %edx
  800551:	68 bc 12 80 00       	push   $0x8012bc
  800556:	53                   	push   %ebx
  800557:	56                   	push   %esi
  800558:	e8 aa fe ff ff       	call   800407 <printfmt>
  80055d:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800560:	89 7d 14             	mov    %edi,0x14(%ebp)
  800563:	e9 a5 02 00 00       	jmp    80080d <vprintfmt+0x3e5>
				printfmt(putch, putdat, "error %d", err);
  800568:	50                   	push   %eax
  800569:	68 b3 12 80 00       	push   $0x8012b3
  80056e:	53                   	push   %ebx
  80056f:	56                   	push   %esi
  800570:	e8 92 fe ff ff       	call   800407 <printfmt>
  800575:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800578:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80057b:	e9 8d 02 00 00       	jmp    80080d <vprintfmt+0x3e5>
			if ((p = va_arg(ap, char *)) == NULL)
  800580:	8b 45 14             	mov    0x14(%ebp),%eax
  800583:	83 c0 04             	add    $0x4,%eax
  800586:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800589:	8b 45 14             	mov    0x14(%ebp),%eax
  80058c:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  80058e:	85 d2                	test   %edx,%edx
  800590:	b8 ac 12 80 00       	mov    $0x8012ac,%eax
  800595:	0f 45 c2             	cmovne %edx,%eax
  800598:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  80059b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80059f:	7e 06                	jle    8005a7 <vprintfmt+0x17f>
  8005a1:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  8005a5:	75 0d                	jne    8005b4 <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005a7:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8005aa:	89 c7                	mov    %eax,%edi
  8005ac:	03 45 e0             	add    -0x20(%ebp),%eax
  8005af:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005b2:	eb 55                	jmp    800609 <vprintfmt+0x1e1>
  8005b4:	83 ec 08             	sub    $0x8,%esp
  8005b7:	ff 75 d8             	pushl  -0x28(%ebp)
  8005ba:	ff 75 cc             	pushl  -0x34(%ebp)
  8005bd:	e8 85 03 00 00       	call   800947 <strnlen>
  8005c2:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8005c5:	29 c2                	sub    %eax,%edx
  8005c7:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  8005ca:	83 c4 10             	add    $0x10,%esp
  8005cd:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  8005cf:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8005d3:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8005d6:	85 ff                	test   %edi,%edi
  8005d8:	7e 11                	jle    8005eb <vprintfmt+0x1c3>
					putch(padc, putdat);
  8005da:	83 ec 08             	sub    $0x8,%esp
  8005dd:	53                   	push   %ebx
  8005de:	ff 75 e0             	pushl  -0x20(%ebp)
  8005e1:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8005e3:	83 ef 01             	sub    $0x1,%edi
  8005e6:	83 c4 10             	add    $0x10,%esp
  8005e9:	eb eb                	jmp    8005d6 <vprintfmt+0x1ae>
  8005eb:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8005ee:	85 d2                	test   %edx,%edx
  8005f0:	b8 00 00 00 00       	mov    $0x0,%eax
  8005f5:	0f 49 c2             	cmovns %edx,%eax
  8005f8:	29 c2                	sub    %eax,%edx
  8005fa:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8005fd:	eb a8                	jmp    8005a7 <vprintfmt+0x17f>
					putch(ch, putdat);
  8005ff:	83 ec 08             	sub    $0x8,%esp
  800602:	53                   	push   %ebx
  800603:	52                   	push   %edx
  800604:	ff d6                	call   *%esi
  800606:	83 c4 10             	add    $0x10,%esp
  800609:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80060c:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80060e:	83 c7 01             	add    $0x1,%edi
  800611:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800615:	0f be d0             	movsbl %al,%edx
  800618:	85 d2                	test   %edx,%edx
  80061a:	74 4b                	je     800667 <vprintfmt+0x23f>
  80061c:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800620:	78 06                	js     800628 <vprintfmt+0x200>
  800622:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800626:	78 1e                	js     800646 <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
  800628:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80062c:	74 d1                	je     8005ff <vprintfmt+0x1d7>
  80062e:	0f be c0             	movsbl %al,%eax
  800631:	83 e8 20             	sub    $0x20,%eax
  800634:	83 f8 5e             	cmp    $0x5e,%eax
  800637:	76 c6                	jbe    8005ff <vprintfmt+0x1d7>
					putch('?', putdat);
  800639:	83 ec 08             	sub    $0x8,%esp
  80063c:	53                   	push   %ebx
  80063d:	6a 3f                	push   $0x3f
  80063f:	ff d6                	call   *%esi
  800641:	83 c4 10             	add    $0x10,%esp
  800644:	eb c3                	jmp    800609 <vprintfmt+0x1e1>
  800646:	89 cf                	mov    %ecx,%edi
  800648:	eb 0e                	jmp    800658 <vprintfmt+0x230>
				putch(' ', putdat);
  80064a:	83 ec 08             	sub    $0x8,%esp
  80064d:	53                   	push   %ebx
  80064e:	6a 20                	push   $0x20
  800650:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800652:	83 ef 01             	sub    $0x1,%edi
  800655:	83 c4 10             	add    $0x10,%esp
  800658:	85 ff                	test   %edi,%edi
  80065a:	7f ee                	jg     80064a <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  80065c:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80065f:	89 45 14             	mov    %eax,0x14(%ebp)
  800662:	e9 a6 01 00 00       	jmp    80080d <vprintfmt+0x3e5>
  800667:	89 cf                	mov    %ecx,%edi
  800669:	eb ed                	jmp    800658 <vprintfmt+0x230>
	if (lflag >= 2)
  80066b:	83 f9 01             	cmp    $0x1,%ecx
  80066e:	7f 1f                	jg     80068f <vprintfmt+0x267>
	else if (lflag)
  800670:	85 c9                	test   %ecx,%ecx
  800672:	74 67                	je     8006db <vprintfmt+0x2b3>
		return va_arg(*ap, long);
  800674:	8b 45 14             	mov    0x14(%ebp),%eax
  800677:	8b 00                	mov    (%eax),%eax
  800679:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80067c:	89 c1                	mov    %eax,%ecx
  80067e:	c1 f9 1f             	sar    $0x1f,%ecx
  800681:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800684:	8b 45 14             	mov    0x14(%ebp),%eax
  800687:	8d 40 04             	lea    0x4(%eax),%eax
  80068a:	89 45 14             	mov    %eax,0x14(%ebp)
  80068d:	eb 17                	jmp    8006a6 <vprintfmt+0x27e>
		return va_arg(*ap, long long);
  80068f:	8b 45 14             	mov    0x14(%ebp),%eax
  800692:	8b 50 04             	mov    0x4(%eax),%edx
  800695:	8b 00                	mov    (%eax),%eax
  800697:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80069a:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80069d:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a0:	8d 40 08             	lea    0x8(%eax),%eax
  8006a3:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8006a6:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8006a9:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8006ac:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  8006b1:	85 c9                	test   %ecx,%ecx
  8006b3:	0f 89 3a 01 00 00    	jns    8007f3 <vprintfmt+0x3cb>
				putch('-', putdat);
  8006b9:	83 ec 08             	sub    $0x8,%esp
  8006bc:	53                   	push   %ebx
  8006bd:	6a 2d                	push   $0x2d
  8006bf:	ff d6                	call   *%esi
				num = -(long long) num;
  8006c1:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8006c4:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8006c7:	f7 da                	neg    %edx
  8006c9:	83 d1 00             	adc    $0x0,%ecx
  8006cc:	f7 d9                	neg    %ecx
  8006ce:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8006d1:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006d6:	e9 18 01 00 00       	jmp    8007f3 <vprintfmt+0x3cb>
		return va_arg(*ap, int);
  8006db:	8b 45 14             	mov    0x14(%ebp),%eax
  8006de:	8b 00                	mov    (%eax),%eax
  8006e0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006e3:	89 c1                	mov    %eax,%ecx
  8006e5:	c1 f9 1f             	sar    $0x1f,%ecx
  8006e8:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006eb:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ee:	8d 40 04             	lea    0x4(%eax),%eax
  8006f1:	89 45 14             	mov    %eax,0x14(%ebp)
  8006f4:	eb b0                	jmp    8006a6 <vprintfmt+0x27e>
	if (lflag >= 2)
  8006f6:	83 f9 01             	cmp    $0x1,%ecx
  8006f9:	7f 1e                	jg     800719 <vprintfmt+0x2f1>
	else if (lflag)
  8006fb:	85 c9                	test   %ecx,%ecx
  8006fd:	74 32                	je     800731 <vprintfmt+0x309>
		return va_arg(*ap, unsigned long);
  8006ff:	8b 45 14             	mov    0x14(%ebp),%eax
  800702:	8b 10                	mov    (%eax),%edx
  800704:	b9 00 00 00 00       	mov    $0x0,%ecx
  800709:	8d 40 04             	lea    0x4(%eax),%eax
  80070c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80070f:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  800714:	e9 da 00 00 00       	jmp    8007f3 <vprintfmt+0x3cb>
		return va_arg(*ap, unsigned long long);
  800719:	8b 45 14             	mov    0x14(%ebp),%eax
  80071c:	8b 10                	mov    (%eax),%edx
  80071e:	8b 48 04             	mov    0x4(%eax),%ecx
  800721:	8d 40 08             	lea    0x8(%eax),%eax
  800724:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800727:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  80072c:	e9 c2 00 00 00       	jmp    8007f3 <vprintfmt+0x3cb>
		return va_arg(*ap, unsigned int);
  800731:	8b 45 14             	mov    0x14(%ebp),%eax
  800734:	8b 10                	mov    (%eax),%edx
  800736:	b9 00 00 00 00       	mov    $0x0,%ecx
  80073b:	8d 40 04             	lea    0x4(%eax),%eax
  80073e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800741:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  800746:	e9 a8 00 00 00       	jmp    8007f3 <vprintfmt+0x3cb>
	if (lflag >= 2)
  80074b:	83 f9 01             	cmp    $0x1,%ecx
  80074e:	7f 1b                	jg     80076b <vprintfmt+0x343>
	else if (lflag)
  800750:	85 c9                	test   %ecx,%ecx
  800752:	74 5c                	je     8007b0 <vprintfmt+0x388>
		return va_arg(*ap, long);
  800754:	8b 45 14             	mov    0x14(%ebp),%eax
  800757:	8b 00                	mov    (%eax),%eax
  800759:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80075c:	99                   	cltd   
  80075d:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800760:	8b 45 14             	mov    0x14(%ebp),%eax
  800763:	8d 40 04             	lea    0x4(%eax),%eax
  800766:	89 45 14             	mov    %eax,0x14(%ebp)
  800769:	eb 17                	jmp    800782 <vprintfmt+0x35a>
		return va_arg(*ap, long long);
  80076b:	8b 45 14             	mov    0x14(%ebp),%eax
  80076e:	8b 50 04             	mov    0x4(%eax),%edx
  800771:	8b 00                	mov    (%eax),%eax
  800773:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800776:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800779:	8b 45 14             	mov    0x14(%ebp),%eax
  80077c:	8d 40 08             	lea    0x8(%eax),%eax
  80077f:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800782:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800785:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 8;
  800788:	b8 08 00 00 00       	mov    $0x8,%eax
			if ((long long) num < 0) {
  80078d:	85 c9                	test   %ecx,%ecx
  80078f:	79 62                	jns    8007f3 <vprintfmt+0x3cb>
				putch('-', putdat);
  800791:	83 ec 08             	sub    $0x8,%esp
  800794:	53                   	push   %ebx
  800795:	6a 2d                	push   $0x2d
  800797:	ff d6                	call   *%esi
				num = -(long long) num;
  800799:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80079c:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80079f:	f7 da                	neg    %edx
  8007a1:	83 d1 00             	adc    $0x0,%ecx
  8007a4:	f7 d9                	neg    %ecx
  8007a6:	83 c4 10             	add    $0x10,%esp
			base = 8;
  8007a9:	b8 08 00 00 00       	mov    $0x8,%eax
  8007ae:	eb 43                	jmp    8007f3 <vprintfmt+0x3cb>
		return va_arg(*ap, int);
  8007b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b3:	8b 00                	mov    (%eax),%eax
  8007b5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007b8:	89 c1                	mov    %eax,%ecx
  8007ba:	c1 f9 1f             	sar    $0x1f,%ecx
  8007bd:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8007c0:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c3:	8d 40 04             	lea    0x4(%eax),%eax
  8007c6:	89 45 14             	mov    %eax,0x14(%ebp)
  8007c9:	eb b7                	jmp    800782 <vprintfmt+0x35a>
			putch('0', putdat);
  8007cb:	83 ec 08             	sub    $0x8,%esp
  8007ce:	53                   	push   %ebx
  8007cf:	6a 30                	push   $0x30
  8007d1:	ff d6                	call   *%esi
			putch('x', putdat);
  8007d3:	83 c4 08             	add    $0x8,%esp
  8007d6:	53                   	push   %ebx
  8007d7:	6a 78                	push   $0x78
  8007d9:	ff d6                	call   *%esi
			num = (unsigned long long)
  8007db:	8b 45 14             	mov    0x14(%ebp),%eax
  8007de:	8b 10                	mov    (%eax),%edx
  8007e0:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8007e5:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8007e8:	8d 40 04             	lea    0x4(%eax),%eax
  8007eb:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007ee:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  8007f3:	83 ec 0c             	sub    $0xc,%esp
  8007f6:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  8007fa:	57                   	push   %edi
  8007fb:	ff 75 e0             	pushl  -0x20(%ebp)
  8007fe:	50                   	push   %eax
  8007ff:	51                   	push   %ecx
  800800:	52                   	push   %edx
  800801:	89 da                	mov    %ebx,%edx
  800803:	89 f0                	mov    %esi,%eax
  800805:	e8 33 fb ff ff       	call   80033d <printnum>
			break;
  80080a:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  80080d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800810:	83 c7 01             	add    $0x1,%edi
  800813:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800817:	83 f8 25             	cmp    $0x25,%eax
  80081a:	0f 84 23 fc ff ff    	je     800443 <vprintfmt+0x1b>
			if (ch == '\0')
  800820:	85 c0                	test   %eax,%eax
  800822:	0f 84 8b 00 00 00    	je     8008b3 <vprintfmt+0x48b>
			putch(ch, putdat);
  800828:	83 ec 08             	sub    $0x8,%esp
  80082b:	53                   	push   %ebx
  80082c:	50                   	push   %eax
  80082d:	ff d6                	call   *%esi
  80082f:	83 c4 10             	add    $0x10,%esp
  800832:	eb dc                	jmp    800810 <vprintfmt+0x3e8>
	if (lflag >= 2)
  800834:	83 f9 01             	cmp    $0x1,%ecx
  800837:	7f 1b                	jg     800854 <vprintfmt+0x42c>
	else if (lflag)
  800839:	85 c9                	test   %ecx,%ecx
  80083b:	74 2c                	je     800869 <vprintfmt+0x441>
		return va_arg(*ap, unsigned long);
  80083d:	8b 45 14             	mov    0x14(%ebp),%eax
  800840:	8b 10                	mov    (%eax),%edx
  800842:	b9 00 00 00 00       	mov    $0x0,%ecx
  800847:	8d 40 04             	lea    0x4(%eax),%eax
  80084a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80084d:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  800852:	eb 9f                	jmp    8007f3 <vprintfmt+0x3cb>
		return va_arg(*ap, unsigned long long);
  800854:	8b 45 14             	mov    0x14(%ebp),%eax
  800857:	8b 10                	mov    (%eax),%edx
  800859:	8b 48 04             	mov    0x4(%eax),%ecx
  80085c:	8d 40 08             	lea    0x8(%eax),%eax
  80085f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800862:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  800867:	eb 8a                	jmp    8007f3 <vprintfmt+0x3cb>
		return va_arg(*ap, unsigned int);
  800869:	8b 45 14             	mov    0x14(%ebp),%eax
  80086c:	8b 10                	mov    (%eax),%edx
  80086e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800873:	8d 40 04             	lea    0x4(%eax),%eax
  800876:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800879:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  80087e:	e9 70 ff ff ff       	jmp    8007f3 <vprintfmt+0x3cb>
			putch(ch, putdat);
  800883:	83 ec 08             	sub    $0x8,%esp
  800886:	53                   	push   %ebx
  800887:	6a 25                	push   $0x25
  800889:	ff d6                	call   *%esi
			break;
  80088b:	83 c4 10             	add    $0x10,%esp
  80088e:	e9 7a ff ff ff       	jmp    80080d <vprintfmt+0x3e5>
			putch('%', putdat);
  800893:	83 ec 08             	sub    $0x8,%esp
  800896:	53                   	push   %ebx
  800897:	6a 25                	push   $0x25
  800899:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80089b:	83 c4 10             	add    $0x10,%esp
  80089e:	89 f8                	mov    %edi,%eax
  8008a0:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8008a4:	74 05                	je     8008ab <vprintfmt+0x483>
  8008a6:	83 e8 01             	sub    $0x1,%eax
  8008a9:	eb f5                	jmp    8008a0 <vprintfmt+0x478>
  8008ab:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8008ae:	e9 5a ff ff ff       	jmp    80080d <vprintfmt+0x3e5>
}
  8008b3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8008b6:	5b                   	pop    %ebx
  8008b7:	5e                   	pop    %esi
  8008b8:	5f                   	pop    %edi
  8008b9:	5d                   	pop    %ebp
  8008ba:	c3                   	ret    

008008bb <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008bb:	f3 0f 1e fb          	endbr32 
  8008bf:	55                   	push   %ebp
  8008c0:	89 e5                	mov    %esp,%ebp
  8008c2:	83 ec 18             	sub    $0x18,%esp
  8008c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c8:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008cb:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008ce:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8008d2:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8008d5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008dc:	85 c0                	test   %eax,%eax
  8008de:	74 26                	je     800906 <vsnprintf+0x4b>
  8008e0:	85 d2                	test   %edx,%edx
  8008e2:	7e 22                	jle    800906 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008e4:	ff 75 14             	pushl  0x14(%ebp)
  8008e7:	ff 75 10             	pushl  0x10(%ebp)
  8008ea:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008ed:	50                   	push   %eax
  8008ee:	68 e6 03 80 00       	push   $0x8003e6
  8008f3:	e8 30 fb ff ff       	call   800428 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008f8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008fb:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800901:	83 c4 10             	add    $0x10,%esp
}
  800904:	c9                   	leave  
  800905:	c3                   	ret    
		return -E_INVAL;
  800906:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80090b:	eb f7                	jmp    800904 <vsnprintf+0x49>

0080090d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80090d:	f3 0f 1e fb          	endbr32 
  800911:	55                   	push   %ebp
  800912:	89 e5                	mov    %esp,%ebp
  800914:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800917:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80091a:	50                   	push   %eax
  80091b:	ff 75 10             	pushl  0x10(%ebp)
  80091e:	ff 75 0c             	pushl  0xc(%ebp)
  800921:	ff 75 08             	pushl  0x8(%ebp)
  800924:	e8 92 ff ff ff       	call   8008bb <vsnprintf>
	va_end(ap);

	return rc;
}
  800929:	c9                   	leave  
  80092a:	c3                   	ret    

0080092b <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80092b:	f3 0f 1e fb          	endbr32 
  80092f:	55                   	push   %ebp
  800930:	89 e5                	mov    %esp,%ebp
  800932:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800935:	b8 00 00 00 00       	mov    $0x0,%eax
  80093a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80093e:	74 05                	je     800945 <strlen+0x1a>
		n++;
  800940:	83 c0 01             	add    $0x1,%eax
  800943:	eb f5                	jmp    80093a <strlen+0xf>
	return n;
}
  800945:	5d                   	pop    %ebp
  800946:	c3                   	ret    

00800947 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800947:	f3 0f 1e fb          	endbr32 
  80094b:	55                   	push   %ebp
  80094c:	89 e5                	mov    %esp,%ebp
  80094e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800951:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800954:	b8 00 00 00 00       	mov    $0x0,%eax
  800959:	39 d0                	cmp    %edx,%eax
  80095b:	74 0d                	je     80096a <strnlen+0x23>
  80095d:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800961:	74 05                	je     800968 <strnlen+0x21>
		n++;
  800963:	83 c0 01             	add    $0x1,%eax
  800966:	eb f1                	jmp    800959 <strnlen+0x12>
  800968:	89 c2                	mov    %eax,%edx
	return n;
}
  80096a:	89 d0                	mov    %edx,%eax
  80096c:	5d                   	pop    %ebp
  80096d:	c3                   	ret    

0080096e <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80096e:	f3 0f 1e fb          	endbr32 
  800972:	55                   	push   %ebp
  800973:	89 e5                	mov    %esp,%ebp
  800975:	53                   	push   %ebx
  800976:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800979:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80097c:	b8 00 00 00 00       	mov    $0x0,%eax
  800981:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800985:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800988:	83 c0 01             	add    $0x1,%eax
  80098b:	84 d2                	test   %dl,%dl
  80098d:	75 f2                	jne    800981 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  80098f:	89 c8                	mov    %ecx,%eax
  800991:	5b                   	pop    %ebx
  800992:	5d                   	pop    %ebp
  800993:	c3                   	ret    

00800994 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800994:	f3 0f 1e fb          	endbr32 
  800998:	55                   	push   %ebp
  800999:	89 e5                	mov    %esp,%ebp
  80099b:	53                   	push   %ebx
  80099c:	83 ec 10             	sub    $0x10,%esp
  80099f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8009a2:	53                   	push   %ebx
  8009a3:	e8 83 ff ff ff       	call   80092b <strlen>
  8009a8:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8009ab:	ff 75 0c             	pushl  0xc(%ebp)
  8009ae:	01 d8                	add    %ebx,%eax
  8009b0:	50                   	push   %eax
  8009b1:	e8 b8 ff ff ff       	call   80096e <strcpy>
	return dst;
}
  8009b6:	89 d8                	mov    %ebx,%eax
  8009b8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009bb:	c9                   	leave  
  8009bc:	c3                   	ret    

008009bd <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8009bd:	f3 0f 1e fb          	endbr32 
  8009c1:	55                   	push   %ebp
  8009c2:	89 e5                	mov    %esp,%ebp
  8009c4:	56                   	push   %esi
  8009c5:	53                   	push   %ebx
  8009c6:	8b 75 08             	mov    0x8(%ebp),%esi
  8009c9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009cc:	89 f3                	mov    %esi,%ebx
  8009ce:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009d1:	89 f0                	mov    %esi,%eax
  8009d3:	39 d8                	cmp    %ebx,%eax
  8009d5:	74 11                	je     8009e8 <strncpy+0x2b>
		*dst++ = *src;
  8009d7:	83 c0 01             	add    $0x1,%eax
  8009da:	0f b6 0a             	movzbl (%edx),%ecx
  8009dd:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8009e0:	80 f9 01             	cmp    $0x1,%cl
  8009e3:	83 da ff             	sbb    $0xffffffff,%edx
  8009e6:	eb eb                	jmp    8009d3 <strncpy+0x16>
	}
	return ret;
}
  8009e8:	89 f0                	mov    %esi,%eax
  8009ea:	5b                   	pop    %ebx
  8009eb:	5e                   	pop    %esi
  8009ec:	5d                   	pop    %ebp
  8009ed:	c3                   	ret    

008009ee <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009ee:	f3 0f 1e fb          	endbr32 
  8009f2:	55                   	push   %ebp
  8009f3:	89 e5                	mov    %esp,%ebp
  8009f5:	56                   	push   %esi
  8009f6:	53                   	push   %ebx
  8009f7:	8b 75 08             	mov    0x8(%ebp),%esi
  8009fa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009fd:	8b 55 10             	mov    0x10(%ebp),%edx
  800a00:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a02:	85 d2                	test   %edx,%edx
  800a04:	74 21                	je     800a27 <strlcpy+0x39>
  800a06:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800a0a:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  800a0c:	39 c2                	cmp    %eax,%edx
  800a0e:	74 14                	je     800a24 <strlcpy+0x36>
  800a10:	0f b6 19             	movzbl (%ecx),%ebx
  800a13:	84 db                	test   %bl,%bl
  800a15:	74 0b                	je     800a22 <strlcpy+0x34>
			*dst++ = *src++;
  800a17:	83 c1 01             	add    $0x1,%ecx
  800a1a:	83 c2 01             	add    $0x1,%edx
  800a1d:	88 5a ff             	mov    %bl,-0x1(%edx)
  800a20:	eb ea                	jmp    800a0c <strlcpy+0x1e>
  800a22:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800a24:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a27:	29 f0                	sub    %esi,%eax
}
  800a29:	5b                   	pop    %ebx
  800a2a:	5e                   	pop    %esi
  800a2b:	5d                   	pop    %ebp
  800a2c:	c3                   	ret    

00800a2d <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a2d:	f3 0f 1e fb          	endbr32 
  800a31:	55                   	push   %ebp
  800a32:	89 e5                	mov    %esp,%ebp
  800a34:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a37:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a3a:	0f b6 01             	movzbl (%ecx),%eax
  800a3d:	84 c0                	test   %al,%al
  800a3f:	74 0c                	je     800a4d <strcmp+0x20>
  800a41:	3a 02                	cmp    (%edx),%al
  800a43:	75 08                	jne    800a4d <strcmp+0x20>
		p++, q++;
  800a45:	83 c1 01             	add    $0x1,%ecx
  800a48:	83 c2 01             	add    $0x1,%edx
  800a4b:	eb ed                	jmp    800a3a <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a4d:	0f b6 c0             	movzbl %al,%eax
  800a50:	0f b6 12             	movzbl (%edx),%edx
  800a53:	29 d0                	sub    %edx,%eax
}
  800a55:	5d                   	pop    %ebp
  800a56:	c3                   	ret    

00800a57 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a57:	f3 0f 1e fb          	endbr32 
  800a5b:	55                   	push   %ebp
  800a5c:	89 e5                	mov    %esp,%ebp
  800a5e:	53                   	push   %ebx
  800a5f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a62:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a65:	89 c3                	mov    %eax,%ebx
  800a67:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a6a:	eb 06                	jmp    800a72 <strncmp+0x1b>
		n--, p++, q++;
  800a6c:	83 c0 01             	add    $0x1,%eax
  800a6f:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800a72:	39 d8                	cmp    %ebx,%eax
  800a74:	74 16                	je     800a8c <strncmp+0x35>
  800a76:	0f b6 08             	movzbl (%eax),%ecx
  800a79:	84 c9                	test   %cl,%cl
  800a7b:	74 04                	je     800a81 <strncmp+0x2a>
  800a7d:	3a 0a                	cmp    (%edx),%cl
  800a7f:	74 eb                	je     800a6c <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a81:	0f b6 00             	movzbl (%eax),%eax
  800a84:	0f b6 12             	movzbl (%edx),%edx
  800a87:	29 d0                	sub    %edx,%eax
}
  800a89:	5b                   	pop    %ebx
  800a8a:	5d                   	pop    %ebp
  800a8b:	c3                   	ret    
		return 0;
  800a8c:	b8 00 00 00 00       	mov    $0x0,%eax
  800a91:	eb f6                	jmp    800a89 <strncmp+0x32>

00800a93 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a93:	f3 0f 1e fb          	endbr32 
  800a97:	55                   	push   %ebp
  800a98:	89 e5                	mov    %esp,%ebp
  800a9a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a9d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800aa1:	0f b6 10             	movzbl (%eax),%edx
  800aa4:	84 d2                	test   %dl,%dl
  800aa6:	74 09                	je     800ab1 <strchr+0x1e>
		if (*s == c)
  800aa8:	38 ca                	cmp    %cl,%dl
  800aaa:	74 0a                	je     800ab6 <strchr+0x23>
	for (; *s; s++)
  800aac:	83 c0 01             	add    $0x1,%eax
  800aaf:	eb f0                	jmp    800aa1 <strchr+0xe>
			return (char *) s;
	return 0;
  800ab1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ab6:	5d                   	pop    %ebp
  800ab7:	c3                   	ret    

00800ab8 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800ab8:	f3 0f 1e fb          	endbr32 
  800abc:	55                   	push   %ebp
  800abd:	89 e5                	mov    %esp,%ebp
  800abf:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac2:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ac6:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800ac9:	38 ca                	cmp    %cl,%dl
  800acb:	74 09                	je     800ad6 <strfind+0x1e>
  800acd:	84 d2                	test   %dl,%dl
  800acf:	74 05                	je     800ad6 <strfind+0x1e>
	for (; *s; s++)
  800ad1:	83 c0 01             	add    $0x1,%eax
  800ad4:	eb f0                	jmp    800ac6 <strfind+0xe>
			break;
	return (char *) s;
}
  800ad6:	5d                   	pop    %ebp
  800ad7:	c3                   	ret    

00800ad8 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800ad8:	f3 0f 1e fb          	endbr32 
  800adc:	55                   	push   %ebp
  800add:	89 e5                	mov    %esp,%ebp
  800adf:	57                   	push   %edi
  800ae0:	56                   	push   %esi
  800ae1:	53                   	push   %ebx
  800ae2:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ae5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800ae8:	85 c9                	test   %ecx,%ecx
  800aea:	74 31                	je     800b1d <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800aec:	89 f8                	mov    %edi,%eax
  800aee:	09 c8                	or     %ecx,%eax
  800af0:	a8 03                	test   $0x3,%al
  800af2:	75 23                	jne    800b17 <memset+0x3f>
		c &= 0xFF;
  800af4:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800af8:	89 d3                	mov    %edx,%ebx
  800afa:	c1 e3 08             	shl    $0x8,%ebx
  800afd:	89 d0                	mov    %edx,%eax
  800aff:	c1 e0 18             	shl    $0x18,%eax
  800b02:	89 d6                	mov    %edx,%esi
  800b04:	c1 e6 10             	shl    $0x10,%esi
  800b07:	09 f0                	or     %esi,%eax
  800b09:	09 c2                	or     %eax,%edx
  800b0b:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800b0d:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800b10:	89 d0                	mov    %edx,%eax
  800b12:	fc                   	cld    
  800b13:	f3 ab                	rep stos %eax,%es:(%edi)
  800b15:	eb 06                	jmp    800b1d <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b17:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b1a:	fc                   	cld    
  800b1b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b1d:	89 f8                	mov    %edi,%eax
  800b1f:	5b                   	pop    %ebx
  800b20:	5e                   	pop    %esi
  800b21:	5f                   	pop    %edi
  800b22:	5d                   	pop    %ebp
  800b23:	c3                   	ret    

00800b24 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b24:	f3 0f 1e fb          	endbr32 
  800b28:	55                   	push   %ebp
  800b29:	89 e5                	mov    %esp,%ebp
  800b2b:	57                   	push   %edi
  800b2c:	56                   	push   %esi
  800b2d:	8b 45 08             	mov    0x8(%ebp),%eax
  800b30:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b33:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b36:	39 c6                	cmp    %eax,%esi
  800b38:	73 32                	jae    800b6c <memmove+0x48>
  800b3a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b3d:	39 c2                	cmp    %eax,%edx
  800b3f:	76 2b                	jbe    800b6c <memmove+0x48>
		s += n;
		d += n;
  800b41:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b44:	89 fe                	mov    %edi,%esi
  800b46:	09 ce                	or     %ecx,%esi
  800b48:	09 d6                	or     %edx,%esi
  800b4a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b50:	75 0e                	jne    800b60 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b52:	83 ef 04             	sub    $0x4,%edi
  800b55:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b58:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800b5b:	fd                   	std    
  800b5c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b5e:	eb 09                	jmp    800b69 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b60:	83 ef 01             	sub    $0x1,%edi
  800b63:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800b66:	fd                   	std    
  800b67:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b69:	fc                   	cld    
  800b6a:	eb 1a                	jmp    800b86 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b6c:	89 c2                	mov    %eax,%edx
  800b6e:	09 ca                	or     %ecx,%edx
  800b70:	09 f2                	or     %esi,%edx
  800b72:	f6 c2 03             	test   $0x3,%dl
  800b75:	75 0a                	jne    800b81 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b77:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800b7a:	89 c7                	mov    %eax,%edi
  800b7c:	fc                   	cld    
  800b7d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b7f:	eb 05                	jmp    800b86 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800b81:	89 c7                	mov    %eax,%edi
  800b83:	fc                   	cld    
  800b84:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b86:	5e                   	pop    %esi
  800b87:	5f                   	pop    %edi
  800b88:	5d                   	pop    %ebp
  800b89:	c3                   	ret    

00800b8a <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b8a:	f3 0f 1e fb          	endbr32 
  800b8e:	55                   	push   %ebp
  800b8f:	89 e5                	mov    %esp,%ebp
  800b91:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800b94:	ff 75 10             	pushl  0x10(%ebp)
  800b97:	ff 75 0c             	pushl  0xc(%ebp)
  800b9a:	ff 75 08             	pushl  0x8(%ebp)
  800b9d:	e8 82 ff ff ff       	call   800b24 <memmove>
}
  800ba2:	c9                   	leave  
  800ba3:	c3                   	ret    

00800ba4 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ba4:	f3 0f 1e fb          	endbr32 
  800ba8:	55                   	push   %ebp
  800ba9:	89 e5                	mov    %esp,%ebp
  800bab:	56                   	push   %esi
  800bac:	53                   	push   %ebx
  800bad:	8b 45 08             	mov    0x8(%ebp),%eax
  800bb0:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bb3:	89 c6                	mov    %eax,%esi
  800bb5:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bb8:	39 f0                	cmp    %esi,%eax
  800bba:	74 1c                	je     800bd8 <memcmp+0x34>
		if (*s1 != *s2)
  800bbc:	0f b6 08             	movzbl (%eax),%ecx
  800bbf:	0f b6 1a             	movzbl (%edx),%ebx
  800bc2:	38 d9                	cmp    %bl,%cl
  800bc4:	75 08                	jne    800bce <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800bc6:	83 c0 01             	add    $0x1,%eax
  800bc9:	83 c2 01             	add    $0x1,%edx
  800bcc:	eb ea                	jmp    800bb8 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800bce:	0f b6 c1             	movzbl %cl,%eax
  800bd1:	0f b6 db             	movzbl %bl,%ebx
  800bd4:	29 d8                	sub    %ebx,%eax
  800bd6:	eb 05                	jmp    800bdd <memcmp+0x39>
	}

	return 0;
  800bd8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bdd:	5b                   	pop    %ebx
  800bde:	5e                   	pop    %esi
  800bdf:	5d                   	pop    %ebp
  800be0:	c3                   	ret    

00800be1 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800be1:	f3 0f 1e fb          	endbr32 
  800be5:	55                   	push   %ebp
  800be6:	89 e5                	mov    %esp,%ebp
  800be8:	8b 45 08             	mov    0x8(%ebp),%eax
  800beb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800bee:	89 c2                	mov    %eax,%edx
  800bf0:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800bf3:	39 d0                	cmp    %edx,%eax
  800bf5:	73 09                	jae    800c00 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800bf7:	38 08                	cmp    %cl,(%eax)
  800bf9:	74 05                	je     800c00 <memfind+0x1f>
	for (; s < ends; s++)
  800bfb:	83 c0 01             	add    $0x1,%eax
  800bfe:	eb f3                	jmp    800bf3 <memfind+0x12>
			break;
	return (void *) s;
}
  800c00:	5d                   	pop    %ebp
  800c01:	c3                   	ret    

00800c02 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c02:	f3 0f 1e fb          	endbr32 
  800c06:	55                   	push   %ebp
  800c07:	89 e5                	mov    %esp,%ebp
  800c09:	57                   	push   %edi
  800c0a:	56                   	push   %esi
  800c0b:	53                   	push   %ebx
  800c0c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c0f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c12:	eb 03                	jmp    800c17 <strtol+0x15>
		s++;
  800c14:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800c17:	0f b6 01             	movzbl (%ecx),%eax
  800c1a:	3c 20                	cmp    $0x20,%al
  800c1c:	74 f6                	je     800c14 <strtol+0x12>
  800c1e:	3c 09                	cmp    $0x9,%al
  800c20:	74 f2                	je     800c14 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800c22:	3c 2b                	cmp    $0x2b,%al
  800c24:	74 2a                	je     800c50 <strtol+0x4e>
	int neg = 0;
  800c26:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800c2b:	3c 2d                	cmp    $0x2d,%al
  800c2d:	74 2b                	je     800c5a <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c2f:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c35:	75 0f                	jne    800c46 <strtol+0x44>
  800c37:	80 39 30             	cmpb   $0x30,(%ecx)
  800c3a:	74 28                	je     800c64 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c3c:	85 db                	test   %ebx,%ebx
  800c3e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c43:	0f 44 d8             	cmove  %eax,%ebx
  800c46:	b8 00 00 00 00       	mov    $0x0,%eax
  800c4b:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800c4e:	eb 46                	jmp    800c96 <strtol+0x94>
		s++;
  800c50:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800c53:	bf 00 00 00 00       	mov    $0x0,%edi
  800c58:	eb d5                	jmp    800c2f <strtol+0x2d>
		s++, neg = 1;
  800c5a:	83 c1 01             	add    $0x1,%ecx
  800c5d:	bf 01 00 00 00       	mov    $0x1,%edi
  800c62:	eb cb                	jmp    800c2f <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c64:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c68:	74 0e                	je     800c78 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800c6a:	85 db                	test   %ebx,%ebx
  800c6c:	75 d8                	jne    800c46 <strtol+0x44>
		s++, base = 8;
  800c6e:	83 c1 01             	add    $0x1,%ecx
  800c71:	bb 08 00 00 00       	mov    $0x8,%ebx
  800c76:	eb ce                	jmp    800c46 <strtol+0x44>
		s += 2, base = 16;
  800c78:	83 c1 02             	add    $0x2,%ecx
  800c7b:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c80:	eb c4                	jmp    800c46 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800c82:	0f be d2             	movsbl %dl,%edx
  800c85:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800c88:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c8b:	7d 3a                	jge    800cc7 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800c8d:	83 c1 01             	add    $0x1,%ecx
  800c90:	0f af 45 10          	imul   0x10(%ebp),%eax
  800c94:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800c96:	0f b6 11             	movzbl (%ecx),%edx
  800c99:	8d 72 d0             	lea    -0x30(%edx),%esi
  800c9c:	89 f3                	mov    %esi,%ebx
  800c9e:	80 fb 09             	cmp    $0x9,%bl
  800ca1:	76 df                	jbe    800c82 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800ca3:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ca6:	89 f3                	mov    %esi,%ebx
  800ca8:	80 fb 19             	cmp    $0x19,%bl
  800cab:	77 08                	ja     800cb5 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800cad:	0f be d2             	movsbl %dl,%edx
  800cb0:	83 ea 57             	sub    $0x57,%edx
  800cb3:	eb d3                	jmp    800c88 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800cb5:	8d 72 bf             	lea    -0x41(%edx),%esi
  800cb8:	89 f3                	mov    %esi,%ebx
  800cba:	80 fb 19             	cmp    $0x19,%bl
  800cbd:	77 08                	ja     800cc7 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800cbf:	0f be d2             	movsbl %dl,%edx
  800cc2:	83 ea 37             	sub    $0x37,%edx
  800cc5:	eb c1                	jmp    800c88 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800cc7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ccb:	74 05                	je     800cd2 <strtol+0xd0>
		*endptr = (char *) s;
  800ccd:	8b 75 0c             	mov    0xc(%ebp),%esi
  800cd0:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800cd2:	89 c2                	mov    %eax,%edx
  800cd4:	f7 da                	neg    %edx
  800cd6:	85 ff                	test   %edi,%edi
  800cd8:	0f 45 c2             	cmovne %edx,%eax
}
  800cdb:	5b                   	pop    %ebx
  800cdc:	5e                   	pop    %esi
  800cdd:	5f                   	pop    %edi
  800cde:	5d                   	pop    %ebp
  800cdf:	c3                   	ret    

00800ce0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ce0:	f3 0f 1e fb          	endbr32 
  800ce4:	55                   	push   %ebp
  800ce5:	89 e5                	mov    %esp,%ebp
  800ce7:	57                   	push   %edi
  800ce8:	56                   	push   %esi
  800ce9:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cea:	b8 00 00 00 00       	mov    $0x0,%eax
  800cef:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf5:	89 c3                	mov    %eax,%ebx
  800cf7:	89 c7                	mov    %eax,%edi
  800cf9:	89 c6                	mov    %eax,%esi
  800cfb:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800cfd:	5b                   	pop    %ebx
  800cfe:	5e                   	pop    %esi
  800cff:	5f                   	pop    %edi
  800d00:	5d                   	pop    %ebp
  800d01:	c3                   	ret    

00800d02 <sys_cgetc>:

int
sys_cgetc(void)
{
  800d02:	f3 0f 1e fb          	endbr32 
  800d06:	55                   	push   %ebp
  800d07:	89 e5                	mov    %esp,%ebp
  800d09:	57                   	push   %edi
  800d0a:	56                   	push   %esi
  800d0b:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d0c:	ba 00 00 00 00       	mov    $0x0,%edx
  800d11:	b8 01 00 00 00       	mov    $0x1,%eax
  800d16:	89 d1                	mov    %edx,%ecx
  800d18:	89 d3                	mov    %edx,%ebx
  800d1a:	89 d7                	mov    %edx,%edi
  800d1c:	89 d6                	mov    %edx,%esi
  800d1e:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800d20:	5b                   	pop    %ebx
  800d21:	5e                   	pop    %esi
  800d22:	5f                   	pop    %edi
  800d23:	5d                   	pop    %ebp
  800d24:	c3                   	ret    

00800d25 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800d25:	f3 0f 1e fb          	endbr32 
  800d29:	55                   	push   %ebp
  800d2a:	89 e5                	mov    %esp,%ebp
  800d2c:	57                   	push   %edi
  800d2d:	56                   	push   %esi
  800d2e:	53                   	push   %ebx
  800d2f:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d32:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d37:	8b 55 08             	mov    0x8(%ebp),%edx
  800d3a:	b8 03 00 00 00       	mov    $0x3,%eax
  800d3f:	89 cb                	mov    %ecx,%ebx
  800d41:	89 cf                	mov    %ecx,%edi
  800d43:	89 ce                	mov    %ecx,%esi
  800d45:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d47:	85 c0                	test   %eax,%eax
  800d49:	7f 08                	jg     800d53 <sys_env_destroy+0x2e>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800d4b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d4e:	5b                   	pop    %ebx
  800d4f:	5e                   	pop    %esi
  800d50:	5f                   	pop    %edi
  800d51:	5d                   	pop    %ebp
  800d52:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d53:	83 ec 0c             	sub    $0xc,%esp
  800d56:	50                   	push   %eax
  800d57:	6a 03                	push   $0x3
  800d59:	68 e4 14 80 00       	push   $0x8014e4
  800d5e:	6a 23                	push   $0x23
  800d60:	68 01 15 80 00       	push   $0x801501
  800d65:	e8 d4 f4 ff ff       	call   80023e <_panic>

00800d6a <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d6a:	f3 0f 1e fb          	endbr32 
  800d6e:	55                   	push   %ebp
  800d6f:	89 e5                	mov    %esp,%ebp
  800d71:	57                   	push   %edi
  800d72:	56                   	push   %esi
  800d73:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d74:	ba 00 00 00 00       	mov    $0x0,%edx
  800d79:	b8 02 00 00 00       	mov    $0x2,%eax
  800d7e:	89 d1                	mov    %edx,%ecx
  800d80:	89 d3                	mov    %edx,%ebx
  800d82:	89 d7                	mov    %edx,%edi
  800d84:	89 d6                	mov    %edx,%esi
  800d86:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d88:	5b                   	pop    %ebx
  800d89:	5e                   	pop    %esi
  800d8a:	5f                   	pop    %edi
  800d8b:	5d                   	pop    %ebp
  800d8c:	c3                   	ret    

00800d8d <sys_yield>:

void
sys_yield(void)
{
  800d8d:	f3 0f 1e fb          	endbr32 
  800d91:	55                   	push   %ebp
  800d92:	89 e5                	mov    %esp,%ebp
  800d94:	57                   	push   %edi
  800d95:	56                   	push   %esi
  800d96:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d97:	ba 00 00 00 00       	mov    $0x0,%edx
  800d9c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800da1:	89 d1                	mov    %edx,%ecx
  800da3:	89 d3                	mov    %edx,%ebx
  800da5:	89 d7                	mov    %edx,%edi
  800da7:	89 d6                	mov    %edx,%esi
  800da9:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800dab:	5b                   	pop    %ebx
  800dac:	5e                   	pop    %esi
  800dad:	5f                   	pop    %edi
  800dae:	5d                   	pop    %ebp
  800daf:	c3                   	ret    

00800db0 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800db0:	f3 0f 1e fb          	endbr32 
  800db4:	55                   	push   %ebp
  800db5:	89 e5                	mov    %esp,%ebp
  800db7:	57                   	push   %edi
  800db8:	56                   	push   %esi
  800db9:	53                   	push   %ebx
  800dba:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800dbd:	be 00 00 00 00       	mov    $0x0,%esi
  800dc2:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dc8:	b8 04 00 00 00       	mov    $0x4,%eax
  800dcd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dd0:	89 f7                	mov    %esi,%edi
  800dd2:	cd 30                	int    $0x30
	if(check && ret > 0)
  800dd4:	85 c0                	test   %eax,%eax
  800dd6:	7f 08                	jg     800de0 <sys_page_alloc+0x30>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800dd8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ddb:	5b                   	pop    %ebx
  800ddc:	5e                   	pop    %esi
  800ddd:	5f                   	pop    %edi
  800dde:	5d                   	pop    %ebp
  800ddf:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800de0:	83 ec 0c             	sub    $0xc,%esp
  800de3:	50                   	push   %eax
  800de4:	6a 04                	push   $0x4
  800de6:	68 e4 14 80 00       	push   $0x8014e4
  800deb:	6a 23                	push   $0x23
  800ded:	68 01 15 80 00       	push   $0x801501
  800df2:	e8 47 f4 ff ff       	call   80023e <_panic>

00800df7 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800df7:	f3 0f 1e fb          	endbr32 
  800dfb:	55                   	push   %ebp
  800dfc:	89 e5                	mov    %esp,%ebp
  800dfe:	57                   	push   %edi
  800dff:	56                   	push   %esi
  800e00:	53                   	push   %ebx
  800e01:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e04:	8b 55 08             	mov    0x8(%ebp),%edx
  800e07:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e0a:	b8 05 00 00 00       	mov    $0x5,%eax
  800e0f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e12:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e15:	8b 75 18             	mov    0x18(%ebp),%esi
  800e18:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e1a:	85 c0                	test   %eax,%eax
  800e1c:	7f 08                	jg     800e26 <sys_page_map+0x2f>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800e1e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e21:	5b                   	pop    %ebx
  800e22:	5e                   	pop    %esi
  800e23:	5f                   	pop    %edi
  800e24:	5d                   	pop    %ebp
  800e25:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e26:	83 ec 0c             	sub    $0xc,%esp
  800e29:	50                   	push   %eax
  800e2a:	6a 05                	push   $0x5
  800e2c:	68 e4 14 80 00       	push   $0x8014e4
  800e31:	6a 23                	push   $0x23
  800e33:	68 01 15 80 00       	push   $0x801501
  800e38:	e8 01 f4 ff ff       	call   80023e <_panic>

00800e3d <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800e3d:	f3 0f 1e fb          	endbr32 
  800e41:	55                   	push   %ebp
  800e42:	89 e5                	mov    %esp,%ebp
  800e44:	57                   	push   %edi
  800e45:	56                   	push   %esi
  800e46:	53                   	push   %ebx
  800e47:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e4a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e4f:	8b 55 08             	mov    0x8(%ebp),%edx
  800e52:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e55:	b8 06 00 00 00       	mov    $0x6,%eax
  800e5a:	89 df                	mov    %ebx,%edi
  800e5c:	89 de                	mov    %ebx,%esi
  800e5e:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e60:	85 c0                	test   %eax,%eax
  800e62:	7f 08                	jg     800e6c <sys_page_unmap+0x2f>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e64:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e67:	5b                   	pop    %ebx
  800e68:	5e                   	pop    %esi
  800e69:	5f                   	pop    %edi
  800e6a:	5d                   	pop    %ebp
  800e6b:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e6c:	83 ec 0c             	sub    $0xc,%esp
  800e6f:	50                   	push   %eax
  800e70:	6a 06                	push   $0x6
  800e72:	68 e4 14 80 00       	push   $0x8014e4
  800e77:	6a 23                	push   $0x23
  800e79:	68 01 15 80 00       	push   $0x801501
  800e7e:	e8 bb f3 ff ff       	call   80023e <_panic>

00800e83 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e83:	f3 0f 1e fb          	endbr32 
  800e87:	55                   	push   %ebp
  800e88:	89 e5                	mov    %esp,%ebp
  800e8a:	57                   	push   %edi
  800e8b:	56                   	push   %esi
  800e8c:	53                   	push   %ebx
  800e8d:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e90:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e95:	8b 55 08             	mov    0x8(%ebp),%edx
  800e98:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e9b:	b8 08 00 00 00       	mov    $0x8,%eax
  800ea0:	89 df                	mov    %ebx,%edi
  800ea2:	89 de                	mov    %ebx,%esi
  800ea4:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ea6:	85 c0                	test   %eax,%eax
  800ea8:	7f 08                	jg     800eb2 <sys_env_set_status+0x2f>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800eaa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ead:	5b                   	pop    %ebx
  800eae:	5e                   	pop    %esi
  800eaf:	5f                   	pop    %edi
  800eb0:	5d                   	pop    %ebp
  800eb1:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800eb2:	83 ec 0c             	sub    $0xc,%esp
  800eb5:	50                   	push   %eax
  800eb6:	6a 08                	push   $0x8
  800eb8:	68 e4 14 80 00       	push   $0x8014e4
  800ebd:	6a 23                	push   $0x23
  800ebf:	68 01 15 80 00       	push   $0x801501
  800ec4:	e8 75 f3 ff ff       	call   80023e <_panic>

00800ec9 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ec9:	f3 0f 1e fb          	endbr32 
  800ecd:	55                   	push   %ebp
  800ece:	89 e5                	mov    %esp,%ebp
  800ed0:	57                   	push   %edi
  800ed1:	56                   	push   %esi
  800ed2:	53                   	push   %ebx
  800ed3:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800ed6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800edb:	8b 55 08             	mov    0x8(%ebp),%edx
  800ede:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ee1:	b8 09 00 00 00       	mov    $0x9,%eax
  800ee6:	89 df                	mov    %ebx,%edi
  800ee8:	89 de                	mov    %ebx,%esi
  800eea:	cd 30                	int    $0x30
	if(check && ret > 0)
  800eec:	85 c0                	test   %eax,%eax
  800eee:	7f 08                	jg     800ef8 <sys_env_set_pgfault_upcall+0x2f>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800ef0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ef3:	5b                   	pop    %ebx
  800ef4:	5e                   	pop    %esi
  800ef5:	5f                   	pop    %edi
  800ef6:	5d                   	pop    %ebp
  800ef7:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ef8:	83 ec 0c             	sub    $0xc,%esp
  800efb:	50                   	push   %eax
  800efc:	6a 09                	push   $0x9
  800efe:	68 e4 14 80 00       	push   $0x8014e4
  800f03:	6a 23                	push   $0x23
  800f05:	68 01 15 80 00       	push   $0x801501
  800f0a:	e8 2f f3 ff ff       	call   80023e <_panic>

00800f0f <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800f0f:	f3 0f 1e fb          	endbr32 
  800f13:	55                   	push   %ebp
  800f14:	89 e5                	mov    %esp,%ebp
  800f16:	57                   	push   %edi
  800f17:	56                   	push   %esi
  800f18:	53                   	push   %ebx
	asm volatile("int %1\n"
  800f19:	8b 55 08             	mov    0x8(%ebp),%edx
  800f1c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f1f:	b8 0b 00 00 00       	mov    $0xb,%eax
  800f24:	be 00 00 00 00       	mov    $0x0,%esi
  800f29:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f2c:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f2f:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800f31:	5b                   	pop    %ebx
  800f32:	5e                   	pop    %esi
  800f33:	5f                   	pop    %edi
  800f34:	5d                   	pop    %ebp
  800f35:	c3                   	ret    

00800f36 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800f36:	f3 0f 1e fb          	endbr32 
  800f3a:	55                   	push   %ebp
  800f3b:	89 e5                	mov    %esp,%ebp
  800f3d:	57                   	push   %edi
  800f3e:	56                   	push   %esi
  800f3f:	53                   	push   %ebx
  800f40:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800f43:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f48:	8b 55 08             	mov    0x8(%ebp),%edx
  800f4b:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f50:	89 cb                	mov    %ecx,%ebx
  800f52:	89 cf                	mov    %ecx,%edi
  800f54:	89 ce                	mov    %ecx,%esi
  800f56:	cd 30                	int    $0x30
	if(check && ret > 0)
  800f58:	85 c0                	test   %eax,%eax
  800f5a:	7f 08                	jg     800f64 <sys_ipc_recv+0x2e>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f5c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f5f:	5b                   	pop    %ebx
  800f60:	5e                   	pop    %esi
  800f61:	5f                   	pop    %edi
  800f62:	5d                   	pop    %ebp
  800f63:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800f64:	83 ec 0c             	sub    $0xc,%esp
  800f67:	50                   	push   %eax
  800f68:	6a 0c                	push   $0xc
  800f6a:	68 e4 14 80 00       	push   $0x8014e4
  800f6f:	6a 23                	push   $0x23
  800f71:	68 01 15 80 00       	push   $0x801501
  800f76:	e8 c3 f2 ff ff       	call   80023e <_panic>
  800f7b:	66 90                	xchg   %ax,%ax
  800f7d:	66 90                	xchg   %ax,%ax
  800f7f:	90                   	nop

00800f80 <__udivdi3>:
  800f80:	f3 0f 1e fb          	endbr32 
  800f84:	55                   	push   %ebp
  800f85:	57                   	push   %edi
  800f86:	56                   	push   %esi
  800f87:	53                   	push   %ebx
  800f88:	83 ec 1c             	sub    $0x1c,%esp
  800f8b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800f8f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800f93:	8b 74 24 34          	mov    0x34(%esp),%esi
  800f97:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800f9b:	85 d2                	test   %edx,%edx
  800f9d:	75 19                	jne    800fb8 <__udivdi3+0x38>
  800f9f:	39 f3                	cmp    %esi,%ebx
  800fa1:	76 4d                	jbe    800ff0 <__udivdi3+0x70>
  800fa3:	31 ff                	xor    %edi,%edi
  800fa5:	89 e8                	mov    %ebp,%eax
  800fa7:	89 f2                	mov    %esi,%edx
  800fa9:	f7 f3                	div    %ebx
  800fab:	89 fa                	mov    %edi,%edx
  800fad:	83 c4 1c             	add    $0x1c,%esp
  800fb0:	5b                   	pop    %ebx
  800fb1:	5e                   	pop    %esi
  800fb2:	5f                   	pop    %edi
  800fb3:	5d                   	pop    %ebp
  800fb4:	c3                   	ret    
  800fb5:	8d 76 00             	lea    0x0(%esi),%esi
  800fb8:	39 f2                	cmp    %esi,%edx
  800fba:	76 14                	jbe    800fd0 <__udivdi3+0x50>
  800fbc:	31 ff                	xor    %edi,%edi
  800fbe:	31 c0                	xor    %eax,%eax
  800fc0:	89 fa                	mov    %edi,%edx
  800fc2:	83 c4 1c             	add    $0x1c,%esp
  800fc5:	5b                   	pop    %ebx
  800fc6:	5e                   	pop    %esi
  800fc7:	5f                   	pop    %edi
  800fc8:	5d                   	pop    %ebp
  800fc9:	c3                   	ret    
  800fca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800fd0:	0f bd fa             	bsr    %edx,%edi
  800fd3:	83 f7 1f             	xor    $0x1f,%edi
  800fd6:	75 48                	jne    801020 <__udivdi3+0xa0>
  800fd8:	39 f2                	cmp    %esi,%edx
  800fda:	72 06                	jb     800fe2 <__udivdi3+0x62>
  800fdc:	31 c0                	xor    %eax,%eax
  800fde:	39 eb                	cmp    %ebp,%ebx
  800fe0:	77 de                	ja     800fc0 <__udivdi3+0x40>
  800fe2:	b8 01 00 00 00       	mov    $0x1,%eax
  800fe7:	eb d7                	jmp    800fc0 <__udivdi3+0x40>
  800fe9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800ff0:	89 d9                	mov    %ebx,%ecx
  800ff2:	85 db                	test   %ebx,%ebx
  800ff4:	75 0b                	jne    801001 <__udivdi3+0x81>
  800ff6:	b8 01 00 00 00       	mov    $0x1,%eax
  800ffb:	31 d2                	xor    %edx,%edx
  800ffd:	f7 f3                	div    %ebx
  800fff:	89 c1                	mov    %eax,%ecx
  801001:	31 d2                	xor    %edx,%edx
  801003:	89 f0                	mov    %esi,%eax
  801005:	f7 f1                	div    %ecx
  801007:	89 c6                	mov    %eax,%esi
  801009:	89 e8                	mov    %ebp,%eax
  80100b:	89 f7                	mov    %esi,%edi
  80100d:	f7 f1                	div    %ecx
  80100f:	89 fa                	mov    %edi,%edx
  801011:	83 c4 1c             	add    $0x1c,%esp
  801014:	5b                   	pop    %ebx
  801015:	5e                   	pop    %esi
  801016:	5f                   	pop    %edi
  801017:	5d                   	pop    %ebp
  801018:	c3                   	ret    
  801019:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801020:	89 f9                	mov    %edi,%ecx
  801022:	b8 20 00 00 00       	mov    $0x20,%eax
  801027:	29 f8                	sub    %edi,%eax
  801029:	d3 e2                	shl    %cl,%edx
  80102b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80102f:	89 c1                	mov    %eax,%ecx
  801031:	89 da                	mov    %ebx,%edx
  801033:	d3 ea                	shr    %cl,%edx
  801035:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801039:	09 d1                	or     %edx,%ecx
  80103b:	89 f2                	mov    %esi,%edx
  80103d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801041:	89 f9                	mov    %edi,%ecx
  801043:	d3 e3                	shl    %cl,%ebx
  801045:	89 c1                	mov    %eax,%ecx
  801047:	d3 ea                	shr    %cl,%edx
  801049:	89 f9                	mov    %edi,%ecx
  80104b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80104f:	89 eb                	mov    %ebp,%ebx
  801051:	d3 e6                	shl    %cl,%esi
  801053:	89 c1                	mov    %eax,%ecx
  801055:	d3 eb                	shr    %cl,%ebx
  801057:	09 de                	or     %ebx,%esi
  801059:	89 f0                	mov    %esi,%eax
  80105b:	f7 74 24 08          	divl   0x8(%esp)
  80105f:	89 d6                	mov    %edx,%esi
  801061:	89 c3                	mov    %eax,%ebx
  801063:	f7 64 24 0c          	mull   0xc(%esp)
  801067:	39 d6                	cmp    %edx,%esi
  801069:	72 15                	jb     801080 <__udivdi3+0x100>
  80106b:	89 f9                	mov    %edi,%ecx
  80106d:	d3 e5                	shl    %cl,%ebp
  80106f:	39 c5                	cmp    %eax,%ebp
  801071:	73 04                	jae    801077 <__udivdi3+0xf7>
  801073:	39 d6                	cmp    %edx,%esi
  801075:	74 09                	je     801080 <__udivdi3+0x100>
  801077:	89 d8                	mov    %ebx,%eax
  801079:	31 ff                	xor    %edi,%edi
  80107b:	e9 40 ff ff ff       	jmp    800fc0 <__udivdi3+0x40>
  801080:	8d 43 ff             	lea    -0x1(%ebx),%eax
  801083:	31 ff                	xor    %edi,%edi
  801085:	e9 36 ff ff ff       	jmp    800fc0 <__udivdi3+0x40>
  80108a:	66 90                	xchg   %ax,%ax
  80108c:	66 90                	xchg   %ax,%ax
  80108e:	66 90                	xchg   %ax,%ax

00801090 <__umoddi3>:
  801090:	f3 0f 1e fb          	endbr32 
  801094:	55                   	push   %ebp
  801095:	57                   	push   %edi
  801096:	56                   	push   %esi
  801097:	53                   	push   %ebx
  801098:	83 ec 1c             	sub    $0x1c,%esp
  80109b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80109f:	8b 74 24 30          	mov    0x30(%esp),%esi
  8010a3:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  8010a7:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8010ab:	85 c0                	test   %eax,%eax
  8010ad:	75 19                	jne    8010c8 <__umoddi3+0x38>
  8010af:	39 df                	cmp    %ebx,%edi
  8010b1:	76 5d                	jbe    801110 <__umoddi3+0x80>
  8010b3:	89 f0                	mov    %esi,%eax
  8010b5:	89 da                	mov    %ebx,%edx
  8010b7:	f7 f7                	div    %edi
  8010b9:	89 d0                	mov    %edx,%eax
  8010bb:	31 d2                	xor    %edx,%edx
  8010bd:	83 c4 1c             	add    $0x1c,%esp
  8010c0:	5b                   	pop    %ebx
  8010c1:	5e                   	pop    %esi
  8010c2:	5f                   	pop    %edi
  8010c3:	5d                   	pop    %ebp
  8010c4:	c3                   	ret    
  8010c5:	8d 76 00             	lea    0x0(%esi),%esi
  8010c8:	89 f2                	mov    %esi,%edx
  8010ca:	39 d8                	cmp    %ebx,%eax
  8010cc:	76 12                	jbe    8010e0 <__umoddi3+0x50>
  8010ce:	89 f0                	mov    %esi,%eax
  8010d0:	89 da                	mov    %ebx,%edx
  8010d2:	83 c4 1c             	add    $0x1c,%esp
  8010d5:	5b                   	pop    %ebx
  8010d6:	5e                   	pop    %esi
  8010d7:	5f                   	pop    %edi
  8010d8:	5d                   	pop    %ebp
  8010d9:	c3                   	ret    
  8010da:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8010e0:	0f bd e8             	bsr    %eax,%ebp
  8010e3:	83 f5 1f             	xor    $0x1f,%ebp
  8010e6:	75 50                	jne    801138 <__umoddi3+0xa8>
  8010e8:	39 d8                	cmp    %ebx,%eax
  8010ea:	0f 82 e0 00 00 00    	jb     8011d0 <__umoddi3+0x140>
  8010f0:	89 d9                	mov    %ebx,%ecx
  8010f2:	39 f7                	cmp    %esi,%edi
  8010f4:	0f 86 d6 00 00 00    	jbe    8011d0 <__umoddi3+0x140>
  8010fa:	89 d0                	mov    %edx,%eax
  8010fc:	89 ca                	mov    %ecx,%edx
  8010fe:	83 c4 1c             	add    $0x1c,%esp
  801101:	5b                   	pop    %ebx
  801102:	5e                   	pop    %esi
  801103:	5f                   	pop    %edi
  801104:	5d                   	pop    %ebp
  801105:	c3                   	ret    
  801106:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80110d:	8d 76 00             	lea    0x0(%esi),%esi
  801110:	89 fd                	mov    %edi,%ebp
  801112:	85 ff                	test   %edi,%edi
  801114:	75 0b                	jne    801121 <__umoddi3+0x91>
  801116:	b8 01 00 00 00       	mov    $0x1,%eax
  80111b:	31 d2                	xor    %edx,%edx
  80111d:	f7 f7                	div    %edi
  80111f:	89 c5                	mov    %eax,%ebp
  801121:	89 d8                	mov    %ebx,%eax
  801123:	31 d2                	xor    %edx,%edx
  801125:	f7 f5                	div    %ebp
  801127:	89 f0                	mov    %esi,%eax
  801129:	f7 f5                	div    %ebp
  80112b:	89 d0                	mov    %edx,%eax
  80112d:	31 d2                	xor    %edx,%edx
  80112f:	eb 8c                	jmp    8010bd <__umoddi3+0x2d>
  801131:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801138:	89 e9                	mov    %ebp,%ecx
  80113a:	ba 20 00 00 00       	mov    $0x20,%edx
  80113f:	29 ea                	sub    %ebp,%edx
  801141:	d3 e0                	shl    %cl,%eax
  801143:	89 44 24 08          	mov    %eax,0x8(%esp)
  801147:	89 d1                	mov    %edx,%ecx
  801149:	89 f8                	mov    %edi,%eax
  80114b:	d3 e8                	shr    %cl,%eax
  80114d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801151:	89 54 24 04          	mov    %edx,0x4(%esp)
  801155:	8b 54 24 04          	mov    0x4(%esp),%edx
  801159:	09 c1                	or     %eax,%ecx
  80115b:	89 d8                	mov    %ebx,%eax
  80115d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801161:	89 e9                	mov    %ebp,%ecx
  801163:	d3 e7                	shl    %cl,%edi
  801165:	89 d1                	mov    %edx,%ecx
  801167:	d3 e8                	shr    %cl,%eax
  801169:	89 e9                	mov    %ebp,%ecx
  80116b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80116f:	d3 e3                	shl    %cl,%ebx
  801171:	89 c7                	mov    %eax,%edi
  801173:	89 d1                	mov    %edx,%ecx
  801175:	89 f0                	mov    %esi,%eax
  801177:	d3 e8                	shr    %cl,%eax
  801179:	89 e9                	mov    %ebp,%ecx
  80117b:	89 fa                	mov    %edi,%edx
  80117d:	d3 e6                	shl    %cl,%esi
  80117f:	09 d8                	or     %ebx,%eax
  801181:	f7 74 24 08          	divl   0x8(%esp)
  801185:	89 d1                	mov    %edx,%ecx
  801187:	89 f3                	mov    %esi,%ebx
  801189:	f7 64 24 0c          	mull   0xc(%esp)
  80118d:	89 c6                	mov    %eax,%esi
  80118f:	89 d7                	mov    %edx,%edi
  801191:	39 d1                	cmp    %edx,%ecx
  801193:	72 06                	jb     80119b <__umoddi3+0x10b>
  801195:	75 10                	jne    8011a7 <__umoddi3+0x117>
  801197:	39 c3                	cmp    %eax,%ebx
  801199:	73 0c                	jae    8011a7 <__umoddi3+0x117>
  80119b:	2b 44 24 0c          	sub    0xc(%esp),%eax
  80119f:	1b 54 24 08          	sbb    0x8(%esp),%edx
  8011a3:	89 d7                	mov    %edx,%edi
  8011a5:	89 c6                	mov    %eax,%esi
  8011a7:	89 ca                	mov    %ecx,%edx
  8011a9:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8011ae:	29 f3                	sub    %esi,%ebx
  8011b0:	19 fa                	sbb    %edi,%edx
  8011b2:	89 d0                	mov    %edx,%eax
  8011b4:	d3 e0                	shl    %cl,%eax
  8011b6:	89 e9                	mov    %ebp,%ecx
  8011b8:	d3 eb                	shr    %cl,%ebx
  8011ba:	d3 ea                	shr    %cl,%edx
  8011bc:	09 d8                	or     %ebx,%eax
  8011be:	83 c4 1c             	add    $0x1c,%esp
  8011c1:	5b                   	pop    %ebx
  8011c2:	5e                   	pop    %esi
  8011c3:	5f                   	pop    %edi
  8011c4:	5d                   	pop    %ebp
  8011c5:	c3                   	ret    
  8011c6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8011cd:	8d 76 00             	lea    0x0(%esi),%esi
  8011d0:	29 fe                	sub    %edi,%esi
  8011d2:	19 c3                	sbb    %eax,%ebx
  8011d4:	89 f2                	mov    %esi,%edx
  8011d6:	89 d9                	mov    %ebx,%ecx
  8011d8:	e9 1d ff ff ff       	jmp    8010fa <__umoddi3+0x6a>
