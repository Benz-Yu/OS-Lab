
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200000:	c02092b7          	lui	t0,0xc0209
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
ffffffffc0200028:	c0209137          	lui	sp,0xc0209

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
ffffffffc0200036:	0000a517          	auipc	a0,0xa
ffffffffc020003a:	00a50513          	addi	a0,a0,10 # ffffffffc020a040 <edata>
ffffffffc020003e:	00011617          	auipc	a2,0x11
ffffffffc0200042:	56260613          	addi	a2,a2,1378 # ffffffffc02115a0 <end>
kern_init(void) {
ffffffffc0200046:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200048:	8e09                	sub	a2,a2,a0
ffffffffc020004a:	4581                	li	a1,0
kern_init(void) {
ffffffffc020004c:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004e:	2a6040ef          	jal	ra,ffffffffc02042f4 <memset>

    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);
ffffffffc0200052:	00004597          	auipc	a1,0x4
ffffffffc0200056:	2ce58593          	addi	a1,a1,718 # ffffffffc0204320 <etext+0x2>
ffffffffc020005a:	00004517          	auipc	a0,0x4
ffffffffc020005e:	2e650513          	addi	a0,a0,742 # ffffffffc0204340 <etext+0x22>
ffffffffc0200062:	05c000ef          	jal	ra,ffffffffc02000be <cprintf>

    print_kerninfo();
ffffffffc0200066:	0a0000ef          	jal	ra,ffffffffc0200106 <print_kerninfo>

    // grade_backtrace();

    pmm_init();                 // init physical memory management
ffffffffc020006a:	2dd010ef          	jal	ra,ffffffffc0201b46 <pmm_init>

    idt_init();                 // init interrupt descriptor table
ffffffffc020006e:	504000ef          	jal	ra,ffffffffc0200572 <idt_init>

    vmm_init();                 // init virtual memory management
ffffffffc0200072:	576030ef          	jal	ra,ffffffffc02035e8 <vmm_init>

    ide_init();                 // init ide devices
ffffffffc0200076:	426000ef          	jal	ra,ffffffffc020049c <ide_init>
    swap_init();                // init swap
ffffffffc020007a:	7c2020ef          	jal	ra,ffffffffc020283c <swap_init>

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
ffffffffc02000b2:	55b030ef          	jal	ra,ffffffffc0203e0c <vprintfmt>
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
ffffffffc02000c0:	02810313          	addi	t1,sp,40 # ffffffffc0209028 <boot_page_table_sv39+0x28>
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
ffffffffc02000e6:	527030ef          	jal	ra,ffffffffc0203e0c <vprintfmt>
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
ffffffffc020010c:	27050513          	addi	a0,a0,624 # ffffffffc0204378 <etext+0x5a>
void print_kerninfo(void) {
ffffffffc0200110:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc0200112:	fadff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  entry  0x%08x (virtual)\n", kern_init);
ffffffffc0200116:	00000597          	auipc	a1,0x0
ffffffffc020011a:	f2058593          	addi	a1,a1,-224 # ffffffffc0200036 <kern_init>
ffffffffc020011e:	00004517          	auipc	a0,0x4
ffffffffc0200122:	27a50513          	addi	a0,a0,634 # ffffffffc0204398 <etext+0x7a>
ffffffffc0200126:	f99ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  etext  0x%08x (virtual)\n", etext);
ffffffffc020012a:	00004597          	auipc	a1,0x4
ffffffffc020012e:	1f458593          	addi	a1,a1,500 # ffffffffc020431e <etext>
ffffffffc0200132:	00004517          	auipc	a0,0x4
ffffffffc0200136:	28650513          	addi	a0,a0,646 # ffffffffc02043b8 <etext+0x9a>
ffffffffc020013a:	f85ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  edata  0x%08x (virtual)\n", edata);
ffffffffc020013e:	0000a597          	auipc	a1,0xa
ffffffffc0200142:	f0258593          	addi	a1,a1,-254 # ffffffffc020a040 <edata>
ffffffffc0200146:	00004517          	auipc	a0,0x4
ffffffffc020014a:	29250513          	addi	a0,a0,658 # ffffffffc02043d8 <etext+0xba>
ffffffffc020014e:	f71ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  end    0x%08x (virtual)\n", end);
ffffffffc0200152:	00011597          	auipc	a1,0x11
ffffffffc0200156:	44e58593          	addi	a1,a1,1102 # ffffffffc02115a0 <end>
ffffffffc020015a:	00004517          	auipc	a0,0x4
ffffffffc020015e:	29e50513          	addi	a0,a0,670 # ffffffffc02043f8 <etext+0xda>
ffffffffc0200162:	f5dff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc0200166:	00012597          	auipc	a1,0x12
ffffffffc020016a:	83958593          	addi	a1,a1,-1991 # ffffffffc021199f <end+0x3ff>
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
ffffffffc020018c:	29050513          	addi	a0,a0,656 # ffffffffc0204418 <etext+0xfa>
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
ffffffffc020019c:	1b060613          	addi	a2,a2,432 # ffffffffc0204348 <etext+0x2a>
ffffffffc02001a0:	04e00593          	li	a1,78
ffffffffc02001a4:	00004517          	auipc	a0,0x4
ffffffffc02001a8:	1bc50513          	addi	a0,a0,444 # ffffffffc0204360 <etext+0x42>
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
ffffffffc02001b8:	36c60613          	addi	a2,a2,876 # ffffffffc0204520 <commands+0xd8>
ffffffffc02001bc:	00004597          	auipc	a1,0x4
ffffffffc02001c0:	38458593          	addi	a1,a1,900 # ffffffffc0204540 <commands+0xf8>
ffffffffc02001c4:	00004517          	auipc	a0,0x4
ffffffffc02001c8:	38450513          	addi	a0,a0,900 # ffffffffc0204548 <commands+0x100>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02001cc:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02001ce:	ef1ff0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc02001d2:	00004617          	auipc	a2,0x4
ffffffffc02001d6:	38660613          	addi	a2,a2,902 # ffffffffc0204558 <commands+0x110>
ffffffffc02001da:	00004597          	auipc	a1,0x4
ffffffffc02001de:	3a658593          	addi	a1,a1,934 # ffffffffc0204580 <commands+0x138>
ffffffffc02001e2:	00004517          	auipc	a0,0x4
ffffffffc02001e6:	36650513          	addi	a0,a0,870 # ffffffffc0204548 <commands+0x100>
ffffffffc02001ea:	ed5ff0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc02001ee:	00004617          	auipc	a2,0x4
ffffffffc02001f2:	3a260613          	addi	a2,a2,930 # ffffffffc0204590 <commands+0x148>
ffffffffc02001f6:	00004597          	auipc	a1,0x4
ffffffffc02001fa:	3ba58593          	addi	a1,a1,954 # ffffffffc02045b0 <commands+0x168>
ffffffffc02001fe:	00004517          	auipc	a0,0x4
ffffffffc0200202:	34a50513          	addi	a0,a0,842 # ffffffffc0204548 <commands+0x100>
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
ffffffffc020023c:	25850513          	addi	a0,a0,600 # ffffffffc0204490 <commands+0x48>
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
ffffffffc020025e:	25e50513          	addi	a0,a0,606 # ffffffffc02044b8 <commands+0x70>
ffffffffc0200262:	e5dff0ef          	jal	ra,ffffffffc02000be <cprintf>
    if (tf != NULL) {
ffffffffc0200266:	000c0563          	beqz	s8,ffffffffc0200270 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc020026a:	8562                	mv	a0,s8
ffffffffc020026c:	4f2000ef          	jal	ra,ffffffffc020075e <print_trapframe>
ffffffffc0200270:	00004c97          	auipc	s9,0x4
ffffffffc0200274:	1d8c8c93          	addi	s9,s9,472 # ffffffffc0204448 <commands>
        if ((buf = readline("")) != NULL) {
ffffffffc0200278:	00005997          	auipc	s3,0x5
ffffffffc020027c:	76898993          	addi	s3,s3,1896 # ffffffffc02059e0 <default_pmm_manager+0x990>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200280:	00004917          	auipc	s2,0x4
ffffffffc0200284:	26090913          	addi	s2,s2,608 # ffffffffc02044e0 <commands+0x98>
        if (argc == MAXARGS - 1) {
ffffffffc0200288:	4a3d                	li	s4,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc020028a:	00004b17          	auipc	s6,0x4
ffffffffc020028e:	25eb0b13          	addi	s6,s6,606 # ffffffffc02044e8 <commands+0xa0>
    if (argc == 0) {
ffffffffc0200292:	00004a97          	auipc	s5,0x4
ffffffffc0200296:	2aea8a93          	addi	s5,s5,686 # ffffffffc0204540 <commands+0xf8>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc020029a:	4b8d                	li	s7,3
        if ((buf = readline("")) != NULL) {
ffffffffc020029c:	854e                	mv	a0,s3
ffffffffc020029e:	6fb030ef          	jal	ra,ffffffffc0204198 <readline>
ffffffffc02002a2:	842a                	mv	s0,a0
ffffffffc02002a4:	dd65                	beqz	a0,ffffffffc020029c <kmonitor+0x6a>
ffffffffc02002a6:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc02002aa:	4481                	li	s1,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002ac:	c999                	beqz	a1,ffffffffc02002c2 <kmonitor+0x90>
ffffffffc02002ae:	854a                	mv	a0,s2
ffffffffc02002b0:	026040ef          	jal	ra,ffffffffc02042d6 <strchr>
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
ffffffffc02002ca:	182d0d13          	addi	s10,s10,386 # ffffffffc0204448 <commands>
    if (argc == 0) {
ffffffffc02002ce:	8556                	mv	a0,s5
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002d0:	4401                	li	s0,0
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002d2:	0d61                	addi	s10,s10,24
ffffffffc02002d4:	7d9030ef          	jal	ra,ffffffffc02042ac <strcmp>
ffffffffc02002d8:	c919                	beqz	a0,ffffffffc02002ee <kmonitor+0xbc>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002da:	2405                	addiw	s0,s0,1
ffffffffc02002dc:	09740463          	beq	s0,s7,ffffffffc0200364 <kmonitor+0x132>
ffffffffc02002e0:	000d3503          	ld	a0,0(s10)
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002e4:	6582                	ld	a1,0(sp)
ffffffffc02002e6:	0d61                	addi	s10,s10,24
ffffffffc02002e8:	7c5030ef          	jal	ra,ffffffffc02042ac <strcmp>
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
ffffffffc020034e:	789030ef          	jal	ra,ffffffffc02042d6 <strchr>
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
ffffffffc020036a:	1a250513          	addi	a0,a0,418 # ffffffffc0204508 <commands+0xc0>
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
ffffffffc0200374:	00011317          	auipc	t1,0x11
ffffffffc0200378:	0cc30313          	addi	t1,t1,204 # ffffffffc0211440 <is_panic>
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
ffffffffc0200398:	00011717          	auipc	a4,0x11
ffffffffc020039c:	0af72423          	sw	a5,168(a4) # ffffffffc0211440 <is_panic>

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
ffffffffc02003aa:	21a50513          	addi	a0,a0,538 # ffffffffc02045c0 <commands+0x178>
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
ffffffffc02003c0:	17c50513          	addi	a0,a0,380 # ffffffffc0205538 <default_pmm_manager+0x4e8>
ffffffffc02003c4:	cfbff0ef          	jal	ra,ffffffffc02000be <cprintf>
    va_end(ap);

panic_dead:
    intr_disable();
ffffffffc02003c8:	132000ef          	jal	ra,ffffffffc02004fa <intr_disable>
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
ffffffffc02003da:	00011717          	auipc	a4,0x11
ffffffffc02003de:	06f73723          	sd	a5,110(a4) # ffffffffc0211448 <timebase>
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
ffffffffc02003fe:	1e650513          	addi	a0,a0,486 # ffffffffc02045e0 <commands+0x198>
    ticks = 0;
ffffffffc0200402:	00011797          	auipc	a5,0x11
ffffffffc0200406:	0607bb23          	sd	zero,118(a5) # ffffffffc0211478 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc020040a:	cb5ff06f          	j	ffffffffc02000be <cprintf>

ffffffffc020040e <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc020040e:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200412:	00011797          	auipc	a5,0x11
ffffffffc0200416:	03678793          	addi	a5,a5,54 # ffffffffc0211448 <timebase>
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
ffffffffc0200448:	0b2000ef          	jal	ra,ffffffffc02004fa <intr_disable>
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
ffffffffc020045c:	0980006f          	j	ffffffffc02004f4 <intr_enable>

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
ffffffffc020047c:	07e000ef          	jal	ra,ffffffffc02004fa <intr_disable>
ffffffffc0200480:	4501                	li	a0,0
ffffffffc0200482:	4581                	li	a1,0
ffffffffc0200484:	4601                	li	a2,0
ffffffffc0200486:	4889                	li	a7,2
ffffffffc0200488:	00000073          	ecall
ffffffffc020048c:	2501                	sext.w	a0,a0
ffffffffc020048e:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc0200490:	064000ef          	jal	ra,ffffffffc02004f4 <intr_enable>
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

ffffffffc02004aa <ide_read_secs>:

int ide_read_secs(unsigned short ideno, uint32_t secno, void *dst,
                  size_t nsecs) {
    int iobase = secno * SECTSIZE;
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc02004aa:	0000a797          	auipc	a5,0xa
ffffffffc02004ae:	b9678793          	addi	a5,a5,-1130 # ffffffffc020a040 <edata>
ffffffffc02004b2:	0095959b          	slliw	a1,a1,0x9
                  size_t nsecs) {
ffffffffc02004b6:	1141                	addi	sp,sp,-16
ffffffffc02004b8:	8532                	mv	a0,a2
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc02004ba:	95be                	add	a1,a1,a5
ffffffffc02004bc:	00969613          	slli	a2,a3,0x9
                  size_t nsecs) {
ffffffffc02004c0:	e406                	sd	ra,8(sp)
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc02004c2:	645030ef          	jal	ra,ffffffffc0204306 <memcpy>
    return 0;
}
ffffffffc02004c6:	60a2                	ld	ra,8(sp)
ffffffffc02004c8:	4501                	li	a0,0
ffffffffc02004ca:	0141                	addi	sp,sp,16
ffffffffc02004cc:	8082                	ret

ffffffffc02004ce <ide_write_secs>:

int ide_write_secs(unsigned short ideno, uint32_t secno, const void *src,
                   size_t nsecs) {
ffffffffc02004ce:	8732                	mv	a4,a2
    int iobase = secno * SECTSIZE;
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc02004d0:	0095979b          	slliw	a5,a1,0x9
ffffffffc02004d4:	0000a517          	auipc	a0,0xa
ffffffffc02004d8:	b6c50513          	addi	a0,a0,-1172 # ffffffffc020a040 <edata>
                   size_t nsecs) {
ffffffffc02004dc:	1141                	addi	sp,sp,-16
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc02004de:	00969613          	slli	a2,a3,0x9
ffffffffc02004e2:	85ba                	mv	a1,a4
ffffffffc02004e4:	953e                	add	a0,a0,a5
                   size_t nsecs) {
ffffffffc02004e6:	e406                	sd	ra,8(sp)
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc02004e8:	61f030ef          	jal	ra,ffffffffc0204306 <memcpy>
    return 0;
}
ffffffffc02004ec:	60a2                	ld	ra,8(sp)
ffffffffc02004ee:	4501                	li	a0,0
ffffffffc02004f0:	0141                	addi	sp,sp,16
ffffffffc02004f2:	8082                	ret

ffffffffc02004f4 <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc02004f4:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc02004f8:	8082                	ret

ffffffffc02004fa <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc02004fa:	100177f3          	csrrci	a5,sstatus,2
ffffffffc02004fe:	8082                	ret

ffffffffc0200500 <pgfault_handler>:
    set_csr(sstatus, SSTATUS_SUM);
}

/* trap_in_kernel - test if trap happened in kernel */
bool trap_in_kernel(struct trapframe *tf) {
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200500:	10053783          	ld	a5,256(a0)
    cprintf("page fault at 0x%08x: %c/%c\n", tf->badvaddr,
            trap_in_kernel(tf) ? 'K' : 'U',
            tf->cause == CAUSE_STORE_PAGE_FAULT ? 'W' : 'R');
}

static int pgfault_handler(struct trapframe *tf) {
ffffffffc0200504:	1141                	addi	sp,sp,-16
ffffffffc0200506:	e022                	sd	s0,0(sp)
ffffffffc0200508:	e406                	sd	ra,8(sp)
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc020050a:	1007f793          	andi	a5,a5,256
static int pgfault_handler(struct trapframe *tf) {
ffffffffc020050e:	842a                	mv	s0,a0
    cprintf("page fault at 0x%08x: %c/%c\n", tf->badvaddr,
ffffffffc0200510:	11053583          	ld	a1,272(a0)
ffffffffc0200514:	05500613          	li	a2,85
ffffffffc0200518:	c399                	beqz	a5,ffffffffc020051e <pgfault_handler+0x1e>
ffffffffc020051a:	04b00613          	li	a2,75
ffffffffc020051e:	11843703          	ld	a4,280(s0)
ffffffffc0200522:	47bd                	li	a5,15
ffffffffc0200524:	05700693          	li	a3,87
ffffffffc0200528:	00f70463          	beq	a4,a5,ffffffffc0200530 <pgfault_handler+0x30>
ffffffffc020052c:	05200693          	li	a3,82
ffffffffc0200530:	00004517          	auipc	a0,0x4
ffffffffc0200534:	3a850513          	addi	a0,a0,936 # ffffffffc02048d8 <commands+0x490>
ffffffffc0200538:	b87ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    extern struct mm_struct *check_mm_struct;
    print_pgfault(tf);
    if (check_mm_struct != NULL) {
ffffffffc020053c:	00011797          	auipc	a5,0x11
ffffffffc0200540:	05c78793          	addi	a5,a5,92 # ffffffffc0211598 <check_mm_struct>
ffffffffc0200544:	6388                	ld	a0,0(a5)
ffffffffc0200546:	c911                	beqz	a0,ffffffffc020055a <pgfault_handler+0x5a>
        return do_pgfault(check_mm_struct, tf->cause, tf->badvaddr);
ffffffffc0200548:	11043603          	ld	a2,272(s0)
ffffffffc020054c:	11843583          	ld	a1,280(s0)
    }
    panic("unhandled page fault.\n");
}
ffffffffc0200550:	6402                	ld	s0,0(sp)
ffffffffc0200552:	60a2                	ld	ra,8(sp)
ffffffffc0200554:	0141                	addi	sp,sp,16
        return do_pgfault(check_mm_struct, tf->cause, tf->badvaddr);
ffffffffc0200556:	5d00306f          	j	ffffffffc0203b26 <do_pgfault>
    panic("unhandled page fault.\n");
ffffffffc020055a:	00004617          	auipc	a2,0x4
ffffffffc020055e:	39e60613          	addi	a2,a2,926 # ffffffffc02048f8 <commands+0x4b0>
ffffffffc0200562:	07800593          	li	a1,120
ffffffffc0200566:	00004517          	auipc	a0,0x4
ffffffffc020056a:	3aa50513          	addi	a0,a0,938 # ffffffffc0204910 <commands+0x4c8>
ffffffffc020056e:	e07ff0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0200572 <idt_init>:
    write_csr(sscratch, 0);
ffffffffc0200572:	14005073          	csrwi	sscratch,0
    write_csr(stvec, &__alltraps);
ffffffffc0200576:	00000797          	auipc	a5,0x0
ffffffffc020057a:	4ca78793          	addi	a5,a5,1226 # ffffffffc0200a40 <__alltraps>
ffffffffc020057e:	10579073          	csrw	stvec,a5
    set_csr(sstatus, SSTATUS_SIE);
ffffffffc0200582:	100167f3          	csrrsi	a5,sstatus,2
    set_csr(sstatus, SSTATUS_SUM);
ffffffffc0200586:	000407b7          	lui	a5,0x40
ffffffffc020058a:	1007a7f3          	csrrs	a5,sstatus,a5
}
ffffffffc020058e:	8082                	ret

ffffffffc0200590 <print_regs>:
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200590:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
ffffffffc0200592:	1141                	addi	sp,sp,-16
ffffffffc0200594:	e022                	sd	s0,0(sp)
ffffffffc0200596:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200598:	00004517          	auipc	a0,0x4
ffffffffc020059c:	39050513          	addi	a0,a0,912 # ffffffffc0204928 <commands+0x4e0>
void print_regs(struct pushregs *gpr) {
ffffffffc02005a0:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc02005a2:	b1dff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc02005a6:	640c                	ld	a1,8(s0)
ffffffffc02005a8:	00004517          	auipc	a0,0x4
ffffffffc02005ac:	39850513          	addi	a0,a0,920 # ffffffffc0204940 <commands+0x4f8>
ffffffffc02005b0:	b0fff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc02005b4:	680c                	ld	a1,16(s0)
ffffffffc02005b6:	00004517          	auipc	a0,0x4
ffffffffc02005ba:	3a250513          	addi	a0,a0,930 # ffffffffc0204958 <commands+0x510>
ffffffffc02005be:	b01ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02005c2:	6c0c                	ld	a1,24(s0)
ffffffffc02005c4:	00004517          	auipc	a0,0x4
ffffffffc02005c8:	3ac50513          	addi	a0,a0,940 # ffffffffc0204970 <commands+0x528>
ffffffffc02005cc:	af3ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02005d0:	700c                	ld	a1,32(s0)
ffffffffc02005d2:	00004517          	auipc	a0,0x4
ffffffffc02005d6:	3b650513          	addi	a0,a0,950 # ffffffffc0204988 <commands+0x540>
ffffffffc02005da:	ae5ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02005de:	740c                	ld	a1,40(s0)
ffffffffc02005e0:	00004517          	auipc	a0,0x4
ffffffffc02005e4:	3c050513          	addi	a0,a0,960 # ffffffffc02049a0 <commands+0x558>
ffffffffc02005e8:	ad7ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02005ec:	780c                	ld	a1,48(s0)
ffffffffc02005ee:	00004517          	auipc	a0,0x4
ffffffffc02005f2:	3ca50513          	addi	a0,a0,970 # ffffffffc02049b8 <commands+0x570>
ffffffffc02005f6:	ac9ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02005fa:	7c0c                	ld	a1,56(s0)
ffffffffc02005fc:	00004517          	auipc	a0,0x4
ffffffffc0200600:	3d450513          	addi	a0,a0,980 # ffffffffc02049d0 <commands+0x588>
ffffffffc0200604:	abbff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc0200608:	602c                	ld	a1,64(s0)
ffffffffc020060a:	00004517          	auipc	a0,0x4
ffffffffc020060e:	3de50513          	addi	a0,a0,990 # ffffffffc02049e8 <commands+0x5a0>
ffffffffc0200612:	aadff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc0200616:	642c                	ld	a1,72(s0)
ffffffffc0200618:	00004517          	auipc	a0,0x4
ffffffffc020061c:	3e850513          	addi	a0,a0,1000 # ffffffffc0204a00 <commands+0x5b8>
ffffffffc0200620:	a9fff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc0200624:	682c                	ld	a1,80(s0)
ffffffffc0200626:	00004517          	auipc	a0,0x4
ffffffffc020062a:	3f250513          	addi	a0,a0,1010 # ffffffffc0204a18 <commands+0x5d0>
ffffffffc020062e:	a91ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc0200632:	6c2c                	ld	a1,88(s0)
ffffffffc0200634:	00004517          	auipc	a0,0x4
ffffffffc0200638:	3fc50513          	addi	a0,a0,1020 # ffffffffc0204a30 <commands+0x5e8>
ffffffffc020063c:	a83ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200640:	702c                	ld	a1,96(s0)
ffffffffc0200642:	00004517          	auipc	a0,0x4
ffffffffc0200646:	40650513          	addi	a0,a0,1030 # ffffffffc0204a48 <commands+0x600>
ffffffffc020064a:	a75ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc020064e:	742c                	ld	a1,104(s0)
ffffffffc0200650:	00004517          	auipc	a0,0x4
ffffffffc0200654:	41050513          	addi	a0,a0,1040 # ffffffffc0204a60 <commands+0x618>
ffffffffc0200658:	a67ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc020065c:	782c                	ld	a1,112(s0)
ffffffffc020065e:	00004517          	auipc	a0,0x4
ffffffffc0200662:	41a50513          	addi	a0,a0,1050 # ffffffffc0204a78 <commands+0x630>
ffffffffc0200666:	a59ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc020066a:	7c2c                	ld	a1,120(s0)
ffffffffc020066c:	00004517          	auipc	a0,0x4
ffffffffc0200670:	42450513          	addi	a0,a0,1060 # ffffffffc0204a90 <commands+0x648>
ffffffffc0200674:	a4bff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc0200678:	604c                	ld	a1,128(s0)
ffffffffc020067a:	00004517          	auipc	a0,0x4
ffffffffc020067e:	42e50513          	addi	a0,a0,1070 # ffffffffc0204aa8 <commands+0x660>
ffffffffc0200682:	a3dff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc0200686:	644c                	ld	a1,136(s0)
ffffffffc0200688:	00004517          	auipc	a0,0x4
ffffffffc020068c:	43850513          	addi	a0,a0,1080 # ffffffffc0204ac0 <commands+0x678>
ffffffffc0200690:	a2fff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200694:	684c                	ld	a1,144(s0)
ffffffffc0200696:	00004517          	auipc	a0,0x4
ffffffffc020069a:	44250513          	addi	a0,a0,1090 # ffffffffc0204ad8 <commands+0x690>
ffffffffc020069e:	a21ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc02006a2:	6c4c                	ld	a1,152(s0)
ffffffffc02006a4:	00004517          	auipc	a0,0x4
ffffffffc02006a8:	44c50513          	addi	a0,a0,1100 # ffffffffc0204af0 <commands+0x6a8>
ffffffffc02006ac:	a13ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc02006b0:	704c                	ld	a1,160(s0)
ffffffffc02006b2:	00004517          	auipc	a0,0x4
ffffffffc02006b6:	45650513          	addi	a0,a0,1110 # ffffffffc0204b08 <commands+0x6c0>
ffffffffc02006ba:	a05ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02006be:	744c                	ld	a1,168(s0)
ffffffffc02006c0:	00004517          	auipc	a0,0x4
ffffffffc02006c4:	46050513          	addi	a0,a0,1120 # ffffffffc0204b20 <commands+0x6d8>
ffffffffc02006c8:	9f7ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02006cc:	784c                	ld	a1,176(s0)
ffffffffc02006ce:	00004517          	auipc	a0,0x4
ffffffffc02006d2:	46a50513          	addi	a0,a0,1130 # ffffffffc0204b38 <commands+0x6f0>
ffffffffc02006d6:	9e9ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02006da:	7c4c                	ld	a1,184(s0)
ffffffffc02006dc:	00004517          	auipc	a0,0x4
ffffffffc02006e0:	47450513          	addi	a0,a0,1140 # ffffffffc0204b50 <commands+0x708>
ffffffffc02006e4:	9dbff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02006e8:	606c                	ld	a1,192(s0)
ffffffffc02006ea:	00004517          	auipc	a0,0x4
ffffffffc02006ee:	47e50513          	addi	a0,a0,1150 # ffffffffc0204b68 <commands+0x720>
ffffffffc02006f2:	9cdff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02006f6:	646c                	ld	a1,200(s0)
ffffffffc02006f8:	00004517          	auipc	a0,0x4
ffffffffc02006fc:	48850513          	addi	a0,a0,1160 # ffffffffc0204b80 <commands+0x738>
ffffffffc0200700:	9bfff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc0200704:	686c                	ld	a1,208(s0)
ffffffffc0200706:	00004517          	auipc	a0,0x4
ffffffffc020070a:	49250513          	addi	a0,a0,1170 # ffffffffc0204b98 <commands+0x750>
ffffffffc020070e:	9b1ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc0200712:	6c6c                	ld	a1,216(s0)
ffffffffc0200714:	00004517          	auipc	a0,0x4
ffffffffc0200718:	49c50513          	addi	a0,a0,1180 # ffffffffc0204bb0 <commands+0x768>
ffffffffc020071c:	9a3ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc0200720:	706c                	ld	a1,224(s0)
ffffffffc0200722:	00004517          	auipc	a0,0x4
ffffffffc0200726:	4a650513          	addi	a0,a0,1190 # ffffffffc0204bc8 <commands+0x780>
ffffffffc020072a:	995ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc020072e:	746c                	ld	a1,232(s0)
ffffffffc0200730:	00004517          	auipc	a0,0x4
ffffffffc0200734:	4b050513          	addi	a0,a0,1200 # ffffffffc0204be0 <commands+0x798>
ffffffffc0200738:	987ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc020073c:	786c                	ld	a1,240(s0)
ffffffffc020073e:	00004517          	auipc	a0,0x4
ffffffffc0200742:	4ba50513          	addi	a0,a0,1210 # ffffffffc0204bf8 <commands+0x7b0>
ffffffffc0200746:	979ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020074a:	7c6c                	ld	a1,248(s0)
}
ffffffffc020074c:	6402                	ld	s0,0(sp)
ffffffffc020074e:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200750:	00004517          	auipc	a0,0x4
ffffffffc0200754:	4c050513          	addi	a0,a0,1216 # ffffffffc0204c10 <commands+0x7c8>
}
ffffffffc0200758:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020075a:	965ff06f          	j	ffffffffc02000be <cprintf>

ffffffffc020075e <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
ffffffffc020075e:	1141                	addi	sp,sp,-16
ffffffffc0200760:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200762:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
ffffffffc0200764:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc0200766:	00004517          	auipc	a0,0x4
ffffffffc020076a:	4c250513          	addi	a0,a0,1218 # ffffffffc0204c28 <commands+0x7e0>
void print_trapframe(struct trapframe *tf) {
ffffffffc020076e:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200770:	94fff0ef          	jal	ra,ffffffffc02000be <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200774:	8522                	mv	a0,s0
ffffffffc0200776:	e1bff0ef          	jal	ra,ffffffffc0200590 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc020077a:	10043583          	ld	a1,256(s0)
ffffffffc020077e:	00004517          	auipc	a0,0x4
ffffffffc0200782:	4c250513          	addi	a0,a0,1218 # ffffffffc0204c40 <commands+0x7f8>
ffffffffc0200786:	939ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc020078a:	10843583          	ld	a1,264(s0)
ffffffffc020078e:	00004517          	auipc	a0,0x4
ffffffffc0200792:	4ca50513          	addi	a0,a0,1226 # ffffffffc0204c58 <commands+0x810>
ffffffffc0200796:	929ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc020079a:	11043583          	ld	a1,272(s0)
ffffffffc020079e:	00004517          	auipc	a0,0x4
ffffffffc02007a2:	4d250513          	addi	a0,a0,1234 # ffffffffc0204c70 <commands+0x828>
ffffffffc02007a6:	919ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02007aa:	11843583          	ld	a1,280(s0)
}
ffffffffc02007ae:	6402                	ld	s0,0(sp)
ffffffffc02007b0:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02007b2:	00004517          	auipc	a0,0x4
ffffffffc02007b6:	4d650513          	addi	a0,a0,1238 # ffffffffc0204c88 <commands+0x840>
}
ffffffffc02007ba:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02007bc:	903ff06f          	j	ffffffffc02000be <cprintf>

ffffffffc02007c0 <interrupt_handler>:

static volatile int in_swap_tick_event = 0;
extern struct mm_struct *check_mm_struct;

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc02007c0:	11853783          	ld	a5,280(a0)
ffffffffc02007c4:	577d                	li	a4,-1
ffffffffc02007c6:	8305                	srli	a4,a4,0x1
ffffffffc02007c8:	8ff9                	and	a5,a5,a4
    switch (cause) {
ffffffffc02007ca:	472d                	li	a4,11
ffffffffc02007cc:	08f76f63          	bltu	a4,a5,ffffffffc020086a <interrupt_handler+0xaa>
ffffffffc02007d0:	00004717          	auipc	a4,0x4
ffffffffc02007d4:	e2c70713          	addi	a4,a4,-468 # ffffffffc02045fc <commands+0x1b4>
ffffffffc02007d8:	078a                	slli	a5,a5,0x2
ffffffffc02007da:	97ba                	add	a5,a5,a4
ffffffffc02007dc:	439c                	lw	a5,0(a5)
ffffffffc02007de:	97ba                	add	a5,a5,a4
ffffffffc02007e0:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc02007e2:	00004517          	auipc	a0,0x4
ffffffffc02007e6:	0a650513          	addi	a0,a0,166 # ffffffffc0204888 <commands+0x440>
ffffffffc02007ea:	8d5ff06f          	j	ffffffffc02000be <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02007ee:	00004517          	auipc	a0,0x4
ffffffffc02007f2:	07a50513          	addi	a0,a0,122 # ffffffffc0204868 <commands+0x420>
ffffffffc02007f6:	8c9ff06f          	j	ffffffffc02000be <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02007fa:	00004517          	auipc	a0,0x4
ffffffffc02007fe:	02e50513          	addi	a0,a0,46 # ffffffffc0204828 <commands+0x3e0>
ffffffffc0200802:	8bdff06f          	j	ffffffffc02000be <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc0200806:	00004517          	auipc	a0,0x4
ffffffffc020080a:	04250513          	addi	a0,a0,66 # ffffffffc0204848 <commands+0x400>
ffffffffc020080e:	8b1ff06f          	j	ffffffffc02000be <cprintf>
            break;
        case IRQ_U_EXT:
            cprintf("User software interrupt\n");
            break;
        case IRQ_S_EXT:
            cprintf("Supervisor external interrupt\n");
ffffffffc0200812:	00004517          	auipc	a0,0x4
ffffffffc0200816:	0a650513          	addi	a0,a0,166 # ffffffffc02048b8 <commands+0x470>
ffffffffc020081a:	8a5ff06f          	j	ffffffffc02000be <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc020081e:	1141                	addi	sp,sp,-16
ffffffffc0200820:	e022                	sd	s0,0(sp)
ffffffffc0200822:	e406                	sd	ra,8(sp)
            clock_set_next_event();
ffffffffc0200824:	bebff0ef          	jal	ra,ffffffffc020040e <clock_set_next_event>
	        ticks++;
ffffffffc0200828:	00011717          	auipc	a4,0x11
ffffffffc020082c:	c5070713          	addi	a4,a4,-944 # ffffffffc0211478 <ticks>
ffffffffc0200830:	631c                	ld	a5,0(a4)
	        if(ticks==100){
ffffffffc0200832:	06400693          	li	a3,100
ffffffffc0200836:	00011417          	auipc	s0,0x11
ffffffffc020083a:	c1a40413          	addi	s0,s0,-998 # ffffffffc0211450 <num>
	        ticks++;
ffffffffc020083e:	0785                	addi	a5,a5,1
ffffffffc0200840:	00011617          	auipc	a2,0x11
ffffffffc0200844:	c2f63c23          	sd	a5,-968(a2) # ffffffffc0211478 <ticks>
	        if(ticks==100){
ffffffffc0200848:	631c                	ld	a5,0(a4)
ffffffffc020084a:	02d78263          	beq	a5,a3,ffffffffc020086e <interrupt_handler+0xae>
	        if(num==10){
ffffffffc020084e:	6018                	ld	a4,0(s0)
ffffffffc0200850:	47a9                	li	a5,10
ffffffffc0200852:	00f71863          	bne	a4,a5,ffffffffc0200862 <interrupt_handler+0xa2>
#endif
}

static inline void sbi_shutdown(void)
{
	SBI_CALL_0(SBI_SHUTDOWN);
ffffffffc0200856:	4501                	li	a0,0
ffffffffc0200858:	4581                	li	a1,0
ffffffffc020085a:	4601                	li	a2,0
ffffffffc020085c:	48a1                	li	a7,8
ffffffffc020085e:	00000073          	ecall
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200862:	60a2                	ld	ra,8(sp)
ffffffffc0200864:	6402                	ld	s0,0(sp)
ffffffffc0200866:	0141                	addi	sp,sp,16
ffffffffc0200868:	8082                	ret
            print_trapframe(tf);
ffffffffc020086a:	ef5ff06f          	j	ffffffffc020075e <print_trapframe>
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc020086e:	06400593          	li	a1,100
ffffffffc0200872:	00004517          	auipc	a0,0x4
ffffffffc0200876:	03650513          	addi	a0,a0,54 # ffffffffc02048a8 <commands+0x460>
ffffffffc020087a:	845ff0ef          	jal	ra,ffffffffc02000be <cprintf>
		        num++;
ffffffffc020087e:	601c                	ld	a5,0(s0)
ffffffffc0200880:	0785                	addi	a5,a5,1
ffffffffc0200882:	00011717          	auipc	a4,0x11
ffffffffc0200886:	bcf73723          	sd	a5,-1074(a4) # ffffffffc0211450 <num>
		        ticks=0;
ffffffffc020088a:	00011797          	auipc	a5,0x11
ffffffffc020088e:	be07b723          	sd	zero,-1042(a5) # ffffffffc0211478 <ticks>
ffffffffc0200892:	bf75                	j	ffffffffc020084e <interrupt_handler+0x8e>

ffffffffc0200894 <exception_handler>:


void exception_handler(struct trapframe *tf) {
    int ret;
    switch (tf->cause) {
ffffffffc0200894:	11853783          	ld	a5,280(a0)
ffffffffc0200898:	473d                	li	a4,15
ffffffffc020089a:	16f76563          	bltu	a4,a5,ffffffffc0200a04 <exception_handler+0x170>
ffffffffc020089e:	00004717          	auipc	a4,0x4
ffffffffc02008a2:	d8e70713          	addi	a4,a4,-626 # ffffffffc020462c <commands+0x1e4>
ffffffffc02008a6:	078a                	slli	a5,a5,0x2
ffffffffc02008a8:	97ba                	add	a5,a5,a4
ffffffffc02008aa:	439c                	lw	a5,0(a5)
void exception_handler(struct trapframe *tf) {
ffffffffc02008ac:	1101                	addi	sp,sp,-32
ffffffffc02008ae:	e822                	sd	s0,16(sp)
ffffffffc02008b0:	ec06                	sd	ra,24(sp)
ffffffffc02008b2:	e426                	sd	s1,8(sp)
    switch (tf->cause) {
ffffffffc02008b4:	97ba                	add	a5,a5,a4
ffffffffc02008b6:	842a                	mv	s0,a0
ffffffffc02008b8:	8782                	jr	a5
                print_trapframe(tf);
                panic("handle pgfault failed. %e\n", ret);
            }
            break;
        case CAUSE_STORE_PAGE_FAULT:
            cprintf("Store/AMO page fault\n");
ffffffffc02008ba:	00004517          	auipc	a0,0x4
ffffffffc02008be:	f5650513          	addi	a0,a0,-170 # ffffffffc0204810 <commands+0x3c8>
ffffffffc02008c2:	ffcff0ef          	jal	ra,ffffffffc02000be <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc02008c6:	8522                	mv	a0,s0
ffffffffc02008c8:	c39ff0ef          	jal	ra,ffffffffc0200500 <pgfault_handler>
ffffffffc02008cc:	84aa                	mv	s1,a0
ffffffffc02008ce:	12051d63          	bnez	a0,ffffffffc0200a08 <exception_handler+0x174>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc02008d2:	60e2                	ld	ra,24(sp)
ffffffffc02008d4:	6442                	ld	s0,16(sp)
ffffffffc02008d6:	64a2                	ld	s1,8(sp)
ffffffffc02008d8:	6105                	addi	sp,sp,32
ffffffffc02008da:	8082                	ret
            cprintf("Instruction address misaligned\n");
ffffffffc02008dc:	00004517          	auipc	a0,0x4
ffffffffc02008e0:	d9450513          	addi	a0,a0,-620 # ffffffffc0204670 <commands+0x228>
}
ffffffffc02008e4:	6442                	ld	s0,16(sp)
ffffffffc02008e6:	60e2                	ld	ra,24(sp)
ffffffffc02008e8:	64a2                	ld	s1,8(sp)
ffffffffc02008ea:	6105                	addi	sp,sp,32
            cprintf("Instruction access fault\n");
ffffffffc02008ec:	fd2ff06f          	j	ffffffffc02000be <cprintf>
ffffffffc02008f0:	00004517          	auipc	a0,0x4
ffffffffc02008f4:	da050513          	addi	a0,a0,-608 # ffffffffc0204690 <commands+0x248>
ffffffffc02008f8:	b7f5                	j	ffffffffc02008e4 <exception_handler+0x50>
            cprintf("Illegal instruction\n");
ffffffffc02008fa:	00004517          	auipc	a0,0x4
ffffffffc02008fe:	db650513          	addi	a0,a0,-586 # ffffffffc02046b0 <commands+0x268>
ffffffffc0200902:	b7cd                	j	ffffffffc02008e4 <exception_handler+0x50>
            cprintf("Breakpoint\n");
ffffffffc0200904:	00004517          	auipc	a0,0x4
ffffffffc0200908:	dc450513          	addi	a0,a0,-572 # ffffffffc02046c8 <commands+0x280>
ffffffffc020090c:	bfe1                	j	ffffffffc02008e4 <exception_handler+0x50>
            cprintf("Load address misaligned\n");
ffffffffc020090e:	00004517          	auipc	a0,0x4
ffffffffc0200912:	dca50513          	addi	a0,a0,-566 # ffffffffc02046d8 <commands+0x290>
ffffffffc0200916:	b7f9                	j	ffffffffc02008e4 <exception_handler+0x50>
            cprintf("Load access fault\n");
ffffffffc0200918:	00004517          	auipc	a0,0x4
ffffffffc020091c:	de050513          	addi	a0,a0,-544 # ffffffffc02046f8 <commands+0x2b0>
ffffffffc0200920:	f9eff0ef          	jal	ra,ffffffffc02000be <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200924:	8522                	mv	a0,s0
ffffffffc0200926:	bdbff0ef          	jal	ra,ffffffffc0200500 <pgfault_handler>
ffffffffc020092a:	84aa                	mv	s1,a0
ffffffffc020092c:	d15d                	beqz	a0,ffffffffc02008d2 <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc020092e:	8522                	mv	a0,s0
ffffffffc0200930:	e2fff0ef          	jal	ra,ffffffffc020075e <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200934:	86a6                	mv	a3,s1
ffffffffc0200936:	00004617          	auipc	a2,0x4
ffffffffc020093a:	dda60613          	addi	a2,a2,-550 # ffffffffc0204710 <commands+0x2c8>
ffffffffc020093e:	0d600593          	li	a1,214
ffffffffc0200942:	00004517          	auipc	a0,0x4
ffffffffc0200946:	fce50513          	addi	a0,a0,-50 # ffffffffc0204910 <commands+0x4c8>
ffffffffc020094a:	a2bff0ef          	jal	ra,ffffffffc0200374 <__panic>
            cprintf("AMO address misaligned\n");
ffffffffc020094e:	00004517          	auipc	a0,0x4
ffffffffc0200952:	de250513          	addi	a0,a0,-542 # ffffffffc0204730 <commands+0x2e8>
ffffffffc0200956:	b779                	j	ffffffffc02008e4 <exception_handler+0x50>
            cprintf("Store/AMO access fault\n");
ffffffffc0200958:	00004517          	auipc	a0,0x4
ffffffffc020095c:	df050513          	addi	a0,a0,-528 # ffffffffc0204748 <commands+0x300>
ffffffffc0200960:	f5eff0ef          	jal	ra,ffffffffc02000be <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200964:	8522                	mv	a0,s0
ffffffffc0200966:	b9bff0ef          	jal	ra,ffffffffc0200500 <pgfault_handler>
ffffffffc020096a:	84aa                	mv	s1,a0
ffffffffc020096c:	d13d                	beqz	a0,ffffffffc02008d2 <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc020096e:	8522                	mv	a0,s0
ffffffffc0200970:	defff0ef          	jal	ra,ffffffffc020075e <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200974:	86a6                	mv	a3,s1
ffffffffc0200976:	00004617          	auipc	a2,0x4
ffffffffc020097a:	d9a60613          	addi	a2,a2,-614 # ffffffffc0204710 <commands+0x2c8>
ffffffffc020097e:	0e000593          	li	a1,224
ffffffffc0200982:	00004517          	auipc	a0,0x4
ffffffffc0200986:	f8e50513          	addi	a0,a0,-114 # ffffffffc0204910 <commands+0x4c8>
ffffffffc020098a:	9ebff0ef          	jal	ra,ffffffffc0200374 <__panic>
            cprintf("Environment call from U-mode\n");
ffffffffc020098e:	00004517          	auipc	a0,0x4
ffffffffc0200992:	dd250513          	addi	a0,a0,-558 # ffffffffc0204760 <commands+0x318>
ffffffffc0200996:	b7b9                	j	ffffffffc02008e4 <exception_handler+0x50>
            cprintf("Environment call from S-mode\n");
ffffffffc0200998:	00004517          	auipc	a0,0x4
ffffffffc020099c:	de850513          	addi	a0,a0,-536 # ffffffffc0204780 <commands+0x338>
ffffffffc02009a0:	b791                	j	ffffffffc02008e4 <exception_handler+0x50>
            cprintf("Environment call from H-mode\n");
ffffffffc02009a2:	00004517          	auipc	a0,0x4
ffffffffc02009a6:	dfe50513          	addi	a0,a0,-514 # ffffffffc02047a0 <commands+0x358>
ffffffffc02009aa:	bf2d                	j	ffffffffc02008e4 <exception_handler+0x50>
            cprintf("Environment call from M-mode\n");
ffffffffc02009ac:	00004517          	auipc	a0,0x4
ffffffffc02009b0:	e1450513          	addi	a0,a0,-492 # ffffffffc02047c0 <commands+0x378>
ffffffffc02009b4:	bf05                	j	ffffffffc02008e4 <exception_handler+0x50>
            cprintf("Instruction page fault\n");
ffffffffc02009b6:	00004517          	auipc	a0,0x4
ffffffffc02009ba:	e2a50513          	addi	a0,a0,-470 # ffffffffc02047e0 <commands+0x398>
ffffffffc02009be:	b71d                	j	ffffffffc02008e4 <exception_handler+0x50>
            cprintf("Load page fault\n");
ffffffffc02009c0:	00004517          	auipc	a0,0x4
ffffffffc02009c4:	e3850513          	addi	a0,a0,-456 # ffffffffc02047f8 <commands+0x3b0>
ffffffffc02009c8:	ef6ff0ef          	jal	ra,ffffffffc02000be <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc02009cc:	8522                	mv	a0,s0
ffffffffc02009ce:	b33ff0ef          	jal	ra,ffffffffc0200500 <pgfault_handler>
ffffffffc02009d2:	84aa                	mv	s1,a0
ffffffffc02009d4:	ee050fe3          	beqz	a0,ffffffffc02008d2 <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc02009d8:	8522                	mv	a0,s0
ffffffffc02009da:	d85ff0ef          	jal	ra,ffffffffc020075e <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc02009de:	86a6                	mv	a3,s1
ffffffffc02009e0:	00004617          	auipc	a2,0x4
ffffffffc02009e4:	d3060613          	addi	a2,a2,-720 # ffffffffc0204710 <commands+0x2c8>
ffffffffc02009e8:	0f600593          	li	a1,246
ffffffffc02009ec:	00004517          	auipc	a0,0x4
ffffffffc02009f0:	f2450513          	addi	a0,a0,-220 # ffffffffc0204910 <commands+0x4c8>
ffffffffc02009f4:	981ff0ef          	jal	ra,ffffffffc0200374 <__panic>
}
ffffffffc02009f8:	6442                	ld	s0,16(sp)
ffffffffc02009fa:	60e2                	ld	ra,24(sp)
ffffffffc02009fc:	64a2                	ld	s1,8(sp)
ffffffffc02009fe:	6105                	addi	sp,sp,32
            print_trapframe(tf);
ffffffffc0200a00:	d5fff06f          	j	ffffffffc020075e <print_trapframe>
ffffffffc0200a04:	d5bff06f          	j	ffffffffc020075e <print_trapframe>
                print_trapframe(tf);
ffffffffc0200a08:	8522                	mv	a0,s0
ffffffffc0200a0a:	d55ff0ef          	jal	ra,ffffffffc020075e <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200a0e:	86a6                	mv	a3,s1
ffffffffc0200a10:	00004617          	auipc	a2,0x4
ffffffffc0200a14:	d0060613          	addi	a2,a2,-768 # ffffffffc0204710 <commands+0x2c8>
ffffffffc0200a18:	0fd00593          	li	a1,253
ffffffffc0200a1c:	00004517          	auipc	a0,0x4
ffffffffc0200a20:	ef450513          	addi	a0,a0,-268 # ffffffffc0204910 <commands+0x4c8>
ffffffffc0200a24:	951ff0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0200a28 <trap>:
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void trap(struct trapframe *tf) {
    // dispatch based on what type of trap occurred
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200a28:	11853783          	ld	a5,280(a0)
ffffffffc0200a2c:	0007c463          	bltz	a5,ffffffffc0200a34 <trap+0xc>
        // interrupts
        interrupt_handler(tf);
    } else {
        // exceptions
        exception_handler(tf);
ffffffffc0200a30:	e65ff06f          	j	ffffffffc0200894 <exception_handler>
        interrupt_handler(tf);
ffffffffc0200a34:	d8dff06f          	j	ffffffffc02007c0 <interrupt_handler>
	...

ffffffffc0200a40 <__alltraps>:
    .endm

    .align 4
    .globl __alltraps
__alltraps:
    SAVE_ALL
ffffffffc0200a40:	14011073          	csrw	sscratch,sp
ffffffffc0200a44:	712d                	addi	sp,sp,-288
ffffffffc0200a46:	e406                	sd	ra,8(sp)
ffffffffc0200a48:	ec0e                	sd	gp,24(sp)
ffffffffc0200a4a:	f012                	sd	tp,32(sp)
ffffffffc0200a4c:	f416                	sd	t0,40(sp)
ffffffffc0200a4e:	f81a                	sd	t1,48(sp)
ffffffffc0200a50:	fc1e                	sd	t2,56(sp)
ffffffffc0200a52:	e0a2                	sd	s0,64(sp)
ffffffffc0200a54:	e4a6                	sd	s1,72(sp)
ffffffffc0200a56:	e8aa                	sd	a0,80(sp)
ffffffffc0200a58:	ecae                	sd	a1,88(sp)
ffffffffc0200a5a:	f0b2                	sd	a2,96(sp)
ffffffffc0200a5c:	f4b6                	sd	a3,104(sp)
ffffffffc0200a5e:	f8ba                	sd	a4,112(sp)
ffffffffc0200a60:	fcbe                	sd	a5,120(sp)
ffffffffc0200a62:	e142                	sd	a6,128(sp)
ffffffffc0200a64:	e546                	sd	a7,136(sp)
ffffffffc0200a66:	e94a                	sd	s2,144(sp)
ffffffffc0200a68:	ed4e                	sd	s3,152(sp)
ffffffffc0200a6a:	f152                	sd	s4,160(sp)
ffffffffc0200a6c:	f556                	sd	s5,168(sp)
ffffffffc0200a6e:	f95a                	sd	s6,176(sp)
ffffffffc0200a70:	fd5e                	sd	s7,184(sp)
ffffffffc0200a72:	e1e2                	sd	s8,192(sp)
ffffffffc0200a74:	e5e6                	sd	s9,200(sp)
ffffffffc0200a76:	e9ea                	sd	s10,208(sp)
ffffffffc0200a78:	edee                	sd	s11,216(sp)
ffffffffc0200a7a:	f1f2                	sd	t3,224(sp)
ffffffffc0200a7c:	f5f6                	sd	t4,232(sp)
ffffffffc0200a7e:	f9fa                	sd	t5,240(sp)
ffffffffc0200a80:	fdfe                	sd	t6,248(sp)
ffffffffc0200a82:	14002473          	csrr	s0,sscratch
ffffffffc0200a86:	100024f3          	csrr	s1,sstatus
ffffffffc0200a8a:	14102973          	csrr	s2,sepc
ffffffffc0200a8e:	143029f3          	csrr	s3,stval
ffffffffc0200a92:	14202a73          	csrr	s4,scause
ffffffffc0200a96:	e822                	sd	s0,16(sp)
ffffffffc0200a98:	e226                	sd	s1,256(sp)
ffffffffc0200a9a:	e64a                	sd	s2,264(sp)
ffffffffc0200a9c:	ea4e                	sd	s3,272(sp)
ffffffffc0200a9e:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc0200aa0:	850a                	mv	a0,sp
    jal trap
ffffffffc0200aa2:	f87ff0ef          	jal	ra,ffffffffc0200a28 <trap>

ffffffffc0200aa6 <__trapret>:
    // sp should be the same as before "jal trap"
    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc0200aa6:	6492                	ld	s1,256(sp)
ffffffffc0200aa8:	6932                	ld	s2,264(sp)
ffffffffc0200aaa:	10049073          	csrw	sstatus,s1
ffffffffc0200aae:	14191073          	csrw	sepc,s2
ffffffffc0200ab2:	60a2                	ld	ra,8(sp)
ffffffffc0200ab4:	61e2                	ld	gp,24(sp)
ffffffffc0200ab6:	7202                	ld	tp,32(sp)
ffffffffc0200ab8:	72a2                	ld	t0,40(sp)
ffffffffc0200aba:	7342                	ld	t1,48(sp)
ffffffffc0200abc:	73e2                	ld	t2,56(sp)
ffffffffc0200abe:	6406                	ld	s0,64(sp)
ffffffffc0200ac0:	64a6                	ld	s1,72(sp)
ffffffffc0200ac2:	6546                	ld	a0,80(sp)
ffffffffc0200ac4:	65e6                	ld	a1,88(sp)
ffffffffc0200ac6:	7606                	ld	a2,96(sp)
ffffffffc0200ac8:	76a6                	ld	a3,104(sp)
ffffffffc0200aca:	7746                	ld	a4,112(sp)
ffffffffc0200acc:	77e6                	ld	a5,120(sp)
ffffffffc0200ace:	680a                	ld	a6,128(sp)
ffffffffc0200ad0:	68aa                	ld	a7,136(sp)
ffffffffc0200ad2:	694a                	ld	s2,144(sp)
ffffffffc0200ad4:	69ea                	ld	s3,152(sp)
ffffffffc0200ad6:	7a0a                	ld	s4,160(sp)
ffffffffc0200ad8:	7aaa                	ld	s5,168(sp)
ffffffffc0200ada:	7b4a                	ld	s6,176(sp)
ffffffffc0200adc:	7bea                	ld	s7,184(sp)
ffffffffc0200ade:	6c0e                	ld	s8,192(sp)
ffffffffc0200ae0:	6cae                	ld	s9,200(sp)
ffffffffc0200ae2:	6d4e                	ld	s10,208(sp)
ffffffffc0200ae4:	6dee                	ld	s11,216(sp)
ffffffffc0200ae6:	7e0e                	ld	t3,224(sp)
ffffffffc0200ae8:	7eae                	ld	t4,232(sp)
ffffffffc0200aea:	7f4e                	ld	t5,240(sp)
ffffffffc0200aec:	7fee                	ld	t6,248(sp)
ffffffffc0200aee:	6142                	ld	sp,16(sp)
    // go back from supervisor call
    sret
ffffffffc0200af0:	10200073          	sret
	...

ffffffffc0200b00 <default_init>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0200b00:	00011797          	auipc	a5,0x11
ffffffffc0200b04:	98078793          	addi	a5,a5,-1664 # ffffffffc0211480 <free_area>
ffffffffc0200b08:	e79c                	sd	a5,8(a5)
ffffffffc0200b0a:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc0200b0c:	0007a823          	sw	zero,16(a5)
}
ffffffffc0200b10:	8082                	ret

ffffffffc0200b12 <default_nr_free_pages>:
}

static size_t
default_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0200b12:	00011517          	auipc	a0,0x11
ffffffffc0200b16:	97e56503          	lwu	a0,-1666(a0) # ffffffffc0211490 <free_area+0x10>
ffffffffc0200b1a:	8082                	ret

ffffffffc0200b1c <default_check>:
}

// LAB2: below code is used to check the first fit allocation algorithm
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
ffffffffc0200b1c:	715d                	addi	sp,sp,-80
ffffffffc0200b1e:	f84a                	sd	s2,48(sp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0200b20:	00011917          	auipc	s2,0x11
ffffffffc0200b24:	96090913          	addi	s2,s2,-1696 # ffffffffc0211480 <free_area>
ffffffffc0200b28:	00893783          	ld	a5,8(s2)
ffffffffc0200b2c:	e486                	sd	ra,72(sp)
ffffffffc0200b2e:	e0a2                	sd	s0,64(sp)
ffffffffc0200b30:	fc26                	sd	s1,56(sp)
ffffffffc0200b32:	f44e                	sd	s3,40(sp)
ffffffffc0200b34:	f052                	sd	s4,32(sp)
ffffffffc0200b36:	ec56                	sd	s5,24(sp)
ffffffffc0200b38:	e85a                	sd	s6,16(sp)
ffffffffc0200b3a:	e45e                	sd	s7,8(sp)
ffffffffc0200b3c:	e062                	sd	s8,0(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200b3e:	31278f63          	beq	a5,s2,ffffffffc0200e5c <default_check+0x340>
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200b42:	fe87b703          	ld	a4,-24(a5)
ffffffffc0200b46:	8305                	srli	a4,a4,0x1
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0200b48:	8b05                	andi	a4,a4,1
ffffffffc0200b4a:	30070d63          	beqz	a4,ffffffffc0200e64 <default_check+0x348>
    int count = 0, total = 0;
ffffffffc0200b4e:	4401                	li	s0,0
ffffffffc0200b50:	4481                	li	s1,0
ffffffffc0200b52:	a031                	j	ffffffffc0200b5e <default_check+0x42>
ffffffffc0200b54:	fe87b703          	ld	a4,-24(a5)
        assert(PageProperty(p));
ffffffffc0200b58:	8b09                	andi	a4,a4,2
ffffffffc0200b5a:	30070563          	beqz	a4,ffffffffc0200e64 <default_check+0x348>
        count ++, total += p->property;
ffffffffc0200b5e:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200b62:	679c                	ld	a5,8(a5)
ffffffffc0200b64:	2485                	addiw	s1,s1,1
ffffffffc0200b66:	9c39                	addw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200b68:	ff2796e3          	bne	a5,s2,ffffffffc0200b54 <default_check+0x38>
ffffffffc0200b6c:	89a2                	mv	s3,s0
    }
    assert(total == nr_free_pages());
ffffffffc0200b6e:	3ef000ef          	jal	ra,ffffffffc020175c <nr_free_pages>
ffffffffc0200b72:	75351963          	bne	a0,s3,ffffffffc02012c4 <default_check+0x7a8>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200b76:	4505                	li	a0,1
ffffffffc0200b78:	317000ef          	jal	ra,ffffffffc020168e <alloc_pages>
ffffffffc0200b7c:	8a2a                	mv	s4,a0
ffffffffc0200b7e:	48050363          	beqz	a0,ffffffffc0201004 <default_check+0x4e8>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200b82:	4505                	li	a0,1
ffffffffc0200b84:	30b000ef          	jal	ra,ffffffffc020168e <alloc_pages>
ffffffffc0200b88:	89aa                	mv	s3,a0
ffffffffc0200b8a:	74050d63          	beqz	a0,ffffffffc02012e4 <default_check+0x7c8>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200b8e:	4505                	li	a0,1
ffffffffc0200b90:	2ff000ef          	jal	ra,ffffffffc020168e <alloc_pages>
ffffffffc0200b94:	8aaa                	mv	s5,a0
ffffffffc0200b96:	4e050763          	beqz	a0,ffffffffc0201084 <default_check+0x568>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200b9a:	2f3a0563          	beq	s4,s3,ffffffffc0200e84 <default_check+0x368>
ffffffffc0200b9e:	2eaa0363          	beq	s4,a0,ffffffffc0200e84 <default_check+0x368>
ffffffffc0200ba2:	2ea98163          	beq	s3,a0,ffffffffc0200e84 <default_check+0x368>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200ba6:	000a2783          	lw	a5,0(s4)
ffffffffc0200baa:	2e079d63          	bnez	a5,ffffffffc0200ea4 <default_check+0x388>
ffffffffc0200bae:	0009a783          	lw	a5,0(s3)
ffffffffc0200bb2:	2e079963          	bnez	a5,ffffffffc0200ea4 <default_check+0x388>
ffffffffc0200bb6:	411c                	lw	a5,0(a0)
ffffffffc0200bb8:	2e079663          	bnez	a5,ffffffffc0200ea4 <default_check+0x388>
extern struct Page *pages;
extern size_t npage;
extern const size_t nbase;
extern uint_t va_pa_offset;

static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200bbc:	00011797          	auipc	a5,0x11
ffffffffc0200bc0:	8f478793          	addi	a5,a5,-1804 # ffffffffc02114b0 <pages>
ffffffffc0200bc4:	639c                	ld	a5,0(a5)
ffffffffc0200bc6:	00004717          	auipc	a4,0x4
ffffffffc0200bca:	0da70713          	addi	a4,a4,218 # ffffffffc0204ca0 <commands+0x858>
ffffffffc0200bce:	630c                	ld	a1,0(a4)
ffffffffc0200bd0:	40fa0733          	sub	a4,s4,a5
ffffffffc0200bd4:	870d                	srai	a4,a4,0x3
ffffffffc0200bd6:	02b70733          	mul	a4,a4,a1
ffffffffc0200bda:	00005697          	auipc	a3,0x5
ffffffffc0200bde:	55668693          	addi	a3,a3,1366 # ffffffffc0206130 <nbase>
ffffffffc0200be2:	6290                	ld	a2,0(a3)
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200be4:	00011697          	auipc	a3,0x11
ffffffffc0200be8:	87c68693          	addi	a3,a3,-1924 # ffffffffc0211460 <npage>
ffffffffc0200bec:	6294                	ld	a3,0(a3)
ffffffffc0200bee:	06b2                	slli	a3,a3,0xc
ffffffffc0200bf0:	9732                	add	a4,a4,a2

static inline uintptr_t page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
ffffffffc0200bf2:	0732                	slli	a4,a4,0xc
ffffffffc0200bf4:	2cd77863          	bleu	a3,a4,ffffffffc0200ec4 <default_check+0x3a8>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200bf8:	40f98733          	sub	a4,s3,a5
ffffffffc0200bfc:	870d                	srai	a4,a4,0x3
ffffffffc0200bfe:	02b70733          	mul	a4,a4,a1
ffffffffc0200c02:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200c04:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200c06:	4ed77f63          	bleu	a3,a4,ffffffffc0201104 <default_check+0x5e8>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200c0a:	40f507b3          	sub	a5,a0,a5
ffffffffc0200c0e:	878d                	srai	a5,a5,0x3
ffffffffc0200c10:	02b787b3          	mul	a5,a5,a1
ffffffffc0200c14:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200c16:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200c18:	34d7f663          	bleu	a3,a5,ffffffffc0200f64 <default_check+0x448>
    assert(alloc_page() == NULL);
ffffffffc0200c1c:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200c1e:	00093c03          	ld	s8,0(s2)
ffffffffc0200c22:	00893b83          	ld	s7,8(s2)
    unsigned int nr_free_store = nr_free;
ffffffffc0200c26:	01092b03          	lw	s6,16(s2)
    elm->prev = elm->next = elm;
ffffffffc0200c2a:	00011797          	auipc	a5,0x11
ffffffffc0200c2e:	8527bf23          	sd	s2,-1954(a5) # ffffffffc0211488 <free_area+0x8>
ffffffffc0200c32:	00011797          	auipc	a5,0x11
ffffffffc0200c36:	8527b723          	sd	s2,-1970(a5) # ffffffffc0211480 <free_area>
    nr_free = 0;
ffffffffc0200c3a:	00011797          	auipc	a5,0x11
ffffffffc0200c3e:	8407ab23          	sw	zero,-1962(a5) # ffffffffc0211490 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0200c42:	24d000ef          	jal	ra,ffffffffc020168e <alloc_pages>
ffffffffc0200c46:	2e051f63          	bnez	a0,ffffffffc0200f44 <default_check+0x428>
    free_page(p0);
ffffffffc0200c4a:	4585                	li	a1,1
ffffffffc0200c4c:	8552                	mv	a0,s4
ffffffffc0200c4e:	2c9000ef          	jal	ra,ffffffffc0201716 <free_pages>
    free_page(p1);
ffffffffc0200c52:	4585                	li	a1,1
ffffffffc0200c54:	854e                	mv	a0,s3
ffffffffc0200c56:	2c1000ef          	jal	ra,ffffffffc0201716 <free_pages>
    free_page(p2);
ffffffffc0200c5a:	4585                	li	a1,1
ffffffffc0200c5c:	8556                	mv	a0,s5
ffffffffc0200c5e:	2b9000ef          	jal	ra,ffffffffc0201716 <free_pages>
    assert(nr_free == 3);
ffffffffc0200c62:	01092703          	lw	a4,16(s2)
ffffffffc0200c66:	478d                	li	a5,3
ffffffffc0200c68:	2af71e63          	bne	a4,a5,ffffffffc0200f24 <default_check+0x408>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200c6c:	4505                	li	a0,1
ffffffffc0200c6e:	221000ef          	jal	ra,ffffffffc020168e <alloc_pages>
ffffffffc0200c72:	89aa                	mv	s3,a0
ffffffffc0200c74:	28050863          	beqz	a0,ffffffffc0200f04 <default_check+0x3e8>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200c78:	4505                	li	a0,1
ffffffffc0200c7a:	215000ef          	jal	ra,ffffffffc020168e <alloc_pages>
ffffffffc0200c7e:	8aaa                	mv	s5,a0
ffffffffc0200c80:	3e050263          	beqz	a0,ffffffffc0201064 <default_check+0x548>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200c84:	4505                	li	a0,1
ffffffffc0200c86:	209000ef          	jal	ra,ffffffffc020168e <alloc_pages>
ffffffffc0200c8a:	8a2a                	mv	s4,a0
ffffffffc0200c8c:	3a050c63          	beqz	a0,ffffffffc0201044 <default_check+0x528>
    assert(alloc_page() == NULL);
ffffffffc0200c90:	4505                	li	a0,1
ffffffffc0200c92:	1fd000ef          	jal	ra,ffffffffc020168e <alloc_pages>
ffffffffc0200c96:	38051763          	bnez	a0,ffffffffc0201024 <default_check+0x508>
    free_page(p0);
ffffffffc0200c9a:	4585                	li	a1,1
ffffffffc0200c9c:	854e                	mv	a0,s3
ffffffffc0200c9e:	279000ef          	jal	ra,ffffffffc0201716 <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0200ca2:	00893783          	ld	a5,8(s2)
ffffffffc0200ca6:	23278f63          	beq	a5,s2,ffffffffc0200ee4 <default_check+0x3c8>
    assert((p = alloc_page()) == p0);
ffffffffc0200caa:	4505                	li	a0,1
ffffffffc0200cac:	1e3000ef          	jal	ra,ffffffffc020168e <alloc_pages>
ffffffffc0200cb0:	32a99a63          	bne	s3,a0,ffffffffc0200fe4 <default_check+0x4c8>
    assert(alloc_page() == NULL);
ffffffffc0200cb4:	4505                	li	a0,1
ffffffffc0200cb6:	1d9000ef          	jal	ra,ffffffffc020168e <alloc_pages>
ffffffffc0200cba:	30051563          	bnez	a0,ffffffffc0200fc4 <default_check+0x4a8>
    assert(nr_free == 0);
ffffffffc0200cbe:	01092783          	lw	a5,16(s2)
ffffffffc0200cc2:	2e079163          	bnez	a5,ffffffffc0200fa4 <default_check+0x488>
    free_page(p);
ffffffffc0200cc6:	854e                	mv	a0,s3
ffffffffc0200cc8:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0200cca:	00010797          	auipc	a5,0x10
ffffffffc0200cce:	7b87bb23          	sd	s8,1974(a5) # ffffffffc0211480 <free_area>
ffffffffc0200cd2:	00010797          	auipc	a5,0x10
ffffffffc0200cd6:	7b77bb23          	sd	s7,1974(a5) # ffffffffc0211488 <free_area+0x8>
    nr_free = nr_free_store;
ffffffffc0200cda:	00010797          	auipc	a5,0x10
ffffffffc0200cde:	7b67ab23          	sw	s6,1974(a5) # ffffffffc0211490 <free_area+0x10>
    free_page(p);
ffffffffc0200ce2:	235000ef          	jal	ra,ffffffffc0201716 <free_pages>
    free_page(p1);
ffffffffc0200ce6:	4585                	li	a1,1
ffffffffc0200ce8:	8556                	mv	a0,s5
ffffffffc0200cea:	22d000ef          	jal	ra,ffffffffc0201716 <free_pages>
    free_page(p2);
ffffffffc0200cee:	4585                	li	a1,1
ffffffffc0200cf0:	8552                	mv	a0,s4
ffffffffc0200cf2:	225000ef          	jal	ra,ffffffffc0201716 <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc0200cf6:	4515                	li	a0,5
ffffffffc0200cf8:	197000ef          	jal	ra,ffffffffc020168e <alloc_pages>
ffffffffc0200cfc:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc0200cfe:	28050363          	beqz	a0,ffffffffc0200f84 <default_check+0x468>
ffffffffc0200d02:	651c                	ld	a5,8(a0)
ffffffffc0200d04:	8385                	srli	a5,a5,0x1
    assert(!PageProperty(p0));
ffffffffc0200d06:	8b85                	andi	a5,a5,1
ffffffffc0200d08:	54079e63          	bnez	a5,ffffffffc0201264 <default_check+0x748>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc0200d0c:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200d0e:	00093b03          	ld	s6,0(s2)
ffffffffc0200d12:	00893a83          	ld	s5,8(s2)
ffffffffc0200d16:	00010797          	auipc	a5,0x10
ffffffffc0200d1a:	7727b523          	sd	s2,1898(a5) # ffffffffc0211480 <free_area>
ffffffffc0200d1e:	00010797          	auipc	a5,0x10
ffffffffc0200d22:	7727b523          	sd	s2,1898(a5) # ffffffffc0211488 <free_area+0x8>
    assert(alloc_page() == NULL);
ffffffffc0200d26:	169000ef          	jal	ra,ffffffffc020168e <alloc_pages>
ffffffffc0200d2a:	50051d63          	bnez	a0,ffffffffc0201244 <default_check+0x728>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
ffffffffc0200d2e:	09098a13          	addi	s4,s3,144
ffffffffc0200d32:	8552                	mv	a0,s4
ffffffffc0200d34:	458d                	li	a1,3
    unsigned int nr_free_store = nr_free;
ffffffffc0200d36:	01092b83          	lw	s7,16(s2)
    nr_free = 0;
ffffffffc0200d3a:	00010797          	auipc	a5,0x10
ffffffffc0200d3e:	7407ab23          	sw	zero,1878(a5) # ffffffffc0211490 <free_area+0x10>
    free_pages(p0 + 2, 3);
ffffffffc0200d42:	1d5000ef          	jal	ra,ffffffffc0201716 <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc0200d46:	4511                	li	a0,4
ffffffffc0200d48:	147000ef          	jal	ra,ffffffffc020168e <alloc_pages>
ffffffffc0200d4c:	4c051c63          	bnez	a0,ffffffffc0201224 <default_check+0x708>
ffffffffc0200d50:	0989b783          	ld	a5,152(s3)
ffffffffc0200d54:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0200d56:	8b85                	andi	a5,a5,1
ffffffffc0200d58:	4a078663          	beqz	a5,ffffffffc0201204 <default_check+0x6e8>
ffffffffc0200d5c:	0a89a703          	lw	a4,168(s3)
ffffffffc0200d60:	478d                	li	a5,3
ffffffffc0200d62:	4af71163          	bne	a4,a5,ffffffffc0201204 <default_check+0x6e8>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0200d66:	450d                	li	a0,3
ffffffffc0200d68:	127000ef          	jal	ra,ffffffffc020168e <alloc_pages>
ffffffffc0200d6c:	8c2a                	mv	s8,a0
ffffffffc0200d6e:	46050b63          	beqz	a0,ffffffffc02011e4 <default_check+0x6c8>
    assert(alloc_page() == NULL);
ffffffffc0200d72:	4505                	li	a0,1
ffffffffc0200d74:	11b000ef          	jal	ra,ffffffffc020168e <alloc_pages>
ffffffffc0200d78:	44051663          	bnez	a0,ffffffffc02011c4 <default_check+0x6a8>
    assert(p0 + 2 == p1);
ffffffffc0200d7c:	438a1463          	bne	s4,s8,ffffffffc02011a4 <default_check+0x688>

    p2 = p0 + 1;
    free_page(p0);
ffffffffc0200d80:	4585                	li	a1,1
ffffffffc0200d82:	854e                	mv	a0,s3
ffffffffc0200d84:	193000ef          	jal	ra,ffffffffc0201716 <free_pages>
    free_pages(p1, 3);
ffffffffc0200d88:	458d                	li	a1,3
ffffffffc0200d8a:	8552                	mv	a0,s4
ffffffffc0200d8c:	18b000ef          	jal	ra,ffffffffc0201716 <free_pages>
ffffffffc0200d90:	0089b783          	ld	a5,8(s3)
    p2 = p0 + 1;
ffffffffc0200d94:	04898c13          	addi	s8,s3,72
ffffffffc0200d98:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0200d9a:	8b85                	andi	a5,a5,1
ffffffffc0200d9c:	3e078463          	beqz	a5,ffffffffc0201184 <default_check+0x668>
ffffffffc0200da0:	0189a703          	lw	a4,24(s3)
ffffffffc0200da4:	4785                	li	a5,1
ffffffffc0200da6:	3cf71f63          	bne	a4,a5,ffffffffc0201184 <default_check+0x668>
ffffffffc0200daa:	008a3783          	ld	a5,8(s4)
ffffffffc0200dae:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0200db0:	8b85                	andi	a5,a5,1
ffffffffc0200db2:	3a078963          	beqz	a5,ffffffffc0201164 <default_check+0x648>
ffffffffc0200db6:	018a2703          	lw	a4,24(s4)
ffffffffc0200dba:	478d                	li	a5,3
ffffffffc0200dbc:	3af71463          	bne	a4,a5,ffffffffc0201164 <default_check+0x648>

    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0200dc0:	4505                	li	a0,1
ffffffffc0200dc2:	0cd000ef          	jal	ra,ffffffffc020168e <alloc_pages>
ffffffffc0200dc6:	36a99f63          	bne	s3,a0,ffffffffc0201144 <default_check+0x628>
    free_page(p0);
ffffffffc0200dca:	4585                	li	a1,1
ffffffffc0200dcc:	14b000ef          	jal	ra,ffffffffc0201716 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0200dd0:	4509                	li	a0,2
ffffffffc0200dd2:	0bd000ef          	jal	ra,ffffffffc020168e <alloc_pages>
ffffffffc0200dd6:	34aa1763          	bne	s4,a0,ffffffffc0201124 <default_check+0x608>

    free_pages(p0, 2);
ffffffffc0200dda:	4589                	li	a1,2
ffffffffc0200ddc:	13b000ef          	jal	ra,ffffffffc0201716 <free_pages>
    free_page(p2);
ffffffffc0200de0:	4585                	li	a1,1
ffffffffc0200de2:	8562                	mv	a0,s8
ffffffffc0200de4:	133000ef          	jal	ra,ffffffffc0201716 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0200de8:	4515                	li	a0,5
ffffffffc0200dea:	0a5000ef          	jal	ra,ffffffffc020168e <alloc_pages>
ffffffffc0200dee:	89aa                	mv	s3,a0
ffffffffc0200df0:	48050a63          	beqz	a0,ffffffffc0201284 <default_check+0x768>
    assert(alloc_page() == NULL);
ffffffffc0200df4:	4505                	li	a0,1
ffffffffc0200df6:	099000ef          	jal	ra,ffffffffc020168e <alloc_pages>
ffffffffc0200dfa:	2e051563          	bnez	a0,ffffffffc02010e4 <default_check+0x5c8>

    assert(nr_free == 0);
ffffffffc0200dfe:	01092783          	lw	a5,16(s2)
ffffffffc0200e02:	2c079163          	bnez	a5,ffffffffc02010c4 <default_check+0x5a8>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc0200e06:	4595                	li	a1,5
ffffffffc0200e08:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc0200e0a:	00010797          	auipc	a5,0x10
ffffffffc0200e0e:	6977a323          	sw	s7,1670(a5) # ffffffffc0211490 <free_area+0x10>
    free_list = free_list_store;
ffffffffc0200e12:	00010797          	auipc	a5,0x10
ffffffffc0200e16:	6767b723          	sd	s6,1646(a5) # ffffffffc0211480 <free_area>
ffffffffc0200e1a:	00010797          	auipc	a5,0x10
ffffffffc0200e1e:	6757b723          	sd	s5,1646(a5) # ffffffffc0211488 <free_area+0x8>
    free_pages(p0, 5);
ffffffffc0200e22:	0f5000ef          	jal	ra,ffffffffc0201716 <free_pages>
    return listelm->next;
ffffffffc0200e26:	00893783          	ld	a5,8(s2)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200e2a:	01278963          	beq	a5,s2,ffffffffc0200e3c <default_check+0x320>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc0200e2e:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200e32:	679c                	ld	a5,8(a5)
ffffffffc0200e34:	34fd                	addiw	s1,s1,-1
ffffffffc0200e36:	9c19                	subw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200e38:	ff279be3          	bne	a5,s2,ffffffffc0200e2e <default_check+0x312>
    }
    assert(count == 0);
ffffffffc0200e3c:	26049463          	bnez	s1,ffffffffc02010a4 <default_check+0x588>
    assert(total == 0);
ffffffffc0200e40:	46041263          	bnez	s0,ffffffffc02012a4 <default_check+0x788>
}
ffffffffc0200e44:	60a6                	ld	ra,72(sp)
ffffffffc0200e46:	6406                	ld	s0,64(sp)
ffffffffc0200e48:	74e2                	ld	s1,56(sp)
ffffffffc0200e4a:	7942                	ld	s2,48(sp)
ffffffffc0200e4c:	79a2                	ld	s3,40(sp)
ffffffffc0200e4e:	7a02                	ld	s4,32(sp)
ffffffffc0200e50:	6ae2                	ld	s5,24(sp)
ffffffffc0200e52:	6b42                	ld	s6,16(sp)
ffffffffc0200e54:	6ba2                	ld	s7,8(sp)
ffffffffc0200e56:	6c02                	ld	s8,0(sp)
ffffffffc0200e58:	6161                	addi	sp,sp,80
ffffffffc0200e5a:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200e5c:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc0200e5e:	4401                	li	s0,0
ffffffffc0200e60:	4481                	li	s1,0
ffffffffc0200e62:	b331                	j	ffffffffc0200b6e <default_check+0x52>
        assert(PageProperty(p));
ffffffffc0200e64:	00004697          	auipc	a3,0x4
ffffffffc0200e68:	e4468693          	addi	a3,a3,-444 # ffffffffc0204ca8 <commands+0x860>
ffffffffc0200e6c:	00004617          	auipc	a2,0x4
ffffffffc0200e70:	e4c60613          	addi	a2,a2,-436 # ffffffffc0204cb8 <commands+0x870>
ffffffffc0200e74:	0f000593          	li	a1,240
ffffffffc0200e78:	00004517          	auipc	a0,0x4
ffffffffc0200e7c:	e5850513          	addi	a0,a0,-424 # ffffffffc0204cd0 <commands+0x888>
ffffffffc0200e80:	cf4ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200e84:	00004697          	auipc	a3,0x4
ffffffffc0200e88:	ee468693          	addi	a3,a3,-284 # ffffffffc0204d68 <commands+0x920>
ffffffffc0200e8c:	00004617          	auipc	a2,0x4
ffffffffc0200e90:	e2c60613          	addi	a2,a2,-468 # ffffffffc0204cb8 <commands+0x870>
ffffffffc0200e94:	0bd00593          	li	a1,189
ffffffffc0200e98:	00004517          	auipc	a0,0x4
ffffffffc0200e9c:	e3850513          	addi	a0,a0,-456 # ffffffffc0204cd0 <commands+0x888>
ffffffffc0200ea0:	cd4ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200ea4:	00004697          	auipc	a3,0x4
ffffffffc0200ea8:	eec68693          	addi	a3,a3,-276 # ffffffffc0204d90 <commands+0x948>
ffffffffc0200eac:	00004617          	auipc	a2,0x4
ffffffffc0200eb0:	e0c60613          	addi	a2,a2,-500 # ffffffffc0204cb8 <commands+0x870>
ffffffffc0200eb4:	0be00593          	li	a1,190
ffffffffc0200eb8:	00004517          	auipc	a0,0x4
ffffffffc0200ebc:	e1850513          	addi	a0,a0,-488 # ffffffffc0204cd0 <commands+0x888>
ffffffffc0200ec0:	cb4ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200ec4:	00004697          	auipc	a3,0x4
ffffffffc0200ec8:	f0c68693          	addi	a3,a3,-244 # ffffffffc0204dd0 <commands+0x988>
ffffffffc0200ecc:	00004617          	auipc	a2,0x4
ffffffffc0200ed0:	dec60613          	addi	a2,a2,-532 # ffffffffc0204cb8 <commands+0x870>
ffffffffc0200ed4:	0c000593          	li	a1,192
ffffffffc0200ed8:	00004517          	auipc	a0,0x4
ffffffffc0200edc:	df850513          	addi	a0,a0,-520 # ffffffffc0204cd0 <commands+0x888>
ffffffffc0200ee0:	c94ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(!list_empty(&free_list));
ffffffffc0200ee4:	00004697          	auipc	a3,0x4
ffffffffc0200ee8:	f7468693          	addi	a3,a3,-140 # ffffffffc0204e58 <commands+0xa10>
ffffffffc0200eec:	00004617          	auipc	a2,0x4
ffffffffc0200ef0:	dcc60613          	addi	a2,a2,-564 # ffffffffc0204cb8 <commands+0x870>
ffffffffc0200ef4:	0d900593          	li	a1,217
ffffffffc0200ef8:	00004517          	auipc	a0,0x4
ffffffffc0200efc:	dd850513          	addi	a0,a0,-552 # ffffffffc0204cd0 <commands+0x888>
ffffffffc0200f00:	c74ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200f04:	00004697          	auipc	a3,0x4
ffffffffc0200f08:	e0468693          	addi	a3,a3,-508 # ffffffffc0204d08 <commands+0x8c0>
ffffffffc0200f0c:	00004617          	auipc	a2,0x4
ffffffffc0200f10:	dac60613          	addi	a2,a2,-596 # ffffffffc0204cb8 <commands+0x870>
ffffffffc0200f14:	0d200593          	li	a1,210
ffffffffc0200f18:	00004517          	auipc	a0,0x4
ffffffffc0200f1c:	db850513          	addi	a0,a0,-584 # ffffffffc0204cd0 <commands+0x888>
ffffffffc0200f20:	c54ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(nr_free == 3);
ffffffffc0200f24:	00004697          	auipc	a3,0x4
ffffffffc0200f28:	f2468693          	addi	a3,a3,-220 # ffffffffc0204e48 <commands+0xa00>
ffffffffc0200f2c:	00004617          	auipc	a2,0x4
ffffffffc0200f30:	d8c60613          	addi	a2,a2,-628 # ffffffffc0204cb8 <commands+0x870>
ffffffffc0200f34:	0d000593          	li	a1,208
ffffffffc0200f38:	00004517          	auipc	a0,0x4
ffffffffc0200f3c:	d9850513          	addi	a0,a0,-616 # ffffffffc0204cd0 <commands+0x888>
ffffffffc0200f40:	c34ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200f44:	00004697          	auipc	a3,0x4
ffffffffc0200f48:	eec68693          	addi	a3,a3,-276 # ffffffffc0204e30 <commands+0x9e8>
ffffffffc0200f4c:	00004617          	auipc	a2,0x4
ffffffffc0200f50:	d6c60613          	addi	a2,a2,-660 # ffffffffc0204cb8 <commands+0x870>
ffffffffc0200f54:	0cb00593          	li	a1,203
ffffffffc0200f58:	00004517          	auipc	a0,0x4
ffffffffc0200f5c:	d7850513          	addi	a0,a0,-648 # ffffffffc0204cd0 <commands+0x888>
ffffffffc0200f60:	c14ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200f64:	00004697          	auipc	a3,0x4
ffffffffc0200f68:	eac68693          	addi	a3,a3,-340 # ffffffffc0204e10 <commands+0x9c8>
ffffffffc0200f6c:	00004617          	auipc	a2,0x4
ffffffffc0200f70:	d4c60613          	addi	a2,a2,-692 # ffffffffc0204cb8 <commands+0x870>
ffffffffc0200f74:	0c200593          	li	a1,194
ffffffffc0200f78:	00004517          	auipc	a0,0x4
ffffffffc0200f7c:	d5850513          	addi	a0,a0,-680 # ffffffffc0204cd0 <commands+0x888>
ffffffffc0200f80:	bf4ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(p0 != NULL);
ffffffffc0200f84:	00004697          	auipc	a3,0x4
ffffffffc0200f88:	f1c68693          	addi	a3,a3,-228 # ffffffffc0204ea0 <commands+0xa58>
ffffffffc0200f8c:	00004617          	auipc	a2,0x4
ffffffffc0200f90:	d2c60613          	addi	a2,a2,-724 # ffffffffc0204cb8 <commands+0x870>
ffffffffc0200f94:	0f800593          	li	a1,248
ffffffffc0200f98:	00004517          	auipc	a0,0x4
ffffffffc0200f9c:	d3850513          	addi	a0,a0,-712 # ffffffffc0204cd0 <commands+0x888>
ffffffffc0200fa0:	bd4ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(nr_free == 0);
ffffffffc0200fa4:	00004697          	auipc	a3,0x4
ffffffffc0200fa8:	eec68693          	addi	a3,a3,-276 # ffffffffc0204e90 <commands+0xa48>
ffffffffc0200fac:	00004617          	auipc	a2,0x4
ffffffffc0200fb0:	d0c60613          	addi	a2,a2,-756 # ffffffffc0204cb8 <commands+0x870>
ffffffffc0200fb4:	0df00593          	li	a1,223
ffffffffc0200fb8:	00004517          	auipc	a0,0x4
ffffffffc0200fbc:	d1850513          	addi	a0,a0,-744 # ffffffffc0204cd0 <commands+0x888>
ffffffffc0200fc0:	bb4ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200fc4:	00004697          	auipc	a3,0x4
ffffffffc0200fc8:	e6c68693          	addi	a3,a3,-404 # ffffffffc0204e30 <commands+0x9e8>
ffffffffc0200fcc:	00004617          	auipc	a2,0x4
ffffffffc0200fd0:	cec60613          	addi	a2,a2,-788 # ffffffffc0204cb8 <commands+0x870>
ffffffffc0200fd4:	0dd00593          	li	a1,221
ffffffffc0200fd8:	00004517          	auipc	a0,0x4
ffffffffc0200fdc:	cf850513          	addi	a0,a0,-776 # ffffffffc0204cd0 <commands+0x888>
ffffffffc0200fe0:	b94ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc0200fe4:	00004697          	auipc	a3,0x4
ffffffffc0200fe8:	e8c68693          	addi	a3,a3,-372 # ffffffffc0204e70 <commands+0xa28>
ffffffffc0200fec:	00004617          	auipc	a2,0x4
ffffffffc0200ff0:	ccc60613          	addi	a2,a2,-820 # ffffffffc0204cb8 <commands+0x870>
ffffffffc0200ff4:	0dc00593          	li	a1,220
ffffffffc0200ff8:	00004517          	auipc	a0,0x4
ffffffffc0200ffc:	cd850513          	addi	a0,a0,-808 # ffffffffc0204cd0 <commands+0x888>
ffffffffc0201000:	b74ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0201004:	00004697          	auipc	a3,0x4
ffffffffc0201008:	d0468693          	addi	a3,a3,-764 # ffffffffc0204d08 <commands+0x8c0>
ffffffffc020100c:	00004617          	auipc	a2,0x4
ffffffffc0201010:	cac60613          	addi	a2,a2,-852 # ffffffffc0204cb8 <commands+0x870>
ffffffffc0201014:	0b900593          	li	a1,185
ffffffffc0201018:	00004517          	auipc	a0,0x4
ffffffffc020101c:	cb850513          	addi	a0,a0,-840 # ffffffffc0204cd0 <commands+0x888>
ffffffffc0201020:	b54ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201024:	00004697          	auipc	a3,0x4
ffffffffc0201028:	e0c68693          	addi	a3,a3,-500 # ffffffffc0204e30 <commands+0x9e8>
ffffffffc020102c:	00004617          	auipc	a2,0x4
ffffffffc0201030:	c8c60613          	addi	a2,a2,-884 # ffffffffc0204cb8 <commands+0x870>
ffffffffc0201034:	0d600593          	li	a1,214
ffffffffc0201038:	00004517          	auipc	a0,0x4
ffffffffc020103c:	c9850513          	addi	a0,a0,-872 # ffffffffc0204cd0 <commands+0x888>
ffffffffc0201040:	b34ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0201044:	00004697          	auipc	a3,0x4
ffffffffc0201048:	d0468693          	addi	a3,a3,-764 # ffffffffc0204d48 <commands+0x900>
ffffffffc020104c:	00004617          	auipc	a2,0x4
ffffffffc0201050:	c6c60613          	addi	a2,a2,-916 # ffffffffc0204cb8 <commands+0x870>
ffffffffc0201054:	0d400593          	li	a1,212
ffffffffc0201058:	00004517          	auipc	a0,0x4
ffffffffc020105c:	c7850513          	addi	a0,a0,-904 # ffffffffc0204cd0 <commands+0x888>
ffffffffc0201060:	b14ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201064:	00004697          	auipc	a3,0x4
ffffffffc0201068:	cc468693          	addi	a3,a3,-828 # ffffffffc0204d28 <commands+0x8e0>
ffffffffc020106c:	00004617          	auipc	a2,0x4
ffffffffc0201070:	c4c60613          	addi	a2,a2,-948 # ffffffffc0204cb8 <commands+0x870>
ffffffffc0201074:	0d300593          	li	a1,211
ffffffffc0201078:	00004517          	auipc	a0,0x4
ffffffffc020107c:	c5850513          	addi	a0,a0,-936 # ffffffffc0204cd0 <commands+0x888>
ffffffffc0201080:	af4ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0201084:	00004697          	auipc	a3,0x4
ffffffffc0201088:	cc468693          	addi	a3,a3,-828 # ffffffffc0204d48 <commands+0x900>
ffffffffc020108c:	00004617          	auipc	a2,0x4
ffffffffc0201090:	c2c60613          	addi	a2,a2,-980 # ffffffffc0204cb8 <commands+0x870>
ffffffffc0201094:	0bb00593          	li	a1,187
ffffffffc0201098:	00004517          	auipc	a0,0x4
ffffffffc020109c:	c3850513          	addi	a0,a0,-968 # ffffffffc0204cd0 <commands+0x888>
ffffffffc02010a0:	ad4ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(count == 0);
ffffffffc02010a4:	00004697          	auipc	a3,0x4
ffffffffc02010a8:	f4c68693          	addi	a3,a3,-180 # ffffffffc0204ff0 <commands+0xba8>
ffffffffc02010ac:	00004617          	auipc	a2,0x4
ffffffffc02010b0:	c0c60613          	addi	a2,a2,-1012 # ffffffffc0204cb8 <commands+0x870>
ffffffffc02010b4:	12500593          	li	a1,293
ffffffffc02010b8:	00004517          	auipc	a0,0x4
ffffffffc02010bc:	c1850513          	addi	a0,a0,-1000 # ffffffffc0204cd0 <commands+0x888>
ffffffffc02010c0:	ab4ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(nr_free == 0);
ffffffffc02010c4:	00004697          	auipc	a3,0x4
ffffffffc02010c8:	dcc68693          	addi	a3,a3,-564 # ffffffffc0204e90 <commands+0xa48>
ffffffffc02010cc:	00004617          	auipc	a2,0x4
ffffffffc02010d0:	bec60613          	addi	a2,a2,-1044 # ffffffffc0204cb8 <commands+0x870>
ffffffffc02010d4:	11a00593          	li	a1,282
ffffffffc02010d8:	00004517          	auipc	a0,0x4
ffffffffc02010dc:	bf850513          	addi	a0,a0,-1032 # ffffffffc0204cd0 <commands+0x888>
ffffffffc02010e0:	a94ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02010e4:	00004697          	auipc	a3,0x4
ffffffffc02010e8:	d4c68693          	addi	a3,a3,-692 # ffffffffc0204e30 <commands+0x9e8>
ffffffffc02010ec:	00004617          	auipc	a2,0x4
ffffffffc02010f0:	bcc60613          	addi	a2,a2,-1076 # ffffffffc0204cb8 <commands+0x870>
ffffffffc02010f4:	11800593          	li	a1,280
ffffffffc02010f8:	00004517          	auipc	a0,0x4
ffffffffc02010fc:	bd850513          	addi	a0,a0,-1064 # ffffffffc0204cd0 <commands+0x888>
ffffffffc0201100:	a74ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0201104:	00004697          	auipc	a3,0x4
ffffffffc0201108:	cec68693          	addi	a3,a3,-788 # ffffffffc0204df0 <commands+0x9a8>
ffffffffc020110c:	00004617          	auipc	a2,0x4
ffffffffc0201110:	bac60613          	addi	a2,a2,-1108 # ffffffffc0204cb8 <commands+0x870>
ffffffffc0201114:	0c100593          	li	a1,193
ffffffffc0201118:	00004517          	auipc	a0,0x4
ffffffffc020111c:	bb850513          	addi	a0,a0,-1096 # ffffffffc0204cd0 <commands+0x888>
ffffffffc0201120:	a54ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0201124:	00004697          	auipc	a3,0x4
ffffffffc0201128:	e8c68693          	addi	a3,a3,-372 # ffffffffc0204fb0 <commands+0xb68>
ffffffffc020112c:	00004617          	auipc	a2,0x4
ffffffffc0201130:	b8c60613          	addi	a2,a2,-1140 # ffffffffc0204cb8 <commands+0x870>
ffffffffc0201134:	11200593          	li	a1,274
ffffffffc0201138:	00004517          	auipc	a0,0x4
ffffffffc020113c:	b9850513          	addi	a0,a0,-1128 # ffffffffc0204cd0 <commands+0x888>
ffffffffc0201140:	a34ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0201144:	00004697          	auipc	a3,0x4
ffffffffc0201148:	e4c68693          	addi	a3,a3,-436 # ffffffffc0204f90 <commands+0xb48>
ffffffffc020114c:	00004617          	auipc	a2,0x4
ffffffffc0201150:	b6c60613          	addi	a2,a2,-1172 # ffffffffc0204cb8 <commands+0x870>
ffffffffc0201154:	11000593          	li	a1,272
ffffffffc0201158:	00004517          	auipc	a0,0x4
ffffffffc020115c:	b7850513          	addi	a0,a0,-1160 # ffffffffc0204cd0 <commands+0x888>
ffffffffc0201160:	a14ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0201164:	00004697          	auipc	a3,0x4
ffffffffc0201168:	e0468693          	addi	a3,a3,-508 # ffffffffc0204f68 <commands+0xb20>
ffffffffc020116c:	00004617          	auipc	a2,0x4
ffffffffc0201170:	b4c60613          	addi	a2,a2,-1204 # ffffffffc0204cb8 <commands+0x870>
ffffffffc0201174:	10e00593          	li	a1,270
ffffffffc0201178:	00004517          	auipc	a0,0x4
ffffffffc020117c:	b5850513          	addi	a0,a0,-1192 # ffffffffc0204cd0 <commands+0x888>
ffffffffc0201180:	9f4ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0201184:	00004697          	auipc	a3,0x4
ffffffffc0201188:	dbc68693          	addi	a3,a3,-580 # ffffffffc0204f40 <commands+0xaf8>
ffffffffc020118c:	00004617          	auipc	a2,0x4
ffffffffc0201190:	b2c60613          	addi	a2,a2,-1236 # ffffffffc0204cb8 <commands+0x870>
ffffffffc0201194:	10d00593          	li	a1,269
ffffffffc0201198:	00004517          	auipc	a0,0x4
ffffffffc020119c:	b3850513          	addi	a0,a0,-1224 # ffffffffc0204cd0 <commands+0x888>
ffffffffc02011a0:	9d4ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(p0 + 2 == p1);
ffffffffc02011a4:	00004697          	auipc	a3,0x4
ffffffffc02011a8:	d8c68693          	addi	a3,a3,-628 # ffffffffc0204f30 <commands+0xae8>
ffffffffc02011ac:	00004617          	auipc	a2,0x4
ffffffffc02011b0:	b0c60613          	addi	a2,a2,-1268 # ffffffffc0204cb8 <commands+0x870>
ffffffffc02011b4:	10800593          	li	a1,264
ffffffffc02011b8:	00004517          	auipc	a0,0x4
ffffffffc02011bc:	b1850513          	addi	a0,a0,-1256 # ffffffffc0204cd0 <commands+0x888>
ffffffffc02011c0:	9b4ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02011c4:	00004697          	auipc	a3,0x4
ffffffffc02011c8:	c6c68693          	addi	a3,a3,-916 # ffffffffc0204e30 <commands+0x9e8>
ffffffffc02011cc:	00004617          	auipc	a2,0x4
ffffffffc02011d0:	aec60613          	addi	a2,a2,-1300 # ffffffffc0204cb8 <commands+0x870>
ffffffffc02011d4:	10700593          	li	a1,263
ffffffffc02011d8:	00004517          	auipc	a0,0x4
ffffffffc02011dc:	af850513          	addi	a0,a0,-1288 # ffffffffc0204cd0 <commands+0x888>
ffffffffc02011e0:	994ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc02011e4:	00004697          	auipc	a3,0x4
ffffffffc02011e8:	d2c68693          	addi	a3,a3,-724 # ffffffffc0204f10 <commands+0xac8>
ffffffffc02011ec:	00004617          	auipc	a2,0x4
ffffffffc02011f0:	acc60613          	addi	a2,a2,-1332 # ffffffffc0204cb8 <commands+0x870>
ffffffffc02011f4:	10600593          	li	a1,262
ffffffffc02011f8:	00004517          	auipc	a0,0x4
ffffffffc02011fc:	ad850513          	addi	a0,a0,-1320 # ffffffffc0204cd0 <commands+0x888>
ffffffffc0201200:	974ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0201204:	00004697          	auipc	a3,0x4
ffffffffc0201208:	cdc68693          	addi	a3,a3,-804 # ffffffffc0204ee0 <commands+0xa98>
ffffffffc020120c:	00004617          	auipc	a2,0x4
ffffffffc0201210:	aac60613          	addi	a2,a2,-1364 # ffffffffc0204cb8 <commands+0x870>
ffffffffc0201214:	10500593          	li	a1,261
ffffffffc0201218:	00004517          	auipc	a0,0x4
ffffffffc020121c:	ab850513          	addi	a0,a0,-1352 # ffffffffc0204cd0 <commands+0x888>
ffffffffc0201220:	954ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc0201224:	00004697          	auipc	a3,0x4
ffffffffc0201228:	ca468693          	addi	a3,a3,-860 # ffffffffc0204ec8 <commands+0xa80>
ffffffffc020122c:	00004617          	auipc	a2,0x4
ffffffffc0201230:	a8c60613          	addi	a2,a2,-1396 # ffffffffc0204cb8 <commands+0x870>
ffffffffc0201234:	10400593          	li	a1,260
ffffffffc0201238:	00004517          	auipc	a0,0x4
ffffffffc020123c:	a9850513          	addi	a0,a0,-1384 # ffffffffc0204cd0 <commands+0x888>
ffffffffc0201240:	934ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201244:	00004697          	auipc	a3,0x4
ffffffffc0201248:	bec68693          	addi	a3,a3,-1044 # ffffffffc0204e30 <commands+0x9e8>
ffffffffc020124c:	00004617          	auipc	a2,0x4
ffffffffc0201250:	a6c60613          	addi	a2,a2,-1428 # ffffffffc0204cb8 <commands+0x870>
ffffffffc0201254:	0fe00593          	li	a1,254
ffffffffc0201258:	00004517          	auipc	a0,0x4
ffffffffc020125c:	a7850513          	addi	a0,a0,-1416 # ffffffffc0204cd0 <commands+0x888>
ffffffffc0201260:	914ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(!PageProperty(p0));
ffffffffc0201264:	00004697          	auipc	a3,0x4
ffffffffc0201268:	c4c68693          	addi	a3,a3,-948 # ffffffffc0204eb0 <commands+0xa68>
ffffffffc020126c:	00004617          	auipc	a2,0x4
ffffffffc0201270:	a4c60613          	addi	a2,a2,-1460 # ffffffffc0204cb8 <commands+0x870>
ffffffffc0201274:	0f900593          	li	a1,249
ffffffffc0201278:	00004517          	auipc	a0,0x4
ffffffffc020127c:	a5850513          	addi	a0,a0,-1448 # ffffffffc0204cd0 <commands+0x888>
ffffffffc0201280:	8f4ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0201284:	00004697          	auipc	a3,0x4
ffffffffc0201288:	d4c68693          	addi	a3,a3,-692 # ffffffffc0204fd0 <commands+0xb88>
ffffffffc020128c:	00004617          	auipc	a2,0x4
ffffffffc0201290:	a2c60613          	addi	a2,a2,-1492 # ffffffffc0204cb8 <commands+0x870>
ffffffffc0201294:	11700593          	li	a1,279
ffffffffc0201298:	00004517          	auipc	a0,0x4
ffffffffc020129c:	a3850513          	addi	a0,a0,-1480 # ffffffffc0204cd0 <commands+0x888>
ffffffffc02012a0:	8d4ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(total == 0);
ffffffffc02012a4:	00004697          	auipc	a3,0x4
ffffffffc02012a8:	d5c68693          	addi	a3,a3,-676 # ffffffffc0205000 <commands+0xbb8>
ffffffffc02012ac:	00004617          	auipc	a2,0x4
ffffffffc02012b0:	a0c60613          	addi	a2,a2,-1524 # ffffffffc0204cb8 <commands+0x870>
ffffffffc02012b4:	12600593          	li	a1,294
ffffffffc02012b8:	00004517          	auipc	a0,0x4
ffffffffc02012bc:	a1850513          	addi	a0,a0,-1512 # ffffffffc0204cd0 <commands+0x888>
ffffffffc02012c0:	8b4ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(total == nr_free_pages());
ffffffffc02012c4:	00004697          	auipc	a3,0x4
ffffffffc02012c8:	a2468693          	addi	a3,a3,-1500 # ffffffffc0204ce8 <commands+0x8a0>
ffffffffc02012cc:	00004617          	auipc	a2,0x4
ffffffffc02012d0:	9ec60613          	addi	a2,a2,-1556 # ffffffffc0204cb8 <commands+0x870>
ffffffffc02012d4:	0f300593          	li	a1,243
ffffffffc02012d8:	00004517          	auipc	a0,0x4
ffffffffc02012dc:	9f850513          	addi	a0,a0,-1544 # ffffffffc0204cd0 <commands+0x888>
ffffffffc02012e0:	894ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc02012e4:	00004697          	auipc	a3,0x4
ffffffffc02012e8:	a4468693          	addi	a3,a3,-1468 # ffffffffc0204d28 <commands+0x8e0>
ffffffffc02012ec:	00004617          	auipc	a2,0x4
ffffffffc02012f0:	9cc60613          	addi	a2,a2,-1588 # ffffffffc0204cb8 <commands+0x870>
ffffffffc02012f4:	0ba00593          	li	a1,186
ffffffffc02012f8:	00004517          	auipc	a0,0x4
ffffffffc02012fc:	9d850513          	addi	a0,a0,-1576 # ffffffffc0204cd0 <commands+0x888>
ffffffffc0201300:	874ff0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0201304 <default_free_pages>:
default_free_pages(struct Page *base, size_t n) {
ffffffffc0201304:	1141                	addi	sp,sp,-16
ffffffffc0201306:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201308:	18058063          	beqz	a1,ffffffffc0201488 <default_free_pages+0x184>
    for (; p != base + n; p ++) {
ffffffffc020130c:	00359693          	slli	a3,a1,0x3
ffffffffc0201310:	96ae                	add	a3,a3,a1
ffffffffc0201312:	068e                	slli	a3,a3,0x3
ffffffffc0201314:	96aa                	add	a3,a3,a0
ffffffffc0201316:	02d50d63          	beq	a0,a3,ffffffffc0201350 <default_free_pages+0x4c>
ffffffffc020131a:	651c                	ld	a5,8(a0)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc020131c:	8b85                	andi	a5,a5,1
ffffffffc020131e:	14079563          	bnez	a5,ffffffffc0201468 <default_free_pages+0x164>
ffffffffc0201322:	651c                	ld	a5,8(a0)
ffffffffc0201324:	8385                	srli	a5,a5,0x1
ffffffffc0201326:	8b85                	andi	a5,a5,1
ffffffffc0201328:	14079063          	bnez	a5,ffffffffc0201468 <default_free_pages+0x164>
ffffffffc020132c:	87aa                	mv	a5,a0
ffffffffc020132e:	a809                	j	ffffffffc0201340 <default_free_pages+0x3c>
ffffffffc0201330:	6798                	ld	a4,8(a5)
ffffffffc0201332:	8b05                	andi	a4,a4,1
ffffffffc0201334:	12071a63          	bnez	a4,ffffffffc0201468 <default_free_pages+0x164>
ffffffffc0201338:	6798                	ld	a4,8(a5)
ffffffffc020133a:	8b09                	andi	a4,a4,2
ffffffffc020133c:	12071663          	bnez	a4,ffffffffc0201468 <default_free_pages+0x164>
        p->flags = 0;
ffffffffc0201340:	0007b423          	sd	zero,8(a5)
    return pa2page(PDE_ADDR(pde));
}

static inline int page_ref(struct Page *page) { return page->ref; }

static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0201344:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0201348:	04878793          	addi	a5,a5,72
ffffffffc020134c:	fed792e3          	bne	a5,a3,ffffffffc0201330 <default_free_pages+0x2c>
    base->property = n;
ffffffffc0201350:	2581                	sext.w	a1,a1
ffffffffc0201352:	cd0c                	sw	a1,24(a0)
    SetPageProperty(base);
ffffffffc0201354:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201358:	4789                	li	a5,2
ffffffffc020135a:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc020135e:	00010697          	auipc	a3,0x10
ffffffffc0201362:	12268693          	addi	a3,a3,290 # ffffffffc0211480 <free_area>
ffffffffc0201366:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0201368:	669c                	ld	a5,8(a3)
ffffffffc020136a:	9db9                	addw	a1,a1,a4
ffffffffc020136c:	00010717          	auipc	a4,0x10
ffffffffc0201370:	12b72223          	sw	a1,292(a4) # ffffffffc0211490 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc0201374:	08d78f63          	beq	a5,a3,ffffffffc0201412 <default_free_pages+0x10e>
            struct Page* page = le2page(le, page_link);
ffffffffc0201378:	fe078713          	addi	a4,a5,-32
ffffffffc020137c:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc020137e:	4801                	li	a6,0
ffffffffc0201380:	02050613          	addi	a2,a0,32
            if (base < page) {
ffffffffc0201384:	00e56a63          	bltu	a0,a4,ffffffffc0201398 <default_free_pages+0x94>
    return listelm->next;
ffffffffc0201388:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc020138a:	02d70563          	beq	a4,a3,ffffffffc02013b4 <default_free_pages+0xb0>
        while ((le = list_next(le)) != &free_list) {
ffffffffc020138e:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0201390:	fe078713          	addi	a4,a5,-32
            if (base < page) {
ffffffffc0201394:	fee57ae3          	bleu	a4,a0,ffffffffc0201388 <default_free_pages+0x84>
ffffffffc0201398:	00080663          	beqz	a6,ffffffffc02013a4 <default_free_pages+0xa0>
ffffffffc020139c:	00010817          	auipc	a6,0x10
ffffffffc02013a0:	0eb83223          	sd	a1,228(a6) # ffffffffc0211480 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc02013a4:	638c                	ld	a1,0(a5)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc02013a6:	e390                	sd	a2,0(a5)
ffffffffc02013a8:	e590                	sd	a2,8(a1)
    elm->next = next;
ffffffffc02013aa:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc02013ac:	f10c                	sd	a1,32(a0)
    if (le != &free_list) {
ffffffffc02013ae:	02d59163          	bne	a1,a3,ffffffffc02013d0 <default_free_pages+0xcc>
ffffffffc02013b2:	a091                	j	ffffffffc02013f6 <default_free_pages+0xf2>
    prev->next = next->prev = elm;
ffffffffc02013b4:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02013b6:	f514                	sd	a3,40(a0)
ffffffffc02013b8:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc02013ba:	f11c                	sd	a5,32(a0)
                list_add(le, &(base->page_link));
ffffffffc02013bc:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc02013be:	00d70563          	beq	a4,a3,ffffffffc02013c8 <default_free_pages+0xc4>
ffffffffc02013c2:	4805                	li	a6,1
ffffffffc02013c4:	87ba                	mv	a5,a4
ffffffffc02013c6:	b7e9                	j	ffffffffc0201390 <default_free_pages+0x8c>
ffffffffc02013c8:	e290                	sd	a2,0(a3)
    return listelm->prev;
ffffffffc02013ca:	85be                	mv	a1,a5
    if (le != &free_list) {
ffffffffc02013cc:	02d78163          	beq	a5,a3,ffffffffc02013ee <default_free_pages+0xea>
        if (p + p->property == base) {
ffffffffc02013d0:	ff85a803          	lw	a6,-8(a1)
        p = le2page(le, page_link);
ffffffffc02013d4:	fe058613          	addi	a2,a1,-32
        if (p + p->property == base) {
ffffffffc02013d8:	02081713          	slli	a4,a6,0x20
ffffffffc02013dc:	9301                	srli	a4,a4,0x20
ffffffffc02013de:	00371793          	slli	a5,a4,0x3
ffffffffc02013e2:	97ba                	add	a5,a5,a4
ffffffffc02013e4:	078e                	slli	a5,a5,0x3
ffffffffc02013e6:	97b2                	add	a5,a5,a2
ffffffffc02013e8:	02f50e63          	beq	a0,a5,ffffffffc0201424 <default_free_pages+0x120>
ffffffffc02013ec:	751c                	ld	a5,40(a0)
    if (le != &free_list) {
ffffffffc02013ee:	fe078713          	addi	a4,a5,-32
ffffffffc02013f2:	00d78d63          	beq	a5,a3,ffffffffc020140c <default_free_pages+0x108>
        if (base + base->property == p) {
ffffffffc02013f6:	4d0c                	lw	a1,24(a0)
ffffffffc02013f8:	02059613          	slli	a2,a1,0x20
ffffffffc02013fc:	9201                	srli	a2,a2,0x20
ffffffffc02013fe:	00361693          	slli	a3,a2,0x3
ffffffffc0201402:	96b2                	add	a3,a3,a2
ffffffffc0201404:	068e                	slli	a3,a3,0x3
ffffffffc0201406:	96aa                	add	a3,a3,a0
ffffffffc0201408:	04d70063          	beq	a4,a3,ffffffffc0201448 <default_free_pages+0x144>
}
ffffffffc020140c:	60a2                	ld	ra,8(sp)
ffffffffc020140e:	0141                	addi	sp,sp,16
ffffffffc0201410:	8082                	ret
ffffffffc0201412:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc0201414:	02050713          	addi	a4,a0,32
    prev->next = next->prev = elm;
ffffffffc0201418:	e398                	sd	a4,0(a5)
ffffffffc020141a:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc020141c:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc020141e:	f11c                	sd	a5,32(a0)
}
ffffffffc0201420:	0141                	addi	sp,sp,16
ffffffffc0201422:	8082                	ret
            p->property += base->property;
ffffffffc0201424:	4d1c                	lw	a5,24(a0)
ffffffffc0201426:	0107883b          	addw	a6,a5,a6
ffffffffc020142a:	ff05ac23          	sw	a6,-8(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc020142e:	57f5                	li	a5,-3
ffffffffc0201430:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201434:	02053803          	ld	a6,32(a0)
ffffffffc0201438:	7518                	ld	a4,40(a0)
            base = p;
ffffffffc020143a:	8532                	mv	a0,a2
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc020143c:	00e83423          	sd	a4,8(a6)
    next->prev = prev;
ffffffffc0201440:	659c                	ld	a5,8(a1)
ffffffffc0201442:	01073023          	sd	a6,0(a4)
ffffffffc0201446:	b765                	j	ffffffffc02013ee <default_free_pages+0xea>
            base->property += p->property;
ffffffffc0201448:	ff87a703          	lw	a4,-8(a5)
ffffffffc020144c:	fe878693          	addi	a3,a5,-24
ffffffffc0201450:	9db9                	addw	a1,a1,a4
ffffffffc0201452:	cd0c                	sw	a1,24(a0)
ffffffffc0201454:	5775                	li	a4,-3
ffffffffc0201456:	60e6b02f          	amoand.d	zero,a4,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc020145a:	6398                	ld	a4,0(a5)
ffffffffc020145c:	679c                	ld	a5,8(a5)
}
ffffffffc020145e:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc0201460:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0201462:	e398                	sd	a4,0(a5)
ffffffffc0201464:	0141                	addi	sp,sp,16
ffffffffc0201466:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0201468:	00004697          	auipc	a3,0x4
ffffffffc020146c:	ba868693          	addi	a3,a3,-1112 # ffffffffc0205010 <commands+0xbc8>
ffffffffc0201470:	00004617          	auipc	a2,0x4
ffffffffc0201474:	84860613          	addi	a2,a2,-1976 # ffffffffc0204cb8 <commands+0x870>
ffffffffc0201478:	08300593          	li	a1,131
ffffffffc020147c:	00004517          	auipc	a0,0x4
ffffffffc0201480:	85450513          	addi	a0,a0,-1964 # ffffffffc0204cd0 <commands+0x888>
ffffffffc0201484:	ef1fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(n > 0);
ffffffffc0201488:	00004697          	auipc	a3,0x4
ffffffffc020148c:	bb068693          	addi	a3,a3,-1104 # ffffffffc0205038 <commands+0xbf0>
ffffffffc0201490:	00004617          	auipc	a2,0x4
ffffffffc0201494:	82860613          	addi	a2,a2,-2008 # ffffffffc0204cb8 <commands+0x870>
ffffffffc0201498:	08000593          	li	a1,128
ffffffffc020149c:	00004517          	auipc	a0,0x4
ffffffffc02014a0:	83450513          	addi	a0,a0,-1996 # ffffffffc0204cd0 <commands+0x888>
ffffffffc02014a4:	ed1fe0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc02014a8 <default_alloc_pages>:
    assert(n > 0);
ffffffffc02014a8:	cd51                	beqz	a0,ffffffffc0201544 <default_alloc_pages+0x9c>
    if (n > nr_free) {
ffffffffc02014aa:	00010597          	auipc	a1,0x10
ffffffffc02014ae:	fd658593          	addi	a1,a1,-42 # ffffffffc0211480 <free_area>
ffffffffc02014b2:	0105a803          	lw	a6,16(a1)
ffffffffc02014b6:	862a                	mv	a2,a0
ffffffffc02014b8:	02081793          	slli	a5,a6,0x20
ffffffffc02014bc:	9381                	srli	a5,a5,0x20
ffffffffc02014be:	00a7ee63          	bltu	a5,a0,ffffffffc02014da <default_alloc_pages+0x32>
    list_entry_t *le = &free_list;
ffffffffc02014c2:	87ae                	mv	a5,a1
ffffffffc02014c4:	a801                	j	ffffffffc02014d4 <default_alloc_pages+0x2c>
        if (p->property >= n) {
ffffffffc02014c6:	ff87a703          	lw	a4,-8(a5)
ffffffffc02014ca:	02071693          	slli	a3,a4,0x20
ffffffffc02014ce:	9281                	srli	a3,a3,0x20
ffffffffc02014d0:	00c6f763          	bleu	a2,a3,ffffffffc02014de <default_alloc_pages+0x36>
    return listelm->next;
ffffffffc02014d4:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc02014d6:	feb798e3          	bne	a5,a1,ffffffffc02014c6 <default_alloc_pages+0x1e>
        return NULL;
ffffffffc02014da:	4501                	li	a0,0
}
ffffffffc02014dc:	8082                	ret
        struct Page *p = le2page(le, page_link);
ffffffffc02014de:	fe078513          	addi	a0,a5,-32
    if (page != NULL) {
ffffffffc02014e2:	dd6d                	beqz	a0,ffffffffc02014dc <default_alloc_pages+0x34>
    return listelm->prev;
ffffffffc02014e4:	0007b883          	ld	a7,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc02014e8:	0087b303          	ld	t1,8(a5)
    prev->next = next;
ffffffffc02014ec:	00060e1b          	sext.w	t3,a2
ffffffffc02014f0:	0068b423          	sd	t1,8(a7)
    next->prev = prev;
ffffffffc02014f4:	01133023          	sd	a7,0(t1)
        if (page->property > n) {
ffffffffc02014f8:	02d67b63          	bleu	a3,a2,ffffffffc020152e <default_alloc_pages+0x86>
            struct Page *p = page + n;
ffffffffc02014fc:	00361693          	slli	a3,a2,0x3
ffffffffc0201500:	96b2                	add	a3,a3,a2
ffffffffc0201502:	068e                	slli	a3,a3,0x3
ffffffffc0201504:	96aa                	add	a3,a3,a0
            p->property = page->property - n;
ffffffffc0201506:	41c7073b          	subw	a4,a4,t3
ffffffffc020150a:	ce98                	sw	a4,24(a3)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020150c:	00868613          	addi	a2,a3,8
ffffffffc0201510:	4709                	li	a4,2
ffffffffc0201512:	40e6302f          	amoor.d	zero,a4,(a2)
    __list_add(elm, listelm, listelm->next);
ffffffffc0201516:	0088b703          	ld	a4,8(a7)
            list_add(prev, &(p->page_link));
ffffffffc020151a:	02068613          	addi	a2,a3,32
    prev->next = next->prev = elm;
ffffffffc020151e:	0105a803          	lw	a6,16(a1)
ffffffffc0201522:	e310                	sd	a2,0(a4)
ffffffffc0201524:	00c8b423          	sd	a2,8(a7)
    elm->next = next;
ffffffffc0201528:	f698                	sd	a4,40(a3)
    elm->prev = prev;
ffffffffc020152a:	0316b023          	sd	a7,32(a3)
        nr_free -= n;
ffffffffc020152e:	41c8083b          	subw	a6,a6,t3
ffffffffc0201532:	00010717          	auipc	a4,0x10
ffffffffc0201536:	f5072f23          	sw	a6,-162(a4) # ffffffffc0211490 <free_area+0x10>
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc020153a:	5775                	li	a4,-3
ffffffffc020153c:	17a1                	addi	a5,a5,-24
ffffffffc020153e:	60e7b02f          	amoand.d	zero,a4,(a5)
ffffffffc0201542:	8082                	ret
default_alloc_pages(size_t n) {
ffffffffc0201544:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc0201546:	00004697          	auipc	a3,0x4
ffffffffc020154a:	af268693          	addi	a3,a3,-1294 # ffffffffc0205038 <commands+0xbf0>
ffffffffc020154e:	00003617          	auipc	a2,0x3
ffffffffc0201552:	76a60613          	addi	a2,a2,1898 # ffffffffc0204cb8 <commands+0x870>
ffffffffc0201556:	06200593          	li	a1,98
ffffffffc020155a:	00003517          	auipc	a0,0x3
ffffffffc020155e:	77650513          	addi	a0,a0,1910 # ffffffffc0204cd0 <commands+0x888>
default_alloc_pages(size_t n) {
ffffffffc0201562:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201564:	e11fe0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0201568 <default_init_memmap>:
default_init_memmap(struct Page *base, size_t n) {
ffffffffc0201568:	1141                	addi	sp,sp,-16
ffffffffc020156a:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc020156c:	c1fd                	beqz	a1,ffffffffc0201652 <default_init_memmap+0xea>
    for (; p != base + n; p ++) {
ffffffffc020156e:	00359693          	slli	a3,a1,0x3
ffffffffc0201572:	96ae                	add	a3,a3,a1
ffffffffc0201574:	068e                	slli	a3,a3,0x3
ffffffffc0201576:	96aa                	add	a3,a3,a0
ffffffffc0201578:	02d50463          	beq	a0,a3,ffffffffc02015a0 <default_init_memmap+0x38>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc020157c:	6518                	ld	a4,8(a0)
        assert(PageReserved(p));
ffffffffc020157e:	87aa                	mv	a5,a0
ffffffffc0201580:	8b05                	andi	a4,a4,1
ffffffffc0201582:	e709                	bnez	a4,ffffffffc020158c <default_init_memmap+0x24>
ffffffffc0201584:	a07d                	j	ffffffffc0201632 <default_init_memmap+0xca>
ffffffffc0201586:	6798                	ld	a4,8(a5)
ffffffffc0201588:	8b05                	andi	a4,a4,1
ffffffffc020158a:	c745                	beqz	a4,ffffffffc0201632 <default_init_memmap+0xca>
        p->flags = p->property = 0;
ffffffffc020158c:	0007ac23          	sw	zero,24(a5)
ffffffffc0201590:	0007b423          	sd	zero,8(a5)
ffffffffc0201594:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0201598:	04878793          	addi	a5,a5,72
ffffffffc020159c:	fed795e3          	bne	a5,a3,ffffffffc0201586 <default_init_memmap+0x1e>
    base->property = n;
ffffffffc02015a0:	2581                	sext.w	a1,a1
ffffffffc02015a2:	cd0c                	sw	a1,24(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02015a4:	4789                	li	a5,2
ffffffffc02015a6:	00850713          	addi	a4,a0,8
ffffffffc02015aa:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc02015ae:	00010697          	auipc	a3,0x10
ffffffffc02015b2:	ed268693          	addi	a3,a3,-302 # ffffffffc0211480 <free_area>
ffffffffc02015b6:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc02015b8:	669c                	ld	a5,8(a3)
ffffffffc02015ba:	9db9                	addw	a1,a1,a4
ffffffffc02015bc:	00010717          	auipc	a4,0x10
ffffffffc02015c0:	ecb72a23          	sw	a1,-300(a4) # ffffffffc0211490 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc02015c4:	04d78a63          	beq	a5,a3,ffffffffc0201618 <default_init_memmap+0xb0>
            struct Page* page = le2page(le, page_link);
ffffffffc02015c8:	fe078713          	addi	a4,a5,-32
ffffffffc02015cc:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc02015ce:	4801                	li	a6,0
ffffffffc02015d0:	02050613          	addi	a2,a0,32
            if (base < page) {
ffffffffc02015d4:	00e56a63          	bltu	a0,a4,ffffffffc02015e8 <default_init_memmap+0x80>
    return listelm->next;
ffffffffc02015d8:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc02015da:	02d70563          	beq	a4,a3,ffffffffc0201604 <default_init_memmap+0x9c>
        while ((le = list_next(le)) != &free_list) {
ffffffffc02015de:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc02015e0:	fe078713          	addi	a4,a5,-32
            if (base < page) {
ffffffffc02015e4:	fee57ae3          	bleu	a4,a0,ffffffffc02015d8 <default_init_memmap+0x70>
ffffffffc02015e8:	00080663          	beqz	a6,ffffffffc02015f4 <default_init_memmap+0x8c>
ffffffffc02015ec:	00010717          	auipc	a4,0x10
ffffffffc02015f0:	e8b73a23          	sd	a1,-364(a4) # ffffffffc0211480 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc02015f4:	6398                	ld	a4,0(a5)
}
ffffffffc02015f6:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc02015f8:	e390                	sd	a2,0(a5)
ffffffffc02015fa:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc02015fc:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc02015fe:	f118                	sd	a4,32(a0)
ffffffffc0201600:	0141                	addi	sp,sp,16
ffffffffc0201602:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0201604:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201606:	f514                	sd	a3,40(a0)
ffffffffc0201608:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc020160a:	f11c                	sd	a5,32(a0)
                list_add(le, &(base->page_link));
ffffffffc020160c:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc020160e:	00d70e63          	beq	a4,a3,ffffffffc020162a <default_init_memmap+0xc2>
ffffffffc0201612:	4805                	li	a6,1
ffffffffc0201614:	87ba                	mv	a5,a4
ffffffffc0201616:	b7e9                	j	ffffffffc02015e0 <default_init_memmap+0x78>
}
ffffffffc0201618:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc020161a:	02050713          	addi	a4,a0,32
    prev->next = next->prev = elm;
ffffffffc020161e:	e398                	sd	a4,0(a5)
ffffffffc0201620:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc0201622:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc0201624:	f11c                	sd	a5,32(a0)
}
ffffffffc0201626:	0141                	addi	sp,sp,16
ffffffffc0201628:	8082                	ret
ffffffffc020162a:	60a2                	ld	ra,8(sp)
ffffffffc020162c:	e290                	sd	a2,0(a3)
ffffffffc020162e:	0141                	addi	sp,sp,16
ffffffffc0201630:	8082                	ret
        assert(PageReserved(p));
ffffffffc0201632:	00004697          	auipc	a3,0x4
ffffffffc0201636:	a0e68693          	addi	a3,a3,-1522 # ffffffffc0205040 <commands+0xbf8>
ffffffffc020163a:	00003617          	auipc	a2,0x3
ffffffffc020163e:	67e60613          	addi	a2,a2,1662 # ffffffffc0204cb8 <commands+0x870>
ffffffffc0201642:	04900593          	li	a1,73
ffffffffc0201646:	00003517          	auipc	a0,0x3
ffffffffc020164a:	68a50513          	addi	a0,a0,1674 # ffffffffc0204cd0 <commands+0x888>
ffffffffc020164e:	d27fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(n > 0);
ffffffffc0201652:	00004697          	auipc	a3,0x4
ffffffffc0201656:	9e668693          	addi	a3,a3,-1562 # ffffffffc0205038 <commands+0xbf0>
ffffffffc020165a:	00003617          	auipc	a2,0x3
ffffffffc020165e:	65e60613          	addi	a2,a2,1630 # ffffffffc0204cb8 <commands+0x870>
ffffffffc0201662:	04600593          	li	a1,70
ffffffffc0201666:	00003517          	auipc	a0,0x3
ffffffffc020166a:	66a50513          	addi	a0,a0,1642 # ffffffffc0204cd0 <commands+0x888>
ffffffffc020166e:	d07fe0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0201672 <pa2page.part.4>:
static inline struct Page *pa2page(uintptr_t pa) {
ffffffffc0201672:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc0201674:	00004617          	auipc	a2,0x4
ffffffffc0201678:	aa460613          	addi	a2,a2,-1372 # ffffffffc0205118 <default_pmm_manager+0xc8>
ffffffffc020167c:	06500593          	li	a1,101
ffffffffc0201680:	00004517          	auipc	a0,0x4
ffffffffc0201684:	ab850513          	addi	a0,a0,-1352 # ffffffffc0205138 <default_pmm_manager+0xe8>
static inline struct Page *pa2page(uintptr_t pa) {
ffffffffc0201688:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc020168a:	cebfe0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc020168e <alloc_pages>:
    pmm_manager->init_memmap(base, n);
}

// alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE
// memory
struct Page *alloc_pages(size_t n) {
ffffffffc020168e:	715d                	addi	sp,sp,-80
ffffffffc0201690:	e0a2                	sd	s0,64(sp)
ffffffffc0201692:	fc26                	sd	s1,56(sp)
ffffffffc0201694:	f84a                	sd	s2,48(sp)
ffffffffc0201696:	f44e                	sd	s3,40(sp)
ffffffffc0201698:	f052                	sd	s4,32(sp)
ffffffffc020169a:	ec56                	sd	s5,24(sp)
ffffffffc020169c:	e486                	sd	ra,72(sp)
ffffffffc020169e:	842a                	mv	s0,a0
ffffffffc02016a0:	00010497          	auipc	s1,0x10
ffffffffc02016a4:	df848493          	addi	s1,s1,-520 # ffffffffc0211498 <pmm_manager>
    while (1) {
        local_intr_save(intr_flag);
        { page = pmm_manager->alloc_pages(n); }
        local_intr_restore(intr_flag);

        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc02016a8:	4985                	li	s3,1
ffffffffc02016aa:	00010a17          	auipc	s4,0x10
ffffffffc02016ae:	dc6a0a13          	addi	s4,s4,-570 # ffffffffc0211470 <swap_init_ok>

        extern struct mm_struct *check_mm_struct;
        // cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
        swap_out(check_mm_struct, n, 0);
ffffffffc02016b2:	0005091b          	sext.w	s2,a0
ffffffffc02016b6:	00010a97          	auipc	s5,0x10
ffffffffc02016ba:	ee2a8a93          	addi	s5,s5,-286 # ffffffffc0211598 <check_mm_struct>
ffffffffc02016be:	a00d                	j	ffffffffc02016e0 <alloc_pages+0x52>
        { page = pmm_manager->alloc_pages(n); }
ffffffffc02016c0:	609c                	ld	a5,0(s1)
ffffffffc02016c2:	6f9c                	ld	a5,24(a5)
ffffffffc02016c4:	9782                	jalr	a5
        swap_out(check_mm_struct, n, 0);
ffffffffc02016c6:	4601                	li	a2,0
ffffffffc02016c8:	85ca                	mv	a1,s2
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc02016ca:	ed0d                	bnez	a0,ffffffffc0201704 <alloc_pages+0x76>
ffffffffc02016cc:	0289ec63          	bltu	s3,s0,ffffffffc0201704 <alloc_pages+0x76>
ffffffffc02016d0:	000a2783          	lw	a5,0(s4)
ffffffffc02016d4:	2781                	sext.w	a5,a5
ffffffffc02016d6:	c79d                	beqz	a5,ffffffffc0201704 <alloc_pages+0x76>
        swap_out(check_mm_struct, n, 0);
ffffffffc02016d8:	000ab503          	ld	a0,0(s5)
ffffffffc02016dc:	021010ef          	jal	ra,ffffffffc0202efc <swap_out>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02016e0:	100027f3          	csrr	a5,sstatus
ffffffffc02016e4:	8b89                	andi	a5,a5,2
        { page = pmm_manager->alloc_pages(n); }
ffffffffc02016e6:	8522                	mv	a0,s0
ffffffffc02016e8:	dfe1                	beqz	a5,ffffffffc02016c0 <alloc_pages+0x32>
        intr_disable();
ffffffffc02016ea:	e11fe0ef          	jal	ra,ffffffffc02004fa <intr_disable>
ffffffffc02016ee:	609c                	ld	a5,0(s1)
ffffffffc02016f0:	8522                	mv	a0,s0
ffffffffc02016f2:	6f9c                	ld	a5,24(a5)
ffffffffc02016f4:	9782                	jalr	a5
ffffffffc02016f6:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc02016f8:	dfdfe0ef          	jal	ra,ffffffffc02004f4 <intr_enable>
ffffffffc02016fc:	6522                	ld	a0,8(sp)
        swap_out(check_mm_struct, n, 0);
ffffffffc02016fe:	4601                	li	a2,0
ffffffffc0201700:	85ca                	mv	a1,s2
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0201702:	d569                	beqz	a0,ffffffffc02016cc <alloc_pages+0x3e>
    }
    // cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
}
ffffffffc0201704:	60a6                	ld	ra,72(sp)
ffffffffc0201706:	6406                	ld	s0,64(sp)
ffffffffc0201708:	74e2                	ld	s1,56(sp)
ffffffffc020170a:	7942                	ld	s2,48(sp)
ffffffffc020170c:	79a2                	ld	s3,40(sp)
ffffffffc020170e:	7a02                	ld	s4,32(sp)
ffffffffc0201710:	6ae2                	ld	s5,24(sp)
ffffffffc0201712:	6161                	addi	sp,sp,80
ffffffffc0201714:	8082                	ret

ffffffffc0201716 <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201716:	100027f3          	csrr	a5,sstatus
ffffffffc020171a:	8b89                	andi	a5,a5,2
ffffffffc020171c:	eb89                	bnez	a5,ffffffffc020172e <free_pages+0x18>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;

    local_intr_save(intr_flag);
    { pmm_manager->free_pages(base, n); }
ffffffffc020171e:	00010797          	auipc	a5,0x10
ffffffffc0201722:	d7a78793          	addi	a5,a5,-646 # ffffffffc0211498 <pmm_manager>
ffffffffc0201726:	639c                	ld	a5,0(a5)
ffffffffc0201728:	0207b303          	ld	t1,32(a5)
ffffffffc020172c:	8302                	jr	t1
void free_pages(struct Page *base, size_t n) {
ffffffffc020172e:	1101                	addi	sp,sp,-32
ffffffffc0201730:	ec06                	sd	ra,24(sp)
ffffffffc0201732:	e822                	sd	s0,16(sp)
ffffffffc0201734:	e426                	sd	s1,8(sp)
ffffffffc0201736:	842a                	mv	s0,a0
ffffffffc0201738:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc020173a:	dc1fe0ef          	jal	ra,ffffffffc02004fa <intr_disable>
    { pmm_manager->free_pages(base, n); }
ffffffffc020173e:	00010797          	auipc	a5,0x10
ffffffffc0201742:	d5a78793          	addi	a5,a5,-678 # ffffffffc0211498 <pmm_manager>
ffffffffc0201746:	639c                	ld	a5,0(a5)
ffffffffc0201748:	85a6                	mv	a1,s1
ffffffffc020174a:	8522                	mv	a0,s0
ffffffffc020174c:	739c                	ld	a5,32(a5)
ffffffffc020174e:	9782                	jalr	a5
    local_intr_restore(intr_flag);
}
ffffffffc0201750:	6442                	ld	s0,16(sp)
ffffffffc0201752:	60e2                	ld	ra,24(sp)
ffffffffc0201754:	64a2                	ld	s1,8(sp)
ffffffffc0201756:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0201758:	d9dfe06f          	j	ffffffffc02004f4 <intr_enable>

ffffffffc020175c <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020175c:	100027f3          	csrr	a5,sstatus
ffffffffc0201760:	8b89                	andi	a5,a5,2
ffffffffc0201762:	eb89                	bnez	a5,ffffffffc0201774 <nr_free_pages+0x18>
// of current free memory
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc0201764:	00010797          	auipc	a5,0x10
ffffffffc0201768:	d3478793          	addi	a5,a5,-716 # ffffffffc0211498 <pmm_manager>
ffffffffc020176c:	639c                	ld	a5,0(a5)
ffffffffc020176e:	0287b303          	ld	t1,40(a5)
ffffffffc0201772:	8302                	jr	t1
size_t nr_free_pages(void) {
ffffffffc0201774:	1141                	addi	sp,sp,-16
ffffffffc0201776:	e406                	sd	ra,8(sp)
ffffffffc0201778:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc020177a:	d81fe0ef          	jal	ra,ffffffffc02004fa <intr_disable>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc020177e:	00010797          	auipc	a5,0x10
ffffffffc0201782:	d1a78793          	addi	a5,a5,-742 # ffffffffc0211498 <pmm_manager>
ffffffffc0201786:	639c                	ld	a5,0(a5)
ffffffffc0201788:	779c                	ld	a5,40(a5)
ffffffffc020178a:	9782                	jalr	a5
ffffffffc020178c:	842a                	mv	s0,a0
        intr_enable();
ffffffffc020178e:	d67fe0ef          	jal	ra,ffffffffc02004f4 <intr_enable>
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc0201792:	8522                	mv	a0,s0
ffffffffc0201794:	60a2                	ld	ra,8(sp)
ffffffffc0201796:	6402                	ld	s0,0(sp)
ffffffffc0201798:	0141                	addi	sp,sp,16
ffffffffc020179a:	8082                	ret

ffffffffc020179c <get_pte>:
// parameter:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc020179c:	715d                	addi	sp,sp,-80
ffffffffc020179e:	fc26                	sd	s1,56(sp)
     *   PTE_W           0x002                   // page table/directory entry
     * flags bit : Writeable
     *   PTE_U           0x004                   // page table/directory entry
     * flags bit : User can access
     */
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc02017a0:	01e5d493          	srli	s1,a1,0x1e
ffffffffc02017a4:	1ff4f493          	andi	s1,s1,511
ffffffffc02017a8:	048e                	slli	s1,s1,0x3
ffffffffc02017aa:	94aa                	add	s1,s1,a0
    if (!(*pdep1 & PTE_V)) {
ffffffffc02017ac:	6094                	ld	a3,0(s1)
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc02017ae:	f84a                	sd	s2,48(sp)
ffffffffc02017b0:	f44e                	sd	s3,40(sp)
ffffffffc02017b2:	f052                	sd	s4,32(sp)
ffffffffc02017b4:	e486                	sd	ra,72(sp)
ffffffffc02017b6:	e0a2                	sd	s0,64(sp)
ffffffffc02017b8:	ec56                	sd	s5,24(sp)
ffffffffc02017ba:	e85a                	sd	s6,16(sp)
ffffffffc02017bc:	e45e                	sd	s7,8(sp)
    if (!(*pdep1 & PTE_V)) {
ffffffffc02017be:	0016f793          	andi	a5,a3,1
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc02017c2:	892e                	mv	s2,a1
ffffffffc02017c4:	8a32                	mv	s4,a2
ffffffffc02017c6:	00010997          	auipc	s3,0x10
ffffffffc02017ca:	c9a98993          	addi	s3,s3,-870 # ffffffffc0211460 <npage>
    if (!(*pdep1 & PTE_V)) {
ffffffffc02017ce:	e3c9                	bnez	a5,ffffffffc0201850 <get_pte+0xb4>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc02017d0:	16060163          	beqz	a2,ffffffffc0201932 <get_pte+0x196>
ffffffffc02017d4:	4505                	li	a0,1
ffffffffc02017d6:	eb9ff0ef          	jal	ra,ffffffffc020168e <alloc_pages>
ffffffffc02017da:	842a                	mv	s0,a0
ffffffffc02017dc:	14050b63          	beqz	a0,ffffffffc0201932 <get_pte+0x196>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02017e0:	00010b97          	auipc	s7,0x10
ffffffffc02017e4:	cd0b8b93          	addi	s7,s7,-816 # ffffffffc02114b0 <pages>
ffffffffc02017e8:	000bb503          	ld	a0,0(s7)
ffffffffc02017ec:	00003797          	auipc	a5,0x3
ffffffffc02017f0:	4b478793          	addi	a5,a5,1204 # ffffffffc0204ca0 <commands+0x858>
ffffffffc02017f4:	0007bb03          	ld	s6,0(a5)
ffffffffc02017f8:	40a40533          	sub	a0,s0,a0
ffffffffc02017fc:	850d                	srai	a0,a0,0x3
ffffffffc02017fe:	03650533          	mul	a0,a0,s6
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0201802:	4785                	li	a5,1
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201804:	00010997          	auipc	s3,0x10
ffffffffc0201808:	c5c98993          	addi	s3,s3,-932 # ffffffffc0211460 <npage>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc020180c:	00080ab7          	lui	s5,0x80
ffffffffc0201810:	0009b703          	ld	a4,0(s3)
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0201814:	c01c                	sw	a5,0(s0)
ffffffffc0201816:	57fd                	li	a5,-1
ffffffffc0201818:	83b1                	srli	a5,a5,0xc
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc020181a:	9556                	add	a0,a0,s5
ffffffffc020181c:	8fe9                	and	a5,a5,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc020181e:	0532                	slli	a0,a0,0xc
ffffffffc0201820:	16e7f063          	bleu	a4,a5,ffffffffc0201980 <get_pte+0x1e4>
ffffffffc0201824:	00010797          	auipc	a5,0x10
ffffffffc0201828:	c7c78793          	addi	a5,a5,-900 # ffffffffc02114a0 <va_pa_offset>
ffffffffc020182c:	639c                	ld	a5,0(a5)
ffffffffc020182e:	6605                	lui	a2,0x1
ffffffffc0201830:	4581                	li	a1,0
ffffffffc0201832:	953e                	add	a0,a0,a5
ffffffffc0201834:	2c1020ef          	jal	ra,ffffffffc02042f4 <memset>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201838:	000bb683          	ld	a3,0(s7)
ffffffffc020183c:	40d406b3          	sub	a3,s0,a3
ffffffffc0201840:	868d                	srai	a3,a3,0x3
ffffffffc0201842:	036686b3          	mul	a3,a3,s6
ffffffffc0201846:	96d6                	add	a3,a3,s5

static inline void flush_tlb() { asm volatile("sfence.vma"); }

// construct PTE from a page and permission bits
static inline pte_t pte_create(uintptr_t ppn, int type) {
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0201848:	06aa                	slli	a3,a3,0xa
ffffffffc020184a:	0116e693          	ori	a3,a3,17
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc020184e:	e094                	sd	a3,0(s1)
    }
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0201850:	77fd                	lui	a5,0xfffff
ffffffffc0201852:	068a                	slli	a3,a3,0x2
ffffffffc0201854:	0009b703          	ld	a4,0(s3)
ffffffffc0201858:	8efd                	and	a3,a3,a5
ffffffffc020185a:	00c6d793          	srli	a5,a3,0xc
ffffffffc020185e:	0ce7fc63          	bleu	a4,a5,ffffffffc0201936 <get_pte+0x19a>
ffffffffc0201862:	00010a97          	auipc	s5,0x10
ffffffffc0201866:	c3ea8a93          	addi	s5,s5,-962 # ffffffffc02114a0 <va_pa_offset>
ffffffffc020186a:	000ab403          	ld	s0,0(s5)
ffffffffc020186e:	01595793          	srli	a5,s2,0x15
ffffffffc0201872:	1ff7f793          	andi	a5,a5,511
ffffffffc0201876:	96a2                	add	a3,a3,s0
ffffffffc0201878:	00379413          	slli	s0,a5,0x3
ffffffffc020187c:	9436                	add	s0,s0,a3
//    pde_t *pdep0 = &((pde_t *)(PDE_ADDR(*pdep1)))[PDX0(la)];
    if (!(*pdep0 & PTE_V)) {
ffffffffc020187e:	6014                	ld	a3,0(s0)
ffffffffc0201880:	0016f793          	andi	a5,a3,1
ffffffffc0201884:	ebbd                	bnez	a5,ffffffffc02018fa <get_pte+0x15e>
    	struct Page *page;
    	if (!create || (page = alloc_page()) == NULL) {
ffffffffc0201886:	0a0a0663          	beqz	s4,ffffffffc0201932 <get_pte+0x196>
ffffffffc020188a:	4505                	li	a0,1
ffffffffc020188c:	e03ff0ef          	jal	ra,ffffffffc020168e <alloc_pages>
ffffffffc0201890:	84aa                	mv	s1,a0
ffffffffc0201892:	c145                	beqz	a0,ffffffffc0201932 <get_pte+0x196>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201894:	00010b97          	auipc	s7,0x10
ffffffffc0201898:	c1cb8b93          	addi	s7,s7,-996 # ffffffffc02114b0 <pages>
ffffffffc020189c:	000bb503          	ld	a0,0(s7)
ffffffffc02018a0:	00003797          	auipc	a5,0x3
ffffffffc02018a4:	40078793          	addi	a5,a5,1024 # ffffffffc0204ca0 <commands+0x858>
ffffffffc02018a8:	0007bb03          	ld	s6,0(a5)
ffffffffc02018ac:	40a48533          	sub	a0,s1,a0
ffffffffc02018b0:	850d                	srai	a0,a0,0x3
ffffffffc02018b2:	03650533          	mul	a0,a0,s6
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc02018b6:	4785                	li	a5,1
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02018b8:	00080a37          	lui	s4,0x80
    		return NULL;
    	}
    	set_page_ref(page, 1);
    	uintptr_t pa = page2pa(page);
    	memset(KADDR(pa), 0, PGSIZE);
ffffffffc02018bc:	0009b703          	ld	a4,0(s3)
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc02018c0:	c09c                	sw	a5,0(s1)
ffffffffc02018c2:	57fd                	li	a5,-1
ffffffffc02018c4:	83b1                	srli	a5,a5,0xc
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02018c6:	9552                	add	a0,a0,s4
ffffffffc02018c8:	8fe9                	and	a5,a5,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc02018ca:	0532                	slli	a0,a0,0xc
ffffffffc02018cc:	08e7fd63          	bleu	a4,a5,ffffffffc0201966 <get_pte+0x1ca>
ffffffffc02018d0:	000ab783          	ld	a5,0(s5)
ffffffffc02018d4:	6605                	lui	a2,0x1
ffffffffc02018d6:	4581                	li	a1,0
ffffffffc02018d8:	953e                	add	a0,a0,a5
ffffffffc02018da:	21b020ef          	jal	ra,ffffffffc02042f4 <memset>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02018de:	000bb683          	ld	a3,0(s7)
ffffffffc02018e2:	40d486b3          	sub	a3,s1,a3
ffffffffc02018e6:	868d                	srai	a3,a3,0x3
ffffffffc02018e8:	036686b3          	mul	a3,a3,s6
ffffffffc02018ec:	96d2                	add	a3,a3,s4
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc02018ee:	06aa                	slli	a3,a3,0xa
ffffffffc02018f0:	0116e693          	ori	a3,a3,17
 //   	memset(pa, 0, PGSIZE);
    	*pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc02018f4:	e014                	sd	a3,0(s0)
ffffffffc02018f6:	0009b703          	ld	a4,0(s3)
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc02018fa:	068a                	slli	a3,a3,0x2
ffffffffc02018fc:	757d                	lui	a0,0xfffff
ffffffffc02018fe:	8ee9                	and	a3,a3,a0
ffffffffc0201900:	00c6d793          	srli	a5,a3,0xc
ffffffffc0201904:	04e7f563          	bleu	a4,a5,ffffffffc020194e <get_pte+0x1b2>
ffffffffc0201908:	000ab503          	ld	a0,0(s5)
ffffffffc020190c:	00c95793          	srli	a5,s2,0xc
ffffffffc0201910:	1ff7f793          	andi	a5,a5,511
ffffffffc0201914:	96aa                	add	a3,a3,a0
ffffffffc0201916:	00379513          	slli	a0,a5,0x3
ffffffffc020191a:	9536                	add	a0,a0,a3
}
ffffffffc020191c:	60a6                	ld	ra,72(sp)
ffffffffc020191e:	6406                	ld	s0,64(sp)
ffffffffc0201920:	74e2                	ld	s1,56(sp)
ffffffffc0201922:	7942                	ld	s2,48(sp)
ffffffffc0201924:	79a2                	ld	s3,40(sp)
ffffffffc0201926:	7a02                	ld	s4,32(sp)
ffffffffc0201928:	6ae2                	ld	s5,24(sp)
ffffffffc020192a:	6b42                	ld	s6,16(sp)
ffffffffc020192c:	6ba2                	ld	s7,8(sp)
ffffffffc020192e:	6161                	addi	sp,sp,80
ffffffffc0201930:	8082                	ret
            return NULL;
ffffffffc0201932:	4501                	li	a0,0
ffffffffc0201934:	b7e5                	j	ffffffffc020191c <get_pte+0x180>
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0201936:	00003617          	auipc	a2,0x3
ffffffffc020193a:	76a60613          	addi	a2,a2,1898 # ffffffffc02050a0 <default_pmm_manager+0x50>
ffffffffc020193e:	10200593          	li	a1,258
ffffffffc0201942:	00003517          	auipc	a0,0x3
ffffffffc0201946:	78650513          	addi	a0,a0,1926 # ffffffffc02050c8 <default_pmm_manager+0x78>
ffffffffc020194a:	a2bfe0ef          	jal	ra,ffffffffc0200374 <__panic>
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc020194e:	00003617          	auipc	a2,0x3
ffffffffc0201952:	75260613          	addi	a2,a2,1874 # ffffffffc02050a0 <default_pmm_manager+0x50>
ffffffffc0201956:	10f00593          	li	a1,271
ffffffffc020195a:	00003517          	auipc	a0,0x3
ffffffffc020195e:	76e50513          	addi	a0,a0,1902 # ffffffffc02050c8 <default_pmm_manager+0x78>
ffffffffc0201962:	a13fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    	memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201966:	86aa                	mv	a3,a0
ffffffffc0201968:	00003617          	auipc	a2,0x3
ffffffffc020196c:	73860613          	addi	a2,a2,1848 # ffffffffc02050a0 <default_pmm_manager+0x50>
ffffffffc0201970:	10b00593          	li	a1,267
ffffffffc0201974:	00003517          	auipc	a0,0x3
ffffffffc0201978:	75450513          	addi	a0,a0,1876 # ffffffffc02050c8 <default_pmm_manager+0x78>
ffffffffc020197c:	9f9fe0ef          	jal	ra,ffffffffc0200374 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201980:	86aa                	mv	a3,a0
ffffffffc0201982:	00003617          	auipc	a2,0x3
ffffffffc0201986:	71e60613          	addi	a2,a2,1822 # ffffffffc02050a0 <default_pmm_manager+0x50>
ffffffffc020198a:	0ff00593          	li	a1,255
ffffffffc020198e:	00003517          	auipc	a0,0x3
ffffffffc0201992:	73a50513          	addi	a0,a0,1850 # ffffffffc02050c8 <default_pmm_manager+0x78>
ffffffffc0201996:	9dffe0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc020199a <get_page>:

// get_page - get related Page struct for linear address la using PDT pgdir
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc020199a:	1141                	addi	sp,sp,-16
ffffffffc020199c:	e022                	sd	s0,0(sp)
ffffffffc020199e:	8432                	mv	s0,a2
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc02019a0:	4601                	li	a2,0
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc02019a2:	e406                	sd	ra,8(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc02019a4:	df9ff0ef          	jal	ra,ffffffffc020179c <get_pte>
    if (ptep_store != NULL) {
ffffffffc02019a8:	c011                	beqz	s0,ffffffffc02019ac <get_page+0x12>
        *ptep_store = ptep;
ffffffffc02019aa:	e008                	sd	a0,0(s0)
    }
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc02019ac:	c521                	beqz	a0,ffffffffc02019f4 <get_page+0x5a>
ffffffffc02019ae:	611c                	ld	a5,0(a0)
        return pte2page(*ptep);
    }
    return NULL;
ffffffffc02019b0:	4501                	li	a0,0
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc02019b2:	0017f713          	andi	a4,a5,1
ffffffffc02019b6:	e709                	bnez	a4,ffffffffc02019c0 <get_page+0x26>
}
ffffffffc02019b8:	60a2                	ld	ra,8(sp)
ffffffffc02019ba:	6402                	ld	s0,0(sp)
ffffffffc02019bc:	0141                	addi	sp,sp,16
ffffffffc02019be:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc02019c0:	00010717          	auipc	a4,0x10
ffffffffc02019c4:	aa070713          	addi	a4,a4,-1376 # ffffffffc0211460 <npage>
ffffffffc02019c8:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc02019ca:	078a                	slli	a5,a5,0x2
ffffffffc02019cc:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02019ce:	02e7f863          	bleu	a4,a5,ffffffffc02019fe <get_page+0x64>
    return &pages[PPN(pa) - nbase];
ffffffffc02019d2:	fff80537          	lui	a0,0xfff80
ffffffffc02019d6:	97aa                	add	a5,a5,a0
ffffffffc02019d8:	00010697          	auipc	a3,0x10
ffffffffc02019dc:	ad868693          	addi	a3,a3,-1320 # ffffffffc02114b0 <pages>
ffffffffc02019e0:	6288                	ld	a0,0(a3)
ffffffffc02019e2:	60a2                	ld	ra,8(sp)
ffffffffc02019e4:	6402                	ld	s0,0(sp)
ffffffffc02019e6:	00379713          	slli	a4,a5,0x3
ffffffffc02019ea:	97ba                	add	a5,a5,a4
ffffffffc02019ec:	078e                	slli	a5,a5,0x3
ffffffffc02019ee:	953e                	add	a0,a0,a5
ffffffffc02019f0:	0141                	addi	sp,sp,16
ffffffffc02019f2:	8082                	ret
ffffffffc02019f4:	60a2                	ld	ra,8(sp)
ffffffffc02019f6:	6402                	ld	s0,0(sp)
    return NULL;
ffffffffc02019f8:	4501                	li	a0,0
}
ffffffffc02019fa:	0141                	addi	sp,sp,16
ffffffffc02019fc:	8082                	ret
ffffffffc02019fe:	c75ff0ef          	jal	ra,ffffffffc0201672 <pa2page.part.4>

ffffffffc0201a02 <page_remove>:
    }
}

// page_remove - free an Page which is related linear address la and has an
// validated pte
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0201a02:	1141                	addi	sp,sp,-16
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201a04:	4601                	li	a2,0
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0201a06:	e406                	sd	ra,8(sp)
ffffffffc0201a08:	e022                	sd	s0,0(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201a0a:	d93ff0ef          	jal	ra,ffffffffc020179c <get_pte>
    if (ptep != NULL) {
ffffffffc0201a0e:	c511                	beqz	a0,ffffffffc0201a1a <page_remove+0x18>
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc0201a10:	611c                	ld	a5,0(a0)
ffffffffc0201a12:	842a                	mv	s0,a0
ffffffffc0201a14:	0017f713          	andi	a4,a5,1
ffffffffc0201a18:	e709                	bnez	a4,ffffffffc0201a22 <page_remove+0x20>
        page_remove_pte(pgdir, la, ptep);
    }
}
ffffffffc0201a1a:	60a2                	ld	ra,8(sp)
ffffffffc0201a1c:	6402                	ld	s0,0(sp)
ffffffffc0201a1e:	0141                	addi	sp,sp,16
ffffffffc0201a20:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc0201a22:	00010717          	auipc	a4,0x10
ffffffffc0201a26:	a3e70713          	addi	a4,a4,-1474 # ffffffffc0211460 <npage>
ffffffffc0201a2a:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc0201a2c:	078a                	slli	a5,a5,0x2
ffffffffc0201a2e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201a30:	04e7f063          	bleu	a4,a5,ffffffffc0201a70 <page_remove+0x6e>
    return &pages[PPN(pa) - nbase];
ffffffffc0201a34:	fff80737          	lui	a4,0xfff80
ffffffffc0201a38:	97ba                	add	a5,a5,a4
ffffffffc0201a3a:	00010717          	auipc	a4,0x10
ffffffffc0201a3e:	a7670713          	addi	a4,a4,-1418 # ffffffffc02114b0 <pages>
ffffffffc0201a42:	6308                	ld	a0,0(a4)
ffffffffc0201a44:	00379713          	slli	a4,a5,0x3
ffffffffc0201a48:	97ba                	add	a5,a5,a4
ffffffffc0201a4a:	078e                	slli	a5,a5,0x3
ffffffffc0201a4c:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc0201a4e:	411c                	lw	a5,0(a0)
ffffffffc0201a50:	fff7871b          	addiw	a4,a5,-1
ffffffffc0201a54:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc0201a56:	cb09                	beqz	a4,ffffffffc0201a68 <page_remove+0x66>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc0201a58:	00043023          	sd	zero,0(s0)
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc0201a5c:	12000073          	sfence.vma
}
ffffffffc0201a60:	60a2                	ld	ra,8(sp)
ffffffffc0201a62:	6402                	ld	s0,0(sp)
ffffffffc0201a64:	0141                	addi	sp,sp,16
ffffffffc0201a66:	8082                	ret
            free_page(page);
ffffffffc0201a68:	4585                	li	a1,1
ffffffffc0201a6a:	cadff0ef          	jal	ra,ffffffffc0201716 <free_pages>
ffffffffc0201a6e:	b7ed                	j	ffffffffc0201a58 <page_remove+0x56>
ffffffffc0201a70:	c03ff0ef          	jal	ra,ffffffffc0201672 <pa2page.part.4>

ffffffffc0201a74 <page_insert>:
//  page:  the Page which need to map
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
// note: PT is changed, so the TLB need to be invalidate
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0201a74:	7179                	addi	sp,sp,-48
ffffffffc0201a76:	87b2                	mv	a5,a2
ffffffffc0201a78:	f022                	sd	s0,32(sp)
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0201a7a:	4605                	li	a2,1
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0201a7c:	842e                	mv	s0,a1
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0201a7e:	85be                	mv	a1,a5
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0201a80:	ec26                	sd	s1,24(sp)
ffffffffc0201a82:	f406                	sd	ra,40(sp)
ffffffffc0201a84:	e84a                	sd	s2,16(sp)
ffffffffc0201a86:	e44e                	sd	s3,8(sp)
ffffffffc0201a88:	84b6                	mv	s1,a3
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0201a8a:	d13ff0ef          	jal	ra,ffffffffc020179c <get_pte>
    if (ptep == NULL) {
ffffffffc0201a8e:	c945                	beqz	a0,ffffffffc0201b3e <page_insert+0xca>
    page->ref += 1;
ffffffffc0201a90:	4014                	lw	a3,0(s0)
        return -E_NO_MEM;
    }
    page_ref_inc(page);
    if (*ptep & PTE_V) {
ffffffffc0201a92:	611c                	ld	a5,0(a0)
ffffffffc0201a94:	892a                	mv	s2,a0
ffffffffc0201a96:	0016871b          	addiw	a4,a3,1
ffffffffc0201a9a:	c018                	sw	a4,0(s0)
ffffffffc0201a9c:	0017f713          	andi	a4,a5,1
ffffffffc0201aa0:	e339                	bnez	a4,ffffffffc0201ae6 <page_insert+0x72>
ffffffffc0201aa2:	00010797          	auipc	a5,0x10
ffffffffc0201aa6:	a0e78793          	addi	a5,a5,-1522 # ffffffffc02114b0 <pages>
ffffffffc0201aaa:	639c                	ld	a5,0(a5)
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201aac:	00003717          	auipc	a4,0x3
ffffffffc0201ab0:	1f470713          	addi	a4,a4,500 # ffffffffc0204ca0 <commands+0x858>
ffffffffc0201ab4:	40f407b3          	sub	a5,s0,a5
ffffffffc0201ab8:	6300                	ld	s0,0(a4)
ffffffffc0201aba:	878d                	srai	a5,a5,0x3
ffffffffc0201abc:	000806b7          	lui	a3,0x80
ffffffffc0201ac0:	028787b3          	mul	a5,a5,s0
ffffffffc0201ac4:	97b6                	add	a5,a5,a3
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0201ac6:	07aa                	slli	a5,a5,0xa
ffffffffc0201ac8:	8fc5                	or	a5,a5,s1
ffffffffc0201aca:	0017e793          	ori	a5,a5,1
            page_ref_dec(page);
        } else {
            page_remove_pte(pgdir, la, ptep);
        }
    }
    *ptep = pte_create(page2ppn(page), PTE_V | perm);
ffffffffc0201ace:	00f93023          	sd	a5,0(s2)
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc0201ad2:	12000073          	sfence.vma
    tlb_invalidate(pgdir, la);
    return 0;
ffffffffc0201ad6:	4501                	li	a0,0
}
ffffffffc0201ad8:	70a2                	ld	ra,40(sp)
ffffffffc0201ada:	7402                	ld	s0,32(sp)
ffffffffc0201adc:	64e2                	ld	s1,24(sp)
ffffffffc0201ade:	6942                	ld	s2,16(sp)
ffffffffc0201ae0:	69a2                	ld	s3,8(sp)
ffffffffc0201ae2:	6145                	addi	sp,sp,48
ffffffffc0201ae4:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc0201ae6:	00010717          	auipc	a4,0x10
ffffffffc0201aea:	97a70713          	addi	a4,a4,-1670 # ffffffffc0211460 <npage>
ffffffffc0201aee:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc0201af0:	00279513          	slli	a0,a5,0x2
ffffffffc0201af4:	8131                	srli	a0,a0,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201af6:	04e57663          	bleu	a4,a0,ffffffffc0201b42 <page_insert+0xce>
    return &pages[PPN(pa) - nbase];
ffffffffc0201afa:	fff807b7          	lui	a5,0xfff80
ffffffffc0201afe:	953e                	add	a0,a0,a5
ffffffffc0201b00:	00010997          	auipc	s3,0x10
ffffffffc0201b04:	9b098993          	addi	s3,s3,-1616 # ffffffffc02114b0 <pages>
ffffffffc0201b08:	0009b783          	ld	a5,0(s3)
ffffffffc0201b0c:	00351713          	slli	a4,a0,0x3
ffffffffc0201b10:	953a                	add	a0,a0,a4
ffffffffc0201b12:	050e                	slli	a0,a0,0x3
ffffffffc0201b14:	953e                	add	a0,a0,a5
        if (p == page) {
ffffffffc0201b16:	00a40e63          	beq	s0,a0,ffffffffc0201b32 <page_insert+0xbe>
    page->ref -= 1;
ffffffffc0201b1a:	411c                	lw	a5,0(a0)
ffffffffc0201b1c:	fff7871b          	addiw	a4,a5,-1
ffffffffc0201b20:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc0201b22:	cb11                	beqz	a4,ffffffffc0201b36 <page_insert+0xc2>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc0201b24:	00093023          	sd	zero,0(s2)
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc0201b28:	12000073          	sfence.vma
ffffffffc0201b2c:	0009b783          	ld	a5,0(s3)
ffffffffc0201b30:	bfb5                	j	ffffffffc0201aac <page_insert+0x38>
    page->ref -= 1;
ffffffffc0201b32:	c014                	sw	a3,0(s0)
    return page->ref;
ffffffffc0201b34:	bfa5                	j	ffffffffc0201aac <page_insert+0x38>
            free_page(page);
ffffffffc0201b36:	4585                	li	a1,1
ffffffffc0201b38:	bdfff0ef          	jal	ra,ffffffffc0201716 <free_pages>
ffffffffc0201b3c:	b7e5                	j	ffffffffc0201b24 <page_insert+0xb0>
        return -E_NO_MEM;
ffffffffc0201b3e:	5571                	li	a0,-4
ffffffffc0201b40:	bf61                	j	ffffffffc0201ad8 <page_insert+0x64>
ffffffffc0201b42:	b31ff0ef          	jal	ra,ffffffffc0201672 <pa2page.part.4>

ffffffffc0201b46 <pmm_init>:
    pmm_manager = &default_pmm_manager;
ffffffffc0201b46:	00003797          	auipc	a5,0x3
ffffffffc0201b4a:	50a78793          	addi	a5,a5,1290 # ffffffffc0205050 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201b4e:	638c                	ld	a1,0(a5)
void pmm_init(void) {
ffffffffc0201b50:	711d                	addi	sp,sp,-96
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201b52:	00003517          	auipc	a0,0x3
ffffffffc0201b56:	60e50513          	addi	a0,a0,1550 # ffffffffc0205160 <default_pmm_manager+0x110>
void pmm_init(void) {
ffffffffc0201b5a:	ec86                	sd	ra,88(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc0201b5c:	00010717          	auipc	a4,0x10
ffffffffc0201b60:	92f73e23          	sd	a5,-1732(a4) # ffffffffc0211498 <pmm_manager>
void pmm_init(void) {
ffffffffc0201b64:	e8a2                	sd	s0,80(sp)
ffffffffc0201b66:	e4a6                	sd	s1,72(sp)
ffffffffc0201b68:	e0ca                	sd	s2,64(sp)
ffffffffc0201b6a:	fc4e                	sd	s3,56(sp)
ffffffffc0201b6c:	f852                	sd	s4,48(sp)
ffffffffc0201b6e:	f456                	sd	s5,40(sp)
ffffffffc0201b70:	f05a                	sd	s6,32(sp)
ffffffffc0201b72:	ec5e                	sd	s7,24(sp)
ffffffffc0201b74:	e862                	sd	s8,16(sp)
ffffffffc0201b76:	e466                	sd	s9,8(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc0201b78:	00010417          	auipc	s0,0x10
ffffffffc0201b7c:	92040413          	addi	s0,s0,-1760 # ffffffffc0211498 <pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201b80:	d3efe0ef          	jal	ra,ffffffffc02000be <cprintf>
    pmm_manager->init();
ffffffffc0201b84:	601c                	ld	a5,0(s0)
    cprintf("membegin %llx memend %llx mem_size %llx\n",mem_begin, mem_end, mem_size);
ffffffffc0201b86:	49c5                	li	s3,17
ffffffffc0201b88:	40100a13          	li	s4,1025
    pmm_manager->init();
ffffffffc0201b8c:	679c                	ld	a5,8(a5)
ffffffffc0201b8e:	00010497          	auipc	s1,0x10
ffffffffc0201b92:	8d248493          	addi	s1,s1,-1838 # ffffffffc0211460 <npage>
ffffffffc0201b96:	00010917          	auipc	s2,0x10
ffffffffc0201b9a:	91a90913          	addi	s2,s2,-1766 # ffffffffc02114b0 <pages>
ffffffffc0201b9e:	9782                	jalr	a5
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0201ba0:	57f5                	li	a5,-3
ffffffffc0201ba2:	07fa                	slli	a5,a5,0x1e
    cprintf("membegin %llx memend %llx mem_size %llx\n",mem_begin, mem_end, mem_size);
ffffffffc0201ba4:	07e006b7          	lui	a3,0x7e00
ffffffffc0201ba8:	01b99613          	slli	a2,s3,0x1b
ffffffffc0201bac:	015a1593          	slli	a1,s4,0x15
ffffffffc0201bb0:	00003517          	auipc	a0,0x3
ffffffffc0201bb4:	5c850513          	addi	a0,a0,1480 # ffffffffc0205178 <default_pmm_manager+0x128>
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0201bb8:	00010717          	auipc	a4,0x10
ffffffffc0201bbc:	8ef73423          	sd	a5,-1816(a4) # ffffffffc02114a0 <va_pa_offset>
    cprintf("membegin %llx memend %llx mem_size %llx\n",mem_begin, mem_end, mem_size);
ffffffffc0201bc0:	cfefe0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("physcial memory map:\n");
ffffffffc0201bc4:	00003517          	auipc	a0,0x3
ffffffffc0201bc8:	5e450513          	addi	a0,a0,1508 # ffffffffc02051a8 <default_pmm_manager+0x158>
ffffffffc0201bcc:	cf2fe0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin,
ffffffffc0201bd0:	01b99693          	slli	a3,s3,0x1b
ffffffffc0201bd4:	16fd                	addi	a3,a3,-1
ffffffffc0201bd6:	015a1613          	slli	a2,s4,0x15
ffffffffc0201bda:	07e005b7          	lui	a1,0x7e00
ffffffffc0201bde:	00003517          	auipc	a0,0x3
ffffffffc0201be2:	5e250513          	addi	a0,a0,1506 # ffffffffc02051c0 <default_pmm_manager+0x170>
ffffffffc0201be6:	cd8fe0ef          	jal	ra,ffffffffc02000be <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201bea:	777d                	lui	a4,0xfffff
ffffffffc0201bec:	00011797          	auipc	a5,0x11
ffffffffc0201bf0:	9b378793          	addi	a5,a5,-1613 # ffffffffc021259f <end+0xfff>
ffffffffc0201bf4:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc0201bf6:	00088737          	lui	a4,0x88
ffffffffc0201bfa:	00010697          	auipc	a3,0x10
ffffffffc0201bfe:	86e6b323          	sd	a4,-1946(a3) # ffffffffc0211460 <npage>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201c02:	00010717          	auipc	a4,0x10
ffffffffc0201c06:	8af73723          	sd	a5,-1874(a4) # ffffffffc02114b0 <pages>
ffffffffc0201c0a:	4681                	li	a3,0
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201c0c:	4701                	li	a4,0
ffffffffc0201c0e:	4585                	li	a1,1
ffffffffc0201c10:	fff80637          	lui	a2,0xfff80
ffffffffc0201c14:	a019                	j	ffffffffc0201c1a <pmm_init+0xd4>
ffffffffc0201c16:	00093783          	ld	a5,0(s2)
        SetPageReserved(pages + i);
ffffffffc0201c1a:	97b6                	add	a5,a5,a3
ffffffffc0201c1c:	07a1                	addi	a5,a5,8
ffffffffc0201c1e:	40b7b02f          	amoor.d	zero,a1,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201c22:	609c                	ld	a5,0(s1)
ffffffffc0201c24:	0705                	addi	a4,a4,1
ffffffffc0201c26:	04868693          	addi	a3,a3,72
ffffffffc0201c2a:	00c78533          	add	a0,a5,a2
ffffffffc0201c2e:	fea764e3          	bltu	a4,a0,ffffffffc0201c16 <pmm_init+0xd0>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201c32:	00093503          	ld	a0,0(s2)
ffffffffc0201c36:	00379693          	slli	a3,a5,0x3
ffffffffc0201c3a:	96be                	add	a3,a3,a5
ffffffffc0201c3c:	fdc00737          	lui	a4,0xfdc00
ffffffffc0201c40:	972a                	add	a4,a4,a0
ffffffffc0201c42:	068e                	slli	a3,a3,0x3
ffffffffc0201c44:	96ba                	add	a3,a3,a4
ffffffffc0201c46:	c0200737          	lui	a4,0xc0200
ffffffffc0201c4a:	58e6ea63          	bltu	a3,a4,ffffffffc02021de <pmm_init+0x698>
ffffffffc0201c4e:	00010997          	auipc	s3,0x10
ffffffffc0201c52:	85298993          	addi	s3,s3,-1966 # ffffffffc02114a0 <va_pa_offset>
ffffffffc0201c56:	0009b703          	ld	a4,0(s3)
    if (freemem < mem_end) {
ffffffffc0201c5a:	45c5                	li	a1,17
ffffffffc0201c5c:	05ee                	slli	a1,a1,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201c5e:	8e99                	sub	a3,a3,a4
    if (freemem < mem_end) {
ffffffffc0201c60:	44b6ef63          	bltu	a3,a1,ffffffffc02020be <pmm_init+0x578>

    return page;
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc0201c64:	601c                	ld	a5,0(s0)
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0201c66:	0000f417          	auipc	s0,0xf
ffffffffc0201c6a:	7f240413          	addi	s0,s0,2034 # ffffffffc0211458 <boot_pgdir>
    pmm_manager->check();
ffffffffc0201c6e:	7b9c                	ld	a5,48(a5)
ffffffffc0201c70:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0201c72:	00003517          	auipc	a0,0x3
ffffffffc0201c76:	59e50513          	addi	a0,a0,1438 # ffffffffc0205210 <default_pmm_manager+0x1c0>
ffffffffc0201c7a:	c44fe0ef          	jal	ra,ffffffffc02000be <cprintf>
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0201c7e:	00007697          	auipc	a3,0x7
ffffffffc0201c82:	38268693          	addi	a3,a3,898 # ffffffffc0209000 <boot_page_table_sv39>
ffffffffc0201c86:	0000f797          	auipc	a5,0xf
ffffffffc0201c8a:	7cd7b923          	sd	a3,2002(a5) # ffffffffc0211458 <boot_pgdir>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc0201c8e:	c02007b7          	lui	a5,0xc0200
ffffffffc0201c92:	0ef6ece3          	bltu	a3,a5,ffffffffc020258a <pmm_init+0xa44>
ffffffffc0201c96:	0009b783          	ld	a5,0(s3)
ffffffffc0201c9a:	8e9d                	sub	a3,a3,a5
ffffffffc0201c9c:	00010797          	auipc	a5,0x10
ffffffffc0201ca0:	80d7b623          	sd	a3,-2036(a5) # ffffffffc02114a8 <boot_cr3>
    // assert(npage <= KMEMSIZE / PGSIZE);
    // The memory starts at 2GB in RISC-V
    // so npage is always larger than KMEMSIZE / PGSIZE
    size_t nr_free_store;

    nr_free_store=nr_free_pages();
ffffffffc0201ca4:	ab9ff0ef          	jal	ra,ffffffffc020175c <nr_free_pages>

    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0201ca8:	6098                	ld	a4,0(s1)
ffffffffc0201caa:	c80007b7          	lui	a5,0xc8000
ffffffffc0201cae:	83b1                	srli	a5,a5,0xc
    nr_free_store=nr_free_pages();
ffffffffc0201cb0:	8a2a                	mv	s4,a0
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0201cb2:	0ae7ece3          	bltu	a5,a4,ffffffffc020256a <pmm_init+0xa24>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc0201cb6:	6008                	ld	a0,0(s0)
ffffffffc0201cb8:	4c050363          	beqz	a0,ffffffffc020217e <pmm_init+0x638>
ffffffffc0201cbc:	6785                	lui	a5,0x1
ffffffffc0201cbe:	17fd                	addi	a5,a5,-1
ffffffffc0201cc0:	8fe9                	and	a5,a5,a0
ffffffffc0201cc2:	2781                	sext.w	a5,a5
ffffffffc0201cc4:	4a079d63          	bnez	a5,ffffffffc020217e <pmm_init+0x638>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc0201cc8:	4601                	li	a2,0
ffffffffc0201cca:	4581                	li	a1,0
ffffffffc0201ccc:	ccfff0ef          	jal	ra,ffffffffc020199a <get_page>
ffffffffc0201cd0:	4c051763          	bnez	a0,ffffffffc020219e <pmm_init+0x658>

    struct Page *p1, *p2;
    p1 = alloc_page();
ffffffffc0201cd4:	4505                	li	a0,1
ffffffffc0201cd6:	9b9ff0ef          	jal	ra,ffffffffc020168e <alloc_pages>
ffffffffc0201cda:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc0201cdc:	6008                	ld	a0,0(s0)
ffffffffc0201cde:	4681                	li	a3,0
ffffffffc0201ce0:	4601                	li	a2,0
ffffffffc0201ce2:	85d6                	mv	a1,s5
ffffffffc0201ce4:	d91ff0ef          	jal	ra,ffffffffc0201a74 <page_insert>
ffffffffc0201ce8:	52051763          	bnez	a0,ffffffffc0202216 <pmm_init+0x6d0>
    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc0201cec:	6008                	ld	a0,0(s0)
ffffffffc0201cee:	4601                	li	a2,0
ffffffffc0201cf0:	4581                	li	a1,0
ffffffffc0201cf2:	aabff0ef          	jal	ra,ffffffffc020179c <get_pte>
ffffffffc0201cf6:	50050063          	beqz	a0,ffffffffc02021f6 <pmm_init+0x6b0>
    assert(pte2page(*ptep) == p1);
ffffffffc0201cfa:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0201cfc:	0017f713          	andi	a4,a5,1
ffffffffc0201d00:	46070363          	beqz	a4,ffffffffc0202166 <pmm_init+0x620>
    if (PPN(pa) >= npage) {
ffffffffc0201d04:	6090                	ld	a2,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0201d06:	078a                	slli	a5,a5,0x2
ffffffffc0201d08:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201d0a:	44c7f063          	bleu	a2,a5,ffffffffc020214a <pmm_init+0x604>
    return &pages[PPN(pa) - nbase];
ffffffffc0201d0e:	fff80737          	lui	a4,0xfff80
ffffffffc0201d12:	97ba                	add	a5,a5,a4
ffffffffc0201d14:	00379713          	slli	a4,a5,0x3
ffffffffc0201d18:	00093683          	ld	a3,0(s2)
ffffffffc0201d1c:	97ba                	add	a5,a5,a4
ffffffffc0201d1e:	078e                	slli	a5,a5,0x3
ffffffffc0201d20:	97b6                	add	a5,a5,a3
ffffffffc0201d22:	5efa9463          	bne	s5,a5,ffffffffc020230a <pmm_init+0x7c4>
    assert(page_ref(p1) == 1);
ffffffffc0201d26:	000aab83          	lw	s7,0(s5)
ffffffffc0201d2a:	4785                	li	a5,1
ffffffffc0201d2c:	5afb9f63          	bne	s7,a5,ffffffffc02022ea <pmm_init+0x7a4>

    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc0201d30:	6008                	ld	a0,0(s0)
ffffffffc0201d32:	76fd                	lui	a3,0xfffff
ffffffffc0201d34:	611c                	ld	a5,0(a0)
ffffffffc0201d36:	078a                	slli	a5,a5,0x2
ffffffffc0201d38:	8ff5                	and	a5,a5,a3
ffffffffc0201d3a:	00c7d713          	srli	a4,a5,0xc
ffffffffc0201d3e:	58c77963          	bleu	a2,a4,ffffffffc02022d0 <pmm_init+0x78a>
ffffffffc0201d42:	0009bc03          	ld	s8,0(s3)
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0201d46:	97e2                	add	a5,a5,s8
ffffffffc0201d48:	0007bb03          	ld	s6,0(a5) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
ffffffffc0201d4c:	0b0a                	slli	s6,s6,0x2
ffffffffc0201d4e:	00db7b33          	and	s6,s6,a3
ffffffffc0201d52:	00cb5793          	srli	a5,s6,0xc
ffffffffc0201d56:	56c7f063          	bleu	a2,a5,ffffffffc02022b6 <pmm_init+0x770>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0201d5a:	4601                	li	a2,0
ffffffffc0201d5c:	6585                	lui	a1,0x1
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0201d5e:	9b62                	add	s6,s6,s8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0201d60:	a3dff0ef          	jal	ra,ffffffffc020179c <get_pte>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0201d64:	0b21                	addi	s6,s6,8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0201d66:	53651863          	bne	a0,s6,ffffffffc0202296 <pmm_init+0x750>

    p2 = alloc_page();
ffffffffc0201d6a:	4505                	li	a0,1
ffffffffc0201d6c:	923ff0ef          	jal	ra,ffffffffc020168e <alloc_pages>
ffffffffc0201d70:	8b2a                	mv	s6,a0
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0201d72:	6008                	ld	a0,0(s0)
ffffffffc0201d74:	46d1                	li	a3,20
ffffffffc0201d76:	6605                	lui	a2,0x1
ffffffffc0201d78:	85da                	mv	a1,s6
ffffffffc0201d7a:	cfbff0ef          	jal	ra,ffffffffc0201a74 <page_insert>
ffffffffc0201d7e:	4e051c63          	bnez	a0,ffffffffc0202276 <pmm_init+0x730>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0201d82:	6008                	ld	a0,0(s0)
ffffffffc0201d84:	4601                	li	a2,0
ffffffffc0201d86:	6585                	lui	a1,0x1
ffffffffc0201d88:	a15ff0ef          	jal	ra,ffffffffc020179c <get_pte>
ffffffffc0201d8c:	4c050563          	beqz	a0,ffffffffc0202256 <pmm_init+0x710>
    assert(*ptep & PTE_U);
ffffffffc0201d90:	611c                	ld	a5,0(a0)
ffffffffc0201d92:	0107f713          	andi	a4,a5,16
ffffffffc0201d96:	4a070063          	beqz	a4,ffffffffc0202236 <pmm_init+0x6f0>
    assert(*ptep & PTE_W);
ffffffffc0201d9a:	8b91                	andi	a5,a5,4
ffffffffc0201d9c:	66078763          	beqz	a5,ffffffffc020240a <pmm_init+0x8c4>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc0201da0:	6008                	ld	a0,0(s0)
ffffffffc0201da2:	611c                	ld	a5,0(a0)
ffffffffc0201da4:	8bc1                	andi	a5,a5,16
ffffffffc0201da6:	64078263          	beqz	a5,ffffffffc02023ea <pmm_init+0x8a4>
    assert(page_ref(p2) == 1);
ffffffffc0201daa:	000b2783          	lw	a5,0(s6)
ffffffffc0201dae:	61779e63          	bne	a5,s7,ffffffffc02023ca <pmm_init+0x884>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc0201db2:	4681                	li	a3,0
ffffffffc0201db4:	6605                	lui	a2,0x1
ffffffffc0201db6:	85d6                	mv	a1,s5
ffffffffc0201db8:	cbdff0ef          	jal	ra,ffffffffc0201a74 <page_insert>
ffffffffc0201dbc:	5e051763          	bnez	a0,ffffffffc02023aa <pmm_init+0x864>
    assert(page_ref(p1) == 2);
ffffffffc0201dc0:	000aa703          	lw	a4,0(s5)
ffffffffc0201dc4:	4789                	li	a5,2
ffffffffc0201dc6:	5cf71263          	bne	a4,a5,ffffffffc020238a <pmm_init+0x844>
    assert(page_ref(p2) == 0);
ffffffffc0201dca:	000b2783          	lw	a5,0(s6)
ffffffffc0201dce:	58079e63          	bnez	a5,ffffffffc020236a <pmm_init+0x824>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0201dd2:	6008                	ld	a0,0(s0)
ffffffffc0201dd4:	4601                	li	a2,0
ffffffffc0201dd6:	6585                	lui	a1,0x1
ffffffffc0201dd8:	9c5ff0ef          	jal	ra,ffffffffc020179c <get_pte>
ffffffffc0201ddc:	56050763          	beqz	a0,ffffffffc020234a <pmm_init+0x804>
    assert(pte2page(*ptep) == p1);
ffffffffc0201de0:	6114                	ld	a3,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0201de2:	0016f793          	andi	a5,a3,1
ffffffffc0201de6:	38078063          	beqz	a5,ffffffffc0202166 <pmm_init+0x620>
    if (PPN(pa) >= npage) {
ffffffffc0201dea:	6098                	ld	a4,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0201dec:	00269793          	slli	a5,a3,0x2
ffffffffc0201df0:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201df2:	34e7fc63          	bleu	a4,a5,ffffffffc020214a <pmm_init+0x604>
    return &pages[PPN(pa) - nbase];
ffffffffc0201df6:	fff80737          	lui	a4,0xfff80
ffffffffc0201dfa:	97ba                	add	a5,a5,a4
ffffffffc0201dfc:	00379713          	slli	a4,a5,0x3
ffffffffc0201e00:	00093603          	ld	a2,0(s2)
ffffffffc0201e04:	97ba                	add	a5,a5,a4
ffffffffc0201e06:	078e                	slli	a5,a5,0x3
ffffffffc0201e08:	97b2                	add	a5,a5,a2
ffffffffc0201e0a:	52fa9063          	bne	s5,a5,ffffffffc020232a <pmm_init+0x7e4>
    assert((*ptep & PTE_U) == 0);
ffffffffc0201e0e:	8ac1                	andi	a3,a3,16
ffffffffc0201e10:	6e069d63          	bnez	a3,ffffffffc020250a <pmm_init+0x9c4>

    page_remove(boot_pgdir, 0x0);
ffffffffc0201e14:	6008                	ld	a0,0(s0)
ffffffffc0201e16:	4581                	li	a1,0
ffffffffc0201e18:	bebff0ef          	jal	ra,ffffffffc0201a02 <page_remove>
    assert(page_ref(p1) == 1);
ffffffffc0201e1c:	000aa703          	lw	a4,0(s5)
ffffffffc0201e20:	4785                	li	a5,1
ffffffffc0201e22:	6cf71463          	bne	a4,a5,ffffffffc02024ea <pmm_init+0x9a4>
    assert(page_ref(p2) == 0);
ffffffffc0201e26:	000b2783          	lw	a5,0(s6)
ffffffffc0201e2a:	6a079063          	bnez	a5,ffffffffc02024ca <pmm_init+0x984>

    page_remove(boot_pgdir, PGSIZE);
ffffffffc0201e2e:	6008                	ld	a0,0(s0)
ffffffffc0201e30:	6585                	lui	a1,0x1
ffffffffc0201e32:	bd1ff0ef          	jal	ra,ffffffffc0201a02 <page_remove>
    assert(page_ref(p1) == 0);
ffffffffc0201e36:	000aa783          	lw	a5,0(s5)
ffffffffc0201e3a:	66079863          	bnez	a5,ffffffffc02024aa <pmm_init+0x964>
    assert(page_ref(p2) == 0);
ffffffffc0201e3e:	000b2783          	lw	a5,0(s6)
ffffffffc0201e42:	70079463          	bnez	a5,ffffffffc020254a <pmm_init+0xa04>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc0201e46:	00043b03          	ld	s6,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc0201e4a:	608c                	ld	a1,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201e4c:	000b3783          	ld	a5,0(s6)
ffffffffc0201e50:	078a                	slli	a5,a5,0x2
ffffffffc0201e52:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201e54:	2eb7fb63          	bleu	a1,a5,ffffffffc020214a <pmm_init+0x604>
    return &pages[PPN(pa) - nbase];
ffffffffc0201e58:	fff80737          	lui	a4,0xfff80
ffffffffc0201e5c:	973e                	add	a4,a4,a5
ffffffffc0201e5e:	00371793          	slli	a5,a4,0x3
ffffffffc0201e62:	00093603          	ld	a2,0(s2)
ffffffffc0201e66:	97ba                	add	a5,a5,a4
ffffffffc0201e68:	078e                	slli	a5,a5,0x3
ffffffffc0201e6a:	00f60733          	add	a4,a2,a5
ffffffffc0201e6e:	4314                	lw	a3,0(a4)
ffffffffc0201e70:	4705                	li	a4,1
ffffffffc0201e72:	6ae69c63          	bne	a3,a4,ffffffffc020252a <pmm_init+0x9e4>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201e76:	00003a97          	auipc	s5,0x3
ffffffffc0201e7a:	e2aa8a93          	addi	s5,s5,-470 # ffffffffc0204ca0 <commands+0x858>
ffffffffc0201e7e:	000ab703          	ld	a4,0(s5)
ffffffffc0201e82:	4037d693          	srai	a3,a5,0x3
ffffffffc0201e86:	00080bb7          	lui	s7,0x80
ffffffffc0201e8a:	02e686b3          	mul	a3,a3,a4
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201e8e:	577d                	li	a4,-1
ffffffffc0201e90:	8331                	srli	a4,a4,0xc
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201e92:	96de                	add	a3,a3,s7
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201e94:	8f75                	and	a4,a4,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0201e96:	06b2                	slli	a3,a3,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201e98:	2ab77b63          	bleu	a1,a4,ffffffffc020214e <pmm_init+0x608>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
    free_page(pde2page(pd0[0]));
ffffffffc0201e9c:	0009b783          	ld	a5,0(s3)
ffffffffc0201ea0:	96be                	add	a3,a3,a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0201ea2:	629c                	ld	a5,0(a3)
ffffffffc0201ea4:	078a                	slli	a5,a5,0x2
ffffffffc0201ea6:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201ea8:	2ab7f163          	bleu	a1,a5,ffffffffc020214a <pmm_init+0x604>
    return &pages[PPN(pa) - nbase];
ffffffffc0201eac:	417787b3          	sub	a5,a5,s7
ffffffffc0201eb0:	00379513          	slli	a0,a5,0x3
ffffffffc0201eb4:	97aa                	add	a5,a5,a0
ffffffffc0201eb6:	00379513          	slli	a0,a5,0x3
ffffffffc0201eba:	9532                	add	a0,a0,a2
ffffffffc0201ebc:	4585                	li	a1,1
ffffffffc0201ebe:	859ff0ef          	jal	ra,ffffffffc0201716 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0201ec2:	000b3503          	ld	a0,0(s6)
    if (PPN(pa) >= npage) {
ffffffffc0201ec6:	609c                	ld	a5,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201ec8:	050a                	slli	a0,a0,0x2
ffffffffc0201eca:	8131                	srli	a0,a0,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201ecc:	26f57f63          	bleu	a5,a0,ffffffffc020214a <pmm_init+0x604>
    return &pages[PPN(pa) - nbase];
ffffffffc0201ed0:	417507b3          	sub	a5,a0,s7
ffffffffc0201ed4:	00379513          	slli	a0,a5,0x3
ffffffffc0201ed8:	00093703          	ld	a4,0(s2)
ffffffffc0201edc:	953e                	add	a0,a0,a5
ffffffffc0201ede:	050e                	slli	a0,a0,0x3
    free_page(pde2page(pd1[0]));
ffffffffc0201ee0:	4585                	li	a1,1
ffffffffc0201ee2:	953a                	add	a0,a0,a4
ffffffffc0201ee4:	833ff0ef          	jal	ra,ffffffffc0201716 <free_pages>
    boot_pgdir[0] = 0;
ffffffffc0201ee8:	601c                	ld	a5,0(s0)
ffffffffc0201eea:	0007b023          	sd	zero,0(a5)

    assert(nr_free_store==nr_free_pages());
ffffffffc0201eee:	86fff0ef          	jal	ra,ffffffffc020175c <nr_free_pages>
ffffffffc0201ef2:	2caa1663          	bne	s4,a0,ffffffffc02021be <pmm_init+0x678>

    cprintf("check_pgdir() succeeded!\n");
ffffffffc0201ef6:	00003517          	auipc	a0,0x3
ffffffffc0201efa:	62a50513          	addi	a0,a0,1578 # ffffffffc0205520 <default_pmm_manager+0x4d0>
ffffffffc0201efe:	9c0fe0ef          	jal	ra,ffffffffc02000be <cprintf>
static void check_boot_pgdir(void) {
    size_t nr_free_store;
    pte_t *ptep;
    int i;

    nr_free_store=nr_free_pages();
ffffffffc0201f02:	85bff0ef          	jal	ra,ffffffffc020175c <nr_free_pages>

    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0201f06:	6098                	ld	a4,0(s1)
ffffffffc0201f08:	c02007b7          	lui	a5,0xc0200
    nr_free_store=nr_free_pages();
ffffffffc0201f0c:	8b2a                	mv	s6,a0
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0201f0e:	00c71693          	slli	a3,a4,0xc
ffffffffc0201f12:	1cd7fd63          	bleu	a3,a5,ffffffffc02020ec <pmm_init+0x5a6>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0201f16:	83b1                	srli	a5,a5,0xc
ffffffffc0201f18:	6008                	ld	a0,0(s0)
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0201f1a:	c0200a37          	lui	s4,0xc0200
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0201f1e:	1ce7f963          	bleu	a4,a5,ffffffffc02020f0 <pmm_init+0x5aa>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0201f22:	7c7d                	lui	s8,0xfffff
ffffffffc0201f24:	6b85                	lui	s7,0x1
ffffffffc0201f26:	a029                	j	ffffffffc0201f30 <pmm_init+0x3ea>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0201f28:	00ca5713          	srli	a4,s4,0xc
ffffffffc0201f2c:	1cf77263          	bleu	a5,a4,ffffffffc02020f0 <pmm_init+0x5aa>
ffffffffc0201f30:	0009b583          	ld	a1,0(s3)
ffffffffc0201f34:	4601                	li	a2,0
ffffffffc0201f36:	95d2                	add	a1,a1,s4
ffffffffc0201f38:	865ff0ef          	jal	ra,ffffffffc020179c <get_pte>
ffffffffc0201f3c:	1c050763          	beqz	a0,ffffffffc020210a <pmm_init+0x5c4>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0201f40:	611c                	ld	a5,0(a0)
ffffffffc0201f42:	078a                	slli	a5,a5,0x2
ffffffffc0201f44:	0187f7b3          	and	a5,a5,s8
ffffffffc0201f48:	1f479163          	bne	a5,s4,ffffffffc020212a <pmm_init+0x5e4>
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0201f4c:	609c                	ld	a5,0(s1)
ffffffffc0201f4e:	9a5e                	add	s4,s4,s7
ffffffffc0201f50:	6008                	ld	a0,0(s0)
ffffffffc0201f52:	00c79713          	slli	a4,a5,0xc
ffffffffc0201f56:	fcea69e3          	bltu	s4,a4,ffffffffc0201f28 <pmm_init+0x3e2>
    }


    assert(boot_pgdir[0] == 0);
ffffffffc0201f5a:	611c                	ld	a5,0(a0)
ffffffffc0201f5c:	6a079363          	bnez	a5,ffffffffc0202602 <pmm_init+0xabc>

    struct Page *p;
    p = alloc_page();
ffffffffc0201f60:	4505                	li	a0,1
ffffffffc0201f62:	f2cff0ef          	jal	ra,ffffffffc020168e <alloc_pages>
ffffffffc0201f66:	8a2a                	mv	s4,a0
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0201f68:	6008                	ld	a0,0(s0)
ffffffffc0201f6a:	4699                	li	a3,6
ffffffffc0201f6c:	10000613          	li	a2,256
ffffffffc0201f70:	85d2                	mv	a1,s4
ffffffffc0201f72:	b03ff0ef          	jal	ra,ffffffffc0201a74 <page_insert>
ffffffffc0201f76:	66051663          	bnez	a0,ffffffffc02025e2 <pmm_init+0xa9c>
    assert(page_ref(p) == 1);
ffffffffc0201f7a:	000a2703          	lw	a4,0(s4) # ffffffffc0200000 <kern_entry>
ffffffffc0201f7e:	4785                	li	a5,1
ffffffffc0201f80:	64f71163          	bne	a4,a5,ffffffffc02025c2 <pmm_init+0xa7c>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0201f84:	6008                	ld	a0,0(s0)
ffffffffc0201f86:	6b85                	lui	s7,0x1
ffffffffc0201f88:	4699                	li	a3,6
ffffffffc0201f8a:	100b8613          	addi	a2,s7,256 # 1100 <BASE_ADDRESS-0xffffffffc01fef00>
ffffffffc0201f8e:	85d2                	mv	a1,s4
ffffffffc0201f90:	ae5ff0ef          	jal	ra,ffffffffc0201a74 <page_insert>
ffffffffc0201f94:	60051763          	bnez	a0,ffffffffc02025a2 <pmm_init+0xa5c>
    assert(page_ref(p) == 2);
ffffffffc0201f98:	000a2703          	lw	a4,0(s4)
ffffffffc0201f9c:	4789                	li	a5,2
ffffffffc0201f9e:	4ef71663          	bne	a4,a5,ffffffffc020248a <pmm_init+0x944>

    const char *str = "ucore: Hello world!!";
    strcpy((void *)0x100, str);
ffffffffc0201fa2:	00003597          	auipc	a1,0x3
ffffffffc0201fa6:	6b658593          	addi	a1,a1,1718 # ffffffffc0205658 <default_pmm_manager+0x608>
ffffffffc0201faa:	10000513          	li	a0,256
ffffffffc0201fae:	2ec020ef          	jal	ra,ffffffffc020429a <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0201fb2:	100b8593          	addi	a1,s7,256
ffffffffc0201fb6:	10000513          	li	a0,256
ffffffffc0201fba:	2f2020ef          	jal	ra,ffffffffc02042ac <strcmp>
ffffffffc0201fbe:	4a051663          	bnez	a0,ffffffffc020246a <pmm_init+0x924>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201fc2:	00093683          	ld	a3,0(s2)
ffffffffc0201fc6:	000abc83          	ld	s9,0(s5)
ffffffffc0201fca:	00080c37          	lui	s8,0x80
ffffffffc0201fce:	40da06b3          	sub	a3,s4,a3
ffffffffc0201fd2:	868d                	srai	a3,a3,0x3
ffffffffc0201fd4:	039686b3          	mul	a3,a3,s9
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201fd8:	5afd                	li	s5,-1
ffffffffc0201fda:	609c                	ld	a5,0(s1)
ffffffffc0201fdc:	00cada93          	srli	s5,s5,0xc
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201fe0:	96e2                	add	a3,a3,s8
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201fe2:	0156f733          	and	a4,a3,s5
    return page2ppn(page) << PGSHIFT;
ffffffffc0201fe6:	06b2                	slli	a3,a3,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201fe8:	16f77363          	bleu	a5,a4,ffffffffc020214e <pmm_init+0x608>

    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0201fec:	0009b783          	ld	a5,0(s3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc0201ff0:	10000513          	li	a0,256
    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0201ff4:	96be                	add	a3,a3,a5
ffffffffc0201ff6:	10068023          	sb	zero,256(a3) # fffffffffffff100 <end+0x3fdedb60>
    assert(strlen((const char *)0x100) == 0);
ffffffffc0201ffa:	25c020ef          	jal	ra,ffffffffc0204256 <strlen>
ffffffffc0201ffe:	44051663          	bnez	a0,ffffffffc020244a <pmm_init+0x904>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc0202002:	00043b83          	ld	s7,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc0202006:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202008:	000bb783          	ld	a5,0(s7)
ffffffffc020200c:	078a                	slli	a5,a5,0x2
ffffffffc020200e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202010:	12e7fd63          	bleu	a4,a5,ffffffffc020214a <pmm_init+0x604>
    return &pages[PPN(pa) - nbase];
ffffffffc0202014:	418787b3          	sub	a5,a5,s8
ffffffffc0202018:	00379693          	slli	a3,a5,0x3
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc020201c:	96be                	add	a3,a3,a5
ffffffffc020201e:	039686b3          	mul	a3,a3,s9
ffffffffc0202022:	96e2                	add	a3,a3,s8
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0202024:	0156fab3          	and	s5,a3,s5
    return page2ppn(page) << PGSHIFT;
ffffffffc0202028:	06b2                	slli	a3,a3,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc020202a:	12eaf263          	bleu	a4,s5,ffffffffc020214e <pmm_init+0x608>
ffffffffc020202e:	0009b983          	ld	s3,0(s3)
    free_page(p);
ffffffffc0202032:	4585                	li	a1,1
ffffffffc0202034:	8552                	mv	a0,s4
ffffffffc0202036:	99b6                	add	s3,s3,a3
ffffffffc0202038:	edeff0ef          	jal	ra,ffffffffc0201716 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc020203c:	0009b783          	ld	a5,0(s3)
    if (PPN(pa) >= npage) {
ffffffffc0202040:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202042:	078a                	slli	a5,a5,0x2
ffffffffc0202044:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202046:	10e7f263          	bleu	a4,a5,ffffffffc020214a <pmm_init+0x604>
    return &pages[PPN(pa) - nbase];
ffffffffc020204a:	fff809b7          	lui	s3,0xfff80
ffffffffc020204e:	97ce                	add	a5,a5,s3
ffffffffc0202050:	00379513          	slli	a0,a5,0x3
ffffffffc0202054:	00093703          	ld	a4,0(s2)
ffffffffc0202058:	97aa                	add	a5,a5,a0
ffffffffc020205a:	00379513          	slli	a0,a5,0x3
    free_page(pde2page(pd0[0]));
ffffffffc020205e:	953a                	add	a0,a0,a4
ffffffffc0202060:	4585                	li	a1,1
ffffffffc0202062:	eb4ff0ef          	jal	ra,ffffffffc0201716 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0202066:	000bb503          	ld	a0,0(s7)
    if (PPN(pa) >= npage) {
ffffffffc020206a:	609c                	ld	a5,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc020206c:	050a                	slli	a0,a0,0x2
ffffffffc020206e:	8131                	srli	a0,a0,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202070:	0cf57d63          	bleu	a5,a0,ffffffffc020214a <pmm_init+0x604>
    return &pages[PPN(pa) - nbase];
ffffffffc0202074:	013507b3          	add	a5,a0,s3
ffffffffc0202078:	00379513          	slli	a0,a5,0x3
ffffffffc020207c:	00093703          	ld	a4,0(s2)
ffffffffc0202080:	953e                	add	a0,a0,a5
ffffffffc0202082:	050e                	slli	a0,a0,0x3
    free_page(pde2page(pd1[0]));
ffffffffc0202084:	4585                	li	a1,1
ffffffffc0202086:	953a                	add	a0,a0,a4
ffffffffc0202088:	e8eff0ef          	jal	ra,ffffffffc0201716 <free_pages>
    boot_pgdir[0] = 0;
ffffffffc020208c:	601c                	ld	a5,0(s0)
ffffffffc020208e:	0007b023          	sd	zero,0(a5) # ffffffffc0200000 <kern_entry>

    assert(nr_free_store==nr_free_pages());
ffffffffc0202092:	ecaff0ef          	jal	ra,ffffffffc020175c <nr_free_pages>
ffffffffc0202096:	38ab1a63          	bne	s6,a0,ffffffffc020242a <pmm_init+0x8e4>
}
ffffffffc020209a:	6446                	ld	s0,80(sp)
ffffffffc020209c:	60e6                	ld	ra,88(sp)
ffffffffc020209e:	64a6                	ld	s1,72(sp)
ffffffffc02020a0:	6906                	ld	s2,64(sp)
ffffffffc02020a2:	79e2                	ld	s3,56(sp)
ffffffffc02020a4:	7a42                	ld	s4,48(sp)
ffffffffc02020a6:	7aa2                	ld	s5,40(sp)
ffffffffc02020a8:	7b02                	ld	s6,32(sp)
ffffffffc02020aa:	6be2                	ld	s7,24(sp)
ffffffffc02020ac:	6c42                	ld	s8,16(sp)
ffffffffc02020ae:	6ca2                	ld	s9,8(sp)

    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc02020b0:	00003517          	auipc	a0,0x3
ffffffffc02020b4:	62050513          	addi	a0,a0,1568 # ffffffffc02056d0 <default_pmm_manager+0x680>
}
ffffffffc02020b8:	6125                	addi	sp,sp,96
    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc02020ba:	804fe06f          	j	ffffffffc02000be <cprintf>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc02020be:	6705                	lui	a4,0x1
ffffffffc02020c0:	177d                	addi	a4,a4,-1
ffffffffc02020c2:	96ba                	add	a3,a3,a4
    if (PPN(pa) >= npage) {
ffffffffc02020c4:	00c6d713          	srli	a4,a3,0xc
ffffffffc02020c8:	08f77163          	bleu	a5,a4,ffffffffc020214a <pmm_init+0x604>
    pmm_manager->init_memmap(base, n);
ffffffffc02020cc:	00043803          	ld	a6,0(s0)
    return &pages[PPN(pa) - nbase];
ffffffffc02020d0:	9732                	add	a4,a4,a2
ffffffffc02020d2:	00371793          	slli	a5,a4,0x3
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc02020d6:	767d                	lui	a2,0xfffff
ffffffffc02020d8:	8ef1                	and	a3,a3,a2
ffffffffc02020da:	97ba                	add	a5,a5,a4
    pmm_manager->init_memmap(base, n);
ffffffffc02020dc:	01083703          	ld	a4,16(a6)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc02020e0:	8d95                	sub	a1,a1,a3
ffffffffc02020e2:	078e                	slli	a5,a5,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc02020e4:	81b1                	srli	a1,a1,0xc
ffffffffc02020e6:	953e                	add	a0,a0,a5
ffffffffc02020e8:	9702                	jalr	a4
ffffffffc02020ea:	bead                	j	ffffffffc0201c64 <pmm_init+0x11e>
ffffffffc02020ec:	6008                	ld	a0,0(s0)
ffffffffc02020ee:	b5b5                	j	ffffffffc0201f5a <pmm_init+0x414>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc02020f0:	86d2                	mv	a3,s4
ffffffffc02020f2:	00003617          	auipc	a2,0x3
ffffffffc02020f6:	fae60613          	addi	a2,a2,-82 # ffffffffc02050a0 <default_pmm_manager+0x50>
ffffffffc02020fa:	1cd00593          	li	a1,461
ffffffffc02020fe:	00003517          	auipc	a0,0x3
ffffffffc0202102:	fca50513          	addi	a0,a0,-54 # ffffffffc02050c8 <default_pmm_manager+0x78>
ffffffffc0202106:	a6efe0ef          	jal	ra,ffffffffc0200374 <__panic>
ffffffffc020210a:	00003697          	auipc	a3,0x3
ffffffffc020210e:	43668693          	addi	a3,a3,1078 # ffffffffc0205540 <default_pmm_manager+0x4f0>
ffffffffc0202112:	00003617          	auipc	a2,0x3
ffffffffc0202116:	ba660613          	addi	a2,a2,-1114 # ffffffffc0204cb8 <commands+0x870>
ffffffffc020211a:	1cd00593          	li	a1,461
ffffffffc020211e:	00003517          	auipc	a0,0x3
ffffffffc0202122:	faa50513          	addi	a0,a0,-86 # ffffffffc02050c8 <default_pmm_manager+0x78>
ffffffffc0202126:	a4efe0ef          	jal	ra,ffffffffc0200374 <__panic>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc020212a:	00003697          	auipc	a3,0x3
ffffffffc020212e:	45668693          	addi	a3,a3,1110 # ffffffffc0205580 <default_pmm_manager+0x530>
ffffffffc0202132:	00003617          	auipc	a2,0x3
ffffffffc0202136:	b8660613          	addi	a2,a2,-1146 # ffffffffc0204cb8 <commands+0x870>
ffffffffc020213a:	1ce00593          	li	a1,462
ffffffffc020213e:	00003517          	auipc	a0,0x3
ffffffffc0202142:	f8a50513          	addi	a0,a0,-118 # ffffffffc02050c8 <default_pmm_manager+0x78>
ffffffffc0202146:	a2efe0ef          	jal	ra,ffffffffc0200374 <__panic>
ffffffffc020214a:	d28ff0ef          	jal	ra,ffffffffc0201672 <pa2page.part.4>
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc020214e:	00003617          	auipc	a2,0x3
ffffffffc0202152:	f5260613          	addi	a2,a2,-174 # ffffffffc02050a0 <default_pmm_manager+0x50>
ffffffffc0202156:	06a00593          	li	a1,106
ffffffffc020215a:	00003517          	auipc	a0,0x3
ffffffffc020215e:	fde50513          	addi	a0,a0,-34 # ffffffffc0205138 <default_pmm_manager+0xe8>
ffffffffc0202162:	a12fe0ef          	jal	ra,ffffffffc0200374 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc0202166:	00003617          	auipc	a2,0x3
ffffffffc020216a:	1aa60613          	addi	a2,a2,426 # ffffffffc0205310 <default_pmm_manager+0x2c0>
ffffffffc020216e:	07000593          	li	a1,112
ffffffffc0202172:	00003517          	auipc	a0,0x3
ffffffffc0202176:	fc650513          	addi	a0,a0,-58 # ffffffffc0205138 <default_pmm_manager+0xe8>
ffffffffc020217a:	9fafe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc020217e:	00003697          	auipc	a3,0x3
ffffffffc0202182:	0d268693          	addi	a3,a3,210 # ffffffffc0205250 <default_pmm_manager+0x200>
ffffffffc0202186:	00003617          	auipc	a2,0x3
ffffffffc020218a:	b3260613          	addi	a2,a2,-1230 # ffffffffc0204cb8 <commands+0x870>
ffffffffc020218e:	19300593          	li	a1,403
ffffffffc0202192:	00003517          	auipc	a0,0x3
ffffffffc0202196:	f3650513          	addi	a0,a0,-202 # ffffffffc02050c8 <default_pmm_manager+0x78>
ffffffffc020219a:	9dafe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc020219e:	00003697          	auipc	a3,0x3
ffffffffc02021a2:	0ea68693          	addi	a3,a3,234 # ffffffffc0205288 <default_pmm_manager+0x238>
ffffffffc02021a6:	00003617          	auipc	a2,0x3
ffffffffc02021aa:	b1260613          	addi	a2,a2,-1262 # ffffffffc0204cb8 <commands+0x870>
ffffffffc02021ae:	19400593          	li	a1,404
ffffffffc02021b2:	00003517          	auipc	a0,0x3
ffffffffc02021b6:	f1650513          	addi	a0,a0,-234 # ffffffffc02050c8 <default_pmm_manager+0x78>
ffffffffc02021ba:	9bafe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc02021be:	00003697          	auipc	a3,0x3
ffffffffc02021c2:	34268693          	addi	a3,a3,834 # ffffffffc0205500 <default_pmm_manager+0x4b0>
ffffffffc02021c6:	00003617          	auipc	a2,0x3
ffffffffc02021ca:	af260613          	addi	a2,a2,-1294 # ffffffffc0204cb8 <commands+0x870>
ffffffffc02021ce:	1c000593          	li	a1,448
ffffffffc02021d2:	00003517          	auipc	a0,0x3
ffffffffc02021d6:	ef650513          	addi	a0,a0,-266 # ffffffffc02050c8 <default_pmm_manager+0x78>
ffffffffc02021da:	99afe0ef          	jal	ra,ffffffffc0200374 <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02021de:	00003617          	auipc	a2,0x3
ffffffffc02021e2:	00a60613          	addi	a2,a2,10 # ffffffffc02051e8 <default_pmm_manager+0x198>
ffffffffc02021e6:	07700593          	li	a1,119
ffffffffc02021ea:	00003517          	auipc	a0,0x3
ffffffffc02021ee:	ede50513          	addi	a0,a0,-290 # ffffffffc02050c8 <default_pmm_manager+0x78>
ffffffffc02021f2:	982fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc02021f6:	00003697          	auipc	a3,0x3
ffffffffc02021fa:	0ea68693          	addi	a3,a3,234 # ffffffffc02052e0 <default_pmm_manager+0x290>
ffffffffc02021fe:	00003617          	auipc	a2,0x3
ffffffffc0202202:	aba60613          	addi	a2,a2,-1350 # ffffffffc0204cb8 <commands+0x870>
ffffffffc0202206:	19a00593          	li	a1,410
ffffffffc020220a:	00003517          	auipc	a0,0x3
ffffffffc020220e:	ebe50513          	addi	a0,a0,-322 # ffffffffc02050c8 <default_pmm_manager+0x78>
ffffffffc0202212:	962fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc0202216:	00003697          	auipc	a3,0x3
ffffffffc020221a:	09a68693          	addi	a3,a3,154 # ffffffffc02052b0 <default_pmm_manager+0x260>
ffffffffc020221e:	00003617          	auipc	a2,0x3
ffffffffc0202222:	a9a60613          	addi	a2,a2,-1382 # ffffffffc0204cb8 <commands+0x870>
ffffffffc0202226:	19800593          	li	a1,408
ffffffffc020222a:	00003517          	auipc	a0,0x3
ffffffffc020222e:	e9e50513          	addi	a0,a0,-354 # ffffffffc02050c8 <default_pmm_manager+0x78>
ffffffffc0202232:	942fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(*ptep & PTE_U);
ffffffffc0202236:	00003697          	auipc	a3,0x3
ffffffffc020223a:	1c268693          	addi	a3,a3,450 # ffffffffc02053f8 <default_pmm_manager+0x3a8>
ffffffffc020223e:	00003617          	auipc	a2,0x3
ffffffffc0202242:	a7a60613          	addi	a2,a2,-1414 # ffffffffc0204cb8 <commands+0x870>
ffffffffc0202246:	1a500593          	li	a1,421
ffffffffc020224a:	00003517          	auipc	a0,0x3
ffffffffc020224e:	e7e50513          	addi	a0,a0,-386 # ffffffffc02050c8 <default_pmm_manager+0x78>
ffffffffc0202252:	922fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0202256:	00003697          	auipc	a3,0x3
ffffffffc020225a:	17268693          	addi	a3,a3,370 # ffffffffc02053c8 <default_pmm_manager+0x378>
ffffffffc020225e:	00003617          	auipc	a2,0x3
ffffffffc0202262:	a5a60613          	addi	a2,a2,-1446 # ffffffffc0204cb8 <commands+0x870>
ffffffffc0202266:	1a400593          	li	a1,420
ffffffffc020226a:	00003517          	auipc	a0,0x3
ffffffffc020226e:	e5e50513          	addi	a0,a0,-418 # ffffffffc02050c8 <default_pmm_manager+0x78>
ffffffffc0202272:	902fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0202276:	00003697          	auipc	a3,0x3
ffffffffc020227a:	11a68693          	addi	a3,a3,282 # ffffffffc0205390 <default_pmm_manager+0x340>
ffffffffc020227e:	00003617          	auipc	a2,0x3
ffffffffc0202282:	a3a60613          	addi	a2,a2,-1478 # ffffffffc0204cb8 <commands+0x870>
ffffffffc0202286:	1a300593          	li	a1,419
ffffffffc020228a:	00003517          	auipc	a0,0x3
ffffffffc020228e:	e3e50513          	addi	a0,a0,-450 # ffffffffc02050c8 <default_pmm_manager+0x78>
ffffffffc0202292:	8e2fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0202296:	00003697          	auipc	a3,0x3
ffffffffc020229a:	0d268693          	addi	a3,a3,210 # ffffffffc0205368 <default_pmm_manager+0x318>
ffffffffc020229e:	00003617          	auipc	a2,0x3
ffffffffc02022a2:	a1a60613          	addi	a2,a2,-1510 # ffffffffc0204cb8 <commands+0x870>
ffffffffc02022a6:	1a000593          	li	a1,416
ffffffffc02022aa:	00003517          	auipc	a0,0x3
ffffffffc02022ae:	e1e50513          	addi	a0,a0,-482 # ffffffffc02050c8 <default_pmm_manager+0x78>
ffffffffc02022b2:	8c2fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc02022b6:	86da                	mv	a3,s6
ffffffffc02022b8:	00003617          	auipc	a2,0x3
ffffffffc02022bc:	de860613          	addi	a2,a2,-536 # ffffffffc02050a0 <default_pmm_manager+0x50>
ffffffffc02022c0:	19f00593          	li	a1,415
ffffffffc02022c4:	00003517          	auipc	a0,0x3
ffffffffc02022c8:	e0450513          	addi	a0,a0,-508 # ffffffffc02050c8 <default_pmm_manager+0x78>
ffffffffc02022cc:	8a8fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc02022d0:	86be                	mv	a3,a5
ffffffffc02022d2:	00003617          	auipc	a2,0x3
ffffffffc02022d6:	dce60613          	addi	a2,a2,-562 # ffffffffc02050a0 <default_pmm_manager+0x50>
ffffffffc02022da:	19e00593          	li	a1,414
ffffffffc02022de:	00003517          	auipc	a0,0x3
ffffffffc02022e2:	dea50513          	addi	a0,a0,-534 # ffffffffc02050c8 <default_pmm_manager+0x78>
ffffffffc02022e6:	88efe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc02022ea:	00003697          	auipc	a3,0x3
ffffffffc02022ee:	06668693          	addi	a3,a3,102 # ffffffffc0205350 <default_pmm_manager+0x300>
ffffffffc02022f2:	00003617          	auipc	a2,0x3
ffffffffc02022f6:	9c660613          	addi	a2,a2,-1594 # ffffffffc0204cb8 <commands+0x870>
ffffffffc02022fa:	19c00593          	li	a1,412
ffffffffc02022fe:	00003517          	auipc	a0,0x3
ffffffffc0202302:	dca50513          	addi	a0,a0,-566 # ffffffffc02050c8 <default_pmm_manager+0x78>
ffffffffc0202306:	86efe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc020230a:	00003697          	auipc	a3,0x3
ffffffffc020230e:	02e68693          	addi	a3,a3,46 # ffffffffc0205338 <default_pmm_manager+0x2e8>
ffffffffc0202312:	00003617          	auipc	a2,0x3
ffffffffc0202316:	9a660613          	addi	a2,a2,-1626 # ffffffffc0204cb8 <commands+0x870>
ffffffffc020231a:	19b00593          	li	a1,411
ffffffffc020231e:	00003517          	auipc	a0,0x3
ffffffffc0202322:	daa50513          	addi	a0,a0,-598 # ffffffffc02050c8 <default_pmm_manager+0x78>
ffffffffc0202326:	84efe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc020232a:	00003697          	auipc	a3,0x3
ffffffffc020232e:	00e68693          	addi	a3,a3,14 # ffffffffc0205338 <default_pmm_manager+0x2e8>
ffffffffc0202332:	00003617          	auipc	a2,0x3
ffffffffc0202336:	98660613          	addi	a2,a2,-1658 # ffffffffc0204cb8 <commands+0x870>
ffffffffc020233a:	1ae00593          	li	a1,430
ffffffffc020233e:	00003517          	auipc	a0,0x3
ffffffffc0202342:	d8a50513          	addi	a0,a0,-630 # ffffffffc02050c8 <default_pmm_manager+0x78>
ffffffffc0202346:	82efe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc020234a:	00003697          	auipc	a3,0x3
ffffffffc020234e:	07e68693          	addi	a3,a3,126 # ffffffffc02053c8 <default_pmm_manager+0x378>
ffffffffc0202352:	00003617          	auipc	a2,0x3
ffffffffc0202356:	96660613          	addi	a2,a2,-1690 # ffffffffc0204cb8 <commands+0x870>
ffffffffc020235a:	1ad00593          	li	a1,429
ffffffffc020235e:	00003517          	auipc	a0,0x3
ffffffffc0202362:	d6a50513          	addi	a0,a0,-662 # ffffffffc02050c8 <default_pmm_manager+0x78>
ffffffffc0202366:	80efe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc020236a:	00003697          	auipc	a3,0x3
ffffffffc020236e:	12668693          	addi	a3,a3,294 # ffffffffc0205490 <default_pmm_manager+0x440>
ffffffffc0202372:	00003617          	auipc	a2,0x3
ffffffffc0202376:	94660613          	addi	a2,a2,-1722 # ffffffffc0204cb8 <commands+0x870>
ffffffffc020237a:	1ac00593          	li	a1,428
ffffffffc020237e:	00003517          	auipc	a0,0x3
ffffffffc0202382:	d4a50513          	addi	a0,a0,-694 # ffffffffc02050c8 <default_pmm_manager+0x78>
ffffffffc0202386:	feffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p1) == 2);
ffffffffc020238a:	00003697          	auipc	a3,0x3
ffffffffc020238e:	0ee68693          	addi	a3,a3,238 # ffffffffc0205478 <default_pmm_manager+0x428>
ffffffffc0202392:	00003617          	auipc	a2,0x3
ffffffffc0202396:	92660613          	addi	a2,a2,-1754 # ffffffffc0204cb8 <commands+0x870>
ffffffffc020239a:	1ab00593          	li	a1,427
ffffffffc020239e:	00003517          	auipc	a0,0x3
ffffffffc02023a2:	d2a50513          	addi	a0,a0,-726 # ffffffffc02050c8 <default_pmm_manager+0x78>
ffffffffc02023a6:	fcffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc02023aa:	00003697          	auipc	a3,0x3
ffffffffc02023ae:	09e68693          	addi	a3,a3,158 # ffffffffc0205448 <default_pmm_manager+0x3f8>
ffffffffc02023b2:	00003617          	auipc	a2,0x3
ffffffffc02023b6:	90660613          	addi	a2,a2,-1786 # ffffffffc0204cb8 <commands+0x870>
ffffffffc02023ba:	1aa00593          	li	a1,426
ffffffffc02023be:	00003517          	auipc	a0,0x3
ffffffffc02023c2:	d0a50513          	addi	a0,a0,-758 # ffffffffc02050c8 <default_pmm_manager+0x78>
ffffffffc02023c6:	faffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p2) == 1);
ffffffffc02023ca:	00003697          	auipc	a3,0x3
ffffffffc02023ce:	06668693          	addi	a3,a3,102 # ffffffffc0205430 <default_pmm_manager+0x3e0>
ffffffffc02023d2:	00003617          	auipc	a2,0x3
ffffffffc02023d6:	8e660613          	addi	a2,a2,-1818 # ffffffffc0204cb8 <commands+0x870>
ffffffffc02023da:	1a800593          	li	a1,424
ffffffffc02023de:	00003517          	auipc	a0,0x3
ffffffffc02023e2:	cea50513          	addi	a0,a0,-790 # ffffffffc02050c8 <default_pmm_manager+0x78>
ffffffffc02023e6:	f8ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc02023ea:	00003697          	auipc	a3,0x3
ffffffffc02023ee:	02e68693          	addi	a3,a3,46 # ffffffffc0205418 <default_pmm_manager+0x3c8>
ffffffffc02023f2:	00003617          	auipc	a2,0x3
ffffffffc02023f6:	8c660613          	addi	a2,a2,-1850 # ffffffffc0204cb8 <commands+0x870>
ffffffffc02023fa:	1a700593          	li	a1,423
ffffffffc02023fe:	00003517          	auipc	a0,0x3
ffffffffc0202402:	cca50513          	addi	a0,a0,-822 # ffffffffc02050c8 <default_pmm_manager+0x78>
ffffffffc0202406:	f6ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(*ptep & PTE_W);
ffffffffc020240a:	00003697          	auipc	a3,0x3
ffffffffc020240e:	ffe68693          	addi	a3,a3,-2 # ffffffffc0205408 <default_pmm_manager+0x3b8>
ffffffffc0202412:	00003617          	auipc	a2,0x3
ffffffffc0202416:	8a660613          	addi	a2,a2,-1882 # ffffffffc0204cb8 <commands+0x870>
ffffffffc020241a:	1a600593          	li	a1,422
ffffffffc020241e:	00003517          	auipc	a0,0x3
ffffffffc0202422:	caa50513          	addi	a0,a0,-854 # ffffffffc02050c8 <default_pmm_manager+0x78>
ffffffffc0202426:	f4ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc020242a:	00003697          	auipc	a3,0x3
ffffffffc020242e:	0d668693          	addi	a3,a3,214 # ffffffffc0205500 <default_pmm_manager+0x4b0>
ffffffffc0202432:	00003617          	auipc	a2,0x3
ffffffffc0202436:	88660613          	addi	a2,a2,-1914 # ffffffffc0204cb8 <commands+0x870>
ffffffffc020243a:	1e800593          	li	a1,488
ffffffffc020243e:	00003517          	auipc	a0,0x3
ffffffffc0202442:	c8a50513          	addi	a0,a0,-886 # ffffffffc02050c8 <default_pmm_manager+0x78>
ffffffffc0202446:	f2ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(strlen((const char *)0x100) == 0);
ffffffffc020244a:	00003697          	auipc	a3,0x3
ffffffffc020244e:	25e68693          	addi	a3,a3,606 # ffffffffc02056a8 <default_pmm_manager+0x658>
ffffffffc0202452:	00003617          	auipc	a2,0x3
ffffffffc0202456:	86660613          	addi	a2,a2,-1946 # ffffffffc0204cb8 <commands+0x870>
ffffffffc020245a:	1e000593          	li	a1,480
ffffffffc020245e:	00003517          	auipc	a0,0x3
ffffffffc0202462:	c6a50513          	addi	a0,a0,-918 # ffffffffc02050c8 <default_pmm_manager+0x78>
ffffffffc0202466:	f0ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc020246a:	00003697          	auipc	a3,0x3
ffffffffc020246e:	20668693          	addi	a3,a3,518 # ffffffffc0205670 <default_pmm_manager+0x620>
ffffffffc0202472:	00003617          	auipc	a2,0x3
ffffffffc0202476:	84660613          	addi	a2,a2,-1978 # ffffffffc0204cb8 <commands+0x870>
ffffffffc020247a:	1dd00593          	li	a1,477
ffffffffc020247e:	00003517          	auipc	a0,0x3
ffffffffc0202482:	c4a50513          	addi	a0,a0,-950 # ffffffffc02050c8 <default_pmm_manager+0x78>
ffffffffc0202486:	eeffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p) == 2);
ffffffffc020248a:	00003697          	auipc	a3,0x3
ffffffffc020248e:	1b668693          	addi	a3,a3,438 # ffffffffc0205640 <default_pmm_manager+0x5f0>
ffffffffc0202492:	00003617          	auipc	a2,0x3
ffffffffc0202496:	82660613          	addi	a2,a2,-2010 # ffffffffc0204cb8 <commands+0x870>
ffffffffc020249a:	1d900593          	li	a1,473
ffffffffc020249e:	00003517          	auipc	a0,0x3
ffffffffc02024a2:	c2a50513          	addi	a0,a0,-982 # ffffffffc02050c8 <default_pmm_manager+0x78>
ffffffffc02024a6:	ecffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p1) == 0);
ffffffffc02024aa:	00003697          	auipc	a3,0x3
ffffffffc02024ae:	01668693          	addi	a3,a3,22 # ffffffffc02054c0 <default_pmm_manager+0x470>
ffffffffc02024b2:	00003617          	auipc	a2,0x3
ffffffffc02024b6:	80660613          	addi	a2,a2,-2042 # ffffffffc0204cb8 <commands+0x870>
ffffffffc02024ba:	1b600593          	li	a1,438
ffffffffc02024be:	00003517          	auipc	a0,0x3
ffffffffc02024c2:	c0a50513          	addi	a0,a0,-1014 # ffffffffc02050c8 <default_pmm_manager+0x78>
ffffffffc02024c6:	eaffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc02024ca:	00003697          	auipc	a3,0x3
ffffffffc02024ce:	fc668693          	addi	a3,a3,-58 # ffffffffc0205490 <default_pmm_manager+0x440>
ffffffffc02024d2:	00002617          	auipc	a2,0x2
ffffffffc02024d6:	7e660613          	addi	a2,a2,2022 # ffffffffc0204cb8 <commands+0x870>
ffffffffc02024da:	1b300593          	li	a1,435
ffffffffc02024de:	00003517          	auipc	a0,0x3
ffffffffc02024e2:	bea50513          	addi	a0,a0,-1046 # ffffffffc02050c8 <default_pmm_manager+0x78>
ffffffffc02024e6:	e8ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc02024ea:	00003697          	auipc	a3,0x3
ffffffffc02024ee:	e6668693          	addi	a3,a3,-410 # ffffffffc0205350 <default_pmm_manager+0x300>
ffffffffc02024f2:	00002617          	auipc	a2,0x2
ffffffffc02024f6:	7c660613          	addi	a2,a2,1990 # ffffffffc0204cb8 <commands+0x870>
ffffffffc02024fa:	1b200593          	li	a1,434
ffffffffc02024fe:	00003517          	auipc	a0,0x3
ffffffffc0202502:	bca50513          	addi	a0,a0,-1078 # ffffffffc02050c8 <default_pmm_manager+0x78>
ffffffffc0202506:	e6ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((*ptep & PTE_U) == 0);
ffffffffc020250a:	00003697          	auipc	a3,0x3
ffffffffc020250e:	f9e68693          	addi	a3,a3,-98 # ffffffffc02054a8 <default_pmm_manager+0x458>
ffffffffc0202512:	00002617          	auipc	a2,0x2
ffffffffc0202516:	7a660613          	addi	a2,a2,1958 # ffffffffc0204cb8 <commands+0x870>
ffffffffc020251a:	1af00593          	li	a1,431
ffffffffc020251e:	00003517          	auipc	a0,0x3
ffffffffc0202522:	baa50513          	addi	a0,a0,-1110 # ffffffffc02050c8 <default_pmm_manager+0x78>
ffffffffc0202526:	e4ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc020252a:	00003697          	auipc	a3,0x3
ffffffffc020252e:	fae68693          	addi	a3,a3,-82 # ffffffffc02054d8 <default_pmm_manager+0x488>
ffffffffc0202532:	00002617          	auipc	a2,0x2
ffffffffc0202536:	78660613          	addi	a2,a2,1926 # ffffffffc0204cb8 <commands+0x870>
ffffffffc020253a:	1b900593          	li	a1,441
ffffffffc020253e:	00003517          	auipc	a0,0x3
ffffffffc0202542:	b8a50513          	addi	a0,a0,-1142 # ffffffffc02050c8 <default_pmm_manager+0x78>
ffffffffc0202546:	e2ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc020254a:	00003697          	auipc	a3,0x3
ffffffffc020254e:	f4668693          	addi	a3,a3,-186 # ffffffffc0205490 <default_pmm_manager+0x440>
ffffffffc0202552:	00002617          	auipc	a2,0x2
ffffffffc0202556:	76660613          	addi	a2,a2,1894 # ffffffffc0204cb8 <commands+0x870>
ffffffffc020255a:	1b700593          	li	a1,439
ffffffffc020255e:	00003517          	auipc	a0,0x3
ffffffffc0202562:	b6a50513          	addi	a0,a0,-1174 # ffffffffc02050c8 <default_pmm_manager+0x78>
ffffffffc0202566:	e0ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc020256a:	00003697          	auipc	a3,0x3
ffffffffc020256e:	cc668693          	addi	a3,a3,-826 # ffffffffc0205230 <default_pmm_manager+0x1e0>
ffffffffc0202572:	00002617          	auipc	a2,0x2
ffffffffc0202576:	74660613          	addi	a2,a2,1862 # ffffffffc0204cb8 <commands+0x870>
ffffffffc020257a:	19200593          	li	a1,402
ffffffffc020257e:	00003517          	auipc	a0,0x3
ffffffffc0202582:	b4a50513          	addi	a0,a0,-1206 # ffffffffc02050c8 <default_pmm_manager+0x78>
ffffffffc0202586:	deffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc020258a:	00003617          	auipc	a2,0x3
ffffffffc020258e:	c5e60613          	addi	a2,a2,-930 # ffffffffc02051e8 <default_pmm_manager+0x198>
ffffffffc0202592:	0bd00593          	li	a1,189
ffffffffc0202596:	00003517          	auipc	a0,0x3
ffffffffc020259a:	b3250513          	addi	a0,a0,-1230 # ffffffffc02050c8 <default_pmm_manager+0x78>
ffffffffc020259e:	dd7fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc02025a2:	00003697          	auipc	a3,0x3
ffffffffc02025a6:	05e68693          	addi	a3,a3,94 # ffffffffc0205600 <default_pmm_manager+0x5b0>
ffffffffc02025aa:	00002617          	auipc	a2,0x2
ffffffffc02025ae:	70e60613          	addi	a2,a2,1806 # ffffffffc0204cb8 <commands+0x870>
ffffffffc02025b2:	1d800593          	li	a1,472
ffffffffc02025b6:	00003517          	auipc	a0,0x3
ffffffffc02025ba:	b1250513          	addi	a0,a0,-1262 # ffffffffc02050c8 <default_pmm_manager+0x78>
ffffffffc02025be:	db7fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p) == 1);
ffffffffc02025c2:	00003697          	auipc	a3,0x3
ffffffffc02025c6:	02668693          	addi	a3,a3,38 # ffffffffc02055e8 <default_pmm_manager+0x598>
ffffffffc02025ca:	00002617          	auipc	a2,0x2
ffffffffc02025ce:	6ee60613          	addi	a2,a2,1774 # ffffffffc0204cb8 <commands+0x870>
ffffffffc02025d2:	1d700593          	li	a1,471
ffffffffc02025d6:	00003517          	auipc	a0,0x3
ffffffffc02025da:	af250513          	addi	a0,a0,-1294 # ffffffffc02050c8 <default_pmm_manager+0x78>
ffffffffc02025de:	d97fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc02025e2:	00003697          	auipc	a3,0x3
ffffffffc02025e6:	fce68693          	addi	a3,a3,-50 # ffffffffc02055b0 <default_pmm_manager+0x560>
ffffffffc02025ea:	00002617          	auipc	a2,0x2
ffffffffc02025ee:	6ce60613          	addi	a2,a2,1742 # ffffffffc0204cb8 <commands+0x870>
ffffffffc02025f2:	1d600593          	li	a1,470
ffffffffc02025f6:	00003517          	auipc	a0,0x3
ffffffffc02025fa:	ad250513          	addi	a0,a0,-1326 # ffffffffc02050c8 <default_pmm_manager+0x78>
ffffffffc02025fe:	d77fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(boot_pgdir[0] == 0);
ffffffffc0202602:	00003697          	auipc	a3,0x3
ffffffffc0202606:	f9668693          	addi	a3,a3,-106 # ffffffffc0205598 <default_pmm_manager+0x548>
ffffffffc020260a:	00002617          	auipc	a2,0x2
ffffffffc020260e:	6ae60613          	addi	a2,a2,1710 # ffffffffc0204cb8 <commands+0x870>
ffffffffc0202612:	1d200593          	li	a1,466
ffffffffc0202616:	00003517          	auipc	a0,0x3
ffffffffc020261a:	ab250513          	addi	a0,a0,-1358 # ffffffffc02050c8 <default_pmm_manager+0x78>
ffffffffc020261e:	d57fd0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0202622 <tlb_invalidate>:
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc0202622:	12000073          	sfence.vma
void tlb_invalidate(pde_t *pgdir, uintptr_t la) { flush_tlb(); }
ffffffffc0202626:	8082                	ret

ffffffffc0202628 <pgdir_alloc_page>:
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0202628:	7179                	addi	sp,sp,-48
ffffffffc020262a:	e84a                	sd	s2,16(sp)
ffffffffc020262c:	892a                	mv	s2,a0
    struct Page *page = alloc_page();
ffffffffc020262e:	4505                	li	a0,1
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0202630:	f022                	sd	s0,32(sp)
ffffffffc0202632:	ec26                	sd	s1,24(sp)
ffffffffc0202634:	e44e                	sd	s3,8(sp)
ffffffffc0202636:	f406                	sd	ra,40(sp)
ffffffffc0202638:	84ae                	mv	s1,a1
ffffffffc020263a:	89b2                	mv	s3,a2
    struct Page *page = alloc_page();
ffffffffc020263c:	852ff0ef          	jal	ra,ffffffffc020168e <alloc_pages>
ffffffffc0202640:	842a                	mv	s0,a0
    if (page != NULL) {
ffffffffc0202642:	cd19                	beqz	a0,ffffffffc0202660 <pgdir_alloc_page+0x38>
        if (page_insert(pgdir, page, la, perm) != 0) {
ffffffffc0202644:	85aa                	mv	a1,a0
ffffffffc0202646:	86ce                	mv	a3,s3
ffffffffc0202648:	8626                	mv	a2,s1
ffffffffc020264a:	854a                	mv	a0,s2
ffffffffc020264c:	c28ff0ef          	jal	ra,ffffffffc0201a74 <page_insert>
ffffffffc0202650:	ed39                	bnez	a0,ffffffffc02026ae <pgdir_alloc_page+0x86>
        if (swap_init_ok) {
ffffffffc0202652:	0000f797          	auipc	a5,0xf
ffffffffc0202656:	e1e78793          	addi	a5,a5,-482 # ffffffffc0211470 <swap_init_ok>
ffffffffc020265a:	439c                	lw	a5,0(a5)
ffffffffc020265c:	2781                	sext.w	a5,a5
ffffffffc020265e:	eb89                	bnez	a5,ffffffffc0202670 <pgdir_alloc_page+0x48>
}
ffffffffc0202660:	8522                	mv	a0,s0
ffffffffc0202662:	70a2                	ld	ra,40(sp)
ffffffffc0202664:	7402                	ld	s0,32(sp)
ffffffffc0202666:	64e2                	ld	s1,24(sp)
ffffffffc0202668:	6942                	ld	s2,16(sp)
ffffffffc020266a:	69a2                	ld	s3,8(sp)
ffffffffc020266c:	6145                	addi	sp,sp,48
ffffffffc020266e:	8082                	ret
            swap_map_swappable(check_mm_struct, la, page, 0);
ffffffffc0202670:	0000f797          	auipc	a5,0xf
ffffffffc0202674:	f2878793          	addi	a5,a5,-216 # ffffffffc0211598 <check_mm_struct>
ffffffffc0202678:	6388                	ld	a0,0(a5)
ffffffffc020267a:	4681                	li	a3,0
ffffffffc020267c:	8622                	mv	a2,s0
ffffffffc020267e:	85a6                	mv	a1,s1
ffffffffc0202680:	06d000ef          	jal	ra,ffffffffc0202eec <swap_map_swappable>
            assert(page_ref(page) == 1);
ffffffffc0202684:	4018                	lw	a4,0(s0)
            page->pra_vaddr = la;
ffffffffc0202686:	e024                	sd	s1,64(s0)
            assert(page_ref(page) == 1);
ffffffffc0202688:	4785                	li	a5,1
ffffffffc020268a:	fcf70be3          	beq	a4,a5,ffffffffc0202660 <pgdir_alloc_page+0x38>
ffffffffc020268e:	00003697          	auipc	a3,0x3
ffffffffc0202692:	aba68693          	addi	a3,a3,-1350 # ffffffffc0205148 <default_pmm_manager+0xf8>
ffffffffc0202696:	00002617          	auipc	a2,0x2
ffffffffc020269a:	62260613          	addi	a2,a2,1570 # ffffffffc0204cb8 <commands+0x870>
ffffffffc020269e:	17a00593          	li	a1,378
ffffffffc02026a2:	00003517          	auipc	a0,0x3
ffffffffc02026a6:	a2650513          	addi	a0,a0,-1498 # ffffffffc02050c8 <default_pmm_manager+0x78>
ffffffffc02026aa:	ccbfd0ef          	jal	ra,ffffffffc0200374 <__panic>
            free_page(page);
ffffffffc02026ae:	8522                	mv	a0,s0
ffffffffc02026b0:	4585                	li	a1,1
ffffffffc02026b2:	864ff0ef          	jal	ra,ffffffffc0201716 <free_pages>
            return NULL;
ffffffffc02026b6:	4401                	li	s0,0
ffffffffc02026b8:	b765                	j	ffffffffc0202660 <pgdir_alloc_page+0x38>

ffffffffc02026ba <kmalloc>:
}

void *kmalloc(size_t n) {
ffffffffc02026ba:	1141                	addi	sp,sp,-16
    void *ptr = NULL;
    struct Page *base = NULL;
    assert(n > 0 && n < 1024 * 0124);
ffffffffc02026bc:	67d5                	lui	a5,0x15
void *kmalloc(size_t n) {
ffffffffc02026be:	e406                	sd	ra,8(sp)
    assert(n > 0 && n < 1024 * 0124);
ffffffffc02026c0:	fff50713          	addi	a4,a0,-1
ffffffffc02026c4:	17f9                	addi	a5,a5,-2
ffffffffc02026c6:	04e7ee63          	bltu	a5,a4,ffffffffc0202722 <kmalloc+0x68>
    int num_pages = (n + PGSIZE - 1) / PGSIZE;
ffffffffc02026ca:	6785                	lui	a5,0x1
ffffffffc02026cc:	17fd                	addi	a5,a5,-1
ffffffffc02026ce:	953e                	add	a0,a0,a5
    base = alloc_pages(num_pages);
ffffffffc02026d0:	8131                	srli	a0,a0,0xc
ffffffffc02026d2:	fbdfe0ef          	jal	ra,ffffffffc020168e <alloc_pages>
    assert(base != NULL);
ffffffffc02026d6:	c159                	beqz	a0,ffffffffc020275c <kmalloc+0xa2>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02026d8:	0000f797          	auipc	a5,0xf
ffffffffc02026dc:	dd878793          	addi	a5,a5,-552 # ffffffffc02114b0 <pages>
ffffffffc02026e0:	639c                	ld	a5,0(a5)
ffffffffc02026e2:	8d1d                	sub	a0,a0,a5
ffffffffc02026e4:	00002797          	auipc	a5,0x2
ffffffffc02026e8:	5bc78793          	addi	a5,a5,1468 # ffffffffc0204ca0 <commands+0x858>
ffffffffc02026ec:	6394                	ld	a3,0(a5)
ffffffffc02026ee:	850d                	srai	a0,a0,0x3
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc02026f0:	0000f797          	auipc	a5,0xf
ffffffffc02026f4:	d7078793          	addi	a5,a5,-656 # ffffffffc0211460 <npage>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02026f8:	02d50533          	mul	a0,a0,a3
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc02026fc:	6398                	ld	a4,0(a5)
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02026fe:	000806b7          	lui	a3,0x80
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0202702:	57fd                	li	a5,-1
ffffffffc0202704:	83b1                	srli	a5,a5,0xc
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202706:	9536                	add	a0,a0,a3
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0202708:	8fe9                	and	a5,a5,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc020270a:	0532                	slli	a0,a0,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc020270c:	02e7fb63          	bleu	a4,a5,ffffffffc0202742 <kmalloc+0x88>
ffffffffc0202710:	0000f797          	auipc	a5,0xf
ffffffffc0202714:	d9078793          	addi	a5,a5,-624 # ffffffffc02114a0 <va_pa_offset>
ffffffffc0202718:	639c                	ld	a5,0(a5)
    ptr = page2kva(base);
    return ptr;
}
ffffffffc020271a:	60a2                	ld	ra,8(sp)
ffffffffc020271c:	953e                	add	a0,a0,a5
ffffffffc020271e:	0141                	addi	sp,sp,16
ffffffffc0202720:	8082                	ret
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0202722:	00003697          	auipc	a3,0x3
ffffffffc0202726:	9c668693          	addi	a3,a3,-1594 # ffffffffc02050e8 <default_pmm_manager+0x98>
ffffffffc020272a:	00002617          	auipc	a2,0x2
ffffffffc020272e:	58e60613          	addi	a2,a2,1422 # ffffffffc0204cb8 <commands+0x870>
ffffffffc0202732:	1f000593          	li	a1,496
ffffffffc0202736:	00003517          	auipc	a0,0x3
ffffffffc020273a:	99250513          	addi	a0,a0,-1646 # ffffffffc02050c8 <default_pmm_manager+0x78>
ffffffffc020273e:	c37fd0ef          	jal	ra,ffffffffc0200374 <__panic>
ffffffffc0202742:	86aa                	mv	a3,a0
ffffffffc0202744:	00003617          	auipc	a2,0x3
ffffffffc0202748:	95c60613          	addi	a2,a2,-1700 # ffffffffc02050a0 <default_pmm_manager+0x50>
ffffffffc020274c:	06a00593          	li	a1,106
ffffffffc0202750:	00003517          	auipc	a0,0x3
ffffffffc0202754:	9e850513          	addi	a0,a0,-1560 # ffffffffc0205138 <default_pmm_manager+0xe8>
ffffffffc0202758:	c1dfd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(base != NULL);
ffffffffc020275c:	00003697          	auipc	a3,0x3
ffffffffc0202760:	9ac68693          	addi	a3,a3,-1620 # ffffffffc0205108 <default_pmm_manager+0xb8>
ffffffffc0202764:	00002617          	auipc	a2,0x2
ffffffffc0202768:	55460613          	addi	a2,a2,1364 # ffffffffc0204cb8 <commands+0x870>
ffffffffc020276c:	1f300593          	li	a1,499
ffffffffc0202770:	00003517          	auipc	a0,0x3
ffffffffc0202774:	95850513          	addi	a0,a0,-1704 # ffffffffc02050c8 <default_pmm_manager+0x78>
ffffffffc0202778:	bfdfd0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc020277c <kfree>:

void kfree(void *ptr, size_t n) {
ffffffffc020277c:	1141                	addi	sp,sp,-16
    assert(n > 0 && n < 1024 * 0124);
ffffffffc020277e:	67d5                	lui	a5,0x15
void kfree(void *ptr, size_t n) {
ffffffffc0202780:	e406                	sd	ra,8(sp)
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0202782:	fff58713          	addi	a4,a1,-1
ffffffffc0202786:	17f9                	addi	a5,a5,-2
ffffffffc0202788:	04e7eb63          	bltu	a5,a4,ffffffffc02027de <kfree+0x62>
    assert(ptr != NULL);
ffffffffc020278c:	c941                	beqz	a0,ffffffffc020281c <kfree+0xa0>
    struct Page *base = NULL;
    int num_pages = (n + PGSIZE - 1) / PGSIZE;
ffffffffc020278e:	6785                	lui	a5,0x1
ffffffffc0202790:	17fd                	addi	a5,a5,-1
ffffffffc0202792:	95be                	add	a1,a1,a5
static inline struct Page *kva2page(void *kva) { return pa2page(PADDR(kva)); }
ffffffffc0202794:	c02007b7          	lui	a5,0xc0200
ffffffffc0202798:	81b1                	srli	a1,a1,0xc
ffffffffc020279a:	06f56463          	bltu	a0,a5,ffffffffc0202802 <kfree+0x86>
ffffffffc020279e:	0000f797          	auipc	a5,0xf
ffffffffc02027a2:	d0278793          	addi	a5,a5,-766 # ffffffffc02114a0 <va_pa_offset>
ffffffffc02027a6:	639c                	ld	a5,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc02027a8:	0000f717          	auipc	a4,0xf
ffffffffc02027ac:	cb870713          	addi	a4,a4,-840 # ffffffffc0211460 <npage>
ffffffffc02027b0:	6318                	ld	a4,0(a4)
static inline struct Page *kva2page(void *kva) { return pa2page(PADDR(kva)); }
ffffffffc02027b2:	40f507b3          	sub	a5,a0,a5
    if (PPN(pa) >= npage) {
ffffffffc02027b6:	83b1                	srli	a5,a5,0xc
ffffffffc02027b8:	04e7f363          	bleu	a4,a5,ffffffffc02027fe <kfree+0x82>
    return &pages[PPN(pa) - nbase];
ffffffffc02027bc:	fff80537          	lui	a0,0xfff80
ffffffffc02027c0:	97aa                	add	a5,a5,a0
ffffffffc02027c2:	0000f697          	auipc	a3,0xf
ffffffffc02027c6:	cee68693          	addi	a3,a3,-786 # ffffffffc02114b0 <pages>
ffffffffc02027ca:	6288                	ld	a0,0(a3)
ffffffffc02027cc:	00379713          	slli	a4,a5,0x3
    base = kva2page(ptr);
    free_pages(base, num_pages);
}
ffffffffc02027d0:	60a2                	ld	ra,8(sp)
ffffffffc02027d2:	97ba                	add	a5,a5,a4
ffffffffc02027d4:	078e                	slli	a5,a5,0x3
    free_pages(base, num_pages);
ffffffffc02027d6:	953e                	add	a0,a0,a5
}
ffffffffc02027d8:	0141                	addi	sp,sp,16
    free_pages(base, num_pages);
ffffffffc02027da:	f3dfe06f          	j	ffffffffc0201716 <free_pages>
    assert(n > 0 && n < 1024 * 0124);
ffffffffc02027de:	00003697          	auipc	a3,0x3
ffffffffc02027e2:	90a68693          	addi	a3,a3,-1782 # ffffffffc02050e8 <default_pmm_manager+0x98>
ffffffffc02027e6:	00002617          	auipc	a2,0x2
ffffffffc02027ea:	4d260613          	addi	a2,a2,1234 # ffffffffc0204cb8 <commands+0x870>
ffffffffc02027ee:	1f900593          	li	a1,505
ffffffffc02027f2:	00003517          	auipc	a0,0x3
ffffffffc02027f6:	8d650513          	addi	a0,a0,-1834 # ffffffffc02050c8 <default_pmm_manager+0x78>
ffffffffc02027fa:	b7bfd0ef          	jal	ra,ffffffffc0200374 <__panic>
ffffffffc02027fe:	e75fe0ef          	jal	ra,ffffffffc0201672 <pa2page.part.4>
static inline struct Page *kva2page(void *kva) { return pa2page(PADDR(kva)); }
ffffffffc0202802:	86aa                	mv	a3,a0
ffffffffc0202804:	00003617          	auipc	a2,0x3
ffffffffc0202808:	9e460613          	addi	a2,a2,-1564 # ffffffffc02051e8 <default_pmm_manager+0x198>
ffffffffc020280c:	06c00593          	li	a1,108
ffffffffc0202810:	00003517          	auipc	a0,0x3
ffffffffc0202814:	92850513          	addi	a0,a0,-1752 # ffffffffc0205138 <default_pmm_manager+0xe8>
ffffffffc0202818:	b5dfd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(ptr != NULL);
ffffffffc020281c:	00003697          	auipc	a3,0x3
ffffffffc0202820:	8bc68693          	addi	a3,a3,-1860 # ffffffffc02050d8 <default_pmm_manager+0x88>
ffffffffc0202824:	00002617          	auipc	a2,0x2
ffffffffc0202828:	49460613          	addi	a2,a2,1172 # ffffffffc0204cb8 <commands+0x870>
ffffffffc020282c:	1fa00593          	li	a1,506
ffffffffc0202830:	00003517          	auipc	a0,0x3
ffffffffc0202834:	89850513          	addi	a0,a0,-1896 # ffffffffc02050c8 <default_pmm_manager+0x78>
ffffffffc0202838:	b3dfd0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc020283c <swap_init>:

static void check_swap(void);

int
swap_init(void)
{
ffffffffc020283c:	7135                	addi	sp,sp,-160
ffffffffc020283e:	ed06                	sd	ra,152(sp)
ffffffffc0202840:	e922                	sd	s0,144(sp)
ffffffffc0202842:	e526                	sd	s1,136(sp)
ffffffffc0202844:	e14a                	sd	s2,128(sp)
ffffffffc0202846:	fcce                	sd	s3,120(sp)
ffffffffc0202848:	f8d2                	sd	s4,112(sp)
ffffffffc020284a:	f4d6                	sd	s5,104(sp)
ffffffffc020284c:	f0da                	sd	s6,96(sp)
ffffffffc020284e:	ecde                	sd	s7,88(sp)
ffffffffc0202850:	e8e2                	sd	s8,80(sp)
ffffffffc0202852:	e4e6                	sd	s9,72(sp)
ffffffffc0202854:	e0ea                	sd	s10,64(sp)
ffffffffc0202856:	fc6e                	sd	s11,56(sp)
     swapfs_init();
ffffffffc0202858:	3c4010ef          	jal	ra,ffffffffc0203c1c <swapfs_init>

     // Since the IDE is faked, it can only store 7 pages at most to pass the test
     if (!(7 <= max_swap_offset &&
ffffffffc020285c:	0000f797          	auipc	a5,0xf
ffffffffc0202860:	ce478793          	addi	a5,a5,-796 # ffffffffc0211540 <max_swap_offset>
ffffffffc0202864:	6394                	ld	a3,0(a5)
ffffffffc0202866:	010007b7          	lui	a5,0x1000
ffffffffc020286a:	17e1                	addi	a5,a5,-8
ffffffffc020286c:	ff968713          	addi	a4,a3,-7
ffffffffc0202870:	42e7ea63          	bltu	a5,a4,ffffffffc0202ca4 <swap_init+0x468>
        max_swap_offset < MAX_SWAP_OFFSET_LIMIT)) {
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
     }

     sm = &swap_manager_clock;//use first in first out Page Replacement Algorithm
ffffffffc0202874:	00007797          	auipc	a5,0x7
ffffffffc0202878:	78c78793          	addi	a5,a5,1932 # ffffffffc020a000 <swap_manager_clock>
     int r = sm->init();
ffffffffc020287c:	6798                	ld	a4,8(a5)
     sm = &swap_manager_clock;//use first in first out Page Replacement Algorithm
ffffffffc020287e:	0000f697          	auipc	a3,0xf
ffffffffc0202882:	bef6b523          	sd	a5,-1046(a3) # ffffffffc0211468 <sm>
     int r = sm->init();
ffffffffc0202886:	9702                	jalr	a4
ffffffffc0202888:	8b2a                	mv	s6,a0
     
     if (r == 0)
ffffffffc020288a:	c10d                	beqz	a0,ffffffffc02028ac <swap_init+0x70>
          cprintf("SWAP: manager = %s\n", sm->name);
          check_swap();
     }

     return r;
}
ffffffffc020288c:	60ea                	ld	ra,152(sp)
ffffffffc020288e:	644a                	ld	s0,144(sp)
ffffffffc0202890:	855a                	mv	a0,s6
ffffffffc0202892:	64aa                	ld	s1,136(sp)
ffffffffc0202894:	690a                	ld	s2,128(sp)
ffffffffc0202896:	79e6                	ld	s3,120(sp)
ffffffffc0202898:	7a46                	ld	s4,112(sp)
ffffffffc020289a:	7aa6                	ld	s5,104(sp)
ffffffffc020289c:	7b06                	ld	s6,96(sp)
ffffffffc020289e:	6be6                	ld	s7,88(sp)
ffffffffc02028a0:	6c46                	ld	s8,80(sp)
ffffffffc02028a2:	6ca6                	ld	s9,72(sp)
ffffffffc02028a4:	6d06                	ld	s10,64(sp)
ffffffffc02028a6:	7de2                	ld	s11,56(sp)
ffffffffc02028a8:	610d                	addi	sp,sp,160
ffffffffc02028aa:	8082                	ret
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc02028ac:	0000f797          	auipc	a5,0xf
ffffffffc02028b0:	bbc78793          	addi	a5,a5,-1092 # ffffffffc0211468 <sm>
ffffffffc02028b4:	639c                	ld	a5,0(a5)
ffffffffc02028b6:	00003517          	auipc	a0,0x3
ffffffffc02028ba:	eba50513          	addi	a0,a0,-326 # ffffffffc0205770 <default_pmm_manager+0x720>
    return listelm->next;
ffffffffc02028be:	0000f417          	auipc	s0,0xf
ffffffffc02028c2:	bc240413          	addi	s0,s0,-1086 # ffffffffc0211480 <free_area>
ffffffffc02028c6:	638c                	ld	a1,0(a5)
          swap_init_ok = 1;
ffffffffc02028c8:	4785                	li	a5,1
ffffffffc02028ca:	0000f717          	auipc	a4,0xf
ffffffffc02028ce:	baf72323          	sw	a5,-1114(a4) # ffffffffc0211470 <swap_init_ok>
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc02028d2:	fecfd0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc02028d6:	641c                	ld	a5,8(s0)
check_swap(void)
{
    //backup mem env
     int ret, count = 0, total = 0, i;
     list_entry_t *le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc02028d8:	2e878a63          	beq	a5,s0,ffffffffc0202bcc <swap_init+0x390>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc02028dc:	fe87b703          	ld	a4,-24(a5)
ffffffffc02028e0:	8305                	srli	a4,a4,0x1
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc02028e2:	8b05                	andi	a4,a4,1
ffffffffc02028e4:	2e070863          	beqz	a4,ffffffffc0202bd4 <swap_init+0x398>
     int ret, count = 0, total = 0, i;
ffffffffc02028e8:	4481                	li	s1,0
ffffffffc02028ea:	4901                	li	s2,0
ffffffffc02028ec:	a031                	j	ffffffffc02028f8 <swap_init+0xbc>
ffffffffc02028ee:	fe87b703          	ld	a4,-24(a5)
        assert(PageProperty(p));
ffffffffc02028f2:	8b09                	andi	a4,a4,2
ffffffffc02028f4:	2e070063          	beqz	a4,ffffffffc0202bd4 <swap_init+0x398>
        count ++, total += p->property;
ffffffffc02028f8:	ff87a703          	lw	a4,-8(a5)
ffffffffc02028fc:	679c                	ld	a5,8(a5)
ffffffffc02028fe:	2905                	addiw	s2,s2,1
ffffffffc0202900:	9cb9                	addw	s1,s1,a4
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202902:	fe8796e3          	bne	a5,s0,ffffffffc02028ee <swap_init+0xb2>
ffffffffc0202906:	89a6                	mv	s3,s1
     }
     assert(total == nr_free_pages());
ffffffffc0202908:	e55fe0ef          	jal	ra,ffffffffc020175c <nr_free_pages>
ffffffffc020290c:	5b351863          	bne	a0,s3,ffffffffc0202ebc <swap_init+0x680>
     cprintf("BEGIN check_swap: count %d, total %d\n",count,total);
ffffffffc0202910:	8626                	mv	a2,s1
ffffffffc0202912:	85ca                	mv	a1,s2
ffffffffc0202914:	00003517          	auipc	a0,0x3
ffffffffc0202918:	e7450513          	addi	a0,a0,-396 # ffffffffc0205788 <default_pmm_manager+0x738>
ffffffffc020291c:	fa2fd0ef          	jal	ra,ffffffffc02000be <cprintf>
     
     //now we set the phy pages env     
     struct mm_struct *mm = mm_create();
ffffffffc0202920:	30d000ef          	jal	ra,ffffffffc020342c <mm_create>
ffffffffc0202924:	8baa                	mv	s7,a0
     assert(mm != NULL);
ffffffffc0202926:	50050b63          	beqz	a0,ffffffffc0202e3c <swap_init+0x600>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
ffffffffc020292a:	0000f797          	auipc	a5,0xf
ffffffffc020292e:	c6e78793          	addi	a5,a5,-914 # ffffffffc0211598 <check_mm_struct>
ffffffffc0202932:	639c                	ld	a5,0(a5)
ffffffffc0202934:	52079463          	bnez	a5,ffffffffc0202e5c <swap_init+0x620>

     check_mm_struct = mm;

     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0202938:	0000f797          	auipc	a5,0xf
ffffffffc020293c:	b2078793          	addi	a5,a5,-1248 # ffffffffc0211458 <boot_pgdir>
ffffffffc0202940:	6398                	ld	a4,0(a5)
     check_mm_struct = mm;
ffffffffc0202942:	0000f797          	auipc	a5,0xf
ffffffffc0202946:	c4a7bb23          	sd	a0,-938(a5) # ffffffffc0211598 <check_mm_struct>
     assert(pgdir[0] == 0);
ffffffffc020294a:	631c                	ld	a5,0(a4)
     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc020294c:	ec3a                	sd	a4,24(sp)
ffffffffc020294e:	ed18                	sd	a4,24(a0)
     assert(pgdir[0] == 0);
ffffffffc0202950:	52079663          	bnez	a5,ffffffffc0202e7c <swap_init+0x640>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
ffffffffc0202954:	6599                	lui	a1,0x6
ffffffffc0202956:	460d                	li	a2,3
ffffffffc0202958:	6505                	lui	a0,0x1
ffffffffc020295a:	31f000ef          	jal	ra,ffffffffc0203478 <vma_create>
ffffffffc020295e:	85aa                	mv	a1,a0
     assert(vma != NULL);
ffffffffc0202960:	52050e63          	beqz	a0,ffffffffc0202e9c <swap_init+0x660>

     insert_vma_struct(mm, vma);
ffffffffc0202964:	855e                	mv	a0,s7
ffffffffc0202966:	37f000ef          	jal	ra,ffffffffc02034e4 <insert_vma_struct>

     //setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
ffffffffc020296a:	00003517          	auipc	a0,0x3
ffffffffc020296e:	e8e50513          	addi	a0,a0,-370 # ffffffffc02057f8 <default_pmm_manager+0x7a8>
ffffffffc0202972:	f4cfd0ef          	jal	ra,ffffffffc02000be <cprintf>
     pte_t *temp_ptep=NULL;
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
ffffffffc0202976:	018bb503          	ld	a0,24(s7)
ffffffffc020297a:	4605                	li	a2,1
ffffffffc020297c:	6585                	lui	a1,0x1
ffffffffc020297e:	e1ffe0ef          	jal	ra,ffffffffc020179c <get_pte>
     assert(temp_ptep!= NULL);
ffffffffc0202982:	40050d63          	beqz	a0,ffffffffc0202d9c <swap_init+0x560>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc0202986:	00003517          	auipc	a0,0x3
ffffffffc020298a:	ec250513          	addi	a0,a0,-318 # ffffffffc0205848 <default_pmm_manager+0x7f8>
ffffffffc020298e:	0000fa17          	auipc	s4,0xf
ffffffffc0202992:	b2aa0a13          	addi	s4,s4,-1238 # ffffffffc02114b8 <check_rp>
ffffffffc0202996:	f28fd0ef          	jal	ra,ffffffffc02000be <cprintf>
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc020299a:	0000fa97          	auipc	s5,0xf
ffffffffc020299e:	b3ea8a93          	addi	s5,s5,-1218 # ffffffffc02114d8 <swap_in_seq_no>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc02029a2:	89d2                	mv	s3,s4
          check_rp[i] = alloc_page();
ffffffffc02029a4:	4505                	li	a0,1
ffffffffc02029a6:	ce9fe0ef          	jal	ra,ffffffffc020168e <alloc_pages>
ffffffffc02029aa:	00a9b023          	sd	a0,0(s3) # fffffffffff80000 <end+0x3fd6ea60>
          assert(check_rp[i] != NULL );
ffffffffc02029ae:	2a050b63          	beqz	a0,ffffffffc0202c64 <swap_init+0x428>
ffffffffc02029b2:	651c                	ld	a5,8(a0)
          assert(!PageProperty(check_rp[i]));
ffffffffc02029b4:	8b89                	andi	a5,a5,2
ffffffffc02029b6:	28079763          	bnez	a5,ffffffffc0202c44 <swap_init+0x408>
ffffffffc02029ba:	09a1                	addi	s3,s3,8
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02029bc:	ff5994e3          	bne	s3,s5,ffffffffc02029a4 <swap_init+0x168>
     }
     list_entry_t free_list_store = free_list;
ffffffffc02029c0:	601c                	ld	a5,0(s0)
ffffffffc02029c2:	00843983          	ld	s3,8(s0)
     assert(list_empty(&free_list));
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
     nr_free = 0;
ffffffffc02029c6:	0000fd17          	auipc	s10,0xf
ffffffffc02029ca:	af2d0d13          	addi	s10,s10,-1294 # ffffffffc02114b8 <check_rp>
     list_entry_t free_list_store = free_list;
ffffffffc02029ce:	f03e                	sd	a5,32(sp)
     unsigned int nr_free_store = nr_free;
ffffffffc02029d0:	481c                	lw	a5,16(s0)
ffffffffc02029d2:	f43e                	sd	a5,40(sp)
    elm->prev = elm->next = elm;
ffffffffc02029d4:	0000f797          	auipc	a5,0xf
ffffffffc02029d8:	aa87ba23          	sd	s0,-1356(a5) # ffffffffc0211488 <free_area+0x8>
ffffffffc02029dc:	0000f797          	auipc	a5,0xf
ffffffffc02029e0:	aa87b223          	sd	s0,-1372(a5) # ffffffffc0211480 <free_area>
     nr_free = 0;
ffffffffc02029e4:	0000f797          	auipc	a5,0xf
ffffffffc02029e8:	aa07a623          	sw	zero,-1364(a5) # ffffffffc0211490 <free_area+0x10>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
        free_pages(check_rp[i],1);
ffffffffc02029ec:	000d3503          	ld	a0,0(s10)
ffffffffc02029f0:	4585                	li	a1,1
ffffffffc02029f2:	0d21                	addi	s10,s10,8
ffffffffc02029f4:	d23fe0ef          	jal	ra,ffffffffc0201716 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02029f8:	ff5d1ae3          	bne	s10,s5,ffffffffc02029ec <swap_init+0x1b0>
     }
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc02029fc:	01042d03          	lw	s10,16(s0)
ffffffffc0202a00:	4791                	li	a5,4
ffffffffc0202a02:	36fd1d63          	bne	s10,a5,ffffffffc0202d7c <swap_init+0x540>
     
     cprintf("set up init env for check_swap begin!\n");
ffffffffc0202a06:	00003517          	auipc	a0,0x3
ffffffffc0202a0a:	eca50513          	addi	a0,a0,-310 # ffffffffc02058d0 <default_pmm_manager+0x880>
ffffffffc0202a0e:	eb0fd0ef          	jal	ra,ffffffffc02000be <cprintf>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0202a12:	6685                	lui	a3,0x1
     //setup initial vir_page<->phy_page environment for page relpacement algorithm 

     
     pgfault_num=0;
ffffffffc0202a14:	0000f797          	auipc	a5,0xf
ffffffffc0202a18:	a607a023          	sw	zero,-1440(a5) # ffffffffc0211474 <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0202a1c:	4629                	li	a2,10
     pgfault_num=0;
ffffffffc0202a1e:	0000f797          	auipc	a5,0xf
ffffffffc0202a22:	a5678793          	addi	a5,a5,-1450 # ffffffffc0211474 <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0202a26:	00c68023          	sb	a2,0(a3) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
     assert(pgfault_num==1);
ffffffffc0202a2a:	4398                	lw	a4,0(a5)
ffffffffc0202a2c:	4585                	li	a1,1
ffffffffc0202a2e:	2701                	sext.w	a4,a4
ffffffffc0202a30:	30b71663          	bne	a4,a1,ffffffffc0202d3c <swap_init+0x500>
     *(unsigned char *)0x1010 = 0x0a;
ffffffffc0202a34:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==1);
ffffffffc0202a38:	4394                	lw	a3,0(a5)
ffffffffc0202a3a:	2681                	sext.w	a3,a3
ffffffffc0202a3c:	32e69063          	bne	a3,a4,ffffffffc0202d5c <swap_init+0x520>
     *(unsigned char *)0x2000 = 0x0b;
ffffffffc0202a40:	6689                	lui	a3,0x2
ffffffffc0202a42:	462d                	li	a2,11
ffffffffc0202a44:	00c68023          	sb	a2,0(a3) # 2000 <BASE_ADDRESS-0xffffffffc01fe000>
     assert(pgfault_num==2);
ffffffffc0202a48:	4398                	lw	a4,0(a5)
ffffffffc0202a4a:	4589                	li	a1,2
ffffffffc0202a4c:	2701                	sext.w	a4,a4
ffffffffc0202a4e:	26b71763          	bne	a4,a1,ffffffffc0202cbc <swap_init+0x480>
     *(unsigned char *)0x2010 = 0x0b;
ffffffffc0202a52:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==2);
ffffffffc0202a56:	4394                	lw	a3,0(a5)
ffffffffc0202a58:	2681                	sext.w	a3,a3
ffffffffc0202a5a:	28e69163          	bne	a3,a4,ffffffffc0202cdc <swap_init+0x4a0>
     *(unsigned char *)0x3000 = 0x0c;
ffffffffc0202a5e:	668d                	lui	a3,0x3
ffffffffc0202a60:	4631                	li	a2,12
ffffffffc0202a62:	00c68023          	sb	a2,0(a3) # 3000 <BASE_ADDRESS-0xffffffffc01fd000>
     assert(pgfault_num==3);
ffffffffc0202a66:	4398                	lw	a4,0(a5)
ffffffffc0202a68:	458d                	li	a1,3
ffffffffc0202a6a:	2701                	sext.w	a4,a4
ffffffffc0202a6c:	28b71863          	bne	a4,a1,ffffffffc0202cfc <swap_init+0x4c0>
     *(unsigned char *)0x3010 = 0x0c;
ffffffffc0202a70:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==3);
ffffffffc0202a74:	4394                	lw	a3,0(a5)
ffffffffc0202a76:	2681                	sext.w	a3,a3
ffffffffc0202a78:	2ae69263          	bne	a3,a4,ffffffffc0202d1c <swap_init+0x4e0>
     *(unsigned char *)0x4000 = 0x0d;
ffffffffc0202a7c:	6691                	lui	a3,0x4
ffffffffc0202a7e:	4635                	li	a2,13
ffffffffc0202a80:	00c68023          	sb	a2,0(a3) # 4000 <BASE_ADDRESS-0xffffffffc01fc000>
     assert(pgfault_num==4);
ffffffffc0202a84:	4398                	lw	a4,0(a5)
ffffffffc0202a86:	2701                	sext.w	a4,a4
ffffffffc0202a88:	33a71a63          	bne	a4,s10,ffffffffc0202dbc <swap_init+0x580>
     *(unsigned char *)0x4010 = 0x0d;
ffffffffc0202a8c:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==4);
ffffffffc0202a90:	439c                	lw	a5,0(a5)
ffffffffc0202a92:	2781                	sext.w	a5,a5
ffffffffc0202a94:	34e79463          	bne	a5,a4,ffffffffc0202ddc <swap_init+0x5a0>
     
     check_content_set();
     assert( nr_free == 0);         
ffffffffc0202a98:	481c                	lw	a5,16(s0)
ffffffffc0202a9a:	36079163          	bnez	a5,ffffffffc0202dfc <swap_init+0x5c0>
ffffffffc0202a9e:	0000f797          	auipc	a5,0xf
ffffffffc0202aa2:	a3a78793          	addi	a5,a5,-1478 # ffffffffc02114d8 <swap_in_seq_no>
ffffffffc0202aa6:	0000f717          	auipc	a4,0xf
ffffffffc0202aaa:	a5a70713          	addi	a4,a4,-1446 # ffffffffc0211500 <swap_out_seq_no>
ffffffffc0202aae:	0000f617          	auipc	a2,0xf
ffffffffc0202ab2:	a5260613          	addi	a2,a2,-1454 # ffffffffc0211500 <swap_out_seq_no>
     for(i = 0; i<MAX_SEQ_NO ; i++) 
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
ffffffffc0202ab6:	56fd                	li	a3,-1
ffffffffc0202ab8:	c394                	sw	a3,0(a5)
ffffffffc0202aba:	c314                	sw	a3,0(a4)
ffffffffc0202abc:	0791                	addi	a5,a5,4
ffffffffc0202abe:	0711                	addi	a4,a4,4
     for(i = 0; i<MAX_SEQ_NO ; i++) 
ffffffffc0202ac0:	fec79ce3          	bne	a5,a2,ffffffffc0202ab8 <swap_init+0x27c>
ffffffffc0202ac4:	0000f697          	auipc	a3,0xf
ffffffffc0202ac8:	a9c68693          	addi	a3,a3,-1380 # ffffffffc0211560 <check_ptep>
ffffffffc0202acc:	0000f817          	auipc	a6,0xf
ffffffffc0202ad0:	9ec80813          	addi	a6,a6,-1556 # ffffffffc02114b8 <check_rp>
ffffffffc0202ad4:	6c05                	lui	s8,0x1
    if (PPN(pa) >= npage) {
ffffffffc0202ad6:	0000fc97          	auipc	s9,0xf
ffffffffc0202ada:	98ac8c93          	addi	s9,s9,-1654 # ffffffffc0211460 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc0202ade:	0000fd97          	auipc	s11,0xf
ffffffffc0202ae2:	9d2d8d93          	addi	s11,s11,-1582 # ffffffffc02114b0 <pages>
ffffffffc0202ae6:	00003d17          	auipc	s10,0x3
ffffffffc0202aea:	64ad0d13          	addi	s10,s10,1610 # ffffffffc0206130 <nbase>
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         check_ptep[i]=0;
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202aee:	6562                	ld	a0,24(sp)
         check_ptep[i]=0;
ffffffffc0202af0:	0006b023          	sd	zero,0(a3)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202af4:	4601                	li	a2,0
ffffffffc0202af6:	85e2                	mv	a1,s8
ffffffffc0202af8:	e842                	sd	a6,16(sp)
         check_ptep[i]=0;
ffffffffc0202afa:	e436                	sd	a3,8(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202afc:	ca1fe0ef          	jal	ra,ffffffffc020179c <get_pte>
ffffffffc0202b00:	66a2                	ld	a3,8(sp)
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
ffffffffc0202b02:	6842                	ld	a6,16(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202b04:	e288                	sd	a0,0(a3)
         assert(check_ptep[i] != NULL);
ffffffffc0202b06:	16050f63          	beqz	a0,ffffffffc0202c84 <swap_init+0x448>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0202b0a:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0202b0c:	0017f613          	andi	a2,a5,1
ffffffffc0202b10:	10060263          	beqz	a2,ffffffffc0202c14 <swap_init+0x3d8>
    if (PPN(pa) >= npage) {
ffffffffc0202b14:	000cb603          	ld	a2,0(s9)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202b18:	078a                	slli	a5,a5,0x2
ffffffffc0202b1a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202b1c:	10c7f863          	bleu	a2,a5,ffffffffc0202c2c <swap_init+0x3f0>
    return &pages[PPN(pa) - nbase];
ffffffffc0202b20:	000d3603          	ld	a2,0(s10)
ffffffffc0202b24:	000db583          	ld	a1,0(s11)
ffffffffc0202b28:	00083503          	ld	a0,0(a6)
ffffffffc0202b2c:	8f91                	sub	a5,a5,a2
ffffffffc0202b2e:	00379613          	slli	a2,a5,0x3
ffffffffc0202b32:	97b2                	add	a5,a5,a2
ffffffffc0202b34:	078e                	slli	a5,a5,0x3
ffffffffc0202b36:	97ae                	add	a5,a5,a1
ffffffffc0202b38:	0af51e63          	bne	a0,a5,ffffffffc0202bf4 <swap_init+0x3b8>
ffffffffc0202b3c:	6785                	lui	a5,0x1
ffffffffc0202b3e:	9c3e                	add	s8,s8,a5
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202b40:	6795                	lui	a5,0x5
ffffffffc0202b42:	06a1                	addi	a3,a3,8
ffffffffc0202b44:	0821                	addi	a6,a6,8
ffffffffc0202b46:	fafc14e3          	bne	s8,a5,ffffffffc0202aee <swap_init+0x2b2>
         assert((*check_ptep[i] & PTE_V));          
     }
     cprintf("set up init env for check_swap over!\n");
ffffffffc0202b4a:	00003517          	auipc	a0,0x3
ffffffffc0202b4e:	e2e50513          	addi	a0,a0,-466 # ffffffffc0205978 <default_pmm_manager+0x928>
ffffffffc0202b52:	d6cfd0ef          	jal	ra,ffffffffc02000be <cprintf>
    int ret = sm->check_swap();
ffffffffc0202b56:	0000f797          	auipc	a5,0xf
ffffffffc0202b5a:	91278793          	addi	a5,a5,-1774 # ffffffffc0211468 <sm>
ffffffffc0202b5e:	639c                	ld	a5,0(a5)
ffffffffc0202b60:	7f9c                	ld	a5,56(a5)
ffffffffc0202b62:	9782                	jalr	a5
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
     assert(ret==0);
ffffffffc0202b64:	2a051c63          	bnez	a0,ffffffffc0202e1c <swap_init+0x5e0>
     
     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         free_pages(check_rp[i],1);
ffffffffc0202b68:	000a3503          	ld	a0,0(s4)
ffffffffc0202b6c:	4585                	li	a1,1
ffffffffc0202b6e:	0a21                	addi	s4,s4,8
ffffffffc0202b70:	ba7fe0ef          	jal	ra,ffffffffc0201716 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202b74:	ff5a1ae3          	bne	s4,s5,ffffffffc0202b68 <swap_init+0x32c>
     } 

     //free_page(pte2page(*temp_ptep));
     
     mm_destroy(mm);
ffffffffc0202b78:	855e                	mv	a0,s7
ffffffffc0202b7a:	239000ef          	jal	ra,ffffffffc02035b2 <mm_destroy>
         
     nr_free = nr_free_store;
ffffffffc0202b7e:	77a2                	ld	a5,40(sp)
ffffffffc0202b80:	0000f717          	auipc	a4,0xf
ffffffffc0202b84:	90f72823          	sw	a5,-1776(a4) # ffffffffc0211490 <free_area+0x10>
     free_list = free_list_store;
ffffffffc0202b88:	7782                	ld	a5,32(sp)
ffffffffc0202b8a:	0000f717          	auipc	a4,0xf
ffffffffc0202b8e:	8ef73b23          	sd	a5,-1802(a4) # ffffffffc0211480 <free_area>
ffffffffc0202b92:	0000f797          	auipc	a5,0xf
ffffffffc0202b96:	8f37bb23          	sd	s3,-1802(a5) # ffffffffc0211488 <free_area+0x8>

     
     le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202b9a:	00898a63          	beq	s3,s0,ffffffffc0202bae <swap_init+0x372>
         struct Page *p = le2page(le, page_link);
         count --, total -= p->property;
ffffffffc0202b9e:	ff89a783          	lw	a5,-8(s3)
    return listelm->next;
ffffffffc0202ba2:	0089b983          	ld	s3,8(s3)
ffffffffc0202ba6:	397d                	addiw	s2,s2,-1
ffffffffc0202ba8:	9c9d                	subw	s1,s1,a5
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202baa:	fe899ae3          	bne	s3,s0,ffffffffc0202b9e <swap_init+0x362>
     }
     cprintf("count is %d, total is %d\n",count,total);
ffffffffc0202bae:	8626                	mv	a2,s1
ffffffffc0202bb0:	85ca                	mv	a1,s2
ffffffffc0202bb2:	00003517          	auipc	a0,0x3
ffffffffc0202bb6:	df650513          	addi	a0,a0,-522 # ffffffffc02059a8 <default_pmm_manager+0x958>
ffffffffc0202bba:	d04fd0ef          	jal	ra,ffffffffc02000be <cprintf>
     //assert(count == 0);
     
     cprintf("check_swap() succeeded!\n");
ffffffffc0202bbe:	00003517          	auipc	a0,0x3
ffffffffc0202bc2:	e0a50513          	addi	a0,a0,-502 # ffffffffc02059c8 <default_pmm_manager+0x978>
ffffffffc0202bc6:	cf8fd0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc0202bca:	b1c9                	j	ffffffffc020288c <swap_init+0x50>
     int ret, count = 0, total = 0, i;
ffffffffc0202bcc:	4481                	li	s1,0
ffffffffc0202bce:	4901                	li	s2,0
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202bd0:	4981                	li	s3,0
ffffffffc0202bd2:	bb1d                	j	ffffffffc0202908 <swap_init+0xcc>
        assert(PageProperty(p));
ffffffffc0202bd4:	00002697          	auipc	a3,0x2
ffffffffc0202bd8:	0d468693          	addi	a3,a3,212 # ffffffffc0204ca8 <commands+0x860>
ffffffffc0202bdc:	00002617          	auipc	a2,0x2
ffffffffc0202be0:	0dc60613          	addi	a2,a2,220 # ffffffffc0204cb8 <commands+0x870>
ffffffffc0202be4:	0ba00593          	li	a1,186
ffffffffc0202be8:	00003517          	auipc	a0,0x3
ffffffffc0202bec:	b7850513          	addi	a0,a0,-1160 # ffffffffc0205760 <default_pmm_manager+0x710>
ffffffffc0202bf0:	f84fd0ef          	jal	ra,ffffffffc0200374 <__panic>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0202bf4:	00003697          	auipc	a3,0x3
ffffffffc0202bf8:	d5c68693          	addi	a3,a3,-676 # ffffffffc0205950 <default_pmm_manager+0x900>
ffffffffc0202bfc:	00002617          	auipc	a2,0x2
ffffffffc0202c00:	0bc60613          	addi	a2,a2,188 # ffffffffc0204cb8 <commands+0x870>
ffffffffc0202c04:	0fa00593          	li	a1,250
ffffffffc0202c08:	00003517          	auipc	a0,0x3
ffffffffc0202c0c:	b5850513          	addi	a0,a0,-1192 # ffffffffc0205760 <default_pmm_manager+0x710>
ffffffffc0202c10:	f64fd0ef          	jal	ra,ffffffffc0200374 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc0202c14:	00002617          	auipc	a2,0x2
ffffffffc0202c18:	6fc60613          	addi	a2,a2,1788 # ffffffffc0205310 <default_pmm_manager+0x2c0>
ffffffffc0202c1c:	07000593          	li	a1,112
ffffffffc0202c20:	00002517          	auipc	a0,0x2
ffffffffc0202c24:	51850513          	addi	a0,a0,1304 # ffffffffc0205138 <default_pmm_manager+0xe8>
ffffffffc0202c28:	f4cfd0ef          	jal	ra,ffffffffc0200374 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0202c2c:	00002617          	auipc	a2,0x2
ffffffffc0202c30:	4ec60613          	addi	a2,a2,1260 # ffffffffc0205118 <default_pmm_manager+0xc8>
ffffffffc0202c34:	06500593          	li	a1,101
ffffffffc0202c38:	00002517          	auipc	a0,0x2
ffffffffc0202c3c:	50050513          	addi	a0,a0,1280 # ffffffffc0205138 <default_pmm_manager+0xe8>
ffffffffc0202c40:	f34fd0ef          	jal	ra,ffffffffc0200374 <__panic>
          assert(!PageProperty(check_rp[i]));
ffffffffc0202c44:	00003697          	auipc	a3,0x3
ffffffffc0202c48:	c4468693          	addi	a3,a3,-956 # ffffffffc0205888 <default_pmm_manager+0x838>
ffffffffc0202c4c:	00002617          	auipc	a2,0x2
ffffffffc0202c50:	06c60613          	addi	a2,a2,108 # ffffffffc0204cb8 <commands+0x870>
ffffffffc0202c54:	0db00593          	li	a1,219
ffffffffc0202c58:	00003517          	auipc	a0,0x3
ffffffffc0202c5c:	b0850513          	addi	a0,a0,-1272 # ffffffffc0205760 <default_pmm_manager+0x710>
ffffffffc0202c60:	f14fd0ef          	jal	ra,ffffffffc0200374 <__panic>
          assert(check_rp[i] != NULL );
ffffffffc0202c64:	00003697          	auipc	a3,0x3
ffffffffc0202c68:	c0c68693          	addi	a3,a3,-1012 # ffffffffc0205870 <default_pmm_manager+0x820>
ffffffffc0202c6c:	00002617          	auipc	a2,0x2
ffffffffc0202c70:	04c60613          	addi	a2,a2,76 # ffffffffc0204cb8 <commands+0x870>
ffffffffc0202c74:	0da00593          	li	a1,218
ffffffffc0202c78:	00003517          	auipc	a0,0x3
ffffffffc0202c7c:	ae850513          	addi	a0,a0,-1304 # ffffffffc0205760 <default_pmm_manager+0x710>
ffffffffc0202c80:	ef4fd0ef          	jal	ra,ffffffffc0200374 <__panic>
         assert(check_ptep[i] != NULL);
ffffffffc0202c84:	00003697          	auipc	a3,0x3
ffffffffc0202c88:	cb468693          	addi	a3,a3,-844 # ffffffffc0205938 <default_pmm_manager+0x8e8>
ffffffffc0202c8c:	00002617          	auipc	a2,0x2
ffffffffc0202c90:	02c60613          	addi	a2,a2,44 # ffffffffc0204cb8 <commands+0x870>
ffffffffc0202c94:	0f900593          	li	a1,249
ffffffffc0202c98:	00003517          	auipc	a0,0x3
ffffffffc0202c9c:	ac850513          	addi	a0,a0,-1336 # ffffffffc0205760 <default_pmm_manager+0x710>
ffffffffc0202ca0:	ed4fd0ef          	jal	ra,ffffffffc0200374 <__panic>
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
ffffffffc0202ca4:	00003617          	auipc	a2,0x3
ffffffffc0202ca8:	a9c60613          	addi	a2,a2,-1380 # ffffffffc0205740 <default_pmm_manager+0x6f0>
ffffffffc0202cac:	02700593          	li	a1,39
ffffffffc0202cb0:	00003517          	auipc	a0,0x3
ffffffffc0202cb4:	ab050513          	addi	a0,a0,-1360 # ffffffffc0205760 <default_pmm_manager+0x710>
ffffffffc0202cb8:	ebcfd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(pgfault_num==2);
ffffffffc0202cbc:	00003697          	auipc	a3,0x3
ffffffffc0202cc0:	c4c68693          	addi	a3,a3,-948 # ffffffffc0205908 <default_pmm_manager+0x8b8>
ffffffffc0202cc4:	00002617          	auipc	a2,0x2
ffffffffc0202cc8:	ff460613          	addi	a2,a2,-12 # ffffffffc0204cb8 <commands+0x870>
ffffffffc0202ccc:	09500593          	li	a1,149
ffffffffc0202cd0:	00003517          	auipc	a0,0x3
ffffffffc0202cd4:	a9050513          	addi	a0,a0,-1392 # ffffffffc0205760 <default_pmm_manager+0x710>
ffffffffc0202cd8:	e9cfd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(pgfault_num==2);
ffffffffc0202cdc:	00003697          	auipc	a3,0x3
ffffffffc0202ce0:	c2c68693          	addi	a3,a3,-980 # ffffffffc0205908 <default_pmm_manager+0x8b8>
ffffffffc0202ce4:	00002617          	auipc	a2,0x2
ffffffffc0202ce8:	fd460613          	addi	a2,a2,-44 # ffffffffc0204cb8 <commands+0x870>
ffffffffc0202cec:	09700593          	li	a1,151
ffffffffc0202cf0:	00003517          	auipc	a0,0x3
ffffffffc0202cf4:	a7050513          	addi	a0,a0,-1424 # ffffffffc0205760 <default_pmm_manager+0x710>
ffffffffc0202cf8:	e7cfd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(pgfault_num==3);
ffffffffc0202cfc:	00003697          	auipc	a3,0x3
ffffffffc0202d00:	c1c68693          	addi	a3,a3,-996 # ffffffffc0205918 <default_pmm_manager+0x8c8>
ffffffffc0202d04:	00002617          	auipc	a2,0x2
ffffffffc0202d08:	fb460613          	addi	a2,a2,-76 # ffffffffc0204cb8 <commands+0x870>
ffffffffc0202d0c:	09900593          	li	a1,153
ffffffffc0202d10:	00003517          	auipc	a0,0x3
ffffffffc0202d14:	a5050513          	addi	a0,a0,-1456 # ffffffffc0205760 <default_pmm_manager+0x710>
ffffffffc0202d18:	e5cfd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(pgfault_num==3);
ffffffffc0202d1c:	00003697          	auipc	a3,0x3
ffffffffc0202d20:	bfc68693          	addi	a3,a3,-1028 # ffffffffc0205918 <default_pmm_manager+0x8c8>
ffffffffc0202d24:	00002617          	auipc	a2,0x2
ffffffffc0202d28:	f9460613          	addi	a2,a2,-108 # ffffffffc0204cb8 <commands+0x870>
ffffffffc0202d2c:	09b00593          	li	a1,155
ffffffffc0202d30:	00003517          	auipc	a0,0x3
ffffffffc0202d34:	a3050513          	addi	a0,a0,-1488 # ffffffffc0205760 <default_pmm_manager+0x710>
ffffffffc0202d38:	e3cfd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(pgfault_num==1);
ffffffffc0202d3c:	00003697          	auipc	a3,0x3
ffffffffc0202d40:	bbc68693          	addi	a3,a3,-1092 # ffffffffc02058f8 <default_pmm_manager+0x8a8>
ffffffffc0202d44:	00002617          	auipc	a2,0x2
ffffffffc0202d48:	f7460613          	addi	a2,a2,-140 # ffffffffc0204cb8 <commands+0x870>
ffffffffc0202d4c:	09100593          	li	a1,145
ffffffffc0202d50:	00003517          	auipc	a0,0x3
ffffffffc0202d54:	a1050513          	addi	a0,a0,-1520 # ffffffffc0205760 <default_pmm_manager+0x710>
ffffffffc0202d58:	e1cfd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(pgfault_num==1);
ffffffffc0202d5c:	00003697          	auipc	a3,0x3
ffffffffc0202d60:	b9c68693          	addi	a3,a3,-1124 # ffffffffc02058f8 <default_pmm_manager+0x8a8>
ffffffffc0202d64:	00002617          	auipc	a2,0x2
ffffffffc0202d68:	f5460613          	addi	a2,a2,-172 # ffffffffc0204cb8 <commands+0x870>
ffffffffc0202d6c:	09300593          	li	a1,147
ffffffffc0202d70:	00003517          	auipc	a0,0x3
ffffffffc0202d74:	9f050513          	addi	a0,a0,-1552 # ffffffffc0205760 <default_pmm_manager+0x710>
ffffffffc0202d78:	dfcfd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0202d7c:	00003697          	auipc	a3,0x3
ffffffffc0202d80:	b2c68693          	addi	a3,a3,-1236 # ffffffffc02058a8 <default_pmm_manager+0x858>
ffffffffc0202d84:	00002617          	auipc	a2,0x2
ffffffffc0202d88:	f3460613          	addi	a2,a2,-204 # ffffffffc0204cb8 <commands+0x870>
ffffffffc0202d8c:	0e800593          	li	a1,232
ffffffffc0202d90:	00003517          	auipc	a0,0x3
ffffffffc0202d94:	9d050513          	addi	a0,a0,-1584 # ffffffffc0205760 <default_pmm_manager+0x710>
ffffffffc0202d98:	ddcfd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(temp_ptep!= NULL);
ffffffffc0202d9c:	00003697          	auipc	a3,0x3
ffffffffc0202da0:	a9468693          	addi	a3,a3,-1388 # ffffffffc0205830 <default_pmm_manager+0x7e0>
ffffffffc0202da4:	00002617          	auipc	a2,0x2
ffffffffc0202da8:	f1460613          	addi	a2,a2,-236 # ffffffffc0204cb8 <commands+0x870>
ffffffffc0202dac:	0d500593          	li	a1,213
ffffffffc0202db0:	00003517          	auipc	a0,0x3
ffffffffc0202db4:	9b050513          	addi	a0,a0,-1616 # ffffffffc0205760 <default_pmm_manager+0x710>
ffffffffc0202db8:	dbcfd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(pgfault_num==4);
ffffffffc0202dbc:	00003697          	auipc	a3,0x3
ffffffffc0202dc0:	b6c68693          	addi	a3,a3,-1172 # ffffffffc0205928 <default_pmm_manager+0x8d8>
ffffffffc0202dc4:	00002617          	auipc	a2,0x2
ffffffffc0202dc8:	ef460613          	addi	a2,a2,-268 # ffffffffc0204cb8 <commands+0x870>
ffffffffc0202dcc:	09d00593          	li	a1,157
ffffffffc0202dd0:	00003517          	auipc	a0,0x3
ffffffffc0202dd4:	99050513          	addi	a0,a0,-1648 # ffffffffc0205760 <default_pmm_manager+0x710>
ffffffffc0202dd8:	d9cfd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(pgfault_num==4);
ffffffffc0202ddc:	00003697          	auipc	a3,0x3
ffffffffc0202de0:	b4c68693          	addi	a3,a3,-1204 # ffffffffc0205928 <default_pmm_manager+0x8d8>
ffffffffc0202de4:	00002617          	auipc	a2,0x2
ffffffffc0202de8:	ed460613          	addi	a2,a2,-300 # ffffffffc0204cb8 <commands+0x870>
ffffffffc0202dec:	09f00593          	li	a1,159
ffffffffc0202df0:	00003517          	auipc	a0,0x3
ffffffffc0202df4:	97050513          	addi	a0,a0,-1680 # ffffffffc0205760 <default_pmm_manager+0x710>
ffffffffc0202df8:	d7cfd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert( nr_free == 0);         
ffffffffc0202dfc:	00002697          	auipc	a3,0x2
ffffffffc0202e00:	09468693          	addi	a3,a3,148 # ffffffffc0204e90 <commands+0xa48>
ffffffffc0202e04:	00002617          	auipc	a2,0x2
ffffffffc0202e08:	eb460613          	addi	a2,a2,-332 # ffffffffc0204cb8 <commands+0x870>
ffffffffc0202e0c:	0f100593          	li	a1,241
ffffffffc0202e10:	00003517          	auipc	a0,0x3
ffffffffc0202e14:	95050513          	addi	a0,a0,-1712 # ffffffffc0205760 <default_pmm_manager+0x710>
ffffffffc0202e18:	d5cfd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(ret==0);
ffffffffc0202e1c:	00003697          	auipc	a3,0x3
ffffffffc0202e20:	b8468693          	addi	a3,a3,-1148 # ffffffffc02059a0 <default_pmm_manager+0x950>
ffffffffc0202e24:	00002617          	auipc	a2,0x2
ffffffffc0202e28:	e9460613          	addi	a2,a2,-364 # ffffffffc0204cb8 <commands+0x870>
ffffffffc0202e2c:	10000593          	li	a1,256
ffffffffc0202e30:	00003517          	auipc	a0,0x3
ffffffffc0202e34:	93050513          	addi	a0,a0,-1744 # ffffffffc0205760 <default_pmm_manager+0x710>
ffffffffc0202e38:	d3cfd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(mm != NULL);
ffffffffc0202e3c:	00003697          	auipc	a3,0x3
ffffffffc0202e40:	97468693          	addi	a3,a3,-1676 # ffffffffc02057b0 <default_pmm_manager+0x760>
ffffffffc0202e44:	00002617          	auipc	a2,0x2
ffffffffc0202e48:	e7460613          	addi	a2,a2,-396 # ffffffffc0204cb8 <commands+0x870>
ffffffffc0202e4c:	0c200593          	li	a1,194
ffffffffc0202e50:	00003517          	auipc	a0,0x3
ffffffffc0202e54:	91050513          	addi	a0,a0,-1776 # ffffffffc0205760 <default_pmm_manager+0x710>
ffffffffc0202e58:	d1cfd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(check_mm_struct == NULL);
ffffffffc0202e5c:	00003697          	auipc	a3,0x3
ffffffffc0202e60:	96468693          	addi	a3,a3,-1692 # ffffffffc02057c0 <default_pmm_manager+0x770>
ffffffffc0202e64:	00002617          	auipc	a2,0x2
ffffffffc0202e68:	e5460613          	addi	a2,a2,-428 # ffffffffc0204cb8 <commands+0x870>
ffffffffc0202e6c:	0c500593          	li	a1,197
ffffffffc0202e70:	00003517          	auipc	a0,0x3
ffffffffc0202e74:	8f050513          	addi	a0,a0,-1808 # ffffffffc0205760 <default_pmm_manager+0x710>
ffffffffc0202e78:	cfcfd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(pgdir[0] == 0);
ffffffffc0202e7c:	00003697          	auipc	a3,0x3
ffffffffc0202e80:	95c68693          	addi	a3,a3,-1700 # ffffffffc02057d8 <default_pmm_manager+0x788>
ffffffffc0202e84:	00002617          	auipc	a2,0x2
ffffffffc0202e88:	e3460613          	addi	a2,a2,-460 # ffffffffc0204cb8 <commands+0x870>
ffffffffc0202e8c:	0ca00593          	li	a1,202
ffffffffc0202e90:	00003517          	auipc	a0,0x3
ffffffffc0202e94:	8d050513          	addi	a0,a0,-1840 # ffffffffc0205760 <default_pmm_manager+0x710>
ffffffffc0202e98:	cdcfd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(vma != NULL);
ffffffffc0202e9c:	00003697          	auipc	a3,0x3
ffffffffc0202ea0:	94c68693          	addi	a3,a3,-1716 # ffffffffc02057e8 <default_pmm_manager+0x798>
ffffffffc0202ea4:	00002617          	auipc	a2,0x2
ffffffffc0202ea8:	e1460613          	addi	a2,a2,-492 # ffffffffc0204cb8 <commands+0x870>
ffffffffc0202eac:	0cd00593          	li	a1,205
ffffffffc0202eb0:	00003517          	auipc	a0,0x3
ffffffffc0202eb4:	8b050513          	addi	a0,a0,-1872 # ffffffffc0205760 <default_pmm_manager+0x710>
ffffffffc0202eb8:	cbcfd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(total == nr_free_pages());
ffffffffc0202ebc:	00002697          	auipc	a3,0x2
ffffffffc0202ec0:	e2c68693          	addi	a3,a3,-468 # ffffffffc0204ce8 <commands+0x8a0>
ffffffffc0202ec4:	00002617          	auipc	a2,0x2
ffffffffc0202ec8:	df460613          	addi	a2,a2,-524 # ffffffffc0204cb8 <commands+0x870>
ffffffffc0202ecc:	0bd00593          	li	a1,189
ffffffffc0202ed0:	00003517          	auipc	a0,0x3
ffffffffc0202ed4:	89050513          	addi	a0,a0,-1904 # ffffffffc0205760 <default_pmm_manager+0x710>
ffffffffc0202ed8:	c9cfd0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0202edc <swap_init_mm>:
     return sm->init_mm(mm);
ffffffffc0202edc:	0000e797          	auipc	a5,0xe
ffffffffc0202ee0:	58c78793          	addi	a5,a5,1420 # ffffffffc0211468 <sm>
ffffffffc0202ee4:	639c                	ld	a5,0(a5)
ffffffffc0202ee6:	0107b303          	ld	t1,16(a5)
ffffffffc0202eea:	8302                	jr	t1

ffffffffc0202eec <swap_map_swappable>:
     return sm->map_swappable(mm, addr, page, swap_in);
ffffffffc0202eec:	0000e797          	auipc	a5,0xe
ffffffffc0202ef0:	57c78793          	addi	a5,a5,1404 # ffffffffc0211468 <sm>
ffffffffc0202ef4:	639c                	ld	a5,0(a5)
ffffffffc0202ef6:	0207b303          	ld	t1,32(a5)
ffffffffc0202efa:	8302                	jr	t1

ffffffffc0202efc <swap_out>:
{
ffffffffc0202efc:	711d                	addi	sp,sp,-96
ffffffffc0202efe:	ec86                	sd	ra,88(sp)
ffffffffc0202f00:	e8a2                	sd	s0,80(sp)
ffffffffc0202f02:	e4a6                	sd	s1,72(sp)
ffffffffc0202f04:	e0ca                	sd	s2,64(sp)
ffffffffc0202f06:	fc4e                	sd	s3,56(sp)
ffffffffc0202f08:	f852                	sd	s4,48(sp)
ffffffffc0202f0a:	f456                	sd	s5,40(sp)
ffffffffc0202f0c:	f05a                	sd	s6,32(sp)
ffffffffc0202f0e:	ec5e                	sd	s7,24(sp)
ffffffffc0202f10:	e862                	sd	s8,16(sp)
     for (i = 0; i != n; ++ i)
ffffffffc0202f12:	cde9                	beqz	a1,ffffffffc0202fec <swap_out+0xf0>
ffffffffc0202f14:	8ab2                	mv	s5,a2
ffffffffc0202f16:	892a                	mv	s2,a0
ffffffffc0202f18:	8a2e                	mv	s4,a1
ffffffffc0202f1a:	4401                	li	s0,0
ffffffffc0202f1c:	0000e997          	auipc	s3,0xe
ffffffffc0202f20:	54c98993          	addi	s3,s3,1356 # ffffffffc0211468 <sm>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0202f24:	00003b17          	auipc	s6,0x3
ffffffffc0202f28:	b24b0b13          	addi	s6,s6,-1244 # ffffffffc0205a48 <default_pmm_manager+0x9f8>
                    cprintf("SWAP: failed to save\n");
ffffffffc0202f2c:	00003b97          	auipc	s7,0x3
ffffffffc0202f30:	b04b8b93          	addi	s7,s7,-1276 # ffffffffc0205a30 <default_pmm_manager+0x9e0>
ffffffffc0202f34:	a825                	j	ffffffffc0202f6c <swap_out+0x70>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0202f36:	67a2                	ld	a5,8(sp)
ffffffffc0202f38:	8626                	mv	a2,s1
ffffffffc0202f3a:	85a2                	mv	a1,s0
ffffffffc0202f3c:	63b4                	ld	a3,64(a5)
ffffffffc0202f3e:	855a                	mv	a0,s6
     for (i = 0; i != n; ++ i)
ffffffffc0202f40:	2405                	addiw	s0,s0,1
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0202f42:	82b1                	srli	a3,a3,0xc
ffffffffc0202f44:	0685                	addi	a3,a3,1
ffffffffc0202f46:	978fd0ef          	jal	ra,ffffffffc02000be <cprintf>
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0202f4a:	6522                	ld	a0,8(sp)
                    free_page(page);
ffffffffc0202f4c:	4585                	li	a1,1
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0202f4e:	613c                	ld	a5,64(a0)
ffffffffc0202f50:	83b1                	srli	a5,a5,0xc
ffffffffc0202f52:	0785                	addi	a5,a5,1
ffffffffc0202f54:	07a2                	slli	a5,a5,0x8
ffffffffc0202f56:	00fc3023          	sd	a5,0(s8) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
                    free_page(page);
ffffffffc0202f5a:	fbcfe0ef          	jal	ra,ffffffffc0201716 <free_pages>
          tlb_invalidate(mm->pgdir, v);
ffffffffc0202f5e:	01893503          	ld	a0,24(s2)
ffffffffc0202f62:	85a6                	mv	a1,s1
ffffffffc0202f64:	ebeff0ef          	jal	ra,ffffffffc0202622 <tlb_invalidate>
     for (i = 0; i != n; ++ i)
ffffffffc0202f68:	048a0d63          	beq	s4,s0,ffffffffc0202fc2 <swap_out+0xc6>
          int r = sm->swap_out_victim(mm, &page, in_tick);
ffffffffc0202f6c:	0009b783          	ld	a5,0(s3)
ffffffffc0202f70:	8656                	mv	a2,s5
ffffffffc0202f72:	002c                	addi	a1,sp,8
ffffffffc0202f74:	7b9c                	ld	a5,48(a5)
ffffffffc0202f76:	854a                	mv	a0,s2
ffffffffc0202f78:	9782                	jalr	a5
          if (r != 0) {
ffffffffc0202f7a:	e12d                	bnez	a0,ffffffffc0202fdc <swap_out+0xe0>
          v=page->pra_vaddr; 
ffffffffc0202f7c:	67a2                	ld	a5,8(sp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0202f7e:	01893503          	ld	a0,24(s2)
ffffffffc0202f82:	4601                	li	a2,0
          v=page->pra_vaddr; 
ffffffffc0202f84:	63a4                	ld	s1,64(a5)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0202f86:	85a6                	mv	a1,s1
ffffffffc0202f88:	815fe0ef          	jal	ra,ffffffffc020179c <get_pte>
          assert((*ptep & PTE_V) != 0);
ffffffffc0202f8c:	611c                	ld	a5,0(a0)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0202f8e:	8c2a                	mv	s8,a0
          assert((*ptep & PTE_V) != 0);
ffffffffc0202f90:	8b85                	andi	a5,a5,1
ffffffffc0202f92:	cfb9                	beqz	a5,ffffffffc0202ff0 <swap_out+0xf4>
          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
ffffffffc0202f94:	65a2                	ld	a1,8(sp)
ffffffffc0202f96:	61bc                	ld	a5,64(a1)
ffffffffc0202f98:	83b1                	srli	a5,a5,0xc
ffffffffc0202f9a:	00178513          	addi	a0,a5,1
ffffffffc0202f9e:	0522                	slli	a0,a0,0x8
ffffffffc0202fa0:	55b000ef          	jal	ra,ffffffffc0203cfa <swapfs_write>
ffffffffc0202fa4:	d949                	beqz	a0,ffffffffc0202f36 <swap_out+0x3a>
                    cprintf("SWAP: failed to save\n");
ffffffffc0202fa6:	855e                	mv	a0,s7
ffffffffc0202fa8:	916fd0ef          	jal	ra,ffffffffc02000be <cprintf>
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0202fac:	0009b783          	ld	a5,0(s3)
ffffffffc0202fb0:	6622                	ld	a2,8(sp)
ffffffffc0202fb2:	4681                	li	a3,0
ffffffffc0202fb4:	739c                	ld	a5,32(a5)
ffffffffc0202fb6:	85a6                	mv	a1,s1
ffffffffc0202fb8:	854a                	mv	a0,s2
     for (i = 0; i != n; ++ i)
ffffffffc0202fba:	2405                	addiw	s0,s0,1
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0202fbc:	9782                	jalr	a5
     for (i = 0; i != n; ++ i)
ffffffffc0202fbe:	fa8a17e3          	bne	s4,s0,ffffffffc0202f6c <swap_out+0x70>
}
ffffffffc0202fc2:	8522                	mv	a0,s0
ffffffffc0202fc4:	60e6                	ld	ra,88(sp)
ffffffffc0202fc6:	6446                	ld	s0,80(sp)
ffffffffc0202fc8:	64a6                	ld	s1,72(sp)
ffffffffc0202fca:	6906                	ld	s2,64(sp)
ffffffffc0202fcc:	79e2                	ld	s3,56(sp)
ffffffffc0202fce:	7a42                	ld	s4,48(sp)
ffffffffc0202fd0:	7aa2                	ld	s5,40(sp)
ffffffffc0202fd2:	7b02                	ld	s6,32(sp)
ffffffffc0202fd4:	6be2                	ld	s7,24(sp)
ffffffffc0202fd6:	6c42                	ld	s8,16(sp)
ffffffffc0202fd8:	6125                	addi	sp,sp,96
ffffffffc0202fda:	8082                	ret
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
ffffffffc0202fdc:	85a2                	mv	a1,s0
ffffffffc0202fde:	00003517          	auipc	a0,0x3
ffffffffc0202fe2:	a0a50513          	addi	a0,a0,-1526 # ffffffffc02059e8 <default_pmm_manager+0x998>
ffffffffc0202fe6:	8d8fd0ef          	jal	ra,ffffffffc02000be <cprintf>
                  break;
ffffffffc0202fea:	bfe1                	j	ffffffffc0202fc2 <swap_out+0xc6>
     for (i = 0; i != n; ++ i)
ffffffffc0202fec:	4401                	li	s0,0
ffffffffc0202fee:	bfd1                	j	ffffffffc0202fc2 <swap_out+0xc6>
          assert((*ptep & PTE_V) != 0);
ffffffffc0202ff0:	00003697          	auipc	a3,0x3
ffffffffc0202ff4:	a2868693          	addi	a3,a3,-1496 # ffffffffc0205a18 <default_pmm_manager+0x9c8>
ffffffffc0202ff8:	00002617          	auipc	a2,0x2
ffffffffc0202ffc:	cc060613          	addi	a2,a2,-832 # ffffffffc0204cb8 <commands+0x870>
ffffffffc0203000:	06600593          	li	a1,102
ffffffffc0203004:	00002517          	auipc	a0,0x2
ffffffffc0203008:	75c50513          	addi	a0,a0,1884 # ffffffffc0205760 <default_pmm_manager+0x710>
ffffffffc020300c:	b68fd0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0203010 <swap_in>:
{
ffffffffc0203010:	7179                	addi	sp,sp,-48
ffffffffc0203012:	e84a                	sd	s2,16(sp)
ffffffffc0203014:	892a                	mv	s2,a0
     struct Page *result = alloc_page();
ffffffffc0203016:	4505                	li	a0,1
{
ffffffffc0203018:	ec26                	sd	s1,24(sp)
ffffffffc020301a:	e44e                	sd	s3,8(sp)
ffffffffc020301c:	f406                	sd	ra,40(sp)
ffffffffc020301e:	f022                	sd	s0,32(sp)
ffffffffc0203020:	84ae                	mv	s1,a1
ffffffffc0203022:	89b2                	mv	s3,a2
     struct Page *result = alloc_page();
ffffffffc0203024:	e6afe0ef          	jal	ra,ffffffffc020168e <alloc_pages>
     assert(result!=NULL);
ffffffffc0203028:	c129                	beqz	a0,ffffffffc020306a <swap_in+0x5a>
     pte_t *ptep = get_pte(mm->pgdir, addr, 0);
ffffffffc020302a:	842a                	mv	s0,a0
ffffffffc020302c:	01893503          	ld	a0,24(s2)
ffffffffc0203030:	4601                	li	a2,0
ffffffffc0203032:	85a6                	mv	a1,s1
ffffffffc0203034:	f68fe0ef          	jal	ra,ffffffffc020179c <get_pte>
ffffffffc0203038:	892a                	mv	s2,a0
     if ((r = swapfs_read((*ptep), result)) != 0)
ffffffffc020303a:	6108                	ld	a0,0(a0)
ffffffffc020303c:	85a2                	mv	a1,s0
ffffffffc020303e:	417000ef          	jal	ra,ffffffffc0203c54 <swapfs_read>
     cprintf("swap_in: load disk swap entry %d with swap_page in vadr 0x%x\n", (*ptep)>>8, addr);
ffffffffc0203042:	00093583          	ld	a1,0(s2)
ffffffffc0203046:	8626                	mv	a2,s1
ffffffffc0203048:	00002517          	auipc	a0,0x2
ffffffffc020304c:	6b850513          	addi	a0,a0,1720 # ffffffffc0205700 <default_pmm_manager+0x6b0>
ffffffffc0203050:	81a1                	srli	a1,a1,0x8
ffffffffc0203052:	86cfd0ef          	jal	ra,ffffffffc02000be <cprintf>
}
ffffffffc0203056:	70a2                	ld	ra,40(sp)
     *ptr_result=result;
ffffffffc0203058:	0089b023          	sd	s0,0(s3)
}
ffffffffc020305c:	7402                	ld	s0,32(sp)
ffffffffc020305e:	64e2                	ld	s1,24(sp)
ffffffffc0203060:	6942                	ld	s2,16(sp)
ffffffffc0203062:	69a2                	ld	s3,8(sp)
ffffffffc0203064:	4501                	li	a0,0
ffffffffc0203066:	6145                	addi	sp,sp,48
ffffffffc0203068:	8082                	ret
     assert(result!=NULL);
ffffffffc020306a:	00002697          	auipc	a3,0x2
ffffffffc020306e:	68668693          	addi	a3,a3,1670 # ffffffffc02056f0 <default_pmm_manager+0x6a0>
ffffffffc0203072:	00002617          	auipc	a2,0x2
ffffffffc0203076:	c4660613          	addi	a2,a2,-954 # ffffffffc0204cb8 <commands+0x870>
ffffffffc020307a:	07c00593          	li	a1,124
ffffffffc020307e:	00002517          	auipc	a0,0x2
ffffffffc0203082:	6e250513          	addi	a0,a0,1762 # ffffffffc0205760 <default_pmm_manager+0x710>
ffffffffc0203086:	aeefd0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc020308a <_clock_init_mm>:
    elm->prev = elm->next = elm;
ffffffffc020308a:	0000e797          	auipc	a5,0xe
ffffffffc020308e:	4f678793          	addi	a5,a5,1270 # ffffffffc0211580 <pra_list_head>
     // 初始化当前指针curr_ptr指向pra_list_head，表示当前页面替换位置为链表头
     // 将mm的私有成员指针指向pra_list_head，用于后续的页面替换算法操作
     //cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
     list_init(&pra_list_head);
     curr_ptr = &pra_list_head;
     mm->sm_priv = &pra_list_head;
ffffffffc0203092:	f51c                	sd	a5,40(a0)
ffffffffc0203094:	e79c                	sd	a5,8(a5)
ffffffffc0203096:	e39c                	sd	a5,0(a5)
     curr_ptr = &pra_list_head;
ffffffffc0203098:	0000e717          	auipc	a4,0xe
ffffffffc020309c:	4ef73c23          	sd	a5,1272(a4) # ffffffffc0211590 <curr_ptr>
     return 0;
}
ffffffffc02030a0:	4501                	li	a0,0
ffffffffc02030a2:	8082                	ret

ffffffffc02030a4 <_clock_init>:

static int
_clock_init(void)
{
    return 0;
}
ffffffffc02030a4:	4501                	li	a0,0
ffffffffc02030a6:	8082                	ret

ffffffffc02030a8 <_clock_set_unswappable>:

static int
_clock_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
    return 0;
}
ffffffffc02030a8:	4501                	li	a0,0
ffffffffc02030aa:	8082                	ret

ffffffffc02030ac <_clock_tick_event>:

static int
_clock_tick_event(struct mm_struct *mm)
{ return 0; }
ffffffffc02030ac:	4501                	li	a0,0
ffffffffc02030ae:	8082                	ret

ffffffffc02030b0 <_clock_check_swap>:
_clock_check_swap(void) {
ffffffffc02030b0:	1141                	addi	sp,sp,-16
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc02030b2:	678d                	lui	a5,0x3
ffffffffc02030b4:	4731                	li	a4,12
_clock_check_swap(void) {
ffffffffc02030b6:	e406                	sd	ra,8(sp)
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc02030b8:	00e78023          	sb	a4,0(a5) # 3000 <BASE_ADDRESS-0xffffffffc01fd000>
    assert(pgfault_num==4);
ffffffffc02030bc:	0000e797          	auipc	a5,0xe
ffffffffc02030c0:	3b878793          	addi	a5,a5,952 # ffffffffc0211474 <pgfault_num>
ffffffffc02030c4:	4398                	lw	a4,0(a5)
ffffffffc02030c6:	4691                	li	a3,4
ffffffffc02030c8:	2701                	sext.w	a4,a4
ffffffffc02030ca:	08d71f63          	bne	a4,a3,ffffffffc0203168 <_clock_check_swap+0xb8>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc02030ce:	6685                	lui	a3,0x1
ffffffffc02030d0:	4629                	li	a2,10
ffffffffc02030d2:	00c68023          	sb	a2,0(a3) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
    assert(pgfault_num==4);
ffffffffc02030d6:	4394                	lw	a3,0(a5)
ffffffffc02030d8:	2681                	sext.w	a3,a3
ffffffffc02030da:	20e69763          	bne	a3,a4,ffffffffc02032e8 <_clock_check_swap+0x238>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc02030de:	6711                	lui	a4,0x4
ffffffffc02030e0:	4635                	li	a2,13
ffffffffc02030e2:	00c70023          	sb	a2,0(a4) # 4000 <BASE_ADDRESS-0xffffffffc01fc000>
    assert(pgfault_num==4);
ffffffffc02030e6:	4398                	lw	a4,0(a5)
ffffffffc02030e8:	2701                	sext.w	a4,a4
ffffffffc02030ea:	1cd71f63          	bne	a4,a3,ffffffffc02032c8 <_clock_check_swap+0x218>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc02030ee:	6689                	lui	a3,0x2
ffffffffc02030f0:	462d                	li	a2,11
ffffffffc02030f2:	00c68023          	sb	a2,0(a3) # 2000 <BASE_ADDRESS-0xffffffffc01fe000>
    assert(pgfault_num==4);
ffffffffc02030f6:	4394                	lw	a3,0(a5)
ffffffffc02030f8:	2681                	sext.w	a3,a3
ffffffffc02030fa:	1ae69763          	bne	a3,a4,ffffffffc02032a8 <_clock_check_swap+0x1f8>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc02030fe:	6715                	lui	a4,0x5
ffffffffc0203100:	46b9                	li	a3,14
ffffffffc0203102:	00d70023          	sb	a3,0(a4) # 5000 <BASE_ADDRESS-0xffffffffc01fb000>
    assert(pgfault_num==5);
ffffffffc0203106:	4398                	lw	a4,0(a5)
ffffffffc0203108:	4695                	li	a3,5
ffffffffc020310a:	2701                	sext.w	a4,a4
ffffffffc020310c:	16d71e63          	bne	a4,a3,ffffffffc0203288 <_clock_check_swap+0x1d8>
    assert(pgfault_num==5);
ffffffffc0203110:	4394                	lw	a3,0(a5)
ffffffffc0203112:	2681                	sext.w	a3,a3
ffffffffc0203114:	14e69a63          	bne	a3,a4,ffffffffc0203268 <_clock_check_swap+0x1b8>
    assert(pgfault_num==5);
ffffffffc0203118:	4398                	lw	a4,0(a5)
ffffffffc020311a:	2701                	sext.w	a4,a4
ffffffffc020311c:	12d71663          	bne	a4,a3,ffffffffc0203248 <_clock_check_swap+0x198>
    assert(pgfault_num==5);
ffffffffc0203120:	4394                	lw	a3,0(a5)
ffffffffc0203122:	2681                	sext.w	a3,a3
ffffffffc0203124:	10e69263          	bne	a3,a4,ffffffffc0203228 <_clock_check_swap+0x178>
    assert(pgfault_num==5);
ffffffffc0203128:	4398                	lw	a4,0(a5)
ffffffffc020312a:	2701                	sext.w	a4,a4
ffffffffc020312c:	0cd71e63          	bne	a4,a3,ffffffffc0203208 <_clock_check_swap+0x158>
    assert(pgfault_num==5);
ffffffffc0203130:	4394                	lw	a3,0(a5)
ffffffffc0203132:	2681                	sext.w	a3,a3
ffffffffc0203134:	0ae69a63          	bne	a3,a4,ffffffffc02031e8 <_clock_check_swap+0x138>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc0203138:	6715                	lui	a4,0x5
ffffffffc020313a:	46b9                	li	a3,14
ffffffffc020313c:	00d70023          	sb	a3,0(a4) # 5000 <BASE_ADDRESS-0xffffffffc01fb000>
    assert(pgfault_num==5);
ffffffffc0203140:	4398                	lw	a4,0(a5)
ffffffffc0203142:	4695                	li	a3,5
ffffffffc0203144:	2701                	sext.w	a4,a4
ffffffffc0203146:	08d71163          	bne	a4,a3,ffffffffc02031c8 <_clock_check_swap+0x118>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc020314a:	6705                	lui	a4,0x1
ffffffffc020314c:	00074683          	lbu	a3,0(a4) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
ffffffffc0203150:	4729                	li	a4,10
ffffffffc0203152:	04e69b63          	bne	a3,a4,ffffffffc02031a8 <_clock_check_swap+0xf8>
    assert(pgfault_num==6);
ffffffffc0203156:	439c                	lw	a5,0(a5)
ffffffffc0203158:	4719                	li	a4,6
ffffffffc020315a:	2781                	sext.w	a5,a5
ffffffffc020315c:	02e79663          	bne	a5,a4,ffffffffc0203188 <_clock_check_swap+0xd8>
}
ffffffffc0203160:	60a2                	ld	ra,8(sp)
ffffffffc0203162:	4501                	li	a0,0
ffffffffc0203164:	0141                	addi	sp,sp,16
ffffffffc0203166:	8082                	ret
    assert(pgfault_num==4);
ffffffffc0203168:	00002697          	auipc	a3,0x2
ffffffffc020316c:	7c068693          	addi	a3,a3,1984 # ffffffffc0205928 <default_pmm_manager+0x8d8>
ffffffffc0203170:	00002617          	auipc	a2,0x2
ffffffffc0203174:	b4860613          	addi	a2,a2,-1208 # ffffffffc0204cb8 <commands+0x870>
ffffffffc0203178:	09100593          	li	a1,145
ffffffffc020317c:	00003517          	auipc	a0,0x3
ffffffffc0203180:	90c50513          	addi	a0,a0,-1780 # ffffffffc0205a88 <default_pmm_manager+0xa38>
ffffffffc0203184:	9f0fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgfault_num==6);
ffffffffc0203188:	00003697          	auipc	a3,0x3
ffffffffc020318c:	95068693          	addi	a3,a3,-1712 # ffffffffc0205ad8 <default_pmm_manager+0xa88>
ffffffffc0203190:	00002617          	auipc	a2,0x2
ffffffffc0203194:	b2860613          	addi	a2,a2,-1240 # ffffffffc0204cb8 <commands+0x870>
ffffffffc0203198:	0a800593          	li	a1,168
ffffffffc020319c:	00003517          	auipc	a0,0x3
ffffffffc02031a0:	8ec50513          	addi	a0,a0,-1812 # ffffffffc0205a88 <default_pmm_manager+0xa38>
ffffffffc02031a4:	9d0fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc02031a8:	00003697          	auipc	a3,0x3
ffffffffc02031ac:	90868693          	addi	a3,a3,-1784 # ffffffffc0205ab0 <default_pmm_manager+0xa60>
ffffffffc02031b0:	00002617          	auipc	a2,0x2
ffffffffc02031b4:	b0860613          	addi	a2,a2,-1272 # ffffffffc0204cb8 <commands+0x870>
ffffffffc02031b8:	0a600593          	li	a1,166
ffffffffc02031bc:	00003517          	auipc	a0,0x3
ffffffffc02031c0:	8cc50513          	addi	a0,a0,-1844 # ffffffffc0205a88 <default_pmm_manager+0xa38>
ffffffffc02031c4:	9b0fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgfault_num==5);
ffffffffc02031c8:	00003697          	auipc	a3,0x3
ffffffffc02031cc:	8d868693          	addi	a3,a3,-1832 # ffffffffc0205aa0 <default_pmm_manager+0xa50>
ffffffffc02031d0:	00002617          	auipc	a2,0x2
ffffffffc02031d4:	ae860613          	addi	a2,a2,-1304 # ffffffffc0204cb8 <commands+0x870>
ffffffffc02031d8:	0a500593          	li	a1,165
ffffffffc02031dc:	00003517          	auipc	a0,0x3
ffffffffc02031e0:	8ac50513          	addi	a0,a0,-1876 # ffffffffc0205a88 <default_pmm_manager+0xa38>
ffffffffc02031e4:	990fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgfault_num==5);
ffffffffc02031e8:	00003697          	auipc	a3,0x3
ffffffffc02031ec:	8b868693          	addi	a3,a3,-1864 # ffffffffc0205aa0 <default_pmm_manager+0xa50>
ffffffffc02031f0:	00002617          	auipc	a2,0x2
ffffffffc02031f4:	ac860613          	addi	a2,a2,-1336 # ffffffffc0204cb8 <commands+0x870>
ffffffffc02031f8:	0a300593          	li	a1,163
ffffffffc02031fc:	00003517          	auipc	a0,0x3
ffffffffc0203200:	88c50513          	addi	a0,a0,-1908 # ffffffffc0205a88 <default_pmm_manager+0xa38>
ffffffffc0203204:	970fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgfault_num==5);
ffffffffc0203208:	00003697          	auipc	a3,0x3
ffffffffc020320c:	89868693          	addi	a3,a3,-1896 # ffffffffc0205aa0 <default_pmm_manager+0xa50>
ffffffffc0203210:	00002617          	auipc	a2,0x2
ffffffffc0203214:	aa860613          	addi	a2,a2,-1368 # ffffffffc0204cb8 <commands+0x870>
ffffffffc0203218:	0a100593          	li	a1,161
ffffffffc020321c:	00003517          	auipc	a0,0x3
ffffffffc0203220:	86c50513          	addi	a0,a0,-1940 # ffffffffc0205a88 <default_pmm_manager+0xa38>
ffffffffc0203224:	950fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgfault_num==5);
ffffffffc0203228:	00003697          	auipc	a3,0x3
ffffffffc020322c:	87868693          	addi	a3,a3,-1928 # ffffffffc0205aa0 <default_pmm_manager+0xa50>
ffffffffc0203230:	00002617          	auipc	a2,0x2
ffffffffc0203234:	a8860613          	addi	a2,a2,-1400 # ffffffffc0204cb8 <commands+0x870>
ffffffffc0203238:	09f00593          	li	a1,159
ffffffffc020323c:	00003517          	auipc	a0,0x3
ffffffffc0203240:	84c50513          	addi	a0,a0,-1972 # ffffffffc0205a88 <default_pmm_manager+0xa38>
ffffffffc0203244:	930fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgfault_num==5);
ffffffffc0203248:	00003697          	auipc	a3,0x3
ffffffffc020324c:	85868693          	addi	a3,a3,-1960 # ffffffffc0205aa0 <default_pmm_manager+0xa50>
ffffffffc0203250:	00002617          	auipc	a2,0x2
ffffffffc0203254:	a6860613          	addi	a2,a2,-1432 # ffffffffc0204cb8 <commands+0x870>
ffffffffc0203258:	09d00593          	li	a1,157
ffffffffc020325c:	00003517          	auipc	a0,0x3
ffffffffc0203260:	82c50513          	addi	a0,a0,-2004 # ffffffffc0205a88 <default_pmm_manager+0xa38>
ffffffffc0203264:	910fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgfault_num==5);
ffffffffc0203268:	00003697          	auipc	a3,0x3
ffffffffc020326c:	83868693          	addi	a3,a3,-1992 # ffffffffc0205aa0 <default_pmm_manager+0xa50>
ffffffffc0203270:	00002617          	auipc	a2,0x2
ffffffffc0203274:	a4860613          	addi	a2,a2,-1464 # ffffffffc0204cb8 <commands+0x870>
ffffffffc0203278:	09b00593          	li	a1,155
ffffffffc020327c:	00003517          	auipc	a0,0x3
ffffffffc0203280:	80c50513          	addi	a0,a0,-2036 # ffffffffc0205a88 <default_pmm_manager+0xa38>
ffffffffc0203284:	8f0fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgfault_num==5);
ffffffffc0203288:	00003697          	auipc	a3,0x3
ffffffffc020328c:	81868693          	addi	a3,a3,-2024 # ffffffffc0205aa0 <default_pmm_manager+0xa50>
ffffffffc0203290:	00002617          	auipc	a2,0x2
ffffffffc0203294:	a2860613          	addi	a2,a2,-1496 # ffffffffc0204cb8 <commands+0x870>
ffffffffc0203298:	09900593          	li	a1,153
ffffffffc020329c:	00002517          	auipc	a0,0x2
ffffffffc02032a0:	7ec50513          	addi	a0,a0,2028 # ffffffffc0205a88 <default_pmm_manager+0xa38>
ffffffffc02032a4:	8d0fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgfault_num==4);
ffffffffc02032a8:	00002697          	auipc	a3,0x2
ffffffffc02032ac:	68068693          	addi	a3,a3,1664 # ffffffffc0205928 <default_pmm_manager+0x8d8>
ffffffffc02032b0:	00002617          	auipc	a2,0x2
ffffffffc02032b4:	a0860613          	addi	a2,a2,-1528 # ffffffffc0204cb8 <commands+0x870>
ffffffffc02032b8:	09700593          	li	a1,151
ffffffffc02032bc:	00002517          	auipc	a0,0x2
ffffffffc02032c0:	7cc50513          	addi	a0,a0,1996 # ffffffffc0205a88 <default_pmm_manager+0xa38>
ffffffffc02032c4:	8b0fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgfault_num==4);
ffffffffc02032c8:	00002697          	auipc	a3,0x2
ffffffffc02032cc:	66068693          	addi	a3,a3,1632 # ffffffffc0205928 <default_pmm_manager+0x8d8>
ffffffffc02032d0:	00002617          	auipc	a2,0x2
ffffffffc02032d4:	9e860613          	addi	a2,a2,-1560 # ffffffffc0204cb8 <commands+0x870>
ffffffffc02032d8:	09500593          	li	a1,149
ffffffffc02032dc:	00002517          	auipc	a0,0x2
ffffffffc02032e0:	7ac50513          	addi	a0,a0,1964 # ffffffffc0205a88 <default_pmm_manager+0xa38>
ffffffffc02032e4:	890fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgfault_num==4);
ffffffffc02032e8:	00002697          	auipc	a3,0x2
ffffffffc02032ec:	64068693          	addi	a3,a3,1600 # ffffffffc0205928 <default_pmm_manager+0x8d8>
ffffffffc02032f0:	00002617          	auipc	a2,0x2
ffffffffc02032f4:	9c860613          	addi	a2,a2,-1592 # ffffffffc0204cb8 <commands+0x870>
ffffffffc02032f8:	09300593          	li	a1,147
ffffffffc02032fc:	00002517          	auipc	a0,0x2
ffffffffc0203300:	78c50513          	addi	a0,a0,1932 # ffffffffc0205a88 <default_pmm_manager+0xa38>
ffffffffc0203304:	870fd0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0203308 <_clock_map_swappable>:
    list_entry_t *entry=&(page->pra_page_link);
ffffffffc0203308:	03060713          	addi	a4,a2,48
    assert(entry != NULL && curr_ptr != NULL);
ffffffffc020330c:	c305                	beqz	a4,ffffffffc020332c <_clock_map_swappable+0x24>
ffffffffc020330e:	0000e797          	auipc	a5,0xe
ffffffffc0203312:	28278793          	addi	a5,a5,642 # ffffffffc0211590 <curr_ptr>
ffffffffc0203316:	639c                	ld	a5,0(a5)
ffffffffc0203318:	cb91                	beqz	a5,ffffffffc020332c <_clock_map_swappable+0x24>
    __list_add(elm, listelm, listelm->next);
ffffffffc020331a:	6794                	ld	a3,8(a5)
}
ffffffffc020331c:	4501                	li	a0,0
    prev->next = next->prev = elm;
ffffffffc020331e:	e298                	sd	a4,0(a3)
ffffffffc0203320:	e798                	sd	a4,8(a5)
    elm->prev = prev;
ffffffffc0203322:	fa1c                	sd	a5,48(a2)
    page->visited = 1;
ffffffffc0203324:	4785                	li	a5,1
    elm->next = next;
ffffffffc0203326:	fe14                	sd	a3,56(a2)
ffffffffc0203328:	ea1c                	sd	a5,16(a2)
}
ffffffffc020332a:	8082                	ret
{
ffffffffc020332c:	1141                	addi	sp,sp,-16
    assert(entry != NULL && curr_ptr != NULL);
ffffffffc020332e:	00002697          	auipc	a3,0x2
ffffffffc0203332:	7ba68693          	addi	a3,a3,1978 # ffffffffc0205ae8 <default_pmm_manager+0xa98>
ffffffffc0203336:	00002617          	auipc	a2,0x2
ffffffffc020333a:	98260613          	addi	a2,a2,-1662 # ffffffffc0204cb8 <commands+0x870>
ffffffffc020333e:	03600593          	li	a1,54
ffffffffc0203342:	00002517          	auipc	a0,0x2
ffffffffc0203346:	74650513          	addi	a0,a0,1862 # ffffffffc0205a88 <default_pmm_manager+0xa38>
{
ffffffffc020334a:	e406                	sd	ra,8(sp)
    assert(entry != NULL && curr_ptr != NULL);
ffffffffc020334c:	828fd0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0203350 <_clock_swap_out_victim>:
{
ffffffffc0203350:	7179                	addi	sp,sp,-48
ffffffffc0203352:	f022                	sd	s0,32(sp)
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc0203354:	7500                	ld	s0,40(a0)
{
ffffffffc0203356:	f406                	sd	ra,40(sp)
ffffffffc0203358:	ec26                	sd	s1,24(sp)
ffffffffc020335a:	e84a                	sd	s2,16(sp)
ffffffffc020335c:	e44e                	sd	s3,8(sp)
         assert(head != NULL);
ffffffffc020335e:	c42d                	beqz	s0,ffffffffc02033c8 <_clock_swap_out_victim+0x78>
     assert(in_tick==0);
ffffffffc0203360:	e641                	bnez	a2,ffffffffc02033e8 <_clock_swap_out_victim+0x98>
ffffffffc0203362:	0000e497          	auipc	s1,0xe
ffffffffc0203366:	22e48493          	addi	s1,s1,558 # ffffffffc0211590 <curr_ptr>
ffffffffc020336a:	89ae                	mv	s3,a1
ffffffffc020336c:	608c                	ld	a1,0(s1)
        cprintf("curr_ptr %p\n", curr_ptr);
ffffffffc020336e:	00002917          	auipc	s2,0x2
ffffffffc0203372:	7c290913          	addi	s2,s2,1986 # ffffffffc0205b30 <default_pmm_manager+0xae0>
        if (curr_ptr == head) {
ffffffffc0203376:	00b40d63          	beq	s0,a1,ffffffffc0203390 <_clock_swap_out_victim+0x40>
        cprintf("curr_ptr %p\n", curr_ptr);
ffffffffc020337a:	854a                	mv	a0,s2
ffffffffc020337c:	d43fc0ef          	jal	ra,ffffffffc02000be <cprintf>
        struct Page* curr_page = le2page(curr_ptr, pra_page_link);
ffffffffc0203380:	608c                	ld	a1,0(s1)
        if (curr_page->visited == 0) {
ffffffffc0203382:	fe05b783          	ld	a5,-32(a1) # fe0 <BASE_ADDRESS-0xffffffffc01ff020>
ffffffffc0203386:	cb99                	beqz	a5,ffffffffc020339c <_clock_swap_out_victim+0x4c>
            curr_page->visited = 0;
ffffffffc0203388:	fe05b023          	sd	zero,-32(a1)
        if (curr_ptr == head) {
ffffffffc020338c:	feb417e3          	bne	s0,a1,ffffffffc020337a <_clock_swap_out_victim+0x2a>
    return listelm->prev;
ffffffffc0203390:	600c                	ld	a1,0(s0)
            curr_ptr = list_prev(curr_ptr);
ffffffffc0203392:	0000e797          	auipc	a5,0xe
ffffffffc0203396:	1eb7bf23          	sd	a1,510(a5) # ffffffffc0211590 <curr_ptr>
            continue;
ffffffffc020339a:	bff1                	j	ffffffffc0203376 <_clock_swap_out_victim+0x26>
ffffffffc020339c:	6198                	ld	a4,0(a1)
}
ffffffffc020339e:	70a2                	ld	ra,40(sp)
ffffffffc02033a0:	7402                	ld	s0,32(sp)
    return listelm->next;
ffffffffc02033a2:	671c                	ld	a5,8(a4)
            curr_ptr = list_prev(curr_ptr);
ffffffffc02033a4:	0000e697          	auipc	a3,0xe
ffffffffc02033a8:	1ee6b623          	sd	a4,492(a3) # ffffffffc0211590 <curr_ptr>
        struct Page* curr_page = le2page(curr_ptr, pra_page_link);
ffffffffc02033ac:	fd058593          	addi	a1,a1,-48
    __list_del(listelm->prev, listelm->next);
ffffffffc02033b0:	6398                	ld	a4,0(a5)
ffffffffc02033b2:	679c                	ld	a5,8(a5)
}
ffffffffc02033b4:	64e2                	ld	s1,24(sp)
ffffffffc02033b6:	6942                	ld	s2,16(sp)
    prev->next = next;
ffffffffc02033b8:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc02033ba:	e398                	sd	a4,0(a5)
            *ptr_page = curr_page;
ffffffffc02033bc:	00b9b023          	sd	a1,0(s3)
}
ffffffffc02033c0:	4501                	li	a0,0
ffffffffc02033c2:	69a2                	ld	s3,8(sp)
ffffffffc02033c4:	6145                	addi	sp,sp,48
ffffffffc02033c6:	8082                	ret
         assert(head != NULL);
ffffffffc02033c8:	00002697          	auipc	a3,0x2
ffffffffc02033cc:	74868693          	addi	a3,a3,1864 # ffffffffc0205b10 <default_pmm_manager+0xac0>
ffffffffc02033d0:	00002617          	auipc	a2,0x2
ffffffffc02033d4:	8e860613          	addi	a2,a2,-1816 # ffffffffc0204cb8 <commands+0x870>
ffffffffc02033d8:	04800593          	li	a1,72
ffffffffc02033dc:	00002517          	auipc	a0,0x2
ffffffffc02033e0:	6ac50513          	addi	a0,a0,1708 # ffffffffc0205a88 <default_pmm_manager+0xa38>
ffffffffc02033e4:	f91fc0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(in_tick==0);
ffffffffc02033e8:	00002697          	auipc	a3,0x2
ffffffffc02033ec:	73868693          	addi	a3,a3,1848 # ffffffffc0205b20 <default_pmm_manager+0xad0>
ffffffffc02033f0:	00002617          	auipc	a2,0x2
ffffffffc02033f4:	8c860613          	addi	a2,a2,-1848 # ffffffffc0204cb8 <commands+0x870>
ffffffffc02033f8:	04900593          	li	a1,73
ffffffffc02033fc:	00002517          	auipc	a0,0x2
ffffffffc0203400:	68c50513          	addi	a0,a0,1676 # ffffffffc0205a88 <default_pmm_manager+0xa38>
ffffffffc0203404:	f71fc0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0203408 <check_vma_overlap.isra.0.part.1>:
}


// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc0203408:	1141                	addi	sp,sp,-16
    assert(prev->vm_start < prev->vm_end);
    assert(prev->vm_end <= next->vm_start);
    assert(next->vm_start < next->vm_end);
ffffffffc020340a:	00002697          	auipc	a3,0x2
ffffffffc020340e:	74e68693          	addi	a3,a3,1870 # ffffffffc0205b58 <default_pmm_manager+0xb08>
ffffffffc0203412:	00002617          	auipc	a2,0x2
ffffffffc0203416:	8a660613          	addi	a2,a2,-1882 # ffffffffc0204cb8 <commands+0x870>
ffffffffc020341a:	07d00593          	li	a1,125
ffffffffc020341e:	00002517          	auipc	a0,0x2
ffffffffc0203422:	75a50513          	addi	a0,a0,1882 # ffffffffc0205b78 <default_pmm_manager+0xb28>
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc0203426:	e406                	sd	ra,8(sp)
    assert(next->vm_start < next->vm_end);
ffffffffc0203428:	f4dfc0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc020342c <mm_create>:
mm_create(void) {
ffffffffc020342c:	1141                	addi	sp,sp,-16
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc020342e:	03000513          	li	a0,48
mm_create(void) {
ffffffffc0203432:	e022                	sd	s0,0(sp)
ffffffffc0203434:	e406                	sd	ra,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0203436:	a84ff0ef          	jal	ra,ffffffffc02026ba <kmalloc>
ffffffffc020343a:	842a                	mv	s0,a0
    if (mm != NULL) {
ffffffffc020343c:	c115                	beqz	a0,ffffffffc0203460 <mm_create+0x34>
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc020343e:	0000e797          	auipc	a5,0xe
ffffffffc0203442:	03278793          	addi	a5,a5,50 # ffffffffc0211470 <swap_init_ok>
ffffffffc0203446:	439c                	lw	a5,0(a5)
    elm->prev = elm->next = elm;
ffffffffc0203448:	e408                	sd	a0,8(s0)
ffffffffc020344a:	e008                	sd	a0,0(s0)
        mm->mmap_cache = NULL;
ffffffffc020344c:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc0203450:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc0203454:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0203458:	2781                	sext.w	a5,a5
ffffffffc020345a:	eb81                	bnez	a5,ffffffffc020346a <mm_create+0x3e>
        else mm->sm_priv = NULL;
ffffffffc020345c:	02053423          	sd	zero,40(a0)
}
ffffffffc0203460:	8522                	mv	a0,s0
ffffffffc0203462:	60a2                	ld	ra,8(sp)
ffffffffc0203464:	6402                	ld	s0,0(sp)
ffffffffc0203466:	0141                	addi	sp,sp,16
ffffffffc0203468:	8082                	ret
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc020346a:	a73ff0ef          	jal	ra,ffffffffc0202edc <swap_init_mm>
}
ffffffffc020346e:	8522                	mv	a0,s0
ffffffffc0203470:	60a2                	ld	ra,8(sp)
ffffffffc0203472:	6402                	ld	s0,0(sp)
ffffffffc0203474:	0141                	addi	sp,sp,16
ffffffffc0203476:	8082                	ret

ffffffffc0203478 <vma_create>:
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint_t vm_flags) {
ffffffffc0203478:	1101                	addi	sp,sp,-32
ffffffffc020347a:	e04a                	sd	s2,0(sp)
ffffffffc020347c:	892a                	mv	s2,a0
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc020347e:	03000513          	li	a0,48
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint_t vm_flags) {
ffffffffc0203482:	e822                	sd	s0,16(sp)
ffffffffc0203484:	e426                	sd	s1,8(sp)
ffffffffc0203486:	ec06                	sd	ra,24(sp)
ffffffffc0203488:	84ae                	mv	s1,a1
ffffffffc020348a:	8432                	mv	s0,a2
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc020348c:	a2eff0ef          	jal	ra,ffffffffc02026ba <kmalloc>
    if (vma != NULL) {
ffffffffc0203490:	c509                	beqz	a0,ffffffffc020349a <vma_create+0x22>
        vma->vm_start = vm_start;
ffffffffc0203492:	01253423          	sd	s2,8(a0)
        vma->vm_end = vm_end;
ffffffffc0203496:	e904                	sd	s1,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0203498:	ed00                	sd	s0,24(a0)
}
ffffffffc020349a:	60e2                	ld	ra,24(sp)
ffffffffc020349c:	6442                	ld	s0,16(sp)
ffffffffc020349e:	64a2                	ld	s1,8(sp)
ffffffffc02034a0:	6902                	ld	s2,0(sp)
ffffffffc02034a2:	6105                	addi	sp,sp,32
ffffffffc02034a4:	8082                	ret

ffffffffc02034a6 <find_vma>:
    if (mm != NULL) {
ffffffffc02034a6:	c51d                	beqz	a0,ffffffffc02034d4 <find_vma+0x2e>
        vma = mm->mmap_cache;
ffffffffc02034a8:	691c                	ld	a5,16(a0)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc02034aa:	c781                	beqz	a5,ffffffffc02034b2 <find_vma+0xc>
ffffffffc02034ac:	6798                	ld	a4,8(a5)
ffffffffc02034ae:	02e5f663          	bleu	a4,a1,ffffffffc02034da <find_vma+0x34>
                list_entry_t *list = &(mm->mmap_list), *le = list;
ffffffffc02034b2:	87aa                	mv	a5,a0
    return listelm->next;
ffffffffc02034b4:	679c                	ld	a5,8(a5)
                while ((le = list_next(le)) != list) {
ffffffffc02034b6:	00f50f63          	beq	a0,a5,ffffffffc02034d4 <find_vma+0x2e>
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
ffffffffc02034ba:	fe87b703          	ld	a4,-24(a5)
ffffffffc02034be:	fee5ebe3          	bltu	a1,a4,ffffffffc02034b4 <find_vma+0xe>
ffffffffc02034c2:	ff07b703          	ld	a4,-16(a5)
ffffffffc02034c6:	fee5f7e3          	bleu	a4,a1,ffffffffc02034b4 <find_vma+0xe>
                    vma = le2vma(le, list_link);
ffffffffc02034ca:	1781                	addi	a5,a5,-32
        if (vma != NULL) {
ffffffffc02034cc:	c781                	beqz	a5,ffffffffc02034d4 <find_vma+0x2e>
            mm->mmap_cache = vma;
ffffffffc02034ce:	e91c                	sd	a5,16(a0)
}
ffffffffc02034d0:	853e                	mv	a0,a5
ffffffffc02034d2:	8082                	ret
    struct vma_struct *vma = NULL;
ffffffffc02034d4:	4781                	li	a5,0
}
ffffffffc02034d6:	853e                	mv	a0,a5
ffffffffc02034d8:	8082                	ret
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc02034da:	6b98                	ld	a4,16(a5)
ffffffffc02034dc:	fce5fbe3          	bleu	a4,a1,ffffffffc02034b2 <find_vma+0xc>
            mm->mmap_cache = vma;
ffffffffc02034e0:	e91c                	sd	a5,16(a0)
    return vma;
ffffffffc02034e2:	b7fd                	j	ffffffffc02034d0 <find_vma+0x2a>

ffffffffc02034e4 <insert_vma_struct>:


// insert_vma_struct -insert vma in mm's list link
void
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
    assert(vma->vm_start < vma->vm_end);
ffffffffc02034e4:	6590                	ld	a2,8(a1)
ffffffffc02034e6:	0105b803          	ld	a6,16(a1)
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
ffffffffc02034ea:	1141                	addi	sp,sp,-16
ffffffffc02034ec:	e406                	sd	ra,8(sp)
ffffffffc02034ee:	872a                	mv	a4,a0
    assert(vma->vm_start < vma->vm_end);
ffffffffc02034f0:	01066863          	bltu	a2,a6,ffffffffc0203500 <insert_vma_struct+0x1c>
ffffffffc02034f4:	a8b9                	j	ffffffffc0203552 <insert_vma_struct+0x6e>
    list_entry_t *le_prev = list, *le_next;

        list_entry_t *le = list;
        while ((le = list_next(le)) != list) {
            struct vma_struct *mmap_prev = le2vma(le, list_link);
            if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc02034f6:	fe87b683          	ld	a3,-24(a5)
ffffffffc02034fa:	04d66763          	bltu	a2,a3,ffffffffc0203548 <insert_vma_struct+0x64>
ffffffffc02034fe:	873e                	mv	a4,a5
ffffffffc0203500:	671c                	ld	a5,8(a4)
        while ((le = list_next(le)) != list) {
ffffffffc0203502:	fef51ae3          	bne	a0,a5,ffffffffc02034f6 <insert_vma_struct+0x12>
        }

    le_next = list_next(le_prev);

    /* check overlap */
    if (le_prev != list) {
ffffffffc0203506:	02a70463          	beq	a4,a0,ffffffffc020352e <insert_vma_struct+0x4a>
        check_vma_overlap(le2vma(le_prev, list_link), vma);
ffffffffc020350a:	ff073683          	ld	a3,-16(a4)
    assert(prev->vm_start < prev->vm_end);
ffffffffc020350e:	fe873883          	ld	a7,-24(a4)
ffffffffc0203512:	08d8f063          	bleu	a3,a7,ffffffffc0203592 <insert_vma_struct+0xae>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0203516:	04d66e63          	bltu	a2,a3,ffffffffc0203572 <insert_vma_struct+0x8e>
    }
    if (le_next != list) {
ffffffffc020351a:	00f50a63          	beq	a0,a5,ffffffffc020352e <insert_vma_struct+0x4a>
ffffffffc020351e:	fe87b683          	ld	a3,-24(a5)
    assert(prev->vm_end <= next->vm_start);
ffffffffc0203522:	0506e863          	bltu	a3,a6,ffffffffc0203572 <insert_vma_struct+0x8e>
    assert(next->vm_start < next->vm_end);
ffffffffc0203526:	ff07b603          	ld	a2,-16(a5)
ffffffffc020352a:	02c6f263          	bleu	a2,a3,ffffffffc020354e <insert_vma_struct+0x6a>
    }

    vma->vm_mm = mm;
    list_add_after(le_prev, &(vma->list_link));

    mm->map_count ++;
ffffffffc020352e:	5114                	lw	a3,32(a0)
    vma->vm_mm = mm;
ffffffffc0203530:	e188                	sd	a0,0(a1)
    list_add_after(le_prev, &(vma->list_link));
ffffffffc0203532:	02058613          	addi	a2,a1,32
    prev->next = next->prev = elm;
ffffffffc0203536:	e390                	sd	a2,0(a5)
ffffffffc0203538:	e710                	sd	a2,8(a4)
}
ffffffffc020353a:	60a2                	ld	ra,8(sp)
    elm->next = next;
ffffffffc020353c:	f59c                	sd	a5,40(a1)
    elm->prev = prev;
ffffffffc020353e:	f198                	sd	a4,32(a1)
    mm->map_count ++;
ffffffffc0203540:	2685                	addiw	a3,a3,1
ffffffffc0203542:	d114                	sw	a3,32(a0)
}
ffffffffc0203544:	0141                	addi	sp,sp,16
ffffffffc0203546:	8082                	ret
    if (le_prev != list) {
ffffffffc0203548:	fca711e3          	bne	a4,a0,ffffffffc020350a <insert_vma_struct+0x26>
ffffffffc020354c:	bfd9                	j	ffffffffc0203522 <insert_vma_struct+0x3e>
ffffffffc020354e:	ebbff0ef          	jal	ra,ffffffffc0203408 <check_vma_overlap.isra.0.part.1>
    assert(vma->vm_start < vma->vm_end);
ffffffffc0203552:	00002697          	auipc	a3,0x2
ffffffffc0203556:	6d668693          	addi	a3,a3,1750 # ffffffffc0205c28 <default_pmm_manager+0xbd8>
ffffffffc020355a:	00001617          	auipc	a2,0x1
ffffffffc020355e:	75e60613          	addi	a2,a2,1886 # ffffffffc0204cb8 <commands+0x870>
ffffffffc0203562:	08400593          	li	a1,132
ffffffffc0203566:	00002517          	auipc	a0,0x2
ffffffffc020356a:	61250513          	addi	a0,a0,1554 # ffffffffc0205b78 <default_pmm_manager+0xb28>
ffffffffc020356e:	e07fc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0203572:	00002697          	auipc	a3,0x2
ffffffffc0203576:	6f668693          	addi	a3,a3,1782 # ffffffffc0205c68 <default_pmm_manager+0xc18>
ffffffffc020357a:	00001617          	auipc	a2,0x1
ffffffffc020357e:	73e60613          	addi	a2,a2,1854 # ffffffffc0204cb8 <commands+0x870>
ffffffffc0203582:	07c00593          	li	a1,124
ffffffffc0203586:	00002517          	auipc	a0,0x2
ffffffffc020358a:	5f250513          	addi	a0,a0,1522 # ffffffffc0205b78 <default_pmm_manager+0xb28>
ffffffffc020358e:	de7fc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(prev->vm_start < prev->vm_end);
ffffffffc0203592:	00002697          	auipc	a3,0x2
ffffffffc0203596:	6b668693          	addi	a3,a3,1718 # ffffffffc0205c48 <default_pmm_manager+0xbf8>
ffffffffc020359a:	00001617          	auipc	a2,0x1
ffffffffc020359e:	71e60613          	addi	a2,a2,1822 # ffffffffc0204cb8 <commands+0x870>
ffffffffc02035a2:	07b00593          	li	a1,123
ffffffffc02035a6:	00002517          	auipc	a0,0x2
ffffffffc02035aa:	5d250513          	addi	a0,a0,1490 # ffffffffc0205b78 <default_pmm_manager+0xb28>
ffffffffc02035ae:	dc7fc0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc02035b2 <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {
ffffffffc02035b2:	1141                	addi	sp,sp,-16
ffffffffc02035b4:	e022                	sd	s0,0(sp)
ffffffffc02035b6:	842a                	mv	s0,a0
    return listelm->next;
ffffffffc02035b8:	6508                	ld	a0,8(a0)
ffffffffc02035ba:	e406                	sd	ra,8(sp)

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list) {
ffffffffc02035bc:	00a40e63          	beq	s0,a0,ffffffffc02035d8 <mm_destroy+0x26>
    __list_del(listelm->prev, listelm->next);
ffffffffc02035c0:	6118                	ld	a4,0(a0)
ffffffffc02035c2:	651c                	ld	a5,8(a0)
        list_del(le);
        kfree(le2vma(le, list_link),sizeof(struct vma_struct));  //kfree vma        
ffffffffc02035c4:	03000593          	li	a1,48
ffffffffc02035c8:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc02035ca:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc02035cc:	e398                	sd	a4,0(a5)
ffffffffc02035ce:	9aeff0ef          	jal	ra,ffffffffc020277c <kfree>
    return listelm->next;
ffffffffc02035d2:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list) {
ffffffffc02035d4:	fea416e3          	bne	s0,a0,ffffffffc02035c0 <mm_destroy+0xe>
    }
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc02035d8:	8522                	mv	a0,s0
    mm=NULL;
}
ffffffffc02035da:	6402                	ld	s0,0(sp)
ffffffffc02035dc:	60a2                	ld	ra,8(sp)
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc02035de:	03000593          	li	a1,48
}
ffffffffc02035e2:	0141                	addi	sp,sp,16
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc02035e4:	998ff06f          	j	ffffffffc020277c <kfree>

ffffffffc02035e8 <vmm_init>:

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void
vmm_init(void) {
ffffffffc02035e8:	715d                	addi	sp,sp,-80
ffffffffc02035ea:	e486                	sd	ra,72(sp)
ffffffffc02035ec:	e0a2                	sd	s0,64(sp)
ffffffffc02035ee:	fc26                	sd	s1,56(sp)
ffffffffc02035f0:	f84a                	sd	s2,48(sp)
ffffffffc02035f2:	f052                	sd	s4,32(sp)
ffffffffc02035f4:	f44e                	sd	s3,40(sp)
ffffffffc02035f6:	ec56                	sd	s5,24(sp)
ffffffffc02035f8:	e85a                	sd	s6,16(sp)
ffffffffc02035fa:	e45e                	sd	s7,8(sp)
}

// check_vmm - check correctness of vmm
static void
check_vmm(void) {
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc02035fc:	960fe0ef          	jal	ra,ffffffffc020175c <nr_free_pages>
ffffffffc0203600:	892a                	mv	s2,a0
    cprintf("check_vmm() succeeded.\n");
}

static void
check_vma_struct(void) {
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0203602:	95afe0ef          	jal	ra,ffffffffc020175c <nr_free_pages>
ffffffffc0203606:	8a2a                	mv	s4,a0

    struct mm_struct *mm = mm_create();
ffffffffc0203608:	e25ff0ef          	jal	ra,ffffffffc020342c <mm_create>
    assert(mm != NULL);
ffffffffc020360c:	842a                	mv	s0,a0
ffffffffc020360e:	03200493          	li	s1,50
ffffffffc0203612:	e919                	bnez	a0,ffffffffc0203628 <vmm_init+0x40>
ffffffffc0203614:	aeed                	j	ffffffffc0203a0e <vmm_init+0x426>
        vma->vm_start = vm_start;
ffffffffc0203616:	e504                	sd	s1,8(a0)
        vma->vm_end = vm_end;
ffffffffc0203618:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc020361a:	00053c23          	sd	zero,24(a0)

    int i;
    for (i = step1; i >= 1; i --) {
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc020361e:	14ed                	addi	s1,s1,-5
ffffffffc0203620:	8522                	mv	a0,s0
ffffffffc0203622:	ec3ff0ef          	jal	ra,ffffffffc02034e4 <insert_vma_struct>
    for (i = step1; i >= 1; i --) {
ffffffffc0203626:	c88d                	beqz	s1,ffffffffc0203658 <vmm_init+0x70>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0203628:	03000513          	li	a0,48
ffffffffc020362c:	88eff0ef          	jal	ra,ffffffffc02026ba <kmalloc>
ffffffffc0203630:	85aa                	mv	a1,a0
ffffffffc0203632:	00248793          	addi	a5,s1,2
    if (vma != NULL) {
ffffffffc0203636:	f165                	bnez	a0,ffffffffc0203616 <vmm_init+0x2e>
        assert(vma != NULL);
ffffffffc0203638:	00002697          	auipc	a3,0x2
ffffffffc020363c:	1b068693          	addi	a3,a3,432 # ffffffffc02057e8 <default_pmm_manager+0x798>
ffffffffc0203640:	00001617          	auipc	a2,0x1
ffffffffc0203644:	67860613          	addi	a2,a2,1656 # ffffffffc0204cb8 <commands+0x870>
ffffffffc0203648:	0ce00593          	li	a1,206
ffffffffc020364c:	00002517          	auipc	a0,0x2
ffffffffc0203650:	52c50513          	addi	a0,a0,1324 # ffffffffc0205b78 <default_pmm_manager+0xb28>
ffffffffc0203654:	d21fc0ef          	jal	ra,ffffffffc0200374 <__panic>
    for (i = step1; i >= 1; i --) {
ffffffffc0203658:	03700493          	li	s1,55
    }

    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc020365c:	1f900993          	li	s3,505
ffffffffc0203660:	a819                	j	ffffffffc0203676 <vmm_init+0x8e>
        vma->vm_start = vm_start;
ffffffffc0203662:	e504                	sd	s1,8(a0)
        vma->vm_end = vm_end;
ffffffffc0203664:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0203666:	00053c23          	sd	zero,24(a0)
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc020366a:	0495                	addi	s1,s1,5
ffffffffc020366c:	8522                	mv	a0,s0
ffffffffc020366e:	e77ff0ef          	jal	ra,ffffffffc02034e4 <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc0203672:	03348a63          	beq	s1,s3,ffffffffc02036a6 <vmm_init+0xbe>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0203676:	03000513          	li	a0,48
ffffffffc020367a:	840ff0ef          	jal	ra,ffffffffc02026ba <kmalloc>
ffffffffc020367e:	85aa                	mv	a1,a0
ffffffffc0203680:	00248793          	addi	a5,s1,2
    if (vma != NULL) {
ffffffffc0203684:	fd79                	bnez	a0,ffffffffc0203662 <vmm_init+0x7a>
        assert(vma != NULL);
ffffffffc0203686:	00002697          	auipc	a3,0x2
ffffffffc020368a:	16268693          	addi	a3,a3,354 # ffffffffc02057e8 <default_pmm_manager+0x798>
ffffffffc020368e:	00001617          	auipc	a2,0x1
ffffffffc0203692:	62a60613          	addi	a2,a2,1578 # ffffffffc0204cb8 <commands+0x870>
ffffffffc0203696:	0d400593          	li	a1,212
ffffffffc020369a:	00002517          	auipc	a0,0x2
ffffffffc020369e:	4de50513          	addi	a0,a0,1246 # ffffffffc0205b78 <default_pmm_manager+0xb28>
ffffffffc02036a2:	cd3fc0ef          	jal	ra,ffffffffc0200374 <__panic>
ffffffffc02036a6:	6418                	ld	a4,8(s0)
ffffffffc02036a8:	479d                	li	a5,7
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i ++) {
ffffffffc02036aa:	1fb00593          	li	a1,507
        assert(le != &(mm->mmap_list));
ffffffffc02036ae:	2ae40063          	beq	s0,a4,ffffffffc020394e <vmm_init+0x366>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc02036b2:	fe873603          	ld	a2,-24(a4)
ffffffffc02036b6:	ffe78693          	addi	a3,a5,-2
ffffffffc02036ba:	20d61a63          	bne	a2,a3,ffffffffc02038ce <vmm_init+0x2e6>
ffffffffc02036be:	ff073683          	ld	a3,-16(a4)
ffffffffc02036c2:	20d79663          	bne	a5,a3,ffffffffc02038ce <vmm_init+0x2e6>
ffffffffc02036c6:	0795                	addi	a5,a5,5
ffffffffc02036c8:	6718                	ld	a4,8(a4)
    for (i = 1; i <= step2; i ++) {
ffffffffc02036ca:	feb792e3          	bne	a5,a1,ffffffffc02036ae <vmm_init+0xc6>
ffffffffc02036ce:	499d                	li	s3,7
ffffffffc02036d0:	4495                	li	s1,5
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc02036d2:	1f900b93          	li	s7,505
        struct vma_struct *vma1 = find_vma(mm, i);
ffffffffc02036d6:	85a6                	mv	a1,s1
ffffffffc02036d8:	8522                	mv	a0,s0
ffffffffc02036da:	dcdff0ef          	jal	ra,ffffffffc02034a6 <find_vma>
ffffffffc02036de:	8b2a                	mv	s6,a0
        assert(vma1 != NULL);
ffffffffc02036e0:	2e050763          	beqz	a0,ffffffffc02039ce <vmm_init+0x3e6>
        struct vma_struct *vma2 = find_vma(mm, i+1);
ffffffffc02036e4:	00148593          	addi	a1,s1,1
ffffffffc02036e8:	8522                	mv	a0,s0
ffffffffc02036ea:	dbdff0ef          	jal	ra,ffffffffc02034a6 <find_vma>
ffffffffc02036ee:	8aaa                	mv	s5,a0
        assert(vma2 != NULL);
ffffffffc02036f0:	2a050f63          	beqz	a0,ffffffffc02039ae <vmm_init+0x3c6>
        struct vma_struct *vma3 = find_vma(mm, i+2);
ffffffffc02036f4:	85ce                	mv	a1,s3
ffffffffc02036f6:	8522                	mv	a0,s0
ffffffffc02036f8:	dafff0ef          	jal	ra,ffffffffc02034a6 <find_vma>
        assert(vma3 == NULL);
ffffffffc02036fc:	28051963          	bnez	a0,ffffffffc020398e <vmm_init+0x3a6>
        struct vma_struct *vma4 = find_vma(mm, i+3);
ffffffffc0203700:	00348593          	addi	a1,s1,3
ffffffffc0203704:	8522                	mv	a0,s0
ffffffffc0203706:	da1ff0ef          	jal	ra,ffffffffc02034a6 <find_vma>
        assert(vma4 == NULL);
ffffffffc020370a:	26051263          	bnez	a0,ffffffffc020396e <vmm_init+0x386>
        struct vma_struct *vma5 = find_vma(mm, i+4);
ffffffffc020370e:	00448593          	addi	a1,s1,4
ffffffffc0203712:	8522                	mv	a0,s0
ffffffffc0203714:	d93ff0ef          	jal	ra,ffffffffc02034a6 <find_vma>
        assert(vma5 == NULL);
ffffffffc0203718:	2c051b63          	bnez	a0,ffffffffc02039ee <vmm_init+0x406>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc020371c:	008b3783          	ld	a5,8(s6)
ffffffffc0203720:	1c979763          	bne	a5,s1,ffffffffc02038ee <vmm_init+0x306>
ffffffffc0203724:	010b3783          	ld	a5,16(s6)
ffffffffc0203728:	1d379363          	bne	a5,s3,ffffffffc02038ee <vmm_init+0x306>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc020372c:	008ab783          	ld	a5,8(s5)
ffffffffc0203730:	1c979f63          	bne	a5,s1,ffffffffc020390e <vmm_init+0x326>
ffffffffc0203734:	010ab783          	ld	a5,16(s5)
ffffffffc0203738:	1d379b63          	bne	a5,s3,ffffffffc020390e <vmm_init+0x326>
ffffffffc020373c:	0495                	addi	s1,s1,5
ffffffffc020373e:	0995                	addi	s3,s3,5
    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc0203740:	f9749be3          	bne	s1,s7,ffffffffc02036d6 <vmm_init+0xee>
ffffffffc0203744:	4491                	li	s1,4
    }

    for (i =4; i>=0; i--) {
ffffffffc0203746:	59fd                	li	s3,-1
        struct vma_struct *vma_below_5= find_vma(mm,i);
ffffffffc0203748:	85a6                	mv	a1,s1
ffffffffc020374a:	8522                	mv	a0,s0
ffffffffc020374c:	d5bff0ef          	jal	ra,ffffffffc02034a6 <find_vma>
ffffffffc0203750:	0004859b          	sext.w	a1,s1
        if (vma_below_5 != NULL ) {
ffffffffc0203754:	c90d                	beqz	a0,ffffffffc0203786 <vmm_init+0x19e>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
ffffffffc0203756:	6914                	ld	a3,16(a0)
ffffffffc0203758:	6510                	ld	a2,8(a0)
ffffffffc020375a:	00002517          	auipc	a0,0x2
ffffffffc020375e:	62e50513          	addi	a0,a0,1582 # ffffffffc0205d88 <default_pmm_manager+0xd38>
ffffffffc0203762:	95dfc0ef          	jal	ra,ffffffffc02000be <cprintf>
        }
        assert(vma_below_5 == NULL);
ffffffffc0203766:	00002697          	auipc	a3,0x2
ffffffffc020376a:	64a68693          	addi	a3,a3,1610 # ffffffffc0205db0 <default_pmm_manager+0xd60>
ffffffffc020376e:	00001617          	auipc	a2,0x1
ffffffffc0203772:	54a60613          	addi	a2,a2,1354 # ffffffffc0204cb8 <commands+0x870>
ffffffffc0203776:	0f600593          	li	a1,246
ffffffffc020377a:	00002517          	auipc	a0,0x2
ffffffffc020377e:	3fe50513          	addi	a0,a0,1022 # ffffffffc0205b78 <default_pmm_manager+0xb28>
ffffffffc0203782:	bf3fc0ef          	jal	ra,ffffffffc0200374 <__panic>
ffffffffc0203786:	14fd                	addi	s1,s1,-1
    for (i =4; i>=0; i--) {
ffffffffc0203788:	fd3490e3          	bne	s1,s3,ffffffffc0203748 <vmm_init+0x160>
    }

    mm_destroy(mm);
ffffffffc020378c:	8522                	mv	a0,s0
ffffffffc020378e:	e25ff0ef          	jal	ra,ffffffffc02035b2 <mm_destroy>

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0203792:	fcbfd0ef          	jal	ra,ffffffffc020175c <nr_free_pages>
ffffffffc0203796:	28aa1c63          	bne	s4,a0,ffffffffc0203a2e <vmm_init+0x446>

    cprintf("check_vma_struct() succeeded!\n");
ffffffffc020379a:	00002517          	auipc	a0,0x2
ffffffffc020379e:	65650513          	addi	a0,a0,1622 # ffffffffc0205df0 <default_pmm_manager+0xda0>
ffffffffc02037a2:	91dfc0ef          	jal	ra,ffffffffc02000be <cprintf>

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void) {
	// char *name = "check_pgfault";
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc02037a6:	fb7fd0ef          	jal	ra,ffffffffc020175c <nr_free_pages>
ffffffffc02037aa:	89aa                	mv	s3,a0

    check_mm_struct = mm_create();
ffffffffc02037ac:	c81ff0ef          	jal	ra,ffffffffc020342c <mm_create>
ffffffffc02037b0:	0000e797          	auipc	a5,0xe
ffffffffc02037b4:	dea7b423          	sd	a0,-536(a5) # ffffffffc0211598 <check_mm_struct>
ffffffffc02037b8:	842a                	mv	s0,a0

    assert(check_mm_struct != NULL);
ffffffffc02037ba:	2a050a63          	beqz	a0,ffffffffc0203a6e <vmm_init+0x486>
    struct mm_struct *mm = check_mm_struct;
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc02037be:	0000e797          	auipc	a5,0xe
ffffffffc02037c2:	c9a78793          	addi	a5,a5,-870 # ffffffffc0211458 <boot_pgdir>
ffffffffc02037c6:	6384                	ld	s1,0(a5)
    assert(pgdir[0] == 0);
ffffffffc02037c8:	609c                	ld	a5,0(s1)
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc02037ca:	ed04                	sd	s1,24(a0)
    assert(pgdir[0] == 0);
ffffffffc02037cc:	32079d63          	bnez	a5,ffffffffc0203b06 <vmm_init+0x51e>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02037d0:	03000513          	li	a0,48
ffffffffc02037d4:	ee7fe0ef          	jal	ra,ffffffffc02026ba <kmalloc>
ffffffffc02037d8:	8a2a                	mv	s4,a0
    if (vma != NULL) {
ffffffffc02037da:	14050a63          	beqz	a0,ffffffffc020392e <vmm_init+0x346>
        vma->vm_end = vm_end;
ffffffffc02037de:	002007b7          	lui	a5,0x200
ffffffffc02037e2:	00fa3823          	sd	a5,16(s4)
        vma->vm_flags = vm_flags;
ffffffffc02037e6:	4789                	li	a5,2

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);

    assert(vma != NULL);

    insert_vma_struct(mm, vma);
ffffffffc02037e8:	85aa                	mv	a1,a0
        vma->vm_flags = vm_flags;
ffffffffc02037ea:	00fa3c23          	sd	a5,24(s4)
    insert_vma_struct(mm, vma);
ffffffffc02037ee:	8522                	mv	a0,s0
        vma->vm_start = vm_start;
ffffffffc02037f0:	000a3423          	sd	zero,8(s4)
    insert_vma_struct(mm, vma);
ffffffffc02037f4:	cf1ff0ef          	jal	ra,ffffffffc02034e4 <insert_vma_struct>

    uintptr_t addr = 0x100;
    assert(find_vma(mm, addr) == vma);
ffffffffc02037f8:	10000593          	li	a1,256
ffffffffc02037fc:	8522                	mv	a0,s0
ffffffffc02037fe:	ca9ff0ef          	jal	ra,ffffffffc02034a6 <find_vma>
ffffffffc0203802:	10000793          	li	a5,256

    int i, sum = 0;
    for (i = 0; i < 100; i ++) {
ffffffffc0203806:	16400713          	li	a4,356
    assert(find_vma(mm, addr) == vma);
ffffffffc020380a:	2aaa1263          	bne	s4,a0,ffffffffc0203aae <vmm_init+0x4c6>
        *(char *)(addr + i) = i;
ffffffffc020380e:	00f78023          	sb	a5,0(a5) # 200000 <BASE_ADDRESS-0xffffffffc0000000>
        sum += i;
ffffffffc0203812:	0785                	addi	a5,a5,1
    for (i = 0; i < 100; i ++) {
ffffffffc0203814:	fee79de3          	bne	a5,a4,ffffffffc020380e <vmm_init+0x226>
        sum += i;
ffffffffc0203818:	6705                	lui	a4,0x1
    for (i = 0; i < 100; i ++) {
ffffffffc020381a:	10000793          	li	a5,256
        sum += i;
ffffffffc020381e:	35670713          	addi	a4,a4,854 # 1356 <BASE_ADDRESS-0xffffffffc01fecaa>
    }
    for (i = 0; i < 100; i ++) {
ffffffffc0203822:	16400613          	li	a2,356
        sum -= *(char *)(addr + i);
ffffffffc0203826:	0007c683          	lbu	a3,0(a5)
ffffffffc020382a:	0785                	addi	a5,a5,1
ffffffffc020382c:	9f15                	subw	a4,a4,a3
    for (i = 0; i < 100; i ++) {
ffffffffc020382e:	fec79ce3          	bne	a5,a2,ffffffffc0203826 <vmm_init+0x23e>
    }
    assert(sum == 0);
ffffffffc0203832:	2a071a63          	bnez	a4,ffffffffc0203ae6 <vmm_init+0x4fe>

    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
ffffffffc0203836:	4581                	li	a1,0
ffffffffc0203838:	8526                	mv	a0,s1
ffffffffc020383a:	9c8fe0ef          	jal	ra,ffffffffc0201a02 <page_remove>
    return pa2page(PDE_ADDR(pde));
ffffffffc020383e:	609c                	ld	a5,0(s1)
    if (PPN(pa) >= npage) {
ffffffffc0203840:	0000e717          	auipc	a4,0xe
ffffffffc0203844:	c2070713          	addi	a4,a4,-992 # ffffffffc0211460 <npage>
ffffffffc0203848:	6318                	ld	a4,0(a4)
    return pa2page(PDE_ADDR(pde));
ffffffffc020384a:	078a                	slli	a5,a5,0x2
ffffffffc020384c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020384e:	28e7f063          	bleu	a4,a5,ffffffffc0203ace <vmm_init+0x4e6>
    return &pages[PPN(pa) - nbase];
ffffffffc0203852:	00003717          	auipc	a4,0x3
ffffffffc0203856:	8de70713          	addi	a4,a4,-1826 # ffffffffc0206130 <nbase>
ffffffffc020385a:	6318                	ld	a4,0(a4)
ffffffffc020385c:	0000e697          	auipc	a3,0xe
ffffffffc0203860:	c5468693          	addi	a3,a3,-940 # ffffffffc02114b0 <pages>
ffffffffc0203864:	6288                	ld	a0,0(a3)
ffffffffc0203866:	8f99                	sub	a5,a5,a4
ffffffffc0203868:	00379713          	slli	a4,a5,0x3
ffffffffc020386c:	97ba                	add	a5,a5,a4
ffffffffc020386e:	078e                	slli	a5,a5,0x3

    free_page(pde2page(pgdir[0]));
ffffffffc0203870:	953e                	add	a0,a0,a5
ffffffffc0203872:	4585                	li	a1,1
ffffffffc0203874:	ea3fd0ef          	jal	ra,ffffffffc0201716 <free_pages>

    pgdir[0] = 0;
ffffffffc0203878:	0004b023          	sd	zero,0(s1)

    mm->pgdir = NULL;
    mm_destroy(mm);
ffffffffc020387c:	8522                	mv	a0,s0
    mm->pgdir = NULL;
ffffffffc020387e:	00043c23          	sd	zero,24(s0)
    mm_destroy(mm);
ffffffffc0203882:	d31ff0ef          	jal	ra,ffffffffc02035b2 <mm_destroy>

    check_mm_struct = NULL;
    nr_free_pages_store--;	// szx : Sv39第二级页表多占了一个内存页，所以执行此操作
ffffffffc0203886:	19fd                	addi	s3,s3,-1
    check_mm_struct = NULL;
ffffffffc0203888:	0000e797          	auipc	a5,0xe
ffffffffc020388c:	d007b823          	sd	zero,-752(a5) # ffffffffc0211598 <check_mm_struct>

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0203890:	ecdfd0ef          	jal	ra,ffffffffc020175c <nr_free_pages>
ffffffffc0203894:	1aa99d63          	bne	s3,a0,ffffffffc0203a4e <vmm_init+0x466>

    cprintf("check_pgfault() succeeded!\n");
ffffffffc0203898:	00002517          	auipc	a0,0x2
ffffffffc020389c:	5c050513          	addi	a0,a0,1472 # ffffffffc0205e58 <default_pmm_manager+0xe08>
ffffffffc02038a0:	81ffc0ef          	jal	ra,ffffffffc02000be <cprintf>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc02038a4:	eb9fd0ef          	jal	ra,ffffffffc020175c <nr_free_pages>
    nr_free_pages_store--;	// szx : Sv39三级页表多占一个内存页，所以执行此操作
ffffffffc02038a8:	197d                	addi	s2,s2,-1
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc02038aa:	1ea91263          	bne	s2,a0,ffffffffc0203a8e <vmm_init+0x4a6>
}
ffffffffc02038ae:	6406                	ld	s0,64(sp)
ffffffffc02038b0:	60a6                	ld	ra,72(sp)
ffffffffc02038b2:	74e2                	ld	s1,56(sp)
ffffffffc02038b4:	7942                	ld	s2,48(sp)
ffffffffc02038b6:	79a2                	ld	s3,40(sp)
ffffffffc02038b8:	7a02                	ld	s4,32(sp)
ffffffffc02038ba:	6ae2                	ld	s5,24(sp)
ffffffffc02038bc:	6b42                	ld	s6,16(sp)
ffffffffc02038be:	6ba2                	ld	s7,8(sp)
    cprintf("check_vmm() succeeded.\n");
ffffffffc02038c0:	00002517          	auipc	a0,0x2
ffffffffc02038c4:	5b850513          	addi	a0,a0,1464 # ffffffffc0205e78 <default_pmm_manager+0xe28>
}
ffffffffc02038c8:	6161                	addi	sp,sp,80
    cprintf("check_vmm() succeeded.\n");
ffffffffc02038ca:	ff4fc06f          	j	ffffffffc02000be <cprintf>
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc02038ce:	00002697          	auipc	a3,0x2
ffffffffc02038d2:	3d268693          	addi	a3,a3,978 # ffffffffc0205ca0 <default_pmm_manager+0xc50>
ffffffffc02038d6:	00001617          	auipc	a2,0x1
ffffffffc02038da:	3e260613          	addi	a2,a2,994 # ffffffffc0204cb8 <commands+0x870>
ffffffffc02038de:	0dd00593          	li	a1,221
ffffffffc02038e2:	00002517          	auipc	a0,0x2
ffffffffc02038e6:	29650513          	addi	a0,a0,662 # ffffffffc0205b78 <default_pmm_manager+0xb28>
ffffffffc02038ea:	a8bfc0ef          	jal	ra,ffffffffc0200374 <__panic>
        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc02038ee:	00002697          	auipc	a3,0x2
ffffffffc02038f2:	43a68693          	addi	a3,a3,1082 # ffffffffc0205d28 <default_pmm_manager+0xcd8>
ffffffffc02038f6:	00001617          	auipc	a2,0x1
ffffffffc02038fa:	3c260613          	addi	a2,a2,962 # ffffffffc0204cb8 <commands+0x870>
ffffffffc02038fe:	0ed00593          	li	a1,237
ffffffffc0203902:	00002517          	auipc	a0,0x2
ffffffffc0203906:	27650513          	addi	a0,a0,630 # ffffffffc0205b78 <default_pmm_manager+0xb28>
ffffffffc020390a:	a6bfc0ef          	jal	ra,ffffffffc0200374 <__panic>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc020390e:	00002697          	auipc	a3,0x2
ffffffffc0203912:	44a68693          	addi	a3,a3,1098 # ffffffffc0205d58 <default_pmm_manager+0xd08>
ffffffffc0203916:	00001617          	auipc	a2,0x1
ffffffffc020391a:	3a260613          	addi	a2,a2,930 # ffffffffc0204cb8 <commands+0x870>
ffffffffc020391e:	0ee00593          	li	a1,238
ffffffffc0203922:	00002517          	auipc	a0,0x2
ffffffffc0203926:	25650513          	addi	a0,a0,598 # ffffffffc0205b78 <default_pmm_manager+0xb28>
ffffffffc020392a:	a4bfc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(vma != NULL);
ffffffffc020392e:	00002697          	auipc	a3,0x2
ffffffffc0203932:	eba68693          	addi	a3,a3,-326 # ffffffffc02057e8 <default_pmm_manager+0x798>
ffffffffc0203936:	00001617          	auipc	a2,0x1
ffffffffc020393a:	38260613          	addi	a2,a2,898 # ffffffffc0204cb8 <commands+0x870>
ffffffffc020393e:	11100593          	li	a1,273
ffffffffc0203942:	00002517          	auipc	a0,0x2
ffffffffc0203946:	23650513          	addi	a0,a0,566 # ffffffffc0205b78 <default_pmm_manager+0xb28>
ffffffffc020394a:	a2bfc0ef          	jal	ra,ffffffffc0200374 <__panic>
        assert(le != &(mm->mmap_list));
ffffffffc020394e:	00002697          	auipc	a3,0x2
ffffffffc0203952:	33a68693          	addi	a3,a3,826 # ffffffffc0205c88 <default_pmm_manager+0xc38>
ffffffffc0203956:	00001617          	auipc	a2,0x1
ffffffffc020395a:	36260613          	addi	a2,a2,866 # ffffffffc0204cb8 <commands+0x870>
ffffffffc020395e:	0db00593          	li	a1,219
ffffffffc0203962:	00002517          	auipc	a0,0x2
ffffffffc0203966:	21650513          	addi	a0,a0,534 # ffffffffc0205b78 <default_pmm_manager+0xb28>
ffffffffc020396a:	a0bfc0ef          	jal	ra,ffffffffc0200374 <__panic>
        assert(vma4 == NULL);
ffffffffc020396e:	00002697          	auipc	a3,0x2
ffffffffc0203972:	39a68693          	addi	a3,a3,922 # ffffffffc0205d08 <default_pmm_manager+0xcb8>
ffffffffc0203976:	00001617          	auipc	a2,0x1
ffffffffc020397a:	34260613          	addi	a2,a2,834 # ffffffffc0204cb8 <commands+0x870>
ffffffffc020397e:	0e900593          	li	a1,233
ffffffffc0203982:	00002517          	auipc	a0,0x2
ffffffffc0203986:	1f650513          	addi	a0,a0,502 # ffffffffc0205b78 <default_pmm_manager+0xb28>
ffffffffc020398a:	9ebfc0ef          	jal	ra,ffffffffc0200374 <__panic>
        assert(vma3 == NULL);
ffffffffc020398e:	00002697          	auipc	a3,0x2
ffffffffc0203992:	36a68693          	addi	a3,a3,874 # ffffffffc0205cf8 <default_pmm_manager+0xca8>
ffffffffc0203996:	00001617          	auipc	a2,0x1
ffffffffc020399a:	32260613          	addi	a2,a2,802 # ffffffffc0204cb8 <commands+0x870>
ffffffffc020399e:	0e700593          	li	a1,231
ffffffffc02039a2:	00002517          	auipc	a0,0x2
ffffffffc02039a6:	1d650513          	addi	a0,a0,470 # ffffffffc0205b78 <default_pmm_manager+0xb28>
ffffffffc02039aa:	9cbfc0ef          	jal	ra,ffffffffc0200374 <__panic>
        assert(vma2 != NULL);
ffffffffc02039ae:	00002697          	auipc	a3,0x2
ffffffffc02039b2:	33a68693          	addi	a3,a3,826 # ffffffffc0205ce8 <default_pmm_manager+0xc98>
ffffffffc02039b6:	00001617          	auipc	a2,0x1
ffffffffc02039ba:	30260613          	addi	a2,a2,770 # ffffffffc0204cb8 <commands+0x870>
ffffffffc02039be:	0e500593          	li	a1,229
ffffffffc02039c2:	00002517          	auipc	a0,0x2
ffffffffc02039c6:	1b650513          	addi	a0,a0,438 # ffffffffc0205b78 <default_pmm_manager+0xb28>
ffffffffc02039ca:	9abfc0ef          	jal	ra,ffffffffc0200374 <__panic>
        assert(vma1 != NULL);
ffffffffc02039ce:	00002697          	auipc	a3,0x2
ffffffffc02039d2:	30a68693          	addi	a3,a3,778 # ffffffffc0205cd8 <default_pmm_manager+0xc88>
ffffffffc02039d6:	00001617          	auipc	a2,0x1
ffffffffc02039da:	2e260613          	addi	a2,a2,738 # ffffffffc0204cb8 <commands+0x870>
ffffffffc02039de:	0e300593          	li	a1,227
ffffffffc02039e2:	00002517          	auipc	a0,0x2
ffffffffc02039e6:	19650513          	addi	a0,a0,406 # ffffffffc0205b78 <default_pmm_manager+0xb28>
ffffffffc02039ea:	98bfc0ef          	jal	ra,ffffffffc0200374 <__panic>
        assert(vma5 == NULL);
ffffffffc02039ee:	00002697          	auipc	a3,0x2
ffffffffc02039f2:	32a68693          	addi	a3,a3,810 # ffffffffc0205d18 <default_pmm_manager+0xcc8>
ffffffffc02039f6:	00001617          	auipc	a2,0x1
ffffffffc02039fa:	2c260613          	addi	a2,a2,706 # ffffffffc0204cb8 <commands+0x870>
ffffffffc02039fe:	0eb00593          	li	a1,235
ffffffffc0203a02:	00002517          	auipc	a0,0x2
ffffffffc0203a06:	17650513          	addi	a0,a0,374 # ffffffffc0205b78 <default_pmm_manager+0xb28>
ffffffffc0203a0a:	96bfc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(mm != NULL);
ffffffffc0203a0e:	00002697          	auipc	a3,0x2
ffffffffc0203a12:	da268693          	addi	a3,a3,-606 # ffffffffc02057b0 <default_pmm_manager+0x760>
ffffffffc0203a16:	00001617          	auipc	a2,0x1
ffffffffc0203a1a:	2a260613          	addi	a2,a2,674 # ffffffffc0204cb8 <commands+0x870>
ffffffffc0203a1e:	0c700593          	li	a1,199
ffffffffc0203a22:	00002517          	auipc	a0,0x2
ffffffffc0203a26:	15650513          	addi	a0,a0,342 # ffffffffc0205b78 <default_pmm_manager+0xb28>
ffffffffc0203a2a:	94bfc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0203a2e:	00002697          	auipc	a3,0x2
ffffffffc0203a32:	39a68693          	addi	a3,a3,922 # ffffffffc0205dc8 <default_pmm_manager+0xd78>
ffffffffc0203a36:	00001617          	auipc	a2,0x1
ffffffffc0203a3a:	28260613          	addi	a2,a2,642 # ffffffffc0204cb8 <commands+0x870>
ffffffffc0203a3e:	0fb00593          	li	a1,251
ffffffffc0203a42:	00002517          	auipc	a0,0x2
ffffffffc0203a46:	13650513          	addi	a0,a0,310 # ffffffffc0205b78 <default_pmm_manager+0xb28>
ffffffffc0203a4a:	92bfc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0203a4e:	00002697          	auipc	a3,0x2
ffffffffc0203a52:	37a68693          	addi	a3,a3,890 # ffffffffc0205dc8 <default_pmm_manager+0xd78>
ffffffffc0203a56:	00001617          	auipc	a2,0x1
ffffffffc0203a5a:	26260613          	addi	a2,a2,610 # ffffffffc0204cb8 <commands+0x870>
ffffffffc0203a5e:	12e00593          	li	a1,302
ffffffffc0203a62:	00002517          	auipc	a0,0x2
ffffffffc0203a66:	11650513          	addi	a0,a0,278 # ffffffffc0205b78 <default_pmm_manager+0xb28>
ffffffffc0203a6a:	90bfc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(check_mm_struct != NULL);
ffffffffc0203a6e:	00002697          	auipc	a3,0x2
ffffffffc0203a72:	3a268693          	addi	a3,a3,930 # ffffffffc0205e10 <default_pmm_manager+0xdc0>
ffffffffc0203a76:	00001617          	auipc	a2,0x1
ffffffffc0203a7a:	24260613          	addi	a2,a2,578 # ffffffffc0204cb8 <commands+0x870>
ffffffffc0203a7e:	10a00593          	li	a1,266
ffffffffc0203a82:	00002517          	auipc	a0,0x2
ffffffffc0203a86:	0f650513          	addi	a0,a0,246 # ffffffffc0205b78 <default_pmm_manager+0xb28>
ffffffffc0203a8a:	8ebfc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0203a8e:	00002697          	auipc	a3,0x2
ffffffffc0203a92:	33a68693          	addi	a3,a3,826 # ffffffffc0205dc8 <default_pmm_manager+0xd78>
ffffffffc0203a96:	00001617          	auipc	a2,0x1
ffffffffc0203a9a:	22260613          	addi	a2,a2,546 # ffffffffc0204cb8 <commands+0x870>
ffffffffc0203a9e:	0bd00593          	li	a1,189
ffffffffc0203aa2:	00002517          	auipc	a0,0x2
ffffffffc0203aa6:	0d650513          	addi	a0,a0,214 # ffffffffc0205b78 <default_pmm_manager+0xb28>
ffffffffc0203aaa:	8cbfc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(find_vma(mm, addr) == vma);
ffffffffc0203aae:	00002697          	auipc	a3,0x2
ffffffffc0203ab2:	37a68693          	addi	a3,a3,890 # ffffffffc0205e28 <default_pmm_manager+0xdd8>
ffffffffc0203ab6:	00001617          	auipc	a2,0x1
ffffffffc0203aba:	20260613          	addi	a2,a2,514 # ffffffffc0204cb8 <commands+0x870>
ffffffffc0203abe:	11600593          	li	a1,278
ffffffffc0203ac2:	00002517          	auipc	a0,0x2
ffffffffc0203ac6:	0b650513          	addi	a0,a0,182 # ffffffffc0205b78 <default_pmm_manager+0xb28>
ffffffffc0203aca:	8abfc0ef          	jal	ra,ffffffffc0200374 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0203ace:	00001617          	auipc	a2,0x1
ffffffffc0203ad2:	64a60613          	addi	a2,a2,1610 # ffffffffc0205118 <default_pmm_manager+0xc8>
ffffffffc0203ad6:	06500593          	li	a1,101
ffffffffc0203ada:	00001517          	auipc	a0,0x1
ffffffffc0203ade:	65e50513          	addi	a0,a0,1630 # ffffffffc0205138 <default_pmm_manager+0xe8>
ffffffffc0203ae2:	893fc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(sum == 0);
ffffffffc0203ae6:	00002697          	auipc	a3,0x2
ffffffffc0203aea:	36268693          	addi	a3,a3,866 # ffffffffc0205e48 <default_pmm_manager+0xdf8>
ffffffffc0203aee:	00001617          	auipc	a2,0x1
ffffffffc0203af2:	1ca60613          	addi	a2,a2,458 # ffffffffc0204cb8 <commands+0x870>
ffffffffc0203af6:	12000593          	li	a1,288
ffffffffc0203afa:	00002517          	auipc	a0,0x2
ffffffffc0203afe:	07e50513          	addi	a0,a0,126 # ffffffffc0205b78 <default_pmm_manager+0xb28>
ffffffffc0203b02:	873fc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgdir[0] == 0);
ffffffffc0203b06:	00002697          	auipc	a3,0x2
ffffffffc0203b0a:	cd268693          	addi	a3,a3,-814 # ffffffffc02057d8 <default_pmm_manager+0x788>
ffffffffc0203b0e:	00001617          	auipc	a2,0x1
ffffffffc0203b12:	1aa60613          	addi	a2,a2,426 # ffffffffc0204cb8 <commands+0x870>
ffffffffc0203b16:	10d00593          	li	a1,269
ffffffffc0203b1a:	00002517          	auipc	a0,0x2
ffffffffc0203b1e:	05e50513          	addi	a0,a0,94 # ffffffffc0205b78 <default_pmm_manager+0xb28>
ffffffffc0203b22:	853fc0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0203b26 <do_pgfault>:
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc0203b26:	7139                	addi	sp,sp,-64
    int ret = -E_INVAL;
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc0203b28:	85b2                	mv	a1,a2
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc0203b2a:	f822                	sd	s0,48(sp)
ffffffffc0203b2c:	f426                	sd	s1,40(sp)
ffffffffc0203b2e:	fc06                	sd	ra,56(sp)
ffffffffc0203b30:	f04a                	sd	s2,32(sp)
ffffffffc0203b32:	ec4e                	sd	s3,24(sp)
ffffffffc0203b34:	8432                	mv	s0,a2
ffffffffc0203b36:	84aa                	mv	s1,a0
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc0203b38:	96fff0ef          	jal	ra,ffffffffc02034a6 <find_vma>

    pgfault_num++;
ffffffffc0203b3c:	0000e797          	auipc	a5,0xe
ffffffffc0203b40:	93878793          	addi	a5,a5,-1736 # ffffffffc0211474 <pgfault_num>
ffffffffc0203b44:	439c                	lw	a5,0(a5)
ffffffffc0203b46:	2785                	addiw	a5,a5,1
ffffffffc0203b48:	0000e717          	auipc	a4,0xe
ffffffffc0203b4c:	92f72623          	sw	a5,-1748(a4) # ffffffffc0211474 <pgfault_num>
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr) {
ffffffffc0203b50:	c54d                	beqz	a0,ffffffffc0203bfa <do_pgfault+0xd4>
ffffffffc0203b52:	651c                	ld	a5,8(a0)
ffffffffc0203b54:	0af46363          	bltu	s0,a5,ffffffffc0203bfa <do_pgfault+0xd4>
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
    if (vma->vm_flags & VM_WRITE) {
ffffffffc0203b58:	6d1c                	ld	a5,24(a0)
    uint32_t perm = PTE_U;
ffffffffc0203b5a:	49c1                	li	s3,16
    if (vma->vm_flags & VM_WRITE) {
ffffffffc0203b5c:	8b89                	andi	a5,a5,2
ffffffffc0203b5e:	efb9                	bnez	a5,ffffffffc0203bbc <do_pgfault+0x96>
        perm |= (PTE_R | PTE_W);
    }
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0203b60:	767d                	lui	a2,0xfffff
    *   mm->pgdir : the PDT of these vma
    *
    */


    ptep = get_pte(mm->pgdir, addr, 1);  //(1) try to find a pte, if pte's
ffffffffc0203b62:	6c88                	ld	a0,24(s1)
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0203b64:	8c71                	and	s0,s0,a2
    ptep = get_pte(mm->pgdir, addr, 1);  //(1) try to find a pte, if pte's
ffffffffc0203b66:	85a2                	mv	a1,s0
ffffffffc0203b68:	4605                	li	a2,1
ffffffffc0203b6a:	c33fd0ef          	jal	ra,ffffffffc020179c <get_pte>
                                         //PT(Page Table) isn't existed, then
                                         //create a PT.
    if (*ptep == 0) {
ffffffffc0203b6e:	610c                	ld	a1,0(a0)
ffffffffc0203b70:	c5b5                	beqz	a1,ffffffffc0203bdc <do_pgfault+0xb6>
        *    swap_in(mm, addr, &page) : 分配一个内存页，然后根据
        *    PTE中的swap条目的addr，找到磁盘页的地址，将磁盘页的内容读入这个内存页
        *    page_insert ： 建立一个Page的phy addr与线性addr la的映射
        *    swap_map_swappable ： 设置页面可交换
        */
        if (swap_init_ok) {
ffffffffc0203b72:	0000e797          	auipc	a5,0xe
ffffffffc0203b76:	8fe78793          	addi	a5,a5,-1794 # ffffffffc0211470 <swap_init_ok>
ffffffffc0203b7a:	439c                	lw	a5,0(a5)
ffffffffc0203b7c:	2781                	sext.w	a5,a5
ffffffffc0203b7e:	c7d9                	beqz	a5,ffffffffc0203c0c <do_pgfault+0xe6>
            //map of phy addr <--->
            //logical addr
            //(3) make the page swappable.

            // (1) 根据 mm 和 addr，尝试将正确磁盘页的内容加载到由页面管理的内存中。
            if ((ret = swap_in(mm, addr, &page)) != 0) {
ffffffffc0203b80:	0030                	addi	a2,sp,8
ffffffffc0203b82:	85a2                	mv	a1,s0
ffffffffc0203b84:	8526                	mv	a0,s1
            struct Page *page = NULL;
ffffffffc0203b86:	e402                	sd	zero,8(sp)
            if ((ret = swap_in(mm, addr, &page)) != 0) {
ffffffffc0203b88:	c88ff0ef          	jal	ra,ffffffffc0203010 <swap_in>
ffffffffc0203b8c:	892a                	mv	s2,a0
ffffffffc0203b8e:	e90d                	bnez	a0,ffffffffc0203bc0 <do_pgfault+0x9a>
                cprintf("swap_in in do_pgfault failed\n");
                goto failed;
            }  
            // (2) 根据 mm、addr 和页面设置物理地址 <--> 逻辑地址的映射  
            // 使用page_insert函数将页面映射到mm->pgdir中
            page_insert(mm->pgdir, page, addr, perm);
ffffffffc0203b90:	65a2                	ld	a1,8(sp)
ffffffffc0203b92:	6c88                	ld	a0,24(s1)
ffffffffc0203b94:	86ce                	mv	a3,s3
ffffffffc0203b96:	8622                	mv	a2,s0
ffffffffc0203b98:	eddfd0ef          	jal	ra,ffffffffc0201a74 <page_insert>
            // (3) 使页面可交换
            swap_map_swappable(mm, addr, page, 1);
ffffffffc0203b9c:	6622                	ld	a2,8(sp)
ffffffffc0203b9e:	4685                	li	a3,1
ffffffffc0203ba0:	85a2                	mv	a1,s0
ffffffffc0203ba2:	8526                	mv	a0,s1
ffffffffc0203ba4:	b48ff0ef          	jal	ra,ffffffffc0202eec <swap_map_swappable>
            // 设置页面的pra_vaddr属性为addr，记录页面所属的虚拟地址
            page->pra_vaddr = addr;
ffffffffc0203ba8:	67a2                	ld	a5,8(sp)
ffffffffc0203baa:	e3a0                	sd	s0,64(a5)
   }

   ret = 0;
failed:
    return ret;
}
ffffffffc0203bac:	70e2                	ld	ra,56(sp)
ffffffffc0203bae:	7442                	ld	s0,48(sp)
ffffffffc0203bb0:	854a                	mv	a0,s2
ffffffffc0203bb2:	74a2                	ld	s1,40(sp)
ffffffffc0203bb4:	7902                	ld	s2,32(sp)
ffffffffc0203bb6:	69e2                	ld	s3,24(sp)
ffffffffc0203bb8:	6121                	addi	sp,sp,64
ffffffffc0203bba:	8082                	ret
        perm |= (PTE_R | PTE_W);
ffffffffc0203bbc:	49d9                	li	s3,22
ffffffffc0203bbe:	b74d                	j	ffffffffc0203b60 <do_pgfault+0x3a>
                cprintf("swap_in in do_pgfault failed\n");
ffffffffc0203bc0:	00002517          	auipc	a0,0x2
ffffffffc0203bc4:	02050513          	addi	a0,a0,32 # ffffffffc0205be0 <default_pmm_manager+0xb90>
ffffffffc0203bc8:	cf6fc0ef          	jal	ra,ffffffffc02000be <cprintf>
}
ffffffffc0203bcc:	70e2                	ld	ra,56(sp)
ffffffffc0203bce:	7442                	ld	s0,48(sp)
ffffffffc0203bd0:	854a                	mv	a0,s2
ffffffffc0203bd2:	74a2                	ld	s1,40(sp)
ffffffffc0203bd4:	7902                	ld	s2,32(sp)
ffffffffc0203bd6:	69e2                	ld	s3,24(sp)
ffffffffc0203bd8:	6121                	addi	sp,sp,64
ffffffffc0203bda:	8082                	ret
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0203bdc:	6c88                	ld	a0,24(s1)
ffffffffc0203bde:	864e                	mv	a2,s3
ffffffffc0203be0:	85a2                	mv	a1,s0
ffffffffc0203be2:	a47fe0ef          	jal	ra,ffffffffc0202628 <pgdir_alloc_page>
   ret = 0;
ffffffffc0203be6:	4901                	li	s2,0
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0203be8:	f171                	bnez	a0,ffffffffc0203bac <do_pgfault+0x86>
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
ffffffffc0203bea:	00002517          	auipc	a0,0x2
ffffffffc0203bee:	fce50513          	addi	a0,a0,-50 # ffffffffc0205bb8 <default_pmm_manager+0xb68>
ffffffffc0203bf2:	cccfc0ef          	jal	ra,ffffffffc02000be <cprintf>
    ret = -E_NO_MEM;
ffffffffc0203bf6:	5971                	li	s2,-4
            goto failed;
ffffffffc0203bf8:	bf55                	j	ffffffffc0203bac <do_pgfault+0x86>
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
ffffffffc0203bfa:	85a2                	mv	a1,s0
ffffffffc0203bfc:	00002517          	auipc	a0,0x2
ffffffffc0203c00:	f8c50513          	addi	a0,a0,-116 # ffffffffc0205b88 <default_pmm_manager+0xb38>
ffffffffc0203c04:	cbafc0ef          	jal	ra,ffffffffc02000be <cprintf>
    int ret = -E_INVAL;
ffffffffc0203c08:	5975                	li	s2,-3
        goto failed;
ffffffffc0203c0a:	b74d                	j	ffffffffc0203bac <do_pgfault+0x86>
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
ffffffffc0203c0c:	00002517          	auipc	a0,0x2
ffffffffc0203c10:	ff450513          	addi	a0,a0,-12 # ffffffffc0205c00 <default_pmm_manager+0xbb0>
ffffffffc0203c14:	caafc0ef          	jal	ra,ffffffffc02000be <cprintf>
    ret = -E_NO_MEM;
ffffffffc0203c18:	5971                	li	s2,-4
            goto failed;
ffffffffc0203c1a:	bf49                	j	ffffffffc0203bac <do_pgfault+0x86>

ffffffffc0203c1c <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {
ffffffffc0203c1c:	1141                	addi	sp,sp,-16
    static_assert((PGSIZE % SECTSIZE) == 0);
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0203c1e:	4505                	li	a0,1
swapfs_init(void) {
ffffffffc0203c20:	e406                	sd	ra,8(sp)
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0203c22:	87dfc0ef          	jal	ra,ffffffffc020049e <ide_device_valid>
ffffffffc0203c26:	cd01                	beqz	a0,ffffffffc0203c3e <swapfs_init+0x22>
        panic("swap fs isn't available.\n");
    }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0203c28:	4505                	li	a0,1
ffffffffc0203c2a:	87bfc0ef          	jal	ra,ffffffffc02004a4 <ide_device_size>
}
ffffffffc0203c2e:	60a2                	ld	ra,8(sp)
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0203c30:	810d                	srli	a0,a0,0x3
ffffffffc0203c32:	0000e797          	auipc	a5,0xe
ffffffffc0203c36:	90a7b723          	sd	a0,-1778(a5) # ffffffffc0211540 <max_swap_offset>
}
ffffffffc0203c3a:	0141                	addi	sp,sp,16
ffffffffc0203c3c:	8082                	ret
        panic("swap fs isn't available.\n");
ffffffffc0203c3e:	00002617          	auipc	a2,0x2
ffffffffc0203c42:	25260613          	addi	a2,a2,594 # ffffffffc0205e90 <default_pmm_manager+0xe40>
ffffffffc0203c46:	45b5                	li	a1,13
ffffffffc0203c48:	00002517          	auipc	a0,0x2
ffffffffc0203c4c:	26850513          	addi	a0,a0,616 # ffffffffc0205eb0 <default_pmm_manager+0xe60>
ffffffffc0203c50:	f24fc0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0203c54 <swapfs_read>:

int
swapfs_read(swap_entry_t entry, struct Page *page) {
ffffffffc0203c54:	1141                	addi	sp,sp,-16
ffffffffc0203c56:	e406                	sd	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203c58:	00855793          	srli	a5,a0,0x8
ffffffffc0203c5c:	c7b5                	beqz	a5,ffffffffc0203cc8 <swapfs_read+0x74>
ffffffffc0203c5e:	0000e717          	auipc	a4,0xe
ffffffffc0203c62:	8e270713          	addi	a4,a4,-1822 # ffffffffc0211540 <max_swap_offset>
ffffffffc0203c66:	6318                	ld	a4,0(a4)
ffffffffc0203c68:	06e7f063          	bleu	a4,a5,ffffffffc0203cc8 <swapfs_read+0x74>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203c6c:	0000e717          	auipc	a4,0xe
ffffffffc0203c70:	84470713          	addi	a4,a4,-1980 # ffffffffc02114b0 <pages>
ffffffffc0203c74:	6310                	ld	a2,0(a4)
ffffffffc0203c76:	00001717          	auipc	a4,0x1
ffffffffc0203c7a:	02a70713          	addi	a4,a4,42 # ffffffffc0204ca0 <commands+0x858>
ffffffffc0203c7e:	00002697          	auipc	a3,0x2
ffffffffc0203c82:	4b268693          	addi	a3,a3,1202 # ffffffffc0206130 <nbase>
ffffffffc0203c86:	40c58633          	sub	a2,a1,a2
ffffffffc0203c8a:	630c                	ld	a1,0(a4)
ffffffffc0203c8c:	860d                	srai	a2,a2,0x3
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203c8e:	0000d717          	auipc	a4,0xd
ffffffffc0203c92:	7d270713          	addi	a4,a4,2002 # ffffffffc0211460 <npage>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203c96:	02b60633          	mul	a2,a2,a1
ffffffffc0203c9a:	0037959b          	slliw	a1,a5,0x3
ffffffffc0203c9e:	629c                	ld	a5,0(a3)
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203ca0:	6318                	ld	a4,0(a4)
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203ca2:	963e                	add	a2,a2,a5
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203ca4:	57fd                	li	a5,-1
ffffffffc0203ca6:	83b1                	srli	a5,a5,0xc
ffffffffc0203ca8:	8ff1                	and	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0203caa:	0632                	slli	a2,a2,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203cac:	02e7fa63          	bleu	a4,a5,ffffffffc0203ce0 <swapfs_read+0x8c>
ffffffffc0203cb0:	0000d797          	auipc	a5,0xd
ffffffffc0203cb4:	7f078793          	addi	a5,a5,2032 # ffffffffc02114a0 <va_pa_offset>
ffffffffc0203cb8:	639c                	ld	a5,0(a5)
}
ffffffffc0203cba:	60a2                	ld	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203cbc:	46a1                	li	a3,8
ffffffffc0203cbe:	963e                	add	a2,a2,a5
ffffffffc0203cc0:	4505                	li	a0,1
}
ffffffffc0203cc2:	0141                	addi	sp,sp,16
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203cc4:	fe6fc06f          	j	ffffffffc02004aa <ide_read_secs>
ffffffffc0203cc8:	86aa                	mv	a3,a0
ffffffffc0203cca:	00002617          	auipc	a2,0x2
ffffffffc0203cce:	1fe60613          	addi	a2,a2,510 # ffffffffc0205ec8 <default_pmm_manager+0xe78>
ffffffffc0203cd2:	45d1                	li	a1,20
ffffffffc0203cd4:	00002517          	auipc	a0,0x2
ffffffffc0203cd8:	1dc50513          	addi	a0,a0,476 # ffffffffc0205eb0 <default_pmm_manager+0xe60>
ffffffffc0203cdc:	e98fc0ef          	jal	ra,ffffffffc0200374 <__panic>
ffffffffc0203ce0:	86b2                	mv	a3,a2
ffffffffc0203ce2:	06a00593          	li	a1,106
ffffffffc0203ce6:	00001617          	auipc	a2,0x1
ffffffffc0203cea:	3ba60613          	addi	a2,a2,954 # ffffffffc02050a0 <default_pmm_manager+0x50>
ffffffffc0203cee:	00001517          	auipc	a0,0x1
ffffffffc0203cf2:	44a50513          	addi	a0,a0,1098 # ffffffffc0205138 <default_pmm_manager+0xe8>
ffffffffc0203cf6:	e7efc0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0203cfa <swapfs_write>:

int
swapfs_write(swap_entry_t entry, struct Page *page) {
ffffffffc0203cfa:	1141                	addi	sp,sp,-16
ffffffffc0203cfc:	e406                	sd	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203cfe:	00855793          	srli	a5,a0,0x8
ffffffffc0203d02:	c7b5                	beqz	a5,ffffffffc0203d6e <swapfs_write+0x74>
ffffffffc0203d04:	0000e717          	auipc	a4,0xe
ffffffffc0203d08:	83c70713          	addi	a4,a4,-1988 # ffffffffc0211540 <max_swap_offset>
ffffffffc0203d0c:	6318                	ld	a4,0(a4)
ffffffffc0203d0e:	06e7f063          	bleu	a4,a5,ffffffffc0203d6e <swapfs_write+0x74>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203d12:	0000d717          	auipc	a4,0xd
ffffffffc0203d16:	79e70713          	addi	a4,a4,1950 # ffffffffc02114b0 <pages>
ffffffffc0203d1a:	6310                	ld	a2,0(a4)
ffffffffc0203d1c:	00001717          	auipc	a4,0x1
ffffffffc0203d20:	f8470713          	addi	a4,a4,-124 # ffffffffc0204ca0 <commands+0x858>
ffffffffc0203d24:	00002697          	auipc	a3,0x2
ffffffffc0203d28:	40c68693          	addi	a3,a3,1036 # ffffffffc0206130 <nbase>
ffffffffc0203d2c:	40c58633          	sub	a2,a1,a2
ffffffffc0203d30:	630c                	ld	a1,0(a4)
ffffffffc0203d32:	860d                	srai	a2,a2,0x3
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203d34:	0000d717          	auipc	a4,0xd
ffffffffc0203d38:	72c70713          	addi	a4,a4,1836 # ffffffffc0211460 <npage>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203d3c:	02b60633          	mul	a2,a2,a1
ffffffffc0203d40:	0037959b          	slliw	a1,a5,0x3
ffffffffc0203d44:	629c                	ld	a5,0(a3)
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203d46:	6318                	ld	a4,0(a4)
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203d48:	963e                	add	a2,a2,a5
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203d4a:	57fd                	li	a5,-1
ffffffffc0203d4c:	83b1                	srli	a5,a5,0xc
ffffffffc0203d4e:	8ff1                	and	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0203d50:	0632                	slli	a2,a2,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203d52:	02e7fa63          	bleu	a4,a5,ffffffffc0203d86 <swapfs_write+0x8c>
ffffffffc0203d56:	0000d797          	auipc	a5,0xd
ffffffffc0203d5a:	74a78793          	addi	a5,a5,1866 # ffffffffc02114a0 <va_pa_offset>
ffffffffc0203d5e:	639c                	ld	a5,0(a5)
}
ffffffffc0203d60:	60a2                	ld	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203d62:	46a1                	li	a3,8
ffffffffc0203d64:	963e                	add	a2,a2,a5
ffffffffc0203d66:	4505                	li	a0,1
}
ffffffffc0203d68:	0141                	addi	sp,sp,16
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203d6a:	f64fc06f          	j	ffffffffc02004ce <ide_write_secs>
ffffffffc0203d6e:	86aa                	mv	a3,a0
ffffffffc0203d70:	00002617          	auipc	a2,0x2
ffffffffc0203d74:	15860613          	addi	a2,a2,344 # ffffffffc0205ec8 <default_pmm_manager+0xe78>
ffffffffc0203d78:	45e5                	li	a1,25
ffffffffc0203d7a:	00002517          	auipc	a0,0x2
ffffffffc0203d7e:	13650513          	addi	a0,a0,310 # ffffffffc0205eb0 <default_pmm_manager+0xe60>
ffffffffc0203d82:	df2fc0ef          	jal	ra,ffffffffc0200374 <__panic>
ffffffffc0203d86:	86b2                	mv	a3,a2
ffffffffc0203d88:	06a00593          	li	a1,106
ffffffffc0203d8c:	00001617          	auipc	a2,0x1
ffffffffc0203d90:	31460613          	addi	a2,a2,788 # ffffffffc02050a0 <default_pmm_manager+0x50>
ffffffffc0203d94:	00001517          	auipc	a0,0x1
ffffffffc0203d98:	3a450513          	addi	a0,a0,932 # ffffffffc0205138 <default_pmm_manager+0xe8>
ffffffffc0203d9c:	dd8fc0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0203da0 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0203da0:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0203da4:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0203da6:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0203daa:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0203dac:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0203db0:	f022                	sd	s0,32(sp)
ffffffffc0203db2:	ec26                	sd	s1,24(sp)
ffffffffc0203db4:	e84a                	sd	s2,16(sp)
ffffffffc0203db6:	f406                	sd	ra,40(sp)
ffffffffc0203db8:	e44e                	sd	s3,8(sp)
ffffffffc0203dba:	84aa                	mv	s1,a0
ffffffffc0203dbc:	892e                	mv	s2,a1
ffffffffc0203dbe:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0203dc2:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
ffffffffc0203dc4:	03067e63          	bleu	a6,a2,ffffffffc0203e00 <printnum+0x60>
ffffffffc0203dc8:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0203dca:	00805763          	blez	s0,ffffffffc0203dd8 <printnum+0x38>
ffffffffc0203dce:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0203dd0:	85ca                	mv	a1,s2
ffffffffc0203dd2:	854e                	mv	a0,s3
ffffffffc0203dd4:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0203dd6:	fc65                	bnez	s0,ffffffffc0203dce <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0203dd8:	1a02                	slli	s4,s4,0x20
ffffffffc0203dda:	020a5a13          	srli	s4,s4,0x20
ffffffffc0203dde:	00002797          	auipc	a5,0x2
ffffffffc0203de2:	29a78793          	addi	a5,a5,666 # ffffffffc0206078 <error_string+0x38>
ffffffffc0203de6:	9a3e                	add	s4,s4,a5
}
ffffffffc0203de8:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0203dea:	000a4503          	lbu	a0,0(s4)
}
ffffffffc0203dee:	70a2                	ld	ra,40(sp)
ffffffffc0203df0:	69a2                	ld	s3,8(sp)
ffffffffc0203df2:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0203df4:	85ca                	mv	a1,s2
ffffffffc0203df6:	8326                	mv	t1,s1
}
ffffffffc0203df8:	6942                	ld	s2,16(sp)
ffffffffc0203dfa:	64e2                	ld	s1,24(sp)
ffffffffc0203dfc:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0203dfe:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0203e00:	03065633          	divu	a2,a2,a6
ffffffffc0203e04:	8722                	mv	a4,s0
ffffffffc0203e06:	f9bff0ef          	jal	ra,ffffffffc0203da0 <printnum>
ffffffffc0203e0a:	b7f9                	j	ffffffffc0203dd8 <printnum+0x38>

ffffffffc0203e0c <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc0203e0c:	7119                	addi	sp,sp,-128
ffffffffc0203e0e:	f4a6                	sd	s1,104(sp)
ffffffffc0203e10:	f0ca                	sd	s2,96(sp)
ffffffffc0203e12:	e8d2                	sd	s4,80(sp)
ffffffffc0203e14:	e4d6                	sd	s5,72(sp)
ffffffffc0203e16:	e0da                	sd	s6,64(sp)
ffffffffc0203e18:	fc5e                	sd	s7,56(sp)
ffffffffc0203e1a:	f862                	sd	s8,48(sp)
ffffffffc0203e1c:	f06a                	sd	s10,32(sp)
ffffffffc0203e1e:	fc86                	sd	ra,120(sp)
ffffffffc0203e20:	f8a2                	sd	s0,112(sp)
ffffffffc0203e22:	ecce                	sd	s3,88(sp)
ffffffffc0203e24:	f466                	sd	s9,40(sp)
ffffffffc0203e26:	ec6e                	sd	s11,24(sp)
ffffffffc0203e28:	892a                	mv	s2,a0
ffffffffc0203e2a:	84ae                	mv	s1,a1
ffffffffc0203e2c:	8d32                	mv	s10,a2
ffffffffc0203e2e:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc0203e30:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203e32:	00002a17          	auipc	s4,0x2
ffffffffc0203e36:	0b6a0a13          	addi	s4,s4,182 # ffffffffc0205ee8 <default_pmm_manager+0xe98>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0203e3a:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0203e3e:	00002c17          	auipc	s8,0x2
ffffffffc0203e42:	202c0c13          	addi	s8,s8,514 # ffffffffc0206040 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0203e46:	000d4503          	lbu	a0,0(s10)
ffffffffc0203e4a:	02500793          	li	a5,37
ffffffffc0203e4e:	001d0413          	addi	s0,s10,1
ffffffffc0203e52:	00f50e63          	beq	a0,a5,ffffffffc0203e6e <vprintfmt+0x62>
            if (ch == '\0') {
ffffffffc0203e56:	c521                	beqz	a0,ffffffffc0203e9e <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0203e58:	02500993          	li	s3,37
ffffffffc0203e5c:	a011                	j	ffffffffc0203e60 <vprintfmt+0x54>
            if (ch == '\0') {
ffffffffc0203e5e:	c121                	beqz	a0,ffffffffc0203e9e <vprintfmt+0x92>
            putch(ch, putdat);
ffffffffc0203e60:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0203e62:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc0203e64:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0203e66:	fff44503          	lbu	a0,-1(s0)
ffffffffc0203e6a:	ff351ae3          	bne	a0,s3,ffffffffc0203e5e <vprintfmt+0x52>
ffffffffc0203e6e:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc0203e72:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc0203e76:	4981                	li	s3,0
ffffffffc0203e78:	4801                	li	a6,0
        width = precision = -1;
ffffffffc0203e7a:	5cfd                	li	s9,-1
ffffffffc0203e7c:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203e7e:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
ffffffffc0203e82:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203e84:	fdd6069b          	addiw	a3,a2,-35
ffffffffc0203e88:	0ff6f693          	andi	a3,a3,255
ffffffffc0203e8c:	00140d13          	addi	s10,s0,1
ffffffffc0203e90:	20d5e563          	bltu	a1,a3,ffffffffc020409a <vprintfmt+0x28e>
ffffffffc0203e94:	068a                	slli	a3,a3,0x2
ffffffffc0203e96:	96d2                	add	a3,a3,s4
ffffffffc0203e98:	4294                	lw	a3,0(a3)
ffffffffc0203e9a:	96d2                	add	a3,a3,s4
ffffffffc0203e9c:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0203e9e:	70e6                	ld	ra,120(sp)
ffffffffc0203ea0:	7446                	ld	s0,112(sp)
ffffffffc0203ea2:	74a6                	ld	s1,104(sp)
ffffffffc0203ea4:	7906                	ld	s2,96(sp)
ffffffffc0203ea6:	69e6                	ld	s3,88(sp)
ffffffffc0203ea8:	6a46                	ld	s4,80(sp)
ffffffffc0203eaa:	6aa6                	ld	s5,72(sp)
ffffffffc0203eac:	6b06                	ld	s6,64(sp)
ffffffffc0203eae:	7be2                	ld	s7,56(sp)
ffffffffc0203eb0:	7c42                	ld	s8,48(sp)
ffffffffc0203eb2:	7ca2                	ld	s9,40(sp)
ffffffffc0203eb4:	7d02                	ld	s10,32(sp)
ffffffffc0203eb6:	6de2                	ld	s11,24(sp)
ffffffffc0203eb8:	6109                	addi	sp,sp,128
ffffffffc0203eba:	8082                	ret
    if (lflag >= 2) {
ffffffffc0203ebc:	4705                	li	a4,1
ffffffffc0203ebe:	008a8593          	addi	a1,s5,8
ffffffffc0203ec2:	01074463          	blt	a4,a6,ffffffffc0203eca <vprintfmt+0xbe>
    else if (lflag) {
ffffffffc0203ec6:	26080363          	beqz	a6,ffffffffc020412c <vprintfmt+0x320>
        return va_arg(*ap, unsigned long);
ffffffffc0203eca:	000ab603          	ld	a2,0(s5)
ffffffffc0203ece:	46c1                	li	a3,16
ffffffffc0203ed0:	8aae                	mv	s5,a1
ffffffffc0203ed2:	a06d                	j	ffffffffc0203f7c <vprintfmt+0x170>
            goto reswitch;
ffffffffc0203ed4:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc0203ed8:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203eda:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0203edc:	b765                	j	ffffffffc0203e84 <vprintfmt+0x78>
            putch(va_arg(ap, int), putdat);
ffffffffc0203ede:	000aa503          	lw	a0,0(s5)
ffffffffc0203ee2:	85a6                	mv	a1,s1
ffffffffc0203ee4:	0aa1                	addi	s5,s5,8
ffffffffc0203ee6:	9902                	jalr	s2
            break;
ffffffffc0203ee8:	bfb9                	j	ffffffffc0203e46 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0203eea:	4705                	li	a4,1
ffffffffc0203eec:	008a8993          	addi	s3,s5,8
ffffffffc0203ef0:	01074463          	blt	a4,a6,ffffffffc0203ef8 <vprintfmt+0xec>
    else if (lflag) {
ffffffffc0203ef4:	22080463          	beqz	a6,ffffffffc020411c <vprintfmt+0x310>
        return va_arg(*ap, long);
ffffffffc0203ef8:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
ffffffffc0203efc:	24044463          	bltz	s0,ffffffffc0204144 <vprintfmt+0x338>
            num = getint(&ap, lflag);
ffffffffc0203f00:	8622                	mv	a2,s0
ffffffffc0203f02:	8ace                	mv	s5,s3
ffffffffc0203f04:	46a9                	li	a3,10
ffffffffc0203f06:	a89d                	j	ffffffffc0203f7c <vprintfmt+0x170>
            err = va_arg(ap, int);
ffffffffc0203f08:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0203f0c:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc0203f0e:	0aa1                	addi	s5,s5,8
            if (err < 0) {
ffffffffc0203f10:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc0203f14:	8fb5                	xor	a5,a5,a3
ffffffffc0203f16:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0203f1a:	1ad74363          	blt	a4,a3,ffffffffc02040c0 <vprintfmt+0x2b4>
ffffffffc0203f1e:	00369793          	slli	a5,a3,0x3
ffffffffc0203f22:	97e2                	add	a5,a5,s8
ffffffffc0203f24:	639c                	ld	a5,0(a5)
ffffffffc0203f26:	18078d63          	beqz	a5,ffffffffc02040c0 <vprintfmt+0x2b4>
                printfmt(putch, putdat, "%s", p);
ffffffffc0203f2a:	86be                	mv	a3,a5
ffffffffc0203f2c:	00002617          	auipc	a2,0x2
ffffffffc0203f30:	1fc60613          	addi	a2,a2,508 # ffffffffc0206128 <error_string+0xe8>
ffffffffc0203f34:	85a6                	mv	a1,s1
ffffffffc0203f36:	854a                	mv	a0,s2
ffffffffc0203f38:	240000ef          	jal	ra,ffffffffc0204178 <printfmt>
ffffffffc0203f3c:	b729                	j	ffffffffc0203e46 <vprintfmt+0x3a>
            lflag ++;
ffffffffc0203f3e:	00144603          	lbu	a2,1(s0)
ffffffffc0203f42:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203f44:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0203f46:	bf3d                	j	ffffffffc0203e84 <vprintfmt+0x78>
    if (lflag >= 2) {
ffffffffc0203f48:	4705                	li	a4,1
ffffffffc0203f4a:	008a8593          	addi	a1,s5,8
ffffffffc0203f4e:	01074463          	blt	a4,a6,ffffffffc0203f56 <vprintfmt+0x14a>
    else if (lflag) {
ffffffffc0203f52:	1e080263          	beqz	a6,ffffffffc0204136 <vprintfmt+0x32a>
        return va_arg(*ap, unsigned long);
ffffffffc0203f56:	000ab603          	ld	a2,0(s5)
ffffffffc0203f5a:	46a1                	li	a3,8
ffffffffc0203f5c:	8aae                	mv	s5,a1
ffffffffc0203f5e:	a839                	j	ffffffffc0203f7c <vprintfmt+0x170>
            putch('0', putdat);
ffffffffc0203f60:	03000513          	li	a0,48
ffffffffc0203f64:	85a6                	mv	a1,s1
ffffffffc0203f66:	e03e                	sd	a5,0(sp)
ffffffffc0203f68:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc0203f6a:	85a6                	mv	a1,s1
ffffffffc0203f6c:	07800513          	li	a0,120
ffffffffc0203f70:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0203f72:	0aa1                	addi	s5,s5,8
ffffffffc0203f74:	ff8ab603          	ld	a2,-8(s5)
            goto number;
ffffffffc0203f78:	6782                	ld	a5,0(sp)
ffffffffc0203f7a:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
ffffffffc0203f7c:	876e                	mv	a4,s11
ffffffffc0203f7e:	85a6                	mv	a1,s1
ffffffffc0203f80:	854a                	mv	a0,s2
ffffffffc0203f82:	e1fff0ef          	jal	ra,ffffffffc0203da0 <printnum>
            break;
ffffffffc0203f86:	b5c1                	j	ffffffffc0203e46 <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0203f88:	000ab603          	ld	a2,0(s5)
ffffffffc0203f8c:	0aa1                	addi	s5,s5,8
ffffffffc0203f8e:	1c060663          	beqz	a2,ffffffffc020415a <vprintfmt+0x34e>
            if (width > 0 && padc != '-') {
ffffffffc0203f92:	00160413          	addi	s0,a2,1
ffffffffc0203f96:	17b05c63          	blez	s11,ffffffffc020410e <vprintfmt+0x302>
ffffffffc0203f9a:	02d00593          	li	a1,45
ffffffffc0203f9e:	14b79263          	bne	a5,a1,ffffffffc02040e2 <vprintfmt+0x2d6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0203fa2:	00064783          	lbu	a5,0(a2)
ffffffffc0203fa6:	0007851b          	sext.w	a0,a5
ffffffffc0203faa:	c905                	beqz	a0,ffffffffc0203fda <vprintfmt+0x1ce>
ffffffffc0203fac:	000cc563          	bltz	s9,ffffffffc0203fb6 <vprintfmt+0x1aa>
ffffffffc0203fb0:	3cfd                	addiw	s9,s9,-1
ffffffffc0203fb2:	036c8263          	beq	s9,s6,ffffffffc0203fd6 <vprintfmt+0x1ca>
                    putch('?', putdat);
ffffffffc0203fb6:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0203fb8:	18098463          	beqz	s3,ffffffffc0204140 <vprintfmt+0x334>
ffffffffc0203fbc:	3781                	addiw	a5,a5,-32
ffffffffc0203fbe:	18fbf163          	bleu	a5,s7,ffffffffc0204140 <vprintfmt+0x334>
                    putch('?', putdat);
ffffffffc0203fc2:	03f00513          	li	a0,63
ffffffffc0203fc6:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0203fc8:	0405                	addi	s0,s0,1
ffffffffc0203fca:	fff44783          	lbu	a5,-1(s0)
ffffffffc0203fce:	3dfd                	addiw	s11,s11,-1
ffffffffc0203fd0:	0007851b          	sext.w	a0,a5
ffffffffc0203fd4:	fd61                	bnez	a0,ffffffffc0203fac <vprintfmt+0x1a0>
            for (; width > 0; width --) {
ffffffffc0203fd6:	e7b058e3          	blez	s11,ffffffffc0203e46 <vprintfmt+0x3a>
ffffffffc0203fda:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0203fdc:	85a6                	mv	a1,s1
ffffffffc0203fde:	02000513          	li	a0,32
ffffffffc0203fe2:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0203fe4:	e60d81e3          	beqz	s11,ffffffffc0203e46 <vprintfmt+0x3a>
ffffffffc0203fe8:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0203fea:	85a6                	mv	a1,s1
ffffffffc0203fec:	02000513          	li	a0,32
ffffffffc0203ff0:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0203ff2:	fe0d94e3          	bnez	s11,ffffffffc0203fda <vprintfmt+0x1ce>
ffffffffc0203ff6:	bd81                	j	ffffffffc0203e46 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0203ff8:	4705                	li	a4,1
ffffffffc0203ffa:	008a8593          	addi	a1,s5,8
ffffffffc0203ffe:	01074463          	blt	a4,a6,ffffffffc0204006 <vprintfmt+0x1fa>
    else if (lflag) {
ffffffffc0204002:	12080063          	beqz	a6,ffffffffc0204122 <vprintfmt+0x316>
        return va_arg(*ap, unsigned long);
ffffffffc0204006:	000ab603          	ld	a2,0(s5)
ffffffffc020400a:	46a9                	li	a3,10
ffffffffc020400c:	8aae                	mv	s5,a1
ffffffffc020400e:	b7bd                	j	ffffffffc0203f7c <vprintfmt+0x170>
ffffffffc0204010:	00144603          	lbu	a2,1(s0)
            padc = '-';
ffffffffc0204014:	02d00793          	li	a5,45
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204018:	846a                	mv	s0,s10
ffffffffc020401a:	b5ad                	j	ffffffffc0203e84 <vprintfmt+0x78>
            putch(ch, putdat);
ffffffffc020401c:	85a6                	mv	a1,s1
ffffffffc020401e:	02500513          	li	a0,37
ffffffffc0204022:	9902                	jalr	s2
            break;
ffffffffc0204024:	b50d                	j	ffffffffc0203e46 <vprintfmt+0x3a>
            precision = va_arg(ap, int);
ffffffffc0204026:	000aac83          	lw	s9,0(s5)
            goto process_precision;
ffffffffc020402a:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc020402e:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204030:	846a                	mv	s0,s10
            if (width < 0)
ffffffffc0204032:	e40dd9e3          	bgez	s11,ffffffffc0203e84 <vprintfmt+0x78>
                width = precision, precision = -1;
ffffffffc0204036:	8de6                	mv	s11,s9
ffffffffc0204038:	5cfd                	li	s9,-1
ffffffffc020403a:	b5a9                	j	ffffffffc0203e84 <vprintfmt+0x78>
            goto reswitch;
ffffffffc020403c:	00144603          	lbu	a2,1(s0)
            padc = '0';
ffffffffc0204040:	03000793          	li	a5,48
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204044:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0204046:	bd3d                	j	ffffffffc0203e84 <vprintfmt+0x78>
                precision = precision * 10 + ch - '0';
ffffffffc0204048:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
ffffffffc020404c:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204050:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc0204052:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc0204056:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc020405a:	fcd56ce3          	bltu	a0,a3,ffffffffc0204032 <vprintfmt+0x226>
            for (precision = 0; ; ++ fmt) {
ffffffffc020405e:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0204060:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
ffffffffc0204064:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
ffffffffc0204068:	0196873b          	addw	a4,a3,s9
ffffffffc020406c:	0017171b          	slliw	a4,a4,0x1
ffffffffc0204070:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
ffffffffc0204074:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
ffffffffc0204078:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
ffffffffc020407c:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc0204080:	fcd57fe3          	bleu	a3,a0,ffffffffc020405e <vprintfmt+0x252>
ffffffffc0204084:	b77d                	j	ffffffffc0204032 <vprintfmt+0x226>
            if (width < 0)
ffffffffc0204086:	fffdc693          	not	a3,s11
ffffffffc020408a:	96fd                	srai	a3,a3,0x3f
ffffffffc020408c:	00ddfdb3          	and	s11,s11,a3
ffffffffc0204090:	00144603          	lbu	a2,1(s0)
ffffffffc0204094:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204096:	846a                	mv	s0,s10
ffffffffc0204098:	b3f5                	j	ffffffffc0203e84 <vprintfmt+0x78>
            putch('%', putdat);
ffffffffc020409a:	85a6                	mv	a1,s1
ffffffffc020409c:	02500513          	li	a0,37
ffffffffc02040a0:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc02040a2:	fff44703          	lbu	a4,-1(s0)
ffffffffc02040a6:	02500793          	li	a5,37
ffffffffc02040aa:	8d22                	mv	s10,s0
ffffffffc02040ac:	d8f70de3          	beq	a4,a5,ffffffffc0203e46 <vprintfmt+0x3a>
ffffffffc02040b0:	02500713          	li	a4,37
ffffffffc02040b4:	1d7d                	addi	s10,s10,-1
ffffffffc02040b6:	fffd4783          	lbu	a5,-1(s10)
ffffffffc02040ba:	fee79de3          	bne	a5,a4,ffffffffc02040b4 <vprintfmt+0x2a8>
ffffffffc02040be:	b361                	j	ffffffffc0203e46 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc02040c0:	00002617          	auipc	a2,0x2
ffffffffc02040c4:	05860613          	addi	a2,a2,88 # ffffffffc0206118 <error_string+0xd8>
ffffffffc02040c8:	85a6                	mv	a1,s1
ffffffffc02040ca:	854a                	mv	a0,s2
ffffffffc02040cc:	0ac000ef          	jal	ra,ffffffffc0204178 <printfmt>
ffffffffc02040d0:	bb9d                	j	ffffffffc0203e46 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc02040d2:	00002617          	auipc	a2,0x2
ffffffffc02040d6:	03e60613          	addi	a2,a2,62 # ffffffffc0206110 <error_string+0xd0>
            if (width > 0 && padc != '-') {
ffffffffc02040da:	00002417          	auipc	s0,0x2
ffffffffc02040de:	03740413          	addi	s0,s0,55 # ffffffffc0206111 <error_string+0xd1>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02040e2:	8532                	mv	a0,a2
ffffffffc02040e4:	85e6                	mv	a1,s9
ffffffffc02040e6:	e032                	sd	a2,0(sp)
ffffffffc02040e8:	e43e                	sd	a5,8(sp)
ffffffffc02040ea:	18a000ef          	jal	ra,ffffffffc0204274 <strnlen>
ffffffffc02040ee:	40ad8dbb          	subw	s11,s11,a0
ffffffffc02040f2:	6602                	ld	a2,0(sp)
ffffffffc02040f4:	01b05d63          	blez	s11,ffffffffc020410e <vprintfmt+0x302>
ffffffffc02040f8:	67a2                	ld	a5,8(sp)
ffffffffc02040fa:	2781                	sext.w	a5,a5
ffffffffc02040fc:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
ffffffffc02040fe:	6522                	ld	a0,8(sp)
ffffffffc0204100:	85a6                	mv	a1,s1
ffffffffc0204102:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0204104:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc0204106:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0204108:	6602                	ld	a2,0(sp)
ffffffffc020410a:	fe0d9ae3          	bnez	s11,ffffffffc02040fe <vprintfmt+0x2f2>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020410e:	00064783          	lbu	a5,0(a2)
ffffffffc0204112:	0007851b          	sext.w	a0,a5
ffffffffc0204116:	e8051be3          	bnez	a0,ffffffffc0203fac <vprintfmt+0x1a0>
ffffffffc020411a:	b335                	j	ffffffffc0203e46 <vprintfmt+0x3a>
        return va_arg(*ap, int);
ffffffffc020411c:	000aa403          	lw	s0,0(s5)
ffffffffc0204120:	bbf1                	j	ffffffffc0203efc <vprintfmt+0xf0>
        return va_arg(*ap, unsigned int);
ffffffffc0204122:	000ae603          	lwu	a2,0(s5)
ffffffffc0204126:	46a9                	li	a3,10
ffffffffc0204128:	8aae                	mv	s5,a1
ffffffffc020412a:	bd89                	j	ffffffffc0203f7c <vprintfmt+0x170>
ffffffffc020412c:	000ae603          	lwu	a2,0(s5)
ffffffffc0204130:	46c1                	li	a3,16
ffffffffc0204132:	8aae                	mv	s5,a1
ffffffffc0204134:	b5a1                	j	ffffffffc0203f7c <vprintfmt+0x170>
ffffffffc0204136:	000ae603          	lwu	a2,0(s5)
ffffffffc020413a:	46a1                	li	a3,8
ffffffffc020413c:	8aae                	mv	s5,a1
ffffffffc020413e:	bd3d                	j	ffffffffc0203f7c <vprintfmt+0x170>
                    putch(ch, putdat);
ffffffffc0204140:	9902                	jalr	s2
ffffffffc0204142:	b559                	j	ffffffffc0203fc8 <vprintfmt+0x1bc>
                putch('-', putdat);
ffffffffc0204144:	85a6                	mv	a1,s1
ffffffffc0204146:	02d00513          	li	a0,45
ffffffffc020414a:	e03e                	sd	a5,0(sp)
ffffffffc020414c:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc020414e:	8ace                	mv	s5,s3
ffffffffc0204150:	40800633          	neg	a2,s0
ffffffffc0204154:	46a9                	li	a3,10
ffffffffc0204156:	6782                	ld	a5,0(sp)
ffffffffc0204158:	b515                	j	ffffffffc0203f7c <vprintfmt+0x170>
            if (width > 0 && padc != '-') {
ffffffffc020415a:	01b05663          	blez	s11,ffffffffc0204166 <vprintfmt+0x35a>
ffffffffc020415e:	02d00693          	li	a3,45
ffffffffc0204162:	f6d798e3          	bne	a5,a3,ffffffffc02040d2 <vprintfmt+0x2c6>
ffffffffc0204166:	00002417          	auipc	s0,0x2
ffffffffc020416a:	fab40413          	addi	s0,s0,-85 # ffffffffc0206111 <error_string+0xd1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020416e:	02800513          	li	a0,40
ffffffffc0204172:	02800793          	li	a5,40
ffffffffc0204176:	bd1d                	j	ffffffffc0203fac <vprintfmt+0x1a0>

ffffffffc0204178 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0204178:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc020417a:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc020417e:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0204180:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0204182:	ec06                	sd	ra,24(sp)
ffffffffc0204184:	f83a                	sd	a4,48(sp)
ffffffffc0204186:	fc3e                	sd	a5,56(sp)
ffffffffc0204188:	e0c2                	sd	a6,64(sp)
ffffffffc020418a:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc020418c:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc020418e:	c7fff0ef          	jal	ra,ffffffffc0203e0c <vprintfmt>
}
ffffffffc0204192:	60e2                	ld	ra,24(sp)
ffffffffc0204194:	6161                	addi	sp,sp,80
ffffffffc0204196:	8082                	ret

ffffffffc0204198 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc0204198:	715d                	addi	sp,sp,-80
ffffffffc020419a:	e486                	sd	ra,72(sp)
ffffffffc020419c:	e0a2                	sd	s0,64(sp)
ffffffffc020419e:	fc26                	sd	s1,56(sp)
ffffffffc02041a0:	f84a                	sd	s2,48(sp)
ffffffffc02041a2:	f44e                	sd	s3,40(sp)
ffffffffc02041a4:	f052                	sd	s4,32(sp)
ffffffffc02041a6:	ec56                	sd	s5,24(sp)
ffffffffc02041a8:	e85a                	sd	s6,16(sp)
ffffffffc02041aa:	e45e                	sd	s7,8(sp)
    if (prompt != NULL) {
ffffffffc02041ac:	c901                	beqz	a0,ffffffffc02041bc <readline+0x24>
        cprintf("%s", prompt);
ffffffffc02041ae:	85aa                	mv	a1,a0
ffffffffc02041b0:	00002517          	auipc	a0,0x2
ffffffffc02041b4:	f7850513          	addi	a0,a0,-136 # ffffffffc0206128 <error_string+0xe8>
ffffffffc02041b8:	f07fb0ef          	jal	ra,ffffffffc02000be <cprintf>
readline(const char *prompt) {
ffffffffc02041bc:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02041be:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc02041c0:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc02041c2:	4aa9                	li	s5,10
ffffffffc02041c4:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc02041c6:	0000db97          	auipc	s7,0xd
ffffffffc02041ca:	e7ab8b93          	addi	s7,s7,-390 # ffffffffc0211040 <buf>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02041ce:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc02041d2:	f25fb0ef          	jal	ra,ffffffffc02000f6 <getchar>
ffffffffc02041d6:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc02041d8:	00054b63          	bltz	a0,ffffffffc02041ee <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02041dc:	00a95b63          	ble	a0,s2,ffffffffc02041f2 <readline+0x5a>
ffffffffc02041e0:	029a5463          	ble	s1,s4,ffffffffc0204208 <readline+0x70>
        c = getchar();
ffffffffc02041e4:	f13fb0ef          	jal	ra,ffffffffc02000f6 <getchar>
ffffffffc02041e8:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc02041ea:	fe0559e3          	bgez	a0,ffffffffc02041dc <readline+0x44>
            return NULL;
ffffffffc02041ee:	4501                	li	a0,0
ffffffffc02041f0:	a099                	j	ffffffffc0204236 <readline+0x9e>
        else if (c == '\b' && i > 0) {
ffffffffc02041f2:	03341463          	bne	s0,s3,ffffffffc020421a <readline+0x82>
ffffffffc02041f6:	e8b9                	bnez	s1,ffffffffc020424c <readline+0xb4>
        c = getchar();
ffffffffc02041f8:	efffb0ef          	jal	ra,ffffffffc02000f6 <getchar>
ffffffffc02041fc:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc02041fe:	fe0548e3          	bltz	a0,ffffffffc02041ee <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0204202:	fea958e3          	ble	a0,s2,ffffffffc02041f2 <readline+0x5a>
ffffffffc0204206:	4481                	li	s1,0
            cputchar(c);
ffffffffc0204208:	8522                	mv	a0,s0
ffffffffc020420a:	ee9fb0ef          	jal	ra,ffffffffc02000f2 <cputchar>
            buf[i ++] = c;
ffffffffc020420e:	009b87b3          	add	a5,s7,s1
ffffffffc0204212:	00878023          	sb	s0,0(a5)
ffffffffc0204216:	2485                	addiw	s1,s1,1
ffffffffc0204218:	bf6d                	j	ffffffffc02041d2 <readline+0x3a>
        else if (c == '\n' || c == '\r') {
ffffffffc020421a:	01540463          	beq	s0,s5,ffffffffc0204222 <readline+0x8a>
ffffffffc020421e:	fb641ae3          	bne	s0,s6,ffffffffc02041d2 <readline+0x3a>
            cputchar(c);
ffffffffc0204222:	8522                	mv	a0,s0
ffffffffc0204224:	ecffb0ef          	jal	ra,ffffffffc02000f2 <cputchar>
            buf[i] = '\0';
ffffffffc0204228:	0000d517          	auipc	a0,0xd
ffffffffc020422c:	e1850513          	addi	a0,a0,-488 # ffffffffc0211040 <buf>
ffffffffc0204230:	94aa                	add	s1,s1,a0
ffffffffc0204232:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc0204236:	60a6                	ld	ra,72(sp)
ffffffffc0204238:	6406                	ld	s0,64(sp)
ffffffffc020423a:	74e2                	ld	s1,56(sp)
ffffffffc020423c:	7942                	ld	s2,48(sp)
ffffffffc020423e:	79a2                	ld	s3,40(sp)
ffffffffc0204240:	7a02                	ld	s4,32(sp)
ffffffffc0204242:	6ae2                	ld	s5,24(sp)
ffffffffc0204244:	6b42                	ld	s6,16(sp)
ffffffffc0204246:	6ba2                	ld	s7,8(sp)
ffffffffc0204248:	6161                	addi	sp,sp,80
ffffffffc020424a:	8082                	ret
            cputchar(c);
ffffffffc020424c:	4521                	li	a0,8
ffffffffc020424e:	ea5fb0ef          	jal	ra,ffffffffc02000f2 <cputchar>
            i --;
ffffffffc0204252:	34fd                	addiw	s1,s1,-1
ffffffffc0204254:	bfbd                	j	ffffffffc02041d2 <readline+0x3a>

ffffffffc0204256 <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc0204256:	00054783          	lbu	a5,0(a0)
ffffffffc020425a:	cb91                	beqz	a5,ffffffffc020426e <strlen+0x18>
    size_t cnt = 0;
ffffffffc020425c:	4781                	li	a5,0
        cnt ++;
ffffffffc020425e:	0785                	addi	a5,a5,1
    while (*s ++ != '\0') {
ffffffffc0204260:	00f50733          	add	a4,a0,a5
ffffffffc0204264:	00074703          	lbu	a4,0(a4)
ffffffffc0204268:	fb7d                	bnez	a4,ffffffffc020425e <strlen+0x8>
    }
    return cnt;
}
ffffffffc020426a:	853e                	mv	a0,a5
ffffffffc020426c:	8082                	ret
    size_t cnt = 0;
ffffffffc020426e:	4781                	li	a5,0
}
ffffffffc0204270:	853e                	mv	a0,a5
ffffffffc0204272:	8082                	ret

ffffffffc0204274 <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
ffffffffc0204274:	c185                	beqz	a1,ffffffffc0204294 <strnlen+0x20>
ffffffffc0204276:	00054783          	lbu	a5,0(a0)
ffffffffc020427a:	cf89                	beqz	a5,ffffffffc0204294 <strnlen+0x20>
    size_t cnt = 0;
ffffffffc020427c:	4781                	li	a5,0
ffffffffc020427e:	a021                	j	ffffffffc0204286 <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
ffffffffc0204280:	00074703          	lbu	a4,0(a4)
ffffffffc0204284:	c711                	beqz	a4,ffffffffc0204290 <strnlen+0x1c>
        cnt ++;
ffffffffc0204286:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0204288:	00f50733          	add	a4,a0,a5
ffffffffc020428c:	fef59ae3          	bne	a1,a5,ffffffffc0204280 <strnlen+0xc>
    }
    return cnt;
}
ffffffffc0204290:	853e                	mv	a0,a5
ffffffffc0204292:	8082                	ret
    size_t cnt = 0;
ffffffffc0204294:	4781                	li	a5,0
}
ffffffffc0204296:	853e                	mv	a0,a5
ffffffffc0204298:	8082                	ret

ffffffffc020429a <strcpy>:
char *
strcpy(char *dst, const char *src) {
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
#else
    char *p = dst;
ffffffffc020429a:	87aa                	mv	a5,a0
    while ((*p ++ = *src ++) != '\0')
ffffffffc020429c:	0585                	addi	a1,a1,1
ffffffffc020429e:	fff5c703          	lbu	a4,-1(a1)
ffffffffc02042a2:	0785                	addi	a5,a5,1
ffffffffc02042a4:	fee78fa3          	sb	a4,-1(a5)
ffffffffc02042a8:	fb75                	bnez	a4,ffffffffc020429c <strcpy+0x2>
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
ffffffffc02042aa:	8082                	ret

ffffffffc02042ac <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02042ac:	00054783          	lbu	a5,0(a0)
ffffffffc02042b0:	0005c703          	lbu	a4,0(a1)
ffffffffc02042b4:	cb91                	beqz	a5,ffffffffc02042c8 <strcmp+0x1c>
ffffffffc02042b6:	00e79c63          	bne	a5,a4,ffffffffc02042ce <strcmp+0x22>
        s1 ++, s2 ++;
ffffffffc02042ba:	0505                	addi	a0,a0,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02042bc:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
ffffffffc02042c0:	0585                	addi	a1,a1,1
ffffffffc02042c2:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02042c6:	fbe5                	bnez	a5,ffffffffc02042b6 <strcmp+0xa>
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc02042c8:	4501                	li	a0,0
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc02042ca:	9d19                	subw	a0,a0,a4
ffffffffc02042cc:	8082                	ret
ffffffffc02042ce:	0007851b          	sext.w	a0,a5
ffffffffc02042d2:	9d19                	subw	a0,a0,a4
ffffffffc02042d4:	8082                	ret

ffffffffc02042d6 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc02042d6:	00054783          	lbu	a5,0(a0)
ffffffffc02042da:	cb91                	beqz	a5,ffffffffc02042ee <strchr+0x18>
        if (*s == c) {
ffffffffc02042dc:	00b79563          	bne	a5,a1,ffffffffc02042e6 <strchr+0x10>
ffffffffc02042e0:	a809                	j	ffffffffc02042f2 <strchr+0x1c>
ffffffffc02042e2:	00b78763          	beq	a5,a1,ffffffffc02042f0 <strchr+0x1a>
            return (char *)s;
        }
        s ++;
ffffffffc02042e6:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc02042e8:	00054783          	lbu	a5,0(a0)
ffffffffc02042ec:	fbfd                	bnez	a5,ffffffffc02042e2 <strchr+0xc>
    }
    return NULL;
ffffffffc02042ee:	4501                	li	a0,0
}
ffffffffc02042f0:	8082                	ret
ffffffffc02042f2:	8082                	ret

ffffffffc02042f4 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc02042f4:	ca01                	beqz	a2,ffffffffc0204304 <memset+0x10>
ffffffffc02042f6:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc02042f8:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc02042fa:	0785                	addi	a5,a5,1
ffffffffc02042fc:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0204300:	fec79de3          	bne	a5,a2,ffffffffc02042fa <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0204304:	8082                	ret

ffffffffc0204306 <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc0204306:	ca19                	beqz	a2,ffffffffc020431c <memcpy+0x16>
ffffffffc0204308:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc020430a:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc020430c:	0585                	addi	a1,a1,1
ffffffffc020430e:	fff5c703          	lbu	a4,-1(a1)
ffffffffc0204312:	0785                	addi	a5,a5,1
ffffffffc0204314:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc0204318:	fec59ae3          	bne	a1,a2,ffffffffc020430c <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc020431c:	8082                	ret
