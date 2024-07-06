
obj/user/evilhello:     file format elf32-i386


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
  80002c:	e8 1d 00 00 00       	call   80004e <libmain>
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
  80003a:	83 ec 10             	sub    $0x10,%esp
	// try to print the kernel entry point as a string!  mua ha ha!
	sys_cputs((char*)0xf010000c, 100);
  80003d:	6a 64                	push   $0x64
  80003f:	68 0c 00 10 f0       	push   $0xf010000c
  800044:	e8 65 00 00 00       	call   8000ae <sys_cputs>
}
  800049:	83 c4 10             	add    $0x10,%esp
  80004c:	c9                   	leave  
  80004d:	c3                   	ret    

0080004e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80004e:	f3 0f 1e fb          	endbr32 
  800052:	55                   	push   %ebp
  800053:	89 e5                	mov    %esp,%ebp
  800055:	56                   	push   %esi
  800056:	53                   	push   %ebx
  800057:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80005a:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv=&envs[ENVX(sys_getenvid())];
  80005d:	e8 d6 00 00 00       	call   800138 <sys_getenvid>
  800062:	25 ff 03 00 00       	and    $0x3ff,%eax
  800067:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80006a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80006f:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800074:	85 db                	test   %ebx,%ebx
  800076:	7e 07                	jle    80007f <libmain+0x31>
		binaryname = argv[0];
  800078:	8b 06                	mov    (%esi),%eax
  80007a:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80007f:	83 ec 08             	sub    $0x8,%esp
  800082:	56                   	push   %esi
  800083:	53                   	push   %ebx
  800084:	e8 aa ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800089:	e8 0a 00 00 00       	call   800098 <exit>
}
  80008e:	83 c4 10             	add    $0x10,%esp
  800091:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800094:	5b                   	pop    %ebx
  800095:	5e                   	pop    %esi
  800096:	5d                   	pop    %ebp
  800097:	c3                   	ret    

00800098 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800098:	f3 0f 1e fb          	endbr32 
  80009c:	55                   	push   %ebp
  80009d:	89 e5                	mov    %esp,%ebp
  80009f:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000a2:	6a 00                	push   $0x0
  8000a4:	e8 4a 00 00 00       	call   8000f3 <sys_env_destroy>
}
  8000a9:	83 c4 10             	add    $0x10,%esp
  8000ac:	c9                   	leave  
  8000ad:	c3                   	ret    

008000ae <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000ae:	f3 0f 1e fb          	endbr32 
  8000b2:	55                   	push   %ebp
  8000b3:	89 e5                	mov    %esp,%ebp
  8000b5:	57                   	push   %edi
  8000b6:	56                   	push   %esi
  8000b7:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000b8:	b8 00 00 00 00       	mov    $0x0,%eax
  8000bd:	8b 55 08             	mov    0x8(%ebp),%edx
  8000c0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000c3:	89 c3                	mov    %eax,%ebx
  8000c5:	89 c7                	mov    %eax,%edi
  8000c7:	89 c6                	mov    %eax,%esi
  8000c9:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000cb:	5b                   	pop    %ebx
  8000cc:	5e                   	pop    %esi
  8000cd:	5f                   	pop    %edi
  8000ce:	5d                   	pop    %ebp
  8000cf:	c3                   	ret    

008000d0 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000d0:	f3 0f 1e fb          	endbr32 
  8000d4:	55                   	push   %ebp
  8000d5:	89 e5                	mov    %esp,%ebp
  8000d7:	57                   	push   %edi
  8000d8:	56                   	push   %esi
  8000d9:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000da:	ba 00 00 00 00       	mov    $0x0,%edx
  8000df:	b8 01 00 00 00       	mov    $0x1,%eax
  8000e4:	89 d1                	mov    %edx,%ecx
  8000e6:	89 d3                	mov    %edx,%ebx
  8000e8:	89 d7                	mov    %edx,%edi
  8000ea:	89 d6                	mov    %edx,%esi
  8000ec:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000ee:	5b                   	pop    %ebx
  8000ef:	5e                   	pop    %esi
  8000f0:	5f                   	pop    %edi
  8000f1:	5d                   	pop    %ebp
  8000f2:	c3                   	ret    

008000f3 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000f3:	f3 0f 1e fb          	endbr32 
  8000f7:	55                   	push   %ebp
  8000f8:	89 e5                	mov    %esp,%ebp
  8000fa:	57                   	push   %edi
  8000fb:	56                   	push   %esi
  8000fc:	53                   	push   %ebx
  8000fd:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800100:	b9 00 00 00 00       	mov    $0x0,%ecx
  800105:	8b 55 08             	mov    0x8(%ebp),%edx
  800108:	b8 03 00 00 00       	mov    $0x3,%eax
  80010d:	89 cb                	mov    %ecx,%ebx
  80010f:	89 cf                	mov    %ecx,%edi
  800111:	89 ce                	mov    %ecx,%esi
  800113:	cd 30                	int    $0x30
	if(check && ret > 0)
  800115:	85 c0                	test   %eax,%eax
  800117:	7f 08                	jg     800121 <sys_env_destroy+0x2e>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800119:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80011c:	5b                   	pop    %ebx
  80011d:	5e                   	pop    %esi
  80011e:	5f                   	pop    %edi
  80011f:	5d                   	pop    %ebp
  800120:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800121:	83 ec 0c             	sub    $0xc,%esp
  800124:	50                   	push   %eax
  800125:	6a 03                	push   $0x3
  800127:	68 6a 10 80 00       	push   $0x80106a
  80012c:	6a 23                	push   $0x23
  80012e:	68 87 10 80 00       	push   $0x801087
  800133:	e8 11 02 00 00       	call   800349 <_panic>

00800138 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800138:	f3 0f 1e fb          	endbr32 
  80013c:	55                   	push   %ebp
  80013d:	89 e5                	mov    %esp,%ebp
  80013f:	57                   	push   %edi
  800140:	56                   	push   %esi
  800141:	53                   	push   %ebx
	asm volatile("int %1\n"
  800142:	ba 00 00 00 00       	mov    $0x0,%edx
  800147:	b8 02 00 00 00       	mov    $0x2,%eax
  80014c:	89 d1                	mov    %edx,%ecx
  80014e:	89 d3                	mov    %edx,%ebx
  800150:	89 d7                	mov    %edx,%edi
  800152:	89 d6                	mov    %edx,%esi
  800154:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800156:	5b                   	pop    %ebx
  800157:	5e                   	pop    %esi
  800158:	5f                   	pop    %edi
  800159:	5d                   	pop    %ebp
  80015a:	c3                   	ret    

0080015b <sys_yield>:

void
sys_yield(void)
{
  80015b:	f3 0f 1e fb          	endbr32 
  80015f:	55                   	push   %ebp
  800160:	89 e5                	mov    %esp,%ebp
  800162:	57                   	push   %edi
  800163:	56                   	push   %esi
  800164:	53                   	push   %ebx
	asm volatile("int %1\n"
  800165:	ba 00 00 00 00       	mov    $0x0,%edx
  80016a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80016f:	89 d1                	mov    %edx,%ecx
  800171:	89 d3                	mov    %edx,%ebx
  800173:	89 d7                	mov    %edx,%edi
  800175:	89 d6                	mov    %edx,%esi
  800177:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800179:	5b                   	pop    %ebx
  80017a:	5e                   	pop    %esi
  80017b:	5f                   	pop    %edi
  80017c:	5d                   	pop    %ebp
  80017d:	c3                   	ret    

0080017e <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80017e:	f3 0f 1e fb          	endbr32 
  800182:	55                   	push   %ebp
  800183:	89 e5                	mov    %esp,%ebp
  800185:	57                   	push   %edi
  800186:	56                   	push   %esi
  800187:	53                   	push   %ebx
  800188:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80018b:	be 00 00 00 00       	mov    $0x0,%esi
  800190:	8b 55 08             	mov    0x8(%ebp),%edx
  800193:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800196:	b8 04 00 00 00       	mov    $0x4,%eax
  80019b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80019e:	89 f7                	mov    %esi,%edi
  8001a0:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001a2:	85 c0                	test   %eax,%eax
  8001a4:	7f 08                	jg     8001ae <sys_page_alloc+0x30>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001a6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001a9:	5b                   	pop    %ebx
  8001aa:	5e                   	pop    %esi
  8001ab:	5f                   	pop    %edi
  8001ac:	5d                   	pop    %ebp
  8001ad:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8001ae:	83 ec 0c             	sub    $0xc,%esp
  8001b1:	50                   	push   %eax
  8001b2:	6a 04                	push   $0x4
  8001b4:	68 6a 10 80 00       	push   $0x80106a
  8001b9:	6a 23                	push   $0x23
  8001bb:	68 87 10 80 00       	push   $0x801087
  8001c0:	e8 84 01 00 00       	call   800349 <_panic>

008001c5 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001c5:	f3 0f 1e fb          	endbr32 
  8001c9:	55                   	push   %ebp
  8001ca:	89 e5                	mov    %esp,%ebp
  8001cc:	57                   	push   %edi
  8001cd:	56                   	push   %esi
  8001ce:	53                   	push   %ebx
  8001cf:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001d2:	8b 55 08             	mov    0x8(%ebp),%edx
  8001d5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001d8:	b8 05 00 00 00       	mov    $0x5,%eax
  8001dd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001e0:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001e3:	8b 75 18             	mov    0x18(%ebp),%esi
  8001e6:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001e8:	85 c0                	test   %eax,%eax
  8001ea:	7f 08                	jg     8001f4 <sys_page_map+0x2f>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001ec:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001ef:	5b                   	pop    %ebx
  8001f0:	5e                   	pop    %esi
  8001f1:	5f                   	pop    %edi
  8001f2:	5d                   	pop    %ebp
  8001f3:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8001f4:	83 ec 0c             	sub    $0xc,%esp
  8001f7:	50                   	push   %eax
  8001f8:	6a 05                	push   $0x5
  8001fa:	68 6a 10 80 00       	push   $0x80106a
  8001ff:	6a 23                	push   $0x23
  800201:	68 87 10 80 00       	push   $0x801087
  800206:	e8 3e 01 00 00       	call   800349 <_panic>

0080020b <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80020b:	f3 0f 1e fb          	endbr32 
  80020f:	55                   	push   %ebp
  800210:	89 e5                	mov    %esp,%ebp
  800212:	57                   	push   %edi
  800213:	56                   	push   %esi
  800214:	53                   	push   %ebx
  800215:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800218:	bb 00 00 00 00       	mov    $0x0,%ebx
  80021d:	8b 55 08             	mov    0x8(%ebp),%edx
  800220:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800223:	b8 06 00 00 00       	mov    $0x6,%eax
  800228:	89 df                	mov    %ebx,%edi
  80022a:	89 de                	mov    %ebx,%esi
  80022c:	cd 30                	int    $0x30
	if(check && ret > 0)
  80022e:	85 c0                	test   %eax,%eax
  800230:	7f 08                	jg     80023a <sys_page_unmap+0x2f>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800232:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800235:	5b                   	pop    %ebx
  800236:	5e                   	pop    %esi
  800237:	5f                   	pop    %edi
  800238:	5d                   	pop    %ebp
  800239:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80023a:	83 ec 0c             	sub    $0xc,%esp
  80023d:	50                   	push   %eax
  80023e:	6a 06                	push   $0x6
  800240:	68 6a 10 80 00       	push   $0x80106a
  800245:	6a 23                	push   $0x23
  800247:	68 87 10 80 00       	push   $0x801087
  80024c:	e8 f8 00 00 00       	call   800349 <_panic>

00800251 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800251:	f3 0f 1e fb          	endbr32 
  800255:	55                   	push   %ebp
  800256:	89 e5                	mov    %esp,%ebp
  800258:	57                   	push   %edi
  800259:	56                   	push   %esi
  80025a:	53                   	push   %ebx
  80025b:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80025e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800263:	8b 55 08             	mov    0x8(%ebp),%edx
  800266:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800269:	b8 08 00 00 00       	mov    $0x8,%eax
  80026e:	89 df                	mov    %ebx,%edi
  800270:	89 de                	mov    %ebx,%esi
  800272:	cd 30                	int    $0x30
	if(check && ret > 0)
  800274:	85 c0                	test   %eax,%eax
  800276:	7f 08                	jg     800280 <sys_env_set_status+0x2f>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800278:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80027b:	5b                   	pop    %ebx
  80027c:	5e                   	pop    %esi
  80027d:	5f                   	pop    %edi
  80027e:	5d                   	pop    %ebp
  80027f:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800280:	83 ec 0c             	sub    $0xc,%esp
  800283:	50                   	push   %eax
  800284:	6a 08                	push   $0x8
  800286:	68 6a 10 80 00       	push   $0x80106a
  80028b:	6a 23                	push   $0x23
  80028d:	68 87 10 80 00       	push   $0x801087
  800292:	e8 b2 00 00 00       	call   800349 <_panic>

00800297 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800297:	f3 0f 1e fb          	endbr32 
  80029b:	55                   	push   %ebp
  80029c:	89 e5                	mov    %esp,%ebp
  80029e:	57                   	push   %edi
  80029f:	56                   	push   %esi
  8002a0:	53                   	push   %ebx
  8002a1:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8002a4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002a9:	8b 55 08             	mov    0x8(%ebp),%edx
  8002ac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002af:	b8 09 00 00 00       	mov    $0x9,%eax
  8002b4:	89 df                	mov    %ebx,%edi
  8002b6:	89 de                	mov    %ebx,%esi
  8002b8:	cd 30                	int    $0x30
	if(check && ret > 0)
  8002ba:	85 c0                	test   %eax,%eax
  8002bc:	7f 08                	jg     8002c6 <sys_env_set_pgfault_upcall+0x2f>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002be:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002c1:	5b                   	pop    %ebx
  8002c2:	5e                   	pop    %esi
  8002c3:	5f                   	pop    %edi
  8002c4:	5d                   	pop    %ebp
  8002c5:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8002c6:	83 ec 0c             	sub    $0xc,%esp
  8002c9:	50                   	push   %eax
  8002ca:	6a 09                	push   $0x9
  8002cc:	68 6a 10 80 00       	push   $0x80106a
  8002d1:	6a 23                	push   $0x23
  8002d3:	68 87 10 80 00       	push   $0x801087
  8002d8:	e8 6c 00 00 00       	call   800349 <_panic>

008002dd <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002dd:	f3 0f 1e fb          	endbr32 
  8002e1:	55                   	push   %ebp
  8002e2:	89 e5                	mov    %esp,%ebp
  8002e4:	57                   	push   %edi
  8002e5:	56                   	push   %esi
  8002e6:	53                   	push   %ebx
	asm volatile("int %1\n"
  8002e7:	8b 55 08             	mov    0x8(%ebp),%edx
  8002ea:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002ed:	b8 0b 00 00 00       	mov    $0xb,%eax
  8002f2:	be 00 00 00 00       	mov    $0x0,%esi
  8002f7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002fa:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002fd:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8002ff:	5b                   	pop    %ebx
  800300:	5e                   	pop    %esi
  800301:	5f                   	pop    %edi
  800302:	5d                   	pop    %ebp
  800303:	c3                   	ret    

00800304 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800304:	f3 0f 1e fb          	endbr32 
  800308:	55                   	push   %ebp
  800309:	89 e5                	mov    %esp,%ebp
  80030b:	57                   	push   %edi
  80030c:	56                   	push   %esi
  80030d:	53                   	push   %ebx
  80030e:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800311:	b9 00 00 00 00       	mov    $0x0,%ecx
  800316:	8b 55 08             	mov    0x8(%ebp),%edx
  800319:	b8 0c 00 00 00       	mov    $0xc,%eax
  80031e:	89 cb                	mov    %ecx,%ebx
  800320:	89 cf                	mov    %ecx,%edi
  800322:	89 ce                	mov    %ecx,%esi
  800324:	cd 30                	int    $0x30
	if(check && ret > 0)
  800326:	85 c0                	test   %eax,%eax
  800328:	7f 08                	jg     800332 <sys_ipc_recv+0x2e>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80032a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80032d:	5b                   	pop    %ebx
  80032e:	5e                   	pop    %esi
  80032f:	5f                   	pop    %edi
  800330:	5d                   	pop    %ebp
  800331:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800332:	83 ec 0c             	sub    $0xc,%esp
  800335:	50                   	push   %eax
  800336:	6a 0c                	push   $0xc
  800338:	68 6a 10 80 00       	push   $0x80106a
  80033d:	6a 23                	push   $0x23
  80033f:	68 87 10 80 00       	push   $0x801087
  800344:	e8 00 00 00 00       	call   800349 <_panic>

00800349 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800349:	f3 0f 1e fb          	endbr32 
  80034d:	55                   	push   %ebp
  80034e:	89 e5                	mov    %esp,%ebp
  800350:	56                   	push   %esi
  800351:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800352:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800355:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80035b:	e8 d8 fd ff ff       	call   800138 <sys_getenvid>
  800360:	83 ec 0c             	sub    $0xc,%esp
  800363:	ff 75 0c             	pushl  0xc(%ebp)
  800366:	ff 75 08             	pushl  0x8(%ebp)
  800369:	56                   	push   %esi
  80036a:	50                   	push   %eax
  80036b:	68 98 10 80 00       	push   $0x801098
  800370:	e8 bb 00 00 00       	call   800430 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800375:	83 c4 18             	add    $0x18,%esp
  800378:	53                   	push   %ebx
  800379:	ff 75 10             	pushl  0x10(%ebp)
  80037c:	e8 5a 00 00 00       	call   8003db <vcprintf>
	cprintf("\n");
  800381:	c7 04 24 bb 10 80 00 	movl   $0x8010bb,(%esp)
  800388:	e8 a3 00 00 00       	call   800430 <cprintf>
  80038d:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800390:	cc                   	int3   
  800391:	eb fd                	jmp    800390 <_panic+0x47>

00800393 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800393:	f3 0f 1e fb          	endbr32 
  800397:	55                   	push   %ebp
  800398:	89 e5                	mov    %esp,%ebp
  80039a:	53                   	push   %ebx
  80039b:	83 ec 04             	sub    $0x4,%esp
  80039e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8003a1:	8b 13                	mov    (%ebx),%edx
  8003a3:	8d 42 01             	lea    0x1(%edx),%eax
  8003a6:	89 03                	mov    %eax,(%ebx)
  8003a8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003ab:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8003af:	3d ff 00 00 00       	cmp    $0xff,%eax
  8003b4:	74 09                	je     8003bf <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8003b6:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8003ba:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8003bd:	c9                   	leave  
  8003be:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8003bf:	83 ec 08             	sub    $0x8,%esp
  8003c2:	68 ff 00 00 00       	push   $0xff
  8003c7:	8d 43 08             	lea    0x8(%ebx),%eax
  8003ca:	50                   	push   %eax
  8003cb:	e8 de fc ff ff       	call   8000ae <sys_cputs>
		b->idx = 0;
  8003d0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8003d6:	83 c4 10             	add    $0x10,%esp
  8003d9:	eb db                	jmp    8003b6 <putch+0x23>

008003db <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8003db:	f3 0f 1e fb          	endbr32 
  8003df:	55                   	push   %ebp
  8003e0:	89 e5                	mov    %esp,%ebp
  8003e2:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8003e8:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003ef:	00 00 00 
	b.cnt = 0;
  8003f2:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003f9:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003fc:	ff 75 0c             	pushl  0xc(%ebp)
  8003ff:	ff 75 08             	pushl  0x8(%ebp)
  800402:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800408:	50                   	push   %eax
  800409:	68 93 03 80 00       	push   $0x800393
  80040e:	e8 20 01 00 00       	call   800533 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800413:	83 c4 08             	add    $0x8,%esp
  800416:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80041c:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800422:	50                   	push   %eax
  800423:	e8 86 fc ff ff       	call   8000ae <sys_cputs>

	return b.cnt;
}
  800428:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80042e:	c9                   	leave  
  80042f:	c3                   	ret    

00800430 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800430:	f3 0f 1e fb          	endbr32 
  800434:	55                   	push   %ebp
  800435:	89 e5                	mov    %esp,%ebp
  800437:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80043a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80043d:	50                   	push   %eax
  80043e:	ff 75 08             	pushl  0x8(%ebp)
  800441:	e8 95 ff ff ff       	call   8003db <vcprintf>
	va_end(ap);

	return cnt;
}
  800446:	c9                   	leave  
  800447:	c3                   	ret    

00800448 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800448:	55                   	push   %ebp
  800449:	89 e5                	mov    %esp,%ebp
  80044b:	57                   	push   %edi
  80044c:	56                   	push   %esi
  80044d:	53                   	push   %ebx
  80044e:	83 ec 1c             	sub    $0x1c,%esp
  800451:	89 c7                	mov    %eax,%edi
  800453:	89 d6                	mov    %edx,%esi
  800455:	8b 45 08             	mov    0x8(%ebp),%eax
  800458:	8b 55 0c             	mov    0xc(%ebp),%edx
  80045b:	89 d1                	mov    %edx,%ecx
  80045d:	89 c2                	mov    %eax,%edx
  80045f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800462:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800465:	8b 45 10             	mov    0x10(%ebp),%eax
  800468:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80046b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80046e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800475:	39 c2                	cmp    %eax,%edx
  800477:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  80047a:	72 3e                	jb     8004ba <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80047c:	83 ec 0c             	sub    $0xc,%esp
  80047f:	ff 75 18             	pushl  0x18(%ebp)
  800482:	83 eb 01             	sub    $0x1,%ebx
  800485:	53                   	push   %ebx
  800486:	50                   	push   %eax
  800487:	83 ec 08             	sub    $0x8,%esp
  80048a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80048d:	ff 75 e0             	pushl  -0x20(%ebp)
  800490:	ff 75 dc             	pushl  -0x24(%ebp)
  800493:	ff 75 d8             	pushl  -0x28(%ebp)
  800496:	e8 55 09 00 00       	call   800df0 <__udivdi3>
  80049b:	83 c4 18             	add    $0x18,%esp
  80049e:	52                   	push   %edx
  80049f:	50                   	push   %eax
  8004a0:	89 f2                	mov    %esi,%edx
  8004a2:	89 f8                	mov    %edi,%eax
  8004a4:	e8 9f ff ff ff       	call   800448 <printnum>
  8004a9:	83 c4 20             	add    $0x20,%esp
  8004ac:	eb 13                	jmp    8004c1 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8004ae:	83 ec 08             	sub    $0x8,%esp
  8004b1:	56                   	push   %esi
  8004b2:	ff 75 18             	pushl  0x18(%ebp)
  8004b5:	ff d7                	call   *%edi
  8004b7:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8004ba:	83 eb 01             	sub    $0x1,%ebx
  8004bd:	85 db                	test   %ebx,%ebx
  8004bf:	7f ed                	jg     8004ae <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8004c1:	83 ec 08             	sub    $0x8,%esp
  8004c4:	56                   	push   %esi
  8004c5:	83 ec 04             	sub    $0x4,%esp
  8004c8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8004cb:	ff 75 e0             	pushl  -0x20(%ebp)
  8004ce:	ff 75 dc             	pushl  -0x24(%ebp)
  8004d1:	ff 75 d8             	pushl  -0x28(%ebp)
  8004d4:	e8 27 0a 00 00       	call   800f00 <__umoddi3>
  8004d9:	83 c4 14             	add    $0x14,%esp
  8004dc:	0f be 80 bd 10 80 00 	movsbl 0x8010bd(%eax),%eax
  8004e3:	50                   	push   %eax
  8004e4:	ff d7                	call   *%edi
}
  8004e6:	83 c4 10             	add    $0x10,%esp
  8004e9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004ec:	5b                   	pop    %ebx
  8004ed:	5e                   	pop    %esi
  8004ee:	5f                   	pop    %edi
  8004ef:	5d                   	pop    %ebp
  8004f0:	c3                   	ret    

008004f1 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004f1:	f3 0f 1e fb          	endbr32 
  8004f5:	55                   	push   %ebp
  8004f6:	89 e5                	mov    %esp,%ebp
  8004f8:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004fb:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004ff:	8b 10                	mov    (%eax),%edx
  800501:	3b 50 04             	cmp    0x4(%eax),%edx
  800504:	73 0a                	jae    800510 <sprintputch+0x1f>
		*b->buf++ = ch;
  800506:	8d 4a 01             	lea    0x1(%edx),%ecx
  800509:	89 08                	mov    %ecx,(%eax)
  80050b:	8b 45 08             	mov    0x8(%ebp),%eax
  80050e:	88 02                	mov    %al,(%edx)
}
  800510:	5d                   	pop    %ebp
  800511:	c3                   	ret    

00800512 <printfmt>:
{
  800512:	f3 0f 1e fb          	endbr32 
  800516:	55                   	push   %ebp
  800517:	89 e5                	mov    %esp,%ebp
  800519:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80051c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80051f:	50                   	push   %eax
  800520:	ff 75 10             	pushl  0x10(%ebp)
  800523:	ff 75 0c             	pushl  0xc(%ebp)
  800526:	ff 75 08             	pushl  0x8(%ebp)
  800529:	e8 05 00 00 00       	call   800533 <vprintfmt>
}
  80052e:	83 c4 10             	add    $0x10,%esp
  800531:	c9                   	leave  
  800532:	c3                   	ret    

00800533 <vprintfmt>:
{
  800533:	f3 0f 1e fb          	endbr32 
  800537:	55                   	push   %ebp
  800538:	89 e5                	mov    %esp,%ebp
  80053a:	57                   	push   %edi
  80053b:	56                   	push   %esi
  80053c:	53                   	push   %ebx
  80053d:	83 ec 3c             	sub    $0x3c,%esp
  800540:	8b 75 08             	mov    0x8(%ebp),%esi
  800543:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800546:	8b 7d 10             	mov    0x10(%ebp),%edi
  800549:	e9 cd 03 00 00       	jmp    80091b <vprintfmt+0x3e8>
		padc = ' ';
  80054e:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800552:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800559:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800560:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800567:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80056c:	8d 47 01             	lea    0x1(%edi),%eax
  80056f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800572:	0f b6 17             	movzbl (%edi),%edx
  800575:	8d 42 dd             	lea    -0x23(%edx),%eax
  800578:	3c 55                	cmp    $0x55,%al
  80057a:	0f 87 1e 04 00 00    	ja     80099e <vprintfmt+0x46b>
  800580:	0f b6 c0             	movzbl %al,%eax
  800583:	3e ff 24 85 80 11 80 	notrack jmp *0x801180(,%eax,4)
  80058a:	00 
  80058b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80058e:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800592:	eb d8                	jmp    80056c <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800594:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800597:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  80059b:	eb cf                	jmp    80056c <vprintfmt+0x39>
  80059d:	0f b6 d2             	movzbl %dl,%edx
  8005a0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8005a3:	b8 00 00 00 00       	mov    $0x0,%eax
  8005a8:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8005ab:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8005ae:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8005b2:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8005b5:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8005b8:	83 f9 09             	cmp    $0x9,%ecx
  8005bb:	77 55                	ja     800612 <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  8005bd:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8005c0:	eb e9                	jmp    8005ab <vprintfmt+0x78>
			precision = va_arg(ap, int);
  8005c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c5:	8b 00                	mov    (%eax),%eax
  8005c7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cd:	8d 40 04             	lea    0x4(%eax),%eax
  8005d0:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8005d3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8005d6:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005da:	79 90                	jns    80056c <vprintfmt+0x39>
				width = precision, precision = -1;
  8005dc:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005df:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005e2:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8005e9:	eb 81                	jmp    80056c <vprintfmt+0x39>
  8005eb:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005ee:	85 c0                	test   %eax,%eax
  8005f0:	ba 00 00 00 00       	mov    $0x0,%edx
  8005f5:	0f 49 d0             	cmovns %eax,%edx
  8005f8:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8005fb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8005fe:	e9 69 ff ff ff       	jmp    80056c <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800603:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800606:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  80060d:	e9 5a ff ff ff       	jmp    80056c <vprintfmt+0x39>
  800612:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800615:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800618:	eb bc                	jmp    8005d6 <vprintfmt+0xa3>
			lflag++;
  80061a:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80061d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800620:	e9 47 ff ff ff       	jmp    80056c <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  800625:	8b 45 14             	mov    0x14(%ebp),%eax
  800628:	8d 78 04             	lea    0x4(%eax),%edi
  80062b:	83 ec 08             	sub    $0x8,%esp
  80062e:	53                   	push   %ebx
  80062f:	ff 30                	pushl  (%eax)
  800631:	ff d6                	call   *%esi
			break;
  800633:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800636:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800639:	e9 da 02 00 00       	jmp    800918 <vprintfmt+0x3e5>
			err = va_arg(ap, int);
  80063e:	8b 45 14             	mov    0x14(%ebp),%eax
  800641:	8d 78 04             	lea    0x4(%eax),%edi
  800644:	8b 00                	mov    (%eax),%eax
  800646:	99                   	cltd   
  800647:	31 d0                	xor    %edx,%eax
  800649:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80064b:	83 f8 08             	cmp    $0x8,%eax
  80064e:	7f 23                	jg     800673 <vprintfmt+0x140>
  800650:	8b 14 85 e0 12 80 00 	mov    0x8012e0(,%eax,4),%edx
  800657:	85 d2                	test   %edx,%edx
  800659:	74 18                	je     800673 <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  80065b:	52                   	push   %edx
  80065c:	68 de 10 80 00       	push   $0x8010de
  800661:	53                   	push   %ebx
  800662:	56                   	push   %esi
  800663:	e8 aa fe ff ff       	call   800512 <printfmt>
  800668:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80066b:	89 7d 14             	mov    %edi,0x14(%ebp)
  80066e:	e9 a5 02 00 00       	jmp    800918 <vprintfmt+0x3e5>
				printfmt(putch, putdat, "error %d", err);
  800673:	50                   	push   %eax
  800674:	68 d5 10 80 00       	push   $0x8010d5
  800679:	53                   	push   %ebx
  80067a:	56                   	push   %esi
  80067b:	e8 92 fe ff ff       	call   800512 <printfmt>
  800680:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800683:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800686:	e9 8d 02 00 00       	jmp    800918 <vprintfmt+0x3e5>
			if ((p = va_arg(ap, char *)) == NULL)
  80068b:	8b 45 14             	mov    0x14(%ebp),%eax
  80068e:	83 c0 04             	add    $0x4,%eax
  800691:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800694:	8b 45 14             	mov    0x14(%ebp),%eax
  800697:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  800699:	85 d2                	test   %edx,%edx
  80069b:	b8 ce 10 80 00       	mov    $0x8010ce,%eax
  8006a0:	0f 45 c2             	cmovne %edx,%eax
  8006a3:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8006a6:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006aa:	7e 06                	jle    8006b2 <vprintfmt+0x17f>
  8006ac:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  8006b0:	75 0d                	jne    8006bf <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006b2:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8006b5:	89 c7                	mov    %eax,%edi
  8006b7:	03 45 e0             	add    -0x20(%ebp),%eax
  8006ba:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006bd:	eb 55                	jmp    800714 <vprintfmt+0x1e1>
  8006bf:	83 ec 08             	sub    $0x8,%esp
  8006c2:	ff 75 d8             	pushl  -0x28(%ebp)
  8006c5:	ff 75 cc             	pushl  -0x34(%ebp)
  8006c8:	e8 85 03 00 00       	call   800a52 <strnlen>
  8006cd:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8006d0:	29 c2                	sub    %eax,%edx
  8006d2:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  8006d5:	83 c4 10             	add    $0x10,%esp
  8006d8:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  8006da:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8006de:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8006e1:	85 ff                	test   %edi,%edi
  8006e3:	7e 11                	jle    8006f6 <vprintfmt+0x1c3>
					putch(padc, putdat);
  8006e5:	83 ec 08             	sub    $0x8,%esp
  8006e8:	53                   	push   %ebx
  8006e9:	ff 75 e0             	pushl  -0x20(%ebp)
  8006ec:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8006ee:	83 ef 01             	sub    $0x1,%edi
  8006f1:	83 c4 10             	add    $0x10,%esp
  8006f4:	eb eb                	jmp    8006e1 <vprintfmt+0x1ae>
  8006f6:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8006f9:	85 d2                	test   %edx,%edx
  8006fb:	b8 00 00 00 00       	mov    $0x0,%eax
  800700:	0f 49 c2             	cmovns %edx,%eax
  800703:	29 c2                	sub    %eax,%edx
  800705:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800708:	eb a8                	jmp    8006b2 <vprintfmt+0x17f>
					putch(ch, putdat);
  80070a:	83 ec 08             	sub    $0x8,%esp
  80070d:	53                   	push   %ebx
  80070e:	52                   	push   %edx
  80070f:	ff d6                	call   *%esi
  800711:	83 c4 10             	add    $0x10,%esp
  800714:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800717:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800719:	83 c7 01             	add    $0x1,%edi
  80071c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800720:	0f be d0             	movsbl %al,%edx
  800723:	85 d2                	test   %edx,%edx
  800725:	74 4b                	je     800772 <vprintfmt+0x23f>
  800727:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80072b:	78 06                	js     800733 <vprintfmt+0x200>
  80072d:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800731:	78 1e                	js     800751 <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
  800733:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800737:	74 d1                	je     80070a <vprintfmt+0x1d7>
  800739:	0f be c0             	movsbl %al,%eax
  80073c:	83 e8 20             	sub    $0x20,%eax
  80073f:	83 f8 5e             	cmp    $0x5e,%eax
  800742:	76 c6                	jbe    80070a <vprintfmt+0x1d7>
					putch('?', putdat);
  800744:	83 ec 08             	sub    $0x8,%esp
  800747:	53                   	push   %ebx
  800748:	6a 3f                	push   $0x3f
  80074a:	ff d6                	call   *%esi
  80074c:	83 c4 10             	add    $0x10,%esp
  80074f:	eb c3                	jmp    800714 <vprintfmt+0x1e1>
  800751:	89 cf                	mov    %ecx,%edi
  800753:	eb 0e                	jmp    800763 <vprintfmt+0x230>
				putch(' ', putdat);
  800755:	83 ec 08             	sub    $0x8,%esp
  800758:	53                   	push   %ebx
  800759:	6a 20                	push   $0x20
  80075b:	ff d6                	call   *%esi
			for (; width > 0; width--)
  80075d:	83 ef 01             	sub    $0x1,%edi
  800760:	83 c4 10             	add    $0x10,%esp
  800763:	85 ff                	test   %edi,%edi
  800765:	7f ee                	jg     800755 <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  800767:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80076a:	89 45 14             	mov    %eax,0x14(%ebp)
  80076d:	e9 a6 01 00 00       	jmp    800918 <vprintfmt+0x3e5>
  800772:	89 cf                	mov    %ecx,%edi
  800774:	eb ed                	jmp    800763 <vprintfmt+0x230>
	if (lflag >= 2)
  800776:	83 f9 01             	cmp    $0x1,%ecx
  800779:	7f 1f                	jg     80079a <vprintfmt+0x267>
	else if (lflag)
  80077b:	85 c9                	test   %ecx,%ecx
  80077d:	74 67                	je     8007e6 <vprintfmt+0x2b3>
		return va_arg(*ap, long);
  80077f:	8b 45 14             	mov    0x14(%ebp),%eax
  800782:	8b 00                	mov    (%eax),%eax
  800784:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800787:	89 c1                	mov    %eax,%ecx
  800789:	c1 f9 1f             	sar    $0x1f,%ecx
  80078c:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80078f:	8b 45 14             	mov    0x14(%ebp),%eax
  800792:	8d 40 04             	lea    0x4(%eax),%eax
  800795:	89 45 14             	mov    %eax,0x14(%ebp)
  800798:	eb 17                	jmp    8007b1 <vprintfmt+0x27e>
		return va_arg(*ap, long long);
  80079a:	8b 45 14             	mov    0x14(%ebp),%eax
  80079d:	8b 50 04             	mov    0x4(%eax),%edx
  8007a0:	8b 00                	mov    (%eax),%eax
  8007a2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007a5:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ab:	8d 40 08             	lea    0x8(%eax),%eax
  8007ae:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8007b1:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007b4:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8007b7:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  8007bc:	85 c9                	test   %ecx,%ecx
  8007be:	0f 89 3a 01 00 00    	jns    8008fe <vprintfmt+0x3cb>
				putch('-', putdat);
  8007c4:	83 ec 08             	sub    $0x8,%esp
  8007c7:	53                   	push   %ebx
  8007c8:	6a 2d                	push   $0x2d
  8007ca:	ff d6                	call   *%esi
				num = -(long long) num;
  8007cc:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007cf:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8007d2:	f7 da                	neg    %edx
  8007d4:	83 d1 00             	adc    $0x0,%ecx
  8007d7:	f7 d9                	neg    %ecx
  8007d9:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8007dc:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007e1:	e9 18 01 00 00       	jmp    8008fe <vprintfmt+0x3cb>
		return va_arg(*ap, int);
  8007e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e9:	8b 00                	mov    (%eax),%eax
  8007eb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007ee:	89 c1                	mov    %eax,%ecx
  8007f0:	c1 f9 1f             	sar    $0x1f,%ecx
  8007f3:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8007f6:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f9:	8d 40 04             	lea    0x4(%eax),%eax
  8007fc:	89 45 14             	mov    %eax,0x14(%ebp)
  8007ff:	eb b0                	jmp    8007b1 <vprintfmt+0x27e>
	if (lflag >= 2)
  800801:	83 f9 01             	cmp    $0x1,%ecx
  800804:	7f 1e                	jg     800824 <vprintfmt+0x2f1>
	else if (lflag)
  800806:	85 c9                	test   %ecx,%ecx
  800808:	74 32                	je     80083c <vprintfmt+0x309>
		return va_arg(*ap, unsigned long);
  80080a:	8b 45 14             	mov    0x14(%ebp),%eax
  80080d:	8b 10                	mov    (%eax),%edx
  80080f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800814:	8d 40 04             	lea    0x4(%eax),%eax
  800817:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80081a:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  80081f:	e9 da 00 00 00       	jmp    8008fe <vprintfmt+0x3cb>
		return va_arg(*ap, unsigned long long);
  800824:	8b 45 14             	mov    0x14(%ebp),%eax
  800827:	8b 10                	mov    (%eax),%edx
  800829:	8b 48 04             	mov    0x4(%eax),%ecx
  80082c:	8d 40 08             	lea    0x8(%eax),%eax
  80082f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800832:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  800837:	e9 c2 00 00 00       	jmp    8008fe <vprintfmt+0x3cb>
		return va_arg(*ap, unsigned int);
  80083c:	8b 45 14             	mov    0x14(%ebp),%eax
  80083f:	8b 10                	mov    (%eax),%edx
  800841:	b9 00 00 00 00       	mov    $0x0,%ecx
  800846:	8d 40 04             	lea    0x4(%eax),%eax
  800849:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80084c:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  800851:	e9 a8 00 00 00       	jmp    8008fe <vprintfmt+0x3cb>
	if (lflag >= 2)
  800856:	83 f9 01             	cmp    $0x1,%ecx
  800859:	7f 1b                	jg     800876 <vprintfmt+0x343>
	else if (lflag)
  80085b:	85 c9                	test   %ecx,%ecx
  80085d:	74 5c                	je     8008bb <vprintfmt+0x388>
		return va_arg(*ap, long);
  80085f:	8b 45 14             	mov    0x14(%ebp),%eax
  800862:	8b 00                	mov    (%eax),%eax
  800864:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800867:	99                   	cltd   
  800868:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80086b:	8b 45 14             	mov    0x14(%ebp),%eax
  80086e:	8d 40 04             	lea    0x4(%eax),%eax
  800871:	89 45 14             	mov    %eax,0x14(%ebp)
  800874:	eb 17                	jmp    80088d <vprintfmt+0x35a>
		return va_arg(*ap, long long);
  800876:	8b 45 14             	mov    0x14(%ebp),%eax
  800879:	8b 50 04             	mov    0x4(%eax),%edx
  80087c:	8b 00                	mov    (%eax),%eax
  80087e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800881:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800884:	8b 45 14             	mov    0x14(%ebp),%eax
  800887:	8d 40 08             	lea    0x8(%eax),%eax
  80088a:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80088d:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800890:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 8;
  800893:	b8 08 00 00 00       	mov    $0x8,%eax
			if ((long long) num < 0) {
  800898:	85 c9                	test   %ecx,%ecx
  80089a:	79 62                	jns    8008fe <vprintfmt+0x3cb>
				putch('-', putdat);
  80089c:	83 ec 08             	sub    $0x8,%esp
  80089f:	53                   	push   %ebx
  8008a0:	6a 2d                	push   $0x2d
  8008a2:	ff d6                	call   *%esi
				num = -(long long) num;
  8008a4:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8008a7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8008aa:	f7 da                	neg    %edx
  8008ac:	83 d1 00             	adc    $0x0,%ecx
  8008af:	f7 d9                	neg    %ecx
  8008b1:	83 c4 10             	add    $0x10,%esp
			base = 8;
  8008b4:	b8 08 00 00 00       	mov    $0x8,%eax
  8008b9:	eb 43                	jmp    8008fe <vprintfmt+0x3cb>
		return va_arg(*ap, int);
  8008bb:	8b 45 14             	mov    0x14(%ebp),%eax
  8008be:	8b 00                	mov    (%eax),%eax
  8008c0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8008c3:	89 c1                	mov    %eax,%ecx
  8008c5:	c1 f9 1f             	sar    $0x1f,%ecx
  8008c8:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8008cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8008ce:	8d 40 04             	lea    0x4(%eax),%eax
  8008d1:	89 45 14             	mov    %eax,0x14(%ebp)
  8008d4:	eb b7                	jmp    80088d <vprintfmt+0x35a>
			putch('0', putdat);
  8008d6:	83 ec 08             	sub    $0x8,%esp
  8008d9:	53                   	push   %ebx
  8008da:	6a 30                	push   $0x30
  8008dc:	ff d6                	call   *%esi
			putch('x', putdat);
  8008de:	83 c4 08             	add    $0x8,%esp
  8008e1:	53                   	push   %ebx
  8008e2:	6a 78                	push   $0x78
  8008e4:	ff d6                	call   *%esi
			num = (unsigned long long)
  8008e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8008e9:	8b 10                	mov    (%eax),%edx
  8008eb:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8008f0:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8008f3:	8d 40 04             	lea    0x4(%eax),%eax
  8008f6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8008f9:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  8008fe:	83 ec 0c             	sub    $0xc,%esp
  800901:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  800905:	57                   	push   %edi
  800906:	ff 75 e0             	pushl  -0x20(%ebp)
  800909:	50                   	push   %eax
  80090a:	51                   	push   %ecx
  80090b:	52                   	push   %edx
  80090c:	89 da                	mov    %ebx,%edx
  80090e:	89 f0                	mov    %esi,%eax
  800910:	e8 33 fb ff ff       	call   800448 <printnum>
			break;
  800915:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  800918:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80091b:	83 c7 01             	add    $0x1,%edi
  80091e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800922:	83 f8 25             	cmp    $0x25,%eax
  800925:	0f 84 23 fc ff ff    	je     80054e <vprintfmt+0x1b>
			if (ch == '\0')
  80092b:	85 c0                	test   %eax,%eax
  80092d:	0f 84 8b 00 00 00    	je     8009be <vprintfmt+0x48b>
			putch(ch, putdat);
  800933:	83 ec 08             	sub    $0x8,%esp
  800936:	53                   	push   %ebx
  800937:	50                   	push   %eax
  800938:	ff d6                	call   *%esi
  80093a:	83 c4 10             	add    $0x10,%esp
  80093d:	eb dc                	jmp    80091b <vprintfmt+0x3e8>
	if (lflag >= 2)
  80093f:	83 f9 01             	cmp    $0x1,%ecx
  800942:	7f 1b                	jg     80095f <vprintfmt+0x42c>
	else if (lflag)
  800944:	85 c9                	test   %ecx,%ecx
  800946:	74 2c                	je     800974 <vprintfmt+0x441>
		return va_arg(*ap, unsigned long);
  800948:	8b 45 14             	mov    0x14(%ebp),%eax
  80094b:	8b 10                	mov    (%eax),%edx
  80094d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800952:	8d 40 04             	lea    0x4(%eax),%eax
  800955:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800958:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  80095d:	eb 9f                	jmp    8008fe <vprintfmt+0x3cb>
		return va_arg(*ap, unsigned long long);
  80095f:	8b 45 14             	mov    0x14(%ebp),%eax
  800962:	8b 10                	mov    (%eax),%edx
  800964:	8b 48 04             	mov    0x4(%eax),%ecx
  800967:	8d 40 08             	lea    0x8(%eax),%eax
  80096a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80096d:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  800972:	eb 8a                	jmp    8008fe <vprintfmt+0x3cb>
		return va_arg(*ap, unsigned int);
  800974:	8b 45 14             	mov    0x14(%ebp),%eax
  800977:	8b 10                	mov    (%eax),%edx
  800979:	b9 00 00 00 00       	mov    $0x0,%ecx
  80097e:	8d 40 04             	lea    0x4(%eax),%eax
  800981:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800984:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  800989:	e9 70 ff ff ff       	jmp    8008fe <vprintfmt+0x3cb>
			putch(ch, putdat);
  80098e:	83 ec 08             	sub    $0x8,%esp
  800991:	53                   	push   %ebx
  800992:	6a 25                	push   $0x25
  800994:	ff d6                	call   *%esi
			break;
  800996:	83 c4 10             	add    $0x10,%esp
  800999:	e9 7a ff ff ff       	jmp    800918 <vprintfmt+0x3e5>
			putch('%', putdat);
  80099e:	83 ec 08             	sub    $0x8,%esp
  8009a1:	53                   	push   %ebx
  8009a2:	6a 25                	push   $0x25
  8009a4:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8009a6:	83 c4 10             	add    $0x10,%esp
  8009a9:	89 f8                	mov    %edi,%eax
  8009ab:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8009af:	74 05                	je     8009b6 <vprintfmt+0x483>
  8009b1:	83 e8 01             	sub    $0x1,%eax
  8009b4:	eb f5                	jmp    8009ab <vprintfmt+0x478>
  8009b6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8009b9:	e9 5a ff ff ff       	jmp    800918 <vprintfmt+0x3e5>
}
  8009be:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8009c1:	5b                   	pop    %ebx
  8009c2:	5e                   	pop    %esi
  8009c3:	5f                   	pop    %edi
  8009c4:	5d                   	pop    %ebp
  8009c5:	c3                   	ret    

008009c6 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8009c6:	f3 0f 1e fb          	endbr32 
  8009ca:	55                   	push   %ebp
  8009cb:	89 e5                	mov    %esp,%ebp
  8009cd:	83 ec 18             	sub    $0x18,%esp
  8009d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d3:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8009d6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8009d9:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8009dd:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8009e0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8009e7:	85 c0                	test   %eax,%eax
  8009e9:	74 26                	je     800a11 <vsnprintf+0x4b>
  8009eb:	85 d2                	test   %edx,%edx
  8009ed:	7e 22                	jle    800a11 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8009ef:	ff 75 14             	pushl  0x14(%ebp)
  8009f2:	ff 75 10             	pushl  0x10(%ebp)
  8009f5:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8009f8:	50                   	push   %eax
  8009f9:	68 f1 04 80 00       	push   $0x8004f1
  8009fe:	e8 30 fb ff ff       	call   800533 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800a03:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800a06:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800a09:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800a0c:	83 c4 10             	add    $0x10,%esp
}
  800a0f:	c9                   	leave  
  800a10:	c3                   	ret    
		return -E_INVAL;
  800a11:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800a16:	eb f7                	jmp    800a0f <vsnprintf+0x49>

00800a18 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800a18:	f3 0f 1e fb          	endbr32 
  800a1c:	55                   	push   %ebp
  800a1d:	89 e5                	mov    %esp,%ebp
  800a1f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800a22:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800a25:	50                   	push   %eax
  800a26:	ff 75 10             	pushl  0x10(%ebp)
  800a29:	ff 75 0c             	pushl  0xc(%ebp)
  800a2c:	ff 75 08             	pushl  0x8(%ebp)
  800a2f:	e8 92 ff ff ff       	call   8009c6 <vsnprintf>
	va_end(ap);

	return rc;
}
  800a34:	c9                   	leave  
  800a35:	c3                   	ret    

00800a36 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800a36:	f3 0f 1e fb          	endbr32 
  800a3a:	55                   	push   %ebp
  800a3b:	89 e5                	mov    %esp,%ebp
  800a3d:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a40:	b8 00 00 00 00       	mov    $0x0,%eax
  800a45:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a49:	74 05                	je     800a50 <strlen+0x1a>
		n++;
  800a4b:	83 c0 01             	add    $0x1,%eax
  800a4e:	eb f5                	jmp    800a45 <strlen+0xf>
	return n;
}
  800a50:	5d                   	pop    %ebp
  800a51:	c3                   	ret    

00800a52 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a52:	f3 0f 1e fb          	endbr32 
  800a56:	55                   	push   %ebp
  800a57:	89 e5                	mov    %esp,%ebp
  800a59:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a5c:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a5f:	b8 00 00 00 00       	mov    $0x0,%eax
  800a64:	39 d0                	cmp    %edx,%eax
  800a66:	74 0d                	je     800a75 <strnlen+0x23>
  800a68:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800a6c:	74 05                	je     800a73 <strnlen+0x21>
		n++;
  800a6e:	83 c0 01             	add    $0x1,%eax
  800a71:	eb f1                	jmp    800a64 <strnlen+0x12>
  800a73:	89 c2                	mov    %eax,%edx
	return n;
}
  800a75:	89 d0                	mov    %edx,%eax
  800a77:	5d                   	pop    %ebp
  800a78:	c3                   	ret    

00800a79 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a79:	f3 0f 1e fb          	endbr32 
  800a7d:	55                   	push   %ebp
  800a7e:	89 e5                	mov    %esp,%ebp
  800a80:	53                   	push   %ebx
  800a81:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a84:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a87:	b8 00 00 00 00       	mov    $0x0,%eax
  800a8c:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800a90:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800a93:	83 c0 01             	add    $0x1,%eax
  800a96:	84 d2                	test   %dl,%dl
  800a98:	75 f2                	jne    800a8c <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  800a9a:	89 c8                	mov    %ecx,%eax
  800a9c:	5b                   	pop    %ebx
  800a9d:	5d                   	pop    %ebp
  800a9e:	c3                   	ret    

00800a9f <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a9f:	f3 0f 1e fb          	endbr32 
  800aa3:	55                   	push   %ebp
  800aa4:	89 e5                	mov    %esp,%ebp
  800aa6:	53                   	push   %ebx
  800aa7:	83 ec 10             	sub    $0x10,%esp
  800aaa:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800aad:	53                   	push   %ebx
  800aae:	e8 83 ff ff ff       	call   800a36 <strlen>
  800ab3:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800ab6:	ff 75 0c             	pushl  0xc(%ebp)
  800ab9:	01 d8                	add    %ebx,%eax
  800abb:	50                   	push   %eax
  800abc:	e8 b8 ff ff ff       	call   800a79 <strcpy>
	return dst;
}
  800ac1:	89 d8                	mov    %ebx,%eax
  800ac3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ac6:	c9                   	leave  
  800ac7:	c3                   	ret    

00800ac8 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800ac8:	f3 0f 1e fb          	endbr32 
  800acc:	55                   	push   %ebp
  800acd:	89 e5                	mov    %esp,%ebp
  800acf:	56                   	push   %esi
  800ad0:	53                   	push   %ebx
  800ad1:	8b 75 08             	mov    0x8(%ebp),%esi
  800ad4:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ad7:	89 f3                	mov    %esi,%ebx
  800ad9:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800adc:	89 f0                	mov    %esi,%eax
  800ade:	39 d8                	cmp    %ebx,%eax
  800ae0:	74 11                	je     800af3 <strncpy+0x2b>
		*dst++ = *src;
  800ae2:	83 c0 01             	add    $0x1,%eax
  800ae5:	0f b6 0a             	movzbl (%edx),%ecx
  800ae8:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800aeb:	80 f9 01             	cmp    $0x1,%cl
  800aee:	83 da ff             	sbb    $0xffffffff,%edx
  800af1:	eb eb                	jmp    800ade <strncpy+0x16>
	}
	return ret;
}
  800af3:	89 f0                	mov    %esi,%eax
  800af5:	5b                   	pop    %ebx
  800af6:	5e                   	pop    %esi
  800af7:	5d                   	pop    %ebp
  800af8:	c3                   	ret    

00800af9 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800af9:	f3 0f 1e fb          	endbr32 
  800afd:	55                   	push   %ebp
  800afe:	89 e5                	mov    %esp,%ebp
  800b00:	56                   	push   %esi
  800b01:	53                   	push   %ebx
  800b02:	8b 75 08             	mov    0x8(%ebp),%esi
  800b05:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b08:	8b 55 10             	mov    0x10(%ebp),%edx
  800b0b:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800b0d:	85 d2                	test   %edx,%edx
  800b0f:	74 21                	je     800b32 <strlcpy+0x39>
  800b11:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800b15:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  800b17:	39 c2                	cmp    %eax,%edx
  800b19:	74 14                	je     800b2f <strlcpy+0x36>
  800b1b:	0f b6 19             	movzbl (%ecx),%ebx
  800b1e:	84 db                	test   %bl,%bl
  800b20:	74 0b                	je     800b2d <strlcpy+0x34>
			*dst++ = *src++;
  800b22:	83 c1 01             	add    $0x1,%ecx
  800b25:	83 c2 01             	add    $0x1,%edx
  800b28:	88 5a ff             	mov    %bl,-0x1(%edx)
  800b2b:	eb ea                	jmp    800b17 <strlcpy+0x1e>
  800b2d:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800b2f:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800b32:	29 f0                	sub    %esi,%eax
}
  800b34:	5b                   	pop    %ebx
  800b35:	5e                   	pop    %esi
  800b36:	5d                   	pop    %ebp
  800b37:	c3                   	ret    

00800b38 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800b38:	f3 0f 1e fb          	endbr32 
  800b3c:	55                   	push   %ebp
  800b3d:	89 e5                	mov    %esp,%ebp
  800b3f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b42:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800b45:	0f b6 01             	movzbl (%ecx),%eax
  800b48:	84 c0                	test   %al,%al
  800b4a:	74 0c                	je     800b58 <strcmp+0x20>
  800b4c:	3a 02                	cmp    (%edx),%al
  800b4e:	75 08                	jne    800b58 <strcmp+0x20>
		p++, q++;
  800b50:	83 c1 01             	add    $0x1,%ecx
  800b53:	83 c2 01             	add    $0x1,%edx
  800b56:	eb ed                	jmp    800b45 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800b58:	0f b6 c0             	movzbl %al,%eax
  800b5b:	0f b6 12             	movzbl (%edx),%edx
  800b5e:	29 d0                	sub    %edx,%eax
}
  800b60:	5d                   	pop    %ebp
  800b61:	c3                   	ret    

00800b62 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b62:	f3 0f 1e fb          	endbr32 
  800b66:	55                   	push   %ebp
  800b67:	89 e5                	mov    %esp,%ebp
  800b69:	53                   	push   %ebx
  800b6a:	8b 45 08             	mov    0x8(%ebp),%eax
  800b6d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b70:	89 c3                	mov    %eax,%ebx
  800b72:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800b75:	eb 06                	jmp    800b7d <strncmp+0x1b>
		n--, p++, q++;
  800b77:	83 c0 01             	add    $0x1,%eax
  800b7a:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800b7d:	39 d8                	cmp    %ebx,%eax
  800b7f:	74 16                	je     800b97 <strncmp+0x35>
  800b81:	0f b6 08             	movzbl (%eax),%ecx
  800b84:	84 c9                	test   %cl,%cl
  800b86:	74 04                	je     800b8c <strncmp+0x2a>
  800b88:	3a 0a                	cmp    (%edx),%cl
  800b8a:	74 eb                	je     800b77 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b8c:	0f b6 00             	movzbl (%eax),%eax
  800b8f:	0f b6 12             	movzbl (%edx),%edx
  800b92:	29 d0                	sub    %edx,%eax
}
  800b94:	5b                   	pop    %ebx
  800b95:	5d                   	pop    %ebp
  800b96:	c3                   	ret    
		return 0;
  800b97:	b8 00 00 00 00       	mov    $0x0,%eax
  800b9c:	eb f6                	jmp    800b94 <strncmp+0x32>

00800b9e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b9e:	f3 0f 1e fb          	endbr32 
  800ba2:	55                   	push   %ebp
  800ba3:	89 e5                	mov    %esp,%ebp
  800ba5:	8b 45 08             	mov    0x8(%ebp),%eax
  800ba8:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800bac:	0f b6 10             	movzbl (%eax),%edx
  800baf:	84 d2                	test   %dl,%dl
  800bb1:	74 09                	je     800bbc <strchr+0x1e>
		if (*s == c)
  800bb3:	38 ca                	cmp    %cl,%dl
  800bb5:	74 0a                	je     800bc1 <strchr+0x23>
	for (; *s; s++)
  800bb7:	83 c0 01             	add    $0x1,%eax
  800bba:	eb f0                	jmp    800bac <strchr+0xe>
			return (char *) s;
	return 0;
  800bbc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bc1:	5d                   	pop    %ebp
  800bc2:	c3                   	ret    

00800bc3 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800bc3:	f3 0f 1e fb          	endbr32 
  800bc7:	55                   	push   %ebp
  800bc8:	89 e5                	mov    %esp,%ebp
  800bca:	8b 45 08             	mov    0x8(%ebp),%eax
  800bcd:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800bd1:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800bd4:	38 ca                	cmp    %cl,%dl
  800bd6:	74 09                	je     800be1 <strfind+0x1e>
  800bd8:	84 d2                	test   %dl,%dl
  800bda:	74 05                	je     800be1 <strfind+0x1e>
	for (; *s; s++)
  800bdc:	83 c0 01             	add    $0x1,%eax
  800bdf:	eb f0                	jmp    800bd1 <strfind+0xe>
			break;
	return (char *) s;
}
  800be1:	5d                   	pop    %ebp
  800be2:	c3                   	ret    

00800be3 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800be3:	f3 0f 1e fb          	endbr32 
  800be7:	55                   	push   %ebp
  800be8:	89 e5                	mov    %esp,%ebp
  800bea:	57                   	push   %edi
  800beb:	56                   	push   %esi
  800bec:	53                   	push   %ebx
  800bed:	8b 7d 08             	mov    0x8(%ebp),%edi
  800bf0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800bf3:	85 c9                	test   %ecx,%ecx
  800bf5:	74 31                	je     800c28 <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800bf7:	89 f8                	mov    %edi,%eax
  800bf9:	09 c8                	or     %ecx,%eax
  800bfb:	a8 03                	test   $0x3,%al
  800bfd:	75 23                	jne    800c22 <memset+0x3f>
		c &= 0xFF;
  800bff:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800c03:	89 d3                	mov    %edx,%ebx
  800c05:	c1 e3 08             	shl    $0x8,%ebx
  800c08:	89 d0                	mov    %edx,%eax
  800c0a:	c1 e0 18             	shl    $0x18,%eax
  800c0d:	89 d6                	mov    %edx,%esi
  800c0f:	c1 e6 10             	shl    $0x10,%esi
  800c12:	09 f0                	or     %esi,%eax
  800c14:	09 c2                	or     %eax,%edx
  800c16:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800c18:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800c1b:	89 d0                	mov    %edx,%eax
  800c1d:	fc                   	cld    
  800c1e:	f3 ab                	rep stos %eax,%es:(%edi)
  800c20:	eb 06                	jmp    800c28 <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800c22:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c25:	fc                   	cld    
  800c26:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800c28:	89 f8                	mov    %edi,%eax
  800c2a:	5b                   	pop    %ebx
  800c2b:	5e                   	pop    %esi
  800c2c:	5f                   	pop    %edi
  800c2d:	5d                   	pop    %ebp
  800c2e:	c3                   	ret    

00800c2f <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800c2f:	f3 0f 1e fb          	endbr32 
  800c33:	55                   	push   %ebp
  800c34:	89 e5                	mov    %esp,%ebp
  800c36:	57                   	push   %edi
  800c37:	56                   	push   %esi
  800c38:	8b 45 08             	mov    0x8(%ebp),%eax
  800c3b:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c3e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800c41:	39 c6                	cmp    %eax,%esi
  800c43:	73 32                	jae    800c77 <memmove+0x48>
  800c45:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c48:	39 c2                	cmp    %eax,%edx
  800c4a:	76 2b                	jbe    800c77 <memmove+0x48>
		s += n;
		d += n;
  800c4c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c4f:	89 fe                	mov    %edi,%esi
  800c51:	09 ce                	or     %ecx,%esi
  800c53:	09 d6                	or     %edx,%esi
  800c55:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c5b:	75 0e                	jne    800c6b <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800c5d:	83 ef 04             	sub    $0x4,%edi
  800c60:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c63:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800c66:	fd                   	std    
  800c67:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c69:	eb 09                	jmp    800c74 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800c6b:	83 ef 01             	sub    $0x1,%edi
  800c6e:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800c71:	fd                   	std    
  800c72:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c74:	fc                   	cld    
  800c75:	eb 1a                	jmp    800c91 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c77:	89 c2                	mov    %eax,%edx
  800c79:	09 ca                	or     %ecx,%edx
  800c7b:	09 f2                	or     %esi,%edx
  800c7d:	f6 c2 03             	test   $0x3,%dl
  800c80:	75 0a                	jne    800c8c <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800c82:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800c85:	89 c7                	mov    %eax,%edi
  800c87:	fc                   	cld    
  800c88:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c8a:	eb 05                	jmp    800c91 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800c8c:	89 c7                	mov    %eax,%edi
  800c8e:	fc                   	cld    
  800c8f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c91:	5e                   	pop    %esi
  800c92:	5f                   	pop    %edi
  800c93:	5d                   	pop    %ebp
  800c94:	c3                   	ret    

00800c95 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c95:	f3 0f 1e fb          	endbr32 
  800c99:	55                   	push   %ebp
  800c9a:	89 e5                	mov    %esp,%ebp
  800c9c:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800c9f:	ff 75 10             	pushl  0x10(%ebp)
  800ca2:	ff 75 0c             	pushl  0xc(%ebp)
  800ca5:	ff 75 08             	pushl  0x8(%ebp)
  800ca8:	e8 82 ff ff ff       	call   800c2f <memmove>
}
  800cad:	c9                   	leave  
  800cae:	c3                   	ret    

00800caf <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800caf:	f3 0f 1e fb          	endbr32 
  800cb3:	55                   	push   %ebp
  800cb4:	89 e5                	mov    %esp,%ebp
  800cb6:	56                   	push   %esi
  800cb7:	53                   	push   %ebx
  800cb8:	8b 45 08             	mov    0x8(%ebp),%eax
  800cbb:	8b 55 0c             	mov    0xc(%ebp),%edx
  800cbe:	89 c6                	mov    %eax,%esi
  800cc0:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800cc3:	39 f0                	cmp    %esi,%eax
  800cc5:	74 1c                	je     800ce3 <memcmp+0x34>
		if (*s1 != *s2)
  800cc7:	0f b6 08             	movzbl (%eax),%ecx
  800cca:	0f b6 1a             	movzbl (%edx),%ebx
  800ccd:	38 d9                	cmp    %bl,%cl
  800ccf:	75 08                	jne    800cd9 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800cd1:	83 c0 01             	add    $0x1,%eax
  800cd4:	83 c2 01             	add    $0x1,%edx
  800cd7:	eb ea                	jmp    800cc3 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800cd9:	0f b6 c1             	movzbl %cl,%eax
  800cdc:	0f b6 db             	movzbl %bl,%ebx
  800cdf:	29 d8                	sub    %ebx,%eax
  800ce1:	eb 05                	jmp    800ce8 <memcmp+0x39>
	}

	return 0;
  800ce3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ce8:	5b                   	pop    %ebx
  800ce9:	5e                   	pop    %esi
  800cea:	5d                   	pop    %ebp
  800ceb:	c3                   	ret    

00800cec <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800cec:	f3 0f 1e fb          	endbr32 
  800cf0:	55                   	push   %ebp
  800cf1:	89 e5                	mov    %esp,%ebp
  800cf3:	8b 45 08             	mov    0x8(%ebp),%eax
  800cf6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800cf9:	89 c2                	mov    %eax,%edx
  800cfb:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800cfe:	39 d0                	cmp    %edx,%eax
  800d00:	73 09                	jae    800d0b <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d02:	38 08                	cmp    %cl,(%eax)
  800d04:	74 05                	je     800d0b <memfind+0x1f>
	for (; s < ends; s++)
  800d06:	83 c0 01             	add    $0x1,%eax
  800d09:	eb f3                	jmp    800cfe <memfind+0x12>
			break;
	return (void *) s;
}
  800d0b:	5d                   	pop    %ebp
  800d0c:	c3                   	ret    

00800d0d <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800d0d:	f3 0f 1e fb          	endbr32 
  800d11:	55                   	push   %ebp
  800d12:	89 e5                	mov    %esp,%ebp
  800d14:	57                   	push   %edi
  800d15:	56                   	push   %esi
  800d16:	53                   	push   %ebx
  800d17:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d1a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d1d:	eb 03                	jmp    800d22 <strtol+0x15>
		s++;
  800d1f:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800d22:	0f b6 01             	movzbl (%ecx),%eax
  800d25:	3c 20                	cmp    $0x20,%al
  800d27:	74 f6                	je     800d1f <strtol+0x12>
  800d29:	3c 09                	cmp    $0x9,%al
  800d2b:	74 f2                	je     800d1f <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800d2d:	3c 2b                	cmp    $0x2b,%al
  800d2f:	74 2a                	je     800d5b <strtol+0x4e>
	int neg = 0;
  800d31:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800d36:	3c 2d                	cmp    $0x2d,%al
  800d38:	74 2b                	je     800d65 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d3a:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800d40:	75 0f                	jne    800d51 <strtol+0x44>
  800d42:	80 39 30             	cmpb   $0x30,(%ecx)
  800d45:	74 28                	je     800d6f <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800d47:	85 db                	test   %ebx,%ebx
  800d49:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d4e:	0f 44 d8             	cmove  %eax,%ebx
  800d51:	b8 00 00 00 00       	mov    $0x0,%eax
  800d56:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800d59:	eb 46                	jmp    800da1 <strtol+0x94>
		s++;
  800d5b:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800d5e:	bf 00 00 00 00       	mov    $0x0,%edi
  800d63:	eb d5                	jmp    800d3a <strtol+0x2d>
		s++, neg = 1;
  800d65:	83 c1 01             	add    $0x1,%ecx
  800d68:	bf 01 00 00 00       	mov    $0x1,%edi
  800d6d:	eb cb                	jmp    800d3a <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d6f:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800d73:	74 0e                	je     800d83 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800d75:	85 db                	test   %ebx,%ebx
  800d77:	75 d8                	jne    800d51 <strtol+0x44>
		s++, base = 8;
  800d79:	83 c1 01             	add    $0x1,%ecx
  800d7c:	bb 08 00 00 00       	mov    $0x8,%ebx
  800d81:	eb ce                	jmp    800d51 <strtol+0x44>
		s += 2, base = 16;
  800d83:	83 c1 02             	add    $0x2,%ecx
  800d86:	bb 10 00 00 00       	mov    $0x10,%ebx
  800d8b:	eb c4                	jmp    800d51 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800d8d:	0f be d2             	movsbl %dl,%edx
  800d90:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800d93:	3b 55 10             	cmp    0x10(%ebp),%edx
  800d96:	7d 3a                	jge    800dd2 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800d98:	83 c1 01             	add    $0x1,%ecx
  800d9b:	0f af 45 10          	imul   0x10(%ebp),%eax
  800d9f:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800da1:	0f b6 11             	movzbl (%ecx),%edx
  800da4:	8d 72 d0             	lea    -0x30(%edx),%esi
  800da7:	89 f3                	mov    %esi,%ebx
  800da9:	80 fb 09             	cmp    $0x9,%bl
  800dac:	76 df                	jbe    800d8d <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800dae:	8d 72 9f             	lea    -0x61(%edx),%esi
  800db1:	89 f3                	mov    %esi,%ebx
  800db3:	80 fb 19             	cmp    $0x19,%bl
  800db6:	77 08                	ja     800dc0 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800db8:	0f be d2             	movsbl %dl,%edx
  800dbb:	83 ea 57             	sub    $0x57,%edx
  800dbe:	eb d3                	jmp    800d93 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800dc0:	8d 72 bf             	lea    -0x41(%edx),%esi
  800dc3:	89 f3                	mov    %esi,%ebx
  800dc5:	80 fb 19             	cmp    $0x19,%bl
  800dc8:	77 08                	ja     800dd2 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800dca:	0f be d2             	movsbl %dl,%edx
  800dcd:	83 ea 37             	sub    $0x37,%edx
  800dd0:	eb c1                	jmp    800d93 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800dd2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800dd6:	74 05                	je     800ddd <strtol+0xd0>
		*endptr = (char *) s;
  800dd8:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ddb:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800ddd:	89 c2                	mov    %eax,%edx
  800ddf:	f7 da                	neg    %edx
  800de1:	85 ff                	test   %edi,%edi
  800de3:	0f 45 c2             	cmovne %edx,%eax
}
  800de6:	5b                   	pop    %ebx
  800de7:	5e                   	pop    %esi
  800de8:	5f                   	pop    %edi
  800de9:	5d                   	pop    %ebp
  800dea:	c3                   	ret    
  800deb:	66 90                	xchg   %ax,%ax
  800ded:	66 90                	xchg   %ax,%ax
  800def:	90                   	nop

00800df0 <__udivdi3>:
  800df0:	f3 0f 1e fb          	endbr32 
  800df4:	55                   	push   %ebp
  800df5:	57                   	push   %edi
  800df6:	56                   	push   %esi
  800df7:	53                   	push   %ebx
  800df8:	83 ec 1c             	sub    $0x1c,%esp
  800dfb:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800dff:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800e03:	8b 74 24 34          	mov    0x34(%esp),%esi
  800e07:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800e0b:	85 d2                	test   %edx,%edx
  800e0d:	75 19                	jne    800e28 <__udivdi3+0x38>
  800e0f:	39 f3                	cmp    %esi,%ebx
  800e11:	76 4d                	jbe    800e60 <__udivdi3+0x70>
  800e13:	31 ff                	xor    %edi,%edi
  800e15:	89 e8                	mov    %ebp,%eax
  800e17:	89 f2                	mov    %esi,%edx
  800e19:	f7 f3                	div    %ebx
  800e1b:	89 fa                	mov    %edi,%edx
  800e1d:	83 c4 1c             	add    $0x1c,%esp
  800e20:	5b                   	pop    %ebx
  800e21:	5e                   	pop    %esi
  800e22:	5f                   	pop    %edi
  800e23:	5d                   	pop    %ebp
  800e24:	c3                   	ret    
  800e25:	8d 76 00             	lea    0x0(%esi),%esi
  800e28:	39 f2                	cmp    %esi,%edx
  800e2a:	76 14                	jbe    800e40 <__udivdi3+0x50>
  800e2c:	31 ff                	xor    %edi,%edi
  800e2e:	31 c0                	xor    %eax,%eax
  800e30:	89 fa                	mov    %edi,%edx
  800e32:	83 c4 1c             	add    $0x1c,%esp
  800e35:	5b                   	pop    %ebx
  800e36:	5e                   	pop    %esi
  800e37:	5f                   	pop    %edi
  800e38:	5d                   	pop    %ebp
  800e39:	c3                   	ret    
  800e3a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800e40:	0f bd fa             	bsr    %edx,%edi
  800e43:	83 f7 1f             	xor    $0x1f,%edi
  800e46:	75 48                	jne    800e90 <__udivdi3+0xa0>
  800e48:	39 f2                	cmp    %esi,%edx
  800e4a:	72 06                	jb     800e52 <__udivdi3+0x62>
  800e4c:	31 c0                	xor    %eax,%eax
  800e4e:	39 eb                	cmp    %ebp,%ebx
  800e50:	77 de                	ja     800e30 <__udivdi3+0x40>
  800e52:	b8 01 00 00 00       	mov    $0x1,%eax
  800e57:	eb d7                	jmp    800e30 <__udivdi3+0x40>
  800e59:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e60:	89 d9                	mov    %ebx,%ecx
  800e62:	85 db                	test   %ebx,%ebx
  800e64:	75 0b                	jne    800e71 <__udivdi3+0x81>
  800e66:	b8 01 00 00 00       	mov    $0x1,%eax
  800e6b:	31 d2                	xor    %edx,%edx
  800e6d:	f7 f3                	div    %ebx
  800e6f:	89 c1                	mov    %eax,%ecx
  800e71:	31 d2                	xor    %edx,%edx
  800e73:	89 f0                	mov    %esi,%eax
  800e75:	f7 f1                	div    %ecx
  800e77:	89 c6                	mov    %eax,%esi
  800e79:	89 e8                	mov    %ebp,%eax
  800e7b:	89 f7                	mov    %esi,%edi
  800e7d:	f7 f1                	div    %ecx
  800e7f:	89 fa                	mov    %edi,%edx
  800e81:	83 c4 1c             	add    $0x1c,%esp
  800e84:	5b                   	pop    %ebx
  800e85:	5e                   	pop    %esi
  800e86:	5f                   	pop    %edi
  800e87:	5d                   	pop    %ebp
  800e88:	c3                   	ret    
  800e89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e90:	89 f9                	mov    %edi,%ecx
  800e92:	b8 20 00 00 00       	mov    $0x20,%eax
  800e97:	29 f8                	sub    %edi,%eax
  800e99:	d3 e2                	shl    %cl,%edx
  800e9b:	89 54 24 08          	mov    %edx,0x8(%esp)
  800e9f:	89 c1                	mov    %eax,%ecx
  800ea1:	89 da                	mov    %ebx,%edx
  800ea3:	d3 ea                	shr    %cl,%edx
  800ea5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800ea9:	09 d1                	or     %edx,%ecx
  800eab:	89 f2                	mov    %esi,%edx
  800ead:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800eb1:	89 f9                	mov    %edi,%ecx
  800eb3:	d3 e3                	shl    %cl,%ebx
  800eb5:	89 c1                	mov    %eax,%ecx
  800eb7:	d3 ea                	shr    %cl,%edx
  800eb9:	89 f9                	mov    %edi,%ecx
  800ebb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800ebf:	89 eb                	mov    %ebp,%ebx
  800ec1:	d3 e6                	shl    %cl,%esi
  800ec3:	89 c1                	mov    %eax,%ecx
  800ec5:	d3 eb                	shr    %cl,%ebx
  800ec7:	09 de                	or     %ebx,%esi
  800ec9:	89 f0                	mov    %esi,%eax
  800ecb:	f7 74 24 08          	divl   0x8(%esp)
  800ecf:	89 d6                	mov    %edx,%esi
  800ed1:	89 c3                	mov    %eax,%ebx
  800ed3:	f7 64 24 0c          	mull   0xc(%esp)
  800ed7:	39 d6                	cmp    %edx,%esi
  800ed9:	72 15                	jb     800ef0 <__udivdi3+0x100>
  800edb:	89 f9                	mov    %edi,%ecx
  800edd:	d3 e5                	shl    %cl,%ebp
  800edf:	39 c5                	cmp    %eax,%ebp
  800ee1:	73 04                	jae    800ee7 <__udivdi3+0xf7>
  800ee3:	39 d6                	cmp    %edx,%esi
  800ee5:	74 09                	je     800ef0 <__udivdi3+0x100>
  800ee7:	89 d8                	mov    %ebx,%eax
  800ee9:	31 ff                	xor    %edi,%edi
  800eeb:	e9 40 ff ff ff       	jmp    800e30 <__udivdi3+0x40>
  800ef0:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800ef3:	31 ff                	xor    %edi,%edi
  800ef5:	e9 36 ff ff ff       	jmp    800e30 <__udivdi3+0x40>
  800efa:	66 90                	xchg   %ax,%ax
  800efc:	66 90                	xchg   %ax,%ax
  800efe:	66 90                	xchg   %ax,%ax

00800f00 <__umoddi3>:
  800f00:	f3 0f 1e fb          	endbr32 
  800f04:	55                   	push   %ebp
  800f05:	57                   	push   %edi
  800f06:	56                   	push   %esi
  800f07:	53                   	push   %ebx
  800f08:	83 ec 1c             	sub    $0x1c,%esp
  800f0b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  800f0f:	8b 74 24 30          	mov    0x30(%esp),%esi
  800f13:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800f17:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800f1b:	85 c0                	test   %eax,%eax
  800f1d:	75 19                	jne    800f38 <__umoddi3+0x38>
  800f1f:	39 df                	cmp    %ebx,%edi
  800f21:	76 5d                	jbe    800f80 <__umoddi3+0x80>
  800f23:	89 f0                	mov    %esi,%eax
  800f25:	89 da                	mov    %ebx,%edx
  800f27:	f7 f7                	div    %edi
  800f29:	89 d0                	mov    %edx,%eax
  800f2b:	31 d2                	xor    %edx,%edx
  800f2d:	83 c4 1c             	add    $0x1c,%esp
  800f30:	5b                   	pop    %ebx
  800f31:	5e                   	pop    %esi
  800f32:	5f                   	pop    %edi
  800f33:	5d                   	pop    %ebp
  800f34:	c3                   	ret    
  800f35:	8d 76 00             	lea    0x0(%esi),%esi
  800f38:	89 f2                	mov    %esi,%edx
  800f3a:	39 d8                	cmp    %ebx,%eax
  800f3c:	76 12                	jbe    800f50 <__umoddi3+0x50>
  800f3e:	89 f0                	mov    %esi,%eax
  800f40:	89 da                	mov    %ebx,%edx
  800f42:	83 c4 1c             	add    $0x1c,%esp
  800f45:	5b                   	pop    %ebx
  800f46:	5e                   	pop    %esi
  800f47:	5f                   	pop    %edi
  800f48:	5d                   	pop    %ebp
  800f49:	c3                   	ret    
  800f4a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800f50:	0f bd e8             	bsr    %eax,%ebp
  800f53:	83 f5 1f             	xor    $0x1f,%ebp
  800f56:	75 50                	jne    800fa8 <__umoddi3+0xa8>
  800f58:	39 d8                	cmp    %ebx,%eax
  800f5a:	0f 82 e0 00 00 00    	jb     801040 <__umoddi3+0x140>
  800f60:	89 d9                	mov    %ebx,%ecx
  800f62:	39 f7                	cmp    %esi,%edi
  800f64:	0f 86 d6 00 00 00    	jbe    801040 <__umoddi3+0x140>
  800f6a:	89 d0                	mov    %edx,%eax
  800f6c:	89 ca                	mov    %ecx,%edx
  800f6e:	83 c4 1c             	add    $0x1c,%esp
  800f71:	5b                   	pop    %ebx
  800f72:	5e                   	pop    %esi
  800f73:	5f                   	pop    %edi
  800f74:	5d                   	pop    %ebp
  800f75:	c3                   	ret    
  800f76:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f7d:	8d 76 00             	lea    0x0(%esi),%esi
  800f80:	89 fd                	mov    %edi,%ebp
  800f82:	85 ff                	test   %edi,%edi
  800f84:	75 0b                	jne    800f91 <__umoddi3+0x91>
  800f86:	b8 01 00 00 00       	mov    $0x1,%eax
  800f8b:	31 d2                	xor    %edx,%edx
  800f8d:	f7 f7                	div    %edi
  800f8f:	89 c5                	mov    %eax,%ebp
  800f91:	89 d8                	mov    %ebx,%eax
  800f93:	31 d2                	xor    %edx,%edx
  800f95:	f7 f5                	div    %ebp
  800f97:	89 f0                	mov    %esi,%eax
  800f99:	f7 f5                	div    %ebp
  800f9b:	89 d0                	mov    %edx,%eax
  800f9d:	31 d2                	xor    %edx,%edx
  800f9f:	eb 8c                	jmp    800f2d <__umoddi3+0x2d>
  800fa1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800fa8:	89 e9                	mov    %ebp,%ecx
  800faa:	ba 20 00 00 00       	mov    $0x20,%edx
  800faf:	29 ea                	sub    %ebp,%edx
  800fb1:	d3 e0                	shl    %cl,%eax
  800fb3:	89 44 24 08          	mov    %eax,0x8(%esp)
  800fb7:	89 d1                	mov    %edx,%ecx
  800fb9:	89 f8                	mov    %edi,%eax
  800fbb:	d3 e8                	shr    %cl,%eax
  800fbd:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800fc1:	89 54 24 04          	mov    %edx,0x4(%esp)
  800fc5:	8b 54 24 04          	mov    0x4(%esp),%edx
  800fc9:	09 c1                	or     %eax,%ecx
  800fcb:	89 d8                	mov    %ebx,%eax
  800fcd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800fd1:	89 e9                	mov    %ebp,%ecx
  800fd3:	d3 e7                	shl    %cl,%edi
  800fd5:	89 d1                	mov    %edx,%ecx
  800fd7:	d3 e8                	shr    %cl,%eax
  800fd9:	89 e9                	mov    %ebp,%ecx
  800fdb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800fdf:	d3 e3                	shl    %cl,%ebx
  800fe1:	89 c7                	mov    %eax,%edi
  800fe3:	89 d1                	mov    %edx,%ecx
  800fe5:	89 f0                	mov    %esi,%eax
  800fe7:	d3 e8                	shr    %cl,%eax
  800fe9:	89 e9                	mov    %ebp,%ecx
  800feb:	89 fa                	mov    %edi,%edx
  800fed:	d3 e6                	shl    %cl,%esi
  800fef:	09 d8                	or     %ebx,%eax
  800ff1:	f7 74 24 08          	divl   0x8(%esp)
  800ff5:	89 d1                	mov    %edx,%ecx
  800ff7:	89 f3                	mov    %esi,%ebx
  800ff9:	f7 64 24 0c          	mull   0xc(%esp)
  800ffd:	89 c6                	mov    %eax,%esi
  800fff:	89 d7                	mov    %edx,%edi
  801001:	39 d1                	cmp    %edx,%ecx
  801003:	72 06                	jb     80100b <__umoddi3+0x10b>
  801005:	75 10                	jne    801017 <__umoddi3+0x117>
  801007:	39 c3                	cmp    %eax,%ebx
  801009:	73 0c                	jae    801017 <__umoddi3+0x117>
  80100b:	2b 44 24 0c          	sub    0xc(%esp),%eax
  80100f:	1b 54 24 08          	sbb    0x8(%esp),%edx
  801013:	89 d7                	mov    %edx,%edi
  801015:	89 c6                	mov    %eax,%esi
  801017:	89 ca                	mov    %ecx,%edx
  801019:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80101e:	29 f3                	sub    %esi,%ebx
  801020:	19 fa                	sbb    %edi,%edx
  801022:	89 d0                	mov    %edx,%eax
  801024:	d3 e0                	shl    %cl,%eax
  801026:	89 e9                	mov    %ebp,%ecx
  801028:	d3 eb                	shr    %cl,%ebx
  80102a:	d3 ea                	shr    %cl,%edx
  80102c:	09 d8                	or     %ebx,%eax
  80102e:	83 c4 1c             	add    $0x1c,%esp
  801031:	5b                   	pop    %ebx
  801032:	5e                   	pop    %esi
  801033:	5f                   	pop    %edi
  801034:	5d                   	pop    %ebp
  801035:	c3                   	ret    
  801036:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80103d:	8d 76 00             	lea    0x0(%esi),%esi
  801040:	29 fe                	sub    %edi,%esi
  801042:	19 c3                	sbb    %eax,%ebx
  801044:	89 f2                	mov    %esi,%edx
  801046:	89 d9                	mov    %ebx,%ecx
  801048:	e9 1d ff ff ff       	jmp    800f6a <__umoddi3+0x6a>
