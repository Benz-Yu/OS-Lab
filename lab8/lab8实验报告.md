# Lab8实验报告

## 练习
对实验报告的要求：

- 基于markdown格式来完成，以文本方式为主
- 填写各个基本练习中要求完成的报告内容
- 列出你认为本实验中重要的知识点，以及与对应的OS原理中的知识点，并简要说明你对二者的含义，关系，差异等方面的理解（也可能出现实验中的知识点没有对应的原理知识点）
- 列出你认为OS原理中很重要，但在实验中没有对应上的知识点

## 练习0：填写已有实验
本实验依赖实验2/3/4/5/6/7。请把你做的实验2/3/4/5/6/7的代码填入本实验中代码中有“LAB2”/“LAB3”/“LAB4”/“LAB5”/“LAB6” /“LAB7”的注释相应部分。并确保编译通过。注意：为了能够正确执行lab8的测试应用程序，可能需对已完成的实验2/3/4/5/6/7的代码进行进一步改进。

## 练习1: 完成读文件操作的实现（需要编码）
首先了解打开文件的处理流程，然后参考本实验后续的文件读写操作的过程分析，填写在 kern/fs/sfs/sfs_inode.c中 的sfs_io_nolock()函数，实现读文件中数据的代码。


#### 关于inode的总结

这个文件系统应该是使用了一段（类似数组的）连续内存来存放很多个4k为单位的block。

block[0]是超块，操作系统一旦无法找到超级块，那么它后面的根目录等都不可能找到了。

然后是root-dir，block[1]，根目录。

然后有一个类似used_list的东西从第二个块开始，占据块总数相同的位数来表示是不是被占用。

此后开始是正常的数据部分和inode。

直接索引能索引12个块，这12个都是具体数据于是是12 * 4k。使用一级间接索引还有个indirect，指向的block[indirect]是额外的索引块，里面的12个全都是索引块。



### 读文件的流程：

VFS初始化： 在内核初始化阶段，我们首先初始化了虚拟文件系统（VFS）。这包括将引导文件系统（bootfs）的信号量设置为1，以确保其正常执行，并加载必要的项。同时，我们初始化了VFS的设备列表，并将相应的信号量设置为1。

设备初始化： 对设备的初始化是为了确保操作系统可以正确地与输入输出设备进行通信。我们初始化了stdin、stdout以及磁盘disk0。这里采用了一个宏，可以方便地调用每个设备的初始化函数，比如dev_init_disk0。

Sys初始化： 系统初始化的过程包括尝试挂载磁盘disk0，使其可以被访问和操作。这是通过调用相应的初始化函数来实现的。


#### 具体的打开文件的处理流程：

通用文件系统访问接口层提供了用户空间程序与底层文件系统的交互接口。当用户程序通过调用库函数的形式发起文件打开操作时，会触发系统调用，将要打开的文件路径和打开方式传递给系统文件系统（sysfile）。首先，需要将来自用户空间的路径字符串复制到内核空间，并减少对当前内存管理的信号量，以确保安全性和资源的合理利用。在路径处理完毕后，进入文件打开函数（file_open），进行打开方式的判定，然后尝试为要打开的文件分配一个文件结构体，该结构体存储与文件相关的状态信息。接着，调用虚拟文件系统（VFS）的打开函数（vfs_open）。

在VFS的打开函数中，首先进行一些打开方式的判定，然后调用 vfs_lookup 函数，尝试获取文件的 inode。如果输入的是相对路径，则从当前进程的文件信息中获取当前工作路径，并返回指定的 inode，如果找不到则返回 -E_NOENT。如果输入格式是 device:path，则找到设备的根节点，并将 path 的设备部分切除。接着根据路径格式（以 / 开头或非 / 开头）找到对应的根目录或当前路径。然后调用 vop_lookup 宏，对传入的节点进行条件判断，并调用 vop_lookup 进行具体的操作。在这个过程中，vop_lookup 实际上调用了 sfs_lookup 函数。

sfs_lookup 函数的作用是根据传入的路径在简单文件系统中查找相应的文件或目录。该函数是文件系统具体实现的一部分，负责处理路径查找等操作：
```c
static const struct inode_ops sfs_node_dirops = {
    .vop_magic                      = VOP_MAGIC,
    .vop_open                       = sfs_opendir,
    .vop_close                      = sfs_close,
    .vop_fstat                      = sfs_fstat,
    .vop_fsync                      = sfs_fsync,
    .vop_namefile                   = sfs_namefile,
    .vop_getdirentry                = sfs_getdirentry,
    .vop_reclaim                    = sfs_reclaim,
    .vop_gettype                    = sfs_gettype,
    .vop_lookup                     = sfs_lookup,
};
```
我们可以看到在文件夹、文件的inode结点被创建时，会经过类似
```c
vop_init(node, sfs_get_ops(din->type), info2fs(sfs, sfs));
```
的过程。当然以上是sfs的inode结点创建的过程，设备的结点又有别的函数。但是所有的inode要么是sfs_inode，要么是device：

```c
struct inode {
    union {
        struct device __device_info;
        struct sfs_inode __sfs_inode_info;
    } in_info;
	........
};
```


在这个过程中，vfs模块调用了sfs的具体实现来处理文件系统的相关操作，实现了从vfs到sfs的跳转。当调用vfs_lookup查找文件时，如果文件不存在，可以使用vop_create来创建文件。

接下来进入vop_open，进行引用计数的调整，以及可能的文件创建或截断操作。最终，打开的文件被存储在一个叫做file的结构体里，同时返回一个文件索引fd，以便之后直接索引到这个文件进行操作。

对于sfs文件系统的vop_open函数，如果打开的是一个文件夹，将进入sfs_opendir函数；如果打开的是一个具体的文件，将进入sfs_openfile函数。目前这两个函数都只进行了正确性判断，没有具体的功能实现。

在文件的打开流程中，目前文件系统和sfs的联系主要体现在这一点。在接下来的读写过程分析中，我们会重新回到这一层来详细讨论相关函数。然而，目前我们已经相对清楚地理解了整个文件访问流程。

具体设备的交互在文件打开的处理流程中并未涉及。在这个过程中，只是简单地获取文件的描述符并存储起来。实际的文件操作将在读写过程中详细讨论。

#### 具体的打开文件的处理流程：

总体的流程大概和前面的open类似。在syscall进入了sysfile_read。在这里首先先file_testfd，看看这个file等是不是可以正常使用。

然后分配一个大小为4096的缓冲区供读文件使用。这里的意思是每次最多只能读取一个page大小的内容，然后如果这个文件比4096大那么分批多次读取。文件的需要读取长度是len，文件到每次操作为止实际读取的长度是alen。然后进入到file_read函数。先通过fd2file拿到fd索引的file（也就是我们要读取的文件）。根据读取的长度声明对应的buffer结构体之后，又进入vop环节。这回直接跳转到了sfs的sfs_read函数。

从sfs_read进入sfs_io，写入位置为0，意思是正在读。接着又得到文件的信息sfs和索引节点的信息sin。对sin的信号量进行操作，防止在读时这个索引被人修改。在一切准备工作完毕后，调用sfs_io_nolock：


```c
static int
sfs_io_nolock(struct sfs_fs *sfs, struct sfs_inode *sin, void *buf, off_t offset, size_t *alenp, bool write) {
    struct sfs_disk_inode *din = sin->din;  // 获取文件的磁盘inode
    assert(din->type != SFS_TYPE_DIR);  // 断言文件类型不是目录
    off_t endpos = offset + *alenp, blkoff;  // 计算Rd/Wr操作的结束位置
    *alenp = 0;  // 将*alenp置零
    // calculate the Rd/Wr end position
    if (offset < 0 || offset >= SFS_MAX_FILE_SIZE || offset > endpos) {  // 如果offset小于0，或者大于等于SFS_MAX_FILE_SIZE，或者大于endpos，则返回-E_INVAL
        return -E_INVAL;
    }
    if (offset == endpos) {  // 如果offset等于endpos，则返回0
        return 0;
    }
    if (endpos > SFS_MAX_FILE_SIZE) {  // 如果endpos大于SFS_MAX_FILE_SIZE，则将endpos设为SFS_MAX_FILE_SIZE
        endpos = SFS_MAX_FILE_SIZE;
    }
    if (!write) {  // 若不是写操作
        if (offset >= din->size) {  // 若offset大于等于文件大小，则返回0
            return 0;
        }
        if (endpos > din->size) {  // 若endpos大于文件大小，则将endpos设为文件大小
            endpos = din->size;
        }
    }

    int (*sfs_buf_op)(struct sfs_fs *sfs, void *buf, size_t len, uint32_t blkno, off_t offset);  // 函数指针，指向读写缓冲区操作函数
    int (*sfs_block_op)(struct sfs_fs *sfs, void *buf, uint32_t blkno, uint32_t nblks);  // 函数指针，指向读写块操作函数
    if (write) {  // 若是写操作
        sfs_buf_op = sfs_wbuf, sfs_block_op = sfs_wblock;  // 设置函数指针指向写缓冲区操作和写块操作函数
    }
    else {  // 若是读操作
        sfs_buf_op = sfs_rbuf, sfs_block_op = sfs_rblock;  // 设置函数指针指向读缓冲区操作和读块操作函数
    }

    int ret = 0;  // 定义返回值
    size_t size, alen = 0;  // 定义size和alen变量
    uint32_t ino;  // 定义inode号
    uint32_t blkno = offset / SFS_BLKSIZE;  // 计算Rd/Wr操作开始的块号
    uint32_t nblks = endpos / SFS_BLKSIZE - blkno;  // 计算Rd/Wr操作涉及的块数

    //LAB8:EXERCISE1 YOUR CODE HINT: call sfs_bmap_load_nolock, sfs_rbuf, sfs_rblock,etc. read different kind of blocks in file
    /*2113870 2113683 1910109
     * (1) If offset isn't aligned with the first block, Rd/Wr some content from offset to the end of the first block
     *       NOTICE: useful function: sfs_bmap_load_nolock, sfs_buf_op
     *               Rd/Wr size = (nblks != 0) ? (SFS_BLKSIZE - blkoff) : (endpos - offset)
     * (2) Rd/Wr aligned blocks 
     *       NOTICE: useful function: sfs_bmap_load_nolock, sfs_block_op
     * (3) If end position isn't aligned with the last block, Rd/Wr some content from begin to the (endpos % SFS_BLKSIZE) of the last block
     *       NOTICE: useful function: sfs_bmap_load_nolock, sfs_buf_op
    */
  // (1)第一部分，用offset % SFS_BLKSIZE判断是否对齐，
  // 若没有对齐，则需要特殊处理，首先通过sfs_bmap_load_nolock找到这一块的inode，然后将这部分数据读出。
    if ((blkoff = offset % SFS_BLKSIZE) != 0) {  // 计算偏移量blkoff
        size = (nblks != 0) ? (SFS_BLKSIZE - blkoff) : (endpos - offset);  // 计算Rd/Wr的大小
        if ((ret = sfs_bmap_load_nolock(sfs, sin, blkno, &ino)) != 0) {  // 调用sfs_bmap_load_nolock函数获取块号对应的inode
            goto out;
        }
        if ((ret = sfs_buf_op(sfs, buf, size, ino, blkoff)) != 0) {  // 调用缓冲区操作函数读取数据
            goto out;
        }

        alen += size;  // 更新已处理数据大小
        buf += size;  // 调整缓冲区指针位置

        if (nblks == 0) {  // 如果没有剩余块，则跳转到out标签
            goto out;
        }

        blkno++;  // 更新块号
        nblks--;  // 更新剩余块数
    }

    if (nblks > 0) {  // 如果还有剩余块
        if ((ret = sfs_bmap_load_nolock(sfs, sin, blkno, &ino)) != 0) {  // 调用sfs_bmap_load_nolock函数获取块号对应的inode
            goto out;
        }
        if ((ret = sfs_block_op(sfs, buf, ino, nblks)) != 0) {  // 调用块操作函数读取数据
            goto out;
        }

        alen += nblks * SFS_BLKSIZE;  // 更新已处理数据大小
        buf += nblks * SFS_BLKSIZE;  // 调整缓冲区指针位置
        blkno += nblks;  // 更新块号
        nblks -= nblks;  // 更新剩余块数
    }

    if ((size = endpos % SFS_BLKSIZE) != 0) {  // 如果endpos没有与最后一个块对齐
        if ((ret = sfs_bmap_load_nolock(sfs, sin, blkno, &ino)) != 0) {  // 调用sfs_bmap_load_nolock函数获取块号对应的inode
            goto out;
        }
        if ((ret = sfs_buf_op(sfs, buf, size, ino, 0)) != 0) {  // 调用缓冲区操作函数读取数据
            goto out;
        }
        alen += size;  // 更新已处理数据大小
    }

out:
    *alenp = alen;  // 更新*alenp
    if (offset + alen > sin->din->size) {  // 如果处理后的文件大小大于原文件大小
        sin->din->size = offset + alen;  // 更新文件大小
        sin->dirty = 1;  // 标记inode为脏
    }
    return ret;  // 返回结果
}


```

在文件系统访问接口层，用户态能做的只是调用库函数写好的open然后发起系统调用。接着将要打开的文件路径和打开方式传给sysfile_open，这里首先将用户空间传来的路径字符串复制到内核空间，此举是为了确保安全性。然后进入file_open函数，在进行一些打开方式的判定后，尝试为要打开的文件分配一个file结构体，存储文件的相关状态信息。之后调用vfs_open进入虚拟接口层。

在vfs_open中，首先进行一些打开方式的判定，然后调用vfs_lookup尝试获取一个inode。根据路径的格式不同，找到相应的设备根节点或系统根目录。随后调用vop_lookup宏，最终调用vop_lookup函数，这个函数实际上是SFS文件系统中的SFS_lookup函数。

在SFS_lookup中，根据文件长度和块的大小的对应关系计算出direct的下标，用以返回一个sfs_disk_inode结点索引的具体数据块。然后根据offset和alenp进行一些边界判断，计算出需要读取的大小。根据上一次读取的块是否读取完进行判断，然后根据需要读取的大小进行操作，如果出现跨块的情况，再次调用相应函数进行数据读取。

在完成文件系统的操作后，需要进行与具体设备的交互。这时会调用dop_io宏，它会进入到设备层，与磁盘设备开始交互，进行d_io操作：

```c
static void
disk0_device_init(struct device *dev) {
    ......
	dev->d_io = disk0_io;
	.......
}

```
于是确定了d_io接下来要去到disk0_io了。再disk0_io里，我们读文件会通过disk0_read_blks_nolock和iobuf_move的组合把数据读取到buffer里面。最终传回到sfs层。




## 练习2: 完成基于文件系统的执行程序机制的实现（需要编码）
改写proc.c中的load_icode函数和其他相关函数，实现基于文件系统的执行程序机制。执行：make qemu。如果能看看到sh用户程序的执行界面，则基本成功了。如果在sh用户界面上可以执行”ls”,”hello”等其他放置在sfs文件系统中的其他执行程序，则可以认为本实验基本成功。

在 proc.c 中，我们需要先先初始化 fs 中的进程控制结构，也就是得操作一下 alloc_proc 函数

需要加的就是这一句：
```proc->filesp = NULL;```
这是因为一个文件需要在 VFS 中变为一个进程才能被执行。


更改后的alloc_proc函数如下：
```c
static struct proc_struct *
alloc_proc(void) {
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
    if (proc != NULL) {
    //LAB4:EXERCISE1 YOUR CODE
    /*
     * below fields in proc_struct need to be initialized
     *       enum proc_state state;                      // Process state
     *       int pid;                                    // Process ID
     *       int runs;                                   // the running times of Proces
     *       uintptr_t kstack;                           // Process kernel stack
     *       volatile bool need_resched;                 // bool value: need to be rescheduled to release CPU?
     *       struct proc_struct *parent;                 // the parent process
     *       struct mm_struct *mm;                       // Process's memory management field
     *       struct context context;                     // Switch here to run process
     *       struct trapframe *tf;                       // Trap frame for current interrupt
     *       uintptr_t cr3;                              // CR3 register: the base addr of Page Directroy Table(PDT)
     *       uint32_t flags;                             // Process flag
     *       char name[PROC_NAME_LEN + 1];               // Process name
     */
     //LAB5 YOUR CODE : (update LAB4 steps)
    /*
     * below fields(add in LAB5) in proc_struct need to be initialized
     *       uint32_t wait_state;                        // waiting state
     *       struct proc_struct *cptr, *yptr, *optr;     // relations between processes
     */
    //LAB6 YOUR CODE : (update LAB5 steps)
    /*
     * below fields(add in LAB6) in proc_struct need to be initialized
     *     struct run_queue *rq;                       // running queue contains Process
     *     list_entry_t run_link;                      // the entry linked in run queue
     *     int time_slice;                             // time slice for occupying the CPU
     *     skew_heap_entry_t lab6_run_pool;            // FOR LAB6 ONLY: the entry in the run pool
     *     uint32_t lab6_stride;                       // FOR LAB6 ONLY: the current stride of the process
     *     uint32_t lab6_priority;                     // FOR LAB6 ONLY: the priority of process, set by lab6_set_priority(uint32_t)
     */

     //LAB8 YOUR CODE : (update LAB6 steps)
      /*
     * below fields(add in LAB6) in proc_struct need to be initialized
     *       struct files_struct * filesp;                file struct point        
     */
        proc->state = PROC_UNINIT;
    	proc->pid = -1;
    	proc->runs = 0;
    	proc->kstack = NULL;
    	proc->need_resched = 0;
        proc->parent = NULL;
        proc->mm = NULL;
        memset(&(proc->context), 0, sizeof(struct context));
        proc->tf = NULL;
        proc->cr3 = boot_cr3;
        proc->flags = 0;
        memset(proc->name, 0, PROC_NAME_LEN);
        proc->wait_state = 0; //PCB新增的条目，初始化进程等待状态
        proc->cptr = proc->optr = proc->yptr = NULL;//设置指针
        proc->filesp = NULL;
    }

    return proc;
}
```
然后就是要实现 `load_icode` 函数，实现后的函数如下所示：
```c
// load_icode -  called by sys_exec-->do_execve
static int
load_icode(int fd, int argc, char **kargv) {
    /* LAB8:EXERCISE2 YOUR CODE  HINT:how to load the file with handler fd  in to process's memory? how to setup argc/argv?
     * MACROs or Functions:2113870 2113683 1910109
     *  mm_create        - create a mm
     *  setup_pgdir      - setup pgdir in mm
     *  load_icode_read  - read raw data content of program file
     *  mm_map           - build new vma
     *  pgdir_alloc_page - allocate new memory for  TEXT/DATA/BSS/stack parts
     *  lcr3             - update Page Directory Addr Register -- CR3
     */
  /* (1) create a new mm for current process
     * (2) create a new PDT, and mm->pgdir= kernel virtual addr of PDT
     * (3) copy TEXT/DATA/BSS parts in binary to memory space of process
     *    (3.1) read raw data content in file and resolve elfhdr
     *    (3.2) read raw data content in file and resolve proghdr based on info in elfhdr
     *    (3.3) call mm_map to build vma related to TEXT/DATA
     *    (3.4) callpgdir_alloc_page to allocate page for TEXT/DATA, read contents in file
     *          and copy them into the new allocated pages
     *    (3.5) callpgdir_alloc_page to allocate pages for BSS, memset zero in these pages
     * (4) call mm_map to setup user stack, and put parameters into user stack
     * (5) setup current process's mm, cr3, reset pgidr (using lcr3 MARCO)
     * (6) setup uargc and uargv in user stacks
     * (7) setup trapframe for user environment
     * (8) if up steps failed, you should cleanup the env.
     * - 
     * 
     * 1、建立内存管理器，创建一个新的mm（内存管理）结构体来管理当前进程的内存。

- 2、建立页目录，创建一个新的页目录表（PDT），并将mm的pgdir字段设置为页目录表的内核虚拟地址。

- 3、将程序文件的TEXT（代码）、DATA（数据）和BSS（未初始化数据）部分复制到进程的内存空间中：
    - 读取程序文件的原始数据内容，并解析ELF头部信息。
    - 根据ELF头部信息，在程序文件中读取原始数据内容，并根据ELF头部中的程序头部信息进行解析。
    - 调用mm_map函数来创建与TEXT和DATA相关的虚拟内存区域（VMA）。
    - 调用pgdir_alloc_page函数为TEXT和DATA部分分配内存页面，并将文件内容复制到新分配的页面中。
    - 调用pgdir_alloc_page函数为BSS部分分配内存页面，并将页面中的内容清零。

- 4、调用mm_map函数设置用户栈，并将参数放入用户栈中，建立并初始化用户堆栈

- 5、设置当前进程的mm结构、页目录表（使用lcr3宏定义）。

- 6、在用户栈中设置uargc和uargv参数，并且处理用户栈中传入的参数，

- 7、最后很关键的一步是设置用户进程的中断帧（trapframe）。

- 8、如果在上述步骤中出现错误，需要清理环境。

     */
    assert(argc >= 0 && argc <= EXEC_MAX_ARG_NUM);
    if (current->mm != NULL) {
        panic("load_icode: current->mm must be empty.\n");
    }

    int ret = -E_NO_MEM;
    struct mm_struct *mm;
    //(1) create a new mm for current process
    if ((mm = mm_create()) == NULL) {
        goto bad_mm;
    }
    //(2) create a new PDT, and mm->pgdir= kernel virtual addr of PDT
    if (setup_pgdir(mm) != 0) {
        goto bad_pgdir_cleanup_mm;
    }
    //(3) copy TEXT/DATA section, build BSS parts in binary to memory space of process
    struct Page *page;
    //(3.1) get the file header of the bianry program (ELF format)
    struct elfhdr __elf; // 创建一个临时的 ELF 文件头结构体
    struct elfhdr *elf = &__elf; // 初始化 elf 指针为临时 ELF 文件头的地址

    // 从可执行程序文件中读取 ELF 文件头的内容，偏移量为 0
    if ((ret = load_icode_read(fd, elf, sizeof(struct elfhdr), 0)) != 0)
        goto bad_elf_cleanup_pgdir; // 如果读取失败，跳转到错误处理部分
    // struct elfhdr *elf = (struct elfhdr *)binary;
    //(3.2) get the entry of the program section headers of the bianry program (ELF format)
    //struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
    //(3.3) This program is valid?
    if (elf->e_magic != ELF_MAGIC) {
        ret = -E_INVAL_ELF;
        goto bad_elf_cleanup_pgdir;
    }
    // 创建一个临时的 proghdr 结构体指针，并初始化 ph 指针
    struct proghdr __ph, *ph = &__ph;
    uint32_t vm_flags, perm, phnum;
    for (phnum = 0; phnum < elf->e_phnum; phnum ++) {
        off_t phoff = elf->e_phoff + sizeof(struct proghdr) * phnum;// 计算程序段头的偏移量
        // 从文件中读取程序段头的内容
        if ((ret = load_icode_read(fd, ph, sizeof(struct proghdr), phoff)) != 0) {
            goto bad_cleanup_mmap;
        }
        //(3.4) find every program section headers
          if (ph->p_type != ELF_PT_LOAD) {
        continue ;
        }
        // 检查 p_filesz 和 p_memsz 字段是否有效
        if (ph->p_filesz > ph->p_memsz) {
            ret = -E_INVAL_ELF;
            goto bad_cleanup_mmap;
        }
        // 如果 p_filesz 为 0，则跳过，因为静态变量可能不占用任何空间
        if (ph->p_filesz == 0) {
            continue ;
            // 这里不做任何处理，因为静态变量可能不占用任何空间
        }
        //(3.5) call mm_map fun to setup the new vma ( ph->p_va, ph->p_memsz)
        vm_flags = 0, perm = PTE_U | PTE_V;
        if (ph->p_flags & ELF_PF_X) vm_flags |= VM_EXEC;
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
        // modify the perm bits here for RISC-V
        if (vm_flags & VM_READ) perm |= PTE_R;
        if (vm_flags & VM_WRITE) perm |= (PTE_W | PTE_R);
        if (vm_flags & VM_EXEC) perm |= PTE_X;
        if ((ret = mm_map(mm, ph->p_va, ph->p_memsz, vm_flags, NULL)) != 0) {
            goto bad_cleanup_mmap;
        }
        off_t offset = ph->p_offset;
        size_t off, size;
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);

        ret = -E_NO_MEM;

        //(3.6) alloc memory, and  copy the contents of every program section (from, from+end) to process's memory (la, la+end)
        end = ph->p_va + ph->p_filesz;
        //(3.6.1) copy TEXT/DATA section of bianry program
        while (start < end) {
        // 分配一个页面，并将其映射到合适的虚拟地址
        if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL) {
            ret = -E_NO_MEM;
            goto bad_cleanup_mmap;
        }
        off = start - la, size = PGSIZE - off, la += PGSIZE;
        if (end < la) {
            size -= la - end;
        }
        // 从文件中读取程序段的内容，并将其复制到分配的页面中
        if ((ret = load_icode_read(fd, page2kva(page) + off, size, offset)) != 0) {
            goto bad_cleanup_mmap;
        }
        start += size, offset += size;
        }
        //(3.6.2) build BSS section of binary program
        end = ph->p_va + ph->p_memsz;

        if (start < la) {
            /* ph->p_memsz == ph->p_filesz */
            if (start == end) {
                continue ;
            }
            off = start + PGSIZE - la, size = PGSIZE - off;
            if (end < la) {
                size -= la - end;
            }
            memset(page2kva(page) + off, 0, size);
            start += size;
            assert((end < la && start == end) || (end >= la && start == la));
        }
        while (start < end) {
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL) {
                ret = -E_NO_MEM;
                goto bad_cleanup_mmap;
            }
            off = start - la, size = PGSIZE - off, la += PGSIZE;
            if (end < la) {
                size -= la - end;
            }
            memset(page2kva(page) + off, 0, size);
            start += size;
        }
    }
    //(4) build user stack memory
    vm_flags = VM_READ | VM_WRITE | VM_STACK;
    if ((ret = mm_map(mm, USTACKTOP - USTACKSIZE, USTACKSIZE, vm_flags, NULL)) != 0) {
        goto bad_cleanup_mmap;
    }
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-PGSIZE , PTE_USER) != NULL);
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-2*PGSIZE , PTE_USER) != NULL);
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-3*PGSIZE , PTE_USER) != NULL);
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-4*PGSIZE , PTE_USER) != NULL);
    //(5) set current process's mm, sr3, and set CR3 reg = physical addr of Page Directory
    mm_count_inc(mm);
    current->mm = mm;
    current->cr3 = PADDR(mm->pgdir);
    lcr3(PADDR(mm->pgdir));

    //(6) setup trapframe for user environment
    uint32_t argv_size=0, i;
    for (i = 0; i < argc; i ++) {
        argv_size += strnlen(kargv[i],EXEC_MAX_ARG_LEN + 1)+1;
    }

    // 计算栈顶位置
    uintptr_t stacktop = USTACKTOP - (argv_size/sizeof(long)+1)*sizeof(long);
    // 将参数列表（uargv）放置在栈上
    char** uargv=(char **)(stacktop  - argc * sizeof(char *));
    argv_size = 0;
    for (i = 0; i < argc; i ++) {
        // 将参数字符串依次拷贝到栈上，并更新参数列表
        uargv[i] = strcpy((char *)(stacktop + argv_size ), kargv[i]);
        argv_size +=  strnlen(kargv[i],EXEC_MAX_ARG_LEN + 1)+1;
    }

    // 将参数个数 argc 放置在栈顶，并更新栈顶位置
    stacktop = (uintptr_t)uargv - sizeof(int);
    *(int *)stacktop = argc;

    // 获取当前进程的陷阱帧指针
    struct trapframe *tf = current->tf;
    // Keep sstatus
    uintptr_t sstatus = tf->status;
    memset(tf, 0, sizeof(struct trapframe));
     /* LAB5:EXERCISE1 2113870 2113683 1910109
     * should set tf->gpr.sp, tf->epc, tf->status
     * NOTICE: If we set trapframe correctly, then the user level process can return to USER MODE from kernel. So
     *          tf->gpr.sp should be user stack top (the value of sp)
     *          tf->epc should be entry point of user program (the value of sepc)
     *          tf->status should be appropriate for user program (the value of sstatus)
     *          hint: check meaning of SPP, SPIE in SSTATUS, use them by SSTATUS_SPP, SSTATUS_SPIE(defined in risv.h)
     */
    tf->gpr.sp=stacktop;
    //tf->gpr.sp = USTACKTOP; // 设置tf->gpr.sp为用户栈的顶部地址
    tf->epc = elf->e_entry; // 设置tf->epc为用户程序的入口地址
    tf->status = (read_csr(sstatus) & ~SSTATUS_SPP & ~SSTATUS_SPIE); // 根据需要设置 tf->status 的值，清除 SSTATUS_SPP 和 SSTATUS_SPIE 位
    ret = 0;
out:
    return ret;
bad_cleanup_mmap:
    exit_mmap(mm);
bad_elf_cleanup_pgdir:
    put_pgdir(mm);
bad_pgdir_cleanup_mm:
    mm_destroy(mm);
bad_mm:
    goto out;
}

```
load_icode 主要是将文件加载到内存中执行，具体步骤如下：

创建一个新的内存管理（mm）结构体，用于管理当前进程的内存空间。

创建一个新的页目录表（PDT），将mm的pgdir字段设置为页目录表的内核虚拟地址。

通过已经实现好的文件系统的read操作，读取程序文件的原始数据内容，并解析ELF头部信息。根据ELF头部信息，在程序文件中读取原始数据内容，并根据ELF头部中的程序头部信息进行解析。

调用mm_map函数来创建与TEXT和DATA相关的虚拟内存区域（VMA）。调用pgdir_alloc_page函数为TEXT和DATA部分分配内存页面，并将文件内容复制到新分配的页面中。同时，调用pgdir_alloc_page函数为BSS部分分配内存页面，并将页面中的内容清零。

调用mm_map函数设置用户栈，并将参数放入用户栈中，建立并初始化用户堆栈。

设置当前进程的mm结构、页目录表（使用lcr3宏定义）。

在用户栈中设置uargc和uargv参数，并且处理用户栈中传入的参数。

设置用户进程的中断帧（trapframe）。

如果在上述步骤中出现错误，需要进行环境清理。

主要和lab5中不一样，需要修改的地方有：

读取ELF文件需把原来lab5中的实现改为通过已经实现好的文件系统的`read`操作进行硬盘文件读取，这个改动主要体现在第三步中，具体如下：
```c
//lab5中
    //(3.1) get the file header of the bianry program (ELF format)
    struct elfhdr *elf = (struct elfhdr *)binary;
    //(3.2) get the entry of the program section headers of the bianry program (ELF format)
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
    //(3.3) This program is valid?
    if (elf->e_magic != ELF_MAGIC) {
        ret = -E_INVAL_ELF;
        goto bad_elf_cleanup_pgdir;
    }

//lab8中
    //(3.1) get the file header of the bianry program (ELF format)
    struct elfhdr __elf;
    struct elfhdr *elf = &__elf;
    if((ret = load_icode_read(fd, elf, sizeof(struct elfhdr), 0)) != 0)
        goto bad_elf_cleanup_pgdir;
    // struct elfhdr *elf = (struct elfhdr *)binary;
    //(3.2) get the entry of the program section headers of the bianry program (ELF format)
    //struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
    //(3.3) This program is valid?
    if (elf->e_magic != ELF_MAGIC) {
        ret = -E_INVAL_ELF;
        goto bad_elf_cleanup_pgdir;
    }
    struct proghdr __ph, *ph = &__ph;
    uint32_t vm_flags, perm, phnum;
```
上面仅展示了一部分，`load_icode_read`应用第三步里各个对在进行硬盘文件读取部分，涉及到读取就要把原来的代码改成调用它。

此外，加入了任意大小参数`argc`和`argv`的功能，使得应用程序能够接受命令行参数输入，这部分改动加在第六步，具体如下：
```c
    uint32_t argv_size=0, i;
    for (i = 0; i < argc; i ++) {
        argv_size += strnlen(kargv[i],EXEC_MAX_ARG_LEN + 1)+1;
    }

    uintptr_t stacktop = USTACKTOP - (argv_size/sizeof(long)+1)*sizeof(long);
    char** uargv=(char **)(stacktop  - argc * sizeof(char *));
    
    argv_size = 0;
    for (i = 0; i < argc; i ++) {
        uargv[i] = strcpy((char *)(stacktop + argv_size ), kargv[i]);
        argv_size +=  strnlen(kargv[i],EXEC_MAX_ARG_LEN + 1)+1;
    }
    
    stacktop = (uintptr_t)uargv - sizeof(int);
    *(int *)stacktop = argc;
```
