#ifndef _DEFINITIONS_INCLUDED_
#define _DEFINITIONS_INCLUDED_ 

//#define SIMULATOR		// компиляция для симулятора, для отладки на симуляторе ISIS Proteus (убрать eeprom)
#define LCD				// включение/отключение LCD дисплея
//#define TEST			// тестовый режим поиск датчиков
//#define SAVETEMPER	// Включить режим сохранения точек измерения в энергонезависимую память EEPROM
//#define TIMEOUTGET	// определение функции приема байта с таймаутом
#define RECEIVEPACKET	// ожидание прихода всех байтов во входящем буфере
#define MAX_DS1820 3	// кол-во датчиков DS1820 в системе

//#define RTC_DS_3231   // DS_3231 часы реального времени

//#define F_CPU 8000000L						// частота кварца, Гц
//#define TCNT1_1MS (65536-(F_CPU/(256L*1000)))	// столько тиков будет делать T/C1 за 1 мс. (0xFFE1 = 65505), порядок байт в eeprom-> [мл.E1][ст.FF]

#define BYTE    unsigned char
#define SET_B(x) |= (1<<x)
#define CLR_B(x) &=~(1<<x) 
#define INV_B(x) ^=(1<<x)

#endif //\_DEFINITIONS_INCLUDED_
