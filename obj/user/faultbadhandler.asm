
obj/user/faultbadhandler:     file format elf32-i386


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
  80002c:	e8 38 00 00 00       	call   800069 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	f3 0f 1e fb          	endbr32 
  800037:	55                   	push   %ebp
  800038:	89 e5                	mov    %esp,%ebp
  80003a:	83 ec 0c             	sub    $0xc,%esp
	sys_page_alloc(0, (void*) (UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W);
  80003d:	6a 07                	push   $0x7
  80003f:	68 00 f0 bf ee       	push   $0xeebff000
  800044:	6a 00                	push   $0x0
  800046:	e8 4e 01 00 00       	call   800199 <sys_page_alloc>
	sys_env_set_pgfault_upcall(0, (void*) 0xDeadBeef);
  80004b:	83 c4 08             	add    $0x8,%esp
  80004e:	68 ef be ad de       	push   $0xdeadbeef
  800053:	6a 00                	push   $0x0
  800055:	e8 58 02 00 00       	call   8002b2 <sys_env_set_pgfault_upcall>
	*(int*)0 = 0;
  80005a:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  800061:	00 00 00 
}
  800064:	83 c4 10             	add    $0x10,%esp
  800067:	c9                   	leave  
  800068:	c3                   	ret    

00800069 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800069:	f3 0f 1e fb          	endbr32 
  80006d:	55                   	push   %ebp
  80006e:	89 e5                	mov    %esp,%ebp
  800070:	56                   	push   %esi
  800071:	53                   	push   %ebx
  800072:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800075:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv=&envs[ENVX(sys_getenvid())];
  800078:	e8 d6 00 00 00       	call   800153 <sys_getenvid>
  80007d:	25 ff 03 00 00       	and    $0x3ff,%eax
  800082:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800085:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80008a:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80008f:	85 db                	test   %ebx,%ebx
  800091:	7e 07                	jle    80009a <libmain+0x31>
		binaryname = argv[0];
  800093:	8b 06                	mov    (%esi),%eax
  800095:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80009a:	83 ec 08             	sub    $0x8,%esp
  80009d:	56                   	push   %esi
  80009e:	53                   	push   %ebx
  80009f:	e8 8f ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000a4:	e8 0a 00 00 00       	call   8000b3 <exit>
}
  8000a9:	83 c4 10             	add    $0x10,%esp
  8000ac:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000af:	5b                   	pop    %ebx
  8000b0:	5e                   	pop    %esi
  8000b1:	5d                   	pop    %ebp
  8000b2:	c3                   	ret    

008000b3 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000b3:	f3 0f 1e fb          	endbr32 
  8000b7:	55                   	push   %ebp
  8000b8:	89 e5                	mov    %esp,%ebp
  8000ba:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000bd:	6a 00                	push   $0x0
  8000bf:	e8 4a 00 00 00       	call   80010e <sys_env_destroy>
}
  8000c4:	83 c4 10             	add    $0x10,%esp
  8000c7:	c9                   	leave  
  8000c8:	c3                   	ret    

008000c9 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000c9:	f3 0f 1e fb          	endbr32 
  8000cd:	55                   	push   %ebp
  8000ce:	89 e5                	mov    %esp,%ebp
  8000d0:	57                   	push   %edi
  8000d1:	56                   	push   %esi
  8000d2:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000d3:	b8 00 00 00 00       	mov    $0x0,%eax
  8000d8:	8b 55 08             	mov    0x8(%ebp),%edx
  8000db:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000de:	89 c3                	mov    %eax,%ebx
  8000e0:	89 c7                	mov    %eax,%edi
  8000e2:	89 c6                	mov    %eax,%esi
  8000e4:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000e6:	5b                   	pop    %ebx
  8000e7:	5e                   	pop    %esi
  8000e8:	5f                   	pop    %edi
  8000e9:	5d                   	pop    %ebp
  8000ea:	c3                   	ret    

008000eb <sys_cgetc>:

int
sys_cgetc(void)
{
  8000eb:	f3 0f 1e fb          	endbr32 
  8000ef:	55                   	push   %ebp
  8000f0:	89 e5                	mov    %esp,%ebp
  8000f2:	57                   	push   %edi
  8000f3:	56                   	push   %esi
  8000f4:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000f5:	ba 00 00 00 00       	mov    $0x0,%edx
  8000fa:	b8 01 00 00 00       	mov    $0x1,%eax
  8000ff:	89 d1                	mov    %edx,%ecx
  800101:	89 d3                	mov    %edx,%ebx
  800103:	89 d7                	mov    %edx,%edi
  800105:	89 d6                	mov    %edx,%esi
  800107:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800109:	5b                   	pop    %ebx
  80010a:	5e                   	pop    %esi
  80010b:	5f                   	pop    %edi
  80010c:	5d                   	pop    %ebp
  80010d:	c3                   	ret    

0080010e <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  80010e:	f3 0f 1e fb          	endbr32 
  800112:	55                   	push   %ebp
  800113:	89 e5                	mov    %esp,%ebp
  800115:	57                   	push   %edi
  800116:	56                   	push   %esi
  800117:	53                   	push   %ebx
  800118:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80011b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800120:	8b 55 08             	mov    0x8(%ebp),%edx
  800123:	b8 03 00 00 00       	mov    $0x3,%eax
  800128:	89 cb                	mov    %ecx,%ebx
  80012a:	89 cf                	mov    %ecx,%edi
  80012c:	89 ce                	mov    %ecx,%esi
  80012e:	cd 30                	int    $0x30
	if(check && ret > 0)
  800130:	85 c0                	test   %eax,%eax
  800132:	7f 08                	jg     80013c <sys_env_destroy+0x2e>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800134:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800137:	5b                   	pop    %ebx
  800138:	5e                   	pop    %esi
  800139:	5f                   	pop    %edi
  80013a:	5d                   	pop    %ebp
  80013b:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80013c:	83 ec 0c             	sub    $0xc,%esp
  80013f:	50                   	push   %eax
  800140:	6a 03                	push   $0x3
  800142:	68 8a 10 80 00       	push   $0x80108a
  800147:	6a 23                	push   $0x23
  800149:	68 a7 10 80 00       	push   $0x8010a7
  80014e:	e8 11 02 00 00       	call   800364 <_panic>

00800153 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800153:	f3 0f 1e fb          	endbr32 
  800157:	55                   	push   %ebp
  800158:	89 e5                	mov    %esp,%ebp
  80015a:	57                   	push   %edi
  80015b:	56                   	push   %esi
  80015c:	53                   	push   %ebx
	asm volatile("int %1\n"
  80015d:	ba 00 00 00 00       	mov    $0x0,%edx
  800162:	b8 02 00 00 00       	mov    $0x2,%eax
  800167:	89 d1                	mov    %edx,%ecx
  800169:	89 d3                	mov    %edx,%ebx
  80016b:	89 d7                	mov    %edx,%edi
  80016d:	89 d6                	mov    %edx,%esi
  80016f:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800171:	5b                   	pop    %ebx
  800172:	5e                   	pop    %esi
  800173:	5f                   	pop    %edi
  800174:	5d                   	pop    %ebp
  800175:	c3                   	ret    

00800176 <sys_yield>:

void
sys_yield(void)
{
  800176:	f3 0f 1e fb          	endbr32 
  80017a:	55                   	push   %ebp
  80017b:	89 e5                	mov    %esp,%ebp
  80017d:	57                   	push   %edi
  80017e:	56                   	push   %esi
  80017f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800180:	ba 00 00 00 00       	mov    $0x0,%edx
  800185:	b8 0a 00 00 00       	mov    $0xa,%eax
  80018a:	89 d1                	mov    %edx,%ecx
  80018c:	89 d3                	mov    %edx,%ebx
  80018e:	89 d7                	mov    %edx,%edi
  800190:	89 d6                	mov    %edx,%esi
  800192:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800194:	5b                   	pop    %ebx
  800195:	5e                   	pop    %esi
  800196:	5f                   	pop    %edi
  800197:	5d                   	pop    %ebp
  800198:	c3                   	ret    

00800199 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800199:	f3 0f 1e fb          	endbr32 
  80019d:	55                   	push   %ebp
  80019e:	89 e5                	mov    %esp,%ebp
  8001a0:	57                   	push   %edi
  8001a1:	56                   	push   %esi
  8001a2:	53                   	push   %ebx
  8001a3:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001a6:	be 00 00 00 00       	mov    $0x0,%esi
  8001ab:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001b1:	b8 04 00 00 00       	mov    $0x4,%eax
  8001b6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001b9:	89 f7                	mov    %esi,%edi
  8001bb:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001bd:	85 c0                	test   %eax,%eax
  8001bf:	7f 08                	jg     8001c9 <sys_page_alloc+0x30>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001c1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001c4:	5b                   	pop    %ebx
  8001c5:	5e                   	pop    %esi
  8001c6:	5f                   	pop    %edi
  8001c7:	5d                   	pop    %ebp
  8001c8:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8001c9:	83 ec 0c             	sub    $0xc,%esp
  8001cc:	50                   	push   %eax
  8001cd:	6a 04                	push   $0x4
  8001cf:	68 8a 10 80 00       	push   $0x80108a
  8001d4:	6a 23                	push   $0x23
  8001d6:	68 a7 10 80 00       	push   $0x8010a7
  8001db:	e8 84 01 00 00       	call   800364 <_panic>

008001e0 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001e0:	f3 0f 1e fb          	endbr32 
  8001e4:	55                   	push   %ebp
  8001e5:	89 e5                	mov    %esp,%ebp
  8001e7:	57                   	push   %edi
  8001e8:	56                   	push   %esi
  8001e9:	53                   	push   %ebx
  8001ea:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001ed:	8b 55 08             	mov    0x8(%ebp),%edx
  8001f0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001f3:	b8 05 00 00 00       	mov    $0x5,%eax
  8001f8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001fb:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001fe:	8b 75 18             	mov    0x18(%ebp),%esi
  800201:	cd 30                	int    $0x30
	if(check && ret > 0)
  800203:	85 c0                	test   %eax,%eax
  800205:	7f 08                	jg     80020f <sys_page_map+0x2f>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800207:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80020a:	5b                   	pop    %ebx
  80020b:	5e                   	pop    %esi
  80020c:	5f                   	pop    %edi
  80020d:	5d                   	pop    %ebp
  80020e:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80020f:	83 ec 0c             	sub    $0xc,%esp
  800212:	50                   	push   %eax
  800213:	6a 05                	push   $0x5
  800215:	68 8a 10 80 00       	push   $0x80108a
  80021a:	6a 23                	push   $0x23
  80021c:	68 a7 10 80 00       	push   $0x8010a7
  800221:	e8 3e 01 00 00       	call   800364 <_panic>

00800226 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800226:	f3 0f 1e fb          	endbr32 
  80022a:	55                   	push   %ebp
  80022b:	89 e5                	mov    %esp,%ebp
  80022d:	57                   	push   %edi
  80022e:	56                   	push   %esi
  80022f:	53                   	push   %ebx
  800230:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800233:	bb 00 00 00 00       	mov    $0x0,%ebx
  800238:	8b 55 08             	mov    0x8(%ebp),%edx
  80023b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80023e:	b8 06 00 00 00       	mov    $0x6,%eax
  800243:	89 df                	mov    %ebx,%edi
  800245:	89 de                	mov    %ebx,%esi
  800247:	cd 30                	int    $0x30
	if(check && ret > 0)
  800249:	85 c0                	test   %eax,%eax
  80024b:	7f 08                	jg     800255 <sys_page_unmap+0x2f>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80024d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800250:	5b                   	pop    %ebx
  800251:	5e                   	pop    %esi
  800252:	5f                   	pop    %edi
  800253:	5d                   	pop    %ebp
  800254:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800255:	83 ec 0c             	sub    $0xc,%esp
  800258:	50                   	push   %eax
  800259:	6a 06                	push   $0x6
  80025b:	68 8a 10 80 00       	push   $0x80108a
  800260:	6a 23                	push   $0x23
  800262:	68 a7 10 80 00       	push   $0x8010a7
  800267:	e8 f8 00 00 00       	call   800364 <_panic>

0080026c <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80026c:	f3 0f 1e fb          	endbr32 
  800270:	55                   	push   %ebp
  800271:	89 e5                	mov    %esp,%ebp
  800273:	57                   	push   %edi
  800274:	56                   	push   %esi
  800275:	53                   	push   %ebx
  800276:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800279:	bb 00 00 00 00       	mov    $0x0,%ebx
  80027e:	8b 55 08             	mov    0x8(%ebp),%edx
  800281:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800284:	b8 08 00 00 00       	mov    $0x8,%eax
  800289:	89 df                	mov    %ebx,%edi
  80028b:	89 de                	mov    %ebx,%esi
  80028d:	cd 30                	int    $0x30
	if(check && ret > 0)
  80028f:	85 c0                	test   %eax,%eax
  800291:	7f 08                	jg     80029b <sys_env_set_status+0x2f>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800293:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800296:	5b                   	pop    %ebx
  800297:	5e                   	pop    %esi
  800298:	5f                   	pop    %edi
  800299:	5d                   	pop    %ebp
  80029a:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80029b:	83 ec 0c             	sub    $0xc,%esp
  80029e:	50                   	push   %eax
  80029f:	6a 08                	push   $0x8
  8002a1:	68 8a 10 80 00       	push   $0x80108a
  8002a6:	6a 23                	push   $0x23
  8002a8:	68 a7 10 80 00       	push   $0x8010a7
  8002ad:	e8 b2 00 00 00       	call   800364 <_panic>

008002b2 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002b2:	f3 0f 1e fb          	endbr32 
  8002b6:	55                   	push   %ebp
  8002b7:	89 e5                	mov    %esp,%ebp
  8002b9:	57                   	push   %edi
  8002ba:	56                   	push   %esi
  8002bb:	53                   	push   %ebx
  8002bc:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8002bf:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002c4:	8b 55 08             	mov    0x8(%ebp),%edx
  8002c7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002ca:	b8 09 00 00 00       	mov    $0x9,%eax
  8002cf:	89 df                	mov    %ebx,%edi
  8002d1:	89 de                	mov    %ebx,%esi
  8002d3:	cd 30                	int    $0x30
	if(check && ret > 0)
  8002d5:	85 c0                	test   %eax,%eax
  8002d7:	7f 08                	jg     8002e1 <sys_env_set_pgfault_upcall+0x2f>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002d9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002dc:	5b                   	pop    %ebx
  8002dd:	5e                   	pop    %esi
  8002de:	5f                   	pop    %edi
  8002df:	5d                   	pop    %ebp
  8002e0:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8002e1:	83 ec 0c             	sub    $0xc,%esp
  8002e4:	50                   	push   %eax
  8002e5:	6a 09                	push   $0x9
  8002e7:	68 8a 10 80 00       	push   $0x80108a
  8002ec:	6a 23                	push   $0x23
  8002ee:	68 a7 10 80 00       	push   $0x8010a7
  8002f3:	e8 6c 00 00 00       	call   800364 <_panic>

008002f8 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002f8:	f3 0f 1e fb          	endbr32 
  8002fc:	55                   	push   %ebp
  8002fd:	89 e5                	mov    %esp,%ebp
  8002ff:	57                   	push   %edi
  800300:	56                   	push   %esi
  800301:	53                   	push   %ebx
	asm volatile("int %1\n"
  800302:	8b 55 08             	mov    0x8(%ebp),%edx
  800305:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800308:	b8 0b 00 00 00       	mov    $0xb,%eax
  80030d:	be 00 00 00 00       	mov    $0x0,%esi
  800312:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800315:	8b 7d 14             	mov    0x14(%ebp),%edi
  800318:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80031a:	5b                   	pop    %ebx
  80031b:	5e                   	pop    %esi
  80031c:	5f                   	pop    %edi
  80031d:	5d                   	pop    %ebp
  80031e:	c3                   	ret    

0080031f <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80031f:	f3 0f 1e fb          	endbr32 
  800323:	55                   	push   %ebp
  800324:	89 e5                	mov    %esp,%ebp
  800326:	57                   	push   %edi
  800327:	56                   	push   %esi
  800328:	53                   	push   %ebx
  800329:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80032c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800331:	8b 55 08             	mov    0x8(%ebp),%edx
  800334:	b8 0c 00 00 00       	mov    $0xc,%eax
  800339:	89 cb                	mov    %ecx,%ebx
  80033b:	89 cf                	mov    %ecx,%edi
  80033d:	89 ce                	mov    %ecx,%esi
  80033f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800341:	85 c0                	test   %eax,%eax
  800343:	7f 08                	jg     80034d <sys_ipc_recv+0x2e>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800345:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800348:	5b                   	pop    %ebx
  800349:	5e                   	pop    %esi
  80034a:	5f                   	pop    %edi
  80034b:	5d                   	pop    %ebp
  80034c:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80034d:	83 ec 0c             	sub    $0xc,%esp
  800350:	50                   	push   %eax
  800351:	6a 0c                	push   $0xc
  800353:	68 8a 10 80 00       	push   $0x80108a
  800358:	6a 23                	push   $0x23
  80035a:	68 a7 10 80 00       	push   $0x8010a7
  80035f:	e8 00 00 00 00       	call   800364 <_panic>

00800364 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800364:	f3 0f 1e fb          	endbr32 
  800368:	55                   	push   %ebp
  800369:	89 e5                	mov    %esp,%ebp
  80036b:	56                   	push   %esi
  80036c:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80036d:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800370:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800376:	e8 d8 fd ff ff       	call   800153 <sys_getenvid>
  80037b:	83 ec 0c             	sub    $0xc,%esp
  80037e:	ff 75 0c             	pushl  0xc(%ebp)
  800381:	ff 75 08             	pushl  0x8(%ebp)
  800384:	56                   	push   %esi
  800385:	50                   	push   %eax
  800386:	68 b8 10 80 00       	push   $0x8010b8
  80038b:	e8 bb 00 00 00       	call   80044b <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800390:	83 c4 18             	add    $0x18,%esp
  800393:	53                   	push   %ebx
  800394:	ff 75 10             	pushl  0x10(%ebp)
  800397:	e8 5a 00 00 00       	call   8003f6 <vcprintf>
	cprintf("\n");
  80039c:	c7 04 24 db 10 80 00 	movl   $0x8010db,(%esp)
  8003a3:	e8 a3 00 00 00       	call   80044b <cprintf>
  8003a8:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8003ab:	cc                   	int3   
  8003ac:	eb fd                	jmp    8003ab <_panic+0x47>

008003ae <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8003ae:	f3 0f 1e fb          	endbr32 
  8003b2:	55                   	push   %ebp
  8003b3:	89 e5                	mov    %esp,%ebp
  8003b5:	53                   	push   %ebx
  8003b6:	83 ec 04             	sub    $0x4,%esp
  8003b9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8003bc:	8b 13                	mov    (%ebx),%edx
  8003be:	8d 42 01             	lea    0x1(%edx),%eax
  8003c1:	89 03                	mov    %eax,(%ebx)
  8003c3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003c6:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8003ca:	3d ff 00 00 00       	cmp    $0xff,%eax
  8003cf:	74 09                	je     8003da <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8003d1:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8003d5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8003d8:	c9                   	leave  
  8003d9:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8003da:	83 ec 08             	sub    $0x8,%esp
  8003dd:	68 ff 00 00 00       	push   $0xff
  8003e2:	8d 43 08             	lea    0x8(%ebx),%eax
  8003e5:	50                   	push   %eax
  8003e6:	e8 de fc ff ff       	call   8000c9 <sys_cputs>
		b->idx = 0;
  8003eb:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8003f1:	83 c4 10             	add    $0x10,%esp
  8003f4:	eb db                	jmp    8003d1 <putch+0x23>

008003f6 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8003f6:	f3 0f 1e fb          	endbr32 
  8003fa:	55                   	push   %ebp
  8003fb:	89 e5                	mov    %esp,%ebp
  8003fd:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800403:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80040a:	00 00 00 
	b.cnt = 0;
  80040d:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800414:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800417:	ff 75 0c             	pushl  0xc(%ebp)
  80041a:	ff 75 08             	pushl  0x8(%ebp)
  80041d:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800423:	50                   	push   %eax
  800424:	68 ae 03 80 00       	push   $0x8003ae
  800429:	e8 20 01 00 00       	call   80054e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80042e:	83 c4 08             	add    $0x8,%esp
  800431:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800437:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80043d:	50                   	push   %eax
  80043e:	e8 86 fc ff ff       	call   8000c9 <sys_cputs>

	return b.cnt;
}
  800443:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800449:	c9                   	leave  
  80044a:	c3                   	ret    

0080044b <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80044b:	f3 0f 1e fb          	endbr32 
  80044f:	55                   	push   %ebp
  800450:	89 e5                	mov    %esp,%ebp
  800452:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800455:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800458:	50                   	push   %eax
  800459:	ff 75 08             	pushl  0x8(%ebp)
  80045c:	e8 95 ff ff ff       	call   8003f6 <vcprintf>
	va_end(ap);

	return cnt;
}
  800461:	c9                   	leave  
  800462:	c3                   	ret    

00800463 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800463:	55                   	push   %ebp
  800464:	89 e5                	mov    %esp,%ebp
  800466:	57                   	push   %edi
  800467:	56                   	push   %esi
  800468:	53                   	push   %ebx
  800469:	83 ec 1c             	sub    $0x1c,%esp
  80046c:	89 c7                	mov    %eax,%edi
  80046e:	89 d6                	mov    %edx,%esi
  800470:	8b 45 08             	mov    0x8(%ebp),%eax
  800473:	8b 55 0c             	mov    0xc(%ebp),%edx
  800476:	89 d1                	mov    %edx,%ecx
  800478:	89 c2                	mov    %eax,%edx
  80047a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80047d:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800480:	8b 45 10             	mov    0x10(%ebp),%eax
  800483:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800486:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800489:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800490:	39 c2                	cmp    %eax,%edx
  800492:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800495:	72 3e                	jb     8004d5 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800497:	83 ec 0c             	sub    $0xc,%esp
  80049a:	ff 75 18             	pushl  0x18(%ebp)
  80049d:	83 eb 01             	sub    $0x1,%ebx
  8004a0:	53                   	push   %ebx
  8004a1:	50                   	push   %eax
  8004a2:	83 ec 08             	sub    $0x8,%esp
  8004a5:	ff 75 e4             	pushl  -0x1c(%ebp)
  8004a8:	ff 75 e0             	pushl  -0x20(%ebp)
  8004ab:	ff 75 dc             	pushl  -0x24(%ebp)
  8004ae:	ff 75 d8             	pushl  -0x28(%ebp)
  8004b1:	e8 5a 09 00 00       	call   800e10 <__udivdi3>
  8004b6:	83 c4 18             	add    $0x18,%esp
  8004b9:	52                   	push   %edx
  8004ba:	50                   	push   %eax
  8004bb:	89 f2                	mov    %esi,%edx
  8004bd:	89 f8                	mov    %edi,%eax
  8004bf:	e8 9f ff ff ff       	call   800463 <printnum>
  8004c4:	83 c4 20             	add    $0x20,%esp
  8004c7:	eb 13                	jmp    8004dc <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8004c9:	83 ec 08             	sub    $0x8,%esp
  8004cc:	56                   	push   %esi
  8004cd:	ff 75 18             	pushl  0x18(%ebp)
  8004d0:	ff d7                	call   *%edi
  8004d2:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8004d5:	83 eb 01             	sub    $0x1,%ebx
  8004d8:	85 db                	test   %ebx,%ebx
  8004da:	7f ed                	jg     8004c9 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8004dc:	83 ec 08             	sub    $0x8,%esp
  8004df:	56                   	push   %esi
  8004e0:	83 ec 04             	sub    $0x4,%esp
  8004e3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8004e6:	ff 75 e0             	pushl  -0x20(%ebp)
  8004e9:	ff 75 dc             	pushl  -0x24(%ebp)
  8004ec:	ff 75 d8             	pushl  -0x28(%ebp)
  8004ef:	e8 2c 0a 00 00       	call   800f20 <__umoddi3>
  8004f4:	83 c4 14             	add    $0x14,%esp
  8004f7:	0f be 80 dd 10 80 00 	movsbl 0x8010dd(%eax),%eax
  8004fe:	50                   	push   %eax
  8004ff:	ff d7                	call   *%edi
}
  800501:	83 c4 10             	add    $0x10,%esp
  800504:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800507:	5b                   	pop    %ebx
  800508:	5e                   	pop    %esi
  800509:	5f                   	pop    %edi
  80050a:	5d                   	pop    %ebp
  80050b:	c3                   	ret    

0080050c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80050c:	f3 0f 1e fb          	endbr32 
  800510:	55                   	push   %ebp
  800511:	89 e5                	mov    %esp,%ebp
  800513:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800516:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80051a:	8b 10                	mov    (%eax),%edx
  80051c:	3b 50 04             	cmp    0x4(%eax),%edx
  80051f:	73 0a                	jae    80052b <sprintputch+0x1f>
		*b->buf++ = ch;
  800521:	8d 4a 01             	lea    0x1(%edx),%ecx
  800524:	89 08                	mov    %ecx,(%eax)
  800526:	8b 45 08             	mov    0x8(%ebp),%eax
  800529:	88 02                	mov    %al,(%edx)
}
  80052b:	5d                   	pop    %ebp
  80052c:	c3                   	ret    

0080052d <printfmt>:
{
  80052d:	f3 0f 1e fb          	endbr32 
  800531:	55                   	push   %ebp
  800532:	89 e5                	mov    %esp,%ebp
  800534:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800537:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80053a:	50                   	push   %eax
  80053b:	ff 75 10             	pushl  0x10(%ebp)
  80053e:	ff 75 0c             	pushl  0xc(%ebp)
  800541:	ff 75 08             	pushl  0x8(%ebp)
  800544:	e8 05 00 00 00       	call   80054e <vprintfmt>
}
  800549:	83 c4 10             	add    $0x10,%esp
  80054c:	c9                   	leave  
  80054d:	c3                   	ret    

0080054e <vprintfmt>:
{
  80054e:	f3 0f 1e fb          	endbr32 
  800552:	55                   	push   %ebp
  800553:	89 e5                	mov    %esp,%ebp
  800555:	57                   	push   %edi
  800556:	56                   	push   %esi
  800557:	53                   	push   %ebx
  800558:	83 ec 3c             	sub    $0x3c,%esp
  80055b:	8b 75 08             	mov    0x8(%ebp),%esi
  80055e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800561:	8b 7d 10             	mov    0x10(%ebp),%edi
  800564:	e9 cd 03 00 00       	jmp    800936 <vprintfmt+0x3e8>
		padc = ' ';
  800569:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  80056d:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800574:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  80057b:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800582:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800587:	8d 47 01             	lea    0x1(%edi),%eax
  80058a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80058d:	0f b6 17             	movzbl (%edi),%edx
  800590:	8d 42 dd             	lea    -0x23(%edx),%eax
  800593:	3c 55                	cmp    $0x55,%al
  800595:	0f 87 1e 04 00 00    	ja     8009b9 <vprintfmt+0x46b>
  80059b:	0f b6 c0             	movzbl %al,%eax
  80059e:	3e ff 24 85 a0 11 80 	notrack jmp *0x8011a0(,%eax,4)
  8005a5:	00 
  8005a6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8005a9:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  8005ad:	eb d8                	jmp    800587 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8005af:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005b2:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  8005b6:	eb cf                	jmp    800587 <vprintfmt+0x39>
  8005b8:	0f b6 d2             	movzbl %dl,%edx
  8005bb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8005be:	b8 00 00 00 00       	mov    $0x0,%eax
  8005c3:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8005c6:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8005c9:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8005cd:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8005d0:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8005d3:	83 f9 09             	cmp    $0x9,%ecx
  8005d6:	77 55                	ja     80062d <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  8005d8:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8005db:	eb e9                	jmp    8005c6 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  8005dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e0:	8b 00                	mov    (%eax),%eax
  8005e2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005e5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e8:	8d 40 04             	lea    0x4(%eax),%eax
  8005eb:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8005ee:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8005f1:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005f5:	79 90                	jns    800587 <vprintfmt+0x39>
				width = precision, precision = -1;
  8005f7:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005fa:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005fd:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800604:	eb 81                	jmp    800587 <vprintfmt+0x39>
  800606:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800609:	85 c0                	test   %eax,%eax
  80060b:	ba 00 00 00 00       	mov    $0x0,%edx
  800610:	0f 49 d0             	cmovns %eax,%edx
  800613:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800616:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800619:	e9 69 ff ff ff       	jmp    800587 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  80061e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800621:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  800628:	e9 5a ff ff ff       	jmp    800587 <vprintfmt+0x39>
  80062d:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800630:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800633:	eb bc                	jmp    8005f1 <vprintfmt+0xa3>
			lflag++;
  800635:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800638:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80063b:	e9 47 ff ff ff       	jmp    800587 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  800640:	8b 45 14             	mov    0x14(%ebp),%eax
  800643:	8d 78 04             	lea    0x4(%eax),%edi
  800646:	83 ec 08             	sub    $0x8,%esp
  800649:	53                   	push   %ebx
  80064a:	ff 30                	pushl  (%eax)
  80064c:	ff d6                	call   *%esi
			break;
  80064e:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800651:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800654:	e9 da 02 00 00       	jmp    800933 <vprintfmt+0x3e5>
			err = va_arg(ap, int);
  800659:	8b 45 14             	mov    0x14(%ebp),%eax
  80065c:	8d 78 04             	lea    0x4(%eax),%edi
  80065f:	8b 00                	mov    (%eax),%eax
  800661:	99                   	cltd   
  800662:	31 d0                	xor    %edx,%eax
  800664:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800666:	83 f8 08             	cmp    $0x8,%eax
  800669:	7f 23                	jg     80068e <vprintfmt+0x140>
  80066b:	8b 14 85 00 13 80 00 	mov    0x801300(,%eax,4),%edx
  800672:	85 d2                	test   %edx,%edx
  800674:	74 18                	je     80068e <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  800676:	52                   	push   %edx
  800677:	68 fe 10 80 00       	push   $0x8010fe
  80067c:	53                   	push   %ebx
  80067d:	56                   	push   %esi
  80067e:	e8 aa fe ff ff       	call   80052d <printfmt>
  800683:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800686:	89 7d 14             	mov    %edi,0x14(%ebp)
  800689:	e9 a5 02 00 00       	jmp    800933 <vprintfmt+0x3e5>
				printfmt(putch, putdat, "error %d", err);
  80068e:	50                   	push   %eax
  80068f:	68 f5 10 80 00       	push   $0x8010f5
  800694:	53                   	push   %ebx
  800695:	56                   	push   %esi
  800696:	e8 92 fe ff ff       	call   80052d <printfmt>
  80069b:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80069e:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8006a1:	e9 8d 02 00 00       	jmp    800933 <vprintfmt+0x3e5>
			if ((p = va_arg(ap, char *)) == NULL)
  8006a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a9:	83 c0 04             	add    $0x4,%eax
  8006ac:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8006af:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b2:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  8006b4:	85 d2                	test   %edx,%edx
  8006b6:	b8 ee 10 80 00       	mov    $0x8010ee,%eax
  8006bb:	0f 45 c2             	cmovne %edx,%eax
  8006be:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8006c1:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006c5:	7e 06                	jle    8006cd <vprintfmt+0x17f>
  8006c7:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  8006cb:	75 0d                	jne    8006da <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006cd:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8006d0:	89 c7                	mov    %eax,%edi
  8006d2:	03 45 e0             	add    -0x20(%ebp),%eax
  8006d5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006d8:	eb 55                	jmp    80072f <vprintfmt+0x1e1>
  8006da:	83 ec 08             	sub    $0x8,%esp
  8006dd:	ff 75 d8             	pushl  -0x28(%ebp)
  8006e0:	ff 75 cc             	pushl  -0x34(%ebp)
  8006e3:	e8 85 03 00 00       	call   800a6d <strnlen>
  8006e8:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8006eb:	29 c2                	sub    %eax,%edx
  8006ed:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  8006f0:	83 c4 10             	add    $0x10,%esp
  8006f3:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  8006f5:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8006f9:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8006fc:	85 ff                	test   %edi,%edi
  8006fe:	7e 11                	jle    800711 <vprintfmt+0x1c3>
					putch(padc, putdat);
  800700:	83 ec 08             	sub    $0x8,%esp
  800703:	53                   	push   %ebx
  800704:	ff 75 e0             	pushl  -0x20(%ebp)
  800707:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800709:	83 ef 01             	sub    $0x1,%edi
  80070c:	83 c4 10             	add    $0x10,%esp
  80070f:	eb eb                	jmp    8006fc <vprintfmt+0x1ae>
  800711:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800714:	85 d2                	test   %edx,%edx
  800716:	b8 00 00 00 00       	mov    $0x0,%eax
  80071b:	0f 49 c2             	cmovns %edx,%eax
  80071e:	29 c2                	sub    %eax,%edx
  800720:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800723:	eb a8                	jmp    8006cd <vprintfmt+0x17f>
					putch(ch, putdat);
  800725:	83 ec 08             	sub    $0x8,%esp
  800728:	53                   	push   %ebx
  800729:	52                   	push   %edx
  80072a:	ff d6                	call   *%esi
  80072c:	83 c4 10             	add    $0x10,%esp
  80072f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800732:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800734:	83 c7 01             	add    $0x1,%edi
  800737:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80073b:	0f be d0             	movsbl %al,%edx
  80073e:	85 d2                	test   %edx,%edx
  800740:	74 4b                	je     80078d <vprintfmt+0x23f>
  800742:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800746:	78 06                	js     80074e <vprintfmt+0x200>
  800748:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  80074c:	78 1e                	js     80076c <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
  80074e:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800752:	74 d1                	je     800725 <vprintfmt+0x1d7>
  800754:	0f be c0             	movsbl %al,%eax
  800757:	83 e8 20             	sub    $0x20,%eax
  80075a:	83 f8 5e             	cmp    $0x5e,%eax
  80075d:	76 c6                	jbe    800725 <vprintfmt+0x1d7>
					putch('?', putdat);
  80075f:	83 ec 08             	sub    $0x8,%esp
  800762:	53                   	push   %ebx
  800763:	6a 3f                	push   $0x3f
  800765:	ff d6                	call   *%esi
  800767:	83 c4 10             	add    $0x10,%esp
  80076a:	eb c3                	jmp    80072f <vprintfmt+0x1e1>
  80076c:	89 cf                	mov    %ecx,%edi
  80076e:	eb 0e                	jmp    80077e <vprintfmt+0x230>
				putch(' ', putdat);
  800770:	83 ec 08             	sub    $0x8,%esp
  800773:	53                   	push   %ebx
  800774:	6a 20                	push   $0x20
  800776:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800778:	83 ef 01             	sub    $0x1,%edi
  80077b:	83 c4 10             	add    $0x10,%esp
  80077e:	85 ff                	test   %edi,%edi
  800780:	7f ee                	jg     800770 <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  800782:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800785:	89 45 14             	mov    %eax,0x14(%ebp)
  800788:	e9 a6 01 00 00       	jmp    800933 <vprintfmt+0x3e5>
  80078d:	89 cf                	mov    %ecx,%edi
  80078f:	eb ed                	jmp    80077e <vprintfmt+0x230>
	if (lflag >= 2)
  800791:	83 f9 01             	cmp    $0x1,%ecx
  800794:	7f 1f                	jg     8007b5 <vprintfmt+0x267>
	else if (lflag)
  800796:	85 c9                	test   %ecx,%ecx
  800798:	74 67                	je     800801 <vprintfmt+0x2b3>
		return va_arg(*ap, long);
  80079a:	8b 45 14             	mov    0x14(%ebp),%eax
  80079d:	8b 00                	mov    (%eax),%eax
  80079f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007a2:	89 c1                	mov    %eax,%ecx
  8007a4:	c1 f9 1f             	sar    $0x1f,%ecx
  8007a7:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8007aa:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ad:	8d 40 04             	lea    0x4(%eax),%eax
  8007b0:	89 45 14             	mov    %eax,0x14(%ebp)
  8007b3:	eb 17                	jmp    8007cc <vprintfmt+0x27e>
		return va_arg(*ap, long long);
  8007b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b8:	8b 50 04             	mov    0x4(%eax),%edx
  8007bb:	8b 00                	mov    (%eax),%eax
  8007bd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007c0:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c6:	8d 40 08             	lea    0x8(%eax),%eax
  8007c9:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8007cc:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007cf:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8007d2:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  8007d7:	85 c9                	test   %ecx,%ecx
  8007d9:	0f 89 3a 01 00 00    	jns    800919 <vprintfmt+0x3cb>
				putch('-', putdat);
  8007df:	83 ec 08             	sub    $0x8,%esp
  8007e2:	53                   	push   %ebx
  8007e3:	6a 2d                	push   $0x2d
  8007e5:	ff d6                	call   *%esi
				num = -(long long) num;
  8007e7:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007ea:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8007ed:	f7 da                	neg    %edx
  8007ef:	83 d1 00             	adc    $0x0,%ecx
  8007f2:	f7 d9                	neg    %ecx
  8007f4:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8007f7:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007fc:	e9 18 01 00 00       	jmp    800919 <vprintfmt+0x3cb>
		return va_arg(*ap, int);
  800801:	8b 45 14             	mov    0x14(%ebp),%eax
  800804:	8b 00                	mov    (%eax),%eax
  800806:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800809:	89 c1                	mov    %eax,%ecx
  80080b:	c1 f9 1f             	sar    $0x1f,%ecx
  80080e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800811:	8b 45 14             	mov    0x14(%ebp),%eax
  800814:	8d 40 04             	lea    0x4(%eax),%eax
  800817:	89 45 14             	mov    %eax,0x14(%ebp)
  80081a:	eb b0                	jmp    8007cc <vprintfmt+0x27e>
	if (lflag >= 2)
  80081c:	83 f9 01             	cmp    $0x1,%ecx
  80081f:	7f 1e                	jg     80083f <vprintfmt+0x2f1>
	else if (lflag)
  800821:	85 c9                	test   %ecx,%ecx
  800823:	74 32                	je     800857 <vprintfmt+0x309>
		return va_arg(*ap, unsigned long);
  800825:	8b 45 14             	mov    0x14(%ebp),%eax
  800828:	8b 10                	mov    (%eax),%edx
  80082a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80082f:	8d 40 04             	lea    0x4(%eax),%eax
  800832:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800835:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  80083a:	e9 da 00 00 00       	jmp    800919 <vprintfmt+0x3cb>
		return va_arg(*ap, unsigned long long);
  80083f:	8b 45 14             	mov    0x14(%ebp),%eax
  800842:	8b 10                	mov    (%eax),%edx
  800844:	8b 48 04             	mov    0x4(%eax),%ecx
  800847:	8d 40 08             	lea    0x8(%eax),%eax
  80084a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80084d:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  800852:	e9 c2 00 00 00       	jmp    800919 <vprintfmt+0x3cb>
		return va_arg(*ap, unsigned int);
  800857:	8b 45 14             	mov    0x14(%ebp),%eax
  80085a:	8b 10                	mov    (%eax),%edx
  80085c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800861:	8d 40 04             	lea    0x4(%eax),%eax
  800864:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800867:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  80086c:	e9 a8 00 00 00       	jmp    800919 <vprintfmt+0x3cb>
	if (lflag >= 2)
  800871:	83 f9 01             	cmp    $0x1,%ecx
  800874:	7f 1b                	jg     800891 <vprintfmt+0x343>
	else if (lflag)
  800876:	85 c9                	test   %ecx,%ecx
  800878:	74 5c                	je     8008d6 <vprintfmt+0x388>
		return va_arg(*ap, long);
  80087a:	8b 45 14             	mov    0x14(%ebp),%eax
  80087d:	8b 00                	mov    (%eax),%eax
  80087f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800882:	99                   	cltd   
  800883:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800886:	8b 45 14             	mov    0x14(%ebp),%eax
  800889:	8d 40 04             	lea    0x4(%eax),%eax
  80088c:	89 45 14             	mov    %eax,0x14(%ebp)
  80088f:	eb 17                	jmp    8008a8 <vprintfmt+0x35a>
		return va_arg(*ap, long long);
  800891:	8b 45 14             	mov    0x14(%ebp),%eax
  800894:	8b 50 04             	mov    0x4(%eax),%edx
  800897:	8b 00                	mov    (%eax),%eax
  800899:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80089c:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80089f:	8b 45 14             	mov    0x14(%ebp),%eax
  8008a2:	8d 40 08             	lea    0x8(%eax),%eax
  8008a5:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8008a8:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8008ab:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 8;
  8008ae:	b8 08 00 00 00       	mov    $0x8,%eax
			if ((long long) num < 0) {
  8008b3:	85 c9                	test   %ecx,%ecx
  8008b5:	79 62                	jns    800919 <vprintfmt+0x3cb>
				putch('-', putdat);
  8008b7:	83 ec 08             	sub    $0x8,%esp
  8008ba:	53                   	push   %ebx
  8008bb:	6a 2d                	push   $0x2d
  8008bd:	ff d6                	call   *%esi
				num = -(long long) num;
  8008bf:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8008c2:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8008c5:	f7 da                	neg    %edx
  8008c7:	83 d1 00             	adc    $0x0,%ecx
  8008ca:	f7 d9                	neg    %ecx
  8008cc:	83 c4 10             	add    $0x10,%esp
			base = 8;
  8008cf:	b8 08 00 00 00       	mov    $0x8,%eax
  8008d4:	eb 43                	jmp    800919 <vprintfmt+0x3cb>
		return va_arg(*ap, int);
  8008d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8008d9:	8b 00                	mov    (%eax),%eax
  8008db:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8008de:	89 c1                	mov    %eax,%ecx
  8008e0:	c1 f9 1f             	sar    $0x1f,%ecx
  8008e3:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8008e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8008e9:	8d 40 04             	lea    0x4(%eax),%eax
  8008ec:	89 45 14             	mov    %eax,0x14(%ebp)
  8008ef:	eb b7                	jmp    8008a8 <vprintfmt+0x35a>
			putch('0', putdat);
  8008f1:	83 ec 08             	sub    $0x8,%esp
  8008f4:	53                   	push   %ebx
  8008f5:	6a 30                	push   $0x30
  8008f7:	ff d6                	call   *%esi
			putch('x', putdat);
  8008f9:	83 c4 08             	add    $0x8,%esp
  8008fc:	53                   	push   %ebx
  8008fd:	6a 78                	push   $0x78
  8008ff:	ff d6                	call   *%esi
			num = (unsigned long long)
  800901:	8b 45 14             	mov    0x14(%ebp),%eax
  800904:	8b 10                	mov    (%eax),%edx
  800906:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  80090b:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  80090e:	8d 40 04             	lea    0x4(%eax),%eax
  800911:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800914:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  800919:	83 ec 0c             	sub    $0xc,%esp
  80091c:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  800920:	57                   	push   %edi
  800921:	ff 75 e0             	pushl  -0x20(%ebp)
  800924:	50                   	push   %eax
  800925:	51                   	push   %ecx
  800926:	52                   	push   %edx
  800927:	89 da                	mov    %ebx,%edx
  800929:	89 f0                	mov    %esi,%eax
  80092b:	e8 33 fb ff ff       	call   800463 <printnum>
			break;
  800930:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  800933:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800936:	83 c7 01             	add    $0x1,%edi
  800939:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80093d:	83 f8 25             	cmp    $0x25,%eax
  800940:	0f 84 23 fc ff ff    	je     800569 <vprintfmt+0x1b>
			if (ch == '\0')
  800946:	85 c0                	test   %eax,%eax
  800948:	0f 84 8b 00 00 00    	je     8009d9 <vprintfmt+0x48b>
			putch(ch, putdat);
  80094e:	83 ec 08             	sub    $0x8,%esp
  800951:	53                   	push   %ebx
  800952:	50                   	push   %eax
  800953:	ff d6                	call   *%esi
  800955:	83 c4 10             	add    $0x10,%esp
  800958:	eb dc                	jmp    800936 <vprintfmt+0x3e8>
	if (lflag >= 2)
  80095a:	83 f9 01             	cmp    $0x1,%ecx
  80095d:	7f 1b                	jg     80097a <vprintfmt+0x42c>
	else if (lflag)
  80095f:	85 c9                	test   %ecx,%ecx
  800961:	74 2c                	je     80098f <vprintfmt+0x441>
		return va_arg(*ap, unsigned long);
  800963:	8b 45 14             	mov    0x14(%ebp),%eax
  800966:	8b 10                	mov    (%eax),%edx
  800968:	b9 00 00 00 00       	mov    $0x0,%ecx
  80096d:	8d 40 04             	lea    0x4(%eax),%eax
  800970:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800973:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  800978:	eb 9f                	jmp    800919 <vprintfmt+0x3cb>
		return va_arg(*ap, unsigned long long);
  80097a:	8b 45 14             	mov    0x14(%ebp),%eax
  80097d:	8b 10                	mov    (%eax),%edx
  80097f:	8b 48 04             	mov    0x4(%eax),%ecx
  800982:	8d 40 08             	lea    0x8(%eax),%eax
  800985:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800988:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  80098d:	eb 8a                	jmp    800919 <vprintfmt+0x3cb>
		return va_arg(*ap, unsigned int);
  80098f:	8b 45 14             	mov    0x14(%ebp),%eax
  800992:	8b 10                	mov    (%eax),%edx
  800994:	b9 00 00 00 00       	mov    $0x0,%ecx
  800999:	8d 40 04             	lea    0x4(%eax),%eax
  80099c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80099f:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  8009a4:	e9 70 ff ff ff       	jmp    800919 <vprintfmt+0x3cb>
			putch(ch, putdat);
  8009a9:	83 ec 08             	sub    $0x8,%esp
  8009ac:	53                   	push   %ebx
  8009ad:	6a 25                	push   $0x25
  8009af:	ff d6                	call   *%esi
			break;
  8009b1:	83 c4 10             	add    $0x10,%esp
  8009b4:	e9 7a ff ff ff       	jmp    800933 <vprintfmt+0x3e5>
			putch('%', putdat);
  8009b9:	83 ec 08             	sub    $0x8,%esp
  8009bc:	53                   	push   %ebx
  8009bd:	6a 25                	push   $0x25
  8009bf:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8009c1:	83 c4 10             	add    $0x10,%esp
  8009c4:	89 f8                	mov    %edi,%eax
  8009c6:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8009ca:	74 05                	je     8009d1 <vprintfmt+0x483>
  8009cc:	83 e8 01             	sub    $0x1,%eax
  8009cf:	eb f5                	jmp    8009c6 <vprintfmt+0x478>
  8009d1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8009d4:	e9 5a ff ff ff       	jmp    800933 <vprintfmt+0x3e5>
}
  8009d9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8009dc:	5b                   	pop    %ebx
  8009dd:	5e                   	pop    %esi
  8009de:	5f                   	pop    %edi
  8009df:	5d                   	pop    %ebp
  8009e0:	c3                   	ret    

008009e1 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8009e1:	f3 0f 1e fb          	endbr32 
  8009e5:	55                   	push   %ebp
  8009e6:	89 e5                	mov    %esp,%ebp
  8009e8:	83 ec 18             	sub    $0x18,%esp
  8009eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ee:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8009f1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8009f4:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8009f8:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8009fb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800a02:	85 c0                	test   %eax,%eax
  800a04:	74 26                	je     800a2c <vsnprintf+0x4b>
  800a06:	85 d2                	test   %edx,%edx
  800a08:	7e 22                	jle    800a2c <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800a0a:	ff 75 14             	pushl  0x14(%ebp)
  800a0d:	ff 75 10             	pushl  0x10(%ebp)
  800a10:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800a13:	50                   	push   %eax
  800a14:	68 0c 05 80 00       	push   $0x80050c
  800a19:	e8 30 fb ff ff       	call   80054e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800a1e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800a21:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800a24:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800a27:	83 c4 10             	add    $0x10,%esp
}
  800a2a:	c9                   	leave  
  800a2b:	c3                   	ret    
		return -E_INVAL;
  800a2c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800a31:	eb f7                	jmp    800a2a <vsnprintf+0x49>

00800a33 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800a33:	f3 0f 1e fb          	endbr32 
  800a37:	55                   	push   %ebp
  800a38:	89 e5                	mov    %esp,%ebp
  800a3a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800a3d:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800a40:	50                   	push   %eax
  800a41:	ff 75 10             	pushl  0x10(%ebp)
  800a44:	ff 75 0c             	pushl  0xc(%ebp)
  800a47:	ff 75 08             	pushl  0x8(%ebp)
  800a4a:	e8 92 ff ff ff       	call   8009e1 <vsnprintf>
	va_end(ap);

	return rc;
}
  800a4f:	c9                   	leave  
  800a50:	c3                   	ret    

00800a51 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800a51:	f3 0f 1e fb          	endbr32 
  800a55:	55                   	push   %ebp
  800a56:	89 e5                	mov    %esp,%ebp
  800a58:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a5b:	b8 00 00 00 00       	mov    $0x0,%eax
  800a60:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a64:	74 05                	je     800a6b <strlen+0x1a>
		n++;
  800a66:	83 c0 01             	add    $0x1,%eax
  800a69:	eb f5                	jmp    800a60 <strlen+0xf>
	return n;
}
  800a6b:	5d                   	pop    %ebp
  800a6c:	c3                   	ret    

00800a6d <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a6d:	f3 0f 1e fb          	endbr32 
  800a71:	55                   	push   %ebp
  800a72:	89 e5                	mov    %esp,%ebp
  800a74:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a77:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a7a:	b8 00 00 00 00       	mov    $0x0,%eax
  800a7f:	39 d0                	cmp    %edx,%eax
  800a81:	74 0d                	je     800a90 <strnlen+0x23>
  800a83:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800a87:	74 05                	je     800a8e <strnlen+0x21>
		n++;
  800a89:	83 c0 01             	add    $0x1,%eax
  800a8c:	eb f1                	jmp    800a7f <strnlen+0x12>
  800a8e:	89 c2                	mov    %eax,%edx
	return n;
}
  800a90:	89 d0                	mov    %edx,%eax
  800a92:	5d                   	pop    %ebp
  800a93:	c3                   	ret    

00800a94 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a94:	f3 0f 1e fb          	endbr32 
  800a98:	55                   	push   %ebp
  800a99:	89 e5                	mov    %esp,%ebp
  800a9b:	53                   	push   %ebx
  800a9c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a9f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800aa2:	b8 00 00 00 00       	mov    $0x0,%eax
  800aa7:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800aab:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800aae:	83 c0 01             	add    $0x1,%eax
  800ab1:	84 d2                	test   %dl,%dl
  800ab3:	75 f2                	jne    800aa7 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  800ab5:	89 c8                	mov    %ecx,%eax
  800ab7:	5b                   	pop    %ebx
  800ab8:	5d                   	pop    %ebp
  800ab9:	c3                   	ret    

00800aba <strcat>:

char *
strcat(char *dst, const char *src)
{
  800aba:	f3 0f 1e fb          	endbr32 
  800abe:	55                   	push   %ebp
  800abf:	89 e5                	mov    %esp,%ebp
  800ac1:	53                   	push   %ebx
  800ac2:	83 ec 10             	sub    $0x10,%esp
  800ac5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800ac8:	53                   	push   %ebx
  800ac9:	e8 83 ff ff ff       	call   800a51 <strlen>
  800ace:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800ad1:	ff 75 0c             	pushl  0xc(%ebp)
  800ad4:	01 d8                	add    %ebx,%eax
  800ad6:	50                   	push   %eax
  800ad7:	e8 b8 ff ff ff       	call   800a94 <strcpy>
	return dst;
}
  800adc:	89 d8                	mov    %ebx,%eax
  800ade:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ae1:	c9                   	leave  
  800ae2:	c3                   	ret    

00800ae3 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800ae3:	f3 0f 1e fb          	endbr32 
  800ae7:	55                   	push   %ebp
  800ae8:	89 e5                	mov    %esp,%ebp
  800aea:	56                   	push   %esi
  800aeb:	53                   	push   %ebx
  800aec:	8b 75 08             	mov    0x8(%ebp),%esi
  800aef:	8b 55 0c             	mov    0xc(%ebp),%edx
  800af2:	89 f3                	mov    %esi,%ebx
  800af4:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800af7:	89 f0                	mov    %esi,%eax
  800af9:	39 d8                	cmp    %ebx,%eax
  800afb:	74 11                	je     800b0e <strncpy+0x2b>
		*dst++ = *src;
  800afd:	83 c0 01             	add    $0x1,%eax
  800b00:	0f b6 0a             	movzbl (%edx),%ecx
  800b03:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800b06:	80 f9 01             	cmp    $0x1,%cl
  800b09:	83 da ff             	sbb    $0xffffffff,%edx
  800b0c:	eb eb                	jmp    800af9 <strncpy+0x16>
	}
	return ret;
}
  800b0e:	89 f0                	mov    %esi,%eax
  800b10:	5b                   	pop    %ebx
  800b11:	5e                   	pop    %esi
  800b12:	5d                   	pop    %ebp
  800b13:	c3                   	ret    

00800b14 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800b14:	f3 0f 1e fb          	endbr32 
  800b18:	55                   	push   %ebp
  800b19:	89 e5                	mov    %esp,%ebp
  800b1b:	56                   	push   %esi
  800b1c:	53                   	push   %ebx
  800b1d:	8b 75 08             	mov    0x8(%ebp),%esi
  800b20:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b23:	8b 55 10             	mov    0x10(%ebp),%edx
  800b26:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800b28:	85 d2                	test   %edx,%edx
  800b2a:	74 21                	je     800b4d <strlcpy+0x39>
  800b2c:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800b30:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  800b32:	39 c2                	cmp    %eax,%edx
  800b34:	74 14                	je     800b4a <strlcpy+0x36>
  800b36:	0f b6 19             	movzbl (%ecx),%ebx
  800b39:	84 db                	test   %bl,%bl
  800b3b:	74 0b                	je     800b48 <strlcpy+0x34>
			*dst++ = *src++;
  800b3d:	83 c1 01             	add    $0x1,%ecx
  800b40:	83 c2 01             	add    $0x1,%edx
  800b43:	88 5a ff             	mov    %bl,-0x1(%edx)
  800b46:	eb ea                	jmp    800b32 <strlcpy+0x1e>
  800b48:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800b4a:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800b4d:	29 f0                	sub    %esi,%eax
}
  800b4f:	5b                   	pop    %ebx
  800b50:	5e                   	pop    %esi
  800b51:	5d                   	pop    %ebp
  800b52:	c3                   	ret    

00800b53 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800b53:	f3 0f 1e fb          	endbr32 
  800b57:	55                   	push   %ebp
  800b58:	89 e5                	mov    %esp,%ebp
  800b5a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b5d:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800b60:	0f b6 01             	movzbl (%ecx),%eax
  800b63:	84 c0                	test   %al,%al
  800b65:	74 0c                	je     800b73 <strcmp+0x20>
  800b67:	3a 02                	cmp    (%edx),%al
  800b69:	75 08                	jne    800b73 <strcmp+0x20>
		p++, q++;
  800b6b:	83 c1 01             	add    $0x1,%ecx
  800b6e:	83 c2 01             	add    $0x1,%edx
  800b71:	eb ed                	jmp    800b60 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800b73:	0f b6 c0             	movzbl %al,%eax
  800b76:	0f b6 12             	movzbl (%edx),%edx
  800b79:	29 d0                	sub    %edx,%eax
}
  800b7b:	5d                   	pop    %ebp
  800b7c:	c3                   	ret    

00800b7d <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b7d:	f3 0f 1e fb          	endbr32 
  800b81:	55                   	push   %ebp
  800b82:	89 e5                	mov    %esp,%ebp
  800b84:	53                   	push   %ebx
  800b85:	8b 45 08             	mov    0x8(%ebp),%eax
  800b88:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b8b:	89 c3                	mov    %eax,%ebx
  800b8d:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800b90:	eb 06                	jmp    800b98 <strncmp+0x1b>
		n--, p++, q++;
  800b92:	83 c0 01             	add    $0x1,%eax
  800b95:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800b98:	39 d8                	cmp    %ebx,%eax
  800b9a:	74 16                	je     800bb2 <strncmp+0x35>
  800b9c:	0f b6 08             	movzbl (%eax),%ecx
  800b9f:	84 c9                	test   %cl,%cl
  800ba1:	74 04                	je     800ba7 <strncmp+0x2a>
  800ba3:	3a 0a                	cmp    (%edx),%cl
  800ba5:	74 eb                	je     800b92 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800ba7:	0f b6 00             	movzbl (%eax),%eax
  800baa:	0f b6 12             	movzbl (%edx),%edx
  800bad:	29 d0                	sub    %edx,%eax
}
  800baf:	5b                   	pop    %ebx
  800bb0:	5d                   	pop    %ebp
  800bb1:	c3                   	ret    
		return 0;
  800bb2:	b8 00 00 00 00       	mov    $0x0,%eax
  800bb7:	eb f6                	jmp    800baf <strncmp+0x32>

00800bb9 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800bb9:	f3 0f 1e fb          	endbr32 
  800bbd:	55                   	push   %ebp
  800bbe:	89 e5                	mov    %esp,%ebp
  800bc0:	8b 45 08             	mov    0x8(%ebp),%eax
  800bc3:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800bc7:	0f b6 10             	movzbl (%eax),%edx
  800bca:	84 d2                	test   %dl,%dl
  800bcc:	74 09                	je     800bd7 <strchr+0x1e>
		if (*s == c)
  800bce:	38 ca                	cmp    %cl,%dl
  800bd0:	74 0a                	je     800bdc <strchr+0x23>
	for (; *s; s++)
  800bd2:	83 c0 01             	add    $0x1,%eax
  800bd5:	eb f0                	jmp    800bc7 <strchr+0xe>
			return (char *) s;
	return 0;
  800bd7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bdc:	5d                   	pop    %ebp
  800bdd:	c3                   	ret    

00800bde <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800bde:	f3 0f 1e fb          	endbr32 
  800be2:	55                   	push   %ebp
  800be3:	89 e5                	mov    %esp,%ebp
  800be5:	8b 45 08             	mov    0x8(%ebp),%eax
  800be8:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800bec:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800bef:	38 ca                	cmp    %cl,%dl
  800bf1:	74 09                	je     800bfc <strfind+0x1e>
  800bf3:	84 d2                	test   %dl,%dl
  800bf5:	74 05                	je     800bfc <strfind+0x1e>
	for (; *s; s++)
  800bf7:	83 c0 01             	add    $0x1,%eax
  800bfa:	eb f0                	jmp    800bec <strfind+0xe>
			break;
	return (char *) s;
}
  800bfc:	5d                   	pop    %ebp
  800bfd:	c3                   	ret    

00800bfe <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800bfe:	f3 0f 1e fb          	endbr32 
  800c02:	55                   	push   %ebp
  800c03:	89 e5                	mov    %esp,%ebp
  800c05:	57                   	push   %edi
  800c06:	56                   	push   %esi
  800c07:	53                   	push   %ebx
  800c08:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c0b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800c0e:	85 c9                	test   %ecx,%ecx
  800c10:	74 31                	je     800c43 <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800c12:	89 f8                	mov    %edi,%eax
  800c14:	09 c8                	or     %ecx,%eax
  800c16:	a8 03                	test   $0x3,%al
  800c18:	75 23                	jne    800c3d <memset+0x3f>
		c &= 0xFF;
  800c1a:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800c1e:	89 d3                	mov    %edx,%ebx
  800c20:	c1 e3 08             	shl    $0x8,%ebx
  800c23:	89 d0                	mov    %edx,%eax
  800c25:	c1 e0 18             	shl    $0x18,%eax
  800c28:	89 d6                	mov    %edx,%esi
  800c2a:	c1 e6 10             	shl    $0x10,%esi
  800c2d:	09 f0                	or     %esi,%eax
  800c2f:	09 c2                	or     %eax,%edx
  800c31:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800c33:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800c36:	89 d0                	mov    %edx,%eax
  800c38:	fc                   	cld    
  800c39:	f3 ab                	rep stos %eax,%es:(%edi)
  800c3b:	eb 06                	jmp    800c43 <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800c3d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c40:	fc                   	cld    
  800c41:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800c43:	89 f8                	mov    %edi,%eax
  800c45:	5b                   	pop    %ebx
  800c46:	5e                   	pop    %esi
  800c47:	5f                   	pop    %edi
  800c48:	5d                   	pop    %ebp
  800c49:	c3                   	ret    

00800c4a <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800c4a:	f3 0f 1e fb          	endbr32 
  800c4e:	55                   	push   %ebp
  800c4f:	89 e5                	mov    %esp,%ebp
  800c51:	57                   	push   %edi
  800c52:	56                   	push   %esi
  800c53:	8b 45 08             	mov    0x8(%ebp),%eax
  800c56:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c59:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800c5c:	39 c6                	cmp    %eax,%esi
  800c5e:	73 32                	jae    800c92 <memmove+0x48>
  800c60:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c63:	39 c2                	cmp    %eax,%edx
  800c65:	76 2b                	jbe    800c92 <memmove+0x48>
		s += n;
		d += n;
  800c67:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c6a:	89 fe                	mov    %edi,%esi
  800c6c:	09 ce                	or     %ecx,%esi
  800c6e:	09 d6                	or     %edx,%esi
  800c70:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c76:	75 0e                	jne    800c86 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800c78:	83 ef 04             	sub    $0x4,%edi
  800c7b:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c7e:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800c81:	fd                   	std    
  800c82:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c84:	eb 09                	jmp    800c8f <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800c86:	83 ef 01             	sub    $0x1,%edi
  800c89:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800c8c:	fd                   	std    
  800c8d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c8f:	fc                   	cld    
  800c90:	eb 1a                	jmp    800cac <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c92:	89 c2                	mov    %eax,%edx
  800c94:	09 ca                	or     %ecx,%edx
  800c96:	09 f2                	or     %esi,%edx
  800c98:	f6 c2 03             	test   $0x3,%dl
  800c9b:	75 0a                	jne    800ca7 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800c9d:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800ca0:	89 c7                	mov    %eax,%edi
  800ca2:	fc                   	cld    
  800ca3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ca5:	eb 05                	jmp    800cac <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800ca7:	89 c7                	mov    %eax,%edi
  800ca9:	fc                   	cld    
  800caa:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800cac:	5e                   	pop    %esi
  800cad:	5f                   	pop    %edi
  800cae:	5d                   	pop    %ebp
  800caf:	c3                   	ret    

00800cb0 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800cb0:	f3 0f 1e fb          	endbr32 
  800cb4:	55                   	push   %ebp
  800cb5:	89 e5                	mov    %esp,%ebp
  800cb7:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800cba:	ff 75 10             	pushl  0x10(%ebp)
  800cbd:	ff 75 0c             	pushl  0xc(%ebp)
  800cc0:	ff 75 08             	pushl  0x8(%ebp)
  800cc3:	e8 82 ff ff ff       	call   800c4a <memmove>
}
  800cc8:	c9                   	leave  
  800cc9:	c3                   	ret    

00800cca <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800cca:	f3 0f 1e fb          	endbr32 
  800cce:	55                   	push   %ebp
  800ccf:	89 e5                	mov    %esp,%ebp
  800cd1:	56                   	push   %esi
  800cd2:	53                   	push   %ebx
  800cd3:	8b 45 08             	mov    0x8(%ebp),%eax
  800cd6:	8b 55 0c             	mov    0xc(%ebp),%edx
  800cd9:	89 c6                	mov    %eax,%esi
  800cdb:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800cde:	39 f0                	cmp    %esi,%eax
  800ce0:	74 1c                	je     800cfe <memcmp+0x34>
		if (*s1 != *s2)
  800ce2:	0f b6 08             	movzbl (%eax),%ecx
  800ce5:	0f b6 1a             	movzbl (%edx),%ebx
  800ce8:	38 d9                	cmp    %bl,%cl
  800cea:	75 08                	jne    800cf4 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800cec:	83 c0 01             	add    $0x1,%eax
  800cef:	83 c2 01             	add    $0x1,%edx
  800cf2:	eb ea                	jmp    800cde <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800cf4:	0f b6 c1             	movzbl %cl,%eax
  800cf7:	0f b6 db             	movzbl %bl,%ebx
  800cfa:	29 d8                	sub    %ebx,%eax
  800cfc:	eb 05                	jmp    800d03 <memcmp+0x39>
	}

	return 0;
  800cfe:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d03:	5b                   	pop    %ebx
  800d04:	5e                   	pop    %esi
  800d05:	5d                   	pop    %ebp
  800d06:	c3                   	ret    

00800d07 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800d07:	f3 0f 1e fb          	endbr32 
  800d0b:	55                   	push   %ebp
  800d0c:	89 e5                	mov    %esp,%ebp
  800d0e:	8b 45 08             	mov    0x8(%ebp),%eax
  800d11:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800d14:	89 c2                	mov    %eax,%edx
  800d16:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800d19:	39 d0                	cmp    %edx,%eax
  800d1b:	73 09                	jae    800d26 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d1d:	38 08                	cmp    %cl,(%eax)
  800d1f:	74 05                	je     800d26 <memfind+0x1f>
	for (; s < ends; s++)
  800d21:	83 c0 01             	add    $0x1,%eax
  800d24:	eb f3                	jmp    800d19 <memfind+0x12>
			break;
	return (void *) s;
}
  800d26:	5d                   	pop    %ebp
  800d27:	c3                   	ret    

00800d28 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800d28:	f3 0f 1e fb          	endbr32 
  800d2c:	55                   	push   %ebp
  800d2d:	89 e5                	mov    %esp,%ebp
  800d2f:	57                   	push   %edi
  800d30:	56                   	push   %esi
  800d31:	53                   	push   %ebx
  800d32:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d35:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d38:	eb 03                	jmp    800d3d <strtol+0x15>
		s++;
  800d3a:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800d3d:	0f b6 01             	movzbl (%ecx),%eax
  800d40:	3c 20                	cmp    $0x20,%al
  800d42:	74 f6                	je     800d3a <strtol+0x12>
  800d44:	3c 09                	cmp    $0x9,%al
  800d46:	74 f2                	je     800d3a <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800d48:	3c 2b                	cmp    $0x2b,%al
  800d4a:	74 2a                	je     800d76 <strtol+0x4e>
	int neg = 0;
  800d4c:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800d51:	3c 2d                	cmp    $0x2d,%al
  800d53:	74 2b                	je     800d80 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d55:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800d5b:	75 0f                	jne    800d6c <strtol+0x44>
  800d5d:	80 39 30             	cmpb   $0x30,(%ecx)
  800d60:	74 28                	je     800d8a <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800d62:	85 db                	test   %ebx,%ebx
  800d64:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d69:	0f 44 d8             	cmove  %eax,%ebx
  800d6c:	b8 00 00 00 00       	mov    $0x0,%eax
  800d71:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800d74:	eb 46                	jmp    800dbc <strtol+0x94>
		s++;
  800d76:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800d79:	bf 00 00 00 00       	mov    $0x0,%edi
  800d7e:	eb d5                	jmp    800d55 <strtol+0x2d>
		s++, neg = 1;
  800d80:	83 c1 01             	add    $0x1,%ecx
  800d83:	bf 01 00 00 00       	mov    $0x1,%edi
  800d88:	eb cb                	jmp    800d55 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d8a:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800d8e:	74 0e                	je     800d9e <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800d90:	85 db                	test   %ebx,%ebx
  800d92:	75 d8                	jne    800d6c <strtol+0x44>
		s++, base = 8;
  800d94:	83 c1 01             	add    $0x1,%ecx
  800d97:	bb 08 00 00 00       	mov    $0x8,%ebx
  800d9c:	eb ce                	jmp    800d6c <strtol+0x44>
		s += 2, base = 16;
  800d9e:	83 c1 02             	add    $0x2,%ecx
  800da1:	bb 10 00 00 00       	mov    $0x10,%ebx
  800da6:	eb c4                	jmp    800d6c <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800da8:	0f be d2             	movsbl %dl,%edx
  800dab:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800dae:	3b 55 10             	cmp    0x10(%ebp),%edx
  800db1:	7d 3a                	jge    800ded <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800db3:	83 c1 01             	add    $0x1,%ecx
  800db6:	0f af 45 10          	imul   0x10(%ebp),%eax
  800dba:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800dbc:	0f b6 11             	movzbl (%ecx),%edx
  800dbf:	8d 72 d0             	lea    -0x30(%edx),%esi
  800dc2:	89 f3                	mov    %esi,%ebx
  800dc4:	80 fb 09             	cmp    $0x9,%bl
  800dc7:	76 df                	jbe    800da8 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800dc9:	8d 72 9f             	lea    -0x61(%edx),%esi
  800dcc:	89 f3                	mov    %esi,%ebx
  800dce:	80 fb 19             	cmp    $0x19,%bl
  800dd1:	77 08                	ja     800ddb <strtol+0xb3>
			dig = *s - 'a' + 10;
  800dd3:	0f be d2             	movsbl %dl,%edx
  800dd6:	83 ea 57             	sub    $0x57,%edx
  800dd9:	eb d3                	jmp    800dae <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800ddb:	8d 72 bf             	lea    -0x41(%edx),%esi
  800dde:	89 f3                	mov    %esi,%ebx
  800de0:	80 fb 19             	cmp    $0x19,%bl
  800de3:	77 08                	ja     800ded <strtol+0xc5>
			dig = *s - 'A' + 10;
  800de5:	0f be d2             	movsbl %dl,%edx
  800de8:	83 ea 37             	sub    $0x37,%edx
  800deb:	eb c1                	jmp    800dae <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800ded:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800df1:	74 05                	je     800df8 <strtol+0xd0>
		*endptr = (char *) s;
  800df3:	8b 75 0c             	mov    0xc(%ebp),%esi
  800df6:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800df8:	89 c2                	mov    %eax,%edx
  800dfa:	f7 da                	neg    %edx
  800dfc:	85 ff                	test   %edi,%edi
  800dfe:	0f 45 c2             	cmovne %edx,%eax
}
  800e01:	5b                   	pop    %ebx
  800e02:	5e                   	pop    %esi
  800e03:	5f                   	pop    %edi
  800e04:	5d                   	pop    %ebp
  800e05:	c3                   	ret    
  800e06:	66 90                	xchg   %ax,%ax
  800e08:	66 90                	xchg   %ax,%ax
  800e0a:	66 90                	xchg   %ax,%ax
  800e0c:	66 90                	xchg   %ax,%ax
  800e0e:	66 90                	xchg   %ax,%ax

00800e10 <__udivdi3>:
  800e10:	f3 0f 1e fb          	endbr32 
  800e14:	55                   	push   %ebp
  800e15:	57                   	push   %edi
  800e16:	56                   	push   %esi
  800e17:	53                   	push   %ebx
  800e18:	83 ec 1c             	sub    $0x1c,%esp
  800e1b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800e1f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800e23:	8b 74 24 34          	mov    0x34(%esp),%esi
  800e27:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800e2b:	85 d2                	test   %edx,%edx
  800e2d:	75 19                	jne    800e48 <__udivdi3+0x38>
  800e2f:	39 f3                	cmp    %esi,%ebx
  800e31:	76 4d                	jbe    800e80 <__udivdi3+0x70>
  800e33:	31 ff                	xor    %edi,%edi
  800e35:	89 e8                	mov    %ebp,%eax
  800e37:	89 f2                	mov    %esi,%edx
  800e39:	f7 f3                	div    %ebx
  800e3b:	89 fa                	mov    %edi,%edx
  800e3d:	83 c4 1c             	add    $0x1c,%esp
  800e40:	5b                   	pop    %ebx
  800e41:	5e                   	pop    %esi
  800e42:	5f                   	pop    %edi
  800e43:	5d                   	pop    %ebp
  800e44:	c3                   	ret    
  800e45:	8d 76 00             	lea    0x0(%esi),%esi
  800e48:	39 f2                	cmp    %esi,%edx
  800e4a:	76 14                	jbe    800e60 <__udivdi3+0x50>
  800e4c:	31 ff                	xor    %edi,%edi
  800e4e:	31 c0                	xor    %eax,%eax
  800e50:	89 fa                	mov    %edi,%edx
  800e52:	83 c4 1c             	add    $0x1c,%esp
  800e55:	5b                   	pop    %ebx
  800e56:	5e                   	pop    %esi
  800e57:	5f                   	pop    %edi
  800e58:	5d                   	pop    %ebp
  800e59:	c3                   	ret    
  800e5a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800e60:	0f bd fa             	bsr    %edx,%edi
  800e63:	83 f7 1f             	xor    $0x1f,%edi
  800e66:	75 48                	jne    800eb0 <__udivdi3+0xa0>
  800e68:	39 f2                	cmp    %esi,%edx
  800e6a:	72 06                	jb     800e72 <__udivdi3+0x62>
  800e6c:	31 c0                	xor    %eax,%eax
  800e6e:	39 eb                	cmp    %ebp,%ebx
  800e70:	77 de                	ja     800e50 <__udivdi3+0x40>
  800e72:	b8 01 00 00 00       	mov    $0x1,%eax
  800e77:	eb d7                	jmp    800e50 <__udivdi3+0x40>
  800e79:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e80:	89 d9                	mov    %ebx,%ecx
  800e82:	85 db                	test   %ebx,%ebx
  800e84:	75 0b                	jne    800e91 <__udivdi3+0x81>
  800e86:	b8 01 00 00 00       	mov    $0x1,%eax
  800e8b:	31 d2                	xor    %edx,%edx
  800e8d:	f7 f3                	div    %ebx
  800e8f:	89 c1                	mov    %eax,%ecx
  800e91:	31 d2                	xor    %edx,%edx
  800e93:	89 f0                	mov    %esi,%eax
  800e95:	f7 f1                	div    %ecx
  800e97:	89 c6                	mov    %eax,%esi
  800e99:	89 e8                	mov    %ebp,%eax
  800e9b:	89 f7                	mov    %esi,%edi
  800e9d:	f7 f1                	div    %ecx
  800e9f:	89 fa                	mov    %edi,%edx
  800ea1:	83 c4 1c             	add    $0x1c,%esp
  800ea4:	5b                   	pop    %ebx
  800ea5:	5e                   	pop    %esi
  800ea6:	5f                   	pop    %edi
  800ea7:	5d                   	pop    %ebp
  800ea8:	c3                   	ret    
  800ea9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800eb0:	89 f9                	mov    %edi,%ecx
  800eb2:	b8 20 00 00 00       	mov    $0x20,%eax
  800eb7:	29 f8                	sub    %edi,%eax
  800eb9:	d3 e2                	shl    %cl,%edx
  800ebb:	89 54 24 08          	mov    %edx,0x8(%esp)
  800ebf:	89 c1                	mov    %eax,%ecx
  800ec1:	89 da                	mov    %ebx,%edx
  800ec3:	d3 ea                	shr    %cl,%edx
  800ec5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800ec9:	09 d1                	or     %edx,%ecx
  800ecb:	89 f2                	mov    %esi,%edx
  800ecd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800ed1:	89 f9                	mov    %edi,%ecx
  800ed3:	d3 e3                	shl    %cl,%ebx
  800ed5:	89 c1                	mov    %eax,%ecx
  800ed7:	d3 ea                	shr    %cl,%edx
  800ed9:	89 f9                	mov    %edi,%ecx
  800edb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800edf:	89 eb                	mov    %ebp,%ebx
  800ee1:	d3 e6                	shl    %cl,%esi
  800ee3:	89 c1                	mov    %eax,%ecx
  800ee5:	d3 eb                	shr    %cl,%ebx
  800ee7:	09 de                	or     %ebx,%esi
  800ee9:	89 f0                	mov    %esi,%eax
  800eeb:	f7 74 24 08          	divl   0x8(%esp)
  800eef:	89 d6                	mov    %edx,%esi
  800ef1:	89 c3                	mov    %eax,%ebx
  800ef3:	f7 64 24 0c          	mull   0xc(%esp)
  800ef7:	39 d6                	cmp    %edx,%esi
  800ef9:	72 15                	jb     800f10 <__udivdi3+0x100>
  800efb:	89 f9                	mov    %edi,%ecx
  800efd:	d3 e5                	shl    %cl,%ebp
  800eff:	39 c5                	cmp    %eax,%ebp
  800f01:	73 04                	jae    800f07 <__udivdi3+0xf7>
  800f03:	39 d6                	cmp    %edx,%esi
  800f05:	74 09                	je     800f10 <__udivdi3+0x100>
  800f07:	89 d8                	mov    %ebx,%eax
  800f09:	31 ff                	xor    %edi,%edi
  800f0b:	e9 40 ff ff ff       	jmp    800e50 <__udivdi3+0x40>
  800f10:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800f13:	31 ff                	xor    %edi,%edi
  800f15:	e9 36 ff ff ff       	jmp    800e50 <__udivdi3+0x40>
  800f1a:	66 90                	xchg   %ax,%ax
  800f1c:	66 90                	xchg   %ax,%ax
  800f1e:	66 90                	xchg   %ax,%ax

00800f20 <__umoddi3>:
  800f20:	f3 0f 1e fb          	endbr32 
  800f24:	55                   	push   %ebp
  800f25:	57                   	push   %edi
  800f26:	56                   	push   %esi
  800f27:	53                   	push   %ebx
  800f28:	83 ec 1c             	sub    $0x1c,%esp
  800f2b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  800f2f:	8b 74 24 30          	mov    0x30(%esp),%esi
  800f33:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800f37:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800f3b:	85 c0                	test   %eax,%eax
  800f3d:	75 19                	jne    800f58 <__umoddi3+0x38>
  800f3f:	39 df                	cmp    %ebx,%edi
  800f41:	76 5d                	jbe    800fa0 <__umoddi3+0x80>
  800f43:	89 f0                	mov    %esi,%eax
  800f45:	89 da                	mov    %ebx,%edx
  800f47:	f7 f7                	div    %edi
  800f49:	89 d0                	mov    %edx,%eax
  800f4b:	31 d2                	xor    %edx,%edx
  800f4d:	83 c4 1c             	add    $0x1c,%esp
  800f50:	5b                   	pop    %ebx
  800f51:	5e                   	pop    %esi
  800f52:	5f                   	pop    %edi
  800f53:	5d                   	pop    %ebp
  800f54:	c3                   	ret    
  800f55:	8d 76 00             	lea    0x0(%esi),%esi
  800f58:	89 f2                	mov    %esi,%edx
  800f5a:	39 d8                	cmp    %ebx,%eax
  800f5c:	76 12                	jbe    800f70 <__umoddi3+0x50>
  800f5e:	89 f0                	mov    %esi,%eax
  800f60:	89 da                	mov    %ebx,%edx
  800f62:	83 c4 1c             	add    $0x1c,%esp
  800f65:	5b                   	pop    %ebx
  800f66:	5e                   	pop    %esi
  800f67:	5f                   	pop    %edi
  800f68:	5d                   	pop    %ebp
  800f69:	c3                   	ret    
  800f6a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800f70:	0f bd e8             	bsr    %eax,%ebp
  800f73:	83 f5 1f             	xor    $0x1f,%ebp
  800f76:	75 50                	jne    800fc8 <__umoddi3+0xa8>
  800f78:	39 d8                	cmp    %ebx,%eax
  800f7a:	0f 82 e0 00 00 00    	jb     801060 <__umoddi3+0x140>
  800f80:	89 d9                	mov    %ebx,%ecx
  800f82:	39 f7                	cmp    %esi,%edi
  800f84:	0f 86 d6 00 00 00    	jbe    801060 <__umoddi3+0x140>
  800f8a:	89 d0                	mov    %edx,%eax
  800f8c:	89 ca                	mov    %ecx,%edx
  800f8e:	83 c4 1c             	add    $0x1c,%esp
  800f91:	5b                   	pop    %ebx
  800f92:	5e                   	pop    %esi
  800f93:	5f                   	pop    %edi
  800f94:	5d                   	pop    %ebp
  800f95:	c3                   	ret    
  800f96:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f9d:	8d 76 00             	lea    0x0(%esi),%esi
  800fa0:	89 fd                	mov    %edi,%ebp
  800fa2:	85 ff                	test   %edi,%edi
  800fa4:	75 0b                	jne    800fb1 <__umoddi3+0x91>
  800fa6:	b8 01 00 00 00       	mov    $0x1,%eax
  800fab:	31 d2                	xor    %edx,%edx
  800fad:	f7 f7                	div    %edi
  800faf:	89 c5                	mov    %eax,%ebp
  800fb1:	89 d8                	mov    %ebx,%eax
  800fb3:	31 d2                	xor    %edx,%edx
  800fb5:	f7 f5                	div    %ebp
  800fb7:	89 f0                	mov    %esi,%eax
  800fb9:	f7 f5                	div    %ebp
  800fbb:	89 d0                	mov    %edx,%eax
  800fbd:	31 d2                	xor    %edx,%edx
  800fbf:	eb 8c                	jmp    800f4d <__umoddi3+0x2d>
  800fc1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800fc8:	89 e9                	mov    %ebp,%ecx
  800fca:	ba 20 00 00 00       	mov    $0x20,%edx
  800fcf:	29 ea                	sub    %ebp,%edx
  800fd1:	d3 e0                	shl    %cl,%eax
  800fd3:	89 44 24 08          	mov    %eax,0x8(%esp)
  800fd7:	89 d1                	mov    %edx,%ecx
  800fd9:	89 f8                	mov    %edi,%eax
  800fdb:	d3 e8                	shr    %cl,%eax
  800fdd:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800fe1:	89 54 24 04          	mov    %edx,0x4(%esp)
  800fe5:	8b 54 24 04          	mov    0x4(%esp),%edx
  800fe9:	09 c1                	or     %eax,%ecx
  800feb:	89 d8                	mov    %ebx,%eax
  800fed:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800ff1:	89 e9                	mov    %ebp,%ecx
  800ff3:	d3 e7                	shl    %cl,%edi
  800ff5:	89 d1                	mov    %edx,%ecx
  800ff7:	d3 e8                	shr    %cl,%eax
  800ff9:	89 e9                	mov    %ebp,%ecx
  800ffb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800fff:	d3 e3                	shl    %cl,%ebx
  801001:	89 c7                	mov    %eax,%edi
  801003:	89 d1                	mov    %edx,%ecx
  801005:	89 f0                	mov    %esi,%eax
  801007:	d3 e8                	shr    %cl,%eax
  801009:	89 e9                	mov    %ebp,%ecx
  80100b:	89 fa                	mov    %edi,%edx
  80100d:	d3 e6                	shl    %cl,%esi
  80100f:	09 d8                	or     %ebx,%eax
  801011:	f7 74 24 08          	divl   0x8(%esp)
  801015:	89 d1                	mov    %edx,%ecx
  801017:	89 f3                	mov    %esi,%ebx
  801019:	f7 64 24 0c          	mull   0xc(%esp)
  80101d:	89 c6                	mov    %eax,%esi
  80101f:	89 d7                	mov    %edx,%edi
  801021:	39 d1                	cmp    %edx,%ecx
  801023:	72 06                	jb     80102b <__umoddi3+0x10b>
  801025:	75 10                	jne    801037 <__umoddi3+0x117>
  801027:	39 c3                	cmp    %eax,%ebx
  801029:	73 0c                	jae    801037 <__umoddi3+0x117>
  80102b:	2b 44 24 0c          	sub    0xc(%esp),%eax
  80102f:	1b 54 24 08          	sbb    0x8(%esp),%edx
  801033:	89 d7                	mov    %edx,%edi
  801035:	89 c6                	mov    %eax,%esi
  801037:	89 ca                	mov    %ecx,%edx
  801039:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80103e:	29 f3                	sub    %esi,%ebx
  801040:	19 fa                	sbb    %edi,%edx
  801042:	89 d0                	mov    %edx,%eax
  801044:	d3 e0                	shl    %cl,%eax
  801046:	89 e9                	mov    %ebp,%ecx
  801048:	d3 eb                	shr    %cl,%ebx
  80104a:	d3 ea                	shr    %cl,%edx
  80104c:	09 d8                	or     %ebx,%eax
  80104e:	83 c4 1c             	add    $0x1c,%esp
  801051:	5b                   	pop    %ebx
  801052:	5e                   	pop    %esi
  801053:	5f                   	pop    %edi
  801054:	5d                   	pop    %ebp
  801055:	c3                   	ret    
  801056:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80105d:	8d 76 00             	lea    0x0(%esi),%esi
  801060:	29 fe                	sub    %edi,%esi
  801062:	19 c3                	sbb    %eax,%ebx
  801064:	89 f2                	mov    %esi,%edx
  801066:	89 d9                	mov    %ebx,%ecx
  801068:	e9 1d ff ff ff       	jmp    800f8a <__umoddi3+0x6a>
