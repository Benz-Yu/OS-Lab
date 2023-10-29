# lab 3


### **练习一**

描述FIFO页面置换算法下，一个页面从被换入到被换出的过程中，会经过代码里哪些函数/宏的处理（或者说，需要调用哪些函数/宏），并用简单的一两句话描述每个函数在过程中做了什么？（为了方便同学们完成练习，所以实际上我们的项目代码和实验指导的还是略有不同，例如我们将FIFO页面置换算法头文件的大部分代码放在了kern/mm/swap_fifo.c文件中，这点请同学们注意）

至少正确指出10个不同的函数分别做了什么？如果少于10个将酌情给分。我们认为只要函数原型不同，就算两个不同的函数。要求指出对执行过程有实际影响,删去后会导致输出结果不同的函数（例如assert）而不是cprintf这样的函数。如果你选择的函数不能完整地体现”从换入到换出“的过程，比如10个函数都是页面换入的时候调用的，或者解释功能的时候只解释了这10个函数在页面换入时的功能，那么也会扣除一定的分数


**FIFO页面替换算法**

所谓FIFO(First in, First out)页面置换算法，相当简单，就是把所有页面排在一个队列里，每次换入页面的时候，把队列里最靠前（最早被换入）的页面置换出去。

### ***算法设计中的函数***


### **swap_in()函数**

在文件kern/mm/swap.c中定义swap_in函数
``` int swap_in(struct mm_struct *mm, uintptr_t addr, struct Page **ptr_result)
{
     struct Page *result = alloc_page();//这里alloc_page()内部可能调用swap_out()
     //找到对应的一个物理页面
     assert(result!=NULL);

     pte_t *ptep = get_pte(mm->pgdir, addr, 0);//找到/构建对应的页表项
	//将物理地址映射到虚拟地址是在swap_in()退出之后，调用page_insert()完成的
     int r;
     if ((r = swapfs_read((*ptep), result)) != 0)//将数据从硬盘读到内存
     {
        assert(r!=0);
     }
     cprintf("swap_in: load disk swap entry %d with swap_page in vadr 0x%x\n", (*ptep)>>8, addr);
     *ptr_result=result;
     return 0;
}
```
mm:表示当前PDT的管理结构体

addr:表示需要换入的虚拟地址

ptr_result：表示指向换入的页面的结果指针

函数首先分配一个页面存储需要从磁盘换入的页，如果没有多余空间分配可能会需要先换出一页，然后找到或构建虚拟地址addr对应的页表项，最后将数据从硬盘读取到之前分配的页面。

其中，调用的比较重要的函数有swapfs_read()、get_pte()、alloc_page()。

### **swapfs_read()函数：**

```
swapfs_read(swap_entry_t entry, struct Page *page) {
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
}
```
函数调用ide_read_secs()函数来实现将磁盘中的页面换入内存，其中换入的页面需要通过page2kva转换为虚拟地址。

### **ide_read_secs()函数：**

```
int ide_read_secs(unsigned short ideno, uint32_t secno, void *dst,
                  size_t nsecs) {
    int iobase = secno * SECTSIZE;
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
    return 0;
}
```
函数的作用是用于从磁盘读取数据。具体来说，它根据传入的扇区号（secno）和扇区数量（nsecs）来确定从磁盘的哪个位置开始读取数据，并将这些数据复制到目标内存区域（dst）中。

### **get_pte()函数：**
```C
 pde_t *pdep1 = &pgdir[PDX1(la)];//找到对应的Giga Page
    if (!(*pdep1 & PTE_V)) {//如果下一级页表不存在，那就给它分配一页，创造新页表
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
        //我们现在在虚拟地址空间中，所以要转化为KADDR再memset.
        //不管页表怎么构造，我们确保物理地址和虚拟地址的偏移量始终相同，那么就可以用这种方式完成对物理内存的访问。
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);//注意这里R,W,X全零
    }
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];//再下一级页表
    //这里的逻辑和前面完全一致，页表不存在就现在分配一个
    if (!(*pdep0 & PTE_V)) {
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
                return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
        *pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
    }
    //找到输入的虚拟地址la对应的页表项的地址(可能是刚刚分配的)
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
}
```
函数的作用是找到虚拟地址对应的页表项的地址，如果不存在就分配一个。函数首先找到虚拟地址对应的Giga Page，如果下一级页表不存在，就为其分配一页，创建新的页表，然后类似的，寻找再下一级页表，如果不存在就进行分配，最后返回找到的虚拟地址对应的页表项的地址。

### **page2pa()函数：**

```
/*
指向某个Page结构体的指针，对应一个物理页面，也对应一个起始的物理地址。
左移若干位就可以从物理页号得到页面的起始物理地址。
*/
static inline uintptr_t page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT; 
}
```


### **alloc_page()函数：**


```C
  #define alloc_page() alloc_pages(1)
```

alloc_page()在这里经宏扩展为allow_pages(1)，意为分配一页

```C
struct Page *alloc_pages(size_t n) {
    struct Page *page = NULL;
    bool intr_flag;

    while (1) {
        local_intr_save(intr_flag);
        { page = pmm_manager->alloc_pages(n); }
        local_intr_restore(intr_flag);
		//如果有足够的物理页面，就不必换出其他页面
        //如果n>1, 说明希望分配多个连续的页面，但是我们换出页面的时候并不能换出连续的页面
 		//swap_init_ok标志是否成功初始化了
        if (page != NULL || n > 1 || swap_init_ok == 0) break;

        extern struct mm_struct *check_mm_struct;
        swap_out(check_mm_struct, n, 0);//调用页面置换的”换出页面“接口。这里必有n=1
    }
    return page;
}
}
```
函数的作用是分配指定数量的页面，函数首先保存中断状态，然后尝试分配页面，如果没有足够多的页面就需要先换出一页再尝试分配，直到成功分配为止。

其中，调用的比较重要的函数有swap_out()

### **swap_out()函数：**
```C
  int swap_out(struct mm_struct *mm, int n, int in_tick)
{
     int i;
     for (i = 0; i != n; ++ i)
     {
          uintptr_t v;
          struct Page *page;
          int r = sm->swap_out_victim(mm, &page, in_tick);//调用页面置换算法的接口
          //r=0表示成功找到了可以换出去的页面
         //要换出去的物理页面存在page里
          if (r != 0) {
                  cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
                  break;
          }
         
          cprintf("SWAP: choose victim page 0x%08x\n", page);

          v=page->pra_vaddr;//可以获取物理页面对应的虚拟地址
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
          assert((*ptep & PTE_V) != 0);

          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
              		//尝试把要换出的物理页面写到硬盘上的交换区，返回值不为0说明失败了
                    cprintf("SWAP: failed to save\n");
                    sm->map_swappable(mm, v, page, 0);
                    continue;
          }
          else {
              //成功换出
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
                    free_page(page);
          }
		  //由于页表改变了，需要刷新TLB
          //思考： swap_in()的时候插入新的页表项之后在哪里刷新了TLB?
          tlb_invalidate(mm->pgdir, v);
     }
     return i;
}
```
 函数的作用是按照页面置换算法换出指定数量的页面，函数首先调用页面置换算法找到可以换出的页面，然后调用get_pte()找到页面对应的页表项指针，确保要换出的页面已经映射到物理地址，即在内存中。然后尝试将页面写入硬盘上的交换区，如果成功写入，就将页表项重新映射到硬盘交换区，然后将页面的内存释放，换出完成后需要刷新TLB。

 其中调用的比较重要的函数是swap_out_victim()、map_swappable()、free_page()

### *swap_out_victim()函数：*

```c
static int _fifo_swap_out_victim(struct mm_struct *mm, struct Page **ptr_page, int in_tick)
{
    list_entry_t *head = (list_entry_t *)mm->sm_priv;
    assert(head != NULL);
    assert(in_tick == 0);
    
    
    // (1) 从 pra_list_head 队列中取出最早到达的页面
    // (2) 将该页面的地址设置为 ptr_page

    list_entry_t *entry = list_prev(head); // 获取队列中最后一个页面的前一个页面
    if (entry != head) { // 如果队列不为空
        list_del(entry); // 从队列中移除该页面
        *ptr_page = le2page(entry, pra_page_link); // 将页面地址设置为 ptr_page
    } else {
        *ptr_page = NULL; // 如果队列为空，表示没有可供换出的页面
    }
    return 0; 
}
```
在FIFO页面置换算法中，swap_out_victim()函数经宏扩展为_fifo_swap_out_victim()函数，函数的作用是从算法维护的队列中找到最早进入的页面作为换出的目标。
### *map_swappable()函数：*

```c
   // (3) _fifo_map_swappable: 根据FIFO页面置换算法，我们应该将最近到达的页面链接到 pra_list_head 链表的末尾。
static int _fifo_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in)
{
    // 获取指向页面置换算法的链表头的指针
    list_entry_t *head = (list_entry_t*) mm->sm_priv;

    // 获取页面的链接信息
    list_entry_t *entry = &(page->pra_page_link);

    // 确保 entry 和 head 非空
    assert(entry != NULL && head != NULL);

    // 记录页面的访问情况

    // (1) 将最近到达的页面链接到 pra_list_head 链表的末尾。
    list_add(head, entry);

    return 0;
}
```
函数的作用是将最近到达的页面链接到队列的末尾，对页面进行管理。
### *free_page()函数：*

```c
   #define free_page(page) free_pages(page, 1)
```
free_page()函数首先经宏扩展为free_pages(page, 1)，表示释放一页

```c
 void free_pages(struct Page *base, size_t n) {
    bool intr_flag;

    local_intr_save(intr_flag);
    { pmm_manager->free_pages(base, n); }
    local_intr_restore(intr_flag);
}
```
函数的作用是释放指定数量的页面，释放时需要先保存中断状态，然后尝试释放页面，最后恢复中断状态


## 练习2：深入理解不同分页模式的工作原理（思考题）

get_pte()函数（位于kern/mm/pmm.c）用于在页表中查找或创建页表项，从而实现对指定线性地址对应的物理页的访问和映射操作。这在操作系统中的分页机制下，是实现虚拟内存与物理内存之间映射关系非常重要的内容。

get_pte()函数中有两段形式类似的代码， 结合sv32，sv39，sv48的异同，解释这两段代码为什么如此相像。

目前get_pte()函数将页表项的查找和页表项的分配合并在一个函数里，你认为这种写法好吗？有没有必要把两个功能拆开？

### **get_pte()函数：**
```C
 pde_t *pdep1 = &pgdir[PDX1(la)];//找到对应的Giga Page
    if (!(*pdep1 & PTE_V)) {//如果下一级页表不存在，那就给它分配一页，创造新页表
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
        //我们现在在虚拟地址空间中，所以要转化为KADDR再memset.
        //不管页表怎么构造，我们确保物理地址和虚拟地址的偏移量始终相同，那么就可以用这种方式完成对物理内存的访问。
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);//注意这里R,W,X全零
    }
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];//再下一级页表
    //这里的逻辑和前面完全一致，页表不存在就现在分配一个
    if (!(*pdep0 & PTE_V)) {
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
                return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
        *pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
    }
    //找到输入的虚拟地址la对应的页表项的地址(可能是刚刚分配的)
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
}
```

### *get_pte()函数中有两段形式类似的代码， 结合sv32，sv39，sv48的异同，解释这两段代码为什么如此相像。*

sv32、sv39、sv48的差别为分别使用了两级、三级和四级页表，而共同点为每级页表采用了相同的页表项结构，在这里，两段代码如此相像的原因就是两段代码分别负责分配两级页表，而这两级页表项的结构是相同的。

### *目前get_pte()函数将页表项的查找和页表项的分配合并在一个函数里，你认为这种写法好吗？有没有必要把两个功能拆开？*

没有必要把两个功能拆开，因为如果能够成功查找到页表项，合并在一起不会影响性能，而如果查找不到页表项需要进行分配，合并可以降低代码的复杂性。

## 练习3：给未被映射的地址映射上物理页（需要编程）
补充完成do_pgfault（mm/vmm.c）函数，给未被映射的地址映射上物理页。设置访问权限 的时候需要参考页面所在 VMA 的权限，同时需要注意映射物理页时需要操作内存控制 结构所指定的页表，而不是内核的页表。 请在实验报告中简要说明你的设计实现过程。请回答如下问题：

### **do_pgfault()函数：**

```
int do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
    int ret = -E_INVAL;
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);

    pgfault_num++;
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr) {
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
        goto failed;
    }

    /* IF (write an existed addr ) OR
     *    (write an non_existed addr && addr is writable) OR
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
    if (vma->vm_flags & VM_WRITE) {
        perm |= (PTE_R | PTE_W);
    }
    addr = ROUNDDOWN(addr, PGSIZE);

    ret = -E_NO_MEM;

    pte_t *ptep=NULL;
    /*
    * Maybe you want help comment, BELOW comments can help you finish the code
    *
    * Some Useful MACROs and DEFINEs, you can use them in below implementation.
    * MACROs or Functions:
    *   get_pte : get an pte and return the kernel virtual address of this pte for la
    *             if the PT contians this pte didn't exist, alloc a page for PT (notice the 3th parameter '1')
    *   pgdir_alloc_page : call alloc_page & page_insert functions to allocate a page size memory & setup
    *             an addr map pa<--->la with linear address la and the PDT pgdir
    * DEFINES:
    *   VM_WRITE  : If vma->vm_flags & VM_WRITE == 1/0, then the vma is writable/non writable
    *   PTE_W           0x002                   // page table/directory entry flags bit : Writeable
    *   PTE_U           0x004                   // page table/directory entry flags bit : User can access
    * VARIABLES:
    *   mm->pgdir : the PDT of these vma
    *
    */


    ptep = get_pte(mm->pgdir, addr, 1);  //(1) try to find a pte, if pte's
                                         //PT(Page Table) isn't existed, then
                                         //create a PT.
    if (*ptep == 0) {
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
            goto failed;
        }
    } else {
        /*LAB3 EXERCISE 3: 2113870 2113683 1910109
        * 请你根据以下信息提示，补充函数
        * 现在我们认为pte是一个交换条目，那我们应该从磁盘加载数据并放到带有phy addr的页面，
        * 并将phy addr与逻辑addr映射，触发交换管理器记录该页面的访问情况
        *
        *  一些有用的宏和定义，可能会对你接下来代码的编写产生帮助(显然是有帮助的)
        *  宏或函数:
        *    swap_in(mm, addr, &page) : 分配一个内存页，然后根据
        *    PTE中的swap条目的addr，找到磁盘页的地址，将磁盘页的内容读入这个内存页
        *    page_insert ： 建立一个Page的phy addr与线性addr la的映射
        *    swap_map_swappable ： 设置页面可交换
        */
        if (swap_init_ok) {
            struct Page *page = NULL;
            // 你要编写的内容在这里，请基于上文说明以及下文的英文注释完成代码编写
            //(1）According to the mm AND addr, try
            //to load the content of right disk page
            //into the memory which page managed.
            //(2) According to the mm,
            //addr AND page, setup the
            //map of phy addr <--->
            //logical addr
            //(3) make the page swappable.

            // (1) 根据 mm 和 addr，尝试将正确磁盘页的内容加载到由页面管理的内存中。
            if ((ret = swap_in(mm, addr, &page)) != 0) {
                cprintf("swap_in in do_pgfault failed\n");
                goto failed;
            }  
            // (2) 根据 mm、addr 和页面设置物理地址 <--> 逻辑地址的映射  
            // 使用page_insert函数将页面映射到mm->pgdir中
            page_insert(mm->pgdir, page, addr, perm);
            // (3) 使页面可交换
            swap_map_swappable(mm, addr, page, 1);
            // 设置页面的pra_vaddr属性为addr，记录页面所属的虚拟地址
            page->pra_vaddr = addr;
        } else {
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
            goto failed;
        }
   }

   ret = 0;
failed:
    return ret;
}


```
### *请描述页目录项（Page Directory Entry）和页表项（Page Table Entry）中组成部分对ucore实现页替换算法的潜在用处。*

页表项中的Present Bit可用于指示该页是否在物理内存中，是实现缺页中断的基础

R/W和U/S Bit可以指示该页的访问权限，让页替换算法可以区分不能调出的内核代码和可以调出的应用程序代码、数据页

A和D bit指示该页是否被访问过以及是否被写过，可以帮助实现extended clock页替换算法等更复杂有效的页替换算法

9-11个bit可供系统利用来记录额外信息

### *如果ucore的缺页服务例程在执行过程中访问内存，出现了页访问异常，请问硬件要做哪些事情？*

缺页服务例程在执行过程中访问内存，出现了页访问异常，首先需要触发一个page fault异常，然后按照正常处理异常的流程保存上下文等，形成嵌套中断。

### *数据结构Page的全局变量（其实是一个数组）的每一项与页表中的页目录项和页表项有无对应关系？如果有，其对应关系是啥？*

```
static inline struct Page *pa2page(uintptr_t pa) {
    if (PPN(pa) >= npage) {
        panic("pa2page called with invalid pa");
    }
    return &pages[PPN(pa) - nbase];//把pages指针当作数组使用
}

static inline struct Page *pte2page(pte_t pte) {
    if (!(pte & PTE_V)) {
        panic("pte2page called with invalid pte");
    }
    return pa2page(PTE_ADDR(pte));
}
//PDE(Page Directory Entry)指的是不在叶节点的页表项（指向低一级页表的页表项）
static inline struct Page *pde2page(pde_t pde) { //PDE_ADDR这个宏和PTE_ADDR是一样的
    return pa2page(PDE_ADDR(pde));
}
```

由代码可知，存在对应关系，因为页目录项和页表项都有对应的物理页面，每个物理页面都有负责管理页面的Page结构体，也就是数组中的一项，也就是说其对应关系是一一对应。
## 练习4：补充完成Clock页替换算法（需要编程）

通过之前的练习，相信大家对FIFO的页面替换算法有了更深入的了解，现在请在我们给出的框架上，填写代码，实现 Clock页替换算法（mm/swap_clock.c）。 请在实验报告中简要说明你的设计实现过程。请回答如下问题：

比较Clock页替换算法和FIFO算法的不同。
### **实现Clock替换算法**

### *_clock_init_mm()函数*
```
static int
_clock_init_mm(struct mm_struct *mm)
{     
     /*LAB3 EXERCISE 4: 2113870 2113683 1910109*/ 
     // 初始化pra_list_head为空链表
     // 初始化当前指针curr_ptr指向pra_list_head，表示当前页面替换位置为链表头
     // 将mm的私有成员指针指向pra_list_head，用于后续的页面替换算法操作
     //cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
     list_init(&pra_list_head);
     curr_ptr = &pra_list_head;
     mm->sm_priv = &pra_list_head;
     return 0;
}
```
和FIFO算法相同，多了一个初始化clock指针。

### *_clock_map_swappable()函数*
```
static int
_clock_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in)
{
    list_entry_t *entry=&(page->pra_page_link);
 
    assert(entry != NULL && curr_ptr != NULL);
    //record the page access situlation
    /*LAB3 EXERCISE 4: 2113870 2113683 1910109*/ 
    // link the most recent arrival page at the back of the pra_list_head qeueue.
    // 将页面page插入到页面链表pra_list_head的末尾
    // 将页面的visited标志置为1，表示该页面已被访问
    list_add(curr_ptr, entry);
    page->visited = 1;
    return 0;
}
```
比FIFO算法多维护了visited位，用于换出页面。


### *_clock_map_swappable()函数*
```
static int
_clock_swap_out_victim(struct mm_struct *mm, struct Page ** ptr_page, int in_tick)
{
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
         assert(head != NULL);
     assert(in_tick==0);
     /* Select the victim */
     //(1)  unlink the  earliest arrival page in front of pra_list_head qeueue
     //(2)  set the addr of addr of this page to ptr_page
    while (1) {
        /*LAB3 EXERCISE 4: 2113870 2113683 1910109*/ 
        // 编写代码
        // 遍历页面链表pra_list_head，查找最早未被访问的页面
        // 获取当前页面对应的Page结构指针
        // 如果当前页面未被访问，则将该页面从页面链表中删除，并将该页面指针赋值给ptr_page作为换出页面
        // 如果当前页面已被访问，则将visited标志置为0，表示该页面已被重新访问

        // 遍历页面链表pra_list_head，查找最早未被访问的页面
        if (curr_ptr == head) {
            curr_ptr = list_prev(curr_ptr);
            continue;
        }
        cprintf("curr_ptr %p\n", curr_ptr);
        // 获取当前页面对应的Page结构指针
        struct Page* curr_page = le2page(curr_ptr, pra_page_link);
        // 如果当前页面未被访问，则将该页面从页面链表中删除，并将该页面指针赋值给ptr_page作为换出页面
        if (curr_page->visited == 0) {
            //(1)  unlink the  earliest arrival page in front of pra_list_head qeueue
            //(2)  set the addr of addr of this page to ptr_page
            curr_ptr = list_prev(curr_ptr);
            list_del(list_next(curr_ptr));
            *ptr_page = curr_page;
            return 0;
        } else {
            // 如果当前页面已被访问，则将visited标志置为0，表示该页面已被重新访问
            curr_page->visited = 0;
        }
    }
    return 0;
}
```
遍历页面链表pra_list_head，查找最早未被访问的页面，如果当前页面未被访问，则将该页面从页面链表中删除，并将该页面指针赋值给ptr_page作为换出页面，如果当前页面已被访问，则将visited标志置为0，表示该页面已被重新访问，然后继续按顺序进行遍历。

### **比较Clock页替换算法和FIFO算法的不同。**

Clock算法把页面页面组织成环形链表的形式，而FIFO算法把页面组织成队列。Clock算法比FIFO算法多维护一个指针，指向最老的那个页面。Clock算法在页表项中设置了一位访问位来表示此页表项对应的页当前是否被访问过，当该页被访问时，把访问位置1。在换出时，如果访问位为0，则淘汰该页，如果访问位为1，则将该页表项的此位置0，继续访问下一个页。Clock算法在本质上与 FIFO 算法是类似的，不同之处是在换出算法中跳过了访问位为 1 的页。

## 练习5：阅读代码和实现手册，理解页表映射方式相关知识（思考题）

### **如果我们采用”一个大页“ 的页表映射方式，相比分级页表，有什么好处、优势，有什么坏处、风险？**

如果我们采用”一个大页“ 的页表映射方式，相比分级页表的好处有：

1.减少了页表的级数，这可以加速虚拟地址到物理地址的转换，因为查找页表的级数较少。

2.采用大页表可以减少TLB缺失次数，因为更多的地址范围可以映射到一个TLB条目中。

3.大页表的管理比多级分页表更简单，减少了页表维护的开销。

坏处、风险有：

1.大页表需要更多的连续内存来存储页表结构。

2.如果一个进程只使用了部分大页，而整个大页都被分配给了它，那么将浪费掉未使用的部分内存。

3.页面替换的开销也会更大。
