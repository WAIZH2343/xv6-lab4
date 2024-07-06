
obj/user/buggyhello2:     file format elf32-i386


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
  80002c:	e8 21 00 00 00       	call   800052 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

const char *hello = "hello, world\n";

void
umain(int argc, char **argv)
{
  800033:	f3 0f 1e fb          	endbr32 
  800037:	55                   	push   %ebp
  800038:	89 e5                	mov    %esp,%ebp
  80003a:	83 ec 10             	sub    $0x10,%esp
	sys_cputs(hello, 1024*1024);
  80003d:	68 00 00 10 00       	push   $0x100000
  800042:	ff 35 00 20 80 00    	pushl  0x802000
  800048:	e8 65 00 00 00       	call   8000b2 <sys_cputs>
}
  80004d:	83 c4 10             	add    $0x10,%esp
  800050:	c9                   	leave  
  800051:	c3                   	ret    

00800052 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800052:	f3 0f 1e fb          	endbr32 
  800056:	55                   	push   %ebp
  800057:	89 e5                	mov    %esp,%ebp
  800059:	56                   	push   %esi
  80005a:	53                   	push   %ebx
  80005b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80005e:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv=&envs[ENVX(sys_getenvid())];
  800061:	e8 d6 00 00 00       	call   80013c <sys_getenvid>
  800066:	25 ff 03 00 00       	and    $0x3ff,%eax
  80006b:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80006e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800073:	a3 08 20 80 00       	mov    %eax,0x802008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800078:	85 db                	test   %ebx,%ebx
  80007a:	7e 07                	jle    800083 <libmain+0x31>
		binaryname = argv[0];
  80007c:	8b 06                	mov    (%esi),%eax
  80007e:	a3 04 20 80 00       	mov    %eax,0x802004

	// call user main routine
	umain(argc, argv);
  800083:	83 ec 08             	sub    $0x8,%esp
  800086:	56                   	push   %esi
  800087:	53                   	push   %ebx
  800088:	e8 a6 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80008d:	e8 0a 00 00 00       	call   80009c <exit>
}
  800092:	83 c4 10             	add    $0x10,%esp
  800095:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800098:	5b                   	pop    %ebx
  800099:	5e                   	pop    %esi
  80009a:	5d                   	pop    %ebp
  80009b:	c3                   	ret    

0080009c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80009c:	f3 0f 1e fb          	endbr32 
  8000a0:	55                   	push   %ebp
  8000a1:	89 e5                	mov    %esp,%ebp
  8000a3:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000a6:	6a 00                	push   $0x0
  8000a8:	e8 4a 00 00 00       	call   8000f7 <sys_env_destroy>
}
  8000ad:	83 c4 10             	add    $0x10,%esp
  8000b0:	c9                   	leave  
  8000b1:	c3                   	ret    

008000b2 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000b2:	f3 0f 1e fb          	endbr32 
  8000b6:	55                   	push   %ebp
  8000b7:	89 e5                	mov    %esp,%ebp
  8000b9:	57                   	push   %edi
  8000ba:	56                   	push   %esi
  8000bb:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000bc:	b8 00 00 00 00       	mov    $0x0,%eax
  8000c1:	8b 55 08             	mov    0x8(%ebp),%edx
  8000c4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000c7:	89 c3                	mov    %eax,%ebx
  8000c9:	89 c7                	mov    %eax,%edi
  8000cb:	89 c6                	mov    %eax,%esi
  8000cd:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000cf:	5b                   	pop    %ebx
  8000d0:	5e                   	pop    %esi
  8000d1:	5f                   	pop    %edi
  8000d2:	5d                   	pop    %ebp
  8000d3:	c3                   	ret    

008000d4 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000d4:	f3 0f 1e fb          	endbr32 
  8000d8:	55                   	push   %ebp
  8000d9:	89 e5                	mov    %esp,%ebp
  8000db:	57                   	push   %edi
  8000dc:	56                   	push   %esi
  8000dd:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000de:	ba 00 00 00 00       	mov    $0x0,%edx
  8000e3:	b8 01 00 00 00       	mov    $0x1,%eax
  8000e8:	89 d1                	mov    %edx,%ecx
  8000ea:	89 d3                	mov    %edx,%ebx
  8000ec:	89 d7                	mov    %edx,%edi
  8000ee:	89 d6                	mov    %edx,%esi
  8000f0:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000f2:	5b                   	pop    %ebx
  8000f3:	5e                   	pop    %esi
  8000f4:	5f                   	pop    %edi
  8000f5:	5d                   	pop    %ebp
  8000f6:	c3                   	ret    

008000f7 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000f7:	f3 0f 1e fb          	endbr32 
  8000fb:	55                   	push   %ebp
  8000fc:	89 e5                	mov    %esp,%ebp
  8000fe:	57                   	push   %edi
  8000ff:	56                   	push   %esi
  800100:	53                   	push   %ebx
  800101:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800104:	b9 00 00 00 00       	mov    $0x0,%ecx
  800109:	8b 55 08             	mov    0x8(%ebp),%edx
  80010c:	b8 03 00 00 00       	mov    $0x3,%eax
  800111:	89 cb                	mov    %ecx,%ebx
  800113:	89 cf                	mov    %ecx,%edi
  800115:	89 ce                	mov    %ecx,%esi
  800117:	cd 30                	int    $0x30
	if(check && ret > 0)
  800119:	85 c0                	test   %eax,%eax
  80011b:	7f 08                	jg     800125 <sys_env_destroy+0x2e>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80011d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800120:	5b                   	pop    %ebx
  800121:	5e                   	pop    %esi
  800122:	5f                   	pop    %edi
  800123:	5d                   	pop    %ebp
  800124:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800125:	83 ec 0c             	sub    $0xc,%esp
  800128:	50                   	push   %eax
  800129:	6a 03                	push   $0x3
  80012b:	68 78 10 80 00       	push   $0x801078
  800130:	6a 23                	push   $0x23
  800132:	68 95 10 80 00       	push   $0x801095
  800137:	e8 11 02 00 00       	call   80034d <_panic>

0080013c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80013c:	f3 0f 1e fb          	endbr32 
  800140:	55                   	push   %ebp
  800141:	89 e5                	mov    %esp,%ebp
  800143:	57                   	push   %edi
  800144:	56                   	push   %esi
  800145:	53                   	push   %ebx
	asm volatile("int %1\n"
  800146:	ba 00 00 00 00       	mov    $0x0,%edx
  80014b:	b8 02 00 00 00       	mov    $0x2,%eax
  800150:	89 d1                	mov    %edx,%ecx
  800152:	89 d3                	mov    %edx,%ebx
  800154:	89 d7                	mov    %edx,%edi
  800156:	89 d6                	mov    %edx,%esi
  800158:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80015a:	5b                   	pop    %ebx
  80015b:	5e                   	pop    %esi
  80015c:	5f                   	pop    %edi
  80015d:	5d                   	pop    %ebp
  80015e:	c3                   	ret    

0080015f <sys_yield>:

void
sys_yield(void)
{
  80015f:	f3 0f 1e fb          	endbr32 
  800163:	55                   	push   %ebp
  800164:	89 e5                	mov    %esp,%ebp
  800166:	57                   	push   %edi
  800167:	56                   	push   %esi
  800168:	53                   	push   %ebx
	asm volatile("int %1\n"
  800169:	ba 00 00 00 00       	mov    $0x0,%edx
  80016e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800173:	89 d1                	mov    %edx,%ecx
  800175:	89 d3                	mov    %edx,%ebx
  800177:	89 d7                	mov    %edx,%edi
  800179:	89 d6                	mov    %edx,%esi
  80017b:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80017d:	5b                   	pop    %ebx
  80017e:	5e                   	pop    %esi
  80017f:	5f                   	pop    %edi
  800180:	5d                   	pop    %ebp
  800181:	c3                   	ret    

00800182 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800182:	f3 0f 1e fb          	endbr32 
  800186:	55                   	push   %ebp
  800187:	89 e5                	mov    %esp,%ebp
  800189:	57                   	push   %edi
  80018a:	56                   	push   %esi
  80018b:	53                   	push   %ebx
  80018c:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80018f:	be 00 00 00 00       	mov    $0x0,%esi
  800194:	8b 55 08             	mov    0x8(%ebp),%edx
  800197:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80019a:	b8 04 00 00 00       	mov    $0x4,%eax
  80019f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001a2:	89 f7                	mov    %esi,%edi
  8001a4:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001a6:	85 c0                	test   %eax,%eax
  8001a8:	7f 08                	jg     8001b2 <sys_page_alloc+0x30>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001aa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001ad:	5b                   	pop    %ebx
  8001ae:	5e                   	pop    %esi
  8001af:	5f                   	pop    %edi
  8001b0:	5d                   	pop    %ebp
  8001b1:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8001b2:	83 ec 0c             	sub    $0xc,%esp
  8001b5:	50                   	push   %eax
  8001b6:	6a 04                	push   $0x4
  8001b8:	68 78 10 80 00       	push   $0x801078
  8001bd:	6a 23                	push   $0x23
  8001bf:	68 95 10 80 00       	push   $0x801095
  8001c4:	e8 84 01 00 00       	call   80034d <_panic>

008001c9 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001c9:	f3 0f 1e fb          	endbr32 
  8001cd:	55                   	push   %ebp
  8001ce:	89 e5                	mov    %esp,%ebp
  8001d0:	57                   	push   %edi
  8001d1:	56                   	push   %esi
  8001d2:	53                   	push   %ebx
  8001d3:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001d6:	8b 55 08             	mov    0x8(%ebp),%edx
  8001d9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001dc:	b8 05 00 00 00       	mov    $0x5,%eax
  8001e1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001e4:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001e7:	8b 75 18             	mov    0x18(%ebp),%esi
  8001ea:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001ec:	85 c0                	test   %eax,%eax
  8001ee:	7f 08                	jg     8001f8 <sys_page_map+0x2f>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001f0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001f3:	5b                   	pop    %ebx
  8001f4:	5e                   	pop    %esi
  8001f5:	5f                   	pop    %edi
  8001f6:	5d                   	pop    %ebp
  8001f7:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8001f8:	83 ec 0c             	sub    $0xc,%esp
  8001fb:	50                   	push   %eax
  8001fc:	6a 05                	push   $0x5
  8001fe:	68 78 10 80 00       	push   $0x801078
  800203:	6a 23                	push   $0x23
  800205:	68 95 10 80 00       	push   $0x801095
  80020a:	e8 3e 01 00 00       	call   80034d <_panic>

0080020f <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80020f:	f3 0f 1e fb          	endbr32 
  800213:	55                   	push   %ebp
  800214:	89 e5                	mov    %esp,%ebp
  800216:	57                   	push   %edi
  800217:	56                   	push   %esi
  800218:	53                   	push   %ebx
  800219:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80021c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800221:	8b 55 08             	mov    0x8(%ebp),%edx
  800224:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800227:	b8 06 00 00 00       	mov    $0x6,%eax
  80022c:	89 df                	mov    %ebx,%edi
  80022e:	89 de                	mov    %ebx,%esi
  800230:	cd 30                	int    $0x30
	if(check && ret > 0)
  800232:	85 c0                	test   %eax,%eax
  800234:	7f 08                	jg     80023e <sys_page_unmap+0x2f>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800236:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800239:	5b                   	pop    %ebx
  80023a:	5e                   	pop    %esi
  80023b:	5f                   	pop    %edi
  80023c:	5d                   	pop    %ebp
  80023d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80023e:	83 ec 0c             	sub    $0xc,%esp
  800241:	50                   	push   %eax
  800242:	6a 06                	push   $0x6
  800244:	68 78 10 80 00       	push   $0x801078
  800249:	6a 23                	push   $0x23
  80024b:	68 95 10 80 00       	push   $0x801095
  800250:	e8 f8 00 00 00       	call   80034d <_panic>

00800255 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800255:	f3 0f 1e fb          	endbr32 
  800259:	55                   	push   %ebp
  80025a:	89 e5                	mov    %esp,%ebp
  80025c:	57                   	push   %edi
  80025d:	56                   	push   %esi
  80025e:	53                   	push   %ebx
  80025f:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800262:	bb 00 00 00 00       	mov    $0x0,%ebx
  800267:	8b 55 08             	mov    0x8(%ebp),%edx
  80026a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80026d:	b8 08 00 00 00       	mov    $0x8,%eax
  800272:	89 df                	mov    %ebx,%edi
  800274:	89 de                	mov    %ebx,%esi
  800276:	cd 30                	int    $0x30
	if(check && ret > 0)
  800278:	85 c0                	test   %eax,%eax
  80027a:	7f 08                	jg     800284 <sys_env_set_status+0x2f>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80027c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80027f:	5b                   	pop    %ebx
  800280:	5e                   	pop    %esi
  800281:	5f                   	pop    %edi
  800282:	5d                   	pop    %ebp
  800283:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800284:	83 ec 0c             	sub    $0xc,%esp
  800287:	50                   	push   %eax
  800288:	6a 08                	push   $0x8
  80028a:	68 78 10 80 00       	push   $0x801078
  80028f:	6a 23                	push   $0x23
  800291:	68 95 10 80 00       	push   $0x801095
  800296:	e8 b2 00 00 00       	call   80034d <_panic>

0080029b <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80029b:	f3 0f 1e fb          	endbr32 
  80029f:	55                   	push   %ebp
  8002a0:	89 e5                	mov    %esp,%ebp
  8002a2:	57                   	push   %edi
  8002a3:	56                   	push   %esi
  8002a4:	53                   	push   %ebx
  8002a5:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8002a8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002ad:	8b 55 08             	mov    0x8(%ebp),%edx
  8002b0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002b3:	b8 09 00 00 00       	mov    $0x9,%eax
  8002b8:	89 df                	mov    %ebx,%edi
  8002ba:	89 de                	mov    %ebx,%esi
  8002bc:	cd 30                	int    $0x30
	if(check && ret > 0)
  8002be:	85 c0                	test   %eax,%eax
  8002c0:	7f 08                	jg     8002ca <sys_env_set_pgfault_upcall+0x2f>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002c2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002c5:	5b                   	pop    %ebx
  8002c6:	5e                   	pop    %esi
  8002c7:	5f                   	pop    %edi
  8002c8:	5d                   	pop    %ebp
  8002c9:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8002ca:	83 ec 0c             	sub    $0xc,%esp
  8002cd:	50                   	push   %eax
  8002ce:	6a 09                	push   $0x9
  8002d0:	68 78 10 80 00       	push   $0x801078
  8002d5:	6a 23                	push   $0x23
  8002d7:	68 95 10 80 00       	push   $0x801095
  8002dc:	e8 6c 00 00 00       	call   80034d <_panic>

008002e1 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002e1:	f3 0f 1e fb          	endbr32 
  8002e5:	55                   	push   %ebp
  8002e6:	89 e5                	mov    %esp,%ebp
  8002e8:	57                   	push   %edi
  8002e9:	56                   	push   %esi
  8002ea:	53                   	push   %ebx
	asm volatile("int %1\n"
  8002eb:	8b 55 08             	mov    0x8(%ebp),%edx
  8002ee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002f1:	b8 0b 00 00 00       	mov    $0xb,%eax
  8002f6:	be 00 00 00 00       	mov    $0x0,%esi
  8002fb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002fe:	8b 7d 14             	mov    0x14(%ebp),%edi
  800301:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800303:	5b                   	pop    %ebx
  800304:	5e                   	pop    %esi
  800305:	5f                   	pop    %edi
  800306:	5d                   	pop    %ebp
  800307:	c3                   	ret    

00800308 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800308:	f3 0f 1e fb          	endbr32 
  80030c:	55                   	push   %ebp
  80030d:	89 e5                	mov    %esp,%ebp
  80030f:	57                   	push   %edi
  800310:	56                   	push   %esi
  800311:	53                   	push   %ebx
  800312:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800315:	b9 00 00 00 00       	mov    $0x0,%ecx
  80031a:	8b 55 08             	mov    0x8(%ebp),%edx
  80031d:	b8 0c 00 00 00       	mov    $0xc,%eax
  800322:	89 cb                	mov    %ecx,%ebx
  800324:	89 cf                	mov    %ecx,%edi
  800326:	89 ce                	mov    %ecx,%esi
  800328:	cd 30                	int    $0x30
	if(check && ret > 0)
  80032a:	85 c0                	test   %eax,%eax
  80032c:	7f 08                	jg     800336 <sys_ipc_recv+0x2e>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80032e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800331:	5b                   	pop    %ebx
  800332:	5e                   	pop    %esi
  800333:	5f                   	pop    %edi
  800334:	5d                   	pop    %ebp
  800335:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800336:	83 ec 0c             	sub    $0xc,%esp
  800339:	50                   	push   %eax
  80033a:	6a 0c                	push   $0xc
  80033c:	68 78 10 80 00       	push   $0x801078
  800341:	6a 23                	push   $0x23
  800343:	68 95 10 80 00       	push   $0x801095
  800348:	e8 00 00 00 00       	call   80034d <_panic>

0080034d <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80034d:	f3 0f 1e fb          	endbr32 
  800351:	55                   	push   %ebp
  800352:	89 e5                	mov    %esp,%ebp
  800354:	56                   	push   %esi
  800355:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800356:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800359:	8b 35 04 20 80 00    	mov    0x802004,%esi
  80035f:	e8 d8 fd ff ff       	call   80013c <sys_getenvid>
  800364:	83 ec 0c             	sub    $0xc,%esp
  800367:	ff 75 0c             	pushl  0xc(%ebp)
  80036a:	ff 75 08             	pushl  0x8(%ebp)
  80036d:	56                   	push   %esi
  80036e:	50                   	push   %eax
  80036f:	68 a4 10 80 00       	push   $0x8010a4
  800374:	e8 bb 00 00 00       	call   800434 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800379:	83 c4 18             	add    $0x18,%esp
  80037c:	53                   	push   %ebx
  80037d:	ff 75 10             	pushl  0x10(%ebp)
  800380:	e8 5a 00 00 00       	call   8003df <vcprintf>
	cprintf("\n");
  800385:	c7 04 24 6c 10 80 00 	movl   $0x80106c,(%esp)
  80038c:	e8 a3 00 00 00       	call   800434 <cprintf>
  800391:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800394:	cc                   	int3   
  800395:	eb fd                	jmp    800394 <_panic+0x47>

00800397 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800397:	f3 0f 1e fb          	endbr32 
  80039b:	55                   	push   %ebp
  80039c:	89 e5                	mov    %esp,%ebp
  80039e:	53                   	push   %ebx
  80039f:	83 ec 04             	sub    $0x4,%esp
  8003a2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8003a5:	8b 13                	mov    (%ebx),%edx
  8003a7:	8d 42 01             	lea    0x1(%edx),%eax
  8003aa:	89 03                	mov    %eax,(%ebx)
  8003ac:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003af:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8003b3:	3d ff 00 00 00       	cmp    $0xff,%eax
  8003b8:	74 09                	je     8003c3 <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8003ba:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8003be:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8003c1:	c9                   	leave  
  8003c2:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8003c3:	83 ec 08             	sub    $0x8,%esp
  8003c6:	68 ff 00 00 00       	push   $0xff
  8003cb:	8d 43 08             	lea    0x8(%ebx),%eax
  8003ce:	50                   	push   %eax
  8003cf:	e8 de fc ff ff       	call   8000b2 <sys_cputs>
		b->idx = 0;
  8003d4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8003da:	83 c4 10             	add    $0x10,%esp
  8003dd:	eb db                	jmp    8003ba <putch+0x23>

008003df <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8003df:	f3 0f 1e fb          	endbr32 
  8003e3:	55                   	push   %ebp
  8003e4:	89 e5                	mov    %esp,%ebp
  8003e6:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8003ec:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003f3:	00 00 00 
	b.cnt = 0;
  8003f6:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003fd:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800400:	ff 75 0c             	pushl  0xc(%ebp)
  800403:	ff 75 08             	pushl  0x8(%ebp)
  800406:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80040c:	50                   	push   %eax
  80040d:	68 97 03 80 00       	push   $0x800397
  800412:	e8 20 01 00 00       	call   800537 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800417:	83 c4 08             	add    $0x8,%esp
  80041a:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800420:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800426:	50                   	push   %eax
  800427:	e8 86 fc ff ff       	call   8000b2 <sys_cputs>

	return b.cnt;
}
  80042c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800432:	c9                   	leave  
  800433:	c3                   	ret    

00800434 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800434:	f3 0f 1e fb          	endbr32 
  800438:	55                   	push   %ebp
  800439:	89 e5                	mov    %esp,%ebp
  80043b:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80043e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800441:	50                   	push   %eax
  800442:	ff 75 08             	pushl  0x8(%ebp)
  800445:	e8 95 ff ff ff       	call   8003df <vcprintf>
	va_end(ap);

	return cnt;
}
  80044a:	c9                   	leave  
  80044b:	c3                   	ret    

0080044c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80044c:	55                   	push   %ebp
  80044d:	89 e5                	mov    %esp,%ebp
  80044f:	57                   	push   %edi
  800450:	56                   	push   %esi
  800451:	53                   	push   %ebx
  800452:	83 ec 1c             	sub    $0x1c,%esp
  800455:	89 c7                	mov    %eax,%edi
  800457:	89 d6                	mov    %edx,%esi
  800459:	8b 45 08             	mov    0x8(%ebp),%eax
  80045c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80045f:	89 d1                	mov    %edx,%ecx
  800461:	89 c2                	mov    %eax,%edx
  800463:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800466:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800469:	8b 45 10             	mov    0x10(%ebp),%eax
  80046c:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80046f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800472:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800479:	39 c2                	cmp    %eax,%edx
  80047b:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  80047e:	72 3e                	jb     8004be <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800480:	83 ec 0c             	sub    $0xc,%esp
  800483:	ff 75 18             	pushl  0x18(%ebp)
  800486:	83 eb 01             	sub    $0x1,%ebx
  800489:	53                   	push   %ebx
  80048a:	50                   	push   %eax
  80048b:	83 ec 08             	sub    $0x8,%esp
  80048e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800491:	ff 75 e0             	pushl  -0x20(%ebp)
  800494:	ff 75 dc             	pushl  -0x24(%ebp)
  800497:	ff 75 d8             	pushl  -0x28(%ebp)
  80049a:	e8 51 09 00 00       	call   800df0 <__udivdi3>
  80049f:	83 c4 18             	add    $0x18,%esp
  8004a2:	52                   	push   %edx
  8004a3:	50                   	push   %eax
  8004a4:	89 f2                	mov    %esi,%edx
  8004a6:	89 f8                	mov    %edi,%eax
  8004a8:	e8 9f ff ff ff       	call   80044c <printnum>
  8004ad:	83 c4 20             	add    $0x20,%esp
  8004b0:	eb 13                	jmp    8004c5 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8004b2:	83 ec 08             	sub    $0x8,%esp
  8004b5:	56                   	push   %esi
  8004b6:	ff 75 18             	pushl  0x18(%ebp)
  8004b9:	ff d7                	call   *%edi
  8004bb:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8004be:	83 eb 01             	sub    $0x1,%ebx
  8004c1:	85 db                	test   %ebx,%ebx
  8004c3:	7f ed                	jg     8004b2 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8004c5:	83 ec 08             	sub    $0x8,%esp
  8004c8:	56                   	push   %esi
  8004c9:	83 ec 04             	sub    $0x4,%esp
  8004cc:	ff 75 e4             	pushl  -0x1c(%ebp)
  8004cf:	ff 75 e0             	pushl  -0x20(%ebp)
  8004d2:	ff 75 dc             	pushl  -0x24(%ebp)
  8004d5:	ff 75 d8             	pushl  -0x28(%ebp)
  8004d8:	e8 23 0a 00 00       	call   800f00 <__umoddi3>
  8004dd:	83 c4 14             	add    $0x14,%esp
  8004e0:	0f be 80 c7 10 80 00 	movsbl 0x8010c7(%eax),%eax
  8004e7:	50                   	push   %eax
  8004e8:	ff d7                	call   *%edi
}
  8004ea:	83 c4 10             	add    $0x10,%esp
  8004ed:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004f0:	5b                   	pop    %ebx
  8004f1:	5e                   	pop    %esi
  8004f2:	5f                   	pop    %edi
  8004f3:	5d                   	pop    %ebp
  8004f4:	c3                   	ret    

008004f5 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004f5:	f3 0f 1e fb          	endbr32 
  8004f9:	55                   	push   %ebp
  8004fa:	89 e5                	mov    %esp,%ebp
  8004fc:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004ff:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800503:	8b 10                	mov    (%eax),%edx
  800505:	3b 50 04             	cmp    0x4(%eax),%edx
  800508:	73 0a                	jae    800514 <sprintputch+0x1f>
		*b->buf++ = ch;
  80050a:	8d 4a 01             	lea    0x1(%edx),%ecx
  80050d:	89 08                	mov    %ecx,(%eax)
  80050f:	8b 45 08             	mov    0x8(%ebp),%eax
  800512:	88 02                	mov    %al,(%edx)
}
  800514:	5d                   	pop    %ebp
  800515:	c3                   	ret    

00800516 <printfmt>:
{
  800516:	f3 0f 1e fb          	endbr32 
  80051a:	55                   	push   %ebp
  80051b:	89 e5                	mov    %esp,%ebp
  80051d:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800520:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800523:	50                   	push   %eax
  800524:	ff 75 10             	pushl  0x10(%ebp)
  800527:	ff 75 0c             	pushl  0xc(%ebp)
  80052a:	ff 75 08             	pushl  0x8(%ebp)
  80052d:	e8 05 00 00 00       	call   800537 <vprintfmt>
}
  800532:	83 c4 10             	add    $0x10,%esp
  800535:	c9                   	leave  
  800536:	c3                   	ret    

00800537 <vprintfmt>:
{
  800537:	f3 0f 1e fb          	endbr32 
  80053b:	55                   	push   %ebp
  80053c:	89 e5                	mov    %esp,%ebp
  80053e:	57                   	push   %edi
  80053f:	56                   	push   %esi
  800540:	53                   	push   %ebx
  800541:	83 ec 3c             	sub    $0x3c,%esp
  800544:	8b 75 08             	mov    0x8(%ebp),%esi
  800547:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80054a:	8b 7d 10             	mov    0x10(%ebp),%edi
  80054d:	e9 cd 03 00 00       	jmp    80091f <vprintfmt+0x3e8>
		padc = ' ';
  800552:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800556:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  80055d:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800564:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80056b:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800570:	8d 47 01             	lea    0x1(%edi),%eax
  800573:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800576:	0f b6 17             	movzbl (%edi),%edx
  800579:	8d 42 dd             	lea    -0x23(%edx),%eax
  80057c:	3c 55                	cmp    $0x55,%al
  80057e:	0f 87 1e 04 00 00    	ja     8009a2 <vprintfmt+0x46b>
  800584:	0f b6 c0             	movzbl %al,%eax
  800587:	3e ff 24 85 80 11 80 	notrack jmp *0x801180(,%eax,4)
  80058e:	00 
  80058f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800592:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800596:	eb d8                	jmp    800570 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800598:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80059b:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  80059f:	eb cf                	jmp    800570 <vprintfmt+0x39>
  8005a1:	0f b6 d2             	movzbl %dl,%edx
  8005a4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8005a7:	b8 00 00 00 00       	mov    $0x0,%eax
  8005ac:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8005af:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8005b2:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8005b6:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8005b9:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8005bc:	83 f9 09             	cmp    $0x9,%ecx
  8005bf:	77 55                	ja     800616 <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  8005c1:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8005c4:	eb e9                	jmp    8005af <vprintfmt+0x78>
			precision = va_arg(ap, int);
  8005c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c9:	8b 00                	mov    (%eax),%eax
  8005cb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005ce:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d1:	8d 40 04             	lea    0x4(%eax),%eax
  8005d4:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8005d7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8005da:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005de:	79 90                	jns    800570 <vprintfmt+0x39>
				width = precision, precision = -1;
  8005e0:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005e3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005e6:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8005ed:	eb 81                	jmp    800570 <vprintfmt+0x39>
  8005ef:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005f2:	85 c0                	test   %eax,%eax
  8005f4:	ba 00 00 00 00       	mov    $0x0,%edx
  8005f9:	0f 49 d0             	cmovns %eax,%edx
  8005fc:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8005ff:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800602:	e9 69 ff ff ff       	jmp    800570 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800607:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  80060a:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  800611:	e9 5a ff ff ff       	jmp    800570 <vprintfmt+0x39>
  800616:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800619:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80061c:	eb bc                	jmp    8005da <vprintfmt+0xa3>
			lflag++;
  80061e:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800621:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800624:	e9 47 ff ff ff       	jmp    800570 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  800629:	8b 45 14             	mov    0x14(%ebp),%eax
  80062c:	8d 78 04             	lea    0x4(%eax),%edi
  80062f:	83 ec 08             	sub    $0x8,%esp
  800632:	53                   	push   %ebx
  800633:	ff 30                	pushl  (%eax)
  800635:	ff d6                	call   *%esi
			break;
  800637:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  80063a:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  80063d:	e9 da 02 00 00       	jmp    80091c <vprintfmt+0x3e5>
			err = va_arg(ap, int);
  800642:	8b 45 14             	mov    0x14(%ebp),%eax
  800645:	8d 78 04             	lea    0x4(%eax),%edi
  800648:	8b 00                	mov    (%eax),%eax
  80064a:	99                   	cltd   
  80064b:	31 d0                	xor    %edx,%eax
  80064d:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80064f:	83 f8 08             	cmp    $0x8,%eax
  800652:	7f 23                	jg     800677 <vprintfmt+0x140>
  800654:	8b 14 85 e0 12 80 00 	mov    0x8012e0(,%eax,4),%edx
  80065b:	85 d2                	test   %edx,%edx
  80065d:	74 18                	je     800677 <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  80065f:	52                   	push   %edx
  800660:	68 e8 10 80 00       	push   $0x8010e8
  800665:	53                   	push   %ebx
  800666:	56                   	push   %esi
  800667:	e8 aa fe ff ff       	call   800516 <printfmt>
  80066c:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80066f:	89 7d 14             	mov    %edi,0x14(%ebp)
  800672:	e9 a5 02 00 00       	jmp    80091c <vprintfmt+0x3e5>
				printfmt(putch, putdat, "error %d", err);
  800677:	50                   	push   %eax
  800678:	68 df 10 80 00       	push   $0x8010df
  80067d:	53                   	push   %ebx
  80067e:	56                   	push   %esi
  80067f:	e8 92 fe ff ff       	call   800516 <printfmt>
  800684:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800687:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80068a:	e9 8d 02 00 00       	jmp    80091c <vprintfmt+0x3e5>
			if ((p = va_arg(ap, char *)) == NULL)
  80068f:	8b 45 14             	mov    0x14(%ebp),%eax
  800692:	83 c0 04             	add    $0x4,%eax
  800695:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800698:	8b 45 14             	mov    0x14(%ebp),%eax
  80069b:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  80069d:	85 d2                	test   %edx,%edx
  80069f:	b8 d8 10 80 00       	mov    $0x8010d8,%eax
  8006a4:	0f 45 c2             	cmovne %edx,%eax
  8006a7:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8006aa:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006ae:	7e 06                	jle    8006b6 <vprintfmt+0x17f>
  8006b0:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  8006b4:	75 0d                	jne    8006c3 <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006b6:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8006b9:	89 c7                	mov    %eax,%edi
  8006bb:	03 45 e0             	add    -0x20(%ebp),%eax
  8006be:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006c1:	eb 55                	jmp    800718 <vprintfmt+0x1e1>
  8006c3:	83 ec 08             	sub    $0x8,%esp
  8006c6:	ff 75 d8             	pushl  -0x28(%ebp)
  8006c9:	ff 75 cc             	pushl  -0x34(%ebp)
  8006cc:	e8 85 03 00 00       	call   800a56 <strnlen>
  8006d1:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8006d4:	29 c2                	sub    %eax,%edx
  8006d6:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  8006d9:	83 c4 10             	add    $0x10,%esp
  8006dc:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  8006de:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8006e2:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8006e5:	85 ff                	test   %edi,%edi
  8006e7:	7e 11                	jle    8006fa <vprintfmt+0x1c3>
					putch(padc, putdat);
  8006e9:	83 ec 08             	sub    $0x8,%esp
  8006ec:	53                   	push   %ebx
  8006ed:	ff 75 e0             	pushl  -0x20(%ebp)
  8006f0:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8006f2:	83 ef 01             	sub    $0x1,%edi
  8006f5:	83 c4 10             	add    $0x10,%esp
  8006f8:	eb eb                	jmp    8006e5 <vprintfmt+0x1ae>
  8006fa:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8006fd:	85 d2                	test   %edx,%edx
  8006ff:	b8 00 00 00 00       	mov    $0x0,%eax
  800704:	0f 49 c2             	cmovns %edx,%eax
  800707:	29 c2                	sub    %eax,%edx
  800709:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80070c:	eb a8                	jmp    8006b6 <vprintfmt+0x17f>
					putch(ch, putdat);
  80070e:	83 ec 08             	sub    $0x8,%esp
  800711:	53                   	push   %ebx
  800712:	52                   	push   %edx
  800713:	ff d6                	call   *%esi
  800715:	83 c4 10             	add    $0x10,%esp
  800718:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80071b:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80071d:	83 c7 01             	add    $0x1,%edi
  800720:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800724:	0f be d0             	movsbl %al,%edx
  800727:	85 d2                	test   %edx,%edx
  800729:	74 4b                	je     800776 <vprintfmt+0x23f>
  80072b:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80072f:	78 06                	js     800737 <vprintfmt+0x200>
  800731:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800735:	78 1e                	js     800755 <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
  800737:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80073b:	74 d1                	je     80070e <vprintfmt+0x1d7>
  80073d:	0f be c0             	movsbl %al,%eax
  800740:	83 e8 20             	sub    $0x20,%eax
  800743:	83 f8 5e             	cmp    $0x5e,%eax
  800746:	76 c6                	jbe    80070e <vprintfmt+0x1d7>
					putch('?', putdat);
  800748:	83 ec 08             	sub    $0x8,%esp
  80074b:	53                   	push   %ebx
  80074c:	6a 3f                	push   $0x3f
  80074e:	ff d6                	call   *%esi
  800750:	83 c4 10             	add    $0x10,%esp
  800753:	eb c3                	jmp    800718 <vprintfmt+0x1e1>
  800755:	89 cf                	mov    %ecx,%edi
  800757:	eb 0e                	jmp    800767 <vprintfmt+0x230>
				putch(' ', putdat);
  800759:	83 ec 08             	sub    $0x8,%esp
  80075c:	53                   	push   %ebx
  80075d:	6a 20                	push   $0x20
  80075f:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800761:	83 ef 01             	sub    $0x1,%edi
  800764:	83 c4 10             	add    $0x10,%esp
  800767:	85 ff                	test   %edi,%edi
  800769:	7f ee                	jg     800759 <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  80076b:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80076e:	89 45 14             	mov    %eax,0x14(%ebp)
  800771:	e9 a6 01 00 00       	jmp    80091c <vprintfmt+0x3e5>
  800776:	89 cf                	mov    %ecx,%edi
  800778:	eb ed                	jmp    800767 <vprintfmt+0x230>
	if (lflag >= 2)
  80077a:	83 f9 01             	cmp    $0x1,%ecx
  80077d:	7f 1f                	jg     80079e <vprintfmt+0x267>
	else if (lflag)
  80077f:	85 c9                	test   %ecx,%ecx
  800781:	74 67                	je     8007ea <vprintfmt+0x2b3>
		return va_arg(*ap, long);
  800783:	8b 45 14             	mov    0x14(%ebp),%eax
  800786:	8b 00                	mov    (%eax),%eax
  800788:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80078b:	89 c1                	mov    %eax,%ecx
  80078d:	c1 f9 1f             	sar    $0x1f,%ecx
  800790:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800793:	8b 45 14             	mov    0x14(%ebp),%eax
  800796:	8d 40 04             	lea    0x4(%eax),%eax
  800799:	89 45 14             	mov    %eax,0x14(%ebp)
  80079c:	eb 17                	jmp    8007b5 <vprintfmt+0x27e>
		return va_arg(*ap, long long);
  80079e:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a1:	8b 50 04             	mov    0x4(%eax),%edx
  8007a4:	8b 00                	mov    (%eax),%eax
  8007a6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007a9:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8007af:	8d 40 08             	lea    0x8(%eax),%eax
  8007b2:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8007b5:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007b8:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8007bb:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  8007c0:	85 c9                	test   %ecx,%ecx
  8007c2:	0f 89 3a 01 00 00    	jns    800902 <vprintfmt+0x3cb>
				putch('-', putdat);
  8007c8:	83 ec 08             	sub    $0x8,%esp
  8007cb:	53                   	push   %ebx
  8007cc:	6a 2d                	push   $0x2d
  8007ce:	ff d6                	call   *%esi
				num = -(long long) num;
  8007d0:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007d3:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8007d6:	f7 da                	neg    %edx
  8007d8:	83 d1 00             	adc    $0x0,%ecx
  8007db:	f7 d9                	neg    %ecx
  8007dd:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8007e0:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007e5:	e9 18 01 00 00       	jmp    800902 <vprintfmt+0x3cb>
		return va_arg(*ap, int);
  8007ea:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ed:	8b 00                	mov    (%eax),%eax
  8007ef:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007f2:	89 c1                	mov    %eax,%ecx
  8007f4:	c1 f9 1f             	sar    $0x1f,%ecx
  8007f7:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8007fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8007fd:	8d 40 04             	lea    0x4(%eax),%eax
  800800:	89 45 14             	mov    %eax,0x14(%ebp)
  800803:	eb b0                	jmp    8007b5 <vprintfmt+0x27e>
	if (lflag >= 2)
  800805:	83 f9 01             	cmp    $0x1,%ecx
  800808:	7f 1e                	jg     800828 <vprintfmt+0x2f1>
	else if (lflag)
  80080a:	85 c9                	test   %ecx,%ecx
  80080c:	74 32                	je     800840 <vprintfmt+0x309>
		return va_arg(*ap, unsigned long);
  80080e:	8b 45 14             	mov    0x14(%ebp),%eax
  800811:	8b 10                	mov    (%eax),%edx
  800813:	b9 00 00 00 00       	mov    $0x0,%ecx
  800818:	8d 40 04             	lea    0x4(%eax),%eax
  80081b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80081e:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  800823:	e9 da 00 00 00       	jmp    800902 <vprintfmt+0x3cb>
		return va_arg(*ap, unsigned long long);
  800828:	8b 45 14             	mov    0x14(%ebp),%eax
  80082b:	8b 10                	mov    (%eax),%edx
  80082d:	8b 48 04             	mov    0x4(%eax),%ecx
  800830:	8d 40 08             	lea    0x8(%eax),%eax
  800833:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800836:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  80083b:	e9 c2 00 00 00       	jmp    800902 <vprintfmt+0x3cb>
		return va_arg(*ap, unsigned int);
  800840:	8b 45 14             	mov    0x14(%ebp),%eax
  800843:	8b 10                	mov    (%eax),%edx
  800845:	b9 00 00 00 00       	mov    $0x0,%ecx
  80084a:	8d 40 04             	lea    0x4(%eax),%eax
  80084d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800850:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  800855:	e9 a8 00 00 00       	jmp    800902 <vprintfmt+0x3cb>
	if (lflag >= 2)
  80085a:	83 f9 01             	cmp    $0x1,%ecx
  80085d:	7f 1b                	jg     80087a <vprintfmt+0x343>
	else if (lflag)
  80085f:	85 c9                	test   %ecx,%ecx
  800861:	74 5c                	je     8008bf <vprintfmt+0x388>
		return va_arg(*ap, long);
  800863:	8b 45 14             	mov    0x14(%ebp),%eax
  800866:	8b 00                	mov    (%eax),%eax
  800868:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80086b:	99                   	cltd   
  80086c:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80086f:	8b 45 14             	mov    0x14(%ebp),%eax
  800872:	8d 40 04             	lea    0x4(%eax),%eax
  800875:	89 45 14             	mov    %eax,0x14(%ebp)
  800878:	eb 17                	jmp    800891 <vprintfmt+0x35a>
		return va_arg(*ap, long long);
  80087a:	8b 45 14             	mov    0x14(%ebp),%eax
  80087d:	8b 50 04             	mov    0x4(%eax),%edx
  800880:	8b 00                	mov    (%eax),%eax
  800882:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800885:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800888:	8b 45 14             	mov    0x14(%ebp),%eax
  80088b:	8d 40 08             	lea    0x8(%eax),%eax
  80088e:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800891:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800894:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 8;
  800897:	b8 08 00 00 00       	mov    $0x8,%eax
			if ((long long) num < 0) {
  80089c:	85 c9                	test   %ecx,%ecx
  80089e:	79 62                	jns    800902 <vprintfmt+0x3cb>
				putch('-', putdat);
  8008a0:	83 ec 08             	sub    $0x8,%esp
  8008a3:	53                   	push   %ebx
  8008a4:	6a 2d                	push   $0x2d
  8008a6:	ff d6                	call   *%esi
				num = -(long long) num;
  8008a8:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8008ab:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8008ae:	f7 da                	neg    %edx
  8008b0:	83 d1 00             	adc    $0x0,%ecx
  8008b3:	f7 d9                	neg    %ecx
  8008b5:	83 c4 10             	add    $0x10,%esp
			base = 8;
  8008b8:	b8 08 00 00 00       	mov    $0x8,%eax
  8008bd:	eb 43                	jmp    800902 <vprintfmt+0x3cb>
		return va_arg(*ap, int);
  8008bf:	8b 45 14             	mov    0x14(%ebp),%eax
  8008c2:	8b 00                	mov    (%eax),%eax
  8008c4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8008c7:	89 c1                	mov    %eax,%ecx
  8008c9:	c1 f9 1f             	sar    $0x1f,%ecx
  8008cc:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8008cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8008d2:	8d 40 04             	lea    0x4(%eax),%eax
  8008d5:	89 45 14             	mov    %eax,0x14(%ebp)
  8008d8:	eb b7                	jmp    800891 <vprintfmt+0x35a>
			putch('0', putdat);
  8008da:	83 ec 08             	sub    $0x8,%esp
  8008dd:	53                   	push   %ebx
  8008de:	6a 30                	push   $0x30
  8008e0:	ff d6                	call   *%esi
			putch('x', putdat);
  8008e2:	83 c4 08             	add    $0x8,%esp
  8008e5:	53                   	push   %ebx
  8008e6:	6a 78                	push   $0x78
  8008e8:	ff d6                	call   *%esi
			num = (unsigned long long)
  8008ea:	8b 45 14             	mov    0x14(%ebp),%eax
  8008ed:	8b 10                	mov    (%eax),%edx
  8008ef:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8008f4:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8008f7:	8d 40 04             	lea    0x4(%eax),%eax
  8008fa:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8008fd:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  800902:	83 ec 0c             	sub    $0xc,%esp
  800905:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  800909:	57                   	push   %edi
  80090a:	ff 75 e0             	pushl  -0x20(%ebp)
  80090d:	50                   	push   %eax
  80090e:	51                   	push   %ecx
  80090f:	52                   	push   %edx
  800910:	89 da                	mov    %ebx,%edx
  800912:	89 f0                	mov    %esi,%eax
  800914:	e8 33 fb ff ff       	call   80044c <printnum>
			break;
  800919:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  80091c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80091f:	83 c7 01             	add    $0x1,%edi
  800922:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800926:	83 f8 25             	cmp    $0x25,%eax
  800929:	0f 84 23 fc ff ff    	je     800552 <vprintfmt+0x1b>
			if (ch == '\0')
  80092f:	85 c0                	test   %eax,%eax
  800931:	0f 84 8b 00 00 00    	je     8009c2 <vprintfmt+0x48b>
			putch(ch, putdat);
  800937:	83 ec 08             	sub    $0x8,%esp
  80093a:	53                   	push   %ebx
  80093b:	50                   	push   %eax
  80093c:	ff d6                	call   *%esi
  80093e:	83 c4 10             	add    $0x10,%esp
  800941:	eb dc                	jmp    80091f <vprintfmt+0x3e8>
	if (lflag >= 2)
  800943:	83 f9 01             	cmp    $0x1,%ecx
  800946:	7f 1b                	jg     800963 <vprintfmt+0x42c>
	else if (lflag)
  800948:	85 c9                	test   %ecx,%ecx
  80094a:	74 2c                	je     800978 <vprintfmt+0x441>
		return va_arg(*ap, unsigned long);
  80094c:	8b 45 14             	mov    0x14(%ebp),%eax
  80094f:	8b 10                	mov    (%eax),%edx
  800951:	b9 00 00 00 00       	mov    $0x0,%ecx
  800956:	8d 40 04             	lea    0x4(%eax),%eax
  800959:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80095c:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  800961:	eb 9f                	jmp    800902 <vprintfmt+0x3cb>
		return va_arg(*ap, unsigned long long);
  800963:	8b 45 14             	mov    0x14(%ebp),%eax
  800966:	8b 10                	mov    (%eax),%edx
  800968:	8b 48 04             	mov    0x4(%eax),%ecx
  80096b:	8d 40 08             	lea    0x8(%eax),%eax
  80096e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800971:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  800976:	eb 8a                	jmp    800902 <vprintfmt+0x3cb>
		return va_arg(*ap, unsigned int);
  800978:	8b 45 14             	mov    0x14(%ebp),%eax
  80097b:	8b 10                	mov    (%eax),%edx
  80097d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800982:	8d 40 04             	lea    0x4(%eax),%eax
  800985:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800988:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  80098d:	e9 70 ff ff ff       	jmp    800902 <vprintfmt+0x3cb>
			putch(ch, putdat);
  800992:	83 ec 08             	sub    $0x8,%esp
  800995:	53                   	push   %ebx
  800996:	6a 25                	push   $0x25
  800998:	ff d6                	call   *%esi
			break;
  80099a:	83 c4 10             	add    $0x10,%esp
  80099d:	e9 7a ff ff ff       	jmp    80091c <vprintfmt+0x3e5>
			putch('%', putdat);
  8009a2:	83 ec 08             	sub    $0x8,%esp
  8009a5:	53                   	push   %ebx
  8009a6:	6a 25                	push   $0x25
  8009a8:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8009aa:	83 c4 10             	add    $0x10,%esp
  8009ad:	89 f8                	mov    %edi,%eax
  8009af:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8009b3:	74 05                	je     8009ba <vprintfmt+0x483>
  8009b5:	83 e8 01             	sub    $0x1,%eax
  8009b8:	eb f5                	jmp    8009af <vprintfmt+0x478>
  8009ba:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8009bd:	e9 5a ff ff ff       	jmp    80091c <vprintfmt+0x3e5>
}
  8009c2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8009c5:	5b                   	pop    %ebx
  8009c6:	5e                   	pop    %esi
  8009c7:	5f                   	pop    %edi
  8009c8:	5d                   	pop    %ebp
  8009c9:	c3                   	ret    

008009ca <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8009ca:	f3 0f 1e fb          	endbr32 
  8009ce:	55                   	push   %ebp
  8009cf:	89 e5                	mov    %esp,%ebp
  8009d1:	83 ec 18             	sub    $0x18,%esp
  8009d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d7:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8009da:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8009dd:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8009e1:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8009e4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8009eb:	85 c0                	test   %eax,%eax
  8009ed:	74 26                	je     800a15 <vsnprintf+0x4b>
  8009ef:	85 d2                	test   %edx,%edx
  8009f1:	7e 22                	jle    800a15 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8009f3:	ff 75 14             	pushl  0x14(%ebp)
  8009f6:	ff 75 10             	pushl  0x10(%ebp)
  8009f9:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8009fc:	50                   	push   %eax
  8009fd:	68 f5 04 80 00       	push   $0x8004f5
  800a02:	e8 30 fb ff ff       	call   800537 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800a07:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800a0a:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800a0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800a10:	83 c4 10             	add    $0x10,%esp
}
  800a13:	c9                   	leave  
  800a14:	c3                   	ret    
		return -E_INVAL;
  800a15:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800a1a:	eb f7                	jmp    800a13 <vsnprintf+0x49>

00800a1c <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800a1c:	f3 0f 1e fb          	endbr32 
  800a20:	55                   	push   %ebp
  800a21:	89 e5                	mov    %esp,%ebp
  800a23:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800a26:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800a29:	50                   	push   %eax
  800a2a:	ff 75 10             	pushl  0x10(%ebp)
  800a2d:	ff 75 0c             	pushl  0xc(%ebp)
  800a30:	ff 75 08             	pushl  0x8(%ebp)
  800a33:	e8 92 ff ff ff       	call   8009ca <vsnprintf>
	va_end(ap);

	return rc;
}
  800a38:	c9                   	leave  
  800a39:	c3                   	ret    

00800a3a <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800a3a:	f3 0f 1e fb          	endbr32 
  800a3e:	55                   	push   %ebp
  800a3f:	89 e5                	mov    %esp,%ebp
  800a41:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a44:	b8 00 00 00 00       	mov    $0x0,%eax
  800a49:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a4d:	74 05                	je     800a54 <strlen+0x1a>
		n++;
  800a4f:	83 c0 01             	add    $0x1,%eax
  800a52:	eb f5                	jmp    800a49 <strlen+0xf>
	return n;
}
  800a54:	5d                   	pop    %ebp
  800a55:	c3                   	ret    

00800a56 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a56:	f3 0f 1e fb          	endbr32 
  800a5a:	55                   	push   %ebp
  800a5b:	89 e5                	mov    %esp,%ebp
  800a5d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a60:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a63:	b8 00 00 00 00       	mov    $0x0,%eax
  800a68:	39 d0                	cmp    %edx,%eax
  800a6a:	74 0d                	je     800a79 <strnlen+0x23>
  800a6c:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800a70:	74 05                	je     800a77 <strnlen+0x21>
		n++;
  800a72:	83 c0 01             	add    $0x1,%eax
  800a75:	eb f1                	jmp    800a68 <strnlen+0x12>
  800a77:	89 c2                	mov    %eax,%edx
	return n;
}
  800a79:	89 d0                	mov    %edx,%eax
  800a7b:	5d                   	pop    %ebp
  800a7c:	c3                   	ret    

00800a7d <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a7d:	f3 0f 1e fb          	endbr32 
  800a81:	55                   	push   %ebp
  800a82:	89 e5                	mov    %esp,%ebp
  800a84:	53                   	push   %ebx
  800a85:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a88:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a8b:	b8 00 00 00 00       	mov    $0x0,%eax
  800a90:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800a94:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800a97:	83 c0 01             	add    $0x1,%eax
  800a9a:	84 d2                	test   %dl,%dl
  800a9c:	75 f2                	jne    800a90 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  800a9e:	89 c8                	mov    %ecx,%eax
  800aa0:	5b                   	pop    %ebx
  800aa1:	5d                   	pop    %ebp
  800aa2:	c3                   	ret    

00800aa3 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800aa3:	f3 0f 1e fb          	endbr32 
  800aa7:	55                   	push   %ebp
  800aa8:	89 e5                	mov    %esp,%ebp
  800aaa:	53                   	push   %ebx
  800aab:	83 ec 10             	sub    $0x10,%esp
  800aae:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800ab1:	53                   	push   %ebx
  800ab2:	e8 83 ff ff ff       	call   800a3a <strlen>
  800ab7:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800aba:	ff 75 0c             	pushl  0xc(%ebp)
  800abd:	01 d8                	add    %ebx,%eax
  800abf:	50                   	push   %eax
  800ac0:	e8 b8 ff ff ff       	call   800a7d <strcpy>
	return dst;
}
  800ac5:	89 d8                	mov    %ebx,%eax
  800ac7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800aca:	c9                   	leave  
  800acb:	c3                   	ret    

00800acc <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800acc:	f3 0f 1e fb          	endbr32 
  800ad0:	55                   	push   %ebp
  800ad1:	89 e5                	mov    %esp,%ebp
  800ad3:	56                   	push   %esi
  800ad4:	53                   	push   %ebx
  800ad5:	8b 75 08             	mov    0x8(%ebp),%esi
  800ad8:	8b 55 0c             	mov    0xc(%ebp),%edx
  800adb:	89 f3                	mov    %esi,%ebx
  800add:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800ae0:	89 f0                	mov    %esi,%eax
  800ae2:	39 d8                	cmp    %ebx,%eax
  800ae4:	74 11                	je     800af7 <strncpy+0x2b>
		*dst++ = *src;
  800ae6:	83 c0 01             	add    $0x1,%eax
  800ae9:	0f b6 0a             	movzbl (%edx),%ecx
  800aec:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800aef:	80 f9 01             	cmp    $0x1,%cl
  800af2:	83 da ff             	sbb    $0xffffffff,%edx
  800af5:	eb eb                	jmp    800ae2 <strncpy+0x16>
	}
	return ret;
}
  800af7:	89 f0                	mov    %esi,%eax
  800af9:	5b                   	pop    %ebx
  800afa:	5e                   	pop    %esi
  800afb:	5d                   	pop    %ebp
  800afc:	c3                   	ret    

00800afd <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800afd:	f3 0f 1e fb          	endbr32 
  800b01:	55                   	push   %ebp
  800b02:	89 e5                	mov    %esp,%ebp
  800b04:	56                   	push   %esi
  800b05:	53                   	push   %ebx
  800b06:	8b 75 08             	mov    0x8(%ebp),%esi
  800b09:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b0c:	8b 55 10             	mov    0x10(%ebp),%edx
  800b0f:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800b11:	85 d2                	test   %edx,%edx
  800b13:	74 21                	je     800b36 <strlcpy+0x39>
  800b15:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800b19:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  800b1b:	39 c2                	cmp    %eax,%edx
  800b1d:	74 14                	je     800b33 <strlcpy+0x36>
  800b1f:	0f b6 19             	movzbl (%ecx),%ebx
  800b22:	84 db                	test   %bl,%bl
  800b24:	74 0b                	je     800b31 <strlcpy+0x34>
			*dst++ = *src++;
  800b26:	83 c1 01             	add    $0x1,%ecx
  800b29:	83 c2 01             	add    $0x1,%edx
  800b2c:	88 5a ff             	mov    %bl,-0x1(%edx)
  800b2f:	eb ea                	jmp    800b1b <strlcpy+0x1e>
  800b31:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800b33:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800b36:	29 f0                	sub    %esi,%eax
}
  800b38:	5b                   	pop    %ebx
  800b39:	5e                   	pop    %esi
  800b3a:	5d                   	pop    %ebp
  800b3b:	c3                   	ret    

00800b3c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800b3c:	f3 0f 1e fb          	endbr32 
  800b40:	55                   	push   %ebp
  800b41:	89 e5                	mov    %esp,%ebp
  800b43:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b46:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800b49:	0f b6 01             	movzbl (%ecx),%eax
  800b4c:	84 c0                	test   %al,%al
  800b4e:	74 0c                	je     800b5c <strcmp+0x20>
  800b50:	3a 02                	cmp    (%edx),%al
  800b52:	75 08                	jne    800b5c <strcmp+0x20>
		p++, q++;
  800b54:	83 c1 01             	add    $0x1,%ecx
  800b57:	83 c2 01             	add    $0x1,%edx
  800b5a:	eb ed                	jmp    800b49 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800b5c:	0f b6 c0             	movzbl %al,%eax
  800b5f:	0f b6 12             	movzbl (%edx),%edx
  800b62:	29 d0                	sub    %edx,%eax
}
  800b64:	5d                   	pop    %ebp
  800b65:	c3                   	ret    

00800b66 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b66:	f3 0f 1e fb          	endbr32 
  800b6a:	55                   	push   %ebp
  800b6b:	89 e5                	mov    %esp,%ebp
  800b6d:	53                   	push   %ebx
  800b6e:	8b 45 08             	mov    0x8(%ebp),%eax
  800b71:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b74:	89 c3                	mov    %eax,%ebx
  800b76:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800b79:	eb 06                	jmp    800b81 <strncmp+0x1b>
		n--, p++, q++;
  800b7b:	83 c0 01             	add    $0x1,%eax
  800b7e:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800b81:	39 d8                	cmp    %ebx,%eax
  800b83:	74 16                	je     800b9b <strncmp+0x35>
  800b85:	0f b6 08             	movzbl (%eax),%ecx
  800b88:	84 c9                	test   %cl,%cl
  800b8a:	74 04                	je     800b90 <strncmp+0x2a>
  800b8c:	3a 0a                	cmp    (%edx),%cl
  800b8e:	74 eb                	je     800b7b <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b90:	0f b6 00             	movzbl (%eax),%eax
  800b93:	0f b6 12             	movzbl (%edx),%edx
  800b96:	29 d0                	sub    %edx,%eax
}
  800b98:	5b                   	pop    %ebx
  800b99:	5d                   	pop    %ebp
  800b9a:	c3                   	ret    
		return 0;
  800b9b:	b8 00 00 00 00       	mov    $0x0,%eax
  800ba0:	eb f6                	jmp    800b98 <strncmp+0x32>

00800ba2 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800ba2:	f3 0f 1e fb          	endbr32 
  800ba6:	55                   	push   %ebp
  800ba7:	89 e5                	mov    %esp,%ebp
  800ba9:	8b 45 08             	mov    0x8(%ebp),%eax
  800bac:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800bb0:	0f b6 10             	movzbl (%eax),%edx
  800bb3:	84 d2                	test   %dl,%dl
  800bb5:	74 09                	je     800bc0 <strchr+0x1e>
		if (*s == c)
  800bb7:	38 ca                	cmp    %cl,%dl
  800bb9:	74 0a                	je     800bc5 <strchr+0x23>
	for (; *s; s++)
  800bbb:	83 c0 01             	add    $0x1,%eax
  800bbe:	eb f0                	jmp    800bb0 <strchr+0xe>
			return (char *) s;
	return 0;
  800bc0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bc5:	5d                   	pop    %ebp
  800bc6:	c3                   	ret    

00800bc7 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800bc7:	f3 0f 1e fb          	endbr32 
  800bcb:	55                   	push   %ebp
  800bcc:	89 e5                	mov    %esp,%ebp
  800bce:	8b 45 08             	mov    0x8(%ebp),%eax
  800bd1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800bd5:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800bd8:	38 ca                	cmp    %cl,%dl
  800bda:	74 09                	je     800be5 <strfind+0x1e>
  800bdc:	84 d2                	test   %dl,%dl
  800bde:	74 05                	je     800be5 <strfind+0x1e>
	for (; *s; s++)
  800be0:	83 c0 01             	add    $0x1,%eax
  800be3:	eb f0                	jmp    800bd5 <strfind+0xe>
			break;
	return (char *) s;
}
  800be5:	5d                   	pop    %ebp
  800be6:	c3                   	ret    

00800be7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800be7:	f3 0f 1e fb          	endbr32 
  800beb:	55                   	push   %ebp
  800bec:	89 e5                	mov    %esp,%ebp
  800bee:	57                   	push   %edi
  800bef:	56                   	push   %esi
  800bf0:	53                   	push   %ebx
  800bf1:	8b 7d 08             	mov    0x8(%ebp),%edi
  800bf4:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800bf7:	85 c9                	test   %ecx,%ecx
  800bf9:	74 31                	je     800c2c <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800bfb:	89 f8                	mov    %edi,%eax
  800bfd:	09 c8                	or     %ecx,%eax
  800bff:	a8 03                	test   $0x3,%al
  800c01:	75 23                	jne    800c26 <memset+0x3f>
		c &= 0xFF;
  800c03:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800c07:	89 d3                	mov    %edx,%ebx
  800c09:	c1 e3 08             	shl    $0x8,%ebx
  800c0c:	89 d0                	mov    %edx,%eax
  800c0e:	c1 e0 18             	shl    $0x18,%eax
  800c11:	89 d6                	mov    %edx,%esi
  800c13:	c1 e6 10             	shl    $0x10,%esi
  800c16:	09 f0                	or     %esi,%eax
  800c18:	09 c2                	or     %eax,%edx
  800c1a:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800c1c:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800c1f:	89 d0                	mov    %edx,%eax
  800c21:	fc                   	cld    
  800c22:	f3 ab                	rep stos %eax,%es:(%edi)
  800c24:	eb 06                	jmp    800c2c <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800c26:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c29:	fc                   	cld    
  800c2a:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800c2c:	89 f8                	mov    %edi,%eax
  800c2e:	5b                   	pop    %ebx
  800c2f:	5e                   	pop    %esi
  800c30:	5f                   	pop    %edi
  800c31:	5d                   	pop    %ebp
  800c32:	c3                   	ret    

00800c33 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800c33:	f3 0f 1e fb          	endbr32 
  800c37:	55                   	push   %ebp
  800c38:	89 e5                	mov    %esp,%ebp
  800c3a:	57                   	push   %edi
  800c3b:	56                   	push   %esi
  800c3c:	8b 45 08             	mov    0x8(%ebp),%eax
  800c3f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c42:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800c45:	39 c6                	cmp    %eax,%esi
  800c47:	73 32                	jae    800c7b <memmove+0x48>
  800c49:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c4c:	39 c2                	cmp    %eax,%edx
  800c4e:	76 2b                	jbe    800c7b <memmove+0x48>
		s += n;
		d += n;
  800c50:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c53:	89 fe                	mov    %edi,%esi
  800c55:	09 ce                	or     %ecx,%esi
  800c57:	09 d6                	or     %edx,%esi
  800c59:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c5f:	75 0e                	jne    800c6f <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800c61:	83 ef 04             	sub    $0x4,%edi
  800c64:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c67:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800c6a:	fd                   	std    
  800c6b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c6d:	eb 09                	jmp    800c78 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800c6f:	83 ef 01             	sub    $0x1,%edi
  800c72:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800c75:	fd                   	std    
  800c76:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c78:	fc                   	cld    
  800c79:	eb 1a                	jmp    800c95 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c7b:	89 c2                	mov    %eax,%edx
  800c7d:	09 ca                	or     %ecx,%edx
  800c7f:	09 f2                	or     %esi,%edx
  800c81:	f6 c2 03             	test   $0x3,%dl
  800c84:	75 0a                	jne    800c90 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800c86:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800c89:	89 c7                	mov    %eax,%edi
  800c8b:	fc                   	cld    
  800c8c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c8e:	eb 05                	jmp    800c95 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800c90:	89 c7                	mov    %eax,%edi
  800c92:	fc                   	cld    
  800c93:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c95:	5e                   	pop    %esi
  800c96:	5f                   	pop    %edi
  800c97:	5d                   	pop    %ebp
  800c98:	c3                   	ret    

00800c99 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c99:	f3 0f 1e fb          	endbr32 
  800c9d:	55                   	push   %ebp
  800c9e:	89 e5                	mov    %esp,%ebp
  800ca0:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800ca3:	ff 75 10             	pushl  0x10(%ebp)
  800ca6:	ff 75 0c             	pushl  0xc(%ebp)
  800ca9:	ff 75 08             	pushl  0x8(%ebp)
  800cac:	e8 82 ff ff ff       	call   800c33 <memmove>
}
  800cb1:	c9                   	leave  
  800cb2:	c3                   	ret    

00800cb3 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800cb3:	f3 0f 1e fb          	endbr32 
  800cb7:	55                   	push   %ebp
  800cb8:	89 e5                	mov    %esp,%ebp
  800cba:	56                   	push   %esi
  800cbb:	53                   	push   %ebx
  800cbc:	8b 45 08             	mov    0x8(%ebp),%eax
  800cbf:	8b 55 0c             	mov    0xc(%ebp),%edx
  800cc2:	89 c6                	mov    %eax,%esi
  800cc4:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800cc7:	39 f0                	cmp    %esi,%eax
  800cc9:	74 1c                	je     800ce7 <memcmp+0x34>
		if (*s1 != *s2)
  800ccb:	0f b6 08             	movzbl (%eax),%ecx
  800cce:	0f b6 1a             	movzbl (%edx),%ebx
  800cd1:	38 d9                	cmp    %bl,%cl
  800cd3:	75 08                	jne    800cdd <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800cd5:	83 c0 01             	add    $0x1,%eax
  800cd8:	83 c2 01             	add    $0x1,%edx
  800cdb:	eb ea                	jmp    800cc7 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800cdd:	0f b6 c1             	movzbl %cl,%eax
  800ce0:	0f b6 db             	movzbl %bl,%ebx
  800ce3:	29 d8                	sub    %ebx,%eax
  800ce5:	eb 05                	jmp    800cec <memcmp+0x39>
	}

	return 0;
  800ce7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800cec:	5b                   	pop    %ebx
  800ced:	5e                   	pop    %esi
  800cee:	5d                   	pop    %ebp
  800cef:	c3                   	ret    

00800cf0 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800cf0:	f3 0f 1e fb          	endbr32 
  800cf4:	55                   	push   %ebp
  800cf5:	89 e5                	mov    %esp,%ebp
  800cf7:	8b 45 08             	mov    0x8(%ebp),%eax
  800cfa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800cfd:	89 c2                	mov    %eax,%edx
  800cff:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800d02:	39 d0                	cmp    %edx,%eax
  800d04:	73 09                	jae    800d0f <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d06:	38 08                	cmp    %cl,(%eax)
  800d08:	74 05                	je     800d0f <memfind+0x1f>
	for (; s < ends; s++)
  800d0a:	83 c0 01             	add    $0x1,%eax
  800d0d:	eb f3                	jmp    800d02 <memfind+0x12>
			break;
	return (void *) s;
}
  800d0f:	5d                   	pop    %ebp
  800d10:	c3                   	ret    

00800d11 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800d11:	f3 0f 1e fb          	endbr32 
  800d15:	55                   	push   %ebp
  800d16:	89 e5                	mov    %esp,%ebp
  800d18:	57                   	push   %edi
  800d19:	56                   	push   %esi
  800d1a:	53                   	push   %ebx
  800d1b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d1e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d21:	eb 03                	jmp    800d26 <strtol+0x15>
		s++;
  800d23:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800d26:	0f b6 01             	movzbl (%ecx),%eax
  800d29:	3c 20                	cmp    $0x20,%al
  800d2b:	74 f6                	je     800d23 <strtol+0x12>
  800d2d:	3c 09                	cmp    $0x9,%al
  800d2f:	74 f2                	je     800d23 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800d31:	3c 2b                	cmp    $0x2b,%al
  800d33:	74 2a                	je     800d5f <strtol+0x4e>
	int neg = 0;
  800d35:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800d3a:	3c 2d                	cmp    $0x2d,%al
  800d3c:	74 2b                	je     800d69 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d3e:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800d44:	75 0f                	jne    800d55 <strtol+0x44>
  800d46:	80 39 30             	cmpb   $0x30,(%ecx)
  800d49:	74 28                	je     800d73 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800d4b:	85 db                	test   %ebx,%ebx
  800d4d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d52:	0f 44 d8             	cmove  %eax,%ebx
  800d55:	b8 00 00 00 00       	mov    $0x0,%eax
  800d5a:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800d5d:	eb 46                	jmp    800da5 <strtol+0x94>
		s++;
  800d5f:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800d62:	bf 00 00 00 00       	mov    $0x0,%edi
  800d67:	eb d5                	jmp    800d3e <strtol+0x2d>
		s++, neg = 1;
  800d69:	83 c1 01             	add    $0x1,%ecx
  800d6c:	bf 01 00 00 00       	mov    $0x1,%edi
  800d71:	eb cb                	jmp    800d3e <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d73:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800d77:	74 0e                	je     800d87 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800d79:	85 db                	test   %ebx,%ebx
  800d7b:	75 d8                	jne    800d55 <strtol+0x44>
		s++, base = 8;
  800d7d:	83 c1 01             	add    $0x1,%ecx
  800d80:	bb 08 00 00 00       	mov    $0x8,%ebx
  800d85:	eb ce                	jmp    800d55 <strtol+0x44>
		s += 2, base = 16;
  800d87:	83 c1 02             	add    $0x2,%ecx
  800d8a:	bb 10 00 00 00       	mov    $0x10,%ebx
  800d8f:	eb c4                	jmp    800d55 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800d91:	0f be d2             	movsbl %dl,%edx
  800d94:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800d97:	3b 55 10             	cmp    0x10(%ebp),%edx
  800d9a:	7d 3a                	jge    800dd6 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800d9c:	83 c1 01             	add    $0x1,%ecx
  800d9f:	0f af 45 10          	imul   0x10(%ebp),%eax
  800da3:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800da5:	0f b6 11             	movzbl (%ecx),%edx
  800da8:	8d 72 d0             	lea    -0x30(%edx),%esi
  800dab:	89 f3                	mov    %esi,%ebx
  800dad:	80 fb 09             	cmp    $0x9,%bl
  800db0:	76 df                	jbe    800d91 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800db2:	8d 72 9f             	lea    -0x61(%edx),%esi
  800db5:	89 f3                	mov    %esi,%ebx
  800db7:	80 fb 19             	cmp    $0x19,%bl
  800dba:	77 08                	ja     800dc4 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800dbc:	0f be d2             	movsbl %dl,%edx
  800dbf:	83 ea 57             	sub    $0x57,%edx
  800dc2:	eb d3                	jmp    800d97 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800dc4:	8d 72 bf             	lea    -0x41(%edx),%esi
  800dc7:	89 f3                	mov    %esi,%ebx
  800dc9:	80 fb 19             	cmp    $0x19,%bl
  800dcc:	77 08                	ja     800dd6 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800dce:	0f be d2             	movsbl %dl,%edx
  800dd1:	83 ea 37             	sub    $0x37,%edx
  800dd4:	eb c1                	jmp    800d97 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800dd6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800dda:	74 05                	je     800de1 <strtol+0xd0>
		*endptr = (char *) s;
  800ddc:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ddf:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800de1:	89 c2                	mov    %eax,%edx
  800de3:	f7 da                	neg    %edx
  800de5:	85 ff                	test   %edi,%edi
  800de7:	0f 45 c2             	cmovne %edx,%eax
}
  800dea:	5b                   	pop    %ebx
  800deb:	5e                   	pop    %esi
  800dec:	5f                   	pop    %edi
  800ded:	5d                   	pop    %ebp
  800dee:	c3                   	ret    
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
