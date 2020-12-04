#include "enc.h"
#include "num.h"




//b = a
void copy_word(word a, word b){
    int i;
    for (i = 0;i < 4;i++)b[i] = a[i];
}

void copy_word_4(word* a, word *b){
    int i;
    for (i = 0;i < 4;i++)copy_word(a[i], b[i]);
}

void xor(word a, const word b){
    int i;
    for (i = 0;i < 4;i++)a[i] ^= b[i];
}




// 其实根本不用与之后再右移，强迫症不适合做程序员

void surround_shift_left_2(word a){
    uint8 f = a[0] & 0xc0; //11000000
    a[0] <<= 2;
    a[0] |= ((a[1] & 0xc0) >> 6);
    a[1] <<= 2;
    a[1] |= ((a[2] & 0xc0) >> 6);
    a[2] <<= 2;
    a[2] |= ((a[3] & 0xc0) >> 6);
    a[3] <<= 2;
    a[3] |= (f >> 6);
}

void surround_shift_left_5(word a){
    uint8 f = a[0] & 0xf8; //11111000
    a[0] <<= 5;
    a[0] |= ((a[1] & 0xf8) >> 3);
    a[1] <<= 5;
    a[1] |= ((a[2] & 0xf8) >> 3);
    a[2] <<= 5;
    a[2] |= ((a[3] & 0xf8) >> 3);
    a[3] <<= 5;
    a[3] |= (f >> 3);
}

void surround_shift_left_10(word a){
    uint8 f = a[0];
    a[0] = a[1];
    a[1] = a[2];
    a[2] = a[3];
    a[3] = f;
    surround_shift_left_2(a);
}

void surround_shift_left_18(word a){
    uint8 temp1 = a[0], temp2 = a[1];
    a[0] = a[2];
    a[1] = a[3];
    a[2] = temp1;
    a[3] = temp2;
    surround_shift_left_2(a);
}

void surround_shift_left_24(word a){
    uint8 temp = a[3];
    a[3] = a[2];
    a[2] = a[1];
    a[1] = a[0];
    a[0] = temp;
}

void surround_shift_left_13(word a){
    uint8 f = a[0];
    a[0] = a[1];
    a[1] = a[2];
    a[2] = a[3];
    a[3] = f;
    surround_shift_left_5(a);
}

void surround_shift_left_23(word a){
    surround_shift_left_18(a);
    surround_shift_left_5(a);
}

void L(word a){
    word temp1, temp2, temp3, temp4;
    copy_word(a, temp1);
    copy_word(a, temp2);
    copy_word(a, temp3);
    copy_word(a, temp4);
    surround_shift_left_2(temp1);
    surround_shift_left_10(temp2);
    surround_shift_left_18(temp3);
    surround_shift_left_24(temp4);
    xor(a, temp1);
    xor(a, temp2);
    xor(a, temp3);
    xor(a, temp4);
}

void L_k(word a){
    word temp1, temp2;
    copy_word(a, temp1);
    copy_word(a, temp2);
    surround_shift_left_13(temp1);
    surround_shift_left_23(temp2);
    xor(a, temp1);
    xor(a, temp2);
}

void T(word a){
    int i = 0;
    for (i = 0;i < 4;i++){
        a[i] = s_box[a[i]];
    }
    L(a);
}

void T_k(word a){
    int i = 0;
    for (i = 0;i < 4;i++){
        a[i] = s_box[a[i]];
    }
    L_k(a);
}



void round_enc(word *text, word rkey, word temp){
    copy_word(text[1], temp);
    xor(temp, text[2]);
    xor(temp, text[3]);
    xor(temp, rkey);
    T(temp);
    xor(temp, text[0]);
}

// 感觉考虑解密的话还是直接全部生成出来比较好
void round_key(word* keys, word rkey, uint8 i){
    copy_word(keys[1], rkey);
    xor(rkey, keys[2]);
    xor(rkey, keys[3]);
    xor(rkey, CK[i]);
    T_k(rkey);
    xor(rkey, keys[0]);
}

void key_init(word* mk){
    xor(mk[0], FK[0]);
    xor(mk[1], FK[1]);
    xor(mk[2], FK[2]);
    xor(mk[3], FK[3]);
}



void get_next_text(word *text, word temp){
    copy_word(text[1], text[0]);
    copy_word(text[2], text[1]);
    copy_word(text[3], text[2]);
    copy_word(temp, text[3]); 
}

void fault(word a){
    a[rand()%4] = rand()%16;
}


void enc(word* plain, word* mkey, word* cipher){
    int round = 0, i = 0;
    word text[4];
    word keys[4];
    word temp;
    word rkey;
    copy_word_4(mkey, keys);
    key_init(keys);
    copy_word_4(plain, text);
    
    for (round = 0; round < 32; ++round){
        round_key(keys, rkey, round);
        round_enc(text, rkey, temp);
        get_next_text(text, temp);
        get_next_text(keys, rkey);
    }
    copy_word(text[3], cipher[0]);
    copy_word(text[2], cipher[1]);
    copy_word(text[1], cipher[2]);
    copy_word(text[0], cipher[3]);
}

void fault_enc(word* plain, word* mkey, word* cipher){
    int round = 0, i = 0;
    word text[4];
    word keys[4];
    word temp;
    word rkey;
    copy_word_4(mkey, keys);
    key_init(keys);
    copy_word_4(plain, text);
    
    for (round = 0; round < 32; ++round){
        if (round == 31){
            fault(text[1]);
        }
        round_key(keys, rkey, round);
        round_enc(text, rkey, temp);
        get_next_text(text, temp);
        get_next_text(keys, rkey);
    }
    copy_word(text[3], cipher[0]);
    copy_word(text[2], cipher[1]);
    copy_word(text[1], cipher[2]);
    copy_word(text[0], cipher[3]);
}

