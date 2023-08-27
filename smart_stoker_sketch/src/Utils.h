#ifndef _UTILS_INCLUDED_
#define _UTILS_INCLUDED_ 

#ifdef SIMULATOR // sn для симулятора! 
void sncpy(unsigned char *dest, unsigned char *src)  // вместо memcpy  void *dest, void *src    
{ // пересохранить из еепром во flash
	dest[0] = src[0];
	dest[1] = src[1];
	dest[2] = src[2];
	dest[3] = src[3];
	dest[4] = src[4];
	dest[5] = src[5];
	dest[6] = src[6];
	dest[7] = src[7];
	dest[8] = src[8]; // 9-байт!
}
#else     
void sncpy(unsigned char *dest, eeprom unsigned char *src)  // вместо memcpy  void *dest, void *src    
{ // пересохранить из еепром во flash
	dest[0] = src[0];
	dest[1] = src[1];
	dest[2] = src[2];
	dest[3] = src[3];
	dest[4] = src[4];
	dest[5] = src[5];
	dest[6] = src[6];
	dest[7] = src[7];
	dest[8] = src[8]; // 9-байт!
}
#endif  

// функции преобразования чисел (для корректного отображения значений)
//#include "bcd.h" //библиотека работы с BCD (заменить функции bcd и bin функциями из библиотеки bcd.h)
unsigned char bcd (unsigned char data)
{
//return bcd2bin(data);
    unsigned char bc;
 
    bc=((((data&(1<<6))|(data&(1<<5))|(data&(1<<4)))*0x0A)>>4)+((data&(1<<3))|(data&(1<<2))|(data&(1<<1))|(data&0x01));
 
    return bc;
}
 
unsigned char bin(unsigned char dec)
{
//return bin2bcd(dec);
    char bcd;
    char n, dig, num, count;
 
    num = dec;
    count = 0;
    bcd = 0;
    for (n=0; n<4; n++) {
        dig = num%10;
        num = num/10;
        bcd = (dig<<count)|bcd;
        count += 4;
    }

    return bcd;
}

#endif //\_UTILS_INCLUDED_
