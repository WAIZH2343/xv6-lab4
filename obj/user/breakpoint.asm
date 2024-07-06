
obj/user/breakpoint:     file format elf32-i386


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
  80002c:	e8 08 00 00 00       	call   800039 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	f3 0f 1e fb          	endbr32 
	asm volatile("int $3");
  800037:	cc                   	int3   
}
  800038:	c3                   	ret    

00800039 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800039:	f3 0f 1e fb          	endbr32 
  80003d:	55                   	push   %ebp
  80003e:	89 e5                	mov    %esp,%ebp
  800040:	56                   	push   %esi
  800041:	53                   	push   %ebx
  800042:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800045:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv=&envs[ENVX(sys_getenvid())];
  800048:	e8 d6 00 00 00       	call   800123 <sys_getenvid>
  80004d:	25 ff 03 00 00       	and    $0x3ff,%eax
  800052:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800055:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80005a:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80005f:	85 db                	test   %ebx,%ebx
  800061:	7e 07                	jle    80006a <libmain+0x31>
		binaryname = argv[0];
  800063:	8b 06                	mov    (%esi),%eax
  800065:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80006a:	83 ec 08             	sub    $0x8,%esp
  80006d:	56                   	push   %esi
  80006e:	53                   	push   %ebx
  80006f:	e8 bf ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800074:	e8 0a 00 00 00       	call   800083 <exit>
}
  800079:	83 c4 10             	add    $0x10,%esp
  80007c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80007f:	5b                   	pop    %ebx
  800080:	5e                   	pop    %esi
  800081:	5d                   	pop    %ebp
  800082:	c3                   	ret    

00800083 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800083:	f3 0f 1e fb          	endbr32 
  800087:	55                   	push   %ebp
  800088:	89 e5                	mov    %esp,%ebp
  80008a:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80008d:	6a 00                	push   $0x0
  80008f:	e8 4a 00 00 00       	call   8000de <sys_env_destroy>
}
  800094:	83 c4 10             	add    $0x10,%esp
  800097:	c9                   	leave  
  800098:	c3                   	ret    

00800099 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800099:	f3 0f 1e fb          	endbr32 
  80009d:	55                   	push   %ebp
  80009e:	89 e5                	mov    %esp,%ebp
  8000a0:	57                   	push   %edi
  8000a1:	56                   	push   %esi
  8000a2:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000a3:	b8 00 00 00 00       	mov    $0x0,%eax
  8000a8:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000ae:	89 c3                	mov    %eax,%ebx
  8000b0:	89 c7                	mov    %eax,%edi
  8000b2:	89 c6                	mov    %eax,%esi
  8000b4:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000b6:	5b                   	pop    %ebx
  8000b7:	5e                   	pop    %esi
  8000b8:	5f                   	pop    %edi
  8000b9:	5d                   	pop    %ebp
  8000ba:	c3                   	ret    

008000bb <sys_cgetc>:

int
sys_cgetc(void)
{
  8000bb:	f3 0f 1e fb          	endbr32 
  8000bf:	55                   	push   %ebp
  8000c0:	89 e5                	mov    %esp,%ebp
  8000c2:	57                   	push   %edi
  8000c3:	56                   	push   %esi
  8000c4:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000c5:	ba 00 00 00 00       	mov    $0x0,%edx
  8000ca:	b8 01 00 00 00       	mov    $0x1,%eax
  8000cf:	89 d1                	mov    %edx,%ecx
  8000d1:	89 d3                	mov    %edx,%ebx
  8000d3:	89 d7                	mov    %edx,%edi
  8000d5:	89 d6                	mov    %edx,%esi
  8000d7:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000d9:	5b                   	pop    %ebx
  8000da:	5e                   	pop    %esi
  8000db:	5f                   	pop    %edi
  8000dc:	5d                   	pop    %ebp
  8000dd:	c3                   	ret    

008000de <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000de:	f3 0f 1e fb          	endbr32 
  8000e2:	55                   	push   %ebp
  8000e3:	89 e5                	mov    %esp,%ebp
  8000e5:	57                   	push   %edi
  8000e6:	56                   	push   %esi
  8000e7:	53                   	push   %ebx
  8000e8:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8000eb:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000f0:	8b 55 08             	mov    0x8(%ebp),%edx
  8000f3:	b8 03 00 00 00       	mov    $0x3,%eax
  8000f8:	89 cb                	mov    %ecx,%ebx
  8000fa:	89 cf                	mov    %ecx,%edi
  8000fc:	89 ce                	mov    %ecx,%esi
  8000fe:	cd 30                	int    $0x30
	if(check && ret > 0)
  800100:	85 c0                	test   %eax,%eax
  800102:	7f 08                	jg     80010c <sys_env_destroy+0x2e>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800104:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800107:	5b                   	pop    %ebx
  800108:	5e                   	pop    %esi
  800109:	5f                   	pop    %edi
  80010a:	5d                   	pop    %ebp
  80010b:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80010c:	83 ec 0c             	sub    $0xc,%esp
  80010f:	50                   	push   %eax
  800110:	6a 03                	push   $0x3
  800112:	68 4a 10 80 00       	push   $0x80104a
  800117:	6a 23                	push   $0x23
  800119:	68 67 10 80 00       	push   $0x801067
  80011e:	e8 11 02 00 00       	call   800334 <_panic>

00800123 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800123:	f3 0f 1e fb          	endbr32 
  800127:	55                   	push   %ebp
  800128:	89 e5                	mov    %esp,%ebp
  80012a:	57                   	push   %edi
  80012b:	56                   	push   %esi
  80012c:	53                   	push   %ebx
	asm volatile("int %1\n"
  80012d:	ba 00 00 00 00       	mov    $0x0,%edx
  800132:	b8 02 00 00 00       	mov    $0x2,%eax
  800137:	89 d1                	mov    %edx,%ecx
  800139:	89 d3                	mov    %edx,%ebx
  80013b:	89 d7                	mov    %edx,%edi
  80013d:	89 d6                	mov    %edx,%esi
  80013f:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800141:	5b                   	pop    %ebx
  800142:	5e                   	pop    %esi
  800143:	5f                   	pop    %edi
  800144:	5d                   	pop    %ebp
  800145:	c3                   	ret    

00800146 <sys_yield>:

void
sys_yield(void)
{
  800146:	f3 0f 1e fb          	endbr32 
  80014a:	55                   	push   %ebp
  80014b:	89 e5                	mov    %esp,%ebp
  80014d:	57                   	push   %edi
  80014e:	56                   	push   %esi
  80014f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800150:	ba 00 00 00 00       	mov    $0x0,%edx
  800155:	b8 0a 00 00 00       	mov    $0xa,%eax
  80015a:	89 d1                	mov    %edx,%ecx
  80015c:	89 d3                	mov    %edx,%ebx
  80015e:	89 d7                	mov    %edx,%edi
  800160:	89 d6                	mov    %edx,%esi
  800162:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800164:	5b                   	pop    %ebx
  800165:	5e                   	pop    %esi
  800166:	5f                   	pop    %edi
  800167:	5d                   	pop    %ebp
  800168:	c3                   	ret    

00800169 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800169:	f3 0f 1e fb          	endbr32 
  80016d:	55                   	push   %ebp
  80016e:	89 e5                	mov    %esp,%ebp
  800170:	57                   	push   %edi
  800171:	56                   	push   %esi
  800172:	53                   	push   %ebx
  800173:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800176:	be 00 00 00 00       	mov    $0x0,%esi
  80017b:	8b 55 08             	mov    0x8(%ebp),%edx
  80017e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800181:	b8 04 00 00 00       	mov    $0x4,%eax
  800186:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800189:	89 f7                	mov    %esi,%edi
  80018b:	cd 30                	int    $0x30
	if(check && ret > 0)
  80018d:	85 c0                	test   %eax,%eax
  80018f:	7f 08                	jg     800199 <sys_page_alloc+0x30>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800191:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800194:	5b                   	pop    %ebx
  800195:	5e                   	pop    %esi
  800196:	5f                   	pop    %edi
  800197:	5d                   	pop    %ebp
  800198:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800199:	83 ec 0c             	sub    $0xc,%esp
  80019c:	50                   	push   %eax
  80019d:	6a 04                	push   $0x4
  80019f:	68 4a 10 80 00       	push   $0x80104a
  8001a4:	6a 23                	push   $0x23
  8001a6:	68 67 10 80 00       	push   $0x801067
  8001ab:	e8 84 01 00 00       	call   800334 <_panic>

008001b0 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001b0:	f3 0f 1e fb          	endbr32 
  8001b4:	55                   	push   %ebp
  8001b5:	89 e5                	mov    %esp,%ebp
  8001b7:	57                   	push   %edi
  8001b8:	56                   	push   %esi
  8001b9:	53                   	push   %ebx
  8001ba:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001bd:	8b 55 08             	mov    0x8(%ebp),%edx
  8001c0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001c3:	b8 05 00 00 00       	mov    $0x5,%eax
  8001c8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001cb:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001ce:	8b 75 18             	mov    0x18(%ebp),%esi
  8001d1:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001d3:	85 c0                	test   %eax,%eax
  8001d5:	7f 08                	jg     8001df <sys_page_map+0x2f>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001d7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001da:	5b                   	pop    %ebx
  8001db:	5e                   	pop    %esi
  8001dc:	5f                   	pop    %edi
  8001dd:	5d                   	pop    %ebp
  8001de:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8001df:	83 ec 0c             	sub    $0xc,%esp
  8001e2:	50                   	push   %eax
  8001e3:	6a 05                	push   $0x5
  8001e5:	68 4a 10 80 00       	push   $0x80104a
  8001ea:	6a 23                	push   $0x23
  8001ec:	68 67 10 80 00       	push   $0x801067
  8001f1:	e8 3e 01 00 00       	call   800334 <_panic>

008001f6 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001f6:	f3 0f 1e fb          	endbr32 
  8001fa:	55                   	push   %ebp
  8001fb:	89 e5                	mov    %esp,%ebp
  8001fd:	57                   	push   %edi
  8001fe:	56                   	push   %esi
  8001ff:	53                   	push   %ebx
  800200:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800203:	bb 00 00 00 00       	mov    $0x0,%ebx
  800208:	8b 55 08             	mov    0x8(%ebp),%edx
  80020b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80020e:	b8 06 00 00 00       	mov    $0x6,%eax
  800213:	89 df                	mov    %ebx,%edi
  800215:	89 de                	mov    %ebx,%esi
  800217:	cd 30                	int    $0x30
	if(check && ret > 0)
  800219:	85 c0                	test   %eax,%eax
  80021b:	7f 08                	jg     800225 <sys_page_unmap+0x2f>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80021d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800220:	5b                   	pop    %ebx
  800221:	5e                   	pop    %esi
  800222:	5f                   	pop    %edi
  800223:	5d                   	pop    %ebp
  800224:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800225:	83 ec 0c             	sub    $0xc,%esp
  800228:	50                   	push   %eax
  800229:	6a 06                	push   $0x6
  80022b:	68 4a 10 80 00       	push   $0x80104a
  800230:	6a 23                	push   $0x23
  800232:	68 67 10 80 00       	push   $0x801067
  800237:	e8 f8 00 00 00       	call   800334 <_panic>

0080023c <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80023c:	f3 0f 1e fb          	endbr32 
  800240:	55                   	push   %ebp
  800241:	89 e5                	mov    %esp,%ebp
  800243:	57                   	push   %edi
  800244:	56                   	push   %esi
  800245:	53                   	push   %ebx
  800246:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800249:	bb 00 00 00 00       	mov    $0x0,%ebx
  80024e:	8b 55 08             	mov    0x8(%ebp),%edx
  800251:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800254:	b8 08 00 00 00       	mov    $0x8,%eax
  800259:	89 df                	mov    %ebx,%edi
  80025b:	89 de                	mov    %ebx,%esi
  80025d:	cd 30                	int    $0x30
	if(check && ret > 0)
  80025f:	85 c0                	test   %eax,%eax
  800261:	7f 08                	jg     80026b <sys_env_set_status+0x2f>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800263:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800266:	5b                   	pop    %ebx
  800267:	5e                   	pop    %esi
  800268:	5f                   	pop    %edi
  800269:	5d                   	pop    %ebp
  80026a:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80026b:	83 ec 0c             	sub    $0xc,%esp
  80026e:	50                   	push   %eax
  80026f:	6a 08                	push   $0x8
  800271:	68 4a 10 80 00       	push   $0x80104a
  800276:	6a 23                	push   $0x23
  800278:	68 67 10 80 00       	push   $0x801067
  80027d:	e8 b2 00 00 00       	call   800334 <_panic>

00800282 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800282:	f3 0f 1e fb          	endbr32 
  800286:	55                   	push   %ebp
  800287:	89 e5                	mov    %esp,%ebp
  800289:	57                   	push   %edi
  80028a:	56                   	push   %esi
  80028b:	53                   	push   %ebx
  80028c:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80028f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800294:	8b 55 08             	mov    0x8(%ebp),%edx
  800297:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80029a:	b8 09 00 00 00       	mov    $0x9,%eax
  80029f:	89 df                	mov    %ebx,%edi
  8002a1:	89 de                	mov    %ebx,%esi
  8002a3:	cd 30                	int    $0x30
	if(check && ret > 0)
  8002a5:	85 c0                	test   %eax,%eax
  8002a7:	7f 08                	jg     8002b1 <sys_env_set_pgfault_upcall+0x2f>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002a9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002ac:	5b                   	pop    %ebx
  8002ad:	5e                   	pop    %esi
  8002ae:	5f                   	pop    %edi
  8002af:	5d                   	pop    %ebp
  8002b0:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8002b1:	83 ec 0c             	sub    $0xc,%esp
  8002b4:	50                   	push   %eax
  8002b5:	6a 09                	push   $0x9
  8002b7:	68 4a 10 80 00       	push   $0x80104a
  8002bc:	6a 23                	push   $0x23
  8002be:	68 67 10 80 00       	push   $0x801067
  8002c3:	e8 6c 00 00 00       	call   800334 <_panic>

008002c8 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002c8:	f3 0f 1e fb          	endbr32 
  8002cc:	55                   	push   %ebp
  8002cd:	89 e5                	mov    %esp,%ebp
  8002cf:	57                   	push   %edi
  8002d0:	56                   	push   %esi
  8002d1:	53                   	push   %ebx
	asm volatile("int %1\n"
  8002d2:	8b 55 08             	mov    0x8(%ebp),%edx
  8002d5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002d8:	b8 0b 00 00 00       	mov    $0xb,%eax
  8002dd:	be 00 00 00 00       	mov    $0x0,%esi
  8002e2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002e5:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002e8:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8002ea:	5b                   	pop    %ebx
  8002eb:	5e                   	pop    %esi
  8002ec:	5f                   	pop    %edi
  8002ed:	5d                   	pop    %ebp
  8002ee:	c3                   	ret    

008002ef <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8002ef:	f3 0f 1e fb          	endbr32 
  8002f3:	55                   	push   %ebp
  8002f4:	89 e5                	mov    %esp,%ebp
  8002f6:	57                   	push   %edi
  8002f7:	56                   	push   %esi
  8002f8:	53                   	push   %ebx
  8002f9:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8002fc:	b9 00 00 00 00       	mov    $0x0,%ecx
  800301:	8b 55 08             	mov    0x8(%ebp),%edx
  800304:	b8 0c 00 00 00       	mov    $0xc,%eax
  800309:	89 cb                	mov    %ecx,%ebx
  80030b:	89 cf                	mov    %ecx,%edi
  80030d:	89 ce                	mov    %ecx,%esi
  80030f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800311:	85 c0                	test   %eax,%eax
  800313:	7f 08                	jg     80031d <sys_ipc_recv+0x2e>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800315:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800318:	5b                   	pop    %ebx
  800319:	5e                   	pop    %esi
  80031a:	5f                   	pop    %edi
  80031b:	5d                   	pop    %ebp
  80031c:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80031d:	83 ec 0c             	sub    $0xc,%esp
  800320:	50                   	push   %eax
  800321:	6a 0c                	push   $0xc
  800323:	68 4a 10 80 00       	push   $0x80104a
  800328:	6a 23                	push   $0x23
  80032a:	68 67 10 80 00       	push   $0x801067
  80032f:	e8 00 00 00 00       	call   800334 <_panic>

00800334 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800334:	f3 0f 1e fb          	endbr32 
  800338:	55                   	push   %ebp
  800339:	89 e5                	mov    %esp,%ebp
  80033b:	56                   	push   %esi
  80033c:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80033d:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800340:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800346:	e8 d8 fd ff ff       	call   800123 <sys_getenvid>
  80034b:	83 ec 0c             	sub    $0xc,%esp
  80034e:	ff 75 0c             	pushl  0xc(%ebp)
  800351:	ff 75 08             	pushl  0x8(%ebp)
  800354:	56                   	push   %esi
  800355:	50                   	push   %eax
  800356:	68 78 10 80 00       	push   $0x801078
  80035b:	e8 bb 00 00 00       	call   80041b <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800360:	83 c4 18             	add    $0x18,%esp
  800363:	53                   	push   %ebx
  800364:	ff 75 10             	pushl  0x10(%ebp)
  800367:	e8 5a 00 00 00       	call   8003c6 <vcprintf>
	cprintf("\n");
  80036c:	c7 04 24 9b 10 80 00 	movl   $0x80109b,(%esp)
  800373:	e8 a3 00 00 00       	call   80041b <cprintf>
  800378:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80037b:	cc                   	int3   
  80037c:	eb fd                	jmp    80037b <_panic+0x47>

0080037e <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80037e:	f3 0f 1e fb          	endbr32 
  800382:	55                   	push   %ebp
  800383:	89 e5                	mov    %esp,%ebp
  800385:	53                   	push   %ebx
  800386:	83 ec 04             	sub    $0x4,%esp
  800389:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80038c:	8b 13                	mov    (%ebx),%edx
  80038e:	8d 42 01             	lea    0x1(%edx),%eax
  800391:	89 03                	mov    %eax,(%ebx)
  800393:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800396:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80039a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80039f:	74 09                	je     8003aa <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8003a1:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8003a5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8003a8:	c9                   	leave  
  8003a9:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8003aa:	83 ec 08             	sub    $0x8,%esp
  8003ad:	68 ff 00 00 00       	push   $0xff
  8003b2:	8d 43 08             	lea    0x8(%ebx),%eax
  8003b5:	50                   	push   %eax
  8003b6:	e8 de fc ff ff       	call   800099 <sys_cputs>
		b->idx = 0;
  8003bb:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8003c1:	83 c4 10             	add    $0x10,%esp
  8003c4:	eb db                	jmp    8003a1 <putch+0x23>

008003c6 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8003c6:	f3 0f 1e fb          	endbr32 
  8003ca:	55                   	push   %ebp
  8003cb:	89 e5                	mov    %esp,%ebp
  8003cd:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8003d3:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003da:	00 00 00 
	b.cnt = 0;
  8003dd:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003e4:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003e7:	ff 75 0c             	pushl  0xc(%ebp)
  8003ea:	ff 75 08             	pushl  0x8(%ebp)
  8003ed:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003f3:	50                   	push   %eax
  8003f4:	68 7e 03 80 00       	push   $0x80037e
  8003f9:	e8 20 01 00 00       	call   80051e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003fe:	83 c4 08             	add    $0x8,%esp
  800401:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800407:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80040d:	50                   	push   %eax
  80040e:	e8 86 fc ff ff       	call   800099 <sys_cputs>

	return b.cnt;
}
  800413:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800419:	c9                   	leave  
  80041a:	c3                   	ret    

0080041b <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80041b:	f3 0f 1e fb          	endbr32 
  80041f:	55                   	push   %ebp
  800420:	89 e5                	mov    %esp,%ebp
  800422:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800425:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800428:	50                   	push   %eax
  800429:	ff 75 08             	pushl  0x8(%ebp)
  80042c:	e8 95 ff ff ff       	call   8003c6 <vcprintf>
	va_end(ap);

	return cnt;
}
  800431:	c9                   	leave  
  800432:	c3                   	ret    

00800433 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800433:	55                   	push   %ebp
  800434:	89 e5                	mov    %esp,%ebp
  800436:	57                   	push   %edi
  800437:	56                   	push   %esi
  800438:	53                   	push   %ebx
  800439:	83 ec 1c             	sub    $0x1c,%esp
  80043c:	89 c7                	mov    %eax,%edi
  80043e:	89 d6                	mov    %edx,%esi
  800440:	8b 45 08             	mov    0x8(%ebp),%eax
  800443:	8b 55 0c             	mov    0xc(%ebp),%edx
  800446:	89 d1                	mov    %edx,%ecx
  800448:	89 c2                	mov    %eax,%edx
  80044a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80044d:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800450:	8b 45 10             	mov    0x10(%ebp),%eax
  800453:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800456:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800459:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800460:	39 c2                	cmp    %eax,%edx
  800462:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800465:	72 3e                	jb     8004a5 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800467:	83 ec 0c             	sub    $0xc,%esp
  80046a:	ff 75 18             	pushl  0x18(%ebp)
  80046d:	83 eb 01             	sub    $0x1,%ebx
  800470:	53                   	push   %ebx
  800471:	50                   	push   %eax
  800472:	83 ec 08             	sub    $0x8,%esp
  800475:	ff 75 e4             	pushl  -0x1c(%ebp)
  800478:	ff 75 e0             	pushl  -0x20(%ebp)
  80047b:	ff 75 dc             	pushl  -0x24(%ebp)
  80047e:	ff 75 d8             	pushl  -0x28(%ebp)
  800481:	e8 5a 09 00 00       	call   800de0 <__udivdi3>
  800486:	83 c4 18             	add    $0x18,%esp
  800489:	52                   	push   %edx
  80048a:	50                   	push   %eax
  80048b:	89 f2                	mov    %esi,%edx
  80048d:	89 f8                	mov    %edi,%eax
  80048f:	e8 9f ff ff ff       	call   800433 <printnum>
  800494:	83 c4 20             	add    $0x20,%esp
  800497:	eb 13                	jmp    8004ac <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800499:	83 ec 08             	sub    $0x8,%esp
  80049c:	56                   	push   %esi
  80049d:	ff 75 18             	pushl  0x18(%ebp)
  8004a0:	ff d7                	call   *%edi
  8004a2:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8004a5:	83 eb 01             	sub    $0x1,%ebx
  8004a8:	85 db                	test   %ebx,%ebx
  8004aa:	7f ed                	jg     800499 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8004ac:	83 ec 08             	sub    $0x8,%esp
  8004af:	56                   	push   %esi
  8004b0:	83 ec 04             	sub    $0x4,%esp
  8004b3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8004b6:	ff 75 e0             	pushl  -0x20(%ebp)
  8004b9:	ff 75 dc             	pushl  -0x24(%ebp)
  8004bc:	ff 75 d8             	pushl  -0x28(%ebp)
  8004bf:	e8 2c 0a 00 00       	call   800ef0 <__umoddi3>
  8004c4:	83 c4 14             	add    $0x14,%esp
  8004c7:	0f be 80 9d 10 80 00 	movsbl 0x80109d(%eax),%eax
  8004ce:	50                   	push   %eax
  8004cf:	ff d7                	call   *%edi
}
  8004d1:	83 c4 10             	add    $0x10,%esp
  8004d4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004d7:	5b                   	pop    %ebx
  8004d8:	5e                   	pop    %esi
  8004d9:	5f                   	pop    %edi
  8004da:	5d                   	pop    %ebp
  8004db:	c3                   	ret    

008004dc <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004dc:	f3 0f 1e fb          	endbr32 
  8004e0:	55                   	push   %ebp
  8004e1:	89 e5                	mov    %esp,%ebp
  8004e3:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004e6:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004ea:	8b 10                	mov    (%eax),%edx
  8004ec:	3b 50 04             	cmp    0x4(%eax),%edx
  8004ef:	73 0a                	jae    8004fb <sprintputch+0x1f>
		*b->buf++ = ch;
  8004f1:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004f4:	89 08                	mov    %ecx,(%eax)
  8004f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8004f9:	88 02                	mov    %al,(%edx)
}
  8004fb:	5d                   	pop    %ebp
  8004fc:	c3                   	ret    

008004fd <printfmt>:
{
  8004fd:	f3 0f 1e fb          	endbr32 
  800501:	55                   	push   %ebp
  800502:	89 e5                	mov    %esp,%ebp
  800504:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800507:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80050a:	50                   	push   %eax
  80050b:	ff 75 10             	pushl  0x10(%ebp)
  80050e:	ff 75 0c             	pushl  0xc(%ebp)
  800511:	ff 75 08             	pushl  0x8(%ebp)
  800514:	e8 05 00 00 00       	call   80051e <vprintfmt>
}
  800519:	83 c4 10             	add    $0x10,%esp
  80051c:	c9                   	leave  
  80051d:	c3                   	ret    

0080051e <vprintfmt>:
{
  80051e:	f3 0f 1e fb          	endbr32 
  800522:	55                   	push   %ebp
  800523:	89 e5                	mov    %esp,%ebp
  800525:	57                   	push   %edi
  800526:	56                   	push   %esi
  800527:	53                   	push   %ebx
  800528:	83 ec 3c             	sub    $0x3c,%esp
  80052b:	8b 75 08             	mov    0x8(%ebp),%esi
  80052e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800531:	8b 7d 10             	mov    0x10(%ebp),%edi
  800534:	e9 cd 03 00 00       	jmp    800906 <vprintfmt+0x3e8>
		padc = ' ';
  800539:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  80053d:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800544:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  80054b:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800552:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800557:	8d 47 01             	lea    0x1(%edi),%eax
  80055a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80055d:	0f b6 17             	movzbl (%edi),%edx
  800560:	8d 42 dd             	lea    -0x23(%edx),%eax
  800563:	3c 55                	cmp    $0x55,%al
  800565:	0f 87 1e 04 00 00    	ja     800989 <vprintfmt+0x46b>
  80056b:	0f b6 c0             	movzbl %al,%eax
  80056e:	3e ff 24 85 60 11 80 	notrack jmp *0x801160(,%eax,4)
  800575:	00 
  800576:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800579:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  80057d:	eb d8                	jmp    800557 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  80057f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800582:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  800586:	eb cf                	jmp    800557 <vprintfmt+0x39>
  800588:	0f b6 d2             	movzbl %dl,%edx
  80058b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  80058e:	b8 00 00 00 00       	mov    $0x0,%eax
  800593:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800596:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800599:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80059d:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8005a0:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8005a3:	83 f9 09             	cmp    $0x9,%ecx
  8005a6:	77 55                	ja     8005fd <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  8005a8:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8005ab:	eb e9                	jmp    800596 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  8005ad:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b0:	8b 00                	mov    (%eax),%eax
  8005b2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b8:	8d 40 04             	lea    0x4(%eax),%eax
  8005bb:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8005be:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8005c1:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005c5:	79 90                	jns    800557 <vprintfmt+0x39>
				width = precision, precision = -1;
  8005c7:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005ca:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005cd:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8005d4:	eb 81                	jmp    800557 <vprintfmt+0x39>
  8005d6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005d9:	85 c0                	test   %eax,%eax
  8005db:	ba 00 00 00 00       	mov    $0x0,%edx
  8005e0:	0f 49 d0             	cmovns %eax,%edx
  8005e3:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8005e6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8005e9:	e9 69 ff ff ff       	jmp    800557 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8005ee:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8005f1:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8005f8:	e9 5a ff ff ff       	jmp    800557 <vprintfmt+0x39>
  8005fd:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800600:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800603:	eb bc                	jmp    8005c1 <vprintfmt+0xa3>
			lflag++;
  800605:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800608:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80060b:	e9 47 ff ff ff       	jmp    800557 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  800610:	8b 45 14             	mov    0x14(%ebp),%eax
  800613:	8d 78 04             	lea    0x4(%eax),%edi
  800616:	83 ec 08             	sub    $0x8,%esp
  800619:	53                   	push   %ebx
  80061a:	ff 30                	pushl  (%eax)
  80061c:	ff d6                	call   *%esi
			break;
  80061e:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800621:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800624:	e9 da 02 00 00       	jmp    800903 <vprintfmt+0x3e5>
			err = va_arg(ap, int);
  800629:	8b 45 14             	mov    0x14(%ebp),%eax
  80062c:	8d 78 04             	lea    0x4(%eax),%edi
  80062f:	8b 00                	mov    (%eax),%eax
  800631:	99                   	cltd   
  800632:	31 d0                	xor    %edx,%eax
  800634:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800636:	83 f8 08             	cmp    $0x8,%eax
  800639:	7f 23                	jg     80065e <vprintfmt+0x140>
  80063b:	8b 14 85 c0 12 80 00 	mov    0x8012c0(,%eax,4),%edx
  800642:	85 d2                	test   %edx,%edx
  800644:	74 18                	je     80065e <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  800646:	52                   	push   %edx
  800647:	68 be 10 80 00       	push   $0x8010be
  80064c:	53                   	push   %ebx
  80064d:	56                   	push   %esi
  80064e:	e8 aa fe ff ff       	call   8004fd <printfmt>
  800653:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800656:	89 7d 14             	mov    %edi,0x14(%ebp)
  800659:	e9 a5 02 00 00       	jmp    800903 <vprintfmt+0x3e5>
				printfmt(putch, putdat, "error %d", err);
  80065e:	50                   	push   %eax
  80065f:	68 b5 10 80 00       	push   $0x8010b5
  800664:	53                   	push   %ebx
  800665:	56                   	push   %esi
  800666:	e8 92 fe ff ff       	call   8004fd <printfmt>
  80066b:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80066e:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800671:	e9 8d 02 00 00       	jmp    800903 <vprintfmt+0x3e5>
			if ((p = va_arg(ap, char *)) == NULL)
  800676:	8b 45 14             	mov    0x14(%ebp),%eax
  800679:	83 c0 04             	add    $0x4,%eax
  80067c:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80067f:	8b 45 14             	mov    0x14(%ebp),%eax
  800682:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  800684:	85 d2                	test   %edx,%edx
  800686:	b8 ae 10 80 00       	mov    $0x8010ae,%eax
  80068b:	0f 45 c2             	cmovne %edx,%eax
  80068e:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  800691:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800695:	7e 06                	jle    80069d <vprintfmt+0x17f>
  800697:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  80069b:	75 0d                	jne    8006aa <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  80069d:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8006a0:	89 c7                	mov    %eax,%edi
  8006a2:	03 45 e0             	add    -0x20(%ebp),%eax
  8006a5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006a8:	eb 55                	jmp    8006ff <vprintfmt+0x1e1>
  8006aa:	83 ec 08             	sub    $0x8,%esp
  8006ad:	ff 75 d8             	pushl  -0x28(%ebp)
  8006b0:	ff 75 cc             	pushl  -0x34(%ebp)
  8006b3:	e8 85 03 00 00       	call   800a3d <strnlen>
  8006b8:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8006bb:	29 c2                	sub    %eax,%edx
  8006bd:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  8006c0:	83 c4 10             	add    $0x10,%esp
  8006c3:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  8006c5:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8006c9:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8006cc:	85 ff                	test   %edi,%edi
  8006ce:	7e 11                	jle    8006e1 <vprintfmt+0x1c3>
					putch(padc, putdat);
  8006d0:	83 ec 08             	sub    $0x8,%esp
  8006d3:	53                   	push   %ebx
  8006d4:	ff 75 e0             	pushl  -0x20(%ebp)
  8006d7:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8006d9:	83 ef 01             	sub    $0x1,%edi
  8006dc:	83 c4 10             	add    $0x10,%esp
  8006df:	eb eb                	jmp    8006cc <vprintfmt+0x1ae>
  8006e1:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8006e4:	85 d2                	test   %edx,%edx
  8006e6:	b8 00 00 00 00       	mov    $0x0,%eax
  8006eb:	0f 49 c2             	cmovns %edx,%eax
  8006ee:	29 c2                	sub    %eax,%edx
  8006f0:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8006f3:	eb a8                	jmp    80069d <vprintfmt+0x17f>
					putch(ch, putdat);
  8006f5:	83 ec 08             	sub    $0x8,%esp
  8006f8:	53                   	push   %ebx
  8006f9:	52                   	push   %edx
  8006fa:	ff d6                	call   *%esi
  8006fc:	83 c4 10             	add    $0x10,%esp
  8006ff:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800702:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800704:	83 c7 01             	add    $0x1,%edi
  800707:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80070b:	0f be d0             	movsbl %al,%edx
  80070e:	85 d2                	test   %edx,%edx
  800710:	74 4b                	je     80075d <vprintfmt+0x23f>
  800712:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800716:	78 06                	js     80071e <vprintfmt+0x200>
  800718:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  80071c:	78 1e                	js     80073c <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
  80071e:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800722:	74 d1                	je     8006f5 <vprintfmt+0x1d7>
  800724:	0f be c0             	movsbl %al,%eax
  800727:	83 e8 20             	sub    $0x20,%eax
  80072a:	83 f8 5e             	cmp    $0x5e,%eax
  80072d:	76 c6                	jbe    8006f5 <vprintfmt+0x1d7>
					putch('?', putdat);
  80072f:	83 ec 08             	sub    $0x8,%esp
  800732:	53                   	push   %ebx
  800733:	6a 3f                	push   $0x3f
  800735:	ff d6                	call   *%esi
  800737:	83 c4 10             	add    $0x10,%esp
  80073a:	eb c3                	jmp    8006ff <vprintfmt+0x1e1>
  80073c:	89 cf                	mov    %ecx,%edi
  80073e:	eb 0e                	jmp    80074e <vprintfmt+0x230>
				putch(' ', putdat);
  800740:	83 ec 08             	sub    $0x8,%esp
  800743:	53                   	push   %ebx
  800744:	6a 20                	push   $0x20
  800746:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800748:	83 ef 01             	sub    $0x1,%edi
  80074b:	83 c4 10             	add    $0x10,%esp
  80074e:	85 ff                	test   %edi,%edi
  800750:	7f ee                	jg     800740 <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  800752:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800755:	89 45 14             	mov    %eax,0x14(%ebp)
  800758:	e9 a6 01 00 00       	jmp    800903 <vprintfmt+0x3e5>
  80075d:	89 cf                	mov    %ecx,%edi
  80075f:	eb ed                	jmp    80074e <vprintfmt+0x230>
	if (lflag >= 2)
  800761:	83 f9 01             	cmp    $0x1,%ecx
  800764:	7f 1f                	jg     800785 <vprintfmt+0x267>
	else if (lflag)
  800766:	85 c9                	test   %ecx,%ecx
  800768:	74 67                	je     8007d1 <vprintfmt+0x2b3>
		return va_arg(*ap, long);
  80076a:	8b 45 14             	mov    0x14(%ebp),%eax
  80076d:	8b 00                	mov    (%eax),%eax
  80076f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800772:	89 c1                	mov    %eax,%ecx
  800774:	c1 f9 1f             	sar    $0x1f,%ecx
  800777:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80077a:	8b 45 14             	mov    0x14(%ebp),%eax
  80077d:	8d 40 04             	lea    0x4(%eax),%eax
  800780:	89 45 14             	mov    %eax,0x14(%ebp)
  800783:	eb 17                	jmp    80079c <vprintfmt+0x27e>
		return va_arg(*ap, long long);
  800785:	8b 45 14             	mov    0x14(%ebp),%eax
  800788:	8b 50 04             	mov    0x4(%eax),%edx
  80078b:	8b 00                	mov    (%eax),%eax
  80078d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800790:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800793:	8b 45 14             	mov    0x14(%ebp),%eax
  800796:	8d 40 08             	lea    0x8(%eax),%eax
  800799:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80079c:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80079f:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8007a2:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  8007a7:	85 c9                	test   %ecx,%ecx
  8007a9:	0f 89 3a 01 00 00    	jns    8008e9 <vprintfmt+0x3cb>
				putch('-', putdat);
  8007af:	83 ec 08             	sub    $0x8,%esp
  8007b2:	53                   	push   %ebx
  8007b3:	6a 2d                	push   $0x2d
  8007b5:	ff d6                	call   *%esi
				num = -(long long) num;
  8007b7:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007ba:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8007bd:	f7 da                	neg    %edx
  8007bf:	83 d1 00             	adc    $0x0,%ecx
  8007c2:	f7 d9                	neg    %ecx
  8007c4:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8007c7:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007cc:	e9 18 01 00 00       	jmp    8008e9 <vprintfmt+0x3cb>
		return va_arg(*ap, int);
  8007d1:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d4:	8b 00                	mov    (%eax),%eax
  8007d6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007d9:	89 c1                	mov    %eax,%ecx
  8007db:	c1 f9 1f             	sar    $0x1f,%ecx
  8007de:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8007e1:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e4:	8d 40 04             	lea    0x4(%eax),%eax
  8007e7:	89 45 14             	mov    %eax,0x14(%ebp)
  8007ea:	eb b0                	jmp    80079c <vprintfmt+0x27e>
	if (lflag >= 2)
  8007ec:	83 f9 01             	cmp    $0x1,%ecx
  8007ef:	7f 1e                	jg     80080f <vprintfmt+0x2f1>
	else if (lflag)
  8007f1:	85 c9                	test   %ecx,%ecx
  8007f3:	74 32                	je     800827 <vprintfmt+0x309>
		return va_arg(*ap, unsigned long);
  8007f5:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f8:	8b 10                	mov    (%eax),%edx
  8007fa:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007ff:	8d 40 04             	lea    0x4(%eax),%eax
  800802:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800805:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  80080a:	e9 da 00 00 00       	jmp    8008e9 <vprintfmt+0x3cb>
		return va_arg(*ap, unsigned long long);
  80080f:	8b 45 14             	mov    0x14(%ebp),%eax
  800812:	8b 10                	mov    (%eax),%edx
  800814:	8b 48 04             	mov    0x4(%eax),%ecx
  800817:	8d 40 08             	lea    0x8(%eax),%eax
  80081a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80081d:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  800822:	e9 c2 00 00 00       	jmp    8008e9 <vprintfmt+0x3cb>
		return va_arg(*ap, unsigned int);
  800827:	8b 45 14             	mov    0x14(%ebp),%eax
  80082a:	8b 10                	mov    (%eax),%edx
  80082c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800831:	8d 40 04             	lea    0x4(%eax),%eax
  800834:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800837:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  80083c:	e9 a8 00 00 00       	jmp    8008e9 <vprintfmt+0x3cb>
	if (lflag >= 2)
  800841:	83 f9 01             	cmp    $0x1,%ecx
  800844:	7f 1b                	jg     800861 <vprintfmt+0x343>
	else if (lflag)
  800846:	85 c9                	test   %ecx,%ecx
  800848:	74 5c                	je     8008a6 <vprintfmt+0x388>
		return va_arg(*ap, long);
  80084a:	8b 45 14             	mov    0x14(%ebp),%eax
  80084d:	8b 00                	mov    (%eax),%eax
  80084f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800852:	99                   	cltd   
  800853:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800856:	8b 45 14             	mov    0x14(%ebp),%eax
  800859:	8d 40 04             	lea    0x4(%eax),%eax
  80085c:	89 45 14             	mov    %eax,0x14(%ebp)
  80085f:	eb 17                	jmp    800878 <vprintfmt+0x35a>
		return va_arg(*ap, long long);
  800861:	8b 45 14             	mov    0x14(%ebp),%eax
  800864:	8b 50 04             	mov    0x4(%eax),%edx
  800867:	8b 00                	mov    (%eax),%eax
  800869:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80086c:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80086f:	8b 45 14             	mov    0x14(%ebp),%eax
  800872:	8d 40 08             	lea    0x8(%eax),%eax
  800875:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800878:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80087b:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 8;
  80087e:	b8 08 00 00 00       	mov    $0x8,%eax
			if ((long long) num < 0) {
  800883:	85 c9                	test   %ecx,%ecx
  800885:	79 62                	jns    8008e9 <vprintfmt+0x3cb>
				putch('-', putdat);
  800887:	83 ec 08             	sub    $0x8,%esp
  80088a:	53                   	push   %ebx
  80088b:	6a 2d                	push   $0x2d
  80088d:	ff d6                	call   *%esi
				num = -(long long) num;
  80088f:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800892:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800895:	f7 da                	neg    %edx
  800897:	83 d1 00             	adc    $0x0,%ecx
  80089a:	f7 d9                	neg    %ecx
  80089c:	83 c4 10             	add    $0x10,%esp
			base = 8;
  80089f:	b8 08 00 00 00       	mov    $0x8,%eax
  8008a4:	eb 43                	jmp    8008e9 <vprintfmt+0x3cb>
		return va_arg(*ap, int);
  8008a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8008a9:	8b 00                	mov    (%eax),%eax
  8008ab:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8008ae:	89 c1                	mov    %eax,%ecx
  8008b0:	c1 f9 1f             	sar    $0x1f,%ecx
  8008b3:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8008b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8008b9:	8d 40 04             	lea    0x4(%eax),%eax
  8008bc:	89 45 14             	mov    %eax,0x14(%ebp)
  8008bf:	eb b7                	jmp    800878 <vprintfmt+0x35a>
			putch('0', putdat);
  8008c1:	83 ec 08             	sub    $0x8,%esp
  8008c4:	53                   	push   %ebx
  8008c5:	6a 30                	push   $0x30
  8008c7:	ff d6                	call   *%esi
			putch('x', putdat);
  8008c9:	83 c4 08             	add    $0x8,%esp
  8008cc:	53                   	push   %ebx
  8008cd:	6a 78                	push   $0x78
  8008cf:	ff d6                	call   *%esi
			num = (unsigned long long)
  8008d1:	8b 45 14             	mov    0x14(%ebp),%eax
  8008d4:	8b 10                	mov    (%eax),%edx
  8008d6:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8008db:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8008de:	8d 40 04             	lea    0x4(%eax),%eax
  8008e1:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8008e4:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  8008e9:	83 ec 0c             	sub    $0xc,%esp
  8008ec:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  8008f0:	57                   	push   %edi
  8008f1:	ff 75 e0             	pushl  -0x20(%ebp)
  8008f4:	50                   	push   %eax
  8008f5:	51                   	push   %ecx
  8008f6:	52                   	push   %edx
  8008f7:	89 da                	mov    %ebx,%edx
  8008f9:	89 f0                	mov    %esi,%eax
  8008fb:	e8 33 fb ff ff       	call   800433 <printnum>
			break;
  800900:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  800903:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800906:	83 c7 01             	add    $0x1,%edi
  800909:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80090d:	83 f8 25             	cmp    $0x25,%eax
  800910:	0f 84 23 fc ff ff    	je     800539 <vprintfmt+0x1b>
			if (ch == '\0')
  800916:	85 c0                	test   %eax,%eax
  800918:	0f 84 8b 00 00 00    	je     8009a9 <vprintfmt+0x48b>
			putch(ch, putdat);
  80091e:	83 ec 08             	sub    $0x8,%esp
  800921:	53                   	push   %ebx
  800922:	50                   	push   %eax
  800923:	ff d6                	call   *%esi
  800925:	83 c4 10             	add    $0x10,%esp
  800928:	eb dc                	jmp    800906 <vprintfmt+0x3e8>
	if (lflag >= 2)
  80092a:	83 f9 01             	cmp    $0x1,%ecx
  80092d:	7f 1b                	jg     80094a <vprintfmt+0x42c>
	else if (lflag)
  80092f:	85 c9                	test   %ecx,%ecx
  800931:	74 2c                	je     80095f <vprintfmt+0x441>
		return va_arg(*ap, unsigned long);
  800933:	8b 45 14             	mov    0x14(%ebp),%eax
  800936:	8b 10                	mov    (%eax),%edx
  800938:	b9 00 00 00 00       	mov    $0x0,%ecx
  80093d:	8d 40 04             	lea    0x4(%eax),%eax
  800940:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800943:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  800948:	eb 9f                	jmp    8008e9 <vprintfmt+0x3cb>
		return va_arg(*ap, unsigned long long);
  80094a:	8b 45 14             	mov    0x14(%ebp),%eax
  80094d:	8b 10                	mov    (%eax),%edx
  80094f:	8b 48 04             	mov    0x4(%eax),%ecx
  800952:	8d 40 08             	lea    0x8(%eax),%eax
  800955:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800958:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  80095d:	eb 8a                	jmp    8008e9 <vprintfmt+0x3cb>
		return va_arg(*ap, unsigned int);
  80095f:	8b 45 14             	mov    0x14(%ebp),%eax
  800962:	8b 10                	mov    (%eax),%edx
  800964:	b9 00 00 00 00       	mov    $0x0,%ecx
  800969:	8d 40 04             	lea    0x4(%eax),%eax
  80096c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80096f:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  800974:	e9 70 ff ff ff       	jmp    8008e9 <vprintfmt+0x3cb>
			putch(ch, putdat);
  800979:	83 ec 08             	sub    $0x8,%esp
  80097c:	53                   	push   %ebx
  80097d:	6a 25                	push   $0x25
  80097f:	ff d6                	call   *%esi
			break;
  800981:	83 c4 10             	add    $0x10,%esp
  800984:	e9 7a ff ff ff       	jmp    800903 <vprintfmt+0x3e5>
			putch('%', putdat);
  800989:	83 ec 08             	sub    $0x8,%esp
  80098c:	53                   	push   %ebx
  80098d:	6a 25                	push   $0x25
  80098f:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800991:	83 c4 10             	add    $0x10,%esp
  800994:	89 f8                	mov    %edi,%eax
  800996:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80099a:	74 05                	je     8009a1 <vprintfmt+0x483>
  80099c:	83 e8 01             	sub    $0x1,%eax
  80099f:	eb f5                	jmp    800996 <vprintfmt+0x478>
  8009a1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8009a4:	e9 5a ff ff ff       	jmp    800903 <vprintfmt+0x3e5>
}
  8009a9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8009ac:	5b                   	pop    %ebx
  8009ad:	5e                   	pop    %esi
  8009ae:	5f                   	pop    %edi
  8009af:	5d                   	pop    %ebp
  8009b0:	c3                   	ret    

008009b1 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8009b1:	f3 0f 1e fb          	endbr32 
  8009b5:	55                   	push   %ebp
  8009b6:	89 e5                	mov    %esp,%ebp
  8009b8:	83 ec 18             	sub    $0x18,%esp
  8009bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8009be:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8009c1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8009c4:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8009c8:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8009cb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8009d2:	85 c0                	test   %eax,%eax
  8009d4:	74 26                	je     8009fc <vsnprintf+0x4b>
  8009d6:	85 d2                	test   %edx,%edx
  8009d8:	7e 22                	jle    8009fc <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8009da:	ff 75 14             	pushl  0x14(%ebp)
  8009dd:	ff 75 10             	pushl  0x10(%ebp)
  8009e0:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8009e3:	50                   	push   %eax
  8009e4:	68 dc 04 80 00       	push   $0x8004dc
  8009e9:	e8 30 fb ff ff       	call   80051e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8009ee:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8009f1:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8009f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009f7:	83 c4 10             	add    $0x10,%esp
}
  8009fa:	c9                   	leave  
  8009fb:	c3                   	ret    
		return -E_INVAL;
  8009fc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800a01:	eb f7                	jmp    8009fa <vsnprintf+0x49>

00800a03 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800a03:	f3 0f 1e fb          	endbr32 
  800a07:	55                   	push   %ebp
  800a08:	89 e5                	mov    %esp,%ebp
  800a0a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800a0d:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800a10:	50                   	push   %eax
  800a11:	ff 75 10             	pushl  0x10(%ebp)
  800a14:	ff 75 0c             	pushl  0xc(%ebp)
  800a17:	ff 75 08             	pushl  0x8(%ebp)
  800a1a:	e8 92 ff ff ff       	call   8009b1 <vsnprintf>
	va_end(ap);

	return rc;
}
  800a1f:	c9                   	leave  
  800a20:	c3                   	ret    

00800a21 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800a21:	f3 0f 1e fb          	endbr32 
  800a25:	55                   	push   %ebp
  800a26:	89 e5                	mov    %esp,%ebp
  800a28:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a2b:	b8 00 00 00 00       	mov    $0x0,%eax
  800a30:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a34:	74 05                	je     800a3b <strlen+0x1a>
		n++;
  800a36:	83 c0 01             	add    $0x1,%eax
  800a39:	eb f5                	jmp    800a30 <strlen+0xf>
	return n;
}
  800a3b:	5d                   	pop    %ebp
  800a3c:	c3                   	ret    

00800a3d <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a3d:	f3 0f 1e fb          	endbr32 
  800a41:	55                   	push   %ebp
  800a42:	89 e5                	mov    %esp,%ebp
  800a44:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a47:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a4a:	b8 00 00 00 00       	mov    $0x0,%eax
  800a4f:	39 d0                	cmp    %edx,%eax
  800a51:	74 0d                	je     800a60 <strnlen+0x23>
  800a53:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800a57:	74 05                	je     800a5e <strnlen+0x21>
		n++;
  800a59:	83 c0 01             	add    $0x1,%eax
  800a5c:	eb f1                	jmp    800a4f <strnlen+0x12>
  800a5e:	89 c2                	mov    %eax,%edx
	return n;
}
  800a60:	89 d0                	mov    %edx,%eax
  800a62:	5d                   	pop    %ebp
  800a63:	c3                   	ret    

00800a64 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a64:	f3 0f 1e fb          	endbr32 
  800a68:	55                   	push   %ebp
  800a69:	89 e5                	mov    %esp,%ebp
  800a6b:	53                   	push   %ebx
  800a6c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a6f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a72:	b8 00 00 00 00       	mov    $0x0,%eax
  800a77:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800a7b:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800a7e:	83 c0 01             	add    $0x1,%eax
  800a81:	84 d2                	test   %dl,%dl
  800a83:	75 f2                	jne    800a77 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  800a85:	89 c8                	mov    %ecx,%eax
  800a87:	5b                   	pop    %ebx
  800a88:	5d                   	pop    %ebp
  800a89:	c3                   	ret    

00800a8a <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a8a:	f3 0f 1e fb          	endbr32 
  800a8e:	55                   	push   %ebp
  800a8f:	89 e5                	mov    %esp,%ebp
  800a91:	53                   	push   %ebx
  800a92:	83 ec 10             	sub    $0x10,%esp
  800a95:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a98:	53                   	push   %ebx
  800a99:	e8 83 ff ff ff       	call   800a21 <strlen>
  800a9e:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800aa1:	ff 75 0c             	pushl  0xc(%ebp)
  800aa4:	01 d8                	add    %ebx,%eax
  800aa6:	50                   	push   %eax
  800aa7:	e8 b8 ff ff ff       	call   800a64 <strcpy>
	return dst;
}
  800aac:	89 d8                	mov    %ebx,%eax
  800aae:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ab1:	c9                   	leave  
  800ab2:	c3                   	ret    

00800ab3 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800ab3:	f3 0f 1e fb          	endbr32 
  800ab7:	55                   	push   %ebp
  800ab8:	89 e5                	mov    %esp,%ebp
  800aba:	56                   	push   %esi
  800abb:	53                   	push   %ebx
  800abc:	8b 75 08             	mov    0x8(%ebp),%esi
  800abf:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ac2:	89 f3                	mov    %esi,%ebx
  800ac4:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800ac7:	89 f0                	mov    %esi,%eax
  800ac9:	39 d8                	cmp    %ebx,%eax
  800acb:	74 11                	je     800ade <strncpy+0x2b>
		*dst++ = *src;
  800acd:	83 c0 01             	add    $0x1,%eax
  800ad0:	0f b6 0a             	movzbl (%edx),%ecx
  800ad3:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800ad6:	80 f9 01             	cmp    $0x1,%cl
  800ad9:	83 da ff             	sbb    $0xffffffff,%edx
  800adc:	eb eb                	jmp    800ac9 <strncpy+0x16>
	}
	return ret;
}
  800ade:	89 f0                	mov    %esi,%eax
  800ae0:	5b                   	pop    %ebx
  800ae1:	5e                   	pop    %esi
  800ae2:	5d                   	pop    %ebp
  800ae3:	c3                   	ret    

00800ae4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800ae4:	f3 0f 1e fb          	endbr32 
  800ae8:	55                   	push   %ebp
  800ae9:	89 e5                	mov    %esp,%ebp
  800aeb:	56                   	push   %esi
  800aec:	53                   	push   %ebx
  800aed:	8b 75 08             	mov    0x8(%ebp),%esi
  800af0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800af3:	8b 55 10             	mov    0x10(%ebp),%edx
  800af6:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800af8:	85 d2                	test   %edx,%edx
  800afa:	74 21                	je     800b1d <strlcpy+0x39>
  800afc:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800b00:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  800b02:	39 c2                	cmp    %eax,%edx
  800b04:	74 14                	je     800b1a <strlcpy+0x36>
  800b06:	0f b6 19             	movzbl (%ecx),%ebx
  800b09:	84 db                	test   %bl,%bl
  800b0b:	74 0b                	je     800b18 <strlcpy+0x34>
			*dst++ = *src++;
  800b0d:	83 c1 01             	add    $0x1,%ecx
  800b10:	83 c2 01             	add    $0x1,%edx
  800b13:	88 5a ff             	mov    %bl,-0x1(%edx)
  800b16:	eb ea                	jmp    800b02 <strlcpy+0x1e>
  800b18:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800b1a:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800b1d:	29 f0                	sub    %esi,%eax
}
  800b1f:	5b                   	pop    %ebx
  800b20:	5e                   	pop    %esi
  800b21:	5d                   	pop    %ebp
  800b22:	c3                   	ret    

00800b23 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800b23:	f3 0f 1e fb          	endbr32 
  800b27:	55                   	push   %ebp
  800b28:	89 e5                	mov    %esp,%ebp
  800b2a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b2d:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800b30:	0f b6 01             	movzbl (%ecx),%eax
  800b33:	84 c0                	test   %al,%al
  800b35:	74 0c                	je     800b43 <strcmp+0x20>
  800b37:	3a 02                	cmp    (%edx),%al
  800b39:	75 08                	jne    800b43 <strcmp+0x20>
		p++, q++;
  800b3b:	83 c1 01             	add    $0x1,%ecx
  800b3e:	83 c2 01             	add    $0x1,%edx
  800b41:	eb ed                	jmp    800b30 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800b43:	0f b6 c0             	movzbl %al,%eax
  800b46:	0f b6 12             	movzbl (%edx),%edx
  800b49:	29 d0                	sub    %edx,%eax
}
  800b4b:	5d                   	pop    %ebp
  800b4c:	c3                   	ret    

00800b4d <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b4d:	f3 0f 1e fb          	endbr32 
  800b51:	55                   	push   %ebp
  800b52:	89 e5                	mov    %esp,%ebp
  800b54:	53                   	push   %ebx
  800b55:	8b 45 08             	mov    0x8(%ebp),%eax
  800b58:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b5b:	89 c3                	mov    %eax,%ebx
  800b5d:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800b60:	eb 06                	jmp    800b68 <strncmp+0x1b>
		n--, p++, q++;
  800b62:	83 c0 01             	add    $0x1,%eax
  800b65:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800b68:	39 d8                	cmp    %ebx,%eax
  800b6a:	74 16                	je     800b82 <strncmp+0x35>
  800b6c:	0f b6 08             	movzbl (%eax),%ecx
  800b6f:	84 c9                	test   %cl,%cl
  800b71:	74 04                	je     800b77 <strncmp+0x2a>
  800b73:	3a 0a                	cmp    (%edx),%cl
  800b75:	74 eb                	je     800b62 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b77:	0f b6 00             	movzbl (%eax),%eax
  800b7a:	0f b6 12             	movzbl (%edx),%edx
  800b7d:	29 d0                	sub    %edx,%eax
}
  800b7f:	5b                   	pop    %ebx
  800b80:	5d                   	pop    %ebp
  800b81:	c3                   	ret    
		return 0;
  800b82:	b8 00 00 00 00       	mov    $0x0,%eax
  800b87:	eb f6                	jmp    800b7f <strncmp+0x32>

00800b89 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b89:	f3 0f 1e fb          	endbr32 
  800b8d:	55                   	push   %ebp
  800b8e:	89 e5                	mov    %esp,%ebp
  800b90:	8b 45 08             	mov    0x8(%ebp),%eax
  800b93:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b97:	0f b6 10             	movzbl (%eax),%edx
  800b9a:	84 d2                	test   %dl,%dl
  800b9c:	74 09                	je     800ba7 <strchr+0x1e>
		if (*s == c)
  800b9e:	38 ca                	cmp    %cl,%dl
  800ba0:	74 0a                	je     800bac <strchr+0x23>
	for (; *s; s++)
  800ba2:	83 c0 01             	add    $0x1,%eax
  800ba5:	eb f0                	jmp    800b97 <strchr+0xe>
			return (char *) s;
	return 0;
  800ba7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bac:	5d                   	pop    %ebp
  800bad:	c3                   	ret    

00800bae <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800bae:	f3 0f 1e fb          	endbr32 
  800bb2:	55                   	push   %ebp
  800bb3:	89 e5                	mov    %esp,%ebp
  800bb5:	8b 45 08             	mov    0x8(%ebp),%eax
  800bb8:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800bbc:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800bbf:	38 ca                	cmp    %cl,%dl
  800bc1:	74 09                	je     800bcc <strfind+0x1e>
  800bc3:	84 d2                	test   %dl,%dl
  800bc5:	74 05                	je     800bcc <strfind+0x1e>
	for (; *s; s++)
  800bc7:	83 c0 01             	add    $0x1,%eax
  800bca:	eb f0                	jmp    800bbc <strfind+0xe>
			break;
	return (char *) s;
}
  800bcc:	5d                   	pop    %ebp
  800bcd:	c3                   	ret    

00800bce <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800bce:	f3 0f 1e fb          	endbr32 
  800bd2:	55                   	push   %ebp
  800bd3:	89 e5                	mov    %esp,%ebp
  800bd5:	57                   	push   %edi
  800bd6:	56                   	push   %esi
  800bd7:	53                   	push   %ebx
  800bd8:	8b 7d 08             	mov    0x8(%ebp),%edi
  800bdb:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800bde:	85 c9                	test   %ecx,%ecx
  800be0:	74 31                	je     800c13 <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800be2:	89 f8                	mov    %edi,%eax
  800be4:	09 c8                	or     %ecx,%eax
  800be6:	a8 03                	test   $0x3,%al
  800be8:	75 23                	jne    800c0d <memset+0x3f>
		c &= 0xFF;
  800bea:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800bee:	89 d3                	mov    %edx,%ebx
  800bf0:	c1 e3 08             	shl    $0x8,%ebx
  800bf3:	89 d0                	mov    %edx,%eax
  800bf5:	c1 e0 18             	shl    $0x18,%eax
  800bf8:	89 d6                	mov    %edx,%esi
  800bfa:	c1 e6 10             	shl    $0x10,%esi
  800bfd:	09 f0                	or     %esi,%eax
  800bff:	09 c2                	or     %eax,%edx
  800c01:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800c03:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800c06:	89 d0                	mov    %edx,%eax
  800c08:	fc                   	cld    
  800c09:	f3 ab                	rep stos %eax,%es:(%edi)
  800c0b:	eb 06                	jmp    800c13 <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800c0d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c10:	fc                   	cld    
  800c11:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800c13:	89 f8                	mov    %edi,%eax
  800c15:	5b                   	pop    %ebx
  800c16:	5e                   	pop    %esi
  800c17:	5f                   	pop    %edi
  800c18:	5d                   	pop    %ebp
  800c19:	c3                   	ret    

00800c1a <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800c1a:	f3 0f 1e fb          	endbr32 
  800c1e:	55                   	push   %ebp
  800c1f:	89 e5                	mov    %esp,%ebp
  800c21:	57                   	push   %edi
  800c22:	56                   	push   %esi
  800c23:	8b 45 08             	mov    0x8(%ebp),%eax
  800c26:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c29:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800c2c:	39 c6                	cmp    %eax,%esi
  800c2e:	73 32                	jae    800c62 <memmove+0x48>
  800c30:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c33:	39 c2                	cmp    %eax,%edx
  800c35:	76 2b                	jbe    800c62 <memmove+0x48>
		s += n;
		d += n;
  800c37:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c3a:	89 fe                	mov    %edi,%esi
  800c3c:	09 ce                	or     %ecx,%esi
  800c3e:	09 d6                	or     %edx,%esi
  800c40:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c46:	75 0e                	jne    800c56 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800c48:	83 ef 04             	sub    $0x4,%edi
  800c4b:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c4e:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800c51:	fd                   	std    
  800c52:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c54:	eb 09                	jmp    800c5f <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800c56:	83 ef 01             	sub    $0x1,%edi
  800c59:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800c5c:	fd                   	std    
  800c5d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c5f:	fc                   	cld    
  800c60:	eb 1a                	jmp    800c7c <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c62:	89 c2                	mov    %eax,%edx
  800c64:	09 ca                	or     %ecx,%edx
  800c66:	09 f2                	or     %esi,%edx
  800c68:	f6 c2 03             	test   $0x3,%dl
  800c6b:	75 0a                	jne    800c77 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800c6d:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800c70:	89 c7                	mov    %eax,%edi
  800c72:	fc                   	cld    
  800c73:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c75:	eb 05                	jmp    800c7c <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800c77:	89 c7                	mov    %eax,%edi
  800c79:	fc                   	cld    
  800c7a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c7c:	5e                   	pop    %esi
  800c7d:	5f                   	pop    %edi
  800c7e:	5d                   	pop    %ebp
  800c7f:	c3                   	ret    

00800c80 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c80:	f3 0f 1e fb          	endbr32 
  800c84:	55                   	push   %ebp
  800c85:	89 e5                	mov    %esp,%ebp
  800c87:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800c8a:	ff 75 10             	pushl  0x10(%ebp)
  800c8d:	ff 75 0c             	pushl  0xc(%ebp)
  800c90:	ff 75 08             	pushl  0x8(%ebp)
  800c93:	e8 82 ff ff ff       	call   800c1a <memmove>
}
  800c98:	c9                   	leave  
  800c99:	c3                   	ret    

00800c9a <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c9a:	f3 0f 1e fb          	endbr32 
  800c9e:	55                   	push   %ebp
  800c9f:	89 e5                	mov    %esp,%ebp
  800ca1:	56                   	push   %esi
  800ca2:	53                   	push   %ebx
  800ca3:	8b 45 08             	mov    0x8(%ebp),%eax
  800ca6:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ca9:	89 c6                	mov    %eax,%esi
  800cab:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800cae:	39 f0                	cmp    %esi,%eax
  800cb0:	74 1c                	je     800cce <memcmp+0x34>
		if (*s1 != *s2)
  800cb2:	0f b6 08             	movzbl (%eax),%ecx
  800cb5:	0f b6 1a             	movzbl (%edx),%ebx
  800cb8:	38 d9                	cmp    %bl,%cl
  800cba:	75 08                	jne    800cc4 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800cbc:	83 c0 01             	add    $0x1,%eax
  800cbf:	83 c2 01             	add    $0x1,%edx
  800cc2:	eb ea                	jmp    800cae <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800cc4:	0f b6 c1             	movzbl %cl,%eax
  800cc7:	0f b6 db             	movzbl %bl,%ebx
  800cca:	29 d8                	sub    %ebx,%eax
  800ccc:	eb 05                	jmp    800cd3 <memcmp+0x39>
	}

	return 0;
  800cce:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800cd3:	5b                   	pop    %ebx
  800cd4:	5e                   	pop    %esi
  800cd5:	5d                   	pop    %ebp
  800cd6:	c3                   	ret    

00800cd7 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800cd7:	f3 0f 1e fb          	endbr32 
  800cdb:	55                   	push   %ebp
  800cdc:	89 e5                	mov    %esp,%ebp
  800cde:	8b 45 08             	mov    0x8(%ebp),%eax
  800ce1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800ce4:	89 c2                	mov    %eax,%edx
  800ce6:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800ce9:	39 d0                	cmp    %edx,%eax
  800ceb:	73 09                	jae    800cf6 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ced:	38 08                	cmp    %cl,(%eax)
  800cef:	74 05                	je     800cf6 <memfind+0x1f>
	for (; s < ends; s++)
  800cf1:	83 c0 01             	add    $0x1,%eax
  800cf4:	eb f3                	jmp    800ce9 <memfind+0x12>
			break;
	return (void *) s;
}
  800cf6:	5d                   	pop    %ebp
  800cf7:	c3                   	ret    

00800cf8 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800cf8:	f3 0f 1e fb          	endbr32 
  800cfc:	55                   	push   %ebp
  800cfd:	89 e5                	mov    %esp,%ebp
  800cff:	57                   	push   %edi
  800d00:	56                   	push   %esi
  800d01:	53                   	push   %ebx
  800d02:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d05:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d08:	eb 03                	jmp    800d0d <strtol+0x15>
		s++;
  800d0a:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800d0d:	0f b6 01             	movzbl (%ecx),%eax
  800d10:	3c 20                	cmp    $0x20,%al
  800d12:	74 f6                	je     800d0a <strtol+0x12>
  800d14:	3c 09                	cmp    $0x9,%al
  800d16:	74 f2                	je     800d0a <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800d18:	3c 2b                	cmp    $0x2b,%al
  800d1a:	74 2a                	je     800d46 <strtol+0x4e>
	int neg = 0;
  800d1c:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800d21:	3c 2d                	cmp    $0x2d,%al
  800d23:	74 2b                	je     800d50 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d25:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800d2b:	75 0f                	jne    800d3c <strtol+0x44>
  800d2d:	80 39 30             	cmpb   $0x30,(%ecx)
  800d30:	74 28                	je     800d5a <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800d32:	85 db                	test   %ebx,%ebx
  800d34:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d39:	0f 44 d8             	cmove  %eax,%ebx
  800d3c:	b8 00 00 00 00       	mov    $0x0,%eax
  800d41:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800d44:	eb 46                	jmp    800d8c <strtol+0x94>
		s++;
  800d46:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800d49:	bf 00 00 00 00       	mov    $0x0,%edi
  800d4e:	eb d5                	jmp    800d25 <strtol+0x2d>
		s++, neg = 1;
  800d50:	83 c1 01             	add    $0x1,%ecx
  800d53:	bf 01 00 00 00       	mov    $0x1,%edi
  800d58:	eb cb                	jmp    800d25 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d5a:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800d5e:	74 0e                	je     800d6e <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800d60:	85 db                	test   %ebx,%ebx
  800d62:	75 d8                	jne    800d3c <strtol+0x44>
		s++, base = 8;
  800d64:	83 c1 01             	add    $0x1,%ecx
  800d67:	bb 08 00 00 00       	mov    $0x8,%ebx
  800d6c:	eb ce                	jmp    800d3c <strtol+0x44>
		s += 2, base = 16;
  800d6e:	83 c1 02             	add    $0x2,%ecx
  800d71:	bb 10 00 00 00       	mov    $0x10,%ebx
  800d76:	eb c4                	jmp    800d3c <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800d78:	0f be d2             	movsbl %dl,%edx
  800d7b:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800d7e:	3b 55 10             	cmp    0x10(%ebp),%edx
  800d81:	7d 3a                	jge    800dbd <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800d83:	83 c1 01             	add    $0x1,%ecx
  800d86:	0f af 45 10          	imul   0x10(%ebp),%eax
  800d8a:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800d8c:	0f b6 11             	movzbl (%ecx),%edx
  800d8f:	8d 72 d0             	lea    -0x30(%edx),%esi
  800d92:	89 f3                	mov    %esi,%ebx
  800d94:	80 fb 09             	cmp    $0x9,%bl
  800d97:	76 df                	jbe    800d78 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800d99:	8d 72 9f             	lea    -0x61(%edx),%esi
  800d9c:	89 f3                	mov    %esi,%ebx
  800d9e:	80 fb 19             	cmp    $0x19,%bl
  800da1:	77 08                	ja     800dab <strtol+0xb3>
			dig = *s - 'a' + 10;
  800da3:	0f be d2             	movsbl %dl,%edx
  800da6:	83 ea 57             	sub    $0x57,%edx
  800da9:	eb d3                	jmp    800d7e <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800dab:	8d 72 bf             	lea    -0x41(%edx),%esi
  800dae:	89 f3                	mov    %esi,%ebx
  800db0:	80 fb 19             	cmp    $0x19,%bl
  800db3:	77 08                	ja     800dbd <strtol+0xc5>
			dig = *s - 'A' + 10;
  800db5:	0f be d2             	movsbl %dl,%edx
  800db8:	83 ea 37             	sub    $0x37,%edx
  800dbb:	eb c1                	jmp    800d7e <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800dbd:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800dc1:	74 05                	je     800dc8 <strtol+0xd0>
		*endptr = (char *) s;
  800dc3:	8b 75 0c             	mov    0xc(%ebp),%esi
  800dc6:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800dc8:	89 c2                	mov    %eax,%edx
  800dca:	f7 da                	neg    %edx
  800dcc:	85 ff                	test   %edi,%edi
  800dce:	0f 45 c2             	cmovne %edx,%eax
}
  800dd1:	5b                   	pop    %ebx
  800dd2:	5e                   	pop    %esi
  800dd3:	5f                   	pop    %edi
  800dd4:	5d                   	pop    %ebp
  800dd5:	c3                   	ret    
  800dd6:	66 90                	xchg   %ax,%ax
  800dd8:	66 90                	xchg   %ax,%ax
  800dda:	66 90                	xchg   %ax,%ax
  800ddc:	66 90                	xchg   %ax,%ax
  800dde:	66 90                	xchg   %ax,%ax

00800de0 <__udivdi3>:
  800de0:	f3 0f 1e fb          	endbr32 
  800de4:	55                   	push   %ebp
  800de5:	57                   	push   %edi
  800de6:	56                   	push   %esi
  800de7:	53                   	push   %ebx
  800de8:	83 ec 1c             	sub    $0x1c,%esp
  800deb:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800def:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800df3:	8b 74 24 34          	mov    0x34(%esp),%esi
  800df7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800dfb:	85 d2                	test   %edx,%edx
  800dfd:	75 19                	jne    800e18 <__udivdi3+0x38>
  800dff:	39 f3                	cmp    %esi,%ebx
  800e01:	76 4d                	jbe    800e50 <__udivdi3+0x70>
  800e03:	31 ff                	xor    %edi,%edi
  800e05:	89 e8                	mov    %ebp,%eax
  800e07:	89 f2                	mov    %esi,%edx
  800e09:	f7 f3                	div    %ebx
  800e0b:	89 fa                	mov    %edi,%edx
  800e0d:	83 c4 1c             	add    $0x1c,%esp
  800e10:	5b                   	pop    %ebx
  800e11:	5e                   	pop    %esi
  800e12:	5f                   	pop    %edi
  800e13:	5d                   	pop    %ebp
  800e14:	c3                   	ret    
  800e15:	8d 76 00             	lea    0x0(%esi),%esi
  800e18:	39 f2                	cmp    %esi,%edx
  800e1a:	76 14                	jbe    800e30 <__udivdi3+0x50>
  800e1c:	31 ff                	xor    %edi,%edi
  800e1e:	31 c0                	xor    %eax,%eax
  800e20:	89 fa                	mov    %edi,%edx
  800e22:	83 c4 1c             	add    $0x1c,%esp
  800e25:	5b                   	pop    %ebx
  800e26:	5e                   	pop    %esi
  800e27:	5f                   	pop    %edi
  800e28:	5d                   	pop    %ebp
  800e29:	c3                   	ret    
  800e2a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800e30:	0f bd fa             	bsr    %edx,%edi
  800e33:	83 f7 1f             	xor    $0x1f,%edi
  800e36:	75 48                	jne    800e80 <__udivdi3+0xa0>
  800e38:	39 f2                	cmp    %esi,%edx
  800e3a:	72 06                	jb     800e42 <__udivdi3+0x62>
  800e3c:	31 c0                	xor    %eax,%eax
  800e3e:	39 eb                	cmp    %ebp,%ebx
  800e40:	77 de                	ja     800e20 <__udivdi3+0x40>
  800e42:	b8 01 00 00 00       	mov    $0x1,%eax
  800e47:	eb d7                	jmp    800e20 <__udivdi3+0x40>
  800e49:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e50:	89 d9                	mov    %ebx,%ecx
  800e52:	85 db                	test   %ebx,%ebx
  800e54:	75 0b                	jne    800e61 <__udivdi3+0x81>
  800e56:	b8 01 00 00 00       	mov    $0x1,%eax
  800e5b:	31 d2                	xor    %edx,%edx
  800e5d:	f7 f3                	div    %ebx
  800e5f:	89 c1                	mov    %eax,%ecx
  800e61:	31 d2                	xor    %edx,%edx
  800e63:	89 f0                	mov    %esi,%eax
  800e65:	f7 f1                	div    %ecx
  800e67:	89 c6                	mov    %eax,%esi
  800e69:	89 e8                	mov    %ebp,%eax
  800e6b:	89 f7                	mov    %esi,%edi
  800e6d:	f7 f1                	div    %ecx
  800e6f:	89 fa                	mov    %edi,%edx
  800e71:	83 c4 1c             	add    $0x1c,%esp
  800e74:	5b                   	pop    %ebx
  800e75:	5e                   	pop    %esi
  800e76:	5f                   	pop    %edi
  800e77:	5d                   	pop    %ebp
  800e78:	c3                   	ret    
  800e79:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e80:	89 f9                	mov    %edi,%ecx
  800e82:	b8 20 00 00 00       	mov    $0x20,%eax
  800e87:	29 f8                	sub    %edi,%eax
  800e89:	d3 e2                	shl    %cl,%edx
  800e8b:	89 54 24 08          	mov    %edx,0x8(%esp)
  800e8f:	89 c1                	mov    %eax,%ecx
  800e91:	89 da                	mov    %ebx,%edx
  800e93:	d3 ea                	shr    %cl,%edx
  800e95:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800e99:	09 d1                	or     %edx,%ecx
  800e9b:	89 f2                	mov    %esi,%edx
  800e9d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800ea1:	89 f9                	mov    %edi,%ecx
  800ea3:	d3 e3                	shl    %cl,%ebx
  800ea5:	89 c1                	mov    %eax,%ecx
  800ea7:	d3 ea                	shr    %cl,%edx
  800ea9:	89 f9                	mov    %edi,%ecx
  800eab:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800eaf:	89 eb                	mov    %ebp,%ebx
  800eb1:	d3 e6                	shl    %cl,%esi
  800eb3:	89 c1                	mov    %eax,%ecx
  800eb5:	d3 eb                	shr    %cl,%ebx
  800eb7:	09 de                	or     %ebx,%esi
  800eb9:	89 f0                	mov    %esi,%eax
  800ebb:	f7 74 24 08          	divl   0x8(%esp)
  800ebf:	89 d6                	mov    %edx,%esi
  800ec1:	89 c3                	mov    %eax,%ebx
  800ec3:	f7 64 24 0c          	mull   0xc(%esp)
  800ec7:	39 d6                	cmp    %edx,%esi
  800ec9:	72 15                	jb     800ee0 <__udivdi3+0x100>
  800ecb:	89 f9                	mov    %edi,%ecx
  800ecd:	d3 e5                	shl    %cl,%ebp
  800ecf:	39 c5                	cmp    %eax,%ebp
  800ed1:	73 04                	jae    800ed7 <__udivdi3+0xf7>
  800ed3:	39 d6                	cmp    %edx,%esi
  800ed5:	74 09                	je     800ee0 <__udivdi3+0x100>
  800ed7:	89 d8                	mov    %ebx,%eax
  800ed9:	31 ff                	xor    %edi,%edi
  800edb:	e9 40 ff ff ff       	jmp    800e20 <__udivdi3+0x40>
  800ee0:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800ee3:	31 ff                	xor    %edi,%edi
  800ee5:	e9 36 ff ff ff       	jmp    800e20 <__udivdi3+0x40>
  800eea:	66 90                	xchg   %ax,%ax
  800eec:	66 90                	xchg   %ax,%ax
  800eee:	66 90                	xchg   %ax,%ax

00800ef0 <__umoddi3>:
  800ef0:	f3 0f 1e fb          	endbr32 
  800ef4:	55                   	push   %ebp
  800ef5:	57                   	push   %edi
  800ef6:	56                   	push   %esi
  800ef7:	53                   	push   %ebx
  800ef8:	83 ec 1c             	sub    $0x1c,%esp
  800efb:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  800eff:	8b 74 24 30          	mov    0x30(%esp),%esi
  800f03:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800f07:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800f0b:	85 c0                	test   %eax,%eax
  800f0d:	75 19                	jne    800f28 <__umoddi3+0x38>
  800f0f:	39 df                	cmp    %ebx,%edi
  800f11:	76 5d                	jbe    800f70 <__umoddi3+0x80>
  800f13:	89 f0                	mov    %esi,%eax
  800f15:	89 da                	mov    %ebx,%edx
  800f17:	f7 f7                	div    %edi
  800f19:	89 d0                	mov    %edx,%eax
  800f1b:	31 d2                	xor    %edx,%edx
  800f1d:	83 c4 1c             	add    $0x1c,%esp
  800f20:	5b                   	pop    %ebx
  800f21:	5e                   	pop    %esi
  800f22:	5f                   	pop    %edi
  800f23:	5d                   	pop    %ebp
  800f24:	c3                   	ret    
  800f25:	8d 76 00             	lea    0x0(%esi),%esi
  800f28:	89 f2                	mov    %esi,%edx
  800f2a:	39 d8                	cmp    %ebx,%eax
  800f2c:	76 12                	jbe    800f40 <__umoddi3+0x50>
  800f2e:	89 f0                	mov    %esi,%eax
  800f30:	89 da                	mov    %ebx,%edx
  800f32:	83 c4 1c             	add    $0x1c,%esp
  800f35:	5b                   	pop    %ebx
  800f36:	5e                   	pop    %esi
  800f37:	5f                   	pop    %edi
  800f38:	5d                   	pop    %ebp
  800f39:	c3                   	ret    
  800f3a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800f40:	0f bd e8             	bsr    %eax,%ebp
  800f43:	83 f5 1f             	xor    $0x1f,%ebp
  800f46:	75 50                	jne    800f98 <__umoddi3+0xa8>
  800f48:	39 d8                	cmp    %ebx,%eax
  800f4a:	0f 82 e0 00 00 00    	jb     801030 <__umoddi3+0x140>
  800f50:	89 d9                	mov    %ebx,%ecx
  800f52:	39 f7                	cmp    %esi,%edi
  800f54:	0f 86 d6 00 00 00    	jbe    801030 <__umoddi3+0x140>
  800f5a:	89 d0                	mov    %edx,%eax
  800f5c:	89 ca                	mov    %ecx,%edx
  800f5e:	83 c4 1c             	add    $0x1c,%esp
  800f61:	5b                   	pop    %ebx
  800f62:	5e                   	pop    %esi
  800f63:	5f                   	pop    %edi
  800f64:	5d                   	pop    %ebp
  800f65:	c3                   	ret    
  800f66:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f6d:	8d 76 00             	lea    0x0(%esi),%esi
  800f70:	89 fd                	mov    %edi,%ebp
  800f72:	85 ff                	test   %edi,%edi
  800f74:	75 0b                	jne    800f81 <__umoddi3+0x91>
  800f76:	b8 01 00 00 00       	mov    $0x1,%eax
  800f7b:	31 d2                	xor    %edx,%edx
  800f7d:	f7 f7                	div    %edi
  800f7f:	89 c5                	mov    %eax,%ebp
  800f81:	89 d8                	mov    %ebx,%eax
  800f83:	31 d2                	xor    %edx,%edx
  800f85:	f7 f5                	div    %ebp
  800f87:	89 f0                	mov    %esi,%eax
  800f89:	f7 f5                	div    %ebp
  800f8b:	89 d0                	mov    %edx,%eax
  800f8d:	31 d2                	xor    %edx,%edx
  800f8f:	eb 8c                	jmp    800f1d <__umoddi3+0x2d>
  800f91:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f98:	89 e9                	mov    %ebp,%ecx
  800f9a:	ba 20 00 00 00       	mov    $0x20,%edx
  800f9f:	29 ea                	sub    %ebp,%edx
  800fa1:	d3 e0                	shl    %cl,%eax
  800fa3:	89 44 24 08          	mov    %eax,0x8(%esp)
  800fa7:	89 d1                	mov    %edx,%ecx
  800fa9:	89 f8                	mov    %edi,%eax
  800fab:	d3 e8                	shr    %cl,%eax
  800fad:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800fb1:	89 54 24 04          	mov    %edx,0x4(%esp)
  800fb5:	8b 54 24 04          	mov    0x4(%esp),%edx
  800fb9:	09 c1                	or     %eax,%ecx
  800fbb:	89 d8                	mov    %ebx,%eax
  800fbd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800fc1:	89 e9                	mov    %ebp,%ecx
  800fc3:	d3 e7                	shl    %cl,%edi
  800fc5:	89 d1                	mov    %edx,%ecx
  800fc7:	d3 e8                	shr    %cl,%eax
  800fc9:	89 e9                	mov    %ebp,%ecx
  800fcb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800fcf:	d3 e3                	shl    %cl,%ebx
  800fd1:	89 c7                	mov    %eax,%edi
  800fd3:	89 d1                	mov    %edx,%ecx
  800fd5:	89 f0                	mov    %esi,%eax
  800fd7:	d3 e8                	shr    %cl,%eax
  800fd9:	89 e9                	mov    %ebp,%ecx
  800fdb:	89 fa                	mov    %edi,%edx
  800fdd:	d3 e6                	shl    %cl,%esi
  800fdf:	09 d8                	or     %ebx,%eax
  800fe1:	f7 74 24 08          	divl   0x8(%esp)
  800fe5:	89 d1                	mov    %edx,%ecx
  800fe7:	89 f3                	mov    %esi,%ebx
  800fe9:	f7 64 24 0c          	mull   0xc(%esp)
  800fed:	89 c6                	mov    %eax,%esi
  800fef:	89 d7                	mov    %edx,%edi
  800ff1:	39 d1                	cmp    %edx,%ecx
  800ff3:	72 06                	jb     800ffb <__umoddi3+0x10b>
  800ff5:	75 10                	jne    801007 <__umoddi3+0x117>
  800ff7:	39 c3                	cmp    %eax,%ebx
  800ff9:	73 0c                	jae    801007 <__umoddi3+0x117>
  800ffb:	2b 44 24 0c          	sub    0xc(%esp),%eax
  800fff:	1b 54 24 08          	sbb    0x8(%esp),%edx
  801003:	89 d7                	mov    %edx,%edi
  801005:	89 c6                	mov    %eax,%esi
  801007:	89 ca                	mov    %ecx,%edx
  801009:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80100e:	29 f3                	sub    %esi,%ebx
  801010:	19 fa                	sbb    %edi,%edx
  801012:	89 d0                	mov    %edx,%eax
  801014:	d3 e0                	shl    %cl,%eax
  801016:	89 e9                	mov    %ebp,%ecx
  801018:	d3 eb                	shr    %cl,%ebx
  80101a:	d3 ea                	shr    %cl,%edx
  80101c:	09 d8                	or     %ebx,%eax
  80101e:	83 c4 1c             	add    $0x1c,%esp
  801021:	5b                   	pop    %ebx
  801022:	5e                   	pop    %esi
  801023:	5f                   	pop    %edi
  801024:	5d                   	pop    %ebp
  801025:	c3                   	ret    
  801026:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80102d:	8d 76 00             	lea    0x0(%esi),%esi
  801030:	29 fe                	sub    %edi,%esi
  801032:	19 c3                	sbb    %eax,%ebx
  801034:	89 f2                	mov    %esi,%edx
  801036:	89 d9                	mov    %ebx,%ecx
  801038:	e9 1d ff ff ff       	jmp    800f5a <__umoddi3+0x6a>
