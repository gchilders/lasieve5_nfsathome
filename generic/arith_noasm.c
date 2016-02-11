#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <limits.h>
#include <math.h>
#include <gmp.h>
#include "siever-config.h"
#include "../if.h"

#include "montgomery_mul.h"

#define uchar   unsigned char

extern ulong montgomery_inv_n;
extern ulong *montgomery_modulo_n;


extern int asm_invert(ulong *,ulong *);

#ifdef ULONG_HAS_32BIT
/* for 32 bit ulong */

/* ------------------- zero: ------------------------ */

void asm_zero64(ulong *x)
{
  x[0]=0; x[1]=0;
}

void asm_zero96(ulong *x)
{
  x[0]=0; x[1]=0; x[2]=0;
}

void asm_zero128(ulong *x)
{
  x[0]=0; x[1]=0; x[2]=0; x[3]=0;
}

void asm_zero160(ulong *x)
{
  x[0]=0; x[1]=0; x[2]=0; x[3]=0; x[4]=0;
}

void asm_zero192(ulong *x)
{
  x[0]=0; x[1]=0; x[2]=0; x[3]=0; x[4]=0; x[5]=0;
}

/* ------------------- copy: ------------------------ */

void asm_copy64(ulong *x, ulong *y)
{
  x[0]=y[0]; x[1]=y[1];
}

void asm_copy96(ulong *x, ulong *y)
{
  x[0]=y[0]; x[1]=y[1]; x[2]=y[2];
}

void asm_copy128(ulong *x, ulong *y)
{
  x[0]=y[0]; x[1]=y[1]; x[2]=y[2]; x[3]=y[3];
}

void asm_copy160(ulong *x, ulong *y)
{
  x[0]=y[0]; x[1]=y[1]; x[2]=y[2]; x[3]=y[3]; x[4]=y[4];
}

void asm_copy192(ulong *x, ulong *y)
{
  x[0]=y[0]; x[1]=y[1]; x[2]=y[2]; x[3]=y[3]; x[4]=y[4]; x[5]=y[5];
}

/* ----------------- subtraction: ---------------------- */

void asm_sub_n64(ulong *x, ulong *y)
{
  ulong carry=0, i;

  for (i=0; i<2; i++) {
    if (x[i]>y[i]) {
      x[i]-=y[i]; x[i]-=carry; carry=0;
    } else if (x[i]<y[i]) {
      x[i]-=y[i]; x[i]-=carry; carry=1;
    } else {
      x[i]=-carry;
    }
  }
}

void asm_sub_n96(ulong *x, ulong *y)
{
  ulong carry=0, i;

  for (i=0; i<3; i++) {
    if (x[i]>y[i]) {
      x[i]-=y[i]; x[i]-=carry; carry=0;
    } else if (x[i]<y[i]) {
      x[i]-=y[i]; x[i]-=carry; carry=1;
    } else {
      x[i]=-carry;
    }
  }
}

void asm_sub_n128(ulong *x, ulong *y)
{
  ulong carry=0, i;

  for (i=0; i<4; i++) {
    if (x[i]>y[i]) {
      x[i]-=y[i]; x[i]-=carry; carry=0;
    } else if (x[i]<y[i]) {
      x[i]-=y[i]; x[i]-=carry; carry=1;
    } else {
      x[i]=-carry;
    }
  }
}

void asm_sub_n160(ulong *x, ulong *y)
{
  ulong carry=0, i;

  for (i=0; i<5; i++) {
    if (x[i]>y[i]) {
      x[i]-=y[i]; x[i]-=carry; carry=0;
    } else if (x[i]<y[i]) {
      x[i]-=y[i]; x[i]-=carry; carry=1;
    } else {
      x[i]=-carry;
    }
  }
}

void asm_sub_n192(ulong *x, ulong *y)
{
  ulong carry=0, i;

  for (i=0; i<6; i++) {
    if (x[i]>y[i]) {
      x[i]-=y[i]; x[i]-=carry; carry=0;
    } else if (x[i]<y[i]) {
      x[i]-=y[i]; x[i]-=carry; carry=1;
    } else {
      x[i]=-carry;
    }
  }
}

/* ------------------- absolute difference: ------------------------ */

void asm_diff64(ulong *c, ulong *a, ulong *b)
{
  ulong i, tmp[2];

  for (i=0; i<2; i++)
    if (a[1-i]>b[1-i]) break;
    else if (a[1-i]<b[1-i]) i=10;
  if (i<2) {
    asm_copy64(tmp,a);
    asm_sub_n64(tmp,b);
    asm_copy64(c,tmp);
  } else {
    asm_copy64(tmp,b);
    asm_sub_n64(tmp,a);
    asm_copy64(c,tmp);
  }
}

void asm_diff96(ulong *c, ulong *a, ulong *b)
{
  ulong i, tmp[3];

  for (i=0; i<3; i++)
    if (a[2-i]>b[2-i]) break;
    else if (a[2-i]<b[2-i]) i=10;
  if (i<3) {
    asm_copy96(tmp,a);
    asm_sub_n96(tmp,b);
    asm_copy96(c,tmp);
  } else {
    asm_copy96(tmp,b);
    asm_sub_n96(tmp,a);
    asm_copy96(c,tmp);
  }
}

void asm_diff128(ulong *c, ulong *a, ulong *b)
{
  ulong i, tmp[4];

  for (i=0; i<4; i++)
    if (a[3-i]>b[3-i]) break;
    else if (a[3-i]<b[3-i]) i=10;
  if (i<4) {
    asm_copy128(tmp,a);
    asm_sub_n128(tmp,b);
    asm_copy128(c,tmp);
  } else {
    asm_copy128(tmp,b);
    asm_sub_n128(tmp,a);
    asm_copy128(c,tmp);
  }
}

void asm_diff160(ulong *c, ulong *a, ulong *b)
{
  ulong i, tmp[5];

  for (i=0; i<5; i++)
    if (a[4-i]>b[4-i]) break;
    else if (a[4-i]<b[4-i]) i=10;
  if (i<5) {
    asm_copy160(tmp,a);
    asm_sub_n160(tmp,b);
    asm_copy160(c,tmp);
  } else {
    asm_copy160(tmp,b);
    asm_sub_n160(tmp,a);
    asm_copy160(c,tmp);
  }
}

void asm_diff192(ulong *c, ulong *a, ulong *b)
{
  ulong i, tmp[6];

  for (i=0; i<6; i++)
    if (a[5-i]>b[5-i]) break;
    else if (a[5-i]<b[5-i]) i=10;
  if (i<6) {
    asm_copy192(tmp,a);
    asm_sub_n192(tmp,b);
    asm_copy192(c,tmp);
  } else {
    asm_copy192(tmp,b);
    asm_sub_n192(tmp,a);
    asm_copy192(c,tmp);
  }
}

/* ----------------- addition mod N: ---------------------- */

void asm_add64(ulong *x, ulong *y)
{
  ulong carry=0, i, yi;

  for (i=0; i<2; i++) {
    yi=y[i];
    if (carry) { x[i]++; if (x[i]) carry=0; }
    x[i]+=yi;
    if (x[i]<yi) carry=1;
  }
  for (i=0; i<2; i++)
    if (x[1-i]<montgomery_modulo_n[1-i]) break;
    else if (x[1-i]>montgomery_modulo_n[1-i]) i=10;
  if (i>=2) carry=1;
  if (carry) asm_sub_n64(x,montgomery_modulo_n);
}

void asm_add96(ulong *x, ulong *y)
{
  ulong carry=0, i, yi;

  for (i=0; i<3; i++) {
    yi=y[i];
    if (carry) { x[i]++; if (x[i]) carry=0; }
    x[i]+=yi;
    if (x[i]<yi) carry=1;
  }
  for (i=0; i<3; i++)
    if (x[2-i]<montgomery_modulo_n[2-i]) break;
    else if (x[2-i]>montgomery_modulo_n[2-i]) i=10;
  if (i>=3) carry=1;
  if (carry) asm_sub_n96(x,montgomery_modulo_n);
}

void asm_add128(ulong *x, ulong *y)
{
  ulong carry=0, i, yi;

  for (i=0; i<4; i++) {
    yi=y[i];
    if (carry) { x[i]++; if (x[i]) carry=0; }
    x[i]+=yi;
    if (x[i]<yi) carry=1;
  }
  for (i=0; i<4; i++)
    if (x[3-i]<montgomery_modulo_n[3-i]) break;
    else if (x[3-i]>montgomery_modulo_n[3-i]) i=10;
  if (i>=4) carry=1;
  if (carry) asm_sub_n128(x,montgomery_modulo_n);
}

void asm_add160(ulong *x, ulong *y)
{
  ulong carry=0, i, yi;

  for (i=0; i<5; i++) {
    yi=y[i];
    if (carry) { x[i]++; if (x[i]) carry=0; }
    x[i]+=yi;
    if (x[i]<yi) carry=1;
  }
  for (i=0; i<5; i++)
    if (x[4-i]<montgomery_modulo_n[4-i]) break;
    else if (x[4-i]>montgomery_modulo_n[4-i]) i=10;
  if (i>=5) carry=1;
  if (carry) asm_sub_n160(x,montgomery_modulo_n);
}

void asm_add192(ulong *x, ulong *y)
{
  ulong carry=0, i, yi;

  for (i=0; i<6; i++) {
    yi=y[i];
    if (carry) { x[i]++; if (x[i]) carry=0; }
    x[i]+=yi;
    if (x[i]<yi) carry=1;
  }
  for (i=0; i<6; i++)
    if (x[5-i]<montgomery_modulo_n[5-i]) break;
    else if (x[5-i]>montgomery_modulo_n[5-i]) i=10;
  if (i>=6) carry=1;
  if (carry) asm_sub_n192(x,montgomery_modulo_n);
}

/* ----------------- addition_ui mod N: ---------------------- */

void asm_add64_ui(ulong *x, ulong y)
{
  ulong carry=0, i;

  x[0]+=y;
  if (x[0]<y) carry=1;
  for (i=1; i<2; i++) if (carry) { x[i]++; if (x[i]) carry=0; }
  for (i=0; i<2; i++)
    if (x[1-i]<montgomery_modulo_n[1-i]) break;
    else if (x[1-i]>montgomery_modulo_n[1-i]) i=10;
  if (i>=2) carry=1;
  if (carry) asm_sub_n64(x,montgomery_modulo_n);
}

void asm_add96_ui(ulong *x, ulong y)
{
  ulong carry=0, i;

  x[0]+=y;
  if (x[0]<y) carry=1;
  for (i=1; i<3; i++) if (carry) { x[i]++; if (x[i]) carry=0; }
  for (i=0; i<3; i++)
    if (x[2-i]<montgomery_modulo_n[2-i]) break;
    else if (x[2-i]>montgomery_modulo_n[2-i]) i=10;
  if (i>=3) carry=1;
  if (carry) asm_sub_n96(x,montgomery_modulo_n);
}

void asm_add128_ui(ulong *x, ulong y)
{
  ulong carry=0, i;

  x[0]+=y;
  if (x[0]<y) carry=1;
  for (i=1; i<4; i++) if (carry) { x[i]++; if (x[i]) carry=0; }
  for (i=0; i<4; i++)
    if (x[3-i]<montgomery_modulo_n[3-i]) break;
    else if (x[3-i]>montgomery_modulo_n[3-i]) i=10;
  if (i>=4) carry=1;
  if (carry) asm_sub_n128(x,montgomery_modulo_n);
}

void asm_add160_ui(ulong *x, ulong y)
{
  ulong carry=0, i;

  x[0]+=y;
  if (x[0]<y) carry=1;
  for (i=1; i<5; i++) if (carry) { x[i]++; if (x[i]) carry=0; }
  for (i=0; i<5; i++)
    if (x[4-i]<montgomery_modulo_n[4-i]) break;
    else if (x[4-i]>montgomery_modulo_n[4-i]) i=10;
  if (i>=5) carry=1;
  if (carry) asm_sub_n160(x,montgomery_modulo_n);
}

void asm_add192_ui(ulong *x, ulong y)
{
  ulong carry=0, i;

  x[0]+=y;
  if (x[0]<y) carry=1;
  for (i=1; i<6; i++) if (carry) { x[i]++; if (x[i]) carry=0; }
  for (i=0; i<6; i++)
    if (x[5-i]<montgomery_modulo_n[5-i]) break;
    else if (x[5-i]>montgomery_modulo_n[5-i]) i=10;
  if (i>=6) carry=1;
  if (carry) asm_sub_n192(x,montgomery_modulo_n);
}

/* ----------------- subtraction mod N: ---------------------- */

void asm_sub64_3(ulong *c, ulong *a, ulong *b)
{
  ulong carry=0, i;

  for (i=0; i<2; i++) {
    if (a[i]>b[i]) {
      c[i]=a[i]-b[i]; c[i]-=carry; carry=0;
    } else if (a[i]<b[i]) {
      c[i]=a[i]-b[i]; c[i]-=carry; carry=1;
    } else {
      c[i]=-carry;
    }
  }
  if (carry) {
    carry=0;
    for (i=0; i<2; i++) {
      if (carry) { c[i]++; if (c[i]) carry=0; }
      c[i]+=montgomery_modulo_n[i];
      if (c[i]<montgomery_modulo_n[i]) carry=1;
    }
  }
}

void asm_sub96_3(ulong *c, ulong *a, ulong *b)
{
  ulong carry=0, i;

  for (i=0; i<3; i++) {
    if (a[i]>b[i]) {
      c[i]=a[i]-b[i]; c[i]-=carry; carry=0;
    } else if (a[i]<b[i]) {
      c[i]=a[i]-b[i]; c[i]-=carry; carry=1;
    } else {
      c[i]=-carry;
    }
  }
  if (carry) {
    carry=0;
    for (i=0; i<3; i++) {
      if (carry) { c[i]++; if (c[i]) carry=0; }
      c[i]+=montgomery_modulo_n[i];
      if (c[i]<montgomery_modulo_n[i]) carry=1;
    }
  }
}

void asm_sub128_3(ulong *c, ulong *a, ulong *b)
{
  ulong carry=0, i;

  for (i=0; i<4; i++) {
    if (a[i]>b[i]) {
      c[i]=a[i]-b[i]; c[i]-=carry; carry=0;
    } else if (a[i]<b[i]) {
      c[i]=a[i]-b[i]; c[i]-=carry; carry=1;
    } else {
      c[i]=-carry;
    }
  }
  if (carry) {
    carry=0;
    for (i=0; i<4; i++) {
      if (carry) { c[i]++; if (c[i]) carry=0; }
      c[i]+=montgomery_modulo_n[i];
      if (c[i]<montgomery_modulo_n[i]) carry=1;
    }
  }
}

void asm_sub160_3(ulong *c, ulong *a, ulong *b)
{
  ulong carry=0, i;

  for (i=0; i<5; i++) {
    if (a[i]>b[i]) {
      c[i]=a[i]-b[i]; c[i]-=carry; carry=0;
    } else if (a[i]<b[i]) {
      c[i]=a[i]-b[i]; c[i]-=carry; carry=1;
    } else {
      c[i]=-carry;
    }
  }
  if (carry) {
    carry=0;
    for (i=0; i<5; i++) {
      if (carry) { c[i]++; if (c[i]) carry=0; }
      c[i]+=montgomery_modulo_n[i];
      if (c[i]<montgomery_modulo_n[i]) carry=1;
    }
  }
}

void asm_sub192_3(ulong *c, ulong *a, ulong *b)
{
  ulong carry=0, i;

  for (i=0; i<6; i++) {
    if (a[i]>b[i]) {
      c[i]=a[i]-b[i]; c[i]-=carry; carry=0;
    } else if (a[i]<b[i]) {
      c[i]=a[i]-b[i]; c[i]-=carry; carry=1;
    } else {
      c[i]=-carry;
    }
  }
  if (carry) {
    carry=0;
    for (i=0; i<6; i++) {
      if (carry) { c[i]++; if (c[i]) carry=0; }
      c[i]+=montgomery_modulo_n[i];
      if (c[i]<montgomery_modulo_n[i]) carry=1;
    }
  }
}

/* ----------------- halving mod N: ---------------------- */

void asm_half64(ulong *x)
{
  ulong carry=0, i;

  if (x[0]&1)
    for (i=0; i<2; i++) {
      if (carry) { x[i]++; if (x[i]) carry=0; }
      x[i]+=montgomery_modulo_n[i];
      if (x[i]<montgomery_modulo_n[i]) carry=1;
    }
  for (i=0; i<1; i++) x[i]=(x[i]>>1)|(x[i+1]<<31);
  x[1]=(x[1]>>1)|(carry<<31);
}

void asm_half96(ulong *x)
{
  ulong carry=0, i;

  if (x[0]&1)
    for (i=0; i<3; i++) {
      if (carry) { x[i]++; if (x[i]) carry=0; }
      x[i]+=montgomery_modulo_n[i];
      if (x[i]<montgomery_modulo_n[i]) carry=1;
    }
  for (i=0; i<2; i++) x[i]=(x[i]>>1)|(x[i+1]<<31);
  x[2]=(x[2]>>1)|(carry<<31);
}

void asm_half128(ulong *x)
{
  ulong carry=0, i;

  if (x[0]&1)
    for (i=0; i<4; i++) {
      if (carry) { x[i]++; if (x[i]) carry=0; }
      x[i]+=montgomery_modulo_n[i];
      if (x[i]<montgomery_modulo_n[i]) carry=1;
    }
  for (i=0; i<3; i++) x[i]=(x[i]>>1)|(x[i+1]<<31);
  x[3]=(x[3]>>1)|(carry<<31);
}

void asm_half160(ulong *x)
{
  ulong carry=0, i;

  if (x[0]&1)
    for (i=0; i<5; i++) {
      if (carry) { x[i]++; if (x[i]) carry=0; }
      x[i]+=montgomery_modulo_n[i];
      if (x[i]<montgomery_modulo_n[i]) carry=1;
    }
  for (i=0; i<4; i++) x[i]=(x[i]>>1)|(x[i+1]<<31);
  x[4]=(x[4]>>1)|(carry<<31);
}

void asm_half192(ulong *x)
{
  ulong carry=0, i;

  if (x[0]&1)
    for (i=0; i<6; i++) {
      if (carry) { x[i]++; if (x[i]) carry=0; }
      x[i]+=montgomery_modulo_n[i];
      if (x[i]<montgomery_modulo_n[i]) carry=1;
    }
  for (i=0; i<5; i++) x[i]=(x[i]>>1)|(x[i+1]<<31);
  x[5]=(x[5]>>1)|(carry<<31);
}

/* ----------------- multiplication mod N: ---------------------- */

ulong mul_high(ulong x, ulong y)
{
  ulong h, res, mask, z;

  h=32>>1;
  mask=1;
  mask<<=h;
  mask--;
  res=(x&mask)*(y&mask);
  res>>=h;
  res+=(x&mask)*(y>>h);
  z=(x>>h)*(y&mask);
  res+=(z&mask);
  res>>=h;
  res+=(z>>h);
  res+=(x>>h)*(y>>h);
  return res;
}

void asm_mulm64(ulong *c, ulong *a, ulong *b)
{
  ulong carry, inv, i, tmp[2+1], l, j, x;

  for (i=0; i<2+1; i++) tmp[i]=0;
  for (i=0; i<2; i++) {
    x=a[i]; carry=0;
    for (j=0; j<2; j++) {
      tmp[j]+=carry; if (tmp[j]<carry) carry=1; else carry=0;
      l=x*b[j];
      tmp[j]+=l; if (tmp[j]<l) carry++;
      carry+=mul_high(x,b[j]);
    }
    tmp[2]+=carry; /* no carry possible */

    inv=tmp[0]*montgomery_inv_n; carry=0;
    for (j=0; j<2; j++) {
      tmp[j]+=carry; if (tmp[j]<carry) carry=1; else carry=0;
      l=inv*montgomery_modulo_n[j];
      tmp[j]+=l; if (tmp[j]<l) carry++;
      carry+=mul_high(inv,montgomery_modulo_n[j]);
    }
    tmp[2]+=carry;

    for (j=0; j<2; j++) tmp[j]=tmp[j+1];
    if (tmp[1]<carry) tmp[2]=1; else tmp[2]=0;
  }
  if (tmp[2]) asm_sub_n64(tmp,montgomery_modulo_n);
  asm_copy64(c,tmp);
  asm_add64_ui(c,0);
}

void asm_mulm96(ulong *c, ulong *a, ulong *b)
{
  ulong carry, inv, i, tmp[3+1], l, j, x;

  for (i=0; i<3+1; i++) tmp[i]=0;
  for (i=0; i<3; i++) {
    x=a[i]; carry=0;
    for (j=0; j<3; j++) {
      tmp[j]+=carry; if (tmp[j]<carry) carry=1; else carry=0;
      l=x*b[j];
      tmp[j]+=l; if (tmp[j]<l) carry++;
      carry+=mul_high(x,b[j]);
    }
    tmp[3]+=carry; /* no carry possible */

    inv=tmp[0]*montgomery_inv_n; carry=0;
    for (j=0; j<3; j++) {
      tmp[j]+=carry; if (tmp[j]<carry) carry=1; else carry=0;
      l=inv*montgomery_modulo_n[j];
      tmp[j]+=l; if (tmp[j]<l) carry++;
      carry+=mul_high(inv,montgomery_modulo_n[j]);
    }
    tmp[3]+=carry;

    for (j=0; j<3; j++) tmp[j]=tmp[j+1];
    if (tmp[2]<carry) tmp[3]=1; else tmp[3]=0;
  }
  if (tmp[3]) asm_sub_n96(tmp,montgomery_modulo_n);
  asm_copy96(c,tmp);
  asm_add96_ui(c,0);
}

void asm_mulm128(ulong *c, ulong *a, ulong *b)
{
  ulong carry, inv, i, tmp[4+1], l, j, x;

  for (i=0; i<4+1; i++) tmp[i]=0;
  for (i=0; i<4; i++) {
    x=a[i]; carry=0;
    for (j=0; j<4; j++) {
      tmp[j]+=carry; if (tmp[j]<carry) carry=1; else carry=0;
      l=x*b[j];
      tmp[j]+=l; if (tmp[j]<l) carry++;
      carry+=mul_high(x,b[j]);
    }
    tmp[4]+=carry; /* no carry possible */

    inv=tmp[0]*montgomery_inv_n; carry=0;
    for (j=0; j<4; j++) {
      tmp[j]+=carry; if (tmp[j]<carry) carry=1; else carry=0;
      l=inv*montgomery_modulo_n[j];
      tmp[j]+=l; if (tmp[j]<l) carry++;
      carry+=mul_high(inv,montgomery_modulo_n[j]);
    }
    tmp[4]+=carry;

    for (j=0; j<4; j++) tmp[j]=tmp[j+1];
    if (tmp[3]<carry) tmp[4]=1; else tmp[4]=0;
  }
  if (tmp[4]) asm_sub_n128(tmp,montgomery_modulo_n);
  asm_copy128(c,tmp);
  asm_add128_ui(c,0);
}

void asm_mulm160(ulong *c, ulong *a, ulong *b)
{
  ulong carry, inv, i, tmp[5+1], l, j, x;

  for (i=0; i<5+1; i++) tmp[i]=0;
  for (i=0; i<5; i++) {
    x=a[i]; carry=0;
    for (j=0; j<5; j++) {
      tmp[j]+=carry; if (tmp[j]<carry) carry=1; else carry=0;
      l=x*b[j];
      tmp[j]+=l; if (tmp[j]<l) carry++;
      carry+=mul_high(x,b[j]);
    }
    tmp[5]+=carry; /* no carry possible */

    inv=tmp[0]*montgomery_inv_n; carry=0;
    for (j=0; j<5; j++) {
      tmp[j]+=carry; if (tmp[j]<carry) carry=1; else carry=0;
      l=inv*montgomery_modulo_n[j];
      tmp[j]+=l; if (tmp[j]<l) carry++;
      carry+=mul_high(inv,montgomery_modulo_n[j]);
    }
    tmp[5]+=carry;

    for (j=0; j<5; j++) tmp[j]=tmp[j+1];
    if (tmp[4]<carry) tmp[5]=1; else tmp[5]=0;
  }
  if (tmp[5]) asm_sub_n160(tmp,montgomery_modulo_n);
  asm_copy160(c,tmp);
  asm_add160_ui(c,0);
}

void asm_mulm192(ulong *c, ulong *a, ulong *b)
{
  ulong carry, inv, i, tmp[6+1], l, j, x;

  for (i=0; i<6+1; i++) tmp[i]=0;
  for (i=0; i<6; i++) {
    x=a[i]; carry=0;
    for (j=0; j<6; j++) {
      tmp[j]+=carry; if (tmp[j]<carry) carry=1; else carry=0;
      l=x*b[j];
      tmp[j]+=l; if (tmp[j]<l) carry++;
      carry+=mul_high(x,b[j]);
    }
    tmp[6]+=carry; /* no carry possible */

    inv=tmp[0]*montgomery_inv_n; carry=0;
    for (j=0; j<6; j++) {
      tmp[j]+=carry; if (tmp[j]<carry) carry=1; else carry=0;
      l=inv*montgomery_modulo_n[j];
      tmp[j]+=l; if (tmp[j]<l) carry++;
      carry+=mul_high(inv,montgomery_modulo_n[j]);
    }
    tmp[6]+=carry;

    for (j=0; j<6; j++) tmp[j]=tmp[j+1];
    if (tmp[5]<carry) tmp[6]=1; else tmp[6]=0;
  }
  if (tmp[6]) asm_sub_n192(tmp,montgomery_modulo_n);
  asm_copy192(c,tmp);
  asm_add192_ui(c,0);
}

/* ----------------- squaring mod N: ---------------------- */

void asm_sqm64(ulong *x,ulong *y)
{
  asm_mulm64(x,y,y);
}

void asm_sqm96(ulong *x,ulong *y)
{
  asm_mulm96(x,y,y);
}
#if 0
void asm_sqm128(ulong *x,ulong *y)
{
  asm_mulm128(x,y,y);
}

void asm_sqm160(ulong *x,ulong *y)
{
  asm_mulm160(x,y,y);
}

void asm_sqm192(ulong *x,ulong *y)
{
  asm_mulm192(x,y,y);
}
#endif

#else
/* for 64 bit ulong */

/* ------------------- zero: ------------------------ */

void asm_zero64(ulong *x)
{
  x[0]=0;
}

void asm_zero128(ulong *x)
{
  x[0]=0; x[1]=0;
}

void asm_zero192(ulong *x)
{
  x[0]=0; x[1]=0; x[2]=0;
}

/* ------------------- copy: ------------------------ */

void asm_copy64(ulong *x, ulong *y)
{
  x[0]=y[0];
}

void asm_copy128(ulong *x, ulong *y)
{
  x[0]=y[0]; x[1]=y[1];
}

void asm_copy192(ulong *x, ulong *y)
{
  x[0]=y[0]; x[1]=y[1]; x[2]=y[2];
}

/* ----------------- subtraction: ---------------------- */

void asm_sub_n64(ulong *x, ulong *y)
{
  if (x[0]>y[0]) {
    x[0]-=y[0];
  } else if (x[0]<y[0]) {
    x[0]-=y[0];
  } else {
    x[0]=0;
  }
}

void asm_sub_n128(ulong *x, ulong *y)
{
  ulong carry=0, i;

  for (i=0; i<2; i++) {
    if (x[i]>y[i]) {
      x[i]-=y[i]; x[i]-=carry; carry=0;
    } else if (x[i]<y[i]) {
      x[i]-=y[i]; x[i]-=carry; carry=1;
    } else {
      x[i]=-carry;
    }
  }
}

void asm_sub_n192(ulong *x, ulong *y)
{
  ulong carry=0, i;

  for (i=0; i<3; i++) {
    if (x[i]>y[i]) {
      x[i]-=y[i]; x[i]-=carry; carry=0;
    } else if (x[i]<y[i]) {
      x[i]-=y[i]; x[i]-=carry; carry=1;
    } else {
      x[i]=-carry;
    }
  }
}

/* ------------------- absolute difference: ------------------------ */

void asm_diff64(ulong *c, ulong *a, ulong *b)
{
  ulong i, tmp[1];

  for (i=0; i<1; i++)
    if (a[0-i]>b[0-i]) break;
    else if (a[0-i]<b[0-i]) i=10;
  if (i<1) {
    asm_copy64(tmp,a);
    asm_sub_n64(tmp,b);
    asm_copy64(c,tmp);
  } else {
    asm_copy64(tmp,b);
    asm_sub_n64(tmp,a);
    asm_copy64(c,tmp);
  }
}

void asm_diff128(ulong *c, ulong *a, ulong *b)
{
  ulong i, tmp[2];

  for (i=0; i<2; i++)
    if (a[1-i]>b[1-i]) break;
    else if (a[1-i]<b[1-i]) i=10;
  if (i<2) {
    asm_copy128(tmp,a);
    asm_sub_n128(tmp,b);
    asm_copy128(c,tmp);
  } else {
    asm_copy128(tmp,b);
    asm_sub_n128(tmp,a);
    asm_copy128(c,tmp);
  }
}

void asm_diff192(ulong *c, ulong *a, ulong *b)
{
  ulong i, tmp[3];

  for (i=0; i<3; i++)
    if (a[2-i]>b[2-i]) break;
    else if (a[2-i]<b[2-i]) i=10;
  if (i<3) {
    asm_copy192(tmp,a);
    asm_sub_n192(tmp,b);
    asm_copy192(c,tmp);
  } else {
    asm_copy192(tmp,b);
    asm_sub_n192(tmp,a);
    asm_copy192(c,tmp);
  }
}

/* ----------------- addition mod N: ---------------------- */

void asm_add64(ulong *x, ulong *y)
{
  ulong carry=0, i, yi;

  for (i=0; i<1; i++) {
    yi=y[i];
    if (carry) { x[i]++; if (x[i]) carry=0; }
    x[i]+=yi;
    if (x[i]<yi) carry=1;
  }
  for (i=0; i<1; i++)
    if (x[0-i]<montgomery_modulo_n[0-i]) break;
    else if (x[0-i]>montgomery_modulo_n[0-i]) i=10;
  if (i>=1) carry=1;
  if (carry) asm_sub_n64(x,montgomery_modulo_n);
}

void asm_add128(ulong *x, ulong *y)
{
  ulong carry=0, i, yi;

  for (i=0; i<2; i++) {
    yi=y[i];
    if (carry) { x[i]++; if (x[i]) carry=0; }
    x[i]+=yi;
    if (x[i]<yi) carry=1;
  }
  for (i=0; i<2; i++)
    if (x[1-i]<montgomery_modulo_n[1-i]) break;
    else if (x[1-i]>montgomery_modulo_n[1-i]) i=10;
  if (i>=2) carry=1;
  if (carry) asm_sub_n128(x,montgomery_modulo_n);
}

void asm_add192(ulong *x, ulong *y)
{
  ulong carry=0, i, yi;

  for (i=0; i<3; i++) {
    yi=y[i];
    if (carry) { x[i]++; if (x[i]) carry=0; }
    x[i]+=yi;
    if (x[i]<yi) carry=1;
  }
  for (i=0; i<3; i++)
    if (x[2-i]<montgomery_modulo_n[2-i]) break;
    else if (x[2-i]>montgomery_modulo_n[2-i]) i=10;
  if (i>=3) carry=1;
  if (carry) asm_sub_n192(x,montgomery_modulo_n);
}

/* ----------------- addition_ui mod N: ---------------------- */

void asm_add64_ui(ulong *x, ulong y)
{
  ulong carry=0, i;

  x[0]+=y;
  if (x[0]<y) carry=1;
  for (i=1; i<1; i++) if (carry) { x[i]++; if (x[i]) carry=0; }
  for (i=0; i<1; i++)
    if (x[0-i]<montgomery_modulo_n[0-i]) break;
    else if (x[0-i]>montgomery_modulo_n[0-i]) i=10;
  if (i>=1) carry=1;
  if (carry) asm_sub_n64(x,montgomery_modulo_n);
}

void asm_add128_ui(ulong *x, ulong y)
{
  ulong carry=0, i;

  x[0]+=y;
  if (x[0]<y) carry=1;
  for (i=1; i<2; i++) if (carry) { x[i]++; if (x[i]) carry=0; }
  for (i=0; i<2; i++)
    if (x[1-i]<montgomery_modulo_n[1-i]) break;
    else if (x[1-i]>montgomery_modulo_n[1-i]) i=10;
  if (i>=2) carry=1;
  if (carry) asm_sub_n128(x,montgomery_modulo_n);
}

void asm_add192_ui(ulong *x, ulong y)
{
  ulong carry=0, i;

  x[0]+=y;
  if (x[0]<y) carry=1;
  for (i=1; i<3; i++) if (carry) { x[i]++; if (x[i]) carry=0; }
  for (i=0; i<3; i++)
    if (x[2-i]<montgomery_modulo_n[2-i]) break;
    else if (x[2-i]>montgomery_modulo_n[2-i]) i=10;
  if (i>=3) carry=1;
  if (carry) asm_sub_n192(x,montgomery_modulo_n);
}

/* ----------------- subtraction mod N: ---------------------- */

void asm_sub64_3(ulong *c, ulong *a, ulong *b)
{
  ulong carry=0, i;

  for (i=0; i<1; i++) {
    if (a[i]>b[i]) {
      c[i]=a[i]-b[i]; c[i]-=carry; carry=0;
    } else if (a[i]<b[i]) {
      c[i]=a[i]-b[i]; c[i]-=carry; carry=1;
    } else {
      c[i]=-carry;
    }
  }
  if (carry) {
    carry=0;
    for (i=0; i<1; i++) {
      if (carry) { c[i]++; if (c[i]) carry=0; }
      c[i]+=montgomery_modulo_n[i];
      if (c[i]<montgomery_modulo_n[i]) carry=1;
    }
  }
}

void asm_sub128_3(ulong *c, ulong *a, ulong *b)
{
  ulong carry=0, i;

  for (i=0; i<2; i++) {
    if (a[i]>b[i]) {
      c[i]=a[i]-b[i]; c[i]-=carry; carry=0;
    } else if (a[i]<b[i]) {
      c[i]=a[i]-b[i]; c[i]-=carry; carry=1;
    } else {
      c[i]=-carry;
    }
  }
  if (carry) {
    carry=0;
    for (i=0; i<2; i++) {
      if (carry) { c[i]++; if (c[i]) carry=0; }
      c[i]+=montgomery_modulo_n[i];
      if (c[i]<montgomery_modulo_n[i]) carry=1;
    }
  }
}

void asm_sub192_3(ulong *c, ulong *a, ulong *b)
{
  ulong carry=0, i;

  for (i=0; i<3; i++) {
    if (a[i]>b[i]) {
      c[i]=a[i]-b[i]; c[i]-=carry; carry=0;
    } else if (a[i]<b[i]) {
      c[i]=a[i]-b[i]; c[i]-=carry; carry=1;
    } else {
      c[i]=-carry;
    }
  }
  if (carry) {
    carry=0;
    for (i=0; i<3; i++) {
      if (carry) { c[i]++; if (c[i]) carry=0; }
      c[i]+=montgomery_modulo_n[i];
      if (c[i]<montgomery_modulo_n[i]) carry=1;
    }
  }
}

/* ----------------- halving mod N: ---------------------- */

void asm_half64(ulong *x)
{
  ulong carry=0, i;

  if (x[0]&1)
    for (i=0; i<1; i++) {
      if (carry) { x[i]++; if (x[i]) carry=0; }
      x[i]+=montgomery_modulo_n[i];
      if (x[i]<montgomery_modulo_n[i]) carry=1;
    }
  x[0]=(x[0]>>1)|(carry<<63);
}

void asm_half128(ulong *x)
{
  ulong carry=0, i;

  if (x[0]&1)
    for (i=0; i<2; i++) {
      if (carry) { x[i]++; if (x[i]) carry=0; }
      x[i]+=montgomery_modulo_n[i];
      if (x[i]<montgomery_modulo_n[i]) carry=1;
    }
  for (i=0; i<1; i++) x[i]=(x[i]>>1)|(x[i+1]<<63);
  x[1]=(x[1]>>1)|(carry<<63);
}

void asm_half192(ulong *x)
{
  ulong carry=0, i;

  if (x[0]&1)
    for (i=0; i<3; i++) {
      if (carry) { x[i]++; if (x[i]) carry=0; }
      x[i]+=montgomery_modulo_n[i];
      if (x[i]<montgomery_modulo_n[i]) carry=1;
    }
  for (i=0; i<2; i++) x[i]=(x[i]>>1)|(x[i+1]<<63);
  x[2]=(x[2]>>1)|(carry<<63);
}

/* ----------------- multiplication mod N: ---------------------- */

ulong mul_high(ulong x, ulong y)
{
  ulong h, res, mask, z;

  h=mp_bits_per_limb>>1;
  mask=1;
  mask<<=h;
  mask--;
  res=(x&mask)*(y&mask);
  res>>=h;
  res+=(x&mask)*(y>>h);
  z=(x>>h)*(y&mask);
  res+=(z&mask);
  res>>=h;
  res+=(z>>h);
  res+=(x>>h)*(y>>h);
  return res;
}

void asm_mulm64(ulong *c, ulong *a, ulong *b)
{
  ulong carry, inv, i, tmp[1+1], l, j, x;

  for (i=0; i<1+1; i++) tmp[i]=0;
  for (i=0; i<1; i++) {
    x=a[i]; carry=0;
    for (j=0; j<1; j++) {
      tmp[j]+=carry; if (tmp[j]<carry) carry=1; else carry=0;
      l=x*b[j];
      tmp[j]+=l; if (tmp[j]<l) carry++;
      carry+=mul_high(x,b[j]);
    }
    tmp[1]+=carry; /* no carry possible */

    inv=tmp[0]*montgomery_inv_n; carry=0;
    for (j=0; j<1; j++) {
      tmp[j]+=carry; if (tmp[j]<carry) carry=1; else carry=0;
      l=inv*montgomery_modulo_n[j];
      tmp[j]+=l; if (tmp[j]<l) carry++;
      carry+=mul_high(inv,montgomery_modulo_n[j]);
    }
    tmp[1]+=carry;

    for (j=0; j<1; j++) tmp[j]=tmp[j+1];
    if (tmp[0]<carry) tmp[1]=1; else tmp[1]=0;
  }
  if (tmp[1]) asm_sub_n64(tmp,montgomery_modulo_n);
  asm_copy64(c,tmp);
  asm_add64_ui(c,0);
}

void asm_mulm128(ulong *c, ulong *a, ulong *b)
{
  ulong carry, inv, i, tmp[2+1], l, j, x;

  for (i=0; i<2+1; i++) tmp[i]=0;
  for (i=0; i<2; i++) {
    x=a[i]; carry=0;
    for (j=0; j<2; j++) {
      tmp[j]+=carry; if (tmp[j]<carry) carry=1; else carry=0;
      l=x*b[j];
      tmp[j]+=l; if (tmp[j]<l) carry++;
      carry+=mul_high(x,b[j]);
    }
    tmp[2]+=carry; /* no carry possible */

    inv=tmp[0]*montgomery_inv_n; carry=0;
    for (j=0; j<2; j++) {
      tmp[j]+=carry; if (tmp[j]<carry) carry=1; else carry=0;
      l=inv*montgomery_modulo_n[j];
      tmp[j]+=l; if (tmp[j]<l) carry++;
      carry+=mul_high(inv,montgomery_modulo_n[j]);
    }
    tmp[2]+=carry;

    for (j=0; j<2; j++) tmp[j]=tmp[j+1];
    if (tmp[1]<carry) tmp[2]=1; else tmp[2]=0;
  }
  if (tmp[2]) asm_sub_n128(tmp,montgomery_modulo_n);
  asm_copy128(c,tmp);
  asm_add128_ui(c,0);
}

void asm_mulm192(ulong *c, ulong *a, ulong *b)
{
  ulong carry, inv, i, tmp[3+1], l, j, x;

  for (i=0; i<3+1; i++) tmp[i]=0;
  for (i=0; i<3; i++) {
    x=a[i]; carry=0;
    for (j=0; j<3; j++) {
      tmp[j]+=carry; if (tmp[j]<carry) carry=1; else carry=0;
      l=x*b[j];
      tmp[j]+=l; if (tmp[j]<l) carry++;
      carry+=mul_high(x,b[j]);
    }
    tmp[3]+=carry; /* no carry possible */

    inv=tmp[0]*montgomery_inv_n; carry=0;
    for (j=0; j<3; j++) {
      tmp[j]+=carry; if (tmp[j]<carry) carry=1; else carry=0;
      l=inv*montgomery_modulo_n[j];
      tmp[j]+=l; if (tmp[j]<l) carry++;
      carry+=mul_high(inv,montgomery_modulo_n[j]);
    }
    tmp[3]+=carry;

    for (j=0; j<3; j++) tmp[j]=tmp[j+1];
    if (tmp[2]<carry) tmp[3]=1; else tmp[3]=0;
  }
  if (tmp[3]) asm_sub_n192(tmp,montgomery_modulo_n);
  asm_copy192(c,tmp);
  asm_add192_ui(c,0);
}

/* ----------------- squaring mod N: ---------------------- */

void asm_sqm64(ulong *x,ulong *y)
{
  asm_mulm64(x,y,y);
}
#if 0
void asm_sqm128(ulong *x,ulong *y)
{
  asm_mulm128(x,y,y);
}

void asm_sqm192(ulong *x,ulong *y)
{
  asm_mulm192(x,y,y);
}
#endif

#endif
