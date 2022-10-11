typedef unsigned char uint8_t;
typedef unsigned short uint16_t;
typedef unsigned int uint32_t;

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

extern "C" void main() {
    print_string("Hello from kernel!");
    for (;;);
}