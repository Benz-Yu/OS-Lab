
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200000:	c02082b7          	lui	t0,0xc0208
    # t1 := 0xffffffff40000000 即虚实映射偏移量
    li      t1, 0xffffffffc0000000 - 0x80000000
ffffffffc0200004:	ffd0031b          	addiw	t1,zero,-3
ffffffffc0200008:	01e31313          	slli	t1,t1,0x1e
    # t0 减去虚实映射偏移量 0xffffffff40000000，变为三级页表的物理地址
    sub     t0, t0, t1
ffffffffc020000c:	406282b3          	sub	t0,t0,t1
    # t0 >>= 12，变为三级页表的物理页号
    srli    t0, t0, 12
ffffffffc0200010:	00c2d293          	srli	t0,t0,0xc

    # t1 := 8 << 60，设置 satp 的 MODE 字段为 Sv39
    li      t1, 8 << 60
ffffffffc0200014:	fff0031b          	addiw	t1,zero,-1
ffffffffc0200018:	03f31313          	slli	t1,t1,0x3f
    # 将刚才计算出的预设三级页表物理页号附加到 satp 中
    or      t0, t0, t1
ffffffffc020001c:	0062e2b3          	or	t0,t0,t1
    # 将算出的 t0(即新的MODE|页表基址物理页号) 覆盖到 satp 中
    csrw    satp, t0
ffffffffc0200020:	18029073          	csrw	satp,t0
    # 使用 sfence.vma 指令刷新 TLB
    sfence.vma
ffffffffc0200024:	12000073          	sfence.vma
    # 从此，我们给内核搭建出了一个完美的虚拟内存空间！
    #nop # 可能映射的位置有些bug。。插入一个nop
    
    # 我们在虚拟内存空间中：随意将 sp 设置为虚拟地址！
    lui sp, %hi(bootstacktop)
ffffffffc0200028:	c0208137          	lui	sp,0xc0208

    # 我们在虚拟内存空间中：随意跳转到虚拟地址！
    # 跳转到 kern_init
    lui t0, %hi(kern_init)
ffffffffc020002c:	c02002b7          	lui	t0,0xc0200
    addi t0, t0, %lo(kern_init)
ffffffffc0200030:	03628293          	addi	t0,t0,54 # ffffffffc0200036 <kern_init>
    jr t0
ffffffffc0200034:	8282                	jr	t0

ffffffffc0200036 <kern_init>:


int
kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc0200036:	00009517          	auipc	a0,0x9
ffffffffc020003a:	00a50513          	addi	a0,a0,10 # ffffffffc0209040 <edata>
ffffffffc020003e:	00010617          	auipc	a2,0x10
ffffffffc0200042:	56260613          	addi	a2,a2,1378 # ffffffffc02105a0 <end>
kern_init(void) {
ffffffffc0200046:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200048:	8e09                	sub	a2,a2,a0
ffffffffc020004a:	4581                	li	a1,0
kern_init(void) {
ffffffffc020004c:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004e:	090040ef          	jal	ra,ffffffffc02040de <memset>

    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);
ffffffffc0200052:	00004597          	auipc	a1,0x4
ffffffffc0200056:	0b658593          	addi	a1,a1,182 # ffffffffc0204108 <etext>
ffffffffc020005a:	00004517          	auipc	a0,0x4
ffffffffc020005e:	0ce50513          	addi	a0,a0,206 # ffffffffc0204128 <etext+0x20>
ffffffffc0200062:	05c000ef          	jal	ra,ffffffffc02000be <cprintf>

    print_kerninfo();
ffffffffc0200066:	0a0000ef          	jal	ra,ffffffffc0200106 <print_kerninfo>

    // grade_backtrace();

    pmm_init();                 // init physical memory management
ffffffffc020006a:	2bd010ef          	jal	ra,ffffffffc0201b26 <pmm_init>

    idt_init();                 // init interrupt descriptor table
ffffffffc020006e:	4e0000ef          	jal	ra,ffffffffc020054e <idt_init>

    vmm_init();                 // init virtual memory management
ffffffffc0200072:	44c030ef          	jal	ra,ffffffffc02034be <vmm_init>

    ide_init();                 // init ide devices
ffffffffc0200076:	426000ef          	jal	ra,ffffffffc020049c <ide_init>
    swap_init();                // init swap
ffffffffc020007a:	7a2020ef          	jal	ra,ffffffffc020281c <swap_init>

    clock_init();               // init clock interrupt
ffffffffc020007e:	356000ef          	jal	ra,ffffffffc02003d4 <clock_init>
    // intr_enable();              // enable irq interrupt



    /* do nothing */
    while (1);
ffffffffc0200082:	a001                	j	ffffffffc0200082 <kern_init+0x4c>

ffffffffc0200084 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc0200084:	1141                	addi	sp,sp,-16
ffffffffc0200086:	e022                	sd	s0,0(sp)
ffffffffc0200088:	e406                	sd	ra,8(sp)
ffffffffc020008a:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc020008c:	39e000ef          	jal	ra,ffffffffc020042a <cons_putc>
    (*cnt) ++;
ffffffffc0200090:	401c                	lw	a5,0(s0)
}
ffffffffc0200092:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc0200094:	2785                	addiw	a5,a5,1
ffffffffc0200096:	c01c                	sw	a5,0(s0)
}
ffffffffc0200098:	6402                	ld	s0,0(sp)
ffffffffc020009a:	0141                	addi	sp,sp,16
ffffffffc020009c:	8082                	ret

ffffffffc020009e <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc020009e:	1101                	addi	sp,sp,-32
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000a0:	86ae                	mv	a3,a1
ffffffffc02000a2:	862a                	mv	a2,a0
ffffffffc02000a4:	006c                	addi	a1,sp,12
ffffffffc02000a6:	00000517          	auipc	a0,0x0
ffffffffc02000aa:	fde50513          	addi	a0,a0,-34 # ffffffffc0200084 <cputch>
vcprintf(const char *fmt, va_list ap) {
ffffffffc02000ae:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc02000b0:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000b2:	345030ef          	jal	ra,ffffffffc0203bf6 <vprintfmt>
    return cnt;
}
ffffffffc02000b6:	60e2                	ld	ra,24(sp)
ffffffffc02000b8:	4532                	lw	a0,12(sp)
ffffffffc02000ba:	6105                	addi	sp,sp,32
ffffffffc02000bc:	8082                	ret

ffffffffc02000be <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc02000be:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc02000c0:	02810313          	addi	t1,sp,40 # ffffffffc0208028 <boot_page_table_sv39+0x28>
cprintf(const char *fmt, ...) {
ffffffffc02000c4:	f42e                	sd	a1,40(sp)
ffffffffc02000c6:	f832                	sd	a2,48(sp)
ffffffffc02000c8:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000ca:	862a                	mv	a2,a0
ffffffffc02000cc:	004c                	addi	a1,sp,4
ffffffffc02000ce:	00000517          	auipc	a0,0x0
ffffffffc02000d2:	fb650513          	addi	a0,a0,-74 # ffffffffc0200084 <cputch>
ffffffffc02000d6:	869a                	mv	a3,t1
cprintf(const char *fmt, ...) {
ffffffffc02000d8:	ec06                	sd	ra,24(sp)
ffffffffc02000da:	e0ba                	sd	a4,64(sp)
ffffffffc02000dc:	e4be                	sd	a5,72(sp)
ffffffffc02000de:	e8c2                	sd	a6,80(sp)
ffffffffc02000e0:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc02000e2:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc02000e4:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000e6:	311030ef          	jal	ra,ffffffffc0203bf6 <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc02000ea:	60e2                	ld	ra,24(sp)
ffffffffc02000ec:	4512                	lw	a0,4(sp)
ffffffffc02000ee:	6125                	addi	sp,sp,96
ffffffffc02000f0:	8082                	ret

ffffffffc02000f2 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
    cons_putc(c);
ffffffffc02000f2:	3380006f          	j	ffffffffc020042a <cons_putc>

ffffffffc02000f6 <getchar>:
    return cnt;
}

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc02000f6:	1141                	addi	sp,sp,-16
ffffffffc02000f8:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc02000fa:	366000ef          	jal	ra,ffffffffc0200460 <cons_getc>
ffffffffc02000fe:	dd75                	beqz	a0,ffffffffc02000fa <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc0200100:	60a2                	ld	ra,8(sp)
ffffffffc0200102:	0141                	addi	sp,sp,16
ffffffffc0200104:	8082                	ret

ffffffffc0200106 <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc0200106:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc0200108:	00004517          	auipc	a0,0x4
ffffffffc020010c:	05850513          	addi	a0,a0,88 # ffffffffc0204160 <etext+0x58>
void print_kerninfo(void) {
ffffffffc0200110:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc0200112:	fadff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  entry  0x%08x (virtual)\n", kern_init);
ffffffffc0200116:	00000597          	auipc	a1,0x0
ffffffffc020011a:	f2058593          	addi	a1,a1,-224 # ffffffffc0200036 <kern_init>
ffffffffc020011e:	00004517          	auipc	a0,0x4
ffffffffc0200122:	06250513          	addi	a0,a0,98 # ffffffffc0204180 <etext+0x78>
ffffffffc0200126:	f99ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  etext  0x%08x (virtual)\n", etext);
ffffffffc020012a:	00004597          	auipc	a1,0x4
ffffffffc020012e:	fde58593          	addi	a1,a1,-34 # ffffffffc0204108 <etext>
ffffffffc0200132:	00004517          	auipc	a0,0x4
ffffffffc0200136:	06e50513          	addi	a0,a0,110 # ffffffffc02041a0 <etext+0x98>
ffffffffc020013a:	f85ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  edata  0x%08x (virtual)\n", edata);
ffffffffc020013e:	00009597          	auipc	a1,0x9
ffffffffc0200142:	f0258593          	addi	a1,a1,-254 # ffffffffc0209040 <edata>
ffffffffc0200146:	00004517          	auipc	a0,0x4
ffffffffc020014a:	07a50513          	addi	a0,a0,122 # ffffffffc02041c0 <etext+0xb8>
ffffffffc020014e:	f71ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  end    0x%08x (virtual)\n", end);
ffffffffc0200152:	00010597          	auipc	a1,0x10
ffffffffc0200156:	44e58593          	addi	a1,a1,1102 # ffffffffc02105a0 <end>
ffffffffc020015a:	00004517          	auipc	a0,0x4
ffffffffc020015e:	08650513          	addi	a0,a0,134 # ffffffffc02041e0 <etext+0xd8>
ffffffffc0200162:	f5dff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc0200166:	00011597          	auipc	a1,0x11
ffffffffc020016a:	83958593          	addi	a1,a1,-1991 # ffffffffc021099f <end+0x3ff>
ffffffffc020016e:	00000797          	auipc	a5,0x0
ffffffffc0200172:	ec878793          	addi	a5,a5,-312 # ffffffffc0200036 <kern_init>
ffffffffc0200176:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc020017a:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc020017e:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200180:	3ff5f593          	andi	a1,a1,1023
ffffffffc0200184:	95be                	add	a1,a1,a5
ffffffffc0200186:	85a9                	srai	a1,a1,0xa
ffffffffc0200188:	00004517          	auipc	a0,0x4
ffffffffc020018c:	07850513          	addi	a0,a0,120 # ffffffffc0204200 <etext+0xf8>
}
ffffffffc0200190:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200192:	f2dff06f          	j	ffffffffc02000be <cprintf>

ffffffffc0200196 <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc0200196:	1141                	addi	sp,sp,-16

    panic("Not Implemented!");
ffffffffc0200198:	00004617          	auipc	a2,0x4
ffffffffc020019c:	f9860613          	addi	a2,a2,-104 # ffffffffc0204130 <etext+0x28>
ffffffffc02001a0:	04e00593          	li	a1,78
ffffffffc02001a4:	00004517          	auipc	a0,0x4
ffffffffc02001a8:	fa450513          	addi	a0,a0,-92 # ffffffffc0204148 <etext+0x40>
void print_stackframe(void) {
ffffffffc02001ac:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc02001ae:	1c6000ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc02001b2 <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02001b2:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02001b4:	00004617          	auipc	a2,0x4
ffffffffc02001b8:	15460613          	addi	a2,a2,340 # ffffffffc0204308 <commands+0xd8>
ffffffffc02001bc:	00004597          	auipc	a1,0x4
ffffffffc02001c0:	16c58593          	addi	a1,a1,364 # ffffffffc0204328 <commands+0xf8>
ffffffffc02001c4:	00004517          	auipc	a0,0x4
ffffffffc02001c8:	16c50513          	addi	a0,a0,364 # ffffffffc0204330 <commands+0x100>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02001cc:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02001ce:	ef1ff0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc02001d2:	00004617          	auipc	a2,0x4
ffffffffc02001d6:	16e60613          	addi	a2,a2,366 # ffffffffc0204340 <commands+0x110>
ffffffffc02001da:	00004597          	auipc	a1,0x4
ffffffffc02001de:	18e58593          	addi	a1,a1,398 # ffffffffc0204368 <commands+0x138>
ffffffffc02001e2:	00004517          	auipc	a0,0x4
ffffffffc02001e6:	14e50513          	addi	a0,a0,334 # ffffffffc0204330 <commands+0x100>
ffffffffc02001ea:	ed5ff0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc02001ee:	00004617          	auipc	a2,0x4
ffffffffc02001f2:	18a60613          	addi	a2,a2,394 # ffffffffc0204378 <commands+0x148>
ffffffffc02001f6:	00004597          	auipc	a1,0x4
ffffffffc02001fa:	1a258593          	addi	a1,a1,418 # ffffffffc0204398 <commands+0x168>
ffffffffc02001fe:	00004517          	auipc	a0,0x4
ffffffffc0200202:	13250513          	addi	a0,a0,306 # ffffffffc0204330 <commands+0x100>
ffffffffc0200206:	eb9ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    }
    return 0;
}
ffffffffc020020a:	60a2                	ld	ra,8(sp)
ffffffffc020020c:	4501                	li	a0,0
ffffffffc020020e:	0141                	addi	sp,sp,16
ffffffffc0200210:	8082                	ret

ffffffffc0200212 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200212:	1141                	addi	sp,sp,-16
ffffffffc0200214:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc0200216:	ef1ff0ef          	jal	ra,ffffffffc0200106 <print_kerninfo>
    return 0;
}
ffffffffc020021a:	60a2                	ld	ra,8(sp)
ffffffffc020021c:	4501                	li	a0,0
ffffffffc020021e:	0141                	addi	sp,sp,16
ffffffffc0200220:	8082                	ret

ffffffffc0200222 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200222:	1141                	addi	sp,sp,-16
ffffffffc0200224:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc0200226:	f71ff0ef          	jal	ra,ffffffffc0200196 <print_stackframe>
    return 0;
}
ffffffffc020022a:	60a2                	ld	ra,8(sp)
ffffffffc020022c:	4501                	li	a0,0
ffffffffc020022e:	0141                	addi	sp,sp,16
ffffffffc0200230:	8082                	ret

ffffffffc0200232 <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc0200232:	7115                	addi	sp,sp,-224
ffffffffc0200234:	e962                	sd	s8,144(sp)
ffffffffc0200236:	8c2a                	mv	s8,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200238:	00004517          	auipc	a0,0x4
ffffffffc020023c:	04050513          	addi	a0,a0,64 # ffffffffc0204278 <commands+0x48>
kmonitor(struct trapframe *tf) {
ffffffffc0200240:	ed86                	sd	ra,216(sp)
ffffffffc0200242:	e9a2                	sd	s0,208(sp)
ffffffffc0200244:	e5a6                	sd	s1,200(sp)
ffffffffc0200246:	e1ca                	sd	s2,192(sp)
ffffffffc0200248:	fd4e                	sd	s3,184(sp)
ffffffffc020024a:	f952                	sd	s4,176(sp)
ffffffffc020024c:	f556                	sd	s5,168(sp)
ffffffffc020024e:	f15a                	sd	s6,160(sp)
ffffffffc0200250:	ed5e                	sd	s7,152(sp)
ffffffffc0200252:	e566                	sd	s9,136(sp)
ffffffffc0200254:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200256:	e69ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc020025a:	00004517          	auipc	a0,0x4
ffffffffc020025e:	04650513          	addi	a0,a0,70 # ffffffffc02042a0 <commands+0x70>
ffffffffc0200262:	e5dff0ef          	jal	ra,ffffffffc02000be <cprintf>
    if (tf != NULL) {
ffffffffc0200266:	000c0563          	beqz	s8,ffffffffc0200270 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc020026a:	8562                	mv	a0,s8
ffffffffc020026c:	4ce000ef          	jal	ra,ffffffffc020073a <print_trapframe>
ffffffffc0200270:	00004c97          	auipc	s9,0x4
ffffffffc0200274:	fc0c8c93          	addi	s9,s9,-64 # ffffffffc0204230 <commands>
        if ((buf = readline("")) != NULL) {
ffffffffc0200278:	00005997          	auipc	s3,0x5
ffffffffc020027c:	50098993          	addi	s3,s3,1280 # ffffffffc0205778 <default_pmm_manager+0x940>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200280:	00004917          	auipc	s2,0x4
ffffffffc0200284:	04890913          	addi	s2,s2,72 # ffffffffc02042c8 <commands+0x98>
        if (argc == MAXARGS - 1) {
ffffffffc0200288:	4a3d                	li	s4,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc020028a:	00004b17          	auipc	s6,0x4
ffffffffc020028e:	046b0b13          	addi	s6,s6,70 # ffffffffc02042d0 <commands+0xa0>
    if (argc == 0) {
ffffffffc0200292:	00004a97          	auipc	s5,0x4
ffffffffc0200296:	096a8a93          	addi	s5,s5,150 # ffffffffc0204328 <commands+0xf8>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc020029a:	4b8d                	li	s7,3
        if ((buf = readline("")) != NULL) {
ffffffffc020029c:	854e                	mv	a0,s3
ffffffffc020029e:	4e5030ef          	jal	ra,ffffffffc0203f82 <readline>
ffffffffc02002a2:	842a                	mv	s0,a0
ffffffffc02002a4:	dd65                	beqz	a0,ffffffffc020029c <kmonitor+0x6a>
ffffffffc02002a6:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc02002aa:	4481                	li	s1,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002ac:	c999                	beqz	a1,ffffffffc02002c2 <kmonitor+0x90>
ffffffffc02002ae:	854a                	mv	a0,s2
ffffffffc02002b0:	611030ef          	jal	ra,ffffffffc02040c0 <strchr>
ffffffffc02002b4:	c925                	beqz	a0,ffffffffc0200324 <kmonitor+0xf2>
            *buf ++ = '\0';
ffffffffc02002b6:	00144583          	lbu	a1,1(s0)
ffffffffc02002ba:	00040023          	sb	zero,0(s0)
ffffffffc02002be:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002c0:	f5fd                	bnez	a1,ffffffffc02002ae <kmonitor+0x7c>
    if (argc == 0) {
ffffffffc02002c2:	dce9                	beqz	s1,ffffffffc020029c <kmonitor+0x6a>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002c4:	6582                	ld	a1,0(sp)
ffffffffc02002c6:	00004d17          	auipc	s10,0x4
ffffffffc02002ca:	f6ad0d13          	addi	s10,s10,-150 # ffffffffc0204230 <commands>
    if (argc == 0) {
ffffffffc02002ce:	8556                	mv	a0,s5
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002d0:	4401                	li	s0,0
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002d2:	0d61                	addi	s10,s10,24
ffffffffc02002d4:	5c3030ef          	jal	ra,ffffffffc0204096 <strcmp>
ffffffffc02002d8:	c919                	beqz	a0,ffffffffc02002ee <kmonitor+0xbc>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002da:	2405                	addiw	s0,s0,1
ffffffffc02002dc:	09740463          	beq	s0,s7,ffffffffc0200364 <kmonitor+0x132>
ffffffffc02002e0:	000d3503          	ld	a0,0(s10)
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002e4:	6582                	ld	a1,0(sp)
ffffffffc02002e6:	0d61                	addi	s10,s10,24
ffffffffc02002e8:	5af030ef          	jal	ra,ffffffffc0204096 <strcmp>
ffffffffc02002ec:	f57d                	bnez	a0,ffffffffc02002da <kmonitor+0xa8>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc02002ee:	00141793          	slli	a5,s0,0x1
ffffffffc02002f2:	97a2                	add	a5,a5,s0
ffffffffc02002f4:	078e                	slli	a5,a5,0x3
ffffffffc02002f6:	97e6                	add	a5,a5,s9
ffffffffc02002f8:	6b9c                	ld	a5,16(a5)
ffffffffc02002fa:	8662                	mv	a2,s8
ffffffffc02002fc:	002c                	addi	a1,sp,8
ffffffffc02002fe:	fff4851b          	addiw	a0,s1,-1
ffffffffc0200302:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc0200304:	f8055ce3          	bgez	a0,ffffffffc020029c <kmonitor+0x6a>
}
ffffffffc0200308:	60ee                	ld	ra,216(sp)
ffffffffc020030a:	644e                	ld	s0,208(sp)
ffffffffc020030c:	64ae                	ld	s1,200(sp)
ffffffffc020030e:	690e                	ld	s2,192(sp)
ffffffffc0200310:	79ea                	ld	s3,184(sp)
ffffffffc0200312:	7a4a                	ld	s4,176(sp)
ffffffffc0200314:	7aaa                	ld	s5,168(sp)
ffffffffc0200316:	7b0a                	ld	s6,160(sp)
ffffffffc0200318:	6bea                	ld	s7,152(sp)
ffffffffc020031a:	6c4a                	ld	s8,144(sp)
ffffffffc020031c:	6caa                	ld	s9,136(sp)
ffffffffc020031e:	6d0a                	ld	s10,128(sp)
ffffffffc0200320:	612d                	addi	sp,sp,224
ffffffffc0200322:	8082                	ret
        if (*buf == '\0') {
ffffffffc0200324:	00044783          	lbu	a5,0(s0)
ffffffffc0200328:	dfc9                	beqz	a5,ffffffffc02002c2 <kmonitor+0x90>
        if (argc == MAXARGS - 1) {
ffffffffc020032a:	03448863          	beq	s1,s4,ffffffffc020035a <kmonitor+0x128>
        argv[argc ++] = buf;
ffffffffc020032e:	00349793          	slli	a5,s1,0x3
ffffffffc0200332:	0118                	addi	a4,sp,128
ffffffffc0200334:	97ba                	add	a5,a5,a4
ffffffffc0200336:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc020033a:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc020033e:	2485                	addiw	s1,s1,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200340:	e591                	bnez	a1,ffffffffc020034c <kmonitor+0x11a>
ffffffffc0200342:	b749                	j	ffffffffc02002c4 <kmonitor+0x92>
            buf ++;
ffffffffc0200344:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200346:	00044583          	lbu	a1,0(s0)
ffffffffc020034a:	ddad                	beqz	a1,ffffffffc02002c4 <kmonitor+0x92>
ffffffffc020034c:	854a                	mv	a0,s2
ffffffffc020034e:	573030ef          	jal	ra,ffffffffc02040c0 <strchr>
ffffffffc0200352:	d96d                	beqz	a0,ffffffffc0200344 <kmonitor+0x112>
ffffffffc0200354:	00044583          	lbu	a1,0(s0)
ffffffffc0200358:	bf91                	j	ffffffffc02002ac <kmonitor+0x7a>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc020035a:	45c1                	li	a1,16
ffffffffc020035c:	855a                	mv	a0,s6
ffffffffc020035e:	d61ff0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc0200362:	b7f1                	j	ffffffffc020032e <kmonitor+0xfc>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc0200364:	6582                	ld	a1,0(sp)
ffffffffc0200366:	00004517          	auipc	a0,0x4
ffffffffc020036a:	f8a50513          	addi	a0,a0,-118 # ffffffffc02042f0 <commands+0xc0>
ffffffffc020036e:	d51ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    return 0;
ffffffffc0200372:	b72d                	j	ffffffffc020029c <kmonitor+0x6a>

ffffffffc0200374 <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc0200374:	00010317          	auipc	t1,0x10
ffffffffc0200378:	0cc30313          	addi	t1,t1,204 # ffffffffc0210440 <is_panic>
ffffffffc020037c:	00032303          	lw	t1,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc0200380:	715d                	addi	sp,sp,-80
ffffffffc0200382:	ec06                	sd	ra,24(sp)
ffffffffc0200384:	e822                	sd	s0,16(sp)
ffffffffc0200386:	f436                	sd	a3,40(sp)
ffffffffc0200388:	f83a                	sd	a4,48(sp)
ffffffffc020038a:	fc3e                	sd	a5,56(sp)
ffffffffc020038c:	e0c2                	sd	a6,64(sp)
ffffffffc020038e:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc0200390:	02031c63          	bnez	t1,ffffffffc02003c8 <__panic+0x54>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc0200394:	4785                	li	a5,1
ffffffffc0200396:	8432                	mv	s0,a2
ffffffffc0200398:	00010717          	auipc	a4,0x10
ffffffffc020039c:	0af72423          	sw	a5,168(a4) # ffffffffc0210440 <is_panic>

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003a0:	862e                	mv	a2,a1
    va_start(ap, fmt);
ffffffffc02003a2:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003a4:	85aa                	mv	a1,a0
ffffffffc02003a6:	00004517          	auipc	a0,0x4
ffffffffc02003aa:	00250513          	addi	a0,a0,2 # ffffffffc02043a8 <commands+0x178>
    va_start(ap, fmt);
ffffffffc02003ae:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003b0:	d0fff0ef          	jal	ra,ffffffffc02000be <cprintf>
    vcprintf(fmt, ap);
ffffffffc02003b4:	65a2                	ld	a1,8(sp)
ffffffffc02003b6:	8522                	mv	a0,s0
ffffffffc02003b8:	ce7ff0ef          	jal	ra,ffffffffc020009e <vcprintf>
    cprintf("\n");
ffffffffc02003bc:	00005517          	auipc	a0,0x5
ffffffffc02003c0:	f6450513          	addi	a0,a0,-156 # ffffffffc0205320 <default_pmm_manager+0x4e8>
ffffffffc02003c4:	cfbff0ef          	jal	ra,ffffffffc02000be <cprintf>
    va_end(ap);

panic_dead:
    intr_disable();
ffffffffc02003c8:	10e000ef          	jal	ra,ffffffffc02004d6 <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc02003cc:	4501                	li	a0,0
ffffffffc02003ce:	e65ff0ef          	jal	ra,ffffffffc0200232 <kmonitor>
ffffffffc02003d2:	bfed                	j	ffffffffc02003cc <__panic+0x58>

ffffffffc02003d4 <clock_init>:
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    // divided by 500 when using Spike(2MHz)
    // divided by 100 when using QEMU(10MHz)
    timebase = 1e7 / 100;
ffffffffc02003d4:	67e1                	lui	a5,0x18
ffffffffc02003d6:	6a078793          	addi	a5,a5,1696 # 186a0 <BASE_ADDRESS-0xffffffffc01e7960>
ffffffffc02003da:	00010717          	auipc	a4,0x10
ffffffffc02003de:	06f73723          	sd	a5,110(a4) # ffffffffc0210448 <timebase>
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc02003e2:	c0102573          	rdtime	a0
static inline void sbi_set_timer(uint64_t stime_value)
{
#if __riscv_xlen == 32
	SBI_CALL_2(SBI_SET_TIMER, stime_value, stime_value >> 32);
#else
	SBI_CALL_1(SBI_SET_TIMER, stime_value);
ffffffffc02003e6:	4581                	li	a1,0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc02003e8:	953e                	add	a0,a0,a5
ffffffffc02003ea:	4601                	li	a2,0
ffffffffc02003ec:	4881                	li	a7,0
ffffffffc02003ee:	00000073          	ecall
    set_csr(sie, MIP_STIP);
ffffffffc02003f2:	02000793          	li	a5,32
ffffffffc02003f6:	1047a7f3          	csrrs	a5,sie,a5
    cprintf("++ setup timer interrupts\n");
ffffffffc02003fa:	00004517          	auipc	a0,0x4
ffffffffc02003fe:	fce50513          	addi	a0,a0,-50 # ffffffffc02043c8 <commands+0x198>
    ticks = 0;
ffffffffc0200402:	00010797          	auipc	a5,0x10
ffffffffc0200406:	0607bb23          	sd	zero,118(a5) # ffffffffc0210478 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc020040a:	cb5ff06f          	j	ffffffffc02000be <cprintf>

ffffffffc020040e <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc020040e:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200412:	00010797          	auipc	a5,0x10
ffffffffc0200416:	03678793          	addi	a5,a5,54 # ffffffffc0210448 <timebase>
ffffffffc020041a:	639c                	ld	a5,0(a5)
ffffffffc020041c:	4581                	li	a1,0
ffffffffc020041e:	4601                	li	a2,0
ffffffffc0200420:	953e                	add	a0,a0,a5
ffffffffc0200422:	4881                	li	a7,0
ffffffffc0200424:	00000073          	ecall
ffffffffc0200428:	8082                	ret

ffffffffc020042a <cons_putc>:
#include <intr.h>
#include <mmu.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020042a:	100027f3          	csrr	a5,sstatus
ffffffffc020042e:	8b89                	andi	a5,a5,2
ffffffffc0200430:	0ff57513          	andi	a0,a0,255
ffffffffc0200434:	e799                	bnez	a5,ffffffffc0200442 <cons_putc+0x18>
	SBI_CALL_1(SBI_CONSOLE_PUTCHAR, ch);
ffffffffc0200436:	4581                	li	a1,0
ffffffffc0200438:	4601                	li	a2,0
ffffffffc020043a:	4885                	li	a7,1
ffffffffc020043c:	00000073          	ecall
    }
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
ffffffffc0200440:	8082                	ret

/* cons_init - initializes the console devices */
void cons_init(void) {}

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) {
ffffffffc0200442:	1101                	addi	sp,sp,-32
ffffffffc0200444:	ec06                	sd	ra,24(sp)
ffffffffc0200446:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0200448:	08e000ef          	jal	ra,ffffffffc02004d6 <intr_disable>
ffffffffc020044c:	6522                	ld	a0,8(sp)
ffffffffc020044e:	4581                	li	a1,0
ffffffffc0200450:	4601                	li	a2,0
ffffffffc0200452:	4885                	li	a7,1
ffffffffc0200454:	00000073          	ecall
    local_intr_save(intr_flag);
    {
        sbi_console_putchar((unsigned char)c);
    }
    local_intr_restore(intr_flag);
}
ffffffffc0200458:	60e2                	ld	ra,24(sp)
ffffffffc020045a:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc020045c:	0740006f          	j	ffffffffc02004d0 <intr_enable>

ffffffffc0200460 <cons_getc>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200460:	100027f3          	csrr	a5,sstatus
ffffffffc0200464:	8b89                	andi	a5,a5,2
ffffffffc0200466:	eb89                	bnez	a5,ffffffffc0200478 <cons_getc+0x18>
	return SBI_CALL_0(SBI_CONSOLE_GETCHAR);
ffffffffc0200468:	4501                	li	a0,0
ffffffffc020046a:	4581                	li	a1,0
ffffffffc020046c:	4601                	li	a2,0
ffffffffc020046e:	4889                	li	a7,2
ffffffffc0200470:	00000073          	ecall
ffffffffc0200474:	2501                	sext.w	a0,a0
    {
        c = sbi_console_getchar();
    }
    local_intr_restore(intr_flag);
    return c;
}
ffffffffc0200476:	8082                	ret
int cons_getc(void) {
ffffffffc0200478:	1101                	addi	sp,sp,-32
ffffffffc020047a:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc020047c:	05a000ef          	jal	ra,ffffffffc02004d6 <intr_disable>
ffffffffc0200480:	4501                	li	a0,0
ffffffffc0200482:	4581                	li	a1,0
ffffffffc0200484:	4601                	li	a2,0
ffffffffc0200486:	4889                	li	a7,2
ffffffffc0200488:	00000073          	ecall
ffffffffc020048c:	2501                	sext.w	a0,a0
ffffffffc020048e:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc0200490:	040000ef          	jal	ra,ffffffffc02004d0 <intr_enable>
}
ffffffffc0200494:	60e2                	ld	ra,24(sp)
ffffffffc0200496:	6522                	ld	a0,8(sp)
ffffffffc0200498:	6105                	addi	sp,sp,32
ffffffffc020049a:	8082                	ret

ffffffffc020049c <ide_init>:
#include <stdio.h>
#include <string.h>
#include <trap.h>
#include <riscv.h>

void ide_init(void) {}
ffffffffc020049c:	8082                	ret

ffffffffc020049e <ide_device_valid>:

#define MAX_IDE 2
#define MAX_DISK_NSECS 56
static char ide[MAX_DISK_NSECS * SECTSIZE];

bool ide_device_valid(unsigned short ideno) { return ideno < MAX_IDE; }
ffffffffc020049e:	00253513          	sltiu	a0,a0,2
ffffffffc02004a2:	8082                	ret

ffffffffc02004a4 <ide_device_size>:

size_t ide_device_size(unsigned short ideno) { return MAX_DISK_NSECS; }
ffffffffc02004a4:	03800513          	li	a0,56
ffffffffc02004a8:	8082                	ret

ffffffffc02004aa <ide_write_secs>:
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
    return 0;
}

int ide_write_secs(unsigned short ideno, uint32_t secno, const void *src,
                   size_t nsecs) {
ffffffffc02004aa:	8732                	mv	a4,a2
    int iobase = secno * SECTSIZE;
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc02004ac:	0095979b          	slliw	a5,a1,0x9
ffffffffc02004b0:	00009517          	auipc	a0,0x9
ffffffffc02004b4:	b9050513          	addi	a0,a0,-1136 # ffffffffc0209040 <edata>
                   size_t nsecs) {
ffffffffc02004b8:	1141                	addi	sp,sp,-16
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc02004ba:	00969613          	slli	a2,a3,0x9
ffffffffc02004be:	85ba                	mv	a1,a4
ffffffffc02004c0:	953e                	add	a0,a0,a5
                   size_t nsecs) {
ffffffffc02004c2:	e406                	sd	ra,8(sp)
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc02004c4:	42d030ef          	jal	ra,ffffffffc02040f0 <memcpy>
    return 0;
}
ffffffffc02004c8:	60a2                	ld	ra,8(sp)
ffffffffc02004ca:	4501                	li	a0,0
ffffffffc02004cc:	0141                	addi	sp,sp,16
ffffffffc02004ce:	8082                	ret

ffffffffc02004d0 <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc02004d0:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc02004d4:	8082                	ret

ffffffffc02004d6 <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc02004d6:	100177f3          	csrrci	a5,sstatus,2
ffffffffc02004da:	8082                	ret

ffffffffc02004dc <pgfault_handler>:
    set_csr(sstatus, SSTATUS_SUM);
}

/* trap_in_kernel - test if trap happened in kernel */
bool trap_in_kernel(struct trapframe *tf) {
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02004dc:	10053783          	ld	a5,256(a0)
    cprintf("page fault at 0x%08x: %c/%c\n", tf->badvaddr,
            trap_in_kernel(tf) ? 'K' : 'U',
            tf->cause == CAUSE_STORE_PAGE_FAULT ? 'W' : 'R');
}

static int pgfault_handler(struct trapframe *tf) {
ffffffffc02004e0:	1141                	addi	sp,sp,-16
ffffffffc02004e2:	e022                	sd	s0,0(sp)
ffffffffc02004e4:	e406                	sd	ra,8(sp)
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02004e6:	1007f793          	andi	a5,a5,256
static int pgfault_handler(struct trapframe *tf) {
ffffffffc02004ea:	842a                	mv	s0,a0
    cprintf("page fault at 0x%08x: %c/%c\n", tf->badvaddr,
ffffffffc02004ec:	11053583          	ld	a1,272(a0)
ffffffffc02004f0:	05500613          	li	a2,85
ffffffffc02004f4:	c399                	beqz	a5,ffffffffc02004fa <pgfault_handler+0x1e>
ffffffffc02004f6:	04b00613          	li	a2,75
ffffffffc02004fa:	11843703          	ld	a4,280(s0)
ffffffffc02004fe:	47bd                	li	a5,15
ffffffffc0200500:	05700693          	li	a3,87
ffffffffc0200504:	00f70463          	beq	a4,a5,ffffffffc020050c <pgfault_handler+0x30>
ffffffffc0200508:	05200693          	li	a3,82
ffffffffc020050c:	00004517          	auipc	a0,0x4
ffffffffc0200510:	1b450513          	addi	a0,a0,436 # ffffffffc02046c0 <commands+0x490>
ffffffffc0200514:	babff0ef          	jal	ra,ffffffffc02000be <cprintf>
    extern struct mm_struct *check_mm_struct;
    print_pgfault(tf);
    if (check_mm_struct != NULL) {
ffffffffc0200518:	00010797          	auipc	a5,0x10
ffffffffc020051c:	08078793          	addi	a5,a5,128 # ffffffffc0210598 <check_mm_struct>
ffffffffc0200520:	6388                	ld	a0,0(a5)
ffffffffc0200522:	c911                	beqz	a0,ffffffffc0200536 <pgfault_handler+0x5a>
        return do_pgfault(check_mm_struct, tf->cause, tf->badvaddr);
ffffffffc0200524:	11043603          	ld	a2,272(s0)
ffffffffc0200528:	11843583          	ld	a1,280(s0)
    }
    panic("unhandled page fault.\n");
}
ffffffffc020052c:	6402                	ld	s0,0(sp)
ffffffffc020052e:	60a2                	ld	ra,8(sp)
ffffffffc0200530:	0141                	addi	sp,sp,16
        return do_pgfault(check_mm_struct, tf->cause, tf->badvaddr);
ffffffffc0200532:	4ca0306f          	j	ffffffffc02039fc <do_pgfault>
    panic("unhandled page fault.\n");
ffffffffc0200536:	00004617          	auipc	a2,0x4
ffffffffc020053a:	1aa60613          	addi	a2,a2,426 # ffffffffc02046e0 <commands+0x4b0>
ffffffffc020053e:	07800593          	li	a1,120
ffffffffc0200542:	00004517          	auipc	a0,0x4
ffffffffc0200546:	1b650513          	addi	a0,a0,438 # ffffffffc02046f8 <commands+0x4c8>
ffffffffc020054a:	e2bff0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc020054e <idt_init>:
    write_csr(sscratch, 0);
ffffffffc020054e:	14005073          	csrwi	sscratch,0
    write_csr(stvec, &__alltraps);
ffffffffc0200552:	00000797          	auipc	a5,0x0
ffffffffc0200556:	4ce78793          	addi	a5,a5,1230 # ffffffffc0200a20 <__alltraps>
ffffffffc020055a:	10579073          	csrw	stvec,a5
    set_csr(sstatus, SSTATUS_SIE);
ffffffffc020055e:	100167f3          	csrrsi	a5,sstatus,2
    set_csr(sstatus, SSTATUS_SUM);
ffffffffc0200562:	000407b7          	lui	a5,0x40
ffffffffc0200566:	1007a7f3          	csrrs	a5,sstatus,a5
}
ffffffffc020056a:	8082                	ret

ffffffffc020056c <print_regs>:
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020056c:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
ffffffffc020056e:	1141                	addi	sp,sp,-16
ffffffffc0200570:	e022                	sd	s0,0(sp)
ffffffffc0200572:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200574:	00004517          	auipc	a0,0x4
ffffffffc0200578:	19c50513          	addi	a0,a0,412 # ffffffffc0204710 <commands+0x4e0>
void print_regs(struct pushregs *gpr) {
ffffffffc020057c:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020057e:	b41ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc0200582:	640c                	ld	a1,8(s0)
ffffffffc0200584:	00004517          	auipc	a0,0x4
ffffffffc0200588:	1a450513          	addi	a0,a0,420 # ffffffffc0204728 <commands+0x4f8>
ffffffffc020058c:	b33ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc0200590:	680c                	ld	a1,16(s0)
ffffffffc0200592:	00004517          	auipc	a0,0x4
ffffffffc0200596:	1ae50513          	addi	a0,a0,430 # ffffffffc0204740 <commands+0x510>
ffffffffc020059a:	b25ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc020059e:	6c0c                	ld	a1,24(s0)
ffffffffc02005a0:	00004517          	auipc	a0,0x4
ffffffffc02005a4:	1b850513          	addi	a0,a0,440 # ffffffffc0204758 <commands+0x528>
ffffffffc02005a8:	b17ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02005ac:	700c                	ld	a1,32(s0)
ffffffffc02005ae:	00004517          	auipc	a0,0x4
ffffffffc02005b2:	1c250513          	addi	a0,a0,450 # ffffffffc0204770 <commands+0x540>
ffffffffc02005b6:	b09ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02005ba:	740c                	ld	a1,40(s0)
ffffffffc02005bc:	00004517          	auipc	a0,0x4
ffffffffc02005c0:	1cc50513          	addi	a0,a0,460 # ffffffffc0204788 <commands+0x558>
ffffffffc02005c4:	afbff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02005c8:	780c                	ld	a1,48(s0)
ffffffffc02005ca:	00004517          	auipc	a0,0x4
ffffffffc02005ce:	1d650513          	addi	a0,a0,470 # ffffffffc02047a0 <commands+0x570>
ffffffffc02005d2:	aedff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02005d6:	7c0c                	ld	a1,56(s0)
ffffffffc02005d8:	00004517          	auipc	a0,0x4
ffffffffc02005dc:	1e050513          	addi	a0,a0,480 # ffffffffc02047b8 <commands+0x588>
ffffffffc02005e0:	adfff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02005e4:	602c                	ld	a1,64(s0)
ffffffffc02005e6:	00004517          	auipc	a0,0x4
ffffffffc02005ea:	1ea50513          	addi	a0,a0,490 # ffffffffc02047d0 <commands+0x5a0>
ffffffffc02005ee:	ad1ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc02005f2:	642c                	ld	a1,72(s0)
ffffffffc02005f4:	00004517          	auipc	a0,0x4
ffffffffc02005f8:	1f450513          	addi	a0,a0,500 # ffffffffc02047e8 <commands+0x5b8>
ffffffffc02005fc:	ac3ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc0200600:	682c                	ld	a1,80(s0)
ffffffffc0200602:	00004517          	auipc	a0,0x4
ffffffffc0200606:	1fe50513          	addi	a0,a0,510 # ffffffffc0204800 <commands+0x5d0>
ffffffffc020060a:	ab5ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc020060e:	6c2c                	ld	a1,88(s0)
ffffffffc0200610:	00004517          	auipc	a0,0x4
ffffffffc0200614:	20850513          	addi	a0,a0,520 # ffffffffc0204818 <commands+0x5e8>
ffffffffc0200618:	aa7ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc020061c:	702c                	ld	a1,96(s0)
ffffffffc020061e:	00004517          	auipc	a0,0x4
ffffffffc0200622:	21250513          	addi	a0,a0,530 # ffffffffc0204830 <commands+0x600>
ffffffffc0200626:	a99ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc020062a:	742c                	ld	a1,104(s0)
ffffffffc020062c:	00004517          	auipc	a0,0x4
ffffffffc0200630:	21c50513          	addi	a0,a0,540 # ffffffffc0204848 <commands+0x618>
ffffffffc0200634:	a8bff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200638:	782c                	ld	a1,112(s0)
ffffffffc020063a:	00004517          	auipc	a0,0x4
ffffffffc020063e:	22650513          	addi	a0,a0,550 # ffffffffc0204860 <commands+0x630>
ffffffffc0200642:	a7dff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200646:	7c2c                	ld	a1,120(s0)
ffffffffc0200648:	00004517          	auipc	a0,0x4
ffffffffc020064c:	23050513          	addi	a0,a0,560 # ffffffffc0204878 <commands+0x648>
ffffffffc0200650:	a6fff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc0200654:	604c                	ld	a1,128(s0)
ffffffffc0200656:	00004517          	auipc	a0,0x4
ffffffffc020065a:	23a50513          	addi	a0,a0,570 # ffffffffc0204890 <commands+0x660>
ffffffffc020065e:	a61ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc0200662:	644c                	ld	a1,136(s0)
ffffffffc0200664:	00004517          	auipc	a0,0x4
ffffffffc0200668:	24450513          	addi	a0,a0,580 # ffffffffc02048a8 <commands+0x678>
ffffffffc020066c:	a53ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200670:	684c                	ld	a1,144(s0)
ffffffffc0200672:	00004517          	auipc	a0,0x4
ffffffffc0200676:	24e50513          	addi	a0,a0,590 # ffffffffc02048c0 <commands+0x690>
ffffffffc020067a:	a45ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc020067e:	6c4c                	ld	a1,152(s0)
ffffffffc0200680:	00004517          	auipc	a0,0x4
ffffffffc0200684:	25850513          	addi	a0,a0,600 # ffffffffc02048d8 <commands+0x6a8>
ffffffffc0200688:	a37ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc020068c:	704c                	ld	a1,160(s0)
ffffffffc020068e:	00004517          	auipc	a0,0x4
ffffffffc0200692:	26250513          	addi	a0,a0,610 # ffffffffc02048f0 <commands+0x6c0>
ffffffffc0200696:	a29ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc020069a:	744c                	ld	a1,168(s0)
ffffffffc020069c:	00004517          	auipc	a0,0x4
ffffffffc02006a0:	26c50513          	addi	a0,a0,620 # ffffffffc0204908 <commands+0x6d8>
ffffffffc02006a4:	a1bff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02006a8:	784c                	ld	a1,176(s0)
ffffffffc02006aa:	00004517          	auipc	a0,0x4
ffffffffc02006ae:	27650513          	addi	a0,a0,630 # ffffffffc0204920 <commands+0x6f0>
ffffffffc02006b2:	a0dff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02006b6:	7c4c                	ld	a1,184(s0)
ffffffffc02006b8:	00004517          	auipc	a0,0x4
ffffffffc02006bc:	28050513          	addi	a0,a0,640 # ffffffffc0204938 <commands+0x708>
ffffffffc02006c0:	9ffff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02006c4:	606c                	ld	a1,192(s0)
ffffffffc02006c6:	00004517          	auipc	a0,0x4
ffffffffc02006ca:	28a50513          	addi	a0,a0,650 # ffffffffc0204950 <commands+0x720>
ffffffffc02006ce:	9f1ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02006d2:	646c                	ld	a1,200(s0)
ffffffffc02006d4:	00004517          	auipc	a0,0x4
ffffffffc02006d8:	29450513          	addi	a0,a0,660 # ffffffffc0204968 <commands+0x738>
ffffffffc02006dc:	9e3ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02006e0:	686c                	ld	a1,208(s0)
ffffffffc02006e2:	00004517          	auipc	a0,0x4
ffffffffc02006e6:	29e50513          	addi	a0,a0,670 # ffffffffc0204980 <commands+0x750>
ffffffffc02006ea:	9d5ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02006ee:	6c6c                	ld	a1,216(s0)
ffffffffc02006f0:	00004517          	auipc	a0,0x4
ffffffffc02006f4:	2a850513          	addi	a0,a0,680 # ffffffffc0204998 <commands+0x768>
ffffffffc02006f8:	9c7ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc02006fc:	706c                	ld	a1,224(s0)
ffffffffc02006fe:	00004517          	auipc	a0,0x4
ffffffffc0200702:	2b250513          	addi	a0,a0,690 # ffffffffc02049b0 <commands+0x780>
ffffffffc0200706:	9b9ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc020070a:	746c                	ld	a1,232(s0)
ffffffffc020070c:	00004517          	auipc	a0,0x4
ffffffffc0200710:	2bc50513          	addi	a0,a0,700 # ffffffffc02049c8 <commands+0x798>
ffffffffc0200714:	9abff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200718:	786c                	ld	a1,240(s0)
ffffffffc020071a:	00004517          	auipc	a0,0x4
ffffffffc020071e:	2c650513          	addi	a0,a0,710 # ffffffffc02049e0 <commands+0x7b0>
ffffffffc0200722:	99dff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200726:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200728:	6402                	ld	s0,0(sp)
ffffffffc020072a:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020072c:	00004517          	auipc	a0,0x4
ffffffffc0200730:	2cc50513          	addi	a0,a0,716 # ffffffffc02049f8 <commands+0x7c8>
}
ffffffffc0200734:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200736:	989ff06f          	j	ffffffffc02000be <cprintf>

ffffffffc020073a <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
ffffffffc020073a:	1141                	addi	sp,sp,-16
ffffffffc020073c:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc020073e:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
ffffffffc0200740:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc0200742:	00004517          	auipc	a0,0x4
ffffffffc0200746:	2ce50513          	addi	a0,a0,718 # ffffffffc0204a10 <commands+0x7e0>
void print_trapframe(struct trapframe *tf) {
ffffffffc020074a:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc020074c:	973ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200750:	8522                	mv	a0,s0
ffffffffc0200752:	e1bff0ef          	jal	ra,ffffffffc020056c <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc0200756:	10043583          	ld	a1,256(s0)
ffffffffc020075a:	00004517          	auipc	a0,0x4
ffffffffc020075e:	2ce50513          	addi	a0,a0,718 # ffffffffc0204a28 <commands+0x7f8>
ffffffffc0200762:	95dff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc0200766:	10843583          	ld	a1,264(s0)
ffffffffc020076a:	00004517          	auipc	a0,0x4
ffffffffc020076e:	2d650513          	addi	a0,a0,726 # ffffffffc0204a40 <commands+0x810>
ffffffffc0200772:	94dff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc0200776:	11043583          	ld	a1,272(s0)
ffffffffc020077a:	00004517          	auipc	a0,0x4
ffffffffc020077e:	2de50513          	addi	a0,a0,734 # ffffffffc0204a58 <commands+0x828>
ffffffffc0200782:	93dff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200786:	11843583          	ld	a1,280(s0)
}
ffffffffc020078a:	6402                	ld	s0,0(sp)
ffffffffc020078c:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020078e:	00004517          	auipc	a0,0x4
ffffffffc0200792:	2e250513          	addi	a0,a0,738 # ffffffffc0204a70 <commands+0x840>
}
ffffffffc0200796:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200798:	927ff06f          	j	ffffffffc02000be <cprintf>

ffffffffc020079c <interrupt_handler>:

static volatile int in_swap_tick_event = 0;
extern struct mm_struct *check_mm_struct;

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc020079c:	11853783          	ld	a5,280(a0)
ffffffffc02007a0:	577d                	li	a4,-1
ffffffffc02007a2:	8305                	srli	a4,a4,0x1
ffffffffc02007a4:	8ff9                	and	a5,a5,a4
    switch (cause) {
ffffffffc02007a6:	472d                	li	a4,11
ffffffffc02007a8:	08f76f63          	bltu	a4,a5,ffffffffc0200846 <interrupt_handler+0xaa>
ffffffffc02007ac:	00004717          	auipc	a4,0x4
ffffffffc02007b0:	c3870713          	addi	a4,a4,-968 # ffffffffc02043e4 <commands+0x1b4>
ffffffffc02007b4:	078a                	slli	a5,a5,0x2
ffffffffc02007b6:	97ba                	add	a5,a5,a4
ffffffffc02007b8:	439c                	lw	a5,0(a5)
ffffffffc02007ba:	97ba                	add	a5,a5,a4
ffffffffc02007bc:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc02007be:	00004517          	auipc	a0,0x4
ffffffffc02007c2:	eb250513          	addi	a0,a0,-334 # ffffffffc0204670 <commands+0x440>
ffffffffc02007c6:	8f9ff06f          	j	ffffffffc02000be <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02007ca:	00004517          	auipc	a0,0x4
ffffffffc02007ce:	e8650513          	addi	a0,a0,-378 # ffffffffc0204650 <commands+0x420>
ffffffffc02007d2:	8edff06f          	j	ffffffffc02000be <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02007d6:	00004517          	auipc	a0,0x4
ffffffffc02007da:	e3a50513          	addi	a0,a0,-454 # ffffffffc0204610 <commands+0x3e0>
ffffffffc02007de:	8e1ff06f          	j	ffffffffc02000be <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc02007e2:	00004517          	auipc	a0,0x4
ffffffffc02007e6:	e4e50513          	addi	a0,a0,-434 # ffffffffc0204630 <commands+0x400>
ffffffffc02007ea:	8d5ff06f          	j	ffffffffc02000be <cprintf>
            break;
        case IRQ_U_EXT:
            cprintf("User software interrupt\n");
            break;
        case IRQ_S_EXT:
            cprintf("Supervisor external interrupt\n");
ffffffffc02007ee:	00004517          	auipc	a0,0x4
ffffffffc02007f2:	eb250513          	addi	a0,a0,-334 # ffffffffc02046a0 <commands+0x470>
ffffffffc02007f6:	8c9ff06f          	j	ffffffffc02000be <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc02007fa:	1141                	addi	sp,sp,-16
ffffffffc02007fc:	e022                	sd	s0,0(sp)
ffffffffc02007fe:	e406                	sd	ra,8(sp)
            clock_set_next_event();
ffffffffc0200800:	c0fff0ef          	jal	ra,ffffffffc020040e <clock_set_next_event>
	        ticks++;
ffffffffc0200804:	00010717          	auipc	a4,0x10
ffffffffc0200808:	c7470713          	addi	a4,a4,-908 # ffffffffc0210478 <ticks>
ffffffffc020080c:	631c                	ld	a5,0(a4)
	        if(ticks==100){
ffffffffc020080e:	06400693          	li	a3,100
ffffffffc0200812:	00010417          	auipc	s0,0x10
ffffffffc0200816:	c3e40413          	addi	s0,s0,-962 # ffffffffc0210450 <num>
	        ticks++;
ffffffffc020081a:	0785                	addi	a5,a5,1
ffffffffc020081c:	00010617          	auipc	a2,0x10
ffffffffc0200820:	c4f63e23          	sd	a5,-932(a2) # ffffffffc0210478 <ticks>
	        if(ticks==100){
ffffffffc0200824:	631c                	ld	a5,0(a4)
ffffffffc0200826:	02d78263          	beq	a5,a3,ffffffffc020084a <interrupt_handler+0xae>
	        if(num==10){
ffffffffc020082a:	6018                	ld	a4,0(s0)
ffffffffc020082c:	47a9                	li	a5,10
ffffffffc020082e:	00f71863          	bne	a4,a5,ffffffffc020083e <interrupt_handler+0xa2>
#endif
}

static inline void sbi_shutdown(void)
{
	SBI_CALL_0(SBI_SHUTDOWN);
ffffffffc0200832:	4501                	li	a0,0
ffffffffc0200834:	4581                	li	a1,0
ffffffffc0200836:	4601                	li	a2,0
ffffffffc0200838:	48a1                	li	a7,8
ffffffffc020083a:	00000073          	ecall
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc020083e:	60a2                	ld	ra,8(sp)
ffffffffc0200840:	6402                	ld	s0,0(sp)
ffffffffc0200842:	0141                	addi	sp,sp,16
ffffffffc0200844:	8082                	ret
            print_trapframe(tf);
ffffffffc0200846:	ef5ff06f          	j	ffffffffc020073a <print_trapframe>
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc020084a:	06400593          	li	a1,100
ffffffffc020084e:	00004517          	auipc	a0,0x4
ffffffffc0200852:	e4250513          	addi	a0,a0,-446 # ffffffffc0204690 <commands+0x460>
ffffffffc0200856:	869ff0ef          	jal	ra,ffffffffc02000be <cprintf>
		        num++;
ffffffffc020085a:	601c                	ld	a5,0(s0)
ffffffffc020085c:	0785                	addi	a5,a5,1
ffffffffc020085e:	00010717          	auipc	a4,0x10
ffffffffc0200862:	bef73923          	sd	a5,-1038(a4) # ffffffffc0210450 <num>
		        ticks=0;
ffffffffc0200866:	00010797          	auipc	a5,0x10
ffffffffc020086a:	c007b923          	sd	zero,-1006(a5) # ffffffffc0210478 <ticks>
ffffffffc020086e:	bf75                	j	ffffffffc020082a <interrupt_handler+0x8e>

ffffffffc0200870 <exception_handler>:


void exception_handler(struct trapframe *tf) {
    int ret;
    switch (tf->cause) {
ffffffffc0200870:	11853783          	ld	a5,280(a0)
ffffffffc0200874:	473d                	li	a4,15
ffffffffc0200876:	16f76563          	bltu	a4,a5,ffffffffc02009e0 <exception_handler+0x170>
ffffffffc020087a:	00004717          	auipc	a4,0x4
ffffffffc020087e:	b9a70713          	addi	a4,a4,-1126 # ffffffffc0204414 <commands+0x1e4>
ffffffffc0200882:	078a                	slli	a5,a5,0x2
ffffffffc0200884:	97ba                	add	a5,a5,a4
ffffffffc0200886:	439c                	lw	a5,0(a5)
void exception_handler(struct trapframe *tf) {
ffffffffc0200888:	1101                	addi	sp,sp,-32
ffffffffc020088a:	e822                	sd	s0,16(sp)
ffffffffc020088c:	ec06                	sd	ra,24(sp)
ffffffffc020088e:	e426                	sd	s1,8(sp)
    switch (tf->cause) {
ffffffffc0200890:	97ba                	add	a5,a5,a4
ffffffffc0200892:	842a                	mv	s0,a0
ffffffffc0200894:	8782                	jr	a5
                print_trapframe(tf);
                panic("handle pgfault failed. %e\n", ret);
            }
            break;
        case CAUSE_STORE_PAGE_FAULT:
            cprintf("Store/AMO page fault\n");
ffffffffc0200896:	00004517          	auipc	a0,0x4
ffffffffc020089a:	d6250513          	addi	a0,a0,-670 # ffffffffc02045f8 <commands+0x3c8>
ffffffffc020089e:	821ff0ef          	jal	ra,ffffffffc02000be <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc02008a2:	8522                	mv	a0,s0
ffffffffc02008a4:	c39ff0ef          	jal	ra,ffffffffc02004dc <pgfault_handler>
ffffffffc02008a8:	84aa                	mv	s1,a0
ffffffffc02008aa:	12051d63          	bnez	a0,ffffffffc02009e4 <exception_handler+0x174>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc02008ae:	60e2                	ld	ra,24(sp)
ffffffffc02008b0:	6442                	ld	s0,16(sp)
ffffffffc02008b2:	64a2                	ld	s1,8(sp)
ffffffffc02008b4:	6105                	addi	sp,sp,32
ffffffffc02008b6:	8082                	ret
            cprintf("Instruction address misaligned\n");
ffffffffc02008b8:	00004517          	auipc	a0,0x4
ffffffffc02008bc:	ba050513          	addi	a0,a0,-1120 # ffffffffc0204458 <commands+0x228>
}
ffffffffc02008c0:	6442                	ld	s0,16(sp)
ffffffffc02008c2:	60e2                	ld	ra,24(sp)
ffffffffc02008c4:	64a2                	ld	s1,8(sp)
ffffffffc02008c6:	6105                	addi	sp,sp,32
            cprintf("Instruction access fault\n");
ffffffffc02008c8:	ff6ff06f          	j	ffffffffc02000be <cprintf>
ffffffffc02008cc:	00004517          	auipc	a0,0x4
ffffffffc02008d0:	bac50513          	addi	a0,a0,-1108 # ffffffffc0204478 <commands+0x248>
ffffffffc02008d4:	b7f5                	j	ffffffffc02008c0 <exception_handler+0x50>
            cprintf("Illegal instruction\n");
ffffffffc02008d6:	00004517          	auipc	a0,0x4
ffffffffc02008da:	bc250513          	addi	a0,a0,-1086 # ffffffffc0204498 <commands+0x268>
ffffffffc02008de:	b7cd                	j	ffffffffc02008c0 <exception_handler+0x50>
            cprintf("Breakpoint\n");
ffffffffc02008e0:	00004517          	auipc	a0,0x4
ffffffffc02008e4:	bd050513          	addi	a0,a0,-1072 # ffffffffc02044b0 <commands+0x280>
ffffffffc02008e8:	bfe1                	j	ffffffffc02008c0 <exception_handler+0x50>
            cprintf("Load address misaligned\n");
ffffffffc02008ea:	00004517          	auipc	a0,0x4
ffffffffc02008ee:	bd650513          	addi	a0,a0,-1066 # ffffffffc02044c0 <commands+0x290>
ffffffffc02008f2:	b7f9                	j	ffffffffc02008c0 <exception_handler+0x50>
            cprintf("Load access fault\n");
ffffffffc02008f4:	00004517          	auipc	a0,0x4
ffffffffc02008f8:	bec50513          	addi	a0,a0,-1044 # ffffffffc02044e0 <commands+0x2b0>
ffffffffc02008fc:	fc2ff0ef          	jal	ra,ffffffffc02000be <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200900:	8522                	mv	a0,s0
ffffffffc0200902:	bdbff0ef          	jal	ra,ffffffffc02004dc <pgfault_handler>
ffffffffc0200906:	84aa                	mv	s1,a0
ffffffffc0200908:	d15d                	beqz	a0,ffffffffc02008ae <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc020090a:	8522                	mv	a0,s0
ffffffffc020090c:	e2fff0ef          	jal	ra,ffffffffc020073a <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200910:	86a6                	mv	a3,s1
ffffffffc0200912:	00004617          	auipc	a2,0x4
ffffffffc0200916:	be660613          	addi	a2,a2,-1050 # ffffffffc02044f8 <commands+0x2c8>
ffffffffc020091a:	0d600593          	li	a1,214
ffffffffc020091e:	00004517          	auipc	a0,0x4
ffffffffc0200922:	dda50513          	addi	a0,a0,-550 # ffffffffc02046f8 <commands+0x4c8>
ffffffffc0200926:	a4fff0ef          	jal	ra,ffffffffc0200374 <__panic>
            cprintf("AMO address misaligned\n");
ffffffffc020092a:	00004517          	auipc	a0,0x4
ffffffffc020092e:	bee50513          	addi	a0,a0,-1042 # ffffffffc0204518 <commands+0x2e8>
ffffffffc0200932:	b779                	j	ffffffffc02008c0 <exception_handler+0x50>
            cprintf("Store/AMO access fault\n");
ffffffffc0200934:	00004517          	auipc	a0,0x4
ffffffffc0200938:	bfc50513          	addi	a0,a0,-1028 # ffffffffc0204530 <commands+0x300>
ffffffffc020093c:	f82ff0ef          	jal	ra,ffffffffc02000be <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200940:	8522                	mv	a0,s0
ffffffffc0200942:	b9bff0ef          	jal	ra,ffffffffc02004dc <pgfault_handler>
ffffffffc0200946:	84aa                	mv	s1,a0
ffffffffc0200948:	d13d                	beqz	a0,ffffffffc02008ae <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc020094a:	8522                	mv	a0,s0
ffffffffc020094c:	defff0ef          	jal	ra,ffffffffc020073a <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200950:	86a6                	mv	a3,s1
ffffffffc0200952:	00004617          	auipc	a2,0x4
ffffffffc0200956:	ba660613          	addi	a2,a2,-1114 # ffffffffc02044f8 <commands+0x2c8>
ffffffffc020095a:	0e000593          	li	a1,224
ffffffffc020095e:	00004517          	auipc	a0,0x4
ffffffffc0200962:	d9a50513          	addi	a0,a0,-614 # ffffffffc02046f8 <commands+0x4c8>
ffffffffc0200966:	a0fff0ef          	jal	ra,ffffffffc0200374 <__panic>
            cprintf("Environment call from U-mode\n");
ffffffffc020096a:	00004517          	auipc	a0,0x4
ffffffffc020096e:	bde50513          	addi	a0,a0,-1058 # ffffffffc0204548 <commands+0x318>
ffffffffc0200972:	b7b9                	j	ffffffffc02008c0 <exception_handler+0x50>
            cprintf("Environment call from S-mode\n");
ffffffffc0200974:	00004517          	auipc	a0,0x4
ffffffffc0200978:	bf450513          	addi	a0,a0,-1036 # ffffffffc0204568 <commands+0x338>
ffffffffc020097c:	b791                	j	ffffffffc02008c0 <exception_handler+0x50>
            cprintf("Environment call from H-mode\n");
ffffffffc020097e:	00004517          	auipc	a0,0x4
ffffffffc0200982:	c0a50513          	addi	a0,a0,-1014 # ffffffffc0204588 <commands+0x358>
ffffffffc0200986:	bf2d                	j	ffffffffc02008c0 <exception_handler+0x50>
            cprintf("Environment call from M-mode\n");
ffffffffc0200988:	00004517          	auipc	a0,0x4
ffffffffc020098c:	c2050513          	addi	a0,a0,-992 # ffffffffc02045a8 <commands+0x378>
ffffffffc0200990:	bf05                	j	ffffffffc02008c0 <exception_handler+0x50>
            cprintf("Instruction page fault\n");
ffffffffc0200992:	00004517          	auipc	a0,0x4
ffffffffc0200996:	c3650513          	addi	a0,a0,-970 # ffffffffc02045c8 <commands+0x398>
ffffffffc020099a:	b71d                	j	ffffffffc02008c0 <exception_handler+0x50>
            cprintf("Load page fault\n");
ffffffffc020099c:	00004517          	auipc	a0,0x4
ffffffffc02009a0:	c4450513          	addi	a0,a0,-956 # ffffffffc02045e0 <commands+0x3b0>
ffffffffc02009a4:	f1aff0ef          	jal	ra,ffffffffc02000be <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc02009a8:	8522                	mv	a0,s0
ffffffffc02009aa:	b33ff0ef          	jal	ra,ffffffffc02004dc <pgfault_handler>
ffffffffc02009ae:	84aa                	mv	s1,a0
ffffffffc02009b0:	ee050fe3          	beqz	a0,ffffffffc02008ae <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc02009b4:	8522                	mv	a0,s0
ffffffffc02009b6:	d85ff0ef          	jal	ra,ffffffffc020073a <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc02009ba:	86a6                	mv	a3,s1
ffffffffc02009bc:	00004617          	auipc	a2,0x4
ffffffffc02009c0:	b3c60613          	addi	a2,a2,-1220 # ffffffffc02044f8 <commands+0x2c8>
ffffffffc02009c4:	0f600593          	li	a1,246
ffffffffc02009c8:	00004517          	auipc	a0,0x4
ffffffffc02009cc:	d3050513          	addi	a0,a0,-720 # ffffffffc02046f8 <commands+0x4c8>
ffffffffc02009d0:	9a5ff0ef          	jal	ra,ffffffffc0200374 <__panic>
}
ffffffffc02009d4:	6442                	ld	s0,16(sp)
ffffffffc02009d6:	60e2                	ld	ra,24(sp)
ffffffffc02009d8:	64a2                	ld	s1,8(sp)
ffffffffc02009da:	6105                	addi	sp,sp,32
            print_trapframe(tf);
ffffffffc02009dc:	d5fff06f          	j	ffffffffc020073a <print_trapframe>
ffffffffc02009e0:	d5bff06f          	j	ffffffffc020073a <print_trapframe>
                print_trapframe(tf);
ffffffffc02009e4:	8522                	mv	a0,s0
ffffffffc02009e6:	d55ff0ef          	jal	ra,ffffffffc020073a <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc02009ea:	86a6                	mv	a3,s1
ffffffffc02009ec:	00004617          	auipc	a2,0x4
ffffffffc02009f0:	b0c60613          	addi	a2,a2,-1268 # ffffffffc02044f8 <commands+0x2c8>
ffffffffc02009f4:	0fd00593          	li	a1,253
ffffffffc02009f8:	00004517          	auipc	a0,0x4
ffffffffc02009fc:	d0050513          	addi	a0,a0,-768 # ffffffffc02046f8 <commands+0x4c8>
ffffffffc0200a00:	975ff0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0200a04 <trap>:
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void trap(struct trapframe *tf) {
    // dispatch based on what type of trap occurred
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200a04:	11853783          	ld	a5,280(a0)
ffffffffc0200a08:	0007c463          	bltz	a5,ffffffffc0200a10 <trap+0xc>
        // interrupts
        interrupt_handler(tf);
    } else {
        // exceptions
        exception_handler(tf);
ffffffffc0200a0c:	e65ff06f          	j	ffffffffc0200870 <exception_handler>
        interrupt_handler(tf);
ffffffffc0200a10:	d8dff06f          	j	ffffffffc020079c <interrupt_handler>
	...

ffffffffc0200a20 <__alltraps>:
    .endm

    .align 4
    .globl __alltraps
__alltraps:
    SAVE_ALL
ffffffffc0200a20:	14011073          	csrw	sscratch,sp
ffffffffc0200a24:	712d                	addi	sp,sp,-288
ffffffffc0200a26:	e406                	sd	ra,8(sp)
ffffffffc0200a28:	ec0e                	sd	gp,24(sp)
ffffffffc0200a2a:	f012                	sd	tp,32(sp)
ffffffffc0200a2c:	f416                	sd	t0,40(sp)
ffffffffc0200a2e:	f81a                	sd	t1,48(sp)
ffffffffc0200a30:	fc1e                	sd	t2,56(sp)
ffffffffc0200a32:	e0a2                	sd	s0,64(sp)
ffffffffc0200a34:	e4a6                	sd	s1,72(sp)
ffffffffc0200a36:	e8aa                	sd	a0,80(sp)
ffffffffc0200a38:	ecae                	sd	a1,88(sp)
ffffffffc0200a3a:	f0b2                	sd	a2,96(sp)
ffffffffc0200a3c:	f4b6                	sd	a3,104(sp)
ffffffffc0200a3e:	f8ba                	sd	a4,112(sp)
ffffffffc0200a40:	fcbe                	sd	a5,120(sp)
ffffffffc0200a42:	e142                	sd	a6,128(sp)
ffffffffc0200a44:	e546                	sd	a7,136(sp)
ffffffffc0200a46:	e94a                	sd	s2,144(sp)
ffffffffc0200a48:	ed4e                	sd	s3,152(sp)
ffffffffc0200a4a:	f152                	sd	s4,160(sp)
ffffffffc0200a4c:	f556                	sd	s5,168(sp)
ffffffffc0200a4e:	f95a                	sd	s6,176(sp)
ffffffffc0200a50:	fd5e                	sd	s7,184(sp)
ffffffffc0200a52:	e1e2                	sd	s8,192(sp)
ffffffffc0200a54:	e5e6                	sd	s9,200(sp)
ffffffffc0200a56:	e9ea                	sd	s10,208(sp)
ffffffffc0200a58:	edee                	sd	s11,216(sp)
ffffffffc0200a5a:	f1f2                	sd	t3,224(sp)
ffffffffc0200a5c:	f5f6                	sd	t4,232(sp)
ffffffffc0200a5e:	f9fa                	sd	t5,240(sp)
ffffffffc0200a60:	fdfe                	sd	t6,248(sp)
ffffffffc0200a62:	14002473          	csrr	s0,sscratch
ffffffffc0200a66:	100024f3          	csrr	s1,sstatus
ffffffffc0200a6a:	14102973          	csrr	s2,sepc
ffffffffc0200a6e:	143029f3          	csrr	s3,stval
ffffffffc0200a72:	14202a73          	csrr	s4,scause
ffffffffc0200a76:	e822                	sd	s0,16(sp)
ffffffffc0200a78:	e226                	sd	s1,256(sp)
ffffffffc0200a7a:	e64a                	sd	s2,264(sp)
ffffffffc0200a7c:	ea4e                	sd	s3,272(sp)
ffffffffc0200a7e:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc0200a80:	850a                	mv	a0,sp
    jal trap
ffffffffc0200a82:	f83ff0ef          	jal	ra,ffffffffc0200a04 <trap>

ffffffffc0200a86 <__trapret>:
    // sp should be the same as before "jal trap"
    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc0200a86:	6492                	ld	s1,256(sp)
ffffffffc0200a88:	6932                	ld	s2,264(sp)
ffffffffc0200a8a:	10049073          	csrw	sstatus,s1
ffffffffc0200a8e:	14191073          	csrw	sepc,s2
ffffffffc0200a92:	60a2                	ld	ra,8(sp)
ffffffffc0200a94:	61e2                	ld	gp,24(sp)
ffffffffc0200a96:	7202                	ld	tp,32(sp)
ffffffffc0200a98:	72a2                	ld	t0,40(sp)
ffffffffc0200a9a:	7342                	ld	t1,48(sp)
ffffffffc0200a9c:	73e2                	ld	t2,56(sp)
ffffffffc0200a9e:	6406                	ld	s0,64(sp)
ffffffffc0200aa0:	64a6                	ld	s1,72(sp)
ffffffffc0200aa2:	6546                	ld	a0,80(sp)
ffffffffc0200aa4:	65e6                	ld	a1,88(sp)
ffffffffc0200aa6:	7606                	ld	a2,96(sp)
ffffffffc0200aa8:	76a6                	ld	a3,104(sp)
ffffffffc0200aaa:	7746                	ld	a4,112(sp)
ffffffffc0200aac:	77e6                	ld	a5,120(sp)
ffffffffc0200aae:	680a                	ld	a6,128(sp)
ffffffffc0200ab0:	68aa                	ld	a7,136(sp)
ffffffffc0200ab2:	694a                	ld	s2,144(sp)
ffffffffc0200ab4:	69ea                	ld	s3,152(sp)
ffffffffc0200ab6:	7a0a                	ld	s4,160(sp)
ffffffffc0200ab8:	7aaa                	ld	s5,168(sp)
ffffffffc0200aba:	7b4a                	ld	s6,176(sp)
ffffffffc0200abc:	7bea                	ld	s7,184(sp)
ffffffffc0200abe:	6c0e                	ld	s8,192(sp)
ffffffffc0200ac0:	6cae                	ld	s9,200(sp)
ffffffffc0200ac2:	6d4e                	ld	s10,208(sp)
ffffffffc0200ac4:	6dee                	ld	s11,216(sp)
ffffffffc0200ac6:	7e0e                	ld	t3,224(sp)
ffffffffc0200ac8:	7eae                	ld	t4,232(sp)
ffffffffc0200aca:	7f4e                	ld	t5,240(sp)
ffffffffc0200acc:	7fee                	ld	t6,248(sp)
ffffffffc0200ace:	6142                	ld	sp,16(sp)
    // go back from supervisor call
    sret
ffffffffc0200ad0:	10200073          	sret
	...

ffffffffc0200ae0 <default_init>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0200ae0:	00010797          	auipc	a5,0x10
ffffffffc0200ae4:	9a078793          	addi	a5,a5,-1632 # ffffffffc0210480 <free_area>
ffffffffc0200ae8:	e79c                	sd	a5,8(a5)
ffffffffc0200aea:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc0200aec:	0007a823          	sw	zero,16(a5)
}
ffffffffc0200af0:	8082                	ret

ffffffffc0200af2 <default_nr_free_pages>:
}

static size_t
default_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0200af2:	00010517          	auipc	a0,0x10
ffffffffc0200af6:	99e56503          	lwu	a0,-1634(a0) # ffffffffc0210490 <free_area+0x10>
ffffffffc0200afa:	8082                	ret

ffffffffc0200afc <default_check>:
}

// LAB2: below code is used to check the first fit allocation algorithm
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
ffffffffc0200afc:	715d                	addi	sp,sp,-80
ffffffffc0200afe:	f84a                	sd	s2,48(sp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0200b00:	00010917          	auipc	s2,0x10
ffffffffc0200b04:	98090913          	addi	s2,s2,-1664 # ffffffffc0210480 <free_area>
ffffffffc0200b08:	00893783          	ld	a5,8(s2)
ffffffffc0200b0c:	e486                	sd	ra,72(sp)
ffffffffc0200b0e:	e0a2                	sd	s0,64(sp)
ffffffffc0200b10:	fc26                	sd	s1,56(sp)
ffffffffc0200b12:	f44e                	sd	s3,40(sp)
ffffffffc0200b14:	f052                	sd	s4,32(sp)
ffffffffc0200b16:	ec56                	sd	s5,24(sp)
ffffffffc0200b18:	e85a                	sd	s6,16(sp)
ffffffffc0200b1a:	e45e                	sd	s7,8(sp)
ffffffffc0200b1c:	e062                	sd	s8,0(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200b1e:	31278f63          	beq	a5,s2,ffffffffc0200e3c <default_check+0x340>
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200b22:	fe87b703          	ld	a4,-24(a5)
ffffffffc0200b26:	8305                	srli	a4,a4,0x1
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0200b28:	8b05                	andi	a4,a4,1
ffffffffc0200b2a:	30070d63          	beqz	a4,ffffffffc0200e44 <default_check+0x348>
    int count = 0, total = 0;
ffffffffc0200b2e:	4401                	li	s0,0
ffffffffc0200b30:	4481                	li	s1,0
ffffffffc0200b32:	a031                	j	ffffffffc0200b3e <default_check+0x42>
ffffffffc0200b34:	fe87b703          	ld	a4,-24(a5)
        assert(PageProperty(p));
ffffffffc0200b38:	8b09                	andi	a4,a4,2
ffffffffc0200b3a:	30070563          	beqz	a4,ffffffffc0200e44 <default_check+0x348>
        count ++, total += p->property;
ffffffffc0200b3e:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200b42:	679c                	ld	a5,8(a5)
ffffffffc0200b44:	2485                	addiw	s1,s1,1
ffffffffc0200b46:	9c39                	addw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200b48:	ff2796e3          	bne	a5,s2,ffffffffc0200b34 <default_check+0x38>
ffffffffc0200b4c:	89a2                	mv	s3,s0
    }
    assert(total == nr_free_pages());
ffffffffc0200b4e:	3ef000ef          	jal	ra,ffffffffc020173c <nr_free_pages>
ffffffffc0200b52:	75351963          	bne	a0,s3,ffffffffc02012a4 <default_check+0x7a8>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200b56:	4505                	li	a0,1
ffffffffc0200b58:	317000ef          	jal	ra,ffffffffc020166e <alloc_pages>
ffffffffc0200b5c:	8a2a                	mv	s4,a0
ffffffffc0200b5e:	48050363          	beqz	a0,ffffffffc0200fe4 <default_check+0x4e8>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200b62:	4505                	li	a0,1
ffffffffc0200b64:	30b000ef          	jal	ra,ffffffffc020166e <alloc_pages>
ffffffffc0200b68:	89aa                	mv	s3,a0
ffffffffc0200b6a:	74050d63          	beqz	a0,ffffffffc02012c4 <default_check+0x7c8>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200b6e:	4505                	li	a0,1
ffffffffc0200b70:	2ff000ef          	jal	ra,ffffffffc020166e <alloc_pages>
ffffffffc0200b74:	8aaa                	mv	s5,a0
ffffffffc0200b76:	4e050763          	beqz	a0,ffffffffc0201064 <default_check+0x568>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200b7a:	2f3a0563          	beq	s4,s3,ffffffffc0200e64 <default_check+0x368>
ffffffffc0200b7e:	2eaa0363          	beq	s4,a0,ffffffffc0200e64 <default_check+0x368>
ffffffffc0200b82:	2ea98163          	beq	s3,a0,ffffffffc0200e64 <default_check+0x368>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200b86:	000a2783          	lw	a5,0(s4)
ffffffffc0200b8a:	2e079d63          	bnez	a5,ffffffffc0200e84 <default_check+0x388>
ffffffffc0200b8e:	0009a783          	lw	a5,0(s3)
ffffffffc0200b92:	2e079963          	bnez	a5,ffffffffc0200e84 <default_check+0x388>
ffffffffc0200b96:	411c                	lw	a5,0(a0)
ffffffffc0200b98:	2e079663          	bnez	a5,ffffffffc0200e84 <default_check+0x388>
extern struct Page *pages;
extern size_t npage;
extern const size_t nbase;
extern uint_t va_pa_offset;

static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200b9c:	00010797          	auipc	a5,0x10
ffffffffc0200ba0:	91478793          	addi	a5,a5,-1772 # ffffffffc02104b0 <pages>
ffffffffc0200ba4:	639c                	ld	a5,0(a5)
ffffffffc0200ba6:	00004717          	auipc	a4,0x4
ffffffffc0200baa:	ee270713          	addi	a4,a4,-286 # ffffffffc0204a88 <commands+0x858>
ffffffffc0200bae:	630c                	ld	a1,0(a4)
ffffffffc0200bb0:	40fa0733          	sub	a4,s4,a5
ffffffffc0200bb4:	870d                	srai	a4,a4,0x3
ffffffffc0200bb6:	02b70733          	mul	a4,a4,a1
ffffffffc0200bba:	00005697          	auipc	a3,0x5
ffffffffc0200bbe:	2de68693          	addi	a3,a3,734 # ffffffffc0205e98 <nbase>
ffffffffc0200bc2:	6290                	ld	a2,0(a3)
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200bc4:	00010697          	auipc	a3,0x10
ffffffffc0200bc8:	89c68693          	addi	a3,a3,-1892 # ffffffffc0210460 <npage>
ffffffffc0200bcc:	6294                	ld	a3,0(a3)
ffffffffc0200bce:	06b2                	slli	a3,a3,0xc
ffffffffc0200bd0:	9732                	add	a4,a4,a2

static inline uintptr_t page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
ffffffffc0200bd2:	0732                	slli	a4,a4,0xc
ffffffffc0200bd4:	2cd77863          	bleu	a3,a4,ffffffffc0200ea4 <default_check+0x3a8>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200bd8:	40f98733          	sub	a4,s3,a5
ffffffffc0200bdc:	870d                	srai	a4,a4,0x3
ffffffffc0200bde:	02b70733          	mul	a4,a4,a1
ffffffffc0200be2:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200be4:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200be6:	4ed77f63          	bleu	a3,a4,ffffffffc02010e4 <default_check+0x5e8>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200bea:	40f507b3          	sub	a5,a0,a5
ffffffffc0200bee:	878d                	srai	a5,a5,0x3
ffffffffc0200bf0:	02b787b3          	mul	a5,a5,a1
ffffffffc0200bf4:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200bf6:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200bf8:	34d7f663          	bleu	a3,a5,ffffffffc0200f44 <default_check+0x448>
    assert(alloc_page() == NULL);
ffffffffc0200bfc:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200bfe:	00093c03          	ld	s8,0(s2)
ffffffffc0200c02:	00893b83          	ld	s7,8(s2)
    unsigned int nr_free_store = nr_free;
ffffffffc0200c06:	01092b03          	lw	s6,16(s2)
    elm->prev = elm->next = elm;
ffffffffc0200c0a:	00010797          	auipc	a5,0x10
ffffffffc0200c0e:	8727bf23          	sd	s2,-1922(a5) # ffffffffc0210488 <free_area+0x8>
ffffffffc0200c12:	00010797          	auipc	a5,0x10
ffffffffc0200c16:	8727b723          	sd	s2,-1938(a5) # ffffffffc0210480 <free_area>
    nr_free = 0;
ffffffffc0200c1a:	00010797          	auipc	a5,0x10
ffffffffc0200c1e:	8607ab23          	sw	zero,-1930(a5) # ffffffffc0210490 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0200c22:	24d000ef          	jal	ra,ffffffffc020166e <alloc_pages>
ffffffffc0200c26:	2e051f63          	bnez	a0,ffffffffc0200f24 <default_check+0x428>
    free_page(p0);
ffffffffc0200c2a:	4585                	li	a1,1
ffffffffc0200c2c:	8552                	mv	a0,s4
ffffffffc0200c2e:	2c9000ef          	jal	ra,ffffffffc02016f6 <free_pages>
    free_page(p1);
ffffffffc0200c32:	4585                	li	a1,1
ffffffffc0200c34:	854e                	mv	a0,s3
ffffffffc0200c36:	2c1000ef          	jal	ra,ffffffffc02016f6 <free_pages>
    free_page(p2);
ffffffffc0200c3a:	4585                	li	a1,1
ffffffffc0200c3c:	8556                	mv	a0,s5
ffffffffc0200c3e:	2b9000ef          	jal	ra,ffffffffc02016f6 <free_pages>
    assert(nr_free == 3);
ffffffffc0200c42:	01092703          	lw	a4,16(s2)
ffffffffc0200c46:	478d                	li	a5,3
ffffffffc0200c48:	2af71e63          	bne	a4,a5,ffffffffc0200f04 <default_check+0x408>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200c4c:	4505                	li	a0,1
ffffffffc0200c4e:	221000ef          	jal	ra,ffffffffc020166e <alloc_pages>
ffffffffc0200c52:	89aa                	mv	s3,a0
ffffffffc0200c54:	28050863          	beqz	a0,ffffffffc0200ee4 <default_check+0x3e8>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200c58:	4505                	li	a0,1
ffffffffc0200c5a:	215000ef          	jal	ra,ffffffffc020166e <alloc_pages>
ffffffffc0200c5e:	8aaa                	mv	s5,a0
ffffffffc0200c60:	3e050263          	beqz	a0,ffffffffc0201044 <default_check+0x548>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200c64:	4505                	li	a0,1
ffffffffc0200c66:	209000ef          	jal	ra,ffffffffc020166e <alloc_pages>
ffffffffc0200c6a:	8a2a                	mv	s4,a0
ffffffffc0200c6c:	3a050c63          	beqz	a0,ffffffffc0201024 <default_check+0x528>
    assert(alloc_page() == NULL);
ffffffffc0200c70:	4505                	li	a0,1
ffffffffc0200c72:	1fd000ef          	jal	ra,ffffffffc020166e <alloc_pages>
ffffffffc0200c76:	38051763          	bnez	a0,ffffffffc0201004 <default_check+0x508>
    free_page(p0);
ffffffffc0200c7a:	4585                	li	a1,1
ffffffffc0200c7c:	854e                	mv	a0,s3
ffffffffc0200c7e:	279000ef          	jal	ra,ffffffffc02016f6 <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0200c82:	00893783          	ld	a5,8(s2)
ffffffffc0200c86:	23278f63          	beq	a5,s2,ffffffffc0200ec4 <default_check+0x3c8>
    assert((p = alloc_page()) == p0);
ffffffffc0200c8a:	4505                	li	a0,1
ffffffffc0200c8c:	1e3000ef          	jal	ra,ffffffffc020166e <alloc_pages>
ffffffffc0200c90:	32a99a63          	bne	s3,a0,ffffffffc0200fc4 <default_check+0x4c8>
    assert(alloc_page() == NULL);
ffffffffc0200c94:	4505                	li	a0,1
ffffffffc0200c96:	1d9000ef          	jal	ra,ffffffffc020166e <alloc_pages>
ffffffffc0200c9a:	30051563          	bnez	a0,ffffffffc0200fa4 <default_check+0x4a8>
    assert(nr_free == 0);
ffffffffc0200c9e:	01092783          	lw	a5,16(s2)
ffffffffc0200ca2:	2e079163          	bnez	a5,ffffffffc0200f84 <default_check+0x488>
    free_page(p);
ffffffffc0200ca6:	854e                	mv	a0,s3
ffffffffc0200ca8:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0200caa:	0000f797          	auipc	a5,0xf
ffffffffc0200cae:	7d87bb23          	sd	s8,2006(a5) # ffffffffc0210480 <free_area>
ffffffffc0200cb2:	0000f797          	auipc	a5,0xf
ffffffffc0200cb6:	7d77bb23          	sd	s7,2006(a5) # ffffffffc0210488 <free_area+0x8>
    nr_free = nr_free_store;
ffffffffc0200cba:	0000f797          	auipc	a5,0xf
ffffffffc0200cbe:	7d67ab23          	sw	s6,2006(a5) # ffffffffc0210490 <free_area+0x10>
    free_page(p);
ffffffffc0200cc2:	235000ef          	jal	ra,ffffffffc02016f6 <free_pages>
    free_page(p1);
ffffffffc0200cc6:	4585                	li	a1,1
ffffffffc0200cc8:	8556                	mv	a0,s5
ffffffffc0200cca:	22d000ef          	jal	ra,ffffffffc02016f6 <free_pages>
    free_page(p2);
ffffffffc0200cce:	4585                	li	a1,1
ffffffffc0200cd0:	8552                	mv	a0,s4
ffffffffc0200cd2:	225000ef          	jal	ra,ffffffffc02016f6 <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc0200cd6:	4515                	li	a0,5
ffffffffc0200cd8:	197000ef          	jal	ra,ffffffffc020166e <alloc_pages>
ffffffffc0200cdc:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc0200cde:	28050363          	beqz	a0,ffffffffc0200f64 <default_check+0x468>
ffffffffc0200ce2:	651c                	ld	a5,8(a0)
ffffffffc0200ce4:	8385                	srli	a5,a5,0x1
    assert(!PageProperty(p0));
ffffffffc0200ce6:	8b85                	andi	a5,a5,1
ffffffffc0200ce8:	54079e63          	bnez	a5,ffffffffc0201244 <default_check+0x748>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc0200cec:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200cee:	00093b03          	ld	s6,0(s2)
ffffffffc0200cf2:	00893a83          	ld	s5,8(s2)
ffffffffc0200cf6:	0000f797          	auipc	a5,0xf
ffffffffc0200cfa:	7927b523          	sd	s2,1930(a5) # ffffffffc0210480 <free_area>
ffffffffc0200cfe:	0000f797          	auipc	a5,0xf
ffffffffc0200d02:	7927b523          	sd	s2,1930(a5) # ffffffffc0210488 <free_area+0x8>
    assert(alloc_page() == NULL);
ffffffffc0200d06:	169000ef          	jal	ra,ffffffffc020166e <alloc_pages>
ffffffffc0200d0a:	50051d63          	bnez	a0,ffffffffc0201224 <default_check+0x728>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
ffffffffc0200d0e:	09098a13          	addi	s4,s3,144
ffffffffc0200d12:	8552                	mv	a0,s4
ffffffffc0200d14:	458d                	li	a1,3
    unsigned int nr_free_store = nr_free;
ffffffffc0200d16:	01092b83          	lw	s7,16(s2)
    nr_free = 0;
ffffffffc0200d1a:	0000f797          	auipc	a5,0xf
ffffffffc0200d1e:	7607ab23          	sw	zero,1910(a5) # ffffffffc0210490 <free_area+0x10>
    free_pages(p0 + 2, 3);
ffffffffc0200d22:	1d5000ef          	jal	ra,ffffffffc02016f6 <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc0200d26:	4511                	li	a0,4
ffffffffc0200d28:	147000ef          	jal	ra,ffffffffc020166e <alloc_pages>
ffffffffc0200d2c:	4c051c63          	bnez	a0,ffffffffc0201204 <default_check+0x708>
ffffffffc0200d30:	0989b783          	ld	a5,152(s3)
ffffffffc0200d34:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0200d36:	8b85                	andi	a5,a5,1
ffffffffc0200d38:	4a078663          	beqz	a5,ffffffffc02011e4 <default_check+0x6e8>
ffffffffc0200d3c:	0a89a703          	lw	a4,168(s3)
ffffffffc0200d40:	478d                	li	a5,3
ffffffffc0200d42:	4af71163          	bne	a4,a5,ffffffffc02011e4 <default_check+0x6e8>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0200d46:	450d                	li	a0,3
ffffffffc0200d48:	127000ef          	jal	ra,ffffffffc020166e <alloc_pages>
ffffffffc0200d4c:	8c2a                	mv	s8,a0
ffffffffc0200d4e:	46050b63          	beqz	a0,ffffffffc02011c4 <default_check+0x6c8>
    assert(alloc_page() == NULL);
ffffffffc0200d52:	4505                	li	a0,1
ffffffffc0200d54:	11b000ef          	jal	ra,ffffffffc020166e <alloc_pages>
ffffffffc0200d58:	44051663          	bnez	a0,ffffffffc02011a4 <default_check+0x6a8>
    assert(p0 + 2 == p1);
ffffffffc0200d5c:	438a1463          	bne	s4,s8,ffffffffc0201184 <default_check+0x688>

    p2 = p0 + 1;
    free_page(p0);
ffffffffc0200d60:	4585                	li	a1,1
ffffffffc0200d62:	854e                	mv	a0,s3
ffffffffc0200d64:	193000ef          	jal	ra,ffffffffc02016f6 <free_pages>
    free_pages(p1, 3);
ffffffffc0200d68:	458d                	li	a1,3
ffffffffc0200d6a:	8552                	mv	a0,s4
ffffffffc0200d6c:	18b000ef          	jal	ra,ffffffffc02016f6 <free_pages>
ffffffffc0200d70:	0089b783          	ld	a5,8(s3)
    p2 = p0 + 1;
ffffffffc0200d74:	04898c13          	addi	s8,s3,72
ffffffffc0200d78:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0200d7a:	8b85                	andi	a5,a5,1
ffffffffc0200d7c:	3e078463          	beqz	a5,ffffffffc0201164 <default_check+0x668>
ffffffffc0200d80:	0189a703          	lw	a4,24(s3)
ffffffffc0200d84:	4785                	li	a5,1
ffffffffc0200d86:	3cf71f63          	bne	a4,a5,ffffffffc0201164 <default_check+0x668>
ffffffffc0200d8a:	008a3783          	ld	a5,8(s4)
ffffffffc0200d8e:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0200d90:	8b85                	andi	a5,a5,1
ffffffffc0200d92:	3a078963          	beqz	a5,ffffffffc0201144 <default_check+0x648>
ffffffffc0200d96:	018a2703          	lw	a4,24(s4)
ffffffffc0200d9a:	478d                	li	a5,3
ffffffffc0200d9c:	3af71463          	bne	a4,a5,ffffffffc0201144 <default_check+0x648>

    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0200da0:	4505                	li	a0,1
ffffffffc0200da2:	0cd000ef          	jal	ra,ffffffffc020166e <alloc_pages>
ffffffffc0200da6:	36a99f63          	bne	s3,a0,ffffffffc0201124 <default_check+0x628>
    free_page(p0);
ffffffffc0200daa:	4585                	li	a1,1
ffffffffc0200dac:	14b000ef          	jal	ra,ffffffffc02016f6 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0200db0:	4509                	li	a0,2
ffffffffc0200db2:	0bd000ef          	jal	ra,ffffffffc020166e <alloc_pages>
ffffffffc0200db6:	34aa1763          	bne	s4,a0,ffffffffc0201104 <default_check+0x608>

    free_pages(p0, 2);
ffffffffc0200dba:	4589                	li	a1,2
ffffffffc0200dbc:	13b000ef          	jal	ra,ffffffffc02016f6 <free_pages>
    free_page(p2);
ffffffffc0200dc0:	4585                	li	a1,1
ffffffffc0200dc2:	8562                	mv	a0,s8
ffffffffc0200dc4:	133000ef          	jal	ra,ffffffffc02016f6 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0200dc8:	4515                	li	a0,5
ffffffffc0200dca:	0a5000ef          	jal	ra,ffffffffc020166e <alloc_pages>
ffffffffc0200dce:	89aa                	mv	s3,a0
ffffffffc0200dd0:	48050a63          	beqz	a0,ffffffffc0201264 <default_check+0x768>
    assert(alloc_page() == NULL);
ffffffffc0200dd4:	4505                	li	a0,1
ffffffffc0200dd6:	099000ef          	jal	ra,ffffffffc020166e <alloc_pages>
ffffffffc0200dda:	2e051563          	bnez	a0,ffffffffc02010c4 <default_check+0x5c8>

    assert(nr_free == 0);
ffffffffc0200dde:	01092783          	lw	a5,16(s2)
ffffffffc0200de2:	2c079163          	bnez	a5,ffffffffc02010a4 <default_check+0x5a8>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc0200de6:	4595                	li	a1,5
ffffffffc0200de8:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc0200dea:	0000f797          	auipc	a5,0xf
ffffffffc0200dee:	6b77a323          	sw	s7,1702(a5) # ffffffffc0210490 <free_area+0x10>
    free_list = free_list_store;
ffffffffc0200df2:	0000f797          	auipc	a5,0xf
ffffffffc0200df6:	6967b723          	sd	s6,1678(a5) # ffffffffc0210480 <free_area>
ffffffffc0200dfa:	0000f797          	auipc	a5,0xf
ffffffffc0200dfe:	6957b723          	sd	s5,1678(a5) # ffffffffc0210488 <free_area+0x8>
    free_pages(p0, 5);
ffffffffc0200e02:	0f5000ef          	jal	ra,ffffffffc02016f6 <free_pages>
    return listelm->next;
ffffffffc0200e06:	00893783          	ld	a5,8(s2)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200e0a:	01278963          	beq	a5,s2,ffffffffc0200e1c <default_check+0x320>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc0200e0e:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200e12:	679c                	ld	a5,8(a5)
ffffffffc0200e14:	34fd                	addiw	s1,s1,-1
ffffffffc0200e16:	9c19                	subw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200e18:	ff279be3          	bne	a5,s2,ffffffffc0200e0e <default_check+0x312>
    }
    assert(count == 0);
ffffffffc0200e1c:	26049463          	bnez	s1,ffffffffc0201084 <default_check+0x588>
    assert(total == 0);
ffffffffc0200e20:	46041263          	bnez	s0,ffffffffc0201284 <default_check+0x788>
}
ffffffffc0200e24:	60a6                	ld	ra,72(sp)
ffffffffc0200e26:	6406                	ld	s0,64(sp)
ffffffffc0200e28:	74e2                	ld	s1,56(sp)
ffffffffc0200e2a:	7942                	ld	s2,48(sp)
ffffffffc0200e2c:	79a2                	ld	s3,40(sp)
ffffffffc0200e2e:	7a02                	ld	s4,32(sp)
ffffffffc0200e30:	6ae2                	ld	s5,24(sp)
ffffffffc0200e32:	6b42                	ld	s6,16(sp)
ffffffffc0200e34:	6ba2                	ld	s7,8(sp)
ffffffffc0200e36:	6c02                	ld	s8,0(sp)
ffffffffc0200e38:	6161                	addi	sp,sp,80
ffffffffc0200e3a:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200e3c:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc0200e3e:	4401                	li	s0,0
ffffffffc0200e40:	4481                	li	s1,0
ffffffffc0200e42:	b331                	j	ffffffffc0200b4e <default_check+0x52>
        assert(PageProperty(p));
ffffffffc0200e44:	00004697          	auipc	a3,0x4
ffffffffc0200e48:	c4c68693          	addi	a3,a3,-948 # ffffffffc0204a90 <commands+0x860>
ffffffffc0200e4c:	00004617          	auipc	a2,0x4
ffffffffc0200e50:	c5460613          	addi	a2,a2,-940 # ffffffffc0204aa0 <commands+0x870>
ffffffffc0200e54:	0f000593          	li	a1,240
ffffffffc0200e58:	00004517          	auipc	a0,0x4
ffffffffc0200e5c:	c6050513          	addi	a0,a0,-928 # ffffffffc0204ab8 <commands+0x888>
ffffffffc0200e60:	d14ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200e64:	00004697          	auipc	a3,0x4
ffffffffc0200e68:	cec68693          	addi	a3,a3,-788 # ffffffffc0204b50 <commands+0x920>
ffffffffc0200e6c:	00004617          	auipc	a2,0x4
ffffffffc0200e70:	c3460613          	addi	a2,a2,-972 # ffffffffc0204aa0 <commands+0x870>
ffffffffc0200e74:	0bd00593          	li	a1,189
ffffffffc0200e78:	00004517          	auipc	a0,0x4
ffffffffc0200e7c:	c4050513          	addi	a0,a0,-960 # ffffffffc0204ab8 <commands+0x888>
ffffffffc0200e80:	cf4ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200e84:	00004697          	auipc	a3,0x4
ffffffffc0200e88:	cf468693          	addi	a3,a3,-780 # ffffffffc0204b78 <commands+0x948>
ffffffffc0200e8c:	00004617          	auipc	a2,0x4
ffffffffc0200e90:	c1460613          	addi	a2,a2,-1004 # ffffffffc0204aa0 <commands+0x870>
ffffffffc0200e94:	0be00593          	li	a1,190
ffffffffc0200e98:	00004517          	auipc	a0,0x4
ffffffffc0200e9c:	c2050513          	addi	a0,a0,-992 # ffffffffc0204ab8 <commands+0x888>
ffffffffc0200ea0:	cd4ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200ea4:	00004697          	auipc	a3,0x4
ffffffffc0200ea8:	d1468693          	addi	a3,a3,-748 # ffffffffc0204bb8 <commands+0x988>
ffffffffc0200eac:	00004617          	auipc	a2,0x4
ffffffffc0200eb0:	bf460613          	addi	a2,a2,-1036 # ffffffffc0204aa0 <commands+0x870>
ffffffffc0200eb4:	0c000593          	li	a1,192
ffffffffc0200eb8:	00004517          	auipc	a0,0x4
ffffffffc0200ebc:	c0050513          	addi	a0,a0,-1024 # ffffffffc0204ab8 <commands+0x888>
ffffffffc0200ec0:	cb4ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(!list_empty(&free_list));
ffffffffc0200ec4:	00004697          	auipc	a3,0x4
ffffffffc0200ec8:	d7c68693          	addi	a3,a3,-644 # ffffffffc0204c40 <commands+0xa10>
ffffffffc0200ecc:	00004617          	auipc	a2,0x4
ffffffffc0200ed0:	bd460613          	addi	a2,a2,-1068 # ffffffffc0204aa0 <commands+0x870>
ffffffffc0200ed4:	0d900593          	li	a1,217
ffffffffc0200ed8:	00004517          	auipc	a0,0x4
ffffffffc0200edc:	be050513          	addi	a0,a0,-1056 # ffffffffc0204ab8 <commands+0x888>
ffffffffc0200ee0:	c94ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200ee4:	00004697          	auipc	a3,0x4
ffffffffc0200ee8:	c0c68693          	addi	a3,a3,-1012 # ffffffffc0204af0 <commands+0x8c0>
ffffffffc0200eec:	00004617          	auipc	a2,0x4
ffffffffc0200ef0:	bb460613          	addi	a2,a2,-1100 # ffffffffc0204aa0 <commands+0x870>
ffffffffc0200ef4:	0d200593          	li	a1,210
ffffffffc0200ef8:	00004517          	auipc	a0,0x4
ffffffffc0200efc:	bc050513          	addi	a0,a0,-1088 # ffffffffc0204ab8 <commands+0x888>
ffffffffc0200f00:	c74ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(nr_free == 3);
ffffffffc0200f04:	00004697          	auipc	a3,0x4
ffffffffc0200f08:	d2c68693          	addi	a3,a3,-724 # ffffffffc0204c30 <commands+0xa00>
ffffffffc0200f0c:	00004617          	auipc	a2,0x4
ffffffffc0200f10:	b9460613          	addi	a2,a2,-1132 # ffffffffc0204aa0 <commands+0x870>
ffffffffc0200f14:	0d000593          	li	a1,208
ffffffffc0200f18:	00004517          	auipc	a0,0x4
ffffffffc0200f1c:	ba050513          	addi	a0,a0,-1120 # ffffffffc0204ab8 <commands+0x888>
ffffffffc0200f20:	c54ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200f24:	00004697          	auipc	a3,0x4
ffffffffc0200f28:	cf468693          	addi	a3,a3,-780 # ffffffffc0204c18 <commands+0x9e8>
ffffffffc0200f2c:	00004617          	auipc	a2,0x4
ffffffffc0200f30:	b7460613          	addi	a2,a2,-1164 # ffffffffc0204aa0 <commands+0x870>
ffffffffc0200f34:	0cb00593          	li	a1,203
ffffffffc0200f38:	00004517          	auipc	a0,0x4
ffffffffc0200f3c:	b8050513          	addi	a0,a0,-1152 # ffffffffc0204ab8 <commands+0x888>
ffffffffc0200f40:	c34ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200f44:	00004697          	auipc	a3,0x4
ffffffffc0200f48:	cb468693          	addi	a3,a3,-844 # ffffffffc0204bf8 <commands+0x9c8>
ffffffffc0200f4c:	00004617          	auipc	a2,0x4
ffffffffc0200f50:	b5460613          	addi	a2,a2,-1196 # ffffffffc0204aa0 <commands+0x870>
ffffffffc0200f54:	0c200593          	li	a1,194
ffffffffc0200f58:	00004517          	auipc	a0,0x4
ffffffffc0200f5c:	b6050513          	addi	a0,a0,-1184 # ffffffffc0204ab8 <commands+0x888>
ffffffffc0200f60:	c14ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(p0 != NULL);
ffffffffc0200f64:	00004697          	auipc	a3,0x4
ffffffffc0200f68:	d2468693          	addi	a3,a3,-732 # ffffffffc0204c88 <commands+0xa58>
ffffffffc0200f6c:	00004617          	auipc	a2,0x4
ffffffffc0200f70:	b3460613          	addi	a2,a2,-1228 # ffffffffc0204aa0 <commands+0x870>
ffffffffc0200f74:	0f800593          	li	a1,248
ffffffffc0200f78:	00004517          	auipc	a0,0x4
ffffffffc0200f7c:	b4050513          	addi	a0,a0,-1216 # ffffffffc0204ab8 <commands+0x888>
ffffffffc0200f80:	bf4ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(nr_free == 0);
ffffffffc0200f84:	00004697          	auipc	a3,0x4
ffffffffc0200f88:	cf468693          	addi	a3,a3,-780 # ffffffffc0204c78 <commands+0xa48>
ffffffffc0200f8c:	00004617          	auipc	a2,0x4
ffffffffc0200f90:	b1460613          	addi	a2,a2,-1260 # ffffffffc0204aa0 <commands+0x870>
ffffffffc0200f94:	0df00593          	li	a1,223
ffffffffc0200f98:	00004517          	auipc	a0,0x4
ffffffffc0200f9c:	b2050513          	addi	a0,a0,-1248 # ffffffffc0204ab8 <commands+0x888>
ffffffffc0200fa0:	bd4ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200fa4:	00004697          	auipc	a3,0x4
ffffffffc0200fa8:	c7468693          	addi	a3,a3,-908 # ffffffffc0204c18 <commands+0x9e8>
ffffffffc0200fac:	00004617          	auipc	a2,0x4
ffffffffc0200fb0:	af460613          	addi	a2,a2,-1292 # ffffffffc0204aa0 <commands+0x870>
ffffffffc0200fb4:	0dd00593          	li	a1,221
ffffffffc0200fb8:	00004517          	auipc	a0,0x4
ffffffffc0200fbc:	b0050513          	addi	a0,a0,-1280 # ffffffffc0204ab8 <commands+0x888>
ffffffffc0200fc0:	bb4ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc0200fc4:	00004697          	auipc	a3,0x4
ffffffffc0200fc8:	c9468693          	addi	a3,a3,-876 # ffffffffc0204c58 <commands+0xa28>
ffffffffc0200fcc:	00004617          	auipc	a2,0x4
ffffffffc0200fd0:	ad460613          	addi	a2,a2,-1324 # ffffffffc0204aa0 <commands+0x870>
ffffffffc0200fd4:	0dc00593          	li	a1,220
ffffffffc0200fd8:	00004517          	auipc	a0,0x4
ffffffffc0200fdc:	ae050513          	addi	a0,a0,-1312 # ffffffffc0204ab8 <commands+0x888>
ffffffffc0200fe0:	b94ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200fe4:	00004697          	auipc	a3,0x4
ffffffffc0200fe8:	b0c68693          	addi	a3,a3,-1268 # ffffffffc0204af0 <commands+0x8c0>
ffffffffc0200fec:	00004617          	auipc	a2,0x4
ffffffffc0200ff0:	ab460613          	addi	a2,a2,-1356 # ffffffffc0204aa0 <commands+0x870>
ffffffffc0200ff4:	0b900593          	li	a1,185
ffffffffc0200ff8:	00004517          	auipc	a0,0x4
ffffffffc0200ffc:	ac050513          	addi	a0,a0,-1344 # ffffffffc0204ab8 <commands+0x888>
ffffffffc0201000:	b74ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201004:	00004697          	auipc	a3,0x4
ffffffffc0201008:	c1468693          	addi	a3,a3,-1004 # ffffffffc0204c18 <commands+0x9e8>
ffffffffc020100c:	00004617          	auipc	a2,0x4
ffffffffc0201010:	a9460613          	addi	a2,a2,-1388 # ffffffffc0204aa0 <commands+0x870>
ffffffffc0201014:	0d600593          	li	a1,214
ffffffffc0201018:	00004517          	auipc	a0,0x4
ffffffffc020101c:	aa050513          	addi	a0,a0,-1376 # ffffffffc0204ab8 <commands+0x888>
ffffffffc0201020:	b54ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0201024:	00004697          	auipc	a3,0x4
ffffffffc0201028:	b0c68693          	addi	a3,a3,-1268 # ffffffffc0204b30 <commands+0x900>
ffffffffc020102c:	00004617          	auipc	a2,0x4
ffffffffc0201030:	a7460613          	addi	a2,a2,-1420 # ffffffffc0204aa0 <commands+0x870>
ffffffffc0201034:	0d400593          	li	a1,212
ffffffffc0201038:	00004517          	auipc	a0,0x4
ffffffffc020103c:	a8050513          	addi	a0,a0,-1408 # ffffffffc0204ab8 <commands+0x888>
ffffffffc0201040:	b34ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201044:	00004697          	auipc	a3,0x4
ffffffffc0201048:	acc68693          	addi	a3,a3,-1332 # ffffffffc0204b10 <commands+0x8e0>
ffffffffc020104c:	00004617          	auipc	a2,0x4
ffffffffc0201050:	a5460613          	addi	a2,a2,-1452 # ffffffffc0204aa0 <commands+0x870>
ffffffffc0201054:	0d300593          	li	a1,211
ffffffffc0201058:	00004517          	auipc	a0,0x4
ffffffffc020105c:	a6050513          	addi	a0,a0,-1440 # ffffffffc0204ab8 <commands+0x888>
ffffffffc0201060:	b14ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0201064:	00004697          	auipc	a3,0x4
ffffffffc0201068:	acc68693          	addi	a3,a3,-1332 # ffffffffc0204b30 <commands+0x900>
ffffffffc020106c:	00004617          	auipc	a2,0x4
ffffffffc0201070:	a3460613          	addi	a2,a2,-1484 # ffffffffc0204aa0 <commands+0x870>
ffffffffc0201074:	0bb00593          	li	a1,187
ffffffffc0201078:	00004517          	auipc	a0,0x4
ffffffffc020107c:	a4050513          	addi	a0,a0,-1472 # ffffffffc0204ab8 <commands+0x888>
ffffffffc0201080:	af4ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(count == 0);
ffffffffc0201084:	00004697          	auipc	a3,0x4
ffffffffc0201088:	d5468693          	addi	a3,a3,-684 # ffffffffc0204dd8 <commands+0xba8>
ffffffffc020108c:	00004617          	auipc	a2,0x4
ffffffffc0201090:	a1460613          	addi	a2,a2,-1516 # ffffffffc0204aa0 <commands+0x870>
ffffffffc0201094:	12500593          	li	a1,293
ffffffffc0201098:	00004517          	auipc	a0,0x4
ffffffffc020109c:	a2050513          	addi	a0,a0,-1504 # ffffffffc0204ab8 <commands+0x888>
ffffffffc02010a0:	ad4ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(nr_free == 0);
ffffffffc02010a4:	00004697          	auipc	a3,0x4
ffffffffc02010a8:	bd468693          	addi	a3,a3,-1068 # ffffffffc0204c78 <commands+0xa48>
ffffffffc02010ac:	00004617          	auipc	a2,0x4
ffffffffc02010b0:	9f460613          	addi	a2,a2,-1548 # ffffffffc0204aa0 <commands+0x870>
ffffffffc02010b4:	11a00593          	li	a1,282
ffffffffc02010b8:	00004517          	auipc	a0,0x4
ffffffffc02010bc:	a0050513          	addi	a0,a0,-1536 # ffffffffc0204ab8 <commands+0x888>
ffffffffc02010c0:	ab4ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02010c4:	00004697          	auipc	a3,0x4
ffffffffc02010c8:	b5468693          	addi	a3,a3,-1196 # ffffffffc0204c18 <commands+0x9e8>
ffffffffc02010cc:	00004617          	auipc	a2,0x4
ffffffffc02010d0:	9d460613          	addi	a2,a2,-1580 # ffffffffc0204aa0 <commands+0x870>
ffffffffc02010d4:	11800593          	li	a1,280
ffffffffc02010d8:	00004517          	auipc	a0,0x4
ffffffffc02010dc:	9e050513          	addi	a0,a0,-1568 # ffffffffc0204ab8 <commands+0x888>
ffffffffc02010e0:	a94ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc02010e4:	00004697          	auipc	a3,0x4
ffffffffc02010e8:	af468693          	addi	a3,a3,-1292 # ffffffffc0204bd8 <commands+0x9a8>
ffffffffc02010ec:	00004617          	auipc	a2,0x4
ffffffffc02010f0:	9b460613          	addi	a2,a2,-1612 # ffffffffc0204aa0 <commands+0x870>
ffffffffc02010f4:	0c100593          	li	a1,193
ffffffffc02010f8:	00004517          	auipc	a0,0x4
ffffffffc02010fc:	9c050513          	addi	a0,a0,-1600 # ffffffffc0204ab8 <commands+0x888>
ffffffffc0201100:	a74ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0201104:	00004697          	auipc	a3,0x4
ffffffffc0201108:	c9468693          	addi	a3,a3,-876 # ffffffffc0204d98 <commands+0xb68>
ffffffffc020110c:	00004617          	auipc	a2,0x4
ffffffffc0201110:	99460613          	addi	a2,a2,-1644 # ffffffffc0204aa0 <commands+0x870>
ffffffffc0201114:	11200593          	li	a1,274
ffffffffc0201118:	00004517          	auipc	a0,0x4
ffffffffc020111c:	9a050513          	addi	a0,a0,-1632 # ffffffffc0204ab8 <commands+0x888>
ffffffffc0201120:	a54ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0201124:	00004697          	auipc	a3,0x4
ffffffffc0201128:	c5468693          	addi	a3,a3,-940 # ffffffffc0204d78 <commands+0xb48>
ffffffffc020112c:	00004617          	auipc	a2,0x4
ffffffffc0201130:	97460613          	addi	a2,a2,-1676 # ffffffffc0204aa0 <commands+0x870>
ffffffffc0201134:	11000593          	li	a1,272
ffffffffc0201138:	00004517          	auipc	a0,0x4
ffffffffc020113c:	98050513          	addi	a0,a0,-1664 # ffffffffc0204ab8 <commands+0x888>
ffffffffc0201140:	a34ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0201144:	00004697          	auipc	a3,0x4
ffffffffc0201148:	c0c68693          	addi	a3,a3,-1012 # ffffffffc0204d50 <commands+0xb20>
ffffffffc020114c:	00004617          	auipc	a2,0x4
ffffffffc0201150:	95460613          	addi	a2,a2,-1708 # ffffffffc0204aa0 <commands+0x870>
ffffffffc0201154:	10e00593          	li	a1,270
ffffffffc0201158:	00004517          	auipc	a0,0x4
ffffffffc020115c:	96050513          	addi	a0,a0,-1696 # ffffffffc0204ab8 <commands+0x888>
ffffffffc0201160:	a14ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0201164:	00004697          	auipc	a3,0x4
ffffffffc0201168:	bc468693          	addi	a3,a3,-1084 # ffffffffc0204d28 <commands+0xaf8>
ffffffffc020116c:	00004617          	auipc	a2,0x4
ffffffffc0201170:	93460613          	addi	a2,a2,-1740 # ffffffffc0204aa0 <commands+0x870>
ffffffffc0201174:	10d00593          	li	a1,269
ffffffffc0201178:	00004517          	auipc	a0,0x4
ffffffffc020117c:	94050513          	addi	a0,a0,-1728 # ffffffffc0204ab8 <commands+0x888>
ffffffffc0201180:	9f4ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(p0 + 2 == p1);
ffffffffc0201184:	00004697          	auipc	a3,0x4
ffffffffc0201188:	b9468693          	addi	a3,a3,-1132 # ffffffffc0204d18 <commands+0xae8>
ffffffffc020118c:	00004617          	auipc	a2,0x4
ffffffffc0201190:	91460613          	addi	a2,a2,-1772 # ffffffffc0204aa0 <commands+0x870>
ffffffffc0201194:	10800593          	li	a1,264
ffffffffc0201198:	00004517          	auipc	a0,0x4
ffffffffc020119c:	92050513          	addi	a0,a0,-1760 # ffffffffc0204ab8 <commands+0x888>
ffffffffc02011a0:	9d4ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02011a4:	00004697          	auipc	a3,0x4
ffffffffc02011a8:	a7468693          	addi	a3,a3,-1420 # ffffffffc0204c18 <commands+0x9e8>
ffffffffc02011ac:	00004617          	auipc	a2,0x4
ffffffffc02011b0:	8f460613          	addi	a2,a2,-1804 # ffffffffc0204aa0 <commands+0x870>
ffffffffc02011b4:	10700593          	li	a1,263
ffffffffc02011b8:	00004517          	auipc	a0,0x4
ffffffffc02011bc:	90050513          	addi	a0,a0,-1792 # ffffffffc0204ab8 <commands+0x888>
ffffffffc02011c0:	9b4ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc02011c4:	00004697          	auipc	a3,0x4
ffffffffc02011c8:	b3468693          	addi	a3,a3,-1228 # ffffffffc0204cf8 <commands+0xac8>
ffffffffc02011cc:	00004617          	auipc	a2,0x4
ffffffffc02011d0:	8d460613          	addi	a2,a2,-1836 # ffffffffc0204aa0 <commands+0x870>
ffffffffc02011d4:	10600593          	li	a1,262
ffffffffc02011d8:	00004517          	auipc	a0,0x4
ffffffffc02011dc:	8e050513          	addi	a0,a0,-1824 # ffffffffc0204ab8 <commands+0x888>
ffffffffc02011e0:	994ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc02011e4:	00004697          	auipc	a3,0x4
ffffffffc02011e8:	ae468693          	addi	a3,a3,-1308 # ffffffffc0204cc8 <commands+0xa98>
ffffffffc02011ec:	00004617          	auipc	a2,0x4
ffffffffc02011f0:	8b460613          	addi	a2,a2,-1868 # ffffffffc0204aa0 <commands+0x870>
ffffffffc02011f4:	10500593          	li	a1,261
ffffffffc02011f8:	00004517          	auipc	a0,0x4
ffffffffc02011fc:	8c050513          	addi	a0,a0,-1856 # ffffffffc0204ab8 <commands+0x888>
ffffffffc0201200:	974ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc0201204:	00004697          	auipc	a3,0x4
ffffffffc0201208:	aac68693          	addi	a3,a3,-1364 # ffffffffc0204cb0 <commands+0xa80>
ffffffffc020120c:	00004617          	auipc	a2,0x4
ffffffffc0201210:	89460613          	addi	a2,a2,-1900 # ffffffffc0204aa0 <commands+0x870>
ffffffffc0201214:	10400593          	li	a1,260
ffffffffc0201218:	00004517          	auipc	a0,0x4
ffffffffc020121c:	8a050513          	addi	a0,a0,-1888 # ffffffffc0204ab8 <commands+0x888>
ffffffffc0201220:	954ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201224:	00004697          	auipc	a3,0x4
ffffffffc0201228:	9f468693          	addi	a3,a3,-1548 # ffffffffc0204c18 <commands+0x9e8>
ffffffffc020122c:	00004617          	auipc	a2,0x4
ffffffffc0201230:	87460613          	addi	a2,a2,-1932 # ffffffffc0204aa0 <commands+0x870>
ffffffffc0201234:	0fe00593          	li	a1,254
ffffffffc0201238:	00004517          	auipc	a0,0x4
ffffffffc020123c:	88050513          	addi	a0,a0,-1920 # ffffffffc0204ab8 <commands+0x888>
ffffffffc0201240:	934ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(!PageProperty(p0));
ffffffffc0201244:	00004697          	auipc	a3,0x4
ffffffffc0201248:	a5468693          	addi	a3,a3,-1452 # ffffffffc0204c98 <commands+0xa68>
ffffffffc020124c:	00004617          	auipc	a2,0x4
ffffffffc0201250:	85460613          	addi	a2,a2,-1964 # ffffffffc0204aa0 <commands+0x870>
ffffffffc0201254:	0f900593          	li	a1,249
ffffffffc0201258:	00004517          	auipc	a0,0x4
ffffffffc020125c:	86050513          	addi	a0,a0,-1952 # ffffffffc0204ab8 <commands+0x888>
ffffffffc0201260:	914ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0201264:	00004697          	auipc	a3,0x4
ffffffffc0201268:	b5468693          	addi	a3,a3,-1196 # ffffffffc0204db8 <commands+0xb88>
ffffffffc020126c:	00004617          	auipc	a2,0x4
ffffffffc0201270:	83460613          	addi	a2,a2,-1996 # ffffffffc0204aa0 <commands+0x870>
ffffffffc0201274:	11700593          	li	a1,279
ffffffffc0201278:	00004517          	auipc	a0,0x4
ffffffffc020127c:	84050513          	addi	a0,a0,-1984 # ffffffffc0204ab8 <commands+0x888>
ffffffffc0201280:	8f4ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(total == 0);
ffffffffc0201284:	00004697          	auipc	a3,0x4
ffffffffc0201288:	b6468693          	addi	a3,a3,-1180 # ffffffffc0204de8 <commands+0xbb8>
ffffffffc020128c:	00004617          	auipc	a2,0x4
ffffffffc0201290:	81460613          	addi	a2,a2,-2028 # ffffffffc0204aa0 <commands+0x870>
ffffffffc0201294:	12600593          	li	a1,294
ffffffffc0201298:	00004517          	auipc	a0,0x4
ffffffffc020129c:	82050513          	addi	a0,a0,-2016 # ffffffffc0204ab8 <commands+0x888>
ffffffffc02012a0:	8d4ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(total == nr_free_pages());
ffffffffc02012a4:	00004697          	auipc	a3,0x4
ffffffffc02012a8:	82c68693          	addi	a3,a3,-2004 # ffffffffc0204ad0 <commands+0x8a0>
ffffffffc02012ac:	00003617          	auipc	a2,0x3
ffffffffc02012b0:	7f460613          	addi	a2,a2,2036 # ffffffffc0204aa0 <commands+0x870>
ffffffffc02012b4:	0f300593          	li	a1,243
ffffffffc02012b8:	00004517          	auipc	a0,0x4
ffffffffc02012bc:	80050513          	addi	a0,a0,-2048 # ffffffffc0204ab8 <commands+0x888>
ffffffffc02012c0:	8b4ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc02012c4:	00004697          	auipc	a3,0x4
ffffffffc02012c8:	84c68693          	addi	a3,a3,-1972 # ffffffffc0204b10 <commands+0x8e0>
ffffffffc02012cc:	00003617          	auipc	a2,0x3
ffffffffc02012d0:	7d460613          	addi	a2,a2,2004 # ffffffffc0204aa0 <commands+0x870>
ffffffffc02012d4:	0ba00593          	li	a1,186
ffffffffc02012d8:	00003517          	auipc	a0,0x3
ffffffffc02012dc:	7e050513          	addi	a0,a0,2016 # ffffffffc0204ab8 <commands+0x888>
ffffffffc02012e0:	894ff0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc02012e4 <default_free_pages>:
default_free_pages(struct Page *base, size_t n) {
ffffffffc02012e4:	1141                	addi	sp,sp,-16
ffffffffc02012e6:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02012e8:	18058063          	beqz	a1,ffffffffc0201468 <default_free_pages+0x184>
    for (; p != base + n; p ++) {
ffffffffc02012ec:	00359693          	slli	a3,a1,0x3
ffffffffc02012f0:	96ae                	add	a3,a3,a1
ffffffffc02012f2:	068e                	slli	a3,a3,0x3
ffffffffc02012f4:	96aa                	add	a3,a3,a0
ffffffffc02012f6:	02d50d63          	beq	a0,a3,ffffffffc0201330 <default_free_pages+0x4c>
ffffffffc02012fa:	651c                	ld	a5,8(a0)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc02012fc:	8b85                	andi	a5,a5,1
ffffffffc02012fe:	14079563          	bnez	a5,ffffffffc0201448 <default_free_pages+0x164>
ffffffffc0201302:	651c                	ld	a5,8(a0)
ffffffffc0201304:	8385                	srli	a5,a5,0x1
ffffffffc0201306:	8b85                	andi	a5,a5,1
ffffffffc0201308:	14079063          	bnez	a5,ffffffffc0201448 <default_free_pages+0x164>
ffffffffc020130c:	87aa                	mv	a5,a0
ffffffffc020130e:	a809                	j	ffffffffc0201320 <default_free_pages+0x3c>
ffffffffc0201310:	6798                	ld	a4,8(a5)
ffffffffc0201312:	8b05                	andi	a4,a4,1
ffffffffc0201314:	12071a63          	bnez	a4,ffffffffc0201448 <default_free_pages+0x164>
ffffffffc0201318:	6798                	ld	a4,8(a5)
ffffffffc020131a:	8b09                	andi	a4,a4,2
ffffffffc020131c:	12071663          	bnez	a4,ffffffffc0201448 <default_free_pages+0x164>
        p->flags = 0;
ffffffffc0201320:	0007b423          	sd	zero,8(a5)
    return pa2page(PDE_ADDR(pde));
}

static inline int page_ref(struct Page *page) { return page->ref; }

static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0201324:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0201328:	04878793          	addi	a5,a5,72
ffffffffc020132c:	fed792e3          	bne	a5,a3,ffffffffc0201310 <default_free_pages+0x2c>
    base->property = n;
ffffffffc0201330:	2581                	sext.w	a1,a1
ffffffffc0201332:	cd0c                	sw	a1,24(a0)
    SetPageProperty(base);
ffffffffc0201334:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201338:	4789                	li	a5,2
ffffffffc020133a:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc020133e:	0000f697          	auipc	a3,0xf
ffffffffc0201342:	14268693          	addi	a3,a3,322 # ffffffffc0210480 <free_area>
ffffffffc0201346:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0201348:	669c                	ld	a5,8(a3)
ffffffffc020134a:	9db9                	addw	a1,a1,a4
ffffffffc020134c:	0000f717          	auipc	a4,0xf
ffffffffc0201350:	14b72223          	sw	a1,324(a4) # ffffffffc0210490 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc0201354:	08d78f63          	beq	a5,a3,ffffffffc02013f2 <default_free_pages+0x10e>
            struct Page* page = le2page(le, page_link);
ffffffffc0201358:	fe078713          	addi	a4,a5,-32
ffffffffc020135c:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc020135e:	4801                	li	a6,0
ffffffffc0201360:	02050613          	addi	a2,a0,32
            if (base < page) {
ffffffffc0201364:	00e56a63          	bltu	a0,a4,ffffffffc0201378 <default_free_pages+0x94>
    return listelm->next;
ffffffffc0201368:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc020136a:	02d70563          	beq	a4,a3,ffffffffc0201394 <default_free_pages+0xb0>
        while ((le = list_next(le)) != &free_list) {
ffffffffc020136e:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0201370:	fe078713          	addi	a4,a5,-32
            if (base < page) {
ffffffffc0201374:	fee57ae3          	bleu	a4,a0,ffffffffc0201368 <default_free_pages+0x84>
ffffffffc0201378:	00080663          	beqz	a6,ffffffffc0201384 <default_free_pages+0xa0>
ffffffffc020137c:	0000f817          	auipc	a6,0xf
ffffffffc0201380:	10b83223          	sd	a1,260(a6) # ffffffffc0210480 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0201384:	638c                	ld	a1,0(a5)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc0201386:	e390                	sd	a2,0(a5)
ffffffffc0201388:	e590                	sd	a2,8(a1)
    elm->next = next;
ffffffffc020138a:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc020138c:	f10c                	sd	a1,32(a0)
    if (le != &free_list) {
ffffffffc020138e:	02d59163          	bne	a1,a3,ffffffffc02013b0 <default_free_pages+0xcc>
ffffffffc0201392:	a091                	j	ffffffffc02013d6 <default_free_pages+0xf2>
    prev->next = next->prev = elm;
ffffffffc0201394:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201396:	f514                	sd	a3,40(a0)
ffffffffc0201398:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc020139a:	f11c                	sd	a5,32(a0)
                list_add(le, &(base->page_link));
ffffffffc020139c:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc020139e:	00d70563          	beq	a4,a3,ffffffffc02013a8 <default_free_pages+0xc4>
ffffffffc02013a2:	4805                	li	a6,1
ffffffffc02013a4:	87ba                	mv	a5,a4
ffffffffc02013a6:	b7e9                	j	ffffffffc0201370 <default_free_pages+0x8c>
ffffffffc02013a8:	e290                	sd	a2,0(a3)
    return listelm->prev;
ffffffffc02013aa:	85be                	mv	a1,a5
    if (le != &free_list) {
ffffffffc02013ac:	02d78163          	beq	a5,a3,ffffffffc02013ce <default_free_pages+0xea>
        if (p + p->property == base) {
ffffffffc02013b0:	ff85a803          	lw	a6,-8(a1)
        p = le2page(le, page_link);
ffffffffc02013b4:	fe058613          	addi	a2,a1,-32
        if (p + p->property == base) {
ffffffffc02013b8:	02081713          	slli	a4,a6,0x20
ffffffffc02013bc:	9301                	srli	a4,a4,0x20
ffffffffc02013be:	00371793          	slli	a5,a4,0x3
ffffffffc02013c2:	97ba                	add	a5,a5,a4
ffffffffc02013c4:	078e                	slli	a5,a5,0x3
ffffffffc02013c6:	97b2                	add	a5,a5,a2
ffffffffc02013c8:	02f50e63          	beq	a0,a5,ffffffffc0201404 <default_free_pages+0x120>
ffffffffc02013cc:	751c                	ld	a5,40(a0)
    if (le != &free_list) {
ffffffffc02013ce:	fe078713          	addi	a4,a5,-32
ffffffffc02013d2:	00d78d63          	beq	a5,a3,ffffffffc02013ec <default_free_pages+0x108>
        if (base + base->property == p) {
ffffffffc02013d6:	4d0c                	lw	a1,24(a0)
ffffffffc02013d8:	02059613          	slli	a2,a1,0x20
ffffffffc02013dc:	9201                	srli	a2,a2,0x20
ffffffffc02013de:	00361693          	slli	a3,a2,0x3
ffffffffc02013e2:	96b2                	add	a3,a3,a2
ffffffffc02013e4:	068e                	slli	a3,a3,0x3
ffffffffc02013e6:	96aa                	add	a3,a3,a0
ffffffffc02013e8:	04d70063          	beq	a4,a3,ffffffffc0201428 <default_free_pages+0x144>
}
ffffffffc02013ec:	60a2                	ld	ra,8(sp)
ffffffffc02013ee:	0141                	addi	sp,sp,16
ffffffffc02013f0:	8082                	ret
ffffffffc02013f2:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc02013f4:	02050713          	addi	a4,a0,32
    prev->next = next->prev = elm;
ffffffffc02013f8:	e398                	sd	a4,0(a5)
ffffffffc02013fa:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc02013fc:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc02013fe:	f11c                	sd	a5,32(a0)
}
ffffffffc0201400:	0141                	addi	sp,sp,16
ffffffffc0201402:	8082                	ret
            p->property += base->property;
ffffffffc0201404:	4d1c                	lw	a5,24(a0)
ffffffffc0201406:	0107883b          	addw	a6,a5,a6
ffffffffc020140a:	ff05ac23          	sw	a6,-8(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc020140e:	57f5                	li	a5,-3
ffffffffc0201410:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201414:	02053803          	ld	a6,32(a0)
ffffffffc0201418:	7518                	ld	a4,40(a0)
            base = p;
ffffffffc020141a:	8532                	mv	a0,a2
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc020141c:	00e83423          	sd	a4,8(a6)
    next->prev = prev;
ffffffffc0201420:	659c                	ld	a5,8(a1)
ffffffffc0201422:	01073023          	sd	a6,0(a4)
ffffffffc0201426:	b765                	j	ffffffffc02013ce <default_free_pages+0xea>
            base->property += p->property;
ffffffffc0201428:	ff87a703          	lw	a4,-8(a5)
ffffffffc020142c:	fe878693          	addi	a3,a5,-24
ffffffffc0201430:	9db9                	addw	a1,a1,a4
ffffffffc0201432:	cd0c                	sw	a1,24(a0)
ffffffffc0201434:	5775                	li	a4,-3
ffffffffc0201436:	60e6b02f          	amoand.d	zero,a4,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc020143a:	6398                	ld	a4,0(a5)
ffffffffc020143c:	679c                	ld	a5,8(a5)
}
ffffffffc020143e:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc0201440:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0201442:	e398                	sd	a4,0(a5)
ffffffffc0201444:	0141                	addi	sp,sp,16
ffffffffc0201446:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0201448:	00004697          	auipc	a3,0x4
ffffffffc020144c:	9b068693          	addi	a3,a3,-1616 # ffffffffc0204df8 <commands+0xbc8>
ffffffffc0201450:	00003617          	auipc	a2,0x3
ffffffffc0201454:	65060613          	addi	a2,a2,1616 # ffffffffc0204aa0 <commands+0x870>
ffffffffc0201458:	08300593          	li	a1,131
ffffffffc020145c:	00003517          	auipc	a0,0x3
ffffffffc0201460:	65c50513          	addi	a0,a0,1628 # ffffffffc0204ab8 <commands+0x888>
ffffffffc0201464:	f11fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(n > 0);
ffffffffc0201468:	00004697          	auipc	a3,0x4
ffffffffc020146c:	9b868693          	addi	a3,a3,-1608 # ffffffffc0204e20 <commands+0xbf0>
ffffffffc0201470:	00003617          	auipc	a2,0x3
ffffffffc0201474:	63060613          	addi	a2,a2,1584 # ffffffffc0204aa0 <commands+0x870>
ffffffffc0201478:	08000593          	li	a1,128
ffffffffc020147c:	00003517          	auipc	a0,0x3
ffffffffc0201480:	63c50513          	addi	a0,a0,1596 # ffffffffc0204ab8 <commands+0x888>
ffffffffc0201484:	ef1fe0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0201488 <default_alloc_pages>:
    assert(n > 0);
ffffffffc0201488:	cd51                	beqz	a0,ffffffffc0201524 <default_alloc_pages+0x9c>
    if (n > nr_free) {
ffffffffc020148a:	0000f597          	auipc	a1,0xf
ffffffffc020148e:	ff658593          	addi	a1,a1,-10 # ffffffffc0210480 <free_area>
ffffffffc0201492:	0105a803          	lw	a6,16(a1)
ffffffffc0201496:	862a                	mv	a2,a0
ffffffffc0201498:	02081793          	slli	a5,a6,0x20
ffffffffc020149c:	9381                	srli	a5,a5,0x20
ffffffffc020149e:	00a7ee63          	bltu	a5,a0,ffffffffc02014ba <default_alloc_pages+0x32>
    list_entry_t *le = &free_list;
ffffffffc02014a2:	87ae                	mv	a5,a1
ffffffffc02014a4:	a801                	j	ffffffffc02014b4 <default_alloc_pages+0x2c>
        if (p->property >= n) {
ffffffffc02014a6:	ff87a703          	lw	a4,-8(a5)
ffffffffc02014aa:	02071693          	slli	a3,a4,0x20
ffffffffc02014ae:	9281                	srli	a3,a3,0x20
ffffffffc02014b0:	00c6f763          	bleu	a2,a3,ffffffffc02014be <default_alloc_pages+0x36>
    return listelm->next;
ffffffffc02014b4:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc02014b6:	feb798e3          	bne	a5,a1,ffffffffc02014a6 <default_alloc_pages+0x1e>
        return NULL;
ffffffffc02014ba:	4501                	li	a0,0
}
ffffffffc02014bc:	8082                	ret
        struct Page *p = le2page(le, page_link);
ffffffffc02014be:	fe078513          	addi	a0,a5,-32
    if (page != NULL) {
ffffffffc02014c2:	dd6d                	beqz	a0,ffffffffc02014bc <default_alloc_pages+0x34>
    return listelm->prev;
ffffffffc02014c4:	0007b883          	ld	a7,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc02014c8:	0087b303          	ld	t1,8(a5)
    prev->next = next;
ffffffffc02014cc:	00060e1b          	sext.w	t3,a2
ffffffffc02014d0:	0068b423          	sd	t1,8(a7)
    next->prev = prev;
ffffffffc02014d4:	01133023          	sd	a7,0(t1)
        if (page->property > n) {
ffffffffc02014d8:	02d67b63          	bleu	a3,a2,ffffffffc020150e <default_alloc_pages+0x86>
            struct Page *p = page + n;
ffffffffc02014dc:	00361693          	slli	a3,a2,0x3
ffffffffc02014e0:	96b2                	add	a3,a3,a2
ffffffffc02014e2:	068e                	slli	a3,a3,0x3
ffffffffc02014e4:	96aa                	add	a3,a3,a0
            p->property = page->property - n;
ffffffffc02014e6:	41c7073b          	subw	a4,a4,t3
ffffffffc02014ea:	ce98                	sw	a4,24(a3)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02014ec:	00868613          	addi	a2,a3,8
ffffffffc02014f0:	4709                	li	a4,2
ffffffffc02014f2:	40e6302f          	amoor.d	zero,a4,(a2)
    __list_add(elm, listelm, listelm->next);
ffffffffc02014f6:	0088b703          	ld	a4,8(a7)
            list_add(prev, &(p->page_link));
ffffffffc02014fa:	02068613          	addi	a2,a3,32
    prev->next = next->prev = elm;
ffffffffc02014fe:	0105a803          	lw	a6,16(a1)
ffffffffc0201502:	e310                	sd	a2,0(a4)
ffffffffc0201504:	00c8b423          	sd	a2,8(a7)
    elm->next = next;
ffffffffc0201508:	f698                	sd	a4,40(a3)
    elm->prev = prev;
ffffffffc020150a:	0316b023          	sd	a7,32(a3)
        nr_free -= n;
ffffffffc020150e:	41c8083b          	subw	a6,a6,t3
ffffffffc0201512:	0000f717          	auipc	a4,0xf
ffffffffc0201516:	f7072f23          	sw	a6,-130(a4) # ffffffffc0210490 <free_area+0x10>
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc020151a:	5775                	li	a4,-3
ffffffffc020151c:	17a1                	addi	a5,a5,-24
ffffffffc020151e:	60e7b02f          	amoand.d	zero,a4,(a5)
ffffffffc0201522:	8082                	ret
default_alloc_pages(size_t n) {
ffffffffc0201524:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc0201526:	00004697          	auipc	a3,0x4
ffffffffc020152a:	8fa68693          	addi	a3,a3,-1798 # ffffffffc0204e20 <commands+0xbf0>
ffffffffc020152e:	00003617          	auipc	a2,0x3
ffffffffc0201532:	57260613          	addi	a2,a2,1394 # ffffffffc0204aa0 <commands+0x870>
ffffffffc0201536:	06200593          	li	a1,98
ffffffffc020153a:	00003517          	auipc	a0,0x3
ffffffffc020153e:	57e50513          	addi	a0,a0,1406 # ffffffffc0204ab8 <commands+0x888>
default_alloc_pages(size_t n) {
ffffffffc0201542:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201544:	e31fe0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0201548 <default_init_memmap>:
default_init_memmap(struct Page *base, size_t n) {
ffffffffc0201548:	1141                	addi	sp,sp,-16
ffffffffc020154a:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc020154c:	c1fd                	beqz	a1,ffffffffc0201632 <default_init_memmap+0xea>
    for (; p != base + n; p ++) {
ffffffffc020154e:	00359693          	slli	a3,a1,0x3
ffffffffc0201552:	96ae                	add	a3,a3,a1
ffffffffc0201554:	068e                	slli	a3,a3,0x3
ffffffffc0201556:	96aa                	add	a3,a3,a0
ffffffffc0201558:	02d50463          	beq	a0,a3,ffffffffc0201580 <default_init_memmap+0x38>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc020155c:	6518                	ld	a4,8(a0)
        assert(PageReserved(p));
ffffffffc020155e:	87aa                	mv	a5,a0
ffffffffc0201560:	8b05                	andi	a4,a4,1
ffffffffc0201562:	e709                	bnez	a4,ffffffffc020156c <default_init_memmap+0x24>
ffffffffc0201564:	a07d                	j	ffffffffc0201612 <default_init_memmap+0xca>
ffffffffc0201566:	6798                	ld	a4,8(a5)
ffffffffc0201568:	8b05                	andi	a4,a4,1
ffffffffc020156a:	c745                	beqz	a4,ffffffffc0201612 <default_init_memmap+0xca>
        p->flags = p->property = 0;
ffffffffc020156c:	0007ac23          	sw	zero,24(a5)
ffffffffc0201570:	0007b423          	sd	zero,8(a5)
ffffffffc0201574:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0201578:	04878793          	addi	a5,a5,72
ffffffffc020157c:	fed795e3          	bne	a5,a3,ffffffffc0201566 <default_init_memmap+0x1e>
    base->property = n;
ffffffffc0201580:	2581                	sext.w	a1,a1
ffffffffc0201582:	cd0c                	sw	a1,24(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201584:	4789                	li	a5,2
ffffffffc0201586:	00850713          	addi	a4,a0,8
ffffffffc020158a:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc020158e:	0000f697          	auipc	a3,0xf
ffffffffc0201592:	ef268693          	addi	a3,a3,-270 # ffffffffc0210480 <free_area>
ffffffffc0201596:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0201598:	669c                	ld	a5,8(a3)
ffffffffc020159a:	9db9                	addw	a1,a1,a4
ffffffffc020159c:	0000f717          	auipc	a4,0xf
ffffffffc02015a0:	eeb72a23          	sw	a1,-268(a4) # ffffffffc0210490 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc02015a4:	04d78a63          	beq	a5,a3,ffffffffc02015f8 <default_init_memmap+0xb0>
            struct Page* page = le2page(le, page_link);
ffffffffc02015a8:	fe078713          	addi	a4,a5,-32
ffffffffc02015ac:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc02015ae:	4801                	li	a6,0
ffffffffc02015b0:	02050613          	addi	a2,a0,32
            if (base < page) {
ffffffffc02015b4:	00e56a63          	bltu	a0,a4,ffffffffc02015c8 <default_init_memmap+0x80>
    return listelm->next;
ffffffffc02015b8:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc02015ba:	02d70563          	beq	a4,a3,ffffffffc02015e4 <default_init_memmap+0x9c>
        while ((le = list_next(le)) != &free_list) {
ffffffffc02015be:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc02015c0:	fe078713          	addi	a4,a5,-32
            if (base < page) {
ffffffffc02015c4:	fee57ae3          	bleu	a4,a0,ffffffffc02015b8 <default_init_memmap+0x70>
ffffffffc02015c8:	00080663          	beqz	a6,ffffffffc02015d4 <default_init_memmap+0x8c>
ffffffffc02015cc:	0000f717          	auipc	a4,0xf
ffffffffc02015d0:	eab73a23          	sd	a1,-332(a4) # ffffffffc0210480 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc02015d4:	6398                	ld	a4,0(a5)
}
ffffffffc02015d6:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc02015d8:	e390                	sd	a2,0(a5)
ffffffffc02015da:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc02015dc:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc02015de:	f118                	sd	a4,32(a0)
ffffffffc02015e0:	0141                	addi	sp,sp,16
ffffffffc02015e2:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc02015e4:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02015e6:	f514                	sd	a3,40(a0)
ffffffffc02015e8:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc02015ea:	f11c                	sd	a5,32(a0)
                list_add(le, &(base->page_link));
ffffffffc02015ec:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc02015ee:	00d70e63          	beq	a4,a3,ffffffffc020160a <default_init_memmap+0xc2>
ffffffffc02015f2:	4805                	li	a6,1
ffffffffc02015f4:	87ba                	mv	a5,a4
ffffffffc02015f6:	b7e9                	j	ffffffffc02015c0 <default_init_memmap+0x78>
}
ffffffffc02015f8:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc02015fa:	02050713          	addi	a4,a0,32
    prev->next = next->prev = elm;
ffffffffc02015fe:	e398                	sd	a4,0(a5)
ffffffffc0201600:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc0201602:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc0201604:	f11c                	sd	a5,32(a0)
}
ffffffffc0201606:	0141                	addi	sp,sp,16
ffffffffc0201608:	8082                	ret
ffffffffc020160a:	60a2                	ld	ra,8(sp)
ffffffffc020160c:	e290                	sd	a2,0(a3)
ffffffffc020160e:	0141                	addi	sp,sp,16
ffffffffc0201610:	8082                	ret
        assert(PageReserved(p));
ffffffffc0201612:	00004697          	auipc	a3,0x4
ffffffffc0201616:	81668693          	addi	a3,a3,-2026 # ffffffffc0204e28 <commands+0xbf8>
ffffffffc020161a:	00003617          	auipc	a2,0x3
ffffffffc020161e:	48660613          	addi	a2,a2,1158 # ffffffffc0204aa0 <commands+0x870>
ffffffffc0201622:	04900593          	li	a1,73
ffffffffc0201626:	00003517          	auipc	a0,0x3
ffffffffc020162a:	49250513          	addi	a0,a0,1170 # ffffffffc0204ab8 <commands+0x888>
ffffffffc020162e:	d47fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(n > 0);
ffffffffc0201632:	00003697          	auipc	a3,0x3
ffffffffc0201636:	7ee68693          	addi	a3,a3,2030 # ffffffffc0204e20 <commands+0xbf0>
ffffffffc020163a:	00003617          	auipc	a2,0x3
ffffffffc020163e:	46660613          	addi	a2,a2,1126 # ffffffffc0204aa0 <commands+0x870>
ffffffffc0201642:	04600593          	li	a1,70
ffffffffc0201646:	00003517          	auipc	a0,0x3
ffffffffc020164a:	47250513          	addi	a0,a0,1138 # ffffffffc0204ab8 <commands+0x888>
ffffffffc020164e:	d27fe0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0201652 <pa2page.part.4>:
static inline struct Page *pa2page(uintptr_t pa) {
ffffffffc0201652:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc0201654:	00004617          	auipc	a2,0x4
ffffffffc0201658:	8ac60613          	addi	a2,a2,-1876 # ffffffffc0204f00 <default_pmm_manager+0xc8>
ffffffffc020165c:	06500593          	li	a1,101
ffffffffc0201660:	00004517          	auipc	a0,0x4
ffffffffc0201664:	8c050513          	addi	a0,a0,-1856 # ffffffffc0204f20 <default_pmm_manager+0xe8>
static inline struct Page *pa2page(uintptr_t pa) {
ffffffffc0201668:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc020166a:	d0bfe0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc020166e <alloc_pages>:
    pmm_manager->init_memmap(base, n);
}

// alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE
// memory
struct Page *alloc_pages(size_t n) {
ffffffffc020166e:	715d                	addi	sp,sp,-80
ffffffffc0201670:	e0a2                	sd	s0,64(sp)
ffffffffc0201672:	fc26                	sd	s1,56(sp)
ffffffffc0201674:	f84a                	sd	s2,48(sp)
ffffffffc0201676:	f44e                	sd	s3,40(sp)
ffffffffc0201678:	f052                	sd	s4,32(sp)
ffffffffc020167a:	ec56                	sd	s5,24(sp)
ffffffffc020167c:	e486                	sd	ra,72(sp)
ffffffffc020167e:	842a                	mv	s0,a0
ffffffffc0201680:	0000f497          	auipc	s1,0xf
ffffffffc0201684:	e1848493          	addi	s1,s1,-488 # ffffffffc0210498 <pmm_manager>
    while (1) {
        local_intr_save(intr_flag);
        { page = pmm_manager->alloc_pages(n); }
        local_intr_restore(intr_flag);

        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0201688:	4985                	li	s3,1
ffffffffc020168a:	0000fa17          	auipc	s4,0xf
ffffffffc020168e:	de6a0a13          	addi	s4,s4,-538 # ffffffffc0210470 <swap_init_ok>

        extern struct mm_struct *check_mm_struct;
        // cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
        swap_out(check_mm_struct, n, 0);
ffffffffc0201692:	0005091b          	sext.w	s2,a0
ffffffffc0201696:	0000fa97          	auipc	s5,0xf
ffffffffc020169a:	f02a8a93          	addi	s5,s5,-254 # ffffffffc0210598 <check_mm_struct>
ffffffffc020169e:	a00d                	j	ffffffffc02016c0 <alloc_pages+0x52>
        { page = pmm_manager->alloc_pages(n); }
ffffffffc02016a0:	609c                	ld	a5,0(s1)
ffffffffc02016a2:	6f9c                	ld	a5,24(a5)
ffffffffc02016a4:	9782                	jalr	a5
        swap_out(check_mm_struct, n, 0);
ffffffffc02016a6:	4601                	li	a2,0
ffffffffc02016a8:	85ca                	mv	a1,s2
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc02016aa:	ed0d                	bnez	a0,ffffffffc02016e4 <alloc_pages+0x76>
ffffffffc02016ac:	0289ec63          	bltu	s3,s0,ffffffffc02016e4 <alloc_pages+0x76>
ffffffffc02016b0:	000a2783          	lw	a5,0(s4)
ffffffffc02016b4:	2781                	sext.w	a5,a5
ffffffffc02016b6:	c79d                	beqz	a5,ffffffffc02016e4 <alloc_pages+0x76>
        swap_out(check_mm_struct, n, 0);
ffffffffc02016b8:	000ab503          	ld	a0,0(s5)
ffffffffc02016bc:	021010ef          	jal	ra,ffffffffc0202edc <swap_out>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02016c0:	100027f3          	csrr	a5,sstatus
ffffffffc02016c4:	8b89                	andi	a5,a5,2
        { page = pmm_manager->alloc_pages(n); }
ffffffffc02016c6:	8522                	mv	a0,s0
ffffffffc02016c8:	dfe1                	beqz	a5,ffffffffc02016a0 <alloc_pages+0x32>
        intr_disable();
ffffffffc02016ca:	e0dfe0ef          	jal	ra,ffffffffc02004d6 <intr_disable>
ffffffffc02016ce:	609c                	ld	a5,0(s1)
ffffffffc02016d0:	8522                	mv	a0,s0
ffffffffc02016d2:	6f9c                	ld	a5,24(a5)
ffffffffc02016d4:	9782                	jalr	a5
ffffffffc02016d6:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc02016d8:	df9fe0ef          	jal	ra,ffffffffc02004d0 <intr_enable>
ffffffffc02016dc:	6522                	ld	a0,8(sp)
        swap_out(check_mm_struct, n, 0);
ffffffffc02016de:	4601                	li	a2,0
ffffffffc02016e0:	85ca                	mv	a1,s2
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc02016e2:	d569                	beqz	a0,ffffffffc02016ac <alloc_pages+0x3e>
    }
    // cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
}
ffffffffc02016e4:	60a6                	ld	ra,72(sp)
ffffffffc02016e6:	6406                	ld	s0,64(sp)
ffffffffc02016e8:	74e2                	ld	s1,56(sp)
ffffffffc02016ea:	7942                	ld	s2,48(sp)
ffffffffc02016ec:	79a2                	ld	s3,40(sp)
ffffffffc02016ee:	7a02                	ld	s4,32(sp)
ffffffffc02016f0:	6ae2                	ld	s5,24(sp)
ffffffffc02016f2:	6161                	addi	sp,sp,80
ffffffffc02016f4:	8082                	ret

ffffffffc02016f6 <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02016f6:	100027f3          	csrr	a5,sstatus
ffffffffc02016fa:	8b89                	andi	a5,a5,2
ffffffffc02016fc:	eb89                	bnez	a5,ffffffffc020170e <free_pages+0x18>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;

    local_intr_save(intr_flag);
    { pmm_manager->free_pages(base, n); }
ffffffffc02016fe:	0000f797          	auipc	a5,0xf
ffffffffc0201702:	d9a78793          	addi	a5,a5,-614 # ffffffffc0210498 <pmm_manager>
ffffffffc0201706:	639c                	ld	a5,0(a5)
ffffffffc0201708:	0207b303          	ld	t1,32(a5)
ffffffffc020170c:	8302                	jr	t1
void free_pages(struct Page *base, size_t n) {
ffffffffc020170e:	1101                	addi	sp,sp,-32
ffffffffc0201710:	ec06                	sd	ra,24(sp)
ffffffffc0201712:	e822                	sd	s0,16(sp)
ffffffffc0201714:	e426                	sd	s1,8(sp)
ffffffffc0201716:	842a                	mv	s0,a0
ffffffffc0201718:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc020171a:	dbdfe0ef          	jal	ra,ffffffffc02004d6 <intr_disable>
    { pmm_manager->free_pages(base, n); }
ffffffffc020171e:	0000f797          	auipc	a5,0xf
ffffffffc0201722:	d7a78793          	addi	a5,a5,-646 # ffffffffc0210498 <pmm_manager>
ffffffffc0201726:	639c                	ld	a5,0(a5)
ffffffffc0201728:	85a6                	mv	a1,s1
ffffffffc020172a:	8522                	mv	a0,s0
ffffffffc020172c:	739c                	ld	a5,32(a5)
ffffffffc020172e:	9782                	jalr	a5
    local_intr_restore(intr_flag);
}
ffffffffc0201730:	6442                	ld	s0,16(sp)
ffffffffc0201732:	60e2                	ld	ra,24(sp)
ffffffffc0201734:	64a2                	ld	s1,8(sp)
ffffffffc0201736:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0201738:	d99fe06f          	j	ffffffffc02004d0 <intr_enable>

ffffffffc020173c <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020173c:	100027f3          	csrr	a5,sstatus
ffffffffc0201740:	8b89                	andi	a5,a5,2
ffffffffc0201742:	eb89                	bnez	a5,ffffffffc0201754 <nr_free_pages+0x18>
// of current free memory
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc0201744:	0000f797          	auipc	a5,0xf
ffffffffc0201748:	d5478793          	addi	a5,a5,-684 # ffffffffc0210498 <pmm_manager>
ffffffffc020174c:	639c                	ld	a5,0(a5)
ffffffffc020174e:	0287b303          	ld	t1,40(a5)
ffffffffc0201752:	8302                	jr	t1
size_t nr_free_pages(void) {
ffffffffc0201754:	1141                	addi	sp,sp,-16
ffffffffc0201756:	e406                	sd	ra,8(sp)
ffffffffc0201758:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc020175a:	d7dfe0ef          	jal	ra,ffffffffc02004d6 <intr_disable>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc020175e:	0000f797          	auipc	a5,0xf
ffffffffc0201762:	d3a78793          	addi	a5,a5,-710 # ffffffffc0210498 <pmm_manager>
ffffffffc0201766:	639c                	ld	a5,0(a5)
ffffffffc0201768:	779c                	ld	a5,40(a5)
ffffffffc020176a:	9782                	jalr	a5
ffffffffc020176c:	842a                	mv	s0,a0
        intr_enable();
ffffffffc020176e:	d63fe0ef          	jal	ra,ffffffffc02004d0 <intr_enable>
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc0201772:	8522                	mv	a0,s0
ffffffffc0201774:	60a2                	ld	ra,8(sp)
ffffffffc0201776:	6402                	ld	s0,0(sp)
ffffffffc0201778:	0141                	addi	sp,sp,16
ffffffffc020177a:	8082                	ret

ffffffffc020177c <get_pte>:
// parameter:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc020177c:	715d                	addi	sp,sp,-80
ffffffffc020177e:	fc26                	sd	s1,56(sp)
     *   PTE_W           0x002                   // page table/directory entry
     * flags bit : Writeable
     *   PTE_U           0x004                   // page table/directory entry
     * flags bit : User can access
     */
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0201780:	01e5d493          	srli	s1,a1,0x1e
ffffffffc0201784:	1ff4f493          	andi	s1,s1,511
ffffffffc0201788:	048e                	slli	s1,s1,0x3
ffffffffc020178a:	94aa                	add	s1,s1,a0
    if (!(*pdep1 & PTE_V)) {
ffffffffc020178c:	6094                	ld	a3,0(s1)
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc020178e:	f84a                	sd	s2,48(sp)
ffffffffc0201790:	f44e                	sd	s3,40(sp)
ffffffffc0201792:	f052                	sd	s4,32(sp)
ffffffffc0201794:	e486                	sd	ra,72(sp)
ffffffffc0201796:	e0a2                	sd	s0,64(sp)
ffffffffc0201798:	ec56                	sd	s5,24(sp)
ffffffffc020179a:	e85a                	sd	s6,16(sp)
ffffffffc020179c:	e45e                	sd	s7,8(sp)
    if (!(*pdep1 & PTE_V)) {
ffffffffc020179e:	0016f793          	andi	a5,a3,1
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc02017a2:	892e                	mv	s2,a1
ffffffffc02017a4:	8a32                	mv	s4,a2
ffffffffc02017a6:	0000f997          	auipc	s3,0xf
ffffffffc02017aa:	cba98993          	addi	s3,s3,-838 # ffffffffc0210460 <npage>
    if (!(*pdep1 & PTE_V)) {
ffffffffc02017ae:	e3c9                	bnez	a5,ffffffffc0201830 <get_pte+0xb4>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc02017b0:	16060163          	beqz	a2,ffffffffc0201912 <get_pte+0x196>
ffffffffc02017b4:	4505                	li	a0,1
ffffffffc02017b6:	eb9ff0ef          	jal	ra,ffffffffc020166e <alloc_pages>
ffffffffc02017ba:	842a                	mv	s0,a0
ffffffffc02017bc:	14050b63          	beqz	a0,ffffffffc0201912 <get_pte+0x196>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02017c0:	0000fb97          	auipc	s7,0xf
ffffffffc02017c4:	cf0b8b93          	addi	s7,s7,-784 # ffffffffc02104b0 <pages>
ffffffffc02017c8:	000bb503          	ld	a0,0(s7)
ffffffffc02017cc:	00003797          	auipc	a5,0x3
ffffffffc02017d0:	2bc78793          	addi	a5,a5,700 # ffffffffc0204a88 <commands+0x858>
ffffffffc02017d4:	0007bb03          	ld	s6,0(a5)
ffffffffc02017d8:	40a40533          	sub	a0,s0,a0
ffffffffc02017dc:	850d                	srai	a0,a0,0x3
ffffffffc02017de:	03650533          	mul	a0,a0,s6
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc02017e2:	4785                	li	a5,1
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc02017e4:	0000f997          	auipc	s3,0xf
ffffffffc02017e8:	c7c98993          	addi	s3,s3,-900 # ffffffffc0210460 <npage>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02017ec:	00080ab7          	lui	s5,0x80
ffffffffc02017f0:	0009b703          	ld	a4,0(s3)
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc02017f4:	c01c                	sw	a5,0(s0)
ffffffffc02017f6:	57fd                	li	a5,-1
ffffffffc02017f8:	83b1                	srli	a5,a5,0xc
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02017fa:	9556                	add	a0,a0,s5
ffffffffc02017fc:	8fe9                	and	a5,a5,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc02017fe:	0532                	slli	a0,a0,0xc
ffffffffc0201800:	16e7f063          	bleu	a4,a5,ffffffffc0201960 <get_pte+0x1e4>
ffffffffc0201804:	0000f797          	auipc	a5,0xf
ffffffffc0201808:	c9c78793          	addi	a5,a5,-868 # ffffffffc02104a0 <va_pa_offset>
ffffffffc020180c:	639c                	ld	a5,0(a5)
ffffffffc020180e:	6605                	lui	a2,0x1
ffffffffc0201810:	4581                	li	a1,0
ffffffffc0201812:	953e                	add	a0,a0,a5
ffffffffc0201814:	0cb020ef          	jal	ra,ffffffffc02040de <memset>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201818:	000bb683          	ld	a3,0(s7)
ffffffffc020181c:	40d406b3          	sub	a3,s0,a3
ffffffffc0201820:	868d                	srai	a3,a3,0x3
ffffffffc0201822:	036686b3          	mul	a3,a3,s6
ffffffffc0201826:	96d6                	add	a3,a3,s5

static inline void flush_tlb() { asm volatile("sfence.vma"); }

// construct PTE from a page and permission bits
static inline pte_t pte_create(uintptr_t ppn, int type) {
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0201828:	06aa                	slli	a3,a3,0xa
ffffffffc020182a:	0116e693          	ori	a3,a3,17
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc020182e:	e094                	sd	a3,0(s1)
    }
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0201830:	77fd                	lui	a5,0xfffff
ffffffffc0201832:	068a                	slli	a3,a3,0x2
ffffffffc0201834:	0009b703          	ld	a4,0(s3)
ffffffffc0201838:	8efd                	and	a3,a3,a5
ffffffffc020183a:	00c6d793          	srli	a5,a3,0xc
ffffffffc020183e:	0ce7fc63          	bleu	a4,a5,ffffffffc0201916 <get_pte+0x19a>
ffffffffc0201842:	0000fa97          	auipc	s5,0xf
ffffffffc0201846:	c5ea8a93          	addi	s5,s5,-930 # ffffffffc02104a0 <va_pa_offset>
ffffffffc020184a:	000ab403          	ld	s0,0(s5)
ffffffffc020184e:	01595793          	srli	a5,s2,0x15
ffffffffc0201852:	1ff7f793          	andi	a5,a5,511
ffffffffc0201856:	96a2                	add	a3,a3,s0
ffffffffc0201858:	00379413          	slli	s0,a5,0x3
ffffffffc020185c:	9436                	add	s0,s0,a3
//    pde_t *pdep0 = &((pde_t *)(PDE_ADDR(*pdep1)))[PDX0(la)];
    if (!(*pdep0 & PTE_V)) {
ffffffffc020185e:	6014                	ld	a3,0(s0)
ffffffffc0201860:	0016f793          	andi	a5,a3,1
ffffffffc0201864:	ebbd                	bnez	a5,ffffffffc02018da <get_pte+0x15e>
    	struct Page *page;
    	if (!create || (page = alloc_page()) == NULL) {
ffffffffc0201866:	0a0a0663          	beqz	s4,ffffffffc0201912 <get_pte+0x196>
ffffffffc020186a:	4505                	li	a0,1
ffffffffc020186c:	e03ff0ef          	jal	ra,ffffffffc020166e <alloc_pages>
ffffffffc0201870:	84aa                	mv	s1,a0
ffffffffc0201872:	c145                	beqz	a0,ffffffffc0201912 <get_pte+0x196>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201874:	0000fb97          	auipc	s7,0xf
ffffffffc0201878:	c3cb8b93          	addi	s7,s7,-964 # ffffffffc02104b0 <pages>
ffffffffc020187c:	000bb503          	ld	a0,0(s7)
ffffffffc0201880:	00003797          	auipc	a5,0x3
ffffffffc0201884:	20878793          	addi	a5,a5,520 # ffffffffc0204a88 <commands+0x858>
ffffffffc0201888:	0007bb03          	ld	s6,0(a5)
ffffffffc020188c:	40a48533          	sub	a0,s1,a0
ffffffffc0201890:	850d                	srai	a0,a0,0x3
ffffffffc0201892:	03650533          	mul	a0,a0,s6
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0201896:	4785                	li	a5,1
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201898:	00080a37          	lui	s4,0x80
    		return NULL;
    	}
    	set_page_ref(page, 1);
    	uintptr_t pa = page2pa(page);
    	memset(KADDR(pa), 0, PGSIZE);
ffffffffc020189c:	0009b703          	ld	a4,0(s3)
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc02018a0:	c09c                	sw	a5,0(s1)
ffffffffc02018a2:	57fd                	li	a5,-1
ffffffffc02018a4:	83b1                	srli	a5,a5,0xc
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02018a6:	9552                	add	a0,a0,s4
ffffffffc02018a8:	8fe9                	and	a5,a5,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc02018aa:	0532                	slli	a0,a0,0xc
ffffffffc02018ac:	08e7fd63          	bleu	a4,a5,ffffffffc0201946 <get_pte+0x1ca>
ffffffffc02018b0:	000ab783          	ld	a5,0(s5)
ffffffffc02018b4:	6605                	lui	a2,0x1
ffffffffc02018b6:	4581                	li	a1,0
ffffffffc02018b8:	953e                	add	a0,a0,a5
ffffffffc02018ba:	025020ef          	jal	ra,ffffffffc02040de <memset>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02018be:	000bb683          	ld	a3,0(s7)
ffffffffc02018c2:	40d486b3          	sub	a3,s1,a3
ffffffffc02018c6:	868d                	srai	a3,a3,0x3
ffffffffc02018c8:	036686b3          	mul	a3,a3,s6
ffffffffc02018cc:	96d2                	add	a3,a3,s4
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc02018ce:	06aa                	slli	a3,a3,0xa
ffffffffc02018d0:	0116e693          	ori	a3,a3,17
 //   	memset(pa, 0, PGSIZE);
    	*pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc02018d4:	e014                	sd	a3,0(s0)
ffffffffc02018d6:	0009b703          	ld	a4,0(s3)
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc02018da:	068a                	slli	a3,a3,0x2
ffffffffc02018dc:	757d                	lui	a0,0xfffff
ffffffffc02018de:	8ee9                	and	a3,a3,a0
ffffffffc02018e0:	00c6d793          	srli	a5,a3,0xc
ffffffffc02018e4:	04e7f563          	bleu	a4,a5,ffffffffc020192e <get_pte+0x1b2>
ffffffffc02018e8:	000ab503          	ld	a0,0(s5)
ffffffffc02018ec:	00c95793          	srli	a5,s2,0xc
ffffffffc02018f0:	1ff7f793          	andi	a5,a5,511
ffffffffc02018f4:	96aa                	add	a3,a3,a0
ffffffffc02018f6:	00379513          	slli	a0,a5,0x3
ffffffffc02018fa:	9536                	add	a0,a0,a3
}
ffffffffc02018fc:	60a6                	ld	ra,72(sp)
ffffffffc02018fe:	6406                	ld	s0,64(sp)
ffffffffc0201900:	74e2                	ld	s1,56(sp)
ffffffffc0201902:	7942                	ld	s2,48(sp)
ffffffffc0201904:	79a2                	ld	s3,40(sp)
ffffffffc0201906:	7a02                	ld	s4,32(sp)
ffffffffc0201908:	6ae2                	ld	s5,24(sp)
ffffffffc020190a:	6b42                	ld	s6,16(sp)
ffffffffc020190c:	6ba2                	ld	s7,8(sp)
ffffffffc020190e:	6161                	addi	sp,sp,80
ffffffffc0201910:	8082                	ret
            return NULL;
ffffffffc0201912:	4501                	li	a0,0
ffffffffc0201914:	b7e5                	j	ffffffffc02018fc <get_pte+0x180>
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0201916:	00003617          	auipc	a2,0x3
ffffffffc020191a:	57260613          	addi	a2,a2,1394 # ffffffffc0204e88 <default_pmm_manager+0x50>
ffffffffc020191e:	10200593          	li	a1,258
ffffffffc0201922:	00003517          	auipc	a0,0x3
ffffffffc0201926:	58e50513          	addi	a0,a0,1422 # ffffffffc0204eb0 <default_pmm_manager+0x78>
ffffffffc020192a:	a4bfe0ef          	jal	ra,ffffffffc0200374 <__panic>
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc020192e:	00003617          	auipc	a2,0x3
ffffffffc0201932:	55a60613          	addi	a2,a2,1370 # ffffffffc0204e88 <default_pmm_manager+0x50>
ffffffffc0201936:	10f00593          	li	a1,271
ffffffffc020193a:	00003517          	auipc	a0,0x3
ffffffffc020193e:	57650513          	addi	a0,a0,1398 # ffffffffc0204eb0 <default_pmm_manager+0x78>
ffffffffc0201942:	a33fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    	memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201946:	86aa                	mv	a3,a0
ffffffffc0201948:	00003617          	auipc	a2,0x3
ffffffffc020194c:	54060613          	addi	a2,a2,1344 # ffffffffc0204e88 <default_pmm_manager+0x50>
ffffffffc0201950:	10b00593          	li	a1,267
ffffffffc0201954:	00003517          	auipc	a0,0x3
ffffffffc0201958:	55c50513          	addi	a0,a0,1372 # ffffffffc0204eb0 <default_pmm_manager+0x78>
ffffffffc020195c:	a19fe0ef          	jal	ra,ffffffffc0200374 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201960:	86aa                	mv	a3,a0
ffffffffc0201962:	00003617          	auipc	a2,0x3
ffffffffc0201966:	52660613          	addi	a2,a2,1318 # ffffffffc0204e88 <default_pmm_manager+0x50>
ffffffffc020196a:	0ff00593          	li	a1,255
ffffffffc020196e:	00003517          	auipc	a0,0x3
ffffffffc0201972:	54250513          	addi	a0,a0,1346 # ffffffffc0204eb0 <default_pmm_manager+0x78>
ffffffffc0201976:	9fffe0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc020197a <get_page>:

// get_page - get related Page struct for linear address la using PDT pgdir
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc020197a:	1141                	addi	sp,sp,-16
ffffffffc020197c:	e022                	sd	s0,0(sp)
ffffffffc020197e:	8432                	mv	s0,a2
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201980:	4601                	li	a2,0
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc0201982:	e406                	sd	ra,8(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201984:	df9ff0ef          	jal	ra,ffffffffc020177c <get_pte>
    if (ptep_store != NULL) {
ffffffffc0201988:	c011                	beqz	s0,ffffffffc020198c <get_page+0x12>
        *ptep_store = ptep;
ffffffffc020198a:	e008                	sd	a0,0(s0)
    }
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc020198c:	c521                	beqz	a0,ffffffffc02019d4 <get_page+0x5a>
ffffffffc020198e:	611c                	ld	a5,0(a0)
        return pte2page(*ptep);
    }
    return NULL;
ffffffffc0201990:	4501                	li	a0,0
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc0201992:	0017f713          	andi	a4,a5,1
ffffffffc0201996:	e709                	bnez	a4,ffffffffc02019a0 <get_page+0x26>
}
ffffffffc0201998:	60a2                	ld	ra,8(sp)
ffffffffc020199a:	6402                	ld	s0,0(sp)
ffffffffc020199c:	0141                	addi	sp,sp,16
ffffffffc020199e:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc02019a0:	0000f717          	auipc	a4,0xf
ffffffffc02019a4:	ac070713          	addi	a4,a4,-1344 # ffffffffc0210460 <npage>
ffffffffc02019a8:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc02019aa:	078a                	slli	a5,a5,0x2
ffffffffc02019ac:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02019ae:	02e7f863          	bleu	a4,a5,ffffffffc02019de <get_page+0x64>
    return &pages[PPN(pa) - nbase];
ffffffffc02019b2:	fff80537          	lui	a0,0xfff80
ffffffffc02019b6:	97aa                	add	a5,a5,a0
ffffffffc02019b8:	0000f697          	auipc	a3,0xf
ffffffffc02019bc:	af868693          	addi	a3,a3,-1288 # ffffffffc02104b0 <pages>
ffffffffc02019c0:	6288                	ld	a0,0(a3)
ffffffffc02019c2:	60a2                	ld	ra,8(sp)
ffffffffc02019c4:	6402                	ld	s0,0(sp)
ffffffffc02019c6:	00379713          	slli	a4,a5,0x3
ffffffffc02019ca:	97ba                	add	a5,a5,a4
ffffffffc02019cc:	078e                	slli	a5,a5,0x3
ffffffffc02019ce:	953e                	add	a0,a0,a5
ffffffffc02019d0:	0141                	addi	sp,sp,16
ffffffffc02019d2:	8082                	ret
ffffffffc02019d4:	60a2                	ld	ra,8(sp)
ffffffffc02019d6:	6402                	ld	s0,0(sp)
    return NULL;
ffffffffc02019d8:	4501                	li	a0,0
}
ffffffffc02019da:	0141                	addi	sp,sp,16
ffffffffc02019dc:	8082                	ret
ffffffffc02019de:	c75ff0ef          	jal	ra,ffffffffc0201652 <pa2page.part.4>

ffffffffc02019e2 <page_remove>:
    }
}

// page_remove - free an Page which is related linear address la and has an
// validated pte
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc02019e2:	1141                	addi	sp,sp,-16
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc02019e4:	4601                	li	a2,0
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc02019e6:	e406                	sd	ra,8(sp)
ffffffffc02019e8:	e022                	sd	s0,0(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc02019ea:	d93ff0ef          	jal	ra,ffffffffc020177c <get_pte>
    if (ptep != NULL) {
ffffffffc02019ee:	c511                	beqz	a0,ffffffffc02019fa <page_remove+0x18>
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc02019f0:	611c                	ld	a5,0(a0)
ffffffffc02019f2:	842a                	mv	s0,a0
ffffffffc02019f4:	0017f713          	andi	a4,a5,1
ffffffffc02019f8:	e709                	bnez	a4,ffffffffc0201a02 <page_remove+0x20>
        page_remove_pte(pgdir, la, ptep);
    }
}
ffffffffc02019fa:	60a2                	ld	ra,8(sp)
ffffffffc02019fc:	6402                	ld	s0,0(sp)
ffffffffc02019fe:	0141                	addi	sp,sp,16
ffffffffc0201a00:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc0201a02:	0000f717          	auipc	a4,0xf
ffffffffc0201a06:	a5e70713          	addi	a4,a4,-1442 # ffffffffc0210460 <npage>
ffffffffc0201a0a:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc0201a0c:	078a                	slli	a5,a5,0x2
ffffffffc0201a0e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201a10:	04e7f063          	bleu	a4,a5,ffffffffc0201a50 <page_remove+0x6e>
    return &pages[PPN(pa) - nbase];
ffffffffc0201a14:	fff80737          	lui	a4,0xfff80
ffffffffc0201a18:	97ba                	add	a5,a5,a4
ffffffffc0201a1a:	0000f717          	auipc	a4,0xf
ffffffffc0201a1e:	a9670713          	addi	a4,a4,-1386 # ffffffffc02104b0 <pages>
ffffffffc0201a22:	6308                	ld	a0,0(a4)
ffffffffc0201a24:	00379713          	slli	a4,a5,0x3
ffffffffc0201a28:	97ba                	add	a5,a5,a4
ffffffffc0201a2a:	078e                	slli	a5,a5,0x3
ffffffffc0201a2c:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc0201a2e:	411c                	lw	a5,0(a0)
ffffffffc0201a30:	fff7871b          	addiw	a4,a5,-1
ffffffffc0201a34:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc0201a36:	cb09                	beqz	a4,ffffffffc0201a48 <page_remove+0x66>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc0201a38:	00043023          	sd	zero,0(s0)
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc0201a3c:	12000073          	sfence.vma
}
ffffffffc0201a40:	60a2                	ld	ra,8(sp)
ffffffffc0201a42:	6402                	ld	s0,0(sp)
ffffffffc0201a44:	0141                	addi	sp,sp,16
ffffffffc0201a46:	8082                	ret
            free_page(page);
ffffffffc0201a48:	4585                	li	a1,1
ffffffffc0201a4a:	cadff0ef          	jal	ra,ffffffffc02016f6 <free_pages>
ffffffffc0201a4e:	b7ed                	j	ffffffffc0201a38 <page_remove+0x56>
ffffffffc0201a50:	c03ff0ef          	jal	ra,ffffffffc0201652 <pa2page.part.4>

ffffffffc0201a54 <page_insert>:
//  page:  the Page which need to map
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
// note: PT is changed, so the TLB need to be invalidate
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0201a54:	7179                	addi	sp,sp,-48
ffffffffc0201a56:	87b2                	mv	a5,a2
ffffffffc0201a58:	f022                	sd	s0,32(sp)
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0201a5a:	4605                	li	a2,1
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0201a5c:	842e                	mv	s0,a1
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0201a5e:	85be                	mv	a1,a5
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0201a60:	ec26                	sd	s1,24(sp)
ffffffffc0201a62:	f406                	sd	ra,40(sp)
ffffffffc0201a64:	e84a                	sd	s2,16(sp)
ffffffffc0201a66:	e44e                	sd	s3,8(sp)
ffffffffc0201a68:	84b6                	mv	s1,a3
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0201a6a:	d13ff0ef          	jal	ra,ffffffffc020177c <get_pte>
    if (ptep == NULL) {
ffffffffc0201a6e:	c945                	beqz	a0,ffffffffc0201b1e <page_insert+0xca>
    page->ref += 1;
ffffffffc0201a70:	4014                	lw	a3,0(s0)
        return -E_NO_MEM;
    }
    page_ref_inc(page);
    if (*ptep & PTE_V) {
ffffffffc0201a72:	611c                	ld	a5,0(a0)
ffffffffc0201a74:	892a                	mv	s2,a0
ffffffffc0201a76:	0016871b          	addiw	a4,a3,1
ffffffffc0201a7a:	c018                	sw	a4,0(s0)
ffffffffc0201a7c:	0017f713          	andi	a4,a5,1
ffffffffc0201a80:	e339                	bnez	a4,ffffffffc0201ac6 <page_insert+0x72>
ffffffffc0201a82:	0000f797          	auipc	a5,0xf
ffffffffc0201a86:	a2e78793          	addi	a5,a5,-1490 # ffffffffc02104b0 <pages>
ffffffffc0201a8a:	639c                	ld	a5,0(a5)
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201a8c:	00003717          	auipc	a4,0x3
ffffffffc0201a90:	ffc70713          	addi	a4,a4,-4 # ffffffffc0204a88 <commands+0x858>
ffffffffc0201a94:	40f407b3          	sub	a5,s0,a5
ffffffffc0201a98:	6300                	ld	s0,0(a4)
ffffffffc0201a9a:	878d                	srai	a5,a5,0x3
ffffffffc0201a9c:	000806b7          	lui	a3,0x80
ffffffffc0201aa0:	028787b3          	mul	a5,a5,s0
ffffffffc0201aa4:	97b6                	add	a5,a5,a3
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0201aa6:	07aa                	slli	a5,a5,0xa
ffffffffc0201aa8:	8fc5                	or	a5,a5,s1
ffffffffc0201aaa:	0017e793          	ori	a5,a5,1
            page_ref_dec(page);
        } else {
            page_remove_pte(pgdir, la, ptep);
        }
    }
    *ptep = pte_create(page2ppn(page), PTE_V | perm);
ffffffffc0201aae:	00f93023          	sd	a5,0(s2)
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc0201ab2:	12000073          	sfence.vma
    tlb_invalidate(pgdir, la);
    return 0;
ffffffffc0201ab6:	4501                	li	a0,0
}
ffffffffc0201ab8:	70a2                	ld	ra,40(sp)
ffffffffc0201aba:	7402                	ld	s0,32(sp)
ffffffffc0201abc:	64e2                	ld	s1,24(sp)
ffffffffc0201abe:	6942                	ld	s2,16(sp)
ffffffffc0201ac0:	69a2                	ld	s3,8(sp)
ffffffffc0201ac2:	6145                	addi	sp,sp,48
ffffffffc0201ac4:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc0201ac6:	0000f717          	auipc	a4,0xf
ffffffffc0201aca:	99a70713          	addi	a4,a4,-1638 # ffffffffc0210460 <npage>
ffffffffc0201ace:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc0201ad0:	00279513          	slli	a0,a5,0x2
ffffffffc0201ad4:	8131                	srli	a0,a0,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201ad6:	04e57663          	bleu	a4,a0,ffffffffc0201b22 <page_insert+0xce>
    return &pages[PPN(pa) - nbase];
ffffffffc0201ada:	fff807b7          	lui	a5,0xfff80
ffffffffc0201ade:	953e                	add	a0,a0,a5
ffffffffc0201ae0:	0000f997          	auipc	s3,0xf
ffffffffc0201ae4:	9d098993          	addi	s3,s3,-1584 # ffffffffc02104b0 <pages>
ffffffffc0201ae8:	0009b783          	ld	a5,0(s3)
ffffffffc0201aec:	00351713          	slli	a4,a0,0x3
ffffffffc0201af0:	953a                	add	a0,a0,a4
ffffffffc0201af2:	050e                	slli	a0,a0,0x3
ffffffffc0201af4:	953e                	add	a0,a0,a5
        if (p == page) {
ffffffffc0201af6:	00a40e63          	beq	s0,a0,ffffffffc0201b12 <page_insert+0xbe>
    page->ref -= 1;
ffffffffc0201afa:	411c                	lw	a5,0(a0)
ffffffffc0201afc:	fff7871b          	addiw	a4,a5,-1
ffffffffc0201b00:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc0201b02:	cb11                	beqz	a4,ffffffffc0201b16 <page_insert+0xc2>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc0201b04:	00093023          	sd	zero,0(s2)
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc0201b08:	12000073          	sfence.vma
ffffffffc0201b0c:	0009b783          	ld	a5,0(s3)
ffffffffc0201b10:	bfb5                	j	ffffffffc0201a8c <page_insert+0x38>
    page->ref -= 1;
ffffffffc0201b12:	c014                	sw	a3,0(s0)
    return page->ref;
ffffffffc0201b14:	bfa5                	j	ffffffffc0201a8c <page_insert+0x38>
            free_page(page);
ffffffffc0201b16:	4585                	li	a1,1
ffffffffc0201b18:	bdfff0ef          	jal	ra,ffffffffc02016f6 <free_pages>
ffffffffc0201b1c:	b7e5                	j	ffffffffc0201b04 <page_insert+0xb0>
        return -E_NO_MEM;
ffffffffc0201b1e:	5571                	li	a0,-4
ffffffffc0201b20:	bf61                	j	ffffffffc0201ab8 <page_insert+0x64>
ffffffffc0201b22:	b31ff0ef          	jal	ra,ffffffffc0201652 <pa2page.part.4>

ffffffffc0201b26 <pmm_init>:
    pmm_manager = &default_pmm_manager;
ffffffffc0201b26:	00003797          	auipc	a5,0x3
ffffffffc0201b2a:	31278793          	addi	a5,a5,786 # ffffffffc0204e38 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201b2e:	638c                	ld	a1,0(a5)
void pmm_init(void) {
ffffffffc0201b30:	711d                	addi	sp,sp,-96
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201b32:	00003517          	auipc	a0,0x3
ffffffffc0201b36:	41650513          	addi	a0,a0,1046 # ffffffffc0204f48 <default_pmm_manager+0x110>
void pmm_init(void) {
ffffffffc0201b3a:	ec86                	sd	ra,88(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc0201b3c:	0000f717          	auipc	a4,0xf
ffffffffc0201b40:	94f73e23          	sd	a5,-1700(a4) # ffffffffc0210498 <pmm_manager>
void pmm_init(void) {
ffffffffc0201b44:	e8a2                	sd	s0,80(sp)
ffffffffc0201b46:	e4a6                	sd	s1,72(sp)
ffffffffc0201b48:	e0ca                	sd	s2,64(sp)
ffffffffc0201b4a:	fc4e                	sd	s3,56(sp)
ffffffffc0201b4c:	f852                	sd	s4,48(sp)
ffffffffc0201b4e:	f456                	sd	s5,40(sp)
ffffffffc0201b50:	f05a                	sd	s6,32(sp)
ffffffffc0201b52:	ec5e                	sd	s7,24(sp)
ffffffffc0201b54:	e862                	sd	s8,16(sp)
ffffffffc0201b56:	e466                	sd	s9,8(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc0201b58:	0000f417          	auipc	s0,0xf
ffffffffc0201b5c:	94040413          	addi	s0,s0,-1728 # ffffffffc0210498 <pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201b60:	d5efe0ef          	jal	ra,ffffffffc02000be <cprintf>
    pmm_manager->init();
ffffffffc0201b64:	601c                	ld	a5,0(s0)
    cprintf("membegin %llx memend %llx mem_size %llx\n",mem_begin, mem_end, mem_size);
ffffffffc0201b66:	49c5                	li	s3,17
ffffffffc0201b68:	40100a13          	li	s4,1025
    pmm_manager->init();
ffffffffc0201b6c:	679c                	ld	a5,8(a5)
ffffffffc0201b6e:	0000f497          	auipc	s1,0xf
ffffffffc0201b72:	8f248493          	addi	s1,s1,-1806 # ffffffffc0210460 <npage>
ffffffffc0201b76:	0000f917          	auipc	s2,0xf
ffffffffc0201b7a:	93a90913          	addi	s2,s2,-1734 # ffffffffc02104b0 <pages>
ffffffffc0201b7e:	9782                	jalr	a5
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0201b80:	57f5                	li	a5,-3
ffffffffc0201b82:	07fa                	slli	a5,a5,0x1e
    cprintf("membegin %llx memend %llx mem_size %llx\n",mem_begin, mem_end, mem_size);
ffffffffc0201b84:	07e006b7          	lui	a3,0x7e00
ffffffffc0201b88:	01b99613          	slli	a2,s3,0x1b
ffffffffc0201b8c:	015a1593          	slli	a1,s4,0x15
ffffffffc0201b90:	00003517          	auipc	a0,0x3
ffffffffc0201b94:	3d050513          	addi	a0,a0,976 # ffffffffc0204f60 <default_pmm_manager+0x128>
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0201b98:	0000f717          	auipc	a4,0xf
ffffffffc0201b9c:	90f73423          	sd	a5,-1784(a4) # ffffffffc02104a0 <va_pa_offset>
    cprintf("membegin %llx memend %llx mem_size %llx\n",mem_begin, mem_end, mem_size);
ffffffffc0201ba0:	d1efe0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("physcial memory map:\n");
ffffffffc0201ba4:	00003517          	auipc	a0,0x3
ffffffffc0201ba8:	3ec50513          	addi	a0,a0,1004 # ffffffffc0204f90 <default_pmm_manager+0x158>
ffffffffc0201bac:	d12fe0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin,
ffffffffc0201bb0:	01b99693          	slli	a3,s3,0x1b
ffffffffc0201bb4:	16fd                	addi	a3,a3,-1
ffffffffc0201bb6:	015a1613          	slli	a2,s4,0x15
ffffffffc0201bba:	07e005b7          	lui	a1,0x7e00
ffffffffc0201bbe:	00003517          	auipc	a0,0x3
ffffffffc0201bc2:	3ea50513          	addi	a0,a0,1002 # ffffffffc0204fa8 <default_pmm_manager+0x170>
ffffffffc0201bc6:	cf8fe0ef          	jal	ra,ffffffffc02000be <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201bca:	777d                	lui	a4,0xfffff
ffffffffc0201bcc:	00010797          	auipc	a5,0x10
ffffffffc0201bd0:	9d378793          	addi	a5,a5,-1581 # ffffffffc021159f <end+0xfff>
ffffffffc0201bd4:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc0201bd6:	00088737          	lui	a4,0x88
ffffffffc0201bda:	0000f697          	auipc	a3,0xf
ffffffffc0201bde:	88e6b323          	sd	a4,-1914(a3) # ffffffffc0210460 <npage>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201be2:	0000f717          	auipc	a4,0xf
ffffffffc0201be6:	8cf73723          	sd	a5,-1842(a4) # ffffffffc02104b0 <pages>
ffffffffc0201bea:	4681                	li	a3,0
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201bec:	4701                	li	a4,0
ffffffffc0201bee:	4585                	li	a1,1
ffffffffc0201bf0:	fff80637          	lui	a2,0xfff80
ffffffffc0201bf4:	a019                	j	ffffffffc0201bfa <pmm_init+0xd4>
ffffffffc0201bf6:	00093783          	ld	a5,0(s2)
        SetPageReserved(pages + i);
ffffffffc0201bfa:	97b6                	add	a5,a5,a3
ffffffffc0201bfc:	07a1                	addi	a5,a5,8
ffffffffc0201bfe:	40b7b02f          	amoor.d	zero,a1,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201c02:	609c                	ld	a5,0(s1)
ffffffffc0201c04:	0705                	addi	a4,a4,1
ffffffffc0201c06:	04868693          	addi	a3,a3,72
ffffffffc0201c0a:	00c78533          	add	a0,a5,a2
ffffffffc0201c0e:	fea764e3          	bltu	a4,a0,ffffffffc0201bf6 <pmm_init+0xd0>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201c12:	00093503          	ld	a0,0(s2)
ffffffffc0201c16:	00379693          	slli	a3,a5,0x3
ffffffffc0201c1a:	96be                	add	a3,a3,a5
ffffffffc0201c1c:	fdc00737          	lui	a4,0xfdc00
ffffffffc0201c20:	972a                	add	a4,a4,a0
ffffffffc0201c22:	068e                	slli	a3,a3,0x3
ffffffffc0201c24:	96ba                	add	a3,a3,a4
ffffffffc0201c26:	c0200737          	lui	a4,0xc0200
ffffffffc0201c2a:	58e6ea63          	bltu	a3,a4,ffffffffc02021be <pmm_init+0x698>
ffffffffc0201c2e:	0000f997          	auipc	s3,0xf
ffffffffc0201c32:	87298993          	addi	s3,s3,-1934 # ffffffffc02104a0 <va_pa_offset>
ffffffffc0201c36:	0009b703          	ld	a4,0(s3)
    if (freemem < mem_end) {
ffffffffc0201c3a:	45c5                	li	a1,17
ffffffffc0201c3c:	05ee                	slli	a1,a1,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201c3e:	8e99                	sub	a3,a3,a4
    if (freemem < mem_end) {
ffffffffc0201c40:	44b6ef63          	bltu	a3,a1,ffffffffc020209e <pmm_init+0x578>

    return page;
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc0201c44:	601c                	ld	a5,0(s0)
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0201c46:	0000f417          	auipc	s0,0xf
ffffffffc0201c4a:	81240413          	addi	s0,s0,-2030 # ffffffffc0210458 <boot_pgdir>
    pmm_manager->check();
ffffffffc0201c4e:	7b9c                	ld	a5,48(a5)
ffffffffc0201c50:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0201c52:	00003517          	auipc	a0,0x3
ffffffffc0201c56:	3a650513          	addi	a0,a0,934 # ffffffffc0204ff8 <default_pmm_manager+0x1c0>
ffffffffc0201c5a:	c64fe0ef          	jal	ra,ffffffffc02000be <cprintf>
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0201c5e:	00006697          	auipc	a3,0x6
ffffffffc0201c62:	3a268693          	addi	a3,a3,930 # ffffffffc0208000 <boot_page_table_sv39>
ffffffffc0201c66:	0000e797          	auipc	a5,0xe
ffffffffc0201c6a:	7ed7b923          	sd	a3,2034(a5) # ffffffffc0210458 <boot_pgdir>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc0201c6e:	c02007b7          	lui	a5,0xc0200
ffffffffc0201c72:	0ef6ece3          	bltu	a3,a5,ffffffffc020256a <pmm_init+0xa44>
ffffffffc0201c76:	0009b783          	ld	a5,0(s3)
ffffffffc0201c7a:	8e9d                	sub	a3,a3,a5
ffffffffc0201c7c:	0000f797          	auipc	a5,0xf
ffffffffc0201c80:	82d7b623          	sd	a3,-2004(a5) # ffffffffc02104a8 <boot_cr3>
    // assert(npage <= KMEMSIZE / PGSIZE);
    // The memory starts at 2GB in RISC-V
    // so npage is always larger than KMEMSIZE / PGSIZE
    size_t nr_free_store;

    nr_free_store=nr_free_pages();
ffffffffc0201c84:	ab9ff0ef          	jal	ra,ffffffffc020173c <nr_free_pages>

    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0201c88:	6098                	ld	a4,0(s1)
ffffffffc0201c8a:	c80007b7          	lui	a5,0xc8000
ffffffffc0201c8e:	83b1                	srli	a5,a5,0xc
    nr_free_store=nr_free_pages();
ffffffffc0201c90:	8a2a                	mv	s4,a0
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0201c92:	0ae7ece3          	bltu	a5,a4,ffffffffc020254a <pmm_init+0xa24>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc0201c96:	6008                	ld	a0,0(s0)
ffffffffc0201c98:	4c050363          	beqz	a0,ffffffffc020215e <pmm_init+0x638>
ffffffffc0201c9c:	6785                	lui	a5,0x1
ffffffffc0201c9e:	17fd                	addi	a5,a5,-1
ffffffffc0201ca0:	8fe9                	and	a5,a5,a0
ffffffffc0201ca2:	2781                	sext.w	a5,a5
ffffffffc0201ca4:	4a079d63          	bnez	a5,ffffffffc020215e <pmm_init+0x638>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc0201ca8:	4601                	li	a2,0
ffffffffc0201caa:	4581                	li	a1,0
ffffffffc0201cac:	ccfff0ef          	jal	ra,ffffffffc020197a <get_page>
ffffffffc0201cb0:	4c051763          	bnez	a0,ffffffffc020217e <pmm_init+0x658>

    struct Page *p1, *p2;
    p1 = alloc_page();
ffffffffc0201cb4:	4505                	li	a0,1
ffffffffc0201cb6:	9b9ff0ef          	jal	ra,ffffffffc020166e <alloc_pages>
ffffffffc0201cba:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc0201cbc:	6008                	ld	a0,0(s0)
ffffffffc0201cbe:	4681                	li	a3,0
ffffffffc0201cc0:	4601                	li	a2,0
ffffffffc0201cc2:	85d6                	mv	a1,s5
ffffffffc0201cc4:	d91ff0ef          	jal	ra,ffffffffc0201a54 <page_insert>
ffffffffc0201cc8:	52051763          	bnez	a0,ffffffffc02021f6 <pmm_init+0x6d0>
    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc0201ccc:	6008                	ld	a0,0(s0)
ffffffffc0201cce:	4601                	li	a2,0
ffffffffc0201cd0:	4581                	li	a1,0
ffffffffc0201cd2:	aabff0ef          	jal	ra,ffffffffc020177c <get_pte>
ffffffffc0201cd6:	50050063          	beqz	a0,ffffffffc02021d6 <pmm_init+0x6b0>
    assert(pte2page(*ptep) == p1);
ffffffffc0201cda:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0201cdc:	0017f713          	andi	a4,a5,1
ffffffffc0201ce0:	46070363          	beqz	a4,ffffffffc0202146 <pmm_init+0x620>
    if (PPN(pa) >= npage) {
ffffffffc0201ce4:	6090                	ld	a2,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0201ce6:	078a                	slli	a5,a5,0x2
ffffffffc0201ce8:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201cea:	44c7f063          	bleu	a2,a5,ffffffffc020212a <pmm_init+0x604>
    return &pages[PPN(pa) - nbase];
ffffffffc0201cee:	fff80737          	lui	a4,0xfff80
ffffffffc0201cf2:	97ba                	add	a5,a5,a4
ffffffffc0201cf4:	00379713          	slli	a4,a5,0x3
ffffffffc0201cf8:	00093683          	ld	a3,0(s2)
ffffffffc0201cfc:	97ba                	add	a5,a5,a4
ffffffffc0201cfe:	078e                	slli	a5,a5,0x3
ffffffffc0201d00:	97b6                	add	a5,a5,a3
ffffffffc0201d02:	5efa9463          	bne	s5,a5,ffffffffc02022ea <pmm_init+0x7c4>
    assert(page_ref(p1) == 1);
ffffffffc0201d06:	000aab83          	lw	s7,0(s5)
ffffffffc0201d0a:	4785                	li	a5,1
ffffffffc0201d0c:	5afb9f63          	bne	s7,a5,ffffffffc02022ca <pmm_init+0x7a4>

    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc0201d10:	6008                	ld	a0,0(s0)
ffffffffc0201d12:	76fd                	lui	a3,0xfffff
ffffffffc0201d14:	611c                	ld	a5,0(a0)
ffffffffc0201d16:	078a                	slli	a5,a5,0x2
ffffffffc0201d18:	8ff5                	and	a5,a5,a3
ffffffffc0201d1a:	00c7d713          	srli	a4,a5,0xc
ffffffffc0201d1e:	58c77963          	bleu	a2,a4,ffffffffc02022b0 <pmm_init+0x78a>
ffffffffc0201d22:	0009bc03          	ld	s8,0(s3)
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0201d26:	97e2                	add	a5,a5,s8
ffffffffc0201d28:	0007bb03          	ld	s6,0(a5) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
ffffffffc0201d2c:	0b0a                	slli	s6,s6,0x2
ffffffffc0201d2e:	00db7b33          	and	s6,s6,a3
ffffffffc0201d32:	00cb5793          	srli	a5,s6,0xc
ffffffffc0201d36:	56c7f063          	bleu	a2,a5,ffffffffc0202296 <pmm_init+0x770>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0201d3a:	4601                	li	a2,0
ffffffffc0201d3c:	6585                	lui	a1,0x1
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0201d3e:	9b62                	add	s6,s6,s8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0201d40:	a3dff0ef          	jal	ra,ffffffffc020177c <get_pte>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0201d44:	0b21                	addi	s6,s6,8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0201d46:	53651863          	bne	a0,s6,ffffffffc0202276 <pmm_init+0x750>

    p2 = alloc_page();
ffffffffc0201d4a:	4505                	li	a0,1
ffffffffc0201d4c:	923ff0ef          	jal	ra,ffffffffc020166e <alloc_pages>
ffffffffc0201d50:	8b2a                	mv	s6,a0
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0201d52:	6008                	ld	a0,0(s0)
ffffffffc0201d54:	46d1                	li	a3,20
ffffffffc0201d56:	6605                	lui	a2,0x1
ffffffffc0201d58:	85da                	mv	a1,s6
ffffffffc0201d5a:	cfbff0ef          	jal	ra,ffffffffc0201a54 <page_insert>
ffffffffc0201d5e:	4e051c63          	bnez	a0,ffffffffc0202256 <pmm_init+0x730>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0201d62:	6008                	ld	a0,0(s0)
ffffffffc0201d64:	4601                	li	a2,0
ffffffffc0201d66:	6585                	lui	a1,0x1
ffffffffc0201d68:	a15ff0ef          	jal	ra,ffffffffc020177c <get_pte>
ffffffffc0201d6c:	4c050563          	beqz	a0,ffffffffc0202236 <pmm_init+0x710>
    assert(*ptep & PTE_U);
ffffffffc0201d70:	611c                	ld	a5,0(a0)
ffffffffc0201d72:	0107f713          	andi	a4,a5,16
ffffffffc0201d76:	4a070063          	beqz	a4,ffffffffc0202216 <pmm_init+0x6f0>
    assert(*ptep & PTE_W);
ffffffffc0201d7a:	8b91                	andi	a5,a5,4
ffffffffc0201d7c:	66078763          	beqz	a5,ffffffffc02023ea <pmm_init+0x8c4>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc0201d80:	6008                	ld	a0,0(s0)
ffffffffc0201d82:	611c                	ld	a5,0(a0)
ffffffffc0201d84:	8bc1                	andi	a5,a5,16
ffffffffc0201d86:	64078263          	beqz	a5,ffffffffc02023ca <pmm_init+0x8a4>
    assert(page_ref(p2) == 1);
ffffffffc0201d8a:	000b2783          	lw	a5,0(s6)
ffffffffc0201d8e:	61779e63          	bne	a5,s7,ffffffffc02023aa <pmm_init+0x884>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc0201d92:	4681                	li	a3,0
ffffffffc0201d94:	6605                	lui	a2,0x1
ffffffffc0201d96:	85d6                	mv	a1,s5
ffffffffc0201d98:	cbdff0ef          	jal	ra,ffffffffc0201a54 <page_insert>
ffffffffc0201d9c:	5e051763          	bnez	a0,ffffffffc020238a <pmm_init+0x864>
    assert(page_ref(p1) == 2);
ffffffffc0201da0:	000aa703          	lw	a4,0(s5)
ffffffffc0201da4:	4789                	li	a5,2
ffffffffc0201da6:	5cf71263          	bne	a4,a5,ffffffffc020236a <pmm_init+0x844>
    assert(page_ref(p2) == 0);
ffffffffc0201daa:	000b2783          	lw	a5,0(s6)
ffffffffc0201dae:	58079e63          	bnez	a5,ffffffffc020234a <pmm_init+0x824>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0201db2:	6008                	ld	a0,0(s0)
ffffffffc0201db4:	4601                	li	a2,0
ffffffffc0201db6:	6585                	lui	a1,0x1
ffffffffc0201db8:	9c5ff0ef          	jal	ra,ffffffffc020177c <get_pte>
ffffffffc0201dbc:	56050763          	beqz	a0,ffffffffc020232a <pmm_init+0x804>
    assert(pte2page(*ptep) == p1);
ffffffffc0201dc0:	6114                	ld	a3,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0201dc2:	0016f793          	andi	a5,a3,1
ffffffffc0201dc6:	38078063          	beqz	a5,ffffffffc0202146 <pmm_init+0x620>
    if (PPN(pa) >= npage) {
ffffffffc0201dca:	6098                	ld	a4,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0201dcc:	00269793          	slli	a5,a3,0x2
ffffffffc0201dd0:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201dd2:	34e7fc63          	bleu	a4,a5,ffffffffc020212a <pmm_init+0x604>
    return &pages[PPN(pa) - nbase];
ffffffffc0201dd6:	fff80737          	lui	a4,0xfff80
ffffffffc0201dda:	97ba                	add	a5,a5,a4
ffffffffc0201ddc:	00379713          	slli	a4,a5,0x3
ffffffffc0201de0:	00093603          	ld	a2,0(s2)
ffffffffc0201de4:	97ba                	add	a5,a5,a4
ffffffffc0201de6:	078e                	slli	a5,a5,0x3
ffffffffc0201de8:	97b2                	add	a5,a5,a2
ffffffffc0201dea:	52fa9063          	bne	s5,a5,ffffffffc020230a <pmm_init+0x7e4>
    assert((*ptep & PTE_U) == 0);
ffffffffc0201dee:	8ac1                	andi	a3,a3,16
ffffffffc0201df0:	6e069d63          	bnez	a3,ffffffffc02024ea <pmm_init+0x9c4>

    page_remove(boot_pgdir, 0x0);
ffffffffc0201df4:	6008                	ld	a0,0(s0)
ffffffffc0201df6:	4581                	li	a1,0
ffffffffc0201df8:	bebff0ef          	jal	ra,ffffffffc02019e2 <page_remove>
    assert(page_ref(p1) == 1);
ffffffffc0201dfc:	000aa703          	lw	a4,0(s5)
ffffffffc0201e00:	4785                	li	a5,1
ffffffffc0201e02:	6cf71463          	bne	a4,a5,ffffffffc02024ca <pmm_init+0x9a4>
    assert(page_ref(p2) == 0);
ffffffffc0201e06:	000b2783          	lw	a5,0(s6)
ffffffffc0201e0a:	6a079063          	bnez	a5,ffffffffc02024aa <pmm_init+0x984>

    page_remove(boot_pgdir, PGSIZE);
ffffffffc0201e0e:	6008                	ld	a0,0(s0)
ffffffffc0201e10:	6585                	lui	a1,0x1
ffffffffc0201e12:	bd1ff0ef          	jal	ra,ffffffffc02019e2 <page_remove>
    assert(page_ref(p1) == 0);
ffffffffc0201e16:	000aa783          	lw	a5,0(s5)
ffffffffc0201e1a:	66079863          	bnez	a5,ffffffffc020248a <pmm_init+0x964>
    assert(page_ref(p2) == 0);
ffffffffc0201e1e:	000b2783          	lw	a5,0(s6)
ffffffffc0201e22:	70079463          	bnez	a5,ffffffffc020252a <pmm_init+0xa04>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc0201e26:	00043b03          	ld	s6,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc0201e2a:	608c                	ld	a1,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201e2c:	000b3783          	ld	a5,0(s6)
ffffffffc0201e30:	078a                	slli	a5,a5,0x2
ffffffffc0201e32:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201e34:	2eb7fb63          	bleu	a1,a5,ffffffffc020212a <pmm_init+0x604>
    return &pages[PPN(pa) - nbase];
ffffffffc0201e38:	fff80737          	lui	a4,0xfff80
ffffffffc0201e3c:	973e                	add	a4,a4,a5
ffffffffc0201e3e:	00371793          	slli	a5,a4,0x3
ffffffffc0201e42:	00093603          	ld	a2,0(s2)
ffffffffc0201e46:	97ba                	add	a5,a5,a4
ffffffffc0201e48:	078e                	slli	a5,a5,0x3
ffffffffc0201e4a:	00f60733          	add	a4,a2,a5
ffffffffc0201e4e:	4314                	lw	a3,0(a4)
ffffffffc0201e50:	4705                	li	a4,1
ffffffffc0201e52:	6ae69c63          	bne	a3,a4,ffffffffc020250a <pmm_init+0x9e4>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201e56:	00003a97          	auipc	s5,0x3
ffffffffc0201e5a:	c32a8a93          	addi	s5,s5,-974 # ffffffffc0204a88 <commands+0x858>
ffffffffc0201e5e:	000ab703          	ld	a4,0(s5)
ffffffffc0201e62:	4037d693          	srai	a3,a5,0x3
ffffffffc0201e66:	00080bb7          	lui	s7,0x80
ffffffffc0201e6a:	02e686b3          	mul	a3,a3,a4
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201e6e:	577d                	li	a4,-1
ffffffffc0201e70:	8331                	srli	a4,a4,0xc
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201e72:	96de                	add	a3,a3,s7
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201e74:	8f75                	and	a4,a4,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0201e76:	06b2                	slli	a3,a3,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201e78:	2ab77b63          	bleu	a1,a4,ffffffffc020212e <pmm_init+0x608>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
    free_page(pde2page(pd0[0]));
ffffffffc0201e7c:	0009b783          	ld	a5,0(s3)
ffffffffc0201e80:	96be                	add	a3,a3,a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0201e82:	629c                	ld	a5,0(a3)
ffffffffc0201e84:	078a                	slli	a5,a5,0x2
ffffffffc0201e86:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201e88:	2ab7f163          	bleu	a1,a5,ffffffffc020212a <pmm_init+0x604>
    return &pages[PPN(pa) - nbase];
ffffffffc0201e8c:	417787b3          	sub	a5,a5,s7
ffffffffc0201e90:	00379513          	slli	a0,a5,0x3
ffffffffc0201e94:	97aa                	add	a5,a5,a0
ffffffffc0201e96:	00379513          	slli	a0,a5,0x3
ffffffffc0201e9a:	9532                	add	a0,a0,a2
ffffffffc0201e9c:	4585                	li	a1,1
ffffffffc0201e9e:	859ff0ef          	jal	ra,ffffffffc02016f6 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0201ea2:	000b3503          	ld	a0,0(s6)
    if (PPN(pa) >= npage) {
ffffffffc0201ea6:	609c                	ld	a5,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201ea8:	050a                	slli	a0,a0,0x2
ffffffffc0201eaa:	8131                	srli	a0,a0,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201eac:	26f57f63          	bleu	a5,a0,ffffffffc020212a <pmm_init+0x604>
    return &pages[PPN(pa) - nbase];
ffffffffc0201eb0:	417507b3          	sub	a5,a0,s7
ffffffffc0201eb4:	00379513          	slli	a0,a5,0x3
ffffffffc0201eb8:	00093703          	ld	a4,0(s2)
ffffffffc0201ebc:	953e                	add	a0,a0,a5
ffffffffc0201ebe:	050e                	slli	a0,a0,0x3
    free_page(pde2page(pd1[0]));
ffffffffc0201ec0:	4585                	li	a1,1
ffffffffc0201ec2:	953a                	add	a0,a0,a4
ffffffffc0201ec4:	833ff0ef          	jal	ra,ffffffffc02016f6 <free_pages>
    boot_pgdir[0] = 0;
ffffffffc0201ec8:	601c                	ld	a5,0(s0)
ffffffffc0201eca:	0007b023          	sd	zero,0(a5)

    assert(nr_free_store==nr_free_pages());
ffffffffc0201ece:	86fff0ef          	jal	ra,ffffffffc020173c <nr_free_pages>
ffffffffc0201ed2:	2caa1663          	bne	s4,a0,ffffffffc020219e <pmm_init+0x678>

    cprintf("check_pgdir() succeeded!\n");
ffffffffc0201ed6:	00003517          	auipc	a0,0x3
ffffffffc0201eda:	43250513          	addi	a0,a0,1074 # ffffffffc0205308 <default_pmm_manager+0x4d0>
ffffffffc0201ede:	9e0fe0ef          	jal	ra,ffffffffc02000be <cprintf>
static void check_boot_pgdir(void) {
    size_t nr_free_store;
    pte_t *ptep;
    int i;

    nr_free_store=nr_free_pages();
ffffffffc0201ee2:	85bff0ef          	jal	ra,ffffffffc020173c <nr_free_pages>

    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0201ee6:	6098                	ld	a4,0(s1)
ffffffffc0201ee8:	c02007b7          	lui	a5,0xc0200
    nr_free_store=nr_free_pages();
ffffffffc0201eec:	8b2a                	mv	s6,a0
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0201eee:	00c71693          	slli	a3,a4,0xc
ffffffffc0201ef2:	1cd7fd63          	bleu	a3,a5,ffffffffc02020cc <pmm_init+0x5a6>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0201ef6:	83b1                	srli	a5,a5,0xc
ffffffffc0201ef8:	6008                	ld	a0,0(s0)
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0201efa:	c0200a37          	lui	s4,0xc0200
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0201efe:	1ce7f963          	bleu	a4,a5,ffffffffc02020d0 <pmm_init+0x5aa>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0201f02:	7c7d                	lui	s8,0xfffff
ffffffffc0201f04:	6b85                	lui	s7,0x1
ffffffffc0201f06:	a029                	j	ffffffffc0201f10 <pmm_init+0x3ea>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0201f08:	00ca5713          	srli	a4,s4,0xc
ffffffffc0201f0c:	1cf77263          	bleu	a5,a4,ffffffffc02020d0 <pmm_init+0x5aa>
ffffffffc0201f10:	0009b583          	ld	a1,0(s3)
ffffffffc0201f14:	4601                	li	a2,0
ffffffffc0201f16:	95d2                	add	a1,a1,s4
ffffffffc0201f18:	865ff0ef          	jal	ra,ffffffffc020177c <get_pte>
ffffffffc0201f1c:	1c050763          	beqz	a0,ffffffffc02020ea <pmm_init+0x5c4>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0201f20:	611c                	ld	a5,0(a0)
ffffffffc0201f22:	078a                	slli	a5,a5,0x2
ffffffffc0201f24:	0187f7b3          	and	a5,a5,s8
ffffffffc0201f28:	1f479163          	bne	a5,s4,ffffffffc020210a <pmm_init+0x5e4>
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0201f2c:	609c                	ld	a5,0(s1)
ffffffffc0201f2e:	9a5e                	add	s4,s4,s7
ffffffffc0201f30:	6008                	ld	a0,0(s0)
ffffffffc0201f32:	00c79713          	slli	a4,a5,0xc
ffffffffc0201f36:	fcea69e3          	bltu	s4,a4,ffffffffc0201f08 <pmm_init+0x3e2>
    }


    assert(boot_pgdir[0] == 0);
ffffffffc0201f3a:	611c                	ld	a5,0(a0)
ffffffffc0201f3c:	6a079363          	bnez	a5,ffffffffc02025e2 <pmm_init+0xabc>

    struct Page *p;
    p = alloc_page();
ffffffffc0201f40:	4505                	li	a0,1
ffffffffc0201f42:	f2cff0ef          	jal	ra,ffffffffc020166e <alloc_pages>
ffffffffc0201f46:	8a2a                	mv	s4,a0
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0201f48:	6008                	ld	a0,0(s0)
ffffffffc0201f4a:	4699                	li	a3,6
ffffffffc0201f4c:	10000613          	li	a2,256
ffffffffc0201f50:	85d2                	mv	a1,s4
ffffffffc0201f52:	b03ff0ef          	jal	ra,ffffffffc0201a54 <page_insert>
ffffffffc0201f56:	66051663          	bnez	a0,ffffffffc02025c2 <pmm_init+0xa9c>
    assert(page_ref(p) == 1);
ffffffffc0201f5a:	000a2703          	lw	a4,0(s4) # ffffffffc0200000 <kern_entry>
ffffffffc0201f5e:	4785                	li	a5,1
ffffffffc0201f60:	64f71163          	bne	a4,a5,ffffffffc02025a2 <pmm_init+0xa7c>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0201f64:	6008                	ld	a0,0(s0)
ffffffffc0201f66:	6b85                	lui	s7,0x1
ffffffffc0201f68:	4699                	li	a3,6
ffffffffc0201f6a:	100b8613          	addi	a2,s7,256 # 1100 <BASE_ADDRESS-0xffffffffc01fef00>
ffffffffc0201f6e:	85d2                	mv	a1,s4
ffffffffc0201f70:	ae5ff0ef          	jal	ra,ffffffffc0201a54 <page_insert>
ffffffffc0201f74:	60051763          	bnez	a0,ffffffffc0202582 <pmm_init+0xa5c>
    assert(page_ref(p) == 2);
ffffffffc0201f78:	000a2703          	lw	a4,0(s4)
ffffffffc0201f7c:	4789                	li	a5,2
ffffffffc0201f7e:	4ef71663          	bne	a4,a5,ffffffffc020246a <pmm_init+0x944>

    const char *str = "ucore: Hello world!!";
    strcpy((void *)0x100, str);
ffffffffc0201f82:	00003597          	auipc	a1,0x3
ffffffffc0201f86:	4be58593          	addi	a1,a1,1214 # ffffffffc0205440 <default_pmm_manager+0x608>
ffffffffc0201f8a:	10000513          	li	a0,256
ffffffffc0201f8e:	0f6020ef          	jal	ra,ffffffffc0204084 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0201f92:	100b8593          	addi	a1,s7,256
ffffffffc0201f96:	10000513          	li	a0,256
ffffffffc0201f9a:	0fc020ef          	jal	ra,ffffffffc0204096 <strcmp>
ffffffffc0201f9e:	4a051663          	bnez	a0,ffffffffc020244a <pmm_init+0x924>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201fa2:	00093683          	ld	a3,0(s2)
ffffffffc0201fa6:	000abc83          	ld	s9,0(s5)
ffffffffc0201faa:	00080c37          	lui	s8,0x80
ffffffffc0201fae:	40da06b3          	sub	a3,s4,a3
ffffffffc0201fb2:	868d                	srai	a3,a3,0x3
ffffffffc0201fb4:	039686b3          	mul	a3,a3,s9
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201fb8:	5afd                	li	s5,-1
ffffffffc0201fba:	609c                	ld	a5,0(s1)
ffffffffc0201fbc:	00cada93          	srli	s5,s5,0xc
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201fc0:	96e2                	add	a3,a3,s8
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201fc2:	0156f733          	and	a4,a3,s5
    return page2ppn(page) << PGSHIFT;
ffffffffc0201fc6:	06b2                	slli	a3,a3,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201fc8:	16f77363          	bleu	a5,a4,ffffffffc020212e <pmm_init+0x608>

    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0201fcc:	0009b783          	ld	a5,0(s3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc0201fd0:	10000513          	li	a0,256
    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0201fd4:	96be                	add	a3,a3,a5
ffffffffc0201fd6:	10068023          	sb	zero,256(a3) # fffffffffffff100 <end+0x3fdeeb60>
    assert(strlen((const char *)0x100) == 0);
ffffffffc0201fda:	066020ef          	jal	ra,ffffffffc0204040 <strlen>
ffffffffc0201fde:	44051663          	bnez	a0,ffffffffc020242a <pmm_init+0x904>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc0201fe2:	00043b83          	ld	s7,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc0201fe6:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201fe8:	000bb783          	ld	a5,0(s7)
ffffffffc0201fec:	078a                	slli	a5,a5,0x2
ffffffffc0201fee:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201ff0:	12e7fd63          	bleu	a4,a5,ffffffffc020212a <pmm_init+0x604>
    return &pages[PPN(pa) - nbase];
ffffffffc0201ff4:	418787b3          	sub	a5,a5,s8
ffffffffc0201ff8:	00379693          	slli	a3,a5,0x3
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201ffc:	96be                	add	a3,a3,a5
ffffffffc0201ffe:	039686b3          	mul	a3,a3,s9
ffffffffc0202002:	96e2                	add	a3,a3,s8
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0202004:	0156fab3          	and	s5,a3,s5
    return page2ppn(page) << PGSHIFT;
ffffffffc0202008:	06b2                	slli	a3,a3,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc020200a:	12eaf263          	bleu	a4,s5,ffffffffc020212e <pmm_init+0x608>
ffffffffc020200e:	0009b983          	ld	s3,0(s3)
    free_page(p);
ffffffffc0202012:	4585                	li	a1,1
ffffffffc0202014:	8552                	mv	a0,s4
ffffffffc0202016:	99b6                	add	s3,s3,a3
ffffffffc0202018:	edeff0ef          	jal	ra,ffffffffc02016f6 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc020201c:	0009b783          	ld	a5,0(s3)
    if (PPN(pa) >= npage) {
ffffffffc0202020:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202022:	078a                	slli	a5,a5,0x2
ffffffffc0202024:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202026:	10e7f263          	bleu	a4,a5,ffffffffc020212a <pmm_init+0x604>
    return &pages[PPN(pa) - nbase];
ffffffffc020202a:	fff809b7          	lui	s3,0xfff80
ffffffffc020202e:	97ce                	add	a5,a5,s3
ffffffffc0202030:	00379513          	slli	a0,a5,0x3
ffffffffc0202034:	00093703          	ld	a4,0(s2)
ffffffffc0202038:	97aa                	add	a5,a5,a0
ffffffffc020203a:	00379513          	slli	a0,a5,0x3
    free_page(pde2page(pd0[0]));
ffffffffc020203e:	953a                	add	a0,a0,a4
ffffffffc0202040:	4585                	li	a1,1
ffffffffc0202042:	eb4ff0ef          	jal	ra,ffffffffc02016f6 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0202046:	000bb503          	ld	a0,0(s7)
    if (PPN(pa) >= npage) {
ffffffffc020204a:	609c                	ld	a5,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc020204c:	050a                	slli	a0,a0,0x2
ffffffffc020204e:	8131                	srli	a0,a0,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202050:	0cf57d63          	bleu	a5,a0,ffffffffc020212a <pmm_init+0x604>
    return &pages[PPN(pa) - nbase];
ffffffffc0202054:	013507b3          	add	a5,a0,s3
ffffffffc0202058:	00379513          	slli	a0,a5,0x3
ffffffffc020205c:	00093703          	ld	a4,0(s2)
ffffffffc0202060:	953e                	add	a0,a0,a5
ffffffffc0202062:	050e                	slli	a0,a0,0x3
    free_page(pde2page(pd1[0]));
ffffffffc0202064:	4585                	li	a1,1
ffffffffc0202066:	953a                	add	a0,a0,a4
ffffffffc0202068:	e8eff0ef          	jal	ra,ffffffffc02016f6 <free_pages>
    boot_pgdir[0] = 0;
ffffffffc020206c:	601c                	ld	a5,0(s0)
ffffffffc020206e:	0007b023          	sd	zero,0(a5) # ffffffffc0200000 <kern_entry>

    assert(nr_free_store==nr_free_pages());
ffffffffc0202072:	ecaff0ef          	jal	ra,ffffffffc020173c <nr_free_pages>
ffffffffc0202076:	38ab1a63          	bne	s6,a0,ffffffffc020240a <pmm_init+0x8e4>
}
ffffffffc020207a:	6446                	ld	s0,80(sp)
ffffffffc020207c:	60e6                	ld	ra,88(sp)
ffffffffc020207e:	64a6                	ld	s1,72(sp)
ffffffffc0202080:	6906                	ld	s2,64(sp)
ffffffffc0202082:	79e2                	ld	s3,56(sp)
ffffffffc0202084:	7a42                	ld	s4,48(sp)
ffffffffc0202086:	7aa2                	ld	s5,40(sp)
ffffffffc0202088:	7b02                	ld	s6,32(sp)
ffffffffc020208a:	6be2                	ld	s7,24(sp)
ffffffffc020208c:	6c42                	ld	s8,16(sp)
ffffffffc020208e:	6ca2                	ld	s9,8(sp)

    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc0202090:	00003517          	auipc	a0,0x3
ffffffffc0202094:	42850513          	addi	a0,a0,1064 # ffffffffc02054b8 <default_pmm_manager+0x680>
}
ffffffffc0202098:	6125                	addi	sp,sp,96
    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc020209a:	824fe06f          	j	ffffffffc02000be <cprintf>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc020209e:	6705                	lui	a4,0x1
ffffffffc02020a0:	177d                	addi	a4,a4,-1
ffffffffc02020a2:	96ba                	add	a3,a3,a4
    if (PPN(pa) >= npage) {
ffffffffc02020a4:	00c6d713          	srli	a4,a3,0xc
ffffffffc02020a8:	08f77163          	bleu	a5,a4,ffffffffc020212a <pmm_init+0x604>
    pmm_manager->init_memmap(base, n);
ffffffffc02020ac:	00043803          	ld	a6,0(s0)
    return &pages[PPN(pa) - nbase];
ffffffffc02020b0:	9732                	add	a4,a4,a2
ffffffffc02020b2:	00371793          	slli	a5,a4,0x3
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc02020b6:	767d                	lui	a2,0xfffff
ffffffffc02020b8:	8ef1                	and	a3,a3,a2
ffffffffc02020ba:	97ba                	add	a5,a5,a4
    pmm_manager->init_memmap(base, n);
ffffffffc02020bc:	01083703          	ld	a4,16(a6)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc02020c0:	8d95                	sub	a1,a1,a3
ffffffffc02020c2:	078e                	slli	a5,a5,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc02020c4:	81b1                	srli	a1,a1,0xc
ffffffffc02020c6:	953e                	add	a0,a0,a5
ffffffffc02020c8:	9702                	jalr	a4
ffffffffc02020ca:	bead                	j	ffffffffc0201c44 <pmm_init+0x11e>
ffffffffc02020cc:	6008                	ld	a0,0(s0)
ffffffffc02020ce:	b5b5                	j	ffffffffc0201f3a <pmm_init+0x414>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc02020d0:	86d2                	mv	a3,s4
ffffffffc02020d2:	00003617          	auipc	a2,0x3
ffffffffc02020d6:	db660613          	addi	a2,a2,-586 # ffffffffc0204e88 <default_pmm_manager+0x50>
ffffffffc02020da:	1cd00593          	li	a1,461
ffffffffc02020de:	00003517          	auipc	a0,0x3
ffffffffc02020e2:	dd250513          	addi	a0,a0,-558 # ffffffffc0204eb0 <default_pmm_manager+0x78>
ffffffffc02020e6:	a8efe0ef          	jal	ra,ffffffffc0200374 <__panic>
ffffffffc02020ea:	00003697          	auipc	a3,0x3
ffffffffc02020ee:	23e68693          	addi	a3,a3,574 # ffffffffc0205328 <default_pmm_manager+0x4f0>
ffffffffc02020f2:	00003617          	auipc	a2,0x3
ffffffffc02020f6:	9ae60613          	addi	a2,a2,-1618 # ffffffffc0204aa0 <commands+0x870>
ffffffffc02020fa:	1cd00593          	li	a1,461
ffffffffc02020fe:	00003517          	auipc	a0,0x3
ffffffffc0202102:	db250513          	addi	a0,a0,-590 # ffffffffc0204eb0 <default_pmm_manager+0x78>
ffffffffc0202106:	a6efe0ef          	jal	ra,ffffffffc0200374 <__panic>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc020210a:	00003697          	auipc	a3,0x3
ffffffffc020210e:	25e68693          	addi	a3,a3,606 # ffffffffc0205368 <default_pmm_manager+0x530>
ffffffffc0202112:	00003617          	auipc	a2,0x3
ffffffffc0202116:	98e60613          	addi	a2,a2,-1650 # ffffffffc0204aa0 <commands+0x870>
ffffffffc020211a:	1ce00593          	li	a1,462
ffffffffc020211e:	00003517          	auipc	a0,0x3
ffffffffc0202122:	d9250513          	addi	a0,a0,-622 # ffffffffc0204eb0 <default_pmm_manager+0x78>
ffffffffc0202126:	a4efe0ef          	jal	ra,ffffffffc0200374 <__panic>
ffffffffc020212a:	d28ff0ef          	jal	ra,ffffffffc0201652 <pa2page.part.4>
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc020212e:	00003617          	auipc	a2,0x3
ffffffffc0202132:	d5a60613          	addi	a2,a2,-678 # ffffffffc0204e88 <default_pmm_manager+0x50>
ffffffffc0202136:	06a00593          	li	a1,106
ffffffffc020213a:	00003517          	auipc	a0,0x3
ffffffffc020213e:	de650513          	addi	a0,a0,-538 # ffffffffc0204f20 <default_pmm_manager+0xe8>
ffffffffc0202142:	a32fe0ef          	jal	ra,ffffffffc0200374 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc0202146:	00003617          	auipc	a2,0x3
ffffffffc020214a:	fb260613          	addi	a2,a2,-78 # ffffffffc02050f8 <default_pmm_manager+0x2c0>
ffffffffc020214e:	07000593          	li	a1,112
ffffffffc0202152:	00003517          	auipc	a0,0x3
ffffffffc0202156:	dce50513          	addi	a0,a0,-562 # ffffffffc0204f20 <default_pmm_manager+0xe8>
ffffffffc020215a:	a1afe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc020215e:	00003697          	auipc	a3,0x3
ffffffffc0202162:	eda68693          	addi	a3,a3,-294 # ffffffffc0205038 <default_pmm_manager+0x200>
ffffffffc0202166:	00003617          	auipc	a2,0x3
ffffffffc020216a:	93a60613          	addi	a2,a2,-1734 # ffffffffc0204aa0 <commands+0x870>
ffffffffc020216e:	19300593          	li	a1,403
ffffffffc0202172:	00003517          	auipc	a0,0x3
ffffffffc0202176:	d3e50513          	addi	a0,a0,-706 # ffffffffc0204eb0 <default_pmm_manager+0x78>
ffffffffc020217a:	9fafe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc020217e:	00003697          	auipc	a3,0x3
ffffffffc0202182:	ef268693          	addi	a3,a3,-270 # ffffffffc0205070 <default_pmm_manager+0x238>
ffffffffc0202186:	00003617          	auipc	a2,0x3
ffffffffc020218a:	91a60613          	addi	a2,a2,-1766 # ffffffffc0204aa0 <commands+0x870>
ffffffffc020218e:	19400593          	li	a1,404
ffffffffc0202192:	00003517          	auipc	a0,0x3
ffffffffc0202196:	d1e50513          	addi	a0,a0,-738 # ffffffffc0204eb0 <default_pmm_manager+0x78>
ffffffffc020219a:	9dafe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc020219e:	00003697          	auipc	a3,0x3
ffffffffc02021a2:	14a68693          	addi	a3,a3,330 # ffffffffc02052e8 <default_pmm_manager+0x4b0>
ffffffffc02021a6:	00003617          	auipc	a2,0x3
ffffffffc02021aa:	8fa60613          	addi	a2,a2,-1798 # ffffffffc0204aa0 <commands+0x870>
ffffffffc02021ae:	1c000593          	li	a1,448
ffffffffc02021b2:	00003517          	auipc	a0,0x3
ffffffffc02021b6:	cfe50513          	addi	a0,a0,-770 # ffffffffc0204eb0 <default_pmm_manager+0x78>
ffffffffc02021ba:	9bafe0ef          	jal	ra,ffffffffc0200374 <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02021be:	00003617          	auipc	a2,0x3
ffffffffc02021c2:	e1260613          	addi	a2,a2,-494 # ffffffffc0204fd0 <default_pmm_manager+0x198>
ffffffffc02021c6:	07700593          	li	a1,119
ffffffffc02021ca:	00003517          	auipc	a0,0x3
ffffffffc02021ce:	ce650513          	addi	a0,a0,-794 # ffffffffc0204eb0 <default_pmm_manager+0x78>
ffffffffc02021d2:	9a2fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc02021d6:	00003697          	auipc	a3,0x3
ffffffffc02021da:	ef268693          	addi	a3,a3,-270 # ffffffffc02050c8 <default_pmm_manager+0x290>
ffffffffc02021de:	00003617          	auipc	a2,0x3
ffffffffc02021e2:	8c260613          	addi	a2,a2,-1854 # ffffffffc0204aa0 <commands+0x870>
ffffffffc02021e6:	19a00593          	li	a1,410
ffffffffc02021ea:	00003517          	auipc	a0,0x3
ffffffffc02021ee:	cc650513          	addi	a0,a0,-826 # ffffffffc0204eb0 <default_pmm_manager+0x78>
ffffffffc02021f2:	982fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc02021f6:	00003697          	auipc	a3,0x3
ffffffffc02021fa:	ea268693          	addi	a3,a3,-350 # ffffffffc0205098 <default_pmm_manager+0x260>
ffffffffc02021fe:	00003617          	auipc	a2,0x3
ffffffffc0202202:	8a260613          	addi	a2,a2,-1886 # ffffffffc0204aa0 <commands+0x870>
ffffffffc0202206:	19800593          	li	a1,408
ffffffffc020220a:	00003517          	auipc	a0,0x3
ffffffffc020220e:	ca650513          	addi	a0,a0,-858 # ffffffffc0204eb0 <default_pmm_manager+0x78>
ffffffffc0202212:	962fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(*ptep & PTE_U);
ffffffffc0202216:	00003697          	auipc	a3,0x3
ffffffffc020221a:	fca68693          	addi	a3,a3,-54 # ffffffffc02051e0 <default_pmm_manager+0x3a8>
ffffffffc020221e:	00003617          	auipc	a2,0x3
ffffffffc0202222:	88260613          	addi	a2,a2,-1918 # ffffffffc0204aa0 <commands+0x870>
ffffffffc0202226:	1a500593          	li	a1,421
ffffffffc020222a:	00003517          	auipc	a0,0x3
ffffffffc020222e:	c8650513          	addi	a0,a0,-890 # ffffffffc0204eb0 <default_pmm_manager+0x78>
ffffffffc0202232:	942fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0202236:	00003697          	auipc	a3,0x3
ffffffffc020223a:	f7a68693          	addi	a3,a3,-134 # ffffffffc02051b0 <default_pmm_manager+0x378>
ffffffffc020223e:	00003617          	auipc	a2,0x3
ffffffffc0202242:	86260613          	addi	a2,a2,-1950 # ffffffffc0204aa0 <commands+0x870>
ffffffffc0202246:	1a400593          	li	a1,420
ffffffffc020224a:	00003517          	auipc	a0,0x3
ffffffffc020224e:	c6650513          	addi	a0,a0,-922 # ffffffffc0204eb0 <default_pmm_manager+0x78>
ffffffffc0202252:	922fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0202256:	00003697          	auipc	a3,0x3
ffffffffc020225a:	f2268693          	addi	a3,a3,-222 # ffffffffc0205178 <default_pmm_manager+0x340>
ffffffffc020225e:	00003617          	auipc	a2,0x3
ffffffffc0202262:	84260613          	addi	a2,a2,-1982 # ffffffffc0204aa0 <commands+0x870>
ffffffffc0202266:	1a300593          	li	a1,419
ffffffffc020226a:	00003517          	auipc	a0,0x3
ffffffffc020226e:	c4650513          	addi	a0,a0,-954 # ffffffffc0204eb0 <default_pmm_manager+0x78>
ffffffffc0202272:	902fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0202276:	00003697          	auipc	a3,0x3
ffffffffc020227a:	eda68693          	addi	a3,a3,-294 # ffffffffc0205150 <default_pmm_manager+0x318>
ffffffffc020227e:	00003617          	auipc	a2,0x3
ffffffffc0202282:	82260613          	addi	a2,a2,-2014 # ffffffffc0204aa0 <commands+0x870>
ffffffffc0202286:	1a000593          	li	a1,416
ffffffffc020228a:	00003517          	auipc	a0,0x3
ffffffffc020228e:	c2650513          	addi	a0,a0,-986 # ffffffffc0204eb0 <default_pmm_manager+0x78>
ffffffffc0202292:	8e2fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0202296:	86da                	mv	a3,s6
ffffffffc0202298:	00003617          	auipc	a2,0x3
ffffffffc020229c:	bf060613          	addi	a2,a2,-1040 # ffffffffc0204e88 <default_pmm_manager+0x50>
ffffffffc02022a0:	19f00593          	li	a1,415
ffffffffc02022a4:	00003517          	auipc	a0,0x3
ffffffffc02022a8:	c0c50513          	addi	a0,a0,-1012 # ffffffffc0204eb0 <default_pmm_manager+0x78>
ffffffffc02022ac:	8c8fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc02022b0:	86be                	mv	a3,a5
ffffffffc02022b2:	00003617          	auipc	a2,0x3
ffffffffc02022b6:	bd660613          	addi	a2,a2,-1066 # ffffffffc0204e88 <default_pmm_manager+0x50>
ffffffffc02022ba:	19e00593          	li	a1,414
ffffffffc02022be:	00003517          	auipc	a0,0x3
ffffffffc02022c2:	bf250513          	addi	a0,a0,-1038 # ffffffffc0204eb0 <default_pmm_manager+0x78>
ffffffffc02022c6:	8aefe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc02022ca:	00003697          	auipc	a3,0x3
ffffffffc02022ce:	e6e68693          	addi	a3,a3,-402 # ffffffffc0205138 <default_pmm_manager+0x300>
ffffffffc02022d2:	00002617          	auipc	a2,0x2
ffffffffc02022d6:	7ce60613          	addi	a2,a2,1998 # ffffffffc0204aa0 <commands+0x870>
ffffffffc02022da:	19c00593          	li	a1,412
ffffffffc02022de:	00003517          	auipc	a0,0x3
ffffffffc02022e2:	bd250513          	addi	a0,a0,-1070 # ffffffffc0204eb0 <default_pmm_manager+0x78>
ffffffffc02022e6:	88efe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc02022ea:	00003697          	auipc	a3,0x3
ffffffffc02022ee:	e3668693          	addi	a3,a3,-458 # ffffffffc0205120 <default_pmm_manager+0x2e8>
ffffffffc02022f2:	00002617          	auipc	a2,0x2
ffffffffc02022f6:	7ae60613          	addi	a2,a2,1966 # ffffffffc0204aa0 <commands+0x870>
ffffffffc02022fa:	19b00593          	li	a1,411
ffffffffc02022fe:	00003517          	auipc	a0,0x3
ffffffffc0202302:	bb250513          	addi	a0,a0,-1102 # ffffffffc0204eb0 <default_pmm_manager+0x78>
ffffffffc0202306:	86efe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc020230a:	00003697          	auipc	a3,0x3
ffffffffc020230e:	e1668693          	addi	a3,a3,-490 # ffffffffc0205120 <default_pmm_manager+0x2e8>
ffffffffc0202312:	00002617          	auipc	a2,0x2
ffffffffc0202316:	78e60613          	addi	a2,a2,1934 # ffffffffc0204aa0 <commands+0x870>
ffffffffc020231a:	1ae00593          	li	a1,430
ffffffffc020231e:	00003517          	auipc	a0,0x3
ffffffffc0202322:	b9250513          	addi	a0,a0,-1134 # ffffffffc0204eb0 <default_pmm_manager+0x78>
ffffffffc0202326:	84efe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc020232a:	00003697          	auipc	a3,0x3
ffffffffc020232e:	e8668693          	addi	a3,a3,-378 # ffffffffc02051b0 <default_pmm_manager+0x378>
ffffffffc0202332:	00002617          	auipc	a2,0x2
ffffffffc0202336:	76e60613          	addi	a2,a2,1902 # ffffffffc0204aa0 <commands+0x870>
ffffffffc020233a:	1ad00593          	li	a1,429
ffffffffc020233e:	00003517          	auipc	a0,0x3
ffffffffc0202342:	b7250513          	addi	a0,a0,-1166 # ffffffffc0204eb0 <default_pmm_manager+0x78>
ffffffffc0202346:	82efe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc020234a:	00003697          	auipc	a3,0x3
ffffffffc020234e:	f2e68693          	addi	a3,a3,-210 # ffffffffc0205278 <default_pmm_manager+0x440>
ffffffffc0202352:	00002617          	auipc	a2,0x2
ffffffffc0202356:	74e60613          	addi	a2,a2,1870 # ffffffffc0204aa0 <commands+0x870>
ffffffffc020235a:	1ac00593          	li	a1,428
ffffffffc020235e:	00003517          	auipc	a0,0x3
ffffffffc0202362:	b5250513          	addi	a0,a0,-1198 # ffffffffc0204eb0 <default_pmm_manager+0x78>
ffffffffc0202366:	80efe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p1) == 2);
ffffffffc020236a:	00003697          	auipc	a3,0x3
ffffffffc020236e:	ef668693          	addi	a3,a3,-266 # ffffffffc0205260 <default_pmm_manager+0x428>
ffffffffc0202372:	00002617          	auipc	a2,0x2
ffffffffc0202376:	72e60613          	addi	a2,a2,1838 # ffffffffc0204aa0 <commands+0x870>
ffffffffc020237a:	1ab00593          	li	a1,427
ffffffffc020237e:	00003517          	auipc	a0,0x3
ffffffffc0202382:	b3250513          	addi	a0,a0,-1230 # ffffffffc0204eb0 <default_pmm_manager+0x78>
ffffffffc0202386:	feffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc020238a:	00003697          	auipc	a3,0x3
ffffffffc020238e:	ea668693          	addi	a3,a3,-346 # ffffffffc0205230 <default_pmm_manager+0x3f8>
ffffffffc0202392:	00002617          	auipc	a2,0x2
ffffffffc0202396:	70e60613          	addi	a2,a2,1806 # ffffffffc0204aa0 <commands+0x870>
ffffffffc020239a:	1aa00593          	li	a1,426
ffffffffc020239e:	00003517          	auipc	a0,0x3
ffffffffc02023a2:	b1250513          	addi	a0,a0,-1262 # ffffffffc0204eb0 <default_pmm_manager+0x78>
ffffffffc02023a6:	fcffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p2) == 1);
ffffffffc02023aa:	00003697          	auipc	a3,0x3
ffffffffc02023ae:	e6e68693          	addi	a3,a3,-402 # ffffffffc0205218 <default_pmm_manager+0x3e0>
ffffffffc02023b2:	00002617          	auipc	a2,0x2
ffffffffc02023b6:	6ee60613          	addi	a2,a2,1774 # ffffffffc0204aa0 <commands+0x870>
ffffffffc02023ba:	1a800593          	li	a1,424
ffffffffc02023be:	00003517          	auipc	a0,0x3
ffffffffc02023c2:	af250513          	addi	a0,a0,-1294 # ffffffffc0204eb0 <default_pmm_manager+0x78>
ffffffffc02023c6:	faffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc02023ca:	00003697          	auipc	a3,0x3
ffffffffc02023ce:	e3668693          	addi	a3,a3,-458 # ffffffffc0205200 <default_pmm_manager+0x3c8>
ffffffffc02023d2:	00002617          	auipc	a2,0x2
ffffffffc02023d6:	6ce60613          	addi	a2,a2,1742 # ffffffffc0204aa0 <commands+0x870>
ffffffffc02023da:	1a700593          	li	a1,423
ffffffffc02023de:	00003517          	auipc	a0,0x3
ffffffffc02023e2:	ad250513          	addi	a0,a0,-1326 # ffffffffc0204eb0 <default_pmm_manager+0x78>
ffffffffc02023e6:	f8ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(*ptep & PTE_W);
ffffffffc02023ea:	00003697          	auipc	a3,0x3
ffffffffc02023ee:	e0668693          	addi	a3,a3,-506 # ffffffffc02051f0 <default_pmm_manager+0x3b8>
ffffffffc02023f2:	00002617          	auipc	a2,0x2
ffffffffc02023f6:	6ae60613          	addi	a2,a2,1710 # ffffffffc0204aa0 <commands+0x870>
ffffffffc02023fa:	1a600593          	li	a1,422
ffffffffc02023fe:	00003517          	auipc	a0,0x3
ffffffffc0202402:	ab250513          	addi	a0,a0,-1358 # ffffffffc0204eb0 <default_pmm_manager+0x78>
ffffffffc0202406:	f6ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc020240a:	00003697          	auipc	a3,0x3
ffffffffc020240e:	ede68693          	addi	a3,a3,-290 # ffffffffc02052e8 <default_pmm_manager+0x4b0>
ffffffffc0202412:	00002617          	auipc	a2,0x2
ffffffffc0202416:	68e60613          	addi	a2,a2,1678 # ffffffffc0204aa0 <commands+0x870>
ffffffffc020241a:	1e800593          	li	a1,488
ffffffffc020241e:	00003517          	auipc	a0,0x3
ffffffffc0202422:	a9250513          	addi	a0,a0,-1390 # ffffffffc0204eb0 <default_pmm_manager+0x78>
ffffffffc0202426:	f4ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(strlen((const char *)0x100) == 0);
ffffffffc020242a:	00003697          	auipc	a3,0x3
ffffffffc020242e:	06668693          	addi	a3,a3,102 # ffffffffc0205490 <default_pmm_manager+0x658>
ffffffffc0202432:	00002617          	auipc	a2,0x2
ffffffffc0202436:	66e60613          	addi	a2,a2,1646 # ffffffffc0204aa0 <commands+0x870>
ffffffffc020243a:	1e000593          	li	a1,480
ffffffffc020243e:	00003517          	auipc	a0,0x3
ffffffffc0202442:	a7250513          	addi	a0,a0,-1422 # ffffffffc0204eb0 <default_pmm_manager+0x78>
ffffffffc0202446:	f2ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc020244a:	00003697          	auipc	a3,0x3
ffffffffc020244e:	00e68693          	addi	a3,a3,14 # ffffffffc0205458 <default_pmm_manager+0x620>
ffffffffc0202452:	00002617          	auipc	a2,0x2
ffffffffc0202456:	64e60613          	addi	a2,a2,1614 # ffffffffc0204aa0 <commands+0x870>
ffffffffc020245a:	1dd00593          	li	a1,477
ffffffffc020245e:	00003517          	auipc	a0,0x3
ffffffffc0202462:	a5250513          	addi	a0,a0,-1454 # ffffffffc0204eb0 <default_pmm_manager+0x78>
ffffffffc0202466:	f0ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p) == 2);
ffffffffc020246a:	00003697          	auipc	a3,0x3
ffffffffc020246e:	fbe68693          	addi	a3,a3,-66 # ffffffffc0205428 <default_pmm_manager+0x5f0>
ffffffffc0202472:	00002617          	auipc	a2,0x2
ffffffffc0202476:	62e60613          	addi	a2,a2,1582 # ffffffffc0204aa0 <commands+0x870>
ffffffffc020247a:	1d900593          	li	a1,473
ffffffffc020247e:	00003517          	auipc	a0,0x3
ffffffffc0202482:	a3250513          	addi	a0,a0,-1486 # ffffffffc0204eb0 <default_pmm_manager+0x78>
ffffffffc0202486:	eeffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p1) == 0);
ffffffffc020248a:	00003697          	auipc	a3,0x3
ffffffffc020248e:	e1e68693          	addi	a3,a3,-482 # ffffffffc02052a8 <default_pmm_manager+0x470>
ffffffffc0202492:	00002617          	auipc	a2,0x2
ffffffffc0202496:	60e60613          	addi	a2,a2,1550 # ffffffffc0204aa0 <commands+0x870>
ffffffffc020249a:	1b600593          	li	a1,438
ffffffffc020249e:	00003517          	auipc	a0,0x3
ffffffffc02024a2:	a1250513          	addi	a0,a0,-1518 # ffffffffc0204eb0 <default_pmm_manager+0x78>
ffffffffc02024a6:	ecffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc02024aa:	00003697          	auipc	a3,0x3
ffffffffc02024ae:	dce68693          	addi	a3,a3,-562 # ffffffffc0205278 <default_pmm_manager+0x440>
ffffffffc02024b2:	00002617          	auipc	a2,0x2
ffffffffc02024b6:	5ee60613          	addi	a2,a2,1518 # ffffffffc0204aa0 <commands+0x870>
ffffffffc02024ba:	1b300593          	li	a1,435
ffffffffc02024be:	00003517          	auipc	a0,0x3
ffffffffc02024c2:	9f250513          	addi	a0,a0,-1550 # ffffffffc0204eb0 <default_pmm_manager+0x78>
ffffffffc02024c6:	eaffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc02024ca:	00003697          	auipc	a3,0x3
ffffffffc02024ce:	c6e68693          	addi	a3,a3,-914 # ffffffffc0205138 <default_pmm_manager+0x300>
ffffffffc02024d2:	00002617          	auipc	a2,0x2
ffffffffc02024d6:	5ce60613          	addi	a2,a2,1486 # ffffffffc0204aa0 <commands+0x870>
ffffffffc02024da:	1b200593          	li	a1,434
ffffffffc02024de:	00003517          	auipc	a0,0x3
ffffffffc02024e2:	9d250513          	addi	a0,a0,-1582 # ffffffffc0204eb0 <default_pmm_manager+0x78>
ffffffffc02024e6:	e8ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((*ptep & PTE_U) == 0);
ffffffffc02024ea:	00003697          	auipc	a3,0x3
ffffffffc02024ee:	da668693          	addi	a3,a3,-602 # ffffffffc0205290 <default_pmm_manager+0x458>
ffffffffc02024f2:	00002617          	auipc	a2,0x2
ffffffffc02024f6:	5ae60613          	addi	a2,a2,1454 # ffffffffc0204aa0 <commands+0x870>
ffffffffc02024fa:	1af00593          	li	a1,431
ffffffffc02024fe:	00003517          	auipc	a0,0x3
ffffffffc0202502:	9b250513          	addi	a0,a0,-1614 # ffffffffc0204eb0 <default_pmm_manager+0x78>
ffffffffc0202506:	e6ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc020250a:	00003697          	auipc	a3,0x3
ffffffffc020250e:	db668693          	addi	a3,a3,-586 # ffffffffc02052c0 <default_pmm_manager+0x488>
ffffffffc0202512:	00002617          	auipc	a2,0x2
ffffffffc0202516:	58e60613          	addi	a2,a2,1422 # ffffffffc0204aa0 <commands+0x870>
ffffffffc020251a:	1b900593          	li	a1,441
ffffffffc020251e:	00003517          	auipc	a0,0x3
ffffffffc0202522:	99250513          	addi	a0,a0,-1646 # ffffffffc0204eb0 <default_pmm_manager+0x78>
ffffffffc0202526:	e4ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc020252a:	00003697          	auipc	a3,0x3
ffffffffc020252e:	d4e68693          	addi	a3,a3,-690 # ffffffffc0205278 <default_pmm_manager+0x440>
ffffffffc0202532:	00002617          	auipc	a2,0x2
ffffffffc0202536:	56e60613          	addi	a2,a2,1390 # ffffffffc0204aa0 <commands+0x870>
ffffffffc020253a:	1b700593          	li	a1,439
ffffffffc020253e:	00003517          	auipc	a0,0x3
ffffffffc0202542:	97250513          	addi	a0,a0,-1678 # ffffffffc0204eb0 <default_pmm_manager+0x78>
ffffffffc0202546:	e2ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc020254a:	00003697          	auipc	a3,0x3
ffffffffc020254e:	ace68693          	addi	a3,a3,-1330 # ffffffffc0205018 <default_pmm_manager+0x1e0>
ffffffffc0202552:	00002617          	auipc	a2,0x2
ffffffffc0202556:	54e60613          	addi	a2,a2,1358 # ffffffffc0204aa0 <commands+0x870>
ffffffffc020255a:	19200593          	li	a1,402
ffffffffc020255e:	00003517          	auipc	a0,0x3
ffffffffc0202562:	95250513          	addi	a0,a0,-1710 # ffffffffc0204eb0 <default_pmm_manager+0x78>
ffffffffc0202566:	e0ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc020256a:	00003617          	auipc	a2,0x3
ffffffffc020256e:	a6660613          	addi	a2,a2,-1434 # ffffffffc0204fd0 <default_pmm_manager+0x198>
ffffffffc0202572:	0bd00593          	li	a1,189
ffffffffc0202576:	00003517          	auipc	a0,0x3
ffffffffc020257a:	93a50513          	addi	a0,a0,-1734 # ffffffffc0204eb0 <default_pmm_manager+0x78>
ffffffffc020257e:	df7fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0202582:	00003697          	auipc	a3,0x3
ffffffffc0202586:	e6668693          	addi	a3,a3,-410 # ffffffffc02053e8 <default_pmm_manager+0x5b0>
ffffffffc020258a:	00002617          	auipc	a2,0x2
ffffffffc020258e:	51660613          	addi	a2,a2,1302 # ffffffffc0204aa0 <commands+0x870>
ffffffffc0202592:	1d800593          	li	a1,472
ffffffffc0202596:	00003517          	auipc	a0,0x3
ffffffffc020259a:	91a50513          	addi	a0,a0,-1766 # ffffffffc0204eb0 <default_pmm_manager+0x78>
ffffffffc020259e:	dd7fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p) == 1);
ffffffffc02025a2:	00003697          	auipc	a3,0x3
ffffffffc02025a6:	e2e68693          	addi	a3,a3,-466 # ffffffffc02053d0 <default_pmm_manager+0x598>
ffffffffc02025aa:	00002617          	auipc	a2,0x2
ffffffffc02025ae:	4f660613          	addi	a2,a2,1270 # ffffffffc0204aa0 <commands+0x870>
ffffffffc02025b2:	1d700593          	li	a1,471
ffffffffc02025b6:	00003517          	auipc	a0,0x3
ffffffffc02025ba:	8fa50513          	addi	a0,a0,-1798 # ffffffffc0204eb0 <default_pmm_manager+0x78>
ffffffffc02025be:	db7fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc02025c2:	00003697          	auipc	a3,0x3
ffffffffc02025c6:	dd668693          	addi	a3,a3,-554 # ffffffffc0205398 <default_pmm_manager+0x560>
ffffffffc02025ca:	00002617          	auipc	a2,0x2
ffffffffc02025ce:	4d660613          	addi	a2,a2,1238 # ffffffffc0204aa0 <commands+0x870>
ffffffffc02025d2:	1d600593          	li	a1,470
ffffffffc02025d6:	00003517          	auipc	a0,0x3
ffffffffc02025da:	8da50513          	addi	a0,a0,-1830 # ffffffffc0204eb0 <default_pmm_manager+0x78>
ffffffffc02025de:	d97fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(boot_pgdir[0] == 0);
ffffffffc02025e2:	00003697          	auipc	a3,0x3
ffffffffc02025e6:	d9e68693          	addi	a3,a3,-610 # ffffffffc0205380 <default_pmm_manager+0x548>
ffffffffc02025ea:	00002617          	auipc	a2,0x2
ffffffffc02025ee:	4b660613          	addi	a2,a2,1206 # ffffffffc0204aa0 <commands+0x870>
ffffffffc02025f2:	1d200593          	li	a1,466
ffffffffc02025f6:	00003517          	auipc	a0,0x3
ffffffffc02025fa:	8ba50513          	addi	a0,a0,-1862 # ffffffffc0204eb0 <default_pmm_manager+0x78>
ffffffffc02025fe:	d77fd0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0202602 <tlb_invalidate>:
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc0202602:	12000073          	sfence.vma
void tlb_invalidate(pde_t *pgdir, uintptr_t la) { flush_tlb(); }
ffffffffc0202606:	8082                	ret

ffffffffc0202608 <pgdir_alloc_page>:
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0202608:	7179                	addi	sp,sp,-48
ffffffffc020260a:	e84a                	sd	s2,16(sp)
ffffffffc020260c:	892a                	mv	s2,a0
    struct Page *page = alloc_page();
ffffffffc020260e:	4505                	li	a0,1
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0202610:	f022                	sd	s0,32(sp)
ffffffffc0202612:	ec26                	sd	s1,24(sp)
ffffffffc0202614:	e44e                	sd	s3,8(sp)
ffffffffc0202616:	f406                	sd	ra,40(sp)
ffffffffc0202618:	84ae                	mv	s1,a1
ffffffffc020261a:	89b2                	mv	s3,a2
    struct Page *page = alloc_page();
ffffffffc020261c:	852ff0ef          	jal	ra,ffffffffc020166e <alloc_pages>
ffffffffc0202620:	842a                	mv	s0,a0
    if (page != NULL) {
ffffffffc0202622:	cd19                	beqz	a0,ffffffffc0202640 <pgdir_alloc_page+0x38>
        if (page_insert(pgdir, page, la, perm) != 0) {
ffffffffc0202624:	85aa                	mv	a1,a0
ffffffffc0202626:	86ce                	mv	a3,s3
ffffffffc0202628:	8626                	mv	a2,s1
ffffffffc020262a:	854a                	mv	a0,s2
ffffffffc020262c:	c28ff0ef          	jal	ra,ffffffffc0201a54 <page_insert>
ffffffffc0202630:	ed39                	bnez	a0,ffffffffc020268e <pgdir_alloc_page+0x86>
        if (swap_init_ok) {
ffffffffc0202632:	0000e797          	auipc	a5,0xe
ffffffffc0202636:	e3e78793          	addi	a5,a5,-450 # ffffffffc0210470 <swap_init_ok>
ffffffffc020263a:	439c                	lw	a5,0(a5)
ffffffffc020263c:	2781                	sext.w	a5,a5
ffffffffc020263e:	eb89                	bnez	a5,ffffffffc0202650 <pgdir_alloc_page+0x48>
}
ffffffffc0202640:	8522                	mv	a0,s0
ffffffffc0202642:	70a2                	ld	ra,40(sp)
ffffffffc0202644:	7402                	ld	s0,32(sp)
ffffffffc0202646:	64e2                	ld	s1,24(sp)
ffffffffc0202648:	6942                	ld	s2,16(sp)
ffffffffc020264a:	69a2                	ld	s3,8(sp)
ffffffffc020264c:	6145                	addi	sp,sp,48
ffffffffc020264e:	8082                	ret
            swap_map_swappable(check_mm_struct, la, page, 0);
ffffffffc0202650:	0000e797          	auipc	a5,0xe
ffffffffc0202654:	f4878793          	addi	a5,a5,-184 # ffffffffc0210598 <check_mm_struct>
ffffffffc0202658:	6388                	ld	a0,0(a5)
ffffffffc020265a:	4681                	li	a3,0
ffffffffc020265c:	8622                	mv	a2,s0
ffffffffc020265e:	85a6                	mv	a1,s1
ffffffffc0202660:	06d000ef          	jal	ra,ffffffffc0202ecc <swap_map_swappable>
            assert(page_ref(page) == 1);
ffffffffc0202664:	4018                	lw	a4,0(s0)
            page->pra_vaddr = la;
ffffffffc0202666:	e024                	sd	s1,64(s0)
            assert(page_ref(page) == 1);
ffffffffc0202668:	4785                	li	a5,1
ffffffffc020266a:	fcf70be3          	beq	a4,a5,ffffffffc0202640 <pgdir_alloc_page+0x38>
ffffffffc020266e:	00003697          	auipc	a3,0x3
ffffffffc0202672:	8c268693          	addi	a3,a3,-1854 # ffffffffc0204f30 <default_pmm_manager+0xf8>
ffffffffc0202676:	00002617          	auipc	a2,0x2
ffffffffc020267a:	42a60613          	addi	a2,a2,1066 # ffffffffc0204aa0 <commands+0x870>
ffffffffc020267e:	17a00593          	li	a1,378
ffffffffc0202682:	00003517          	auipc	a0,0x3
ffffffffc0202686:	82e50513          	addi	a0,a0,-2002 # ffffffffc0204eb0 <default_pmm_manager+0x78>
ffffffffc020268a:	cebfd0ef          	jal	ra,ffffffffc0200374 <__panic>
            free_page(page);
ffffffffc020268e:	8522                	mv	a0,s0
ffffffffc0202690:	4585                	li	a1,1
ffffffffc0202692:	864ff0ef          	jal	ra,ffffffffc02016f6 <free_pages>
            return NULL;
ffffffffc0202696:	4401                	li	s0,0
ffffffffc0202698:	b765                	j	ffffffffc0202640 <pgdir_alloc_page+0x38>

ffffffffc020269a <kmalloc>:
}

void *kmalloc(size_t n) {
ffffffffc020269a:	1141                	addi	sp,sp,-16
    void *ptr = NULL;
    struct Page *base = NULL;
    assert(n > 0 && n < 1024 * 0124);
ffffffffc020269c:	67d5                	lui	a5,0x15
void *kmalloc(size_t n) {
ffffffffc020269e:	e406                	sd	ra,8(sp)
    assert(n > 0 && n < 1024 * 0124);
ffffffffc02026a0:	fff50713          	addi	a4,a0,-1
ffffffffc02026a4:	17f9                	addi	a5,a5,-2
ffffffffc02026a6:	04e7ee63          	bltu	a5,a4,ffffffffc0202702 <kmalloc+0x68>
    int num_pages = (n + PGSIZE - 1) / PGSIZE;
ffffffffc02026aa:	6785                	lui	a5,0x1
ffffffffc02026ac:	17fd                	addi	a5,a5,-1
ffffffffc02026ae:	953e                	add	a0,a0,a5
    base = alloc_pages(num_pages);
ffffffffc02026b0:	8131                	srli	a0,a0,0xc
ffffffffc02026b2:	fbdfe0ef          	jal	ra,ffffffffc020166e <alloc_pages>
    assert(base != NULL);
ffffffffc02026b6:	c159                	beqz	a0,ffffffffc020273c <kmalloc+0xa2>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02026b8:	0000e797          	auipc	a5,0xe
ffffffffc02026bc:	df878793          	addi	a5,a5,-520 # ffffffffc02104b0 <pages>
ffffffffc02026c0:	639c                	ld	a5,0(a5)
ffffffffc02026c2:	8d1d                	sub	a0,a0,a5
ffffffffc02026c4:	00002797          	auipc	a5,0x2
ffffffffc02026c8:	3c478793          	addi	a5,a5,964 # ffffffffc0204a88 <commands+0x858>
ffffffffc02026cc:	6394                	ld	a3,0(a5)
ffffffffc02026ce:	850d                	srai	a0,a0,0x3
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc02026d0:	0000e797          	auipc	a5,0xe
ffffffffc02026d4:	d9078793          	addi	a5,a5,-624 # ffffffffc0210460 <npage>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02026d8:	02d50533          	mul	a0,a0,a3
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc02026dc:	6398                	ld	a4,0(a5)
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02026de:	000806b7          	lui	a3,0x80
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc02026e2:	57fd                	li	a5,-1
ffffffffc02026e4:	83b1                	srli	a5,a5,0xc
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02026e6:	9536                	add	a0,a0,a3
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc02026e8:	8fe9                	and	a5,a5,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc02026ea:	0532                	slli	a0,a0,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc02026ec:	02e7fb63          	bleu	a4,a5,ffffffffc0202722 <kmalloc+0x88>
ffffffffc02026f0:	0000e797          	auipc	a5,0xe
ffffffffc02026f4:	db078793          	addi	a5,a5,-592 # ffffffffc02104a0 <va_pa_offset>
ffffffffc02026f8:	639c                	ld	a5,0(a5)
    ptr = page2kva(base);
    return ptr;
}
ffffffffc02026fa:	60a2                	ld	ra,8(sp)
ffffffffc02026fc:	953e                	add	a0,a0,a5
ffffffffc02026fe:	0141                	addi	sp,sp,16
ffffffffc0202700:	8082                	ret
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0202702:	00002697          	auipc	a3,0x2
ffffffffc0202706:	7ce68693          	addi	a3,a3,1998 # ffffffffc0204ed0 <default_pmm_manager+0x98>
ffffffffc020270a:	00002617          	auipc	a2,0x2
ffffffffc020270e:	39660613          	addi	a2,a2,918 # ffffffffc0204aa0 <commands+0x870>
ffffffffc0202712:	1f000593          	li	a1,496
ffffffffc0202716:	00002517          	auipc	a0,0x2
ffffffffc020271a:	79a50513          	addi	a0,a0,1946 # ffffffffc0204eb0 <default_pmm_manager+0x78>
ffffffffc020271e:	c57fd0ef          	jal	ra,ffffffffc0200374 <__panic>
ffffffffc0202722:	86aa                	mv	a3,a0
ffffffffc0202724:	00002617          	auipc	a2,0x2
ffffffffc0202728:	76460613          	addi	a2,a2,1892 # ffffffffc0204e88 <default_pmm_manager+0x50>
ffffffffc020272c:	06a00593          	li	a1,106
ffffffffc0202730:	00002517          	auipc	a0,0x2
ffffffffc0202734:	7f050513          	addi	a0,a0,2032 # ffffffffc0204f20 <default_pmm_manager+0xe8>
ffffffffc0202738:	c3dfd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(base != NULL);
ffffffffc020273c:	00002697          	auipc	a3,0x2
ffffffffc0202740:	7b468693          	addi	a3,a3,1972 # ffffffffc0204ef0 <default_pmm_manager+0xb8>
ffffffffc0202744:	00002617          	auipc	a2,0x2
ffffffffc0202748:	35c60613          	addi	a2,a2,860 # ffffffffc0204aa0 <commands+0x870>
ffffffffc020274c:	1f300593          	li	a1,499
ffffffffc0202750:	00002517          	auipc	a0,0x2
ffffffffc0202754:	76050513          	addi	a0,a0,1888 # ffffffffc0204eb0 <default_pmm_manager+0x78>
ffffffffc0202758:	c1dfd0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc020275c <kfree>:

void kfree(void *ptr, size_t n) {
ffffffffc020275c:	1141                	addi	sp,sp,-16
    assert(n > 0 && n < 1024 * 0124);
ffffffffc020275e:	67d5                	lui	a5,0x15
void kfree(void *ptr, size_t n) {
ffffffffc0202760:	e406                	sd	ra,8(sp)
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0202762:	fff58713          	addi	a4,a1,-1
ffffffffc0202766:	17f9                	addi	a5,a5,-2
ffffffffc0202768:	04e7eb63          	bltu	a5,a4,ffffffffc02027be <kfree+0x62>
    assert(ptr != NULL);
ffffffffc020276c:	c941                	beqz	a0,ffffffffc02027fc <kfree+0xa0>
    struct Page *base = NULL;
    int num_pages = (n + PGSIZE - 1) / PGSIZE;
ffffffffc020276e:	6785                	lui	a5,0x1
ffffffffc0202770:	17fd                	addi	a5,a5,-1
ffffffffc0202772:	95be                	add	a1,a1,a5
static inline struct Page *kva2page(void *kva) { return pa2page(PADDR(kva)); }
ffffffffc0202774:	c02007b7          	lui	a5,0xc0200
ffffffffc0202778:	81b1                	srli	a1,a1,0xc
ffffffffc020277a:	06f56463          	bltu	a0,a5,ffffffffc02027e2 <kfree+0x86>
ffffffffc020277e:	0000e797          	auipc	a5,0xe
ffffffffc0202782:	d2278793          	addi	a5,a5,-734 # ffffffffc02104a0 <va_pa_offset>
ffffffffc0202786:	639c                	ld	a5,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc0202788:	0000e717          	auipc	a4,0xe
ffffffffc020278c:	cd870713          	addi	a4,a4,-808 # ffffffffc0210460 <npage>
ffffffffc0202790:	6318                	ld	a4,0(a4)
static inline struct Page *kva2page(void *kva) { return pa2page(PADDR(kva)); }
ffffffffc0202792:	40f507b3          	sub	a5,a0,a5
    if (PPN(pa) >= npage) {
ffffffffc0202796:	83b1                	srli	a5,a5,0xc
ffffffffc0202798:	04e7f363          	bleu	a4,a5,ffffffffc02027de <kfree+0x82>
    return &pages[PPN(pa) - nbase];
ffffffffc020279c:	fff80537          	lui	a0,0xfff80
ffffffffc02027a0:	97aa                	add	a5,a5,a0
ffffffffc02027a2:	0000e697          	auipc	a3,0xe
ffffffffc02027a6:	d0e68693          	addi	a3,a3,-754 # ffffffffc02104b0 <pages>
ffffffffc02027aa:	6288                	ld	a0,0(a3)
ffffffffc02027ac:	00379713          	slli	a4,a5,0x3
    base = kva2page(ptr);
    free_pages(base, num_pages);
}
ffffffffc02027b0:	60a2                	ld	ra,8(sp)
ffffffffc02027b2:	97ba                	add	a5,a5,a4
ffffffffc02027b4:	078e                	slli	a5,a5,0x3
    free_pages(base, num_pages);
ffffffffc02027b6:	953e                	add	a0,a0,a5
}
ffffffffc02027b8:	0141                	addi	sp,sp,16
    free_pages(base, num_pages);
ffffffffc02027ba:	f3dfe06f          	j	ffffffffc02016f6 <free_pages>
    assert(n > 0 && n < 1024 * 0124);
ffffffffc02027be:	00002697          	auipc	a3,0x2
ffffffffc02027c2:	71268693          	addi	a3,a3,1810 # ffffffffc0204ed0 <default_pmm_manager+0x98>
ffffffffc02027c6:	00002617          	auipc	a2,0x2
ffffffffc02027ca:	2da60613          	addi	a2,a2,730 # ffffffffc0204aa0 <commands+0x870>
ffffffffc02027ce:	1f900593          	li	a1,505
ffffffffc02027d2:	00002517          	auipc	a0,0x2
ffffffffc02027d6:	6de50513          	addi	a0,a0,1758 # ffffffffc0204eb0 <default_pmm_manager+0x78>
ffffffffc02027da:	b9bfd0ef          	jal	ra,ffffffffc0200374 <__panic>
ffffffffc02027de:	e75fe0ef          	jal	ra,ffffffffc0201652 <pa2page.part.4>
static inline struct Page *kva2page(void *kva) { return pa2page(PADDR(kva)); }
ffffffffc02027e2:	86aa                	mv	a3,a0
ffffffffc02027e4:	00002617          	auipc	a2,0x2
ffffffffc02027e8:	7ec60613          	addi	a2,a2,2028 # ffffffffc0204fd0 <default_pmm_manager+0x198>
ffffffffc02027ec:	06c00593          	li	a1,108
ffffffffc02027f0:	00002517          	auipc	a0,0x2
ffffffffc02027f4:	73050513          	addi	a0,a0,1840 # ffffffffc0204f20 <default_pmm_manager+0xe8>
ffffffffc02027f8:	b7dfd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(ptr != NULL);
ffffffffc02027fc:	00002697          	auipc	a3,0x2
ffffffffc0202800:	6c468693          	addi	a3,a3,1732 # ffffffffc0204ec0 <default_pmm_manager+0x88>
ffffffffc0202804:	00002617          	auipc	a2,0x2
ffffffffc0202808:	29c60613          	addi	a2,a2,668 # ffffffffc0204aa0 <commands+0x870>
ffffffffc020280c:	1fa00593          	li	a1,506
ffffffffc0202810:	00002517          	auipc	a0,0x2
ffffffffc0202814:	6a050513          	addi	a0,a0,1696 # ffffffffc0204eb0 <default_pmm_manager+0x78>
ffffffffc0202818:	b5dfd0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc020281c <swap_init>:

static void check_swap(void);

int
swap_init(void)
{
ffffffffc020281c:	7135                	addi	sp,sp,-160
ffffffffc020281e:	ed06                	sd	ra,152(sp)
ffffffffc0202820:	e922                	sd	s0,144(sp)
ffffffffc0202822:	e526                	sd	s1,136(sp)
ffffffffc0202824:	e14a                	sd	s2,128(sp)
ffffffffc0202826:	fcce                	sd	s3,120(sp)
ffffffffc0202828:	f8d2                	sd	s4,112(sp)
ffffffffc020282a:	f4d6                	sd	s5,104(sp)
ffffffffc020282c:	f0da                	sd	s6,96(sp)
ffffffffc020282e:	ecde                	sd	s7,88(sp)
ffffffffc0202830:	e8e2                	sd	s8,80(sp)
ffffffffc0202832:	e4e6                	sd	s9,72(sp)
ffffffffc0202834:	e0ea                	sd	s10,64(sp)
ffffffffc0202836:	fc6e                	sd	s11,56(sp)
     swapfs_init();
ffffffffc0202838:	274010ef          	jal	ra,ffffffffc0203aac <swapfs_init>

     // Since the IDE is faked, it can only store 7 pages at most to pass the test
     if (!(7 <= max_swap_offset &&
ffffffffc020283c:	0000e797          	auipc	a5,0xe
ffffffffc0202840:	d0478793          	addi	a5,a5,-764 # ffffffffc0210540 <max_swap_offset>
ffffffffc0202844:	6394                	ld	a3,0(a5)
ffffffffc0202846:	010007b7          	lui	a5,0x1000
ffffffffc020284a:	17e1                	addi	a5,a5,-8
ffffffffc020284c:	ff968713          	addi	a4,a3,-7
ffffffffc0202850:	42e7ea63          	bltu	a5,a4,ffffffffc0202c84 <swap_init+0x468>
        max_swap_offset < MAX_SWAP_OFFSET_LIMIT)) {
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
     }

     sm = &swap_manager_clock;//use first in first out Page Replacement Algorithm
ffffffffc0202854:	00006797          	auipc	a5,0x6
ffffffffc0202858:	7ac78793          	addi	a5,a5,1964 # ffffffffc0209000 <swap_manager_clock>
     int r = sm->init();
ffffffffc020285c:	6798                	ld	a4,8(a5)
     sm = &swap_manager_clock;//use first in first out Page Replacement Algorithm
ffffffffc020285e:	0000e697          	auipc	a3,0xe
ffffffffc0202862:	c0f6b523          	sd	a5,-1014(a3) # ffffffffc0210468 <sm>
     int r = sm->init();
ffffffffc0202866:	9702                	jalr	a4
ffffffffc0202868:	8b2a                	mv	s6,a0
     
     if (r == 0)
ffffffffc020286a:	c10d                	beqz	a0,ffffffffc020288c <swap_init+0x70>
          cprintf("SWAP: manager = %s\n", sm->name);
          check_swap();
     }

     return r;
}
ffffffffc020286c:	60ea                	ld	ra,152(sp)
ffffffffc020286e:	644a                	ld	s0,144(sp)
ffffffffc0202870:	855a                	mv	a0,s6
ffffffffc0202872:	64aa                	ld	s1,136(sp)
ffffffffc0202874:	690a                	ld	s2,128(sp)
ffffffffc0202876:	79e6                	ld	s3,120(sp)
ffffffffc0202878:	7a46                	ld	s4,112(sp)
ffffffffc020287a:	7aa6                	ld	s5,104(sp)
ffffffffc020287c:	7b06                	ld	s6,96(sp)
ffffffffc020287e:	6be6                	ld	s7,88(sp)
ffffffffc0202880:	6c46                	ld	s8,80(sp)
ffffffffc0202882:	6ca6                	ld	s9,72(sp)
ffffffffc0202884:	6d06                	ld	s10,64(sp)
ffffffffc0202886:	7de2                	ld	s11,56(sp)
ffffffffc0202888:	610d                	addi	sp,sp,160
ffffffffc020288a:	8082                	ret
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc020288c:	0000e797          	auipc	a5,0xe
ffffffffc0202890:	bdc78793          	addi	a5,a5,-1060 # ffffffffc0210468 <sm>
ffffffffc0202894:	639c                	ld	a5,0(a5)
ffffffffc0202896:	00003517          	auipc	a0,0x3
ffffffffc020289a:	c7250513          	addi	a0,a0,-910 # ffffffffc0205508 <default_pmm_manager+0x6d0>
    return listelm->next;
ffffffffc020289e:	0000e417          	auipc	s0,0xe
ffffffffc02028a2:	be240413          	addi	s0,s0,-1054 # ffffffffc0210480 <free_area>
ffffffffc02028a6:	638c                	ld	a1,0(a5)
          swap_init_ok = 1;
ffffffffc02028a8:	4785                	li	a5,1
ffffffffc02028aa:	0000e717          	auipc	a4,0xe
ffffffffc02028ae:	bcf72323          	sw	a5,-1082(a4) # ffffffffc0210470 <swap_init_ok>
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc02028b2:	80dfd0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc02028b6:	641c                	ld	a5,8(s0)
check_swap(void)
{
    //backup mem env
     int ret, count = 0, total = 0, i;
     list_entry_t *le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc02028b8:	2e878a63          	beq	a5,s0,ffffffffc0202bac <swap_init+0x390>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc02028bc:	fe87b703          	ld	a4,-24(a5)
ffffffffc02028c0:	8305                	srli	a4,a4,0x1
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc02028c2:	8b05                	andi	a4,a4,1
ffffffffc02028c4:	2e070863          	beqz	a4,ffffffffc0202bb4 <swap_init+0x398>
     int ret, count = 0, total = 0, i;
ffffffffc02028c8:	4481                	li	s1,0
ffffffffc02028ca:	4901                	li	s2,0
ffffffffc02028cc:	a031                	j	ffffffffc02028d8 <swap_init+0xbc>
ffffffffc02028ce:	fe87b703          	ld	a4,-24(a5)
        assert(PageProperty(p));
ffffffffc02028d2:	8b09                	andi	a4,a4,2
ffffffffc02028d4:	2e070063          	beqz	a4,ffffffffc0202bb4 <swap_init+0x398>
        count ++, total += p->property;
ffffffffc02028d8:	ff87a703          	lw	a4,-8(a5)
ffffffffc02028dc:	679c                	ld	a5,8(a5)
ffffffffc02028de:	2905                	addiw	s2,s2,1
ffffffffc02028e0:	9cb9                	addw	s1,s1,a4
     while ((le = list_next(le)) != &free_list) {
ffffffffc02028e2:	fe8796e3          	bne	a5,s0,ffffffffc02028ce <swap_init+0xb2>
ffffffffc02028e6:	89a6                	mv	s3,s1
     }
     assert(total == nr_free_pages());
ffffffffc02028e8:	e55fe0ef          	jal	ra,ffffffffc020173c <nr_free_pages>
ffffffffc02028ec:	5b351863          	bne	a0,s3,ffffffffc0202e9c <swap_init+0x680>
     cprintf("BEGIN check_swap: count %d, total %d\n",count,total);
ffffffffc02028f0:	8626                	mv	a2,s1
ffffffffc02028f2:	85ca                	mv	a1,s2
ffffffffc02028f4:	00003517          	auipc	a0,0x3
ffffffffc02028f8:	c2c50513          	addi	a0,a0,-980 # ffffffffc0205520 <default_pmm_manager+0x6e8>
ffffffffc02028fc:	fc2fd0ef          	jal	ra,ffffffffc02000be <cprintf>
     
     //now we set the phy pages env     
     struct mm_struct *mm = mm_create();
ffffffffc0202900:	203000ef          	jal	ra,ffffffffc0203302 <mm_create>
ffffffffc0202904:	8baa                	mv	s7,a0
     assert(mm != NULL);
ffffffffc0202906:	50050b63          	beqz	a0,ffffffffc0202e1c <swap_init+0x600>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
ffffffffc020290a:	0000e797          	auipc	a5,0xe
ffffffffc020290e:	c8e78793          	addi	a5,a5,-882 # ffffffffc0210598 <check_mm_struct>
ffffffffc0202912:	639c                	ld	a5,0(a5)
ffffffffc0202914:	52079463          	bnez	a5,ffffffffc0202e3c <swap_init+0x620>

     check_mm_struct = mm;

     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0202918:	0000e797          	auipc	a5,0xe
ffffffffc020291c:	b4078793          	addi	a5,a5,-1216 # ffffffffc0210458 <boot_pgdir>
ffffffffc0202920:	6398                	ld	a4,0(a5)
     check_mm_struct = mm;
ffffffffc0202922:	0000e797          	auipc	a5,0xe
ffffffffc0202926:	c6a7bb23          	sd	a0,-906(a5) # ffffffffc0210598 <check_mm_struct>
     assert(pgdir[0] == 0);
ffffffffc020292a:	631c                	ld	a5,0(a4)
     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc020292c:	ec3a                	sd	a4,24(sp)
ffffffffc020292e:	ed18                	sd	a4,24(a0)
     assert(pgdir[0] == 0);
ffffffffc0202930:	52079663          	bnez	a5,ffffffffc0202e5c <swap_init+0x640>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
ffffffffc0202934:	6599                	lui	a1,0x6
ffffffffc0202936:	460d                	li	a2,3
ffffffffc0202938:	6505                	lui	a0,0x1
ffffffffc020293a:	215000ef          	jal	ra,ffffffffc020334e <vma_create>
ffffffffc020293e:	85aa                	mv	a1,a0
     assert(vma != NULL);
ffffffffc0202940:	52050e63          	beqz	a0,ffffffffc0202e7c <swap_init+0x660>

     insert_vma_struct(mm, vma);
ffffffffc0202944:	855e                	mv	a0,s7
ffffffffc0202946:	275000ef          	jal	ra,ffffffffc02033ba <insert_vma_struct>

     //setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
ffffffffc020294a:	00003517          	auipc	a0,0x3
ffffffffc020294e:	c4650513          	addi	a0,a0,-954 # ffffffffc0205590 <default_pmm_manager+0x758>
ffffffffc0202952:	f6cfd0ef          	jal	ra,ffffffffc02000be <cprintf>
     pte_t *temp_ptep=NULL;
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
ffffffffc0202956:	018bb503          	ld	a0,24(s7)
ffffffffc020295a:	4605                	li	a2,1
ffffffffc020295c:	6585                	lui	a1,0x1
ffffffffc020295e:	e1ffe0ef          	jal	ra,ffffffffc020177c <get_pte>
     assert(temp_ptep!= NULL);
ffffffffc0202962:	40050d63          	beqz	a0,ffffffffc0202d7c <swap_init+0x560>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc0202966:	00003517          	auipc	a0,0x3
ffffffffc020296a:	c7a50513          	addi	a0,a0,-902 # ffffffffc02055e0 <default_pmm_manager+0x7a8>
ffffffffc020296e:	0000ea17          	auipc	s4,0xe
ffffffffc0202972:	b4aa0a13          	addi	s4,s4,-1206 # ffffffffc02104b8 <check_rp>
ffffffffc0202976:	f48fd0ef          	jal	ra,ffffffffc02000be <cprintf>
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc020297a:	0000ea97          	auipc	s5,0xe
ffffffffc020297e:	b5ea8a93          	addi	s5,s5,-1186 # ffffffffc02104d8 <swap_in_seq_no>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc0202982:	89d2                	mv	s3,s4
          check_rp[i] = alloc_page();
ffffffffc0202984:	4505                	li	a0,1
ffffffffc0202986:	ce9fe0ef          	jal	ra,ffffffffc020166e <alloc_pages>
ffffffffc020298a:	00a9b023          	sd	a0,0(s3) # fffffffffff80000 <end+0x3fd6fa60>
          assert(check_rp[i] != NULL );
ffffffffc020298e:	2a050b63          	beqz	a0,ffffffffc0202c44 <swap_init+0x428>
ffffffffc0202992:	651c                	ld	a5,8(a0)
          assert(!PageProperty(check_rp[i]));
ffffffffc0202994:	8b89                	andi	a5,a5,2
ffffffffc0202996:	28079763          	bnez	a5,ffffffffc0202c24 <swap_init+0x408>
ffffffffc020299a:	09a1                	addi	s3,s3,8
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc020299c:	ff5994e3          	bne	s3,s5,ffffffffc0202984 <swap_init+0x168>
     }
     list_entry_t free_list_store = free_list;
ffffffffc02029a0:	601c                	ld	a5,0(s0)
ffffffffc02029a2:	00843983          	ld	s3,8(s0)
     assert(list_empty(&free_list));
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
     nr_free = 0;
ffffffffc02029a6:	0000ed17          	auipc	s10,0xe
ffffffffc02029aa:	b12d0d13          	addi	s10,s10,-1262 # ffffffffc02104b8 <check_rp>
     list_entry_t free_list_store = free_list;
ffffffffc02029ae:	f03e                	sd	a5,32(sp)
     unsigned int nr_free_store = nr_free;
ffffffffc02029b0:	481c                	lw	a5,16(s0)
ffffffffc02029b2:	f43e                	sd	a5,40(sp)
    elm->prev = elm->next = elm;
ffffffffc02029b4:	0000e797          	auipc	a5,0xe
ffffffffc02029b8:	ac87ba23          	sd	s0,-1324(a5) # ffffffffc0210488 <free_area+0x8>
ffffffffc02029bc:	0000e797          	auipc	a5,0xe
ffffffffc02029c0:	ac87b223          	sd	s0,-1340(a5) # ffffffffc0210480 <free_area>
     nr_free = 0;
ffffffffc02029c4:	0000e797          	auipc	a5,0xe
ffffffffc02029c8:	ac07a623          	sw	zero,-1332(a5) # ffffffffc0210490 <free_area+0x10>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
        free_pages(check_rp[i],1);
ffffffffc02029cc:	000d3503          	ld	a0,0(s10)
ffffffffc02029d0:	4585                	li	a1,1
ffffffffc02029d2:	0d21                	addi	s10,s10,8
ffffffffc02029d4:	d23fe0ef          	jal	ra,ffffffffc02016f6 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02029d8:	ff5d1ae3          	bne	s10,s5,ffffffffc02029cc <swap_init+0x1b0>
     }
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc02029dc:	01042d03          	lw	s10,16(s0)
ffffffffc02029e0:	4791                	li	a5,4
ffffffffc02029e2:	36fd1d63          	bne	s10,a5,ffffffffc0202d5c <swap_init+0x540>
     
     cprintf("set up init env for check_swap begin!\n");
ffffffffc02029e6:	00003517          	auipc	a0,0x3
ffffffffc02029ea:	c8250513          	addi	a0,a0,-894 # ffffffffc0205668 <default_pmm_manager+0x830>
ffffffffc02029ee:	ed0fd0ef          	jal	ra,ffffffffc02000be <cprintf>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc02029f2:	6685                	lui	a3,0x1
     //setup initial vir_page<->phy_page environment for page relpacement algorithm 

     
     pgfault_num=0;
ffffffffc02029f4:	0000e797          	auipc	a5,0xe
ffffffffc02029f8:	a807a023          	sw	zero,-1408(a5) # ffffffffc0210474 <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc02029fc:	4629                	li	a2,10
     pgfault_num=0;
ffffffffc02029fe:	0000e797          	auipc	a5,0xe
ffffffffc0202a02:	a7678793          	addi	a5,a5,-1418 # ffffffffc0210474 <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0202a06:	00c68023          	sb	a2,0(a3) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
     assert(pgfault_num==1);
ffffffffc0202a0a:	4398                	lw	a4,0(a5)
ffffffffc0202a0c:	4585                	li	a1,1
ffffffffc0202a0e:	2701                	sext.w	a4,a4
ffffffffc0202a10:	30b71663          	bne	a4,a1,ffffffffc0202d1c <swap_init+0x500>
     *(unsigned char *)0x1010 = 0x0a;
ffffffffc0202a14:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==1);
ffffffffc0202a18:	4394                	lw	a3,0(a5)
ffffffffc0202a1a:	2681                	sext.w	a3,a3
ffffffffc0202a1c:	32e69063          	bne	a3,a4,ffffffffc0202d3c <swap_init+0x520>
     *(unsigned char *)0x2000 = 0x0b;
ffffffffc0202a20:	6689                	lui	a3,0x2
ffffffffc0202a22:	462d                	li	a2,11
ffffffffc0202a24:	00c68023          	sb	a2,0(a3) # 2000 <BASE_ADDRESS-0xffffffffc01fe000>
     assert(pgfault_num==2);
ffffffffc0202a28:	4398                	lw	a4,0(a5)
ffffffffc0202a2a:	4589                	li	a1,2
ffffffffc0202a2c:	2701                	sext.w	a4,a4
ffffffffc0202a2e:	26b71763          	bne	a4,a1,ffffffffc0202c9c <swap_init+0x480>
     *(unsigned char *)0x2010 = 0x0b;
ffffffffc0202a32:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==2);
ffffffffc0202a36:	4394                	lw	a3,0(a5)
ffffffffc0202a38:	2681                	sext.w	a3,a3
ffffffffc0202a3a:	28e69163          	bne	a3,a4,ffffffffc0202cbc <swap_init+0x4a0>
     *(unsigned char *)0x3000 = 0x0c;
ffffffffc0202a3e:	668d                	lui	a3,0x3
ffffffffc0202a40:	4631                	li	a2,12
ffffffffc0202a42:	00c68023          	sb	a2,0(a3) # 3000 <BASE_ADDRESS-0xffffffffc01fd000>
     assert(pgfault_num==3);
ffffffffc0202a46:	4398                	lw	a4,0(a5)
ffffffffc0202a48:	458d                	li	a1,3
ffffffffc0202a4a:	2701                	sext.w	a4,a4
ffffffffc0202a4c:	28b71863          	bne	a4,a1,ffffffffc0202cdc <swap_init+0x4c0>
     *(unsigned char *)0x3010 = 0x0c;
ffffffffc0202a50:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==3);
ffffffffc0202a54:	4394                	lw	a3,0(a5)
ffffffffc0202a56:	2681                	sext.w	a3,a3
ffffffffc0202a58:	2ae69263          	bne	a3,a4,ffffffffc0202cfc <swap_init+0x4e0>
     *(unsigned char *)0x4000 = 0x0d;
ffffffffc0202a5c:	6691                	lui	a3,0x4
ffffffffc0202a5e:	4635                	li	a2,13
ffffffffc0202a60:	00c68023          	sb	a2,0(a3) # 4000 <BASE_ADDRESS-0xffffffffc01fc000>
     assert(pgfault_num==4);
ffffffffc0202a64:	4398                	lw	a4,0(a5)
ffffffffc0202a66:	2701                	sext.w	a4,a4
ffffffffc0202a68:	33a71a63          	bne	a4,s10,ffffffffc0202d9c <swap_init+0x580>
     *(unsigned char *)0x4010 = 0x0d;
ffffffffc0202a6c:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==4);
ffffffffc0202a70:	439c                	lw	a5,0(a5)
ffffffffc0202a72:	2781                	sext.w	a5,a5
ffffffffc0202a74:	34e79463          	bne	a5,a4,ffffffffc0202dbc <swap_init+0x5a0>
     
     check_content_set();
     assert( nr_free == 0);         
ffffffffc0202a78:	481c                	lw	a5,16(s0)
ffffffffc0202a7a:	36079163          	bnez	a5,ffffffffc0202ddc <swap_init+0x5c0>
ffffffffc0202a7e:	0000e797          	auipc	a5,0xe
ffffffffc0202a82:	a5a78793          	addi	a5,a5,-1446 # ffffffffc02104d8 <swap_in_seq_no>
ffffffffc0202a86:	0000e717          	auipc	a4,0xe
ffffffffc0202a8a:	a7a70713          	addi	a4,a4,-1414 # ffffffffc0210500 <swap_out_seq_no>
ffffffffc0202a8e:	0000e617          	auipc	a2,0xe
ffffffffc0202a92:	a7260613          	addi	a2,a2,-1422 # ffffffffc0210500 <swap_out_seq_no>
     for(i = 0; i<MAX_SEQ_NO ; i++) 
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
ffffffffc0202a96:	56fd                	li	a3,-1
ffffffffc0202a98:	c394                	sw	a3,0(a5)
ffffffffc0202a9a:	c314                	sw	a3,0(a4)
ffffffffc0202a9c:	0791                	addi	a5,a5,4
ffffffffc0202a9e:	0711                	addi	a4,a4,4
     for(i = 0; i<MAX_SEQ_NO ; i++) 
ffffffffc0202aa0:	fec79ce3          	bne	a5,a2,ffffffffc0202a98 <swap_init+0x27c>
ffffffffc0202aa4:	0000e697          	auipc	a3,0xe
ffffffffc0202aa8:	abc68693          	addi	a3,a3,-1348 # ffffffffc0210560 <check_ptep>
ffffffffc0202aac:	0000e817          	auipc	a6,0xe
ffffffffc0202ab0:	a0c80813          	addi	a6,a6,-1524 # ffffffffc02104b8 <check_rp>
ffffffffc0202ab4:	6c05                	lui	s8,0x1
    if (PPN(pa) >= npage) {
ffffffffc0202ab6:	0000ec97          	auipc	s9,0xe
ffffffffc0202aba:	9aac8c93          	addi	s9,s9,-1622 # ffffffffc0210460 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc0202abe:	0000ed97          	auipc	s11,0xe
ffffffffc0202ac2:	9f2d8d93          	addi	s11,s11,-1550 # ffffffffc02104b0 <pages>
ffffffffc0202ac6:	00003d17          	auipc	s10,0x3
ffffffffc0202aca:	3d2d0d13          	addi	s10,s10,978 # ffffffffc0205e98 <nbase>
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         check_ptep[i]=0;
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202ace:	6562                	ld	a0,24(sp)
         check_ptep[i]=0;
ffffffffc0202ad0:	0006b023          	sd	zero,0(a3)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202ad4:	4601                	li	a2,0
ffffffffc0202ad6:	85e2                	mv	a1,s8
ffffffffc0202ad8:	e842                	sd	a6,16(sp)
         check_ptep[i]=0;
ffffffffc0202ada:	e436                	sd	a3,8(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202adc:	ca1fe0ef          	jal	ra,ffffffffc020177c <get_pte>
ffffffffc0202ae0:	66a2                	ld	a3,8(sp)
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
ffffffffc0202ae2:	6842                	ld	a6,16(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202ae4:	e288                	sd	a0,0(a3)
         assert(check_ptep[i] != NULL);
ffffffffc0202ae6:	16050f63          	beqz	a0,ffffffffc0202c64 <swap_init+0x448>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0202aea:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0202aec:	0017f613          	andi	a2,a5,1
ffffffffc0202af0:	10060263          	beqz	a2,ffffffffc0202bf4 <swap_init+0x3d8>
    if (PPN(pa) >= npage) {
ffffffffc0202af4:	000cb603          	ld	a2,0(s9)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202af8:	078a                	slli	a5,a5,0x2
ffffffffc0202afa:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202afc:	10c7f863          	bleu	a2,a5,ffffffffc0202c0c <swap_init+0x3f0>
    return &pages[PPN(pa) - nbase];
ffffffffc0202b00:	000d3603          	ld	a2,0(s10)
ffffffffc0202b04:	000db583          	ld	a1,0(s11)
ffffffffc0202b08:	00083503          	ld	a0,0(a6)
ffffffffc0202b0c:	8f91                	sub	a5,a5,a2
ffffffffc0202b0e:	00379613          	slli	a2,a5,0x3
ffffffffc0202b12:	97b2                	add	a5,a5,a2
ffffffffc0202b14:	078e                	slli	a5,a5,0x3
ffffffffc0202b16:	97ae                	add	a5,a5,a1
ffffffffc0202b18:	0af51e63          	bne	a0,a5,ffffffffc0202bd4 <swap_init+0x3b8>
ffffffffc0202b1c:	6785                	lui	a5,0x1
ffffffffc0202b1e:	9c3e                	add	s8,s8,a5
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202b20:	6795                	lui	a5,0x5
ffffffffc0202b22:	06a1                	addi	a3,a3,8
ffffffffc0202b24:	0821                	addi	a6,a6,8
ffffffffc0202b26:	fafc14e3          	bne	s8,a5,ffffffffc0202ace <swap_init+0x2b2>
         assert((*check_ptep[i] & PTE_V));          
     }
     cprintf("set up init env for check_swap over!\n");
ffffffffc0202b2a:	00003517          	auipc	a0,0x3
ffffffffc0202b2e:	be650513          	addi	a0,a0,-1050 # ffffffffc0205710 <default_pmm_manager+0x8d8>
ffffffffc0202b32:	d8cfd0ef          	jal	ra,ffffffffc02000be <cprintf>
    int ret = sm->check_swap();
ffffffffc0202b36:	0000e797          	auipc	a5,0xe
ffffffffc0202b3a:	93278793          	addi	a5,a5,-1742 # ffffffffc0210468 <sm>
ffffffffc0202b3e:	639c                	ld	a5,0(a5)
ffffffffc0202b40:	7f9c                	ld	a5,56(a5)
ffffffffc0202b42:	9782                	jalr	a5
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
     assert(ret==0);
ffffffffc0202b44:	2a051c63          	bnez	a0,ffffffffc0202dfc <swap_init+0x5e0>
     
     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         free_pages(check_rp[i],1);
ffffffffc0202b48:	000a3503          	ld	a0,0(s4)
ffffffffc0202b4c:	4585                	li	a1,1
ffffffffc0202b4e:	0a21                	addi	s4,s4,8
ffffffffc0202b50:	ba7fe0ef          	jal	ra,ffffffffc02016f6 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202b54:	ff5a1ae3          	bne	s4,s5,ffffffffc0202b48 <swap_init+0x32c>
     } 

     //free_page(pte2page(*temp_ptep));
     
     mm_destroy(mm);
ffffffffc0202b58:	855e                	mv	a0,s7
ffffffffc0202b5a:	12f000ef          	jal	ra,ffffffffc0203488 <mm_destroy>
         
     nr_free = nr_free_store;
ffffffffc0202b5e:	77a2                	ld	a5,40(sp)
ffffffffc0202b60:	0000e717          	auipc	a4,0xe
ffffffffc0202b64:	92f72823          	sw	a5,-1744(a4) # ffffffffc0210490 <free_area+0x10>
     free_list = free_list_store;
ffffffffc0202b68:	7782                	ld	a5,32(sp)
ffffffffc0202b6a:	0000e717          	auipc	a4,0xe
ffffffffc0202b6e:	90f73b23          	sd	a5,-1770(a4) # ffffffffc0210480 <free_area>
ffffffffc0202b72:	0000e797          	auipc	a5,0xe
ffffffffc0202b76:	9137bb23          	sd	s3,-1770(a5) # ffffffffc0210488 <free_area+0x8>

     
     le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202b7a:	00898a63          	beq	s3,s0,ffffffffc0202b8e <swap_init+0x372>
         struct Page *p = le2page(le, page_link);
         count --, total -= p->property;
ffffffffc0202b7e:	ff89a783          	lw	a5,-8(s3)
    return listelm->next;
ffffffffc0202b82:	0089b983          	ld	s3,8(s3)
ffffffffc0202b86:	397d                	addiw	s2,s2,-1
ffffffffc0202b88:	9c9d                	subw	s1,s1,a5
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202b8a:	fe899ae3          	bne	s3,s0,ffffffffc0202b7e <swap_init+0x362>
     }
     cprintf("count is %d, total is %d\n",count,total);
ffffffffc0202b8e:	8626                	mv	a2,s1
ffffffffc0202b90:	85ca                	mv	a1,s2
ffffffffc0202b92:	00003517          	auipc	a0,0x3
ffffffffc0202b96:	bae50513          	addi	a0,a0,-1106 # ffffffffc0205740 <default_pmm_manager+0x908>
ffffffffc0202b9a:	d24fd0ef          	jal	ra,ffffffffc02000be <cprintf>
     //assert(count == 0);
     
     cprintf("check_swap() succeeded!\n");
ffffffffc0202b9e:	00003517          	auipc	a0,0x3
ffffffffc0202ba2:	bc250513          	addi	a0,a0,-1086 # ffffffffc0205760 <default_pmm_manager+0x928>
ffffffffc0202ba6:	d18fd0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc0202baa:	b1c9                	j	ffffffffc020286c <swap_init+0x50>
     int ret, count = 0, total = 0, i;
ffffffffc0202bac:	4481                	li	s1,0
ffffffffc0202bae:	4901                	li	s2,0
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202bb0:	4981                	li	s3,0
ffffffffc0202bb2:	bb1d                	j	ffffffffc02028e8 <swap_init+0xcc>
        assert(PageProperty(p));
ffffffffc0202bb4:	00002697          	auipc	a3,0x2
ffffffffc0202bb8:	edc68693          	addi	a3,a3,-292 # ffffffffc0204a90 <commands+0x860>
ffffffffc0202bbc:	00002617          	auipc	a2,0x2
ffffffffc0202bc0:	ee460613          	addi	a2,a2,-284 # ffffffffc0204aa0 <commands+0x870>
ffffffffc0202bc4:	0ba00593          	li	a1,186
ffffffffc0202bc8:	00003517          	auipc	a0,0x3
ffffffffc0202bcc:	93050513          	addi	a0,a0,-1744 # ffffffffc02054f8 <default_pmm_manager+0x6c0>
ffffffffc0202bd0:	fa4fd0ef          	jal	ra,ffffffffc0200374 <__panic>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0202bd4:	00003697          	auipc	a3,0x3
ffffffffc0202bd8:	b1468693          	addi	a3,a3,-1260 # ffffffffc02056e8 <default_pmm_manager+0x8b0>
ffffffffc0202bdc:	00002617          	auipc	a2,0x2
ffffffffc0202be0:	ec460613          	addi	a2,a2,-316 # ffffffffc0204aa0 <commands+0x870>
ffffffffc0202be4:	0fa00593          	li	a1,250
ffffffffc0202be8:	00003517          	auipc	a0,0x3
ffffffffc0202bec:	91050513          	addi	a0,a0,-1776 # ffffffffc02054f8 <default_pmm_manager+0x6c0>
ffffffffc0202bf0:	f84fd0ef          	jal	ra,ffffffffc0200374 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc0202bf4:	00002617          	auipc	a2,0x2
ffffffffc0202bf8:	50460613          	addi	a2,a2,1284 # ffffffffc02050f8 <default_pmm_manager+0x2c0>
ffffffffc0202bfc:	07000593          	li	a1,112
ffffffffc0202c00:	00002517          	auipc	a0,0x2
ffffffffc0202c04:	32050513          	addi	a0,a0,800 # ffffffffc0204f20 <default_pmm_manager+0xe8>
ffffffffc0202c08:	f6cfd0ef          	jal	ra,ffffffffc0200374 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0202c0c:	00002617          	auipc	a2,0x2
ffffffffc0202c10:	2f460613          	addi	a2,a2,756 # ffffffffc0204f00 <default_pmm_manager+0xc8>
ffffffffc0202c14:	06500593          	li	a1,101
ffffffffc0202c18:	00002517          	auipc	a0,0x2
ffffffffc0202c1c:	30850513          	addi	a0,a0,776 # ffffffffc0204f20 <default_pmm_manager+0xe8>
ffffffffc0202c20:	f54fd0ef          	jal	ra,ffffffffc0200374 <__panic>
          assert(!PageProperty(check_rp[i]));
ffffffffc0202c24:	00003697          	auipc	a3,0x3
ffffffffc0202c28:	9fc68693          	addi	a3,a3,-1540 # ffffffffc0205620 <default_pmm_manager+0x7e8>
ffffffffc0202c2c:	00002617          	auipc	a2,0x2
ffffffffc0202c30:	e7460613          	addi	a2,a2,-396 # ffffffffc0204aa0 <commands+0x870>
ffffffffc0202c34:	0db00593          	li	a1,219
ffffffffc0202c38:	00003517          	auipc	a0,0x3
ffffffffc0202c3c:	8c050513          	addi	a0,a0,-1856 # ffffffffc02054f8 <default_pmm_manager+0x6c0>
ffffffffc0202c40:	f34fd0ef          	jal	ra,ffffffffc0200374 <__panic>
          assert(check_rp[i] != NULL );
ffffffffc0202c44:	00003697          	auipc	a3,0x3
ffffffffc0202c48:	9c468693          	addi	a3,a3,-1596 # ffffffffc0205608 <default_pmm_manager+0x7d0>
ffffffffc0202c4c:	00002617          	auipc	a2,0x2
ffffffffc0202c50:	e5460613          	addi	a2,a2,-428 # ffffffffc0204aa0 <commands+0x870>
ffffffffc0202c54:	0da00593          	li	a1,218
ffffffffc0202c58:	00003517          	auipc	a0,0x3
ffffffffc0202c5c:	8a050513          	addi	a0,a0,-1888 # ffffffffc02054f8 <default_pmm_manager+0x6c0>
ffffffffc0202c60:	f14fd0ef          	jal	ra,ffffffffc0200374 <__panic>
         assert(check_ptep[i] != NULL);
ffffffffc0202c64:	00003697          	auipc	a3,0x3
ffffffffc0202c68:	a6c68693          	addi	a3,a3,-1428 # ffffffffc02056d0 <default_pmm_manager+0x898>
ffffffffc0202c6c:	00002617          	auipc	a2,0x2
ffffffffc0202c70:	e3460613          	addi	a2,a2,-460 # ffffffffc0204aa0 <commands+0x870>
ffffffffc0202c74:	0f900593          	li	a1,249
ffffffffc0202c78:	00003517          	auipc	a0,0x3
ffffffffc0202c7c:	88050513          	addi	a0,a0,-1920 # ffffffffc02054f8 <default_pmm_manager+0x6c0>
ffffffffc0202c80:	ef4fd0ef          	jal	ra,ffffffffc0200374 <__panic>
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
ffffffffc0202c84:	00003617          	auipc	a2,0x3
ffffffffc0202c88:	85460613          	addi	a2,a2,-1964 # ffffffffc02054d8 <default_pmm_manager+0x6a0>
ffffffffc0202c8c:	02700593          	li	a1,39
ffffffffc0202c90:	00003517          	auipc	a0,0x3
ffffffffc0202c94:	86850513          	addi	a0,a0,-1944 # ffffffffc02054f8 <default_pmm_manager+0x6c0>
ffffffffc0202c98:	edcfd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(pgfault_num==2);
ffffffffc0202c9c:	00003697          	auipc	a3,0x3
ffffffffc0202ca0:	a0468693          	addi	a3,a3,-1532 # ffffffffc02056a0 <default_pmm_manager+0x868>
ffffffffc0202ca4:	00002617          	auipc	a2,0x2
ffffffffc0202ca8:	dfc60613          	addi	a2,a2,-516 # ffffffffc0204aa0 <commands+0x870>
ffffffffc0202cac:	09500593          	li	a1,149
ffffffffc0202cb0:	00003517          	auipc	a0,0x3
ffffffffc0202cb4:	84850513          	addi	a0,a0,-1976 # ffffffffc02054f8 <default_pmm_manager+0x6c0>
ffffffffc0202cb8:	ebcfd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(pgfault_num==2);
ffffffffc0202cbc:	00003697          	auipc	a3,0x3
ffffffffc0202cc0:	9e468693          	addi	a3,a3,-1564 # ffffffffc02056a0 <default_pmm_manager+0x868>
ffffffffc0202cc4:	00002617          	auipc	a2,0x2
ffffffffc0202cc8:	ddc60613          	addi	a2,a2,-548 # ffffffffc0204aa0 <commands+0x870>
ffffffffc0202ccc:	09700593          	li	a1,151
ffffffffc0202cd0:	00003517          	auipc	a0,0x3
ffffffffc0202cd4:	82850513          	addi	a0,a0,-2008 # ffffffffc02054f8 <default_pmm_manager+0x6c0>
ffffffffc0202cd8:	e9cfd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(pgfault_num==3);
ffffffffc0202cdc:	00003697          	auipc	a3,0x3
ffffffffc0202ce0:	9d468693          	addi	a3,a3,-1580 # ffffffffc02056b0 <default_pmm_manager+0x878>
ffffffffc0202ce4:	00002617          	auipc	a2,0x2
ffffffffc0202ce8:	dbc60613          	addi	a2,a2,-580 # ffffffffc0204aa0 <commands+0x870>
ffffffffc0202cec:	09900593          	li	a1,153
ffffffffc0202cf0:	00003517          	auipc	a0,0x3
ffffffffc0202cf4:	80850513          	addi	a0,a0,-2040 # ffffffffc02054f8 <default_pmm_manager+0x6c0>
ffffffffc0202cf8:	e7cfd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(pgfault_num==3);
ffffffffc0202cfc:	00003697          	auipc	a3,0x3
ffffffffc0202d00:	9b468693          	addi	a3,a3,-1612 # ffffffffc02056b0 <default_pmm_manager+0x878>
ffffffffc0202d04:	00002617          	auipc	a2,0x2
ffffffffc0202d08:	d9c60613          	addi	a2,a2,-612 # ffffffffc0204aa0 <commands+0x870>
ffffffffc0202d0c:	09b00593          	li	a1,155
ffffffffc0202d10:	00002517          	auipc	a0,0x2
ffffffffc0202d14:	7e850513          	addi	a0,a0,2024 # ffffffffc02054f8 <default_pmm_manager+0x6c0>
ffffffffc0202d18:	e5cfd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(pgfault_num==1);
ffffffffc0202d1c:	00003697          	auipc	a3,0x3
ffffffffc0202d20:	97468693          	addi	a3,a3,-1676 # ffffffffc0205690 <default_pmm_manager+0x858>
ffffffffc0202d24:	00002617          	auipc	a2,0x2
ffffffffc0202d28:	d7c60613          	addi	a2,a2,-644 # ffffffffc0204aa0 <commands+0x870>
ffffffffc0202d2c:	09100593          	li	a1,145
ffffffffc0202d30:	00002517          	auipc	a0,0x2
ffffffffc0202d34:	7c850513          	addi	a0,a0,1992 # ffffffffc02054f8 <default_pmm_manager+0x6c0>
ffffffffc0202d38:	e3cfd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(pgfault_num==1);
ffffffffc0202d3c:	00003697          	auipc	a3,0x3
ffffffffc0202d40:	95468693          	addi	a3,a3,-1708 # ffffffffc0205690 <default_pmm_manager+0x858>
ffffffffc0202d44:	00002617          	auipc	a2,0x2
ffffffffc0202d48:	d5c60613          	addi	a2,a2,-676 # ffffffffc0204aa0 <commands+0x870>
ffffffffc0202d4c:	09300593          	li	a1,147
ffffffffc0202d50:	00002517          	auipc	a0,0x2
ffffffffc0202d54:	7a850513          	addi	a0,a0,1960 # ffffffffc02054f8 <default_pmm_manager+0x6c0>
ffffffffc0202d58:	e1cfd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0202d5c:	00003697          	auipc	a3,0x3
ffffffffc0202d60:	8e468693          	addi	a3,a3,-1820 # ffffffffc0205640 <default_pmm_manager+0x808>
ffffffffc0202d64:	00002617          	auipc	a2,0x2
ffffffffc0202d68:	d3c60613          	addi	a2,a2,-708 # ffffffffc0204aa0 <commands+0x870>
ffffffffc0202d6c:	0e800593          	li	a1,232
ffffffffc0202d70:	00002517          	auipc	a0,0x2
ffffffffc0202d74:	78850513          	addi	a0,a0,1928 # ffffffffc02054f8 <default_pmm_manager+0x6c0>
ffffffffc0202d78:	dfcfd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(temp_ptep!= NULL);
ffffffffc0202d7c:	00003697          	auipc	a3,0x3
ffffffffc0202d80:	84c68693          	addi	a3,a3,-1972 # ffffffffc02055c8 <default_pmm_manager+0x790>
ffffffffc0202d84:	00002617          	auipc	a2,0x2
ffffffffc0202d88:	d1c60613          	addi	a2,a2,-740 # ffffffffc0204aa0 <commands+0x870>
ffffffffc0202d8c:	0d500593          	li	a1,213
ffffffffc0202d90:	00002517          	auipc	a0,0x2
ffffffffc0202d94:	76850513          	addi	a0,a0,1896 # ffffffffc02054f8 <default_pmm_manager+0x6c0>
ffffffffc0202d98:	ddcfd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(pgfault_num==4);
ffffffffc0202d9c:	00003697          	auipc	a3,0x3
ffffffffc0202da0:	92468693          	addi	a3,a3,-1756 # ffffffffc02056c0 <default_pmm_manager+0x888>
ffffffffc0202da4:	00002617          	auipc	a2,0x2
ffffffffc0202da8:	cfc60613          	addi	a2,a2,-772 # ffffffffc0204aa0 <commands+0x870>
ffffffffc0202dac:	09d00593          	li	a1,157
ffffffffc0202db0:	00002517          	auipc	a0,0x2
ffffffffc0202db4:	74850513          	addi	a0,a0,1864 # ffffffffc02054f8 <default_pmm_manager+0x6c0>
ffffffffc0202db8:	dbcfd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(pgfault_num==4);
ffffffffc0202dbc:	00003697          	auipc	a3,0x3
ffffffffc0202dc0:	90468693          	addi	a3,a3,-1788 # ffffffffc02056c0 <default_pmm_manager+0x888>
ffffffffc0202dc4:	00002617          	auipc	a2,0x2
ffffffffc0202dc8:	cdc60613          	addi	a2,a2,-804 # ffffffffc0204aa0 <commands+0x870>
ffffffffc0202dcc:	09f00593          	li	a1,159
ffffffffc0202dd0:	00002517          	auipc	a0,0x2
ffffffffc0202dd4:	72850513          	addi	a0,a0,1832 # ffffffffc02054f8 <default_pmm_manager+0x6c0>
ffffffffc0202dd8:	d9cfd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert( nr_free == 0);         
ffffffffc0202ddc:	00002697          	auipc	a3,0x2
ffffffffc0202de0:	e9c68693          	addi	a3,a3,-356 # ffffffffc0204c78 <commands+0xa48>
ffffffffc0202de4:	00002617          	auipc	a2,0x2
ffffffffc0202de8:	cbc60613          	addi	a2,a2,-836 # ffffffffc0204aa0 <commands+0x870>
ffffffffc0202dec:	0f100593          	li	a1,241
ffffffffc0202df0:	00002517          	auipc	a0,0x2
ffffffffc0202df4:	70850513          	addi	a0,a0,1800 # ffffffffc02054f8 <default_pmm_manager+0x6c0>
ffffffffc0202df8:	d7cfd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(ret==0);
ffffffffc0202dfc:	00003697          	auipc	a3,0x3
ffffffffc0202e00:	93c68693          	addi	a3,a3,-1732 # ffffffffc0205738 <default_pmm_manager+0x900>
ffffffffc0202e04:	00002617          	auipc	a2,0x2
ffffffffc0202e08:	c9c60613          	addi	a2,a2,-868 # ffffffffc0204aa0 <commands+0x870>
ffffffffc0202e0c:	10000593          	li	a1,256
ffffffffc0202e10:	00002517          	auipc	a0,0x2
ffffffffc0202e14:	6e850513          	addi	a0,a0,1768 # ffffffffc02054f8 <default_pmm_manager+0x6c0>
ffffffffc0202e18:	d5cfd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(mm != NULL);
ffffffffc0202e1c:	00002697          	auipc	a3,0x2
ffffffffc0202e20:	72c68693          	addi	a3,a3,1836 # ffffffffc0205548 <default_pmm_manager+0x710>
ffffffffc0202e24:	00002617          	auipc	a2,0x2
ffffffffc0202e28:	c7c60613          	addi	a2,a2,-900 # ffffffffc0204aa0 <commands+0x870>
ffffffffc0202e2c:	0c200593          	li	a1,194
ffffffffc0202e30:	00002517          	auipc	a0,0x2
ffffffffc0202e34:	6c850513          	addi	a0,a0,1736 # ffffffffc02054f8 <default_pmm_manager+0x6c0>
ffffffffc0202e38:	d3cfd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(check_mm_struct == NULL);
ffffffffc0202e3c:	00002697          	auipc	a3,0x2
ffffffffc0202e40:	71c68693          	addi	a3,a3,1820 # ffffffffc0205558 <default_pmm_manager+0x720>
ffffffffc0202e44:	00002617          	auipc	a2,0x2
ffffffffc0202e48:	c5c60613          	addi	a2,a2,-932 # ffffffffc0204aa0 <commands+0x870>
ffffffffc0202e4c:	0c500593          	li	a1,197
ffffffffc0202e50:	00002517          	auipc	a0,0x2
ffffffffc0202e54:	6a850513          	addi	a0,a0,1704 # ffffffffc02054f8 <default_pmm_manager+0x6c0>
ffffffffc0202e58:	d1cfd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(pgdir[0] == 0);
ffffffffc0202e5c:	00002697          	auipc	a3,0x2
ffffffffc0202e60:	71468693          	addi	a3,a3,1812 # ffffffffc0205570 <default_pmm_manager+0x738>
ffffffffc0202e64:	00002617          	auipc	a2,0x2
ffffffffc0202e68:	c3c60613          	addi	a2,a2,-964 # ffffffffc0204aa0 <commands+0x870>
ffffffffc0202e6c:	0ca00593          	li	a1,202
ffffffffc0202e70:	00002517          	auipc	a0,0x2
ffffffffc0202e74:	68850513          	addi	a0,a0,1672 # ffffffffc02054f8 <default_pmm_manager+0x6c0>
ffffffffc0202e78:	cfcfd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(vma != NULL);
ffffffffc0202e7c:	00002697          	auipc	a3,0x2
ffffffffc0202e80:	70468693          	addi	a3,a3,1796 # ffffffffc0205580 <default_pmm_manager+0x748>
ffffffffc0202e84:	00002617          	auipc	a2,0x2
ffffffffc0202e88:	c1c60613          	addi	a2,a2,-996 # ffffffffc0204aa0 <commands+0x870>
ffffffffc0202e8c:	0cd00593          	li	a1,205
ffffffffc0202e90:	00002517          	auipc	a0,0x2
ffffffffc0202e94:	66850513          	addi	a0,a0,1640 # ffffffffc02054f8 <default_pmm_manager+0x6c0>
ffffffffc0202e98:	cdcfd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(total == nr_free_pages());
ffffffffc0202e9c:	00002697          	auipc	a3,0x2
ffffffffc0202ea0:	c3468693          	addi	a3,a3,-972 # ffffffffc0204ad0 <commands+0x8a0>
ffffffffc0202ea4:	00002617          	auipc	a2,0x2
ffffffffc0202ea8:	bfc60613          	addi	a2,a2,-1028 # ffffffffc0204aa0 <commands+0x870>
ffffffffc0202eac:	0bd00593          	li	a1,189
ffffffffc0202eb0:	00002517          	auipc	a0,0x2
ffffffffc0202eb4:	64850513          	addi	a0,a0,1608 # ffffffffc02054f8 <default_pmm_manager+0x6c0>
ffffffffc0202eb8:	cbcfd0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0202ebc <swap_init_mm>:
     return sm->init_mm(mm);
ffffffffc0202ebc:	0000d797          	auipc	a5,0xd
ffffffffc0202ec0:	5ac78793          	addi	a5,a5,1452 # ffffffffc0210468 <sm>
ffffffffc0202ec4:	639c                	ld	a5,0(a5)
ffffffffc0202ec6:	0107b303          	ld	t1,16(a5)
ffffffffc0202eca:	8302                	jr	t1

ffffffffc0202ecc <swap_map_swappable>:
     return sm->map_swappable(mm, addr, page, swap_in);
ffffffffc0202ecc:	0000d797          	auipc	a5,0xd
ffffffffc0202ed0:	59c78793          	addi	a5,a5,1436 # ffffffffc0210468 <sm>
ffffffffc0202ed4:	639c                	ld	a5,0(a5)
ffffffffc0202ed6:	0207b303          	ld	t1,32(a5)
ffffffffc0202eda:	8302                	jr	t1

ffffffffc0202edc <swap_out>:
{
ffffffffc0202edc:	711d                	addi	sp,sp,-96
ffffffffc0202ede:	ec86                	sd	ra,88(sp)
ffffffffc0202ee0:	e8a2                	sd	s0,80(sp)
ffffffffc0202ee2:	e4a6                	sd	s1,72(sp)
ffffffffc0202ee4:	e0ca                	sd	s2,64(sp)
ffffffffc0202ee6:	fc4e                	sd	s3,56(sp)
ffffffffc0202ee8:	f852                	sd	s4,48(sp)
ffffffffc0202eea:	f456                	sd	s5,40(sp)
ffffffffc0202eec:	f05a                	sd	s6,32(sp)
ffffffffc0202eee:	ec5e                	sd	s7,24(sp)
ffffffffc0202ef0:	e862                	sd	s8,16(sp)
     for (i = 0; i != n; ++ i)
ffffffffc0202ef2:	cde9                	beqz	a1,ffffffffc0202fcc <swap_out+0xf0>
ffffffffc0202ef4:	8ab2                	mv	s5,a2
ffffffffc0202ef6:	892a                	mv	s2,a0
ffffffffc0202ef8:	8a2e                	mv	s4,a1
ffffffffc0202efa:	4401                	li	s0,0
ffffffffc0202efc:	0000d997          	auipc	s3,0xd
ffffffffc0202f00:	56c98993          	addi	s3,s3,1388 # ffffffffc0210468 <sm>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0202f04:	00003b17          	auipc	s6,0x3
ffffffffc0202f08:	8dcb0b13          	addi	s6,s6,-1828 # ffffffffc02057e0 <default_pmm_manager+0x9a8>
                    cprintf("SWAP: failed to save\n");
ffffffffc0202f0c:	00003b97          	auipc	s7,0x3
ffffffffc0202f10:	8bcb8b93          	addi	s7,s7,-1860 # ffffffffc02057c8 <default_pmm_manager+0x990>
ffffffffc0202f14:	a825                	j	ffffffffc0202f4c <swap_out+0x70>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0202f16:	67a2                	ld	a5,8(sp)
ffffffffc0202f18:	8626                	mv	a2,s1
ffffffffc0202f1a:	85a2                	mv	a1,s0
ffffffffc0202f1c:	63b4                	ld	a3,64(a5)
ffffffffc0202f1e:	855a                	mv	a0,s6
     for (i = 0; i != n; ++ i)
ffffffffc0202f20:	2405                	addiw	s0,s0,1
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0202f22:	82b1                	srli	a3,a3,0xc
ffffffffc0202f24:	0685                	addi	a3,a3,1
ffffffffc0202f26:	998fd0ef          	jal	ra,ffffffffc02000be <cprintf>
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0202f2a:	6522                	ld	a0,8(sp)
                    free_page(page);
ffffffffc0202f2c:	4585                	li	a1,1
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0202f2e:	613c                	ld	a5,64(a0)
ffffffffc0202f30:	83b1                	srli	a5,a5,0xc
ffffffffc0202f32:	0785                	addi	a5,a5,1
ffffffffc0202f34:	07a2                	slli	a5,a5,0x8
ffffffffc0202f36:	00fc3023          	sd	a5,0(s8) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
                    free_page(page);
ffffffffc0202f3a:	fbcfe0ef          	jal	ra,ffffffffc02016f6 <free_pages>
          tlb_invalidate(mm->pgdir, v);
ffffffffc0202f3e:	01893503          	ld	a0,24(s2)
ffffffffc0202f42:	85a6                	mv	a1,s1
ffffffffc0202f44:	ebeff0ef          	jal	ra,ffffffffc0202602 <tlb_invalidate>
     for (i = 0; i != n; ++ i)
ffffffffc0202f48:	048a0d63          	beq	s4,s0,ffffffffc0202fa2 <swap_out+0xc6>
          int r = sm->swap_out_victim(mm, &page, in_tick);
ffffffffc0202f4c:	0009b783          	ld	a5,0(s3)
ffffffffc0202f50:	8656                	mv	a2,s5
ffffffffc0202f52:	002c                	addi	a1,sp,8
ffffffffc0202f54:	7b9c                	ld	a5,48(a5)
ffffffffc0202f56:	854a                	mv	a0,s2
ffffffffc0202f58:	9782                	jalr	a5
          if (r != 0) {
ffffffffc0202f5a:	e12d                	bnez	a0,ffffffffc0202fbc <swap_out+0xe0>
          v=page->pra_vaddr; 
ffffffffc0202f5c:	67a2                	ld	a5,8(sp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0202f5e:	01893503          	ld	a0,24(s2)
ffffffffc0202f62:	4601                	li	a2,0
          v=page->pra_vaddr; 
ffffffffc0202f64:	63a4                	ld	s1,64(a5)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0202f66:	85a6                	mv	a1,s1
ffffffffc0202f68:	815fe0ef          	jal	ra,ffffffffc020177c <get_pte>
          assert((*ptep & PTE_V) != 0);
ffffffffc0202f6c:	611c                	ld	a5,0(a0)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0202f6e:	8c2a                	mv	s8,a0
          assert((*ptep & PTE_V) != 0);
ffffffffc0202f70:	8b85                	andi	a5,a5,1
ffffffffc0202f72:	cfb9                	beqz	a5,ffffffffc0202fd0 <swap_out+0xf4>
          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
ffffffffc0202f74:	65a2                	ld	a1,8(sp)
ffffffffc0202f76:	61bc                	ld	a5,64(a1)
ffffffffc0202f78:	83b1                	srli	a5,a5,0xc
ffffffffc0202f7a:	00178513          	addi	a0,a5,1
ffffffffc0202f7e:	0522                	slli	a0,a0,0x8
ffffffffc0202f80:	365000ef          	jal	ra,ffffffffc0203ae4 <swapfs_write>
ffffffffc0202f84:	d949                	beqz	a0,ffffffffc0202f16 <swap_out+0x3a>
                    cprintf("SWAP: failed to save\n");
ffffffffc0202f86:	855e                	mv	a0,s7
ffffffffc0202f88:	936fd0ef          	jal	ra,ffffffffc02000be <cprintf>
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0202f8c:	0009b783          	ld	a5,0(s3)
ffffffffc0202f90:	6622                	ld	a2,8(sp)
ffffffffc0202f92:	4681                	li	a3,0
ffffffffc0202f94:	739c                	ld	a5,32(a5)
ffffffffc0202f96:	85a6                	mv	a1,s1
ffffffffc0202f98:	854a                	mv	a0,s2
     for (i = 0; i != n; ++ i)
ffffffffc0202f9a:	2405                	addiw	s0,s0,1
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0202f9c:	9782                	jalr	a5
     for (i = 0; i != n; ++ i)
ffffffffc0202f9e:	fa8a17e3          	bne	s4,s0,ffffffffc0202f4c <swap_out+0x70>
}
ffffffffc0202fa2:	8522                	mv	a0,s0
ffffffffc0202fa4:	60e6                	ld	ra,88(sp)
ffffffffc0202fa6:	6446                	ld	s0,80(sp)
ffffffffc0202fa8:	64a6                	ld	s1,72(sp)
ffffffffc0202faa:	6906                	ld	s2,64(sp)
ffffffffc0202fac:	79e2                	ld	s3,56(sp)
ffffffffc0202fae:	7a42                	ld	s4,48(sp)
ffffffffc0202fb0:	7aa2                	ld	s5,40(sp)
ffffffffc0202fb2:	7b02                	ld	s6,32(sp)
ffffffffc0202fb4:	6be2                	ld	s7,24(sp)
ffffffffc0202fb6:	6c42                	ld	s8,16(sp)
ffffffffc0202fb8:	6125                	addi	sp,sp,96
ffffffffc0202fba:	8082                	ret
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
ffffffffc0202fbc:	85a2                	mv	a1,s0
ffffffffc0202fbe:	00002517          	auipc	a0,0x2
ffffffffc0202fc2:	7c250513          	addi	a0,a0,1986 # ffffffffc0205780 <default_pmm_manager+0x948>
ffffffffc0202fc6:	8f8fd0ef          	jal	ra,ffffffffc02000be <cprintf>
                  break;
ffffffffc0202fca:	bfe1                	j	ffffffffc0202fa2 <swap_out+0xc6>
     for (i = 0; i != n; ++ i)
ffffffffc0202fcc:	4401                	li	s0,0
ffffffffc0202fce:	bfd1                	j	ffffffffc0202fa2 <swap_out+0xc6>
          assert((*ptep & PTE_V) != 0);
ffffffffc0202fd0:	00002697          	auipc	a3,0x2
ffffffffc0202fd4:	7e068693          	addi	a3,a3,2016 # ffffffffc02057b0 <default_pmm_manager+0x978>
ffffffffc0202fd8:	00002617          	auipc	a2,0x2
ffffffffc0202fdc:	ac860613          	addi	a2,a2,-1336 # ffffffffc0204aa0 <commands+0x870>
ffffffffc0202fe0:	06600593          	li	a1,102
ffffffffc0202fe4:	00002517          	auipc	a0,0x2
ffffffffc0202fe8:	51450513          	addi	a0,a0,1300 # ffffffffc02054f8 <default_pmm_manager+0x6c0>
ffffffffc0202fec:	b88fd0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0202ff0 <_clock_init_mm>:
     // 初始化pra_list_head为空链表
     // 初始化当前指针curr_ptr指向pra_list_head，表示当前页面替换位置为链表头
     // 将mm的私有成员指针指向pra_list_head，用于后续的页面替换算法操作
     //cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
     return 0;
}
ffffffffc0202ff0:	4501                	li	a0,0
ffffffffc0202ff2:	8082                	ret

ffffffffc0202ff4 <_clock_init>:

static int
_clock_init(void)
{
    return 0;
}
ffffffffc0202ff4:	4501                	li	a0,0
ffffffffc0202ff6:	8082                	ret

ffffffffc0202ff8 <_clock_set_unswappable>:

static int
_clock_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
    return 0;
}
ffffffffc0202ff8:	4501                	li	a0,0
ffffffffc0202ffa:	8082                	ret

ffffffffc0202ffc <_clock_check_swap>:
_clock_check_swap(void) {
ffffffffc0202ffc:	1141                	addi	sp,sp,-16
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0202ffe:	678d                	lui	a5,0x3
ffffffffc0203000:	4731                	li	a4,12
_clock_check_swap(void) {
ffffffffc0203002:	e406                	sd	ra,8(sp)
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0203004:	00e78023          	sb	a4,0(a5) # 3000 <BASE_ADDRESS-0xffffffffc01fd000>
    assert(pgfault_num==4);
ffffffffc0203008:	0000d797          	auipc	a5,0xd
ffffffffc020300c:	46c78793          	addi	a5,a5,1132 # ffffffffc0210474 <pgfault_num>
ffffffffc0203010:	4398                	lw	a4,0(a5)
ffffffffc0203012:	4691                	li	a3,4
ffffffffc0203014:	2701                	sext.w	a4,a4
ffffffffc0203016:	08d71f63          	bne	a4,a3,ffffffffc02030b4 <_clock_check_swap+0xb8>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc020301a:	6685                	lui	a3,0x1
ffffffffc020301c:	4629                	li	a2,10
ffffffffc020301e:	00c68023          	sb	a2,0(a3) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
    assert(pgfault_num==4);
ffffffffc0203022:	4394                	lw	a3,0(a5)
ffffffffc0203024:	2681                	sext.w	a3,a3
ffffffffc0203026:	20e69763          	bne	a3,a4,ffffffffc0203234 <_clock_check_swap+0x238>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc020302a:	6711                	lui	a4,0x4
ffffffffc020302c:	4635                	li	a2,13
ffffffffc020302e:	00c70023          	sb	a2,0(a4) # 4000 <BASE_ADDRESS-0xffffffffc01fc000>
    assert(pgfault_num==4);
ffffffffc0203032:	4398                	lw	a4,0(a5)
ffffffffc0203034:	2701                	sext.w	a4,a4
ffffffffc0203036:	1cd71f63          	bne	a4,a3,ffffffffc0203214 <_clock_check_swap+0x218>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc020303a:	6689                	lui	a3,0x2
ffffffffc020303c:	462d                	li	a2,11
ffffffffc020303e:	00c68023          	sb	a2,0(a3) # 2000 <BASE_ADDRESS-0xffffffffc01fe000>
    assert(pgfault_num==4);
ffffffffc0203042:	4394                	lw	a3,0(a5)
ffffffffc0203044:	2681                	sext.w	a3,a3
ffffffffc0203046:	1ae69763          	bne	a3,a4,ffffffffc02031f4 <_clock_check_swap+0x1f8>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc020304a:	6715                	lui	a4,0x5
ffffffffc020304c:	46b9                	li	a3,14
ffffffffc020304e:	00d70023          	sb	a3,0(a4) # 5000 <BASE_ADDRESS-0xffffffffc01fb000>
    assert(pgfault_num==5);
ffffffffc0203052:	4398                	lw	a4,0(a5)
ffffffffc0203054:	4695                	li	a3,5
ffffffffc0203056:	2701                	sext.w	a4,a4
ffffffffc0203058:	16d71e63          	bne	a4,a3,ffffffffc02031d4 <_clock_check_swap+0x1d8>
    assert(pgfault_num==5);
ffffffffc020305c:	4394                	lw	a3,0(a5)
ffffffffc020305e:	2681                	sext.w	a3,a3
ffffffffc0203060:	14e69a63          	bne	a3,a4,ffffffffc02031b4 <_clock_check_swap+0x1b8>
    assert(pgfault_num==5);
ffffffffc0203064:	4398                	lw	a4,0(a5)
ffffffffc0203066:	2701                	sext.w	a4,a4
ffffffffc0203068:	12d71663          	bne	a4,a3,ffffffffc0203194 <_clock_check_swap+0x198>
    assert(pgfault_num==5);
ffffffffc020306c:	4394                	lw	a3,0(a5)
ffffffffc020306e:	2681                	sext.w	a3,a3
ffffffffc0203070:	10e69263          	bne	a3,a4,ffffffffc0203174 <_clock_check_swap+0x178>
    assert(pgfault_num==5);
ffffffffc0203074:	4398                	lw	a4,0(a5)
ffffffffc0203076:	2701                	sext.w	a4,a4
ffffffffc0203078:	0cd71e63          	bne	a4,a3,ffffffffc0203154 <_clock_check_swap+0x158>
    assert(pgfault_num==5);
ffffffffc020307c:	4394                	lw	a3,0(a5)
ffffffffc020307e:	2681                	sext.w	a3,a3
ffffffffc0203080:	0ae69a63          	bne	a3,a4,ffffffffc0203134 <_clock_check_swap+0x138>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc0203084:	6715                	lui	a4,0x5
ffffffffc0203086:	46b9                	li	a3,14
ffffffffc0203088:	00d70023          	sb	a3,0(a4) # 5000 <BASE_ADDRESS-0xffffffffc01fb000>
    assert(pgfault_num==5);
ffffffffc020308c:	4398                	lw	a4,0(a5)
ffffffffc020308e:	4695                	li	a3,5
ffffffffc0203090:	2701                	sext.w	a4,a4
ffffffffc0203092:	08d71163          	bne	a4,a3,ffffffffc0203114 <_clock_check_swap+0x118>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc0203096:	6705                	lui	a4,0x1
ffffffffc0203098:	00074683          	lbu	a3,0(a4) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
ffffffffc020309c:	4729                	li	a4,10
ffffffffc020309e:	04e69b63          	bne	a3,a4,ffffffffc02030f4 <_clock_check_swap+0xf8>
    assert(pgfault_num==6);
ffffffffc02030a2:	439c                	lw	a5,0(a5)
ffffffffc02030a4:	4719                	li	a4,6
ffffffffc02030a6:	2781                	sext.w	a5,a5
ffffffffc02030a8:	02e79663          	bne	a5,a4,ffffffffc02030d4 <_clock_check_swap+0xd8>
}
ffffffffc02030ac:	60a2                	ld	ra,8(sp)
ffffffffc02030ae:	4501                	li	a0,0
ffffffffc02030b0:	0141                	addi	sp,sp,16
ffffffffc02030b2:	8082                	ret
    assert(pgfault_num==4);
ffffffffc02030b4:	00002697          	auipc	a3,0x2
ffffffffc02030b8:	60c68693          	addi	a3,a3,1548 # ffffffffc02056c0 <default_pmm_manager+0x888>
ffffffffc02030bc:	00002617          	auipc	a2,0x2
ffffffffc02030c0:	9e460613          	addi	a2,a2,-1564 # ffffffffc0204aa0 <commands+0x870>
ffffffffc02030c4:	07700593          	li	a1,119
ffffffffc02030c8:	00002517          	auipc	a0,0x2
ffffffffc02030cc:	75850513          	addi	a0,a0,1880 # ffffffffc0205820 <default_pmm_manager+0x9e8>
ffffffffc02030d0:	aa4fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgfault_num==6);
ffffffffc02030d4:	00002697          	auipc	a3,0x2
ffffffffc02030d8:	79c68693          	addi	a3,a3,1948 # ffffffffc0205870 <default_pmm_manager+0xa38>
ffffffffc02030dc:	00002617          	auipc	a2,0x2
ffffffffc02030e0:	9c460613          	addi	a2,a2,-1596 # ffffffffc0204aa0 <commands+0x870>
ffffffffc02030e4:	08e00593          	li	a1,142
ffffffffc02030e8:	00002517          	auipc	a0,0x2
ffffffffc02030ec:	73850513          	addi	a0,a0,1848 # ffffffffc0205820 <default_pmm_manager+0x9e8>
ffffffffc02030f0:	a84fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc02030f4:	00002697          	auipc	a3,0x2
ffffffffc02030f8:	75468693          	addi	a3,a3,1876 # ffffffffc0205848 <default_pmm_manager+0xa10>
ffffffffc02030fc:	00002617          	auipc	a2,0x2
ffffffffc0203100:	9a460613          	addi	a2,a2,-1628 # ffffffffc0204aa0 <commands+0x870>
ffffffffc0203104:	08c00593          	li	a1,140
ffffffffc0203108:	00002517          	auipc	a0,0x2
ffffffffc020310c:	71850513          	addi	a0,a0,1816 # ffffffffc0205820 <default_pmm_manager+0x9e8>
ffffffffc0203110:	a64fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgfault_num==5);
ffffffffc0203114:	00002697          	auipc	a3,0x2
ffffffffc0203118:	72468693          	addi	a3,a3,1828 # ffffffffc0205838 <default_pmm_manager+0xa00>
ffffffffc020311c:	00002617          	auipc	a2,0x2
ffffffffc0203120:	98460613          	addi	a2,a2,-1660 # ffffffffc0204aa0 <commands+0x870>
ffffffffc0203124:	08b00593          	li	a1,139
ffffffffc0203128:	00002517          	auipc	a0,0x2
ffffffffc020312c:	6f850513          	addi	a0,a0,1784 # ffffffffc0205820 <default_pmm_manager+0x9e8>
ffffffffc0203130:	a44fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgfault_num==5);
ffffffffc0203134:	00002697          	auipc	a3,0x2
ffffffffc0203138:	70468693          	addi	a3,a3,1796 # ffffffffc0205838 <default_pmm_manager+0xa00>
ffffffffc020313c:	00002617          	auipc	a2,0x2
ffffffffc0203140:	96460613          	addi	a2,a2,-1692 # ffffffffc0204aa0 <commands+0x870>
ffffffffc0203144:	08900593          	li	a1,137
ffffffffc0203148:	00002517          	auipc	a0,0x2
ffffffffc020314c:	6d850513          	addi	a0,a0,1752 # ffffffffc0205820 <default_pmm_manager+0x9e8>
ffffffffc0203150:	a24fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgfault_num==5);
ffffffffc0203154:	00002697          	auipc	a3,0x2
ffffffffc0203158:	6e468693          	addi	a3,a3,1764 # ffffffffc0205838 <default_pmm_manager+0xa00>
ffffffffc020315c:	00002617          	auipc	a2,0x2
ffffffffc0203160:	94460613          	addi	a2,a2,-1724 # ffffffffc0204aa0 <commands+0x870>
ffffffffc0203164:	08700593          	li	a1,135
ffffffffc0203168:	00002517          	auipc	a0,0x2
ffffffffc020316c:	6b850513          	addi	a0,a0,1720 # ffffffffc0205820 <default_pmm_manager+0x9e8>
ffffffffc0203170:	a04fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgfault_num==5);
ffffffffc0203174:	00002697          	auipc	a3,0x2
ffffffffc0203178:	6c468693          	addi	a3,a3,1732 # ffffffffc0205838 <default_pmm_manager+0xa00>
ffffffffc020317c:	00002617          	auipc	a2,0x2
ffffffffc0203180:	92460613          	addi	a2,a2,-1756 # ffffffffc0204aa0 <commands+0x870>
ffffffffc0203184:	08500593          	li	a1,133
ffffffffc0203188:	00002517          	auipc	a0,0x2
ffffffffc020318c:	69850513          	addi	a0,a0,1688 # ffffffffc0205820 <default_pmm_manager+0x9e8>
ffffffffc0203190:	9e4fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgfault_num==5);
ffffffffc0203194:	00002697          	auipc	a3,0x2
ffffffffc0203198:	6a468693          	addi	a3,a3,1700 # ffffffffc0205838 <default_pmm_manager+0xa00>
ffffffffc020319c:	00002617          	auipc	a2,0x2
ffffffffc02031a0:	90460613          	addi	a2,a2,-1788 # ffffffffc0204aa0 <commands+0x870>
ffffffffc02031a4:	08300593          	li	a1,131
ffffffffc02031a8:	00002517          	auipc	a0,0x2
ffffffffc02031ac:	67850513          	addi	a0,a0,1656 # ffffffffc0205820 <default_pmm_manager+0x9e8>
ffffffffc02031b0:	9c4fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgfault_num==5);
ffffffffc02031b4:	00002697          	auipc	a3,0x2
ffffffffc02031b8:	68468693          	addi	a3,a3,1668 # ffffffffc0205838 <default_pmm_manager+0xa00>
ffffffffc02031bc:	00002617          	auipc	a2,0x2
ffffffffc02031c0:	8e460613          	addi	a2,a2,-1820 # ffffffffc0204aa0 <commands+0x870>
ffffffffc02031c4:	08100593          	li	a1,129
ffffffffc02031c8:	00002517          	auipc	a0,0x2
ffffffffc02031cc:	65850513          	addi	a0,a0,1624 # ffffffffc0205820 <default_pmm_manager+0x9e8>
ffffffffc02031d0:	9a4fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgfault_num==5);
ffffffffc02031d4:	00002697          	auipc	a3,0x2
ffffffffc02031d8:	66468693          	addi	a3,a3,1636 # ffffffffc0205838 <default_pmm_manager+0xa00>
ffffffffc02031dc:	00002617          	auipc	a2,0x2
ffffffffc02031e0:	8c460613          	addi	a2,a2,-1852 # ffffffffc0204aa0 <commands+0x870>
ffffffffc02031e4:	07f00593          	li	a1,127
ffffffffc02031e8:	00002517          	auipc	a0,0x2
ffffffffc02031ec:	63850513          	addi	a0,a0,1592 # ffffffffc0205820 <default_pmm_manager+0x9e8>
ffffffffc02031f0:	984fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgfault_num==4);
ffffffffc02031f4:	00002697          	auipc	a3,0x2
ffffffffc02031f8:	4cc68693          	addi	a3,a3,1228 # ffffffffc02056c0 <default_pmm_manager+0x888>
ffffffffc02031fc:	00002617          	auipc	a2,0x2
ffffffffc0203200:	8a460613          	addi	a2,a2,-1884 # ffffffffc0204aa0 <commands+0x870>
ffffffffc0203204:	07d00593          	li	a1,125
ffffffffc0203208:	00002517          	auipc	a0,0x2
ffffffffc020320c:	61850513          	addi	a0,a0,1560 # ffffffffc0205820 <default_pmm_manager+0x9e8>
ffffffffc0203210:	964fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgfault_num==4);
ffffffffc0203214:	00002697          	auipc	a3,0x2
ffffffffc0203218:	4ac68693          	addi	a3,a3,1196 # ffffffffc02056c0 <default_pmm_manager+0x888>
ffffffffc020321c:	00002617          	auipc	a2,0x2
ffffffffc0203220:	88460613          	addi	a2,a2,-1916 # ffffffffc0204aa0 <commands+0x870>
ffffffffc0203224:	07b00593          	li	a1,123
ffffffffc0203228:	00002517          	auipc	a0,0x2
ffffffffc020322c:	5f850513          	addi	a0,a0,1528 # ffffffffc0205820 <default_pmm_manager+0x9e8>
ffffffffc0203230:	944fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgfault_num==4);
ffffffffc0203234:	00002697          	auipc	a3,0x2
ffffffffc0203238:	48c68693          	addi	a3,a3,1164 # ffffffffc02056c0 <default_pmm_manager+0x888>
ffffffffc020323c:	00002617          	auipc	a2,0x2
ffffffffc0203240:	86460613          	addi	a2,a2,-1948 # ffffffffc0204aa0 <commands+0x870>
ffffffffc0203244:	07900593          	li	a1,121
ffffffffc0203248:	00002517          	auipc	a0,0x2
ffffffffc020324c:	5d850513          	addi	a0,a0,1496 # ffffffffc0205820 <default_pmm_manager+0x9e8>
ffffffffc0203250:	924fd0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0203254 <_clock_swap_out_victim>:
         assert(head != NULL);
ffffffffc0203254:	751c                	ld	a5,40(a0)
{
ffffffffc0203256:	1141                	addi	sp,sp,-16
ffffffffc0203258:	e406                	sd	ra,8(sp)
         assert(head != NULL);
ffffffffc020325a:	c39d                	beqz	a5,ffffffffc0203280 <_clock_swap_out_victim+0x2c>
     assert(in_tick==0);
ffffffffc020325c:	e211                	bnez	a2,ffffffffc0203260 <_clock_swap_out_victim+0xc>
    }
ffffffffc020325e:	a001                	j	ffffffffc020325e <_clock_swap_out_victim+0xa>
     assert(in_tick==0);
ffffffffc0203260:	00002697          	auipc	a3,0x2
ffffffffc0203264:	65868693          	addi	a3,a3,1624 # ffffffffc02058b8 <default_pmm_manager+0xa80>
ffffffffc0203268:	00002617          	auipc	a2,0x2
ffffffffc020326c:	83860613          	addi	a2,a2,-1992 # ffffffffc0204aa0 <commands+0x870>
ffffffffc0203270:	04400593          	li	a1,68
ffffffffc0203274:	00002517          	auipc	a0,0x2
ffffffffc0203278:	5ac50513          	addi	a0,a0,1452 # ffffffffc0205820 <default_pmm_manager+0x9e8>
ffffffffc020327c:	8f8fd0ef          	jal	ra,ffffffffc0200374 <__panic>
         assert(head != NULL);
ffffffffc0203280:	00002697          	auipc	a3,0x2
ffffffffc0203284:	62868693          	addi	a3,a3,1576 # ffffffffc02058a8 <default_pmm_manager+0xa70>
ffffffffc0203288:	00002617          	auipc	a2,0x2
ffffffffc020328c:	81860613          	addi	a2,a2,-2024 # ffffffffc0204aa0 <commands+0x870>
ffffffffc0203290:	04300593          	li	a1,67
ffffffffc0203294:	00002517          	auipc	a0,0x2
ffffffffc0203298:	58c50513          	addi	a0,a0,1420 # ffffffffc0205820 <default_pmm_manager+0x9e8>
ffffffffc020329c:	8d8fd0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc02032a0 <_clock_map_swappable>:
    list_entry_t *entry=&(page->pra_page_link);
ffffffffc02032a0:	03060613          	addi	a2,a2,48
    assert(entry != NULL && curr_ptr != NULL);
ffffffffc02032a4:	ca09                	beqz	a2,ffffffffc02032b6 <_clock_map_swappable+0x16>
ffffffffc02032a6:	0000d797          	auipc	a5,0xd
ffffffffc02032aa:	2ea78793          	addi	a5,a5,746 # ffffffffc0210590 <curr_ptr>
ffffffffc02032ae:	639c                	ld	a5,0(a5)
ffffffffc02032b0:	c399                	beqz	a5,ffffffffc02032b6 <_clock_map_swappable+0x16>
}
ffffffffc02032b2:	4501                	li	a0,0
ffffffffc02032b4:	8082                	ret
{
ffffffffc02032b6:	1141                	addi	sp,sp,-16
    assert(entry != NULL && curr_ptr != NULL);
ffffffffc02032b8:	00002697          	auipc	a3,0x2
ffffffffc02032bc:	5c868693          	addi	a3,a3,1480 # ffffffffc0205880 <default_pmm_manager+0xa48>
ffffffffc02032c0:	00001617          	auipc	a2,0x1
ffffffffc02032c4:	7e060613          	addi	a2,a2,2016 # ffffffffc0204aa0 <commands+0x870>
ffffffffc02032c8:	03300593          	li	a1,51
ffffffffc02032cc:	00002517          	auipc	a0,0x2
ffffffffc02032d0:	55450513          	addi	a0,a0,1364 # ffffffffc0205820 <default_pmm_manager+0x9e8>
{
ffffffffc02032d4:	e406                	sd	ra,8(sp)
    assert(entry != NULL && curr_ptr != NULL);
ffffffffc02032d6:	89efd0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc02032da <_clock_tick_event>:
ffffffffc02032da:	4501                	li	a0,0
ffffffffc02032dc:	8082                	ret

ffffffffc02032de <check_vma_overlap.isra.0.part.1>:
}


// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc02032de:	1141                	addi	sp,sp,-16
    assert(prev->vm_start < prev->vm_end);
    assert(prev->vm_end <= next->vm_start);
    assert(next->vm_start < next->vm_end);
ffffffffc02032e0:	00002697          	auipc	a3,0x2
ffffffffc02032e4:	60068693          	addi	a3,a3,1536 # ffffffffc02058e0 <default_pmm_manager+0xaa8>
ffffffffc02032e8:	00001617          	auipc	a2,0x1
ffffffffc02032ec:	7b860613          	addi	a2,a2,1976 # ffffffffc0204aa0 <commands+0x870>
ffffffffc02032f0:	07d00593          	li	a1,125
ffffffffc02032f4:	00002517          	auipc	a0,0x2
ffffffffc02032f8:	60c50513          	addi	a0,a0,1548 # ffffffffc0205900 <default_pmm_manager+0xac8>
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc02032fc:	e406                	sd	ra,8(sp)
    assert(next->vm_start < next->vm_end);
ffffffffc02032fe:	876fd0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0203302 <mm_create>:
mm_create(void) {
ffffffffc0203302:	1141                	addi	sp,sp,-16
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0203304:	03000513          	li	a0,48
mm_create(void) {
ffffffffc0203308:	e022                	sd	s0,0(sp)
ffffffffc020330a:	e406                	sd	ra,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc020330c:	b8eff0ef          	jal	ra,ffffffffc020269a <kmalloc>
ffffffffc0203310:	842a                	mv	s0,a0
    if (mm != NULL) {
ffffffffc0203312:	c115                	beqz	a0,ffffffffc0203336 <mm_create+0x34>
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0203314:	0000d797          	auipc	a5,0xd
ffffffffc0203318:	15c78793          	addi	a5,a5,348 # ffffffffc0210470 <swap_init_ok>
ffffffffc020331c:	439c                	lw	a5,0(a5)
    elm->prev = elm->next = elm;
ffffffffc020331e:	e408                	sd	a0,8(s0)
ffffffffc0203320:	e008                	sd	a0,0(s0)
        mm->mmap_cache = NULL;
ffffffffc0203322:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc0203326:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc020332a:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc020332e:	2781                	sext.w	a5,a5
ffffffffc0203330:	eb81                	bnez	a5,ffffffffc0203340 <mm_create+0x3e>
        else mm->sm_priv = NULL;
ffffffffc0203332:	02053423          	sd	zero,40(a0)
}
ffffffffc0203336:	8522                	mv	a0,s0
ffffffffc0203338:	60a2                	ld	ra,8(sp)
ffffffffc020333a:	6402                	ld	s0,0(sp)
ffffffffc020333c:	0141                	addi	sp,sp,16
ffffffffc020333e:	8082                	ret
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0203340:	b7dff0ef          	jal	ra,ffffffffc0202ebc <swap_init_mm>
}
ffffffffc0203344:	8522                	mv	a0,s0
ffffffffc0203346:	60a2                	ld	ra,8(sp)
ffffffffc0203348:	6402                	ld	s0,0(sp)
ffffffffc020334a:	0141                	addi	sp,sp,16
ffffffffc020334c:	8082                	ret

ffffffffc020334e <vma_create>:
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint_t vm_flags) {
ffffffffc020334e:	1101                	addi	sp,sp,-32
ffffffffc0203350:	e04a                	sd	s2,0(sp)
ffffffffc0203352:	892a                	mv	s2,a0
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0203354:	03000513          	li	a0,48
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint_t vm_flags) {
ffffffffc0203358:	e822                	sd	s0,16(sp)
ffffffffc020335a:	e426                	sd	s1,8(sp)
ffffffffc020335c:	ec06                	sd	ra,24(sp)
ffffffffc020335e:	84ae                	mv	s1,a1
ffffffffc0203360:	8432                	mv	s0,a2
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0203362:	b38ff0ef          	jal	ra,ffffffffc020269a <kmalloc>
    if (vma != NULL) {
ffffffffc0203366:	c509                	beqz	a0,ffffffffc0203370 <vma_create+0x22>
        vma->vm_start = vm_start;
ffffffffc0203368:	01253423          	sd	s2,8(a0)
        vma->vm_end = vm_end;
ffffffffc020336c:	e904                	sd	s1,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc020336e:	ed00                	sd	s0,24(a0)
}
ffffffffc0203370:	60e2                	ld	ra,24(sp)
ffffffffc0203372:	6442                	ld	s0,16(sp)
ffffffffc0203374:	64a2                	ld	s1,8(sp)
ffffffffc0203376:	6902                	ld	s2,0(sp)
ffffffffc0203378:	6105                	addi	sp,sp,32
ffffffffc020337a:	8082                	ret

ffffffffc020337c <find_vma>:
    if (mm != NULL) {
ffffffffc020337c:	c51d                	beqz	a0,ffffffffc02033aa <find_vma+0x2e>
        vma = mm->mmap_cache;
ffffffffc020337e:	691c                	ld	a5,16(a0)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc0203380:	c781                	beqz	a5,ffffffffc0203388 <find_vma+0xc>
ffffffffc0203382:	6798                	ld	a4,8(a5)
ffffffffc0203384:	02e5f663          	bleu	a4,a1,ffffffffc02033b0 <find_vma+0x34>
                list_entry_t *list = &(mm->mmap_list), *le = list;
ffffffffc0203388:	87aa                	mv	a5,a0
    return listelm->next;
ffffffffc020338a:	679c                	ld	a5,8(a5)
                while ((le = list_next(le)) != list) {
ffffffffc020338c:	00f50f63          	beq	a0,a5,ffffffffc02033aa <find_vma+0x2e>
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
ffffffffc0203390:	fe87b703          	ld	a4,-24(a5)
ffffffffc0203394:	fee5ebe3          	bltu	a1,a4,ffffffffc020338a <find_vma+0xe>
ffffffffc0203398:	ff07b703          	ld	a4,-16(a5)
ffffffffc020339c:	fee5f7e3          	bleu	a4,a1,ffffffffc020338a <find_vma+0xe>
                    vma = le2vma(le, list_link);
ffffffffc02033a0:	1781                	addi	a5,a5,-32
        if (vma != NULL) {
ffffffffc02033a2:	c781                	beqz	a5,ffffffffc02033aa <find_vma+0x2e>
            mm->mmap_cache = vma;
ffffffffc02033a4:	e91c                	sd	a5,16(a0)
}
ffffffffc02033a6:	853e                	mv	a0,a5
ffffffffc02033a8:	8082                	ret
    struct vma_struct *vma = NULL;
ffffffffc02033aa:	4781                	li	a5,0
}
ffffffffc02033ac:	853e                	mv	a0,a5
ffffffffc02033ae:	8082                	ret
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc02033b0:	6b98                	ld	a4,16(a5)
ffffffffc02033b2:	fce5fbe3          	bleu	a4,a1,ffffffffc0203388 <find_vma+0xc>
            mm->mmap_cache = vma;
ffffffffc02033b6:	e91c                	sd	a5,16(a0)
    return vma;
ffffffffc02033b8:	b7fd                	j	ffffffffc02033a6 <find_vma+0x2a>

ffffffffc02033ba <insert_vma_struct>:


// insert_vma_struct -insert vma in mm's list link
void
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
    assert(vma->vm_start < vma->vm_end);
ffffffffc02033ba:	6590                	ld	a2,8(a1)
ffffffffc02033bc:	0105b803          	ld	a6,16(a1) # 1010 <BASE_ADDRESS-0xffffffffc01feff0>
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
ffffffffc02033c0:	1141                	addi	sp,sp,-16
ffffffffc02033c2:	e406                	sd	ra,8(sp)
ffffffffc02033c4:	872a                	mv	a4,a0
    assert(vma->vm_start < vma->vm_end);
ffffffffc02033c6:	01066863          	bltu	a2,a6,ffffffffc02033d6 <insert_vma_struct+0x1c>
ffffffffc02033ca:	a8b9                	j	ffffffffc0203428 <insert_vma_struct+0x6e>
    list_entry_t *le_prev = list, *le_next;

        list_entry_t *le = list;
        while ((le = list_next(le)) != list) {
            struct vma_struct *mmap_prev = le2vma(le, list_link);
            if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc02033cc:	fe87b683          	ld	a3,-24(a5)
ffffffffc02033d0:	04d66763          	bltu	a2,a3,ffffffffc020341e <insert_vma_struct+0x64>
ffffffffc02033d4:	873e                	mv	a4,a5
ffffffffc02033d6:	671c                	ld	a5,8(a4)
        while ((le = list_next(le)) != list) {
ffffffffc02033d8:	fef51ae3          	bne	a0,a5,ffffffffc02033cc <insert_vma_struct+0x12>
        }

    le_next = list_next(le_prev);

    /* check overlap */
    if (le_prev != list) {
ffffffffc02033dc:	02a70463          	beq	a4,a0,ffffffffc0203404 <insert_vma_struct+0x4a>
        check_vma_overlap(le2vma(le_prev, list_link), vma);
ffffffffc02033e0:	ff073683          	ld	a3,-16(a4)
    assert(prev->vm_start < prev->vm_end);
ffffffffc02033e4:	fe873883          	ld	a7,-24(a4)
ffffffffc02033e8:	08d8f063          	bleu	a3,a7,ffffffffc0203468 <insert_vma_struct+0xae>
    assert(prev->vm_end <= next->vm_start);
ffffffffc02033ec:	04d66e63          	bltu	a2,a3,ffffffffc0203448 <insert_vma_struct+0x8e>
    }
    if (le_next != list) {
ffffffffc02033f0:	00f50a63          	beq	a0,a5,ffffffffc0203404 <insert_vma_struct+0x4a>
ffffffffc02033f4:	fe87b683          	ld	a3,-24(a5)
    assert(prev->vm_end <= next->vm_start);
ffffffffc02033f8:	0506e863          	bltu	a3,a6,ffffffffc0203448 <insert_vma_struct+0x8e>
    assert(next->vm_start < next->vm_end);
ffffffffc02033fc:	ff07b603          	ld	a2,-16(a5)
ffffffffc0203400:	02c6f263          	bleu	a2,a3,ffffffffc0203424 <insert_vma_struct+0x6a>
    }

    vma->vm_mm = mm;
    list_add_after(le_prev, &(vma->list_link));

    mm->map_count ++;
ffffffffc0203404:	5114                	lw	a3,32(a0)
    vma->vm_mm = mm;
ffffffffc0203406:	e188                	sd	a0,0(a1)
    list_add_after(le_prev, &(vma->list_link));
ffffffffc0203408:	02058613          	addi	a2,a1,32
    prev->next = next->prev = elm;
ffffffffc020340c:	e390                	sd	a2,0(a5)
ffffffffc020340e:	e710                	sd	a2,8(a4)
}
ffffffffc0203410:	60a2                	ld	ra,8(sp)
    elm->next = next;
ffffffffc0203412:	f59c                	sd	a5,40(a1)
    elm->prev = prev;
ffffffffc0203414:	f198                	sd	a4,32(a1)
    mm->map_count ++;
ffffffffc0203416:	2685                	addiw	a3,a3,1
ffffffffc0203418:	d114                	sw	a3,32(a0)
}
ffffffffc020341a:	0141                	addi	sp,sp,16
ffffffffc020341c:	8082                	ret
    if (le_prev != list) {
ffffffffc020341e:	fca711e3          	bne	a4,a0,ffffffffc02033e0 <insert_vma_struct+0x26>
ffffffffc0203422:	bfd9                	j	ffffffffc02033f8 <insert_vma_struct+0x3e>
ffffffffc0203424:	ebbff0ef          	jal	ra,ffffffffc02032de <check_vma_overlap.isra.0.part.1>
    assert(vma->vm_start < vma->vm_end);
ffffffffc0203428:	00002697          	auipc	a3,0x2
ffffffffc020342c:	56868693          	addi	a3,a3,1384 # ffffffffc0205990 <default_pmm_manager+0xb58>
ffffffffc0203430:	00001617          	auipc	a2,0x1
ffffffffc0203434:	67060613          	addi	a2,a2,1648 # ffffffffc0204aa0 <commands+0x870>
ffffffffc0203438:	08400593          	li	a1,132
ffffffffc020343c:	00002517          	auipc	a0,0x2
ffffffffc0203440:	4c450513          	addi	a0,a0,1220 # ffffffffc0205900 <default_pmm_manager+0xac8>
ffffffffc0203444:	f31fc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0203448:	00002697          	auipc	a3,0x2
ffffffffc020344c:	58868693          	addi	a3,a3,1416 # ffffffffc02059d0 <default_pmm_manager+0xb98>
ffffffffc0203450:	00001617          	auipc	a2,0x1
ffffffffc0203454:	65060613          	addi	a2,a2,1616 # ffffffffc0204aa0 <commands+0x870>
ffffffffc0203458:	07c00593          	li	a1,124
ffffffffc020345c:	00002517          	auipc	a0,0x2
ffffffffc0203460:	4a450513          	addi	a0,a0,1188 # ffffffffc0205900 <default_pmm_manager+0xac8>
ffffffffc0203464:	f11fc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(prev->vm_start < prev->vm_end);
ffffffffc0203468:	00002697          	auipc	a3,0x2
ffffffffc020346c:	54868693          	addi	a3,a3,1352 # ffffffffc02059b0 <default_pmm_manager+0xb78>
ffffffffc0203470:	00001617          	auipc	a2,0x1
ffffffffc0203474:	63060613          	addi	a2,a2,1584 # ffffffffc0204aa0 <commands+0x870>
ffffffffc0203478:	07b00593          	li	a1,123
ffffffffc020347c:	00002517          	auipc	a0,0x2
ffffffffc0203480:	48450513          	addi	a0,a0,1156 # ffffffffc0205900 <default_pmm_manager+0xac8>
ffffffffc0203484:	ef1fc0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0203488 <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {
ffffffffc0203488:	1141                	addi	sp,sp,-16
ffffffffc020348a:	e022                	sd	s0,0(sp)
ffffffffc020348c:	842a                	mv	s0,a0
    return listelm->next;
ffffffffc020348e:	6508                	ld	a0,8(a0)
ffffffffc0203490:	e406                	sd	ra,8(sp)

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list) {
ffffffffc0203492:	00a40e63          	beq	s0,a0,ffffffffc02034ae <mm_destroy+0x26>
    __list_del(listelm->prev, listelm->next);
ffffffffc0203496:	6118                	ld	a4,0(a0)
ffffffffc0203498:	651c                	ld	a5,8(a0)
        list_del(le);
        kfree(le2vma(le, list_link),sizeof(struct vma_struct));  //kfree vma        
ffffffffc020349a:	03000593          	li	a1,48
ffffffffc020349e:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc02034a0:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc02034a2:	e398                	sd	a4,0(a5)
ffffffffc02034a4:	ab8ff0ef          	jal	ra,ffffffffc020275c <kfree>
    return listelm->next;
ffffffffc02034a8:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list) {
ffffffffc02034aa:	fea416e3          	bne	s0,a0,ffffffffc0203496 <mm_destroy+0xe>
    }
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc02034ae:	8522                	mv	a0,s0
    mm=NULL;
}
ffffffffc02034b0:	6402                	ld	s0,0(sp)
ffffffffc02034b2:	60a2                	ld	ra,8(sp)
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc02034b4:	03000593          	li	a1,48
}
ffffffffc02034b8:	0141                	addi	sp,sp,16
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc02034ba:	aa2ff06f          	j	ffffffffc020275c <kfree>

ffffffffc02034be <vmm_init>:

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void
vmm_init(void) {
ffffffffc02034be:	715d                	addi	sp,sp,-80
ffffffffc02034c0:	e486                	sd	ra,72(sp)
ffffffffc02034c2:	e0a2                	sd	s0,64(sp)
ffffffffc02034c4:	fc26                	sd	s1,56(sp)
ffffffffc02034c6:	f84a                	sd	s2,48(sp)
ffffffffc02034c8:	f052                	sd	s4,32(sp)
ffffffffc02034ca:	f44e                	sd	s3,40(sp)
ffffffffc02034cc:	ec56                	sd	s5,24(sp)
ffffffffc02034ce:	e85a                	sd	s6,16(sp)
ffffffffc02034d0:	e45e                	sd	s7,8(sp)
}

// check_vmm - check correctness of vmm
static void
check_vmm(void) {
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc02034d2:	a6afe0ef          	jal	ra,ffffffffc020173c <nr_free_pages>
ffffffffc02034d6:	892a                	mv	s2,a0
    cprintf("check_vmm() succeeded.\n");
}

static void
check_vma_struct(void) {
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc02034d8:	a64fe0ef          	jal	ra,ffffffffc020173c <nr_free_pages>
ffffffffc02034dc:	8a2a                	mv	s4,a0

    struct mm_struct *mm = mm_create();
ffffffffc02034de:	e25ff0ef          	jal	ra,ffffffffc0203302 <mm_create>
    assert(mm != NULL);
ffffffffc02034e2:	842a                	mv	s0,a0
ffffffffc02034e4:	03200493          	li	s1,50
ffffffffc02034e8:	e919                	bnez	a0,ffffffffc02034fe <vmm_init+0x40>
ffffffffc02034ea:	aeed                	j	ffffffffc02038e4 <vmm_init+0x426>
        vma->vm_start = vm_start;
ffffffffc02034ec:	e504                	sd	s1,8(a0)
        vma->vm_end = vm_end;
ffffffffc02034ee:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc02034f0:	00053c23          	sd	zero,24(a0)

    int i;
    for (i = step1; i >= 1; i --) {
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc02034f4:	14ed                	addi	s1,s1,-5
ffffffffc02034f6:	8522                	mv	a0,s0
ffffffffc02034f8:	ec3ff0ef          	jal	ra,ffffffffc02033ba <insert_vma_struct>
    for (i = step1; i >= 1; i --) {
ffffffffc02034fc:	c88d                	beqz	s1,ffffffffc020352e <vmm_init+0x70>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02034fe:	03000513          	li	a0,48
ffffffffc0203502:	998ff0ef          	jal	ra,ffffffffc020269a <kmalloc>
ffffffffc0203506:	85aa                	mv	a1,a0
ffffffffc0203508:	00248793          	addi	a5,s1,2
    if (vma != NULL) {
ffffffffc020350c:	f165                	bnez	a0,ffffffffc02034ec <vmm_init+0x2e>
        assert(vma != NULL);
ffffffffc020350e:	00002697          	auipc	a3,0x2
ffffffffc0203512:	07268693          	addi	a3,a3,114 # ffffffffc0205580 <default_pmm_manager+0x748>
ffffffffc0203516:	00001617          	auipc	a2,0x1
ffffffffc020351a:	58a60613          	addi	a2,a2,1418 # ffffffffc0204aa0 <commands+0x870>
ffffffffc020351e:	0ce00593          	li	a1,206
ffffffffc0203522:	00002517          	auipc	a0,0x2
ffffffffc0203526:	3de50513          	addi	a0,a0,990 # ffffffffc0205900 <default_pmm_manager+0xac8>
ffffffffc020352a:	e4bfc0ef          	jal	ra,ffffffffc0200374 <__panic>
    for (i = step1; i >= 1; i --) {
ffffffffc020352e:	03700493          	li	s1,55
    }

    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc0203532:	1f900993          	li	s3,505
ffffffffc0203536:	a819                	j	ffffffffc020354c <vmm_init+0x8e>
        vma->vm_start = vm_start;
ffffffffc0203538:	e504                	sd	s1,8(a0)
        vma->vm_end = vm_end;
ffffffffc020353a:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc020353c:	00053c23          	sd	zero,24(a0)
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0203540:	0495                	addi	s1,s1,5
ffffffffc0203542:	8522                	mv	a0,s0
ffffffffc0203544:	e77ff0ef          	jal	ra,ffffffffc02033ba <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc0203548:	03348a63          	beq	s1,s3,ffffffffc020357c <vmm_init+0xbe>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc020354c:	03000513          	li	a0,48
ffffffffc0203550:	94aff0ef          	jal	ra,ffffffffc020269a <kmalloc>
ffffffffc0203554:	85aa                	mv	a1,a0
ffffffffc0203556:	00248793          	addi	a5,s1,2
    if (vma != NULL) {
ffffffffc020355a:	fd79                	bnez	a0,ffffffffc0203538 <vmm_init+0x7a>
        assert(vma != NULL);
ffffffffc020355c:	00002697          	auipc	a3,0x2
ffffffffc0203560:	02468693          	addi	a3,a3,36 # ffffffffc0205580 <default_pmm_manager+0x748>
ffffffffc0203564:	00001617          	auipc	a2,0x1
ffffffffc0203568:	53c60613          	addi	a2,a2,1340 # ffffffffc0204aa0 <commands+0x870>
ffffffffc020356c:	0d400593          	li	a1,212
ffffffffc0203570:	00002517          	auipc	a0,0x2
ffffffffc0203574:	39050513          	addi	a0,a0,912 # ffffffffc0205900 <default_pmm_manager+0xac8>
ffffffffc0203578:	dfdfc0ef          	jal	ra,ffffffffc0200374 <__panic>
ffffffffc020357c:	6418                	ld	a4,8(s0)
ffffffffc020357e:	479d                	li	a5,7
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i ++) {
ffffffffc0203580:	1fb00593          	li	a1,507
        assert(le != &(mm->mmap_list));
ffffffffc0203584:	2ae40063          	beq	s0,a4,ffffffffc0203824 <vmm_init+0x366>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0203588:	fe873603          	ld	a2,-24(a4)
ffffffffc020358c:	ffe78693          	addi	a3,a5,-2
ffffffffc0203590:	20d61a63          	bne	a2,a3,ffffffffc02037a4 <vmm_init+0x2e6>
ffffffffc0203594:	ff073683          	ld	a3,-16(a4)
ffffffffc0203598:	20d79663          	bne	a5,a3,ffffffffc02037a4 <vmm_init+0x2e6>
ffffffffc020359c:	0795                	addi	a5,a5,5
ffffffffc020359e:	6718                	ld	a4,8(a4)
    for (i = 1; i <= step2; i ++) {
ffffffffc02035a0:	feb792e3          	bne	a5,a1,ffffffffc0203584 <vmm_init+0xc6>
ffffffffc02035a4:	499d                	li	s3,7
ffffffffc02035a6:	4495                	li	s1,5
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc02035a8:	1f900b93          	li	s7,505
        struct vma_struct *vma1 = find_vma(mm, i);
ffffffffc02035ac:	85a6                	mv	a1,s1
ffffffffc02035ae:	8522                	mv	a0,s0
ffffffffc02035b0:	dcdff0ef          	jal	ra,ffffffffc020337c <find_vma>
ffffffffc02035b4:	8b2a                	mv	s6,a0
        assert(vma1 != NULL);
ffffffffc02035b6:	2e050763          	beqz	a0,ffffffffc02038a4 <vmm_init+0x3e6>
        struct vma_struct *vma2 = find_vma(mm, i+1);
ffffffffc02035ba:	00148593          	addi	a1,s1,1
ffffffffc02035be:	8522                	mv	a0,s0
ffffffffc02035c0:	dbdff0ef          	jal	ra,ffffffffc020337c <find_vma>
ffffffffc02035c4:	8aaa                	mv	s5,a0
        assert(vma2 != NULL);
ffffffffc02035c6:	2a050f63          	beqz	a0,ffffffffc0203884 <vmm_init+0x3c6>
        struct vma_struct *vma3 = find_vma(mm, i+2);
ffffffffc02035ca:	85ce                	mv	a1,s3
ffffffffc02035cc:	8522                	mv	a0,s0
ffffffffc02035ce:	dafff0ef          	jal	ra,ffffffffc020337c <find_vma>
        assert(vma3 == NULL);
ffffffffc02035d2:	28051963          	bnez	a0,ffffffffc0203864 <vmm_init+0x3a6>
        struct vma_struct *vma4 = find_vma(mm, i+3);
ffffffffc02035d6:	00348593          	addi	a1,s1,3
ffffffffc02035da:	8522                	mv	a0,s0
ffffffffc02035dc:	da1ff0ef          	jal	ra,ffffffffc020337c <find_vma>
        assert(vma4 == NULL);
ffffffffc02035e0:	26051263          	bnez	a0,ffffffffc0203844 <vmm_init+0x386>
        struct vma_struct *vma5 = find_vma(mm, i+4);
ffffffffc02035e4:	00448593          	addi	a1,s1,4
ffffffffc02035e8:	8522                	mv	a0,s0
ffffffffc02035ea:	d93ff0ef          	jal	ra,ffffffffc020337c <find_vma>
        assert(vma5 == NULL);
ffffffffc02035ee:	2c051b63          	bnez	a0,ffffffffc02038c4 <vmm_init+0x406>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc02035f2:	008b3783          	ld	a5,8(s6)
ffffffffc02035f6:	1c979763          	bne	a5,s1,ffffffffc02037c4 <vmm_init+0x306>
ffffffffc02035fa:	010b3783          	ld	a5,16(s6)
ffffffffc02035fe:	1d379363          	bne	a5,s3,ffffffffc02037c4 <vmm_init+0x306>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc0203602:	008ab783          	ld	a5,8(s5)
ffffffffc0203606:	1c979f63          	bne	a5,s1,ffffffffc02037e4 <vmm_init+0x326>
ffffffffc020360a:	010ab783          	ld	a5,16(s5)
ffffffffc020360e:	1d379b63          	bne	a5,s3,ffffffffc02037e4 <vmm_init+0x326>
ffffffffc0203612:	0495                	addi	s1,s1,5
ffffffffc0203614:	0995                	addi	s3,s3,5
    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc0203616:	f9749be3          	bne	s1,s7,ffffffffc02035ac <vmm_init+0xee>
ffffffffc020361a:	4491                	li	s1,4
    }

    for (i =4; i>=0; i--) {
ffffffffc020361c:	59fd                	li	s3,-1
        struct vma_struct *vma_below_5= find_vma(mm,i);
ffffffffc020361e:	85a6                	mv	a1,s1
ffffffffc0203620:	8522                	mv	a0,s0
ffffffffc0203622:	d5bff0ef          	jal	ra,ffffffffc020337c <find_vma>
ffffffffc0203626:	0004859b          	sext.w	a1,s1
        if (vma_below_5 != NULL ) {
ffffffffc020362a:	c90d                	beqz	a0,ffffffffc020365c <vmm_init+0x19e>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
ffffffffc020362c:	6914                	ld	a3,16(a0)
ffffffffc020362e:	6510                	ld	a2,8(a0)
ffffffffc0203630:	00002517          	auipc	a0,0x2
ffffffffc0203634:	4c050513          	addi	a0,a0,1216 # ffffffffc0205af0 <default_pmm_manager+0xcb8>
ffffffffc0203638:	a87fc0ef          	jal	ra,ffffffffc02000be <cprintf>
        }
        assert(vma_below_5 == NULL);
ffffffffc020363c:	00002697          	auipc	a3,0x2
ffffffffc0203640:	4dc68693          	addi	a3,a3,1244 # ffffffffc0205b18 <default_pmm_manager+0xce0>
ffffffffc0203644:	00001617          	auipc	a2,0x1
ffffffffc0203648:	45c60613          	addi	a2,a2,1116 # ffffffffc0204aa0 <commands+0x870>
ffffffffc020364c:	0f600593          	li	a1,246
ffffffffc0203650:	00002517          	auipc	a0,0x2
ffffffffc0203654:	2b050513          	addi	a0,a0,688 # ffffffffc0205900 <default_pmm_manager+0xac8>
ffffffffc0203658:	d1dfc0ef          	jal	ra,ffffffffc0200374 <__panic>
ffffffffc020365c:	14fd                	addi	s1,s1,-1
    for (i =4; i>=0; i--) {
ffffffffc020365e:	fd3490e3          	bne	s1,s3,ffffffffc020361e <vmm_init+0x160>
    }

    mm_destroy(mm);
ffffffffc0203662:	8522                	mv	a0,s0
ffffffffc0203664:	e25ff0ef          	jal	ra,ffffffffc0203488 <mm_destroy>

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0203668:	8d4fe0ef          	jal	ra,ffffffffc020173c <nr_free_pages>
ffffffffc020366c:	28aa1c63          	bne	s4,a0,ffffffffc0203904 <vmm_init+0x446>

    cprintf("check_vma_struct() succeeded!\n");
ffffffffc0203670:	00002517          	auipc	a0,0x2
ffffffffc0203674:	4e850513          	addi	a0,a0,1256 # ffffffffc0205b58 <default_pmm_manager+0xd20>
ffffffffc0203678:	a47fc0ef          	jal	ra,ffffffffc02000be <cprintf>

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void) {
	// char *name = "check_pgfault";
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc020367c:	8c0fe0ef          	jal	ra,ffffffffc020173c <nr_free_pages>
ffffffffc0203680:	89aa                	mv	s3,a0

    check_mm_struct = mm_create();
ffffffffc0203682:	c81ff0ef          	jal	ra,ffffffffc0203302 <mm_create>
ffffffffc0203686:	0000d797          	auipc	a5,0xd
ffffffffc020368a:	f0a7b923          	sd	a0,-238(a5) # ffffffffc0210598 <check_mm_struct>
ffffffffc020368e:	842a                	mv	s0,a0

    assert(check_mm_struct != NULL);
ffffffffc0203690:	2a050a63          	beqz	a0,ffffffffc0203944 <vmm_init+0x486>
    struct mm_struct *mm = check_mm_struct;
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0203694:	0000d797          	auipc	a5,0xd
ffffffffc0203698:	dc478793          	addi	a5,a5,-572 # ffffffffc0210458 <boot_pgdir>
ffffffffc020369c:	6384                	ld	s1,0(a5)
    assert(pgdir[0] == 0);
ffffffffc020369e:	609c                	ld	a5,0(s1)
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc02036a0:	ed04                	sd	s1,24(a0)
    assert(pgdir[0] == 0);
ffffffffc02036a2:	32079d63          	bnez	a5,ffffffffc02039dc <vmm_init+0x51e>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02036a6:	03000513          	li	a0,48
ffffffffc02036aa:	ff1fe0ef          	jal	ra,ffffffffc020269a <kmalloc>
ffffffffc02036ae:	8a2a                	mv	s4,a0
    if (vma != NULL) {
ffffffffc02036b0:	14050a63          	beqz	a0,ffffffffc0203804 <vmm_init+0x346>
        vma->vm_end = vm_end;
ffffffffc02036b4:	002007b7          	lui	a5,0x200
ffffffffc02036b8:	00fa3823          	sd	a5,16(s4)
        vma->vm_flags = vm_flags;
ffffffffc02036bc:	4789                	li	a5,2

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);

    assert(vma != NULL);

    insert_vma_struct(mm, vma);
ffffffffc02036be:	85aa                	mv	a1,a0
        vma->vm_flags = vm_flags;
ffffffffc02036c0:	00fa3c23          	sd	a5,24(s4)
    insert_vma_struct(mm, vma);
ffffffffc02036c4:	8522                	mv	a0,s0
        vma->vm_start = vm_start;
ffffffffc02036c6:	000a3423          	sd	zero,8(s4)
    insert_vma_struct(mm, vma);
ffffffffc02036ca:	cf1ff0ef          	jal	ra,ffffffffc02033ba <insert_vma_struct>

    uintptr_t addr = 0x100;
    assert(find_vma(mm, addr) == vma);
ffffffffc02036ce:	10000593          	li	a1,256
ffffffffc02036d2:	8522                	mv	a0,s0
ffffffffc02036d4:	ca9ff0ef          	jal	ra,ffffffffc020337c <find_vma>
ffffffffc02036d8:	10000793          	li	a5,256

    int i, sum = 0;
    for (i = 0; i < 100; i ++) {
ffffffffc02036dc:	16400713          	li	a4,356
    assert(find_vma(mm, addr) == vma);
ffffffffc02036e0:	2aaa1263          	bne	s4,a0,ffffffffc0203984 <vmm_init+0x4c6>
        *(char *)(addr + i) = i;
ffffffffc02036e4:	00f78023          	sb	a5,0(a5) # 200000 <BASE_ADDRESS-0xffffffffc0000000>
        sum += i;
ffffffffc02036e8:	0785                	addi	a5,a5,1
    for (i = 0; i < 100; i ++) {
ffffffffc02036ea:	fee79de3          	bne	a5,a4,ffffffffc02036e4 <vmm_init+0x226>
        sum += i;
ffffffffc02036ee:	6705                	lui	a4,0x1
    for (i = 0; i < 100; i ++) {
ffffffffc02036f0:	10000793          	li	a5,256
        sum += i;
ffffffffc02036f4:	35670713          	addi	a4,a4,854 # 1356 <BASE_ADDRESS-0xffffffffc01fecaa>
    }
    for (i = 0; i < 100; i ++) {
ffffffffc02036f8:	16400613          	li	a2,356
        sum -= *(char *)(addr + i);
ffffffffc02036fc:	0007c683          	lbu	a3,0(a5)
ffffffffc0203700:	0785                	addi	a5,a5,1
ffffffffc0203702:	9f15                	subw	a4,a4,a3
    for (i = 0; i < 100; i ++) {
ffffffffc0203704:	fec79ce3          	bne	a5,a2,ffffffffc02036fc <vmm_init+0x23e>
    }
    assert(sum == 0);
ffffffffc0203708:	2a071a63          	bnez	a4,ffffffffc02039bc <vmm_init+0x4fe>

    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
ffffffffc020370c:	4581                	li	a1,0
ffffffffc020370e:	8526                	mv	a0,s1
ffffffffc0203710:	ad2fe0ef          	jal	ra,ffffffffc02019e2 <page_remove>
    return pa2page(PDE_ADDR(pde));
ffffffffc0203714:	609c                	ld	a5,0(s1)
    if (PPN(pa) >= npage) {
ffffffffc0203716:	0000d717          	auipc	a4,0xd
ffffffffc020371a:	d4a70713          	addi	a4,a4,-694 # ffffffffc0210460 <npage>
ffffffffc020371e:	6318                	ld	a4,0(a4)
    return pa2page(PDE_ADDR(pde));
ffffffffc0203720:	078a                	slli	a5,a5,0x2
ffffffffc0203722:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203724:	28e7f063          	bleu	a4,a5,ffffffffc02039a4 <vmm_init+0x4e6>
    return &pages[PPN(pa) - nbase];
ffffffffc0203728:	00002717          	auipc	a4,0x2
ffffffffc020372c:	77070713          	addi	a4,a4,1904 # ffffffffc0205e98 <nbase>
ffffffffc0203730:	6318                	ld	a4,0(a4)
ffffffffc0203732:	0000d697          	auipc	a3,0xd
ffffffffc0203736:	d7e68693          	addi	a3,a3,-642 # ffffffffc02104b0 <pages>
ffffffffc020373a:	6288                	ld	a0,0(a3)
ffffffffc020373c:	8f99                	sub	a5,a5,a4
ffffffffc020373e:	00379713          	slli	a4,a5,0x3
ffffffffc0203742:	97ba                	add	a5,a5,a4
ffffffffc0203744:	078e                	slli	a5,a5,0x3

    free_page(pde2page(pgdir[0]));
ffffffffc0203746:	953e                	add	a0,a0,a5
ffffffffc0203748:	4585                	li	a1,1
ffffffffc020374a:	fadfd0ef          	jal	ra,ffffffffc02016f6 <free_pages>

    pgdir[0] = 0;
ffffffffc020374e:	0004b023          	sd	zero,0(s1)

    mm->pgdir = NULL;
    mm_destroy(mm);
ffffffffc0203752:	8522                	mv	a0,s0
    mm->pgdir = NULL;
ffffffffc0203754:	00043c23          	sd	zero,24(s0)
    mm_destroy(mm);
ffffffffc0203758:	d31ff0ef          	jal	ra,ffffffffc0203488 <mm_destroy>

    check_mm_struct = NULL;
    nr_free_pages_store--;	// szx : Sv39第二级页表多占了一个内存页，所以执行此操作
ffffffffc020375c:	19fd                	addi	s3,s3,-1
    check_mm_struct = NULL;
ffffffffc020375e:	0000d797          	auipc	a5,0xd
ffffffffc0203762:	e207bd23          	sd	zero,-454(a5) # ffffffffc0210598 <check_mm_struct>

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0203766:	fd7fd0ef          	jal	ra,ffffffffc020173c <nr_free_pages>
ffffffffc020376a:	1aa99d63          	bne	s3,a0,ffffffffc0203924 <vmm_init+0x466>

    cprintf("check_pgfault() succeeded!\n");
ffffffffc020376e:	00002517          	auipc	a0,0x2
ffffffffc0203772:	45250513          	addi	a0,a0,1106 # ffffffffc0205bc0 <default_pmm_manager+0xd88>
ffffffffc0203776:	949fc0ef          	jal	ra,ffffffffc02000be <cprintf>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc020377a:	fc3fd0ef          	jal	ra,ffffffffc020173c <nr_free_pages>
    nr_free_pages_store--;	// szx : Sv39三级页表多占一个内存页，所以执行此操作
ffffffffc020377e:	197d                	addi	s2,s2,-1
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0203780:	1ea91263          	bne	s2,a0,ffffffffc0203964 <vmm_init+0x4a6>
}
ffffffffc0203784:	6406                	ld	s0,64(sp)
ffffffffc0203786:	60a6                	ld	ra,72(sp)
ffffffffc0203788:	74e2                	ld	s1,56(sp)
ffffffffc020378a:	7942                	ld	s2,48(sp)
ffffffffc020378c:	79a2                	ld	s3,40(sp)
ffffffffc020378e:	7a02                	ld	s4,32(sp)
ffffffffc0203790:	6ae2                	ld	s5,24(sp)
ffffffffc0203792:	6b42                	ld	s6,16(sp)
ffffffffc0203794:	6ba2                	ld	s7,8(sp)
    cprintf("check_vmm() succeeded.\n");
ffffffffc0203796:	00002517          	auipc	a0,0x2
ffffffffc020379a:	44a50513          	addi	a0,a0,1098 # ffffffffc0205be0 <default_pmm_manager+0xda8>
}
ffffffffc020379e:	6161                	addi	sp,sp,80
    cprintf("check_vmm() succeeded.\n");
ffffffffc02037a0:	91ffc06f          	j	ffffffffc02000be <cprintf>
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc02037a4:	00002697          	auipc	a3,0x2
ffffffffc02037a8:	26468693          	addi	a3,a3,612 # ffffffffc0205a08 <default_pmm_manager+0xbd0>
ffffffffc02037ac:	00001617          	auipc	a2,0x1
ffffffffc02037b0:	2f460613          	addi	a2,a2,756 # ffffffffc0204aa0 <commands+0x870>
ffffffffc02037b4:	0dd00593          	li	a1,221
ffffffffc02037b8:	00002517          	auipc	a0,0x2
ffffffffc02037bc:	14850513          	addi	a0,a0,328 # ffffffffc0205900 <default_pmm_manager+0xac8>
ffffffffc02037c0:	bb5fc0ef          	jal	ra,ffffffffc0200374 <__panic>
        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc02037c4:	00002697          	auipc	a3,0x2
ffffffffc02037c8:	2cc68693          	addi	a3,a3,716 # ffffffffc0205a90 <default_pmm_manager+0xc58>
ffffffffc02037cc:	00001617          	auipc	a2,0x1
ffffffffc02037d0:	2d460613          	addi	a2,a2,724 # ffffffffc0204aa0 <commands+0x870>
ffffffffc02037d4:	0ed00593          	li	a1,237
ffffffffc02037d8:	00002517          	auipc	a0,0x2
ffffffffc02037dc:	12850513          	addi	a0,a0,296 # ffffffffc0205900 <default_pmm_manager+0xac8>
ffffffffc02037e0:	b95fc0ef          	jal	ra,ffffffffc0200374 <__panic>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc02037e4:	00002697          	auipc	a3,0x2
ffffffffc02037e8:	2dc68693          	addi	a3,a3,732 # ffffffffc0205ac0 <default_pmm_manager+0xc88>
ffffffffc02037ec:	00001617          	auipc	a2,0x1
ffffffffc02037f0:	2b460613          	addi	a2,a2,692 # ffffffffc0204aa0 <commands+0x870>
ffffffffc02037f4:	0ee00593          	li	a1,238
ffffffffc02037f8:	00002517          	auipc	a0,0x2
ffffffffc02037fc:	10850513          	addi	a0,a0,264 # ffffffffc0205900 <default_pmm_manager+0xac8>
ffffffffc0203800:	b75fc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(vma != NULL);
ffffffffc0203804:	00002697          	auipc	a3,0x2
ffffffffc0203808:	d7c68693          	addi	a3,a3,-644 # ffffffffc0205580 <default_pmm_manager+0x748>
ffffffffc020380c:	00001617          	auipc	a2,0x1
ffffffffc0203810:	29460613          	addi	a2,a2,660 # ffffffffc0204aa0 <commands+0x870>
ffffffffc0203814:	11100593          	li	a1,273
ffffffffc0203818:	00002517          	auipc	a0,0x2
ffffffffc020381c:	0e850513          	addi	a0,a0,232 # ffffffffc0205900 <default_pmm_manager+0xac8>
ffffffffc0203820:	b55fc0ef          	jal	ra,ffffffffc0200374 <__panic>
        assert(le != &(mm->mmap_list));
ffffffffc0203824:	00002697          	auipc	a3,0x2
ffffffffc0203828:	1cc68693          	addi	a3,a3,460 # ffffffffc02059f0 <default_pmm_manager+0xbb8>
ffffffffc020382c:	00001617          	auipc	a2,0x1
ffffffffc0203830:	27460613          	addi	a2,a2,628 # ffffffffc0204aa0 <commands+0x870>
ffffffffc0203834:	0db00593          	li	a1,219
ffffffffc0203838:	00002517          	auipc	a0,0x2
ffffffffc020383c:	0c850513          	addi	a0,a0,200 # ffffffffc0205900 <default_pmm_manager+0xac8>
ffffffffc0203840:	b35fc0ef          	jal	ra,ffffffffc0200374 <__panic>
        assert(vma4 == NULL);
ffffffffc0203844:	00002697          	auipc	a3,0x2
ffffffffc0203848:	22c68693          	addi	a3,a3,556 # ffffffffc0205a70 <default_pmm_manager+0xc38>
ffffffffc020384c:	00001617          	auipc	a2,0x1
ffffffffc0203850:	25460613          	addi	a2,a2,596 # ffffffffc0204aa0 <commands+0x870>
ffffffffc0203854:	0e900593          	li	a1,233
ffffffffc0203858:	00002517          	auipc	a0,0x2
ffffffffc020385c:	0a850513          	addi	a0,a0,168 # ffffffffc0205900 <default_pmm_manager+0xac8>
ffffffffc0203860:	b15fc0ef          	jal	ra,ffffffffc0200374 <__panic>
        assert(vma3 == NULL);
ffffffffc0203864:	00002697          	auipc	a3,0x2
ffffffffc0203868:	1fc68693          	addi	a3,a3,508 # ffffffffc0205a60 <default_pmm_manager+0xc28>
ffffffffc020386c:	00001617          	auipc	a2,0x1
ffffffffc0203870:	23460613          	addi	a2,a2,564 # ffffffffc0204aa0 <commands+0x870>
ffffffffc0203874:	0e700593          	li	a1,231
ffffffffc0203878:	00002517          	auipc	a0,0x2
ffffffffc020387c:	08850513          	addi	a0,a0,136 # ffffffffc0205900 <default_pmm_manager+0xac8>
ffffffffc0203880:	af5fc0ef          	jal	ra,ffffffffc0200374 <__panic>
        assert(vma2 != NULL);
ffffffffc0203884:	00002697          	auipc	a3,0x2
ffffffffc0203888:	1cc68693          	addi	a3,a3,460 # ffffffffc0205a50 <default_pmm_manager+0xc18>
ffffffffc020388c:	00001617          	auipc	a2,0x1
ffffffffc0203890:	21460613          	addi	a2,a2,532 # ffffffffc0204aa0 <commands+0x870>
ffffffffc0203894:	0e500593          	li	a1,229
ffffffffc0203898:	00002517          	auipc	a0,0x2
ffffffffc020389c:	06850513          	addi	a0,a0,104 # ffffffffc0205900 <default_pmm_manager+0xac8>
ffffffffc02038a0:	ad5fc0ef          	jal	ra,ffffffffc0200374 <__panic>
        assert(vma1 != NULL);
ffffffffc02038a4:	00002697          	auipc	a3,0x2
ffffffffc02038a8:	19c68693          	addi	a3,a3,412 # ffffffffc0205a40 <default_pmm_manager+0xc08>
ffffffffc02038ac:	00001617          	auipc	a2,0x1
ffffffffc02038b0:	1f460613          	addi	a2,a2,500 # ffffffffc0204aa0 <commands+0x870>
ffffffffc02038b4:	0e300593          	li	a1,227
ffffffffc02038b8:	00002517          	auipc	a0,0x2
ffffffffc02038bc:	04850513          	addi	a0,a0,72 # ffffffffc0205900 <default_pmm_manager+0xac8>
ffffffffc02038c0:	ab5fc0ef          	jal	ra,ffffffffc0200374 <__panic>
        assert(vma5 == NULL);
ffffffffc02038c4:	00002697          	auipc	a3,0x2
ffffffffc02038c8:	1bc68693          	addi	a3,a3,444 # ffffffffc0205a80 <default_pmm_manager+0xc48>
ffffffffc02038cc:	00001617          	auipc	a2,0x1
ffffffffc02038d0:	1d460613          	addi	a2,a2,468 # ffffffffc0204aa0 <commands+0x870>
ffffffffc02038d4:	0eb00593          	li	a1,235
ffffffffc02038d8:	00002517          	auipc	a0,0x2
ffffffffc02038dc:	02850513          	addi	a0,a0,40 # ffffffffc0205900 <default_pmm_manager+0xac8>
ffffffffc02038e0:	a95fc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(mm != NULL);
ffffffffc02038e4:	00002697          	auipc	a3,0x2
ffffffffc02038e8:	c6468693          	addi	a3,a3,-924 # ffffffffc0205548 <default_pmm_manager+0x710>
ffffffffc02038ec:	00001617          	auipc	a2,0x1
ffffffffc02038f0:	1b460613          	addi	a2,a2,436 # ffffffffc0204aa0 <commands+0x870>
ffffffffc02038f4:	0c700593          	li	a1,199
ffffffffc02038f8:	00002517          	auipc	a0,0x2
ffffffffc02038fc:	00850513          	addi	a0,a0,8 # ffffffffc0205900 <default_pmm_manager+0xac8>
ffffffffc0203900:	a75fc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0203904:	00002697          	auipc	a3,0x2
ffffffffc0203908:	22c68693          	addi	a3,a3,556 # ffffffffc0205b30 <default_pmm_manager+0xcf8>
ffffffffc020390c:	00001617          	auipc	a2,0x1
ffffffffc0203910:	19460613          	addi	a2,a2,404 # ffffffffc0204aa0 <commands+0x870>
ffffffffc0203914:	0fb00593          	li	a1,251
ffffffffc0203918:	00002517          	auipc	a0,0x2
ffffffffc020391c:	fe850513          	addi	a0,a0,-24 # ffffffffc0205900 <default_pmm_manager+0xac8>
ffffffffc0203920:	a55fc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0203924:	00002697          	auipc	a3,0x2
ffffffffc0203928:	20c68693          	addi	a3,a3,524 # ffffffffc0205b30 <default_pmm_manager+0xcf8>
ffffffffc020392c:	00001617          	auipc	a2,0x1
ffffffffc0203930:	17460613          	addi	a2,a2,372 # ffffffffc0204aa0 <commands+0x870>
ffffffffc0203934:	12e00593          	li	a1,302
ffffffffc0203938:	00002517          	auipc	a0,0x2
ffffffffc020393c:	fc850513          	addi	a0,a0,-56 # ffffffffc0205900 <default_pmm_manager+0xac8>
ffffffffc0203940:	a35fc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(check_mm_struct != NULL);
ffffffffc0203944:	00002697          	auipc	a3,0x2
ffffffffc0203948:	23468693          	addi	a3,a3,564 # ffffffffc0205b78 <default_pmm_manager+0xd40>
ffffffffc020394c:	00001617          	auipc	a2,0x1
ffffffffc0203950:	15460613          	addi	a2,a2,340 # ffffffffc0204aa0 <commands+0x870>
ffffffffc0203954:	10a00593          	li	a1,266
ffffffffc0203958:	00002517          	auipc	a0,0x2
ffffffffc020395c:	fa850513          	addi	a0,a0,-88 # ffffffffc0205900 <default_pmm_manager+0xac8>
ffffffffc0203960:	a15fc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0203964:	00002697          	auipc	a3,0x2
ffffffffc0203968:	1cc68693          	addi	a3,a3,460 # ffffffffc0205b30 <default_pmm_manager+0xcf8>
ffffffffc020396c:	00001617          	auipc	a2,0x1
ffffffffc0203970:	13460613          	addi	a2,a2,308 # ffffffffc0204aa0 <commands+0x870>
ffffffffc0203974:	0bd00593          	li	a1,189
ffffffffc0203978:	00002517          	auipc	a0,0x2
ffffffffc020397c:	f8850513          	addi	a0,a0,-120 # ffffffffc0205900 <default_pmm_manager+0xac8>
ffffffffc0203980:	9f5fc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(find_vma(mm, addr) == vma);
ffffffffc0203984:	00002697          	auipc	a3,0x2
ffffffffc0203988:	20c68693          	addi	a3,a3,524 # ffffffffc0205b90 <default_pmm_manager+0xd58>
ffffffffc020398c:	00001617          	auipc	a2,0x1
ffffffffc0203990:	11460613          	addi	a2,a2,276 # ffffffffc0204aa0 <commands+0x870>
ffffffffc0203994:	11600593          	li	a1,278
ffffffffc0203998:	00002517          	auipc	a0,0x2
ffffffffc020399c:	f6850513          	addi	a0,a0,-152 # ffffffffc0205900 <default_pmm_manager+0xac8>
ffffffffc02039a0:	9d5fc0ef          	jal	ra,ffffffffc0200374 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02039a4:	00001617          	auipc	a2,0x1
ffffffffc02039a8:	55c60613          	addi	a2,a2,1372 # ffffffffc0204f00 <default_pmm_manager+0xc8>
ffffffffc02039ac:	06500593          	li	a1,101
ffffffffc02039b0:	00001517          	auipc	a0,0x1
ffffffffc02039b4:	57050513          	addi	a0,a0,1392 # ffffffffc0204f20 <default_pmm_manager+0xe8>
ffffffffc02039b8:	9bdfc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(sum == 0);
ffffffffc02039bc:	00002697          	auipc	a3,0x2
ffffffffc02039c0:	1f468693          	addi	a3,a3,500 # ffffffffc0205bb0 <default_pmm_manager+0xd78>
ffffffffc02039c4:	00001617          	auipc	a2,0x1
ffffffffc02039c8:	0dc60613          	addi	a2,a2,220 # ffffffffc0204aa0 <commands+0x870>
ffffffffc02039cc:	12000593          	li	a1,288
ffffffffc02039d0:	00002517          	auipc	a0,0x2
ffffffffc02039d4:	f3050513          	addi	a0,a0,-208 # ffffffffc0205900 <default_pmm_manager+0xac8>
ffffffffc02039d8:	99dfc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgdir[0] == 0);
ffffffffc02039dc:	00002697          	auipc	a3,0x2
ffffffffc02039e0:	b9468693          	addi	a3,a3,-1132 # ffffffffc0205570 <default_pmm_manager+0x738>
ffffffffc02039e4:	00001617          	auipc	a2,0x1
ffffffffc02039e8:	0bc60613          	addi	a2,a2,188 # ffffffffc0204aa0 <commands+0x870>
ffffffffc02039ec:	10d00593          	li	a1,269
ffffffffc02039f0:	00002517          	auipc	a0,0x2
ffffffffc02039f4:	f1050513          	addi	a0,a0,-240 # ffffffffc0205900 <default_pmm_manager+0xac8>
ffffffffc02039f8:	97dfc0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc02039fc <do_pgfault>:
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc02039fc:	1101                	addi	sp,sp,-32
    int ret = -E_INVAL;
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc02039fe:	85b2                	mv	a1,a2
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc0203a00:	e822                	sd	s0,16(sp)
ffffffffc0203a02:	e426                	sd	s1,8(sp)
ffffffffc0203a04:	ec06                	sd	ra,24(sp)
ffffffffc0203a06:	e04a                	sd	s2,0(sp)
ffffffffc0203a08:	8432                	mv	s0,a2
ffffffffc0203a0a:	84aa                	mv	s1,a0
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc0203a0c:	971ff0ef          	jal	ra,ffffffffc020337c <find_vma>

    pgfault_num++;
ffffffffc0203a10:	0000d797          	auipc	a5,0xd
ffffffffc0203a14:	a6478793          	addi	a5,a5,-1436 # ffffffffc0210474 <pgfault_num>
ffffffffc0203a18:	439c                	lw	a5,0(a5)
ffffffffc0203a1a:	2785                	addiw	a5,a5,1
ffffffffc0203a1c:	0000d717          	auipc	a4,0xd
ffffffffc0203a20:	a4f72c23          	sw	a5,-1448(a4) # ffffffffc0210474 <pgfault_num>
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr) {
ffffffffc0203a24:	c939                	beqz	a0,ffffffffc0203a7a <do_pgfault+0x7e>
ffffffffc0203a26:	651c                	ld	a5,8(a0)
ffffffffc0203a28:	04f46963          	bltu	s0,a5,ffffffffc0203a7a <do_pgfault+0x7e>
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
    if (vma->vm_flags & VM_WRITE) {
ffffffffc0203a2c:	6d1c                	ld	a5,24(a0)
    uint32_t perm = PTE_U;
ffffffffc0203a2e:	4941                	li	s2,16
    if (vma->vm_flags & VM_WRITE) {
ffffffffc0203a30:	8b89                	andi	a5,a5,2
ffffffffc0203a32:	e785                	bnez	a5,ffffffffc0203a5a <do_pgfault+0x5e>
        perm |= (PTE_R | PTE_W);
    }
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0203a34:	767d                	lui	a2,0xfffff
    *   mm->pgdir : the PDT of these vma
    *
    */


    ptep = get_pte(mm->pgdir, addr, 1);  //(1) try to find a pte, if pte's
ffffffffc0203a36:	6c88                	ld	a0,24(s1)
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0203a38:	8c71                	and	s0,s0,a2
    ptep = get_pte(mm->pgdir, addr, 1);  //(1) try to find a pte, if pte's
ffffffffc0203a3a:	85a2                	mv	a1,s0
ffffffffc0203a3c:	4605                	li	a2,1
ffffffffc0203a3e:	d3ffd0ef          	jal	ra,ffffffffc020177c <get_pte>
                                         //PT(Page Table) isn't existed, then
                                         //create a PT.
    if (*ptep == 0) {
ffffffffc0203a42:	610c                	ld	a1,0(a0)
ffffffffc0203a44:	cd89                	beqz	a1,ffffffffc0203a5e <do_pgfault+0x62>
        *    swap_in(mm, addr, &page) : 分配一个内存页，然后根据
        *    PTE中的swap条目的addr，找到磁盘页的地址，将磁盘页的内容读入这个内存页
        *    page_insert ： 建立一个Page的phy addr与线性addr la的映射
        *    swap_map_swappable ： 设置页面可交换
        */
        if (swap_init_ok) {
ffffffffc0203a46:	0000d797          	auipc	a5,0xd
ffffffffc0203a4a:	a2a78793          	addi	a5,a5,-1494 # ffffffffc0210470 <swap_init_ok>
ffffffffc0203a4e:	439c                	lw	a5,0(a5)
ffffffffc0203a50:	2781                	sext.w	a5,a5
ffffffffc0203a52:	cf8d                	beqz	a5,ffffffffc0203a8c <do_pgfault+0x90>
            //(2) According to the mm,
            //addr AND page, setup the
            //map of phy addr <--->
            //logical addr
            //(3) make the page swappable.
            page->pra_vaddr = addr;
ffffffffc0203a54:	04003023          	sd	zero,64(zero) # 40 <BASE_ADDRESS-0xffffffffc01fffc0>
ffffffffc0203a58:	9002                	ebreak
        perm |= (PTE_R | PTE_W);
ffffffffc0203a5a:	4959                	li	s2,22
ffffffffc0203a5c:	bfe1                	j	ffffffffc0203a34 <do_pgfault+0x38>
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0203a5e:	6c88                	ld	a0,24(s1)
ffffffffc0203a60:	864a                	mv	a2,s2
ffffffffc0203a62:	85a2                	mv	a1,s0
ffffffffc0203a64:	ba5fe0ef          	jal	ra,ffffffffc0202608 <pgdir_alloc_page>
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
            goto failed;
        }
   }

   ret = 0;
ffffffffc0203a68:	4781                	li	a5,0
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0203a6a:	c90d                	beqz	a0,ffffffffc0203a9c <do_pgfault+0xa0>
failed:
    return ret;
}
ffffffffc0203a6c:	60e2                	ld	ra,24(sp)
ffffffffc0203a6e:	6442                	ld	s0,16(sp)
ffffffffc0203a70:	64a2                	ld	s1,8(sp)
ffffffffc0203a72:	6902                	ld	s2,0(sp)
ffffffffc0203a74:	853e                	mv	a0,a5
ffffffffc0203a76:	6105                	addi	sp,sp,32
ffffffffc0203a78:	8082                	ret
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
ffffffffc0203a7a:	85a2                	mv	a1,s0
ffffffffc0203a7c:	00002517          	auipc	a0,0x2
ffffffffc0203a80:	e9450513          	addi	a0,a0,-364 # ffffffffc0205910 <default_pmm_manager+0xad8>
ffffffffc0203a84:	e3afc0ef          	jal	ra,ffffffffc02000be <cprintf>
    int ret = -E_INVAL;
ffffffffc0203a88:	57f5                	li	a5,-3
        goto failed;
ffffffffc0203a8a:	b7cd                	j	ffffffffc0203a6c <do_pgfault+0x70>
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
ffffffffc0203a8c:	00002517          	auipc	a0,0x2
ffffffffc0203a90:	edc50513          	addi	a0,a0,-292 # ffffffffc0205968 <default_pmm_manager+0xb30>
ffffffffc0203a94:	e2afc0ef          	jal	ra,ffffffffc02000be <cprintf>
    ret = -E_NO_MEM;
ffffffffc0203a98:	57f1                	li	a5,-4
            goto failed;
ffffffffc0203a9a:	bfc9                	j	ffffffffc0203a6c <do_pgfault+0x70>
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
ffffffffc0203a9c:	00002517          	auipc	a0,0x2
ffffffffc0203aa0:	ea450513          	addi	a0,a0,-348 # ffffffffc0205940 <default_pmm_manager+0xb08>
ffffffffc0203aa4:	e1afc0ef          	jal	ra,ffffffffc02000be <cprintf>
    ret = -E_NO_MEM;
ffffffffc0203aa8:	57f1                	li	a5,-4
            goto failed;
ffffffffc0203aaa:	b7c9                	j	ffffffffc0203a6c <do_pgfault+0x70>

ffffffffc0203aac <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {
ffffffffc0203aac:	1141                	addi	sp,sp,-16
    static_assert((PGSIZE % SECTSIZE) == 0);
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0203aae:	4505                	li	a0,1
swapfs_init(void) {
ffffffffc0203ab0:	e406                	sd	ra,8(sp)
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0203ab2:	9edfc0ef          	jal	ra,ffffffffc020049e <ide_device_valid>
ffffffffc0203ab6:	cd01                	beqz	a0,ffffffffc0203ace <swapfs_init+0x22>
        panic("swap fs isn't available.\n");
    }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0203ab8:	4505                	li	a0,1
ffffffffc0203aba:	9ebfc0ef          	jal	ra,ffffffffc02004a4 <ide_device_size>
}
ffffffffc0203abe:	60a2                	ld	ra,8(sp)
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0203ac0:	810d                	srli	a0,a0,0x3
ffffffffc0203ac2:	0000d797          	auipc	a5,0xd
ffffffffc0203ac6:	a6a7bf23          	sd	a0,-1410(a5) # ffffffffc0210540 <max_swap_offset>
}
ffffffffc0203aca:	0141                	addi	sp,sp,16
ffffffffc0203acc:	8082                	ret
        panic("swap fs isn't available.\n");
ffffffffc0203ace:	00002617          	auipc	a2,0x2
ffffffffc0203ad2:	12a60613          	addi	a2,a2,298 # ffffffffc0205bf8 <default_pmm_manager+0xdc0>
ffffffffc0203ad6:	45b5                	li	a1,13
ffffffffc0203ad8:	00002517          	auipc	a0,0x2
ffffffffc0203adc:	14050513          	addi	a0,a0,320 # ffffffffc0205c18 <default_pmm_manager+0xde0>
ffffffffc0203ae0:	895fc0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0203ae4 <swapfs_write>:
swapfs_read(swap_entry_t entry, struct Page *page) {
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
}

int
swapfs_write(swap_entry_t entry, struct Page *page) {
ffffffffc0203ae4:	1141                	addi	sp,sp,-16
ffffffffc0203ae6:	e406                	sd	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203ae8:	00855793          	srli	a5,a0,0x8
ffffffffc0203aec:	c7b5                	beqz	a5,ffffffffc0203b58 <swapfs_write+0x74>
ffffffffc0203aee:	0000d717          	auipc	a4,0xd
ffffffffc0203af2:	a5270713          	addi	a4,a4,-1454 # ffffffffc0210540 <max_swap_offset>
ffffffffc0203af6:	6318                	ld	a4,0(a4)
ffffffffc0203af8:	06e7f063          	bleu	a4,a5,ffffffffc0203b58 <swapfs_write+0x74>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203afc:	0000d717          	auipc	a4,0xd
ffffffffc0203b00:	9b470713          	addi	a4,a4,-1612 # ffffffffc02104b0 <pages>
ffffffffc0203b04:	6310                	ld	a2,0(a4)
ffffffffc0203b06:	00001717          	auipc	a4,0x1
ffffffffc0203b0a:	f8270713          	addi	a4,a4,-126 # ffffffffc0204a88 <commands+0x858>
ffffffffc0203b0e:	00002697          	auipc	a3,0x2
ffffffffc0203b12:	38a68693          	addi	a3,a3,906 # ffffffffc0205e98 <nbase>
ffffffffc0203b16:	40c58633          	sub	a2,a1,a2
ffffffffc0203b1a:	630c                	ld	a1,0(a4)
ffffffffc0203b1c:	860d                	srai	a2,a2,0x3
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203b1e:	0000d717          	auipc	a4,0xd
ffffffffc0203b22:	94270713          	addi	a4,a4,-1726 # ffffffffc0210460 <npage>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203b26:	02b60633          	mul	a2,a2,a1
ffffffffc0203b2a:	0037959b          	slliw	a1,a5,0x3
ffffffffc0203b2e:	629c                	ld	a5,0(a3)
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203b30:	6318                	ld	a4,0(a4)
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203b32:	963e                	add	a2,a2,a5
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203b34:	57fd                	li	a5,-1
ffffffffc0203b36:	83b1                	srli	a5,a5,0xc
ffffffffc0203b38:	8ff1                	and	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0203b3a:	0632                	slli	a2,a2,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203b3c:	02e7fa63          	bleu	a4,a5,ffffffffc0203b70 <swapfs_write+0x8c>
ffffffffc0203b40:	0000d797          	auipc	a5,0xd
ffffffffc0203b44:	96078793          	addi	a5,a5,-1696 # ffffffffc02104a0 <va_pa_offset>
ffffffffc0203b48:	639c                	ld	a5,0(a5)
}
ffffffffc0203b4a:	60a2                	ld	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203b4c:	46a1                	li	a3,8
ffffffffc0203b4e:	963e                	add	a2,a2,a5
ffffffffc0203b50:	4505                	li	a0,1
}
ffffffffc0203b52:	0141                	addi	sp,sp,16
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203b54:	957fc06f          	j	ffffffffc02004aa <ide_write_secs>
ffffffffc0203b58:	86aa                	mv	a3,a0
ffffffffc0203b5a:	00002617          	auipc	a2,0x2
ffffffffc0203b5e:	0d660613          	addi	a2,a2,214 # ffffffffc0205c30 <default_pmm_manager+0xdf8>
ffffffffc0203b62:	45e5                	li	a1,25
ffffffffc0203b64:	00002517          	auipc	a0,0x2
ffffffffc0203b68:	0b450513          	addi	a0,a0,180 # ffffffffc0205c18 <default_pmm_manager+0xde0>
ffffffffc0203b6c:	809fc0ef          	jal	ra,ffffffffc0200374 <__panic>
ffffffffc0203b70:	86b2                	mv	a3,a2
ffffffffc0203b72:	06a00593          	li	a1,106
ffffffffc0203b76:	00001617          	auipc	a2,0x1
ffffffffc0203b7a:	31260613          	addi	a2,a2,786 # ffffffffc0204e88 <default_pmm_manager+0x50>
ffffffffc0203b7e:	00001517          	auipc	a0,0x1
ffffffffc0203b82:	3a250513          	addi	a0,a0,930 # ffffffffc0204f20 <default_pmm_manager+0xe8>
ffffffffc0203b86:	feefc0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0203b8a <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0203b8a:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0203b8e:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0203b90:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0203b94:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0203b96:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0203b9a:	f022                	sd	s0,32(sp)
ffffffffc0203b9c:	ec26                	sd	s1,24(sp)
ffffffffc0203b9e:	e84a                	sd	s2,16(sp)
ffffffffc0203ba0:	f406                	sd	ra,40(sp)
ffffffffc0203ba2:	e44e                	sd	s3,8(sp)
ffffffffc0203ba4:	84aa                	mv	s1,a0
ffffffffc0203ba6:	892e                	mv	s2,a1
ffffffffc0203ba8:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0203bac:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
ffffffffc0203bae:	03067e63          	bleu	a6,a2,ffffffffc0203bea <printnum+0x60>
ffffffffc0203bb2:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0203bb4:	00805763          	blez	s0,ffffffffc0203bc2 <printnum+0x38>
ffffffffc0203bb8:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0203bba:	85ca                	mv	a1,s2
ffffffffc0203bbc:	854e                	mv	a0,s3
ffffffffc0203bbe:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0203bc0:	fc65                	bnez	s0,ffffffffc0203bb8 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0203bc2:	1a02                	slli	s4,s4,0x20
ffffffffc0203bc4:	020a5a13          	srli	s4,s4,0x20
ffffffffc0203bc8:	00002797          	auipc	a5,0x2
ffffffffc0203bcc:	21878793          	addi	a5,a5,536 # ffffffffc0205de0 <error_string+0x38>
ffffffffc0203bd0:	9a3e                	add	s4,s4,a5
}
ffffffffc0203bd2:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0203bd4:	000a4503          	lbu	a0,0(s4)
}
ffffffffc0203bd8:	70a2                	ld	ra,40(sp)
ffffffffc0203bda:	69a2                	ld	s3,8(sp)
ffffffffc0203bdc:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0203bde:	85ca                	mv	a1,s2
ffffffffc0203be0:	8326                	mv	t1,s1
}
ffffffffc0203be2:	6942                	ld	s2,16(sp)
ffffffffc0203be4:	64e2                	ld	s1,24(sp)
ffffffffc0203be6:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0203be8:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0203bea:	03065633          	divu	a2,a2,a6
ffffffffc0203bee:	8722                	mv	a4,s0
ffffffffc0203bf0:	f9bff0ef          	jal	ra,ffffffffc0203b8a <printnum>
ffffffffc0203bf4:	b7f9                	j	ffffffffc0203bc2 <printnum+0x38>

ffffffffc0203bf6 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc0203bf6:	7119                	addi	sp,sp,-128
ffffffffc0203bf8:	f4a6                	sd	s1,104(sp)
ffffffffc0203bfa:	f0ca                	sd	s2,96(sp)
ffffffffc0203bfc:	e8d2                	sd	s4,80(sp)
ffffffffc0203bfe:	e4d6                	sd	s5,72(sp)
ffffffffc0203c00:	e0da                	sd	s6,64(sp)
ffffffffc0203c02:	fc5e                	sd	s7,56(sp)
ffffffffc0203c04:	f862                	sd	s8,48(sp)
ffffffffc0203c06:	f06a                	sd	s10,32(sp)
ffffffffc0203c08:	fc86                	sd	ra,120(sp)
ffffffffc0203c0a:	f8a2                	sd	s0,112(sp)
ffffffffc0203c0c:	ecce                	sd	s3,88(sp)
ffffffffc0203c0e:	f466                	sd	s9,40(sp)
ffffffffc0203c10:	ec6e                	sd	s11,24(sp)
ffffffffc0203c12:	892a                	mv	s2,a0
ffffffffc0203c14:	84ae                	mv	s1,a1
ffffffffc0203c16:	8d32                	mv	s10,a2
ffffffffc0203c18:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc0203c1a:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203c1c:	00002a17          	auipc	s4,0x2
ffffffffc0203c20:	034a0a13          	addi	s4,s4,52 # ffffffffc0205c50 <default_pmm_manager+0xe18>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0203c24:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0203c28:	00002c17          	auipc	s8,0x2
ffffffffc0203c2c:	180c0c13          	addi	s8,s8,384 # ffffffffc0205da8 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0203c30:	000d4503          	lbu	a0,0(s10)
ffffffffc0203c34:	02500793          	li	a5,37
ffffffffc0203c38:	001d0413          	addi	s0,s10,1
ffffffffc0203c3c:	00f50e63          	beq	a0,a5,ffffffffc0203c58 <vprintfmt+0x62>
            if (ch == '\0') {
ffffffffc0203c40:	c521                	beqz	a0,ffffffffc0203c88 <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0203c42:	02500993          	li	s3,37
ffffffffc0203c46:	a011                	j	ffffffffc0203c4a <vprintfmt+0x54>
            if (ch == '\0') {
ffffffffc0203c48:	c121                	beqz	a0,ffffffffc0203c88 <vprintfmt+0x92>
            putch(ch, putdat);
ffffffffc0203c4a:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0203c4c:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc0203c4e:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0203c50:	fff44503          	lbu	a0,-1(s0)
ffffffffc0203c54:	ff351ae3          	bne	a0,s3,ffffffffc0203c48 <vprintfmt+0x52>
ffffffffc0203c58:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc0203c5c:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc0203c60:	4981                	li	s3,0
ffffffffc0203c62:	4801                	li	a6,0
        width = precision = -1;
ffffffffc0203c64:	5cfd                	li	s9,-1
ffffffffc0203c66:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203c68:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
ffffffffc0203c6c:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203c6e:	fdd6069b          	addiw	a3,a2,-35
ffffffffc0203c72:	0ff6f693          	andi	a3,a3,255
ffffffffc0203c76:	00140d13          	addi	s10,s0,1
ffffffffc0203c7a:	20d5e563          	bltu	a1,a3,ffffffffc0203e84 <vprintfmt+0x28e>
ffffffffc0203c7e:	068a                	slli	a3,a3,0x2
ffffffffc0203c80:	96d2                	add	a3,a3,s4
ffffffffc0203c82:	4294                	lw	a3,0(a3)
ffffffffc0203c84:	96d2                	add	a3,a3,s4
ffffffffc0203c86:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0203c88:	70e6                	ld	ra,120(sp)
ffffffffc0203c8a:	7446                	ld	s0,112(sp)
ffffffffc0203c8c:	74a6                	ld	s1,104(sp)
ffffffffc0203c8e:	7906                	ld	s2,96(sp)
ffffffffc0203c90:	69e6                	ld	s3,88(sp)
ffffffffc0203c92:	6a46                	ld	s4,80(sp)
ffffffffc0203c94:	6aa6                	ld	s5,72(sp)
ffffffffc0203c96:	6b06                	ld	s6,64(sp)
ffffffffc0203c98:	7be2                	ld	s7,56(sp)
ffffffffc0203c9a:	7c42                	ld	s8,48(sp)
ffffffffc0203c9c:	7ca2                	ld	s9,40(sp)
ffffffffc0203c9e:	7d02                	ld	s10,32(sp)
ffffffffc0203ca0:	6de2                	ld	s11,24(sp)
ffffffffc0203ca2:	6109                	addi	sp,sp,128
ffffffffc0203ca4:	8082                	ret
    if (lflag >= 2) {
ffffffffc0203ca6:	4705                	li	a4,1
ffffffffc0203ca8:	008a8593          	addi	a1,s5,8
ffffffffc0203cac:	01074463          	blt	a4,a6,ffffffffc0203cb4 <vprintfmt+0xbe>
    else if (lflag) {
ffffffffc0203cb0:	26080363          	beqz	a6,ffffffffc0203f16 <vprintfmt+0x320>
        return va_arg(*ap, unsigned long);
ffffffffc0203cb4:	000ab603          	ld	a2,0(s5)
ffffffffc0203cb8:	46c1                	li	a3,16
ffffffffc0203cba:	8aae                	mv	s5,a1
ffffffffc0203cbc:	a06d                	j	ffffffffc0203d66 <vprintfmt+0x170>
            goto reswitch;
ffffffffc0203cbe:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc0203cc2:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203cc4:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0203cc6:	b765                	j	ffffffffc0203c6e <vprintfmt+0x78>
            putch(va_arg(ap, int), putdat);
ffffffffc0203cc8:	000aa503          	lw	a0,0(s5)
ffffffffc0203ccc:	85a6                	mv	a1,s1
ffffffffc0203cce:	0aa1                	addi	s5,s5,8
ffffffffc0203cd0:	9902                	jalr	s2
            break;
ffffffffc0203cd2:	bfb9                	j	ffffffffc0203c30 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0203cd4:	4705                	li	a4,1
ffffffffc0203cd6:	008a8993          	addi	s3,s5,8
ffffffffc0203cda:	01074463          	blt	a4,a6,ffffffffc0203ce2 <vprintfmt+0xec>
    else if (lflag) {
ffffffffc0203cde:	22080463          	beqz	a6,ffffffffc0203f06 <vprintfmt+0x310>
        return va_arg(*ap, long);
ffffffffc0203ce2:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
ffffffffc0203ce6:	24044463          	bltz	s0,ffffffffc0203f2e <vprintfmt+0x338>
            num = getint(&ap, lflag);
ffffffffc0203cea:	8622                	mv	a2,s0
ffffffffc0203cec:	8ace                	mv	s5,s3
ffffffffc0203cee:	46a9                	li	a3,10
ffffffffc0203cf0:	a89d                	j	ffffffffc0203d66 <vprintfmt+0x170>
            err = va_arg(ap, int);
ffffffffc0203cf2:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0203cf6:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc0203cf8:	0aa1                	addi	s5,s5,8
            if (err < 0) {
ffffffffc0203cfa:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc0203cfe:	8fb5                	xor	a5,a5,a3
ffffffffc0203d00:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0203d04:	1ad74363          	blt	a4,a3,ffffffffc0203eaa <vprintfmt+0x2b4>
ffffffffc0203d08:	00369793          	slli	a5,a3,0x3
ffffffffc0203d0c:	97e2                	add	a5,a5,s8
ffffffffc0203d0e:	639c                	ld	a5,0(a5)
ffffffffc0203d10:	18078d63          	beqz	a5,ffffffffc0203eaa <vprintfmt+0x2b4>
                printfmt(putch, putdat, "%s", p);
ffffffffc0203d14:	86be                	mv	a3,a5
ffffffffc0203d16:	00002617          	auipc	a2,0x2
ffffffffc0203d1a:	17a60613          	addi	a2,a2,378 # ffffffffc0205e90 <error_string+0xe8>
ffffffffc0203d1e:	85a6                	mv	a1,s1
ffffffffc0203d20:	854a                	mv	a0,s2
ffffffffc0203d22:	240000ef          	jal	ra,ffffffffc0203f62 <printfmt>
ffffffffc0203d26:	b729                	j	ffffffffc0203c30 <vprintfmt+0x3a>
            lflag ++;
ffffffffc0203d28:	00144603          	lbu	a2,1(s0)
ffffffffc0203d2c:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203d2e:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0203d30:	bf3d                	j	ffffffffc0203c6e <vprintfmt+0x78>
    if (lflag >= 2) {
ffffffffc0203d32:	4705                	li	a4,1
ffffffffc0203d34:	008a8593          	addi	a1,s5,8
ffffffffc0203d38:	01074463          	blt	a4,a6,ffffffffc0203d40 <vprintfmt+0x14a>
    else if (lflag) {
ffffffffc0203d3c:	1e080263          	beqz	a6,ffffffffc0203f20 <vprintfmt+0x32a>
        return va_arg(*ap, unsigned long);
ffffffffc0203d40:	000ab603          	ld	a2,0(s5)
ffffffffc0203d44:	46a1                	li	a3,8
ffffffffc0203d46:	8aae                	mv	s5,a1
ffffffffc0203d48:	a839                	j	ffffffffc0203d66 <vprintfmt+0x170>
            putch('0', putdat);
ffffffffc0203d4a:	03000513          	li	a0,48
ffffffffc0203d4e:	85a6                	mv	a1,s1
ffffffffc0203d50:	e03e                	sd	a5,0(sp)
ffffffffc0203d52:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc0203d54:	85a6                	mv	a1,s1
ffffffffc0203d56:	07800513          	li	a0,120
ffffffffc0203d5a:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0203d5c:	0aa1                	addi	s5,s5,8
ffffffffc0203d5e:	ff8ab603          	ld	a2,-8(s5)
            goto number;
ffffffffc0203d62:	6782                	ld	a5,0(sp)
ffffffffc0203d64:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
ffffffffc0203d66:	876e                	mv	a4,s11
ffffffffc0203d68:	85a6                	mv	a1,s1
ffffffffc0203d6a:	854a                	mv	a0,s2
ffffffffc0203d6c:	e1fff0ef          	jal	ra,ffffffffc0203b8a <printnum>
            break;
ffffffffc0203d70:	b5c1                	j	ffffffffc0203c30 <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0203d72:	000ab603          	ld	a2,0(s5)
ffffffffc0203d76:	0aa1                	addi	s5,s5,8
ffffffffc0203d78:	1c060663          	beqz	a2,ffffffffc0203f44 <vprintfmt+0x34e>
            if (width > 0 && padc != '-') {
ffffffffc0203d7c:	00160413          	addi	s0,a2,1
ffffffffc0203d80:	17b05c63          	blez	s11,ffffffffc0203ef8 <vprintfmt+0x302>
ffffffffc0203d84:	02d00593          	li	a1,45
ffffffffc0203d88:	14b79263          	bne	a5,a1,ffffffffc0203ecc <vprintfmt+0x2d6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0203d8c:	00064783          	lbu	a5,0(a2)
ffffffffc0203d90:	0007851b          	sext.w	a0,a5
ffffffffc0203d94:	c905                	beqz	a0,ffffffffc0203dc4 <vprintfmt+0x1ce>
ffffffffc0203d96:	000cc563          	bltz	s9,ffffffffc0203da0 <vprintfmt+0x1aa>
ffffffffc0203d9a:	3cfd                	addiw	s9,s9,-1
ffffffffc0203d9c:	036c8263          	beq	s9,s6,ffffffffc0203dc0 <vprintfmt+0x1ca>
                    putch('?', putdat);
ffffffffc0203da0:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0203da2:	18098463          	beqz	s3,ffffffffc0203f2a <vprintfmt+0x334>
ffffffffc0203da6:	3781                	addiw	a5,a5,-32
ffffffffc0203da8:	18fbf163          	bleu	a5,s7,ffffffffc0203f2a <vprintfmt+0x334>
                    putch('?', putdat);
ffffffffc0203dac:	03f00513          	li	a0,63
ffffffffc0203db0:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0203db2:	0405                	addi	s0,s0,1
ffffffffc0203db4:	fff44783          	lbu	a5,-1(s0)
ffffffffc0203db8:	3dfd                	addiw	s11,s11,-1
ffffffffc0203dba:	0007851b          	sext.w	a0,a5
ffffffffc0203dbe:	fd61                	bnez	a0,ffffffffc0203d96 <vprintfmt+0x1a0>
            for (; width > 0; width --) {
ffffffffc0203dc0:	e7b058e3          	blez	s11,ffffffffc0203c30 <vprintfmt+0x3a>
ffffffffc0203dc4:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0203dc6:	85a6                	mv	a1,s1
ffffffffc0203dc8:	02000513          	li	a0,32
ffffffffc0203dcc:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0203dce:	e60d81e3          	beqz	s11,ffffffffc0203c30 <vprintfmt+0x3a>
ffffffffc0203dd2:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0203dd4:	85a6                	mv	a1,s1
ffffffffc0203dd6:	02000513          	li	a0,32
ffffffffc0203dda:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0203ddc:	fe0d94e3          	bnez	s11,ffffffffc0203dc4 <vprintfmt+0x1ce>
ffffffffc0203de0:	bd81                	j	ffffffffc0203c30 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0203de2:	4705                	li	a4,1
ffffffffc0203de4:	008a8593          	addi	a1,s5,8
ffffffffc0203de8:	01074463          	blt	a4,a6,ffffffffc0203df0 <vprintfmt+0x1fa>
    else if (lflag) {
ffffffffc0203dec:	12080063          	beqz	a6,ffffffffc0203f0c <vprintfmt+0x316>
        return va_arg(*ap, unsigned long);
ffffffffc0203df0:	000ab603          	ld	a2,0(s5)
ffffffffc0203df4:	46a9                	li	a3,10
ffffffffc0203df6:	8aae                	mv	s5,a1
ffffffffc0203df8:	b7bd                	j	ffffffffc0203d66 <vprintfmt+0x170>
ffffffffc0203dfa:	00144603          	lbu	a2,1(s0)
            padc = '-';
ffffffffc0203dfe:	02d00793          	li	a5,45
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203e02:	846a                	mv	s0,s10
ffffffffc0203e04:	b5ad                	j	ffffffffc0203c6e <vprintfmt+0x78>
            putch(ch, putdat);
ffffffffc0203e06:	85a6                	mv	a1,s1
ffffffffc0203e08:	02500513          	li	a0,37
ffffffffc0203e0c:	9902                	jalr	s2
            break;
ffffffffc0203e0e:	b50d                	j	ffffffffc0203c30 <vprintfmt+0x3a>
            precision = va_arg(ap, int);
ffffffffc0203e10:	000aac83          	lw	s9,0(s5)
            goto process_precision;
ffffffffc0203e14:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc0203e18:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203e1a:	846a                	mv	s0,s10
            if (width < 0)
ffffffffc0203e1c:	e40dd9e3          	bgez	s11,ffffffffc0203c6e <vprintfmt+0x78>
                width = precision, precision = -1;
ffffffffc0203e20:	8de6                	mv	s11,s9
ffffffffc0203e22:	5cfd                	li	s9,-1
ffffffffc0203e24:	b5a9                	j	ffffffffc0203c6e <vprintfmt+0x78>
            goto reswitch;
ffffffffc0203e26:	00144603          	lbu	a2,1(s0)
            padc = '0';
ffffffffc0203e2a:	03000793          	li	a5,48
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203e2e:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0203e30:	bd3d                	j	ffffffffc0203c6e <vprintfmt+0x78>
                precision = precision * 10 + ch - '0';
ffffffffc0203e32:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
ffffffffc0203e36:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203e3a:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc0203e3c:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc0203e40:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc0203e44:	fcd56ce3          	bltu	a0,a3,ffffffffc0203e1c <vprintfmt+0x226>
            for (precision = 0; ; ++ fmt) {
ffffffffc0203e48:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0203e4a:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
ffffffffc0203e4e:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
ffffffffc0203e52:	0196873b          	addw	a4,a3,s9
ffffffffc0203e56:	0017171b          	slliw	a4,a4,0x1
ffffffffc0203e5a:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
ffffffffc0203e5e:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
ffffffffc0203e62:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
ffffffffc0203e66:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc0203e6a:	fcd57fe3          	bleu	a3,a0,ffffffffc0203e48 <vprintfmt+0x252>
ffffffffc0203e6e:	b77d                	j	ffffffffc0203e1c <vprintfmt+0x226>
            if (width < 0)
ffffffffc0203e70:	fffdc693          	not	a3,s11
ffffffffc0203e74:	96fd                	srai	a3,a3,0x3f
ffffffffc0203e76:	00ddfdb3          	and	s11,s11,a3
ffffffffc0203e7a:	00144603          	lbu	a2,1(s0)
ffffffffc0203e7e:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203e80:	846a                	mv	s0,s10
ffffffffc0203e82:	b3f5                	j	ffffffffc0203c6e <vprintfmt+0x78>
            putch('%', putdat);
ffffffffc0203e84:	85a6                	mv	a1,s1
ffffffffc0203e86:	02500513          	li	a0,37
ffffffffc0203e8a:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc0203e8c:	fff44703          	lbu	a4,-1(s0)
ffffffffc0203e90:	02500793          	li	a5,37
ffffffffc0203e94:	8d22                	mv	s10,s0
ffffffffc0203e96:	d8f70de3          	beq	a4,a5,ffffffffc0203c30 <vprintfmt+0x3a>
ffffffffc0203e9a:	02500713          	li	a4,37
ffffffffc0203e9e:	1d7d                	addi	s10,s10,-1
ffffffffc0203ea0:	fffd4783          	lbu	a5,-1(s10)
ffffffffc0203ea4:	fee79de3          	bne	a5,a4,ffffffffc0203e9e <vprintfmt+0x2a8>
ffffffffc0203ea8:	b361                	j	ffffffffc0203c30 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc0203eaa:	00002617          	auipc	a2,0x2
ffffffffc0203eae:	fd660613          	addi	a2,a2,-42 # ffffffffc0205e80 <error_string+0xd8>
ffffffffc0203eb2:	85a6                	mv	a1,s1
ffffffffc0203eb4:	854a                	mv	a0,s2
ffffffffc0203eb6:	0ac000ef          	jal	ra,ffffffffc0203f62 <printfmt>
ffffffffc0203eba:	bb9d                	j	ffffffffc0203c30 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc0203ebc:	00002617          	auipc	a2,0x2
ffffffffc0203ec0:	fbc60613          	addi	a2,a2,-68 # ffffffffc0205e78 <error_string+0xd0>
            if (width > 0 && padc != '-') {
ffffffffc0203ec4:	00002417          	auipc	s0,0x2
ffffffffc0203ec8:	fb540413          	addi	s0,s0,-75 # ffffffffc0205e79 <error_string+0xd1>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0203ecc:	8532                	mv	a0,a2
ffffffffc0203ece:	85e6                	mv	a1,s9
ffffffffc0203ed0:	e032                	sd	a2,0(sp)
ffffffffc0203ed2:	e43e                	sd	a5,8(sp)
ffffffffc0203ed4:	18a000ef          	jal	ra,ffffffffc020405e <strnlen>
ffffffffc0203ed8:	40ad8dbb          	subw	s11,s11,a0
ffffffffc0203edc:	6602                	ld	a2,0(sp)
ffffffffc0203ede:	01b05d63          	blez	s11,ffffffffc0203ef8 <vprintfmt+0x302>
ffffffffc0203ee2:	67a2                	ld	a5,8(sp)
ffffffffc0203ee4:	2781                	sext.w	a5,a5
ffffffffc0203ee6:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
ffffffffc0203ee8:	6522                	ld	a0,8(sp)
ffffffffc0203eea:	85a6                	mv	a1,s1
ffffffffc0203eec:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0203eee:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc0203ef0:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0203ef2:	6602                	ld	a2,0(sp)
ffffffffc0203ef4:	fe0d9ae3          	bnez	s11,ffffffffc0203ee8 <vprintfmt+0x2f2>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0203ef8:	00064783          	lbu	a5,0(a2)
ffffffffc0203efc:	0007851b          	sext.w	a0,a5
ffffffffc0203f00:	e8051be3          	bnez	a0,ffffffffc0203d96 <vprintfmt+0x1a0>
ffffffffc0203f04:	b335                	j	ffffffffc0203c30 <vprintfmt+0x3a>
        return va_arg(*ap, int);
ffffffffc0203f06:	000aa403          	lw	s0,0(s5)
ffffffffc0203f0a:	bbf1                	j	ffffffffc0203ce6 <vprintfmt+0xf0>
        return va_arg(*ap, unsigned int);
ffffffffc0203f0c:	000ae603          	lwu	a2,0(s5)
ffffffffc0203f10:	46a9                	li	a3,10
ffffffffc0203f12:	8aae                	mv	s5,a1
ffffffffc0203f14:	bd89                	j	ffffffffc0203d66 <vprintfmt+0x170>
ffffffffc0203f16:	000ae603          	lwu	a2,0(s5)
ffffffffc0203f1a:	46c1                	li	a3,16
ffffffffc0203f1c:	8aae                	mv	s5,a1
ffffffffc0203f1e:	b5a1                	j	ffffffffc0203d66 <vprintfmt+0x170>
ffffffffc0203f20:	000ae603          	lwu	a2,0(s5)
ffffffffc0203f24:	46a1                	li	a3,8
ffffffffc0203f26:	8aae                	mv	s5,a1
ffffffffc0203f28:	bd3d                	j	ffffffffc0203d66 <vprintfmt+0x170>
                    putch(ch, putdat);
ffffffffc0203f2a:	9902                	jalr	s2
ffffffffc0203f2c:	b559                	j	ffffffffc0203db2 <vprintfmt+0x1bc>
                putch('-', putdat);
ffffffffc0203f2e:	85a6                	mv	a1,s1
ffffffffc0203f30:	02d00513          	li	a0,45
ffffffffc0203f34:	e03e                	sd	a5,0(sp)
ffffffffc0203f36:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc0203f38:	8ace                	mv	s5,s3
ffffffffc0203f3a:	40800633          	neg	a2,s0
ffffffffc0203f3e:	46a9                	li	a3,10
ffffffffc0203f40:	6782                	ld	a5,0(sp)
ffffffffc0203f42:	b515                	j	ffffffffc0203d66 <vprintfmt+0x170>
            if (width > 0 && padc != '-') {
ffffffffc0203f44:	01b05663          	blez	s11,ffffffffc0203f50 <vprintfmt+0x35a>
ffffffffc0203f48:	02d00693          	li	a3,45
ffffffffc0203f4c:	f6d798e3          	bne	a5,a3,ffffffffc0203ebc <vprintfmt+0x2c6>
ffffffffc0203f50:	00002417          	auipc	s0,0x2
ffffffffc0203f54:	f2940413          	addi	s0,s0,-215 # ffffffffc0205e79 <error_string+0xd1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0203f58:	02800513          	li	a0,40
ffffffffc0203f5c:	02800793          	li	a5,40
ffffffffc0203f60:	bd1d                	j	ffffffffc0203d96 <vprintfmt+0x1a0>

ffffffffc0203f62 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0203f62:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc0203f64:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0203f68:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0203f6a:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0203f6c:	ec06                	sd	ra,24(sp)
ffffffffc0203f6e:	f83a                	sd	a4,48(sp)
ffffffffc0203f70:	fc3e                	sd	a5,56(sp)
ffffffffc0203f72:	e0c2                	sd	a6,64(sp)
ffffffffc0203f74:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0203f76:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0203f78:	c7fff0ef          	jal	ra,ffffffffc0203bf6 <vprintfmt>
}
ffffffffc0203f7c:	60e2                	ld	ra,24(sp)
ffffffffc0203f7e:	6161                	addi	sp,sp,80
ffffffffc0203f80:	8082                	ret

ffffffffc0203f82 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc0203f82:	715d                	addi	sp,sp,-80
ffffffffc0203f84:	e486                	sd	ra,72(sp)
ffffffffc0203f86:	e0a2                	sd	s0,64(sp)
ffffffffc0203f88:	fc26                	sd	s1,56(sp)
ffffffffc0203f8a:	f84a                	sd	s2,48(sp)
ffffffffc0203f8c:	f44e                	sd	s3,40(sp)
ffffffffc0203f8e:	f052                	sd	s4,32(sp)
ffffffffc0203f90:	ec56                	sd	s5,24(sp)
ffffffffc0203f92:	e85a                	sd	s6,16(sp)
ffffffffc0203f94:	e45e                	sd	s7,8(sp)
    if (prompt != NULL) {
ffffffffc0203f96:	c901                	beqz	a0,ffffffffc0203fa6 <readline+0x24>
        cprintf("%s", prompt);
ffffffffc0203f98:	85aa                	mv	a1,a0
ffffffffc0203f9a:	00002517          	auipc	a0,0x2
ffffffffc0203f9e:	ef650513          	addi	a0,a0,-266 # ffffffffc0205e90 <error_string+0xe8>
ffffffffc0203fa2:	91cfc0ef          	jal	ra,ffffffffc02000be <cprintf>
readline(const char *prompt) {
ffffffffc0203fa6:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0203fa8:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc0203faa:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc0203fac:	4aa9                	li	s5,10
ffffffffc0203fae:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc0203fb0:	0000cb97          	auipc	s7,0xc
ffffffffc0203fb4:	090b8b93          	addi	s7,s7,144 # ffffffffc0210040 <buf>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0203fb8:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc0203fbc:	93afc0ef          	jal	ra,ffffffffc02000f6 <getchar>
ffffffffc0203fc0:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc0203fc2:	00054b63          	bltz	a0,ffffffffc0203fd8 <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0203fc6:	00a95b63          	ble	a0,s2,ffffffffc0203fdc <readline+0x5a>
ffffffffc0203fca:	029a5463          	ble	s1,s4,ffffffffc0203ff2 <readline+0x70>
        c = getchar();
ffffffffc0203fce:	928fc0ef          	jal	ra,ffffffffc02000f6 <getchar>
ffffffffc0203fd2:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc0203fd4:	fe0559e3          	bgez	a0,ffffffffc0203fc6 <readline+0x44>
            return NULL;
ffffffffc0203fd8:	4501                	li	a0,0
ffffffffc0203fda:	a099                	j	ffffffffc0204020 <readline+0x9e>
        else if (c == '\b' && i > 0) {
ffffffffc0203fdc:	03341463          	bne	s0,s3,ffffffffc0204004 <readline+0x82>
ffffffffc0203fe0:	e8b9                	bnez	s1,ffffffffc0204036 <readline+0xb4>
        c = getchar();
ffffffffc0203fe2:	914fc0ef          	jal	ra,ffffffffc02000f6 <getchar>
ffffffffc0203fe6:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc0203fe8:	fe0548e3          	bltz	a0,ffffffffc0203fd8 <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0203fec:	fea958e3          	ble	a0,s2,ffffffffc0203fdc <readline+0x5a>
ffffffffc0203ff0:	4481                	li	s1,0
            cputchar(c);
ffffffffc0203ff2:	8522                	mv	a0,s0
ffffffffc0203ff4:	8fefc0ef          	jal	ra,ffffffffc02000f2 <cputchar>
            buf[i ++] = c;
ffffffffc0203ff8:	009b87b3          	add	a5,s7,s1
ffffffffc0203ffc:	00878023          	sb	s0,0(a5)
ffffffffc0204000:	2485                	addiw	s1,s1,1
ffffffffc0204002:	bf6d                	j	ffffffffc0203fbc <readline+0x3a>
        else if (c == '\n' || c == '\r') {
ffffffffc0204004:	01540463          	beq	s0,s5,ffffffffc020400c <readline+0x8a>
ffffffffc0204008:	fb641ae3          	bne	s0,s6,ffffffffc0203fbc <readline+0x3a>
            cputchar(c);
ffffffffc020400c:	8522                	mv	a0,s0
ffffffffc020400e:	8e4fc0ef          	jal	ra,ffffffffc02000f2 <cputchar>
            buf[i] = '\0';
ffffffffc0204012:	0000c517          	auipc	a0,0xc
ffffffffc0204016:	02e50513          	addi	a0,a0,46 # ffffffffc0210040 <buf>
ffffffffc020401a:	94aa                	add	s1,s1,a0
ffffffffc020401c:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc0204020:	60a6                	ld	ra,72(sp)
ffffffffc0204022:	6406                	ld	s0,64(sp)
ffffffffc0204024:	74e2                	ld	s1,56(sp)
ffffffffc0204026:	7942                	ld	s2,48(sp)
ffffffffc0204028:	79a2                	ld	s3,40(sp)
ffffffffc020402a:	7a02                	ld	s4,32(sp)
ffffffffc020402c:	6ae2                	ld	s5,24(sp)
ffffffffc020402e:	6b42                	ld	s6,16(sp)
ffffffffc0204030:	6ba2                	ld	s7,8(sp)
ffffffffc0204032:	6161                	addi	sp,sp,80
ffffffffc0204034:	8082                	ret
            cputchar(c);
ffffffffc0204036:	4521                	li	a0,8
ffffffffc0204038:	8bafc0ef          	jal	ra,ffffffffc02000f2 <cputchar>
            i --;
ffffffffc020403c:	34fd                	addiw	s1,s1,-1
ffffffffc020403e:	bfbd                	j	ffffffffc0203fbc <readline+0x3a>

ffffffffc0204040 <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc0204040:	00054783          	lbu	a5,0(a0)
ffffffffc0204044:	cb91                	beqz	a5,ffffffffc0204058 <strlen+0x18>
    size_t cnt = 0;
ffffffffc0204046:	4781                	li	a5,0
        cnt ++;
ffffffffc0204048:	0785                	addi	a5,a5,1
    while (*s ++ != '\0') {
ffffffffc020404a:	00f50733          	add	a4,a0,a5
ffffffffc020404e:	00074703          	lbu	a4,0(a4)
ffffffffc0204052:	fb7d                	bnez	a4,ffffffffc0204048 <strlen+0x8>
    }
    return cnt;
}
ffffffffc0204054:	853e                	mv	a0,a5
ffffffffc0204056:	8082                	ret
    size_t cnt = 0;
ffffffffc0204058:	4781                	li	a5,0
}
ffffffffc020405a:	853e                	mv	a0,a5
ffffffffc020405c:	8082                	ret

ffffffffc020405e <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
ffffffffc020405e:	c185                	beqz	a1,ffffffffc020407e <strnlen+0x20>
ffffffffc0204060:	00054783          	lbu	a5,0(a0)
ffffffffc0204064:	cf89                	beqz	a5,ffffffffc020407e <strnlen+0x20>
    size_t cnt = 0;
ffffffffc0204066:	4781                	li	a5,0
ffffffffc0204068:	a021                	j	ffffffffc0204070 <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
ffffffffc020406a:	00074703          	lbu	a4,0(a4)
ffffffffc020406e:	c711                	beqz	a4,ffffffffc020407a <strnlen+0x1c>
        cnt ++;
ffffffffc0204070:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0204072:	00f50733          	add	a4,a0,a5
ffffffffc0204076:	fef59ae3          	bne	a1,a5,ffffffffc020406a <strnlen+0xc>
    }
    return cnt;
}
ffffffffc020407a:	853e                	mv	a0,a5
ffffffffc020407c:	8082                	ret
    size_t cnt = 0;
ffffffffc020407e:	4781                	li	a5,0
}
ffffffffc0204080:	853e                	mv	a0,a5
ffffffffc0204082:	8082                	ret

ffffffffc0204084 <strcpy>:
char *
strcpy(char *dst, const char *src) {
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
#else
    char *p = dst;
ffffffffc0204084:	87aa                	mv	a5,a0
    while ((*p ++ = *src ++) != '\0')
ffffffffc0204086:	0585                	addi	a1,a1,1
ffffffffc0204088:	fff5c703          	lbu	a4,-1(a1)
ffffffffc020408c:	0785                	addi	a5,a5,1
ffffffffc020408e:	fee78fa3          	sb	a4,-1(a5)
ffffffffc0204092:	fb75                	bnez	a4,ffffffffc0204086 <strcpy+0x2>
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
ffffffffc0204094:	8082                	ret

ffffffffc0204096 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0204096:	00054783          	lbu	a5,0(a0)
ffffffffc020409a:	0005c703          	lbu	a4,0(a1)
ffffffffc020409e:	cb91                	beqz	a5,ffffffffc02040b2 <strcmp+0x1c>
ffffffffc02040a0:	00e79c63          	bne	a5,a4,ffffffffc02040b8 <strcmp+0x22>
        s1 ++, s2 ++;
ffffffffc02040a4:	0505                	addi	a0,a0,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02040a6:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
ffffffffc02040aa:	0585                	addi	a1,a1,1
ffffffffc02040ac:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02040b0:	fbe5                	bnez	a5,ffffffffc02040a0 <strcmp+0xa>
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc02040b2:	4501                	li	a0,0
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc02040b4:	9d19                	subw	a0,a0,a4
ffffffffc02040b6:	8082                	ret
ffffffffc02040b8:	0007851b          	sext.w	a0,a5
ffffffffc02040bc:	9d19                	subw	a0,a0,a4
ffffffffc02040be:	8082                	ret

ffffffffc02040c0 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc02040c0:	00054783          	lbu	a5,0(a0)
ffffffffc02040c4:	cb91                	beqz	a5,ffffffffc02040d8 <strchr+0x18>
        if (*s == c) {
ffffffffc02040c6:	00b79563          	bne	a5,a1,ffffffffc02040d0 <strchr+0x10>
ffffffffc02040ca:	a809                	j	ffffffffc02040dc <strchr+0x1c>
ffffffffc02040cc:	00b78763          	beq	a5,a1,ffffffffc02040da <strchr+0x1a>
            return (char *)s;
        }
        s ++;
ffffffffc02040d0:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc02040d2:	00054783          	lbu	a5,0(a0)
ffffffffc02040d6:	fbfd                	bnez	a5,ffffffffc02040cc <strchr+0xc>
    }
    return NULL;
ffffffffc02040d8:	4501                	li	a0,0
}
ffffffffc02040da:	8082                	ret
ffffffffc02040dc:	8082                	ret

ffffffffc02040de <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc02040de:	ca01                	beqz	a2,ffffffffc02040ee <memset+0x10>
ffffffffc02040e0:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc02040e2:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc02040e4:	0785                	addi	a5,a5,1
ffffffffc02040e6:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc02040ea:	fec79de3          	bne	a5,a2,ffffffffc02040e4 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc02040ee:	8082                	ret

ffffffffc02040f0 <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc02040f0:	ca19                	beqz	a2,ffffffffc0204106 <memcpy+0x16>
ffffffffc02040f2:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc02040f4:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc02040f6:	0585                	addi	a1,a1,1
ffffffffc02040f8:	fff5c703          	lbu	a4,-1(a1)
ffffffffc02040fc:	0785                	addi	a5,a5,1
ffffffffc02040fe:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc0204102:	fec59ae3          	bne	a1,a2,ffffffffc02040f6 <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc0204106:	8082                	ret
