/*
Copyright (C) 2001 Jens Franke, T. Kleinjung.
This file is part of gnfs4linux, distributed under the terms of the 
GNU General Public Licence and WITHOUT ANY WARRANTY.

You should have received a copy of the GNU General Public License along
with this program; see the file COPYING.  If not, write to the Free
Software Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA
02111-1307, USA.
*/
/* Written by T. Kleinjung. */
#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <limits.h>
#include <math.h>
#include <gmp.h>
#include "siever-config.h"
#include "montgomery_mul.h"

typedef unsigned long long    ull;

extern ulong montgomery_inv_n;
extern ulong *montgomery_modulo_n;
extern ulong montgomery_modulo_R2[NMAX_ULONGS];
extern ulong montgomery_ulongs;


extern void (*asm_mulmod)(ulong *,ulong *,ulong *);
extern void (*asm_squmod)(ulong *,ulong *);
extern void (*asm_add2)(ulong *,ulong *);
extern void (*asm_diff)(ulong *,ulong *,ulong *);



int psp(mpz_t n)
{
  ulong x[NMAX_ULONGS], ex[NMAX_ULONGS], one[NMAX_ULONGS], s, mask;
  long e, i, b, v, shift;

#ifdef ULONG_HAS_32BIT
  shift=5;
#else
  shift=6;
#endif
  mask=(1UL<<shift)-1;

  if (!set_montgomery_multiplication(n)) return -1;

  if (!(montgomery_modulo_n[0]&1)) return 0;  /* number is even */
  ex[0]=montgomery_modulo_n[0]-1;
  for (i=1; i<montgomery_ulongs; i++)  ex[i]=montgomery_modulo_n[i];
  for (i=0; i<montgomery_ulongs; i++) if (ex[i]) break;
  if (i>=montgomery_ulongs) return 0;  /* number is 1 */

  e=0;
  while (!(ex[0]&1)) {
    for (i=0; i<montgomery_ulongs-1; i++) ex[i]=(ex[i]>>1)|(ex[i+1]<<mask);
    ex[montgomery_ulongs-1]>>=1;
    e++;
  }
  one[0]=1; for (i=1; i<montgomery_ulongs; i++) one[i]=0;
  asm_mulmod(one,montgomery_modulo_R2,one);

  for (i=montgomery_ulongs-1; i>=0; i--) if (ex[i]) break;
  if (i<0) complain("psp\n");
  b=(i<<shift)+mask; v=ex[i];
  while (v>=0) { b--; v<<=1; }

  for (i=0; i<montgomery_ulongs; i++) x[i]=0;
  s=1;
  for (i=b-1; i>=0; i--) {
    if (2*s>=(montgomery_ulongs<<shift)) break;
    s<<=1;
    v=ex[i>>shift]&(1UL<<(i&mask));
    if (v) s++;
  }
  x[s>>shift]=1UL<<(s&mask);
  asm_mulmod(x,montgomery_modulo_R2,x);

  if (i>=0) {
    v=(ex[i>>shift]<<(mask-(i&mask)));
    while (1) {
      asm_squmod(x,x);
      if (v<0) asm_add2(x,x);
      if (i&mask) {
        i--; v<<=1;
      } else {
        if (!i) break;
        i--; v=ex[i>>shift];
      }
    }
  }
  if (asm_cmp(x,one)==0) return 1;
  asm_diff(one,montgomery_modulo_n,one);
  if (asm_cmp(x,one)==0) return 1;
  for (i=0; i<e-1; i++) {
    asm_squmod(x,x);
    if (asm_cmp(x,one)==0) return 1;
  }
  return 0;
}

