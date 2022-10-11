#include "types.h"
#include "functions.h"
#include "vga.cpp"
#include "task.cpp"

void test() {
    print_string("Hello from second task!");
    uint32_t esp = 0;
    __asm__ __volatile__("movl %%esp, %0":"=m"(esp)::"%eax");
    yield();
}

extern "C" void main() {
    print_string("Hello from kernel!");
    current_task = &mainTask;
    Task* secondTask = createTask(test);
    uint32_t esp = 0;
    __asm__ __volatile__("movl %%esp, %0":"=m"(mainTask.esp)::"%eax");
    yield();
    for (;;);
}