#include <inttypes.h>
#include <stdio.h>

const uint16_t divi1 = 239*239;
//const uint16_t divi1 = 5*5;

int main() {
    uint64_t a; // High 64 bits
    uint64_t b; // Low 64 bits

    uint64_t rdx; // High 64 bits
    uint64_t rax; // Low 64 bits

    __int128 prod = 0;
    __int128 bigint = 1ULL;

    bigint <<= 68;
    bigint /= divi1;
    uint64_t inv = (uint64_t)(bigint);         // Bottom 64 bits
    inv++;
    printf("0x%016lx %08x\n", inv, divi1);
    
    uint64_t max = 1;
    max <<= 49;
    max--;

    uint64_t min = 0x7ea0000000;
    //uint64_t min = 1;
    for (uint64_t i=min; i<max; i+=0xf7a){
      prod = i;
      prod *= inv;

      a = (uint64_t) (prod>>64);
      b = (uint64_t) (prod>>52) +1;
      //printf("m. %lx %016lx %016lx\n", i, a, b);

      prod = b;
      prod *= divi1;
      //prod += divi1;
      a = (uint64_t)(prod>>16);
      b = (uint64_t)prod;
      //printf("r. %lx %016lx %016lx %lu\n", i, a,b, 0ul);
      if (a == i){
        continue;
      }
      printf("3. %lx %016lx %016lx \n--\n\n",i, a,b);
      bigint = i;
      bigint <<= 64;
      bigint /= divi1;
      a = (uint64_t) (bigint >> 64);
      b = (uint64_t) (bigint );
      printf("4. %lu %016lx %016lx \n--\n\n",i, a,b);
    }

    /*
    // Cast to 128-bit to ensure a 128-bit multiplication
    unsigned __int128 result = (unsigned __int128)a * b;

    // Split the result
    rax = (uint64_t)result;         // Bottom 64 bits
    rdx = (uint64_t)(result >> 64); // Top 64 bits

    printf("High (RDX): 0x%016llx\n", (unsigned long long)rdx);
    printf("Low  (RAX): 0x%016llx\n", (unsigned long long)rax);

    return 0;
*/
}
const uint16_t divisor = 239*239;

void divide(__int128 x, uint64_t res[2]){
  res[0] = x / divisor;
  res[1] = x % divisor;
}

int oldmain(){
  __int128 a = 12000;
  uint64_t b = 3881;
  uint64_t res[2];
  res[0]=0;
  res[1]=0;

  for (unsigned int i=0; i<20; i++){
    //printf(" <res = %lu %lu\n", res[0], res[1]);
    divide(a,res);
    //printf(" >res = %lu %lu\n", res[0], res[1]);
    uint64_t check = res[0]*divisor + res[1];
    if(check != a){
      return 7;
    }
    a += b;
    b = res[1];
  }
  return 0;
}
