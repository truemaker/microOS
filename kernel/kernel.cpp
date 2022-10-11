typedef unsigned char uint8_t;
typedef unsigned short uint16_t;
typedef unsigned int uint32_t;

extern "C" void switch_context(uint32_t* old_esp, uint32_t new_esp);

struct Task {
    uint32_t esp;
    bool running;
    Task* next;
};

Task mainTask;

struct Stack {
    uint32_t cr3;
    uint32_t eflags;
    uint32_t edi;
    uint32_t esi;
    uint32_t ebp;
    uint32_t esp;
    uint32_t edx;
    uint32_t ecx;
    uint32_t ebx;
    uint32_t eax;
    uint32_t base;
} __attribute__((packed));

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
    tStack->esp = taskStack-16;
    tStack->edx = 0;
    tStack->ecx = 0;
    tStack->ebx = 0;
    tStack->eax = 0;
    tStack->base = taskStack;
    __asm__ __volatile__("movl %%cr3, %%eax; movl %%eax, %0;":"=m"(tStack->cr3)::"%eax");
    __asm__ __volatile__("pushfl; movl (%%esp), %%eax; movl %%eax, %0; popfl;":"=m"(tStack->eflags)::"%eax");
    latest_task = latest_task + sizeof(Task);
    Task* task = (Task*)(latest_task-sizeof(Task));
    task->esp = (uint32_t)tStack;
    task->next = mainTask.next;
    mainTask.next = task;
    return task;
}

uint32_t vga_pos = 0;

void print_char(char c) {
    uint32_t index = vga_pos * 2;
    *(char*)(0xb8000 + index) = c;
    *(char*)(0xb8000 + index + 1) = 0x0f;
    vga_pos++;
}

void print_string(char* c) {
    char* str = c;
    while (*str != 0) {
        print_char(*str);
        str++;
    }
}

void print_string(const char* str) {
    print_string((char*)str);
}

void test() {
    print_string("Hello from second task!");
    uint32_t esp = 0;
    __asm__ __volatile__("movl %%esp, %%eax; movl %%eax, %0;":"=m"(esp)::"%eax");
    switch_context(&esp,mainTask.esp);
}

extern "C" void main() {
    print_string("Hello from kernel!");
    Task* secondTask = createTask(test);
    uint32_t esp = 0;
    __asm__ __volatile__("movl %%esp, %%eax; movl %%eax, %0;":"=m"(esp)::"%eax");
    switch_context(&esp,secondTask->esp);
    for (;;);
}