#include "types.h"
struct IDTEntry32 {
    uint16_t base_low;
    uint16_t selector;        // a code segment selector in GDT or LDT
    uint8_t  zero;            // unused, set to 0
    uint8_t  type_attributes; // gate type, dpl, and p fields
    uint16_t base_high;
};

struct IDTDesciptor32
{
    uint16_t limit;
    uint32_t base;
};

extern void* isr_stub_table[];
static IDTEntry32 idt[256] __attribute__((aligned(0x10)));
static IDTDesciptor32 idtr;

void idt_set_descriptor(uint8_t vector, void* isr, uint8_t flags) {
    IDTEntry32* entry = &idt[vector];
    entry->base_low = (uint32_t)isr & 0xFFFF;
    entry->selector = 0x8;
    entry->type_attributes = flags;
    entry->base_high = (uint32_t)isr >> 16;
    entry->zero = 0;
}

void idt_init() {
    idtr.base = (uint32_t)&idt[0];
    idtr.limit = (uint16_t)sizeof(IDTEntry32) * 256 - 1;
 
    for (uint8_t vector = 0; vector < 32; vector++) {
        idt_set_descriptor(vector, isr_stub_table[vector], 0x8E);
    }
 
    __asm__ volatile ("lidt %0" : : "m"(idtr)); // load the new IDT
    //__asm__ volatile ("sti"); // set the interrupt flag
}