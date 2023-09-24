#  操作系统lab0.5+lab1实验报告
##  lab 0.5
###  练习1: 使用GDB验证启动流程
由于在qemu源代码中宏定义了复位地址**0x1000**，使用gdb调试QEMU模拟的RISC-V计算机加电后，将直接从**0x1000**处开始执行汇编代码
![从0x1000处开始的汇编代码](/imgs/2023-09-23/nNhZOu5asbQdCy9y.png)
***复位地址上的复位代码如下***
**auipc  t0,0x0**:将 PC 的值加上一个立即数0x0，并将结果存储到一个寄存器中 t0中。
**addi  a1,t0,32**:将立即数32加在寄存器t0中，并将结果储存在寄存器a1里
**csrr a0,mhartid**:读取特定控制状态寄存器（CSR）的指令，并将结果存储到一个通用寄存器 a0中.
**ld   t0,24(t0)**:从内存中加载数据0x80000000的指令，并将结果存储到一个通用寄存器t0中
**jr     t0**:跳转到由寄存器指定的地址的指令,即跳转到0x80000000处运行bootloader

***跳转到0x80000000后将执行以下汇编代码***
![输入图片说明](/imgs/2023-09-23/dGiHYhOtrm5g8fM8.png)

**csrr a6,mhartid**:读取特定控制状态寄存器（CSR）的指令，并将结果存储到一个通用寄存器 a6中.
**bgtz a6,0x80000108**:如果 a6 寄存器中的值大于零，程序计数器（PC）的值会被设置为 0x80000108，然后程序会从该地址开始执行。否则，程序会继续执行下一条指令。
**auipc  t1,0x0**:将 PC 的值加上一个立即数0x0，并将结果存储到一个寄存器中 t1中。
**addi  a1,t0,1032**:将立即数1032加在寄存器t0中，并将结果储存在寄存器a1里
**auipc  t1,0x0**:将 PC 的值加上一个立即数0x0，并将结果存储到一个寄存器中 t1中。
**addi  t1,t1,-16**:将立即数-16加在寄存器t1中，并将结果储存在寄存器t1里
**sd    t1,0(t0)**:t1 寄存器中的值将被存储到内存中地址为 t0 的位置
**auipc  t0,0x0**:将 PC 的值加上一个立即数0x0，并将结果存储到一个寄存器中 t0中。
**addi  t0,t0,1020**:将立即数1020加在寄存器t0中，并将结果储存在寄存器t0里
**ld   t0,0(t0)**:从内存中加载数据0+t0的指令，并将结果存储到一个通用寄存器t0中
***.......***
***.......***
***.......***
在**0x80200000**处打上断点后运行到**0x80200000**后即开始执行应用程序的第一条指令，进入一个死循环之中

***思考与讨论***
本实验中未涉及如何将内核镜像**os.bin** 被加载到以物理地址 0x80200000开头的区域上的过程
0x80200000处的代码为**地址相关代码**不可以随意更换代码地址


##  lab 1
### 练习1：理解内核启动中的程序入口操作
Q:阅读 kern/init/entry.S内容代码，结合操作系统内核启动流程，说明指令 la sp, bootstacktop 完成了什么操作，目的是什么？ tail kern_init 完成了什么操作，目的是什么？

A：`la sp, bootstacktop`: 这条指令是 MIPS 汇编语言中的一条加载指令，它将 `bootstacktop` 的地址加载到 `sp` 寄存器中。在这里，`sp` 是堆栈指针，`bootstacktop` 是堆栈的顶部地址。这样做的目的是设置堆栈指针，确保在后续的代码执行中，如果有函数调用或者中断发生，可以使用正确的堆栈空间。`tail kern_init`: 这条指令跳转到 `kern_init` 函数的末尾。在 MIPS 汇编中，`tail` 是一个伪指令，用于表示一个跳转的目标位置。在这里，它的目的是跳转到内核初始化函数的末尾，也就是内核初始化的代码开始执行的地方。这样做是为了开始执行内核的初始化过程，包括设置各种系统参数，初始化设备驱动等。

###  练习2：完善中断处理 （需要编程）
Q:请编程完善trap.c中的中断处理函数trap，在对时钟中断进行处理的部分填写kern/trap/trap.c函数中处理时钟中断的部分，使操作系统每遇到100次时钟中断后，调用print_ticks子程序，向屏幕上打印一行文字”100 ticks”，在打印完10行后调用sbi.h中的shut_down()函数关机。
要求完成问题1提出的相关函数实现，提交改进后的源代码包（可以编译执行），并在实验报告中简要说明实现过程和定时器中断中断处理的流程。实现要求的部分代码后，运行整个系统，大约每1秒会输出一次”100 ticks”，输出10行。

完善编程代码如下：
```
 case IRQ_S_TIMER:
            // "All bits besides SSIP and USIP in the sip register are
            // read-only." -- privileged spec1.9.1, 4.1.4, p59
            // In fact, Call sbi_set_timer will clear STIP, or you can clear it
            // directly.
            // cprintf("Supervisor timer interrupt\n");
             /* LAB1 EXERCISE2   2113683 :  */
            /*(1)设置下次时钟中断- clock_set_next_event()
             *(2)计数器（ticks）加一
             *(3)当计数器加到100的时候，我们会输出一个`100ticks`表示我们触发了100次时钟中断，同时打印次数（num）加一
            * (4)判断打印次数，当打印次数为10时，调用<sbi.h>中的关机函数关机
            */
            clock_set_next_event();
	    ticks+=1;
	    if(ticks==100){
		cprintf("100ticks\n");
		num+=1;
		ticks=0;
		}
	    if(num==10){
		sbi_shutdown();
		}
            break;
```
**执行结果如下**
![输入图片说明](/imgs/2023-09-23/oYNgYgappJPtIOjW.png)

如图所示，正常每1秒输出一次100ticks并在输出10行后自动调用sbi.h中的shut_down()函数关机。

### 扩展练习 Challenge1：描述与理解中断流程
Q：描述ucore中处理中断异常的流程（从异常的产生开始），其中mov a0，sp的目的是什么？SAVE_ALL中寄寄存器保存在栈中的位置是什么确定的？对于任何中断，__alltraps 中都需要保存所有寄存器吗？请说明理由。

A：	1.  `mov a0, sp`的目的：这条指令是将当前的栈指针（sp）的值复制到寄存器a0中。在ucore中，a0通常被用作系统调用的参数传递。
		2.  `SAVE_ALL`中寄存器保存在栈中的位置：在ucore中，`SAVE_ALL`宏用于保存所有的CPU寄存器。这些寄存器被保存在栈中，位置由硬件和编译器决定。在大多数实现中，寄存器的保存顺序和它们的编号有关，比如a0, a1, a2, ..., a7, sp, ra。
		3.  对于任何中断，`__alltraps`中都需要保存所有寄存器吗？在ucore中，答案是肯定的。因为中断处理程序可能会改变CPU的状态，包括寄存器的值。保存所有的寄存器是为了在中断处理完成后能够恢复被中断的程序原来的状态。不保存所有的寄存器可能会导致程序在中断处理完成后处于未定义的状态，引发错误。
		
###  扩增练习 Challenge2：理解上下文切换机制
Q：在trapentry.S中汇编代码 csrw sscratch, sp；csrrw s0, sscratch, x0实现了什么操作，目的是什么？save all里面保存了stval scause这些csr，而在restore all里面却不还原它们？那这样store的意义何在呢？

A：  1、`csrw sscratch, sp`这条指令将栈指针（sp）的值写入到名为sscratch的CSR中。`csrrw s0, sscratch, x0`这条指令将sscratch的值读取到s0寄存器，同时将x0寄存器的值写入到sscratch。在这两个操作中，sscratch通常被用作一个临时寄存器，用于在不同的操作之间保存和恢复状态。
		2、在异常处理或系统调用中，stval scause这些csr里的数据可能包括函数的返回值、寄存器的旧值等。尽管stval和scause等CSR的值在`restore all`中不会被还原，但在其他地方，可能需要这些值来判断异常的原因，或者决定如何处理异常。因此，在`save all`中保存这些值仍然是有意义的。

### 扩展练习Challenge3：完善异常中断
A：编程完善在触发一条非法指令异常 mret和，在 kern/trap/trap.c的异常处理函数中捕获，并对其进行处理，简单输出异常类型和异常指令触发地址，即“Illegal instruction caught at 0x(地址)”，“ebreak caught at 0x（地址）”与“Exception type:Illegal instruction"，“Exception type: breakpoint”。
