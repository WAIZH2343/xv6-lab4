
obj/user/badsegment:     file format elf32-i386


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
  80002c:	e8 0d 00 00 00       	call   80003e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	f3 0f 1e fb          	endbr32 
	// Try to load the kernel's TSS selector into the DS register.
	asm volatile("movw $0x28,%ax; movw %ax,%ds");
  800037:	66 b8 28 00          	mov    $0x28,%ax
  80003b:	8e d8                	mov    %eax,%ds
}
  80003d:	c3                   	ret    

0080003e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80003e:	f3 0f 1e fb          	endbr32 
  800042:	55                   	push   %ebp
  800043:	89 e5                	mov    %esp,%ebp
  800045:	56                   	push   %esi
  800046:	53                   	push   %ebx
  800047:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80004a:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv=&envs[ENVX(sys_getenvid())];
  80004d:	e8 d6 00 00 00       	call   800128 <sys_getenvid>
  800052:	25 ff 03 00 00       	and    $0x3ff,%eax
  800057:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80005a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80005f:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800064:	85 db                	test   %ebx,%ebx
  800066:	7e 07                	jle    80006f <libmain+0x31>
		binaryname = argv[0];
  800068:	8b 06                	mov    (%esi),%eax
  80006a:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80006f:	83 ec 08             	sub    $0x8,%esp
  800072:	56                   	push   %esi
  800073:	53                   	push   %ebx
  800074:	e8 ba ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800079:	e8 0a 00 00 00       	call   800088 <exit>
}
  80007e:	83 c4 10             	add    $0x10,%esp
  800081:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800084:	5b                   	pop    %ebx
  800085:	5e                   	pop    %esi
  800086:	5d                   	pop    %ebp
  800087:	c3                   	ret    

00800088 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800088:	f3 0f 1e fb          	endbr32 
  80008c:	55                   	push   %ebp
  80008d:	89 e5                	mov    %esp,%ebp
  80008f:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800092:	6a 00                	push   $0x0
  800094:	e8 4a 00 00 00       	call   8000e3 <sys_env_destroy>
}
  800099:	83 c4 10             	add    $0x10,%esp
  80009c:	c9                   	leave  
  80009d:	c3                   	ret    

0080009e <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  80009e:	f3 0f 1e fb          	endbr32 
  8000a2:	55                   	push   %ebp
  8000a3:	89 e5                	mov    %esp,%ebp
  8000a5:	57                   	push   %edi
  8000a6:	56                   	push   %esi
  8000a7:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000a8:	b8 00 00 00 00       	mov    $0x0,%eax
  8000ad:	8b 55 08             	mov    0x8(%ebp),%edx
  8000b0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000b3:	89 c3                	mov    %eax,%ebx
  8000b5:	89 c7                	mov    %eax,%edi
  8000b7:	89 c6                	mov    %eax,%esi
  8000b9:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000bb:	5b                   	pop    %ebx
  8000bc:	5e                   	pop    %esi
  8000bd:	5f                   	pop    %edi
  8000be:	5d                   	pop    %ebp
  8000bf:	c3                   	ret    

008000c0 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000c0:	f3 0f 1e fb          	endbr32 
  8000c4:	55                   	push   %ebp
  8000c5:	89 e5                	mov    %esp,%ebp
  8000c7:	57                   	push   %edi
  8000c8:	56                   	push   %esi
  8000c9:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000ca:	ba 00 00 00 00       	mov    $0x0,%edx
  8000cf:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d4:	89 d1                	mov    %edx,%ecx
  8000d6:	89 d3                	mov    %edx,%ebx
  8000d8:	89 d7                	mov    %edx,%edi
  8000da:	89 d6                	mov    %edx,%esi
  8000dc:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000de:	5b                   	pop    %ebx
  8000df:	5e                   	pop    %esi
  8000e0:	5f                   	pop    %edi
  8000e1:	5d                   	pop    %ebp
  8000e2:	c3                   	ret    

008000e3 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000e3:	f3 0f 1e fb          	endbr32 
  8000e7:	55                   	push   %ebp
  8000e8:	89 e5                	mov    %esp,%ebp
  8000ea:	57                   	push   %edi
  8000eb:	56                   	push   %esi
  8000ec:	53                   	push   %ebx
  8000ed:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8000f0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000f5:	8b 55 08             	mov    0x8(%ebp),%edx
  8000f8:	b8 03 00 00 00       	mov    $0x3,%eax
  8000fd:	89 cb                	mov    %ecx,%ebx
  8000ff:	89 cf                	mov    %ecx,%edi
  800101:	89 ce                	mov    %ecx,%esi
  800103:	cd 30                	int    $0x30
	if(check && ret > 0)
  800105:	85 c0                	test   %eax,%eax
  800107:	7f 08                	jg     800111 <sys_env_destroy+0x2e>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800109:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80010c:	5b                   	pop    %ebx
  80010d:	5e                   	pop    %esi
  80010e:	5f                   	pop    %edi
  80010f:	5d                   	pop    %ebp
  800110:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800111:	83 ec 0c             	sub    $0xc,%esp
  800114:	50                   	push   %eax
  800115:	6a 03                	push   $0x3
  800117:	68 4a 10 80 00       	push   $0x80104a
  80011c:	6a 23                	push   $0x23
  80011e:	68 67 10 80 00       	push   $0x801067
  800123:	e8 11 02 00 00       	call   800339 <_panic>

00800128 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800128:	f3 0f 1e fb          	endbr32 
  80012c:	55                   	push   %ebp
  80012d:	89 e5                	mov    %esp,%ebp
  80012f:	57                   	push   %edi
  800130:	56                   	push   %esi
  800131:	53                   	push   %ebx
	asm volatile("int %1\n"
  800132:	ba 00 00 00 00       	mov    $0x0,%edx
  800137:	b8 02 00 00 00       	mov    $0x2,%eax
  80013c:	89 d1                	mov    %edx,%ecx
  80013e:	89 d3                	mov    %edx,%ebx
  800140:	89 d7                	mov    %edx,%edi
  800142:	89 d6                	mov    %edx,%esi
  800144:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800146:	5b                   	pop    %ebx
  800147:	5e                   	pop    %esi
  800148:	5f                   	pop    %edi
  800149:	5d                   	pop    %ebp
  80014a:	c3                   	ret    

0080014b <sys_yield>:

void
sys_yield(void)
{
  80014b:	f3 0f 1e fb          	endbr32 
  80014f:	55                   	push   %ebp
  800150:	89 e5                	mov    %esp,%ebp
  800152:	57                   	push   %edi
  800153:	56                   	push   %esi
  800154:	53                   	push   %ebx
	asm volatile("int %1\n"
  800155:	ba 00 00 00 00       	mov    $0x0,%edx
  80015a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80015f:	89 d1                	mov    %edx,%ecx
  800161:	89 d3                	mov    %edx,%ebx
  800163:	89 d7                	mov    %edx,%edi
  800165:	89 d6                	mov    %edx,%esi
  800167:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800169:	5b                   	pop    %ebx
  80016a:	5e                   	pop    %esi
  80016b:	5f                   	pop    %edi
  80016c:	5d                   	pop    %ebp
  80016d:	c3                   	ret    

0080016e <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80016e:	f3 0f 1e fb          	endbr32 
  800172:	55                   	push   %ebp
  800173:	89 e5                	mov    %esp,%ebp
  800175:	57                   	push   %edi
  800176:	56                   	push   %esi
  800177:	53                   	push   %ebx
  800178:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80017b:	be 00 00 00 00       	mov    $0x0,%esi
  800180:	8b 55 08             	mov    0x8(%ebp),%edx
  800183:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800186:	b8 04 00 00 00       	mov    $0x4,%eax
  80018b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80018e:	89 f7                	mov    %esi,%edi
  800190:	cd 30                	int    $0x30
	if(check && ret > 0)
  800192:	85 c0                	test   %eax,%eax
  800194:	7f 08                	jg     80019e <sys_page_alloc+0x30>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800196:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800199:	5b                   	pop    %ebx
  80019a:	5e                   	pop    %esi
  80019b:	5f                   	pop    %edi
  80019c:	5d                   	pop    %ebp
  80019d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80019e:	83 ec 0c             	sub    $0xc,%esp
  8001a1:	50                   	push   %eax
  8001a2:	6a 04                	push   $0x4
  8001a4:	68 4a 10 80 00       	push   $0x80104a
  8001a9:	6a 23                	push   $0x23
  8001ab:	68 67 10 80 00       	push   $0x801067
  8001b0:	e8 84 01 00 00       	call   800339 <_panic>

008001b5 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001b5:	f3 0f 1e fb          	endbr32 
  8001b9:	55                   	push   %ebp
  8001ba:	89 e5                	mov    %esp,%ebp
  8001bc:	57                   	push   %edi
  8001bd:	56                   	push   %esi
  8001be:	53                   	push   %ebx
  8001bf:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001c2:	8b 55 08             	mov    0x8(%ebp),%edx
  8001c5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001c8:	b8 05 00 00 00       	mov    $0x5,%eax
  8001cd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001d0:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001d3:	8b 75 18             	mov    0x18(%ebp),%esi
  8001d6:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001d8:	85 c0                	test   %eax,%eax
  8001da:	7f 08                	jg     8001e4 <sys_page_map+0x2f>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001dc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001df:	5b                   	pop    %ebx
  8001e0:	5e                   	pop    %esi
  8001e1:	5f                   	pop    %edi
  8001e2:	5d                   	pop    %ebp
  8001e3:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8001e4:	83 ec 0c             	sub    $0xc,%esp
  8001e7:	50                   	push   %eax
  8001e8:	6a 05                	push   $0x5
  8001ea:	68 4a 10 80 00       	push   $0x80104a
  8001ef:	6a 23                	push   $0x23
  8001f1:	68 67 10 80 00       	push   $0x801067
  8001f6:	e8 3e 01 00 00       	call   800339 <_panic>

008001fb <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001fb:	f3 0f 1e fb          	endbr32 
  8001ff:	55                   	push   %ebp
  800200:	89 e5                	mov    %esp,%ebp
  800202:	57                   	push   %edi
  800203:	56                   	push   %esi
  800204:	53                   	push   %ebx
  800205:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800208:	bb 00 00 00 00       	mov    $0x0,%ebx
  80020d:	8b 55 08             	mov    0x8(%ebp),%edx
  800210:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800213:	b8 06 00 00 00       	mov    $0x6,%eax
  800218:	89 df                	mov    %ebx,%edi
  80021a:	89 de                	mov    %ebx,%esi
  80021c:	cd 30                	int    $0x30
	if(check && ret > 0)
  80021e:	85 c0                	test   %eax,%eax
  800220:	7f 08                	jg     80022a <sys_page_unmap+0x2f>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800222:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800225:	5b                   	pop    %ebx
  800226:	5e                   	pop    %esi
  800227:	5f                   	pop    %edi
  800228:	5d                   	pop    %ebp
  800229:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80022a:	83 ec 0c             	sub    $0xc,%esp
  80022d:	50                   	push   %eax
  80022e:	6a 06                	push   $0x6
  800230:	68 4a 10 80 00       	push   $0x80104a
  800235:	6a 23                	push   $0x23
  800237:	68 67 10 80 00       	push   $0x801067
  80023c:	e8 f8 00 00 00       	call   800339 <_panic>

00800241 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800241:	f3 0f 1e fb          	endbr32 
  800245:	55                   	push   %ebp
  800246:	89 e5                	mov    %esp,%ebp
  800248:	57                   	push   %edi
  800249:	56                   	push   %esi
  80024a:	53                   	push   %ebx
  80024b:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80024e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800253:	8b 55 08             	mov    0x8(%ebp),%edx
  800256:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800259:	b8 08 00 00 00       	mov    $0x8,%eax
  80025e:	89 df                	mov    %ebx,%edi
  800260:	89 de                	mov    %ebx,%esi
  800262:	cd 30                	int    $0x30
	if(check && ret > 0)
  800264:	85 c0                	test   %eax,%eax
  800266:	7f 08                	jg     800270 <sys_env_set_status+0x2f>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800268:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80026b:	5b                   	pop    %ebx
  80026c:	5e                   	pop    %esi
  80026d:	5f                   	pop    %edi
  80026e:	5d                   	pop    %ebp
  80026f:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800270:	83 ec 0c             	sub    $0xc,%esp
  800273:	50                   	push   %eax
  800274:	6a 08                	push   $0x8
  800276:	68 4a 10 80 00       	push   $0x80104a
  80027b:	6a 23                	push   $0x23
  80027d:	68 67 10 80 00       	push   $0x801067
  800282:	e8 b2 00 00 00       	call   800339 <_panic>

00800287 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800287:	f3 0f 1e fb          	endbr32 
  80028b:	55                   	push   %ebp
  80028c:	89 e5                	mov    %esp,%ebp
  80028e:	57                   	push   %edi
  80028f:	56                   	push   %esi
  800290:	53                   	push   %ebx
  800291:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800294:	bb 00 00 00 00       	mov    $0x0,%ebx
  800299:	8b 55 08             	mov    0x8(%ebp),%edx
  80029c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80029f:	b8 09 00 00 00       	mov    $0x9,%eax
  8002a4:	89 df                	mov    %ebx,%edi
  8002a6:	89 de                	mov    %ebx,%esi
  8002a8:	cd 30                	int    $0x30
	if(check && ret > 0)
  8002aa:	85 c0                	test   %eax,%eax
  8002ac:	7f 08                	jg     8002b6 <sys_env_set_pgfault_upcall+0x2f>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002ae:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002b1:	5b                   	pop    %ebx
  8002b2:	5e                   	pop    %esi
  8002b3:	5f                   	pop    %edi
  8002b4:	5d                   	pop    %ebp
  8002b5:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8002b6:	83 ec 0c             	sub    $0xc,%esp
  8002b9:	50                   	push   %eax
  8002ba:	6a 09                	push   $0x9
  8002bc:	68 4a 10 80 00       	push   $0x80104a
  8002c1:	6a 23                	push   $0x23
  8002c3:	68 67 10 80 00       	push   $0x801067
  8002c8:	e8 6c 00 00 00       	call   800339 <_panic>

008002cd <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002cd:	f3 0f 1e fb          	endbr32 
  8002d1:	55                   	push   %ebp
  8002d2:	89 e5                	mov    %esp,%ebp
  8002d4:	57                   	push   %edi
  8002d5:	56                   	push   %esi
  8002d6:	53                   	push   %ebx
	asm volatile("int %1\n"
  8002d7:	8b 55 08             	mov    0x8(%ebp),%edx
  8002da:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002dd:	b8 0b 00 00 00       	mov    $0xb,%eax
  8002e2:	be 00 00 00 00       	mov    $0x0,%esi
  8002e7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002ea:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002ed:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8002ef:	5b                   	pop    %ebx
  8002f0:	5e                   	pop    %esi
  8002f1:	5f                   	pop    %edi
  8002f2:	5d                   	pop    %ebp
  8002f3:	c3                   	ret    

008002f4 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8002f4:	f3 0f 1e fb          	endbr32 
  8002f8:	55                   	push   %ebp
  8002f9:	89 e5                	mov    %esp,%ebp
  8002fb:	57                   	push   %edi
  8002fc:	56                   	push   %esi
  8002fd:	53                   	push   %ebx
  8002fe:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800301:	b9 00 00 00 00       	mov    $0x0,%ecx
  800306:	8b 55 08             	mov    0x8(%ebp),%edx
  800309:	b8 0c 00 00 00       	mov    $0xc,%eax
  80030e:	89 cb                	mov    %ecx,%ebx
  800310:	89 cf                	mov    %ecx,%edi
  800312:	89 ce                	mov    %ecx,%esi
  800314:	cd 30                	int    $0x30
	if(check && ret > 0)
  800316:	85 c0                	test   %eax,%eax
  800318:	7f 08                	jg     800322 <sys_ipc_recv+0x2e>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80031a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80031d:	5b                   	pop    %ebx
  80031e:	5e                   	pop    %esi
  80031f:	5f                   	pop    %edi
  800320:	5d                   	pop    %ebp
  800321:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800322:	83 ec 0c             	sub    $0xc,%esp
  800325:	50                   	push   %eax
  800326:	6a 0c                	push   $0xc
  800328:	68 4a 10 80 00       	push   $0x80104a
  80032d:	6a 23                	push   $0x23
  80032f:	68 67 10 80 00       	push   $0x801067
  800334:	e8 00 00 00 00       	call   800339 <_panic>

00800339 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800339:	f3 0f 1e fb          	endbr32 
  80033d:	55                   	push   %ebp
  80033e:	89 e5                	mov    %esp,%ebp
  800340:	56                   	push   %esi
  800341:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800342:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800345:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80034b:	e8 d8 fd ff ff       	call   800128 <sys_getenvid>
  800350:	83 ec 0c             	sub    $0xc,%esp
  800353:	ff 75 0c             	pushl  0xc(%ebp)
  800356:	ff 75 08             	pushl  0x8(%ebp)
  800359:	56                   	push   %esi
  80035a:	50                   	push   %eax
  80035b:	68 78 10 80 00       	push   $0x801078
  800360:	e8 bb 00 00 00       	call   800420 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800365:	83 c4 18             	add    $0x18,%esp
  800368:	53                   	push   %ebx
  800369:	ff 75 10             	pushl  0x10(%ebp)
  80036c:	e8 5a 00 00 00       	call   8003cb <vcprintf>
	cprintf("\n");
  800371:	c7 04 24 9b 10 80 00 	movl   $0x80109b,(%esp)
  800378:	e8 a3 00 00 00       	call   800420 <cprintf>
  80037d:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800380:	cc                   	int3   
  800381:	eb fd                	jmp    800380 <_panic+0x47>

00800383 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800383:	f3 0f 1e fb          	endbr32 
  800387:	55                   	push   %ebp
  800388:	89 e5                	mov    %esp,%ebp
  80038a:	53                   	push   %ebx
  80038b:	83 ec 04             	sub    $0x4,%esp
  80038e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800391:	8b 13                	mov    (%ebx),%edx
  800393:	8d 42 01             	lea    0x1(%edx),%eax
  800396:	89 03                	mov    %eax,(%ebx)
  800398:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80039b:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80039f:	3d ff 00 00 00       	cmp    $0xff,%eax
  8003a4:	74 09                	je     8003af <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8003a6:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8003aa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8003ad:	c9                   	leave  
  8003ae:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8003af:	83 ec 08             	sub    $0x8,%esp
  8003b2:	68 ff 00 00 00       	push   $0xff
  8003b7:	8d 43 08             	lea    0x8(%ebx),%eax
  8003ba:	50                   	push   %eax
  8003bb:	e8 de fc ff ff       	call   80009e <sys_cputs>
		b->idx = 0;
  8003c0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8003c6:	83 c4 10             	add    $0x10,%esp
  8003c9:	eb db                	jmp    8003a6 <putch+0x23>

008003cb <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8003cb:	f3 0f 1e fb          	endbr32 
  8003cf:	55                   	push   %ebp
  8003d0:	89 e5                	mov    %esp,%ebp
  8003d2:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8003d8:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003df:	00 00 00 
	b.cnt = 0;
  8003e2:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003e9:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003ec:	ff 75 0c             	pushl  0xc(%ebp)
  8003ef:	ff 75 08             	pushl  0x8(%ebp)
  8003f2:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003f8:	50                   	push   %eax
  8003f9:	68 83 03 80 00       	push   $0x800383
  8003fe:	e8 20 01 00 00       	call   800523 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800403:	83 c4 08             	add    $0x8,%esp
  800406:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80040c:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800412:	50                   	push   %eax
  800413:	e8 86 fc ff ff       	call   80009e <sys_cputs>

	return b.cnt;
}
  800418:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80041e:	c9                   	leave  
  80041f:	c3                   	ret    

00800420 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800420:	f3 0f 1e fb          	endbr32 
  800424:	55                   	push   %ebp
  800425:	89 e5                	mov    %esp,%ebp
  800427:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80042a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80042d:	50                   	push   %eax
  80042e:	ff 75 08             	pushl  0x8(%ebp)
  800431:	e8 95 ff ff ff       	call   8003cb <vcprintf>
	va_end(ap);

	return cnt;
}
  800436:	c9                   	leave  
  800437:	c3                   	ret    

00800438 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800438:	55                   	push   %ebp
  800439:	89 e5                	mov    %esp,%ebp
  80043b:	57                   	push   %edi
  80043c:	56                   	push   %esi
  80043d:	53                   	push   %ebx
  80043e:	83 ec 1c             	sub    $0x1c,%esp
  800441:	89 c7                	mov    %eax,%edi
  800443:	89 d6                	mov    %edx,%esi
  800445:	8b 45 08             	mov    0x8(%ebp),%eax
  800448:	8b 55 0c             	mov    0xc(%ebp),%edx
  80044b:	89 d1                	mov    %edx,%ecx
  80044d:	89 c2                	mov    %eax,%edx
  80044f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800452:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800455:	8b 45 10             	mov    0x10(%ebp),%eax
  800458:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80045b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80045e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800465:	39 c2                	cmp    %eax,%edx
  800467:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  80046a:	72 3e                	jb     8004aa <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80046c:	83 ec 0c             	sub    $0xc,%esp
  80046f:	ff 75 18             	pushl  0x18(%ebp)
  800472:	83 eb 01             	sub    $0x1,%ebx
  800475:	53                   	push   %ebx
  800476:	50                   	push   %eax
  800477:	83 ec 08             	sub    $0x8,%esp
  80047a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80047d:	ff 75 e0             	pushl  -0x20(%ebp)
  800480:	ff 75 dc             	pushl  -0x24(%ebp)
  800483:	ff 75 d8             	pushl  -0x28(%ebp)
  800486:	e8 55 09 00 00       	call   800de0 <__udivdi3>
  80048b:	83 c4 18             	add    $0x18,%esp
  80048e:	52                   	push   %edx
  80048f:	50                   	push   %eax
  800490:	89 f2                	mov    %esi,%edx
  800492:	89 f8                	mov    %edi,%eax
  800494:	e8 9f ff ff ff       	call   800438 <printnum>
  800499:	83 c4 20             	add    $0x20,%esp
  80049c:	eb 13                	jmp    8004b1 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80049e:	83 ec 08             	sub    $0x8,%esp
  8004a1:	56                   	push   %esi
  8004a2:	ff 75 18             	pushl  0x18(%ebp)
  8004a5:	ff d7                	call   *%edi
  8004a7:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8004aa:	83 eb 01             	sub    $0x1,%ebx
  8004ad:	85 db                	test   %ebx,%ebx
  8004af:	7f ed                	jg     80049e <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8004b1:	83 ec 08             	sub    $0x8,%esp
  8004b4:	56                   	push   %esi
  8004b5:	83 ec 04             	sub    $0x4,%esp
  8004b8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8004bb:	ff 75 e0             	pushl  -0x20(%ebp)
  8004be:	ff 75 dc             	pushl  -0x24(%ebp)
  8004c1:	ff 75 d8             	pushl  -0x28(%ebp)
  8004c4:	e8 27 0a 00 00       	call   800ef0 <__umoddi3>
  8004c9:	83 c4 14             	add    $0x14,%esp
  8004cc:	0f be 80 9d 10 80 00 	movsbl 0x80109d(%eax),%eax
  8004d3:	50                   	push   %eax
  8004d4:	ff d7                	call   *%edi
}
  8004d6:	83 c4 10             	add    $0x10,%esp
  8004d9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004dc:	5b                   	pop    %ebx
  8004dd:	5e                   	pop    %esi
  8004de:	5f                   	pop    %edi
  8004df:	5d                   	pop    %ebp
  8004e0:	c3                   	ret    

008004e1 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004e1:	f3 0f 1e fb          	endbr32 
  8004e5:	55                   	push   %ebp
  8004e6:	89 e5                	mov    %esp,%ebp
  8004e8:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004eb:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004ef:	8b 10                	mov    (%eax),%edx
  8004f1:	3b 50 04             	cmp    0x4(%eax),%edx
  8004f4:	73 0a                	jae    800500 <sprintputch+0x1f>
		*b->buf++ = ch;
  8004f6:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004f9:	89 08                	mov    %ecx,(%eax)
  8004fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8004fe:	88 02                	mov    %al,(%edx)
}
  800500:	5d                   	pop    %ebp
  800501:	c3                   	ret    

00800502 <printfmt>:
{
  800502:	f3 0f 1e fb          	endbr32 
  800506:	55                   	push   %ebp
  800507:	89 e5                	mov    %esp,%ebp
  800509:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80050c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80050f:	50                   	push   %eax
  800510:	ff 75 10             	pushl  0x10(%ebp)
  800513:	ff 75 0c             	pushl  0xc(%ebp)
  800516:	ff 75 08             	pushl  0x8(%ebp)
  800519:	e8 05 00 00 00       	call   800523 <vprintfmt>
}
  80051e:	83 c4 10             	add    $0x10,%esp
  800521:	c9                   	leave  
  800522:	c3                   	ret    

00800523 <vprintfmt>:
{
  800523:	f3 0f 1e fb          	endbr32 
  800527:	55                   	push   %ebp
  800528:	89 e5                	mov    %esp,%ebp
  80052a:	57                   	push   %edi
  80052b:	56                   	push   %esi
  80052c:	53                   	push   %ebx
  80052d:	83 ec 3c             	sub    $0x3c,%esp
  800530:	8b 75 08             	mov    0x8(%ebp),%esi
  800533:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800536:	8b 7d 10             	mov    0x10(%ebp),%edi
  800539:	e9 cd 03 00 00       	jmp    80090b <vprintfmt+0x3e8>
		padc = ' ';
  80053e:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800542:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800549:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800550:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800557:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80055c:	8d 47 01             	lea    0x1(%edi),%eax
  80055f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800562:	0f b6 17             	movzbl (%edi),%edx
  800565:	8d 42 dd             	lea    -0x23(%edx),%eax
  800568:	3c 55                	cmp    $0x55,%al
  80056a:	0f 87 1e 04 00 00    	ja     80098e <vprintfmt+0x46b>
  800570:	0f b6 c0             	movzbl %al,%eax
  800573:	3e ff 24 85 60 11 80 	notrack jmp *0x801160(,%eax,4)
  80057a:	00 
  80057b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80057e:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800582:	eb d8                	jmp    80055c <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800584:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800587:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  80058b:	eb cf                	jmp    80055c <vprintfmt+0x39>
  80058d:	0f b6 d2             	movzbl %dl,%edx
  800590:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800593:	b8 00 00 00 00       	mov    $0x0,%eax
  800598:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  80059b:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80059e:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8005a2:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8005a5:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8005a8:	83 f9 09             	cmp    $0x9,%ecx
  8005ab:	77 55                	ja     800602 <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  8005ad:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8005b0:	eb e9                	jmp    80059b <vprintfmt+0x78>
			precision = va_arg(ap, int);
  8005b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b5:	8b 00                	mov    (%eax),%eax
  8005b7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8005bd:	8d 40 04             	lea    0x4(%eax),%eax
  8005c0:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8005c3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8005c6:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005ca:	79 90                	jns    80055c <vprintfmt+0x39>
				width = precision, precision = -1;
  8005cc:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005cf:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005d2:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8005d9:	eb 81                	jmp    80055c <vprintfmt+0x39>
  8005db:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005de:	85 c0                	test   %eax,%eax
  8005e0:	ba 00 00 00 00       	mov    $0x0,%edx
  8005e5:	0f 49 d0             	cmovns %eax,%edx
  8005e8:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8005eb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8005ee:	e9 69 ff ff ff       	jmp    80055c <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8005f3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8005f6:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8005fd:	e9 5a ff ff ff       	jmp    80055c <vprintfmt+0x39>
  800602:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800605:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800608:	eb bc                	jmp    8005c6 <vprintfmt+0xa3>
			lflag++;
  80060a:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80060d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800610:	e9 47 ff ff ff       	jmp    80055c <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  800615:	8b 45 14             	mov    0x14(%ebp),%eax
  800618:	8d 78 04             	lea    0x4(%eax),%edi
  80061b:	83 ec 08             	sub    $0x8,%esp
  80061e:	53                   	push   %ebx
  80061f:	ff 30                	pushl  (%eax)
  800621:	ff d6                	call   *%esi
			break;
  800623:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800626:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800629:	e9 da 02 00 00       	jmp    800908 <vprintfmt+0x3e5>
			err = va_arg(ap, int);
  80062e:	8b 45 14             	mov    0x14(%ebp),%eax
  800631:	8d 78 04             	lea    0x4(%eax),%edi
  800634:	8b 00                	mov    (%eax),%eax
  800636:	99                   	cltd   
  800637:	31 d0                	xor    %edx,%eax
  800639:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80063b:	83 f8 08             	cmp    $0x8,%eax
  80063e:	7f 23                	jg     800663 <vprintfmt+0x140>
  800640:	8b 14 85 c0 12 80 00 	mov    0x8012c0(,%eax,4),%edx
  800647:	85 d2                	test   %edx,%edx
  800649:	74 18                	je     800663 <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  80064b:	52                   	push   %edx
  80064c:	68 be 10 80 00       	push   $0x8010be
  800651:	53                   	push   %ebx
  800652:	56                   	push   %esi
  800653:	e8 aa fe ff ff       	call   800502 <printfmt>
  800658:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80065b:	89 7d 14             	mov    %edi,0x14(%ebp)
  80065e:	e9 a5 02 00 00       	jmp    800908 <vprintfmt+0x3e5>
				printfmt(putch, putdat, "error %d", err);
  800663:	50                   	push   %eax
  800664:	68 b5 10 80 00       	push   $0x8010b5
  800669:	53                   	push   %ebx
  80066a:	56                   	push   %esi
  80066b:	e8 92 fe ff ff       	call   800502 <printfmt>
  800670:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800673:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800676:	e9 8d 02 00 00       	jmp    800908 <vprintfmt+0x3e5>
			if ((p = va_arg(ap, char *)) == NULL)
  80067b:	8b 45 14             	mov    0x14(%ebp),%eax
  80067e:	83 c0 04             	add    $0x4,%eax
  800681:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800684:	8b 45 14             	mov    0x14(%ebp),%eax
  800687:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  800689:	85 d2                	test   %edx,%edx
  80068b:	b8 ae 10 80 00       	mov    $0x8010ae,%eax
  800690:	0f 45 c2             	cmovne %edx,%eax
  800693:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  800696:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80069a:	7e 06                	jle    8006a2 <vprintfmt+0x17f>
  80069c:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  8006a0:	75 0d                	jne    8006af <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006a2:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8006a5:	89 c7                	mov    %eax,%edi
  8006a7:	03 45 e0             	add    -0x20(%ebp),%eax
  8006aa:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006ad:	eb 55                	jmp    800704 <vprintfmt+0x1e1>
  8006af:	83 ec 08             	sub    $0x8,%esp
  8006b2:	ff 75 d8             	pushl  -0x28(%ebp)
  8006b5:	ff 75 cc             	pushl  -0x34(%ebp)
  8006b8:	e8 85 03 00 00       	call   800a42 <strnlen>
  8006bd:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8006c0:	29 c2                	sub    %eax,%edx
  8006c2:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  8006c5:	83 c4 10             	add    $0x10,%esp
  8006c8:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  8006ca:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8006ce:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8006d1:	85 ff                	test   %edi,%edi
  8006d3:	7e 11                	jle    8006e6 <vprintfmt+0x1c3>
					putch(padc, putdat);
  8006d5:	83 ec 08             	sub    $0x8,%esp
  8006d8:	53                   	push   %ebx
  8006d9:	ff 75 e0             	pushl  -0x20(%ebp)
  8006dc:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8006de:	83 ef 01             	sub    $0x1,%edi
  8006e1:	83 c4 10             	add    $0x10,%esp
  8006e4:	eb eb                	jmp    8006d1 <vprintfmt+0x1ae>
  8006e6:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8006e9:	85 d2                	test   %edx,%edx
  8006eb:	b8 00 00 00 00       	mov    $0x0,%eax
  8006f0:	0f 49 c2             	cmovns %edx,%eax
  8006f3:	29 c2                	sub    %eax,%edx
  8006f5:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8006f8:	eb a8                	jmp    8006a2 <vprintfmt+0x17f>
					putch(ch, putdat);
  8006fa:	83 ec 08             	sub    $0x8,%esp
  8006fd:	53                   	push   %ebx
  8006fe:	52                   	push   %edx
  8006ff:	ff d6                	call   *%esi
  800701:	83 c4 10             	add    $0x10,%esp
  800704:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800707:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800709:	83 c7 01             	add    $0x1,%edi
  80070c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800710:	0f be d0             	movsbl %al,%edx
  800713:	85 d2                	test   %edx,%edx
  800715:	74 4b                	je     800762 <vprintfmt+0x23f>
  800717:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80071b:	78 06                	js     800723 <vprintfmt+0x200>
  80071d:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800721:	78 1e                	js     800741 <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
  800723:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800727:	74 d1                	je     8006fa <vprintfmt+0x1d7>
  800729:	0f be c0             	movsbl %al,%eax
  80072c:	83 e8 20             	sub    $0x20,%eax
  80072f:	83 f8 5e             	cmp    $0x5e,%eax
  800732:	76 c6                	jbe    8006fa <vprintfmt+0x1d7>
					putch('?', putdat);
  800734:	83 ec 08             	sub    $0x8,%esp
  800737:	53                   	push   %ebx
  800738:	6a 3f                	push   $0x3f
  80073a:	ff d6                	call   *%esi
  80073c:	83 c4 10             	add    $0x10,%esp
  80073f:	eb c3                	jmp    800704 <vprintfmt+0x1e1>
  800741:	89 cf                	mov    %ecx,%edi
  800743:	eb 0e                	jmp    800753 <vprintfmt+0x230>
				putch(' ', putdat);
  800745:	83 ec 08             	sub    $0x8,%esp
  800748:	53                   	push   %ebx
  800749:	6a 20                	push   $0x20
  80074b:	ff d6                	call   *%esi
			for (; width > 0; width--)
  80074d:	83 ef 01             	sub    $0x1,%edi
  800750:	83 c4 10             	add    $0x10,%esp
  800753:	85 ff                	test   %edi,%edi
  800755:	7f ee                	jg     800745 <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  800757:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80075a:	89 45 14             	mov    %eax,0x14(%ebp)
  80075d:	e9 a6 01 00 00       	jmp    800908 <vprintfmt+0x3e5>
  800762:	89 cf                	mov    %ecx,%edi
  800764:	eb ed                	jmp    800753 <vprintfmt+0x230>
	if (lflag >= 2)
  800766:	83 f9 01             	cmp    $0x1,%ecx
  800769:	7f 1f                	jg     80078a <vprintfmt+0x267>
	else if (lflag)
  80076b:	85 c9                	test   %ecx,%ecx
  80076d:	74 67                	je     8007d6 <vprintfmt+0x2b3>
		return va_arg(*ap, long);
  80076f:	8b 45 14             	mov    0x14(%ebp),%eax
  800772:	8b 00                	mov    (%eax),%eax
  800774:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800777:	89 c1                	mov    %eax,%ecx
  800779:	c1 f9 1f             	sar    $0x1f,%ecx
  80077c:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80077f:	8b 45 14             	mov    0x14(%ebp),%eax
  800782:	8d 40 04             	lea    0x4(%eax),%eax
  800785:	89 45 14             	mov    %eax,0x14(%ebp)
  800788:	eb 17                	jmp    8007a1 <vprintfmt+0x27e>
		return va_arg(*ap, long long);
  80078a:	8b 45 14             	mov    0x14(%ebp),%eax
  80078d:	8b 50 04             	mov    0x4(%eax),%edx
  800790:	8b 00                	mov    (%eax),%eax
  800792:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800795:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800798:	8b 45 14             	mov    0x14(%ebp),%eax
  80079b:	8d 40 08             	lea    0x8(%eax),%eax
  80079e:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8007a1:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007a4:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8007a7:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  8007ac:	85 c9                	test   %ecx,%ecx
  8007ae:	0f 89 3a 01 00 00    	jns    8008ee <vprintfmt+0x3cb>
				putch('-', putdat);
  8007b4:	83 ec 08             	sub    $0x8,%esp
  8007b7:	53                   	push   %ebx
  8007b8:	6a 2d                	push   $0x2d
  8007ba:	ff d6                	call   *%esi
				num = -(long long) num;
  8007bc:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007bf:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8007c2:	f7 da                	neg    %edx
  8007c4:	83 d1 00             	adc    $0x0,%ecx
  8007c7:	f7 d9                	neg    %ecx
  8007c9:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8007cc:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007d1:	e9 18 01 00 00       	jmp    8008ee <vprintfmt+0x3cb>
		return va_arg(*ap, int);
  8007d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d9:	8b 00                	mov    (%eax),%eax
  8007db:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007de:	89 c1                	mov    %eax,%ecx
  8007e0:	c1 f9 1f             	sar    $0x1f,%ecx
  8007e3:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8007e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e9:	8d 40 04             	lea    0x4(%eax),%eax
  8007ec:	89 45 14             	mov    %eax,0x14(%ebp)
  8007ef:	eb b0                	jmp    8007a1 <vprintfmt+0x27e>
	if (lflag >= 2)
  8007f1:	83 f9 01             	cmp    $0x1,%ecx
  8007f4:	7f 1e                	jg     800814 <vprintfmt+0x2f1>
	else if (lflag)
  8007f6:	85 c9                	test   %ecx,%ecx
  8007f8:	74 32                	je     80082c <vprintfmt+0x309>
		return va_arg(*ap, unsigned long);
  8007fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8007fd:	8b 10                	mov    (%eax),%edx
  8007ff:	b9 00 00 00 00       	mov    $0x0,%ecx
  800804:	8d 40 04             	lea    0x4(%eax),%eax
  800807:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80080a:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  80080f:	e9 da 00 00 00       	jmp    8008ee <vprintfmt+0x3cb>
		return va_arg(*ap, unsigned long long);
  800814:	8b 45 14             	mov    0x14(%ebp),%eax
  800817:	8b 10                	mov    (%eax),%edx
  800819:	8b 48 04             	mov    0x4(%eax),%ecx
  80081c:	8d 40 08             	lea    0x8(%eax),%eax
  80081f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800822:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  800827:	e9 c2 00 00 00       	jmp    8008ee <vprintfmt+0x3cb>
		return va_arg(*ap, unsigned int);
  80082c:	8b 45 14             	mov    0x14(%ebp),%eax
  80082f:	8b 10                	mov    (%eax),%edx
  800831:	b9 00 00 00 00       	mov    $0x0,%ecx
  800836:	8d 40 04             	lea    0x4(%eax),%eax
  800839:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80083c:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  800841:	e9 a8 00 00 00       	jmp    8008ee <vprintfmt+0x3cb>
	if (lflag >= 2)
  800846:	83 f9 01             	cmp    $0x1,%ecx
  800849:	7f 1b                	jg     800866 <vprintfmt+0x343>
	else if (lflag)
  80084b:	85 c9                	test   %ecx,%ecx
  80084d:	74 5c                	je     8008ab <vprintfmt+0x388>
		return va_arg(*ap, long);
  80084f:	8b 45 14             	mov    0x14(%ebp),%eax
  800852:	8b 00                	mov    (%eax),%eax
  800854:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800857:	99                   	cltd   
  800858:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80085b:	8b 45 14             	mov    0x14(%ebp),%eax
  80085e:	8d 40 04             	lea    0x4(%eax),%eax
  800861:	89 45 14             	mov    %eax,0x14(%ebp)
  800864:	eb 17                	jmp    80087d <vprintfmt+0x35a>
		return va_arg(*ap, long long);
  800866:	8b 45 14             	mov    0x14(%ebp),%eax
  800869:	8b 50 04             	mov    0x4(%eax),%edx
  80086c:	8b 00                	mov    (%eax),%eax
  80086e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800871:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800874:	8b 45 14             	mov    0x14(%ebp),%eax
  800877:	8d 40 08             	lea    0x8(%eax),%eax
  80087a:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80087d:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800880:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 8;
  800883:	b8 08 00 00 00       	mov    $0x8,%eax
			if ((long long) num < 0) {
  800888:	85 c9                	test   %ecx,%ecx
  80088a:	79 62                	jns    8008ee <vprintfmt+0x3cb>
				putch('-', putdat);
  80088c:	83 ec 08             	sub    $0x8,%esp
  80088f:	53                   	push   %ebx
  800890:	6a 2d                	push   $0x2d
  800892:	ff d6                	call   *%esi
				num = -(long long) num;
  800894:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800897:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80089a:	f7 da                	neg    %edx
  80089c:	83 d1 00             	adc    $0x0,%ecx
  80089f:	f7 d9                	neg    %ecx
  8008a1:	83 c4 10             	add    $0x10,%esp
			base = 8;
  8008a4:	b8 08 00 00 00       	mov    $0x8,%eax
  8008a9:	eb 43                	jmp    8008ee <vprintfmt+0x3cb>
		return va_arg(*ap, int);
  8008ab:	8b 45 14             	mov    0x14(%ebp),%eax
  8008ae:	8b 00                	mov    (%eax),%eax
  8008b0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8008b3:	89 c1                	mov    %eax,%ecx
  8008b5:	c1 f9 1f             	sar    $0x1f,%ecx
  8008b8:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8008bb:	8b 45 14             	mov    0x14(%ebp),%eax
  8008be:	8d 40 04             	lea    0x4(%eax),%eax
  8008c1:	89 45 14             	mov    %eax,0x14(%ebp)
  8008c4:	eb b7                	jmp    80087d <vprintfmt+0x35a>
			putch('0', putdat);
  8008c6:	83 ec 08             	sub    $0x8,%esp
  8008c9:	53                   	push   %ebx
  8008ca:	6a 30                	push   $0x30
  8008cc:	ff d6                	call   *%esi
			putch('x', putdat);
  8008ce:	83 c4 08             	add    $0x8,%esp
  8008d1:	53                   	push   %ebx
  8008d2:	6a 78                	push   $0x78
  8008d4:	ff d6                	call   *%esi
			num = (unsigned long long)
  8008d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8008d9:	8b 10                	mov    (%eax),%edx
  8008db:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8008e0:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8008e3:	8d 40 04             	lea    0x4(%eax),%eax
  8008e6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8008e9:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  8008ee:	83 ec 0c             	sub    $0xc,%esp
  8008f1:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  8008f5:	57                   	push   %edi
  8008f6:	ff 75 e0             	pushl  -0x20(%ebp)
  8008f9:	50                   	push   %eax
  8008fa:	51                   	push   %ecx
  8008fb:	52                   	push   %edx
  8008fc:	89 da                	mov    %ebx,%edx
  8008fe:	89 f0                	mov    %esi,%eax
  800900:	e8 33 fb ff ff       	call   800438 <printnum>
			break;
  800905:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  800908:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80090b:	83 c7 01             	add    $0x1,%edi
  80090e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800912:	83 f8 25             	cmp    $0x25,%eax
  800915:	0f 84 23 fc ff ff    	je     80053e <vprintfmt+0x1b>
			if (ch == '\0')
  80091b:	85 c0                	test   %eax,%eax
  80091d:	0f 84 8b 00 00 00    	je     8009ae <vprintfmt+0x48b>
			putch(ch, putdat);
  800923:	83 ec 08             	sub    $0x8,%esp
  800926:	53                   	push   %ebx
  800927:	50                   	push   %eax
  800928:	ff d6                	call   *%esi
  80092a:	83 c4 10             	add    $0x10,%esp
  80092d:	eb dc                	jmp    80090b <vprintfmt+0x3e8>
	if (lflag >= 2)
  80092f:	83 f9 01             	cmp    $0x1,%ecx
  800932:	7f 1b                	jg     80094f <vprintfmt+0x42c>
	else if (lflag)
  800934:	85 c9                	test   %ecx,%ecx
  800936:	74 2c                	je     800964 <vprintfmt+0x441>
		return va_arg(*ap, unsigned long);
  800938:	8b 45 14             	mov    0x14(%ebp),%eax
  80093b:	8b 10                	mov    (%eax),%edx
  80093d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800942:	8d 40 04             	lea    0x4(%eax),%eax
  800945:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800948:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  80094d:	eb 9f                	jmp    8008ee <vprintfmt+0x3cb>
		return va_arg(*ap, unsigned long long);
  80094f:	8b 45 14             	mov    0x14(%ebp),%eax
  800952:	8b 10                	mov    (%eax),%edx
  800954:	8b 48 04             	mov    0x4(%eax),%ecx
  800957:	8d 40 08             	lea    0x8(%eax),%eax
  80095a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80095d:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  800962:	eb 8a                	jmp    8008ee <vprintfmt+0x3cb>
		return va_arg(*ap, unsigned int);
  800964:	8b 45 14             	mov    0x14(%ebp),%eax
  800967:	8b 10                	mov    (%eax),%edx
  800969:	b9 00 00 00 00       	mov    $0x0,%ecx
  80096e:	8d 40 04             	lea    0x4(%eax),%eax
  800971:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800974:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  800979:	e9 70 ff ff ff       	jmp    8008ee <vprintfmt+0x3cb>
			putch(ch, putdat);
  80097e:	83 ec 08             	sub    $0x8,%esp
  800981:	53                   	push   %ebx
  800982:	6a 25                	push   $0x25
  800984:	ff d6                	call   *%esi
			break;
  800986:	83 c4 10             	add    $0x10,%esp
  800989:	e9 7a ff ff ff       	jmp    800908 <vprintfmt+0x3e5>
			putch('%', putdat);
  80098e:	83 ec 08             	sub    $0x8,%esp
  800991:	53                   	push   %ebx
  800992:	6a 25                	push   $0x25
  800994:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800996:	83 c4 10             	add    $0x10,%esp
  800999:	89 f8                	mov    %edi,%eax
  80099b:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80099f:	74 05                	je     8009a6 <vprintfmt+0x483>
  8009a1:	83 e8 01             	sub    $0x1,%eax
  8009a4:	eb f5                	jmp    80099b <vprintfmt+0x478>
  8009a6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8009a9:	e9 5a ff ff ff       	jmp    800908 <vprintfmt+0x3e5>
}
  8009ae:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8009b1:	5b                   	pop    %ebx
  8009b2:	5e                   	pop    %esi
  8009b3:	5f                   	pop    %edi
  8009b4:	5d                   	pop    %ebp
  8009b5:	c3                   	ret    

008009b6 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8009b6:	f3 0f 1e fb          	endbr32 
  8009ba:	55                   	push   %ebp
  8009bb:	89 e5                	mov    %esp,%ebp
  8009bd:	83 ec 18             	sub    $0x18,%esp
  8009c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c3:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8009c6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8009c9:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8009cd:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8009d0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8009d7:	85 c0                	test   %eax,%eax
  8009d9:	74 26                	je     800a01 <vsnprintf+0x4b>
  8009db:	85 d2                	test   %edx,%edx
  8009dd:	7e 22                	jle    800a01 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8009df:	ff 75 14             	pushl  0x14(%ebp)
  8009e2:	ff 75 10             	pushl  0x10(%ebp)
  8009e5:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8009e8:	50                   	push   %eax
  8009e9:	68 e1 04 80 00       	push   $0x8004e1
  8009ee:	e8 30 fb ff ff       	call   800523 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8009f3:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8009f6:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8009f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009fc:	83 c4 10             	add    $0x10,%esp
}
  8009ff:	c9                   	leave  
  800a00:	c3                   	ret    
		return -E_INVAL;
  800a01:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800a06:	eb f7                	jmp    8009ff <vsnprintf+0x49>

00800a08 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800a08:	f3 0f 1e fb          	endbr32 
  800a0c:	55                   	push   %ebp
  800a0d:	89 e5                	mov    %esp,%ebp
  800a0f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800a12:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800a15:	50                   	push   %eax
  800a16:	ff 75 10             	pushl  0x10(%ebp)
  800a19:	ff 75 0c             	pushl  0xc(%ebp)
  800a1c:	ff 75 08             	pushl  0x8(%ebp)
  800a1f:	e8 92 ff ff ff       	call   8009b6 <vsnprintf>
	va_end(ap);

	return rc;
}
  800a24:	c9                   	leave  
  800a25:	c3                   	ret    

00800a26 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800a26:	f3 0f 1e fb          	endbr32 
  800a2a:	55                   	push   %ebp
  800a2b:	89 e5                	mov    %esp,%ebp
  800a2d:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a30:	b8 00 00 00 00       	mov    $0x0,%eax
  800a35:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a39:	74 05                	je     800a40 <strlen+0x1a>
		n++;
  800a3b:	83 c0 01             	add    $0x1,%eax
  800a3e:	eb f5                	jmp    800a35 <strlen+0xf>
	return n;
}
  800a40:	5d                   	pop    %ebp
  800a41:	c3                   	ret    

00800a42 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a42:	f3 0f 1e fb          	endbr32 
  800a46:	55                   	push   %ebp
  800a47:	89 e5                	mov    %esp,%ebp
  800a49:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a4c:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a4f:	b8 00 00 00 00       	mov    $0x0,%eax
  800a54:	39 d0                	cmp    %edx,%eax
  800a56:	74 0d                	je     800a65 <strnlen+0x23>
  800a58:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800a5c:	74 05                	je     800a63 <strnlen+0x21>
		n++;
  800a5e:	83 c0 01             	add    $0x1,%eax
  800a61:	eb f1                	jmp    800a54 <strnlen+0x12>
  800a63:	89 c2                	mov    %eax,%edx
	return n;
}
  800a65:	89 d0                	mov    %edx,%eax
  800a67:	5d                   	pop    %ebp
  800a68:	c3                   	ret    

00800a69 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a69:	f3 0f 1e fb          	endbr32 
  800a6d:	55                   	push   %ebp
  800a6e:	89 e5                	mov    %esp,%ebp
  800a70:	53                   	push   %ebx
  800a71:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a74:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a77:	b8 00 00 00 00       	mov    $0x0,%eax
  800a7c:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800a80:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800a83:	83 c0 01             	add    $0x1,%eax
  800a86:	84 d2                	test   %dl,%dl
  800a88:	75 f2                	jne    800a7c <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  800a8a:	89 c8                	mov    %ecx,%eax
  800a8c:	5b                   	pop    %ebx
  800a8d:	5d                   	pop    %ebp
  800a8e:	c3                   	ret    

00800a8f <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a8f:	f3 0f 1e fb          	endbr32 
  800a93:	55                   	push   %ebp
  800a94:	89 e5                	mov    %esp,%ebp
  800a96:	53                   	push   %ebx
  800a97:	83 ec 10             	sub    $0x10,%esp
  800a9a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a9d:	53                   	push   %ebx
  800a9e:	e8 83 ff ff ff       	call   800a26 <strlen>
  800aa3:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800aa6:	ff 75 0c             	pushl  0xc(%ebp)
  800aa9:	01 d8                	add    %ebx,%eax
  800aab:	50                   	push   %eax
  800aac:	e8 b8 ff ff ff       	call   800a69 <strcpy>
	return dst;
}
  800ab1:	89 d8                	mov    %ebx,%eax
  800ab3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ab6:	c9                   	leave  
  800ab7:	c3                   	ret    

00800ab8 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800ab8:	f3 0f 1e fb          	endbr32 
  800abc:	55                   	push   %ebp
  800abd:	89 e5                	mov    %esp,%ebp
  800abf:	56                   	push   %esi
  800ac0:	53                   	push   %ebx
  800ac1:	8b 75 08             	mov    0x8(%ebp),%esi
  800ac4:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ac7:	89 f3                	mov    %esi,%ebx
  800ac9:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800acc:	89 f0                	mov    %esi,%eax
  800ace:	39 d8                	cmp    %ebx,%eax
  800ad0:	74 11                	je     800ae3 <strncpy+0x2b>
		*dst++ = *src;
  800ad2:	83 c0 01             	add    $0x1,%eax
  800ad5:	0f b6 0a             	movzbl (%edx),%ecx
  800ad8:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800adb:	80 f9 01             	cmp    $0x1,%cl
  800ade:	83 da ff             	sbb    $0xffffffff,%edx
  800ae1:	eb eb                	jmp    800ace <strncpy+0x16>
	}
	return ret;
}
  800ae3:	89 f0                	mov    %esi,%eax
  800ae5:	5b                   	pop    %ebx
  800ae6:	5e                   	pop    %esi
  800ae7:	5d                   	pop    %ebp
  800ae8:	c3                   	ret    

00800ae9 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800ae9:	f3 0f 1e fb          	endbr32 
  800aed:	55                   	push   %ebp
  800aee:	89 e5                	mov    %esp,%ebp
  800af0:	56                   	push   %esi
  800af1:	53                   	push   %ebx
  800af2:	8b 75 08             	mov    0x8(%ebp),%esi
  800af5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800af8:	8b 55 10             	mov    0x10(%ebp),%edx
  800afb:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800afd:	85 d2                	test   %edx,%edx
  800aff:	74 21                	je     800b22 <strlcpy+0x39>
  800b01:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800b05:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  800b07:	39 c2                	cmp    %eax,%edx
  800b09:	74 14                	je     800b1f <strlcpy+0x36>
  800b0b:	0f b6 19             	movzbl (%ecx),%ebx
  800b0e:	84 db                	test   %bl,%bl
  800b10:	74 0b                	je     800b1d <strlcpy+0x34>
			*dst++ = *src++;
  800b12:	83 c1 01             	add    $0x1,%ecx
  800b15:	83 c2 01             	add    $0x1,%edx
  800b18:	88 5a ff             	mov    %bl,-0x1(%edx)
  800b1b:	eb ea                	jmp    800b07 <strlcpy+0x1e>
  800b1d:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800b1f:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800b22:	29 f0                	sub    %esi,%eax
}
  800b24:	5b                   	pop    %ebx
  800b25:	5e                   	pop    %esi
  800b26:	5d                   	pop    %ebp
  800b27:	c3                   	ret    

00800b28 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800b28:	f3 0f 1e fb          	endbr32 
  800b2c:	55                   	push   %ebp
  800b2d:	89 e5                	mov    %esp,%ebp
  800b2f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b32:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800b35:	0f b6 01             	movzbl (%ecx),%eax
  800b38:	84 c0                	test   %al,%al
  800b3a:	74 0c                	je     800b48 <strcmp+0x20>
  800b3c:	3a 02                	cmp    (%edx),%al
  800b3e:	75 08                	jne    800b48 <strcmp+0x20>
		p++, q++;
  800b40:	83 c1 01             	add    $0x1,%ecx
  800b43:	83 c2 01             	add    $0x1,%edx
  800b46:	eb ed                	jmp    800b35 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800b48:	0f b6 c0             	movzbl %al,%eax
  800b4b:	0f b6 12             	movzbl (%edx),%edx
  800b4e:	29 d0                	sub    %edx,%eax
}
  800b50:	5d                   	pop    %ebp
  800b51:	c3                   	ret    

00800b52 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b52:	f3 0f 1e fb          	endbr32 
  800b56:	55                   	push   %ebp
  800b57:	89 e5                	mov    %esp,%ebp
  800b59:	53                   	push   %ebx
  800b5a:	8b 45 08             	mov    0x8(%ebp),%eax
  800b5d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b60:	89 c3                	mov    %eax,%ebx
  800b62:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800b65:	eb 06                	jmp    800b6d <strncmp+0x1b>
		n--, p++, q++;
  800b67:	83 c0 01             	add    $0x1,%eax
  800b6a:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800b6d:	39 d8                	cmp    %ebx,%eax
  800b6f:	74 16                	je     800b87 <strncmp+0x35>
  800b71:	0f b6 08             	movzbl (%eax),%ecx
  800b74:	84 c9                	test   %cl,%cl
  800b76:	74 04                	je     800b7c <strncmp+0x2a>
  800b78:	3a 0a                	cmp    (%edx),%cl
  800b7a:	74 eb                	je     800b67 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b7c:	0f b6 00             	movzbl (%eax),%eax
  800b7f:	0f b6 12             	movzbl (%edx),%edx
  800b82:	29 d0                	sub    %edx,%eax
}
  800b84:	5b                   	pop    %ebx
  800b85:	5d                   	pop    %ebp
  800b86:	c3                   	ret    
		return 0;
  800b87:	b8 00 00 00 00       	mov    $0x0,%eax
  800b8c:	eb f6                	jmp    800b84 <strncmp+0x32>

00800b8e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b8e:	f3 0f 1e fb          	endbr32 
  800b92:	55                   	push   %ebp
  800b93:	89 e5                	mov    %esp,%ebp
  800b95:	8b 45 08             	mov    0x8(%ebp),%eax
  800b98:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b9c:	0f b6 10             	movzbl (%eax),%edx
  800b9f:	84 d2                	test   %dl,%dl
  800ba1:	74 09                	je     800bac <strchr+0x1e>
		if (*s == c)
  800ba3:	38 ca                	cmp    %cl,%dl
  800ba5:	74 0a                	je     800bb1 <strchr+0x23>
	for (; *s; s++)
  800ba7:	83 c0 01             	add    $0x1,%eax
  800baa:	eb f0                	jmp    800b9c <strchr+0xe>
			return (char *) s;
	return 0;
  800bac:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bb1:	5d                   	pop    %ebp
  800bb2:	c3                   	ret    

00800bb3 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800bb3:	f3 0f 1e fb          	endbr32 
  800bb7:	55                   	push   %ebp
  800bb8:	89 e5                	mov    %esp,%ebp
  800bba:	8b 45 08             	mov    0x8(%ebp),%eax
  800bbd:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800bc1:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800bc4:	38 ca                	cmp    %cl,%dl
  800bc6:	74 09                	je     800bd1 <strfind+0x1e>
  800bc8:	84 d2                	test   %dl,%dl
  800bca:	74 05                	je     800bd1 <strfind+0x1e>
	for (; *s; s++)
  800bcc:	83 c0 01             	add    $0x1,%eax
  800bcf:	eb f0                	jmp    800bc1 <strfind+0xe>
			break;
	return (char *) s;
}
  800bd1:	5d                   	pop    %ebp
  800bd2:	c3                   	ret    

00800bd3 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800bd3:	f3 0f 1e fb          	endbr32 
  800bd7:	55                   	push   %ebp
  800bd8:	89 e5                	mov    %esp,%ebp
  800bda:	57                   	push   %edi
  800bdb:	56                   	push   %esi
  800bdc:	53                   	push   %ebx
  800bdd:	8b 7d 08             	mov    0x8(%ebp),%edi
  800be0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800be3:	85 c9                	test   %ecx,%ecx
  800be5:	74 31                	je     800c18 <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800be7:	89 f8                	mov    %edi,%eax
  800be9:	09 c8                	or     %ecx,%eax
  800beb:	a8 03                	test   $0x3,%al
  800bed:	75 23                	jne    800c12 <memset+0x3f>
		c &= 0xFF;
  800bef:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800bf3:	89 d3                	mov    %edx,%ebx
  800bf5:	c1 e3 08             	shl    $0x8,%ebx
  800bf8:	89 d0                	mov    %edx,%eax
  800bfa:	c1 e0 18             	shl    $0x18,%eax
  800bfd:	89 d6                	mov    %edx,%esi
  800bff:	c1 e6 10             	shl    $0x10,%esi
  800c02:	09 f0                	or     %esi,%eax
  800c04:	09 c2                	or     %eax,%edx
  800c06:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800c08:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800c0b:	89 d0                	mov    %edx,%eax
  800c0d:	fc                   	cld    
  800c0e:	f3 ab                	rep stos %eax,%es:(%edi)
  800c10:	eb 06                	jmp    800c18 <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800c12:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c15:	fc                   	cld    
  800c16:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800c18:	89 f8                	mov    %edi,%eax
  800c1a:	5b                   	pop    %ebx
  800c1b:	5e                   	pop    %esi
  800c1c:	5f                   	pop    %edi
  800c1d:	5d                   	pop    %ebp
  800c1e:	c3                   	ret    

00800c1f <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800c1f:	f3 0f 1e fb          	endbr32 
  800c23:	55                   	push   %ebp
  800c24:	89 e5                	mov    %esp,%ebp
  800c26:	57                   	push   %edi
  800c27:	56                   	push   %esi
  800c28:	8b 45 08             	mov    0x8(%ebp),%eax
  800c2b:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c2e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800c31:	39 c6                	cmp    %eax,%esi
  800c33:	73 32                	jae    800c67 <memmove+0x48>
  800c35:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c38:	39 c2                	cmp    %eax,%edx
  800c3a:	76 2b                	jbe    800c67 <memmove+0x48>
		s += n;
		d += n;
  800c3c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c3f:	89 fe                	mov    %edi,%esi
  800c41:	09 ce                	or     %ecx,%esi
  800c43:	09 d6                	or     %edx,%esi
  800c45:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c4b:	75 0e                	jne    800c5b <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800c4d:	83 ef 04             	sub    $0x4,%edi
  800c50:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c53:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800c56:	fd                   	std    
  800c57:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c59:	eb 09                	jmp    800c64 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800c5b:	83 ef 01             	sub    $0x1,%edi
  800c5e:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800c61:	fd                   	std    
  800c62:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c64:	fc                   	cld    
  800c65:	eb 1a                	jmp    800c81 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c67:	89 c2                	mov    %eax,%edx
  800c69:	09 ca                	or     %ecx,%edx
  800c6b:	09 f2                	or     %esi,%edx
  800c6d:	f6 c2 03             	test   $0x3,%dl
  800c70:	75 0a                	jne    800c7c <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800c72:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800c75:	89 c7                	mov    %eax,%edi
  800c77:	fc                   	cld    
  800c78:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c7a:	eb 05                	jmp    800c81 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800c7c:	89 c7                	mov    %eax,%edi
  800c7e:	fc                   	cld    
  800c7f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c81:	5e                   	pop    %esi
  800c82:	5f                   	pop    %edi
  800c83:	5d                   	pop    %ebp
  800c84:	c3                   	ret    

00800c85 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c85:	f3 0f 1e fb          	endbr32 
  800c89:	55                   	push   %ebp
  800c8a:	89 e5                	mov    %esp,%ebp
  800c8c:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800c8f:	ff 75 10             	pushl  0x10(%ebp)
  800c92:	ff 75 0c             	pushl  0xc(%ebp)
  800c95:	ff 75 08             	pushl  0x8(%ebp)
  800c98:	e8 82 ff ff ff       	call   800c1f <memmove>
}
  800c9d:	c9                   	leave  
  800c9e:	c3                   	ret    

00800c9f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c9f:	f3 0f 1e fb          	endbr32 
  800ca3:	55                   	push   %ebp
  800ca4:	89 e5                	mov    %esp,%ebp
  800ca6:	56                   	push   %esi
  800ca7:	53                   	push   %ebx
  800ca8:	8b 45 08             	mov    0x8(%ebp),%eax
  800cab:	8b 55 0c             	mov    0xc(%ebp),%edx
  800cae:	89 c6                	mov    %eax,%esi
  800cb0:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800cb3:	39 f0                	cmp    %esi,%eax
  800cb5:	74 1c                	je     800cd3 <memcmp+0x34>
		if (*s1 != *s2)
  800cb7:	0f b6 08             	movzbl (%eax),%ecx
  800cba:	0f b6 1a             	movzbl (%edx),%ebx
  800cbd:	38 d9                	cmp    %bl,%cl
  800cbf:	75 08                	jne    800cc9 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800cc1:	83 c0 01             	add    $0x1,%eax
  800cc4:	83 c2 01             	add    $0x1,%edx
  800cc7:	eb ea                	jmp    800cb3 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800cc9:	0f b6 c1             	movzbl %cl,%eax
  800ccc:	0f b6 db             	movzbl %bl,%ebx
  800ccf:	29 d8                	sub    %ebx,%eax
  800cd1:	eb 05                	jmp    800cd8 <memcmp+0x39>
	}

	return 0;
  800cd3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800cd8:	5b                   	pop    %ebx
  800cd9:	5e                   	pop    %esi
  800cda:	5d                   	pop    %ebp
  800cdb:	c3                   	ret    

00800cdc <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800cdc:	f3 0f 1e fb          	endbr32 
  800ce0:	55                   	push   %ebp
  800ce1:	89 e5                	mov    %esp,%ebp
  800ce3:	8b 45 08             	mov    0x8(%ebp),%eax
  800ce6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800ce9:	89 c2                	mov    %eax,%edx
  800ceb:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800cee:	39 d0                	cmp    %edx,%eax
  800cf0:	73 09                	jae    800cfb <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800cf2:	38 08                	cmp    %cl,(%eax)
  800cf4:	74 05                	je     800cfb <memfind+0x1f>
	for (; s < ends; s++)
  800cf6:	83 c0 01             	add    $0x1,%eax
  800cf9:	eb f3                	jmp    800cee <memfind+0x12>
			break;
	return (void *) s;
}
  800cfb:	5d                   	pop    %ebp
  800cfc:	c3                   	ret    

00800cfd <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800cfd:	f3 0f 1e fb          	endbr32 
  800d01:	55                   	push   %ebp
  800d02:	89 e5                	mov    %esp,%ebp
  800d04:	57                   	push   %edi
  800d05:	56                   	push   %esi
  800d06:	53                   	push   %ebx
  800d07:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d0a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d0d:	eb 03                	jmp    800d12 <strtol+0x15>
		s++;
  800d0f:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800d12:	0f b6 01             	movzbl (%ecx),%eax
  800d15:	3c 20                	cmp    $0x20,%al
  800d17:	74 f6                	je     800d0f <strtol+0x12>
  800d19:	3c 09                	cmp    $0x9,%al
  800d1b:	74 f2                	je     800d0f <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800d1d:	3c 2b                	cmp    $0x2b,%al
  800d1f:	74 2a                	je     800d4b <strtol+0x4e>
	int neg = 0;
  800d21:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800d26:	3c 2d                	cmp    $0x2d,%al
  800d28:	74 2b                	je     800d55 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d2a:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800d30:	75 0f                	jne    800d41 <strtol+0x44>
  800d32:	80 39 30             	cmpb   $0x30,(%ecx)
  800d35:	74 28                	je     800d5f <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800d37:	85 db                	test   %ebx,%ebx
  800d39:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d3e:	0f 44 d8             	cmove  %eax,%ebx
  800d41:	b8 00 00 00 00       	mov    $0x0,%eax
  800d46:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800d49:	eb 46                	jmp    800d91 <strtol+0x94>
		s++;
  800d4b:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800d4e:	bf 00 00 00 00       	mov    $0x0,%edi
  800d53:	eb d5                	jmp    800d2a <strtol+0x2d>
		s++, neg = 1;
  800d55:	83 c1 01             	add    $0x1,%ecx
  800d58:	bf 01 00 00 00       	mov    $0x1,%edi
  800d5d:	eb cb                	jmp    800d2a <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d5f:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800d63:	74 0e                	je     800d73 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800d65:	85 db                	test   %ebx,%ebx
  800d67:	75 d8                	jne    800d41 <strtol+0x44>
		s++, base = 8;
  800d69:	83 c1 01             	add    $0x1,%ecx
  800d6c:	bb 08 00 00 00       	mov    $0x8,%ebx
  800d71:	eb ce                	jmp    800d41 <strtol+0x44>
		s += 2, base = 16;
  800d73:	83 c1 02             	add    $0x2,%ecx
  800d76:	bb 10 00 00 00       	mov    $0x10,%ebx
  800d7b:	eb c4                	jmp    800d41 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800d7d:	0f be d2             	movsbl %dl,%edx
  800d80:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800d83:	3b 55 10             	cmp    0x10(%ebp),%edx
  800d86:	7d 3a                	jge    800dc2 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800d88:	83 c1 01             	add    $0x1,%ecx
  800d8b:	0f af 45 10          	imul   0x10(%ebp),%eax
  800d8f:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800d91:	0f b6 11             	movzbl (%ecx),%edx
  800d94:	8d 72 d0             	lea    -0x30(%edx),%esi
  800d97:	89 f3                	mov    %esi,%ebx
  800d99:	80 fb 09             	cmp    $0x9,%bl
  800d9c:	76 df                	jbe    800d7d <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800d9e:	8d 72 9f             	lea    -0x61(%edx),%esi
  800da1:	89 f3                	mov    %esi,%ebx
  800da3:	80 fb 19             	cmp    $0x19,%bl
  800da6:	77 08                	ja     800db0 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800da8:	0f be d2             	movsbl %dl,%edx
  800dab:	83 ea 57             	sub    $0x57,%edx
  800dae:	eb d3                	jmp    800d83 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800db0:	8d 72 bf             	lea    -0x41(%edx),%esi
  800db3:	89 f3                	mov    %esi,%ebx
  800db5:	80 fb 19             	cmp    $0x19,%bl
  800db8:	77 08                	ja     800dc2 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800dba:	0f be d2             	movsbl %dl,%edx
  800dbd:	83 ea 37             	sub    $0x37,%edx
  800dc0:	eb c1                	jmp    800d83 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800dc2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800dc6:	74 05                	je     800dcd <strtol+0xd0>
		*endptr = (char *) s;
  800dc8:	8b 75 0c             	mov    0xc(%ebp),%esi
  800dcb:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800dcd:	89 c2                	mov    %eax,%edx
  800dcf:	f7 da                	neg    %edx
  800dd1:	85 ff                	test   %edi,%edi
  800dd3:	0f 45 c2             	cmovne %edx,%eax
}
  800dd6:	5b                   	pop    %ebx
  800dd7:	5e                   	pop    %esi
  800dd8:	5f                   	pop    %edi
  800dd9:	5d                   	pop    %ebp
  800dda:	c3                   	ret    
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
