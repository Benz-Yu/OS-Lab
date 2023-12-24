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


#### 一些关于inode的总结

这个文件系统应该是使用了一段（类似数组的）连续内存来存放很多个4k为单位的block。

block[0]是超块，也就是gxl老师说的一旦这万一坏了那你又获得了一个新砖头了。艹做系统一旦无法找到超级块，那么它后面的根目录啥的都根本不可能找到了。（不是说得从超级块找到莫，可是看起来超级快的数据里面没有相关的情况呀，还是可以直接找到root）

然后是root-dir，block[1]，这个是gxl老师说的一旦这玩意噶了就得花大价钱来扫描整个磁盘空间然后根据关系推断出谁是谁的父亲。

然后有一个类似used_list的东西从第二个块开始，占据核块总数相同的bit数来表示是不是被占用。

此后开始是正常的数据部分，这里好像没有额外的freelist来保证健壮性。


我感觉哦，这个sfs_disk_inode的direct是存了很多个块，如果这个b是个文件夹，那么它里面可能存了别的文件夹头的块，或者是直接就是文件头的块。如果这个b是个文件，那么里面就直接是这个文件使用到的所有块。

使用一级间接索引，我的理解是，我能索引12个块，这12个都是具体数据于是是12 * 4k。而我还有个indirect，这玩意指向的block[indirect]是我的额外的索引块，里面的12个全都是索引块，这12个又可以各自索引12个具体的文件数据块，于是再加上12*12*4k



### 那么从现在开始，进入读文件的流程。

最开始首先从宏观上来梳理一下这次实验的一些相关的东西。一个独写文件的流程，大概是经过：

- 在一个进程调用了相关的库的接口。

- 用户进程下潜到内核调用抽象层的接口。抽象层是为了方便在各种使用不同的文件系统的操作系统中移植代码而使用的一个对上层提供通用接口的层次。

- 从抽象层进入到我们这个操作系统的真正的文件系统。

- 文件系统调用硬盘io接口。

那么现在来看看细节。在内核初始化的时候现在多了个文件系统的初始化。它干了三件事：

- 初始化vfs。这里包括给引导文件系统bootfs的信号量置为1，让它能正常执行然后加载必要项（老师说不被人使用的信号量在这里焕发第二春！）。同时初始化vfs的设备列表，它的对应的信号量也置为1.

- 设备初始化，主要是将这次实验用到的stdin、stdout和磁盘disk0初始化。这里用了一个很神奇的宏来实现对于每个不同的设备都可以调用到比如说dev_init_disk0，也就是对应的初始化函数。

- 初始化sys。这里试图把disk0挂载，使其可以被访问和操作。


#### 现在到了具体的打开文件的处理流程了。

1. 通用文件系统访问接口层：

用户态能能做到的仍然只是调用库函数写好的open然后发起系统调用。这里陷入内核态之后将要打开的文件路径和打开方式传给sysfile_open（注意这里是sysfile系统文件不是sfs简单文件系统，一开始我看混了还纳闷怎么直接就跳过vfs进入sfs了），这里首先得把用户空间来的路径字符串复制到内核空间（如果返回的不是0，就说明返回的是-E_INVAL表示复制失败了）复制的时候得把现在的mm的信号量减少说明我正在用这个复制字符串。这里的复制字符串，我认为是因为这个传入的是指针，而这个字符串指针所在的位置是用户空间，在内核空间直接使用这个东西可能会造成一些不安全的影响。总之，在路径处理完毕后，进入file_open函数。在进行一些打开方式的判定后，尝试为这个要打开的文件分配一个file结构体。它的里面存了一些文件的相关状态信息。这里是直接从fd数组里面拿一个出与可用状态FD_NONE的file结构体。我推测fd数组这个机制存在的原因可能是要限制打开文件的上限数。这里的fd应该是索引下标，如果传入的是NO_FD那么随便分配一个，否则返回fd指定的如果是合法的file。然后调用vfs_open进入虚拟接口层

2. vfs：在vfs_open中，

首先上来还是一些打开方式的判定。调用vfs_lookup根据这个传入的路径试图获得一个inode。如果输入的是一个相对路径，那么就试图从当前进程的filesp信息里面拿到当前进程的工作路径作为返回给这个inode，然后直接返回一个-E_NOENT。如果来的是一个device:path格式的，那么找到这个device的根节点同时将path参数的device:部分切掉。如果找的到根那么这个部分返回0.剩下的情况如果是/开头那么就找到系统根目录，否则就是找到当前的路径（可能是个设备，所以拿到它的fs然后返回）

然后进入一个vop_lookup宏。这个宏的作用我推测只是对所有vop操作都进行同样的条件判断，然后对传入的node的in_ops（这是一个node的op操作集合）调用vop_lookup。现在最关键的地方来了。这个vop_lookup，事实上就是sfs_lookup：

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


看到sfs_get_ops(din->type)里就包括了sfs_node_dirops。于是inode结点的函数vop_lookup就可以使用到sfs_lookup。这里实现了vfs到sfs的跳转。

当然现在vfs还没有结束，让我们把目光再回到调用vfs_lookup的地方。这里如果这个文件不存在，我们可以给他创建一个。当进入到vop_create宏时，它所遇到的操作和上述的vop_lookup是一样的。在理解了这一堆vop的宏操作是干什么之后（如果我没理解错的话），我们就可以知道这个过程实际上就是vfs进入到sfs了。

接下来就可以进入vop_open了。然后把一些引用计数进行调整，同时如果需求是创建文件或者截断，那么就可以调用vop_truncate(node, 0)将文件的长度截断为0，相当于重新创建了。具体的vop_open进入到什么地方在下个阶段进行描述。

在以上的人肉深度优先的学习函数调用的过程解释完毕后，这个被打开的文件的node就终于存到了file里，然后这个file的索引fd被返回回去，下次在使用的时候可以直接索引到这个file然后都这个文件了。

3.sfs

对于vop_open函数，如果打开的是一个文件夹，那么经过一系列兜兜转转最终会来到sfs_opendir。如果打开的是一个具体的文件，那么会到sfs_openfile。这两者目前都还没有特别的功能实现，都只是做了正确性判断。

文件的打开流程目前和sfs的联系也就暂时只有这点，后面在分析读写过程的时候我们还会回到这一层来具体探讨一下相关函数。但是现在已经可以比较清楚的清除这一套访问下来的流程了。

4.具体设备

如果仅仅只是找到这个文件的描述符然后把它存起来（打开文件的处理流程），在这个过程中似乎不涉及到具体设备的交互。open操作也断在了sfs里面没有下文了。具体的文件操作在读写时会详细涉及。

#### 现在到了具体的打开文件的处理流程了。

总体的流程大概和前面的open类似。在syscall进入了sysfile_read。在这里首先先file_testfd，看看这个file等是不是可以正常使用。然后分配一个大小为4096的缓冲区供读文件使用。这里的意思是每次最多只能读取一个page大小的内容，然后如果这个文件比4096大那么分批多次读取。文件的需要读取长度是len，文件到每次操作为止实际读取的长度是alen。然后进入到file_read函数。先通过fd2file拿到fd索引的file（也就是我们要读取的文件）。根据读取的长度声明对应的buffer结构体之后，又进入vop环节。这回直接跳转到了sfs的sfs_read函数。从sfs_read进入sfs_io，写入位置为0，意思是正在读。接着又得到文件的信息sfs和索引节点的信息sin。对sin的信号量进行操作，防止在读时这个索引被人修改。在一切准备工作完毕后，调用sfs_io_nolock，也就是ex1由本组的一位大佬完成的填空的部分了：


```c
static int
sfs_io_nolock(struct sfs_fs *sfs, struct sfs_inode *sin, void *buf, off_t offset, size_t *alenp, bool write) {
    struct sfs_disk_inode *din = sin->din;
    assert(din->type != SFS_TYPE_DIR);
    off_t endpos = offset + *alenp, blkoff;
    *alenp = 0;
	// calculate the Rd/Wr end position
    if (offset < 0 || offset >= SFS_MAX_FILE_SIZE || offset > endpos) {
        return -E_INVAL;
    }
    if (offset == endpos) {
        return 0;
    }
    if (endpos > SFS_MAX_FILE_SIZE) {
        endpos = SFS_MAX_FILE_SIZE;
    }
    if (!write) {
        if (offset >= din->size) {
            return 0;
        }
        if (endpos > din->size) {
            endpos = din->size;
        }
    }

    int (*sfs_buf_op)(struct sfs_fs *sfs, void *buf, size_t len, uint32_t blkno, off_t offset);
    int (*sfs_block_op)(struct sfs_fs *sfs, void *buf, uint32_t blkno, uint32_t nblks);
    if (write) {
        sfs_buf_op = sfs_wbuf, sfs_block_op = sfs_wblock;
    }
    else {
        sfs_buf_op = sfs_rbuf, sfs_block_op = sfs_rblock;
    }

    int ret = 0;
    size_t size, alen = 0;
    uint32_t ino;
    uint32_t blkno = offset / SFS_BLKSIZE;          // The NO. of Rd/Wr begin block
    uint32_t nblks = endpos / SFS_BLKSIZE - blkno;  // The size of Rd/Wr blocks

 
  // (1)第一部分，用offset % SFS_BLKSIZE判断是否对齐，
  // 若没有对齐，则需要特殊处理，首先通过sfs_bmap_load_nolock找到这一块的inode，然后将这部分数据读出。
    if ((blkoff = offset % SFS_BLKSIZE) != 0) {
        size = (nblks != 0) ? (SFS_BLKSIZE - blkoff) : (endpos - offset);
        if ((ret = sfs_bmap_load_nolock(sfs, sin, blkno, &ino)) != 0) {
            goto out;
        }
        if ((ret = sfs_buf_op(sfs, buf, size, ino, blkoff)) != 0) {
            goto out;
        }

        alen += size;
        buf += size;

        if (nblks == 0) {
            goto out;
        }

        blkno++;
        nblks--;
    }

    if (nblks > 0) {
        if ((ret = sfs_bmap_load_nolock(sfs, sin, blkno, &ino)) != 0) {
            goto out;
        }
        if ((ret = sfs_block_op(sfs, buf, ino, nblks)) != 0) {
            goto out;
        }

        alen += nblks * SFS_BLKSIZE;
        buf += nblks * SFS_BLKSIZE;
        blkno += nblks;
        nblks -= nblks;
    }
    if ((size = endpos % SFS_BLKSIZE) != 0) {
        if ((ret = sfs_bmap_load_nolock(sfs, sin, blkno, &ino)) != 0) {
            goto out;
        }
        if ((ret = sfs_buf_op(sfs, buf, size, ino, 0)) != 0) {
            goto out;
        }
        alen += size;
    }
out:
    *alenp = alen;
    if (offset + alen > sin->din->size) {
        sin->din->size = offset + alen;
        sin->dirty = 1;
    }
    return ret;
}

```

让我们来看看这里做了什么：

- 1、首先明确：offset是上一轮读取结束的为止，alenp是现在需要读取的长度。在这里首先得进行一些是否越界的判断。然后就会引入两个变量，blkno和nblks。它们是作用在sin的direct上的。这时候再回过头看一开始描述的那一段sfs_disk_inode的direct的问题了。现在的blkno和nblks就是根据文件长度和块的大小的对应关系求出来的direct的下标，用来返回一个sfs_disk_inode结点索引的具体数据块。

- 2、读取时，首先要对上一次读取的块是否读取完进行判断。如果offset 不能整除 SFS_BLKSIZE，则得到的余数是上一个被读取的块被读取了多少。拿SFS_BLKSIZE减去这个余数就是上一个块还剩多少需要被读取。

```c
size = (nblks != 0) ? (SFS_BLKSIZE - blkoff) : (endpos - offset);
```
就可以理解了：如果这一轮需要开始读取的块是当前inode索引的第一个块，那么说明上次出现了一些情况导致只读取了这个块的一部分，于是这次要读取的大小就是这个块的剩余部分endpos - offset。如果当前块不是第一个，那么就首先得把上一个块的剩下这么多SFS_BLKSIZE - blkoff数据给读出来。这部分会通过sfs_bmap_load_nolock进入sfs_bmap_get_nolock。这里又有两个类了，一是之前提到过的direct数组中，直接挂在当前inode下的12个具体的数据块，另一个是挂在indirect下的12个索引块。如果现在要取的下标是在12个直接索引块里面，那么直接就看，如果这个块不存在且允许create，那么就在对应的下标处alloc一个，如果存在那可以直接返回回去了。

如果是在indirect里面，那么调用sfs_bmap_get_sub_nolock再找。这里也是在干一些比较相似的事情，时间有限就不在深入了。总之是找到这个indirect的索引块索引的数据库。突然在想如果没有更精妙的递归实现方式的话，文件大小一旦增加，那么是不是就得有很多sfs_bmap_get_sub_nolock、sfs_bmap_get_sub_sub_nolock、sfs_bmap_get_sub_sub_sub_nolock……。再取到数据后，调用sfs_block_op，这里现在在读取，于是sfs_block_op函数就会对应到sfs_rwblock，把需要的东西写入buf缓存中。后面的操作也类似，如果有出现跨块的情况那么就把多出来的部分再次调用sfs_bmap_load_nolock和sfs_block_op的组合把数据写入buffer中。

- 3、这里还得介绍一下sfs与具体设备的联系。刚刚的sfs_rwblock会进入到sfs_rwblock_nolock。它回创建一个io缓冲iobuf，然后使用dop_io的宏。这个宏是定义在设备头文件里的，也就是说现在正式开始进入设备层，与磁盘设备开始交互。这里是要调用刚刚一直传下来的sfs里的设备--磁盘进行d_io操作了。

我们找到磁盘设备的初始化函数：

```c
static void
disk0_device_init(struct device *dev) {
    ......
	dev->d_io = disk0_io;
	.......
}

```
于是确定了d_io接下来要去到disk0_io了。再disk0_io里，我们读文件会通过disk0_read_blks_nolock和iobuf_move的组合把数据读取到buffer里面。最终传回到sfs层。


sfs_io_nolock结束后，调用iobuf_skip跳过刚刚读取的字节的长度的数据。这里暂时没搞清楚是干什么的。至此，读取流程完毕，读取到的数据已经被直接改写再buffer里。






















## 练习2: 完成基于文件系统的执行程序机制的实现（需要编码）
改写proc.c中的load_icode函数和其他相关函数，实现基于文件系统的执行程序机制。执行：make qemu。如果能看看到sh用户程序的执行界面，则基本成功了。如果在sh用户界面上可以执行”ls”,”hello”等其他放置在sfs文件系统中的其他执行程序，则可以认为本实验基本成功。

在 proc.c 中，我们需要先先初始化 fs 中的进程控制结构，也就是得操作一下 alloc_proc 函数

需要加的就是这一句：
```proc->filesp = NULL;```
这是因为一个文件需要在 VFS 中变为一个进程才能被执行。

至于说注释里还有一些关于lab6的操作，其实不用管，因为注释里也说了，加的那些东西只有lab6会用，所以不用管，直接在lab5的基础上做就行。

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
     * MACROs or Functions:
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
    for (phnum = 0; phnum < elf->e_phnum; phnum ++) {
        off_t phoff = elf->e_phoff + sizeof(struct proghdr) * phnum;
        if ((ret = load_icode_read(fd, ph, sizeof(struct proghdr), phoff)) != 0) {
            goto bad_cleanup_mmap;
        }
        //(3.4) find every program section headers
        if (ph->p_type != ELF_PT_LOAD) {
            continue ;
        }
        if (ph->p_filesz > ph->p_memsz) {
            ret = -E_INVAL_ELF;
            goto bad_cleanup_mmap;
        }
        if (ph->p_filesz == 0) {
            continue ;
            // do nothing here since static variables may not occupy any space
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
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL) {
                ret = -E_NO_MEM;
                goto bad_cleanup_mmap;
            }
            off = start - la, size = PGSIZE - off, la += PGSIZE;
            if (end < la) {
                size -= la - end;
            }
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

    uintptr_t stacktop = USTACKTOP - (argv_size/sizeof(long)+1)*sizeof(long);
    char** uargv=(char **)(stacktop  - argc * sizeof(char *));
    
    argv_size = 0;
    for (i = 0; i < argc; i ++) {
        uargv[i] = strcpy((char *)(stacktop + argv_size ), kargv[i]);
        argv_size +=  strnlen(kargv[i],EXEC_MAX_ARG_LEN + 1)+1;
    }
    
    stacktop = (uintptr_t)uargv - sizeof(int);
    *(int *)stacktop = argc;
    
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

- 1、建立内存管理器，创建一个新的mm（内存管理）结构体来管理当前进程的内存。

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
## 扩展练习 Challenge1：完成基于“UNIX的PIPE机制”的设计方案
如果要在ucore里加入UNIX的管道（Pipe）机制，至少需要定义哪些数据结构和接口？（接口给出语义即可，不必具体实现。数据结构的设计应当给出一个（或多个）具体的C语言struct定义。在网络上查找相关的Linux资料和实现，请在实验报告中给出设计实现”UNIX的PIPE机制“的概要设方案，你的设计应当体现出对可能出现的同步互斥问题的处理。）

为了实现 UNIX 的 PIPE 机制，可以考虑在磁盘上保留一部分空间或者是一个特定的文件来作为 pipe 机制的缓冲区，接下来将说明如何完成对 pipe 机制的支持：
下面是一个基本的设计方案：

### 定义管道数据结构
为了实现管道机制，需要在内核中定义一个管道数据结构来存储进程间传输的数据。该数据结构包括两个缓冲区，一个输入缓冲区和一个输出缓冲区。每个缓冲区都由一个首指针和一个尾指针组成，以便进行读写操作。

### 管道创建与销毁
当进程A需要向进程B发送数据时，它可以调用pipe()系统调用，该调用将创建一个新的管道，并返回一个文件描述符（fd）。进程A将使用该fd来写入数据到输出缓冲区中。进程B将使用相同的fd从输入缓冲区中读取数据。

当不再需要管道时，进程可以使用close()系统调用来关闭读或写端口。当所有相关的fd都被关闭时，管道将被销毁。

### 管道读写操作
进程使用read()系统调用从输入缓冲区中读取数据，并使用write()系统调用将数据写入输出缓冲区中。

如果输入缓冲区为空，则调用read()会被阻塞，直到数据可用为止。同样，如果输出缓冲区已满，则调用write()也会被阻塞，直到有足够的空间可用为止。

### 管道进程同步
由于管道是共享的，因此可能需要使用信号量或互斥锁等机制来保证多个进程之间的同步。例如，当一个进程向管道中写入数据时，应该确保在另一个进程读取数据之前，该数据不会被覆盖或修改。

### 虚拟文件系统实现
为了兼容UNIX的标准I/O接口，可以在虚拟文件系统（VFS）中实现管道机制。这样，管道就可以像其他文件一样使用标准的I/O函数进行读写操作。

在VFS中，每个管道都可以被表示为一个特殊的文件类型，比如“FIFO”文件。当进程打开FIFO文件时，将创建一个新的fd，并将该fd与管道相关联。然后，进程就可以使用标准的I/O函数进行读写操作了。

## 扩展练习 Challenge2：完成基于“UNIX的软连接和硬连接机制”的设计方案
如果要在ucore里加入UNIX的软连接和硬连接机制，至少需要定义哪些数据结构和接口？（接口给出语义即可，不必具体实现。数据结构的设计应当给出一个(或多个）具体的C语言struct定义。在网络上查找相关的Linux资料和实现，请在实验报告中给出设计实现”UNIX的软连接和硬连接机制“的概要设方案，你的设计应当体现出对可能出现的同步互斥问题的处理。）

需要定义以下数据结构和接口：

### 数据结构：
    inode：表示文件的元数据，包括文件类型、大小、权限等信息。
    file：表示打开的文件，包括指向inode的指针、读写偏移量等信息。
### 接口：
    int link(const char *oldpath, const char *newpath)：创建一个硬链接，将oldpath指向的文件与newpath指向的文件名关联起来。这个接口会在目标文件夹的控制块中增加一个描述符，并且两个描述符的inode指针相同，同时nlinks数据结构应该相应增加。
    int symlink(const char *target, const char *linkpath)：创建一个软链接，将target指向的地址与linkpath指向的文件名关联起来。这个接口会在文件目录中创建一个特殊的文件，其中包含指向target的地址信息。
    int readlink(const char *pathname, char *buf, size_t bufsiz)：读取软链接文件的内容，将软链接指向的地址信息放入buf中。
    int unlink(const char *pathname)：删除一个链接，如果是硬链接，减少相关nlinks数据结构的计数；如果是软链接，直接删除软链接文件。
对于可能出现的同步互斥问题，可以使用信号量或互斥锁等机制来确保多个进程对链接的访问是同步的，防止并发引起的数据不一致问题。比如，在创建硬链接或软链接时，可以使用互斥锁来保护相关数据结构的访问，确保一次只有一个进程在修改链接信息。在对链接进行删除操作时，也需要考虑并发情况下的同步问题，避免资源泄漏或数据一致性问题。