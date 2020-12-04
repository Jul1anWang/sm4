#ifndef ENC_H
#define ENC_H

#include <time.h>
#include <stdlib.h>

typedef unsigned char  uint8;
typedef uint8 word[4];


void enc(word* plain, word* mkey, word* cipher);
void fault_enc(word* plain, word* mkey, word* cipher);


#endif