// entry.S, 159
// entry points of interrupts

#include <spede/machine/asmacros.h>
#include "entry.h"

// set DS and ES to Kernel's data segment
#define SET_KERNEL_SEGS movw $(KERNEL_DATA), %ax; mov %ax, %ds; mov %ax, %es

.comm kernel_stack, KERNEL_STACK_SIZE, 1 // define kernel stack space
.text

// Loader loads trapframe of a process to CPU registers, to run it
ENTRY(LoadRun)
   movl 4(%esp), %eax   // load stack pointer from eax
   movl %eax, %esp
   popl %gs
   popl %fs
   popl %es
   popl %ds
   popa                 // restore general registers
   add $4, %esp         // skip 4 bytes that stored intr_id
   iret

// push intr type number then jump to common handler
ENTRY(TimerEntry)
   pushl $TIMER_INTR
   jmp CompleteTFenterKernel

//Phase 2 add 2 new entries : GetPidEntry, SleepEntry
ENTRY(GetPidEntry)
   pushl $GETPID_INTR
   jmp CompleteTFenterKernel

ENTRY(SleepEntry)
   pushl $SLEEP_INTR
   jmp CompleteTFenterKernel

//Phase 3 add 4 new entries :  StartProcEntry, SemGetEntry, SemWaitEntry, SemPostEntry
ENTRY(StartProcEntry)
   pushl $STARTPROC_INTR
   jmp CompleteTFenterKernel

ENTRY(SemGetEntry)
   pushl $SEMGET_INTR
   jmp CompleteTFenterKernel

ENTRY(SemWaitEntry)
   pushl $SEMWAIT_INTR
   jmp CompleteTFenterKernel

ENTRY(SemPostEntry)
   pushl $SEMPOST_INTR
   jmp CompleteTFenterKernel

//Phase 4 entries
ENTRY(MsgSndEntry)
   pushl $MSGSND_INTR
   jmp CompleteTFenterKernel

ENTRY(MsgRcvEntry)
   pushl $MSGRCV_INTR
   jmp CompleteTFenterKernel	

//phase 5 entry
ENTRY(IRQ7Entry)
   pushl $IRQ7_INTR
   jmp CompleteTFenterKernel

// save CPU context, call KernelMain()
CompleteTFenterKernel:
   pusha
   pushl %ds
   pushl %es
   pushl %fs
   pushl %gs
   movl %esp, %edx
   cld
   SET_KERNEL_SEGS      // set kernel data segments
   leal kernel_stack + KERNEL_STACK_SIZE, %esp
   pushl %edx
   call CNAME(KernelMain)

