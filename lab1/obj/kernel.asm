
bin/kernel：     文件格式 elf64-littleriscv


Disassembly of section .text:

0000000080200000 <kern_entry>:
#include <memlayout.h>

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    la sp, bootstacktop
    80200000:	00004117          	auipc	sp,0x4
    80200004:	00010113          	mv	sp,sp

    tail kern_init
    80200008:	0040006f          	j	8020000c <kern_init>

000000008020000c <kern_init>:
int kern_init(void) __attribute__((noreturn));
void grade_backtrace(void);

int kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
    8020000c:	00004517          	auipc	a0,0x4
    80200010:	ffc50513          	addi	a0,a0,-4 # 80204008 <edata>
    80200014:	00004617          	auipc	a2,0x4
    80200018:	00460613          	addi	a2,a2,4 # 80204018 <end>
int kern_init(void) {
    8020001c:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
    8020001e:	8e09                	sub	a2,a2,a0
    80200020:	4581                	li	a1,0
int kern_init(void) {
    80200022:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
    80200024:	540000ef          	jal	ra,80200564 <memset>

    cons_init();  // init the console
    80200028:	13c000ef          	jal	ra,80200164 <cons_init>

    const char *message = "(THU.CST) os is loading ...\n";
    cprintf("%s\n\n", message);
    8020002c:	00001597          	auipc	a1,0x1
    80200030:	97c58593          	addi	a1,a1,-1668 # 802009a8 <etext+0x2>
    80200034:	00001517          	auipc	a0,0x1
    80200038:	99450513          	addi	a0,a0,-1644 # 802009c8 <etext+0x22>
    8020003c:	030000ef          	jal	ra,8020006c <cprintf>

    print_kerninfo();
    80200040:	060000ef          	jal	ra,802000a0 <print_kerninfo>

    // grade_backtrace();

    idt_init();  // init interrupt descriptor table
    80200044:	130000ef          	jal	ra,80200174 <idt_init>

    // rdtime in mbare mode crashes
    clock_init();  // init clock interrupt
    80200048:	0e8000ef          	jal	ra,80200130 <clock_init>

    intr_enable();  // enable irq interrupt
    8020004c:	122000ef          	jal	ra,8020016e <intr_enable>
    
    while (1)
        ;
    80200050:	a001                	j	80200050 <kern_init+0x44>

0000000080200052 <cputch>:

/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void cputch(int c, int *cnt) {
    80200052:	1141                	addi	sp,sp,-16
    80200054:	e022                	sd	s0,0(sp)
    80200056:	e406                	sd	ra,8(sp)
    80200058:	842e                	mv	s0,a1
    cons_putc(c);
    8020005a:	10c000ef          	jal	ra,80200166 <cons_putc>
    (*cnt)++;
    8020005e:	401c                	lw	a5,0(s0)
}
    80200060:	60a2                	ld	ra,8(sp)
    (*cnt)++;
    80200062:	2785                	addiw	a5,a5,1
    80200064:	c01c                	sw	a5,0(s0)
}
    80200066:	6402                	ld	s0,0(sp)
    80200068:	0141                	addi	sp,sp,16
    8020006a:	8082                	ret

000000008020006c <cprintf>:
 * cprintf - formats a string and writes it to stdout
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int cprintf(const char *fmt, ...) {
    8020006c:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
    8020006e:	02810313          	addi	t1,sp,40 # 80204028 <end+0x10>
int cprintf(const char *fmt, ...) {
    80200072:	f42e                	sd	a1,40(sp)
    80200074:	f832                	sd	a2,48(sp)
    80200076:	fc36                	sd	a3,56(sp)
    vprintfmt((void *)cputch, &cnt, fmt, ap);
    80200078:	862a                	mv	a2,a0
    8020007a:	004c                	addi	a1,sp,4
    8020007c:	00000517          	auipc	a0,0x0
    80200080:	fd650513          	addi	a0,a0,-42 # 80200052 <cputch>
    80200084:	869a                	mv	a3,t1
int cprintf(const char *fmt, ...) {
    80200086:	ec06                	sd	ra,24(sp)
    80200088:	e0ba                	sd	a4,64(sp)
    8020008a:	e4be                	sd	a5,72(sp)
    8020008c:	e8c2                	sd	a6,80(sp)
    8020008e:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
    80200090:	e41a                	sd	t1,8(sp)
    int cnt = 0;
    80200092:	c202                	sw	zero,4(sp)
    vprintfmt((void *)cputch, &cnt, fmt, ap);
    80200094:	54e000ef          	jal	ra,802005e2 <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
    80200098:	60e2                	ld	ra,24(sp)
    8020009a:	4512                	lw	a0,4(sp)
    8020009c:	6125                	addi	sp,sp,96
    8020009e:	8082                	ret

00000000802000a0 <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
    802000a0:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
    802000a2:	00001517          	auipc	a0,0x1
    802000a6:	92e50513          	addi	a0,a0,-1746 # 802009d0 <etext+0x2a>
void print_kerninfo(void) {
    802000aa:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
    802000ac:	fc1ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  entry  0x%016x (virtual)\n", kern_init);
    802000b0:	00000597          	auipc	a1,0x0
    802000b4:	f5c58593          	addi	a1,a1,-164 # 8020000c <kern_init>
    802000b8:	00001517          	auipc	a0,0x1
    802000bc:	93850513          	addi	a0,a0,-1736 # 802009f0 <etext+0x4a>
    802000c0:	fadff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  etext  0x%016x (virtual)\n", etext);
    802000c4:	00001597          	auipc	a1,0x1
    802000c8:	8e258593          	addi	a1,a1,-1822 # 802009a6 <etext>
    802000cc:	00001517          	auipc	a0,0x1
    802000d0:	94450513          	addi	a0,a0,-1724 # 80200a10 <etext+0x6a>
    802000d4:	f99ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  edata  0x%016x (virtual)\n", edata);
    802000d8:	00004597          	auipc	a1,0x4
    802000dc:	f3058593          	addi	a1,a1,-208 # 80204008 <edata>
    802000e0:	00001517          	auipc	a0,0x1
    802000e4:	95050513          	addi	a0,a0,-1712 # 80200a30 <etext+0x8a>
    802000e8:	f85ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  end    0x%016x (virtual)\n", end);
    802000ec:	00004597          	auipc	a1,0x4
    802000f0:	f2c58593          	addi	a1,a1,-212 # 80204018 <end>
    802000f4:	00001517          	auipc	a0,0x1
    802000f8:	95c50513          	addi	a0,a0,-1700 # 80200a50 <etext+0xaa>
    802000fc:	f71ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
    80200100:	00004597          	auipc	a1,0x4
    80200104:	31758593          	addi	a1,a1,791 # 80204417 <end+0x3ff>
    80200108:	00000797          	auipc	a5,0x0
    8020010c:	f0478793          	addi	a5,a5,-252 # 8020000c <kern_init>
    80200110:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
    80200114:	43f7d593          	srai	a1,a5,0x3f
}
    80200118:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
    8020011a:	3ff5f593          	andi	a1,a1,1023
    8020011e:	95be                	add	a1,a1,a5
    80200120:	85a9                	srai	a1,a1,0xa
    80200122:	00001517          	auipc	a0,0x1
    80200126:	94e50513          	addi	a0,a0,-1714 # 80200a70 <etext+0xca>
}
    8020012a:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
    8020012c:	f41ff06f          	j	8020006c <cprintf>

0000000080200130 <clock_init>:

/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    80200130:	1141                	addi	sp,sp,-16
    80200132:	e406                	sd	ra,8(sp)
    // enable timer interrupt in sie
    set_csr(sie, MIP_STIP);
    80200134:	02000793          	li	a5,32
    80200138:	1047a7f3          	csrrs	a5,sie,a5
    __asm__ __volatile__("rdtime %0" : "=r"(n));
    8020013c:	c0102573          	rdtime	a0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
    80200140:	67e1                	lui	a5,0x18
    80200142:	6a078793          	addi	a5,a5,1696 # 186a0 <BASE_ADDRESS-0x801e7960>
    80200146:	953e                	add	a0,a0,a5
    80200148:	043000ef          	jal	ra,8020098a <sbi_set_timer>
}
    8020014c:	60a2                	ld	ra,8(sp)
    ticks = 0;
    8020014e:	00004797          	auipc	a5,0x4
    80200152:	ec07b123          	sd	zero,-318(a5) # 80204010 <ticks>
    cprintf("++ setup timer interrupts\n");
    80200156:	00001517          	auipc	a0,0x1
    8020015a:	94a50513          	addi	a0,a0,-1718 # 80200aa0 <etext+0xfa>
}
    8020015e:	0141                	addi	sp,sp,16
    cprintf("++ setup timer interrupts\n");
    80200160:	f0dff06f          	j	8020006c <cprintf>

0000000080200164 <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
    80200164:	8082                	ret

0000000080200166 <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) { sbi_console_putchar((unsigned char)c); }
    80200166:	0ff57513          	andi	a0,a0,255
    8020016a:	0050006f          	j	8020096e <sbi_console_putchar>

000000008020016e <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
    8020016e:	100167f3          	csrrsi	a5,sstatus,2
    80200172:	8082                	ret

0000000080200174 <idt_init>:
 */
void idt_init(void) {
    extern void __alltraps(void);
    /* Set sscratch register to 0, indicating to exception vector that we are
     * presently executing in the kernel */
    write_csr(sscratch, 0);
    80200174:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
    80200178:	00000797          	auipc	a5,0x0
    8020017c:	31078793          	addi	a5,a5,784 # 80200488 <__alltraps>
    80200180:	10579073          	csrw	stvec,a5
}
    80200184:	8082                	ret

0000000080200186 <print_regs>:
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs *gpr) {
    cprintf("  zero     0x%08x\n", gpr->zero);
    80200186:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
    80200188:	1141                	addi	sp,sp,-16
    8020018a:	e022                	sd	s0,0(sp)
    8020018c:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
    8020018e:	00001517          	auipc	a0,0x1
    80200192:	a0250513          	addi	a0,a0,-1534 # 80200b90 <etext+0x1ea>
void print_regs(struct pushregs *gpr) {
    80200196:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
    80200198:	ed5ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
    8020019c:	640c                	ld	a1,8(s0)
    8020019e:	00001517          	auipc	a0,0x1
    802001a2:	a0a50513          	addi	a0,a0,-1526 # 80200ba8 <etext+0x202>
    802001a6:	ec7ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
    802001aa:	680c                	ld	a1,16(s0)
    802001ac:	00001517          	auipc	a0,0x1
    802001b0:	a1450513          	addi	a0,a0,-1516 # 80200bc0 <etext+0x21a>
    802001b4:	eb9ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
    802001b8:	6c0c                	ld	a1,24(s0)
    802001ba:	00001517          	auipc	a0,0x1
    802001be:	a1e50513          	addi	a0,a0,-1506 # 80200bd8 <etext+0x232>
    802001c2:	eabff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
    802001c6:	700c                	ld	a1,32(s0)
    802001c8:	00001517          	auipc	a0,0x1
    802001cc:	a2850513          	addi	a0,a0,-1496 # 80200bf0 <etext+0x24a>
    802001d0:	e9dff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
    802001d4:	740c                	ld	a1,40(s0)
    802001d6:	00001517          	auipc	a0,0x1
    802001da:	a3250513          	addi	a0,a0,-1486 # 80200c08 <etext+0x262>
    802001de:	e8fff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
    802001e2:	780c                	ld	a1,48(s0)
    802001e4:	00001517          	auipc	a0,0x1
    802001e8:	a3c50513          	addi	a0,a0,-1476 # 80200c20 <etext+0x27a>
    802001ec:	e81ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
    802001f0:	7c0c                	ld	a1,56(s0)
    802001f2:	00001517          	auipc	a0,0x1
    802001f6:	a4650513          	addi	a0,a0,-1466 # 80200c38 <etext+0x292>
    802001fa:	e73ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
    802001fe:	602c                	ld	a1,64(s0)
    80200200:	00001517          	auipc	a0,0x1
    80200204:	a5050513          	addi	a0,a0,-1456 # 80200c50 <etext+0x2aa>
    80200208:	e65ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
    8020020c:	642c                	ld	a1,72(s0)
    8020020e:	00001517          	auipc	a0,0x1
    80200212:	a5a50513          	addi	a0,a0,-1446 # 80200c68 <etext+0x2c2>
    80200216:	e57ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
    8020021a:	682c                	ld	a1,80(s0)
    8020021c:	00001517          	auipc	a0,0x1
    80200220:	a6450513          	addi	a0,a0,-1436 # 80200c80 <etext+0x2da>
    80200224:	e49ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
    80200228:	6c2c                	ld	a1,88(s0)
    8020022a:	00001517          	auipc	a0,0x1
    8020022e:	a6e50513          	addi	a0,a0,-1426 # 80200c98 <etext+0x2f2>
    80200232:	e3bff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
    80200236:	702c                	ld	a1,96(s0)
    80200238:	00001517          	auipc	a0,0x1
    8020023c:	a7850513          	addi	a0,a0,-1416 # 80200cb0 <etext+0x30a>
    80200240:	e2dff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
    80200244:	742c                	ld	a1,104(s0)
    80200246:	00001517          	auipc	a0,0x1
    8020024a:	a8250513          	addi	a0,a0,-1406 # 80200cc8 <etext+0x322>
    8020024e:	e1fff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
    80200252:	782c                	ld	a1,112(s0)
    80200254:	00001517          	auipc	a0,0x1
    80200258:	a8c50513          	addi	a0,a0,-1396 # 80200ce0 <etext+0x33a>
    8020025c:	e11ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
    80200260:	7c2c                	ld	a1,120(s0)
    80200262:	00001517          	auipc	a0,0x1
    80200266:	a9650513          	addi	a0,a0,-1386 # 80200cf8 <etext+0x352>
    8020026a:	e03ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
    8020026e:	604c                	ld	a1,128(s0)
    80200270:	00001517          	auipc	a0,0x1
    80200274:	aa050513          	addi	a0,a0,-1376 # 80200d10 <etext+0x36a>
    80200278:	df5ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
    8020027c:	644c                	ld	a1,136(s0)
    8020027e:	00001517          	auipc	a0,0x1
    80200282:	aaa50513          	addi	a0,a0,-1366 # 80200d28 <etext+0x382>
    80200286:	de7ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
    8020028a:	684c                	ld	a1,144(s0)
    8020028c:	00001517          	auipc	a0,0x1
    80200290:	ab450513          	addi	a0,a0,-1356 # 80200d40 <etext+0x39a>
    80200294:	dd9ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
    80200298:	6c4c                	ld	a1,152(s0)
    8020029a:	00001517          	auipc	a0,0x1
    8020029e:	abe50513          	addi	a0,a0,-1346 # 80200d58 <etext+0x3b2>
    802002a2:	dcbff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
    802002a6:	704c                	ld	a1,160(s0)
    802002a8:	00001517          	auipc	a0,0x1
    802002ac:	ac850513          	addi	a0,a0,-1336 # 80200d70 <etext+0x3ca>
    802002b0:	dbdff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
    802002b4:	744c                	ld	a1,168(s0)
    802002b6:	00001517          	auipc	a0,0x1
    802002ba:	ad250513          	addi	a0,a0,-1326 # 80200d88 <etext+0x3e2>
    802002be:	dafff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
    802002c2:	784c                	ld	a1,176(s0)
    802002c4:	00001517          	auipc	a0,0x1
    802002c8:	adc50513          	addi	a0,a0,-1316 # 80200da0 <etext+0x3fa>
    802002cc:	da1ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
    802002d0:	7c4c                	ld	a1,184(s0)
    802002d2:	00001517          	auipc	a0,0x1
    802002d6:	ae650513          	addi	a0,a0,-1306 # 80200db8 <etext+0x412>
    802002da:	d93ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
    802002de:	606c                	ld	a1,192(s0)
    802002e0:	00001517          	auipc	a0,0x1
    802002e4:	af050513          	addi	a0,a0,-1296 # 80200dd0 <etext+0x42a>
    802002e8:	d85ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
    802002ec:	646c                	ld	a1,200(s0)
    802002ee:	00001517          	auipc	a0,0x1
    802002f2:	afa50513          	addi	a0,a0,-1286 # 80200de8 <etext+0x442>
    802002f6:	d77ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
    802002fa:	686c                	ld	a1,208(s0)
    802002fc:	00001517          	auipc	a0,0x1
    80200300:	b0450513          	addi	a0,a0,-1276 # 80200e00 <etext+0x45a>
    80200304:	d69ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
    80200308:	6c6c                	ld	a1,216(s0)
    8020030a:	00001517          	auipc	a0,0x1
    8020030e:	b0e50513          	addi	a0,a0,-1266 # 80200e18 <etext+0x472>
    80200312:	d5bff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
    80200316:	706c                	ld	a1,224(s0)
    80200318:	00001517          	auipc	a0,0x1
    8020031c:	b1850513          	addi	a0,a0,-1256 # 80200e30 <etext+0x48a>
    80200320:	d4dff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
    80200324:	746c                	ld	a1,232(s0)
    80200326:	00001517          	auipc	a0,0x1
    8020032a:	b2250513          	addi	a0,a0,-1246 # 80200e48 <etext+0x4a2>
    8020032e:	d3fff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
    80200332:	786c                	ld	a1,240(s0)
    80200334:	00001517          	auipc	a0,0x1
    80200338:	b2c50513          	addi	a0,a0,-1236 # 80200e60 <etext+0x4ba>
    8020033c:	d31ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
    80200340:	7c6c                	ld	a1,248(s0)
}
    80200342:	6402                	ld	s0,0(sp)
    80200344:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
    80200346:	00001517          	auipc	a0,0x1
    8020034a:	b3250513          	addi	a0,a0,-1230 # 80200e78 <etext+0x4d2>
}
    8020034e:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
    80200350:	d1dff06f          	j	8020006c <cprintf>

0000000080200354 <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
    80200354:	1141                	addi	sp,sp,-16
    80200356:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
    80200358:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
    8020035a:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
    8020035c:	00001517          	auipc	a0,0x1
    80200360:	b3450513          	addi	a0,a0,-1228 # 80200e90 <etext+0x4ea>
void print_trapframe(struct trapframe *tf) {
    80200364:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
    80200366:	d07ff0ef          	jal	ra,8020006c <cprintf>
    print_regs(&tf->gpr);
    8020036a:	8522                	mv	a0,s0
    8020036c:	e1bff0ef          	jal	ra,80200186 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
    80200370:	10043583          	ld	a1,256(s0)
    80200374:	00001517          	auipc	a0,0x1
    80200378:	b3450513          	addi	a0,a0,-1228 # 80200ea8 <etext+0x502>
    8020037c:	cf1ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
    80200380:	10843583          	ld	a1,264(s0)
    80200384:	00001517          	auipc	a0,0x1
    80200388:	b3c50513          	addi	a0,a0,-1220 # 80200ec0 <etext+0x51a>
    8020038c:	ce1ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    80200390:	11043583          	ld	a1,272(s0)
    80200394:	00001517          	auipc	a0,0x1
    80200398:	b4450513          	addi	a0,a0,-1212 # 80200ed8 <etext+0x532>
    8020039c:	cd1ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
    802003a0:	11843583          	ld	a1,280(s0)
}
    802003a4:	6402                	ld	s0,0(sp)
    802003a6:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
    802003a8:	00001517          	auipc	a0,0x1
    802003ac:	b4850513          	addi	a0,a0,-1208 # 80200ef0 <etext+0x54a>
}
    802003b0:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
    802003b2:	cbbff06f          	j	8020006c <cprintf>

00000000802003b6 <interrupt_handler>:

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
    802003b6:	11853783          	ld	a5,280(a0)
    802003ba:	577d                	li	a4,-1
    802003bc:	8305                	srli	a4,a4,0x1
    802003be:	8ff9                	and	a5,a5,a4
    switch (cause) {
    802003c0:	472d                	li	a4,11
    802003c2:	04f76a63          	bltu	a4,a5,80200416 <interrupt_handler+0x60>
    802003c6:	00000717          	auipc	a4,0x0
    802003ca:	6f670713          	addi	a4,a4,1782 # 80200abc <etext+0x116>
    802003ce:	078a                	slli	a5,a5,0x2
    802003d0:	97ba                	add	a5,a5,a4
    802003d2:	439c                	lw	a5,0(a5)
    802003d4:	97ba                	add	a5,a5,a4
    802003d6:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
    802003d8:	00000517          	auipc	a0,0x0
    802003dc:	77850513          	addi	a0,a0,1912 # 80200b50 <etext+0x1aa>
    802003e0:	c8dff06f          	j	8020006c <cprintf>
            cprintf("Hypervisor software interrupt\n");
    802003e4:	00000517          	auipc	a0,0x0
    802003e8:	74c50513          	addi	a0,a0,1868 # 80200b30 <etext+0x18a>
    802003ec:	c81ff06f          	j	8020006c <cprintf>
            cprintf("User software interrupt\n");
    802003f0:	00000517          	auipc	a0,0x0
    802003f4:	70050513          	addi	a0,a0,1792 # 80200af0 <etext+0x14a>
    802003f8:	c75ff06f          	j	8020006c <cprintf>
            cprintf("Supervisor software interrupt\n");
    802003fc:	00000517          	auipc	a0,0x0
    80200400:	71450513          	addi	a0,a0,1812 # 80200b10 <etext+0x16a>
    80200404:	c69ff06f          	j	8020006c <cprintf>
            break;
        case IRQ_U_EXT:
            cprintf("User software interrupt\n");
            break;
        case IRQ_S_EXT:
            cprintf("Supervisor external interrupt\n");
    80200408:	00000517          	auipc	a0,0x0
    8020040c:	76850513          	addi	a0,a0,1896 # 80200b70 <etext+0x1ca>
    80200410:	c5dff06f          	j	8020006c <cprintf>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
    80200414:	8082                	ret
            print_trapframe(tf);
    80200416:	f3fff06f          	j	80200354 <print_trapframe>

000000008020041a <exception_handler>:

void exception_handler(struct trapframe *tf) {
    switch (tf->cause) {
    8020041a:	11853583          	ld	a1,280(a0)
    8020041e:	47ad                	li	a5,11
    80200420:	02b7e863          	bltu	a5,a1,80200450 <exception_handler+0x36>
    80200424:	4705                	li	a4,1
    80200426:	6785                	lui	a5,0x1
    80200428:	00b71733          	sll	a4,a4,a1
    8020042c:	17cd                	addi	a5,a5,-13
    8020042e:	8ff9                	and	a5,a5,a4
    80200430:	ef99                	bnez	a5,8020044e <exception_handler+0x34>
void exception_handler(struct trapframe *tf) {
    80200432:	1141                	addi	sp,sp,-16
    80200434:	e022                	sd	s0,0(sp)
    80200436:	e406                	sd	ra,8(sp)
    80200438:	00877793          	andi	a5,a4,8
    8020043c:	842a                	mv	s0,a0
    8020043e:	eb99                	bnez	a5,80200454 <exception_handler+0x3a>
    80200440:	8b11                	andi	a4,a4,4
    80200442:	eb09                	bnez	a4,80200454 <exception_handler+0x3a>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
    80200444:	6402                	ld	s0,0(sp)
    80200446:	60a2                	ld	ra,8(sp)
    80200448:	0141                	addi	sp,sp,16
            print_trapframe(tf);
    8020044a:	f0bff06f          	j	80200354 <print_trapframe>
    8020044e:	8082                	ret
    80200450:	f05ff06f          	j	80200354 <print_trapframe>
            cprintf("  cause    0x%08x\n", tf->cause);
    80200454:	00001517          	auipc	a0,0x1
    80200458:	a9c50513          	addi	a0,a0,-1380 # 80200ef0 <etext+0x54a>
    8020045c:	c11ff0ef          	jal	ra,8020006c <cprintf>
	    cprintf("  epc      0x%08x\n", tf->epc);
    80200460:	10843583          	ld	a1,264(s0)
}
    80200464:	6402                	ld	s0,0(sp)
    80200466:	60a2                	ld	ra,8(sp)
	    cprintf("  epc      0x%08x\n", tf->epc);
    80200468:	00001517          	auipc	a0,0x1
    8020046c:	a5850513          	addi	a0,a0,-1448 # 80200ec0 <etext+0x51a>
}
    80200470:	0141                	addi	sp,sp,16
	    cprintf("  epc      0x%08x\n", tf->epc);
    80200472:	bfbff06f          	j	8020006c <cprintf>

0000000080200476 <trap>:

/* trap_dispatch - dispatch based on what type of trap occurred */
static inline void trap_dispatch(struct trapframe *tf) {
    if ((intptr_t)tf->cause < 0) {
    80200476:	11853783          	ld	a5,280(a0)
    8020047a:	0007c463          	bltz	a5,80200482 <trap+0xc>
        // interrupts
        interrupt_handler(tf);
    } else {
        // exceptions
        exception_handler(tf);
    8020047e:	f9dff06f          	j	8020041a <exception_handler>
        interrupt_handler(tf);
    80200482:	f35ff06f          	j	802003b6 <interrupt_handler>
	...

0000000080200488 <__alltraps>:
    .endm

    .globl __alltraps
.align(2)
__alltraps:
    SAVE_ALL
    80200488:	14011073          	csrw	sscratch,sp
    8020048c:	712d                	addi	sp,sp,-288
    8020048e:	e002                	sd	zero,0(sp)
    80200490:	e406                	sd	ra,8(sp)
    80200492:	ec0e                	sd	gp,24(sp)
    80200494:	f012                	sd	tp,32(sp)
    80200496:	f416                	sd	t0,40(sp)
    80200498:	f81a                	sd	t1,48(sp)
    8020049a:	fc1e                	sd	t2,56(sp)
    8020049c:	e0a2                	sd	s0,64(sp)
    8020049e:	e4a6                	sd	s1,72(sp)
    802004a0:	e8aa                	sd	a0,80(sp)
    802004a2:	ecae                	sd	a1,88(sp)
    802004a4:	f0b2                	sd	a2,96(sp)
    802004a6:	f4b6                	sd	a3,104(sp)
    802004a8:	f8ba                	sd	a4,112(sp)
    802004aa:	fcbe                	sd	a5,120(sp)
    802004ac:	e142                	sd	a6,128(sp)
    802004ae:	e546                	sd	a7,136(sp)
    802004b0:	e94a                	sd	s2,144(sp)
    802004b2:	ed4e                	sd	s3,152(sp)
    802004b4:	f152                	sd	s4,160(sp)
    802004b6:	f556                	sd	s5,168(sp)
    802004b8:	f95a                	sd	s6,176(sp)
    802004ba:	fd5e                	sd	s7,184(sp)
    802004bc:	e1e2                	sd	s8,192(sp)
    802004be:	e5e6                	sd	s9,200(sp)
    802004c0:	e9ea                	sd	s10,208(sp)
    802004c2:	edee                	sd	s11,216(sp)
    802004c4:	f1f2                	sd	t3,224(sp)
    802004c6:	f5f6                	sd	t4,232(sp)
    802004c8:	f9fa                	sd	t5,240(sp)
    802004ca:	fdfe                	sd	t6,248(sp)
    802004cc:	14001473          	csrrw	s0,sscratch,zero
    802004d0:	100024f3          	csrr	s1,sstatus
    802004d4:	14102973          	csrr	s2,sepc
    802004d8:	143029f3          	csrr	s3,stval
    802004dc:	14202a73          	csrr	s4,scause
    802004e0:	e822                	sd	s0,16(sp)
    802004e2:	e226                	sd	s1,256(sp)
    802004e4:	e64a                	sd	s2,264(sp)
    802004e6:	ea4e                	sd	s3,272(sp)
    802004e8:	ee52                	sd	s4,280(sp)

    move  a0, sp
    802004ea:	850a                	mv	a0,sp
    jal trap
    802004ec:	f8bff0ef          	jal	ra,80200476 <trap>

00000000802004f0 <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
    802004f0:	6492                	ld	s1,256(sp)
    802004f2:	6932                	ld	s2,264(sp)
    802004f4:	10049073          	csrw	sstatus,s1
    802004f8:	14191073          	csrw	sepc,s2
    802004fc:	60a2                	ld	ra,8(sp)
    802004fe:	61e2                	ld	gp,24(sp)
    80200500:	7202                	ld	tp,32(sp)
    80200502:	72a2                	ld	t0,40(sp)
    80200504:	7342                	ld	t1,48(sp)
    80200506:	73e2                	ld	t2,56(sp)
    80200508:	6406                	ld	s0,64(sp)
    8020050a:	64a6                	ld	s1,72(sp)
    8020050c:	6546                	ld	a0,80(sp)
    8020050e:	65e6                	ld	a1,88(sp)
    80200510:	7606                	ld	a2,96(sp)
    80200512:	76a6                	ld	a3,104(sp)
    80200514:	7746                	ld	a4,112(sp)
    80200516:	77e6                	ld	a5,120(sp)
    80200518:	680a                	ld	a6,128(sp)
    8020051a:	68aa                	ld	a7,136(sp)
    8020051c:	694a                	ld	s2,144(sp)
    8020051e:	69ea                	ld	s3,152(sp)
    80200520:	7a0a                	ld	s4,160(sp)
    80200522:	7aaa                	ld	s5,168(sp)
    80200524:	7b4a                	ld	s6,176(sp)
    80200526:	7bea                	ld	s7,184(sp)
    80200528:	6c0e                	ld	s8,192(sp)
    8020052a:	6cae                	ld	s9,200(sp)
    8020052c:	6d4e                	ld	s10,208(sp)
    8020052e:	6dee                	ld	s11,216(sp)
    80200530:	7e0e                	ld	t3,224(sp)
    80200532:	7eae                	ld	t4,232(sp)
    80200534:	7f4e                	ld	t5,240(sp)
    80200536:	7fee                	ld	t6,248(sp)
    80200538:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
    8020053a:	10200073          	sret

000000008020053e <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
    8020053e:	c185                	beqz	a1,8020055e <strnlen+0x20>
    80200540:	00054783          	lbu	a5,0(a0)
    80200544:	cf89                	beqz	a5,8020055e <strnlen+0x20>
    size_t cnt = 0;
    80200546:	4781                	li	a5,0
    80200548:	a021                	j	80200550 <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
    8020054a:	00074703          	lbu	a4,0(a4)
    8020054e:	c711                	beqz	a4,8020055a <strnlen+0x1c>
        cnt ++;
    80200550:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
    80200552:	00f50733          	add	a4,a0,a5
    80200556:	fef59ae3          	bne	a1,a5,8020054a <strnlen+0xc>
    }
    return cnt;
}
    8020055a:	853e                	mv	a0,a5
    8020055c:	8082                	ret
    size_t cnt = 0;
    8020055e:	4781                	li	a5,0
}
    80200560:	853e                	mv	a0,a5
    80200562:	8082                	ret

0000000080200564 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
    80200564:	ca01                	beqz	a2,80200574 <memset+0x10>
    80200566:	962a                	add	a2,a2,a0
    char *p = s;
    80200568:	87aa                	mv	a5,a0
        *p ++ = c;
    8020056a:	0785                	addi	a5,a5,1
    8020056c:	feb78fa3          	sb	a1,-1(a5) # fff <BASE_ADDRESS-0x801ff001>
    while (n -- > 0) {
    80200570:	fec79de3          	bne	a5,a2,8020056a <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
    80200574:	8082                	ret

0000000080200576 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
    80200576:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
    8020057a:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
    8020057c:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
    80200580:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
    80200582:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
    80200586:	f022                	sd	s0,32(sp)
    80200588:	ec26                	sd	s1,24(sp)
    8020058a:	e84a                	sd	s2,16(sp)
    8020058c:	f406                	sd	ra,40(sp)
    8020058e:	e44e                	sd	s3,8(sp)
    80200590:	84aa                	mv	s1,a0
    80200592:	892e                	mv	s2,a1
    80200594:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
    80200598:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
    8020059a:	03067e63          	bleu	a6,a2,802005d6 <printnum+0x60>
    8020059e:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
    802005a0:	00805763          	blez	s0,802005ae <printnum+0x38>
    802005a4:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
    802005a6:	85ca                	mv	a1,s2
    802005a8:	854e                	mv	a0,s3
    802005aa:	9482                	jalr	s1
        while (-- width > 0)
    802005ac:	fc65                	bnez	s0,802005a4 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
    802005ae:	1a02                	slli	s4,s4,0x20
    802005b0:	020a5a13          	srli	s4,s4,0x20
    802005b4:	00001797          	auipc	a5,0x1
    802005b8:	ae478793          	addi	a5,a5,-1308 # 80201098 <error_string+0x38>
    802005bc:	9a3e                	add	s4,s4,a5
}
    802005be:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
    802005c0:	000a4503          	lbu	a0,0(s4)
}
    802005c4:	70a2                	ld	ra,40(sp)
    802005c6:	69a2                	ld	s3,8(sp)
    802005c8:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
    802005ca:	85ca                	mv	a1,s2
    802005cc:	8326                	mv	t1,s1
}
    802005ce:	6942                	ld	s2,16(sp)
    802005d0:	64e2                	ld	s1,24(sp)
    802005d2:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
    802005d4:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
    802005d6:	03065633          	divu	a2,a2,a6
    802005da:	8722                	mv	a4,s0
    802005dc:	f9bff0ef          	jal	ra,80200576 <printnum>
    802005e0:	b7f9                	j	802005ae <printnum+0x38>

00000000802005e2 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
    802005e2:	7119                	addi	sp,sp,-128
    802005e4:	f4a6                	sd	s1,104(sp)
    802005e6:	f0ca                	sd	s2,96(sp)
    802005e8:	e8d2                	sd	s4,80(sp)
    802005ea:	e4d6                	sd	s5,72(sp)
    802005ec:	e0da                	sd	s6,64(sp)
    802005ee:	fc5e                	sd	s7,56(sp)
    802005f0:	f862                	sd	s8,48(sp)
    802005f2:	f06a                	sd	s10,32(sp)
    802005f4:	fc86                	sd	ra,120(sp)
    802005f6:	f8a2                	sd	s0,112(sp)
    802005f8:	ecce                	sd	s3,88(sp)
    802005fa:	f466                	sd	s9,40(sp)
    802005fc:	ec6e                	sd	s11,24(sp)
    802005fe:	892a                	mv	s2,a0
    80200600:	84ae                	mv	s1,a1
    80200602:	8d32                	mv	s10,a2
    80200604:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
    80200606:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
    80200608:	00001a17          	auipc	s4,0x1
    8020060c:	8fca0a13          	addi	s4,s4,-1796 # 80200f04 <etext+0x55e>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
    80200610:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
    80200614:	00001c17          	auipc	s8,0x1
    80200618:	a4cc0c13          	addi	s8,s8,-1460 # 80201060 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    8020061c:	000d4503          	lbu	a0,0(s10)
    80200620:	02500793          	li	a5,37
    80200624:	001d0413          	addi	s0,s10,1
    80200628:	00f50e63          	beq	a0,a5,80200644 <vprintfmt+0x62>
            if (ch == '\0') {
    8020062c:	c521                	beqz	a0,80200674 <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    8020062e:	02500993          	li	s3,37
    80200632:	a011                	j	80200636 <vprintfmt+0x54>
            if (ch == '\0') {
    80200634:	c121                	beqz	a0,80200674 <vprintfmt+0x92>
            putch(ch, putdat);
    80200636:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    80200638:	0405                	addi	s0,s0,1
            putch(ch, putdat);
    8020063a:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    8020063c:	fff44503          	lbu	a0,-1(s0)
    80200640:	ff351ae3          	bne	a0,s3,80200634 <vprintfmt+0x52>
    80200644:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
    80200648:	02000793          	li	a5,32
        lflag = altflag = 0;
    8020064c:	4981                	li	s3,0
    8020064e:	4801                	li	a6,0
        width = precision = -1;
    80200650:	5cfd                	li	s9,-1
    80200652:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
    80200654:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
    80200658:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
    8020065a:	fdd6069b          	addiw	a3,a2,-35
    8020065e:	0ff6f693          	andi	a3,a3,255
    80200662:	00140d13          	addi	s10,s0,1
    80200666:	20d5e563          	bltu	a1,a3,80200870 <vprintfmt+0x28e>
    8020066a:	068a                	slli	a3,a3,0x2
    8020066c:	96d2                	add	a3,a3,s4
    8020066e:	4294                	lw	a3,0(a3)
    80200670:	96d2                	add	a3,a3,s4
    80200672:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
    80200674:	70e6                	ld	ra,120(sp)
    80200676:	7446                	ld	s0,112(sp)
    80200678:	74a6                	ld	s1,104(sp)
    8020067a:	7906                	ld	s2,96(sp)
    8020067c:	69e6                	ld	s3,88(sp)
    8020067e:	6a46                	ld	s4,80(sp)
    80200680:	6aa6                	ld	s5,72(sp)
    80200682:	6b06                	ld	s6,64(sp)
    80200684:	7be2                	ld	s7,56(sp)
    80200686:	7c42                	ld	s8,48(sp)
    80200688:	7ca2                	ld	s9,40(sp)
    8020068a:	7d02                	ld	s10,32(sp)
    8020068c:	6de2                	ld	s11,24(sp)
    8020068e:	6109                	addi	sp,sp,128
    80200690:	8082                	ret
    if (lflag >= 2) {
    80200692:	4705                	li	a4,1
    80200694:	008a8593          	addi	a1,s5,8
    80200698:	01074463          	blt	a4,a6,802006a0 <vprintfmt+0xbe>
    else if (lflag) {
    8020069c:	26080363          	beqz	a6,80200902 <vprintfmt+0x320>
        return va_arg(*ap, unsigned long);
    802006a0:	000ab603          	ld	a2,0(s5)
    802006a4:	46c1                	li	a3,16
    802006a6:	8aae                	mv	s5,a1
    802006a8:	a06d                	j	80200752 <vprintfmt+0x170>
            goto reswitch;
    802006aa:	00144603          	lbu	a2,1(s0)
            altflag = 1;
    802006ae:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
    802006b0:	846a                	mv	s0,s10
            goto reswitch;
    802006b2:	b765                	j	8020065a <vprintfmt+0x78>
            putch(va_arg(ap, int), putdat);
    802006b4:	000aa503          	lw	a0,0(s5)
    802006b8:	85a6                	mv	a1,s1
    802006ba:	0aa1                	addi	s5,s5,8
    802006bc:	9902                	jalr	s2
            break;
    802006be:	bfb9                	j	8020061c <vprintfmt+0x3a>
    if (lflag >= 2) {
    802006c0:	4705                	li	a4,1
    802006c2:	008a8993          	addi	s3,s5,8
    802006c6:	01074463          	blt	a4,a6,802006ce <vprintfmt+0xec>
    else if (lflag) {
    802006ca:	22080463          	beqz	a6,802008f2 <vprintfmt+0x310>
        return va_arg(*ap, long);
    802006ce:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
    802006d2:	24044463          	bltz	s0,8020091a <vprintfmt+0x338>
            num = getint(&ap, lflag);
    802006d6:	8622                	mv	a2,s0
    802006d8:	8ace                	mv	s5,s3
    802006da:	46a9                	li	a3,10
    802006dc:	a89d                	j	80200752 <vprintfmt+0x170>
            err = va_arg(ap, int);
    802006de:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
    802006e2:	4719                	li	a4,6
            err = va_arg(ap, int);
    802006e4:	0aa1                	addi	s5,s5,8
            if (err < 0) {
    802006e6:	41f7d69b          	sraiw	a3,a5,0x1f
    802006ea:	8fb5                	xor	a5,a5,a3
    802006ec:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
    802006f0:	1ad74363          	blt	a4,a3,80200896 <vprintfmt+0x2b4>
    802006f4:	00369793          	slli	a5,a3,0x3
    802006f8:	97e2                	add	a5,a5,s8
    802006fa:	639c                	ld	a5,0(a5)
    802006fc:	18078d63          	beqz	a5,80200896 <vprintfmt+0x2b4>
                printfmt(putch, putdat, "%s", p);
    80200700:	86be                	mv	a3,a5
    80200702:	00001617          	auipc	a2,0x1
    80200706:	a4660613          	addi	a2,a2,-1466 # 80201148 <error_string+0xe8>
    8020070a:	85a6                	mv	a1,s1
    8020070c:	854a                	mv	a0,s2
    8020070e:	240000ef          	jal	ra,8020094e <printfmt>
    80200712:	b729                	j	8020061c <vprintfmt+0x3a>
            lflag ++;
    80200714:	00144603          	lbu	a2,1(s0)
    80200718:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
    8020071a:	846a                	mv	s0,s10
            goto reswitch;
    8020071c:	bf3d                	j	8020065a <vprintfmt+0x78>
    if (lflag >= 2) {
    8020071e:	4705                	li	a4,1
    80200720:	008a8593          	addi	a1,s5,8
    80200724:	01074463          	blt	a4,a6,8020072c <vprintfmt+0x14a>
    else if (lflag) {
    80200728:	1e080263          	beqz	a6,8020090c <vprintfmt+0x32a>
        return va_arg(*ap, unsigned long);
    8020072c:	000ab603          	ld	a2,0(s5)
    80200730:	46a1                	li	a3,8
    80200732:	8aae                	mv	s5,a1
    80200734:	a839                	j	80200752 <vprintfmt+0x170>
            putch('0', putdat);
    80200736:	03000513          	li	a0,48
    8020073a:	85a6                	mv	a1,s1
    8020073c:	e03e                	sd	a5,0(sp)
    8020073e:	9902                	jalr	s2
            putch('x', putdat);
    80200740:	85a6                	mv	a1,s1
    80200742:	07800513          	li	a0,120
    80200746:	9902                	jalr	s2
            num = (unsigned long long)va_arg(ap, void *);
    80200748:	0aa1                	addi	s5,s5,8
    8020074a:	ff8ab603          	ld	a2,-8(s5)
            goto number;
    8020074e:	6782                	ld	a5,0(sp)
    80200750:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
    80200752:	876e                	mv	a4,s11
    80200754:	85a6                	mv	a1,s1
    80200756:	854a                	mv	a0,s2
    80200758:	e1fff0ef          	jal	ra,80200576 <printnum>
            break;
    8020075c:	b5c1                	j	8020061c <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
    8020075e:	000ab603          	ld	a2,0(s5)
    80200762:	0aa1                	addi	s5,s5,8
    80200764:	1c060663          	beqz	a2,80200930 <vprintfmt+0x34e>
            if (width > 0 && padc != '-') {
    80200768:	00160413          	addi	s0,a2,1
    8020076c:	17b05c63          	blez	s11,802008e4 <vprintfmt+0x302>
    80200770:	02d00593          	li	a1,45
    80200774:	14b79263          	bne	a5,a1,802008b8 <vprintfmt+0x2d6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    80200778:	00064783          	lbu	a5,0(a2)
    8020077c:	0007851b          	sext.w	a0,a5
    80200780:	c905                	beqz	a0,802007b0 <vprintfmt+0x1ce>
    80200782:	000cc563          	bltz	s9,8020078c <vprintfmt+0x1aa>
    80200786:	3cfd                	addiw	s9,s9,-1
    80200788:	036c8263          	beq	s9,s6,802007ac <vprintfmt+0x1ca>
                    putch('?', putdat);
    8020078c:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
    8020078e:	18098463          	beqz	s3,80200916 <vprintfmt+0x334>
    80200792:	3781                	addiw	a5,a5,-32
    80200794:	18fbf163          	bleu	a5,s7,80200916 <vprintfmt+0x334>
                    putch('?', putdat);
    80200798:	03f00513          	li	a0,63
    8020079c:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    8020079e:	0405                	addi	s0,s0,1
    802007a0:	fff44783          	lbu	a5,-1(s0)
    802007a4:	3dfd                	addiw	s11,s11,-1
    802007a6:	0007851b          	sext.w	a0,a5
    802007aa:	fd61                	bnez	a0,80200782 <vprintfmt+0x1a0>
            for (; width > 0; width --) {
    802007ac:	e7b058e3          	blez	s11,8020061c <vprintfmt+0x3a>
    802007b0:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
    802007b2:	85a6                	mv	a1,s1
    802007b4:	02000513          	li	a0,32
    802007b8:	9902                	jalr	s2
            for (; width > 0; width --) {
    802007ba:	e60d81e3          	beqz	s11,8020061c <vprintfmt+0x3a>
    802007be:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
    802007c0:	85a6                	mv	a1,s1
    802007c2:	02000513          	li	a0,32
    802007c6:	9902                	jalr	s2
            for (; width > 0; width --) {
    802007c8:	fe0d94e3          	bnez	s11,802007b0 <vprintfmt+0x1ce>
    802007cc:	bd81                	j	8020061c <vprintfmt+0x3a>
    if (lflag >= 2) {
    802007ce:	4705                	li	a4,1
    802007d0:	008a8593          	addi	a1,s5,8
    802007d4:	01074463          	blt	a4,a6,802007dc <vprintfmt+0x1fa>
    else if (lflag) {
    802007d8:	12080063          	beqz	a6,802008f8 <vprintfmt+0x316>
        return va_arg(*ap, unsigned long);
    802007dc:	000ab603          	ld	a2,0(s5)
    802007e0:	46a9                	li	a3,10
    802007e2:	8aae                	mv	s5,a1
    802007e4:	b7bd                	j	80200752 <vprintfmt+0x170>
    802007e6:	00144603          	lbu	a2,1(s0)
            padc = '-';
    802007ea:	02d00793          	li	a5,45
        switch (ch = *(unsigned char *)fmt ++) {
    802007ee:	846a                	mv	s0,s10
    802007f0:	b5ad                	j	8020065a <vprintfmt+0x78>
            putch(ch, putdat);
    802007f2:	85a6                	mv	a1,s1
    802007f4:	02500513          	li	a0,37
    802007f8:	9902                	jalr	s2
            break;
    802007fa:	b50d                	j	8020061c <vprintfmt+0x3a>
            precision = va_arg(ap, int);
    802007fc:	000aac83          	lw	s9,0(s5)
            goto process_precision;
    80200800:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
    80200804:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
    80200806:	846a                	mv	s0,s10
            if (width < 0)
    80200808:	e40dd9e3          	bgez	s11,8020065a <vprintfmt+0x78>
                width = precision, precision = -1;
    8020080c:	8de6                	mv	s11,s9
    8020080e:	5cfd                	li	s9,-1
    80200810:	b5a9                	j	8020065a <vprintfmt+0x78>
            goto reswitch;
    80200812:	00144603          	lbu	a2,1(s0)
            padc = '0';
    80200816:	03000793          	li	a5,48
        switch (ch = *(unsigned char *)fmt ++) {
    8020081a:	846a                	mv	s0,s10
            goto reswitch;
    8020081c:	bd3d                	j	8020065a <vprintfmt+0x78>
                precision = precision * 10 + ch - '0';
    8020081e:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
    80200822:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
    80200826:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
    80200828:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
    8020082c:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
    80200830:	fcd56ce3          	bltu	a0,a3,80200808 <vprintfmt+0x226>
            for (precision = 0; ; ++ fmt) {
    80200834:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
    80200836:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
    8020083a:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
    8020083e:	0196873b          	addw	a4,a3,s9
    80200842:	0017171b          	slliw	a4,a4,0x1
    80200846:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
    8020084a:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
    8020084e:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
    80200852:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
    80200856:	fcd57fe3          	bleu	a3,a0,80200834 <vprintfmt+0x252>
    8020085a:	b77d                	j	80200808 <vprintfmt+0x226>
            if (width < 0)
    8020085c:	fffdc693          	not	a3,s11
    80200860:	96fd                	srai	a3,a3,0x3f
    80200862:	00ddfdb3          	and	s11,s11,a3
    80200866:	00144603          	lbu	a2,1(s0)
    8020086a:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
    8020086c:	846a                	mv	s0,s10
    8020086e:	b3f5                	j	8020065a <vprintfmt+0x78>
            putch('%', putdat);
    80200870:	85a6                	mv	a1,s1
    80200872:	02500513          	li	a0,37
    80200876:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
    80200878:	fff44703          	lbu	a4,-1(s0)
    8020087c:	02500793          	li	a5,37
    80200880:	8d22                	mv	s10,s0
    80200882:	d8f70de3          	beq	a4,a5,8020061c <vprintfmt+0x3a>
    80200886:	02500713          	li	a4,37
    8020088a:	1d7d                	addi	s10,s10,-1
    8020088c:	fffd4783          	lbu	a5,-1(s10)
    80200890:	fee79de3          	bne	a5,a4,8020088a <vprintfmt+0x2a8>
    80200894:	b361                	j	8020061c <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
    80200896:	00001617          	auipc	a2,0x1
    8020089a:	8a260613          	addi	a2,a2,-1886 # 80201138 <error_string+0xd8>
    8020089e:	85a6                	mv	a1,s1
    802008a0:	854a                	mv	a0,s2
    802008a2:	0ac000ef          	jal	ra,8020094e <printfmt>
    802008a6:	bb9d                	j	8020061c <vprintfmt+0x3a>
                p = "(null)";
    802008a8:	00001617          	auipc	a2,0x1
    802008ac:	88860613          	addi	a2,a2,-1912 # 80201130 <error_string+0xd0>
            if (width > 0 && padc != '-') {
    802008b0:	00001417          	auipc	s0,0x1
    802008b4:	88140413          	addi	s0,s0,-1919 # 80201131 <error_string+0xd1>
                for (width -= strnlen(p, precision); width > 0; width --) {
    802008b8:	8532                	mv	a0,a2
    802008ba:	85e6                	mv	a1,s9
    802008bc:	e032                	sd	a2,0(sp)
    802008be:	e43e                	sd	a5,8(sp)
    802008c0:	c7fff0ef          	jal	ra,8020053e <strnlen>
    802008c4:	40ad8dbb          	subw	s11,s11,a0
    802008c8:	6602                	ld	a2,0(sp)
    802008ca:	01b05d63          	blez	s11,802008e4 <vprintfmt+0x302>
    802008ce:	67a2                	ld	a5,8(sp)
    802008d0:	2781                	sext.w	a5,a5
    802008d2:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
    802008d4:	6522                	ld	a0,8(sp)
    802008d6:	85a6                	mv	a1,s1
    802008d8:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
    802008da:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
    802008dc:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
    802008de:	6602                	ld	a2,0(sp)
    802008e0:	fe0d9ae3          	bnez	s11,802008d4 <vprintfmt+0x2f2>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    802008e4:	00064783          	lbu	a5,0(a2)
    802008e8:	0007851b          	sext.w	a0,a5
    802008ec:	e8051be3          	bnez	a0,80200782 <vprintfmt+0x1a0>
    802008f0:	b335                	j	8020061c <vprintfmt+0x3a>
        return va_arg(*ap, int);
    802008f2:	000aa403          	lw	s0,0(s5)
    802008f6:	bbf1                	j	802006d2 <vprintfmt+0xf0>
        return va_arg(*ap, unsigned int);
    802008f8:	000ae603          	lwu	a2,0(s5)
    802008fc:	46a9                	li	a3,10
    802008fe:	8aae                	mv	s5,a1
    80200900:	bd89                	j	80200752 <vprintfmt+0x170>
    80200902:	000ae603          	lwu	a2,0(s5)
    80200906:	46c1                	li	a3,16
    80200908:	8aae                	mv	s5,a1
    8020090a:	b5a1                	j	80200752 <vprintfmt+0x170>
    8020090c:	000ae603          	lwu	a2,0(s5)
    80200910:	46a1                	li	a3,8
    80200912:	8aae                	mv	s5,a1
    80200914:	bd3d                	j	80200752 <vprintfmt+0x170>
                    putch(ch, putdat);
    80200916:	9902                	jalr	s2
    80200918:	b559                	j	8020079e <vprintfmt+0x1bc>
                putch('-', putdat);
    8020091a:	85a6                	mv	a1,s1
    8020091c:	02d00513          	li	a0,45
    80200920:	e03e                	sd	a5,0(sp)
    80200922:	9902                	jalr	s2
                num = -(long long)num;
    80200924:	8ace                	mv	s5,s3
    80200926:	40800633          	neg	a2,s0
    8020092a:	46a9                	li	a3,10
    8020092c:	6782                	ld	a5,0(sp)
    8020092e:	b515                	j	80200752 <vprintfmt+0x170>
            if (width > 0 && padc != '-') {
    80200930:	01b05663          	blez	s11,8020093c <vprintfmt+0x35a>
    80200934:	02d00693          	li	a3,45
    80200938:	f6d798e3          	bne	a5,a3,802008a8 <vprintfmt+0x2c6>
    8020093c:	00000417          	auipc	s0,0x0
    80200940:	7f540413          	addi	s0,s0,2037 # 80201131 <error_string+0xd1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    80200944:	02800513          	li	a0,40
    80200948:	02800793          	li	a5,40
    8020094c:	bd1d                	j	80200782 <vprintfmt+0x1a0>

000000008020094e <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
    8020094e:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
    80200950:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
    80200954:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
    80200956:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
    80200958:	ec06                	sd	ra,24(sp)
    8020095a:	f83a                	sd	a4,48(sp)
    8020095c:	fc3e                	sd	a5,56(sp)
    8020095e:	e0c2                	sd	a6,64(sp)
    80200960:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
    80200962:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
    80200964:	c7fff0ef          	jal	ra,802005e2 <vprintfmt>
}
    80200968:	60e2                	ld	ra,24(sp)
    8020096a:	6161                	addi	sp,sp,80
    8020096c:	8082                	ret

000000008020096e <sbi_console_putchar>:

int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
}
void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
    8020096e:	00003797          	auipc	a5,0x3
    80200972:	69278793          	addi	a5,a5,1682 # 80204000 <bootstacktop>
    __asm__ volatile (
    80200976:	6398                	ld	a4,0(a5)
    80200978:	4781                	li	a5,0
    8020097a:	88ba                	mv	a7,a4
    8020097c:	852a                	mv	a0,a0
    8020097e:	85be                	mv	a1,a5
    80200980:	863e                	mv	a2,a5
    80200982:	00000073          	ecall
    80200986:	87aa                	mv	a5,a0
}
    80200988:	8082                	ret

000000008020098a <sbi_set_timer>:

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
    8020098a:	00003797          	auipc	a5,0x3
    8020098e:	67e78793          	addi	a5,a5,1662 # 80204008 <edata>
    __asm__ volatile (
    80200992:	6398                	ld	a4,0(a5)
    80200994:	4781                	li	a5,0
    80200996:	88ba                	mv	a7,a4
    80200998:	852a                	mv	a0,a0
    8020099a:	85be                	mv	a1,a5
    8020099c:	863e                	mv	a2,a5
    8020099e:	00000073          	ecall
    802009a2:	87aa                	mv	a5,a0
}
    802009a4:	8082                	ret
