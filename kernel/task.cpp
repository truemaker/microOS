#include "types.h"
uint32_t stack = 0x200000;
uint32_t get_new_stack() {
    stack = stack + 0x2000; // 1 KB Stack
    return stack;
}

uint32_t latest_task = 0x100000;
Task* createTask(void(*func)()) {
    uint32_t taskStack = get_new_stack();
    Stack* tStack = (Stack*)taskStack-sizeof(Stack);
    tStack->edi = 0;
    tStack->esi = 0;
    tStack->ebp = taskStack;
    tStack->esp = taskStack-(4*4);
    tStack->edx = 0;
    tStack->ecx = 0;
    tStack->ebx = 0;
    tStack->eax = 0;
    tStack->eip = (uint32_t)func;
    __asm__ __volatile__("pushfl; movl (%%esp), %%eax; movl %%eax, %0; popfl;":"=m"(tStack->eflags)::"%eax");
    latest_task = latest_task + sizeof(Task);
    Task* task = (Task*)(latest_task-sizeof(Task));
    task->esp = (uint32_t)tStack;
    task->next = mainTask.next;
    mainTask.next = task;
    return task;
}

void yield() {
    print_string("Yield");
    Task* previous = current_task;
    current_task = current_task->next;
    switch_context(&previous->esp, current_task->esp);
}