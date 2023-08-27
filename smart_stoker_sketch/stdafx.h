#ifndef _STDAFX_INCLUDED_
#define _STDAFX_INCLUDED_ 

#include <mega32.h>
#include <1wire.h>
#include <ds1820.h>				// DS1820 Temperature Sensor functions
#include <ds18b20.h>			// DS18b20 Temperature Sensor functions
//#include <ds18x20_v2.h>		// новая либа вместо ds18b20.h - другой формат вывода температуры
//#include <string.h>			// #include -ed для memcpy
#include <delay.h>				// для delay_ms
#include <math.h> 
#include <alcd.h>				// Alphanumeric LCD Module functions
#include <stdlib.h>				// itoa...
#include <stdio.h>				// sprintf
#include <bcd.h>                // библиотека работы с BCD

#include "src\Definitions.h"	// настройка режимов сборки
#include "src\Utils.h"			// вспомогательные функции     
#include "src\Variables.h"		// глобальные переменные
#include "src\RealTimeClock.h"  // часы реального времени ds3231
#include "src\CRC8.h"			// вычисление контрольной суммы

#include "src\ADC.h"			// АЦП
#include "src\ControllerInit.h" // настройка работы контроллера
#include "src\USART.h"          // 
#include "src\Temperature.h"    // функции получения температуры с DS1820 и DS18b20
#include "src\LCD.h"			// LCD - дисплей

#endif //\_STDAFX_INCLUDED_
