
obj/user/faultregs:     file format elf32-i386


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
  80002c:	e8 b8 05 00 00       	call   8005e9 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <check_regs>:
static struct regs before, during, after;

static void
check_regs(struct regs* a, const char *an, struct regs* b, const char *bn,
	   const char *testname)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 0c             	sub    $0xc,%esp
  80003c:	89 c6                	mov    %eax,%esi
  80003e:	89 cb                	mov    %ecx,%ebx
	int mismatch = 0;

	cprintf("%-6s %-8s %-8s\n", "", an, bn);
  800040:	ff 75 08             	pushl  0x8(%ebp)
  800043:	52                   	push   %edx
  800044:	68 b1 16 80 00       	push   $0x8016b1
  800049:	68 80 16 80 00       	push   $0x801680
  80004e:	e8 dd 06 00 00       	call   800730 <cprintf>
			cprintf("MISMATCH\n");				\
			mismatch = 1;					\
		}							\
	} while (0)

	CHECK(edi, regs.reg_edi);
  800053:	ff 33                	pushl  (%ebx)
  800055:	ff 36                	pushl  (%esi)
  800057:	68 90 16 80 00       	push   $0x801690
  80005c:	68 94 16 80 00       	push   $0x801694
  800061:	e8 ca 06 00 00       	call   800730 <cprintf>
  800066:	83 c4 20             	add    $0x20,%esp
  800069:	8b 03                	mov    (%ebx),%eax
  80006b:	39 06                	cmp    %eax,(%esi)
  80006d:	0f 84 2e 02 00 00    	je     8002a1 <check_regs+0x26e>
  800073:	83 ec 0c             	sub    $0xc,%esp
  800076:	68 a8 16 80 00       	push   $0x8016a8
  80007b:	e8 b0 06 00 00       	call   800730 <cprintf>
  800080:	83 c4 10             	add    $0x10,%esp
  800083:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(esi, regs.reg_esi);
  800088:	ff 73 04             	pushl  0x4(%ebx)
  80008b:	ff 76 04             	pushl  0x4(%esi)
  80008e:	68 b2 16 80 00       	push   $0x8016b2
  800093:	68 94 16 80 00       	push   $0x801694
  800098:	e8 93 06 00 00       	call   800730 <cprintf>
  80009d:	83 c4 10             	add    $0x10,%esp
  8000a0:	8b 43 04             	mov    0x4(%ebx),%eax
  8000a3:	39 46 04             	cmp    %eax,0x4(%esi)
  8000a6:	0f 84 0f 02 00 00    	je     8002bb <check_regs+0x288>
  8000ac:	83 ec 0c             	sub    $0xc,%esp
  8000af:	68 a8 16 80 00       	push   $0x8016a8
  8000b4:	e8 77 06 00 00       	call   800730 <cprintf>
  8000b9:	83 c4 10             	add    $0x10,%esp
  8000bc:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebp, regs.reg_ebp);
  8000c1:	ff 73 08             	pushl  0x8(%ebx)
  8000c4:	ff 76 08             	pushl  0x8(%esi)
  8000c7:	68 b6 16 80 00       	push   $0x8016b6
  8000cc:	68 94 16 80 00       	push   $0x801694
  8000d1:	e8 5a 06 00 00       	call   800730 <cprintf>
  8000d6:	83 c4 10             	add    $0x10,%esp
  8000d9:	8b 43 08             	mov    0x8(%ebx),%eax
  8000dc:	39 46 08             	cmp    %eax,0x8(%esi)
  8000df:	0f 84 eb 01 00 00    	je     8002d0 <check_regs+0x29d>
  8000e5:	83 ec 0c             	sub    $0xc,%esp
  8000e8:	68 a8 16 80 00       	push   $0x8016a8
  8000ed:	e8 3e 06 00 00       	call   800730 <cprintf>
  8000f2:	83 c4 10             	add    $0x10,%esp
  8000f5:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebx, regs.reg_ebx);
  8000fa:	ff 73 10             	pushl  0x10(%ebx)
  8000fd:	ff 76 10             	pushl  0x10(%esi)
  800100:	68 ba 16 80 00       	push   $0x8016ba
  800105:	68 94 16 80 00       	push   $0x801694
  80010a:	e8 21 06 00 00       	call   800730 <cprintf>
  80010f:	83 c4 10             	add    $0x10,%esp
  800112:	8b 43 10             	mov    0x10(%ebx),%eax
  800115:	39 46 10             	cmp    %eax,0x10(%esi)
  800118:	0f 84 c7 01 00 00    	je     8002e5 <check_regs+0x2b2>
  80011e:	83 ec 0c             	sub    $0xc,%esp
  800121:	68 a8 16 80 00       	push   $0x8016a8
  800126:	e8 05 06 00 00       	call   800730 <cprintf>
  80012b:	83 c4 10             	add    $0x10,%esp
  80012e:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(edx, regs.reg_edx);
  800133:	ff 73 14             	pushl  0x14(%ebx)
  800136:	ff 76 14             	pushl  0x14(%esi)
  800139:	68 be 16 80 00       	push   $0x8016be
  80013e:	68 94 16 80 00       	push   $0x801694
  800143:	e8 e8 05 00 00       	call   800730 <cprintf>
  800148:	83 c4 10             	add    $0x10,%esp
  80014b:	8b 43 14             	mov    0x14(%ebx),%eax
  80014e:	39 46 14             	cmp    %eax,0x14(%esi)
  800151:	0f 84 a3 01 00 00    	je     8002fa <check_regs+0x2c7>
  800157:	83 ec 0c             	sub    $0xc,%esp
  80015a:	68 a8 16 80 00       	push   $0x8016a8
  80015f:	e8 cc 05 00 00       	call   800730 <cprintf>
  800164:	83 c4 10             	add    $0x10,%esp
  800167:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ecx, regs.reg_ecx);
  80016c:	ff 73 18             	pushl  0x18(%ebx)
  80016f:	ff 76 18             	pushl  0x18(%esi)
  800172:	68 c2 16 80 00       	push   $0x8016c2
  800177:	68 94 16 80 00       	push   $0x801694
  80017c:	e8 af 05 00 00       	call   800730 <cprintf>
  800181:	83 c4 10             	add    $0x10,%esp
  800184:	8b 43 18             	mov    0x18(%ebx),%eax
  800187:	39 46 18             	cmp    %eax,0x18(%esi)
  80018a:	0f 84 7f 01 00 00    	je     80030f <check_regs+0x2dc>
  800190:	83 ec 0c             	sub    $0xc,%esp
  800193:	68 a8 16 80 00       	push   $0x8016a8
  800198:	e8 93 05 00 00       	call   800730 <cprintf>
  80019d:	83 c4 10             	add    $0x10,%esp
  8001a0:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eax, regs.reg_eax);
  8001a5:	ff 73 1c             	pushl  0x1c(%ebx)
  8001a8:	ff 76 1c             	pushl  0x1c(%esi)
  8001ab:	68 c6 16 80 00       	push   $0x8016c6
  8001b0:	68 94 16 80 00       	push   $0x801694
  8001b5:	e8 76 05 00 00       	call   800730 <cprintf>
  8001ba:	83 c4 10             	add    $0x10,%esp
  8001bd:	8b 43 1c             	mov    0x1c(%ebx),%eax
  8001c0:	39 46 1c             	cmp    %eax,0x1c(%esi)
  8001c3:	0f 84 5b 01 00 00    	je     800324 <check_regs+0x2f1>
  8001c9:	83 ec 0c             	sub    $0xc,%esp
  8001cc:	68 a8 16 80 00       	push   $0x8016a8
  8001d1:	e8 5a 05 00 00       	call   800730 <cprintf>
  8001d6:	83 c4 10             	add    $0x10,%esp
  8001d9:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eip, eip);
  8001de:	ff 73 20             	pushl  0x20(%ebx)
  8001e1:	ff 76 20             	pushl  0x20(%esi)
  8001e4:	68 ca 16 80 00       	push   $0x8016ca
  8001e9:	68 94 16 80 00       	push   $0x801694
  8001ee:	e8 3d 05 00 00       	call   800730 <cprintf>
  8001f3:	83 c4 10             	add    $0x10,%esp
  8001f6:	8b 43 20             	mov    0x20(%ebx),%eax
  8001f9:	39 46 20             	cmp    %eax,0x20(%esi)
  8001fc:	0f 84 37 01 00 00    	je     800339 <check_regs+0x306>
  800202:	83 ec 0c             	sub    $0xc,%esp
  800205:	68 a8 16 80 00       	push   $0x8016a8
  80020a:	e8 21 05 00 00       	call   800730 <cprintf>
  80020f:	83 c4 10             	add    $0x10,%esp
  800212:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eflags, eflags);
  800217:	ff 73 24             	pushl  0x24(%ebx)
  80021a:	ff 76 24             	pushl  0x24(%esi)
  80021d:	68 ce 16 80 00       	push   $0x8016ce
  800222:	68 94 16 80 00       	push   $0x801694
  800227:	e8 04 05 00 00       	call   800730 <cprintf>
  80022c:	83 c4 10             	add    $0x10,%esp
  80022f:	8b 43 24             	mov    0x24(%ebx),%eax
  800232:	39 46 24             	cmp    %eax,0x24(%esi)
  800235:	0f 84 13 01 00 00    	je     80034e <check_regs+0x31b>
  80023b:	83 ec 0c             	sub    $0xc,%esp
  80023e:	68 a8 16 80 00       	push   $0x8016a8
  800243:	e8 e8 04 00 00       	call   800730 <cprintf>
	CHECK(esp, esp);
  800248:	ff 73 28             	pushl  0x28(%ebx)
  80024b:	ff 76 28             	pushl  0x28(%esi)
  80024e:	68 d5 16 80 00       	push   $0x8016d5
  800253:	68 94 16 80 00       	push   $0x801694
  800258:	e8 d3 04 00 00       	call   800730 <cprintf>
  80025d:	83 c4 20             	add    $0x20,%esp
  800260:	8b 43 28             	mov    0x28(%ebx),%eax
  800263:	39 46 28             	cmp    %eax,0x28(%esi)
  800266:	0f 84 53 01 00 00    	je     8003bf <check_regs+0x38c>
  80026c:	83 ec 0c             	sub    $0xc,%esp
  80026f:	68 a8 16 80 00       	push   $0x8016a8
  800274:	e8 b7 04 00 00       	call   800730 <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  800279:	83 c4 08             	add    $0x8,%esp
  80027c:	ff 75 0c             	pushl  0xc(%ebp)
  80027f:	68 d9 16 80 00       	push   $0x8016d9
  800284:	e8 a7 04 00 00       	call   800730 <cprintf>
  800289:	83 c4 10             	add    $0x10,%esp
	if (!mismatch)
		cprintf("OK\n");
	else
		cprintf("MISMATCH\n");
  80028c:	83 ec 0c             	sub    $0xc,%esp
  80028f:	68 a8 16 80 00       	push   $0x8016a8
  800294:	e8 97 04 00 00       	call   800730 <cprintf>
  800299:	83 c4 10             	add    $0x10,%esp
}
  80029c:	e9 16 01 00 00       	jmp    8003b7 <check_regs+0x384>
	CHECK(edi, regs.reg_edi);
  8002a1:	83 ec 0c             	sub    $0xc,%esp
  8002a4:	68 a4 16 80 00       	push   $0x8016a4
  8002a9:	e8 82 04 00 00       	call   800730 <cprintf>
  8002ae:	83 c4 10             	add    $0x10,%esp
	int mismatch = 0;
  8002b1:	bf 00 00 00 00       	mov    $0x0,%edi
  8002b6:	e9 cd fd ff ff       	jmp    800088 <check_regs+0x55>
	CHECK(esi, regs.reg_esi);
  8002bb:	83 ec 0c             	sub    $0xc,%esp
  8002be:	68 a4 16 80 00       	push   $0x8016a4
  8002c3:	e8 68 04 00 00       	call   800730 <cprintf>
  8002c8:	83 c4 10             	add    $0x10,%esp
  8002cb:	e9 f1 fd ff ff       	jmp    8000c1 <check_regs+0x8e>
	CHECK(ebp, regs.reg_ebp);
  8002d0:	83 ec 0c             	sub    $0xc,%esp
  8002d3:	68 a4 16 80 00       	push   $0x8016a4
  8002d8:	e8 53 04 00 00       	call   800730 <cprintf>
  8002dd:	83 c4 10             	add    $0x10,%esp
  8002e0:	e9 15 fe ff ff       	jmp    8000fa <check_regs+0xc7>
	CHECK(ebx, regs.reg_ebx);
  8002e5:	83 ec 0c             	sub    $0xc,%esp
  8002e8:	68 a4 16 80 00       	push   $0x8016a4
  8002ed:	e8 3e 04 00 00       	call   800730 <cprintf>
  8002f2:	83 c4 10             	add    $0x10,%esp
  8002f5:	e9 39 fe ff ff       	jmp    800133 <check_regs+0x100>
	CHECK(edx, regs.reg_edx);
  8002fa:	83 ec 0c             	sub    $0xc,%esp
  8002fd:	68 a4 16 80 00       	push   $0x8016a4
  800302:	e8 29 04 00 00       	call   800730 <cprintf>
  800307:	83 c4 10             	add    $0x10,%esp
  80030a:	e9 5d fe ff ff       	jmp    80016c <check_regs+0x139>
	CHECK(ecx, regs.reg_ecx);
  80030f:	83 ec 0c             	sub    $0xc,%esp
  800312:	68 a4 16 80 00       	push   $0x8016a4
  800317:	e8 14 04 00 00       	call   800730 <cprintf>
  80031c:	83 c4 10             	add    $0x10,%esp
  80031f:	e9 81 fe ff ff       	jmp    8001a5 <check_regs+0x172>
	CHECK(eax, regs.reg_eax);
  800324:	83 ec 0c             	sub    $0xc,%esp
  800327:	68 a4 16 80 00       	push   $0x8016a4
  80032c:	e8 ff 03 00 00       	call   800730 <cprintf>
  800331:	83 c4 10             	add    $0x10,%esp
  800334:	e9 a5 fe ff ff       	jmp    8001de <check_regs+0x1ab>
	CHECK(eip, eip);
  800339:	83 ec 0c             	sub    $0xc,%esp
  80033c:	68 a4 16 80 00       	push   $0x8016a4
  800341:	e8 ea 03 00 00       	call   800730 <cprintf>
  800346:	83 c4 10             	add    $0x10,%esp
  800349:	e9 c9 fe ff ff       	jmp    800217 <check_regs+0x1e4>
	CHECK(eflags, eflags);
  80034e:	83 ec 0c             	sub    $0xc,%esp
  800351:	68 a4 16 80 00       	push   $0x8016a4
  800356:	e8 d5 03 00 00       	call   800730 <cprintf>
	CHECK(esp, esp);
  80035b:	ff 73 28             	pushl  0x28(%ebx)
  80035e:	ff 76 28             	pushl  0x28(%esi)
  800361:	68 d5 16 80 00       	push   $0x8016d5
  800366:	68 94 16 80 00       	push   $0x801694
  80036b:	e8 c0 03 00 00       	call   800730 <cprintf>
  800370:	83 c4 20             	add    $0x20,%esp
  800373:	8b 43 28             	mov    0x28(%ebx),%eax
  800376:	39 46 28             	cmp    %eax,0x28(%esi)
  800379:	0f 85 ed fe ff ff    	jne    80026c <check_regs+0x239>
  80037f:	83 ec 0c             	sub    $0xc,%esp
  800382:	68 a4 16 80 00       	push   $0x8016a4
  800387:	e8 a4 03 00 00       	call   800730 <cprintf>
	cprintf("Registers %s ", testname);
  80038c:	83 c4 08             	add    $0x8,%esp
  80038f:	ff 75 0c             	pushl  0xc(%ebp)
  800392:	68 d9 16 80 00       	push   $0x8016d9
  800397:	e8 94 03 00 00       	call   800730 <cprintf>
	if (!mismatch)
  80039c:	83 c4 10             	add    $0x10,%esp
  80039f:	85 ff                	test   %edi,%edi
  8003a1:	0f 85 e5 fe ff ff    	jne    80028c <check_regs+0x259>
		cprintf("OK\n");
  8003a7:	83 ec 0c             	sub    $0xc,%esp
  8003aa:	68 a4 16 80 00       	push   $0x8016a4
  8003af:	e8 7c 03 00 00       	call   800730 <cprintf>
  8003b4:	83 c4 10             	add    $0x10,%esp
}
  8003b7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003ba:	5b                   	pop    %ebx
  8003bb:	5e                   	pop    %esi
  8003bc:	5f                   	pop    %edi
  8003bd:	5d                   	pop    %ebp
  8003be:	c3                   	ret    
	CHECK(esp, esp);
  8003bf:	83 ec 0c             	sub    $0xc,%esp
  8003c2:	68 a4 16 80 00       	push   $0x8016a4
  8003c7:	e8 64 03 00 00       	call   800730 <cprintf>
	cprintf("Registers %s ", testname);
  8003cc:	83 c4 08             	add    $0x8,%esp
  8003cf:	ff 75 0c             	pushl  0xc(%ebp)
  8003d2:	68 d9 16 80 00       	push   $0x8016d9
  8003d7:	e8 54 03 00 00       	call   800730 <cprintf>
  8003dc:	83 c4 10             	add    $0x10,%esp
  8003df:	e9 a8 fe ff ff       	jmp    80028c <check_regs+0x259>

008003e4 <pgfault>:

static void
pgfault(struct UTrapframe *utf)
{
  8003e4:	f3 0f 1e fb          	endbr32 
  8003e8:	55                   	push   %ebp
  8003e9:	89 e5                	mov    %esp,%ebp
  8003eb:	83 ec 08             	sub    $0x8,%esp
  8003ee:	8b 45 08             	mov    0x8(%ebp),%eax
	int r;

	if (utf->utf_fault_va != (uint32_t)UTEMP)
  8003f1:	8b 10                	mov    (%eax),%edx
  8003f3:	81 fa 00 00 40 00    	cmp    $0x400000,%edx
  8003f9:	0f 85 a3 00 00 00    	jne    8004a2 <pgfault+0xbe>
		panic("pgfault expected at UTEMP, got 0x%08x (eip %08x)",
		      utf->utf_fault_va, utf->utf_eip);

	// Check registers in UTrapframe
	during.regs = utf->utf_regs;
  8003ff:	8b 50 08             	mov    0x8(%eax),%edx
  800402:	89 15 60 20 80 00    	mov    %edx,0x802060
  800408:	8b 50 0c             	mov    0xc(%eax),%edx
  80040b:	89 15 64 20 80 00    	mov    %edx,0x802064
  800411:	8b 50 10             	mov    0x10(%eax),%edx
  800414:	89 15 68 20 80 00    	mov    %edx,0x802068
  80041a:	8b 50 14             	mov    0x14(%eax),%edx
  80041d:	89 15 6c 20 80 00    	mov    %edx,0x80206c
  800423:	8b 50 18             	mov    0x18(%eax),%edx
  800426:	89 15 70 20 80 00    	mov    %edx,0x802070
  80042c:	8b 50 1c             	mov    0x1c(%eax),%edx
  80042f:	89 15 74 20 80 00    	mov    %edx,0x802074
  800435:	8b 50 20             	mov    0x20(%eax),%edx
  800438:	89 15 78 20 80 00    	mov    %edx,0x802078
  80043e:	8b 50 24             	mov    0x24(%eax),%edx
  800441:	89 15 7c 20 80 00    	mov    %edx,0x80207c
	during.eip = utf->utf_eip;
  800447:	8b 50 28             	mov    0x28(%eax),%edx
  80044a:	89 15 80 20 80 00    	mov    %edx,0x802080
	during.eflags = utf->utf_eflags & ~FL_RF;
  800450:	8b 50 2c             	mov    0x2c(%eax),%edx
  800453:	81 e2 ff ff fe ff    	and    $0xfffeffff,%edx
  800459:	89 15 84 20 80 00    	mov    %edx,0x802084
	during.esp = utf->utf_esp;
  80045f:	8b 40 30             	mov    0x30(%eax),%eax
  800462:	a3 88 20 80 00       	mov    %eax,0x802088
	check_regs(&before, "before", &during, "during", "in UTrapframe");
  800467:	83 ec 08             	sub    $0x8,%esp
  80046a:	68 ff 16 80 00       	push   $0x8016ff
  80046f:	68 0d 17 80 00       	push   $0x80170d
  800474:	b9 60 20 80 00       	mov    $0x802060,%ecx
  800479:	ba f8 16 80 00       	mov    $0x8016f8,%edx
  80047e:	b8 a0 20 80 00       	mov    $0x8020a0,%eax
  800483:	e8 ab fb ff ff       	call   800033 <check_regs>

	// Map UTEMP so the write succeeds
	if ((r = sys_page_alloc(0, UTEMP, PTE_U|PTE_P|PTE_W)) < 0)
  800488:	83 c4 0c             	add    $0xc,%esp
  80048b:	6a 07                	push   $0x7
  80048d:	68 00 00 40 00       	push   $0x400000
  800492:	6a 00                	push   $0x0
  800494:	e8 22 0d 00 00       	call   8011bb <sys_page_alloc>
  800499:	83 c4 10             	add    $0x10,%esp
  80049c:	85 c0                	test   %eax,%eax
  80049e:	78 1a                	js     8004ba <pgfault+0xd6>
		panic("sys_page_alloc: %e", r);
}
  8004a0:	c9                   	leave  
  8004a1:	c3                   	ret    
		panic("pgfault expected at UTEMP, got 0x%08x (eip %08x)",
  8004a2:	83 ec 0c             	sub    $0xc,%esp
  8004a5:	ff 70 28             	pushl  0x28(%eax)
  8004a8:	52                   	push   %edx
  8004a9:	68 40 17 80 00       	push   $0x801740
  8004ae:	6a 50                	push   $0x50
  8004b0:	68 e7 16 80 00       	push   $0x8016e7
  8004b5:	e8 8f 01 00 00       	call   800649 <_panic>
		panic("sys_page_alloc: %e", r);
  8004ba:	50                   	push   %eax
  8004bb:	68 14 17 80 00       	push   $0x801714
  8004c0:	6a 5c                	push   $0x5c
  8004c2:	68 e7 16 80 00       	push   $0x8016e7
  8004c7:	e8 7d 01 00 00       	call   800649 <_panic>

008004cc <umain>:

void
umain(int argc, char **argv)
{
  8004cc:	f3 0f 1e fb          	endbr32 
  8004d0:	55                   	push   %ebp
  8004d1:	89 e5                	mov    %esp,%ebp
  8004d3:	83 ec 14             	sub    $0x14,%esp
	set_pgfault_handler(pgfault);
  8004d6:	68 e4 03 80 00       	push   $0x8003e4
  8004db:	e8 a6 0e 00 00       	call   801386 <set_pgfault_handler>

	asm volatile(
  8004e0:	50                   	push   %eax
  8004e1:	9c                   	pushf  
  8004e2:	58                   	pop    %eax
  8004e3:	0d d5 08 00 00       	or     $0x8d5,%eax
  8004e8:	50                   	push   %eax
  8004e9:	9d                   	popf   
  8004ea:	a3 c4 20 80 00       	mov    %eax,0x8020c4
  8004ef:	8d 05 2a 05 80 00    	lea    0x80052a,%eax
  8004f5:	a3 c0 20 80 00       	mov    %eax,0x8020c0
  8004fa:	58                   	pop    %eax
  8004fb:	89 3d a0 20 80 00    	mov    %edi,0x8020a0
  800501:	89 35 a4 20 80 00    	mov    %esi,0x8020a4
  800507:	89 2d a8 20 80 00    	mov    %ebp,0x8020a8
  80050d:	89 1d b0 20 80 00    	mov    %ebx,0x8020b0
  800513:	89 15 b4 20 80 00    	mov    %edx,0x8020b4
  800519:	89 0d b8 20 80 00    	mov    %ecx,0x8020b8
  80051f:	a3 bc 20 80 00       	mov    %eax,0x8020bc
  800524:	89 25 c8 20 80 00    	mov    %esp,0x8020c8
  80052a:	c7 05 00 00 40 00 2a 	movl   $0x2a,0x400000
  800531:	00 00 00 
  800534:	89 3d 20 20 80 00    	mov    %edi,0x802020
  80053a:	89 35 24 20 80 00    	mov    %esi,0x802024
  800540:	89 2d 28 20 80 00    	mov    %ebp,0x802028
  800546:	89 1d 30 20 80 00    	mov    %ebx,0x802030
  80054c:	89 15 34 20 80 00    	mov    %edx,0x802034
  800552:	89 0d 38 20 80 00    	mov    %ecx,0x802038
  800558:	a3 3c 20 80 00       	mov    %eax,0x80203c
  80055d:	89 25 48 20 80 00    	mov    %esp,0x802048
  800563:	8b 3d a0 20 80 00    	mov    0x8020a0,%edi
  800569:	8b 35 a4 20 80 00    	mov    0x8020a4,%esi
  80056f:	8b 2d a8 20 80 00    	mov    0x8020a8,%ebp
  800575:	8b 1d b0 20 80 00    	mov    0x8020b0,%ebx
  80057b:	8b 15 b4 20 80 00    	mov    0x8020b4,%edx
  800581:	8b 0d b8 20 80 00    	mov    0x8020b8,%ecx
  800587:	a1 bc 20 80 00       	mov    0x8020bc,%eax
  80058c:	8b 25 c8 20 80 00    	mov    0x8020c8,%esp
  800592:	50                   	push   %eax
  800593:	9c                   	pushf  
  800594:	58                   	pop    %eax
  800595:	a3 44 20 80 00       	mov    %eax,0x802044
  80059a:	58                   	pop    %eax
		: : "m" (before), "m" (after) : "memory", "cc");

	// Check UTEMP to roughly determine that EIP was restored
	// correctly (of course, we probably wouldn't get this far if
	// it weren't)
	if (*(int*)UTEMP != 42)
  80059b:	83 c4 10             	add    $0x10,%esp
  80059e:	83 3d 00 00 40 00 2a 	cmpl   $0x2a,0x400000
  8005a5:	75 30                	jne    8005d7 <umain+0x10b>
		cprintf("EIP after page-fault MISMATCH\n");
	after.eip = before.eip;
  8005a7:	a1 c0 20 80 00       	mov    0x8020c0,%eax
  8005ac:	a3 40 20 80 00       	mov    %eax,0x802040

	check_regs(&before, "before", &after, "after", "after page-fault");
  8005b1:	83 ec 08             	sub    $0x8,%esp
  8005b4:	68 27 17 80 00       	push   $0x801727
  8005b9:	68 38 17 80 00       	push   $0x801738
  8005be:	b9 20 20 80 00       	mov    $0x802020,%ecx
  8005c3:	ba f8 16 80 00       	mov    $0x8016f8,%edx
  8005c8:	b8 a0 20 80 00       	mov    $0x8020a0,%eax
  8005cd:	e8 61 fa ff ff       	call   800033 <check_regs>
}
  8005d2:	83 c4 10             	add    $0x10,%esp
  8005d5:	c9                   	leave  
  8005d6:	c3                   	ret    
		cprintf("EIP after page-fault MISMATCH\n");
  8005d7:	83 ec 0c             	sub    $0xc,%esp
  8005da:	68 74 17 80 00       	push   $0x801774
  8005df:	e8 4c 01 00 00       	call   800730 <cprintf>
  8005e4:	83 c4 10             	add    $0x10,%esp
  8005e7:	eb be                	jmp    8005a7 <umain+0xdb>

008005e9 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8005e9:	f3 0f 1e fb          	endbr32 
  8005ed:	55                   	push   %ebp
  8005ee:	89 e5                	mov    %esp,%ebp
  8005f0:	56                   	push   %esi
  8005f1:	53                   	push   %ebx
  8005f2:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8005f5:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv=&envs[ENVX(sys_getenvid())];
  8005f8:	e8 78 0b 00 00       	call   801175 <sys_getenvid>
  8005fd:	25 ff 03 00 00       	and    $0x3ff,%eax
  800602:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800605:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80060a:	a3 cc 20 80 00       	mov    %eax,0x8020cc

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80060f:	85 db                	test   %ebx,%ebx
  800611:	7e 07                	jle    80061a <libmain+0x31>
		binaryname = argv[0];
  800613:	8b 06                	mov    (%esi),%eax
  800615:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80061a:	83 ec 08             	sub    $0x8,%esp
  80061d:	56                   	push   %esi
  80061e:	53                   	push   %ebx
  80061f:	e8 a8 fe ff ff       	call   8004cc <umain>

	// exit gracefully
	exit();
  800624:	e8 0a 00 00 00       	call   800633 <exit>
}
  800629:	83 c4 10             	add    $0x10,%esp
  80062c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80062f:	5b                   	pop    %ebx
  800630:	5e                   	pop    %esi
  800631:	5d                   	pop    %ebp
  800632:	c3                   	ret    

00800633 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800633:	f3 0f 1e fb          	endbr32 
  800637:	55                   	push   %ebp
  800638:	89 e5                	mov    %esp,%ebp
  80063a:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80063d:	6a 00                	push   $0x0
  80063f:	e8 ec 0a 00 00       	call   801130 <sys_env_destroy>
}
  800644:	83 c4 10             	add    $0x10,%esp
  800647:	c9                   	leave  
  800648:	c3                   	ret    

00800649 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800649:	f3 0f 1e fb          	endbr32 
  80064d:	55                   	push   %ebp
  80064e:	89 e5                	mov    %esp,%ebp
  800650:	56                   	push   %esi
  800651:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800652:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800655:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80065b:	e8 15 0b 00 00       	call   801175 <sys_getenvid>
  800660:	83 ec 0c             	sub    $0xc,%esp
  800663:	ff 75 0c             	pushl  0xc(%ebp)
  800666:	ff 75 08             	pushl  0x8(%ebp)
  800669:	56                   	push   %esi
  80066a:	50                   	push   %eax
  80066b:	68 a0 17 80 00       	push   $0x8017a0
  800670:	e8 bb 00 00 00       	call   800730 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800675:	83 c4 18             	add    $0x18,%esp
  800678:	53                   	push   %ebx
  800679:	ff 75 10             	pushl  0x10(%ebp)
  80067c:	e8 5a 00 00 00       	call   8006db <vcprintf>
	cprintf("\n");
  800681:	c7 04 24 b0 16 80 00 	movl   $0x8016b0,(%esp)
  800688:	e8 a3 00 00 00       	call   800730 <cprintf>
  80068d:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800690:	cc                   	int3   
  800691:	eb fd                	jmp    800690 <_panic+0x47>

00800693 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800693:	f3 0f 1e fb          	endbr32 
  800697:	55                   	push   %ebp
  800698:	89 e5                	mov    %esp,%ebp
  80069a:	53                   	push   %ebx
  80069b:	83 ec 04             	sub    $0x4,%esp
  80069e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8006a1:	8b 13                	mov    (%ebx),%edx
  8006a3:	8d 42 01             	lea    0x1(%edx),%eax
  8006a6:	89 03                	mov    %eax,(%ebx)
  8006a8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006ab:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8006af:	3d ff 00 00 00       	cmp    $0xff,%eax
  8006b4:	74 09                	je     8006bf <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8006b6:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8006ba:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006bd:	c9                   	leave  
  8006be:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8006bf:	83 ec 08             	sub    $0x8,%esp
  8006c2:	68 ff 00 00 00       	push   $0xff
  8006c7:	8d 43 08             	lea    0x8(%ebx),%eax
  8006ca:	50                   	push   %eax
  8006cb:	e8 1b 0a 00 00       	call   8010eb <sys_cputs>
		b->idx = 0;
  8006d0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8006d6:	83 c4 10             	add    $0x10,%esp
  8006d9:	eb db                	jmp    8006b6 <putch+0x23>

008006db <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8006db:	f3 0f 1e fb          	endbr32 
  8006df:	55                   	push   %ebp
  8006e0:	89 e5                	mov    %esp,%ebp
  8006e2:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8006e8:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8006ef:	00 00 00 
	b.cnt = 0;
  8006f2:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8006f9:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8006fc:	ff 75 0c             	pushl  0xc(%ebp)
  8006ff:	ff 75 08             	pushl  0x8(%ebp)
  800702:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800708:	50                   	push   %eax
  800709:	68 93 06 80 00       	push   $0x800693
  80070e:	e8 20 01 00 00       	call   800833 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800713:	83 c4 08             	add    $0x8,%esp
  800716:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80071c:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800722:	50                   	push   %eax
  800723:	e8 c3 09 00 00       	call   8010eb <sys_cputs>

	return b.cnt;
}
  800728:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80072e:	c9                   	leave  
  80072f:	c3                   	ret    

00800730 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800730:	f3 0f 1e fb          	endbr32 
  800734:	55                   	push   %ebp
  800735:	89 e5                	mov    %esp,%ebp
  800737:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80073a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80073d:	50                   	push   %eax
  80073e:	ff 75 08             	pushl  0x8(%ebp)
  800741:	e8 95 ff ff ff       	call   8006db <vcprintf>
	va_end(ap);

	return cnt;
}
  800746:	c9                   	leave  
  800747:	c3                   	ret    

00800748 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800748:	55                   	push   %ebp
  800749:	89 e5                	mov    %esp,%ebp
  80074b:	57                   	push   %edi
  80074c:	56                   	push   %esi
  80074d:	53                   	push   %ebx
  80074e:	83 ec 1c             	sub    $0x1c,%esp
  800751:	89 c7                	mov    %eax,%edi
  800753:	89 d6                	mov    %edx,%esi
  800755:	8b 45 08             	mov    0x8(%ebp),%eax
  800758:	8b 55 0c             	mov    0xc(%ebp),%edx
  80075b:	89 d1                	mov    %edx,%ecx
  80075d:	89 c2                	mov    %eax,%edx
  80075f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800762:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800765:	8b 45 10             	mov    0x10(%ebp),%eax
  800768:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80076b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80076e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800775:	39 c2                	cmp    %eax,%edx
  800777:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  80077a:	72 3e                	jb     8007ba <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80077c:	83 ec 0c             	sub    $0xc,%esp
  80077f:	ff 75 18             	pushl  0x18(%ebp)
  800782:	83 eb 01             	sub    $0x1,%ebx
  800785:	53                   	push   %ebx
  800786:	50                   	push   %eax
  800787:	83 ec 08             	sub    $0x8,%esp
  80078a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80078d:	ff 75 e0             	pushl  -0x20(%ebp)
  800790:	ff 75 dc             	pushl  -0x24(%ebp)
  800793:	ff 75 d8             	pushl  -0x28(%ebp)
  800796:	e8 75 0c 00 00       	call   801410 <__udivdi3>
  80079b:	83 c4 18             	add    $0x18,%esp
  80079e:	52                   	push   %edx
  80079f:	50                   	push   %eax
  8007a0:	89 f2                	mov    %esi,%edx
  8007a2:	89 f8                	mov    %edi,%eax
  8007a4:	e8 9f ff ff ff       	call   800748 <printnum>
  8007a9:	83 c4 20             	add    $0x20,%esp
  8007ac:	eb 13                	jmp    8007c1 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8007ae:	83 ec 08             	sub    $0x8,%esp
  8007b1:	56                   	push   %esi
  8007b2:	ff 75 18             	pushl  0x18(%ebp)
  8007b5:	ff d7                	call   *%edi
  8007b7:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8007ba:	83 eb 01             	sub    $0x1,%ebx
  8007bd:	85 db                	test   %ebx,%ebx
  8007bf:	7f ed                	jg     8007ae <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8007c1:	83 ec 08             	sub    $0x8,%esp
  8007c4:	56                   	push   %esi
  8007c5:	83 ec 04             	sub    $0x4,%esp
  8007c8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8007cb:	ff 75 e0             	pushl  -0x20(%ebp)
  8007ce:	ff 75 dc             	pushl  -0x24(%ebp)
  8007d1:	ff 75 d8             	pushl  -0x28(%ebp)
  8007d4:	e8 47 0d 00 00       	call   801520 <__umoddi3>
  8007d9:	83 c4 14             	add    $0x14,%esp
  8007dc:	0f be 80 c3 17 80 00 	movsbl 0x8017c3(%eax),%eax
  8007e3:	50                   	push   %eax
  8007e4:	ff d7                	call   *%edi
}
  8007e6:	83 c4 10             	add    $0x10,%esp
  8007e9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007ec:	5b                   	pop    %ebx
  8007ed:	5e                   	pop    %esi
  8007ee:	5f                   	pop    %edi
  8007ef:	5d                   	pop    %ebp
  8007f0:	c3                   	ret    

008007f1 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8007f1:	f3 0f 1e fb          	endbr32 
  8007f5:	55                   	push   %ebp
  8007f6:	89 e5                	mov    %esp,%ebp
  8007f8:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8007fb:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8007ff:	8b 10                	mov    (%eax),%edx
  800801:	3b 50 04             	cmp    0x4(%eax),%edx
  800804:	73 0a                	jae    800810 <sprintputch+0x1f>
		*b->buf++ = ch;
  800806:	8d 4a 01             	lea    0x1(%edx),%ecx
  800809:	89 08                	mov    %ecx,(%eax)
  80080b:	8b 45 08             	mov    0x8(%ebp),%eax
  80080e:	88 02                	mov    %al,(%edx)
}
  800810:	5d                   	pop    %ebp
  800811:	c3                   	ret    

00800812 <printfmt>:
{
  800812:	f3 0f 1e fb          	endbr32 
  800816:	55                   	push   %ebp
  800817:	89 e5                	mov    %esp,%ebp
  800819:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80081c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80081f:	50                   	push   %eax
  800820:	ff 75 10             	pushl  0x10(%ebp)
  800823:	ff 75 0c             	pushl  0xc(%ebp)
  800826:	ff 75 08             	pushl  0x8(%ebp)
  800829:	e8 05 00 00 00       	call   800833 <vprintfmt>
}
  80082e:	83 c4 10             	add    $0x10,%esp
  800831:	c9                   	leave  
  800832:	c3                   	ret    

00800833 <vprintfmt>:
{
  800833:	f3 0f 1e fb          	endbr32 
  800837:	55                   	push   %ebp
  800838:	89 e5                	mov    %esp,%ebp
  80083a:	57                   	push   %edi
  80083b:	56                   	push   %esi
  80083c:	53                   	push   %ebx
  80083d:	83 ec 3c             	sub    $0x3c,%esp
  800840:	8b 75 08             	mov    0x8(%ebp),%esi
  800843:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800846:	8b 7d 10             	mov    0x10(%ebp),%edi
  800849:	e9 cd 03 00 00       	jmp    800c1b <vprintfmt+0x3e8>
		padc = ' ';
  80084e:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800852:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800859:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800860:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800867:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80086c:	8d 47 01             	lea    0x1(%edi),%eax
  80086f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800872:	0f b6 17             	movzbl (%edi),%edx
  800875:	8d 42 dd             	lea    -0x23(%edx),%eax
  800878:	3c 55                	cmp    $0x55,%al
  80087a:	0f 87 1e 04 00 00    	ja     800c9e <vprintfmt+0x46b>
  800880:	0f b6 c0             	movzbl %al,%eax
  800883:	3e ff 24 85 80 18 80 	notrack jmp *0x801880(,%eax,4)
  80088a:	00 
  80088b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80088e:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800892:	eb d8                	jmp    80086c <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800894:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800897:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  80089b:	eb cf                	jmp    80086c <vprintfmt+0x39>
  80089d:	0f b6 d2             	movzbl %dl,%edx
  8008a0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8008a3:	b8 00 00 00 00       	mov    $0x0,%eax
  8008a8:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8008ab:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8008ae:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8008b2:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8008b5:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8008b8:	83 f9 09             	cmp    $0x9,%ecx
  8008bb:	77 55                	ja     800912 <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  8008bd:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8008c0:	eb e9                	jmp    8008ab <vprintfmt+0x78>
			precision = va_arg(ap, int);
  8008c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8008c5:	8b 00                	mov    (%eax),%eax
  8008c7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8008ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8008cd:	8d 40 04             	lea    0x4(%eax),%eax
  8008d0:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8008d3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8008d6:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8008da:	79 90                	jns    80086c <vprintfmt+0x39>
				width = precision, precision = -1;
  8008dc:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8008df:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8008e2:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8008e9:	eb 81                	jmp    80086c <vprintfmt+0x39>
  8008eb:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8008ee:	85 c0                	test   %eax,%eax
  8008f0:	ba 00 00 00 00       	mov    $0x0,%edx
  8008f5:	0f 49 d0             	cmovns %eax,%edx
  8008f8:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8008fb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8008fe:	e9 69 ff ff ff       	jmp    80086c <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800903:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800906:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  80090d:	e9 5a ff ff ff       	jmp    80086c <vprintfmt+0x39>
  800912:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800915:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800918:	eb bc                	jmp    8008d6 <vprintfmt+0xa3>
			lflag++;
  80091a:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80091d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800920:	e9 47 ff ff ff       	jmp    80086c <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  800925:	8b 45 14             	mov    0x14(%ebp),%eax
  800928:	8d 78 04             	lea    0x4(%eax),%edi
  80092b:	83 ec 08             	sub    $0x8,%esp
  80092e:	53                   	push   %ebx
  80092f:	ff 30                	pushl  (%eax)
  800931:	ff d6                	call   *%esi
			break;
  800933:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800936:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800939:	e9 da 02 00 00       	jmp    800c18 <vprintfmt+0x3e5>
			err = va_arg(ap, int);
  80093e:	8b 45 14             	mov    0x14(%ebp),%eax
  800941:	8d 78 04             	lea    0x4(%eax),%edi
  800944:	8b 00                	mov    (%eax),%eax
  800946:	99                   	cltd   
  800947:	31 d0                	xor    %edx,%eax
  800949:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80094b:	83 f8 08             	cmp    $0x8,%eax
  80094e:	7f 23                	jg     800973 <vprintfmt+0x140>
  800950:	8b 14 85 e0 19 80 00 	mov    0x8019e0(,%eax,4),%edx
  800957:	85 d2                	test   %edx,%edx
  800959:	74 18                	je     800973 <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  80095b:	52                   	push   %edx
  80095c:	68 e4 17 80 00       	push   $0x8017e4
  800961:	53                   	push   %ebx
  800962:	56                   	push   %esi
  800963:	e8 aa fe ff ff       	call   800812 <printfmt>
  800968:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80096b:	89 7d 14             	mov    %edi,0x14(%ebp)
  80096e:	e9 a5 02 00 00       	jmp    800c18 <vprintfmt+0x3e5>
				printfmt(putch, putdat, "error %d", err);
  800973:	50                   	push   %eax
  800974:	68 db 17 80 00       	push   $0x8017db
  800979:	53                   	push   %ebx
  80097a:	56                   	push   %esi
  80097b:	e8 92 fe ff ff       	call   800812 <printfmt>
  800980:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800983:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800986:	e9 8d 02 00 00       	jmp    800c18 <vprintfmt+0x3e5>
			if ((p = va_arg(ap, char *)) == NULL)
  80098b:	8b 45 14             	mov    0x14(%ebp),%eax
  80098e:	83 c0 04             	add    $0x4,%eax
  800991:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800994:	8b 45 14             	mov    0x14(%ebp),%eax
  800997:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  800999:	85 d2                	test   %edx,%edx
  80099b:	b8 d4 17 80 00       	mov    $0x8017d4,%eax
  8009a0:	0f 45 c2             	cmovne %edx,%eax
  8009a3:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8009a6:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8009aa:	7e 06                	jle    8009b2 <vprintfmt+0x17f>
  8009ac:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  8009b0:	75 0d                	jne    8009bf <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  8009b2:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8009b5:	89 c7                	mov    %eax,%edi
  8009b7:	03 45 e0             	add    -0x20(%ebp),%eax
  8009ba:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8009bd:	eb 55                	jmp    800a14 <vprintfmt+0x1e1>
  8009bf:	83 ec 08             	sub    $0x8,%esp
  8009c2:	ff 75 d8             	pushl  -0x28(%ebp)
  8009c5:	ff 75 cc             	pushl  -0x34(%ebp)
  8009c8:	e8 85 03 00 00       	call   800d52 <strnlen>
  8009cd:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8009d0:	29 c2                	sub    %eax,%edx
  8009d2:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  8009d5:	83 c4 10             	add    $0x10,%esp
  8009d8:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  8009da:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8009de:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8009e1:	85 ff                	test   %edi,%edi
  8009e3:	7e 11                	jle    8009f6 <vprintfmt+0x1c3>
					putch(padc, putdat);
  8009e5:	83 ec 08             	sub    $0x8,%esp
  8009e8:	53                   	push   %ebx
  8009e9:	ff 75 e0             	pushl  -0x20(%ebp)
  8009ec:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8009ee:	83 ef 01             	sub    $0x1,%edi
  8009f1:	83 c4 10             	add    $0x10,%esp
  8009f4:	eb eb                	jmp    8009e1 <vprintfmt+0x1ae>
  8009f6:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8009f9:	85 d2                	test   %edx,%edx
  8009fb:	b8 00 00 00 00       	mov    $0x0,%eax
  800a00:	0f 49 c2             	cmovns %edx,%eax
  800a03:	29 c2                	sub    %eax,%edx
  800a05:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800a08:	eb a8                	jmp    8009b2 <vprintfmt+0x17f>
					putch(ch, putdat);
  800a0a:	83 ec 08             	sub    $0x8,%esp
  800a0d:	53                   	push   %ebx
  800a0e:	52                   	push   %edx
  800a0f:	ff d6                	call   *%esi
  800a11:	83 c4 10             	add    $0x10,%esp
  800a14:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800a17:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a19:	83 c7 01             	add    $0x1,%edi
  800a1c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800a20:	0f be d0             	movsbl %al,%edx
  800a23:	85 d2                	test   %edx,%edx
  800a25:	74 4b                	je     800a72 <vprintfmt+0x23f>
  800a27:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800a2b:	78 06                	js     800a33 <vprintfmt+0x200>
  800a2d:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800a31:	78 1e                	js     800a51 <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
  800a33:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800a37:	74 d1                	je     800a0a <vprintfmt+0x1d7>
  800a39:	0f be c0             	movsbl %al,%eax
  800a3c:	83 e8 20             	sub    $0x20,%eax
  800a3f:	83 f8 5e             	cmp    $0x5e,%eax
  800a42:	76 c6                	jbe    800a0a <vprintfmt+0x1d7>
					putch('?', putdat);
  800a44:	83 ec 08             	sub    $0x8,%esp
  800a47:	53                   	push   %ebx
  800a48:	6a 3f                	push   $0x3f
  800a4a:	ff d6                	call   *%esi
  800a4c:	83 c4 10             	add    $0x10,%esp
  800a4f:	eb c3                	jmp    800a14 <vprintfmt+0x1e1>
  800a51:	89 cf                	mov    %ecx,%edi
  800a53:	eb 0e                	jmp    800a63 <vprintfmt+0x230>
				putch(' ', putdat);
  800a55:	83 ec 08             	sub    $0x8,%esp
  800a58:	53                   	push   %ebx
  800a59:	6a 20                	push   $0x20
  800a5b:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800a5d:	83 ef 01             	sub    $0x1,%edi
  800a60:	83 c4 10             	add    $0x10,%esp
  800a63:	85 ff                	test   %edi,%edi
  800a65:	7f ee                	jg     800a55 <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  800a67:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800a6a:	89 45 14             	mov    %eax,0x14(%ebp)
  800a6d:	e9 a6 01 00 00       	jmp    800c18 <vprintfmt+0x3e5>
  800a72:	89 cf                	mov    %ecx,%edi
  800a74:	eb ed                	jmp    800a63 <vprintfmt+0x230>
	if (lflag >= 2)
  800a76:	83 f9 01             	cmp    $0x1,%ecx
  800a79:	7f 1f                	jg     800a9a <vprintfmt+0x267>
	else if (lflag)
  800a7b:	85 c9                	test   %ecx,%ecx
  800a7d:	74 67                	je     800ae6 <vprintfmt+0x2b3>
		return va_arg(*ap, long);
  800a7f:	8b 45 14             	mov    0x14(%ebp),%eax
  800a82:	8b 00                	mov    (%eax),%eax
  800a84:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800a87:	89 c1                	mov    %eax,%ecx
  800a89:	c1 f9 1f             	sar    $0x1f,%ecx
  800a8c:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800a8f:	8b 45 14             	mov    0x14(%ebp),%eax
  800a92:	8d 40 04             	lea    0x4(%eax),%eax
  800a95:	89 45 14             	mov    %eax,0x14(%ebp)
  800a98:	eb 17                	jmp    800ab1 <vprintfmt+0x27e>
		return va_arg(*ap, long long);
  800a9a:	8b 45 14             	mov    0x14(%ebp),%eax
  800a9d:	8b 50 04             	mov    0x4(%eax),%edx
  800aa0:	8b 00                	mov    (%eax),%eax
  800aa2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800aa5:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800aa8:	8b 45 14             	mov    0x14(%ebp),%eax
  800aab:	8d 40 08             	lea    0x8(%eax),%eax
  800aae:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800ab1:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800ab4:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800ab7:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  800abc:	85 c9                	test   %ecx,%ecx
  800abe:	0f 89 3a 01 00 00    	jns    800bfe <vprintfmt+0x3cb>
				putch('-', putdat);
  800ac4:	83 ec 08             	sub    $0x8,%esp
  800ac7:	53                   	push   %ebx
  800ac8:	6a 2d                	push   $0x2d
  800aca:	ff d6                	call   *%esi
				num = -(long long) num;
  800acc:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800acf:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800ad2:	f7 da                	neg    %edx
  800ad4:	83 d1 00             	adc    $0x0,%ecx
  800ad7:	f7 d9                	neg    %ecx
  800ad9:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800adc:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ae1:	e9 18 01 00 00       	jmp    800bfe <vprintfmt+0x3cb>
		return va_arg(*ap, int);
  800ae6:	8b 45 14             	mov    0x14(%ebp),%eax
  800ae9:	8b 00                	mov    (%eax),%eax
  800aeb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800aee:	89 c1                	mov    %eax,%ecx
  800af0:	c1 f9 1f             	sar    $0x1f,%ecx
  800af3:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800af6:	8b 45 14             	mov    0x14(%ebp),%eax
  800af9:	8d 40 04             	lea    0x4(%eax),%eax
  800afc:	89 45 14             	mov    %eax,0x14(%ebp)
  800aff:	eb b0                	jmp    800ab1 <vprintfmt+0x27e>
	if (lflag >= 2)
  800b01:	83 f9 01             	cmp    $0x1,%ecx
  800b04:	7f 1e                	jg     800b24 <vprintfmt+0x2f1>
	else if (lflag)
  800b06:	85 c9                	test   %ecx,%ecx
  800b08:	74 32                	je     800b3c <vprintfmt+0x309>
		return va_arg(*ap, unsigned long);
  800b0a:	8b 45 14             	mov    0x14(%ebp),%eax
  800b0d:	8b 10                	mov    (%eax),%edx
  800b0f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b14:	8d 40 04             	lea    0x4(%eax),%eax
  800b17:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800b1a:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  800b1f:	e9 da 00 00 00       	jmp    800bfe <vprintfmt+0x3cb>
		return va_arg(*ap, unsigned long long);
  800b24:	8b 45 14             	mov    0x14(%ebp),%eax
  800b27:	8b 10                	mov    (%eax),%edx
  800b29:	8b 48 04             	mov    0x4(%eax),%ecx
  800b2c:	8d 40 08             	lea    0x8(%eax),%eax
  800b2f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800b32:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  800b37:	e9 c2 00 00 00       	jmp    800bfe <vprintfmt+0x3cb>
		return va_arg(*ap, unsigned int);
  800b3c:	8b 45 14             	mov    0x14(%ebp),%eax
  800b3f:	8b 10                	mov    (%eax),%edx
  800b41:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b46:	8d 40 04             	lea    0x4(%eax),%eax
  800b49:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800b4c:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  800b51:	e9 a8 00 00 00       	jmp    800bfe <vprintfmt+0x3cb>
	if (lflag >= 2)
  800b56:	83 f9 01             	cmp    $0x1,%ecx
  800b59:	7f 1b                	jg     800b76 <vprintfmt+0x343>
	else if (lflag)
  800b5b:	85 c9                	test   %ecx,%ecx
  800b5d:	74 5c                	je     800bbb <vprintfmt+0x388>
		return va_arg(*ap, long);
  800b5f:	8b 45 14             	mov    0x14(%ebp),%eax
  800b62:	8b 00                	mov    (%eax),%eax
  800b64:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b67:	99                   	cltd   
  800b68:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800b6b:	8b 45 14             	mov    0x14(%ebp),%eax
  800b6e:	8d 40 04             	lea    0x4(%eax),%eax
  800b71:	89 45 14             	mov    %eax,0x14(%ebp)
  800b74:	eb 17                	jmp    800b8d <vprintfmt+0x35a>
		return va_arg(*ap, long long);
  800b76:	8b 45 14             	mov    0x14(%ebp),%eax
  800b79:	8b 50 04             	mov    0x4(%eax),%edx
  800b7c:	8b 00                	mov    (%eax),%eax
  800b7e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b81:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800b84:	8b 45 14             	mov    0x14(%ebp),%eax
  800b87:	8d 40 08             	lea    0x8(%eax),%eax
  800b8a:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800b8d:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800b90:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 8;
  800b93:	b8 08 00 00 00       	mov    $0x8,%eax
			if ((long long) num < 0) {
  800b98:	85 c9                	test   %ecx,%ecx
  800b9a:	79 62                	jns    800bfe <vprintfmt+0x3cb>
				putch('-', putdat);
  800b9c:	83 ec 08             	sub    $0x8,%esp
  800b9f:	53                   	push   %ebx
  800ba0:	6a 2d                	push   $0x2d
  800ba2:	ff d6                	call   *%esi
				num = -(long long) num;
  800ba4:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800ba7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800baa:	f7 da                	neg    %edx
  800bac:	83 d1 00             	adc    $0x0,%ecx
  800baf:	f7 d9                	neg    %ecx
  800bb1:	83 c4 10             	add    $0x10,%esp
			base = 8;
  800bb4:	b8 08 00 00 00       	mov    $0x8,%eax
  800bb9:	eb 43                	jmp    800bfe <vprintfmt+0x3cb>
		return va_arg(*ap, int);
  800bbb:	8b 45 14             	mov    0x14(%ebp),%eax
  800bbe:	8b 00                	mov    (%eax),%eax
  800bc0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800bc3:	89 c1                	mov    %eax,%ecx
  800bc5:	c1 f9 1f             	sar    $0x1f,%ecx
  800bc8:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800bcb:	8b 45 14             	mov    0x14(%ebp),%eax
  800bce:	8d 40 04             	lea    0x4(%eax),%eax
  800bd1:	89 45 14             	mov    %eax,0x14(%ebp)
  800bd4:	eb b7                	jmp    800b8d <vprintfmt+0x35a>
			putch('0', putdat);
  800bd6:	83 ec 08             	sub    $0x8,%esp
  800bd9:	53                   	push   %ebx
  800bda:	6a 30                	push   $0x30
  800bdc:	ff d6                	call   *%esi
			putch('x', putdat);
  800bde:	83 c4 08             	add    $0x8,%esp
  800be1:	53                   	push   %ebx
  800be2:	6a 78                	push   $0x78
  800be4:	ff d6                	call   *%esi
			num = (unsigned long long)
  800be6:	8b 45 14             	mov    0x14(%ebp),%eax
  800be9:	8b 10                	mov    (%eax),%edx
  800beb:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800bf0:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800bf3:	8d 40 04             	lea    0x4(%eax),%eax
  800bf6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800bf9:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  800bfe:	83 ec 0c             	sub    $0xc,%esp
  800c01:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  800c05:	57                   	push   %edi
  800c06:	ff 75 e0             	pushl  -0x20(%ebp)
  800c09:	50                   	push   %eax
  800c0a:	51                   	push   %ecx
  800c0b:	52                   	push   %edx
  800c0c:	89 da                	mov    %ebx,%edx
  800c0e:	89 f0                	mov    %esi,%eax
  800c10:	e8 33 fb ff ff       	call   800748 <printnum>
			break;
  800c15:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  800c18:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800c1b:	83 c7 01             	add    $0x1,%edi
  800c1e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800c22:	83 f8 25             	cmp    $0x25,%eax
  800c25:	0f 84 23 fc ff ff    	je     80084e <vprintfmt+0x1b>
			if (ch == '\0')
  800c2b:	85 c0                	test   %eax,%eax
  800c2d:	0f 84 8b 00 00 00    	je     800cbe <vprintfmt+0x48b>
			putch(ch, putdat);
  800c33:	83 ec 08             	sub    $0x8,%esp
  800c36:	53                   	push   %ebx
  800c37:	50                   	push   %eax
  800c38:	ff d6                	call   *%esi
  800c3a:	83 c4 10             	add    $0x10,%esp
  800c3d:	eb dc                	jmp    800c1b <vprintfmt+0x3e8>
	if (lflag >= 2)
  800c3f:	83 f9 01             	cmp    $0x1,%ecx
  800c42:	7f 1b                	jg     800c5f <vprintfmt+0x42c>
	else if (lflag)
  800c44:	85 c9                	test   %ecx,%ecx
  800c46:	74 2c                	je     800c74 <vprintfmt+0x441>
		return va_arg(*ap, unsigned long);
  800c48:	8b 45 14             	mov    0x14(%ebp),%eax
  800c4b:	8b 10                	mov    (%eax),%edx
  800c4d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c52:	8d 40 04             	lea    0x4(%eax),%eax
  800c55:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800c58:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  800c5d:	eb 9f                	jmp    800bfe <vprintfmt+0x3cb>
		return va_arg(*ap, unsigned long long);
  800c5f:	8b 45 14             	mov    0x14(%ebp),%eax
  800c62:	8b 10                	mov    (%eax),%edx
  800c64:	8b 48 04             	mov    0x4(%eax),%ecx
  800c67:	8d 40 08             	lea    0x8(%eax),%eax
  800c6a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800c6d:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  800c72:	eb 8a                	jmp    800bfe <vprintfmt+0x3cb>
		return va_arg(*ap, unsigned int);
  800c74:	8b 45 14             	mov    0x14(%ebp),%eax
  800c77:	8b 10                	mov    (%eax),%edx
  800c79:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c7e:	8d 40 04             	lea    0x4(%eax),%eax
  800c81:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800c84:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  800c89:	e9 70 ff ff ff       	jmp    800bfe <vprintfmt+0x3cb>
			putch(ch, putdat);
  800c8e:	83 ec 08             	sub    $0x8,%esp
  800c91:	53                   	push   %ebx
  800c92:	6a 25                	push   $0x25
  800c94:	ff d6                	call   *%esi
			break;
  800c96:	83 c4 10             	add    $0x10,%esp
  800c99:	e9 7a ff ff ff       	jmp    800c18 <vprintfmt+0x3e5>
			putch('%', putdat);
  800c9e:	83 ec 08             	sub    $0x8,%esp
  800ca1:	53                   	push   %ebx
  800ca2:	6a 25                	push   $0x25
  800ca4:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800ca6:	83 c4 10             	add    $0x10,%esp
  800ca9:	89 f8                	mov    %edi,%eax
  800cab:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800caf:	74 05                	je     800cb6 <vprintfmt+0x483>
  800cb1:	83 e8 01             	sub    $0x1,%eax
  800cb4:	eb f5                	jmp    800cab <vprintfmt+0x478>
  800cb6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800cb9:	e9 5a ff ff ff       	jmp    800c18 <vprintfmt+0x3e5>
}
  800cbe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cc1:	5b                   	pop    %ebx
  800cc2:	5e                   	pop    %esi
  800cc3:	5f                   	pop    %edi
  800cc4:	5d                   	pop    %ebp
  800cc5:	c3                   	ret    

00800cc6 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800cc6:	f3 0f 1e fb          	endbr32 
  800cca:	55                   	push   %ebp
  800ccb:	89 e5                	mov    %esp,%ebp
  800ccd:	83 ec 18             	sub    $0x18,%esp
  800cd0:	8b 45 08             	mov    0x8(%ebp),%eax
  800cd3:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800cd6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800cd9:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800cdd:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800ce0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800ce7:	85 c0                	test   %eax,%eax
  800ce9:	74 26                	je     800d11 <vsnprintf+0x4b>
  800ceb:	85 d2                	test   %edx,%edx
  800ced:	7e 22                	jle    800d11 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800cef:	ff 75 14             	pushl  0x14(%ebp)
  800cf2:	ff 75 10             	pushl  0x10(%ebp)
  800cf5:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800cf8:	50                   	push   %eax
  800cf9:	68 f1 07 80 00       	push   $0x8007f1
  800cfe:	e8 30 fb ff ff       	call   800833 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800d03:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800d06:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800d09:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d0c:	83 c4 10             	add    $0x10,%esp
}
  800d0f:	c9                   	leave  
  800d10:	c3                   	ret    
		return -E_INVAL;
  800d11:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800d16:	eb f7                	jmp    800d0f <vsnprintf+0x49>

00800d18 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800d18:	f3 0f 1e fb          	endbr32 
  800d1c:	55                   	push   %ebp
  800d1d:	89 e5                	mov    %esp,%ebp
  800d1f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800d22:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800d25:	50                   	push   %eax
  800d26:	ff 75 10             	pushl  0x10(%ebp)
  800d29:	ff 75 0c             	pushl  0xc(%ebp)
  800d2c:	ff 75 08             	pushl  0x8(%ebp)
  800d2f:	e8 92 ff ff ff       	call   800cc6 <vsnprintf>
	va_end(ap);

	return rc;
}
  800d34:	c9                   	leave  
  800d35:	c3                   	ret    

00800d36 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800d36:	f3 0f 1e fb          	endbr32 
  800d3a:	55                   	push   %ebp
  800d3b:	89 e5                	mov    %esp,%ebp
  800d3d:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800d40:	b8 00 00 00 00       	mov    $0x0,%eax
  800d45:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800d49:	74 05                	je     800d50 <strlen+0x1a>
		n++;
  800d4b:	83 c0 01             	add    $0x1,%eax
  800d4e:	eb f5                	jmp    800d45 <strlen+0xf>
	return n;
}
  800d50:	5d                   	pop    %ebp
  800d51:	c3                   	ret    

00800d52 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800d52:	f3 0f 1e fb          	endbr32 
  800d56:	55                   	push   %ebp
  800d57:	89 e5                	mov    %esp,%ebp
  800d59:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d5c:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800d5f:	b8 00 00 00 00       	mov    $0x0,%eax
  800d64:	39 d0                	cmp    %edx,%eax
  800d66:	74 0d                	je     800d75 <strnlen+0x23>
  800d68:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800d6c:	74 05                	je     800d73 <strnlen+0x21>
		n++;
  800d6e:	83 c0 01             	add    $0x1,%eax
  800d71:	eb f1                	jmp    800d64 <strnlen+0x12>
  800d73:	89 c2                	mov    %eax,%edx
	return n;
}
  800d75:	89 d0                	mov    %edx,%eax
  800d77:	5d                   	pop    %ebp
  800d78:	c3                   	ret    

00800d79 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800d79:	f3 0f 1e fb          	endbr32 
  800d7d:	55                   	push   %ebp
  800d7e:	89 e5                	mov    %esp,%ebp
  800d80:	53                   	push   %ebx
  800d81:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d84:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800d87:	b8 00 00 00 00       	mov    $0x0,%eax
  800d8c:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800d90:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800d93:	83 c0 01             	add    $0x1,%eax
  800d96:	84 d2                	test   %dl,%dl
  800d98:	75 f2                	jne    800d8c <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  800d9a:	89 c8                	mov    %ecx,%eax
  800d9c:	5b                   	pop    %ebx
  800d9d:	5d                   	pop    %ebp
  800d9e:	c3                   	ret    

00800d9f <strcat>:

char *
strcat(char *dst, const char *src)
{
  800d9f:	f3 0f 1e fb          	endbr32 
  800da3:	55                   	push   %ebp
  800da4:	89 e5                	mov    %esp,%ebp
  800da6:	53                   	push   %ebx
  800da7:	83 ec 10             	sub    $0x10,%esp
  800daa:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800dad:	53                   	push   %ebx
  800dae:	e8 83 ff ff ff       	call   800d36 <strlen>
  800db3:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800db6:	ff 75 0c             	pushl  0xc(%ebp)
  800db9:	01 d8                	add    %ebx,%eax
  800dbb:	50                   	push   %eax
  800dbc:	e8 b8 ff ff ff       	call   800d79 <strcpy>
	return dst;
}
  800dc1:	89 d8                	mov    %ebx,%eax
  800dc3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800dc6:	c9                   	leave  
  800dc7:	c3                   	ret    

00800dc8 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800dc8:	f3 0f 1e fb          	endbr32 
  800dcc:	55                   	push   %ebp
  800dcd:	89 e5                	mov    %esp,%ebp
  800dcf:	56                   	push   %esi
  800dd0:	53                   	push   %ebx
  800dd1:	8b 75 08             	mov    0x8(%ebp),%esi
  800dd4:	8b 55 0c             	mov    0xc(%ebp),%edx
  800dd7:	89 f3                	mov    %esi,%ebx
  800dd9:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800ddc:	89 f0                	mov    %esi,%eax
  800dde:	39 d8                	cmp    %ebx,%eax
  800de0:	74 11                	je     800df3 <strncpy+0x2b>
		*dst++ = *src;
  800de2:	83 c0 01             	add    $0x1,%eax
  800de5:	0f b6 0a             	movzbl (%edx),%ecx
  800de8:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800deb:	80 f9 01             	cmp    $0x1,%cl
  800dee:	83 da ff             	sbb    $0xffffffff,%edx
  800df1:	eb eb                	jmp    800dde <strncpy+0x16>
	}
	return ret;
}
  800df3:	89 f0                	mov    %esi,%eax
  800df5:	5b                   	pop    %ebx
  800df6:	5e                   	pop    %esi
  800df7:	5d                   	pop    %ebp
  800df8:	c3                   	ret    

00800df9 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800df9:	f3 0f 1e fb          	endbr32 
  800dfd:	55                   	push   %ebp
  800dfe:	89 e5                	mov    %esp,%ebp
  800e00:	56                   	push   %esi
  800e01:	53                   	push   %ebx
  800e02:	8b 75 08             	mov    0x8(%ebp),%esi
  800e05:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e08:	8b 55 10             	mov    0x10(%ebp),%edx
  800e0b:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800e0d:	85 d2                	test   %edx,%edx
  800e0f:	74 21                	je     800e32 <strlcpy+0x39>
  800e11:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800e15:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  800e17:	39 c2                	cmp    %eax,%edx
  800e19:	74 14                	je     800e2f <strlcpy+0x36>
  800e1b:	0f b6 19             	movzbl (%ecx),%ebx
  800e1e:	84 db                	test   %bl,%bl
  800e20:	74 0b                	je     800e2d <strlcpy+0x34>
			*dst++ = *src++;
  800e22:	83 c1 01             	add    $0x1,%ecx
  800e25:	83 c2 01             	add    $0x1,%edx
  800e28:	88 5a ff             	mov    %bl,-0x1(%edx)
  800e2b:	eb ea                	jmp    800e17 <strlcpy+0x1e>
  800e2d:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800e2f:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800e32:	29 f0                	sub    %esi,%eax
}
  800e34:	5b                   	pop    %ebx
  800e35:	5e                   	pop    %esi
  800e36:	5d                   	pop    %ebp
  800e37:	c3                   	ret    

00800e38 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800e38:	f3 0f 1e fb          	endbr32 
  800e3c:	55                   	push   %ebp
  800e3d:	89 e5                	mov    %esp,%ebp
  800e3f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e42:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800e45:	0f b6 01             	movzbl (%ecx),%eax
  800e48:	84 c0                	test   %al,%al
  800e4a:	74 0c                	je     800e58 <strcmp+0x20>
  800e4c:	3a 02                	cmp    (%edx),%al
  800e4e:	75 08                	jne    800e58 <strcmp+0x20>
		p++, q++;
  800e50:	83 c1 01             	add    $0x1,%ecx
  800e53:	83 c2 01             	add    $0x1,%edx
  800e56:	eb ed                	jmp    800e45 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800e58:	0f b6 c0             	movzbl %al,%eax
  800e5b:	0f b6 12             	movzbl (%edx),%edx
  800e5e:	29 d0                	sub    %edx,%eax
}
  800e60:	5d                   	pop    %ebp
  800e61:	c3                   	ret    

00800e62 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800e62:	f3 0f 1e fb          	endbr32 
  800e66:	55                   	push   %ebp
  800e67:	89 e5                	mov    %esp,%ebp
  800e69:	53                   	push   %ebx
  800e6a:	8b 45 08             	mov    0x8(%ebp),%eax
  800e6d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e70:	89 c3                	mov    %eax,%ebx
  800e72:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800e75:	eb 06                	jmp    800e7d <strncmp+0x1b>
		n--, p++, q++;
  800e77:	83 c0 01             	add    $0x1,%eax
  800e7a:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800e7d:	39 d8                	cmp    %ebx,%eax
  800e7f:	74 16                	je     800e97 <strncmp+0x35>
  800e81:	0f b6 08             	movzbl (%eax),%ecx
  800e84:	84 c9                	test   %cl,%cl
  800e86:	74 04                	je     800e8c <strncmp+0x2a>
  800e88:	3a 0a                	cmp    (%edx),%cl
  800e8a:	74 eb                	je     800e77 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800e8c:	0f b6 00             	movzbl (%eax),%eax
  800e8f:	0f b6 12             	movzbl (%edx),%edx
  800e92:	29 d0                	sub    %edx,%eax
}
  800e94:	5b                   	pop    %ebx
  800e95:	5d                   	pop    %ebp
  800e96:	c3                   	ret    
		return 0;
  800e97:	b8 00 00 00 00       	mov    $0x0,%eax
  800e9c:	eb f6                	jmp    800e94 <strncmp+0x32>

00800e9e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800e9e:	f3 0f 1e fb          	endbr32 
  800ea2:	55                   	push   %ebp
  800ea3:	89 e5                	mov    %esp,%ebp
  800ea5:	8b 45 08             	mov    0x8(%ebp),%eax
  800ea8:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800eac:	0f b6 10             	movzbl (%eax),%edx
  800eaf:	84 d2                	test   %dl,%dl
  800eb1:	74 09                	je     800ebc <strchr+0x1e>
		if (*s == c)
  800eb3:	38 ca                	cmp    %cl,%dl
  800eb5:	74 0a                	je     800ec1 <strchr+0x23>
	for (; *s; s++)
  800eb7:	83 c0 01             	add    $0x1,%eax
  800eba:	eb f0                	jmp    800eac <strchr+0xe>
			return (char *) s;
	return 0;
  800ebc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ec1:	5d                   	pop    %ebp
  800ec2:	c3                   	ret    

00800ec3 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800ec3:	f3 0f 1e fb          	endbr32 
  800ec7:	55                   	push   %ebp
  800ec8:	89 e5                	mov    %esp,%ebp
  800eca:	8b 45 08             	mov    0x8(%ebp),%eax
  800ecd:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ed1:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800ed4:	38 ca                	cmp    %cl,%dl
  800ed6:	74 09                	je     800ee1 <strfind+0x1e>
  800ed8:	84 d2                	test   %dl,%dl
  800eda:	74 05                	je     800ee1 <strfind+0x1e>
	for (; *s; s++)
  800edc:	83 c0 01             	add    $0x1,%eax
  800edf:	eb f0                	jmp    800ed1 <strfind+0xe>
			break;
	return (char *) s;
}
  800ee1:	5d                   	pop    %ebp
  800ee2:	c3                   	ret    

00800ee3 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800ee3:	f3 0f 1e fb          	endbr32 
  800ee7:	55                   	push   %ebp
  800ee8:	89 e5                	mov    %esp,%ebp
  800eea:	57                   	push   %edi
  800eeb:	56                   	push   %esi
  800eec:	53                   	push   %ebx
  800eed:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ef0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800ef3:	85 c9                	test   %ecx,%ecx
  800ef5:	74 31                	je     800f28 <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800ef7:	89 f8                	mov    %edi,%eax
  800ef9:	09 c8                	or     %ecx,%eax
  800efb:	a8 03                	test   $0x3,%al
  800efd:	75 23                	jne    800f22 <memset+0x3f>
		c &= 0xFF;
  800eff:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800f03:	89 d3                	mov    %edx,%ebx
  800f05:	c1 e3 08             	shl    $0x8,%ebx
  800f08:	89 d0                	mov    %edx,%eax
  800f0a:	c1 e0 18             	shl    $0x18,%eax
  800f0d:	89 d6                	mov    %edx,%esi
  800f0f:	c1 e6 10             	shl    $0x10,%esi
  800f12:	09 f0                	or     %esi,%eax
  800f14:	09 c2                	or     %eax,%edx
  800f16:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800f18:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800f1b:	89 d0                	mov    %edx,%eax
  800f1d:	fc                   	cld    
  800f1e:	f3 ab                	rep stos %eax,%es:(%edi)
  800f20:	eb 06                	jmp    800f28 <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800f22:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f25:	fc                   	cld    
  800f26:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800f28:	89 f8                	mov    %edi,%eax
  800f2a:	5b                   	pop    %ebx
  800f2b:	5e                   	pop    %esi
  800f2c:	5f                   	pop    %edi
  800f2d:	5d                   	pop    %ebp
  800f2e:	c3                   	ret    

00800f2f <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800f2f:	f3 0f 1e fb          	endbr32 
  800f33:	55                   	push   %ebp
  800f34:	89 e5                	mov    %esp,%ebp
  800f36:	57                   	push   %edi
  800f37:	56                   	push   %esi
  800f38:	8b 45 08             	mov    0x8(%ebp),%eax
  800f3b:	8b 75 0c             	mov    0xc(%ebp),%esi
  800f3e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800f41:	39 c6                	cmp    %eax,%esi
  800f43:	73 32                	jae    800f77 <memmove+0x48>
  800f45:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800f48:	39 c2                	cmp    %eax,%edx
  800f4a:	76 2b                	jbe    800f77 <memmove+0x48>
		s += n;
		d += n;
  800f4c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f4f:	89 fe                	mov    %edi,%esi
  800f51:	09 ce                	or     %ecx,%esi
  800f53:	09 d6                	or     %edx,%esi
  800f55:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800f5b:	75 0e                	jne    800f6b <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800f5d:	83 ef 04             	sub    $0x4,%edi
  800f60:	8d 72 fc             	lea    -0x4(%edx),%esi
  800f63:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800f66:	fd                   	std    
  800f67:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f69:	eb 09                	jmp    800f74 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800f6b:	83 ef 01             	sub    $0x1,%edi
  800f6e:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800f71:	fd                   	std    
  800f72:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800f74:	fc                   	cld    
  800f75:	eb 1a                	jmp    800f91 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f77:	89 c2                	mov    %eax,%edx
  800f79:	09 ca                	or     %ecx,%edx
  800f7b:	09 f2                	or     %esi,%edx
  800f7d:	f6 c2 03             	test   $0x3,%dl
  800f80:	75 0a                	jne    800f8c <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800f82:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800f85:	89 c7                	mov    %eax,%edi
  800f87:	fc                   	cld    
  800f88:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f8a:	eb 05                	jmp    800f91 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800f8c:	89 c7                	mov    %eax,%edi
  800f8e:	fc                   	cld    
  800f8f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800f91:	5e                   	pop    %esi
  800f92:	5f                   	pop    %edi
  800f93:	5d                   	pop    %ebp
  800f94:	c3                   	ret    

00800f95 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800f95:	f3 0f 1e fb          	endbr32 
  800f99:	55                   	push   %ebp
  800f9a:	89 e5                	mov    %esp,%ebp
  800f9c:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800f9f:	ff 75 10             	pushl  0x10(%ebp)
  800fa2:	ff 75 0c             	pushl  0xc(%ebp)
  800fa5:	ff 75 08             	pushl  0x8(%ebp)
  800fa8:	e8 82 ff ff ff       	call   800f2f <memmove>
}
  800fad:	c9                   	leave  
  800fae:	c3                   	ret    

00800faf <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800faf:	f3 0f 1e fb          	endbr32 
  800fb3:	55                   	push   %ebp
  800fb4:	89 e5                	mov    %esp,%ebp
  800fb6:	56                   	push   %esi
  800fb7:	53                   	push   %ebx
  800fb8:	8b 45 08             	mov    0x8(%ebp),%eax
  800fbb:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fbe:	89 c6                	mov    %eax,%esi
  800fc0:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800fc3:	39 f0                	cmp    %esi,%eax
  800fc5:	74 1c                	je     800fe3 <memcmp+0x34>
		if (*s1 != *s2)
  800fc7:	0f b6 08             	movzbl (%eax),%ecx
  800fca:	0f b6 1a             	movzbl (%edx),%ebx
  800fcd:	38 d9                	cmp    %bl,%cl
  800fcf:	75 08                	jne    800fd9 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800fd1:	83 c0 01             	add    $0x1,%eax
  800fd4:	83 c2 01             	add    $0x1,%edx
  800fd7:	eb ea                	jmp    800fc3 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800fd9:	0f b6 c1             	movzbl %cl,%eax
  800fdc:	0f b6 db             	movzbl %bl,%ebx
  800fdf:	29 d8                	sub    %ebx,%eax
  800fe1:	eb 05                	jmp    800fe8 <memcmp+0x39>
	}

	return 0;
  800fe3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800fe8:	5b                   	pop    %ebx
  800fe9:	5e                   	pop    %esi
  800fea:	5d                   	pop    %ebp
  800feb:	c3                   	ret    

00800fec <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800fec:	f3 0f 1e fb          	endbr32 
  800ff0:	55                   	push   %ebp
  800ff1:	89 e5                	mov    %esp,%ebp
  800ff3:	8b 45 08             	mov    0x8(%ebp),%eax
  800ff6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800ff9:	89 c2                	mov    %eax,%edx
  800ffb:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800ffe:	39 d0                	cmp    %edx,%eax
  801000:	73 09                	jae    80100b <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  801002:	38 08                	cmp    %cl,(%eax)
  801004:	74 05                	je     80100b <memfind+0x1f>
	for (; s < ends; s++)
  801006:	83 c0 01             	add    $0x1,%eax
  801009:	eb f3                	jmp    800ffe <memfind+0x12>
			break;
	return (void *) s;
}
  80100b:	5d                   	pop    %ebp
  80100c:	c3                   	ret    

0080100d <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80100d:	f3 0f 1e fb          	endbr32 
  801011:	55                   	push   %ebp
  801012:	89 e5                	mov    %esp,%ebp
  801014:	57                   	push   %edi
  801015:	56                   	push   %esi
  801016:	53                   	push   %ebx
  801017:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80101a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80101d:	eb 03                	jmp    801022 <strtol+0x15>
		s++;
  80101f:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  801022:	0f b6 01             	movzbl (%ecx),%eax
  801025:	3c 20                	cmp    $0x20,%al
  801027:	74 f6                	je     80101f <strtol+0x12>
  801029:	3c 09                	cmp    $0x9,%al
  80102b:	74 f2                	je     80101f <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  80102d:	3c 2b                	cmp    $0x2b,%al
  80102f:	74 2a                	je     80105b <strtol+0x4e>
	int neg = 0;
  801031:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  801036:	3c 2d                	cmp    $0x2d,%al
  801038:	74 2b                	je     801065 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80103a:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801040:	75 0f                	jne    801051 <strtol+0x44>
  801042:	80 39 30             	cmpb   $0x30,(%ecx)
  801045:	74 28                	je     80106f <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801047:	85 db                	test   %ebx,%ebx
  801049:	b8 0a 00 00 00       	mov    $0xa,%eax
  80104e:	0f 44 d8             	cmove  %eax,%ebx
  801051:	b8 00 00 00 00       	mov    $0x0,%eax
  801056:	89 5d 10             	mov    %ebx,0x10(%ebp)
  801059:	eb 46                	jmp    8010a1 <strtol+0x94>
		s++;
  80105b:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  80105e:	bf 00 00 00 00       	mov    $0x0,%edi
  801063:	eb d5                	jmp    80103a <strtol+0x2d>
		s++, neg = 1;
  801065:	83 c1 01             	add    $0x1,%ecx
  801068:	bf 01 00 00 00       	mov    $0x1,%edi
  80106d:	eb cb                	jmp    80103a <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80106f:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801073:	74 0e                	je     801083 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  801075:	85 db                	test   %ebx,%ebx
  801077:	75 d8                	jne    801051 <strtol+0x44>
		s++, base = 8;
  801079:	83 c1 01             	add    $0x1,%ecx
  80107c:	bb 08 00 00 00       	mov    $0x8,%ebx
  801081:	eb ce                	jmp    801051 <strtol+0x44>
		s += 2, base = 16;
  801083:	83 c1 02             	add    $0x2,%ecx
  801086:	bb 10 00 00 00       	mov    $0x10,%ebx
  80108b:	eb c4                	jmp    801051 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  80108d:	0f be d2             	movsbl %dl,%edx
  801090:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  801093:	3b 55 10             	cmp    0x10(%ebp),%edx
  801096:	7d 3a                	jge    8010d2 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  801098:	83 c1 01             	add    $0x1,%ecx
  80109b:	0f af 45 10          	imul   0x10(%ebp),%eax
  80109f:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  8010a1:	0f b6 11             	movzbl (%ecx),%edx
  8010a4:	8d 72 d0             	lea    -0x30(%edx),%esi
  8010a7:	89 f3                	mov    %esi,%ebx
  8010a9:	80 fb 09             	cmp    $0x9,%bl
  8010ac:	76 df                	jbe    80108d <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  8010ae:	8d 72 9f             	lea    -0x61(%edx),%esi
  8010b1:	89 f3                	mov    %esi,%ebx
  8010b3:	80 fb 19             	cmp    $0x19,%bl
  8010b6:	77 08                	ja     8010c0 <strtol+0xb3>
			dig = *s - 'a' + 10;
  8010b8:	0f be d2             	movsbl %dl,%edx
  8010bb:	83 ea 57             	sub    $0x57,%edx
  8010be:	eb d3                	jmp    801093 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  8010c0:	8d 72 bf             	lea    -0x41(%edx),%esi
  8010c3:	89 f3                	mov    %esi,%ebx
  8010c5:	80 fb 19             	cmp    $0x19,%bl
  8010c8:	77 08                	ja     8010d2 <strtol+0xc5>
			dig = *s - 'A' + 10;
  8010ca:	0f be d2             	movsbl %dl,%edx
  8010cd:	83 ea 37             	sub    $0x37,%edx
  8010d0:	eb c1                	jmp    801093 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  8010d2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8010d6:	74 05                	je     8010dd <strtol+0xd0>
		*endptr = (char *) s;
  8010d8:	8b 75 0c             	mov    0xc(%ebp),%esi
  8010db:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  8010dd:	89 c2                	mov    %eax,%edx
  8010df:	f7 da                	neg    %edx
  8010e1:	85 ff                	test   %edi,%edi
  8010e3:	0f 45 c2             	cmovne %edx,%eax
}
  8010e6:	5b                   	pop    %ebx
  8010e7:	5e                   	pop    %esi
  8010e8:	5f                   	pop    %edi
  8010e9:	5d                   	pop    %ebp
  8010ea:	c3                   	ret    

008010eb <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8010eb:	f3 0f 1e fb          	endbr32 
  8010ef:	55                   	push   %ebp
  8010f0:	89 e5                	mov    %esp,%ebp
  8010f2:	57                   	push   %edi
  8010f3:	56                   	push   %esi
  8010f4:	53                   	push   %ebx
	asm volatile("int %1\n"
  8010f5:	b8 00 00 00 00       	mov    $0x0,%eax
  8010fa:	8b 55 08             	mov    0x8(%ebp),%edx
  8010fd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801100:	89 c3                	mov    %eax,%ebx
  801102:	89 c7                	mov    %eax,%edi
  801104:	89 c6                	mov    %eax,%esi
  801106:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  801108:	5b                   	pop    %ebx
  801109:	5e                   	pop    %esi
  80110a:	5f                   	pop    %edi
  80110b:	5d                   	pop    %ebp
  80110c:	c3                   	ret    

0080110d <sys_cgetc>:

int
sys_cgetc(void)
{
  80110d:	f3 0f 1e fb          	endbr32 
  801111:	55                   	push   %ebp
  801112:	89 e5                	mov    %esp,%ebp
  801114:	57                   	push   %edi
  801115:	56                   	push   %esi
  801116:	53                   	push   %ebx
	asm volatile("int %1\n"
  801117:	ba 00 00 00 00       	mov    $0x0,%edx
  80111c:	b8 01 00 00 00       	mov    $0x1,%eax
  801121:	89 d1                	mov    %edx,%ecx
  801123:	89 d3                	mov    %edx,%ebx
  801125:	89 d7                	mov    %edx,%edi
  801127:	89 d6                	mov    %edx,%esi
  801129:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  80112b:	5b                   	pop    %ebx
  80112c:	5e                   	pop    %esi
  80112d:	5f                   	pop    %edi
  80112e:	5d                   	pop    %ebp
  80112f:	c3                   	ret    

00801130 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  801130:	f3 0f 1e fb          	endbr32 
  801134:	55                   	push   %ebp
  801135:	89 e5                	mov    %esp,%ebp
  801137:	57                   	push   %edi
  801138:	56                   	push   %esi
  801139:	53                   	push   %ebx
  80113a:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80113d:	b9 00 00 00 00       	mov    $0x0,%ecx
  801142:	8b 55 08             	mov    0x8(%ebp),%edx
  801145:	b8 03 00 00 00       	mov    $0x3,%eax
  80114a:	89 cb                	mov    %ecx,%ebx
  80114c:	89 cf                	mov    %ecx,%edi
  80114e:	89 ce                	mov    %ecx,%esi
  801150:	cd 30                	int    $0x30
	if(check && ret > 0)
  801152:	85 c0                	test   %eax,%eax
  801154:	7f 08                	jg     80115e <sys_env_destroy+0x2e>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  801156:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801159:	5b                   	pop    %ebx
  80115a:	5e                   	pop    %esi
  80115b:	5f                   	pop    %edi
  80115c:	5d                   	pop    %ebp
  80115d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80115e:	83 ec 0c             	sub    $0xc,%esp
  801161:	50                   	push   %eax
  801162:	6a 03                	push   $0x3
  801164:	68 04 1a 80 00       	push   $0x801a04
  801169:	6a 23                	push   $0x23
  80116b:	68 21 1a 80 00       	push   $0x801a21
  801170:	e8 d4 f4 ff ff       	call   800649 <_panic>

00801175 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  801175:	f3 0f 1e fb          	endbr32 
  801179:	55                   	push   %ebp
  80117a:	89 e5                	mov    %esp,%ebp
  80117c:	57                   	push   %edi
  80117d:	56                   	push   %esi
  80117e:	53                   	push   %ebx
	asm volatile("int %1\n"
  80117f:	ba 00 00 00 00       	mov    $0x0,%edx
  801184:	b8 02 00 00 00       	mov    $0x2,%eax
  801189:	89 d1                	mov    %edx,%ecx
  80118b:	89 d3                	mov    %edx,%ebx
  80118d:	89 d7                	mov    %edx,%edi
  80118f:	89 d6                	mov    %edx,%esi
  801191:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  801193:	5b                   	pop    %ebx
  801194:	5e                   	pop    %esi
  801195:	5f                   	pop    %edi
  801196:	5d                   	pop    %ebp
  801197:	c3                   	ret    

00801198 <sys_yield>:

void
sys_yield(void)
{
  801198:	f3 0f 1e fb          	endbr32 
  80119c:	55                   	push   %ebp
  80119d:	89 e5                	mov    %esp,%ebp
  80119f:	57                   	push   %edi
  8011a0:	56                   	push   %esi
  8011a1:	53                   	push   %ebx
	asm volatile("int %1\n"
  8011a2:	ba 00 00 00 00       	mov    $0x0,%edx
  8011a7:	b8 0a 00 00 00       	mov    $0xa,%eax
  8011ac:	89 d1                	mov    %edx,%ecx
  8011ae:	89 d3                	mov    %edx,%ebx
  8011b0:	89 d7                	mov    %edx,%edi
  8011b2:	89 d6                	mov    %edx,%esi
  8011b4:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8011b6:	5b                   	pop    %ebx
  8011b7:	5e                   	pop    %esi
  8011b8:	5f                   	pop    %edi
  8011b9:	5d                   	pop    %ebp
  8011ba:	c3                   	ret    

008011bb <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8011bb:	f3 0f 1e fb          	endbr32 
  8011bf:	55                   	push   %ebp
  8011c0:	89 e5                	mov    %esp,%ebp
  8011c2:	57                   	push   %edi
  8011c3:	56                   	push   %esi
  8011c4:	53                   	push   %ebx
  8011c5:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8011c8:	be 00 00 00 00       	mov    $0x0,%esi
  8011cd:	8b 55 08             	mov    0x8(%ebp),%edx
  8011d0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011d3:	b8 04 00 00 00       	mov    $0x4,%eax
  8011d8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8011db:	89 f7                	mov    %esi,%edi
  8011dd:	cd 30                	int    $0x30
	if(check && ret > 0)
  8011df:	85 c0                	test   %eax,%eax
  8011e1:	7f 08                	jg     8011eb <sys_page_alloc+0x30>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8011e3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011e6:	5b                   	pop    %ebx
  8011e7:	5e                   	pop    %esi
  8011e8:	5f                   	pop    %edi
  8011e9:	5d                   	pop    %ebp
  8011ea:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8011eb:	83 ec 0c             	sub    $0xc,%esp
  8011ee:	50                   	push   %eax
  8011ef:	6a 04                	push   $0x4
  8011f1:	68 04 1a 80 00       	push   $0x801a04
  8011f6:	6a 23                	push   $0x23
  8011f8:	68 21 1a 80 00       	push   $0x801a21
  8011fd:	e8 47 f4 ff ff       	call   800649 <_panic>

00801202 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  801202:	f3 0f 1e fb          	endbr32 
  801206:	55                   	push   %ebp
  801207:	89 e5                	mov    %esp,%ebp
  801209:	57                   	push   %edi
  80120a:	56                   	push   %esi
  80120b:	53                   	push   %ebx
  80120c:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80120f:	8b 55 08             	mov    0x8(%ebp),%edx
  801212:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801215:	b8 05 00 00 00       	mov    $0x5,%eax
  80121a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80121d:	8b 7d 14             	mov    0x14(%ebp),%edi
  801220:	8b 75 18             	mov    0x18(%ebp),%esi
  801223:	cd 30                	int    $0x30
	if(check && ret > 0)
  801225:	85 c0                	test   %eax,%eax
  801227:	7f 08                	jg     801231 <sys_page_map+0x2f>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  801229:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80122c:	5b                   	pop    %ebx
  80122d:	5e                   	pop    %esi
  80122e:	5f                   	pop    %edi
  80122f:	5d                   	pop    %ebp
  801230:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  801231:	83 ec 0c             	sub    $0xc,%esp
  801234:	50                   	push   %eax
  801235:	6a 05                	push   $0x5
  801237:	68 04 1a 80 00       	push   $0x801a04
  80123c:	6a 23                	push   $0x23
  80123e:	68 21 1a 80 00       	push   $0x801a21
  801243:	e8 01 f4 ff ff       	call   800649 <_panic>

00801248 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  801248:	f3 0f 1e fb          	endbr32 
  80124c:	55                   	push   %ebp
  80124d:	89 e5                	mov    %esp,%ebp
  80124f:	57                   	push   %edi
  801250:	56                   	push   %esi
  801251:	53                   	push   %ebx
  801252:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  801255:	bb 00 00 00 00       	mov    $0x0,%ebx
  80125a:	8b 55 08             	mov    0x8(%ebp),%edx
  80125d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801260:	b8 06 00 00 00       	mov    $0x6,%eax
  801265:	89 df                	mov    %ebx,%edi
  801267:	89 de                	mov    %ebx,%esi
  801269:	cd 30                	int    $0x30
	if(check && ret > 0)
  80126b:	85 c0                	test   %eax,%eax
  80126d:	7f 08                	jg     801277 <sys_page_unmap+0x2f>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80126f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801272:	5b                   	pop    %ebx
  801273:	5e                   	pop    %esi
  801274:	5f                   	pop    %edi
  801275:	5d                   	pop    %ebp
  801276:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  801277:	83 ec 0c             	sub    $0xc,%esp
  80127a:	50                   	push   %eax
  80127b:	6a 06                	push   $0x6
  80127d:	68 04 1a 80 00       	push   $0x801a04
  801282:	6a 23                	push   $0x23
  801284:	68 21 1a 80 00       	push   $0x801a21
  801289:	e8 bb f3 ff ff       	call   800649 <_panic>

0080128e <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80128e:	f3 0f 1e fb          	endbr32 
  801292:	55                   	push   %ebp
  801293:	89 e5                	mov    %esp,%ebp
  801295:	57                   	push   %edi
  801296:	56                   	push   %esi
  801297:	53                   	push   %ebx
  801298:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80129b:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012a0:	8b 55 08             	mov    0x8(%ebp),%edx
  8012a3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012a6:	b8 08 00 00 00       	mov    $0x8,%eax
  8012ab:	89 df                	mov    %ebx,%edi
  8012ad:	89 de                	mov    %ebx,%esi
  8012af:	cd 30                	int    $0x30
	if(check && ret > 0)
  8012b1:	85 c0                	test   %eax,%eax
  8012b3:	7f 08                	jg     8012bd <sys_env_set_status+0x2f>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8012b5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012b8:	5b                   	pop    %ebx
  8012b9:	5e                   	pop    %esi
  8012ba:	5f                   	pop    %edi
  8012bb:	5d                   	pop    %ebp
  8012bc:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8012bd:	83 ec 0c             	sub    $0xc,%esp
  8012c0:	50                   	push   %eax
  8012c1:	6a 08                	push   $0x8
  8012c3:	68 04 1a 80 00       	push   $0x801a04
  8012c8:	6a 23                	push   $0x23
  8012ca:	68 21 1a 80 00       	push   $0x801a21
  8012cf:	e8 75 f3 ff ff       	call   800649 <_panic>

008012d4 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8012d4:	f3 0f 1e fb          	endbr32 
  8012d8:	55                   	push   %ebp
  8012d9:	89 e5                	mov    %esp,%ebp
  8012db:	57                   	push   %edi
  8012dc:	56                   	push   %esi
  8012dd:	53                   	push   %ebx
  8012de:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8012e1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012e6:	8b 55 08             	mov    0x8(%ebp),%edx
  8012e9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012ec:	b8 09 00 00 00       	mov    $0x9,%eax
  8012f1:	89 df                	mov    %ebx,%edi
  8012f3:	89 de                	mov    %ebx,%esi
  8012f5:	cd 30                	int    $0x30
	if(check && ret > 0)
  8012f7:	85 c0                	test   %eax,%eax
  8012f9:	7f 08                	jg     801303 <sys_env_set_pgfault_upcall+0x2f>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8012fb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012fe:	5b                   	pop    %ebx
  8012ff:	5e                   	pop    %esi
  801300:	5f                   	pop    %edi
  801301:	5d                   	pop    %ebp
  801302:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  801303:	83 ec 0c             	sub    $0xc,%esp
  801306:	50                   	push   %eax
  801307:	6a 09                	push   $0x9
  801309:	68 04 1a 80 00       	push   $0x801a04
  80130e:	6a 23                	push   $0x23
  801310:	68 21 1a 80 00       	push   $0x801a21
  801315:	e8 2f f3 ff ff       	call   800649 <_panic>

0080131a <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80131a:	f3 0f 1e fb          	endbr32 
  80131e:	55                   	push   %ebp
  80131f:	89 e5                	mov    %esp,%ebp
  801321:	57                   	push   %edi
  801322:	56                   	push   %esi
  801323:	53                   	push   %ebx
	asm volatile("int %1\n"
  801324:	8b 55 08             	mov    0x8(%ebp),%edx
  801327:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80132a:	b8 0b 00 00 00       	mov    $0xb,%eax
  80132f:	be 00 00 00 00       	mov    $0x0,%esi
  801334:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801337:	8b 7d 14             	mov    0x14(%ebp),%edi
  80133a:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80133c:	5b                   	pop    %ebx
  80133d:	5e                   	pop    %esi
  80133e:	5f                   	pop    %edi
  80133f:	5d                   	pop    %ebp
  801340:	c3                   	ret    

00801341 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801341:	f3 0f 1e fb          	endbr32 
  801345:	55                   	push   %ebp
  801346:	89 e5                	mov    %esp,%ebp
  801348:	57                   	push   %edi
  801349:	56                   	push   %esi
  80134a:	53                   	push   %ebx
  80134b:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80134e:	b9 00 00 00 00       	mov    $0x0,%ecx
  801353:	8b 55 08             	mov    0x8(%ebp),%edx
  801356:	b8 0c 00 00 00       	mov    $0xc,%eax
  80135b:	89 cb                	mov    %ecx,%ebx
  80135d:	89 cf                	mov    %ecx,%edi
  80135f:	89 ce                	mov    %ecx,%esi
  801361:	cd 30                	int    $0x30
	if(check && ret > 0)
  801363:	85 c0                	test   %eax,%eax
  801365:	7f 08                	jg     80136f <sys_ipc_recv+0x2e>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801367:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80136a:	5b                   	pop    %ebx
  80136b:	5e                   	pop    %esi
  80136c:	5f                   	pop    %edi
  80136d:	5d                   	pop    %ebp
  80136e:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80136f:	83 ec 0c             	sub    $0xc,%esp
  801372:	50                   	push   %eax
  801373:	6a 0c                	push   $0xc
  801375:	68 04 1a 80 00       	push   $0x801a04
  80137a:	6a 23                	push   $0x23
  80137c:	68 21 1a 80 00       	push   $0x801a21
  801381:	e8 c3 f2 ff ff       	call   800649 <_panic>

00801386 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801386:	f3 0f 1e fb          	endbr32 
  80138a:	55                   	push   %ebp
  80138b:	89 e5                	mov    %esp,%ebp
  80138d:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801390:	83 3d d0 20 80 00 00 	cmpl   $0x0,0x8020d0
  801397:	74 0a                	je     8013a3 <set_pgfault_handler+0x1d>
        sys_env_set_pgfault_upcall(0, _pgfault_upcall);
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801399:	8b 45 08             	mov    0x8(%ebp),%eax
  80139c:	a3 d0 20 80 00       	mov    %eax,0x8020d0
}
  8013a1:	c9                   	leave  
  8013a2:	c3                   	ret    
		if (sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P) < 0)
  8013a3:	83 ec 04             	sub    $0x4,%esp
  8013a6:	6a 07                	push   $0x7
  8013a8:	68 00 f0 bf ee       	push   $0xeebff000
  8013ad:	6a 00                	push   $0x0
  8013af:	e8 07 fe ff ff       	call   8011bb <sys_page_alloc>
  8013b4:	83 c4 10             	add    $0x10,%esp
  8013b7:	85 c0                	test   %eax,%eax
  8013b9:	78 14                	js     8013cf <set_pgfault_handler+0x49>
        sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  8013bb:	83 ec 08             	sub    $0x8,%esp
  8013be:	68 e3 13 80 00       	push   $0x8013e3
  8013c3:	6a 00                	push   $0x0
  8013c5:	e8 0a ff ff ff       	call   8012d4 <sys_env_set_pgfault_upcall>
  8013ca:	83 c4 10             	add    $0x10,%esp
  8013cd:	eb ca                	jmp    801399 <set_pgfault_handler+0x13>
            panic("set_pgfault_handler failed.");
  8013cf:	83 ec 04             	sub    $0x4,%esp
  8013d2:	68 2f 1a 80 00       	push   $0x801a2f
  8013d7:	6a 21                	push   $0x21
  8013d9:	68 4b 1a 80 00       	push   $0x801a4b
  8013de:	e8 66 f2 ff ff       	call   800649 <_panic>

008013e3 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8013e3:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8013e4:	a1 d0 20 80 00       	mov    0x8020d0,%eax
	call *%eax
  8013e9:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8013eb:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	addl $8, %esp
  8013ee:	83 c4 08             	add    $0x8,%esp
	movl 32(%esp), %eax
  8013f1:	8b 44 24 20          	mov    0x20(%esp),%eax
	movl 40(%esp), %edx
  8013f5:	8b 54 24 28          	mov    0x28(%esp),%edx
	subl $4, %edx
  8013f9:	83 ea 04             	sub    $0x4,%edx
	movl %eax, (%edx)
  8013fc:	89 02                	mov    %eax,(%edx)
	movl %edx, 40(%esp)
  8013fe:	89 54 24 28          	mov    %edx,0x28(%esp)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal
  801402:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp
  801403:	83 c4 04             	add    $0x4,%esp
	popfl
  801406:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  801407:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801408:	c3                   	ret    
  801409:	66 90                	xchg   %ax,%ax
  80140b:	66 90                	xchg   %ax,%ax
  80140d:	66 90                	xchg   %ax,%ax
  80140f:	90                   	nop

00801410 <__udivdi3>:
  801410:	f3 0f 1e fb          	endbr32 
  801414:	55                   	push   %ebp
  801415:	57                   	push   %edi
  801416:	56                   	push   %esi
  801417:	53                   	push   %ebx
  801418:	83 ec 1c             	sub    $0x1c,%esp
  80141b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80141f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  801423:	8b 74 24 34          	mov    0x34(%esp),%esi
  801427:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  80142b:	85 d2                	test   %edx,%edx
  80142d:	75 19                	jne    801448 <__udivdi3+0x38>
  80142f:	39 f3                	cmp    %esi,%ebx
  801431:	76 4d                	jbe    801480 <__udivdi3+0x70>
  801433:	31 ff                	xor    %edi,%edi
  801435:	89 e8                	mov    %ebp,%eax
  801437:	89 f2                	mov    %esi,%edx
  801439:	f7 f3                	div    %ebx
  80143b:	89 fa                	mov    %edi,%edx
  80143d:	83 c4 1c             	add    $0x1c,%esp
  801440:	5b                   	pop    %ebx
  801441:	5e                   	pop    %esi
  801442:	5f                   	pop    %edi
  801443:	5d                   	pop    %ebp
  801444:	c3                   	ret    
  801445:	8d 76 00             	lea    0x0(%esi),%esi
  801448:	39 f2                	cmp    %esi,%edx
  80144a:	76 14                	jbe    801460 <__udivdi3+0x50>
  80144c:	31 ff                	xor    %edi,%edi
  80144e:	31 c0                	xor    %eax,%eax
  801450:	89 fa                	mov    %edi,%edx
  801452:	83 c4 1c             	add    $0x1c,%esp
  801455:	5b                   	pop    %ebx
  801456:	5e                   	pop    %esi
  801457:	5f                   	pop    %edi
  801458:	5d                   	pop    %ebp
  801459:	c3                   	ret    
  80145a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801460:	0f bd fa             	bsr    %edx,%edi
  801463:	83 f7 1f             	xor    $0x1f,%edi
  801466:	75 48                	jne    8014b0 <__udivdi3+0xa0>
  801468:	39 f2                	cmp    %esi,%edx
  80146a:	72 06                	jb     801472 <__udivdi3+0x62>
  80146c:	31 c0                	xor    %eax,%eax
  80146e:	39 eb                	cmp    %ebp,%ebx
  801470:	77 de                	ja     801450 <__udivdi3+0x40>
  801472:	b8 01 00 00 00       	mov    $0x1,%eax
  801477:	eb d7                	jmp    801450 <__udivdi3+0x40>
  801479:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801480:	89 d9                	mov    %ebx,%ecx
  801482:	85 db                	test   %ebx,%ebx
  801484:	75 0b                	jne    801491 <__udivdi3+0x81>
  801486:	b8 01 00 00 00       	mov    $0x1,%eax
  80148b:	31 d2                	xor    %edx,%edx
  80148d:	f7 f3                	div    %ebx
  80148f:	89 c1                	mov    %eax,%ecx
  801491:	31 d2                	xor    %edx,%edx
  801493:	89 f0                	mov    %esi,%eax
  801495:	f7 f1                	div    %ecx
  801497:	89 c6                	mov    %eax,%esi
  801499:	89 e8                	mov    %ebp,%eax
  80149b:	89 f7                	mov    %esi,%edi
  80149d:	f7 f1                	div    %ecx
  80149f:	89 fa                	mov    %edi,%edx
  8014a1:	83 c4 1c             	add    $0x1c,%esp
  8014a4:	5b                   	pop    %ebx
  8014a5:	5e                   	pop    %esi
  8014a6:	5f                   	pop    %edi
  8014a7:	5d                   	pop    %ebp
  8014a8:	c3                   	ret    
  8014a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8014b0:	89 f9                	mov    %edi,%ecx
  8014b2:	b8 20 00 00 00       	mov    $0x20,%eax
  8014b7:	29 f8                	sub    %edi,%eax
  8014b9:	d3 e2                	shl    %cl,%edx
  8014bb:	89 54 24 08          	mov    %edx,0x8(%esp)
  8014bf:	89 c1                	mov    %eax,%ecx
  8014c1:	89 da                	mov    %ebx,%edx
  8014c3:	d3 ea                	shr    %cl,%edx
  8014c5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8014c9:	09 d1                	or     %edx,%ecx
  8014cb:	89 f2                	mov    %esi,%edx
  8014cd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8014d1:	89 f9                	mov    %edi,%ecx
  8014d3:	d3 e3                	shl    %cl,%ebx
  8014d5:	89 c1                	mov    %eax,%ecx
  8014d7:	d3 ea                	shr    %cl,%edx
  8014d9:	89 f9                	mov    %edi,%ecx
  8014db:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8014df:	89 eb                	mov    %ebp,%ebx
  8014e1:	d3 e6                	shl    %cl,%esi
  8014e3:	89 c1                	mov    %eax,%ecx
  8014e5:	d3 eb                	shr    %cl,%ebx
  8014e7:	09 de                	or     %ebx,%esi
  8014e9:	89 f0                	mov    %esi,%eax
  8014eb:	f7 74 24 08          	divl   0x8(%esp)
  8014ef:	89 d6                	mov    %edx,%esi
  8014f1:	89 c3                	mov    %eax,%ebx
  8014f3:	f7 64 24 0c          	mull   0xc(%esp)
  8014f7:	39 d6                	cmp    %edx,%esi
  8014f9:	72 15                	jb     801510 <__udivdi3+0x100>
  8014fb:	89 f9                	mov    %edi,%ecx
  8014fd:	d3 e5                	shl    %cl,%ebp
  8014ff:	39 c5                	cmp    %eax,%ebp
  801501:	73 04                	jae    801507 <__udivdi3+0xf7>
  801503:	39 d6                	cmp    %edx,%esi
  801505:	74 09                	je     801510 <__udivdi3+0x100>
  801507:	89 d8                	mov    %ebx,%eax
  801509:	31 ff                	xor    %edi,%edi
  80150b:	e9 40 ff ff ff       	jmp    801450 <__udivdi3+0x40>
  801510:	8d 43 ff             	lea    -0x1(%ebx),%eax
  801513:	31 ff                	xor    %edi,%edi
  801515:	e9 36 ff ff ff       	jmp    801450 <__udivdi3+0x40>
  80151a:	66 90                	xchg   %ax,%ax
  80151c:	66 90                	xchg   %ax,%ax
  80151e:	66 90                	xchg   %ax,%ax

00801520 <__umoddi3>:
  801520:	f3 0f 1e fb          	endbr32 
  801524:	55                   	push   %ebp
  801525:	57                   	push   %edi
  801526:	56                   	push   %esi
  801527:	53                   	push   %ebx
  801528:	83 ec 1c             	sub    $0x1c,%esp
  80152b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80152f:	8b 74 24 30          	mov    0x30(%esp),%esi
  801533:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  801537:	8b 7c 24 38          	mov    0x38(%esp),%edi
  80153b:	85 c0                	test   %eax,%eax
  80153d:	75 19                	jne    801558 <__umoddi3+0x38>
  80153f:	39 df                	cmp    %ebx,%edi
  801541:	76 5d                	jbe    8015a0 <__umoddi3+0x80>
  801543:	89 f0                	mov    %esi,%eax
  801545:	89 da                	mov    %ebx,%edx
  801547:	f7 f7                	div    %edi
  801549:	89 d0                	mov    %edx,%eax
  80154b:	31 d2                	xor    %edx,%edx
  80154d:	83 c4 1c             	add    $0x1c,%esp
  801550:	5b                   	pop    %ebx
  801551:	5e                   	pop    %esi
  801552:	5f                   	pop    %edi
  801553:	5d                   	pop    %ebp
  801554:	c3                   	ret    
  801555:	8d 76 00             	lea    0x0(%esi),%esi
  801558:	89 f2                	mov    %esi,%edx
  80155a:	39 d8                	cmp    %ebx,%eax
  80155c:	76 12                	jbe    801570 <__umoddi3+0x50>
  80155e:	89 f0                	mov    %esi,%eax
  801560:	89 da                	mov    %ebx,%edx
  801562:	83 c4 1c             	add    $0x1c,%esp
  801565:	5b                   	pop    %ebx
  801566:	5e                   	pop    %esi
  801567:	5f                   	pop    %edi
  801568:	5d                   	pop    %ebp
  801569:	c3                   	ret    
  80156a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801570:	0f bd e8             	bsr    %eax,%ebp
  801573:	83 f5 1f             	xor    $0x1f,%ebp
  801576:	75 50                	jne    8015c8 <__umoddi3+0xa8>
  801578:	39 d8                	cmp    %ebx,%eax
  80157a:	0f 82 e0 00 00 00    	jb     801660 <__umoddi3+0x140>
  801580:	89 d9                	mov    %ebx,%ecx
  801582:	39 f7                	cmp    %esi,%edi
  801584:	0f 86 d6 00 00 00    	jbe    801660 <__umoddi3+0x140>
  80158a:	89 d0                	mov    %edx,%eax
  80158c:	89 ca                	mov    %ecx,%edx
  80158e:	83 c4 1c             	add    $0x1c,%esp
  801591:	5b                   	pop    %ebx
  801592:	5e                   	pop    %esi
  801593:	5f                   	pop    %edi
  801594:	5d                   	pop    %ebp
  801595:	c3                   	ret    
  801596:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80159d:	8d 76 00             	lea    0x0(%esi),%esi
  8015a0:	89 fd                	mov    %edi,%ebp
  8015a2:	85 ff                	test   %edi,%edi
  8015a4:	75 0b                	jne    8015b1 <__umoddi3+0x91>
  8015a6:	b8 01 00 00 00       	mov    $0x1,%eax
  8015ab:	31 d2                	xor    %edx,%edx
  8015ad:	f7 f7                	div    %edi
  8015af:	89 c5                	mov    %eax,%ebp
  8015b1:	89 d8                	mov    %ebx,%eax
  8015b3:	31 d2                	xor    %edx,%edx
  8015b5:	f7 f5                	div    %ebp
  8015b7:	89 f0                	mov    %esi,%eax
  8015b9:	f7 f5                	div    %ebp
  8015bb:	89 d0                	mov    %edx,%eax
  8015bd:	31 d2                	xor    %edx,%edx
  8015bf:	eb 8c                	jmp    80154d <__umoddi3+0x2d>
  8015c1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8015c8:	89 e9                	mov    %ebp,%ecx
  8015ca:	ba 20 00 00 00       	mov    $0x20,%edx
  8015cf:	29 ea                	sub    %ebp,%edx
  8015d1:	d3 e0                	shl    %cl,%eax
  8015d3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8015d7:	89 d1                	mov    %edx,%ecx
  8015d9:	89 f8                	mov    %edi,%eax
  8015db:	d3 e8                	shr    %cl,%eax
  8015dd:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8015e1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8015e5:	8b 54 24 04          	mov    0x4(%esp),%edx
  8015e9:	09 c1                	or     %eax,%ecx
  8015eb:	89 d8                	mov    %ebx,%eax
  8015ed:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8015f1:	89 e9                	mov    %ebp,%ecx
  8015f3:	d3 e7                	shl    %cl,%edi
  8015f5:	89 d1                	mov    %edx,%ecx
  8015f7:	d3 e8                	shr    %cl,%eax
  8015f9:	89 e9                	mov    %ebp,%ecx
  8015fb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8015ff:	d3 e3                	shl    %cl,%ebx
  801601:	89 c7                	mov    %eax,%edi
  801603:	89 d1                	mov    %edx,%ecx
  801605:	89 f0                	mov    %esi,%eax
  801607:	d3 e8                	shr    %cl,%eax
  801609:	89 e9                	mov    %ebp,%ecx
  80160b:	89 fa                	mov    %edi,%edx
  80160d:	d3 e6                	shl    %cl,%esi
  80160f:	09 d8                	or     %ebx,%eax
  801611:	f7 74 24 08          	divl   0x8(%esp)
  801615:	89 d1                	mov    %edx,%ecx
  801617:	89 f3                	mov    %esi,%ebx
  801619:	f7 64 24 0c          	mull   0xc(%esp)
  80161d:	89 c6                	mov    %eax,%esi
  80161f:	89 d7                	mov    %edx,%edi
  801621:	39 d1                	cmp    %edx,%ecx
  801623:	72 06                	jb     80162b <__umoddi3+0x10b>
  801625:	75 10                	jne    801637 <__umoddi3+0x117>
  801627:	39 c3                	cmp    %eax,%ebx
  801629:	73 0c                	jae    801637 <__umoddi3+0x117>
  80162b:	2b 44 24 0c          	sub    0xc(%esp),%eax
  80162f:	1b 54 24 08          	sbb    0x8(%esp),%edx
  801633:	89 d7                	mov    %edx,%edi
  801635:	89 c6                	mov    %eax,%esi
  801637:	89 ca                	mov    %ecx,%edx
  801639:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80163e:	29 f3                	sub    %esi,%ebx
  801640:	19 fa                	sbb    %edi,%edx
  801642:	89 d0                	mov    %edx,%eax
  801644:	d3 e0                	shl    %cl,%eax
  801646:	89 e9                	mov    %ebp,%ecx
  801648:	d3 eb                	shr    %cl,%ebx
  80164a:	d3 ea                	shr    %cl,%edx
  80164c:	09 d8                	or     %ebx,%eax
  80164e:	83 c4 1c             	add    $0x1c,%esp
  801651:	5b                   	pop    %ebx
  801652:	5e                   	pop    %esi
  801653:	5f                   	pop    %edi
  801654:	5d                   	pop    %ebp
  801655:	c3                   	ret    
  801656:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80165d:	8d 76 00             	lea    0x0(%esi),%esi
  801660:	29 fe                	sub    %edi,%esi
  801662:	19 c3                	sbb    %eax,%ebx
  801664:	89 f2                	mov    %esi,%edx
  801666:	89 d9                	mov    %ebx,%ecx
  801668:	e9 1d ff ff ff       	jmp    80158a <__umoddi3+0x6a>
