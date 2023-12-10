# Lab5：用户进程管理
## 练习0：填写已有实验
本实验依赖实验2/3/4。请把你做的实验2/3/4的代码填入本实验中代码中有“LAB2”/“LAB3”/“LAB4”的注释相应部分。注意：为了能够正确执行lab5的测试应用程序，可能需对已完成的实验2/3/4的代码进行进一步改进。

## 练习1: 加载应用程序并执行（需要编码）
#### do_execv函数调用load_icode（位于kern/process/proc.c中）来加载并解析一个处于内存中的ELF执行文件格式的应用程序。你需要补充load_icode的第6步，建立相应的用户内存空间来放置应用程序的代码段、数据段等，且要设置好proc_struct结构中的成员变量trapframe中的内容，确保在执行此进程后，能够从应用程序设定的起始执行地址开始执行。需设置正确的trapframe内容。请在实验报告中简要说明你的设计实现过程。
我们只需要设置三个内容：将trapframe的栈指针SP设置为用户空间的栈顶USTACKTOP；将用户态程序计数器设置为程序入口点；将原来的SPP、SPIE位清零。
```c
    tf->gpr.sp = USTACKTOP;
    tf->epc = elf->e_entry;
    tf->status = sstatus & ~(SSTATUS_SPP | SSTATUS_SPIE);
```

#### 请简要描述这个用户态进程被ucore选择占用CPU执行（RUNNING态）到具体执行应用程序第一条指令的整个经过。
schedule()函数选择该用户态进程后，操作系统先保存原执行进程的上下文，然后切换到新进程的上下文。再将新进程设置为running态，将其代码和数据加载到内存中，最后根据epc开始执行第一条指令。
## 练习2: 父进程复制自己的内存空间给子进程（需要编码）
#### 创建子进程的函数do_fork在执行中将拷贝当前进程（即父进程）的用户内存地址空间中的合法内容到新进程中（子进程），完成内存资源的复制。具体是通过copy_range函数（位于kern/mm/pmm.c中）实现的，请补充copy_range的实现，确保能够正确执行。请在实验报告中简要说明你的设计实现过程。
```c
    void *kva_src = page2kva(page);
    void *kva_dst = page2kva(npage);
    memcpy(kva_dst, kva_src, PGSIZE);
    ret = page_insert(to, npage, start, perm);
    assert(ret == 0);
```
我们只需使用深拷贝将父进程的内容拷贝到子进程新申请的页中，然后将子进程的页插入页目录表中
#### 如何设计实现Copy on Write机制？给出概要设计，鼓励给出详细设计。Copy-on-write（简称COW）的基本概念是指如果有多个使用者对一个资源A（比如内存块）进行读操作，则每个使用者只需获得一个指向同一个资源A的指针，就可以使用该资源了。若某使用者需要对这个资源A进行写操作，系统会对该资源进行拷贝操作，从而使得该“写操作”使用者获得一个该资源A的“私有”拷贝—资源B，可对资源B进行写操作。该“写操作”使用者对资源B的改变对于其他的使用者而言是不可见的，因为其他使用者看到的还是资源A。
当使用者使用某资源时，先默认其仅读取资源而不更改；当检测到写操作时，将该资源复制一份，然后申请一个新的指针，并将其提供给该使用者使用。其他使用者依然使用原有指针，故他们看到的还是原有资源，某使用者对资源的改变是其他使用者不可见的。
## 练习3: 阅读分析源代码，理解进程执行 fork/exec/wait/exit 的实现，以及系统调用的实现（不需要编码）
#### 请在实验报告中简要说明你对 fork/exec/wait/exit函数的分析，并回答如下问题：请分析fork/exec/wait/exit的执行流程。重点关注哪些操作是在用户态完成，哪些是在内核态完成？内核态与用户态程序是如何交错执行的？内核态执行结果是如何返回给用户程序的？
fork:创建一个新的进程，将新进程的父进程指向当前进程->创建内核栈->由克隆标志位决定共享还是复制内存->在内核栈顶设置中断帧，程序入口点->分配进程号并将其加入到进程链表中->将进程唤醒，返回值设置为进程ID<br>
exec:检查内存为可用的用户态内存->将内存管理mm_struct置空->调用load_icode()函数读ELF格式的文件，申请内存空间，建立用户态虚存空间，加载应用程序执行码等->设置进程名<br>
wait:检查内存为可用的用户态内存首先检查指定的 pid 是否为 0，如果不为 0，则根据 pid 查找对应的进程，并判断是否是当前进程的子进程，并且是否处于僵尸状态。如果是，则跳转到标签 found。如果 pid 为 0，表示要等待任意子进程的结束，那么就遍历当前进程的所有子进程，检查它们是否处于僵尸状态，如果是，则同样跳转到标签 found。在 found 标签处，会进行一些必要的检查，比如确保被等待的进程不是空闲进程或者初始化进程。然后，如果传入的 code_store 不为 NULL，就将被等待进程的退出码存储到 code_store 指向的内存区域。
紧接着，代码在保存中断状态、从进程哈希表中删除进程、移除进程链表、释放内核栈和最终释放进程所占用的内存空间。最后返回 0 表示等待成功。<br>
exit:将进程管理内存的资源全部释放->进程状态设置为ZOOMBIE（将要结束进程但资源释放未全部完成）->若其父进程处于等待子进程状态，那么将它唤醒将自己的子进程过渡为自己父进程的子进程<Br>
#### 请给出ucore中一个用户态进程的执行状态生命周期图（包括执行状态，执行状态之间的变换关系，以及产生变换的事件或函数调用）。（字符方式画即可）
以exit用户进程为例：<br>
kernel_thread()->do_fork()->{alloc_proc()``程序状态PROC_UNINIT``、setup_kstack(proc)、copy_mm(clone_flags, proc)、copy_thread(proc, stack, tf)、 wakeup_proc(proc)``程序状态改为runnable``}->schedule()->process_run()->{lcr3()、switch_to()}->fork()->sys_fork()->syscall(SYS_fork)->ecall->trap(struct trapframe *tf)->trap_dispatch(tf)->exception_handler(tf)->syscall()->syscalls[num](arg)->sys_fork(uint64_t arg[])->do_fork(0, stack, tf)->{······}->exit()->sys_fork()->syscall(SYS_fork)->ecall->trap(struct trapframe *tf)->trap_dispatch(tf)->exception_handler(tf)->syscall()->syscalls[num](arg)->sys_fork(uint64_t arg[])->do_exit(error_code)