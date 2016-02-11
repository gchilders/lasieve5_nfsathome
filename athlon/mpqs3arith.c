static inline u32_t mpqs3_mod3(u32_t *a, u32_t n)
{
  u32_t res;

  __asm__ volatile ("xorl %%edx,%%edx\n"
       "movl 8(%%esi),%%eax\n"
       "divl %%ecx\n"
       "movl 4(%%esi),%%eax\n"
       "divl %%ecx\n"
       "movl (%%esi),%%eax\n"
       "divl %%ecx" : "=d" (res) : "c" (n), "S" (a) : "%eax" );
  return res;
}

