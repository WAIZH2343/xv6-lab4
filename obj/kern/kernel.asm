
obj/kern/kernel:     file format elf32-i386


Disassembly of section .text:

f0100000 <_start+0xeffffff4>:
.globl		_start
_start = RELOC(entry)

.globl entry
entry:
	movw	$0x1234,0x472			# warm boot
f0100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
f0100006:	00 00                	add    %al,(%eax)
f0100008:	fe 4f 52             	decb   0x52(%edi)
f010000b:	e4                   	.byte 0xe4

f010000c <entry>:
f010000c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
f0100013:	34 12 
	# sufficient until we set up our real page table in mem_init
	# in lab 2.

	# Load the physical address of entry_pgdir into cr3.  entry_pgdir
	# is defined in entrypgdir.c.
	movl	$(RELOC(entry_pgdir)), %eax
f0100015:	b8 00 00 12 00       	mov    $0x120000,%eax
	movl	%eax, %cr3
f010001a:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl	%cr0, %eax
f010001d:	0f 20 c0             	mov    %cr0,%eax
	orl	$(CR0_PE|CR0_PG|CR0_WP), %eax
f0100020:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl	%eax, %cr0
f0100025:	0f 22 c0             	mov    %eax,%cr0

	# Now paging is enabled, but we're still running at a low EIP
	# (why is this okay?).  Jump up above KERNBASE before entering
	# C code.
	mov	$relocated, %eax
f0100028:	b8 2f 00 10 f0       	mov    $0xf010002f,%eax
	jmp	*%eax
f010002d:	ff e0                	jmp    *%eax

f010002f <relocated>:
relocated:

	# Clear the frame pointer register (EBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movl	$0x0,%ebp			# nuke frame pointer
f010002f:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Set the stack pointer
	movl	$(bootstacktop),%esp
f0100034:	bc 00 00 12 f0       	mov    $0xf0120000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 62 00 00 00       	call   f01000a0 <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f0100040:	f3 0f 1e fb          	endbr32 
f0100044:	55                   	push   %ebp
f0100045:	89 e5                	mov    %esp,%ebp
f0100047:	56                   	push   %esi
f0100048:	53                   	push   %ebx
f0100049:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f010004c:	83 3d 80 6e 23 f0 00 	cmpl   $0x0,0xf0236e80
f0100053:	74 0f                	je     f0100064 <_panic+0x24>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f0100055:	83 ec 0c             	sub    $0xc,%esp
f0100058:	6a 00                	push   $0x0
f010005a:	e8 85 08 00 00       	call   f01008e4 <monitor>
f010005f:	83 c4 10             	add    $0x10,%esp
f0100062:	eb f1                	jmp    f0100055 <_panic+0x15>
	panicstr = fmt;
f0100064:	89 35 80 6e 23 f0    	mov    %esi,0xf0236e80
	asm volatile("cli; cld");
f010006a:	fa                   	cli    
f010006b:	fc                   	cld    
	va_start(ap, fmt);
f010006c:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic on CPU %d at %s:%d: ", cpunum(), file, line);
f010006f:	e8 8e 5c 00 00       	call   f0105d02 <cpunum>
f0100074:	ff 75 0c             	pushl  0xc(%ebp)
f0100077:	ff 75 08             	pushl  0x8(%ebp)
f010007a:	50                   	push   %eax
f010007b:	68 80 63 10 f0       	push   $0xf0106380
f0100080:	e8 59 38 00 00       	call   f01038de <cprintf>
	vcprintf(fmt, ap);
f0100085:	83 c4 08             	add    $0x8,%esp
f0100088:	53                   	push   %ebx
f0100089:	56                   	push   %esi
f010008a:	e8 25 38 00 00       	call   f01038b4 <vcprintf>
	cprintf("\n");
f010008f:	c7 04 24 db 68 10 f0 	movl   $0xf01068db,(%esp)
f0100096:	e8 43 38 00 00       	call   f01038de <cprintf>
f010009b:	83 c4 10             	add    $0x10,%esp
f010009e:	eb b5                	jmp    f0100055 <_panic+0x15>

f01000a0 <i386_init>:
{
f01000a0:	f3 0f 1e fb          	endbr32 
f01000a4:	55                   	push   %ebp
f01000a5:	89 e5                	mov    %esp,%ebp
f01000a7:	53                   	push   %ebx
f01000a8:	83 ec 04             	sub    $0x4,%esp
	cons_init();
f01000ab:	e8 b3 05 00 00       	call   f0100663 <cons_init>
	cprintf("6828 decimal is %o octal!\n", 6828);
f01000b0:	83 ec 08             	sub    $0x8,%esp
f01000b3:	68 ac 1a 00 00       	push   $0x1aac
f01000b8:	68 ec 63 10 f0       	push   $0xf01063ec
f01000bd:	e8 1c 38 00 00       	call   f01038de <cprintf>
	mem_init();
f01000c2:	e8 01 12 00 00       	call   f01012c8 <mem_init>
	env_init();
f01000c7:	e8 ca 2f 00 00       	call   f0103096 <env_init>
	trap_init();
f01000cc:	e8 f7 38 00 00       	call   f01039c8 <trap_init>
	mp_init();
f01000d1:	e8 2d 59 00 00       	call   f0105a03 <mp_init>
	lapic_init();
f01000d6:	e8 41 5c 00 00       	call   f0105d1c <lapic_init>
	pic_init();
f01000db:	e8 13 37 00 00       	call   f01037f3 <pic_init>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f01000e0:	c7 04 24 c0 23 12 f0 	movl   $0xf01223c0,(%esp)
f01000e7:	e8 9e 5e 00 00       	call   f0105f8a <spin_lock>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01000ec:	83 c4 10             	add    $0x10,%esp
f01000ef:	83 3d 88 6e 23 f0 07 	cmpl   $0x7,0xf0236e88
f01000f6:	76 27                	jbe    f010011f <i386_init+0x7f>
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f01000f8:	83 ec 04             	sub    $0x4,%esp
f01000fb:	b8 66 59 10 f0       	mov    $0xf0105966,%eax
f0100100:	2d ec 58 10 f0       	sub    $0xf01058ec,%eax
f0100105:	50                   	push   %eax
f0100106:	68 ec 58 10 f0       	push   $0xf01058ec
f010010b:	68 00 70 00 f0       	push   $0xf0007000
f0100110:	e8 1b 56 00 00       	call   f0105730 <memmove>
	for (c = cpus; c < cpus + ncpu; c++) {
f0100115:	83 c4 10             	add    $0x10,%esp
f0100118:	bb 20 70 23 f0       	mov    $0xf0237020,%ebx
f010011d:	eb 53                	jmp    f0100172 <i386_init+0xd2>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010011f:	68 00 70 00 00       	push   $0x7000
f0100124:	68 a4 63 10 f0       	push   $0xf01063a4
f0100129:	6a 50                	push   $0x50
f010012b:	68 07 64 10 f0       	push   $0xf0106407
f0100130:	e8 0b ff ff ff       	call   f0100040 <_panic>
		mpentry_kstack = percpu_kstacks[c - cpus] + KSTKSIZE;
f0100135:	89 d8                	mov    %ebx,%eax
f0100137:	2d 20 70 23 f0       	sub    $0xf0237020,%eax
f010013c:	c1 f8 02             	sar    $0x2,%eax
f010013f:	69 c0 35 c2 72 4f    	imul   $0x4f72c235,%eax,%eax
f0100145:	c1 e0 0f             	shl    $0xf,%eax
f0100148:	8d 80 00 00 24 f0    	lea    -0xfdc0000(%eax),%eax
f010014e:	a3 84 6e 23 f0       	mov    %eax,0xf0236e84
		lapic_startap(c->cpu_id, PADDR(code));
f0100153:	83 ec 08             	sub    $0x8,%esp
f0100156:	68 00 70 00 00       	push   $0x7000
f010015b:	0f b6 03             	movzbl (%ebx),%eax
f010015e:	50                   	push   %eax
f010015f:	e8 12 5d 00 00       	call   f0105e76 <lapic_startap>
		while(c->cpu_status != CPU_STARTED)
f0100164:	83 c4 10             	add    $0x10,%esp
f0100167:	8b 43 04             	mov    0x4(%ebx),%eax
f010016a:	83 f8 01             	cmp    $0x1,%eax
f010016d:	75 f8                	jne    f0100167 <i386_init+0xc7>
	for (c = cpus; c < cpus + ncpu; c++) {
f010016f:	83 c3 74             	add    $0x74,%ebx
f0100172:	6b 05 c4 73 23 f0 74 	imul   $0x74,0xf02373c4,%eax
f0100179:	05 20 70 23 f0       	add    $0xf0237020,%eax
f010017e:	39 c3                	cmp    %eax,%ebx
f0100180:	73 13                	jae    f0100195 <i386_init+0xf5>
		if (c == cpus + cpunum())  // We've started already.
f0100182:	e8 7b 5b 00 00       	call   f0105d02 <cpunum>
f0100187:	6b c0 74             	imul   $0x74,%eax,%eax
f010018a:	05 20 70 23 f0       	add    $0xf0237020,%eax
f010018f:	39 c3                	cmp    %eax,%ebx
f0100191:	74 dc                	je     f010016f <i386_init+0xcf>
f0100193:	eb a0                	jmp    f0100135 <i386_init+0x95>
	ENV_CREATE(user_yield, ENV_TYPE_USER);
f0100195:	83 ec 08             	sub    $0x8,%esp
f0100198:	6a 00                	push   $0x0
f010019a:	68 9c a2 19 f0       	push   $0xf019a29c
f010019f:	e8 f5 30 00 00       	call   f0103299 <env_create>
	ENV_CREATE(user_yield, ENV_TYPE_USER);
f01001a4:	83 c4 08             	add    $0x8,%esp
f01001a7:	6a 00                	push   $0x0
f01001a9:	68 9c a2 19 f0       	push   $0xf019a29c
f01001ae:	e8 e6 30 00 00       	call   f0103299 <env_create>
	ENV_CREATE(user_yield, ENV_TYPE_USER);
f01001b3:	83 c4 08             	add    $0x8,%esp
f01001b6:	6a 00                	push   $0x0
f01001b8:	68 9c a2 19 f0       	push   $0xf019a29c
f01001bd:	e8 d7 30 00 00       	call   f0103299 <env_create>
	sched_yield();
f01001c2:	e8 55 43 00 00       	call   f010451c <sched_yield>

f01001c7 <mp_main>:
{
f01001c7:	f3 0f 1e fb          	endbr32 
f01001cb:	55                   	push   %ebp
f01001cc:	89 e5                	mov    %esp,%ebp
f01001ce:	83 ec 08             	sub    $0x8,%esp
	lcr3(PADDR(kern_pgdir));
f01001d1:	a1 8c 6e 23 f0       	mov    0xf0236e8c,%eax
	if ((uint32_t)kva < KERNBASE)
f01001d6:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01001db:	76 52                	jbe    f010022f <mp_main+0x68>
	return (physaddr_t)kva - KERNBASE;
f01001dd:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f01001e2:	0f 22 d8             	mov    %eax,%cr3
	cprintf("SMP: CPU %d starting\n", cpunum());
f01001e5:	e8 18 5b 00 00       	call   f0105d02 <cpunum>
f01001ea:	83 ec 08             	sub    $0x8,%esp
f01001ed:	50                   	push   %eax
f01001ee:	68 13 64 10 f0       	push   $0xf0106413
f01001f3:	e8 e6 36 00 00       	call   f01038de <cprintf>
	lapic_init();
f01001f8:	e8 1f 5b 00 00       	call   f0105d1c <lapic_init>
	env_init_percpu();
f01001fd:	e8 64 2e 00 00       	call   f0103066 <env_init_percpu>
	trap_init_percpu();
f0100202:	e8 ef 36 00 00       	call   f01038f6 <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f0100207:	e8 f6 5a 00 00       	call   f0105d02 <cpunum>
f010020c:	6b d0 74             	imul   $0x74,%eax,%edx
f010020f:	83 c2 04             	add    $0x4,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f0100212:	b8 01 00 00 00       	mov    $0x1,%eax
f0100217:	f0 87 82 20 70 23 f0 	lock xchg %eax,-0xfdc8fe0(%edx)
f010021e:	c7 04 24 c0 23 12 f0 	movl   $0xf01223c0,(%esp)
f0100225:	e8 60 5d 00 00       	call   f0105f8a <spin_lock>
	sched_yield();
f010022a:	e8 ed 42 00 00       	call   f010451c <sched_yield>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010022f:	50                   	push   %eax
f0100230:	68 c8 63 10 f0       	push   $0xf01063c8
f0100235:	6a 67                	push   $0x67
f0100237:	68 07 64 10 f0       	push   $0xf0106407
f010023c:	e8 ff fd ff ff       	call   f0100040 <_panic>

f0100241 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f0100241:	f3 0f 1e fb          	endbr32 
f0100245:	55                   	push   %ebp
f0100246:	89 e5                	mov    %esp,%ebp
f0100248:	53                   	push   %ebx
f0100249:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f010024c:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f010024f:	ff 75 0c             	pushl  0xc(%ebp)
f0100252:	ff 75 08             	pushl  0x8(%ebp)
f0100255:	68 29 64 10 f0       	push   $0xf0106429
f010025a:	e8 7f 36 00 00       	call   f01038de <cprintf>
	vcprintf(fmt, ap);
f010025f:	83 c4 08             	add    $0x8,%esp
f0100262:	53                   	push   %ebx
f0100263:	ff 75 10             	pushl  0x10(%ebp)
f0100266:	e8 49 36 00 00       	call   f01038b4 <vcprintf>
	cprintf("\n");
f010026b:	c7 04 24 db 68 10 f0 	movl   $0xf01068db,(%esp)
f0100272:	e8 67 36 00 00       	call   f01038de <cprintf>
	va_end(ap);
}
f0100277:	83 c4 10             	add    $0x10,%esp
f010027a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010027d:	c9                   	leave  
f010027e:	c3                   	ret    

f010027f <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f010027f:	f3 0f 1e fb          	endbr32 
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100283:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100288:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f0100289:	a8 01                	test   $0x1,%al
f010028b:	74 0a                	je     f0100297 <serial_proc_data+0x18>
f010028d:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100292:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f0100293:	0f b6 c0             	movzbl %al,%eax
f0100296:	c3                   	ret    
		return -1;
f0100297:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
f010029c:	c3                   	ret    

f010029d <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f010029d:	55                   	push   %ebp
f010029e:	89 e5                	mov    %esp,%ebp
f01002a0:	53                   	push   %ebx
f01002a1:	83 ec 04             	sub    $0x4,%esp
f01002a4:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f01002a6:	ff d3                	call   *%ebx
f01002a8:	83 f8 ff             	cmp    $0xffffffff,%eax
f01002ab:	74 29                	je     f01002d6 <cons_intr+0x39>
		if (c == 0)
f01002ad:	85 c0                	test   %eax,%eax
f01002af:	74 f5                	je     f01002a6 <cons_intr+0x9>
			continue;
		cons.buf[cons.wpos++] = c;
f01002b1:	8b 0d 24 62 23 f0    	mov    0xf0236224,%ecx
f01002b7:	8d 51 01             	lea    0x1(%ecx),%edx
f01002ba:	88 81 20 60 23 f0    	mov    %al,-0xfdc9fe0(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f01002c0:	81 fa 00 02 00 00    	cmp    $0x200,%edx
			cons.wpos = 0;
f01002c6:	b8 00 00 00 00       	mov    $0x0,%eax
f01002cb:	0f 44 d0             	cmove  %eax,%edx
f01002ce:	89 15 24 62 23 f0    	mov    %edx,0xf0236224
f01002d4:	eb d0                	jmp    f01002a6 <cons_intr+0x9>
	}
}
f01002d6:	83 c4 04             	add    $0x4,%esp
f01002d9:	5b                   	pop    %ebx
f01002da:	5d                   	pop    %ebp
f01002db:	c3                   	ret    

f01002dc <kbd_proc_data>:
{
f01002dc:	f3 0f 1e fb          	endbr32 
f01002e0:	55                   	push   %ebp
f01002e1:	89 e5                	mov    %esp,%ebp
f01002e3:	53                   	push   %ebx
f01002e4:	83 ec 04             	sub    $0x4,%esp
f01002e7:	ba 64 00 00 00       	mov    $0x64,%edx
f01002ec:	ec                   	in     (%dx),%al
	if ((stat & KBS_DIB) == 0)
f01002ed:	a8 01                	test   $0x1,%al
f01002ef:	0f 84 f2 00 00 00    	je     f01003e7 <kbd_proc_data+0x10b>
	if (stat & KBS_TERR)
f01002f5:	a8 20                	test   $0x20,%al
f01002f7:	0f 85 f1 00 00 00    	jne    f01003ee <kbd_proc_data+0x112>
f01002fd:	ba 60 00 00 00       	mov    $0x60,%edx
f0100302:	ec                   	in     (%dx),%al
f0100303:	89 c2                	mov    %eax,%edx
	if (data == 0xE0) {
f0100305:	3c e0                	cmp    $0xe0,%al
f0100307:	74 61                	je     f010036a <kbd_proc_data+0x8e>
	} else if (data & 0x80) {
f0100309:	84 c0                	test   %al,%al
f010030b:	78 70                	js     f010037d <kbd_proc_data+0xa1>
	} else if (shift & E0ESC) {
f010030d:	8b 0d 00 60 23 f0    	mov    0xf0236000,%ecx
f0100313:	f6 c1 40             	test   $0x40,%cl
f0100316:	74 0e                	je     f0100326 <kbd_proc_data+0x4a>
		data |= 0x80;
f0100318:	83 c8 80             	or     $0xffffff80,%eax
f010031b:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f010031d:	83 e1 bf             	and    $0xffffffbf,%ecx
f0100320:	89 0d 00 60 23 f0    	mov    %ecx,0xf0236000
	shift |= shiftcode[data];
f0100326:	0f b6 d2             	movzbl %dl,%edx
f0100329:	0f b6 82 a0 65 10 f0 	movzbl -0xfef9a60(%edx),%eax
f0100330:	0b 05 00 60 23 f0    	or     0xf0236000,%eax
	shift ^= togglecode[data];
f0100336:	0f b6 8a a0 64 10 f0 	movzbl -0xfef9b60(%edx),%ecx
f010033d:	31 c8                	xor    %ecx,%eax
f010033f:	a3 00 60 23 f0       	mov    %eax,0xf0236000
	c = charcode[shift & (CTL | SHIFT)][data];
f0100344:	89 c1                	mov    %eax,%ecx
f0100346:	83 e1 03             	and    $0x3,%ecx
f0100349:	8b 0c 8d 80 64 10 f0 	mov    -0xfef9b80(,%ecx,4),%ecx
f0100350:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f0100354:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f0100357:	a8 08                	test   $0x8,%al
f0100359:	74 61                	je     f01003bc <kbd_proc_data+0xe0>
		if ('a' <= c && c <= 'z')
f010035b:	89 da                	mov    %ebx,%edx
f010035d:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f0100360:	83 f9 19             	cmp    $0x19,%ecx
f0100363:	77 4b                	ja     f01003b0 <kbd_proc_data+0xd4>
			c += 'A' - 'a';
f0100365:	83 eb 20             	sub    $0x20,%ebx
f0100368:	eb 0c                	jmp    f0100376 <kbd_proc_data+0x9a>
		shift |= E0ESC;
f010036a:	83 0d 00 60 23 f0 40 	orl    $0x40,0xf0236000
		return 0;
f0100371:	bb 00 00 00 00       	mov    $0x0,%ebx
}
f0100376:	89 d8                	mov    %ebx,%eax
f0100378:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010037b:	c9                   	leave  
f010037c:	c3                   	ret    
		data = (shift & E0ESC ? data : data & 0x7F);
f010037d:	8b 0d 00 60 23 f0    	mov    0xf0236000,%ecx
f0100383:	89 cb                	mov    %ecx,%ebx
f0100385:	83 e3 40             	and    $0x40,%ebx
f0100388:	83 e0 7f             	and    $0x7f,%eax
f010038b:	85 db                	test   %ebx,%ebx
f010038d:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f0100390:	0f b6 d2             	movzbl %dl,%edx
f0100393:	0f b6 82 a0 65 10 f0 	movzbl -0xfef9a60(%edx),%eax
f010039a:	83 c8 40             	or     $0x40,%eax
f010039d:	0f b6 c0             	movzbl %al,%eax
f01003a0:	f7 d0                	not    %eax
f01003a2:	21 c8                	and    %ecx,%eax
f01003a4:	a3 00 60 23 f0       	mov    %eax,0xf0236000
		return 0;
f01003a9:	bb 00 00 00 00       	mov    $0x0,%ebx
f01003ae:	eb c6                	jmp    f0100376 <kbd_proc_data+0x9a>
		else if ('A' <= c && c <= 'Z')
f01003b0:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f01003b3:	8d 4b 20             	lea    0x20(%ebx),%ecx
f01003b6:	83 fa 1a             	cmp    $0x1a,%edx
f01003b9:	0f 42 d9             	cmovb  %ecx,%ebx
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f01003bc:	f7 d0                	not    %eax
f01003be:	a8 06                	test   $0x6,%al
f01003c0:	75 b4                	jne    f0100376 <kbd_proc_data+0x9a>
f01003c2:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f01003c8:	75 ac                	jne    f0100376 <kbd_proc_data+0x9a>
		cprintf("Rebooting!\n");
f01003ca:	83 ec 0c             	sub    $0xc,%esp
f01003cd:	68 43 64 10 f0       	push   $0xf0106443
f01003d2:	e8 07 35 00 00       	call   f01038de <cprintf>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01003d7:	b8 03 00 00 00       	mov    $0x3,%eax
f01003dc:	ba 92 00 00 00       	mov    $0x92,%edx
f01003e1:	ee                   	out    %al,(%dx)
}
f01003e2:	83 c4 10             	add    $0x10,%esp
f01003e5:	eb 8f                	jmp    f0100376 <kbd_proc_data+0x9a>
		return -1;
f01003e7:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
f01003ec:	eb 88                	jmp    f0100376 <kbd_proc_data+0x9a>
		return -1;
f01003ee:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
f01003f3:	eb 81                	jmp    f0100376 <kbd_proc_data+0x9a>

f01003f5 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f01003f5:	55                   	push   %ebp
f01003f6:	89 e5                	mov    %esp,%ebp
f01003f8:	57                   	push   %edi
f01003f9:	56                   	push   %esi
f01003fa:	53                   	push   %ebx
f01003fb:	83 ec 1c             	sub    $0x1c,%esp
f01003fe:	89 c1                	mov    %eax,%ecx
	for (i = 0;
f0100400:	be 00 00 00 00       	mov    $0x0,%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100405:	bf fd 03 00 00       	mov    $0x3fd,%edi
f010040a:	bb 84 00 00 00       	mov    $0x84,%ebx
f010040f:	89 fa                	mov    %edi,%edx
f0100411:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f0100412:	a8 20                	test   $0x20,%al
f0100414:	75 13                	jne    f0100429 <cons_putc+0x34>
f0100416:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
f010041c:	7f 0b                	jg     f0100429 <cons_putc+0x34>
f010041e:	89 da                	mov    %ebx,%edx
f0100420:	ec                   	in     (%dx),%al
f0100421:	ec                   	in     (%dx),%al
f0100422:	ec                   	in     (%dx),%al
f0100423:	ec                   	in     (%dx),%al
	     i++)
f0100424:	83 c6 01             	add    $0x1,%esi
f0100427:	eb e6                	jmp    f010040f <cons_putc+0x1a>
	outb(COM1 + COM_TX, c);
f0100429:	88 4d e7             	mov    %cl,-0x19(%ebp)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010042c:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100431:	89 c8                	mov    %ecx,%eax
f0100433:	ee                   	out    %al,(%dx)
	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f0100434:	be 00 00 00 00       	mov    $0x0,%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100439:	bf 79 03 00 00       	mov    $0x379,%edi
f010043e:	bb 84 00 00 00       	mov    $0x84,%ebx
f0100443:	89 fa                	mov    %edi,%edx
f0100445:	ec                   	in     (%dx),%al
f0100446:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
f010044c:	7f 0f                	jg     f010045d <cons_putc+0x68>
f010044e:	84 c0                	test   %al,%al
f0100450:	78 0b                	js     f010045d <cons_putc+0x68>
f0100452:	89 da                	mov    %ebx,%edx
f0100454:	ec                   	in     (%dx),%al
f0100455:	ec                   	in     (%dx),%al
f0100456:	ec                   	in     (%dx),%al
f0100457:	ec                   	in     (%dx),%al
f0100458:	83 c6 01             	add    $0x1,%esi
f010045b:	eb e6                	jmp    f0100443 <cons_putc+0x4e>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010045d:	ba 78 03 00 00       	mov    $0x378,%edx
f0100462:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f0100466:	ee                   	out    %al,(%dx)
f0100467:	ba 7a 03 00 00       	mov    $0x37a,%edx
f010046c:	b8 0d 00 00 00       	mov    $0xd,%eax
f0100471:	ee                   	out    %al,(%dx)
f0100472:	b8 08 00 00 00       	mov    $0x8,%eax
f0100477:	ee                   	out    %al,(%dx)
		c |= 0x0700;
f0100478:	89 c8                	mov    %ecx,%eax
f010047a:	80 cc 07             	or     $0x7,%ah
f010047d:	f7 c1 00 ff ff ff    	test   $0xffffff00,%ecx
f0100483:	0f 44 c8             	cmove  %eax,%ecx
	switch (c & 0xff) {
f0100486:	0f b6 c1             	movzbl %cl,%eax
f0100489:	80 f9 0a             	cmp    $0xa,%cl
f010048c:	0f 84 dd 00 00 00    	je     f010056f <cons_putc+0x17a>
f0100492:	83 f8 0a             	cmp    $0xa,%eax
f0100495:	7f 46                	jg     f01004dd <cons_putc+0xe8>
f0100497:	83 f8 08             	cmp    $0x8,%eax
f010049a:	0f 84 a7 00 00 00    	je     f0100547 <cons_putc+0x152>
f01004a0:	83 f8 09             	cmp    $0x9,%eax
f01004a3:	0f 85 d3 00 00 00    	jne    f010057c <cons_putc+0x187>
		cons_putc(' ');
f01004a9:	b8 20 00 00 00       	mov    $0x20,%eax
f01004ae:	e8 42 ff ff ff       	call   f01003f5 <cons_putc>
		cons_putc(' ');
f01004b3:	b8 20 00 00 00       	mov    $0x20,%eax
f01004b8:	e8 38 ff ff ff       	call   f01003f5 <cons_putc>
		cons_putc(' ');
f01004bd:	b8 20 00 00 00       	mov    $0x20,%eax
f01004c2:	e8 2e ff ff ff       	call   f01003f5 <cons_putc>
		cons_putc(' ');
f01004c7:	b8 20 00 00 00       	mov    $0x20,%eax
f01004cc:	e8 24 ff ff ff       	call   f01003f5 <cons_putc>
		cons_putc(' ');
f01004d1:	b8 20 00 00 00       	mov    $0x20,%eax
f01004d6:	e8 1a ff ff ff       	call   f01003f5 <cons_putc>
		break;
f01004db:	eb 25                	jmp    f0100502 <cons_putc+0x10d>
	switch (c & 0xff) {
f01004dd:	83 f8 0d             	cmp    $0xd,%eax
f01004e0:	0f 85 96 00 00 00    	jne    f010057c <cons_putc+0x187>
		crt_pos -= (crt_pos % CRT_COLS);
f01004e6:	0f b7 05 28 62 23 f0 	movzwl 0xf0236228,%eax
f01004ed:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f01004f3:	c1 e8 16             	shr    $0x16,%eax
f01004f6:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01004f9:	c1 e0 04             	shl    $0x4,%eax
f01004fc:	66 a3 28 62 23 f0    	mov    %ax,0xf0236228
	if (crt_pos >= CRT_SIZE) {
f0100502:	66 81 3d 28 62 23 f0 	cmpw   $0x7cf,0xf0236228
f0100509:	cf 07 
f010050b:	0f 87 8e 00 00 00    	ja     f010059f <cons_putc+0x1aa>
	outb(addr_6845, 14);
f0100511:	8b 0d 30 62 23 f0    	mov    0xf0236230,%ecx
f0100517:	b8 0e 00 00 00       	mov    $0xe,%eax
f010051c:	89 ca                	mov    %ecx,%edx
f010051e:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f010051f:	0f b7 1d 28 62 23 f0 	movzwl 0xf0236228,%ebx
f0100526:	8d 71 01             	lea    0x1(%ecx),%esi
f0100529:	89 d8                	mov    %ebx,%eax
f010052b:	66 c1 e8 08          	shr    $0x8,%ax
f010052f:	89 f2                	mov    %esi,%edx
f0100531:	ee                   	out    %al,(%dx)
f0100532:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100537:	89 ca                	mov    %ecx,%edx
f0100539:	ee                   	out    %al,(%dx)
f010053a:	89 d8                	mov    %ebx,%eax
f010053c:	89 f2                	mov    %esi,%edx
f010053e:	ee                   	out    %al,(%dx)
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f010053f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100542:	5b                   	pop    %ebx
f0100543:	5e                   	pop    %esi
f0100544:	5f                   	pop    %edi
f0100545:	5d                   	pop    %ebp
f0100546:	c3                   	ret    
		if (crt_pos > 0) {
f0100547:	0f b7 05 28 62 23 f0 	movzwl 0xf0236228,%eax
f010054e:	66 85 c0             	test   %ax,%ax
f0100551:	74 be                	je     f0100511 <cons_putc+0x11c>
			crt_pos--;
f0100553:	83 e8 01             	sub    $0x1,%eax
f0100556:	66 a3 28 62 23 f0    	mov    %ax,0xf0236228
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f010055c:	0f b7 d0             	movzwl %ax,%edx
f010055f:	b1 00                	mov    $0x0,%cl
f0100561:	83 c9 20             	or     $0x20,%ecx
f0100564:	a1 2c 62 23 f0       	mov    0xf023622c,%eax
f0100569:	66 89 0c 50          	mov    %cx,(%eax,%edx,2)
f010056d:	eb 93                	jmp    f0100502 <cons_putc+0x10d>
		crt_pos += CRT_COLS;
f010056f:	66 83 05 28 62 23 f0 	addw   $0x50,0xf0236228
f0100576:	50 
f0100577:	e9 6a ff ff ff       	jmp    f01004e6 <cons_putc+0xf1>
		crt_buf[crt_pos++] = c;		/* write the character */
f010057c:	0f b7 05 28 62 23 f0 	movzwl 0xf0236228,%eax
f0100583:	8d 50 01             	lea    0x1(%eax),%edx
f0100586:	66 89 15 28 62 23 f0 	mov    %dx,0xf0236228
f010058d:	0f b7 c0             	movzwl %ax,%eax
f0100590:	8b 15 2c 62 23 f0    	mov    0xf023622c,%edx
f0100596:	66 89 0c 42          	mov    %cx,(%edx,%eax,2)
		break;
f010059a:	e9 63 ff ff ff       	jmp    f0100502 <cons_putc+0x10d>
		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f010059f:	a1 2c 62 23 f0       	mov    0xf023622c,%eax
f01005a4:	83 ec 04             	sub    $0x4,%esp
f01005a7:	68 00 0f 00 00       	push   $0xf00
f01005ac:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f01005b2:	52                   	push   %edx
f01005b3:	50                   	push   %eax
f01005b4:	e8 77 51 00 00       	call   f0105730 <memmove>
			crt_buf[i] = 0x0700 | ' ';
f01005b9:	8b 15 2c 62 23 f0    	mov    0xf023622c,%edx
f01005bf:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f01005c5:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f01005cb:	83 c4 10             	add    $0x10,%esp
f01005ce:	66 c7 00 20 07       	movw   $0x720,(%eax)
f01005d3:	83 c0 02             	add    $0x2,%eax
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01005d6:	39 d0                	cmp    %edx,%eax
f01005d8:	75 f4                	jne    f01005ce <cons_putc+0x1d9>
		crt_pos -= CRT_COLS;
f01005da:	66 83 2d 28 62 23 f0 	subw   $0x50,0xf0236228
f01005e1:	50 
f01005e2:	e9 2a ff ff ff       	jmp    f0100511 <cons_putc+0x11c>

f01005e7 <serial_intr>:
{
f01005e7:	f3 0f 1e fb          	endbr32 
	if (serial_exists)
f01005eb:	80 3d 34 62 23 f0 00 	cmpb   $0x0,0xf0236234
f01005f2:	75 01                	jne    f01005f5 <serial_intr+0xe>
f01005f4:	c3                   	ret    
{
f01005f5:	55                   	push   %ebp
f01005f6:	89 e5                	mov    %esp,%ebp
f01005f8:	83 ec 08             	sub    $0x8,%esp
		cons_intr(serial_proc_data);
f01005fb:	b8 7f 02 10 f0       	mov    $0xf010027f,%eax
f0100600:	e8 98 fc ff ff       	call   f010029d <cons_intr>
}
f0100605:	c9                   	leave  
f0100606:	c3                   	ret    

f0100607 <kbd_intr>:
{
f0100607:	f3 0f 1e fb          	endbr32 
f010060b:	55                   	push   %ebp
f010060c:	89 e5                	mov    %esp,%ebp
f010060e:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f0100611:	b8 dc 02 10 f0       	mov    $0xf01002dc,%eax
f0100616:	e8 82 fc ff ff       	call   f010029d <cons_intr>
}
f010061b:	c9                   	leave  
f010061c:	c3                   	ret    

f010061d <cons_getc>:
{
f010061d:	f3 0f 1e fb          	endbr32 
f0100621:	55                   	push   %ebp
f0100622:	89 e5                	mov    %esp,%ebp
f0100624:	83 ec 08             	sub    $0x8,%esp
	serial_intr();
f0100627:	e8 bb ff ff ff       	call   f01005e7 <serial_intr>
	kbd_intr();
f010062c:	e8 d6 ff ff ff       	call   f0100607 <kbd_intr>
	if (cons.rpos != cons.wpos) {
f0100631:	a1 20 62 23 f0       	mov    0xf0236220,%eax
	return 0;
f0100636:	ba 00 00 00 00       	mov    $0x0,%edx
	if (cons.rpos != cons.wpos) {
f010063b:	3b 05 24 62 23 f0    	cmp    0xf0236224,%eax
f0100641:	74 1c                	je     f010065f <cons_getc+0x42>
		c = cons.buf[cons.rpos++];
f0100643:	8d 48 01             	lea    0x1(%eax),%ecx
f0100646:	0f b6 90 20 60 23 f0 	movzbl -0xfdc9fe0(%eax),%edx
			cons.rpos = 0;
f010064d:	3d ff 01 00 00       	cmp    $0x1ff,%eax
f0100652:	b8 00 00 00 00       	mov    $0x0,%eax
f0100657:	0f 45 c1             	cmovne %ecx,%eax
f010065a:	a3 20 62 23 f0       	mov    %eax,0xf0236220
}
f010065f:	89 d0                	mov    %edx,%eax
f0100661:	c9                   	leave  
f0100662:	c3                   	ret    

f0100663 <cons_init>:

// initialize the console devices
void
cons_init(void)
{
f0100663:	f3 0f 1e fb          	endbr32 
f0100667:	55                   	push   %ebp
f0100668:	89 e5                	mov    %esp,%ebp
f010066a:	57                   	push   %edi
f010066b:	56                   	push   %esi
f010066c:	53                   	push   %ebx
f010066d:	83 ec 0c             	sub    $0xc,%esp
	was = *cp;
f0100670:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f0100677:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f010067e:	5a a5 
	if (*cp != 0xA55A) {
f0100680:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f0100687:	66 3d 5a a5          	cmp    $0xa55a,%ax
f010068b:	0f 84 d4 00 00 00    	je     f0100765 <cons_init+0x102>
		addr_6845 = MONO_BASE;
f0100691:	c7 05 30 62 23 f0 b4 	movl   $0x3b4,0xf0236230
f0100698:	03 00 00 
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f010069b:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
	outb(addr_6845, 14);
f01006a0:	8b 3d 30 62 23 f0    	mov    0xf0236230,%edi
f01006a6:	b8 0e 00 00 00       	mov    $0xe,%eax
f01006ab:	89 fa                	mov    %edi,%edx
f01006ad:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f01006ae:	8d 4f 01             	lea    0x1(%edi),%ecx
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006b1:	89 ca                	mov    %ecx,%edx
f01006b3:	ec                   	in     (%dx),%al
f01006b4:	0f b6 c0             	movzbl %al,%eax
f01006b7:	c1 e0 08             	shl    $0x8,%eax
f01006ba:	89 c3                	mov    %eax,%ebx
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01006bc:	b8 0f 00 00 00       	mov    $0xf,%eax
f01006c1:	89 fa                	mov    %edi,%edx
f01006c3:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006c4:	89 ca                	mov    %ecx,%edx
f01006c6:	ec                   	in     (%dx),%al
	crt_buf = (uint16_t*) cp;
f01006c7:	89 35 2c 62 23 f0    	mov    %esi,0xf023622c
	pos |= inb(addr_6845 + 1);
f01006cd:	0f b6 c0             	movzbl %al,%eax
f01006d0:	09 d8                	or     %ebx,%eax
	crt_pos = pos;
f01006d2:	66 a3 28 62 23 f0    	mov    %ax,0xf0236228
	kbd_intr();
f01006d8:	e8 2a ff ff ff       	call   f0100607 <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<IRQ_KBD));
f01006dd:	83 ec 0c             	sub    $0xc,%esp
f01006e0:	0f b7 05 a8 23 12 f0 	movzwl 0xf01223a8,%eax
f01006e7:	25 fd ff 00 00       	and    $0xfffd,%eax
f01006ec:	50                   	push   %eax
f01006ed:	e8 7f 30 00 00       	call   f0103771 <irq_setmask_8259A>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01006f2:	bb 00 00 00 00       	mov    $0x0,%ebx
f01006f7:	b9 fa 03 00 00       	mov    $0x3fa,%ecx
f01006fc:	89 d8                	mov    %ebx,%eax
f01006fe:	89 ca                	mov    %ecx,%edx
f0100700:	ee                   	out    %al,(%dx)
f0100701:	bf fb 03 00 00       	mov    $0x3fb,%edi
f0100706:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f010070b:	89 fa                	mov    %edi,%edx
f010070d:	ee                   	out    %al,(%dx)
f010070e:	b8 0c 00 00 00       	mov    $0xc,%eax
f0100713:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100718:	ee                   	out    %al,(%dx)
f0100719:	be f9 03 00 00       	mov    $0x3f9,%esi
f010071e:	89 d8                	mov    %ebx,%eax
f0100720:	89 f2                	mov    %esi,%edx
f0100722:	ee                   	out    %al,(%dx)
f0100723:	b8 03 00 00 00       	mov    $0x3,%eax
f0100728:	89 fa                	mov    %edi,%edx
f010072a:	ee                   	out    %al,(%dx)
f010072b:	ba fc 03 00 00       	mov    $0x3fc,%edx
f0100730:	89 d8                	mov    %ebx,%eax
f0100732:	ee                   	out    %al,(%dx)
f0100733:	b8 01 00 00 00       	mov    $0x1,%eax
f0100738:	89 f2                	mov    %esi,%edx
f010073a:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010073b:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100740:	ec                   	in     (%dx),%al
f0100741:	89 c3                	mov    %eax,%ebx
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f0100743:	83 c4 10             	add    $0x10,%esp
f0100746:	3c ff                	cmp    $0xff,%al
f0100748:	0f 95 05 34 62 23 f0 	setne  0xf0236234
f010074f:	89 ca                	mov    %ecx,%edx
f0100751:	ec                   	in     (%dx),%al
f0100752:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100757:	ec                   	in     (%dx),%al
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f0100758:	80 fb ff             	cmp    $0xff,%bl
f010075b:	74 23                	je     f0100780 <cons_init+0x11d>
		cprintf("Serial port does not exist!\n");
}
f010075d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100760:	5b                   	pop    %ebx
f0100761:	5e                   	pop    %esi
f0100762:	5f                   	pop    %edi
f0100763:	5d                   	pop    %ebp
f0100764:	c3                   	ret    
		*cp = was;
f0100765:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f010076c:	c7 05 30 62 23 f0 d4 	movl   $0x3d4,0xf0236230
f0100773:	03 00 00 
	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f0100776:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
f010077b:	e9 20 ff ff ff       	jmp    f01006a0 <cons_init+0x3d>
		cprintf("Serial port does not exist!\n");
f0100780:	83 ec 0c             	sub    $0xc,%esp
f0100783:	68 4f 64 10 f0       	push   $0xf010644f
f0100788:	e8 51 31 00 00       	call   f01038de <cprintf>
f010078d:	83 c4 10             	add    $0x10,%esp
}
f0100790:	eb cb                	jmp    f010075d <cons_init+0xfa>

f0100792 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f0100792:	f3 0f 1e fb          	endbr32 
f0100796:	55                   	push   %ebp
f0100797:	89 e5                	mov    %esp,%ebp
f0100799:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f010079c:	8b 45 08             	mov    0x8(%ebp),%eax
f010079f:	e8 51 fc ff ff       	call   f01003f5 <cons_putc>
}
f01007a4:	c9                   	leave  
f01007a5:	c3                   	ret    

f01007a6 <getchar>:

int
getchar(void)
{
f01007a6:	f3 0f 1e fb          	endbr32 
f01007aa:	55                   	push   %ebp
f01007ab:	89 e5                	mov    %esp,%ebp
f01007ad:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f01007b0:	e8 68 fe ff ff       	call   f010061d <cons_getc>
f01007b5:	85 c0                	test   %eax,%eax
f01007b7:	74 f7                	je     f01007b0 <getchar+0xa>
		/* do nothing */;
	return c;
}
f01007b9:	c9                   	leave  
f01007ba:	c3                   	ret    

f01007bb <iscons>:

int
iscons(int fdnum)
{
f01007bb:	f3 0f 1e fb          	endbr32 
	// used by readline
	return 1;
}
f01007bf:	b8 01 00 00 00       	mov    $0x1,%eax
f01007c4:	c3                   	ret    

f01007c5 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f01007c5:	f3 0f 1e fb          	endbr32 
f01007c9:	55                   	push   %ebp
f01007ca:	89 e5                	mov    %esp,%ebp
f01007cc:	83 ec 0c             	sub    $0xc,%esp
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f01007cf:	68 a0 66 10 f0       	push   $0xf01066a0
f01007d4:	68 be 66 10 f0       	push   $0xf01066be
f01007d9:	68 c3 66 10 f0       	push   $0xf01066c3
f01007de:	e8 fb 30 00 00       	call   f01038de <cprintf>
f01007e3:	83 c4 0c             	add    $0xc,%esp
f01007e6:	68 2c 67 10 f0       	push   $0xf010672c
f01007eb:	68 cc 66 10 f0       	push   $0xf01066cc
f01007f0:	68 c3 66 10 f0       	push   $0xf01066c3
f01007f5:	e8 e4 30 00 00       	call   f01038de <cprintf>
	return 0;
}
f01007fa:	b8 00 00 00 00       	mov    $0x0,%eax
f01007ff:	c9                   	leave  
f0100800:	c3                   	ret    

f0100801 <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f0100801:	f3 0f 1e fb          	endbr32 
f0100805:	55                   	push   %ebp
f0100806:	89 e5                	mov    %esp,%ebp
f0100808:	83 ec 14             	sub    $0x14,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f010080b:	68 d5 66 10 f0       	push   $0xf01066d5
f0100810:	e8 c9 30 00 00       	call   f01038de <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100815:	83 c4 08             	add    $0x8,%esp
f0100818:	68 0c 00 10 00       	push   $0x10000c
f010081d:	68 54 67 10 f0       	push   $0xf0106754
f0100822:	e8 b7 30 00 00       	call   f01038de <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f0100827:	83 c4 0c             	add    $0xc,%esp
f010082a:	68 0c 00 10 00       	push   $0x10000c
f010082f:	68 0c 00 10 f0       	push   $0xf010000c
f0100834:	68 7c 67 10 f0       	push   $0xf010677c
f0100839:	e8 a0 30 00 00       	call   f01038de <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f010083e:	83 c4 0c             	add    $0xc,%esp
f0100841:	68 7d 63 10 00       	push   $0x10637d
f0100846:	68 7d 63 10 f0       	push   $0xf010637d
f010084b:	68 a0 67 10 f0       	push   $0xf01067a0
f0100850:	e8 89 30 00 00       	call   f01038de <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100855:	83 c4 0c             	add    $0xc,%esp
f0100858:	68 00 60 23 00       	push   $0x236000
f010085d:	68 00 60 23 f0       	push   $0xf0236000
f0100862:	68 c4 67 10 f0       	push   $0xf01067c4
f0100867:	e8 72 30 00 00       	call   f01038de <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f010086c:	83 c4 0c             	add    $0xc,%esp
f010086f:	68 08 80 27 00       	push   $0x278008
f0100874:	68 08 80 27 f0       	push   $0xf0278008
f0100879:	68 e8 67 10 f0       	push   $0xf01067e8
f010087e:	e8 5b 30 00 00       	call   f01038de <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100883:	83 c4 08             	add    $0x8,%esp
		ROUNDUP(end - entry, 1024) / 1024);
f0100886:	b8 08 80 27 f0       	mov    $0xf0278008,%eax
f010088b:	2d 0d fc 0f f0       	sub    $0xf00ffc0d,%eax
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100890:	c1 f8 0a             	sar    $0xa,%eax
f0100893:	50                   	push   %eax
f0100894:	68 0c 68 10 f0       	push   $0xf010680c
f0100899:	e8 40 30 00 00       	call   f01038de <cprintf>
	return 0;
}
f010089e:	b8 00 00 00 00       	mov    $0x0,%eax
f01008a3:	c9                   	leave  
f01008a4:	c3                   	ret    

f01008a5 <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f01008a5:	f3 0f 1e fb          	endbr32 
f01008a9:	55                   	push   %ebp
f01008aa:	89 e5                	mov    %esp,%ebp
f01008ac:	53                   	push   %ebx
f01008ad:	83 ec 04             	sub    $0x4,%esp
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f01008b0:	89 eb                	mov    %ebp,%ebx
	// Your code here.
	uint32_t ebp, *p;
	ebp=read_ebp();
	while(ebp != 0)
f01008b2:	85 db                	test   %ebx,%ebx
f01008b4:	74 24                	je     f01008da <mon_backtrace+0x35>
	{
		p = (uint32_t *) ebp;
		cprintf("ebp %x eip %x args %08x %08x %08x %08x %08x\n", ebp, p[1], p[2], p[3], p[4], p[5], p[6]);
f01008b6:	ff 73 18             	pushl  0x18(%ebx)
f01008b9:	ff 73 14             	pushl  0x14(%ebx)
f01008bc:	ff 73 10             	pushl  0x10(%ebx)
f01008bf:	ff 73 0c             	pushl  0xc(%ebx)
f01008c2:	ff 73 08             	pushl  0x8(%ebx)
f01008c5:	ff 73 04             	pushl  0x4(%ebx)
f01008c8:	53                   	push   %ebx
f01008c9:	68 38 68 10 f0       	push   $0xf0106838
f01008ce:	e8 0b 30 00 00       	call   f01038de <cprintf>
		ebp = p[0];//ebp get val - the last addr
f01008d3:	8b 1b                	mov    (%ebx),%ebx
f01008d5:	83 c4 20             	add    $0x20,%esp
f01008d8:	eb d8                	jmp    f01008b2 <mon_backtrace+0xd>
	}
	return 0;
}
f01008da:	b8 00 00 00 00       	mov    $0x0,%eax
f01008df:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01008e2:	c9                   	leave  
f01008e3:	c3                   	ret    

f01008e4 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f01008e4:	f3 0f 1e fb          	endbr32 
f01008e8:	55                   	push   %ebp
f01008e9:	89 e5                	mov    %esp,%ebp
f01008eb:	57                   	push   %edi
f01008ec:	56                   	push   %esi
f01008ed:	53                   	push   %ebx
f01008ee:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f01008f1:	68 68 68 10 f0       	push   $0xf0106868
f01008f6:	e8 e3 2f 00 00       	call   f01038de <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f01008fb:	c7 04 24 8c 68 10 f0 	movl   $0xf010688c,(%esp)
f0100902:	e8 d7 2f 00 00       	call   f01038de <cprintf>
	
	if(tf != NULL) print_trapframe(tf);
f0100907:	83 c4 10             	add    $0x10,%esp
f010090a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f010090e:	0f 84 e2 00 00 00    	je     f01009f6 <monitor+0x112>
f0100914:	83 ec 0c             	sub    $0xc,%esp
f0100917:	ff 75 08             	pushl  0x8(%ebp)
f010091a:	e8 7f 35 00 00       	call   f0103e9e <print_trapframe>
f010091f:	83 c4 10             	add    $0x10,%esp
f0100922:	e9 cf 00 00 00       	jmp    f01009f6 <monitor+0x112>
		while (*buf && strchr(WHITESPACE, *buf))
f0100927:	83 ec 08             	sub    $0x8,%esp
f010092a:	0f be c0             	movsbl %al,%eax
f010092d:	50                   	push   %eax
f010092e:	68 f2 66 10 f0       	push   $0xf01066f2
f0100933:	e8 67 4d 00 00       	call   f010569f <strchr>
f0100938:	83 c4 10             	add    $0x10,%esp
f010093b:	85 c0                	test   %eax,%eax
f010093d:	74 6c                	je     f01009ab <monitor+0xc7>
			*buf++ = 0;
f010093f:	c6 03 00             	movb   $0x0,(%ebx)
f0100942:	89 f7                	mov    %esi,%edi
f0100944:	8d 5b 01             	lea    0x1(%ebx),%ebx
f0100947:	89 fe                	mov    %edi,%esi
		while (*buf && strchr(WHITESPACE, *buf))
f0100949:	0f b6 03             	movzbl (%ebx),%eax
f010094c:	84 c0                	test   %al,%al
f010094e:	75 d7                	jne    f0100927 <monitor+0x43>
	argv[argc] = 0;
f0100950:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100957:	00 
	if (argc == 0)
f0100958:	85 f6                	test   %esi,%esi
f010095a:	0f 84 96 00 00 00    	je     f01009f6 <monitor+0x112>
		if (strcmp(argv[0], commands[i].name) == 0)
f0100960:	83 ec 08             	sub    $0x8,%esp
f0100963:	68 be 66 10 f0       	push   $0xf01066be
f0100968:	ff 75 a8             	pushl  -0x58(%ebp)
f010096b:	e8 c9 4c 00 00       	call   f0105639 <strcmp>
f0100970:	83 c4 10             	add    $0x10,%esp
f0100973:	85 c0                	test   %eax,%eax
f0100975:	0f 84 a7 00 00 00    	je     f0100a22 <monitor+0x13e>
f010097b:	83 ec 08             	sub    $0x8,%esp
f010097e:	68 cc 66 10 f0       	push   $0xf01066cc
f0100983:	ff 75 a8             	pushl  -0x58(%ebp)
f0100986:	e8 ae 4c 00 00       	call   f0105639 <strcmp>
f010098b:	83 c4 10             	add    $0x10,%esp
f010098e:	85 c0                	test   %eax,%eax
f0100990:	0f 84 87 00 00 00    	je     f0100a1d <monitor+0x139>
	cprintf("Unknown command '%s'\n", argv[0]);
f0100996:	83 ec 08             	sub    $0x8,%esp
f0100999:	ff 75 a8             	pushl  -0x58(%ebp)
f010099c:	68 14 67 10 f0       	push   $0xf0106714
f01009a1:	e8 38 2f 00 00       	call   f01038de <cprintf>
	return 0;
f01009a6:	83 c4 10             	add    $0x10,%esp
f01009a9:	eb 4b                	jmp    f01009f6 <monitor+0x112>
		if (*buf == 0)
f01009ab:	80 3b 00             	cmpb   $0x0,(%ebx)
f01009ae:	74 a0                	je     f0100950 <monitor+0x6c>
		if (argc == MAXARGS-1) {
f01009b0:	83 fe 0f             	cmp    $0xf,%esi
f01009b3:	74 2f                	je     f01009e4 <monitor+0x100>
		argv[argc++] = buf;
f01009b5:	8d 7e 01             	lea    0x1(%esi),%edi
f01009b8:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
		while (*buf && !strchr(WHITESPACE, *buf))
f01009bc:	0f b6 03             	movzbl (%ebx),%eax
f01009bf:	84 c0                	test   %al,%al
f01009c1:	74 84                	je     f0100947 <monitor+0x63>
f01009c3:	83 ec 08             	sub    $0x8,%esp
f01009c6:	0f be c0             	movsbl %al,%eax
f01009c9:	50                   	push   %eax
f01009ca:	68 f2 66 10 f0       	push   $0xf01066f2
f01009cf:	e8 cb 4c 00 00       	call   f010569f <strchr>
f01009d4:	83 c4 10             	add    $0x10,%esp
f01009d7:	85 c0                	test   %eax,%eax
f01009d9:	0f 85 68 ff ff ff    	jne    f0100947 <monitor+0x63>
			buf++;
f01009df:	83 c3 01             	add    $0x1,%ebx
f01009e2:	eb d8                	jmp    f01009bc <monitor+0xd8>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f01009e4:	83 ec 08             	sub    $0x8,%esp
f01009e7:	6a 10                	push   $0x10
f01009e9:	68 f7 66 10 f0       	push   $0xf01066f7
f01009ee:	e8 eb 2e 00 00       	call   f01038de <cprintf>
			return 0;
f01009f3:	83 c4 10             	add    $0x10,%esp

	while (1) {
		buf = readline("K> ");
f01009f6:	83 ec 0c             	sub    $0xc,%esp
f01009f9:	68 ee 66 10 f0       	push   $0xf01066ee
f01009fe:	e8 4e 4a 00 00       	call   f0105451 <readline>
f0100a03:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100a05:	83 c4 10             	add    $0x10,%esp
f0100a08:	85 c0                	test   %eax,%eax
f0100a0a:	74 ea                	je     f01009f6 <monitor+0x112>
	argv[argc] = 0;
f0100a0c:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	argc = 0;
f0100a13:	be 00 00 00 00       	mov    $0x0,%esi
f0100a18:	e9 2c ff ff ff       	jmp    f0100949 <monitor+0x65>
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100a1d:	b8 01 00 00 00       	mov    $0x1,%eax
			return commands[i].func(argc, argv, tf);
f0100a22:	83 ec 04             	sub    $0x4,%esp
f0100a25:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0100a28:	ff 75 08             	pushl  0x8(%ebp)
f0100a2b:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100a2e:	52                   	push   %edx
f0100a2f:	56                   	push   %esi
f0100a30:	ff 14 85 bc 68 10 f0 	call   *-0xfef9744(,%eax,4)
			if (runcmd(buf, tf) < 0)
f0100a37:	83 c4 10             	add    $0x10,%esp
f0100a3a:	85 c0                	test   %eax,%eax
f0100a3c:	79 b8                	jns    f01009f6 <monitor+0x112>
				break;
	}
}
f0100a3e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100a41:	5b                   	pop    %ebx
f0100a42:	5e                   	pop    %esi
f0100a43:	5f                   	pop    %edi
f0100a44:	5d                   	pop    %ebp
f0100a45:	c3                   	ret    

f0100a46 <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

static int
nvram_read(int r)
{
f0100a46:	55                   	push   %ebp
f0100a47:	89 e5                	mov    %esp,%ebp
f0100a49:	56                   	push   %esi
f0100a4a:	53                   	push   %ebx
f0100a4b:	89 c3                	mov    %eax,%ebx
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100a4d:	83 ec 0c             	sub    $0xc,%esp
f0100a50:	50                   	push   %eax
f0100a51:	e8 e5 2c 00 00       	call   f010373b <mc146818_read>
f0100a56:	89 c6                	mov    %eax,%esi
f0100a58:	83 c3 01             	add    $0x1,%ebx
f0100a5b:	89 1c 24             	mov    %ebx,(%esp)
f0100a5e:	e8 d8 2c 00 00       	call   f010373b <mc146818_read>
f0100a63:	c1 e0 08             	shl    $0x8,%eax
f0100a66:	09 f0                	or     %esi,%eax
}
f0100a68:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100a6b:	5b                   	pop    %ebx
f0100a6c:	5e                   	pop    %esi
f0100a6d:	5d                   	pop    %ebp
f0100a6e:	c3                   	ret    

f0100a6f <boot_alloc>:
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100a6f:	83 3d 38 62 23 f0 00 	cmpl   $0x0,0xf0236238
f0100a76:	74 2c                	je     f0100aa4 <boot_alloc+0x35>
	// Allocate a chunk large enough to hold 'n' bytes, then update
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	result=nextfree;
f0100a78:	8b 0d 38 62 23 f0    	mov    0xf0236238,%ecx
	nextfree=ROUNDUP(nextfree+n, PGSIZE);
f0100a7e:	8d 84 01 ff 0f 00 00 	lea    0xfff(%ecx,%eax,1),%eax
f0100a85:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100a8a:	a3 38 62 23 f0       	mov    %eax,0xf0236238
	if((uint32_t)nextfree-KERNBASE > npages*PGSIZE) panic("out of memory!!\n");
f0100a8f:	05 00 00 00 10       	add    $0x10000000,%eax
f0100a94:	8b 15 88 6e 23 f0    	mov    0xf0236e88,%edx
f0100a9a:	c1 e2 0c             	shl    $0xc,%edx
f0100a9d:	39 d0                	cmp    %edx,%eax
f0100a9f:	77 16                	ja     f0100ab7 <boot_alloc+0x48>

	return result;
}
f0100aa1:	89 c8                	mov    %ecx,%eax
f0100aa3:	c3                   	ret    
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100aa4:	ba 07 90 27 f0       	mov    $0xf0279007,%edx
f0100aa9:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100aaf:	89 15 38 62 23 f0    	mov    %edx,0xf0236238
f0100ab5:	eb c1                	jmp    f0100a78 <boot_alloc+0x9>
{
f0100ab7:	55                   	push   %ebp
f0100ab8:	89 e5                	mov    %esp,%ebp
f0100aba:	83 ec 0c             	sub    $0xc,%esp
	if((uint32_t)nextfree-KERNBASE > npages*PGSIZE) panic("out of memory!!\n");
f0100abd:	68 cc 68 10 f0       	push   $0xf01068cc
f0100ac2:	6a 6e                	push   $0x6e
f0100ac4:	68 dd 68 10 f0       	push   $0xf01068dd
f0100ac9:	e8 72 f5 ff ff       	call   f0100040 <_panic>

f0100ace <check_va2pa>:
static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f0100ace:	89 d1                	mov    %edx,%ecx
f0100ad0:	c1 e9 16             	shr    $0x16,%ecx
	if (!(*pgdir & PTE_P))
f0100ad3:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0100ad6:	a8 01                	test   $0x1,%al
f0100ad8:	74 51                	je     f0100b2b <check_va2pa+0x5d>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100ada:	89 c1                	mov    %eax,%ecx
f0100adc:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
	if (PGNUM(pa) >= npages)
f0100ae2:	c1 e8 0c             	shr    $0xc,%eax
f0100ae5:	3b 05 88 6e 23 f0    	cmp    0xf0236e88,%eax
f0100aeb:	73 23                	jae    f0100b10 <check_va2pa+0x42>
	if (!(p[PTX(va)] & PTE_P))
f0100aed:	c1 ea 0c             	shr    $0xc,%edx
f0100af0:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100af6:	8b 94 91 00 00 00 f0 	mov    -0x10000000(%ecx,%edx,4),%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100afd:	89 d0                	mov    %edx,%eax
f0100aff:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100b04:	f6 c2 01             	test   $0x1,%dl
f0100b07:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100b0c:	0f 44 c2             	cmove  %edx,%eax
f0100b0f:	c3                   	ret    
{
f0100b10:	55                   	push   %ebp
f0100b11:	89 e5                	mov    %esp,%ebp
f0100b13:	83 ec 08             	sub    $0x8,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100b16:	51                   	push   %ecx
f0100b17:	68 a4 63 10 f0       	push   $0xf01063a4
f0100b1c:	68 84 03 00 00       	push   $0x384
f0100b21:	68 dd 68 10 f0       	push   $0xf01068dd
f0100b26:	e8 15 f5 ff ff       	call   f0100040 <_panic>
		return ~0;
f0100b2b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
f0100b30:	c3                   	ret    

f0100b31 <check_page_free_list>:
{
f0100b31:	55                   	push   %ebp
f0100b32:	89 e5                	mov    %esp,%ebp
f0100b34:	57                   	push   %edi
f0100b35:	56                   	push   %esi
f0100b36:	53                   	push   %ebx
f0100b37:	83 ec 2c             	sub    $0x2c,%esp
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100b3a:	84 c0                	test   %al,%al
f0100b3c:	0f 85 77 02 00 00    	jne    f0100db9 <check_page_free_list+0x288>
	if (!page_free_list)
f0100b42:	83 3d 40 62 23 f0 00 	cmpl   $0x0,0xf0236240
f0100b49:	74 0a                	je     f0100b55 <check_page_free_list+0x24>
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100b4b:	be 00 04 00 00       	mov    $0x400,%esi
f0100b50:	e9 bf 02 00 00       	jmp    f0100e14 <check_page_free_list+0x2e3>
		panic("'page_free_list' is a null pointer!");
f0100b55:	83 ec 04             	sub    $0x4,%esp
f0100b58:	68 24 6c 10 f0       	push   $0xf0106c24
f0100b5d:	68 b8 02 00 00       	push   $0x2b8
f0100b62:	68 dd 68 10 f0       	push   $0xf01068dd
f0100b67:	e8 d4 f4 ff ff       	call   f0100040 <_panic>
f0100b6c:	50                   	push   %eax
f0100b6d:	68 a4 63 10 f0       	push   $0xf01063a4
f0100b72:	6a 58                	push   $0x58
f0100b74:	68 e9 68 10 f0       	push   $0xf01068e9
f0100b79:	e8 c2 f4 ff ff       	call   f0100040 <_panic>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100b7e:	8b 1b                	mov    (%ebx),%ebx
f0100b80:	85 db                	test   %ebx,%ebx
f0100b82:	74 41                	je     f0100bc5 <check_page_free_list+0x94>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100b84:	89 d8                	mov    %ebx,%eax
f0100b86:	2b 05 90 6e 23 f0    	sub    0xf0236e90,%eax
f0100b8c:	c1 f8 03             	sar    $0x3,%eax
f0100b8f:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100b92:	89 c2                	mov    %eax,%edx
f0100b94:	c1 ea 16             	shr    $0x16,%edx
f0100b97:	39 f2                	cmp    %esi,%edx
f0100b99:	73 e3                	jae    f0100b7e <check_page_free_list+0x4d>
	if (PGNUM(pa) >= npages)
f0100b9b:	89 c2                	mov    %eax,%edx
f0100b9d:	c1 ea 0c             	shr    $0xc,%edx
f0100ba0:	3b 15 88 6e 23 f0    	cmp    0xf0236e88,%edx
f0100ba6:	73 c4                	jae    f0100b6c <check_page_free_list+0x3b>
			memset(page2kva(pp), 0x97, 128);
f0100ba8:	83 ec 04             	sub    $0x4,%esp
f0100bab:	68 80 00 00 00       	push   $0x80
f0100bb0:	68 97 00 00 00       	push   $0x97
	return (void *)(pa + KERNBASE);
f0100bb5:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100bba:	50                   	push   %eax
f0100bbb:	e8 24 4b 00 00       	call   f01056e4 <memset>
f0100bc0:	83 c4 10             	add    $0x10,%esp
f0100bc3:	eb b9                	jmp    f0100b7e <check_page_free_list+0x4d>
	first_free_page = (char *) boot_alloc(0);
f0100bc5:	b8 00 00 00 00       	mov    $0x0,%eax
f0100bca:	e8 a0 fe ff ff       	call   f0100a6f <boot_alloc>
f0100bcf:	89 45 cc             	mov    %eax,-0x34(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100bd2:	8b 15 40 62 23 f0    	mov    0xf0236240,%edx
		assert(pp >= pages);
f0100bd8:	8b 0d 90 6e 23 f0    	mov    0xf0236e90,%ecx
		assert(pp < pages + npages);
f0100bde:	a1 88 6e 23 f0       	mov    0xf0236e88,%eax
f0100be3:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0100be6:	8d 34 c1             	lea    (%ecx,%eax,8),%esi
	int nfree_basemem = 0, nfree_extmem = 0;
f0100be9:	bf 00 00 00 00       	mov    $0x0,%edi
f0100bee:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100bf1:	e9 f9 00 00 00       	jmp    f0100cef <check_page_free_list+0x1be>
		assert(pp >= pages);
f0100bf6:	68 f7 68 10 f0       	push   $0xf01068f7
f0100bfb:	68 03 69 10 f0       	push   $0xf0106903
f0100c00:	68 d2 02 00 00       	push   $0x2d2
f0100c05:	68 dd 68 10 f0       	push   $0xf01068dd
f0100c0a:	e8 31 f4 ff ff       	call   f0100040 <_panic>
		assert(pp < pages + npages);
f0100c0f:	68 18 69 10 f0       	push   $0xf0106918
f0100c14:	68 03 69 10 f0       	push   $0xf0106903
f0100c19:	68 d3 02 00 00       	push   $0x2d3
f0100c1e:	68 dd 68 10 f0       	push   $0xf01068dd
f0100c23:	e8 18 f4 ff ff       	call   f0100040 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100c28:	68 48 6c 10 f0       	push   $0xf0106c48
f0100c2d:	68 03 69 10 f0       	push   $0xf0106903
f0100c32:	68 d4 02 00 00       	push   $0x2d4
f0100c37:	68 dd 68 10 f0       	push   $0xf01068dd
f0100c3c:	e8 ff f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != 0);
f0100c41:	68 2c 69 10 f0       	push   $0xf010692c
f0100c46:	68 03 69 10 f0       	push   $0xf0106903
f0100c4b:	68 d7 02 00 00       	push   $0x2d7
f0100c50:	68 dd 68 10 f0       	push   $0xf01068dd
f0100c55:	e8 e6 f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100c5a:	68 3d 69 10 f0       	push   $0xf010693d
f0100c5f:	68 03 69 10 f0       	push   $0xf0106903
f0100c64:	68 d8 02 00 00       	push   $0x2d8
f0100c69:	68 dd 68 10 f0       	push   $0xf01068dd
f0100c6e:	e8 cd f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100c73:	68 7c 6c 10 f0       	push   $0xf0106c7c
f0100c78:	68 03 69 10 f0       	push   $0xf0106903
f0100c7d:	68 d9 02 00 00       	push   $0x2d9
f0100c82:	68 dd 68 10 f0       	push   $0xf01068dd
f0100c87:	e8 b4 f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100c8c:	68 56 69 10 f0       	push   $0xf0106956
f0100c91:	68 03 69 10 f0       	push   $0xf0106903
f0100c96:	68 da 02 00 00       	push   $0x2da
f0100c9b:	68 dd 68 10 f0       	push   $0xf01068dd
f0100ca0:	e8 9b f3 ff ff       	call   f0100040 <_panic>
	if (PGNUM(pa) >= npages)
f0100ca5:	89 c3                	mov    %eax,%ebx
f0100ca7:	c1 eb 0c             	shr    $0xc,%ebx
f0100caa:	39 5d d0             	cmp    %ebx,-0x30(%ebp)
f0100cad:	76 0f                	jbe    f0100cbe <check_page_free_list+0x18d>
	return (void *)(pa + KERNBASE);
f0100caf:	2d 00 00 00 10       	sub    $0x10000000,%eax
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100cb4:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0100cb7:	77 17                	ja     f0100cd0 <check_page_free_list+0x19f>
			++nfree_extmem;
f0100cb9:	83 c7 01             	add    $0x1,%edi
f0100cbc:	eb 2f                	jmp    f0100ced <check_page_free_list+0x1bc>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100cbe:	50                   	push   %eax
f0100cbf:	68 a4 63 10 f0       	push   $0xf01063a4
f0100cc4:	6a 58                	push   $0x58
f0100cc6:	68 e9 68 10 f0       	push   $0xf01068e9
f0100ccb:	e8 70 f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100cd0:	68 a0 6c 10 f0       	push   $0xf0106ca0
f0100cd5:	68 03 69 10 f0       	push   $0xf0106903
f0100cda:	68 db 02 00 00       	push   $0x2db
f0100cdf:	68 dd 68 10 f0       	push   $0xf01068dd
f0100ce4:	e8 57 f3 ff ff       	call   f0100040 <_panic>
			++nfree_basemem;
f0100ce9:	83 45 d4 01          	addl   $0x1,-0x2c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100ced:	8b 12                	mov    (%edx),%edx
f0100cef:	85 d2                	test   %edx,%edx
f0100cf1:	74 74                	je     f0100d67 <check_page_free_list+0x236>
		assert(pp >= pages);
f0100cf3:	39 d1                	cmp    %edx,%ecx
f0100cf5:	0f 87 fb fe ff ff    	ja     f0100bf6 <check_page_free_list+0xc5>
		assert(pp < pages + npages);
f0100cfb:	39 d6                	cmp    %edx,%esi
f0100cfd:	0f 86 0c ff ff ff    	jbe    f0100c0f <check_page_free_list+0xde>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100d03:	89 d0                	mov    %edx,%eax
f0100d05:	29 c8                	sub    %ecx,%eax
f0100d07:	a8 07                	test   $0x7,%al
f0100d09:	0f 85 19 ff ff ff    	jne    f0100c28 <check_page_free_list+0xf7>
	return (pp - pages) << PGSHIFT;
f0100d0f:	c1 f8 03             	sar    $0x3,%eax
		assert(page2pa(pp) != 0);
f0100d12:	c1 e0 0c             	shl    $0xc,%eax
f0100d15:	0f 84 26 ff ff ff    	je     f0100c41 <check_page_free_list+0x110>
		assert(page2pa(pp) != IOPHYSMEM);
f0100d1b:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100d20:	0f 84 34 ff ff ff    	je     f0100c5a <check_page_free_list+0x129>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100d26:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100d2b:	0f 84 42 ff ff ff    	je     f0100c73 <check_page_free_list+0x142>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100d31:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100d36:	0f 84 50 ff ff ff    	je     f0100c8c <check_page_free_list+0x15b>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100d3c:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100d41:	0f 87 5e ff ff ff    	ja     f0100ca5 <check_page_free_list+0x174>
		assert(page2pa(pp) != MPENTRY_PADDR);
f0100d47:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0100d4c:	75 9b                	jne    f0100ce9 <check_page_free_list+0x1b8>
f0100d4e:	68 70 69 10 f0       	push   $0xf0106970
f0100d53:	68 03 69 10 f0       	push   $0xf0106903
f0100d58:	68 dd 02 00 00       	push   $0x2dd
f0100d5d:	68 dd 68 10 f0       	push   $0xf01068dd
f0100d62:	e8 d9 f2 ff ff       	call   f0100040 <_panic>
f0100d67:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
	assert(nfree_basemem > 0);
f0100d6a:	85 db                	test   %ebx,%ebx
f0100d6c:	7e 19                	jle    f0100d87 <check_page_free_list+0x256>
	assert(nfree_extmem > 0);
f0100d6e:	85 ff                	test   %edi,%edi
f0100d70:	7e 2e                	jle    f0100da0 <check_page_free_list+0x26f>
	cprintf("check_page_free_list() succeeded!\n");
f0100d72:	83 ec 0c             	sub    $0xc,%esp
f0100d75:	68 e8 6c 10 f0       	push   $0xf0106ce8
f0100d7a:	e8 5f 2b 00 00       	call   f01038de <cprintf>
}
f0100d7f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100d82:	5b                   	pop    %ebx
f0100d83:	5e                   	pop    %esi
f0100d84:	5f                   	pop    %edi
f0100d85:	5d                   	pop    %ebp
f0100d86:	c3                   	ret    
	assert(nfree_basemem > 0);
f0100d87:	68 8d 69 10 f0       	push   $0xf010698d
f0100d8c:	68 03 69 10 f0       	push   $0xf0106903
f0100d91:	68 e5 02 00 00       	push   $0x2e5
f0100d96:	68 dd 68 10 f0       	push   $0xf01068dd
f0100d9b:	e8 a0 f2 ff ff       	call   f0100040 <_panic>
	assert(nfree_extmem > 0);
f0100da0:	68 9f 69 10 f0       	push   $0xf010699f
f0100da5:	68 03 69 10 f0       	push   $0xf0106903
f0100daa:	68 e6 02 00 00       	push   $0x2e6
f0100daf:	68 dd 68 10 f0       	push   $0xf01068dd
f0100db4:	e8 87 f2 ff ff       	call   f0100040 <_panic>
	if (!page_free_list)
f0100db9:	a1 40 62 23 f0       	mov    0xf0236240,%eax
f0100dbe:	85 c0                	test   %eax,%eax
f0100dc0:	0f 84 8f fd ff ff    	je     f0100b55 <check_page_free_list+0x24>
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100dc6:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0100dc9:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100dcc:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100dcf:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0100dd2:	89 c2                	mov    %eax,%edx
f0100dd4:	2b 15 90 6e 23 f0    	sub    0xf0236e90,%edx
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100dda:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100de0:	0f 95 c2             	setne  %dl
f0100de3:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0100de6:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100dea:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100dec:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100df0:	8b 00                	mov    (%eax),%eax
f0100df2:	85 c0                	test   %eax,%eax
f0100df4:	75 dc                	jne    f0100dd2 <check_page_free_list+0x2a1>
		*tp[1] = 0;
f0100df6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100df9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100dff:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100e02:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100e05:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100e07:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100e0a:	a3 40 62 23 f0       	mov    %eax,0xf0236240
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100e0f:	be 01 00 00 00       	mov    $0x1,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100e14:	8b 1d 40 62 23 f0    	mov    0xf0236240,%ebx
f0100e1a:	e9 61 fd ff ff       	jmp    f0100b80 <check_page_free_list+0x4f>

f0100e1f <page_init>:
{
f0100e1f:	f3 0f 1e fb          	endbr32 
f0100e23:	55                   	push   %ebp
f0100e24:	89 e5                	mov    %esp,%ebp
f0100e26:	57                   	push   %edi
f0100e27:	56                   	push   %esi
f0100e28:	53                   	push   %ebx
f0100e29:	83 ec 0c             	sub    $0xc,%esp
	size_t kernel_end_page = PADDR(boot_alloc(0)) / PGSIZE;	
f0100e2c:	b8 00 00 00 00       	mov    $0x0,%eax
f0100e31:	e8 39 fc ff ff       	call   f0100a6f <boot_alloc>
	if ((uint32_t)kva < KERNBASE)
f0100e36:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100e3b:	76 20                	jbe    f0100e5d <page_init+0x3e>
	return (physaddr_t)kva - KERNBASE;
f0100e3d:	8d 88 00 00 00 10    	lea    0x10000000(%eax),%ecx
f0100e43:	c1 e9 0c             	shr    $0xc,%ecx
f0100e46:	8b 1d 40 62 23 f0    	mov    0xf0236240,%ebx
	for (i = 0; i < npages; i++) {
f0100e4c:	be 00 00 00 00       	mov    $0x0,%esi
f0100e51:	b8 00 00 00 00       	mov    $0x0,%eax
			page_free_list = &pages[i];
f0100e56:	bf 01 00 00 00       	mov    $0x1,%edi
	for (i = 0; i < npages; i++) {
f0100e5b:	eb 38                	jmp    f0100e95 <page_init+0x76>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100e5d:	50                   	push   %eax
f0100e5e:	68 c8 63 10 f0       	push   $0xf01063c8
f0100e63:	68 43 01 00 00       	push   $0x143
f0100e68:	68 dd 68 10 f0       	push   $0xf01068dd
f0100e6d:	e8 ce f1 ff ff       	call   f0100040 <_panic>
		} else if (i >= io_hole_start_page && i < kernel_end_page) {
f0100e72:	3d 9f 00 00 00       	cmp    $0x9f,%eax
f0100e77:	76 3c                	jbe    f0100eb5 <page_init+0x96>
f0100e79:	39 c8                	cmp    %ecx,%eax
f0100e7b:	73 38                	jae    f0100eb5 <page_init+0x96>
			pages[i].pp_ref = 1;
f0100e7d:	8b 15 90 6e 23 f0    	mov    0xf0236e90,%edx
f0100e83:	8d 14 c2             	lea    (%edx,%eax,8),%edx
f0100e86:	66 c7 42 04 01 00    	movw   $0x1,0x4(%edx)
			pages[i].pp_link = NULL;
f0100e8c:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
	for (i = 0; i < npages; i++) {
f0100e92:	83 c0 01             	add    $0x1,%eax
f0100e95:	39 05 88 6e 23 f0    	cmp    %eax,0xf0236e88
f0100e9b:	76 55                	jbe    f0100ef2 <page_init+0xd3>
		if (i == 0) {
f0100e9d:	85 c0                	test   %eax,%eax
f0100e9f:	75 d1                	jne    f0100e72 <page_init+0x53>
			pages[i].pp_ref = 1;
f0100ea1:	8b 15 90 6e 23 f0    	mov    0xf0236e90,%edx
f0100ea7:	66 c7 42 04 01 00    	movw   $0x1,0x4(%edx)
			pages[i].pp_link = NULL;
f0100ead:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
f0100eb3:	eb dd                	jmp    f0100e92 <page_init+0x73>
		}else if(i == MPENTRY_PADDR / PGSIZE){
f0100eb5:	83 f8 07             	cmp    $0x7,%eax
f0100eb8:	74 23                	je     f0100edd <page_init+0xbe>
f0100eba:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
			pages[i].pp_ref = 0;
f0100ec1:	89 d6                	mov    %edx,%esi
f0100ec3:	03 35 90 6e 23 f0    	add    0xf0236e90,%esi
f0100ec9:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)
			pages[i].pp_link = page_free_list;
f0100ecf:	89 1e                	mov    %ebx,(%esi)
			page_free_list = &pages[i];
f0100ed1:	89 d3                	mov    %edx,%ebx
f0100ed3:	03 1d 90 6e 23 f0    	add    0xf0236e90,%ebx
f0100ed9:	89 fe                	mov    %edi,%esi
f0100edb:	eb b5                	jmp    f0100e92 <page_init+0x73>
			pages[i].pp_ref = 1;
f0100edd:	8b 15 90 6e 23 f0    	mov    0xf0236e90,%edx
f0100ee3:	66 c7 42 3c 01 00    	movw   $0x1,0x3c(%edx)
			pages[i].pp_link = NULL;
f0100ee9:	c7 42 38 00 00 00 00 	movl   $0x0,0x38(%edx)
f0100ef0:	eb a0                	jmp    f0100e92 <page_init+0x73>
f0100ef2:	89 f0                	mov    %esi,%eax
f0100ef4:	84 c0                	test   %al,%al
f0100ef6:	74 06                	je     f0100efe <page_init+0xdf>
f0100ef8:	89 1d 40 62 23 f0    	mov    %ebx,0xf0236240
}
f0100efe:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100f01:	5b                   	pop    %ebx
f0100f02:	5e                   	pop    %esi
f0100f03:	5f                   	pop    %edi
f0100f04:	5d                   	pop    %ebp
f0100f05:	c3                   	ret    

f0100f06 <page_alloc>:
{
f0100f06:	f3 0f 1e fb          	endbr32 
f0100f0a:	55                   	push   %ebp
f0100f0b:	89 e5                	mov    %esp,%ebp
f0100f0d:	53                   	push   %ebx
f0100f0e:	83 ec 04             	sub    $0x4,%esp
	if(page_free_list == NULL) return NULL;
f0100f11:	8b 1d 40 62 23 f0    	mov    0xf0236240,%ebx
f0100f17:	85 db                	test   %ebx,%ebx
f0100f19:	74 13                	je     f0100f2e <page_alloc+0x28>
	page_free_list=res->pp_link;
f0100f1b:	8b 03                	mov    (%ebx),%eax
f0100f1d:	a3 40 62 23 f0       	mov    %eax,0xf0236240
	res->pp_link=NULL;
f0100f22:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if(alloc_flags&ALLOC_ZERO) 	memset(page2kva(res), 0, PGSIZE);
f0100f28:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0100f2c:	75 07                	jne    f0100f35 <page_alloc+0x2f>
}
f0100f2e:	89 d8                	mov    %ebx,%eax
f0100f30:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100f33:	c9                   	leave  
f0100f34:	c3                   	ret    
	return (pp - pages) << PGSHIFT;
f0100f35:	89 d8                	mov    %ebx,%eax
f0100f37:	2b 05 90 6e 23 f0    	sub    0xf0236e90,%eax
f0100f3d:	c1 f8 03             	sar    $0x3,%eax
f0100f40:	89 c2                	mov    %eax,%edx
f0100f42:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0100f45:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0100f4a:	3b 05 88 6e 23 f0    	cmp    0xf0236e88,%eax
f0100f50:	73 1b                	jae    f0100f6d <page_alloc+0x67>
	if(alloc_flags&ALLOC_ZERO) 	memset(page2kva(res), 0, PGSIZE);
f0100f52:	83 ec 04             	sub    $0x4,%esp
f0100f55:	68 00 10 00 00       	push   $0x1000
f0100f5a:	6a 00                	push   $0x0
	return (void *)(pa + KERNBASE);
f0100f5c:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0100f62:	52                   	push   %edx
f0100f63:	e8 7c 47 00 00       	call   f01056e4 <memset>
f0100f68:	83 c4 10             	add    $0x10,%esp
f0100f6b:	eb c1                	jmp    f0100f2e <page_alloc+0x28>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100f6d:	52                   	push   %edx
f0100f6e:	68 a4 63 10 f0       	push   $0xf01063a4
f0100f73:	6a 58                	push   $0x58
f0100f75:	68 e9 68 10 f0       	push   $0xf01068e9
f0100f7a:	e8 c1 f0 ff ff       	call   f0100040 <_panic>

f0100f7f <page_free>:
{
f0100f7f:	f3 0f 1e fb          	endbr32 
f0100f83:	55                   	push   %ebp
f0100f84:	89 e5                	mov    %esp,%ebp
f0100f86:	83 ec 08             	sub    $0x8,%esp
f0100f89:	8b 45 08             	mov    0x8(%ebp),%eax
	assert(pp->pp_ref==0);
f0100f8c:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0100f91:	75 14                	jne    f0100fa7 <page_free+0x28>
	assert(pp->pp_link==NULL);
f0100f93:	83 38 00             	cmpl   $0x0,(%eax)
f0100f96:	75 28                	jne    f0100fc0 <page_free+0x41>
	pp->pp_link=page_free_list;
f0100f98:	8b 15 40 62 23 f0    	mov    0xf0236240,%edx
f0100f9e:	89 10                	mov    %edx,(%eax)
	page_free_list=pp;
f0100fa0:	a3 40 62 23 f0       	mov    %eax,0xf0236240
}
f0100fa5:	c9                   	leave  
f0100fa6:	c3                   	ret    
	assert(pp->pp_ref==0);
f0100fa7:	68 b0 69 10 f0       	push   $0xf01069b0
f0100fac:	68 03 69 10 f0       	push   $0xf0106903
f0100fb1:	68 7e 01 00 00       	push   $0x17e
f0100fb6:	68 dd 68 10 f0       	push   $0xf01068dd
f0100fbb:	e8 80 f0 ff ff       	call   f0100040 <_panic>
	assert(pp->pp_link==NULL);
f0100fc0:	68 be 69 10 f0       	push   $0xf01069be
f0100fc5:	68 03 69 10 f0       	push   $0xf0106903
f0100fca:	68 7f 01 00 00       	push   $0x17f
f0100fcf:	68 dd 68 10 f0       	push   $0xf01068dd
f0100fd4:	e8 67 f0 ff ff       	call   f0100040 <_panic>

f0100fd9 <page_decref>:
{
f0100fd9:	f3 0f 1e fb          	endbr32 
f0100fdd:	55                   	push   %ebp
f0100fde:	89 e5                	mov    %esp,%ebp
f0100fe0:	83 ec 08             	sub    $0x8,%esp
f0100fe3:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f0100fe6:	0f b7 42 04          	movzwl 0x4(%edx),%eax
f0100fea:	83 e8 01             	sub    $0x1,%eax
f0100fed:	66 89 42 04          	mov    %ax,0x4(%edx)
f0100ff1:	66 85 c0             	test   %ax,%ax
f0100ff4:	74 02                	je     f0100ff8 <page_decref+0x1f>
}
f0100ff6:	c9                   	leave  
f0100ff7:	c3                   	ret    
		page_free(pp);
f0100ff8:	83 ec 0c             	sub    $0xc,%esp
f0100ffb:	52                   	push   %edx
f0100ffc:	e8 7e ff ff ff       	call   f0100f7f <page_free>
f0101001:	83 c4 10             	add    $0x10,%esp
}
f0101004:	eb f0                	jmp    f0100ff6 <page_decref+0x1d>

f0101006 <pgdir_walk>:
{
f0101006:	f3 0f 1e fb          	endbr32 
f010100a:	55                   	push   %ebp
f010100b:	89 e5                	mov    %esp,%ebp
f010100d:	56                   	push   %esi
f010100e:	53                   	push   %ebx
f010100f:	8b 75 0c             	mov    0xc(%ebp),%esi
	unsigned int dic_move=PDX(va);
f0101012:	89 f3                	mov    %esi,%ebx
f0101014:	c1 eb 16             	shr    $0x16,%ebx
	pde_t * dic_entry_ptr=pgdir+dic_move;
f0101017:	c1 e3 02             	shl    $0x2,%ebx
f010101a:	03 5d 08             	add    0x8(%ebp),%ebx
	if(!(*dic_entry_ptr & PTE_P)){
f010101d:	f6 03 01             	testb  $0x1,(%ebx)
f0101020:	75 2d                	jne    f010104f <pgdir_walk+0x49>
		if(create){
f0101022:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0101026:	74 68                	je     f0101090 <pgdir_walk+0x8a>
			new_page=page_alloc(1);
f0101028:	83 ec 0c             	sub    $0xc,%esp
f010102b:	6a 01                	push   $0x1
f010102d:	e8 d4 fe ff ff       	call   f0100f06 <page_alloc>
			if(new_page==NULL) return NULL;
f0101032:	83 c4 10             	add    $0x10,%esp
f0101035:	85 c0                	test   %eax,%eax
f0101037:	74 3b                	je     f0101074 <pgdir_walk+0x6e>
			new_page->pp_ref++;
f0101039:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
	return (pp - pages) << PGSHIFT;
f010103e:	2b 05 90 6e 23 f0    	sub    0xf0236e90,%eax
f0101044:	c1 f8 03             	sar    $0x3,%eax
f0101047:	c1 e0 0c             	shl    $0xc,%eax
			*dic_entry_ptr=(page2pa(new_page)|PTE_P|PTE_W|PTE_U);
f010104a:	83 c8 07             	or     $0x7,%eax
f010104d:	89 03                	mov    %eax,(%ebx)
	page_move=PTX(va);
f010104f:	c1 ee 0c             	shr    $0xc,%esi
f0101052:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
	page_base=KADDR(PTE_ADDR(*dic_entry_ptr));
f0101058:	8b 03                	mov    (%ebx),%eax
f010105a:	89 c2                	mov    %eax,%edx
f010105c:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	if (PGNUM(pa) >= npages)
f0101062:	c1 e8 0c             	shr    $0xc,%eax
f0101065:	3b 05 88 6e 23 f0    	cmp    0xf0236e88,%eax
f010106b:	73 0e                	jae    f010107b <pgdir_walk+0x75>
	return &page_base[page_move];
f010106d:	8d 84 b2 00 00 00 f0 	lea    -0x10000000(%edx,%esi,4),%eax
}
f0101074:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0101077:	5b                   	pop    %ebx
f0101078:	5e                   	pop    %esi
f0101079:	5d                   	pop    %ebp
f010107a:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010107b:	52                   	push   %edx
f010107c:	68 a4 63 10 f0       	push   $0xf01063a4
f0101081:	68 b9 01 00 00       	push   $0x1b9
f0101086:	68 dd 68 10 f0       	push   $0xf01068dd
f010108b:	e8 b0 ef ff ff       	call   f0100040 <_panic>
		else return NULL;
f0101090:	b8 00 00 00 00       	mov    $0x0,%eax
f0101095:	eb dd                	jmp    f0101074 <pgdir_walk+0x6e>

f0101097 <boot_map_region>:
{
f0101097:	55                   	push   %ebp
f0101098:	89 e5                	mov    %esp,%ebp
f010109a:	57                   	push   %edi
f010109b:	56                   	push   %esi
f010109c:	53                   	push   %ebx
f010109d:	83 ec 1c             	sub    $0x1c,%esp
f01010a0:	89 c7                	mov    %eax,%edi
f01010a2:	89 55 e0             	mov    %edx,-0x20(%ebp)
f01010a5:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	for(i=0; i<size; i+=PGSIZE){
f01010a8:	be 00 00 00 00       	mov    $0x0,%esi
f01010ad:	89 f3                	mov    %esi,%ebx
f01010af:	03 5d 08             	add    0x8(%ebp),%ebx
f01010b2:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
f01010b5:	76 24                	jbe    f01010db <boot_map_region+0x44>
		entry=pgdir_walk(pgdir, (void *)va, 1);
f01010b7:	83 ec 04             	sub    $0x4,%esp
f01010ba:	6a 01                	push   $0x1
f01010bc:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01010bf:	01 f0                	add    %esi,%eax
f01010c1:	50                   	push   %eax
f01010c2:	57                   	push   %edi
f01010c3:	e8 3e ff ff ff       	call   f0101006 <pgdir_walk>
		*entry=(pa|perm|PTE_P);
f01010c8:	0b 5d 0c             	or     0xc(%ebp),%ebx
f01010cb:	83 cb 01             	or     $0x1,%ebx
f01010ce:	89 18                	mov    %ebx,(%eax)
	for(i=0; i<size; i+=PGSIZE){
f01010d0:	81 c6 00 10 00 00    	add    $0x1000,%esi
f01010d6:	83 c4 10             	add    $0x10,%esp
f01010d9:	eb d2                	jmp    f01010ad <boot_map_region+0x16>
}
f01010db:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01010de:	5b                   	pop    %ebx
f01010df:	5e                   	pop    %esi
f01010e0:	5f                   	pop    %edi
f01010e1:	5d                   	pop    %ebp
f01010e2:	c3                   	ret    

f01010e3 <page_lookup>:
{
f01010e3:	f3 0f 1e fb          	endbr32 
f01010e7:	55                   	push   %ebp
f01010e8:	89 e5                	mov    %esp,%ebp
f01010ea:	53                   	push   %ebx
f01010eb:	83 ec 08             	sub    $0x8,%esp
f01010ee:	8b 5d 10             	mov    0x10(%ebp),%ebx
	entry=pgdir_walk(pgdir, va, 0);
f01010f1:	6a 00                	push   $0x0
f01010f3:	ff 75 0c             	pushl  0xc(%ebp)
f01010f6:	ff 75 08             	pushl  0x8(%ebp)
f01010f9:	e8 08 ff ff ff       	call   f0101006 <pgdir_walk>
	if(entry==NULL) return NULL;
f01010fe:	83 c4 10             	add    $0x10,%esp
f0101101:	85 c0                	test   %eax,%eax
f0101103:	74 3c                	je     f0101141 <page_lookup+0x5e>
	if(!(*entry & PTE_P)) return NULL;
f0101105:	8b 10                	mov    (%eax),%edx
f0101107:	f6 c2 01             	test   $0x1,%dl
f010110a:	74 39                	je     f0101145 <page_lookup+0x62>
f010110c:	c1 ea 0c             	shr    $0xc,%edx
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010110f:	39 15 88 6e 23 f0    	cmp    %edx,0xf0236e88
f0101115:	76 16                	jbe    f010112d <page_lookup+0x4a>
		panic("pa2page called with invalid pa");
	return &pages[PGNUM(pa)];
f0101117:	8b 0d 90 6e 23 f0    	mov    0xf0236e90,%ecx
f010111d:	8d 14 d1             	lea    (%ecx,%edx,8),%edx
	if(pte_store!=NULL) *pte_store=entry;
f0101120:	85 db                	test   %ebx,%ebx
f0101122:	74 02                	je     f0101126 <page_lookup+0x43>
f0101124:	89 03                	mov    %eax,(%ebx)
}
f0101126:	89 d0                	mov    %edx,%eax
f0101128:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010112b:	c9                   	leave  
f010112c:	c3                   	ret    
		panic("pa2page called with invalid pa");
f010112d:	83 ec 04             	sub    $0x4,%esp
f0101130:	68 0c 6d 10 f0       	push   $0xf0106d0c
f0101135:	6a 51                	push   $0x51
f0101137:	68 e9 68 10 f0       	push   $0xf01068e9
f010113c:	e8 ff ee ff ff       	call   f0100040 <_panic>
	if(entry==NULL) return NULL;
f0101141:	89 c2                	mov    %eax,%edx
f0101143:	eb e1                	jmp    f0101126 <page_lookup+0x43>
	if(!(*entry & PTE_P)) return NULL;
f0101145:	ba 00 00 00 00       	mov    $0x0,%edx
f010114a:	eb da                	jmp    f0101126 <page_lookup+0x43>

f010114c <tlb_invalidate>:
{
f010114c:	f3 0f 1e fb          	endbr32 
f0101150:	55                   	push   %ebp
f0101151:	89 e5                	mov    %esp,%ebp
f0101153:	83 ec 08             	sub    $0x8,%esp
	if (!curenv || curenv->env_pgdir == pgdir)
f0101156:	e8 a7 4b 00 00       	call   f0105d02 <cpunum>
f010115b:	6b c0 74             	imul   $0x74,%eax,%eax
f010115e:	83 b8 28 70 23 f0 00 	cmpl   $0x0,-0xfdc8fd8(%eax)
f0101165:	74 16                	je     f010117d <tlb_invalidate+0x31>
f0101167:	e8 96 4b 00 00       	call   f0105d02 <cpunum>
f010116c:	6b c0 74             	imul   $0x74,%eax,%eax
f010116f:	8b 80 28 70 23 f0    	mov    -0xfdc8fd8(%eax),%eax
f0101175:	8b 55 08             	mov    0x8(%ebp),%edx
f0101178:	39 50 60             	cmp    %edx,0x60(%eax)
f010117b:	75 06                	jne    f0101183 <tlb_invalidate+0x37>
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f010117d:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101180:	0f 01 38             	invlpg (%eax)
}
f0101183:	c9                   	leave  
f0101184:	c3                   	ret    

f0101185 <page_remove>:
{
f0101185:	f3 0f 1e fb          	endbr32 
f0101189:	55                   	push   %ebp
f010118a:	89 e5                	mov    %esp,%ebp
f010118c:	56                   	push   %esi
f010118d:	53                   	push   %ebx
f010118e:	83 ec 14             	sub    $0x14,%esp
f0101191:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0101194:	8b 75 0c             	mov    0xc(%ebp),%esi
	pte_t *pte=NULL;
f0101197:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	struct PageInfo *page=page_lookup(pgdir, va, &pte);
f010119e:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01011a1:	50                   	push   %eax
f01011a2:	56                   	push   %esi
f01011a3:	53                   	push   %ebx
f01011a4:	e8 3a ff ff ff       	call   f01010e3 <page_lookup>
	if(page==NULL) return;
f01011a9:	83 c4 10             	add    $0x10,%esp
f01011ac:	85 c0                	test   %eax,%eax
f01011ae:	74 1f                	je     f01011cf <page_remove+0x4a>
	page_decref(page);
f01011b0:	83 ec 0c             	sub    $0xc,%esp
f01011b3:	50                   	push   %eax
f01011b4:	e8 20 fe ff ff       	call   f0100fd9 <page_decref>
	tlb_invalidate(pgdir, va);
f01011b9:	83 c4 08             	add    $0x8,%esp
f01011bc:	56                   	push   %esi
f01011bd:	53                   	push   %ebx
f01011be:	e8 89 ff ff ff       	call   f010114c <tlb_invalidate>
	*pte=0;
f01011c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01011c6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
f01011cc:	83 c4 10             	add    $0x10,%esp
}
f01011cf:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01011d2:	5b                   	pop    %ebx
f01011d3:	5e                   	pop    %esi
f01011d4:	5d                   	pop    %ebp
f01011d5:	c3                   	ret    

f01011d6 <page_insert>:
{
f01011d6:	f3 0f 1e fb          	endbr32 
f01011da:	55                   	push   %ebp
f01011db:	89 e5                	mov    %esp,%ebp
f01011dd:	57                   	push   %edi
f01011de:	56                   	push   %esi
f01011df:	53                   	push   %ebx
f01011e0:	83 ec 10             	sub    $0x10,%esp
f01011e3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01011e6:	8b 7d 10             	mov    0x10(%ebp),%edi
	entry=pgdir_walk(pgdir, va, 1);
f01011e9:	6a 01                	push   $0x1
f01011eb:	57                   	push   %edi
f01011ec:	ff 75 08             	pushl  0x8(%ebp)
f01011ef:	e8 12 fe ff ff       	call   f0101006 <pgdir_walk>
	if(entry==NULL) return -E_NO_MEM;
f01011f4:	83 c4 10             	add    $0x10,%esp
f01011f7:	85 c0                	test   %eax,%eax
f01011f9:	74 4a                	je     f0101245 <page_insert+0x6f>
f01011fb:	89 c6                	mov    %eax,%esi
	pp->pp_ref++;
f01011fd:	66 83 43 04 01       	addw   $0x1,0x4(%ebx)
	if((*entry) & PTE_P){
f0101202:	f6 00 01             	testb  $0x1,(%eax)
f0101205:	75 21                	jne    f0101228 <page_insert+0x52>
	return (pp - pages) << PGSHIFT;
f0101207:	2b 1d 90 6e 23 f0    	sub    0xf0236e90,%ebx
f010120d:	c1 fb 03             	sar    $0x3,%ebx
f0101210:	c1 e3 0c             	shl    $0xc,%ebx
	*entry=(page2pa(pp)|perm|PTE_P);
f0101213:	0b 5d 14             	or     0x14(%ebp),%ebx
f0101216:	83 cb 01             	or     $0x1,%ebx
f0101219:	89 1e                	mov    %ebx,(%esi)
	return 0;
f010121b:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101220:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101223:	5b                   	pop    %ebx
f0101224:	5e                   	pop    %esi
f0101225:	5f                   	pop    %edi
f0101226:	5d                   	pop    %ebp
f0101227:	c3                   	ret    
		tlb_invalidate(pgdir, va);
f0101228:	83 ec 08             	sub    $0x8,%esp
f010122b:	57                   	push   %edi
f010122c:	ff 75 08             	pushl  0x8(%ebp)
f010122f:	e8 18 ff ff ff       	call   f010114c <tlb_invalidate>
		page_remove(pgdir, va);
f0101234:	83 c4 08             	add    $0x8,%esp
f0101237:	57                   	push   %edi
f0101238:	ff 75 08             	pushl  0x8(%ebp)
f010123b:	e8 45 ff ff ff       	call   f0101185 <page_remove>
f0101240:	83 c4 10             	add    $0x10,%esp
f0101243:	eb c2                	jmp    f0101207 <page_insert+0x31>
	if(entry==NULL) return -E_NO_MEM;
f0101245:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f010124a:	eb d4                	jmp    f0101220 <page_insert+0x4a>

f010124c <mmio_map_region>:
{
f010124c:	f3 0f 1e fb          	endbr32 
f0101250:	55                   	push   %ebp
f0101251:	89 e5                	mov    %esp,%ebp
f0101253:	57                   	push   %edi
f0101254:	56                   	push   %esi
f0101255:	53                   	push   %ebx
f0101256:	83 ec 0c             	sub    $0xc,%esp
f0101259:	8b 5d 08             	mov    0x8(%ebp),%ebx
	size = ROUNDUP(pa+size, PGSIZE);
f010125c:	8b 45 0c             	mov    0xc(%ebp),%eax
f010125f:	8d bc 03 ff 0f 00 00 	lea    0xfff(%ebx,%eax,1),%edi
f0101266:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
	pa = ROUNDDOWN(pa, PGSIZE);
f010126c:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	size -= pa;
f0101272:	89 fe                	mov    %edi,%esi
f0101274:	29 de                	sub    %ebx,%esi
	if (base+size >= MMIOLIM) panic("not enough memory");
f0101276:	8b 15 00 23 12 f0    	mov    0xf0122300,%edx
f010127c:	8d 04 32             	lea    (%edx,%esi,1),%eax
f010127f:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f0101284:	77 2b                	ja     f01012b1 <mmio_map_region+0x65>
	boot_map_region(kern_pgdir, base, size, pa, PTE_PCD|PTE_PWT|PTE_W);
f0101286:	83 ec 08             	sub    $0x8,%esp
f0101289:	6a 1a                	push   $0x1a
f010128b:	53                   	push   %ebx
f010128c:	89 f1                	mov    %esi,%ecx
f010128e:	a1 8c 6e 23 f0       	mov    0xf0236e8c,%eax
f0101293:	e8 ff fd ff ff       	call   f0101097 <boot_map_region>
	base += size;
f0101298:	89 f0                	mov    %esi,%eax
f010129a:	03 05 00 23 12 f0    	add    0xf0122300,%eax
f01012a0:	a3 00 23 12 f0       	mov    %eax,0xf0122300
	return (void*) (base - size);
f01012a5:	29 fb                	sub    %edi,%ebx
f01012a7:	01 d8                	add    %ebx,%eax
}
f01012a9:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01012ac:	5b                   	pop    %ebx
f01012ad:	5e                   	pop    %esi
f01012ae:	5f                   	pop    %edi
f01012af:	5d                   	pop    %ebp
f01012b0:	c3                   	ret    
	if (base+size >= MMIOLIM) panic("not enough memory");
f01012b1:	83 ec 04             	sub    $0x4,%esp
f01012b4:	68 d0 69 10 f0       	push   $0xf01069d0
f01012b9:	68 64 02 00 00       	push   $0x264
f01012be:	68 dd 68 10 f0       	push   $0xf01068dd
f01012c3:	e8 78 ed ff ff       	call   f0100040 <_panic>

f01012c8 <mem_init>:
{
f01012c8:	f3 0f 1e fb          	endbr32 
f01012cc:	55                   	push   %ebp
f01012cd:	89 e5                	mov    %esp,%ebp
f01012cf:	57                   	push   %edi
f01012d0:	56                   	push   %esi
f01012d1:	53                   	push   %ebx
f01012d2:	83 ec 3c             	sub    $0x3c,%esp
	basemem = nvram_read(NVRAM_BASELO);
f01012d5:	b8 15 00 00 00       	mov    $0x15,%eax
f01012da:	e8 67 f7 ff ff       	call   f0100a46 <nvram_read>
f01012df:	89 c3                	mov    %eax,%ebx
	extmem = nvram_read(NVRAM_EXTLO);
f01012e1:	b8 17 00 00 00       	mov    $0x17,%eax
f01012e6:	e8 5b f7 ff ff       	call   f0100a46 <nvram_read>
f01012eb:	89 c6                	mov    %eax,%esi
	ext16mem = nvram_read(NVRAM_EXT16LO) * 64;
f01012ed:	b8 34 00 00 00       	mov    $0x34,%eax
f01012f2:	e8 4f f7 ff ff       	call   f0100a46 <nvram_read>
	if (ext16mem)
f01012f7:	c1 e0 06             	shl    $0x6,%eax
f01012fa:	0f 84 df 00 00 00    	je     f01013df <mem_init+0x117>
		totalmem = 16 * 1024 + ext16mem;
f0101300:	05 00 40 00 00       	add    $0x4000,%eax
	npages = totalmem / (PGSIZE / 1024);
f0101305:	89 c2                	mov    %eax,%edx
f0101307:	c1 ea 02             	shr    $0x2,%edx
f010130a:	89 15 88 6e 23 f0    	mov    %edx,0xf0236e88
	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101310:	89 c2                	mov    %eax,%edx
f0101312:	29 da                	sub    %ebx,%edx
f0101314:	52                   	push   %edx
f0101315:	53                   	push   %ebx
f0101316:	50                   	push   %eax
f0101317:	68 2c 6d 10 f0       	push   $0xf0106d2c
f010131c:	e8 bd 25 00 00       	call   f01038de <cprintf>
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f0101321:	b8 00 10 00 00       	mov    $0x1000,%eax
f0101326:	e8 44 f7 ff ff       	call   f0100a6f <boot_alloc>
f010132b:	a3 8c 6e 23 f0       	mov    %eax,0xf0236e8c
	memset(kern_pgdir, 0, PGSIZE);
f0101330:	83 c4 0c             	add    $0xc,%esp
f0101333:	68 00 10 00 00       	push   $0x1000
f0101338:	6a 00                	push   $0x0
f010133a:	50                   	push   %eax
f010133b:	e8 a4 43 00 00       	call   f01056e4 <memset>
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f0101340:	a1 8c 6e 23 f0       	mov    0xf0236e8c,%eax
	if ((uint32_t)kva < KERNBASE)
f0101345:	83 c4 10             	add    $0x10,%esp
f0101348:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010134d:	0f 86 9c 00 00 00    	jbe    f01013ef <mem_init+0x127>
	return (physaddr_t)kva - KERNBASE;
f0101353:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0101359:	83 ca 05             	or     $0x5,%edx
f010135c:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	pages = (struct PageInfo *) boot_alloc(npages*sizeof(struct PageInfo));
f0101362:	a1 88 6e 23 f0       	mov    0xf0236e88,%eax
f0101367:	c1 e0 03             	shl    $0x3,%eax
f010136a:	e8 00 f7 ff ff       	call   f0100a6f <boot_alloc>
f010136f:	a3 90 6e 23 f0       	mov    %eax,0xf0236e90
	memset(pages, 0, npages*sizeof(struct PageInfo));
f0101374:	83 ec 04             	sub    $0x4,%esp
f0101377:	8b 0d 88 6e 23 f0    	mov    0xf0236e88,%ecx
f010137d:	8d 14 cd 00 00 00 00 	lea    0x0(,%ecx,8),%edx
f0101384:	52                   	push   %edx
f0101385:	6a 00                	push   $0x0
f0101387:	50                   	push   %eax
f0101388:	e8 57 43 00 00       	call   f01056e4 <memset>
	envs=(struct Env*)boot_alloc(NENV*sizeof(struct Env));
f010138d:	b8 00 f0 01 00       	mov    $0x1f000,%eax
f0101392:	e8 d8 f6 ff ff       	call   f0100a6f <boot_alloc>
f0101397:	a3 44 62 23 f0       	mov    %eax,0xf0236244
	memset(envs, 0, NENV*sizeof(struct Env));
f010139c:	83 c4 0c             	add    $0xc,%esp
f010139f:	68 00 f0 01 00       	push   $0x1f000
f01013a4:	6a 00                	push   $0x0
f01013a6:	50                   	push   %eax
f01013a7:	e8 38 43 00 00       	call   f01056e4 <memset>
	page_init();//1,init pages 2,init pages_free_list
f01013ac:	e8 6e fa ff ff       	call   f0100e1f <page_init>
	check_page_free_list(1);
f01013b1:	b8 01 00 00 00       	mov    $0x1,%eax
f01013b6:	e8 76 f7 ff ff       	call   f0100b31 <check_page_free_list>
	if (!pages)
f01013bb:	83 c4 10             	add    $0x10,%esp
f01013be:	83 3d 90 6e 23 f0 00 	cmpl   $0x0,0xf0236e90
f01013c5:	74 3d                	je     f0101404 <mem_init+0x13c>
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01013c7:	a1 40 62 23 f0       	mov    0xf0236240,%eax
f01013cc:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
f01013d3:	85 c0                	test   %eax,%eax
f01013d5:	74 44                	je     f010141b <mem_init+0x153>
		++nfree;
f01013d7:	83 45 d4 01          	addl   $0x1,-0x2c(%ebp)
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01013db:	8b 00                	mov    (%eax),%eax
f01013dd:	eb f4                	jmp    f01013d3 <mem_init+0x10b>
		totalmem = 1 * 1024 + extmem;
f01013df:	8d 86 00 04 00 00    	lea    0x400(%esi),%eax
f01013e5:	85 f6                	test   %esi,%esi
f01013e7:	0f 44 c3             	cmove  %ebx,%eax
f01013ea:	e9 16 ff ff ff       	jmp    f0101305 <mem_init+0x3d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01013ef:	50                   	push   %eax
f01013f0:	68 c8 63 10 f0       	push   $0xf01063c8
f01013f5:	68 94 00 00 00       	push   $0x94
f01013fa:	68 dd 68 10 f0       	push   $0xf01068dd
f01013ff:	e8 3c ec ff ff       	call   f0100040 <_panic>
		panic("'pages' is a null pointer!");
f0101404:	83 ec 04             	sub    $0x4,%esp
f0101407:	68 e2 69 10 f0       	push   $0xf01069e2
f010140c:	68 f9 02 00 00       	push   $0x2f9
f0101411:	68 dd 68 10 f0       	push   $0xf01068dd
f0101416:	e8 25 ec ff ff       	call   f0100040 <_panic>
	assert((pp0 = page_alloc(0)));
f010141b:	83 ec 0c             	sub    $0xc,%esp
f010141e:	6a 00                	push   $0x0
f0101420:	e8 e1 fa ff ff       	call   f0100f06 <page_alloc>
f0101425:	89 c3                	mov    %eax,%ebx
f0101427:	83 c4 10             	add    $0x10,%esp
f010142a:	85 c0                	test   %eax,%eax
f010142c:	0f 84 11 02 00 00    	je     f0101643 <mem_init+0x37b>
	assert((pp1 = page_alloc(0)));
f0101432:	83 ec 0c             	sub    $0xc,%esp
f0101435:	6a 00                	push   $0x0
f0101437:	e8 ca fa ff ff       	call   f0100f06 <page_alloc>
f010143c:	89 c6                	mov    %eax,%esi
f010143e:	83 c4 10             	add    $0x10,%esp
f0101441:	85 c0                	test   %eax,%eax
f0101443:	0f 84 13 02 00 00    	je     f010165c <mem_init+0x394>
	assert((pp2 = page_alloc(0)));
f0101449:	83 ec 0c             	sub    $0xc,%esp
f010144c:	6a 00                	push   $0x0
f010144e:	e8 b3 fa ff ff       	call   f0100f06 <page_alloc>
f0101453:	89 c7                	mov    %eax,%edi
f0101455:	83 c4 10             	add    $0x10,%esp
f0101458:	85 c0                	test   %eax,%eax
f010145a:	0f 84 15 02 00 00    	je     f0101675 <mem_init+0x3ad>
	assert(pp1 && pp1 != pp0);
f0101460:	39 f3                	cmp    %esi,%ebx
f0101462:	0f 84 26 02 00 00    	je     f010168e <mem_init+0x3c6>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101468:	39 c3                	cmp    %eax,%ebx
f010146a:	0f 84 37 02 00 00    	je     f01016a7 <mem_init+0x3df>
f0101470:	39 c6                	cmp    %eax,%esi
f0101472:	0f 84 2f 02 00 00    	je     f01016a7 <mem_init+0x3df>
	return (pp - pages) << PGSHIFT;
f0101478:	8b 0d 90 6e 23 f0    	mov    0xf0236e90,%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f010147e:	8b 15 88 6e 23 f0    	mov    0xf0236e88,%edx
f0101484:	c1 e2 0c             	shl    $0xc,%edx
f0101487:	89 d8                	mov    %ebx,%eax
f0101489:	29 c8                	sub    %ecx,%eax
f010148b:	c1 f8 03             	sar    $0x3,%eax
f010148e:	c1 e0 0c             	shl    $0xc,%eax
f0101491:	39 d0                	cmp    %edx,%eax
f0101493:	0f 83 27 02 00 00    	jae    f01016c0 <mem_init+0x3f8>
f0101499:	89 f0                	mov    %esi,%eax
f010149b:	29 c8                	sub    %ecx,%eax
f010149d:	c1 f8 03             	sar    $0x3,%eax
f01014a0:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp1) < npages*PGSIZE);
f01014a3:	39 c2                	cmp    %eax,%edx
f01014a5:	0f 86 2e 02 00 00    	jbe    f01016d9 <mem_init+0x411>
f01014ab:	89 f8                	mov    %edi,%eax
f01014ad:	29 c8                	sub    %ecx,%eax
f01014af:	c1 f8 03             	sar    $0x3,%eax
f01014b2:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp2) < npages*PGSIZE);
f01014b5:	39 c2                	cmp    %eax,%edx
f01014b7:	0f 86 35 02 00 00    	jbe    f01016f2 <mem_init+0x42a>
	fl = page_free_list;
f01014bd:	a1 40 62 23 f0       	mov    0xf0236240,%eax
f01014c2:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f01014c5:	c7 05 40 62 23 f0 00 	movl   $0x0,0xf0236240
f01014cc:	00 00 00 
	assert(!page_alloc(0));
f01014cf:	83 ec 0c             	sub    $0xc,%esp
f01014d2:	6a 00                	push   $0x0
f01014d4:	e8 2d fa ff ff       	call   f0100f06 <page_alloc>
f01014d9:	83 c4 10             	add    $0x10,%esp
f01014dc:	85 c0                	test   %eax,%eax
f01014de:	0f 85 27 02 00 00    	jne    f010170b <mem_init+0x443>
	page_free(pp0);
f01014e4:	83 ec 0c             	sub    $0xc,%esp
f01014e7:	53                   	push   %ebx
f01014e8:	e8 92 fa ff ff       	call   f0100f7f <page_free>
	page_free(pp1);
f01014ed:	89 34 24             	mov    %esi,(%esp)
f01014f0:	e8 8a fa ff ff       	call   f0100f7f <page_free>
	page_free(pp2);
f01014f5:	89 3c 24             	mov    %edi,(%esp)
f01014f8:	e8 82 fa ff ff       	call   f0100f7f <page_free>
	assert((pp0 = page_alloc(0)));
f01014fd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101504:	e8 fd f9 ff ff       	call   f0100f06 <page_alloc>
f0101509:	89 c3                	mov    %eax,%ebx
f010150b:	83 c4 10             	add    $0x10,%esp
f010150e:	85 c0                	test   %eax,%eax
f0101510:	0f 84 0e 02 00 00    	je     f0101724 <mem_init+0x45c>
	assert((pp1 = page_alloc(0)));
f0101516:	83 ec 0c             	sub    $0xc,%esp
f0101519:	6a 00                	push   $0x0
f010151b:	e8 e6 f9 ff ff       	call   f0100f06 <page_alloc>
f0101520:	89 c6                	mov    %eax,%esi
f0101522:	83 c4 10             	add    $0x10,%esp
f0101525:	85 c0                	test   %eax,%eax
f0101527:	0f 84 10 02 00 00    	je     f010173d <mem_init+0x475>
	assert((pp2 = page_alloc(0)));
f010152d:	83 ec 0c             	sub    $0xc,%esp
f0101530:	6a 00                	push   $0x0
f0101532:	e8 cf f9 ff ff       	call   f0100f06 <page_alloc>
f0101537:	89 c7                	mov    %eax,%edi
f0101539:	83 c4 10             	add    $0x10,%esp
f010153c:	85 c0                	test   %eax,%eax
f010153e:	0f 84 12 02 00 00    	je     f0101756 <mem_init+0x48e>
	assert(pp1 && pp1 != pp0);
f0101544:	39 f3                	cmp    %esi,%ebx
f0101546:	0f 84 23 02 00 00    	je     f010176f <mem_init+0x4a7>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010154c:	39 c6                	cmp    %eax,%esi
f010154e:	0f 84 34 02 00 00    	je     f0101788 <mem_init+0x4c0>
f0101554:	39 c3                	cmp    %eax,%ebx
f0101556:	0f 84 2c 02 00 00    	je     f0101788 <mem_init+0x4c0>
	assert(!page_alloc(0));
f010155c:	83 ec 0c             	sub    $0xc,%esp
f010155f:	6a 00                	push   $0x0
f0101561:	e8 a0 f9 ff ff       	call   f0100f06 <page_alloc>
f0101566:	83 c4 10             	add    $0x10,%esp
f0101569:	85 c0                	test   %eax,%eax
f010156b:	0f 85 30 02 00 00    	jne    f01017a1 <mem_init+0x4d9>
f0101571:	89 d8                	mov    %ebx,%eax
f0101573:	2b 05 90 6e 23 f0    	sub    0xf0236e90,%eax
f0101579:	c1 f8 03             	sar    $0x3,%eax
f010157c:	89 c2                	mov    %eax,%edx
f010157e:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0101581:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0101586:	3b 05 88 6e 23 f0    	cmp    0xf0236e88,%eax
f010158c:	0f 83 28 02 00 00    	jae    f01017ba <mem_init+0x4f2>
	memset(page2kva(pp0), 1, PGSIZE);
f0101592:	83 ec 04             	sub    $0x4,%esp
f0101595:	68 00 10 00 00       	push   $0x1000
f010159a:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f010159c:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f01015a2:	52                   	push   %edx
f01015a3:	e8 3c 41 00 00       	call   f01056e4 <memset>
	page_free(pp0);
f01015a8:	89 1c 24             	mov    %ebx,(%esp)
f01015ab:	e8 cf f9 ff ff       	call   f0100f7f <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f01015b0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f01015b7:	e8 4a f9 ff ff       	call   f0100f06 <page_alloc>
f01015bc:	83 c4 10             	add    $0x10,%esp
f01015bf:	85 c0                	test   %eax,%eax
f01015c1:	0f 84 05 02 00 00    	je     f01017cc <mem_init+0x504>
	assert(pp && pp0 == pp);
f01015c7:	39 c3                	cmp    %eax,%ebx
f01015c9:	0f 85 16 02 00 00    	jne    f01017e5 <mem_init+0x51d>
	return (pp - pages) << PGSHIFT;
f01015cf:	2b 05 90 6e 23 f0    	sub    0xf0236e90,%eax
f01015d5:	c1 f8 03             	sar    $0x3,%eax
f01015d8:	89 c2                	mov    %eax,%edx
f01015da:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f01015dd:	25 ff ff 0f 00       	and    $0xfffff,%eax
f01015e2:	3b 05 88 6e 23 f0    	cmp    0xf0236e88,%eax
f01015e8:	0f 83 10 02 00 00    	jae    f01017fe <mem_init+0x536>
	return (void *)(pa + KERNBASE);
f01015ee:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
f01015f4:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
		assert(c[i] == 0);
f01015fa:	80 38 00             	cmpb   $0x0,(%eax)
f01015fd:	0f 85 0d 02 00 00    	jne    f0101810 <mem_init+0x548>
f0101603:	83 c0 01             	add    $0x1,%eax
	for (i = 0; i < PGSIZE; i++)
f0101606:	39 d0                	cmp    %edx,%eax
f0101608:	75 f0                	jne    f01015fa <mem_init+0x332>
	page_free_list = fl;
f010160a:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010160d:	a3 40 62 23 f0       	mov    %eax,0xf0236240
	page_free(pp0);
f0101612:	83 ec 0c             	sub    $0xc,%esp
f0101615:	53                   	push   %ebx
f0101616:	e8 64 f9 ff ff       	call   f0100f7f <page_free>
	page_free(pp1);
f010161b:	89 34 24             	mov    %esi,(%esp)
f010161e:	e8 5c f9 ff ff       	call   f0100f7f <page_free>
	page_free(pp2);
f0101623:	89 3c 24             	mov    %edi,(%esp)
f0101626:	e8 54 f9 ff ff       	call   f0100f7f <page_free>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f010162b:	a1 40 62 23 f0       	mov    0xf0236240,%eax
f0101630:	83 c4 10             	add    $0x10,%esp
f0101633:	85 c0                	test   %eax,%eax
f0101635:	0f 84 ee 01 00 00    	je     f0101829 <mem_init+0x561>
		--nfree;
f010163b:	83 6d d4 01          	subl   $0x1,-0x2c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
f010163f:	8b 00                	mov    (%eax),%eax
f0101641:	eb f0                	jmp    f0101633 <mem_init+0x36b>
	assert((pp0 = page_alloc(0)));
f0101643:	68 fd 69 10 f0       	push   $0xf01069fd
f0101648:	68 03 69 10 f0       	push   $0xf0106903
f010164d:	68 01 03 00 00       	push   $0x301
f0101652:	68 dd 68 10 f0       	push   $0xf01068dd
f0101657:	e8 e4 e9 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f010165c:	68 13 6a 10 f0       	push   $0xf0106a13
f0101661:	68 03 69 10 f0       	push   $0xf0106903
f0101666:	68 02 03 00 00       	push   $0x302
f010166b:	68 dd 68 10 f0       	push   $0xf01068dd
f0101670:	e8 cb e9 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101675:	68 29 6a 10 f0       	push   $0xf0106a29
f010167a:	68 03 69 10 f0       	push   $0xf0106903
f010167f:	68 03 03 00 00       	push   $0x303
f0101684:	68 dd 68 10 f0       	push   $0xf01068dd
f0101689:	e8 b2 e9 ff ff       	call   f0100040 <_panic>
	assert(pp1 && pp1 != pp0);
f010168e:	68 3f 6a 10 f0       	push   $0xf0106a3f
f0101693:	68 03 69 10 f0       	push   $0xf0106903
f0101698:	68 06 03 00 00       	push   $0x306
f010169d:	68 dd 68 10 f0       	push   $0xf01068dd
f01016a2:	e8 99 e9 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01016a7:	68 68 6d 10 f0       	push   $0xf0106d68
f01016ac:	68 03 69 10 f0       	push   $0xf0106903
f01016b1:	68 07 03 00 00       	push   $0x307
f01016b6:	68 dd 68 10 f0       	push   $0xf01068dd
f01016bb:	e8 80 e9 ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp0) < npages*PGSIZE);
f01016c0:	68 51 6a 10 f0       	push   $0xf0106a51
f01016c5:	68 03 69 10 f0       	push   $0xf0106903
f01016ca:	68 08 03 00 00       	push   $0x308
f01016cf:	68 dd 68 10 f0       	push   $0xf01068dd
f01016d4:	e8 67 e9 ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f01016d9:	68 6e 6a 10 f0       	push   $0xf0106a6e
f01016de:	68 03 69 10 f0       	push   $0xf0106903
f01016e3:	68 09 03 00 00       	push   $0x309
f01016e8:	68 dd 68 10 f0       	push   $0xf01068dd
f01016ed:	e8 4e e9 ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f01016f2:	68 8b 6a 10 f0       	push   $0xf0106a8b
f01016f7:	68 03 69 10 f0       	push   $0xf0106903
f01016fc:	68 0a 03 00 00       	push   $0x30a
f0101701:	68 dd 68 10 f0       	push   $0xf01068dd
f0101706:	e8 35 e9 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f010170b:	68 a8 6a 10 f0       	push   $0xf0106aa8
f0101710:	68 03 69 10 f0       	push   $0xf0106903
f0101715:	68 11 03 00 00       	push   $0x311
f010171a:	68 dd 68 10 f0       	push   $0xf01068dd
f010171f:	e8 1c e9 ff ff       	call   f0100040 <_panic>
	assert((pp0 = page_alloc(0)));
f0101724:	68 fd 69 10 f0       	push   $0xf01069fd
f0101729:	68 03 69 10 f0       	push   $0xf0106903
f010172e:	68 18 03 00 00       	push   $0x318
f0101733:	68 dd 68 10 f0       	push   $0xf01068dd
f0101738:	e8 03 e9 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f010173d:	68 13 6a 10 f0       	push   $0xf0106a13
f0101742:	68 03 69 10 f0       	push   $0xf0106903
f0101747:	68 19 03 00 00       	push   $0x319
f010174c:	68 dd 68 10 f0       	push   $0xf01068dd
f0101751:	e8 ea e8 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101756:	68 29 6a 10 f0       	push   $0xf0106a29
f010175b:	68 03 69 10 f0       	push   $0xf0106903
f0101760:	68 1a 03 00 00       	push   $0x31a
f0101765:	68 dd 68 10 f0       	push   $0xf01068dd
f010176a:	e8 d1 e8 ff ff       	call   f0100040 <_panic>
	assert(pp1 && pp1 != pp0);
f010176f:	68 3f 6a 10 f0       	push   $0xf0106a3f
f0101774:	68 03 69 10 f0       	push   $0xf0106903
f0101779:	68 1c 03 00 00       	push   $0x31c
f010177e:	68 dd 68 10 f0       	push   $0xf01068dd
f0101783:	e8 b8 e8 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101788:	68 68 6d 10 f0       	push   $0xf0106d68
f010178d:	68 03 69 10 f0       	push   $0xf0106903
f0101792:	68 1d 03 00 00       	push   $0x31d
f0101797:	68 dd 68 10 f0       	push   $0xf01068dd
f010179c:	e8 9f e8 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f01017a1:	68 a8 6a 10 f0       	push   $0xf0106aa8
f01017a6:	68 03 69 10 f0       	push   $0xf0106903
f01017ab:	68 1e 03 00 00       	push   $0x31e
f01017b0:	68 dd 68 10 f0       	push   $0xf01068dd
f01017b5:	e8 86 e8 ff ff       	call   f0100040 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01017ba:	52                   	push   %edx
f01017bb:	68 a4 63 10 f0       	push   $0xf01063a4
f01017c0:	6a 58                	push   $0x58
f01017c2:	68 e9 68 10 f0       	push   $0xf01068e9
f01017c7:	e8 74 e8 ff ff       	call   f0100040 <_panic>
	assert((pp = page_alloc(ALLOC_ZERO)));
f01017cc:	68 b7 6a 10 f0       	push   $0xf0106ab7
f01017d1:	68 03 69 10 f0       	push   $0xf0106903
f01017d6:	68 23 03 00 00       	push   $0x323
f01017db:	68 dd 68 10 f0       	push   $0xf01068dd
f01017e0:	e8 5b e8 ff ff       	call   f0100040 <_panic>
	assert(pp && pp0 == pp);
f01017e5:	68 d5 6a 10 f0       	push   $0xf0106ad5
f01017ea:	68 03 69 10 f0       	push   $0xf0106903
f01017ef:	68 24 03 00 00       	push   $0x324
f01017f4:	68 dd 68 10 f0       	push   $0xf01068dd
f01017f9:	e8 42 e8 ff ff       	call   f0100040 <_panic>
f01017fe:	52                   	push   %edx
f01017ff:	68 a4 63 10 f0       	push   $0xf01063a4
f0101804:	6a 58                	push   $0x58
f0101806:	68 e9 68 10 f0       	push   $0xf01068e9
f010180b:	e8 30 e8 ff ff       	call   f0100040 <_panic>
		assert(c[i] == 0);
f0101810:	68 e5 6a 10 f0       	push   $0xf0106ae5
f0101815:	68 03 69 10 f0       	push   $0xf0106903
f010181a:	68 27 03 00 00       	push   $0x327
f010181f:	68 dd 68 10 f0       	push   $0xf01068dd
f0101824:	e8 17 e8 ff ff       	call   f0100040 <_panic>
	assert(nfree == 0);
f0101829:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f010182d:	0f 85 39 09 00 00    	jne    f010216c <mem_init+0xea4>
	cprintf("check_page_alloc() succeeded!\n");
f0101833:	83 ec 0c             	sub    $0xc,%esp
f0101836:	68 88 6d 10 f0       	push   $0xf0106d88
f010183b:	e8 9e 20 00 00       	call   f01038de <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101840:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101847:	e8 ba f6 ff ff       	call   f0100f06 <page_alloc>
f010184c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010184f:	83 c4 10             	add    $0x10,%esp
f0101852:	85 c0                	test   %eax,%eax
f0101854:	0f 84 2b 09 00 00    	je     f0102185 <mem_init+0xebd>
	assert((pp1 = page_alloc(0)));
f010185a:	83 ec 0c             	sub    $0xc,%esp
f010185d:	6a 00                	push   $0x0
f010185f:	e8 a2 f6 ff ff       	call   f0100f06 <page_alloc>
f0101864:	89 c7                	mov    %eax,%edi
f0101866:	83 c4 10             	add    $0x10,%esp
f0101869:	85 c0                	test   %eax,%eax
f010186b:	0f 84 2d 09 00 00    	je     f010219e <mem_init+0xed6>
	assert((pp2 = page_alloc(0)));
f0101871:	83 ec 0c             	sub    $0xc,%esp
f0101874:	6a 00                	push   $0x0
f0101876:	e8 8b f6 ff ff       	call   f0100f06 <page_alloc>
f010187b:	89 c3                	mov    %eax,%ebx
f010187d:	83 c4 10             	add    $0x10,%esp
f0101880:	85 c0                	test   %eax,%eax
f0101882:	0f 84 2f 09 00 00    	je     f01021b7 <mem_init+0xeef>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101888:	39 7d d4             	cmp    %edi,-0x2c(%ebp)
f010188b:	0f 84 3f 09 00 00    	je     f01021d0 <mem_init+0xf08>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101891:	39 c7                	cmp    %eax,%edi
f0101893:	0f 84 50 09 00 00    	je     f01021e9 <mem_init+0xf21>
f0101899:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f010189c:	0f 84 47 09 00 00    	je     f01021e9 <mem_init+0xf21>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f01018a2:	a1 40 62 23 f0       	mov    0xf0236240,%eax
f01018a7:	89 45 cc             	mov    %eax,-0x34(%ebp)
	page_free_list = 0;
f01018aa:	c7 05 40 62 23 f0 00 	movl   $0x0,0xf0236240
f01018b1:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f01018b4:	83 ec 0c             	sub    $0xc,%esp
f01018b7:	6a 00                	push   $0x0
f01018b9:	e8 48 f6 ff ff       	call   f0100f06 <page_alloc>
f01018be:	83 c4 10             	add    $0x10,%esp
f01018c1:	85 c0                	test   %eax,%eax
f01018c3:	0f 85 39 09 00 00    	jne    f0102202 <mem_init+0xf3a>


	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f01018c9:	83 ec 04             	sub    $0x4,%esp
f01018cc:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01018cf:	50                   	push   %eax
f01018d0:	6a 00                	push   $0x0
f01018d2:	ff 35 8c 6e 23 f0    	pushl  0xf0236e8c
f01018d8:	e8 06 f8 ff ff       	call   f01010e3 <page_lookup>
f01018dd:	83 c4 10             	add    $0x10,%esp
f01018e0:	85 c0                	test   %eax,%eax
f01018e2:	0f 85 33 09 00 00    	jne    f010221b <mem_init+0xf53>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f01018e8:	6a 02                	push   $0x2
f01018ea:	6a 00                	push   $0x0
f01018ec:	57                   	push   %edi
f01018ed:	ff 35 8c 6e 23 f0    	pushl  0xf0236e8c
f01018f3:	e8 de f8 ff ff       	call   f01011d6 <page_insert>
f01018f8:	83 c4 10             	add    $0x10,%esp
f01018fb:	85 c0                	test   %eax,%eax
f01018fd:	0f 89 31 09 00 00    	jns    f0102234 <mem_init+0xf6c>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101903:	83 ec 0c             	sub    $0xc,%esp
f0101906:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101909:	e8 71 f6 ff ff       	call   f0100f7f <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f010190e:	6a 02                	push   $0x2
f0101910:	6a 00                	push   $0x0
f0101912:	57                   	push   %edi
f0101913:	ff 35 8c 6e 23 f0    	pushl  0xf0236e8c
f0101919:	e8 b8 f8 ff ff       	call   f01011d6 <page_insert>
f010191e:	83 c4 20             	add    $0x20,%esp
f0101921:	85 c0                	test   %eax,%eax
f0101923:	0f 85 24 09 00 00    	jne    f010224d <mem_init+0xf85>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101929:	8b 35 8c 6e 23 f0    	mov    0xf0236e8c,%esi
	return (pp - pages) << PGSHIFT;
f010192f:	8b 0d 90 6e 23 f0    	mov    0xf0236e90,%ecx
f0101935:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f0101938:	8b 16                	mov    (%esi),%edx
f010193a:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101940:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101943:	29 c8                	sub    %ecx,%eax
f0101945:	c1 f8 03             	sar    $0x3,%eax
f0101948:	c1 e0 0c             	shl    $0xc,%eax
f010194b:	39 c2                	cmp    %eax,%edx
f010194d:	0f 85 13 09 00 00    	jne    f0102266 <mem_init+0xf9e>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101953:	ba 00 00 00 00       	mov    $0x0,%edx
f0101958:	89 f0                	mov    %esi,%eax
f010195a:	e8 6f f1 ff ff       	call   f0100ace <check_va2pa>
f010195f:	89 c2                	mov    %eax,%edx
f0101961:	89 f8                	mov    %edi,%eax
f0101963:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0101966:	c1 f8 03             	sar    $0x3,%eax
f0101969:	c1 e0 0c             	shl    $0xc,%eax
f010196c:	39 c2                	cmp    %eax,%edx
f010196e:	0f 85 0b 09 00 00    	jne    f010227f <mem_init+0xfb7>
	assert(pp1->pp_ref == 1);
f0101974:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101979:	0f 85 19 09 00 00    	jne    f0102298 <mem_init+0xfd0>
	assert(pp0->pp_ref == 1);
f010197f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101982:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101987:	0f 85 24 09 00 00    	jne    f01022b1 <mem_init+0xfe9>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f010198d:	6a 02                	push   $0x2
f010198f:	68 00 10 00 00       	push   $0x1000
f0101994:	53                   	push   %ebx
f0101995:	56                   	push   %esi
f0101996:	e8 3b f8 ff ff       	call   f01011d6 <page_insert>
f010199b:	83 c4 10             	add    $0x10,%esp
f010199e:	85 c0                	test   %eax,%eax
f01019a0:	0f 85 24 09 00 00    	jne    f01022ca <mem_init+0x1002>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01019a6:	ba 00 10 00 00       	mov    $0x1000,%edx
f01019ab:	a1 8c 6e 23 f0       	mov    0xf0236e8c,%eax
f01019b0:	e8 19 f1 ff ff       	call   f0100ace <check_va2pa>
f01019b5:	89 c2                	mov    %eax,%edx
f01019b7:	89 d8                	mov    %ebx,%eax
f01019b9:	2b 05 90 6e 23 f0    	sub    0xf0236e90,%eax
f01019bf:	c1 f8 03             	sar    $0x3,%eax
f01019c2:	c1 e0 0c             	shl    $0xc,%eax
f01019c5:	39 c2                	cmp    %eax,%edx
f01019c7:	0f 85 16 09 00 00    	jne    f01022e3 <mem_init+0x101b>
	assert(pp2->pp_ref == 1);
f01019cd:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01019d2:	0f 85 24 09 00 00    	jne    f01022fc <mem_init+0x1034>

	// should be no free memory
	assert(!page_alloc(0));
f01019d8:	83 ec 0c             	sub    $0xc,%esp
f01019db:	6a 00                	push   $0x0
f01019dd:	e8 24 f5 ff ff       	call   f0100f06 <page_alloc>
f01019e2:	83 c4 10             	add    $0x10,%esp
f01019e5:	85 c0                	test   %eax,%eax
f01019e7:	0f 85 28 09 00 00    	jne    f0102315 <mem_init+0x104d>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01019ed:	6a 02                	push   $0x2
f01019ef:	68 00 10 00 00       	push   $0x1000
f01019f4:	53                   	push   %ebx
f01019f5:	ff 35 8c 6e 23 f0    	pushl  0xf0236e8c
f01019fb:	e8 d6 f7 ff ff       	call   f01011d6 <page_insert>
f0101a00:	83 c4 10             	add    $0x10,%esp
f0101a03:	85 c0                	test   %eax,%eax
f0101a05:	0f 85 23 09 00 00    	jne    f010232e <mem_init+0x1066>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101a0b:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101a10:	a1 8c 6e 23 f0       	mov    0xf0236e8c,%eax
f0101a15:	e8 b4 f0 ff ff       	call   f0100ace <check_va2pa>
f0101a1a:	89 c2                	mov    %eax,%edx
f0101a1c:	89 d8                	mov    %ebx,%eax
f0101a1e:	2b 05 90 6e 23 f0    	sub    0xf0236e90,%eax
f0101a24:	c1 f8 03             	sar    $0x3,%eax
f0101a27:	c1 e0 0c             	shl    $0xc,%eax
f0101a2a:	39 c2                	cmp    %eax,%edx
f0101a2c:	0f 85 15 09 00 00    	jne    f0102347 <mem_init+0x107f>
	assert(pp2->pp_ref == 1);
f0101a32:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101a37:	0f 85 23 09 00 00    	jne    f0102360 <mem_init+0x1098>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101a3d:	83 ec 0c             	sub    $0xc,%esp
f0101a40:	6a 00                	push   $0x0
f0101a42:	e8 bf f4 ff ff       	call   f0100f06 <page_alloc>
f0101a47:	83 c4 10             	add    $0x10,%esp
f0101a4a:	85 c0                	test   %eax,%eax
f0101a4c:	0f 85 27 09 00 00    	jne    f0102379 <mem_init+0x10b1>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101a52:	8b 0d 8c 6e 23 f0    	mov    0xf0236e8c,%ecx
f0101a58:	8b 01                	mov    (%ecx),%eax
f0101a5a:	89 c2                	mov    %eax,%edx
f0101a5c:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	if (PGNUM(pa) >= npages)
f0101a62:	c1 e8 0c             	shr    $0xc,%eax
f0101a65:	3b 05 88 6e 23 f0    	cmp    0xf0236e88,%eax
f0101a6b:	0f 83 21 09 00 00    	jae    f0102392 <mem_init+0x10ca>
	return (void *)(pa + KERNBASE);
f0101a71:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0101a77:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101a7a:	83 ec 04             	sub    $0x4,%esp
f0101a7d:	6a 00                	push   $0x0
f0101a7f:	68 00 10 00 00       	push   $0x1000
f0101a84:	51                   	push   %ecx
f0101a85:	e8 7c f5 ff ff       	call   f0101006 <pgdir_walk>
f0101a8a:	89 c2                	mov    %eax,%edx
f0101a8c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101a8f:	83 c0 04             	add    $0x4,%eax
f0101a92:	83 c4 10             	add    $0x10,%esp
f0101a95:	39 d0                	cmp    %edx,%eax
f0101a97:	0f 85 0a 09 00 00    	jne    f01023a7 <mem_init+0x10df>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101a9d:	6a 06                	push   $0x6
f0101a9f:	68 00 10 00 00       	push   $0x1000
f0101aa4:	53                   	push   %ebx
f0101aa5:	ff 35 8c 6e 23 f0    	pushl  0xf0236e8c
f0101aab:	e8 26 f7 ff ff       	call   f01011d6 <page_insert>
f0101ab0:	83 c4 10             	add    $0x10,%esp
f0101ab3:	85 c0                	test   %eax,%eax
f0101ab5:	0f 85 05 09 00 00    	jne    f01023c0 <mem_init+0x10f8>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101abb:	8b 35 8c 6e 23 f0    	mov    0xf0236e8c,%esi
f0101ac1:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101ac6:	89 f0                	mov    %esi,%eax
f0101ac8:	e8 01 f0 ff ff       	call   f0100ace <check_va2pa>
f0101acd:	89 c2                	mov    %eax,%edx
	return (pp - pages) << PGSHIFT;
f0101acf:	89 d8                	mov    %ebx,%eax
f0101ad1:	2b 05 90 6e 23 f0    	sub    0xf0236e90,%eax
f0101ad7:	c1 f8 03             	sar    $0x3,%eax
f0101ada:	c1 e0 0c             	shl    $0xc,%eax
f0101add:	39 c2                	cmp    %eax,%edx
f0101adf:	0f 85 f4 08 00 00    	jne    f01023d9 <mem_init+0x1111>
	assert(pp2->pp_ref == 1);
f0101ae5:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101aea:	0f 85 02 09 00 00    	jne    f01023f2 <mem_init+0x112a>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101af0:	83 ec 04             	sub    $0x4,%esp
f0101af3:	6a 00                	push   $0x0
f0101af5:	68 00 10 00 00       	push   $0x1000
f0101afa:	56                   	push   %esi
f0101afb:	e8 06 f5 ff ff       	call   f0101006 <pgdir_walk>
f0101b00:	83 c4 10             	add    $0x10,%esp
f0101b03:	f6 00 04             	testb  $0x4,(%eax)
f0101b06:	0f 84 ff 08 00 00    	je     f010240b <mem_init+0x1143>
	assert(kern_pgdir[0] & PTE_U);
f0101b0c:	a1 8c 6e 23 f0       	mov    0xf0236e8c,%eax
f0101b11:	f6 00 04             	testb  $0x4,(%eax)
f0101b14:	0f 84 0a 09 00 00    	je     f0102424 <mem_init+0x115c>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101b1a:	6a 02                	push   $0x2
f0101b1c:	68 00 10 00 00       	push   $0x1000
f0101b21:	53                   	push   %ebx
f0101b22:	50                   	push   %eax
f0101b23:	e8 ae f6 ff ff       	call   f01011d6 <page_insert>
f0101b28:	83 c4 10             	add    $0x10,%esp
f0101b2b:	85 c0                	test   %eax,%eax
f0101b2d:	0f 85 0a 09 00 00    	jne    f010243d <mem_init+0x1175>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101b33:	83 ec 04             	sub    $0x4,%esp
f0101b36:	6a 00                	push   $0x0
f0101b38:	68 00 10 00 00       	push   $0x1000
f0101b3d:	ff 35 8c 6e 23 f0    	pushl  0xf0236e8c
f0101b43:	e8 be f4 ff ff       	call   f0101006 <pgdir_walk>
f0101b48:	83 c4 10             	add    $0x10,%esp
f0101b4b:	f6 00 02             	testb  $0x2,(%eax)
f0101b4e:	0f 84 02 09 00 00    	je     f0102456 <mem_init+0x118e>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101b54:	83 ec 04             	sub    $0x4,%esp
f0101b57:	6a 00                	push   $0x0
f0101b59:	68 00 10 00 00       	push   $0x1000
f0101b5e:	ff 35 8c 6e 23 f0    	pushl  0xf0236e8c
f0101b64:	e8 9d f4 ff ff       	call   f0101006 <pgdir_walk>
f0101b69:	83 c4 10             	add    $0x10,%esp
f0101b6c:	f6 00 04             	testb  $0x4,(%eax)
f0101b6f:	0f 85 fa 08 00 00    	jne    f010246f <mem_init+0x11a7>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101b75:	6a 02                	push   $0x2
f0101b77:	68 00 00 40 00       	push   $0x400000
f0101b7c:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101b7f:	ff 35 8c 6e 23 f0    	pushl  0xf0236e8c
f0101b85:	e8 4c f6 ff ff       	call   f01011d6 <page_insert>
f0101b8a:	83 c4 10             	add    $0x10,%esp
f0101b8d:	85 c0                	test   %eax,%eax
f0101b8f:	0f 89 f3 08 00 00    	jns    f0102488 <mem_init+0x11c0>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101b95:	6a 02                	push   $0x2
f0101b97:	68 00 10 00 00       	push   $0x1000
f0101b9c:	57                   	push   %edi
f0101b9d:	ff 35 8c 6e 23 f0    	pushl  0xf0236e8c
f0101ba3:	e8 2e f6 ff ff       	call   f01011d6 <page_insert>
f0101ba8:	83 c4 10             	add    $0x10,%esp
f0101bab:	85 c0                	test   %eax,%eax
f0101bad:	0f 85 ee 08 00 00    	jne    f01024a1 <mem_init+0x11d9>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101bb3:	83 ec 04             	sub    $0x4,%esp
f0101bb6:	6a 00                	push   $0x0
f0101bb8:	68 00 10 00 00       	push   $0x1000
f0101bbd:	ff 35 8c 6e 23 f0    	pushl  0xf0236e8c
f0101bc3:	e8 3e f4 ff ff       	call   f0101006 <pgdir_walk>
f0101bc8:	83 c4 10             	add    $0x10,%esp
f0101bcb:	f6 00 04             	testb  $0x4,(%eax)
f0101bce:	0f 85 e6 08 00 00    	jne    f01024ba <mem_init+0x11f2>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0101bd4:	a1 8c 6e 23 f0       	mov    0xf0236e8c,%eax
f0101bd9:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101bdc:	ba 00 00 00 00       	mov    $0x0,%edx
f0101be1:	e8 e8 ee ff ff       	call   f0100ace <check_va2pa>
f0101be6:	89 fe                	mov    %edi,%esi
f0101be8:	2b 35 90 6e 23 f0    	sub    0xf0236e90,%esi
f0101bee:	c1 fe 03             	sar    $0x3,%esi
f0101bf1:	c1 e6 0c             	shl    $0xc,%esi
f0101bf4:	39 f0                	cmp    %esi,%eax
f0101bf6:	0f 85 d7 08 00 00    	jne    f01024d3 <mem_init+0x120b>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101bfc:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101c01:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101c04:	e8 c5 ee ff ff       	call   f0100ace <check_va2pa>
f0101c09:	39 c6                	cmp    %eax,%esi
f0101c0b:	0f 85 db 08 00 00    	jne    f01024ec <mem_init+0x1224>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0101c11:	66 83 7f 04 02       	cmpw   $0x2,0x4(%edi)
f0101c16:	0f 85 e9 08 00 00    	jne    f0102505 <mem_init+0x123d>
	assert(pp2->pp_ref == 0);
f0101c1c:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101c21:	0f 85 f7 08 00 00    	jne    f010251e <mem_init+0x1256>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0101c27:	83 ec 0c             	sub    $0xc,%esp
f0101c2a:	6a 00                	push   $0x0
f0101c2c:	e8 d5 f2 ff ff       	call   f0100f06 <page_alloc>
f0101c31:	83 c4 10             	add    $0x10,%esp
f0101c34:	39 c3                	cmp    %eax,%ebx
f0101c36:	0f 85 fb 08 00 00    	jne    f0102537 <mem_init+0x126f>
f0101c3c:	85 c0                	test   %eax,%eax
f0101c3e:	0f 84 f3 08 00 00    	je     f0102537 <mem_init+0x126f>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0101c44:	83 ec 08             	sub    $0x8,%esp
f0101c47:	6a 00                	push   $0x0
f0101c49:	ff 35 8c 6e 23 f0    	pushl  0xf0236e8c
f0101c4f:	e8 31 f5 ff ff       	call   f0101185 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101c54:	8b 35 8c 6e 23 f0    	mov    0xf0236e8c,%esi
f0101c5a:	ba 00 00 00 00       	mov    $0x0,%edx
f0101c5f:	89 f0                	mov    %esi,%eax
f0101c61:	e8 68 ee ff ff       	call   f0100ace <check_va2pa>
f0101c66:	83 c4 10             	add    $0x10,%esp
f0101c69:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101c6c:	0f 85 de 08 00 00    	jne    f0102550 <mem_init+0x1288>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101c72:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101c77:	89 f0                	mov    %esi,%eax
f0101c79:	e8 50 ee ff ff       	call   f0100ace <check_va2pa>
f0101c7e:	89 c2                	mov    %eax,%edx
f0101c80:	89 f8                	mov    %edi,%eax
f0101c82:	2b 05 90 6e 23 f0    	sub    0xf0236e90,%eax
f0101c88:	c1 f8 03             	sar    $0x3,%eax
f0101c8b:	c1 e0 0c             	shl    $0xc,%eax
f0101c8e:	39 c2                	cmp    %eax,%edx
f0101c90:	0f 85 d3 08 00 00    	jne    f0102569 <mem_init+0x12a1>
	assert(pp1->pp_ref == 1);
f0101c96:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101c9b:	0f 85 e1 08 00 00    	jne    f0102582 <mem_init+0x12ba>
	assert(pp2->pp_ref == 0);
f0101ca1:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101ca6:	0f 85 ef 08 00 00    	jne    f010259b <mem_init+0x12d3>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0101cac:	6a 00                	push   $0x0
f0101cae:	68 00 10 00 00       	push   $0x1000
f0101cb3:	57                   	push   %edi
f0101cb4:	56                   	push   %esi
f0101cb5:	e8 1c f5 ff ff       	call   f01011d6 <page_insert>
f0101cba:	83 c4 10             	add    $0x10,%esp
f0101cbd:	85 c0                	test   %eax,%eax
f0101cbf:	0f 85 ef 08 00 00    	jne    f01025b4 <mem_init+0x12ec>
	assert(pp1->pp_ref);
f0101cc5:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0101cca:	0f 84 fd 08 00 00    	je     f01025cd <mem_init+0x1305>
	assert(pp1->pp_link == NULL);
f0101cd0:	83 3f 00             	cmpl   $0x0,(%edi)
f0101cd3:	0f 85 0d 09 00 00    	jne    f01025e6 <mem_init+0x131e>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0101cd9:	83 ec 08             	sub    $0x8,%esp
f0101cdc:	68 00 10 00 00       	push   $0x1000
f0101ce1:	ff 35 8c 6e 23 f0    	pushl  0xf0236e8c
f0101ce7:	e8 99 f4 ff ff       	call   f0101185 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101cec:	8b 35 8c 6e 23 f0    	mov    0xf0236e8c,%esi
f0101cf2:	ba 00 00 00 00       	mov    $0x0,%edx
f0101cf7:	89 f0                	mov    %esi,%eax
f0101cf9:	e8 d0 ed ff ff       	call   f0100ace <check_va2pa>
f0101cfe:	83 c4 10             	add    $0x10,%esp
f0101d01:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101d04:	0f 85 f5 08 00 00    	jne    f01025ff <mem_init+0x1337>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0101d0a:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101d0f:	89 f0                	mov    %esi,%eax
f0101d11:	e8 b8 ed ff ff       	call   f0100ace <check_va2pa>
f0101d16:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101d19:	0f 85 f9 08 00 00    	jne    f0102618 <mem_init+0x1350>
	assert(pp1->pp_ref == 0);
f0101d1f:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0101d24:	0f 85 07 09 00 00    	jne    f0102631 <mem_init+0x1369>
	assert(pp2->pp_ref == 0);
f0101d2a:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101d2f:	0f 85 15 09 00 00    	jne    f010264a <mem_init+0x1382>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0101d35:	83 ec 0c             	sub    $0xc,%esp
f0101d38:	6a 00                	push   $0x0
f0101d3a:	e8 c7 f1 ff ff       	call   f0100f06 <page_alloc>
f0101d3f:	83 c4 10             	add    $0x10,%esp
f0101d42:	85 c0                	test   %eax,%eax
f0101d44:	0f 84 19 09 00 00    	je     f0102663 <mem_init+0x139b>
f0101d4a:	39 c7                	cmp    %eax,%edi
f0101d4c:	0f 85 11 09 00 00    	jne    f0102663 <mem_init+0x139b>

	// should be no free memory
	assert(!page_alloc(0));
f0101d52:	83 ec 0c             	sub    $0xc,%esp
f0101d55:	6a 00                	push   $0x0
f0101d57:	e8 aa f1 ff ff       	call   f0100f06 <page_alloc>
f0101d5c:	83 c4 10             	add    $0x10,%esp
f0101d5f:	85 c0                	test   %eax,%eax
f0101d61:	0f 85 15 09 00 00    	jne    f010267c <mem_init+0x13b4>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101d67:	8b 0d 8c 6e 23 f0    	mov    0xf0236e8c,%ecx
f0101d6d:	8b 11                	mov    (%ecx),%edx
f0101d6f:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101d75:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101d78:	2b 05 90 6e 23 f0    	sub    0xf0236e90,%eax
f0101d7e:	c1 f8 03             	sar    $0x3,%eax
f0101d81:	c1 e0 0c             	shl    $0xc,%eax
f0101d84:	39 c2                	cmp    %eax,%edx
f0101d86:	0f 85 09 09 00 00    	jne    f0102695 <mem_init+0x13cd>
	kern_pgdir[0] = 0;
f0101d8c:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0101d92:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101d95:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101d9a:	0f 85 0e 09 00 00    	jne    f01026ae <mem_init+0x13e6>
	pp0->pp_ref = 0;
f0101da0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101da3:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0101da9:	83 ec 0c             	sub    $0xc,%esp
f0101dac:	50                   	push   %eax
f0101dad:	e8 cd f1 ff ff       	call   f0100f7f <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0101db2:	83 c4 0c             	add    $0xc,%esp
f0101db5:	6a 01                	push   $0x1
f0101db7:	68 00 10 40 00       	push   $0x401000
f0101dbc:	ff 35 8c 6e 23 f0    	pushl  0xf0236e8c
f0101dc2:	e8 3f f2 ff ff       	call   f0101006 <pgdir_walk>
f0101dc7:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101dca:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0101dcd:	8b 0d 8c 6e 23 f0    	mov    0xf0236e8c,%ecx
f0101dd3:	8b 41 04             	mov    0x4(%ecx),%eax
f0101dd6:	89 c6                	mov    %eax,%esi
f0101dd8:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	if (PGNUM(pa) >= npages)
f0101dde:	8b 15 88 6e 23 f0    	mov    0xf0236e88,%edx
f0101de4:	c1 e8 0c             	shr    $0xc,%eax
f0101de7:	83 c4 10             	add    $0x10,%esp
f0101dea:	39 d0                	cmp    %edx,%eax
f0101dec:	0f 83 d5 08 00 00    	jae    f01026c7 <mem_init+0x13ff>
	assert(ptep == ptep1 + PTX(va));
f0101df2:	81 ee fc ff ff 0f    	sub    $0xffffffc,%esi
f0101df8:	39 75 d0             	cmp    %esi,-0x30(%ebp)
f0101dfb:	0f 85 db 08 00 00    	jne    f01026dc <mem_init+0x1414>
	kern_pgdir[PDX(va)] = 0;
f0101e01:	c7 41 04 00 00 00 00 	movl   $0x0,0x4(%ecx)
	pp0->pp_ref = 0;
f0101e08:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101e0b:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
	return (pp - pages) << PGSHIFT;
f0101e11:	2b 05 90 6e 23 f0    	sub    0xf0236e90,%eax
f0101e17:	c1 f8 03             	sar    $0x3,%eax
f0101e1a:	89 c1                	mov    %eax,%ecx
f0101e1c:	c1 e1 0c             	shl    $0xc,%ecx
	if (PGNUM(pa) >= npages)
f0101e1f:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0101e24:	39 c2                	cmp    %eax,%edx
f0101e26:	0f 86 c9 08 00 00    	jbe    f01026f5 <mem_init+0x142d>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0101e2c:	83 ec 04             	sub    $0x4,%esp
f0101e2f:	68 00 10 00 00       	push   $0x1000
f0101e34:	68 ff 00 00 00       	push   $0xff
	return (void *)(pa + KERNBASE);
f0101e39:	81 e9 00 00 00 10    	sub    $0x10000000,%ecx
f0101e3f:	51                   	push   %ecx
f0101e40:	e8 9f 38 00 00       	call   f01056e4 <memset>
	page_free(pp0);
f0101e45:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f0101e48:	89 34 24             	mov    %esi,(%esp)
f0101e4b:	e8 2f f1 ff ff       	call   f0100f7f <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0101e50:	83 c4 0c             	add    $0xc,%esp
f0101e53:	6a 01                	push   $0x1
f0101e55:	6a 00                	push   $0x0
f0101e57:	ff 35 8c 6e 23 f0    	pushl  0xf0236e8c
f0101e5d:	e8 a4 f1 ff ff       	call   f0101006 <pgdir_walk>
	return (pp - pages) << PGSHIFT;
f0101e62:	89 f0                	mov    %esi,%eax
f0101e64:	2b 05 90 6e 23 f0    	sub    0xf0236e90,%eax
f0101e6a:	c1 f8 03             	sar    $0x3,%eax
f0101e6d:	89 c2                	mov    %eax,%edx
f0101e6f:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0101e72:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0101e77:	83 c4 10             	add    $0x10,%esp
f0101e7a:	3b 05 88 6e 23 f0    	cmp    0xf0236e88,%eax
f0101e80:	0f 83 81 08 00 00    	jae    f0102707 <mem_init+0x143f>
	return (void *)(pa + KERNBASE);
f0101e86:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f0101e8c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0101e8f:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0101e95:	f6 00 01             	testb  $0x1,(%eax)
f0101e98:	0f 85 7b 08 00 00    	jne    f0102719 <mem_init+0x1451>
f0101e9e:	83 c0 04             	add    $0x4,%eax
	for(i=0; i<NPTENTRIES; i++)
f0101ea1:	39 d0                	cmp    %edx,%eax
f0101ea3:	75 f0                	jne    f0101e95 <mem_init+0xbcd>
	kern_pgdir[0] = 0;
f0101ea5:	a1 8c 6e 23 f0       	mov    0xf0236e8c,%eax
f0101eaa:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0101eb0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101eb3:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// give free list back
	page_free_list = fl;
f0101eb9:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0101ebc:	89 0d 40 62 23 f0    	mov    %ecx,0xf0236240

	// free the pages we took
	page_free(pp0);
f0101ec2:	83 ec 0c             	sub    $0xc,%esp
f0101ec5:	50                   	push   %eax
f0101ec6:	e8 b4 f0 ff ff       	call   f0100f7f <page_free>
	page_free(pp1);
f0101ecb:	89 3c 24             	mov    %edi,(%esp)
f0101ece:	e8 ac f0 ff ff       	call   f0100f7f <page_free>
	page_free(pp2);
f0101ed3:	89 1c 24             	mov    %ebx,(%esp)
f0101ed6:	e8 a4 f0 ff ff       	call   f0100f7f <page_free>

	// test mmio_map_region
	mm1 = (uintptr_t) mmio_map_region(0, 4097);
f0101edb:	83 c4 08             	add    $0x8,%esp
f0101ede:	68 01 10 00 00       	push   $0x1001
f0101ee3:	6a 00                	push   $0x0
f0101ee5:	e8 62 f3 ff ff       	call   f010124c <mmio_map_region>
f0101eea:	89 c3                	mov    %eax,%ebx
	mm2 = (uintptr_t) mmio_map_region(0, 4096);
f0101eec:	83 c4 08             	add    $0x8,%esp
f0101eef:	68 00 10 00 00       	push   $0x1000
f0101ef4:	6a 00                	push   $0x0
f0101ef6:	e8 51 f3 ff ff       	call   f010124c <mmio_map_region>
f0101efb:	89 c6                	mov    %eax,%esi
	// check that they're in the right region
	assert(mm1 >= MMIOBASE && mm1 + 8192 < MMIOLIM);
f0101efd:	8d 83 00 20 00 00    	lea    0x2000(%ebx),%eax
f0101f03:	83 c4 10             	add    $0x10,%esp
f0101f06:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0101f0c:	0f 86 20 08 00 00    	jbe    f0102732 <mem_init+0x146a>
f0101f12:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f0101f17:	0f 87 15 08 00 00    	ja     f0102732 <mem_init+0x146a>
	assert(mm2 >= MMIOBASE && mm2 + 8192 < MMIOLIM);
f0101f1d:	8d 96 00 20 00 00    	lea    0x2000(%esi),%edx
f0101f23:	81 fa ff ff bf ef    	cmp    $0xefbfffff,%edx
f0101f29:	0f 87 1c 08 00 00    	ja     f010274b <mem_init+0x1483>
f0101f2f:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0101f35:	0f 86 10 08 00 00    	jbe    f010274b <mem_init+0x1483>
	// check that they're page-aligned
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f0101f3b:	89 da                	mov    %ebx,%edx
f0101f3d:	09 f2                	or     %esi,%edx
f0101f3f:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
f0101f45:	0f 85 19 08 00 00    	jne    f0102764 <mem_init+0x149c>
	// check that they don't overlap
	assert(mm1 + 8192 <= mm2);
f0101f4b:	39 c6                	cmp    %eax,%esi
f0101f4d:	0f 82 2a 08 00 00    	jb     f010277d <mem_init+0x14b5>
	// check page mappings
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f0101f53:	8b 3d 8c 6e 23 f0    	mov    0xf0236e8c,%edi
f0101f59:	89 da                	mov    %ebx,%edx
f0101f5b:	89 f8                	mov    %edi,%eax
f0101f5d:	e8 6c eb ff ff       	call   f0100ace <check_va2pa>
f0101f62:	85 c0                	test   %eax,%eax
f0101f64:	0f 85 2c 08 00 00    	jne    f0102796 <mem_init+0x14ce>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f0101f6a:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
f0101f70:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101f73:	89 c2                	mov    %eax,%edx
f0101f75:	89 f8                	mov    %edi,%eax
f0101f77:	e8 52 eb ff ff       	call   f0100ace <check_va2pa>
f0101f7c:	3d 00 10 00 00       	cmp    $0x1000,%eax
f0101f81:	0f 85 28 08 00 00    	jne    f01027af <mem_init+0x14e7>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f0101f87:	89 f2                	mov    %esi,%edx
f0101f89:	89 f8                	mov    %edi,%eax
f0101f8b:	e8 3e eb ff ff       	call   f0100ace <check_va2pa>
f0101f90:	85 c0                	test   %eax,%eax
f0101f92:	0f 85 30 08 00 00    	jne    f01027c8 <mem_init+0x1500>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f0101f98:	8d 96 00 10 00 00    	lea    0x1000(%esi),%edx
f0101f9e:	89 f8                	mov    %edi,%eax
f0101fa0:	e8 29 eb ff ff       	call   f0100ace <check_va2pa>
f0101fa5:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101fa8:	0f 85 33 08 00 00    	jne    f01027e1 <mem_init+0x1519>
	// check permissions
	assert(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
f0101fae:	83 ec 04             	sub    $0x4,%esp
f0101fb1:	6a 00                	push   $0x0
f0101fb3:	53                   	push   %ebx
f0101fb4:	57                   	push   %edi
f0101fb5:	e8 4c f0 ff ff       	call   f0101006 <pgdir_walk>
f0101fba:	83 c4 10             	add    $0x10,%esp
f0101fbd:	f6 00 1a             	testb  $0x1a,(%eax)
f0101fc0:	0f 84 34 08 00 00    	je     f01027fa <mem_init+0x1532>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f0101fc6:	83 ec 04             	sub    $0x4,%esp
f0101fc9:	6a 00                	push   $0x0
f0101fcb:	53                   	push   %ebx
f0101fcc:	ff 35 8c 6e 23 f0    	pushl  0xf0236e8c
f0101fd2:	e8 2f f0 ff ff       	call   f0101006 <pgdir_walk>
f0101fd7:	8b 00                	mov    (%eax),%eax
f0101fd9:	83 c4 10             	add    $0x10,%esp
f0101fdc:	83 e0 04             	and    $0x4,%eax
f0101fdf:	89 c7                	mov    %eax,%edi
f0101fe1:	0f 85 2c 08 00 00    	jne    f0102813 <mem_init+0x154b>
	// clear the mappings
	*pgdir_walk(kern_pgdir, (void*) mm1, 0) = 0;
f0101fe7:	83 ec 04             	sub    $0x4,%esp
f0101fea:	6a 00                	push   $0x0
f0101fec:	53                   	push   %ebx
f0101fed:	ff 35 8c 6e 23 f0    	pushl  0xf0236e8c
f0101ff3:	e8 0e f0 ff ff       	call   f0101006 <pgdir_walk>
f0101ff8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm1 + PGSIZE, 0) = 0;
f0101ffe:	83 c4 0c             	add    $0xc,%esp
f0102001:	6a 00                	push   $0x0
f0102003:	ff 75 d4             	pushl  -0x2c(%ebp)
f0102006:	ff 35 8c 6e 23 f0    	pushl  0xf0236e8c
f010200c:	e8 f5 ef ff ff       	call   f0101006 <pgdir_walk>
f0102011:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm2, 0) = 0;
f0102017:	83 c4 0c             	add    $0xc,%esp
f010201a:	6a 00                	push   $0x0
f010201c:	56                   	push   %esi
f010201d:	ff 35 8c 6e 23 f0    	pushl  0xf0236e8c
f0102023:	e8 de ef ff ff       	call   f0101006 <pgdir_walk>
f0102028:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	cprintf("check_page() succeeded!\n");
f010202e:	c7 04 24 d8 6b 10 f0 	movl   $0xf0106bd8,(%esp)
f0102035:	e8 a4 18 00 00       	call   f01038de <cprintf>
	boot_map_region(kern_pgdir, UPAGES, PTSIZE, page2pa(pages), PTE_U);
f010203a:	83 c4 08             	add    $0x8,%esp
f010203d:	6a 04                	push   $0x4
f010203f:	6a 00                	push   $0x0
f0102041:	b9 00 00 40 00       	mov    $0x400000,%ecx
f0102046:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f010204b:	a1 8c 6e 23 f0       	mov    0xf0236e8c,%eax
f0102050:	e8 42 f0 ff ff       	call   f0101097 <boot_map_region>
	boot_map_region(kern_pgdir, UENVS, PTSIZE, PADDR(envs), PTE_U);
f0102055:	a1 44 62 23 f0       	mov    0xf0236244,%eax
	if ((uint32_t)kva < KERNBASE)
f010205a:	83 c4 10             	add    $0x10,%esp
f010205d:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102062:	0f 86 c4 07 00 00    	jbe    f010282c <mem_init+0x1564>
f0102068:	83 ec 08             	sub    $0x8,%esp
f010206b:	6a 04                	push   $0x4
	return (physaddr_t)kva - KERNBASE;
f010206d:	05 00 00 00 10       	add    $0x10000000,%eax
f0102072:	50                   	push   %eax
f0102073:	b9 00 00 40 00       	mov    $0x400000,%ecx
f0102078:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f010207d:	a1 8c 6e 23 f0       	mov    0xf0236e8c,%eax
f0102082:	e8 10 f0 ff ff       	call   f0101097 <boot_map_region>
	if ((uint32_t)kva < KERNBASE)
f0102087:	83 c4 10             	add    $0x10,%esp
f010208a:	b8 00 80 11 f0       	mov    $0xf0118000,%eax
f010208f:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102094:	0f 86 a7 07 00 00    	jbe    f0102841 <mem_init+0x1579>
	boot_map_region(kern_pgdir, KSTACKTOP-KSTKSIZE, KSTKSIZE, PADDR(bootstack), PTE_W);
f010209a:	83 ec 08             	sub    $0x8,%esp
f010209d:	6a 02                	push   $0x2
f010209f:	68 00 80 11 00       	push   $0x118000
f01020a4:	b9 00 80 00 00       	mov    $0x8000,%ecx
f01020a9:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f01020ae:	a1 8c 6e 23 f0       	mov    0xf0236e8c,%eax
f01020b3:	e8 df ef ff ff       	call   f0101097 <boot_map_region>
	boot_map_region(kern_pgdir, KERNBASE, 0xffffffff-KERNBASE, 0, PTE_W);
f01020b8:	83 c4 08             	add    $0x8,%esp
f01020bb:	6a 02                	push   $0x2
f01020bd:	6a 00                	push   $0x0
f01020bf:	b9 ff ff ff 0f       	mov    $0xfffffff,%ecx
f01020c4:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f01020c9:	a1 8c 6e 23 f0       	mov    0xf0236e8c,%eax
f01020ce:	e8 c4 ef ff ff       	call   f0101097 <boot_map_region>
f01020d3:	c7 45 d0 00 80 23 f0 	movl   $0xf0238000,-0x30(%ebp)
f01020da:	83 c4 10             	add    $0x10,%esp
f01020dd:	bb 00 80 23 f0       	mov    $0xf0238000,%ebx
f01020e2:	be 00 80 ff ef       	mov    $0xefff8000,%esi
f01020e7:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f01020ed:	0f 86 63 07 00 00    	jbe    f0102856 <mem_init+0x158e>
		boot_map_region(kern_pgdir, 
f01020f3:	83 ec 08             	sub    $0x8,%esp
f01020f6:	6a 02                	push   $0x2
f01020f8:	8d 83 00 00 00 10    	lea    0x10000000(%ebx),%eax
f01020fe:	50                   	push   %eax
f01020ff:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102104:	89 f2                	mov    %esi,%edx
f0102106:	a1 8c 6e 23 f0       	mov    0xf0236e8c,%eax
f010210b:	e8 87 ef ff ff       	call   f0101097 <boot_map_region>
f0102110:	81 c3 00 80 00 00    	add    $0x8000,%ebx
f0102116:	81 ee 00 00 01 00    	sub    $0x10000,%esi
	for(int i = 0; i<NCPU;++i){
f010211c:	83 c4 10             	add    $0x10,%esp
f010211f:	81 fb 00 80 27 f0    	cmp    $0xf0278000,%ebx
f0102125:	75 c0                	jne    f01020e7 <mem_init+0xe1f>
	pgdir = kern_pgdir;
f0102127:	a1 8c 6e 23 f0       	mov    0xf0236e8c,%eax
f010212c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f010212f:	a1 88 6e 23 f0       	mov    0xf0236e88,%eax
f0102134:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0102137:	8d 34 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%esi
f010213e:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	for (i = 0; i < n; i += PGSIZE)
f0102144:	89 fb                	mov    %edi,%ebx
f0102146:	39 de                	cmp    %ebx,%esi
f0102148:	0f 86 36 07 00 00    	jbe    f0102884 <mem_init+0x15bc>
		assert(check_va2pa(pgdir, UPAGES + i) == page2pa(pages) + i);
f010214e:	8d 93 00 00 00 ef    	lea    -0x11000000(%ebx),%edx
f0102154:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102157:	e8 72 e9 ff ff       	call   f0100ace <check_va2pa>
f010215c:	39 c3                	cmp    %eax,%ebx
f010215e:	0f 85 07 07 00 00    	jne    f010286b <mem_init+0x15a3>
	for (i = 0; i < n; i += PGSIZE)
f0102164:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f010216a:	eb da                	jmp    f0102146 <mem_init+0xe7e>
	assert(nfree == 0);
f010216c:	68 ef 6a 10 f0       	push   $0xf0106aef
f0102171:	68 03 69 10 f0       	push   $0xf0106903
f0102176:	68 34 03 00 00       	push   $0x334
f010217b:	68 dd 68 10 f0       	push   $0xf01068dd
f0102180:	e8 bb de ff ff       	call   f0100040 <_panic>
	assert((pp0 = page_alloc(0)));
f0102185:	68 fd 69 10 f0       	push   $0xf01069fd
f010218a:	68 03 69 10 f0       	push   $0xf0106903
f010218f:	68 99 03 00 00       	push   $0x399
f0102194:	68 dd 68 10 f0       	push   $0xf01068dd
f0102199:	e8 a2 de ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f010219e:	68 13 6a 10 f0       	push   $0xf0106a13
f01021a3:	68 03 69 10 f0       	push   $0xf0106903
f01021a8:	68 9a 03 00 00       	push   $0x39a
f01021ad:	68 dd 68 10 f0       	push   $0xf01068dd
f01021b2:	e8 89 de ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f01021b7:	68 29 6a 10 f0       	push   $0xf0106a29
f01021bc:	68 03 69 10 f0       	push   $0xf0106903
f01021c1:	68 9b 03 00 00       	push   $0x39b
f01021c6:	68 dd 68 10 f0       	push   $0xf01068dd
f01021cb:	e8 70 de ff ff       	call   f0100040 <_panic>
	assert(pp1 && pp1 != pp0);
f01021d0:	68 3f 6a 10 f0       	push   $0xf0106a3f
f01021d5:	68 03 69 10 f0       	push   $0xf0106903
f01021da:	68 9e 03 00 00       	push   $0x39e
f01021df:	68 dd 68 10 f0       	push   $0xf01068dd
f01021e4:	e8 57 de ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01021e9:	68 68 6d 10 f0       	push   $0xf0106d68
f01021ee:	68 03 69 10 f0       	push   $0xf0106903
f01021f3:	68 9f 03 00 00       	push   $0x39f
f01021f8:	68 dd 68 10 f0       	push   $0xf01068dd
f01021fd:	e8 3e de ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f0102202:	68 a8 6a 10 f0       	push   $0xf0106aa8
f0102207:	68 03 69 10 f0       	push   $0xf0106903
f010220c:	68 a6 03 00 00       	push   $0x3a6
f0102211:	68 dd 68 10 f0       	push   $0xf01068dd
f0102216:	e8 25 de ff ff       	call   f0100040 <_panic>
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f010221b:	68 a8 6d 10 f0       	push   $0xf0106da8
f0102220:	68 03 69 10 f0       	push   $0xf0106903
f0102225:	68 aa 03 00 00       	push   $0x3aa
f010222a:	68 dd 68 10 f0       	push   $0xf01068dd
f010222f:	e8 0c de ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0102234:	68 e0 6d 10 f0       	push   $0xf0106de0
f0102239:	68 03 69 10 f0       	push   $0xf0106903
f010223e:	68 ad 03 00 00       	push   $0x3ad
f0102243:	68 dd 68 10 f0       	push   $0xf01068dd
f0102248:	e8 f3 dd ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f010224d:	68 10 6e 10 f0       	push   $0xf0106e10
f0102252:	68 03 69 10 f0       	push   $0xf0106903
f0102257:	68 b1 03 00 00       	push   $0x3b1
f010225c:	68 dd 68 10 f0       	push   $0xf01068dd
f0102261:	e8 da dd ff ff       	call   f0100040 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102266:	68 40 6e 10 f0       	push   $0xf0106e40
f010226b:	68 03 69 10 f0       	push   $0xf0106903
f0102270:	68 b2 03 00 00       	push   $0x3b2
f0102275:	68 dd 68 10 f0       	push   $0xf01068dd
f010227a:	e8 c1 dd ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f010227f:	68 68 6e 10 f0       	push   $0xf0106e68
f0102284:	68 03 69 10 f0       	push   $0xf0106903
f0102289:	68 b3 03 00 00       	push   $0x3b3
f010228e:	68 dd 68 10 f0       	push   $0xf01068dd
f0102293:	e8 a8 dd ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f0102298:	68 fa 6a 10 f0       	push   $0xf0106afa
f010229d:	68 03 69 10 f0       	push   $0xf0106903
f01022a2:	68 b4 03 00 00       	push   $0x3b4
f01022a7:	68 dd 68 10 f0       	push   $0xf01068dd
f01022ac:	e8 8f dd ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f01022b1:	68 0b 6b 10 f0       	push   $0xf0106b0b
f01022b6:	68 03 69 10 f0       	push   $0xf0106903
f01022bb:	68 b5 03 00 00       	push   $0x3b5
f01022c0:	68 dd 68 10 f0       	push   $0xf01068dd
f01022c5:	e8 76 dd ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01022ca:	68 98 6e 10 f0       	push   $0xf0106e98
f01022cf:	68 03 69 10 f0       	push   $0xf0106903
f01022d4:	68 b8 03 00 00       	push   $0x3b8
f01022d9:	68 dd 68 10 f0       	push   $0xf01068dd
f01022de:	e8 5d dd ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01022e3:	68 d4 6e 10 f0       	push   $0xf0106ed4
f01022e8:	68 03 69 10 f0       	push   $0xf0106903
f01022ed:	68 b9 03 00 00       	push   $0x3b9
f01022f2:	68 dd 68 10 f0       	push   $0xf01068dd
f01022f7:	e8 44 dd ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f01022fc:	68 1c 6b 10 f0       	push   $0xf0106b1c
f0102301:	68 03 69 10 f0       	push   $0xf0106903
f0102306:	68 ba 03 00 00       	push   $0x3ba
f010230b:	68 dd 68 10 f0       	push   $0xf01068dd
f0102310:	e8 2b dd ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f0102315:	68 a8 6a 10 f0       	push   $0xf0106aa8
f010231a:	68 03 69 10 f0       	push   $0xf0106903
f010231f:	68 bd 03 00 00       	push   $0x3bd
f0102324:	68 dd 68 10 f0       	push   $0xf01068dd
f0102329:	e8 12 dd ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f010232e:	68 98 6e 10 f0       	push   $0xf0106e98
f0102333:	68 03 69 10 f0       	push   $0xf0106903
f0102338:	68 c0 03 00 00       	push   $0x3c0
f010233d:	68 dd 68 10 f0       	push   $0xf01068dd
f0102342:	e8 f9 dc ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102347:	68 d4 6e 10 f0       	push   $0xf0106ed4
f010234c:	68 03 69 10 f0       	push   $0xf0106903
f0102351:	68 c1 03 00 00       	push   $0x3c1
f0102356:	68 dd 68 10 f0       	push   $0xf01068dd
f010235b:	e8 e0 dc ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0102360:	68 1c 6b 10 f0       	push   $0xf0106b1c
f0102365:	68 03 69 10 f0       	push   $0xf0106903
f010236a:	68 c2 03 00 00       	push   $0x3c2
f010236f:	68 dd 68 10 f0       	push   $0xf01068dd
f0102374:	e8 c7 dc ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f0102379:	68 a8 6a 10 f0       	push   $0xf0106aa8
f010237e:	68 03 69 10 f0       	push   $0xf0106903
f0102383:	68 c6 03 00 00       	push   $0x3c6
f0102388:	68 dd 68 10 f0       	push   $0xf01068dd
f010238d:	e8 ae dc ff ff       	call   f0100040 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102392:	52                   	push   %edx
f0102393:	68 a4 63 10 f0       	push   $0xf01063a4
f0102398:	68 c9 03 00 00       	push   $0x3c9
f010239d:	68 dd 68 10 f0       	push   $0xf01068dd
f01023a2:	e8 99 dc ff ff       	call   f0100040 <_panic>
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f01023a7:	68 04 6f 10 f0       	push   $0xf0106f04
f01023ac:	68 03 69 10 f0       	push   $0xf0106903
f01023b1:	68 ca 03 00 00       	push   $0x3ca
f01023b6:	68 dd 68 10 f0       	push   $0xf01068dd
f01023bb:	e8 80 dc ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f01023c0:	68 44 6f 10 f0       	push   $0xf0106f44
f01023c5:	68 03 69 10 f0       	push   $0xf0106903
f01023ca:	68 cd 03 00 00       	push   $0x3cd
f01023cf:	68 dd 68 10 f0       	push   $0xf01068dd
f01023d4:	e8 67 dc ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01023d9:	68 d4 6e 10 f0       	push   $0xf0106ed4
f01023de:	68 03 69 10 f0       	push   $0xf0106903
f01023e3:	68 ce 03 00 00       	push   $0x3ce
f01023e8:	68 dd 68 10 f0       	push   $0xf01068dd
f01023ed:	e8 4e dc ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f01023f2:	68 1c 6b 10 f0       	push   $0xf0106b1c
f01023f7:	68 03 69 10 f0       	push   $0xf0106903
f01023fc:	68 cf 03 00 00       	push   $0x3cf
f0102401:	68 dd 68 10 f0       	push   $0xf01068dd
f0102406:	e8 35 dc ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f010240b:	68 84 6f 10 f0       	push   $0xf0106f84
f0102410:	68 03 69 10 f0       	push   $0xf0106903
f0102415:	68 d0 03 00 00       	push   $0x3d0
f010241a:	68 dd 68 10 f0       	push   $0xf01068dd
f010241f:	e8 1c dc ff ff       	call   f0100040 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0102424:	68 2d 6b 10 f0       	push   $0xf0106b2d
f0102429:	68 03 69 10 f0       	push   $0xf0106903
f010242e:	68 d1 03 00 00       	push   $0x3d1
f0102433:	68 dd 68 10 f0       	push   $0xf01068dd
f0102438:	e8 03 dc ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f010243d:	68 98 6e 10 f0       	push   $0xf0106e98
f0102442:	68 03 69 10 f0       	push   $0xf0106903
f0102447:	68 d4 03 00 00       	push   $0x3d4
f010244c:	68 dd 68 10 f0       	push   $0xf01068dd
f0102451:	e8 ea db ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0102456:	68 b8 6f 10 f0       	push   $0xf0106fb8
f010245b:	68 03 69 10 f0       	push   $0xf0106903
f0102460:	68 d5 03 00 00       	push   $0x3d5
f0102465:	68 dd 68 10 f0       	push   $0xf01068dd
f010246a:	e8 d1 db ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f010246f:	68 ec 6f 10 f0       	push   $0xf0106fec
f0102474:	68 03 69 10 f0       	push   $0xf0106903
f0102479:	68 d6 03 00 00       	push   $0x3d6
f010247e:	68 dd 68 10 f0       	push   $0xf01068dd
f0102483:	e8 b8 db ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0102488:	68 24 70 10 f0       	push   $0xf0107024
f010248d:	68 03 69 10 f0       	push   $0xf0106903
f0102492:	68 d9 03 00 00       	push   $0x3d9
f0102497:	68 dd 68 10 f0       	push   $0xf01068dd
f010249c:	e8 9f db ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f01024a1:	68 5c 70 10 f0       	push   $0xf010705c
f01024a6:	68 03 69 10 f0       	push   $0xf0106903
f01024ab:	68 dc 03 00 00       	push   $0x3dc
f01024b0:	68 dd 68 10 f0       	push   $0xf01068dd
f01024b5:	e8 86 db ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01024ba:	68 ec 6f 10 f0       	push   $0xf0106fec
f01024bf:	68 03 69 10 f0       	push   $0xf0106903
f01024c4:	68 dd 03 00 00       	push   $0x3dd
f01024c9:	68 dd 68 10 f0       	push   $0xf01068dd
f01024ce:	e8 6d db ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f01024d3:	68 98 70 10 f0       	push   $0xf0107098
f01024d8:	68 03 69 10 f0       	push   $0xf0106903
f01024dd:	68 e0 03 00 00       	push   $0x3e0
f01024e2:	68 dd 68 10 f0       	push   $0xf01068dd
f01024e7:	e8 54 db ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f01024ec:	68 c4 70 10 f0       	push   $0xf01070c4
f01024f1:	68 03 69 10 f0       	push   $0xf0106903
f01024f6:	68 e1 03 00 00       	push   $0x3e1
f01024fb:	68 dd 68 10 f0       	push   $0xf01068dd
f0102500:	e8 3b db ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 2);
f0102505:	68 43 6b 10 f0       	push   $0xf0106b43
f010250a:	68 03 69 10 f0       	push   $0xf0106903
f010250f:	68 e3 03 00 00       	push   $0x3e3
f0102514:	68 dd 68 10 f0       	push   $0xf01068dd
f0102519:	e8 22 db ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f010251e:	68 54 6b 10 f0       	push   $0xf0106b54
f0102523:	68 03 69 10 f0       	push   $0xf0106903
f0102528:	68 e4 03 00 00       	push   $0x3e4
f010252d:	68 dd 68 10 f0       	push   $0xf01068dd
f0102532:	e8 09 db ff ff       	call   f0100040 <_panic>
	assert((pp = page_alloc(0)) && pp == pp2);
f0102537:	68 f4 70 10 f0       	push   $0xf01070f4
f010253c:	68 03 69 10 f0       	push   $0xf0106903
f0102541:	68 e7 03 00 00       	push   $0x3e7
f0102546:	68 dd 68 10 f0       	push   $0xf01068dd
f010254b:	e8 f0 da ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102550:	68 18 71 10 f0       	push   $0xf0107118
f0102555:	68 03 69 10 f0       	push   $0xf0106903
f010255a:	68 eb 03 00 00       	push   $0x3eb
f010255f:	68 dd 68 10 f0       	push   $0xf01068dd
f0102564:	e8 d7 da ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102569:	68 c4 70 10 f0       	push   $0xf01070c4
f010256e:	68 03 69 10 f0       	push   $0xf0106903
f0102573:	68 ec 03 00 00       	push   $0x3ec
f0102578:	68 dd 68 10 f0       	push   $0xf01068dd
f010257d:	e8 be da ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f0102582:	68 fa 6a 10 f0       	push   $0xf0106afa
f0102587:	68 03 69 10 f0       	push   $0xf0106903
f010258c:	68 ed 03 00 00       	push   $0x3ed
f0102591:	68 dd 68 10 f0       	push   $0xf01068dd
f0102596:	e8 a5 da ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f010259b:	68 54 6b 10 f0       	push   $0xf0106b54
f01025a0:	68 03 69 10 f0       	push   $0xf0106903
f01025a5:	68 ee 03 00 00       	push   $0x3ee
f01025aa:	68 dd 68 10 f0       	push   $0xf01068dd
f01025af:	e8 8c da ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f01025b4:	68 3c 71 10 f0       	push   $0xf010713c
f01025b9:	68 03 69 10 f0       	push   $0xf0106903
f01025be:	68 f1 03 00 00       	push   $0x3f1
f01025c3:	68 dd 68 10 f0       	push   $0xf01068dd
f01025c8:	e8 73 da ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref);
f01025cd:	68 65 6b 10 f0       	push   $0xf0106b65
f01025d2:	68 03 69 10 f0       	push   $0xf0106903
f01025d7:	68 f2 03 00 00       	push   $0x3f2
f01025dc:	68 dd 68 10 f0       	push   $0xf01068dd
f01025e1:	e8 5a da ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_link == NULL);
f01025e6:	68 71 6b 10 f0       	push   $0xf0106b71
f01025eb:	68 03 69 10 f0       	push   $0xf0106903
f01025f0:	68 f3 03 00 00       	push   $0x3f3
f01025f5:	68 dd 68 10 f0       	push   $0xf01068dd
f01025fa:	e8 41 da ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01025ff:	68 18 71 10 f0       	push   $0xf0107118
f0102604:	68 03 69 10 f0       	push   $0xf0106903
f0102609:	68 f7 03 00 00       	push   $0x3f7
f010260e:	68 dd 68 10 f0       	push   $0xf01068dd
f0102613:	e8 28 da ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0102618:	68 74 71 10 f0       	push   $0xf0107174
f010261d:	68 03 69 10 f0       	push   $0xf0106903
f0102622:	68 f8 03 00 00       	push   $0x3f8
f0102627:	68 dd 68 10 f0       	push   $0xf01068dd
f010262c:	e8 0f da ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f0102631:	68 86 6b 10 f0       	push   $0xf0106b86
f0102636:	68 03 69 10 f0       	push   $0xf0106903
f010263b:	68 f9 03 00 00       	push   $0x3f9
f0102640:	68 dd 68 10 f0       	push   $0xf01068dd
f0102645:	e8 f6 d9 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f010264a:	68 54 6b 10 f0       	push   $0xf0106b54
f010264f:	68 03 69 10 f0       	push   $0xf0106903
f0102654:	68 fa 03 00 00       	push   $0x3fa
f0102659:	68 dd 68 10 f0       	push   $0xf01068dd
f010265e:	e8 dd d9 ff ff       	call   f0100040 <_panic>
	assert((pp = page_alloc(0)) && pp == pp1);
f0102663:	68 9c 71 10 f0       	push   $0xf010719c
f0102668:	68 03 69 10 f0       	push   $0xf0106903
f010266d:	68 fd 03 00 00       	push   $0x3fd
f0102672:	68 dd 68 10 f0       	push   $0xf01068dd
f0102677:	e8 c4 d9 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f010267c:	68 a8 6a 10 f0       	push   $0xf0106aa8
f0102681:	68 03 69 10 f0       	push   $0xf0106903
f0102686:	68 00 04 00 00       	push   $0x400
f010268b:	68 dd 68 10 f0       	push   $0xf01068dd
f0102690:	e8 ab d9 ff ff       	call   f0100040 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102695:	68 40 6e 10 f0       	push   $0xf0106e40
f010269a:	68 03 69 10 f0       	push   $0xf0106903
f010269f:	68 03 04 00 00       	push   $0x403
f01026a4:	68 dd 68 10 f0       	push   $0xf01068dd
f01026a9:	e8 92 d9 ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f01026ae:	68 0b 6b 10 f0       	push   $0xf0106b0b
f01026b3:	68 03 69 10 f0       	push   $0xf0106903
f01026b8:	68 05 04 00 00       	push   $0x405
f01026bd:	68 dd 68 10 f0       	push   $0xf01068dd
f01026c2:	e8 79 d9 ff ff       	call   f0100040 <_panic>
f01026c7:	56                   	push   %esi
f01026c8:	68 a4 63 10 f0       	push   $0xf01063a4
f01026cd:	68 0c 04 00 00       	push   $0x40c
f01026d2:	68 dd 68 10 f0       	push   $0xf01068dd
f01026d7:	e8 64 d9 ff ff       	call   f0100040 <_panic>
	assert(ptep == ptep1 + PTX(va));
f01026dc:	68 97 6b 10 f0       	push   $0xf0106b97
f01026e1:	68 03 69 10 f0       	push   $0xf0106903
f01026e6:	68 0d 04 00 00       	push   $0x40d
f01026eb:	68 dd 68 10 f0       	push   $0xf01068dd
f01026f0:	e8 4b d9 ff ff       	call   f0100040 <_panic>
f01026f5:	51                   	push   %ecx
f01026f6:	68 a4 63 10 f0       	push   $0xf01063a4
f01026fb:	6a 58                	push   $0x58
f01026fd:	68 e9 68 10 f0       	push   $0xf01068e9
f0102702:	e8 39 d9 ff ff       	call   f0100040 <_panic>
f0102707:	52                   	push   %edx
f0102708:	68 a4 63 10 f0       	push   $0xf01063a4
f010270d:	6a 58                	push   $0x58
f010270f:	68 e9 68 10 f0       	push   $0xf01068e9
f0102714:	e8 27 d9 ff ff       	call   f0100040 <_panic>
		assert((ptep[i] & PTE_P) == 0);
f0102719:	68 af 6b 10 f0       	push   $0xf0106baf
f010271e:	68 03 69 10 f0       	push   $0xf0106903
f0102723:	68 17 04 00 00       	push   $0x417
f0102728:	68 dd 68 10 f0       	push   $0xf01068dd
f010272d:	e8 0e d9 ff ff       	call   f0100040 <_panic>
	assert(mm1 >= MMIOBASE && mm1 + 8192 < MMIOLIM);
f0102732:	68 c0 71 10 f0       	push   $0xf01071c0
f0102737:	68 03 69 10 f0       	push   $0xf0106903
f010273c:	68 27 04 00 00       	push   $0x427
f0102741:	68 dd 68 10 f0       	push   $0xf01068dd
f0102746:	e8 f5 d8 ff ff       	call   f0100040 <_panic>
	assert(mm2 >= MMIOBASE && mm2 + 8192 < MMIOLIM);
f010274b:	68 e8 71 10 f0       	push   $0xf01071e8
f0102750:	68 03 69 10 f0       	push   $0xf0106903
f0102755:	68 28 04 00 00       	push   $0x428
f010275a:	68 dd 68 10 f0       	push   $0xf01068dd
f010275f:	e8 dc d8 ff ff       	call   f0100040 <_panic>
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f0102764:	68 10 72 10 f0       	push   $0xf0107210
f0102769:	68 03 69 10 f0       	push   $0xf0106903
f010276e:	68 2a 04 00 00       	push   $0x42a
f0102773:	68 dd 68 10 f0       	push   $0xf01068dd
f0102778:	e8 c3 d8 ff ff       	call   f0100040 <_panic>
	assert(mm1 + 8192 <= mm2);
f010277d:	68 c6 6b 10 f0       	push   $0xf0106bc6
f0102782:	68 03 69 10 f0       	push   $0xf0106903
f0102787:	68 2c 04 00 00       	push   $0x42c
f010278c:	68 dd 68 10 f0       	push   $0xf01068dd
f0102791:	e8 aa d8 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f0102796:	68 38 72 10 f0       	push   $0xf0107238
f010279b:	68 03 69 10 f0       	push   $0xf0106903
f01027a0:	68 2e 04 00 00       	push   $0x42e
f01027a5:	68 dd 68 10 f0       	push   $0xf01068dd
f01027aa:	e8 91 d8 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f01027af:	68 5c 72 10 f0       	push   $0xf010725c
f01027b4:	68 03 69 10 f0       	push   $0xf0106903
f01027b9:	68 2f 04 00 00       	push   $0x42f
f01027be:	68 dd 68 10 f0       	push   $0xf01068dd
f01027c3:	e8 78 d8 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f01027c8:	68 8c 72 10 f0       	push   $0xf010728c
f01027cd:	68 03 69 10 f0       	push   $0xf0106903
f01027d2:	68 30 04 00 00       	push   $0x430
f01027d7:	68 dd 68 10 f0       	push   $0xf01068dd
f01027dc:	e8 5f d8 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f01027e1:	68 b0 72 10 f0       	push   $0xf01072b0
f01027e6:	68 03 69 10 f0       	push   $0xf0106903
f01027eb:	68 31 04 00 00       	push   $0x431
f01027f0:	68 dd 68 10 f0       	push   $0xf01068dd
f01027f5:	e8 46 d8 ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
f01027fa:	68 dc 72 10 f0       	push   $0xf01072dc
f01027ff:	68 03 69 10 f0       	push   $0xf0106903
f0102804:	68 33 04 00 00       	push   $0x433
f0102809:	68 dd 68 10 f0       	push   $0xf01068dd
f010280e:	e8 2d d8 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f0102813:	68 20 73 10 f0       	push   $0xf0107320
f0102818:	68 03 69 10 f0       	push   $0xf0106903
f010281d:	68 34 04 00 00       	push   $0x434
f0102822:	68 dd 68 10 f0       	push   $0xf01068dd
f0102827:	e8 14 d8 ff ff       	call   f0100040 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010282c:	50                   	push   %eax
f010282d:	68 c8 63 10 f0       	push   $0xf01063c8
f0102832:	68 c7 00 00 00       	push   $0xc7
f0102837:	68 dd 68 10 f0       	push   $0xf01068dd
f010283c:	e8 ff d7 ff ff       	call   f0100040 <_panic>
f0102841:	50                   	push   %eax
f0102842:	68 c8 63 10 f0       	push   $0xf01063c8
f0102847:	68 d4 00 00 00       	push   $0xd4
f010284c:	68 dd 68 10 f0       	push   $0xf01068dd
f0102851:	e8 ea d7 ff ff       	call   f0100040 <_panic>
f0102856:	53                   	push   %ebx
f0102857:	68 c8 63 10 f0       	push   $0xf01063c8
f010285c:	68 16 01 00 00       	push   $0x116
f0102861:	68 dd 68 10 f0       	push   $0xf01068dd
f0102866:	e8 d5 d7 ff ff       	call   f0100040 <_panic>
		assert(check_va2pa(pgdir, UPAGES + i) == page2pa(pages) + i);
f010286b:	68 54 73 10 f0       	push   $0xf0107354
f0102870:	68 03 69 10 f0       	push   $0xf0106903
f0102875:	68 4c 03 00 00       	push   $0x34c
f010287a:	68 dd 68 10 f0       	push   $0xf01068dd
f010287f:	e8 bc d7 ff ff       	call   f0100040 <_panic>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102884:	a1 44 62 23 f0       	mov    0xf0236244,%eax
f0102889:	89 45 c4             	mov    %eax,-0x3c(%ebp)
	if ((uint32_t)kva < KERNBASE)
f010288c:	89 45 cc             	mov    %eax,-0x34(%ebp)
f010288f:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
f0102894:	8d b0 00 00 40 21    	lea    0x21400000(%eax),%esi
f010289a:	89 da                	mov    %ebx,%edx
f010289c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010289f:	e8 2a e2 ff ff       	call   f0100ace <check_va2pa>
f01028a4:	81 7d cc ff ff ff ef 	cmpl   $0xefffffff,-0x34(%ebp)
f01028ab:	76 3b                	jbe    f01028e8 <mem_init+0x1620>
f01028ad:	8d 14 1e             	lea    (%esi,%ebx,1),%edx
f01028b0:	39 d0                	cmp    %edx,%eax
f01028b2:	75 4b                	jne    f01028ff <mem_init+0x1637>
f01028b4:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (i = 0; i < n; i += PGSIZE)
f01028ba:	81 fb 00 f0 c1 ee    	cmp    $0xeec1f000,%ebx
f01028c0:	75 d8                	jne    f010289a <mem_init+0x15d2>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f01028c2:	8b 75 c8             	mov    -0x38(%ebp),%esi
f01028c5:	c1 e6 0c             	shl    $0xc,%esi
f01028c8:	89 fb                	mov    %edi,%ebx
f01028ca:	39 f3                	cmp    %esi,%ebx
f01028cc:	73 63                	jae    f0102931 <mem_init+0x1669>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f01028ce:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
f01028d4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01028d7:	e8 f2 e1 ff ff       	call   f0100ace <check_va2pa>
f01028dc:	39 c3                	cmp    %eax,%ebx
f01028de:	75 38                	jne    f0102918 <mem_init+0x1650>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f01028e0:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01028e6:	eb e2                	jmp    f01028ca <mem_init+0x1602>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01028e8:	ff 75 c4             	pushl  -0x3c(%ebp)
f01028eb:	68 c8 63 10 f0       	push   $0xf01063c8
f01028f0:	68 51 03 00 00       	push   $0x351
f01028f5:	68 dd 68 10 f0       	push   $0xf01068dd
f01028fa:	e8 41 d7 ff ff       	call   f0100040 <_panic>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f01028ff:	68 8c 73 10 f0       	push   $0xf010738c
f0102904:	68 03 69 10 f0       	push   $0xf0106903
f0102909:	68 51 03 00 00       	push   $0x351
f010290e:	68 dd 68 10 f0       	push   $0xf01068dd
f0102913:	e8 28 d7 ff ff       	call   f0100040 <_panic>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102918:	68 c0 73 10 f0       	push   $0xf01073c0
f010291d:	68 03 69 10 f0       	push   $0xf0106903
f0102922:	68 55 03 00 00       	push   $0x355
f0102927:	68 dd 68 10 f0       	push   $0xf01068dd
f010292c:	e8 0f d7 ff ff       	call   f0100040 <_panic>
f0102931:	c7 45 cc 00 80 24 00 	movl   $0x248000,-0x34(%ebp)
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102938:	bb 00 80 ff ef       	mov    $0xefff8000,%ebx
f010293d:	89 7d c0             	mov    %edi,-0x40(%ebp)
f0102940:	8d bb 00 80 ff ff    	lea    -0x8000(%ebx),%edi
			assert(check_va2pa(pgdir, base + KSTKGAP + i) == PADDR(percpu_kstacks[n]) + i);
f0102946:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102949:	89 45 bc             	mov    %eax,-0x44(%ebp)
f010294c:	89 de                	mov    %ebx,%esi
f010294e:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0102951:	05 00 80 ff 0f       	add    $0xfff8000,%eax
f0102956:	89 45 c8             	mov    %eax,-0x38(%ebp)
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102959:	8d 83 00 80 00 00    	lea    0x8000(%ebx),%eax
f010295f:	89 45 c4             	mov    %eax,-0x3c(%ebp)
			assert(check_va2pa(pgdir, base + KSTKGAP + i) == PADDR(percpu_kstacks[n]) + i);
f0102962:	89 f2                	mov    %esi,%edx
f0102964:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102967:	e8 62 e1 ff ff       	call   f0100ace <check_va2pa>
	if ((uint32_t)kva < KERNBASE)
f010296c:	81 7d d0 ff ff ff ef 	cmpl   $0xefffffff,-0x30(%ebp)
f0102973:	76 58                	jbe    f01029cd <mem_init+0x1705>
f0102975:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0102978:	8d 14 31             	lea    (%ecx,%esi,1),%edx
f010297b:	39 d0                	cmp    %edx,%eax
f010297d:	75 65                	jne    f01029e4 <mem_init+0x171c>
f010297f:	81 c6 00 10 00 00    	add    $0x1000,%esi
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102985:	3b 75 c4             	cmp    -0x3c(%ebp),%esi
f0102988:	75 d8                	jne    f0102962 <mem_init+0x169a>
			assert(check_va2pa(pgdir, base + i) == ~0);
f010298a:	89 fa                	mov    %edi,%edx
f010298c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010298f:	e8 3a e1 ff ff       	call   f0100ace <check_va2pa>
f0102994:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102997:	75 64                	jne    f01029fd <mem_init+0x1735>
f0102999:	81 c7 00 10 00 00    	add    $0x1000,%edi
		for (i = 0; i < KSTKGAP; i += PGSIZE)
f010299f:	39 df                	cmp    %ebx,%edi
f01029a1:	75 e7                	jne    f010298a <mem_init+0x16c2>
f01029a3:	81 eb 00 00 01 00    	sub    $0x10000,%ebx
f01029a9:	81 45 d0 00 80 00 00 	addl   $0x8000,-0x30(%ebp)
f01029b0:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01029b3:	81 45 cc 00 80 01 00 	addl   $0x18000,-0x34(%ebp)
	for (n = 0; n < NCPU; n++) {
f01029ba:	3d 00 80 27 f0       	cmp    $0xf0278000,%eax
f01029bf:	0f 85 7b ff ff ff    	jne    f0102940 <mem_init+0x1678>
f01029c5:	8b 7d c0             	mov    -0x40(%ebp),%edi
f01029c8:	e9 84 00 00 00       	jmp    f0102a51 <mem_init+0x1789>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01029cd:	ff 75 bc             	pushl  -0x44(%ebp)
f01029d0:	68 c8 63 10 f0       	push   $0xf01063c8
f01029d5:	68 5c 03 00 00       	push   $0x35c
f01029da:	68 dd 68 10 f0       	push   $0xf01068dd
f01029df:	e8 5c d6 ff ff       	call   f0100040 <_panic>
			assert(check_va2pa(pgdir, base + KSTKGAP + i) == PADDR(percpu_kstacks[n]) + i);
f01029e4:	68 e8 73 10 f0       	push   $0xf01073e8
f01029e9:	68 03 69 10 f0       	push   $0xf0106903
f01029ee:	68 5c 03 00 00       	push   $0x35c
f01029f3:	68 dd 68 10 f0       	push   $0xf01068dd
f01029f8:	e8 43 d6 ff ff       	call   f0100040 <_panic>
			assert(check_va2pa(pgdir, base + i) == ~0);
f01029fd:	68 30 74 10 f0       	push   $0xf0107430
f0102a02:	68 03 69 10 f0       	push   $0xf0106903
f0102a07:	68 5e 03 00 00       	push   $0x35e
f0102a0c:	68 dd 68 10 f0       	push   $0xf01068dd
f0102a11:	e8 2a d6 ff ff       	call   f0100040 <_panic>
			assert(pgdir[i] & PTE_P);
f0102a16:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102a19:	f6 04 b8 01          	testb  $0x1,(%eax,%edi,4)
f0102a1d:	75 4e                	jne    f0102a6d <mem_init+0x17a5>
f0102a1f:	68 f1 6b 10 f0       	push   $0xf0106bf1
f0102a24:	68 03 69 10 f0       	push   $0xf0106903
f0102a29:	68 69 03 00 00       	push   $0x369
f0102a2e:	68 dd 68 10 f0       	push   $0xf01068dd
f0102a33:	e8 08 d6 ff ff       	call   f0100040 <_panic>
				assert(pgdir[i] & PTE_P);
f0102a38:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102a3b:	8b 04 b8             	mov    (%eax,%edi,4),%eax
f0102a3e:	a8 01                	test   $0x1,%al
f0102a40:	74 30                	je     f0102a72 <mem_init+0x17aa>
				assert(pgdir[i] & PTE_W);
f0102a42:	a8 02                	test   $0x2,%al
f0102a44:	74 45                	je     f0102a8b <mem_init+0x17c3>
	for (i = 0; i < NPDENTRIES; i++) {
f0102a46:	83 c7 01             	add    $0x1,%edi
f0102a49:	81 ff 00 04 00 00    	cmp    $0x400,%edi
f0102a4f:	74 6c                	je     f0102abd <mem_init+0x17f5>
		switch (i) {
f0102a51:	8d 87 45 fc ff ff    	lea    -0x3bb(%edi),%eax
f0102a57:	83 f8 04             	cmp    $0x4,%eax
f0102a5a:	76 ba                	jbe    f0102a16 <mem_init+0x174e>
			if (i >= PDX(KERNBASE)) {
f0102a5c:	81 ff bf 03 00 00    	cmp    $0x3bf,%edi
f0102a62:	77 d4                	ja     f0102a38 <mem_init+0x1770>
				assert(pgdir[i] == 0);
f0102a64:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102a67:	83 3c b8 00          	cmpl   $0x0,(%eax,%edi,4)
f0102a6b:	75 37                	jne    f0102aa4 <mem_init+0x17dc>
	for (i = 0; i < NPDENTRIES; i++) {
f0102a6d:	83 c7 01             	add    $0x1,%edi
f0102a70:	eb df                	jmp    f0102a51 <mem_init+0x1789>
				assert(pgdir[i] & PTE_P);
f0102a72:	68 f1 6b 10 f0       	push   $0xf0106bf1
f0102a77:	68 03 69 10 f0       	push   $0xf0106903
f0102a7c:	68 6d 03 00 00       	push   $0x36d
f0102a81:	68 dd 68 10 f0       	push   $0xf01068dd
f0102a86:	e8 b5 d5 ff ff       	call   f0100040 <_panic>
				assert(pgdir[i] & PTE_W);
f0102a8b:	68 02 6c 10 f0       	push   $0xf0106c02
f0102a90:	68 03 69 10 f0       	push   $0xf0106903
f0102a95:	68 6e 03 00 00       	push   $0x36e
f0102a9a:	68 dd 68 10 f0       	push   $0xf01068dd
f0102a9f:	e8 9c d5 ff ff       	call   f0100040 <_panic>
				assert(pgdir[i] == 0);
f0102aa4:	68 13 6c 10 f0       	push   $0xf0106c13
f0102aa9:	68 03 69 10 f0       	push   $0xf0106903
f0102aae:	68 70 03 00 00       	push   $0x370
f0102ab3:	68 dd 68 10 f0       	push   $0xf01068dd
f0102ab8:	e8 83 d5 ff ff       	call   f0100040 <_panic>
	cprintf("check_kern_pgdir() succeeded!\n");
f0102abd:	83 ec 0c             	sub    $0xc,%esp
f0102ac0:	68 54 74 10 f0       	push   $0xf0107454
f0102ac5:	e8 14 0e 00 00       	call   f01038de <cprintf>
	lcr3(PADDR(kern_pgdir));
f0102aca:	a1 8c 6e 23 f0       	mov    0xf0236e8c,%eax
	if ((uint32_t)kva < KERNBASE)
f0102acf:	83 c4 10             	add    $0x10,%esp
f0102ad2:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102ad7:	0f 86 03 02 00 00    	jbe    f0102ce0 <mem_init+0x1a18>
	return (physaddr_t)kva - KERNBASE;
f0102add:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0102ae2:	0f 22 d8             	mov    %eax,%cr3
	check_page_free_list(0);
f0102ae5:	b8 00 00 00 00       	mov    $0x0,%eax
f0102aea:	e8 42 e0 ff ff       	call   f0100b31 <check_page_free_list>
	asm volatile("movl %%cr0,%0" : "=r" (val));
f0102aef:	0f 20 c0             	mov    %cr0,%eax
	cr0 &= ~(CR0_TS|CR0_EM);
f0102af2:	83 e0 f3             	and    $0xfffffff3,%eax
f0102af5:	0d 23 00 05 80       	or     $0x80050023,%eax
	asm volatile("movl %0,%%cr0" : : "r" (val));
f0102afa:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102afd:	83 ec 0c             	sub    $0xc,%esp
f0102b00:	6a 00                	push   $0x0
f0102b02:	e8 ff e3 ff ff       	call   f0100f06 <page_alloc>
f0102b07:	89 c6                	mov    %eax,%esi
f0102b09:	83 c4 10             	add    $0x10,%esp
f0102b0c:	85 c0                	test   %eax,%eax
f0102b0e:	0f 84 e1 01 00 00    	je     f0102cf5 <mem_init+0x1a2d>
	assert((pp1 = page_alloc(0)));
f0102b14:	83 ec 0c             	sub    $0xc,%esp
f0102b17:	6a 00                	push   $0x0
f0102b19:	e8 e8 e3 ff ff       	call   f0100f06 <page_alloc>
f0102b1e:	89 c7                	mov    %eax,%edi
f0102b20:	83 c4 10             	add    $0x10,%esp
f0102b23:	85 c0                	test   %eax,%eax
f0102b25:	0f 84 e3 01 00 00    	je     f0102d0e <mem_init+0x1a46>
	assert((pp2 = page_alloc(0)));
f0102b2b:	83 ec 0c             	sub    $0xc,%esp
f0102b2e:	6a 00                	push   $0x0
f0102b30:	e8 d1 e3 ff ff       	call   f0100f06 <page_alloc>
f0102b35:	89 c3                	mov    %eax,%ebx
f0102b37:	83 c4 10             	add    $0x10,%esp
f0102b3a:	85 c0                	test   %eax,%eax
f0102b3c:	0f 84 e5 01 00 00    	je     f0102d27 <mem_init+0x1a5f>
	page_free(pp0);
f0102b42:	83 ec 0c             	sub    $0xc,%esp
f0102b45:	56                   	push   %esi
f0102b46:	e8 34 e4 ff ff       	call   f0100f7f <page_free>
	return (pp - pages) << PGSHIFT;
f0102b4b:	89 f8                	mov    %edi,%eax
f0102b4d:	2b 05 90 6e 23 f0    	sub    0xf0236e90,%eax
f0102b53:	c1 f8 03             	sar    $0x3,%eax
f0102b56:	89 c2                	mov    %eax,%edx
f0102b58:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0102b5b:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0102b60:	83 c4 10             	add    $0x10,%esp
f0102b63:	3b 05 88 6e 23 f0    	cmp    0xf0236e88,%eax
f0102b69:	0f 83 d1 01 00 00    	jae    f0102d40 <mem_init+0x1a78>
	memset(page2kva(pp1), 1, PGSIZE);
f0102b6f:	83 ec 04             	sub    $0x4,%esp
f0102b72:	68 00 10 00 00       	push   $0x1000
f0102b77:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f0102b79:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0102b7f:	52                   	push   %edx
f0102b80:	e8 5f 2b 00 00       	call   f01056e4 <memset>
	return (pp - pages) << PGSHIFT;
f0102b85:	89 d8                	mov    %ebx,%eax
f0102b87:	2b 05 90 6e 23 f0    	sub    0xf0236e90,%eax
f0102b8d:	c1 f8 03             	sar    $0x3,%eax
f0102b90:	89 c2                	mov    %eax,%edx
f0102b92:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0102b95:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0102b9a:	83 c4 10             	add    $0x10,%esp
f0102b9d:	3b 05 88 6e 23 f0    	cmp    0xf0236e88,%eax
f0102ba3:	0f 83 a9 01 00 00    	jae    f0102d52 <mem_init+0x1a8a>
	memset(page2kva(pp2), 2, PGSIZE);
f0102ba9:	83 ec 04             	sub    $0x4,%esp
f0102bac:	68 00 10 00 00       	push   $0x1000
f0102bb1:	6a 02                	push   $0x2
	return (void *)(pa + KERNBASE);
f0102bb3:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0102bb9:	52                   	push   %edx
f0102bba:	e8 25 2b 00 00       	call   f01056e4 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0102bbf:	6a 02                	push   $0x2
f0102bc1:	68 00 10 00 00       	push   $0x1000
f0102bc6:	57                   	push   %edi
f0102bc7:	ff 35 8c 6e 23 f0    	pushl  0xf0236e8c
f0102bcd:	e8 04 e6 ff ff       	call   f01011d6 <page_insert>
	assert(pp1->pp_ref == 1);
f0102bd2:	83 c4 20             	add    $0x20,%esp
f0102bd5:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102bda:	0f 85 84 01 00 00    	jne    f0102d64 <mem_init+0x1a9c>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102be0:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102be7:	01 01 01 
f0102bea:	0f 85 8d 01 00 00    	jne    f0102d7d <mem_init+0x1ab5>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0102bf0:	6a 02                	push   $0x2
f0102bf2:	68 00 10 00 00       	push   $0x1000
f0102bf7:	53                   	push   %ebx
f0102bf8:	ff 35 8c 6e 23 f0    	pushl  0xf0236e8c
f0102bfe:	e8 d3 e5 ff ff       	call   f01011d6 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102c03:	83 c4 10             	add    $0x10,%esp
f0102c06:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102c0d:	02 02 02 
f0102c10:	0f 85 80 01 00 00    	jne    f0102d96 <mem_init+0x1ace>
	assert(pp2->pp_ref == 1);
f0102c16:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102c1b:	0f 85 8e 01 00 00    	jne    f0102daf <mem_init+0x1ae7>
	assert(pp1->pp_ref == 0);
f0102c21:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102c26:	0f 85 9c 01 00 00    	jne    f0102dc8 <mem_init+0x1b00>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0102c2c:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0102c33:	03 03 03 
	return (pp - pages) << PGSHIFT;
f0102c36:	89 d8                	mov    %ebx,%eax
f0102c38:	2b 05 90 6e 23 f0    	sub    0xf0236e90,%eax
f0102c3e:	c1 f8 03             	sar    $0x3,%eax
f0102c41:	89 c2                	mov    %eax,%edx
f0102c43:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0102c46:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0102c4b:	3b 05 88 6e 23 f0    	cmp    0xf0236e88,%eax
f0102c51:	0f 83 8a 01 00 00    	jae    f0102de1 <mem_init+0x1b19>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102c57:	81 ba 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%edx)
f0102c5e:	03 03 03 
f0102c61:	0f 85 8c 01 00 00    	jne    f0102df3 <mem_init+0x1b2b>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102c67:	83 ec 08             	sub    $0x8,%esp
f0102c6a:	68 00 10 00 00       	push   $0x1000
f0102c6f:	ff 35 8c 6e 23 f0    	pushl  0xf0236e8c
f0102c75:	e8 0b e5 ff ff       	call   f0101185 <page_remove>
	assert(pp2->pp_ref == 0);
f0102c7a:	83 c4 10             	add    $0x10,%esp
f0102c7d:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102c82:	0f 85 84 01 00 00    	jne    f0102e0c <mem_init+0x1b44>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102c88:	8b 0d 8c 6e 23 f0    	mov    0xf0236e8c,%ecx
f0102c8e:	8b 11                	mov    (%ecx),%edx
f0102c90:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	return (pp - pages) << PGSHIFT;
f0102c96:	89 f0                	mov    %esi,%eax
f0102c98:	2b 05 90 6e 23 f0    	sub    0xf0236e90,%eax
f0102c9e:	c1 f8 03             	sar    $0x3,%eax
f0102ca1:	c1 e0 0c             	shl    $0xc,%eax
f0102ca4:	39 c2                	cmp    %eax,%edx
f0102ca6:	0f 85 79 01 00 00    	jne    f0102e25 <mem_init+0x1b5d>
	kern_pgdir[0] = 0;
f0102cac:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0102cb2:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102cb7:	0f 85 81 01 00 00    	jne    f0102e3e <mem_init+0x1b76>
	pp0->pp_ref = 0;
f0102cbd:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// free the pages we took
	page_free(pp0);
f0102cc3:	83 ec 0c             	sub    $0xc,%esp
f0102cc6:	56                   	push   %esi
f0102cc7:	e8 b3 e2 ff ff       	call   f0100f7f <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0102ccc:	c7 04 24 e8 74 10 f0 	movl   $0xf01074e8,(%esp)
f0102cd3:	e8 06 0c 00 00       	call   f01038de <cprintf>
}
f0102cd8:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102cdb:	5b                   	pop    %ebx
f0102cdc:	5e                   	pop    %esi
f0102cdd:	5f                   	pop    %edi
f0102cde:	5d                   	pop    %ebp
f0102cdf:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102ce0:	50                   	push   %eax
f0102ce1:	68 c8 63 10 f0       	push   $0xf01063c8
f0102ce6:	68 ed 00 00 00       	push   $0xed
f0102ceb:	68 dd 68 10 f0       	push   $0xf01068dd
f0102cf0:	e8 4b d3 ff ff       	call   f0100040 <_panic>
	assert((pp0 = page_alloc(0)));
f0102cf5:	68 fd 69 10 f0       	push   $0xf01069fd
f0102cfa:	68 03 69 10 f0       	push   $0xf0106903
f0102cff:	68 49 04 00 00       	push   $0x449
f0102d04:	68 dd 68 10 f0       	push   $0xf01068dd
f0102d09:	e8 32 d3 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0102d0e:	68 13 6a 10 f0       	push   $0xf0106a13
f0102d13:	68 03 69 10 f0       	push   $0xf0106903
f0102d18:	68 4a 04 00 00       	push   $0x44a
f0102d1d:	68 dd 68 10 f0       	push   $0xf01068dd
f0102d22:	e8 19 d3 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0102d27:	68 29 6a 10 f0       	push   $0xf0106a29
f0102d2c:	68 03 69 10 f0       	push   $0xf0106903
f0102d31:	68 4b 04 00 00       	push   $0x44b
f0102d36:	68 dd 68 10 f0       	push   $0xf01068dd
f0102d3b:	e8 00 d3 ff ff       	call   f0100040 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102d40:	52                   	push   %edx
f0102d41:	68 a4 63 10 f0       	push   $0xf01063a4
f0102d46:	6a 58                	push   $0x58
f0102d48:	68 e9 68 10 f0       	push   $0xf01068e9
f0102d4d:	e8 ee d2 ff ff       	call   f0100040 <_panic>
f0102d52:	52                   	push   %edx
f0102d53:	68 a4 63 10 f0       	push   $0xf01063a4
f0102d58:	6a 58                	push   $0x58
f0102d5a:	68 e9 68 10 f0       	push   $0xf01068e9
f0102d5f:	e8 dc d2 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f0102d64:	68 fa 6a 10 f0       	push   $0xf0106afa
f0102d69:	68 03 69 10 f0       	push   $0xf0106903
f0102d6e:	68 50 04 00 00       	push   $0x450
f0102d73:	68 dd 68 10 f0       	push   $0xf01068dd
f0102d78:	e8 c3 d2 ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102d7d:	68 74 74 10 f0       	push   $0xf0107474
f0102d82:	68 03 69 10 f0       	push   $0xf0106903
f0102d87:	68 51 04 00 00       	push   $0x451
f0102d8c:	68 dd 68 10 f0       	push   $0xf01068dd
f0102d91:	e8 aa d2 ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102d96:	68 98 74 10 f0       	push   $0xf0107498
f0102d9b:	68 03 69 10 f0       	push   $0xf0106903
f0102da0:	68 53 04 00 00       	push   $0x453
f0102da5:	68 dd 68 10 f0       	push   $0xf01068dd
f0102daa:	e8 91 d2 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0102daf:	68 1c 6b 10 f0       	push   $0xf0106b1c
f0102db4:	68 03 69 10 f0       	push   $0xf0106903
f0102db9:	68 54 04 00 00       	push   $0x454
f0102dbe:	68 dd 68 10 f0       	push   $0xf01068dd
f0102dc3:	e8 78 d2 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f0102dc8:	68 86 6b 10 f0       	push   $0xf0106b86
f0102dcd:	68 03 69 10 f0       	push   $0xf0106903
f0102dd2:	68 55 04 00 00       	push   $0x455
f0102dd7:	68 dd 68 10 f0       	push   $0xf01068dd
f0102ddc:	e8 5f d2 ff ff       	call   f0100040 <_panic>
f0102de1:	52                   	push   %edx
f0102de2:	68 a4 63 10 f0       	push   $0xf01063a4
f0102de7:	6a 58                	push   $0x58
f0102de9:	68 e9 68 10 f0       	push   $0xf01068e9
f0102dee:	e8 4d d2 ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102df3:	68 bc 74 10 f0       	push   $0xf01074bc
f0102df8:	68 03 69 10 f0       	push   $0xf0106903
f0102dfd:	68 57 04 00 00       	push   $0x457
f0102e02:	68 dd 68 10 f0       	push   $0xf01068dd
f0102e07:	e8 34 d2 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0102e0c:	68 54 6b 10 f0       	push   $0xf0106b54
f0102e11:	68 03 69 10 f0       	push   $0xf0106903
f0102e16:	68 59 04 00 00       	push   $0x459
f0102e1b:	68 dd 68 10 f0       	push   $0xf01068dd
f0102e20:	e8 1b d2 ff ff       	call   f0100040 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102e25:	68 40 6e 10 f0       	push   $0xf0106e40
f0102e2a:	68 03 69 10 f0       	push   $0xf0106903
f0102e2f:	68 5c 04 00 00       	push   $0x45c
f0102e34:	68 dd 68 10 f0       	push   $0xf01068dd
f0102e39:	e8 02 d2 ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f0102e3e:	68 0b 6b 10 f0       	push   $0xf0106b0b
f0102e43:	68 03 69 10 f0       	push   $0xf0106903
f0102e48:	68 5e 04 00 00       	push   $0x45e
f0102e4d:	68 dd 68 10 f0       	push   $0xf01068dd
f0102e52:	e8 e9 d1 ff ff       	call   f0100040 <_panic>

f0102e57 <user_mem_check>:
{
f0102e57:	f3 0f 1e fb          	endbr32 
f0102e5b:	55                   	push   %ebp
f0102e5c:	89 e5                	mov    %esp,%ebp
f0102e5e:	57                   	push   %edi
f0102e5f:	56                   	push   %esi
f0102e60:	53                   	push   %ebx
f0102e61:	83 ec 1c             	sub    $0x1c,%esp
f0102e64:	8b 7d 08             	mov    0x8(%ebp),%edi
f0102e67:	8b 75 14             	mov    0x14(%ebp),%esi
	start=ROUNDDOWN((char *)va, PGSIZE);
f0102e6a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0102e6d:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
f0102e73:	89 5d e0             	mov    %ebx,-0x20(%ebp)
	end=ROUNDUP((char *)(va+len), PGSIZE);
f0102e76:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102e79:	03 45 10             	add    0x10(%ebp),%eax
f0102e7c:	05 ff 0f 00 00       	add    $0xfff,%eax
f0102e81:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102e86:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for(; start<end; start+=PGSIZE){
f0102e89:	eb 06                	jmp    f0102e91 <user_mem_check+0x3a>
f0102e8b:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102e91:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f0102e94:	73 55                	jae    f0102eeb <user_mem_check+0x94>
		cur=pgdir_walk(env->env_pgdir, (void *)start, 0);
f0102e96:	83 ec 04             	sub    $0x4,%esp
f0102e99:	6a 00                	push   $0x0
f0102e9b:	53                   	push   %ebx
f0102e9c:	ff 77 60             	pushl  0x60(%edi)
f0102e9f:	e8 62 e1 ff ff       	call   f0101006 <pgdir_walk>
f0102ea4:	89 da                	mov    %ebx,%edx
		if(cur==NULL || (int)start>=ULIM || ((uint32_t)(*cur)&perm)!=perm){
f0102ea6:	83 c4 10             	add    $0x10,%esp
f0102ea9:	85 c0                	test   %eax,%eax
f0102eab:	74 10                	je     f0102ebd <user_mem_check+0x66>
f0102ead:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0102eb3:	77 08                	ja     f0102ebd <user_mem_check+0x66>
f0102eb5:	89 f1                	mov    %esi,%ecx
f0102eb7:	23 08                	and    (%eax),%ecx
f0102eb9:	39 ce                	cmp    %ecx,%esi
f0102ebb:	74 ce                	je     f0102e8b <user_mem_check+0x34>
			if(start == ROUNDDOWN((char *)va, PGSIZE)) user_mem_check_addr = (uintptr_t)va;
f0102ebd:	3b 5d e0             	cmp    -0x20(%ebp),%ebx
f0102ec0:	0f 44 55 0c          	cmove  0xc(%ebp),%edx
f0102ec4:	89 15 3c 62 23 f0    	mov    %edx,0xf023623c
			cprintf("[%08x] user_mem_check assertion failure for va %08x\n", env->env_id, user_mem_check_addr);
f0102eca:	83 ec 04             	sub    $0x4,%esp
f0102ecd:	52                   	push   %edx
f0102ece:	ff 77 48             	pushl  0x48(%edi)
f0102ed1:	68 14 75 10 f0       	push   $0xf0107514
f0102ed6:	e8 03 0a 00 00       	call   f01038de <cprintf>
			return -E_FAULT;
f0102edb:	83 c4 10             	add    $0x10,%esp
f0102ede:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
}
f0102ee3:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102ee6:	5b                   	pop    %ebx
f0102ee7:	5e                   	pop    %esi
f0102ee8:	5f                   	pop    %edi
f0102ee9:	5d                   	pop    %ebp
f0102eea:	c3                   	ret    
	return 0;
f0102eeb:	b8 00 00 00 00       	mov    $0x0,%eax
f0102ef0:	eb f1                	jmp    f0102ee3 <user_mem_check+0x8c>

f0102ef2 <user_mem_assert>:
{
f0102ef2:	f3 0f 1e fb          	endbr32 
f0102ef6:	55                   	push   %ebp
f0102ef7:	89 e5                	mov    %esp,%ebp
f0102ef9:	53                   	push   %ebx
f0102efa:	83 ec 04             	sub    $0x4,%esp
f0102efd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f0102f00:	8b 45 14             	mov    0x14(%ebp),%eax
f0102f03:	83 c8 04             	or     $0x4,%eax
f0102f06:	50                   	push   %eax
f0102f07:	ff 75 10             	pushl  0x10(%ebp)
f0102f0a:	ff 75 0c             	pushl  0xc(%ebp)
f0102f0d:	53                   	push   %ebx
f0102f0e:	e8 44 ff ff ff       	call   f0102e57 <user_mem_check>
f0102f13:	83 c4 10             	add    $0x10,%esp
f0102f16:	85 c0                	test   %eax,%eax
f0102f18:	78 05                	js     f0102f1f <user_mem_assert+0x2d>
}
f0102f1a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0102f1d:	c9                   	leave  
f0102f1e:	c3                   	ret    
		cprintf("[%08x] user_mem_check assertion failure for "
f0102f1f:	83 ec 04             	sub    $0x4,%esp
f0102f22:	ff 35 3c 62 23 f0    	pushl  0xf023623c
f0102f28:	ff 73 48             	pushl  0x48(%ebx)
f0102f2b:	68 14 75 10 f0       	push   $0xf0107514
f0102f30:	e8 a9 09 00 00       	call   f01038de <cprintf>
		env_destroy(env);	// may not return
f0102f35:	89 1c 24             	mov    %ebx,(%esp)
f0102f38:	e8 7c 06 00 00       	call   f01035b9 <env_destroy>
f0102f3d:	83 c4 10             	add    $0x10,%esp
}
f0102f40:	eb d8                	jmp    f0102f1a <user_mem_assert+0x28>

f0102f42 <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f0102f42:	55                   	push   %ebp
f0102f43:	89 e5                	mov    %esp,%ebp
f0102f45:	57                   	push   %edi
f0102f46:	56                   	push   %esi
f0102f47:	53                   	push   %ebx
f0102f48:	83 ec 0c             	sub    $0xc,%esp
f0102f4b:	89 c7                	mov    %eax,%edi
	//
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
	void* start=(void*)ROUNDDOWN((uint32_t)va, PGSIZE);//get va start
f0102f4d:	89 d3                	mov    %edx,%ebx
f0102f4f:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	void* end=(void*)ROUNDUP((uint32_t)va+len, PGSIZE);//get va end
f0102f55:	8d b4 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%esi
f0102f5c:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	struct PageInfo *p=NULL;
	void* i;
	int r;

	for(i=start; i<end; i+=PGSIZE){
f0102f62:	39 f3                	cmp    %esi,%ebx
f0102f64:	73 5a                	jae    f0102fc0 <region_alloc+0x7e>
		p=page_alloc(0);//get a pageinfo
f0102f66:	83 ec 0c             	sub    $0xc,%esp
f0102f69:	6a 00                	push   $0x0
f0102f6b:	e8 96 df ff ff       	call   f0100f06 <page_alloc>
		if(p==NULL) panic("allocation failed!");
f0102f70:	83 c4 10             	add    $0x10,%esp
f0102f73:	85 c0                	test   %eax,%eax
f0102f75:	74 1b                	je     f0102f92 <region_alloc+0x50>
		r=page_insert(e->env_pgdir, p, i, PTE_W | PTE_U);//set pageinfo with va
f0102f77:	6a 06                	push   $0x6
f0102f79:	53                   	push   %ebx
f0102f7a:	50                   	push   %eax
f0102f7b:	ff 77 60             	pushl  0x60(%edi)
f0102f7e:	e8 53 e2 ff ff       	call   f01011d6 <page_insert>
		if(r!=0) panic("region alloc error!");
f0102f83:	83 c4 10             	add    $0x10,%esp
f0102f86:	85 c0                	test   %eax,%eax
f0102f88:	75 1f                	jne    f0102fa9 <region_alloc+0x67>
	for(i=start; i<end; i+=PGSIZE){
f0102f8a:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102f90:	eb d0                	jmp    f0102f62 <region_alloc+0x20>
		if(p==NULL) panic("allocation failed!");
f0102f92:	83 ec 04             	sub    $0x4,%esp
f0102f95:	68 49 75 10 f0       	push   $0xf0107549
f0102f9a:	68 37 01 00 00       	push   $0x137
f0102f9f:	68 5c 75 10 f0       	push   $0xf010755c
f0102fa4:	e8 97 d0 ff ff       	call   f0100040 <_panic>
		if(r!=0) panic("region alloc error!");
f0102fa9:	83 ec 04             	sub    $0x4,%esp
f0102fac:	68 67 75 10 f0       	push   $0xf0107567
f0102fb1:	68 39 01 00 00       	push   $0x139
f0102fb6:	68 5c 75 10 f0       	push   $0xf010755c
f0102fbb:	e8 80 d0 ff ff       	call   f0100040 <_panic>
	}
}
f0102fc0:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102fc3:	5b                   	pop    %ebx
f0102fc4:	5e                   	pop    %esi
f0102fc5:	5f                   	pop    %edi
f0102fc6:	5d                   	pop    %ebp
f0102fc7:	c3                   	ret    

f0102fc8 <envid2env>:
{
f0102fc8:	f3 0f 1e fb          	endbr32 
f0102fcc:	55                   	push   %ebp
f0102fcd:	89 e5                	mov    %esp,%ebp
f0102fcf:	56                   	push   %esi
f0102fd0:	53                   	push   %ebx
f0102fd1:	8b 75 08             	mov    0x8(%ebp),%esi
f0102fd4:	8b 45 10             	mov    0x10(%ebp),%eax
	if (envid == 0) {
f0102fd7:	85 f6                	test   %esi,%esi
f0102fd9:	74 2e                	je     f0103009 <envid2env+0x41>
	e = &envs[ENVX(envid)];
f0102fdb:	89 f3                	mov    %esi,%ebx
f0102fdd:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
f0102fe3:	6b db 7c             	imul   $0x7c,%ebx,%ebx
f0102fe6:	03 1d 44 62 23 f0    	add    0xf0236244,%ebx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f0102fec:	83 7b 54 00          	cmpl   $0x0,0x54(%ebx)
f0102ff0:	74 2e                	je     f0103020 <envid2env+0x58>
f0102ff2:	39 73 48             	cmp    %esi,0x48(%ebx)
f0102ff5:	75 29                	jne    f0103020 <envid2env+0x58>
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0102ff7:	84 c0                	test   %al,%al
f0102ff9:	75 35                	jne    f0103030 <envid2env+0x68>
	*env_store = e;
f0102ffb:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102ffe:	89 18                	mov    %ebx,(%eax)
	return 0;
f0103000:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103005:	5b                   	pop    %ebx
f0103006:	5e                   	pop    %esi
f0103007:	5d                   	pop    %ebp
f0103008:	c3                   	ret    
		*env_store = curenv;
f0103009:	e8 f4 2c 00 00       	call   f0105d02 <cpunum>
f010300e:	6b c0 74             	imul   $0x74,%eax,%eax
f0103011:	8b 80 28 70 23 f0    	mov    -0xfdc8fd8(%eax),%eax
f0103017:	8b 55 0c             	mov    0xc(%ebp),%edx
f010301a:	89 02                	mov    %eax,(%edx)
		return 0;
f010301c:	89 f0                	mov    %esi,%eax
f010301e:	eb e5                	jmp    f0103005 <envid2env+0x3d>
		*env_store = 0;
f0103020:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103023:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0103029:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f010302e:	eb d5                	jmp    f0103005 <envid2env+0x3d>
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0103030:	e8 cd 2c 00 00       	call   f0105d02 <cpunum>
f0103035:	6b c0 74             	imul   $0x74,%eax,%eax
f0103038:	39 98 28 70 23 f0    	cmp    %ebx,-0xfdc8fd8(%eax)
f010303e:	74 bb                	je     f0102ffb <envid2env+0x33>
f0103040:	8b 73 4c             	mov    0x4c(%ebx),%esi
f0103043:	e8 ba 2c 00 00       	call   f0105d02 <cpunum>
f0103048:	6b c0 74             	imul   $0x74,%eax,%eax
f010304b:	8b 80 28 70 23 f0    	mov    -0xfdc8fd8(%eax),%eax
f0103051:	3b 70 48             	cmp    0x48(%eax),%esi
f0103054:	74 a5                	je     f0102ffb <envid2env+0x33>
		*env_store = 0;
f0103056:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103059:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f010305f:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0103064:	eb 9f                	jmp    f0103005 <envid2env+0x3d>

f0103066 <env_init_percpu>:
{
f0103066:	f3 0f 1e fb          	endbr32 
	asm volatile("lgdt (%0)" : : "r" (p));
f010306a:	b8 20 23 12 f0       	mov    $0xf0122320,%eax
f010306f:	0f 01 10             	lgdtl  (%eax)
	asm volatile("movw %%ax,%%gs" : : "a" (GD_UD|3));
f0103072:	b8 23 00 00 00       	mov    $0x23,%eax
f0103077:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" : : "a" (GD_UD|3));
f0103079:	8e e0                	mov    %eax,%fs
	asm volatile("movw %%ax,%%es" : : "a" (GD_KD));
f010307b:	b8 10 00 00 00       	mov    $0x10,%eax
f0103080:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" : : "a" (GD_KD));
f0103082:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" : : "a" (GD_KD));
f0103084:	8e d0                	mov    %eax,%ss
	asm volatile("ljmp %0,$1f\n 1:\n" : : "i" (GD_KT));
f0103086:	ea 8d 30 10 f0 08 00 	ljmp   $0x8,$0xf010308d
	asm volatile("lldt %0" : : "r" (sel));
f010308d:	b8 00 00 00 00       	mov    $0x0,%eax
f0103092:	0f 00 d0             	lldt   %ax
}
f0103095:	c3                   	ret    

f0103096 <env_init>:
{
f0103096:	f3 0f 1e fb          	endbr32 
f010309a:	55                   	push   %ebp
f010309b:	89 e5                	mov    %esp,%ebp
f010309d:	56                   	push   %esi
f010309e:	53                   	push   %ebx
		envs[i].env_id=0;
f010309f:	8b 35 44 62 23 f0    	mov    0xf0236244,%esi
f01030a5:	8d 86 84 ef 01 00    	lea    0x1ef84(%esi),%eax
f01030ab:	89 f3                	mov    %esi,%ebx
f01030ad:	ba 00 00 00 00       	mov    $0x0,%edx
f01030b2:	89 d1                	mov    %edx,%ecx
f01030b4:	89 c2                	mov    %eax,%edx
f01030b6:	c7 40 48 00 00 00 00 	movl   $0x0,0x48(%eax)
		envs[i].env_status=ENV_FREE;
f01030bd:	c7 40 54 00 00 00 00 	movl   $0x0,0x54(%eax)
		envs[i].env_link=env_free_list;
f01030c4:	89 48 44             	mov    %ecx,0x44(%eax)
f01030c7:	83 e8 7c             	sub    $0x7c,%eax
	for(i=NENV-1; i>=0; i--){
f01030ca:	39 da                	cmp    %ebx,%edx
f01030cc:	75 e4                	jne    f01030b2 <env_init+0x1c>
f01030ce:	89 35 48 62 23 f0    	mov    %esi,0xf0236248
	env_init_percpu();
f01030d4:	e8 8d ff ff ff       	call   f0103066 <env_init_percpu>
}
f01030d9:	5b                   	pop    %ebx
f01030da:	5e                   	pop    %esi
f01030db:	5d                   	pop    %ebp
f01030dc:	c3                   	ret    

f01030dd <env_alloc>:
{
f01030dd:	f3 0f 1e fb          	endbr32 
f01030e1:	55                   	push   %ebp
f01030e2:	89 e5                	mov    %esp,%ebp
f01030e4:	53                   	push   %ebx
f01030e5:	83 ec 04             	sub    $0x4,%esp
	if (!(e = env_free_list))
f01030e8:	8b 1d 48 62 23 f0    	mov    0xf0236248,%ebx
f01030ee:	85 db                	test   %ebx,%ebx
f01030f0:	0f 84 95 01 00 00    	je     f010328b <env_alloc+0x1ae>
	if (!(p = page_alloc(ALLOC_ZERO)))
f01030f6:	83 ec 0c             	sub    $0xc,%esp
f01030f9:	6a 01                	push   $0x1
f01030fb:	e8 06 de ff ff       	call   f0100f06 <page_alloc>
f0103100:	83 c4 10             	add    $0x10,%esp
f0103103:	85 c0                	test   %eax,%eax
f0103105:	0f 84 87 01 00 00    	je     f0103292 <env_alloc+0x1b5>
	return (pp - pages) << PGSHIFT;
f010310b:	89 c2                	mov    %eax,%edx
f010310d:	2b 15 90 6e 23 f0    	sub    0xf0236e90,%edx
f0103113:	c1 fa 03             	sar    $0x3,%edx
f0103116:	89 d1                	mov    %edx,%ecx
f0103118:	c1 e1 0c             	shl    $0xc,%ecx
	if (PGNUM(pa) >= npages)
f010311b:	81 e2 ff ff 0f 00    	and    $0xfffff,%edx
f0103121:	3b 15 88 6e 23 f0    	cmp    0xf0236e88,%edx
f0103127:	0f 83 37 01 00 00    	jae    f0103264 <env_alloc+0x187>
	return (void *)(pa + KERNBASE);
f010312d:	81 e9 00 00 00 10    	sub    $0x10000000,%ecx
f0103133:	89 4b 60             	mov    %ecx,0x60(%ebx)
	p->pp_ref++;
f0103136:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
f010313b:	b8 00 00 00 00       	mov    $0x0,%eax
		e->env_pgdir[i]=0;
f0103140:	8b 53 60             	mov    0x60(%ebx),%edx
f0103143:	c7 04 02 00 00 00 00 	movl   $0x0,(%edx,%eax,1)
f010314a:	83 c0 04             	add    $0x4,%eax
	for(i=0; i<PDX(UTOP); i++){
f010314d:	3d ec 0e 00 00       	cmp    $0xeec,%eax
f0103152:	75 ec                	jne    f0103140 <env_alloc+0x63>
		e->env_pgdir[i]=kern_pgdir[i];
f0103154:	8b 15 8c 6e 23 f0    	mov    0xf0236e8c,%edx
f010315a:	8b 0c 02             	mov    (%edx,%eax,1),%ecx
f010315d:	8b 53 60             	mov    0x60(%ebx),%edx
f0103160:	89 0c 02             	mov    %ecx,(%edx,%eax,1)
f0103163:	83 c0 04             	add    $0x4,%eax
	for(i=PDX(UTOP); i<NPDENTRIES; i++){
f0103166:	3d 00 10 00 00       	cmp    $0x1000,%eax
f010316b:	75 e7                	jne    f0103154 <env_alloc+0x77>
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f010316d:	8b 43 60             	mov    0x60(%ebx),%eax
	if ((uint32_t)kva < KERNBASE)
f0103170:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103175:	0f 86 fb 00 00 00    	jbe    f0103276 <env_alloc+0x199>
	return (physaddr_t)kva - KERNBASE;
f010317b:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0103181:	83 ca 05             	or     $0x5,%edx
f0103184:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f010318a:	8b 43 48             	mov    0x48(%ebx),%eax
f010318d:	05 00 10 00 00       	add    $0x1000,%eax
		generation = 1 << ENVGENSHIFT;
f0103192:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f0103197:	ba 00 10 00 00       	mov    $0x1000,%edx
f010319c:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f010319f:	89 da                	mov    %ebx,%edx
f01031a1:	2b 15 44 62 23 f0    	sub    0xf0236244,%edx
f01031a7:	c1 fa 02             	sar    $0x2,%edx
f01031aa:	69 d2 df 7b ef bd    	imul   $0xbdef7bdf,%edx,%edx
f01031b0:	09 d0                	or     %edx,%eax
f01031b2:	89 43 48             	mov    %eax,0x48(%ebx)
	e->env_parent_id = parent_id;
f01031b5:	8b 45 0c             	mov    0xc(%ebp),%eax
f01031b8:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f01031bb:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f01031c2:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f01031c9:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f01031d0:	83 ec 04             	sub    $0x4,%esp
f01031d3:	6a 44                	push   $0x44
f01031d5:	6a 00                	push   $0x0
f01031d7:	53                   	push   %ebx
f01031d8:	e8 07 25 00 00       	call   f01056e4 <memset>
	e->env_tf.tf_ds = GD_UD | 3;
f01031dd:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f01031e3:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f01031e9:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f01031ef:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f01031f6:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	e->env_tf.tf_eflags |= FL_IF;
f01031fc:	81 4b 38 00 02 00 00 	orl    $0x200,0x38(%ebx)
	e->env_pgfault_upcall = 0;
f0103203:	c7 43 64 00 00 00 00 	movl   $0x0,0x64(%ebx)
	e->env_ipc_recving = 0;
f010320a:	c6 43 68 00          	movb   $0x0,0x68(%ebx)
	env_free_list = e->env_link;
f010320e:	8b 43 44             	mov    0x44(%ebx),%eax
f0103211:	a3 48 62 23 f0       	mov    %eax,0xf0236248
	*newenv_store = e;
f0103216:	8b 45 08             	mov    0x8(%ebp),%eax
f0103219:	89 18                	mov    %ebx,(%eax)
	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f010321b:	8b 5b 48             	mov    0x48(%ebx),%ebx
f010321e:	e8 df 2a 00 00       	call   f0105d02 <cpunum>
f0103223:	6b c0 74             	imul   $0x74,%eax,%eax
f0103226:	83 c4 10             	add    $0x10,%esp
f0103229:	ba 00 00 00 00       	mov    $0x0,%edx
f010322e:	83 b8 28 70 23 f0 00 	cmpl   $0x0,-0xfdc8fd8(%eax)
f0103235:	74 11                	je     f0103248 <env_alloc+0x16b>
f0103237:	e8 c6 2a 00 00       	call   f0105d02 <cpunum>
f010323c:	6b c0 74             	imul   $0x74,%eax,%eax
f010323f:	8b 80 28 70 23 f0    	mov    -0xfdc8fd8(%eax),%eax
f0103245:	8b 50 48             	mov    0x48(%eax),%edx
f0103248:	83 ec 04             	sub    $0x4,%esp
f010324b:	53                   	push   %ebx
f010324c:	52                   	push   %edx
f010324d:	68 7b 75 10 f0       	push   $0xf010757b
f0103252:	e8 87 06 00 00       	call   f01038de <cprintf>
	return 0;
f0103257:	83 c4 10             	add    $0x10,%esp
f010325a:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010325f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103262:	c9                   	leave  
f0103263:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103264:	51                   	push   %ecx
f0103265:	68 a4 63 10 f0       	push   $0xf01063a4
f010326a:	6a 58                	push   $0x58
f010326c:	68 e9 68 10 f0       	push   $0xf01068e9
f0103271:	e8 ca cd ff ff       	call   f0100040 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103276:	50                   	push   %eax
f0103277:	68 c8 63 10 f0       	push   $0xf01063c8
f010327c:	68 cf 00 00 00       	push   $0xcf
f0103281:	68 5c 75 10 f0       	push   $0xf010755c
f0103286:	e8 b5 cd ff ff       	call   f0100040 <_panic>
		return -E_NO_FREE_ENV;
f010328b:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f0103290:	eb cd                	jmp    f010325f <env_alloc+0x182>
		return -E_NO_MEM;
f0103292:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0103297:	eb c6                	jmp    f010325f <env_alloc+0x182>

f0103299 <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f0103299:	f3 0f 1e fb          	endbr32 
f010329d:	55                   	push   %ebp
f010329e:	89 e5                	mov    %esp,%ebp
f01032a0:	57                   	push   %edi
f01032a1:	56                   	push   %esi
f01032a2:	53                   	push   %ebx
f01032a3:	83 ec 34             	sub    $0x34,%esp
f01032a6:	8b 75 08             	mov    0x8(%ebp),%esi
	// LAB 3: Your code here.
	struct Env *e;
	int rc;
	rc=env_alloc(&e, 0);
f01032a9:	6a 00                	push   $0x0
f01032ab:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01032ae:	50                   	push   %eax
f01032af:	e8 29 fe ff ff       	call   f01030dd <env_alloc>
	if(rc!=0) panic("env_create failed: env_alloc failed!\n");
f01032b4:	83 c4 10             	add    $0x10,%esp
f01032b7:	85 c0                	test   %eax,%eax
f01032b9:	75 3d                	jne    f01032f8 <env_create+0x5f>
	load_icode(e, binary);
f01032bb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
	if(header->e_magic!=ELF_MAGIC) panic("load_icode failed: this binary is not elf!\n");
f01032be:	81 3e 7f 45 4c 46    	cmpl   $0x464c457f,(%esi)
f01032c4:	75 49                	jne    f010330f <env_create+0x76>
	if(header->e_entry==0) panic("load_icode failed: this elf can't be excuted.\n");
f01032c6:	8b 46 18             	mov    0x18(%esi),%eax
f01032c9:	85 c0                	test   %eax,%eax
f01032cb:	74 59                	je     f0103326 <env_create+0x8d>
	e->env_tf.tf_eip=header->e_entry;
f01032cd:	89 47 30             	mov    %eax,0x30(%edi)
	lcr3(PADDR(e->env_pgdir));
f01032d0:	8b 47 60             	mov    0x60(%edi),%eax
	if ((uint32_t)kva < KERNBASE)
f01032d3:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01032d8:	76 63                	jbe    f010333d <env_create+0xa4>
	return (physaddr_t)kva - KERNBASE;
f01032da:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f01032df:	0f 22 d8             	mov    %eax,%cr3
	ph=(struct Proghdr*)((uint8_t *)header+header->e_phoff);
f01032e2:	89 f3                	mov    %esi,%ebx
f01032e4:	03 5e 1c             	add    0x1c(%esi),%ebx
	eph=ph+header->e_phnum;
f01032e7:	0f b7 46 2c          	movzwl 0x2c(%esi),%eax
f01032eb:	c1 e0 05             	shl    $0x5,%eax
f01032ee:	01 d8                	add    %ebx,%eax
f01032f0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	for(; ph<eph; ph++){
f01032f3:	e9 95 00 00 00       	jmp    f010338d <env_create+0xf4>
	if(rc!=0) panic("env_create failed: env_alloc failed!\n");
f01032f8:	83 ec 04             	sub    $0x4,%esp
f01032fb:	68 b4 75 10 f0       	push   $0xf01075b4
f0103300:	68 9b 01 00 00       	push   $0x19b
f0103305:	68 5c 75 10 f0       	push   $0xf010755c
f010330a:	e8 31 cd ff ff       	call   f0100040 <_panic>
	if(header->e_magic!=ELF_MAGIC) panic("load_icode failed: this binary is not elf!\n");
f010330f:	83 ec 04             	sub    $0x4,%esp
f0103312:	68 dc 75 10 f0       	push   $0xf01075dc
f0103317:	68 75 01 00 00       	push   $0x175
f010331c:	68 5c 75 10 f0       	push   $0xf010755c
f0103321:	e8 1a cd ff ff       	call   f0100040 <_panic>
	if(header->e_entry==0) panic("load_icode failed: this elf can't be excuted.\n");
f0103326:	83 ec 04             	sub    $0x4,%esp
f0103329:	68 08 76 10 f0       	push   $0xf0107608
f010332e:	68 77 01 00 00       	push   $0x177
f0103333:	68 5c 75 10 f0       	push   $0xf010755c
f0103338:	e8 03 cd ff ff       	call   f0100040 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010333d:	50                   	push   %eax
f010333e:	68 c8 63 10 f0       	push   $0xf01063c8
f0103343:	68 79 01 00 00       	push   $0x179
f0103348:	68 5c 75 10 f0       	push   $0xf010755c
f010334d:	e8 ee cc ff ff       	call   f0100040 <_panic>
			region_alloc(e, (void *)ph->p_va, ph->p_memsz);
f0103352:	8b 53 08             	mov    0x8(%ebx),%edx
f0103355:	89 f8                	mov    %edi,%eax
f0103357:	e8 e6 fb ff ff       	call   f0102f42 <region_alloc>
			memmove((void *)ph->p_va, binary+ph->p_offset, ph->p_filesz);
f010335c:	83 ec 04             	sub    $0x4,%esp
f010335f:	ff 73 10             	pushl  0x10(%ebx)
f0103362:	89 f0                	mov    %esi,%eax
f0103364:	03 43 04             	add    0x4(%ebx),%eax
f0103367:	50                   	push   %eax
f0103368:	ff 73 08             	pushl  0x8(%ebx)
f010336b:	e8 c0 23 00 00       	call   f0105730 <memmove>
			memset((void *)(ph->p_va+ph->p_filesz), 0, ph->p_memsz-ph->p_filesz);
f0103370:	8b 43 10             	mov    0x10(%ebx),%eax
f0103373:	83 c4 0c             	add    $0xc,%esp
f0103376:	8b 53 14             	mov    0x14(%ebx),%edx
f0103379:	29 c2                	sub    %eax,%edx
f010337b:	52                   	push   %edx
f010337c:	6a 00                	push   $0x0
f010337e:	03 43 08             	add    0x8(%ebx),%eax
f0103381:	50                   	push   %eax
f0103382:	e8 5d 23 00 00       	call   f01056e4 <memset>
f0103387:	83 c4 10             	add    $0x10,%esp
	for(; ph<eph; ph++){
f010338a:	83 c3 20             	add    $0x20,%ebx
f010338d:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f0103390:	76 24                	jbe    f01033b6 <env_create+0x11d>
		if(ph->p_type==ELF_PROG_LOAD){
f0103392:	83 3b 01             	cmpl   $0x1,(%ebx)
f0103395:	75 f3                	jne    f010338a <env_create+0xf1>
			if(ph->p_memsz < ph->p_filesz) panic("load_icode failed: ph->p_memsz < ph->p_filesz!\n");
f0103397:	8b 4b 14             	mov    0x14(%ebx),%ecx
f010339a:	3b 4b 10             	cmp    0x10(%ebx),%ecx
f010339d:	73 b3                	jae    f0103352 <env_create+0xb9>
f010339f:	83 ec 04             	sub    $0x4,%esp
f01033a2:	68 38 76 10 f0       	push   $0xf0107638
f01033a7:	68 7f 01 00 00       	push   $0x17f
f01033ac:	68 5c 75 10 f0       	push   $0xf010755c
f01033b1:	e8 8a cc ff ff       	call   f0100040 <_panic>
	region_alloc(e, (void *)(USTACKTOP-PGSIZE), PGSIZE);
f01033b6:	b9 00 10 00 00       	mov    $0x1000,%ecx
f01033bb:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f01033c0:	89 f8                	mov    %edi,%eax
f01033c2:	e8 7b fb ff ff       	call   f0102f42 <region_alloc>
	e->env_type=type;
f01033c7:	8b 55 0c             	mov    0xc(%ebp),%edx
f01033ca:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01033cd:	89 50 50             	mov    %edx,0x50(%eax)
}
f01033d0:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01033d3:	5b                   	pop    %ebx
f01033d4:	5e                   	pop    %esi
f01033d5:	5f                   	pop    %edi
f01033d6:	5d                   	pop    %ebp
f01033d7:	c3                   	ret    

f01033d8 <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f01033d8:	f3 0f 1e fb          	endbr32 
f01033dc:	55                   	push   %ebp
f01033dd:	89 e5                	mov    %esp,%ebp
f01033df:	57                   	push   %edi
f01033e0:	56                   	push   %esi
f01033e1:	53                   	push   %ebx
f01033e2:	83 ec 1c             	sub    $0x1c,%esp
f01033e5:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f01033e8:	e8 15 29 00 00       	call   f0105d02 <cpunum>
f01033ed:	6b c0 74             	imul   $0x74,%eax,%eax
f01033f0:	39 b8 28 70 23 f0    	cmp    %edi,-0xfdc8fd8(%eax)
f01033f6:	74 48                	je     f0103440 <env_free+0x68>
		lcr3(PADDR(kern_pgdir));

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f01033f8:	8b 5f 48             	mov    0x48(%edi),%ebx
f01033fb:	e8 02 29 00 00       	call   f0105d02 <cpunum>
f0103400:	6b c0 74             	imul   $0x74,%eax,%eax
f0103403:	ba 00 00 00 00       	mov    $0x0,%edx
f0103408:	83 b8 28 70 23 f0 00 	cmpl   $0x0,-0xfdc8fd8(%eax)
f010340f:	74 11                	je     f0103422 <env_free+0x4a>
f0103411:	e8 ec 28 00 00       	call   f0105d02 <cpunum>
f0103416:	6b c0 74             	imul   $0x74,%eax,%eax
f0103419:	8b 80 28 70 23 f0    	mov    -0xfdc8fd8(%eax),%eax
f010341f:	8b 50 48             	mov    0x48(%eax),%edx
f0103422:	83 ec 04             	sub    $0x4,%esp
f0103425:	53                   	push   %ebx
f0103426:	52                   	push   %edx
f0103427:	68 90 75 10 f0       	push   $0xf0107590
f010342c:	e8 ad 04 00 00       	call   f01038de <cprintf>
f0103431:	83 c4 10             	add    $0x10,%esp
f0103434:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f010343b:	e9 a9 00 00 00       	jmp    f01034e9 <env_free+0x111>
		lcr3(PADDR(kern_pgdir));
f0103440:	a1 8c 6e 23 f0       	mov    0xf0236e8c,%eax
	if ((uint32_t)kva < KERNBASE)
f0103445:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010344a:	76 0a                	jbe    f0103456 <env_free+0x7e>
	return (physaddr_t)kva - KERNBASE;
f010344c:	05 00 00 00 10       	add    $0x10000000,%eax
f0103451:	0f 22 d8             	mov    %eax,%cr3
}
f0103454:	eb a2                	jmp    f01033f8 <env_free+0x20>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103456:	50                   	push   %eax
f0103457:	68 c8 63 10 f0       	push   $0xf01063c8
f010345c:	68 ae 01 00 00       	push   $0x1ae
f0103461:	68 5c 75 10 f0       	push   $0xf010755c
f0103466:	e8 d5 cb ff ff       	call   f0100040 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010346b:	56                   	push   %esi
f010346c:	68 a4 63 10 f0       	push   $0xf01063a4
f0103471:	68 bd 01 00 00       	push   $0x1bd
f0103476:	68 5c 75 10 f0       	push   $0xf010755c
f010347b:	e8 c0 cb ff ff       	call   f0100040 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103480:	83 ec 08             	sub    $0x8,%esp
f0103483:	89 d8                	mov    %ebx,%eax
f0103485:	c1 e0 0c             	shl    $0xc,%eax
f0103488:	0b 45 e4             	or     -0x1c(%ebp),%eax
f010348b:	50                   	push   %eax
f010348c:	ff 77 60             	pushl  0x60(%edi)
f010348f:	e8 f1 dc ff ff       	call   f0101185 <page_remove>
f0103494:	83 c4 10             	add    $0x10,%esp
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103497:	83 c3 01             	add    $0x1,%ebx
f010349a:	83 c6 04             	add    $0x4,%esi
f010349d:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f01034a3:	74 07                	je     f01034ac <env_free+0xd4>
			if (pt[pteno] & PTE_P)
f01034a5:	f6 06 01             	testb  $0x1,(%esi)
f01034a8:	74 ed                	je     f0103497 <env_free+0xbf>
f01034aa:	eb d4                	jmp    f0103480 <env_free+0xa8>
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f01034ac:	8b 47 60             	mov    0x60(%edi),%eax
f01034af:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01034b2:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
	if (PGNUM(pa) >= npages)
f01034b9:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01034bc:	3b 05 88 6e 23 f0    	cmp    0xf0236e88,%eax
f01034c2:	73 65                	jae    f0103529 <env_free+0x151>
		page_decref(pa2page(pa));
f01034c4:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f01034c7:	a1 90 6e 23 f0       	mov    0xf0236e90,%eax
f01034cc:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01034cf:	8d 04 d0             	lea    (%eax,%edx,8),%eax
f01034d2:	50                   	push   %eax
f01034d3:	e8 01 db ff ff       	call   f0100fd9 <page_decref>
f01034d8:	83 c4 10             	add    $0x10,%esp
f01034db:	83 45 e0 04          	addl   $0x4,-0x20(%ebp)
f01034df:	8b 45 e0             	mov    -0x20(%ebp),%eax
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f01034e2:	3d ec 0e 00 00       	cmp    $0xeec,%eax
f01034e7:	74 54                	je     f010353d <env_free+0x165>
		if (!(e->env_pgdir[pdeno] & PTE_P))
f01034e9:	8b 47 60             	mov    0x60(%edi),%eax
f01034ec:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01034ef:	8b 04 10             	mov    (%eax,%edx,1),%eax
f01034f2:	a8 01                	test   $0x1,%al
f01034f4:	74 e5                	je     f01034db <env_free+0x103>
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f01034f6:	89 c6                	mov    %eax,%esi
f01034f8:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	if (PGNUM(pa) >= npages)
f01034fe:	c1 e8 0c             	shr    $0xc,%eax
f0103501:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0103504:	39 05 88 6e 23 f0    	cmp    %eax,0xf0236e88
f010350a:	0f 86 5b ff ff ff    	jbe    f010346b <env_free+0x93>
	return (void *)(pa + KERNBASE);
f0103510:	81 ee 00 00 00 10    	sub    $0x10000000,%esi
f0103516:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103519:	c1 e0 14             	shl    $0x14,%eax
f010351c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f010351f:	bb 00 00 00 00       	mov    $0x0,%ebx
f0103524:	e9 7c ff ff ff       	jmp    f01034a5 <env_free+0xcd>
		panic("pa2page called with invalid pa");
f0103529:	83 ec 04             	sub    $0x4,%esp
f010352c:	68 0c 6d 10 f0       	push   $0xf0106d0c
f0103531:	6a 51                	push   $0x51
f0103533:	68 e9 68 10 f0       	push   $0xf01068e9
f0103538:	e8 03 cb ff ff       	call   f0100040 <_panic>
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f010353d:	8b 47 60             	mov    0x60(%edi),%eax
	if ((uint32_t)kva < KERNBASE)
f0103540:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103545:	76 49                	jbe    f0103590 <env_free+0x1b8>
	e->env_pgdir = 0;
f0103547:	c7 47 60 00 00 00 00 	movl   $0x0,0x60(%edi)
	return (physaddr_t)kva - KERNBASE;
f010354e:	05 00 00 00 10       	add    $0x10000000,%eax
	if (PGNUM(pa) >= npages)
f0103553:	c1 e8 0c             	shr    $0xc,%eax
f0103556:	3b 05 88 6e 23 f0    	cmp    0xf0236e88,%eax
f010355c:	73 47                	jae    f01035a5 <env_free+0x1cd>
	page_decref(pa2page(pa));
f010355e:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f0103561:	8b 15 90 6e 23 f0    	mov    0xf0236e90,%edx
f0103567:	8d 04 c2             	lea    (%edx,%eax,8),%eax
f010356a:	50                   	push   %eax
f010356b:	e8 69 da ff ff       	call   f0100fd9 <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f0103570:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f0103577:	a1 48 62 23 f0       	mov    0xf0236248,%eax
f010357c:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f010357f:	89 3d 48 62 23 f0    	mov    %edi,0xf0236248
}
f0103585:	83 c4 10             	add    $0x10,%esp
f0103588:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010358b:	5b                   	pop    %ebx
f010358c:	5e                   	pop    %esi
f010358d:	5f                   	pop    %edi
f010358e:	5d                   	pop    %ebp
f010358f:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103590:	50                   	push   %eax
f0103591:	68 c8 63 10 f0       	push   $0xf01063c8
f0103596:	68 cb 01 00 00       	push   $0x1cb
f010359b:	68 5c 75 10 f0       	push   $0xf010755c
f01035a0:	e8 9b ca ff ff       	call   f0100040 <_panic>
		panic("pa2page called with invalid pa");
f01035a5:	83 ec 04             	sub    $0x4,%esp
f01035a8:	68 0c 6d 10 f0       	push   $0xf0106d0c
f01035ad:	6a 51                	push   $0x51
f01035af:	68 e9 68 10 f0       	push   $0xf01068e9
f01035b4:	e8 87 ca ff ff       	call   f0100040 <_panic>

f01035b9 <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e)
{
f01035b9:	f3 0f 1e fb          	endbr32 
f01035bd:	55                   	push   %ebp
f01035be:	89 e5                	mov    %esp,%ebp
f01035c0:	53                   	push   %ebx
f01035c1:	83 ec 04             	sub    $0x4,%esp
f01035c4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	if (e->env_status == ENV_RUNNING && curenv != e) {
f01035c7:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f01035cb:	74 21                	je     f01035ee <env_destroy+0x35>
		e->env_status = ENV_DYING;
		return;
	}

	env_free(e);
f01035cd:	83 ec 0c             	sub    $0xc,%esp
f01035d0:	53                   	push   %ebx
f01035d1:	e8 02 fe ff ff       	call   f01033d8 <env_free>

	if (curenv == e) {
f01035d6:	e8 27 27 00 00       	call   f0105d02 <cpunum>
f01035db:	6b c0 74             	imul   $0x74,%eax,%eax
f01035de:	83 c4 10             	add    $0x10,%esp
f01035e1:	39 98 28 70 23 f0    	cmp    %ebx,-0xfdc8fd8(%eax)
f01035e7:	74 1e                	je     f0103607 <env_destroy+0x4e>
		curenv = NULL;
		sched_yield();
	}
}
f01035e9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01035ec:	c9                   	leave  
f01035ed:	c3                   	ret    
	if (e->env_status == ENV_RUNNING && curenv != e) {
f01035ee:	e8 0f 27 00 00       	call   f0105d02 <cpunum>
f01035f3:	6b c0 74             	imul   $0x74,%eax,%eax
f01035f6:	39 98 28 70 23 f0    	cmp    %ebx,-0xfdc8fd8(%eax)
f01035fc:	74 cf                	je     f01035cd <env_destroy+0x14>
		e->env_status = ENV_DYING;
f01035fe:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
		return;
f0103605:	eb e2                	jmp    f01035e9 <env_destroy+0x30>
		curenv = NULL;
f0103607:	e8 f6 26 00 00       	call   f0105d02 <cpunum>
f010360c:	6b c0 74             	imul   $0x74,%eax,%eax
f010360f:	c7 80 28 70 23 f0 00 	movl   $0x0,-0xfdc8fd8(%eax)
f0103616:	00 00 00 
		sched_yield();
f0103619:	e8 fe 0e 00 00       	call   f010451c <sched_yield>

f010361e <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f010361e:	f3 0f 1e fb          	endbr32 
f0103622:	55                   	push   %ebp
f0103623:	89 e5                	mov    %esp,%ebp
f0103625:	53                   	push   %ebx
f0103626:	83 ec 04             	sub    $0x4,%esp
	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f0103629:	e8 d4 26 00 00       	call   f0105d02 <cpunum>
f010362e:	6b c0 74             	imul   $0x74,%eax,%eax
f0103631:	8b 98 28 70 23 f0    	mov    -0xfdc8fd8(%eax),%ebx
f0103637:	e8 c6 26 00 00       	call   f0105d02 <cpunum>
f010363c:	89 43 5c             	mov    %eax,0x5c(%ebx)

	asm volatile(
f010363f:	8b 65 08             	mov    0x8(%ebp),%esp
f0103642:	61                   	popa   
f0103643:	07                   	pop    %es
f0103644:	1f                   	pop    %ds
f0103645:	83 c4 08             	add    $0x8,%esp
f0103648:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret\n"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f0103649:	83 ec 04             	sub    $0x4,%esp
f010364c:	68 a6 75 10 f0       	push   $0xf01075a6
f0103651:	68 02 02 00 00       	push   $0x202
f0103656:	68 5c 75 10 f0       	push   $0xf010755c
f010365b:	e8 e0 c9 ff ff       	call   f0100040 <_panic>

f0103660 <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f0103660:	f3 0f 1e fb          	endbr32 
f0103664:	55                   	push   %ebp
f0103665:	89 e5                	mov    %esp,%ebp
f0103667:	83 ec 08             	sub    $0x8,%esp
	//	e->env_tf.  Go back through the code you wrote above
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.
	if(curenv != NULL && curenv->env_status==ENV_RUNNING){
f010366a:	e8 93 26 00 00       	call   f0105d02 <cpunum>
f010366f:	6b c0 74             	imul   $0x74,%eax,%eax
f0103672:	83 b8 28 70 23 f0 00 	cmpl   $0x0,-0xfdc8fd8(%eax)
f0103679:	74 14                	je     f010368f <env_run+0x2f>
f010367b:	e8 82 26 00 00       	call   f0105d02 <cpunum>
f0103680:	6b c0 74             	imul   $0x74,%eax,%eax
f0103683:	8b 80 28 70 23 f0    	mov    -0xfdc8fd8(%eax),%eax
f0103689:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f010368d:	74 7d                	je     f010370c <env_run+0xac>
		curenv->env_status=ENV_RUNNABLE;
	}
	curenv=e;
f010368f:	e8 6e 26 00 00       	call   f0105d02 <cpunum>
f0103694:	6b c0 74             	imul   $0x74,%eax,%eax
f0103697:	8b 55 08             	mov    0x8(%ebp),%edx
f010369a:	89 90 28 70 23 f0    	mov    %edx,-0xfdc8fd8(%eax)
	curenv->env_status=ENV_RUNNING;
f01036a0:	e8 5d 26 00 00       	call   f0105d02 <cpunum>
f01036a5:	6b c0 74             	imul   $0x74,%eax,%eax
f01036a8:	8b 80 28 70 23 f0    	mov    -0xfdc8fd8(%eax),%eax
f01036ae:	c7 40 54 03 00 00 00 	movl   $0x3,0x54(%eax)
	curenv->env_runs++;
f01036b5:	e8 48 26 00 00       	call   f0105d02 <cpunum>
f01036ba:	6b c0 74             	imul   $0x74,%eax,%eax
f01036bd:	8b 80 28 70 23 f0    	mov    -0xfdc8fd8(%eax),%eax
f01036c3:	83 40 58 01          	addl   $0x1,0x58(%eax)
	lcr3(PADDR(curenv->env_pgdir));
f01036c7:	e8 36 26 00 00       	call   f0105d02 <cpunum>
f01036cc:	6b c0 74             	imul   $0x74,%eax,%eax
f01036cf:	8b 80 28 70 23 f0    	mov    -0xfdc8fd8(%eax),%eax
f01036d5:	8b 40 60             	mov    0x60(%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f01036d8:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01036dd:	76 47                	jbe    f0103726 <env_run+0xc6>
	return (physaddr_t)kva - KERNBASE;
f01036df:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f01036e4:	0f 22 d8             	mov    %eax,%cr3
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f01036e7:	83 ec 0c             	sub    $0xc,%esp
f01036ea:	68 c0 23 12 f0       	push   $0xf01223c0
f01036ef:	e8 34 29 00 00       	call   f0106028 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f01036f4:	f3 90                	pause  
	//LAB4 go user mode need to unlock
	unlock_kernel();
	env_pop_tf(&curenv->env_tf);
f01036f6:	e8 07 26 00 00       	call   f0105d02 <cpunum>
f01036fb:	83 c4 04             	add    $0x4,%esp
f01036fe:	6b c0 74             	imul   $0x74,%eax,%eax
f0103701:	ff b0 28 70 23 f0    	pushl  -0xfdc8fd8(%eax)
f0103707:	e8 12 ff ff ff       	call   f010361e <env_pop_tf>
		curenv->env_status=ENV_RUNNABLE;
f010370c:	e8 f1 25 00 00       	call   f0105d02 <cpunum>
f0103711:	6b c0 74             	imul   $0x74,%eax,%eax
f0103714:	8b 80 28 70 23 f0    	mov    -0xfdc8fd8(%eax),%eax
f010371a:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
f0103721:	e9 69 ff ff ff       	jmp    f010368f <env_run+0x2f>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103726:	50                   	push   %eax
f0103727:	68 c8 63 10 f0       	push   $0xf01063c8
f010372c:	68 26 02 00 00       	push   $0x226
f0103731:	68 5c 75 10 f0       	push   $0xf010755c
f0103736:	e8 05 c9 ff ff       	call   f0100040 <_panic>

f010373b <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f010373b:	f3 0f 1e fb          	endbr32 
f010373f:	55                   	push   %ebp
f0103740:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103742:	8b 45 08             	mov    0x8(%ebp),%eax
f0103745:	ba 70 00 00 00       	mov    $0x70,%edx
f010374a:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010374b:	ba 71 00 00 00       	mov    $0x71,%edx
f0103750:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0103751:	0f b6 c0             	movzbl %al,%eax
}
f0103754:	5d                   	pop    %ebp
f0103755:	c3                   	ret    

f0103756 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0103756:	f3 0f 1e fb          	endbr32 
f010375a:	55                   	push   %ebp
f010375b:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010375d:	8b 45 08             	mov    0x8(%ebp),%eax
f0103760:	ba 70 00 00 00       	mov    $0x70,%edx
f0103765:	ee                   	out    %al,(%dx)
f0103766:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103769:	ba 71 00 00 00       	mov    $0x71,%edx
f010376e:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f010376f:	5d                   	pop    %ebp
f0103770:	c3                   	ret    

f0103771 <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f0103771:	f3 0f 1e fb          	endbr32 
f0103775:	55                   	push   %ebp
f0103776:	89 e5                	mov    %esp,%ebp
f0103778:	56                   	push   %esi
f0103779:	53                   	push   %ebx
f010377a:	8b 45 08             	mov    0x8(%ebp),%eax
	int i;
	irq_mask_8259A = mask;
f010377d:	66 a3 a8 23 12 f0    	mov    %ax,0xf01223a8
	if (!didinit)
f0103783:	80 3d 4c 62 23 f0 00 	cmpb   $0x0,0xf023624c
f010378a:	75 07                	jne    f0103793 <irq_setmask_8259A+0x22>
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
}
f010378c:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010378f:	5b                   	pop    %ebx
f0103790:	5e                   	pop    %esi
f0103791:	5d                   	pop    %ebp
f0103792:	c3                   	ret    
f0103793:	89 c6                	mov    %eax,%esi
f0103795:	ba 21 00 00 00       	mov    $0x21,%edx
f010379a:	ee                   	out    %al,(%dx)
	outb(IO_PIC2+1, (char)(mask >> 8));
f010379b:	66 c1 e8 08          	shr    $0x8,%ax
f010379f:	ba a1 00 00 00       	mov    $0xa1,%edx
f01037a4:	ee                   	out    %al,(%dx)
	cprintf("enabled interrupts:");
f01037a5:	83 ec 0c             	sub    $0xc,%esp
f01037a8:	68 68 76 10 f0       	push   $0xf0107668
f01037ad:	e8 2c 01 00 00       	call   f01038de <cprintf>
f01037b2:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 16; i++)
f01037b5:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (~mask & (1<<i))
f01037ba:	0f b7 f6             	movzwl %si,%esi
f01037bd:	f7 d6                	not    %esi
f01037bf:	eb 19                	jmp    f01037da <irq_setmask_8259A+0x69>
			cprintf(" %d", i);
f01037c1:	83 ec 08             	sub    $0x8,%esp
f01037c4:	53                   	push   %ebx
f01037c5:	68 5b 7b 10 f0       	push   $0xf0107b5b
f01037ca:	e8 0f 01 00 00       	call   f01038de <cprintf>
f01037cf:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 16; i++)
f01037d2:	83 c3 01             	add    $0x1,%ebx
f01037d5:	83 fb 10             	cmp    $0x10,%ebx
f01037d8:	74 07                	je     f01037e1 <irq_setmask_8259A+0x70>
		if (~mask & (1<<i))
f01037da:	0f a3 de             	bt     %ebx,%esi
f01037dd:	73 f3                	jae    f01037d2 <irq_setmask_8259A+0x61>
f01037df:	eb e0                	jmp    f01037c1 <irq_setmask_8259A+0x50>
	cprintf("\n");
f01037e1:	83 ec 0c             	sub    $0xc,%esp
f01037e4:	68 db 68 10 f0       	push   $0xf01068db
f01037e9:	e8 f0 00 00 00       	call   f01038de <cprintf>
f01037ee:	83 c4 10             	add    $0x10,%esp
f01037f1:	eb 99                	jmp    f010378c <irq_setmask_8259A+0x1b>

f01037f3 <pic_init>:
{
f01037f3:	f3 0f 1e fb          	endbr32 
f01037f7:	55                   	push   %ebp
f01037f8:	89 e5                	mov    %esp,%ebp
f01037fa:	57                   	push   %edi
f01037fb:	56                   	push   %esi
f01037fc:	53                   	push   %ebx
f01037fd:	83 ec 0c             	sub    $0xc,%esp
	didinit = 1;
f0103800:	c6 05 4c 62 23 f0 01 	movb   $0x1,0xf023624c
f0103807:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010380c:	bb 21 00 00 00       	mov    $0x21,%ebx
f0103811:	89 da                	mov    %ebx,%edx
f0103813:	ee                   	out    %al,(%dx)
f0103814:	b9 a1 00 00 00       	mov    $0xa1,%ecx
f0103819:	89 ca                	mov    %ecx,%edx
f010381b:	ee                   	out    %al,(%dx)
f010381c:	bf 11 00 00 00       	mov    $0x11,%edi
f0103821:	be 20 00 00 00       	mov    $0x20,%esi
f0103826:	89 f8                	mov    %edi,%eax
f0103828:	89 f2                	mov    %esi,%edx
f010382a:	ee                   	out    %al,(%dx)
f010382b:	b8 20 00 00 00       	mov    $0x20,%eax
f0103830:	89 da                	mov    %ebx,%edx
f0103832:	ee                   	out    %al,(%dx)
f0103833:	b8 04 00 00 00       	mov    $0x4,%eax
f0103838:	ee                   	out    %al,(%dx)
f0103839:	b8 03 00 00 00       	mov    $0x3,%eax
f010383e:	ee                   	out    %al,(%dx)
f010383f:	bb a0 00 00 00       	mov    $0xa0,%ebx
f0103844:	89 f8                	mov    %edi,%eax
f0103846:	89 da                	mov    %ebx,%edx
f0103848:	ee                   	out    %al,(%dx)
f0103849:	b8 28 00 00 00       	mov    $0x28,%eax
f010384e:	89 ca                	mov    %ecx,%edx
f0103850:	ee                   	out    %al,(%dx)
f0103851:	b8 02 00 00 00       	mov    $0x2,%eax
f0103856:	ee                   	out    %al,(%dx)
f0103857:	b8 01 00 00 00       	mov    $0x1,%eax
f010385c:	ee                   	out    %al,(%dx)
f010385d:	bf 68 00 00 00       	mov    $0x68,%edi
f0103862:	89 f8                	mov    %edi,%eax
f0103864:	89 f2                	mov    %esi,%edx
f0103866:	ee                   	out    %al,(%dx)
f0103867:	b9 0a 00 00 00       	mov    $0xa,%ecx
f010386c:	89 c8                	mov    %ecx,%eax
f010386e:	ee                   	out    %al,(%dx)
f010386f:	89 f8                	mov    %edi,%eax
f0103871:	89 da                	mov    %ebx,%edx
f0103873:	ee                   	out    %al,(%dx)
f0103874:	89 c8                	mov    %ecx,%eax
f0103876:	ee                   	out    %al,(%dx)
	if (irq_mask_8259A != 0xFFFF)
f0103877:	0f b7 05 a8 23 12 f0 	movzwl 0xf01223a8,%eax
f010387e:	66 83 f8 ff          	cmp    $0xffff,%ax
f0103882:	75 08                	jne    f010388c <pic_init+0x99>
}
f0103884:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103887:	5b                   	pop    %ebx
f0103888:	5e                   	pop    %esi
f0103889:	5f                   	pop    %edi
f010388a:	5d                   	pop    %ebp
f010388b:	c3                   	ret    
		irq_setmask_8259A(irq_mask_8259A);
f010388c:	83 ec 0c             	sub    $0xc,%esp
f010388f:	0f b7 c0             	movzwl %ax,%eax
f0103892:	50                   	push   %eax
f0103893:	e8 d9 fe ff ff       	call   f0103771 <irq_setmask_8259A>
f0103898:	83 c4 10             	add    $0x10,%esp
}
f010389b:	eb e7                	jmp    f0103884 <pic_init+0x91>

f010389d <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f010389d:	f3 0f 1e fb          	endbr32 
f01038a1:	55                   	push   %ebp
f01038a2:	89 e5                	mov    %esp,%ebp
f01038a4:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f01038a7:	ff 75 08             	pushl  0x8(%ebp)
f01038aa:	e8 e3 ce ff ff       	call   f0100792 <cputchar>
	*cnt++;
}
f01038af:	83 c4 10             	add    $0x10,%esp
f01038b2:	c9                   	leave  
f01038b3:	c3                   	ret    

f01038b4 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f01038b4:	f3 0f 1e fb          	endbr32 
f01038b8:	55                   	push   %ebp
f01038b9:	89 e5                	mov    %esp,%ebp
f01038bb:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f01038be:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f01038c5:	ff 75 0c             	pushl  0xc(%ebp)
f01038c8:	ff 75 08             	pushl  0x8(%ebp)
f01038cb:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01038ce:	50                   	push   %eax
f01038cf:	68 9d 38 10 f0       	push   $0xf010389d
f01038d4:	e8 75 16 00 00       	call   f0104f4e <vprintfmt>
	return cnt;
}
f01038d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01038dc:	c9                   	leave  
f01038dd:	c3                   	ret    

f01038de <cprintf>:

int
cprintf(const char *fmt, ...)
{
f01038de:	f3 0f 1e fb          	endbr32 
f01038e2:	55                   	push   %ebp
f01038e3:	89 e5                	mov    %esp,%ebp
f01038e5:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f01038e8:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f01038eb:	50                   	push   %eax
f01038ec:	ff 75 08             	pushl  0x8(%ebp)
f01038ef:	e8 c0 ff ff ff       	call   f01038b4 <vcprintf>
	va_end(ap);

	return cnt;
}
f01038f4:	c9                   	leave  
f01038f5:	c3                   	ret    

f01038f6 <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f01038f6:	f3 0f 1e fb          	endbr32 
f01038fa:	55                   	push   %ebp
f01038fb:	89 e5                	mov    %esp,%ebp
f01038fd:	57                   	push   %edi
f01038fe:	56                   	push   %esi
f01038ff:	53                   	push   %ebx
f0103900:	83 ec 1c             	sub    $0x1c,%esp
	// accidentally load the same TSS on more than one CPU, you'll
	// get a triple fault.  If you set up an individual CPU's TSS
	// wrong, you may not get a fault until you try to return from
	// user space on that CPU.
	//
	int cpu_num=cpunum();
f0103903:	e8 fa 23 00 00       	call   f0105d02 <cpunum>
f0103908:	89 c3                	mov    %eax,%ebx
	// LAB 4: Your code here:
	thiscpu->cpu_ts.ts_esp0 = KSTACKTOP - cpu_num * (KSTKSIZE + KSTKGAP);
f010390a:	e8 f3 23 00 00       	call   f0105d02 <cpunum>
f010390f:	6b c0 74             	imul   $0x74,%eax,%eax
f0103912:	89 d9                	mov    %ebx,%ecx
f0103914:	c1 e1 10             	shl    $0x10,%ecx
f0103917:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f010391c:	29 ca                	sub    %ecx,%edx
f010391e:	89 90 30 70 23 f0    	mov    %edx,-0xfdc8fd0(%eax)
	thiscpu->cpu_ts.ts_ss0 = GD_KD;
f0103924:	e8 d9 23 00 00       	call   f0105d02 <cpunum>
f0103929:	6b c0 74             	imul   $0x74,%eax,%eax
f010392c:	66 c7 80 34 70 23 f0 	movw   $0x10,-0xfdc8fcc(%eax)
f0103933:	10 00 
	thiscpu->cpu_ts.ts_iomb = sizeof(struct Taskstate);
f0103935:	e8 c8 23 00 00       	call   f0105d02 <cpunum>
f010393a:	6b c0 74             	imul   $0x74,%eax,%eax
f010393d:	66 c7 80 92 70 23 f0 	movw   $0x68,-0xfdc8f6e(%eax)
f0103944:	68 00 
	//ts.ts_esp0 = KSTACKTOP;
	//ts.ts_ss0 = GD_KD;
	//ts.ts_iomb = sizeof(struct Taskstate);

	// Initialize the TSS slot of the gdt.
	gdt[(GD_TSS0 >> 3) + cpu_num] = SEG16(STS_T32A, (uint32_t) (&thiscpu->cpu_ts),
f0103946:	8d 7b 05             	lea    0x5(%ebx),%edi
f0103949:	e8 b4 23 00 00       	call   f0105d02 <cpunum>
f010394e:	89 c6                	mov    %eax,%esi
f0103950:	e8 ad 23 00 00       	call   f0105d02 <cpunum>
f0103955:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0103958:	e8 a5 23 00 00       	call   f0105d02 <cpunum>
f010395d:	66 c7 04 fd 40 23 12 	movw   $0x67,-0xfeddcc0(,%edi,8)
f0103964:	f0 67 00 
f0103967:	6b f6 74             	imul   $0x74,%esi,%esi
f010396a:	81 c6 2c 70 23 f0    	add    $0xf023702c,%esi
f0103970:	66 89 34 fd 42 23 12 	mov    %si,-0xfeddcbe(,%edi,8)
f0103977:	f0 
f0103978:	6b 55 e4 74          	imul   $0x74,-0x1c(%ebp),%edx
f010397c:	81 c2 2c 70 23 f0    	add    $0xf023702c,%edx
f0103982:	c1 ea 10             	shr    $0x10,%edx
f0103985:	88 14 fd 44 23 12 f0 	mov    %dl,-0xfeddcbc(,%edi,8)
f010398c:	c6 04 fd 46 23 12 f0 	movb   $0x40,-0xfeddcba(,%edi,8)
f0103993:	40 
f0103994:	6b c0 74             	imul   $0x74,%eax,%eax
f0103997:	05 2c 70 23 f0       	add    $0xf023702c,%eax
f010399c:	c1 e8 18             	shr    $0x18,%eax
f010399f:	88 04 fd 47 23 12 f0 	mov    %al,-0xfeddcb9(,%edi,8)
										sizeof(struct Taskstate) - 1, 0);
	gdt[(GD_TSS0 >> 3) + cpu_num].sd_s = 0;
f01039a6:	c6 04 fd 45 23 12 f0 	movb   $0x89,-0xfeddcbb(,%edi,8)
f01039ad:	89 

	// Load the TSS selector (like other segment selectors, the
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0+ (cpu_num << 3));
f01039ae:	8d 1c dd 28 00 00 00 	lea    0x28(,%ebx,8),%ebx
	asm volatile("ltr %0" : : "r" (sel));
f01039b5:	0f 00 db             	ltr    %bx
	asm volatile("lidt (%0)" : : "r" (p));
f01039b8:	b8 ac 23 12 f0       	mov    $0xf01223ac,%eax
f01039bd:	0f 01 18             	lidtl  (%eax)

	// Load the IDT
	lidt(&idt_pd);
}
f01039c0:	83 c4 1c             	add    $0x1c,%esp
f01039c3:	5b                   	pop    %ebx
f01039c4:	5e                   	pop    %esi
f01039c5:	5f                   	pop    %edi
f01039c6:	5d                   	pop    %ebp
f01039c7:	c3                   	ret    

f01039c8 <trap_init>:
{
f01039c8:	f3 0f 1e fb          	endbr32 
f01039cc:	55                   	push   %ebp
f01039cd:	89 e5                	mov    %esp,%ebp
f01039cf:	83 ec 08             	sub    $0x8,%esp
	SETGATE(idt[T_DIVIDE], 0, GD_KT, divide_entry, 0);
f01039d2:	b8 b0 43 10 f0       	mov    $0xf01043b0,%eax
f01039d7:	66 a3 60 62 23 f0    	mov    %ax,0xf0236260
f01039dd:	66 c7 05 62 62 23 f0 	movw   $0x8,0xf0236262
f01039e4:	08 00 
f01039e6:	c6 05 64 62 23 f0 00 	movb   $0x0,0xf0236264
f01039ed:	c6 05 65 62 23 f0 8e 	movb   $0x8e,0xf0236265
f01039f4:	c1 e8 10             	shr    $0x10,%eax
f01039f7:	66 a3 66 62 23 f0    	mov    %ax,0xf0236266
	SETGATE(idt[T_DEBUG], 0, GD_KT, debug_entry, 0);
f01039fd:	b8 ba 43 10 f0       	mov    $0xf01043ba,%eax
f0103a02:	66 a3 68 62 23 f0    	mov    %ax,0xf0236268
f0103a08:	66 c7 05 6a 62 23 f0 	movw   $0x8,0xf023626a
f0103a0f:	08 00 
f0103a11:	c6 05 6c 62 23 f0 00 	movb   $0x0,0xf023626c
f0103a18:	c6 05 6d 62 23 f0 8e 	movb   $0x8e,0xf023626d
f0103a1f:	c1 e8 10             	shr    $0x10,%eax
f0103a22:	66 a3 6e 62 23 f0    	mov    %ax,0xf023626e
	SETGATE(idt[T_NMI], 0, GD_KT, nmi_entry, 0);
f0103a28:	b8 c0 43 10 f0       	mov    $0xf01043c0,%eax
f0103a2d:	66 a3 70 62 23 f0    	mov    %ax,0xf0236270
f0103a33:	66 c7 05 72 62 23 f0 	movw   $0x8,0xf0236272
f0103a3a:	08 00 
f0103a3c:	c6 05 74 62 23 f0 00 	movb   $0x0,0xf0236274
f0103a43:	c6 05 75 62 23 f0 8e 	movb   $0x8e,0xf0236275
f0103a4a:	c1 e8 10             	shr    $0x10,%eax
f0103a4d:	66 a3 76 62 23 f0    	mov    %ax,0xf0236276
	SETGATE(idt[T_BRKPT], 0, GD_KT, brkpt_entry, 3);
f0103a53:	b8 c6 43 10 f0       	mov    $0xf01043c6,%eax
f0103a58:	66 a3 78 62 23 f0    	mov    %ax,0xf0236278
f0103a5e:	66 c7 05 7a 62 23 f0 	movw   $0x8,0xf023627a
f0103a65:	08 00 
f0103a67:	c6 05 7c 62 23 f0 00 	movb   $0x0,0xf023627c
f0103a6e:	c6 05 7d 62 23 f0 ee 	movb   $0xee,0xf023627d
f0103a75:	c1 e8 10             	shr    $0x10,%eax
f0103a78:	66 a3 7e 62 23 f0    	mov    %ax,0xf023627e
	SETGATE(idt[T_OFLOW], 0, GD_KT, oflow_entry, 0);
f0103a7e:	b8 cc 43 10 f0       	mov    $0xf01043cc,%eax
f0103a83:	66 a3 80 62 23 f0    	mov    %ax,0xf0236280
f0103a89:	66 c7 05 82 62 23 f0 	movw   $0x8,0xf0236282
f0103a90:	08 00 
f0103a92:	c6 05 84 62 23 f0 00 	movb   $0x0,0xf0236284
f0103a99:	c6 05 85 62 23 f0 8e 	movb   $0x8e,0xf0236285
f0103aa0:	c1 e8 10             	shr    $0x10,%eax
f0103aa3:	66 a3 86 62 23 f0    	mov    %ax,0xf0236286
	SETGATE(idt[T_BOUND], 0, GD_KT, bound_entry, 0);
f0103aa9:	b8 d2 43 10 f0       	mov    $0xf01043d2,%eax
f0103aae:	66 a3 88 62 23 f0    	mov    %ax,0xf0236288
f0103ab4:	66 c7 05 8a 62 23 f0 	movw   $0x8,0xf023628a
f0103abb:	08 00 
f0103abd:	c6 05 8c 62 23 f0 00 	movb   $0x0,0xf023628c
f0103ac4:	c6 05 8d 62 23 f0 8e 	movb   $0x8e,0xf023628d
f0103acb:	c1 e8 10             	shr    $0x10,%eax
f0103ace:	66 a3 8e 62 23 f0    	mov    %ax,0xf023628e
	SETGATE(idt[T_ILLOP], 0, GD_KT, illop_entry, 0);
f0103ad4:	b8 d8 43 10 f0       	mov    $0xf01043d8,%eax
f0103ad9:	66 a3 90 62 23 f0    	mov    %ax,0xf0236290
f0103adf:	66 c7 05 92 62 23 f0 	movw   $0x8,0xf0236292
f0103ae6:	08 00 
f0103ae8:	c6 05 94 62 23 f0 00 	movb   $0x0,0xf0236294
f0103aef:	c6 05 95 62 23 f0 8e 	movb   $0x8e,0xf0236295
f0103af6:	c1 e8 10             	shr    $0x10,%eax
f0103af9:	66 a3 96 62 23 f0    	mov    %ax,0xf0236296
	SETGATE(idt[T_DEVICE], 0, GD_KT, device_entry, 0);
f0103aff:	b8 de 43 10 f0       	mov    $0xf01043de,%eax
f0103b04:	66 a3 98 62 23 f0    	mov    %ax,0xf0236298
f0103b0a:	66 c7 05 9a 62 23 f0 	movw   $0x8,0xf023629a
f0103b11:	08 00 
f0103b13:	c6 05 9c 62 23 f0 00 	movb   $0x0,0xf023629c
f0103b1a:	c6 05 9d 62 23 f0 8e 	movb   $0x8e,0xf023629d
f0103b21:	c1 e8 10             	shr    $0x10,%eax
f0103b24:	66 a3 9e 62 23 f0    	mov    %ax,0xf023629e
	SETGATE(idt[T_DBLFLT], 0, GD_KT, dblflt_entry, 0);
f0103b2a:	b8 e4 43 10 f0       	mov    $0xf01043e4,%eax
f0103b2f:	66 a3 a0 62 23 f0    	mov    %ax,0xf02362a0
f0103b35:	66 c7 05 a2 62 23 f0 	movw   $0x8,0xf02362a2
f0103b3c:	08 00 
f0103b3e:	c6 05 a4 62 23 f0 00 	movb   $0x0,0xf02362a4
f0103b45:	c6 05 a5 62 23 f0 8e 	movb   $0x8e,0xf02362a5
f0103b4c:	c1 e8 10             	shr    $0x10,%eax
f0103b4f:	66 a3 a6 62 23 f0    	mov    %ax,0xf02362a6
	SETGATE(idt[T_TSS], 0, GD_KT, tss_entry, 0);
f0103b55:	b8 e8 43 10 f0       	mov    $0xf01043e8,%eax
f0103b5a:	66 a3 b0 62 23 f0    	mov    %ax,0xf02362b0
f0103b60:	66 c7 05 b2 62 23 f0 	movw   $0x8,0xf02362b2
f0103b67:	08 00 
f0103b69:	c6 05 b4 62 23 f0 00 	movb   $0x0,0xf02362b4
f0103b70:	c6 05 b5 62 23 f0 8e 	movb   $0x8e,0xf02362b5
f0103b77:	c1 e8 10             	shr    $0x10,%eax
f0103b7a:	66 a3 b6 62 23 f0    	mov    %ax,0xf02362b6
	SETGATE(idt[T_SEGNP], 0, GD_KT, segnp_entry, 0);
f0103b80:	b8 ec 43 10 f0       	mov    $0xf01043ec,%eax
f0103b85:	66 a3 b8 62 23 f0    	mov    %ax,0xf02362b8
f0103b8b:	66 c7 05 ba 62 23 f0 	movw   $0x8,0xf02362ba
f0103b92:	08 00 
f0103b94:	c6 05 bc 62 23 f0 00 	movb   $0x0,0xf02362bc
f0103b9b:	c6 05 bd 62 23 f0 8e 	movb   $0x8e,0xf02362bd
f0103ba2:	c1 e8 10             	shr    $0x10,%eax
f0103ba5:	66 a3 be 62 23 f0    	mov    %ax,0xf02362be
	SETGATE(idt[T_STACK], 0, GD_KT, stack_entry, 0);
f0103bab:	b8 f0 43 10 f0       	mov    $0xf01043f0,%eax
f0103bb0:	66 a3 c0 62 23 f0    	mov    %ax,0xf02362c0
f0103bb6:	66 c7 05 c2 62 23 f0 	movw   $0x8,0xf02362c2
f0103bbd:	08 00 
f0103bbf:	c6 05 c4 62 23 f0 00 	movb   $0x0,0xf02362c4
f0103bc6:	c6 05 c5 62 23 f0 8e 	movb   $0x8e,0xf02362c5
f0103bcd:	c1 e8 10             	shr    $0x10,%eax
f0103bd0:	66 a3 c6 62 23 f0    	mov    %ax,0xf02362c6
	SETGATE(idt[T_GPFLT], 0, GD_KT, gpflt_entry, 0);
f0103bd6:	b8 f4 43 10 f0       	mov    $0xf01043f4,%eax
f0103bdb:	66 a3 c8 62 23 f0    	mov    %ax,0xf02362c8
f0103be1:	66 c7 05 ca 62 23 f0 	movw   $0x8,0xf02362ca
f0103be8:	08 00 
f0103bea:	c6 05 cc 62 23 f0 00 	movb   $0x0,0xf02362cc
f0103bf1:	c6 05 cd 62 23 f0 8e 	movb   $0x8e,0xf02362cd
f0103bf8:	c1 e8 10             	shr    $0x10,%eax
f0103bfb:	66 a3 ce 62 23 f0    	mov    %ax,0xf02362ce
	SETGATE(idt[T_PGFLT], 0, GD_KT, pgflt_entry, 0);
f0103c01:	b8 f8 43 10 f0       	mov    $0xf01043f8,%eax
f0103c06:	66 a3 d0 62 23 f0    	mov    %ax,0xf02362d0
f0103c0c:	66 c7 05 d2 62 23 f0 	movw   $0x8,0xf02362d2
f0103c13:	08 00 
f0103c15:	c6 05 d4 62 23 f0 00 	movb   $0x0,0xf02362d4
f0103c1c:	c6 05 d5 62 23 f0 8e 	movb   $0x8e,0xf02362d5
f0103c23:	c1 e8 10             	shr    $0x10,%eax
f0103c26:	66 a3 d6 62 23 f0    	mov    %ax,0xf02362d6
	SETGATE(idt[T_FPERR], 0, GD_KT, fperr_entry, 0);
f0103c2c:	b8 fc 43 10 f0       	mov    $0xf01043fc,%eax
f0103c31:	66 a3 e0 62 23 f0    	mov    %ax,0xf02362e0
f0103c37:	66 c7 05 e2 62 23 f0 	movw   $0x8,0xf02362e2
f0103c3e:	08 00 
f0103c40:	c6 05 e4 62 23 f0 00 	movb   $0x0,0xf02362e4
f0103c47:	c6 05 e5 62 23 f0 8e 	movb   $0x8e,0xf02362e5
f0103c4e:	c1 e8 10             	shr    $0x10,%eax
f0103c51:	66 a3 e6 62 23 f0    	mov    %ax,0xf02362e6
	SETGATE(idt[T_ALIGN], 0, GD_KT, align_entry, 0);
f0103c57:	b8 02 44 10 f0       	mov    $0xf0104402,%eax
f0103c5c:	66 a3 e8 62 23 f0    	mov    %ax,0xf02362e8
f0103c62:	66 c7 05 ea 62 23 f0 	movw   $0x8,0xf02362ea
f0103c69:	08 00 
f0103c6b:	c6 05 ec 62 23 f0 00 	movb   $0x0,0xf02362ec
f0103c72:	c6 05 ed 62 23 f0 8e 	movb   $0x8e,0xf02362ed
f0103c79:	c1 e8 10             	shr    $0x10,%eax
f0103c7c:	66 a3 ee 62 23 f0    	mov    %ax,0xf02362ee
	SETGATE(idt[T_MCHK], 0, GD_KT, mchk_entry, 0);
f0103c82:	b8 06 44 10 f0       	mov    $0xf0104406,%eax
f0103c87:	66 a3 f0 62 23 f0    	mov    %ax,0xf02362f0
f0103c8d:	66 c7 05 f2 62 23 f0 	movw   $0x8,0xf02362f2
f0103c94:	08 00 
f0103c96:	c6 05 f4 62 23 f0 00 	movb   $0x0,0xf02362f4
f0103c9d:	c6 05 f5 62 23 f0 8e 	movb   $0x8e,0xf02362f5
f0103ca4:	c1 e8 10             	shr    $0x10,%eax
f0103ca7:	66 a3 f6 62 23 f0    	mov    %ax,0xf02362f6
	SETGATE(idt[T_SIMDERR], 0, GD_KT, simderr_entry, 0);
f0103cad:	b8 0c 44 10 f0       	mov    $0xf010440c,%eax
f0103cb2:	66 a3 f8 62 23 f0    	mov    %ax,0xf02362f8
f0103cb8:	66 c7 05 fa 62 23 f0 	movw   $0x8,0xf02362fa
f0103cbf:	08 00 
f0103cc1:	c6 05 fc 62 23 f0 00 	movb   $0x0,0xf02362fc
f0103cc8:	c6 05 fd 62 23 f0 8e 	movb   $0x8e,0xf02362fd
f0103ccf:	c1 e8 10             	shr    $0x10,%eax
f0103cd2:	66 a3 fe 62 23 f0    	mov    %ax,0xf02362fe
	SETGATE(idt[T_SYSCALL], 0, GD_KT, syscall_entry, 3);
f0103cd8:	b8 12 44 10 f0       	mov    $0xf0104412,%eax
f0103cdd:	66 a3 e0 63 23 f0    	mov    %ax,0xf02363e0
f0103ce3:	66 c7 05 e2 63 23 f0 	movw   $0x8,0xf02363e2
f0103cea:	08 00 
f0103cec:	c6 05 e4 63 23 f0 00 	movb   $0x0,0xf02363e4
f0103cf3:	c6 05 e5 63 23 f0 ee 	movb   $0xee,0xf02363e5
f0103cfa:	c1 e8 10             	shr    $0x10,%eax
f0103cfd:	66 a3 e6 63 23 f0    	mov    %ax,0xf02363e6
	SETGATE(idt[IRQ_OFFSET + IRQ_ERROR], 0, GD_KT, irq_error_handler, 3);
f0103d03:	b8 18 44 10 f0       	mov    $0xf0104418,%eax
f0103d08:	66 a3 f8 63 23 f0    	mov    %ax,0xf02363f8
f0103d0e:	66 c7 05 fa 63 23 f0 	movw   $0x8,0xf02363fa
f0103d15:	08 00 
f0103d17:	c6 05 fc 63 23 f0 00 	movb   $0x0,0xf02363fc
f0103d1e:	c6 05 fd 63 23 f0 ee 	movb   $0xee,0xf02363fd
f0103d25:	c1 e8 10             	shr    $0x10,%eax
f0103d28:	66 a3 fe 63 23 f0    	mov    %ax,0xf02363fe
	SETGATE(idt[IRQ_OFFSET + IRQ_IDE], 0, GD_KT, irq_ide_handler, 3);
f0103d2e:	b8 1e 44 10 f0       	mov    $0xf010441e,%eax
f0103d33:	66 a3 d0 63 23 f0    	mov    %ax,0xf02363d0
f0103d39:	66 c7 05 d2 63 23 f0 	movw   $0x8,0xf02363d2
f0103d40:	08 00 
f0103d42:	c6 05 d4 63 23 f0 00 	movb   $0x0,0xf02363d4
f0103d49:	c6 05 d5 63 23 f0 ee 	movb   $0xee,0xf02363d5
f0103d50:	c1 e8 10             	shr    $0x10,%eax
f0103d53:	66 a3 d6 63 23 f0    	mov    %ax,0xf02363d6
	SETGATE(idt[IRQ_OFFSET + IRQ_KBD], 0, GD_KT, irq_kbd_handler, 3);
f0103d59:	b8 24 44 10 f0       	mov    $0xf0104424,%eax
f0103d5e:	66 a3 68 63 23 f0    	mov    %ax,0xf0236368
f0103d64:	66 c7 05 6a 63 23 f0 	movw   $0x8,0xf023636a
f0103d6b:	08 00 
f0103d6d:	c6 05 6c 63 23 f0 00 	movb   $0x0,0xf023636c
f0103d74:	c6 05 6d 63 23 f0 ee 	movb   $0xee,0xf023636d
f0103d7b:	c1 e8 10             	shr    $0x10,%eax
f0103d7e:	66 a3 6e 63 23 f0    	mov    %ax,0xf023636e
	SETGATE(idt[IRQ_OFFSET + IRQ_SERIAL], 0, GD_KT, irq_serial_handler, 3);
f0103d84:	b8 2a 44 10 f0       	mov    $0xf010442a,%eax
f0103d89:	66 a3 80 63 23 f0    	mov    %ax,0xf0236380
f0103d8f:	66 c7 05 82 63 23 f0 	movw   $0x8,0xf0236382
f0103d96:	08 00 
f0103d98:	c6 05 84 63 23 f0 00 	movb   $0x0,0xf0236384
f0103d9f:	c6 05 85 63 23 f0 ee 	movb   $0xee,0xf0236385
f0103da6:	c1 e8 10             	shr    $0x10,%eax
f0103da9:	66 a3 86 63 23 f0    	mov    %ax,0xf0236386
	SETGATE(idt[IRQ_OFFSET + IRQ_SPURIOUS], 0, GD_KT, irq_spurious_handler, 3);
f0103daf:	b8 30 44 10 f0       	mov    $0xf0104430,%eax
f0103db4:	66 a3 98 63 23 f0    	mov    %ax,0xf0236398
f0103dba:	66 c7 05 9a 63 23 f0 	movw   $0x8,0xf023639a
f0103dc1:	08 00 
f0103dc3:	c6 05 9c 63 23 f0 00 	movb   $0x0,0xf023639c
f0103dca:	c6 05 9d 63 23 f0 ee 	movb   $0xee,0xf023639d
f0103dd1:	c1 e8 10             	shr    $0x10,%eax
f0103dd4:	66 a3 9e 63 23 f0    	mov    %ax,0xf023639e
	SETGATE(idt[IRQ_OFFSET + IRQ_TIMER], 0, GD_KT, irq_timer_handler, 3);
f0103dda:	b8 36 44 10 f0       	mov    $0xf0104436,%eax
f0103ddf:	66 a3 60 63 23 f0    	mov    %ax,0xf0236360
f0103de5:	66 c7 05 62 63 23 f0 	movw   $0x8,0xf0236362
f0103dec:	08 00 
f0103dee:	c6 05 64 63 23 f0 00 	movb   $0x0,0xf0236364
f0103df5:	c6 05 65 63 23 f0 ee 	movb   $0xee,0xf0236365
f0103dfc:	c1 e8 10             	shr    $0x10,%eax
f0103dff:	66 a3 66 63 23 f0    	mov    %ax,0xf0236366
	trap_init_percpu();
f0103e05:	e8 ec fa ff ff       	call   f01038f6 <trap_init_percpu>
}
f0103e0a:	c9                   	leave  
f0103e0b:	c3                   	ret    

f0103e0c <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f0103e0c:	f3 0f 1e fb          	endbr32 
f0103e10:	55                   	push   %ebp
f0103e11:	89 e5                	mov    %esp,%ebp
f0103e13:	53                   	push   %ebx
f0103e14:	83 ec 0c             	sub    $0xc,%esp
f0103e17:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f0103e1a:	ff 33                	pushl  (%ebx)
f0103e1c:	68 7c 76 10 f0       	push   $0xf010767c
f0103e21:	e8 b8 fa ff ff       	call   f01038de <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0103e26:	83 c4 08             	add    $0x8,%esp
f0103e29:	ff 73 04             	pushl  0x4(%ebx)
f0103e2c:	68 8b 76 10 f0       	push   $0xf010768b
f0103e31:	e8 a8 fa ff ff       	call   f01038de <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0103e36:	83 c4 08             	add    $0x8,%esp
f0103e39:	ff 73 08             	pushl  0x8(%ebx)
f0103e3c:	68 9a 76 10 f0       	push   $0xf010769a
f0103e41:	e8 98 fa ff ff       	call   f01038de <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0103e46:	83 c4 08             	add    $0x8,%esp
f0103e49:	ff 73 0c             	pushl  0xc(%ebx)
f0103e4c:	68 a9 76 10 f0       	push   $0xf01076a9
f0103e51:	e8 88 fa ff ff       	call   f01038de <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0103e56:	83 c4 08             	add    $0x8,%esp
f0103e59:	ff 73 10             	pushl  0x10(%ebx)
f0103e5c:	68 b8 76 10 f0       	push   $0xf01076b8
f0103e61:	e8 78 fa ff ff       	call   f01038de <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0103e66:	83 c4 08             	add    $0x8,%esp
f0103e69:	ff 73 14             	pushl  0x14(%ebx)
f0103e6c:	68 c7 76 10 f0       	push   $0xf01076c7
f0103e71:	e8 68 fa ff ff       	call   f01038de <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0103e76:	83 c4 08             	add    $0x8,%esp
f0103e79:	ff 73 18             	pushl  0x18(%ebx)
f0103e7c:	68 d6 76 10 f0       	push   $0xf01076d6
f0103e81:	e8 58 fa ff ff       	call   f01038de <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0103e86:	83 c4 08             	add    $0x8,%esp
f0103e89:	ff 73 1c             	pushl  0x1c(%ebx)
f0103e8c:	68 e5 76 10 f0       	push   $0xf01076e5
f0103e91:	e8 48 fa ff ff       	call   f01038de <cprintf>
}
f0103e96:	83 c4 10             	add    $0x10,%esp
f0103e99:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103e9c:	c9                   	leave  
f0103e9d:	c3                   	ret    

f0103e9e <print_trapframe>:
{
f0103e9e:	f3 0f 1e fb          	endbr32 
f0103ea2:	55                   	push   %ebp
f0103ea3:	89 e5                	mov    %esp,%ebp
f0103ea5:	56                   	push   %esi
f0103ea6:	53                   	push   %ebx
f0103ea7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f0103eaa:	e8 53 1e 00 00       	call   f0105d02 <cpunum>
f0103eaf:	83 ec 04             	sub    $0x4,%esp
f0103eb2:	50                   	push   %eax
f0103eb3:	53                   	push   %ebx
f0103eb4:	68 49 77 10 f0       	push   $0xf0107749
f0103eb9:	e8 20 fa ff ff       	call   f01038de <cprintf>
	print_regs(&tf->tf_regs);
f0103ebe:	89 1c 24             	mov    %ebx,(%esp)
f0103ec1:	e8 46 ff ff ff       	call   f0103e0c <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f0103ec6:	83 c4 08             	add    $0x8,%esp
f0103ec9:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f0103ecd:	50                   	push   %eax
f0103ece:	68 67 77 10 f0       	push   $0xf0107767
f0103ed3:	e8 06 fa ff ff       	call   f01038de <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f0103ed8:	83 c4 08             	add    $0x8,%esp
f0103edb:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f0103edf:	50                   	push   %eax
f0103ee0:	68 7a 77 10 f0       	push   $0xf010777a
f0103ee5:	e8 f4 f9 ff ff       	call   f01038de <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103eea:	8b 43 28             	mov    0x28(%ebx),%eax
	if (trapno < ARRAY_SIZE(excnames))
f0103eed:	83 c4 10             	add    $0x10,%esp
f0103ef0:	83 f8 13             	cmp    $0x13,%eax
f0103ef3:	0f 86 da 00 00 00    	jbe    f0103fd3 <print_trapframe+0x135>
		return "System call";
f0103ef9:	ba f4 76 10 f0       	mov    $0xf01076f4,%edx
	if (trapno == T_SYSCALL)
f0103efe:	83 f8 30             	cmp    $0x30,%eax
f0103f01:	74 13                	je     f0103f16 <print_trapframe+0x78>
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f0103f03:	8d 50 e0             	lea    -0x20(%eax),%edx
		return "Hardware Interrupt";
f0103f06:	83 fa 0f             	cmp    $0xf,%edx
f0103f09:	ba 00 77 10 f0       	mov    $0xf0107700,%edx
f0103f0e:	b9 0f 77 10 f0       	mov    $0xf010770f,%ecx
f0103f13:	0f 46 d1             	cmovbe %ecx,%edx
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103f16:	83 ec 04             	sub    $0x4,%esp
f0103f19:	52                   	push   %edx
f0103f1a:	50                   	push   %eax
f0103f1b:	68 8d 77 10 f0       	push   $0xf010778d
f0103f20:	e8 b9 f9 ff ff       	call   f01038de <cprintf>
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0103f25:	83 c4 10             	add    $0x10,%esp
f0103f28:	39 1d 60 6a 23 f0    	cmp    %ebx,0xf0236a60
f0103f2e:	0f 84 ab 00 00 00    	je     f0103fdf <print_trapframe+0x141>
	cprintf("  err  0x%08x", tf->tf_err);
f0103f34:	83 ec 08             	sub    $0x8,%esp
f0103f37:	ff 73 2c             	pushl  0x2c(%ebx)
f0103f3a:	68 ae 77 10 f0       	push   $0xf01077ae
f0103f3f:	e8 9a f9 ff ff       	call   f01038de <cprintf>
	if (tf->tf_trapno == T_PGFLT)
f0103f44:	83 c4 10             	add    $0x10,%esp
f0103f47:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103f4b:	0f 85 b1 00 00 00    	jne    f0104002 <print_trapframe+0x164>
			tf->tf_err & 1 ? "protection" : "not-present");
f0103f51:	8b 43 2c             	mov    0x2c(%ebx),%eax
		cprintf(" [%s, %s, %s]\n",
f0103f54:	a8 01                	test   $0x1,%al
f0103f56:	b9 22 77 10 f0       	mov    $0xf0107722,%ecx
f0103f5b:	ba 2d 77 10 f0       	mov    $0xf010772d,%edx
f0103f60:	0f 44 ca             	cmove  %edx,%ecx
f0103f63:	a8 02                	test   $0x2,%al
f0103f65:	be 39 77 10 f0       	mov    $0xf0107739,%esi
f0103f6a:	ba 3f 77 10 f0       	mov    $0xf010773f,%edx
f0103f6f:	0f 45 d6             	cmovne %esi,%edx
f0103f72:	a8 04                	test   $0x4,%al
f0103f74:	b8 44 77 10 f0       	mov    $0xf0107744,%eax
f0103f79:	be 76 78 10 f0       	mov    $0xf0107876,%esi
f0103f7e:	0f 44 c6             	cmove  %esi,%eax
f0103f81:	51                   	push   %ecx
f0103f82:	52                   	push   %edx
f0103f83:	50                   	push   %eax
f0103f84:	68 bc 77 10 f0       	push   $0xf01077bc
f0103f89:	e8 50 f9 ff ff       	call   f01038de <cprintf>
f0103f8e:	83 c4 10             	add    $0x10,%esp
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f0103f91:	83 ec 08             	sub    $0x8,%esp
f0103f94:	ff 73 30             	pushl  0x30(%ebx)
f0103f97:	68 cb 77 10 f0       	push   $0xf01077cb
f0103f9c:	e8 3d f9 ff ff       	call   f01038de <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f0103fa1:	83 c4 08             	add    $0x8,%esp
f0103fa4:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f0103fa8:	50                   	push   %eax
f0103fa9:	68 da 77 10 f0       	push   $0xf01077da
f0103fae:	e8 2b f9 ff ff       	call   f01038de <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f0103fb3:	83 c4 08             	add    $0x8,%esp
f0103fb6:	ff 73 38             	pushl  0x38(%ebx)
f0103fb9:	68 ed 77 10 f0       	push   $0xf01077ed
f0103fbe:	e8 1b f9 ff ff       	call   f01038de <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f0103fc3:	83 c4 10             	add    $0x10,%esp
f0103fc6:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0103fca:	75 4b                	jne    f0104017 <print_trapframe+0x179>
}
f0103fcc:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103fcf:	5b                   	pop    %ebx
f0103fd0:	5e                   	pop    %esi
f0103fd1:	5d                   	pop    %ebp
f0103fd2:	c3                   	ret    
		return excnames[trapno];
f0103fd3:	8b 14 85 40 7a 10 f0 	mov    -0xfef85c0(,%eax,4),%edx
f0103fda:	e9 37 ff ff ff       	jmp    f0103f16 <print_trapframe+0x78>
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0103fdf:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103fe3:	0f 85 4b ff ff ff    	jne    f0103f34 <print_trapframe+0x96>
	asm volatile("movl %%cr2,%0" : "=r" (val));
f0103fe9:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f0103fec:	83 ec 08             	sub    $0x8,%esp
f0103fef:	50                   	push   %eax
f0103ff0:	68 9f 77 10 f0       	push   $0xf010779f
f0103ff5:	e8 e4 f8 ff ff       	call   f01038de <cprintf>
f0103ffa:	83 c4 10             	add    $0x10,%esp
f0103ffd:	e9 32 ff ff ff       	jmp    f0103f34 <print_trapframe+0x96>
		cprintf("\n");
f0104002:	83 ec 0c             	sub    $0xc,%esp
f0104005:	68 db 68 10 f0       	push   $0xf01068db
f010400a:	e8 cf f8 ff ff       	call   f01038de <cprintf>
f010400f:	83 c4 10             	add    $0x10,%esp
f0104012:	e9 7a ff ff ff       	jmp    f0103f91 <print_trapframe+0xf3>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f0104017:	83 ec 08             	sub    $0x8,%esp
f010401a:	ff 73 3c             	pushl  0x3c(%ebx)
f010401d:	68 fc 77 10 f0       	push   $0xf01077fc
f0104022:	e8 b7 f8 ff ff       	call   f01038de <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f0104027:	83 c4 08             	add    $0x8,%esp
f010402a:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f010402e:	50                   	push   %eax
f010402f:	68 0b 78 10 f0       	push   $0xf010780b
f0104034:	e8 a5 f8 ff ff       	call   f01038de <cprintf>
f0104039:	83 c4 10             	add    $0x10,%esp
}
f010403c:	eb 8e                	jmp    f0103fcc <print_trapframe+0x12e>

f010403e <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f010403e:	f3 0f 1e fb          	endbr32 
f0104042:	55                   	push   %ebp
f0104043:	89 e5                	mov    %esp,%ebp
f0104045:	57                   	push   %edi
f0104046:	56                   	push   %esi
f0104047:	53                   	push   %ebx
f0104048:	83 ec 24             	sub    $0x24,%esp
f010404b:	8b 5d 08             	mov    0x8(%ebp),%ebx
f010404e:	0f 20 d6             	mov    %cr2,%esi
	uint32_t fault_va;

	// Read processor's CR2 register to find the faulting address
	fault_va = rcr2();
	cprintf("Page fault at address: 0x%08x\n", fault_va);
f0104051:	56                   	push   %esi
f0104052:	68 c0 79 10 f0       	push   $0xf01079c0
f0104057:	e8 82 f8 ff ff       	call   f01038de <cprintf>

	// Handle kernel-mode page faults.
	// LAB 3: Your code here.
	if((tf->tf_cs&3)==0){
f010405c:	83 c4 10             	add    $0x10,%esp
f010405f:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0104063:	74 5d                	je     f01040c2 <page_fault_handler+0x84>
	//   user_mem_assert() and env_run() are useful here.
	//   To change what the user environment runs, modify 'curenv->env_tf'
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.
	if(curenv->env_pgfault_upcall){
f0104065:	e8 98 1c 00 00       	call   f0105d02 <cpunum>
f010406a:	6b c0 74             	imul   $0x74,%eax,%eax
f010406d:	8b 80 28 70 23 f0    	mov    -0xfdc8fd8(%eax),%eax
f0104073:	83 78 64 00          	cmpl   $0x0,0x64(%eax)
f0104077:	75 5e                	jne    f01040d7 <page_fault_handler+0x99>
		curenv->env_tf.tf_esp=(uintptr_t)utf;
		env_run(curenv);
	}

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0104079:	8b 7b 30             	mov    0x30(%ebx),%edi
		curenv->env_id, fault_va, tf->tf_eip);
f010407c:	e8 81 1c 00 00       	call   f0105d02 <cpunum>
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0104081:	57                   	push   %edi
f0104082:	56                   	push   %esi
		curenv->env_id, fault_va, tf->tf_eip);
f0104083:	6b c0 74             	imul   $0x74,%eax,%eax
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0104086:	8b 80 28 70 23 f0    	mov    -0xfdc8fd8(%eax),%eax
f010408c:	ff 70 48             	pushl  0x48(%eax)
f010408f:	68 10 7a 10 f0       	push   $0xf0107a10
f0104094:	e8 45 f8 ff ff       	call   f01038de <cprintf>
	print_trapframe(tf);
f0104099:	89 1c 24             	mov    %ebx,(%esp)
f010409c:	e8 fd fd ff ff       	call   f0103e9e <print_trapframe>
	env_destroy(curenv);
f01040a1:	e8 5c 1c 00 00       	call   f0105d02 <cpunum>
f01040a6:	83 c4 04             	add    $0x4,%esp
f01040a9:	6b c0 74             	imul   $0x74,%eax,%eax
f01040ac:	ff b0 28 70 23 f0    	pushl  -0xfdc8fd8(%eax)
f01040b2:	e8 02 f5 ff ff       	call   f01035b9 <env_destroy>
}
f01040b7:	83 c4 10             	add    $0x10,%esp
f01040ba:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01040bd:	5b                   	pop    %ebx
f01040be:	5e                   	pop    %esi
f01040bf:	5f                   	pop    %edi
f01040c0:	5d                   	pop    %ebp
f01040c1:	c3                   	ret    
		panic("page_fault in kernal mode, fault address %08x\n", fault_va);
f01040c2:	56                   	push   %esi
f01040c3:	68 e0 79 10 f0       	push   $0xf01079e0
f01040c8:	68 60 01 00 00       	push   $0x160
f01040cd:	68 1e 78 10 f0       	push   $0xf010781e
f01040d2:	e8 69 bf ff ff       	call   f0100040 <_panic>
		if(tf->tf_esp>UXSTACKTOP-PGSIZE && tf->tf_esp<UXSTACKTOP){
f01040d7:	8b 7b 3c             	mov    0x3c(%ebx),%edi
f01040da:	8d 87 ff 0f 40 11    	lea    0x11400fff(%edi),%eax
		uintptr_t stacktop=UXSTACKTOP;
f01040e0:	3d ff 0f 00 00       	cmp    $0xfff,%eax
f01040e5:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
f01040ea:	0f 43 f8             	cmovae %eax,%edi
		user_mem_assert(curenv, (void *)(stacktop-size), size, PTE_U|PTE_W);
f01040ed:	8d 57 c8             	lea    -0x38(%edi),%edx
f01040f0:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f01040f3:	e8 0a 1c 00 00       	call   f0105d02 <cpunum>
f01040f8:	6a 06                	push   $0x6
f01040fa:	6a 38                	push   $0x38
f01040fc:	ff 75 e4             	pushl  -0x1c(%ebp)
f01040ff:	6b c0 74             	imul   $0x74,%eax,%eax
f0104102:	ff b0 28 70 23 f0    	pushl  -0xfdc8fd8(%eax)
f0104108:	e8 e5 ed ff ff       	call   f0102ef2 <user_mem_assert>
		utf->utf_fault_va=fault_va;
f010410d:	89 77 c8             	mov    %esi,-0x38(%edi)
		utf->utf_err=tf->tf_err;
f0104110:	8b 43 2c             	mov    0x2c(%ebx),%eax
f0104113:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104116:	89 42 04             	mov    %eax,0x4(%edx)
		utf->utf_regs=tf->tf_regs;
f0104119:	83 ef 30             	sub    $0x30,%edi
f010411c:	b9 08 00 00 00       	mov    $0x8,%ecx
f0104121:	89 de                	mov    %ebx,%esi
f0104123:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		utf->utf_eip=tf->tf_eip;
f0104125:	8b 43 30             	mov    0x30(%ebx),%eax
f0104128:	89 42 28             	mov    %eax,0x28(%edx)
		utf->utf_eflags=tf->tf_eflags;
f010412b:	8b 43 38             	mov    0x38(%ebx),%eax
f010412e:	89 d7                	mov    %edx,%edi
f0104130:	89 42 2c             	mov    %eax,0x2c(%edx)
		utf->utf_esp=tf->tf_esp;
f0104133:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0104136:	89 42 30             	mov    %eax,0x30(%edx)
		curenv->env_tf.tf_eip=(uintptr_t)curenv->env_pgfault_upcall;
f0104139:	e8 c4 1b 00 00       	call   f0105d02 <cpunum>
f010413e:	6b c0 74             	imul   $0x74,%eax,%eax
f0104141:	8b 80 28 70 23 f0    	mov    -0xfdc8fd8(%eax),%eax
f0104147:	8b 58 64             	mov    0x64(%eax),%ebx
f010414a:	e8 b3 1b 00 00       	call   f0105d02 <cpunum>
f010414f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104152:	8b 80 28 70 23 f0    	mov    -0xfdc8fd8(%eax),%eax
f0104158:	89 58 30             	mov    %ebx,0x30(%eax)
		curenv->env_tf.tf_esp=(uintptr_t)utf;
f010415b:	e8 a2 1b 00 00       	call   f0105d02 <cpunum>
f0104160:	6b c0 74             	imul   $0x74,%eax,%eax
f0104163:	8b 80 28 70 23 f0    	mov    -0xfdc8fd8(%eax),%eax
f0104169:	89 78 3c             	mov    %edi,0x3c(%eax)
		env_run(curenv);
f010416c:	e8 91 1b 00 00       	call   f0105d02 <cpunum>
f0104171:	83 c4 04             	add    $0x4,%esp
f0104174:	6b c0 74             	imul   $0x74,%eax,%eax
f0104177:	ff b0 28 70 23 f0    	pushl  -0xfdc8fd8(%eax)
f010417d:	e8 de f4 ff ff       	call   f0103660 <env_run>

f0104182 <trap>:
{
f0104182:	f3 0f 1e fb          	endbr32 
f0104186:	55                   	push   %ebp
f0104187:	89 e5                	mov    %esp,%ebp
f0104189:	57                   	push   %edi
f010418a:	56                   	push   %esi
f010418b:	8b 75 08             	mov    0x8(%ebp),%esi
	asm volatile("cld" ::: "cc");
f010418e:	fc                   	cld    
	if (panicstr)
f010418f:	83 3d 80 6e 23 f0 00 	cmpl   $0x0,0xf0236e80
f0104196:	74 01                	je     f0104199 <trap+0x17>
		asm volatile("hlt");
f0104198:	f4                   	hlt    
	if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
f0104199:	e8 64 1b 00 00       	call   f0105d02 <cpunum>
f010419e:	6b d0 74             	imul   $0x74,%eax,%edx
f01041a1:	83 c2 04             	add    $0x4,%edx
	asm volatile("lock; xchgl %0, %1"
f01041a4:	b8 01 00 00 00       	mov    $0x1,%eax
f01041a9:	f0 87 82 20 70 23 f0 	lock xchg %eax,-0xfdc8fe0(%edx)
f01041b0:	83 f8 02             	cmp    $0x2,%eax
f01041b3:	74 7e                	je     f0104233 <trap+0xb1>
	asm volatile("pushfl; popl %0" : "=r" (eflags));
f01041b5:	9c                   	pushf  
f01041b6:	58                   	pop    %eax
	assert(!(read_eflags() & FL_IF));
f01041b7:	f6 c4 02             	test   $0x2,%ah
f01041ba:	0f 85 88 00 00 00    	jne    f0104248 <trap+0xc6>
	if ((tf->tf_cs & 3) == 3) {
f01041c0:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f01041c4:	83 e0 03             	and    $0x3,%eax
f01041c7:	66 83 f8 03          	cmp    $0x3,%ax
f01041cb:	0f 84 90 00 00 00    	je     f0104261 <trap+0xdf>
	last_tf = tf;
f01041d1:	89 35 60 6a 23 f0    	mov    %esi,0xf0236a60
	switch(tf->tf_trapno){
f01041d7:	8b 46 28             	mov    0x28(%esi),%eax
f01041da:	83 f8 0e             	cmp    $0xe,%eax
f01041dd:	0f 84 23 01 00 00    	je     f0104306 <trap+0x184>
f01041e3:	83 f8 30             	cmp    $0x30,%eax
f01041e6:	0f 84 5e 01 00 00    	je     f010434a <trap+0x1c8>
f01041ec:	83 f8 03             	cmp    $0x3,%eax
f01041ef:	0f 84 47 01 00 00    	je     f010433c <trap+0x1ba>
			if(tf->tf_trapno == IRQ_OFFSET+IRQ_TIMER){
f01041f5:	83 f8 20             	cmp    $0x20,%eax
f01041f8:	0f 84 6d 01 00 00    	je     f010436b <trap+0x1e9>
				print_trapframe(tf);
f01041fe:	83 ec 0c             	sub    $0xc,%esp
f0104201:	56                   	push   %esi
f0104202:	e8 97 fc ff ff       	call   f0103e9e <print_trapframe>
				if (tf->tf_cs == GD_KT)
f0104207:	83 c4 10             	add    $0x10,%esp
f010420a:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f010420f:	0f 84 6d 01 00 00    	je     f0104382 <trap+0x200>
					env_destroy(curenv);
f0104215:	e8 e8 1a 00 00       	call   f0105d02 <cpunum>
f010421a:	83 ec 0c             	sub    $0xc,%esp
f010421d:	6b c0 74             	imul   $0x74,%eax,%eax
f0104220:	ff b0 28 70 23 f0    	pushl  -0xfdc8fd8(%eax)
f0104226:	e8 8e f3 ff ff       	call   f01035b9 <env_destroy>
					return;
f010422b:	83 c4 10             	add    $0x10,%esp
f010422e:	e9 df 00 00 00       	jmp    f0104312 <trap+0x190>
	spin_lock(&kernel_lock);
f0104233:	83 ec 0c             	sub    $0xc,%esp
f0104236:	68 c0 23 12 f0       	push   $0xf01223c0
f010423b:	e8 4a 1d 00 00       	call   f0105f8a <spin_lock>
}
f0104240:	83 c4 10             	add    $0x10,%esp
f0104243:	e9 6d ff ff ff       	jmp    f01041b5 <trap+0x33>
	assert(!(read_eflags() & FL_IF));
f0104248:	68 2a 78 10 f0       	push   $0xf010782a
f010424d:	68 03 69 10 f0       	push   $0xf0106903
f0104252:	68 2a 01 00 00       	push   $0x12a
f0104257:	68 1e 78 10 f0       	push   $0xf010781e
f010425c:	e8 df bd ff ff       	call   f0100040 <_panic>
		assert(curenv);
f0104261:	e8 9c 1a 00 00       	call   f0105d02 <cpunum>
f0104266:	6b c0 74             	imul   $0x74,%eax,%eax
f0104269:	83 b8 28 70 23 f0 00 	cmpl   $0x0,-0xfdc8fd8(%eax)
f0104270:	74 4e                	je     f01042c0 <trap+0x13e>
	spin_lock(&kernel_lock);
f0104272:	83 ec 0c             	sub    $0xc,%esp
f0104275:	68 c0 23 12 f0       	push   $0xf01223c0
f010427a:	e8 0b 1d 00 00       	call   f0105f8a <spin_lock>
		if (curenv->env_status == ENV_DYING) {
f010427f:	e8 7e 1a 00 00       	call   f0105d02 <cpunum>
f0104284:	6b c0 74             	imul   $0x74,%eax,%eax
f0104287:	8b 80 28 70 23 f0    	mov    -0xfdc8fd8(%eax),%eax
f010428d:	83 c4 10             	add    $0x10,%esp
f0104290:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f0104294:	74 43                	je     f01042d9 <trap+0x157>
		curenv->env_tf = *tf;
f0104296:	e8 67 1a 00 00       	call   f0105d02 <cpunum>
f010429b:	6b c0 74             	imul   $0x74,%eax,%eax
f010429e:	8b 80 28 70 23 f0    	mov    -0xfdc8fd8(%eax),%eax
f01042a4:	b9 11 00 00 00       	mov    $0x11,%ecx
f01042a9:	89 c7                	mov    %eax,%edi
f01042ab:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		tf = &curenv->env_tf;
f01042ad:	e8 50 1a 00 00       	call   f0105d02 <cpunum>
f01042b2:	6b c0 74             	imul   $0x74,%eax,%eax
f01042b5:	8b b0 28 70 23 f0    	mov    -0xfdc8fd8(%eax),%esi
f01042bb:	e9 11 ff ff ff       	jmp    f01041d1 <trap+0x4f>
		assert(curenv);
f01042c0:	68 43 78 10 f0       	push   $0xf0107843
f01042c5:	68 03 69 10 f0       	push   $0xf0106903
f01042ca:	68 31 01 00 00       	push   $0x131
f01042cf:	68 1e 78 10 f0       	push   $0xf010781e
f01042d4:	e8 67 bd ff ff       	call   f0100040 <_panic>
			env_free(curenv);
f01042d9:	e8 24 1a 00 00       	call   f0105d02 <cpunum>
f01042de:	83 ec 0c             	sub    $0xc,%esp
f01042e1:	6b c0 74             	imul   $0x74,%eax,%eax
f01042e4:	ff b0 28 70 23 f0    	pushl  -0xfdc8fd8(%eax)
f01042ea:	e8 e9 f0 ff ff       	call   f01033d8 <env_free>
			curenv = NULL;
f01042ef:	e8 0e 1a 00 00       	call   f0105d02 <cpunum>
f01042f4:	6b c0 74             	imul   $0x74,%eax,%eax
f01042f7:	c7 80 28 70 23 f0 00 	movl   $0x0,-0xfdc8fd8(%eax)
f01042fe:	00 00 00 
			sched_yield();
f0104301:	e8 16 02 00 00       	call   f010451c <sched_yield>
			page_fault_handler(tf);
f0104306:	83 ec 0c             	sub    $0xc,%esp
f0104309:	56                   	push   %esi
f010430a:	e8 2f fd ff ff       	call   f010403e <page_fault_handler>
			break;
f010430f:	83 c4 10             	add    $0x10,%esp
	if (curenv && curenv->env_status == ENV_RUNNING)
f0104312:	e8 eb 19 00 00       	call   f0105d02 <cpunum>
f0104317:	6b c0 74             	imul   $0x74,%eax,%eax
f010431a:	83 b8 28 70 23 f0 00 	cmpl   $0x0,-0xfdc8fd8(%eax)
f0104321:	74 14                	je     f0104337 <trap+0x1b5>
f0104323:	e8 da 19 00 00       	call   f0105d02 <cpunum>
f0104328:	6b c0 74             	imul   $0x74,%eax,%eax
f010432b:	8b 80 28 70 23 f0    	mov    -0xfdc8fd8(%eax),%eax
f0104331:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0104335:	74 62                	je     f0104399 <trap+0x217>
		sched_yield();
f0104337:	e8 e0 01 00 00       	call   f010451c <sched_yield>
			monitor(tf);
f010433c:	83 ec 0c             	sub    $0xc,%esp
f010433f:	56                   	push   %esi
f0104340:	e8 9f c5 ff ff       	call   f01008e4 <monitor>
			break;
f0104345:	83 c4 10             	add    $0x10,%esp
f0104348:	eb c8                	jmp    f0104312 <trap+0x190>
			ret_code=syscall(
f010434a:	83 ec 08             	sub    $0x8,%esp
f010434d:	ff 76 04             	pushl  0x4(%esi)
f0104350:	ff 36                	pushl  (%esi)
f0104352:	ff 76 10             	pushl  0x10(%esi)
f0104355:	ff 76 18             	pushl  0x18(%esi)
f0104358:	ff 76 14             	pushl  0x14(%esi)
f010435b:	ff 76 1c             	pushl  0x1c(%esi)
f010435e:	e8 74 02 00 00       	call   f01045d7 <syscall>
			tf->tf_regs.reg_eax=ret_code;
f0104363:	89 46 1c             	mov    %eax,0x1c(%esi)
			break;
f0104366:	83 c4 20             	add    $0x20,%esp
f0104369:	eb a7                	jmp    f0104312 <trap+0x190>
				cprintf("Timer interrupt on irq 0\n");
f010436b:	83 ec 0c             	sub    $0xc,%esp
f010436e:	68 4a 78 10 f0       	push   $0xf010784a
f0104373:	e8 66 f5 ff ff       	call   f01038de <cprintf>
				lapic_eoi();//开启IF标志位，接收外部中断
f0104378:	e8 d4 1a 00 00       	call   f0105e51 <lapic_eoi>
				sched_yield();//Choose a user environment to run and run it.
f010437d:	e8 9a 01 00 00       	call   f010451c <sched_yield>
					panic("unhandled trap in kernel");
f0104382:	83 ec 04             	sub    $0x4,%esp
f0104385:	68 64 78 10 f0       	push   $0xf0107864
f010438a:	68 0d 01 00 00       	push   $0x10d
f010438f:	68 1e 78 10 f0       	push   $0xf010781e
f0104394:	e8 a7 bc ff ff       	call   f0100040 <_panic>
		env_run(curenv);
f0104399:	e8 64 19 00 00       	call   f0105d02 <cpunum>
f010439e:	83 ec 0c             	sub    $0xc,%esp
f01043a1:	6b c0 74             	imul   $0x74,%eax,%eax
f01043a4:	ff b0 28 70 23 f0    	pushl  -0xfdc8fd8(%eax)
f01043aa:	e8 b1 f2 ff ff       	call   f0103660 <env_run>
f01043af:	90                   	nop

f01043b0 <divide_entry>:

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */
 .text
TRAPHANDLER_NOEC(divide_entry, T_DIVIDE);
f01043b0:	6a 00                	push   $0x0
f01043b2:	6a 00                	push   $0x0
f01043b4:	e9 83 00 00 00       	jmp    f010443c <_alltraps>
f01043b9:	90                   	nop

f01043ba <debug_entry>:
TRAPHANDLER_NOEC(debug_entry, T_DEBUG);
f01043ba:	6a 00                	push   $0x0
f01043bc:	6a 01                	push   $0x1
f01043be:	eb 7c                	jmp    f010443c <_alltraps>

f01043c0 <nmi_entry>:
TRAPHANDLER_NOEC(nmi_entry, T_NMI);
f01043c0:	6a 00                	push   $0x0
f01043c2:	6a 02                	push   $0x2
f01043c4:	eb 76                	jmp    f010443c <_alltraps>

f01043c6 <brkpt_entry>:
TRAPHANDLER_NOEC(brkpt_entry, T_BRKPT);
f01043c6:	6a 00                	push   $0x0
f01043c8:	6a 03                	push   $0x3
f01043ca:	eb 70                	jmp    f010443c <_alltraps>

f01043cc <oflow_entry>:
TRAPHANDLER_NOEC(oflow_entry, T_OFLOW);
f01043cc:	6a 00                	push   $0x0
f01043ce:	6a 04                	push   $0x4
f01043d0:	eb 6a                	jmp    f010443c <_alltraps>

f01043d2 <bound_entry>:
TRAPHANDLER_NOEC(bound_entry, T_BOUND);
f01043d2:	6a 00                	push   $0x0
f01043d4:	6a 05                	push   $0x5
f01043d6:	eb 64                	jmp    f010443c <_alltraps>

f01043d8 <illop_entry>:
TRAPHANDLER_NOEC(illop_entry, T_ILLOP);
f01043d8:	6a 00                	push   $0x0
f01043da:	6a 06                	push   $0x6
f01043dc:	eb 5e                	jmp    f010443c <_alltraps>

f01043de <device_entry>:
TRAPHANDLER_NOEC(device_entry, T_DEVICE);
f01043de:	6a 00                	push   $0x0
f01043e0:	6a 07                	push   $0x7
f01043e2:	eb 58                	jmp    f010443c <_alltraps>

f01043e4 <dblflt_entry>:
TRAPHANDLER(dblflt_entry, T_DBLFLT);
f01043e4:	6a 08                	push   $0x8
f01043e6:	eb 54                	jmp    f010443c <_alltraps>

f01043e8 <tss_entry>:
TRAPHANDLER(tss_entry, T_TSS);
f01043e8:	6a 0a                	push   $0xa
f01043ea:	eb 50                	jmp    f010443c <_alltraps>

f01043ec <segnp_entry>:
TRAPHANDLER(segnp_entry, T_SEGNP);
f01043ec:	6a 0b                	push   $0xb
f01043ee:	eb 4c                	jmp    f010443c <_alltraps>

f01043f0 <stack_entry>:
TRAPHANDLER(stack_entry, T_STACK);
f01043f0:	6a 0c                	push   $0xc
f01043f2:	eb 48                	jmp    f010443c <_alltraps>

f01043f4 <gpflt_entry>:
TRAPHANDLER(gpflt_entry, T_GPFLT);
f01043f4:	6a 0d                	push   $0xd
f01043f6:	eb 44                	jmp    f010443c <_alltraps>

f01043f8 <pgflt_entry>:
TRAPHANDLER(pgflt_entry, T_PGFLT);
f01043f8:	6a 0e                	push   $0xe
f01043fa:	eb 40                	jmp    f010443c <_alltraps>

f01043fc <fperr_entry>:
TRAPHANDLER_NOEC(fperr_entry, T_FPERR);
f01043fc:	6a 00                	push   $0x0
f01043fe:	6a 10                	push   $0x10
f0104400:	eb 3a                	jmp    f010443c <_alltraps>

f0104402 <align_entry>:
TRAPHANDLER(align_entry, T_ALIGN);
f0104402:	6a 11                	push   $0x11
f0104404:	eb 36                	jmp    f010443c <_alltraps>

f0104406 <mchk_entry>:
TRAPHANDLER_NOEC(mchk_entry, T_MCHK);
f0104406:	6a 00                	push   $0x0
f0104408:	6a 12                	push   $0x12
f010440a:	eb 30                	jmp    f010443c <_alltraps>

f010440c <simderr_entry>:
TRAPHANDLER_NOEC(simderr_entry, T_SIMDERR);
f010440c:	6a 00                	push   $0x0
f010440e:	6a 13                	push   $0x13
f0104410:	eb 2a                	jmp    f010443c <_alltraps>

f0104412 <syscall_entry>:
TRAPHANDLER_NOEC(syscall_entry, T_SYSCALL);
f0104412:	6a 00                	push   $0x0
f0104414:	6a 30                	push   $0x30
f0104416:	eb 24                	jmp    f010443c <_alltraps>

f0104418 <irq_error_handler>:

//LAB4, out IRQ
TRAPHANDLER_NOEC(irq_error_handler, IRQ_OFFSET+IRQ_ERROR)
f0104418:	6a 00                	push   $0x0
f010441a:	6a 33                	push   $0x33
f010441c:	eb 1e                	jmp    f010443c <_alltraps>

f010441e <irq_ide_handler>:
TRAPHANDLER_NOEC(irq_ide_handler, IRQ_OFFSET+IRQ_IDE)
f010441e:	6a 00                	push   $0x0
f0104420:	6a 2e                	push   $0x2e
f0104422:	eb 18                	jmp    f010443c <_alltraps>

f0104424 <irq_kbd_handler>:
TRAPHANDLER_NOEC(irq_kbd_handler, IRQ_OFFSET+IRQ_KBD)
f0104424:	6a 00                	push   $0x0
f0104426:	6a 21                	push   $0x21
f0104428:	eb 12                	jmp    f010443c <_alltraps>

f010442a <irq_serial_handler>:
TRAPHANDLER_NOEC(irq_serial_handler, IRQ_OFFSET+IRQ_SERIAL)
f010442a:	6a 00                	push   $0x0
f010442c:	6a 24                	push   $0x24
f010442e:	eb 0c                	jmp    f010443c <_alltraps>

f0104430 <irq_spurious_handler>:
TRAPHANDLER_NOEC(irq_spurious_handler, IRQ_OFFSET+IRQ_SPURIOUS)
f0104430:	6a 00                	push   $0x0
f0104432:	6a 27                	push   $0x27
f0104434:	eb 06                	jmp    f010443c <_alltraps>

f0104436 <irq_timer_handler>:
TRAPHANDLER_NOEC(irq_timer_handler, IRQ_OFFSET+IRQ_TIMER)
f0104436:	6a 00                	push   $0x0
f0104438:	6a 20                	push   $0x20
f010443a:	eb 00                	jmp    f010443c <_alltraps>

f010443c <_alltraps>:
/*
 * Lab 3: Your code here for _alltraps
 */
 .global _alltraps
 _alltraps:
 pushl %ds;
f010443c:	1e                   	push   %ds
 pushl %es;
f010443d:	06                   	push   %es
 pushal;
f010443e:	60                   	pusha  

 movl $GD_KD, %eax;
f010443f:	b8 10 00 00 00       	mov    $0x10,%eax
 movw %ax, %ds;
f0104444:	8e d8                	mov    %eax,%ds
 movw %ax, %es;
f0104446:	8e c0                	mov    %eax,%es

 pushl %esp;
f0104448:	54                   	push   %esp
 call trap
f0104449:	e8 34 fd ff ff       	call   f0104182 <trap>

f010444e <sched_halt>:
// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
{
f010444e:	f3 0f 1e fb          	endbr32 
f0104452:	55                   	push   %ebp
f0104453:	89 e5                	mov    %esp,%ebp
f0104455:	83 ec 08             	sub    $0x8,%esp
f0104458:	a1 44 62 23 f0       	mov    0xf0236244,%eax
f010445d:	8d 50 54             	lea    0x54(%eax),%edx
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f0104460:	b9 00 00 00 00       	mov    $0x0,%ecx
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
f0104465:	8b 02                	mov    (%edx),%eax
f0104467:	83 e8 01             	sub    $0x1,%eax
		if ((envs[i].env_status == ENV_RUNNABLE ||
f010446a:	83 f8 02             	cmp    $0x2,%eax
f010446d:	76 2d                	jbe    f010449c <sched_halt+0x4e>
	for (i = 0; i < NENV; i++) {
f010446f:	83 c1 01             	add    $0x1,%ecx
f0104472:	83 c2 7c             	add    $0x7c,%edx
f0104475:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f010447b:	75 e8                	jne    f0104465 <sched_halt+0x17>
		     envs[i].env_status == ENV_DYING))
			break;
	}
	if (i == NENV) {
		cprintf("No runnable environments in the system!\n");
f010447d:	83 ec 0c             	sub    $0xc,%esp
f0104480:	68 90 7a 10 f0       	push   $0xf0107a90
f0104485:	e8 54 f4 ff ff       	call   f01038de <cprintf>
f010448a:	83 c4 10             	add    $0x10,%esp
		while (1)
			monitor(NULL);
f010448d:	83 ec 0c             	sub    $0xc,%esp
f0104490:	6a 00                	push   $0x0
f0104492:	e8 4d c4 ff ff       	call   f01008e4 <monitor>
f0104497:	83 c4 10             	add    $0x10,%esp
f010449a:	eb f1                	jmp    f010448d <sched_halt+0x3f>
	}

	// Mark that no environment is running on this CPU
	curenv = NULL;
f010449c:	e8 61 18 00 00       	call   f0105d02 <cpunum>
f01044a1:	6b c0 74             	imul   $0x74,%eax,%eax
f01044a4:	c7 80 28 70 23 f0 00 	movl   $0x0,-0xfdc8fd8(%eax)
f01044ab:	00 00 00 
	lcr3(PADDR(kern_pgdir));
f01044ae:	a1 8c 6e 23 f0       	mov    0xf0236e8c,%eax
	if ((uint32_t)kva < KERNBASE)
f01044b3:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01044b8:	76 50                	jbe    f010450a <sched_halt+0xbc>
	return (physaddr_t)kva - KERNBASE;
f01044ba:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f01044bf:	0f 22 d8             	mov    %eax,%cr3

	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);
f01044c2:	e8 3b 18 00 00       	call   f0105d02 <cpunum>
f01044c7:	6b d0 74             	imul   $0x74,%eax,%edx
f01044ca:	83 c2 04             	add    $0x4,%edx
	asm volatile("lock; xchgl %0, %1"
f01044cd:	b8 02 00 00 00       	mov    $0x2,%eax
f01044d2:	f0 87 82 20 70 23 f0 	lock xchg %eax,-0xfdc8fe0(%edx)
	spin_unlock(&kernel_lock);
f01044d9:	83 ec 0c             	sub    $0xc,%esp
f01044dc:	68 c0 23 12 f0       	push   $0xf01223c0
f01044e1:	e8 42 1b 00 00       	call   f0106028 <spin_unlock>
	asm volatile("pause");
f01044e6:	f3 90                	pause  
		//sti指令是开中断，如手册中所述，我们在 bootloader 中第一条指令 cli 就屏蔽了外部中断，到目前为止还没有重新开启外部中断。
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
f01044e8:	e8 15 18 00 00       	call   f0105d02 <cpunum>
f01044ed:	6b c0 74             	imul   $0x74,%eax,%eax
	asm volatile (
f01044f0:	8b 80 30 70 23 f0    	mov    -0xfdc8fd0(%eax),%eax
f01044f6:	bd 00 00 00 00       	mov    $0x0,%ebp
f01044fb:	89 c4                	mov    %eax,%esp
f01044fd:	6a 00                	push   $0x0
f01044ff:	6a 00                	push   $0x0
f0104501:	fb                   	sti    
f0104502:	f4                   	hlt    
f0104503:	eb fd                	jmp    f0104502 <sched_halt+0xb4>
}
f0104505:	83 c4 10             	add    $0x10,%esp
f0104508:	c9                   	leave  
f0104509:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010450a:	50                   	push   %eax
f010450b:	68 c8 63 10 f0       	push   $0xf01063c8
f0104510:	6a 50                	push   $0x50
f0104512:	68 b9 7a 10 f0       	push   $0xf0107ab9
f0104517:	e8 24 bb ff ff       	call   f0100040 <_panic>

f010451c <sched_yield>:
{
f010451c:	f3 0f 1e fb          	endbr32 
f0104520:	55                   	push   %ebp
f0104521:	89 e5                	mov    %esp,%ebp
f0104523:	56                   	push   %esi
f0104524:	53                   	push   %ebx
	if(curenv)//从当前的env的下一个env开始尝试
f0104525:	e8 d8 17 00 00       	call   f0105d02 <cpunum>
f010452a:	6b c0 74             	imul   $0x74,%eax,%eax
	int begin = 0;
f010452d:	b9 00 00 00 00       	mov    $0x0,%ecx
	if(curenv)//从当前的env的下一个env开始尝试
f0104532:	83 b8 28 70 23 f0 00 	cmpl   $0x0,-0xfdc8fd8(%eax)
f0104539:	74 1a                	je     f0104555 <sched_yield+0x39>
		begin = ENVX(curenv->env_id) + 1;
f010453b:	e8 c2 17 00 00       	call   f0105d02 <cpunum>
f0104540:	6b c0 74             	imul   $0x74,%eax,%eax
f0104543:	8b 80 28 70 23 f0    	mov    -0xfdc8fd8(%eax),%eax
f0104549:	8b 48 48             	mov    0x48(%eax),%ecx
f010454c:	81 e1 ff 03 00 00    	and    $0x3ff,%ecx
f0104552:	83 c1 01             	add    $0x1,%ecx
		if(envs[index].env_status == ENV_RUNNABLE)
f0104555:	8b 1d 44 62 23 f0    	mov    0xf0236244,%ebx
f010455b:	89 ca                	mov    %ecx,%edx
f010455d:	81 c1 00 04 00 00    	add    $0x400,%ecx
		int index = (begin + i) % NENV;
f0104563:	89 d6                	mov    %edx,%esi
f0104565:	c1 fe 1f             	sar    $0x1f,%esi
f0104568:	c1 ee 16             	shr    $0x16,%esi
f010456b:	8d 04 32             	lea    (%edx,%esi,1),%eax
f010456e:	25 ff 03 00 00       	and    $0x3ff,%eax
f0104573:	29 f0                	sub    %esi,%eax
		if(envs[index].env_status == ENV_RUNNABLE)
f0104575:	6b c0 7c             	imul   $0x7c,%eax,%eax
f0104578:	01 d8                	add    %ebx,%eax
f010457a:	83 78 54 02          	cmpl   $0x2,0x54(%eax)
f010457e:	74 38                	je     f01045b8 <sched_yield+0x9c>
f0104580:	83 c2 01             	add    $0x1,%edx
	for(int i = 0 ; i < NENV; ++i)//遍历整个 envs 数组寻找 ENV_RUNNABLE 的环境
f0104583:	39 ca                	cmp    %ecx,%edx
f0104585:	75 dc                	jne    f0104563 <sched_yield+0x47>
	if(curenv && curenv->env_status == ENV_RUNNING)//如果之前的环境还没运行结束，即ENV_RUNNING，则继续执行之前的env
f0104587:	e8 76 17 00 00       	call   f0105d02 <cpunum>
f010458c:	6b c0 74             	imul   $0x74,%eax,%eax
f010458f:	83 b8 28 70 23 f0 00 	cmpl   $0x0,-0xfdc8fd8(%eax)
f0104596:	74 14                	je     f01045ac <sched_yield+0x90>
f0104598:	e8 65 17 00 00       	call   f0105d02 <cpunum>
f010459d:	6b c0 74             	imul   $0x74,%eax,%eax
f01045a0:	8b 80 28 70 23 f0    	mov    -0xfdc8fd8(%eax),%eax
f01045a6:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f01045aa:	74 15                	je     f01045c1 <sched_yield+0xa5>
	sched_halt();
f01045ac:	e8 9d fe ff ff       	call   f010444e <sched_halt>
}
f01045b1:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01045b4:	5b                   	pop    %ebx
f01045b5:	5e                   	pop    %esi
f01045b6:	5d                   	pop    %ebp
f01045b7:	c3                   	ret    
			env_run(&envs[index]);//env_run仍然是回归用户态的唯一出口
f01045b8:	83 ec 0c             	sub    $0xc,%esp
f01045bb:	50                   	push   %eax
f01045bc:	e8 9f f0 ff ff       	call   f0103660 <env_run>
		env_run(curenv);
f01045c1:	e8 3c 17 00 00       	call   f0105d02 <cpunum>
f01045c6:	83 ec 0c             	sub    $0xc,%esp
f01045c9:	6b c0 74             	imul   $0x74,%eax,%eax
f01045cc:	ff b0 28 70 23 f0    	pushl  -0xfdc8fd8(%eax)
f01045d2:	e8 89 f0 ff ff       	call   f0103660 <env_run>

f01045d7 <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f01045d7:	f3 0f 1e fb          	endbr32 
f01045db:	55                   	push   %ebp
f01045dc:	89 e5                	mov    %esp,%ebp
f01045de:	57                   	push   %edi
f01045df:	56                   	push   %esi
f01045e0:	53                   	push   %ebx
f01045e1:	83 ec 1c             	sub    $0x1c,%esp
f01045e4:	8b 45 08             	mov    0x8(%ebp),%eax
f01045e7:	8b 5d 10             	mov    0x10(%ebp),%ebx
f01045ea:	83 f8 0c             	cmp    $0xc,%eax
f01045ed:	0f 87 91 05 00 00    	ja     f0104b84 <syscall+0x5ad>
f01045f3:	3e ff 24 85 00 7b 10 	notrack jmp *-0xfef8500(,%eax,4)
f01045fa:	f0 
	user_mem_assert(curenv, s, len, 0);
f01045fb:	e8 02 17 00 00       	call   f0105d02 <cpunum>
f0104600:	6a 00                	push   $0x0
f0104602:	53                   	push   %ebx
f0104603:	ff 75 0c             	pushl  0xc(%ebp)
f0104606:	6b c0 74             	imul   $0x74,%eax,%eax
f0104609:	ff b0 28 70 23 f0    	pushl  -0xfdc8fd8(%eax)
f010460f:	e8 de e8 ff ff       	call   f0102ef2 <user_mem_assert>
	cprintf("%.*s", len, s);
f0104614:	83 c4 0c             	add    $0xc,%esp
f0104617:	ff 75 0c             	pushl  0xc(%ebp)
f010461a:	53                   	push   %ebx
f010461b:	68 c6 7a 10 f0       	push   $0xf0107ac6
f0104620:	e8 b9 f2 ff ff       	call   f01038de <cprintf>
}
f0104625:	83 c4 10             	add    $0x10,%esp
	int32_t ret;

	switch (syscallno) {
		case (SYS_cputs):
            sys_cputs((const char *)a1, a2);
            ret=0;
f0104628:	b8 00 00 00 00       	mov    $0x0,%eax
			break;
		default:
			return -E_INVAL;
	}
	return ret;
}
f010462d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104630:	5b                   	pop    %ebx
f0104631:	5e                   	pop    %esi
f0104632:	5f                   	pop    %edi
f0104633:	5d                   	pop    %ebp
f0104634:	c3                   	ret    
	return cons_getc();
f0104635:	e8 e3 bf ff ff       	call   f010061d <cons_getc>
			break;
f010463a:	eb f1                	jmp    f010462d <syscall+0x56>
	return curenv->env_id;
f010463c:	e8 c1 16 00 00       	call   f0105d02 <cpunum>
f0104641:	6b c0 74             	imul   $0x74,%eax,%eax
f0104644:	8b 80 28 70 23 f0    	mov    -0xfdc8fd8(%eax),%eax
f010464a:	8b 40 48             	mov    0x48(%eax),%eax
			break;
f010464d:	eb de                	jmp    f010462d <syscall+0x56>
	if ((r = envid2env(envid, &e, 1)) < 0)
f010464f:	83 ec 04             	sub    $0x4,%esp
f0104652:	6a 01                	push   $0x1
f0104654:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104657:	50                   	push   %eax
f0104658:	ff 75 0c             	pushl  0xc(%ebp)
f010465b:	e8 68 e9 ff ff       	call   f0102fc8 <envid2env>
f0104660:	83 c4 10             	add    $0x10,%esp
f0104663:	85 c0                	test   %eax,%eax
f0104665:	78 c6                	js     f010462d <syscall+0x56>
	if (e == curenv)
f0104667:	e8 96 16 00 00       	call   f0105d02 <cpunum>
f010466c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f010466f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104672:	39 90 28 70 23 f0    	cmp    %edx,-0xfdc8fd8(%eax)
f0104678:	74 3d                	je     f01046b7 <syscall+0xe0>
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f010467a:	8b 5a 48             	mov    0x48(%edx),%ebx
f010467d:	e8 80 16 00 00       	call   f0105d02 <cpunum>
f0104682:	83 ec 04             	sub    $0x4,%esp
f0104685:	53                   	push   %ebx
f0104686:	6b c0 74             	imul   $0x74,%eax,%eax
f0104689:	8b 80 28 70 23 f0    	mov    -0xfdc8fd8(%eax),%eax
f010468f:	ff 70 48             	pushl  0x48(%eax)
f0104692:	68 e6 7a 10 f0       	push   $0xf0107ae6
f0104697:	e8 42 f2 ff ff       	call   f01038de <cprintf>
f010469c:	83 c4 10             	add    $0x10,%esp
	env_destroy(e);
f010469f:	83 ec 0c             	sub    $0xc,%esp
f01046a2:	ff 75 e4             	pushl  -0x1c(%ebp)
f01046a5:	e8 0f ef ff ff       	call   f01035b9 <env_destroy>
	return 0;
f01046aa:	83 c4 10             	add    $0x10,%esp
f01046ad:	b8 00 00 00 00       	mov    $0x0,%eax
			break;
f01046b2:	e9 76 ff ff ff       	jmp    f010462d <syscall+0x56>
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f01046b7:	e8 46 16 00 00       	call   f0105d02 <cpunum>
f01046bc:	83 ec 08             	sub    $0x8,%esp
f01046bf:	6b c0 74             	imul   $0x74,%eax,%eax
f01046c2:	8b 80 28 70 23 f0    	mov    -0xfdc8fd8(%eax),%eax
f01046c8:	ff 70 48             	pushl  0x48(%eax)
f01046cb:	68 cb 7a 10 f0       	push   $0xf0107acb
f01046d0:	e8 09 f2 ff ff       	call   f01038de <cprintf>
f01046d5:	83 c4 10             	add    $0x10,%esp
f01046d8:	eb c5                	jmp    f010469f <syscall+0xc8>
	sched_yield();
f01046da:	e8 3d fe ff ff       	call   f010451c <sched_yield>
	int iret=env_alloc(&e, curenv->env_id);
f01046df:	e8 1e 16 00 00       	call   f0105d02 <cpunum>
f01046e4:	83 ec 08             	sub    $0x8,%esp
f01046e7:	6b c0 74             	imul   $0x74,%eax,%eax
f01046ea:	8b 80 28 70 23 f0    	mov    -0xfdc8fd8(%eax),%eax
f01046f0:	ff 70 48             	pushl  0x48(%eax)
f01046f3:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01046f6:	50                   	push   %eax
f01046f7:	e8 e1 e9 ff ff       	call   f01030dd <env_alloc>
	if(iret<0) return iret;
f01046fc:	83 c4 10             	add    $0x10,%esp
f01046ff:	85 c0                	test   %eax,%eax
f0104701:	0f 88 26 ff ff ff    	js     f010462d <syscall+0x56>
	e->env_status=ENV_NOT_RUNNABLE;
f0104707:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010470a:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
	e->env_tf=curenv->env_tf;
f0104711:	e8 ec 15 00 00       	call   f0105d02 <cpunum>
f0104716:	6b c0 74             	imul   $0x74,%eax,%eax
f0104719:	8b b0 28 70 23 f0    	mov    -0xfdc8fd8(%eax),%esi
f010471f:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104724:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104727:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	e->env_tf.tf_regs.reg_eax=0;
f0104729:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010472c:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
	return e->env_id;
f0104733:	8b 40 48             	mov    0x48(%eax),%eax
			break;
f0104736:	e9 f2 fe ff ff       	jmp    f010462d <syscall+0x56>
	if(status!=ENV_RUNNABLE && status!=ENV_NOT_RUNNABLE){
f010473b:	8d 43 fe             	lea    -0x2(%ebx),%eax
f010473e:	a9 fd ff ff ff       	test   $0xfffffffd,%eax
f0104743:	75 28                	jne    f010476d <syscall+0x196>
	if(envid2env(envid, &e, true) < 0){
f0104745:	83 ec 04             	sub    $0x4,%esp
f0104748:	6a 01                	push   $0x1
f010474a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010474d:	50                   	push   %eax
f010474e:	ff 75 0c             	pushl  0xc(%ebp)
f0104751:	e8 72 e8 ff ff       	call   f0102fc8 <envid2env>
f0104756:	83 c4 10             	add    $0x10,%esp
f0104759:	85 c0                	test   %eax,%eax
f010475b:	78 1a                	js     f0104777 <syscall+0x1a0>
	e->env_status=status;
f010475d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104760:	89 58 54             	mov    %ebx,0x54(%eax)
	return 0;
f0104763:	b8 00 00 00 00       	mov    $0x0,%eax
f0104768:	e9 c0 fe ff ff       	jmp    f010462d <syscall+0x56>
		return -E_INVAL;
f010476d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104772:	e9 b6 fe ff ff       	jmp    f010462d <syscall+0x56>
		return -E_BAD_ENV;
f0104777:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
			break;
f010477c:	e9 ac fe ff ff       	jmp    f010462d <syscall+0x56>
	if(envid2env(envid, &e, 1)<0){
f0104781:	83 ec 04             	sub    $0x4,%esp
f0104784:	6a 01                	push   $0x1
f0104786:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104789:	50                   	push   %eax
f010478a:	ff 75 0c             	pushl  0xc(%ebp)
f010478d:	e8 36 e8 ff ff       	call   f0102fc8 <envid2env>
f0104792:	83 c4 10             	add    $0x10,%esp
f0104795:	85 c0                	test   %eax,%eax
f0104797:	78 67                	js     f0104800 <syscall+0x229>
	if((physaddr_t)(va)>=UTOP || PGOFF(va)){
f0104799:	81 fb ff ff bf ee    	cmp    $0xeebfffff,%ebx
f010479f:	77 69                	ja     f010480a <syscall+0x233>
f01047a1:	f7 c3 ff 0f 00 00    	test   $0xfff,%ebx
f01047a7:	75 6b                	jne    f0104814 <syscall+0x23d>
	if((perm&PTE_U)==0 || (perm&PTE_P)==0 || (perm& ~PTE_SYSCALL)!=0){
f01047a9:	8b 45 14             	mov    0x14(%ebp),%eax
f01047ac:	25 fd f1 ff ff       	and    $0xfffff1fd,%eax
f01047b1:	83 f8 05             	cmp    $0x5,%eax
f01047b4:	75 68                	jne    f010481e <syscall+0x247>
	struct PageInfo *pi=page_alloc(ALLOC_ZERO);
f01047b6:	83 ec 0c             	sub    $0xc,%esp
f01047b9:	6a 01                	push   $0x1
f01047bb:	e8 46 c7 ff ff       	call   f0100f06 <page_alloc>
f01047c0:	89 c6                	mov    %eax,%esi
	if(pi==NULL) return -E_INVAL;
f01047c2:	83 c4 10             	add    $0x10,%esp
f01047c5:	85 c0                	test   %eax,%eax
f01047c7:	74 5f                	je     f0104828 <syscall+0x251>
	if(page_insert(e->env_pgdir, pi, va, perm)<0){
f01047c9:	ff 75 14             	pushl  0x14(%ebp)
f01047cc:	53                   	push   %ebx
f01047cd:	50                   	push   %eax
f01047ce:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01047d1:	ff 70 60             	pushl  0x60(%eax)
f01047d4:	e8 fd c9 ff ff       	call   f01011d6 <page_insert>
f01047d9:	83 c4 10             	add    $0x10,%esp
f01047dc:	85 c0                	test   %eax,%eax
f01047de:	78 0a                	js     f01047ea <syscall+0x213>
	return 0;
f01047e0:	b8 00 00 00 00       	mov    $0x0,%eax
			break;
f01047e5:	e9 43 fe ff ff       	jmp    f010462d <syscall+0x56>
		page_free(pi);
f01047ea:	83 ec 0c             	sub    $0xc,%esp
f01047ed:	56                   	push   %esi
f01047ee:	e8 8c c7 ff ff       	call   f0100f7f <page_free>
		return -E_NO_MEM;
f01047f3:	83 c4 10             	add    $0x10,%esp
f01047f6:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f01047fb:	e9 2d fe ff ff       	jmp    f010462d <syscall+0x56>
		return -E_BAD_ENV;
f0104800:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0104805:	e9 23 fe ff ff       	jmp    f010462d <syscall+0x56>
		return -E_INVAL;
f010480a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f010480f:	e9 19 fe ff ff       	jmp    f010462d <syscall+0x56>
f0104814:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104819:	e9 0f fe ff ff       	jmp    f010462d <syscall+0x56>
		return -E_INVAL;
f010481e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104823:	e9 05 fe ff ff       	jmp    f010462d <syscall+0x56>
	if(pi==NULL) return -E_INVAL;
f0104828:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f010482d:	e9 fb fd ff ff       	jmp    f010462d <syscall+0x56>
	if(envid2env(srcenvid, &src_env, 1)<0)			//获取环境
f0104832:	83 ec 04             	sub    $0x4,%esp
f0104835:	6a 01                	push   $0x1
f0104837:	8d 45 dc             	lea    -0x24(%ebp),%eax
f010483a:	50                   	push   %eax
f010483b:	ff 75 0c             	pushl  0xc(%ebp)
f010483e:	e8 85 e7 ff ff       	call   f0102fc8 <envid2env>
f0104843:	83 c4 10             	add    $0x10,%esp
f0104846:	85 c0                	test   %eax,%eax
f0104848:	0f 88 8a 00 00 00    	js     f01048d8 <syscall+0x301>
	if(envid2env(dstenvid, &dst_env, 1)<0)			//获取环境
f010484e:	83 ec 04             	sub    $0x4,%esp
f0104851:	6a 01                	push   $0x1
f0104853:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0104856:	50                   	push   %eax
f0104857:	ff 75 14             	pushl  0x14(%ebp)
f010485a:	e8 69 e7 ff ff       	call   f0102fc8 <envid2env>
f010485f:	83 c4 10             	add    $0x10,%esp
f0104862:	85 c0                	test   %eax,%eax
f0104864:	78 7c                	js     f01048e2 <syscall+0x30b>
	if((physaddr_t)(srcva)>=UTOP || PGOFF(srcva)||(physaddr_t)(dstva)>=UTOP || PGOFF(dstva)) 
f0104866:	81 fb ff ff bf ee    	cmp    $0xeebfffff,%ebx
f010486c:	77 7e                	ja     f01048ec <syscall+0x315>
f010486e:	81 7d 18 ff ff bf ee 	cmpl   $0xeebfffff,0x18(%ebp)
f0104875:	77 7f                	ja     f01048f6 <syscall+0x31f>
f0104877:	89 d8                	mov    %ebx,%eax
f0104879:	0b 45 18             	or     0x18(%ebp),%eax
f010487c:	a9 ff 0f 00 00       	test   $0xfff,%eax
f0104881:	75 7d                	jne    f0104900 <syscall+0x329>
	if((perm &PTE_U) == 0||(perm & PTE_P) == 0 || (perm & (~PTE_SYSCALL)) != 0)
f0104883:	8b 45 1c             	mov    0x1c(%ebp),%eax
f0104886:	25 fd f1 ff ff       	and    $0xfffff1fd,%eax
f010488b:	83 f8 05             	cmp    $0x5,%eax
f010488e:	75 7a                	jne    f010490a <syscall+0x333>
	struct PageInfo * pp = page_lookup(src_env->env_pgdir, srcva, &pte);
f0104890:	83 ec 04             	sub    $0x4,%esp
f0104893:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104896:	50                   	push   %eax
f0104897:	53                   	push   %ebx
f0104898:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010489b:	ff 70 60             	pushl  0x60(%eax)
f010489e:	e8 40 c8 ff ff       	call   f01010e3 <page_lookup>
	if(!pp) return -E_INVAL;
f01048a3:	83 c4 10             	add    $0x10,%esp
f01048a6:	85 c0                	test   %eax,%eax
f01048a8:	74 6a                	je     f0104914 <syscall+0x33d>
	if((*pte&PTE_W) == 0 && (perm & PTE_W) != 0)
f01048aa:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01048ad:	f6 02 02             	testb  $0x2,(%edx)
f01048b0:	75 06                	jne    f01048b8 <syscall+0x2e1>
f01048b2:	f6 45 1c 02          	testb  $0x2,0x1c(%ebp)
f01048b6:	75 66                	jne    f010491e <syscall+0x347>
	if(page_insert(dst_env->env_pgdir, pp, dstva, perm)<0) 
f01048b8:	ff 75 1c             	pushl  0x1c(%ebp)
f01048bb:	ff 75 18             	pushl  0x18(%ebp)
f01048be:	50                   	push   %eax
f01048bf:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01048c2:	ff 70 60             	pushl  0x60(%eax)
f01048c5:	e8 0c c9 ff ff       	call   f01011d6 <page_insert>
f01048ca:	83 c4 10             	add    $0x10,%esp
		return -E_INVAL;
f01048cd:	c1 f8 1f             	sar    $0x1f,%eax
f01048d0:	83 e0 fd             	and    $0xfffffffd,%eax
f01048d3:	e9 55 fd ff ff       	jmp    f010462d <syscall+0x56>
		return -E_BAD_ENV;
f01048d8:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f01048dd:	e9 4b fd ff ff       	jmp    f010462d <syscall+0x56>
		return -E_BAD_ENV;
f01048e2:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f01048e7:	e9 41 fd ff ff       	jmp    f010462d <syscall+0x56>
		return -E_INVAL;
f01048ec:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01048f1:	e9 37 fd ff ff       	jmp    f010462d <syscall+0x56>
f01048f6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01048fb:	e9 2d fd ff ff       	jmp    f010462d <syscall+0x56>
f0104900:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104905:	e9 23 fd ff ff       	jmp    f010462d <syscall+0x56>
		return -E_INVAL;
f010490a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f010490f:	e9 19 fd ff ff       	jmp    f010462d <syscall+0x56>
	if(!pp) return -E_INVAL;
f0104914:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104919:	e9 0f fd ff ff       	jmp    f010462d <syscall+0x56>
		return -E_INVAL;
f010491e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104923:	e9 05 fd ff ff       	jmp    f010462d <syscall+0x56>
	if(envid2env(envid, &e, 1)<0)
f0104928:	83 ec 04             	sub    $0x4,%esp
f010492b:	6a 01                	push   $0x1
f010492d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104930:	50                   	push   %eax
f0104931:	ff 75 0c             	pushl  0xc(%ebp)
f0104934:	e8 8f e6 ff ff       	call   f0102fc8 <envid2env>
f0104939:	83 c4 10             	add    $0x10,%esp
f010493c:	85 c0                	test   %eax,%eax
f010493e:	78 2c                	js     f010496c <syscall+0x395>
	if((physaddr_t)(va)>=UTOP || PGOFF(va)) 				//检查va合规性
f0104940:	81 fb ff ff bf ee    	cmp    $0xeebfffff,%ebx
f0104946:	77 2e                	ja     f0104976 <syscall+0x39f>
f0104948:	f7 c3 ff 0f 00 00    	test   $0xfff,%ebx
f010494e:	75 30                	jne    f0104980 <syscall+0x3a9>
	page_remove(e->env_pgdir, va);
f0104950:	83 ec 08             	sub    $0x8,%esp
f0104953:	53                   	push   %ebx
f0104954:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104957:	ff 70 60             	pushl  0x60(%eax)
f010495a:	e8 26 c8 ff ff       	call   f0101185 <page_remove>
	return 0;
f010495f:	83 c4 10             	add    $0x10,%esp
f0104962:	b8 00 00 00 00       	mov    $0x0,%eax
f0104967:	e9 c1 fc ff ff       	jmp    f010462d <syscall+0x56>
		return -E_BAD_ENV;
f010496c:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0104971:	e9 b7 fc ff ff       	jmp    f010462d <syscall+0x56>
		return -E_INVAL;
f0104976:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f010497b:	e9 ad fc ff ff       	jmp    f010462d <syscall+0x56>
f0104980:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			break;
f0104985:	e9 a3 fc ff ff       	jmp    f010462d <syscall+0x56>
	if(envid2env(envid, &e, 1)<0){
f010498a:	83 ec 04             	sub    $0x4,%esp
f010498d:	6a 01                	push   $0x1
f010498f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104992:	50                   	push   %eax
f0104993:	ff 75 0c             	pushl  0xc(%ebp)
f0104996:	e8 2d e6 ff ff       	call   f0102fc8 <envid2env>
f010499b:	83 c4 10             	add    $0x10,%esp
f010499e:	85 c0                	test   %eax,%eax
f01049a0:	78 10                	js     f01049b2 <syscall+0x3db>
	e->env_pgfault_upcall=func;
f01049a2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01049a5:	89 58 64             	mov    %ebx,0x64(%eax)
	return 0;
f01049a8:	b8 00 00 00 00       	mov    $0x0,%eax
f01049ad:	e9 7b fc ff ff       	jmp    f010462d <syscall+0x56>
		return -E_BAD_ENV;
f01049b2:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
			break;
f01049b7:	e9 71 fc ff ff       	jmp    f010462d <syscall+0x56>
	if((r = envid2env(envid, &env, 0))< 0){
f01049bc:	83 ec 04             	sub    $0x4,%esp
f01049bf:	6a 00                	push   $0x0
f01049c1:	8d 45 e0             	lea    -0x20(%ebp),%eax
f01049c4:	50                   	push   %eax
f01049c5:	ff 75 0c             	pushl  0xc(%ebp)
f01049c8:	e8 fb e5 ff ff       	call   f0102fc8 <envid2env>
f01049cd:	83 c4 10             	add    $0x10,%esp
f01049d0:	85 c0                	test   %eax,%eax
f01049d2:	0f 88 fd 00 00 00    	js     f0104ad5 <syscall+0x4fe>
	if(env->env_ipc_recving == 0){
f01049d8:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01049db:	80 78 68 00          	cmpb   $0x0,0x68(%eax)
f01049df:	0f 84 fa 00 00 00    	je     f0104adf <syscall+0x508>
	if(srcva<(void*)UTOP){
f01049e5:	81 7d 14 ff ff bf ee 	cmpl   $0xeebfffff,0x14(%ebp)
f01049ec:	77 78                	ja     f0104a66 <syscall+0x48f>
		struct PageInfo *pg=page_lookup(curenv->env_pgdir, srcva, &pte);
f01049ee:	e8 0f 13 00 00       	call   f0105d02 <cpunum>
f01049f3:	83 ec 04             	sub    $0x4,%esp
f01049f6:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f01049f9:	52                   	push   %edx
f01049fa:	ff 75 14             	pushl  0x14(%ebp)
f01049fd:	6b c0 74             	imul   $0x74,%eax,%eax
f0104a00:	8b 80 28 70 23 f0    	mov    -0xfdc8fd8(%eax),%eax
f0104a06:	ff 70 60             	pushl  0x60(%eax)
f0104a09:	e8 d5 c6 ff ff       	call   f01010e3 <page_lookup>
f0104a0e:	89 c2                	mov    %eax,%edx
		if(srcva!=ROUNDDOWN(srcva, PGSIZE)){
f0104a10:	83 c4 10             	add    $0x10,%esp
			return -E_INVAL;
f0104a13:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		if(srcva!=ROUNDDOWN(srcva, PGSIZE)){
f0104a18:	f7 45 14 ff 0f 00 00 	testl  $0xfff,0x14(%ebp)
f0104a1f:	0f 85 08 fc ff ff    	jne    f010462d <syscall+0x56>
		if((*pte & perm & PTE_SYSCALL) != (perm & PTE_SYSCALL)){
f0104a25:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104a28:	8b 08                	mov    (%eax),%ecx
f0104a2a:	89 c8                	mov    %ecx,%eax
f0104a2c:	f7 d0                	not    %eax
f0104a2e:	23 45 18             	and    0x18(%ebp),%eax
		if(!pg){
f0104a31:	a9 07 0e 00 00       	test   $0xe07,%eax
f0104a36:	0f 85 8f 00 00 00    	jne    f0104acb <syscall+0x4f4>
f0104a3c:	85 d2                	test   %edx,%edx
f0104a3e:	0f 84 87 00 00 00    	je     f0104acb <syscall+0x4f4>
		if((perm & PTE_W) && !(*pte & PTE_W)){
f0104a44:	f6 45 18 02          	testb  $0x2,0x18(%ebp)
f0104a48:	74 0e                	je     f0104a58 <syscall+0x481>
			return -E_INVAL;
f0104a4a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		if((perm & PTE_W) && !(*pte & PTE_W)){
f0104a4f:	f6 c1 02             	test   $0x2,%cl
f0104a52:	0f 84 d5 fb ff ff    	je     f010462d <syscall+0x56>
		if(env->env_ipc_dstva < (void*)UTOP){
f0104a58:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104a5b:	8b 48 6c             	mov    0x6c(%eax),%ecx
f0104a5e:	81 f9 ff ff bf ee    	cmp    $0xeebfffff,%ecx
f0104a64:	76 3b                	jbe    f0104aa1 <syscall+0x4ca>
	env->env_ipc_recving = 0;
f0104a66:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104a69:	c6 40 68 00          	movb   $0x0,0x68(%eax)
	env->env_ipc_from = curenv->env_id;
f0104a6d:	e8 90 12 00 00       	call   f0105d02 <cpunum>
f0104a72:	89 c2                	mov    %eax,%edx
f0104a74:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104a77:	6b d2 74             	imul   $0x74,%edx,%edx
f0104a7a:	8b 92 28 70 23 f0    	mov    -0xfdc8fd8(%edx),%edx
f0104a80:	8b 52 48             	mov    0x48(%edx),%edx
f0104a83:	89 50 74             	mov    %edx,0x74(%eax)
	env->env_ipc_value = value; 
f0104a86:	89 58 70             	mov    %ebx,0x70(%eax)
	env->env_status = ENV_RUNNABLE;
f0104a89:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
	env->env_tf.tf_regs.reg_eax = 0;
f0104a90:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
	return 0;
f0104a97:	b8 00 00 00 00       	mov    $0x0,%eax
f0104a9c:	e9 8c fb ff ff       	jmp    f010462d <syscall+0x56>
			r=page_insert(env->env_pgdir, pg, env->env_ipc_dstva, perm);
f0104aa1:	ff 75 18             	pushl  0x18(%ebp)
f0104aa4:	51                   	push   %ecx
f0104aa5:	52                   	push   %edx
f0104aa6:	ff 70 60             	pushl  0x60(%eax)
f0104aa9:	e8 28 c7 ff ff       	call   f01011d6 <page_insert>
f0104aae:	89 c2                	mov    %eax,%edx
			if(r<0){
f0104ab0:	83 c4 10             	add    $0x10,%esp
				return -E_NO_MEM;
f0104ab3:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
			if(r<0){
f0104ab8:	85 d2                	test   %edx,%edx
f0104aba:	0f 88 6d fb ff ff    	js     f010462d <syscall+0x56>
			env->env_ipc_perm=perm;
f0104ac0:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104ac3:	8b 7d 18             	mov    0x18(%ebp),%edi
f0104ac6:	89 78 78             	mov    %edi,0x78(%eax)
f0104ac9:	eb 9b                	jmp    f0104a66 <syscall+0x48f>
			return -E_INVAL;
f0104acb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104ad0:	e9 58 fb ff ff       	jmp    f010462d <syscall+0x56>
		return -E_BAD_ENV;
f0104ad5:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0104ada:	e9 4e fb ff ff       	jmp    f010462d <syscall+0x56>
		return -E_IPC_NOT_RECV;
f0104adf:	b8 f9 ff ff ff       	mov    $0xfffffff9,%eax
			break;
f0104ae4:	e9 44 fb ff ff       	jmp    f010462d <syscall+0x56>
	if((uintptr_t)dstva < UTOP && PGOFF(dstva) != 0){
f0104ae9:	81 7d 0c ff ff bf ee 	cmpl   $0xeebfffff,0xc(%ebp)
f0104af0:	77 13                	ja     f0104b05 <syscall+0x52e>
f0104af2:	f7 45 0c ff 0f 00 00 	testl  $0xfff,0xc(%ebp)
f0104af9:	74 0a                	je     f0104b05 <syscall+0x52e>
			ret=sys_ipc_recv((void *)(a1));
f0104afb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104b00:	e9 28 fb ff ff       	jmp    f010462d <syscall+0x56>
	curenv->env_ipc_recving = 1;
f0104b05:	e8 f8 11 00 00       	call   f0105d02 <cpunum>
f0104b0a:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b0d:	8b 80 28 70 23 f0    	mov    -0xfdc8fd8(%eax),%eax
f0104b13:	c6 40 68 01          	movb   $0x1,0x68(%eax)
	curenv->env_ipc_dstva = dstva;
f0104b17:	e8 e6 11 00 00       	call   f0105d02 <cpunum>
f0104b1c:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b1f:	8b 80 28 70 23 f0    	mov    -0xfdc8fd8(%eax),%eax
f0104b25:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0104b28:	89 78 6c             	mov    %edi,0x6c(%eax)
	curenv->env_ipc_value = 0;
f0104b2b:	e8 d2 11 00 00       	call   f0105d02 <cpunum>
f0104b30:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b33:	8b 80 28 70 23 f0    	mov    -0xfdc8fd8(%eax),%eax
f0104b39:	c7 40 70 00 00 00 00 	movl   $0x0,0x70(%eax)
	curenv->env_ipc_from = 0;
f0104b40:	e8 bd 11 00 00       	call   f0105d02 <cpunum>
f0104b45:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b48:	8b 80 28 70 23 f0    	mov    -0xfdc8fd8(%eax),%eax
f0104b4e:	c7 40 74 00 00 00 00 	movl   $0x0,0x74(%eax)
	curenv->env_ipc_perm = 0;
f0104b55:	e8 a8 11 00 00       	call   f0105d02 <cpunum>
f0104b5a:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b5d:	8b 80 28 70 23 f0    	mov    -0xfdc8fd8(%eax),%eax
f0104b63:	c7 40 78 00 00 00 00 	movl   $0x0,0x78(%eax)
	curenv->env_status = ENV_NOT_RUNNABLE;
f0104b6a:	e8 93 11 00 00       	call   f0105d02 <cpunum>
f0104b6f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b72:	8b 80 28 70 23 f0    	mov    -0xfdc8fd8(%eax),%eax
f0104b78:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
	sched_yield();
f0104b7f:	e8 98 f9 ff ff       	call   f010451c <sched_yield>
            ret=0;
f0104b84:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104b89:	e9 9f fa ff ff       	jmp    f010462d <syscall+0x56>

f0104b8e <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0104b8e:	55                   	push   %ebp
f0104b8f:	89 e5                	mov    %esp,%ebp
f0104b91:	57                   	push   %edi
f0104b92:	56                   	push   %esi
f0104b93:	53                   	push   %ebx
f0104b94:	83 ec 14             	sub    $0x14,%esp
f0104b97:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0104b9a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0104b9d:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0104ba0:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f0104ba3:	8b 1a                	mov    (%edx),%ebx
f0104ba5:	8b 01                	mov    (%ecx),%eax
f0104ba7:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104baa:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0104bb1:	eb 23                	jmp    f0104bd6 <stab_binsearch+0x48>

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0104bb3:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f0104bb6:	eb 1e                	jmp    f0104bd6 <stab_binsearch+0x48>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0104bb8:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104bbb:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0104bbe:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0104bc2:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0104bc5:	73 46                	jae    f0104c0d <stab_binsearch+0x7f>
			*region_left = m;
f0104bc7:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0104bca:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f0104bcc:	8d 5f 01             	lea    0x1(%edi),%ebx
		any_matches = 1;
f0104bcf:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
	while (l <= r) {
f0104bd6:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0104bd9:	7f 5f                	jg     f0104c3a <stab_binsearch+0xac>
		int true_m = (l + r) / 2, m = true_m;
f0104bdb:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104bde:	8d 14 03             	lea    (%ebx,%eax,1),%edx
f0104be1:	89 d0                	mov    %edx,%eax
f0104be3:	c1 e8 1f             	shr    $0x1f,%eax
f0104be6:	01 d0                	add    %edx,%eax
f0104be8:	89 c7                	mov    %eax,%edi
f0104bea:	d1 ff                	sar    %edi
f0104bec:	83 e0 fe             	and    $0xfffffffe,%eax
f0104bef:	01 f8                	add    %edi,%eax
f0104bf1:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0104bf4:	8d 54 81 04          	lea    0x4(%ecx,%eax,4),%edx
f0104bf8:	89 f8                	mov    %edi,%eax
		while (m >= l && stabs[m].n_type != type)
f0104bfa:	39 c3                	cmp    %eax,%ebx
f0104bfc:	7f b5                	jg     f0104bb3 <stab_binsearch+0x25>
f0104bfe:	0f b6 0a             	movzbl (%edx),%ecx
f0104c01:	83 ea 0c             	sub    $0xc,%edx
f0104c04:	39 f1                	cmp    %esi,%ecx
f0104c06:	74 b0                	je     f0104bb8 <stab_binsearch+0x2a>
			m--;
f0104c08:	83 e8 01             	sub    $0x1,%eax
f0104c0b:	eb ed                	jmp    f0104bfa <stab_binsearch+0x6c>
		} else if (stabs[m].n_value > addr) {
f0104c0d:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0104c10:	76 14                	jbe    f0104c26 <stab_binsearch+0x98>
			*region_right = m - 1;
f0104c12:	83 e8 01             	sub    $0x1,%eax
f0104c15:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104c18:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0104c1b:	89 07                	mov    %eax,(%edi)
		any_matches = 1;
f0104c1d:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0104c24:	eb b0                	jmp    f0104bd6 <stab_binsearch+0x48>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0104c26:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104c29:	89 07                	mov    %eax,(%edi)
			l = m;
			addr++;
f0104c2b:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0104c2f:	89 c3                	mov    %eax,%ebx
		any_matches = 1;
f0104c31:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0104c38:	eb 9c                	jmp    f0104bd6 <stab_binsearch+0x48>
		}
	}

	if (!any_matches)
f0104c3a:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0104c3e:	75 15                	jne    f0104c55 <stab_binsearch+0xc7>
		*region_right = *region_left - 1;
f0104c40:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104c43:	8b 00                	mov    (%eax),%eax
f0104c45:	83 e8 01             	sub    $0x1,%eax
f0104c48:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0104c4b:	89 07                	mov    %eax,(%edi)
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
f0104c4d:	83 c4 14             	add    $0x14,%esp
f0104c50:	5b                   	pop    %ebx
f0104c51:	5e                   	pop    %esi
f0104c52:	5f                   	pop    %edi
f0104c53:	5d                   	pop    %ebp
f0104c54:	c3                   	ret    
		for (l = *region_right;
f0104c55:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104c58:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0104c5a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104c5d:	8b 0f                	mov    (%edi),%ecx
f0104c5f:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104c62:	8b 7d ec             	mov    -0x14(%ebp),%edi
f0104c65:	8d 54 97 04          	lea    0x4(%edi,%edx,4),%edx
		for (l = *region_right;
f0104c69:	eb 03                	jmp    f0104c6e <stab_binsearch+0xe0>
		     l--)
f0104c6b:	83 e8 01             	sub    $0x1,%eax
		for (l = *region_right;
f0104c6e:	39 c1                	cmp    %eax,%ecx
f0104c70:	7d 0a                	jge    f0104c7c <stab_binsearch+0xee>
		     l > *region_left && stabs[l].n_type != type;
f0104c72:	0f b6 1a             	movzbl (%edx),%ebx
f0104c75:	83 ea 0c             	sub    $0xc,%edx
f0104c78:	39 f3                	cmp    %esi,%ebx
f0104c7a:	75 ef                	jne    f0104c6b <stab_binsearch+0xdd>
		*region_left = l;
f0104c7c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104c7f:	89 07                	mov    %eax,(%edi)
}
f0104c81:	eb ca                	jmp    f0104c4d <stab_binsearch+0xbf>

f0104c83 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0104c83:	f3 0f 1e fb          	endbr32 
f0104c87:	55                   	push   %ebp
f0104c88:	89 e5                	mov    %esp,%ebp
f0104c8a:	57                   	push   %edi
f0104c8b:	56                   	push   %esi
f0104c8c:	53                   	push   %ebx
f0104c8d:	83 ec 2c             	sub    $0x2c,%esp
f0104c90:	8b 7d 08             	mov    0x8(%ebp),%edi
f0104c93:	8b 75 0c             	mov    0xc(%ebp),%esi
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0104c96:	c7 06 34 7b 10 f0    	movl   $0xf0107b34,(%esi)
	info->eip_line = 0;
f0104c9c:	c7 46 04 00 00 00 00 	movl   $0x0,0x4(%esi)
	info->eip_fn_name = "<unknown>";
f0104ca3:	c7 46 08 34 7b 10 f0 	movl   $0xf0107b34,0x8(%esi)
	info->eip_fn_namelen = 9;
f0104caa:	c7 46 0c 09 00 00 00 	movl   $0x9,0xc(%esi)
	info->eip_fn_addr = addr;
f0104cb1:	89 7e 10             	mov    %edi,0x10(%esi)
	info->eip_fn_narg = 0;
f0104cb4:	c7 46 14 00 00 00 00 	movl   $0x0,0x14(%esi)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0104cbb:	81 ff ff ff 7f ef    	cmp    $0xef7fffff,%edi
f0104cc1:	0f 87 e0 00 00 00    	ja     f0104da7 <debuginfo_eip+0x124>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.

		stabs = usd->stabs;
f0104cc7:	a1 00 00 20 00       	mov    0x200000,%eax
f0104ccc:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		stab_end = usd->stab_end;
f0104ccf:	a1 04 00 20 00       	mov    0x200004,%eax
		stabstr = usd->stabstr;
f0104cd4:	8b 0d 08 00 20 00    	mov    0x200008,%ecx
f0104cda:	89 4d cc             	mov    %ecx,-0x34(%ebp)
		stabstr_end = usd->stabstr_end;
f0104cdd:	8b 0d 0c 00 20 00    	mov    0x20000c,%ecx
f0104ce3:	89 4d d0             	mov    %ecx,-0x30(%ebp)
		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0104ce6:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0104ce9:	39 4d cc             	cmp    %ecx,-0x34(%ebp)
f0104cec:	0f 83 4d 01 00 00    	jae    f0104e3f <debuginfo_eip+0x1bc>
f0104cf2:	80 79 ff 00          	cmpb   $0x0,-0x1(%ecx)
f0104cf6:	0f 85 4a 01 00 00    	jne    f0104e46 <debuginfo_eip+0x1c3>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0104cfc:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0104d03:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0104d06:	29 d8                	sub    %ebx,%eax
f0104d08:	c1 f8 02             	sar    $0x2,%eax
f0104d0b:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0104d11:	83 e8 01             	sub    $0x1,%eax
f0104d14:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0104d17:	57                   	push   %edi
f0104d18:	6a 64                	push   $0x64
f0104d1a:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0104d1d:	89 c1                	mov    %eax,%ecx
f0104d1f:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0104d22:	89 d8                	mov    %ebx,%eax
f0104d24:	e8 65 fe ff ff       	call   f0104b8e <stab_binsearch>
	if (lfile == 0)
f0104d29:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104d2c:	83 c4 08             	add    $0x8,%esp
f0104d2f:	85 c0                	test   %eax,%eax
f0104d31:	0f 84 16 01 00 00    	je     f0104e4d <debuginfo_eip+0x1ca>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0104d37:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0104d3a:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104d3d:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0104d40:	57                   	push   %edi
f0104d41:	6a 24                	push   $0x24
f0104d43:	8d 45 d8             	lea    -0x28(%ebp),%eax
f0104d46:	89 c1                	mov    %eax,%ecx
f0104d48:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0104d4b:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
f0104d4e:	89 d8                	mov    %ebx,%eax
f0104d50:	e8 39 fe ff ff       	call   f0104b8e <stab_binsearch>

	if (lfun <= rfun) {
f0104d55:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0104d58:	83 c4 08             	add    $0x8,%esp
f0104d5b:	3b 5d d8             	cmp    -0x28(%ebp),%ebx
f0104d5e:	7f 66                	jg     f0104dc6 <debuginfo_eip+0x143>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0104d60:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0104d63:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0104d66:	8d 14 87             	lea    (%edi,%eax,4),%edx
f0104d69:	8b 02                	mov    (%edx),%eax
f0104d6b:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0104d6e:	8b 7d cc             	mov    -0x34(%ebp),%edi
f0104d71:	29 f9                	sub    %edi,%ecx
f0104d73:	39 c8                	cmp    %ecx,%eax
f0104d75:	73 05                	jae    f0104d7c <debuginfo_eip+0xf9>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0104d77:	01 f8                	add    %edi,%eax
f0104d79:	89 46 08             	mov    %eax,0x8(%esi)
		info->eip_fn_addr = stabs[lfun].n_value;
f0104d7c:	8b 42 08             	mov    0x8(%edx),%eax
f0104d7f:	89 46 10             	mov    %eax,0x10(%esi)
		info->eip_fn_addr = addr;
		lline = lfile;
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0104d82:	83 ec 08             	sub    $0x8,%esp
f0104d85:	6a 3a                	push   $0x3a
f0104d87:	ff 76 08             	pushl  0x8(%esi)
f0104d8a:	e8 35 09 00 00       	call   f01056c4 <strfind>
f0104d8f:	2b 46 08             	sub    0x8(%esi),%eax
f0104d92:	89 46 0c             	mov    %eax,0xc(%esi)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0104d95:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104d98:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0104d9b:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0104d9e:	8d 44 81 04          	lea    0x4(%ecx,%eax,4),%eax
f0104da2:	83 c4 10             	add    $0x10,%esp
f0104da5:	eb 2d                	jmp    f0104dd4 <debuginfo_eip+0x151>
		stabstr_end = __STABSTR_END__;
f0104da7:	c7 45 d0 6a 7f 11 f0 	movl   $0xf0117f6a,-0x30(%ebp)
		stabstr = __STABSTR_BEGIN__;
f0104dae:	c7 45 cc ad 47 11 f0 	movl   $0xf01147ad,-0x34(%ebp)
		stab_end = __STAB_END__;
f0104db5:	b8 ac 47 11 f0       	mov    $0xf01147ac,%eax
		stabs = __STAB_BEGIN__;
f0104dba:	c7 45 d4 14 80 10 f0 	movl   $0xf0108014,-0x2c(%ebp)
f0104dc1:	e9 20 ff ff ff       	jmp    f0104ce6 <debuginfo_eip+0x63>
		info->eip_fn_addr = addr;
f0104dc6:	89 7e 10             	mov    %edi,0x10(%esi)
		lline = lfile;
f0104dc9:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0104dcc:	eb b4                	jmp    f0104d82 <debuginfo_eip+0xff>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f0104dce:	83 eb 01             	sub    $0x1,%ebx
f0104dd1:	83 e8 0c             	sub    $0xc,%eax
	while (lline >= lfile
f0104dd4:	39 df                	cmp    %ebx,%edi
f0104dd6:	7f 2e                	jg     f0104e06 <debuginfo_eip+0x183>
	       && stabs[lline].n_type != N_SOL
f0104dd8:	0f b6 10             	movzbl (%eax),%edx
f0104ddb:	80 fa 84             	cmp    $0x84,%dl
f0104dde:	74 0b                	je     f0104deb <debuginfo_eip+0x168>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0104de0:	80 fa 64             	cmp    $0x64,%dl
f0104de3:	75 e9                	jne    f0104dce <debuginfo_eip+0x14b>
f0104de5:	83 78 04 00          	cmpl   $0x0,0x4(%eax)
f0104de9:	74 e3                	je     f0104dce <debuginfo_eip+0x14b>
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0104deb:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0104dee:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0104df1:	8b 14 87             	mov    (%edi,%eax,4),%edx
f0104df4:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0104df7:	8b 7d cc             	mov    -0x34(%ebp),%edi
f0104dfa:	29 f8                	sub    %edi,%eax
f0104dfc:	39 c2                	cmp    %eax,%edx
f0104dfe:	73 06                	jae    f0104e06 <debuginfo_eip+0x183>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0104e00:	89 f8                	mov    %edi,%eax
f0104e02:	01 d0                	add    %edx,%eax
f0104e04:	89 06                	mov    %eax,(%esi)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0104e06:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104e09:	8b 4d d8             	mov    -0x28(%ebp),%ecx
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0104e0c:	ba 00 00 00 00       	mov    $0x0,%edx
	if (lfun < rfun)
f0104e11:	39 c8                	cmp    %ecx,%eax
f0104e13:	7d 44                	jge    f0104e59 <debuginfo_eip+0x1d6>
		for (lline = lfun + 1;
f0104e15:	8d 50 01             	lea    0x1(%eax),%edx
f0104e18:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0104e1b:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0104e1e:	8d 44 87 10          	lea    0x10(%edi,%eax,4),%eax
f0104e22:	eb 07                	jmp    f0104e2b <debuginfo_eip+0x1a8>
			info->eip_fn_narg++;
f0104e24:	83 46 14 01          	addl   $0x1,0x14(%esi)
		     lline++)
f0104e28:	83 c2 01             	add    $0x1,%edx
		for (lline = lfun + 1;
f0104e2b:	39 d1                	cmp    %edx,%ecx
f0104e2d:	74 25                	je     f0104e54 <debuginfo_eip+0x1d1>
f0104e2f:	83 c0 0c             	add    $0xc,%eax
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0104e32:	80 78 f4 a0          	cmpb   $0xa0,-0xc(%eax)
f0104e36:	74 ec                	je     f0104e24 <debuginfo_eip+0x1a1>
	return 0;
f0104e38:	ba 00 00 00 00       	mov    $0x0,%edx
f0104e3d:	eb 1a                	jmp    f0104e59 <debuginfo_eip+0x1d6>
		return -1;
f0104e3f:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0104e44:	eb 13                	jmp    f0104e59 <debuginfo_eip+0x1d6>
f0104e46:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0104e4b:	eb 0c                	jmp    f0104e59 <debuginfo_eip+0x1d6>
		return -1;
f0104e4d:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0104e52:	eb 05                	jmp    f0104e59 <debuginfo_eip+0x1d6>
	return 0;
f0104e54:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0104e59:	89 d0                	mov    %edx,%eax
f0104e5b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104e5e:	5b                   	pop    %ebx
f0104e5f:	5e                   	pop    %esi
f0104e60:	5f                   	pop    %edi
f0104e61:	5d                   	pop    %ebp
f0104e62:	c3                   	ret    

f0104e63 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0104e63:	55                   	push   %ebp
f0104e64:	89 e5                	mov    %esp,%ebp
f0104e66:	57                   	push   %edi
f0104e67:	56                   	push   %esi
f0104e68:	53                   	push   %ebx
f0104e69:	83 ec 1c             	sub    $0x1c,%esp
f0104e6c:	89 c7                	mov    %eax,%edi
f0104e6e:	89 d6                	mov    %edx,%esi
f0104e70:	8b 45 08             	mov    0x8(%ebp),%eax
f0104e73:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104e76:	89 d1                	mov    %edx,%ecx
f0104e78:	89 c2                	mov    %eax,%edx
f0104e7a:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104e7d:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0104e80:	8b 45 10             	mov    0x10(%ebp),%eax
f0104e83:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0104e86:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0104e89:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f0104e90:	39 c2                	cmp    %eax,%edx
f0104e92:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
f0104e95:	72 3e                	jb     f0104ed5 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0104e97:	83 ec 0c             	sub    $0xc,%esp
f0104e9a:	ff 75 18             	pushl  0x18(%ebp)
f0104e9d:	83 eb 01             	sub    $0x1,%ebx
f0104ea0:	53                   	push   %ebx
f0104ea1:	50                   	push   %eax
f0104ea2:	83 ec 08             	sub    $0x8,%esp
f0104ea5:	ff 75 e4             	pushl  -0x1c(%ebp)
f0104ea8:	ff 75 e0             	pushl  -0x20(%ebp)
f0104eab:	ff 75 dc             	pushl  -0x24(%ebp)
f0104eae:	ff 75 d8             	pushl  -0x28(%ebp)
f0104eb1:	e8 6a 12 00 00       	call   f0106120 <__udivdi3>
f0104eb6:	83 c4 18             	add    $0x18,%esp
f0104eb9:	52                   	push   %edx
f0104eba:	50                   	push   %eax
f0104ebb:	89 f2                	mov    %esi,%edx
f0104ebd:	89 f8                	mov    %edi,%eax
f0104ebf:	e8 9f ff ff ff       	call   f0104e63 <printnum>
f0104ec4:	83 c4 20             	add    $0x20,%esp
f0104ec7:	eb 13                	jmp    f0104edc <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0104ec9:	83 ec 08             	sub    $0x8,%esp
f0104ecc:	56                   	push   %esi
f0104ecd:	ff 75 18             	pushl  0x18(%ebp)
f0104ed0:	ff d7                	call   *%edi
f0104ed2:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
f0104ed5:	83 eb 01             	sub    $0x1,%ebx
f0104ed8:	85 db                	test   %ebx,%ebx
f0104eda:	7f ed                	jg     f0104ec9 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0104edc:	83 ec 08             	sub    $0x8,%esp
f0104edf:	56                   	push   %esi
f0104ee0:	83 ec 04             	sub    $0x4,%esp
f0104ee3:	ff 75 e4             	pushl  -0x1c(%ebp)
f0104ee6:	ff 75 e0             	pushl  -0x20(%ebp)
f0104ee9:	ff 75 dc             	pushl  -0x24(%ebp)
f0104eec:	ff 75 d8             	pushl  -0x28(%ebp)
f0104eef:	e8 3c 13 00 00       	call   f0106230 <__umoddi3>
f0104ef4:	83 c4 14             	add    $0x14,%esp
f0104ef7:	0f be 80 3e 7b 10 f0 	movsbl -0xfef84c2(%eax),%eax
f0104efe:	50                   	push   %eax
f0104eff:	ff d7                	call   *%edi
}
f0104f01:	83 c4 10             	add    $0x10,%esp
f0104f04:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104f07:	5b                   	pop    %ebx
f0104f08:	5e                   	pop    %esi
f0104f09:	5f                   	pop    %edi
f0104f0a:	5d                   	pop    %ebp
f0104f0b:	c3                   	ret    

f0104f0c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0104f0c:	f3 0f 1e fb          	endbr32 
f0104f10:	55                   	push   %ebp
f0104f11:	89 e5                	mov    %esp,%ebp
f0104f13:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0104f16:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0104f1a:	8b 10                	mov    (%eax),%edx
f0104f1c:	3b 50 04             	cmp    0x4(%eax),%edx
f0104f1f:	73 0a                	jae    f0104f2b <sprintputch+0x1f>
		*b->buf++ = ch;
f0104f21:	8d 4a 01             	lea    0x1(%edx),%ecx
f0104f24:	89 08                	mov    %ecx,(%eax)
f0104f26:	8b 45 08             	mov    0x8(%ebp),%eax
f0104f29:	88 02                	mov    %al,(%edx)
}
f0104f2b:	5d                   	pop    %ebp
f0104f2c:	c3                   	ret    

f0104f2d <printfmt>:
{
f0104f2d:	f3 0f 1e fb          	endbr32 
f0104f31:	55                   	push   %ebp
f0104f32:	89 e5                	mov    %esp,%ebp
f0104f34:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
f0104f37:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0104f3a:	50                   	push   %eax
f0104f3b:	ff 75 10             	pushl  0x10(%ebp)
f0104f3e:	ff 75 0c             	pushl  0xc(%ebp)
f0104f41:	ff 75 08             	pushl  0x8(%ebp)
f0104f44:	e8 05 00 00 00       	call   f0104f4e <vprintfmt>
}
f0104f49:	83 c4 10             	add    $0x10,%esp
f0104f4c:	c9                   	leave  
f0104f4d:	c3                   	ret    

f0104f4e <vprintfmt>:
{
f0104f4e:	f3 0f 1e fb          	endbr32 
f0104f52:	55                   	push   %ebp
f0104f53:	89 e5                	mov    %esp,%ebp
f0104f55:	57                   	push   %edi
f0104f56:	56                   	push   %esi
f0104f57:	53                   	push   %ebx
f0104f58:	83 ec 3c             	sub    $0x3c,%esp
f0104f5b:	8b 75 08             	mov    0x8(%ebp),%esi
f0104f5e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104f61:	8b 7d 10             	mov    0x10(%ebp),%edi
f0104f64:	e9 cd 03 00 00       	jmp    f0105336 <vprintfmt+0x3e8>
		padc = ' ';
f0104f69:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
f0104f6d:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
f0104f74:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
f0104f7b:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
f0104f82:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
f0104f87:	8d 47 01             	lea    0x1(%edi),%eax
f0104f8a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0104f8d:	0f b6 17             	movzbl (%edi),%edx
f0104f90:	8d 42 dd             	lea    -0x23(%edx),%eax
f0104f93:	3c 55                	cmp    $0x55,%al
f0104f95:	0f 87 1e 04 00 00    	ja     f01053b9 <vprintfmt+0x46b>
f0104f9b:	0f b6 c0             	movzbl %al,%eax
f0104f9e:	3e ff 24 85 00 7c 10 	notrack jmp *-0xfef8400(,%eax,4)
f0104fa5:	f0 
f0104fa6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
f0104fa9:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
f0104fad:	eb d8                	jmp    f0104f87 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
f0104faf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104fb2:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
f0104fb6:	eb cf                	jmp    f0104f87 <vprintfmt+0x39>
f0104fb8:	0f b6 d2             	movzbl %dl,%edx
f0104fbb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
f0104fbe:	b8 00 00 00 00       	mov    $0x0,%eax
f0104fc3:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
f0104fc6:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0104fc9:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
f0104fcd:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
f0104fd0:	8d 4a d0             	lea    -0x30(%edx),%ecx
f0104fd3:	83 f9 09             	cmp    $0x9,%ecx
f0104fd6:	77 55                	ja     f010502d <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
f0104fd8:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
f0104fdb:	eb e9                	jmp    f0104fc6 <vprintfmt+0x78>
			precision = va_arg(ap, int);
f0104fdd:	8b 45 14             	mov    0x14(%ebp),%eax
f0104fe0:	8b 00                	mov    (%eax),%eax
f0104fe2:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104fe5:	8b 45 14             	mov    0x14(%ebp),%eax
f0104fe8:	8d 40 04             	lea    0x4(%eax),%eax
f0104feb:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0104fee:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
f0104ff1:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0104ff5:	79 90                	jns    f0104f87 <vprintfmt+0x39>
				width = precision, precision = -1;
f0104ff7:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0104ffa:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0104ffd:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
f0105004:	eb 81                	jmp    f0104f87 <vprintfmt+0x39>
f0105006:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105009:	85 c0                	test   %eax,%eax
f010500b:	ba 00 00 00 00       	mov    $0x0,%edx
f0105010:	0f 49 d0             	cmovns %eax,%edx
f0105013:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0105016:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
f0105019:	e9 69 ff ff ff       	jmp    f0104f87 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
f010501e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
f0105021:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
f0105028:	e9 5a ff ff ff       	jmp    f0104f87 <vprintfmt+0x39>
f010502d:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0105030:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105033:	eb bc                	jmp    f0104ff1 <vprintfmt+0xa3>
			lflag++;
f0105035:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
f0105038:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
f010503b:	e9 47 ff ff ff       	jmp    f0104f87 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
f0105040:	8b 45 14             	mov    0x14(%ebp),%eax
f0105043:	8d 78 04             	lea    0x4(%eax),%edi
f0105046:	83 ec 08             	sub    $0x8,%esp
f0105049:	53                   	push   %ebx
f010504a:	ff 30                	pushl  (%eax)
f010504c:	ff d6                	call   *%esi
			break;
f010504e:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
f0105051:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
f0105054:	e9 da 02 00 00       	jmp    f0105333 <vprintfmt+0x3e5>
			err = va_arg(ap, int);
f0105059:	8b 45 14             	mov    0x14(%ebp),%eax
f010505c:	8d 78 04             	lea    0x4(%eax),%edi
f010505f:	8b 00                	mov    (%eax),%eax
f0105061:	99                   	cltd   
f0105062:	31 d0                	xor    %edx,%eax
f0105064:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0105066:	83 f8 08             	cmp    $0x8,%eax
f0105069:	7f 23                	jg     f010508e <vprintfmt+0x140>
f010506b:	8b 14 85 60 7d 10 f0 	mov    -0xfef82a0(,%eax,4),%edx
f0105072:	85 d2                	test   %edx,%edx
f0105074:	74 18                	je     f010508e <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
f0105076:	52                   	push   %edx
f0105077:	68 15 69 10 f0       	push   $0xf0106915
f010507c:	53                   	push   %ebx
f010507d:	56                   	push   %esi
f010507e:	e8 aa fe ff ff       	call   f0104f2d <printfmt>
f0105083:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f0105086:	89 7d 14             	mov    %edi,0x14(%ebp)
f0105089:	e9 a5 02 00 00       	jmp    f0105333 <vprintfmt+0x3e5>
				printfmt(putch, putdat, "error %d", err);
f010508e:	50                   	push   %eax
f010508f:	68 56 7b 10 f0       	push   $0xf0107b56
f0105094:	53                   	push   %ebx
f0105095:	56                   	push   %esi
f0105096:	e8 92 fe ff ff       	call   f0104f2d <printfmt>
f010509b:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f010509e:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
f01050a1:	e9 8d 02 00 00       	jmp    f0105333 <vprintfmt+0x3e5>
			if ((p = va_arg(ap, char *)) == NULL)
f01050a6:	8b 45 14             	mov    0x14(%ebp),%eax
f01050a9:	83 c0 04             	add    $0x4,%eax
f01050ac:	89 45 c8             	mov    %eax,-0x38(%ebp)
f01050af:	8b 45 14             	mov    0x14(%ebp),%eax
f01050b2:	8b 10                	mov    (%eax),%edx
				p = "(null)";
f01050b4:	85 d2                	test   %edx,%edx
f01050b6:	b8 4f 7b 10 f0       	mov    $0xf0107b4f,%eax
f01050bb:	0f 45 c2             	cmovne %edx,%eax
f01050be:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
f01050c1:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f01050c5:	7e 06                	jle    f01050cd <vprintfmt+0x17f>
f01050c7:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
f01050cb:	75 0d                	jne    f01050da <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
f01050cd:	8b 45 cc             	mov    -0x34(%ebp),%eax
f01050d0:	89 c7                	mov    %eax,%edi
f01050d2:	03 45 e0             	add    -0x20(%ebp),%eax
f01050d5:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01050d8:	eb 55                	jmp    f010512f <vprintfmt+0x1e1>
f01050da:	83 ec 08             	sub    $0x8,%esp
f01050dd:	ff 75 d8             	pushl  -0x28(%ebp)
f01050e0:	ff 75 cc             	pushl  -0x34(%ebp)
f01050e3:	e8 6b 04 00 00       	call   f0105553 <strnlen>
f01050e8:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01050eb:	29 c2                	sub    %eax,%edx
f01050ed:	89 55 c4             	mov    %edx,-0x3c(%ebp)
f01050f0:	83 c4 10             	add    $0x10,%esp
f01050f3:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
f01050f5:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
f01050f9:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
f01050fc:	85 ff                	test   %edi,%edi
f01050fe:	7e 11                	jle    f0105111 <vprintfmt+0x1c3>
					putch(padc, putdat);
f0105100:	83 ec 08             	sub    $0x8,%esp
f0105103:	53                   	push   %ebx
f0105104:	ff 75 e0             	pushl  -0x20(%ebp)
f0105107:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
f0105109:	83 ef 01             	sub    $0x1,%edi
f010510c:	83 c4 10             	add    $0x10,%esp
f010510f:	eb eb                	jmp    f01050fc <vprintfmt+0x1ae>
f0105111:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f0105114:	85 d2                	test   %edx,%edx
f0105116:	b8 00 00 00 00       	mov    $0x0,%eax
f010511b:	0f 49 c2             	cmovns %edx,%eax
f010511e:	29 c2                	sub    %eax,%edx
f0105120:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0105123:	eb a8                	jmp    f01050cd <vprintfmt+0x17f>
					putch(ch, putdat);
f0105125:	83 ec 08             	sub    $0x8,%esp
f0105128:	53                   	push   %ebx
f0105129:	52                   	push   %edx
f010512a:	ff d6                	call   *%esi
f010512c:	83 c4 10             	add    $0x10,%esp
f010512f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0105132:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0105134:	83 c7 01             	add    $0x1,%edi
f0105137:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f010513b:	0f be d0             	movsbl %al,%edx
f010513e:	85 d2                	test   %edx,%edx
f0105140:	74 4b                	je     f010518d <vprintfmt+0x23f>
f0105142:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0105146:	78 06                	js     f010514e <vprintfmt+0x200>
f0105148:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
f010514c:	78 1e                	js     f010516c <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
f010514e:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f0105152:	74 d1                	je     f0105125 <vprintfmt+0x1d7>
f0105154:	0f be c0             	movsbl %al,%eax
f0105157:	83 e8 20             	sub    $0x20,%eax
f010515a:	83 f8 5e             	cmp    $0x5e,%eax
f010515d:	76 c6                	jbe    f0105125 <vprintfmt+0x1d7>
					putch('?', putdat);
f010515f:	83 ec 08             	sub    $0x8,%esp
f0105162:	53                   	push   %ebx
f0105163:	6a 3f                	push   $0x3f
f0105165:	ff d6                	call   *%esi
f0105167:	83 c4 10             	add    $0x10,%esp
f010516a:	eb c3                	jmp    f010512f <vprintfmt+0x1e1>
f010516c:	89 cf                	mov    %ecx,%edi
f010516e:	eb 0e                	jmp    f010517e <vprintfmt+0x230>
				putch(' ', putdat);
f0105170:	83 ec 08             	sub    $0x8,%esp
f0105173:	53                   	push   %ebx
f0105174:	6a 20                	push   $0x20
f0105176:	ff d6                	call   *%esi
			for (; width > 0; width--)
f0105178:	83 ef 01             	sub    $0x1,%edi
f010517b:	83 c4 10             	add    $0x10,%esp
f010517e:	85 ff                	test   %edi,%edi
f0105180:	7f ee                	jg     f0105170 <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
f0105182:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0105185:	89 45 14             	mov    %eax,0x14(%ebp)
f0105188:	e9 a6 01 00 00       	jmp    f0105333 <vprintfmt+0x3e5>
f010518d:	89 cf                	mov    %ecx,%edi
f010518f:	eb ed                	jmp    f010517e <vprintfmt+0x230>
	if (lflag >= 2)
f0105191:	83 f9 01             	cmp    $0x1,%ecx
f0105194:	7f 1f                	jg     f01051b5 <vprintfmt+0x267>
	else if (lflag)
f0105196:	85 c9                	test   %ecx,%ecx
f0105198:	74 67                	je     f0105201 <vprintfmt+0x2b3>
		return va_arg(*ap, long);
f010519a:	8b 45 14             	mov    0x14(%ebp),%eax
f010519d:	8b 00                	mov    (%eax),%eax
f010519f:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01051a2:	89 c1                	mov    %eax,%ecx
f01051a4:	c1 f9 1f             	sar    $0x1f,%ecx
f01051a7:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f01051aa:	8b 45 14             	mov    0x14(%ebp),%eax
f01051ad:	8d 40 04             	lea    0x4(%eax),%eax
f01051b0:	89 45 14             	mov    %eax,0x14(%ebp)
f01051b3:	eb 17                	jmp    f01051cc <vprintfmt+0x27e>
		return va_arg(*ap, long long);
f01051b5:	8b 45 14             	mov    0x14(%ebp),%eax
f01051b8:	8b 50 04             	mov    0x4(%eax),%edx
f01051bb:	8b 00                	mov    (%eax),%eax
f01051bd:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01051c0:	89 55 dc             	mov    %edx,-0x24(%ebp)
f01051c3:	8b 45 14             	mov    0x14(%ebp),%eax
f01051c6:	8d 40 08             	lea    0x8(%eax),%eax
f01051c9:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
f01051cc:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01051cf:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
f01051d2:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
f01051d7:	85 c9                	test   %ecx,%ecx
f01051d9:	0f 89 3a 01 00 00    	jns    f0105319 <vprintfmt+0x3cb>
				putch('-', putdat);
f01051df:	83 ec 08             	sub    $0x8,%esp
f01051e2:	53                   	push   %ebx
f01051e3:	6a 2d                	push   $0x2d
f01051e5:	ff d6                	call   *%esi
				num = -(long long) num;
f01051e7:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01051ea:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f01051ed:	f7 da                	neg    %edx
f01051ef:	83 d1 00             	adc    $0x0,%ecx
f01051f2:	f7 d9                	neg    %ecx
f01051f4:	83 c4 10             	add    $0x10,%esp
			base = 10;
f01051f7:	b8 0a 00 00 00       	mov    $0xa,%eax
f01051fc:	e9 18 01 00 00       	jmp    f0105319 <vprintfmt+0x3cb>
		return va_arg(*ap, int);
f0105201:	8b 45 14             	mov    0x14(%ebp),%eax
f0105204:	8b 00                	mov    (%eax),%eax
f0105206:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105209:	89 c1                	mov    %eax,%ecx
f010520b:	c1 f9 1f             	sar    $0x1f,%ecx
f010520e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0105211:	8b 45 14             	mov    0x14(%ebp),%eax
f0105214:	8d 40 04             	lea    0x4(%eax),%eax
f0105217:	89 45 14             	mov    %eax,0x14(%ebp)
f010521a:	eb b0                	jmp    f01051cc <vprintfmt+0x27e>
	if (lflag >= 2)
f010521c:	83 f9 01             	cmp    $0x1,%ecx
f010521f:	7f 1e                	jg     f010523f <vprintfmt+0x2f1>
	else if (lflag)
f0105221:	85 c9                	test   %ecx,%ecx
f0105223:	74 32                	je     f0105257 <vprintfmt+0x309>
		return va_arg(*ap, unsigned long);
f0105225:	8b 45 14             	mov    0x14(%ebp),%eax
f0105228:	8b 10                	mov    (%eax),%edx
f010522a:	b9 00 00 00 00       	mov    $0x0,%ecx
f010522f:	8d 40 04             	lea    0x4(%eax),%eax
f0105232:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0105235:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
f010523a:	e9 da 00 00 00       	jmp    f0105319 <vprintfmt+0x3cb>
		return va_arg(*ap, unsigned long long);
f010523f:	8b 45 14             	mov    0x14(%ebp),%eax
f0105242:	8b 10                	mov    (%eax),%edx
f0105244:	8b 48 04             	mov    0x4(%eax),%ecx
f0105247:	8d 40 08             	lea    0x8(%eax),%eax
f010524a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f010524d:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
f0105252:	e9 c2 00 00 00       	jmp    f0105319 <vprintfmt+0x3cb>
		return va_arg(*ap, unsigned int);
f0105257:	8b 45 14             	mov    0x14(%ebp),%eax
f010525a:	8b 10                	mov    (%eax),%edx
f010525c:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105261:	8d 40 04             	lea    0x4(%eax),%eax
f0105264:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0105267:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
f010526c:	e9 a8 00 00 00       	jmp    f0105319 <vprintfmt+0x3cb>
	if (lflag >= 2)
f0105271:	83 f9 01             	cmp    $0x1,%ecx
f0105274:	7f 1b                	jg     f0105291 <vprintfmt+0x343>
	else if (lflag)
f0105276:	85 c9                	test   %ecx,%ecx
f0105278:	74 5c                	je     f01052d6 <vprintfmt+0x388>
		return va_arg(*ap, long);
f010527a:	8b 45 14             	mov    0x14(%ebp),%eax
f010527d:	8b 00                	mov    (%eax),%eax
f010527f:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105282:	99                   	cltd   
f0105283:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0105286:	8b 45 14             	mov    0x14(%ebp),%eax
f0105289:	8d 40 04             	lea    0x4(%eax),%eax
f010528c:	89 45 14             	mov    %eax,0x14(%ebp)
f010528f:	eb 17                	jmp    f01052a8 <vprintfmt+0x35a>
		return va_arg(*ap, long long);
f0105291:	8b 45 14             	mov    0x14(%ebp),%eax
f0105294:	8b 50 04             	mov    0x4(%eax),%edx
f0105297:	8b 00                	mov    (%eax),%eax
f0105299:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010529c:	89 55 dc             	mov    %edx,-0x24(%ebp)
f010529f:	8b 45 14             	mov    0x14(%ebp),%eax
f01052a2:	8d 40 08             	lea    0x8(%eax),%eax
f01052a5:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
f01052a8:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01052ab:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 8;
f01052ae:	b8 08 00 00 00       	mov    $0x8,%eax
			if ((long long) num < 0) {
f01052b3:	85 c9                	test   %ecx,%ecx
f01052b5:	79 62                	jns    f0105319 <vprintfmt+0x3cb>
				putch('-', putdat);
f01052b7:	83 ec 08             	sub    $0x8,%esp
f01052ba:	53                   	push   %ebx
f01052bb:	6a 2d                	push   $0x2d
f01052bd:	ff d6                	call   *%esi
				num = -(long long) num;
f01052bf:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01052c2:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f01052c5:	f7 da                	neg    %edx
f01052c7:	83 d1 00             	adc    $0x0,%ecx
f01052ca:	f7 d9                	neg    %ecx
f01052cc:	83 c4 10             	add    $0x10,%esp
			base = 8;
f01052cf:	b8 08 00 00 00       	mov    $0x8,%eax
f01052d4:	eb 43                	jmp    f0105319 <vprintfmt+0x3cb>
		return va_arg(*ap, int);
f01052d6:	8b 45 14             	mov    0x14(%ebp),%eax
f01052d9:	8b 00                	mov    (%eax),%eax
f01052db:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01052de:	89 c1                	mov    %eax,%ecx
f01052e0:	c1 f9 1f             	sar    $0x1f,%ecx
f01052e3:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f01052e6:	8b 45 14             	mov    0x14(%ebp),%eax
f01052e9:	8d 40 04             	lea    0x4(%eax),%eax
f01052ec:	89 45 14             	mov    %eax,0x14(%ebp)
f01052ef:	eb b7                	jmp    f01052a8 <vprintfmt+0x35a>
			putch('0', putdat);
f01052f1:	83 ec 08             	sub    $0x8,%esp
f01052f4:	53                   	push   %ebx
f01052f5:	6a 30                	push   $0x30
f01052f7:	ff d6                	call   *%esi
			putch('x', putdat);
f01052f9:	83 c4 08             	add    $0x8,%esp
f01052fc:	53                   	push   %ebx
f01052fd:	6a 78                	push   $0x78
f01052ff:	ff d6                	call   *%esi
			num = (unsigned long long)
f0105301:	8b 45 14             	mov    0x14(%ebp),%eax
f0105304:	8b 10                	mov    (%eax),%edx
f0105306:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
f010530b:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
f010530e:	8d 40 04             	lea    0x4(%eax),%eax
f0105311:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0105314:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
f0105319:	83 ec 0c             	sub    $0xc,%esp
f010531c:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
f0105320:	57                   	push   %edi
f0105321:	ff 75 e0             	pushl  -0x20(%ebp)
f0105324:	50                   	push   %eax
f0105325:	51                   	push   %ecx
f0105326:	52                   	push   %edx
f0105327:	89 da                	mov    %ebx,%edx
f0105329:	89 f0                	mov    %esi,%eax
f010532b:	e8 33 fb ff ff       	call   f0104e63 <printnum>
			break;
f0105330:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
f0105333:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0105336:	83 c7 01             	add    $0x1,%edi
f0105339:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f010533d:	83 f8 25             	cmp    $0x25,%eax
f0105340:	0f 84 23 fc ff ff    	je     f0104f69 <vprintfmt+0x1b>
			if (ch == '\0')
f0105346:	85 c0                	test   %eax,%eax
f0105348:	0f 84 8b 00 00 00    	je     f01053d9 <vprintfmt+0x48b>
			putch(ch, putdat);
f010534e:	83 ec 08             	sub    $0x8,%esp
f0105351:	53                   	push   %ebx
f0105352:	50                   	push   %eax
f0105353:	ff d6                	call   *%esi
f0105355:	83 c4 10             	add    $0x10,%esp
f0105358:	eb dc                	jmp    f0105336 <vprintfmt+0x3e8>
	if (lflag >= 2)
f010535a:	83 f9 01             	cmp    $0x1,%ecx
f010535d:	7f 1b                	jg     f010537a <vprintfmt+0x42c>
	else if (lflag)
f010535f:	85 c9                	test   %ecx,%ecx
f0105361:	74 2c                	je     f010538f <vprintfmt+0x441>
		return va_arg(*ap, unsigned long);
f0105363:	8b 45 14             	mov    0x14(%ebp),%eax
f0105366:	8b 10                	mov    (%eax),%edx
f0105368:	b9 00 00 00 00       	mov    $0x0,%ecx
f010536d:	8d 40 04             	lea    0x4(%eax),%eax
f0105370:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0105373:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
f0105378:	eb 9f                	jmp    f0105319 <vprintfmt+0x3cb>
		return va_arg(*ap, unsigned long long);
f010537a:	8b 45 14             	mov    0x14(%ebp),%eax
f010537d:	8b 10                	mov    (%eax),%edx
f010537f:	8b 48 04             	mov    0x4(%eax),%ecx
f0105382:	8d 40 08             	lea    0x8(%eax),%eax
f0105385:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0105388:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
f010538d:	eb 8a                	jmp    f0105319 <vprintfmt+0x3cb>
		return va_arg(*ap, unsigned int);
f010538f:	8b 45 14             	mov    0x14(%ebp),%eax
f0105392:	8b 10                	mov    (%eax),%edx
f0105394:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105399:	8d 40 04             	lea    0x4(%eax),%eax
f010539c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f010539f:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
f01053a4:	e9 70 ff ff ff       	jmp    f0105319 <vprintfmt+0x3cb>
			putch(ch, putdat);
f01053a9:	83 ec 08             	sub    $0x8,%esp
f01053ac:	53                   	push   %ebx
f01053ad:	6a 25                	push   $0x25
f01053af:	ff d6                	call   *%esi
			break;
f01053b1:	83 c4 10             	add    $0x10,%esp
f01053b4:	e9 7a ff ff ff       	jmp    f0105333 <vprintfmt+0x3e5>
			putch('%', putdat);
f01053b9:	83 ec 08             	sub    $0x8,%esp
f01053bc:	53                   	push   %ebx
f01053bd:	6a 25                	push   $0x25
f01053bf:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f01053c1:	83 c4 10             	add    $0x10,%esp
f01053c4:	89 f8                	mov    %edi,%eax
f01053c6:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
f01053ca:	74 05                	je     f01053d1 <vprintfmt+0x483>
f01053cc:	83 e8 01             	sub    $0x1,%eax
f01053cf:	eb f5                	jmp    f01053c6 <vprintfmt+0x478>
f01053d1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01053d4:	e9 5a ff ff ff       	jmp    f0105333 <vprintfmt+0x3e5>
}
f01053d9:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01053dc:	5b                   	pop    %ebx
f01053dd:	5e                   	pop    %esi
f01053de:	5f                   	pop    %edi
f01053df:	5d                   	pop    %ebp
f01053e0:	c3                   	ret    

f01053e1 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f01053e1:	f3 0f 1e fb          	endbr32 
f01053e5:	55                   	push   %ebp
f01053e6:	89 e5                	mov    %esp,%ebp
f01053e8:	83 ec 18             	sub    $0x18,%esp
f01053eb:	8b 45 08             	mov    0x8(%ebp),%eax
f01053ee:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f01053f1:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01053f4:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f01053f8:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f01053fb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0105402:	85 c0                	test   %eax,%eax
f0105404:	74 26                	je     f010542c <vsnprintf+0x4b>
f0105406:	85 d2                	test   %edx,%edx
f0105408:	7e 22                	jle    f010542c <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f010540a:	ff 75 14             	pushl  0x14(%ebp)
f010540d:	ff 75 10             	pushl  0x10(%ebp)
f0105410:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0105413:	50                   	push   %eax
f0105414:	68 0c 4f 10 f0       	push   $0xf0104f0c
f0105419:	e8 30 fb ff ff       	call   f0104f4e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f010541e:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0105421:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0105424:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0105427:	83 c4 10             	add    $0x10,%esp
}
f010542a:	c9                   	leave  
f010542b:	c3                   	ret    
		return -E_INVAL;
f010542c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0105431:	eb f7                	jmp    f010542a <vsnprintf+0x49>

f0105433 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0105433:	f3 0f 1e fb          	endbr32 
f0105437:	55                   	push   %ebp
f0105438:	89 e5                	mov    %esp,%ebp
f010543a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f010543d:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0105440:	50                   	push   %eax
f0105441:	ff 75 10             	pushl  0x10(%ebp)
f0105444:	ff 75 0c             	pushl  0xc(%ebp)
f0105447:	ff 75 08             	pushl  0x8(%ebp)
f010544a:	e8 92 ff ff ff       	call   f01053e1 <vsnprintf>
	va_end(ap);

	return rc;
}
f010544f:	c9                   	leave  
f0105450:	c3                   	ret    

f0105451 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0105451:	f3 0f 1e fb          	endbr32 
f0105455:	55                   	push   %ebp
f0105456:	89 e5                	mov    %esp,%ebp
f0105458:	57                   	push   %edi
f0105459:	56                   	push   %esi
f010545a:	53                   	push   %ebx
f010545b:	83 ec 0c             	sub    $0xc,%esp
f010545e:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0105461:	85 c0                	test   %eax,%eax
f0105463:	74 11                	je     f0105476 <readline+0x25>
		cprintf("%s", prompt);
f0105465:	83 ec 08             	sub    $0x8,%esp
f0105468:	50                   	push   %eax
f0105469:	68 15 69 10 f0       	push   $0xf0106915
f010546e:	e8 6b e4 ff ff       	call   f01038de <cprintf>
f0105473:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f0105476:	83 ec 0c             	sub    $0xc,%esp
f0105479:	6a 00                	push   $0x0
f010547b:	e8 3b b3 ff ff       	call   f01007bb <iscons>
f0105480:	89 c7                	mov    %eax,%edi
f0105482:	83 c4 10             	add    $0x10,%esp
	i = 0;
f0105485:	be 00 00 00 00       	mov    $0x0,%esi
f010548a:	eb 4b                	jmp    f01054d7 <readline+0x86>
	while (1) {
		c = getchar();
		if (c < 0) {
			cprintf("read error: %e\n", c);
f010548c:	83 ec 08             	sub    $0x8,%esp
f010548f:	50                   	push   %eax
f0105490:	68 84 7d 10 f0       	push   $0xf0107d84
f0105495:	e8 44 e4 ff ff       	call   f01038de <cprintf>
			return NULL;
f010549a:	83 c4 10             	add    $0x10,%esp
f010549d:	b8 00 00 00 00       	mov    $0x0,%eax
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
f01054a2:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01054a5:	5b                   	pop    %ebx
f01054a6:	5e                   	pop    %esi
f01054a7:	5f                   	pop    %edi
f01054a8:	5d                   	pop    %ebp
f01054a9:	c3                   	ret    
			if (echoing)
f01054aa:	85 ff                	test   %edi,%edi
f01054ac:	75 05                	jne    f01054b3 <readline+0x62>
			i--;
f01054ae:	83 ee 01             	sub    $0x1,%esi
f01054b1:	eb 24                	jmp    f01054d7 <readline+0x86>
				cputchar('\b');
f01054b3:	83 ec 0c             	sub    $0xc,%esp
f01054b6:	6a 08                	push   $0x8
f01054b8:	e8 d5 b2 ff ff       	call   f0100792 <cputchar>
f01054bd:	83 c4 10             	add    $0x10,%esp
f01054c0:	eb ec                	jmp    f01054ae <readline+0x5d>
				cputchar(c);
f01054c2:	83 ec 0c             	sub    $0xc,%esp
f01054c5:	53                   	push   %ebx
f01054c6:	e8 c7 b2 ff ff       	call   f0100792 <cputchar>
f01054cb:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f01054ce:	88 9e 80 6a 23 f0    	mov    %bl,-0xfdc9580(%esi)
f01054d4:	8d 76 01             	lea    0x1(%esi),%esi
		c = getchar();
f01054d7:	e8 ca b2 ff ff       	call   f01007a6 <getchar>
f01054dc:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f01054de:	85 c0                	test   %eax,%eax
f01054e0:	78 aa                	js     f010548c <readline+0x3b>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f01054e2:	83 f8 08             	cmp    $0x8,%eax
f01054e5:	0f 94 c2             	sete   %dl
f01054e8:	83 f8 7f             	cmp    $0x7f,%eax
f01054eb:	0f 94 c0             	sete   %al
f01054ee:	08 c2                	or     %al,%dl
f01054f0:	74 04                	je     f01054f6 <readline+0xa5>
f01054f2:	85 f6                	test   %esi,%esi
f01054f4:	7f b4                	jg     f01054aa <readline+0x59>
		} else if (c >= ' ' && i < BUFLEN-1) {
f01054f6:	83 fb 1f             	cmp    $0x1f,%ebx
f01054f9:	7e 0e                	jle    f0105509 <readline+0xb8>
f01054fb:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0105501:	7f 06                	jg     f0105509 <readline+0xb8>
			if (echoing)
f0105503:	85 ff                	test   %edi,%edi
f0105505:	74 c7                	je     f01054ce <readline+0x7d>
f0105507:	eb b9                	jmp    f01054c2 <readline+0x71>
		} else if (c == '\n' || c == '\r') {
f0105509:	83 fb 0a             	cmp    $0xa,%ebx
f010550c:	74 05                	je     f0105513 <readline+0xc2>
f010550e:	83 fb 0d             	cmp    $0xd,%ebx
f0105511:	75 c4                	jne    f01054d7 <readline+0x86>
			if (echoing)
f0105513:	85 ff                	test   %edi,%edi
f0105515:	75 11                	jne    f0105528 <readline+0xd7>
			buf[i] = 0;
f0105517:	c6 86 80 6a 23 f0 00 	movb   $0x0,-0xfdc9580(%esi)
			return buf;
f010551e:	b8 80 6a 23 f0       	mov    $0xf0236a80,%eax
f0105523:	e9 7a ff ff ff       	jmp    f01054a2 <readline+0x51>
				cputchar('\n');
f0105528:	83 ec 0c             	sub    $0xc,%esp
f010552b:	6a 0a                	push   $0xa
f010552d:	e8 60 b2 ff ff       	call   f0100792 <cputchar>
f0105532:	83 c4 10             	add    $0x10,%esp
f0105535:	eb e0                	jmp    f0105517 <readline+0xc6>

f0105537 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0105537:	f3 0f 1e fb          	endbr32 
f010553b:	55                   	push   %ebp
f010553c:	89 e5                	mov    %esp,%ebp
f010553e:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0105541:	b8 00 00 00 00       	mov    $0x0,%eax
f0105546:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f010554a:	74 05                	je     f0105551 <strlen+0x1a>
		n++;
f010554c:	83 c0 01             	add    $0x1,%eax
f010554f:	eb f5                	jmp    f0105546 <strlen+0xf>
	return n;
}
f0105551:	5d                   	pop    %ebp
f0105552:	c3                   	ret    

f0105553 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0105553:	f3 0f 1e fb          	endbr32 
f0105557:	55                   	push   %ebp
f0105558:	89 e5                	mov    %esp,%ebp
f010555a:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010555d:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0105560:	b8 00 00 00 00       	mov    $0x0,%eax
f0105565:	39 d0                	cmp    %edx,%eax
f0105567:	74 0d                	je     f0105576 <strnlen+0x23>
f0105569:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f010556d:	74 05                	je     f0105574 <strnlen+0x21>
		n++;
f010556f:	83 c0 01             	add    $0x1,%eax
f0105572:	eb f1                	jmp    f0105565 <strnlen+0x12>
f0105574:	89 c2                	mov    %eax,%edx
	return n;
}
f0105576:	89 d0                	mov    %edx,%eax
f0105578:	5d                   	pop    %ebp
f0105579:	c3                   	ret    

f010557a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f010557a:	f3 0f 1e fb          	endbr32 
f010557e:	55                   	push   %ebp
f010557f:	89 e5                	mov    %esp,%ebp
f0105581:	53                   	push   %ebx
f0105582:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105585:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0105588:	b8 00 00 00 00       	mov    $0x0,%eax
f010558d:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
f0105591:	88 14 01             	mov    %dl,(%ecx,%eax,1)
f0105594:	83 c0 01             	add    $0x1,%eax
f0105597:	84 d2                	test   %dl,%dl
f0105599:	75 f2                	jne    f010558d <strcpy+0x13>
		/* do nothing */;
	return ret;
}
f010559b:	89 c8                	mov    %ecx,%eax
f010559d:	5b                   	pop    %ebx
f010559e:	5d                   	pop    %ebp
f010559f:	c3                   	ret    

f01055a0 <strcat>:

char *
strcat(char *dst, const char *src)
{
f01055a0:	f3 0f 1e fb          	endbr32 
f01055a4:	55                   	push   %ebp
f01055a5:	89 e5                	mov    %esp,%ebp
f01055a7:	53                   	push   %ebx
f01055a8:	83 ec 10             	sub    $0x10,%esp
f01055ab:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f01055ae:	53                   	push   %ebx
f01055af:	e8 83 ff ff ff       	call   f0105537 <strlen>
f01055b4:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
f01055b7:	ff 75 0c             	pushl  0xc(%ebp)
f01055ba:	01 d8                	add    %ebx,%eax
f01055bc:	50                   	push   %eax
f01055bd:	e8 b8 ff ff ff       	call   f010557a <strcpy>
	return dst;
}
f01055c2:	89 d8                	mov    %ebx,%eax
f01055c4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01055c7:	c9                   	leave  
f01055c8:	c3                   	ret    

f01055c9 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f01055c9:	f3 0f 1e fb          	endbr32 
f01055cd:	55                   	push   %ebp
f01055ce:	89 e5                	mov    %esp,%ebp
f01055d0:	56                   	push   %esi
f01055d1:	53                   	push   %ebx
f01055d2:	8b 75 08             	mov    0x8(%ebp),%esi
f01055d5:	8b 55 0c             	mov    0xc(%ebp),%edx
f01055d8:	89 f3                	mov    %esi,%ebx
f01055da:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01055dd:	89 f0                	mov    %esi,%eax
f01055df:	39 d8                	cmp    %ebx,%eax
f01055e1:	74 11                	je     f01055f4 <strncpy+0x2b>
		*dst++ = *src;
f01055e3:	83 c0 01             	add    $0x1,%eax
f01055e6:	0f b6 0a             	movzbl (%edx),%ecx
f01055e9:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f01055ec:	80 f9 01             	cmp    $0x1,%cl
f01055ef:	83 da ff             	sbb    $0xffffffff,%edx
f01055f2:	eb eb                	jmp    f01055df <strncpy+0x16>
	}
	return ret;
}
f01055f4:	89 f0                	mov    %esi,%eax
f01055f6:	5b                   	pop    %ebx
f01055f7:	5e                   	pop    %esi
f01055f8:	5d                   	pop    %ebp
f01055f9:	c3                   	ret    

f01055fa <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f01055fa:	f3 0f 1e fb          	endbr32 
f01055fe:	55                   	push   %ebp
f01055ff:	89 e5                	mov    %esp,%ebp
f0105601:	56                   	push   %esi
f0105602:	53                   	push   %ebx
f0105603:	8b 75 08             	mov    0x8(%ebp),%esi
f0105606:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0105609:	8b 55 10             	mov    0x10(%ebp),%edx
f010560c:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f010560e:	85 d2                	test   %edx,%edx
f0105610:	74 21                	je     f0105633 <strlcpy+0x39>
f0105612:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f0105616:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
f0105618:	39 c2                	cmp    %eax,%edx
f010561a:	74 14                	je     f0105630 <strlcpy+0x36>
f010561c:	0f b6 19             	movzbl (%ecx),%ebx
f010561f:	84 db                	test   %bl,%bl
f0105621:	74 0b                	je     f010562e <strlcpy+0x34>
			*dst++ = *src++;
f0105623:	83 c1 01             	add    $0x1,%ecx
f0105626:	83 c2 01             	add    $0x1,%edx
f0105629:	88 5a ff             	mov    %bl,-0x1(%edx)
f010562c:	eb ea                	jmp    f0105618 <strlcpy+0x1e>
f010562e:	89 d0                	mov    %edx,%eax
		*dst = '\0';
f0105630:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0105633:	29 f0                	sub    %esi,%eax
}
f0105635:	5b                   	pop    %ebx
f0105636:	5e                   	pop    %esi
f0105637:	5d                   	pop    %ebp
f0105638:	c3                   	ret    

f0105639 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0105639:	f3 0f 1e fb          	endbr32 
f010563d:	55                   	push   %ebp
f010563e:	89 e5                	mov    %esp,%ebp
f0105640:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105643:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0105646:	0f b6 01             	movzbl (%ecx),%eax
f0105649:	84 c0                	test   %al,%al
f010564b:	74 0c                	je     f0105659 <strcmp+0x20>
f010564d:	3a 02                	cmp    (%edx),%al
f010564f:	75 08                	jne    f0105659 <strcmp+0x20>
		p++, q++;
f0105651:	83 c1 01             	add    $0x1,%ecx
f0105654:	83 c2 01             	add    $0x1,%edx
f0105657:	eb ed                	jmp    f0105646 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0105659:	0f b6 c0             	movzbl %al,%eax
f010565c:	0f b6 12             	movzbl (%edx),%edx
f010565f:	29 d0                	sub    %edx,%eax
}
f0105661:	5d                   	pop    %ebp
f0105662:	c3                   	ret    

f0105663 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0105663:	f3 0f 1e fb          	endbr32 
f0105667:	55                   	push   %ebp
f0105668:	89 e5                	mov    %esp,%ebp
f010566a:	53                   	push   %ebx
f010566b:	8b 45 08             	mov    0x8(%ebp),%eax
f010566e:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105671:	89 c3                	mov    %eax,%ebx
f0105673:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0105676:	eb 06                	jmp    f010567e <strncmp+0x1b>
		n--, p++, q++;
f0105678:	83 c0 01             	add    $0x1,%eax
f010567b:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
f010567e:	39 d8                	cmp    %ebx,%eax
f0105680:	74 16                	je     f0105698 <strncmp+0x35>
f0105682:	0f b6 08             	movzbl (%eax),%ecx
f0105685:	84 c9                	test   %cl,%cl
f0105687:	74 04                	je     f010568d <strncmp+0x2a>
f0105689:	3a 0a                	cmp    (%edx),%cl
f010568b:	74 eb                	je     f0105678 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f010568d:	0f b6 00             	movzbl (%eax),%eax
f0105690:	0f b6 12             	movzbl (%edx),%edx
f0105693:	29 d0                	sub    %edx,%eax
}
f0105695:	5b                   	pop    %ebx
f0105696:	5d                   	pop    %ebp
f0105697:	c3                   	ret    
		return 0;
f0105698:	b8 00 00 00 00       	mov    $0x0,%eax
f010569d:	eb f6                	jmp    f0105695 <strncmp+0x32>

f010569f <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f010569f:	f3 0f 1e fb          	endbr32 
f01056a3:	55                   	push   %ebp
f01056a4:	89 e5                	mov    %esp,%ebp
f01056a6:	8b 45 08             	mov    0x8(%ebp),%eax
f01056a9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01056ad:	0f b6 10             	movzbl (%eax),%edx
f01056b0:	84 d2                	test   %dl,%dl
f01056b2:	74 09                	je     f01056bd <strchr+0x1e>
		if (*s == c)
f01056b4:	38 ca                	cmp    %cl,%dl
f01056b6:	74 0a                	je     f01056c2 <strchr+0x23>
	for (; *s; s++)
f01056b8:	83 c0 01             	add    $0x1,%eax
f01056bb:	eb f0                	jmp    f01056ad <strchr+0xe>
			return (char *) s;
	return 0;
f01056bd:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01056c2:	5d                   	pop    %ebp
f01056c3:	c3                   	ret    

f01056c4 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f01056c4:	f3 0f 1e fb          	endbr32 
f01056c8:	55                   	push   %ebp
f01056c9:	89 e5                	mov    %esp,%ebp
f01056cb:	8b 45 08             	mov    0x8(%ebp),%eax
f01056ce:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01056d2:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f01056d5:	38 ca                	cmp    %cl,%dl
f01056d7:	74 09                	je     f01056e2 <strfind+0x1e>
f01056d9:	84 d2                	test   %dl,%dl
f01056db:	74 05                	je     f01056e2 <strfind+0x1e>
	for (; *s; s++)
f01056dd:	83 c0 01             	add    $0x1,%eax
f01056e0:	eb f0                	jmp    f01056d2 <strfind+0xe>
			break;
	return (char *) s;
}
f01056e2:	5d                   	pop    %ebp
f01056e3:	c3                   	ret    

f01056e4 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f01056e4:	f3 0f 1e fb          	endbr32 
f01056e8:	55                   	push   %ebp
f01056e9:	89 e5                	mov    %esp,%ebp
f01056eb:	57                   	push   %edi
f01056ec:	56                   	push   %esi
f01056ed:	53                   	push   %ebx
f01056ee:	8b 7d 08             	mov    0x8(%ebp),%edi
f01056f1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f01056f4:	85 c9                	test   %ecx,%ecx
f01056f6:	74 31                	je     f0105729 <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f01056f8:	89 f8                	mov    %edi,%eax
f01056fa:	09 c8                	or     %ecx,%eax
f01056fc:	a8 03                	test   $0x3,%al
f01056fe:	75 23                	jne    f0105723 <memset+0x3f>
		c &= 0xFF;
f0105700:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0105704:	89 d3                	mov    %edx,%ebx
f0105706:	c1 e3 08             	shl    $0x8,%ebx
f0105709:	89 d0                	mov    %edx,%eax
f010570b:	c1 e0 18             	shl    $0x18,%eax
f010570e:	89 d6                	mov    %edx,%esi
f0105710:	c1 e6 10             	shl    $0x10,%esi
f0105713:	09 f0                	or     %esi,%eax
f0105715:	09 c2                	or     %eax,%edx
f0105717:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f0105719:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
f010571c:	89 d0                	mov    %edx,%eax
f010571e:	fc                   	cld    
f010571f:	f3 ab                	rep stos %eax,%es:(%edi)
f0105721:	eb 06                	jmp    f0105729 <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0105723:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105726:	fc                   	cld    
f0105727:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0105729:	89 f8                	mov    %edi,%eax
f010572b:	5b                   	pop    %ebx
f010572c:	5e                   	pop    %esi
f010572d:	5f                   	pop    %edi
f010572e:	5d                   	pop    %ebp
f010572f:	c3                   	ret    

f0105730 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0105730:	f3 0f 1e fb          	endbr32 
f0105734:	55                   	push   %ebp
f0105735:	89 e5                	mov    %esp,%ebp
f0105737:	57                   	push   %edi
f0105738:	56                   	push   %esi
f0105739:	8b 45 08             	mov    0x8(%ebp),%eax
f010573c:	8b 75 0c             	mov    0xc(%ebp),%esi
f010573f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0105742:	39 c6                	cmp    %eax,%esi
f0105744:	73 32                	jae    f0105778 <memmove+0x48>
f0105746:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0105749:	39 c2                	cmp    %eax,%edx
f010574b:	76 2b                	jbe    f0105778 <memmove+0x48>
		s += n;
		d += n;
f010574d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105750:	89 fe                	mov    %edi,%esi
f0105752:	09 ce                	or     %ecx,%esi
f0105754:	09 d6                	or     %edx,%esi
f0105756:	f7 c6 03 00 00 00    	test   $0x3,%esi
f010575c:	75 0e                	jne    f010576c <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f010575e:	83 ef 04             	sub    $0x4,%edi
f0105761:	8d 72 fc             	lea    -0x4(%edx),%esi
f0105764:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
f0105767:	fd                   	std    
f0105768:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010576a:	eb 09                	jmp    f0105775 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f010576c:	83 ef 01             	sub    $0x1,%edi
f010576f:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
f0105772:	fd                   	std    
f0105773:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0105775:	fc                   	cld    
f0105776:	eb 1a                	jmp    f0105792 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105778:	89 c2                	mov    %eax,%edx
f010577a:	09 ca                	or     %ecx,%edx
f010577c:	09 f2                	or     %esi,%edx
f010577e:	f6 c2 03             	test   $0x3,%dl
f0105781:	75 0a                	jne    f010578d <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f0105783:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
f0105786:	89 c7                	mov    %eax,%edi
f0105788:	fc                   	cld    
f0105789:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010578b:	eb 05                	jmp    f0105792 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
f010578d:	89 c7                	mov    %eax,%edi
f010578f:	fc                   	cld    
f0105790:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0105792:	5e                   	pop    %esi
f0105793:	5f                   	pop    %edi
f0105794:	5d                   	pop    %ebp
f0105795:	c3                   	ret    

f0105796 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0105796:	f3 0f 1e fb          	endbr32 
f010579a:	55                   	push   %ebp
f010579b:	89 e5                	mov    %esp,%ebp
f010579d:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f01057a0:	ff 75 10             	pushl  0x10(%ebp)
f01057a3:	ff 75 0c             	pushl  0xc(%ebp)
f01057a6:	ff 75 08             	pushl  0x8(%ebp)
f01057a9:	e8 82 ff ff ff       	call   f0105730 <memmove>
}
f01057ae:	c9                   	leave  
f01057af:	c3                   	ret    

f01057b0 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f01057b0:	f3 0f 1e fb          	endbr32 
f01057b4:	55                   	push   %ebp
f01057b5:	89 e5                	mov    %esp,%ebp
f01057b7:	56                   	push   %esi
f01057b8:	53                   	push   %ebx
f01057b9:	8b 45 08             	mov    0x8(%ebp),%eax
f01057bc:	8b 55 0c             	mov    0xc(%ebp),%edx
f01057bf:	89 c6                	mov    %eax,%esi
f01057c1:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01057c4:	39 f0                	cmp    %esi,%eax
f01057c6:	74 1c                	je     f01057e4 <memcmp+0x34>
		if (*s1 != *s2)
f01057c8:	0f b6 08             	movzbl (%eax),%ecx
f01057cb:	0f b6 1a             	movzbl (%edx),%ebx
f01057ce:	38 d9                	cmp    %bl,%cl
f01057d0:	75 08                	jne    f01057da <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
f01057d2:	83 c0 01             	add    $0x1,%eax
f01057d5:	83 c2 01             	add    $0x1,%edx
f01057d8:	eb ea                	jmp    f01057c4 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
f01057da:	0f b6 c1             	movzbl %cl,%eax
f01057dd:	0f b6 db             	movzbl %bl,%ebx
f01057e0:	29 d8                	sub    %ebx,%eax
f01057e2:	eb 05                	jmp    f01057e9 <memcmp+0x39>
	}

	return 0;
f01057e4:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01057e9:	5b                   	pop    %ebx
f01057ea:	5e                   	pop    %esi
f01057eb:	5d                   	pop    %ebp
f01057ec:	c3                   	ret    

f01057ed <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f01057ed:	f3 0f 1e fb          	endbr32 
f01057f1:	55                   	push   %ebp
f01057f2:	89 e5                	mov    %esp,%ebp
f01057f4:	8b 45 08             	mov    0x8(%ebp),%eax
f01057f7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f01057fa:	89 c2                	mov    %eax,%edx
f01057fc:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f01057ff:	39 d0                	cmp    %edx,%eax
f0105801:	73 09                	jae    f010580c <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
f0105803:	38 08                	cmp    %cl,(%eax)
f0105805:	74 05                	je     f010580c <memfind+0x1f>
	for (; s < ends; s++)
f0105807:	83 c0 01             	add    $0x1,%eax
f010580a:	eb f3                	jmp    f01057ff <memfind+0x12>
			break;
	return (void *) s;
}
f010580c:	5d                   	pop    %ebp
f010580d:	c3                   	ret    

f010580e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f010580e:	f3 0f 1e fb          	endbr32 
f0105812:	55                   	push   %ebp
f0105813:	89 e5                	mov    %esp,%ebp
f0105815:	57                   	push   %edi
f0105816:	56                   	push   %esi
f0105817:	53                   	push   %ebx
f0105818:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010581b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010581e:	eb 03                	jmp    f0105823 <strtol+0x15>
		s++;
f0105820:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
f0105823:	0f b6 01             	movzbl (%ecx),%eax
f0105826:	3c 20                	cmp    $0x20,%al
f0105828:	74 f6                	je     f0105820 <strtol+0x12>
f010582a:	3c 09                	cmp    $0x9,%al
f010582c:	74 f2                	je     f0105820 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
f010582e:	3c 2b                	cmp    $0x2b,%al
f0105830:	74 2a                	je     f010585c <strtol+0x4e>
	int neg = 0;
f0105832:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
f0105837:	3c 2d                	cmp    $0x2d,%al
f0105839:	74 2b                	je     f0105866 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f010583b:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f0105841:	75 0f                	jne    f0105852 <strtol+0x44>
f0105843:	80 39 30             	cmpb   $0x30,(%ecx)
f0105846:	74 28                	je     f0105870 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0105848:	85 db                	test   %ebx,%ebx
f010584a:	b8 0a 00 00 00       	mov    $0xa,%eax
f010584f:	0f 44 d8             	cmove  %eax,%ebx
f0105852:	b8 00 00 00 00       	mov    $0x0,%eax
f0105857:	89 5d 10             	mov    %ebx,0x10(%ebp)
f010585a:	eb 46                	jmp    f01058a2 <strtol+0x94>
		s++;
f010585c:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
f010585f:	bf 00 00 00 00       	mov    $0x0,%edi
f0105864:	eb d5                	jmp    f010583b <strtol+0x2d>
		s++, neg = 1;
f0105866:	83 c1 01             	add    $0x1,%ecx
f0105869:	bf 01 00 00 00       	mov    $0x1,%edi
f010586e:	eb cb                	jmp    f010583b <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0105870:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f0105874:	74 0e                	je     f0105884 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
f0105876:	85 db                	test   %ebx,%ebx
f0105878:	75 d8                	jne    f0105852 <strtol+0x44>
		s++, base = 8;
f010587a:	83 c1 01             	add    $0x1,%ecx
f010587d:	bb 08 00 00 00       	mov    $0x8,%ebx
f0105882:	eb ce                	jmp    f0105852 <strtol+0x44>
		s += 2, base = 16;
f0105884:	83 c1 02             	add    $0x2,%ecx
f0105887:	bb 10 00 00 00       	mov    $0x10,%ebx
f010588c:	eb c4                	jmp    f0105852 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
f010588e:	0f be d2             	movsbl %dl,%edx
f0105891:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f0105894:	3b 55 10             	cmp    0x10(%ebp),%edx
f0105897:	7d 3a                	jge    f01058d3 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
f0105899:	83 c1 01             	add    $0x1,%ecx
f010589c:	0f af 45 10          	imul   0x10(%ebp),%eax
f01058a0:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
f01058a2:	0f b6 11             	movzbl (%ecx),%edx
f01058a5:	8d 72 d0             	lea    -0x30(%edx),%esi
f01058a8:	89 f3                	mov    %esi,%ebx
f01058aa:	80 fb 09             	cmp    $0x9,%bl
f01058ad:	76 df                	jbe    f010588e <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
f01058af:	8d 72 9f             	lea    -0x61(%edx),%esi
f01058b2:	89 f3                	mov    %esi,%ebx
f01058b4:	80 fb 19             	cmp    $0x19,%bl
f01058b7:	77 08                	ja     f01058c1 <strtol+0xb3>
			dig = *s - 'a' + 10;
f01058b9:	0f be d2             	movsbl %dl,%edx
f01058bc:	83 ea 57             	sub    $0x57,%edx
f01058bf:	eb d3                	jmp    f0105894 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
f01058c1:	8d 72 bf             	lea    -0x41(%edx),%esi
f01058c4:	89 f3                	mov    %esi,%ebx
f01058c6:	80 fb 19             	cmp    $0x19,%bl
f01058c9:	77 08                	ja     f01058d3 <strtol+0xc5>
			dig = *s - 'A' + 10;
f01058cb:	0f be d2             	movsbl %dl,%edx
f01058ce:	83 ea 37             	sub    $0x37,%edx
f01058d1:	eb c1                	jmp    f0105894 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
f01058d3:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f01058d7:	74 05                	je     f01058de <strtol+0xd0>
		*endptr = (char *) s;
f01058d9:	8b 75 0c             	mov    0xc(%ebp),%esi
f01058dc:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
f01058de:	89 c2                	mov    %eax,%edx
f01058e0:	f7 da                	neg    %edx
f01058e2:	85 ff                	test   %edi,%edi
f01058e4:	0f 45 c2             	cmovne %edx,%eax
}
f01058e7:	5b                   	pop    %ebx
f01058e8:	5e                   	pop    %esi
f01058e9:	5f                   	pop    %edi
f01058ea:	5d                   	pop    %ebp
f01058eb:	c3                   	ret    

f01058ec <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f01058ec:	fa                   	cli    

	xorw    %ax, %ax
f01058ed:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f01058ef:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f01058f1:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f01058f3:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f01058f5:	0f 01 16             	lgdtl  (%esi)
f01058f8:	74 70                	je     f010596a <mpsearch1+0x3>
	movl    %cr0, %eax
f01058fa:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f01058fd:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f0105901:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f0105904:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f010590a:	08 00                	or     %al,(%eax)

f010590c <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f010590c:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f0105910:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0105912:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0105914:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f0105916:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f010591a:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f010591c:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f010591e:	b8 00 00 12 00       	mov    $0x120000,%eax
	movl    %eax, %cr3
f0105923:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f0105926:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f0105929:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f010592e:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in boot_aps()
	movl    mpentry_kstack, %esp
f0105931:	8b 25 84 6e 23 f0    	mov    0xf0236e84,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f0105937:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f010593c:	b8 c7 01 10 f0       	mov    $0xf01001c7,%eax
	call    *%eax
f0105941:	ff d0                	call   *%eax

f0105943 <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f0105943:	eb fe                	jmp    f0105943 <spin>
f0105945:	8d 76 00             	lea    0x0(%esi),%esi

f0105948 <gdt>:
	...
f0105950:	ff                   	(bad)  
f0105951:	ff 00                	incl   (%eax)
f0105953:	00 00                	add    %al,(%eax)
f0105955:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f010595c:	00                   	.byte 0x0
f010595d:	92                   	xchg   %eax,%edx
f010595e:	cf                   	iret   
	...

f0105960 <gdtdesc>:
f0105960:	17                   	pop    %ss
f0105961:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f0105966 <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f0105966:	90                   	nop

f0105967 <mpsearch1>:
}

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f0105967:	55                   	push   %ebp
f0105968:	89 e5                	mov    %esp,%ebp
f010596a:	57                   	push   %edi
f010596b:	56                   	push   %esi
f010596c:	53                   	push   %ebx
f010596d:	83 ec 0c             	sub    $0xc,%esp
f0105970:	89 c7                	mov    %eax,%edi
	if (PGNUM(pa) >= npages)
f0105972:	a1 88 6e 23 f0       	mov    0xf0236e88,%eax
f0105977:	89 f9                	mov    %edi,%ecx
f0105979:	c1 e9 0c             	shr    $0xc,%ecx
f010597c:	39 c1                	cmp    %eax,%ecx
f010597e:	73 19                	jae    f0105999 <mpsearch1+0x32>
	return (void *)(pa + KERNBASE);
f0105980:	8d 9f 00 00 00 f0    	lea    -0x10000000(%edi),%ebx
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f0105986:	01 d7                	add    %edx,%edi
	if (PGNUM(pa) >= npages)
f0105988:	89 fa                	mov    %edi,%edx
f010598a:	c1 ea 0c             	shr    $0xc,%edx
f010598d:	39 c2                	cmp    %eax,%edx
f010598f:	73 1a                	jae    f01059ab <mpsearch1+0x44>
	return (void *)(pa + KERNBASE);
f0105991:	81 ef 00 00 00 10    	sub    $0x10000000,%edi

	for (; mp < end; mp++)
f0105997:	eb 27                	jmp    f01059c0 <mpsearch1+0x59>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105999:	57                   	push   %edi
f010599a:	68 a4 63 10 f0       	push   $0xf01063a4
f010599f:	6a 57                	push   $0x57
f01059a1:	68 21 7f 10 f0       	push   $0xf0107f21
f01059a6:	e8 95 a6 ff ff       	call   f0100040 <_panic>
f01059ab:	57                   	push   %edi
f01059ac:	68 a4 63 10 f0       	push   $0xf01063a4
f01059b1:	6a 57                	push   $0x57
f01059b3:	68 21 7f 10 f0       	push   $0xf0107f21
f01059b8:	e8 83 a6 ff ff       	call   f0100040 <_panic>
f01059bd:	83 c3 10             	add    $0x10,%ebx
f01059c0:	39 fb                	cmp    %edi,%ebx
f01059c2:	73 30                	jae    f01059f4 <mpsearch1+0x8d>
f01059c4:	89 de                	mov    %ebx,%esi
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f01059c6:	83 ec 04             	sub    $0x4,%esp
f01059c9:	6a 04                	push   $0x4
f01059cb:	68 31 7f 10 f0       	push   $0xf0107f31
f01059d0:	53                   	push   %ebx
f01059d1:	e8 da fd ff ff       	call   f01057b0 <memcmp>
f01059d6:	83 c4 10             	add    $0x10,%esp
f01059d9:	85 c0                	test   %eax,%eax
f01059db:	75 e0                	jne    f01059bd <mpsearch1+0x56>
f01059dd:	89 da                	mov    %ebx,%edx
	for (i = 0; i < len; i++)
f01059df:	83 c6 10             	add    $0x10,%esi
		sum += ((uint8_t *)addr)[i];
f01059e2:	0f b6 0a             	movzbl (%edx),%ecx
f01059e5:	01 c8                	add    %ecx,%eax
f01059e7:	83 c2 01             	add    $0x1,%edx
	for (i = 0; i < len; i++)
f01059ea:	39 f2                	cmp    %esi,%edx
f01059ec:	75 f4                	jne    f01059e2 <mpsearch1+0x7b>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f01059ee:	84 c0                	test   %al,%al
f01059f0:	75 cb                	jne    f01059bd <mpsearch1+0x56>
f01059f2:	eb 05                	jmp    f01059f9 <mpsearch1+0x92>
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
f01059f4:	bb 00 00 00 00       	mov    $0x0,%ebx
}
f01059f9:	89 d8                	mov    %ebx,%eax
f01059fb:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01059fe:	5b                   	pop    %ebx
f01059ff:	5e                   	pop    %esi
f0105a00:	5f                   	pop    %edi
f0105a01:	5d                   	pop    %ebp
f0105a02:	c3                   	ret    

f0105a03 <mp_init>:
	return conf;
}

void
mp_init(void)
{
f0105a03:	f3 0f 1e fb          	endbr32 
f0105a07:	55                   	push   %ebp
f0105a08:	89 e5                	mov    %esp,%ebp
f0105a0a:	57                   	push   %edi
f0105a0b:	56                   	push   %esi
f0105a0c:	53                   	push   %ebx
f0105a0d:	83 ec 1c             	sub    $0x1c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f0105a10:	c7 05 c0 73 23 f0 20 	movl   $0xf0237020,0xf02373c0
f0105a17:	70 23 f0 
	if (PGNUM(pa) >= npages)
f0105a1a:	83 3d 88 6e 23 f0 00 	cmpl   $0x0,0xf0236e88
f0105a21:	0f 84 a3 00 00 00    	je     f0105aca <mp_init+0xc7>
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f0105a27:	0f b7 05 0e 04 00 f0 	movzwl 0xf000040e,%eax
f0105a2e:	85 c0                	test   %eax,%eax
f0105a30:	0f 84 aa 00 00 00    	je     f0105ae0 <mp_init+0xdd>
		p <<= 4;	// Translate from segment to PA
f0105a36:	c1 e0 04             	shl    $0x4,%eax
		if ((mp = mpsearch1(p, 1024)))
f0105a39:	ba 00 04 00 00       	mov    $0x400,%edx
f0105a3e:	e8 24 ff ff ff       	call   f0105967 <mpsearch1>
f0105a43:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105a46:	85 c0                	test   %eax,%eax
f0105a48:	75 1a                	jne    f0105a64 <mp_init+0x61>
	return mpsearch1(0xF0000, 0x10000);
f0105a4a:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105a4f:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f0105a54:	e8 0e ff ff ff       	call   f0105967 <mpsearch1>
f0105a59:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	if ((mp = mpsearch()) == 0)
f0105a5c:	85 c0                	test   %eax,%eax
f0105a5e:	0f 84 35 02 00 00    	je     f0105c99 <mp_init+0x296>
	if (mp->physaddr == 0 || mp->type != 0) {
f0105a64:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105a67:	8b 58 04             	mov    0x4(%eax),%ebx
f0105a6a:	85 db                	test   %ebx,%ebx
f0105a6c:	0f 84 97 00 00 00    	je     f0105b09 <mp_init+0x106>
f0105a72:	80 78 0b 00          	cmpb   $0x0,0xb(%eax)
f0105a76:	0f 85 8d 00 00 00    	jne    f0105b09 <mp_init+0x106>
f0105a7c:	89 d8                	mov    %ebx,%eax
f0105a7e:	c1 e8 0c             	shr    $0xc,%eax
f0105a81:	3b 05 88 6e 23 f0    	cmp    0xf0236e88,%eax
f0105a87:	0f 83 91 00 00 00    	jae    f0105b1e <mp_init+0x11b>
	return (void *)(pa + KERNBASE);
f0105a8d:	81 eb 00 00 00 10    	sub    $0x10000000,%ebx
f0105a93:	89 de                	mov    %ebx,%esi
	if (memcmp(conf, "PCMP", 4) != 0) {
f0105a95:	83 ec 04             	sub    $0x4,%esp
f0105a98:	6a 04                	push   $0x4
f0105a9a:	68 36 7f 10 f0       	push   $0xf0107f36
f0105a9f:	53                   	push   %ebx
f0105aa0:	e8 0b fd ff ff       	call   f01057b0 <memcmp>
f0105aa5:	83 c4 10             	add    $0x10,%esp
f0105aa8:	85 c0                	test   %eax,%eax
f0105aaa:	0f 85 83 00 00 00    	jne    f0105b33 <mp_init+0x130>
f0105ab0:	0f b7 7b 04          	movzwl 0x4(%ebx),%edi
f0105ab4:	01 df                	add    %ebx,%edi
	sum = 0;
f0105ab6:	89 c2                	mov    %eax,%edx
	for (i = 0; i < len; i++)
f0105ab8:	39 fb                	cmp    %edi,%ebx
f0105aba:	0f 84 88 00 00 00    	je     f0105b48 <mp_init+0x145>
		sum += ((uint8_t *)addr)[i];
f0105ac0:	0f b6 0b             	movzbl (%ebx),%ecx
f0105ac3:	01 ca                	add    %ecx,%edx
f0105ac5:	83 c3 01             	add    $0x1,%ebx
f0105ac8:	eb ee                	jmp    f0105ab8 <mp_init+0xb5>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105aca:	68 00 04 00 00       	push   $0x400
f0105acf:	68 a4 63 10 f0       	push   $0xf01063a4
f0105ad4:	6a 6f                	push   $0x6f
f0105ad6:	68 21 7f 10 f0       	push   $0xf0107f21
f0105adb:	e8 60 a5 ff ff       	call   f0100040 <_panic>
		p = *(uint16_t *) (bda + 0x13) * 1024;
f0105ae0:	0f b7 05 13 04 00 f0 	movzwl 0xf0000413,%eax
f0105ae7:	c1 e0 0a             	shl    $0xa,%eax
		if ((mp = mpsearch1(p - 1024, 1024)))
f0105aea:	2d 00 04 00 00       	sub    $0x400,%eax
f0105aef:	ba 00 04 00 00       	mov    $0x400,%edx
f0105af4:	e8 6e fe ff ff       	call   f0105967 <mpsearch1>
f0105af9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105afc:	85 c0                	test   %eax,%eax
f0105afe:	0f 85 60 ff ff ff    	jne    f0105a64 <mp_init+0x61>
f0105b04:	e9 41 ff ff ff       	jmp    f0105a4a <mp_init+0x47>
		cprintf("SMP: Default configurations not implemented\n");
f0105b09:	83 ec 0c             	sub    $0xc,%esp
f0105b0c:	68 94 7d 10 f0       	push   $0xf0107d94
f0105b11:	e8 c8 dd ff ff       	call   f01038de <cprintf>
		return NULL;
f0105b16:	83 c4 10             	add    $0x10,%esp
f0105b19:	e9 7b 01 00 00       	jmp    f0105c99 <mp_init+0x296>
f0105b1e:	53                   	push   %ebx
f0105b1f:	68 a4 63 10 f0       	push   $0xf01063a4
f0105b24:	68 90 00 00 00       	push   $0x90
f0105b29:	68 21 7f 10 f0       	push   $0xf0107f21
f0105b2e:	e8 0d a5 ff ff       	call   f0100040 <_panic>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f0105b33:	83 ec 0c             	sub    $0xc,%esp
f0105b36:	68 c4 7d 10 f0       	push   $0xf0107dc4
f0105b3b:	e8 9e dd ff ff       	call   f01038de <cprintf>
		return NULL;
f0105b40:	83 c4 10             	add    $0x10,%esp
f0105b43:	e9 51 01 00 00       	jmp    f0105c99 <mp_init+0x296>
	if (sum(conf, conf->length) != 0) {
f0105b48:	84 d2                	test   %dl,%dl
f0105b4a:	75 22                	jne    f0105b6e <mp_init+0x16b>
	if (conf->version != 1 && conf->version != 4) {
f0105b4c:	0f b6 56 06          	movzbl 0x6(%esi),%edx
f0105b50:	80 fa 01             	cmp    $0x1,%dl
f0105b53:	74 05                	je     f0105b5a <mp_init+0x157>
f0105b55:	80 fa 04             	cmp    $0x4,%dl
f0105b58:	75 29                	jne    f0105b83 <mp_init+0x180>
f0105b5a:	0f b7 4e 28          	movzwl 0x28(%esi),%ecx
f0105b5e:	01 d9                	add    %ebx,%ecx
	for (i = 0; i < len; i++)
f0105b60:	39 d9                	cmp    %ebx,%ecx
f0105b62:	74 38                	je     f0105b9c <mp_init+0x199>
		sum += ((uint8_t *)addr)[i];
f0105b64:	0f b6 13             	movzbl (%ebx),%edx
f0105b67:	01 d0                	add    %edx,%eax
f0105b69:	83 c3 01             	add    $0x1,%ebx
f0105b6c:	eb f2                	jmp    f0105b60 <mp_init+0x15d>
		cprintf("SMP: Bad MP configuration checksum\n");
f0105b6e:	83 ec 0c             	sub    $0xc,%esp
f0105b71:	68 f8 7d 10 f0       	push   $0xf0107df8
f0105b76:	e8 63 dd ff ff       	call   f01038de <cprintf>
		return NULL;
f0105b7b:	83 c4 10             	add    $0x10,%esp
f0105b7e:	e9 16 01 00 00       	jmp    f0105c99 <mp_init+0x296>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f0105b83:	83 ec 08             	sub    $0x8,%esp
f0105b86:	0f b6 d2             	movzbl %dl,%edx
f0105b89:	52                   	push   %edx
f0105b8a:	68 1c 7e 10 f0       	push   $0xf0107e1c
f0105b8f:	e8 4a dd ff ff       	call   f01038de <cprintf>
		return NULL;
f0105b94:	83 c4 10             	add    $0x10,%esp
f0105b97:	e9 fd 00 00 00       	jmp    f0105c99 <mp_init+0x296>
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f0105b9c:	02 46 2a             	add    0x2a(%esi),%al
f0105b9f:	75 1c                	jne    f0105bbd <mp_init+0x1ba>
	if ((conf = mpconfig(&mp)) == 0)
		return;
	ismp = 1;
f0105ba1:	c7 05 00 70 23 f0 01 	movl   $0x1,0xf0237000
f0105ba8:	00 00 00 
	lapicaddr = conf->lapicaddr;
f0105bab:	8b 46 24             	mov    0x24(%esi),%eax
f0105bae:	a3 00 80 27 f0       	mov    %eax,0xf0278000

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0105bb3:	8d 7e 2c             	lea    0x2c(%esi),%edi
f0105bb6:	bb 00 00 00 00       	mov    $0x0,%ebx
f0105bbb:	eb 4d                	jmp    f0105c0a <mp_init+0x207>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f0105bbd:	83 ec 0c             	sub    $0xc,%esp
f0105bc0:	68 3c 7e 10 f0       	push   $0xf0107e3c
f0105bc5:	e8 14 dd ff ff       	call   f01038de <cprintf>
		return NULL;
f0105bca:	83 c4 10             	add    $0x10,%esp
f0105bcd:	e9 c7 00 00 00       	jmp    f0105c99 <mp_init+0x296>
		switch (*p) {
		case MPPROC:
			proc = (struct mpproc *)p;
			if (proc->flags & MPPROC_BOOT)
f0105bd2:	f6 47 03 02          	testb  $0x2,0x3(%edi)
f0105bd6:	74 11                	je     f0105be9 <mp_init+0x1e6>
				bootcpu = &cpus[ncpu];
f0105bd8:	6b 05 c4 73 23 f0 74 	imul   $0x74,0xf02373c4,%eax
f0105bdf:	05 20 70 23 f0       	add    $0xf0237020,%eax
f0105be4:	a3 c0 73 23 f0       	mov    %eax,0xf02373c0
			if (ncpu < NCPU) {
f0105be9:	a1 c4 73 23 f0       	mov    0xf02373c4,%eax
f0105bee:	83 f8 07             	cmp    $0x7,%eax
f0105bf1:	7f 33                	jg     f0105c26 <mp_init+0x223>
				cpus[ncpu].cpu_id = ncpu;
f0105bf3:	6b d0 74             	imul   $0x74,%eax,%edx
f0105bf6:	88 82 20 70 23 f0    	mov    %al,-0xfdc8fe0(%edx)
				ncpu++;
f0105bfc:	83 c0 01             	add    $0x1,%eax
f0105bff:	a3 c4 73 23 f0       	mov    %eax,0xf02373c4
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f0105c04:	83 c7 14             	add    $0x14,%edi
	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0105c07:	83 c3 01             	add    $0x1,%ebx
f0105c0a:	0f b7 46 22          	movzwl 0x22(%esi),%eax
f0105c0e:	39 d8                	cmp    %ebx,%eax
f0105c10:	76 4f                	jbe    f0105c61 <mp_init+0x25e>
		switch (*p) {
f0105c12:	0f b6 07             	movzbl (%edi),%eax
f0105c15:	84 c0                	test   %al,%al
f0105c17:	74 b9                	je     f0105bd2 <mp_init+0x1cf>
f0105c19:	8d 50 ff             	lea    -0x1(%eax),%edx
f0105c1c:	80 fa 03             	cmp    $0x3,%dl
f0105c1f:	77 1c                	ja     f0105c3d <mp_init+0x23a>
			continue;
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f0105c21:	83 c7 08             	add    $0x8,%edi
			continue;
f0105c24:	eb e1                	jmp    f0105c07 <mp_init+0x204>
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f0105c26:	83 ec 08             	sub    $0x8,%esp
f0105c29:	0f b6 47 01          	movzbl 0x1(%edi),%eax
f0105c2d:	50                   	push   %eax
f0105c2e:	68 6c 7e 10 f0       	push   $0xf0107e6c
f0105c33:	e8 a6 dc ff ff       	call   f01038de <cprintf>
f0105c38:	83 c4 10             	add    $0x10,%esp
f0105c3b:	eb c7                	jmp    f0105c04 <mp_init+0x201>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f0105c3d:	83 ec 08             	sub    $0x8,%esp
		switch (*p) {
f0105c40:	0f b6 c0             	movzbl %al,%eax
			cprintf("mpinit: unknown config type %x\n", *p);
f0105c43:	50                   	push   %eax
f0105c44:	68 94 7e 10 f0       	push   $0xf0107e94
f0105c49:	e8 90 dc ff ff       	call   f01038de <cprintf>
			ismp = 0;
f0105c4e:	c7 05 00 70 23 f0 00 	movl   $0x0,0xf0237000
f0105c55:	00 00 00 
			i = conf->entry;
f0105c58:	0f b7 5e 22          	movzwl 0x22(%esi),%ebx
f0105c5c:	83 c4 10             	add    $0x10,%esp
f0105c5f:	eb a6                	jmp    f0105c07 <mp_init+0x204>
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f0105c61:	a1 c0 73 23 f0       	mov    0xf02373c0,%eax
f0105c66:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f0105c6d:	83 3d 00 70 23 f0 00 	cmpl   $0x0,0xf0237000
f0105c74:	74 2b                	je     f0105ca1 <mp_init+0x29e>
		ncpu = 1;
		lapicaddr = 0;
		cprintf("SMP: configuration not found, SMP disabled\n");
		return;
	}
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f0105c76:	83 ec 04             	sub    $0x4,%esp
f0105c79:	ff 35 c4 73 23 f0    	pushl  0xf02373c4
f0105c7f:	0f b6 00             	movzbl (%eax),%eax
f0105c82:	50                   	push   %eax
f0105c83:	68 3b 7f 10 f0       	push   $0xf0107f3b
f0105c88:	e8 51 dc ff ff       	call   f01038de <cprintf>

	if (mp->imcrp) {
f0105c8d:	83 c4 10             	add    $0x10,%esp
f0105c90:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105c93:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f0105c97:	75 2e                	jne    f0105cc7 <mp_init+0x2c4>
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
	}
}
f0105c99:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105c9c:	5b                   	pop    %ebx
f0105c9d:	5e                   	pop    %esi
f0105c9e:	5f                   	pop    %edi
f0105c9f:	5d                   	pop    %ebp
f0105ca0:	c3                   	ret    
		ncpu = 1;
f0105ca1:	c7 05 c4 73 23 f0 01 	movl   $0x1,0xf02373c4
f0105ca8:	00 00 00 
		lapicaddr = 0;
f0105cab:	c7 05 00 80 27 f0 00 	movl   $0x0,0xf0278000
f0105cb2:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f0105cb5:	83 ec 0c             	sub    $0xc,%esp
f0105cb8:	68 b4 7e 10 f0       	push   $0xf0107eb4
f0105cbd:	e8 1c dc ff ff       	call   f01038de <cprintf>
		return;
f0105cc2:	83 c4 10             	add    $0x10,%esp
f0105cc5:	eb d2                	jmp    f0105c99 <mp_init+0x296>
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f0105cc7:	83 ec 0c             	sub    $0xc,%esp
f0105cca:	68 e0 7e 10 f0       	push   $0xf0107ee0
f0105ccf:	e8 0a dc ff ff       	call   f01038de <cprintf>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0105cd4:	b8 70 00 00 00       	mov    $0x70,%eax
f0105cd9:	ba 22 00 00 00       	mov    $0x22,%edx
f0105cde:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0105cdf:	ba 23 00 00 00       	mov    $0x23,%edx
f0105ce4:	ec                   	in     (%dx),%al
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
f0105ce5:	83 c8 01             	or     $0x1,%eax
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0105ce8:	ee                   	out    %al,(%dx)
}
f0105ce9:	83 c4 10             	add    $0x10,%esp
f0105cec:	eb ab                	jmp    f0105c99 <mp_init+0x296>

f0105cee <lapicw>:
volatile uint32_t *lapic;

static void
lapicw(int index, int value)
{
	lapic[index] = value;
f0105cee:	8b 0d 04 80 27 f0    	mov    0xf0278004,%ecx
f0105cf4:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f0105cf7:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f0105cf9:	a1 04 80 27 f0       	mov    0xf0278004,%eax
f0105cfe:	8b 40 20             	mov    0x20(%eax),%eax
}
f0105d01:	c3                   	ret    

f0105d02 <cpunum>:
	lapicw(TPR, 0);
}

int
cpunum(void)
{
f0105d02:	f3 0f 1e fb          	endbr32 
	if (lapic)
f0105d06:	8b 15 04 80 27 f0    	mov    0xf0278004,%edx
		return lapic[ID] >> 24;
	return 0;
f0105d0c:	b8 00 00 00 00       	mov    $0x0,%eax
	if (lapic)
f0105d11:	85 d2                	test   %edx,%edx
f0105d13:	74 06                	je     f0105d1b <cpunum+0x19>
		return lapic[ID] >> 24;
f0105d15:	8b 42 20             	mov    0x20(%edx),%eax
f0105d18:	c1 e8 18             	shr    $0x18,%eax
}
f0105d1b:	c3                   	ret    

f0105d1c <lapic_init>:
{
f0105d1c:	f3 0f 1e fb          	endbr32 
	if (!lapicaddr)
f0105d20:	a1 00 80 27 f0       	mov    0xf0278000,%eax
f0105d25:	85 c0                	test   %eax,%eax
f0105d27:	75 01                	jne    f0105d2a <lapic_init+0xe>
f0105d29:	c3                   	ret    
{
f0105d2a:	55                   	push   %ebp
f0105d2b:	89 e5                	mov    %esp,%ebp
f0105d2d:	83 ec 10             	sub    $0x10,%esp
	lapic = mmio_map_region(lapicaddr, 4096);
f0105d30:	68 00 10 00 00       	push   $0x1000
f0105d35:	50                   	push   %eax
f0105d36:	e8 11 b5 ff ff       	call   f010124c <mmio_map_region>
f0105d3b:	a3 04 80 27 f0       	mov    %eax,0xf0278004
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f0105d40:	ba 27 01 00 00       	mov    $0x127,%edx
f0105d45:	b8 3c 00 00 00       	mov    $0x3c,%eax
f0105d4a:	e8 9f ff ff ff       	call   f0105cee <lapicw>
	lapicw(TDCR, X1);
f0105d4f:	ba 0b 00 00 00       	mov    $0xb,%edx
f0105d54:	b8 f8 00 00 00       	mov    $0xf8,%eax
f0105d59:	e8 90 ff ff ff       	call   f0105cee <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f0105d5e:	ba 20 00 02 00       	mov    $0x20020,%edx
f0105d63:	b8 c8 00 00 00       	mov    $0xc8,%eax
f0105d68:	e8 81 ff ff ff       	call   f0105cee <lapicw>
	lapicw(TICR, 10000000); 
f0105d6d:	ba 80 96 98 00       	mov    $0x989680,%edx
f0105d72:	b8 e0 00 00 00       	mov    $0xe0,%eax
f0105d77:	e8 72 ff ff ff       	call   f0105cee <lapicw>
	if (thiscpu != bootcpu)
f0105d7c:	e8 81 ff ff ff       	call   f0105d02 <cpunum>
f0105d81:	6b c0 74             	imul   $0x74,%eax,%eax
f0105d84:	05 20 70 23 f0       	add    $0xf0237020,%eax
f0105d89:	83 c4 10             	add    $0x10,%esp
f0105d8c:	39 05 c0 73 23 f0    	cmp    %eax,0xf02373c0
f0105d92:	74 0f                	je     f0105da3 <lapic_init+0x87>
		lapicw(LINT0, MASKED);
f0105d94:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105d99:	b8 d4 00 00 00       	mov    $0xd4,%eax
f0105d9e:	e8 4b ff ff ff       	call   f0105cee <lapicw>
	lapicw(LINT1, MASKED);
f0105da3:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105da8:	b8 d8 00 00 00       	mov    $0xd8,%eax
f0105dad:	e8 3c ff ff ff       	call   f0105cee <lapicw>
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f0105db2:	a1 04 80 27 f0       	mov    0xf0278004,%eax
f0105db7:	8b 40 30             	mov    0x30(%eax),%eax
f0105dba:	c1 e8 10             	shr    $0x10,%eax
f0105dbd:	a8 fc                	test   $0xfc,%al
f0105dbf:	75 7c                	jne    f0105e3d <lapic_init+0x121>
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f0105dc1:	ba 33 00 00 00       	mov    $0x33,%edx
f0105dc6:	b8 dc 00 00 00       	mov    $0xdc,%eax
f0105dcb:	e8 1e ff ff ff       	call   f0105cee <lapicw>
	lapicw(ESR, 0);
f0105dd0:	ba 00 00 00 00       	mov    $0x0,%edx
f0105dd5:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0105dda:	e8 0f ff ff ff       	call   f0105cee <lapicw>
	lapicw(ESR, 0);
f0105ddf:	ba 00 00 00 00       	mov    $0x0,%edx
f0105de4:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0105de9:	e8 00 ff ff ff       	call   f0105cee <lapicw>
	lapicw(EOI, 0);
f0105dee:	ba 00 00 00 00       	mov    $0x0,%edx
f0105df3:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0105df8:	e8 f1 fe ff ff       	call   f0105cee <lapicw>
	lapicw(ICRHI, 0);
f0105dfd:	ba 00 00 00 00       	mov    $0x0,%edx
f0105e02:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105e07:	e8 e2 fe ff ff       	call   f0105cee <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f0105e0c:	ba 00 85 08 00       	mov    $0x88500,%edx
f0105e11:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105e16:	e8 d3 fe ff ff       	call   f0105cee <lapicw>
	while(lapic[ICRLO] & DELIVS)
f0105e1b:	8b 15 04 80 27 f0    	mov    0xf0278004,%edx
f0105e21:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0105e27:	f6 c4 10             	test   $0x10,%ah
f0105e2a:	75 f5                	jne    f0105e21 <lapic_init+0x105>
	lapicw(TPR, 0);
f0105e2c:	ba 00 00 00 00       	mov    $0x0,%edx
f0105e31:	b8 20 00 00 00       	mov    $0x20,%eax
f0105e36:	e8 b3 fe ff ff       	call   f0105cee <lapicw>
}
f0105e3b:	c9                   	leave  
f0105e3c:	c3                   	ret    
		lapicw(PCINT, MASKED);
f0105e3d:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105e42:	b8 d0 00 00 00       	mov    $0xd0,%eax
f0105e47:	e8 a2 fe ff ff       	call   f0105cee <lapicw>
f0105e4c:	e9 70 ff ff ff       	jmp    f0105dc1 <lapic_init+0xa5>

f0105e51 <lapic_eoi>:

// Acknowledge interrupt.
void
lapic_eoi(void)
{
f0105e51:	f3 0f 1e fb          	endbr32 
	if (lapic)
f0105e55:	83 3d 04 80 27 f0 00 	cmpl   $0x0,0xf0278004
f0105e5c:	74 17                	je     f0105e75 <lapic_eoi+0x24>
{
f0105e5e:	55                   	push   %ebp
f0105e5f:	89 e5                	mov    %esp,%ebp
f0105e61:	83 ec 08             	sub    $0x8,%esp
		lapicw(EOI, 0);
f0105e64:	ba 00 00 00 00       	mov    $0x0,%edx
f0105e69:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0105e6e:	e8 7b fe ff ff       	call   f0105cee <lapicw>
}
f0105e73:	c9                   	leave  
f0105e74:	c3                   	ret    
f0105e75:	c3                   	ret    

f0105e76 <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f0105e76:	f3 0f 1e fb          	endbr32 
f0105e7a:	55                   	push   %ebp
f0105e7b:	89 e5                	mov    %esp,%ebp
f0105e7d:	56                   	push   %esi
f0105e7e:	53                   	push   %ebx
f0105e7f:	8b 75 08             	mov    0x8(%ebp),%esi
f0105e82:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0105e85:	b8 0f 00 00 00       	mov    $0xf,%eax
f0105e8a:	ba 70 00 00 00       	mov    $0x70,%edx
f0105e8f:	ee                   	out    %al,(%dx)
f0105e90:	b8 0a 00 00 00       	mov    $0xa,%eax
f0105e95:	ba 71 00 00 00       	mov    $0x71,%edx
f0105e9a:	ee                   	out    %al,(%dx)
	if (PGNUM(pa) >= npages)
f0105e9b:	83 3d 88 6e 23 f0 00 	cmpl   $0x0,0xf0236e88
f0105ea2:	74 7e                	je     f0105f22 <lapic_startap+0xac>
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
	wrv[0] = 0;
f0105ea4:	66 c7 05 67 04 00 f0 	movw   $0x0,0xf0000467
f0105eab:	00 00 
	wrv[1] = addr >> 4;
f0105ead:	89 d8                	mov    %ebx,%eax
f0105eaf:	c1 e8 04             	shr    $0x4,%eax
f0105eb2:	66 a3 69 04 00 f0    	mov    %ax,0xf0000469

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f0105eb8:	c1 e6 18             	shl    $0x18,%esi
f0105ebb:	89 f2                	mov    %esi,%edx
f0105ebd:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105ec2:	e8 27 fe ff ff       	call   f0105cee <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f0105ec7:	ba 00 c5 00 00       	mov    $0xc500,%edx
f0105ecc:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105ed1:	e8 18 fe ff ff       	call   f0105cee <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f0105ed6:	ba 00 85 00 00       	mov    $0x8500,%edx
f0105edb:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105ee0:	e8 09 fe ff ff       	call   f0105cee <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105ee5:	c1 eb 0c             	shr    $0xc,%ebx
f0105ee8:	80 cf 06             	or     $0x6,%bh
		lapicw(ICRHI, apicid << 24);
f0105eeb:	89 f2                	mov    %esi,%edx
f0105eed:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105ef2:	e8 f7 fd ff ff       	call   f0105cee <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105ef7:	89 da                	mov    %ebx,%edx
f0105ef9:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105efe:	e8 eb fd ff ff       	call   f0105cee <lapicw>
		lapicw(ICRHI, apicid << 24);
f0105f03:	89 f2                	mov    %esi,%edx
f0105f05:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105f0a:	e8 df fd ff ff       	call   f0105cee <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105f0f:	89 da                	mov    %ebx,%edx
f0105f11:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105f16:	e8 d3 fd ff ff       	call   f0105cee <lapicw>
		microdelay(200);
	}
}
f0105f1b:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0105f1e:	5b                   	pop    %ebx
f0105f1f:	5e                   	pop    %esi
f0105f20:	5d                   	pop    %ebp
f0105f21:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105f22:	68 67 04 00 00       	push   $0x467
f0105f27:	68 a4 63 10 f0       	push   $0xf01063a4
f0105f2c:	68 98 00 00 00       	push   $0x98
f0105f31:	68 58 7f 10 f0       	push   $0xf0107f58
f0105f36:	e8 05 a1 ff ff       	call   f0100040 <_panic>

f0105f3b <lapic_ipi>:

void
lapic_ipi(int vector)
{
f0105f3b:	f3 0f 1e fb          	endbr32 
f0105f3f:	55                   	push   %ebp
f0105f40:	89 e5                	mov    %esp,%ebp
f0105f42:	83 ec 08             	sub    $0x8,%esp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f0105f45:	8b 55 08             	mov    0x8(%ebp),%edx
f0105f48:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f0105f4e:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105f53:	e8 96 fd ff ff       	call   f0105cee <lapicw>
	while (lapic[ICRLO] & DELIVS)
f0105f58:	8b 15 04 80 27 f0    	mov    0xf0278004,%edx
f0105f5e:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0105f64:	f6 c4 10             	test   $0x10,%ah
f0105f67:	75 f5                	jne    f0105f5e <lapic_ipi+0x23>
		;
}
f0105f69:	c9                   	leave  
f0105f6a:	c3                   	ret    

f0105f6b <__spin_initlock>:
}
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f0105f6b:	f3 0f 1e fb          	endbr32 
f0105f6f:	55                   	push   %ebp
f0105f70:	89 e5                	mov    %esp,%ebp
f0105f72:	8b 45 08             	mov    0x8(%ebp),%eax
	lk->locked = 0;
f0105f75:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
	lk->name = name;
f0105f7b:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105f7e:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f0105f81:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f0105f88:	5d                   	pop    %ebp
f0105f89:	c3                   	ret    

f0105f8a <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f0105f8a:	f3 0f 1e fb          	endbr32 
f0105f8e:	55                   	push   %ebp
f0105f8f:	89 e5                	mov    %esp,%ebp
f0105f91:	56                   	push   %esi
f0105f92:	53                   	push   %ebx
f0105f93:	8b 5d 08             	mov    0x8(%ebp),%ebx
	return lock->locked && lock->cpu == thiscpu;
f0105f96:	83 3b 00             	cmpl   $0x0,(%ebx)
f0105f99:	75 07                	jne    f0105fa2 <spin_lock+0x18>
	asm volatile("lock; xchgl %0, %1"
f0105f9b:	ba 01 00 00 00       	mov    $0x1,%edx
f0105fa0:	eb 34                	jmp    f0105fd6 <spin_lock+0x4c>
f0105fa2:	8b 73 08             	mov    0x8(%ebx),%esi
f0105fa5:	e8 58 fd ff ff       	call   f0105d02 <cpunum>
f0105faa:	6b c0 74             	imul   $0x74,%eax,%eax
f0105fad:	05 20 70 23 f0       	add    $0xf0237020,%eax
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
f0105fb2:	39 c6                	cmp    %eax,%esi
f0105fb4:	75 e5                	jne    f0105f9b <spin_lock+0x11>
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f0105fb6:	8b 5b 04             	mov    0x4(%ebx),%ebx
f0105fb9:	e8 44 fd ff ff       	call   f0105d02 <cpunum>
f0105fbe:	83 ec 0c             	sub    $0xc,%esp
f0105fc1:	53                   	push   %ebx
f0105fc2:	50                   	push   %eax
f0105fc3:	68 68 7f 10 f0       	push   $0xf0107f68
f0105fc8:	6a 41                	push   $0x41
f0105fca:	68 ca 7f 10 f0       	push   $0xf0107fca
f0105fcf:	e8 6c a0 ff ff       	call   f0100040 <_panic>

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
		asm volatile ("pause");
f0105fd4:	f3 90                	pause  
f0105fd6:	89 d0                	mov    %edx,%eax
f0105fd8:	f0 87 03             	lock xchg %eax,(%ebx)
	while (xchg(&lk->locked, 1) != 0)
f0105fdb:	85 c0                	test   %eax,%eax
f0105fdd:	75 f5                	jne    f0105fd4 <spin_lock+0x4a>

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f0105fdf:	e8 1e fd ff ff       	call   f0105d02 <cpunum>
f0105fe4:	6b c0 74             	imul   $0x74,%eax,%eax
f0105fe7:	05 20 70 23 f0       	add    $0xf0237020,%eax
f0105fec:	89 43 08             	mov    %eax,0x8(%ebx)
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f0105fef:	89 ea                	mov    %ebp,%edx
	for (i = 0; i < 10; i++){
f0105ff1:	b8 00 00 00 00       	mov    $0x0,%eax
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
f0105ff6:	83 f8 09             	cmp    $0x9,%eax
f0105ff9:	7f 21                	jg     f010601c <spin_lock+0x92>
f0105ffb:	81 fa ff ff 7f ef    	cmp    $0xef7fffff,%edx
f0106001:	76 19                	jbe    f010601c <spin_lock+0x92>
		pcs[i] = ebp[1];          // saved %eip
f0106003:	8b 4a 04             	mov    0x4(%edx),%ecx
f0106006:	89 4c 83 0c          	mov    %ecx,0xc(%ebx,%eax,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f010600a:	8b 12                	mov    (%edx),%edx
	for (i = 0; i < 10; i++){
f010600c:	83 c0 01             	add    $0x1,%eax
f010600f:	eb e5                	jmp    f0105ff6 <spin_lock+0x6c>
		pcs[i] = 0;
f0106011:	c7 44 83 0c 00 00 00 	movl   $0x0,0xc(%ebx,%eax,4)
f0106018:	00 
	for (; i < 10; i++)
f0106019:	83 c0 01             	add    $0x1,%eax
f010601c:	83 f8 09             	cmp    $0x9,%eax
f010601f:	7e f0                	jle    f0106011 <spin_lock+0x87>
	get_caller_pcs(lk->pcs);
#endif
}
f0106021:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0106024:	5b                   	pop    %ebx
f0106025:	5e                   	pop    %esi
f0106026:	5d                   	pop    %ebp
f0106027:	c3                   	ret    

f0106028 <spin_unlock>:

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f0106028:	f3 0f 1e fb          	endbr32 
f010602c:	55                   	push   %ebp
f010602d:	89 e5                	mov    %esp,%ebp
f010602f:	57                   	push   %edi
f0106030:	56                   	push   %esi
f0106031:	53                   	push   %ebx
f0106032:	83 ec 4c             	sub    $0x4c,%esp
f0106035:	8b 75 08             	mov    0x8(%ebp),%esi
	return lock->locked && lock->cpu == thiscpu;
f0106038:	83 3e 00             	cmpl   $0x0,(%esi)
f010603b:	75 35                	jne    f0106072 <spin_unlock+0x4a>
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f010603d:	83 ec 04             	sub    $0x4,%esp
f0106040:	6a 28                	push   $0x28
f0106042:	8d 46 0c             	lea    0xc(%esi),%eax
f0106045:	50                   	push   %eax
f0106046:	8d 5d c0             	lea    -0x40(%ebp),%ebx
f0106049:	53                   	push   %ebx
f010604a:	e8 e1 f6 ff ff       	call   f0105730 <memmove>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
f010604f:	8b 46 08             	mov    0x8(%esi),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f0106052:	0f b6 38             	movzbl (%eax),%edi
f0106055:	8b 76 04             	mov    0x4(%esi),%esi
f0106058:	e8 a5 fc ff ff       	call   f0105d02 <cpunum>
f010605d:	57                   	push   %edi
f010605e:	56                   	push   %esi
f010605f:	50                   	push   %eax
f0106060:	68 94 7f 10 f0       	push   $0xf0107f94
f0106065:	e8 74 d8 ff ff       	call   f01038de <cprintf>
f010606a:	83 c4 20             	add    $0x20,%esp
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f010606d:	8d 7d a8             	lea    -0x58(%ebp),%edi
f0106070:	eb 4e                	jmp    f01060c0 <spin_unlock+0x98>
	return lock->locked && lock->cpu == thiscpu;
f0106072:	8b 5e 08             	mov    0x8(%esi),%ebx
f0106075:	e8 88 fc ff ff       	call   f0105d02 <cpunum>
f010607a:	6b c0 74             	imul   $0x74,%eax,%eax
f010607d:	05 20 70 23 f0       	add    $0xf0237020,%eax
	if (!holding(lk)) {
f0106082:	39 c3                	cmp    %eax,%ebx
f0106084:	75 b7                	jne    f010603d <spin_unlock+0x15>
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
	}

	lk->pcs[0] = 0;
f0106086:	c7 46 0c 00 00 00 00 	movl   $0x0,0xc(%esi)
	lk->cpu = 0;
f010608d:	c7 46 08 00 00 00 00 	movl   $0x0,0x8(%esi)
	asm volatile("lock; xchgl %0, %1"
f0106094:	b8 00 00 00 00       	mov    $0x0,%eax
f0106099:	f0 87 06             	lock xchg %eax,(%esi)
	// respect to any other instruction which references the same memory.
	// x86 CPUs will not reorder loads/stores across locked instructions
	// (vol 3, 8.2.2). Because xchg() is implemented using asm volatile,
	// gcc will not reorder C statements across the xchg.
	xchg(&lk->locked, 0);
}
f010609c:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010609f:	5b                   	pop    %ebx
f01060a0:	5e                   	pop    %esi
f01060a1:	5f                   	pop    %edi
f01060a2:	5d                   	pop    %ebp
f01060a3:	c3                   	ret    
				cprintf("  %08x\n", pcs[i]);
f01060a4:	83 ec 08             	sub    $0x8,%esp
f01060a7:	ff 36                	pushl  (%esi)
f01060a9:	68 f1 7f 10 f0       	push   $0xf0107ff1
f01060ae:	e8 2b d8 ff ff       	call   f01038de <cprintf>
f01060b3:	83 c4 10             	add    $0x10,%esp
f01060b6:	83 c3 04             	add    $0x4,%ebx
		for (i = 0; i < 10 && pcs[i]; i++) {
f01060b9:	8d 45 e8             	lea    -0x18(%ebp),%eax
f01060bc:	39 c3                	cmp    %eax,%ebx
f01060be:	74 40                	je     f0106100 <spin_unlock+0xd8>
f01060c0:	89 de                	mov    %ebx,%esi
f01060c2:	8b 03                	mov    (%ebx),%eax
f01060c4:	85 c0                	test   %eax,%eax
f01060c6:	74 38                	je     f0106100 <spin_unlock+0xd8>
			if (debuginfo_eip(pcs[i], &info) >= 0)
f01060c8:	83 ec 08             	sub    $0x8,%esp
f01060cb:	57                   	push   %edi
f01060cc:	50                   	push   %eax
f01060cd:	e8 b1 eb ff ff       	call   f0104c83 <debuginfo_eip>
f01060d2:	83 c4 10             	add    $0x10,%esp
f01060d5:	85 c0                	test   %eax,%eax
f01060d7:	78 cb                	js     f01060a4 <spin_unlock+0x7c>
					pcs[i] - info.eip_fn_addr);
f01060d9:	8b 06                	mov    (%esi),%eax
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f01060db:	83 ec 04             	sub    $0x4,%esp
f01060de:	89 c2                	mov    %eax,%edx
f01060e0:	2b 55 b8             	sub    -0x48(%ebp),%edx
f01060e3:	52                   	push   %edx
f01060e4:	ff 75 b0             	pushl  -0x50(%ebp)
f01060e7:	ff 75 b4             	pushl  -0x4c(%ebp)
f01060ea:	ff 75 ac             	pushl  -0x54(%ebp)
f01060ed:	ff 75 a8             	pushl  -0x58(%ebp)
f01060f0:	50                   	push   %eax
f01060f1:	68 da 7f 10 f0       	push   $0xf0107fda
f01060f6:	e8 e3 d7 ff ff       	call   f01038de <cprintf>
f01060fb:	83 c4 20             	add    $0x20,%esp
f01060fe:	eb b6                	jmp    f01060b6 <spin_unlock+0x8e>
		panic("spin_unlock");
f0106100:	83 ec 04             	sub    $0x4,%esp
f0106103:	68 f9 7f 10 f0       	push   $0xf0107ff9
f0106108:	6a 67                	push   $0x67
f010610a:	68 ca 7f 10 f0       	push   $0xf0107fca
f010610f:	e8 2c 9f ff ff       	call   f0100040 <_panic>
f0106114:	66 90                	xchg   %ax,%ax
f0106116:	66 90                	xchg   %ax,%ax
f0106118:	66 90                	xchg   %ax,%ax
f010611a:	66 90                	xchg   %ax,%ax
f010611c:	66 90                	xchg   %ax,%ax
f010611e:	66 90                	xchg   %ax,%ax

f0106120 <__udivdi3>:
f0106120:	f3 0f 1e fb          	endbr32 
f0106124:	55                   	push   %ebp
f0106125:	57                   	push   %edi
f0106126:	56                   	push   %esi
f0106127:	53                   	push   %ebx
f0106128:	83 ec 1c             	sub    $0x1c,%esp
f010612b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f010612f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
f0106133:	8b 74 24 34          	mov    0x34(%esp),%esi
f0106137:	8b 5c 24 38          	mov    0x38(%esp),%ebx
f010613b:	85 d2                	test   %edx,%edx
f010613d:	75 19                	jne    f0106158 <__udivdi3+0x38>
f010613f:	39 f3                	cmp    %esi,%ebx
f0106141:	76 4d                	jbe    f0106190 <__udivdi3+0x70>
f0106143:	31 ff                	xor    %edi,%edi
f0106145:	89 e8                	mov    %ebp,%eax
f0106147:	89 f2                	mov    %esi,%edx
f0106149:	f7 f3                	div    %ebx
f010614b:	89 fa                	mov    %edi,%edx
f010614d:	83 c4 1c             	add    $0x1c,%esp
f0106150:	5b                   	pop    %ebx
f0106151:	5e                   	pop    %esi
f0106152:	5f                   	pop    %edi
f0106153:	5d                   	pop    %ebp
f0106154:	c3                   	ret    
f0106155:	8d 76 00             	lea    0x0(%esi),%esi
f0106158:	39 f2                	cmp    %esi,%edx
f010615a:	76 14                	jbe    f0106170 <__udivdi3+0x50>
f010615c:	31 ff                	xor    %edi,%edi
f010615e:	31 c0                	xor    %eax,%eax
f0106160:	89 fa                	mov    %edi,%edx
f0106162:	83 c4 1c             	add    $0x1c,%esp
f0106165:	5b                   	pop    %ebx
f0106166:	5e                   	pop    %esi
f0106167:	5f                   	pop    %edi
f0106168:	5d                   	pop    %ebp
f0106169:	c3                   	ret    
f010616a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0106170:	0f bd fa             	bsr    %edx,%edi
f0106173:	83 f7 1f             	xor    $0x1f,%edi
f0106176:	75 48                	jne    f01061c0 <__udivdi3+0xa0>
f0106178:	39 f2                	cmp    %esi,%edx
f010617a:	72 06                	jb     f0106182 <__udivdi3+0x62>
f010617c:	31 c0                	xor    %eax,%eax
f010617e:	39 eb                	cmp    %ebp,%ebx
f0106180:	77 de                	ja     f0106160 <__udivdi3+0x40>
f0106182:	b8 01 00 00 00       	mov    $0x1,%eax
f0106187:	eb d7                	jmp    f0106160 <__udivdi3+0x40>
f0106189:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0106190:	89 d9                	mov    %ebx,%ecx
f0106192:	85 db                	test   %ebx,%ebx
f0106194:	75 0b                	jne    f01061a1 <__udivdi3+0x81>
f0106196:	b8 01 00 00 00       	mov    $0x1,%eax
f010619b:	31 d2                	xor    %edx,%edx
f010619d:	f7 f3                	div    %ebx
f010619f:	89 c1                	mov    %eax,%ecx
f01061a1:	31 d2                	xor    %edx,%edx
f01061a3:	89 f0                	mov    %esi,%eax
f01061a5:	f7 f1                	div    %ecx
f01061a7:	89 c6                	mov    %eax,%esi
f01061a9:	89 e8                	mov    %ebp,%eax
f01061ab:	89 f7                	mov    %esi,%edi
f01061ad:	f7 f1                	div    %ecx
f01061af:	89 fa                	mov    %edi,%edx
f01061b1:	83 c4 1c             	add    $0x1c,%esp
f01061b4:	5b                   	pop    %ebx
f01061b5:	5e                   	pop    %esi
f01061b6:	5f                   	pop    %edi
f01061b7:	5d                   	pop    %ebp
f01061b8:	c3                   	ret    
f01061b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01061c0:	89 f9                	mov    %edi,%ecx
f01061c2:	b8 20 00 00 00       	mov    $0x20,%eax
f01061c7:	29 f8                	sub    %edi,%eax
f01061c9:	d3 e2                	shl    %cl,%edx
f01061cb:	89 54 24 08          	mov    %edx,0x8(%esp)
f01061cf:	89 c1                	mov    %eax,%ecx
f01061d1:	89 da                	mov    %ebx,%edx
f01061d3:	d3 ea                	shr    %cl,%edx
f01061d5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f01061d9:	09 d1                	or     %edx,%ecx
f01061db:	89 f2                	mov    %esi,%edx
f01061dd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01061e1:	89 f9                	mov    %edi,%ecx
f01061e3:	d3 e3                	shl    %cl,%ebx
f01061e5:	89 c1                	mov    %eax,%ecx
f01061e7:	d3 ea                	shr    %cl,%edx
f01061e9:	89 f9                	mov    %edi,%ecx
f01061eb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f01061ef:	89 eb                	mov    %ebp,%ebx
f01061f1:	d3 e6                	shl    %cl,%esi
f01061f3:	89 c1                	mov    %eax,%ecx
f01061f5:	d3 eb                	shr    %cl,%ebx
f01061f7:	09 de                	or     %ebx,%esi
f01061f9:	89 f0                	mov    %esi,%eax
f01061fb:	f7 74 24 08          	divl   0x8(%esp)
f01061ff:	89 d6                	mov    %edx,%esi
f0106201:	89 c3                	mov    %eax,%ebx
f0106203:	f7 64 24 0c          	mull   0xc(%esp)
f0106207:	39 d6                	cmp    %edx,%esi
f0106209:	72 15                	jb     f0106220 <__udivdi3+0x100>
f010620b:	89 f9                	mov    %edi,%ecx
f010620d:	d3 e5                	shl    %cl,%ebp
f010620f:	39 c5                	cmp    %eax,%ebp
f0106211:	73 04                	jae    f0106217 <__udivdi3+0xf7>
f0106213:	39 d6                	cmp    %edx,%esi
f0106215:	74 09                	je     f0106220 <__udivdi3+0x100>
f0106217:	89 d8                	mov    %ebx,%eax
f0106219:	31 ff                	xor    %edi,%edi
f010621b:	e9 40 ff ff ff       	jmp    f0106160 <__udivdi3+0x40>
f0106220:	8d 43 ff             	lea    -0x1(%ebx),%eax
f0106223:	31 ff                	xor    %edi,%edi
f0106225:	e9 36 ff ff ff       	jmp    f0106160 <__udivdi3+0x40>
f010622a:	66 90                	xchg   %ax,%ax
f010622c:	66 90                	xchg   %ax,%ax
f010622e:	66 90                	xchg   %ax,%ax

f0106230 <__umoddi3>:
f0106230:	f3 0f 1e fb          	endbr32 
f0106234:	55                   	push   %ebp
f0106235:	57                   	push   %edi
f0106236:	56                   	push   %esi
f0106237:	53                   	push   %ebx
f0106238:	83 ec 1c             	sub    $0x1c,%esp
f010623b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
f010623f:	8b 74 24 30          	mov    0x30(%esp),%esi
f0106243:	8b 5c 24 34          	mov    0x34(%esp),%ebx
f0106247:	8b 7c 24 38          	mov    0x38(%esp),%edi
f010624b:	85 c0                	test   %eax,%eax
f010624d:	75 19                	jne    f0106268 <__umoddi3+0x38>
f010624f:	39 df                	cmp    %ebx,%edi
f0106251:	76 5d                	jbe    f01062b0 <__umoddi3+0x80>
f0106253:	89 f0                	mov    %esi,%eax
f0106255:	89 da                	mov    %ebx,%edx
f0106257:	f7 f7                	div    %edi
f0106259:	89 d0                	mov    %edx,%eax
f010625b:	31 d2                	xor    %edx,%edx
f010625d:	83 c4 1c             	add    $0x1c,%esp
f0106260:	5b                   	pop    %ebx
f0106261:	5e                   	pop    %esi
f0106262:	5f                   	pop    %edi
f0106263:	5d                   	pop    %ebp
f0106264:	c3                   	ret    
f0106265:	8d 76 00             	lea    0x0(%esi),%esi
f0106268:	89 f2                	mov    %esi,%edx
f010626a:	39 d8                	cmp    %ebx,%eax
f010626c:	76 12                	jbe    f0106280 <__umoddi3+0x50>
f010626e:	89 f0                	mov    %esi,%eax
f0106270:	89 da                	mov    %ebx,%edx
f0106272:	83 c4 1c             	add    $0x1c,%esp
f0106275:	5b                   	pop    %ebx
f0106276:	5e                   	pop    %esi
f0106277:	5f                   	pop    %edi
f0106278:	5d                   	pop    %ebp
f0106279:	c3                   	ret    
f010627a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0106280:	0f bd e8             	bsr    %eax,%ebp
f0106283:	83 f5 1f             	xor    $0x1f,%ebp
f0106286:	75 50                	jne    f01062d8 <__umoddi3+0xa8>
f0106288:	39 d8                	cmp    %ebx,%eax
f010628a:	0f 82 e0 00 00 00    	jb     f0106370 <__umoddi3+0x140>
f0106290:	89 d9                	mov    %ebx,%ecx
f0106292:	39 f7                	cmp    %esi,%edi
f0106294:	0f 86 d6 00 00 00    	jbe    f0106370 <__umoddi3+0x140>
f010629a:	89 d0                	mov    %edx,%eax
f010629c:	89 ca                	mov    %ecx,%edx
f010629e:	83 c4 1c             	add    $0x1c,%esp
f01062a1:	5b                   	pop    %ebx
f01062a2:	5e                   	pop    %esi
f01062a3:	5f                   	pop    %edi
f01062a4:	5d                   	pop    %ebp
f01062a5:	c3                   	ret    
f01062a6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01062ad:	8d 76 00             	lea    0x0(%esi),%esi
f01062b0:	89 fd                	mov    %edi,%ebp
f01062b2:	85 ff                	test   %edi,%edi
f01062b4:	75 0b                	jne    f01062c1 <__umoddi3+0x91>
f01062b6:	b8 01 00 00 00       	mov    $0x1,%eax
f01062bb:	31 d2                	xor    %edx,%edx
f01062bd:	f7 f7                	div    %edi
f01062bf:	89 c5                	mov    %eax,%ebp
f01062c1:	89 d8                	mov    %ebx,%eax
f01062c3:	31 d2                	xor    %edx,%edx
f01062c5:	f7 f5                	div    %ebp
f01062c7:	89 f0                	mov    %esi,%eax
f01062c9:	f7 f5                	div    %ebp
f01062cb:	89 d0                	mov    %edx,%eax
f01062cd:	31 d2                	xor    %edx,%edx
f01062cf:	eb 8c                	jmp    f010625d <__umoddi3+0x2d>
f01062d1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01062d8:	89 e9                	mov    %ebp,%ecx
f01062da:	ba 20 00 00 00       	mov    $0x20,%edx
f01062df:	29 ea                	sub    %ebp,%edx
f01062e1:	d3 e0                	shl    %cl,%eax
f01062e3:	89 44 24 08          	mov    %eax,0x8(%esp)
f01062e7:	89 d1                	mov    %edx,%ecx
f01062e9:	89 f8                	mov    %edi,%eax
f01062eb:	d3 e8                	shr    %cl,%eax
f01062ed:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f01062f1:	89 54 24 04          	mov    %edx,0x4(%esp)
f01062f5:	8b 54 24 04          	mov    0x4(%esp),%edx
f01062f9:	09 c1                	or     %eax,%ecx
f01062fb:	89 d8                	mov    %ebx,%eax
f01062fd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0106301:	89 e9                	mov    %ebp,%ecx
f0106303:	d3 e7                	shl    %cl,%edi
f0106305:	89 d1                	mov    %edx,%ecx
f0106307:	d3 e8                	shr    %cl,%eax
f0106309:	89 e9                	mov    %ebp,%ecx
f010630b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f010630f:	d3 e3                	shl    %cl,%ebx
f0106311:	89 c7                	mov    %eax,%edi
f0106313:	89 d1                	mov    %edx,%ecx
f0106315:	89 f0                	mov    %esi,%eax
f0106317:	d3 e8                	shr    %cl,%eax
f0106319:	89 e9                	mov    %ebp,%ecx
f010631b:	89 fa                	mov    %edi,%edx
f010631d:	d3 e6                	shl    %cl,%esi
f010631f:	09 d8                	or     %ebx,%eax
f0106321:	f7 74 24 08          	divl   0x8(%esp)
f0106325:	89 d1                	mov    %edx,%ecx
f0106327:	89 f3                	mov    %esi,%ebx
f0106329:	f7 64 24 0c          	mull   0xc(%esp)
f010632d:	89 c6                	mov    %eax,%esi
f010632f:	89 d7                	mov    %edx,%edi
f0106331:	39 d1                	cmp    %edx,%ecx
f0106333:	72 06                	jb     f010633b <__umoddi3+0x10b>
f0106335:	75 10                	jne    f0106347 <__umoddi3+0x117>
f0106337:	39 c3                	cmp    %eax,%ebx
f0106339:	73 0c                	jae    f0106347 <__umoddi3+0x117>
f010633b:	2b 44 24 0c          	sub    0xc(%esp),%eax
f010633f:	1b 54 24 08          	sbb    0x8(%esp),%edx
f0106343:	89 d7                	mov    %edx,%edi
f0106345:	89 c6                	mov    %eax,%esi
f0106347:	89 ca                	mov    %ecx,%edx
f0106349:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f010634e:	29 f3                	sub    %esi,%ebx
f0106350:	19 fa                	sbb    %edi,%edx
f0106352:	89 d0                	mov    %edx,%eax
f0106354:	d3 e0                	shl    %cl,%eax
f0106356:	89 e9                	mov    %ebp,%ecx
f0106358:	d3 eb                	shr    %cl,%ebx
f010635a:	d3 ea                	shr    %cl,%edx
f010635c:	09 d8                	or     %ebx,%eax
f010635e:	83 c4 1c             	add    $0x1c,%esp
f0106361:	5b                   	pop    %ebx
f0106362:	5e                   	pop    %esi
f0106363:	5f                   	pop    %edi
f0106364:	5d                   	pop    %ebp
f0106365:	c3                   	ret    
f0106366:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f010636d:	8d 76 00             	lea    0x0(%esi),%esi
f0106370:	29 fe                	sub    %edi,%esi
f0106372:	19 c3                	sbb    %eax,%ebx
f0106374:	89 f2                	mov    %esi,%edx
f0106376:	89 d9                	mov    %ebx,%ecx
f0106378:	e9 1d ff ff ff       	jmp    f010629a <__umoddi3+0x6a>
