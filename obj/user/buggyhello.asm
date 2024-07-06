
obj/user/buggyhello:     file format elf32-i386


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
  80002c:	e8 1a 00 00 00       	call   80004b <libmain>
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
	sys_cputs((char*)1, 1);
  80003d:	6a 01                	push   $0x1
  80003f:	6a 01                	push   $0x1
  800041:	e8 65 00 00 00       	call   8000ab <sys_cputs>
}
  800046:	83 c4 10             	add    $0x10,%esp
  800049:	c9                   	leave  
  80004a:	c3                   	ret    

0080004b <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80004b:	f3 0f 1e fb          	endbr32 
  80004f:	55                   	push   %ebp
  800050:	89 e5                	mov    %esp,%ebp
  800052:	56                   	push   %esi
  800053:	53                   	push   %ebx
  800054:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800057:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv=&envs[ENVX(sys_getenvid())];
  80005a:	e8 d6 00 00 00       	call   800135 <sys_getenvid>
  80005f:	25 ff 03 00 00       	and    $0x3ff,%eax
  800064:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800067:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80006c:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800071:	85 db                	test   %ebx,%ebx
  800073:	7e 07                	jle    80007c <libmain+0x31>
		binaryname = argv[0];
  800075:	8b 06                	mov    (%esi),%eax
  800077:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80007c:	83 ec 08             	sub    $0x8,%esp
  80007f:	56                   	push   %esi
  800080:	53                   	push   %ebx
  800081:	e8 ad ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800086:	e8 0a 00 00 00       	call   800095 <exit>
}
  80008b:	83 c4 10             	add    $0x10,%esp
  80008e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800091:	5b                   	pop    %ebx
  800092:	5e                   	pop    %esi
  800093:	5d                   	pop    %ebp
  800094:	c3                   	ret    

00800095 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800095:	f3 0f 1e fb          	endbr32 
  800099:	55                   	push   %ebp
  80009a:	89 e5                	mov    %esp,%ebp
  80009c:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80009f:	6a 00                	push   $0x0
  8000a1:	e8 4a 00 00 00       	call   8000f0 <sys_env_destroy>
}
  8000a6:	83 c4 10             	add    $0x10,%esp
  8000a9:	c9                   	leave  
  8000aa:	c3                   	ret    

008000ab <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000ab:	f3 0f 1e fb          	endbr32 
  8000af:	55                   	push   %ebp
  8000b0:	89 e5                	mov    %esp,%ebp
  8000b2:	57                   	push   %edi
  8000b3:	56                   	push   %esi
  8000b4:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000b5:	b8 00 00 00 00       	mov    $0x0,%eax
  8000ba:	8b 55 08             	mov    0x8(%ebp),%edx
  8000bd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000c0:	89 c3                	mov    %eax,%ebx
  8000c2:	89 c7                	mov    %eax,%edi
  8000c4:	89 c6                	mov    %eax,%esi
  8000c6:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000c8:	5b                   	pop    %ebx
  8000c9:	5e                   	pop    %esi
  8000ca:	5f                   	pop    %edi
  8000cb:	5d                   	pop    %ebp
  8000cc:	c3                   	ret    

008000cd <sys_cgetc>:

int
sys_cgetc(void)
{
  8000cd:	f3 0f 1e fb          	endbr32 
  8000d1:	55                   	push   %ebp
  8000d2:	89 e5                	mov    %esp,%ebp
  8000d4:	57                   	push   %edi
  8000d5:	56                   	push   %esi
  8000d6:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000d7:	ba 00 00 00 00       	mov    $0x0,%edx
  8000dc:	b8 01 00 00 00       	mov    $0x1,%eax
  8000e1:	89 d1                	mov    %edx,%ecx
  8000e3:	89 d3                	mov    %edx,%ebx
  8000e5:	89 d7                	mov    %edx,%edi
  8000e7:	89 d6                	mov    %edx,%esi
  8000e9:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000eb:	5b                   	pop    %ebx
  8000ec:	5e                   	pop    %esi
  8000ed:	5f                   	pop    %edi
  8000ee:	5d                   	pop    %ebp
  8000ef:	c3                   	ret    

008000f0 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000f0:	f3 0f 1e fb          	endbr32 
  8000f4:	55                   	push   %ebp
  8000f5:	89 e5                	mov    %esp,%ebp
  8000f7:	57                   	push   %edi
  8000f8:	56                   	push   %esi
  8000f9:	53                   	push   %ebx
  8000fa:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8000fd:	b9 00 00 00 00       	mov    $0x0,%ecx
  800102:	8b 55 08             	mov    0x8(%ebp),%edx
  800105:	b8 03 00 00 00       	mov    $0x3,%eax
  80010a:	89 cb                	mov    %ecx,%ebx
  80010c:	89 cf                	mov    %ecx,%edi
  80010e:	89 ce                	mov    %ecx,%esi
  800110:	cd 30                	int    $0x30
	if(check && ret > 0)
  800112:	85 c0                	test   %eax,%eax
  800114:	7f 08                	jg     80011e <sys_env_destroy+0x2e>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800116:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800119:	5b                   	pop    %ebx
  80011a:	5e                   	pop    %esi
  80011b:	5f                   	pop    %edi
  80011c:	5d                   	pop    %ebp
  80011d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80011e:	83 ec 0c             	sub    $0xc,%esp
  800121:	50                   	push   %eax
  800122:	6a 03                	push   $0x3
  800124:	68 6a 10 80 00       	push   $0x80106a
  800129:	6a 23                	push   $0x23
  80012b:	68 87 10 80 00       	push   $0x801087
  800130:	e8 11 02 00 00       	call   800346 <_panic>

00800135 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800135:	f3 0f 1e fb          	endbr32 
  800139:	55                   	push   %ebp
  80013a:	89 e5                	mov    %esp,%ebp
  80013c:	57                   	push   %edi
  80013d:	56                   	push   %esi
  80013e:	53                   	push   %ebx
	asm volatile("int %1\n"
  80013f:	ba 00 00 00 00       	mov    $0x0,%edx
  800144:	b8 02 00 00 00       	mov    $0x2,%eax
  800149:	89 d1                	mov    %edx,%ecx
  80014b:	89 d3                	mov    %edx,%ebx
  80014d:	89 d7                	mov    %edx,%edi
  80014f:	89 d6                	mov    %edx,%esi
  800151:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800153:	5b                   	pop    %ebx
  800154:	5e                   	pop    %esi
  800155:	5f                   	pop    %edi
  800156:	5d                   	pop    %ebp
  800157:	c3                   	ret    

00800158 <sys_yield>:

void
sys_yield(void)
{
  800158:	f3 0f 1e fb          	endbr32 
  80015c:	55                   	push   %ebp
  80015d:	89 e5                	mov    %esp,%ebp
  80015f:	57                   	push   %edi
  800160:	56                   	push   %esi
  800161:	53                   	push   %ebx
	asm volatile("int %1\n"
  800162:	ba 00 00 00 00       	mov    $0x0,%edx
  800167:	b8 0a 00 00 00       	mov    $0xa,%eax
  80016c:	89 d1                	mov    %edx,%ecx
  80016e:	89 d3                	mov    %edx,%ebx
  800170:	89 d7                	mov    %edx,%edi
  800172:	89 d6                	mov    %edx,%esi
  800174:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800176:	5b                   	pop    %ebx
  800177:	5e                   	pop    %esi
  800178:	5f                   	pop    %edi
  800179:	5d                   	pop    %ebp
  80017a:	c3                   	ret    

0080017b <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80017b:	f3 0f 1e fb          	endbr32 
  80017f:	55                   	push   %ebp
  800180:	89 e5                	mov    %esp,%ebp
  800182:	57                   	push   %edi
  800183:	56                   	push   %esi
  800184:	53                   	push   %ebx
  800185:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800188:	be 00 00 00 00       	mov    $0x0,%esi
  80018d:	8b 55 08             	mov    0x8(%ebp),%edx
  800190:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800193:	b8 04 00 00 00       	mov    $0x4,%eax
  800198:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80019b:	89 f7                	mov    %esi,%edi
  80019d:	cd 30                	int    $0x30
	if(check && ret > 0)
  80019f:	85 c0                	test   %eax,%eax
  8001a1:	7f 08                	jg     8001ab <sys_page_alloc+0x30>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001a3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001a6:	5b                   	pop    %ebx
  8001a7:	5e                   	pop    %esi
  8001a8:	5f                   	pop    %edi
  8001a9:	5d                   	pop    %ebp
  8001aa:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8001ab:	83 ec 0c             	sub    $0xc,%esp
  8001ae:	50                   	push   %eax
  8001af:	6a 04                	push   $0x4
  8001b1:	68 6a 10 80 00       	push   $0x80106a
  8001b6:	6a 23                	push   $0x23
  8001b8:	68 87 10 80 00       	push   $0x801087
  8001bd:	e8 84 01 00 00       	call   800346 <_panic>

008001c2 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001c2:	f3 0f 1e fb          	endbr32 
  8001c6:	55                   	push   %ebp
  8001c7:	89 e5                	mov    %esp,%ebp
  8001c9:	57                   	push   %edi
  8001ca:	56                   	push   %esi
  8001cb:	53                   	push   %ebx
  8001cc:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001cf:	8b 55 08             	mov    0x8(%ebp),%edx
  8001d2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001d5:	b8 05 00 00 00       	mov    $0x5,%eax
  8001da:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001dd:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001e0:	8b 75 18             	mov    0x18(%ebp),%esi
  8001e3:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001e5:	85 c0                	test   %eax,%eax
  8001e7:	7f 08                	jg     8001f1 <sys_page_map+0x2f>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001e9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001ec:	5b                   	pop    %ebx
  8001ed:	5e                   	pop    %esi
  8001ee:	5f                   	pop    %edi
  8001ef:	5d                   	pop    %ebp
  8001f0:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8001f1:	83 ec 0c             	sub    $0xc,%esp
  8001f4:	50                   	push   %eax
  8001f5:	6a 05                	push   $0x5
  8001f7:	68 6a 10 80 00       	push   $0x80106a
  8001fc:	6a 23                	push   $0x23
  8001fe:	68 87 10 80 00       	push   $0x801087
  800203:	e8 3e 01 00 00       	call   800346 <_panic>

00800208 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800208:	f3 0f 1e fb          	endbr32 
  80020c:	55                   	push   %ebp
  80020d:	89 e5                	mov    %esp,%ebp
  80020f:	57                   	push   %edi
  800210:	56                   	push   %esi
  800211:	53                   	push   %ebx
  800212:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800215:	bb 00 00 00 00       	mov    $0x0,%ebx
  80021a:	8b 55 08             	mov    0x8(%ebp),%edx
  80021d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800220:	b8 06 00 00 00       	mov    $0x6,%eax
  800225:	89 df                	mov    %ebx,%edi
  800227:	89 de                	mov    %ebx,%esi
  800229:	cd 30                	int    $0x30
	if(check && ret > 0)
  80022b:	85 c0                	test   %eax,%eax
  80022d:	7f 08                	jg     800237 <sys_page_unmap+0x2f>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80022f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800232:	5b                   	pop    %ebx
  800233:	5e                   	pop    %esi
  800234:	5f                   	pop    %edi
  800235:	5d                   	pop    %ebp
  800236:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800237:	83 ec 0c             	sub    $0xc,%esp
  80023a:	50                   	push   %eax
  80023b:	6a 06                	push   $0x6
  80023d:	68 6a 10 80 00       	push   $0x80106a
  800242:	6a 23                	push   $0x23
  800244:	68 87 10 80 00       	push   $0x801087
  800249:	e8 f8 00 00 00       	call   800346 <_panic>

0080024e <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80024e:	f3 0f 1e fb          	endbr32 
  800252:	55                   	push   %ebp
  800253:	89 e5                	mov    %esp,%ebp
  800255:	57                   	push   %edi
  800256:	56                   	push   %esi
  800257:	53                   	push   %ebx
  800258:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80025b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800260:	8b 55 08             	mov    0x8(%ebp),%edx
  800263:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800266:	b8 08 00 00 00       	mov    $0x8,%eax
  80026b:	89 df                	mov    %ebx,%edi
  80026d:	89 de                	mov    %ebx,%esi
  80026f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800271:	85 c0                	test   %eax,%eax
  800273:	7f 08                	jg     80027d <sys_env_set_status+0x2f>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800275:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800278:	5b                   	pop    %ebx
  800279:	5e                   	pop    %esi
  80027a:	5f                   	pop    %edi
  80027b:	5d                   	pop    %ebp
  80027c:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80027d:	83 ec 0c             	sub    $0xc,%esp
  800280:	50                   	push   %eax
  800281:	6a 08                	push   $0x8
  800283:	68 6a 10 80 00       	push   $0x80106a
  800288:	6a 23                	push   $0x23
  80028a:	68 87 10 80 00       	push   $0x801087
  80028f:	e8 b2 00 00 00       	call   800346 <_panic>

00800294 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800294:	f3 0f 1e fb          	endbr32 
  800298:	55                   	push   %ebp
  800299:	89 e5                	mov    %esp,%ebp
  80029b:	57                   	push   %edi
  80029c:	56                   	push   %esi
  80029d:	53                   	push   %ebx
  80029e:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8002a1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002a6:	8b 55 08             	mov    0x8(%ebp),%edx
  8002a9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002ac:	b8 09 00 00 00       	mov    $0x9,%eax
  8002b1:	89 df                	mov    %ebx,%edi
  8002b3:	89 de                	mov    %ebx,%esi
  8002b5:	cd 30                	int    $0x30
	if(check && ret > 0)
  8002b7:	85 c0                	test   %eax,%eax
  8002b9:	7f 08                	jg     8002c3 <sys_env_set_pgfault_upcall+0x2f>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002bb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002be:	5b                   	pop    %ebx
  8002bf:	5e                   	pop    %esi
  8002c0:	5f                   	pop    %edi
  8002c1:	5d                   	pop    %ebp
  8002c2:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8002c3:	83 ec 0c             	sub    $0xc,%esp
  8002c6:	50                   	push   %eax
  8002c7:	6a 09                	push   $0x9
  8002c9:	68 6a 10 80 00       	push   $0x80106a
  8002ce:	6a 23                	push   $0x23
  8002d0:	68 87 10 80 00       	push   $0x801087
  8002d5:	e8 6c 00 00 00       	call   800346 <_panic>

008002da <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002da:	f3 0f 1e fb          	endbr32 
  8002de:	55                   	push   %ebp
  8002df:	89 e5                	mov    %esp,%ebp
  8002e1:	57                   	push   %edi
  8002e2:	56                   	push   %esi
  8002e3:	53                   	push   %ebx
	asm volatile("int %1\n"
  8002e4:	8b 55 08             	mov    0x8(%ebp),%edx
  8002e7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002ea:	b8 0b 00 00 00       	mov    $0xb,%eax
  8002ef:	be 00 00 00 00       	mov    $0x0,%esi
  8002f4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002f7:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002fa:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8002fc:	5b                   	pop    %ebx
  8002fd:	5e                   	pop    %esi
  8002fe:	5f                   	pop    %edi
  8002ff:	5d                   	pop    %ebp
  800300:	c3                   	ret    

00800301 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800301:	f3 0f 1e fb          	endbr32 
  800305:	55                   	push   %ebp
  800306:	89 e5                	mov    %esp,%ebp
  800308:	57                   	push   %edi
  800309:	56                   	push   %esi
  80030a:	53                   	push   %ebx
  80030b:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80030e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800313:	8b 55 08             	mov    0x8(%ebp),%edx
  800316:	b8 0c 00 00 00       	mov    $0xc,%eax
  80031b:	89 cb                	mov    %ecx,%ebx
  80031d:	89 cf                	mov    %ecx,%edi
  80031f:	89 ce                	mov    %ecx,%esi
  800321:	cd 30                	int    $0x30
	if(check && ret > 0)
  800323:	85 c0                	test   %eax,%eax
  800325:	7f 08                	jg     80032f <sys_ipc_recv+0x2e>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800327:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80032a:	5b                   	pop    %ebx
  80032b:	5e                   	pop    %esi
  80032c:	5f                   	pop    %edi
  80032d:	5d                   	pop    %ebp
  80032e:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80032f:	83 ec 0c             	sub    $0xc,%esp
  800332:	50                   	push   %eax
  800333:	6a 0c                	push   $0xc
  800335:	68 6a 10 80 00       	push   $0x80106a
  80033a:	6a 23                	push   $0x23
  80033c:	68 87 10 80 00       	push   $0x801087
  800341:	e8 00 00 00 00       	call   800346 <_panic>

00800346 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800346:	f3 0f 1e fb          	endbr32 
  80034a:	55                   	push   %ebp
  80034b:	89 e5                	mov    %esp,%ebp
  80034d:	56                   	push   %esi
  80034e:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80034f:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800352:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800358:	e8 d8 fd ff ff       	call   800135 <sys_getenvid>
  80035d:	83 ec 0c             	sub    $0xc,%esp
  800360:	ff 75 0c             	pushl  0xc(%ebp)
  800363:	ff 75 08             	pushl  0x8(%ebp)
  800366:	56                   	push   %esi
  800367:	50                   	push   %eax
  800368:	68 98 10 80 00       	push   $0x801098
  80036d:	e8 bb 00 00 00       	call   80042d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800372:	83 c4 18             	add    $0x18,%esp
  800375:	53                   	push   %ebx
  800376:	ff 75 10             	pushl  0x10(%ebp)
  800379:	e8 5a 00 00 00       	call   8003d8 <vcprintf>
	cprintf("\n");
  80037e:	c7 04 24 bb 10 80 00 	movl   $0x8010bb,(%esp)
  800385:	e8 a3 00 00 00       	call   80042d <cprintf>
  80038a:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80038d:	cc                   	int3   
  80038e:	eb fd                	jmp    80038d <_panic+0x47>

00800390 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800390:	f3 0f 1e fb          	endbr32 
  800394:	55                   	push   %ebp
  800395:	89 e5                	mov    %esp,%ebp
  800397:	53                   	push   %ebx
  800398:	83 ec 04             	sub    $0x4,%esp
  80039b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80039e:	8b 13                	mov    (%ebx),%edx
  8003a0:	8d 42 01             	lea    0x1(%edx),%eax
  8003a3:	89 03                	mov    %eax,(%ebx)
  8003a5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003a8:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8003ac:	3d ff 00 00 00       	cmp    $0xff,%eax
  8003b1:	74 09                	je     8003bc <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8003b3:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8003b7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8003ba:	c9                   	leave  
  8003bb:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8003bc:	83 ec 08             	sub    $0x8,%esp
  8003bf:	68 ff 00 00 00       	push   $0xff
  8003c4:	8d 43 08             	lea    0x8(%ebx),%eax
  8003c7:	50                   	push   %eax
  8003c8:	e8 de fc ff ff       	call   8000ab <sys_cputs>
		b->idx = 0;
  8003cd:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8003d3:	83 c4 10             	add    $0x10,%esp
  8003d6:	eb db                	jmp    8003b3 <putch+0x23>

008003d8 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8003d8:	f3 0f 1e fb          	endbr32 
  8003dc:	55                   	push   %ebp
  8003dd:	89 e5                	mov    %esp,%ebp
  8003df:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8003e5:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003ec:	00 00 00 
	b.cnt = 0;
  8003ef:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003f6:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003f9:	ff 75 0c             	pushl  0xc(%ebp)
  8003fc:	ff 75 08             	pushl  0x8(%ebp)
  8003ff:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800405:	50                   	push   %eax
  800406:	68 90 03 80 00       	push   $0x800390
  80040b:	e8 20 01 00 00       	call   800530 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800410:	83 c4 08             	add    $0x8,%esp
  800413:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800419:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80041f:	50                   	push   %eax
  800420:	e8 86 fc ff ff       	call   8000ab <sys_cputs>

	return b.cnt;
}
  800425:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80042b:	c9                   	leave  
  80042c:	c3                   	ret    

0080042d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80042d:	f3 0f 1e fb          	endbr32 
  800431:	55                   	push   %ebp
  800432:	89 e5                	mov    %esp,%ebp
  800434:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800437:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80043a:	50                   	push   %eax
  80043b:	ff 75 08             	pushl  0x8(%ebp)
  80043e:	e8 95 ff ff ff       	call   8003d8 <vcprintf>
	va_end(ap);

	return cnt;
}
  800443:	c9                   	leave  
  800444:	c3                   	ret    

00800445 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800445:	55                   	push   %ebp
  800446:	89 e5                	mov    %esp,%ebp
  800448:	57                   	push   %edi
  800449:	56                   	push   %esi
  80044a:	53                   	push   %ebx
  80044b:	83 ec 1c             	sub    $0x1c,%esp
  80044e:	89 c7                	mov    %eax,%edi
  800450:	89 d6                	mov    %edx,%esi
  800452:	8b 45 08             	mov    0x8(%ebp),%eax
  800455:	8b 55 0c             	mov    0xc(%ebp),%edx
  800458:	89 d1                	mov    %edx,%ecx
  80045a:	89 c2                	mov    %eax,%edx
  80045c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80045f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800462:	8b 45 10             	mov    0x10(%ebp),%eax
  800465:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800468:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80046b:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800472:	39 c2                	cmp    %eax,%edx
  800474:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800477:	72 3e                	jb     8004b7 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800479:	83 ec 0c             	sub    $0xc,%esp
  80047c:	ff 75 18             	pushl  0x18(%ebp)
  80047f:	83 eb 01             	sub    $0x1,%ebx
  800482:	53                   	push   %ebx
  800483:	50                   	push   %eax
  800484:	83 ec 08             	sub    $0x8,%esp
  800487:	ff 75 e4             	pushl  -0x1c(%ebp)
  80048a:	ff 75 e0             	pushl  -0x20(%ebp)
  80048d:	ff 75 dc             	pushl  -0x24(%ebp)
  800490:	ff 75 d8             	pushl  -0x28(%ebp)
  800493:	e8 58 09 00 00       	call   800df0 <__udivdi3>
  800498:	83 c4 18             	add    $0x18,%esp
  80049b:	52                   	push   %edx
  80049c:	50                   	push   %eax
  80049d:	89 f2                	mov    %esi,%edx
  80049f:	89 f8                	mov    %edi,%eax
  8004a1:	e8 9f ff ff ff       	call   800445 <printnum>
  8004a6:	83 c4 20             	add    $0x20,%esp
  8004a9:	eb 13                	jmp    8004be <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8004ab:	83 ec 08             	sub    $0x8,%esp
  8004ae:	56                   	push   %esi
  8004af:	ff 75 18             	pushl  0x18(%ebp)
  8004b2:	ff d7                	call   *%edi
  8004b4:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8004b7:	83 eb 01             	sub    $0x1,%ebx
  8004ba:	85 db                	test   %ebx,%ebx
  8004bc:	7f ed                	jg     8004ab <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8004be:	83 ec 08             	sub    $0x8,%esp
  8004c1:	56                   	push   %esi
  8004c2:	83 ec 04             	sub    $0x4,%esp
  8004c5:	ff 75 e4             	pushl  -0x1c(%ebp)
  8004c8:	ff 75 e0             	pushl  -0x20(%ebp)
  8004cb:	ff 75 dc             	pushl  -0x24(%ebp)
  8004ce:	ff 75 d8             	pushl  -0x28(%ebp)
  8004d1:	e8 2a 0a 00 00       	call   800f00 <__umoddi3>
  8004d6:	83 c4 14             	add    $0x14,%esp
  8004d9:	0f be 80 bd 10 80 00 	movsbl 0x8010bd(%eax),%eax
  8004e0:	50                   	push   %eax
  8004e1:	ff d7                	call   *%edi
}
  8004e3:	83 c4 10             	add    $0x10,%esp
  8004e6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004e9:	5b                   	pop    %ebx
  8004ea:	5e                   	pop    %esi
  8004eb:	5f                   	pop    %edi
  8004ec:	5d                   	pop    %ebp
  8004ed:	c3                   	ret    

008004ee <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004ee:	f3 0f 1e fb          	endbr32 
  8004f2:	55                   	push   %ebp
  8004f3:	89 e5                	mov    %esp,%ebp
  8004f5:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004f8:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004fc:	8b 10                	mov    (%eax),%edx
  8004fe:	3b 50 04             	cmp    0x4(%eax),%edx
  800501:	73 0a                	jae    80050d <sprintputch+0x1f>
		*b->buf++ = ch;
  800503:	8d 4a 01             	lea    0x1(%edx),%ecx
  800506:	89 08                	mov    %ecx,(%eax)
  800508:	8b 45 08             	mov    0x8(%ebp),%eax
  80050b:	88 02                	mov    %al,(%edx)
}
  80050d:	5d                   	pop    %ebp
  80050e:	c3                   	ret    

0080050f <printfmt>:
{
  80050f:	f3 0f 1e fb          	endbr32 
  800513:	55                   	push   %ebp
  800514:	89 e5                	mov    %esp,%ebp
  800516:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800519:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80051c:	50                   	push   %eax
  80051d:	ff 75 10             	pushl  0x10(%ebp)
  800520:	ff 75 0c             	pushl  0xc(%ebp)
  800523:	ff 75 08             	pushl  0x8(%ebp)
  800526:	e8 05 00 00 00       	call   800530 <vprintfmt>
}
  80052b:	83 c4 10             	add    $0x10,%esp
  80052e:	c9                   	leave  
  80052f:	c3                   	ret    

00800530 <vprintfmt>:
{
  800530:	f3 0f 1e fb          	endbr32 
  800534:	55                   	push   %ebp
  800535:	89 e5                	mov    %esp,%ebp
  800537:	57                   	push   %edi
  800538:	56                   	push   %esi
  800539:	53                   	push   %ebx
  80053a:	83 ec 3c             	sub    $0x3c,%esp
  80053d:	8b 75 08             	mov    0x8(%ebp),%esi
  800540:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800543:	8b 7d 10             	mov    0x10(%ebp),%edi
  800546:	e9 cd 03 00 00       	jmp    800918 <vprintfmt+0x3e8>
		padc = ' ';
  80054b:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  80054f:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800556:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  80055d:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800564:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800569:	8d 47 01             	lea    0x1(%edi),%eax
  80056c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80056f:	0f b6 17             	movzbl (%edi),%edx
  800572:	8d 42 dd             	lea    -0x23(%edx),%eax
  800575:	3c 55                	cmp    $0x55,%al
  800577:	0f 87 1e 04 00 00    	ja     80099b <vprintfmt+0x46b>
  80057d:	0f b6 c0             	movzbl %al,%eax
  800580:	3e ff 24 85 80 11 80 	notrack jmp *0x801180(,%eax,4)
  800587:	00 
  800588:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80058b:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  80058f:	eb d8                	jmp    800569 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800591:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800594:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  800598:	eb cf                	jmp    800569 <vprintfmt+0x39>
  80059a:	0f b6 d2             	movzbl %dl,%edx
  80059d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8005a0:	b8 00 00 00 00       	mov    $0x0,%eax
  8005a5:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8005a8:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8005ab:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8005af:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8005b2:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8005b5:	83 f9 09             	cmp    $0x9,%ecx
  8005b8:	77 55                	ja     80060f <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  8005ba:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8005bd:	eb e9                	jmp    8005a8 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  8005bf:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c2:	8b 00                	mov    (%eax),%eax
  8005c4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ca:	8d 40 04             	lea    0x4(%eax),%eax
  8005cd:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8005d0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8005d3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005d7:	79 90                	jns    800569 <vprintfmt+0x39>
				width = precision, precision = -1;
  8005d9:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005dc:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005df:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8005e6:	eb 81                	jmp    800569 <vprintfmt+0x39>
  8005e8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005eb:	85 c0                	test   %eax,%eax
  8005ed:	ba 00 00 00 00       	mov    $0x0,%edx
  8005f2:	0f 49 d0             	cmovns %eax,%edx
  8005f5:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8005f8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8005fb:	e9 69 ff ff ff       	jmp    800569 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800600:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800603:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  80060a:	e9 5a ff ff ff       	jmp    800569 <vprintfmt+0x39>
  80060f:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800612:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800615:	eb bc                	jmp    8005d3 <vprintfmt+0xa3>
			lflag++;
  800617:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80061a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80061d:	e9 47 ff ff ff       	jmp    800569 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  800622:	8b 45 14             	mov    0x14(%ebp),%eax
  800625:	8d 78 04             	lea    0x4(%eax),%edi
  800628:	83 ec 08             	sub    $0x8,%esp
  80062b:	53                   	push   %ebx
  80062c:	ff 30                	pushl  (%eax)
  80062e:	ff d6                	call   *%esi
			break;
  800630:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800633:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800636:	e9 da 02 00 00       	jmp    800915 <vprintfmt+0x3e5>
			err = va_arg(ap, int);
  80063b:	8b 45 14             	mov    0x14(%ebp),%eax
  80063e:	8d 78 04             	lea    0x4(%eax),%edi
  800641:	8b 00                	mov    (%eax),%eax
  800643:	99                   	cltd   
  800644:	31 d0                	xor    %edx,%eax
  800646:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800648:	83 f8 08             	cmp    $0x8,%eax
  80064b:	7f 23                	jg     800670 <vprintfmt+0x140>
  80064d:	8b 14 85 e0 12 80 00 	mov    0x8012e0(,%eax,4),%edx
  800654:	85 d2                	test   %edx,%edx
  800656:	74 18                	je     800670 <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  800658:	52                   	push   %edx
  800659:	68 de 10 80 00       	push   $0x8010de
  80065e:	53                   	push   %ebx
  80065f:	56                   	push   %esi
  800660:	e8 aa fe ff ff       	call   80050f <printfmt>
  800665:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800668:	89 7d 14             	mov    %edi,0x14(%ebp)
  80066b:	e9 a5 02 00 00       	jmp    800915 <vprintfmt+0x3e5>
				printfmt(putch, putdat, "error %d", err);
  800670:	50                   	push   %eax
  800671:	68 d5 10 80 00       	push   $0x8010d5
  800676:	53                   	push   %ebx
  800677:	56                   	push   %esi
  800678:	e8 92 fe ff ff       	call   80050f <printfmt>
  80067d:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800680:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800683:	e9 8d 02 00 00       	jmp    800915 <vprintfmt+0x3e5>
			if ((p = va_arg(ap, char *)) == NULL)
  800688:	8b 45 14             	mov    0x14(%ebp),%eax
  80068b:	83 c0 04             	add    $0x4,%eax
  80068e:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800691:	8b 45 14             	mov    0x14(%ebp),%eax
  800694:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  800696:	85 d2                	test   %edx,%edx
  800698:	b8 ce 10 80 00       	mov    $0x8010ce,%eax
  80069d:	0f 45 c2             	cmovne %edx,%eax
  8006a0:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8006a3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006a7:	7e 06                	jle    8006af <vprintfmt+0x17f>
  8006a9:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  8006ad:	75 0d                	jne    8006bc <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006af:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8006b2:	89 c7                	mov    %eax,%edi
  8006b4:	03 45 e0             	add    -0x20(%ebp),%eax
  8006b7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006ba:	eb 55                	jmp    800711 <vprintfmt+0x1e1>
  8006bc:	83 ec 08             	sub    $0x8,%esp
  8006bf:	ff 75 d8             	pushl  -0x28(%ebp)
  8006c2:	ff 75 cc             	pushl  -0x34(%ebp)
  8006c5:	e8 85 03 00 00       	call   800a4f <strnlen>
  8006ca:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8006cd:	29 c2                	sub    %eax,%edx
  8006cf:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  8006d2:	83 c4 10             	add    $0x10,%esp
  8006d5:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  8006d7:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8006db:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8006de:	85 ff                	test   %edi,%edi
  8006e0:	7e 11                	jle    8006f3 <vprintfmt+0x1c3>
					putch(padc, putdat);
  8006e2:	83 ec 08             	sub    $0x8,%esp
  8006e5:	53                   	push   %ebx
  8006e6:	ff 75 e0             	pushl  -0x20(%ebp)
  8006e9:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8006eb:	83 ef 01             	sub    $0x1,%edi
  8006ee:	83 c4 10             	add    $0x10,%esp
  8006f1:	eb eb                	jmp    8006de <vprintfmt+0x1ae>
  8006f3:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8006f6:	85 d2                	test   %edx,%edx
  8006f8:	b8 00 00 00 00       	mov    $0x0,%eax
  8006fd:	0f 49 c2             	cmovns %edx,%eax
  800700:	29 c2                	sub    %eax,%edx
  800702:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800705:	eb a8                	jmp    8006af <vprintfmt+0x17f>
					putch(ch, putdat);
  800707:	83 ec 08             	sub    $0x8,%esp
  80070a:	53                   	push   %ebx
  80070b:	52                   	push   %edx
  80070c:	ff d6                	call   *%esi
  80070e:	83 c4 10             	add    $0x10,%esp
  800711:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800714:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800716:	83 c7 01             	add    $0x1,%edi
  800719:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80071d:	0f be d0             	movsbl %al,%edx
  800720:	85 d2                	test   %edx,%edx
  800722:	74 4b                	je     80076f <vprintfmt+0x23f>
  800724:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800728:	78 06                	js     800730 <vprintfmt+0x200>
  80072a:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  80072e:	78 1e                	js     80074e <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
  800730:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800734:	74 d1                	je     800707 <vprintfmt+0x1d7>
  800736:	0f be c0             	movsbl %al,%eax
  800739:	83 e8 20             	sub    $0x20,%eax
  80073c:	83 f8 5e             	cmp    $0x5e,%eax
  80073f:	76 c6                	jbe    800707 <vprintfmt+0x1d7>
					putch('?', putdat);
  800741:	83 ec 08             	sub    $0x8,%esp
  800744:	53                   	push   %ebx
  800745:	6a 3f                	push   $0x3f
  800747:	ff d6                	call   *%esi
  800749:	83 c4 10             	add    $0x10,%esp
  80074c:	eb c3                	jmp    800711 <vprintfmt+0x1e1>
  80074e:	89 cf                	mov    %ecx,%edi
  800750:	eb 0e                	jmp    800760 <vprintfmt+0x230>
				putch(' ', putdat);
  800752:	83 ec 08             	sub    $0x8,%esp
  800755:	53                   	push   %ebx
  800756:	6a 20                	push   $0x20
  800758:	ff d6                	call   *%esi
			for (; width > 0; width--)
  80075a:	83 ef 01             	sub    $0x1,%edi
  80075d:	83 c4 10             	add    $0x10,%esp
  800760:	85 ff                	test   %edi,%edi
  800762:	7f ee                	jg     800752 <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  800764:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800767:	89 45 14             	mov    %eax,0x14(%ebp)
  80076a:	e9 a6 01 00 00       	jmp    800915 <vprintfmt+0x3e5>
  80076f:	89 cf                	mov    %ecx,%edi
  800771:	eb ed                	jmp    800760 <vprintfmt+0x230>
	if (lflag >= 2)
  800773:	83 f9 01             	cmp    $0x1,%ecx
  800776:	7f 1f                	jg     800797 <vprintfmt+0x267>
	else if (lflag)
  800778:	85 c9                	test   %ecx,%ecx
  80077a:	74 67                	je     8007e3 <vprintfmt+0x2b3>
		return va_arg(*ap, long);
  80077c:	8b 45 14             	mov    0x14(%ebp),%eax
  80077f:	8b 00                	mov    (%eax),%eax
  800781:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800784:	89 c1                	mov    %eax,%ecx
  800786:	c1 f9 1f             	sar    $0x1f,%ecx
  800789:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80078c:	8b 45 14             	mov    0x14(%ebp),%eax
  80078f:	8d 40 04             	lea    0x4(%eax),%eax
  800792:	89 45 14             	mov    %eax,0x14(%ebp)
  800795:	eb 17                	jmp    8007ae <vprintfmt+0x27e>
		return va_arg(*ap, long long);
  800797:	8b 45 14             	mov    0x14(%ebp),%eax
  80079a:	8b 50 04             	mov    0x4(%eax),%edx
  80079d:	8b 00                	mov    (%eax),%eax
  80079f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007a2:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a8:	8d 40 08             	lea    0x8(%eax),%eax
  8007ab:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8007ae:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007b1:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8007b4:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  8007b9:	85 c9                	test   %ecx,%ecx
  8007bb:	0f 89 3a 01 00 00    	jns    8008fb <vprintfmt+0x3cb>
				putch('-', putdat);
  8007c1:	83 ec 08             	sub    $0x8,%esp
  8007c4:	53                   	push   %ebx
  8007c5:	6a 2d                	push   $0x2d
  8007c7:	ff d6                	call   *%esi
				num = -(long long) num;
  8007c9:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007cc:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8007cf:	f7 da                	neg    %edx
  8007d1:	83 d1 00             	adc    $0x0,%ecx
  8007d4:	f7 d9                	neg    %ecx
  8007d6:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8007d9:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007de:	e9 18 01 00 00       	jmp    8008fb <vprintfmt+0x3cb>
		return va_arg(*ap, int);
  8007e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e6:	8b 00                	mov    (%eax),%eax
  8007e8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007eb:	89 c1                	mov    %eax,%ecx
  8007ed:	c1 f9 1f             	sar    $0x1f,%ecx
  8007f0:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8007f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f6:	8d 40 04             	lea    0x4(%eax),%eax
  8007f9:	89 45 14             	mov    %eax,0x14(%ebp)
  8007fc:	eb b0                	jmp    8007ae <vprintfmt+0x27e>
	if (lflag >= 2)
  8007fe:	83 f9 01             	cmp    $0x1,%ecx
  800801:	7f 1e                	jg     800821 <vprintfmt+0x2f1>
	else if (lflag)
  800803:	85 c9                	test   %ecx,%ecx
  800805:	74 32                	je     800839 <vprintfmt+0x309>
		return va_arg(*ap, unsigned long);
  800807:	8b 45 14             	mov    0x14(%ebp),%eax
  80080a:	8b 10                	mov    (%eax),%edx
  80080c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800811:	8d 40 04             	lea    0x4(%eax),%eax
  800814:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800817:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  80081c:	e9 da 00 00 00       	jmp    8008fb <vprintfmt+0x3cb>
		return va_arg(*ap, unsigned long long);
  800821:	8b 45 14             	mov    0x14(%ebp),%eax
  800824:	8b 10                	mov    (%eax),%edx
  800826:	8b 48 04             	mov    0x4(%eax),%ecx
  800829:	8d 40 08             	lea    0x8(%eax),%eax
  80082c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80082f:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  800834:	e9 c2 00 00 00       	jmp    8008fb <vprintfmt+0x3cb>
		return va_arg(*ap, unsigned int);
  800839:	8b 45 14             	mov    0x14(%ebp),%eax
  80083c:	8b 10                	mov    (%eax),%edx
  80083e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800843:	8d 40 04             	lea    0x4(%eax),%eax
  800846:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800849:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  80084e:	e9 a8 00 00 00       	jmp    8008fb <vprintfmt+0x3cb>
	if (lflag >= 2)
  800853:	83 f9 01             	cmp    $0x1,%ecx
  800856:	7f 1b                	jg     800873 <vprintfmt+0x343>
	else if (lflag)
  800858:	85 c9                	test   %ecx,%ecx
  80085a:	74 5c                	je     8008b8 <vprintfmt+0x388>
		return va_arg(*ap, long);
  80085c:	8b 45 14             	mov    0x14(%ebp),%eax
  80085f:	8b 00                	mov    (%eax),%eax
  800861:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800864:	99                   	cltd   
  800865:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800868:	8b 45 14             	mov    0x14(%ebp),%eax
  80086b:	8d 40 04             	lea    0x4(%eax),%eax
  80086e:	89 45 14             	mov    %eax,0x14(%ebp)
  800871:	eb 17                	jmp    80088a <vprintfmt+0x35a>
		return va_arg(*ap, long long);
  800873:	8b 45 14             	mov    0x14(%ebp),%eax
  800876:	8b 50 04             	mov    0x4(%eax),%edx
  800879:	8b 00                	mov    (%eax),%eax
  80087b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80087e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800881:	8b 45 14             	mov    0x14(%ebp),%eax
  800884:	8d 40 08             	lea    0x8(%eax),%eax
  800887:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80088a:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80088d:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 8;
  800890:	b8 08 00 00 00       	mov    $0x8,%eax
			if ((long long) num < 0) {
  800895:	85 c9                	test   %ecx,%ecx
  800897:	79 62                	jns    8008fb <vprintfmt+0x3cb>
				putch('-', putdat);
  800899:	83 ec 08             	sub    $0x8,%esp
  80089c:	53                   	push   %ebx
  80089d:	6a 2d                	push   $0x2d
  80089f:	ff d6                	call   *%esi
				num = -(long long) num;
  8008a1:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8008a4:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8008a7:	f7 da                	neg    %edx
  8008a9:	83 d1 00             	adc    $0x0,%ecx
  8008ac:	f7 d9                	neg    %ecx
  8008ae:	83 c4 10             	add    $0x10,%esp
			base = 8;
  8008b1:	b8 08 00 00 00       	mov    $0x8,%eax
  8008b6:	eb 43                	jmp    8008fb <vprintfmt+0x3cb>
		return va_arg(*ap, int);
  8008b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8008bb:	8b 00                	mov    (%eax),%eax
  8008bd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8008c0:	89 c1                	mov    %eax,%ecx
  8008c2:	c1 f9 1f             	sar    $0x1f,%ecx
  8008c5:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8008c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8008cb:	8d 40 04             	lea    0x4(%eax),%eax
  8008ce:	89 45 14             	mov    %eax,0x14(%ebp)
  8008d1:	eb b7                	jmp    80088a <vprintfmt+0x35a>
			putch('0', putdat);
  8008d3:	83 ec 08             	sub    $0x8,%esp
  8008d6:	53                   	push   %ebx
  8008d7:	6a 30                	push   $0x30
  8008d9:	ff d6                	call   *%esi
			putch('x', putdat);
  8008db:	83 c4 08             	add    $0x8,%esp
  8008de:	53                   	push   %ebx
  8008df:	6a 78                	push   $0x78
  8008e1:	ff d6                	call   *%esi
			num = (unsigned long long)
  8008e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8008e6:	8b 10                	mov    (%eax),%edx
  8008e8:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8008ed:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8008f0:	8d 40 04             	lea    0x4(%eax),%eax
  8008f3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8008f6:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  8008fb:	83 ec 0c             	sub    $0xc,%esp
  8008fe:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  800902:	57                   	push   %edi
  800903:	ff 75 e0             	pushl  -0x20(%ebp)
  800906:	50                   	push   %eax
  800907:	51                   	push   %ecx
  800908:	52                   	push   %edx
  800909:	89 da                	mov    %ebx,%edx
  80090b:	89 f0                	mov    %esi,%eax
  80090d:	e8 33 fb ff ff       	call   800445 <printnum>
			break;
  800912:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  800915:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800918:	83 c7 01             	add    $0x1,%edi
  80091b:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80091f:	83 f8 25             	cmp    $0x25,%eax
  800922:	0f 84 23 fc ff ff    	je     80054b <vprintfmt+0x1b>
			if (ch == '\0')
  800928:	85 c0                	test   %eax,%eax
  80092a:	0f 84 8b 00 00 00    	je     8009bb <vprintfmt+0x48b>
			putch(ch, putdat);
  800930:	83 ec 08             	sub    $0x8,%esp
  800933:	53                   	push   %ebx
  800934:	50                   	push   %eax
  800935:	ff d6                	call   *%esi
  800937:	83 c4 10             	add    $0x10,%esp
  80093a:	eb dc                	jmp    800918 <vprintfmt+0x3e8>
	if (lflag >= 2)
  80093c:	83 f9 01             	cmp    $0x1,%ecx
  80093f:	7f 1b                	jg     80095c <vprintfmt+0x42c>
	else if (lflag)
  800941:	85 c9                	test   %ecx,%ecx
  800943:	74 2c                	je     800971 <vprintfmt+0x441>
		return va_arg(*ap, unsigned long);
  800945:	8b 45 14             	mov    0x14(%ebp),%eax
  800948:	8b 10                	mov    (%eax),%edx
  80094a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80094f:	8d 40 04             	lea    0x4(%eax),%eax
  800952:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800955:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  80095a:	eb 9f                	jmp    8008fb <vprintfmt+0x3cb>
		return va_arg(*ap, unsigned long long);
  80095c:	8b 45 14             	mov    0x14(%ebp),%eax
  80095f:	8b 10                	mov    (%eax),%edx
  800961:	8b 48 04             	mov    0x4(%eax),%ecx
  800964:	8d 40 08             	lea    0x8(%eax),%eax
  800967:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80096a:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  80096f:	eb 8a                	jmp    8008fb <vprintfmt+0x3cb>
		return va_arg(*ap, unsigned int);
  800971:	8b 45 14             	mov    0x14(%ebp),%eax
  800974:	8b 10                	mov    (%eax),%edx
  800976:	b9 00 00 00 00       	mov    $0x0,%ecx
  80097b:	8d 40 04             	lea    0x4(%eax),%eax
  80097e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800981:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  800986:	e9 70 ff ff ff       	jmp    8008fb <vprintfmt+0x3cb>
			putch(ch, putdat);
  80098b:	83 ec 08             	sub    $0x8,%esp
  80098e:	53                   	push   %ebx
  80098f:	6a 25                	push   $0x25
  800991:	ff d6                	call   *%esi
			break;
  800993:	83 c4 10             	add    $0x10,%esp
  800996:	e9 7a ff ff ff       	jmp    800915 <vprintfmt+0x3e5>
			putch('%', putdat);
  80099b:	83 ec 08             	sub    $0x8,%esp
  80099e:	53                   	push   %ebx
  80099f:	6a 25                	push   $0x25
  8009a1:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8009a3:	83 c4 10             	add    $0x10,%esp
  8009a6:	89 f8                	mov    %edi,%eax
  8009a8:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8009ac:	74 05                	je     8009b3 <vprintfmt+0x483>
  8009ae:	83 e8 01             	sub    $0x1,%eax
  8009b1:	eb f5                	jmp    8009a8 <vprintfmt+0x478>
  8009b3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8009b6:	e9 5a ff ff ff       	jmp    800915 <vprintfmt+0x3e5>
}
  8009bb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8009be:	5b                   	pop    %ebx
  8009bf:	5e                   	pop    %esi
  8009c0:	5f                   	pop    %edi
  8009c1:	5d                   	pop    %ebp
  8009c2:	c3                   	ret    

008009c3 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8009c3:	f3 0f 1e fb          	endbr32 
  8009c7:	55                   	push   %ebp
  8009c8:	89 e5                	mov    %esp,%ebp
  8009ca:	83 ec 18             	sub    $0x18,%esp
  8009cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d0:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8009d3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8009d6:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8009da:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8009dd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8009e4:	85 c0                	test   %eax,%eax
  8009e6:	74 26                	je     800a0e <vsnprintf+0x4b>
  8009e8:	85 d2                	test   %edx,%edx
  8009ea:	7e 22                	jle    800a0e <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8009ec:	ff 75 14             	pushl  0x14(%ebp)
  8009ef:	ff 75 10             	pushl  0x10(%ebp)
  8009f2:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8009f5:	50                   	push   %eax
  8009f6:	68 ee 04 80 00       	push   $0x8004ee
  8009fb:	e8 30 fb ff ff       	call   800530 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800a00:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800a03:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800a06:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800a09:	83 c4 10             	add    $0x10,%esp
}
  800a0c:	c9                   	leave  
  800a0d:	c3                   	ret    
		return -E_INVAL;
  800a0e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800a13:	eb f7                	jmp    800a0c <vsnprintf+0x49>

00800a15 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800a15:	f3 0f 1e fb          	endbr32 
  800a19:	55                   	push   %ebp
  800a1a:	89 e5                	mov    %esp,%ebp
  800a1c:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800a1f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800a22:	50                   	push   %eax
  800a23:	ff 75 10             	pushl  0x10(%ebp)
  800a26:	ff 75 0c             	pushl  0xc(%ebp)
  800a29:	ff 75 08             	pushl  0x8(%ebp)
  800a2c:	e8 92 ff ff ff       	call   8009c3 <vsnprintf>
	va_end(ap);

	return rc;
}
  800a31:	c9                   	leave  
  800a32:	c3                   	ret    

00800a33 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800a33:	f3 0f 1e fb          	endbr32 
  800a37:	55                   	push   %ebp
  800a38:	89 e5                	mov    %esp,%ebp
  800a3a:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a3d:	b8 00 00 00 00       	mov    $0x0,%eax
  800a42:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a46:	74 05                	je     800a4d <strlen+0x1a>
		n++;
  800a48:	83 c0 01             	add    $0x1,%eax
  800a4b:	eb f5                	jmp    800a42 <strlen+0xf>
	return n;
}
  800a4d:	5d                   	pop    %ebp
  800a4e:	c3                   	ret    

00800a4f <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a4f:	f3 0f 1e fb          	endbr32 
  800a53:	55                   	push   %ebp
  800a54:	89 e5                	mov    %esp,%ebp
  800a56:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a59:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a5c:	b8 00 00 00 00       	mov    $0x0,%eax
  800a61:	39 d0                	cmp    %edx,%eax
  800a63:	74 0d                	je     800a72 <strnlen+0x23>
  800a65:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800a69:	74 05                	je     800a70 <strnlen+0x21>
		n++;
  800a6b:	83 c0 01             	add    $0x1,%eax
  800a6e:	eb f1                	jmp    800a61 <strnlen+0x12>
  800a70:	89 c2                	mov    %eax,%edx
	return n;
}
  800a72:	89 d0                	mov    %edx,%eax
  800a74:	5d                   	pop    %ebp
  800a75:	c3                   	ret    

00800a76 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a76:	f3 0f 1e fb          	endbr32 
  800a7a:	55                   	push   %ebp
  800a7b:	89 e5                	mov    %esp,%ebp
  800a7d:	53                   	push   %ebx
  800a7e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a81:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a84:	b8 00 00 00 00       	mov    $0x0,%eax
  800a89:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800a8d:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800a90:	83 c0 01             	add    $0x1,%eax
  800a93:	84 d2                	test   %dl,%dl
  800a95:	75 f2                	jne    800a89 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  800a97:	89 c8                	mov    %ecx,%eax
  800a99:	5b                   	pop    %ebx
  800a9a:	5d                   	pop    %ebp
  800a9b:	c3                   	ret    

00800a9c <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a9c:	f3 0f 1e fb          	endbr32 
  800aa0:	55                   	push   %ebp
  800aa1:	89 e5                	mov    %esp,%ebp
  800aa3:	53                   	push   %ebx
  800aa4:	83 ec 10             	sub    $0x10,%esp
  800aa7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800aaa:	53                   	push   %ebx
  800aab:	e8 83 ff ff ff       	call   800a33 <strlen>
  800ab0:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800ab3:	ff 75 0c             	pushl  0xc(%ebp)
  800ab6:	01 d8                	add    %ebx,%eax
  800ab8:	50                   	push   %eax
  800ab9:	e8 b8 ff ff ff       	call   800a76 <strcpy>
	return dst;
}
  800abe:	89 d8                	mov    %ebx,%eax
  800ac0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ac3:	c9                   	leave  
  800ac4:	c3                   	ret    

00800ac5 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800ac5:	f3 0f 1e fb          	endbr32 
  800ac9:	55                   	push   %ebp
  800aca:	89 e5                	mov    %esp,%ebp
  800acc:	56                   	push   %esi
  800acd:	53                   	push   %ebx
  800ace:	8b 75 08             	mov    0x8(%ebp),%esi
  800ad1:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ad4:	89 f3                	mov    %esi,%ebx
  800ad6:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800ad9:	89 f0                	mov    %esi,%eax
  800adb:	39 d8                	cmp    %ebx,%eax
  800add:	74 11                	je     800af0 <strncpy+0x2b>
		*dst++ = *src;
  800adf:	83 c0 01             	add    $0x1,%eax
  800ae2:	0f b6 0a             	movzbl (%edx),%ecx
  800ae5:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800ae8:	80 f9 01             	cmp    $0x1,%cl
  800aeb:	83 da ff             	sbb    $0xffffffff,%edx
  800aee:	eb eb                	jmp    800adb <strncpy+0x16>
	}
	return ret;
}
  800af0:	89 f0                	mov    %esi,%eax
  800af2:	5b                   	pop    %ebx
  800af3:	5e                   	pop    %esi
  800af4:	5d                   	pop    %ebp
  800af5:	c3                   	ret    

00800af6 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800af6:	f3 0f 1e fb          	endbr32 
  800afa:	55                   	push   %ebp
  800afb:	89 e5                	mov    %esp,%ebp
  800afd:	56                   	push   %esi
  800afe:	53                   	push   %ebx
  800aff:	8b 75 08             	mov    0x8(%ebp),%esi
  800b02:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b05:	8b 55 10             	mov    0x10(%ebp),%edx
  800b08:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800b0a:	85 d2                	test   %edx,%edx
  800b0c:	74 21                	je     800b2f <strlcpy+0x39>
  800b0e:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800b12:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  800b14:	39 c2                	cmp    %eax,%edx
  800b16:	74 14                	je     800b2c <strlcpy+0x36>
  800b18:	0f b6 19             	movzbl (%ecx),%ebx
  800b1b:	84 db                	test   %bl,%bl
  800b1d:	74 0b                	je     800b2a <strlcpy+0x34>
			*dst++ = *src++;
  800b1f:	83 c1 01             	add    $0x1,%ecx
  800b22:	83 c2 01             	add    $0x1,%edx
  800b25:	88 5a ff             	mov    %bl,-0x1(%edx)
  800b28:	eb ea                	jmp    800b14 <strlcpy+0x1e>
  800b2a:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800b2c:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800b2f:	29 f0                	sub    %esi,%eax
}
  800b31:	5b                   	pop    %ebx
  800b32:	5e                   	pop    %esi
  800b33:	5d                   	pop    %ebp
  800b34:	c3                   	ret    

00800b35 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800b35:	f3 0f 1e fb          	endbr32 
  800b39:	55                   	push   %ebp
  800b3a:	89 e5                	mov    %esp,%ebp
  800b3c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b3f:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800b42:	0f b6 01             	movzbl (%ecx),%eax
  800b45:	84 c0                	test   %al,%al
  800b47:	74 0c                	je     800b55 <strcmp+0x20>
  800b49:	3a 02                	cmp    (%edx),%al
  800b4b:	75 08                	jne    800b55 <strcmp+0x20>
		p++, q++;
  800b4d:	83 c1 01             	add    $0x1,%ecx
  800b50:	83 c2 01             	add    $0x1,%edx
  800b53:	eb ed                	jmp    800b42 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800b55:	0f b6 c0             	movzbl %al,%eax
  800b58:	0f b6 12             	movzbl (%edx),%edx
  800b5b:	29 d0                	sub    %edx,%eax
}
  800b5d:	5d                   	pop    %ebp
  800b5e:	c3                   	ret    

00800b5f <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b5f:	f3 0f 1e fb          	endbr32 
  800b63:	55                   	push   %ebp
  800b64:	89 e5                	mov    %esp,%ebp
  800b66:	53                   	push   %ebx
  800b67:	8b 45 08             	mov    0x8(%ebp),%eax
  800b6a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b6d:	89 c3                	mov    %eax,%ebx
  800b6f:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800b72:	eb 06                	jmp    800b7a <strncmp+0x1b>
		n--, p++, q++;
  800b74:	83 c0 01             	add    $0x1,%eax
  800b77:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800b7a:	39 d8                	cmp    %ebx,%eax
  800b7c:	74 16                	je     800b94 <strncmp+0x35>
  800b7e:	0f b6 08             	movzbl (%eax),%ecx
  800b81:	84 c9                	test   %cl,%cl
  800b83:	74 04                	je     800b89 <strncmp+0x2a>
  800b85:	3a 0a                	cmp    (%edx),%cl
  800b87:	74 eb                	je     800b74 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b89:	0f b6 00             	movzbl (%eax),%eax
  800b8c:	0f b6 12             	movzbl (%edx),%edx
  800b8f:	29 d0                	sub    %edx,%eax
}
  800b91:	5b                   	pop    %ebx
  800b92:	5d                   	pop    %ebp
  800b93:	c3                   	ret    
		return 0;
  800b94:	b8 00 00 00 00       	mov    $0x0,%eax
  800b99:	eb f6                	jmp    800b91 <strncmp+0x32>

00800b9b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b9b:	f3 0f 1e fb          	endbr32 
  800b9f:	55                   	push   %ebp
  800ba0:	89 e5                	mov    %esp,%ebp
  800ba2:	8b 45 08             	mov    0x8(%ebp),%eax
  800ba5:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ba9:	0f b6 10             	movzbl (%eax),%edx
  800bac:	84 d2                	test   %dl,%dl
  800bae:	74 09                	je     800bb9 <strchr+0x1e>
		if (*s == c)
  800bb0:	38 ca                	cmp    %cl,%dl
  800bb2:	74 0a                	je     800bbe <strchr+0x23>
	for (; *s; s++)
  800bb4:	83 c0 01             	add    $0x1,%eax
  800bb7:	eb f0                	jmp    800ba9 <strchr+0xe>
			return (char *) s;
	return 0;
  800bb9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bbe:	5d                   	pop    %ebp
  800bbf:	c3                   	ret    

00800bc0 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800bc0:	f3 0f 1e fb          	endbr32 
  800bc4:	55                   	push   %ebp
  800bc5:	89 e5                	mov    %esp,%ebp
  800bc7:	8b 45 08             	mov    0x8(%ebp),%eax
  800bca:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800bce:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800bd1:	38 ca                	cmp    %cl,%dl
  800bd3:	74 09                	je     800bde <strfind+0x1e>
  800bd5:	84 d2                	test   %dl,%dl
  800bd7:	74 05                	je     800bde <strfind+0x1e>
	for (; *s; s++)
  800bd9:	83 c0 01             	add    $0x1,%eax
  800bdc:	eb f0                	jmp    800bce <strfind+0xe>
			break;
	return (char *) s;
}
  800bde:	5d                   	pop    %ebp
  800bdf:	c3                   	ret    

00800be0 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800be0:	f3 0f 1e fb          	endbr32 
  800be4:	55                   	push   %ebp
  800be5:	89 e5                	mov    %esp,%ebp
  800be7:	57                   	push   %edi
  800be8:	56                   	push   %esi
  800be9:	53                   	push   %ebx
  800bea:	8b 7d 08             	mov    0x8(%ebp),%edi
  800bed:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800bf0:	85 c9                	test   %ecx,%ecx
  800bf2:	74 31                	je     800c25 <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800bf4:	89 f8                	mov    %edi,%eax
  800bf6:	09 c8                	or     %ecx,%eax
  800bf8:	a8 03                	test   $0x3,%al
  800bfa:	75 23                	jne    800c1f <memset+0x3f>
		c &= 0xFF;
  800bfc:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800c00:	89 d3                	mov    %edx,%ebx
  800c02:	c1 e3 08             	shl    $0x8,%ebx
  800c05:	89 d0                	mov    %edx,%eax
  800c07:	c1 e0 18             	shl    $0x18,%eax
  800c0a:	89 d6                	mov    %edx,%esi
  800c0c:	c1 e6 10             	shl    $0x10,%esi
  800c0f:	09 f0                	or     %esi,%eax
  800c11:	09 c2                	or     %eax,%edx
  800c13:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800c15:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800c18:	89 d0                	mov    %edx,%eax
  800c1a:	fc                   	cld    
  800c1b:	f3 ab                	rep stos %eax,%es:(%edi)
  800c1d:	eb 06                	jmp    800c25 <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800c1f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c22:	fc                   	cld    
  800c23:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800c25:	89 f8                	mov    %edi,%eax
  800c27:	5b                   	pop    %ebx
  800c28:	5e                   	pop    %esi
  800c29:	5f                   	pop    %edi
  800c2a:	5d                   	pop    %ebp
  800c2b:	c3                   	ret    

00800c2c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800c2c:	f3 0f 1e fb          	endbr32 
  800c30:	55                   	push   %ebp
  800c31:	89 e5                	mov    %esp,%ebp
  800c33:	57                   	push   %edi
  800c34:	56                   	push   %esi
  800c35:	8b 45 08             	mov    0x8(%ebp),%eax
  800c38:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c3b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800c3e:	39 c6                	cmp    %eax,%esi
  800c40:	73 32                	jae    800c74 <memmove+0x48>
  800c42:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c45:	39 c2                	cmp    %eax,%edx
  800c47:	76 2b                	jbe    800c74 <memmove+0x48>
		s += n;
		d += n;
  800c49:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c4c:	89 fe                	mov    %edi,%esi
  800c4e:	09 ce                	or     %ecx,%esi
  800c50:	09 d6                	or     %edx,%esi
  800c52:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c58:	75 0e                	jne    800c68 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800c5a:	83 ef 04             	sub    $0x4,%edi
  800c5d:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c60:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800c63:	fd                   	std    
  800c64:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c66:	eb 09                	jmp    800c71 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800c68:	83 ef 01             	sub    $0x1,%edi
  800c6b:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800c6e:	fd                   	std    
  800c6f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c71:	fc                   	cld    
  800c72:	eb 1a                	jmp    800c8e <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c74:	89 c2                	mov    %eax,%edx
  800c76:	09 ca                	or     %ecx,%edx
  800c78:	09 f2                	or     %esi,%edx
  800c7a:	f6 c2 03             	test   $0x3,%dl
  800c7d:	75 0a                	jne    800c89 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800c7f:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800c82:	89 c7                	mov    %eax,%edi
  800c84:	fc                   	cld    
  800c85:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c87:	eb 05                	jmp    800c8e <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800c89:	89 c7                	mov    %eax,%edi
  800c8b:	fc                   	cld    
  800c8c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c8e:	5e                   	pop    %esi
  800c8f:	5f                   	pop    %edi
  800c90:	5d                   	pop    %ebp
  800c91:	c3                   	ret    

00800c92 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c92:	f3 0f 1e fb          	endbr32 
  800c96:	55                   	push   %ebp
  800c97:	89 e5                	mov    %esp,%ebp
  800c99:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800c9c:	ff 75 10             	pushl  0x10(%ebp)
  800c9f:	ff 75 0c             	pushl  0xc(%ebp)
  800ca2:	ff 75 08             	pushl  0x8(%ebp)
  800ca5:	e8 82 ff ff ff       	call   800c2c <memmove>
}
  800caa:	c9                   	leave  
  800cab:	c3                   	ret    

00800cac <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800cac:	f3 0f 1e fb          	endbr32 
  800cb0:	55                   	push   %ebp
  800cb1:	89 e5                	mov    %esp,%ebp
  800cb3:	56                   	push   %esi
  800cb4:	53                   	push   %ebx
  800cb5:	8b 45 08             	mov    0x8(%ebp),%eax
  800cb8:	8b 55 0c             	mov    0xc(%ebp),%edx
  800cbb:	89 c6                	mov    %eax,%esi
  800cbd:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800cc0:	39 f0                	cmp    %esi,%eax
  800cc2:	74 1c                	je     800ce0 <memcmp+0x34>
		if (*s1 != *s2)
  800cc4:	0f b6 08             	movzbl (%eax),%ecx
  800cc7:	0f b6 1a             	movzbl (%edx),%ebx
  800cca:	38 d9                	cmp    %bl,%cl
  800ccc:	75 08                	jne    800cd6 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800cce:	83 c0 01             	add    $0x1,%eax
  800cd1:	83 c2 01             	add    $0x1,%edx
  800cd4:	eb ea                	jmp    800cc0 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800cd6:	0f b6 c1             	movzbl %cl,%eax
  800cd9:	0f b6 db             	movzbl %bl,%ebx
  800cdc:	29 d8                	sub    %ebx,%eax
  800cde:	eb 05                	jmp    800ce5 <memcmp+0x39>
	}

	return 0;
  800ce0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ce5:	5b                   	pop    %ebx
  800ce6:	5e                   	pop    %esi
  800ce7:	5d                   	pop    %ebp
  800ce8:	c3                   	ret    

00800ce9 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ce9:	f3 0f 1e fb          	endbr32 
  800ced:	55                   	push   %ebp
  800cee:	89 e5                	mov    %esp,%ebp
  800cf0:	8b 45 08             	mov    0x8(%ebp),%eax
  800cf3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800cf6:	89 c2                	mov    %eax,%edx
  800cf8:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800cfb:	39 d0                	cmp    %edx,%eax
  800cfd:	73 09                	jae    800d08 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800cff:	38 08                	cmp    %cl,(%eax)
  800d01:	74 05                	je     800d08 <memfind+0x1f>
	for (; s < ends; s++)
  800d03:	83 c0 01             	add    $0x1,%eax
  800d06:	eb f3                	jmp    800cfb <memfind+0x12>
			break;
	return (void *) s;
}
  800d08:	5d                   	pop    %ebp
  800d09:	c3                   	ret    

00800d0a <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800d0a:	f3 0f 1e fb          	endbr32 
  800d0e:	55                   	push   %ebp
  800d0f:	89 e5                	mov    %esp,%ebp
  800d11:	57                   	push   %edi
  800d12:	56                   	push   %esi
  800d13:	53                   	push   %ebx
  800d14:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d17:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d1a:	eb 03                	jmp    800d1f <strtol+0x15>
		s++;
  800d1c:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800d1f:	0f b6 01             	movzbl (%ecx),%eax
  800d22:	3c 20                	cmp    $0x20,%al
  800d24:	74 f6                	je     800d1c <strtol+0x12>
  800d26:	3c 09                	cmp    $0x9,%al
  800d28:	74 f2                	je     800d1c <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800d2a:	3c 2b                	cmp    $0x2b,%al
  800d2c:	74 2a                	je     800d58 <strtol+0x4e>
	int neg = 0;
  800d2e:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800d33:	3c 2d                	cmp    $0x2d,%al
  800d35:	74 2b                	je     800d62 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d37:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800d3d:	75 0f                	jne    800d4e <strtol+0x44>
  800d3f:	80 39 30             	cmpb   $0x30,(%ecx)
  800d42:	74 28                	je     800d6c <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800d44:	85 db                	test   %ebx,%ebx
  800d46:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d4b:	0f 44 d8             	cmove  %eax,%ebx
  800d4e:	b8 00 00 00 00       	mov    $0x0,%eax
  800d53:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800d56:	eb 46                	jmp    800d9e <strtol+0x94>
		s++;
  800d58:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800d5b:	bf 00 00 00 00       	mov    $0x0,%edi
  800d60:	eb d5                	jmp    800d37 <strtol+0x2d>
		s++, neg = 1;
  800d62:	83 c1 01             	add    $0x1,%ecx
  800d65:	bf 01 00 00 00       	mov    $0x1,%edi
  800d6a:	eb cb                	jmp    800d37 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d6c:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800d70:	74 0e                	je     800d80 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800d72:	85 db                	test   %ebx,%ebx
  800d74:	75 d8                	jne    800d4e <strtol+0x44>
		s++, base = 8;
  800d76:	83 c1 01             	add    $0x1,%ecx
  800d79:	bb 08 00 00 00       	mov    $0x8,%ebx
  800d7e:	eb ce                	jmp    800d4e <strtol+0x44>
		s += 2, base = 16;
  800d80:	83 c1 02             	add    $0x2,%ecx
  800d83:	bb 10 00 00 00       	mov    $0x10,%ebx
  800d88:	eb c4                	jmp    800d4e <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800d8a:	0f be d2             	movsbl %dl,%edx
  800d8d:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800d90:	3b 55 10             	cmp    0x10(%ebp),%edx
  800d93:	7d 3a                	jge    800dcf <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800d95:	83 c1 01             	add    $0x1,%ecx
  800d98:	0f af 45 10          	imul   0x10(%ebp),%eax
  800d9c:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800d9e:	0f b6 11             	movzbl (%ecx),%edx
  800da1:	8d 72 d0             	lea    -0x30(%edx),%esi
  800da4:	89 f3                	mov    %esi,%ebx
  800da6:	80 fb 09             	cmp    $0x9,%bl
  800da9:	76 df                	jbe    800d8a <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800dab:	8d 72 9f             	lea    -0x61(%edx),%esi
  800dae:	89 f3                	mov    %esi,%ebx
  800db0:	80 fb 19             	cmp    $0x19,%bl
  800db3:	77 08                	ja     800dbd <strtol+0xb3>
			dig = *s - 'a' + 10;
  800db5:	0f be d2             	movsbl %dl,%edx
  800db8:	83 ea 57             	sub    $0x57,%edx
  800dbb:	eb d3                	jmp    800d90 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800dbd:	8d 72 bf             	lea    -0x41(%edx),%esi
  800dc0:	89 f3                	mov    %esi,%ebx
  800dc2:	80 fb 19             	cmp    $0x19,%bl
  800dc5:	77 08                	ja     800dcf <strtol+0xc5>
			dig = *s - 'A' + 10;
  800dc7:	0f be d2             	movsbl %dl,%edx
  800dca:	83 ea 37             	sub    $0x37,%edx
  800dcd:	eb c1                	jmp    800d90 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800dcf:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800dd3:	74 05                	je     800dda <strtol+0xd0>
		*endptr = (char *) s;
  800dd5:	8b 75 0c             	mov    0xc(%ebp),%esi
  800dd8:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800dda:	89 c2                	mov    %eax,%edx
  800ddc:	f7 da                	neg    %edx
  800dde:	85 ff                	test   %edi,%edi
  800de0:	0f 45 c2             	cmovne %edx,%eax
}
  800de3:	5b                   	pop    %ebx
  800de4:	5e                   	pop    %esi
  800de5:	5f                   	pop    %edi
  800de6:	5d                   	pop    %ebp
  800de7:	c3                   	ret    
  800de8:	66 90                	xchg   %ax,%ax
  800dea:	66 90                	xchg   %ax,%ax
  800dec:	66 90                	xchg   %ax,%ax
  800dee:	66 90                	xchg   %ax,%ax

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
