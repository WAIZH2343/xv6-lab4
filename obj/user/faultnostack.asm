
obj/user/faultnostack:     file format elf32-i386


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
  80002c:	e8 27 00 00 00       	call   800058 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

void _pgfault_upcall();

void
umain(int argc, char **argv)
{
  800033:	f3 0f 1e fb          	endbr32 
  800037:	55                   	push   %ebp
  800038:	89 e5                	mov    %esp,%ebp
  80003a:	83 ec 10             	sub    $0x10,%esp
	sys_env_set_pgfault_upcall(0, (void*) _pgfault_upcall);
  80003d:	68 53 03 80 00       	push   $0x800353
  800042:	6a 00                	push   $0x0
  800044:	e8 58 02 00 00       	call   8002a1 <sys_env_set_pgfault_upcall>
	*(int*)0 = 0;
  800049:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  800050:	00 00 00 
}
  800053:	83 c4 10             	add    $0x10,%esp
  800056:	c9                   	leave  
  800057:	c3                   	ret    

00800058 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800058:	f3 0f 1e fb          	endbr32 
  80005c:	55                   	push   %ebp
  80005d:	89 e5                	mov    %esp,%ebp
  80005f:	56                   	push   %esi
  800060:	53                   	push   %ebx
  800061:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800064:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv=&envs[ENVX(sys_getenvid())];
  800067:	e8 d6 00 00 00       	call   800142 <sys_getenvid>
  80006c:	25 ff 03 00 00       	and    $0x3ff,%eax
  800071:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800074:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800079:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80007e:	85 db                	test   %ebx,%ebx
  800080:	7e 07                	jle    800089 <libmain+0x31>
		binaryname = argv[0];
  800082:	8b 06                	mov    (%esi),%eax
  800084:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800089:	83 ec 08             	sub    $0x8,%esp
  80008c:	56                   	push   %esi
  80008d:	53                   	push   %ebx
  80008e:	e8 a0 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800093:	e8 0a 00 00 00       	call   8000a2 <exit>
}
  800098:	83 c4 10             	add    $0x10,%esp
  80009b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80009e:	5b                   	pop    %ebx
  80009f:	5e                   	pop    %esi
  8000a0:	5d                   	pop    %ebp
  8000a1:	c3                   	ret    

008000a2 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a2:	f3 0f 1e fb          	endbr32 
  8000a6:	55                   	push   %ebp
  8000a7:	89 e5                	mov    %esp,%ebp
  8000a9:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000ac:	6a 00                	push   $0x0
  8000ae:	e8 4a 00 00 00       	call   8000fd <sys_env_destroy>
}
  8000b3:	83 c4 10             	add    $0x10,%esp
  8000b6:	c9                   	leave  
  8000b7:	c3                   	ret    

008000b8 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000b8:	f3 0f 1e fb          	endbr32 
  8000bc:	55                   	push   %ebp
  8000bd:	89 e5                	mov    %esp,%ebp
  8000bf:	57                   	push   %edi
  8000c0:	56                   	push   %esi
  8000c1:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000c2:	b8 00 00 00 00       	mov    $0x0,%eax
  8000c7:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000cd:	89 c3                	mov    %eax,%ebx
  8000cf:	89 c7                	mov    %eax,%edi
  8000d1:	89 c6                	mov    %eax,%esi
  8000d3:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000d5:	5b                   	pop    %ebx
  8000d6:	5e                   	pop    %esi
  8000d7:	5f                   	pop    %edi
  8000d8:	5d                   	pop    %ebp
  8000d9:	c3                   	ret    

008000da <sys_cgetc>:

int
sys_cgetc(void)
{
  8000da:	f3 0f 1e fb          	endbr32 
  8000de:	55                   	push   %ebp
  8000df:	89 e5                	mov    %esp,%ebp
  8000e1:	57                   	push   %edi
  8000e2:	56                   	push   %esi
  8000e3:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000e4:	ba 00 00 00 00       	mov    $0x0,%edx
  8000e9:	b8 01 00 00 00       	mov    $0x1,%eax
  8000ee:	89 d1                	mov    %edx,%ecx
  8000f0:	89 d3                	mov    %edx,%ebx
  8000f2:	89 d7                	mov    %edx,%edi
  8000f4:	89 d6                	mov    %edx,%esi
  8000f6:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000f8:	5b                   	pop    %ebx
  8000f9:	5e                   	pop    %esi
  8000fa:	5f                   	pop    %edi
  8000fb:	5d                   	pop    %ebp
  8000fc:	c3                   	ret    

008000fd <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000fd:	f3 0f 1e fb          	endbr32 
  800101:	55                   	push   %ebp
  800102:	89 e5                	mov    %esp,%ebp
  800104:	57                   	push   %edi
  800105:	56                   	push   %esi
  800106:	53                   	push   %ebx
  800107:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80010a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80010f:	8b 55 08             	mov    0x8(%ebp),%edx
  800112:	b8 03 00 00 00       	mov    $0x3,%eax
  800117:	89 cb                	mov    %ecx,%ebx
  800119:	89 cf                	mov    %ecx,%edi
  80011b:	89 ce                	mov    %ecx,%esi
  80011d:	cd 30                	int    $0x30
	if(check && ret > 0)
  80011f:	85 c0                	test   %eax,%eax
  800121:	7f 08                	jg     80012b <sys_env_destroy+0x2e>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800123:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800126:	5b                   	pop    %ebx
  800127:	5e                   	pop    %esi
  800128:	5f                   	pop    %edi
  800129:	5d                   	pop    %ebp
  80012a:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80012b:	83 ec 0c             	sub    $0xc,%esp
  80012e:	50                   	push   %eax
  80012f:	6a 03                	push   $0x3
  800131:	68 ea 10 80 00       	push   $0x8010ea
  800136:	6a 23                	push   $0x23
  800138:	68 07 11 80 00       	push   $0x801107
  80013d:	e8 37 02 00 00       	call   800379 <_panic>

00800142 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800142:	f3 0f 1e fb          	endbr32 
  800146:	55                   	push   %ebp
  800147:	89 e5                	mov    %esp,%ebp
  800149:	57                   	push   %edi
  80014a:	56                   	push   %esi
  80014b:	53                   	push   %ebx
	asm volatile("int %1\n"
  80014c:	ba 00 00 00 00       	mov    $0x0,%edx
  800151:	b8 02 00 00 00       	mov    $0x2,%eax
  800156:	89 d1                	mov    %edx,%ecx
  800158:	89 d3                	mov    %edx,%ebx
  80015a:	89 d7                	mov    %edx,%edi
  80015c:	89 d6                	mov    %edx,%esi
  80015e:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800160:	5b                   	pop    %ebx
  800161:	5e                   	pop    %esi
  800162:	5f                   	pop    %edi
  800163:	5d                   	pop    %ebp
  800164:	c3                   	ret    

00800165 <sys_yield>:

void
sys_yield(void)
{
  800165:	f3 0f 1e fb          	endbr32 
  800169:	55                   	push   %ebp
  80016a:	89 e5                	mov    %esp,%ebp
  80016c:	57                   	push   %edi
  80016d:	56                   	push   %esi
  80016e:	53                   	push   %ebx
	asm volatile("int %1\n"
  80016f:	ba 00 00 00 00       	mov    $0x0,%edx
  800174:	b8 0a 00 00 00       	mov    $0xa,%eax
  800179:	89 d1                	mov    %edx,%ecx
  80017b:	89 d3                	mov    %edx,%ebx
  80017d:	89 d7                	mov    %edx,%edi
  80017f:	89 d6                	mov    %edx,%esi
  800181:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800183:	5b                   	pop    %ebx
  800184:	5e                   	pop    %esi
  800185:	5f                   	pop    %edi
  800186:	5d                   	pop    %ebp
  800187:	c3                   	ret    

00800188 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800188:	f3 0f 1e fb          	endbr32 
  80018c:	55                   	push   %ebp
  80018d:	89 e5                	mov    %esp,%ebp
  80018f:	57                   	push   %edi
  800190:	56                   	push   %esi
  800191:	53                   	push   %ebx
  800192:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800195:	be 00 00 00 00       	mov    $0x0,%esi
  80019a:	8b 55 08             	mov    0x8(%ebp),%edx
  80019d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001a0:	b8 04 00 00 00       	mov    $0x4,%eax
  8001a5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001a8:	89 f7                	mov    %esi,%edi
  8001aa:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001ac:	85 c0                	test   %eax,%eax
  8001ae:	7f 08                	jg     8001b8 <sys_page_alloc+0x30>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001b0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001b3:	5b                   	pop    %ebx
  8001b4:	5e                   	pop    %esi
  8001b5:	5f                   	pop    %edi
  8001b6:	5d                   	pop    %ebp
  8001b7:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8001b8:	83 ec 0c             	sub    $0xc,%esp
  8001bb:	50                   	push   %eax
  8001bc:	6a 04                	push   $0x4
  8001be:	68 ea 10 80 00       	push   $0x8010ea
  8001c3:	6a 23                	push   $0x23
  8001c5:	68 07 11 80 00       	push   $0x801107
  8001ca:	e8 aa 01 00 00       	call   800379 <_panic>

008001cf <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001cf:	f3 0f 1e fb          	endbr32 
  8001d3:	55                   	push   %ebp
  8001d4:	89 e5                	mov    %esp,%ebp
  8001d6:	57                   	push   %edi
  8001d7:	56                   	push   %esi
  8001d8:	53                   	push   %ebx
  8001d9:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001dc:	8b 55 08             	mov    0x8(%ebp),%edx
  8001df:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001e2:	b8 05 00 00 00       	mov    $0x5,%eax
  8001e7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001ea:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001ed:	8b 75 18             	mov    0x18(%ebp),%esi
  8001f0:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001f2:	85 c0                	test   %eax,%eax
  8001f4:	7f 08                	jg     8001fe <sys_page_map+0x2f>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001f6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001f9:	5b                   	pop    %ebx
  8001fa:	5e                   	pop    %esi
  8001fb:	5f                   	pop    %edi
  8001fc:	5d                   	pop    %ebp
  8001fd:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8001fe:	83 ec 0c             	sub    $0xc,%esp
  800201:	50                   	push   %eax
  800202:	6a 05                	push   $0x5
  800204:	68 ea 10 80 00       	push   $0x8010ea
  800209:	6a 23                	push   $0x23
  80020b:	68 07 11 80 00       	push   $0x801107
  800210:	e8 64 01 00 00       	call   800379 <_panic>

00800215 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800215:	f3 0f 1e fb          	endbr32 
  800219:	55                   	push   %ebp
  80021a:	89 e5                	mov    %esp,%ebp
  80021c:	57                   	push   %edi
  80021d:	56                   	push   %esi
  80021e:	53                   	push   %ebx
  80021f:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800222:	bb 00 00 00 00       	mov    $0x0,%ebx
  800227:	8b 55 08             	mov    0x8(%ebp),%edx
  80022a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80022d:	b8 06 00 00 00       	mov    $0x6,%eax
  800232:	89 df                	mov    %ebx,%edi
  800234:	89 de                	mov    %ebx,%esi
  800236:	cd 30                	int    $0x30
	if(check && ret > 0)
  800238:	85 c0                	test   %eax,%eax
  80023a:	7f 08                	jg     800244 <sys_page_unmap+0x2f>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80023c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80023f:	5b                   	pop    %ebx
  800240:	5e                   	pop    %esi
  800241:	5f                   	pop    %edi
  800242:	5d                   	pop    %ebp
  800243:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800244:	83 ec 0c             	sub    $0xc,%esp
  800247:	50                   	push   %eax
  800248:	6a 06                	push   $0x6
  80024a:	68 ea 10 80 00       	push   $0x8010ea
  80024f:	6a 23                	push   $0x23
  800251:	68 07 11 80 00       	push   $0x801107
  800256:	e8 1e 01 00 00       	call   800379 <_panic>

0080025b <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80025b:	f3 0f 1e fb          	endbr32 
  80025f:	55                   	push   %ebp
  800260:	89 e5                	mov    %esp,%ebp
  800262:	57                   	push   %edi
  800263:	56                   	push   %esi
  800264:	53                   	push   %ebx
  800265:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800268:	bb 00 00 00 00       	mov    $0x0,%ebx
  80026d:	8b 55 08             	mov    0x8(%ebp),%edx
  800270:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800273:	b8 08 00 00 00       	mov    $0x8,%eax
  800278:	89 df                	mov    %ebx,%edi
  80027a:	89 de                	mov    %ebx,%esi
  80027c:	cd 30                	int    $0x30
	if(check && ret > 0)
  80027e:	85 c0                	test   %eax,%eax
  800280:	7f 08                	jg     80028a <sys_env_set_status+0x2f>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800282:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800285:	5b                   	pop    %ebx
  800286:	5e                   	pop    %esi
  800287:	5f                   	pop    %edi
  800288:	5d                   	pop    %ebp
  800289:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80028a:	83 ec 0c             	sub    $0xc,%esp
  80028d:	50                   	push   %eax
  80028e:	6a 08                	push   $0x8
  800290:	68 ea 10 80 00       	push   $0x8010ea
  800295:	6a 23                	push   $0x23
  800297:	68 07 11 80 00       	push   $0x801107
  80029c:	e8 d8 00 00 00       	call   800379 <_panic>

008002a1 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002a1:	f3 0f 1e fb          	endbr32 
  8002a5:	55                   	push   %ebp
  8002a6:	89 e5                	mov    %esp,%ebp
  8002a8:	57                   	push   %edi
  8002a9:	56                   	push   %esi
  8002aa:	53                   	push   %ebx
  8002ab:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8002ae:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002b3:	8b 55 08             	mov    0x8(%ebp),%edx
  8002b6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002b9:	b8 09 00 00 00       	mov    $0x9,%eax
  8002be:	89 df                	mov    %ebx,%edi
  8002c0:	89 de                	mov    %ebx,%esi
  8002c2:	cd 30                	int    $0x30
	if(check && ret > 0)
  8002c4:	85 c0                	test   %eax,%eax
  8002c6:	7f 08                	jg     8002d0 <sys_env_set_pgfault_upcall+0x2f>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002c8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002cb:	5b                   	pop    %ebx
  8002cc:	5e                   	pop    %esi
  8002cd:	5f                   	pop    %edi
  8002ce:	5d                   	pop    %ebp
  8002cf:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8002d0:	83 ec 0c             	sub    $0xc,%esp
  8002d3:	50                   	push   %eax
  8002d4:	6a 09                	push   $0x9
  8002d6:	68 ea 10 80 00       	push   $0x8010ea
  8002db:	6a 23                	push   $0x23
  8002dd:	68 07 11 80 00       	push   $0x801107
  8002e2:	e8 92 00 00 00       	call   800379 <_panic>

008002e7 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002e7:	f3 0f 1e fb          	endbr32 
  8002eb:	55                   	push   %ebp
  8002ec:	89 e5                	mov    %esp,%ebp
  8002ee:	57                   	push   %edi
  8002ef:	56                   	push   %esi
  8002f0:	53                   	push   %ebx
	asm volatile("int %1\n"
  8002f1:	8b 55 08             	mov    0x8(%ebp),%edx
  8002f4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002f7:	b8 0b 00 00 00       	mov    $0xb,%eax
  8002fc:	be 00 00 00 00       	mov    $0x0,%esi
  800301:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800304:	8b 7d 14             	mov    0x14(%ebp),%edi
  800307:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800309:	5b                   	pop    %ebx
  80030a:	5e                   	pop    %esi
  80030b:	5f                   	pop    %edi
  80030c:	5d                   	pop    %ebp
  80030d:	c3                   	ret    

0080030e <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80030e:	f3 0f 1e fb          	endbr32 
  800312:	55                   	push   %ebp
  800313:	89 e5                	mov    %esp,%ebp
  800315:	57                   	push   %edi
  800316:	56                   	push   %esi
  800317:	53                   	push   %ebx
  800318:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80031b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800320:	8b 55 08             	mov    0x8(%ebp),%edx
  800323:	b8 0c 00 00 00       	mov    $0xc,%eax
  800328:	89 cb                	mov    %ecx,%ebx
  80032a:	89 cf                	mov    %ecx,%edi
  80032c:	89 ce                	mov    %ecx,%esi
  80032e:	cd 30                	int    $0x30
	if(check && ret > 0)
  800330:	85 c0                	test   %eax,%eax
  800332:	7f 08                	jg     80033c <sys_ipc_recv+0x2e>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800334:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800337:	5b                   	pop    %ebx
  800338:	5e                   	pop    %esi
  800339:	5f                   	pop    %edi
  80033a:	5d                   	pop    %ebp
  80033b:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80033c:	83 ec 0c             	sub    $0xc,%esp
  80033f:	50                   	push   %eax
  800340:	6a 0c                	push   $0xc
  800342:	68 ea 10 80 00       	push   $0x8010ea
  800347:	6a 23                	push   $0x23
  800349:	68 07 11 80 00       	push   $0x801107
  80034e:	e8 26 00 00 00       	call   800379 <_panic>

00800353 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800353:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800354:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  800359:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80035b:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	addl $8, %esp
  80035e:	83 c4 08             	add    $0x8,%esp
	movl 32(%esp), %eax
  800361:	8b 44 24 20          	mov    0x20(%esp),%eax
	movl 40(%esp), %edx
  800365:	8b 54 24 28          	mov    0x28(%esp),%edx
	subl $4, %edx
  800369:	83 ea 04             	sub    $0x4,%edx
	movl %eax, (%edx)
  80036c:	89 02                	mov    %eax,(%edx)
	movl %edx, 40(%esp)
  80036e:	89 54 24 28          	mov    %edx,0x28(%esp)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal
  800372:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp
  800373:	83 c4 04             	add    $0x4,%esp
	popfl
  800376:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  800377:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  800378:	c3                   	ret    

00800379 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800379:	f3 0f 1e fb          	endbr32 
  80037d:	55                   	push   %ebp
  80037e:	89 e5                	mov    %esp,%ebp
  800380:	56                   	push   %esi
  800381:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800382:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800385:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80038b:	e8 b2 fd ff ff       	call   800142 <sys_getenvid>
  800390:	83 ec 0c             	sub    $0xc,%esp
  800393:	ff 75 0c             	pushl  0xc(%ebp)
  800396:	ff 75 08             	pushl  0x8(%ebp)
  800399:	56                   	push   %esi
  80039a:	50                   	push   %eax
  80039b:	68 18 11 80 00       	push   $0x801118
  8003a0:	e8 bb 00 00 00       	call   800460 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8003a5:	83 c4 18             	add    $0x18,%esp
  8003a8:	53                   	push   %ebx
  8003a9:	ff 75 10             	pushl  0x10(%ebp)
  8003ac:	e8 5a 00 00 00       	call   80040b <vcprintf>
	cprintf("\n");
  8003b1:	c7 04 24 3b 11 80 00 	movl   $0x80113b,(%esp)
  8003b8:	e8 a3 00 00 00       	call   800460 <cprintf>
  8003bd:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8003c0:	cc                   	int3   
  8003c1:	eb fd                	jmp    8003c0 <_panic+0x47>

008003c3 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8003c3:	f3 0f 1e fb          	endbr32 
  8003c7:	55                   	push   %ebp
  8003c8:	89 e5                	mov    %esp,%ebp
  8003ca:	53                   	push   %ebx
  8003cb:	83 ec 04             	sub    $0x4,%esp
  8003ce:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8003d1:	8b 13                	mov    (%ebx),%edx
  8003d3:	8d 42 01             	lea    0x1(%edx),%eax
  8003d6:	89 03                	mov    %eax,(%ebx)
  8003d8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003db:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8003df:	3d ff 00 00 00       	cmp    $0xff,%eax
  8003e4:	74 09                	je     8003ef <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8003e6:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8003ea:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8003ed:	c9                   	leave  
  8003ee:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8003ef:	83 ec 08             	sub    $0x8,%esp
  8003f2:	68 ff 00 00 00       	push   $0xff
  8003f7:	8d 43 08             	lea    0x8(%ebx),%eax
  8003fa:	50                   	push   %eax
  8003fb:	e8 b8 fc ff ff       	call   8000b8 <sys_cputs>
		b->idx = 0;
  800400:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800406:	83 c4 10             	add    $0x10,%esp
  800409:	eb db                	jmp    8003e6 <putch+0x23>

0080040b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80040b:	f3 0f 1e fb          	endbr32 
  80040f:	55                   	push   %ebp
  800410:	89 e5                	mov    %esp,%ebp
  800412:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800418:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80041f:	00 00 00 
	b.cnt = 0;
  800422:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800429:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80042c:	ff 75 0c             	pushl  0xc(%ebp)
  80042f:	ff 75 08             	pushl  0x8(%ebp)
  800432:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800438:	50                   	push   %eax
  800439:	68 c3 03 80 00       	push   $0x8003c3
  80043e:	e8 20 01 00 00       	call   800563 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800443:	83 c4 08             	add    $0x8,%esp
  800446:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80044c:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800452:	50                   	push   %eax
  800453:	e8 60 fc ff ff       	call   8000b8 <sys_cputs>

	return b.cnt;
}
  800458:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80045e:	c9                   	leave  
  80045f:	c3                   	ret    

00800460 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800460:	f3 0f 1e fb          	endbr32 
  800464:	55                   	push   %ebp
  800465:	89 e5                	mov    %esp,%ebp
  800467:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80046a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80046d:	50                   	push   %eax
  80046e:	ff 75 08             	pushl  0x8(%ebp)
  800471:	e8 95 ff ff ff       	call   80040b <vcprintf>
	va_end(ap);

	return cnt;
}
  800476:	c9                   	leave  
  800477:	c3                   	ret    

00800478 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800478:	55                   	push   %ebp
  800479:	89 e5                	mov    %esp,%ebp
  80047b:	57                   	push   %edi
  80047c:	56                   	push   %esi
  80047d:	53                   	push   %ebx
  80047e:	83 ec 1c             	sub    $0x1c,%esp
  800481:	89 c7                	mov    %eax,%edi
  800483:	89 d6                	mov    %edx,%esi
  800485:	8b 45 08             	mov    0x8(%ebp),%eax
  800488:	8b 55 0c             	mov    0xc(%ebp),%edx
  80048b:	89 d1                	mov    %edx,%ecx
  80048d:	89 c2                	mov    %eax,%edx
  80048f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800492:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800495:	8b 45 10             	mov    0x10(%ebp),%eax
  800498:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80049b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80049e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8004a5:	39 c2                	cmp    %eax,%edx
  8004a7:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8004aa:	72 3e                	jb     8004ea <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8004ac:	83 ec 0c             	sub    $0xc,%esp
  8004af:	ff 75 18             	pushl  0x18(%ebp)
  8004b2:	83 eb 01             	sub    $0x1,%ebx
  8004b5:	53                   	push   %ebx
  8004b6:	50                   	push   %eax
  8004b7:	83 ec 08             	sub    $0x8,%esp
  8004ba:	ff 75 e4             	pushl  -0x1c(%ebp)
  8004bd:	ff 75 e0             	pushl  -0x20(%ebp)
  8004c0:	ff 75 dc             	pushl  -0x24(%ebp)
  8004c3:	ff 75 d8             	pushl  -0x28(%ebp)
  8004c6:	e8 b5 09 00 00       	call   800e80 <__udivdi3>
  8004cb:	83 c4 18             	add    $0x18,%esp
  8004ce:	52                   	push   %edx
  8004cf:	50                   	push   %eax
  8004d0:	89 f2                	mov    %esi,%edx
  8004d2:	89 f8                	mov    %edi,%eax
  8004d4:	e8 9f ff ff ff       	call   800478 <printnum>
  8004d9:	83 c4 20             	add    $0x20,%esp
  8004dc:	eb 13                	jmp    8004f1 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8004de:	83 ec 08             	sub    $0x8,%esp
  8004e1:	56                   	push   %esi
  8004e2:	ff 75 18             	pushl  0x18(%ebp)
  8004e5:	ff d7                	call   *%edi
  8004e7:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8004ea:	83 eb 01             	sub    $0x1,%ebx
  8004ed:	85 db                	test   %ebx,%ebx
  8004ef:	7f ed                	jg     8004de <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8004f1:	83 ec 08             	sub    $0x8,%esp
  8004f4:	56                   	push   %esi
  8004f5:	83 ec 04             	sub    $0x4,%esp
  8004f8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8004fb:	ff 75 e0             	pushl  -0x20(%ebp)
  8004fe:	ff 75 dc             	pushl  -0x24(%ebp)
  800501:	ff 75 d8             	pushl  -0x28(%ebp)
  800504:	e8 87 0a 00 00       	call   800f90 <__umoddi3>
  800509:	83 c4 14             	add    $0x14,%esp
  80050c:	0f be 80 3d 11 80 00 	movsbl 0x80113d(%eax),%eax
  800513:	50                   	push   %eax
  800514:	ff d7                	call   *%edi
}
  800516:	83 c4 10             	add    $0x10,%esp
  800519:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80051c:	5b                   	pop    %ebx
  80051d:	5e                   	pop    %esi
  80051e:	5f                   	pop    %edi
  80051f:	5d                   	pop    %ebp
  800520:	c3                   	ret    

00800521 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800521:	f3 0f 1e fb          	endbr32 
  800525:	55                   	push   %ebp
  800526:	89 e5                	mov    %esp,%ebp
  800528:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80052b:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80052f:	8b 10                	mov    (%eax),%edx
  800531:	3b 50 04             	cmp    0x4(%eax),%edx
  800534:	73 0a                	jae    800540 <sprintputch+0x1f>
		*b->buf++ = ch;
  800536:	8d 4a 01             	lea    0x1(%edx),%ecx
  800539:	89 08                	mov    %ecx,(%eax)
  80053b:	8b 45 08             	mov    0x8(%ebp),%eax
  80053e:	88 02                	mov    %al,(%edx)
}
  800540:	5d                   	pop    %ebp
  800541:	c3                   	ret    

00800542 <printfmt>:
{
  800542:	f3 0f 1e fb          	endbr32 
  800546:	55                   	push   %ebp
  800547:	89 e5                	mov    %esp,%ebp
  800549:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80054c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80054f:	50                   	push   %eax
  800550:	ff 75 10             	pushl  0x10(%ebp)
  800553:	ff 75 0c             	pushl  0xc(%ebp)
  800556:	ff 75 08             	pushl  0x8(%ebp)
  800559:	e8 05 00 00 00       	call   800563 <vprintfmt>
}
  80055e:	83 c4 10             	add    $0x10,%esp
  800561:	c9                   	leave  
  800562:	c3                   	ret    

00800563 <vprintfmt>:
{
  800563:	f3 0f 1e fb          	endbr32 
  800567:	55                   	push   %ebp
  800568:	89 e5                	mov    %esp,%ebp
  80056a:	57                   	push   %edi
  80056b:	56                   	push   %esi
  80056c:	53                   	push   %ebx
  80056d:	83 ec 3c             	sub    $0x3c,%esp
  800570:	8b 75 08             	mov    0x8(%ebp),%esi
  800573:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800576:	8b 7d 10             	mov    0x10(%ebp),%edi
  800579:	e9 cd 03 00 00       	jmp    80094b <vprintfmt+0x3e8>
		padc = ' ';
  80057e:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800582:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800589:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800590:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800597:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80059c:	8d 47 01             	lea    0x1(%edi),%eax
  80059f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8005a2:	0f b6 17             	movzbl (%edi),%edx
  8005a5:	8d 42 dd             	lea    -0x23(%edx),%eax
  8005a8:	3c 55                	cmp    $0x55,%al
  8005aa:	0f 87 1e 04 00 00    	ja     8009ce <vprintfmt+0x46b>
  8005b0:	0f b6 c0             	movzbl %al,%eax
  8005b3:	3e ff 24 85 00 12 80 	notrack jmp *0x801200(,%eax,4)
  8005ba:	00 
  8005bb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8005be:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  8005c2:	eb d8                	jmp    80059c <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8005c4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005c7:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  8005cb:	eb cf                	jmp    80059c <vprintfmt+0x39>
  8005cd:	0f b6 d2             	movzbl %dl,%edx
  8005d0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8005d3:	b8 00 00 00 00       	mov    $0x0,%eax
  8005d8:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8005db:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8005de:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8005e2:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8005e5:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8005e8:	83 f9 09             	cmp    $0x9,%ecx
  8005eb:	77 55                	ja     800642 <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  8005ed:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8005f0:	eb e9                	jmp    8005db <vprintfmt+0x78>
			precision = va_arg(ap, int);
  8005f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f5:	8b 00                	mov    (%eax),%eax
  8005f7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fd:	8d 40 04             	lea    0x4(%eax),%eax
  800600:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800603:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800606:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80060a:	79 90                	jns    80059c <vprintfmt+0x39>
				width = precision, precision = -1;
  80060c:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80060f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800612:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800619:	eb 81                	jmp    80059c <vprintfmt+0x39>
  80061b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80061e:	85 c0                	test   %eax,%eax
  800620:	ba 00 00 00 00       	mov    $0x0,%edx
  800625:	0f 49 d0             	cmovns %eax,%edx
  800628:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80062b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80062e:	e9 69 ff ff ff       	jmp    80059c <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800633:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800636:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  80063d:	e9 5a ff ff ff       	jmp    80059c <vprintfmt+0x39>
  800642:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800645:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800648:	eb bc                	jmp    800606 <vprintfmt+0xa3>
			lflag++;
  80064a:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80064d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800650:	e9 47 ff ff ff       	jmp    80059c <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  800655:	8b 45 14             	mov    0x14(%ebp),%eax
  800658:	8d 78 04             	lea    0x4(%eax),%edi
  80065b:	83 ec 08             	sub    $0x8,%esp
  80065e:	53                   	push   %ebx
  80065f:	ff 30                	pushl  (%eax)
  800661:	ff d6                	call   *%esi
			break;
  800663:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800666:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800669:	e9 da 02 00 00       	jmp    800948 <vprintfmt+0x3e5>
			err = va_arg(ap, int);
  80066e:	8b 45 14             	mov    0x14(%ebp),%eax
  800671:	8d 78 04             	lea    0x4(%eax),%edi
  800674:	8b 00                	mov    (%eax),%eax
  800676:	99                   	cltd   
  800677:	31 d0                	xor    %edx,%eax
  800679:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80067b:	83 f8 08             	cmp    $0x8,%eax
  80067e:	7f 23                	jg     8006a3 <vprintfmt+0x140>
  800680:	8b 14 85 60 13 80 00 	mov    0x801360(,%eax,4),%edx
  800687:	85 d2                	test   %edx,%edx
  800689:	74 18                	je     8006a3 <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  80068b:	52                   	push   %edx
  80068c:	68 5e 11 80 00       	push   $0x80115e
  800691:	53                   	push   %ebx
  800692:	56                   	push   %esi
  800693:	e8 aa fe ff ff       	call   800542 <printfmt>
  800698:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80069b:	89 7d 14             	mov    %edi,0x14(%ebp)
  80069e:	e9 a5 02 00 00       	jmp    800948 <vprintfmt+0x3e5>
				printfmt(putch, putdat, "error %d", err);
  8006a3:	50                   	push   %eax
  8006a4:	68 55 11 80 00       	push   $0x801155
  8006a9:	53                   	push   %ebx
  8006aa:	56                   	push   %esi
  8006ab:	e8 92 fe ff ff       	call   800542 <printfmt>
  8006b0:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8006b3:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8006b6:	e9 8d 02 00 00       	jmp    800948 <vprintfmt+0x3e5>
			if ((p = va_arg(ap, char *)) == NULL)
  8006bb:	8b 45 14             	mov    0x14(%ebp),%eax
  8006be:	83 c0 04             	add    $0x4,%eax
  8006c1:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8006c4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c7:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  8006c9:	85 d2                	test   %edx,%edx
  8006cb:	b8 4e 11 80 00       	mov    $0x80114e,%eax
  8006d0:	0f 45 c2             	cmovne %edx,%eax
  8006d3:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8006d6:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006da:	7e 06                	jle    8006e2 <vprintfmt+0x17f>
  8006dc:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  8006e0:	75 0d                	jne    8006ef <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006e2:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8006e5:	89 c7                	mov    %eax,%edi
  8006e7:	03 45 e0             	add    -0x20(%ebp),%eax
  8006ea:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006ed:	eb 55                	jmp    800744 <vprintfmt+0x1e1>
  8006ef:	83 ec 08             	sub    $0x8,%esp
  8006f2:	ff 75 d8             	pushl  -0x28(%ebp)
  8006f5:	ff 75 cc             	pushl  -0x34(%ebp)
  8006f8:	e8 85 03 00 00       	call   800a82 <strnlen>
  8006fd:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800700:	29 c2                	sub    %eax,%edx
  800702:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  800705:	83 c4 10             	add    $0x10,%esp
  800708:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  80070a:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  80070e:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800711:	85 ff                	test   %edi,%edi
  800713:	7e 11                	jle    800726 <vprintfmt+0x1c3>
					putch(padc, putdat);
  800715:	83 ec 08             	sub    $0x8,%esp
  800718:	53                   	push   %ebx
  800719:	ff 75 e0             	pushl  -0x20(%ebp)
  80071c:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  80071e:	83 ef 01             	sub    $0x1,%edi
  800721:	83 c4 10             	add    $0x10,%esp
  800724:	eb eb                	jmp    800711 <vprintfmt+0x1ae>
  800726:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800729:	85 d2                	test   %edx,%edx
  80072b:	b8 00 00 00 00       	mov    $0x0,%eax
  800730:	0f 49 c2             	cmovns %edx,%eax
  800733:	29 c2                	sub    %eax,%edx
  800735:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800738:	eb a8                	jmp    8006e2 <vprintfmt+0x17f>
					putch(ch, putdat);
  80073a:	83 ec 08             	sub    $0x8,%esp
  80073d:	53                   	push   %ebx
  80073e:	52                   	push   %edx
  80073f:	ff d6                	call   *%esi
  800741:	83 c4 10             	add    $0x10,%esp
  800744:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800747:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800749:	83 c7 01             	add    $0x1,%edi
  80074c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800750:	0f be d0             	movsbl %al,%edx
  800753:	85 d2                	test   %edx,%edx
  800755:	74 4b                	je     8007a2 <vprintfmt+0x23f>
  800757:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80075b:	78 06                	js     800763 <vprintfmt+0x200>
  80075d:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800761:	78 1e                	js     800781 <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
  800763:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800767:	74 d1                	je     80073a <vprintfmt+0x1d7>
  800769:	0f be c0             	movsbl %al,%eax
  80076c:	83 e8 20             	sub    $0x20,%eax
  80076f:	83 f8 5e             	cmp    $0x5e,%eax
  800772:	76 c6                	jbe    80073a <vprintfmt+0x1d7>
					putch('?', putdat);
  800774:	83 ec 08             	sub    $0x8,%esp
  800777:	53                   	push   %ebx
  800778:	6a 3f                	push   $0x3f
  80077a:	ff d6                	call   *%esi
  80077c:	83 c4 10             	add    $0x10,%esp
  80077f:	eb c3                	jmp    800744 <vprintfmt+0x1e1>
  800781:	89 cf                	mov    %ecx,%edi
  800783:	eb 0e                	jmp    800793 <vprintfmt+0x230>
				putch(' ', putdat);
  800785:	83 ec 08             	sub    $0x8,%esp
  800788:	53                   	push   %ebx
  800789:	6a 20                	push   $0x20
  80078b:	ff d6                	call   *%esi
			for (; width > 0; width--)
  80078d:	83 ef 01             	sub    $0x1,%edi
  800790:	83 c4 10             	add    $0x10,%esp
  800793:	85 ff                	test   %edi,%edi
  800795:	7f ee                	jg     800785 <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  800797:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80079a:	89 45 14             	mov    %eax,0x14(%ebp)
  80079d:	e9 a6 01 00 00       	jmp    800948 <vprintfmt+0x3e5>
  8007a2:	89 cf                	mov    %ecx,%edi
  8007a4:	eb ed                	jmp    800793 <vprintfmt+0x230>
	if (lflag >= 2)
  8007a6:	83 f9 01             	cmp    $0x1,%ecx
  8007a9:	7f 1f                	jg     8007ca <vprintfmt+0x267>
	else if (lflag)
  8007ab:	85 c9                	test   %ecx,%ecx
  8007ad:	74 67                	je     800816 <vprintfmt+0x2b3>
		return va_arg(*ap, long);
  8007af:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b2:	8b 00                	mov    (%eax),%eax
  8007b4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007b7:	89 c1                	mov    %eax,%ecx
  8007b9:	c1 f9 1f             	sar    $0x1f,%ecx
  8007bc:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8007bf:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c2:	8d 40 04             	lea    0x4(%eax),%eax
  8007c5:	89 45 14             	mov    %eax,0x14(%ebp)
  8007c8:	eb 17                	jmp    8007e1 <vprintfmt+0x27e>
		return va_arg(*ap, long long);
  8007ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8007cd:	8b 50 04             	mov    0x4(%eax),%edx
  8007d0:	8b 00                	mov    (%eax),%eax
  8007d2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007d5:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8007db:	8d 40 08             	lea    0x8(%eax),%eax
  8007de:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8007e1:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007e4:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8007e7:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  8007ec:	85 c9                	test   %ecx,%ecx
  8007ee:	0f 89 3a 01 00 00    	jns    80092e <vprintfmt+0x3cb>
				putch('-', putdat);
  8007f4:	83 ec 08             	sub    $0x8,%esp
  8007f7:	53                   	push   %ebx
  8007f8:	6a 2d                	push   $0x2d
  8007fa:	ff d6                	call   *%esi
				num = -(long long) num;
  8007fc:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007ff:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800802:	f7 da                	neg    %edx
  800804:	83 d1 00             	adc    $0x0,%ecx
  800807:	f7 d9                	neg    %ecx
  800809:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80080c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800811:	e9 18 01 00 00       	jmp    80092e <vprintfmt+0x3cb>
		return va_arg(*ap, int);
  800816:	8b 45 14             	mov    0x14(%ebp),%eax
  800819:	8b 00                	mov    (%eax),%eax
  80081b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80081e:	89 c1                	mov    %eax,%ecx
  800820:	c1 f9 1f             	sar    $0x1f,%ecx
  800823:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800826:	8b 45 14             	mov    0x14(%ebp),%eax
  800829:	8d 40 04             	lea    0x4(%eax),%eax
  80082c:	89 45 14             	mov    %eax,0x14(%ebp)
  80082f:	eb b0                	jmp    8007e1 <vprintfmt+0x27e>
	if (lflag >= 2)
  800831:	83 f9 01             	cmp    $0x1,%ecx
  800834:	7f 1e                	jg     800854 <vprintfmt+0x2f1>
	else if (lflag)
  800836:	85 c9                	test   %ecx,%ecx
  800838:	74 32                	je     80086c <vprintfmt+0x309>
		return va_arg(*ap, unsigned long);
  80083a:	8b 45 14             	mov    0x14(%ebp),%eax
  80083d:	8b 10                	mov    (%eax),%edx
  80083f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800844:	8d 40 04             	lea    0x4(%eax),%eax
  800847:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80084a:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  80084f:	e9 da 00 00 00       	jmp    80092e <vprintfmt+0x3cb>
		return va_arg(*ap, unsigned long long);
  800854:	8b 45 14             	mov    0x14(%ebp),%eax
  800857:	8b 10                	mov    (%eax),%edx
  800859:	8b 48 04             	mov    0x4(%eax),%ecx
  80085c:	8d 40 08             	lea    0x8(%eax),%eax
  80085f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800862:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  800867:	e9 c2 00 00 00       	jmp    80092e <vprintfmt+0x3cb>
		return va_arg(*ap, unsigned int);
  80086c:	8b 45 14             	mov    0x14(%ebp),%eax
  80086f:	8b 10                	mov    (%eax),%edx
  800871:	b9 00 00 00 00       	mov    $0x0,%ecx
  800876:	8d 40 04             	lea    0x4(%eax),%eax
  800879:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80087c:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  800881:	e9 a8 00 00 00       	jmp    80092e <vprintfmt+0x3cb>
	if (lflag >= 2)
  800886:	83 f9 01             	cmp    $0x1,%ecx
  800889:	7f 1b                	jg     8008a6 <vprintfmt+0x343>
	else if (lflag)
  80088b:	85 c9                	test   %ecx,%ecx
  80088d:	74 5c                	je     8008eb <vprintfmt+0x388>
		return va_arg(*ap, long);
  80088f:	8b 45 14             	mov    0x14(%ebp),%eax
  800892:	8b 00                	mov    (%eax),%eax
  800894:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800897:	99                   	cltd   
  800898:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80089b:	8b 45 14             	mov    0x14(%ebp),%eax
  80089e:	8d 40 04             	lea    0x4(%eax),%eax
  8008a1:	89 45 14             	mov    %eax,0x14(%ebp)
  8008a4:	eb 17                	jmp    8008bd <vprintfmt+0x35a>
		return va_arg(*ap, long long);
  8008a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8008a9:	8b 50 04             	mov    0x4(%eax),%edx
  8008ac:	8b 00                	mov    (%eax),%eax
  8008ae:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8008b1:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8008b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8008b7:	8d 40 08             	lea    0x8(%eax),%eax
  8008ba:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8008bd:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8008c0:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 8;
  8008c3:	b8 08 00 00 00       	mov    $0x8,%eax
			if ((long long) num < 0) {
  8008c8:	85 c9                	test   %ecx,%ecx
  8008ca:	79 62                	jns    80092e <vprintfmt+0x3cb>
				putch('-', putdat);
  8008cc:	83 ec 08             	sub    $0x8,%esp
  8008cf:	53                   	push   %ebx
  8008d0:	6a 2d                	push   $0x2d
  8008d2:	ff d6                	call   *%esi
				num = -(long long) num;
  8008d4:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8008d7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8008da:	f7 da                	neg    %edx
  8008dc:	83 d1 00             	adc    $0x0,%ecx
  8008df:	f7 d9                	neg    %ecx
  8008e1:	83 c4 10             	add    $0x10,%esp
			base = 8;
  8008e4:	b8 08 00 00 00       	mov    $0x8,%eax
  8008e9:	eb 43                	jmp    80092e <vprintfmt+0x3cb>
		return va_arg(*ap, int);
  8008eb:	8b 45 14             	mov    0x14(%ebp),%eax
  8008ee:	8b 00                	mov    (%eax),%eax
  8008f0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8008f3:	89 c1                	mov    %eax,%ecx
  8008f5:	c1 f9 1f             	sar    $0x1f,%ecx
  8008f8:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8008fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8008fe:	8d 40 04             	lea    0x4(%eax),%eax
  800901:	89 45 14             	mov    %eax,0x14(%ebp)
  800904:	eb b7                	jmp    8008bd <vprintfmt+0x35a>
			putch('0', putdat);
  800906:	83 ec 08             	sub    $0x8,%esp
  800909:	53                   	push   %ebx
  80090a:	6a 30                	push   $0x30
  80090c:	ff d6                	call   *%esi
			putch('x', putdat);
  80090e:	83 c4 08             	add    $0x8,%esp
  800911:	53                   	push   %ebx
  800912:	6a 78                	push   $0x78
  800914:	ff d6                	call   *%esi
			num = (unsigned long long)
  800916:	8b 45 14             	mov    0x14(%ebp),%eax
  800919:	8b 10                	mov    (%eax),%edx
  80091b:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800920:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800923:	8d 40 04             	lea    0x4(%eax),%eax
  800926:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800929:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  80092e:	83 ec 0c             	sub    $0xc,%esp
  800931:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  800935:	57                   	push   %edi
  800936:	ff 75 e0             	pushl  -0x20(%ebp)
  800939:	50                   	push   %eax
  80093a:	51                   	push   %ecx
  80093b:	52                   	push   %edx
  80093c:	89 da                	mov    %ebx,%edx
  80093e:	89 f0                	mov    %esi,%eax
  800940:	e8 33 fb ff ff       	call   800478 <printnum>
			break;
  800945:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  800948:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80094b:	83 c7 01             	add    $0x1,%edi
  80094e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800952:	83 f8 25             	cmp    $0x25,%eax
  800955:	0f 84 23 fc ff ff    	je     80057e <vprintfmt+0x1b>
			if (ch == '\0')
  80095b:	85 c0                	test   %eax,%eax
  80095d:	0f 84 8b 00 00 00    	je     8009ee <vprintfmt+0x48b>
			putch(ch, putdat);
  800963:	83 ec 08             	sub    $0x8,%esp
  800966:	53                   	push   %ebx
  800967:	50                   	push   %eax
  800968:	ff d6                	call   *%esi
  80096a:	83 c4 10             	add    $0x10,%esp
  80096d:	eb dc                	jmp    80094b <vprintfmt+0x3e8>
	if (lflag >= 2)
  80096f:	83 f9 01             	cmp    $0x1,%ecx
  800972:	7f 1b                	jg     80098f <vprintfmt+0x42c>
	else if (lflag)
  800974:	85 c9                	test   %ecx,%ecx
  800976:	74 2c                	je     8009a4 <vprintfmt+0x441>
		return va_arg(*ap, unsigned long);
  800978:	8b 45 14             	mov    0x14(%ebp),%eax
  80097b:	8b 10                	mov    (%eax),%edx
  80097d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800982:	8d 40 04             	lea    0x4(%eax),%eax
  800985:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800988:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  80098d:	eb 9f                	jmp    80092e <vprintfmt+0x3cb>
		return va_arg(*ap, unsigned long long);
  80098f:	8b 45 14             	mov    0x14(%ebp),%eax
  800992:	8b 10                	mov    (%eax),%edx
  800994:	8b 48 04             	mov    0x4(%eax),%ecx
  800997:	8d 40 08             	lea    0x8(%eax),%eax
  80099a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80099d:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  8009a2:	eb 8a                	jmp    80092e <vprintfmt+0x3cb>
		return va_arg(*ap, unsigned int);
  8009a4:	8b 45 14             	mov    0x14(%ebp),%eax
  8009a7:	8b 10                	mov    (%eax),%edx
  8009a9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8009ae:	8d 40 04             	lea    0x4(%eax),%eax
  8009b1:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8009b4:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  8009b9:	e9 70 ff ff ff       	jmp    80092e <vprintfmt+0x3cb>
			putch(ch, putdat);
  8009be:	83 ec 08             	sub    $0x8,%esp
  8009c1:	53                   	push   %ebx
  8009c2:	6a 25                	push   $0x25
  8009c4:	ff d6                	call   *%esi
			break;
  8009c6:	83 c4 10             	add    $0x10,%esp
  8009c9:	e9 7a ff ff ff       	jmp    800948 <vprintfmt+0x3e5>
			putch('%', putdat);
  8009ce:	83 ec 08             	sub    $0x8,%esp
  8009d1:	53                   	push   %ebx
  8009d2:	6a 25                	push   $0x25
  8009d4:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8009d6:	83 c4 10             	add    $0x10,%esp
  8009d9:	89 f8                	mov    %edi,%eax
  8009db:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8009df:	74 05                	je     8009e6 <vprintfmt+0x483>
  8009e1:	83 e8 01             	sub    $0x1,%eax
  8009e4:	eb f5                	jmp    8009db <vprintfmt+0x478>
  8009e6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8009e9:	e9 5a ff ff ff       	jmp    800948 <vprintfmt+0x3e5>
}
  8009ee:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8009f1:	5b                   	pop    %ebx
  8009f2:	5e                   	pop    %esi
  8009f3:	5f                   	pop    %edi
  8009f4:	5d                   	pop    %ebp
  8009f5:	c3                   	ret    

008009f6 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8009f6:	f3 0f 1e fb          	endbr32 
  8009fa:	55                   	push   %ebp
  8009fb:	89 e5                	mov    %esp,%ebp
  8009fd:	83 ec 18             	sub    $0x18,%esp
  800a00:	8b 45 08             	mov    0x8(%ebp),%eax
  800a03:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800a06:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800a09:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800a0d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800a10:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800a17:	85 c0                	test   %eax,%eax
  800a19:	74 26                	je     800a41 <vsnprintf+0x4b>
  800a1b:	85 d2                	test   %edx,%edx
  800a1d:	7e 22                	jle    800a41 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800a1f:	ff 75 14             	pushl  0x14(%ebp)
  800a22:	ff 75 10             	pushl  0x10(%ebp)
  800a25:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800a28:	50                   	push   %eax
  800a29:	68 21 05 80 00       	push   $0x800521
  800a2e:	e8 30 fb ff ff       	call   800563 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800a33:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800a36:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800a39:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800a3c:	83 c4 10             	add    $0x10,%esp
}
  800a3f:	c9                   	leave  
  800a40:	c3                   	ret    
		return -E_INVAL;
  800a41:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800a46:	eb f7                	jmp    800a3f <vsnprintf+0x49>

00800a48 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800a48:	f3 0f 1e fb          	endbr32 
  800a4c:	55                   	push   %ebp
  800a4d:	89 e5                	mov    %esp,%ebp
  800a4f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800a52:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800a55:	50                   	push   %eax
  800a56:	ff 75 10             	pushl  0x10(%ebp)
  800a59:	ff 75 0c             	pushl  0xc(%ebp)
  800a5c:	ff 75 08             	pushl  0x8(%ebp)
  800a5f:	e8 92 ff ff ff       	call   8009f6 <vsnprintf>
	va_end(ap);

	return rc;
}
  800a64:	c9                   	leave  
  800a65:	c3                   	ret    

00800a66 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800a66:	f3 0f 1e fb          	endbr32 
  800a6a:	55                   	push   %ebp
  800a6b:	89 e5                	mov    %esp,%ebp
  800a6d:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a70:	b8 00 00 00 00       	mov    $0x0,%eax
  800a75:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a79:	74 05                	je     800a80 <strlen+0x1a>
		n++;
  800a7b:	83 c0 01             	add    $0x1,%eax
  800a7e:	eb f5                	jmp    800a75 <strlen+0xf>
	return n;
}
  800a80:	5d                   	pop    %ebp
  800a81:	c3                   	ret    

00800a82 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a82:	f3 0f 1e fb          	endbr32 
  800a86:	55                   	push   %ebp
  800a87:	89 e5                	mov    %esp,%ebp
  800a89:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a8c:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a8f:	b8 00 00 00 00       	mov    $0x0,%eax
  800a94:	39 d0                	cmp    %edx,%eax
  800a96:	74 0d                	je     800aa5 <strnlen+0x23>
  800a98:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800a9c:	74 05                	je     800aa3 <strnlen+0x21>
		n++;
  800a9e:	83 c0 01             	add    $0x1,%eax
  800aa1:	eb f1                	jmp    800a94 <strnlen+0x12>
  800aa3:	89 c2                	mov    %eax,%edx
	return n;
}
  800aa5:	89 d0                	mov    %edx,%eax
  800aa7:	5d                   	pop    %ebp
  800aa8:	c3                   	ret    

00800aa9 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800aa9:	f3 0f 1e fb          	endbr32 
  800aad:	55                   	push   %ebp
  800aae:	89 e5                	mov    %esp,%ebp
  800ab0:	53                   	push   %ebx
  800ab1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ab4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800ab7:	b8 00 00 00 00       	mov    $0x0,%eax
  800abc:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800ac0:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800ac3:	83 c0 01             	add    $0x1,%eax
  800ac6:	84 d2                	test   %dl,%dl
  800ac8:	75 f2                	jne    800abc <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  800aca:	89 c8                	mov    %ecx,%eax
  800acc:	5b                   	pop    %ebx
  800acd:	5d                   	pop    %ebp
  800ace:	c3                   	ret    

00800acf <strcat>:

char *
strcat(char *dst, const char *src)
{
  800acf:	f3 0f 1e fb          	endbr32 
  800ad3:	55                   	push   %ebp
  800ad4:	89 e5                	mov    %esp,%ebp
  800ad6:	53                   	push   %ebx
  800ad7:	83 ec 10             	sub    $0x10,%esp
  800ada:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800add:	53                   	push   %ebx
  800ade:	e8 83 ff ff ff       	call   800a66 <strlen>
  800ae3:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800ae6:	ff 75 0c             	pushl  0xc(%ebp)
  800ae9:	01 d8                	add    %ebx,%eax
  800aeb:	50                   	push   %eax
  800aec:	e8 b8 ff ff ff       	call   800aa9 <strcpy>
	return dst;
}
  800af1:	89 d8                	mov    %ebx,%eax
  800af3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800af6:	c9                   	leave  
  800af7:	c3                   	ret    

00800af8 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800af8:	f3 0f 1e fb          	endbr32 
  800afc:	55                   	push   %ebp
  800afd:	89 e5                	mov    %esp,%ebp
  800aff:	56                   	push   %esi
  800b00:	53                   	push   %ebx
  800b01:	8b 75 08             	mov    0x8(%ebp),%esi
  800b04:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b07:	89 f3                	mov    %esi,%ebx
  800b09:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b0c:	89 f0                	mov    %esi,%eax
  800b0e:	39 d8                	cmp    %ebx,%eax
  800b10:	74 11                	je     800b23 <strncpy+0x2b>
		*dst++ = *src;
  800b12:	83 c0 01             	add    $0x1,%eax
  800b15:	0f b6 0a             	movzbl (%edx),%ecx
  800b18:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800b1b:	80 f9 01             	cmp    $0x1,%cl
  800b1e:	83 da ff             	sbb    $0xffffffff,%edx
  800b21:	eb eb                	jmp    800b0e <strncpy+0x16>
	}
	return ret;
}
  800b23:	89 f0                	mov    %esi,%eax
  800b25:	5b                   	pop    %ebx
  800b26:	5e                   	pop    %esi
  800b27:	5d                   	pop    %ebp
  800b28:	c3                   	ret    

00800b29 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800b29:	f3 0f 1e fb          	endbr32 
  800b2d:	55                   	push   %ebp
  800b2e:	89 e5                	mov    %esp,%ebp
  800b30:	56                   	push   %esi
  800b31:	53                   	push   %ebx
  800b32:	8b 75 08             	mov    0x8(%ebp),%esi
  800b35:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b38:	8b 55 10             	mov    0x10(%ebp),%edx
  800b3b:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800b3d:	85 d2                	test   %edx,%edx
  800b3f:	74 21                	je     800b62 <strlcpy+0x39>
  800b41:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800b45:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  800b47:	39 c2                	cmp    %eax,%edx
  800b49:	74 14                	je     800b5f <strlcpy+0x36>
  800b4b:	0f b6 19             	movzbl (%ecx),%ebx
  800b4e:	84 db                	test   %bl,%bl
  800b50:	74 0b                	je     800b5d <strlcpy+0x34>
			*dst++ = *src++;
  800b52:	83 c1 01             	add    $0x1,%ecx
  800b55:	83 c2 01             	add    $0x1,%edx
  800b58:	88 5a ff             	mov    %bl,-0x1(%edx)
  800b5b:	eb ea                	jmp    800b47 <strlcpy+0x1e>
  800b5d:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800b5f:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800b62:	29 f0                	sub    %esi,%eax
}
  800b64:	5b                   	pop    %ebx
  800b65:	5e                   	pop    %esi
  800b66:	5d                   	pop    %ebp
  800b67:	c3                   	ret    

00800b68 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800b68:	f3 0f 1e fb          	endbr32 
  800b6c:	55                   	push   %ebp
  800b6d:	89 e5                	mov    %esp,%ebp
  800b6f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b72:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800b75:	0f b6 01             	movzbl (%ecx),%eax
  800b78:	84 c0                	test   %al,%al
  800b7a:	74 0c                	je     800b88 <strcmp+0x20>
  800b7c:	3a 02                	cmp    (%edx),%al
  800b7e:	75 08                	jne    800b88 <strcmp+0x20>
		p++, q++;
  800b80:	83 c1 01             	add    $0x1,%ecx
  800b83:	83 c2 01             	add    $0x1,%edx
  800b86:	eb ed                	jmp    800b75 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800b88:	0f b6 c0             	movzbl %al,%eax
  800b8b:	0f b6 12             	movzbl (%edx),%edx
  800b8e:	29 d0                	sub    %edx,%eax
}
  800b90:	5d                   	pop    %ebp
  800b91:	c3                   	ret    

00800b92 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b92:	f3 0f 1e fb          	endbr32 
  800b96:	55                   	push   %ebp
  800b97:	89 e5                	mov    %esp,%ebp
  800b99:	53                   	push   %ebx
  800b9a:	8b 45 08             	mov    0x8(%ebp),%eax
  800b9d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ba0:	89 c3                	mov    %eax,%ebx
  800ba2:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800ba5:	eb 06                	jmp    800bad <strncmp+0x1b>
		n--, p++, q++;
  800ba7:	83 c0 01             	add    $0x1,%eax
  800baa:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800bad:	39 d8                	cmp    %ebx,%eax
  800baf:	74 16                	je     800bc7 <strncmp+0x35>
  800bb1:	0f b6 08             	movzbl (%eax),%ecx
  800bb4:	84 c9                	test   %cl,%cl
  800bb6:	74 04                	je     800bbc <strncmp+0x2a>
  800bb8:	3a 0a                	cmp    (%edx),%cl
  800bba:	74 eb                	je     800ba7 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800bbc:	0f b6 00             	movzbl (%eax),%eax
  800bbf:	0f b6 12             	movzbl (%edx),%edx
  800bc2:	29 d0                	sub    %edx,%eax
}
  800bc4:	5b                   	pop    %ebx
  800bc5:	5d                   	pop    %ebp
  800bc6:	c3                   	ret    
		return 0;
  800bc7:	b8 00 00 00 00       	mov    $0x0,%eax
  800bcc:	eb f6                	jmp    800bc4 <strncmp+0x32>

00800bce <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800bce:	f3 0f 1e fb          	endbr32 
  800bd2:	55                   	push   %ebp
  800bd3:	89 e5                	mov    %esp,%ebp
  800bd5:	8b 45 08             	mov    0x8(%ebp),%eax
  800bd8:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800bdc:	0f b6 10             	movzbl (%eax),%edx
  800bdf:	84 d2                	test   %dl,%dl
  800be1:	74 09                	je     800bec <strchr+0x1e>
		if (*s == c)
  800be3:	38 ca                	cmp    %cl,%dl
  800be5:	74 0a                	je     800bf1 <strchr+0x23>
	for (; *s; s++)
  800be7:	83 c0 01             	add    $0x1,%eax
  800bea:	eb f0                	jmp    800bdc <strchr+0xe>
			return (char *) s;
	return 0;
  800bec:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bf1:	5d                   	pop    %ebp
  800bf2:	c3                   	ret    

00800bf3 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800bf3:	f3 0f 1e fb          	endbr32 
  800bf7:	55                   	push   %ebp
  800bf8:	89 e5                	mov    %esp,%ebp
  800bfa:	8b 45 08             	mov    0x8(%ebp),%eax
  800bfd:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800c01:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800c04:	38 ca                	cmp    %cl,%dl
  800c06:	74 09                	je     800c11 <strfind+0x1e>
  800c08:	84 d2                	test   %dl,%dl
  800c0a:	74 05                	je     800c11 <strfind+0x1e>
	for (; *s; s++)
  800c0c:	83 c0 01             	add    $0x1,%eax
  800c0f:	eb f0                	jmp    800c01 <strfind+0xe>
			break;
	return (char *) s;
}
  800c11:	5d                   	pop    %ebp
  800c12:	c3                   	ret    

00800c13 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800c13:	f3 0f 1e fb          	endbr32 
  800c17:	55                   	push   %ebp
  800c18:	89 e5                	mov    %esp,%ebp
  800c1a:	57                   	push   %edi
  800c1b:	56                   	push   %esi
  800c1c:	53                   	push   %ebx
  800c1d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c20:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800c23:	85 c9                	test   %ecx,%ecx
  800c25:	74 31                	je     800c58 <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800c27:	89 f8                	mov    %edi,%eax
  800c29:	09 c8                	or     %ecx,%eax
  800c2b:	a8 03                	test   $0x3,%al
  800c2d:	75 23                	jne    800c52 <memset+0x3f>
		c &= 0xFF;
  800c2f:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800c33:	89 d3                	mov    %edx,%ebx
  800c35:	c1 e3 08             	shl    $0x8,%ebx
  800c38:	89 d0                	mov    %edx,%eax
  800c3a:	c1 e0 18             	shl    $0x18,%eax
  800c3d:	89 d6                	mov    %edx,%esi
  800c3f:	c1 e6 10             	shl    $0x10,%esi
  800c42:	09 f0                	or     %esi,%eax
  800c44:	09 c2                	or     %eax,%edx
  800c46:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800c48:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800c4b:	89 d0                	mov    %edx,%eax
  800c4d:	fc                   	cld    
  800c4e:	f3 ab                	rep stos %eax,%es:(%edi)
  800c50:	eb 06                	jmp    800c58 <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800c52:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c55:	fc                   	cld    
  800c56:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800c58:	89 f8                	mov    %edi,%eax
  800c5a:	5b                   	pop    %ebx
  800c5b:	5e                   	pop    %esi
  800c5c:	5f                   	pop    %edi
  800c5d:	5d                   	pop    %ebp
  800c5e:	c3                   	ret    

00800c5f <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800c5f:	f3 0f 1e fb          	endbr32 
  800c63:	55                   	push   %ebp
  800c64:	89 e5                	mov    %esp,%ebp
  800c66:	57                   	push   %edi
  800c67:	56                   	push   %esi
  800c68:	8b 45 08             	mov    0x8(%ebp),%eax
  800c6b:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c6e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800c71:	39 c6                	cmp    %eax,%esi
  800c73:	73 32                	jae    800ca7 <memmove+0x48>
  800c75:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c78:	39 c2                	cmp    %eax,%edx
  800c7a:	76 2b                	jbe    800ca7 <memmove+0x48>
		s += n;
		d += n;
  800c7c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c7f:	89 fe                	mov    %edi,%esi
  800c81:	09 ce                	or     %ecx,%esi
  800c83:	09 d6                	or     %edx,%esi
  800c85:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c8b:	75 0e                	jne    800c9b <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800c8d:	83 ef 04             	sub    $0x4,%edi
  800c90:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c93:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800c96:	fd                   	std    
  800c97:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c99:	eb 09                	jmp    800ca4 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800c9b:	83 ef 01             	sub    $0x1,%edi
  800c9e:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800ca1:	fd                   	std    
  800ca2:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ca4:	fc                   	cld    
  800ca5:	eb 1a                	jmp    800cc1 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ca7:	89 c2                	mov    %eax,%edx
  800ca9:	09 ca                	or     %ecx,%edx
  800cab:	09 f2                	or     %esi,%edx
  800cad:	f6 c2 03             	test   $0x3,%dl
  800cb0:	75 0a                	jne    800cbc <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800cb2:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800cb5:	89 c7                	mov    %eax,%edi
  800cb7:	fc                   	cld    
  800cb8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800cba:	eb 05                	jmp    800cc1 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800cbc:	89 c7                	mov    %eax,%edi
  800cbe:	fc                   	cld    
  800cbf:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800cc1:	5e                   	pop    %esi
  800cc2:	5f                   	pop    %edi
  800cc3:	5d                   	pop    %ebp
  800cc4:	c3                   	ret    

00800cc5 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800cc5:	f3 0f 1e fb          	endbr32 
  800cc9:	55                   	push   %ebp
  800cca:	89 e5                	mov    %esp,%ebp
  800ccc:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800ccf:	ff 75 10             	pushl  0x10(%ebp)
  800cd2:	ff 75 0c             	pushl  0xc(%ebp)
  800cd5:	ff 75 08             	pushl  0x8(%ebp)
  800cd8:	e8 82 ff ff ff       	call   800c5f <memmove>
}
  800cdd:	c9                   	leave  
  800cde:	c3                   	ret    

00800cdf <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800cdf:	f3 0f 1e fb          	endbr32 
  800ce3:	55                   	push   %ebp
  800ce4:	89 e5                	mov    %esp,%ebp
  800ce6:	56                   	push   %esi
  800ce7:	53                   	push   %ebx
  800ce8:	8b 45 08             	mov    0x8(%ebp),%eax
  800ceb:	8b 55 0c             	mov    0xc(%ebp),%edx
  800cee:	89 c6                	mov    %eax,%esi
  800cf0:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800cf3:	39 f0                	cmp    %esi,%eax
  800cf5:	74 1c                	je     800d13 <memcmp+0x34>
		if (*s1 != *s2)
  800cf7:	0f b6 08             	movzbl (%eax),%ecx
  800cfa:	0f b6 1a             	movzbl (%edx),%ebx
  800cfd:	38 d9                	cmp    %bl,%cl
  800cff:	75 08                	jne    800d09 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800d01:	83 c0 01             	add    $0x1,%eax
  800d04:	83 c2 01             	add    $0x1,%edx
  800d07:	eb ea                	jmp    800cf3 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800d09:	0f b6 c1             	movzbl %cl,%eax
  800d0c:	0f b6 db             	movzbl %bl,%ebx
  800d0f:	29 d8                	sub    %ebx,%eax
  800d11:	eb 05                	jmp    800d18 <memcmp+0x39>
	}

	return 0;
  800d13:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d18:	5b                   	pop    %ebx
  800d19:	5e                   	pop    %esi
  800d1a:	5d                   	pop    %ebp
  800d1b:	c3                   	ret    

00800d1c <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800d1c:	f3 0f 1e fb          	endbr32 
  800d20:	55                   	push   %ebp
  800d21:	89 e5                	mov    %esp,%ebp
  800d23:	8b 45 08             	mov    0x8(%ebp),%eax
  800d26:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800d29:	89 c2                	mov    %eax,%edx
  800d2b:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800d2e:	39 d0                	cmp    %edx,%eax
  800d30:	73 09                	jae    800d3b <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d32:	38 08                	cmp    %cl,(%eax)
  800d34:	74 05                	je     800d3b <memfind+0x1f>
	for (; s < ends; s++)
  800d36:	83 c0 01             	add    $0x1,%eax
  800d39:	eb f3                	jmp    800d2e <memfind+0x12>
			break;
	return (void *) s;
}
  800d3b:	5d                   	pop    %ebp
  800d3c:	c3                   	ret    

00800d3d <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800d3d:	f3 0f 1e fb          	endbr32 
  800d41:	55                   	push   %ebp
  800d42:	89 e5                	mov    %esp,%ebp
  800d44:	57                   	push   %edi
  800d45:	56                   	push   %esi
  800d46:	53                   	push   %ebx
  800d47:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d4a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d4d:	eb 03                	jmp    800d52 <strtol+0x15>
		s++;
  800d4f:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800d52:	0f b6 01             	movzbl (%ecx),%eax
  800d55:	3c 20                	cmp    $0x20,%al
  800d57:	74 f6                	je     800d4f <strtol+0x12>
  800d59:	3c 09                	cmp    $0x9,%al
  800d5b:	74 f2                	je     800d4f <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800d5d:	3c 2b                	cmp    $0x2b,%al
  800d5f:	74 2a                	je     800d8b <strtol+0x4e>
	int neg = 0;
  800d61:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800d66:	3c 2d                	cmp    $0x2d,%al
  800d68:	74 2b                	je     800d95 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d6a:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800d70:	75 0f                	jne    800d81 <strtol+0x44>
  800d72:	80 39 30             	cmpb   $0x30,(%ecx)
  800d75:	74 28                	je     800d9f <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800d77:	85 db                	test   %ebx,%ebx
  800d79:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d7e:	0f 44 d8             	cmove  %eax,%ebx
  800d81:	b8 00 00 00 00       	mov    $0x0,%eax
  800d86:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800d89:	eb 46                	jmp    800dd1 <strtol+0x94>
		s++;
  800d8b:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800d8e:	bf 00 00 00 00       	mov    $0x0,%edi
  800d93:	eb d5                	jmp    800d6a <strtol+0x2d>
		s++, neg = 1;
  800d95:	83 c1 01             	add    $0x1,%ecx
  800d98:	bf 01 00 00 00       	mov    $0x1,%edi
  800d9d:	eb cb                	jmp    800d6a <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d9f:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800da3:	74 0e                	je     800db3 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800da5:	85 db                	test   %ebx,%ebx
  800da7:	75 d8                	jne    800d81 <strtol+0x44>
		s++, base = 8;
  800da9:	83 c1 01             	add    $0x1,%ecx
  800dac:	bb 08 00 00 00       	mov    $0x8,%ebx
  800db1:	eb ce                	jmp    800d81 <strtol+0x44>
		s += 2, base = 16;
  800db3:	83 c1 02             	add    $0x2,%ecx
  800db6:	bb 10 00 00 00       	mov    $0x10,%ebx
  800dbb:	eb c4                	jmp    800d81 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800dbd:	0f be d2             	movsbl %dl,%edx
  800dc0:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800dc3:	3b 55 10             	cmp    0x10(%ebp),%edx
  800dc6:	7d 3a                	jge    800e02 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800dc8:	83 c1 01             	add    $0x1,%ecx
  800dcb:	0f af 45 10          	imul   0x10(%ebp),%eax
  800dcf:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800dd1:	0f b6 11             	movzbl (%ecx),%edx
  800dd4:	8d 72 d0             	lea    -0x30(%edx),%esi
  800dd7:	89 f3                	mov    %esi,%ebx
  800dd9:	80 fb 09             	cmp    $0x9,%bl
  800ddc:	76 df                	jbe    800dbd <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800dde:	8d 72 9f             	lea    -0x61(%edx),%esi
  800de1:	89 f3                	mov    %esi,%ebx
  800de3:	80 fb 19             	cmp    $0x19,%bl
  800de6:	77 08                	ja     800df0 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800de8:	0f be d2             	movsbl %dl,%edx
  800deb:	83 ea 57             	sub    $0x57,%edx
  800dee:	eb d3                	jmp    800dc3 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800df0:	8d 72 bf             	lea    -0x41(%edx),%esi
  800df3:	89 f3                	mov    %esi,%ebx
  800df5:	80 fb 19             	cmp    $0x19,%bl
  800df8:	77 08                	ja     800e02 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800dfa:	0f be d2             	movsbl %dl,%edx
  800dfd:	83 ea 37             	sub    $0x37,%edx
  800e00:	eb c1                	jmp    800dc3 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800e02:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800e06:	74 05                	je     800e0d <strtol+0xd0>
		*endptr = (char *) s;
  800e08:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e0b:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800e0d:	89 c2                	mov    %eax,%edx
  800e0f:	f7 da                	neg    %edx
  800e11:	85 ff                	test   %edi,%edi
  800e13:	0f 45 c2             	cmovne %edx,%eax
}
  800e16:	5b                   	pop    %ebx
  800e17:	5e                   	pop    %esi
  800e18:	5f                   	pop    %edi
  800e19:	5d                   	pop    %ebp
  800e1a:	c3                   	ret    

00800e1b <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800e1b:	f3 0f 1e fb          	endbr32 
  800e1f:	55                   	push   %ebp
  800e20:	89 e5                	mov    %esp,%ebp
  800e22:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  800e25:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  800e2c:	74 0a                	je     800e38 <set_pgfault_handler+0x1d>
        sys_env_set_pgfault_upcall(0, _pgfault_upcall);
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800e2e:	8b 45 08             	mov    0x8(%ebp),%eax
  800e31:	a3 08 20 80 00       	mov    %eax,0x802008
}
  800e36:	c9                   	leave  
  800e37:	c3                   	ret    
		if (sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P) < 0)
  800e38:	83 ec 04             	sub    $0x4,%esp
  800e3b:	6a 07                	push   $0x7
  800e3d:	68 00 f0 bf ee       	push   $0xeebff000
  800e42:	6a 00                	push   $0x0
  800e44:	e8 3f f3 ff ff       	call   800188 <sys_page_alloc>
  800e49:	83 c4 10             	add    $0x10,%esp
  800e4c:	85 c0                	test   %eax,%eax
  800e4e:	78 14                	js     800e64 <set_pgfault_handler+0x49>
        sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  800e50:	83 ec 08             	sub    $0x8,%esp
  800e53:	68 53 03 80 00       	push   $0x800353
  800e58:	6a 00                	push   $0x0
  800e5a:	e8 42 f4 ff ff       	call   8002a1 <sys_env_set_pgfault_upcall>
  800e5f:	83 c4 10             	add    $0x10,%esp
  800e62:	eb ca                	jmp    800e2e <set_pgfault_handler+0x13>
            panic("set_pgfault_handler failed.");
  800e64:	83 ec 04             	sub    $0x4,%esp
  800e67:	68 84 13 80 00       	push   $0x801384
  800e6c:	6a 21                	push   $0x21
  800e6e:	68 a0 13 80 00       	push   $0x8013a0
  800e73:	e8 01 f5 ff ff       	call   800379 <_panic>
  800e78:	66 90                	xchg   %ax,%ax
  800e7a:	66 90                	xchg   %ax,%ax
  800e7c:	66 90                	xchg   %ax,%ax
  800e7e:	66 90                	xchg   %ax,%ax

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
