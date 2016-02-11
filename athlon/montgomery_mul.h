#define NMAX_ULONGS   8
#define ulong  unsigned long

void (*asm_mulmod)(ulong *,ulong *,ulong *);
void (*asm_squmod)(ulong *,ulong *);
void (*asm_add2)(ulong *,ulong *);
void (*asm_diff)(ulong *,ulong *,ulong *);
void (*asm_sub)(ulong *,ulong *,ulong *);
void (*asm_add2_ui)(ulong *,ulong);
void (*asm_zero)(ulong *);
void (*asm_copy)(ulong *,ulong *);
void (*asm_sub_n)(ulong *,ulong *);
void (*asm_half)(ulong *);
int (*asm_inv)(ulong *,ulong *);

void init_montgomery_multiplication();
int set_montgomery_multiplication(mpz_t);

