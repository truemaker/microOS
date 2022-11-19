#include "types.h"
#include "functions.h"
#include "vga.cpp"
#include "idt.cpp"
#include "task.cpp"

void test() {
    print_string("Hello from second task!");
    /*uint32_t esp = 0;
    __asm__ __volatile__("movl %%esp, %0":"=m"(esp)::"%eax");*/
    yield();
}

extern "C" void exception_handler(void) {
    print_string("Something went wrong!");
    for (;;);
}

extern "C" void main() {
    print_string("Hello from kernel!");
    idt_init();
    current_task = &mainTask;
    Task* secondTask = createTask(test);
    yield();
    for (;;);
}