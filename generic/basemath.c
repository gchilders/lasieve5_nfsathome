

#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>

#include "gmp.h"
#include "siever-config.h"
#include "montgomery_mul.h"

extern ulong montgomery_inv_n;
extern ulong *montgomery_modulo_n;
extern ulong montgomery_modulo_R2[NMAX_ULONGS];
extern ulong montgomery_modulo_R4[NMAX_ULONGS];
extern ulong montgomery_ulongs;


int asm_cmp64(ulong *a, ulong *b) {
  if (a[0]!=b[0]) return 1;
  if (a[1]!=b[1]) return 1;
  return 0;
}


int asm_cmp(ulong *a, ulong *b)
{
  long i;

  for (i=0; i<montgomery_ulongs; i++) if (a[i]!=b[i]) return 1;
  return 0;
}


void gcd(ulong *gcd, ulong *a, ulong *b)
{
  ulong r[NMAX_ULONGS], bb[NMAX_ULONGS], aa[NMAX_ULONGS], shift, mask;
  long i;

  for (i=0; i<montgomery_ulongs; i++) if (a[i]) break;
  if (i>=montgomery_ulongs) { asm_copy(gcd,b); return; }
  for (i=0; i<montgomery_ulongs; i++) if (b[i]) break;
  if (i>=montgomery_ulongs) { asm_copy(gcd,a); return; }

#ifdef ULONG_HAS_32BIT
  shift=5;
#else
  shift=6;
#endif
  mask=(1UL<<shift)-1;

  asm_copy(bb,b); asm_copy(aa,a);
  while (!(bb[0]&1)) {
    for (i=0; i<montgomery_ulongs-1; i++) bb[i]=(bb[i]>>1)|(bb[i+1]<<mask);
    bb[montgomery_ulongs-1]>>=1;
  }
  while (!(aa[0]&1)) {
    for (i=0; i<montgomery_ulongs-1; i++) aa[i]=(aa[i]>>1)|(aa[i+1]<<mask);
    aa[montgomery_ulongs-1]>>=1;
  }
  while (1) {
    asm_diff(r,aa,bb);
    for (i=0; i<montgomery_ulongs; i++) if (r[i]) break;
    if (i>=montgomery_ulongs) break;
    while (!(r[0]&1)) {
      for (i=0; i<montgomery_ulongs-1; i++) r[i]=(r[i]>>1)|(r[i+1]<<mask);
      r[montgomery_ulongs-1]>>=1;
    }
    for (i=montgomery_ulongs-1; i>=0; i--) if (aa[i]!=bb[i]) break;
    if ((i>=0) && (aa[i]>bb[i])) asm_copy(aa,r); else asm_copy(bb,r);
  }
  asm_copy(gcd,aa);
}


void asm_half_old(ulong *a)
{
  ulong c, n_half[NMAX_ULONGS], shift, mask;
  long i;

#ifdef ULONG_HAS_32BIT
  shift=5;
#else
  shift=6;
#endif
  mask=(1UL<<shift)-1;

  for (i=0; i<montgomery_ulongs-1; i++)
    n_half[i]=(montgomery_modulo_n[i]>>1)|(montgomery_modulo_n[i+1]<<mask);
  n_half[montgomery_ulongs-1]=montgomery_modulo_n[montgomery_ulongs-1]>>1;
  asm_add2_ui(n_half,1);  /* (N+1)/2 */

  c=a[0]&1;
  for (i=0; i<montgomery_ulongs-1; i++) a[i]=(a[i]>>1)|(a[i+1]<<mask);
  a[montgomery_ulongs-1]>>=1;
  if (c) asm_add2(a,n_half);
}


int is_nonzero(ulong *a)
{
  long i;

  for (i=0; i<montgomery_ulongs; i++) if (a[i]) return 1;
  return 0;
}


int asm_invert(ulong *res, ulong *b)  /* inverts b mod N */
{
  long i, f1, len;
  ulong t1[NMAX_ULONGS], t2[NMAX_ULONGS];
  ulong v1[NMAX_ULONGS], v2[NMAX_ULONGS];
  ulong n_half[NMAX_ULONGS], shift, mask;

#ifdef ULONG_HAS_32BIT
  shift=5;
#else
  shift=6;
#endif
  mask=(1UL<<shift)-1;

  for (i=0; i<montgomery_ulongs; i++) if (b[i]) break;
  if (i>=montgomery_ulongs) return 0;
  if (b[0]&1) {
    asm_copy(t1,b); f1=0;
  } else {
    asm_sub(t1,montgomery_modulo_n,b); f1=1;
  }
  asm_zero(t2); t2[0]=1;
  asm_copy(v1,montgomery_modulo_n); asm_zero(v2);
  len=montgomery_ulongs-1;
  while (1) {
    if (!(t1[len]|v1[len])) len--;
    for (i=len; i>=0; i--) if (t1[i]!=v1[i]) break;
    if (i<0) break;
    if (t1[i]>v1[i]) {  /* t1>v1 */
      asm_sub_n(t1,v1); /* t1 even */
      asm_sub(t2,t2,v2);
      do {
        for (i=0; i<len; i++) t1[i]=(t1[i]>>1)|(t1[i+1]<<mask);
        t1[len]>>=1;
        asm_half(t2);
      } while (!(t1[0]&1));
    } else {  /* v1>t1 */
      asm_sub_n(v1,t1); /* t1 even */
      asm_sub(v2,v2,t2);
      do {
        for (i=0; i<len; i++) v1[i]=(v1[i]>>1)|(v1[i+1]<<mask);
        v1[len]>>=1;
        asm_half(v2);
      } while (!(v1[0]&1));
    }
  }
  if (t1[0]!=1) return 0;
  for (i=1; i<montgomery_ulongs; i++) if (t1[i]) return 0;
  if (f1) asm_sub(res,montgomery_modulo_n,t2); else asm_copy(res,t2);
  asm_mulmod(res,montgomery_modulo_R4,res);
/* check */
  v1[0]=1; for (i=1; i<montgomery_ulongs; i++) v1[i]=0;
  asm_mulmod(v1,montgomery_modulo_R2,v1);
  asm_mulmod(v2,res,b);
  if (asm_cmp(v1,v2)) {
    complain("inversion failed\n");
  }
  return 1;
}

