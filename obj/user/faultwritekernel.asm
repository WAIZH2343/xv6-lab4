
obj/user/faultwritekernel:     file format elf32-i386


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
  80002c:	e8 11 00 00 00       	call   800042 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	f3 0f 1e fb          	endbr32 
	*(unsigned*)0xf0100000 = 0;
  800037:	c7 05 00 00 10 f0 00 	movl   $0x0,0xf0100000
  80003e:	00 00 00 
}
  800041:	c3                   	ret    

00800042 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800042:	f3 0f 1e fb          	endbr32 
  800046:	55                   	push   %ebp
  800047:	89 e5                	mov    %esp,%ebp
  800049:	56                   	push   %esi
  80004a:	53                   	push   %ebx
  80004b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80004e:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv=&envs[ENVX(sys_getenvid())];
  800051:	e8 d6 00 00 00       	call   80012c <sys_getenvid>
  800056:	25 ff 03 00 00       	and    $0x3ff,%eax
  80005b:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80005e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800063:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800068:	85 db                	test   %ebx,%ebx
  80006a:	7e 07                	jle    800073 <libmain+0x31>
		binaryname = argv[0];
  80006c:	8b 06                	mov    (%esi),%eax
  80006e:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800073:	83 ec 08             	sub    $0x8,%esp
  800076:	56                   	push   %esi
  800077:	53                   	push   %ebx
  800078:	e8 b6 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80007d:	e8 0a 00 00 00       	call   80008c <exit>
}
  800082:	83 c4 10             	add    $0x10,%esp
  800085:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800088:	5b                   	pop    %ebx
  800089:	5e                   	pop    %esi
  80008a:	5d                   	pop    %ebp
  80008b:	c3                   	ret    

0080008c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80008c:	f3 0f 1e fb          	endbr32 
  800090:	55                   	push   %ebp
  800091:	89 e5                	mov    %esp,%ebp
  800093:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800096:	6a 00                	push   $0x0
  800098:	e8 4a 00 00 00       	call   8000e7 <sys_env_destroy>
}
  80009d:	83 c4 10             	add    $0x10,%esp
  8000a0:	c9                   	leave  
  8000a1:	c3                   	ret    

008000a2 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000a2:	f3 0f 1e fb          	endbr32 
  8000a6:	55                   	push   %ebp
  8000a7:	89 e5                	mov    %esp,%ebp
  8000a9:	57                   	push   %edi
  8000aa:	56                   	push   %esi
  8000ab:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000ac:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b1:	8b 55 08             	mov    0x8(%ebp),%edx
  8000b4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000b7:	89 c3                	mov    %eax,%ebx
  8000b9:	89 c7                	mov    %eax,%edi
  8000bb:	89 c6                	mov    %eax,%esi
  8000bd:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000bf:	5b                   	pop    %ebx
  8000c0:	5e                   	pop    %esi
  8000c1:	5f                   	pop    %edi
  8000c2:	5d                   	pop    %ebp
  8000c3:	c3                   	ret    

008000c4 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000c4:	f3 0f 1e fb          	endbr32 
  8000c8:	55                   	push   %ebp
  8000c9:	89 e5                	mov    %esp,%ebp
  8000cb:	57                   	push   %edi
  8000cc:	56                   	push   %esi
  8000cd:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000ce:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d3:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d8:	89 d1                	mov    %edx,%ecx
  8000da:	89 d3                	mov    %edx,%ebx
  8000dc:	89 d7                	mov    %edx,%edi
  8000de:	89 d6                	mov    %edx,%esi
  8000e0:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000e2:	5b                   	pop    %ebx
  8000e3:	5e                   	pop    %esi
  8000e4:	5f                   	pop    %edi
  8000e5:	5d                   	pop    %ebp
  8000e6:	c3                   	ret    

008000e7 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000e7:	f3 0f 1e fb          	endbr32 
  8000eb:	55                   	push   %ebp
  8000ec:	89 e5                	mov    %esp,%ebp
  8000ee:	57                   	push   %edi
  8000ef:	56                   	push   %esi
  8000f0:	53                   	push   %ebx
  8000f1:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8000f4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000f9:	8b 55 08             	mov    0x8(%ebp),%edx
  8000fc:	b8 03 00 00 00       	mov    $0x3,%eax
  800101:	89 cb                	mov    %ecx,%ebx
  800103:	89 cf                	mov    %ecx,%edi
  800105:	89 ce                	mov    %ecx,%esi
  800107:	cd 30                	int    $0x30
	if(check && ret > 0)
  800109:	85 c0                	test   %eax,%eax
  80010b:	7f 08                	jg     800115 <sys_env_destroy+0x2e>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80010d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800110:	5b                   	pop    %ebx
  800111:	5e                   	pop    %esi
  800112:	5f                   	pop    %edi
  800113:	5d                   	pop    %ebp
  800114:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800115:	83 ec 0c             	sub    $0xc,%esp
  800118:	50                   	push   %eax
  800119:	6a 03                	push   $0x3
  80011b:	68 4a 10 80 00       	push   $0x80104a
  800120:	6a 23                	push   $0x23
  800122:	68 67 10 80 00       	push   $0x801067
  800127:	e8 11 02 00 00       	call   80033d <_panic>

0080012c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80012c:	f3 0f 1e fb          	endbr32 
  800130:	55                   	push   %ebp
  800131:	89 e5                	mov    %esp,%ebp
  800133:	57                   	push   %edi
  800134:	56                   	push   %esi
  800135:	53                   	push   %ebx
	asm volatile("int %1\n"
  800136:	ba 00 00 00 00       	mov    $0x0,%edx
  80013b:	b8 02 00 00 00       	mov    $0x2,%eax
  800140:	89 d1                	mov    %edx,%ecx
  800142:	89 d3                	mov    %edx,%ebx
  800144:	89 d7                	mov    %edx,%edi
  800146:	89 d6                	mov    %edx,%esi
  800148:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80014a:	5b                   	pop    %ebx
  80014b:	5e                   	pop    %esi
  80014c:	5f                   	pop    %edi
  80014d:	5d                   	pop    %ebp
  80014e:	c3                   	ret    

0080014f <sys_yield>:

void
sys_yield(void)
{
  80014f:	f3 0f 1e fb          	endbr32 
  800153:	55                   	push   %ebp
  800154:	89 e5                	mov    %esp,%ebp
  800156:	57                   	push   %edi
  800157:	56                   	push   %esi
  800158:	53                   	push   %ebx
	asm volatile("int %1\n"
  800159:	ba 00 00 00 00       	mov    $0x0,%edx
  80015e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800163:	89 d1                	mov    %edx,%ecx
  800165:	89 d3                	mov    %edx,%ebx
  800167:	89 d7                	mov    %edx,%edi
  800169:	89 d6                	mov    %edx,%esi
  80016b:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80016d:	5b                   	pop    %ebx
  80016e:	5e                   	pop    %esi
  80016f:	5f                   	pop    %edi
  800170:	5d                   	pop    %ebp
  800171:	c3                   	ret    

00800172 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800172:	f3 0f 1e fb          	endbr32 
  800176:	55                   	push   %ebp
  800177:	89 e5                	mov    %esp,%ebp
  800179:	57                   	push   %edi
  80017a:	56                   	push   %esi
  80017b:	53                   	push   %ebx
  80017c:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80017f:	be 00 00 00 00       	mov    $0x0,%esi
  800184:	8b 55 08             	mov    0x8(%ebp),%edx
  800187:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80018a:	b8 04 00 00 00       	mov    $0x4,%eax
  80018f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800192:	89 f7                	mov    %esi,%edi
  800194:	cd 30                	int    $0x30
	if(check && ret > 0)
  800196:	85 c0                	test   %eax,%eax
  800198:	7f 08                	jg     8001a2 <sys_page_alloc+0x30>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80019a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80019d:	5b                   	pop    %ebx
  80019e:	5e                   	pop    %esi
  80019f:	5f                   	pop    %edi
  8001a0:	5d                   	pop    %ebp
  8001a1:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8001a2:	83 ec 0c             	sub    $0xc,%esp
  8001a5:	50                   	push   %eax
  8001a6:	6a 04                	push   $0x4
  8001a8:	68 4a 10 80 00       	push   $0x80104a
  8001ad:	6a 23                	push   $0x23
  8001af:	68 67 10 80 00       	push   $0x801067
  8001b4:	e8 84 01 00 00       	call   80033d <_panic>

008001b9 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001b9:	f3 0f 1e fb          	endbr32 
  8001bd:	55                   	push   %ebp
  8001be:	89 e5                	mov    %esp,%ebp
  8001c0:	57                   	push   %edi
  8001c1:	56                   	push   %esi
  8001c2:	53                   	push   %ebx
  8001c3:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001c6:	8b 55 08             	mov    0x8(%ebp),%edx
  8001c9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001cc:	b8 05 00 00 00       	mov    $0x5,%eax
  8001d1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001d4:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001d7:	8b 75 18             	mov    0x18(%ebp),%esi
  8001da:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001dc:	85 c0                	test   %eax,%eax
  8001de:	7f 08                	jg     8001e8 <sys_page_map+0x2f>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001e0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001e3:	5b                   	pop    %ebx
  8001e4:	5e                   	pop    %esi
  8001e5:	5f                   	pop    %edi
  8001e6:	5d                   	pop    %ebp
  8001e7:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8001e8:	83 ec 0c             	sub    $0xc,%esp
  8001eb:	50                   	push   %eax
  8001ec:	6a 05                	push   $0x5
  8001ee:	68 4a 10 80 00       	push   $0x80104a
  8001f3:	6a 23                	push   $0x23
  8001f5:	68 67 10 80 00       	push   $0x801067
  8001fa:	e8 3e 01 00 00       	call   80033d <_panic>

008001ff <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001ff:	f3 0f 1e fb          	endbr32 
  800203:	55                   	push   %ebp
  800204:	89 e5                	mov    %esp,%ebp
  800206:	57                   	push   %edi
  800207:	56                   	push   %esi
  800208:	53                   	push   %ebx
  800209:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80020c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800211:	8b 55 08             	mov    0x8(%ebp),%edx
  800214:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800217:	b8 06 00 00 00       	mov    $0x6,%eax
  80021c:	89 df                	mov    %ebx,%edi
  80021e:	89 de                	mov    %ebx,%esi
  800220:	cd 30                	int    $0x30
	if(check && ret > 0)
  800222:	85 c0                	test   %eax,%eax
  800224:	7f 08                	jg     80022e <sys_page_unmap+0x2f>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800226:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800229:	5b                   	pop    %ebx
  80022a:	5e                   	pop    %esi
  80022b:	5f                   	pop    %edi
  80022c:	5d                   	pop    %ebp
  80022d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80022e:	83 ec 0c             	sub    $0xc,%esp
  800231:	50                   	push   %eax
  800232:	6a 06                	push   $0x6
  800234:	68 4a 10 80 00       	push   $0x80104a
  800239:	6a 23                	push   $0x23
  80023b:	68 67 10 80 00       	push   $0x801067
  800240:	e8 f8 00 00 00       	call   80033d <_panic>

00800245 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800245:	f3 0f 1e fb          	endbr32 
  800249:	55                   	push   %ebp
  80024a:	89 e5                	mov    %esp,%ebp
  80024c:	57                   	push   %edi
  80024d:	56                   	push   %esi
  80024e:	53                   	push   %ebx
  80024f:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800252:	bb 00 00 00 00       	mov    $0x0,%ebx
  800257:	8b 55 08             	mov    0x8(%ebp),%edx
  80025a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80025d:	b8 08 00 00 00       	mov    $0x8,%eax
  800262:	89 df                	mov    %ebx,%edi
  800264:	89 de                	mov    %ebx,%esi
  800266:	cd 30                	int    $0x30
	if(check && ret > 0)
  800268:	85 c0                	test   %eax,%eax
  80026a:	7f 08                	jg     800274 <sys_env_set_status+0x2f>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80026c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80026f:	5b                   	pop    %ebx
  800270:	5e                   	pop    %esi
  800271:	5f                   	pop    %edi
  800272:	5d                   	pop    %ebp
  800273:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800274:	83 ec 0c             	sub    $0xc,%esp
  800277:	50                   	push   %eax
  800278:	6a 08                	push   $0x8
  80027a:	68 4a 10 80 00       	push   $0x80104a
  80027f:	6a 23                	push   $0x23
  800281:	68 67 10 80 00       	push   $0x801067
  800286:	e8 b2 00 00 00       	call   80033d <_panic>

0080028b <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80028b:	f3 0f 1e fb          	endbr32 
  80028f:	55                   	push   %ebp
  800290:	89 e5                	mov    %esp,%ebp
  800292:	57                   	push   %edi
  800293:	56                   	push   %esi
  800294:	53                   	push   %ebx
  800295:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800298:	bb 00 00 00 00       	mov    $0x0,%ebx
  80029d:	8b 55 08             	mov    0x8(%ebp),%edx
  8002a0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002a3:	b8 09 00 00 00       	mov    $0x9,%eax
  8002a8:	89 df                	mov    %ebx,%edi
  8002aa:	89 de                	mov    %ebx,%esi
  8002ac:	cd 30                	int    $0x30
	if(check && ret > 0)
  8002ae:	85 c0                	test   %eax,%eax
  8002b0:	7f 08                	jg     8002ba <sys_env_set_pgfault_upcall+0x2f>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002b2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002b5:	5b                   	pop    %ebx
  8002b6:	5e                   	pop    %esi
  8002b7:	5f                   	pop    %edi
  8002b8:	5d                   	pop    %ebp
  8002b9:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8002ba:	83 ec 0c             	sub    $0xc,%esp
  8002bd:	50                   	push   %eax
  8002be:	6a 09                	push   $0x9
  8002c0:	68 4a 10 80 00       	push   $0x80104a
  8002c5:	6a 23                	push   $0x23
  8002c7:	68 67 10 80 00       	push   $0x801067
  8002cc:	e8 6c 00 00 00       	call   80033d <_panic>

008002d1 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002d1:	f3 0f 1e fb          	endbr32 
  8002d5:	55                   	push   %ebp
  8002d6:	89 e5                	mov    %esp,%ebp
  8002d8:	57                   	push   %edi
  8002d9:	56                   	push   %esi
  8002da:	53                   	push   %ebx
	asm volatile("int %1\n"
  8002db:	8b 55 08             	mov    0x8(%ebp),%edx
  8002de:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002e1:	b8 0b 00 00 00       	mov    $0xb,%eax
  8002e6:	be 00 00 00 00       	mov    $0x0,%esi
  8002eb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002ee:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002f1:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8002f3:	5b                   	pop    %ebx
  8002f4:	5e                   	pop    %esi
  8002f5:	5f                   	pop    %edi
  8002f6:	5d                   	pop    %ebp
  8002f7:	c3                   	ret    

008002f8 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8002f8:	f3 0f 1e fb          	endbr32 
  8002fc:	55                   	push   %ebp
  8002fd:	89 e5                	mov    %esp,%ebp
  8002ff:	57                   	push   %edi
  800300:	56                   	push   %esi
  800301:	53                   	push   %ebx
  800302:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800305:	b9 00 00 00 00       	mov    $0x0,%ecx
  80030a:	8b 55 08             	mov    0x8(%ebp),%edx
  80030d:	b8 0c 00 00 00       	mov    $0xc,%eax
  800312:	89 cb                	mov    %ecx,%ebx
  800314:	89 cf                	mov    %ecx,%edi
  800316:	89 ce                	mov    %ecx,%esi
  800318:	cd 30                	int    $0x30
	if(check && ret > 0)
  80031a:	85 c0                	test   %eax,%eax
  80031c:	7f 08                	jg     800326 <sys_ipc_recv+0x2e>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80031e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800321:	5b                   	pop    %ebx
  800322:	5e                   	pop    %esi
  800323:	5f                   	pop    %edi
  800324:	5d                   	pop    %ebp
  800325:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800326:	83 ec 0c             	sub    $0xc,%esp
  800329:	50                   	push   %eax
  80032a:	6a 0c                	push   $0xc
  80032c:	68 4a 10 80 00       	push   $0x80104a
  800331:	6a 23                	push   $0x23
  800333:	68 67 10 80 00       	push   $0x801067
  800338:	e8 00 00 00 00       	call   80033d <_panic>

0080033d <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80033d:	f3 0f 1e fb          	endbr32 
  800341:	55                   	push   %ebp
  800342:	89 e5                	mov    %esp,%ebp
  800344:	56                   	push   %esi
  800345:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800346:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800349:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80034f:	e8 d8 fd ff ff       	call   80012c <sys_getenvid>
  800354:	83 ec 0c             	sub    $0xc,%esp
  800357:	ff 75 0c             	pushl  0xc(%ebp)
  80035a:	ff 75 08             	pushl  0x8(%ebp)
  80035d:	56                   	push   %esi
  80035e:	50                   	push   %eax
  80035f:	68 78 10 80 00       	push   $0x801078
  800364:	e8 bb 00 00 00       	call   800424 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800369:	83 c4 18             	add    $0x18,%esp
  80036c:	53                   	push   %ebx
  80036d:	ff 75 10             	pushl  0x10(%ebp)
  800370:	e8 5a 00 00 00       	call   8003cf <vcprintf>
	cprintf("\n");
  800375:	c7 04 24 9b 10 80 00 	movl   $0x80109b,(%esp)
  80037c:	e8 a3 00 00 00       	call   800424 <cprintf>
  800381:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800384:	cc                   	int3   
  800385:	eb fd                	jmp    800384 <_panic+0x47>

00800387 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800387:	f3 0f 1e fb          	endbr32 
  80038b:	55                   	push   %ebp
  80038c:	89 e5                	mov    %esp,%ebp
  80038e:	53                   	push   %ebx
  80038f:	83 ec 04             	sub    $0x4,%esp
  800392:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800395:	8b 13                	mov    (%ebx),%edx
  800397:	8d 42 01             	lea    0x1(%edx),%eax
  80039a:	89 03                	mov    %eax,(%ebx)
  80039c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80039f:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8003a3:	3d ff 00 00 00       	cmp    $0xff,%eax
  8003a8:	74 09                	je     8003b3 <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8003aa:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8003ae:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8003b1:	c9                   	leave  
  8003b2:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8003b3:	83 ec 08             	sub    $0x8,%esp
  8003b6:	68 ff 00 00 00       	push   $0xff
  8003bb:	8d 43 08             	lea    0x8(%ebx),%eax
  8003be:	50                   	push   %eax
  8003bf:	e8 de fc ff ff       	call   8000a2 <sys_cputs>
		b->idx = 0;
  8003c4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8003ca:	83 c4 10             	add    $0x10,%esp
  8003cd:	eb db                	jmp    8003aa <putch+0x23>

008003cf <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8003cf:	f3 0f 1e fb          	endbr32 
  8003d3:	55                   	push   %ebp
  8003d4:	89 e5                	mov    %esp,%ebp
  8003d6:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8003dc:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003e3:	00 00 00 
	b.cnt = 0;
  8003e6:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003ed:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003f0:	ff 75 0c             	pushl  0xc(%ebp)
  8003f3:	ff 75 08             	pushl  0x8(%ebp)
  8003f6:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003fc:	50                   	push   %eax
  8003fd:	68 87 03 80 00       	push   $0x800387
  800402:	e8 20 01 00 00       	call   800527 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800407:	83 c4 08             	add    $0x8,%esp
  80040a:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800410:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800416:	50                   	push   %eax
  800417:	e8 86 fc ff ff       	call   8000a2 <sys_cputs>

	return b.cnt;
}
  80041c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800422:	c9                   	leave  
  800423:	c3                   	ret    

00800424 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800424:	f3 0f 1e fb          	endbr32 
  800428:	55                   	push   %ebp
  800429:	89 e5                	mov    %esp,%ebp
  80042b:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80042e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800431:	50                   	push   %eax
  800432:	ff 75 08             	pushl  0x8(%ebp)
  800435:	e8 95 ff ff ff       	call   8003cf <vcprintf>
	va_end(ap);

	return cnt;
}
  80043a:	c9                   	leave  
  80043b:	c3                   	ret    

0080043c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80043c:	55                   	push   %ebp
  80043d:	89 e5                	mov    %esp,%ebp
  80043f:	57                   	push   %edi
  800440:	56                   	push   %esi
  800441:	53                   	push   %ebx
  800442:	83 ec 1c             	sub    $0x1c,%esp
  800445:	89 c7                	mov    %eax,%edi
  800447:	89 d6                	mov    %edx,%esi
  800449:	8b 45 08             	mov    0x8(%ebp),%eax
  80044c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80044f:	89 d1                	mov    %edx,%ecx
  800451:	89 c2                	mov    %eax,%edx
  800453:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800456:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800459:	8b 45 10             	mov    0x10(%ebp),%eax
  80045c:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80045f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800462:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800469:	39 c2                	cmp    %eax,%edx
  80046b:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  80046e:	72 3e                	jb     8004ae <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800470:	83 ec 0c             	sub    $0xc,%esp
  800473:	ff 75 18             	pushl  0x18(%ebp)
  800476:	83 eb 01             	sub    $0x1,%ebx
  800479:	53                   	push   %ebx
  80047a:	50                   	push   %eax
  80047b:	83 ec 08             	sub    $0x8,%esp
  80047e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800481:	ff 75 e0             	pushl  -0x20(%ebp)
  800484:	ff 75 dc             	pushl  -0x24(%ebp)
  800487:	ff 75 d8             	pushl  -0x28(%ebp)
  80048a:	e8 51 09 00 00       	call   800de0 <__udivdi3>
  80048f:	83 c4 18             	add    $0x18,%esp
  800492:	52                   	push   %edx
  800493:	50                   	push   %eax
  800494:	89 f2                	mov    %esi,%edx
  800496:	89 f8                	mov    %edi,%eax
  800498:	e8 9f ff ff ff       	call   80043c <printnum>
  80049d:	83 c4 20             	add    $0x20,%esp
  8004a0:	eb 13                	jmp    8004b5 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8004a2:	83 ec 08             	sub    $0x8,%esp
  8004a5:	56                   	push   %esi
  8004a6:	ff 75 18             	pushl  0x18(%ebp)
  8004a9:	ff d7                	call   *%edi
  8004ab:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8004ae:	83 eb 01             	sub    $0x1,%ebx
  8004b1:	85 db                	test   %ebx,%ebx
  8004b3:	7f ed                	jg     8004a2 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8004b5:	83 ec 08             	sub    $0x8,%esp
  8004b8:	56                   	push   %esi
  8004b9:	83 ec 04             	sub    $0x4,%esp
  8004bc:	ff 75 e4             	pushl  -0x1c(%ebp)
  8004bf:	ff 75 e0             	pushl  -0x20(%ebp)
  8004c2:	ff 75 dc             	pushl  -0x24(%ebp)
  8004c5:	ff 75 d8             	pushl  -0x28(%ebp)
  8004c8:	e8 23 0a 00 00       	call   800ef0 <__umoddi3>
  8004cd:	83 c4 14             	add    $0x14,%esp
  8004d0:	0f be 80 9d 10 80 00 	movsbl 0x80109d(%eax),%eax
  8004d7:	50                   	push   %eax
  8004d8:	ff d7                	call   *%edi
}
  8004da:	83 c4 10             	add    $0x10,%esp
  8004dd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004e0:	5b                   	pop    %ebx
  8004e1:	5e                   	pop    %esi
  8004e2:	5f                   	pop    %edi
  8004e3:	5d                   	pop    %ebp
  8004e4:	c3                   	ret    

008004e5 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004e5:	f3 0f 1e fb          	endbr32 
  8004e9:	55                   	push   %ebp
  8004ea:	89 e5                	mov    %esp,%ebp
  8004ec:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004ef:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004f3:	8b 10                	mov    (%eax),%edx
  8004f5:	3b 50 04             	cmp    0x4(%eax),%edx
  8004f8:	73 0a                	jae    800504 <sprintputch+0x1f>
		*b->buf++ = ch;
  8004fa:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004fd:	89 08                	mov    %ecx,(%eax)
  8004ff:	8b 45 08             	mov    0x8(%ebp),%eax
  800502:	88 02                	mov    %al,(%edx)
}
  800504:	5d                   	pop    %ebp
  800505:	c3                   	ret    

00800506 <printfmt>:
{
  800506:	f3 0f 1e fb          	endbr32 
  80050a:	55                   	push   %ebp
  80050b:	89 e5                	mov    %esp,%ebp
  80050d:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800510:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800513:	50                   	push   %eax
  800514:	ff 75 10             	pushl  0x10(%ebp)
  800517:	ff 75 0c             	pushl  0xc(%ebp)
  80051a:	ff 75 08             	pushl  0x8(%ebp)
  80051d:	e8 05 00 00 00       	call   800527 <vprintfmt>
}
  800522:	83 c4 10             	add    $0x10,%esp
  800525:	c9                   	leave  
  800526:	c3                   	ret    

00800527 <vprintfmt>:
{
  800527:	f3 0f 1e fb          	endbr32 
  80052b:	55                   	push   %ebp
  80052c:	89 e5                	mov    %esp,%ebp
  80052e:	57                   	push   %edi
  80052f:	56                   	push   %esi
  800530:	53                   	push   %ebx
  800531:	83 ec 3c             	sub    $0x3c,%esp
  800534:	8b 75 08             	mov    0x8(%ebp),%esi
  800537:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80053a:	8b 7d 10             	mov    0x10(%ebp),%edi
  80053d:	e9 cd 03 00 00       	jmp    80090f <vprintfmt+0x3e8>
		padc = ' ';
  800542:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800546:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  80054d:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800554:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80055b:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800560:	8d 47 01             	lea    0x1(%edi),%eax
  800563:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800566:	0f b6 17             	movzbl (%edi),%edx
  800569:	8d 42 dd             	lea    -0x23(%edx),%eax
  80056c:	3c 55                	cmp    $0x55,%al
  80056e:	0f 87 1e 04 00 00    	ja     800992 <vprintfmt+0x46b>
  800574:	0f b6 c0             	movzbl %al,%eax
  800577:	3e ff 24 85 60 11 80 	notrack jmp *0x801160(,%eax,4)
  80057e:	00 
  80057f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800582:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800586:	eb d8                	jmp    800560 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800588:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80058b:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  80058f:	eb cf                	jmp    800560 <vprintfmt+0x39>
  800591:	0f b6 d2             	movzbl %dl,%edx
  800594:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800597:	b8 00 00 00 00       	mov    $0x0,%eax
  80059c:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  80059f:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8005a2:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8005a6:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8005a9:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8005ac:	83 f9 09             	cmp    $0x9,%ecx
  8005af:	77 55                	ja     800606 <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  8005b1:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8005b4:	eb e9                	jmp    80059f <vprintfmt+0x78>
			precision = va_arg(ap, int);
  8005b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b9:	8b 00                	mov    (%eax),%eax
  8005bb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005be:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c1:	8d 40 04             	lea    0x4(%eax),%eax
  8005c4:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8005c7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8005ca:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005ce:	79 90                	jns    800560 <vprintfmt+0x39>
				width = precision, precision = -1;
  8005d0:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005d3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005d6:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8005dd:	eb 81                	jmp    800560 <vprintfmt+0x39>
  8005df:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005e2:	85 c0                	test   %eax,%eax
  8005e4:	ba 00 00 00 00       	mov    $0x0,%edx
  8005e9:	0f 49 d0             	cmovns %eax,%edx
  8005ec:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8005ef:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8005f2:	e9 69 ff ff ff       	jmp    800560 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8005f7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8005fa:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  800601:	e9 5a ff ff ff       	jmp    800560 <vprintfmt+0x39>
  800606:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800609:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80060c:	eb bc                	jmp    8005ca <vprintfmt+0xa3>
			lflag++;
  80060e:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800611:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800614:	e9 47 ff ff ff       	jmp    800560 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  800619:	8b 45 14             	mov    0x14(%ebp),%eax
  80061c:	8d 78 04             	lea    0x4(%eax),%edi
  80061f:	83 ec 08             	sub    $0x8,%esp
  800622:	53                   	push   %ebx
  800623:	ff 30                	pushl  (%eax)
  800625:	ff d6                	call   *%esi
			break;
  800627:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  80062a:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  80062d:	e9 da 02 00 00       	jmp    80090c <vprintfmt+0x3e5>
			err = va_arg(ap, int);
  800632:	8b 45 14             	mov    0x14(%ebp),%eax
  800635:	8d 78 04             	lea    0x4(%eax),%edi
  800638:	8b 00                	mov    (%eax),%eax
  80063a:	99                   	cltd   
  80063b:	31 d0                	xor    %edx,%eax
  80063d:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80063f:	83 f8 08             	cmp    $0x8,%eax
  800642:	7f 23                	jg     800667 <vprintfmt+0x140>
  800644:	8b 14 85 c0 12 80 00 	mov    0x8012c0(,%eax,4),%edx
  80064b:	85 d2                	test   %edx,%edx
  80064d:	74 18                	je     800667 <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  80064f:	52                   	push   %edx
  800650:	68 be 10 80 00       	push   $0x8010be
  800655:	53                   	push   %ebx
  800656:	56                   	push   %esi
  800657:	e8 aa fe ff ff       	call   800506 <printfmt>
  80065c:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80065f:	89 7d 14             	mov    %edi,0x14(%ebp)
  800662:	e9 a5 02 00 00       	jmp    80090c <vprintfmt+0x3e5>
				printfmt(putch, putdat, "error %d", err);
  800667:	50                   	push   %eax
  800668:	68 b5 10 80 00       	push   $0x8010b5
  80066d:	53                   	push   %ebx
  80066e:	56                   	push   %esi
  80066f:	e8 92 fe ff ff       	call   800506 <printfmt>
  800674:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800677:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80067a:	e9 8d 02 00 00       	jmp    80090c <vprintfmt+0x3e5>
			if ((p = va_arg(ap, char *)) == NULL)
  80067f:	8b 45 14             	mov    0x14(%ebp),%eax
  800682:	83 c0 04             	add    $0x4,%eax
  800685:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800688:	8b 45 14             	mov    0x14(%ebp),%eax
  80068b:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  80068d:	85 d2                	test   %edx,%edx
  80068f:	b8 ae 10 80 00       	mov    $0x8010ae,%eax
  800694:	0f 45 c2             	cmovne %edx,%eax
  800697:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  80069a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80069e:	7e 06                	jle    8006a6 <vprintfmt+0x17f>
  8006a0:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  8006a4:	75 0d                	jne    8006b3 <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006a6:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8006a9:	89 c7                	mov    %eax,%edi
  8006ab:	03 45 e0             	add    -0x20(%ebp),%eax
  8006ae:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006b1:	eb 55                	jmp    800708 <vprintfmt+0x1e1>
  8006b3:	83 ec 08             	sub    $0x8,%esp
  8006b6:	ff 75 d8             	pushl  -0x28(%ebp)
  8006b9:	ff 75 cc             	pushl  -0x34(%ebp)
  8006bc:	e8 85 03 00 00       	call   800a46 <strnlen>
  8006c1:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8006c4:	29 c2                	sub    %eax,%edx
  8006c6:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  8006c9:	83 c4 10             	add    $0x10,%esp
  8006cc:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  8006ce:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8006d2:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8006d5:	85 ff                	test   %edi,%edi
  8006d7:	7e 11                	jle    8006ea <vprintfmt+0x1c3>
					putch(padc, putdat);
  8006d9:	83 ec 08             	sub    $0x8,%esp
  8006dc:	53                   	push   %ebx
  8006dd:	ff 75 e0             	pushl  -0x20(%ebp)
  8006e0:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8006e2:	83 ef 01             	sub    $0x1,%edi
  8006e5:	83 c4 10             	add    $0x10,%esp
  8006e8:	eb eb                	jmp    8006d5 <vprintfmt+0x1ae>
  8006ea:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8006ed:	85 d2                	test   %edx,%edx
  8006ef:	b8 00 00 00 00       	mov    $0x0,%eax
  8006f4:	0f 49 c2             	cmovns %edx,%eax
  8006f7:	29 c2                	sub    %eax,%edx
  8006f9:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8006fc:	eb a8                	jmp    8006a6 <vprintfmt+0x17f>
					putch(ch, putdat);
  8006fe:	83 ec 08             	sub    $0x8,%esp
  800701:	53                   	push   %ebx
  800702:	52                   	push   %edx
  800703:	ff d6                	call   *%esi
  800705:	83 c4 10             	add    $0x10,%esp
  800708:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80070b:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80070d:	83 c7 01             	add    $0x1,%edi
  800710:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800714:	0f be d0             	movsbl %al,%edx
  800717:	85 d2                	test   %edx,%edx
  800719:	74 4b                	je     800766 <vprintfmt+0x23f>
  80071b:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80071f:	78 06                	js     800727 <vprintfmt+0x200>
  800721:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800725:	78 1e                	js     800745 <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
  800727:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80072b:	74 d1                	je     8006fe <vprintfmt+0x1d7>
  80072d:	0f be c0             	movsbl %al,%eax
  800730:	83 e8 20             	sub    $0x20,%eax
  800733:	83 f8 5e             	cmp    $0x5e,%eax
  800736:	76 c6                	jbe    8006fe <vprintfmt+0x1d7>
					putch('?', putdat);
  800738:	83 ec 08             	sub    $0x8,%esp
  80073b:	53                   	push   %ebx
  80073c:	6a 3f                	push   $0x3f
  80073e:	ff d6                	call   *%esi
  800740:	83 c4 10             	add    $0x10,%esp
  800743:	eb c3                	jmp    800708 <vprintfmt+0x1e1>
  800745:	89 cf                	mov    %ecx,%edi
  800747:	eb 0e                	jmp    800757 <vprintfmt+0x230>
				putch(' ', putdat);
  800749:	83 ec 08             	sub    $0x8,%esp
  80074c:	53                   	push   %ebx
  80074d:	6a 20                	push   $0x20
  80074f:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800751:	83 ef 01             	sub    $0x1,%edi
  800754:	83 c4 10             	add    $0x10,%esp
  800757:	85 ff                	test   %edi,%edi
  800759:	7f ee                	jg     800749 <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  80075b:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80075e:	89 45 14             	mov    %eax,0x14(%ebp)
  800761:	e9 a6 01 00 00       	jmp    80090c <vprintfmt+0x3e5>
  800766:	89 cf                	mov    %ecx,%edi
  800768:	eb ed                	jmp    800757 <vprintfmt+0x230>
	if (lflag >= 2)
  80076a:	83 f9 01             	cmp    $0x1,%ecx
  80076d:	7f 1f                	jg     80078e <vprintfmt+0x267>
	else if (lflag)
  80076f:	85 c9                	test   %ecx,%ecx
  800771:	74 67                	je     8007da <vprintfmt+0x2b3>
		return va_arg(*ap, long);
  800773:	8b 45 14             	mov    0x14(%ebp),%eax
  800776:	8b 00                	mov    (%eax),%eax
  800778:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80077b:	89 c1                	mov    %eax,%ecx
  80077d:	c1 f9 1f             	sar    $0x1f,%ecx
  800780:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800783:	8b 45 14             	mov    0x14(%ebp),%eax
  800786:	8d 40 04             	lea    0x4(%eax),%eax
  800789:	89 45 14             	mov    %eax,0x14(%ebp)
  80078c:	eb 17                	jmp    8007a5 <vprintfmt+0x27e>
		return va_arg(*ap, long long);
  80078e:	8b 45 14             	mov    0x14(%ebp),%eax
  800791:	8b 50 04             	mov    0x4(%eax),%edx
  800794:	8b 00                	mov    (%eax),%eax
  800796:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800799:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80079c:	8b 45 14             	mov    0x14(%ebp),%eax
  80079f:	8d 40 08             	lea    0x8(%eax),%eax
  8007a2:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8007a5:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007a8:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8007ab:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  8007b0:	85 c9                	test   %ecx,%ecx
  8007b2:	0f 89 3a 01 00 00    	jns    8008f2 <vprintfmt+0x3cb>
				putch('-', putdat);
  8007b8:	83 ec 08             	sub    $0x8,%esp
  8007bb:	53                   	push   %ebx
  8007bc:	6a 2d                	push   $0x2d
  8007be:	ff d6                	call   *%esi
				num = -(long long) num;
  8007c0:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007c3:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8007c6:	f7 da                	neg    %edx
  8007c8:	83 d1 00             	adc    $0x0,%ecx
  8007cb:	f7 d9                	neg    %ecx
  8007cd:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8007d0:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007d5:	e9 18 01 00 00       	jmp    8008f2 <vprintfmt+0x3cb>
		return va_arg(*ap, int);
  8007da:	8b 45 14             	mov    0x14(%ebp),%eax
  8007dd:	8b 00                	mov    (%eax),%eax
  8007df:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007e2:	89 c1                	mov    %eax,%ecx
  8007e4:	c1 f9 1f             	sar    $0x1f,%ecx
  8007e7:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8007ea:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ed:	8d 40 04             	lea    0x4(%eax),%eax
  8007f0:	89 45 14             	mov    %eax,0x14(%ebp)
  8007f3:	eb b0                	jmp    8007a5 <vprintfmt+0x27e>
	if (lflag >= 2)
  8007f5:	83 f9 01             	cmp    $0x1,%ecx
  8007f8:	7f 1e                	jg     800818 <vprintfmt+0x2f1>
	else if (lflag)
  8007fa:	85 c9                	test   %ecx,%ecx
  8007fc:	74 32                	je     800830 <vprintfmt+0x309>
		return va_arg(*ap, unsigned long);
  8007fe:	8b 45 14             	mov    0x14(%ebp),%eax
  800801:	8b 10                	mov    (%eax),%edx
  800803:	b9 00 00 00 00       	mov    $0x0,%ecx
  800808:	8d 40 04             	lea    0x4(%eax),%eax
  80080b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80080e:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  800813:	e9 da 00 00 00       	jmp    8008f2 <vprintfmt+0x3cb>
		return va_arg(*ap, unsigned long long);
  800818:	8b 45 14             	mov    0x14(%ebp),%eax
  80081b:	8b 10                	mov    (%eax),%edx
  80081d:	8b 48 04             	mov    0x4(%eax),%ecx
  800820:	8d 40 08             	lea    0x8(%eax),%eax
  800823:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800826:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  80082b:	e9 c2 00 00 00       	jmp    8008f2 <vprintfmt+0x3cb>
		return va_arg(*ap, unsigned int);
  800830:	8b 45 14             	mov    0x14(%ebp),%eax
  800833:	8b 10                	mov    (%eax),%edx
  800835:	b9 00 00 00 00       	mov    $0x0,%ecx
  80083a:	8d 40 04             	lea    0x4(%eax),%eax
  80083d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800840:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  800845:	e9 a8 00 00 00       	jmp    8008f2 <vprintfmt+0x3cb>
	if (lflag >= 2)
  80084a:	83 f9 01             	cmp    $0x1,%ecx
  80084d:	7f 1b                	jg     80086a <vprintfmt+0x343>
	else if (lflag)
  80084f:	85 c9                	test   %ecx,%ecx
  800851:	74 5c                	je     8008af <vprintfmt+0x388>
		return va_arg(*ap, long);
  800853:	8b 45 14             	mov    0x14(%ebp),%eax
  800856:	8b 00                	mov    (%eax),%eax
  800858:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80085b:	99                   	cltd   
  80085c:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80085f:	8b 45 14             	mov    0x14(%ebp),%eax
  800862:	8d 40 04             	lea    0x4(%eax),%eax
  800865:	89 45 14             	mov    %eax,0x14(%ebp)
  800868:	eb 17                	jmp    800881 <vprintfmt+0x35a>
		return va_arg(*ap, long long);
  80086a:	8b 45 14             	mov    0x14(%ebp),%eax
  80086d:	8b 50 04             	mov    0x4(%eax),%edx
  800870:	8b 00                	mov    (%eax),%eax
  800872:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800875:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800878:	8b 45 14             	mov    0x14(%ebp),%eax
  80087b:	8d 40 08             	lea    0x8(%eax),%eax
  80087e:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800881:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800884:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 8;
  800887:	b8 08 00 00 00       	mov    $0x8,%eax
			if ((long long) num < 0) {
  80088c:	85 c9                	test   %ecx,%ecx
  80088e:	79 62                	jns    8008f2 <vprintfmt+0x3cb>
				putch('-', putdat);
  800890:	83 ec 08             	sub    $0x8,%esp
  800893:	53                   	push   %ebx
  800894:	6a 2d                	push   $0x2d
  800896:	ff d6                	call   *%esi
				num = -(long long) num;
  800898:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80089b:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80089e:	f7 da                	neg    %edx
  8008a0:	83 d1 00             	adc    $0x0,%ecx
  8008a3:	f7 d9                	neg    %ecx
  8008a5:	83 c4 10             	add    $0x10,%esp
			base = 8;
  8008a8:	b8 08 00 00 00       	mov    $0x8,%eax
  8008ad:	eb 43                	jmp    8008f2 <vprintfmt+0x3cb>
		return va_arg(*ap, int);
  8008af:	8b 45 14             	mov    0x14(%ebp),%eax
  8008b2:	8b 00                	mov    (%eax),%eax
  8008b4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8008b7:	89 c1                	mov    %eax,%ecx
  8008b9:	c1 f9 1f             	sar    $0x1f,%ecx
  8008bc:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8008bf:	8b 45 14             	mov    0x14(%ebp),%eax
  8008c2:	8d 40 04             	lea    0x4(%eax),%eax
  8008c5:	89 45 14             	mov    %eax,0x14(%ebp)
  8008c8:	eb b7                	jmp    800881 <vprintfmt+0x35a>
			putch('0', putdat);
  8008ca:	83 ec 08             	sub    $0x8,%esp
  8008cd:	53                   	push   %ebx
  8008ce:	6a 30                	push   $0x30
  8008d0:	ff d6                	call   *%esi
			putch('x', putdat);
  8008d2:	83 c4 08             	add    $0x8,%esp
  8008d5:	53                   	push   %ebx
  8008d6:	6a 78                	push   $0x78
  8008d8:	ff d6                	call   *%esi
			num = (unsigned long long)
  8008da:	8b 45 14             	mov    0x14(%ebp),%eax
  8008dd:	8b 10                	mov    (%eax),%edx
  8008df:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8008e4:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8008e7:	8d 40 04             	lea    0x4(%eax),%eax
  8008ea:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8008ed:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  8008f2:	83 ec 0c             	sub    $0xc,%esp
  8008f5:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  8008f9:	57                   	push   %edi
  8008fa:	ff 75 e0             	pushl  -0x20(%ebp)
  8008fd:	50                   	push   %eax
  8008fe:	51                   	push   %ecx
  8008ff:	52                   	push   %edx
  800900:	89 da                	mov    %ebx,%edx
  800902:	89 f0                	mov    %esi,%eax
  800904:	e8 33 fb ff ff       	call   80043c <printnum>
			break;
  800909:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  80090c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80090f:	83 c7 01             	add    $0x1,%edi
  800912:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800916:	83 f8 25             	cmp    $0x25,%eax
  800919:	0f 84 23 fc ff ff    	je     800542 <vprintfmt+0x1b>
			if (ch == '\0')
  80091f:	85 c0                	test   %eax,%eax
  800921:	0f 84 8b 00 00 00    	je     8009b2 <vprintfmt+0x48b>
			putch(ch, putdat);
  800927:	83 ec 08             	sub    $0x8,%esp
  80092a:	53                   	push   %ebx
  80092b:	50                   	push   %eax
  80092c:	ff d6                	call   *%esi
  80092e:	83 c4 10             	add    $0x10,%esp
  800931:	eb dc                	jmp    80090f <vprintfmt+0x3e8>
	if (lflag >= 2)
  800933:	83 f9 01             	cmp    $0x1,%ecx
  800936:	7f 1b                	jg     800953 <vprintfmt+0x42c>
	else if (lflag)
  800938:	85 c9                	test   %ecx,%ecx
  80093a:	74 2c                	je     800968 <vprintfmt+0x441>
		return va_arg(*ap, unsigned long);
  80093c:	8b 45 14             	mov    0x14(%ebp),%eax
  80093f:	8b 10                	mov    (%eax),%edx
  800941:	b9 00 00 00 00       	mov    $0x0,%ecx
  800946:	8d 40 04             	lea    0x4(%eax),%eax
  800949:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80094c:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  800951:	eb 9f                	jmp    8008f2 <vprintfmt+0x3cb>
		return va_arg(*ap, unsigned long long);
  800953:	8b 45 14             	mov    0x14(%ebp),%eax
  800956:	8b 10                	mov    (%eax),%edx
  800958:	8b 48 04             	mov    0x4(%eax),%ecx
  80095b:	8d 40 08             	lea    0x8(%eax),%eax
  80095e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800961:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  800966:	eb 8a                	jmp    8008f2 <vprintfmt+0x3cb>
		return va_arg(*ap, unsigned int);
  800968:	8b 45 14             	mov    0x14(%ebp),%eax
  80096b:	8b 10                	mov    (%eax),%edx
  80096d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800972:	8d 40 04             	lea    0x4(%eax),%eax
  800975:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800978:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  80097d:	e9 70 ff ff ff       	jmp    8008f2 <vprintfmt+0x3cb>
			putch(ch, putdat);
  800982:	83 ec 08             	sub    $0x8,%esp
  800985:	53                   	push   %ebx
  800986:	6a 25                	push   $0x25
  800988:	ff d6                	call   *%esi
			break;
  80098a:	83 c4 10             	add    $0x10,%esp
  80098d:	e9 7a ff ff ff       	jmp    80090c <vprintfmt+0x3e5>
			putch('%', putdat);
  800992:	83 ec 08             	sub    $0x8,%esp
  800995:	53                   	push   %ebx
  800996:	6a 25                	push   $0x25
  800998:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80099a:	83 c4 10             	add    $0x10,%esp
  80099d:	89 f8                	mov    %edi,%eax
  80099f:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8009a3:	74 05                	je     8009aa <vprintfmt+0x483>
  8009a5:	83 e8 01             	sub    $0x1,%eax
  8009a8:	eb f5                	jmp    80099f <vprintfmt+0x478>
  8009aa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8009ad:	e9 5a ff ff ff       	jmp    80090c <vprintfmt+0x3e5>
}
  8009b2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8009b5:	5b                   	pop    %ebx
  8009b6:	5e                   	pop    %esi
  8009b7:	5f                   	pop    %edi
  8009b8:	5d                   	pop    %ebp
  8009b9:	c3                   	ret    

008009ba <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8009ba:	f3 0f 1e fb          	endbr32 
  8009be:	55                   	push   %ebp
  8009bf:	89 e5                	mov    %esp,%ebp
  8009c1:	83 ec 18             	sub    $0x18,%esp
  8009c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c7:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8009ca:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8009cd:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8009d1:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8009d4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8009db:	85 c0                	test   %eax,%eax
  8009dd:	74 26                	je     800a05 <vsnprintf+0x4b>
  8009df:	85 d2                	test   %edx,%edx
  8009e1:	7e 22                	jle    800a05 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8009e3:	ff 75 14             	pushl  0x14(%ebp)
  8009e6:	ff 75 10             	pushl  0x10(%ebp)
  8009e9:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8009ec:	50                   	push   %eax
  8009ed:	68 e5 04 80 00       	push   $0x8004e5
  8009f2:	e8 30 fb ff ff       	call   800527 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8009f7:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8009fa:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8009fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800a00:	83 c4 10             	add    $0x10,%esp
}
  800a03:	c9                   	leave  
  800a04:	c3                   	ret    
		return -E_INVAL;
  800a05:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800a0a:	eb f7                	jmp    800a03 <vsnprintf+0x49>

00800a0c <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800a0c:	f3 0f 1e fb          	endbr32 
  800a10:	55                   	push   %ebp
  800a11:	89 e5                	mov    %esp,%ebp
  800a13:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800a16:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800a19:	50                   	push   %eax
  800a1a:	ff 75 10             	pushl  0x10(%ebp)
  800a1d:	ff 75 0c             	pushl  0xc(%ebp)
  800a20:	ff 75 08             	pushl  0x8(%ebp)
  800a23:	e8 92 ff ff ff       	call   8009ba <vsnprintf>
	va_end(ap);

	return rc;
}
  800a28:	c9                   	leave  
  800a29:	c3                   	ret    

00800a2a <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800a2a:	f3 0f 1e fb          	endbr32 
  800a2e:	55                   	push   %ebp
  800a2f:	89 e5                	mov    %esp,%ebp
  800a31:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a34:	b8 00 00 00 00       	mov    $0x0,%eax
  800a39:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a3d:	74 05                	je     800a44 <strlen+0x1a>
		n++;
  800a3f:	83 c0 01             	add    $0x1,%eax
  800a42:	eb f5                	jmp    800a39 <strlen+0xf>
	return n;
}
  800a44:	5d                   	pop    %ebp
  800a45:	c3                   	ret    

00800a46 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a46:	f3 0f 1e fb          	endbr32 
  800a4a:	55                   	push   %ebp
  800a4b:	89 e5                	mov    %esp,%ebp
  800a4d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a50:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a53:	b8 00 00 00 00       	mov    $0x0,%eax
  800a58:	39 d0                	cmp    %edx,%eax
  800a5a:	74 0d                	je     800a69 <strnlen+0x23>
  800a5c:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800a60:	74 05                	je     800a67 <strnlen+0x21>
		n++;
  800a62:	83 c0 01             	add    $0x1,%eax
  800a65:	eb f1                	jmp    800a58 <strnlen+0x12>
  800a67:	89 c2                	mov    %eax,%edx
	return n;
}
  800a69:	89 d0                	mov    %edx,%eax
  800a6b:	5d                   	pop    %ebp
  800a6c:	c3                   	ret    

00800a6d <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a6d:	f3 0f 1e fb          	endbr32 
  800a71:	55                   	push   %ebp
  800a72:	89 e5                	mov    %esp,%ebp
  800a74:	53                   	push   %ebx
  800a75:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a78:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a7b:	b8 00 00 00 00       	mov    $0x0,%eax
  800a80:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800a84:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800a87:	83 c0 01             	add    $0x1,%eax
  800a8a:	84 d2                	test   %dl,%dl
  800a8c:	75 f2                	jne    800a80 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  800a8e:	89 c8                	mov    %ecx,%eax
  800a90:	5b                   	pop    %ebx
  800a91:	5d                   	pop    %ebp
  800a92:	c3                   	ret    

00800a93 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a93:	f3 0f 1e fb          	endbr32 
  800a97:	55                   	push   %ebp
  800a98:	89 e5                	mov    %esp,%ebp
  800a9a:	53                   	push   %ebx
  800a9b:	83 ec 10             	sub    $0x10,%esp
  800a9e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800aa1:	53                   	push   %ebx
  800aa2:	e8 83 ff ff ff       	call   800a2a <strlen>
  800aa7:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800aaa:	ff 75 0c             	pushl  0xc(%ebp)
  800aad:	01 d8                	add    %ebx,%eax
  800aaf:	50                   	push   %eax
  800ab0:	e8 b8 ff ff ff       	call   800a6d <strcpy>
	return dst;
}
  800ab5:	89 d8                	mov    %ebx,%eax
  800ab7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800aba:	c9                   	leave  
  800abb:	c3                   	ret    

00800abc <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800abc:	f3 0f 1e fb          	endbr32 
  800ac0:	55                   	push   %ebp
  800ac1:	89 e5                	mov    %esp,%ebp
  800ac3:	56                   	push   %esi
  800ac4:	53                   	push   %ebx
  800ac5:	8b 75 08             	mov    0x8(%ebp),%esi
  800ac8:	8b 55 0c             	mov    0xc(%ebp),%edx
  800acb:	89 f3                	mov    %esi,%ebx
  800acd:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800ad0:	89 f0                	mov    %esi,%eax
  800ad2:	39 d8                	cmp    %ebx,%eax
  800ad4:	74 11                	je     800ae7 <strncpy+0x2b>
		*dst++ = *src;
  800ad6:	83 c0 01             	add    $0x1,%eax
  800ad9:	0f b6 0a             	movzbl (%edx),%ecx
  800adc:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800adf:	80 f9 01             	cmp    $0x1,%cl
  800ae2:	83 da ff             	sbb    $0xffffffff,%edx
  800ae5:	eb eb                	jmp    800ad2 <strncpy+0x16>
	}
	return ret;
}
  800ae7:	89 f0                	mov    %esi,%eax
  800ae9:	5b                   	pop    %ebx
  800aea:	5e                   	pop    %esi
  800aeb:	5d                   	pop    %ebp
  800aec:	c3                   	ret    

00800aed <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800aed:	f3 0f 1e fb          	endbr32 
  800af1:	55                   	push   %ebp
  800af2:	89 e5                	mov    %esp,%ebp
  800af4:	56                   	push   %esi
  800af5:	53                   	push   %ebx
  800af6:	8b 75 08             	mov    0x8(%ebp),%esi
  800af9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800afc:	8b 55 10             	mov    0x10(%ebp),%edx
  800aff:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800b01:	85 d2                	test   %edx,%edx
  800b03:	74 21                	je     800b26 <strlcpy+0x39>
  800b05:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800b09:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  800b0b:	39 c2                	cmp    %eax,%edx
  800b0d:	74 14                	je     800b23 <strlcpy+0x36>
  800b0f:	0f b6 19             	movzbl (%ecx),%ebx
  800b12:	84 db                	test   %bl,%bl
  800b14:	74 0b                	je     800b21 <strlcpy+0x34>
			*dst++ = *src++;
  800b16:	83 c1 01             	add    $0x1,%ecx
  800b19:	83 c2 01             	add    $0x1,%edx
  800b1c:	88 5a ff             	mov    %bl,-0x1(%edx)
  800b1f:	eb ea                	jmp    800b0b <strlcpy+0x1e>
  800b21:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800b23:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800b26:	29 f0                	sub    %esi,%eax
}
  800b28:	5b                   	pop    %ebx
  800b29:	5e                   	pop    %esi
  800b2a:	5d                   	pop    %ebp
  800b2b:	c3                   	ret    

00800b2c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800b2c:	f3 0f 1e fb          	endbr32 
  800b30:	55                   	push   %ebp
  800b31:	89 e5                	mov    %esp,%ebp
  800b33:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b36:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800b39:	0f b6 01             	movzbl (%ecx),%eax
  800b3c:	84 c0                	test   %al,%al
  800b3e:	74 0c                	je     800b4c <strcmp+0x20>
  800b40:	3a 02                	cmp    (%edx),%al
  800b42:	75 08                	jne    800b4c <strcmp+0x20>
		p++, q++;
  800b44:	83 c1 01             	add    $0x1,%ecx
  800b47:	83 c2 01             	add    $0x1,%edx
  800b4a:	eb ed                	jmp    800b39 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800b4c:	0f b6 c0             	movzbl %al,%eax
  800b4f:	0f b6 12             	movzbl (%edx),%edx
  800b52:	29 d0                	sub    %edx,%eax
}
  800b54:	5d                   	pop    %ebp
  800b55:	c3                   	ret    

00800b56 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b56:	f3 0f 1e fb          	endbr32 
  800b5a:	55                   	push   %ebp
  800b5b:	89 e5                	mov    %esp,%ebp
  800b5d:	53                   	push   %ebx
  800b5e:	8b 45 08             	mov    0x8(%ebp),%eax
  800b61:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b64:	89 c3                	mov    %eax,%ebx
  800b66:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800b69:	eb 06                	jmp    800b71 <strncmp+0x1b>
		n--, p++, q++;
  800b6b:	83 c0 01             	add    $0x1,%eax
  800b6e:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800b71:	39 d8                	cmp    %ebx,%eax
  800b73:	74 16                	je     800b8b <strncmp+0x35>
  800b75:	0f b6 08             	movzbl (%eax),%ecx
  800b78:	84 c9                	test   %cl,%cl
  800b7a:	74 04                	je     800b80 <strncmp+0x2a>
  800b7c:	3a 0a                	cmp    (%edx),%cl
  800b7e:	74 eb                	je     800b6b <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b80:	0f b6 00             	movzbl (%eax),%eax
  800b83:	0f b6 12             	movzbl (%edx),%edx
  800b86:	29 d0                	sub    %edx,%eax
}
  800b88:	5b                   	pop    %ebx
  800b89:	5d                   	pop    %ebp
  800b8a:	c3                   	ret    
		return 0;
  800b8b:	b8 00 00 00 00       	mov    $0x0,%eax
  800b90:	eb f6                	jmp    800b88 <strncmp+0x32>

00800b92 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b92:	f3 0f 1e fb          	endbr32 
  800b96:	55                   	push   %ebp
  800b97:	89 e5                	mov    %esp,%ebp
  800b99:	8b 45 08             	mov    0x8(%ebp),%eax
  800b9c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ba0:	0f b6 10             	movzbl (%eax),%edx
  800ba3:	84 d2                	test   %dl,%dl
  800ba5:	74 09                	je     800bb0 <strchr+0x1e>
		if (*s == c)
  800ba7:	38 ca                	cmp    %cl,%dl
  800ba9:	74 0a                	je     800bb5 <strchr+0x23>
	for (; *s; s++)
  800bab:	83 c0 01             	add    $0x1,%eax
  800bae:	eb f0                	jmp    800ba0 <strchr+0xe>
			return (char *) s;
	return 0;
  800bb0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bb5:	5d                   	pop    %ebp
  800bb6:	c3                   	ret    

00800bb7 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800bb7:	f3 0f 1e fb          	endbr32 
  800bbb:	55                   	push   %ebp
  800bbc:	89 e5                	mov    %esp,%ebp
  800bbe:	8b 45 08             	mov    0x8(%ebp),%eax
  800bc1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800bc5:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800bc8:	38 ca                	cmp    %cl,%dl
  800bca:	74 09                	je     800bd5 <strfind+0x1e>
  800bcc:	84 d2                	test   %dl,%dl
  800bce:	74 05                	je     800bd5 <strfind+0x1e>
	for (; *s; s++)
  800bd0:	83 c0 01             	add    $0x1,%eax
  800bd3:	eb f0                	jmp    800bc5 <strfind+0xe>
			break;
	return (char *) s;
}
  800bd5:	5d                   	pop    %ebp
  800bd6:	c3                   	ret    

00800bd7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800bd7:	f3 0f 1e fb          	endbr32 
  800bdb:	55                   	push   %ebp
  800bdc:	89 e5                	mov    %esp,%ebp
  800bde:	57                   	push   %edi
  800bdf:	56                   	push   %esi
  800be0:	53                   	push   %ebx
  800be1:	8b 7d 08             	mov    0x8(%ebp),%edi
  800be4:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800be7:	85 c9                	test   %ecx,%ecx
  800be9:	74 31                	je     800c1c <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800beb:	89 f8                	mov    %edi,%eax
  800bed:	09 c8                	or     %ecx,%eax
  800bef:	a8 03                	test   $0x3,%al
  800bf1:	75 23                	jne    800c16 <memset+0x3f>
		c &= 0xFF;
  800bf3:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800bf7:	89 d3                	mov    %edx,%ebx
  800bf9:	c1 e3 08             	shl    $0x8,%ebx
  800bfc:	89 d0                	mov    %edx,%eax
  800bfe:	c1 e0 18             	shl    $0x18,%eax
  800c01:	89 d6                	mov    %edx,%esi
  800c03:	c1 e6 10             	shl    $0x10,%esi
  800c06:	09 f0                	or     %esi,%eax
  800c08:	09 c2                	or     %eax,%edx
  800c0a:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800c0c:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800c0f:	89 d0                	mov    %edx,%eax
  800c11:	fc                   	cld    
  800c12:	f3 ab                	rep stos %eax,%es:(%edi)
  800c14:	eb 06                	jmp    800c1c <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800c16:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c19:	fc                   	cld    
  800c1a:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800c1c:	89 f8                	mov    %edi,%eax
  800c1e:	5b                   	pop    %ebx
  800c1f:	5e                   	pop    %esi
  800c20:	5f                   	pop    %edi
  800c21:	5d                   	pop    %ebp
  800c22:	c3                   	ret    

00800c23 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800c23:	f3 0f 1e fb          	endbr32 
  800c27:	55                   	push   %ebp
  800c28:	89 e5                	mov    %esp,%ebp
  800c2a:	57                   	push   %edi
  800c2b:	56                   	push   %esi
  800c2c:	8b 45 08             	mov    0x8(%ebp),%eax
  800c2f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c32:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800c35:	39 c6                	cmp    %eax,%esi
  800c37:	73 32                	jae    800c6b <memmove+0x48>
  800c39:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c3c:	39 c2                	cmp    %eax,%edx
  800c3e:	76 2b                	jbe    800c6b <memmove+0x48>
		s += n;
		d += n;
  800c40:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c43:	89 fe                	mov    %edi,%esi
  800c45:	09 ce                	or     %ecx,%esi
  800c47:	09 d6                	or     %edx,%esi
  800c49:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c4f:	75 0e                	jne    800c5f <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800c51:	83 ef 04             	sub    $0x4,%edi
  800c54:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c57:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800c5a:	fd                   	std    
  800c5b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c5d:	eb 09                	jmp    800c68 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800c5f:	83 ef 01             	sub    $0x1,%edi
  800c62:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800c65:	fd                   	std    
  800c66:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c68:	fc                   	cld    
  800c69:	eb 1a                	jmp    800c85 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c6b:	89 c2                	mov    %eax,%edx
  800c6d:	09 ca                	or     %ecx,%edx
  800c6f:	09 f2                	or     %esi,%edx
  800c71:	f6 c2 03             	test   $0x3,%dl
  800c74:	75 0a                	jne    800c80 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800c76:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800c79:	89 c7                	mov    %eax,%edi
  800c7b:	fc                   	cld    
  800c7c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c7e:	eb 05                	jmp    800c85 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800c80:	89 c7                	mov    %eax,%edi
  800c82:	fc                   	cld    
  800c83:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c85:	5e                   	pop    %esi
  800c86:	5f                   	pop    %edi
  800c87:	5d                   	pop    %ebp
  800c88:	c3                   	ret    

00800c89 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c89:	f3 0f 1e fb          	endbr32 
  800c8d:	55                   	push   %ebp
  800c8e:	89 e5                	mov    %esp,%ebp
  800c90:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800c93:	ff 75 10             	pushl  0x10(%ebp)
  800c96:	ff 75 0c             	pushl  0xc(%ebp)
  800c99:	ff 75 08             	pushl  0x8(%ebp)
  800c9c:	e8 82 ff ff ff       	call   800c23 <memmove>
}
  800ca1:	c9                   	leave  
  800ca2:	c3                   	ret    

00800ca3 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ca3:	f3 0f 1e fb          	endbr32 
  800ca7:	55                   	push   %ebp
  800ca8:	89 e5                	mov    %esp,%ebp
  800caa:	56                   	push   %esi
  800cab:	53                   	push   %ebx
  800cac:	8b 45 08             	mov    0x8(%ebp),%eax
  800caf:	8b 55 0c             	mov    0xc(%ebp),%edx
  800cb2:	89 c6                	mov    %eax,%esi
  800cb4:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800cb7:	39 f0                	cmp    %esi,%eax
  800cb9:	74 1c                	je     800cd7 <memcmp+0x34>
		if (*s1 != *s2)
  800cbb:	0f b6 08             	movzbl (%eax),%ecx
  800cbe:	0f b6 1a             	movzbl (%edx),%ebx
  800cc1:	38 d9                	cmp    %bl,%cl
  800cc3:	75 08                	jne    800ccd <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800cc5:	83 c0 01             	add    $0x1,%eax
  800cc8:	83 c2 01             	add    $0x1,%edx
  800ccb:	eb ea                	jmp    800cb7 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800ccd:	0f b6 c1             	movzbl %cl,%eax
  800cd0:	0f b6 db             	movzbl %bl,%ebx
  800cd3:	29 d8                	sub    %ebx,%eax
  800cd5:	eb 05                	jmp    800cdc <memcmp+0x39>
	}

	return 0;
  800cd7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800cdc:	5b                   	pop    %ebx
  800cdd:	5e                   	pop    %esi
  800cde:	5d                   	pop    %ebp
  800cdf:	c3                   	ret    

00800ce0 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ce0:	f3 0f 1e fb          	endbr32 
  800ce4:	55                   	push   %ebp
  800ce5:	89 e5                	mov    %esp,%ebp
  800ce7:	8b 45 08             	mov    0x8(%ebp),%eax
  800cea:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800ced:	89 c2                	mov    %eax,%edx
  800cef:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800cf2:	39 d0                	cmp    %edx,%eax
  800cf4:	73 09                	jae    800cff <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800cf6:	38 08                	cmp    %cl,(%eax)
  800cf8:	74 05                	je     800cff <memfind+0x1f>
	for (; s < ends; s++)
  800cfa:	83 c0 01             	add    $0x1,%eax
  800cfd:	eb f3                	jmp    800cf2 <memfind+0x12>
			break;
	return (void *) s;
}
  800cff:	5d                   	pop    %ebp
  800d00:	c3                   	ret    

00800d01 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800d01:	f3 0f 1e fb          	endbr32 
  800d05:	55                   	push   %ebp
  800d06:	89 e5                	mov    %esp,%ebp
  800d08:	57                   	push   %edi
  800d09:	56                   	push   %esi
  800d0a:	53                   	push   %ebx
  800d0b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d0e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d11:	eb 03                	jmp    800d16 <strtol+0x15>
		s++;
  800d13:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800d16:	0f b6 01             	movzbl (%ecx),%eax
  800d19:	3c 20                	cmp    $0x20,%al
  800d1b:	74 f6                	je     800d13 <strtol+0x12>
  800d1d:	3c 09                	cmp    $0x9,%al
  800d1f:	74 f2                	je     800d13 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800d21:	3c 2b                	cmp    $0x2b,%al
  800d23:	74 2a                	je     800d4f <strtol+0x4e>
	int neg = 0;
  800d25:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800d2a:	3c 2d                	cmp    $0x2d,%al
  800d2c:	74 2b                	je     800d59 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d2e:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800d34:	75 0f                	jne    800d45 <strtol+0x44>
  800d36:	80 39 30             	cmpb   $0x30,(%ecx)
  800d39:	74 28                	je     800d63 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800d3b:	85 db                	test   %ebx,%ebx
  800d3d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d42:	0f 44 d8             	cmove  %eax,%ebx
  800d45:	b8 00 00 00 00       	mov    $0x0,%eax
  800d4a:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800d4d:	eb 46                	jmp    800d95 <strtol+0x94>
		s++;
  800d4f:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800d52:	bf 00 00 00 00       	mov    $0x0,%edi
  800d57:	eb d5                	jmp    800d2e <strtol+0x2d>
		s++, neg = 1;
  800d59:	83 c1 01             	add    $0x1,%ecx
  800d5c:	bf 01 00 00 00       	mov    $0x1,%edi
  800d61:	eb cb                	jmp    800d2e <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d63:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800d67:	74 0e                	je     800d77 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800d69:	85 db                	test   %ebx,%ebx
  800d6b:	75 d8                	jne    800d45 <strtol+0x44>
		s++, base = 8;
  800d6d:	83 c1 01             	add    $0x1,%ecx
  800d70:	bb 08 00 00 00       	mov    $0x8,%ebx
  800d75:	eb ce                	jmp    800d45 <strtol+0x44>
		s += 2, base = 16;
  800d77:	83 c1 02             	add    $0x2,%ecx
  800d7a:	bb 10 00 00 00       	mov    $0x10,%ebx
  800d7f:	eb c4                	jmp    800d45 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800d81:	0f be d2             	movsbl %dl,%edx
  800d84:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800d87:	3b 55 10             	cmp    0x10(%ebp),%edx
  800d8a:	7d 3a                	jge    800dc6 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800d8c:	83 c1 01             	add    $0x1,%ecx
  800d8f:	0f af 45 10          	imul   0x10(%ebp),%eax
  800d93:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800d95:	0f b6 11             	movzbl (%ecx),%edx
  800d98:	8d 72 d0             	lea    -0x30(%edx),%esi
  800d9b:	89 f3                	mov    %esi,%ebx
  800d9d:	80 fb 09             	cmp    $0x9,%bl
  800da0:	76 df                	jbe    800d81 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800da2:	8d 72 9f             	lea    -0x61(%edx),%esi
  800da5:	89 f3                	mov    %esi,%ebx
  800da7:	80 fb 19             	cmp    $0x19,%bl
  800daa:	77 08                	ja     800db4 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800dac:	0f be d2             	movsbl %dl,%edx
  800daf:	83 ea 57             	sub    $0x57,%edx
  800db2:	eb d3                	jmp    800d87 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800db4:	8d 72 bf             	lea    -0x41(%edx),%esi
  800db7:	89 f3                	mov    %esi,%ebx
  800db9:	80 fb 19             	cmp    $0x19,%bl
  800dbc:	77 08                	ja     800dc6 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800dbe:	0f be d2             	movsbl %dl,%edx
  800dc1:	83 ea 37             	sub    $0x37,%edx
  800dc4:	eb c1                	jmp    800d87 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800dc6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800dca:	74 05                	je     800dd1 <strtol+0xd0>
		*endptr = (char *) s;
  800dcc:	8b 75 0c             	mov    0xc(%ebp),%esi
  800dcf:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800dd1:	89 c2                	mov    %eax,%edx
  800dd3:	f7 da                	neg    %edx
  800dd5:	85 ff                	test   %edi,%edi
  800dd7:	0f 45 c2             	cmovne %edx,%eax
}
  800dda:	5b                   	pop    %ebx
  800ddb:	5e                   	pop    %esi
  800ddc:	5f                   	pop    %edi
  800ddd:	5d                   	pop    %ebp
  800dde:	c3                   	ret    
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
