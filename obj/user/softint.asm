
obj/user/softint:     file format elf32-i386


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
  80002c:	e8 09 00 00 00       	call   80003a <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	f3 0f 1e fb          	endbr32 
	asm volatile("int $14");	// page fault
  800037:	cd 0e                	int    $0xe
}
  800039:	c3                   	ret    

0080003a <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80003a:	f3 0f 1e fb          	endbr32 
  80003e:	55                   	push   %ebp
  80003f:	89 e5                	mov    %esp,%ebp
  800041:	56                   	push   %esi
  800042:	53                   	push   %ebx
  800043:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800046:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv=&envs[ENVX(sys_getenvid())];
  800049:	e8 d6 00 00 00       	call   800124 <sys_getenvid>
  80004e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800053:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800056:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80005b:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800060:	85 db                	test   %ebx,%ebx
  800062:	7e 07                	jle    80006b <libmain+0x31>
		binaryname = argv[0];
  800064:	8b 06                	mov    (%esi),%eax
  800066:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80006b:	83 ec 08             	sub    $0x8,%esp
  80006e:	56                   	push   %esi
  80006f:	53                   	push   %ebx
  800070:	e8 be ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800075:	e8 0a 00 00 00       	call   800084 <exit>
}
  80007a:	83 c4 10             	add    $0x10,%esp
  80007d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800080:	5b                   	pop    %ebx
  800081:	5e                   	pop    %esi
  800082:	5d                   	pop    %ebp
  800083:	c3                   	ret    

00800084 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800084:	f3 0f 1e fb          	endbr32 
  800088:	55                   	push   %ebp
  800089:	89 e5                	mov    %esp,%ebp
  80008b:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80008e:	6a 00                	push   $0x0
  800090:	e8 4a 00 00 00       	call   8000df <sys_env_destroy>
}
  800095:	83 c4 10             	add    $0x10,%esp
  800098:	c9                   	leave  
  800099:	c3                   	ret    

0080009a <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  80009a:	f3 0f 1e fb          	endbr32 
  80009e:	55                   	push   %ebp
  80009f:	89 e5                	mov    %esp,%ebp
  8000a1:	57                   	push   %edi
  8000a2:	56                   	push   %esi
  8000a3:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000a4:	b8 00 00 00 00       	mov    $0x0,%eax
  8000a9:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000af:	89 c3                	mov    %eax,%ebx
  8000b1:	89 c7                	mov    %eax,%edi
  8000b3:	89 c6                	mov    %eax,%esi
  8000b5:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000b7:	5b                   	pop    %ebx
  8000b8:	5e                   	pop    %esi
  8000b9:	5f                   	pop    %edi
  8000ba:	5d                   	pop    %ebp
  8000bb:	c3                   	ret    

008000bc <sys_cgetc>:

int
sys_cgetc(void)
{
  8000bc:	f3 0f 1e fb          	endbr32 
  8000c0:	55                   	push   %ebp
  8000c1:	89 e5                	mov    %esp,%ebp
  8000c3:	57                   	push   %edi
  8000c4:	56                   	push   %esi
  8000c5:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000c6:	ba 00 00 00 00       	mov    $0x0,%edx
  8000cb:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d0:	89 d1                	mov    %edx,%ecx
  8000d2:	89 d3                	mov    %edx,%ebx
  8000d4:	89 d7                	mov    %edx,%edi
  8000d6:	89 d6                	mov    %edx,%esi
  8000d8:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000da:	5b                   	pop    %ebx
  8000db:	5e                   	pop    %esi
  8000dc:	5f                   	pop    %edi
  8000dd:	5d                   	pop    %ebp
  8000de:	c3                   	ret    

008000df <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000df:	f3 0f 1e fb          	endbr32 
  8000e3:	55                   	push   %ebp
  8000e4:	89 e5                	mov    %esp,%ebp
  8000e6:	57                   	push   %edi
  8000e7:	56                   	push   %esi
  8000e8:	53                   	push   %ebx
  8000e9:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8000ec:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000f1:	8b 55 08             	mov    0x8(%ebp),%edx
  8000f4:	b8 03 00 00 00       	mov    $0x3,%eax
  8000f9:	89 cb                	mov    %ecx,%ebx
  8000fb:	89 cf                	mov    %ecx,%edi
  8000fd:	89 ce                	mov    %ecx,%esi
  8000ff:	cd 30                	int    $0x30
	if(check && ret > 0)
  800101:	85 c0                	test   %eax,%eax
  800103:	7f 08                	jg     80010d <sys_env_destroy+0x2e>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800105:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800108:	5b                   	pop    %ebx
  800109:	5e                   	pop    %esi
  80010a:	5f                   	pop    %edi
  80010b:	5d                   	pop    %ebp
  80010c:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80010d:	83 ec 0c             	sub    $0xc,%esp
  800110:	50                   	push   %eax
  800111:	6a 03                	push   $0x3
  800113:	68 4a 10 80 00       	push   $0x80104a
  800118:	6a 23                	push   $0x23
  80011a:	68 67 10 80 00       	push   $0x801067
  80011f:	e8 11 02 00 00       	call   800335 <_panic>

00800124 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800124:	f3 0f 1e fb          	endbr32 
  800128:	55                   	push   %ebp
  800129:	89 e5                	mov    %esp,%ebp
  80012b:	57                   	push   %edi
  80012c:	56                   	push   %esi
  80012d:	53                   	push   %ebx
	asm volatile("int %1\n"
  80012e:	ba 00 00 00 00       	mov    $0x0,%edx
  800133:	b8 02 00 00 00       	mov    $0x2,%eax
  800138:	89 d1                	mov    %edx,%ecx
  80013a:	89 d3                	mov    %edx,%ebx
  80013c:	89 d7                	mov    %edx,%edi
  80013e:	89 d6                	mov    %edx,%esi
  800140:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800142:	5b                   	pop    %ebx
  800143:	5e                   	pop    %esi
  800144:	5f                   	pop    %edi
  800145:	5d                   	pop    %ebp
  800146:	c3                   	ret    

00800147 <sys_yield>:

void
sys_yield(void)
{
  800147:	f3 0f 1e fb          	endbr32 
  80014b:	55                   	push   %ebp
  80014c:	89 e5                	mov    %esp,%ebp
  80014e:	57                   	push   %edi
  80014f:	56                   	push   %esi
  800150:	53                   	push   %ebx
	asm volatile("int %1\n"
  800151:	ba 00 00 00 00       	mov    $0x0,%edx
  800156:	b8 0a 00 00 00       	mov    $0xa,%eax
  80015b:	89 d1                	mov    %edx,%ecx
  80015d:	89 d3                	mov    %edx,%ebx
  80015f:	89 d7                	mov    %edx,%edi
  800161:	89 d6                	mov    %edx,%esi
  800163:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800165:	5b                   	pop    %ebx
  800166:	5e                   	pop    %esi
  800167:	5f                   	pop    %edi
  800168:	5d                   	pop    %ebp
  800169:	c3                   	ret    

0080016a <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80016a:	f3 0f 1e fb          	endbr32 
  80016e:	55                   	push   %ebp
  80016f:	89 e5                	mov    %esp,%ebp
  800171:	57                   	push   %edi
  800172:	56                   	push   %esi
  800173:	53                   	push   %ebx
  800174:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800177:	be 00 00 00 00       	mov    $0x0,%esi
  80017c:	8b 55 08             	mov    0x8(%ebp),%edx
  80017f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800182:	b8 04 00 00 00       	mov    $0x4,%eax
  800187:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80018a:	89 f7                	mov    %esi,%edi
  80018c:	cd 30                	int    $0x30
	if(check && ret > 0)
  80018e:	85 c0                	test   %eax,%eax
  800190:	7f 08                	jg     80019a <sys_page_alloc+0x30>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800192:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800195:	5b                   	pop    %ebx
  800196:	5e                   	pop    %esi
  800197:	5f                   	pop    %edi
  800198:	5d                   	pop    %ebp
  800199:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80019a:	83 ec 0c             	sub    $0xc,%esp
  80019d:	50                   	push   %eax
  80019e:	6a 04                	push   $0x4
  8001a0:	68 4a 10 80 00       	push   $0x80104a
  8001a5:	6a 23                	push   $0x23
  8001a7:	68 67 10 80 00       	push   $0x801067
  8001ac:	e8 84 01 00 00       	call   800335 <_panic>

008001b1 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001b1:	f3 0f 1e fb          	endbr32 
  8001b5:	55                   	push   %ebp
  8001b6:	89 e5                	mov    %esp,%ebp
  8001b8:	57                   	push   %edi
  8001b9:	56                   	push   %esi
  8001ba:	53                   	push   %ebx
  8001bb:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001be:	8b 55 08             	mov    0x8(%ebp),%edx
  8001c1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001c4:	b8 05 00 00 00       	mov    $0x5,%eax
  8001c9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001cc:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001cf:	8b 75 18             	mov    0x18(%ebp),%esi
  8001d2:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001d4:	85 c0                	test   %eax,%eax
  8001d6:	7f 08                	jg     8001e0 <sys_page_map+0x2f>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001d8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001db:	5b                   	pop    %ebx
  8001dc:	5e                   	pop    %esi
  8001dd:	5f                   	pop    %edi
  8001de:	5d                   	pop    %ebp
  8001df:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8001e0:	83 ec 0c             	sub    $0xc,%esp
  8001e3:	50                   	push   %eax
  8001e4:	6a 05                	push   $0x5
  8001e6:	68 4a 10 80 00       	push   $0x80104a
  8001eb:	6a 23                	push   $0x23
  8001ed:	68 67 10 80 00       	push   $0x801067
  8001f2:	e8 3e 01 00 00       	call   800335 <_panic>

008001f7 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001f7:	f3 0f 1e fb          	endbr32 
  8001fb:	55                   	push   %ebp
  8001fc:	89 e5                	mov    %esp,%ebp
  8001fe:	57                   	push   %edi
  8001ff:	56                   	push   %esi
  800200:	53                   	push   %ebx
  800201:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800204:	bb 00 00 00 00       	mov    $0x0,%ebx
  800209:	8b 55 08             	mov    0x8(%ebp),%edx
  80020c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80020f:	b8 06 00 00 00       	mov    $0x6,%eax
  800214:	89 df                	mov    %ebx,%edi
  800216:	89 de                	mov    %ebx,%esi
  800218:	cd 30                	int    $0x30
	if(check && ret > 0)
  80021a:	85 c0                	test   %eax,%eax
  80021c:	7f 08                	jg     800226 <sys_page_unmap+0x2f>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80021e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800221:	5b                   	pop    %ebx
  800222:	5e                   	pop    %esi
  800223:	5f                   	pop    %edi
  800224:	5d                   	pop    %ebp
  800225:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800226:	83 ec 0c             	sub    $0xc,%esp
  800229:	50                   	push   %eax
  80022a:	6a 06                	push   $0x6
  80022c:	68 4a 10 80 00       	push   $0x80104a
  800231:	6a 23                	push   $0x23
  800233:	68 67 10 80 00       	push   $0x801067
  800238:	e8 f8 00 00 00       	call   800335 <_panic>

0080023d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80023d:	f3 0f 1e fb          	endbr32 
  800241:	55                   	push   %ebp
  800242:	89 e5                	mov    %esp,%ebp
  800244:	57                   	push   %edi
  800245:	56                   	push   %esi
  800246:	53                   	push   %ebx
  800247:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80024a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80024f:	8b 55 08             	mov    0x8(%ebp),%edx
  800252:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800255:	b8 08 00 00 00       	mov    $0x8,%eax
  80025a:	89 df                	mov    %ebx,%edi
  80025c:	89 de                	mov    %ebx,%esi
  80025e:	cd 30                	int    $0x30
	if(check && ret > 0)
  800260:	85 c0                	test   %eax,%eax
  800262:	7f 08                	jg     80026c <sys_env_set_status+0x2f>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800264:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800267:	5b                   	pop    %ebx
  800268:	5e                   	pop    %esi
  800269:	5f                   	pop    %edi
  80026a:	5d                   	pop    %ebp
  80026b:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80026c:	83 ec 0c             	sub    $0xc,%esp
  80026f:	50                   	push   %eax
  800270:	6a 08                	push   $0x8
  800272:	68 4a 10 80 00       	push   $0x80104a
  800277:	6a 23                	push   $0x23
  800279:	68 67 10 80 00       	push   $0x801067
  80027e:	e8 b2 00 00 00       	call   800335 <_panic>

00800283 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800283:	f3 0f 1e fb          	endbr32 
  800287:	55                   	push   %ebp
  800288:	89 e5                	mov    %esp,%ebp
  80028a:	57                   	push   %edi
  80028b:	56                   	push   %esi
  80028c:	53                   	push   %ebx
  80028d:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800290:	bb 00 00 00 00       	mov    $0x0,%ebx
  800295:	8b 55 08             	mov    0x8(%ebp),%edx
  800298:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80029b:	b8 09 00 00 00       	mov    $0x9,%eax
  8002a0:	89 df                	mov    %ebx,%edi
  8002a2:	89 de                	mov    %ebx,%esi
  8002a4:	cd 30                	int    $0x30
	if(check && ret > 0)
  8002a6:	85 c0                	test   %eax,%eax
  8002a8:	7f 08                	jg     8002b2 <sys_env_set_pgfault_upcall+0x2f>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002aa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002ad:	5b                   	pop    %ebx
  8002ae:	5e                   	pop    %esi
  8002af:	5f                   	pop    %edi
  8002b0:	5d                   	pop    %ebp
  8002b1:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8002b2:	83 ec 0c             	sub    $0xc,%esp
  8002b5:	50                   	push   %eax
  8002b6:	6a 09                	push   $0x9
  8002b8:	68 4a 10 80 00       	push   $0x80104a
  8002bd:	6a 23                	push   $0x23
  8002bf:	68 67 10 80 00       	push   $0x801067
  8002c4:	e8 6c 00 00 00       	call   800335 <_panic>

008002c9 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002c9:	f3 0f 1e fb          	endbr32 
  8002cd:	55                   	push   %ebp
  8002ce:	89 e5                	mov    %esp,%ebp
  8002d0:	57                   	push   %edi
  8002d1:	56                   	push   %esi
  8002d2:	53                   	push   %ebx
	asm volatile("int %1\n"
  8002d3:	8b 55 08             	mov    0x8(%ebp),%edx
  8002d6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002d9:	b8 0b 00 00 00       	mov    $0xb,%eax
  8002de:	be 00 00 00 00       	mov    $0x0,%esi
  8002e3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002e6:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002e9:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8002eb:	5b                   	pop    %ebx
  8002ec:	5e                   	pop    %esi
  8002ed:	5f                   	pop    %edi
  8002ee:	5d                   	pop    %ebp
  8002ef:	c3                   	ret    

008002f0 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8002f0:	f3 0f 1e fb          	endbr32 
  8002f4:	55                   	push   %ebp
  8002f5:	89 e5                	mov    %esp,%ebp
  8002f7:	57                   	push   %edi
  8002f8:	56                   	push   %esi
  8002f9:	53                   	push   %ebx
  8002fa:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8002fd:	b9 00 00 00 00       	mov    $0x0,%ecx
  800302:	8b 55 08             	mov    0x8(%ebp),%edx
  800305:	b8 0c 00 00 00       	mov    $0xc,%eax
  80030a:	89 cb                	mov    %ecx,%ebx
  80030c:	89 cf                	mov    %ecx,%edi
  80030e:	89 ce                	mov    %ecx,%esi
  800310:	cd 30                	int    $0x30
	if(check && ret > 0)
  800312:	85 c0                	test   %eax,%eax
  800314:	7f 08                	jg     80031e <sys_ipc_recv+0x2e>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800316:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800319:	5b                   	pop    %ebx
  80031a:	5e                   	pop    %esi
  80031b:	5f                   	pop    %edi
  80031c:	5d                   	pop    %ebp
  80031d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80031e:	83 ec 0c             	sub    $0xc,%esp
  800321:	50                   	push   %eax
  800322:	6a 0c                	push   $0xc
  800324:	68 4a 10 80 00       	push   $0x80104a
  800329:	6a 23                	push   $0x23
  80032b:	68 67 10 80 00       	push   $0x801067
  800330:	e8 00 00 00 00       	call   800335 <_panic>

00800335 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800335:	f3 0f 1e fb          	endbr32 
  800339:	55                   	push   %ebp
  80033a:	89 e5                	mov    %esp,%ebp
  80033c:	56                   	push   %esi
  80033d:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80033e:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800341:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800347:	e8 d8 fd ff ff       	call   800124 <sys_getenvid>
  80034c:	83 ec 0c             	sub    $0xc,%esp
  80034f:	ff 75 0c             	pushl  0xc(%ebp)
  800352:	ff 75 08             	pushl  0x8(%ebp)
  800355:	56                   	push   %esi
  800356:	50                   	push   %eax
  800357:	68 78 10 80 00       	push   $0x801078
  80035c:	e8 bb 00 00 00       	call   80041c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800361:	83 c4 18             	add    $0x18,%esp
  800364:	53                   	push   %ebx
  800365:	ff 75 10             	pushl  0x10(%ebp)
  800368:	e8 5a 00 00 00       	call   8003c7 <vcprintf>
	cprintf("\n");
  80036d:	c7 04 24 9b 10 80 00 	movl   $0x80109b,(%esp)
  800374:	e8 a3 00 00 00       	call   80041c <cprintf>
  800379:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80037c:	cc                   	int3   
  80037d:	eb fd                	jmp    80037c <_panic+0x47>

0080037f <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80037f:	f3 0f 1e fb          	endbr32 
  800383:	55                   	push   %ebp
  800384:	89 e5                	mov    %esp,%ebp
  800386:	53                   	push   %ebx
  800387:	83 ec 04             	sub    $0x4,%esp
  80038a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80038d:	8b 13                	mov    (%ebx),%edx
  80038f:	8d 42 01             	lea    0x1(%edx),%eax
  800392:	89 03                	mov    %eax,(%ebx)
  800394:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800397:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80039b:	3d ff 00 00 00       	cmp    $0xff,%eax
  8003a0:	74 09                	je     8003ab <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8003a2:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8003a6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8003a9:	c9                   	leave  
  8003aa:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8003ab:	83 ec 08             	sub    $0x8,%esp
  8003ae:	68 ff 00 00 00       	push   $0xff
  8003b3:	8d 43 08             	lea    0x8(%ebx),%eax
  8003b6:	50                   	push   %eax
  8003b7:	e8 de fc ff ff       	call   80009a <sys_cputs>
		b->idx = 0;
  8003bc:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8003c2:	83 c4 10             	add    $0x10,%esp
  8003c5:	eb db                	jmp    8003a2 <putch+0x23>

008003c7 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8003c7:	f3 0f 1e fb          	endbr32 
  8003cb:	55                   	push   %ebp
  8003cc:	89 e5                	mov    %esp,%ebp
  8003ce:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8003d4:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003db:	00 00 00 
	b.cnt = 0;
  8003de:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003e5:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003e8:	ff 75 0c             	pushl  0xc(%ebp)
  8003eb:	ff 75 08             	pushl  0x8(%ebp)
  8003ee:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003f4:	50                   	push   %eax
  8003f5:	68 7f 03 80 00       	push   $0x80037f
  8003fa:	e8 20 01 00 00       	call   80051f <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003ff:	83 c4 08             	add    $0x8,%esp
  800402:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800408:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80040e:	50                   	push   %eax
  80040f:	e8 86 fc ff ff       	call   80009a <sys_cputs>

	return b.cnt;
}
  800414:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80041a:	c9                   	leave  
  80041b:	c3                   	ret    

0080041c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80041c:	f3 0f 1e fb          	endbr32 
  800420:	55                   	push   %ebp
  800421:	89 e5                	mov    %esp,%ebp
  800423:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800426:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800429:	50                   	push   %eax
  80042a:	ff 75 08             	pushl  0x8(%ebp)
  80042d:	e8 95 ff ff ff       	call   8003c7 <vcprintf>
	va_end(ap);

	return cnt;
}
  800432:	c9                   	leave  
  800433:	c3                   	ret    

00800434 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800434:	55                   	push   %ebp
  800435:	89 e5                	mov    %esp,%ebp
  800437:	57                   	push   %edi
  800438:	56                   	push   %esi
  800439:	53                   	push   %ebx
  80043a:	83 ec 1c             	sub    $0x1c,%esp
  80043d:	89 c7                	mov    %eax,%edi
  80043f:	89 d6                	mov    %edx,%esi
  800441:	8b 45 08             	mov    0x8(%ebp),%eax
  800444:	8b 55 0c             	mov    0xc(%ebp),%edx
  800447:	89 d1                	mov    %edx,%ecx
  800449:	89 c2                	mov    %eax,%edx
  80044b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80044e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800451:	8b 45 10             	mov    0x10(%ebp),%eax
  800454:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800457:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80045a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800461:	39 c2                	cmp    %eax,%edx
  800463:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800466:	72 3e                	jb     8004a6 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800468:	83 ec 0c             	sub    $0xc,%esp
  80046b:	ff 75 18             	pushl  0x18(%ebp)
  80046e:	83 eb 01             	sub    $0x1,%ebx
  800471:	53                   	push   %ebx
  800472:	50                   	push   %eax
  800473:	83 ec 08             	sub    $0x8,%esp
  800476:	ff 75 e4             	pushl  -0x1c(%ebp)
  800479:	ff 75 e0             	pushl  -0x20(%ebp)
  80047c:	ff 75 dc             	pushl  -0x24(%ebp)
  80047f:	ff 75 d8             	pushl  -0x28(%ebp)
  800482:	e8 59 09 00 00       	call   800de0 <__udivdi3>
  800487:	83 c4 18             	add    $0x18,%esp
  80048a:	52                   	push   %edx
  80048b:	50                   	push   %eax
  80048c:	89 f2                	mov    %esi,%edx
  80048e:	89 f8                	mov    %edi,%eax
  800490:	e8 9f ff ff ff       	call   800434 <printnum>
  800495:	83 c4 20             	add    $0x20,%esp
  800498:	eb 13                	jmp    8004ad <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80049a:	83 ec 08             	sub    $0x8,%esp
  80049d:	56                   	push   %esi
  80049e:	ff 75 18             	pushl  0x18(%ebp)
  8004a1:	ff d7                	call   *%edi
  8004a3:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8004a6:	83 eb 01             	sub    $0x1,%ebx
  8004a9:	85 db                	test   %ebx,%ebx
  8004ab:	7f ed                	jg     80049a <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8004ad:	83 ec 08             	sub    $0x8,%esp
  8004b0:	56                   	push   %esi
  8004b1:	83 ec 04             	sub    $0x4,%esp
  8004b4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8004b7:	ff 75 e0             	pushl  -0x20(%ebp)
  8004ba:	ff 75 dc             	pushl  -0x24(%ebp)
  8004bd:	ff 75 d8             	pushl  -0x28(%ebp)
  8004c0:	e8 2b 0a 00 00       	call   800ef0 <__umoddi3>
  8004c5:	83 c4 14             	add    $0x14,%esp
  8004c8:	0f be 80 9d 10 80 00 	movsbl 0x80109d(%eax),%eax
  8004cf:	50                   	push   %eax
  8004d0:	ff d7                	call   *%edi
}
  8004d2:	83 c4 10             	add    $0x10,%esp
  8004d5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004d8:	5b                   	pop    %ebx
  8004d9:	5e                   	pop    %esi
  8004da:	5f                   	pop    %edi
  8004db:	5d                   	pop    %ebp
  8004dc:	c3                   	ret    

008004dd <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004dd:	f3 0f 1e fb          	endbr32 
  8004e1:	55                   	push   %ebp
  8004e2:	89 e5                	mov    %esp,%ebp
  8004e4:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004e7:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004eb:	8b 10                	mov    (%eax),%edx
  8004ed:	3b 50 04             	cmp    0x4(%eax),%edx
  8004f0:	73 0a                	jae    8004fc <sprintputch+0x1f>
		*b->buf++ = ch;
  8004f2:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004f5:	89 08                	mov    %ecx,(%eax)
  8004f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8004fa:	88 02                	mov    %al,(%edx)
}
  8004fc:	5d                   	pop    %ebp
  8004fd:	c3                   	ret    

008004fe <printfmt>:
{
  8004fe:	f3 0f 1e fb          	endbr32 
  800502:	55                   	push   %ebp
  800503:	89 e5                	mov    %esp,%ebp
  800505:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800508:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80050b:	50                   	push   %eax
  80050c:	ff 75 10             	pushl  0x10(%ebp)
  80050f:	ff 75 0c             	pushl  0xc(%ebp)
  800512:	ff 75 08             	pushl  0x8(%ebp)
  800515:	e8 05 00 00 00       	call   80051f <vprintfmt>
}
  80051a:	83 c4 10             	add    $0x10,%esp
  80051d:	c9                   	leave  
  80051e:	c3                   	ret    

0080051f <vprintfmt>:
{
  80051f:	f3 0f 1e fb          	endbr32 
  800523:	55                   	push   %ebp
  800524:	89 e5                	mov    %esp,%ebp
  800526:	57                   	push   %edi
  800527:	56                   	push   %esi
  800528:	53                   	push   %ebx
  800529:	83 ec 3c             	sub    $0x3c,%esp
  80052c:	8b 75 08             	mov    0x8(%ebp),%esi
  80052f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800532:	8b 7d 10             	mov    0x10(%ebp),%edi
  800535:	e9 cd 03 00 00       	jmp    800907 <vprintfmt+0x3e8>
		padc = ' ';
  80053a:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  80053e:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800545:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  80054c:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800553:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800558:	8d 47 01             	lea    0x1(%edi),%eax
  80055b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80055e:	0f b6 17             	movzbl (%edi),%edx
  800561:	8d 42 dd             	lea    -0x23(%edx),%eax
  800564:	3c 55                	cmp    $0x55,%al
  800566:	0f 87 1e 04 00 00    	ja     80098a <vprintfmt+0x46b>
  80056c:	0f b6 c0             	movzbl %al,%eax
  80056f:	3e ff 24 85 60 11 80 	notrack jmp *0x801160(,%eax,4)
  800576:	00 
  800577:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80057a:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  80057e:	eb d8                	jmp    800558 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800580:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800583:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  800587:	eb cf                	jmp    800558 <vprintfmt+0x39>
  800589:	0f b6 d2             	movzbl %dl,%edx
  80058c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  80058f:	b8 00 00 00 00       	mov    $0x0,%eax
  800594:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800597:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80059a:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80059e:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8005a1:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8005a4:	83 f9 09             	cmp    $0x9,%ecx
  8005a7:	77 55                	ja     8005fe <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  8005a9:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8005ac:	eb e9                	jmp    800597 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  8005ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b1:	8b 00                	mov    (%eax),%eax
  8005b3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b9:	8d 40 04             	lea    0x4(%eax),%eax
  8005bc:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8005bf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8005c2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005c6:	79 90                	jns    800558 <vprintfmt+0x39>
				width = precision, precision = -1;
  8005c8:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005cb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005ce:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8005d5:	eb 81                	jmp    800558 <vprintfmt+0x39>
  8005d7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005da:	85 c0                	test   %eax,%eax
  8005dc:	ba 00 00 00 00       	mov    $0x0,%edx
  8005e1:	0f 49 d0             	cmovns %eax,%edx
  8005e4:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8005e7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8005ea:	e9 69 ff ff ff       	jmp    800558 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8005ef:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8005f2:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8005f9:	e9 5a ff ff ff       	jmp    800558 <vprintfmt+0x39>
  8005fe:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800601:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800604:	eb bc                	jmp    8005c2 <vprintfmt+0xa3>
			lflag++;
  800606:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800609:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80060c:	e9 47 ff ff ff       	jmp    800558 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  800611:	8b 45 14             	mov    0x14(%ebp),%eax
  800614:	8d 78 04             	lea    0x4(%eax),%edi
  800617:	83 ec 08             	sub    $0x8,%esp
  80061a:	53                   	push   %ebx
  80061b:	ff 30                	pushl  (%eax)
  80061d:	ff d6                	call   *%esi
			break;
  80061f:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800622:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800625:	e9 da 02 00 00       	jmp    800904 <vprintfmt+0x3e5>
			err = va_arg(ap, int);
  80062a:	8b 45 14             	mov    0x14(%ebp),%eax
  80062d:	8d 78 04             	lea    0x4(%eax),%edi
  800630:	8b 00                	mov    (%eax),%eax
  800632:	99                   	cltd   
  800633:	31 d0                	xor    %edx,%eax
  800635:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800637:	83 f8 08             	cmp    $0x8,%eax
  80063a:	7f 23                	jg     80065f <vprintfmt+0x140>
  80063c:	8b 14 85 c0 12 80 00 	mov    0x8012c0(,%eax,4),%edx
  800643:	85 d2                	test   %edx,%edx
  800645:	74 18                	je     80065f <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  800647:	52                   	push   %edx
  800648:	68 be 10 80 00       	push   $0x8010be
  80064d:	53                   	push   %ebx
  80064e:	56                   	push   %esi
  80064f:	e8 aa fe ff ff       	call   8004fe <printfmt>
  800654:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800657:	89 7d 14             	mov    %edi,0x14(%ebp)
  80065a:	e9 a5 02 00 00       	jmp    800904 <vprintfmt+0x3e5>
				printfmt(putch, putdat, "error %d", err);
  80065f:	50                   	push   %eax
  800660:	68 b5 10 80 00       	push   $0x8010b5
  800665:	53                   	push   %ebx
  800666:	56                   	push   %esi
  800667:	e8 92 fe ff ff       	call   8004fe <printfmt>
  80066c:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80066f:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800672:	e9 8d 02 00 00       	jmp    800904 <vprintfmt+0x3e5>
			if ((p = va_arg(ap, char *)) == NULL)
  800677:	8b 45 14             	mov    0x14(%ebp),%eax
  80067a:	83 c0 04             	add    $0x4,%eax
  80067d:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800680:	8b 45 14             	mov    0x14(%ebp),%eax
  800683:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  800685:	85 d2                	test   %edx,%edx
  800687:	b8 ae 10 80 00       	mov    $0x8010ae,%eax
  80068c:	0f 45 c2             	cmovne %edx,%eax
  80068f:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  800692:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800696:	7e 06                	jle    80069e <vprintfmt+0x17f>
  800698:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  80069c:	75 0d                	jne    8006ab <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  80069e:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8006a1:	89 c7                	mov    %eax,%edi
  8006a3:	03 45 e0             	add    -0x20(%ebp),%eax
  8006a6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006a9:	eb 55                	jmp    800700 <vprintfmt+0x1e1>
  8006ab:	83 ec 08             	sub    $0x8,%esp
  8006ae:	ff 75 d8             	pushl  -0x28(%ebp)
  8006b1:	ff 75 cc             	pushl  -0x34(%ebp)
  8006b4:	e8 85 03 00 00       	call   800a3e <strnlen>
  8006b9:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8006bc:	29 c2                	sub    %eax,%edx
  8006be:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  8006c1:	83 c4 10             	add    $0x10,%esp
  8006c4:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  8006c6:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8006ca:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8006cd:	85 ff                	test   %edi,%edi
  8006cf:	7e 11                	jle    8006e2 <vprintfmt+0x1c3>
					putch(padc, putdat);
  8006d1:	83 ec 08             	sub    $0x8,%esp
  8006d4:	53                   	push   %ebx
  8006d5:	ff 75 e0             	pushl  -0x20(%ebp)
  8006d8:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8006da:	83 ef 01             	sub    $0x1,%edi
  8006dd:	83 c4 10             	add    $0x10,%esp
  8006e0:	eb eb                	jmp    8006cd <vprintfmt+0x1ae>
  8006e2:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8006e5:	85 d2                	test   %edx,%edx
  8006e7:	b8 00 00 00 00       	mov    $0x0,%eax
  8006ec:	0f 49 c2             	cmovns %edx,%eax
  8006ef:	29 c2                	sub    %eax,%edx
  8006f1:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8006f4:	eb a8                	jmp    80069e <vprintfmt+0x17f>
					putch(ch, putdat);
  8006f6:	83 ec 08             	sub    $0x8,%esp
  8006f9:	53                   	push   %ebx
  8006fa:	52                   	push   %edx
  8006fb:	ff d6                	call   *%esi
  8006fd:	83 c4 10             	add    $0x10,%esp
  800700:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800703:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800705:	83 c7 01             	add    $0x1,%edi
  800708:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80070c:	0f be d0             	movsbl %al,%edx
  80070f:	85 d2                	test   %edx,%edx
  800711:	74 4b                	je     80075e <vprintfmt+0x23f>
  800713:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800717:	78 06                	js     80071f <vprintfmt+0x200>
  800719:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  80071d:	78 1e                	js     80073d <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
  80071f:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800723:	74 d1                	je     8006f6 <vprintfmt+0x1d7>
  800725:	0f be c0             	movsbl %al,%eax
  800728:	83 e8 20             	sub    $0x20,%eax
  80072b:	83 f8 5e             	cmp    $0x5e,%eax
  80072e:	76 c6                	jbe    8006f6 <vprintfmt+0x1d7>
					putch('?', putdat);
  800730:	83 ec 08             	sub    $0x8,%esp
  800733:	53                   	push   %ebx
  800734:	6a 3f                	push   $0x3f
  800736:	ff d6                	call   *%esi
  800738:	83 c4 10             	add    $0x10,%esp
  80073b:	eb c3                	jmp    800700 <vprintfmt+0x1e1>
  80073d:	89 cf                	mov    %ecx,%edi
  80073f:	eb 0e                	jmp    80074f <vprintfmt+0x230>
				putch(' ', putdat);
  800741:	83 ec 08             	sub    $0x8,%esp
  800744:	53                   	push   %ebx
  800745:	6a 20                	push   $0x20
  800747:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800749:	83 ef 01             	sub    $0x1,%edi
  80074c:	83 c4 10             	add    $0x10,%esp
  80074f:	85 ff                	test   %edi,%edi
  800751:	7f ee                	jg     800741 <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  800753:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800756:	89 45 14             	mov    %eax,0x14(%ebp)
  800759:	e9 a6 01 00 00       	jmp    800904 <vprintfmt+0x3e5>
  80075e:	89 cf                	mov    %ecx,%edi
  800760:	eb ed                	jmp    80074f <vprintfmt+0x230>
	if (lflag >= 2)
  800762:	83 f9 01             	cmp    $0x1,%ecx
  800765:	7f 1f                	jg     800786 <vprintfmt+0x267>
	else if (lflag)
  800767:	85 c9                	test   %ecx,%ecx
  800769:	74 67                	je     8007d2 <vprintfmt+0x2b3>
		return va_arg(*ap, long);
  80076b:	8b 45 14             	mov    0x14(%ebp),%eax
  80076e:	8b 00                	mov    (%eax),%eax
  800770:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800773:	89 c1                	mov    %eax,%ecx
  800775:	c1 f9 1f             	sar    $0x1f,%ecx
  800778:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80077b:	8b 45 14             	mov    0x14(%ebp),%eax
  80077e:	8d 40 04             	lea    0x4(%eax),%eax
  800781:	89 45 14             	mov    %eax,0x14(%ebp)
  800784:	eb 17                	jmp    80079d <vprintfmt+0x27e>
		return va_arg(*ap, long long);
  800786:	8b 45 14             	mov    0x14(%ebp),%eax
  800789:	8b 50 04             	mov    0x4(%eax),%edx
  80078c:	8b 00                	mov    (%eax),%eax
  80078e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800791:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800794:	8b 45 14             	mov    0x14(%ebp),%eax
  800797:	8d 40 08             	lea    0x8(%eax),%eax
  80079a:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80079d:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007a0:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8007a3:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  8007a8:	85 c9                	test   %ecx,%ecx
  8007aa:	0f 89 3a 01 00 00    	jns    8008ea <vprintfmt+0x3cb>
				putch('-', putdat);
  8007b0:	83 ec 08             	sub    $0x8,%esp
  8007b3:	53                   	push   %ebx
  8007b4:	6a 2d                	push   $0x2d
  8007b6:	ff d6                	call   *%esi
				num = -(long long) num;
  8007b8:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007bb:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8007be:	f7 da                	neg    %edx
  8007c0:	83 d1 00             	adc    $0x0,%ecx
  8007c3:	f7 d9                	neg    %ecx
  8007c5:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8007c8:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007cd:	e9 18 01 00 00       	jmp    8008ea <vprintfmt+0x3cb>
		return va_arg(*ap, int);
  8007d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d5:	8b 00                	mov    (%eax),%eax
  8007d7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007da:	89 c1                	mov    %eax,%ecx
  8007dc:	c1 f9 1f             	sar    $0x1f,%ecx
  8007df:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8007e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e5:	8d 40 04             	lea    0x4(%eax),%eax
  8007e8:	89 45 14             	mov    %eax,0x14(%ebp)
  8007eb:	eb b0                	jmp    80079d <vprintfmt+0x27e>
	if (lflag >= 2)
  8007ed:	83 f9 01             	cmp    $0x1,%ecx
  8007f0:	7f 1e                	jg     800810 <vprintfmt+0x2f1>
	else if (lflag)
  8007f2:	85 c9                	test   %ecx,%ecx
  8007f4:	74 32                	je     800828 <vprintfmt+0x309>
		return va_arg(*ap, unsigned long);
  8007f6:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f9:	8b 10                	mov    (%eax),%edx
  8007fb:	b9 00 00 00 00       	mov    $0x0,%ecx
  800800:	8d 40 04             	lea    0x4(%eax),%eax
  800803:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800806:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  80080b:	e9 da 00 00 00       	jmp    8008ea <vprintfmt+0x3cb>
		return va_arg(*ap, unsigned long long);
  800810:	8b 45 14             	mov    0x14(%ebp),%eax
  800813:	8b 10                	mov    (%eax),%edx
  800815:	8b 48 04             	mov    0x4(%eax),%ecx
  800818:	8d 40 08             	lea    0x8(%eax),%eax
  80081b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80081e:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  800823:	e9 c2 00 00 00       	jmp    8008ea <vprintfmt+0x3cb>
		return va_arg(*ap, unsigned int);
  800828:	8b 45 14             	mov    0x14(%ebp),%eax
  80082b:	8b 10                	mov    (%eax),%edx
  80082d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800832:	8d 40 04             	lea    0x4(%eax),%eax
  800835:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800838:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  80083d:	e9 a8 00 00 00       	jmp    8008ea <vprintfmt+0x3cb>
	if (lflag >= 2)
  800842:	83 f9 01             	cmp    $0x1,%ecx
  800845:	7f 1b                	jg     800862 <vprintfmt+0x343>
	else if (lflag)
  800847:	85 c9                	test   %ecx,%ecx
  800849:	74 5c                	je     8008a7 <vprintfmt+0x388>
		return va_arg(*ap, long);
  80084b:	8b 45 14             	mov    0x14(%ebp),%eax
  80084e:	8b 00                	mov    (%eax),%eax
  800850:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800853:	99                   	cltd   
  800854:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800857:	8b 45 14             	mov    0x14(%ebp),%eax
  80085a:	8d 40 04             	lea    0x4(%eax),%eax
  80085d:	89 45 14             	mov    %eax,0x14(%ebp)
  800860:	eb 17                	jmp    800879 <vprintfmt+0x35a>
		return va_arg(*ap, long long);
  800862:	8b 45 14             	mov    0x14(%ebp),%eax
  800865:	8b 50 04             	mov    0x4(%eax),%edx
  800868:	8b 00                	mov    (%eax),%eax
  80086a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80086d:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800870:	8b 45 14             	mov    0x14(%ebp),%eax
  800873:	8d 40 08             	lea    0x8(%eax),%eax
  800876:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800879:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80087c:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 8;
  80087f:	b8 08 00 00 00       	mov    $0x8,%eax
			if ((long long) num < 0) {
  800884:	85 c9                	test   %ecx,%ecx
  800886:	79 62                	jns    8008ea <vprintfmt+0x3cb>
				putch('-', putdat);
  800888:	83 ec 08             	sub    $0x8,%esp
  80088b:	53                   	push   %ebx
  80088c:	6a 2d                	push   $0x2d
  80088e:	ff d6                	call   *%esi
				num = -(long long) num;
  800890:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800893:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800896:	f7 da                	neg    %edx
  800898:	83 d1 00             	adc    $0x0,%ecx
  80089b:	f7 d9                	neg    %ecx
  80089d:	83 c4 10             	add    $0x10,%esp
			base = 8;
  8008a0:	b8 08 00 00 00       	mov    $0x8,%eax
  8008a5:	eb 43                	jmp    8008ea <vprintfmt+0x3cb>
		return va_arg(*ap, int);
  8008a7:	8b 45 14             	mov    0x14(%ebp),%eax
  8008aa:	8b 00                	mov    (%eax),%eax
  8008ac:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8008af:	89 c1                	mov    %eax,%ecx
  8008b1:	c1 f9 1f             	sar    $0x1f,%ecx
  8008b4:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8008b7:	8b 45 14             	mov    0x14(%ebp),%eax
  8008ba:	8d 40 04             	lea    0x4(%eax),%eax
  8008bd:	89 45 14             	mov    %eax,0x14(%ebp)
  8008c0:	eb b7                	jmp    800879 <vprintfmt+0x35a>
			putch('0', putdat);
  8008c2:	83 ec 08             	sub    $0x8,%esp
  8008c5:	53                   	push   %ebx
  8008c6:	6a 30                	push   $0x30
  8008c8:	ff d6                	call   *%esi
			putch('x', putdat);
  8008ca:	83 c4 08             	add    $0x8,%esp
  8008cd:	53                   	push   %ebx
  8008ce:	6a 78                	push   $0x78
  8008d0:	ff d6                	call   *%esi
			num = (unsigned long long)
  8008d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8008d5:	8b 10                	mov    (%eax),%edx
  8008d7:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8008dc:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8008df:	8d 40 04             	lea    0x4(%eax),%eax
  8008e2:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8008e5:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  8008ea:	83 ec 0c             	sub    $0xc,%esp
  8008ed:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  8008f1:	57                   	push   %edi
  8008f2:	ff 75 e0             	pushl  -0x20(%ebp)
  8008f5:	50                   	push   %eax
  8008f6:	51                   	push   %ecx
  8008f7:	52                   	push   %edx
  8008f8:	89 da                	mov    %ebx,%edx
  8008fa:	89 f0                	mov    %esi,%eax
  8008fc:	e8 33 fb ff ff       	call   800434 <printnum>
			break;
  800901:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  800904:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800907:	83 c7 01             	add    $0x1,%edi
  80090a:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80090e:	83 f8 25             	cmp    $0x25,%eax
  800911:	0f 84 23 fc ff ff    	je     80053a <vprintfmt+0x1b>
			if (ch == '\0')
  800917:	85 c0                	test   %eax,%eax
  800919:	0f 84 8b 00 00 00    	je     8009aa <vprintfmt+0x48b>
			putch(ch, putdat);
  80091f:	83 ec 08             	sub    $0x8,%esp
  800922:	53                   	push   %ebx
  800923:	50                   	push   %eax
  800924:	ff d6                	call   *%esi
  800926:	83 c4 10             	add    $0x10,%esp
  800929:	eb dc                	jmp    800907 <vprintfmt+0x3e8>
	if (lflag >= 2)
  80092b:	83 f9 01             	cmp    $0x1,%ecx
  80092e:	7f 1b                	jg     80094b <vprintfmt+0x42c>
	else if (lflag)
  800930:	85 c9                	test   %ecx,%ecx
  800932:	74 2c                	je     800960 <vprintfmt+0x441>
		return va_arg(*ap, unsigned long);
  800934:	8b 45 14             	mov    0x14(%ebp),%eax
  800937:	8b 10                	mov    (%eax),%edx
  800939:	b9 00 00 00 00       	mov    $0x0,%ecx
  80093e:	8d 40 04             	lea    0x4(%eax),%eax
  800941:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800944:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  800949:	eb 9f                	jmp    8008ea <vprintfmt+0x3cb>
		return va_arg(*ap, unsigned long long);
  80094b:	8b 45 14             	mov    0x14(%ebp),%eax
  80094e:	8b 10                	mov    (%eax),%edx
  800950:	8b 48 04             	mov    0x4(%eax),%ecx
  800953:	8d 40 08             	lea    0x8(%eax),%eax
  800956:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800959:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  80095e:	eb 8a                	jmp    8008ea <vprintfmt+0x3cb>
		return va_arg(*ap, unsigned int);
  800960:	8b 45 14             	mov    0x14(%ebp),%eax
  800963:	8b 10                	mov    (%eax),%edx
  800965:	b9 00 00 00 00       	mov    $0x0,%ecx
  80096a:	8d 40 04             	lea    0x4(%eax),%eax
  80096d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800970:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  800975:	e9 70 ff ff ff       	jmp    8008ea <vprintfmt+0x3cb>
			putch(ch, putdat);
  80097a:	83 ec 08             	sub    $0x8,%esp
  80097d:	53                   	push   %ebx
  80097e:	6a 25                	push   $0x25
  800980:	ff d6                	call   *%esi
			break;
  800982:	83 c4 10             	add    $0x10,%esp
  800985:	e9 7a ff ff ff       	jmp    800904 <vprintfmt+0x3e5>
			putch('%', putdat);
  80098a:	83 ec 08             	sub    $0x8,%esp
  80098d:	53                   	push   %ebx
  80098e:	6a 25                	push   $0x25
  800990:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800992:	83 c4 10             	add    $0x10,%esp
  800995:	89 f8                	mov    %edi,%eax
  800997:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80099b:	74 05                	je     8009a2 <vprintfmt+0x483>
  80099d:	83 e8 01             	sub    $0x1,%eax
  8009a0:	eb f5                	jmp    800997 <vprintfmt+0x478>
  8009a2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8009a5:	e9 5a ff ff ff       	jmp    800904 <vprintfmt+0x3e5>
}
  8009aa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8009ad:	5b                   	pop    %ebx
  8009ae:	5e                   	pop    %esi
  8009af:	5f                   	pop    %edi
  8009b0:	5d                   	pop    %ebp
  8009b1:	c3                   	ret    

008009b2 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8009b2:	f3 0f 1e fb          	endbr32 
  8009b6:	55                   	push   %ebp
  8009b7:	89 e5                	mov    %esp,%ebp
  8009b9:	83 ec 18             	sub    $0x18,%esp
  8009bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8009bf:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8009c2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8009c5:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8009c9:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8009cc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8009d3:	85 c0                	test   %eax,%eax
  8009d5:	74 26                	je     8009fd <vsnprintf+0x4b>
  8009d7:	85 d2                	test   %edx,%edx
  8009d9:	7e 22                	jle    8009fd <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8009db:	ff 75 14             	pushl  0x14(%ebp)
  8009de:	ff 75 10             	pushl  0x10(%ebp)
  8009e1:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8009e4:	50                   	push   %eax
  8009e5:	68 dd 04 80 00       	push   $0x8004dd
  8009ea:	e8 30 fb ff ff       	call   80051f <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8009ef:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8009f2:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8009f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009f8:	83 c4 10             	add    $0x10,%esp
}
  8009fb:	c9                   	leave  
  8009fc:	c3                   	ret    
		return -E_INVAL;
  8009fd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800a02:	eb f7                	jmp    8009fb <vsnprintf+0x49>

00800a04 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800a04:	f3 0f 1e fb          	endbr32 
  800a08:	55                   	push   %ebp
  800a09:	89 e5                	mov    %esp,%ebp
  800a0b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800a0e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800a11:	50                   	push   %eax
  800a12:	ff 75 10             	pushl  0x10(%ebp)
  800a15:	ff 75 0c             	pushl  0xc(%ebp)
  800a18:	ff 75 08             	pushl  0x8(%ebp)
  800a1b:	e8 92 ff ff ff       	call   8009b2 <vsnprintf>
	va_end(ap);

	return rc;
}
  800a20:	c9                   	leave  
  800a21:	c3                   	ret    

00800a22 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800a22:	f3 0f 1e fb          	endbr32 
  800a26:	55                   	push   %ebp
  800a27:	89 e5                	mov    %esp,%ebp
  800a29:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a2c:	b8 00 00 00 00       	mov    $0x0,%eax
  800a31:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a35:	74 05                	je     800a3c <strlen+0x1a>
		n++;
  800a37:	83 c0 01             	add    $0x1,%eax
  800a3a:	eb f5                	jmp    800a31 <strlen+0xf>
	return n;
}
  800a3c:	5d                   	pop    %ebp
  800a3d:	c3                   	ret    

00800a3e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a3e:	f3 0f 1e fb          	endbr32 
  800a42:	55                   	push   %ebp
  800a43:	89 e5                	mov    %esp,%ebp
  800a45:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a48:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a4b:	b8 00 00 00 00       	mov    $0x0,%eax
  800a50:	39 d0                	cmp    %edx,%eax
  800a52:	74 0d                	je     800a61 <strnlen+0x23>
  800a54:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800a58:	74 05                	je     800a5f <strnlen+0x21>
		n++;
  800a5a:	83 c0 01             	add    $0x1,%eax
  800a5d:	eb f1                	jmp    800a50 <strnlen+0x12>
  800a5f:	89 c2                	mov    %eax,%edx
	return n;
}
  800a61:	89 d0                	mov    %edx,%eax
  800a63:	5d                   	pop    %ebp
  800a64:	c3                   	ret    

00800a65 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a65:	f3 0f 1e fb          	endbr32 
  800a69:	55                   	push   %ebp
  800a6a:	89 e5                	mov    %esp,%ebp
  800a6c:	53                   	push   %ebx
  800a6d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a70:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a73:	b8 00 00 00 00       	mov    $0x0,%eax
  800a78:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800a7c:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800a7f:	83 c0 01             	add    $0x1,%eax
  800a82:	84 d2                	test   %dl,%dl
  800a84:	75 f2                	jne    800a78 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  800a86:	89 c8                	mov    %ecx,%eax
  800a88:	5b                   	pop    %ebx
  800a89:	5d                   	pop    %ebp
  800a8a:	c3                   	ret    

00800a8b <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a8b:	f3 0f 1e fb          	endbr32 
  800a8f:	55                   	push   %ebp
  800a90:	89 e5                	mov    %esp,%ebp
  800a92:	53                   	push   %ebx
  800a93:	83 ec 10             	sub    $0x10,%esp
  800a96:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a99:	53                   	push   %ebx
  800a9a:	e8 83 ff ff ff       	call   800a22 <strlen>
  800a9f:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800aa2:	ff 75 0c             	pushl  0xc(%ebp)
  800aa5:	01 d8                	add    %ebx,%eax
  800aa7:	50                   	push   %eax
  800aa8:	e8 b8 ff ff ff       	call   800a65 <strcpy>
	return dst;
}
  800aad:	89 d8                	mov    %ebx,%eax
  800aaf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ab2:	c9                   	leave  
  800ab3:	c3                   	ret    

00800ab4 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800ab4:	f3 0f 1e fb          	endbr32 
  800ab8:	55                   	push   %ebp
  800ab9:	89 e5                	mov    %esp,%ebp
  800abb:	56                   	push   %esi
  800abc:	53                   	push   %ebx
  800abd:	8b 75 08             	mov    0x8(%ebp),%esi
  800ac0:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ac3:	89 f3                	mov    %esi,%ebx
  800ac5:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800ac8:	89 f0                	mov    %esi,%eax
  800aca:	39 d8                	cmp    %ebx,%eax
  800acc:	74 11                	je     800adf <strncpy+0x2b>
		*dst++ = *src;
  800ace:	83 c0 01             	add    $0x1,%eax
  800ad1:	0f b6 0a             	movzbl (%edx),%ecx
  800ad4:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800ad7:	80 f9 01             	cmp    $0x1,%cl
  800ada:	83 da ff             	sbb    $0xffffffff,%edx
  800add:	eb eb                	jmp    800aca <strncpy+0x16>
	}
	return ret;
}
  800adf:	89 f0                	mov    %esi,%eax
  800ae1:	5b                   	pop    %ebx
  800ae2:	5e                   	pop    %esi
  800ae3:	5d                   	pop    %ebp
  800ae4:	c3                   	ret    

00800ae5 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800ae5:	f3 0f 1e fb          	endbr32 
  800ae9:	55                   	push   %ebp
  800aea:	89 e5                	mov    %esp,%ebp
  800aec:	56                   	push   %esi
  800aed:	53                   	push   %ebx
  800aee:	8b 75 08             	mov    0x8(%ebp),%esi
  800af1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800af4:	8b 55 10             	mov    0x10(%ebp),%edx
  800af7:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800af9:	85 d2                	test   %edx,%edx
  800afb:	74 21                	je     800b1e <strlcpy+0x39>
  800afd:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800b01:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  800b03:	39 c2                	cmp    %eax,%edx
  800b05:	74 14                	je     800b1b <strlcpy+0x36>
  800b07:	0f b6 19             	movzbl (%ecx),%ebx
  800b0a:	84 db                	test   %bl,%bl
  800b0c:	74 0b                	je     800b19 <strlcpy+0x34>
			*dst++ = *src++;
  800b0e:	83 c1 01             	add    $0x1,%ecx
  800b11:	83 c2 01             	add    $0x1,%edx
  800b14:	88 5a ff             	mov    %bl,-0x1(%edx)
  800b17:	eb ea                	jmp    800b03 <strlcpy+0x1e>
  800b19:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800b1b:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800b1e:	29 f0                	sub    %esi,%eax
}
  800b20:	5b                   	pop    %ebx
  800b21:	5e                   	pop    %esi
  800b22:	5d                   	pop    %ebp
  800b23:	c3                   	ret    

00800b24 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800b24:	f3 0f 1e fb          	endbr32 
  800b28:	55                   	push   %ebp
  800b29:	89 e5                	mov    %esp,%ebp
  800b2b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b2e:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800b31:	0f b6 01             	movzbl (%ecx),%eax
  800b34:	84 c0                	test   %al,%al
  800b36:	74 0c                	je     800b44 <strcmp+0x20>
  800b38:	3a 02                	cmp    (%edx),%al
  800b3a:	75 08                	jne    800b44 <strcmp+0x20>
		p++, q++;
  800b3c:	83 c1 01             	add    $0x1,%ecx
  800b3f:	83 c2 01             	add    $0x1,%edx
  800b42:	eb ed                	jmp    800b31 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800b44:	0f b6 c0             	movzbl %al,%eax
  800b47:	0f b6 12             	movzbl (%edx),%edx
  800b4a:	29 d0                	sub    %edx,%eax
}
  800b4c:	5d                   	pop    %ebp
  800b4d:	c3                   	ret    

00800b4e <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b4e:	f3 0f 1e fb          	endbr32 
  800b52:	55                   	push   %ebp
  800b53:	89 e5                	mov    %esp,%ebp
  800b55:	53                   	push   %ebx
  800b56:	8b 45 08             	mov    0x8(%ebp),%eax
  800b59:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b5c:	89 c3                	mov    %eax,%ebx
  800b5e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800b61:	eb 06                	jmp    800b69 <strncmp+0x1b>
		n--, p++, q++;
  800b63:	83 c0 01             	add    $0x1,%eax
  800b66:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800b69:	39 d8                	cmp    %ebx,%eax
  800b6b:	74 16                	je     800b83 <strncmp+0x35>
  800b6d:	0f b6 08             	movzbl (%eax),%ecx
  800b70:	84 c9                	test   %cl,%cl
  800b72:	74 04                	je     800b78 <strncmp+0x2a>
  800b74:	3a 0a                	cmp    (%edx),%cl
  800b76:	74 eb                	je     800b63 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b78:	0f b6 00             	movzbl (%eax),%eax
  800b7b:	0f b6 12             	movzbl (%edx),%edx
  800b7e:	29 d0                	sub    %edx,%eax
}
  800b80:	5b                   	pop    %ebx
  800b81:	5d                   	pop    %ebp
  800b82:	c3                   	ret    
		return 0;
  800b83:	b8 00 00 00 00       	mov    $0x0,%eax
  800b88:	eb f6                	jmp    800b80 <strncmp+0x32>

00800b8a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b8a:	f3 0f 1e fb          	endbr32 
  800b8e:	55                   	push   %ebp
  800b8f:	89 e5                	mov    %esp,%ebp
  800b91:	8b 45 08             	mov    0x8(%ebp),%eax
  800b94:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b98:	0f b6 10             	movzbl (%eax),%edx
  800b9b:	84 d2                	test   %dl,%dl
  800b9d:	74 09                	je     800ba8 <strchr+0x1e>
		if (*s == c)
  800b9f:	38 ca                	cmp    %cl,%dl
  800ba1:	74 0a                	je     800bad <strchr+0x23>
	for (; *s; s++)
  800ba3:	83 c0 01             	add    $0x1,%eax
  800ba6:	eb f0                	jmp    800b98 <strchr+0xe>
			return (char *) s;
	return 0;
  800ba8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bad:	5d                   	pop    %ebp
  800bae:	c3                   	ret    

00800baf <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800baf:	f3 0f 1e fb          	endbr32 
  800bb3:	55                   	push   %ebp
  800bb4:	89 e5                	mov    %esp,%ebp
  800bb6:	8b 45 08             	mov    0x8(%ebp),%eax
  800bb9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800bbd:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800bc0:	38 ca                	cmp    %cl,%dl
  800bc2:	74 09                	je     800bcd <strfind+0x1e>
  800bc4:	84 d2                	test   %dl,%dl
  800bc6:	74 05                	je     800bcd <strfind+0x1e>
	for (; *s; s++)
  800bc8:	83 c0 01             	add    $0x1,%eax
  800bcb:	eb f0                	jmp    800bbd <strfind+0xe>
			break;
	return (char *) s;
}
  800bcd:	5d                   	pop    %ebp
  800bce:	c3                   	ret    

00800bcf <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800bcf:	f3 0f 1e fb          	endbr32 
  800bd3:	55                   	push   %ebp
  800bd4:	89 e5                	mov    %esp,%ebp
  800bd6:	57                   	push   %edi
  800bd7:	56                   	push   %esi
  800bd8:	53                   	push   %ebx
  800bd9:	8b 7d 08             	mov    0x8(%ebp),%edi
  800bdc:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800bdf:	85 c9                	test   %ecx,%ecx
  800be1:	74 31                	je     800c14 <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800be3:	89 f8                	mov    %edi,%eax
  800be5:	09 c8                	or     %ecx,%eax
  800be7:	a8 03                	test   $0x3,%al
  800be9:	75 23                	jne    800c0e <memset+0x3f>
		c &= 0xFF;
  800beb:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800bef:	89 d3                	mov    %edx,%ebx
  800bf1:	c1 e3 08             	shl    $0x8,%ebx
  800bf4:	89 d0                	mov    %edx,%eax
  800bf6:	c1 e0 18             	shl    $0x18,%eax
  800bf9:	89 d6                	mov    %edx,%esi
  800bfb:	c1 e6 10             	shl    $0x10,%esi
  800bfe:	09 f0                	or     %esi,%eax
  800c00:	09 c2                	or     %eax,%edx
  800c02:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800c04:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800c07:	89 d0                	mov    %edx,%eax
  800c09:	fc                   	cld    
  800c0a:	f3 ab                	rep stos %eax,%es:(%edi)
  800c0c:	eb 06                	jmp    800c14 <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800c0e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c11:	fc                   	cld    
  800c12:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800c14:	89 f8                	mov    %edi,%eax
  800c16:	5b                   	pop    %ebx
  800c17:	5e                   	pop    %esi
  800c18:	5f                   	pop    %edi
  800c19:	5d                   	pop    %ebp
  800c1a:	c3                   	ret    

00800c1b <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800c1b:	f3 0f 1e fb          	endbr32 
  800c1f:	55                   	push   %ebp
  800c20:	89 e5                	mov    %esp,%ebp
  800c22:	57                   	push   %edi
  800c23:	56                   	push   %esi
  800c24:	8b 45 08             	mov    0x8(%ebp),%eax
  800c27:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c2a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800c2d:	39 c6                	cmp    %eax,%esi
  800c2f:	73 32                	jae    800c63 <memmove+0x48>
  800c31:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c34:	39 c2                	cmp    %eax,%edx
  800c36:	76 2b                	jbe    800c63 <memmove+0x48>
		s += n;
		d += n;
  800c38:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c3b:	89 fe                	mov    %edi,%esi
  800c3d:	09 ce                	or     %ecx,%esi
  800c3f:	09 d6                	or     %edx,%esi
  800c41:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c47:	75 0e                	jne    800c57 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800c49:	83 ef 04             	sub    $0x4,%edi
  800c4c:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c4f:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800c52:	fd                   	std    
  800c53:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c55:	eb 09                	jmp    800c60 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800c57:	83 ef 01             	sub    $0x1,%edi
  800c5a:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800c5d:	fd                   	std    
  800c5e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c60:	fc                   	cld    
  800c61:	eb 1a                	jmp    800c7d <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c63:	89 c2                	mov    %eax,%edx
  800c65:	09 ca                	or     %ecx,%edx
  800c67:	09 f2                	or     %esi,%edx
  800c69:	f6 c2 03             	test   $0x3,%dl
  800c6c:	75 0a                	jne    800c78 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800c6e:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800c71:	89 c7                	mov    %eax,%edi
  800c73:	fc                   	cld    
  800c74:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c76:	eb 05                	jmp    800c7d <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800c78:	89 c7                	mov    %eax,%edi
  800c7a:	fc                   	cld    
  800c7b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c7d:	5e                   	pop    %esi
  800c7e:	5f                   	pop    %edi
  800c7f:	5d                   	pop    %ebp
  800c80:	c3                   	ret    

00800c81 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c81:	f3 0f 1e fb          	endbr32 
  800c85:	55                   	push   %ebp
  800c86:	89 e5                	mov    %esp,%ebp
  800c88:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800c8b:	ff 75 10             	pushl  0x10(%ebp)
  800c8e:	ff 75 0c             	pushl  0xc(%ebp)
  800c91:	ff 75 08             	pushl  0x8(%ebp)
  800c94:	e8 82 ff ff ff       	call   800c1b <memmove>
}
  800c99:	c9                   	leave  
  800c9a:	c3                   	ret    

00800c9b <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c9b:	f3 0f 1e fb          	endbr32 
  800c9f:	55                   	push   %ebp
  800ca0:	89 e5                	mov    %esp,%ebp
  800ca2:	56                   	push   %esi
  800ca3:	53                   	push   %ebx
  800ca4:	8b 45 08             	mov    0x8(%ebp),%eax
  800ca7:	8b 55 0c             	mov    0xc(%ebp),%edx
  800caa:	89 c6                	mov    %eax,%esi
  800cac:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800caf:	39 f0                	cmp    %esi,%eax
  800cb1:	74 1c                	je     800ccf <memcmp+0x34>
		if (*s1 != *s2)
  800cb3:	0f b6 08             	movzbl (%eax),%ecx
  800cb6:	0f b6 1a             	movzbl (%edx),%ebx
  800cb9:	38 d9                	cmp    %bl,%cl
  800cbb:	75 08                	jne    800cc5 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800cbd:	83 c0 01             	add    $0x1,%eax
  800cc0:	83 c2 01             	add    $0x1,%edx
  800cc3:	eb ea                	jmp    800caf <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800cc5:	0f b6 c1             	movzbl %cl,%eax
  800cc8:	0f b6 db             	movzbl %bl,%ebx
  800ccb:	29 d8                	sub    %ebx,%eax
  800ccd:	eb 05                	jmp    800cd4 <memcmp+0x39>
	}

	return 0;
  800ccf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800cd4:	5b                   	pop    %ebx
  800cd5:	5e                   	pop    %esi
  800cd6:	5d                   	pop    %ebp
  800cd7:	c3                   	ret    

00800cd8 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800cd8:	f3 0f 1e fb          	endbr32 
  800cdc:	55                   	push   %ebp
  800cdd:	89 e5                	mov    %esp,%ebp
  800cdf:	8b 45 08             	mov    0x8(%ebp),%eax
  800ce2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800ce5:	89 c2                	mov    %eax,%edx
  800ce7:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800cea:	39 d0                	cmp    %edx,%eax
  800cec:	73 09                	jae    800cf7 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800cee:	38 08                	cmp    %cl,(%eax)
  800cf0:	74 05                	je     800cf7 <memfind+0x1f>
	for (; s < ends; s++)
  800cf2:	83 c0 01             	add    $0x1,%eax
  800cf5:	eb f3                	jmp    800cea <memfind+0x12>
			break;
	return (void *) s;
}
  800cf7:	5d                   	pop    %ebp
  800cf8:	c3                   	ret    

00800cf9 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800cf9:	f3 0f 1e fb          	endbr32 
  800cfd:	55                   	push   %ebp
  800cfe:	89 e5                	mov    %esp,%ebp
  800d00:	57                   	push   %edi
  800d01:	56                   	push   %esi
  800d02:	53                   	push   %ebx
  800d03:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d06:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d09:	eb 03                	jmp    800d0e <strtol+0x15>
		s++;
  800d0b:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800d0e:	0f b6 01             	movzbl (%ecx),%eax
  800d11:	3c 20                	cmp    $0x20,%al
  800d13:	74 f6                	je     800d0b <strtol+0x12>
  800d15:	3c 09                	cmp    $0x9,%al
  800d17:	74 f2                	je     800d0b <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800d19:	3c 2b                	cmp    $0x2b,%al
  800d1b:	74 2a                	je     800d47 <strtol+0x4e>
	int neg = 0;
  800d1d:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800d22:	3c 2d                	cmp    $0x2d,%al
  800d24:	74 2b                	je     800d51 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d26:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800d2c:	75 0f                	jne    800d3d <strtol+0x44>
  800d2e:	80 39 30             	cmpb   $0x30,(%ecx)
  800d31:	74 28                	je     800d5b <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800d33:	85 db                	test   %ebx,%ebx
  800d35:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d3a:	0f 44 d8             	cmove  %eax,%ebx
  800d3d:	b8 00 00 00 00       	mov    $0x0,%eax
  800d42:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800d45:	eb 46                	jmp    800d8d <strtol+0x94>
		s++;
  800d47:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800d4a:	bf 00 00 00 00       	mov    $0x0,%edi
  800d4f:	eb d5                	jmp    800d26 <strtol+0x2d>
		s++, neg = 1;
  800d51:	83 c1 01             	add    $0x1,%ecx
  800d54:	bf 01 00 00 00       	mov    $0x1,%edi
  800d59:	eb cb                	jmp    800d26 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d5b:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800d5f:	74 0e                	je     800d6f <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800d61:	85 db                	test   %ebx,%ebx
  800d63:	75 d8                	jne    800d3d <strtol+0x44>
		s++, base = 8;
  800d65:	83 c1 01             	add    $0x1,%ecx
  800d68:	bb 08 00 00 00       	mov    $0x8,%ebx
  800d6d:	eb ce                	jmp    800d3d <strtol+0x44>
		s += 2, base = 16;
  800d6f:	83 c1 02             	add    $0x2,%ecx
  800d72:	bb 10 00 00 00       	mov    $0x10,%ebx
  800d77:	eb c4                	jmp    800d3d <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800d79:	0f be d2             	movsbl %dl,%edx
  800d7c:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800d7f:	3b 55 10             	cmp    0x10(%ebp),%edx
  800d82:	7d 3a                	jge    800dbe <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800d84:	83 c1 01             	add    $0x1,%ecx
  800d87:	0f af 45 10          	imul   0x10(%ebp),%eax
  800d8b:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800d8d:	0f b6 11             	movzbl (%ecx),%edx
  800d90:	8d 72 d0             	lea    -0x30(%edx),%esi
  800d93:	89 f3                	mov    %esi,%ebx
  800d95:	80 fb 09             	cmp    $0x9,%bl
  800d98:	76 df                	jbe    800d79 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800d9a:	8d 72 9f             	lea    -0x61(%edx),%esi
  800d9d:	89 f3                	mov    %esi,%ebx
  800d9f:	80 fb 19             	cmp    $0x19,%bl
  800da2:	77 08                	ja     800dac <strtol+0xb3>
			dig = *s - 'a' + 10;
  800da4:	0f be d2             	movsbl %dl,%edx
  800da7:	83 ea 57             	sub    $0x57,%edx
  800daa:	eb d3                	jmp    800d7f <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800dac:	8d 72 bf             	lea    -0x41(%edx),%esi
  800daf:	89 f3                	mov    %esi,%ebx
  800db1:	80 fb 19             	cmp    $0x19,%bl
  800db4:	77 08                	ja     800dbe <strtol+0xc5>
			dig = *s - 'A' + 10;
  800db6:	0f be d2             	movsbl %dl,%edx
  800db9:	83 ea 37             	sub    $0x37,%edx
  800dbc:	eb c1                	jmp    800d7f <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800dbe:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800dc2:	74 05                	je     800dc9 <strtol+0xd0>
		*endptr = (char *) s;
  800dc4:	8b 75 0c             	mov    0xc(%ebp),%esi
  800dc7:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800dc9:	89 c2                	mov    %eax,%edx
  800dcb:	f7 da                	neg    %edx
  800dcd:	85 ff                	test   %edi,%edi
  800dcf:	0f 45 c2             	cmovne %edx,%eax
}
  800dd2:	5b                   	pop    %ebx
  800dd3:	5e                   	pop    %esi
  800dd4:	5f                   	pop    %edi
  800dd5:	5d                   	pop    %ebp
  800dd6:	c3                   	ret    
  800dd7:	66 90                	xchg   %ax,%ax
  800dd9:	66 90                	xchg   %ax,%ax
  800ddb:	66 90                	xchg   %ax,%ax
  800ddd:	66 90                	xchg   %ax,%ax
  800ddf:	90                   	nop

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
