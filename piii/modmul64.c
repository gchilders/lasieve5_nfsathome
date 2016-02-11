/*
  Copyright (C) 2002,2006 Jens Franke, Thorsten Kleinjung
  This file is part of gnfs4linux, distributed under the terms of the 
  GNU General Public Licence and WITHOUT ANY WARRANTY.

  You should have received a copy of the GNU General Public License along
  with this program; see the file COPYING.  If not, write to the Free
  Software Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA
  02111-1307, USA.
*/

#include <sys/types.h>
#include "siever-config.h"
#include "gmp.h"
#include "64bit.h"

static mpz_t modmul64_aux1, modmul64_aux2;
static int modmul64_init=0;

u64_t modmul64(u64_t x, u64_t y)
{
  if (!modmul64_init) {
    mpz_init(modmul64_aux1);
    mpz_init(modmul64_aux2);
    modmul64_init=1;
  }
  mpz_set_ull(modmul64_aux1,x);
  mpz_set_ull(modmul64_aux2,y);
  mpz_mul(modmul64_aux1,modmul64_aux1,modmul64_aux2);
  mpz_set_ull(modmul64_aux2,modulo64);
  mpz_mod(modmul64_aux1,modmul64_aux1,modmul64_aux2);
  return mpz_get_ull(modmul64_aux1);
}

