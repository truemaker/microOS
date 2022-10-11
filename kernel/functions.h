#pragma once
extern "C" void switch_context(uint32_t* old_esp, uint32_t new_esp);
void yield();