#include "stdio.h"
#include "stdint.h"

// 1000 Bit
#define QWS 17

uint64_t data[QWS];
uint64_t temp[QWS];
uint64_t mul8[QWS];
uint64_t mul2[QWS];
uint64_t sum[QWS];

uint64_t rem = 0;

void printit(uint64_t dat[], uint64_t rem){
  for (uint8_t i=0; i<QWS; i++){
    printf("%02d %lb\n", i, dat[i]);
  }
  printf("%2s %lb\n", "RE", rem);
}

// result and source can be the same, dividing in-place
void divide(uint64_t result[], uint64_t source[], uint64_t divisor, uint64_t *rem){
  for (uint8_t i=0; i<QWS; i++){
    unsigned __int128 q = ((unsigned __int128)*rem<<64) | source[i];
    result[i]=q / divisor;
    *rem = q % divisor;
    //printf("rem=%d", *rem);
  }
}

uint8_t mult10(uint64_t data[]){
  uint64_t rem = 0;
  uint8_t i=QWS;
  const uint64_t mask = (1ULL << 40) - 1;
  while(i>0){
    i--;
    unsigned __int128 tmp = data[i];
    //printf("mult10: i = %d, tmp = %lb %lb\n", i, (uint64_t)(tmp>>64), (uint64_t)tmp);
    tmp *= 10;
    tmp += rem;
    //printf("mult10: tmp*10 = %lb %lb  ", (uint64_t)(tmp>>64), (uint64_t)tmp);
    rem = tmp>>64;
    //printf(" rem= %lb\n", rem);
    data[i] = (uint64_t)tmp;
  }
  uint8_t ret =  (data[0]>>40);
  data[0] &= mask;
  return ret;
}

void printitdec(uint64_t data[], uint32_t bits){
  //printf("data initial: \n");
  //printit(data, 0);
  printf("bits: %d\n",bits);
  unsigned __int128 tmp = data[QWS-1];
  for (uint32_t i=0; i<bits/3; i++){
    //printf("data step %d: \n", i);
    //printit(data, 0);
    uint8_t dig = mult10(data);
    printf("%d:%d\n", i, dig);
    //printit(data, 0);
  }
}

int main(){
  // init data
  for (uint8_t i=0; i<QWS; i++){
    data[i]=0;
  }
  uint64_t eins = 1;
  data[0] = eins<<40;
  rem = 0;
  printit(data, rem);
  divide(temp, data, 7, &rem);
  printit(temp, rem);
  printitdec(temp, 9090);
  printit(temp, rem);
}

