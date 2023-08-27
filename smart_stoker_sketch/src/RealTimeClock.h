#ifndef _REAL_TIME_CLOCK_INCLUDED_
#define _REAL_TIME_CLOCK_INCLUDED_ 

// дефайны адресов микросхемы
#define RTC_adr_write 0b11010000    // 0xD0
#define RTC_adr_read  0b11010001    // 0xD1

// переменные времени
unsigned char hour23;
unsigned char minute23;
unsigned char sec23;

// переменные даты
unsigned char day;
unsigned char wday;
unsigned char month;
unsigned char year;

// переменные температуры
//unsigned int  temp;
unsigned char t1;
unsigned char t2;

#asm
   .equ __i2c_port=0x15 ;PORTC
   .equ __sda_bit=1
   .equ __scl_bit=0
#endasm

// необходимые библиотеки  
//#include "bcd.h" //библиотека работы с BCD (заменить функции bcd и bin функциями из библиотеки bcd.h)
#include <i2c.h> //библиотека i2c

// инициализация начальных установок
void RTC_init(void)
{
    i2c_start();                // запуск i2c
    i2c_write(RTC_adr_write);   // передача адреса устройства, режим записи 
    i2c_write(0x0E);            // передача адреса памяти
    i2c_write(0b00100000);      // запустить преобразование температуры и выход на 1 Гц
    i2c_write(0b00001000);      // разрешить выход 32 кГц
    i2c_stop();                 // остановка i2c
}

#define RTC_SEC   0x00	// секунды
#define RTC_MIN   0x01	// минуты
#define RTC_HOUR  0x02	// чаы 
#define RTC_WDAY  0x03	// день недели
#define RTC_DAY   0x04	// число
#define RTC_MONTH 0x05	// месяц
#define RTC_YEAR  0x06	// год (00-99)

// установка параметра ds3231
unsigned char RTC_Get(unsigned char _param)
{
	unsigned char result;

    i2c_start();				// запуск i2c
    i2c_write(RTC_adr_write);	// передача адреса устройства, режим записи
    i2c_write(_param);			// передача адреса памяти
    i2c_stop();					// остановка i2c

    i2c_start();				// запуск i2c
    i2c_write(RTC_adr_read);	// передача адреса устройства, режим чтения
	result = bcd(i2c_read(0));	// чтение секунд, ACK(0), NACK(1)
    i2c_stop();					// остановка i2c 

	return result;
}
// установка параметра ds3231
void RTC_Set(unsigned char _param, unsigned char _value)
{
	i2c_start();				// запуск i2c
	i2c_write(RTC_adr_write);	// передача адреса устройства, режим записи
	i2c_write(_param);			// параметр
	i2c_write(bin(_value));		// значение
	i2c_stop();					// остановка i2c
}

// чтение температуры
unsigned char RTC_Get_temper(unsigned char* wholeT, unsigned char* divT)	// wholeT,divT ^C
{
    i2c_start();                // запуск i2c
    i2c_write(RTC_adr_write);   // передача адреса устройства, режим записи
    i2c_write(0x11);            // передача адреса памяти
    i2c_stop();                 // остановка i2c

    i2c_start();                // запуск i2c
    i2c_write(RTC_adr_read);    // передача адреса устройства, режим чтения
    t1 = i2c_read(0);           // чтение MSB температуры
    t2 = i2c_read(1);           // чтение LSB температуры
    i2c_stop();                 // остановка i2c

    t2=(t2>>7);                 // сдвигаем на 6 - точность 0,25 (2 бита)
                                // сдвигаем на 7 - точность 0,5 (1 бит)
    t2=t2*5;

	*wholeT = t1;
	*divT = t2;
	return t1;
}

// получение времени и даты
void RTC_read_time(void)
{
    i2c_start();                    // запуск i2c
    i2c_write(RTC_adr_write);       // передача адреса устройства, режим записи
    i2c_write(0x00);                // передача адреса памяти
    i2c_stop();                     // остановка i2c
    i2c_start();                    // запуск i2c
    i2c_write(RTC_adr_read);        // передача адреса устройства, режим чтения
        sec23 = bcd(i2c_read(0));   // чтение секунд, ACK
    i2c_stop();                     // остановка i2c
 
        i2c_start();                // запуск i2c
    i2c_write(RTC_adr_write);       // передача адреса устройства, режим записи
    i2c_write(0x01);                // передача адреса памяти
    i2c_stop();                     // остановка i2c
    i2c_start();                    // запуск i2c
    i2c_write(RTC_adr_read);        // передача адреса устройства, режим чтения
         minute23 = bcd(i2c_read(0));     // чтение минут, ACK
    i2c_stop();                     // остановка i2c
 
        i2c_start();                // запуск i2c
    i2c_write(RTC_adr_write);       // передача адреса устройства, режим записи
    i2c_write(0x02);                // передача адреса памяти
    i2c_stop();                     // остановка i2c
    i2c_start();                    // запуск i2c
    i2c_write(RTC_adr_read);        // передача адреса устройства, режим чтения
        hour23 = bcd(i2c_read(0));  // чтение часов, ACK
    i2c_stop();
 
        i2c_start();                // запуск i2c
    i2c_write(RTC_adr_write);       // передача адреса устройства, режим записи
    i2c_write(0x03);                // передача адреса памяти
    i2c_stop();                     // остановка i2c
    i2c_start();                    // запуск i2c
    i2c_write(RTC_adr_read);        // передача адреса устройства, режим чтения
        wday = bcd(i2c_read(0));    // чтение день недели, ACK
    i2c_stop();
 
        i2c_start();                // запуск i2c
    i2c_write(RTC_adr_write);       // передача адреса устройства, режим записи
    i2c_write(0x04);                // передача адреса памяти
    i2c_stop();                     // остановка i2c
    i2c_start();                    // запуск i2c
    i2c_write(RTC_adr_read);        // передача адреса устройства, режим чтения
        day = bcd(i2c_read(0));     // чтение число, ACK
    i2c_stop();
 
        i2c_start();                // запуск i2c
    i2c_write(RTC_adr_write);       // передача адреса устройства, режим записи
    i2c_write(0x05);                // передача адреса памяти
    i2c_stop();                     // остановка i2c
    i2c_start();                    // запуск i2c
    i2c_write(RTC_adr_read);        // передача адреса устройства, режим чтения
        month = bcd(i2c_read(0));   // чтение месяц, ACK
    i2c_stop();
    
        i2c_start();                // запуск i2c
    i2c_write(RTC_adr_write);       // передача адреса устройства, режим записи
    i2c_write(0x06);                // передача адреса памяти
    i2c_stop();                     // остановка i2c
    i2c_start();                    // запуск i2c
    i2c_write(RTC_adr_read);        // передача адреса устройства, режим чтения
        year = bcd(i2c_read(1));    // чтение год, NACK
    i2c_stop();
}

// установка времени
void RTC_write_minute23(unsigned char min1)
{
    i2c_start();                // запуск i2c
    i2c_write(RTC_adr_write);   // передача адреса устройства, режим записи
    i2c_write(0x01);            // 0x01 минуты
    i2c_write(bin(min1));
    i2c_stop();                 // остановка i2c
}

void RTC_write_hour23(unsigned char hour1)
{
    i2c_start();                // запуск i2c
    i2c_write(RTC_adr_write);   // передача адреса устройства, режим записи
    i2c_write(0x02);            // 0x02 часы
    i2c_write(bin(hour1));
    i2c_stop();                 // остановка i2c
}
 
void RTC_write_sec23(unsigned char sec1)
{
    i2c_start();                // запуск i2c
    i2c_write(RTC_adr_write);   // передача адреса устройства, режим записи
    i2c_write(0x00);            // 0x00 секунды
    i2c_write(bin(sec1));
    i2c_stop();                 // остановка i2c
}
 
// установка даты
void RTC_write_wday23(unsigned char wday1)
{ 
    i2c_start();                // запуск i2c
    i2c_write(RTC_adr_write);   // передача адреса устройства, режим записи
    i2c_write(0x03);            // 0x01 минуты
    i2c_write(bin(wday1));
    i2c_stop();                 // остановка i2c
} 
 
void RTC_write_day23(unsigned char day1)
{
    i2c_start();                // запуск i2c
    i2c_write(RTC_adr_write);   // передача адреса устройства, режим записи
    i2c_write(0x04);            // 0x01 минуты
    i2c_write(bin(day1));
    i2c_stop();                 // остановка i2c
} 
 
void RTC_write_month23(unsigned char month1)
{
    i2c_start();                // запуск i2c
    i2c_write(RTC_adr_write);   // передача адреса устройства, режим записи
    i2c_write(0x05);            // 0x01 минуты
    i2c_write(bin(month1));
    i2c_stop();                 // остановка i2c
}  

void RTC_write_year23(unsigned char year1)
{
    i2c_start();                // запуск i2c
    i2c_write(RTC_adr_write);   // передача адреса устройства, режим записи
    i2c_write(0x06);            // 0x01 минуты
    i2c_write(bin(year1));
    i2c_stop();                 // остановка i2c
}     

// чтение температуры
void RTC_read_temper(void)
{
    i2c_start();                // запуск i2c
    i2c_write(RTC_adr_write);   // передача адреса устройства, режим записи
    i2c_write(0x11);            // передача адреса памяти
    i2c_stop();                 // остановка i2c

    i2c_start();                // запуск i2c
    i2c_write(RTC_adr_read);    // передача адреса устройства, режим чтения
    t1 = i2c_read(0);           // чтение MSB температуры
    t2 = i2c_read(1);           // чтение LSB температуры
    i2c_stop();                 // остановка i2c

    t2=(t2>>7);                 // сдвигаем на 6 - точность 0,25 (2 бита)
                                // сдвигаем на 7 - точность 0,5 (1 бит)
    t2=t2*5;
}

//в void main добавить инициализацию
//RTC_init();

#endif // _REAL_TIME_CLOCK_INCLUDED_
